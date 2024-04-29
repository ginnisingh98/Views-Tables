--------------------------------------------------------
--  DDL for Package Body PAY_US_MMRF_SQWL_FORMAT_RECORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_MMRF_SQWL_FORMAT_RECORD" AS
/* $Header: pyussqfr.pkb 120.12.12010000.3 2010/03/25 04:49:44 emunisek ship $  */
 /*===========================================================================+
 |               Copyright (c) 2001 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+

  Name
    pay_us_mmrf_sqwl_format_record

  Purpose
    The purpose of this package is to format reacord to support the
    generation of SQWL magnetic tape for US legilsative requirements.

  Notes
    Referenced By:  Package  pay_us_reporting_utils_pkg

  History

  25-Mar-2010  emunisek   115.25  9356178      Added new field to the Florida SQWL Record to
                                               display the Actual Florida SUI Taxable
  05-09-2008   pannapur   115.24  7335939      Modified 139th position for AL_SQWL to display 'AL'
  27-Jul-2007  sjawid     115.23  6277029      Modified RA, RE Records for Kansas.
  18-Jun-2007  sjawid     115.20  6036926      Kansas(KS) sqwl fomat changed to MMREF from ICESA.
  23-May-2007  sjawid     115.19  6057156      Added RT record for VA State.
  29-Nov-2006  sackumar   115.18  5686173      Modified RA, RE and RS Records for AL State.
  18-Nov-2006  sackumar   115.17  5657141      Modified RA Records for AL State
  02-Nov-2006  sackumar   115.16  5637654      Modified (POS 36-37)RA Records for Texas
  30-May-2006  sackumar  115.15   5092657      Modified RS Records for Texas SQWL
								      Modified RE, RS Record for Nebraska.
  17-Feb-2006  sudedas     115.14  4559359      Modified RA, RE, RS Records for Texas SQWL
                                   4867893      Modified RT Record for Alabama and Florida SQWL
  18-Nov-2005  saikrish    115.13  3835632      Added code to format Tips Wages.
  11-Nov-2005  sudedas     115.12  4552131      Modified RE,RS and RT Record for AL_SQWL
                                   1236643      Modified RS Record for MN_SQWL
  25-MAY-2005  sudedas     115.10  4170713      Modified RS record for MN_SQWL
  07-SEP-2004  jgoswami    115.9   3871022      Modified RA record for NV_SQWL
  02-SEP-2004  jgoswami    115.8   3871022      Modified RA record for NV_SQWL
  28-AUG-2004  jgoswami    115.7   3830050      Added code for NV_SQWL
  08-AUG-2004  jgoswami    115.6   3527986      Removed record delimiters for NY_SQWL
  01-MAR-2004  jgoswami    115.5   3334497      Added code for AK_SQWL
  19-DEC-2003  jgoswami    115.4   3319454      Added EIN fro WA_SQWL for a02,a03
  27-Oct-2003  fusman      115.1   Bug:3175230  Added End of rec for NY_SQWL
  14-Jul-2003  ppanda      115.0                Created
*/

-- This function determines the required length for fields
-- in various data record. This function is being referenced
-- from DAT_VALIDATION function in package pay_us_reporting_utils_pkg
--
FUNCTION set_req_field_length (p_report_type      IN  varchar2,
                               p_format           IN  varchar2,
                               p_report_qualifier IN  varchar2,
                               p_record_name      IN  varchar2,
                               p_input_1          IN  varchar2,
                               p_input_2          IN  varchar2,
                               p_input_3          IN  varchar2,
                               p_input_4          IN  varchar2,
                               p_input_5          IN  varchar2
                              ) return NUMBER
IS
  l_length    number(10);
BEGIN
       IF p_record_name in ('RU','RT','RF') THEN
--{
          l_length := 15;
          IF (p_record_name = 'RT') and (p_report_qualifier = 'FL_SQWL') THEN
	         IF (p_input_3 = 'Total Tax Due') THEN
	     	    l_length :=  11;
             ELSIF (p_input_3 like '%Month%') THEN
      			l_length := 7;
	         END IF;
          END IF;
--}
       ELSIF p_record_name in ('RS','RO','RW') THEN
--{
          l_length := 11;
          IF ((p_record_name = 'RS') AND
              (p_input_3 = 'Other State Data')
             ) THEN
             l_length := 10;
             hr_utility.trace('RS. Other State Data.l_length = '||to_char(l_length));
          ELSIF p_record_name = 'RS' THEN
--{
             IF p_report_qualifier = 'GA_SQWL' THEN
                IF p_input_3 = 'SUI Insurance Wages' THEN
                   l_length :=9;
                END IF;
             END IF; --GA_SQWL
--}
          END IF; --RS Record
--}
       ELSIF p_record_name in ('RSSUMM') THEN
--{
          l_length := 14;
--}
       ELSIF (p_record_name = 'D') and (p_report_qualifier = 'AK_SQWL') THEN
          l_length := 11;
       END IF; -- p_record_name
return l_length;
END set_req_field_length; -- End of set_req_field_length
--

PROCEDURE format_sqwl_contact_prsn_info (
                p_report_qualifier         IN  varchar2,
                p_record_name              IN  varchar2,
                p_validate                 IN  varchar2,
                p_exclude_from_output      IN OUT nocopy varchar2,
                p_contact_prsn_name        IN OUT nocopy varchar2,
                p_contact_prsn_phone       IN OUT nocopy varchar2,
                p_contact_prsn_extension   IN OUT nocopy varchar2,
                p_contact_prsn_email       IN OUT nocopy varchar2,
                p_contact_prsn_fax         IN OUT nocopy varchar2,
                p_contact_prsn_first_name  IN OUT nocopy varchar2,
                p_contact_prsn_middle_name IN OUT nocopy varchar2,
                p_contact_prsn_last_name   IN OUT nocopy varchar2)
IS
BEGIN
   IF p_contact_prsn_name is NULL THEN
--{
      p_contact_prsn_name      :=lpad(' ',27);
      p_contact_prsn_phone     :=lpad(' ',15);
      p_contact_prsn_extension :=lpad(' ',5);
      p_contact_prsn_email     :=lpad(' ',40);
      IF ((p_report_qualifier = 'NY_SQWL') AND
          (p_record_name = 'RA')) THEN
 		 p_contact_prsn_fax := lpad(' ',24);   --Fax
      ELSE
         p_contact_prsn_fax := lpad(' ',10);   --Fax
	  END IF;
--}
   ELSE
--{
      p_contact_prsn_name  :=rpad(substr(nvl(upper(p_contact_prsn_name),' '),1,27),27);
      p_contact_prsn_email :=rpad(substr(nvl(upper(p_contact_prsn_email),' '),1,40),40);
      IF p_report_qualifier = 'NY_SQWL' and
         p_record_name = 'RA' THEN
         p_contact_prsn_fax :=
           rpad(substr(nvl(replace(p_contact_prsn_fax,' '),' '),1,24),24);
      ELSE
   	     p_contact_prsn_fax :=
           rpad(substr(nvl(replace(p_contact_prsn_fax,' '),' '),1,10),10);
  	  END IF;
--}
   END IF;
END format_sqwl_contact_prsn_info;

-- Formatting RA record for SQWL reporting
--
/*----------------------------- Parameter mapping. -----------------------------
  Record Identifier,                                   -->   p_input_1
  Submitter''s Employer Identification Number (EIN),   -->   p_input_2
  Personal Identification Number (PIN)                 -->   p_input_3,
  Resub Indicator                                      -->   p_input_4,
-- This is  fix for bug # 2510920 to rename TLCN to WFID
  Resub WFID                                           -->   p_input_5,
  Software Code                                        -->   p_input_6,
  Company Name                                         -->   p_input_7,
  Location Address                                     -->   p_input_8,
  Delivery Address                                     -->   p_input_9,
  City                                                 -->   p_input_10,
  State Abbreviation                                   -->   p_input_11,
  Zip Code                                             -->   p_input_12,
  Zip Code Extension                                   -->   p_input_13,
  Foreign State / Province                             -->   p_input_14,
  Foreign Postal Code                                  -->   p_input_15,
  Country Code                                         -->   p_input_16,
  Submitter Name                                       -->   p_input_17,
  Location Address                                     -->   p_input_18,
  Delivery Address                                     -->   p_input_19,
  City                                                 -->   p_input_20,
  State Abbreviation                                   -->   p_input_21,
  Zip Code                                             -->   p_input_22,
  Zip Code Extension                                   -->   p_input_23,
  Foreign State / Province                             -->   p_input_24,
  Foreing Postal Code                                  -->   p_input_25,
  Country Code                                         -->   p_input_26,
  Contact Name                                         -->   p_input_27,
  Contact Phone Number                                 -->   p_input_28,
  Contact Phone Extension                              -->   p_input_29,
  Contact E-Mail                                       -->   p_input_30,
  Blank,Contact FAX                                    -->   p_input_31,
  Preferred Method Of Problem Notification Code        -->   p_input_32,
  Preparer Code                                        -->   p_input_33,
*/

FUNCTION format_SQWL_RA_record(
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
p_end_of_rec               varchar2(20);
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
p_end_of_rec   := fnd_global.local_chr(13)||fnd_global.local_chr(10);
  hr_utility.trace('RA Record Formatting started ');
  hr_utility.trace('Format_SQWL_RA_Record Begin for Company '|| p_input_7);
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
-- EIN Validation
   IF p_input_40 = 'FLAT' THEN
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
      hr_utility.trace('Valid EIN '||l_emp_ein);
-- Validation Ends
--
-- Formatiing Starts
      /*Pos:3-11 EIN blank for LA,NH SQWL. */

      IF ((p_report_qualifier = 'LA_SQWL')OR
          (p_report_qualifier = 'NH_SQWL'))  THEN
         l_emp_ein := lpad(' ',9);
      END IF;

      /* Pos:12 - 216 blank for PA. */

      IF ((p_report_qualifier = 'LA_SQWL')OR
          (p_report_qualifier = 'NH_SQWL')OR
          (p_report_qualifier = 'SC_SQWL')OR
          (p_report_qualifier = 'NY_SQWL') OR
          (p_report_qualifier = 'NV_SQWL')OR
          (p_report_qualifier = 'VA_SQWL')) THEN
--{
         l_pin := lpad(' ',17);
         r_input_4 := lpad(' ',1);
         r_input_5 := lpad(' ',6);
         r_input_6 := lpad(' ',2);
         r_input_7 := lpad(' ',57);
         r_input_8 := lpad(' ',22);
         r_input_9 := lpad(' ',22);
         r_input_10 := lpad(' ',22);
         r_input_11 := lpad(' ',2);
         r_input_12 := lpad(' ',5);
         r_input_13 := lpad(' ',4);
         r_input_14 := lpad(' ',23);
         r_input_15 := lpad(' ',15);
         r_input_16 := lpad(' ',2);
         r_input_24 := lpad(' ',23);
         r_input_25 := lpad(' ',15);
         r_input_26 := lpad(' ',2);

         IF ((p_report_qualifier = 'NH_SQWL')OR
             (p_report_qualifier = 'SC_SQWL')) THEN
--{
            r_input_17 := lpad(' ',57);
            r_input_18 := lpad(' ',22);
            r_input_19 := lpad(' ',22);
            r_input_20 := lpad(' ',22);
            r_input_21 := lpad(' ',2);
            r_input_22 := lpad(' ',5);
            r_input_23 := lpad(' ',4);
--}
         END IF;

         IF (p_report_qualifier = 'NY_SQWL') THEN
		    l_pin      := lpad(' ',15);
			r_input_23 := lpad(' ',4);
         ELSIF (p_report_qualifier = 'NV_SQWL') THEN
                    l_pin := '0';
		    l_pin      := rpad(substr(l_pin,1,17),17,'0');
         END IF;
--}
      ELSE
         l_pin := rpad(substr(nvl(p_input_3,' '),1,17),17);
         hr_utility.trace(' l_pin = '||l_pin);
--}
      END IF;

      IF ( p_report_qualifier = 'AL_SQWL' ) THEN
           r_input_4    := lpad(' ', 1) ;
	   r_input_5    := lpad(' ', 6) ;
	   r_input_6    := lpad('99', 2) ;
      END IF;

      /* Position : 12 - 35, 438-442, 446-485, 489-498 Blank For Texas (Bug# 4559359) */
      IF ( p_report_qualifier = 'TX_SQWL' ) THEN
           l_pin        := lpad(' ', 17) ;
           r_input_4    := lpad(' ', 1) ;
	   r_input_5    := lpad(' ', 6) ;
	   r_input_6    := lpad('99', 2) ;
	   r_input_29   := lpad(' ', 5) ;
	   r_input_30   := lpad(' ', 40) ;
	   r_input_31   := lpad(' ', 10) ;
      END IF ;

      /* Pos:38-94 Company name. Pos:489-498 Fax blank for SC_SQWL. */
      IF p_report_qualifier = 'SC_SQWL' THEN
         r_input_7 := p_input_7;
         r_input_31 := lpad(' ',10);
      END IF;

      /* Pos:489-498 Fax,Pos:446-485 Email blank for LA_SQWL. */
      IF p_report_qualifier = 'LA_SQWL' THEN
         r_input_30 := lpad(' ',40);
         r_input_31 := lpad(' ',10);
      END IF;

      /* Checking for preferred method of problem notification code which is
         1=email, 2=fax, 3=postal service, 4=OWRS  */
      IF ((p_input_32 = '1' ) OR
          (p_input_32 = '2' )  OR
          (p_input_32 = '3' )  OR
          (p_input_32 = '4' )  )  THEN
         hr_utility.trace('Preferred method of code is correct. it is '||p_input_32);
         l_pblm_code:= p_input_32;
      ELSE
         hr_utility.trace('Preferred method of code is incorrect. it is '||p_input_32);
         l_pblm_code:= lpad(' ',1);
      END IF;

      If( (p_input_33 = 'A' )OR
          (p_input_33 = 'S' )OR
          (p_input_33 = 'L' )OR
          (p_input_33 = 'P' )OR
          (p_input_33 = 'O' ))   THEN
        l_preparer_code:= p_input_33;
        hr_utility.trace('l_preparer_code  is correct. it is '||p_input_33);
      ELSE
        IF (p_report_qualifier = 'AL_SQWL') THEN
           l_preparer_code := lpad('O',1);
	ELSE
           l_preparer_code:= lpad(' ',1);
        END IF;
        hr_utility.trace('l_preparer_code  is incorrect. it is '||p_input_33);
      END IF;

      IF ((p_report_qualifier = 'LA_SQWL')OR
          (p_report_qualifier = 'NH_SQWL')OR
          (p_report_qualifier = 'SC_SQWL')OR
	  (p_report_qualifier = 'TX_SQWL') /* Bug# 4559359 */
	 )
      THEN
	 l_pblm_code:= lpad(' ',1);
         l_preparer_code:= lpad(' ',1);
      ELSIF (p_report_qualifier = 'NV_SQWL') THEN
         l_pblm_code:= lpad(' ',1);
         l_preparer_code:= lpad('O',1);
      END IF;

      IF (p_report_qualifier = 'FL_SQWL') THEN
         l_pin := rpad(substr(nvl(p_input_3,' '),1,8),17);
         r_input_4 := lpad(' ',1);
         r_input_5 := lpad(' ',6);
         r_input_6 := lpad(' ',2);
         r_input_8 := lpad(' ',22);
         r_input_9 := lpad(' ',22);
         r_input_10 := lpad(' ',22);
         r_input_11 := lpad(' ',2);
         r_input_12 := lpad(' ',5);
         r_input_13 := lpad(' ',4);
         r_input_14 := lpad(' ',23);
         r_input_15 := lpad(' ',15);
         r_input_16 := lpad(' ',2);
         r_input_17 := lpad(' ',57);
         r_input_18 := lpad(' ',22);
         r_input_19 := lpad(' ',22);
         r_input_20 := lpad(' ',22);
         r_input_21 := lpad(' ',2);
         r_input_22 := lpad(' ',5);
         r_input_23 := lpad(' ',4);
         r_input_24 := lpad(' ',23);
         r_input_25 := lpad(' ',15);
         r_input_26 := lpad(' ',2);
         l_pblm_code:= lpad(' ',1);
         l_preparer_code:= lpad(' ',1);
         l_end_of_rec   := p_end_of_rec;
      ELSIF (p_report_qualifier = 'VA_SQWL') THEN
	     r_input_7 := p_input_7;
         r_input_18 := lpad(' ',22);
		 r_input_29 := lpad(' ',5);
		 r_input_30 := lpad(' ',40);
         r_input_31 := lpad(' ',10);

      ELSIF (p_report_qualifier = 'KS_SQWL') THEN /*6036926 */
         r_input_4 := lpad(' ',1);
         r_input_5 := lpad(' ',6);
         r_input_6 := lpad(' ',2);
         r_input_8 := lpad(' ',22);
        /* r_input_11 := lpad(' ',2);
         r_input_12 := lpad(' ',5); */  /*Bug 6277029*/
         r_input_13 := lpad(' ',4);
         r_input_14 := lpad(' ',23);
         r_input_15 := lpad(' ',15);
         r_input_16 := lpad(' ',2);
         r_input_18 := lpad(' ',22);
         /* r_input_21 := lpad(' ',2);
         r_input_22 := lpad(' ',5); */  /*Bug 6277029*/
         r_input_23 := lpad(' ',4);
         r_input_24 := lpad(' ',23);
         r_input_25 := lpad(' ',15);
         r_input_26 := lpad(' ',2);
         r_input_30 := lpad(' ',40);
         r_input_31 := lpad(' ',10);
         l_pblm_code:= lpad(' ',1);
         l_preparer_code:= lpad(' ',1);
      END IF;

      hr_utility.trace('p_input_40 = '||p_input_40);
      IF (p_report_qualifier = 'NY_SQWL') THEN
          /* Bug 3527986 Removed Delimiters fro NY */
          --l_end_of_rec   := p_end_of_rec;
         return_value:='RA'
                       ||l_emp_ein||l_pin
                       ||rpad(substr(nvl(r_input_4,'0'),1,1),1)
                       ||rpad(substr(nvl(r_input_5,' '),1,6),6)
                       ||rpad(substr(nvl(r_input_6,' '),1,2),2)
                       ||rpad(substr(nvl(r_input_7,' '),1,57),57)
                       ||rpad(substr(nvl(r_input_8,' '),1,22),22)
                       ||rpad(substr(nvl(r_input_9,' '),1,22),22)
                       ||rpad(substr(nvl(r_input_10,' '),1,22),22)
                       ||rpad(substr(nvl(r_input_11,' '),1,2),2)
                       ||rpad(substr(nvl(r_input_12,' '),1,5),5)
                       ||rpad(substr(nvl(r_input_13,' '),1,4),9)
                       ||rpad(substr(nvl(r_input_14,' '),1,23),23)
                       ||rpad(substr(nvl(r_input_15,' '),1,15),15)
                       ||rpad(substr(nvl(r_input_16,' '),1,2),2)
                       ||rpad(substr(nvl(upper(r_input_17),' '),1,57),57)
                       ||rpad(substr(nvl(r_input_18,' '),1,22),22)
                       ||rpad(substr(nvl(r_input_19,' '),1,22),22)
                       ||rpad(substr(nvl(r_input_20,' '),1,22),22)
                       ||rpad(substr(nvl(r_input_21,' '),1,2),2)
                       ||rpad(substr(nvl(r_input_22,' '),1,5),5)
                       ||rpad(substr(nvl(r_input_23,' '),1,4),9)
                       ||rpad(substr(nvl(r_input_24,' '),1,23),23)
                       ||rpad(substr(nvl(r_input_25,' '),1,15),15)
                       ||rpad(substr(nvl(r_input_26,' '),1,2),2)
                       ||rpad(substr(nvl(r_input_27,' '),1,27),27)
                       ||rpad(substr(nvl(r_input_28,' '),1,15),15)
                       ||rpad(substr(nvl(r_input_29,' '),1,5),8)
                       ||rpad(substr(nvl(r_input_30,' '),1,43),43)
                       ||rpad(substr(nvl(r_input_31,' '),1,24),24)
                       ||l_end_of_rec;
      ELSE
         return_value:='RA'
                       ||l_emp_ein||l_pin
                       ||rpad(substr(nvl(r_input_4,'0'),1,1),1)
                       ||rpad(substr(nvl(r_input_5,' '),1,6),6)
                       ||rpad(substr(nvl(r_input_6,' '),1,2),2)
                       ||rpad(substr(nvl(r_input_7,' '),1,57),57)
                       ||rpad(substr(nvl(r_input_8,' '),1,22),22)
                       ||rpad(substr(nvl(r_input_9,' '),1,22),22)
                       ||rpad(substr(nvl(r_input_10,' '),1,22),22)
                       ||rpad(substr(nvl(r_input_11,' '),1,2),2)
                       ||rpad(substr(nvl(r_input_12,' '),1,5),5)
                       ||rpad(substr(nvl(r_input_13,' '),1,4),9)
                       ||rpad(substr(nvl(r_input_14,' '),1,23),23)
                       ||rpad(substr(nvl(r_input_15,' '),1,15),15)
                       ||rpad(substr(nvl(r_input_16,' '),1,2),2)
                       ||rpad(substr(nvl(upper(r_input_17),' '),1,57),57)
                       ||rpad(substr(nvl(r_input_18,' '),1,22),22)
                       ||rpad(substr(nvl(r_input_19,' '),1,22),22)
                       ||rpad(substr(nvl(r_input_20,' '),1,22),22)
                       ||rpad(substr(nvl(r_input_21,' '),1,2),2)
                       ||rpad(substr(nvl(r_input_22,' '),1,5),5)
                       ||rpad(substr(nvl(r_input_23,' '),1,4),9)
                       ||rpad(substr(nvl(r_input_24,' '),1,23),23)
                       ||rpad(substr(nvl(r_input_25,' '),1,15),15)
                       ||rpad(substr(nvl(r_input_26,' '),1,2),2)
                       ||rpad(substr(nvl(r_input_27,' '),1,27),27)
                       ||rpad(substr(nvl(r_input_28,' '),1,15),15)
                       ||rpad(substr(nvl(r_input_29,' '),1,5),8)
                       ||rpad(substr(nvl(r_input_30,' '),1,43),43)
                       ||rpad(substr(nvl(r_input_31,' '),1,10),10)
                       ||l_pblm_code
                       ||l_preparer_code
                       ||lpad(' ',12)
                       ||l_end_of_rec ;
         ret_str_len:=length(return_value);
         hr_utility.trace('---------------------FLAT----------------------------');
      END IF;
   ELSIF p_input_40 = 'CSV' THEN
      hr_utility.trace('---------------------CSV----------------------------');
      return_value:='RA'||','||p_input_2||','||p_input_3
                        ||','||rpad(substr(nvl(p_input_4,'0'),1,1),1)
                        ||','||rpad(substr(nvl(p_input_5,' '),1,6),6)
                        ||','||rpad(substr(nvl(p_input_6,' '),1,2),2)
                        ||','||rpad(substr(nvl(p_input_7,' '),1,57),57)
                        ||','||rpad(substr(nvl(p_input_8,' '),1,22),22)
                        ||','||rpad(substr(nvl(p_input_9,' '),1,22),22)
                        ||','||rpad(substr(nvl(p_input_10,' '),1,22),22)
                        ||','||rpad(substr(nvl(p_input_11,' '),1,2),2)
                        ||','||rpad(substr(nvl(p_input_12,' '),1,5),5)
                        ||','||rpad(substr(nvl(p_input_13,' '),1,4),4)
                        ||','||lpad(' ',5)
                        ||','||rpad(substr(nvl(p_input_14,' '),1,23),23)
                        ||','||rpad(substr(nvl(p_input_15,' '),1,15),15)
                        ||','||rpad(substr(nvl(p_input_16,' '),1,2),2)
                        ||','||rpad(substr(upper(p_input_17),1,57),57)
                        ||','||rpad(substr(nvl(p_input_18,' '),1,22),22)
                        ||','||rpad(substr(nvl(p_input_19,' '),1,22),22)
                        ||','||rpad(substr(nvl(p_input_20,' '),1,22),22)
                        ||','||rpad(substr(nvl(p_input_21,' '),1,2),2)
                        ||','||rpad(substr(nvl(p_input_22,' '),1,5),5)
                        ||','||rpad(substr(nvl(p_input_23,' '),1,4),4)
                        ||','||lpad(' ',5)
                        ||','||rpad(substr(nvl(p_input_24,' '),1,23),23)
                        ||','||rpad(substr(nvl(p_input_25,' '),1,15),15)
                        ||','||rpad(substr(nvl(p_input_26,' '),1,2),2)
                        ||','||rpad(substr(nvl(p_input_27,' '),1,27),27)
                        ||','||rpad(substr(nvl(p_input_28,' '),1,15),15)
                        ||','||rpad(substr(nvl(p_input_29,' '),1,5),5)
                        ||','||lpad(' ',3)
                        ||','||rpad(substr(nvl(p_input_30,' '),1,40),40)
                        ||','||lpad(' ',3)
                        ||','||rpad(substr(nvl(p_input_31,' '),1,10),10)
                        ||','||p_input_32
                        ||','||p_input_33
                        ||','||lpad(' ',12);
      hr_utility.trace('---------------------CSV----------------------------');
      hr_utility.trace(return_value);
   END IF;
   p_error := l_exclude_from_output_chk;
   ret_str_len:=length(return_value);
   return return_value;
END format_SQWL_RA_record; -- End of formatting SQWL RA Record
--
-- Formatting RE record for SQWL reporting
--
   /* Record Identifier              --> p_input_1,
      Tax Year                       --> p_input_2,
      Agent Indicator Code           --> p_input_3,
      Employer / Agent Employer Identification Number (EIN) -->p_input_4,
      Agent For EIN                  --> p_input_5,
      Terminating Business Indicator --> p_input_6,
      Establishment Number           --> p_input_7,
      Other EIN                      --> p_input_8,
      Employer Name                  --> p_input_9,
      Location Address               --> p_input_10,
      Delivery Address               --> p_input_11,
      City                           --> p_input_12,
      State Abbreviation             --> p_input_13,
      Zip Code                       --> p_input_14,
      Zip Code Extension             --> p_input_15,
      Blank,
      Foreign State / Provinc        --> p_input_16
      Foreign Postal Code            --> p_input_17,
      Country Code                   --> p_input_18,
      Employment Code                --> p_input_19,
      Tax Jurisdiction Code          --> p_input_20,
      Third Party Sick Pay Indicator --> p_input_21,
      Texas Specific Fields :
      TWC Account Number(SUI ER Acct)--> p_input_30,
      Qtr and Yr MMYYYY              --> p_input_31,
      Tax Rate Decimal Point         --> p_input_32,
      NAICS Code                     --> p_input_33
   */
--
FUNCTION format_SQWL_RE_record(
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

p_end_of_rec               varchar2(20);
BEGIN
p_end_of_rec   := fnd_global.local_chr(13)||fnd_global.local_chr(10);
   hr_utility.trace('RE Record Formatting started ');
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

   IF p_record_name = 'RE' THEN -- p_record_name
--{
      /* Check for agent indicator code p_input_3 */
      IF p_input_3 = 'Y'  THEN
         hr_utility.trace('agent indicator is Y');
         l_agent_indicator := '1';
         l_emp_ein   := p_input_5;
         l_agent_ein := p_input_4;
      ELSE
         l_agent_indicator:=lpad(' ','1');
         hr_utility.trace('agent indicator is not 1');
         l_emp_ein   := p_input_4;
         l_agent_ein := lpad(' ',9);
      END IF;

      IF p_input_6 = 'Y' THEN
         l_term_indicator:='1';
      ELSE
            l_term_indicator:='0';
      END IF;

      IF ((p_report_qualifier = 'LA_SQWL') OR /*Added SQWL. */
          (p_report_qualifier = 'MD_SQWL') OR
          (p_report_qualifier = 'NH_SQWL') OR
          (p_report_qualifier = 'SC_SQWL') OR
          (p_report_qualifier = 'OR_SQWL') OR
	  (p_report_qualifier = 'CA_SQWL') OR
	  (p_report_qualifier = 'NY_SQWL') OR
	  (p_report_qualifier = 'NC_SQWL') OR
	  (p_report_qualifier = 'FL_SQWL') OR
	  (p_report_qualifier = 'NE_SQWL') OR      /*Bug 5189831*/
	  (p_report_qualifier = 'KS_SQWL') OR      /*Bug 6036926*/
	  (p_report_qualifier = 'AL_SQWL')) THEN /* Bug 4552131 */
--{
          l_agent_indicator := lpad(' ',1);
          l_other_ein       := lpad(' ',9);
          l_agent_ein       := lpad(' ',9);
          l_term_indicator  := lpad(' ',1);
          l_emp_ein         := p_input_4;
          r_input_7         := lpad(' ',4);
          r_input_8         := l_other_ein;
--}
      END IF;

      IF ((p_report_qualifier = 'MD_SQWL') OR /*Added SQWL. */
          (p_report_qualifier = 'OR_SQWL') OR
          (p_report_qualifier = 'NH_SQWL') OR
          (p_report_qualifier = 'NC_SQWL') OR
          (p_report_qualifier = 'SC_SQWL') OR
          (p_report_qualifier = 'CA_SQWL')) THEN
--{
          l_emp_ein := lpad(' ',9);
--}
      END IF;

      /* Pos:3-6 blank for OR_SQWL */

      IF (p_report_qualifier = 'OR_SQWL' OR
          p_report_qualifier = 'CA_SQWL' OR
          p_report_qualifier = 'NY_SQWL' OR
          p_report_qualifier = 'NC_SQWL' OR
	  p_report_qualifier = 'KS_SQWL' OR /* 6036926 */
          p_report_qualifier = 'FL_SQWL') THEN
--{
          r_input_2 := lpad(' ',4);
--}
      END IF;

      /* OH RITA Other EIN. */
      If (p_report_qualifier = 'NH_SQWL') THEN

	 r_input_8 := p_input_8;

      END IF;

      IF p_input_40 = 'FLAT' THEN
--{
--    Validation for RE Record starts
--    These validation are used only for mf file only.
--    not for any of the audit report
--
         hr_utility.trace('before data_validation of ein');
         l_emp_ein :=
             pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                        p_report_type,
                                                        p_format,
                                                        p_report_qualifier,
                                                        p_record_name,
                                                        'EIN',
                                                        l_emp_ein,
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

         IF l_agent_indicator = '1' THEN
--{
            l_agent_ein :=
              pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                         p_report_type,
                                                         p_format,
                                                         p_report_qualifier,
                                                         p_record_name,
                                                         'EIN',
                                                         l_agent_ein,
                                                         'Agent EIN',
                                                         p_input_9,
                                                         null,
                                                         p_validate,
                                                         p_exclude_from_output,
                                                         sp_out_1,
                                                         sp_out_2);
            IF p_exclude_from_output = 'Y' THEN
               l_exclude_from_output_chk := TRUE;
            END IF;
--}
         END IF; -- agent_indicator

         hr_utility.trace('after data_validation of EIN');
         l_input_8 := replace(r_input_8,' ');

         IF l_input_8 IS NOT NULL THEN --Checking Other EIN for validation
--{
            hr_utility.trace('before data_validation of other EIN');
            l_other_ein:=
              pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                         p_report_type,
                                                         p_format,
                                                         p_report_qualifier,
                                                         p_record_name,
                                                         'EIN',
                                                         p_input_8,
                                                         'Other EIN',
                                                         p_input_9,
                                                         null,
                                                         p_validate,
                                                         p_exclude_from_output,
                                                         sp_out_1,
                                                         sp_out_2
                                                        );
            hr_utility.trace('after data_validation of Other EIN');
            IF p_exclude_from_output = 'Y' THEN
               l_exclude_from_output_chk := TRUE;
            END IF;
--}
         ELSE
            l_other_ein:= lpad(' ',9);
         END IF; --Checking Other EIN for validation
--
-- Validation for RE record ends here

-- Formatting for mf file
--
         IF ( p_report_qualifier = 'TX_SQWL' ) THEN /* Bug# 4559359 */
              r_input_7     := lpad(' ', 4) ;
              r_input_16    := lpad(' ', 23) ;
	      r_input_17    := lpad(' ', 15) ;
	      r_input_18    := lpad(' ', 2) ;
	      r_input_19    := lpad(' ', 1) ;
	      r_input_20    := lpad(' ', 1) ;
	      r_input_21    := lpad(' ', 1) ;
	 END IF ;

         IF p_report_qualifier = 'NY_SQWL' THEN
  	        l_agent_ein := lpad(' ',7);
		    r_input_15 :=  lpad(' ',4);
	  	    r_input_19 := lpad(' ',1);
         END IF;

         /* Pos:40 - 173 Blank for MD,OR SQWL. */

         IF ((p_report_qualifier = 'MD_SQWL') OR
             (p_report_qualifier = 'OR_SQWL') OR
             (p_report_qualifier = 'NE_SQWL')  /*Bug 5189831*/
	     ) THEN
--{
             r_input_9 := lpad(' ',57);
             r_input_10 := lpad(' ',22);
             r_input_11 := lpad(' ',22);
             r_input_12 := lpad(' ',22);
             r_input_13 := lpad(' ',2);
             r_input_14 := lpad(' ',5);
             r_input_15 := lpad(' ',4);
--}
          END IF;

          /* Pos:97-108 Location address blank for NC SQWL. */

          IF p_report_qualifier = 'NC_SQWL' OR
	     p_report_qualifier = 'KS_SQWL'THEN  /* Bug 6036926 */
             r_input_10 := lpad(' ',22);
          END IF;

          IF ((p_report_qualifier = 'FL_SQWL') OR
              (p_report_qualifier = 'VA_SQWL')) THEN
	         r_input_10 := lpad(' ',22);
          END IF;

          /* MD_SQWL Pos:3-6 Tax year blank and Pos:163-164 not blank. */
          IF p_report_qualifier = 'MD_SQWL' THEN
             r_input_2 := lpad(' ',4);
             r_input_13 := rpad(substr(nvl(p_input_13,' '),1,2),2);
          END IF;

	  /* Pos:163-164 not blank. */
          IF p_report_qualifier = 'AL_SQWL' THEN
             r_input_13 := 'AL';
          END IF;
	  /* Pos:163-173 blank for 'KS' Bug 6036926 */
           IF (p_report_qualifier = 'KS_SQWL') THEN
	        /* r_input_13 := lpad(' ',2);
	         r_input_14 := lpad(' ',5); */ /*6277029*/
	         r_input_15 := lpad(' ',4);
          END IF;

	  /* foreign adrs,emp_code, third_party,tax_jurisdiction formatting */
          IF ((p_report_qualifier = 'MD_SQWL') OR
              (p_report_qualifier = 'LA_SQWL') OR
              (p_report_qualifier = 'SC_SQWL') OR
              (p_report_qualifier = 'OR_SQWL') OR
              (p_report_qualifier = 'CA_SQWL') OR
	      (p_report_qualifier = 'NY_SQWL') OR
	      (p_report_qualifier = 'FL_SQWL') OR
	      (p_report_qualifier = 'NE_SQWL') OR  /* Bug# 5189831*/
	      (p_report_qualifier = 'KS_SQWL') OR  /* Bug# 6036926*/
	      (p_report_qualifier = 'VA_SQWL')) THEN
--{
             r_input_16 := lpad(' ',23);
             r_input_17 := lpad(' ',15);
             r_input_18 := lpad(' ',2);
             r_input_20 := lpad(' ',1);
             r_input_21 := lpad(' ',1);

             IF ((p_report_qualifier = 'MD_SQWL') OR
                 (p_report_qualifier = 'LA_SQWL') OR
                 (p_report_qualifier = 'SC_SQWL') OR
                 (p_report_qualifier = 'OR_SQWL') OR
                 (p_report_qualifier = 'NE_SQWL') OR  /* Bug# 5189831*/
		 (p_report_qualifier = 'KS_SQWL') OR  /* Bug# 6036926*/
                 (p_report_qualifier = 'CA_SQWL')) THEN

		r_input_19 := lpad(' ',1);

             END IF;-- AL,PA emp_code blank
--}
          END IF;

          /* Pos:217-218 Country code blank for NH_SQWL. */
          IF p_report_qualifier = 'NH_SQWL' OR
	     p_report_qualifier = 'KS_SQWL' THEN  /* Bug# 6036926*/
             r_input_18 := lpad(' ',2);
          END IF;

          /* Pos:219 - 221 blank for NH and NC SQWL */
          IF ((p_report_qualifier = 'NH_SQWL') OR
              (p_report_qualifier = 'NV_SQWL') OR
              (p_report_qualifier = 'NC_SQWL') OR
	      (p_report_qualifier = 'KS_SQWL') OR /* Bug# 6036926 */
	      (p_report_qualifier = 'AL_SQWL')) THEN /* Bug# 4552131 */
--{
              r_input_19 := lpad(' ',1);
              r_input_20 := lpad(' ',1);
              r_input_21 := lpad(' ',1);
	--}
          END IF;

          IF p_report_qualifier = 'LA_SQWL' THEN
--{
             r_input_21 := p_input_21;
             r_input_22 := rpad(nvl(r_input_22,' '),2);
             r_input_23 := rpad(nvl(r_input_23,' '),6);
             r_input_24 := lpad(' ',2);
             /*Bug: 2324869 */
             r_input_25 := rpad(substr(replace(
                   pay_us_reporting_utils_pkg.character_check(nvl(r_input_25,
                                              ' ')),'-'),1,6),12,0);
             /*Pos:250 - 253 Not supported. Zero Fill. */
             r_input_26 := '0';
             r_input_27 := '0';
             r_input_28 := '0';
             r_input_29 := '0';
--}
          ELSE
--{
             r_input_22 := lpad(' ',2);
             r_input_23 := lpad(' ',6);
             r_input_24 := lpad(' ',2);
             r_input_25 := lpad(' ',12);
             r_input_26 := lpad(' ',1);
             r_input_27 := lpad(' ',1);
             r_input_28 := lpad(' ',1);
             r_input_29 := lpad(' ',1);

             IF  p_report_qualifier = 'NY_SQWL' THEN
               IF substr(p_input_23,1,2) = '03' THEN
                  l_rep_prd := 1;
               ELSIF substr(p_input_23,1,2) = '06' THEN
                  l_rep_prd := 2;
               ELSIF substr(p_input_23,1,2) = '09' THEN
                  l_rep_prd := 3;
               ELSIF substr(p_input_23,1,2) = '12' THEN
                  l_rep_prd := 4;
               END IF;
               l_rep_qtr :=  rpad(l_rep_prd,1) ||rpad(nvl(substr(p_input_23,3,4),' '),4);
             ELSE
               l_rep_qtr := ' ';
               l_rep_prd := ' ';
             END IF;
--}
          END IF;

          IF (p_report_qualifier = 'VA_SQWL') THEN
             l_term_indicator := lpad(' ',1);
          END IF;
             /* Bug 3527986 */
             /*
	      IF ((p_report_qualifier = 'FL_SQWL') OR
                  (p_report_qualifier = 'NY_SQWL')) THEN
		     l_end_of_rec   := p_end_of_rec;
	      END IF;
              */

	 IF (p_report_qualifier = 'FL_SQWL') THEN
	    l_end_of_rec   := p_end_of_rec;
	 END IF;

          IF ( p_report_qualifier = 'TX_SQWL' ) THEN /* Bug# 4559359 */
	       r_input_29 := r_input_29 ||
	                     lpad(' ', 46) ||
	                     rpad(substr(nvl(r_input_30,' '),1,9),9) ||
                             rpad(substr(nvl(r_input_31,' '),1,6),6) ||
			     rpad(' ',1) ||
			     lpad(substr(nvl(r_input_32,'0'),1,5),5,'0') ||
			     rpad(' ',1) ||
			     lpad(' ',6)  ; /* NAICS Code */
       	  END IF ;

          r_input_30 := lpad(' ',8);


	IF  p_report_qualifier = 'NY_SQWL' THEN
--{
              return_value := 'RE'
                              ||rpad(substr(nvl(r_input_2,' '),1,4),4)
                              ||l_agent_indicator
                              ||l_emp_ein||l_agent_ein
                              ||l_term_indicator
                              ||rpad(substr(nvl(r_input_7,' '),1,4),4)
                              ||l_other_ein
                              ||rpad(substr(nvl(upper(r_input_9),' '),1,79),79)
                              ||rpad(substr(nvl(r_input_11,' '),1,22),22)
                              ||rpad(substr(nvl(r_input_12,' '),1,22),22)
                              ||rpad(substr(nvl(r_input_13,' '),1,2),2)
                              ||rpad(substr(nvl(r_input_14,' '),1,5),5)
                              ||rpad(substr(nvl(r_input_15,' '),1,4),4)
			      ||rpad(substr(nvl(l_rep_qtr,' '),1,5),5)
                              ||rpad(substr(nvl(r_input_16,' '),1,23),23)
                              ||rpad(substr(nvl(r_input_17,' '),1,15),15)
                              ||rpad(substr(nvl(r_input_18,' '),1,2),2)
                              ||rpad(nvl(r_input_19,' '),1)
                              ||rpad(nvl(r_input_20,' '),1)
                              ||rpad(nvl(r_input_21,' '),1)
                              ||r_input_22
                              ||r_input_23
                              ||rpad(r_input_24,5)
                              ||rpad(r_input_25,15)
                              ||r_input_26
                              ||r_input_27
                              ||r_input_28
                              ||rpad(r_input_29,252)
                              ||r_input_30
                              ||l_end_of_rec;
--}
          ELSE
--{
              return_value := 'RE'
                              ||rpad(substr(nvl(r_input_2,' '),1,4),4)
                              ||l_agent_indicator
                              ||l_emp_ein||l_agent_ein
                              ||l_term_indicator
                              ||rpad(substr(nvl(r_input_7,' '),1,4),4)
                              ||l_other_ein
                              ||rpad(substr(nvl(upper(r_input_9),' '),1,57),57)
                              ||rpad(substr(nvl(r_input_10,' '),1,22),22)
                              ||rpad(substr(nvl(r_input_11,' '),1,22),22)
                              ||rpad(substr(nvl(r_input_12,' '),1,22),22)
                              ||rpad(substr(nvl(r_input_13,' '),1,2),2)
                              ||rpad(substr(nvl(r_input_14,' '),1,5),5)
                              ||rpad(substr(nvl(r_input_15,' '),1,4),9)
                              ||rpad(substr(nvl(r_input_16,' '),1,23),23)
                              ||rpad(substr(nvl(r_input_17,' '),1,15),15)
                              ||rpad(substr(nvl(r_input_18,' '),1,2),2)
                              ||rpad(nvl(r_input_19,'R'),1)
                              ||rpad(nvl(r_input_20,' '),1)
                              ||rpad(nvl(r_input_21,'0'),1)
                              ||r_input_22
                              ||r_input_23
                              ||rpad(r_input_24,5)
                              ||rpad(r_input_25,15)
                              ||r_input_26
                              ||r_input_27
                              ||r_input_28
                              ||rpad(r_input_29,252)
                              ||r_input_30
                              ||l_end_of_rec;
--}
          END IF;
          ret_str_len:=length(return_value);
--}
      ELSIF p_input_40 = 'CSV' THEN
--{
            return_value:= 'RE'
                           ||','||rpad(substr(p_input_2,1,4),4)
                           ||','||l_agent_indicator
                           ||','||l_emp_ein
                           ||','||l_agent_ein
                           ||','||l_term_indicator
                           ||','||rpad(substr(nvl(p_input_7,' '),1,4),4)
                           ||','||p_input_8
                           ||','||rpad(substr(nvl(upper(p_input_9),' '),1,57),57)
                           ||','||rpad(substr(nvl(p_input_10,' '),1,22),22)
                           ||','||rpad(substr(nvl(p_input_11,' '),1,22),22)
                           ||','||rpad(substr(nvl(p_input_12,' '),1,22),22)
                           ||','||rpad(substr(nvl(p_input_13,' '),1,2),2)
                           ||','||rpad(substr(nvl(p_input_14,' '),1,5),5)
                           ||','||rpad(substr(nvl(p_input_15,' '),1,4),4)
                           ||','||lpad(' ',5)
                           ||','||rpad(substr(nvl(p_input_16,' '),1,23),23)
                           ||','||rpad(substr(nvl(p_input_17,' '),1,15),15)
                           ||','||rpad(substr(nvl(p_input_18,' '),1,2),2)
                           ||','||rpad(nvl(p_input_19,'R'),1)
                           ||','||rpad(nvl(p_input_20,' '),1)
                           ||','||rpad(nvl(p_input_21,'0'),1)
                           ||','||p_input_22
                           ||','||p_input_23
                           ||','||p_input_24
                           ||','||lpad(' ',3)
                           ||','||p_input_25
                           ||','||lpad(' ',3)
                           ||','||p_input_26
                           ||','||p_input_27
                           ||','||p_input_28
                           ||','||p_input_29
                           ||','||p_input_30;
--}
      END IF;
END IF;
   p_error := l_exclude_from_output_chk;
   ret_str_len:=length(return_value);
   return return_value;
END format_SQWL_RE_record; -- End of Function Formatting RE record

/*  ------------ Parameter mapping for SQWL RS Record  -------------
--{
  Record Identifier                                   --> p_input_1
  State Code                                          --> p_input_2
  Taxing Entity Code                                  --> p_input_3
  Social Security Number (SSN)                        --> p_input_4
  Employee First Name                                 --> p_input_5
  Employee Middle Name or Initial                     --> p_input_6
  Employee Last Name                                  --> p_input_7
  Suffix                                              --> p_input_8
  Location Address                                    --> p_input_0
  Delivery Address                                    --> p_input_10
  City                                                --> p_input_11
  State Abbreviation                                  --> p_input_12
  Zip Code                                            --> p_input_13
  Zip Code Extension                                  --> p_input_14
  Foreign State / Province                            --> p_input_15
  Foreign Postal Code                                 --> p_input_16
  Country Code                                        --> p_input_17
  Optional Code                                       --> p_input_18
  Reporting Period                                    --> p_input_19
  State Quarterly Unemployment Insurance Total Wages  --> p_input_20
  State Quarterly Unemployment Total Taxable Wages    --> p_input_21
  Number of Weeks Worked                              --> p_input_22
  Date First Employed                                 --> p_input_23
  Date of Separation                                  --> p_input_24
  State Employer Account Number                       --> p_input_25
  State Code                                          --> p_input_26
  State Taxable Wages                                 --> p_input_27
  SIT Withheld                                        --> p_input_28
  Other State Data                                    --> p_input_29
  Tax Type Code                                       --> p_input_30
  Local Taxable Wages                                 --> p_input_31
  Local Income Tax Withheld                           --> p_input_32
  State Control Number                                --> p_input_33
  Supplemental Data 1                                 --> p_input_34
  Supplemental Data 2                                 --> p_input_35
--}
*/

FUNCTION format_SQWL_RS_record(
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
l_carate_1_position            number := 0 ;
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
l_end_of_rec                   varchar2(20);
p_end_of_rec               varchar2(20);
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

/* Bug 4170713 */
l_pos_260                      varchar2(1) ;
l_pos_261                      varchar2(1) ;
l_pos_262                      varchar2(1) ;

/* Bug# 1236643 */
l_st_er_acct_no                varchar2(300) ;
l_er_unit_no                   varchar2(300) ;

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
p_end_of_rec   := fnd_global.local_chr(13)||fnd_global.local_chr(10);
   hr_utility.trace('Formatting RS record for SQWL ');
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

   l_state_length := length(replace(p_input_2,' ')); /* Fix for State code.*/

   IF l_state_length < 2 THEN

      r_input_2 := lpad(replace(p_input_2,' '),2,0);
      r_input_26 := lpad(replace(p_input_26,' '),2,0);

      hr_utility.trace('l_state_length = '||to_char(l_state_length));
      hr_utility.trace('l_state_length < 2.State code r_input_2 = '||r_input_2);
      hr_utility.trace('State code r_input_26 = '||r_input_26);
   END IF;

   /* Pos:3 - 4 State Code Blank for GA SQWL, State Abbreviation for AL SQWL */
   IF  (p_report_qualifier = 'GA_SQWL') OR
       (p_report_qualifier = 'KS_SQWL') THEN  /* Bug 6036926 */
      r_input_2 := lpad(' ',2);
   ELSIF ( p_report_qualifier = 'AL_SQWL') THEN /* Bug# 4552131 */
      r_input_2 := 'AL' ;
   ELSE
      r_input_2 := rpad(nvl(r_input_2,' '),2);
   END IF;

   /* Pos:5 - 9 Taxing entity code blank for all the states except AZ_SQWL/TX_SQWL. */

   IF ( p_report_qualifier = 'AZ_SQWL' ) THEN
        r_input_3 := rpad(substr(nvl(r_input_3,' '),1,5),5);
   ELSIF  p_report_qualifier = 'TX_SQWL' THEN /* Bug# 4559359 */
        r_input_3 := rpad('UTAX',5);
   ELSIF  p_report_qualifier = 'VA_SQWL' THEN
	  r_input_3 := rpad('B',5);
   ELSIF  p_report_qualifier = 'NV_SQWL' THEN
	  r_input_3 := rpad('WAGE',5);
   ELSIF  p_report_qualifier = 'FL_SQWL' THEN
      r_input_3 := rpad(substr(nvl(r_input_3,' '),1,2),5);
      l_end_of_rec   := p_end_of_rec;
   ELSE
      r_input_3 := lpad(' ',5);
   END IF;

   /* Pos:10 - 18 Social security number */

   IF p_input_40 = 'FLAT' THEN
      l_ssn := pay_us_reporting_utils_pkg.data_validation(
                                p_effective_date,
                                p_report_type,
                                p_format,
                                p_report_qualifier,
                                p_record_name,
                                'SSN',
                                r_input_4,
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
      l_ssn := replace(replace(r_input_4,'-'),',');
   END IF;

   hr_utility.trace('SSN after Validation and Formatting = '||l_ssn);


   IF p_report_qualifier = 'LA_SQWL' THEN
--{
   /* Pos:19 - 38 Last name
      Pos:39 - 53 First name
      Pos:54 - 68 Middle name
      Pos:69 - 72 suffix Blank  */

      /* Last name. p_input_7 */
      l_first_name := pay_us_reporting_utils_pkg.Character_check(rpad(nvl(substr(r_input_7,1,20),' '),20));

      /* Middle Name  p_input_5 */
      l_middle_name := pay_us_reporting_utils_pkg.Character_check(rpad(nvl(substr(r_input_5,1,15),' '),15));

      /* First Name. p_input_6 */
      l_last_name :=  pay_us_reporting_utils_pkg.Character_check(rpad(nvl(substr(r_input_6,1,15),' '),15));
      l_suffix := lpad(' ',4);
--}
   ELSE
      /* Pos:19 - 33 First name
         Pos:34 - 48 Middle name
         Pos:49 - 68 Last name
         Pos:69 - 72 suffix  */

      l_first_name := pay_us_reporting_utils_pkg.Character_check(rpad(
                                    nvl(substr(r_input_5,1,15),' '),15));
      l_middle_name := pay_us_reporting_utils_pkg.Character_check(rpad(
                                    nvl(substr(r_input_6,1,15),' '),15));
      l_last_name :=  pay_us_reporting_utils_pkg.Character_check(rpad(
                                    nvl(substr(r_input_7,1,20),' '),20));
      l_suffix := pay_us_reporting_utils_pkg.Character_check(rpad(
                                    nvl(substr(r_input_8,1,4),' '),4));
   END IF;
   hr_utility.trace('l_suffix = '||l_suffix);

   /* Middle Name blank for MD_SQWL. */
   IF p_report_qualifier = 'MD_SQWL' THEN
      l_middle_name := lpad(' ',15);
   END IF;

   /* Pos:69 - 149 blank for following state SQWL */
   IF ( (p_report_qualifier = 'MD_SQWL') OR
        (p_report_qualifier = 'OR_SQWL') OR
        (p_report_qualifier = 'MN_SQWL') OR
        (p_report_qualifier = 'MS_SQWL') OR
        (p_report_qualifier = 'GA_SQWL') OR
        (p_report_qualifier = 'MO_SQWL') OR
        (p_report_qualifier = 'SC_SQWL') OR
        (p_report_qualifier = 'NC_SQWL') OR
        (p_report_qualifier = 'NH_SQWL') OR
        (p_report_qualifier = 'NV_SQWL') OR
        (p_report_qualifier = 'LA_SQWL') OR
        (p_report_qualifier = 'CA_SQWL') OR
        (p_report_qualifier = 'NY_SQWL') OR
        (p_report_qualifier = 'NE_SQWL') OR /* Bug# 5189831*/
	(p_report_qualifier = 'KS_SQWL') OR /* Bug 6036926 */
        (p_report_qualifier = 'FL_SQWL')) THEN
--{
      hr_utility.trace('Pos:69 - 149 blank for AL and NC');
      l_suffix   := lpad(' ',4);
      r_input_9  := lpad(' ',22);
      r_input_10 := lpad(' ',22);
      r_input_11 := lpad(' ',22);
      r_input_12 := lpad(' ',2);
      r_input_13 := lpad(' ',5);
      r_input_14 := lpad(' ',4);
--}
   END IF;

   /* Pos:69-72 Suffix not blank for SC_SQWL. */

   IF ((p_report_qualifier = 'SC_SQWL') OR
       (p_report_qualifier = 'NY_SQWL') OR
       (p_report_qualifier = 'NV_SQWL') OR
       (p_report_qualifier = 'FL_SQWL')) THEN
      l_suffix := pay_us_reporting_utils_pkg.Character_check(rpad(
                         nvl(substr(r_input_8,1,4),' '),4));
   END IF;

   /* Pos: 73 - 149 Blank for Alabama SQWL Ref Bug# 4552131*/

   IF ( p_report_qualifier = 'TX_SQWL' ) THEN /* Bug# 4559359 */

      r_input_9  := lpad(' ',22);
      r_input_10 := lpad(' ',22);
      r_input_11 := lpad(' ',22);
      r_input_12 := lpad(' ',2);
      r_input_13 := lpad(' ',5);
      r_input_14 := lpad(' ',4);

   END IF ;
   /* Pos: 139 'AL' for Alabama SQWL Ref Bug# 7335939*/
      IF ( p_report_qualifier = 'AL_SQWL') THEN /* Bug# 7335939 */

      r_input_9  := lpad(' ',22);
      r_input_10 := lpad(' ',22);
      r_input_11 := lpad(' ',22);
      r_input_12 := lpad('AL',2);
      r_input_13 := lpad(' ',5);
      r_input_14 := lpad(' ',4);

   END IF ;

   /* Pos:155 - 177 178 - 192 193 - 194
      Foreign State / Province --> r_input_15
      Foreign Postal Code      --> r_input_16
      Country Code             --> r_input_17
      Foreign address set to blank for following states and locals */

   IF ((p_report_qualifier = 'MD_SQWL') OR
       (p_report_qualifier = 'OR_SQWL') OR
       (p_report_qualifier = 'MN_SQWL') OR
       (p_report_qualifier = 'MO_SQWL') OR
       (p_report_qualifier = 'MS_SQWL') OR
       (p_report_qualifier = 'GA_SQWL') OR
       (p_report_qualifier = 'SC_SQWL') OR
       (p_report_qualifier = 'LA_SQWL') OR
       (p_report_qualifier = 'AZ_SQWL') OR
       (p_report_qualifier = 'NC_SQWL') OR
       (p_report_qualifier = 'NH_SQWL') OR
       (p_report_qualifier = 'NV_SQWL') OR
       (p_report_qualifier = 'CA_SQWL') OR
       (p_report_qualifier = 'NY_SQWL') OR
       (p_report_qualifier = 'NE_SQWL') OR /* Bug # 5189831*/
       (p_report_qualifier = 'AL_SQWL') OR    /* AL is added for Bug# 4552131 */
       (p_report_qualifier = 'KS_SQWL') OR  /* 6036926 */
       (p_report_qualifier = 'TX_SQWL')) THEN /* TX is added for Bug# 4559359 */
--{
      r_input_15 := lpad(' ',23);
      r_input_16 := lpad(' ',15);
      r_input_17 := lpad(' ',2);
--}
   ELSE
--{
      r_input_15 := rpad(nvl(r_input_15,' '),23);
      r_input_16 := rpad(nvl(r_input_16,' '),15);
      r_input_17 := rpad(nvl(r_input_17,' '),2);
--}
   END IF;


   /* Pos:195 - 242 Optional code - Date of separation  blanks */
   /* Pos:203-226 State quarterly unemployments details should be Zero filled
                  for MO, OH and PA
      This is to fix bug # 2627606
      This is also true with many states for W2, so changes made for W2
   */
--{
   /* Pos:195-196 Optional code .
      Pos:197-202 Reporting period. */
   r_input_18 := lpad(' ',2);

   r_input_19 := rpad(nvl(p_input_19,' '),6);

   /* GA_SQWL expects state code in Pos:195-196.  */
   IF p_report_qualifier = 'GA_SQWL' THEN
      r_input_18 := lpad(replace(p_input_2,' '),2);
   ELSIF p_report_qualifier = 'MO_SQWL' THEN
      r_input_18 := '00';
   ELSIF p_report_qualifier = 'NC_SQWL' THEN
      r_input_18 :=  replace(nvl(p_input_18,'N'),'Y','S')||' ';
      hr_utility.trace('Seasonal worker for NC is '||p_input_18);
   ELSIF (p_report_qualifier = 'CA_SQWL') THEN
      r_input_18 := p_input_18||' ';
   ELSIF (p_report_qualifier = 'NY_SQWL') THEN
      r_input_18 := lpad(' ',2);
      r_input_19 := lpad(' ',6);
   END IF;

   /* Pos:203-213 SUI Insurance Wages. */
   IF p_input_40 = 'FLAT' THEN
      r_input_20 :=
        pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                   p_report_type,
                                                   p_format,
                                                   p_report_qualifier,
                                                   p_record_name,
                                                   'NEG_CHECK',
                                                   r_input_20,
                                                   'SUI Insurance Wages',
                                                   p_input_39,
                                                   null,
                                                   p_validate,
                                                   p_exclude_from_output,
                                                   sp_out_1,
                                                   sp_out_2);

      IF p_exclude_from_output = 'Y' THEN
         l_exclude_from_output_chk := TRUE;
      END IF;

      /* Pos:214-224 SUI Taxable Wages. */
      IF ((p_report_qualifier = 'AZ_SQWL') OR
          (p_report_qualifier = 'SC_SQWL') OR
	  (p_report_qualifier = 'FL_SQWL') OR
	  (p_report_qualifier = 'KS_SQWL') OR  /* Bug 6036926 */
          (p_report_qualifier = 'TX_SQWL')) THEN  /* #5919391 */
--{
         r_input_21 :=
           pay_us_reporting_utils_pkg.data_validation( p_effective_date,
                                                       p_report_type,
                                                       p_format,
                                                       p_report_qualifier,
                                                       p_record_name,
                                                       'NEG_CHECK',
                                                       r_input_21,
                                                       'SUI Taxable Wages',
                                                       p_input_39,
                                                       null,
                                                       p_validate,
                                                       p_exclude_from_output,
                                                       sp_out_1,
                                                       sp_out_2);
         IF p_exclude_from_output = 'Y' THEN
            l_exclude_from_output_chk := TRUE;
         END IF;
      END IF; /* AZ,NH,SC_SQWL */
   END IF; /* p_input_40 FLAT */

   IF ((p_report_qualifier = 'MD_SQWL') OR
       (p_report_qualifier = 'MN_SQWL') OR
       (p_report_qualifier = 'MS_SQWL') OR
       (p_report_qualifier = 'LA_SQWL') OR
       (p_report_qualifier = 'NH_SQWL') OR
       (p_report_qualifier = 'NV_SQWL') OR
       (p_report_qualifier = 'NC_SQWL') OR
       (p_report_qualifier = 'OR_SQWL') OR
       (p_report_qualifier = 'MO_SQWL') OR
       (p_report_qualifier = 'AL_SQWL')) THEN /* AL is added for Bug# 4552131 */

      r_input_21 := rpad(0,11,0);

   END IF;

   IF ( p_report_qualifier = 'TX_SQWL' ) THEN
      r_input_21 := lpad(r_input_21, 11, '0') ;
   END IF ;

   IF ((p_report_qualifier = 'CA_SQWL') OR
   	(p_report_qualifier = 'NY_SQWL')  OR
        (p_report_qualifier = 'VA_SQWL')) THEN

      r_input_21 := lpad(' ',11);
   END IF;

   IF p_report_qualifier = 'GA_SQWL'   THEN
      r_input_20 := lpad(r_input_20,11,0);
      r_input_21 := lpad(' ',11);
   END IF;

   IF p_report_qualifier = 'NE_SQWL'  THEN/* Bug# 5189831*/
        r_input_20 := lpad(r_input_20,11,0);
        r_input_21 := lpad('0',11,'0');
   END IF;

   /* Bug:2286329 Negative hours check. */
   IF ((p_report_qualifier = 'MN_SQWL') OR
       (p_report_qualifier = 'OR_SQWL')) THEN

      l_hours_worked := to_number(replace(r_input_34,' '));
      hr_utility.trace('l_hours_worked = '||to_char(l_hours_worked));

      IF l_hours_worked <0 THEN
         hr_utility.trace('Error in RS record for Employee '||p_input_1||
                          ' Negative hours');
         l_exclude_from_output_chk := TRUE;
         pay_core_utils.push_message(801,'PAY_INVALID_EE_FORMAT','A');
         pay_core_utils.push_token('record_name',p_record_name);
         pay_core_utils.push_token('name_or_number',substr(p_input_39,1,50));
         pay_core_utils.push_token('description','Negative hours');
       END IF;

   END IF; /*Hours check for OR,MN SQWL */

   /*Pos:225-226 No. of weeks worked. */
   r_input_22 := rpad(0,2,0);

   /*Pos:225-226 No. of weeks worked.Blank for SC_SQWL. */
   IF ((p_report_qualifier = 'SC_SQWL') OR
       (p_report_qualifier = 'LA_SQWL') OR
       (p_report_qualifier = 'GA_SQWL') OR
       (p_report_qualifier = 'CA_SQWL') OR
       ( p_report_qualifier = 'NY_SQWL') OR
       ( p_report_qualifier = 'NE_SQWL') OR /* Bug# 5189831*/
       ( p_report_qualifier = 'VA_SQWL') OR /* Fix.*/
       ( p_report_qualifier = 'KS_SQWL') OR /* 6036926 */
       ( p_report_qualifier = 'TX_SQWL' )) THEN /* Bug# 4559359 */

      r_input_22 :=  lpad(' ',2);
   END IF;

   /* Pos:227-234:Date First Employed,Pos:
             235-242:Date of Separation. */
   IF ( p_report_qualifier = 'TX_SQWL' ) THEN /* Bug# 4559359 */
        r_input_23   := lpad(substr(nvl(r_input_23,' '),1,8),8) ;

	if  r_input_24 <> '01010001' then
	    r_input_24   := lpad(substr(nvl(r_input_24,' '),1,8),8) ;
       else
             r_input_24 := lpad(' ',8);
       end if;

   ELSE
	r_input_23 := lpad(' ',8);
        r_input_24 := lpad(' ',8);
   END IF ;

   /* Pos:248-267 State Employer Account number */
--{
   IF ((p_report_qualifier = 'NH_SQWL') ) THEN  /* Bug:2901849 */
      r_input_25 := lpad(replace(replace(nvl(replace(r_input_25,' '),' ')
                         ,'-'),'/'),20,0);
   ELSIF p_report_qualifier = 'NC_SQWL' THEN
      r_input_25 := rpad(lpad(replace(replace(nvl(replace(r_input_25,' ')
                         ,' '),'-'),'/'),7),20);
   ELSIF p_report_qualifier = 'OR_SQWL' THEN
      l_s_hyphen_position := nvl(instr(substr(r_input_25,1,7),'-'),1) - 1 ;
      IF l_s_hyphen_position = -1  or l_s_hyphen_position > 7  then
         l_s_hyphen_position := 7;
      End IF;
      r_input_25 := lpad(nvl(substr(r_input_25,1,l_s_hyphen_position),0),7,'0')
                                    || lpad(' ',13);
   ELSIF p_report_qualifier = 'NV_SQWL'  THEN

      l_s_hyphen_position := nvl(instr(substr(r_input_25,1,9),'-'),1) - 1 ;
      IF l_s_hyphen_position = -1  or l_s_hyphen_position > 9  then
         l_s_hyphen_position := 9;
      End IF;

     r_input_25 := rpad(lpad(replace(nvl(replace(substr(r_input_25,1,l_s_hyphen_position)
                                            ,' '),' '),'.'),9,'0'),20);

   ELSIF p_report_qualifier = 'NE_SQWL'  THEN /* Bug# 5189831*/

      l_s_hyphen_position := nvl(instr(substr(r_input_25,1,10),'-'),1) - 1 ;
      IF l_s_hyphen_position = -1  or l_s_hyphen_position > 10  then
         l_s_hyphen_position := 10;
      End IF;

     r_input_25 := lpad(lpad(replace(nvl(replace(substr(r_input_25,1,l_s_hyphen_position)
                                            ,' '),' '),'.'),10,'0'),20);

   ELSIF p_report_qualifier = 'MO_SQWL' THEN

      r_input_25 := rpad(replace(replace(nvl(replace(r_input_25,' '),' ')
                         ,'-'),'/'),15)
                                    || rpad( ' ',5) ;
   ELSIF p_report_qualifier = 'GA_SQWL' THEN

      r_input_25 := lpad(' ',12) || rpad(replace(replace(nvl(
                         replace(r_input_25,' '),' '),'-'),'/'),8);
   ELSIF p_report_qualifier = 'SC_SQWL' THEN

      l_s_hyphen_position := nvl(instr(substr(r_input_25,1,6),'-'),1) - 1 ;
      IF l_s_hyphen_position = -1  or l_s_hyphen_position > 6  then
         l_s_hyphen_position := 6;
      End IF;

      r_input_25 := lpad(nvl(replace(substr(r_input_25,1,l_s_hyphen_position)
                         ,'/'),0),20,'0');
   ELSIF (p_report_qualifier = 'MD_SQWL') THEN

      r_input_25 := lpad(lpad(replace(replace(substr(nvl(replace(r_input_25,
                         ' '),' '),1,10),'-'),'/'),10),20);
   ELSIF p_report_qualifier = 'MS_SQWL' THEN

      r_input_25 := rpad(replace(replace(nvl(replace(r_input_25,' '),' ')
                         ,'-'),'/'),20);
   ELSIF ((p_report_qualifier = 'LA_SQWL') OR
          ( p_report_qualifier = 'NY_SQWL'))  THEN

      r_input_25 := lpad(' ',20);
   ELSIF p_report_qualifier = 'AZ_SQWL' THEN
      r_input_25 := rpad(replace(replace(substr(nvl(replace(r_input_25,' ')
                         ,' '),1,7),'-'),'/'),7)||lpad(substr(nvl(
                         replace(r_input_26,' '),' '),1,3),3,0)||lpad(' ',10);


   /* Bug :4170713 */
   /* Position 260 : Month1 Employment
      Position 261 : Month2 Employment
      Position 262 : Month3 Employment
      Position 263-267 : Blank
   */

   ELSIF p_report_qualifier = 'MN_SQWL' THEN /* Bug:2334393 */
/*
      l_s_hyphen_position :=
        nvl(instr(substr(substr(r_input_25,1,instr(r_input_25,'^',1,1) - 1),1,8),'-'),1) - 1 ;

      IF l_s_hyphen_position = -1  or l_s_hyphen_position > 8  then
         l_s_hyphen_position := 8;
      End IF;
*/
/* Bug# 1236643 Pos: 256 - 259 Employer Unit Number */
      l_s_hyphen_position :=
        nvl(instr(substr(r_input_25,1,instr(r_input_25,'^',1,1) - 1),'-'),1) - 1 ;

      l_carate_1_position := instr(r_input_25,'^',1,1) ;

      IF l_s_hyphen_position = -1  THEN
         l_st_er_acct_no := lpad(replace(nvl(substr(r_input_25,1,8),'0'),'/'),8,'0') ;
	 l_er_unit_no := rpad('0',4,'0') ;
      ELSE
         l_st_er_acct_no := lpad(replace(nvl(substr(substr(r_input_25,1,l_s_hyphen_position),1,8),'0'),'/'),8,'0') ;
	 l_er_unit_no := lpad(nvl(substr(substr(r_input_25,l_s_hyphen_position + 2,l_carate_1_position - (l_s_hyphen_position + 2)),1,4),'0'),4,'0') ;
      End IF;


      If substr(r_input_25,instr(r_input_25,'^',1,1) + 1,instr(r_input_25,'^',1,2) - instr(r_input_25,'^',1,1) - 1) = '0' Then
         l_pos_260 := '0' ;
      Else
         l_pos_260 := '1' ;
      End If ;

      If substr(r_input_25,instr(r_input_25,'^',1,2) + 1,instr(r_input_25,'^',1,3) - instr(r_input_25,'^',1,2) - 1) = '0' Then
         l_pos_261 := '0' ;
      Else
         l_pos_261 := '1' ;
      End If ;

      If substr(r_input_25,instr(r_input_25,'^',1,3) + 1) = '0' Then
         l_pos_262 := '0' ;
      Else
         l_pos_262 := '1' ;
      End If ;

      r_input_25 := l_st_er_acct_no || l_er_unit_no || l_pos_260 || l_pos_261 || l_pos_262 || rpad(' ',5,' ') ;

   ELSIF p_report_qualifier = 'CA_SQWL' THEN
      r_input_25 := rpad(replace(r_input_25, '-'), 11, '0')||lpad(' ',9);
   ELSIF p_report_qualifier = 'VA_SQWL' THEN
      r_input_25 := lpad(substr(nvl(replace(replace(r_input_25, '-'), ' '),'0'),1,10),20,'0');
   ELSIF p_report_qualifier = 'FL_SQWL' THEN
      r_input_25 := rpad(replace(nvl(substr(r_input_25,1,20),' '),'-'),20,' ');
   ELSIF p_report_qualifier = 'AL_SQWL' THEN
      r_input_25 := rpad(nvl(substr(r_input_25,1,10),' '),20,' ') ;
   ELSIF p_report_qualifier = 'TX_SQWL' OR /* Bug# 4559359 */
         p_report_qualifier = 'KS_SQWL' THEN /* Bug# 6036926 */
      r_input_25 := rpad(nvl(substr(replace(r_input_25,'-' ),1,9),' '),20,' ') ;
   END IF;
--}

   /* Pos:274 - 275 State code blank for PA,NJ,OH RITA ,NC and SQWL */
   IF (p_report_qualifier = 'MN_SQWL') THEN
      r_input_26 := '00';
   ELSE
      r_input_26 := lpad(' ',2);
   END IF;

   /* Pos:276 - 286 State taxable wages.
      Pos:287 - 297 SIT withheld. */

   IF ((p_report_qualifier = 'CA_SQWL') OR
       (p_report_qualifier = 'NY_SQWL' and
      substr(p_input_19,1,2) = '12' )) THEN
--{
      IF p_input_40 = 'FLAT' THEN
         r_input_27:=
           pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                      p_report_type,
                                                      p_format,
                                                      p_report_qualifier,
                                                      p_record_name,
                                                      'NEG_CHECK',
                                                      r_input_27,
                                                      'State taxable Wages',
                                                      p_input_39,
                                                      null,
                                                      p_validate,
                                                      p_exclude_from_output,
                                                      sp_out_1,
                                                      sp_out_2);
         IF p_exclude_from_output = 'Y' THEN
            l_exclude_from_output_chk := TRUE;
         END IF;
         r_input_28 :=
           pay_us_reporting_utils_pkg.data_validation( p_effective_date,
                                                       p_report_type,
                                                       p_format,
                                                       p_report_qualifier,
                                                       p_record_name,
                                                       'NEG_CHECK',
                                                       r_input_28,
                                                       'SIT Withheld',
                                                       p_input_39,
                                                       null,
                                                       p_validate,
                                                       p_exclude_from_output,
                                                       sp_out_1,
                                                       sp_out_2);
         IF p_exclude_from_output = 'Y' THEN
            l_exclude_from_output_chk := TRUE;
         END IF;
      END IF;
--}
   ELSE
      r_input_27 := rpad(0,11,0);
      r_input_28 := rpad(0,11,0);
   END IF;

   /* Pos:276-297 Blank for SC_SQWL. State wages and SIT withheld. */
   IF ((p_report_qualifier = 'SC_SQWL') OR
       (p_report_qualifier = 'GA_SQWL') OR
       (p_report_qualifier = 'FL_SQWL') OR
       (p_report_qualifier = 'VA_SQWL') OR
       (p_report_qualifier = 'AZ_SQWL') OR /* Fix.*/
       (p_report_qualifier = 'KS_SQWL') OR /* Bug 6036926 */
       (p_report_qualifier = 'TX_SQWL')) /* Bug# 4559359 */ THEN
      r_input_27 := lpad(' ',11);
      r_input_28 := lpad(' ',11);
   END IF;

   /* Pos:298-307 State Excess Wages for LA_SQWL. */
   IF (p_report_qualifier = 'LA_SQWL') THEN
      IF p_input_40 = 'FLAT' THEN
         hr_utility.trace(' Other state data AL,MD,OH ');
         r_input_29 :=
           pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                      p_report_type,
                                                      p_format,
                                                      p_report_qualifier,
                                                      p_record_name,
                                                      'NEG_CHECK',
                                                      r_input_29,
                                                      'Other State Data',
                                                      p_input_39,
                                                      null,
                                                      p_validate,
                                                      p_exclude_from_output,
                                                      sp_out_1,
                                                      sp_out_2);
         IF p_exclude_from_output = 'Y' THEN
            l_exclude_from_output_chk := TRUE;
         END IF;
      END IF;
   ELSE
      r_input_29 := lpad(' ',10);
   END IF;

   IF p_report_qualifier = 'NC_SQWL' THEN
      r_input_29 := rpad(upper(rpad(p_input_29, 6, ' ')),10);
      hr_utility.trace('State Control No for NC is '||r_input_29);
   END IF;

   /* Pos:308 - 308 Tax type code formatting */
   IF p_report_qualifier = 'VA_SQWL' THEN
      r_input_30 := 'B' ; /*Unemployement Tax */
   ELSE
      r_input_30 := lpad(' ', 1);
   END IF;

   /* Pos:309 - 319 Local taxable wages filled with zeros
      Pos:320 - 330 Local Income tax withheld filled with zeros */

   hr_utility.trace('Zero fill for SQWLs. p_report_qualifier = '||p_report_qualifier);
   r_input_31 := rpad(0,11,0);
   r_input_32 := rpad(0,11,0);
   hr_utility.trace('r_input_31 '||r_input_31);
   hr_utility.trace('r_input_32 '||r_input_32);

   /* Pos:309-330 Blank for SC_SQWL. State wages and SIT withheld. */
   IF ((p_report_qualifier = 'SC_SQWL') OR
       (p_report_qualifier = 'GA_SQWL') OR
       (p_report_qualifier = 'LA_SQWL') OR
       (p_report_qualifier = 'CA_SQWL') OR
       (p_report_qualifier = 'NY_SQWL') OR
       (p_report_qualifier = 'FL_SQWL') OR
       (p_report_qualifier = 'VA_SQWL') OR
       (p_report_qualifier = 'AZ_SQWL') OR /* Fix.*/
       (p_report_qualifier = 'KS_SQWL') OR /* Bug 6036926 */
       (p_report_qualifier = 'TX_SQWL')) THEN /* Bug# 4559359 */
--{
      r_input_31 := lpad(' ',11);
      r_input_32 := lpad(' ',11);
--}
   END IF;

   /* Pos:331 - 337 State Control number filled with blank for SQWL
      Pos:338 - 412 Supplemental data1
      Pos:413 - 487 Supplemental data2  */
   r_input_33 := replace(replace(replace(p_input_33,'-'),' '),'/');
--{
   -- Formatting Supplemental Data
   --
   r_input_33 := lpad(' ',7);
   IF p_report_qualifier = 'NE_SQWL' THEN
       r_input_33 := lpad('0',7,'0');
   END IF;


   IF p_report_qualifier = 'LA_SQWL' THEN

      r_input_34 := lpad(rpad(rpad(nvl(r_input_34,' '),1) ||
                    rpad(nvl(r_input_35,' '),1) ||
                    rpad(nvl(r_input_36,' '),1),56),75);
      r_input_35 := lpad(' ',75);

   ELSIF p_report_qualifier = 'KS_SQWL' THEN
      r_input_34 := rpad(rpad(nvl(r_input_34,' '),1) ||
                    rpad(nvl(r_input_35,' '),1) ||
                    rpad(nvl(r_input_36,' '),1),75); /* 6036926 */
       r_input_35 := lpad(' ',75);

   ELSIF p_report_qualifier = 'MN_SQWL' THEN
      r_input_34 := rpad(lpad(nvl(r_input_34,' '),3,0)||/*3011801*/
                    rpad(nvl(r_input_35,' '),1),75);
      r_input_35 := lpad(' ',75);
   ELSIF p_report_qualifier = 'OR_SQWL' THEN
      r_input_34 := rpad(lpad(nvl(r_input_34,' '),3,0),75); /*2286335*/
      r_input_35 := lpad(' ',75);
   ELSIF p_report_qualifier = 'NV_SQWL' THEN
--    r_input_34 := 0;  /* Will be supported in Q1 2005 with new Tips Wages Balance*/
-- Added for bug 3835632 .
      r_input_34 := rpad(lpad(nvl(r_input_34,' '),9,0),75);
      r_input_35 := lpad(' ',75);
/* 4559359 */
/*   ELSIF p_report_qualifier = 'TX_SQWL' THEN
      hr_utility.trace(' r_input_34 := '|| r_input_34 ) ;
      r_input_34 := lpad(nvl(r_input_34,' '),3,'0') ||
                    lpad(substr(nvl(r_input_35,' '),1,3),3) || /* County Code * /
		    lpad(' ',1) ||
		    lpad(' ',6) || /* NAICS Code * /
		    lpad(' ',1) ||
		    lpad(' ',10) || /* Establishment ID - Not Supported * /
		    lpad(' ',1) ||
		    lpad('0',5,'0') || /* Unit Number - Zero Fill * /
		    lpad(' ',45) ;
*/
     ELSE
        r_input_34 := lpad(' ',75);
        r_input_35 := lpad(' ',75);
     END IF;
--}

   /* Fix for Bug # 2789523 */
   IF p_report_qualifier = 'MN_SQWL' THEN
      l_last_field := lpad('X',25);
   ELSE
      l_last_field := lpad(' ',25);
   END IF;

   IF p_report_qualifier = 'WA_SQWL' THEN
      hr_utility.trace('WA_SQWL');
      r_input_4 :=
        pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                   p_report_type,
                                                   p_format,
                                                   p_report_qualifier,
                                                   p_record_name,
                                                   'NEG_CHECK',
                                                   p_input_4,
                                                   'Quarterly Gross Wages',
                                                   p_input_2,
                                                   null,
                                                   p_validate,
                                                   p_exclude_from_output,
                                                   sp_out_1,
                                                   sp_out_2);
      IF p_exclude_from_output = 'Y' THEN
         l_exclude_from_output_chk := TRUE;
      END IF;
      l_hours_worked := to_number(replace(p_input_3,' '));
      hr_utility.trace('l_hours_worked = '||to_char(l_hours_worked));
      IF l_hours_worked <0 THEN
         hr_utility.trace('Error in RS record for Employee '||p_input_2||
                             ' Negative hours');
         l_exclude_from_output_chk := TRUE;
         pay_core_utils.push_message(801,'PAY_INVALID_EE_FORMAT','A');
         pay_core_utils.push_token('record_name',p_record_name);
         pay_core_utils.push_token('name_or_number',substr(p_input_2,1,50));
         pay_core_utils.push_token('description','Negative hours');
      END IF;
      hr_utility.trace('p_exclude_from_output = '||p_exclude_from_output);
-- Validation Starts
-- EIN Validation
      r_input_5 :=
          pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                     p_report_type,
                                                     p_format,
                                                     p_report_qualifier,
                                                     p_record_name,
                                                     'EIN',
                                                     p_input_5,
                                                     'EIN',
                                                     p_input_2,
                                                     null,
                                                     p_validate,
                                                     p_exclude_from_output,
                                                     sp_out_1,
                                                     sp_out_2);

      IF p_exclude_from_output = 'Y' THEN
         l_exclude_from_output_chk := TRUE;
      END IF;
      hr_utility.trace('Valid EIN '||r_input_5);
      hr_utility.trace('p_exclude_from_output = '||p_exclude_from_output);
-- Validation Ends
      r_input_2 := replace(p_input_2,',');
      r_input_4 := to_char(to_number(r_input_4/100),'000000.00');
/*
      l_wa_sqwl_outstring := p_input_1||','||r_input_2||','||p_input_3||','||r_input_4;
*/
      l_wa_sqwl_outstring := r_input_5||','||p_input_1||','||r_input_2||','||p_input_3||','||r_input_4;
      hr_utility.trace('l_wa_sqwl_outstring = '||l_wa_sqwl_outstring);
   END IF;

   IF p_input_40 = 'FLAT' THEN
--{ Start of formatting FLAT type RS Record
--
      IF (p_report_qualifier = 'NY_SQWL')  THEN

          /* Bug 3527986 Removed Delimiters fro NY */
          --l_end_of_rec   := p_end_of_rec;

         	return_value:= 'RS'||r_input_2
                               ||r_input_3
                               ||l_ssn
                               ||l_first_name
                               ||l_middle_name
                               ||l_last_name
                               ||l_suffix
                               ||rpad(substr(nvl(r_input_9,' '),1,22),22)
                               ||rpad(substr(nvl(r_input_10,' '),1,22),22)
                               ||rpad(substr(nvl(r_input_11,' '),1,22),22)
                               ||rpad(substr(nvl(r_input_12,' '),1,2),2)
                               ||rpad(substr(nvl(r_input_13,' '),1,5),5)
                               ||rpad(substr(nvl(r_input_14,' '),1,4),9)
                               ||r_input_15
                               ||r_input_16
                               ||r_input_17
                               ||r_input_18
                               ||r_input_19
                               ||r_input_20
                               ||r_input_21
                               ||r_input_22
                               ||r_input_23
                               ||r_input_24
			       ||'W'
                               ||lpad(' ',4)
                               ||r_input_25
                               ||lpad(' ',6)
                               ||r_input_26
                               ||r_input_27
                               ||r_input_28
                               ||r_input_29
                               ||r_input_30
                               ||r_input_31
                               ||r_input_32
                               ||r_input_33
                               ||r_input_34
                               ||r_input_35
                               ||lpad(' ',25)
                               ||l_end_of_rec;
          ELSIF p_report_qualifier = 'WA_SQWL'  THEN
                return_value:= l_wa_sqwl_outstring;
	  ELSE
           		return_value:= 'RS'||r_input_2
                               ||r_input_3
                               ||l_ssn
                               ||l_first_name
                               ||l_middle_name
                               ||l_last_name
                               ||l_suffix
                               ||rpad(substr(nvl(r_input_9,' '),1,22),22)
                               ||rpad(substr(nvl(r_input_10,' '),1,22),22)
                               ||rpad(substr(nvl(r_input_11,' '),1,22),22)
                               ||rpad(substr(nvl(r_input_12,' '),1,2),2)
                               ||rpad(substr(nvl(r_input_13,' '),1,5),5)
                               ||rpad(substr(nvl(r_input_14,' '),1,4),9)
                               ||r_input_15
                               ||r_input_16
                               ||r_input_17
                               ||r_input_18
                               ||r_input_19
                               ||r_input_20
                               ||r_input_21
                               ||r_input_22
                               ||r_input_23
                               ||r_input_24
                               ||lpad(' ',5)
                               ||r_input_25
                               ||lpad(' ',6)
                               ||r_input_26
                               ||r_input_27
                               ||r_input_28
                               ||r_input_29
                               ||r_input_30
                               ||r_input_31
                               ||r_input_32
                               ||r_input_33
                               ||r_input_34
                               ||r_input_35
                               ||l_last_field
                               ||l_end_of_rec;
		END IF;
        hr_utility.trace('Length of return value = '||to_char(length(return_value)));
--} End of formatting FLAT Type RS Record
   ELSIF p_input_40 = 'CSV' THEN
--{ Start of formatting RS record in CSV format

    IF p_report_qualifier = 'FL_SQWL' THEN ----Added for Bug#9356178

      return_value := 'RS'
                      ||','||r_input_2
                      ||','||r_input_3
                      ||','||l_ssn
                      ||','||l_first_name
                      ||','||l_middle_name
                      ||','||l_last_name
                      ||','||l_suffix
                      ||','||rpad(substr(nvl(r_input_9,' '),1,22),22)
                      ||','||rpad(substr(nvl(r_input_10,' '),1,22),22)
                      ||','||rpad(substr(nvl(r_input_11,' '),1,22),22)
                      ||','||rpad(substr(nvl(r_input_12,' '),1,2),2)
                      ||','||rpad(substr(nvl(r_input_13,' '),1,5),5)
                      ||','||rpad(substr(nvl(r_input_14,' '),1,4),4)
                      ||','||lpad(' ',5)
                      ||','||r_input_15
                      ||','||r_input_16
                      ||','||r_input_17
                      ||','||r_input_18
                      ||','||r_input_19
                      ||','||r_input_20
                      ||','||r_input_21
                      ||','||r_input_22
                      ||','||r_input_23
                      ||','||r_input_24
                      ||','||lpad(' ',6)
                      ||','||r_input_25
                      ||','||lpad(' ',6)
                      ||','||r_input_26
                      ||','||r_input_27
                      ||','||r_input_28
                      ||','||r_input_29
                      ||','||r_input_30
                      ||','||r_input_31
                      ||','||r_input_32
                      ||','||r_input_33
                      ||','||r_input_34
                      ||','||r_input_35
                      ||','||lpad(' ',5)
		      ||','||r_input_37;

      ELSE

            return_value := 'RS'
                      ||','||r_input_2
                      ||','||r_input_3
                      ||','||l_ssn
                      ||','||l_first_name
                      ||','||l_middle_name
                      ||','||l_last_name
                      ||','||l_suffix
                      ||','||rpad(substr(nvl(r_input_9,' '),1,22),22)
                      ||','||rpad(substr(nvl(r_input_10,' '),1,22),22)
                      ||','||rpad(substr(nvl(r_input_11,' '),1,22),22)
                      ||','||rpad(substr(nvl(r_input_12,' '),1,2),2)
                      ||','||rpad(substr(nvl(r_input_13,' '),1,5),5)
                      ||','||rpad(substr(nvl(r_input_14,' '),1,4),4)
                      ||','||lpad(' ',5)
                      ||','||r_input_15
                      ||','||r_input_16
                      ||','||r_input_17
                      ||','||r_input_18
                      ||','||r_input_19
                      ||','||r_input_20
                      ||','||r_input_21
                      ||','||r_input_22
                      ||','||r_input_23
                      ||','||r_input_24
                      ||','||lpad(' ',6)
                      ||','||r_input_25
                      ||','||lpad(' ',6)
                      ||','||r_input_26
                      ||','||r_input_27
                      ||','||r_input_28
                      ||','||r_input_29
                      ||','||r_input_30
                      ||','||r_input_31
                      ||','||r_input_32
                      ||','||r_input_33
                      ||','||r_input_34
                      ||','||r_input_35
                      ||','||lpad(' ',5);

      END IF;
--} End of formatting RS record in CSV format
--
   ELSIF p_input_40 = 'BLANK' THEN
--{ Start of formatting BALNK RS record used for audit report
--
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
                       ||','||' '
                       ||','||lpad(' ',5)
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
                       ||','||lpad(' ',6)
                       ||','||' '
                       ||','||lpad(' ',6)
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
                       ||','||lpad(' ',5);
--} End of formatting BLANK RS record used for audit report
--
   END IF; -- p_input_40
   p_error := l_exclude_from_output_chk;
   ret_str_len:=length(return_value);
   return return_value;
END format_SQWL_RS_record;
-- End of Formatting RS Record for W2 Reporting

-- Formatting RT record for SQWL reporting
--
/*
  Record Identifier                                              --> p_input_1
  Number of RW Records                                           --> p_input_2
  Wages, Tips and other Compensation                             --> p_input_3
  Federal Income Tax Withheld                                    --> p_input_4
  Social Security Wages                                          --> p_input_5
  Social Security Tax Withheld                                   --> p_input_6
  Medicare Wages And Tips                                        --> p_input_7
  Medicare Tax Withheld                                          --> p_input_8
  Social Security Tips                                           --> p_input_9
  Advance Earned Income Credit                                   --> p_input_10
  Dependent Care Benefits                                        --> p_input_11
  Deferred Compensation Contributions to Section 401(k)          --> p_input_12
  Deferred Compensation Contributions to Section 403(b)          --> p_input_13
  Deferred Compensation Contributions to Section 408(k)(6)       --> p_input_14
  Deferred Compensation Contributions to Section 457(b)          --> p_input_15
  Deferred Compensation Contributions to Section 501(c)(18)(D)   --> p_input_16
  Military EE''s Basic Quarters, Subsistence And Combat Pay      --> p_input_17
  Non-Qual. Plan Sec.457 Distributions or Contributions          --> p_input_18
  Non-Qual. Plan NOT Section 457 Distributions or Contributions  --> p_input_19
  Employer Cost of Premiums for GTL> $50k                        --> p_input_20
  Income Tax Withheld by Third-Party Payer                       --> p_input_21
  Income from the Exercise of Nonqualified Stock Options         --> p_input_22

  For PuertoRico following input parameters were used
      W2 Govt EE Contributions                                   --> p_input_23
      Total Fed Wages                                            --> p_input_24

  For PuertoRico following input parameters were used
     Cost of Pension or Annuity                                  --> p_input_23
     Contributions to Qualified Plans                            --> p_input_24
     Cost Reimbursement                                          --> p_input_25
*/
FUNCTION format_SQWL_RT_record(
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
l_input_2                  varchar2(100);
return_value               varchar2(32767);
l_exclude_from_output_chk  boolean;
l_rt_end_of_rec            varchar2(200);
l_records                  number(10);
l_end_of_rec               varchar2(20);
p_end_of_rec               varchar2(20);

TYPE function_columns IS RECORD(
                                p_parameter_name  varchar2(100),
                                p_parameter_value varchar2(100),
                                p_output_value varchar2(100)
                               );
function_parameter_rec  function_columns;
TYPE input_parameter_record IS TABLE OF function_parameter_rec%TYPE
                               INDEX BY BINARY_INTEGER;
parameter_record input_parameter_record;

BEGIN
p_end_of_rec   := fnd_global.local_chr(13)||fnd_global.local_chr(10);
   hr_utility.trace('RT Record Formatting started for SQWL reporting ');

--  Validation Starts
  If p_input_40='FLAT' THEN
--{
    IF p_report_qualifier = 'FL_SQWL' THEN
--{
       parameter_record(1).p_parameter_name:= 'Wages,Tips And Other Compensation';
       parameter_record(1).p_parameter_value:=p_input_3;

       parameter_record(2).p_parameter_name:= 'Total Tax Due';
       parameter_record(2).p_parameter_value:=p_input_22;

       parameter_record(3).p_parameter_name:= 'Corrected Worker Ist Month';
       parameter_record(3).p_parameter_value:=p_input_23;

       parameter_record(4).p_parameter_name:= 'Corrected Worker IInd Month';
       parameter_record(4).p_parameter_value:=p_input_24;

       parameter_record(5).p_parameter_name:= 'Corrected Worker IIIrd Month';
       parameter_record(5).p_parameter_value:=p_input_25;

       l_records :=5;
       l_end_of_rec   := p_end_of_rec;
--}
    ELSE
--{
       parameter_record(1).p_parameter_name:= ' Wages,Tips And Other Compensation';
       parameter_record(1).p_parameter_value:=p_input_3;

       parameter_record(2).p_parameter_name:= ' Federal Income Tax Withheld';
       parameter_record(2).p_parameter_value:=p_input_4;

       parameter_record(3).p_parameter_name:= 'Social Security Wages';
       parameter_record(3).p_parameter_value:=p_input_5;

       parameter_record(4).p_parameter_name:= ' Social Security Tax Withheld';
       parameter_record(4).p_parameter_value:=p_input_6;

       parameter_record(5).p_parameter_name:= 'Medicare Wages And Tips';
       parameter_record(5).p_parameter_value:=p_input_7;

       parameter_record(6).p_parameter_name:= 'Medicare Tax Withheld';
       parameter_record(6).p_parameter_value:=p_input_8;

       parameter_record(7).p_parameter_name:= 'Social Security Tips';
       parameter_record(7).p_parameter_value:=p_input_9;

       parameter_record(8).p_parameter_name:= 'Advance Earned Income Credit';
       parameter_record(8).p_parameter_value:=p_input_10;

       parameter_record(9).p_parameter_name:= 'Dependent Care Benefits';
       parameter_record(9).p_parameter_value:=p_input_11;

       parameter_record(10).p_parameter_name:= 'Deferred Comp Contr. to Sec 401(k)';
       parameter_record(10).p_parameter_value:=p_input_12;

       parameter_record(11).p_parameter_name:= 'Deferred Comp Contr. to Sec 403(b)';
       parameter_record(11).p_parameter_value:=p_input_13;

       parameter_record(12).p_parameter_name:= 'Deferred Comp Contr. to Sec 408(k)(6)';
       parameter_record(12).p_parameter_value:=p_input_14;

       parameter_record(13).p_parameter_name:= 'Deferred Comp Contr. to Sec 457(b)';
       parameter_record(13).p_parameter_value:=p_input_15;

       parameter_record(14).p_parameter_name:= 'Deferred Comp Contr. to Sec 501(c)';
       parameter_record(14).p_parameter_value:=p_input_16;

    /* Following field is commented to fix bug # 2297587
       parameter_record(15).p_parameter_name:= 'Military Combat Pay';
       parameter_record(15).p_parameter_value:=p_input_17;
    */
       parameter_record(15).p_parameter_name:= 'Non-Qual. plan Sec 457';
       parameter_record(15).p_parameter_value:=p_input_18;

       parameter_record(16).p_parameter_name:= 'Non-Qual. plan NOT Sec 457';
       parameter_record(16).p_parameter_value:=p_input_19;

       parameter_record(17).p_parameter_name:= 'Employer cost of premiun';
       parameter_record(17).p_parameter_value:=p_input_20;

       parameter_record(18).p_parameter_name:= 'Income tax withheld by 3rd party payer';
       parameter_record(18).p_parameter_value:=p_input_21;

       parameter_record(19).p_parameter_name:= 'Income from nonqualified stock option';
       parameter_record(19).p_parameter_value:=p_input_22;
       l_records := 19;

    END IF;
-- Validating above data based on the report_qualifier and number entries
--
    FOR i in 1..l_records
    LOOP
       parameter_record(i).p_output_value :=
       pay_us_reporting_utils_pkg.data_validation( p_effective_date,
                                                   p_report_type,
                                                   p_format,
                                                   p_report_qualifier,
                                                   p_record_name,
                                                   'NEG_CHECK',
                                                   parameter_record(i).p_parameter_value,
                                                   parameter_record(i).p_parameter_name,
                                                   p_input_39,
                                                   null,
                                                   p_validate,
                                                   p_exclude_from_output,
                                                   sp_out_1,
                                                   sp_out_2);
       IF p_exclude_from_output = 'Y' THEN
          l_exclude_from_output_chk := TRUE;
       END IF;
       hr_utility.trace(parameter_record(i).p_parameter_name||' = '
                                    ||parameter_record(i).p_output_value);
       hr_utility.trace('After validating the parameter for -ve Value p_exclude_from_output = '||p_exclude_from_output);
    END LOOP;
-- Validation Ends here

-- For Alabama, Zero Fill Pos : 250 - 264 /* Employer Contributions to Health Savings Account */
-- Zero Fill Pos : 280 - 294
-- Zero Fill Pos : 355 - 369
   IF p_report_qualifier = 'AL_SQWL' THEN
      parameter_record(15).p_output_value := rpad(parameter_record(15).p_output_value,30,'0') ;
      parameter_record(16).p_output_value := rpad(parameter_record(16).p_output_value,30,'0') ;
      parameter_record(19).p_output_value := rpad(parameter_record(19).p_output_value,30,'0') ;
   END IF ;
--
-- Formatting RT Record depending on report_qualifier
--
-- Formatting No of Employee Wage/State Record
    l_input_2:= lpad(substr(nvl(p_input_2,'0'),1,7),7,0);

    IF p_report_qualifier = 'SC_SQWL' THEN /*2274381.*/
--{
       return_value := 'RT'||l_input_2
                           ||lpad(' ',503);
--}
    ELSIF p_report_qualifier = 'FL_SQWL' THEN
--{
       return_value := 'RT'||lpad(' ',7)
                           ||lpad(substr(nvl(parameter_record(1).p_output_value,'0'),1,15),15)
			   --||lpad(' ',456)
			   ||lpad(' ',195) /* Bug# 4867893 */
			   ||lpad('0',15,'0')
			   ||lpad(' ',246)
                           ||lpad(substr(nvl(parameter_record(2).p_output_value,'0'),1,11),11)
                           ||lpad(substr(nvl(parameter_record(3).p_output_value,'0'),1,7),7)
                           ||lpad(substr(nvl(parameter_record(4).p_output_value,'0'),1,7),7)
                           ||lpad(substr(nvl(parameter_record(5).p_output_value,'0'),1,7),7)
				           ||l_end_of_rec;

   ELSIF p_report_qualifier = 'VA_SQWL' THEN  /* Bug# 6057156 */
--{
       return_value := 'RT'||lpad(' ',510);
--}
--}
    ELSE
--{
       return_value := 'RT'||l_input_2
                           ||parameter_record(1).p_output_value
                           ||parameter_record(2).p_output_value
                           ||parameter_record(3).p_output_value
                           ||parameter_record(4).p_output_value
                           ||parameter_record(5).p_output_value
                           ||parameter_record(6).p_output_value
                           ||parameter_record(7).p_output_value
                           ||parameter_record(8).p_output_value
                           ||parameter_record(9).p_output_value
                           ||parameter_record(10).p_output_value
                           ||parameter_record(11).p_output_value
                           ||parameter_record(12).p_output_value
                           ||parameter_record(13).p_output_value
                           ||parameter_record(14).p_output_value
-- commented to fix bug # 2297587 ||parameter_record(15).p_output_value
                           ||lpad('0',15,'0') /* Bug# 4867893 */
                           ||rpad(parameter_record(15).p_output_value,30)
                           ||rpad(parameter_record(16).p_output_value,45)
                           ||parameter_record(17).p_output_value
                           ||parameter_record(18).p_output_value
                           ||rpad(parameter_record(19).p_output_value,173);
--}
    END IF;
    ret_str_len:=length(return_value);
--}
  ELSIF p_input_40 = 'CSV' THEN
--{
     l_rt_end_of_rec := lpad(' ',158);
     return_value := 'RT'||','||l_input_2
                         ||','||p_input_3
                         ||','||p_input_4
                         ||','||p_input_5
                         ||','||p_input_6
                         ||','||p_input_7
                         ||','||p_input_8
                         ||','||p_input_9
                         ||','||p_input_10
                         ||','||p_input_11
                         ||','||p_input_12
                         ||','||p_input_13
                         ||','||p_input_14
                         ||','||p_input_15
                         ||','||p_input_16
    -- commented to fix bug # 2297587 ||','||p_input_17
                         ||','||lpad(' ',15)
                         ||','||p_input_18
                         ||','||lpad(' ',15)
                         ||','||p_input_19
                         ||','||lpad(' ',30)
                         ||','||p_input_20
                         ||','||p_input_21
                         ||','||p_input_22
                         ||','||l_rt_end_of_rec;
--}
  END IF; -- p_input_40  (i.e. FLAT, CSV)
  p_error := l_exclude_from_output_chk;
  ret_str_len:=length(return_value);
  return return_value;
END format_SQWL_RT_record; -- End of Formatting SQWL RT record

-- Formatting RSSUMM record for SQWL reporting
--
/*
  Record Identifier                                              --> p_input_1
  State Code                                                     --> p_input_2
  Taxing Entity Code/State Rec Type                              --> p_input_3
  Federal Tax ID Number                                          --> p_input_4
  State Employer Acct Number                                     --> p_input_5
  Reporting Period                                               --> p_input_6
  Total Number of Workers on Report                              --> p_input_7
  Total Wages Paid This Quarter (Including Tips)                 --> p_input_8
  Nontaxable Wage                                                --> p_input_9
  Taxable Wages Paid This Quarter                                --> p_input_10
  Month(1) employment for employer                               --> p_input_11
  Month(2) employment for employer                               --> p_input_12
  Month(3) employment for employer                               --> p_input_13
  No Workers/No Wages Indicator                                  --> p_input_14
  Employer Name                                                  --> p_input_15

*/
FUNCTION format_SQWL_RSSUMM_record(
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
l_input_2                  varchar2(100);
l_input_3                  varchar2(100);
l_input_6                  varchar2(100);
l_input_7                  varchar2(100);
l_input_11                 varchar2(100);
l_input_12                 varchar2(100);
l_input_13                 varchar2(100);
l_noworker_nowage_ind      varchar2(100);
return_value               varchar2(32767);
l_exclude_from_output_chk  boolean;
l_rt_end_of_rec            varchar2(200);
l_records                  number(10);
l_end_of_rec               varchar2(20);
l_emp_ein                      varchar2(100);
l_other_ein                      varchar2(100);
p_end_of_rec               varchar2(20);

TYPE function_columns IS RECORD(
                                p_parameter_name  varchar2(100),
                                p_parameter_value varchar2(100),
                                p_output_value varchar2(100)
                               );
function_parameter_rec  function_columns;
TYPE input_parameter_record IS TABLE OF function_parameter_rec%TYPE
                               INDEX BY BINARY_INTEGER;
parameter_record input_parameter_record;

BEGIN
p_end_of_rec   := fnd_global.local_chr(13)||fnd_global.local_chr(10);
   hr_utility.trace('RSSUMM Record Formatting started for SQWL reporting ');

          l_emp_ein         := p_input_4;
          l_other_ein       := p_input_5;
    hr_utility.trace('Before Valaditing Values are ...');
    hr_utility.trace('p_input_1 = '||p_input_1);
    hr_utility.trace('p_input_2 = '||p_input_2);
    hr_utility.trace('p_input_3 = '||p_input_3);
    hr_utility.trace('p_input_4 = '||p_input_4);
    hr_utility.trace('p_input_5 = '||p_input_5);
    hr_utility.trace('p_input_6 = '||p_input_6);
    hr_utility.trace('p_input_7 = '||p_input_7);
    hr_utility.trace('p_input_8 = '||p_input_8);
    hr_utility.trace('p_input_9 = '||p_input_9);
    hr_utility.trace('p_input_10 = '||p_input_10);
    hr_utility.trace('p_input_11 = '||p_input_11);
    hr_utility.trace('p_input_12 = '||p_input_12);
    hr_utility.trace('p_input_13 = '||p_input_13);
    hr_utility.trace('p_input_14 = '||p_input_14);
    hr_utility.trace('p_input_15 = '||p_input_15);
--  Validation Starts
  If p_input_40='FLAT' THEN
--{
--    These validation are used only for mf file only.
--    not for any of the audit report
--
         hr_utility.trace('before data_validation of ein');
         l_emp_ein :=
             pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                        p_report_type,
                                                        p_format,
                                                        p_report_qualifier,
                                                        p_record_name,
                                                        'EIN',
                                                        l_emp_ein,
                                                        'Employer EIN',
                                                        p_input_15,
                                                        null,
                                                        p_validate,
                                                        p_exclude_from_output,
                                                        sp_out_1,
                                                        sp_out_2);
         IF p_exclude_from_output = 'Y' THEN
            l_exclude_from_output_chk := TRUE;
         END IF;

       IF l_other_ein is not null then
--{
         hr_utility.trace('before data_validation of Other EIN');
         l_other_ein :=
             pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                        p_report_type,
                                                        p_format,
                                                        p_report_qualifier,
                                                        p_record_name,
                                                        'EIN',
                                                        l_other_ein,
                                                        'Other EIN',
                                                        p_input_15,
                                                        null,
                                                        p_validate,
                                                        p_exclude_from_output,
                                                        sp_out_1,
                                                        sp_out_2);
             IF p_exclude_from_output = 'Y' THEN
                l_exclude_from_output_chk := TRUE;
             END IF;
--}
         END IF;

    IF p_report_qualifier = 'NV_SQWL' THEN
--{
       parameter_record(1).p_parameter_name:= 'Wages,Tips And Other Compensation';
       parameter_record(1).p_parameter_value:=p_input_8;

       parameter_record(2).p_parameter_name:= ' Nontaxable Wage';
       parameter_record(2).p_parameter_value:=p_input_9;

       parameter_record(3).p_parameter_name:= 'Taxable Wages';
       parameter_record(3).p_parameter_value:=p_input_10;

       l_records := 3;
--}
    END IF;
-- Validating above data based on the report_qualifier and number entries
--
    FOR i in 1..l_records
    LOOP
       hr_utility.trace(parameter_record(i).p_parameter_name||' = '
                                    ||parameter_record(i).p_parameter_value);

       hr_utility.trace('value of(i)|| = '|| to_char(i));

       parameter_record(i).p_output_value :=
       pay_us_reporting_utils_pkg.data_validation( p_effective_date,
                                                   p_report_type,
                                                   p_format,
                                                   p_report_qualifier,
                                                   p_record_name,
                                                   'NEG_CHECK',
                                                   parameter_record(i).p_parameter_value,
                                                   parameter_record(i).p_parameter_name,
                                                   p_input_39,
                                                   null,
                                                   p_validate,
                                                   p_exclude_from_output,
                                                   sp_out_1,
                                                   sp_out_2);
       IF p_exclude_from_output = 'Y' THEN
          l_exclude_from_output_chk := TRUE;
       END IF;
       hr_utility.trace(parameter_record(i).p_parameter_name||' = '
                                    ||parameter_record(i).p_output_value);
       hr_utility.trace('After validating the parameter for -ve Value p_exclude_from_output = '||p_exclude_from_output);
    END LOOP;
-- Validation Ends here
--
-- Formatting RSSUMM Record depending on report_qualifier
--
-- Formatting No of Employee Wage/State Record
    l_input_2:= lpad(substr(nvl(p_input_2,'0'),1,2),2,0);

-- Taxing Entity Code/State Rec Type
    l_input_3:= lpad(substr(nvl(p_input_3,'SUMM'),1,4),4);

-- No Workers/No Wages Indicator
   if p_input_8 <> 0 AND (p_input_7 <> 0 OR p_input_8 <> 0)then
      l_noworker_nowage_ind := ' ';
   else
      l_noworker_nowage_ind := 'Y';
   end if;
   l_noworker_nowage_ind := lpad(substr(l_noworker_nowage_ind,1,1),1);

-- Len:   6   Desc: Reporting Period
    l_input_6:= lpad(substr(nvl(p_input_6,'0'),1,6),6,0);

-- Len:   7   Desc: Total Number of Workers on Report
    l_input_7:= lpad(substr(nvl(p_input_7,'0'),1,7),7,0);

-- Len:   7   Desc: Month(1) employment for employer
    l_input_11:= lpad(substr(nvl(p_input_11,'0'),1,7),7,0);

-- Len:   7   Desc: Month(2) employment for employer
    l_input_12:= lpad(substr(nvl(p_input_12,'0'),1,7),7,0);

-- Len:   7   Desc: Month(3) employment for employer
    l_input_13:= lpad(substr(nvl(p_input_13,'0'),1,7),7,0);



    IF p_report_qualifier = 'NV_SQWL' THEN
--{
       return_value := 'RS'||l_input_2
                           ||l_input_3
                           ||lpad(' ',2)
                           ||l_emp_ein
                           ||lpad(' ',1)
                           ||l_other_ein
                           ||lpad(' ',1)
                           ||l_input_6
                           ||lpad(' ',1)
                           ||l_input_7
                           ||lpad(' ',1)
                           ||parameter_record(1).p_output_value
                           ||lpad(' ',1)
                           ||parameter_record(2).p_output_value
                           ||lpad(' ',1)
                           ||parameter_record(3).p_output_value
                           ||lpad(' ',1)
                           ||lpad(' ',13)
                           ||l_input_11
                           ||lpad(' ',1)
                           ||l_input_12
                           ||lpad(' ',1)
                           ||l_input_13
                           ||lpad(' ',1)
                           ||l_noworker_nowage_ind
                           ||lpad(' ',384);
--}
    END IF;
    ret_str_len:=length(return_value);
    hr_utility.trace(' Length of ret_str_len = ' || to_char(ret_str_len));
--}
  ELSIF p_input_40 = 'CSV' THEN
--{
     l_rt_end_of_rec := lpad(' ',158);
--{
       return_value := 'RS'||','||l_input_2
                           ||','||l_input_3
                           ||','||lpad(' ',2)
                           ||','||l_emp_ein
                           ||','||lpad(' ',1)
                           ||','||l_other_ein
                           ||','||lpad(' ',1)
                           ||','||l_input_6
                           ||','||lpad(' ',1)
                           ||','||l_input_7
                           ||','||lpad(' ',1)
                           ||','||parameter_record(1).p_output_value
                           ||','||lpad(' ',1)
                           ||','||parameter_record(2).p_output_value
                           ||','||lpad(' ',1)
                           ||','||parameter_record(3).p_output_value
                           ||','||lpad(' ',1)
                           ||','||lpad(' ',13)
                           ||','||l_input_11
                           ||','||lpad(' ',1)
                           ||','||l_input_12
                           ||','||lpad(' ',1)
                           ||','||l_input_13
                           ||','||lpad(' ',1)
                           ||','||l_noworker_nowage_ind
                           ||','||lpad(' ',384)
                           ||','||l_rt_end_of_rec;
--}
  END IF; -- p_input_40  (i.e. FLAT, CSV)
  p_error := l_exclude_from_output_chk;
  ret_str_len:=length(return_value);
  return return_value;
END format_SQWL_RSSUMM_record; -- End of Formatting SQWL RSSUMM record

--
-- Formatting RST record for SQWL reporting
--
/*
  Effective Date                               --> p_effective_date
  Report Type  (i.e.W2 )                       --> p_report_type
  Report Format                                --> p_format
  Report Qualifier                             --> p_report_qualifier
  Record Name (i.e. RST)                        --> p_record_name
  Record Identifier                            --> p_record_identifier
  Number of Employee                           --> p_total_no_employee
  SIT Wages                                    --> p_sit_wages
  SIT Taxes                                    --> p_sit_taxes
  1st Month employed no of employee            --> p_month1_no_employee
  2nd Month employed no of employee            --> p_month1_no_employee
  3rd Month employed no of employee            --> p_month1_no_employee
  Report Format Mode (FLAT, CSV)               --> p_format_mode
  Validation Flag                              --> p_validate
  Exclude Record from mag file                 --> p_exclude_from_output
  Return Record Length                         --> ret_str_len
*/

FUNCTION format_SQWL_RST_record(
                   p_effective_date        IN  varchar2,
                   p_report_type           IN  varchar2,
                   p_format                IN  varchar2,
                   p_report_qualifier      IN  varchar2,
                   p_record_name           IN  varchar2,
                   p_record_identifier     IN  varchar2,
                   p_total_no_of_employee  IN  varchar2,
                   p_state_code            IN  varchar2,
                   p_sui_reduction_wages   IN  varchar2,
                   p_sit_wages             IN  varchar2,
                   p_sit_tax               IN  varchar2,
                   p_month1_no_employee    IN  varchar2,
                   p_month2_no_employee    IN  varchar2,
                   p_month3_no_employee    IN  varchar2,
                   p_format_mode           IN  varchar2,
                   p_validate              IN  varchar2,
                   p_exclude_from_output   OUT nocopy varchar2,
                   ret_str_len             OUT nocopy number
                 ) RETURN VARCHAR2
IS
return_value                   varchar2(32767);
r_total_no_of_employee         varchar2(300);  -- r_input_2
r_state_code                   varchar2(300);  -- r_input_3
r_sui_reduction_wages          varchar2(300);  -- r_input_4
r_sit_wages                    varchar2(300);  -- r_input_5
r_sit_tax                      varchar2(300);  -- r_input_6
r_month1_no_employee           varchar2(300);  -- r_input_7
r_month2_no_employee           varchar2(300);  -- r_input_8
r_month3_no_employee           varchar2(300);  -- r_input_9
l_state_length                 number(10);

BEGIN
IF p_record_name = 'RST' THEN
-- Assigning parameter values to local variables
--
   r_total_no_of_employee    := p_total_no_of_employee;
   r_state_code              := p_state_code;
   r_sui_reduction_wages     := p_sui_reduction_wages;
   r_sit_wages               := p_sit_wages;
   r_sit_tax                 := p_sit_tax;
   r_month1_no_employee      := p_month1_no_employee;
   r_month2_no_employee      := p_month2_no_employee;
   r_month3_no_employee      := p_month3_no_employee;
   hr_utility.trace('Report Qualifier before Formatting RST Record  '
                                              ||p_report_qualifier);
   /*r_input_2 := lpad(' ',7);*/
   r_total_no_of_employee := lpad(substr(nvl(p_total_no_of_employee,'0'),1,7),7,0);
   r_sui_reduction_wages := lpad(nvl(r_sui_reduction_wages,'0'), 14, '0');
   r_sit_wages := lpad(nvl(r_sit_wages,'0'), 14, '0');
   l_state_length := length(replace(p_state_code,' ')); /* Fix for State code.*/
   IF l_state_length < 2 THEN
      r_state_code := lpad(replace(nvl(p_state_code,' '),' '),2,0);
      r_sit_tax := lpad(nvl(r_sit_tax,'0'), 14, '0');
      r_month1_no_employee := lpad(nvl(r_month1_no_employee,'0'), 7, '0');
      r_month2_no_employee := lpad(nvl(r_month2_no_employee,'0'), 7, '0');
      r_month3_no_employee := lpad(nvl(r_month3_no_employee,'0'), 7, '0');
   END IF;
   return_value:= 'RST'
                  ||r_total_no_of_employee --r_input_2
                  ||' '
                  ||r_state_code
                  ||' '
                  ||r_sui_reduction_wages
                  ||' '
                  ||r_sit_wages
                  ||' '
                  ||r_sit_tax
                  ||' '
                  ||r_month1_no_employee
                  ||' '
                  ||r_month2_no_employee
                  ||' '
                  ||r_month3_no_employee
                  ||lpad(' ',430);
END IF;  --p_record_name
   ret_str_len:=length(return_value);
   return return_value;
END format_SQWL_RST_record;
-- End of formatting RST record used for SQWL reporting
--


--
-- Formatting RU record for SQWL reporting
--
/*
   Effective Date                                 --> p_effective_date
   Report Type  (i.e.W2 )                         --> p_report_type
   Report Format                                  --> p_format
   Report Qualifier                               --> p_report_qualifier
   Record Name (i.e. RU)                          --> p_record_name
   Record Identifier                              --> p_record_identifier
   Number of RS Records                           --> p_number_of_RS_record
   Record Format Mode   (FLAT, CSV etc.)          --> p_record_format_mode
   Exclude RU record from .mf file                --> p_exclude_from_output

*/
FUNCTION format_SQWL_RU_record(
                   p_effective_date       IN  varchar2,
                   p_report_type          IN  varchar2,
                   p_format               IN  varchar2,
                   p_report_qualifier     IN  varchar2,
                   p_record_name          IN  varchar2,
                   p_record_identifier    IN  varchar2,
                   p_number_of_RS_record  IN  varchar2,
                   p_record_format_mode   IN  varchar2,
                   p_exclude_from_output  OUT nocopy varchar2,
                   ret_str_len            OUT nocopy number
                 ) RETURN VARCHAR2
IS
return_value               varchar2(32767);
l_no_of_rs_record          varchar2(300);
p_end_of_rec               varchar2(20);
l_end_of_rec               varchar2(20) ;

BEGIN
p_end_of_rec   := fnd_global.local_chr(13)||fnd_global.local_chr(10);
   hr_utility.trace('Formatting RU Record');
   hr_utility.trace('RU Record Format Mode  '||p_record_format_mode);
   l_no_of_rs_record := lpad(substr(nvl(p_number_of_RS_record,'0'),1,7),7,0);

   /* Bug 3527986 Removed Delimiters fro NY */
   /*
   IF ((p_report_qualifier = 'NY_SQWL')  and
 	   (p_record_format_mode = 'FLAT' )) THEN
      return_value:='RU'||l_no_of_rs_record||lpad(' ',503)||p_end_of_rec;
   ELSIF ((p_report_qualifier = 'NY_SQWL')  and
  	      (p_record_format_mode = 'CSV' )) THEN
      return_value:='RU'||','||l_no_of_rs_record||lpad(' ',503);
   END IF; -- p_report_qualifier
   */
   IF ((p_report_qualifier = 'NY_SQWL')  and
 	   (p_record_format_mode = 'FLAT' )) THEN
      return_value:='RU'||l_no_of_rs_record||lpad(' ',503)||l_end_of_rec;
   ELSIF ((p_report_qualifier = 'NY_SQWL')  and
  	      (p_record_format_mode = 'CSV' )) THEN
      return_value:='RU'||','||l_no_of_rs_record||lpad(' ',503);
   END IF; -- p_report_qualifier

   ret_str_len:=length(return_value);
   return return_value;
END format_SQWL_RU_record;  -- End of Formatting RU Record

-- Formatting RF record for SQWL reporting
--
/*
  Effective Date                               --> p_effective_date
  Report Type     (i.e. SQWL)                  --> p_report_type
  Report Format                                --> p_format
  Report Qualifier                             --> p_report_qualifier
  Record Name (i.e. RF)                        --> p_record_name
  Record Identifier                            --> p_record_identifier
  Number of RW Records                         --> p_total_no_of_record
  Wages, Tips and other Compensation           --> p_total_wages
  Federal Income Tax Withheld                  --> p_tal_taxes
  Report Format Mode (FLAT, CSV)               --> p_format_mode
  Validation Flag                              --> p_validate
  Exclude Record from mag file                 --> p_exclude_from_output
  Return Record Length                         --> ret_str_len
*/
FUNCTION format_SQWL_RF_record(
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
                               ret_str_len            OUT nocopy number
                              ) RETURN VARCHAR2
IS
return_value               varchar2(32767);
l_exclude_from_output_chk  boolean;
l_total_records            varchar2(50);
p_end_of_rec               varchar2(20);
l_end_of_rec               varchar2(20) ;

BEGIN
p_end_of_rec   := fnd_global.local_chr(13)||fnd_global.local_chr(10);
-- Formatting RF Record
   hr_utility.trace('Report Qualifier before Formatting RF Record  '
                                              ||p_report_qualifier);

 /* Bug:2259849. */
   IF ((p_report_qualifier = 'LA_SQWL' ) OR
          (p_report_qualifier = 'NV_SQWL')) THEN

         return_value := 'RF'||lpad(' ',510);

   ELSIF p_report_qualifier = 'NY_SQWL' THEN

        return_value := 'RF'||lpad(' ',510)||l_end_of_rec;

   ELSIF p_report_qualifier = 'AZ_SQWL' THEN /* Bug:2259849. */

         return_value := 'RF'||lpad(' ',510);

   ELSIF ((p_report_qualifier = 'NH_SQWL') OR
          (p_report_qualifier = 'VA_SQWL')) THEN

         return_value := 'RF'||rpad(' ',5)
                             ||rpad(0,9,0)
                             ||lpad(' ',496);

   ELSIF p_report_qualifier = 'SC_SQWL' THEN

         l_total_records := lpad(substr(nvl(p_total_no_of_record,' '),1,7),7,0);
         return_value := 'RF'||l_total_records
                             ||lpad(' ',7)
                             ||lpad(' ',496);
   ELSE
         return_value:=
                  'RF'
                  || lpad(lpad(substr(nvl(p_total_no_of_record,' '),1,9),9,0),14)
                  || rpad(' ',496);
   END IF;
   ret_str_len:=length(return_value);
   return return_value;
END format_SQWL_RF_record; -- End of Formatting RF Record for SQWL Reporting
--
--BEGIN

--hr_utility.trace_on(null, 'NVSQWL');

END pay_us_mmrf_sqwl_format_record; -- End of Package Body

/
