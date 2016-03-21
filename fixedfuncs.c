#include <stdio.h>
#include <string.h>

#define MAX_DECIMAL_DIGITS 8
/* Multiply an unpacked BCD number by 2. Return 1 if there is a
   carry out of the most significant digit. 0 otherwise.  The
   resulting number is returned in n1.
*/
int base10double(char n1[MAX_DECIMAL_DIGITS])
{
  int i, tmp, carry=0;
  for(i=0;i<MAX_DECIMAL_DIGITS;i++)
    {
      n1[i] += (n1[i] + carry);
      if(n1[i] > 9)
	{
	  n1[i] -= 10;
	  carry = 1;
	}
      else
	carry=0;
    }
  return carry;
}

/* Convert a string into a signed fixed-point binary
   representation with up to 32 bits of fractional part.
*/
int strtoSfixed(char *s, int frac_bits)
{
  char *point = s;
  unsigned int value;
  int i,negative=0;
  char digits[MAX_DECIMAL_DIGITS];
  /* get the integer portion*/
  if(*s=='-')
    {
      negative=1;
      s++;
    }
  value = atoi(s);
  /* find the decimal point */
  while((*point != '.')&&(*point != 0))
    point++;
  /* if there is nothing after the decimal point, or there is
     not a decimal point, then shift and return what we already
     have */
  if(( *point == 0 ) || ( *(point+1) == 0 ))
    {
      if(negative)
	value = -value;
      return value << frac_bits;
    }
  ++point;
  /* convert the remaining part into an unpacked BCD number. */
  for(i=(MAX_DECIMAL_DIGITS-1);i>=0;i--)
    {
      if(*point == 0)
	digits[i] = 0;
      else
	{
	  digits[i] = *point - '0';
	  ++point;
	}
    }
  /* convert the unpacked BCD number into binary */
  while(frac_bits > 0)
    {
      value <<= 1;
      if(base10double(digits))
	value |= 1;
      frac_bits--;
    }
  /* negate if there was a leading '-' */
  if(negative)
    value = -value;
  return value;
}

/* Print an unsigned fixed point number with the given number of
   bits in the fractional part.  NOTE: frac_bits must be between
   0 and 28 for this function to work properly.
*/
void printS( int num, int frac_bits, int decimal )
{ 
  unsigned int mask = (1 << frac_bits) - 1;
  unsigned int fracpart;
  if(num < 0)
    {
      printf("-");
      num = -num;
    }
  /* Print the integer part (with the sign, if it is negative) */
  printf("%d.",num>>frac_bits);
  /* Remove the integer part and keep the fraction part */
  fracpart = num & mask;
  /* Print all of the digits in the fraction part . The post -
     test loop ensures that the first digit is printed , even if
     it is zero. */
  do {
    /* Remember that multiplying by the constant ten can be done
       using a shift followed by an add with operand2 shifted ,
       or the other way around ... two instructions on the ARM
       processor. That is much faster than a mul instruction. */
    fracpart *= 10;
    printf ("%u", fracpart >> frac_bits);
    fracpart &= mask ;
	decimal--;
  } while (decimal);
}

