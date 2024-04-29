--------------------------------------------------------
--  DDL for Package PAY_GB_MOVDED_EDI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_MOVDED_EDI" AUTHID CURRENT_USER as
/* $Header: pygbmedi.pkh 120.16.12010000.19 2010/01/22 14:30:39 namgoyal ship $ */
--
/*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +============================================================================
 Name
    PAY_GB_MOVDED_EDI
  Purpose
    Package to contol archiver process in the creation of assignment actions
    and then the creation of EDI message files using the magtape process for
    EDI Message Types : P45(3), P46, P46PENNOT
Notes

  History
    10-OCT-2000 S.Robinson 115.0        Date created.
    18-JUN-2001 S.Robinson 115.1        Passing Char_Errors as 'N'
    19-JUN-2001 S.Robinson 115.2        Enforce Character validation for
                                        P45(3), P46 and P46 Pen processes.
    26-JUN-2001 S.Robinson 115.3        Ensure numeric values nvl is passed
                                        as 0 - Bug 1851781.
    20-JUL-2001 S.Robinson 115.4        Removed carriage return from Test
                                        submission parameter in P45_3
                                        header.
    05-MAR-2002 G.Butler   115.5        Altered cursors for UTF8 project.
                                        Added dbdrv lines
    10-JUN-2002 R.Makhija  115.6        Changed cursors to get tax details
                                        from PAYE Details element as
                                        effective of last Run
    08-JUL-2002 R.Makhija  115.7        Changed cursors to look for PAYE
                                        element run results for tax
                                        details first
    06-NOV-2002 BTHAMMIN   115.9        Bug 2657976
                                        Cursors csr_p45_3_assignments
                                        and csr_p46_assignments are
                                        changed. job.name is changet to
                                        display only the selected segment
                                        in Organization Developer DF.
    09-DEC-2002 BTHAMMIN   115.10       Check for enabled and displayed
                                        segments.
    23-DEC-2002 NSUGAVAN   115.11       To be R8.0 compliant, commented out
                                        function get_job_segment as it has been
                                        moved to a different file(pygbjseg.pkh)
                                        Replaced calls to this function in
                                        cursors.
    03-jan-2003 NSUGAVAN   115.12       Modified cursor calls w.r.t change in
					get_job_segment Function change
    08-Jul-2003 AMILLS     115.13       Bug 3038685. Performance tune of
                                        assignments cursors.
    16-DEC-2003 ASENGAR    115.16       BUG 3221422. Removed merge(cartesian) joins
                                        for assignment cursors.
    28-APR-2004 ASENGAR    115.17       BUG 3550468 Changed cursor csr_p46_assignments
                                        using nvl for the case when job is null.
    13-MAY-2004 KTHAMPAN   115.18       BUG 3609354. Use nvl(xx,'NONE') for NI field
                                        in cursor csr_p45_3_assignments,
                                        csr_p46_assignments and csr_p46_pennot_assignments
    04-OCT-2004 AMILLS     115.19       BUG 3850012. Added Ordered Index and Use NL
                                        Hint to csr_p46_assignments.
    05-OCT-2004 AMILLS     115.20       3850012. Also hinted csr_p45_3_assignments,
                                        csr_p46_pennot_assignments.
    13-OCT-2004 ALIKHAR    115.21	Bug 3891351. Changed the cursors
					csr_p45_3_assignments, csr_p46_assignments,
					csr_p46_pennot_assignments to join
  				        assignment table with period of service
				        table based on period_of_service_id column.
    06-JAN-2005 TUKUMAR    115.22       Bugs 4086317,4086331,4086142 : Changed the length
					of display of Employer's PAYE Reference
    13-FEB-2006 TUKUMAR    115.23       Bug 5006451 : P46 Students loan Enhancement.
					Modified cursor csr_p46_assignments
    16-JUN-2006 KTHAMPAN   115.24       Code change for EDI Rollback.
    19-JUN-2006 KTHAMPAN   115.25       Bug 5169434. Substr title to 4 chars for
                                        P46 and P45(3).
    27-JUL-2006 TUKUMAR    115.26       Inlcuded WNU 3.0 cursors: 5398360
    19-DEC-2006 KTHAMPAN   115.27       Fix bug 5719330
    18-JAN-2007 JVARADRA   115.29       Fix bug 5766232, changed the TAX_REF value to uppercase
    30-Oct-2007 ABHGANGU   115.31    6345375  Added cursors
                                                   csr_p45pt_3_header
                                                  ,csr_p45pt_3_assignments
                                                  ,csr_p46_5_pennot_header
                                                  ,csr_p46_5_pennot_assignments
    19-Nov-2007 ABHGANGU   115.32    6345375  Added cursors csr_p46_5_header
                                                         csr_p46_5_assignments
    19-Nov-2007 PARUSIA    115.33    6345375  Changed cursor csr_p45pt_3_assignments
                                              to fetch continue_student_loan_deductions
                                              for P45PT3
    28-Nov-2007 PARUSIA    115.34    6345375  Hardcoded value of URGENT_MARKER in
                                              csr_p45pt_3_header as ' '
    30-Nov-2007 PARUSIA    115.35    6345375  Set default value for NATIONAL_INSURANCE_NUMBER
                                              in csr_p45pt_3_assignments as ' '
    27-DEC-2007 rlingama   115.37    6710197  Modified action_information9 to action_information13
                                              in csr_p45pt_3_assignments,csr_p46_5_pennot_assignments,
					                          csr_p46_5_assignments cursors.
    4-Jan-2007  PARUSIA    115.38    6710229  Selected middle_name also from
                                              csr_p45pt_3_assignments,
                                              csr_p46_5_pennot_assignments,
                                              csr_p46_5_assignments.
    30-Apr-2008 rlingama   115.39    6994632  P45(3) minor enhancements for UK EOY Changes APR08
    29-May-2008 rlingama   115.40    7038073  The PAY_PREVIOUS and TAX_PREVIOUS fields are numeric
                                              hence assigning 0 if the value is NULL
    06-Jun-2008 rlingama   115.41    7038073  Added NVL for pennot address line 2 and 3.
    05-Jul-2008 rlingama   115.42    7157720  Report PREVIOUS_TAX_PAID_NOTIFIED if >=0 in P45PT3
    17-Oct-2008 dwkrishn   115.43    7433580  Added Cursors for 2009 legislative changes.
    20-Oct-2008 dwkrishn   115.44    7433580  Incorporated Review Comments.
    30-Oct-2008 dwkrishn   115.45    7433580  Added P45PT3 Changes.
    03-Nov-2008 dwkrishn   115.46    7433580  Added Pennot Changes.
    03-Nov-2008 dwkrishn   115.47    7433580  Changed Pennot csr_p46_ver6_pennot_assg cursor
    10-Nov-2008 namgoyal   115.48    7540858  Added first_name validation to truncate the name
                                              after space in cursors for P45PT3, P46 and P46 Pennot
					      EDI's version 5 and 6. Also commented the new procedures
					      introduced for In Year filling for 2008-2009.
    10-Nov-2008 namgoyal   115.49             Uncommented the new procedures
                                              introduced for In Year filling for 2008-2009.
    11-NOV-2008 dwkrishn   115.50    7433580  Added Function edi_errors_log,And other edi_errors Types
                                               to incorporate Success Failure sections in O/P File
    20-Nov-2008 namgoyal   115.51    7540858  Removed the changes done in version 48/49
    27-Jan-2009 dwkrishn   115.52    7830717  Total Pay,Total Tax was defaulted to 0 causing issues in
                                              Null comparison in formula.Added decode to make user entered 0
                                              also to be space.
    05-Feb-2009 krreddy    115.53    8216080  Added 2 cursors and a procedure P46EXP_VER6_ACTION_CREATION
                                              to implement P46Expat Notification
    15-Jul-2009 dwkrishn   115.54    8640608  Added hints to cursor csr_p45pt_3_ver6_assignments,csr_p46_ver6_assignments .
    09-Sep-2009 dwkrishn   115.55    8329474  Sender EDI is made case insensitive for P45PT3 and P46 Pennot.
    22-Jan-2010 namgoyal   115.56 9255173,9255183 Updated for P46 V6 and P46 Expat eText reports
============================================================================*/
--
--
--
-- Function to fetch country name for the given country code
--
function get_territory_short_name(prm_name varchar2)
return varchar2;

cursor csr_p45_3_header is
select 'SENDER_ID=P',      nvl(hoi.org_information11,' '),
       'RECEIVER_ID=P',    'INLAND REVENUE',
       'TEST_INDICATOR=P', decode(pay_magtape_generic.get_parameter_value('TEST'),'N',' ','Y','1'),
       'URGENT_MARKER=P',  decode(pay_magtape_generic.get_parameter_value('URGENT'),'N',' ','Y','1'),
       'REQUEST_ID=P',     fnd_number.number_to_canonical(pact.request_id),
       'FORM_TYPE=P',      '5',
       'FORM_TYPE_MEANING=P', 'P45_3',
       'TAX_DIST_NO=P',    nvl(substr(hoi.org_information1,1,3),' '),
       'TAX_DIST_REF=P',   nvl(upper(substr(ltrim(substr(hoi.org_information1,4,11),'/'),1,10)),' '),
       'TAX_DISTRICT=P',   nvl(upper(hoi.org_information2),' '),
       'EMPLOYERS_ADDRESS_LINE=P', nvl(upper(hoi.org_information4),' '),
       'EMPLOYERS_NAME=P', nvl(upper(hoi.org_information3),' ')
from   pay_payroll_actions pact,
       hr_organization_information hoi
where  pact.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and    pact.business_group_id = hoi.organization_id
and    hoi.org_information_context = 'Tax Details References'
and    nvl(hoi.org_information10,'UK') = 'UK'
and    substr(pact.legislative_parameters, instr(pact.legislative_parameters, 'TAX_REF=') + 8,
       instr(pact.legislative_parameters||' ',' ',instr(pact.legislative_parameters, 'TAX_REF=')+8) -
       instr(pact.legislative_parameters, 'TAX_REF=') - 8) = hoi.org_information1;
--
--
cursor csr_p45_3_assignments is
select 'ASSIGNMENT_ACTION_ID=C',paa.assignment_action_id,
       'CHARS_ALREADY_TESTED=P','N',
       'ADDRESS_LINE1=P',       nvl(upper(substr(addr.action_information5,1,35)),' '),
       'ADDRESS_LINE2=P',       nvl(upper(substr(addr.action_information6,1,35)),' '),
       'ADDRESS_LINE3=P',       nvl(upper(substr(addr.action_information7,1,35)),' '),
       'ASSIGNMENT_NUMBER=P',   nvl(peo.action_information11,' '),
       'SEX=P',                 nvl(peo.action_information17,' '),
       'PREV_TAX_REFERENCE=P',  nvl(upper(substr(ltrim(substr(p453.action_information2,4,11),'/'),1,10)),' '),
       'PREV_TAX_DISTRICT=P',   nvl(substr(p453.action_information2,1,3),' '),
       'DATE_OF_BIRTH=P',       nvl(peo.action_information15,' '),
       'HIRE_DATE=P',           nvl(peo.action_information16,' '),
       'DATE_LEFT_PREV_EMP=P',  nvl(p453.action_information3,' '),
       'PREV_TAX_CODE=P',       nvl(p453.action_information4,' '),
       'PREV_TAX_BASIS=P',      nvl(p453.action_information5,' '),
       'PREV_LAST_PAY_TYPE=P',  nvl(p453.action_information6,' '),
       'PREV_LAST_PAY_PERIOD=P',nvl(p453.action_information7,' '),
       'TAX_CODE_IN_USE=P',     nvl(peo.action_information21,' '),
       'TAX_BASIS_IN_USE=P',    nvl(peo.action_information22,' '),
       'PAY_PREVIOUS=P',        nvl(p453.action_information8,'0'),
       'TAX_PREVIOUS=P',        nvl(p453.action_information9,'0'),
       'JOB_TITLE=P',           peo.action_information18,
       'COUNTY=P',              nvl(upper(addr.action_information9),' '),
       'FIRST_NAME=P',          nvl(upper(substr(peo.action_information6,1,35)),' '),
       'LAST_NAME=P',           nvl(upper(substr(peo.action_information8,1,35)),' '),
       'NATIONAL_INSURANCE_NUMBER=P', nvl(peo.action_information12,'NONE'),
       'POSTAL_CODE=P',         nvl(addr.action_information12,' '),
       'TITLE=P',               nvl(substr(peo.action_information14,1,4),' '),
       'TOWN_OR_CITY=P',        nvl(upper(addr.action_information8),' '),
       'STUDENT_LOAN_FLAG_START_DATE=P', nvl(p453.action_information10,'X'),
       'STUDENT_LOAN_FLAG_END_DATE=P',   nvl(p453.action_information11,'4712/12/31 00:00:00'),
       'STUDENT_LOAN_FLAG_EFFECTIVE_END_DATE=P', nvl(p453.action_information12,'4712/12/31 00:00:00') ,
       'EFFECTIVE_DATE=P',      fnd_date.date_to_canonical(pay.effective_date)
from   pay_payroll_actions    pay,
       pay_assignment_actions paa,
       pay_action_information addr,
       pay_action_information peo,
       pay_action_information p453
where  pay.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and    pay.payroll_action_id = paa.payroll_action_id
and    paa.assignment_action_id = peo.action_context_id
and    peo.action_information_category = 'GB EMPLOYEE DETAILS'
and    peo.action_context_type = 'AAP'
and    paa.assignment_action_id = addr.action_context_id
and    addr.action_information_category = 'ADDRESS DETAILS'
and    addr.action_context_type = 'AAP'
and    paa.assignment_action_id = p453.action_context_id
and    p453.action_information_category = 'GB P45(3) EDI'
and    p453.action_context_type = 'AAP';
--
--
cursor csr_p46_header is
select 'SENDER_ID=P', nvl(hoi.org_information11,' '),
       'RECEIVER_ID=P', 'INLAND REVENUE',
       'TEST_INDICATOR=P', decode(pay_magtape_generic.get_parameter_value('TEST'),'N',' ','Y','1'),
       'URGENT_MARKER=P', decode(pay_magtape_generic.get_parameter_value('URGENT'),'N',' ','Y','1'),
       'REQUEST_ID=P', fnd_number.number_to_canonical(pact.request_id),
       'FORM_TYPE=P', '7',
       'FORM_TYPE_MEANING=P', 'P46',
       'TAX_DIST_NO=P', nvl(substr(hoi.org_information1,1,3),' '),
       'TAX_DIST_REF=P', nvl(upper(substr(ltrim(substr(hoi.org_information1,4,11),'/'),1,10)),' '),
       'TAX_DISTRICT=P', nvl(upper(hoi.org_information2),' '),
       'EMPLOYERS_ADDRESS_LINE=P', nvl(upper(hoi.org_information4),' '),
       'EMPLOYERS_NAME=P', nvl(upper(hoi.org_information3),' ')
from   pay_payroll_actions pact,
       hr_organization_information hoi
where  pact.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and    pact.business_group_id = hoi.organization_id
and    hoi.org_information_context = 'Tax Details References'
and    nvl(hoi.org_information10,'UK') = 'UK'
and    substr(pact.legislative_parameters,instr(pact.legislative_parameters,'TAX_REF=') + 8,
       instr(pact.legislative_parameters||' ',' ', instr(pact.legislative_parameters,'TAX_REF=')+8) -
       instr(pact.legislative_parameters, 'TAX_REF=') - 8) = hoi.org_information1;

cursor csr_p46_assignments is
select 'ASSIGNMENT_ACTION_ID=C', paa.assignment_action_id,
       'CHARS_ALREADY_TESTED=P', 'N',
       'ADDRESS_LINE1=P',        nvl(upper(substr(addr.action_information5,1,35)),' '),
       'ADDRESS_LINE2=P',        nvl(upper(substr(addr.action_information6,1,35)),' '),
       'ADDRESS_LINE3=P',        nvl(upper(substr(addr.action_information7,1,35)),' '),
       'ASSIGNMENT_NUMBER=P',    nvl(peo.action_information11,' '),
       'ASSIGNMENT_ID=P',        paa.assignment_id,
       'P46_STATEMENT=P',        nvl(p46.action_information2,'N'),
	   'P46_STATEMENT_STUDENT_LOAN=P', nvl(p46.action_information3,'N'),
       'DATE_OF_BIRTH=P',        peo.action_information15,
       'HIRE_DATE=P',            peo.action_information16,
       'TAX_CODE_IN_USE=P',      nvl(peo.action_information21,' '),
       'TAX_BASIS_IN_USE=P',     nvl(peo.action_information22,' '),
       'COUNTY=P',               nvl(upper(addr.action_information9),' '),
       'FIRST_NAME=P',           nvl(upper(substr(peo.action_information6,1,35)),' '),
       'LAST_NAME=P',            nvl(upper(substr(peo.action_information8,1,35)),' '),
       'NATIONAL_INSURANCE_NUMBER=P', nvl(peo.action_information12,'NONE'),
       'POSTAL_CODE=P',          nvl(addr.action_information12,' '),
       'TITLE=P',                nvl(substr(peo.action_information14,1,4),' '),
       'TOWN_OR_CITY=P',         nvl(upper(addr.action_information8),' '),
       'SEX=P',                  nvl(peo.action_information17,' '),
       'JOB_TITLE=P',            nvl(peo.action_information18,' ')
from   pay_payroll_actions    pay,
       pay_assignment_actions paa,
       pay_action_information addr,
       pay_action_information peo,
       pay_action_information p46
where  pay.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and    pay.payroll_action_id = paa.payroll_action_id
and    paa.assignment_action_id = peo.action_context_id
and    peo.action_information_category = 'GB EMPLOYEE DETAILS'
and    peo.action_context_type = 'AAP'
and    paa.assignment_action_id = addr.action_context_id
and    addr.action_information_category = 'ADDRESS DETAILS'
and    addr.action_context_type = 'AAP'
and    paa.assignment_action_id = p46.action_context_id
and    p46.action_information_category = 'GB P46 EDI'
and    p46.action_context_type = 'AAP';
--
--
cursor csr_p46_pennot_header is
select 'SENDER_ID=P',     hoi.org_information11,
       'RECEIVER_ID=P',   'INLAND REVENUE',
       'TEST_INDICATOR=P',decode(pay_magtape_generic.get_parameter_value('TEST'),'N',' ','Y','1'),
       'URGENT_MARKER=P', decode(pay_magtape_generic.get_parameter_value('URGENT'),'N',' ','Y','1'),
       'REQUEST_ID=P',    fnd_number.number_to_canonical(pact.request_id),
       'FORM_TYPE=P', '6',
       'FORM_TYPE_MEANING=P', 'P46_PENNOT',
       'TAX_DIST_NO=P',   substr(hoi.org_information1,1,3),
       'TAX_DIST_REF=P',  upper(substr(ltrim(substr(hoi.org_information1,4,11),'/'),1,10)),
       'TAX_DISTRICT=P',  upper(hoi.org_information2),
       'EMPLOYERS_ADDRESS_LINE=P', nvl(upper(hoi.org_information4),' '),
       'EMPLOYERS_NAME=P',nvl(upper(hoi.org_information3),' ')
from   pay_payroll_actions pact,
       hr_organization_information hoi
where  pact.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and    pact.business_group_id = hoi.organization_id
and    hoi.org_information_context = 'Tax Details References'
and    nvl(hoi.org_information10,'UK') = 'UK'
and    substr(pact.legislative_parameters, instr(pact.legislative_parameters,'TAX_REF=') + 8,
       instr(pact.legislative_parameters||' ',' ',instr(pact.legislative_parameters, 'TAX_REF=')+8) -
       instr(pact.legislative_parameters, 'TAX_REF=') - 8) = hoi.org_information1;
--

--
cursor csr_p46_pennot_assignments is
select 'ASSIGNMENT_ACTION_ID=C', paa.assignment_action_id,
       'CHARS_ALREADY_TESTED=P', 'N',
       'ADDRESS_LINE1=P',        nvl(upper(substr(addr.action_information5,1,35)),' '),
       'ADDRESS_LINE2=P',        nvl(upper(substr(addr.action_information6,1,35)),' '),
       'ADDRESS_LINE3=P',        nvl(upper(substr(addr.action_information7,1,35)),' '),
       'ASSIGNMENT_NUMBER=P',    nvl(peo.action_information11,' '),
       'SEX=P',                  nvl(peo.action_information17,' '),
       'ANNUAL_PENSION=P',       nvl(p46p.action_information2,'X'),
       'DATE_PENSION_STARTED=P', nvl(p46p.action_information3,'0001/01/01 00:00:00'),
       'TAX_CODE_IN_USE=P',      nvl(peo.action_information21,' '),
       'TAX_BASIS_IN_USE=P',     nvl(peo.action_information22,' '),
       'JOB_TITLE=P',            nvl(peo.action_information18,' '),
       'COUNTY=P',               nvl(upper(addr.action_information9),' '),
       'FIRST_NAME=P',           nvl(upper(substr(peo.action_information6,1,35)),' '),
       'LAST_NAME=P',            nvl(upper(substr(peo.action_information8,1,35)),' '),
       'NATIONAL_INSURANCE_NUMBER=P', nvl(peo.action_information12,'NONE'),
       'POSTAL_CODE=P',          nvl(addr.action_information12,' '),
       'TITLE=P',                nvl(peo.action_information14,' '),
       'TOWN_OR_CITY=P',         nvl(upper(addr.action_information8),' ')
from   pay_payroll_actions    pay,
       pay_assignment_actions paa,
       pay_action_information addr,
       pay_action_information peo,
       pay_action_information p46p
where  pay.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and    pay.payroll_action_id = paa.payroll_action_id
and    paa.assignment_action_id = peo.action_context_id
and    peo.action_information_category = 'GB EMPLOYEE DETAILS'
and    peo.action_context_type = 'AAP'
and    paa.assignment_action_id = addr.action_context_id
and    addr.action_information_category = 'ADDRESS DETAILS'
and    addr.action_context_type = 'AAP'
and    paa.assignment_action_id = p46p.action_context_id
and    p46p.action_information_category = 'GB P46 Pension EDI'
and    p46p.action_context_type = 'AAP';
--
--
-- Bug 5398360
cursor csr_wnu3_header is
select 'SENDER_ID=P', nvl(hoi.org_information11,' '),
       'RECEIVER_ID=P', 'INLAND REVENUE',
       'TEST_INDICATOR=P', decode(pay_magtape_generic.get_parameter_value('TEST'),'N',' ','Y','1'),
       'URGENT_MARKER=P', ' ', -- as a space is required in this place
       'REQUEST_ID=P', fnd_number.number_to_canonical(pact.request_id),
       'FORM_TYPE=P', '18',
       'FORM_TYPE_MEANING=P', 'WNU',
       'TAX_DIST_NO=P', nvl(substr(hoi.org_information1,1,3),' '),
       'TAX_DIST_REF=P', nvl(upper(substr(ltrim(substr(hoi.org_information1,4,11),'/'),1,10)),' '),
       'TAX_DISTRICT=P', nvl(upper(hoi.org_information2),' '),
       'EMPLOYERS_ADDRESS_LINE=P', nvl(upper(hoi.org_information4),' '),
       'EMPLOYERS_NAME=P', nvl(upper(hoi.org_information3),' ')
from   pay_payroll_actions pact,
       hr_organization_information hoi
where  pact.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and    pact.business_group_id = hoi.organization_id
and    hoi.org_information_context = 'Tax Details References'
and    nvl(hoi.org_information10,'UK') = 'UK'
and    substr(pact.legislative_parameters,instr(pact.legislative_parameters,'TAX_REF=') + 8,
       instr(pact.legislative_parameters||' ',' ', instr(pact.legislative_parameters,'TAX_REF=')+8) -
       instr(pact.legislative_parameters, 'TAX_REF=') - 8) = hoi.org_information1;
--
--
cursor csr_wnu3_assignments is
select 'ASSIGNMENT_ACTION_ID=C', paa.assignment_action_id,
       'ADDRESS_LINE1=P',        ' ', -- wnu3 does not require address
       'ADDRESS_LINE2=P',        ' ',
       'ADDRESS_LINE3=P',        ' ',
       'COUNTY=P',               ' ',
       'FIRST_NAME=P',           nvl(upper(substr(peo.action_information6,1,35)),' '),
       'LAST_NAME=P',            nvl(upper(substr(peo.action_information8,1,35)),' '),
       'NATIONAL_INSURANCE_NUMBER=P', nvl(peo.action_information12,'NONE'),
       'POSTAL_CODE=P',          ' ',
       'TITLE=P',                nvl(substr(peo.action_information14,1,4),' '),
       'TOWN_OR_CITY=P',         ' ',
       'DATE_OF_BIRTH=P',        peo.action_information15,
       'HIRE_DATE=P',            peo.action_information16,
       'TAX_CODE_IN_USE=P',      nvl(peo.action_information21,' '),
       'TAX_BASIS_IN_USE=P',     nvl(peo.action_information22,' '),
       'CHARS_ALREADY_TESTED=P', 'N',
       'ASSIGNMENT_ID=P',        paa.assignment_id,
       'ASSIGNMENT_NUMBER=P',    nvl(upper(peo.action_information11), ' '), -- for MOVDED_ASG
       'NEW_ASSIGNMENT_NUMBER=P',nvl(upper(peo.action_information11), ' ') ,  -- for PAY_GB_EDI_WNU_3
       'OLD_ASSIGNMENT_NUMBER=P',nvl(upper(wnu3.action_information2), ' ')  -- for PAY_GB_EDI_WNU_3
from   pay_assignment_actions paa,
       pay_action_information peo,
       pay_action_information wnu3
where  paa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and    paa.assignment_action_id = peo.action_context_id
and    peo.action_information_category = 'GB EMPLOYEE DETAILS'
and    peo.action_context_type = 'AAP'
and    paa.assignment_action_id = wnu3.action_context_id(+)
and    wnu3.action_information_category(+) = 'GB WNU EDI'
and    wnu3.action_context_type(+)= 'AAP';

--
/* changes for P45PT_3 start*/
cursor csr_p45pt_3_header is
select 'SENDER_ID=P',      nvl(hoi.org_information11,' '),
       'RECEIVER_ID=P',    'HMRC',        /* changed for P45PT_3*/
       'TEST_INDICATOR=P', decode(pay_magtape_generic.get_parameter_value('TEST'),'N',' ','Y','1'),
       'URGENT_MARKER=P',  ' ',
       'REQUEST_ID=P',     fnd_number.number_to_canonical(pact.request_id),
       'FORM_TYPE=P',      '5',
       'FORM_TYPE_MEANING=P', 'P45PT3',  /* changed for P45PT_3*/
       'TAX_DIST_NO=P',    nvl(substr(hoi.org_information1,1,3),' '),
       'TAX_DIST_REF=P',   nvl(upper(substr(ltrim(substr(hoi.org_information1,4,11),'/'),1,10)),' '),
       'TAX_DISTRICT=P',   nvl(upper(hoi.org_information2),' '),
       'EMPLOYERS_ADDRESS_LINE=P', nvl(upper(hoi.org_information4),' '),
       'EMPLOYERS_NAME=P', nvl(upper(hoi.org_information3),' '),
       'TEST_ID=P',        nvl(pay_magtape_generic.get_parameter_value('TEST_ID'),' ') /*added for P45PT_3*/
from   pay_payroll_actions pact,
       hr_organization_information hoi
where  pact.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and    pact.business_group_id = hoi.organization_id
and    hoi.org_information_context = 'Tax Details References'
and    nvl(hoi.org_information10,'UK') = 'UK'
and    substr(pact.legislative_parameters, instr(pact.legislative_parameters, 'TAX_REF=') + 8,
       instr(pact.legislative_parameters||' ',' ',instr(pact.legislative_parameters, 'TAX_REF=')+8) -
       instr(pact.legislative_parameters, 'TAX_REF=') - 8) = hoi.org_information1;
--
--
cursor csr_p45pt_3_assignments is
select 'ASSIGNMENT_ACTION_ID=C',paa.assignment_action_id,
       'CHARS_ALREADY_TESTED=P','N',
       'ADDRESS_LINE1=P',       nvl(upper(substr(addr.action_information5,1,35)),' '),
       'ADDRESS_LINE2=P',       nvl(upper(substr(addr.action_information6,1,35)),' '),
       'ADDRESS_LINE3=P',       nvl(upper(substr(addr.action_information7,1,35)),' '),
       'ASSIGNMENT_NUMBER=P',   nvl(peo.action_information11,' '),
       'SEX=P',                 nvl(peo.action_information17,' '),
       'PREV_TAX_REFERENCE=P',  nvl(upper(substr(ltrim(substr(p453.action_information2,4,11),'/'),1,10)),' '),
       'PREV_TAX_DISTRICT=P',   nvl(substr(p453.action_information2,1,3),' '),
       'DATE_OF_BIRTH=P',       peo.action_information15,
       'HIRE_DATE=P',           peo.action_information16,
       'DATE_LEFT_PREV_EMP=P',  nvl(p453.action_information3,'0001/01/01 00:00:00'),
       'PREV_TAX_CODE=P',       nvl(p453.action_information4,' '),
       'PREV_TAX_BASIS=P',      nvl(p453.action_information5,' '),
       'PREV_LAST_PAY_TYPE=P',  nvl(p453.action_information6,' '),
       'PREV_LAST_PAY_PERIOD=P',nvl(p453.action_information7,' '),
       'TAX_CODE_IN_USE=P',     nvl(peo.action_information21,' '),
       'TAX_BASIS_IN_USE=P',    nvl(peo.action_information22,' '),
       -- Bug 6994632 We need to report values form Newstarter tab instead of PAYE tab values
       /*'PAY_PREVIOUS=P',        nvl(p453.action_information8,' '),*/
       -- Bug 7038073 These fields are numeric hence assigning 0.00 if the value is NULL
       /*'PAY_PREVIOUS=P',        nvl(decode(p453.action_information16,0,NULL,p453.action_information16),nvl(p453.action_information8,' ')),
       'TAX_PREVIOUS=P',        nvl(p453.action_information9,' '),*/
       'PAY_PREVIOUS=P',        nvl(decode(p453.action_information16,0,NULL,p453.action_information16),nvl(p453.action_information8,'0')),
       'TAX_PREVIOUS=P',        nvl(p453.action_information9,'0'),
       'JOB_TITLE=P',           peo.action_information18,
       'COUNTY=P',              nvl(upper(pay_gb_movded_edi.get_territory_short_name(addr.action_information13)),' '), /* Country parameter*/
--For bug 7540858 : P45PT3 version5
       'FIRST_NAME=P',          nvl(upper(substr(peo.action_information6,1,35)),' '),
       'MIDDLE_NAME=P',         nvl(upper(substr(peo.action_information7,1,35)),' '), /*Bug 6710229*/
       'LAST_NAME=P',           nvl(upper(substr(peo.action_information8,1,35)),' '),
       'NATIONAL_INSURANCE_NUMBER=P', nvl(peo.action_information12,' '),
       'POSTAL_CODE=P',         nvl(addr.action_information12,' '),
       'TITLE=P',               nvl(substr(peo.action_information14,1,4),' '),
       'TOWN_OR_CITY=P',        nvl(upper(addr.action_information8),' '),
       'STUDENT_LOAN_FLAG_START_DATE=P', nvl(p453.action_information10,'X'),
       'STUDENT_LOAN_FLAG_END_DATE=P',   nvl(p453.action_information11,'4712/12/31 00:00:00'),
       'STUDENT_LOAN_FLAG_EFFECTIVE_END_DATE=P', nvl(p453.action_information12,'4712/12/31 00:00:00') ,
       'EFFECTIVE_DATE=P',      fnd_date.date_to_canonical(pay.effective_date),
       --Bug 7157720 report PREVIOUS_TAX_PAID_NOTIFIED if >=0
       -- Bug 6994632 assigning NULL if it is zero
       'PREVIOUS_TAX_PAID_NOTIFIED=P',         nvl(p453.action_information13,' '),
       --'PREVIOUS_TAX_PAID_NOTIFIED=P',   nvl(decode(p453.action_information13,0,' ',p453.action_information13),' '),
       'NOT_PAID_BETWEEN_START_AND5APR=P',   decode(p453.action_information14,'Y','Y','N',' ',' '),
       'CONTINUE_SL_DEDUCTIONS=P', decode(p453.action_information15,'Y','Y','N',' ',' ')
from   pay_payroll_actions    pay,
       pay_assignment_actions paa,
       pay_action_information addr,
       pay_action_information peo,
       pay_action_information p453
where  pay.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and    pay.payroll_action_id = paa.payroll_action_id
and    paa.assignment_action_id = peo.action_context_id
and    peo.action_information_category = 'GB EMPLOYEE DETAILS'
and    peo.action_context_type = 'AAP'
and    paa.assignment_action_id = addr.action_context_id
and    addr.action_information_category = 'ADDRESS DETAILS'
and    addr.action_context_type = 'AAP'
and    paa.assignment_action_id = p453.action_context_id
and    p453.action_information_category = 'GB P45(3) EDI'
and    p453.action_context_type = 'AAP';
/* changes for P45PT_3 end*/

/*Changes for P45PT_3 Version 6*/

cursor csr_p45pt_3_ver6_header is
select 'SENDER_ID=P',      nvl(UPPER(hoi.org_information11),' '), -- Bug 8329474
       'RECEIVER_ID=P',    'HMRC',        /* changed for P45PT_3*/
       'TEST_INDICATOR=P', decode(pay_magtape_generic.get_parameter_value('TEST'),'N',' ','Y','1'),
       'URGENT_MARKER=P',  ' ',
       'REQUEST_ID=P',     fnd_number.number_to_canonical(pact.request_id),
       'FORM_TYPE=P',      '5',
       'FORM_TYPE_MEANING=P', 'P45PT_3_VER6',  /* changed for P45PT_3*/
       'TAX_DIST_NO=P',    nvl(substr(hoi.org_information1,1,3),' '),
       'TAX_DIST_REF=P',   nvl(upper(substr(ltrim(substr(hoi.org_information1,4,11),'/'),1,10)),' '),
       'TAX_DISTRICT=P',   nvl(upper(hoi.org_information2),' '),
       'EMPLOYERS_ADDRESS_LINE=P', nvl(upper(hoi.org_information4),' '),
       'EMPLOYERS_NAME=P', nvl(upper(hoi.org_information3),' '),
       'TEST_ID=P',        nvl(pay_magtape_generic.get_parameter_value('TEST_ID'),' ') /*added for P45PT_3*/
from   pay_payroll_actions pact,
       hr_organization_information hoi
where  pact.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and    pact.business_group_id = hoi.organization_id
and    hoi.org_information_context = 'Tax Details References'
and    nvl(hoi.org_information10,'UK') = 'UK'
and    substr(pact.legislative_parameters, instr(pact.legislative_parameters, 'TAX_REF=') + 8,
       instr(pact.legislative_parameters||' ',' ',instr(pact.legislative_parameters, 'TAX_REF=')+8) -
       instr(pact.legislative_parameters, 'TAX_REF=') - 8) = hoi.org_information1;
---
cursor csr_p45pt_3_ver6_assignments is
select /*+ ordered*/ 'ASSIGNMENT_ACTION_ID=C',paa.assignment_action_id,
       'CHARS_ALREADY_TESTED=P','N',
       'ADDRESS_LINE1=P',       nvl(upper(substr(addr.action_information5,1,35)),' '),
       'ADDRESS_LINE2=P',       nvl(upper(substr(addr.action_information6,1,35)),' '),
       'ADDRESS_LINE3=P',       nvl(upper(substr(addr.action_information7,1,35)),' '),
       'ASSIGNMENT_NUMBER=P',   nvl(peo.action_information11,' '),
       'SEX=P',                 nvl(peo.action_information17,' '),
       'PREV_TAX_REFERENCE=P',  nvl(upper(substr(ltrim(substr(p453.action_information2,4,11),'/'),1,10)),' '),
       'PREV_TAX_DISTRICT=P',   nvl(substr(p453.action_information2,1,3),' '),
       'DATE_OF_BIRTH=P',       nvl(peo.action_information15,' '),
       'HIRE_DATE=P',           peo.action_information16,
       'DATE_LEFT_PREV_EMP=P',  nvl(p453.action_information3,'0001/01/01 00:00:00'),
       'PREV_TAX_CODE=P',       nvl(p453.action_information4,' '),
       'PREV_TAX_BASIS=P',      nvl(p453.action_information5,' '),
       'PREV_LAST_PAY_TYPE=P',  nvl(p453.action_information6,' '),
       'PREV_LAST_PAY_PERIOD=P',nvl(p453.action_information7,' '),
       'TAX_CODE_IN_USE=P',     nvl(peo.action_information21,' '),
       'TAX_BASIS_IN_USE=P',    nvl(peo.action_information22,' '),
       -- Bug 6994632 We need to report values form Newstarter tab instead of PAYE tab values
       /*'PAY_PREVIOUS=P',        nvl(p453.action_information8,' '),*/
       -- Bug 7038073 These fields are numeric hence assigning 0.00 if the value is NULL
       /*'PAY_PREVIOUS=P',        nvl(decode(p453.action_information16,0,NULL,p453.action_information16),nvl(p453.action_information8,' ')),
       'TAX_PREVIOUS=P',        nvl(p453.action_information9,' '),*/
       'PAY_PREVIOUS=P',        nvl(decode(p453.action_information16,0,NULL,p453.action_information16),nvl(p453.action_information8,'0')),
       'TAX_PREVIOUS=P',        nvl(p453.action_information9,'0'),
       'JOB_TITLE=P',           peo.action_information18,
       'COUNTY=P',              nvl(upper(pay_gb_movded_edi.get_territory_short_name(addr.action_information13)),' '), /* Country parameter*/
--For bug 7540858 : P45PT3 version 6
       'FIRST_NAME=P',          nvl(upper(substr(peo.action_information6,1,35)),' '),
       'MIDDLE_NAME=P',         nvl(upper(substr(peo.action_information7,1,35)),' '), /*Bug 6710229*/
       'LAST_NAME=P',           nvl(upper(substr(peo.action_information8,1,35)),' '),
       'NATIONAL_INSURANCE_NUMBER=P', nvl(peo.action_information12,' '),
       'POSTAL_CODE=P',         nvl(addr.action_information12,' '),
       'TITLE=P',               nvl(substr(peo.action_information14,1,4),' '),
       'TOWN_OR_CITY=P',        nvl(upper(addr.action_information8),' '),
       'STUDENT_LOAN_FLAG_START_DATE=P', nvl(p453.action_information10,'X'),
       'STUDENT_LOAN_FLAG_END_DATE=P',   nvl(p453.action_information11,'4712/12/31 00:00:00'),
       'STUDENT_LOAN_FLAG_EFFECTIVE_END_DATE=P', nvl(p453.action_information12,'4712/12/31 00:00:00') ,
       'EFFECTIVE_DATE=P',      fnd_date.date_to_canonical(pay.effective_date),
       --Bug 7157720 report PREVIOUS_TAX_PAID_NOTIFIED if >=0
       -- Bug 6994632 assigning NULL if it is zero
       'PREVIOUS_TAX_PAID_NOTIFIED=P',         nvl(p453.action_information13,' '),
       --'PREVIOUS_TAX_PAID_NOTIFIED=P',   nvl(decode(p453.action_information13,0,' ',p453.action_information13),' '),
       'NOT_PAID_BETWEEN_START_AND5APR=P',   decode(p453.action_information14,'Y','Y','N',' ',' '),
       'CONTINUE_SL_DEDUCTIONS=P', decode(p453.action_information15,'Y','Y','N',' ',' ')
from   pay_payroll_actions    pay,
       pay_assignment_actions paa,
       pay_action_information addr,
       pay_action_information peo,
       pay_action_information p453
where  pay.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and    pay.payroll_action_id = paa.payroll_action_id
and    paa.assignment_action_id = peo.action_context_id
and    peo.action_information_category = 'GB EMPLOYEE DETAILS'
and    peo.action_context_type = 'AAP'
and    paa.assignment_action_id = addr.action_context_id
and    addr.action_information_category = 'ADDRESS DETAILS'
and    addr.action_context_type = 'AAP'
and    paa.assignment_action_id = p453.action_context_id
and    p453.action_information_category = 'GB P45(3) EDI'
and    p453.action_context_type = 'AAP';
----
/*Changes for P45PT_3 Version 6*/

/***** Year end changes for P46 PENNOT ********/
 /******* start *******/
cursor csr_p46_5_pennot_header is
select 'SENDER_ID=P',     hoi.org_information11,
       'RECEIVER_ID=P',   'HMRC',
       'TEST_INDICATOR=P',decode(pay_magtape_generic.get_parameter_value('TEST'),'N',' ','Y','1'),
       'TEST_ID=P', pay_magtape_generic.get_parameter_value('TEST_ID'),
       'URGENT_MARKER=P', ' ',
       'TRANSMISSION_DATE=P', to_char(sysdate,'CCYYMMDD'),
       'TRANSMISSION_TIME=P', to_char(sysdate,'HHMMSS'),
       'REQUEST_ID=P',    fnd_number.number_to_canonical(pact.request_id),
       'FORM_TYPE=P', '6',
       'FORM_TYPE_MEANING=P', 'P46_5_PENNOT',
       'UNIQUE_REF=P', '1234',
       'SENDER_SUBAD=P',' ',
       'RECIPIENT_SUBAD=P',' ',
       'TAX_DIST_NO=P',   substr(hoi.org_information1,1,3),
       'TAX_DIST_REF=P',  upper(substr(ltrim(substr(hoi.org_information1,4,11),'/'),1,10)),
       'TAX_DISTRICT=P',  upper(hoi.org_information2),
       'EMPLOYERS_ADDRESS_LINE=P', nvl(upper(hoi.org_information4),' '),
       'EMPLOYERS_NAME=P',nvl(upper(hoi.org_information3),' ')
from   pay_payroll_actions pact,
       hr_organization_information hoi
where  pact.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and    pact.business_group_id = hoi.organization_id
and    hoi.org_information_context = 'Tax Details References'
and    nvl(hoi.org_information10,'UK') = 'UK'
and    substr(pact.legislative_parameters, instr(pact.legislative_parameters,'TAX_REF=') + 8,
       instr(pact.legislative_parameters||' ',' ',instr(pact.legislative_parameters, 'TAX_REF=')+8) -
       instr(pact.legislative_parameters, 'TAX_REF=') - 8) = hoi.org_information1;
--
--
cursor csr_p46_5_pennot_assignments is
select 'ASSIGNMENT_ACTION_ID=C', paa.assignment_action_id,
       'CHARS_ALREADY_TESTED=P', 'N',
       'ADDRESS_LINE1=P',        nvl(upper(substr(addr.action_information5,1,35)),' '),
       'ADDRESS_LINE2=P',        nvl(upper(substr(addr.action_information6,1,35)),' '), -- Bug 7038073  Added nvl
       'ADDRESS_LINE3=P',        nvl(upper(substr(addr.action_information7,1,35)),' '), -- Bug 7038073  Added nvl
       'ADDRESS_LINE4=P',        ' ',
       'ASSIGNMENT_NUMBER=P',    nvl(peo.action_information11,' '),
       'SEX=P',                  nvl(peo.action_information17,' '),
       'ANNUAL_PENSION=P',       p46p.action_information2,
       'DATE_PENSION_STARTED=P', nvl(p46p.action_information3,'0001/01/01 00:00:00'),
       'TAX_CODE_IN_USE=P',      nvl(peo.action_information21,' '),
       'TAX_BASIS_IN_USE=P',     nvl(peo.action_information22,' '),
       'JOB_TITLE=P',            nvl(peo.action_information18,' '),
       'COUNTY=P',               nvl(upper(pay_gb_movded_edi.get_territory_short_name(addr.action_information13)),' '), /* Country parameter*/
--For bug 7540858 : P46 Pennot version 5
       'FIRST_NAME=P',           nvl(upper(substr(peo.action_information6,1,35)),' '),
       'MIDDLE_NAME=P',          nvl(upper(substr(peo.action_information7,1,35)),' '), /*Bug 6710229*/
       'LAST_NAME=P',            nvl(upper(substr(peo.action_information8,1,35)),' '),
       'NATIONAL_INSURANCE_NUMBER=P', peo.action_information12,
       'POSTAL_CODE=P',          nvl(addr.action_information12,' '),
       'TITLE=P',                nvl(peo.action_information14,' '),
       'TOWN_OR_CITY=P',         nvl(upper(addr.action_information8),' '),
       'MID_NAME=P',             upper(substr(peo.action_information7,1,35)),
       'RECENT_BEREAVED=P',      p46p.action_information10,
       'PREV_EMP_REF=P',         upper(substr(ltrim(substr(p46p.action_information4,4,11),'/'),1,10)),
       'PREV_HMRC_NO=P',         substr(p46p.action_information4,1,3),
        -- Bug 7038073 These fields are numeric hence assigning 0.00 if the value is NULL
       /*'TOTAL_PAY=P',            nvl(p46p.action_information11,' '),
       'TOTAL_TAX=P',            nvl(p46p.action_information12,' '),*/
       'TOTAL_PAY=P',            nvl(p46p.action_information11,'0'),
       'TOTAL_TAX=P',            nvl(p46p.action_information12,'0'),
       'DATE_LEFT_PREV_EMP=P',   nvl(p46p.action_information5,'0001/01/01 00:00:00'),
       'DATE_OF_BIRTH=P',        nvl(peo.action_information15,'0001/01/01 00:00:00'),
       'TAX_CODE_LEAVING=P',     nvl(p46p.action_information6,' '),
       'TAX_BASIS_PREV=P',       nvl(p46p.action_information7,' '),
       'PREV_PAY_TYPE=P',        nvl(p46p.action_information8,' '),
       'PREV_PAY_PERIOD=P',      nvl(p46p.action_information9,' '),
       'EFFECTIVE_DATE=P',       fnd_date.date_to_canonical(pay.effective_date)
from   pay_payroll_actions    pay,
       pay_assignment_actions paa,
       pay_action_information addr,
       pay_action_information peo,
       pay_action_information p46p
where  pay.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and    pay.payroll_action_id = paa.payroll_action_id
and    paa.assignment_action_id = peo.action_context_id
and    peo.action_information_category = 'GB EMPLOYEE DETAILS'
and    peo.action_context_type = 'AAP'
and    paa.assignment_action_id = addr.action_context_id
and    addr.action_information_category = 'ADDRESS DETAILS'
and    addr.action_context_type = 'AAP'
and    paa.assignment_action_id = p46p.action_context_id
and    p46p.action_information_category = 'GB P46 PENNOT EDI'
and    p46p.action_context_type = 'AAP';


/***** Year end changes for P46 PENNOT Version 6 Start********/
 cursor csr_p46_ver6_pennot_header is
select 'SENDER_ID=P',     UPPER(hoi.org_information11),
       'RECEIVER_ID=P',   'HMRC',
       'TEST_INDICATOR=P',decode(pay_magtape_generic.get_parameter_value('TEST'),'N',' ','Y','1'),
       'TEST_ID=P', pay_magtape_generic.get_parameter_value('TEST_ID'),
       'URGENT_MARKER=P', ' ',
       'TRANSMISSION_DATE=P', to_char(sysdate,'CCYYMMDD'),
       'TRANSMISSION_TIME=P', to_char(sysdate,'HHMMSS'),
       'REQUEST_ID=P',    fnd_number.number_to_canonical(pact.request_id),
       'FORM_TYPE=P', '6',
       'FORM_TYPE_MEANING=P', 'P46_VER6_PENNOT',
       'UNIQUE_REF=P', '1234',
       'SENDER_SUBAD=P',' ',
       'RECIPIENT_SUBAD=P',' ',
       'TAX_DIST_NO=P',   substr(hoi.org_information1,1,3),
       'TAX_DIST_REF=P',  upper(substr(ltrim(substr(hoi.org_information1,4,11),'/'),1,10)),
       'TAX_DISTRICT=P',  upper(hoi.org_information2),
       'EMPLOYERS_ADDRESS_LINE=P', nvl(upper(hoi.org_information4),' '),
       'EMPLOYERS_NAME=P',nvl(upper(hoi.org_information3),' ')
from   pay_payroll_actions pact,
       hr_organization_information hoi
where  pact.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and    pact.business_group_id = hoi.organization_id
and    hoi.org_information_context = 'Tax Details References'
and    nvl(hoi.org_information10,'UK') = 'UK'
and    substr(pact.legislative_parameters, instr(pact.legislative_parameters,'TAX_REF=') + 8,
       instr(pact.legislative_parameters||' ',' ',instr(pact.legislative_parameters, 'TAX_REF=')+8) -
       instr(pact.legislative_parameters, 'TAX_REF=') - 8) = hoi.org_information1;
--
--
cursor csr_p46_ver6_pennot_assg is
select 'ASSIGNMENT_ACTION_ID=C', paa.assignment_action_id,
       'CHARS_ALREADY_TESTED=P', 'N',
       'ADDRESS_LINE1=P',        nvl(upper(substr(addr.action_information5,1,35)),' '),
       'ADDRESS_LINE2=P',        nvl(upper(substr(addr.action_information6,1,35)),' '), -- Bug 7038073  Added nvl
       'ADDRESS_LINE3=P',        nvl(upper(substr(addr.action_information7,1,35)),' '), -- Bug 7038073  Added nvl
       'ADDRESS_LINE4=P',        ' ',
       'ASSIGNMENT_NUMBER=P',    nvl(peo.action_information11,' '),
       'SEX=P',                  nvl(peo.action_information17,' '),
       'ANNUAL_PENSION=P',       p46p.action_information2,
       'DATE_PENSION_STARTED=P', nvl(p46p.action_information3,'0001/01/01 00:00:00'),
       'TAX_CODE_IN_USE=P',      nvl(peo.action_information21,' '),
       'TAX_BASIS_IN_USE=P',     nvl(peo.action_information22,' '),
       'JOB_TITLE=P',            nvl(peo.action_information18,' '),
       'COUNTY=P',               nvl(upper(pay_gb_movded_edi.get_territory_short_name(addr.action_information13)),' '), /* Country parameter*/
--For bug 7540858 : P46 Pennot version 6
       'FIRST_NAME=P',           nvl(upper(substr(peo.action_information6,1,35)),' '),
       'MIDDLE_NAME=P',          nvl(upper(substr(peo.action_information7,1,35)),' '), /*Bug 6710229*/
       'LAST_NAME=P',            nvl(upper(substr(peo.action_information8,1,35)),' '),
       'NATIONAL_INSURANCE_NUMBER=P', peo.action_information12,
       'POSTAL_CODE=P',          nvl(addr.action_information12,' '),
       'TITLE=P',                nvl(peo.action_information14,' '),
       'TOWN_OR_CITY=P',         nvl(upper(addr.action_information8),' '),
       'MID_NAME=P',             upper(substr(peo.action_information7,1,35)),
       'RECENT_BEREAVED=P',      p46p.action_information10,
       'PREV_EMP_REF=P',         nvl(upper(substr(ltrim(substr(p46p.action_information4,4,11),'/'),1,10)),' '),
       'PREV_HMRC_NO=P',         nvl(substr(p46p.action_information4,1,3),' '),
        -- Bug 7038073 These fields are numeric hence assigning 0.00 if the value is NULL
       /*'TOTAL_PAY=P',            nvl(p46p.action_information11,' '),
       'TOTAL_TAX=P',            nvl(p46p.action_information12,' '),*/
       /*'TOTAL_PAY=P',            nvl(p46p.action_information11,'0'),
       'TOTAL_TAX=P',            nvl(p46p.action_information12,'0'),*/
       'TOTAL_PAY=P',            nvl(decode(p46p.action_information11,'0',null,p46p.action_information11),' '), --7830717
       'TOTAL_TAX=P',            nvl(decode(p46p.action_information12,'0',null,p46p.action_information12),' '), --7830717
       'DATE_LEFT_PREV_EMP=P',   nvl(p46p.action_information5,'0001/01/01 00:00:00'),
       'DATE_OF_BIRTH=P',        nvl(peo.action_information15,'0001/01/01 00:00:00'),
       'TAX_CODE_LEAVING=P',     nvl(p46p.action_information6,' '),
       'TAX_BASIS_PREV=P',       nvl(p46p.action_information7,' '),
       'PREV_PAY_TYPE=P',        nvl(p46p.action_information8,' '),
       'PREV_PAY_PERIOD=P',      nvl(p46p.action_information9,' '),
       'EFFECTIVE_DATE=P',       fnd_date.date_to_canonical(pay.effective_date)
from   pay_payroll_actions    pay,
       pay_assignment_actions paa,
       pay_action_information addr,
       pay_action_information peo,
       pay_action_information p46p
where  pay.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and    pay.payroll_action_id = paa.payroll_action_id
and    paa.assignment_action_id = peo.action_context_id
and    peo.action_information_category = 'GB EMPLOYEE DETAILS'
and    peo.action_context_type = 'AAP'
and    paa.assignment_action_id = addr.action_context_id
and    addr.action_information_category = 'ADDRESS DETAILS'
and    addr.action_context_type = 'AAP'
and    paa.assignment_action_id = p46p.action_context_id
and    p46p.action_information_category = 'GB P46 PENNOT EDI'
and    p46p.action_context_type = 'AAP';

/***** Year end changes for P46 PENNOT Version 6 End********/
---
cursor csr_p46_5_header is
select 'SENDER_ID=P', nvl(UPPER(hoi.org_information11),' '),
       'RECEIVER_ID=P', 'HMRC',
       'TEST_INDICATOR=P', decode(pay_magtape_generic.get_parameter_value('TEST'),'N',' ','Y','1'),
       'URGENT_MARKER=P', ' ',--decode(pay_magtape_generic.get_parameter_value('URGENT'),'N',' ','Y','1'),
       'REQUEST_ID=P', fnd_number.number_to_canonical(pact.request_id),
       'FORM_TYPE=P', '7',
       'FORM_TYPE_MEANING=P', 'P46_5',
       'TAX_DIST_NO=P', nvl(substr(hoi.org_information1,1,3),' '),
       'TAX_DIST_REF=P', nvl(upper(substr(ltrim(substr(hoi.org_information1,4,11),'/'),1,10)),' '),
       'TAX_DISTRICT=P', nvl(upper(hoi.org_information2),' '),
       'EMPLOYERS_ADDRESS_LINE=P', nvl(upper(hoi.org_information4),' '),
       'EMPLOYERS_NAME=P', nvl(upper(hoi.org_information3),' '),
       'TEST_ID=P', pay_magtape_generic.get_parameter_value('TEST_ID')
from   pay_payroll_actions pact,
       hr_organization_information hoi
where  pact.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and    pact.business_group_id = hoi.organization_id
and    hoi.org_information_context = 'Tax Details References'
and    nvl(hoi.org_information10,'UK') = 'UK'
and    substr(pact.legislative_parameters,instr(pact.legislative_parameters,'TAX_REF=') + 8,
       instr(pact.legislative_parameters||' ',' ', instr(pact.legislative_parameters,'TAX_REF=')+8) -
       instr(pact.legislative_parameters, 'TAX_REF=') - 8) = hoi.org_information1;

cursor csr_p46_5_assignments is
select 'ASSIGNMENT_ACTION_ID=C', paa.assignment_action_id,
       'CHARS_ALREADY_TESTED=P', 'N',
       'ADDRESS_LINE1=P',        nvl(upper(substr(addr.action_information5,1,35)),' '),
       'ADDRESS_LINE2=P',        nvl(upper(substr(addr.action_information6,1,35)),' '),
       'ADDRESS_LINE3=P',        nvl(upper(substr(addr.action_information7,1,35)),' '),
       'ASSIGNMENT_NUMBER=P',    nvl(peo.action_information11,' '),
       'ASSIGNMENT_ID=P',        paa.assignment_id,
       'P46_STATEMENT=P',        nvl(p46.action_information2,' '),
	   'P46_STATEMENT_STUDENT_LOAN=P', nvl(p46.action_information3,' '),
       'DEFAULT_P46=P',          nvl(p46.action_information4,' '),
       'DATE_OF_BIRTH=P',        nvl(peo.action_information15,' '),
       'HIRE_DATE=P',            nvl(peo.action_information16,' '),
       'TAX_CODE_IN_USE=P',      nvl(peo.action_information21,' '),
       'TAX_BASIS_IN_USE=P',     nvl(peo.action_information22,' '),
       'COUNTY=P',               nvl(upper(pay_gb_movded_edi.get_territory_short_name(addr.action_information13)),' '), /* Country parameter*/
--For bug 7540858 : P46 version 5
       'FIRST_NAME=P',           nvl(upper(substr(peo.action_information6,1,35)),' '),
       'MIDDLE_NAME=P',          nvl(upper(substr(peo.action_information7,1,35)),' '), /*Bug 6710229*/
       'LAST_NAME=P',            nvl(upper(substr(peo.action_information8,1,35)),' '),
       'NATIONAL_INSURANCE_NUMBER=P', nvl(peo.action_information12,' '),
       'POSTAL_CODE=P',          nvl(addr.action_information12,' '),
       'TITLE=P',                nvl(substr(peo.action_information14,1,4),' '),
       'TOWN_OR_CITY=P',         nvl(upper(addr.action_information8),' '),
       'SEX=P',                  nvl(peo.action_information17,' '),
       'JOB_TITLE=P',            nvl(peo.action_information18,' '),
       'EFFECTIVE_DATE=P',       fnd_date.date_to_canonical(pay.effective_date)
from   pay_payroll_actions    pay,
       pay_assignment_actions paa,
       pay_action_information addr,
       pay_action_information peo,
       pay_action_information p46
where  pay.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and    pay.payroll_action_id = paa.payroll_action_id
and    paa.assignment_action_id = peo.action_context_id
and    peo.action_information_category = 'GB EMPLOYEE DETAILS'
and    peo.action_context_type = 'AAP'
and    paa.assignment_action_id = addr.action_context_id
and    addr.action_information_category = 'ADDRESS DETAILS'
and    addr.action_context_type = 'AAP'
and    paa.assignment_action_id = p46.action_context_id
and    p46.action_information_category = 'GB P46_5 EDI'
and    p46.action_context_type = 'AAP';

    /***** END *****/

/*P46 Version6 EOY Changes Start*/
cursor csr_p46_ver6_header is
select 'SENDER_ID=P', nvl(UPPER(hoi.org_information11),' '),
       'RECEIVER_ID=P', 'HMRC',
       'TEST_INDICATOR=P', decode(pay_magtape_generic.get_parameter_value('TEST'),'N',' ','Y','1'),
       'URGENT_MARKER=P', ' ',--decode(pay_magtape_generic.get_parameter_value('URGENT'),'N',' ','Y','1'),
       'REQUEST_ID=P', fnd_number.number_to_canonical(pact.request_id),
       'FORM_TYPE=P', '7',
       'FORM_TYPE_MEANING=P', 'P46_VER6',
       'TAX_DIST_NO=P', nvl(substr(hoi.org_information1,1,3),' '),
       'TAX_DIST_REF=P', nvl(upper(substr(ltrim(substr(hoi.org_information1,4,11),'/'),1,10)),' '),
       'TAX_DISTRICT=P', nvl(upper(hoi.org_information2),' '),
       'EMPLOYERS_ADDRESS_LINE=P', nvl(upper(hoi.org_information4),' '),
       'EMPLOYERS_NAME=P', nvl(upper(hoi.org_information3),' '),
       'TEST_ID=P', pay_magtape_generic.get_parameter_value('TEST_ID')
from   pay_payroll_actions pact,
       hr_organization_information hoi
where  pact.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and    pact.business_group_id = hoi.organization_id
and    hoi.org_information_context = 'Tax Details References'
and    nvl(hoi.org_information10,'UK') = 'UK'
and    substr(pact.legislative_parameters,instr(pact.legislative_parameters,'TAX_REF=') + 8,
       instr(pact.legislative_parameters||' ',' ', instr(pact.legislative_parameters,'TAX_REF=')+8) -
       instr(pact.legislative_parameters, 'TAX_REF=') - 8) = hoi.org_information1;

cursor csr_p46_ver6_assignments is
select /*+ ordered */ 'ASSIGNMENT_ACTION_ID=C', paa.assignment_action_id,
       'CHARS_ALREADY_TESTED=P', 'N',
       'ADDRESS_LINE1=P',        nvl(upper(substr(addr.action_information5,1,35)),' '),
       'ADDRESS_LINE2=P',        nvl(upper(substr(addr.action_information6,1,35)),' '),
       'ADDRESS_LINE3=P',        nvl(upper(substr(addr.action_information7,1,35)),' '),
       'ASSIGNMENT_NUMBER=P',    nvl(peo.action_information11,' '),
       'ASSIGNMENT_ID=P',        paa.assignment_id,
       'P46_STATEMENT=P',        nvl(p46.action_information2,' '),
	   'P46_STATEMENT_STUDENT_LOAN=P', nvl(p46.action_information3,' '),
       'DEFAULT_P46=P',          nvl(p46.action_information4,' '),
       'DATE_OF_BIRTH=P',        nvl(peo.action_information15,' '),
       'HIRE_DATE=P',            nvl(peo.action_information16,' '),
       'TAX_CODE_IN_USE=P',      nvl(peo.action_information21,' '),
       'TAX_BASIS_IN_USE=P',     nvl(peo.action_information22,' '),
       'COUNTY=P',               nvl(upper(pay_gb_movded_edi.get_territory_short_name(addr.action_information13)),' '), /* Country parameter*/
--For bug 7540858 : P46 version 6
       'FIRST_NAME=P',           nvl(upper(substr(peo.action_information6,1,35)),' '),
       'MIDDLE_NAME=P',          nvl(upper(substr(peo.action_information7,1,35)),' '), /*Bug 6710229*/
       'LAST_NAME=P',            nvl(upper(substr(peo.action_information8,1,35)),' '),
       'NATIONAL_INSURANCE_NUMBER=P', nvl(peo.action_information12,' '),
       'POSTAL_CODE=P',          nvl(addr.action_information12,' '),
       'TITLE=P',                nvl(substr(peo.action_information14,1,4),' '),
       'TOWN_OR_CITY=P',         nvl(upper(addr.action_information8),' '),
       'SEX=P',                  nvl(peo.action_information17,' '),
       'JOB_TITLE=P',            nvl(peo.action_information18,' '),
       'EFFECTIVE_DATE=P',       fnd_date.date_to_canonical(pay.effective_date)
from   pay_payroll_actions    pay,
       pay_assignment_actions paa,
       pay_action_information addr,
       pay_action_information peo,
       pay_action_information p46
where  pay.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and    pay.payroll_action_id = paa.payroll_action_id
and    paa.assignment_action_id = peo.action_context_id
and    peo.action_information_category = 'GB EMPLOYEE DETAILS'
and    peo.action_context_type = 'AAP'
and    paa.assignment_action_id = addr.action_context_id
and    addr.action_information_category = 'ADDRESS DETAILS'
and    addr.action_context_type = 'AAP'
and    paa.assignment_action_id = p46.action_context_id
and    p46.action_information_category = 'GB P46_5 EDI'
and    p46.action_context_type = 'AAP';

/*P46 Version6 EOY Changes End*/


	/*Changes for P46EXP_Ver6 starts*/
cursor csr_p46exp_ver6_header is
select 'SENDER_ID=P', nvl(UPPER(hoi.org_information11),' '),
       'RECEIVER_ID=P', 'HMRC',
       'TEST_INDICATOR=P', decode(pay_magtape_generic.get_parameter_value('TEST'),'N',' ','Y','1'),
       'URGENT_MARKER=P', ' ',
       'REQUEST_ID=P', fnd_number.number_to_canonical(pact.request_id),
       'FORM_TYPE=P', '23',
       'FORM_TYPE_MEANING=P', 'P46EXP_VER6',
       'TAX_DIST_NO=P', nvl(substr(hoi.org_information1,1,3),' '),
       'TAX_DIST_REF=P', nvl(upper(substr(ltrim(substr(hoi.org_information1,4,11),'/'),1,10)),' '),
       'TAX_DISTRICT=P', nvl(upper(hoi.org_information2),' '),
       'EMPLOYERS_ADDRESS_LINE=P', nvl(upper(hoi.org_information4),' '),
       'EMPLOYERS_NAME=P', nvl(upper(hoi.org_information3),' '),
       'TEST_ID=P', pay_magtape_generic.get_parameter_value('TEST_ID')
from   pay_payroll_actions pact,
       hr_organization_information hoi
where  pact.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and    pact.business_group_id = hoi.organization_id
and    hoi.org_information_context = 'Tax Details References'
and    nvl(hoi.org_information10,'UK') = 'UK'
and    substr(pact.legislative_parameters,instr(pact.legislative_parameters,'TAX_REF=') + 8,
       instr(pact.legislative_parameters||' ',' ', instr(pact.legislative_parameters,'TAX_REF=')+8) -
       instr(pact.legislative_parameters, 'TAX_REF=') - 8) = hoi.org_information1;

cursor csr_p46exp_ver6_assignments is
select 'ASSIGNMENT_ACTION_ID=C', paa.assignment_action_id,
       'CHARS_ALREADY_TESTED=P', 'N',
       'ADDRESS_LINE1=P',        nvl(upper(substr(addr.action_information5,1,35)),' '),
       'ADDRESS_LINE2=P',        nvl(upper(substr(addr.action_information6,1,35)),' '),
       'ADDRESS_LINE3=P',        nvl(upper(substr(addr.action_information7,1,35)),' '),
       'ASSIGNMENT_NUMBER=P',    nvl(peo.action_information11,' '),
       'ASSIGNMENT_ID=P',        paa.assignment_id,
       'P46_EXPAT_STATEMENT=P',        nvl(p46.action_information2,' '),
	   'P46_EXPAT_STUDENT_LOAN=P', nvl(p46.action_information3,' '),
       'DATE_OF_BIRTH=P',        nvl(peo.action_information15,' '),
       'HIRE_DATE=P',            nvl(peo.action_information16,' '),
       'TAX_CODE_IN_USE=P',      nvl(peo.action_information21,' '),
       'TAX_BASIS_IN_USE=P',     nvl(peo.action_information22,' '),
       'COUNTY=P',               nvl(upper(pay_gb_movded_edi.get_territory_short_name(addr.action_information13)),' '), /* Country parameter*/
       'FIRST_NAME=P',           nvl(upper(substr(peo.action_information6,1,35)),' '),
       'MIDDLE_NAME=P',          nvl(upper(substr(peo.action_information7,1,35)),' '), /*Bug 6710229*/
       'LAST_NAME=P',            nvl(upper(substr(peo.action_information8,1,35)),' '),
       'NATIONAL_INSURANCE_NUMBER=P', nvl(peo.action_information12,' '),
       'POSTAL_CODE=P',          nvl(addr.action_information12,' '),
       'TITLE=P',                nvl(substr(peo.action_information14,1,4),' '),
       'TOWN_OR_CITY=P',         nvl(upper(addr.action_information8),' '),
       'SEX=P',                  nvl(peo.action_information17,' '),
       'JOB_TITLE=P',            nvl(peo.action_information18,' '),
       'EFFECTIVE_DATE=P',       fnd_date.date_to_canonical(pay.effective_date),
       'P46_EXPAT_EEA_CITIZEN=P', nvl(p46.action_information4,' '),
       'P46_EXPAT_START_EMPL_DATE=P', nvl(p46.action_information5,' '),
       'P46_EXPAT_EMP6_SCHEME=P', nvl(p46.action_information6,' ')

from   pay_payroll_actions    pay,
       pay_assignment_actions paa,
       pay_action_information addr,
       pay_action_information peo,
       pay_action_information p46
where  pay.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and    pay.payroll_action_id = paa.payroll_action_id
and    paa.assignment_action_id = peo.action_context_id
and    peo.action_information_category = 'GB EMPLOYEE DETAILS'
and    peo.action_context_type = 'AAP'
and    paa.assignment_action_id = addr.action_context_id
and    addr.action_information_category = 'ADDRESS DETAILS'
and    addr.action_context_type = 'AAP'
and    paa.assignment_action_id = p46.action_context_id
and    p46.action_information_category = 'GB P46EXP EDI'
and    p46.action_context_type = 'AAP';


	/*Changes for P46EXP_Ver6 End*/

--
level_cnt   number;
--
--
PROCEDURE archinit ( p_payroll_action_id IN NUMBER);
--
PROCEDURE range_cursor (pactid IN NUMBER,
                        sqlstr OUT NOCOPY VARCHAR2);
--
PROCEDURE p45_3_action_creation(pactid IN NUMBER,
                                stperson IN NUMBER,
                                endperson IN NUMBER,
                                chunk IN NUMBER);
--
/* changes for P45PT_3 start */
PROCEDURE p45pt_3_action_creation(pactid IN NUMBER,
                                stperson IN NUMBER,
                                endperson IN NUMBER,
                                chunk IN NUMBER);
/* changes for P45PT_3 end */

/*Changes for P45PT_3 Version 6 Start*/
PROCEDURE p45pt_3_ver6_action_creation(pactid IN NUMBER,
                                stperson IN NUMBER,
                                endperson IN NUMBER,
                                chunk IN NUMBER);
/*Changes for P45PT_3 Version 6 End*/
--
PROCEDURE p46_action_creation(pactid IN NUMBER,
                              stperson IN NUMBER,
                              endperson IN NUMBER,
                              chunk IN NUMBER);
--
PROCEDURE p46_5_action_creation   (pactid    in number,
                                 stperson  in number,
                                 endperson in number,
                                 chunk     in number);

--
/*P46 Version6 EOY Changes Start*/
PROCEDURE p46_ver6_action_creation   (pactid    in number,
                                 stperson  in number,
                                 endperson in number,
                                 chunk     in number);
/*P46 Version6 EOY Changes End*/

	/*Changes for P46EXP_Ver6 starts*/
PROCEDURE P46EXP_VER6_ACTION_CREATION (pactid    in number,
                                     stperson  in number,
                                     endperson in number,
                                     chunk     in number);
	/*Changes for P46EXP_Ver6 End*/

PROCEDURE p46_pennot_action_creation(pactid IN NUMBER,
                                     stperson IN NUMBER,
                                     endperson IN NUMBER,
                                     chunk IN NUMBER);

/**UK EOY P46 PENNOT --- Corresponds to CP PENNOT EDI Process **/
PROCEDURE p46_5_pennot_action_creation(pactid IN NUMBER,
                                     stperson IN NUMBER,
                                     endperson IN NUMBER,
                                     chunk IN NUMBER);

--
/**UK EOY 08-09 P46 PENNOT --- Corresponds to CP PENNOT EDI Process **/
PROCEDURE P46_VER6_PENNOT_ACT_CREATION(pactid IN NUMBER,
                                     stperson IN NUMBER,
                                     endperson IN NUMBER,
                                     chunk IN NUMBER);
--
PROCEDURE archive_code (p_assactid         IN   NUMBER,
                        p_effective_date   IN   DATE);
--
PROCEDURE deinitialization_code(pactid IN NUMBER);
--
FUNCTION date_validate (c_assignment_action_id  NUMBER,
                            p_mode                  VARCHAR2,
                            p_validate_date         DATE)
RETURN NUMBER;

function edi_errors_log(assignment_number  IN   varchar2,
                          ni_number        IN   varchar2,
                          first_name       IN   varchar2,
                          last_name        IN   varchar2,
                          middle_name      IN   varchar2,
                          title            IN   varchar2,
                          status           IN   varchar2)
RETURN NUMBER;

--For bug 9255173:
/*P46 Version6 eText Changes Start*/
PROCEDURE p46_ver6et_action_creation (pactid    in number,
                                 stperson  in number,
                                 endperson in number,
                                 chunk     in number);

FUNCTION tax_dist_etext_vals(p_tst_indi  in varchar2,
                             p_tst_id  in varchar2,
                             p_tax_ref  in varchar2,
                             p_employer_name in varchar2)
Return BOOLEAN;
/*P46 Version6 eText Changes End*/

--For bug 9255183:
/*P46Expat eText Changes Start*/
PROCEDURE P46EXP_VER6ET_ACTION_CREATION (pactid    in number,
                                     stperson  in number,
                                     endperson in number,
                                     chunk     in number);

g_archive_type varchar2(20);
/*P46Expat eText Changes End*/

TYPE edi_errors IS RECORD
    (assignment_number varchar2(100),
     ni_number     varchar2(30),
     first_name    varchar2(100),
     last_name     varchar2(100),
     middle_name   varchar2(100),
     title         varchar2(100),
     status        varchar2(100));

TYPE edi_errors_table IS TABLE OF
    edi_errors INDEX BY BINARY_INTEGER;

g_edi_errors_table edi_errors_table;

END PAY_GB_MOVDED_EDI;

/
