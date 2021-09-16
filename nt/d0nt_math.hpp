/**
* File						: d0math
* Author					: Gordon Watts (gwatts@fnal.gov) & Onne Peters (opeters@fnal.gov)
* Created					: 5/24/1999
* Last updated				: 5/24/1999
* Description				: This is a workaround for the fact that the math functions in cmath are not 
*							: part of the standard namespace. This file gets included instead of <cmath>
*							: or <math.h> by using the #pragma include_alias directive.
**/

#ifndef D0MATH
#define D0MATH

// This is needed, because of the line
// #pragma include_alias(<cmath>, <d0math>) 
// in nt_settings.hpp. That caused the #include <cmath> here to become <d0math>, and
// the header would include itself...Luckily enough transitivity is not supported for
// these #pragma's...

#pragma include_alias(<cmath_temp>, <cmath>)

#include <cmath_temp>
#include <complex>

namespace std {
	// abs functions
	//template< class T >
	//inline T abs(T number) {
	//	return ::abs(number);
	//}
	
	// Specify this for double, floats and longs, so that fabs/labs gets called instead of
	// abs. 
	// double a = abs(-0.255) gives 0.
	//inline double abs(double number) {
	//	return ::fabs(number);
	//}
	
	inline float abs(float number) {
		return (float)::fabs(number);
	} 

	inline long abs(long number) {
		return ::labs(number);
	}

	// Seems to be some sort of template specilization problem... this workaround seems to work..
	//inline double abs (std::complex<double> &c) {
	//	return abs<complex<double> > (c);
	//};

	// acos functions
	template< class T > 
	inline T acos(T number) {
		return ::acos(number);
	}

	// asin functions
	template< class T > 
	inline T asin(T number) {
		return ::asin(number);
	}

	// atan functions
	template< class T > 
	inline T atan(T number) {
		return ::atan(number);
	}

	// atan2 functions
	template< class T > 
	inline T atan2(T number) {
		return ::atan2(number);
	}

	// cos functions
	template< class T > 
	inline T cos(T number) {
		return ::cos(number);
	}

	// cosh functions
	template< class T > 
	inline T cosh(T number) {
		return ::cosh(number);
	}

	// exp functions
	//template< class T > 
	//inline T exp(T number) {
	//	return ::exp(number);
	//}

	// fabs functions
	//template< class T > 
	//inline T fabs(T number) {
	//	return ::fabs(number);
	//}

	// fmod functions
	template< class T1, class T2 > 
	inline T1 fmod(T1 number1, T2 number2) {
		return ::asin(number1, number2);
	}

	// labs function
	template< class T >
	inline T labs(T number) {
		return ::labs(number);
	}

	// log functions
	//template< class T > 
	//inline T log(T number) {
	//	return ::log(number);
	//}

	// log10 functions
	template< class T > 
	inline T log10(T number) {
		return ::log10(number);
	}

	// pow functions
	//template< class T1, class T2 > 
	//inline T1 pow(T1 number1, T2 number2) {
	//	return ::pow(number1, number2);
	//}

	// sin functions
	template< class T > 
	inline T sin(T number) {
		return ::sin(number);
	}

	// sinh functions
	template< class T > 
	inline T sinh(T number) {
		return ::sinh(number);
	}

	// tan functions
	template< class T > 
	inline T tan(T number) {
		return ::tan(number);
	}

	// tanh functions
	template< class T > 
	inline T tanh(T number) {
		return ::tanh(number);
	}

	// sqrt functions
	template< class T > 
	inline T sqrt(T number) {
		return ::sqrt(number);
	}
} // namespace std

#endif // D0MATH
