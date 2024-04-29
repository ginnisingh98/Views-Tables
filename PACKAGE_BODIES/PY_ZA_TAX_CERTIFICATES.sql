--------------------------------------------------------
--  DDL for Package Body PY_ZA_TAX_CERTIFICATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PY_ZA_TAX_CERTIFICATES" as
/* $Header: pyzatcer.pkb 120.12.12010000.5 2009/05/07 07:33:28 rbabla ship $ */
/*
-- +======================================================================+
-- |       Copyright (c) 1998 Oracle Corporation South Africa Ltd         |
-- |                Cape Town, Western Cape, South Africa                 |
-- |                           All rights reserved.                       |
-- +======================================================================+
-- SQL Script File Name : pyzatcer.pkb
-- Description          : This sql script seeds the py_za_tax_certificates
--                        package for the ZA localisation. This package
--                        is used in the Tax Certificate reports.
--
-- Change List:
-- ------------
--
-- Name           Date        Version Bug     Text
-- -------------- ----------- ------- ------- -----------------------------
-- F.D. Loubser   08-May-2000   110.0         Initial version
-- J.N. Louw      24-Aug-2000   115.0         Updated for ZAPatch11i.01
-- F.D. Loubser   11-Sep-2000   115.1         Updated for CBO
-- G.J. Fraser    09-Jan-2001   110.11        Changed Balance Names
-- L. KLoppers    06-Sep-2002   115.2 2266025 Added A_OTHER_RETIREMENT_LUMP_SUMS_ASG_RETRO_TAX_YTD
--                                            and A_OTHER_RETIREMENT_LUMP_SUMS_ASG_RETRO_TAX_PTD
-- L. Kloppers    12-Sep-2002   115.2 2224332 Added Function get_sars_code to return correct SARS Code
--                                            in case of a Director or Foreign Income
-- N. Venugopal   11-Aug-2003   115.4 3069004 Added A_ANNUAL_BURSARIES_AND_SCHOLARSHIPS_NRFI_ASG_TAX_YTD,
--                                            A_ANNUAL_BURSARIES_AND_SCHOLARSHIPS_RFI_ASG_TAX_YTD
-- Nageswara      01-Feb-2004   115.5 3396163 Added
--                                            A_LABOUR_BROKER_PAYMENTS_NRFI_ASG_TAX_YTD,
--                                            A_ANNUAL_LABOUR_BROKER_PAYMENTS_NRFI_ASG_TAX_YTD,
--                                            A_INDEPENDENT_CONTRACTOR_PAYMENTS_RFI_ASG_TAX_YTD,
--                                            A_INDEPENDENT_CONTRACTOR_PAYMENTS_NRFI_ASG_TAX_YTD,
--                                            A_ANNUAL_INDEPENDENT_CONTRACTOR_PAYMENTS_RFI_ASG_TAX_YTD,
--                                            A_ANNUAL_INDEPENDENT_CONTRACTOR_PAYMENTS_NRFI_ASG_TAX_YTD
-- Nageswara      13-Feb-2004   115.6 3396163 A_LABOUR_BROKER_PAYMENTS_RFI_ASG_TAX_YTD,
--                                            A_ANNUAL_LABOUR_BROKER_PAYMENTS_RFI_ASG_TAX_YTD,
--                                            Commented 'serverout on size'
-- Nageswara      20-Oct-2004   115.7 3931277 Added
--                                            A_ANNUAL_PAYMENT_OF_EMPLOYEE_DEBT_RFI_ASG_TAX_YTD
--                                            A_ANNUAL_PAYMENT_OF_EMPLOYEE_DEBT_NRFI_ASG_TAX_YTD
--                                            Local variable initialization moved to body section instead
--                                              in Declarative section. - GSCC standard
-- Nageswara      31-Dec-2004   115.8 4083627 Added
--                                              A_TAXABLE_SUBSISTENCE_ALLOWANCE_FOREIGN_TRAVEL_RFI_ASG_TAX_YTD
--					        A_TAXABLE_SUBSISTENCE_ALLOWANCE_FOREIGN_TRAVEL_NRFI_ASG_TAX_YTD
--					        A_NON_TAXABLE_SUBSISTENCE_ALLOWANCE_FOREIGN_TRAVEL_ASG_TAX_YTD
--					        A_EXECUTIVE_EQUITY_SHARES_RFI_ASG_TAX_YTD
--					        A_EXECUTIVE_EQUITY_SHARES_NRFI_ASG_TAX_YTD
-- R. V. Pahune  25-Aug-2005   115.10 4346920 For Tax Directive Number Source Type in 'I', 'E'
--                                            as After Migration the tax directive Number is fed inderectly
--                                            by formulae result. and pay_run_results.status <> 'B'
-- R.V. Pahune  27-Sep-2005    115.13 4346920 changes the query for lump_sum_indicator.
-- A. Mahanty   27-Jan-2006    115.14 4346920 Removed
--                                              A_NON_TAXABLE_ARBITRATION_AWARD_ASG_LMPSM_TAX_YTD
-- A. Mahanty   18-May-2006    115.15 5231652 The unused procedure get_tax_data
                                              removed
REM R Pahune    13-Apr-2007    115.16         Duplicate certificates are produce in case of only
REM                                           Lump Sum payment made in tax year.
REM R Pahune    24-Apr-2007   115.17         No IT3A in case of Lump Sum Cert.
REM R Pahune    22-Jun-2007   115.19         Zero Balances reported in Elec Tax File and
REM                                          added missing Med balances
REM R Pahune    26-Jun-2007   115.20         return 'A' if l_sum < 0 cond added
REM R Babla     05-Mar-2008   115.22 6867418 Changes for sars TYE2008 to include the lump sum
REM                                          income sources and tax on the new lump sum
REM P Arusia    19-Mar-2008   115.23 6867418 Modified ipr5_indicator function to add canonical_to_number
REM R Babla     10-Apr-2009   115.24 8406456 Changes done for TYS2009
REM R Babla     24-Apr-2009   115.25 8493624 Modified function irp5_indicator. Removed the reference of
REM                                          code 3908 while calculating the Lump Sum Income
-- ========================================================================
*/
---------------------------------------------------------------------------
-- This function is used to populate the temporary table for the IRP5 and
-- IT3A reports
-- It returns the sequence number of the temporary values
---------------------------------------------------------------------------
function populate_temporary_table
(
   p_irp5_indicator    in varchar2,
   p_payroll_action_id in varchar2,
   p_employee          in number
)  return number is

cursor c_main is
   select per.employee_number,
          paa.assignment_action_id ASS_ACTION_ID,
          ppa.effective_date       CF_EFF_DATE,
          per.national_identifier,
          per.per_information1,
          per.per_information2,
          per.last_name,
          per.first_name,
          ass.assignment_number,
          per.first_name || ' ' ||
             substr(per.middle_names, 1, (replace(instr(per.middle_names, ',', 1), 0, 250) - 1)) FIRST_NAMES,
          to_char(per.date_of_birth, 'YYYYMMDD') DATE_OF_BIRTH,
          substr(per.first_name, 1, 1) || nvl(substr(per.middle_names, 1, 1), '')
             || substr(per.middle_names, (replace(instr(per.middle_names, ',', 1, 1), 0, 250) + 1), 1)
             || substr(per.middle_names, (replace(instr(per.middle_names, ',', 1, 2), 0, 250) + 1), 1)
             || substr(per.middle_names, (replace(instr(per.middle_names, ',', 1, 3), 0, 250) + 1), 1)
             || substr(per.middle_names, (replace(instr(per.middle_names, ',', 1, 4), 0, 250) + 1), 1) INITIALS,
          per.middle_names,
          adr.address_line1,
          adr.address_line2,
          adr.address_line3,
          adr.town_or_city,
          adr.postal_code,
          ass.assignment_id,
          ass.location_id,
          ass.payroll_id,
          ass.effective_start_date,
          ass.effective_end_date,
          aei.aei_information4,
          aei.aei_information7,
          aei.aei_information6,
          aei.aei_information3,
          nvl(aei.aei_information8, nvl(scl.segment10, '1'))                      AEI_INFORMATION8,
          decode(aei.aei_information2, null, per.last_name, aei.aei_information2) AEI_INFORMATION2,
          hrl.location_code,
          hrl.address_line_1,
          hrl.address_line_2,
          hrl.address_line_3,
          hrl.town_or_city CITY,
          hrl.postal_code  POSTCODE,
          org.name         ORG_NAME,
          hoi.organization_id,
          hoi.org_information1,
          hoi.org_information3,
          hoi.org_information4,
          nvl(fcl.meaning, 'A') NATURE,
          paa.serial_number
   from   hr_all_organization_units   org,
          per_all_people_f            per,
          per_addresses               adr,
          per_all_assignments_f       ass,
          per_assignment_extra_info   aei,
          hr_soft_coding_keyflex      scl,
          pay_all_payrolls_f          ppf,
          hr_locations                hrl,
          hr_organization_information hoi,
          hr_all_organization_units   hou,
          fnd_common_lookups          fcl,
          pay_assignment_actions      paa,
          pay_payroll_actions         ppa
   where  ppa.payroll_action_id    = substr(P_PAYROLL_ACTION_ID, 28)
   and    ppa.action_type          = 'X'
   and    ppa.action_status        = 'C'
   and    ppa.report_type          = 'ZA_IRP5'
   and    paa.payroll_action_id    = ppa.payroll_action_id
   and    nvl(substr(paa.serial_number, 1, 1), '1') in ('1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '&')
   and    ass.assignment_id        = paa.assignment_id
   and    (ass.assignment_id = P_EMPLOYEE or P_EMPLOYEE is null)
   and    ass.effective_start_date =
   (
      select max(paf2.effective_start_date)
      from   per_assignments_f paf2
      where  paf2.effective_start_date <= ppa.effective_date
      and    paf2.assignment_id = paa.assignment_id
   )
   and    per.person_id            = ass.person_id
   and    per.effective_start_date =
   (
      select max(per2.effective_start_date)
      from   per_people_f per2
      where  per2.effective_start_date <= ppa.effective_date
      and    per2.person_id = ass.person_id
   )
   and    ppf.payroll_id           = ass.payroll_id
   and    ppf.effective_start_date =
   (
      select max(ppf2.effective_start_date)
      from   pay_all_payrolls_f ppf2
      where  ppf2.effective_start_date <= ppa.effective_date
      and    ppf2.payroll_id = ass.payroll_id
   )
   and    scl.soft_coding_keyflex_id (+) = ppf.soft_coding_keyflex_id
   and    per.person_id                  = adr.person_id (+)
   and    adr.style (+)                  = 'ZA'
   and    adr.primary_flag (+)           = 'Y'
   and    org.organization_id (+)        = ass.organization_id
   and    ass.assignment_id              = aei.assignment_id (+)
   and    aei.aei_information7           = hou.organization_id
   and    hou.organization_id            = hoi.organization_id
   and    hoi.org_information_context    = 'ZA_LEGAL_ENTITY'
   and    hrl.location_id (+)            = hou.location_id
   and    hrl.style (+)                  = 'ZA'
   and    fcl.lookup_type (+)            = 'ZA_PER_NATURES'
   and    fcl.lookup_code (+)            = aei.aei_information4
   and    fcl.application_id (+)         = 800;

   l_irp5_indicator varchar2(1);
   l_irp5_id        number(15);

begin
/*
   -- Get a unique sequence number to access the temporary table
   select pay_za_irp5_temp_s.nextval
   into   l_irp5_id
   from   dual;

   -- Populate the temporary table
   for v_main in c_main
   loop

      if irp5_indicator(v_main.ass_action_id) = p_irp5_indicator then

         insert into pay_za_irp5_temp
         values
         (
            l_irp5_id,
            v_main.employee_number,
            v_main.ass_action_id,
            v_main.cf_eff_date,
            v_main.national_identifier,
            v_main.per_information1,
            v_main.per_information2,
            v_main.last_name,
            v_main.first_name,
            v_main.assignment_number,
            v_main.first_names,
            v_main.date_of_birth,
            v_main.initials,
            v_main.middle_names,
            v_main.address_line1,
            v_main.address_line2,
            v_main.address_line3,
            v_main.town_or_city,
            v_main.postal_code,
            v_main.assignment_id,
            v_main.location_id,
            v_main.payroll_id,
            v_main.effective_start_date,
            v_main.effective_end_date,
            v_main.aei_information4,
            v_main.aei_information7,
            v_main.aei_information6,
            v_main.aei_information3,
            v_main.aei_information8,
            v_main.aei_information2,
            v_main.location_code,
            v_main.address_line_1,
            v_main.address_line_2,
            v_main.address_line_3,
            v_main.city,
            v_main.postcode,
            v_main.org_name,
            v_main.organization_id,
            v_main.org_information1,
            v_main.org_information3,
            v_main.org_information4,
            v_main.nature,
            v_main.serial_number
         );

      end if;

   end loop c_main;
*/
   return l_irp5_id;

end populate_temporary_table;

---------------------------------------------------------------------------
-- This function is used to indicate whether the Certificate is an IRP5 or
-- an IT3A
---------------------------------------------------------------------------
function irp5_indicator
(
   p_assignment_action_id in number
)  return varchar2 is

l_lump_sum_indicator varchar2(1);
l_site               number(15, 3);
l_paye               number(15, 3);
l_voluntary_tax      number(15, 3);
l_total              number(15, 3);
l_sum                number(15);
l_lmpsm_sum          number(15);

begin

   -- Local variable initialization - GSCC standards
   l_lump_sum_indicator  := 'N';
   l_site                := 0;
   l_paye                := 0;
   l_voluntary_tax       := 0;
   l_total               := 0;
   l_sum                 := 0;

   -- Check whether this is a Lump Sum or a Main Certificate

Select decode(count(*), 0 ,'Y', 'N')
   into   l_lump_sum_indicator
    From      pay_payroll_actions    ppa_arch,
      pay_assignment_actions paa_arch
where paa_arch.assignment_action_id = p_assignment_action_id
and   ppa_arch.payroll_action_id    = paa_arch.payroll_action_id
and   paa_arch.assignment_action_id =
(
   select max(paa.assignment_action_id)
   from   pay_assignment_actions paa
   where  paa.payroll_action_id = ppa_arch.payroll_action_id
   and   paa.assignment_id = paa_arch.assignment_id
) ;
   -- If this is the Main Certificate
   if l_lump_sum_indicator = 'N' then

      -- Get the SITE value
      begin

         select fnd_number.canonical_to_number(arc.value)
         into   l_site
         from   ff_archive_items  arc,
                ff_database_items dbi
         where  dbi.user_name      = 'A_SITE_ASG_TAX_YTD'
         and    arc.user_entity_id = dbi.user_entity_id
         and    arc.context1       = p_assignment_action_id;

      exception
         when no_data_found then
            l_site := 0;

      end;

      -- Get the PAYE value
      begin

         select fnd_number.canonical_to_number(arc.value)
         into   l_paye
         from   ff_archive_items  arc,
                ff_database_items dbi
         where  dbi.user_name      = 'A_PAYE_ASG_TAX_YTD'
         and    arc.user_entity_id = dbi.user_entity_id
         and    arc.context1       = p_assignment_action_id;

      exception
         when no_data_found then
            l_paye := 0;

      end;

      -- Get the Voluntary Tax value
      begin

         select arc.value
         into   l_voluntary_tax
         from   ff_archive_items  arc,
                ff_database_items dbi
         where  dbi.user_name      = 'A_VOLUNTARY_TAX_ASG_TAX_YTD'
         and    arc.user_entity_id = dbi.user_entity_id
         and    arc.context1       = p_assignment_action_id;

      exception
         when no_data_found then
            l_voluntary_tax := 0;

      end;

      -- Calculate the Total Tax paid
      l_total := l_paye + l_voluntary_tax + l_site;

   else

      -- Get the Lump Sum Tax value
      begin

         select sum(arc.value)
         into   l_total
         from   ff_archive_items  arc,
                ff_database_items dbi
         where  dbi.user_name      IN ('A_TAX_ON_LUMP_SUMS_ASG_LMPSM_TAX_YTD',
	                               'A_TAX_ON_RETIREMENT_FUND_LUMP_SUMS_ASG_LMPSM_TAX_YTD')
         and    arc.user_entity_id = dbi.user_entity_id
         and    arc.context1       = p_assignment_action_id;

      exception
         when no_data_found then
            l_total := 0;

      end;

   end if;

   -- Check whether the assignment had zeroes for all his income balances
   -- bug 3069004 , Added A_ANNUAL_BURSARIES_AND_SCHOLARSHIPS_NRFI_ASG_TAX_YTD, A_ANNUAL_BURSARIES_AND_SCHOLARSHIPS_RFI_ASG_TAX_YTD
   if l_lump_sum_indicator = 'N' then

      begin

         -- Check the Main Certificate Income sources
             -- Added for the balance feed enhancement
         select sum(trunc(to_number(arc.value))) value
         into   l_sum
         from  -- pay_za_irp5_bal_codes irp5,
                ff_archive_items      arc,
                ff_database_items     dbi
         where  arc.context1 = p_assignment_action_id
         and
         (
            arc.value is not null
            or
            (
               arc.value is not null
               and to_number(arc.value) <> 0
            )
         )
         and    dbi.user_entity_id = arc.user_entity_id
--         and    irp5.user_name = dbi.user_name
         and    dbi.user_name in
           (
             'A_GROSS_REMUNERATION_ASG_TAX_YTD',
             'A_GROSS_NON_TAXABLE_INCOME_ASG_TAX_YTD',
             'A_ARREAR_PROVIDENT_FUND_ASG_TAX_YTD',
             'A_ARREAR_RETIREMENT_ANNUITY_ASG_TAX_YTD',
             'A_CURRENT_PROVIDENT_FUND_ASG_TAX_YTD',
             'A_CURRENT_RETIREMENT_ANNUITY_ASG_TAX_YTD',
             'A_MEDICAL_AID_CONTRIBUTION_ASG_TAX_YTD'
             );
      exception
         when no_data_found then
            l_sum := 0;
      end;

-- End adding for balance feed enhancement
-- Added to get if only lump sum payment is made avoid duplicate certificate
      begin

         -- Check the Lump Sum Certificate Income Sources
         select sum(trunc(to_number(arc.value))) value
         into   l_lmpsm_sum
         from  -- pay_za_irp5_bal_codes irp5,
                ff_archive_items      arc,
                ff_database_items     dbi
         where  arc.context1 in (select ch.assignment_action_id
                                 from pay_assignment_actions main
                                 ,    pay_assignment_actions ch
                                 where main.assignment_action_id = p_assignment_action_id
                                 and   ch.payroll_action_id     = main.payroll_action_id
                                 and   ch.assignment_action_id < main.assignment_action_id
                                 AND   ch.assignment_id        = main.assignment_id)
         and
         (
            arc.value is not null
            or
            (
               arc.value is not null
               and arc.value <> 0
            )
         )
         and    dbi.user_entity_id = arc.user_entity_id
--         and    irp5.user_name = dbi.user_name
         and    dbi.user_name in
         (
         'A_EXECUTIVE_EQUITY_SHARES_NRFI_ASG_LMPSM_TAX_YTD'
         ,'A_EXECUTIVE_EQUITY_SHARES_RFI_ASG_LMPSM_TAX_YTD'
         ,'A_OTHER_LUMP_SUMS_ASG_LMPSM_TAX_YTD'
         ,'A_OTHER_RETIREMENT_LUMP_SUMS_ASG_LMPSM_TAX_YTD'
         ,'A_RESIGNATION_PENSION_AND_RAF_LUMP_SUMS_ASG_LMPSM_TAX_YTD'
         ,'A_RESIGNATION_PROVIDENT_LUMP_SUMS_ASG_LMPSM_TAX_YTD'
         ,'A_RETIREMENT_OR_RETRENCHMENT_GRATUITIES_ASG_LMPSM_TAX_YTD'
         ,'A_RETIREMENT_PENSION_AND_RAF_LUMP_SUMS_ASG_LMPSM_TAX_YTD'
         ,'A_RETIREMENT_PROVIDENT_LUMP_SUMS_ASG_LMPSM_TAX_YTD'
         ,'A_SHARE_OPTIONS_EXERCISED_NRFI_ASG_LMPSM_TAX_YTD'
         ,'A_SHARE_OPTIONS_EXERCISED_RFI_ASG_LMPSM_TAX_YTD'
         ,'A_SPECIAL_REMUNERATION_ASG_LMPSM_TAX_YTD'
         ,'A_TAXABLE_ARBITRATION_AWARD_NRFI_ASG_LMPSM_TAX_YTD'
         ,'A_TAXABLE_ARBITRATION_AWARD_RFI_ASG_LMPSM_TAX_YTD'
	-- ,'A_SURPLUS_APPORTIONMENT_ASG_LMPSM_TAX_YTD'
	 ,'A_UNCLAIMED_BENEFITS_ASG_LMPSM_TAX_YTD'
	 ,'A_RETIRE_PEN_RAF_PROV_FUND_BEN_ON_RET_OR_DEATH_RFI_ASG_LMPSM_TAX_YTD'
	 ,'A_RETIRE_PEN_RAF_PROV_FUND_BEN_ON_RET_OR_DEATH_NRFI_ASG_LMPSM_TAX_YTD'
	 ,'A_RETIRE_PEN_RAF_AND_PROV_FUND_LUMP_SUM_WITHDRAWAL_BENEFITS_ASG_LMPSM_TAX_YTD'
          );
          -- Added for the balance feed enhancement

-- End adding for balance feed enhancement
      exception
         when no_data_found then
            l_lmpsm_sum := 0;

      end;
      if l_lmpsm_sum is null then
         l_lmpsm_sum := 0;
      end if;
      l_sum  := l_sum - l_lmpsm_sum;
-- End if only Lump Sum payment is made

-- added l_sum < 0 to avoid certificates for zero balances .
      -- Check the Main Certificate Deductions
      if ((l_sum = 0) or (l_sum is null)) then

         begin

            select sum(trunc(to_number(arc.value))) value
            into   l_sum
            from   ff_archive_items         arc,
                   ff_database_items        dbi
            where  arc.context1 = p_assignment_action_id
            and    dbi.user_name IN (
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
            ,'A_ANNUAL_EE_INCOME_PROTECTION_POLICY_CONTRIBUTIONS_ASG_TAX_YTD'
            ,'A_EE_INCOME_PROTECTION_POLICY_CONTRIBUTIONS_ASG_TAX_YTD'
            ,'A_MEDICAL_AID_CONTRIBUTION_ASG_TAX_YTD'
         ,'A_MED_COSTS_DMD_PD_BY_EE_EE_FAMILY_RFI_ASG_TAX_YTD' -- added on 22-May-2007
         ,'A_MED_COSTS_DMD_PD_BY_EE_EE_FAMILY_NRFI_ASG_TAX_YTD'
         ,'A_MED_COSTS_DMD_PD_BY_EE_EE_FAMILY_PKG_ASG_TAX_YTD'
         ,'A_ANNUAL_MED_COSTS_DMD_PD_BY_EE_EE_FAMILY_RFI_ASG_TAX_YTD'
         ,'A_ANNUAL_MED_COSTS_DMD_PD_BY_EE_EE_FAMILY_NRFI_ASG_TAX_YTD'
         ,'A_ANNUAL_MED_COSTS_DMD_PD_BY_EE_EE_FAMILY_PKG_ASG_TAX_YTD'
         ,'A_MEDICAL_CONTRIBUTIONS_ABATEMENT_ASG_TAX_YTD'
         ,'A_ANNUAL_MEDICAL_CONTRIBUTIONS_ABATEMENT_ASG_TAX_YTD'
	 ,'A_DONATIONS_MADE_BY_EE_AND_PAID_BY_ER_ASG_TAX_YTD'
	 ,'A_ANNUAL_DONATIONS_MADE_BY_EE_AND_PAID_BY_ER_ASG_TAX_YTD'
            )
            and    dbi.user_entity_id = arc.user_entity_id;

         exception
            when no_data_found then
               l_sum := 0;

         end;

      end if;

   else

      begin

         -- Check the Lump Sum Certificate Income Sources
         select sum(trunc(to_number(arc.value))) value
         into   l_sum
         from  -- pay_za_irp5_bal_codes irp5,
                ff_archive_items      arc,
                ff_database_items     dbi
         where  arc.context1 = p_assignment_action_id
         and
         (
            arc.value is not null
            or
            (
               arc.value is not null
               and arc.value <> 0
            )
         )
         and    dbi.user_entity_id = arc.user_entity_id
--         and    irp5.user_name = dbi.user_name
         and    dbi.user_name in
         (
         'A_EXECUTIVE_EQUITY_SHARES_NRFI_ASG_LMPSM_TAX_YTD'
         ,'A_EXECUTIVE_EQUITY_SHARES_RFI_ASG_LMPSM_TAX_YTD'
         ,'A_OTHER_LUMP_SUMS_ASG_LMPSM_TAX_YTD'
         ,'A_OTHER_RETIREMENT_LUMP_SUMS_ASG_LMPSM_TAX_YTD'
         ,'A_RESIGNATION_PENSION_AND_RAF_LUMP_SUMS_ASG_LMPSM_TAX_YTD'
         ,'A_RESIGNATION_PROVIDENT_LUMP_SUMS_ASG_LMPSM_TAX_YTD'
         ,'A_RETIREMENT_OR_RETRENCHMENT_GRATUITIES_ASG_LMPSM_TAX_YTD'
         ,'A_RETIREMENT_PENSION_AND_RAF_LUMP_SUMS_ASG_LMPSM_TAX_YTD'
         ,'A_RETIREMENT_PROVIDENT_LUMP_SUMS_ASG_LMPSM_TAX_YTD'
         ,'A_SHARE_OPTIONS_EXERCISED_NRFI_ASG_LMPSM_TAX_YTD'
         ,'A_SHARE_OPTIONS_EXERCISED_RFI_ASG_LMPSM_TAX_YTD'
         ,'A_SPECIAL_REMUNERATION_ASG_LMPSM_TAX_YTD'
         ,'A_TAXABLE_ARBITRATION_AWARD_NRFI_ASG_LMPSM_TAX_YTD'
         ,'A_TAXABLE_ARBITRATION_AWARD_RFI_ASG_LMPSM_TAX_YTD'
	-- ,'A_SURPLUS_APPORTIONMENT_ASG_LMPSM_TAX_YTD'
	 ,'A_UNCLAIMED_BENEFITS_ASG_LMPSM_TAX_YTD'
	 ,'A_RETIRE_PEN_RAF_PROV_FUND_BEN_ON_RET_OR_DEATH_RFI_ASG_LMPSM_TAX_YTD'
	 ,'A_RETIRE_PEN_RAF_PROV_FUND_BEN_ON_RET_OR_DEATH_NRFI_ASG_LMPSM_TAX_YTD'
	 ,'A_RETIRE_PEN_RAF_AND_PROV_FUND_LUMP_SUM_WITHDRAWAL_BENEFITS_ASG_LMPSM_TAX_YTD'
          );
          -- Added for the balance feed enhancement

-- End adding for balance feed enhancement
      exception
         when no_data_found then
            l_sum := 0;

      end;

   end if;

   if ((l_sum <= 0) or (l_sum is null)) then

      -- If the assignment had zero for all his balances then don't include him
      return 'A';

   else   -- Check for IRP5/IT3A

      if l_total > 0 then

         return 'Y';

      else

         return 'N';

      end if;

   end if;

end irp5_indicator;

---------------------------------------------------------------------------
-- This function is used to retrieve the Tax Status, Tax Directive Number
-- and Tax Directive Value Input Values from the ZA_Tax element
---------------------------------------------------------------------------
--Bug 5231652
-- Removed, as this procedure was not referenced anymore
/*
procedure get_tax_data
(
   assignment_id          in     number,
   assignment_action_id   in     number,
   date_earned            in     date,
   p_tax_status           in out nocopy varchar2,
   p_directive_number     in out nocopy varchar2,
   p_directive_value      in out nocopy number,
   p_lump_sum_indicator   in     varchar2
)  is
*/
--
/*-----------------------------------------------------------------------------
  Name      : get_sars_code
  Purpose   : Returns the correct SARS Code for Directors and/or Foreign Income
  Arguments : SARS Code
              Tax Status
              Nature of Person
  Notes     : This function is used to establish the SARS Code that needs to
              be printed on Tax Year End Reports and the Electronic Tax Year
              End File. It works on the principle that where the Nature of Person
              is 'C' (Director of Private Company or Member of Close Corporation)
              OR where Tax Status is 'M', 'N', 'P' or 'Q' (Private Director,
              Private Director with Directive Amount, Private Director with
              Directive Percentage or Private Director Zero Tax), the SARS Code
              3601 must be changed to 3615, and additionally,
              where Nature of Person is 'M' (Foreign Employment Income),
              50 must be added to the SARS Code.
-----------------------------------------------------------------------------*/

function get_sars_code
(
   p_sars_code    in     varchar2,
   p_tax_status   in     varchar2,
   p_nature       in     varchar2
)  return varchar2 is

l_tax_status      fnd_lookup_values.lookup_code%type;
l_nature          fnd_lookup_values.meaning%type;
l_sars_code       varchar2(256);

begin

   -- Local variable initialization - GSCC standards
   l_sars_code := 0;

   if ((p_nature = 'C' or (p_tax_status in ('M', 'N', 'P', 'Q'))) and p_sars_code = '3601')
   then
      l_sars_code := '3615';
   else
      l_sars_code := p_sars_code;
   end if;

   if (p_nature = 'M' and to_number(l_sars_code) >= 3601 and to_number(l_sars_code) <= 3907
                      and to_number(l_sars_code) not in (3695, 3696, 3697, 3698, 3699))
   then
      l_sars_code := to_char(to_number(l_sars_code) + 50);
   end if;

   return l_sars_code;

end get_sars_code;


end py_za_tax_certificates;

/
