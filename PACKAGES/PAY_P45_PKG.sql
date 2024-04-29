--------------------------------------------------------
--  DDL for Package PAY_P45_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_P45_PKG" AUTHID CURRENT_USER as
/* $Header: payrp45.pkh 120.6.12010000.9 2009/05/06 04:12:57 jvaradra ship $ */
--
/*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +============================================================================
 Name
    PAY_P45_PKG
  Purpose
    Supports the VIEW P45 form (PAYWSR45) called from the form PAYGBTAX.
    This is a UK Specific form/package.
Notes

  History
    07-AUG-94   P.Shergil   40.0        Date Created.
    29-AUG-94   H.Minton    40.1        Added Function to get the formula id
    04-OCT-94   R.Fine      40.2        Renamed package to start PAY_
    08-MAR-2000 J. Moyano  115.1        Function get_student_loan_flag added.
    14-AUG-2000 A.Parkes   115.2        Added P45 Archiver hooks and cursors.
    08-FEB-2001 S.Robinson 115.3        Procedure pop_term_from_archive added.
    19-FEB-2001 A.Parkes   115.4        Removed action_status from
                                        csr_edi_assignments select.
                                        Added get_report_request_error func
    29-MAR-2001 A.Parkes   115.5        Put space in RECEIVER_ID value.
                           115.6        842703 added X_TRANSFER_DATE param
                                        to get_data
    17-FEB-2002 S.Robinson 115.7        Added dbdrv commands.
    27-FEB-2002 K.Thampan  115.8        Added X_STUDENT_LOAN_FLAG to procedure
                                        pop_term_asg_from_archive
    12-Dec-2002 A.Mills    115.9        Added nocopy via utility
    20-Aug-2003 A.Mills    115.9        Agg PAYE changes.
    13-May-2004 K.Thampan  115.12       Put NONE in the field where NI number
                                        is not available on P45 EDI file
    18-JAN-2005 navesriv   115.13       Displayed Employee PAYE Reference in full
                                        by increasing the length of the field
    26-APR-2005 kthampan   115.14       Add one parameter to the procedure
                                        pop_term_asg_from_archive
    19-JUN-2006 K.Thampan  115.15       Substr title to 4 chars. Bug 5169434
    04-SEP-2006 ajeyam     115.16       New proc/functions created to find whether
                                        P45 issued (or) not for the given
                                        assignment. Bug 5144323
    05-SEP-2006 ajeyam     115.17       Parameters added/changed for new report-
                                        show the p45 issued for act asgs 5144323
    13-NOV-2007 parusia    115.18       Added 2 new cursors csr_tax_district and
                                        csr_edi_assignments for P45PT1. Bug 6345375
    27-DEC-2007 rlingama   115.19       Modified X_COUNTY to X_COUNTRY in
                                        csr_movded5_edi_assignments cursor.Bug 6710197
     4-Jan-2008 parusia    115.20       Selected middle_name also from cursor
                                        csr_movded5_edi_assignments. Bug 6710229
    14-May-2008 rlingama   115.21       Bug 7028893.Added function PAYE_RETURN_P45_ISSUED_FLAG.
    16-OCT-2008 vijranga   115.22	Added 2 new cursors csr_movded_ver6_tax_district
                                        csr_movded_ver6_edi_assignments for P45PT1.
					Bug 7433580.
    17-OCT-2008 vijranga   115.23      	Renamed cursor csr_movded_ver6_edi_assignments to
                                        csr_movded_ver6_edi_assignment.	Bug 7433580.
    22-OCT-2008	vijranga   115.24       Changed FORM_TYPE_MEANING for ver6 in
                                        csr_movded_ver6_tax_district.
    10-DEC-2008 rlingama   115.27       P45 A4 2008-09 Changes.Bug 7261906
    04-May-2009 jvaradra   115.28       Bug 7601088 Added function PAYE_SYNC_P45_ISSUED_FLAG
     ============================================================================*/
--
-- CURSORS
CURSOR csr_tax_district IS
SELECT 'SENDER_ID=P', upper(nvl(org_information11,' ')),
  'RECEIVER_ID=P', 'INLAND REVENUE',
  'TEST_INDICATOR=P', decode(pay_gb_eoy_archive.get_parameter
                        (legislative_parameters,
			 'TEST'),'Y','1',' '),
  'URGENT_MARKER=P',  decode(pay_gb_eoy_archive.get_parameter
                        (legislative_parameters,
			 'URGENT'),'Y','Y',' '),
  'REQUEST_ID=P', fnd_number.number_to_canonical(pact.request_id),
  'FORM_TYPE=P', '4',
  'FORM_TYPE_MEANING=P', 'P45',
  'TAX_DIST_NO=P', substr(hoi.org_information1,1,3),
  'TAX_DIST_REF=P',
  upper(substr(ltrim(substr(hoi.org_information1,4,11),'/') ,1,10)),                    /* Bug no 4086012    */
  'TAX_DISTRICT=P', upper(nvl(substr(hoi.org_information2 ,1,40),' ')),
  'EMPLOYERS_ADDRESS_LINE=P',
  upper(nvl(substr(hoi.org_information4,1,60),' ')),
  'EMPLOYERS_NAME=P', upper(nvl(substr(hoi.org_information3,1,36),' '))
FROM  pay_payroll_actions pact,
      hr_organization_information hoi
WHERE pact.payroll_action_id = pay_magtape_generic.get_parameter_value
                                     ('TRANSFER_PAYROLL_ACTION_ID')
  AND   hoi.org_information_context = 'Tax Details References'
  AND    substr(pact.legislative_parameters,
                instr(pact.legislative_parameters,'TAX_REF=') + 8,
                    instr(pact.legislative_parameters||' ',' ',
                          instr(pact.legislative_parameters,'TAX_REF=')+8)
		- instr(pact.legislative_parameters,'TAX_REF=') - 8)
           = hoi.org_information1
  AND hoi.organization_id = pact.business_group_id;
--
CURSOR csr_edi_assignments IS
SELECT
  'ASSIGNMENT_ACTION_ID=C', act.assignment_action_id,
  'CHARS_ALREADY_TESTED=P', pay_gb_eoy_archive.get_parameter
                              (pact.legislative_parameters,'CHAR_ERROR'),
  'ADDRESS_LINE1=P',
  upper(nvl(max(decode(fue.user_entity_name,
                       'X_ADDRESS_LINE1',substr(fai.VALUE,1,35))),' ')),
  'ADDRESS_LINE2=P',
  upper(nvl(max(decode(fue.user_entity_name,
                       'X_ADDRESS_LINE2',substr(fai.VALUE,1,35))),' ')),
  'ADDRESS_LINE3=P',
  upper(nvl(max(decode(fue.user_entity_name,
                       'X_ADDRESS_LINE3',substr(fai.VALUE,1,35))),' ')),
  'ASSIGNMENT_NUMBER=P',
  upper(nvl(max(decode(fue.user_entity_name,
		       'X_ASSIGNMENT_NUMBER',
		       substr(fai.VALUE,1,20))),' ')),
  'COUNTY=P',
  upper(nvl(max(decode(fue.user_entity_name,'X_COUNTY',
		       substr(fai.VALUE,1,35))),' ')),
  'FIRST_NAME=P',
  nvl(max(decode(fue.user_entity_name,'X_FIRST_NAME',
		 substr(upper(fai.VALUE),1,35))),' '),
  'LAST_NAME=P',
  nvl(max(decode(fue.user_entity_name,'X_LAST_NAME',
		 substr(upper(fai.VALUE),1,35))),' '),
  'NATIONAL_INSURANCE_NUMBER=P',
  nvl(max(decode(fue.user_entity_name,
		 'X_NATIONAL_INSURANCE_NUMBER',
		 substr(upper(fai.VALUE),1,9))),'NONE'),
  'POSTAL_CODE=P',
  nvl(max(decode(fue.user_entity_name,'X_POSTAL_CODE',
		 substr(upper(fai.VALUE),1,9))),' '),
  'TITLE=P',
  nvl(max(decode(fue.user_entity_name,'X_TITLE',
		 substr(upper(fai.VALUE),1,4))),' '),
  'TOWN_OR_CITY=P',
  upper(nvl(max(decode(fue.user_entity_name,
		       'X_TOWN_OR_CITY',
		       substr(fai.VALUE,1,35))),' '))
FROM   pay_assignment_actions act_edi,
       pay_action_interlocks  pai,
       pay_assignment_actions act,
       pay_payroll_actions    pact,
       ff_archive_items       fai,
       ff_user_entities       fue
WHERE  act_edi.payroll_action_id = pay_magtape_generic.get_parameter_value
                                         ('TRANSFER_PAYROLL_ACTION_ID')
  AND  act_edi.assignment_action_id = pai.locking_action_id
  AND  act.assignment_action_id     = pai.locked_action_id
  AND  pact.payroll_action_id       = act.payroll_action_id
  AND  act.assignment_action_id     = fai.context1
  AND  fai.archive_type              <> 'PA'
  AND  fai.user_entity_id           = fue.user_entity_id
GROUP  BY act.assignment_action_id, pay_gb_eoy_archive.get_parameter
                                (pact.legislative_parameters,'CHAR_ERROR'),
          act.action_status
ORDER  BY 12;
--
--
/* Added for P45PT1 ( Bug 6345375 ) */
CURSOR csr_movded5_tax_district IS
SELECT 'SENDER_ID=P', upper(nvl(org_information11,' ')),
  'RECEIVER_ID=P'   , 'HMRC',
  'TEST_INDICATOR=P', decode(pay_gb_eoy_archive.get_parameter
                        (legislative_parameters,
                         'TEST'),'Y','1',' '),
  'URGENT_MARKER=P' ,  ' ',
  'REQUEST_ID=P'    , fnd_number.number_to_canonical(pact.request_id),
  'FORM_TYPE=P'     , '4',
  'FORM_TYPE_MEANING=P', 'P45PT1',
  'TAX_DIST_NO=P'   , substr(hoi.org_information1,1,3),
  'TAX_DIST_REF=P'  , upper(substr(ltrim(substr(hoi.org_information1,4,11),'/') ,1,10)),  /* Bug no 4086012    */
  'TAX_DISTRICT=P'  , upper(nvl(substr(hoi.org_information2 ,1,40),' ')),
  'EMPLOYERS_ADDRESS_LINE=P', upper(nvl(substr(hoi.org_information4,1,60),' ')),
  'EMPLOYERS_NAME=P', upper(nvl(substr(hoi.org_information3,1,36),' ')),
  'TEST_ID=P'       , nvl(pay_gb_eoy_archive.get_parameter
                         (legislative_parameters,
                          'TEST_ID'),' ') /*added for P45PT1*/
FROM  pay_payroll_actions pact,
      hr_organization_information hoi
WHERE pact.payroll_action_id = pay_magtape_generic.get_parameter_value
                                     ('TRANSFER_PAYROLL_ACTION_ID')
  AND   hoi.org_information_context = 'Tax Details References'
  AND    substr(pact.legislative_parameters,
                instr(pact.legislative_parameters,'TAX_REF=') + 8,
                    instr(pact.legislative_parameters||' ',' ',
                          instr(pact.legislative_parameters,'TAX_REF=')+8)
		- instr(pact.legislative_parameters,'TAX_REF=') - 8)
           = hoi.org_information1
  AND hoi.organization_id = pact.business_group_id;
--
CURSOR csr_movded5_edi_assignments IS
SELECT
  'ASSIGNMENT_ACTION_ID=C', act.assignment_action_id,
  'CHARS_ALREADY_TESTED=P', pay_gb_eoy_archive.get_parameter
                              (pact.legislative_parameters,'CHAR_ERROR'),
  'ADDRESS_LINE1=P',
  upper(nvl(max(decode(fue.user_entity_name,
                       'X_ADDRESS_LINE1',substr(fai.VALUE,1,35))),' ')),
  'ADDRESS_LINE2=P',
  upper(nvl(max(decode(fue.user_entity_name,
                       'X_ADDRESS_LINE2',substr(fai.VALUE,1,35))),' ')),
  'ADDRESS_LINE3=P',
  upper(nvl(max(decode(fue.user_entity_name,
                       'X_ADDRESS_LINE3',substr(fai.VALUE,1,35))),' ')),
  'ASSIGNMENT_NUMBER=P',
  upper(nvl(max(decode(fue.user_entity_name,
		       'X_ASSIGNMENT_NUMBER',
		       substr(fai.VALUE,1,20))),' ')),
  'COUNTY=P',
  upper(nvl(max(decode(fue.user_entity_name,'X_COUNTRY',
		       substr(fai.VALUE,1,35))),' ')), /* Country parameter*/
  'FIRST_NAME=P',
  nvl(max(decode(fue.user_entity_name,'X_FIRST_NAME',
		 substr(upper(fai.VALUE),1,35))),' '),
  'MIDDLE_NAME=P',   /*Bug 6710229*/
  nvl(max(decode(fue.user_entity_name,'X_MIDDLE_NAME',
		 substr(upper(fai.VALUE),1,35))),' '),
  'LAST_NAME=P',
  nvl(max(decode(fue.user_entity_name,'X_LAST_NAME',
		 substr(upper(fai.VALUE),1,35))),' '),
  'NATIONAL_INSURANCE_NUMBER=P',
  nvl(max(decode(fue.user_entity_name,
		 'X_NATIONAL_INSURANCE_NUMBER',
		 substr(upper(fai.VALUE),1,9))),' '),
  'POSTAL_CODE=P',
  nvl(max(decode(fue.user_entity_name,'X_POSTAL_CODE',
		 substr(upper(fai.VALUE),1,9))),' '),
  'TITLE=P',
  nvl(max(decode(fue.user_entity_name,'X_TITLE',
		 substr(upper(fai.VALUE),1,4))),' '),
  'TOWN_OR_CITY=P',
  upper(nvl(max(decode(fue.user_entity_name,
		       'X_TOWN_OR_CITY',
		       substr(fai.VALUE,1,35))),' ')),
  'EFFECTIVE_DATE=P',      fnd_date.date_to_canonical(pact.effective_date)
FROM   pay_assignment_actions act_edi,
       pay_action_interlocks  pai,
       pay_assignment_actions act,
       pay_payroll_actions    pact,
       ff_archive_items       fai,
       ff_user_entities       fue
WHERE  act_edi.payroll_action_id = pay_magtape_generic.get_parameter_value
                                         ('TRANSFER_PAYROLL_ACTION_ID')
  AND  act_edi.assignment_action_id = pai.locking_action_id
  AND  act.assignment_action_id     = pai.locked_action_id
  AND  pact.payroll_action_id       = act.payroll_action_id
  AND  act.assignment_action_id     = fai.context1
  AND  fai.archive_type              <> 'PA'
  AND  fai.user_entity_id           = fue.user_entity_id
GROUP  BY act.assignment_action_id, pay_gb_eoy_archive.get_parameter
                                (pact.legislative_parameters,'CHAR_ERROR'),
          act.action_status, fnd_date.date_to_canonical(pact.effective_date)
ORDER  BY 12;
/* Addition for P45PT1 ( Bug 6345375 ) ends*/
--
/* Added for P45PT1 Ver6 changes starts */
CURSOR csr_movded_ver6_tax_district IS
SELECT 'SENDER_ID=P', upper(nvl(org_information11,' ')),
  'RECEIVER_ID=P'   , 'HMRC',
  'TEST_INDICATOR=P', decode(pay_gb_eoy_archive.get_parameter
                        (legislative_parameters,
                         'TEST'),'Y','1',' '),
  'URGENT_MARKER=P' ,  ' ',
  'REQUEST_ID=P'    , fnd_number.number_to_canonical(pact.request_id),
  'FORM_TYPE=P'     , '4',
  'FORM_TYPE_MEANING=P', 'P45PT1_VER6',
  'TAX_DIST_NO=P'   , substr(hoi.org_information1,1,3),
  'TAX_DIST_REF=P'  , upper(substr(ltrim(substr(hoi.org_information1,4,11),'/') ,1,10)),
  'TAX_DISTRICT=P'  , upper(nvl(substr(hoi.org_information2 ,1,40),' ')),
  'EMPLOYERS_ADDRESS_LINE=P', upper(nvl(substr(hoi.org_information4,1,60),' ')),
  'EMPLOYERS_NAME=P', upper(nvl(substr(hoi.org_information3,1,36),' ')),
  'TEST_ID=P'       , nvl(pay_gb_eoy_archive.get_parameter
                         (legislative_parameters,
                          'TEST_ID'),' ') /*added for P45PT1*/
FROM  pay_payroll_actions pact,
      hr_organization_information hoi
WHERE pact.payroll_action_id = pay_magtape_generic.get_parameter_value
                                     ('TRANSFER_PAYROLL_ACTION_ID')
  AND   hoi.org_information_context = 'Tax Details References'
  AND    substr(pact.legislative_parameters,
                instr(pact.legislative_parameters,'TAX_REF=') + 8,
                    instr(pact.legislative_parameters||' ',' ',
                          instr(pact.legislative_parameters,'TAX_REF=')+8)
		- instr(pact.legislative_parameters,'TAX_REF=') - 8)
           = hoi.org_information1
  AND hoi.organization_id = pact.business_group_id;
--
CURSOR csr_movded_ver6_edi_assignment IS
SELECT
  'ASSIGNMENT_ACTION_ID=C', act.assignment_action_id,
  'CHARS_ALREADY_TESTED=P', pay_gb_eoy_archive.get_parameter
                              (pact.legislative_parameters,'CHAR_ERROR'),
  'ADDRESS_LINE1=P',
  upper(nvl(max(decode(fue.user_entity_name,
                       'X_ADDRESS_LINE1',substr(fai.VALUE,1,35))),' ')),
  'ADDRESS_LINE2=P',
  upper(nvl(max(decode(fue.user_entity_name,
                       'X_ADDRESS_LINE2',substr(fai.VALUE,1,35))),' ')),
  'ADDRESS_LINE3=P',
  upper(nvl(max(decode(fue.user_entity_name,
                       'X_ADDRESS_LINE3',substr(fai.VALUE,1,35))),' ')),
  'ASSIGNMENT_NUMBER=P',
  upper(nvl(max(decode(fue.user_entity_name,
		       'X_ASSIGNMENT_NUMBER',
		       substr(fai.VALUE,1,20))),' ')),
  'COUNTY=P',
  upper(nvl(max(decode(fue.user_entity_name,'X_COUNTRY',
		       substr(fai.VALUE,1,35))),' ')), /* Country parameter*/
  'FIRST_NAME=P',
  nvl(max(decode(fue.user_entity_name,'X_FIRST_NAME',
		 substr(upper(fai.VALUE),1,35))),' '),
  'MIDDLE_NAME=P',   /*Bug 6710229*/
  nvl(max(decode(fue.user_entity_name,'X_MIDDLE_NAME',
		 substr(upper(fai.VALUE),1,35))),' '),
  'LAST_NAME=P',
  nvl(max(decode(fue.user_entity_name,'X_LAST_NAME',
		 substr(upper(fai.VALUE),1,35))),' '),
  'NATIONAL_INSURANCE_NUMBER=P',
  nvl(max(decode(fue.user_entity_name,
		 'X_NATIONAL_INSURANCE_NUMBER',
		 substr(upper(fai.VALUE),1,9))),' '),
  'POSTAL_CODE=P',
  nvl(max(decode(fue.user_entity_name,'X_POSTAL_CODE',
		 substr(upper(fai.VALUE),1,9))),' '),
  'TITLE=P',
  nvl(max(decode(fue.user_entity_name,'X_TITLE',
		 substr(upper(fai.VALUE),1,4))),' '),
  'TOWN_OR_CITY=P',
  upper(nvl(max(decode(fue.user_entity_name,
		       'X_TOWN_OR_CITY',
		       substr(fai.VALUE,1,35))),' ')),
  'EFFECTIVE_DATE=P',      fnd_date.date_to_canonical(pact.effective_date)
FROM   pay_assignment_actions act_edi,
       pay_action_interlocks  pai,
       pay_assignment_actions act,
       pay_payroll_actions    pact,
       ff_archive_items       fai,
       ff_user_entities       fue
WHERE  act_edi.payroll_action_id = pay_magtape_generic.get_parameter_value
                                         ('TRANSFER_PAYROLL_ACTION_ID')
  AND  act_edi.assignment_action_id = pai.locking_action_id
  AND  act.assignment_action_id     = pai.locked_action_id
  AND  pact.payroll_action_id       = act.payroll_action_id
  AND  act.assignment_action_id     = fai.context1
  AND  fai.archive_type              <> 'PA'
  AND  fai.user_entity_id           = fue.user_entity_id
GROUP  BY act.assignment_action_id, pay_gb_eoy_archive.get_parameter
                                (pact.legislative_parameters,'CHAR_ERROR'),
          act.action_status, fnd_date.date_to_canonical(pact.effective_date)
ORDER  BY 12;
--
--
  level_cnt number; -- required by the generic magtape procedure.
-- FUNCTION get_report_request_error
-- Function to retrieve the global g_fnd_rep_request_msg which will be
-- populated with the fnd message in the event of the P45 report submission
-- failing.
FUNCTION get_report_request_error RETURN VARCHAR2;
--
-- PROCEDURE range_cursor
-- Procedure which returns a varchar2 defining a SQL Statement to select
-- all the people in the business group.
-- The archiver uses this cursor to split the people into chunks for parallel
-- processing.
-- This procedure is used for both the P45 Archive process and the P45 EDI
-- process.  When called by the P45 Archive process it also archives the
-- tax ref. info.
PROCEDURE range_cursor (pactid IN NUMBER,
                        sqlstr out nocopy varchar2);
--
PROCEDURE arch_act_creation(pactid IN NUMBER,
                            stperson IN NUMBER,
                            endperson IN NUMBER,
                            chunk IN NUMBER);
--
PROCEDURE archinit(p_payroll_action_id IN NUMBER);
--
PROCEDURE archive_code(p_assactid IN NUMBER, p_effective_date IN DATE);
--
-- PROCEDURE spawn_reports
-- This is the procedure called after P45 archiving has taken place.  It is
-- called as the magtape hook, but instead of creating a file, it is used to
-- spawn the P45 report.  It will call the PAY_GB_P45_REPORT_SUBMISSION
-- formula to report the report request id and to stop the magtape process.
PROCEDURE spawn_reports;
--
PROCEDURE edi_act_creation(pactid IN NUMBER,
                            stperson IN NUMBER,
                            endperson IN NUMBER,
                            chunk IN NUMBER);
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   get_p45_formula_id                                                   --
-- Purpose                                                                 --
--   this function finds the formula id for the validation of the PAYE     --
--   tax_code element entry value.
-----------------------------------------------------------------------------
--
FUNCTION get_p45_formula_id RETURN NUMBER;
-----------------------------------------------------------------------------
--
--
-----------------------------------------------------------------------------
--
-- Name                                                                    --
--   get_student_loan_flag                                                 --
-- Purpose                                                                 --
--   this function finds if the employee has a Student Loan effective at   --
--   the time employment ceases. Returns 'Y' if 'End Date' is not prior    --
--   or equal to the termination date.                                     --
-----------------------------------------------------------------------------
--
FUNCTION get_student_loan_flag (p_assignment_id in NUMBER,
                                p_termination_date in DATE,
                                p_session_date in DATE) RETURN VARCHAR2;
--
--
-----------------------------------------------------------------------------

procedure get_data(X_PERSON_ID     in number,
                   X_SESSION_DATE  in date,
                   X_ADDRESS_LINE1 in out nocopy varchar2,
                   X_ADDRESS_LINE2 in out nocopy varchar2,
                   X_ADDRESS_LINE3 in out nocopy varchar2,
                   X_TOWN_OR_CITY  in out nocopy varchar2,
                   X_REGION_1      in out nocopy varchar2,
                   X_COUNTRY       in out nocopy varchar2,
                   X_POSTAL_CODE   in out nocopy varchar2,
                   X_ASSIGNMENT_ID        in     number,
                   X_ASSIGNMENT_ACTION_ID in out nocopy number,
                   X_ASSIGNMENT_END_DATE    in     date,
                   X_DATE_EARNED          in out nocopy date,
                   X_PAYROLL_ACTION_ID    in out nocopy number,
                   X_TRANSFER_DATE        in     date default
                                                 hr_general.end_of_time);

procedure get_data(X_PERSON_ID     in number,
                   X_SESSION_DATE  in date,
                   X_ADDRESS_LINE1 in out nocopy varchar2,
                   X_ADDRESS_LINE2 in out nocopy varchar2,
                   X_ADDRESS_LINE3 in out nocopy varchar2,
                   X_TOWN_OR_CITY  in out nocopy varchar2,
                   X_REGION_1      in out nocopy varchar2,
                   X_COUNTRY       in out nocopy varchar2,
                   X_POSTAL_CODE   in out nocopy varchar2,
                   X_ASSIGNMENT_ID        in     number,
                   X_ASSIGNMENT_ACTION_ID in out nocopy number,
                   X_ASSIGNMENT_END_DATE    in     date,
                   X_DATE_EARNED          in out nocopy date,
                   X_PAYROLL_ACTION_ID    in out nocopy number,
                   X_EMPLOYER_NAME        in out nocopy varchar2,
                   X_EMPLOYER_ADDRESS     in out nocopy varchar2,
                   X_TRANSFER_DATE        in     date default
                                                 hr_general.end_of_time);

procedure get_form_query_data(X_ASSIGNMENT_ID           in number,
                              X_LAST_NAME               in out nocopy varchar2,
                              X_TITLE                   in out nocopy varchar2,
                              X_FIRST_NAME              in out nocopy varchar2,
                              X_NATIONAL_IDENTIFIER     in out nocopy varchar2,
                              X_PERSON_ID               in out nocopy number,
                              X_ACTUAL_TERMINATION_DATE in out nocopy date,
                              X_DECEASED_FLAG           in out nocopy varchar2,
                              X_ASSIGNMENT_NUMBER       in out nocopy varchar2,
                              X_PAYROLL_ID              in out nocopy number,
                              X_ORGANIZATION_ID         in out nocopy number,
                              X_ORG_NAME                in out nocopy varchar2,
                              X_DATE_OF_BIRTH           in out nocopy date,      /*P45 A4 2008/09*/
                              X_SEX                     in out nocopy varchar2); /*P45 A4 2008/09*/

procedure pop_term_asg_from_archive(X_ASSIGNMENT_ACTION_ID  in number,
                                X_NI1                   in out nocopy varchar2,
                                X_NI2                   in out nocopy varchar2,
                                X_NI3                   in out nocopy varchar2,
                                X_NI4                   in out nocopy varchar2,
                                X_NI5                   in out nocopy varchar2,
                                X_NI6                   in out nocopy varchar2,
                                X_NI7                   in out nocopy varchar2,
                                X_NI8                   in out nocopy varchar2,
                                X_NI9                   in out nocopy varchar2,
                                X_LAST_NAME             in out nocopy varchar2,
                                X_TITLE                 in out nocopy varchar2,
                                X_FIRST_NAME            in out nocopy varchar2,
                                X_DATE_OF_LEAVING_DD    in out nocopy varchar2,
                                X_DATE_OF_LEAVING_MM    in out nocopy varchar2,
                                X_DATE_OF_LEAVING_YY    in out nocopy varchar2,
                                X_TAX_CODE_AT_LEAVING   in out nocopy varchar2,
                                X_WK1_OR_MTH1           in out nocopy varchar2,
                                X_WEEK_NO               in out nocopy varchar2,
                                X_MONTH_NO              in out nocopy varchar2,
                                X_PAY_TD_POUNDS         in out nocopy number,
                                X_PAY_TD_PENCE          in out nocopy number,
                                X_TAX_TD_POUNDS         in out nocopy number,
                                X_TAX_TD_PENCE          in out nocopy number,
                                X_PAY_IN_EMP_POUNDS     in out nocopy number,
                                X_PAY_IN_EMP_PENCE      in out nocopy number,
                                X_TAX_IN_EMP_POUNDS     in out nocopy number,
                                X_TAX_IN_EMP_PENCE      in out nocopy number,
                                X_ASSIGNMENT_NUMBER     in out nocopy varchar2,
                                X_ORG_NAME              in out nocopy varchar2,
                                X_ADDRESS_LINE1         in out nocopy varchar2,
                                X_ADDRESS_LINE2         in out nocopy varchar2,
                                X_ADDRESS_LINE3         in out nocopy varchar2,
                                X_TOWN_OR_CITY          in out nocopy varchar2,
                                X_REGION_1              in out nocopy varchar2,
                                X_POSTAL_CODE           in out nocopy varchar2,
                                X_DECEASED_FLAG         in out nocopy varchar2,
                                X_ISSUE_DATE            in out nocopy varchar2,
                                X_TAX_REF_TRANSFER      in out nocopy varchar2,
                                X_STUDENT_LOAN_FLAG     in out nocopy varchar2,
                                X_COUNTRY               in out nocopy varchar2,
                                X_DATE_OF_BIRTH_DD      in out nocopy varchar2,    /* Start P45 A4 2008/09*/
                                X_DATE_OF_BIRTH_MM      in out nocopy varchar2,
                                X_DATE_OF_BIRTH_YY      in out nocopy varchar2,
                                X_SEX_M                 in out nocopy varchar2,
                                X_SEX_F                 in out nocopy varchar2    /* End P45 A4 2008/09*/);

Procedure pop_term_pact_from_archive (X_PAYROLL_ACTION_ID in number,
                                X_EMPLOYER_NAME         in out nocopy varchar2,
                                X_EMPLOYER_ADDRESS      in out nocopy varchar2);
--------------------------------------------------------------------------
-- name get_p45_asg_action_id
-- Purpose
-- Get P45 Assignment Action id, Issue Date
-- for the given Assignment ID
--------------------------------------------------------------------------
PROCEDURE get_p45_asg_action_id(p_assignment_id        in number,
                                p_assignment_action_id out nocopy number,
                                p_issue_date           out nocopy date,
                                p_action_sequence      out nocopy number
                                );
--------------------------------------------------------------------------
-- name get_p45_eit_manual_issue_dt
-- purpose
-- Get the P45 Manual Issue date from Extra Info. table
-- for the given Assignment ID
--------------------------------------------------------------------------
FUNCTION get_p45_eit_manual_issue_dt(p_assignment_id in number) RETURN DATE;

--------------------------------------------------------------------------
-- name get_p45_agg_asg_action_id
-- Get the Aggregated Assignment Id, Assignment Action id,
-- Final Payment Date for which the P45 been issued
--------------------------------------------------------------------------
PROCEDURE get_p45_agg_asg_action_id(p_assignment_id         in number,
                                    p_agg_assignment_id     out nocopy number,
                                    p_final_payment_date    out nocopy date,
                                    p_p45_issue_date        out nocopy date,
                                    p_p45_agg_asg_action_id out nocopy number
                                   );

--------------------------------------------------------------------------
-- name return_p45_issued_flag
--
-- Purpose                                                                 --
--   this function returns whether the P45 is issued or not for the given  --
--   assignment (Y-Yes/N-No)
-----------------------------------------------------------------------------
FUNCTION return_p45_issued_flag(p_assignment_id in number) RETURN VARCHAR2;

-- Bug 7028893.Added function PAYE_RETURN_P45_ISSUED_FLAG.
--------------------------------------------------------------------------
-- FUNCTION paye_return_p45_issued_flag
-- DESCRIPTION return the P45 issued status for the given assignment (Y-Yes/N-No)
--------------------------------------------------------------------------
FUNCTION paye_return_p45_issued_flag(p_assignment_id in number,p_payroll_action_id in number) RETURN VARCHAR2;

-- Bug 7601088.Added function PAYE_SYNC_P45_ISSUED_FLAG.
--------------------------------------------------------------------------
-- FUNCTION PAYE_SYNC_P45_ISSUED_FLAG
-- DESCRIPTION return the P45 issued status for the given assignment (Y-Yes/N-No)
--------------------------------------------------------------------------
FUNCTION PAYE_SYNC_P45_ISSUED_FLAG(p_assignment_id in number,p_effective_date in date) RETURN VARCHAR2;

END PAY_P45_PKG;

/
