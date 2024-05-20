const bool VERBOSE = false;

#import <Cocoa/Cocoa.h>
#import "meshopt.h"

// https://github.com/zeux/meshoptimizer
#import "meshoptimizer.h"

bool isSameClassName(id a, NSString *b) { return (a&&[[a className] compare:b]==NSOrderedSame); }
bool isNumber(id a) { return isSameClassName(a,@"__NSCFNumber"); }

void meshopt(std::vector<float> *v, std::vector<unsigned int> *f, NSString *params) {
    
    const size_t attr_count = v->size()/3;
    const int attr_stride = 3;
    float *attr = new float[attr_count*attr_stride];
    for(int n=0; n<attr_count; n++) {
        attr[n*attr_stride+0] = (*v)[n*3+0];
        attr[n*attr_stride+1] = (*v)[n*3+1];
        attr[n*attr_stride+2] = (*v)[n*3+2];
    }
    
    const size_t index_count = f->size();
    unsigned int *indices = f->data();
    unsigned int *result_indices = new unsigned int[index_count];
    
    float target_error = 1e-2f;
    float result_error = 0;
    
    float si = 0.5;
    
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    if(params) {
        settings = [NSJSONSerialization JSONObjectWithData:[[[NSRegularExpression regularExpressionWithPattern:@"(/\\*[\\s\\S]*?\\*/|//.*)" options:1 error:nil] stringByReplacingMatchesInString:params options:0 range:NSMakeRange(0,params.length) withTemplate:@""] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        if(isNumber(settings[@"si"])) si = [settings[@"si"] floatValue];
    }
        
    size_t result_index_count = meshopt_simplify(result_indices,indices,index_count,attr,attr_count,attr_stride*sizeof(float),index_count*si,target_error,0,&result_error);
    float *result_attr = new float[attr_count*attr_stride];
    size_t result_attr_count = meshopt_optimizeVertexFetch(result_attr,result_indices,result_index_count,attr,attr_count,attr_stride*sizeof(float));
    
    
    v->clear();
    f->clear();
    
    for(int n=0; n<result_attr_count; n++) {
        v->push_back(result_attr[n*attr_stride+0]);
        v->push_back(result_attr[n*attr_stride+1]);
        v->push_back(result_attr[n*attr_stride+2]);
    }

    for(int k=0; k<result_index_count/3; k++) {
        f->push_back(result_indices[k*3+0]);
        f->push_back(result_indices[k*3+1]);
        f->push_back(result_indices[k*3+2]);
    }
    

    delete[] attr;
    
    delete[] result_indices;
    

}