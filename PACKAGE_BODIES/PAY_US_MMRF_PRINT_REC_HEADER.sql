--------------------------------------------------------
--  DDL for Package Body PAY_US_MMRF_PRINT_REC_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_MMRF_PRINT_REC_HEADER" AS
/* $Header: pyusprhd.pkb 120.6.12010000.2 2010/03/25 04:53:17 emunisek ship $  */

 /*===========================================================================+
 |               Copyright (c) 2001 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+

  Name
    pay_us_mmrf_print_rec_header_pkg

  Purpose
    The purpose of this package is to format reacord header
    to support the generation of magnetic tape W2 / SQWL reports
    for US legilsative requirements. These record headers are
    mainly used for CSV

   Notes
    Referenced By:  Package  pay_us_reporting_utils_pkg

   Notes

   History

   25-Mar-2010 emunisek   115.21  9356178  Added new column "Actual State Quarterly
                                           Unemployment Total Taxable Wages" for Florida
					   SQWL Audit Reports a02 and a03
   10-Jan-2007 sausingh   115.20  5358272  Added Headers for Roth 401k/403b
               sudedas                            Changed mmrf2_format_rcw_record_header
   22-Nov-2006 sudedas    115.19  5640748  Modified mmrf_format_re_record_header
                                           for State of Maryland.
   17-Aug-2006 sudedas    115.18  5256745  Header Changed for RW and RT
                                           Records due to MMREF-1 spec change.
   30-May-2006 sackumar 115.17 (5089997, 4554387) Changed header for CUSTOM H and D Records.
   03-Dec-2005 sodhingr   115.16  4398606  Changed header for RCO and RCW
   05-Nov-2005 sudedas    115.15  4391218  Header Changed for RA, RW, RO, RT, RO
                                           Records due to MMREF-1 spec change.
   25-NOV-2004 rsethupa   115.14  4014356  RS Record header for NJ
                                           Added 'MIF'
   25-NOV-2004 rsethupa   115.13  4022086  RS Record header for MS
                                           Added 'Federal ER Account Number',
					   '1099 Income' and 'Payment Yeat'
   05-NOV-2004 rsethupa   115.12  3680056  RW and RT records header for
                                           ER Contrib to Health Savings Acct
   02-NOV-2004 rsethupa   115.11  3180532  RS Record header for IN
                                           Replaced columns 'Country Code',
					   'Optional Code' and 'Reporting Period'
					   with 'Federal Advanced EIC'.
					   Added 'State Advanced EIC' and
					   'State Advanced EIC ID'
   27-OCT-2004 rsethupa   115.10  3936924  RS record header for AL
				           Added 'Federal Employer Account Number',
					   'Payment Year'
   26-OCT-2004 meshah     115.9   3650105  changed mmrf2_format_rcw_record_header
                                           to add ER contribution to HSA Account.
   28-AUG-2004 jgoswami   115.8   3830050  added mmrf_format_rssumm_rec_header
   01-MAR-2004 jgoswami   115.7   3334497  Added Columns for AK_SQWL header string.
   19-DEC-03  jgoswami    115.6   3319454  Added EIN for WA_SQWL header string.
   08-DEC-03  ppanda      115.4   3300354  Column heading on a02 and a03 corrected
   02-Dec-03  ppanda      115.3   3277954  Column heading changed for RCW and RCO record
   10-Nov-03  ppanda      115.2   2587381  RCW and RCO record header formating function
                                           added
   14-Oct-03  fusman      115.1   2682247  Separate header for NY in RS record.
                                  3220001  Parameter order was changed.
   14-Jul-03  ppanda      115.0                Created
*/
 -- Global Variable
g_number	NUMBER;
l_return    varchar2(100);
end_date    date := to_date('31/12/4712','DD/MM/YYYY');

--
-- This function format submitter Record (i.e. RA) record header
--
FUNCTION mmrf_format_ra_record_header(
                   p_report_type          IN  varchar2,
                   p_format               IN  varchar2,
                   p_report_qualifier     IN  varchar2,
                   p_record_name          IN  varchar2
                 )  RETURN VARCHAR2
IS
-- Local Variables
  header_string        varchar2(3000);
BEGIN
     hr_utility.trace('Formatting RA record header');
     -- This is  fix for bug # 2510920
     -- Column heading which used to be 'Resub TLCN' now its going to be 'Resub WFID'
     --
     header_string := 'Record Identifier'
                        ||','||'Submitters Employer Identification Number (EIN)'
                        ||','||'Personal Identification Number (PIN)'
                        ||','||'Blank' -- Bug# 4391218
                        ||','||'Resub Indicator'
                        ||','||'Resub WFID'
                        ||','||'Software Code'
                        ||','||'Company Name'
                        ||','||'Location Address'
                        ||','||'Delivery Address'
                        ||','||'City'
                        ||','||'State Abbreviation'
                        ||','||'Zip Code'
                        ||','||'Zip Code Extension'
                        ||','||'Blank'
                        ||','||'Foreign State / Province'
                        ||','||'Foreign Postal Code'
                        ||','||'Country Code'
                        ||','||'Submitter Name'
                        ||','||'Location Address'
                        ||','||'Delivery Address'
                        ||','||'City'
                        ||','||'State Abbreviation'
                        ||','||'Zip Code'
                        ||','||'Zip Code Extension'
                        ||','||'Blank'
                        ||','||'Foreign State / Province'
                        ||','||'Foreing Postal Code'
                        ||','||'Country Code'
                        ||','||'Contact Name'
                        ||','||'Contact Phone Number'
                        ||','||'Contact Phone Extension'
                        ||','||'Blank'
                        ||','||'Contact E-Mail'
                        ||','||'Blank'
                        ||','||'Contact FAX'
                        ||','||'Preferred Method Of Problem Notification Code'
                        ||','||'Preparer Code'
                        ||','||'Blank';
     hr_utility.trace('value of header string = '||header_string);
     return header_String;
END mmrf_format_ra_record_header;

--
-- This function format Employer Record (i.e. RE) record header
--
FUNCTION mmrf_format_re_record_header(
                                      p_report_type          IN  varchar2,
                                      p_format               IN  varchar2,
                                      p_report_qualifier     IN  varchar2,
                                      p_record_name          IN  varchar2
                 )  RETURN VARCHAR2
IS
-- Local Variables
  header_string    varchar2(6000);
  l_header_9       varchar2(3000);
BEGIN
     hr_utility.trace('Formatting RE record header');
     If ((p_report_qualifier = 'PA') OR
         (p_report_qualifier = 'PA_PHILA')) THEN
          l_header_9 := 'Third Party Sick Pay Indicator'
                          ||','||'PA 8-digit Account Number';
     Elsif (p_report_qualifier = 'MD') Then
          l_header_9 := 'Third Party Sick Pay Indicator'
                        || ',' || 'MW508 ER - Tax Year'
                        || ',' || 'MW508 ER ID'
                        || ',' || 'MW508 Central Registration Number'
                        || ',' || 'MW508 - ER Name'
                        || ',' || 'MW508 ER St Address'
                        || ',' || 'MW508 City'
                        || ',' || 'MW508 State'
                        || ',' || 'MW508 Zipcode'
                        || ',' || 'MW508 Zip Extension'
                        || ',' || 'MW508 ER Number of W2s'
                        || ',' || 'MW508 Total amt of taxes w/h'
                        || ',' || 'MW508 ER Total Tax w/h'
                        || ',' || 'MW508 ER Credits'
                        || ',' || 'MW508 ER Amt Tax Due'
                        || ',' || 'MW508 ER Amt Balance Due'
                        || ',' || 'MW508 ER Amt Overpayment'
                        || ',' || 'MW508 ER Amt Credit'
                        || ',' || 'MW508 ER Amt Refunded'
                        || ',' || 'MW508 Gross Payroll'
                        || ',' || 'ER State Pickup Amt'
                        || ',' || 'ER Rep Name'
                        || ',' || 'ER Rep Title'
                        || ',' || 'ER Rep Date'
                        || ',' || 'ER Rep Phone Number'
                        || ',' || 'ER Total File Indicator' ;
     Else
        l_header_9 := 'Third Party Sick Pay Indicator'
                                     ||','||'Blank';
     End if;
     header_string :=
                 'Record Identifier'
                 ||','||'Tax Year'
                 ||','||'Agent Indicator Code'
                 ||','||'Employer / Agent Employer Identification Number (EIN)'
                 ||','||'Agent For EIN'
                 ||','||'Terminating Business Indicator'
                 ||','||'Establishment Number'
                 ||','||'Other EIN'
                 ||','||'Employer Name'
                 ||','||'Location Address'
                 ||','||'Delivery Address'
                 ||','||'City'
                 ||','||'State Abbreviation'
                 ||','||'Zip Code'
                 ||','||'Zip Code Extension'
                 ||','||'Blank'
                 ||','||'Foreign State / Province'
                 ||','||'Foreign Postal Code'
                 ||','||'Country Code'
                 ||','||'Employment Code'
                 ||','||'Tax Jurisdiction Code'
                 ||','||l_header_9;
     hr_utility.trace('value of header string = '||header_string);
     return header_string;
END mmrf_format_re_record_header;

--
-- This function formats Wage Record (i.e. RW) record header
--
FUNCTION mmrf_format_rw_record_header(
                                      p_report_type          IN  varchar2,
                                      p_format               IN  varchar2,
                                      p_report_qualifier     IN  varchar2,
                                      p_record_name          IN  varchar2
                                     ) RETURN VARCHAR2
IS
-- Local Variables
  header_string    varchar2(3000);
BEGIN
     hr_utility.trace('Formatting RW record header');
     header_string :=
          'Record Identifier'
          ||','||'Social Security Number'
          ||','||'Employee First Name'
          ||','||'Employee Middle Name or Initial'
          ||','||'Employee Last Name'
          ||','||'Suffix'
          ||','||'Location Address'
          ||','||'Delivery Address'
          ||','||'City'
          ||','||'State Abbreviation'
          ||','||'Zip Code'
          ||','||'Zip Code Extension'
          ||','||'Blank'
          ||','||'Foreign State / Province'
          ||','||'Foreign Postal Code'
          ||','||'Country Code'
          ||','||'Wages Tips And Other Compensation'
          ||','||'Federal Income Tax Withheld'
          ||','||'Social Security Wages'
          ||','||'Social Security Tax Withheld'
          ||','||'Medicare Wages And Tips'
          ||','||'Medicare Tax Withheld'
          ||','||'Social Security Tips'
          ||','||'Advance Earned Income Credit'
          ||','||'Dependent Care Benefits'
          ||','||'Deferred Compensation Contributions to Section 401(k)'
          ||','||'Deferred Compensation Contributions to Section 403(b)'
          ||','||'Deferred Compensation Contributions to Section 408(k)(6)'
          ||','||'Deferred Compensation Contributions to Section 457(b)'
          ||','||'Deferred Compensation Contributions to Section 501(c)(18)(D)'
        --||','||'Military EE''s Basic Quarters Subsistence and Combat Pay'
          ||','||'Blank'
          ||','||'Non-Qual. plan Sec.457 Distributions or Contributions'
	-- Bug 3680056 - New field
          ||','||'Employer Contributions to Health Savings Account'
          ||','||'Non-Qual. plan NOT Section 457 Distributions or Contributions'
    -- Bug 4391218
          ||','||'Non-Taxable Combat Pay'
          ||','||'Blank'
          ||','||'Employer Cost of Premiums for GTL> $50k'
          ||','||'Income From Exercise of Nonqualified Stock Options'
    -- Bug 4391218
          ||','||'Deferrals Under a Section 409A Non-Qualified Deferred Comp Plan'
    -- Bug 5256745
          ||','||'Designated Roth Contrib. To Sec. 401(k) Plan'
          ||','||'Designated Roth Contrib. Und Sec. 403(b) Salary Reduction Agreement'
          ||','||'Blank'
          ||','||'Statutory Employee Indicator'
          ||','||'Blank'
          ||','||'Retirement Plan Indicator'
          ||','||'Third-Party Sick Pay Indicator'
          ||','||'Blank';
     hr_utility.trace('value of formatted header string = '||header_string);
     return header_string;
END mmrf_format_rw_record_header;

--
-- This function formats Puertorico based Wage Record (i.e. RO) record header
--
FUNCTION mmrf_format_ro_record_header(
                   p_report_type          IN  varchar2,
                   p_format               IN  varchar2,
                   p_report_qualifier     IN  varchar2,
                   p_record_name          IN  varchar2
                 )  RETURN VARCHAR2
IS
-- Local Variables
  header_string    varchar2(3000);
BEGIN
     hr_utility.trace('Formatting RO record header');
     header_string :=
          'Record Identifier'
          ||','||'Blank'
          ||','||'Allocated Tips'
          ||','||'Uncollected Employee Tax on Tips'
          ||','||'Medical Savings Account'
          ||','||'Simple Retirement Account'
          ||','||'Qualified Adoption Expenses'
          ||','||'Uncollected Social Security or RRTA Tax on GTL'
          ||','||'Uncollected Medicare Tax on GTL'
      -- Bug 4391218
          ||','||'Income Under Section 409A on a Non-Qualified Deferred Comp Plan'
          ||','||'Blank'
          ||','||'Civil Status'
          ||','||'Spouse''s Social Security Number (SSN)'
          ||','||'Wages Subject to Puerto Rico Tax'
          ||','||'Commissions Subject to Puerto Rico Tax'
          ||','||'Allowances Subject to Puerto Rico Tax'
          ||','||'Tips Subject to Puerto Rico Tax'
          ||','||'Total Wages  Commissions  Tips  and Allowances Subject to Puerto Rico Tax'
          ||','||'Puerto Rico Tax Withheld'
          ||','||'Retirement Fund Annual Contributions'
          ||','||'Blank'
          ||','||'Total Wages  Tips and other Compensation Subject to Virgin Islands  or Guam  or American Samoa  or Northern Mariana Islands Income Tax'
          ||','||'Virgin Islands  or Guam  or American Samoa  or Northern Mariana Islands Income Tax Withheld'
          ||','||'Blank';
     hr_utility.trace('value of formatted header string = '||header_string);
     return header_string;
END mmrf_format_ro_record_header;

--
-- This function formats State Wage Record (i.e. RS) record header
--
FUNCTION mmrf_format_w2_rs_rec_header(
                   p_report_type          IN  varchar2,
                   p_format               IN  varchar2,
                   p_report_qualifier     IN  varchar2,
                   p_record_name          IN  varchar2,
                   p_input_1              IN  varchar2
                 )  RETURN VARCHAR2
IS
-- Local Variables
  header_string    varchar2(3000);

  l_header_20     varchar2(900);
  l_header_21     varchar2(900);
  -- Bug 3936924
  l_header_25     varchar2(900);
  l_report_format varchar2(15);
  l_header_29     varchar2(900);
  -- Bug 4014356
  l_header_30     varchar2(900);
  l_header_34     varchar2(900);
  l_name_header   varchar2(900);
  --Bug 3180532
  l_header_17     varchar2(900);

BEGIN
   hr_utility.trace('Formatting W2 RS record header');
   l_report_format := p_input_1;
   l_name_header := 'Employee First Name'
                                     ||','||'Employee Middle Name or Initial'
                                     ||','||'Employee Last Name';
   l_header_20 := 'State Quarterly Unemployment Insurance Total Wages';
   l_header_21 := 'State Quarterly Unemployment Total Taxable Wages';
   l_header_25 := 'State Employer Account Number';

/* Bug 3180532
   l_header_17
   For Indiana, only 'Federal Advanced EIC' is reqd
   'Country Code', 'Optional Code' and 'Reporting Period' not reqd
   For other states these 3 strings are combined in l_header_17 */
   IF p_report_qualifier = 'IN' THEN
      l_header_17 := 'Federal Advanced EIC';
   ELSE
      l_header_17 := 'Country Code'
             ||','||'Optional Code'
             ||','||'Reporting Period';
   END IF;

   IF p_report_qualifier = 'AL' THEN
      l_header_29 := 'FIT withheld';
      -- Bug 3936924  - New columns headers
      l_header_25 := l_header_25 || ',' ||
                     'Federal Employer Account Number';
   ELSIF p_report_qualifier = 'MD' THEN
      l_header_29 := 'Maryland state pickup for MD state retirement system';
   ELSIF p_report_qualifier = 'OH' THEN
      l_header_29 := 'Total Wages Tips and Other Compenstaion';
   ELSE
      l_header_29 := 'Other State Data';
   END IF;

   IF p_report_qualifier = 'MS' THEN
      l_header_25 := l_header_25 || ',' ||
                     'Federal Employer Account Number';
   END IF;

   -- Bug 4014356
   IF p_report_qualifier = 'NJ' THEN
      l_header_30 := 'MIF';
   ELSE
      l_header_30 := 'Tax Type Code';
   END IF;

   IF p_report_qualifier = 'KY' THEN
      l_header_34 :=
          'Amount of tax credit for KY rural economic dev. asst.'
          ||','||'Amount of tax credit for KY jobs dev. act'
          ||','||
            'Amount of tax credit for KY industrial revitalization authority'
          ||','||'Amount of tax credit for KY industrial devep. authority'
          ||','||'Blank';
   ELSIF p_report_qualifier = 'NJ' THEN
      l_header_34 := 'Disability Plan Type Code'
          ||','||'Private Disability Plan'
          ||','||'Unemployment Insurance Tax'
          ||','||'SDI Withheld'
          ||','||'Pension Plan Indicator'
          ||','||'Deferred Comp. Indicator '
          ||','||'Deferred Compensation'
          ||','||'Blank';
   ELSIF p_report_qualifier = 'MD' THEN
      l_header_34 := 'MD Central Registration Number'
          ||','||'Wages Tips and Other Compensation'
          ||','||'FIT w/h'
          ||','||'Blank';
   ELSIF p_report_qualifier = 'ME' THEN
      l_header_34 := 'State Withheld a/c Number'
          ||','||'Blank';
   ELSIF p_report_qualifier = 'MA' THEN
      l_header_34 := 'FICA + MCR w/h '
          ||','||'Blank';
   -- Bug 3936924
   ELSIF p_report_qualifier = 'AL' THEN
      l_header_34 := 'Payment Year'
          ||','||'Blank';
   -- Bug 3180532 : For Indiana 'State Advanced EIC' and 'State Advanced EIC ID'
   ELSIF p_report_qualifier = 'IN' THEN
      l_header_34 := 'State Advanced EIC'
          ||','||'State Advanced EIC ID';
   ELSIF p_report_qualifier = 'MS' THEN
      l_header_34 := '1099 Income'
          ||','||'Payment Year';
   END IF;

   header_string:=
           'Record Identifier'
           ||','||'State Code'
           ||','||'Taxing Entity Code'
           ||','||'Social Security Number (SSN)'
           ||','||l_name_header
           ||','||'Suffix'
           ||','||'Location Address'
           ||','||'Delivery Address'
           ||','||'City'
           ||','||'State Abbreviation'
           ||','||'Zip Code'
           ||','||'Zip Code Extension'
           ||','||'Blank'
           ||','||'Foreign State / Province'
           ||','||'Foreign Postal Code'
           ||','|| l_header_17
           ||','|| l_header_20
           ||','|| l_header_21
           ||','||'Number of Weeks Worked'
           ||','||'Date First Employed'
           ||','||'Date of Separation'
           ||','||'Blank'
           ||','|| l_header_25
           ||','||'Blank'
           ||','||'State Code'
           ||','||'State Taxable Wages'
           ||','||'SIT Withheld'
           ||','||l_header_29
           ||','||l_header_30
           ||','||'Local Taxable Wages'
           ||','||'Local Income Tax Withheld'
           ||','||'State Control Number'
           ||','||l_header_34;
   hr_utility.trace('value of formatted W2 RS Record header string = '||header_string);
   return header_string;
END mmrf_format_w2_rs_rec_header;

--
-- This function formats State Wage Record (i.e. RO) record header
--
FUNCTION mmrf_format_sqwl_rs_rec_header(
                                           p_report_type          IN  varchar2,
                                           p_format               IN  varchar2,
                                           p_report_qualifier     IN  varchar2,
                                           p_record_name          IN  varchar2,
                                           p_input_1              IN  varchar2
                                          )  RETURN VARCHAR2
IS
-- Local Variables
  header_string    varchar2(3000);
  l_report_format varchar2(15);
  l_header_20     varchar2(900);
  l_header_21     varchar2(900);
  l_header_28     varchar2(900);
  l_header_29     varchar2(900);
  l_header_34     varchar2(900);
  l_name_header   varchar2(900);

BEGIN
   hr_utility.trace('Formatting SQWL RS record header');
   hr_utility.trace('p_report_qualifier = '|| p_report_qualifier);
   l_report_format := p_input_1;
   IF p_report_qualifier in ( 'LA_SQWL','AK_SQWL') THEN /*Bug:2337613 */
      l_name_header := 'Employee Last Name'||','||'Employee First Name'
                       ||','||'Employee Middle Name or Initial';
   ELSE
      l_name_header := 'Employee First Name'
                       ||','||'Employee Middle Name or Initial'
                       ||','||'Employee Last Name';
   END IF;

   If p_report_qualifier ='CA_SQWL' Then
      If l_report_format is not null and
         l_report_format = 'RTM' Then
         l_header_20 := 'SDI/SUI Total Wages';
         l_header_21 := 'SUI Total Taxable Wages';
      Else
         l_header_20 := 'State Quarterly Unemployment Insurance Total Wages';
         l_header_21 := 'State Quarterly Unemployment Total Taxable Wages';
      End If;
   Else
      l_header_20 := 'State Quarterly Unemployment Insurance Total Wages';
      l_header_21 := 'State Quarterly Unemployment Total Taxable Wages';
   End If;

   l_header_29 := 'Other State Data';

   l_header_34 := 'Supplemental Data 1'
                  ||','||'Supplemental Data 2'
                  ||','||'Blank';

  IF p_report_qualifier = 'NY_SQWL' THEN   /*2682247*/

    l_header_28 := 'Q4 only YTD FIT Wages'
                   ||','||'Q4 only YTD SIT and CIT';
  ELSE

    l_header_28 := 'State Taxable Wages'
                   ||','||'SIT Withheld';

  END IF;

   hr_utility.trace('l_header_28 = '|| l_header_28);

   IF p_report_qualifier = 'WA_SQWL' THEN
      header_string:=
           'Employer Identification Number(EIN)'
           ||','||'Social Security Number (SSN)'
           ||','||'Name'
           ||','||'Quarterly Hours'
           ||','||'Quarterly Gross Wages';
      hr_utility.trace(header_string);
   ELSIF p_report_qualifier = 'AK_SQWL' THEN
      header_string:=
           'Transaction Code'
           ||','||'Employer Account Number'
           ||','||'Year'
           ||','||'Quarter'
           ||','||'Social Security Number (SSN)'
           ||','||l_name_header
           ||','||l_header_20
           ||','||'Project Code'
           ||','||'Hourly Rate'
           ||','||'Occupational Code or Title'
           ||','||'Area Code' ;
	   /* Bug # 4554387
           ||','||'Batch Number'
           ||','||'Batch Item';
	   */
      hr_utility.trace(header_string);
   ELSIF p_report_qualifier = 'NM_SQWL' THEN
      header_string:=
           'Social Security Number (SSN)'
           ||','||'Quater Gross Wages'
           ||','||'Quarter Excess Wages'
           ||','||'Withholding'
           ||','||'WorkersComp' ;

      hr_utility.trace(header_string);
   ELSIF p_report_qualifier = 'FL_SQWL' THEN --Added for Bug#9356178
      header_string:=
           'Record Identifier'
           ||','||'State Code'
           ||','||'Taxing Entity Code'
           ||','||'Social Security Number (SSN)'
           ||','||l_name_header
           ||','||'Suffix'
           ||','||'Location Address'
           ||','||'Delivery Address'
           ||','||'City'
           ||','||'State Abbreviation'
           ||','||'Zip Code'
           ||','||'Zip Code Extension'
           ||','||'Blank'
           ||','||'Foreign State / Province'
           ||','||'Foreign Postal Code'
           ||','||'Country Code'
           ||','||'Optional Code'
           ||','||'Reporting Period'
           ||','|| l_header_20
           ||','|| l_header_21
           ||','||'Number of Weeks Worked'
           ||','||'Date First Employed'
           ||','||'Date of Separation'
           ||','||'Blank'
           ||','||'State Employer Account Number'
           ||','||'Blank'
           ||','||'State Code'
           ||','|| l_header_28
           ||','||l_header_29
           ||','||'Tax Type Code'
           ||','||'Local Taxable Wages'
           ||','||'Local Income Tax Withheld'
           ||','||'State Control Number'
           ||','||l_header_34
	   ||','||'Actual State Quarterly Unemployment Total Taxable Wages' ;
   ELSE
      header_string:=
           'Record Identifier'
           ||','||'State Code'
           ||','||'Taxing Entity Code'
           ||','||'Social Security Number (SSN)'
           ||','||l_name_header
           ||','||'Suffix'
           ||','||'Location Address'
           ||','||'Delivery Address'
           ||','||'City'
           ||','||'State Abbreviation'
           ||','||'Zip Code'
           ||','||'Zip Code Extension'
           ||','||'Blank'
           ||','||'Foreign State / Province'
           ||','||'Foreign Postal Code'
           ||','||'Country Code'
           ||','||'Optional Code'
           ||','||'Reporting Period'
           ||','|| l_header_20
           ||','|| l_header_21
           ||','||'Number of Weeks Worked'
           ||','||'Date First Employed'
           ||','||'Date of Separation'
           ||','||'Blank'
           ||','||'State Employer Account Number'
           ||','||'Blank'
           ||','||'State Code'
           ||','|| l_header_28
           ||','||l_header_29
           ||','||'Tax Type Code'
           ||','||'Local Taxable Wages'
           ||','||'Local Income Tax Withheld'
           ||','||'State Control Number'
           ||','||l_header_34;
   END IF;
   hr_utility.trace('value of formatted SQWL RS Record header string = '||header_string);
   return header_string;
END mmrf_format_sqwl_rs_rec_header;


--
-- This function formats Total Wage Record (i.e. RSSSUM) record header
--
FUNCTION mmrf_format_rssumm_rec_header(
                                      p_report_type          IN  varchar2,
                                      p_format               IN  varchar2,
                                      p_report_qualifier     IN  varchar2,
                                      p_record_name          IN  varchar2
                                     )  RETURN VARCHAR2
IS
-- Local Variables
  header_string    varchar2(3000);
  l_report_format varchar2(15);
  l_header_3     varchar2(900);
  l_header_4     varchar2(900);
  l_header_5     varchar2(900);
  l_header_8     varchar2(900);
  l_header_9     varchar2(900);
  l_records      varchar2(900);
  l_name_header   varchar2(900);

BEGIN
   hr_utility.trace('Formatting RSSSUMM record header');

   IF (p_report_qualifier = 'NV') THEN
      l_records := 'Number of RS Records';
      l_header_3 := 'State Taxable Wages';
      l_header_4 := 'State Income Tax Withheld';
   ELSE
      l_records := 'Number of RW Records';
      l_header_3 := 'Wages Tips and other Compensation';
      l_header_4 := 'Federal Income Tax Withheld';
   END IF;

   IF p_report_qualifier = 'RI' THEN
      l_records:= 'Number of RS Records';
      l_header_5 := 'State Taxable Wages';
      l_header_9 := 'State Income Tax Withheld';
   ELSE
      l_header_5 := 'Social Security Wages';
      l_header_9 := 'Social Security Tips';
   END IF;

   IF p_report_qualifier = 'MA' THEN
      l_header_8 := 'Total FICA + MRC withheld';
   ELSE
      l_header_8 := 'Medicare Tax Withheld';
   END IF;

   header_string:=
      'Record Identifier'
      ||','||'State Code'
      ||','||'Taxing Entity Code/State Rec Type'
      ||','||'Blank'
      ||','||'Federal Tax ID Number'
      ||','||'Blank'
      ||','||'State Employer Acct Number'
      ||','||'Blank'
      ||','||'Reporting Period'
      ||','||'Blank'
      ||','||'Total Number of Workers on Report'
      ||','||'Blank'
      ||','||'Total Wages Paid This Quarter (Including Tips)'
      ||','||'Blank'
      ||','||'Nontaxable Wages'
      ||','||'Blank'
      ||','||'Taxable Wages Paid This Quarter'
      ||','||'Blank'
      ||','||'Blank'
      ||','||'Month(1) employment for employer'
      ||','||'Blank'
      ||','||'Month(2) employment for employer'
      ||','||'Blank'
      ||','||'Month(3) employment for employer'
      ||','||'Blank'
      ||','||'No Workers/No Wages Indicator'
      ||','||'Blank';
      return header_String;
      hr_utility.trace('value of header string = '||header_string);
END mmrf_format_rssumm_rec_header;

--
-- This function formats Total Wage Record (i.e. RT) record header
--
FUNCTION mmrf_format_rt_record_header(
                                      p_report_type          IN  varchar2,
                                      p_format               IN  varchar2,
                                      p_report_qualifier     IN  varchar2,
                                      p_record_name          IN  varchar2
                                     )  RETURN VARCHAR2
IS
-- Local Variables
  header_string    varchar2(3000);
  l_report_format varchar2(15);
  l_header_3     varchar2(900);
  l_header_4     varchar2(900);
  l_header_5     varchar2(900);
  l_header_8     varchar2(900);
  l_header_9     varchar2(900);
  l_records      varchar2(900);
  l_name_header   varchar2(900);

BEGIN
   hr_utility.trace('Formatting RT record header');

   IF ( (p_report_qualifier = 'CT') OR
        (p_report_qualifier = 'MA') ) THEN
      l_records := 'Number of RS Records';
      l_header_3 := 'State Taxable Wages';
      l_header_4 := 'State Income Tax Withheld';
   ELSE
      l_records := 'Number of RW Records';
      l_header_3 := 'Wages Tips and other Compensation';
      l_header_4 := 'Federal Income Tax Withheld';
   END IF;

   IF p_report_qualifier = 'RI' THEN
      l_records:= 'Number of RS Records';
      l_header_5 := 'State Taxable Wages';
      l_header_9 := 'State Income Tax Withheld';
   ELSE
      l_header_5 := 'Social Security Wages';
      l_header_9 := 'Social Security Tips';
   END IF;

   IF p_report_qualifier = 'MA' THEN
      l_header_8 := 'Total FICA + MRC withheld';
   ELSE
      l_header_8 := 'Medicare Tax Withheld';
   END IF;

   header_string:=
      'Record Identifier'
      ||','||l_records
      ||','||l_header_3
      ||','||l_header_4
      ||','||l_header_5
      ||','||'Social Security Tax Withheld'
      ||','||'Medicare Wages And Tips'
      ||','||l_header_8
      ||','||l_header_9
      ||','||'Advance Earned Income Credit'
      ||','||'Dependent Care Benefits'
      ||','||'Deferred Compensation Contributions to Section 401(k)'
      ||','||'Deferred Compensation Contributions to Section 403(b)'
      ||','||'Deferred Compensation Contributions to Section 408(k)(6)'
      ||','||'Deferred Compensation Contributions to Section 457(b)'
      ||','||'Deferred Compensation Contributions to Section 501(c)(18)(D)'
    --||','||'Military EE''s Basic Quarters Subsistence And Combat Pay'
      ||','||'Blank'
      ||','||'Non-Qual. Plan Sec.457 Distributions or Contributions'
    -- Bug 3680056 - New field
      ||','||'Employer Contributions to Health Savings Account'
      ||','||'Non-Qual. Plan NOT Section 457 Distributions or Contributions'
    -- Bug 4391218
      ||','||'Non-Taxable Combat Pay'
      ||','||'Blank'
      ||','||'Employer Cost of Premiums for GTL> $50k'
      ||','||'Income Tax Withheld by Third-Party Payer'
      ||','||'Income from the Exercise of Nonqualified Stock Options'
    -- Bug 4391218
      ||','||'Deferrals Under a Section 409A Non-Qualified Deferred Plan Comp'
    -- Bug 5256745
      ||','||'Designated Roth Contrib. To Sec. 401(k) Plan'
      ||','||'Designated Roth Contrib. Und Sec. 403(b) Salary Reduction Agreement'
      ||','||'Blank';
      return header_String;
      hr_utility.trace('value of header string = '||header_string);
END mmrf_format_rt_record_header;

--
-- This function formats Total Puertorico Wage Record (i.e. RU) record header
--
FUNCTION mmrf_format_ru_record_header(
                                      p_report_type          IN  varchar2,
                                      p_format               IN  varchar2,
                                      p_report_qualifier     IN  varchar2,
                                      p_record_name          IN  varchar2
                                     )  RETURN VARCHAR2
IS
-- Local Variables
  header_string    varchar2(3000);

BEGIN
   hr_utility.trace('Formatting RU record header');
   header_string:=
     'Record Identifier'
     ||','||'Number of RO Records'
     ||','||'Allocated Tips'
     ||','||'Uncollected Employee Tax on Tips'
     ||','||'Medical Savings Account'
     ||','||'Simple Retirement Account'
     ||','||'Qualified Adoption Expenses'
     ||','||'Uncollected Social Security Tax on GTL'
     ||','||'Uncollected Medicare Tax On GTL'
   -- Bug 4391218
     ||','||'Income Under Section 409A on a Non-Qualified Deferred Comp Plan'
     ||','||'Blank'
     ||','||'Wages Subject to Puerto Rico Tax'
     ||','||'Commissions Subject to Puerto Rico Tax'
     ||','||'Allowances Subject to Puerto Rico Tax'
     ||','||'Tips Subject to Puerto Rico Tax'
     ||','||'Total Wages Commissions  Tips  And Allowances Subject to Puerto Rico Tax'
     ||','||'Puerto Rico Tax Withheld'
     ||','||'Retirement Fund Annual Contributions'
     ||','||'Total Wages Tips And Other Compensation Subject to Virgin Islands or Guam or American Samoa or Northern Mariana Islands Income Tax'
     ||','||'Virgin Islands  or Guam  Or American Samoa  or Northern Mariana Islands Income Tax Withheld'
     ||','||'Blank';
   hr_utility.trace('value of formatted header string = '||header_string);
   return header_string;
END mmrf_format_ru_record_header;

--
-- This function formats File Total Record (i.e. RF) record header
--
FUNCTION mmrf_format_rf_record_header(
                                      p_report_type          IN  varchar2,
                                      p_format               IN  varchar2,
                                      p_report_qualifier     IN  varchar2,
                                      p_record_name          IN  varchar2
                                     )  RETURN VARCHAR2
IS
-- Local Variables
  l_records        varchar2(900);
  header_string    varchar2(3000);

BEGIN
   hr_utility.trace('Formatting RF record header');
   IF p_report_qualifier = 'PA' THEN
      l_records := 'Blank'
                   ||','||'Number of RS Records'
                   ||','||'PA Taxable Wages'
                   ||','||'PA tax withheld';

   ELSIF p_report_qualifier = 'CT' THEN
      l_records := 'Number of RS Records'
                   ||','||'Blank'
                   ||','||'State Taxable Wages'
                   ||','||'Blank'
                   ||','||'SIT withheld'
                   ||','||'Blank';
   ELSIF ((p_report_qualifier = 'IN') OR
          (p_report_qualifier = 'MA') OR
          (p_report_qualifier = 'RI') OR
          (p_report_qualifier = 'VA')) THEN
      l_records := 'Blank'
                   ||','||'Number of RS Records'
                   ||','||'Blank';
   ELSE
      l_records := 'Blank'
                   ||','||'Number of RW Records'
                   ||','||'Blank';
   END IF;
   header_string:= 'Record Identifier'
                   ||','||l_records;

   hr_utility.trace('value of header string = '||header_string);
   return header_string;
END mmrf_format_rf_record_header;

--
-- This function formats Wage Record (i.e. RCW) record header
--
FUNCTION mmrf2_format_rcw_record_header(
                                      p_report_type          IN  varchar2,
                                      p_format               IN  varchar2,
                                      p_report_qualifier     IN  varchar2,
                                      p_record_name          IN  varchar2
                                     ) RETURN VARCHAR2
IS
-- Local Variables
  header_string    varchar2(2500);
BEGIN

     hr_utility.trace('Formatting RCW record header');
     header_string :=
          'Record Identifier'
          ||','||'(Orig) SSN'
          ||','||'(Correct) SSN'
          ||','||'(Orig) First Name'
          ||','||'(Orig) Middle Name or Initial'
          ||','||'(Orig) Last Name'
          ||','||'(Correct) First Name'
          ||','||'(Correct) Middle Name or Initial'
          ||','||'(Correct) Last Name'
          ||','||'Location Address'
          ||','||'Delivery Address'
          ||','||'City'
          ||','||'State Abbreviation'
          ||','||'Zip Code'
          ||','||'Zip Code Extension'
          ||','||'Blank'
          ||','||'Foreign State / Province'
          ||','||'Foreign Postal Code'
          ||','||'Country Code'
          ||','||'(Orig) Wages Tips And Other Compensation'
          ||','||'(Correct) Wages Tips And Other Compensation'
          ||','||'(Orig) FIT Withheld'
          ||','||'(Correct) FIT Withheld'
          ||','||'(Orig) SS Wages'
          ||','||'(Correct) SS Wages'
          ||','||'(Orig) SS Tax Withheld'
          ||','||'(Correct) SS Tax Withheld'
          ||','||'(Orig) Medicare Wages And Tips'
          ||','||'(Correct) Medicare Wages And Tips'
          ||','||'(Orig) Medicare Tax Withheld'
          ||','||'(Correct) Medicare Tax Withheld'
          ||','||'(Orig) SS Tips'
          ||','||'(Correct) SS Tips'
          ||','||'(Orig) Advance EIC'
          ||','||'(Correct) Advance EIC'
          ||','||'(Orig) Dependent Care Benefits'
          ||','||'(Correct) Dependent Care Benefits'
          ||','||'(Orig) Def. CompContrib to Sec 401(k)'
          ||','||'(Correct) Def. CompContrib to Sec 401(k)'
          ||','||'(Orig) Def. CompContrib to Sec 403(b)'
          ||','||'(Correct) Def. CompContrib to Sec 403(b)'
          ||','||'(Orig) Def. CompContrib to Sec 408(k)(6)'
          ||','||'(Correct) Def. CompContrib to Sec 408(k)(6)'
          ||','||'(Orig) Def. CompContrib to Sec 457(b)'
          ||','||'(Correct) Def. CompContrib to Sec 457(b)'
          ||','||'(Orig) Def. CompContrib to Sec (501)(c)(18)(D)'
          ||','||'(Correct) Def. CompContrib to Sec (501)(c)(18)(D)'
          ||','||'(Orig) Total Def. CompContrib '
          ||','||'(Correct) Total Def. CompContrib '
          ||','||'(Orig) Military EE''s Basic Qtrs Subsistence and Combat Pay'
          ||','||'(Correct) Military EE''s Basic Qtrs Subsistence and Combat Pay'
          ||','||'(Orig) Non-Qual. plan Sec.457 Dist or Contrib'
          ||','||'(Correct) Non-Qual. plan Sec.457 Dist or Contrib'
          ||','||'(Orig) ER Contribution to HSA'
          ||','||'(Correct) ER Contribution to HSA'
          ||','||'(Orig) Non-Qual. plan NOT Section 457 Dist or Contrib'
          ||','||'(Correct) Non-Qual. plan NOT Section 457 Dist or Contrib'
          ||','||'(Orig) Nontaxable Combat Pay'
          ||','||'(Correct) Nontaxable Combat Pay'
          --||','||'Blank'
          ||','||'(Orig) Employer Cost of Premiums for GTL> $50k'
          ||','||'(Correct) Employer Cost of Premiums for GTL> $50k'
          ||','||'(Orig) Income From Exercise of Nonqual Stock Options'
          ||','||'(Correct) Income From Exercise of Nonqual Stock Options'
          ||','||'(Orig) Deferrals Under Section 409A'
          ||','||'(Correct) Deferrals Under Section 409A'
          ||','||'(Orig) Designated Roth Contr. to 401k Plan' /* 5358272 */
          ||','||'(Correct) Designated Roth Contr. to 401k Plan'
          ||','||'(Orig) Designated Roth Contr. to 403b Plan'
          ||','||'(Correct) Designated Roth Contr. to 403b Plan'
          --||','||'Blank'
          ||','||'(Orig) Statutory Employee Indicator'
          ||','||'(Correct) Statutory Employee Indicator'
          ||','||'(Orig) Retirement Plan Indicator'
          ||','||'(Correct) Retirement Plan Indicator'
          ||','||'(Orig) Third-Party Sick Pay Indicator'
          ||','||'(Correct) Third-Party Sick Pay Indicator'
          ||','||'Blank';
     hr_utility.trace('length of formatted header string = '|| to_char(length(header_string)) );
     --hr_utility.trace('value of formatted header string = '||header_string);
     return header_string;
END mmrf2_format_rcw_record_header;


--
-- This function formats Puertorico based Wage Record (i.e. RCO) record header
--
FUNCTION mmrf2_format_rco_record_header(
                   p_report_type          IN  varchar2,
                   p_format               IN  varchar2,
                   p_report_qualifier     IN  varchar2,
                   p_record_name          IN  varchar2
                 )  RETURN VARCHAR2
IS
-- Local Variables
  header_string    varchar2(3000);
BEGIN
     hr_utility.trace('Formatting RCO record header');
     header_string :=
          'Record Identifier'
          ||','||'Blank'
          ||','||'(Orig) Allocated Tips'
          ||','||'(Correct) Allocated Tips'
          ||','||'(Orig) Uncollected Employee Tax on Tips'
          ||','||'(Correct) Uncollected Employee Tax on Tips'
          ||','||'(Orig) Medical Savings Account'
          ||','||'(Correct) Medical Savings Account'
          ||','||'(Orig) Simple Retirement Account'
          ||','||'(Correct) Simple Retirement Account'
          ||','||'(Orig) Qualified Adoption Expenses'
          ||','||'(Correct) Qualified Adoption Expenses'
          ||','||'(Orig) Uncollected Social Security or RRTA Tax on GTL > $50k'
          ||','||'(Correct) Uncollected Social Security or RRTA Tax on GTL > $50k'
          ||','||'(Orig) Uncollected Medicare Tax on GTL > $50k'
          ||','||'(Correct) Uncollected Medicare Tax on GTL > $50k'
          ||','||'(Orig) Income Under 409A'
          ||','||'(Correct) Income Under 409A';
         -- ||','||'Blank';
     --hr_utility.trace('value of formatted header string = '||header_string);
     return header_string;
END mmrf2_format_rco_record_header;

--
--BEGIN
--hr_utility.trace_on(null,'PRINTHEADER');
END pay_us_mmrf_print_rec_header;
--End of Package Body

/
