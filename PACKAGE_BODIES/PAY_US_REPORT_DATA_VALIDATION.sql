--------------------------------------------------------
--  DDL for Package Body PAY_US_REPORT_DATA_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_REPORT_DATA_VALIDATION" AS
/* $Header: payusdatavalid.pkb 115.3 2003/12/09 17:04 sodhingr noship $  */

 /*===========================================================================+
 |               Copyright (c) 2001 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+

  Name
    pay_us_report_data_validation

  Purpose
    The purpose of this package is to validate EIN, SSN etc
    to support the generation of magnetic tape W2 / SQWL reports
    for US legilsative requirements.

   Notes
    Referenced By:  Package  pay_us_reporting_utils_pkg

   Notes

   History
   15-Jul-03  ppanda      115.0                Created
   15-OCT-03  ppanda      115.2  2787752       EIN Validation for set of numbers
                                               commented out.
                                 3084344       SSN Validation for W-2 Mag changed
                                               Invalid SSN would be 111-11-1111, 333-33-3333
                                               first 3 digits 000 or 666
                                               and last 4 digits 0000
  09-DEC-03  sodhingr     115.3  3084344       changed the variable l_last_four_chars to take the
                                               last four chars
*/

/* Following is to validate EIN to support SQWL Reporting */
FUNCTION validate_SQWL_EIN( p_report_qualifier IN  varchar2,
                            p_record_name      IN  varchar2,
                            p_input_2          IN  varchar2,
                            p_input_4          IN  varchar2,
                            p_validate         IN  varchar2,
                            p_err              OUT nocopy boolean
                          ) return varchar2 IS
-- Local Variables
return_value    varchar2(100);
BEGIN
   IF p_report_qualifier = 'NY_SQWL' THEN
       return_value := rpad(substr(replace(p_input_2,'-'),1,11),11,' ');
   ELSE
       return_value := lpad(substr(replace(p_input_2,'-'),1,9),9,0); /*Bug:2409031*/
   END IF;
   return return_value;
END validate_SQWL_EIN;

/* Following is to validate EIN to support W2 Reporting */

FUNCTION validate_W2_EIN( p_report_qualifier IN  varchar2,
                          p_record_name      IN  varchar2,
                          p_input_2          IN  varchar2,
                          p_input_4          IN  varchar2,
                          p_validate         IN  varchar2,
                          p_err              OUT nocopy boolean
                        ) return varchar2 IS
-- Local Variables
return_value    varchar2(100);
l_description   varchar2(50);
l_err boolean := FALSE;

BEGIN
/* IF the EIN starts with any of these numbers the exclude flag
   should be set based on p_validate.*/
/* This validation is commented to fix Bug # 2787752
   EIN should not be Validated for these starting Numbers

   IF (( substr(p_input_2,1,2) = '00'  ) OR
       ( substr(p_input_2,1,2) = '07'  ) OR
       ( substr(p_input_2,1,2) = '08'  ) OR
       ( substr(p_input_2,1,2) = '09'  ) OR
       ( substr(p_input_2,1,2) = '10'  ) OR
       ( substr(p_input_2,1,2) = '17'  ) OR
       ( substr(p_input_2,1,2) = '18'  ) OR
       ( substr(p_input_2,1,2) = '19'  ) OR
       ( substr(p_input_2,1,2) = '20'  ) OR
       ( substr(p_input_2,1,2) = '26'  ) OR
       ( substr(p_input_2,1,2) = '27'  ) OR
       ( substr(p_input_2,1,2) = '28'  ) OR
       ( substr(p_input_2,1,2) = '29'  ) OR
       ( substr(p_input_2,1,2) = '30'  ) OR
       ( substr(p_input_2,1,2) = '40'  ) OR
       ( substr(p_input_2,1,2) = '49'  ) OR
       ( substr(p_input_2,1,2) = '50'  ) OR
       ( substr(p_input_2,1,2) = '60'  ) OR
       ( substr(p_input_2,1,2) = '69'  ) OR
       ( substr(p_input_2,1,2) = '70'  ) OR
       ( substr(p_input_2,1,2) = '78'  ) OR
       ( substr(p_input_2,1,2) = '79'  ) OR
       ( substr(p_input_2,1,2) = '80'  ) OR
       ( substr(p_input_2,1,2) = '89'  ) OR
       ( substr(p_input_2,1,2) = '90'  )  )
*/
   IF p_input_2 IS NULL
   THEN
--{
       hr_utility.trace('ERROR: EIN is NULL');
       l_description:='EIN '||substr(p_input_2,1,9)||
                      ' is Invalid. EIN cannot be NULL';
       pay_core_utils.push_message(801,'PAY_INVALID_ER_FORMAT','P');
       pay_core_utils.push_token('record_name',p_record_name);
       pay_core_utils.push_token('name_or_number',p_input_4);
       pay_core_utils.push_token('description',l_description);
       l_err:=TRUE;
--}
   END IF;
   p_err := l_err;
  /*Bug:2159881 */
   return_value := rpad(substr(replace(replace(nvl(replace(p_input_2,' '),' '),'-'),'/'),1,9),9);
   return return_value;
end validate_W2_EIN;
-- End EIN Validation for W2 reporting
--
/* Following is to validate SSN to support SQWL Reporting */
FUNCTION validate_SQWL_SSN(p_effective_date       IN  varchar2,
                           p_report_type          IN  varchar2,
                           p_format               IN  varchar2,
                           p_report_qualifier     IN  varchar2,
                           p_record_name          IN  varchar2,
                           p_input_1              IN  varchar2,
                           p_input_2              IN  varchar2,
                           p_input_3              IN  varchar2,
                           p_input_4              IN  varchar2,
                           p_input_5              IN  varchar2,
                           p_validate             IN  varchar2,
                           p_err                  OUT nocopy boolean
                          ) return varchar2 IS
-- Local Variables
l_err           boolean := FALSE;
return_value    varchar2(100);
l_length        number(10);
l_message       varchar2(2000);
l_number_length number(10);
l_description   varchar2(50);
l_input_2       varchar2(100);
l_ssn           varchar2(50);

TYPE special_numbers is record(p_number_set varchar2(50));
special_number_record  special_numbers;

TYPE ssn_special_number_rec is table of special_number_record%type
                               INDEX BY binary_integer;
ssn_check  ssn_special_number_rec;
BEGIN
   /* SSN valid check */

   hr_utility.trace('Input SSN  before Validation '||p_input_2);
   IF ((p_report_qualifier = 'MN_SQWL') OR
       (p_report_qualifier = 'GA_SQWL')) THEN
-- Character hypen, period and quotes are eliminated
      l_ssn := replace(replace(replace(
                 replace(pay_us_reporting_utils_pkg.character_check(p_input_2),
                               ' '),'-'),'.'),'''');
   ELSE
-- Character I is eliminated in addition to hypen, period and quotes
      l_ssn := replace(replace(replace(replace(
                 replace(pay_us_reporting_utils_pkg.character_check(p_input_2),
                               ' '),'I'),'-'),'.'),'''');
   END IF;

   hr_utility.trace('SSN after eliminating special chars = '||l_ssn);
-- Validation for SSN starting with 8 or 9
-- When SSN starting with 8 or 9 a warning is logged
--
   IF ((substr(l_ssn,1,1) = '8') OR (substr(l_ssn,1,1) = '9'))  THEN
      l_description:= 'Invalid SSN. SSN should not begin with '||
                             substr(l_ssn,1,1);
      --l_err:=TRUE;
      -- Bug # 2183859
      -- This should be a warning instead of an error
      pay_core_utils.push_message(801,'PAY_INVALID_EE_FORMAT_WARNING','A');
      pay_core_utils.push_token('record_name',substr(p_record_name,1,50));
      pay_core_utils.push_token('name_or_number',substr(p_input_4,1,50));
      pay_core_utils.push_token('description',substr(l_description,1,50));
      /* WARNING in RW record for employee 1234.SSN 912345697 is invalid.SSN
                 cannot begin with 9 */
      hr_utility.trace('Warning in '||p_record_name||'for employee '||
                               p_input_4||l_description);
   ELSE
-- Validation for Special numbers wrongly used as SSN
-- An error is logged for these numbers
      ssn_check(1).p_number_set := '111111111';
      ssn_check(2).p_number_set := '222222222';
      ssn_check(3).p_number_set := '333333333';
      ssn_check(4).p_number_set := '444444444';
      ssn_check(5).p_number_set := '555555555';
      ssn_check(6).p_number_set := '666666666';
      ssn_check(7).p_number_set := '777777777';
      ssn_check(8).p_number_set := '123456789';

      FOR i in 1 .. 8 LOOP
         IF l_ssn = ssn_check(i).p_number_set THEN
            l_err:=TRUE;
            l_description := 'Social Security '||l_ssn||' is Invalid.';
            hr_utility.trace(l_description);
          END IF;
      END LOOP;
   END IF; -- End of check for SSN starting with 8 or 9

-- For SQWL an error message is logged but record is not invalidated
-- when these numbers used as SSN
   IF l_err THEN
      pay_core_utils.push_message(801,'PAY_INVALID_EE_FORMAT','A');
      pay_core_utils.push_token('record_name',substr(p_record_name,1,50));
      pay_core_utils.push_token('name_or_number',substr(p_input_4,1,50));
      pay_core_utils.push_token('description',substr(l_description,1,50));
      /* Error in RW record for employee 1234.SSN 912345697 is
               invalid.SSN cannot begin with 9 */
      hr_utility.trace('Error in '||p_record_name||'for employee '||
                            p_input_4||l_description);
      return_value:= rpad(substr(l_ssn,1,9),9);
      IF p_report_type = 'SQWL' THEN /*Bug:2309772. */
         l_err := FALSE;
      END IF;
   ELSE
      hr_utility.trace('Valid SSN');
      IF l_ssn IS NULL THEN --SSN null check
         return_value:= '000000000';
         IF p_report_qualifier = 'AZ_SQWL' THEN
            hr_utility.trace('SSN is BLANK.Padding spaces to 1 ');
            return_value := rpad('1',9);
         ELSE
            l_description:= 'SSN is blank. Padded with zeros';
            -- Bug # 2183859
            -- This would be a informative warning
            pay_core_utils.push_message(801,'PAY_INVALID_EE_FORMAT_WARNING','A');
            pay_core_utils.push_token('record_name',substr(p_record_name,1,50));
            pay_core_utils.push_token('name_or_number',substr(p_input_4,1,50));
            pay_core_utils.push_token('description',substr(l_description,1,50));
            /* WARNING in RW record for employee 1234.SSN is blank padded with zeros*/
            hr_utility.trace('Warning in '||p_record_name||'for employee '||
                                                 p_input_4||l_description);
          END IF;
-- If SSN is I after stripping hypen, period and quotes a warning message
-- is logged and I padded with blanks is reported as SSN
--
      ELSIF l_ssn = 'I' THEN
          return_value := rpad(l_ssn,9);
      ELSE
-- If SSN is valid and Not Null
          hr_utility.trace('Valid SSN after all checks = '||return_value);
          return_value:= rpad(substr(l_ssn,1,9),9);
      END IF; --SSN null check
   END IF; -- SSN valid check
   p_err := l_err;
   return return_value;
END validate_SQWL_SSN;


/* Following is to validate EIN to support W2 Reporting */

FUNCTION validate_W2_SSN(p_effective_date       IN  varchar2,
                         p_report_type          IN  varchar2,
                         p_format               IN  varchar2,
                         p_report_qualifier     IN  varchar2,
                         p_record_name          IN  varchar2,
                         p_input_1              IN  varchar2,
                         p_input_2              IN  varchar2,
                         p_input_3              IN  varchar2,
                         p_input_4              IN  varchar2,
                         p_input_5              IN  varchar2,
                         p_validate             IN  varchar2,
                         p_err                  OUT nocopy boolean
                        ) return varchar2 IS
l_err             boolean           := FALSE;
l_warning         boolean           := FALSE;
return_value      varchar2(100);
l_length          number(10);
l_message         varchar2(2000);
l_number_length   number(10);
l_description     varchar2(50);
l_input_2         varchar2(100);
l_ssn             varchar2(50);
l_1st_three_chars varchar2(10);
l_last_four_chars varchar2(10);

TYPE special_numbers is record(p_number_set varchar2(50));
special_number_record  special_numbers;

TYPE ssn_special_number_rec is table of special_number_record%type
                               INDEX BY binary_integer;
ssn_check  ssn_special_number_rec;
BEGIN
   /* SSN validation for W2 reporting */
   hr_utility.trace('Input SSN  before Validation '||p_input_2);

-- Character I is eliminated in addition to hypen, period and quotes
   l_ssn := replace(replace(replace(replace(
                 replace(pay_us_reporting_utils_pkg.character_check(p_input_2),
                               ' '),'I'),'-'),'.'),'''');
   hr_utility.trace('SSN after eliminating special chars = '||l_ssn);
   l_1st_three_chars :=  substr(l_ssn,1,3);
   l_last_four_chars :=  substr(l_ssn,(length(l_ssn)-3));

-- Validation for SSN starting with 8 or 9
-- When SSN starting with 8 or 9 a warning is logged
--
   IF ((substr(l_ssn,1,1) = '8') OR (substr(l_ssn,1,1) = '9'))  THEN
      -- Bug # 2183859
      -- This should be a warning instead of an error
      l_warning := TRUE;
      l_description:= 'Invalid SSN. SSN should not begin with '||
                                              substr(l_ssn,1,1);
   ELSE

/*   New set of Number need to be used for SSN Validation
     Validation for Special numbers wrongly used as SSN
     A warning is logged for these numbers
     This is result of bug fix 3084344
*/
      ssn_check(1).p_number_set := '111111111';
      ssn_check(2).p_number_set := '222222222';
      ssn_check(3).p_number_set := '333333333';
      ssn_check(4).p_number_set := '444444444';
      ssn_check(5).p_number_set := '555555555';
      ssn_check(6).p_number_set := '666666666';
      ssn_check(7).p_number_set := '777777777';
      ssn_check(8).p_number_set := '123456789';

      FOR i in 1 .. 8 LOOP
         IF l_ssn = ssn_check(i).p_number_set THEN
            l_warning :=TRUE;
            l_description := 'SSN '||l_ssn||' has Invalid combinations.';
            hr_utility.trace(l_description);
          END IF;
      END LOOP;
-- First 3 digits of SSN should not be 000 or 666
      if (l_1st_three_chars = '000' or
          l_1st_three_chars = '666' ) then
--{
            l_warning:=TRUE;
            l_description := 'SSN  '||l_ssn||' is Invalid as 1st 3 digits 000/666';
            hr_utility.trace(l_description);
--}
-- Last 4 digits of SSN should not be 0000
      elsif (l_last_four_chars = '0000') then
            l_warning:=TRUE;
            l_description := 'SSN  '||l_ssn||' is Invalid as last 4 digits 0000';
            hr_utility.trace(l_description);
      end if;

   END IF; -- End of check for SSN starting with 8 or 9

-- Set Return Value
   IF l_ssn IS NULL THEN --SSN null check
         l_warning:=TRUE;
         return_value:= '000000000';
         l_description:= 'SSN is blank. Padded with zeros';
   ELSE
         return_value:= rpad(substr(l_ssn,1,9),9);
   END IF;


-- For W2 a warning message is logged but record is processed without Invalidating
--
   IF l_warning THEN
      pay_core_utils.push_message(801,'PAY_INVALID_EE_FORMAT_WARNING','A');
      pay_core_utils.push_token('record_name',substr(p_record_name,1,50));
      pay_core_utils.push_token('name_or_number',substr(p_input_4,1,50));
      pay_core_utils.push_token('description',substr(l_description,1,50));
      hr_utility.trace('WARNING: in '||p_record_name||'for employee '||
                                                p_input_4||l_description);
   END IF; -- SSN valid check
   p_err := FALSE;
   return return_value;
END validate_W2_SSN;
-- End of validate_W2_SSN
--

-- End of Package Body pay_us_reporting_data_validation
END pay_us_report_data_validation;

/
