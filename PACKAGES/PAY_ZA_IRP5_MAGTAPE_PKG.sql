--------------------------------------------------------
--  DDL for Package PAY_ZA_IRP5_MAGTAPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ZA_IRP5_MAGTAPE_PKG" AUTHID CURRENT_USER as
/* $Header: pyzamag.pkh 120.6.12010000.2 2009/04/27 04:56:31 rbabla ship $ */

type char240_data_type_table is table of varchar2(240)
     index by binary_integer;

-- Note: A driving cursor applies to a specific magnetic block. Each block
--       could have several formulas associated with it.
--       Cursors can pass parameters to the formulas, by indicating them
--       with a TRANSFER...=P. Parameters are available to all subsequent
--       blocks. The same go for contexts (C). Contexts will be used for
--       archive and live database items.
--       If you want to use a parameter from a previous cursor in the WHERE
--       clause of a subsequent cursor, use get_parameter_value.

-- The driving cursor for the File Header
cursor header_cursor is
   select 'TRANSFER_BUSINESS_GROUP_ID=P', nvl(to_char(hoi.organization_id), '&&&'),
          'TRANSFER_CREATOR_NAME=P',      nvl(substr(hoi.org_information1, 1, 80),  '&&&'),
          'TRANSFER_PAYE_NUMBER=P',       nvl(substr(hoi.org_information2, 1, 80),  '&&&'),
          'TRANSFER_CONTACT_NAME=P',      nvl(substr(hoi.org_information3, 1, 80),  '&&&'),
          'TRANSFER_CONTACT_PHN=P',       nvl(substr(hoi.org_information4, 1, 80),  '&&&'),
          'TRANSFER_ALT_PHN=P',           nvl(substr(hoi.org_information5, 1, 80),  '&&&'),
          'TRANSFER_ADD_1=P',             nvl(substr(hoi.org_information6, 1, 80),  '&&&'),
          'TRANSFER_ADD_2=P',             nvl(substr(hoi.org_information7, 1, 80),  '&&&'),
          'TRANSFER_ADD_3=P',             nvl(substr(hoi.org_information8, 1, 80),  '&&&'),
          'TRANSFER_ADD_4=P',             nvl(substr(hoi.org_information9, 1, 80),  '&&&'),
          'TRANSFER_POST_CODE=P',         nvl(substr(hoi.org_information10, 1, 80), '&&&')
   from   hr_all_organization_units   haou,
          hr_organization_information hoi
   where  hoi.organization_id = haou.organization_id
     and  hoi.org_information_context = 'ZA_TAX_FILE_ENTITY'
     and  pay_magtape_generic.get_parameter_value('BUS_GRP') = hoi.organization_id;

-- The driving cursor for the Employer Header
-- Note: TRANSFER_PAYROLL_ACTION_ID is the optional Payroll Action ID parameter
--       on the Electronic Tax File Magtape SRS. If supplied it is the Payroll
--       Action of the Archive Run.
cursor subheader_cursor is
   select 'TRANSFER_TRADE_NAME=P',    nvl(substr(hoi.org_information1, 1, 80), '&&&'),
          'TRANSFER_PAYE_NUMBER=P',   nvl(substr(hoi.org_information3, 1, 80), '&&&'),
          'TRANSFER_DIP_IND=P',       nvl(substr(hoi.org_information4, 1, 80), '&&&'),
          'TRANSFER_EMP_ADD_1=P',     nvl(substr(hloc.address_line_1, 1, 80),  '&&&'),
          'TRANSFER_EMP_ADD_2=P',     nvl(substr(hloc.address_line_2, 1, 80),  '&&&'),
          'TRANSFER_EMP_ADD_3=P',     nvl(substr(hloc.address_line_3, 1, 80),  '&&&'),
          'TRANSFER_EMP_ADD_4=P',     nvl(substr(hloc.town_or_city, 1, 80),    '&&&'),
          'TRANSFER_EMP_POSTCODE=P',  nvl(substr(hloc.postal_code, 1, 80),     '&&&'),
          'TRANSFER_LEG_ENTITY_ID=P', haou.organization_id
   from   hr_all_organization_units   haou,
          hr_organization_information hoi,
          hr_locations                hloc
   where  hoi.organization_id = haou.organization_id
     and  pay_magtape_generic.get_parameter_value('BUS_GRP') = haou.business_group_id
     and  hoi.org_information_context = 'ZA_LEGAL_ENTITY'
     and  hloc.location_id (+) = haou.location_id
     and  exists
          (
             select ''
             from   pay_payroll_actions       ppa,
                    pay_assignment_actions    paa,
                    per_assignment_extra_info paei
             where  ppa.payroll_action_id =
                    nvl(pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'),
                        ppa.payroll_action_id)
              and   ppa.action_type = 'X'
              and   ppa.report_type = 'ZA_IRP5'
              and   pay_za_irp5_archive_pkg.get_parameter('TAX_YEAR',
                    ppa.legislative_parameters) =
                    pay_magtape_generic.get_parameter_value('TAX_YEAR')
              and   paa.payroll_action_id = ppa.payroll_action_id
              and   paa.assignment_id = paei.assignment_id
              and   to_char(haou.organization_id) = paei.aei_information7
              and   paei.aei_information_category = 'ZA_SPECIFIC_INFO'
              and   paa.serial_number is not null
              and   py_za_tax_certificates.irp5_indicator(paa.assignment_action_id) in ('Y','N') -- 6166892
              and   substr(paa.serial_number, 1, 1) in ('0','1','2','3','4','5','6','7','8','9')
          )
   order by haou.organization_id;

-- The driving cursor for the Employee Details
-- Note: TRANSFER_PAYROLL_ACTION_ID is the optional Payroll Action ID parameter
--       on the Electronic Tax File Magtape SRS. If supplied it is the Payroll
--       Action of the Archive Run.
-- Note: TRANSFER_LEG_ENTITY_ID is passed from the subheader_cursor
-- Note: The ASSIGNMENT_ACTION_ID context is the Assignment Action of the Archiver
-- Note: The last entry in this tax year is chosen. It might happen that a person
--       transfers between payrolls, but this is not catered for; since he is
--       supposed to start on a new assignment number.
cursor employee_cursor is
   SELECT  'TRANSFER_EMPEE_NAME=P',           nvl(ltrim(rtrim(substr(paei.aei_information2, 1, 80))), '&&&'),
          'TRANSFER_LAST_NAME=P',            nvl(substr(ppf.last_name, 1, 80), '&&&'),
          'TRANSFER_ID_NUMBER=P',            nvl(substr(ppf.national_identifier, 1, 80), '&&&'),
          'TRANSFER_BIRTH_DATE=P',           nvl(to_char(ppf.date_of_birth, 'YYYYMMDD'), '8010101'),
          'TRANSFER_EMPLOYEE_NUMBER=P',      nvl(substr(ppf.employee_number, 1, 80), '&&&'),
          'TRANSFER_FIRST_NAME=P',           nvl(substr(ppf.first_name, 1, 80), '&&&'),
          'TRANSFER_MIDDLE_NAMES=P',         nvl(substr(ppf.middle_names, 1, 80), '&&&'),
          'TRANSFER_CC_TRUST_NUMBER=P',      nvl(substr(paei.aei_information3, 1, 80), '&&&'),
          'TRANSFER_NATURE=P',               nvl(substr(paei.aei_information4, 1, 80), '&&&'),
          'TRANSFER_CONTRACTOR=P',           nvl(substr(paei.aei_information6, 1, 80), '&&&'),
          'TRANSFER_LABOUR_BROKER=P',        nvl(substr(paei.aei_information10, 1, 80), '&&&'), -- Bug 3396163
          'TRANSFER_PENSION_BASIS=P',        nvl(substr(paei.aei_information8, 1, 80), nvl(substr(scl.segment10, 1, 80), '1')),
          'TRANSFER_PASSPORT=P',             nvl(substr(ppf.per_information2, 1, 80),  '&&&'),
          'TRANSFER_INCOME_NUMBER=P',        nvl(substr(ppf.per_information1, 1, 80),  '&&&'),
          'TRANSFER_ASSIGNMENT_ACTION_ID=P', paa.assignment_action_id,
          'TRANSFER_CERTIFICATE_NUMBER=P',   substr(paa.serial_number, 1, 80),
          'TRANSFER_TAX_DIRECTIVE_NO=P',     nvl(faidn.context,'&&&'),
          'ASSIGNMENT_ID=C',                 paa.assignment_id,
          'ASSIGNMENT_ACTION_ID=C',          paa.assignment_action_id,
          'PAYROLL_ACTION_ID=C',             paa.payroll_action_id,
          'PERSON_ID=C',                     pef.person_id,
          'DATE_EARNED=C',                   fnd_date.date_to_canonical(ppa.effective_date),
          'PAYROLL_ID=C',                    pef.payroll_id,
          'SOURCE_TEXT=C',                   nvl(faidn.context,'To Be Advised')
   from   pay_payroll_actions       ppa,
          hr_soft_coding_keyflex    scl,
          pay_all_payrolls_f        papf,
          per_assignments_f         pef,
          per_people_f              ppf,
          pay_assignment_actions    paa,
          per_assignment_extra_info paei,
          ff_archive_items         fai,
          ff_archive_item_contexts faidn,
          ff_contexts              fc1,
          ff_database_items        fdi
   where  ppa.payroll_action_id =
          nvl(pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'),
              ppa.payroll_action_id)
     and  ppa.action_type = 'X'
     and  ppa.report_type = 'ZA_IRP5'
     and  pay_za_irp5_archive_pkg.get_parameter('TAX_YEAR', ppa.legislative_parameters) =
          pay_magtape_generic.get_parameter_value('TAX_YEAR')
     and  paa.payroll_action_id = ppa.payroll_action_id
     and  paa.assignment_id = paei.assignment_id
     and  paa.serial_number is not null
     and  py_za_tax_certificates.irp5_indicator(paa.assignment_action_id) in ('Y','N') -- 6166892
     and  substr(paa.serial_number, 1, 1) in ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
     and  pef.assignment_id = paa.assignment_id
     and  ppf.person_id = pef.person_id
     and  ppf.per_information_category = 'ZA'
     and  pef.effective_start_date =
     (
        select max(pef2.effective_start_date)
        from   per_assignments_f pef2
        where  pef2.effective_start_date <= ppa.effective_date
        and    pef2.assignment_id = paa.assignment_id
     )
     and  ppf.effective_start_date =
     (
        select max(ppf2.effective_start_date)
        from   per_people_f ppf2
        where  ppf2.effective_start_date <= ppa.effective_date
        and    ppf2.person_id = ppf.person_id
     )
     and  papf.payroll_id          = pef.payroll_id
     and  papf.effective_start_date =
     (
        select max(papf2.effective_start_date)
        from   pay_all_payrolls_f papf2
        where  papf2.effective_start_date <= ppa.effective_date
        and    papf2.payroll_id = pef.payroll_id
     )
     and  scl.soft_coding_keyflex_id (+) = papf.soft_coding_keyflex_id
     and  paei.aei_information7 =
          pay_magtape_generic.get_parameter_value('TRANSFER_LEG_ENTITY_ID')
     and  paei.aei_information_category = 'ZA_SPECIFIC_INFO'
     AND  fai.context1 = paa.assignment_action_id
     and  fc1.context_name = 'SOURCE_TEXT'
     and  faidn.context_id = fc1.context_id
     and  fai.archive_item_id = faidn.archive_item_id
     and  fdi.user_entity_id = fai.user_entity_id
     and  fdi.user_name = 'A_TAX_ON_LUMP_SUMS_ASG_LMPSM_TAX_YTD'
   order  by paa.serial_number;

-- The driving cursor for the Deductions Details
-- Note: TRANSFER_ASSIGNMENT_ACTION_ID is the assignment action id passed from the
--       employee_cursor.
cursor deductions_cursor is
   SELECT distinct 'TRANSFER_DEDUCTION=P',    1,
          'TRANSFER_SARS_CODE=P',    SARS_CODE,
          'TRANSFER_CLEARANCE_NO=P', CLEARANCE_NO,
          'SOURCE_ID=C',             SOURCE_ID,
          'SOURCE_NUMBER=C',         SOURCE_NUMBER
   from
   (
   Select substr(fai.value, 1, 80) DEDUCTION,
          code.code                SARS_CODE,
          faic2.CONTEXT            CLEARANCE_NO,
          code.code                SOURCE_ID,
          faic2.CONTEXT SOURCE_NUMBER
   FROM
   ff_archive_items         fai,
          ff_archive_item_contexts faic2,
          ff_contexts              fc2,
          pay_za_irp5_bal_codes    code,
          ff_database_items        fdi
   where  fai.context1 =
          pay_magtape_generic.get_parameter_value('TRANSFER_ASSIGNMENT_ACTION_ID')
     and  fc2.context_name = 'SOURCE_NUMBER'
     and  faic2.context_id = fc2.context_id
     and  fai.archive_item_id = faic2.archive_item_id
     AND  fdi.user_entity_id = fai.user_entity_id
     AND  fdi.user_name             = code.user_name
     AND code.user_name IN    (
         'A_ANNUAL_PENSION_FUND_ASG_CLRNO_TAX_YTD'
         ,'A_CURRENT_PENSION_FUND_ASG_CLRNO_TAX_YTD'
         ,'A_ANNUAL_ARREAR_PENSION_FUND_ASG_CLRNO_TAX_YTD'
         ,'A_ARREAR_PENSION_FUND_ASG_CLRNO_TAX_YTD'
         ,'A_ANNUAL_PROVIDENT_FUND_ASG_CLRNO_TAX_YTD'
         ,'A_CURRENT_PROVIDENT_FUND_ASG_CLRNO_TAX_YTD'
         ,'A_ARREAR_PROVIDENT_FUND_ASG_CLRNO_TAX_YTD'
         ,'A_ANNUAL_RETIREMENT_ANNUITY_ASG_CLRNO_TAX_YTD'
         ,'A_CURRENT_RETIREMENT_ANNUITY_ASG_CLRNO_TAX_YTD'
         ,'A_ANNUAL_ARREAR_RETIREMENT_ANNUITY_ASG_CLRNO_TAX_YTD'
         ,'A_ARREAR_RETIREMENT_ANNUITY_ASG_CLRNO_TAX_YTD'
   )
UNION all
  select
          substr(fai.value, 1, 80) DEDUCTION,
          code.code                SARS_CODE,
          '99999999999'            CLEARANCE_NO,
          code.code                SOURCE_ID,
          '99999999999'            SOURCE_NUMBER
   FROM
          ff_archive_items         fai,
          pay_za_irp5_bal_codes    code,
          ff_database_items        fdi
   Where  fai.context1 =
          pay_magtape_generic.get_parameter_value('TRANSFER_ASSIGNMENT_ACTION_ID')
   AND  fdi.user_entity_id = fai.user_entity_id
   AND  fdi.user_name             = code.user_name
   And   code.user_name in
  (
    'A_MEDICAL_AID_CONTRIBUTION_ASG_TAX_YTD' --4005
    ,'A_EE_INCOME_PROTECTION_POLICY_CONTRIBUTIONS_ASG_TAX_YTD' --4018
    ,'A_MED_COSTS_DMD_PD_BY_EE_EE_FAMILY_RFI_ASG_TAX_YTD' --4024
    ,'A_MEDICAL_CONTRIBUTIONS_ABATEMENT_ASG_TAX_YTD' --4025
    ,'A_DONATIONS_MADE_BY_EE_AND_PAID_BY_ER_ASG_TAX_YTD' --4030
    ,'A_ANNUAL_DONATIONS_MADE_BY_EE_AND_PAID_BY_ER_ASG_TAX_YTD' --4030
    )
 ) deduction
   order  by SARS_CODE , SOURCE_NUMBER;

level_cnt number;

end pay_za_irp5_magtape_pkg;

/
