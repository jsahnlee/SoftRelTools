#pragma warning (disable: 4786)
#pragma warning (disable: 4503)
#define for if(0);else for

//
// Remap cmath to fix it up (mostly Onne's work)
//

#pragma include_alias (<cmath>, <SoftRelTools/nt/d0nt_math.hpp>)
