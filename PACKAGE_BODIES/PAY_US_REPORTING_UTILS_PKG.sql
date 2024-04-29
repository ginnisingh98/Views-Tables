--------------------------------------------------------
--  DDL for Package Body PAY_US_REPORTING_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_REPORTING_UTILS_PKG" AS
/* $Header: pyusmref.pkb 120.10.12010000.3 2010/03/23 13:44:20 emunisek ship $  */

 /*===========================================================================+
 |               Copyright (c) 2001 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
    pay_us_reporting_utils_pkg

  Purpose
    The purpose of this package is to support the generation of magnetic tape W2
    reports for US legilsative requirements incorporating magtape resilience
    and the new end-of-year design. New Functions will support the Year end
    reporting in MMREF format initially and will be extended to have more
    format.

  Notes

  Parameters: The following 7 parameters are used in all the functions.

               p_effective_date -
                           This parameter indicates the year for the function.
               p_item_name -
                           This parameter indicates the name of the item
                           to be calculated.
                           'EE_ADDRESS' - Employee address
                           'ER_ADDRESS' - Employer Address
               p_report_type -
                           This parameter will have the type of the report.
                           eg: 'W2'
               p_format -
                          This parameter will have the format to be printed
                          on W2. eg:'MMREF'
               p_record_name -
                          This parameter will have the particular
                               record name. eg: RA,RF,RE,RT,RSSUMM etc.
               p_validate -
                           This parameter will check whether it wants to
                            validate the error condition or override the checking.
                            'N'- Override
                            'Y'- Check
               p_exclude_from_output -
                           This out parameter gives the information on
                           whether the record has to be printed or not.
                           'Y'- Do not print.
                           'N'- Print.


  Change List
  -----------
  Date        Name     Vers   Bug No  Description
  ----------- -------- ------ ------- --------------------------
  24-JUL-2001 fusman   40.0           created
  06-Sep-2001 fusman   40.1           Made changes to the function get_item_data.
  08-spe-2001 djoshi   40.2           Program modified by Mehul and Fouzia
                                      for Value exceed allowable lenth in
                                      RO and RU reocrd. Arcs done by dipen in
                                      their absence.
  10-Sep-2001 fusman   40.3           changed the output to upper case.
  18-Sep-2001 fusman   40.4           Changed the message PAY_INVALID_ER_DATA and
                                      the tokens.
  19-Sep-2001 fusman   40.5           Changed the to_number conversion of the
                                      p_tax_unit_id.
  19-Sep-2001 fusman   40.6           Changed the date format.
  20-Sep-2001 fusman   40.7           Added an exit statement for too many rows.
  21-Sep-2001 fusman   40.8           Changed the cursor get_ss_limit to fetch as
                                      dollar and cents.
  28-Sep-2001 fusman   40.9           Removed commas from the names, checked
                                      the terminated business indicator,
                                      padded with blanks for spouse's social
                                      security number in RO record.
  02-Nov-2001 fusman   40.10          Added two new functions and created RS rec
  03-Nov-2001 fusman   40.11          Added two dbi item to Get_territory_values
                                      Added extra checking to SSN.
  05-Nov-2001 fusman   40.12          Added a blank space if value not found for
                                      dbis - A_CON_NATIONAL_IDENTIFIER and
                                           - A_PER_MARITAL_STATUS
  05-Nov-2001 fusman   40.13          Avoided NEG_CHECK for
                                           - A_CON_NATIONAL_IDENTIFIER and
                                           - A_PER_MARITAL_STATUS.
  13-Nov-2001 fusman   40.14   2102205 Alabama Location address should be null
                                       in RE record.
                               2105936 Suffix mismatch.
                               2109184
                               2108966 Incorrect State code in RS.
  15-Nov-2001          40.15           Added a blank call for RS record.Spaces
                                       has been removed from EIN.
  16-Nov-2001          40.16   2110762 Removed hyphens and spaces on State
                                       control number and state id number.
  19-Nov-2001          40.17   2109279
                               2114444 RF incorrect for PA and CT.
  20-nov-2001          40.18           Date for. changed for get_employer_address
  20-nov-2001          40.19   2116807 RE rec for IN pos 221.
  26-Nov-2001          115.10          Added dbdrv command.
  27-Nov-2001          115.11  2124630 RE record for NC .
  03-Dec-2001          115.12  2128995 County code not shown for IN in RS.
  04-Dec-2001          115.13  2133985 Foreign State/province in foreign address.
  05-Dec-2001          115.14  2132773 Agent EIN for PA,NC, AL,CT.
  10-Dec-2001          115.16  2128533 Added checkfile stmt.
  11-Dec-2001          115.17  2145032 CT resub indicator is not blanked.
  20-Dec-2001          115.18  2159881 / removed in EIN.
                               2150138 Period,comma not removed in the names.
                               2157065 Non-global locations are not fetched.
  21-Dec-2001          115.19          Modified checkfile to meet GSCC Standards.
  21-Dec-2001          115.20  2146475 Marital status value for PR emp.
  21-Dec-2001          115.21          Removed - from SSN.
  02-Jan-2002          115.22  2159881 / removed in state emp a/c number.
  03-Jan-2002          115.23          Removed / and - in RE record for PA emp num.
  23-Jan-2002          115.24          Added format changes for OH RITA.
  24-Jan-2002          115.25          Removed RA preparer code default value for
                                       OH RITA.
  24-Jan-2002          115.26          Removed the zero fill for the state code in
                                       RS record for OH RITA.
  24-Jan-2002          115.27          Changed the city to upper case.
  04-Mar-2002          115.28          Added SQWL changes to RA,RE and RS records.
  13-Mar-2002          115.29  2259849 Bug 2259849 and fix for SC,AZ,MN SQWL
                                       on formatting issues replacing blanks
                                       for zeroes and viceversa.
  14-Mar-2002          115.32          Changed for UTF8-
  14-Mar-2002          115.33          Fix for state code in RS record.
  20-Mar-2002          115.34  2274381 RT record.
  22-MAR-2002          115.36          Added count to SC_SQWL
  25-MAR-2002 djoshi   115.37  2281801
  25-MAR-2002 djoshi   115.38          Fix the SUI Account No for SC,MD,MO
  05-MAY-2002 djoshi   115.39  2351936 Fix for SUI Account No. for OR.
  16-MAY-2002 fusman   115.40          Fix for SUI Account No on all SQWL states and
                                       for bug 2337613,2334393,2324869,2309772,2286329.
  17-MAY-2002 fusman   115.41          Fixed LA_SQWL headers and passed SSN as output to print
                                       in a03 file.
  23-MAY-2002 fusman   115.42          EIN is not checked for SQWL.
  24-MAY-2002 fusman   115.43          p_input_2 is send for GA_SQWL for position 18.
  10-aug-2002 ppanda   115.45  2173795 For Puerto Rico Tax Jurisdiction Civil Status
                                       value would be either M or S
                               2183859 MMREF-1 doesn't currently Pick up employees
                                       with SSN beginning W/9
                                       Validation for SSN modified to log a
                                       warning for SSN beginning with 9
                                       A warning is also logged for person having
                                       no or blank SSN For above two cases person
                                       record appears in .a03 and .mf file
                               2503639 JD context removed from Puerto Rico Balance

                               2198547 Pos:119-140. Delivery Address shoul not be
                                       blanked out for NC. This is to revert the chenges
                                       made to fix the bug 2124630.
  11-Jun-2002 fusman   115.46  2409031 Removed '-' from EIN for LA_SQWL.
  13-Jun-2002 fusman   115.47          Hyphens in EIN is removed first and then
                                       9 digits is taken.

  14-AUG-2002 sodhingr 115.48          Changed the format_record function to support
                                       MMREF format for CA
  22-AUG-2002 rpinjala 115.49          Changed the print_record_header for CA RTM report
                                       and p_input_1 has a value of RTM passed from the
                                       MMRF_SUBMITTER_DUMMY_SQWL
  05-SEP-2002 sodhingr 115.50  2550189 Changed the formating for RST record to fill with
                                       zero when null and right justify and zero fill for
                                       all the numeric values.
  29-SEP-2002 ahanda   115.55          Changed Get_Territory_Values to call JD specific
                                       archive value for JD specific DBIs
  23-OCT-2002 ppanda   115.56  2510920 Column heading which used to be 'Resub TLCN' now
                                         its going to be 'Resub WFID'
                               2640074 For state of CT RF record changed
                                        State Taxable Wages using position 12-27 instead of 13-28
                                        SIT Withheld using the position 28-43 instead of 30-43
                               2627606 For state of MO, OH and PA column position 203-226
                                       is now filled with zeros
                               2644092 For state of KS  column position 3-4 State code
                                       and 274-275 State code are now blank filled
                               2640052 For state of CT, on RT record SIT w/h used to be in
                                       positions 26-40.Now it is in 25-39. On RT Pos 40-512
                                       will be blank
                               2297587 On RW record pos 342-352 is blank filled and  associated
                                       validation is commented out
                                       On RT record pos 220-334 is blank filled and associated
                                       validation is commented out
                               2645739 On RW record local variables were formatted and used
                                       for Flat record instead of input parameters
  03-NOV-2002		       2622709 Changed the 'RST' record for CA, to report no.of employees
					 from Pos 4-10
  04-NOV-2002 ppanda   115.59  2297587 Column heading also to be blanked out
                                       along with the values
  10-NOV-2002 sodhingr  115.60         Changed get_item_data and format_record procedure for NY MMREF
  11-NOV-2002 ppanda   115.61  2180659 Philadelphia, PA locality changes made as per MMREF specs
                               2182946 St. Louis, MO locality changes made as per MMREF specs
                               2420001 Daton, OH locality changes made as per MMREF Specs
  14-NOV-2002 sodhingr 115.62  Changed format_record function for NY SQWL to print SIT wages
			       and tax withheld
  15-NOV-2002 ppanda   115.63  2668099 On RS record pos 203-226 filled with zeros
                               2668250 On RS record for Arkansa pos 309-330 filled with blank
  19-NOV-2002 ppanda   115.66  2673502 trace_on command commented
                                       A change made for RO record when type is BLANK
                                       RO Balnk record was shifting the RS record by one column right
                                       because of an unwanted coma
  20-NOV-2002 sodhingr 115.67          Changed format_record function for NY MMREF  to use
				       p_input_23 instead of local variable r_input_23
				       which was printing blank for Quarter on
				       RE record pos 174-178.
				       Changed the function get_file_name to allow only numbers and
				       characters in the magnetic and report file name
  24-NOV-2002 ppanda   115.68  2680070 On RA record for St Louis pos 95-512 is blank filled
                                       On RS record Pos 341-351 filled with zeros
                               2680189 On RA record Pos 12-217 and 499-500 filled with Blank
                                       On RO record Pos 275-351 and 363-384 filled with zeros
                                       On RT record Pos 3-512 filled with blank
                                       On RF record pos 8-16 filled with number of RW records and
                                             pos 17-512 filled with blank
                               2682414 On RS record positions 338-349 right justified with wages and filled with zeros
                                                    positions 413-424 right justified with withheld and filled with zeros
                               2682446 On RS local record Tax Entity code is null filled which was causing wraping problem
                                       for MF file.
  02-Dec-2002 ppanda    115.70         Nocopy hint added to OUT and IN OUT parameters
  06-Dec-2002 ppanda    115.71 2682428 On RA record posistion 499 is hard coded with 3 for Dayton Local mag
  20-Jan-2003 ppanda    115.72 2742008 For Massachussets RS and RT record formatted for 2 new fields
                               2736928 For PuertoRico RA, RE, RO, RS and RT record formatted as new requirement
  23-Jan-2003 ppanda    115.76 2767254 On RS record position 342-352, 364-374 and 386-407 filled with zeros
                                       instead of blanks
  11-Feb-2003 fusman    115.77 2789523 MN wants "X" in position 512 of rs record.
  10-FEB-2003 sodhingr  115.77 2778338, 2788155 changed format_record and data_validation for FL_SQWL and VA_SQWL
  14-FEB-2003 sodhingr  115.78 2802928 changed the format_record to print Agent id number for FL_SQWL
  23-feb-2003 djoshi    115.79 djoshi  Added the RITA CCA split
  04-mar-2003 fusman    115.80 2426228 Changed the formats of phone numbers to match the doc.
  10-MAR-2003 sodhingr  115.81         Changed the procedure data_validation to remove the formating for
 					Total tax due on FL's RT record.
  19-MAR-2003 sodhingr  115.82 2856632  modified format_record funtion for 'RS' record Pos 5-9 , which is blank
                                        for FL as apps doesn't support Unit code
                                        Also, change the Agent Id number for 'FL' on 'RA' rec to print 8 chars
                                        instead of 7 chars and changed 'RT' record to print 11 chars for tax
                                        due.
					modified data_validation procedure to restrict the length of tax due
				        to 11 chars instead of 10 chars
 19-MAR-2003 sodhingr   115.83  2859806 Added company name for VA SQWL, RA rec pos38-94
 21-MAR-2003 sodhingr   115.86  2856632 FL Unit code shouldn't be blank, we do support Unit code in apps.
 08-APR-2003 sodhingr   115.87  2892148, 2892354 changed the function format_record to add CR/LF for FL SQWL
					and for AZ SQWL added blanks instead of zeros from pos 274-337
 15-APR-2003 fusman     115.88  2901849 NH SQWL State Account number is changed to be right
                                        justified with leading zeros.
 01-JUN-2003 fusman     115.89  2349576 NC SQWL MMREF Changes.
                                2787646 WA SQWL New format Changes.
                                2796947 NH's required field changes.
 06-JUN-2003 fusman     115.90          NC SQWL delivery address blanked out.
 18-JUN-2003 fusman     115.91  3011801 MN hours worked right justified and zero filled.
 15-AUG-2003 ppanda     115.92          This package redesined for modularising complex functions
                                        Modification resultted into few packages
 07-Nov-2003 ppanda             2587381 Get_File_Name function changed to support Federal W-2c Magnetic Media
 07-Nov-2003 fusman     115.95  3233249 Added balance feed check for performance issue.
 07-Nov-2003 ppanda             2587381 W-2c report type added
 01-MAR-2004 JGoswami   115.98  3334497 Modified data_validation added AK_SQWL check.
                                        Added support to CUSTOM report format for AK_SQWL
 28-AUG-2004 JGoswami   115.99  3830050 Modified data_validation added RSSUMM check for NV SQWL.
 10-NOV-2004 meshah     115.100         added function get_ff_archive_value
 15-NOV-2004 djoshi     115.101         changed l_jurisdiciton_code to varchar2(11) in
                                        function get_ff_archive_value
 07-Nov-2005 sudedas    115.102 4391218 Updated Format_Record function , updated with 2 new input params ,
                                        pay_us_mmrf_w2_format_record.format_W2_RW_record
 17-Feb-2006 sudedas    115.103 4425800 Added Functions Get_Employee_Count and Get_Total_Wages
 30-May-2006 sackumar 115.104 5089997 Added Functions Get_Employee_Count_Monthwise and Get_Wages.
 14-Jun-2006 sackumar  115.105 5089997 Modified get_wages to get the workers comp values..
 17-Aug-2006 sudedas   115.106 5256745  Updated Format_Record Function with 2 Optional Input
                                        Parameters p_input_43 and p_input_44 and
                                        Updated pay_us_mmrf_w2_format_record.format_W2_RW_record.
 22-Nov-2006 sudedas   115.107 5640748  Enhanced Get_Total_Wages Function.
 01-Dec-2006 sudedas   115.108          Changed Cursors cur_employee_count and cur_summed_balance
                                        in Function Get_Total_Wages (Added Jurisdiction Check)
 25-Jun-2007 sjawid    115.109 5621099  Added function GET_SUI_WAGES.
 07-Dec-2007 vmkulkar  115.110 6644795  Added call to format_W2_RV_record
			       6648007  get_item_data can now handle 'CS_PERSON' used
					for capturing contact persons title.
18-Feb-2008  sjawid    115.111 6677736  Modified function GET_SUI_WAGES to ignore
                                        -ve Wages employees for Florida SQWL xml format.
 23-Mar-2010 emunisek  115.113 9356178  Modified GET_SUI_WAGES function to adjust
                                        the Florida Taxable Wages as per the new filing
					requirement.
 ============================================================================*/
 -- Global Variable

    g_number	NUMBER;
    l_return    varchar2(100);
    end_date    date := to_date('31/12/4712','DD/MM/YYYY');

 -- Used by Magnetic W2 (MMREF  format).
/* ============================================================================ */
/* Function Name : calculate_balance
   Purpose       : Purpose of this function is is to provide calculation
                   of Derived balnces that are used in the formula
   Error checking

   Special Note  :
*/

FUNCTION calculate_balance(
                   p_effective_date         IN varchar2,
                   p_balance_name           IN varchar2,
                   p_report_type            IN varchar2,
                   p_format                 IN varchar2,
                   p_report_qualifier       IN varchar2,
                   p_record_name            IN varchar2,
                   p_input_1                IN varchar2,
                   p_input_2                IN varchar2,
                   p_input_3                IN varchar2,
                   p_input_4                IN varchar2,
                   p_input_5                IN varchar2,
                   p_input_6                IN varchar2,
                   p_input_7                IN varchar2,
                   p_input_8                IN varchar2,
                   p_input_9                IN varchar2,
                   p_input_10               IN varchar2,
                   p_input_11               IN varchar2,
                   p_input_12               IN varchar2,
                   p_input_13               IN varchar2,
                   p_input_14               IN varchar2,
                   p_input_15               IN varchar2,
                   p_validate               IN  varchar2,
                   p_exclude_from_output    out nocopy varchar2,
                   sp_out_1                 out nocopy varchar2,
                   sp_out_2                 out nocopy varchar2,
                   sp_out_3                 out nocopy varchar2,
                   sp_out_4                 out nocopy varchar2,
                   sp_out_5                 out nocopy varchar2
                    ) RETURN number  IS
/* LOCAL Varialbe Declaration */

l_calculated_value number ;
  Begin
    null;
     return 0;

End calculate_balance;

/* Function Name : calculate_wages
   Purpose       : Purpose of this function is is to provide calcula
tion
                   of wages that are used in the formula
   Error checking

   Special Note  :

*/

FUNCTION calculate_wages(
                   p_effective_date         IN varchar2,
                   p_wage_name              IN varchar2,
                   p_report_type            IN varchar2,
                   p_format                 IN varchar2,
                   p_report_qualifier       IN varchar2,
                   p_record_name            IN varchar2,
                   p_input_1                IN varchar2,
                   p_gross                  IN varchar2,
                   p_subject                IN varchar2,
                   p_subject_nw             IN varchar2,
                   p_pretax_redns           IN varchar2,
                   p_taxable                IN varchar2,
                   p_validate               IN  varchar2,
                   p_exclude_from_output    out nocopy varchar2,
                   sp_exempt                out nocopy varchar2,
                   sp_reduced_sub           out nocopy varchar2,
                   sp_excess                out nocopy varchar2,
                   sp_reduced_sub_wh        out nocopy varchar2,
                   sp_out_1                 out nocopy varchar2
                    )
RETURN number    IS

return_wage number(10):=100;
l_error boolean;
l_message varchar2(300);
l_description varchar2(50);

BEGIN

null;

RETURN '0';

END;





/*   --------------------------------------------------------------
    Name       :   get_item_data

    Purpose    : Purpose of this function is  to get live
                 data from the System.This can be replace
                 Call to live database items where error
                 checking is required.

   Parameters :
               p_effective_date -
                           This parameter indicates the year for the function.
               p_item_name -
                           This parameter indicates the name of the item
                           to be calculated.
                           'EE_ADDRESS' - Employee address
                           'ER_ADDRESS' - Employer Address
                           'CR_ADDRESS' - Company's Address
                           'CR_PERSON'  -Contact Persons details in the Submitter record.
			   'CS_PERSON' - Contact person details title. -vmkulkar
               p_report_type -
                           This parameter will have the type of the report.
                           eg: 'W2'
               p_format -
                          This parameter will have the format to be printed
                          on W2. eg:'MMREF'
               p_record_name -
                          This parameter will have the particular
                               record name. eg: RA,RF,RE,RT,RSSUMM etc.
               p_validate -
                           This parameter will check whether it wants to
                            validate the error condition or override the checking.
                            'N'- Override
                            'Y'- Check
               p_exclude_from_output -
                           This parameter gives the information on
                           whether the record has to be printed or not.
                           'Y'- Do not print.
                           'N'- Print.
              sp_out_1 -
                            This out parameter returns Location address.
              sp_out_2 -
                            This out parameter returns  Delivery address.
              sp_out_3 -
                            This out parameter returns Town_or_city.
              sp_out_4 -
                            This out parameter returns State abbreviation.
              sp_out_5 -
                            This out parameter returns Postal_code.
              sp_out_6 -
                            This out parameter returns zip code extension.
              sp_out_7 -
                            This out parameter returns foreign state/province.
              sp_out_8 -
                            This out parameter returns foreign postal_code.
              sp_out_9 -
                            This out parameter returns Country_code.
              sp_out_10 -
                            This parameter is returns the organization name or employee number.



   Error checking

   Special Note  :


    ----------------------------------------------------------------   */

FUNCTION get_item_data(
                   p_assignment_id            number,      --context
                   p_date_earned              date,    --context
                   p_tax_unit_id              number,      --context
                   p_effective_date       IN  varchar2,
                   p_item_name            IN  varchar2,
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
                   p_exclude_from_output  OUT nocopy varchar2,
                   sp_out_1               OUT nocopy varchar2,
                   sp_out_2               OUT nocopy varchar2,
                   sp_out_3               OUT nocopy varchar2,
                   sp_out_4               OUT nocopy varchar2,
                   sp_out_5               OUT nocopy varchar2,
                   sp_out_6               OUT nocopy varchar2,
                   sp_out_7               OUT nocopy varchar2,
                   sp_out_8               OUT nocopy varchar2,
                   sp_out_9               OUT nocopy varchar2,
                   sp_out_10              OUT nocopy varchar2
                    ) RETURN VARCHAR2  IS
-- Declaration of Local Variables
--
l_input_1       varchar2(50);
l_valid_address  boolean;
c_item_name     varchar2(40);
c_tax_unit_id   hr_all_organization_units.organization_id%TYPE;

BEGIN
   hr_utility.trace('Start of GET_ITEM_DATA ');
   hr_utility.trace('Parameter Input Values ...');
   hr_utility.trace('Ccontext value p_assignemnt_id  = '
                          || to_char(p_assignment_id));
   hr_utility.trace('               p_date_earned    = '
                          ||p_date_earned);
   hr_utility.trace('               p_tax_unit_id is = '
                          || to_char(p_tax_unit_id));
   hr_utility.trace('p_effective_date is   : '|| p_effective_date);
   hr_utility.trace('p_item_name is        : '|| p_item_name);
   hr_utility.trace('p_report_type is      : '|| p_report_type);
   hr_utility.trace('p_format is           : '|| p_format);
   hr_utility.trace('p_report_qualifier is : '|| p_report_qualifier   );
   hr_utility.trace('p_record_name  is     : '|| p_record_name   );
   hr_utility.trace('p_input_1 is          : '|| p_input_1   );
   hr_utility.trace('p_input_2 is          : '|| p_input_2   );
   hr_utility.trace('p_input_3 is          : '|| p_input_3   );
   hr_utility.trace('p_input_4 is          : '|| p_input_4   );
   hr_utility.trace('p_input_5 is          : '|| p_input_5   );
   hr_utility.trace('p_validate is         : '|| p_validate   );

-- p_item_name parameter is checked to decide which
--   procedure to call for Address or contact info
--
   IF p_item_name = 'CR_ADDRESS' THEN --p_item_name
      l_input_1:=replace(p_input_1,' ');
      IF l_input_1 IS NULL THEN
         hr_utility.trace('p_input_1 is null');
         c_item_name := NULL;
         l_valid_address := FALSE;
      ELSE -- l_input_1 IS NOT NULL THEN
         hr_utility.trace('p_input_1 is not null');
         c_tax_unit_id := to_number(p_input_1);
         c_item_name := 'ER_ADDRESS';
      END IF;
   ELSIF p_item_name = 'ER_ADDRESS' THEN
      hr_utility.trace(p_item_name);
      c_tax_unit_id := p_tax_unit_id;
      c_item_name := 'ER_ADDRESS';
      hr_utility.trace('c_tax_unit_id = '||to_char(c_tax_unit_id));
   ELSIF p_item_name = 'EE_ADDRESS' THEN
      c_item_name:='EE_ADDRESS';
   ELSIF p_item_name = 'CR_PERSON' THEN
      c_item_name:='CR_PERSON';
      l_valid_address:=FALSE;
   ELSIF p_item_name = 'CS_PERSON' THEN
      c_item_name:='CS_PERSON';
      l_valid_address:=FALSE;
   END IF; --p_item_name

   IF c_item_name = 'CR_PERSON' THEN --c_item_name
--
-- Following function is called to fetch Contact Person info
--
      hr_utility.trace('Calling get_cr_person_info');
      sp_out_1 := pay_us_get_item_data_pkg.get_contact_person_info(
                                     p_assignment_id,
                                     p_date_earned,
                                     p_tax_unit_id,
                                     p_effective_date,
                                     c_item_name,
                                     p_report_type,
                                     p_format,
                                     p_report_qualifier,
                                     p_record_name,
                                     p_input_1,
                                     p_validate,
                                     p_exclude_from_output,
                                     sp_out_1,
                                     sp_out_2,
                                     sp_out_3,
                                     sp_out_4,
                                     sp_out_5,
                                     sp_out_6,
                                     sp_out_7,
                                     sp_out_8
                                    );

   ELSIF c_item_name = 'CS_PERSON' THEN
-- vmkulkar
-- Following function is called to fetch Contact Person Title
--
--	vmkulkar - Contact person Title should we displayed in the MD RV Record.
--	So using p_contact_prsn_email(out4) for passing TITLE back to the formula.
--	ITEM NAME used is 'CS_PERSON'

      sp_out_1 := pay_us_get_item_data_pkg.get_contact_person_info(
                                     p_assignment_id,
                                     p_date_earned,
                                     p_tax_unit_id,
                                     p_effective_date,
                                     c_item_name,
                                     p_report_type,
                                     p_format,
                                     p_report_qualifier,
                                     p_record_name,
                                     p_input_1,
                                     p_validate,
                                     p_exclude_from_output,
                                     sp_out_1,
                                     sp_out_2,
                                     sp_out_3,
                                     sp_out_4,
                                     sp_out_5,
                                     sp_out_6,
                                     sp_out_7,
                                     sp_out_8
                                    );

   ELSIF c_item_name = 'EE_ADDRESS' THEN
--
-- Following function is called to fetch Employee Address
--
      hr_utility.trace('EE_ADDRESS Calling get_mmref_employee_address');
      sp_out_1 := pay_us_get_item_data_pkg.get_mmref_employee_address(
                                  p_assignment_id,
                                  p_date_earned,
                                  p_tax_unit_id,
                                  p_effective_date,
                                  p_item_name,
                                  p_report_type,
                                  p_format,
                                  p_report_qualifier,
                                  p_record_name,
                                  p_input_1,
                                  p_input_2,
                                  p_input_3,
                                  p_input_4,
                                  p_input_5,
                                  p_validate,
                                  p_exclude_from_output,
                                  sp_out_1,
                                  sp_out_2,
                                  sp_out_3,
                                  sp_out_4,
                                  sp_out_5,
                                  sp_out_6,
                                  sp_out_7,
                                  sp_out_8,
                                  sp_out_9,
                                  sp_out_10
                                 );
      hr_utility.trace('EE_ADDRESS get_mmref_employee_address completed sucessfully');
   ELSIF  c_item_name = 'ER_ADDRESS' THEN
--
-- Following function is called to fetch Employer Address
--
      hr_utility.trace('ER_ADDRESS Calling get_mmref_employer_address');
      sp_out_1 := pay_us_get_item_data_pkg.get_mmref_employer_address(
                                  p_assignment_id,
                                  p_date_earned,
                                  p_tax_unit_id,
                                  p_effective_date,
                                  p_item_name,
                                  p_report_type,
                                  p_format,
                                  p_report_qualifier,
                                  p_record_name,
                                  p_input_1,
                                  p_input_2,
                                  p_input_3,
                                  p_input_4,
                                  p_input_5,
                                  p_validate,
                                  p_exclude_from_output,
                                  sp_out_1,
                                  sp_out_2,
                                  sp_out_3,
                                  sp_out_4,
                                  sp_out_5,
                                  sp_out_6,
                                  sp_out_7,
                                  sp_out_8,
                                  sp_out_9,
                                  sp_out_10
                                 );
      hr_utility.trace('ER_ADDRESS get_mmref_employer_address completed sucessfully');
   END IF; --c_item_name

   IF p_exclude_from_output IS NULL THEN
      p_exclude_from_output := 'N';
   END IF;
--
-- Following checks are made to eliminate unwanted chanracters
-- from the output values

   sp_out_1 := Character_check(sp_out_1);
   sp_out_2 := Character_check(sp_out_2);
   sp_out_3 := Character_check(sp_out_3);
   sp_out_5 := Character_check(sp_out_5);
   sp_out_6 := Character_check(sp_out_6);
   sp_out_7 := Character_check(sp_out_7);
   sp_out_8 := Character_check(sp_out_8);
   sp_out_9 := Character_check(sp_out_9);
   /* Email address should not under go Character checking.*/
   IF p_item_name <> 'CR_PERSON' THEN
      sp_out_4 := Character_check(sp_out_4);
   END IF;

   hr_utility.trace('Return Values of Get_Item_Data ..');
   hr_utility.trace('Value of sp_out_1 = '||sp_out_1);
   hr_utility.trace('Value of sp_out_2 = '||sp_out_2);
   hr_utility.trace('Value of sp_out_3 = '||sp_out_3);
   hr_utility.trace('Value of sp_out_4 = '||sp_out_4);
   hr_utility.trace('Value of sp_out_5 = '||sp_out_5);
   hr_utility.trace('Value of sp_out_6 = '||sp_out_6);
   hr_utility.trace('Value of sp_out_7 = '||sp_out_7);
   hr_utility.trace('Value of sp_out_8 = '||sp_out_8);
   hr_utility.trace('Value of sp_out_9 = '||sp_out_9);
   hr_utility.trace('Value of sp_out_10 = '||sp_out_10);

   hr_utility.trace('Befor the final return. Length of the fields. ');
   hr_utility.trace('length of sp_out_1 = '||to_char(length(sp_out_1)));
   hr_utility.trace('length of sp_out_2 = '||to_char(length(sp_out_2)));
   hr_utility.trace('length of sp_out_3 = '||to_char(length(sp_out_3)));
   hr_utility.trace('length of sp_out_4 = '||to_char(length(sp_out_4)));
   hr_utility.trace('length of sp_out_5 = '||to_char(length(sp_out_5)));
   hr_utility.trace('length of sp_out_6 = '||to_char(length(sp_out_6)));
   hr_utility.trace('length of sp_out_7 = '||to_char(length(sp_out_7)));
   hr_utility.trace('length of sp_out_8 = '||to_char(length(sp_out_8)));
   hr_utility.trace('length of sp_out_9 = '||to_char(length(sp_out_9)));
   hr_utility.trace('length of sp_out_10 = '||to_char(length(sp_out_10)));

   RETURN sp_out_1;
END; -- End of function GET_ITEM_DATA


/* -------------------------------------------------------------
   Function Name : print_record_header
   Purpose       : Function will return the String for header
                   or title line for the Table or table heading
                   related to record for printing in audit files

   Error checking

   Special Note  :

  -------------------------------------------------------------- */

FUNCTION print_record_header(
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
                   p_validate             IN  varchar2,
                   p_exclude_from_output  OUT nocopy varchar2,
                   sp_out_1               OUT nocopy varchar2,
                   sp_out_2               OUT nocopy varchar2,
                   sp_out_3               OUT nocopy varchar2,
                   sp_out_4               OUT nocopy varchar2,
                   sp_out_5               OUT nocopy varchar2,
                   sp_out_6               OUT nocopy varchar2,
                   sp_out_7               OUT nocopy varchar2,
                   sp_out_8               OUT nocopy varchar2,
                   sp_out_9               OUT nocopy varchar2,
                   sp_out_10              OUT nocopy varchar2
                 )  RETURN VARCHAR2
IS

  header_string        varchar2(3000);
  return_header_string varchar2(2000);

  l_header_2      varchar2(900);
  l_header_3      varchar2(900);
  l_header_4      varchar2(900);
  l_header_5      varchar2(900);
  l_header_8      varchar2(900);
  l_header_9      varchar2(900);

  l_header_20     varchar2(900);
  l_header_21     varchar2(900);
  l_report_format varchar2(15);
  l_header_29     varchar2(900);
  l_header_34     varchar2(900);
  l_name_header   varchar2(900);
  l_records       varchar2(900);


BEGIN
    l_report_format := p_input_1;
    hr_utility.trace('Begin Checking ');
    IF p_format = 'MMREF' THEN
       IF p_record_name = 'RA' THEN
          hr_utility.trace('RA record');
          header_string :=
            pay_us_mmrf_print_rec_header.mmrf_format_ra_record_header(
                                                         p_report_type,
                                                         p_format,
                                                         p_report_qualifier,
                                                         p_record_name
                                                       );
       ELSIF p_record_name = 'RE' THEN     --1028 length
          hr_utility.trace('RE record');
          header_string :=
            pay_us_mmrf_print_rec_header.mmrf_format_re_record_header(
                                                         p_report_type,
                                                         p_format,
                                                         p_report_qualifier,
                                                         p_record_name
                                                       );
       ELSIF p_record_name = 'RW' THEN
          hr_utility.trace('RW record');  --2189 length
          header_string :=
            pay_us_mmrf_print_rec_header.mmrf_format_rw_record_header(
                                                         p_report_type,
                                                         p_format,
                                                         p_report_qualifier,
                                                         p_record_name
                                                       );
       ELSIF p_record_name = 'RO' THEN
          hr_utility.trace('RO record');  --1398 length
          header_string:=
            pay_us_mmrf_print_rec_header.mmrf_format_ro_record_header(
                                                        p_report_type,
                                                        p_format,
                                                        p_report_qualifier,
                                                        p_record_name
                                                      );
       ELSIF p_record_name = 'RS' THEN
          hr_utility.trace('RS record');  -- 1715 length
          IF p_report_type = 'W2' THEN
             header_string:=
               pay_us_mmrf_print_rec_header.mmrf_format_w2_rs_rec_header(
                                                           p_report_type,
                                                           p_format,
                                                           p_report_qualifier,
                                                           p_record_name,
                                                           p_input_1
                                                         );
          ELSIF p_report_type = 'SQWL' THEN
             header_string:=
               pay_us_mmrf_print_rec_header.mmrf_format_sqwl_rs_rec_header(
                                                           p_report_type,
                                                           p_format,
                                                           p_report_qualifier,
                                                           p_record_name,
                                                           p_input_1
                                                         );
          END IF;
       ELSIF p_record_name = 'RSSUMM' THEN
          hr_utility.trace('RSSUMM record');    -- 1503 length
          IF p_report_type = 'SQWL' THEN
          header_string:=
            pay_us_mmrf_print_rec_header.mmrf_format_rssumm_rec_header(
                                                        p_report_type,
                                                        p_format,
                                                        p_report_qualifier,
                                                        p_record_name
                                                      );
          END IF;
       ELSIF p_record_name = 'RT' THEN
          hr_utility.trace('RT record');    -- 1503 length
          header_string:=
            pay_us_mmrf_print_rec_header.mmrf_format_rt_record_header(
                                                        p_report_type,
                                                        p_format,
                                                        p_report_qualifier,
                                                        p_record_name
                                                      );
       ELSIF p_record_name = 'RU' THEN
          hr_utility.trace('RU record');   -- 1295 length
          header_string:=
            pay_us_mmrf_print_rec_header.mmrf_format_rt_record_header(
                                                        p_report_type,
                                                        p_format,
                                                        p_report_qualifier,
                                                        p_record_name
                                                      );
       ELSIF p_record_name = 'RF' THEN
          hr_utility.trace('RF record');
          header_string:=
            pay_us_mmrf_print_rec_header.mmrf_format_rt_record_header(
                                                        p_report_type,
                                                        p_format,
                                                        p_report_qualifier,
                                                        p_record_name
                                                      );
       END IF; /* p_record_name */
    ELSIF p_format = 'CUSTOM' THEN

       IF p_record_name = 'A' or
           p_record_name = 'H' or
	   p_record_name = 'D'
       THEN
          hr_utility.trace(p_record_name||' record');  -- 117 length
          IF p_report_type = 'SQWL' THEN
             header_string:=
               pay_us_mmrf_print_rec_header.mmrf_format_sqwl_rs_rec_header(
                                                           p_report_type,
                                                           p_format,
                                                           p_report_qualifier,
                                                           p_record_name,
                                                           p_input_1
                                                         );
          END IF;
       END IF;
    END IF; /* p_format */
    hr_utility.trace('splitting the header string ');
    return_header_string := substr(header_string,1,200);
    sp_out_1:=substr(header_string,201,200);
    sp_out_2:=substr(header_string,401,200);
    sp_out_3:=substr(header_string,601,200);
    sp_out_4:=substr(header_string,801,200);
    sp_out_5:=substr(header_string,1001,200);
    sp_out_6:=substr(header_string,1201,200);
    sp_out_7:=substr(header_string,1401,200);
    sp_out_8:=substr(header_string,1601,200);
    sp_out_9:=substr(header_string,1801,200);
    sp_out_10:=substr(header_string,2001,300);
    p_exclude_from_output:='N';
    hr_utility.trace('return_header_string  = '||return_header_string);
    hr_utility.trace('sp_out_1:='||sp_out_1);
    hr_utility.trace('sp_out_2:='||sp_out_2);
    hr_utility.trace('sp_out_3:='||sp_out_3);
    hr_utility.trace('sp_out_4:='||sp_out_4);
    hr_utility.trace('sp_out_5:='||sp_out_5);
    hr_utility.trace('sp_out_6:='||sp_out_6);
    hr_utility.trace('sp_out_7:='||sp_out_7);
    hr_utility.trace('sp_out_8:='||sp_out_8);
    hr_utility.trace('sp_out_9:='||sp_out_9);
    hr_utility.trace('sp_out_10:='||sp_out_10);

   RETURN return_header_string;
END;



/*
   Name            : data_validation
                   : Function will validate data for any
                     database items or can change the data
                     based on the parameters. It should
                     be capable of having special data
                     validation and change function.

   Error checking

   Special Note  :

*/

FUNCTION data_validation(
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
                   p_validate             IN  varchar2,
                   p_exclude_from_output  OUT nocopy varchar2,
                   sp_out_1               OUT nocopy varchar2,
                   sp_out_2               OUT nocopy varchar2
                 )
return varchar2 IS
l_err boolean;
return_value varchar2(100);
l_length number(10);
l_message varchar2(2000);
l_number_length number(10);
l_description varchar2(50);
l_input_2   varchar2(100);
l_ssn varchar2(50);

TYPE special_numbers is record(
p_number_set varchar2(50));

special_number_record special_numbers;

TYPE ssn_special_number_rec is table
of special_number_record%type INDEX BY binary_integer;
ssn_check ssn_special_number_rec;
BEGIN
l_err  := FALSE;
    IF p_input_1 = 'EIN' THEN
       IF p_report_type = 'SQWL' THEN   -- SQWL EIN check
          return_value :=
             pay_us_report_data_validation.validate_SQWL_EIN( p_report_qualifier,
                                         p_record_name,
                                         p_input_2,
                                         p_input_4,
                                         p_validate,
                                         l_err
                                         );
       ELSIF p_report_type IN ('W2','W2C')  THEN  -- W2 or W2c EIN check
          return_value :=
             pay_us_report_data_validation.validate_W2_EIN( p_report_qualifier,
                                         p_record_name,
                                         p_input_2,
                                         p_input_4,
                                         p_validate,
                                         l_err
                                        );
       END IF; /* SQWL or W2 EIN check */
    ELSIF p_input_1 = 'SSN' THEN
       IF p_report_type = 'SQWL' THEN  /*SQWL SSN check*/
          return_value :=
             pay_us_report_data_validation.validate_SQWL_SSN(p_effective_date,
                                         p_report_type,
                                         p_format,
                                         p_report_qualifier,
                                         p_record_name,
                                         p_input_1,
                                         p_input_2,
                                         p_input_3,
                                         p_input_4,
                                         p_input_5,
                                         p_validate,
                                         l_err
                                        );
       ELSIF p_report_type IN  ('W2','W2C') THEN  /* W2 or W2c SSN check*/
          return_value :=
             pay_us_report_data_validation.validate_W2_SSN(p_effective_date,
                                         p_report_type,
                                         p_format,
                                         p_report_qualifier,
                                         p_record_name,
                                         p_input_1,
                                         p_input_2,
                                         p_input_3,
                                         p_input_4,
                                         p_input_5,
                                         p_validate,
                                         l_err
                                        );
       END IF; -- SQLWL or W2 SSN check
    ELSIF p_input_1 = 'NEG_CHECK' THEN
       l_input_2 := replace(p_input_2,' ');
       IF p_report_type IN ('W2','W2C') THEN
          l_length := pay_us_mmrf_w2_format_record.set_req_field_length(
                               p_report_type,
                               p_format,
                               p_report_qualifier,
                               p_record_name,
                               p_input_1,
                               p_input_2,
                               p_input_3,
                               p_input_4,
                               p_input_5
                              );
       ELSIF p_report_type = 'SQWL' THEN
          l_length := pay_us_mmrf_sqwl_format_record.set_req_field_length(
                               p_report_type,
                               p_format,
                               p_report_qualifier,
                               p_record_name,
                               p_input_1,
                               p_input_2,
                               p_input_3,
                               p_input_4,
                               p_input_5
                              );
       END IF;
       l_number_length:=length(l_input_2);
       IF l_number_length > l_length THEN
         IF (p_record_name in ('RO','RW','RS','RCW','RCO','RSSUMM') OR
            (p_record_name = 'D' AND p_report_qualifier = 'AK_SQWL')) THEN
            l_description:=' The number is bigger than the given length '
                           ||l_length;
            pay_core_utils.push_message(801,'PAY_INVALID_EE_DATA','A');
            pay_core_utils.push_token('record_name',substr(p_record_name,1,50));
            pay_core_utils.push_token('name_or_number',substr(p_input_4,1,50));
            pay_core_utils.push_token('field_name',substr(p_input_3,1,50));
            pay_core_utils.push_token('description',substr(l_description,1,50));
            /* Error in RW record for employee 1234 in Medicare wages.
               The number is bigger than the given length 11 */
            hr_utility.trace(p_input_3 ||' '||l_description);
         END IF;
         l_err:=TRUE;
       END IF;

       hr_utility.trace('l_input_2 = '|| l_input_2);
       hr_utility.trace('l_input_2 in number = '|| to_char(to_number(l_input_2)));
       hr_utility.trace('l_length = '|| l_length);
       hr_utility.trace('After Number length check');
       IF to_number(l_input_2) < 0 THEN
          return_value:='-'||lpad(nvl(replace(l_input_2,'-'),0),l_length-1,0);
          IF( p_record_name in ('RO','RW','RS','RCW','RCO','D','RSSUMM') OR
            (p_record_name = 'D' AND p_report_qualifier = 'AK_SQWL')) THEN
             l_description:=' The value is negative '||substr(l_input_2,1,l_length);
             pay_core_utils.push_message(801,'PAY_INVALID_EE_DATA','A');
             pay_core_utils.push_token('record_name',substr(p_record_name,1,50));
             pay_core_utils.push_token('name_or_number',substr(p_input_4,1,50));
             pay_core_utils.push_token('field_name',substr(p_input_3,1,50));
             pay_core_utils.push_token('description',substr(l_description,1,50));

             /* sample mesg*/
             /* Error in RW record for employee 1234 in Medicare wages.
                The value is negative -2345 */
             hr_utility.trace(l_description);
          END IF;
          l_err:=TRUE;
       ELSE
             hr_utility.trace('l_input_2 = '|| l_input_2);
             hr_utility.trace('l_length = '|| l_length);
          return_value:=lpad(nvl(replace(l_input_2,'-'),0),l_length,0);
             hr_utility.trace('return_value = '|| return_value);
       END IF; /* to_number(l_input_2) */
    END IF; /* p_input_1 */

   hr_utility.trace('Before returning the value = '||return_value);
   hr_utility.trace('p_validate = '||p_validate);

   IF p_validate= 'Y' THEN
      IF l_err THEN
         p_exclude_from_output:='Y';
      ELSE
         p_exclude_from_output:='N';
      END IF;
   END IF;
   hr_utility.trace('p_exclude_from_output = '||p_exclude_from_output);
   RETURN return_value;

END DATA_VALIDATION;


/* ---------------------------------------------------------------
   Function Name : format_record
   Purpose       : Function will return formating of the record
                   there will be one function per record
   Error checking

   Special Note  :

   parameters    : p_input_1
                         This parameter will have the value for
                         transfer employee for
                         'FED' in jurisdiction
                         'W2'  in p_report_type



-------------------------------------------------------------------- */

--

FUNCTION format_record(
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
                   p_input_41             IN  varchar2 default null,
                   p_input_42             IN  varchar2 default null,
                   p_input_43             IN  varchar2 default null,
                   p_input_44             IN  varchar2 default null
                 ) RETURN VARCHAR2
IS

return_value               varchar2(32767);
l_exclude_from_output_chk  boolean;
main_return_string         varchar2(300);
BEGIN

  hr_utility.trace(' p_report_qualifier  = '||p_report_qualifier);
  hr_utility.trace(' p_record_name  = '     ||p_record_name);
  hr_utility.trace(' p_input_2      = '     ||p_input_2);
  hr_utility.trace(' p_input_2      = '     ||p_input_2);
  hr_utility.trace(' p_input_3      = '     ||p_input_3);
  hr_utility.trace(' p_input_4      = '     ||p_input_4);
  hr_utility.trace(' p_input_5      = '     ||p_input_5);
  hr_utility.trace(' p_input_6      = '     ||p_input_6);
  hr_utility.trace(' p_input_7      = '     ||p_input_7);
  hr_utility.trace(' p_input_8      = '     ||p_input_8);
  hr_utility.trace(' p_input_9      = '     ||p_input_9);
  hr_utility.trace(' p_input_10     = '     ||p_input_10);
  hr_utility.trace(' p_input_11     = '     ||p_input_11);
  hr_utility.trace(' p_input_12     = '     ||p_input_12);
  hr_utility.trace(' p_input_13     = '     ||p_input_13);
  hr_utility.trace(' p_input_14     = '     ||p_input_14);
  hr_utility.trace(' p_input_15     = '     ||p_input_15);
  hr_utility.trace(' p_input_16     = '     ||p_input_16);
  hr_utility.trace(' p_input_17     = '     ||p_input_17);
  hr_utility.trace(' p_input_18     = '     ||p_input_18);
  hr_utility.trace(' p_input_19     = '     ||p_input_19);
  hr_utility.trace(' p_input_20     = '     ||p_input_20);
  hr_utility.trace(' p_input_21     = '     ||p_input_21);
  hr_utility.trace(' p_input_22     = '     ||p_input_22);
  hr_utility.trace(' p_input_23     = '     ||p_input_23);
  hr_utility.trace(' p_input_24     = '     ||p_input_24);
  hr_utility.trace(' p_input_25     = '     ||p_input_25);
  hr_utility.trace(' p_input_26     = '     ||p_input_26);
  hr_utility.trace(' p_input_27     = '     ||p_input_27);
  hr_utility.trace(' p_input_28     = '     ||p_input_28);
  hr_utility.trace(' p_input_29     = '     ||p_input_29);
  hr_utility.trace(' p_input_30     = '     ||p_input_30);
  hr_utility.trace(' p_input_31     = '     ||p_input_31);
  hr_utility.trace(' p_input_32     = '     ||p_input_32);
  hr_utility.trace(' p_input_33     = '     ||p_input_33);
  hr_utility.trace(' p_input_34     = '     ||p_input_34);
  hr_utility.trace(' p_input_35     = '     ||p_input_35);
  hr_utility.trace(' p_input_36     = '     ||p_input_36);
  hr_utility.trace(' p_input_37     = '     ||p_input_37);
  hr_utility.trace(' p_input_38     = '     ||p_input_38);
  hr_utility.trace(' p_input_39     = '     ||p_input_39);
  hr_utility.trace(' p_input_40     = '     ||p_input_40);
  hr_utility.trace(' p_input_41     = '     ||p_input_41);
  hr_utility.trace(' p_input_42     = '     ||p_input_42);
  hr_utility.trace(' p_input_43     = '     ||p_input_43);
  hr_utility.trace(' p_input_44     = '     ||p_input_44);

  IF p_format = 'MMREF' THEN  -- p_format
--{
     IF (p_report_type = 'W2') THEN
--{
        IF  p_record_name = 'RA' THEN -- p_record_name
            return_value := pay_us_mmrf_w2_format_record.format_W2_RA_record(
                                                p_effective_date,
                                                p_report_type,
                                                p_format,
                                                p_report_qualifier,
                                                p_record_name,
                                                p_input_1,
                                                p_input_2,
                                                p_input_3,
                                                p_input_4,
                                                p_input_5,
                                                p_input_6,
                                                p_input_7,
                                                p_input_8,
                                                p_input_9 ,
                                                p_input_10,
                                                p_input_11,
                                                p_input_12,
                                                p_input_13,
                                                p_input_14,
                                                p_input_15,
                                                p_input_16,
                                                p_input_17,
                                                p_input_18,
                                                p_input_19,
                                                p_input_20,
                                                p_input_21,
                                                p_input_22,
                                                p_input_23,
                                                p_input_24,
                                                p_input_25,
                                                p_input_26,
                                                p_input_27,
                                                p_input_28,
                                                p_input_29,
                                                p_input_30,
                                                p_input_31,
                                                p_input_32,
                                                p_input_33,
                                                p_input_34,
                                                p_input_35,
                                                p_input_36,
                                                p_input_37,
                                                p_input_38,
                                                p_input_39,
                                                p_input_40,
                                                p_validate,
                                                p_exclude_from_output,
                                                sp_out_1,
                                                sp_out_2,
                                                sp_out_3,
                                                sp_out_4,
                                                sp_out_5,
                                                ret_str_len,
                                                l_exclude_from_output_chk
                                              );
        ELSIF p_record_name = 'RE' THEN
              return_value :=
                   pay_us_mmrf_w2_format_record.format_W2_RE_record(
                                                p_effective_date,
                                                p_report_type,
                                                p_format,
                                                p_report_qualifier,
                                                p_record_name,
                                                p_input_1,
                                                p_input_2,
                                                p_input_3,
                                                p_input_4,
                                                p_input_5,
                                                p_input_6,
                                                p_input_7,
                                                p_input_8,
                                                p_input_9 ,
                                                p_input_10,
                                                p_input_11,
                                                p_input_12,
                                                p_input_13,
                                                p_input_14,
                                                p_input_15,
                                                p_input_16,
                                                p_input_17,
                                                p_input_18,
                                                p_input_19,
                                                p_input_20,
                                                p_input_21,
                                                p_input_22,
                                                p_input_23,
                                                p_input_24,
                                                p_input_25,
                                                p_input_26,
                                                p_input_27,
                                                p_input_28,
                                                p_input_29,
                                                p_input_30,
                                                p_input_31,
                                                p_input_32,
                                                p_input_33,
                                                p_input_34,
                                                p_input_35,
                                                p_input_36,
                                                p_input_37,
                                                p_input_38,
                                                p_input_39,
                                                p_input_40,
                                                p_validate,
                                                p_exclude_from_output,
                                                sp_out_1,
                                                sp_out_2,
                                                sp_out_3,
                                                sp_out_4,
                                                sp_out_5,
                                                ret_str_len,
                                                l_exclude_from_output_chk
                                              );
        ELSIF p_record_name = 'RW' THEN
              return_value :=
                pay_us_mmrf_w2_format_record.format_W2_RW_record(
                                                p_effective_date,
                                                p_report_type,
                                                p_format,
                                                p_report_qualifier,
                                                p_record_name,
                                                p_input_1,
                                                p_input_2,
                                                p_input_3,
                                                p_input_4,
                                                p_input_5,
                                                p_input_6,
                                                p_input_7,
                                                p_input_8,
                                                p_input_9 ,
                                                p_input_10,
                                                p_input_11,
                                                p_input_12,
                                                p_input_13,
                                                p_input_14,
                                                p_input_15,
                                                p_input_16,
                                                p_input_17,
                                                p_input_18,
                                                p_input_19,
                                                p_input_20,
                                                p_input_21,
                                                p_input_22,
                                                p_input_23,
                                                p_input_24,
                                                p_input_25,
                                                p_input_26,
                                                p_input_27,
                                                p_input_28,
                                                p_input_29,
                                                p_input_30,
                                                p_input_31,
                                                p_input_32,
                                                p_input_33,
                                                p_input_34,
                                                p_input_35,
                                                p_input_36,
                                                p_input_37,
                                                p_input_38,
                                                p_input_39,
                                                p_input_40,
                                                p_validate,
                                                p_exclude_from_output,
                                                sp_out_1,
                                                sp_out_2,
                                                sp_out_3,
                                                sp_out_4,
                                                sp_out_5,
                                                ret_str_len,
                                                l_exclude_from_output_chk,
                                                p_input_41,
                                                p_input_42,
                                                p_input_43,
                                                p_input_44
                                              );

        ELSIF p_record_name = 'RO' THEN
              return_value :=
                pay_us_mmrf_w2_format_record.format_W2_RO_record(
                                                p_effective_date,
                                                p_report_type,
                                                p_format,
                                                p_report_qualifier,
                                                p_record_name,
                                                p_input_1,
                                                p_input_2,
                                                p_input_3,
                                                p_input_4,
                                                p_input_5,
                                                p_input_6,
                                                p_input_7,
                                                p_input_8,
                                                p_input_9 ,
                                                p_input_10,
                                                p_input_11,
                                                p_input_12,
                                                p_input_13,
                                                p_input_14,
                                                p_input_15,
                                                p_input_16,
                                                p_input_17,
                                                p_input_18,
                                                p_input_19,
                                                p_input_20,
                                                p_input_21,
                                                p_input_22,
                                                p_input_23,
                                                p_input_24,
                                                p_input_25,
                                                p_input_26,
                                                p_input_27,
                                                p_input_28,
                                                p_input_29,
                                                p_input_30,
                                                p_input_31,
                                                p_input_32,
                                                p_input_33,
                                                p_input_34,
                                                p_input_35,
                                                p_input_36,
                                                p_input_37,
                                                p_input_38,
                                                p_input_39,
                                                p_input_40,
                                                p_validate,
                                                p_exclude_from_output,
                                                sp_out_1,
                                                sp_out_2,
                                                sp_out_3,
                                                sp_out_4,
                                                sp_out_5,
                                                ret_str_len,
                                                l_exclude_from_output_chk
                                              );

        ELSIF p_record_name = 'RS' THEN
              return_value :=
                pay_us_mmrf_w2_format_record.format_W2_RS_record(
                                                p_effective_date,
                                                p_report_type,
                                                p_format,
                                                p_report_qualifier,
                                                p_record_name,
                                                p_input_1,
                                                p_input_2,
                                                p_input_3,
                                                p_input_4,
                                                p_input_5,
                                                p_input_6,
                                                p_input_7,
                                                p_input_8,
                                                p_input_9 ,
                                                p_input_10,
                                                p_input_11,
                                                p_input_12,
                                                p_input_13,
                                                p_input_14,
                                                p_input_15,
                                                p_input_16,
                                                p_input_17,
                                                p_input_18,
                                                p_input_19,
                                                p_input_20,
                                                p_input_21,
                                                p_input_22,
                                                p_input_23,
                                                p_input_24,
                                                p_input_25,
                                                p_input_26,
                                                p_input_27,
                                                p_input_28,
                                                p_input_29,
                                                p_input_30,
                                                p_input_31,
                                                p_input_32,
                                                p_input_33,
                                                p_input_34,
                                                p_input_35,
                                                p_input_36,
                                                p_input_37,
                                                p_input_38,
                                                p_input_39,
                                                p_input_40,
                                                p_validate,
                                                p_exclude_from_output,
                                                sp_out_1,
                                                sp_out_2,
                                                sp_out_3,
                                                sp_out_4,
                                                sp_out_5,
                                                ret_str_len,
                                                l_exclude_from_output_chk
                                              );
        ELSIF p_record_name = 'RT' THEN
              return_value :=
                pay_us_mmrf_w2_format_record.format_W2_RT_record(
                                                p_effective_date,
                                                p_report_type,
                                                p_format,
                                                p_report_qualifier,
                                                p_record_name,
                                                p_input_1,
                                                p_input_2,
                                                p_input_3,
                                                p_input_4,
                                                p_input_5,
                                                p_input_6,
                                                p_input_7,
                                                p_input_8,
                                                p_input_9 ,
                                                p_input_10,
                                                p_input_11,
                                                p_input_12,
                                                p_input_13,
                                                p_input_14,
                                                p_input_15,
                                                p_input_16,
                                                p_input_17,
                                                p_input_18,
                                                p_input_19,
                                                p_input_20,
                                                p_input_21,
                                                p_input_22,
                                                p_input_23,
                                                p_input_24,
                                                p_input_25,
                                                p_input_26,
                                                p_input_27,
                                                p_input_28,
                                                p_input_29,
                                                p_input_30,
                                                p_input_31,
                                                p_input_32,
                                                p_input_33,
                                                p_input_34,
                                                p_input_35,
                                                p_input_36,
                                                p_input_37,
                                                p_input_38,
                                                p_input_39,
                                                p_input_40,
                                                p_validate,
                                                p_exclude_from_output,
                                                sp_out_1,
                                                sp_out_2,
                                                sp_out_3,
                                                sp_out_4,
                                                sp_out_5,
                                                ret_str_len,
                                                l_exclude_from_output_chk
                                              );
        ELSIF p_record_name = 'RU' THEN
            return_value :=
              pay_us_mmrf_w2_format_record.format_W2_RU_record(
                                                p_effective_date,
                                                p_report_type,
                                                p_format,
                                                p_report_qualifier,
                                                p_record_name,
                                                p_input_1,
                                                p_input_2,
                                                p_input_3,
                                                p_input_4,
                                                p_input_5,
                                                p_input_6,
                                                p_input_7,
                                                p_input_8,
                                                p_input_9 ,
                                                p_input_10,
                                                p_input_11,
                                                p_input_12,
                                                p_input_13,
                                                p_input_14,
                                                p_input_15,
                                                p_input_16,
                                                p_input_17,
                                                p_input_18,
                                                p_input_19,
                                                p_input_20,
                                                p_input_21,
                                                p_input_22,
                                                p_input_23,
                                                p_input_24,
                                                p_input_25,
                                                p_input_26,
                                                p_input_27,
                                                p_input_28,
                                                p_input_29,
                                                p_input_30,
                                                p_input_31,
                                                p_input_32,
                                                p_input_33,
                                                p_input_34,
                                                p_input_35,
                                                p_input_36,
                                                p_input_37,
                                                p_input_38,
                                                p_input_39,
                                                p_input_40,
                                                p_validate,
                                                p_exclude_from_output,
                                                sp_out_1,
                                                sp_out_2,
                                                sp_out_3,
                                                sp_out_4,
                                                sp_out_5,
                                                ret_str_len,
                                                l_exclude_from_output_chk
                                              );

-- RV Record formatting vmkulkar
	        ELSIF  p_record_name = 'RV' THEN -- p_record_name
            return_value := pay_us_mmrf_w2_format_record.format_W2_RV_record(
                                                p_effective_date,
                                                p_report_type,
                                                p_format,
                                                p_report_qualifier,
                                                p_record_name,
                                                p_input_1,
                                                p_input_2,
                                                p_input_3,
                                                p_input_4,
                                                p_input_5,
                                                p_input_6,
                                                p_input_7,
                                                p_input_8,
                                                p_input_9 ,
                                                p_input_10,
                                                p_input_11,
                                                p_input_12,
                                                p_input_13,
                                                p_input_14,
                                                p_input_15,
                                                p_input_16,
                                                p_input_17,
                                                p_input_18,
                                                p_input_19,
                                                p_input_20,
                                                p_input_21,
                                                p_input_22,
                                                p_input_23,
                                                p_input_24,
                                                p_input_25,
                                                p_input_26,
                                                p_input_27,
                                                p_input_28,
                                                p_input_29,
                                                p_input_30,
                                                p_input_31,
                                                p_input_32,
                                                p_input_33,
                                                p_input_34,
                                                p_input_35,
                                                p_input_36,
                                                p_input_37,
                                                p_input_38,
                                                p_input_39,
                                                p_input_40,
                                                p_validate,
                                                p_exclude_from_output,
                                                sp_out_1,
                                                sp_out_2,
                                                sp_out_3,
                                                sp_out_4,
                                                sp_out_5,
                                                ret_str_len,
                                                l_exclude_from_output_chk
                                              );
	ELSIF p_record_name = 'RF' THEN
              return_value :=
                pay_us_mmrf_w2_format_record.format_W2_RF_record(
                                                  p_effective_date,
                                                  p_report_type,
                                                  p_format,
                                                  p_report_qualifier,
                                                  p_record_name,
                                                  p_input_1,
                                                  p_input_2,
                                                  p_input_3,
                                                  p_input_4,
                                                  p_input_40,
                                                  p_validate,
                                                  p_exclude_from_output,
                                                  ret_str_len,
                                                  l_exclude_from_output_chk
                                                 );
        END IF;  --p_record_name
--}
     ELSIF (p_report_type = 'SQWL') THEN  --p_report_type
--{
        IF    p_record_name = 'RA'  THEN -- p_record_name
            return_value := pay_us_mmrf_sqwl_format_record.format_SQWL_RA_record(
                                                p_effective_date,
                                                p_report_type,
                                                p_format,
                                                p_report_qualifier,
                                                p_record_name,
                                                p_input_1,
                                                p_input_2,
                                                p_input_3,
                                                p_input_4,
                                                p_input_5,
                                                p_input_6,
                                                p_input_7,
                                                p_input_8,
                                                p_input_9 ,
                                                p_input_10,
                                                p_input_11,
                                                p_input_12,
                                                p_input_13,
                                                p_input_14,
                                                p_input_15,
                                                p_input_16,
                                                p_input_17,
                                                p_input_18,
                                                p_input_19,
                                                p_input_20,
                                                p_input_21,
                                                p_input_22,
                                                p_input_23,
                                                p_input_24,
                                                p_input_25,
                                                p_input_26,
                                                p_input_27,
                                                p_input_28,
                                                p_input_29,
                                                p_input_30,
                                                p_input_31,
                                                p_input_32,
                                                p_input_33,
                                                p_input_34,
                                                p_input_35,
                                                p_input_36,
                                                p_input_37,
                                                p_input_38,
                                                p_input_39,
                                                p_input_40,
                                                p_validate,
                                                p_exclude_from_output,
                                                sp_out_1,
                                                sp_out_2,
                                                sp_out_3,
                                                sp_out_4,
                                                sp_out_5,
                                                ret_str_len,
                                                l_exclude_from_output_chk
                                              );
        ELSIF p_record_name = 'RE'  THEN
            return_value :=
              pay_us_mmrf_sqwl_format_record.format_SQWL_RE_record(
                                                p_effective_date,
                                                p_report_type,
                                                p_format,
                                                p_report_qualifier,
                                                p_record_name,
                                                p_input_1,
                                                p_input_2,
                                                p_input_3,
                                                p_input_4,
                                                p_input_5,
                                                p_input_6,
                                                p_input_7,
                                                p_input_8,
                                                p_input_9 ,
                                                p_input_10,
                                                p_input_11,
                                                p_input_12,
                                                p_input_13,
                                                p_input_14,
                                                p_input_15,
                                                p_input_16,
                                                p_input_17,
                                                p_input_18,
                                                p_input_19,
                                                p_input_20,
                                                p_input_21,
                                                p_input_22,
                                                p_input_23,
                                                p_input_24,
                                                p_input_25,
                                                p_input_26,
                                                p_input_27,
                                                p_input_28,
                                                p_input_29,
                                                p_input_30,
                                                p_input_31,
                                                p_input_32,
                                                p_input_33,
                                                p_input_34,
                                                p_input_35,
                                                p_input_36,
                                                p_input_37,
                                                p_input_38,
                                                p_input_39,
                                                p_input_40,
                                                p_validate,
                                                p_exclude_from_output,
                                                sp_out_1,
                                                sp_out_2,
                                                sp_out_3,
                                                sp_out_4,
                                                sp_out_5,
                                                ret_str_len,
                                                l_exclude_from_output_chk
                                              );

        ELSIF p_record_name = 'RS'  THEN
            return_value :=
              pay_us_mmrf_sqwl_format_record.format_SQWL_RS_record(
                                                p_effective_date,
                                                p_report_type,
                                                p_format,
                                                p_report_qualifier,
                                                p_record_name,
                                                p_input_1,
                                                p_input_2,
                                                p_input_3,
                                                p_input_4,
                                                p_input_5,
                                                p_input_6,
                                                p_input_7,
                                                p_input_8,
                                                p_input_9 ,
                                                p_input_10,
                                                p_input_11,
                                                p_input_12,
                                                p_input_13,
                                                p_input_14,
                                                p_input_15,
                                                p_input_16,
                                                p_input_17,
                                                p_input_18,
                                                p_input_19,
                                                p_input_20,
                                                p_input_21,
                                                p_input_22,
                                                p_input_23,
                                                p_input_24,
                                                p_input_25,
                                                p_input_26,
                                                p_input_27,
                                                p_input_28,
                                                p_input_29,
                                                p_input_30,
                                                p_input_31,
                                                p_input_32,
                                                p_input_33,
                                                p_input_34,
                                                p_input_35,
                                                p_input_36,
                                                p_input_37,
                                                p_input_38,
                                                p_input_39,
                                                p_input_40,
                                                p_validate,
                                                p_exclude_from_output,
                                                sp_out_1,
                                                sp_out_2,
                                                sp_out_3,
                                                sp_out_4,
                                                sp_out_5,
                                                ret_str_len,
                                                l_exclude_from_output_chk
                                              );
        ELSIF p_record_name = 'RT'  THEN
            return_value :=
              pay_us_mmrf_sqwl_format_record.format_SQWL_RT_record(
                                                p_effective_date,
                                                p_report_type,
                                                p_format,
                                                p_report_qualifier,
                                                p_record_name,
                                                p_input_1,
                                                p_input_2,
                                                p_input_3,
                                                p_input_4,
                                                p_input_5,
                                                p_input_6,
                                                p_input_7,
                                                p_input_8,
                                                p_input_9 ,
                                                p_input_10,
                                                p_input_11,
                                                p_input_12,
                                                p_input_13,
                                                p_input_14,
                                                p_input_15,
                                                p_input_16,
                                                p_input_17,
                                                p_input_18,
                                                p_input_19,
                                                p_input_20,
                                                p_input_21,
                                                p_input_22,
                                                p_input_23,
                                                p_input_24,
                                                p_input_25,
                                                p_input_26,
                                                p_input_27,
                                                p_input_28,
                                                p_input_29,
                                                p_input_30,
                                                p_input_31,
                                                p_input_32,
                                                p_input_33,
                                                p_input_34,
                                                p_input_35,
                                                p_input_36,
                                                p_input_37,
                                                p_input_38,
                                                p_input_39,
                                                p_input_40,
                                                p_validate,
                                                p_exclude_from_output,
                                                sp_out_1,
                                                sp_out_2,
                                                sp_out_3,
                                                sp_out_4,
                                                sp_out_5,
                                                ret_str_len,
                                                l_exclude_from_output_chk
                                              );
        ELSIF p_record_name = 'RSSUMM'  THEN
            return_value :=
              pay_us_mmrf_sqwl_format_record.format_SQWL_RSSUMM_record(
                                                p_effective_date,
                                                p_report_type,
                                                p_format,
                                                p_report_qualifier,
                                                p_record_name,
                                                p_input_1,
                                                p_input_2,
                                                p_input_3,
                                                p_input_4,
                                                p_input_5,
                                                p_input_6,
                                                p_input_7,
                                                p_input_8,
                                                p_input_9 ,
                                                p_input_10,
                                                p_input_11,
                                                p_input_12,
                                                p_input_13,
                                                p_input_14,
                                                p_input_15,
                                                p_input_16,
                                                p_input_17,
                                                p_input_18,
                                                p_input_19,
                                                p_input_20,
                                                p_input_21,
                                                p_input_22,
                                                p_input_23,
                                                p_input_24,
                                                p_input_25,
                                                p_input_26,
                                                p_input_27,
                                                p_input_28,
                                                p_input_29,
                                                p_input_30,
                                                p_input_31,
                                                p_input_32,
                                                p_input_33,
                                                p_input_34,
                                                p_input_35,
                                                p_input_36,
                                                p_input_37,
                                                p_input_38,
                                                p_input_39,
                                                p_input_40,
                                                p_validate,
                                                p_exclude_from_output,
                                                sp_out_1,
                                                sp_out_2,
                                                sp_out_3,
                                                sp_out_4,
                                                sp_out_5,
                                                ret_str_len,
                                                l_exclude_from_output_chk
                                              );
        ELSIF p_record_name = 'RST' THEN
            return_value :=
              pay_us_mmrf_sqwl_format_record.format_SQWL_RST_record(
                                                p_effective_date,
                                                p_report_type,
                                                p_format,
                                                p_report_qualifier,
                                                p_record_name,
                                                p_input_1,
                                                p_input_2,
                                                p_input_3,
                                                p_input_4,
                                                p_input_5,
                                                p_input_6,
                                                p_input_7,
                                                p_input_8,
                                                p_input_9 ,
                                                p_input_40,
                                                p_validate,
                                                p_exclude_from_output,
                                                ret_str_len
                                              );
        ELSIF p_record_name = 'RU'  THEN
            return_value :=
              pay_us_mmrf_sqwl_format_record.format_SQWL_RU_record(
                                                p_effective_date,
                                                p_report_type,
                                                p_format,
                                                p_report_qualifier,
                                                p_record_name,
                                                p_input_1,
                                                p_input_2,
                                                p_input_40,
                                                p_exclude_from_output,
                                                ret_str_len
                                                 );
        ELSIF p_record_name = 'RF'  THEN
            return_value :=
              pay_us_mmrf_sqwl_format_record.format_SQWL_RF_record(
                                                p_effective_date,
                                                p_report_type,
                                                p_format,
                                                p_report_qualifier,
                                                p_record_name,
                                                p_input_1,
                                                p_input_2,
                                                p_input_3,
                                                p_input_4,
                                                p_input_40,
                                                p_validate,
                                                p_exclude_from_output,
                                                ret_str_len
                                                 );
        END IF;  --p_record_name
--}
     END IF; --p_report_type
--}
  ELSIF p_format = 'CUSTOM' THEN
--{
        hr_utility.trace('In pay_us_reporting_utils_pkg.format_record ' || p_format);

        IF    p_record_name = 'H'  THEN -- p_record_name
              hr_utility.trace('In pay_us_reporting_utils_pkg.format_record ' || p_record_name);
            return_value :=
              pay_us_custom_sqwl_format_rec.format_SQWL_CUSTOM_EMPLOYER(
                                                p_effective_date,
                                                p_report_type,
                                                p_format,
                                                p_report_qualifier,
                                                p_record_name,
                                                p_input_1,
                                                p_input_2,
                                                p_input_3,
                                                p_input_4,
                                                p_input_5,
                                                p_input_6,
                                                p_input_7,
                                                p_input_8,
                                                p_input_9 ,
                                                p_input_10,
                                                p_input_11,
                                                p_input_12,
                                                p_input_13,
                                                p_input_14,
                                                p_input_15,
                                                p_input_16,
                                                p_input_17,
                                                p_input_18,
                                                p_input_19,
                                                p_input_20,
                                                p_input_21,
                                                p_input_22,
                                                p_input_23,
                                                p_input_24,
                                                p_input_25,
                                                p_input_26,
                                                p_input_27,
                                                p_input_28,
                                                p_input_29,
                                                p_input_30,
                                                p_input_31,
                                                p_input_32,
                                                p_input_33,
                                                p_input_34,
                                                p_input_35,
                                                p_input_36,
                                                p_input_37,
                                                p_input_38,
                                                p_input_39,
                                                p_input_40,
                                                p_validate,
                                                p_exclude_from_output,
                                                sp_out_1,
                                                sp_out_2,
                                                sp_out_3,
                                                sp_out_4,
                                                sp_out_5,
                                                ret_str_len,
                                                l_exclude_from_output_chk
                                              );

        ELSIF p_record_name = 'D'  THEN
              hr_utility.trace('In pay_us_reporting_utils_pkg.format_record ' || p_record_name);
            return_value :=
              pay_us_custom_sqwl_format_rec.format_SQWL_CUSTOM_EMPLOYEE(
                                                p_effective_date,
                                                p_report_type,
                                                p_format,
                                                p_report_qualifier,
                                                p_record_name,
                                                p_input_1,
                                                p_input_2,
                                                p_input_3,
                                                p_input_4,
                                                p_input_5,
                                                p_input_6,
                                                p_input_7,
                                                p_input_8,
                                                p_input_9 ,
                                                p_input_10,
                                                p_input_11,
                                                p_input_12,
                                                p_input_13,
                                                p_input_14,
                                                p_input_15,
                                                p_input_16,
                                                p_input_17,
                                                p_input_18,
                                                p_input_19,
                                                p_input_20,
                                                p_input_21,
                                                p_input_22,
                                                p_input_23,
                                                p_input_24,
                                                p_input_25,
                                                p_input_26,
                                                p_input_27,
                                                p_input_28,
                                                p_input_29,
                                                p_input_30,
                                                p_input_31,
                                                p_input_32,
                                                p_input_33,
                                                p_input_34,
                                                p_input_35,
                                                p_input_36,
                                                p_input_37,
                                                p_input_38,
                                                p_input_39,
                                                p_input_40,
                                                p_validate,
                                                p_exclude_from_output,
                                                sp_out_1,
                                                sp_out_2,
                                                sp_out_3,
                                                sp_out_4,
                                                sp_out_5,
                                                ret_str_len,
                                                l_exclude_from_output_chk
                                              );
     END IF; --p_report_type
--}
   END IF; -- p_format
   return_value:=upper(return_value);

   main_return_string := substr(return_value,1,200);
   sp_out_1:=substr(return_value,201,200);
   sp_out_2:=substr(return_value,401,200);
   sp_out_3:=substr(return_value,601,200);
   sp_out_4:=substr(return_value,801,200);

   IF (((p_record_name = 'RS') OR (p_record_name = 'D')) AND
       (p_report_type = 'SQWL') AND
       (p_input_40 = 'FLAT') ) THEN
       NULL; -- sp_out_5 is initialized with ssn in format_SQWL_RS_record
   ELSE
       sp_out_5:=substr(return_value,1001,200);
   END IF;
   IF l_exclude_from_output_chk  THEN
      p_exclude_from_output := 'Y';
   ELSE
      p_exclude_from_output := 'N';
   END IF;
   hr_utility.trace('main_return_string = '||main_return_string);
   hr_utility.trace(' length of main_return_string = '||to_char(length(main_return_string)));
   hr_utility.trace('sp_out_1 = '||sp_out_1);
   hr_utility.trace(' length of sp_out_1 = '||to_char(length(sp_out_1)));
   hr_utility.trace('sp_out_2 = '||sp_out_2);
   hr_utility.trace(' length of sp_out_2 = '||to_char(length(sp_out_2)));
   hr_utility.trace('sp_out_3 = '||sp_out_3);
   hr_utility.trace(' length of sp_out_3 = '||to_char(length(sp_out_3)));
   hr_utility.trace('sp_out_4 = '||sp_out_4);
   hr_utility.trace(' length of sp_out_4 = '||to_char(length(sp_out_4)));
   hr_utility.trace('sp_out_5 = '||sp_out_5);
   hr_utility.trace(' length of sp_out_5 = '||to_char(length(sp_out_5)));
   hr_utility.trace('p_exclude_from_output = '||p_exclude_from_output);

   RETURN main_return_string;
END Format_Record;

/* Function Name : Get_Territory_Values
   Purpose       :  Purpose of this function is to fetch the balances as well
                    as the data related to territory.
   Error checking
   Special Note  :
*/

FUNCTION Get_Territory_Values(
                   p_assignment_action_id     number, -- context
                   p_tax_unit_id              number,-- context
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
                   p_validate             IN  varchar2,
                   p_exclude_from_output  OUT nocopy varchar2,
                   sp_out_1               OUT nocopy varchar2,
                   sp_out_2               OUT nocopy varchar2,
                   sp_out_3               OUT nocopy varchar2,
                   sp_out_4               OUT nocopy varchar2,
                   sp_out_5               OUT nocopy varchar2,
                   sp_out_6               OUT nocopy varchar2,
                   sp_out_7               OUT nocopy varchar2,
                   sp_out_8               OUT nocopy varchar2,
                   sp_out_9               OUT nocopy varchar2,
                   sp_out_10              OUT nocopy varchar2)
return varchar2 IS

  l_err boolean;
  l_entity_id ff_database_items.user_entity_id%type;
  l_archived_value ff_archive_items.value%type;
  l_jurisdiction_code varchar2(25);
  l_message varchar2(1000);
  l_state_wage varchar2(100);
  l_main_return varchar2(100);

  TYPE dbi_columns IS RECORD(
     p_user_name ff_database_items.user_name%type,
     p_archived_value ff_archive_items.value%type);

  dbi_rec dbi_columns;

  TYPE dbi_infm IS TABLE OF dbi_rec%TYPE
  INDEX BY BINARY_INTEGER;

  dbi_table dbi_infm;

  CURSOR get_user_entity_id
       (c_user_name ff_database_items.user_name%type) IS
    SELECT fdi.user_entity_id
      FROM   ff_database_items fdi,
             ff_user_entities  fue
      WHERE  fue.legislation_code = 'US'
      AND    fue.user_entity_id = fdi.user_entity_id
      AND    fdi.user_name = c_user_name;

  CURSOR get_archived_values(
          c_user_entity_id ff_database_items.user_entity_id%type,
          c_assignment_action_id pay_assignment_actions.assignment_action_id%type,
          c_tax_unit_id hr_organization_units.organization_id%type)
  IS
    SELECT target.value
    FROM   ff_archive_item_contexts con2,
           ff_contexts fc2,
           ff_archive_items target
    WHERE  target.user_entity_id = c_user_entity_id
    AND    target.context1 = to_char(c_assignment_action_id)
	   /* context assignment action id */
    AND    fc2.context_name = 'TAX_UNIT_ID'
    and    con2.archive_item_id = target.archive_item_id
    and    con2.context_id = fc2.context_id
    and    ltrim(rtrim(con2.context)) = to_char(c_tax_unit_id);
           /*context of tax_unit_id */

  CURSOR get_jd_archived_values(
          c_user_entity_id ff_database_items.user_entity_id%type,
          c_assignment_action_id pay_assignment_actions.assignment_action_id%type,
          c_tax_unit_id hr_organization_units.organization_id%type,
          c_jurisdiction_code varchar2)
  IS
    SELECT target.value
    FROM   ff_archive_item_contexts con2,
           ff_archive_item_contexts con3,
           ff_contexts fc2,
           ff_contexts fc3,
           ff_archive_items target
    WHERE  target.user_entity_id = c_user_entity_id
    AND    target.context1 = to_char(c_assignment_action_id)
            /* context assignment action id */
    AND    fc2.context_name = 'TAX_UNIT_ID'
    and    con2.archive_item_id = target.archive_item_id
    and    con2.context_id = fc2.context_id
    and    ltrim(rtrim(con2.context)) = to_char(c_tax_unit_id)
            /*context of tax_unit_id */
    and    fc3.context_name = 'JURISDICTION_CODE'
    and    con3.archive_item_id = target.archive_item_id
    and    con3.context_id = fc3.context_id
    and    substr(con3.context,1,2) = substr(c_jurisdiction_code,1,2);
           /* 3rd context of state jurisdiction_code*/

BEGIN

   hr_utility.trace('p_assignment_action_id = '||to_char(p_assignment_action_id));
   hr_utility.trace('p_tax_unit_id = '||to_char(p_tax_unit_id));
   dbi_table(1).p_user_name:='A_TERRITORY_RETIRE_CONTRIB_PER_GRE_YTD';
   dbi_table(2).p_user_name:='A_TERRITORY_TAXABLE_ALLOW_PER_GRE_YTD';
   dbi_table(3).p_user_name:='A_TERRITORY_TAXABLE_COMM_PER_GRE_YTD';
   dbi_table(4).p_user_name:='A_TERRITORY_TAXABLE_TIPS_PER_GRE_YTD';
   dbi_table(5).p_user_name:='A_SIT_WITHHELD_PER_JD_GRE_YTD';
   dbi_table(6).p_user_name:='A_PER_MARITAL_STATUS';
   dbi_table(7).p_user_name:='A_CON_NATIONAL_IDENTIFIER';

   l_jurisdiction_code:='72-000-0000';
   hr_utility.trace('Get PR Values');

   FOR i in dbi_table.first .. dbi_table.last loop

       OPEN get_user_entity_id(dbi_table(i).p_user_name);
       FETCH get_user_entity_id INTO l_entity_id;
       IF get_user_entity_id%NOTFOUND THEN

          l_message:='Error in '||p_record_name||'. User_Entity_Id not found for user name '
                            ||dbi_table(i).p_user_name;
          dbi_table(i).p_archived_value:='00000000000';

       ELSIF get_user_entity_id%FOUND THEN

          hr_utility.trace('get_user_entity_id = '||to_char(l_entity_id));
          hr_utility.trace('p_assignment_action_id = '||to_char(p_assignment_action_id));
          hr_utility.trace('p_tax_unit_id  = '||to_char(p_tax_unit_id));

          IF dbi_table(i).p_user_name like '%PER_JD_GRE_YTD' THEN
             open get_jd_archived_values(l_entity_id,
                                      p_assignment_action_id,
                                      p_tax_unit_id,
                                      l_jurisdiction_code);
             FETCH get_jd_archived_values INTO l_archived_value;
             IF get_jd_archived_values%NOTFOUND THEN
                dbi_table(i).p_archived_value:='00000000000';
             ELSE
                dbi_table(i).p_archived_value:= data_validation
                                                  ( p_effective_date,
                                                    p_report_type,
                                                    p_format,
                                                    p_report_qualifier,
                                                    p_record_name,
                                                    'NEG_CHECK',
                                                    l_archived_value,
                                                    dbi_table(i).p_user_name,
                                                    p_input_1,
                                                    null,
                                                    p_validate,
                                                    p_exclude_from_output,
                                                    sp_out_1,
                                                    sp_out_2);

                hr_utility.trace('Archived_value = '||dbi_table(i).p_archived_value);

                IF p_exclude_from_output = 'Y' THEN
                   l_err:=TRUE;
                END IF;
             END IF;
             CLOSE get_jd_archived_values;

          ELSE -- Non JD specific balances
             OPEN get_archived_values(l_entity_id,
                                      p_assignment_action_id,
                                      p_tax_unit_id);
             FETCH get_archived_values INTO l_archived_value;

             IF get_archived_values%NOTFOUND THEN
                IF ( (dbi_table(i).p_user_name = 'A_PER_MARITAL_STATUS') OR
                     (dbi_table(i).p_user_name = 'A_CON_NATIONAL_IDENTIFIER') ) THEN
                   dbi_table(i).p_archived_value:= ' ';
                ELSE
                   dbi_table(i).p_archived_value:='00000000000';
                END IF;

                hr_utility.trace('Archived_values not found for user name ' ||dbi_table(i).p_user_name);
             ELSIF get_archived_values%FOUND THEN

                hr_utility.trace('Archived_values found for user name ' ||dbi_table(i).p_user_name);
                hr_utility.trace('Archived_value before neg check= '||l_archived_value);

                IF ((dbi_table(i).p_user_name = 'A_PER_MARITAL_STATUS') OR
                    (dbi_table(i).p_user_name = 'A_CON_NATIONAL_IDENTIFIER')) THEN
                   dbi_table(i).p_archived_value := l_archived_value;

                   IF dbi_table(i).p_user_name = 'A_PER_MARITAL_STATUS' THEN

                      l_archived_value := replace(l_archived_value,' ');
                      -- Bug # 2173795
                      -- For Portorico Tax Jurisdiction Civil Status value would either M or S
                      -- IF l_archived_value is other than M it should be defaulted to S
                      IF l_archived_value = 'M' THEN
                         dbi_table(i).p_archived_value := 'M';
                      ELSE
                         dbi_table(i).p_archived_value := 'S';
                      END IF;
                   END IF;

                ELSE

                   dbi_table(i).p_archived_value:= data_validation
                                                     ( p_effective_date,
                                                       p_report_type,
                                                       p_format,
                                                       p_report_qualifier,
                                                       p_record_name,
                                                       'NEG_CHECK',
                                                       l_archived_value,
                                                       dbi_table(i).p_user_name,
                                                       p_input_1,
                                                       null,
                                                       p_validate,
                                                       p_exclude_from_output,
                                                       sp_out_1,
                                                       sp_out_2);

                   hr_utility.trace('Archived_value = '||dbi_table(i).p_archived_value);

                   IF p_exclude_from_output = 'Y' THEN
                      l_err:=TRUE;
                   END IF;
                END IF;
             END IF;
             CLOSE get_archived_values;
          END IF;
       END IF;
       CLOSE get_user_entity_id;

   END LOOP;


   hr_utility.trace('before Call to retrieve state_wages');

   l_state_wage := HR_US_W2_REP.GET_W2_ARCH_BAL
                    (p_assignment_action_id,'A_W2_STATE_WAGES',
                     p_tax_unit_id,l_jurisdiction_code,2);

   hr_utility.trace('l_state_wage = '||l_state_wage);
   sp_out_5:=  data_validation ( p_effective_date,
                                     p_report_type,
                                     p_format,
                                     p_report_qualifier,
                                     p_record_name,
                                     'NEG_CHECK',
                                     l_state_wage,
                                     'State_wage',
                                     p_input_1,
                                     null,
                                     p_validate,
                                     p_exclude_from_output,
                                     sp_out_1,
                                     sp_out_2);

   IF p_exclude_from_output='Y' THEN
       l_err:=TRUE;
   END IF;


   l_main_return:=dbi_table(1).p_archived_value;
   sp_out_1:=dbi_table(2).p_archived_value;
   sp_out_2:=dbi_table(3).p_archived_value;
   sp_out_3:=dbi_table(4).p_archived_value;
   sp_out_4:=dbi_table(5).p_archived_value;
   sp_out_6:=dbi_table(6).p_archived_value;
   sp_out_7:=dbi_table(7).p_archived_value;


   hr_utility.trace('l_main_return = '||l_main_return);
   hr_utility.trace('sp_out_1 = '||sp_out_1);
   hr_utility.trace('sp_out_2 = '||sp_out_2);
   hr_utility.trace('sp_out_3 = '||sp_out_3);
   hr_utility.trace('sp_out_4 = '||sp_out_4);
   hr_utility.trace('sp_out_5 = '||sp_out_5);
   hr_utility.trace('sp_out_6 = '||sp_out_6);
   hr_utility.trace('sp_out_7 = '||sp_out_7);


   IF p_validate = 'Y' THEN
      IF l_err THEN
         p_exclude_from_output:='Y';
      END IF;
   END IF;

   IF p_exclude_from_output IS NULL THEN
      p_exclude_from_output:='N';
   END IF;

   RETURN l_main_return;

END Get_Territory_Values;

FUNCTION Character_check(p_value IN varchar2)
RETURN VARCHAR2

IS

  TYPE special_characters is record(
  p_character varchar2(100));
  character_val_record special_characters;
  type character_val_rec IS table of character_val_record%type
  INDEX BY BINARY_INTEGER;
  character_rec character_val_rec;
  l_stripped_value varchar2(100);
  l_param_length number(20);

  Begin

     character_rec(1).p_character :='<';
     character_rec(2).p_character :='>';
     character_rec(3).p_character :='(';
     character_rec(4).p_character :=')';
     character_rec(5).p_character :='_';
     character_rec(6).p_character :='*';
     character_rec(7).p_character :='&';
     character_rec(8).p_character :='^';
     character_rec(9).p_character :='%';
     character_rec(10).p_character :='$';
     character_rec(11).p_character :='#';
     character_rec(12).p_character :='@';
     character_rec(13).p_character :='!';
     character_rec(14).p_character :='~';
     character_rec(15).p_character :='+';
     character_rec(16).p_character :='=';
     character_rec(17).p_character :='?';
     character_rec(18).p_character :='/';
     character_rec(19).p_character :=','; /* Bug:2150138*/

     l_stripped_value := p_value;

     FOR i in 1 .. 19 LOOP

         l_stripped_value := replace(l_stripped_value,character_rec(i).p_character,' ');

     END LOOP;

     return l_stripped_value;

  END;

FUNCTION Formula_Check(p_report_format IN VARCHAR2,
                       p_formula_name  IN VARCHAR2)
RETURN VARCHAR2 IS

   l_value varchar2(1);

   CURSOR formula_exist(c_report_format pay_magnetic_blocks.report_format%TYPE,
                     c_formula_name  ff_formulas_f.formula_name%TYPE)
   IS
   SELECT 'Y'
   FROM  ff_formulas_f ff,
         pay_magnetic_blocks pmb,
         pay_magnetic_records pmr
   WHERE pmb.report_format = c_report_format
   AND   pmr.magnetic_block_id = pmb.magnetic_block_id
   AND   pmr.formula_id = ff.formula_id
   AND   ff.formula_name = c_formula_name;

   Begin

   l_value := 'N';

     hr_utility.trace('Formula_Check');
     hr_utility.trace('p_report_format = '||p_report_format);
     hr_utility.trace('p_formula_name = '||p_formula_name);


     OPEN formula_exist(p_report_format,
                        p_formula_name);

     FETCH formula_exist INTO l_value;

     CLOSE formula_exist;

     hr_utility.trace('l_value = '||l_value);

     RETURN l_value;

  END;

FUNCTION get_file_name ( p_bus_group_id       IN Number,    -- Business Group Id
                         p_report_type        IN Varchar2,  -- W2, W2C, SQWL, RL (Rita/CCA or Local City)
                         p_state_code         IN Varchar2,  -- FED or State Code
                         p_mag_effective_date IN Varchar2,  -- This would be used to derive period
                         p_format_type        IN Varchar2   -- Only for SQWL (I=ICESA, M=MMREF, T=TIB4, S=State)
                       ) RETURN varchar2
   IS

--
-- Purpose: Procedure to derive the Mag file Name for following Magnetic media
--          processes.
--               1. Federal W-2 Magnetic Media
--               2. State W-2 Magnetic Media
--               3. State Quarterly Wage Listing
--               4. Local W-2 Magnetic Media
--               5. Federal W-2c Magnetic Medica
--
-- Declaration of  Local program variables
--
   l_mag_file_name          Varchar2(80);
--
-- This Cursor fetches Tax info for the given jurisdiction and effective date
--
-- Federal Mag filenames will have following format.
--                   1.	Max of 6 characters Business Group Short Name (Embedded blanks will be ignored)
--                   2.	FED or State Abbreviation
--                   3.	Format specifier (W2)
--                   4.	Last two digits of the year

cursor c_fed_w2_Cursor(c_bus_group_id       Number,
                       c_report_type        Varchar2,
                       c_mag_effective_date Varchar2)
       is
       select substr(translate(upper(o.short_name),
                    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz~`!@#$%^\&*()_-+=|\}]
{["'':;?/>.<, ', '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'),1,6)||
    ---substr(replace(replace(replace(upper(o.short_name),'_'),' '),'-'),1,6)||
              'FED'||c_report_type||
              substr(to_char(add_months(fnd_date.canonical_TO_DATE(c_mag_effective_date), 12) -1, 'YYYY'),3,4)
         from per_business_groups o where o.organization_id = c_bus_group_id;

-- State W-2 Mag filenames will have following format.
--                   1.	Max of 6 characters Business Group Short Name (Embedded blanks will be ignored)
--                   2.	State Abbreviation
--                   3.	Report Type
--                   4.	Last two digits of the year

cursor c_State_W2_Cursor (c_bus_group_id       Number,
                          c_report_type        Varchar2,
                          c_state_code         Varchar2,
                          c_mag_effective_date Varchar2)
       is
       select substr(translate(upper(o.short_name),
                    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz~`!@#$%^\&*()_-+=|\}]
{["'':;?/>.<, ', '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'),1,6)||
-- substr(replace(replace(replace(upper(o.short_name),'_'),' '),'-'),1,6)||
              psr.state_code ||
              c_report_type||
              substr(to_char(add_months(fnd_date.canonical_to_date(c_mag_effective_date ), 12) -1, 'YYYY'),3,4)
         from per_business_groups o, pay_state_rules psr
        where o.organization_id = c_bus_group_id
          and psr.state_code = c_state_code;

-- The SQWL (State Quarterly Wage Listing) filenames will follow the naming convention as
--                  1.	Max of 6 characters Business Group Short Name (Embedded blanks will be ignored)
--                  2.	State Abbreviation
--                  3.	Period in MMYY format
--                  4.	Format Type (i.e. I=ICESA, M=MMREF, T=TIB4, S=State)

cursor c_sqwl_Cursor (c_bus_group_id       Number,
                      c_state_code         Varchar2,
                      c_mag_effective_date Varchar2,
                      c_format_type        Varchar2)
       is
       select substr(translate(upper(o.short_name),
                    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz~`!@#$%^\&*()_-+=|\}]
{["'':;?/>.<, ', '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'),1,6)||
-- substr(replace(replace(replace(upper(o.short_name),'_'),' '),'-'),1,6)||
              c_state_code ||
              substr(to_char(fnd_date.canonical_to_date(c_mag_effective_date ), 'MMYY'),1,4) ||
              c_format_type
         from per_business_groups o, pay_state_rules psr
        where o.organization_id = c_bus_group_id
          and psr.state_code = c_state_code;

--
-- Local Mag filenames will have following format.
--                   1.	Max of 6 characters Business Group Short Name (Embedded blanks will be ignored)
--                   2.	City or Agency Code
--                   3.	Format specifier (W2)
--                   4.	Last two digits of the year
--
cursor c_local_cursor(c_bus_group_id        Number,
                      c_city_or_agency_code Varchar2,
                      c_mag_effective_date  Varchar2)
       is
       select substr(translate(upper(o.short_name),
                    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz~`!@#$%^\&*()_-+=|\}]
{["'':;?/>.<, ', '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'),1,6)||
-- substr(replace(replace(replace(upper(o.short_name),'_'),' '),'-'),1,6)||
              decode(c_city_or_agency_code,'RTCCA','RITA','CCAAA','CCA',c_city_or_agency_code) ||
              'W2'||
              substr(to_char(add_months(fnd_date.canonical_TO_DATE(c_mag_effective_date), 12) -1, 'YYYY'),3,4)
         from per_business_groups o where o.organization_id = c_bus_group_id;

BEGIN
   l_mag_file_name  := '';

    if p_report_type in ('W2', 'W2C') then
       if p_state_code = 'FED' then
            open c_fed_w2_cursor(p_bus_group_id, p_report_type, p_mag_effective_date );
            fetch c_fed_w2_cursor into l_mag_file_name;
            close c_fed_w2_cursor;
       else
            open c_state_w2_cursor(p_bus_group_id, p_report_type, p_state_code, p_mag_effective_date );
            fetch c_state_w2_cursor into l_mag_file_name;
            close c_state_w2_cursor ;
       end if;

    elsif p_report_type = 'SQWL' then
            open c_sqwl_cursor(p_bus_group_id, p_state_code, p_mag_effective_date, p_format_type );
            fetch c_sqwl_cursor into l_mag_file_name;
            close c_sqwl_cursor;
    elsif p_report_type = 'RL' then
            open c_local_cursor(p_bus_group_id, p_state_code, p_mag_effective_date );
            fetch c_local_cursor into l_mag_file_name;
            close c_local_cursor;
    else
          l_mag_file_name := 'ERRORMAGFILE';
    end if;
    return (l_mag_file_name);
END get_file_name; -- End of Function get_file_name


-- This function derives balance_ID for a given Balance
--
FUNCTION bal_db_item ( p_db_item_name varchar2)
   RETURN number
IS

 /* Get the defined_balance_id for the specified balance DB item. */

   CURSOR   csr_defined_balance is
   SELECT   to_number(UE.creator_id)
     FROM   ff_user_entities  UE,
            ff_database_items DI
     WHERE  DI.user_name            = p_db_item_name
       AND  UE.user_entity_id       = DI.user_entity_id
       AND  Ue.creator_type         = 'B'
       AND  UE.legislation_code     = 'US';

   l_defined_balance_id pay_defined_balances.defined_balance_id%TYPE;


BEGIN

    --hr_utility.trace('p_db_item_name is '||p_db_item_name);

   OPEN csr_defined_balance;
   FETCH csr_defined_balance INTO l_defined_balance_id;
   IF csr_defined_balance%notfound THEN
     CLOSE csr_defined_balance;
     RAISE hr_utility.hr_error;
   ELSE
     CLOSE csr_defined_balance;
   END IF;

   --hr_utility.trace('l_defined_balance_id is '||to_char(l_defined_balance_id));
   RETURN (l_defined_balance_id);

END bal_db_item;

-- Derives live Balance for W2_GOVE_EE_CONTRIB
--
FUNCTION get_live_ee_contrib( p_assignment_action_id      number,      --context
                              p_tax_unit_id               number       --context
                            )
  RETURN VARCHAR2
  IS

  lv_bal_amt          number  := 0;
  l_bal_id            number  := 0;
  l_get               boolean := TRUE ;
  l_balance_name      pay_balance_types.balance_name%TYPE;
  l_effective_start_date pay_payroll_actions.effective_date%TYPE;
  l_effective_end_date pay_payroll_actions.effective_date%TYPE;
  l_exists            varchar2(1);

CURSOR get_effective_date(c_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
IS
select add_months(effective_date,-12)+1,effective_date
from   pay_payroll_actions ppa,
       pay_assignment_actions paa
where  ppa.payroll_action_id = paa.payroll_action_id
and    paa.assignment_action_id = c_assignment_action_id;

/*Bug:3233249*/
CURSOR get_balance_feed_exist(c_balance_name pay_balance_types.balance_name%TYPE,
                              c_start_date pay_payroll_actions.effective_date%TYPE,
                              c_end_date pay_payroll_actions.effective_date%TYPE)
IS
select '1' from pay_balance_feeds_f pbf,
                pay_balance_types  pbt
where pbf.balance_type_id = pbt.balance_type_id
and pbt.balance_name =  c_balance_name
and pbf.effective_start_date <= c_end_date
and pbf.effective_end_date >= c_start_date;


BEGIN
        if p_tax_unit_id is not null then
           pay_balance_pkg.set_context('TAX_UNIT_ID', p_tax_unit_id);
        end if;
        l_balance_name := 'W2 Govt EE Contrib';

        OPEN get_effective_date(p_assignment_action_id);
        FETCH get_effective_date INTO l_effective_start_date
                                      ,l_effective_end_date;

        hr_utility.trace('l_effective_start_date = '||l_effective_start_date);
        hr_utility.trace('l_effective_end_date = '||l_effective_end_date);

        IF get_effective_date%NOTFOUND THEN

           hr_utility.trace('Effective Date not found for given
                             assignment_action_id ='||to_char(p_assignment_action_id));

        END IF;

        CLOSE get_effective_date;

        OPEN get_balance_feed_exist(l_balance_name,
                                    l_effective_start_date,
                                    l_effective_end_date);

        FETCH get_balance_feed_exist INTO l_exists;


        If get_balance_feed_exist%NOTFOUND THEN

            hr_utility.trace('get_balance_feed_exist%NOTFOUND');
           return 0;

        ELSE

          /* Live Balance Call Procedure */
          l_bal_id   := bal_db_item('W2_GOVT_EE_CONTRIB_PER_GRE_YTD');
           hr_utility.trace('get_balance_feed_exist FOUND');
           lv_bal_amt := nvl(pay_balance_pkg.get_value
                            (p_defined_balance_id   => l_bal_id,
                             p_assignment_action_id => p_assignment_action_id),0);
           return (to_char(lv_bal_amt));

        END IF;

END get_live_ee_contrib;

 /*********************************************************************
    Name        : get_ff_archive_value

    Description : Definition for formula function GET_ARCHIVE_VALUE.
                  Calls the get_archive_value function to fetch the
                  archived value for an user entity
    ********************************************************************/

   FUNCTION get_ff_archive_value (
      p_action_id           NUMBER,   -- context
      p_jurisdiction_code   VARCHAR2, -- context
      p_tax_unit_id         NUMBER,   -- context
      p_data_type           VARCHAR2
   )
      RETURN NUMBER IS

   lv_return_value NUMBER;
   lv_data_type VARCHAR2(100);
  /*bug 4011829 */
   l_jurisdiction_code VARCHAR(11);


   BEGIN
   lv_return_value := 0;
   hr_utility.trace('In pay_us_reporting_utils_pkg.get_ff_archive_value');

   hr_utility.trace('p_tax_unit_id = '||p_tax_unit_id);
   hr_utility.trace('p_assignment_action_id = '||p_action_id);

/*

-- remarked by tmehra, as discussed with Dipen and Mehul
-- The whole if block would  be removed after Mehul clarifies the
-- 'A_W2_HSA_PER_GRE_YTD' usage.

   IF p_data_type = 'ER_HSA' THEN
      lv_data_type := 'A_W2_HSA_PER_GRE_YTD';
   ELSIF p_data_type = 'IN_STATE_ADV_EIC' THEN
      lv_data_type := 'A_STEIC_ADVANCE_PER_JD_GRE_YTD';
   ELSIF p_data_type = 'IN_FED_ADV_EIC' THEN
      lv_data_type := 'A_EIC_ADVANCE_PER_GRE_YTD';
   ELSE lv_data_type := NULL;
   END IF;
*/
  if p_data_type like '%_JD_%' THEN

     l_jurisdiction_code := substr(p_jurisdiction_code,1,2)||'-000-0000';

  else

     l_jurisdiction_code := NULL;

  end if;

   lv_return_value := to_number(pay_us_archive_util.get_archive_value(
                                                   p_action_id,
                                                   p_data_type,
                                                   p_tax_unit_id,
                                                   l_jurisdiction_code
                                                 ));

   hr_utility.trace('lv_return_value = ' || lv_return_value);


   RETURN nvl(lv_return_value,0);

   END get_ff_archive_value;


   FUNCTION get_employee_count( p_payroll_action_id   number,  --context
                                p_tax_unit_id         number,  --context
                                p_state             varchar2 default null
                              ) RETURN number IS
   lv_employee_count   number ;
   BEGIN
        hr_utility.trace('Inside pay_us_reporting_utils_pkg.get_employee_count') ;
        hr_utility.trace('p_payroll_action_id := '||p_payroll_action_id) ;
        hr_utility.trace('p_tax_unit_id := ' || p_tax_unit_id) ;

        select count(*)
        into lv_employee_count
        from pay_payroll_actions ppa,
               pay_assignment_actions paa
        where ppa.payroll_action_id = p_payroll_action_id
        and paa.tax_unit_id = p_tax_unit_id
        and ppa.payroll_action_id = paa.payroll_action_id ;

    hr_utility.trace('lv_employee_count := '||lv_employee_count) ;
    RETURN lv_employee_count ;

    END get_employee_count ;


FUNCTION get_employee_count_monthwise( p_payroll_action_id   number,  --context
                             p_tax_unit_id         number,  --context
                             p_database_item_name             varchar2
                            ) RETURN number is
   lv_employee_count   number ;
   temp_month_count number;
   return_month_count number;

   cursor get_all_assignment (cur_payroll_action_id number, cur_tax_unit_id number)
   is
   Select paa.assignment_action_id
   from pay_assignment_actions paa
   where payroll_action_id  = cur_payroll_action_id
   and tax_unit_id = cur_tax_unit_id;

   BEGIN

   return_month_count := 0;

   FOR i in get_all_assignment (p_payroll_action_id, p_tax_unit_id) LOOP

	   Select fai.value
	   into lv_employee_count
	   from ff_archive_items fai,
	          ff_database_items fdi
	   where fdi.user_name = p_database_item_name	/*eg A_SQWL_MONTH1_COUNT */
	      and fai.user_entity_id = fdi.user_entity_id
	      and fai.context1 = i.assignment_action_id ;

         IF lv_employee_count is null THEN
            temp_month_count := pay_us_sqwl_misc.get_Old_Month1_Count( i.assignment_action_id);
         ELSE
            temp_month_count := lv_employee_count ;
         END IF;

        IF (temp_month_count <> 0 ) THEN
            return_month_count := return_month_count + 1;
       END IF;

    END LOOP;

    RETURN return_month_count ;

END get_employee_count_monthwise;

   FUNCTION get_total_wages( p_payroll_action_id   number,  --context
                             p_tax_unit_id         number,  --context
                             p_state               varchar2,
                             p_report_type         varchar2 default 'SQWL',
                             p_balance_name        varchar2 default null
                           ) RETURN number IS
   lv_total_wages    number ;

   CURSOR cur_employee_count(p_payroll_action_id number,
                             p_tax_unit_id       number,
                             p_state             varchar2) IS
       SELECT count(*)
       FROM   ff_archive_item_contexts faic,
              ff_archive_items fai,
              ff_database_items fdi,
              pay_assignment_actions paa,
              pay_payroll_actions ppa
       WHERE
              ppa.payroll_action_id = p_payroll_action_id
          and ppa.payroll_action_id = paa.payroll_action_id
          and fdi.user_name = 'A_STATE_ABBREV'
          and fdi.user_entity_id = fai.user_entity_id
          and fai.archive_item_id = faic.archive_item_id
          and fai.context1 = paa.assignment_action_id
          and fai.value = p_state
          and paa.tax_unit_id = p_tax_unit_id
          and paa.action_status = 'C'
          and nvL(hr_us_w2_rep.get_w2_arch_bal(paa.assignment_action_id,
                                               'A_W2_STATE_WAGES',
                                                paa.tax_unit_id,
                                                faic.context , 2),0) > 0
              and not exists
                          (
                            select 'x'
                              from hr_organization_information hoi
                             WHERE hoi.organization_id = paa.tax_unit_id
                               and hoi.org_information_context ='1099R Magnetic Report Rules'
                           )   ;

   lv_employee_count       NUMBER ;

   CURSOR cur_summed_balance(p_payroll_action_id number,
                             p_tax_unit_id       number,
                             p_state             varchar2) IS
      SELECT fdi1.user_name,
              sum(to_number(nvl(fai1.value,'0')))
       FROM       ff_archive_item_contexts faic,
                  ff_archive_items fai,
                  ff_database_items fdi,
                  pay_assignment_actions paa,
                  pay_payroll_actions ppa,
                  ff_archive_items fai1,
                  ff_database_items fdi1,
                  ff_archive_item_contexts faic1,
                  ff_contexts fc,
                  pay_us_states pus
            WHERE
                  ppa.payroll_action_id = p_payroll_action_id
              and ppa.payroll_action_id = paa.payroll_action_id
              and fdi.user_name = 'A_STATE_ABBREV'
              and fdi.user_entity_id = fai.user_entity_id
              and fai.archive_item_id = faic.archive_item_id
              and fai.context1 = paa.assignment_action_id
              and fai.value = p_state
              and paa.tax_unit_id = p_tax_unit_id
              and paa.action_status = 'C'
              and nvL(hr_us_w2_rep.get_w2_arch_bal(paa.assignment_action_id,
                                               'A_W2_STATE_WAGES',
                                                paa.tax_unit_id,
                                                faic.context , 2),0) > 0
              and not exists
                          (
                            select 'x'
                              from hr_organization_information hoi
                             WHERE hoi.organization_id = paa.tax_unit_id
                               and hoi.org_information_context ='1099R Magnetic Report Rules'
                           )

              and fdi1.user_name in (
              'A_SIT_WITHHELD_PER_JD_GRE_YTD',
              'A_SIT_SUBJ_NWHABLE_PER_JD_GRE_YTD',
              'A_SIT_SUBJ_WHABLE_PER_JD_GRE_YTD',
              'A_SIT_PRE_TAX_REDNS_PER_JD_GRE_YTD',
              'A_W2_STATE_PICKUP_PER_GRE_YTD')
              and  fdi1.user_entity_id = fai1.user_entity_id
              and  fai1.context1 = paa.assignment_action_id
              and  fai1.archive_item_id = faic1.archive_item_id
              and  (
                   (
                   faic1.context_id = fc.context_id
              and  fc.context_name = 'JURISDICTION_CODE'
              and  substr(faic1.context,1,2) = pus.state_code
              and  pus.state_abbrev = p_state
                   )
                 or
                     not exists (select 'x'
                             from  ff_archive_items fai2,
                                   ff_archive_item_contexts faic2,
                                   ff_contexts fc2
                             where fai2.user_entity_id = fdi1.user_entity_id
                             and   fai2.context1 = fai1.context1
                             and   fai2.archive_item_id = fai1.archive_item_id
                             and   fai2.archive_item_id = faic2.archive_item_id
                             and   faic2.context_id = fc2.context_id
                             and   fc2.context_name = 'JURISDICTION_CODE')
                  )
group by fdi1.user_name ;

   TYPE balance_rec IS RECORD ( dbi_name             VARCHAR2(200),
                                summed_balance_value NUMBER ) ;
   TYPE w2_bal_tab IS TABLE OF balance_rec INDEX BY BINARY_INTEGER ;
   lv_tot_wage_tab      w2_bal_tab ;
   i                    NUMBER ;

   BEGIN

        hr_utility.trace('Inside pay_us_reporting_utils_pkg.get_total_wages') ;
        hr_utility.trace('p_payroll_action_id := '||p_payroll_action_id) ;
        hr_utility.trace('p_tax_unit_id := ' || p_tax_unit_id) ;
        hr_utility.trace('p_state := ' || p_state) ;
        hr_utility.trace('p_report_type := ' || p_report_type) ;
        hr_utility.trace('p_balance_name := ' || p_balance_name) ;

    lv_total_wages := 0 ;
    lv_employee_count := 0 ;

    IF p_report_type = 'SQWL' THEN

      IF p_state = 'MI'  or p_state='NM' THEN

        select sum(to_number(nvl(fai.value, '0')) - to_number(nvl(fai1.value, '0')))
        into lv_total_wages
        from pay_payroll_actions ppa,
             pay_assignment_actions paa,
             ff_archive_items fai,
             ff_archive_items fai1,
             ff_database_items fdi,
             ff_database_items fdi1
        where ppa.payroll_action_id = p_payroll_action_id
        and ppa.payroll_action_id = paa.payroll_action_id
        and paa.tax_unit_id = p_tax_unit_id
        and fai.context1 = paa.assignment_action_id
        and fai.user_entity_id = fdi.user_entity_id
        and fdi.user_name = 'A_SUI_ER_SUBJ_WHABLE_PER_JD_GRE_QTD'
        and fai1.context1 = fai.context1
        and fai1.user_entity_id = fdi1.user_entity_id
        and fdi1.user_name = 'A_SUI_ER_PRE_TAX_REDNS_PER_JD_GRE_QTD' ;

        RETURN lv_total_wages ;
     END IF ;

   ELSIF p_report_type = 'W2' THEN
      IF p_state = 'MD' THEN
         OPEN cur_summed_balance(p_payroll_action_id,
                                 p_tax_unit_id,
                                 p_state) ;
         i := 0 ;
         LOOP
            i := i + 1 ;
            FETCH cur_summed_balance INTO lv_tot_wage_tab(i).dbi_name,
                                          lv_tot_wage_tab(i).summed_balance_value;

            EXIT WHEN cur_summed_balance%NOTFOUND ;

         END LOOP ;
         CLOSE cur_summed_balance ;

      IF p_balance_name = 'SIT Withheld' THEN
            FOR j IN 1..(i - 1)
            LOOP
               IF lv_tot_wage_tab(j).dbi_name = 'A_SIT_WITHHELD_PER_JD_GRE_YTD' THEN
                  lv_total_wages := lv_tot_wage_tab(j).summed_balance_value ;
                  EXIT ;
               END IF ;
            END LOOP ;
              hr_utility.trace('p_balance_name := '||p_balance_name) ;
              hr_utility.trace('lv_total_wages := '||lv_total_wages) ;

            RETURN lv_total_wages ;

      ELSIF p_balance_name = 'State taxable Wages' THEN
            FOR j IN 1..(i - 1)
            LOOP
               IF  lv_tot_wage_tab(j).dbi_name = 'A_SIT_SUBJ_WHABLE_PER_JD_GRE_YTD' THEN
                   lv_total_wages := lv_total_wages + lv_tot_wage_tab(j).summed_balance_value ;
               ELSIF lv_tot_wage_tab(j).dbi_name = 'A_SIT_SUBJ_NWHABLE_PER_JD_GRE_YTD' THEN
                   lv_total_wages := lv_total_wages + lv_tot_wage_tab(j).summed_balance_value ;
               ELSIF lv_tot_wage_tab(j).dbi_name = 'A_SIT_PRE_TAX_REDNS_PER_JD_GRE_YTD' THEN
                   lv_total_wages := lv_total_wages - lv_tot_wage_tab(j).summed_balance_value ;
               END IF ;
            END LOOP ;
            hr_utility.trace('p_balance_name := '||p_balance_name) ;
            hr_utility.trace('lv_total_wages := '||lv_total_wages) ;

            RETURN lv_total_wages ;

      ELSIF p_balance_name = 'Other State Data' THEN
            FOR j IN 1..(i - 1)
            LOOP
               IF lv_tot_wage_tab(j).dbi_name = 'A_W2_STATE_PICKUP_PER_GRE_YTD' THEN
                  lv_total_wages := lv_tot_wage_tab(j).summed_balance_value ;
                  EXIT ;
               END IF ;
            END LOOP ;
          hr_utility.trace('p_balance_name := '||p_balance_name) ;
          hr_utility.trace('lv_total_wages := '||lv_total_wages) ;

            RETURN lv_total_wages ;
      END IF ; -- p_balance_name
      END IF ; -- p_state

      IF p_balance_name = 'Employee Count' THEN
         IF p_state = 'MD' THEN
            OPEN cur_employee_count(p_payroll_action_id,
                                    p_tax_unit_id,
                                    p_state) ;
            FETCH cur_employee_count INTO lv_employee_count ;
            CLOSE cur_employee_count ;

            RETURN lv_employee_count ;
         END IF ;
      END IF ;
    END IF ; -- p_report_type

   END get_total_wages ;

/* sackumar */

function get_wages(p_payroll_action_id   number,  --context
                           p_tax_unit_id         number,  --context
                           p_state               varchar2,
                           p_excess_wages out nocopy number,
                           p_withholding out nocopy number,
                           p_workerscomp out nocopy number
                          ) return number IS
   BEGIN
        select nvl(sum(to_number(nvl(fai.value, '0'))
                   - to_number(nvl(fai1.value, '0'))
                   - to_number(nvl(fai2.value, '0'))
                       ),0)
        into p_excess_wages
        from pay_payroll_actions ppa,
             pay_assignment_actions paa,
             ff_archive_items fai,
             ff_archive_items fai1,
             ff_archive_items fai2,
             ff_database_items fdi,
             ff_database_items fdi1,
             ff_database_items fdi2
        where ppa.payroll_action_id = p_payroll_action_id
        and ppa.payroll_action_id = paa.payroll_action_id
        and paa.tax_unit_id = p_tax_unit_id
        and fai.context1 = paa.assignment_action_id
        and fai.user_entity_id = fdi.user_entity_id
        and fdi.user_name = 'A_SUI_ER_SUBJ_WHABLE_PER_JD_GRE_QTD'
        and fai1.context1 = fai.context1
        and fai1.user_entity_id = fdi1.user_entity_id
        and fdi1.user_name = 'A_SUI_ER_PRE_TAX_REDNS_PER_JD_GRE_QTD'
        and fai2.context1 = fai1.context1
        and fai2.user_entity_id = fdi2.user_entity_id
        and fdi2.user_name = 'A_SUI_ER_TAXABLE_PER_JD_GRE_QTD' ;

        select nvl(sum(to_number(nvl(fai.value, '0'))),0)
        into p_withholding
        from pay_payroll_actions ppa,
             pay_assignment_actions paa,
             ff_archive_items fai,
             ff_database_items fdi
        where ppa.payroll_action_id = p_payroll_action_id
        and ppa.payroll_action_id = paa.payroll_action_id
        and paa.tax_unit_id = p_tax_unit_id
        and fai.context1 = paa.assignment_action_id
        and fai.user_entity_id = fdi.user_entity_id
        and fdi.user_name = 'A_SIT_WITHHELD_PER_JD_GRE_QTD';

        select nvl(sum(to_number(nvl(fai.value, '0'))
                   + to_number(nvl(fai1.value, '0'))
                   + to_number(nvl(fai2.value, '0'))
                      ),0)
        into p_workerscomp
        from pay_payroll_actions ppa,
             pay_assignment_actions paa,
             ff_archive_items fai,
             ff_archive_items fai1,
             ff_archive_items fai2,
             ff_database_items fdi,
             ff_database_items fdi1,
             ff_database_items fdi2
        where ppa.payroll_action_id = p_payroll_action_id
        and ppa.payroll_action_id = paa.payroll_action_id
        and paa.tax_unit_id = p_tax_unit_id
        and fai.context1 = paa.assignment_action_id
        and fai.user_entity_id = fdi.user_entity_id
        and fdi.user_name = 'A_WORKERS_COMPENSATION2_ER_PER_JD_GRE_QTD'
        and fai1.context1 = fai.context1
        and fai1.user_entity_id = fdi1.user_entity_id
        and fdi1.user_name = 'A_WORKERS_COMP2_WITHHELD_PER_JD_GRE_QTD'
        and fai2.context1 = fai1.context1
        and fai2.user_entity_id = fdi2.user_entity_id
        and fdi2.user_name = 'A_WORKERS_COMP_WITHHELD_PER_JD_GRE_QTD' ;

        return(0);
   END get_wages ;

   FUNCTION GET_SUI_WAGES(p_payroll_action_id   number,  --context
                   p_tax_unit_id         number,  --context
                   p_state               varchar2,
                   p_sui_gross out nocopy number,
                   p_sui_subj out nocopy number,
                   p_sui_pre_tax out nocopy number,
                   p_sui_taxable out nocopy number
                  )return number is

     CURSOR cur_fl_sqwl IS
     select 'Y' from pay_payroll_actions
      where payroll_action_id=p_payroll_action_id
      and report_type='SQWL'
      and report_qualifier='FL';

      l_fl_sqwl VARCHAR2(2);
      l_sui_adj_taxable number;

   BEGIN

        select  nvl(sum(to_number(nvl(fai.value, '0'))),0),
	        nvl(sum(to_number(nvl(fai1.value, '0'))),0),
		nvl(sum(to_number(nvl(fai2.value, '0'))),0),
		nvl(sum(to_number(nvl(fai3.value, '0'))),0)
        into	p_sui_subj,
		p_sui_pre_tax,
		p_sui_taxable,
		p_sui_gross
        from pay_payroll_actions ppa,
             pay_assignment_actions paa,
             ff_archive_items fai,
             ff_archive_items fai1,
             ff_archive_items fai2,
             ff_archive_items fai3,
             ff_database_items fdi,
             ff_database_items fdi1,
             ff_database_items fdi2,
             ff_database_items fdi3
        where ppa.payroll_action_id = p_payroll_action_id
        and ppa.payroll_action_id = paa.payroll_action_id
        and paa.tax_unit_id = p_tax_unit_id
        and fai.context1 = paa.assignment_action_id
        and fai.user_entity_id = fdi.user_entity_id
        and fdi.user_name = 'A_SUI_ER_SUBJ_WHABLE_PER_JD_GRE_QTD'
        and fai1.context1 = fai.context1
        and fai1.user_entity_id = fdi1.user_entity_id
        and fdi1.user_name = 'A_SUI_ER_PRE_TAX_REDNS_PER_JD_GRE_QTD'
        and fai2.context1 = fai1.context1
        and fai2.user_entity_id = fdi2.user_entity_id
        and fdi2.user_name = 'A_SUI_ER_TAXABLE_PER_JD_GRE_QTD'
        and fai3.context1 = fai1.context1
        and fai3.user_entity_id = fdi3.user_entity_id
        and fdi3.user_name = 'A_SUI_ER_GROSS_PER_JD_GRE_QTD'
        and  length(translate(trim(fai.value),' .0123456789',' ')) is null
	and  length(translate(trim(fai2.value),' .0123456789',' ')) is null ;

        hr_utility.trace('Actual SUI Taxable Amount'||p_sui_taxable);

	open cur_fl_sqwl;
	fetch cur_fl_sqwl into l_fl_sqwl;
	if l_fl_sqwl = 'Y'
	then
	hr_utility.trace('Getting the Adjusted Taxable for Florida');

        select  nvl(sum(to_number(nvl(fai.value, '0'))),0)
        into p_sui_taxable
        from pay_payroll_actions ppa,
             pay_assignment_actions paa,
             ff_archive_items fai,
             ff_database_items fdi
        where ppa.payroll_action_id = p_payroll_action_id
        and ppa.payroll_action_id = paa.payroll_action_id
        and paa.tax_unit_id = p_tax_unit_id
        and fai.context1 = paa.assignment_action_id
        and fai.user_entity_id = fdi.user_entity_id
        and fdi.user_name = 'SUI_ER_FL_ADJ_TAXABLE_PER_JD_GRE_QTD'
	and  length(translate(trim(fai.value),' .0123456789',' ')) is null;


        hr_utility.trace('Adjusted SUI Taxable Amount for Florida'||p_sui_taxable);

	end if;
        return(0);

   END GET_SUI_WAGES;
--BEGIN
--hr_utility.trace_on(null,'MMREF');

END pay_us_reporting_utils_pkg;

/
