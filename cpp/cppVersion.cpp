#include <viennacl/vector.hpp>
#include <vector>
#include <iostream>
typedef double scalarT;

extern "C" {
    void cppAdditionImpl(int size) {
        std::vector<scalarT> input(size);
        for (size_t i=0; i<input.size(); ++i)
            input[i] = i;
        std::vector<scalarT> output(size);
        for (size_t i=0; i<input.size(); ++i) {
            output[i] = input[i] + input[i];
        }
             
        //       return output;
    }
}
/*
int main() {
    std::vector<scalarT> result = cppAdditionImpl(100);
    for(size_t i = 0 ; i < result.size(); ++i)
        std::cout<<result[i]<<", ";
    
    return 0;
}
        

        
*/
