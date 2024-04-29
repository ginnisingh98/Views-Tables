--------------------------------------------------------
--  DDL for Package Body PAY_US_MMRF_W2_FORMAT_RECORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_MMRF_W2_FORMAT_RECORD" AS
/* $Header: pyusw2fr.pkb 120.47.12010000.32 2010/03/30 15:31:55 emunisek ship $  */

 /*===========================================================================+
 |               Copyright (c) 2001 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+

  Name
    pay_us_mmrf_w2_format_record

  Purpose
    The purpose of this package is to format reacord to support the
    generation of W2 magnetic tape for US legilsative requirements.

  Notes
    Referenced By:  Package  pay_us_reporting_utils_pkg

  History

  14-Jul-03  ppanda      115.0                Created
  18-Sep-03  ppanda      115.2  3150687       STATE W2 MAG RS RECORDS ARE ONLY 487 POSITIONS
                                              RS record formatting function uses a local variable
                                              l_last_field which is 25 spaces. This field was not
                                              initialized. This was causing the RS record length as 487.
  30-OCT-03  ppanda      115.3  3135857       Reporting Period for SC no longer required. Position
                                              197-202 on RS record blank filled.
  01-NOV-03  ppanda      115.5                Function set_req_field_length  modified for W-2c Mag requirement

  08-NOV-03  tmehra      115.6  2084851       Maryland State Pickup Pos 298-307 change
  20-NOV-03  ppanda      115.7  3130999       RA positions  12 - 216 NR blank fill
                                                           274 - 295 NR blank fill
                                                           356 - 512 NR blank fill
                                              RE position    7       NR blank fill
                                                            17 - 39  NR blank fill
                                                            97 - 118 NR blank fill
                                                           179 - 512 NR blank fill
                                              RS position   73 - 94  NR blank fill
                                                           150 - 194 NR blank fill
                                                           274 - 275 NR blank fill
  22-NOV-03 sodhingr    115.8                 Removed show_errors to fix GSCC failure
  25-NOV-03 ppanda      115.9   3067494       Kansas City, MO Local RS reocrd formating changed
                                              for few fields
  02-DEC-03 ppanda      115.10  3293083       Lousiana state W-2 is not reporting submitter
                                              Delivery address, City, State, Zip and Zip code
                                              extension.
  08-NOV-03 tmehra      115.11  2084851       Zero filled the Maryland State Pickup Pos 298-307
  08-DEC-03 ppanda      115.9   3299126       For LA state W2 RE record : 97- 118(Employer Address)
                                              Not required
  26-DEC-03 ppanda      115.10  3337295       For PR RO, RS and RT record specification changed
                                              Refer Bug Descriotion for the details of record changes.
  20-AUG-04 tmehra      115.11  3534769       Added support for the Maryland state pickup.

  27-OCT-04 rsethupa    115.15  3895206       NJ DIPP Plan ID - Only last 14 characters are
				              required
					      RS Positions  339-352
                                3936924       For State of AL
				              RE positions  170-173 - zip code extension
					                    401-410 - Alabama withholding tax acct number
							              (Right justify zero fill)
                                              RS positions  248-257 - State ER In Number
					                    258-268 - Federal Employer Id Number
							    393-396 - Payment year
  28-OCT-04 rsethupa    115.16  3936924       Removed redundant local variables. Added comments.

  02-NOV-04 rsethupa    115.17  3180532       IN EIC changes
                                              RS positions 193 - 203 Box 9 - Adv Fed EIC
					                   204 - 273 Blank fill
							   341 - 352 Box 19b - State Adv EIC
							   353 - 357 Box 20b - Adv EIC ID "INADV"
							   358 - 512 Blank fill
  04-NOV-04 rsethupa    115.18  3186636       WV requires MMREF format from 2004. Formatting for
                                              RE, RW and RS records done as per specifications.
                                3292989       ST Louis MO Local W-2 Mag
				              RA positions 12 - 28 blank fill
					                   29 - 29 blank fill
							   30 - 35 blank fill
							   36 - 37 blank fill
                                3680056       New fields ER Contrib to a Health Savings Account has been
                                              added to RW and RT records
					      RW positions 364-374
					      RT positions 250-264
  18-NOV-04 ppanda      115.19  3180532       IN EIC changes
                                              RS positions 341 - 352 Box 19b - State Adv EIC
							   353 - 357 Box 20b - Adv EIC ID "INADV"
                                              These two values were lpaded with blanks. This was
                                              causing the value to appear at position 396 instead
                                              of 341.
  18-NOV-04 ppanda      115.20  4016439       Dayton, OH Local Tape RA record changed
                                               for preferred problem notification method.
  24-NOV-04 rsethupa    115.21  3180532       Added local variable l_fl_field_17_20 for RS record
  24-NOV-04 rsethupa    115.22  4022086       RS record for state of MS
                                              positions
              				                  258-266 Federal Employer ID number
    					                      267 - blank
					                          298-307 Federal Tax withheld
					                          338-348 1099 Income
					                          349-392 blanks
					                          393-396 Payment Year
					                          397-512 blanks
  25-NOV-04 rsethupa    115.23  4014356       RS Record for NJ
                                              Positions
              			 	                  308-310 Medical Malpractice
                                                Insurance Premium Assistance
                                                Assessment (MIF)
                                              311-330 blanks
  29-Nov-04 ppanda      115.24  4012469       RS record changed for
                                              positions 3-4 STate Code
                                                - now require numeric code "20"
                                              positions 274-275 state code -
                                                - now require numeric code "20"
                                              positions 338-348 Employee
                                                Contributions to Kansas Public
                                                EE's Retirement System (KPERS,
                                                KPF or Judges)
  03-DEC-04 rsethupa    115.25  4045592       OH_CCAAA RS record
                                              positions 338-412 is now blank
  07-DEC-04 rsethupa    115.26  4052268       For WV RE record
                                              positions
					      7 : Agent Indicator code
					      17-25 : Agent for EIN
					      31-39 : Other EIN
  23-DEC-04 rsethupa    115.27  4084765       Added logic to display NJ DIPP Plan ID
                                              even if it is less than 14 characters
  04-APR-05 meshah      115.28  4279809       changed the r_input_34 for AL in
                                              the RS record.
  07-Nov-05 sudedas     115.29  4391218       RA,RW,RO,RT and RU W2 Format changed.
  09-Nov-05 saurgupt    115.30  4720007       Postion 341-351 : RS record for IN moves by one
                                              position.
  09-Nov-05 kvsankar    115.31  4502738       RE, RW, RT record added for MO_KNSAS
                                              Removed Code that was commented.
  11-Nov-05 kvsankar    115.32  4730413       OH RS record SD has incorrect positioning
                                              for SD code. It should be right justified and
                                              blank filled in positions 331-337.
  15-Nov-05 kvsankar    115.33  4728539       For RS 368-369 should be filled with ZERO's
                                              for Maryland
  16-Nov-05 kvsankar    115.34  4739790       Modified RE, RW and RS record for MO_KNSAS
  29-Nov-05 sudedas     115.35  4665713       Modified RW, RO, RS and RT Record for Puerto Rico W2
                                4859212       Modified RW Pos: 342 - 352 and RT Pos: 220 - 234
  17-Aug-06 sudedas     115.36  5256745       Modified RW Pos: 441 - 451 , Pos: 452 - 462
                                              RT Pos: 370 - 384 , Pos: 385 - 399
                                              RO Pos: 266 - 274.
                                4736977       Modified RS Record Pos: 368 - 369 for MD. Should now
                                              report W4 Withholding Allowances for Maryland.
  26-Oct-06 vmkulkar    115.37  5513076       Modified RS pos 73-94 , pos : 95-116 and pos : 357-359
					      for the state of INDIANA
  03-Nov-06 vmkulkar    115.38  5513076       Modified RS pos 331-343 , pos : 344-354 and pos : 355-359
                                5637673       and 360-512 blanks for INDIANA
  10-Nov-06 sausingh    115.39  5651314       Modified RS pos 298-307 for GEORGIA
  14-Nov-06 sausingh    115.40  5651314       Removed (115.38=120.10) from
                                              line 5 to remove GSCC compliencnce
  14-Nov-06 sausingh    115.40  5651314       Modified RS pos 298-307 for GEORGIA
  22-Nov-06 sudedas     115.41  5640748       Modified RE Record for State of Maryland.
  28-Nov-06 vmkulkar	115.42  5668970       Modified
					      RO pos 265 civil status
					      RS 274-275
					      RU pos 55-69 zero   for Puerto Rico(PR).
  29-Nov-06 sudedas     115.43  5686164       Modified RE Record for Maryland , added nvl.
  04-Dec-06 sudedas     115.44  5693183       RS Rec Pos: 248 - 267 Blank for GA.
  14-dec-06 djoshi      115.45  5717304       RS record position 307 fixed for
                                              KS and NJ

  14-dec-06 djoshi      115.46  5717304       RS record position 307 fixed for
                                              KS and NJ
  15-Dec-06 sudedas     115.47  5717438       RS Record Pos : 298 - 307 Modified
                                              for ELSE section.
                                              (Earlier code only for GA)
  28-Dec-06 alikhar     115.49  5696443       RS Record for GA modified. Two new fields.
                                              Pos 338-412 (FEIN) and Pos 413-487 (SIT).
  03-Jan-07 sudedas     115.50  5739737       Position 341 - 343 Modified for Indiana RS Record.
  13-Jan-07 sudedas     115.51  5760355       Maryland RE Record Position: 273 - 294 should
                                5759976       report Address Line 1 (Employer Delivery Address)
  16-Feb-07 vaprakas    115.52  5876054       Fixed mutilple issue in RS and RT records for PR
  16-Feb-07 sudedas     115.53  5886247       City Name to be displayed for Tax Withheld in Ohio-RITA
  26-Oct-07 svannian    115.55  6330489       RA RECORD Modified,
                                              Position: 20-23 ,Software Vendor code(1334)
                                              Position: 24-28 ,blank
                                              RO RECORD Modified ,
                                              Position: 265,blank
                                              changes for the Federal and ALL STATES
  02-Nov-07 svannian   115.56  5155648        For Transfer State FED and State PR, position 275-278 of
					      RO record and 408-418 of RW Record made to Zero.
  22-Nov-07 sjawid     115.57  6641801        For State SC RS record Pos 197-202 modified to
                       115.58                 populate  Reporting period.
  07-Dec-07 vmkulkar   115.59  6644795        Added function format_W2_RV_record
			       6648007
  07-Dec-07 svannian   115.61  6648064        430-512 of Rw record made to blank fill for indiana
  07-Dec-07 vmkulkar   115.64	              PR RS Rec 338-347 Blank fill
  10-Dec-07 svannian   115.65  6644795        For PR - RU RECORD 10 - 24 zero fill
                                              40 - 29 zero fill
					      RO RECORD
					      34-99 zero fill
  26-Dec-07 svannian   115.70  6684920        RA pos 172-512 made blank
                                              RE pos 219 made blank
  02-Jan-08 vmkulkar   115.73  6720630        RS 274-275 MI made blank
  09-Jan-08 vmkulkar   115.75  6650931        Reverted back the CCA changes made in the last version.
  21-apr-08	svannian   115.77  6855543        GA pos 340 - 482 changed as stated in bug 6855543
  19-nOV-08 SKPATIL    115.78  7045241        Making RE record for LA  position 219 as required at format_W2_RE_record()
  13-Feb-09 skpatil    115.90  8243215        Making pos 197-202 required in RS record for state of DC
  29-Oct-09 svannian   115.91  9065558        Changes foe WI made in RS record
  19-Mar-10 emunisek   115.104 9356178        Overloaded function format_mmref_address
                                              to accommodate the phone number requirement
                                              of Florida SQWL.This will be used only for the purpose of Florida SQWL.All other
                                              calls to the function format_mmref_address will use the existing function
  24-Mar-10 emunisek   115.105 9356178        Reorganized the code as per the suggestions
                                              made in codereview.
  30-Mar-10 emunisek   115.106 9356178        Placed special character check on Phone Number
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
       IF p_record_name in ('RU','RT','RF','RCU','RCT','RCF') THEN
--{
          l_length := 15;
          IF ( (p_record_name = 'RF' ) AND
               (p_report_qualifier = 'CT') ) THEN
              l_length := 16;
          END IF;
--}
       ELSIF p_record_name in ('RS','RO','RW','RCW','RCO') THEN
--{
          l_length := 11;
          IF ((p_record_name = 'RS') AND
              (p_input_3 = 'Other State Data')
             ) THEN
             l_length := 10;
             hr_utility.trace('RS. Other State Data.l_length = '||to_char(l_length));
          ELSIF p_record_name = 'RS' THEN
--{
             IF p_report_qualifier = 'NJ' THEN
                IF ((p_input_3 = 'SDI Withheld') OR
                    (p_input_3 = 'Unemployment Insurance Tax')) THEN
                   l_length := 5;
                ELSIF p_input_3 = 'Deferred Comp' THEN
                   l_length := 9;
                ELSIF p_input_3 = 'MIF' THEN  --  Bug 4014356
		   l_length := 3;
                END IF;
             END IF; --NJ
--}
          END IF; --RS Record

       /* Bug 5640748 */
/*
       ELSIF p_record_name = 'RE' THEN
          IF p_report_qualifier = 'MD' THEN
             IF (( p_input_3 = 'Tot Withheld Tax Reported') OR
                 ( p_input_3 = 'SIT Withheld') OR
                 ( p_input_3 = 'MW508 ER Credits') OR
                 ( p_input_3 = 'MW508 ER Amt Tax Due') OR
                 ( p_input_3 = 'MW508 ER Amt Balance Due') OR
                 ( p_input_3 = 'MW508 ER Amt Overpayment') OR
                 ( p_input_3 = 'MW508 ER Amt Credit') OR
                 ( p_input_3 = 'MW508 ER Amt Refunded') OR
                 ( p_input_3 = 'State taxable Wages') OR
                 ( p_input_3 = 'Other State Data')
                 ) THEN
                 l_length := 12 ;
             END IF ; -- p_input_3
            END IF ; -- MD
*/
--}
       END IF; -- p_record_name
return l_length;
END set_req_field_length; -- End of set_req_field_length
--

PROCEDURE format_w2_contact_prsn_info (
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
      p_contact_prsn_name      := lpad(' ',27);
      p_contact_prsn_phone     := lpad(' ',15);
      p_contact_prsn_extension := lpad(' ',5);
      p_contact_prsn_email     := lpad(' ',40);
      p_contact_prsn_fax       := lpad(' ',10);
--}
   ELSE
--{
      p_contact_prsn_name  :=rpad(substr(nvl(upper(p_contact_prsn_name),' '),1,27),27);
      p_contact_prsn_email :=rpad(substr(nvl(upper(p_contact_prsn_email),' '),1,40),40);
      p_contact_prsn_fax :=
           rpad(substr(nvl(replace(p_contact_prsn_fax,' '),' '),1,10),10);
--}
   END IF;
END format_w2_contact_prsn_info;
-- End of famatting Contact Person info used for reportin W2
--

--
-- Procedure to Format Employee and Employer Address
-- This procedure is being called from function GET_EE_ADDRESS
--                                          and GET_ER_ADDRESS
--
PROCEDURE  format_mmref_address(
                   p_name                 IN  varchar2,
                   p_locality_company_id  IN  varchar2,
                   p_emp_number           IN  varchar2,
                   p_address_line_1       IN  varchar2,
                   p_address_line_2       IN  varchar2,
                   p_address_line_3       IN  varchar2,
                   p_town_or_city         IN  varchar2,
                   p_state                IN  varchar2,
                   p_postal_code          IN  varchar2,
                   p_country              IN  varchar2,
                   p_region_1             IN  varchar2,
                   p_region_2             IN  varchar2,
                   p_valid_address        IN  varchar2,
                   p_item_name            IN  varchar2,
                   p_report_type          IN  varchar2,
                   p_record_name          IN  varchar2,
                   p_validate             IN  varchar2,
                   p_local_code           IN  varchar2,
                   p_exclude_from_output  OUT nocopy varchar2,
                   sp_out_1               IN OUT nocopy varchar2,
                   sp_out_2               IN OUT nocopy varchar2,
                   sp_out_3               IN OUT nocopy varchar2,
                   sp_out_4               IN OUT nocopy varchar2,
                   sp_out_5               IN OUT nocopy varchar2,
                   sp_out_6               IN OUT nocopy varchar2,
                   sp_out_7               IN OUT nocopy varchar2,
                   sp_out_8               IN OUT nocopy varchar2,
                   sp_out_9               IN OUT nocopy varchar2,
                   sp_out_10              IN OUT nocopy varchar2 ) IS
--
TYPE message_columns IS RECORD(
     p_mesg_description varchar2(100),
     p_mesg_value varchar2(100),
     p_output_value varchar2(100));
message_parameter_rec message_columns;
TYPE message_parameter_record IS TABLE OF message_parameter_rec%TYPE
INDEX BY BINARY_INTEGER;
message_record message_parameter_record;

l_level           varchar2(1);
l_mesg_name       varchar2(50);
l_name_or_number  varchar2(50);
l_err             boolean := FALSE;
l_hyphen_position number(10);
c_item_name       varchar2(100);
l_name            varchar2(100);
l_location_addr   varchar2(100);
l_delivery_addr   varchar2(100);
l_State           varchar2(100);
l_city            varchar2(100);

BEGIN
   c_item_name     := p_item_name;
   l_name          := rpad(upper(substr(nvl(p_name,lpad(' ',57)),1,57)),57);
   l_location_addr := nvl(rpad(replace(replace(upper(substr(ltrim
                   (p_address_line_2 ||' '||p_address_line_3), 1, 22))
                    ,',','_'),''''),22) ,lpad(' ',22));
   l_delivery_addr := nvl(rpad(replace(replace(upper(substr(ltrim(
                      p_address_line_1),1,22)),',','_'),''''),22),lpad(' ',22));
   l_State         := upper(rpad(substr(p_state,1,2),2));
   l_city          := nvl(upper(rpad(substr(p_town_or_city, 1, 22), 22)),
                      lpad(' ',22));
-- Format for Valid Address
   IF p_valid_address = 'Y' THEN
--{
      hr_utility.trace('Valid Address found  ');
      hr_utility.trace('Location address '||l_location_addr);
      hr_utility.trace('Delivery address '||l_delivery_addr);
      hr_utility.trace('town_or_city     '||l_city);
      hr_utility.trace('postal_code      '||p_postal_code);
      hr_utility.trace('State            '||l_state);
      hr_utility.trace('p_country        '||p_country);

      IF c_item_name = 'EE_ADDRESS' THEN
         l_level := 'A';
         l_mesg_name := 'PAY_INVALID_EE_FORMAT';
         l_name_or_number := p_emp_number;
      ELSIF c_item_name = 'ER_ADDRESS' THEN
         l_level := 'P';
         l_mesg_name := 'PAY_INVALID_ER_FORMAT';
         l_name_or_number := substr(p_name,1,50);
      END IF;

      message_record(1).p_mesg_description:='Invalid address.Address Line1 is null';
      message_record(2).p_mesg_description:='Invalid address.City is null';
      message_record(3).p_mesg_description:='Invalid address.State is null';
      message_record(4).p_mesg_description:='Invalid address.Zip is null';
      message_record(1).p_mesg_value:= l_delivery_addr;
      message_record(2).p_mesg_value:= l_city;
      message_record(3).p_mesg_value:= l_state;
      message_record(4).p_mesg_value:= p_postal_code;

      FOR i in 1..4 LOOP
         IF message_record(i).p_mesg_value IS NULL THEN
            pay_core_utils.push_message(801,l_mesg_name,l_level);
            pay_core_utils.push_token('record_name', p_record_name);
            pay_core_utils.push_token('name_or_number', l_name_or_number);
            pay_core_utils.push_token('description',
                                    message_record(i).p_mesg_description);
            l_err:=TRUE;
          END IF;
      END LOOP;

      sp_out_1 := l_location_addr;
      sp_out_2 := l_delivery_addr;
      sp_out_3 := l_city;

      IF (p_country = 'US' OR p_country IS NULL )THEN
         sp_out_9:= lpad(' ',2);
         IF p_region_2 IS NOT NULL THEN
            sp_out_4 := l_state;   --State abbreviation
            sp_out_7 := lpad(' ',23); --foreign state/province
         ELSE  --The region is null.
            sp_out_4 := lpad(' ',2);
            sp_out_7 := lpad(' ',23);
         END IF;
      ELSE  -- country is not US
         sp_out_4 := lpad(' ',2);
                                    /* Bug:2133985 foreign state/province*/
         sp_out_7 := upper(rpad(substr(nvl(p_region_1,' '),1,23),23));
         sp_out_9:= upper(rpad(substr(p_country,1,2),2));
      END IF;

      /* See if the zip code has a zip code extension ie. contains a hyphen */

      IF p_postal_code IS NOT NULL THEN
--{
         l_hyphen_position := instr(p_postal_code, '-');

         /* sp_out_5: zip code             Len: 5
            sp_out_6: zip code extension   Len: 4
            sp_out_8: foreign postal_code  Len: 15 */

         IF ( (p_country = 'US') OR ( p_country IS NULL ) ) THEN
            IF l_hyphen_position = 0 THEN
               sp_out_5:= upper(rpad(substr(p_postal_code,1,5),5));
               sp_out_6 := lpad(' ', 4);
            ELSE
               sp_out_5:= upper(rpad(substr(substr
                               (p_postal_code,1,l_hyphen_position-1),1,5),5));
               sp_out_6 := upper(rpad(substr(
                                 p_postal_code,l_hyphen_position+1,4),4));
            END IF;
            sp_out_8:= lpad(' ',15);
         ELSE /* ( (l_country = 'US') OR ( l_country IS NULL ) ) */
            sp_out_5:= lpad(' ',5);                  --zip
            sp_out_6:= lpad(' ', 4);                 --extension
            sp_out_8:= upper(rpad(substr(p_postal_code,1,15),15)); --foreign zip
         END IF;
--}
      ELSE /*  l_postal_code IS NULL.*/
--{
         sp_out_5:= lpad(' ',5);                                   --zip
         sp_out_8:= lpad(' ',15);                                  -- foreign zip
         sp_out_6:= lpad(' ', 4);                                  --extension
         hr_utility.trace('Zip or Postal Code is null');
--}
      END IF;
      IF ((p_item_name = 'ER_ADDRESS') OR ( p_item_name = 'CR_ADDRESS')) THEN
         sp_out_10:= p_name;
         hr_utility.trace('Organization Name = '||p_name);
         /* Locality_Company_Id */
         IF ((p_item_name = 'ER_ADDRESS') and (p_local_code = 'PHILA')) THEN
            sp_out_8:= lpad(NVL(p_locality_company_id,' '),15);
         END IF;
      ELSIF p_item_name = 'EE_ADDRESS' THEN
         sp_out_10:= pay_us_reporting_utils_pkg.Character_check(p_emp_number);
      END IF;
--}
--
-- when address is Invalid
--
   ELSE
--{
      IF p_item_name IN ('EE_ADDRESS',
                         'ER_ADDRESS',
                         'CR_ADDRESS') THEN
         sp_out_1:=lpad(' ',22);
         sp_out_2:=lpad(' ',22);
         sp_out_3:=lpad(' ',22);
         sp_out_4:=lpad(' ',2);
         sp_out_5:=lpad(' ',5);
         sp_out_6:=lpad(' ',9);
         sp_out_7:=lpad(' ',23);
         sp_out_8:=lpad(' ',15);
         sp_out_9:=lpad(' ',2);
         sp_out_10:=lpad(' ',57);
      END IF;
      IF ( (p_item_name = 'ER_ADDRESS')OR
           (p_item_name = 'EE_ADDRESS')
         ) THEN
         l_err :=TRUE;
      END IF;
--}
   END IF;  --p_valid_address
   hr_utility.trace('location address       '||sp_out_1);
   hr_utility.trace('delivery address       '||sp_out_2);
   hr_utility.trace('City                   '||sp_out_3);
   hr_utility.trace('State                  '||sp_out_4);
   hr_utility.trace('Zip                    '||sp_out_5);
   hr_utility.trace('Zip Code Extension     '||sp_out_6);
   hr_utility.trace('Foreign State/Province '||sp_out_7);
   hr_utility.trace('Foreign Zip            '||sp_out_8);
   hr_utility.trace('Country                '||sp_out_9);
   IF (p_item_name = 'ER_ADDRESS') THEN
      hr_utility.trace('Organization Name   '||sp_out_10);
   ELSE
      hr_utility.trace('Employee Number     '||sp_out_10);
   END IF;
--
-- Check to include or exclude record on the basis of validity of address
--
   IF p_validate = 'Y' THEN
      IF l_err THEN
         p_exclude_from_output := 'Y';
         hr_utility.trace('p_validate is Y .error '||p_exclude_from_output);
      END IF;
   END IF;
   IF p_exclude_from_output IS NULL THEN
      p_exclude_from_output := 'N';
   END IF;
END format_mmref_address;  --End of Procedure Validate_address

--Overloaded format_mmref_address procedure for Bug#9356178

PROCEDURE  format_mmref_address(
                   p_name                 IN  varchar2,
                   p_locality_company_id  IN  varchar2,
                   p_emp_number           IN  varchar2,
                   p_address_line_1       IN  varchar2,
                   p_address_line_2       IN  varchar2,
                   p_address_line_3       IN  varchar2,
                   p_town_or_city         IN  varchar2,
                   p_state                IN  varchar2,
                   p_postal_code          IN  varchar2,
                   p_country              IN  varchar2,
                   p_region_1             IN  varchar2,
                   p_region_2             IN  varchar2,
		   p_phone_number         IN  varchar2,
                   p_valid_address        IN  varchar2,
                   p_item_name            IN  varchar2,
                   p_report_type          IN  varchar2,
                   p_record_name          IN  varchar2,
                   p_validate             IN  varchar2,
                   p_local_code           IN  varchar2,
                   p_exclude_from_output  OUT nocopy varchar2,
                   sp_out_1               IN OUT nocopy varchar2,
                   sp_out_2               IN OUT nocopy varchar2,
                   sp_out_3               IN OUT nocopy varchar2,
                   sp_out_4               IN OUT nocopy varchar2,
                   sp_out_5               IN OUT nocopy varchar2,
                   sp_out_6               IN OUT nocopy varchar2,
                   sp_out_7               IN OUT nocopy varchar2,
                   sp_out_8               IN OUT nocopy varchar2,
                   sp_out_9               IN OUT nocopy varchar2,
                   sp_out_10              IN OUT nocopy varchar2 ) IS
--
TYPE message_columns IS RECORD(
     p_mesg_description varchar2(100),
     p_mesg_value varchar2(100),
     p_output_value varchar2(100));
message_parameter_rec message_columns;
TYPE message_parameter_record IS TABLE OF message_parameter_rec%TYPE
INDEX BY BINARY_INTEGER;
message_record message_parameter_record;

l_level           varchar2(1);
l_mesg_name       varchar2(50);
l_name_or_number  varchar2(50);
l_err             boolean := FALSE;
l_hyphen_position number(10);
c_item_name       varchar2(100);
l_name            varchar2(100);
l_location_addr   varchar2(100);
l_delivery_addr   varchar2(100);
l_State           varchar2(100);
l_city            varchar2(100);
l_phone_number    varchar2(100);

BEGIN
   c_item_name     := p_item_name;
   l_name          := rpad(upper(substr(nvl(p_name,lpad(' ',57)),1,57)),57);
   l_location_addr := nvl(rpad(replace(replace(upper(substr(ltrim
                   (p_address_line_2 ||' '||p_address_line_3), 1, 22))
                    ,',','_'),''''),22) ,lpad(' ',22));
   l_delivery_addr := nvl(rpad(replace(replace(upper(substr(ltrim(
                      p_address_line_1),1,22)),',','_'),''''),22),lpad(' ',22));
   l_State         := upper(rpad(substr(p_state,1,2),2));
   l_city          := nvl(upper(rpad(substr(p_town_or_city, 1, 22), 22)),
                      lpad(' ',22));
-- Format for Valid Address
   IF p_valid_address = 'Y' THEN
--{
      hr_utility.trace('Valid Address found  ');
      hr_utility.trace('Location address '||l_location_addr);
      hr_utility.trace('Delivery address '||l_delivery_addr);
      hr_utility.trace('town_or_city     '||l_city);
      hr_utility.trace('postal_code      '||p_postal_code);
      hr_utility.trace('State            '||l_state);
      hr_utility.trace('p_country        '||p_country);
      hr_utility.trace('phone_number     '||p_phone_number);

      IF c_item_name = 'EE_ADDRESS' THEN
         l_level := 'A';
         l_mesg_name := 'PAY_INVALID_EE_FORMAT';
         l_name_or_number := p_emp_number;
      ELSIF c_item_name = 'ER_ADDRESS' THEN
         l_level := 'P';
         l_mesg_name := 'PAY_INVALID_ER_FORMAT';
         l_name_or_number := substr(p_name,1,50);
      END IF;

      message_record(1).p_mesg_description:='Invalid address.Address Line1 is null';
      message_record(2).p_mesg_description:='Invalid address.City is null';
      message_record(3).p_mesg_description:='Invalid address.State is null';
      message_record(4).p_mesg_description:='Invalid address.Zip is null';
      message_record(1).p_mesg_value:= l_delivery_addr;
      message_record(2).p_mesg_value:= l_city;
      message_record(3).p_mesg_value:= l_state;
      message_record(4).p_mesg_value:= p_postal_code;

      FOR i in 1..4 LOOP
         IF message_record(i).p_mesg_value IS NULL THEN
            pay_core_utils.push_message(801,l_mesg_name,l_level);
            pay_core_utils.push_token('record_name', p_record_name);
            pay_core_utils.push_token('name_or_number', l_name_or_number);
            pay_core_utils.push_token('description',
                                    message_record(i).p_mesg_description);
            l_err:=TRUE;
          END IF;
      END LOOP;

      sp_out_1 := l_location_addr;
      sp_out_2 := l_delivery_addr;
      sp_out_3 := l_city;

      IF (p_country = 'US' OR p_country IS NULL )THEN
         sp_out_9:= lpad(' ',2);
         IF p_region_2 IS NOT NULL THEN
            sp_out_4 := l_state;   --State abbreviation
            sp_out_7 := lpad(' ',23); --foreign state/province
         ELSE  --The region is null.
            sp_out_4 := lpad(' ',2);
            sp_out_7 := lpad(' ',23);
         END IF;
      ELSE  -- country is not US
         sp_out_4 := lpad(' ',2);
                                    /* Bug:2133985 foreign state/province*/
         sp_out_7 := upper(rpad(substr(nvl(p_region_1,' '),1,23),23));
         sp_out_9:= upper(rpad(substr(p_country,1,2),2));
      END IF;

      /* See if the zip code has a zip code extension ie. contains a hyphen */

      IF p_postal_code IS NOT NULL THEN
--{
         l_hyphen_position := instr(p_postal_code, '-');

         /* sp_out_5: zip code             Len: 5
            sp_out_6: zip code extension   Len: 4
            sp_out_8: foreign postal_code  Len: 15 */

         IF ( (p_country = 'US') OR ( p_country IS NULL ) ) THEN
            IF l_hyphen_position = 0 THEN
               sp_out_5:= upper(rpad(substr(p_postal_code,1,5),5));
               sp_out_6 := lpad(' ', 4);
            ELSE
               sp_out_5:= upper(rpad(substr(substr
                               (p_postal_code,1,l_hyphen_position-1),1,5),5));
               sp_out_6 := upper(rpad(substr(
                                 p_postal_code,l_hyphen_position+1,4),4));
            END IF;
            sp_out_8:= lpad(' ',15);
         ELSE /* ( (l_country = 'US') OR ( l_country IS NULL ) ) */
            sp_out_5:= lpad(' ',5);                  --zip
            sp_out_6:= lpad(' ', 4);                 --extension
            sp_out_8:= upper(rpad(substr(p_postal_code,1,15),15)); --foreign zip
         END IF;
--}
      ELSE /*  l_postal_code IS NULL.*/
--{
         sp_out_5:= lpad(' ',5);                                   --zip
         sp_out_8:= lpad(' ',15);                                  -- foreign zip
         sp_out_6:= lpad(' ', 4);                                  --extension

         hr_utility.trace('Zip or Postal Code is null');
--}
      END IF;
      IF ((p_item_name = 'ER_ADDRESS') OR ( p_item_name = 'CR_ADDRESS')) THEN
         sp_out_10:= p_name;
         hr_utility.trace('Organization Name = '||p_name);
         /* Locality_Company_Id */
         IF ((p_item_name = 'ER_ADDRESS') and (p_local_code = 'PHILA')) THEN
            sp_out_8:= lpad(NVL(p_locality_company_id,' '),15);
         END IF;
      ELSIF p_item_name = 'EE_ADDRESS' THEN
         sp_out_10:= pay_us_reporting_utils_pkg.Character_check(p_emp_number);
      END IF;
--}
--
-- when address is Invalid
--
   ELSE
--{
      IF p_item_name IN ('EE_ADDRESS',
                         'ER_ADDRESS',
                         'CR_ADDRESS') THEN
         sp_out_1:=lpad(' ',22);
         sp_out_2:=lpad(' ',22);
         sp_out_3:=lpad(' ',22);
         sp_out_4:=lpad(' ',2);
         sp_out_5:=lpad(' ',5);
         sp_out_6:=lpad(' ',9);
         sp_out_7:=lpad(' ',23);
         sp_out_8:=lpad(' ',15);
         sp_out_9:=lpad(' ',2);
         sp_out_10:=lpad(' ',57);
      END IF;
      IF ( (p_item_name = 'ER_ADDRESS')OR
           (p_item_name = 'EE_ADDRESS')
         ) THEN
         l_err :=TRUE;
      END IF;
--}
   END IF;  --p_valid_address

   l_phone_number := p_phone_number;

   l_phone_number:= replace(p_phone_number,'-',''); /*To remove the '-' entered in Phone Number*/

   l_phone_number:= replace(pay_us_reporting_utils_pkg.Character_check(l_phone_number),' ',''); /*To remove the Special Characters*/

   sp_out_6:= sp_out_6||'|'||nvl(l_phone_number,'0000000000'); --Phone Number is tagged to ZipCode extension to avoid new variable creation
                                                               --It is done only for FLSQWL usage and will be removed from this
                                                               --variable once value is passed to FL_XML_EMPLOYER_SQWL formula
                                                               --The zip code extension and phone number are separeted by Pipe | symbol

   hr_utility.trace('location address       '||sp_out_1);
   hr_utility.trace('delivery address       '||sp_out_2);
   hr_utility.trace('City                   '||sp_out_3);
   hr_utility.trace('State                  '||sp_out_4);
   hr_utility.trace('Zip                    '||sp_out_5);
   hr_utility.trace('Zip Code Extension     '||substr(sp_out_6,1,4));
   hr_utility.trace('Phone Number           '||substr(sp_out_6,5));
   hr_utility.trace('Foreign State/Province '||sp_out_7);
   hr_utility.trace('Foreign Zip            '||sp_out_8);
   hr_utility.trace('Country                '||sp_out_9);
   IF (p_item_name = 'ER_ADDRESS') THEN
      hr_utility.trace('Organization Name   '||sp_out_10);
   ELSE
      hr_utility.trace('Employee Number     '||sp_out_10);
   END IF;
--
-- Check to include or exclude record on the basis of validity of address
--
   IF p_validate = 'Y' THEN
      IF l_err THEN
         p_exclude_from_output := 'Y';
         hr_utility.trace('p_validate is Y .error '||p_exclude_from_output);
      END IF;
   END IF;
   IF p_exclude_from_output IS NULL THEN
      p_exclude_from_output := 'N';
   END IF;
END format_mmref_address;  --End of Overloaded format_mmref_address

-- Formatting RA record for W2 reporting
--
/*--------------------- Parameter mapping Starts. ----------------------
  Record Identifier,                                   --> p_input_1
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
  ------------------------ Parameter mapping Ends. -------------------------
*/

FUNCTION format_W2_RA_record(
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
  hr_utility.trace('RA Record Formatting started ');
  hr_utility.trace(' Format_W2_RA_Record Begin for Company '|| p_input_7);
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

      /* Pos:12 - 216 blank for PA. */
      IF ((p_report_qualifier = 'PA') OR
          (p_report_qualifier = 'LA'))
      THEN
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
--}
      ELSIF p_report_qualifier = 'MA' THEN
--{
         l_pin := lpad(' ',17);
         r_input_5 := lpad(' ',6);
         r_input_6 := lpad(' ',2);
         r_input_14 := lpad(' ',23);
         r_input_15 := lpad(' ',15);
         r_input_16 := lpad(' ',2);
         r_input_24 := lpad(' ',23);
         r_input_25 := lpad(' ',15);
         r_input_26 := lpad(' ',2);
--}
      ELSIF p_report_qualifier = 'CT' THEN
--{
         l_pin := lpad(' ',17);
         r_input_5 := lpad(' ',6);
         r_input_6 := lpad(' ',2);
         r_input_4 := lpad(' ',1);/* Bug: 2145032 */
--}
          ELSIF --(( p_report_qualifier = 'PA_PHILA') OR
            -- ( p_report_qualifier = 'MO_STLOU')) THEN
            p_report_qualifier = 'MO_STLOU' THEN   /* 7579598 */

         l_pin := lpad(' ',17) ;  -- Bug 4391218

      ELSE
--{
         /* Bug 4391218 Pos: 12 - 19 (8 characters) */
         l_pin := rpad(substr(nvl(p_input_3,' '),1,8),17);
         hr_utility.trace(' l_pin = '||l_pin);
--}
      END IF;
/*6330489*/
      --  IF p_report_qualifier not in ('MO_KNSAS','MO_STLOU','OH_CCAAA','OH_DAYTO','OH_RTCCA','PA_PHILA')
    IF p_report_qualifier not in ('MO_KNSAS','MO_STLOU','OH_CCAAA','OH_DAYTO','OH_RTCCA') /*7579598*/
      THEN
      l_pin := rpad((rpad(substr(nvl(p_input_3 ,' '),1,8),8,' ') || '1334'),17);
      END IF ;

      IF p_report_qualifier = 'IN' THEN
         /* 6684920 */
         r_input_14 := lpad(' ',23);
         r_input_15 := lpad(' ',15);
         r_input_16 := lpad(' ',2);
   /*      r_input_17 := lpad(' ',57);
         r_input_18 := lpad(' ',22);
         r_input_19 := lpad(' ',22);
         r_input_20 := lpad(' ',22);
         r_input_21 := lpad(' ',2);
         r_input_22 := lpad(' ',5);
         r_input_23 := lpad(' ',5);
         r_input_24 := lpad(' ',23);
         r_input_25 := lpad(' ',15);
         r_input_26 := lpad(' ',2);
         r_input_27 := lpad(' ',27);
         r_input_28 := lpad(' ',15);
         r_input_29 := lpad(' ',5);
         r_input_30 := lpad(' ',40);
         r_input_31 := lpad(' ',10);
         r_input_32 := lpad(' ',1);
         r_input_33 := lpad(' ',1);  */
         /* 7569563 */
      END IF;

      /* Checking for preferred method of problem notification code which is
         1=email, 2=postal service  */
      IF ((p_input_32 = '1' ) OR
          (p_input_32 = '2' )
         )
      THEN
         hr_utility.trace('Preferred method of code is correct. it is '||p_input_32);
         l_pblm_code:= p_input_32;
      ELSE
         hr_utility.trace('Preferred method of code is incorrect. it is '||p_input_32);
         l_pblm_code:= lpad('2',1);
      END IF;
      -- Bug # 2682428
      --
      -- commented to fix bug # 4016439
      /*IF (p_report_qualifier = 'OH_DAYTO') THEN
         l_pblm_code:= '2';
      END IF;*/
      -- Bug # 2736928
      --
      IF (p_report_qualifier = 'PR') THEN
         l_pblm_code:= '2';
      END IF;

      If( (p_input_33 = 'A' )OR
          (p_input_33 = 'S' )OR
          (p_input_33 = 'L' )OR
          (p_input_33 = 'P' )OR
          (p_input_33 = 'O' ))   THEN
        l_preparer_code:= p_input_33;
        hr_utility.trace('l_preparer_code  is correct. it is '||p_input_33);
      ELSE
        l_preparer_code:= lpad(' ',1);
        hr_utility.trace('l_preparer_code  is incorrect. it is '||p_input_33);
      END IF;

       /* fix for bug # 2680189 */
    /*  IF (p_report_qualifier = 'PA_PHILA') THEN
      --   r_input_3  := ' ';
         r_input_4  := ' ';
         r_input_5  := ' ';
         r_input_6  := ' ';
         r_input_7  := ' ';
      END IF; */

      /* Fix for Bug # 2680070 and 2680189 */
   --   IF ((p_report_qualifier = 'MO_STLOU') OR
    --      (p_report_qualifier = 'PA_PHILA')) THEN
    IF ((p_report_qualifier = 'MO_STLOU')) THEN
--{
         r_input_8  := ' ';
         r_input_9  := ' ';
         r_input_10 := ' ';
         r_input_11 := ' ';
         r_input_12 := ' ';
         r_input_13 := ' ';
         r_input_14 := ' ';
         r_input_15 := ' ';
         r_input_16 := ' ';
--}
      END IF; /*7579598*/

      /* Fix for Bug # 2680070  and #3130999 and # 3292989*/
      IF (p_report_qualifier = 'MO_STLOU')  THEN
         l_pin      := lpad(' ',17);
	 r_input_4  := ' ';
	 r_input_5  := ' ';
	 r_input_6  := ' ';
         r_input_18 := ' ';
         r_input_19 := ' ';
         r_input_20 := ' ';
         r_input_21 := ' ';
         r_input_22 := ' ';
         r_input_23 := ' ';
         r_input_24 := ' ';
         r_input_25 := ' ';
         r_input_26 := ' ';
         r_input_27 := ' ';
         r_input_28 := ' ';
         r_input_29 := ' ';
         r_input_30 := ' ';
         r_input_31 := ' ';
      END IF;
      -- Bug # 3293083
      IF (p_report_qualifier = 'LA') THEN
         r_input_18 := ' ';
         r_input_24 := ' ';
         r_input_25 := ' ';
         r_input_26 := ' ';
         r_input_27 := ' ';
         r_input_28 := ' ';
         r_input_29 := ' ';
         r_input_30 := ' ';
         r_input_31 := ' ';
      END IF;

      /* Fix for Bug # 2680070 */
      IF p_report_qualifier = 'MO_STLOU' THEN
         r_input_17 := ' ';
      END IF;

      IF ((p_report_qualifier = 'MA') OR
          (p_report_qualifier = 'PA') OR
       --   (p_report_qualifier = 'PA_PHILA') OR      -- fix for bug # 2680189
          (p_report_qualifier = 'CT') OR
          (p_report_qualifier = 'LA') OR            -- fix for bug # 3109990
          (p_report_qualifier = 'MO_STLOU')) THEN -- OR /* 7569563 */
        --  (p_report_qualifier = 'IN')) THEN /* 6684920 */
--{
         l_pblm_code     := lpad(' ',1);
         l_preparer_code := lpad(' ',1);
--}
      END IF;

      IF p_report_qualifier = 'MD' then /* 7572352 */
      r_input_4 := lpad('0',1);
      r_input_5 := lpad(' ',6);
      END IF ;

-- Formatiing Ends
--

-- RA Record of Flat Type
--
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
--
         hr_utility.trace('RA Record of FLAT Type  -----');
         ret_str_len:=length(return_value);

   ELSIF p_input_40 = 'CSV' THEN
      hr_utility.trace('RA Record  of CSV Type formatting Starts ----');
      return_value:='RA'||','||p_input_2||','||p_input_3||','||lpad(' ',9) -- Bug#  4391218
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
      hr_utility.trace(' RA Record of CSV Type formatting Ends----');
      hr_utility.trace(return_value);
   END IF;
   p_error := l_exclude_from_output_chk;
   ret_str_len:=length(return_value);
   return return_value;
END format_W2_RA_record; -- End of formatting W2 RA Record

--vmkulkar
-- Formatting of RV Record Start
FUNCTION format_W2_RV_record(
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


    /*	Specifications for PR

	1-2     Record Identifier			--> p_input_1,
	3-12    Employer phone number			--> p_input_2,
	13-17   Access Code				--> p_input_3,
	18-32   Cost of Pension or Annuity		--> p_input_4,
	33-47   Reimbursed Expenses			--> p_input_5,
	48-62   Contributions to Qualified Lanns	--> p_input_6,
	63-77   Salaries under act 324 of 2004		--> p_input_7,
	78-92   Uncollected Social Security Tax on Tips --> p_input_8,
	93-107  Uncollected Medicare Tax on Tips        --> p_input_9,
        108-512 Blank							 */

      /*  Specifications for MD

	1-2	Record identifier			--> p_input_1
	3-4	State Code(24)				--> p_input_2
	5-9	State record('MW508')			--> p_input_3
	10-13	MW508 ER - Tax year			--> p_input_4
	14-22	MW508 ER Id number			--> p_input_5
	23-30	MW508 Central Registration		--> p_input_6
		number(Tax Withholding Acct Number)
	31-87   MW508 ER Name				--> p_input_7
	88-109  MW508 ER St Address			--> p_input_8
	110-131 MW508 City				--> p_input_9
	132-133 MW508 State				--> p_input_10
	134-138 MW508 Zipcode				--> p_input_11
	139-142 MW508 Zip Extension			--> p_input_12
	143-148 MW508 ER Number of W2s			--> p_input_13
	149-160 MW508 Total amt of taxes		--> p_input_14
	161-172 MW508 ER Total Tax			--> p_input_15
	173-187 MW508 ER Credits			--> p_input_16
	185-196 MW508 ER amt tax due			--> p_input_17
		total w/h amt due after credits
	197-208 MW508 ER amt balance due		--> p_input_18
	209-220 MW508 ER amt overpayment		--> p_input_19
	221-232 MW508 ER amt of overpayment		--> p_input_20
	233-244 MW508 amt overpayment refunded		--> p_input_21
	245-256 MW508 gross payroll			--> p_input_22
	257-268 MW508 ER State pickup amt		--> p_input_23
	269-296 ER Rep name				--> p_input_24
	297-311 ER Rep title				--> p_input_25
	312-319 ER Rep Date				--> p_input_26
	320-329 ER Rep phone number			--> p_input_27
	330-330 ER Total File Indicator "Y"		--> p_input_28
	331-512 Blank							*/



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
l_exclude_from_output_chk  boolean;
return_value               varchar2(32767);


BEGIN
   hr_utility.trace('RV Record Formatting started ');
-- Initializing local variables with parameter value
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


-- Use separate IF conditions for each report_qualifier.

IF p_report_qualifier = 'PR' THEN

	r_input_2 := lpad(nvl(r_input_2,' '),10,' ');
	r_input_3 := lpad(nvl(substr(replace(r_input_3,' '),1,5),' '),5);
	r_input_4 := lpad(nvl(r_input_4,' '),15,'0');
	r_input_5 := lpad(nvl(r_input_5,' '),15,'0');
	r_input_6 := lpad(nvl(r_input_6,' '),15,'0');
	r_input_7 := lpad(nvl(r_input_7,' '),15,'0');
	r_input_8 := lpad(nvl(r_input_8,' '),15,'0');
	r_input_9 := lpad(nvl(r_input_9,' '),15,'0');

END IF;

IF p_report_qualifier = 'NE' or p_report_qualifier = 'IL' THEN /* 6651399 */
/* 7569151 */
	r_input_2 := lpad(nvl(r_input_2,'0'),7,'0');
	r_input_3 := lpad(nvl(r_input_3,'0'),15,'0');
	r_input_4 := lpad(nvl(r_input_4,'0'),15,'0');

END IF;

IF p_report_qualifier = 'IN' THEN /* 7569563 */

	r_input_2 := lpad(nvl(r_input_2,' '),2,' ');
	r_input_3 := lpad(nvl(r_input_3,'0'),13,'0');
	r_input_4 := lpad(nvl(r_input_4,'0'),13,'0');
	r_input_5 := lpad(nvl(r_input_5,'0'),13,'0');
	r_input_6 := lpad(nvl(r_input_6,'0'),13,'0');

END IF;

IF p_report_qualifier = 'ID' THEN /* 7565870 */

	r_input_2 := lpad(replace(nvl(r_input_2,' '),'-',''),9,' ');
	r_input_3 :=  lpad(nvl(replace(translate(r_input_3,'?/:,;.'' ', '#'), '#', ''),' '),4,' ');
	r_input_4 := lpad(nvl(r_input_4,'0'),9,'0');
	r_input_5 := lpad(nvl(r_input_5,' '),1,' ');
	r_input_6 := lpad(nvl(r_input_6,' '),6,' ');
	r_input_7 := lpad(nvl(r_input_7,'0'),11,'0');
	r_input_8 := lpad(nvl(r_input_8,'0'),11,'0');
	r_input_9 := lpad(nvl(r_input_9,'0'),11,'0');

	if r_input_5 = 'B' then
	r_input_10 := lpad(nvl(r_input_10,'0'),11,'0');
	else
	r_input_10 := lpad(' ',11,' ');
	end if;

	if r_input_5 = 'B' then
    r_input_11 := lpad(nvl(r_input_11,'0'),11,'0');
	else
	r_input_11 := lpad(' ',11,' ');
	end if;

	r_input_12 := lpad(nvl(replace(r_input_12,'-',''),'0'),11,'0');
	r_input_13 := lpad(nvl(r_input_13,' '),1,' ');
	r_input_14 := lpad(nvl(r_input_14,'0'),11,'0');
	r_input_15 := lpad(nvl(r_input_15,'0'),11,'0');
	r_input_16 := lpad(nvl(replace(r_input_16,'-',''),'0'),11,'0');
	r_input_17 := lpad(nvl(r_input_17,' '),1,' ');
	r_input_18 := lpad(nvl(r_input_18,'0'),7,'0');
	r_input_19 := lpad(nvl(r_input_19,'0'),7,'0');
	r_input_20 := lpad(nvl(r_input_20,'0'),1,'0');
	r_input_21 := lpad(nvl(r_input_21,'0'),7,'0');
	r_input_22 := lpad(nvl(r_input_22,'0'),11,'0');
	r_input_23 := lpad(nvl(replace(r_input_23,'-',''),'0'),11,'0');
	r_input_24 := lpad(nvl(r_input_24,' '),1,' ');

END IF;


IF p_report_qualifier = 'MD' THEN

	    r_input_4  := rpad(substr(nvl(r_input_4,' '),1,4),4);
            r_input_5  := rpad(substr(replace(replace(nvl(replace(p_input_5,' '),' '),'-'),'/'),1,9),9);
            r_input_6  := lpad(replace(replace(nvl(replace(p_input_6,' '),' '),'-'),'/'),8,'0');

            r_input_7  := rpad(substr(nvl(upper(r_input_7),' '),1,57),57,' ');  --ER Name

	    /* ER Address */
	    r_input_8  := rpad(substr(nvl(r_input_8,' '),1,22),22,' ');
            r_input_9  := rpad(substr(nvl(r_input_9, ' '),1,22),22,' ');
            r_input_10 := rpad(substr(nvl(r_input_10,' '),1,2),2,' ');
            r_input_11 := rpad(substr(nvl(r_input_11,' '),1,5),5,' ');
            r_input_12 := rpad(substr(nvl(r_input_12,' '),1,4),4,' ');

            r_input_13 := lpad(nvl(r_input_13,'0'),6,'0');   -- Number of RS Records

            r_input_14 := lpad(nvl(r_input_14,'0'),12,'0');
            r_input_15 := lpad(nvl(r_input_15,'0'),12,'0');
            r_input_16 := lpad(nvl(r_input_16,'0'),12,'0');
            r_input_17 := lpad(nvl(r_input_17,'0'),12,'0');
            r_input_18 := lpad(nvl(r_input_18,'0'),12,'0');
            r_input_19 := lpad(nvl(r_input_19,'0'),12,'0');
            r_input_20 := lpad(nvl(r_input_20,'0'),12,'0');
            r_input_21 := lpad(nvl(r_input_21,'0'),12,'0');
            r_input_22 := lpad(nvl(r_input_22,'0'),12,'0');
            r_input_23 := lpad(nvl(r_input_23,'0'),12,'0');

            r_input_24 := rpad(substr(nvl(upper(r_input_24),' '),1,28),28,' '); --Contact
            r_input_25 := rpad(nvl(r_input_25,' '),15,' ');	-- Title

	    /* Date in YYYYMMDD format */
	    r_input_26 := substr(nvl(r_input_26,' '),5,4)||substr(nvl(r_input_26,' '),1,2)||substr(nvl(r_input_26,' '),3,2);
            r_input_26 := rpad(nvl(r_input_26,' '),8,' ');            -- Date

            r_input_27 := rpad(nvl(r_input_27,' '),10,' ');  -- Phone
END IF ;

IF p_report_qualifier = 'NE' or p_report_qualifier = 'IL'  THEN /* 6651399 */
/* 7569151 */
	return_value :='RV'
		     ||r_input_2
		     ||r_input_3
		     ||r_input_4
		     ||lpad(' ',473);

END IF;

IF p_report_qualifier = 'IN' THEN /* 7569563 */

	return_value :='RV'
		     ||r_input_2
		     ||r_input_3
		     ||r_input_4
		     ||r_input_5
		     ||r_input_6
		     ||lpad(' ', 456);

END IF;

IF p_report_qualifier = 'OR' THEN /* 9065357  */

	return_value :='RV'
		     ||lpad(nvl(r_input_2,'0'),7,'0')
  	     ||lpad(nvl(r_input_3,'0'),15,'0')
		     ||lpad(nvl(r_input_4,'0'),15,'0')
		     ||lpad(' ', 473);

END IF;

IF p_report_qualifier = 'PR' THEN

	return_value :='RV'
		     ||r_input_2
		     ||r_input_3
		     ||r_input_4
		     ||r_input_5
		     ||r_input_6
		     ||r_input_7
		     ||r_input_8
		     ||r_input_9
		     ||lpad(' ',405);

END IF;

IF p_report_qualifier = 'ID' Then /* 7565870 */
    return_value :='RV'
		     ||r_input_2
		     ||r_input_3
		     ||r_input_4
		     ||r_input_5
		     ||r_input_6
		     ||r_input_7
		     ||r_input_8
		     ||r_input_9
		     ||r_input_10
		     ||r_input_11
		     ||r_input_12
		     ||r_input_13
		     ||r_input_14
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
		     ||lpad(' ',335);
END IF;


IF p_report_qualifier = 'MD' THEN

	return_value :='RV'
		     ||r_input_2
		     ||r_input_3
		     ||r_input_4
		     ||r_input_5
		     ||r_input_6
		     ||r_input_7
		     ||r_input_8
		     ||r_input_9
		     ||r_input_10
		     ||r_input_11
		     ||r_input_12
		     ||r_input_13
		     ||r_input_14
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
		     ||r_input_25
		     ||r_input_26
		     ||r_input_27
		     ||r_input_28
		     ||lpad(' ',166) /* 7572352 */
             || to_char(sysdate,'YYYYMMDD')
                          ||to_char(systimestamp,'HH24MISSFF2');

END IF;

         IF p_exclude_from_output = 'Y' THEN
            l_exclude_from_output_chk := TRUE;
         END IF;

p_error := l_exclude_from_output_chk;
ret_str_len:=length(return_value);
return return_value;
END format_W2_RV_record;
-- vmkulkar
-- End of Function Formatting RV record


--
-- Formatting RE Record for W2 reporting
--
FUNCTION format_W2_RE_record(
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
      Alabama Withholding Tax Acct Number (Only for AL) --> p_input_23
      Tax Withholding Acct No. (MD)  --> p_input_24
      Total No. of RS Record for this Employer / GRE (MD) --> p_input_25
      Total Withheld Tax Reported for MD --> p_input_26
      Total Withheld Tax Shown on W2 (MD) --> p_input_27
      MW508 ER Credits (MD)             --> p_input_28
      MW508 Amt Tax Due (MD)            --> p_input_29
      MW508 Amt Balance Due (MD)        --> p_input_30
      MW508 ER Amt OverPayment (MD)     --> p_input_31
      MW508 ER Amt Credit (MD)          --> p_input_32
      MW508 ER Amt Refunded (MD)        --> p_input_33
      Total Gross MD Payroll for Year   --> p_input_34
      Total State Pickup Amt (MD)       --> p_input_35
      ER Reporting Name (MD)            --> p_input_36
      ER Reporting Date (MD)            --> p_input_37
      ER Reporting Phone Number (MD)    --> p_input_38
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
/* Bug 3936924 */
l_al_wh_tax_acct_no        varchar2(300);

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

       /* 7572620 */

    /*   IF p_report_qualifier = 'WV' THEN
         l_term_indicator  := lpad(' ',1);
      END IF; */

      IF ((p_report_qualifier = 'AL') OR      --AL ,CT,NC,PA and OH RITA
          (p_report_qualifier = 'PA') OR
          (p_report_qualifier = 'NC') OR
          (p_report_qualifier = 'CT') OR
          (p_report_qualifier = 'LA') OR      -- Bug # 3130999
          (p_report_qualifier = 'MO') OR      -- Added to fix bug # 2149507
	  (p_report_qualifier = 'MO_KNSAS') OR  -- Fix for Bug # 3067494
          (p_report_qualifier = 'OH_RTCCA') OR
          (p_report_qualifier = 'OH_CCAAA') OR
      --    (p_report_qualifier = 'PA_PHILA') OR /* 7579598 */
          (p_report_qualifier = 'MO_STLOU')) THEN
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

      /* OH RITA Other EIN. */
      If ((p_report_qualifier = 'OH_RTCCA') OR
          (p_report_qualifier = 'OH_CCAAA')) THEN
--{
         r_input_8 := p_input_8;
--}
      END IF;
      /* Bug 5640748 */
      IF (p_report_qualifier = 'MD') THEN
         l_term_indicator := '0' ;
         r_input_8 := lpad(' ',9,' ') ;
      END IF ;

--    Validation for RE Record starts
--    These validation are used only for mf file only.
--    not for any of the audit report
--
      IF p_input_40 = 'FLAT' THEN
--{
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
            l_agent_ein :=  pay_us_reporting_utils_pkg.data_validation(p_effective_date,
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
            l_other_ein:= pay_us_reporting_utils_pkg.data_validation(p_effective_date,
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
                                                     sp_out_2);
            hr_utility.trace('after data_validation of l_other_ein');
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
         /* Pos:27 - 30 Establishment number is blank for MA */

         IF p_report_qualifier = 'MA' THEN
            r_input_7 := lpad(' ',4);
         END IF;

         /* Pos:119-140 Delivery address blank for NC.Bug:2124630 */
         /* Pos:119-140 Delivery Address shoul not be blanked out for NC.
                         This is to revert back the chenges made to fix
                         the bug 2124630. Delivery address should be
                         reported for NC in the Pos 119-140 Code written
                         to fix bug 2124630 will be commented to fix bug
                         # 2198547
         */
         /*
         IF p_report_qualifier = 'NC' THEN
            r_input_10 := r_input_11;  -- Bug:2124630
            r_input_11 := lpad(' ',22);
         END IF;
         */
         /* Employer Address is blank out for the Saint Louis Local of MO state */
         IF (p_report_qualifier = 'MO_STLOU')THEN
             r_input_10 := lpad(' ',22);
             r_input_12 := lpad(' ',22);
             r_input_13 := lpad(' ',2);
             r_input_14 := lpad(' ',5);
             r_input_15 := lpad(' ',4);
         END IF;

         /* Delivery Address is blank out for MO and Saint Louis local  */
         -- Bug 4739790
         -- Removed the MO_KNSAS condition as we require Delivery address for that
         IF ((p_report_qualifier = 'MO') OR
             (p_report_qualifier = 'MO_STLOU')) THEN
              r_input_11 := lpad(' ',22);
         END IF;

         IF p_report_qualifier = 'AL' THEN
            r_input_10 := lpad(' ',22);
         /* Bug 3936924
	    Zip Code Extn reqd for AL now
	    401-410 - Alabama withholding tax acct number*/
            l_al_wh_tax_acct_no := lpad(replace(replace(nvl(replace(r_input_23,' '),' ')
                                ,'-'),'/'),10,'0');
            r_input_23 := ' ';
         ELSE
	    l_al_wh_tax_acct_no := lpad(' ',10,' ');
         END IF; --AL zip ext blank

         /* AL,PA,MA,NC and OH RITA/CCA foreign adrs,emp_code,
            third_party,tax_jurisdiction testing.
            Saint Louis, Missouri, Philadelphia added for local mag*/
         IF ((p_report_qualifier = 'AL') OR
             (p_report_qualifier = 'PA') OR
             (p_report_qualifier = 'LA') OR  -- Bug # 3130999
             (p_report_qualifier = 'NC') OR
             (p_report_qualifier = 'MO') OR  -- Added for fixing bug # 2149507
             (p_report_qualifier = 'MO_KNSAS') OR  -- Fix for Bug # 3067494
             (p_report_qualifier = 'OH_RTCCA') OR
             (p_report_qualifier = 'OH_CCAAA') OR
             (p_report_qualifier = 'MO_STLOU') OR
          --   (p_report_qualifier = 'PA_PHILA') OR /*7579598*/
             (p_report_qualifier = 'MA') ) THEN -- OR
	        --   (p_report_qualifier = 'WV') OR -- Bug # 3186636 bug # 7572620
        --     (p_report_qualifier = 'MD'))  -- Bug# 5640748
--{
             r_input_16 := lpad(' ',23);
             r_input_17 := lpad(' ',15);
             r_input_18 := lpad(' ',2);
             r_input_20 := lpad(' ',1);
             r_input_21 := lpad(' ',1);

             IF ((p_report_qualifier = 'PA') OR   -- AL,PA,NC emp_code blank
                 (p_report_qualifier = 'NC') OR
              --   (p_report_qualifier = 'LA') OR  -- Bug # 3130999 ,Bug 7045241 commenting foramtting of posotion 219 as it is required
                 (p_report_qualifier = 'OH_RTCCA') OR
                 (p_report_qualifier = 'OH_CCAAA') OR
                 (p_report_qualifier = 'MO_STLOU') OR
               --  (p_report_qualifier = 'PA_PHILA') OR /*7579598*/
                 (p_report_qualifier = 'MO_KNSAS') OR  -- Fix for Bug # 3067494
                 (p_report_qualifier = 'AL') OR
                 (p_report_qualifier = 'MO')   -- OR -- Added for fixing bug # 2149507
		        --   (p_report_qualifier = 'WV') OR -- Bug # 3186636 bug # 7572620
             --    (p_report_qualifier = 'MD') -- Bug# 5640748
                 ) THEN
                r_input_19 := lpad(' ',1);
             END IF;-- AL,PA emp_code blank
--}
         END IF; --AL,PA,MA checking

            if p_report_qualifier = 'MD' then /* 7572352 */
          r_input_16 := lpad(' ',23);
             r_input_17 := lpad(' ',15);
             r_input_18 := lpad(' ',2);
             r_input_20 := lpad(' ',1);
              r_input_19 := lpad(' ',1);
         end if ;

         /* Pos:219 - 221 blank for CT */
         IF (p_report_qualifier = 'CT') THEN
--{
             r_input_19 := lpad(' ',1);
             r_input_20 := lpad(' ',1);
             r_input_21 := lpad(' ',1);
--}
         END IF;

         /* Bug:2116807 Pos:221 blank for IN */
        /*  7569563 */
    /*     IF p_report_qualifier = 'IN' THEN
            r_input_21 := lpad(' ',1);
	    r_input_19 := lpad(' ',1);
         END IF; */
         /* 7572352 */
     /*    IF p_report_qualifier = 'MD' THEN
            r_input_21 := lpad('0',1,'0') ;
         END IF ; */

         IF p_report_qualifier = 'PA' THEN   /* Bug:2159881 */
            -- Formatting for 8 digit PA account
            r_input_30 := rpad(replace(replace(nvl
                              (replace(r_input_22,' '),' '),'/'),'-'),8);
         ELSE
            r_input_30 := lpad(' ',8);
         END IF;

         IF p_report_qualifier = 'PA_PHILA' THEN
--{
             hr_utility.trace('CHK before Formating Locality Comapny ID ');
      /*      l_bus_tax_acct_number := rpad(replace(replace(nvl
                                   (replace(p_input_17,' '),' '),'/'),'-'),7);
            hr_utility.trace('CHK Formatted Locality Comapny ID '
                                  ||l_bus_tax_acct_number); */
      --      r_input_22 := substr(l_bus_tax_acct_number,1,2);
       --     r_input_23 := rpad(substr(l_bus_tax_acct_number,3,7),6);
            r_input_22 := lpad(' ',2);
            r_input_23 := lpad(' ',6);
            r_input_24 := lpad(' ',2);
            r_input_25 := lpad(' ',12);
            r_input_26 := lpad(' ',1);
            r_input_27 := lpad(' ',1);
            r_input_28 := lpad(' ',1);
            r_input_29 := lpad(' ',1);
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

         END IF;

         -- Bug # 3299126
         IF p_report_qualifier = 'LA' THEN --LA Delivery address should be blank
            r_input_10 := lpad(' ',22);
         END IF;

         -- Bug# 5640748
         IF p_report_qualifier = 'MD' THEN
            r_input_22 := rpad(substr(nvl(r_input_2,' '),1,4),4) ;
            r_input_23 := l_emp_ein ;
            r_input_24 := lpad(replace(replace(nvl(replace(p_input_24,' '),' ')
                          ,'-'),'/'),8,'0');
            r_input_24 := r_input_24 || rpad(substr(nvl(upper(r_input_9), ' '), 1, 30), 30, ' ') ;
            r_input_24 := r_input_24 || rpad(substr(nvl(r_input_11, ' '),1, 22), 22, ' ') ; /* Bug# 5759976 Changed r_input_10 to r_input_11 */
            r_input_24 := r_input_24 || rpad(substr(nvl(r_input_12, ' '),1, 20), 20, ' ') ;
            r_input_24 := r_input_24 || rpad(substr(nvl(r_input_13, ' '),1, 2), 2, ' ') ;
            r_input_24 := r_input_24 || rpad(substr(nvl(r_input_14, ' '), 1, 5), 5, ' ') ;
            r_input_24 := r_input_24 || rpad(substr(nvl(r_input_15, ' '),1, 4), 4 , ' ') ;

            r_input_25 := lpad(p_input_25, 5 , '0') ;

            r_input_26 := lpad(nvl(p_input_26, '0'), 12, '0') ;
            r_input_27 := lpad(nvl(p_input_27, '0'), 12, '0') ;
            r_input_28 := lpad(nvl(p_input_28, '0'), 12, '0') ;
            r_input_29 := lpad(nvl(p_input_29, '0'), 12, '0') ;
            r_input_30 := lpad(nvl(p_input_30, '0'), 12, '0') ;
            r_input_31 := lpad(nvl(p_input_31, '0'), 12, '0') ;
            r_input_32 := lpad(nvl(p_input_32, '0'), 12, '0') ;
            r_input_33 := lpad(nvl(p_input_33, '0'), 12, '0') ;
            r_input_34 := lpad(nvl(p_input_34, '0'), 12, '0') ;
            r_input_35 := lpad(nvl(p_input_35, '0'), 12, '0') ;

            r_input_36 := rpad(nvl(p_input_36, ' '), 43, ' ') ;
            r_input_37 := rpad(p_input_37, 8, ' ') ;
            r_input_38 := rpad(nvl(p_input_38,' '), 10, ' ') ;
         END IF ;
--{
         IF p_report_qualifier = 'MD' THEN /* 6648007 */
             r_input_22 := lpad(replace(replace(nvl(replace(p_input_24,' '),' ')
                          ,'-'),'/'),8,'0'); --Central Registration Number

         END IF ;

         IF p_report_qualifier = 'MD' THEN
             return_value :=  'RE'
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
                       /*   ||r_input_23
                          ||r_input_24
                          ||r_input_25
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
                          ||r_input_36
                          ||r_input_37
                          ||r_input_38
                          ||'Y' */
			                    || LPAD(' ',267)
                          ||to_char(sysdate,'YYYYMMDD') /* 7572352 */
                          ||to_char(systimestamp,'HH24MISSFF2')
			  /* 6648007 - Moved to RV record */
                          ||l_end_of_rec ;
        ELSE
         return_value :=  'RE'
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
                          ||rpad(r_input_29,148)
                          ||rpad(l_al_wh_tax_acct_no,104,' ') -- Positions 401-410 for AL state
                          ||r_input_30
                          ||l_end_of_rec;
--}
         END IF ;
         ret_str_len:=length(return_value);
--}
      ELSIF p_input_40 = 'CSV' THEN
--{
        IF p_report_qualifier = 'MD' THEN
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
                           ||','||r_input_22
                           ||','||r_input_23
                           ||','||r_input_24
                           ||','||r_input_9
                           ||','||r_input_10
                           ||','||r_input_12
                           ||','||r_input_13
                           ||','||r_input_14
                           ||','||r_input_15
                           ||','||p_input_25
                           ||','||p_input_26
                           ||','||p_input_27
                           ||','||p_input_28
                           ||','||p_input_29
                           ||','||p_input_30
                           ||','||p_input_31
                           ||','||p_input_32
                           ||','||p_input_33
                           ||','||p_input_34
                           ||','||p_input_35
                           ||','||p_input_36
                           ||','||p_input_37
                           ||','||p_input_38
                           ||','||'Y' ;
         ELSE
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

        END IF ; -- p_report_qulaifier
--}
      END IF; -- p_input_40
END IF;
p_error := l_exclude_from_output_chk;
ret_str_len:=length(return_value);
return return_value;
END format_W2_RE_record; -- End of Function Formatting RE record
--
--

-- Formatting RW record for W2 reporting
-- Parameter description

/*Record Identifier,                                            --> p_input_1
  Social Security Number,                                       --> p_input_2
  Employee First Name,                                          --> p_input_3
  Employee Middle Name or Initial,                              --> p_input_4
  Employee Last Name,                                           --> p_input_5
  Suffix,                                                       --> p_input_6
  Location Address,                                             --> p_input_7
  Delivery Address,                                             --> p_input_8
  City,                                                         --> p_input_9
  State Abbreviation,                                           --> p_input_10
  Zip Code,                                                     --> p_input_11
  Zip Code Extension,                                           --> p_input_12
  Blank,
  Foreign State / Province,                                     --> p_input_13
  Foreign Postal Code,                                          --> p_input_14
  Country Code,                                                 --> p_input_15
  Wages, Tips And Other Compensation,                           --> p_input_16
  Federal Income Tax Withheld,                                  --> p_input_17
  Social Security Wages,                                        --> p_input_18
  Social Security Tax Withheld,                                 --> p_input_19
  Medicare Wages And Tips,                                      --> p_input_20
  Medicare Tax Withheld,                                        --> p_input_21
  Social Security Tips,                                         --> p_input_22
  Advance Earned Income Credit,                                 --> p_input_23
  Dependent Care Benefits,                                      --> p_input_24
  Deferred Compensation Contributions to Section 401(k),        --> p_input_25
  Deferred Compensation Contributions to Section 403(b),        --> p_input_26
  Deferred Compensation Contributions to Section 408(k)(6),     --> p_input_27
  Deferred Compensation Contributions to Section 457(b),        --> p_input_28
  Deferred Compensation Contributions to Section 501(c)(18)(D), --> p_input_29
  Military EE''s Basic Quarters, Subsistence and Combat Pay,    --> p_input_30
  Non-Qual. plan Sec.457 Distributions or Contributions,        --> p_input_31
  Non-Qual. plan NOT Section 457 Distributions or Contributions,--> p_input_32
  Blank,
  Employer Cost of Premiums for GTL> $50k,                      --> p_input_33
  Income From Exercise of Nonqualified Stock Options,,          --> p_input_34
  Blank,,                                                       --> p_input_31
  Statutory Employee Indicator,,                                --> p_input_35
  Blank,
  Retirement Plan Indicator,,                                   --> p_input_36
  Third-Party Sick Pay Indicator,                               --> p_input_37
  Employer Contributions to a Health Savings Account            --> p_input_38
  Non Taxable Combat Pay                                        --> p_input_41
  Deferrals Und a Sec 409A Non-Qualified Deferred Comp Plan     --> p_input_42
  Designated Roth Contributions to a section 401(k) Plan        --> p_input_43
  Designated Roth Contributions Under a section 403(b) Salaray  --> p_input_44
*/

FUNCTION format_W2_RW_record(
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
                   p_error                OUT nocopy boolean,
                   p_input_41             IN  varchar2 default null,
                   p_input_42             IN  varchar2 default null,
                   p_input_43             IN  varchar2 default null,
                   p_input_44             IN  varchar2 default null

                 ) RETURN VARCHAR2
IS

l_full_name                varchar2(100);
l_emp_name_or_number       varchar2(50);
l_emp_number               varchar2(50);
l_first_name               varchar2(150);
l_middle_name              varchar2(100);
l_last_name                varchar2(150);
l_suffix                   varchar2(100);
l_ssn                      varchar2(100);
l_message                  varchar2(2000);
l_description              varchar2(50);
l_field_description        varchar2(50);
l_ss_count                 number(10);
l_amount                   number(10);
return_value               varchar2(32767);
l_err                      boolean;
l_exclude_from_output_chk  boolean;
l_ss_tax_limit  pay_us_federal_tax_info_f.ss_ee_wage_limit%TYPE;
l_ss_wage_limit  pay_us_federal_tax_info_f.ss_ee_wage_limit%TYPE;

TYPE function_columns IS RECORD(
                                p_parameter_name  varchar2(100),
                                p_parameter_value varchar2(100),
                                p_output_value varchar2(100)
                               );
function_parameter_rec  function_columns;
TYPE input_parameter_record IS TABLE OF function_parameter_rec%TYPE
                               INDEX BY BINARY_INTEGER;
parameter_record input_parameter_record;

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
/* Bug # 4391218 */
r_input_40                 varchar2(300) ;
r_input_41                 varchar2(300) ;
/* Bug # 5256745 */
r_input_42                 varchar2(300) ;
r_input_43                 varchar2(300) ;

CURSOR GET_SS_LIMIT(c_date varchar2)
IS
SELECT SS_EE_WAGE_LIMIT*100,
       (SS_EE_WAGE_LIMIT*SS_EE_RATE)*100 tax
FROM   PAY_US_FEDERAL_TAX_INFO_F
WHERE  TO_DATE(C_DATE,'DD-MM-YYYY') BETWEEN EFFECTIVE_START_DATE
                                        AND EFFECTIVE_END_DATE
AND    FED_INFORMATION_CATEGORY = '401K LIMITS';

BEGIN
   hr_utility.trace('Formatting RW record');
   hr_utility.trace('Formatting Mode = '||p_input_40);
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
   r_input_40 := p_input_41 ;
   r_input_41 := p_input_42 ; -- Bug # 4391218
   r_input_42 := p_input_43 ;
   r_input_43 := p_input_44 ; -- Bug # 5256745
--}

--
   IF p_input_40 = 'FLAT' THEN

-- Following Formattings are required for data validation
--
--{

	/*5155648*/
	/* commented for bug 7109106 */
/*	IF (p_report_qualifier = 'FED' and
             r_input_10 = 'PR') THEN
             r_input_33 := '0';

        END IF;  */


         /* For fixing bug # 2645739 instead of input parameters, local variables were formatted
            and used for Flat reocrd */
         IF ((p_report_qualifier = 'NC') OR
             (p_report_qualifier = 'MO_STLOU')) THEN
--{
             r_input_18 := '0';
             r_input_19 := '0';
             r_input_20 := '0';
             r_input_21 := '0';
             r_input_22 := '0';
             r_input_23 := '0';
             r_input_24 := '0';
             r_input_25 := '0';
             r_input_26 := '0';
             r_input_27 := '0';
             r_input_28 := '0';
             r_input_29 := '0';
             r_input_30 := '0';
             r_input_31 := '0';
             r_input_32 := '0';
             r_input_33 := '0';
             r_input_34 := '0';
--}
         END IF;

         IF p_report_qualifier = 'MO_STLOU' THEN
--{
            r_input_17 := '0';
            r_input_25 := p_input_25;
            r_input_26 := p_input_26;
            r_input_27 := p_input_27;
            r_input_28 := p_input_28;
            r_input_29 := p_input_29;
--}
         END IF;

         IF  p_report_qualifier = 'PR' THEN
--{
             r_input_16 := '0';
             r_input_17 := '0';
             r_input_23 := '0';
             r_input_24 := '0';
             r_input_25 := '0';
             r_input_26 := '0';
             r_input_27 := '0';
             r_input_28 := '0';
             r_input_29 := '0';
             r_input_30 := '0';
             r_input_31 := '0';
             r_input_32 := '0';
             r_input_33 := '0';
	     r_input_38 := '0';   /* Bug 3680056 NR-Zero fill for PR */
--}
         END IF;

--       Fix for Bug# 4502738
         IF  p_report_qualifier = 'MO_KNSAS' THEN
--{
             r_input_17 := '0';  -- Federal Income Tax Withheld
             r_input_18 := '0';  -- Social Security Wages
             r_input_19 := '0';  -- Social Security Tax Withheld
             r_input_22 := '0';  -- Social Security Tips
             r_input_23 := '0';  -- Advance Earned Income Credit
             r_input_24 := '0';  -- Dependent Care Benefits
             r_input_25 := '0';  -- Deferred Compensation Contributions to Section 401(k)
             r_input_26 := '0';  -- Deferred Compensation Contributions to Section 403(b)
             r_input_27 := '0';  -- Deferred Compensation Contributions to Section 408(k)(6)
             r_input_28 := '0';  -- Deferred Compensation Contributions to Section 457(b)
             r_input_29 := '0';  -- Deferred Compensation Contributions to Section 501(c)(18)(D)
             r_input_30 := lpad(' ',11); -- Blank
             r_input_31 := '0';  -- Non-Qual. plan Sec.457 Distributions or Contributions
             r_input_32 := '0';  -- Non-Qual. plan NOT Section 457 Distributions or Contributions
             r_input_33 := '0';  -- Employer Cost of Premiums for GTL> $50k
             r_input_34 := '0';  -- Income from nonqualified stock option
             r_input_38 := '0';  -- Employer Contributions to Health Savings Account
             r_input_41 := '0';  -- Deferrals Under Sec 409A Non-Qual Def Comp Plan
--}
         END IF;


/* Bug # 3186636 */
--{
/* 7572620 */
         IF p_report_qualifier = 'WV' THEN

            /*       r_input_7 := ' ';
             r_input_13 := ' ';
             r_input_14 := ' ';
             r_input_15 := ' ';
             r_input_18 := '0';
             r_input_19 := '0';
             r_input_20 := '0';
             r_input_21 := '0';
             r_input_22 := '0';
             r_input_23 := '0';
             r_input_24 := '0';
             r_input_25 := '0';
             r_input_26 := '0';
             r_input_27 := '0';
             r_input_28 := '0';
             r_input_29 := '0'; */
             r_input_30 := '0';
          /*   r_input_31 := '0';
             r_input_32 := '0';
             r_input_33 := '0';
             r_input_34 := '0';
             r_input_35 := ' ';
             r_input_36 := ' ';
             r_input_37 := ' '; */

         END IF;
--}
--
-- Formatting completes before data validation
--
         parameter_record(1).p_parameter_name:= ' Wages,Tips And Other Compensation';
         parameter_record(1).p_parameter_value:=r_input_16;

         parameter_record(2).p_parameter_name:= ' Federal Income Tax Withheld';
         parameter_record(2).p_parameter_value:=r_input_17;

         parameter_record(3).p_parameter_name:= 'SS Wages';
         parameter_record(3).p_parameter_value:=r_input_18;

         parameter_record(4).p_parameter_name:= ' Social Security Tax Withheld';
         parameter_record(4).p_parameter_value:=r_input_19;

         parameter_record(5).p_parameter_name:= 'Medicare Wages And Tips';
         parameter_record(5).p_parameter_value:=r_input_20;

         parameter_record(6).p_parameter_name:= 'Medicare Tax Withheld';
         parameter_record(6).p_parameter_value:=r_input_21;

         parameter_record(7).p_parameter_name:= 'SS Tips';
         parameter_record(7).p_parameter_value:=r_input_22;

         parameter_record(8).p_parameter_name:= 'Advance Earned Income Credit';
         parameter_record(8).p_parameter_value:=r_input_23;

         parameter_record(9).p_parameter_name:= 'Dependent Care Benefits';
         parameter_record(9).p_parameter_value:=r_input_24;

         parameter_record(10).p_parameter_name:= 'Deferred Comp Contr. to Sec 401(k)';
         parameter_record(10).p_parameter_value:=r_input_25;

         parameter_record(11).p_parameter_name:= 'Deferred Comp Contr. to Sec 403(b)';
         parameter_record(11).p_parameter_value:=r_input_26;

         parameter_record(12).p_parameter_name:= 'Deferred Comp Contr. to Sec 408(k)(6)';
         parameter_record(12).p_parameter_value:=r_input_27;

         parameter_record(13).p_parameter_name:= 'Deferred Comp Contr. to Sec 457(b)';
         parameter_record(13).p_parameter_value:=r_input_28;

         parameter_record(14).p_parameter_name:= 'Deferred Comp Contr. to Sec 501(c)';
         parameter_record(14).p_parameter_value:=r_input_29;
         /* As A_W2_MILITARY_HOUSING_Q is disabled this field will be blank filled
           no standard numeric validation would be performed
           parameter_record(15).p_parameter_name:= 'Military Combat Pay';
           parameter_record(15).p_parameter_value:=p_input_30;
         */
         parameter_record(15).p_parameter_name:= 'Non-Qual. plan Sec 457';
         parameter_record(15).p_parameter_value:=r_input_31;

         parameter_record(16).p_parameter_name:= 'Non-Qual. plan NOT Sec 457';
         parameter_record(16).p_parameter_value:=r_input_32;

         parameter_record(17).p_parameter_name:= 'Employer cost of premiun';
         parameter_record(17).p_parameter_value:=r_input_33;

         parameter_record(18).p_parameter_name:= 'Income from nonqualified stock option';
         parameter_record(18).p_parameter_value:=r_input_34;

         /* Bug 3680056 New field */
	 parameter_record(19).p_parameter_name:= 'Employer Contributions to Health Savings Account';
         parameter_record(19).p_parameter_value:=r_input_38;

         parameter_record(20).p_parameter_name:= 'Non-Taxable Combat Pay';
         parameter_record(20).p_parameter_value:=r_input_40 ; -- Bug # 4391218

         parameter_record(21).p_parameter_name:= 'Deferrals Under Sec 409A Non-Qual Def Comp Plan';
         parameter_record(21).p_parameter_value:=r_input_41 ; -- Bug # 4391218
         /* Bug 5256745 */
         parameter_record(22).p_parameter_name:= 'Roth Contributions Und Sec 401(k) Plan';
         parameter_record(22).p_parameter_value:=r_input_42 ; -- Bug # 5256745

         parameter_record(23).p_parameter_name:= 'Roth Contributions Und Sec 403(b) Plan';
         parameter_record(23).p_parameter_value:=r_input_43 ; -- Bug # 5256745

         l_first_name := pay_us_reporting_utils_pkg.Character_check(rpad(nvl(
                                        substr(p_input_3,1,15),' '),15));
         l_middle_name := pay_us_reporting_utils_pkg.Character_check(rpad(nvl(
                                        substr(p_input_4,1,15),' '),15));
         l_last_name :=  pay_us_reporting_utils_pkg.Character_check(rpad(nvl(
                                        substr(p_input_5,1,20),' '),20));
         l_suffix := pay_us_reporting_utils_pkg.Character_check(rpad(nvl(
                                        substr(p_input_6,1,4),' '),4));
         l_full_name := substr(ltrim(rtrim(p_input_3)||' '||
                                     rtrim(p_input_5)),1,50);

         l_emp_number := replace(p_input_39,' ');

         IF l_emp_number IS NULL THEN
            l_emp_name_or_number := l_full_name;
            hr_utility.trace('l_emp_name_or_number = '||l_emp_name_or_number);
         ELSE
            l_emp_name_or_number:= l_emp_number;
            hr_utility.trace('l_emp_name_or_number = '||l_emp_name_or_number);
         END IF;
--
--   Validation for RW Record  Start
--
--   SSN Validation
         l_ssn :=
           pay_us_reporting_utils_pkg.data_validation( p_effective_date,
                                                      p_report_type,
                                                      p_format,
                                                      p_report_qualifier,
                                                      p_record_name,
                                                      'SSN',
                                                      p_input_2,
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

--    Various Amount Validation for for Neg value. If value is found negative record
--            is marked for exclusion
         FOR i in 1..23
         LOOP
            parameter_record(i).p_output_value :=
                pay_us_reporting_utils_pkg.data_validation(
                                                p_effective_date,
                                                p_report_type,
                                                p_format,
                                                p_report_qualifier,
                                                p_record_name,
                                                'NEG_CHECK',
                                                parameter_record(i).p_parameter_value,
                                                parameter_record(i).p_parameter_name,
                                                l_emp_name_or_number, --EE number for mesg
                                                null,
                                                p_validate,
                                                p_exclude_from_output,
                                                sp_out_1,
                                                sp_out_2);

            IF p_exclude_from_output = 'Y' THEN
               l_exclude_from_output_chk := TRUE;
            END IF;
            hr_utility.trace(parameter_record(i).p_parameter_name||' = '||
                                       parameter_record(i).p_output_value);
            hr_utility.trace('p_exclude_from_output = '||p_exclude_from_output);

         END LOOP;

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
            IF (to_number(parameter_record(3).p_output_value) > 0 OR
                to_number(parameter_record(4).p_output_value) > 0 OR
                to_number(parameter_record(7).p_output_value) > 0 )
            THEN
--{
               hr_utility.trace('SS Tax w/h, SS Tips, SS Wages are >0 ');
               IF (to_number(parameter_record(3).p_output_value)+
                       to_number(parameter_record(7).p_output_value))
                       > l_ss_wage_limit
               THEN
                 hr_utility.trace('ss_tips+ss_wages is > '||
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

               IF to_number(parameter_record(4).p_output_value)>l_ss_tax_limit
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

            hr_utility.trace('After SS Wage/ Tax limit checking ');

            IF l_err THEN
               IF p_validate = 'Y' THEN
                  p_exclude_from_output := 'Y';
               END IF;
            END IF;

            IF p_exclude_from_output = 'Y' THEN
               l_exclude_from_output_chk := TRUE;
            END IF;
--
-- Validation for RW record Ends here
--

-- Formatting feields for Geo specific requirements
--


            /* Fix for Bug # 2767254 */
            IF  p_report_qualifier = 'PR' THEN
                r_input_30 := rpad('0',11,'0');
                r_input_31 := rpad('0',11,'0');
                r_input_32 := rpad('0',22,'0');
            ELSE
                r_input_30 := lpad('0',11,'0'); /* Bug 4859212 */
                r_input_31 := lpad(' ',11);
                r_input_32 := lpad(' ',22);
            END IF;

            IF (p_report_qualifier = 'MO_STLOU') THEN
               l_first_name   := lpad(' ',15);
               l_middle_name  := lpad(' ',15);
               l_last_name    := lpad(' ',20);
            END IF;

            /* For State of NC, suffix is blank filled Bug # 2645739 */
            IF(( p_report_qualifier = 'NC') OR
               (p_report_qualifier = 'MO_STLOU')) THEN
               l_suffix   := lpad(' ',4);
            END IF;

         IF ((p_report_qualifier = 'NC') OR
             (p_report_qualifier = 'MO_STLOU')) THEN
--{
             r_input_7  := ' ';
             r_input_8  := ' ';
             r_input_9  := ' ';
             r_input_10 := ' ';
             r_input_11 := ' ';
             r_input_12 := ' ';
             r_input_13 := ' ';
             r_input_14 := ' ';
             r_input_15 := ' ';
             r_input_35 := ' ';
             r_input_36 := ' ';
             r_input_37 := ' ';
         END IF;

--       Fix for Bug# 4502738
         -- Bug 4739790
         -- Removed the blanking of fields r_input_8 and r_input_9
         -- as they are required for MO_KNSAS
         IF (p_report_qualifier = 'MO_KNSAS') THEN
--{
             r_input_13 := ' ';
             r_input_14 := ' ';
             r_input_15 := ' ';
             r_input_35 := ' ';
             r_input_36 := ' ';
             r_input_37 := ' ';
         END IF;
--       Fix for Bug# 4391218

         r_input_40 := parameter_record(20).p_output_value ;

         IF ( p_report_qualifier = 'MO_KNSAS') THEN
             r_input_40 := lpad('0',22,'0') ;
	     r_input_30 := lpad(' ',11) ; -- Keep it as it is in spec not changed for #4859212
         END IF ;


--       End of Fix for Bug# 4391218

         hr_utility.trace('Before formatting and returning RW record for the flat file');

-- Formatting Wage Record for .mf reporting file
--
	IF p_report_qualifier = 'IN' THEN
	 return_value := 'RW'||l_ssn||l_first_name
                             ||l_middle_name
                             ||l_last_name||l_suffix
                             ||rpad(substr(nvl(r_input_7,' '),1,22),22)
                             ||rpad(substr(nvl(r_input_8,' '),1,22),22)
                             ||rpad(substr(nvl(r_input_9,' '),1,22),22)
                             ||rpad(substr(nvl(r_input_10,' '),1,2),2)
                             ||rpad(substr(nvl(r_input_11,' '),1,5),5)
                             ||rpad(substr(nvl(r_input_12,' '),1,4),9)
                             ||rpad(substr(nvl(r_input_13,' '),1,23),23)
                             ||rpad(substr(nvl(r_input_14,' '),1,15),15)
                             ||rpad(substr(nvl(r_input_15,' '),1,2),2)
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
                             -- ||parameter_record(15).p_output_value
                             --lpad(' ',11)
                             ||r_input_30
                             --||rpad(parameter_record(15).p_output_value,22)
                             ||parameter_record(15).p_output_value
			     -- Bug 3680056 New Field 364-374
                             ||parameter_record(19).p_output_value
                             --||rpad(parameter_record(16).p_output_value,33)
                             ||parameter_record(16).p_output_value
                             --||r_input_32
                             ||rpad(r_input_40,22,' ')
                             ||parameter_record(17).p_output_value
                             --||rpad(parameter_record(18).p_output_value,67)
                             ||parameter_record(18).p_output_value
                             --||rpad(parameter_record(21).p_output_value,56,' ')
                            /* Bug 7569563 */
                             ||parameter_record(21).p_output_value
                             ||parameter_record(22).p_output_value
                             ||rpad(parameter_record(23).p_output_value,34,' ')
                             ||rpad(substr(nvl(r_input_35,'0'),1,1),2)
                             ||rpad(substr(nvl(r_input_36,'0'),1,1),1)
                             ||rpad(substr(nvl(r_input_37,'0'),1,1),24);
			  --   || rpad(' ',83); /* 6648064 */
            ELSE
            return_value := 'RW'||l_ssn||l_first_name
                             ||l_middle_name
                             ||l_last_name||l_suffix
                             ||rpad(substr(nvl(r_input_7,' '),1,22),22)
                             ||rpad(substr(nvl(r_input_8,' '),1,22),22)
                             ||rpad(substr(nvl(r_input_9,' '),1,22),22)
                             ||rpad(substr(nvl(r_input_10,' '),1,2),2)
                             ||rpad(substr(nvl(r_input_11,' '),1,5),5)
                             ||rpad(substr(nvl(r_input_12,' '),1,4),9)
                             ||rpad(substr(nvl(r_input_13,' '),1,23),23)
                             ||rpad(substr(nvl(r_input_14,' '),1,15),15)
                             ||rpad(substr(nvl(r_input_15,' '),1,2),2)
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
                             -- ||parameter_record(15).p_output_value
                             --lpad(' ',11)
                             ||r_input_30
                             --||rpad(parameter_record(15).p_output_value,22)
                             ||parameter_record(15).p_output_value
			     -- Bug 3680056 New Field 364-374
                             ||parameter_record(19).p_output_value
                             --||rpad(parameter_record(16).p_output_value,33)
                             ||parameter_record(16).p_output_value
                             --||r_input_32
                             ||rpad(r_input_40,22,' ')
                             ||parameter_record(17).p_output_value
                             --||rpad(parameter_record(18).p_output_value,67)
                             ||parameter_record(18).p_output_value
                             --||rpad(parameter_record(21).p_output_value,56,' ')
                             /* Bug 5256745 */
                             ||parameter_record(21).p_output_value
                             ||parameter_record(22).p_output_value
                             ||rpad(parameter_record(23).p_output_value,34,' ')
                             ||rpad(substr(nvl(r_input_35,'0'),1,1),2)
                             ||rpad(substr(nvl(r_input_36,'0'),1,1),1)
                             ||rpad(substr(nvl(r_input_37,'0'),1,1),24);
         END IF ;
         ret_str_len:=length(return_value);
         hr_utility.trace('ret_str_len = '||to_char(ret_str_len));
--}
   ELSIF p_input_40 = 'CSV' THEN
--{
         hr_utility.trace('CSV');
         return_value :=
           'RW'||','||replace(p_input_2,',')
           ||','||replace(p_input_3,',',' ')||','||replace(p_input_4,',',' ')
           ||','||replace(p_input_5,',',' ')||','||replace(p_input_6,',',' ')
           ||','||rpad(substr(nvl(p_input_7,' '),1,22),22)
           ||','||rpad(substr(nvl(p_input_8,' '),1,22),22)
           ||','||rpad(substr(nvl(p_input_9,' '),1,22),22)
           ||','||rpad(substr(nvl(p_input_10,' '),1,2),2)
           ||','||rpad(substr(nvl(p_input_11,' '),1,5),5)
           ||','||rpad(substr(nvl(p_input_12,' '),1,4),4)
           ||','||lpad(' ',5)
           ||','||rpad(substr(nvl(p_input_13,' '),1,23),23)
           ||','||rpad(substr(nvl(p_input_14,' '),1,15),15)
           ||','||rpad(substr(nvl(p_input_15,' '),1,2),2)
           ||','||p_input_16
           ||','||p_input_17
           ||','||p_input_18
           ||','||p_input_19
           ||','||p_input_20
           ||','||p_input_21
           ||','||p_input_22
           ||','||p_input_23
           ||','||p_input_24
           ||','||p_input_25
           ||','||p_input_26
           ||','||p_input_27
           ||','||p_input_28
           ||','||p_input_29
           -- commented to fix bug # 2297587 ||','||p_input_30
           ||','||lpad('0',11,'0') /* Bug 4859212 */
           ||','||p_input_31
           ||','||p_input_38  -- Bug 3680056 ER Contrib to HSA
           ||','||p_input_32
           ||','||p_input_41  -- Bug # 4391218
           ||','||lpad(' ',11)
           ||','||p_input_33
           ||','||p_input_34
           ||','||p_input_42  -- Bug # 4391218
           /* Bug 5256745 */
           ||','||p_input_43
           ||','||p_input_44
           ||','||lpad(' ',23)
           ||','||rpad(nvl(p_input_35,'0'),1)
           ||','||lpad(' ',1)
           ||','||rpad(nvl(p_input_36,'0'),1)
           ||','||rpad(nvl(p_input_37,'0'),1)
           ||','||lpad(' ',23);
--}
   ELSIF p_input_40 = 'BLANK' THEN
--{
         hr_utility.trace('Formatting BLANK RW Record ');
         return_value :=
           ' '||','||' '
           ||','||' '||','||' '
           ||','||' '||','||' '
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
           ||','||' '
           ||','||' '
           ||','||' '
           ||','||' '
           ||','||' '
           ||','||' '
           ||','||' '
           ||','||' '
           ||','||' '
           ||','||' ' -- Bug 3680056 ER Contrib to HSA
           ||','||' '
           ||','||' ' -- Bug # 4391218
           ||','||lpad(' ',11)
           ||','||' '
           ||','||' '
           ||','||' '
           /* Bug 5256745 */
           ||','||' '
           ||','||' '
           ||','||lpad(' ',23)
           ||','||' '
           ||','||lpad(' ',1)
           ||','||' '
           ||','||' '
           ||','||' ';
         hr_utility.trace(return_value);
--}
   END IF;
   p_error := l_exclude_from_output_chk;
   ret_str_len:=length(return_value);
   return return_value;

END format_W2_RW_record;
-- End of Formatting RW Record for W2 reporting
--
-- Formatting RO record for W2 reporting
--
/*-------------------------- Parameter Description ------------------------
  Record Identifier,                                         --> p_input_1
  Allocated Tips,                                            --> p_input_2
  Uncollected Employee Tax on Tips,                          --> p_input_3
  Medical Savings Account,                                   --> p_input_4
  Simple Retirement Account,                                 --> p_input_5
  Qualified Adoption Expenses,                               --> p_input_6
  Uncollected Social Security or RRTA Tax on GTL,            --> p_input_7
  Uncollected Medicare Tax on GTL,                           --> p_input_8
  Civil Status,                                              --> p_input_9
  Spouse''s Social Security Number (SSN),                    --> p_input_10
  Wages Subject to Puerto Rico Tax,                          --> p_input_11
  Commissions Subject to Puerto Rico Tax,                    --> p_input_12
  Allowances Subject to Puerto Rico Tax,                     --> p_input_13
  Tips Subject to Puerto Rico Tax,                           --> p_input_14
  Total Wages, Commissions, Tips, and Allow Sub. to PRTax,   --> p_input_15
  Puerto Rico Tax Withheld,                                  --> p_input_16
  Retirement Fund Annual Contributions,                      --> p_input_17
  Total Wages, Tips and other Compensation Subject to
     Virgin Islands, or Guam, or American Samoa, or Northern
     Mariana Islands Income Tax,                             --> p_input_18
  Virgin Islands, or Guam, or AS, or MP Income Tax Withheld  --> p_input_19
  Marital Status   S Single  M Married  etc                  --> p_input_20
  Employee SSN for Philadelphia use only                     --> p_input_21
  Income Under Section 409A on a Non-Qual Deferred Comp Plan --> p_input_22
*/
FUNCTION format_W2_RO_record(
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
l_full_name                varchar2(100);
l_emp_name_or_number       varchar2(50);
l_emp_number               varchar2(50);
l_first_name               varchar2(150);
l_middle_name              varchar2(100);
l_last_name                varchar2(150);
l_suffix                   varchar2(100);
l_ssn                      varchar2(100);
l_emp_ssn                  varchar2(100);
l_message                  varchar2(2000);
l_description              varchar2(50);
l_field_description        varchar2(50);
l_ss_count                 number(10);
l_amount                   number(10);
return_value               varchar2(32767);
l_err                      boolean;
l_exclude_from_output_chk  boolean;
l_ss_tax_limit   pay_us_federal_tax_info_f.ss_ee_wage_limit%TYPE;
l_ss_wage_limit  pay_us_federal_tax_info_f.ss_ee_wage_limit%TYPE;

TYPE function_columns IS RECORD(
                                p_parameter_name  varchar2(100),
                                p_parameter_value varchar2(100),
                                p_output_value varchar2(100)
                               );
function_parameter_rec  function_columns;
TYPE input_parameter_record IS TABLE OF function_parameter_rec%TYPE
                               INDEX BY BINARY_INTEGER;
parameter_record input_parameter_record;

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
   hr_utility.trace('Formatting RO Record');
   hr_utility.trace('Format Mode  p_input_40 '||p_input_40);
-- Initializing local variables with parameter value
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

   IF p_input_40 = 'FLAT' THEN
-- Validation Starts
--{
      parameter_record(1).p_parameter_name:= ' Allocated Tips';
      parameter_record(1).p_parameter_value:=p_input_2;

      parameter_record(2).p_parameter_name:= 'Uncollected employee tax on tips';
      parameter_record(2).p_parameter_value:=p_input_3;

      parameter_record(3).p_parameter_name:= 'medical savings a/c';
      parameter_record(3).p_parameter_value:=p_input_4;

      parameter_record(4).p_parameter_name:= 'simple retirement a/c';
      parameter_record(4).p_parameter_value:=p_input_5;

      parameter_record(5).p_parameter_name:= 'qualified adopted expenses';
      parameter_record(5).p_parameter_value:=p_input_6;

      parameter_record(6).p_parameter_name:= 'Uncollected ss or RRTA tax';
      parameter_record(6).p_parameter_value:=p_input_7;

      parameter_record(7).p_parameter_name:= 'Uncollected medicare tax';
      parameter_record(7).p_parameter_value:=p_input_8;

      parameter_record(8).p_parameter_name:= 'wages sub. to PR tax';
      parameter_record(8).p_parameter_value:=p_input_11;

      parameter_record(9).p_parameter_name:= 'Commissions sub.to PR tax';
      parameter_record(9).p_parameter_value:=p_input_12;

      parameter_record(10).p_parameter_name:= 'Allowances sub. to PR tax';
      parameter_record(10).p_parameter_value:=p_input_13;

      parameter_record(11).p_parameter_name:= 'Tips sub to PR tax';
      parameter_record(11).p_parameter_value:=p_input_14;

      parameter_record(12).p_parameter_name:= 'Total wages sub to PR tax';
      parameter_record(12).p_parameter_value:=p_input_15;

      parameter_record(13).p_parameter_name:= 'PR tax withheld';
      parameter_record(13).p_parameter_value:=p_input_16;

      parameter_record(14).p_parameter_name:= 'Retirement fund ann. contributions';
      parameter_record(14).p_parameter_value:=p_input_17;

      parameter_record(15).p_parameter_name:= 'Total wages sub to VI,GU,AS and MP islands';
      parameter_record(15).p_parameter_value:=p_input_18;

      parameter_record(16).p_parameter_name:= 'VI,GU or MP Islands income tax wh';
      parameter_record(16).p_parameter_value:=p_input_19;

      parameter_record(17).p_parameter_name:= 'Income Under Sec 409A on a Non-Qual Def Comp Plan';
      parameter_record(17).p_parameter_value := p_input_22;

      hr_utility.trace('Before the data validation loop.');
--
-- This loop used to validation above 17 input values
--
      FOR i in 1..17
      LOOP
--{
        hr_utility.trace('Value of loop counter i is : ' || to_char(i));
        hr_utility.trace('Input '||parameter_record(i).p_parameter_name||' = '
                                 ||parameter_record(i).p_parameter_value);

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

        hr_utility.trace('Value of i is : ' || to_char(i));
        hr_utility.trace('Output ' || parameter_record(i).p_parameter_name||' = '
                                   ||parameter_record(i).p_output_value);
        hr_utility.trace('p_exclude_from_output = '||p_exclude_from_output);
--}
      END LOOP; -- End of various Amount validation loop
      hr_utility.trace('After Amount data validation ');
-- Spouse SSN validation
      IF p_input_20 = 'PR_M' THEN
         l_ssn:= replace(replace(p_input_10,' '),'I');
         IF l_ssn IS NULL THEN
            l_ssn:='000000000';
         ELSE
            l_ssn :=
             pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                        p_report_type,
                                                        p_format,
                                                        p_report_qualifier,
                                                        p_record_name,
                                                        'SSN',
                                                        p_input_10,
                                                        'Spouse Social Security',
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
         l_ssn:=lpad(' ',9);
      END IF;
      hr_utility.trace('After Spouse SSN validation. SSN = '||l_ssn);
      -- This is added for Philadelphia locality
      --
      IF (p_report_qualifier = 'PA_PHILA') THEN
         IF p_input_21 IS NULL THEN
            l_emp_ssn:=lpad(' ',9);
         ELSE
            l_emp_ssn :=
              pay_us_reporting_utils_pkg.data_validation(
                                           p_effective_date,
                                           p_report_type,
                                           p_format,
                                           p_report_qualifier,
                                           p_record_name,
                                           'SSN',
                                           p_input_21,
                                           'Employee Social Security',
                                           p_input_39,
                                           null,
                                           p_validate,
                                           p_exclude_from_output,
                                           sp_out_1,
                                           sp_out_2);
            hr_utility.trace('For Philadelphia  SSN after validation. = '||l_emp_ssn);
            IF p_exclude_from_output = 'Y' THEN
               l_exclude_from_output_chk := TRUE;
            END IF;
         END IF;
      END IF;

-- Validation Ends
--
-- Formatting Starts


      IF (p_report_qualifier = 'PA_PHILA') THEN
             r_input_9  := ' ';
             l_ssn      := lpad(' ',9);
             r_input_11 := lpad('0',11,'0');
             r_input_12 := lpad('0',11,'0');
             r_input_13 := lpad('0',11,'0');
             r_input_14 := lpad('0',11,'0');
             r_input_15 := lpad('0',11,'0');
             r_input_16 := lpad('0',11,'0');
             r_input_17 := lpad('0',11,'0');
             r_input_18 := lpad('0',11,'0');
             r_input_19 := lpad('0',11,'0');
      ELSIF (p_report_qualifier = 'PR') THEN
             l_ssn      := lpad(' ',9); /* Bug 4665713 */
             r_input_2  := lpad('0',11,'0');
             r_input_3 :=  parameter_record(2).p_output_value;
             r_input_4  := lpad('0',11,'0');
             r_input_5  := lpad('0',11,'0');
             r_input_6  := lpad('0',11,'0');
             r_input_7 :=  parameter_record(6).p_output_value;
             --r_input_8 :=  rpad(parameter_record(7).p_output_value,187);
             r_input_8 :=  parameter_record(7).p_output_value ;
	     r_input_9  := ' ';   -- Bug # 5668970
             r_input_22 := rpad(parameter_record(17).p_output_value,176) ;
             r_input_11 := parameter_record(8).p_output_value;
             r_input_12 := parameter_record(9).p_output_value;
             r_input_13 := parameter_record(10).p_output_value;
             r_input_14 := parameter_record(11).p_output_value;
             r_input_15 := parameter_record(12).p_output_value;
             r_input_16 := parameter_record(13).p_output_value;
             r_input_17 := parameter_record(14).p_output_value;
      ELSE
             l_emp_ssn  := lpad(' ',9);
             r_input_11 := parameter_record(8).p_output_value;
             r_input_12 := parameter_record(9).p_output_value;
             r_input_13 := parameter_record(10).p_output_value;
             r_input_14 := parameter_record(11).p_output_value;
             r_input_15 := parameter_record(12).p_output_value;
             r_input_16 := parameter_record(13).p_output_value;
             r_input_17 := parameter_record(14).p_output_value;
             r_input_18 := parameter_record(15).p_output_value;
             r_input_19 := parameter_record(16).p_output_value;
      END IF;
/* 6806139  */
/* 5155648 */
  /*    IF ( p_report_qualifier = 'FED' AND UPPER(p_input_23) = 'P') THEN
        r_input_11 := lpad('0',11,'0');
      END IF ; */


      /* This changes made for PR for fixing Bug # 2736928 */
      /* Bug # 3337295 fixed RO record fields for PR.
         These changes gone with YE 2003 Phase III
             position 352-362 - should now contain blanks
                      363-384 - should contain zeroes
                      385-512 - should now contain blanks
      */
-- Formatting Ends
      IF (p_report_qualifier = 'PR') THEN
--{
          return_value:='RO'
                        ||lpad(' ',9)
                        ||r_input_2
                        ||r_input_3
                        ||r_input_4
                        ||r_input_5
                        ||r_input_6
                       /* ||r_input_7
                        ||r_input_8 */
			||lpad('0',22,'0') /* 6644795 */
                        ||r_input_22
                        -- ||rpad(nvl(r_input_9,' '),1) /* 6330489 */
                        ||rpad(' ',1)/* 6330489 */
                        --||l_ssn
                        /* Bug 5256745 */
                        ||lpad(' ',9)
                        ||r_input_11
                        ||r_input_12
                        ||r_input_13
                        ||r_input_14
                        ||r_input_15
                        ||r_input_16
                        ||r_input_17
                        ||lpad(' ',11)
                        ||lpad('0',22,'0')
                        ||lpad(' ',128);
--}
         ELSIF p_report_qualifier NOT IN ('MO_KNSAS','MO_STLOU','OH_CCAAA','OH_DAYTO','OH_RTCCA','PA_PHILA') THEN
--{
         return_value:='RO'
                       ||lpad(l_emp_ssn,9)   -- Added for Philadelphia locality
                       ||lpad(parameter_record(1).p_output_value,11)
                       ||parameter_record(2).p_output_value
                       ||parameter_record(3).p_output_value
                       ||parameter_record(4).p_output_value
                       ||parameter_record(5).p_output_value
                       ||parameter_record(6).p_output_value
                       --||rpad(parameter_record(7).p_output_value,187)
                       ||parameter_record(7).p_output_value
                       ||rpad(parameter_record(17).p_output_value,176)
                       -- ||rpad(nvl(r_input_9,' '),1) /* 6330489 */
                       ||rpad(' ',1) /* 6330489 */
                       --||l_ssn
                        /* Bug 5256745 */
                       ||lpad(' ',9)
                       ||r_input_11
                       ||r_input_12
                       ||r_input_13
                       ||r_input_14
                       ||r_input_15
                       ||r_input_16
                       ||rpad(r_input_17,22)
                       ||r_input_18
                       ||rpad(r_input_19,139);

--}
	ELSE

	return_value:='RO'
                       ||lpad(l_emp_ssn,9)   -- Added for Philadelphia locality
                       ||lpad(parameter_record(1).p_output_value,11)
                       ||parameter_record(2).p_output_value
                       ||parameter_record(3).p_output_value
                       ||parameter_record(4).p_output_value
                       ||parameter_record(5).p_output_value
                       ||parameter_record(6).p_output_value
                       --||rpad(parameter_record(7).p_output_value,187)
                       ||parameter_record(7).p_output_value
                       ||rpad(parameter_record(17).p_output_value,176)
                       ||rpad(nvl(r_input_9,' '),1)
                       --||l_ssn
                        /* Bug 5256745 */
                       ||lpad(' ',9)
                       ||r_input_11
                       ||r_input_12
                       ||r_input_13
                       ||r_input_14
                       ||r_input_15
                       ||r_input_16
                       ||rpad(r_input_17,22)
                       ||r_input_18
                       ||rpad(r_input_19,139);
      END IF;

      ret_str_len:=length(return_value);
      hr_utility.trace('length of return_Value RO = '||to_char(ret_str_len));
--}
   ELSIF p_input_40 = 'CSV' THEN
--{
-- Format Mode CSV
--
      IF (p_report_qualifier = 'PR') THEN
   --{
          return_value:=','|| -- As RO_Status column removed from RO record header coma is now prefixed
                    p_input_1
                    ||','||lpad(' ',9)
                    ||','||p_input_2
                    ||','||p_input_3
                    ||','||p_input_4
                    ||','||p_input_5
                    ||','||p_input_6
                    ||','||p_input_7
                    ||','||p_input_8
                    ||','||p_input_22
                    ||','||lpad(' ',165)
                    ||','||rpad(nvl(p_input_9,' '),1)
                    ||','||p_input_10
                    ||','||p_input_11
                    ||','||p_input_12
                    ||','||p_input_13
                    ||','||p_input_14
                    ||','||p_input_15
                    ||','||p_input_16
                    ||','||p_input_17
                    ||','||lpad(' ',11)
                    ||','||lpad('0',11,'0')
                    ||','||lpad('0',11,'0')
                    ||','||lpad(' ',128);
   --}
	ELSE
   --{
         return_value:=','|| -- As RO_Status column removed from RO record header coma is now prefixed
                    p_input_1
                    ||','||lpad(' ',9)
                    ||','||p_input_2
                    ||','||p_input_3
                    ||','||p_input_4
                    ||','||p_input_5
                    ||','||p_input_6
                    ||','||p_input_7
                    ||','||p_input_8
                    ||','||p_input_22
                    ||','||lpad(' ',165)
                    ||','||rpad(nvl(p_input_9,' '),1)
                    ||','||p_input_10
                    ||','||p_input_11
                    ||','||p_input_12
                    ||','||p_input_13
                    ||','||p_input_14
                    ||','||p_input_15
                    ||','||p_input_16
                    ||','||p_input_17
                    ||','||lpad(' ',11)
                    ||','||p_input_18
                    ||','||p_input_19
                    ||','||lpad(' ',128);
    --}

      END IF;
   ELSIF p_input_40 = 'BLANK' THEN
--{
-- Format Mode  BLANK (used for Formatting Blank RO Record)
--
    IF (p_report_qualifier = 'PR') THEN
       return_value:=--','||   As RO_Status column removed from RO record header coma is now prefixed
                    ' '
                    ||','||lpad(' ',9)
                    ||','||' '
                    ||','||' '
                    ||','||' '
                    ||','||' '
                    ||','||' '
                    ||','||' '
                    ||','||' '
                    ||','||' '
                    ||','||lpad(' ',165)
                    ||','||' '
                    ||','||' '
                    ||','||' '
                    ||','||' '
                    ||','||' '
                    ||','||' '
                    ||','||' '
                    ||','||' '
                    ||','||' '
                    ||','||lpad(' ',11)
                    ||','||' '
                    ||','||' '
                    ||','||lpad(' ',128);
--}
   ELSE
       return_value:=  ' '
                    ||','||lpad(' ',9)
                    ||','||' '
                    ||','||' '
                    ||','||' '
                    ||','||' '
                    ||','||' '
                    ||','||' '
                    ||','||' '
                    ||','||' '
                    ||','||lpad(' ',165)
                    ||','||' '
                    ||','||' '
                    ||','||' '
                    ||','||' '
                    ||','||' '
                    ||','||' '
                    ||','||' '
                    ||','||' '
                    ||','||' '
                    ||','||lpad(' ',11)
                    ||','||' '
                    ||','||' '
                    ||','||lpad(' ',128);
     END IF ;
   END IF;
   p_error := l_exclude_from_output_chk;
   ret_str_len:=length(return_value);
   return return_value;

END format_W2_RO_record;
-- End of formatting RO record for W2 reporting
--

/*  ---------------------- Parameter Mapping -----------------------
  Record Identifier                                   --> p_input_1
  State Code                                          --> p_input_2
  Taxing Entity Code                                  --> p_input_3
  Social Security Number (SSN)                        --> p_input_4
  Employee First Name                                 --> p_input_5
  Employee Middle Name or Initial                     --> p_input_6
  Employee Last Name                                  --> p_input_7
  Suffix                                              --> p_input_8
  Location Address                                    --> p_input_9
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

  Fed Wages  Tips and other comp  (for state MA)   |
  Contrib to Qual Plans  (for PR)                  |----> p_input_36
  FIT Withheld  (for state MD)                     |
  Tax credit amt for KY indus revit act (state KY) |
  Federal Employer Account Number (for state AL)   |

  Supplemental Data for KS state                      --> p_input_34
    used for KS state EE contributions to public EE's retirement System
    (KPERS, KPF or Judges)

  Malpractice Insurance Fund (MIF) for NJ State       --> p_input_36

  Cost Reimbursement (for PR)                      |----> p_input_37
  Tax credit amt for KY indus dev act (state KY)   |
  Employee Withholding Allowance provided on W4    |
  as of 31st December,YYYY (for Maryland)          |

  Serial Number  (for PR)                             --> p_input_38
  EE number used for trace messg purpose              --> p_input_39

*/

FUNCTION format_W2_RS_record(
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
l_mif                          varchar2(100);
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

/* PuertoRico W2 related variables  Bug # 2736928 */
l_contact_person_phone_no      varchar2(100);       -- mapped to r_input_34
l_pension_annuity              varchar2(100);       -- mapped to r_input_35
l_contribution_plan            varchar2(100);       -- mapped to r_input_36
l_cost_reimbursement           varchar2(100);       -- mapped to r_input_37
l_uncollected_ss_tax_on_tips   varchar2(100);       -- mapped to r_input_31
l_uncollected_med_tax_on_tips  varchar2(100);       -- mapped to r_input_32
l_rt_end_of_rec                varchar2(200);
l_end_of_rec                   varchar2(20);
l_length                       number(10);
/* Bug 2789523 */
l_last_field                   varchar2(100);
/* Bug 3180532 - local variable for audit record (CSV/BLANK) */
l_audit_field_17               varchar2(100);
l_fl_field_17_20               varchar2(100);
/* EE contributions to public EE's retirement System */
l_ee_contrib_pub_retire_system varchar2(100);
/* Bug 4084765 */
l_nj_dipp_plan_id              varchar2(14);

/* Bug # 5513076 and 5637673 */
swap_street_location_indiana varchar2(300);
IN_state_adv_EIC varchar2(100);

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
r_input_34                     varchar2(500); /* Increased for Puerto Rico */
r_input_35                     varchar2(300);
r_input_36                     varchar2(300);
r_input_37                     varchar2(300);
r_input_38                     varchar2(300);
r_input_39                     varchar2(300);

BEGIN
   hr_utility.trace('Formatting RS record for W2 reporting');
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

   /* Pos:3 - 4 State Code Blank for AL,MA,MD */
   IF (/*(p_report_qualifier = 'MA')       OR  6720319 */
       (p_report_qualifier = 'MD')       OR
       (p_report_qualifier = 'MO_STLOU') OR
       (p_report_qualifier = 'OH_CCAAA') OR
       (p_report_qualifier = 'MO_KNSAS') OR
--       (p_report_qualifier = 'KS')       OR   -- Added for Bug # 2644092 commented to fix bug # 4012469
       (p_report_qualifier = 'AL')) THEN
      r_input_2 := lpad(' ',2);
   ELSE
      r_input_2 := rpad(nvl(r_input_2,' '),2);
   END IF;

   /* Pos:5 - 9 Taxing entity code blank for these states and local */

   IF p_report_qualifier = 'OH_DAYTO' THEN
      r_input_3 := lpad(nvl(p_input_29,' '),5);
   ELSIF p_report_qualifier = 'PR' THEN         /* For bug # 2736928 */
      r_input_3 := lpad('0',5,'0');
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
   ELSE
      l_ssn := replace(replace(r_input_4,'-'),',');
   END IF;

   hr_utility.trace('SSN after Validation and Formatting = '||l_ssn);

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
   hr_utility.trace('l_suffix = '||l_suffix);

   /* Suffix blank for MD,OH_RC,MD_SQWL,MN_SQWL,OH_SQWL */
   IF ((p_report_qualifier = 'MD')        OR
       (p_report_qualifier = 'OH_CCAAA')  OR
       (p_report_qualifier = 'MO_KNSAS')  OR     -- Fix for Bug # 3067494
       (p_report_qualifier = 'OH_RTCCA')) THEN
      l_suffix := lpad(' ',4);
   END IF;

   /* Pos:69 - 149 blank for AL,NC,MO,WV */
   IF ((p_report_qualifier = 'AL') OR
        (p_report_qualifier = 'NC') OR
        (p_report_qualifier = 'MO') --OR -- Fix for bug # 2149507 Bug # 7572620
	--	(p_report_qualifier = 'WV') -- Bug # 3186636
      ) THEN
--{
      hr_utility.trace('Pos:69 - 149 blank for state '||p_report_qualifier);
      l_suffix   := lpad(' ',4);
      r_input_9  := lpad(' ',22);
      r_input_10 := lpad(' ',22);
      r_input_11 := lpad(' ',22);
      r_input_12 := lpad(' ',2);
      r_input_13 := lpad(' ',5);
      r_input_14 := lpad(' ',4);
--}
   END IF;

    IF p_report_qualifier = 'MI' then /* 7681852 */
    l_suffix   := lpad(' ',4);
    end if;

   IF  (p_report_qualifier = 'LA')  -- Bug # 3130999
   THEN
      r_input_9  := lpad(' ',22);
   END IF;


   /* Zip ext is null for MT and ME */

   IF ((p_report_qualifier = 'MT') OR
       (p_report_qualifier = 'MO_STLOU') OR
       (p_report_qualifier = 'ME')) THEN
      r_input_14 := lpad(' ',4);
   END IF;

   /* Pos:155 - 177 178 - 192 193 - 194
      Foreign State / Province --> r_input_15
      Foreign Postal Code      --> r_input_16
      Country Code             --> r_input_17
      Foreign address set to blank for following states and locals */

   IF ((p_report_qualifier = 'AL') OR
       (p_report_qualifier = 'AR') OR
       (p_report_qualifier = 'GA') OR
       (p_report_qualifier = 'ID') OR
       (p_report_qualifier = 'KS') OR
       (p_report_qualifier = 'MD') OR
       (p_report_qualifier = 'DE') OR
       (p_report_qualifier = 'SC') OR
       (p_report_qualifier = 'LA') OR  -- Bug # 3130999
       (p_report_qualifier = 'NE') OR
       (p_report_qualifier = 'ME') OR
       (p_report_qualifier = 'MA') OR
       (p_report_qualifier = 'PA') OR
       --     (p_report_qualifier = 'WV') OR  -- Bug 3186636 Bug # 7572620
       (p_report_qualifier = 'OH_RTCCA') OR
       (p_report_qualifier = 'OH_CCAAA') OR
       (p_report_qualifier = 'NC') OR
       (p_report_qualifier = 'MO') OR   -- Fix for Bug # 2149507
       (p_report_qualifier = 'MO_KNSAS') OR  -- Fix for Bug # 3067494
       (p_report_qualifier = 'MO_STLOU') ) THEN
   --  (p_report_qualifier = 'OH_DAYTO') OR
      -- (p_report_qualifier = 'PA_PHILA') ) THEN /*7579598*/
--{
      r_input_15 := lpad(' ',23);
      r_input_16 := lpad(' ',15);
      r_input_17 := lpad(' ',2);

      IF p_report_qualifier = 'ME' THEN --ME  Country value is not null
         r_input_17 := rpad(nvl(p_input_17,' '),2);
      END IF;
--}
   ELSE
      r_input_15 := rpad(nvl(r_input_15,' '),23);
      r_input_16 := rpad(nvl(r_input_16,' '),15);
      r_input_17 := rpad(nvl(r_input_17,' '),2);
   END IF;

   -- Bug 4739790
   -- Removed blanking of r_input_10 as we require Deliver Address for MO_KNSAS
   IF   (p_report_qualifier = 'MO_KNSAS') -- Fix for Bug # 3067494
   THEN
      r_input_14 := lpad(' ',4);
   END IF;

   /* Pos:195 - 242 Optional code - Date of separation  blanks */
   /* Pos:203-226 State quarterly unemployments details should be Zero filled
                  for MO, OH and PA
      This is to fix bug # 2627606
      This is also true with many states for W2, so changes made for W2
   */
--{
if p_report_qualifier = 'OR' then  /* 9065357  */
   r_input_18 := lpad(' ',2);
   r_input_19 := lpad(' ',6);
   r_input_20 := lpad(' ',11);
   r_input_21 := lpad(' ',11);
   r_input_22 := lpad(' ',2);
	 r_input_23 := lpad(NVL(p_input_29,' '),8, ' ');
	 r_input_24 := lpad(NVL(p_input_30,' '),8, ' ');
else
   r_input_18 := lpad(' ',2);
   r_input_19 := lpad(' ',6);
   r_input_20 := lpad('0',11,'0');
   r_input_21 := lpad('0',11,'0');
   r_input_22 := lpad('0',2,'0');
   r_input_23 := lpad(' ',8);
   r_input_24 := lpad(' ',8);
end if;
   /* Pos:197-202 Reporting period for SC,ME,DC and MT */
-- (p_report_qualifier = 'SC') OR
-- Bug # 3134857  fixed to blank out 197-202 for State of SC
--
   IF ((p_report_qualifier = 'ME') OR
       (p_report_qualifier = 'MT') OR
	 (p_report_qualifier = 'DC') OR /* 8243215 */
       (p_report_qualifier = 'SC')) THEN  /* bug 6641801 */
      r_input_19 := rpad(nvl(p_input_19,' '),6);
   END IF;
   /* As per bug # 2668099 this should be zero filled
      IF p_report_qualifier = 'ME' THEN
         r_input_21 := lpad(' ',11);
      END IF;
   */
   /* Bug #2736928 Puertorico Bug Fix */
   IF (p_report_qualifier = 'PR') THEN
      r_input_15 := lpad(' ',23);
      r_input_16 := lpad(' ',15);
      r_input_17 := lpad(' ',2);
      r_input_18 := lpad('0',2,'0');
      r_input_19 := rpad('0',6,'0');
   END IF;
--}

   /* Pos:248-267 State Employer Account number is blank for ME,MA,MD,IN,PA and OH RITA */

--{
   IF ((p_report_qualifier = 'IN') OR
       (p_report_qualifier = 'ME') OR
       -- Bug# 5693183
       -- (p_report_qualifier = 'GA') OR
       (p_report_qualifier = 'MA') OR
       (p_report_qualifier = 'MD') OR
       (p_report_qualifier = 'PR') OR
       (p_report_qualifier = 'OH_RTCCA') OR
       (p_report_qualifier = 'OH_CCAAA') OR
       (p_report_qualifier = 'MO_STLOU') OR
       (p_report_qualifier = 'MO_KNSAS') OR -- Bug # 3067494
       (p_report_qualifier = 'PA_PHILA') OR
       (p_report_qualifier = 'OH_DAYTO') OR
       (p_report_qualifier = 'PA')) THEN

      r_input_25 := lpad(' ',20);
   -- Bug # 2673612 , 9239621
   ELSIF (p_report_qualifier = 'ID') or (p_report_qualifier = 'OR')  THEN
      r_input_25 := lpad(replace(replace(nvl(replace(r_input_25,' '),' ')
                         ,'-'),'/'),20,'0');
 -- Bug 3936924 , 9115440
 --  ELSIF (p_report_qualifier = 'AL') THEN

--		 if (to_number (nvl(replace(replace(nvl(replace(r_input_25,' '),' ')
  --                       ,'-'),'/') ,'0' )) < 700000) then
  --    r_input_25 := lpad(replace(replace(nvl(replace(r_input_25,' '),' ')
   --                      ,'-'),'/'),10,'0') ||
	  --          rpad(lpad(replace(replace(nvl(replace(r_input_36,' '),' ')
    --                     ,'-'),'/'),9,'0'),10,' ');
	--	 elsif (to_number (nvl(replace(replace(nvl(replace(r_input_25,' '),' ')
    --                     ,'-'),'/') ,'0' )) >= 700000) then
	--			   r_input_25 := 'R' || lpad(replace(replace(nvl(replace(r_input_25,' '),' ')
     --                    ,'-'),'/'),9,'0') ||
	  --          rpad(lpad(replace(replace(nvl(replace(r_input_36,' '),' ')
      --                   ,'-'),'/'),9,'0'),10,' ');
	--	end if;
	-- Bug # 9306028
	 ELSIF (p_report_qualifier = 'AL') THEN
      r_input_25 := lpad(replace(replace(nvl(replace(r_input_25,' '),' ')
                         ,'-'),'/'),10,'0') ||
	            rpad(lpad(replace(replace(nvl(replace(r_input_36,' '),' ')
                         ,'-'),'/'),9,'0'),10,' ');


 -- Bug 4022086
   ELSIF (p_report_qualifier = 'MS') THEN
      r_input_25 := rpad(replace(replace(nvl(replace(r_input_25,' '),' ')
                         ,'-'),'/'),10,'0');
      r_input_36 := rpad(rpad(replace(replace(nvl(replace(r_input_36,' '),' ')
                         ,'-'),'/'),9),10);
      IF p_input_40 = 'FLAT' THEN
         r_input_25 := r_input_25 || r_input_36;
      ELSE
         r_input_25 := r_input_25 || ',' || r_input_36;
      END IF;
   -- Bug# 5693183
   ELSIF (p_report_qualifier = 'GA') THEN
      r_input_25 := lpad('0', 20, '0') ;
   ELSE
     /* Bug:2159881 */
     r_input_25 := rpad(replace(replace(nvl(replace(r_input_25,' '),' ')
                         ,'-'),'/'),20);
   END IF;
--}

   /* Pos:274 - 275 State code blank for PA,NJ,OH RITA ,NC and SQWL */
   IF ((p_report_qualifier = 'PA') OR
       (p_report_qualifier = 'NJ') OR
       (p_report_qualifier = 'MI') OR
       (p_report_qualifier = 'LA') OR        -- Bug # 3130999
       (p_report_qualifier = 'OH_RTCCA') OR
       (p_report_qualifier = 'OH_CCAAA') OR
       (p_report_qualifier = 'MO_STLOU') OR
      -- (p_report_qualifier = 'PA_PHILA') OR /* 7579598 */
       (p_report_qualifier = 'NC') OR
  --     (p_report_qualifier = 'KS') OR  -- commented to fix bug # 4012469 Fix for bug # 2644092
       (p_report_qualifier = 'MO_KNSAS') OR  -- Fix for Bug # 3067494
       (p_report_qualifier = 'MO')   -- Fix for Bug 2149507
      ) THEN
      r_input_26 := lpad(' ',2);
   ELSE
      r_input_26 := rpad(nvl(r_input_26,' '),2);
   END IF;

   /* Pos:276 - 286 State taxable wages.
      Pos:287 - 297 SIT withheld. */

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

   /* SIT withheld and wages are zero fill for OH RITA. */
   IF (p_report_qualifier = 'OH_CCAAA')
   THEN
      r_input_27 := rpad(0,11,0);
      r_input_28 := rpad(0,11,0);
   END IF;

   /* SIT withheld are zero fill for MO KANSAS */
   IF (p_report_qualifier = 'MO_KNSAS')
   THEN
      r_input_28 := rpad(0,11,0);
   END IF;

   /* SIT withheld for St Louis, MO  Local  is zero filled  */
   IF p_report_qualifier = 'MO_STLOU' THEN
      r_input_28 := rpad(0,11,0);
      hr_utility.trace('SIT Withheld = '||r_input_28);
   END IF;

   /* Pos:298 - 307 Other state data AL,MD,OH*/
   /* Pos:298-307 State Excess Wages for LA_SQWL. */
   /* Added by tmehra for bug 2084851 */
   IF ((p_report_qualifier = 'AL') OR
       (p_report_qualifier = 'OH') OR
       (p_report_qualifier = 'MD') OR
       (p_report_qualifier = 'MS')) THEN
   --{
      If p_input_40 = 'FLAT' THEN
         hr_utility.trace(' Other state data AL, OH, MD, MS ');
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
    --}
/*    ELSIF (p_report_qualifier = 'GA') THEN
      r_input_29 := r_input_29 ;*/
   /* Modified only for GA for Bug# 5717438 */
   ELSIF (p_report_qualifier = 'GA') THEN
      r_input_29 := lpad(NVL(r_input_29,' '),10);  -- Bug 5651314
   ELSIF (p_report_qualifier = 'WI') THEN
      r_input_29 :=  lpad(nvl(r_input_29,' '),10,'0'); --Bug 9065558
   ELSIF (p_report_qualifier = 'NM') THEN
    r_input_29 := replace(replace(nvl(replace(p_input_25,' '),' '),'-'),'/');
    l_length := length(r_input_29);
    r_input_29 := lpad(substr(r_input_29 , l_length -9 , l_length ),10,'0');
   ELSE
      r_input_29 := lpad(' ',10);
   END IF;

   /* BUG 5717304 and Bug 5717384 */
  IF (p_report_qualifier = 'KY')
  -- OR p_report_qualifier = 'NJ' ) /* 9065458  */
   THEN
      r_input_29 :=  lpad(NVL(' ',' '),10);
   END IF;

   /* Pos:308 - 308 Tax type code  IN and OH */
   IF p_report_qualifier = 'OH' THEN
      r_input_30 := rpad(nvl(r_input_30,' '),1);
   ELSIF p_report_qualifier = 'IN' THEN /*Bug:2128995 */
      r_input_29 := lpad(' ',9);
      r_input_30 := lpad(nvl(r_input_30,' '),2,'0');
   ELSIF p_report_qualifier = 'PR' THEN /*Bug:2736928 */
--      r_input_30 := 'F';
        r_input_30 := ' ';  -- Bug # 3337295
   ELSE
      r_input_30 := lpad(' ', 1);
   END IF;

   /* Pos:309 - 319 Local taxable wages OH ,IN and OH RITA
      Pos:320 - 330 Local Income tax withheld */

   IF ((p_report_qualifier = 'OH') OR
       (p_report_qualifier = 'OH_RTCCA') OR
       (p_report_qualifier = 'OH_CCAAA') OR
       (p_report_qualifier = 'MO_STLOU') OR
       (p_report_qualifier = 'MO_KNSAS') OR  -- Fix for Bug # 3067494
       (p_report_qualifier = 'PA_PHILA') OR
       (p_report_qualifier = 'OH_DAYTO') OR
       (p_report_qualifier = 'IN') ) THEN
--{
      IF p_input_40 = 'FLAT' THEN
-- Validating Local Taxable Wages
         r_input_31 :=
           pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                      p_report_type,
                                                      p_format,
                                                      p_report_qualifier,
                                                      p_record_name,
                                                      'NEG_CHECK',
                                                      r_input_31,
                                                      'Local taxable Wages',
                                                      p_input_39,
                                                      null,
                                                      p_validate,
                                                      p_exclude_from_output,
                                                      sp_out_1,
                                                      sp_out_2);
         IF p_exclude_from_output = 'Y' THEN
            l_exclude_from_output_chk := TRUE;
         END IF;
--  Validating Local Income Tax withheld
         r_input_32 := pay_us_reporting_utils_pkg.data_validation( p_effective_date,
                                               p_report_type,
                                               p_format,
                                               p_report_qualifier,
                                               p_record_name,
                                               'NEG_CHECK',
                                               r_input_32,
                                               'Local Income tax withheld',
                                               p_input_39,
                                               null,
                                               p_validate,
                                               p_exclude_from_output,
                                               sp_out_1,
                                               sp_out_2);
         IF p_exclude_from_output = 'Y' THEN
            l_exclude_from_output_chk := TRUE;
         END IF;
         hr_utility.trace('Local Taxable Wages after validation n Formatting '
                          ||r_input_31);
         hr_utility.trace('Local Tax Withhel after validation n Formatting '
                          ||r_input_32);
      END IF;
--}
   ELSE /* Zero Fill for other States. */
      hr_utility.trace('Zero fill for SQWLs. p_report_qualifier = '||p_report_qualifier);
      r_input_31 := rpad(0,11,0);
      r_input_32 := rpad(0,11,0);
      hr_utility.trace('r_input_31 '||r_input_31);
      hr_utility.trace('r_input_32 '||r_input_32);
   END IF;

   /* Pos:309-330 Blank for SC_SQWL. State wages and SIT withheld. */
   IF (p_report_qualifier = 'AR')    -- To fix bug # 2668250
   THEN

      r_input_31 := lpad(' ',11);
      r_input_32 := lpad(' ',11);
   END IF;

   /* Pos:331 - 337 State Control number OH,IN,KY,NJ and GA
      Pos:338 - 412 Supplemental data1
      Pos:413 - 487 Supplemental data2  */
   r_input_33 := replace(replace(replace(p_input_33,'-'),' '),'/');

   IF p_report_qualifier = 'OH' THEN
         -- Bug 4730413
         r_input_33 := lpad(nvl(r_input_33,' '),7);
         r_input_34 := lpad(' ',75);
         r_input_35 := lpad(' ',75);
   /* Bug 3180532
      Pos: 193-203 Federal Advanced EIC
      Pos: 204 - 273 Blank fill
      Pos: 341 - 352 Box 19b - State Adv EIC
      Pos: 353 - 357 Box 20b - Adv EIC ID "INADV"
      Pos: 358 - 512 Blank fill */
   ELSIF p_report_qualifier = 'IN' THEN
         IF p_input_40 = 'FLAT' THEN
           r_input_17:=
           pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                      p_report_type,
                                                      p_format,
                                                      p_report_qualifier,
                                                      p_record_name,
                                                      'NEG_CHECK',
                                                      p_input_17,
                                                      'Federal Advanced EIC',
                                                      p_input_39,
                                                      null,
                                                      p_validate,
                                                      p_exclude_from_output,
                                                      sp_out_1,
                                                      sp_out_2);
           IF p_exclude_from_output = 'Y' THEN
              l_exclude_from_output_chk := TRUE;
           END IF;

           r_input_34:=
           pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                      p_report_type,
                                                      p_format,
                                                      p_report_qualifier,
                                                      p_record_name,
                                                      'NEG_CHECK',
                                                      r_input_34,
                                                      'State Advanced EIC',
                                                      p_input_39,
                                                      null,
                                                      p_validate,
                                                      p_exclude_from_output,
                                                      sp_out_1,
                                                      sp_out_2);
           IF p_exclude_from_output = 'Y' THEN
              l_exclude_from_output_chk := TRUE;
           END IF;
	   hr_utility.trace('Federal Advanced EIC after validation n Formatting '
                          ||r_input_17);
           hr_utility.trace('State Advanced EIC after validation n Formatting '
                          ||r_input_34);

	   r_input_21 := lpad(' ',11);
           r_input_22 := lpad(' ',2);
           r_input_33 := rpad(nvl(r_input_33,' '),10,0);                -- Bug 5513076,5637673
           r_input_34 := rpad(lpad(r_input_34,11,0) || r_input_35,72);  -- Bug 4720007
           r_input_35 := lpad(' ',75);

         END IF;
         r_input_17 := lpad(r_input_17,11,0) ;
-- Bug 3936924
   ELSIF p_report_qualifier = 'AL' THEN
         r_input_33 := lpad(' ',7);
         -- for bug 4279809
         r_input_34 := rpad((rpad(rpad('0',11,'0'),55,' ')||r_input_34),75,' ');
         --r_input_34 := rpad(lpad(r_input_34,59,' '),75,' ');
         r_input_35 := lpad(' ',75);
         IF p_input_40 = 'CSV' THEN
            r_input_25 := p_input_25 || ',' || p_input_36;
         END IF;
   ELSIF p_report_qualifier = 'GA' THEN /* 6855543 */

        r_input_33 := rpad(nvl(r_input_33,' '),9);
         r_input_34 := rpad(substr(nvl(upper(p_input_30),' '),1,57),57)
        ||rpad(substr(nvl(p_input_31,' '),1,22),22)
        ||rpad(substr(nvl(p_input_32,' '),1,22),22)
        ||rpad(substr(nvl(p_input_34,' '),1,22),22)
        ||rpad(substr(nvl(p_input_35,' '),1,2),2)
        ||rpad(substr(nvl(p_input_36,' '),1,5),5)
        ||rpad(substr(nvl(p_input_37,' '),1,4),4)
        ||rpad(substr(replace(replace(nvl(replace(p_input_38,' '),' '),'-'),'/'),1,9),9);
         r_input_35 := lpad(' ',5);
   ELSIF  p_report_qualifier = 'ME' THEN
         r_input_33 := lpad(' ',7);
         r_input_34 := rpad(rpad(nvl(replace(replace(r_input_34,'-'),' '),' '),11),75);
         r_input_35 := lpad(' ',75);
   ELSIF p_report_qualifier = 'MA' THEN
         r_input_33 := lpad(' ',7);
         IF p_input_40 = 'FLAT' THEN
            l_fica_mcr_wh :=
              pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                         p_report_type,
                                                         p_format,
                                                         p_report_qualifier,
                                                         p_record_name,
                                                         'NEG_CHECK',
                                                         r_input_34,
                                                         'FICA_MCR_WH',
                                                         p_input_39,
                                                         null,
                                                         p_validate,
                                                         p_exclude_from_output,
                                                         sp_out_1,
                                                         sp_out_2);
            l_w2_govt_ee_contrib  :=
              pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                         p_report_type,
                                                         p_format,
                                                         p_report_qualifier,
                                                         p_record_name,
                                                         'NEG_CHECK',
                                                         r_input_35,
                                                         'W2_GOVT_EE_CONTRIB',
                                                         p_input_39,
                                                         null,
                                                         p_validate,
                                                         p_exclude_from_output,
                                                         sp_out_1,
                                                         sp_out_2);
            l_w2_fed_wages  :=
              pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                         p_report_type,
                                                         p_format,
                                                         p_report_qualifier,
                                                         p_record_name,
                                                         'NEG_CHECK',
                                                         r_input_36,
                                                         'FED_WAGES',
                                                         p_input_39,
                                                         null,
                                                         p_validate,
                                                         p_exclude_from_output,
                                                         sp_out_1,
                                                         sp_out_2);
         /*   r_input_34 := l_fica_mcr_wh||l_w2_govt_ee_contrib||l_w2_fed_wages
                                       ||lpad(' ',42); */
            r_input_34 := lpad(' ',75); /* 6720319 */
            r_input_35 := lpad(' ',75);
         ELSE
            r_input_34 := r_input_34;
            r_input_35 := 'Federal Railroad MA and Local Govt '||
                          'retirement contribution  '||
                          p_input_35||' | '||
                          'Fed Wages  Tips and other comp  '||p_input_36;
         END IF;

   ELSIF p_report_qualifier = 'NJ' THEN
      --   r_input_33 := lpad(' ',7); /* 9065458  */
         IF p_input_40 = 'FLAT' THEN

            l_mif :=
	      pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                         p_report_type,
                                                         p_format,
                                                         p_report_qualifier,
                                                         p_record_name,
                                                         'NEG_CHECK',
                                                         p_input_36,
                                                         'MIF',
                                                         p_input_39,
                                                         null,
                                                         p_validate,
                                                         p_exclude_from_output,
                                                         sp_out_1,
                                                         sp_out_2);
            IF p_exclude_from_output = 'Y' THEN
              l_exclude_from_output_chk := TRUE;
            END IF;

            l_unemp_insurance :=
              pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                         p_report_type,
                                                         p_format,
                                                         p_report_qualifier,
                                                         p_record_name,
                                                         'NEG_CHECK',
                                                         p_input_31,
                                                  'Unemployment Insurance Tax',
                                                         p_input_39,
                                                         null,
                                                         p_validate,
                                                         p_exclude_from_output,
                                                         sp_out_1,
                                                         sp_out_2);
            l_sdi_wh :=
              pay_us_reporting_utils_pkg.data_validation( p_effective_date,
                                                         p_report_type,
                                                         p_format,
                                                         p_report_qualifier,
                                                         p_record_name,
                                                         'NEG_CHECK',
                                                         p_input_32,
                                                         'SDI Withheld',
                                                         p_input_39,
                                                         null,
                                                         p_validate,
                                                         p_exclude_from_output,
                                                         sp_out_1,
                                                         sp_out_2);
            l_deferred_comp :=
              pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                         p_report_type,
                                                         p_format,
                                                         p_report_qualifier,
                                                         p_record_name,
                                                         'NEG_CHECK',
                                                         p_input_35,
                                                         'Deferred Comp',
                                                         p_input_39,
                                                         null,
                                                         p_validate,
                                                         p_exclude_from_output,
                                                         sp_out_1,
                                                         sp_out_2);

            /* Bug 4014356*/
/* Bug 9065458  */
r_input_29 := lpad(' ',1);
r_input_30 := rpad(nvl(p_input_37,' '),15,' ');
r_input_31 := lpad(nvl(p_input_38,'0'),5,0);
r_input_32 := lpad(' ', 19);
r_input_33 :='';
	  /*  r_input_30 := lpad(l_mif,3,0);
 r_input_31 := lpad(' ',9);
	    r_input_32 := lpad(' ',11);
            r_input_33 := lpad(' ',7); */

             -- Bug 3895206 - Last 14 characters of NJ DIPP ID only reqd
             -- Bug 4084765 - Added logic for displaying DIPP plan ID whose length is less than 14
            IF length(p_input_30) >= 14 THEN
               l_nj_dipp_plan_id := rpad(substr(p_input_30,-14),14);
            ELSE
	       l_nj_dipp_plan_id := substr(rpad(nvl(p_input_30,' '),14),-14);
            END IF;

            r_input_34 := rpad(nvl(p_input_29,' '),1)|| l_nj_dipp_plan_id
	                   ||l_unemp_insurance ||l_sdi_wh||rpad(
                           nvl(p_input_33,' '),1)||rpad(nvl(p_input_34,' '),1)
                           ||l_deferred_comp;
            r_input_35 := lpad(' ',114);

         ELSE
	    r_input_30 := p_input_36;
            r_input_34 := r_input_29||','||p_input_30||','||p_input_31||','||
                          p_input_32||','||p_input_33||','||p_input_34||','||
                          p_input_35;
            r_input_35 := lpad(' ',10);
         END IF;
   ELSIF p_report_qualifier = 'KY' THEN
         r_input_33 := rpad(nvl(r_input_33,' '),7);
         IF p_input_40 = 'FLAT' THEN
            l_tax_ct_rural :=
              pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                         p_report_type,
                                                         p_format,
                                                         p_report_qualifier,
                                                         p_record_name,
                                                         'NEG_CHECK',
                                                         r_input_34,
                                        'Tax credit amount for KY rural asst.',
                                                         p_input_39,
                                                         null,
                                                         p_validate,
                                                         p_exclude_from_output,
                                                         sp_out_1,
                                                         sp_out_2);
            l_tax_ct_job_dev :=
              pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                         p_report_type,
                                                         p_format,
                                                         p_report_qualifier,
                                                         p_record_name,
                                                         'NEG_CHECK',
                                                         r_input_35,
                                        'Tax credit amount for KY job dev act',
                                                         p_input_39,
                                                         null,
                                                         p_validate,
                                                         p_exclude_from_output,
                                                         sp_out_1,
                                                         sp_out_2);
            l_tax_ct_ind_revit :=
              pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                         p_report_type,
                                                         p_format,
                                                         p_report_qualifier,
                                                         p_record_name,
                                                         'NEG_CHECK',
                                                         r_input_36,
                                       'Tax credit amt for KY indus revit act',
                                                         p_input_39,
                                                         null,
                                                         p_validate,
                                                         p_exclude_from_output,
                                                         sp_out_1,
                                                         sp_out_2);
            l_tax_ct_ind_dev :=
              pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                         p_report_type,
                                                         p_format,
                                                         p_report_qualifier,
                                                         p_record_name,
                                                         'NEG_CHECK',
                                                         r_input_37,
                                        'Tax credit amt for KY indus dev act',
                                                         p_input_39,
                                                         null,
                                                         p_validate,
                                                         p_exclude_from_output,
                                                         sp_out_1,
                                                         sp_out_2);
            r_input_34 := l_tax_ct_rural||l_tax_ct_job_dev||l_tax_ct_ind_revit
                                          ||l_tax_ct_ind_dev||lpad(' ',31);
            r_input_35 := lpad(' ',75);
         ELSE
            r_input_34 := r_input_34||','||r_input_35||','||r_input_36||','||r_input_37;
            r_input_35 := lpad(' ',75);
         END IF;
   ELSIF p_report_qualifier = 'MD' THEN
--{
         r_input_33 := lpad(' ',7);
         IF p_input_40 = 'FLAT' THEN
            l_wages_tips :=
              pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                         p_report_type,
                                                         p_format,
                                                         p_report_qualifier,
                                                         p_record_name,
                                                         'NEG_CHECK',
                                                         p_input_35,
                                                         'Wages Tips',
                                                         p_input_39,
                                                         null,
                                                         p_validate,
                                                         p_exclude_from_output,
                                                         sp_out_1,
                                                         sp_out_2);
            l_fit_wh :=
              pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                         p_report_type,
                                                         p_format,
                                                         p_report_qualifier,
                                                         p_record_name,
                                                         'NEG_CHECK',
                                                         r_input_36,
                                                         'FIT Withheld',
                                                         p_input_39,
                                                         null,
                                                         p_validate,
                                                         p_exclude_from_output,
                                                         sp_out_1,
                                                         sp_out_2);

            -- Bug 4728539
            -- 368-369 should be filled with ZERO's
            -- Bug# 4736977
            -- 368-369 should report Employee Withholding Allowances
            r_input_34 := rpad(nvl(r_input_34,' '),8)||l_wages_tips||l_fit_wh||lpad(r_input_37,2,'0')||lpad(' ',43);
            r_input_35 := lpad(' ',75);
         ELSE
            r_input_34 := r_input_34||','||r_input_35||','||r_input_36;
            r_input_35 := lpad(' ',8);
         END IF;
--}
      /* Start of PuertoRico Supplemental Data formating */
   ELSIF p_report_qualifier = 'PR' THEN
--{
      /* These changes added for Bug # 3337295  */
      --{

         r_input_23 := lpad(0,8,0);
         r_input_24 := lpad(0,8,0);
         --r_input_26 := lpad(' ',2);
	 r_input_26 := '00';		   --  Bug  #  5668970
         r_input_27 := rpad(0,11,0);
         r_input_28 := rpad(0,11,0);
         r_input_29 := lpad(0,10,0);

      --}

         r_input_33 := lpad(' ',7);
         IF p_input_40 = 'FLAT' THEN
            l_pension_annuity :=
              pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                         p_report_type,
                                                         p_format,
                                                         p_report_qualifier,
                                                         p_record_name,
                                                         'NEG_CHECK',
                                                         p_input_35,
                                                         'Cost of Pension Annuity',
                                                         p_input_39,
                                                         null,
                                                         p_validate,
                                                         p_exclude_from_output,
                                                         sp_out_1,
                                                         sp_out_2);
            l_contribution_plan :=
              pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                         p_report_type,
                                                         p_format,
                                                         p_report_qualifier,
                                                         p_record_name,
                                                         'NEG_CHECK',
                                                         p_input_36,
                                                         'Contrib to Qual Plans',
                                                         p_input_39,
                                                         null,
                                                         p_validate,
                                                         p_exclude_from_output,
                                                         sp_out_1,
                                                         sp_out_2);
            l_cost_reimbursement :=
              pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                         p_report_type,
                                                         p_format,
                                                         p_report_qualifier,
                                                         p_record_name,
                                                         'NEG_CHECK',
                                                         p_input_37,
                                                         'Cost Reimbursement',
                                                         p_input_39,
                                                         null,
                                                         p_validate,
                                                         p_exclude_from_output,
                                                         sp_out_1,
                                                         sp_out_2);
            l_uncollected_ss_tax_on_tips :=
              pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                         p_report_type,
                                                         p_format,
                                                         p_report_qualifier,
                                                         p_record_name,
                                                         'NEG_CHECK',
                                                         p_input_31,
                                                         'Uncollected SS Tax on Tips',
                                                         p_input_39,
                                                         null,
                                                         p_validate,
                                                         p_exclude_from_output,
                                                         sp_out_1,
                                                         sp_out_2);
            l_uncollected_med_tax_on_tips :=
              pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                         p_report_type,
                                                         p_format,
                                                         p_report_qualifier,
                                                         p_record_name,
                                                         'NEG_CHECK',
                                                         p_input_32,
                                               'Uncollected Med Tax on Tips',
                                                         p_input_39,
                                                         null,
                                                         p_validate,
                                                         p_exclude_from_output,
                                                         sp_out_1,
                                                         sp_out_2);
            r_input_34 := rpad(nvl(' ',' '),10)||-- Contact Person Phone
                         -- lpad(' ',8)||              -- Operations Closing Date  5876054
                          lpad('0',8,'0')||
                          lpad(nvl(replace(p_input_38,' '),' '),9,'0')|| -- Serial Number
                          lpad(nvl(l_pension_annuity,'0'),11,'0')||      -- Cost of Pension Annuity
    				      lpad(nvl(l_contribution_plan,'0'),11,'0')||    -- Contributions to qualified Plans
   				          lpad(nvl(l_cost_reimbursement,'0'),11,'0')||          -- Cost Reimbursement
                          lpad(' ',1)||                                         -- Amendment Indicator
                      /*    lpad(nvl(substr(replace(p_input_29,' '),1,5),' '),5)||   */    -- Access code
		          lpad(' ',5)|| /* 6644795 */
                          lpad(nvl(l_uncollected_ss_tax_on_tips,'0'),11,'0')||  -- Uncollected SS tax on Tips
                          lpad(nvl(l_uncollected_med_tax_on_tips,'0'),11,'0');  -- Uncollected Med. Tax on Tips
            r_input_35 := lpad('0',5,'0') || lpad('0',11,'0') || lpad('0',8,'0') || lpad(' ',38); --Bug 4665713  Bug 5876054
         ELSE
            r_input_34 :=  'Contact Person Phone '||p_input_34 || '|' ||
                           'Operations Closing Date '|| ' |' ||
                           'Serial Number '||p_input_38|| ' |' ||
                           'Cost of Pension or annuity '||p_input_35|| '|' ||
                           'Contrib to Qual Plans '||p_input_36|| '|' ||
                           'Cost Reimbursement '||p_input_37|| '|' ||
                           'Amendment Indicator '|| ' |' ||
                           'Access Code '||p_input_29||  ' |' ||
                           'Uncollected SS Tax on Tips '||p_input_31|| '|' ||
                           'Uncollected Med Tax on Tips '||p_input_32 || '|' ||
			   'Specialist Register Number '||lpad(' ',5)|| '|' || /* Bug 4665713 */
			   'Salaries Und Act 324 of 2004 '|| '0' ;

            r_input_35 :=  lpad(' ',46); /* Bug 4665713 */
         END IF;
                 /* End of Puertorico Supplemental Data */

   /* Bug # 3186636 - Formatting for WV */
   ELSIF p_report_qualifier = 'WV' THEN
       r_input_18 := lpad(' ',2); /* 7572620 */
      r_input_19 := lpad(' ',6);
      r_input_20 := lpad(' ',11);
      r_input_21 := lpad(' ',11);
      r_input_22 := lpad(' ',2);
      r_input_23 := lpad(' ',8);

     -- r_input_23 := lpad(0,8,0);
      r_input_24 := lpad(' ',8);
      r_input_29 := lpad(' ',10);
      r_input_30 := ' ';
      r_input_31 := lpad(0,11,0);
      r_input_32 := lpad(0,11,0);
      r_input_33 := lpad(' ',7);
      r_input_34 := lpad(' ',75);
      r_input_35 := lpad(' ',75);

   ELSIF p_report_qualifier = 'WI' THEN -- Bug 9065558
      r_input_31 := lpad(' ',11);
      r_input_32 := lpad(' ',11);
      r_input_33 := lpad(' ',7);
      r_input_34 := lpad(' ',75);
      r_input_35 := lpad(' ',75);

   /* Bug 4022086 - Formatting for MS */
   ELSIF p_report_qualifier = 'MS' THEN
      r_input_33 := lpad(' ',7);
      IF p_input_40 = 'FLAT' THEN
         r_input_34 := rpad(rpad(lpad(0,11,0),55,' ') || r_input_35,75,' ');
         r_input_35 := lpad(' ',75);
      ELSE
         r_input_34 := p_input_34 || ',' || p_input_35;
	 r_input_35 := ' ';
      END IF;
   ELSIF p_report_qualifier = 'KS' THEN
     r_input_2  := '20';
     r_input_26 := '20';
     r_input_33 := lpad(' ',7);
     l_ee_contrib_pub_retire_system :=
           pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                      p_report_type,
                                                      p_format,
                                                      p_report_qualifier,
                                                      p_record_name,
                                                      'NEG_CHECK',
                                                      p_input_34,
                                                      'EE contrib to retirement systems',
                                                      p_input_39,
                                                      null,
                                                      p_validate,
                                                      p_exclude_from_output,
                                                      sp_out_1,
                                                      sp_out_2);
           IF p_exclude_from_output = 'Y' THEN
              l_exclude_from_output_chk := TRUE;
           END IF;
      IF p_input_40 = 'FLAT' THEN
         r_input_34 := rpad(lpad(l_ee_contrib_pub_retire_system,11,0),75,' ');
         r_input_35 := lpad(' ',75);
      ELSE
         r_input_34 := p_input_34;
   	     r_input_35 := ' ';
      END IF;
   /* Bug 5696443 - New fields for AR */
   ELSIF p_report_qualifier = 'AR' THEN
      r_input_33 := rpad(' ',7);
      r_input_34 := rpad(lpad(replace(replace(nvl(replace(p_input_34,' '),' '),'-'),'/'),9,'0'),75,' ');
      r_input_35 := rpad(replace(nvl(p_input_35,' '),'-'),75,' ');
   ELSE
   -- Supplemental data for other states filled with blank
   --
      r_input_33 := lpad(' ',7);
      r_input_34 := lpad(' ',75);
      r_input_35 := lpad(' ',75);
   END IF; /* W2 States. */


   /* OH RITA 298-304 blanks. 305-307 City code.
                 Pos:308 C=Emp.City R=Res.City  */
   IF (p_report_qualifier = 'OH_RTCCA')
   THEN
     /*r_input_29 := lpad(rpad(nvl(replace(p_input_29,' '),'000'),3),10); */
      r_input_3  := 'RO' || rpad(nvl(replace(p_input_29,' '),'000'),3); /* 6716247 */
      r_input_29 := rpad(' ',10);
      r_input_30 := rpad(nvl(p_input_30,' '),1);
   /* Bug 4045592 - Commented the following code as blank is reqd from 338-412
      r_input_34 := rpad(rpad(nvl(replace(upper(p_input_34),' '),' '),22),75); */

   END IF;

   IF (p_report_qualifier = 'OH_CCAAA')
   THEN
     r_input_29 := lpad(rpad(nvl(replace(p_input_29,' '),'000'),3),10);
      r_input_30 := rpad(nvl(p_input_30,' '),1);
   /* Bug 4045592 - Commented the following code as blank is reqd from 338-412
      r_input_34 := rpad(rpad(nvl(replace(upper(p_input_34),' '),' '),22),75); */
   END IF;


   IF ((p_report_qualifier = 'MO_STLOU') OR
       (p_report_qualifier = 'PA_PHILA') OR
       (p_report_qualifier = 'OH_DAYTO')) THEN
      r_input_30 := rpad(nvl(p_input_30,' '),1);
   END IF;

   IF (p_report_qualifier = 'MO_KNSAS')  THEN
      r_input_30 := rpad(' ',1);
   END IF;

   IF p_report_qualifier = 'PA_PHILA' THEN
      hr_utility.trace('Company Locality Id '||p_input_33);
      r_input_33 := lpad(substr(NVL(p_input_33,' '),1,7),7);
   END IF;

   IF p_report_qualifier = 'OH_DAYTO' THEN
      r_input_34 := rpad(lpad(nvl(r_input_31,'0'),12,'0'),75);
      r_input_35 := rpad(lpad(nvl(r_input_32,'0'),12,'0'),75);
   END IF;
   /* City Name should be displayed for OH RITA for Taxes Withheld */
   /* Bug 5886247 */
   IF (p_report_qualifier = 'OH_RTCCA') THEN /* 6716247 */
      r_input_34 := lpad(' ',75);
     /* IF to_number(nvl(r_input_32,'0')) > 0 THEN
         r_input_34 := rpad(rpad(nvl(p_input_34,' '),22,' '),75, ' ') ;
      END IF ; */
   END IF ;

   /* Fix for Bug # 2680070 */
   hr_utility.trace('Value of Stock Option Amount '||p_input_35);
   IF (p_report_qualifier = 'MO_STLOU') THEN
      IF (to_number(NVL(p_input_35,'0')) > 0) THEN
         r_input_34 := 'STK'||lpad(NVL(p_input_35,'0'),11,'0')||lpad(' ',61);
         r_input_35 := lpad(' ',75);
      ELSE
         r_input_34 := lpad(' ',3)||rpad('0',11,'0')||lpad(' ',61);
         r_input_35 := lpad(' ',75);
      END IF;
   END IF;
   hr_utility.trace('Value of r_input_34 '||r_input_34);

   l_last_field := lpad(' ',25);

  /*  if p_report_qualifier = 'WI' THEN -- Bug 9065558
  l_last_field := rpad('0',25,'0');
  END IF;        */

    IF p_report_qualifier = 'OR' THEN /* 9065357 */
		  r_input_31 := lpad(' ',11);
      r_input_32 := lpad(' ',11);
 end if ;

  if p_report_qualifier = 'MD' Then /* 7572352 */
    l_last_field  := lpad(' ',9) || to_char(sysdate,'YYYYMMDD')
                          ||to_char(systimestamp,'HH24MISSFF2') ;

    end if ;

   IF p_input_40 = 'FLAT' THEN
--{ Start of formatting FLAT type RS Record
--
      IF p_report_qualifier = 'IN' THEN
         l_fl_field_17_20 := r_input_17 || lpad(' ',10);

	 /* Bug # 5513076 */
         swap_street_location_indiana := r_input_9;
         r_input_9 := r_input_10;                 /*pos 73-94 Street Address pos 95-116 Location Address */
         r_input_10 := swap_street_location_indiana;

	 -- Bug 5513076,5637673
          IN_state_adv_EIC := substr(r_input_34,1,11);
          r_input_34 := /*'000' Commenting for Bug# 5739737*/
                        lpad(nvl(substr(p_input_33, -3),'0'),3,'0')||
                        IN_state_adv_EIC||'INADV'||substr(r_input_34,20,53);




      ELSE
         l_fl_field_17_20 := r_input_17 || r_input_18 || r_input_19 || r_input_20 ;
      END IF;

      IF p_report_qualifier = 'MD' THEN /* 6648007 */
     /* r_input_32 := lpad(' ', 8) || rpad(substr(nvl(p_input_38,' '),1,9),9) ; */
      r_input_32 := lpad(' ', 8) || rpad(substr(replace(replace(nvl(p_input_38,' '),'-'),'/'),1,9),9);
      r_input_33 := ' ' ;
      END IF;

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
                         ||l_fl_field_17_20
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

      hr_utility.trace('Length of return value = '||to_char(length(return_value)));
--} End of formatting FLAT Type RS Record
   ELSIF p_input_40 = 'CSV' THEN
--{ Start of formatting RS record in CSV format
      /* Bug 3180532
         IN does not require fields Country Code, Optional code and Reporting Period */
      IF p_report_qualifier = 'IN' THEN
         l_audit_field_17 := p_input_17;
      ELSE
         l_audit_field_17 := r_input_17 ||','|| r_input_18 ||','|| r_input_19 ;
      END IF;

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
                      ||','||l_audit_field_17
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
--} End of formatting RS record in CSV format
--
   ELSIF p_input_40 = 'BLANK' THEN
--{ Start of formatting BALNK RS record used for audit report
--
   /* Bug 3180532 - IN does not require fields Country Code,
                    Optional code and Reporting Period */
   IF p_report_qualifier = 'IN' THEN
         l_audit_field_17 := ' ';
      ELSE
         l_audit_field_17 := ' '||','||' '||','||' ';
      END IF;

      return_value := ''
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
                      ||','|| l_audit_field_17
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
END format_W2_RS_record;
-- End of Formatting RS Record for W2 Reporting

-- Formatting RT record for W2 reporting
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

  For Massachussets following input parameters were used
      W2 Govt EE Contributions                                   --> p_input_23
      Total Fed Wages                                            --> p_input_24

  For PuertoRico following input parameters were used
     Cost of Pension or Annuity                                  --> p_input_23
     Contributions to Qualified Plans                            --> p_input_24
     Cost Reimbursement                                          --> p_input_25
  Employer Contributions to a Health Savings Account             --> p_input_26
  Non-Taxable Combat Pay                                         --> p_input_27
  Deferrals Under a Section 409A Non-Qualified Deferred Comp Plan--> p_input_28
  Designated Roth Contributions to a section 401(k) Plan         --> p_input_31
  Designated Roth Contributions Under a section 403(b) Plan      --> p_input_32
*/
FUNCTION format_W2_RT_record(
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
p_end_of_rec               varchar2(20) :=
                             fnd_global.local_chr(13)||fnd_global.local_chr(10);

TYPE function_columns IS RECORD(
                                p_parameter_name  varchar2(100),
                                p_parameter_value varchar2(100),
                                p_output_value varchar2(100)
                               );
function_parameter_rec  function_columns;
TYPE input_parameter_record IS TABLE OF function_parameter_rec%TYPE
                               INDEX BY BINARY_INTEGER;
parameter_record input_parameter_record;

r_input_1 varchar2(300);
r_input_2 varchar2(300);
r_input_3 varchar2(300);
r_input_4 varchar2(300);
r_input_5 varchar2(300);
r_input_6 varchar2(300);
r_input_7 varchar2(300);
r_input_8 varchar2(300);
r_input_9 varchar2(300);
r_input_10 varchar2(300);
r_input_11 varchar2(300);
r_input_12 varchar2(300);
r_input_13 varchar2(300);
r_input_14 varchar2(300);
r_input_15 varchar2(300);
r_input_16 varchar2(300);
r_input_17 varchar2(300);
r_input_18 varchar2(300);
r_input_19 varchar2(300);
r_input_20 varchar2(300);
r_input_21 varchar2(300);
r_input_22 varchar2(300);
r_input_23 varchar2(300);
r_input_24 varchar2(300);
r_input_25 varchar2(300);
r_input_26 varchar2(300);
r_input_27 varchar2(300);
r_input_28 varchar2(300);
r_input_29 varchar2(300);
r_input_30 varchar2(300);
r_input_31 varchar2(300);
r_input_32 varchar2(300);
r_input_33 varchar2(300);
r_input_34 varchar2(300);
r_input_35 varchar2(300);
r_input_36 varchar2(300);
r_input_37 varchar2(300);
r_input_38 varchar2(300);
r_input_39 varchar2(300);

BEGIN
--   hr_utility.trace_on(null,'RI_W2') ;
   hr_utility.trace('Formatting RT record for W2 reporting');
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
--  Validation Starts
   If p_input_40='FLAT' THEN
--{
    IF p_report_qualifier = 'MA' THEN
--{
       parameter_record(1).p_parameter_name:= 'State taxable Wages';
       parameter_record(1).p_parameter_value:=p_input_3;

       parameter_record(2).p_parameter_name:= 'SIT withheld';
       parameter_record(2).p_parameter_value:=p_input_4;

       parameter_record(3).p_parameter_name:= 'FICA and Medicare withheld';
       parameter_record(3).p_parameter_value:=p_input_5;

       parameter_record(4).p_parameter_name:= 'W2 Govt EE Contributions';
       parameter_record(4).p_parameter_value:=p_input_23;

       parameter_record(5).p_parameter_name:= 'Total Fed Wages';
       parameter_record(5).p_parameter_value:=p_input_24;
       l_records :=5;
--}
    ELSIF p_report_qualifier = 'CT' THEN
--{
       parameter_record(1).p_parameter_name:= 'State taxable Wages';
       parameter_record(1).p_parameter_value:=p_input_3;

       parameter_record(2).p_parameter_name:= 'SIT withheld';
       parameter_record(2).p_parameter_value:=p_input_4;

       l_records :=2;
--}
    ELSIF p_report_qualifier = 'PA' THEN
--{
       parameter_record(1).p_parameter_name:= 'State taxable Wages';
       parameter_record(1).p_parameter_value:=p_input_3;

       parameter_record(2).p_parameter_name:= 'SIT withheld';
       parameter_record(2).p_parameter_value:=p_input_4;

       /* Bug 3680056 New field */
       parameter_record(3).p_parameter_name:= 'Employer Contributions to Health Savings Account';
       parameter_record(3).p_parameter_value:=p_input_26;

       parameter_record(4).p_parameter_name:= 'Non-Taxable Combat Pay';
       parameter_record(4).p_parameter_value := p_input_27 ;

       l_records := 4 ;
--       l_records :=3;
--}
    ELSIF p_report_qualifier = 'RI' THEN
--{
       parameter_record(1).p_parameter_name:= 'Wages,Tips And Other Compensation';
       parameter_record(1).p_parameter_value:=p_input_3;

       parameter_record(2).p_parameter_name:= 'Federal Income Tax Withheld';
       parameter_record(2).p_parameter_value:=p_input_4;

       parameter_record(3).p_parameter_name:= 'State Taxable Wages';
       parameter_record(3).p_parameter_value:=p_input_5;

       parameter_record(4).p_parameter_name:= 'Medicare Wages And Tips';
       parameter_record(4).p_parameter_value:=p_input_6;

       parameter_record(5).p_parameter_name:= 'Medicare Tax Withheld';
       parameter_record(5).p_parameter_value:=p_input_7;

       parameter_record(6).p_parameter_name:= 'SIT withheld';
       parameter_record(6).p_parameter_value:=p_input_8;

       /* Bug 3680056 New field */
       parameter_record(7).p_parameter_name:= 'Employer Contributions to Health Savings Account';
       parameter_record(7).p_parameter_value:=p_input_26;

       parameter_record(8).p_parameter_name:= 'Non-Taxable Combat Pay';
       parameter_record(8).p_parameter_value := p_input_27 ;

       parameter_record(9).p_parameter_name:= 'Deferrals Under a Sec 409A Non-Qual Def Comp Plan';
       parameter_record(9).p_parameter_value := p_input_28 ;

       l_records := 9 ;

--       l_records :=7;
--}
    ELSIF p_report_qualifier = 'FL_SQWL' THEN
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

       l_records := 5 ;
       l_end_of_rec   := p_end_of_rec;
--}
    ELSIF p_report_qualifier = 'MO_KNSAS' THEN
--       Fix for Bug# 4502738
--{
       parameter_record(1).p_parameter_name:= 'Wages,Tips And Other Compensation';
       parameter_record(1).p_parameter_value:=p_input_3;

       parameter_record(2).p_parameter_name:= 'Medicare Wages And Tips';
       parameter_record(2).p_parameter_value:=p_input_7;

       parameter_record(3).p_parameter_name:= 'Medicare Tax Withheld';
       parameter_record(3).p_parameter_value:=p_input_8;

       l_records := 3 ;
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

       /* Bug 3680056 New field */
       parameter_record(20).p_parameter_name:= 'Employer Contributions to Health Savings Account';
       parameter_record(20).p_parameter_value:=p_input_26;

       parameter_record(21).p_parameter_name:= 'Non-Taxable Combat Pay';
       parameter_record(21).p_parameter_value := p_input_27 ;

       parameter_record(22).p_parameter_name:= 'Deferrals Under a Sec 409A Non-Qual Def Comp Plan';
       parameter_record(22).p_parameter_value := p_input_28 ;
       /* Bug 5256745 */

       parameter_record(23).p_parameter_name:= 'Roth Contributions Und Sec 401(k) Plan';
       parameter_record(23).p_parameter_value := p_input_31 ;

       parameter_record(24).p_parameter_name:= 'Roth Contributions Und Sec 403(b) Plan';
       parameter_record(24).p_parameter_value := p_input_32 ;

       l_records := 24 ;

    END IF;

    /* These Values validated specifically for PuertoRico */
    /* Bug 3680056 - Since New field is added as parameter 20, the foll. 3 parameters for PR
       have been shifted by one each. i.e from 20-22 to 21-23 */
    IF p_report_qualifier = 'PR' THEN

       parameter_record(21).p_parameter_name:= 'Cost of Pension Annuity';
       parameter_record(21).p_parameter_value:=p_input_23;

       parameter_record(22).p_parameter_name:= 'Contribution to Qual. Plans';
       parameter_record(22).p_parameter_value:=p_input_24;

       parameter_record(23).p_parameter_name:= 'Cost Reimbursement';
       parameter_record(23).p_parameter_value:=p_input_25;

       parameter_record(24).p_parameter_name:= 'Non-Taxable Combat Pay';
       parameter_record(24).p_parameter_value := p_input_27 ;

       parameter_record(25).p_parameter_name:= 'Deferrals Under a Sec 409A Non-Qual Def Comp Plan';
       parameter_record(25).p_parameter_value := p_input_28 ;

       parameter_record(26).p_parameter_name:= 'Uncollected SS Tax on Tips';
       parameter_record(26).p_parameter_value := p_input_29 ;

       parameter_record(27).p_parameter_name:= 'Uncollected Medicare Tax on Tips';
       parameter_record(27).p_parameter_value := p_input_30 ;

       l_records := 27 ;

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
       hr_utility.trace('p_exclude_from_output = '||p_exclude_from_output);
    END LOOP;

-- Validation Ends here
--
-- Formatting RT Record depending on report_qualifier
--
-- Formatting No of Employee Wage/State Record
    l_input_2:= lpad(substr(nvl(p_input_2,'0'),1,7),7,0);

    IF p_report_qualifier = 'MA' THEN
--{
       return_value := 'RT'||l_input_2
                           ||parameter_record(1).p_output_value
                           ||parameter_record(2).p_output_value
                           ||lpad(' ',45)
                     /*      ||parameter_record(3).p_output_value
                           ||parameter_record(4).p_output_value     -- Railroad, MA and Local Govt Reqtirement Contrib
                           ||parameter_record(5).p_output_value     -- Fed Wages (Box 1) */
                           ||lpad(' ',45)    /* 6720319 */
                           ||lpad(' ',383);                         -- 383 Spaces
--}
    ELSIF p_report_qualifier = 'CT' THEN
--{
    --
    -- space between wage and withhed removed to fix bug # 2640052
    --
       return_value := 'RT'||l_input_2
                           ||parameter_record(1).p_output_value
                    --     ||lpad(' ',1)
                           ||parameter_record(2).p_output_value
                           ||lpad(' ',473);

--}
    ELSIF p_report_qualifier = 'PA' THEN
--{
       return_value := 'RT'||lpad(' ',247) -- changed from 249
                           ||parameter_record(3).p_output_value  -- Bug 3680056 - New Field 250-264
			   --||lpad(' ',209)
			   ||lpad(' ',15)
			   ||rpad(parameter_record(4).p_output_value,196)
                           ||l_input_2
                           ||parameter_record(1).p_output_value
                           ||parameter_record(2).p_output_value;
	--}
    ELSIF p_report_qualifier = 'RI' THEN
--{
       hr_utility.trace('Within RI') ;
       return_value := 'RT'||l_input_2
                           ||parameter_record(1).p_output_value
                           ||parameter_record(2).p_output_value
                           ||parameter_record(3).p_output_value
                           ||lpad(' ',15)
                           ||parameter_record(4).p_output_value
                           ||parameter_record(5).p_output_value
                           ||parameter_record(6).p_output_value
			   ||lpad(' ',135)  /*  Bug 3680056 - New field from 250-264 */
			   ||rpad(parameter_record(7).p_output_value,30)
			   ||rpad(parameter_record(8).p_output_value,30)
			   ||lpad('0',45,'0')
			   ||rpad(parameter_record(9).p_output_value,158) ;
       hr_utility.trace('Exiting RI') ;
--}
    ELSIF p_report_qualifier = 'SC_SQWL' THEN /*2274381.*/
       return_value := 'RT'||l_input_2
                           ||lpad(' ',503);
    ELSIF p_report_qualifier = 'FL_SQWL' THEN
--{
       return_value := 'RT'||lpad(' ',7)
                           ||lpad(substr(nvl(parameter_record(1).p_output_value,'0'),1,15),15)
                           ||lpad(' ',456)
                           ||lpad(substr(nvl(parameter_record(2).p_output_value,'0'),1,11),11)
                           ||lpad(substr(nvl(parameter_record(3).p_output_value,'0'),1,7),7)
                           ||lpad(substr(nvl(parameter_record(4).p_output_value,'0'),1,7),7)
                           ||lpad(substr(nvl(parameter_record(5).p_output_value,'0'),1,7),7)
				           ||l_end_of_rec;
--}
    ELSIF p_report_qualifier = 'PA_PHILA' THEN /* Bug # 2680189 */
       return_value := 'RT'||lpad(' ',510);
    ELSIF p_report_qualifier = 'PR' THEN
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
                       /*  Bug 	5876054
                           ||parameter_record(10).p_output_value
                           ||parameter_record(11).p_output_value
                           ||parameter_record(12).p_output_value
                           ||parameter_record(13).p_output_value
                           ||parameter_record(14).p_output_value
                           ||lpad(' ',15)
                           ||rpad(parameter_record(15).p_output_value,15)
                       */
                           ||lpad('0',15,'0')
                           ||lpad('0',15,'0')
                           ||lpad('0',15,'0')
                           ||lpad('0',15,'0')
                           ||lpad('0',15,'0')
                           ||lpad('0',15,'0')
                           ||lpad('0',15,'0')
			   -- Bug 3680056 - New Field 250-264
			               ||parameter_record(20).p_output_value
                           ||parameter_record(16).p_output_value
                           ||rpad(parameter_record(24).p_output_value,30)
                           ||parameter_record(17).p_output_value
                           ||parameter_record(18).p_output_value
                           ||parameter_record(19).p_output_value
-- 	5876054                ||parameter_record(25).p_output_value /* Changed from here : Bug 4665713 */
                           ||lpad('0',15,'0')
                           ||lpad('0',30,'0')
			   ||lpad(' ',113) /* 6644795 - The Values have been Moved to the RV record */
            		/*	   ||lpad(' ',22)
                           ||parameter_record(21).p_output_value
                           ||parameter_record(22).p_output_value
                           ||parameter_record(23).p_output_value
                           ||lpad('0',15,'0')
			   ||parameter_record(26).p_output_value
			   ||parameter_record(27).p_output_value
			   ||lpad(' ',1) */;
--}
    ELSIF p_report_qualifier = 'MO_KNSAS' THEN
--{
--       Fix for Bug# 4502738
       return_value := 'RT'||l_input_2
                           ||parameter_record(1).p_output_value
                           ||rpad('0',45,'0' )
                           ||parameter_record(2).p_output_value
                           ||parameter_record(3).p_output_value
                           ||rpad('0',120,'0' )
                           ||rpad(' ',15,' ' )
                           ||rpad('0',60,'0' )
                           ||rpad(' ',15,' ' )
                           ||rpad('0',60,'0' )
                           ||rpad(' ',143,' ' );
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
                           ||lpad('0',15,'0') /* Bug 4859212 */
                           ||rpad(parameter_record(15).p_output_value,15)
			   ||rpad(parameter_record(20).p_output_value,15) -- Bug 3680056 Pos 250-264
                           --||rpad(parameter_record(16).p_output_value,45)
                           ||parameter_record(16).p_output_value
                           ||rpad(parameter_record(21).p_output_value,30)
                           ||parameter_record(17).p_output_value
                           ||parameter_record(18).p_output_value
                           --||rpad(parameter_record(19).p_output_value,173);
                           ||parameter_record(19).p_output_value
                           --||rpad(parameter_record(22).p_output_value,158)
                           /* Bug 5256745 */
                           ||parameter_record(22).p_output_value
                           ||parameter_record(23).p_output_value
                           ||rpad(parameter_record(24).p_output_value,128) ;

--}
    END IF;
    hr_utility.trace('B4 Calculating length') ;
    ret_str_len:=length(return_value);
--}
  ELSIF p_input_40 = 'CSV' THEN
--{
     /* for PuertoRico following condition added */
     IF p_report_qualifier = 'PR' THEN
     /* Bug 4665713 */
     l_rt_end_of_rec := ','||p_input_28
                           ||lpad(' ',52)||'|'||
                           'Cost of Pension Annuity '||p_input_23||'|'||
                           'Contrib to Qual. Plans ' ||p_input_24||'|'||
                           'Cost Reimbursement '     ||p_input_25||'|'||
			   'Salaries under Act No. 324 of 2004 ' ||'0'||'|'||
			   'Uncollected SS Tax on Tips '||p_input_29||'|'||
			   'Uncollected Medicare Tax on Tips '||p_input_30 ;

     ELSE
        l_rt_end_of_rec :=  ','||p_input_28
                            ||','||p_input_31
                            ||','||p_input_32
                            ||','||lpad(' ',113) ;
     END IF;

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
                         ||','||lpad('0',15,'0') /* Bug 4859212 */
                         ||','||p_input_18
                         ||','||p_input_26  -- Bug 3680056 ER Contrib to HSA
                         ||','||p_input_19
                         ||','||p_input_27
                         ||','||lpad(' ',15)
                         ||','||p_input_20
                         ||','||p_input_21
                         ||','||p_input_22
			 ||l_rt_end_of_rec;
--}
  END IF; -- p_input_40  (i.e. FLAT, CSV)
  p_error := l_exclude_from_output_chk;
  ret_str_len:=length(return_value);
  hr_utility.trace('Exiting RT') ;
  return return_value;
END format_W2_RT_record; -- End of Formatting RT record
--
-- Formatting RW record for W2 reporting
--
/*
   Record Identifier                                         --> p_input_1
   Number of RO Records                                      --> p_input_2
   Allocated Tips                                            --> p_input_3
   Uncollected Employee Tax on Tips                          --> p_input_4
   Medical Savings Account                                   --> p_input_5
   Simple Retirement Account                                 --> p_input_6
   Qualified Adoption Expenses                               --> p_input_7
   Uncollected Social Security Tax on GTL                    --> p_input_8
   Uncollected Medicare Tax On GTL                           --> p_input_9
   Wages Subject to Puerto Rico Tax                          --> p_input_10
   Commissions Subject to Puerto Rico Tax                    --> p_input_11
   Allowances Subject to Puerto Rico Tax                     --> p_input_12
   Tips Subject to Puerto Rico Tax                           --> p_input_13
   Total Wages, Commissions, Tips, And Allow Sub to PR Tax   --> p_input_14
   Puerto Rico Tax Withheld                                  --> p_input_15
   Retirement Fund Annual Contributions                      --> p_input_16
   Total Wages, Tips And Other Comp Sub to Virgin Islands,
    or Guam, or American Samoa, or Northern Mariana
    Islands Income Tax                                       --> p_input_17
   Virgin Islands, or Guam, Or American Samoa, or Northern
    Mariana Islands Income Tax Withheld                      --> p_input_18
    Income Under Section 409A on Non-Qualified Def Comp Plan --> p_input_20
    Employee Number                                          --> p_input_39
   Blank;
*/
FUNCTION format_W2_RU_record(
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
r_input_6 varchar2(100);

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
   hr_utility.trace('Formatting RU Record');
   hr_utility.trace('Format Mode  p_input_40 '||p_input_40);
   IF p_input_40='FLAT' THEN
--{
         IF p_report_qualifier = 'PR' THEN         -- Bug #  5668970
		r_input_6 := rpad('0',15,'0');
         END IF;

	 parameter_record(1).p_parameter_name:= ' Allocated Tips';
         parameter_record(1).p_parameter_value:=p_input_3;

         parameter_record(2).p_parameter_name:= 'Uncollected employee tax on tips';
         parameter_record(2).p_parameter_value:=p_input_4;

         parameter_record(3).p_parameter_name:= 'medical savings a/c';
         parameter_record(3).p_parameter_value:=p_input_5;

         parameter_record(4).p_parameter_name:= 'simple retirement a/c';
         parameter_record(4).p_parameter_value:=p_input_6;

         parameter_record(5).p_parameter_name:= 'qualified adoption expenses';
         parameter_record(5).p_parameter_value:=p_input_7;

         parameter_record(6).p_parameter_name:= 'Uncollected SS tax';
         parameter_record(6).p_parameter_value:=p_input_8;

         parameter_record(7).p_parameter_name:= 'Uncollected medicare tax';
         parameter_record(7).p_parameter_value:=p_input_9;

         parameter_record(8).p_parameter_name:= 'wages sub. to PR tax';
         parameter_record(8).p_parameter_value:=p_input_10;

         parameter_record(9).p_parameter_name:= 'Commissions sub.to PR tax';
         parameter_record(9).p_parameter_value:=p_input_11;

         parameter_record(10).p_parameter_name:= 'Allowances sub. to PR tax';
         parameter_record(10).p_parameter_value:=p_input_12;

         parameter_record(11).p_parameter_name:= 'Tips sub to PR tax';
         parameter_record(11).p_parameter_value:=p_input_13;

         parameter_record(12).p_parameter_name:= 'Total wages sub to PR tax';
         parameter_record(12).p_parameter_value:=p_input_14;

         parameter_record(13).p_parameter_name:= 'PR tax withheld';
         parameter_record(13).p_parameter_value:=p_input_15;

         parameter_record(14).p_parameter_name:= 'Retirement fund ann. contri';
         parameter_record(14).p_parameter_value:=p_input_16;

         parameter_record(15).p_parameter_name:= 'Total wages sub to VI,GU,AS and MP islands';
         parameter_record(15).p_parameter_value:=p_input_17;

         parameter_record(16).p_parameter_name:= 'VI,GU or MP Islands income tax wh';
         parameter_record(16).p_parameter_value:=p_input_18;

	 --Added New Field in Pos: 115 - 129

         parameter_record(17).p_parameter_name:= 'Income Und Sec 409A on Non-Qual Def Comp Plan';
         parameter_record(17).p_parameter_value := p_input_20;

--
-- Validation and Formatting for above fields done in this loop
         FOR i in 1..17
         LOOP
           parameter_record(i).p_output_value :=
              pay_us_reporting_utils_pkg.data_validation(
                                             p_effective_date,
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
           hr_utility.trace('p_exclude_from_output = '||p_exclude_from_output);
         END LOOP;
-- Formatting RU record for format mode FLAT
-- formatting Total no of record
         l_input_2 := lpad(substr(nvl(p_input_2,'0'),1,7),7,0);
-- Formatting RU record for W2 reporting
	 IF p_report_qualifier = 'PR' THEN
         return_value:='RU'||l_input_2
	                /* ||parameter_record(1).p_output_value */
		           ||rpad('0',15,'0') /* 6644795 */
                           ||parameter_record(2).p_output_value
                       /*    ||parameter_record(3).p_output_value
                           ||parameter_record(4).p_output_value
                           ||parameter_record(5).p_output_value
                           ||parameter_record(6).p_output_value
                           --||rpad(parameter_record(7).p_output_value,255)
                           ||parameter_record(7).p_output_value */
			   ||rpad('0',75,'0')/* 6644795  */
                           ||rpad(parameter_record(17).p_output_value,240)
                           ||parameter_record(8).p_output_value
                           ||parameter_record(9).p_output_value
                           ||parameter_record(10).p_output_value
                           ||parameter_record(11).p_output_value
                           ||parameter_record(12).p_output_value
                           ||parameter_record(13).p_output_value
                           ||parameter_record(14).p_output_value
                           ||parameter_record(15).p_output_value
                           ||rpad(parameter_record(16).p_output_value,38);
         ELSE
	  return_value:='RU'||l_input_2
                           ||parameter_record(1).p_output_value
                           ||parameter_record(2).p_output_value
                           ||parameter_record(3).p_output_value
                           ||parameter_record(4).p_output_value
                           ||parameter_record(5).p_output_value
                           ||parameter_record(6).p_output_value
                           --||rpad(parameter_record(7).p_output_value,255)
                           ||parameter_record(7).p_output_value
                           ||rpad(parameter_record(17).p_output_value,240)
                           ||parameter_record(8).p_output_value
                           ||parameter_record(9).p_output_value
                           ||parameter_record(10).p_output_value
                           ||parameter_record(11).p_output_value
                           ||parameter_record(12).p_output_value
                           ||parameter_record(13).p_output_value
                           ||parameter_record(14).p_output_value
                           ||parameter_record(15).p_output_value
                           ||rpad(parameter_record(16).p_output_value,38);
         END IF ;
         ret_str_len:=length(return_value);
--}
   ELSIF p_input_40 = 'CSV' THEN
-- Formatting RU record for W2 audit reports
         return_value:='RU'||','||l_input_2
                           ||','||p_input_3
                           ||','||p_input_4
                           ||','||p_input_5
                           ||','||p_input_6
                           ||','||p_input_7
                           ||','||p_input_8
                           ||','||p_input_9
                           ||','||p_input_20
                           ||','||lpad(' ',225)
                           ||','||p_input_10
                           ||','||p_input_11
                           ||','||p_input_12
                           ||','||p_input_13
                           ||','||p_input_14
                           ||','||p_input_15
                           ||','||p_input_16
                           ||','||p_input_17
                           ||','||p_input_18
                           ||','||lpad(' ',23);

   END IF; -- p_input_40
   ret_str_len:=length(return_value);
   p_error := l_exclude_from_output_chk;
   return return_value;
END format_W2_RU_record;  -- End of Formatting RU Record

-- Formatting RF record for W2 reporting
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
FUNCTION format_W2_RF_record(
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
l_exclude_from_output_chk  boolean;
l_total_records            varchar2(50);
l_wages                    varchar2(100);
l_taxes                    varchar2(100);
sp_out_1                   varchar2(100);
sp_out_2                   varchar2(100);
BEGIN
   hr_utility.trace('Formatting RF Record');
   hr_utility.trace('Format Mode  p_input_40 '||p_format_mode);
   hr_utility.trace('Report Qualifier before Formatting RF Record  '
                                              ||p_report_qualifier);
   IF ((p_report_qualifier = 'PA_PHILA') OR  -- Bug # 2680189
       (p_report_qualifier = 'CO')) THEN     -- Bug # 2813555
--{
      l_total_records := lpad(nvl(p_total_no_of_record,'0'),9,0);
      return_value := 'RF'
                      ||lpad(' ',5)
                      ||l_total_records
                      ||lpad(' ',496);
--}
   ELSIF p_report_qualifier IN  ('PA', 'CT') THEN

--{
-- Validating Total Wage for Negative Value
--
      l_wages :=
        pay_us_reporting_utils_pkg.data_validation(p_effective_date,
                                                   p_report_type,
                                                   p_format,
                                                   p_report_qualifier,
                                                   p_record_name,
                                                   'NEG_CHECK',
                                                   p_total_wages,
                                                   'State taxable Wages',
                                                   null,
                                                   null,
                                                   p_validate,
                                                   p_exclude_from_output,
                                                   sp_out_1,
                                                   sp_out_2);

      IF p_exclude_from_output = 'Y' THEN
         l_exclude_from_output_chk := TRUE;
      END IF;
-- Validating Total Tax for Negative Value
--
      l_taxes :=
        pay_us_reporting_utils_pkg.data_validation( p_effective_date,
                                                    p_report_type,
                                                    p_format,
                                                    p_report_qualifier,
                                                    p_record_name,
                                                    'NEG_CHECK',
                                                    p_total_taxes,
                                                    'SIT Withheld',
                                                    null,
                                                    null,
                                                    p_validate,
                                                    p_exclude_from_output,
                                                    sp_out_1,
                                                    sp_out_2);

      IF p_exclude_from_output = 'Y' THEN
         l_exclude_from_output_chk := TRUE;
      END IF;
-- Formatting RF Record for state PA
      IF p_report_qualifier = 'PA' THEN
--{
         l_total_records := lpad(substr(nvl(p_total_no_of_record,' '),1,7),7,0);
         return_value    := 'RF'||lpad(' ',473)
                                ||l_total_records
                                ||l_wages
                                ||l_taxes;
--}
-- Formatting RF Record for state CT
      ELSIF p_report_qualifier = 'CT' THEN
--{
         --
         -- This is to fix bug # 2640074
         -- column positions of State Wages/Withheld changed
         -- return_value := 'RF'||rpad(l_total_records,10)||rpad(l_wages,17)
         --                     ||rpad(l_taxes,483);
         --
         l_total_records := lpad(substr(nvl(p_total_no_of_record,' '),1,9),9,0);
         return_value    := 'RF'||rpad(l_total_records,9)
                                ||rpad(l_wages,16)
                                ||rpad(l_taxes,483);
--}
      END IF;
--}
   ELSE

         return_value:= 'RF'
                        ||lpad(lpad(substr(nvl(p_total_no_of_record,' '),1,9)
                                    ,9,0),14)
                        ||rpad(' ',496);

   END IF;
   p_error := l_exclude_from_output_chk;
   ret_str_len:=length(return_value);
   return return_value;
END format_W2_RF_record; -- End of Formatting RF Record for W2 Reporting

END pay_us_mmrf_w2_format_record; -- End of Package Body

/
