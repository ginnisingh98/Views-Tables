--------------------------------------------------------
--  DDL for Package PAY_ZA_UIF_MAGTAPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ZA_UIF_MAGTAPE_PKG" AUTHID CURRENT_USER as
/* $Header: pyzauifm.pkh 115.8 2003/10/20 23:35:43 rpahune noship $ */
/*REM +====================================================================+
REM |       Copyright (c) 2002 Oracle Corporation                          |
REM |                           All rights reserved.                       |
REM +======================================================================+
REM SQL Script File name : pyzauifm.pkh
REM Description          : This sql script seeds the Package that creates
REM                        the UIF Magtape Driving cursors
REM
REM Change List:
REM ------------
REM
REM Name           Date        Version Bug     Text
REM -------------- ----------- ------- ------  ------------------------------
REM L.Kloppers     21-Apr-2002   115.0 2266156 Initial Version
REM L.Kloppers     06-May-2002   115.1 2266156 Removed join between Assignment
REM                                            Actions and Creator Payroll
REM                                            Action
REM L.Kloppers     08-May-2002   115.2 2266156 Modified to allow for multiple
REM                                            archives per UIF Month
REM Nageswara Rao  24-Jan-2003   115.3 2654703 Modified employer cursor
REM                                            with email address
REM Nageswara Rao  02-Feb-2003   115.4         Changes for GSCC compliance
REM Nageswara Rao  05-Mar-2003   115.5         Changes in Employee cursor
REM R.Pahune       26-Sep-2003   115.7 3134183 Modified Employee cursor
REM					       to reduce the cost.
REM R.Pahune       21-Oct-2003   115.8 3134183 Modified Employee cursor NVL
REM					       default changed from ':::' to
REM                                            '&&&'
REM ========================================================================
*/

-- Note: A driving cursor applies to a specific magnetic block. Each block
--       could have several formulas associated with it.
--       Cursors can pass parameters to the formulas, by indicating them
--       with a TRANSFER...=P. Parameters are available to all subsequent
--       blocks. The same go for contexts (C). Contexts will be used for
--       archive and live database items.
--       If you want to use a parameter from a previous cursor in the WHERE
--       clause of a subsequent cursor, use get_parameter_value.

-- The driving cursor for the File Header
-- Note: The latest Electronic UIF File Preprocess Payroll Action is selected,
--       unless a specific Preprocess is selected. In the latter case the
--       TRANSFER_ARCH_PAYROLL_ACTION_ID is the optional Payroll Action ID parameter
--       on the Electronic UIF File Preprocess SRS. If supplied it is the Payroll
--       Action of the Archive Run.
cursor header_cursor is
   select 'TRANSFER_BUSINESS_GROUP_ID=P'      , nvl(pai.action_information1, '&&&'),
          'TRANSFER_UIF_CAL_MONTH=P'          , nvl(pai.action_information2, '&&&'),
          'TRANSFER_CREATOR_UIF_REFERENCE=P'  , nvl(pai.action_information4, '&&&'),
          'TRANSFER_CONTACT_PERSON=P'         , nvl(pai.action_information5, '&&&'),
          'TRANSFER_CONTACT_NUMBER=P'         , nvl(pai.action_information6, '&&&'),
          'TRANSFER_CONTACT_EMAIL_ADDRESS=P'  , nvl(pai.action_information7, '&&&')
     from pay_action_information    pai
        , pay_payroll_actions       ppa
    where pai.action_information1 = pay_magtape_generic.get_parameter_value('BG_ID')
      and pai.action_information2 = pay_magtape_generic.get_parameter_value('CAL_MONTH')
      and pai.action_information_category = 'ZA UIF CREATOR DETAILS'
      and pai.action_context_type = 'PA'
      and pai.action_context_id = ppa.payroll_action_id
      and ppa.rowid =
          (
          select substr(
                       max(lpad(ppa2.action_sequence, 15, 0) || ppa2.rowid)
                       , -length(ppa2.rowid)
                       )
            from pay_payroll_actions    ppa2
           where to_char(to_date(pay_za_uif_archive_pkg.get_parameter('END_DATE', ppa2.legislative_parameters), 'YYYY/MM/DD'), 'YYYYMM')
                  = pay_magtape_generic.get_parameter_value('CAL_MONTH')
             and ppa2.business_group_id = pay_magtape_generic.get_parameter_value('BG_ID')
             and ppa2.action_type = 'X'
             and ppa2.report_type = 'ZA_UIF'
             and ppa2.payroll_action_id = nvl(pay_magtape_generic.get_parameter_value('TRANSFER_ARCH_PAYROLL_ACTION_ID'),
                                            ppa2.payroll_action_id)
          group by length(ppa2.rowid)
          );


-- The driving cursor for the Employer Header
-- Note: TRANSFER_ARCH_PAYROLL_ACTION_ID is the optional Payroll Action ID parameter
--       on the Electronic UIF File Preprocess SRS. If supplied it is the Payroll
--       Action of the Archive Run.
--       TRANSFER_BUSINESS_GROUP_ID is passed from the header_cursor
cursor subheader_cursor is
   select 'TRANSFER_UIF_EMPL_REF_NO=P',        nvl(max(distinct pai.action_information4), '&&&') /*UIF Employer Ref No*/
        , 'TRANSFER_PAYE_EMPL_NO=P',           nvl(max(distinct pai.action_information5), '&&&') /*PAYE Employer Number*/
          /* Changes as per Bug2654703 */
        , 'TRANSFER_EMPLOYER_EMAIL_ADDRESS=P', nvl(max(distinct pai.action_information22), '&&&') /*UIF Employer Email id*/

     from pay_action_information pai
        , pay_payroll_actions    ppa
        , pay_assignment_actions paa
    where pai.action_information2 = pay_magtape_generic.get_parameter_value('CAL_MONTH')
      and pai.action_context_type = 'AAP'
      and pai.action_information_category = 'ZA UIF EMPLOYEE DETAILS'
      and pai.action_context_id = paa.assignment_action_id
      and paa.payroll_action_id = ppa.payroll_action_id
      and ppa.payroll_action_id in
          (
          select ppa2.payroll_action_id
            from pay_payroll_actions ppa2
           where to_char(to_date(pay_za_uif_archive_pkg.get_parameter('END_DATE', ppa2.legislative_parameters), 'YYYY/MM/DD'), 'YYYYMM')
                 =            pay_magtape_generic.get_parameter_value('CAL_MONTH')
             and ppa2.business_group_id = pay_magtape_generic.get_parameter_value('TRANSFER_BUSINESS_GROUP_ID')
             and ppa2.action_type = 'X'
             and ppa2.report_type = 'ZA_UIF'
             and ppa2.payroll_action_id = nvl(pay_magtape_generic.get_parameter_value('TRANSFER_ARCH_PAYROLL_ACTION_ID'),
                                              ppa2.payroll_action_id)
        )
    group by pai.action_information4 /*UIF Employer Ref No*/
           , pai.action_information5 /*PAYE Employer Number*/
	   , pai.action_information22;/*UIF Employer Email id, Changes as per Bug2654703 */


-- The driving cursor for the Employee Details
-- Note: TRANSFER_ARCH_PAYROLL_ACTION_ID is the optional Payroll Action ID parameter
--       on the Electronic Tax File Magtape SRS. If supplied it is the Payroll
--       Action of the Archive Run.
-- Note: TRANSFER_UIF_EMPL_REF_NO is passed from the subheader_cursor
-- Start R.Pahune       26-Sep-2003   115.7 3134183
cursor employee_cursor is
select
          'TRANSFER_UIF_EMPL_REF_NO=P'         , nvl(pai.action_information4 , '&&&'),
          'TRANSFER_ID_NUMBER=P'               , nvl(pai.action_information6 , '&&&'),
          'TRANSFER_OTHER_NUMBER=P'            , nvl(pai.action_information7 , '&&&'),
          'TRANSFER_EMPLOYEE_NUMBER=P'         , nvl(pai.action_information8 , '&&&'),
          'TRANSFER_SURNAME=P'                 , nvl(pai.action_information9 , '&&&'),
          'TRANSFER_FIRST_NAMES=P'             , nvl(pai.action_information10, '&&&'),
          'TRANSFER_DATE_OF_BIRTH=P'           , nvl(pai.action_information11, '&&&'),
          'TRANSFER_DATE_EMPLOYED_FROM=P'      , nvl(pai.action_information12, '&&&'),
          'TRANSFER_DATE_EMPLOYED_TO=P'        , nvl(pai.action_information13, '&&&'),
          'TRANSFER_EMPLOYMENT_STATUS=P'       , nvl(pai.action_information14, '01'),
          'TRANSFER_REASON_NON_CONTRIB=P'      , nvl(pai.action_information15, '&&&'),
          'TRANSFER_GROSS_TAX_REMUN=P'         , nvl(pai.action_information16, '&&&'),
          'TRANSFER_GROSS_UIF_REMUN=P'         , nvl(pai.action_information17, '&&&'),
          'TRANSFER_UIF_CONTRIBUTION=P'        , nvl(pai.action_information18, '&&&'),
          'TRANSFER_BANK_BRANCH_CODE=P'        , nvl(pai.action_information19, '&&&'),
          'TRANSFER_BANK_ACCOUNT_NUMBER=P'     , nvl(pai.action_information20, '&&&'),
          'TRANSFER_BANK_ACCOUNT_TYPE=P'       , nvl(pai.action_information21, '&&&')
	  from PAY_ACTION_INFORMATION pai, pay_assignment_actions paa ,
	  (
          select substr(
                       max(lpad(paa2.action_sequence, 15, 0) || paa2.rowid)
                       , -length(paa2.rowid)
                       ) paa_rowid, assignment_id
            from pay_assignment_actions paa2
               , pay_payroll_actions    ppa2
           where ppa2.payroll_action_id  = paa2.payroll_action_id
             and to_char(to_date(pay_za_uif_archive_pkg.get_parameter('END_DATE', ppa2.legislative_parameters), 'YYYY/MM/DD'), 'YYYYMM')
                 =            pay_magtape_generic.get_parameter_value('CAL_MONTH')
             and ppa2.business_group_id = pay_magtape_generic.get_parameter_value('TRANSFER_BUSINESS_GROUP_ID')
             and ppa2.action_type = 'X'
             and ppa2.report_type = 'ZA_UIF'
             and paa2.payroll_action_id = nvl(pay_magtape_generic.get_parameter_value('TRANSFER_ARCH_PAYROLL_ACTION_ID'),
                                              ppa2.payroll_action_id)
          group by length(paa2.rowid) , paa2.assignment_id
          )  paa_v
    where pai.action_information2 = pay_magtape_generic.get_parameter_value('CAL_MONTH')
      and pai.action_information4 = pay_magtape_generic.get_parameter_value('TRANSFER_UIF_EMPL_REF_NO')
      and pai.action_context_id = paa.assignment_action_id
      and pai.action_context_type = 'AAP'
      and pai.action_information_category = 'ZA UIF EMPLOYEE DETAILS'
      and paa.rowid = paa_v.paa_rowid
      and paa.assignment_id  = paa_v.assignment_id
     order by pai.action_information8 /*Employee Number*/;

/*Query Before R.Pahune       26-Sep-2003   115.7 3134183 */
/*cursor employee_cursor is
   select
          'TRANSFER_UIF_EMPL_REF_NO=P'         , nvl(pai.action_information4 , '&&&'),
          'TRANSFER_ID_NUMBER=P'               , nvl(pai.action_information6 , '&&&'),
          'TRANSFER_OTHER_NUMBER=P'            , nvl(pai.action_information7 , '&&&'),
          'TRANSFER_EMPLOYEE_NUMBER=P'         , nvl(pai.action_information8 , '&&&'),
          'TRANSFER_SURNAME=P'                 , nvl(pai.action_information9 , '&&&'),
          'TRANSFER_FIRST_NAMES=P'             , nvl(pai.action_information10, '&&&'),
          'TRANSFER_DATE_OF_BIRTH=P'           , nvl(pai.action_information11, '&&&'),
          'TRANSFER_DATE_EMPLOYED_FROM=P'      , nvl(pai.action_information12, '&&&'),
          'TRANSFER_DATE_EMPLOYED_TO=P'        , nvl(pai.action_information13, '&&&'),
          'TRANSFER_EMPLOYMENT_STATUS=P'       , nvl(pai.action_information14, '01'), */ /* Defaulted to '01' when null */
/*          'TRANSFER_REASON_NON_CONTRIB=P'      , nvl(pai.action_information15, '&&&'),
          'TRANSFER_GROSS_TAX_REMUN=P'         , nvl(pai.action_information16, '&&&'),
          'TRANSFER_GROSS_UIF_REMUN=P'         , nvl(pai.action_information17, '&&&'),
          'TRANSFER_UIF_CONTRIBUTION=P'        , nvl(pai.action_information18, '&&&'),
          'TRANSFER_BANK_BRANCH_CODE=P'        , nvl(pai.action_information19, '&&&'),
          'TRANSFER_BANK_ACCOUNT_NUMBER=P'     , nvl(pai.action_information20, '&&&'),
          'TRANSFER_BANK_ACCOUNT_TYPE=P'       , nvl(pai.action_information21, '&&&')
     from pay_action_information pai
        , pay_assignment_actions paa
    where pai.action_information2 = pay_magtape_generic.get_parameter_value('CAL_MONTH')
      and pai.action_context_type = 'AAP'
      and pai.action_information4 = pay_magtape_generic.get_parameter_value('TRANSFER_UIF_EMPL_REF_NO')
      and pai.action_information_category = 'ZA UIF EMPLOYEE DETAILS'
      and pai.action_context_id = paa.assignment_action_id
      and paa.rowid =
          (
          select substr(
                       max(lpad(paa2.action_sequence, 15, 0) || paa2.rowid)
                       , -length(paa2.rowid)
                       )
            from pay_assignment_actions paa2
               , pay_payroll_actions    ppa2
           where paa2.assignment_id      = paa.assignment_id
             and ppa2.payroll_action_id  = paa2.payroll_action_id
             and to_char(to_date(pay_za_uif_archive_pkg.get_parameter('END_DATE', ppa2.legislative_parameters), 'YYYY/MM/DD'), 'YYYYMM')
                 =            pay_magtape_generic.get_parameter_value('CAL_MONTH')
             and ppa2.business_group_id = pay_magtape_generic.get_parameter_value('TRANSFER_BUSINESS_GROUP_ID')
             and ppa2.action_type = 'X'
             and ppa2.report_type = 'ZA_UIF'
             and ppa2.payroll_action_id = nvl(pay_magtape_generic.get_parameter_value('TRANSFER_ARCH_PAYROLL_ACTION_ID'),
                                              ppa2.payroll_action_id)
          group by length(paa2.rowid)
          )
    order by pai.action_information8 */ /*Employee Number*/

-- End R.Pahune       26-Sep-2003   115.7 3134183

level_cnt number;

end pay_za_uif_magtape_pkg;

 

/
