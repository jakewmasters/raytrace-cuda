#include <stdio.h>
#include <stdlib.h>
#include <zlib.h>

#include "sphere.cpp"
#include "hitablelist.cpp"
#include "float.h"
#include "camera.cpp"

float hit_sphere(const vec3& center, float radius, const ray& r){
    vec3 oc = r.origin() - center;
    float a = dot(r.direction(), r.direction());
    float b = 2.0 * dot(oc, r.direction());
    float c = dot(oc, oc) - radius*radius;
    float discriminant = b*b - 4*a*c;
    if(discriminant < 0){
        return -1.0;
    } else {
        return (-b - sqrt(discriminant)) / (2.0*a);
    }
}

vec3 color(const ray& r, hitable *world/*, int depth*/){
    hit_record rec;
    if (world->hit(r,0.001,MAXFLOAT,rec)) {
        vec3 target = rec.p + rec.normal + random_in_unit_sphere();
        return 0.5*color(ray(rec.p, target-rec.p),world);
        // ray scattered;
        // vec3 attenuation;
        // if (depth < 50 && rec.mat_ptr->scatter(r, rec, attenuation, scattered)) {
        //     return attenuation*color(scattered, world, depth+1);
        // } else {
        //     return vec3(0,0,0);
        // }
    } else {
        vec3 unit_direction = unit_vector(r.direction());
        float t = 0.5*(unit_direction.y() + 1.0);
        return (1.0-t)*vec3(1.0,1.0,1.0) + t*vec3(0.5,0.7,1.0);    
    }
}

void usage(char *prog_name) {
    fprintf(stderr, "%s: [-h] -o <out_file>...\n", prog_name);
    fprintf(stderr, "  -o        exactly one output file must be specified\n");
    fprintf(stderr, "  -h        print this help and exit\n");
}

int main(int argc, char **argv) {

    char *prog_name = argv[0];
    char *out_file;

    int ch;
    while ((ch = getopt(argc, argv, "ho:")) != -1) {
        switch(ch) {
            case 'o':
                out_file = optarg;
                break;
            case '?':
            default:
                usage(prog_name);
        }
    }

    int nx = 512;
    int ny = 512;
    int ns = 100;

    FILE *out_file_ptr;
    if ((out_file_ptr = fopen(out_file, "w")) == NULL) {
        fprintf(stderr, "can't open %s for reading...\n", out_file);
        exit(1);
    }
    fprintf(out_file_ptr, "P3\n%d %d\n255\n", nx, ny);

    hitable *list[4];
    list[0] = new sphere(vec3(0,0,-1), 0.5, new lambertian(vec3(0.8,0.3,0.3)));
    list[1] = new sphere(vec3(0,-100.5,-1), 100, new lambertian(vec3(0.8,0.8,0.0)));
    list[2] = new sphere(vec3(1,0,-1),0.5, new metal(vec3(0.8,0.6,0.2)));
    list[3] = new sphere(vec3(-1,0,-1),0.5, new metal(vec3(0.8,0.8,0.8)));
    hitable *world = new hitable_list(list,2);
    camera cam;

    for (int j=ny-1; j >=0; --j){
        for (int i=0; i < nx; ++i){
            vec3 col(0,0,0);
            for (int s=0; s < ns; ++s){
                float u = float(i + drand48()) / float(nx);
                float v = float(j + drand48()) / float(ny);
                ray r = cam.get_ray(u,v);
                vec3 p = r.point_at_parameter(2.0);
                col += color(r,world/*, 0*/);    
            }
            col /= float(ns);
            col = vec3(sqrt(col[0]), sqrt(col[1]), sqrt(col[2]));
            int ir = int(255.99*col[0]);
            int ig = int(255.99*col[1]);
            int ib = int(255.99*col[2]);
            fprintf(out_file_ptr, "%d %d %d\n", ir, ig, ib);
        }
    }
}