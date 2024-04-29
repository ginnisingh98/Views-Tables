--------------------------------------------------------
--  DDL for Package Body PAY_US_MMRF2_W2C_FORMAT_RECORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_MMRF2_W2C_FORMAT_RECORD" AS
/* $Header: payusw2cmagfreco.pkb 120.2 2007/01/10 13:14:52 sausingh noship $  */

 /*===========================================================================+
 |               Copyright (c) 2001 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+

  Name
    pay_us_mmrf2_w2c_format_record

  File Name:
    payusw2cmagfreco.pkb

  Purpose
    The purpose of this package is to format reacord to support the
    generation of W-2c magnetic tape for US legilsative requirements.

  Notes
    Refers By:  Package  pay_us_w2c_in_mmref2_format

  History
  10-JAN-07  sausingh    115.11 5358272 added parameter_record(24) and parameter_record(25)
                                        for RCT and RCW records for bug number 5358272
  06-JAN-04  rsethupa    115.11 4097321 To display the RCO record in a03 and a02,
                                        the global variable
					pay_us_w2c_in_mmref2_format.rco_csv_record
					is assigned values - return_value_csv and
					return_value_mf depending on whether RCO has
					errored out or it is correct.

  15-NOV-04  meshah      115.10 4005679 changed for RCO record also.
  15-NOV-04  meshah      115.9  4005679 now checking for
                                        l_exclude_from_output_chk flag before
                                        creating the csv record. if the mf is
                                        fine then we use the exact copy of
                                        mf to be displayed for a03 however
                                        where there is an error in mf we use
                                        a different plsql table to display the
                                        values in the a02 file.
  09-NOV-04  meshah      115.7  3996391 changed format_W2C_RCT_record
                                        function. changed the p_parameter_name
                                        for 15 and 16. Also changed the
                                        format sequence.
  26-Oct-04  meshah      115.8  3650105       added parameter 21 in
                                              format_W2C_RCT_record
                                              and format_W2C_RCW_record for
                                              ER health savings account.
  07-JAN-03  ppanda      115.7  3358901       negative balance on RCW and RCO record were
                                              not errorning. When negative balance found on
                                              RCW or RCO record employee is moved to a02
  26-DEC-03  ppanda      115.5  3315951       RCO record was not having prefixed comma
                                              which was causing RCO columns moved by one column left
                                              and disallign all the fields in a02 and a03
  10-DEC-03  ppanda      115.4  3311278       RCW and RCO formating changed
  08-DEC-03  ppanda      115.3  3298890       On the A03 file, the columns (Orig) First Name,
                                              (Orig) Middle Name, and (Orig) Last Name are being
                                              populated even though no name change was made.
  03-DEC-03  ppanda      115.2  3292976       RCA record format changed for position 166-171
  14-OCT-03  ppanda      115.0                Created

*/
/******************************************************************
 ** Package Local Variables
 ******************************************************************/
 gv_package varchar2(50) := 'pay_us_mmrf2_w2c_format_record';

--
--
-- Formatting RCA record for W2c reporting in MMREF-2 format
--
/*--------------------- Parameter mapping Starts. ----------------------
  Record Identifier,                                   -->   p_input_1
  Submitter''s Employer Identification Number (EIN),   -->   p_input_2
  Personal Identification Number (PIN)                 -->   p_input_3,
  Software Code                                        -->   p_input_4,
  Company Name                                         -->   p_input_5,
  Location Address                                     -->   p_input_6,
  Delivery Address                                     -->   p_input_7,
  City                                                 -->   p_input_8 ,
  State Abbreviation                                   -->   p_input_9 ,
  Zip Code                                             -->   p_input_10,
  Zip Code Extension                                   -->   p_input_11,
  Foreign State / Province                             -->   p_input_12,
  Foreign Postal Code                                  -->   p_input_13,
  Country Code                                         -->   p_input_14,
  Contact Name                                         -->   p_input_15,
  Contact Phone Number                                 -->   p_input_16
  Contact Phone Extension                              -->   p_input_17,
  Contact E-Mail                                       -->   p_input_18,
  Contact FAX                                          -->   p_input_19,
  Preferred Method Of Problem Notification Code        -->   p_input_20,
  Preparer Code                                        -->   p_input_21,
  Resub inidicator                                     -->   p_input_22
  resub WFID                                           -->   p_input_23

  ------------------------ Parameter mapping Ends. -------------------------
*/

FUNCTION format_W2C_RCA_record(
                   p_effective_date       IN  varchar2,
                   p_report_type          IN  varchar2,
                   p_format               IN  varchar2,
                   p_report_qualifier     IN  varchar2,
                   p_record_name          IN  varchar2,
                   p_input_1              IN  varchar2,
                   p_input_2              IN  varchar2,
                   p_input_3              IN  varchar2,
                   p_input_4              IN  varchar2,
                   p_input_5              IN  varchar2,
                   p_input_6              IN  varchar2,
                   p_input_7              IN  varchar2,
                   p_input_8              IN  varchar2,
                   p_input_9              IN  varchar2,
                   p_input_10             IN  varchar2,
                   p_input_11             IN  varchar2,
                   p_input_12             IN  varchar2,
                   p_input_13             IN  varchar2,
                   p_input_14             IN  varchar2,
                   p_input_15             IN  varchar2,
                   p_input_16             IN  varchar2,
                   p_input_17             IN  varchar2,
                   p_input_18             IN  varchar2,
                   p_input_19             IN  varchar2,
                   p_input_20             IN  varchar2,
                   p_input_21             IN  varchar2,
                   p_input_22             IN  varchar2,
                   p_input_23             IN  varchar2,
                   p_input_24             IN  varchar2,
                   p_input_25             IN  varchar2,
                   p_input_26             IN  varchar2,
                   p_input_27             IN  varchar2,
                   p_input_28             IN  varchar2,
                   p_input_29             IN  varchar2,
                   p_input_30             IN  varchar2,
                   p_input_31             IN  varchar2,
                   p_input_32             IN  varchar2,
                   p_input_33             IN  varchar2,
                   p_input_34             IN  varchar2,
                   p_input_35             IN  varchar2,
                   p_input_36             IN  varchar2,
                   p_input_37             IN  varchar2,
                   p_input_38             IN  varchar2,
                   p_input_39             IN  varchar2,
                   p_input_40             IN  varchar2,
                   p_validate             IN  varchar2,
                   p_exclude_from_output  OUT nocopy varchar2,
                   sp_out_1               OUT nocopy varchar2,
                   sp_out_2               OUT nocopy varchar2,
                   sp_out_3               OUT nocopy varchar2,
                   sp_out_4               OUT nocopy varchar2,
                   sp_out_5               OUT nocopy varchar2,
                   ret_str_len            OUT nocopy number,
                   p_error                OUT nocopy boolean
                 ) RETURN VARCHAR2
IS
l_agent_indicator          varchar2(1);
l_emp_ein                  varchar2(100);
l_agent_ein                varchar2(100);
l_other_ein                varchar2(100);
l_term_indicator           varchar2(1);
l_exclude_from_output_chk  boolean;
l_input_8                  varchar2(50);
l_bus_tax_acct_number      varchar2(50);
l_rep_qtr                  varchar2(300);
l_rep_prd                  varchar2(300);
l_end_of_rec               varchar2(20);
return_value               varchar2(32767);
l_pin                      varchar2(50);
l_pblm_code                varchar2(1);
l_preparer_code            varchar2(1);
p_end_of_rec               varchar2(20) :=
                           fnd_global.local_chr(13)||fnd_global.local_chr(10);
r_input_1                  varchar2(300);
r_input_2                  varchar2(300);
r_input_3                  varchar2(300);
r_input_4                  varchar2(300);
r_input_5                  varchar2(300);
r_input_6                  varchar2(300);
r_input_7                  varchar2(300);
r_input_8                  varchar2(300);
r_input_9                  varchar2(300);
r_input_10                 varchar2(300);
r_input_11                 varchar2(300);
r_input_12                 varchar2(300);
r_input_13                 varchar2(300);
r_input_14                 varchar2(300);
r_input_15                 varchar2(300);
r_input_16                 varchar2(300);
r_input_17                 varchar2(300);
r_input_18                 varchar2(300);
r_input_19                 varchar2(300);
r_input_20                 varchar2(300);
r_input_21                 varchar2(300);
r_input_22                 varchar2(300);
r_input_23                 varchar2(300);
r_input_24                 varchar2(300);
r_input_25                 varchar2(300);
r_input_26                 varchar2(300);
r_input_27                 varchar2(300);
r_input_28                 varchar2(300);
r_input_29                 varchar2(300);
r_input_30                 varchar2(300);
r_input_31                 varchar2(300);
r_input_32                 varchar2(300);
r_input_33                 varchar2(300);
r_input_34                 varchar2(300);
r_input_35                 varchar2(300);
r_input_36                 varchar2(300);
r_input_37                 varchar2(300);
r_input_38                 varchar2(300);
r_input_39                 varchar2(300);

BEGIN
  hr_utility.set_location(gv_package || '.format_W2C_RCA_record', 10);
  hr_utility.trace('RCA Record Formatting started for W-2c');
  hr_utility.trace(' Format_W2_RA_Record Begin for Company '|| p_input_5);
-- Initializing local variables with parameter value
--{
   r_input_2 := p_input_2;
   r_input_3 := p_input_3;
   r_input_4 := p_input_4;
   r_input_5 := p_input_5;
   r_input_6 := p_input_6;
   r_input_7 := p_input_7;
   r_input_8 := p_input_8;
   r_input_9 := p_input_9;
   r_input_10 := p_input_10;
   r_input_11 := p_input_11;
   r_input_12 := p_input_12;
   r_input_13 := p_input_13;
   r_input_14 := p_input_14;
   r_input_15 := p_input_15;
   r_input_16 := p_input_16;
   r_input_17 := p_input_17;
   r_input_18 := p_input_18;
   r_input_19 := p_input_19;
   r_input_20 := p_input_20;
   r_input_21 := p_input_21;
   r_input_22 := p_input_22;
   r_input_23 := p_input_23;
   r_input_24 := p_input_24;
   r_input_25 := p_input_25;
   r_input_26 := p_input_26;
   r_input_27 := p_input_27;
   r_input_28 := p_input_28;
   r_input_29 := p_input_29;
   r_input_30 := p_input_30;
   r_input_31 := p_input_31;
   r_input_32 := p_input_32;
   r_input_33 := p_input_33;
   r_input_34 := p_input_34;
   r_input_35 := p_input_35;
   r_input_36 := p_input_36;
   r_input_37 := p_input_37;
   r_input_38 := p_input_38;
   r_input_39 := p_input_39;
--}
-- Validation Starts
   IF p_input_40 = 'FLAT' THEN
-- EIN Validation and format
      hr_utility.set_location(gv_package || '.format_W2C_RCA_record', 20);
      l_emp_ein :=
          pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                     p_report_type,
                                                     p_format,
                                                     p_report_qualifier,
                                                     p_record_name,
                                                     'EIN',
                                                     p_input_2,
                                                     'Submitters EIN',
                                                     p_input_17,
                                                     null,
                                                     p_validate,
                                                     p_exclude_from_output,
                                                     sp_out_1,
                                                     sp_out_2);

      IF p_exclude_from_output = 'Y' THEN
         l_exclude_from_output_chk := TRUE;
      END IF;
      l_emp_ein := rpad(substr(l_emp_ein,1,9),9);
      hr_utility.trace('After Validation formatted EIN '||l_emp_ein);
-- EIN Validation Ends
--
      hr_utility.set_location(gv_package || '.format_W2C_RCA_record', 30);

-- Formatiing Starts

      -- Formating PIN which is of 17 char long

      l_pin := rpad(substr(nvl(p_input_3,' '),1,17),17);
      hr_utility.trace('Formatted PIN = '||l_pin);

      /* Checking for preferred method of problem notification code which is
         1=email, 2=USPS  */
      IF ((p_input_20 = '1' ) OR
          (p_input_20 = '2' )  )  THEN
         hr_utility.trace('Preferred method of code is correct. it is '||p_input_20);
         l_pblm_code:= lpad(p_input_20,1);
      ELSE
         hr_utility.trace('Preferred method of code is incorrect. it is '||p_input_20);
         l_pblm_code:= lpad(' ',1);
      END IF;

      If( (p_input_21 = 'A' )OR
          (p_input_21 = 'S' )OR
          (p_input_21 = 'L' )OR
          (p_input_21 = 'P' )OR
          (p_input_21 = 'O' ))   THEN
        l_preparer_code:= lpad(p_input_21,1);
        hr_utility.trace('l_preparer_code  is correct. it is '||p_input_21);
      ELSE
        l_preparer_code:= lpad(' ',1);
        hr_utility.trace('l_preparer_code  is incorrect. it is '||p_input_21);
      END IF;

-- Formatiing Ends
--
      hr_utility.set_location(gv_package || '.format_W2C_RCA_record', 40);

-- RA Record of Flat Type
--
      return_value:='RCA'
                    ||l_emp_ein
                    ||l_pin
                    ||rpad(substr(nvl(r_input_4,' '),1,2),2)
                    ||rpad(substr(nvl(r_input_5,' '),1,57),57)
                    ||rpad(substr(nvl(r_input_6,' '),1,22),22)
                    ||rpad(substr(nvl(r_input_7,' '),1,22),22)
                    ||rpad(substr(nvl(r_input_8,' '),1,22),22)
                    ||rpad(substr(nvl(r_input_9,' '),1,2),2)
                    ||rpad(substr(nvl(r_input_10,' '),1,5),5)
                    ||rpad(substr(nvl(r_input_11,' '),1,4),10)
                    ||rpad(substr(nvl(r_input_12,' '),1,23),23)
                    ||rpad(substr(nvl(r_input_13,' '),1,15),15)
                    ||rpad(substr(nvl(r_input_14,' '),1,2),2)
                    ||rpad(substr(nvl(r_input_15,' '),1,27),27)
                    ||rpad(substr(nvl(r_input_16,' '),1,15),15)
                    ||rpad(substr(nvl(r_input_17,' '),1,5),8)
                    ||rpad(substr(nvl(r_input_18,' '),1,43),43)
                    ||rpad(substr(nvl(r_input_19,' '),1,10),10)
                    ||l_pblm_code
                    ||l_preparer_code
                    ||rpad(substr(nvl(r_input_22,'0'),1,1),1)
                    ||rpad(substr(nvl(r_input_23,' '),1,6),6)
                    ||lpad(' ',701);
      -- These Variables are initialized to derive the file total
        pay_us_w2c_in_mmref2_format.number_of_valid_rcw_rcf  := 0;
        pay_us_w2c_in_mmref2_format.number_of_valid_rco_rcf  := 0;
        pay_us_w2c_in_mmref2_format.number_of_error_rcw_rcf  := 0;
        pay_us_w2c_in_mmref2_format.number_of_error_rco_rcf  := 0;

--
      hr_utility.set_location(gv_package || '.format_W2C_RCA_record', 50);
         hr_utility.trace('RCA Record of FLAT Type  -----');
         ret_str_len:=length(return_value);
   END IF;
   p_error := l_exclude_from_output_chk;
   ret_str_len:=length(return_value);
   return return_value;
END format_W2C_RCA_record; -- End of formatting W2c RCA Record

--
-- Formatting RCE Record for W2c reporting in MMREF-2 format
--
FUNCTION format_W2C_RCE_record(
                   p_effective_date       IN  varchar2,
                   p_report_type          IN  varchar2,
                   p_format               IN  varchar2,
                   p_report_qualifier     IN  varchar2,
                   p_record_name          IN  varchar2,
                   p_input_1              IN  varchar2,
                   p_input_2              IN  varchar2,
                   p_input_3              IN  varchar2,
                   p_input_4              IN  varchar2,
                   p_input_5              IN  varchar2,
                   p_input_6              IN  varchar2,
                   p_input_7              IN  varchar2,
                   p_input_8              IN  varchar2,
                   p_input_9              IN  varchar2,
                   p_input_10             IN  varchar2,
                   p_input_11             IN  varchar2,
                   p_input_12             IN  varchar2,
                   p_input_13             IN  varchar2,
                   p_input_14             IN  varchar2,
                   p_input_15             IN  varchar2,
                   p_input_16             IN  varchar2,
                   p_input_17             IN  varchar2,
                   p_input_18             IN  varchar2,
                   p_input_19             IN  varchar2,
                   p_input_20             IN  varchar2,
                   p_input_21             IN  varchar2,
                   p_input_22             IN  varchar2,
                   p_input_23             IN  varchar2,
                   p_input_24             IN  varchar2,
                   p_input_25             IN  varchar2,
                   p_input_26             IN  varchar2,
                   p_input_27             IN  varchar2,
                   p_input_28             IN  varchar2,
                   p_input_29             IN  varchar2,
                   p_input_30             IN  varchar2,
                   p_input_31             IN  varchar2,
                   p_input_32             IN  varchar2,
                   p_input_33             IN  varchar2,
                   p_input_34             IN  varchar2,
                   p_input_35             IN  varchar2,
                   p_input_36             IN  varchar2,
                   p_input_37             IN  varchar2,
                   p_input_38             IN  varchar2,
                   p_input_39             IN  varchar2,
                   p_input_40             IN  varchar2,
                   p_validate             IN  varchar2,
                   p_exclude_from_output  OUT nocopy varchar2,
                   sp_out_1               OUT nocopy varchar2,
                   sp_out_2               OUT nocopy varchar2,
                   sp_out_3               OUT nocopy varchar2,
                   sp_out_4               OUT nocopy varchar2,
                   sp_out_5               OUT nocopy varchar2,
                   ret_str_len            OUT nocopy number,
                   p_error                OUT nocopy boolean
                 ) RETURN VARCHAR2
IS
   /* Record Identifier                                     --> p_input_1,
      Tax Year                                              --> p_input_2,
      Employer / Agent Employer Identification Number (EIN) --> p_input_3,
   */

l_agent_indicator          varchar2(1);
l_emp_ein                  varchar2(100);
l_agent_ein                varchar2(100);
l_other_ein                varchar2(100);
l_term_indicator           varchar2(1);
l_exclude_from_output_chk  boolean;
l_input_8                  varchar2(50);
l_bus_tax_acct_number      varchar2(50);
l_rep_qtr                  varchar2(300);
l_rep_prd                  varchar2(300);
l_end_of_rec               varchar2(20);
return_value               varchar2(32767);

r_input_1                  varchar2(300);
r_input_2                  varchar2(300);
r_input_3                  varchar2(300);
r_input_4                  varchar2(300);
r_input_5                  varchar2(300);
r_input_6                  varchar2(300);
r_input_7                  varchar2(300);
r_input_8                  varchar2(300);
r_input_9                  varchar2(300);
r_input_10                 varchar2(300);
r_input_11                 varchar2(300);
r_input_12                 varchar2(300);
r_input_13                 varchar2(300);
r_input_14                 varchar2(300);
r_input_15                 varchar2(300);
r_input_16                 varchar2(300);
r_input_17                 varchar2(300);
r_input_18                 varchar2(300);
r_input_19                 varchar2(300);
r_input_20                 varchar2(300);
r_input_21                 varchar2(300);
r_input_22                 varchar2(300);
r_input_23                 varchar2(300);
r_input_24                 varchar2(300);
r_input_25                 varchar2(300);
r_input_26                 varchar2(300);
r_input_27                 varchar2(300);
r_input_28                 varchar2(300);
r_input_29                 varchar2(300);
r_input_30                 varchar2(300);
r_input_31                 varchar2(300);
r_input_32                 varchar2(300);
r_input_33                 varchar2(300);
r_input_34                 varchar2(300);
r_input_35                 varchar2(300);
r_input_36                 varchar2(300);
r_input_37                 varchar2(300);
r_input_38                 varchar2(300);
r_input_39                 varchar2(300);

BEGIN
   hr_utility.set_location(gv_package || '.format_W2C_RCE_record', 10);
   hr_utility.trace('RCE Record Formatting started ');
   hr_utility.trace('Format Record Type '|| p_input_40);
-- Initializing local variables with parameter value
--{
   r_input_2 := p_input_2;
   r_input_3 := p_input_3;
   r_input_4 := p_input_4;
   r_input_5 := p_input_5;
   r_input_6 := p_input_6;
   r_input_7 := p_input_7;
   r_input_8 := p_input_8;
   r_input_9 := p_input_9;
   r_input_10 := p_input_10;
   r_input_11 := p_input_11;
   r_input_12 := p_input_12;
   r_input_13 := p_input_13;
   r_input_14 := p_input_14;
   r_input_15 := p_input_15;
   r_input_16 := p_input_16;
   r_input_17 := p_input_17;
   r_input_18 := p_input_18;
   r_input_19 := p_input_19;
   r_input_20 := p_input_20;
   r_input_21 := p_input_21;
   r_input_22 := p_input_22;
   r_input_23 := p_input_23;
   r_input_24 := p_input_24;
   r_input_25 := p_input_25;
   r_input_26 := p_input_26;
   r_input_27 := p_input_27;
   r_input_28 := p_input_28;
   r_input_29 := p_input_29;
   r_input_30 := p_input_30;
   r_input_31 := p_input_31;
   r_input_32 := p_input_32;
   r_input_33 := p_input_33;
   r_input_34 := p_input_34;
   r_input_35 := p_input_35;
   r_input_36 := p_input_36;
   r_input_37 := p_input_37;
   r_input_38 := p_input_38;
   r_input_39 := p_input_39;
--}
   hr_utility.set_location(gv_package || '.format_W2C_RCE_record', 20);

--    Validation for RCE Record starts
--    These validation are used only for mf file only.
--    not for any of the audit report
--
      IF p_input_40 = 'FLAT' THEN
--{
         hr_utility.set_location(gv_package || '.format_W2C_RCE_record', 30);
         hr_utility.trace('before data_validation of EIN is '||p_input_3);
         l_emp_ein :=
             pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                        p_report_type,
                                                        p_format,
                                                        p_report_qualifier,
                                                        p_record_name,
                                                        'EIN',
                                                        p_input_3,
                                                        'Employer EIN',
                                                        p_input_9,
                                                        null,
                                                        p_validate,
                                                        p_exclude_from_output,
                                                        sp_out_1,
                                                        sp_out_2);
         IF p_exclude_from_output = 'Y' THEN
            l_exclude_from_output_chk := TRUE;
         END IF;
         hr_utility.trace('after data_validation of EIN value is '||l_emp_ein);
         hr_utility.trace('Exclude from output '||p_exclude_from_output);
         return_value :=  'RCE'
                          ||rpad(substr(nvl(r_input_2,' '),1,4),13)
                          ||l_emp_ein
                          ||lpad(' ',197)
                          ||lpad(NVL(r_input_19,'R'),1)
                          ||lpad(' ',801);
--}
      END IF;
   p_error := l_exclude_from_output_chk;
   ret_str_len:=length(return_value);
   return return_value;
end format_W2C_RCE_record;
-- End of Formatting RCE record for W-2c reporting
--


--
-- This function is used for formatting RCF Record in MMREF-2 format
--
/*
  Effective Date                               --> p_effective_date
  Report Type  (i.e.W2 )                       --> p_report_type
  Report Format                                --> p_format
  Report Qualifier                             --> p_report_qualifier
  Record Name (i.e. RF)                        --> p_record_name
  Record Identifier                            --> p_record_identifier
  Number of RW Records                         --> p_total_no_of_record
  Wages, Tips and other Compensation           --> p_total_wages
  Federal Income Tax Withheld                  --> p_total_taxes
  Report Format Mode (FLAT, CSV)               --> p_format_mode
  Validation Flag                              --> p_validate
  Exclude Record from mag file                 --> p_exclude_from_output
  Return Record Length                         --> ret_str_len
  Validation Error Flag                        --> p_error
*/
FUNCTION format_W2C_RCF_record(
                   p_effective_date       IN  varchar2,
                   p_report_type          IN  varchar2,
                   p_format               IN  varchar2,
                   p_report_qualifier     IN  varchar2,
                   p_record_name          IN  varchar2,
                   p_record_identifier    IN  varchar2,
                   p_total_no_of_record   IN  varchar2,
                   p_total_wages          IN  varchar2,
                   p_total_taxes          IN  varchar2,
                   p_format_mode          IN  varchar2,
                   p_validate             IN  varchar2,
                   p_exclude_from_output  OUT nocopy varchar2,
                   ret_str_len            OUT nocopy number,
                   p_error                OUT nocopy boolean
                 ) RETURN VARCHAR2
IS
return_value               varchar2(32767);
l_exclude_from_output_chk  boolean := FALSE;
l_total_rcw_records        varchar2(50);
l_wages                    varchar2(100);
l_taxes                    varchar2(100);
sp_out_1                   varchar2(100);
sp_out_2                   varchar2(100);
BEGIN
   hr_utility.trace('Formatting RCF Record');
   l_total_rcw_records := lpad(nvl(p_total_no_of_record,'0'),9,0);
   return_value := 'RCF'
                   ||l_total_rcw_records
                   ||lpad(' ',1012);
   p_error := l_exclude_from_output_chk;
   ret_str_len:=length(return_value);
   return return_value;
END format_W2C_RCF_record; -- End of Formatting RF Record for W2 Reporting

--
-- This function is used for formatting RCT Record in MMREF-2 format
--
/*
  Effective Date                               --> p_effective_date
  Report Type  (i.e.W2C )                      --> p_report_type
  Report Format                                --> p_format
  Report Qualifier                             --> p_report_qualifier
  Record Name (i.e. RCT)                       --> p_record_name
  Record Identifier                            --> p_record_identifier
  Number of RW Records                         --> p_total_no_of_record
  Wages, Tips and other Compensation           --> p_total_wages
  Federal Income Tax Withheld                  --> p_total_taxes
  Report Format Mode (FLAT, CSV)               --> p_format_mode
  Validation Flag                              --> p_validate
  Exclude Record from mag file                 --> p_exclude_from_output
  Return Record Length                         --> ret_str_len
  Validation Error Flag                        --> p_error
*/
FUNCTION format_W2C_RCT_record(
                   p_effective_date       IN  varchar2,
                   p_report_type          IN  varchar2,
                   p_format               IN  varchar2,
                   p_report_qualifier     IN  varchar2,
                   p_record_name          IN  varchar2,
                   p_record_identifier    IN  varchar2,
                   p_total_no_of_record   IN  varchar2,
                   p_total_wages          IN  varchar2,
                   p_total_taxes          IN  varchar2,
                   p_format_mode          IN  varchar2,
                   p_validate             IN  varchar2,
                   p_exclude_from_output  OUT nocopy varchar2,
                   ret_str_len            OUT nocopy number,
                   p_error                OUT nocopy boolean
                 ) RETURN VARCHAR2
IS
return_value               varchar2(32767);
l_exclude_from_output_chk  boolean := FALSE;
l_total_rcw_records        varchar2(50);
l_wages                    varchar2(100);
l_taxes                    varchar2(100);
sp_out_1                   varchar2(100);
sp_out_2                   varchar2(100);
TYPE function_columns IS RECORD(
                                p_parameter_name  varchar2(100)
                               );
function_parameter_rec  function_columns;
TYPE input_parameter_record IS TABLE OF function_parameter_rec%TYPE
                               INDEX BY BINARY_INTEGER;
parameter_record input_parameter_record;
ln_no_of_rcw_wages                 number := 20;
lv_no_of_rcw_records               varchar2(10) := ' ';

BEGIN
   hr_utility.set_location(gv_package || '.format_W2C_RCT_record', 10);
   hr_utility.trace('Formatting RCT Record');

          parameter_record.delete;
          parameter_record(1).p_parameter_name := 'Wages,Tips And Other Compensation';
          parameter_record(2).p_parameter_name := 'Federal Income Tax Withheld';
          parameter_record(3).p_parameter_name := 'Social Security Wages';
          parameter_record(4).p_parameter_name := 'Social Security Tax Withheld';
          parameter_record(5).p_parameter_name := 'Medicare Wages And Tips';
          parameter_record(6).p_parameter_name := 'Medicare Tax Withheld';
          parameter_record(7).p_parameter_name := 'Social Security Tips';
          parameter_record(8).p_parameter_name := 'Advance Earned Income Credit';
          parameter_record(9).p_parameter_name := 'Dependent Care Benefits';
          parameter_record(10).p_parameter_name:= 'Deferred Comp Contr. to Sec 401(k)';
          parameter_record(11).p_parameter_name:= 'Deferred Comp Contr. to Sec 403(b)';
          parameter_record(12).p_parameter_name:= 'Deferred Comp Contr. to Sec 408(k)(6)';
          parameter_record(13).p_parameter_name:= 'Deferred Comp Contr. to Sec 457(b)';
          parameter_record(14).p_parameter_name:= 'Deferred Comp Contr. to Sec 501(c)';
          parameter_record(15).p_parameter_name:= 'Deferred Compensation Contribution';
          parameter_record(16).p_parameter_name:= 'Military Combat Pay';
          parameter_record(17).p_parameter_name:= 'Non-Qual. plan Sec 457';
          parameter_record(18).p_parameter_name:= 'Non-Qual. plan NOT Sec 457';
          parameter_record(19).p_parameter_name:= 'Employer cost of premiun';
          parameter_record(20).p_parameter_name:= 'Income from nonqualified stock option';
          parameter_record(21).p_parameter_name:= 'ER Contribution to HSA';
          parameter_record(22).p_parameter_name:= 'Nontaxable Combat Pay';
          parameter_record(23).p_parameter_name:= 'Nonqual 409A Deferral Amount';
          parameter_record(24).p_parameter_name:= 'Designated Roth Contr. to 401k Plan'; /* 5358272 */
          parameter_record(25).p_parameter_name:= 'Designated Roth Contr. to 403b Plan'; /* 5358272 */




          hr_utility.set_location(gv_package || '.format_W2C_RCT_record', 20);
          ln_no_of_rcw_wages := 25;  /* 5358272 */

          FOR i IN 1..ln_no_of_rcw_wages
          LOOP
             hr_utility.trace(parameter_record(i).p_parameter_name||' OLD-> '
                || pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old_formated
                || ' NEW->  '|| pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new_formated);
          END LOOP;

          hr_utility.set_location(gv_package || '.format_W2C_RCT_record', 30);

          lv_no_of_rcw_records := lpad(pay_us_w2c_in_mmref2_format.number_of_valid_rcw_rct,7,0);
          return_value := 'RCT'
                          ||lv_no_of_rcw_records
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(1).rct_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(1).rct_wage_new_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(2).rct_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(2).rct_wage_new_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(3).rct_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(3).rct_wage_new_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(4).rct_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(4).rct_wage_new_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(5).rct_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(5).rct_wage_new_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(6).rct_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(6).rct_wage_new_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(7).rct_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(7).rct_wage_new_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(8).rct_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(8).rct_wage_new_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(9).rct_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(9).rct_wage_new_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(10).rct_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(10).rct_wage_new_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(11).rct_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(11).rct_wage_new_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(12).rct_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(12).rct_wage_new_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(13).rct_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(13).rct_wage_new_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(14).rct_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(14).rct_wage_new_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(15).rct_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(15).rct_wage_new_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(16).rct_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(16).rct_wage_new_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(17).rct_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(17).rct_wage_new_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(21).rct_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(21).rct_wage_new_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(18).rct_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(18).rct_wage_new_formated
                          --||lpad(' ',60)
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(22).rct_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(22).rct_wage_new_formated
                          ||lpad(' ',30)
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(19).rct_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(19).rct_wage_new_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(20).rct_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(20).rct_wage_new_formated
                          --||lpad(' ',324)
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(23).rct_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(23).rct_wage_new_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(24).rct_wage_old_formated  /* 5358272 */
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(24).rct_wage_new_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(25).rct_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rct_info(25).rct_wage_new_formated
                          ||lpad(' ',234);

   hr_utility.set_location(gv_package || '.format_W2C_RCT_record', 40);
   p_error := l_exclude_from_output_chk;
   ret_str_len:=length(return_value);
   return return_value;
END format_W2C_RCT_record; -- End of Formatting RCT Record for W-2c Reporting


--
-- This function is used for formatting RCU Record in MMREF-2 format
--
/*
  Effective Date                               --> p_effective_date
  Report Type  (i.e.W2C )                      --> p_report_type
  Report Format                                --> p_format
  Report Qualifier                             --> p_report_qualifier
  Record Name (i.e. RCU)                       --> p_record_name
  Record Identifier                            --> p_record_identifier
  Number of RW Records                         --> p_total_no_of_record
  Wages, Tips and other Compensation           --> p_total_wages
  Federal Income Tax Withheld                  --> p_total_taxes
  Report Format Mode (FLAT, CSV)               --> p_format_mode
  Validation Flag                              --> p_validate
  Exclude Record from mag file                 --> p_exclude_from_output
  Return Record Length                         --> ret_str_len
  Validation Error Flag                        --> p_error
*/
FUNCTION format_W2C_RCU_record(
                   p_effective_date       IN  varchar2,
                   p_report_type          IN  varchar2,
                   p_format               IN  varchar2,
                   p_report_qualifier     IN  varchar2,
                   p_record_name          IN  varchar2,
                   p_record_identifier    IN  varchar2,
                   p_total_no_of_record   IN  varchar2,
                   p_total_wages          IN  varchar2,
                   p_total_taxes          IN  varchar2,
                   p_format_mode          IN  varchar2,
                   p_validate             IN  varchar2,
                   p_exclude_from_output  OUT nocopy varchar2,
                   ret_str_len            OUT nocopy number,
                   p_error                OUT nocopy boolean
                 ) RETURN VARCHAR2
IS
return_value               varchar2(32767);
l_exclude_from_output_chk  boolean := FALSE;
l_total_rcu_records        varchar2(50);
l_wages                    varchar2(100);
l_taxes                    varchar2(100);
sp_out_1                   varchar2(100);
sp_out_2                   varchar2(100);
TYPE function_columns IS RECORD(
                                p_parameter_name  varchar2(100)
                               );
function_parameter_rec  function_columns;
TYPE input_parameter_record IS TABLE OF function_parameter_rec%TYPE
                               INDEX BY BINARY_INTEGER;
parameter_record input_parameter_record;
ln_no_of_rco_wages                 number := 8;
lv_no_of_rco_records               varchar2(10) := ' ';

BEGIN
          hr_utility.set_location(gv_package || '.format_W2C_RCU_record', 10);
          hr_utility.trace('Formatting RCU Record');
          parameter_record.delete;
          parameter_record(1).p_parameter_name:= ' Allocated Tips';
          parameter_record(2).p_parameter_name:= 'Uncollected employee tax on tips';
          parameter_record(3).p_parameter_name:= 'medical savings a/c';
          parameter_record(4).p_parameter_name:= 'simple retirement a/c';
          parameter_record(5).p_parameter_name:= 'qualified adoption expenses';
          parameter_record(6).p_parameter_name:= 'Uncollected SS tax';
          parameter_record(7).p_parameter_name:= 'Uncollected medicare tax';
          parameter_record(8).p_parameter_name:= 'Income under 409A';

          hr_utility.set_location(gv_package || '.format_W2C_RCU_record', 20);
          ln_no_of_rco_wages := 8;
          FOR i IN 1..ln_no_of_rco_wages
          LOOP
             hr_utility.trace(parameter_record(i).p_parameter_name||' OLD-> '
                || pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_old_formated
                || ' NEW->  '|| pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_new_formated);
          END LOOP;
          hr_utility.set_location(gv_package || '.format_W2C_RCU_record', 30);
          lv_no_of_rco_records := lpad(pay_us_w2c_in_mmref2_format.number_of_valid_rco_rcu,7,0);
          return_value := 'RCU'
                          ||lv_no_of_rco_records
                          ||pay_us_w2c_in_mmref2_format.ltr_rcu_info(1).rcu_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rcu_info(1).rcu_wage_new_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rcu_info(2).rcu_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rcu_info(2).rcu_wage_new_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rcu_info(3).rcu_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rcu_info(3).rcu_wage_new_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rcu_info(4).rcu_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rcu_info(4).rcu_wage_new_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rcu_info(5).rcu_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rcu_info(5).rcu_wage_new_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rcu_info(6).rcu_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rcu_info(6).rcu_wage_new_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rcu_info(7).rcu_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rcu_info(7).rcu_wage_new_formated
                          --||lpad(' ',804);
                          ||pay_us_w2c_in_mmref2_format.ltr_rcu_info(8).rcu_wage_old_formated
                          ||pay_us_w2c_in_mmref2_format.ltr_rcu_info(8).rcu_wage_new_formated
                          ||lpad(' ',774);

   hr_utility.set_location(gv_package || '.format_W2C_RCU_record', 40);
   p_error := l_exclude_from_output_chk;
   ret_str_len:=length(return_value);
   return return_value;
END format_W2C_RCU_record; -- End of Formatting RCU Record for W-2c Reporting
--
-- This function is used for formatting RCU Record in MMREF-2 format
--
FUNCTION format_W2C_RCW_record (  p_effective_date               IN varchar2,
                                  p_report_type                  IN varchar2,
                                  p_format                       IN varchar2,
                                  p_report_qualifier             IN varchar2,
                                  p_record_name                  IN varchar2,
                                  p_tax_unit_id                  IN varchar2,
                                  p_record_identifier            IN varchar2,
                                  p_ssn_old                      IN varchar2,
                                  p_ssn_new                      IN varchar2,
                                  p_first_name_old               IN varchar2,
                                  p_middle_name_old              IN varchar2,
                                  p_last_name_old                IN varchar2,
                                  p_first_name_old_raw           IN varchar2,
                                  p_middle_name_old_raw          IN varchar2,
                                  p_last_name_old_raw            IN varchar2,
                                  p_first_name_new               IN varchar2,
                                  p_middle_name_new              IN varchar2,
                                  p_last_name_new                IN varchar2,
                                  p_location_address             IN varchar2,
                                  p_delivery_address             IN varchar2,
                                  p_city                         IN varchar2,
                                  p_state                        IN varchar2,
                                  p_zip                          IN varchar2,
                                  p_zip_extension                IN varchar2,
                                  p_foreign_state                IN varchar2,
                                  p_foreign_postal_code          IN varchar2,
                                  p_country_code                 IN varchar2,
                                  p_statutory_emp_indicator_old  IN varchar2,
                                  p_statutory_emp_indicator_new  IN varchar2,
                                  p_retire_plan_indicator_old    IN varchar2,
                                  p_retire_plan_indicator_new    IN varchar2,
                                  p_sickpay_indicator_old        IN varchar2,
                                  p_sickpay_indicator_new        IN varchar2,
                                  p_orig_assignment_actid        IN varchar2,
                                  p_correct_assignment_actid     IN varchar2,
                                  p_employee_number              IN varchar2,
                                  rcw_wage_rec                   IN OUT nocopy pay_us_w2c_in_mmref2_format.table_wage_record,
                                  p_format_type                  IN varchar2,
                                  p_validate                     IN varchar2,
                                  p_exclude_from_output          OUT nocopy varchar2,
                                  ret_str_len                    OUT nocopy varchar2,
                                  p_error                        OUT nocopy boolean
                               )
                               return varchar2
IS
l_emp_name_or_number       varchar2(50);
l_emp_number               varchar2(50);
l_first_name_old           varchar2(150);
l_middle_name_old          varchar2(100);
l_last_name_old            varchar2(150);
l_first_name_new           varchar2(150);
l_middle_name_new          varchar2(100);
l_last_name_new            varchar2(150);
l_full_name_old            varchar2(100);
l_full_name_new            varchar2(100);
l_suffix                   varchar2(100);
l_ssn_old                  varchar2(100);
l_ssn_new                  varchar2(100);
l_message                  varchar2(2000);
l_description              varchar2(50);
l_field_description        varchar2(50);
l_ss_count                 number(10);
l_amount                   number(10);
return_value_mf            varchar2(32767);
return_value_csv           varchar2(32767);
return_value_blank         varchar2(32767);
l_err                      boolean;
l_exclude_from_output_chk  boolean;
l_ss_tax_limit  pay_us_federal_tax_info_f.ss_ee_wage_limit%TYPE;
l_ss_wage_limit  pay_us_federal_tax_info_f.ss_ee_wage_limit%TYPE;
sp_out_1                   varchar2(100);
sp_out_2                   varchar2(100);

CURSOR GET_SS_LIMIT(c_date varchar2)
    IS
SELECT SS_EE_WAGE_LIMIT*100,
       (SS_EE_WAGE_LIMIT*SS_EE_RATE)*100 tax
FROM   PAY_US_FEDERAL_TAX_INFO_F
WHERE  TO_DATE(C_DATE,'DD-MM-YYYY') BETWEEN EFFECTIVE_START_DATE
                                        AND EFFECTIVE_END_DATE
AND    FED_INFORMATION_CATEGORY = '401K LIMITS';


TYPE function_columns IS RECORD(
                                p_parameter_name  varchar2(100)
                               );
function_parameter_rec  function_columns;
TYPE input_parameter_record IS TABLE OF function_parameter_rec%TYPE
                               INDEX BY BINARY_INTEGER;
parameter_record input_parameter_record;
BEGIN
   hr_utility.set_location(gv_package || '.format_W2C_RCW_record', 10);
   --{

         l_first_name_old := pay_us_reporting_utils_pkg.Character_check(rpad(nvl(
                                        substr(p_first_name_old,1,15),' '),15));
         l_middle_name_old := pay_us_reporting_utils_pkg.Character_check(rpad(nvl(
                                        substr(p_middle_name_old,1,15),' '),15));
         l_last_name_old :=  pay_us_reporting_utils_pkg.Character_check(rpad(nvl(
                                        substr(p_last_name_old,1,20),' '),20));
         l_full_name_old := substr(pay_us_reporting_utils_pkg.Character_check(ltrim(rtrim(p_first_name_old)||' '||
                                     rtrim(p_last_name_old))),1,50);

         l_first_name_new := pay_us_reporting_utils_pkg.Character_check(rpad(nvl(
                                        substr(p_first_name_new,1,15),' '),15));
         l_middle_name_new := pay_us_reporting_utils_pkg.Character_check(rpad(nvl(
                                        substr(p_middle_name_new,1,15),' '),15));
         l_last_name_new :=  pay_us_reporting_utils_pkg.Character_check(rpad(nvl(
                                        substr(p_last_name_new,1,20),' '),20));
         l_full_name_new := substr(pay_us_reporting_utils_pkg.Character_check(ltrim(rtrim(p_first_name_new)||' '||
                                     rtrim(p_last_name_new))),1,50);

         l_emp_number := replace(p_employee_number,' ');

         IF l_emp_number IS NULL THEN
            l_emp_name_or_number := l_full_name_new;
            hr_utility.trace('Employee Name or Number = '||l_emp_name_or_number);
         ELSE
            l_emp_name_or_number:= l_emp_number;
            hr_utility.trace('Employee Name or Number = '||l_emp_name_or_number);
         END IF;
   hr_utility.set_location(gv_package || '.format_W2C_RCW_record', 20);
--
--   Validation for RCW Record  Start
--
--   Originally reported SSN validation and formatting
         l_ssn_old := lpad(' ',9);
         IF rtrim(p_ssn_old) IS not NULL then
            l_ssn_old :=
              pay_us_reporting_utils_pkg.data_validation( p_effective_date,
                                                      p_report_type,
                                                      p_format,
                                                      p_report_qualifier,
                                                      p_record_name,
                                                      'SSN',
                                                      p_ssn_old,
                                                      'Social Security',
                                                      l_emp_name_or_number,
                                                      null,
                                                      p_validate,
                                                      p_exclude_from_output,
                                                      sp_out_1,
                                                      sp_out_2);
            IF p_exclude_from_output = 'Y' THEN
               l_exclude_from_output_chk := TRUE;
            END IF;
         END IF;
   hr_utility.set_location(gv_package || '.format_W2C_RCW_record', 30);
--   Corrected SSN validation and formatting
         l_ssn_new := lpad(' ',9);
         l_ssn_new :=
              pay_us_reporting_utils_pkg.data_validation( p_effective_date,
                                                      p_report_type,
                                                      p_format,
                                                      p_report_qualifier,
                                                      p_record_name,
                                                      'SSN',
                                                      p_ssn_new,
                                                      'Social Security',
                                                      l_emp_name_or_number,
                                                      null,
                                                      p_validate,
                                                      p_exclude_from_output,
                                                      sp_out_1,
                                                      sp_out_2);
            IF p_exclude_from_output = 'Y' THEN
               l_exclude_from_output_chk := TRUE;
            END IF;
   hr_utility.set_location(gv_package || '.format_W2C_RCW_record', 40);

         parameter_record(1).p_parameter_name := 'Wages,Tips And Other Compensation';
         parameter_record(2).p_parameter_name := 'Federal Income Tax Withheld';
         parameter_record(3).p_parameter_name := 'Social Security Wages';
         parameter_record(4).p_parameter_name := 'Social Security Tax Withheld';
         parameter_record(5).p_parameter_name := 'Medicare Wages And Tips';
         parameter_record(6).p_parameter_name := 'Medicare Tax Withheld';
         parameter_record(7).p_parameter_name := 'Social Security Tips';
         parameter_record(8).p_parameter_name := 'Advance Earned Income Credit';
         parameter_record(9).p_parameter_name := 'Dependent Care Benefits';
         parameter_record(10).p_parameter_name:= 'Deferred Comp Contr. to Sec 401(k)';
         parameter_record(11).p_parameter_name:= 'Deferred Comp Contr. to Sec 403(b)';
         parameter_record(12).p_parameter_name:= 'Deferred Comp Contr. to Sec 408(k)(6)';
         parameter_record(13).p_parameter_name:= 'Deferred Comp Contr. to Sec 457(b)';
         parameter_record(14).p_parameter_name:= 'Deferred Comp Contr. to Sec 501(c)';
         parameter_record(15).p_parameter_name:= 'Deferred Compensation Contribution ';
         parameter_record(16).p_parameter_name:= 'Military Combat Pay';
         parameter_record(17).p_parameter_name:= 'Non-Qual. plan Sec 457';
         parameter_record(18).p_parameter_name:= 'Non-Qual. plan NOT Sec 457';
         parameter_record(19).p_parameter_name:= 'Employer cost of premiun';
         parameter_record(20).p_parameter_name:= 'Income from nonqualified stock option';
         parameter_record(21).p_parameter_name:= 'ER Contribution for HSA';
         parameter_record(22).p_parameter_name:= 'Nontaxable Combat Pay';
         parameter_record(23).p_parameter_name:= 'Nonqual 409A Deferral Amount';
         parameter_record(24).p_parameter_name:= 'Designated Roth Contr. to 401k Plan'; /* 5358272 */
          parameter_record(25).p_parameter_name:= 'Designated Roth Contr. to 403b Plan'; /* 5358272 */

--    Various Amount Validation for for Neg value. If value is found negative record
--            is marked for exclusion

         FOR i in 1..25  /* 5358272 */
         LOOP
-- Negative Value validation for Originally reported wages
-- if Originally reported and coreected values are identical validation and
--    formating are  avoided with this check
--
   hr_utility.set_location(gv_package || '.format_W2C_RCW_record', 50);
           if (rcw_wage_rec(i).identical_flag = 'N') then
           --{
              if rcw_wage_rec(i).wage_old_value <> 0 then
              --{
                 rcw_wage_rec(i).wage_old_value_formated :=
                    pay_us_reporting_utils_pkg.data_validation(
                                                p_effective_date,
                                                p_report_type,
                                                p_format,
                                                p_report_qualifier,
                                                p_record_name,
                                                'NEG_CHECK',
                                                rcw_wage_rec(i).wage_old_value,
                                                parameter_record(i).p_parameter_name||'(Old)',
                                                l_emp_name_or_number, --EE number or Full name for mesg
                                                null,
                                                p_validate,
                                                p_exclude_from_output,
                                                sp_out_1,
                                                sp_out_2);

                 IF p_exclude_from_output = 'Y' THEN
                    l_exclude_from_output_chk := TRUE;
                    l_err := TRUE;
                 END IF;
                 hr_utility.trace(parameter_record(i).p_parameter_name||'Old = '||
                                       rcw_wage_rec(i).wage_old_value_formated);
                 hr_utility.trace('p_exclude_from_output = '||p_exclude_from_output);
              --}
              else
                 rcw_wage_rec(i).wage_old_value_formated := lpad('0',11,'0');
              end if;
   hr_utility.set_location(gv_package || '.format_W2C_RCW_record', 60);
-- Validation and formating of Corrected Value
--
              if rcw_wage_rec(i).wage_new_value <> 0 then
              --{
                 rcw_wage_rec(i).wage_new_value_formated :=
                    pay_us_reporting_utils_pkg.data_validation(
                                                p_effective_date,
                                                p_report_type,
                                                p_format,
                                                p_report_qualifier,
                                                p_record_name,
                                                'NEG_CHECK',
                                                rcw_wage_rec(i).wage_new_value,
                                                parameter_record(i).p_parameter_name||'(New)',
                                                l_emp_name_or_number, --EE number or Full Name for mesg
                                                null,
                                                p_validate,
                                                p_exclude_from_output,
                                                sp_out_1,
                                                sp_out_2);

                 IF p_exclude_from_output = 'Y' THEN
                    l_exclude_from_output_chk := TRUE;
                    l_err := TRUE;
                 END IF;
                 hr_utility.trace(parameter_record(i).p_parameter_name||'New = '||
                                       rcw_wage_rec(i).wage_new_value_formated);
                 hr_utility.trace('p_exclude_from_output = '||p_exclude_from_output);
              --}
              else
                 rcw_wage_rec(i).wage_new_value_formated := lpad('0',11,'0');
              end if;
           --}
           end if;
         END LOOP;
         hr_utility.set_location(gv_package || '.format_W2C_RCW_record', 70);
         hr_utility.trace('SS Wage and Tax limit Checking begins.' );
         OPEN get_ss_limit(p_effective_date);
         LOOP
            FETCH get_ss_limit INTO l_ss_wage_limit,
                                    l_ss_tax_limit;
            hr_utility.trace('SS Wage Limit '||to_char(l_ss_wage_limit));
            l_ss_count:= get_ss_limit%ROWCOUNT;
            EXIT WHEN get_ss_limit%NOTFOUND ;
         END LOOP;
         CLOSE get_ss_limit;
         hr_utility.trace('No. rows exist for limit '||to_char(l_ss_count));

         IF l_ss_count = 0 THEN
            hr_utility.trace('No data found on PAY_US_FEDERAL_TAX_INFO_F '||
                                 'for Social security wage limits.');
         ELSIF l_ss_count >1 THEN
            hr_utility.trace('Too many rows on PAY_US_FEDERAL_TAX_INFO_F '||
                                 'for Social security wage limits.');
         ELSIF l_ss_count=1 THEN
--{
         hr_utility.trace('SS Wage (Box-3     '||to_char(rcw_wage_rec(3).wage_new_value));
         hr_utility.trace('SS Tax w/h (Box-4) '||to_char(rcw_wage_rec(4).wage_new_value));
         hr_utility.trace('SS Tips (Box-7)    '||to_char(rcw_wage_rec(7).wage_new_value));

            IF (rcw_wage_rec(3).wage_new_value > 0 OR
                rcw_wage_rec(4).wage_new_value > 0 OR
                rcw_wage_rec(7).wage_new_value > 0 )
            THEN
--{
               hr_utility.trace('SS Tax w/h, SS Tips, SS Wages are >0 ');
               IF (rcw_wage_rec(3).wage_new_value+
                   rcw_wage_rec(7).wage_new_value) > l_ss_wage_limit
               THEN
                 hr_utility.trace('Sum of SS_Tips and SS_Wages is > '||
                                  to_char(l_ss_wage_limit));
                 l_field_description:='the sum of '||
                                      parameter_record(3).p_parameter_name
                                      ||' and '||
                                      parameter_record(7).p_parameter_name;
                 l_amount:=l_ss_wage_limit/100;
                 l_description:=' It is greater than  '||to_char(l_amount);
                 pay_core_utils.push_message(801,'PAY_INVALID_EE_DATA','A');
                 pay_core_utils.push_token('record_name',p_record_name);
                 pay_core_utils.push_token('name_or_number',
                                      substr(l_emp_name_or_number,1,50));
                 pay_core_utils.push_token('field_name',l_field_description);
                 pay_core_utils.push_token('description',
                                           substr(l_description,1,50));
                 l_err := TRUE;
               END IF;
               IF rcw_wage_rec(4).wage_new_value > l_ss_tax_limit
               THEN
--{
                 hr_utility.trace('SS Tax w/h is > '||
                                  to_char(l_ss_tax_limit));
                 l_err := TRUE;
                 l_amount:=l_ss_tax_limit/100;
                 l_description:=' It is greater than  '||to_char(l_amount);
                 pay_core_utils.push_message(801,'PAY_INVALID_EE_DATA','A');
                 pay_core_utils.push_token('record_name',p_record_name);
                 pay_core_utils.push_token('name_or_number',
                                           substr(l_emp_name_or_number,1,50));
                 pay_core_utils.push_token('field_name',parameter_record(4).p_parameter_name);
                 pay_core_utils.push_token('description',l_description);
/* Sample message for SS Wage/Tax limit
   Error in RW record for Employee 1234 in Social Security Tax Withheld. It is greater than 498480  */
--}
                 END IF; --l_ss_tax_limit
--}
              END IF; -- negative check
--}
            END IF; --l_ss_count
   hr_utility.set_location(gv_package || '.format_W2C_RCW_record', 80);
            hr_utility.trace('After SS Wage/ Tax limit checking ');
            IF l_err THEN
               IF p_validate = 'Y' THEN
                  p_exclude_from_output := 'Y';
               END IF;
            END IF;

            IF p_exclude_from_output = 'Y' THEN
               l_exclude_from_output_chk := TRUE;
            ELSE
               l_exclude_from_output_chk := FALSE;
            END IF;
--
-- Validation for RCW record Ends here
--
   hr_utility.set_location(gv_package || '.format_W2C_RCW_record', 90);
   hr_utility.trace('Formating RCW record in MMREF-2 format ');
-- Formatting Wage Record (RCW) for .mf reporting file
--
       return_value_mf :=    'RCW'
                             ||l_ssn_old
                             ||l_ssn_new
                             ||rpad(l_first_name_old,15)
                             ||rpad(l_middle_name_old,15)
                             ||rpad(l_last_name_old,20)
                             ||rpad(l_first_name_new,15)
                             ||rpad(l_middle_name_new,15)
                             ||rpad(l_last_name_new,20)
                             ||rpad(substr(nvl(p_location_address,' '),1,22),22)
                             ||rpad(substr(nvl(p_delivery_address,' '),1,22),22)
                             ||rpad(substr(nvl(p_city,' '),1,22),22)
                             ||rpad(substr(nvl(p_state,' '),1,2),2)
                             ||rpad(substr(nvl(p_zip,' '),1,5),5)
                             ||rpad(substr(nvl(p_zip_extension,' '),1,4),9)
                             ||rpad(substr(nvl(p_foreign_state,' '),1,23),23)
                             ||rpad(substr(nvl(p_foreign_postal_code,' '),1,15),15)
                             ||rpad(substr(nvl(p_country_code,' '),1,2),2)
                             ||rcw_wage_rec(1).wage_old_value_formated
                             ||rcw_wage_rec(1).wage_new_value_formated
                             ||rcw_wage_rec(2).wage_old_value_formated
                             ||rcw_wage_rec(2).wage_new_value_formated
                             ||rcw_wage_rec(3).wage_old_value_formated
                             ||rcw_wage_rec(3).wage_new_value_formated
                             ||rcw_wage_rec(4).wage_old_value_formated
                             ||rcw_wage_rec(4).wage_new_value_formated
                             ||rcw_wage_rec(5).wage_old_value_formated
                             ||rcw_wage_rec(5).wage_new_value_formated
                             ||rcw_wage_rec(6).wage_old_value_formated
                             ||rcw_wage_rec(6).wage_new_value_formated
                             ||rcw_wage_rec(7).wage_old_value_formated
                             ||rcw_wage_rec(7).wage_new_value_formated
                             ||rcw_wage_rec(8).wage_old_value_formated
                             ||rcw_wage_rec(8).wage_new_value_formated
                             ||rcw_wage_rec(9).wage_old_value_formated
                             ||rcw_wage_rec(9).wage_new_value_formated
                             ||rcw_wage_rec(10).wage_old_value_formated
                             ||rcw_wage_rec(10).wage_new_value_formated
                             ||rcw_wage_rec(11).wage_old_value_formated
                             ||rcw_wage_rec(11).wage_new_value_formated
                             ||rcw_wage_rec(12).wage_old_value_formated
                             ||rcw_wage_rec(12).wage_new_value_formated
                             ||rcw_wage_rec(13).wage_old_value_formated
                             ||rcw_wage_rec(13).wage_new_value_formated
                             ||rcw_wage_rec(14).wage_old_value_formated
                             ||rcw_wage_rec(14).wage_new_value_formated
                             ||rcw_wage_rec(15).wage_old_value_formated
                             ||rcw_wage_rec(15).wage_new_value_formated
                             ||rcw_wage_rec(16).wage_old_value_formated
                             ||rcw_wage_rec(16).wage_new_value_formated
                             ||rcw_wage_rec(17).wage_old_value_formated
                             ||rcw_wage_rec(17).wage_new_value_formated
                             ||rcw_wage_rec(21).wage_old_value_formated
                             ||rcw_wage_rec(21).wage_new_value_formated
                             --||lpad(' ',22)
                             ||rcw_wage_rec(18).wage_old_value_formated
                             ||rcw_wage_rec(18).wage_new_value_formated
                             /* commented for bug 4398606 ||lpad(' ',44) */
                             ||rcw_wage_rec(22).wage_old_value_formated --noncombatpay
                             ||rcw_wage_rec(22).wage_new_value_formated
                             ||lpad(' ',22)
                             /* done changes for bug 4398606 */
                             ||rcw_wage_rec(19).wage_old_value_formated
                             ||rcw_wage_rec(19).wage_new_value_formated
                             ||rcw_wage_rec(20).wage_old_value_formated
                             ||rcw_wage_rec(20).wage_new_value_formated
                             /* commented for bug 4398606 ||lpad(' ',253)*/
                             ||rcw_wage_rec(23).wage_old_value_formated
                             ||rcw_wage_rec(23).wage_new_value_formated
                             ||rcw_wage_rec(24).wage_old_value_formated
                             ||rcw_wage_rec(24).wage_new_value_formated
                             ||rcw_wage_rec(25).wage_old_value_formated
                             ||rcw_wage_rec(25).wage_new_value_formated
                             --||lpad(' ',231)
                             ||lpad(' ',187)
                             ||lpad(p_statutory_emp_indicator_old,1)
                             ||lpad(p_statutory_emp_indicator_new,1)
                             ||lpad(p_retire_plan_indicator_old,1)
                             ||lpad(p_retire_plan_indicator_new,1)
                             ||lpad(p_sickpay_indicator_old,1)
                             ||lpad(p_sickpay_indicator_new,1)
                             ||lpad(' ',16);
   pay_us_w2c_in_mmref2_format.rcw_mf_record  := return_value_mf;
   hr_utility.trace('Formating RCW record completed ');
   hr_utility.trace('mf Format RCW Record  '||pay_us_w2c_in_mmref2_format.rcw_mf_record);
   hr_utility.trace('Length of FLAT Format RCW Record  '||to_char(length(pay_us_w2c_in_mmref2_format.rcw_mf_record)));
   hr_utility.set_location(gv_package || '.format_W2C_RCW_record', 100);
   --}
   -- Formatting CSV format of RCW record
   --{
    hr_utility.trace('Formating RCW record in CSV format');

    if l_exclude_from_output_chk then
    -- {
       -- This will be used for a02 record because this gets the actual values
       -- from balance calls. In a02 we will show all the values irrespective
       -- if it is changed or not.

       return_value_csv :=
                     'RCW'
                     ||','||l_ssn_old
                     ||','||l_ssn_new
                     ||','||rpad(l_first_name_old,15)
                     ||','||rpad(l_middle_name_old,15)
                     ||','||rpad(l_last_name_old,20)
                     ||','||rpad(l_first_name_new,15)
                     ||','||rpad(l_middle_name_new,15)
                     ||','||rpad(l_last_name_new,20)
                     ||','||rpad(substr(nvl(p_location_address,' '),1,22),22)
                     ||','||rpad(substr(nvl(p_delivery_address,' '),1,22),22)
                     ||','||rpad(substr(nvl(p_city,' '),1,22),22)
                     ||','||rpad(substr(nvl(p_state,' '),1,2),2)
                     ||','||rpad(substr(nvl(p_zip,' '),1,5),5)
                     ||','||rpad(substr(nvl(p_zip_extension,' '),1,4),9)
                     ||','||' '
                     ||','||rpad(substr(nvl(p_foreign_state,' '),1,23),23)
                     ||','||rpad(substr(nvl(p_foreign_postal_code,' '),1,15),15)
                     ||','||rpad(substr(nvl(p_country_code,' '),1,2),2)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information1*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information1*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information2*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information2*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information3*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information3*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information4*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information4*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information5*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information5*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information6*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information6*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information7*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information7*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information8*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information8*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information9*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information9*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information10*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information10*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information11*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information11*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information12*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information12*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information13*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information13*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information14*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information14*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information15*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information15*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information16*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information16*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information17*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information17*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information21*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information21*100)
                     --||','||lpad(' ',22)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information18*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information18*100)
                     ||','||lpad(' ',44)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information19*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information19*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information20*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information20*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information23*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information23*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information24*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information24*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information25*100)
                     ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information25*100)
                     ||','||lpad(' ',187)
                     ||','||lpad(p_statutory_emp_indicator_old,1)
                     ||','||lpad(p_statutory_emp_indicator_new,1)
                     ||','||lpad(p_retire_plan_indicator_old,1)
                     ||','||lpad(p_retire_plan_indicator_new,1)
                     ||','||lpad(p_sickpay_indicator_old,1)
                     ||','||lpad(p_sickpay_indicator_new,1)
                     ||','||lpad(' ',16);

     else

       return_value_csv :=   'RCW'
                             ||','||l_ssn_old
                             ||','||l_ssn_new
                             ||','||rpad(l_first_name_old,15)
                             ||','||rpad(l_middle_name_old,15)
                             ||','||rpad(l_last_name_old,20)
                             ||','||rpad(l_first_name_new,15)
                             ||','||rpad(l_middle_name_new,15)
                             ||','||rpad(l_last_name_new,20)
                             ||','||rpad(substr(nvl(p_location_address,' '),1,22),22)
                             ||','||rpad(substr(nvl(p_delivery_address,' '),1,22),22)
                             ||','||rpad(substr(nvl(p_city,' '),1,22),22)
                             ||','||rpad(substr(nvl(p_state,' '),1,2),2)
                             ||','||rpad(substr(nvl(p_zip,' '),1,5),5)
                             ||','||rpad(substr(nvl(p_zip_extension,' '),1,4),9)
                             ||','||' '
                             ||','||rpad(substr(nvl(p_foreign_state,' '),1,23),23)
                             ||','||rpad(substr(nvl(p_foreign_postal_code,' '),1,15),15)
                             ||','||rpad(substr(nvl(p_country_code,' '),1,2),2)
                             ||','||rcw_wage_rec(1).wage_old_value_formated
                             ||','||rcw_wage_rec(1).wage_new_value_formated
                             ||','||rcw_wage_rec(2).wage_old_value_formated
                             ||','||rcw_wage_rec(2).wage_new_value_formated
                             ||','||rcw_wage_rec(3).wage_old_value_formated
                             ||','||rcw_wage_rec(3).wage_new_value_formated
                             ||','||rcw_wage_rec(4).wage_old_value_formated
                             ||','||rcw_wage_rec(4).wage_new_value_formated
                             ||','||rcw_wage_rec(5).wage_old_value_formated
                             ||','||rcw_wage_rec(5).wage_new_value_formated
                             ||','||rcw_wage_rec(6).wage_old_value_formated
                             ||','||rcw_wage_rec(6).wage_new_value_formated
                             ||','||rcw_wage_rec(7).wage_old_value_formated
                             ||','||rcw_wage_rec(7).wage_new_value_formated
                             ||','||rcw_wage_rec(8).wage_old_value_formated
                             ||','||rcw_wage_rec(8).wage_new_value_formated
                             ||','||rcw_wage_rec(9).wage_old_value_formated
                             ||','||rcw_wage_rec(9).wage_new_value_formated
                             ||','||rcw_wage_rec(10).wage_old_value_formated
                             ||','||rcw_wage_rec(10).wage_new_value_formated
                             ||','||rcw_wage_rec(11).wage_old_value_formated
                             ||','||rcw_wage_rec(11).wage_new_value_formated
                             ||','||rcw_wage_rec(12).wage_old_value_formated
                             ||','||rcw_wage_rec(12).wage_new_value_formated
                             ||','||rcw_wage_rec(13).wage_old_value_formated
                             ||','||rcw_wage_rec(13).wage_new_value_formated
                             ||','||rcw_wage_rec(14).wage_old_value_formated
                             ||','||rcw_wage_rec(14).wage_new_value_formated
                             ||','||rcw_wage_rec(15).wage_old_value_formated
                             ||','||rcw_wage_rec(15).wage_new_value_formated
                             ||','||rcw_wage_rec(16).wage_old_value_formated
                             ||','||rcw_wage_rec(16).wage_new_value_formated
                             ||','||rcw_wage_rec(17).wage_old_value_formated
                             ||','||rcw_wage_rec(17).wage_new_value_formated
                             ||','||rcw_wage_rec(21).wage_old_value_formated
                             ||','||rcw_wage_rec(21).wage_new_value_formated
                             ||','||rcw_wage_rec(18).wage_old_value_formated
                             ||','||rcw_wage_rec(18).wage_new_value_formated
                             ||','||lpad(' ',44)
                             ||','||rcw_wage_rec(19).wage_old_value_formated  /* 5358272 */
                             ||','||rcw_wage_rec(19).wage_new_value_formated
                             ||','||rcw_wage_rec(20).wage_old_value_formated
                             ||','||rcw_wage_rec(20).wage_new_value_formated
                             ||','||rcw_wage_rec(23).wage_old_value_formated
                             ||','||rcw_wage_rec(23).wage_new_value_formated
                             ||','||rcw_wage_rec(24).wage_old_value_formated
                             ||','||rcw_wage_rec(24).wage_new_value_formated
                             ||','||rcw_wage_rec(25).wage_old_value_formated
                             ||','||rcw_wage_rec(25).wage_new_value_formated
                             ||','||lpad(' ',187)
                             ||','||lpad(p_statutory_emp_indicator_old,1)
                             ||','||lpad(p_statutory_emp_indicator_new,1)
                             ||','||lpad(p_retire_plan_indicator_old,1)
                             ||','||lpad(p_retire_plan_indicator_new,1)
                             ||','||lpad(p_sickpay_indicator_old,1)
                             ||','||lpad(p_sickpay_indicator_new,1)
                             ||','||lpad(' ',16);

     end if; /* l_exclude_from_output_chk */

     pay_us_w2c_in_mmref2_format.rcw_csv_record := return_value_csv;
     hr_utility.trace('CSV Format RCW Record  '||pay_us_w2c_in_mmref2_format.rcw_csv_record);
     hr_utility.trace('Length of CSV Format RCW Record  '||to_char(length(pay_us_w2c_in_mmref2_format.rcw_csv_record)));
     hr_utility.set_location(gv_package || '.format_W2C_RCW_record', 110);
   --}
   -- Format Blank RCW record in MMREF-2 format
   -- This Blank record would be used when RCO record is moved to .a02 for error
   --{

     hr_utility.trace('Formatting BLANK RCW Record ');
     return_value_blank :=
                     ' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' '
                     ||','||' ';
   pay_us_w2c_in_mmref2_format.rcw_blank_csv_record := return_value_blank;
   hr_utility.trace('CSV Blank Format RCW Record  '||pay_us_w2c_in_mmref2_format.rcw_blank_csv_record);
   hr_utility.set_location(gv_package || '.format_W2C_RCW_record', 120);
   --}

   hr_utility.trace('p_exclude_from_output  ->'||p_exclude_from_output);
   p_error := l_exclude_from_output_chk;
   ret_str_len:=length(return_value_mf);
   return return_value_mf;
END format_W2C_RCW_record;
-- End of Formatting RCW in MMREF-2 format

-- This function is used for formatting RCO Record in MMREF-2 format
--
FUNCTION format_W2C_RCO_record (  p_effective_date               IN varchar2,
                                  p_report_type                  IN varchar2,
                                  p_format                       IN varchar2,
                                  p_report_qualifier             IN varchar2,
                                  p_record_name                  IN varchar2,
                                  p_tax_unit_id                  IN varchar2,
                                  p_record_identifier            IN varchar2,
                                  p_ssn_new                      IN varchar2,
                                  p_first_name_new               IN varchar2,
                                  p_middle_name_new              IN varchar2,
                                  p_last_name_new                IN varchar2,
                                  p_orig_assignment_actid        IN varchar2,
                                  p_correct_assignment_actid     IN varchar2,
                                  p_employee_number              IN varchar2,
                                  rco_wage_rec                   IN OUT nocopy pay_us_w2c_in_mmref2_format.table_wage_record,
                                  p_format_type                  IN varchar2,
                                  p_validate                     IN varchar2,
                                  p_exclude_from_output          OUT nocopy varchar2,
                                  ret_str_len                    OUT nocopy varchar2,
                                  p_error                        OUT nocopy boolean
                               )
                               return varchar2
IS
l_emp_name_or_number       varchar2(50);
l_emp_number               varchar2(50);
l_full_name_new            varchar2(100);
l_message                  varchar2(2000);
l_description              varchar2(50);
l_field_description        varchar2(50);
l_ss_count                 number(10);
l_amount                   number(10);
return_value_mf            varchar2(32767);
return_value_csv           varchar2(32767);
return_value_blank         varchar2(32767);
l_err                      boolean;
l_exclude_from_output_chk  boolean;
sp_out_1                   varchar2(100);
sp_out_2                   varchar2(100);

TYPE function_columns IS RECORD(
                                p_parameter_name  varchar2(100)
                               );
function_parameter_rec  function_columns;
TYPE input_parameter_record IS TABLE OF function_parameter_rec%TYPE
                               INDEX BY BINARY_INTEGER;
parameter_record input_parameter_record;

BEGIN
   hr_utility.set_location(gv_package || '.format_W2C_RCO_record', 10);
   --{

         l_full_name_new := substr(pay_us_reporting_utils_pkg.Character_check(ltrim(rtrim(p_first_name_new)||' '||
                                     rtrim(p_last_name_new))),1,50);

         l_emp_number := replace(p_employee_number,' ');

         IF l_emp_number IS NULL THEN
            l_emp_name_or_number := l_full_name_new;
            hr_utility.trace('Employee Name or Number = '||l_emp_name_or_number);
         ELSE
            l_emp_name_or_number:= l_emp_number;
            hr_utility.trace('Employee Name or Number = '||l_emp_name_or_number);
         END IF;
         hr_utility.set_location(gv_package || '.format_W2C_RCO_record', 20);
--
--   Validation for RCO Record  Start
--
         parameter_record(1).p_parameter_name:= ' allocated tips';
         parameter_record(2).p_parameter_name:= ' uncollected employee tax on tips';
         parameter_record(3).p_parameter_name:= ' Medical Savings Account';
         parameter_record(4).p_parameter_name:= ' Simple Retirement Account';
         parameter_record(5).p_parameter_name:= ' Qualified adoption expenses';
         parameter_record(6).p_parameter_name:= 'uncollected social security or RRTA tax on GTL insurance over $50000';
         parameter_record(7).p_parameter_name:= 'uncollected medicare tax on GTL insurance over $50,000';
         parameter_record(8).p_parameter_name:= 'income under 409A';
--    Various Amount Validation for for Neg value. If value is found negative record
--            is marked for exclusion
         FOR i in 1..8
         LOOP
-- Negative Value validation for Originally reported wages
-- if Originally reported and coreected values are identical validation and
--    formating are  avoided with this check
--
           hr_utility.set_location(gv_package || '.format_W2C_RCO_record', 30);
           if (rco_wage_rec(i).identical_flag = 'N') then
           --{
              if rco_wage_rec(i).wage_old_value <> 0 then
              --{
                 rco_wage_rec(i).wage_old_value_formated :=
                    pay_us_reporting_utils_pkg.data_validation(
                                                p_effective_date,
                                                p_report_type,
                                                p_format,
                                                p_report_qualifier,
                                                p_record_name,
                                                'NEG_CHECK',
                                                rco_wage_rec(i).wage_old_value,
                                                parameter_record(i).p_parameter_name||'(Old)',
                                                l_emp_name_or_number, --EE number or Full name for mesg
                                                null,
                                                p_validate,
                                                p_exclude_from_output,
                                                sp_out_1,
                                                sp_out_2);

                 IF p_exclude_from_output = 'Y' THEN
                    l_exclude_from_output_chk := TRUE;
                    l_err := TRUE;
                 END IF;
                 hr_utility.trace(parameter_record(i).p_parameter_name||'Old = '||
                                       rco_wage_rec(i).wage_old_value_formated);
                 hr_utility.trace('p_exclude_from_output = '||p_exclude_from_output);
              --}
              else
                 rco_wage_rec(i).wage_old_value_formated := lpad('0',11,'0');
              end if;
           hr_utility.set_location(gv_package || '.format_W2C_RCW_record', 40);
-- Validation and formating of Corrected Value
--
              if rco_wage_rec(i).wage_new_value <> 0 then
              --{
                 rco_wage_rec(i).wage_new_value_formated :=
                    pay_us_reporting_utils_pkg.data_validation(
                                                p_effective_date,
                                                p_report_type,
                                                p_format,
                                                p_report_qualifier,
                                                p_record_name,
                                                'NEG_CHECK',
                                                rco_wage_rec(i).wage_new_value,
                                                parameter_record(i).p_parameter_name||'(New)',
                                                l_emp_name_or_number, --EE number or Full Name for mesg
                                                null,
                                                p_validate,
                                                p_exclude_from_output,
                                                sp_out_1,
                                                sp_out_2);

                 IF p_exclude_from_output = 'Y' THEN
                    l_exclude_from_output_chk := TRUE;
                    l_err := TRUE;
                 END IF;
                 hr_utility.trace(parameter_record(i).p_parameter_name||'New = '||
                                       rco_wage_rec(i).wage_new_value_formated);
                 hr_utility.trace('p_exclude_from_output = '||p_exclude_from_output);
              --}
              else
                 rco_wage_rec(i).wage_new_value_formated := lpad('0',11,'0');
              end if;
           --}
           end if;
         END LOOP;
         hr_utility.set_location(gv_package || '.format_W2C_RCO_record', 50);
         if l_err then
            p_exclude_from_output := 'Y';
         end if;

         IF p_exclude_from_output = 'Y' THEN
            l_exclude_from_output_chk := TRUE;
         ELSE
            l_exclude_from_output_chk := FALSE;
         END IF;
--
-- Validation for RCO record Ends here
--
   hr_utility.set_location(gv_package || '.format_W2C_RCO_record', 60);
   hr_utility.trace('Formating RCO record in MMREF-2 format ');
-- Formatting Wage Record (RCO) for .mf reporting file
--
       return_value_mf :=    'RCO'
                             ||lpad(' ',9)
                             ||rco_wage_rec(1).wage_old_value_formated
                             ||rco_wage_rec(1).wage_new_value_formated
                             ||rco_wage_rec(2).wage_old_value_formated
                             ||rco_wage_rec(2).wage_new_value_formated
                             ||rco_wage_rec(3).wage_old_value_formated
                             ||rco_wage_rec(3).wage_new_value_formated
                             ||rco_wage_rec(4).wage_old_value_formated
                             ||rco_wage_rec(4).wage_new_value_formated
                             ||rco_wage_rec(5).wage_old_value_formated
                             ||rco_wage_rec(5).wage_new_value_formated
                             ||rco_wage_rec(6).wage_old_value_formated
                             ||rco_wage_rec(6).wage_new_value_formated
                             ||rco_wage_rec(7).wage_old_value_formated
                             ||rco_wage_rec(7).wage_new_value_formated
                             ||rco_wage_rec(8).wage_old_value_formated
                             ||rco_wage_rec(8).wage_new_value_formated
                             ||lpad(' ',836);
   pay_us_w2c_in_mmref2_format.rco_mf_record  := return_value_mf;
   hr_utility.trace('Formating RCO record completed ');
   hr_utility.trace('mf Format RCO Record  '||pay_us_w2c_in_mmref2_format.rco_mf_record);
   hr_utility.trace('Length of FLAT Format RCO Record  '||to_char(length(pay_us_w2c_in_mmref2_format.rco_mf_record)));
   hr_utility.set_location(gv_package || '.format_W2C_RCO_record', 70);
   --}
   -- Formatting CSV format of RCO record
   --{
    hr_utility.trace('Formating RCO record in CSV format');

    if l_exclude_from_output_chk then
    -- {
       -- This will be used for a02 record because this gets the actual values
       -- from balance calls. In a02 we will show all the values irrespective
       -- if it is changed or not.

             return_value_csv :=      ','  ||
                             'RCO'
                             ||','||lpad(' ',9)
                             ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rco_info(1).action_information1*100)
                             ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rco_info(2).action_information1*100)
                             ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rco_info(1).action_information2*100)
                             ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rco_info(2).action_information2*100)
                             ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rco_info(1).action_information3*100)
                             ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rco_info(2).action_information3*100)
                             ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rco_info(1).action_information4*100)
                             ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rco_info(2).action_information4*100)
                             ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rco_info(1).action_information5*100)
                             ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rco_info(2).action_information5*100)
                             ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rco_info(1).action_information6*100)
                             ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rco_info(2).action_information6*100)
                             ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rco_info(1).action_information7*100)
                             ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rco_info(2).action_information7*100)
                             ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rco_info(1).action_information8*100)
                             ||','||to_char(pay_us_w2c_in_mmref2_format.ltr_rco_info(2).action_information8*100)
                             ||lpad(' ',836);
                             --||lpad(' ',858);
             /* Bug 4097321 - Assign return_value_csv to global variable*/
             pay_us_w2c_in_mmref2_format.rco_csv_record := return_value_csv;
     --}
     else

       return_value_mf :=    'RCO'
                             ||','||lpad(' ',9)
                             ||','||rco_wage_rec(1).wage_old_value_formated
                             ||','||rco_wage_rec(1).wage_new_value_formated
                             ||','||rco_wage_rec(2).wage_old_value_formated
                             ||','||rco_wage_rec(2).wage_new_value_formated
                             ||','||rco_wage_rec(3).wage_old_value_formated
                             ||','||rco_wage_rec(3).wage_new_value_formated
                             ||','||rco_wage_rec(4).wage_old_value_formated
                             ||','||rco_wage_rec(4).wage_new_value_formated
                             ||','||rco_wage_rec(5).wage_old_value_formated
                             ||','||rco_wage_rec(5).wage_new_value_formated
                             ||','||rco_wage_rec(6).wage_old_value_formated
                             ||','||rco_wage_rec(6).wage_new_value_formated
                             ||','||rco_wage_rec(7).wage_old_value_formated
                             ||','||rco_wage_rec(7).wage_new_value_formated
                             ||','||rco_wage_rec(8).wage_old_value_formated
                             ||','||rco_wage_rec(8).wage_new_value_formated
                             ||lpad(' ',836);

                             --||','||lpad(' ',858);
	     /* Bug 4097321 - Assign return_value_mf to global variable
	                      This is needed to print RCO in a03 if it is correct */
             pay_us_w2c_in_mmref2_format.rco_csv_record := ',' || return_value_mf;

     end if;

     /* Bug 4097321 - Commented following code. The Assignment is done inside the IF..ELSE above
     pay_us_w2c_in_mmref2_format.rco_csv_record := return_value_csv;      */
     hr_utility.trace('CSV Format RCO Record  '||pay_us_w2c_in_mmref2_format.rco_csv_record);
     hr_utility.set_location(gv_package || '.format_W2C_RCO_record', 80);
   --}
   -- Format Blank RCO record in MMREF-2 format
   -- This Blank record would be used when RCO record is moved to .a02 for error
   --{

     hr_utility.trace('Formatting BLANK RCO Record ');
     return_value_blank :=   ','
                             ||' '
                             ||','||lpad(' ',9)
                             ||','||' '
                             ||','||' '
                             ||','||' '
                             ||','||' '
                             ||','||' '
                             ||','||' '
                             ||','||' '
                             ||','||' '
                             ||','||' '
                             ||','||' '
                             ||','||' '
                             ||','||' '
                             ||','||' '
                             ||','||' '
                             ||','||' ';
   pay_us_w2c_in_mmref2_format.rco_blank_csv_record := return_value_blank;
   hr_utility.trace('CSV Blank Format RCO Record  '||pay_us_w2c_in_mmref2_format.rcw_blank_csv_record);
   hr_utility.set_location(gv_package || '.format_W2C_RCO_record', 90);
   --}

   hr_utility.trace('p_exclude_from_output  ->'||p_exclude_from_output);
   p_error := l_exclude_from_output_chk;
   ret_str_len:=length(return_value_mf);
    hr_utility.trace('format W2C RCO return_value_mf  ->'||return_value_mf);
   return return_value_mf;
END format_W2C_RCO_record;
-- End of Formatting RCW in MMREF-2 format

--BEGIN
--hr_utility.trace_on(null,'W2CFMTREC');
END pay_us_mmrf2_w2c_format_record; -- End of Package Body

/
