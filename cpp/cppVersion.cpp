#include <viennacl/vector.hpp>
#include <vector>
#include <iostream>
typedef double scalarT;

extern "C" {
    void cppAdditionImpl(int size) {
        viennacl::vector<scalarT> calc(size);
        for (size_t i=0; i<calc.size(); ++i)
            calc[i] = i;
        viennacl::vector<scalarT> result(size);
        result = calc + calc;
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
