--------------------------------------------------------
--  DDL for Package PAY_AU_TFN_MAGTAPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_TFN_MAGTAPE" AUTHID CURRENT_USER AS
/* $Header: pyautfn.pkh 120.6.12010000.5 2009/10/30 11:50:29 dduvvuri ship $*/
--------------------------------------------------------------------------+



--------------------------------------------------------------------------+
-- The variable is used to decide wether tax details are getting
-- updated using  API or from form PAYAUTAX .
-- If called from FORM the varables is initialized to 'FORM'
--------------------------------------------------------------------------+
/* Bug 4066194 - Removed default settings to resolve GSCC Warnings */

tax_api_called_from        varchar2(10);

/*Bug 5367067  variable  inv_character_string is used to store set of invalid characters
               variable  blank_character_string is used to store the blank character the no of spaces should be
	       equal to number of invalid characters in inv_character_string     */

inv_character_string       varchar2(40) default ',_$#+@`!*^%~[]{};:\|?><.';  /* 9000052 - Added a dot character */
blank_character_string     varchar2(40) default '                        ';  /* 9000052 - Added an extra space for the above dot character */


level_cnt number;

/* Bug 4066194 -
   Removed Record Type - tfn_flags_record
   Procedure - populate_tfn_flags
   Function  - get_tfn_flag_values
*/

--------------------------------------------------------------------------+
-- PROCEDURE to return the sql statement to select the range of employees
-- to be processed.
--------------------------------------------------------------------------+
PROCEDURE range_code
      (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%TYPE,
       p_sql                out nocopy varchar2);




--------------------------------------------------------------------------+
-- PROCEDURE to further restrict the assignments to be processed by the
-- archive process.
--------------------------------------------------------------------------+
PROCEDURE assignment_action_code
      (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%TYPE,
       p_start_person_id    in per_all_people_f.person_id%TYPE,
       p_end_person_id      in per_all_people_f.person_id%TYPE,
       p_chunk              in number);




--------------------------------------------------------------------------+
-- PROCEDURE to initialize the globals, plsql tables and contexts.
--------------------------------------------------------------------------+
PROCEDURE initialization_code
      (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%TYPE);




--------------------------------------------------------------------------+
-- PROCEDURE to actually archive the data.
--------------------------------------------------------------------------+
PROCEDURE archive_code
      (p_payroll_action_id  in pay_assignment_actions.payroll_action_id%TYPE,
       p_effective_date     in date);


--------------------------------------------------------------------------+
-- PROCEDURE to set the value of the variable tax_api_called_from.
--------------------------------------------------------------------------+
PROCEDURE set_value
      (p_value             in varchar2);




--------------------------------------------------------------------------+
-- FUNCTION to get the value of the variable tax_api_called_from.
--------------------------------------------------------------------------+
FUNCTION get_value return varchar2;


--------------------------------------------------------------------------+
-- Declaration of the cursors for the magtape process
--------------------------------------------------------------------------+

/*
**  Cursor to retrieve the Supplier Detail information
*/

/*Bug2920725   Corrected base tables to support security model*/
/* Bug 3229452 - Used fnd_date.canonical_to_date instead of to_date for selecting
                 REPORT_END_DATE*/
/* Bug 9000052 - Used function remove_extra_spaces in package pay_au_tfn_magtape_flags for reporting name fields correctly */
CURSOR C_TFN_SUPPLIER IS
SELECT
       'LEGAL_EMPLOYER_NAME=P'
      ,hou.name
      ,'SUPPLIER_NUMBER=P'
      ,hoi.org_information12
      ,'RUN_TYPE=P'
      ,pay_magtape_generic.get_parameter_value('RUN_TYPE')
      ,'REPORT_END_DATE=P'
      ,to_char(fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('REPORT_END_DATE')),'ddmmyyyy')
      ,'GATEWAY_USER_ID=P'
      ,NVL(hoi.org_information15,' ')
      ,'SUPPLIER_NAME=P'
      ,pay_au_tfn_magtape_flags.remove_extra_spaces(translate(hoi.org_information3,inv_character_string,blank_character_string)) /*Bug 9000052*/
      ,'CONTACT_NAME=P'
      ,pay_au_tfn_magtape_flags.remove_extra_spaces(translate(decode(pap.first_name,null,'',pap.first_name || ' ') || pap.last_name,inv_character_string,blank_character_string)) /*Bug 9000052*/
      ,'TELEPHONE_NUMBER=P'
      ,hoi.org_information14
      ,'SUPP_FILE_REFERENCE=P'
      ,nvl(pay_magtape_generic.get_parameter_value('SUPP_FILE_REF'),' ')
      ,'STREET_ADDRESS1=P'
      ,translate(nvl(hlc.address_line_1,' '),inv_character_string,blank_character_string)
      ,'STREET_ADDRESS2=P'
      ,translate(nvl(hlc.address_line_2,' '),inv_character_string,blank_character_string)
      ,'SUBURB=P'
      ,translate(nvl(hlc.town_or_city,' '),inv_character_string,blank_character_string)
      ,'STATE=P'
      ,nvl(hlc.region_1,' ')
      ,'POST_CODE=P'
      ,nvl(hlc.postal_code,' ')
      ,'COUNTRY=P'
      ,nvl(ftl.territory_short_name,' ')
      ,'SUPP_EMAIL=P'
      ,nvl(pap.email_address,' ')
  FROM   hr_organization_information hoi
        ,hr_locations_all            hlc     --Modified the table from hr_locations to hr_locations_all
        ,fnd_territories_tl          ftl
        ,hr_organization_units       hou
        ,per_people_f                pap
   WHERE  hou.business_group_id       = pay_magtape_generic.get_parameter_value('BUSINESS_GROUP_ID')
     AND  hou.organization_id         = hoi.organization_id
     AND  hoi.organization_id         = pay_magtape_generic.get_parameter_value('LEGAL_EMPLOYER')
     AND  hoi.org_information_context = 'AU_LEGAL_EMPLOYER'
     AND  ftl.territory_code          = hlc.country
     AND  ftl.language(+)             = userenv('LANG')
     AND  hlc.location_id(+)          = hou.location_id
     AND  hoi.org_information7        = pap.person_id
     AND  pap.effective_start_date    = (SELECT  max(effective_start_date)
                                           FROM  per_people_f p
                                          WHERE  pap.person_id=p.person_id
                                         and p.effective_start_date <=                     /* 5474358 */
fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('REPORT_END_DATE'))
                                         group by p.person_id);




/*
**  Cursor to retrieve the Payer(Employer) Detail information
*/

/*Bug2920725   Corrected base tables to support security model*/
/* Bug 9000052 - Used function remove_extra_spaces in package pay_au_tfn_magtape_flags for reporting name fields correctly */
CURSOR C_TFN_PAYER IS
SELECT
       'REPORT_START_DATE=P'
      ,to_char(to_date(pay_magtape_generic.get_parameter_value('REPORT_END_DATE'),'ddmmyyyy')-14,'ddmmyyyy')/*Bug 2974527*/
      ,'REPORT_END_DATE=P'
      ,pay_magtape_generic.get_parameter_value('REPORT_END_DATE')
      ,'PAYER_ABN=P'
      ,hoi.org_information12
      ,'BRANCH_NUMBER=P'
      ,nvl(hoi.org_information13,'001')   /* Bug#5570822 Setting Branch number to 001 to avoid ECI checker error*/
      ,'BUSINESS_NAME=P'
      ,pay_au_tfn_magtape_flags.remove_extra_spaces(translate(nvl(hoi.org_information3,' '),inv_character_string,blank_character_string)) /*Bug 9000052*/
      ,'TRADING_NAME=P'
      ,pay_au_tfn_magtape_flags.remove_extra_spaces(translate(nvl(hoi.org_information4,' '),inv_character_string,blank_character_string)) /*Bug 9000052*/
      ,'ADDRESS_LINE1=P'
      ,translate(nvl(hlc.address_line_1,' '),inv_character_string,blank_character_string)
      ,'ADDRESS_LINE2=P'
      ,translate(nvl(hlc.address_line_2,' '),inv_character_string,blank_character_string)
      ,'SUBURB=P'
      ,translate(nvl(hlc.town_or_city,' '),inv_character_string,blank_character_string)
      ,'STATE=P'
      ,nvl(hlc.region_1,' ')
      ,'POST_CODE=P'
      ,nvl(hlc.postal_code,' ')
      ,'COUNTRY=P'
      ,nvl(ftl.territory_short_name,' ')
      ,'CONTACT_NAME=P'
      ,pay_au_tfn_magtape_flags.remove_extra_spaces(translate(decode(pap.first_name,null,'',pap.first_name || ' ') || pap.last_name,inv_character_string,blank_character_string)) /*Bug 9000052*/
      ,'TELEPHONE_NUMBER=P'
      ,hoi.org_information14
  FROM   hr_organization_information hoi
        ,hr_locations_all            hlc   --Modified the table from hr_locations to hr_locations_all
        ,fnd_territories_tl          ftl
        ,hr_organization_units       hou
        ,per_people_f            pap
   WHERE  hou.business_group_id       = pay_magtape_generic.get_parameter_value('BUSINESS_GROUP_ID')
     AND  hou.organization_id         = hoi.organization_id
     AND  hoi.organization_id         = pay_magtape_generic.get_parameter_value('LEGAL_EMPLOYER')
     AND  hoi.org_information_context = 'AU_LEGAL_EMPLOYER'
     AND  ftl.territory_code          = hlc.country
     AND  ftl.language(+)             = userenv('LANG')
     AND  hlc.location_id(+)          = hou.location_id
     AND  hoi.org_information7        = pap.person_id
     AND  pap.effective_start_date    = (SELECT  max(effective_start_date)
                                           FROM  per_people_f p
                                          WHERE  pap.person_id=p.person_id
                                          and p.effective_start_date <=    /* 5474358 */
to_date(pay_magtape_generic.get_parameter_value('REPORT_END_DATE'),'DD-MM-YYYY')
                                         group by p.person_id  );



/*
**  Cursor to retrieve the Payee Detail information
*/

-------------------------------------------------------------+
-- The plsql table populated by the initialization_code will be
-- used to get the value of the reportable fields. Also the
-- assignment action inserted by the assignment_code will the
-- restriction condition for the employees to print on magtape
-------------------------------------------------------------+
/*Bug2920725   Corrected base tables to support security model*/
/*
Bug 4066194 - Changed Package reference to "pay_au_tfn_magtape_flags"
              Removed package self reference.

Bug4247686  - Modified for performance reason
*/

/* Bug 9000052 - Used function remove_extra_spaces in package pay_au_tfn_magtape_flags for reporting name fields correctly */
CURSOR C_TFN_PAYEE IS
SELECT
      'PAYEE_TFN=P'
      ,replace(pay_au_tfn_magtape_flags.get_tfn_flag_values(paa.assignment_id,'TAX_FILE_NUMBER'),' ','')
      ,'SURNAME=P'
      ,pay_au_tfn_magtape_flags.remove_extra_spaces(translate(pap.last_name,inv_character_string,blank_character_string)) /*Bug 9000052*/
      ,'FIRST_GIVEN_NAME=P'
      ,pay_au_tfn_magtape_flags.remove_extra_spaces(translate(nvl(pap.first_name,'NULL VALUE'),inv_character_string,blank_character_string)) /*Bug 9000052*/
      ,'SECOND_GIVEN_NAME=P'
      ,pay_au_tfn_magtape_flags.remove_extra_spaces(translate(nvl(pap.middle_names,' '),inv_character_string,blank_character_string)) /*Bug 9000052*/
      ,'EMPLOYEE_NUMBER=P'
      ,nvl(pap.employee_number,' ')
      ,'PREVIOUS_SURNAME=P'
      ,pay_au_tfn_magtape_flags.remove_extra_spaces(translate(nvl(pap.previous_last_name,' '),inv_character_string,blank_character_string)) /*Bug 9000052*/
      ,'DATE_OF_BIRTH=P'
      ,to_char(pap.date_of_birth,'DDMMYYYY')
      ,'ADDRESS_LINE1=P'
      ,translate(nvl(pad.address_line1,' '),inv_character_string,blank_character_string)
      ,'ADDRESS_LINE2=P'
      ,translate(nvl(pad.address_line2,' '),inv_character_string,blank_character_string)
      ,'SUBURB=P'
      ,translate(nvl(pad.town_or_city,' '),inv_character_string,blank_character_string)
      ,'STATE=P'
      ,nvl(decode(pad.country,null,null,'AU',pad.region_1,'OTH'),' ')/*changed for Bug 2751147*/
      ,'POST_CODE=P'
      ,nvl(decode(pad.country,null,null,'AU',pad.postal_code,'9999'),'0000')/*Changed for Bug 2751147*/
      ,'COUNTRY=P'
      ,nvl(decode(pad.country,'AU',' ',pad.country),' ')
      ,'PAYROLL_NUMBER=P'
      ,paa.assignment_number
      ,'PAYEE_TERMINATOR_IND=P'
      ,decode(pay_au_tfn_magtape_flags.get_tfn_flag_values(paa.assignment_id,'CURRENT_OR_TERMINATED'),'T','T',' ')
      ,'AU_RES=P'
      ,nvl(pay_au_tfn_magtape_flags.get_tfn_flag_values(paa.assignment_id,'AUSTRALIAN_RESIDENT_FLAG'),' ')
      ,'BASIS_OF_PAYMENT=P'
      ,pay_au_tfn_magtape_flags.get_tfn_flag_values(paa.assignment_id,'BASIS_OF_PAYMENT')
      ,'TAX_FREE_TH=P'
      ,nvl(pay_au_tfn_magtape_flags.get_tfn_flag_values(paa.assignment_id,'TAX_FREE_THRESHOLD_FLAG'),' ')
      ,'FTB=P'
      ,nvl(pay_au_tfn_magtape_flags.get_tfn_flag_values(paa.assignment_id,'FTA_CLAIM_FLAG'),'N')
      ,'REBATE_FLAG=P'
      ,nvl(pay_au_tfn_magtape_flags.get_tfn_flag_values(paa.assignment_id,'REBATE_FLAG'),'N')
      ,'HECS=P'
      ,nvl(pay_au_tfn_magtape_flags.get_tfn_flag_values(paa.assignment_id,'HECS_FLAG'),' ')
      ,'SFSS=P'
      ,nvl(pay_au_tfn_magtape_flags.get_tfn_flag_values(paa.assignment_id,'SFSS_FLAG'),'N')
      ,'TFN_FOR_SUPER=P'
      ,nvl(pay_au_tfn_magtape_flags.get_tfn_flag_values(paa.assignment_id,'TFN_FOR_SUPER'),'N')
      ,'DATE_DECLARATION=P'
      ,nvl(pay_au_tfn_magtape_flags.get_tfn_flag_values(paa.assignment_id,'DECLARATION_SIGNED_DATE'),'00000000')
      ,'EFFECTIVE_START_DATE=P'
      ,pay_au_tfn_magtape_flags.get_tfn_flag_values(paa.assignment_id,'EFFECTIVE_START_DATE')
      ,'SATO=P' /*bug7270073*/
      ,nvl(pay_au_tfn_magtape_flags.get_tfn_flag_values(paa.assignment_id,'SENIOR_FLAG'),'N')
  FROM
         hr_soft_coding_keyflex   hsc
        ,per_assignments_f        paa
        ,per_people_f             pap
        ,per_addresses            pad
        ,pay_payroll_actions      ppa
        ,pay_assignment_actions   pac
  WHERE  paa.soft_coding_keyflex_id  = hsc.soft_coding_keyflex_id
    AND  ppa.report_type='AU_TFN_MAGTAPE' /*Bug4247686 */
    AND  ppa.report_qualifier='AU'
    AND  ppa.report_category='REPORT'
    AND  pap.business_group_id       = pay_magtape_generic.get_parameter_value('BUSINESS_GROUP_ID')
    AND  hsc.segment1                = pay_magtape_generic.get_parameter_value('LEGAL_EMPLOYER')
    AND  pap.person_id               = paa.person_id
    AND  pap.person_id               = pad.person_id(+)
    AND  pad.primary_flag(+)	     = 'Y' /*Added for bug 2751147*/
    AND  paa.effective_start_date    = ( SELECT max(effective_Start_date)
                                         FROM  per_assignments_f a
                                         WHERE  a.assignment_id = paa.assignment_id
                                         and a.effective_start_date < =
                                         to_date(pay_magtape_generic.get_parameter_value('REPORT_END_DATE'),'DD-MM-YYYY')  /*5474358 */
                                         group by a.assignment_id   /*Bug4247686 */
                                        )
    AND  pap.effective_start_date    = ( SELECT max(effective_Start_date)
                                         FROM per_people_f p
                                         WHERE p.person_id = pap.person_id
                                         and p.effective_start_date < =
                                         to_date(pay_magtape_generic.get_parameter_value('REPORT_END_DATE'),'DD-MM-YYYY')  /*5474358 */
                                         group by p.person_id /*Bug4247686 */
                                        )
    and  sysdate between nvl(pad.date_from , sysdate) and nvl(pad.date_to ,sysdate) /* 4632219 */
    AND  ppa.payroll_action_id       = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
    AND  pac.payroll_action_id       = ppa.payroll_action_id
    AND  pac.assignment_id           = paa.assignment_id
    ORDER BY pap.employee_number ;


END PAY_AU_TFN_MAGTAPE;

/
