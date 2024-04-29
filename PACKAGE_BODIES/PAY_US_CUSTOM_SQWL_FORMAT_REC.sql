--------------------------------------------------------
--  DDL for Package Body PAY_US_CUSTOM_SQWL_FORMAT_REC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_CUSTOM_SQWL_FORMAT_REC" AS
/* $Header: pyuscussqfr.pkb 120.3.12000000.1 2007/01/18 02:14:23 appldev noship $  */

 /*===========================================================================+
 |               Copyright (c) 2001 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+

  Name
    pay_us_custom_sqwl_format_rec

  Purpose
    The purpose of this package is to format reacord to support the
    generation of SQWL magnetic tape for US legilsative requirements.

  Notes
    Referenced By:  Package  pay_us_reporting_utils_pkg

  History

  24-FEB-2004  jgoswami    115.0   3334497      Created
  30-May-2006  sackumar    115.1   5089997     Modified format_SQWL_CUSTOM_EMPLOYER
								     and format_SQWL_CUSTOM_EMPLOYEE procedures for NM and AK

  14-JUN-2006  sackumar    115.2   5089997     Modified format_SQWL_CUSTOM_EMPLOYER for NM
*/

--
-- Formatting Submitter record for SQWL reporting
-- For Future Use

--
-- Formatting Custom Employer record for SQWL reporting
--
   /* Record Identifier              --> p_input_1,
      Employer Account Number        --> p_input_2,
      Tax Year                       --> p_input_3,
      Quarter                        --> p_input_4,
      Number of Wage Items           --> p_input_5,
      Total Wages                    --> p_input_6,
      Source Code                    --> p_input_7,
      Filler                         --> p_input_8,
      Batch Number                   --> p_input_9,
      Batch Item                     --> p_input_10,
   */
--
FUNCTION format_SQWL_CUSTOM_EMPLOYER(
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
l_term_indicator           varchar2(1);
l_other_ein                varchar2(100);
l_exclude_from_output_chk  boolean;
l_input_8                  varchar2(50);
l_bus_tax_acct_number      varchar2(50);
l_rep_qtr                  varchar2(300);
l_rep_prd                  varchar2(300);
l_end_of_rec               varchar2(20);
l_transaction_code         varchar2(1);
l_emp_account_num          varchar2(100);
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

p_end_of_rec varchar2(20) := fnd_global.local_chr(13)||fnd_global.local_chr(10);
BEGIN
   hr_utility.trace('Custom Employer Record Formatting started ');
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

   IF p_record_name = 'H' THEN -- p_record_name
--{
      IF  p_report_qualifier = 'AK_SQWL' THEN
--{
      /* Pos: 1   Len: 1 Transaction Code. */
         l_transaction_code := 'H';

        /* Pos: 2   Len: 10  Desc: State Employer Account Number */
        /* Ask Legislative Analyst to check for Special Characters */
        /* r_input_2 := rpad(substr(replace( pay_us_reporting_utils_pkg.character_check(nvl(r_input_2,'0')),'-'),1,8),8,0);
        */

          l_emp_account_num := upper(lpad(substr(replace(r_input_2,'-'), 1, 8), 8, '0'));

         /* Pos: 14   Len:   1   Desc: Quarter */
               IF substr(p_input_4,1,2) = '03' THEN
                  l_rep_prd := 1;
               ELSIF substr(p_input_4,1,2) = '06' THEN
                  l_rep_prd := 2;
               ELSIF substr(p_input_4,1,2) = '09' THEN
                  l_rep_prd := 3;
               ELSIF substr(p_input_4,1,2) = '12' THEN
                  l_rep_prd := 4;
               END IF;

             IF p_input_40 = 'FLAT' THEN
   	      -- Formatting for mf file

                 return_value := l_transaction_code
                              ||l_emp_account_num
                              ||rpad(substr(nvl(r_input_3,' '),1,4),4)
                              ||l_rep_prd
                              ||lpad(substr(nvl(r_input_5,'0'),1,6),6,'0')
                              ||lpad(substr(nvl(r_input_6,'0'),1,11),11,'0')
                              ||r_input_7
                              ||lpad(nvl(r_input_8,'0'),73,'0')
                              ||lpad(nvl(r_input_9,'0'),8,'0')
                              ||lpad(nvl(r_input_10,'0'),4,'0');

                 ret_str_len:=length(return_value);
--}
             ELSIF p_input_40 = 'CSV' THEN
--{
               return_value:= l_transaction_code
                             ||','||l_emp_account_num
                             ||','||rpad(substr(nvl(r_input_3,' '),1,4),4)
                             ||','||l_rep_prd
                             ||','||lpad(substr(nvl(r_input_5,'0'),1,6),6,'0')
                             ||','||lpad(substr(nvl(r_input_6,'0'),1,11),11,'0')
                             ||','||r_input_7
                             ||','||lpad(nvl(r_input_8,'0'),73,'0')
                             ||','||lpad(nvl(r_input_9,'0'),8,'0')
                             ||','||lpad(nvl(r_input_10,'0'),4,'0');
--}
             END IF;
      ELSIF  p_report_qualifier = 'NM_SQWL' THEN
         r_input_3 := 'ES_903_Employer';

         IF p_input_40 = 'FLAT' THEN
	     return_value:= r_input_2
				      || r_input_3
				|| ',' || r_input_4
				|| ',' || r_input_5
				|| ',' || r_input_6
				|| ',' || r_input_7
				|| ',' || r_input_8
				|| ',' || r_input_9
				|| ',' || r_input_10
				|| ',' || r_input_11
				|| ',' || r_input_12
				|| ',' || r_input_13
				|| ',' || r_input_14
				|| ',' || r_input_15
				|| ',' || r_input_16
				|| ',' || r_input_17
				|| ',' || r_input_18
				|| ',' || r_input_19
				|| ',' || r_input_20
				|| ',' || r_input_21
				|| ',' || r_input_22
				|| ',' || r_input_23
				|| ',' || r_input_24 ;

		 ret_str_len:=length(return_value);

          ELSIF p_input_40 = 'CSV' THEN
	     return_value:= r_input_4
				|| ',' || r_input_5
				|| ',' || r_input_6
				|| ',' || r_input_7
				|| ',' || r_input_8
				|| ',' || r_input_9
				|| ',' || r_input_10
				|| ',' || r_input_11
				|| ',' || r_input_12
				|| ',' || r_input_13
				|| ',' || r_input_14
				|| ',' || r_input_15
				|| ',' || r_input_16
				|| ',' || r_input_17
				|| ',' || r_input_18
				|| ',' || r_input_19
				|| ',' || r_input_20
				|| ',' || r_input_21
				|| ',' || r_input_22
				|| ',' || r_input_23
				|| ',' || r_input_24;
	  END IF;
      END IF;-- p_report_qualifier
END IF;
   p_error := l_exclude_from_output_chk;
   ret_str_len:=length(return_value);
   hr_utility.trace('Length of return value = '||to_char(length(return_value)));
   return return_value;
END format_SQWL_CUSTOM_EMPLOYER; -- End of Function Formatting Custom Employer record

/*  ------------ Parameter mapping for SQWL Custom Employee Record  -------------
--{
  Record Identifier                                   --> p_input_1
  Employer Account Number                             --> p_input_2
  Tax Year                                            --> p_input_3
  Quarter                                             --> p_input_4
  Social Security Number (SSN)                        --> p_input_5
  Employee Last Name                                  --> p_input_6
  Employee First Name                                 --> p_input_7
  Employee Middle Name or Initial                     --> p_input_8
  State Quarterly Unemployment Insurance Total Wages  --> p_input_9
  Project Code                                        --> p_input_10
  Hourly Rate                                         --> p_input_11
  Occupational Code or Title                          --> p_input_12
  Area Code                                           --> p_input_13
  Batch Number                                        --> p_input_14
  Batch Item                                          --> p_input_15

  -- Not Currently Used for AK SQWL
  State Quarterly Unemployment Total Taxable Wages    --> p_input_16
  State Taxable Wages                                 --> p_input_17
  SIT Withheld                                        --> p_input_18
--}
*/

FUNCTION format_SQWL_CUSTOM_EMPLOYEE (
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
return_value                   varchar2(32767);
l_s_hyphen_position            number := 0;
l_pblm_code                    varchar2(1);
l_preparer_code                varchar2(1);
l_input_1                      varchar2(100);
l_records                      number(10);
l_input_2                      varchar2(100);
l_record_identifier            varchar2(2);
l_tax_year                     date;
l_agent_indicator              varchar2(1);
l_emp_ein                      varchar2(100);
l_term_indicator               varchar2(1);
l_agent_ein                    varchar2(100);
l_other_ein                    varchar2(100);
l_input_8                      varchar2(50);
l_check                        varchar2(1);
l_employment_code              varchar2(1);
p_exc                          varchar2(10);
main_return_string             varchar2(300);
l_resub_tlcn                   varchar2(100);
l_pin                          varchar2(50);
l_ssn                          varchar2(100);
l_wages_tips                   varchar2(100);
l_full_name                    varchar2(100);
l_emp_name_or_number           varchar2(50);
l_emp_number                   varchar2(50);
l_first_name                   varchar2(150);
l_middle_name                  varchar2(100);
l_last_name                    varchar2(150);
l_suffix                       varchar2(100);
l_err                          boolean;
l_exclude_from_output_chk      boolean;
l_message                      varchar2(2000);
l_ss_tax_limit                 pay_us_federal_tax_info_f.ss_ee_wage_limit%TYPE;
l_description                  varchar2(50);
l_field_description            varchar2(50);
l_ss_wage_limit                pay_us_federal_tax_info_f.ss_ee_wage_limit%TYPE;
l_ss_count                     number(10);
l_amount                       number(10);
l_tax_ct_job_dev               varchar2(30);
l_tax_ct_ind_revit             varchar2(30);
l_tax_ct_ind_dev               varchar2(30);
l_tax_ct_rural                 varchar2(30);
l_fit_wh                       varchar2(30);
l_total_records                varchar2(50);
l_wages                        varchar2(100);
l_taxes                        varchar2(100);
l_deferred_comp                varchar2(100);
l_sdi_wh                       varchar2(100);
l_state_length                 number(10);
l_unemp_insurance              varchar2(100);
l_fica_mcr_wh                  varchar2(100);
l_bus_tax_acct_number          varchar2(50);
l_w2_govt_ee_contrib           varchar2(100);
l_w2_fed_wages                 varchar2(100);
l_wa_sqwl_outstring            varchar2(200);
l_hours_worked                 number(10);
l_rep_prd                      varchar2(300);
l_transaction_code         varchar2(1);
l_emp_account_num          varchar2(100);
l_end_of_rec                   varchar2(20);
p_end_of_rec                   varchar2(20) :=
                               fnd_global.local_chr(13)||fnd_global.local_chr(10);
/* PuertoRico W2 related variables  Bug # 2736928 */
l_contact_person_phone_no      varchar2(100);       -- mapped to r_input_34
l_pension_annuity              varchar2(100);       -- mapped to r_input_35
l_contribution_plan            varchar2(100);       -- mapped to r_input_36
l_cost_reimbursement           varchar2(100);       -- mapped to r_input_37
l_uncollected_ss_tax_on_tips   varchar2(100);       -- mapped to r_input_31
l_uncollected_med_tax_on_tips  varchar2(100);       -- mapped to r_input_32

l_rt_end_of_rec                varchar2(200);

/* Bug 2789523 */
l_last_field                   varchar2(100);

r_input_1                      varchar2(300);
r_input_2                      varchar2(300);
r_input_3                      varchar2(300);
r_input_4                      varchar2(300);
r_input_5                      varchar2(300);
r_input_6                      varchar2(300);
r_input_7                      varchar2(300);
r_input_8                      varchar2(300);
r_input_9                      varchar2(300);
r_input_10                     varchar2(300);
r_input_11                     varchar2(300);
r_input_12                     varchar2(300);
r_input_13                     varchar2(300);
r_input_14                     varchar2(300);
r_input_15                     varchar2(300);
r_input_16                     varchar2(300);
r_input_17                     varchar2(300);
r_input_18                     varchar2(300);
r_input_19                     varchar2(300);
r_input_20                     varchar2(300);
r_input_21                     varchar2(300);
r_input_22                     varchar2(300);
r_input_23                     varchar2(300);
r_input_24                     varchar2(300);
r_input_25                     varchar2(300);
r_input_26                     varchar2(300);
r_input_27                     varchar2(300);
r_input_28                     varchar2(300);
r_input_29                     varchar2(300);
r_input_30                     varchar2(300);
r_input_31                     varchar2(300);
r_input_32                     varchar2(300);
r_input_33                     varchar2(300);
r_input_34                     varchar2(300);
r_input_35                     varchar2(300);
r_input_36                     varchar2(300);
r_input_37                     varchar2(300);
r_input_38                     varchar2(300);
r_input_39                     varchar2(300);

BEGIN
   hr_utility.trace('Formatting Custom Employee record for SQWL ');
   hr_utility.trace('p_report_qualifier = '||p_report_qualifier);
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

   IF p_record_name = 'D' THEN -- p_record_name
--{
      IF  p_report_qualifier = 'AK_SQWL' THEN
--{
      /* Pos: 1   Len: 1 Transaction Code. */
       /* Bug 4554387   l_transaction_code := 'D'; */

      /* Pos: 2   Len: 10  Desc: State Employer Account Number */
      /* Ask Legislative Analyst to check for Special Characters */
      /* r_input_2 := rpad(substr(replace( pay_us_reporting_utils_pkg.character_check(nvl(r_input_2,'0')),'-'),1,8),8,0);
         r_input_2 := lpad(replace(replace(nvl(replace(r_input_2,' '),' ') ,'-'),'/'),8,0);
      */

      l_emp_account_num := upper(lpad(substr(replace(r_input_2,'-'), 1, 8), 8, '0'));

     /* Pos: 14   Len:   1   Desc: Quarter                            */
               IF substr(p_input_4,1,2) = '03' THEN
                  l_rep_prd := 1;
               ELSIF substr(p_input_4,1,2) = '06' THEN
                  l_rep_prd := 2;
               ELSIF substr(p_input_4,1,2) = '09' THEN
                  l_rep_prd := 3;
               ELSIF substr(p_input_4,1,2) = '12' THEN
                  l_rep_prd := 4;
               END IF;

              /* Pos:15   Len: 9    Desc: Social security number */

              IF p_input_40 = 'FLAT' THEN

		    l_ssn := pay_us_reporting_utils_pkg.data_validation(
                                p_effective_date,
                                p_report_type,
                                p_format,
                                p_report_qualifier,
                                p_record_name,
                                'SSN',
                                r_input_5,
                                'Social Security',
                                p_input_39, --EE number for messg purpose.
                                null,
                                p_validate,
                                p_exclude_from_output,
                                sp_out_1,
                                sp_out_2);
                      IF p_exclude_from_output = 'Y' THEN
                          l_exclude_from_output_chk := TRUE;
                      END IF;
                   sp_out_5 := l_ssn;
               ELSE
                   l_ssn := replace(replace(r_input_5,'-'),',');
               END IF;

            hr_utility.trace('SSN after Validation and Formatting = '||l_ssn);

            /*Pos:24 - 48 Last name
               Pos:49 - 63 First name
               Pos:64 - 64 Middle name
            */

            l_last_name :=  pay_us_reporting_utils_pkg.Character_check(
                                     nvl(substr(r_input_6,1,25),''));
            l_first_name := pay_us_reporting_utils_pkg.Character_check(
                                     nvl(substr(r_input_7,1,15),''));
            l_middle_name := ltrim(pay_us_reporting_utils_pkg.Character_check(
                                     nvl(substr(r_input_8,1,1),'')));

             /* Pos:65-75 SUI Insurance Wages. */
             IF p_input_40 = 'FLAT' THEN

                  r_input_9 :=  pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                   p_report_type,
                                                   p_format,
                                                   p_report_qualifier,
                                                   p_record_name,
                                                   'NEG_CHECK',
                                                   r_input_9,
                                                   'SUI Insurance Wages',
                                                   p_input_39,
                                                   null,
                                                   p_validate,
                                                   p_exclude_from_output,
                                                   sp_out_1,
                                                   sp_out_2);

                    /*Bug# 4554387*/
                r_input_9 := ltrim(r_input_9,'0');

                IF p_exclude_from_output = 'Y' THEN
                    l_exclude_from_output_chk := TRUE;
                END IF;

             END IF;
          /* Pos:76 Project Code  */
          /* Bug 4554387    r_input_10 := lpad(nvl(r_input_10,'0'),1,'0'); */
          r_input_10 := '';

          /* Pos:77-81 Hourly Rate */
          /* Bug 4554387    r_input_11 := lpad(nvl(r_input_11,'0'),5,'0'); */
          r_input_11 := '';

        /* Pos: 82-103    Desc: Occupational Code or Title */
          r_input_12 :=  ltrim(upper(substr(r_input_12,1,10)));

        /* Pos: 104-105   Desc: Area Code */
          r_input_13 := ltrim(upper(substr(r_input_13,1,2)));

        /* Pos: 106-113   Desc: Batch Number  */
        /*Bug # 4554387   r_input_14 := lpad(nvl(r_input_14,'0'),8,'0');*/

        /* Pos: 114-117   Desc: Batch Number  */
        /*Bug # 4554387   r_input_15 := lpad(nvl(r_input_15,'0'),4,'0');*/

       /* Check with Legislative Analyst that do we want to report
          an employee to a02 for other -ve wages or taxes
       */

       /*Bug # 4554387 */
       /*
          IF p_input_40 = 'FLAT' THEN
       -{ Start of formatting FLAT type Custom Employee Record

           		return_value:= l_transaction_code
                               ||l_emp_account_num
                               ||rpad(substr(nvl(r_input_3,' '),1,4),4)
                               ||l_rep_prd
                               ||l_ssn
                               ||l_last_name
                               ||l_first_name
                               ||l_middle_name
                               ||r_input_9
                               ||r_input_10
                               ||r_input_11
                               ||r_input_12
                               ||r_input_13
                               ||r_input_14
                               ||r_input_15
                               |l_end_of_rec;

               hr_utility.trace('Length of return value = '||to_char(length(return_value)));
       --} End of formatting FLAT Type RS Record
          ELS
       */
       /* end of Bug # 4554387*/

          IF p_input_40 = 'CSV'
             or p_input_40 = 'FLAT' THEN /* Bug # 4554387 */

--{ Start of formatting Custom Employee record in CSV format
             return_value := /* Bug # 4554387 l_transaction_code
                             ||','||*/l_emp_account_num
                             ||','||rpad(substr(nvl(r_input_3,' '),1,4),4)
                             ||','||l_rep_prd
                             ||','||l_ssn
                             ||','||l_last_name
                             ||','||l_first_name
                             ||','||l_middle_name
                             ||','||r_input_9
                             ||',' /*Bug# 4554387 ||r_input_10 */
                             ||',' /*Bug# 4554387 ||r_input_11 */
                             ||','||r_input_12
                             ||','||r_input_13;
       		             /* Bug # 4554387
                             ||','||r_input_14
                             ||','||r_input_15
                             ||','||lpad(' ',5);
		             */

       --} End of formatting RS record in CSV format

          ELSIF p_input_40 = 'BLANK' THEN
       --{ Start of formatting BALNK Custom Employee record used for audit report

             return_value :=  ''
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
	       	              /* Bug# 4554387
                              ||','||' '
                              ||','||lpad(' ',5);
		              */
       --} End of formatting BLANK Custom Employee record used for audit report
          END IF; -- p_input_40
      ELSIF  p_report_qualifier = 'NM_SQWL' THEN
        r_input_2 := 'ES_903_Employees';

	  IF p_input_40 = 'FLAT' THEN
             return_value := r_input_2
	                          || ',' || r_input_3
	                          || ',' || r_input_4
	                          || ',' || r_input_5
	                          || ',' || r_input_6
	                          || ',' || r_input_7
	                          || ',' || r_input_8;

	  ELSIF p_input_40 = 'CSV' THEN
             return_value := r_input_3
	                          /* || ',' || r_input_4 Employee Name */
	                          || ',' || r_input_5
	                          || ',' || r_input_6
	                          || ',' || r_input_7
	                          || ',' || r_input_8;
          END IF;
      END IF;-- p_report_qualifier
END IF; -- p_record_name
   p_error := l_exclude_from_output_chk;
   ret_str_len:=length(return_value);
   hr_utility.trace('Length of return value = '||to_char(length(return_value)));
   return return_value;
END format_SQWL_CUSTOM_EMPLOYEE;
-- End of Formatting Custom Employee Record for SQWL Reporting

END pay_us_custom_sqwl_format_rec; -- End of Package Body

/
