--------------------------------------------------------
--  DDL for Package Body PAY_RI_AC_TAX_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RI_AC_TAX_RULE" as
/* $Header: payacemptaxwrap.pkb 120.0 2005/09/10 03:48:48 psnellin noship $ */

 l_pay_us_fedtax_rule_rec         pay_us_emp_fed_tax_rules_f%ROWTYPE;
 l_pay_us_statetax_rule_rec       PAY_US_EMP_STATE_TAX_RULES_F%ROWTYPE;
 l_pay_us_countytax_rule_rec      PAY_US_EMP_COUNTY_TAX_RULES_F%ROWTYPE;
 l_pay_us_citytax_rule_rec        PAY_US_EMP_CITY_TAX_RULES_F%ROWTYPE;

 l_pay_ca_fedtax_rule_rec         PAY_CA_EMP_FED_TAX_INFO_F%ROWTYPE;
 l_pay_ca_provtax_rule_rec        PAY_CA_EMP_PROV_TAX_INFO_F%ROWTYPE;
 g_employee   varchar2(250);
 g_assignment varchar2(20);
 g_link_value number(15);
 g_user_sequence number(15);

-- =============================================================================
-- HR_DataPump:
--
-- NOTE : p_data_pump_batch_line_id is used as link_value_id in the procedure
--        as in future we may have to have it as batch_line_ids concatenated
--        string
-- =============================================================================
PROCEDURE HR_DataPump
          (p_dp_mode                 IN Varchar2
          ,p_effective_date          IN Date
          ,p_spreadsheet_identifier  IN Varchar2
          ) AS

  l_datetrack_update_mode  Varchar2(50);
  l_dt_correction          Boolean;
  l_dt_update              Boolean;
  l_dt_upd_override        Boolean;
  l_upd_chg_ins            Boolean;

  l_effective_date         Date;

  /* Added for wrap pkg datapump */
  ln_ovn number;
  ld_eff_start_date  date;
  ld_eff_end_date   date;
  ln_emp_state_tax_rule_id number;
  ln_emp_county_tax_rule_id number;
  ln_emp_city_tax_rule_id number;
  ln_ca_emp_fed_tax_inf_id number;
  ln_ca_emp_prov_tax_inf_id number;

begin

  l_effective_date := trunc(p_effective_date);
  ln_ovn := NULL;

  -- Create a batch line for US Emp Fed Tax Rule Information

  if P_SPREADSHEET_IDENTIFIER = 'PAYRIUSFED' then

      hr_utility.trace('p_dp_mode :'||p_dp_mode);

      -- check for valid datatrack update modes
      Dt_Api.Find_DT_Upd_Modes
     (p_effective_date        => l_effective_date
     ,p_base_table_name       => 'PAY_US_EMP_FED_TAX_RULES_F'
     ,p_base_key_column       => 'EMP_FED_TAX_RULE_ID'
     ,p_base_key_value        => l_pay_us_fedtax_rule_rec.emp_fed_tax_rule_id
     ,p_correction            => l_dt_correction
     ,p_update                => l_dt_update
     ,p_update_override       => l_dt_upd_override
     ,p_update_change_insert  => l_upd_chg_ins
      );


     IF l_dt_update THEN

          l_datetrack_update_mode := 'UPDATE';
          hr_utility.trace('l_datetrack_update_mode :'||l_datetrack_update_mode);

     ELSIF l_dt_upd_override OR
          l_upd_chg_ins THEN
          -- Cannnot update the record because future dated record found
          -- NULL;
           hr_utility.set_message(801, 'HR_7211_DT_UPD_ROWS_IN_FUTURE');
           hr_utility.raise_error;
     ELSE
          l_datetrack_update_mode := 'CORRECTION';
          hr_utility.trace('l_datetrack_update_mode :'||l_datetrack_update_mode);
     END IF;


   ln_ovn := l_pay_us_fedtax_rule_rec.OBJECT_VERSION_NUMBER;

   pay_federal_tax_rule_api.update_fed_tax_rule
   (
    p_effective_date                 => p_effective_date
   ,p_datetrack_update_mode          => l_datetrack_update_mode
   ,p_emp_fed_tax_rule_id            => l_pay_us_fedtax_rule_rec.emp_fed_tax_rule_id
   ,p_object_version_number          => ln_ovn
   ,p_sui_state_code                 => l_pay_us_fedtax_rule_rec.sui_state_code
   ,p_filing_status_code             => l_pay_us_fedtax_rule_rec.FILING_STATUS_CODE
   ,p_fit_override_amount            => l_pay_us_fedtax_rule_rec.FIT_OVERRIDE_AMOUNT
   ,p_fit_override_rate              => l_pay_us_fedtax_rule_rec.FIT_OVERRIDE_RATE
   ,p_withholding_allowances         => l_pay_us_fedtax_rule_rec.WITHHOLDING_ALLOWANCES
   ,p_cumulative_taxation            => l_pay_us_fedtax_rule_rec.CUMULATIVE_TAXATION
   ,p_eic_filing_status_code         => l_pay_us_fedtax_rule_rec.EIC_FILING_STATUS_CODE
   ,p_fit_additional_tax             => l_pay_us_fedtax_rule_rec.FIT_ADDITIONAL_TAX
   ,p_fit_exempt                     => l_pay_us_fedtax_rule_rec.FIT_EXEMPT
   ,p_futa_tax_exempt                => l_pay_us_fedtax_rule_rec.FUTA_TAX_EXEMPT
   ,p_medicare_tax_exempt            => l_pay_us_fedtax_rule_rec.MEDICARE_TAX_EXEMPT
   ,p_ss_tax_exempt                  => l_pay_us_fedtax_rule_rec.SS_TAX_EXEMPT
   ,p_statutory_employee             => l_pay_us_fedtax_rule_rec.STATUTORY_EMPLOYEE
   ,p_supp_tax_override_rate         => l_pay_us_fedtax_rule_rec.SUPP_TAX_OVERRIDE_RATE
   ,p_excessive_wa_reject_date       => l_pay_us_fedtax_rule_rec.EXCESSIVE_WA_REJECT_DATE
   ,p_effective_start_date           => ld_eff_start_date
   ,p_effective_end_date             => ld_eff_end_date
  );

    hr_utility.trace('call to hrdpp_UPDATE_FED_TAX_RULE.insert_batch_lines done');

  end if; -- p_spreadsheet_identifier = 'PAYRIUSFED'



  if P_SPREADSHEET_IDENTIFIER = 'PAYRIUSSTATE' then

    if p_dp_mode = 'UPDATE' then

      hr_utility.trace('p_dp_mode :'||p_dp_mode);

      -- check for valid datatrack update modes
      Dt_Api.Find_DT_Upd_Modes
     (p_effective_date        => l_effective_date
     ,p_base_table_name       => 'PAY_US_EMP_STATE_TAX_RULES_F'
     ,p_base_key_column       => 'EMP_STATE_TAX_RULE_ID'
     ,p_base_key_value        => l_pay_us_statetax_rule_rec.EMP_STATE_TAX_RULE_ID
     ,p_correction            => l_dt_correction
     ,p_update                => l_dt_update
     ,p_update_override       => l_dt_upd_override
     ,p_update_change_insert  => l_upd_chg_ins
      );


     IF l_dt_update THEN

          l_datetrack_update_mode := 'UPDATE';
          hr_utility.trace('l_datetrack_update_mode :'||l_datetrack_update_mode);

     ELSIF l_dt_upd_override OR
          l_upd_chg_ins THEN
           hr_utility.set_message(801, 'HR_7211_DT_UPD_ROWS_IN_FUTURE');
           hr_utility.raise_error;
     ELSE
          l_datetrack_update_mode := 'CORRECTION';
          hr_utility.trace('l_datetrack_update_mode :'||l_datetrack_update_mode);
     END IF;


      ln_ovn := l_pay_us_statetax_rule_rec.OBJECT_VERSION_NUMBER;

      hr_utility.trace('Calling PAY_STATE_TAX_RULE_API.UPDATE_STATE_TAX_RULE');
      PAY_STATE_TAX_RULE_API.UPDATE_STATE_TAX_RULE
         (P_EFFECTIVE_DATE                 => l_effective_date
         ,P_DATETRACK_UPDATE_MODE          => l_datetrack_update_mode
         ,P_EMP_STATE_TAX_RULE_ID          => l_pay_us_statetax_rule_rec.EMP_STATE_TAX_RULE_ID
         ,p_object_version_number          => ln_ovn
         ,P_ADDITIONAL_WA_AMOUNT           => l_pay_us_statetax_rule_rec.ADDITIONAL_WA_AMOUNT
         ,P_FILING_STATUS_CODE             => l_pay_us_statetax_rule_rec.FILING_STATUS_CODE
         ,P_SECONDARY_WA                   => l_pay_us_statetax_rule_rec.SECONDARY_WA
         ,P_SIT_ADDITIONAL_TAX             => l_pay_us_statetax_rule_rec.SIT_ADDITIONAL_TAX
         ,P_SIT_OVERRIDE_AMOUNT            => l_pay_us_statetax_rule_rec.SIT_OVERRIDE_AMOUNT
         ,P_SIT_OVERRIDE_RATE              => l_pay_us_statetax_rule_rec.SIT_OVERRIDE_RATE
         ,P_WITHHOLDING_ALLOWANCES         => l_pay_us_statetax_rule_rec.WITHHOLDING_ALLOWANCES
         ,P_EXCESSIVE_WA_REJECT_DATE       => l_pay_us_statetax_rule_rec.EXCESSIVE_WA_REJECT_DATE
         ,P_SDI_EXEMPT                     => l_pay_us_statetax_rule_rec.SDI_EXEMPT
         ,P_SIT_EXEMPT                     => l_pay_us_statetax_rule_rec.SIT_EXEMPT
         ,P_SIT_OPTIONAL_CALC_IND          => l_pay_us_statetax_rule_rec.SIT_OPTIONAL_CALC_IND
         ,P_STATE_NON_RESIDENT_CERT        => l_pay_us_statetax_rule_rec.STATE_NON_RESIDENT_CERT
         ,P_SUI_EXEMPT                     => l_pay_us_statetax_rule_rec.SUI_EXEMPT
         ,P_WC_EXEMPT                      => l_pay_us_statetax_rule_rec.WC_EXEMPT
         ,P_SUI_WAGE_BASE_OVERRIDE_AMOUN   => l_pay_us_statetax_rule_rec.SUI_WAGE_BASE_OVERRIDE_AMOUNT
         ,P_SUPP_TAX_OVERRIDE_RATE         => l_pay_us_statetax_rule_rec.SUPP_TAX_OVERRIDE_RATE
         ,P_STA_INFORMATION_CATEGORY       => l_pay_us_statetax_rule_rec.STA_INFORMATION_CATEGORY
         ,P_STA_INFORMATION1               => l_pay_us_statetax_rule_rec.STA_INFORMATION1
         ,P_STA_INFORMATION2               => l_pay_us_statetax_rule_rec.STA_INFORMATION2
         ,P_STA_INFORMATION3               => l_pay_us_statetax_rule_rec.STA_INFORMATION3
         ,P_STA_INFORMATION4               => l_pay_us_statetax_rule_rec.STA_INFORMATION4
         ,P_STA_INFORMATION5               => l_pay_us_statetax_rule_rec.STA_INFORMATION5
         ,P_STA_INFORMATION6               => l_pay_us_statetax_rule_rec.STA_INFORMATION6
         ,P_STA_INFORMATION7               => l_pay_us_statetax_rule_rec.STA_INFORMATION7
         ,P_STA_INFORMATION8               => l_pay_us_statetax_rule_rec.STA_INFORMATION8
         ,P_STA_INFORMATION9               => l_pay_us_statetax_rule_rec.STA_INFORMATION9
         ,P_STA_INFORMATION10               => l_pay_us_statetax_rule_rec.STA_INFORMATION10
         ,P_STA_INFORMATION11               => l_pay_us_statetax_rule_rec.STA_INFORMATION11
         ,P_STA_INFORMATION12               => l_pay_us_statetax_rule_rec.STA_INFORMATION12
         ,P_STA_INFORMATION13               => l_pay_us_statetax_rule_rec.STA_INFORMATION13
         ,P_STA_INFORMATION14               => l_pay_us_statetax_rule_rec.STA_INFORMATION14
         ,P_STA_INFORMATION15               => l_pay_us_statetax_rule_rec.STA_INFORMATION15
         ,P_STA_INFORMATION16               => l_pay_us_statetax_rule_rec.STA_INFORMATION16
         ,P_STA_INFORMATION17               => l_pay_us_statetax_rule_rec.STA_INFORMATION17
         ,P_STA_INFORMATION18               => l_pay_us_statetax_rule_rec.STA_INFORMATION18
         ,P_STA_INFORMATION19               => l_pay_us_statetax_rule_rec.STA_INFORMATION19
         ,P_STA_INFORMATION20               => l_pay_us_statetax_rule_rec.STA_INFORMATION20
         ,P_STA_INFORMATION21               => l_pay_us_statetax_rule_rec.STA_INFORMATION21
         ,P_STA_INFORMATION22               => l_pay_us_statetax_rule_rec.STA_INFORMATION22
         ,P_STA_INFORMATION23               => l_pay_us_statetax_rule_rec.STA_INFORMATION23
         ,P_STA_INFORMATION24               => l_pay_us_statetax_rule_rec.STA_INFORMATION24
         ,P_STA_INFORMATION25               => l_pay_us_statetax_rule_rec.STA_INFORMATION25
         ,P_STA_INFORMATION26               => l_pay_us_statetax_rule_rec.STA_INFORMATION26
         ,P_STA_INFORMATION27               => l_pay_us_statetax_rule_rec.STA_INFORMATION27
         ,P_STA_INFORMATION28               => l_pay_us_statetax_rule_rec.STA_INFORMATION28
         ,P_STA_INFORMATION29              => l_pay_us_statetax_rule_rec.STA_INFORMATION29
         ,P_STA_INFORMATION30              => l_pay_us_statetax_rule_rec.STA_INFORMATION30
         ,p_effective_start_date           => ld_eff_start_date
         ,p_effective_end_date             => ld_eff_end_date
         );

    hr_utility.trace('call to hrdpp_UPDATE_STATE_TAX_RULE.insert_batch_lines done');

   elsif p_dp_mode = 'INSERT' then

      hr_utility.trace('p_dp_mode :'||p_dp_mode);
      hr_utility.trace('calling PAY_STATE_TAX_RULE_API.CREATE_STATE_TAX_RULE ');

      PAY_STATE_TAX_RULE_API.CREATE_STATE_TAX_RULE
         (P_EFFECTIVE_DATE                 => p_effective_date
         ,P_ASSIGNMENT_ID                  => l_pay_us_statetax_rule_rec.ASSIGNMENT_ID
         ,P_STATE_CODE                     => l_pay_us_statetax_rule_rec.STATE_CODE
         ,P_ADDITIONAL_WA_AMOUNT           => NVL(l_pay_us_statetax_rule_rec.ADDITIONAL_WA_AMOUNT,0)
         ,P_FILING_STATUS_CODE             => l_pay_us_statetax_rule_rec.FILING_STATUS_CODE
         ,p_remainder_percent              => NVL(l_pay_us_statetax_rule_rec.REMAINDER_PERCENT,0)
         ,P_SECONDARY_WA                   => NVL(l_pay_us_statetax_rule_rec.SECONDARY_WA,0)
         ,P_SIT_ADDITIONAL_TAX             => NVL(l_pay_us_statetax_rule_rec.SIT_ADDITIONAL_TAX,0)
         ,P_SIT_OVERRIDE_AMOUNT            => NVL(l_pay_us_statetax_rule_rec.SIT_OVERRIDE_AMOUNT,0)
         ,P_SIT_OVERRIDE_RATE              => NVL(l_pay_us_statetax_rule_rec.SIT_OVERRIDE_RATE,0)
         ,P_WITHHOLDING_ALLOWANCES         => NVL(l_pay_us_statetax_rule_rec.WITHHOLDING_ALLOWANCES,0)
         ,P_EXCESSIVE_WA_REJECT_DATE       => l_pay_us_statetax_rule_rec.EXCESSIVE_WA_REJECT_DATE
         ,P_SDI_EXEMPT                     => l_pay_us_statetax_rule_rec.SDI_EXEMPT
         ,P_SIT_EXEMPT                     => l_pay_us_statetax_rule_rec.SIT_EXEMPT
         ,P_SIT_OPTIONAL_CALC_IND          => l_pay_us_statetax_rule_rec.SIT_OPTIONAL_CALC_IND
         ,P_STATE_NON_RESIDENT_CERT        => l_pay_us_statetax_rule_rec.STATE_NON_RESIDENT_CERT
         ,P_SUI_EXEMPT                     => l_pay_us_statetax_rule_rec.SUI_EXEMPT
         ,P_WC_EXEMPT                      => l_pay_us_statetax_rule_rec.WC_EXEMPT
         ,P_SUI_WAGE_BASE_OVERRIDE_AMOUN   => l_pay_us_statetax_rule_rec.SUI_WAGE_BASE_OVERRIDE_AMOUNT
         ,P_SUPP_TAX_OVERRIDE_RATE         => NVL(l_pay_us_statetax_rule_rec.SUPP_TAX_OVERRIDE_RATE,0)
         ,P_STA_INFORMATION_CATEGORY       => l_pay_us_statetax_rule_rec.STA_INFORMATION_CATEGORY
         ,P_STA_INFORMATION1               => l_pay_us_statetax_rule_rec.STA_INFORMATION1
         ,P_STA_INFORMATION2               => l_pay_us_statetax_rule_rec.STA_INFORMATION2
         ,P_STA_INFORMATION3               => l_pay_us_statetax_rule_rec.STA_INFORMATION3
         ,P_STA_INFORMATION4               => l_pay_us_statetax_rule_rec.STA_INFORMATION4
         ,P_STA_INFORMATION5               => l_pay_us_statetax_rule_rec.STA_INFORMATION5
         ,P_STA_INFORMATION6               => l_pay_us_statetax_rule_rec.STA_INFORMATION6
         ,P_STA_INFORMATION7               => l_pay_us_statetax_rule_rec.STA_INFORMATION7
         ,P_STA_INFORMATION8               => l_pay_us_statetax_rule_rec.STA_INFORMATION8
         ,P_STA_INFORMATION9               => l_pay_us_statetax_rule_rec.STA_INFORMATION9
         ,P_STA_INFORMATION10              => l_pay_us_statetax_rule_rec.STA_INFORMATION10
         ,P_STA_INFORMATION11              => l_pay_us_statetax_rule_rec.STA_INFORMATION11
         ,P_STA_INFORMATION12              => l_pay_us_statetax_rule_rec.STA_INFORMATION12
         ,P_STA_INFORMATION13              => l_pay_us_statetax_rule_rec.STA_INFORMATION13
         ,P_STA_INFORMATION14              => l_pay_us_statetax_rule_rec.STA_INFORMATION14
         ,P_STA_INFORMATION15              => l_pay_us_statetax_rule_rec.STA_INFORMATION15
         ,P_STA_INFORMATION16              => l_pay_us_statetax_rule_rec.STA_INFORMATION16
         ,P_STA_INFORMATION17              => l_pay_us_statetax_rule_rec.STA_INFORMATION17
         ,P_STA_INFORMATION18              => l_pay_us_statetax_rule_rec.STA_INFORMATION18
         ,P_STA_INFORMATION19              => l_pay_us_statetax_rule_rec.STA_INFORMATION19
         ,P_STA_INFORMATION20              => l_pay_us_statetax_rule_rec.STA_INFORMATION20
         ,P_STA_INFORMATION21              => l_pay_us_statetax_rule_rec.STA_INFORMATION21
         ,P_STA_INFORMATION22              => l_pay_us_statetax_rule_rec.STA_INFORMATION22
         ,P_STA_INFORMATION23              => l_pay_us_statetax_rule_rec.STA_INFORMATION23
         ,P_STA_INFORMATION24              => l_pay_us_statetax_rule_rec.STA_INFORMATION24
         ,P_STA_INFORMATION25              => l_pay_us_statetax_rule_rec.STA_INFORMATION25
         ,P_STA_INFORMATION26              => l_pay_us_statetax_rule_rec.STA_INFORMATION26
         ,P_STA_INFORMATION27              => l_pay_us_statetax_rule_rec.STA_INFORMATION27
         ,P_STA_INFORMATION28              => l_pay_us_statetax_rule_rec.STA_INFORMATION28
         ,P_STA_INFORMATION29              => l_pay_us_statetax_rule_rec.STA_INFORMATION29
         ,P_STA_INFORMATION30              => l_pay_us_statetax_rule_rec.STA_INFORMATION30
         ,p_emp_state_tax_rule_id          => ln_emp_state_tax_rule_id
         ,p_object_version_number             => ln_ovn
         ,p_effective_start_date              => ld_eff_start_date
         ,p_effective_end_date                => ld_eff_end_date
         );

    hr_utility.trace('emp_state_tax_rule_id : '||to_char(ln_emp_state_tax_rule_id));
    hr_utility.trace('call to PAY_STATE_TAX_RULE_API.CREATE_STATE_TAX_RULE done');
   end if; -- end if for p_dp_mode validation for US State Tax

  end if; -- p_spreadsheet_identifier = 'PAYRIUSSTATE'


  if P_SPREADSHEET_IDENTIFIER = 'PAYRIUSCOUNTY' then

    if p_dp_mode = 'UPDATE' then

       hr_utility.trace('p_dp_mode :'||p_dp_mode);


       -- check for valid datatrack update modes
       Dt_Api.Find_DT_Upd_Modes
      (p_effective_date        => l_effective_date
      ,p_base_table_name       => 'PAY_US_EMP_COUNTY_TAX_RULES_F'
      ,p_base_key_column       => 'EMP_COUNTY_TAX_RULE_ID'
      ,p_base_key_value        => l_pay_us_countytax_rule_rec.EMP_COUNTY_TAX_RULE_ID
      ,p_correction            => l_dt_correction
      ,p_update                => l_dt_update
      ,p_update_override       => l_dt_upd_override
      ,p_update_change_insert  => l_upd_chg_ins
       );


      IF l_dt_update THEN

          l_datetrack_update_mode := 'UPDATE';
          hr_utility.trace('l_datetrack_update_mode :'||l_datetrack_update_mode);

      ELSIF l_dt_upd_override OR
            l_upd_chg_ins THEN
          -- Need to check if future datetrack records exist
          -- if yes then raise error
          -- NULL;
           hr_utility.set_message(801, 'HR_7211_DT_UPD_ROWS_IN_FUTURE');
           hr_utility.raise_error;
      ELSE
          l_datetrack_update_mode := 'CORRECTION';
          hr_utility.trace('l_datetrack_update_mode :'||l_datetrack_update_mode);
      END IF;

       ln_ovn := l_pay_us_countytax_rule_rec.OBJECT_VERSION_NUMBER;

       pay_county_tax_rule_api.update_county_tax_rule
       (p_emp_county_tax_rule_id         => l_pay_us_countytax_rule_rec.EMP_COUNTY_TAX_RULE_ID
       ,p_effective_start_date           => ld_eff_start_date
       ,p_effective_end_date             => ld_eff_end_date
       ,p_additional_wa_rate             => l_pay_us_countytax_rule_rec.ADDITIONAL_WA_RATE
       ,p_filing_status_code             => l_pay_us_countytax_rule_rec.FILING_STATUS_CODE
       ,p_lit_additional_tax             => l_pay_us_countytax_rule_rec.LIT_ADDITIONAL_TAX
       ,p_lit_override_amount            => l_pay_us_countytax_rule_rec.LIT_OVERRIDE_AMOUNT
       ,p_lit_override_rate              => l_pay_us_countytax_rule_rec.LIT_OVERRIDE_RATE
       ,p_withholding_allowances         => l_pay_us_countytax_rule_rec.WITHHOLDING_ALLOWANCES
       ,p_lit_exempt                     => l_pay_us_countytax_rule_rec.LIT_EXEMPT
       ,p_sd_exempt                      => l_pay_us_countytax_rule_rec.SD_EXEMPT
       ,p_ht_exempt                      => l_pay_us_countytax_rule_rec.HT_EXEMPT
       ,p_school_district_code           => l_pay_us_countytax_rule_rec.SCHOOL_DISTRICT_CODE
       ,p_object_version_number          => ln_ovn
       ,p_effective_date                 => l_effective_date
       ,p_datetrack_mode                 => l_datetrack_update_mode
       );
      hr_utility.trace('call to pay_county_tax_rule_api.update_county_tax_rule done');

    elsif p_dp_mode = 'INSERT' then

      hr_utility.trace('p_dp_mode :'||p_dp_mode);

         pay_county_tax_rule_api.create_county_tax_rule
         (p_emp_county_tax_rule_id         => ln_emp_county_tax_rule_id
         ,p_effective_start_date           => ld_eff_start_date
         ,p_effective_end_date             => ld_eff_end_date
         ,p_assignment_id                  => l_pay_us_countytax_rule_rec.assignment_id
         ,p_state_code                     => l_pay_us_countytax_rule_rec.state_code
         ,p_county_code                    => l_pay_us_countytax_rule_rec.county_code
         ,p_additional_wa_rate             => l_pay_us_countytax_rule_rec.ADDITIONAL_WA_RATE
         ,p_filing_status_code             => l_pay_us_countytax_rule_rec.FILING_STATUS_CODE
         ,p_lit_additional_tax             => l_pay_us_countytax_rule_rec.LIT_ADDITIONAL_TAX
         ,p_lit_override_amount            => l_pay_us_countytax_rule_rec.LIT_OVERRIDE_AMOUNT
         ,p_lit_override_rate              => l_pay_us_countytax_rule_rec.LIT_OVERRIDE_RATE
         ,p_withholding_allowances         => l_pay_us_countytax_rule_rec.WITHHOLDING_ALLOWANCES
         ,p_lit_exempt                     => l_pay_us_countytax_rule_rec.LIT_EXEMPT
         ,p_sd_exempt                      => l_pay_us_countytax_rule_rec.SD_EXEMPT
         ,p_ht_exempt                      => l_pay_us_countytax_rule_rec.HT_EXEMPT
         ,p_school_district_code           => l_pay_us_countytax_rule_rec.SCHOOL_DISTRICT_CODE
         ,p_object_version_number          => ln_ovn
         ,p_effective_date                 => l_effective_date
         );


      hr_utility.trace('call to pay_county_tax_rule_api.create_county_tax_rule done');
    end if; -- end if for p_dp_mode validation for US County Tax

  end if; -- P_SPREADSHEET_IDENTIFIER = 'PAYRIUSCOUNTY'


  if P_SPREADSHEET_IDENTIFIER = 'PAYRIUSCITY' then

    if p_dp_mode = 'UPDATE' then

       hr_utility.trace('p_dp_mode :'||p_dp_mode);

       -- check for valid datatrack update modes
       Dt_Api.Find_DT_Upd_Modes
      (p_effective_date        => l_effective_date
      ,p_base_table_name       => 'PAY_US_EMP_CITY_TAX_RULES_F'
      ,p_base_key_column       => 'EMP_CITY_TAX_RULE_ID'
      ,p_base_key_value        => l_pay_us_citytax_rule_rec.EMP_CITY_TAX_RULE_ID
      ,p_correction            => l_dt_correction
      ,p_update                => l_dt_update
      ,p_update_override       => l_dt_upd_override
      ,p_update_change_insert  => l_upd_chg_ins
       );

        IF l_dt_update THEN

          l_datetrack_update_mode := 'UPDATE';
          hr_utility.trace('l_datetrack_update_mode :'||l_datetrack_update_mode);

        ELSIF l_dt_upd_override OR
            l_upd_chg_ins THEN
          -- Need to check if future datetrack records exist
          -- if yes then raise error
          -- NULL;
           hr_utility.set_message(801, 'HR_7211_DT_UPD_ROWS_IN_FUTURE');
           hr_utility.raise_error;
        ELSE
          l_datetrack_update_mode := 'CORRECTION';
          hr_utility.trace('l_datetrack_update_mode :'||l_datetrack_update_mode);
        END IF;


         ln_ovn := l_pay_us_citytax_rule_rec.OBJECT_VERSION_NUMBER;

         pay_city_tax_rule_api.update_city_tax_rule
         (P_DATETRACK_MODE                 => l_datetrack_update_mode
         ,P_EFFECTIVE_DATE                 => l_effective_date
         ,P_ADDITIONAL_WA_RATE             => l_pay_us_citytax_rule_rec.ADDITIONAL_WA_RATE
         ,P_FILING_STATUS_CODE             => l_pay_us_citytax_rule_rec.FILING_STATUS_CODE
         ,P_LIT_ADDITIONAL_TAX             => l_pay_us_citytax_rule_rec.LIT_ADDITIONAL_TAX
         ,P_LIT_OVERRIDE_AMOUNT            => l_pay_us_citytax_rule_rec.LIT_OVERRIDE_AMOUNT
         ,P_LIT_OVERRIDE_RATE              => l_pay_us_citytax_rule_rec.LIT_OVERRIDE_RATE
         ,P_WITHHOLDING_ALLOWANCES         => l_pay_us_citytax_rule_rec.WITHHOLDING_ALLOWANCES
         ,P_LIT_EXEMPT                     => l_pay_us_citytax_rule_rec.LIT_EXEMPT
         ,P_SD_EXEMPT                      => l_pay_us_citytax_rule_rec.SD_EXEMPT
         ,P_HT_EXEMPT                      => l_pay_us_citytax_rule_rec.HT_EXEMPT
         ,P_SCHOOL_DISTRICT_CODE           => l_pay_us_citytax_rule_rec.SCHOOL_DISTRICT_CODE
         ,p_emp_city_tax_rule_id           => l_pay_us_citytax_rule_rec.EMP_CITY_TAX_RULE_ID
         ,p_object_version_number          => ln_ovn
         ,p_effective_start_date           => ld_eff_start_date
         ,p_effective_end_date             => ld_eff_end_date
         );

         hr_utility.trace('call to pay_city_tax_rule_api.update_city_tax_rule done');

    elsif p_dp_mode = 'INSERT' then

         hr_utility.trace('p_dp_mode :'||p_dp_mode);

         pay_city_tax_rule_api.create_city_tax_rule
         (P_ASSIGNMENT_ID                  => l_pay_us_citytax_rule_rec.ASSIGNMENT_ID
         ,P_STATE_CODE                     => l_pay_us_citytax_rule_rec.state_code
         ,P_COUNTY_CODE                    => l_pay_us_citytax_rule_rec.county_code
         ,P_CITY_CODE                      => l_pay_us_citytax_rule_rec.city_code
         ,P_EFFECTIVE_DATE                 => l_effective_date
         ,P_ADDITIONAL_WA_RATE             => l_pay_us_citytax_rule_rec.ADDITIONAL_WA_RATE
         ,P_FILING_STATUS_CODE             => l_pay_us_citytax_rule_rec.FILING_STATUS_CODE
         ,P_LIT_ADDITIONAL_TAX             => l_pay_us_citytax_rule_rec.LIT_ADDITIONAL_TAX
         ,P_LIT_OVERRIDE_AMOUNT            => l_pay_us_citytax_rule_rec.LIT_OVERRIDE_AMOUNT
         ,P_LIT_OVERRIDE_RATE              => l_pay_us_citytax_rule_rec.LIT_OVERRIDE_RATE
         ,P_WITHHOLDING_ALLOWANCES         => l_pay_us_citytax_rule_rec.WITHHOLDING_ALLOWANCES
         ,P_LIT_EXEMPT                     => l_pay_us_citytax_rule_rec.LIT_EXEMPT
         ,P_SD_EXEMPT                      => l_pay_us_citytax_rule_rec.SD_EXEMPT
         ,P_HT_EXEMPT                      => l_pay_us_citytax_rule_rec.HT_EXEMPT
         ,P_SCHOOL_DISTRICT_CODE           => l_pay_us_citytax_rule_rec.SCHOOL_DISTRICT_CODE
         ,p_emp_city_tax_rule_id           => ln_emp_city_tax_rule_id
         ,p_effective_start_date           => ld_eff_start_date
         ,p_effective_end_date             => ld_eff_end_date
	 ,p_object_version_number          => ln_ovn
         );

      hr_utility.trace('call to pay_city_tax_rule_api.create_city_tax_rule done');
    end if; -- end if for p_dp_mode validation for US County Tax

  end if; -- P_SPREADSHEET_IDENTIFIER = 'PAYRIUSCITY'

  if P_SPREADSHEET_IDENTIFIER = 'PAYRICAFED' then

    if p_dp_mode = 'UPDATE' then

      hr_utility.trace('p_dp_mode :'||p_dp_mode);

      -- check for valid datatrack update modes
      Dt_Api.Find_DT_Upd_Modes
     (p_effective_date        => l_effective_date
     ,p_base_table_name       => 'PAY_CA_EMP_FED_TAX_INFO_F'
     ,p_base_key_column       => 'EMP_FED_TAX_INF_ID'
     ,p_base_key_value        => l_pay_ca_fedtax_rule_rec.EMP_FED_TAX_INF_ID
     ,p_correction            => l_dt_correction
     ,p_update                => l_dt_update
     ,p_update_override       => l_dt_upd_override
     ,p_update_change_insert  => l_upd_chg_ins
      );

       IF l_dt_update THEN

          l_datetrack_update_mode := 'UPDATE';
          hr_utility.trace('l_datetrack_update_mode :'||l_datetrack_update_mode);

       ELSIF l_dt_upd_override OR
          l_upd_chg_ins THEN
          -- Need to check if future dated record exists
          -- if yes then raise error
          -- NULL;
           hr_utility.set_message(801, 'HR_7211_DT_UPD_ROWS_IN_FUTURE');
           hr_utility.raise_error;
       ELSE
          l_datetrack_update_mode := 'CORRECTION';
          hr_utility.trace('l_datetrack_update_mode :'||l_datetrack_update_mode);
       END IF;

      ln_ovn := l_pay_ca_fedtax_rule_rec.OBJECT_VERSION_NUMBER;

      pay_ca_emp_fedtax_inf_api.update_ca_emp_fedtax_inf
      (P_ASSIGNMENT_ID 				=> l_pay_ca_fedtax_rule_rec.ASSIGNMENT_ID
      ,P_LEGISLATION_CODE                       => l_pay_ca_fedtax_rule_rec.LEGISLATION_CODE
      ,P_EMPLOYMENT_PROVINCE 			=> l_pay_ca_fedtax_rule_rec.EMPLOYMENT_PROVINCE
      ,P_TAX_CREDIT_AMOUNT 			=> l_pay_ca_fedtax_rule_rec.TAX_CREDIT_AMOUNT
      ,P_BASIC_EXEMPTION_FLAG 			=> l_pay_ca_fedtax_rule_rec.BASIC_EXEMPTION_FLAG
      ,P_ADDITIONAL_TAX 			=> l_pay_ca_fedtax_rule_rec.ADDITIONAL_TAX
      ,P_ANNUAL_DEDN 				=> l_pay_ca_fedtax_rule_rec.ANNUAL_DEDN
      ,P_TOTAL_EXPENSE_BY_COMMISSION 		=> l_pay_ca_fedtax_rule_rec.TOTAL_EXPENSE_BY_COMMISSION
      ,P_TOTAL_REMNRTN_BY_COMMISSION 		=> l_pay_ca_fedtax_rule_rec.TOTAL_REMNRTN_BY_COMMISSION
      ,P_PRESCRIBED_ZONE_DEDN_AMT 		=> l_pay_ca_fedtax_rule_rec.PRESCRIBED_ZONE_DEDN_AMT
      ,P_CPP_QPP_EXEMPT_FLAG 			=> l_pay_ca_fedtax_rule_rec.CPP_QPP_EXEMPT_FLAG
      ,P_FED_EXEMPT_FLAG 			=> l_pay_ca_fedtax_rule_rec.FED_EXEMPT_FLAG
      ,P_EI_EXEMPT_FLAG 			=> l_pay_ca_fedtax_rule_rec.EI_EXEMPT_FLAG
      ,P_FED_OVERRIDE_AMOUNT 			=> l_pay_ca_fedtax_rule_rec.FED_OVERRIDE_AMOUNT
      ,P_FED_OVERRIDE_RATE 			=> l_pay_ca_fedtax_rule_rec.FED_OVERRIDE_RATE
      ,P_OTHER_FEDTAX_CREDITS                   => l_pay_ca_fedtax_rule_rec.OTHER_FEDTAX_CREDITS
      ,P_CA_TAX_INFORMATION_CATEGORY 		=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION_CATEGORY
      ,P_CA_TAX_INFORMATION1 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION1
      ,P_CA_TAX_INFORMATION2 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION2
      ,P_CA_TAX_INFORMATION3 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION3
      ,P_CA_TAX_INFORMATION4 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION4
      ,P_CA_TAX_INFORMATION5 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION5
      ,P_CA_TAX_INFORMATION6 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION6
      ,P_CA_TAX_INFORMATION7 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION7
      ,P_CA_TAX_INFORMATION8 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION8
      ,P_CA_TAX_INFORMATION9 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION9
      ,P_CA_TAX_INFORMATION10 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION10
      ,P_CA_TAX_INFORMATION11 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION11
      ,P_CA_TAX_INFORMATION12 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION12
      ,P_CA_TAX_INFORMATION13 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION13
      ,P_CA_TAX_INFORMATION14 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION14
      ,P_CA_TAX_INFORMATION15 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION15
      ,P_CA_TAX_INFORMATION16 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION16
      ,P_CA_TAX_INFORMATION17 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION17
      ,P_CA_TAX_INFORMATION18 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION18
      ,P_CA_TAX_INFORMATION19 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION19
      ,P_CA_TAX_INFORMATION20 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION20
      ,P_CA_TAX_INFORMATION21 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION21
      ,P_CA_TAX_INFORMATION22 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION22
      ,P_CA_TAX_INFORMATION23 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION23
      ,P_CA_TAX_INFORMATION24 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION24
      ,P_CA_TAX_INFORMATION25 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION25
      ,P_CA_TAX_INFORMATION26 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION26
      ,P_CA_TAX_INFORMATION27 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION27
      ,P_CA_TAX_INFORMATION28 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION28
      ,P_CA_TAX_INFORMATION29 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION29
      ,P_CA_TAX_INFORMATION30 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION30
      ,P_FED_LSF_AMOUNT 			=> l_pay_ca_fedtax_rule_rec.FED_LSF_AMOUNT
      ,p_emp_fed_tax_inf_id                     => l_pay_ca_fedtax_rule_rec.emp_fed_tax_inf_id
      ,P_EFFECTIVE_DATE 			=> l_effective_date
      ,P_DATETRACK_MODE 			=> l_datetrack_update_mode
      ,p_effective_start_date                   => ld_eff_start_date
      ,p_effective_end_date                     => ld_eff_end_date
      ,p_object_version_number                  => ln_ovn);

    hr_utility.trace('call to pay_ca_emp_fedtax_inf_api.update_ca_emp_fedtax_inf done');

   elsif p_dp_mode = 'INSERT' then

      hr_utility.trace('p_dp_mode :'||p_dp_mode);

       pay_ca_emp_fedtax_inf_api.create_ca_emp_fedtax_inf
      (P_ASSIGNMENT_ID 				=> l_pay_ca_fedtax_rule_rec.ASSIGNMENT_ID
      ,P_LEGISLATION_CODE                       => l_pay_ca_fedtax_rule_rec.LEGISLATION_CODE
      ,p_business_group_id                      => l_pay_ca_fedtax_rule_rec.business_group_id
      ,P_EMPLOYMENT_PROVINCE 			=> l_pay_ca_fedtax_rule_rec.EMPLOYMENT_PROVINCE
      ,P_TAX_CREDIT_AMOUNT 			=> l_pay_ca_fedtax_rule_rec.TAX_CREDIT_AMOUNT
      ,P_BASIC_EXEMPTION_FLAG 			=> l_pay_ca_fedtax_rule_rec.BASIC_EXEMPTION_FLAG
      ,P_ADDITIONAL_TAX 			=> l_pay_ca_fedtax_rule_rec.ADDITIONAL_TAX
      ,P_ANNUAL_DEDN 				=> l_pay_ca_fedtax_rule_rec.ANNUAL_DEDN
      ,P_TOTAL_EXPENSE_BY_COMMISSION 		=> l_pay_ca_fedtax_rule_rec.TOTAL_EXPENSE_BY_COMMISSION
      ,P_TOTAL_REMNRTN_BY_COMMISSION 		=> l_pay_ca_fedtax_rule_rec.TOTAL_REMNRTN_BY_COMMISSION
      ,P_PRESCRIBED_ZONE_DEDN_AMT 		=> l_pay_ca_fedtax_rule_rec.PRESCRIBED_ZONE_DEDN_AMT
      ,P_CPP_QPP_EXEMPT_FLAG 			=> l_pay_ca_fedtax_rule_rec.CPP_QPP_EXEMPT_FLAG
      ,P_FED_EXEMPT_FLAG 			=> l_pay_ca_fedtax_rule_rec.FED_EXEMPT_FLAG
      ,P_EI_EXEMPT_FLAG 			=> l_pay_ca_fedtax_rule_rec.EI_EXEMPT_FLAG
      ,P_FED_OVERRIDE_AMOUNT 			=> l_pay_ca_fedtax_rule_rec.FED_OVERRIDE_AMOUNT
      ,P_FED_OVERRIDE_RATE 			=> l_pay_ca_fedtax_rule_rec.FED_OVERRIDE_RATE
      ,P_OTHER_FEDTAX_CREDITS                   => l_pay_ca_fedtax_rule_rec.OTHER_FEDTAX_CREDITS
      ,P_CA_TAX_INFORMATION_CATEGORY 		=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION_CATEGORY
      ,P_CA_TAX_INFORMATION1 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION1
      ,P_CA_TAX_INFORMATION2 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION2
      ,P_CA_TAX_INFORMATION3 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION3
      ,P_CA_TAX_INFORMATION4 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION4
      ,P_CA_TAX_INFORMATION5 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION5
      ,P_CA_TAX_INFORMATION6 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION6
      ,P_CA_TAX_INFORMATION7 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION7
      ,P_CA_TAX_INFORMATION8 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION8
      ,P_CA_TAX_INFORMATION9 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION9
      ,P_CA_TAX_INFORMATION10 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION10
      ,P_CA_TAX_INFORMATION11 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION11
      ,P_CA_TAX_INFORMATION12 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION12
      ,P_CA_TAX_INFORMATION13 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION13
      ,P_CA_TAX_INFORMATION14 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION14
      ,P_CA_TAX_INFORMATION15 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION15
      ,P_CA_TAX_INFORMATION16 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION16
      ,P_CA_TAX_INFORMATION17 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION17
      ,P_CA_TAX_INFORMATION18 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION18
      ,P_CA_TAX_INFORMATION19 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION19
      ,P_CA_TAX_INFORMATION20 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION20
      ,P_CA_TAX_INFORMATION21 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION21
      ,P_CA_TAX_INFORMATION22 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION22
      ,P_CA_TAX_INFORMATION23 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION23
      ,P_CA_TAX_INFORMATION24 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION24
      ,P_CA_TAX_INFORMATION25 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION25
      ,P_CA_TAX_INFORMATION26 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION26
      ,P_CA_TAX_INFORMATION27 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION27
      ,P_CA_TAX_INFORMATION28 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION28
      ,P_CA_TAX_INFORMATION29 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION29
      ,P_CA_TAX_INFORMATION30 			=> l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION30
      ,P_FED_LSF_AMOUNT 			=> l_pay_ca_fedtax_rule_rec.FED_LSF_AMOUNT
      ,p_emp_fed_tax_inf_id                     => ln_ca_emp_fed_tax_inf_id
      ,P_EFFECTIVE_DATE 			=> l_effective_date
      ,p_effective_start_date                   => ld_eff_start_date
      ,p_effective_end_date                     => ld_eff_end_date
	  ,p_object_version_number              => ln_ovn);

       hr_utility.trace('call to  pay_ca_emp_fedtax_inf_api.create_ca_emp_fedtax_inf done');
   end if; -- end if for p_dp_mode validation for Canada Federal Tax

  end if; -- p_spreadsheet_identifier = 'PAYRICAFED'

  if P_SPREADSHEET_IDENTIFIER = 'PAYRICAPROVINCE' then

    if p_dp_mode = 'UPDATE' then

      hr_utility.trace('p_dp_mode :'||p_dp_mode);

      -- check for valid datatrack update modes
      Dt_Api.Find_DT_Upd_Modes
     (p_effective_date        => l_effective_date
     ,p_base_table_name       => 'PAY_CA_EMP_PROV_TAX_INFO_F'
     ,p_base_key_column       => 'EMP_PROVINCE_TAX_INF_ID'
     ,p_base_key_value        => l_pay_ca_provtax_rule_rec.EMP_PROVINCE_TAX_INF_ID
     ,p_correction            => l_dt_correction
     ,p_update                => l_dt_update
     ,p_update_override       => l_dt_upd_override
     ,p_update_change_insert  => l_upd_chg_ins
      );


       IF l_dt_update THEN

          l_datetrack_update_mode := 'UPDATE';
          hr_utility.trace('l_datetrack_update_mode :'||l_datetrack_update_mode);

       ELSIF l_dt_upd_override OR
          l_upd_chg_ins THEN
          -- Need to check if future dated record exists
          -- if yes then raise error
          -- NULL;
           hr_utility.set_message(801, 'HR_7211_DT_UPD_ROWS_IN_FUTURE');
           hr_utility.raise_error;
       ELSE
          l_datetrack_update_mode := 'CORRECTION';
          hr_utility.trace('l_datetrack_update_mode :'||l_datetrack_update_mode);
       END IF;

       ln_ovn := l_pay_ca_provtax_rule_rec.OBJECT_VERSION_NUMBER;

       PAY_CA_EMP_PRVTAX_INF_API.update_ca_emp_prvtax_inf
        (p_emp_province_tax_inf_id       => l_pay_ca_provtax_rule_rec.EMP_PROVINCE_TAX_INF_ID
        ,P_LEGISLATION_CODE                => l_pay_ca_provtax_rule_rec.LEGISLATION_CODE
        ,P_ASSIGNMENT_ID                   => l_pay_ca_provtax_rule_rec.ASSIGNMENT_ID
        ,P_PROVINCE_CODE                   => l_pay_ca_provtax_rule_rec.PROVINCE_CODE
        ,P_TAX_CREDIT_AMOUNT               => l_pay_ca_provtax_rule_rec.TAX_CREDIT_AMOUNT
        ,P_BASIC_EXEMPTION_FLAG            => l_pay_ca_provtax_rule_rec.BASIC_EXEMPTION_FLAG
        ,P_MARRIAGE_STATUS                 => l_pay_ca_provtax_rule_rec.MARRIAGE_STATUS
        ,P_NO_OF_INFIRM_DEPENDANTS         => l_pay_ca_provtax_rule_rec.NO_OF_INFIRM_DEPENDANTS
        ,P_NON_RESIDENT_STATUS             => l_pay_ca_provtax_rule_rec.NON_RESIDENT_STATUS
        ,P_DISABILITY_STATUS               => l_pay_ca_provtax_rule_rec.DISABILITY_STATUS
        ,P_NO_OF_DEPENDANTS                => l_pay_ca_provtax_rule_rec.NO_OF_DEPENDANTS
        ,P_ANNUAL_DEDN                     => l_pay_ca_provtax_rule_rec.ANNUAL_DEDN
        ,P_TOTAL_EXPENSE_BY_COMMISSION     => l_pay_ca_provtax_rule_rec.TOTAL_EXPENSE_BY_COMMISSION
        ,P_TOTAL_REMNRTN_BY_COMMISSION     => l_pay_ca_provtax_rule_rec.TOTAL_REMNRTN_BY_COMMISSION
        ,P_PRESCRIBED_ZONE_DEDN_AMT        => l_pay_ca_provtax_rule_rec.PRESCRIBED_ZONE_DEDN_AMT
        ,P_ADDITIONAL_TAX                  => l_pay_ca_provtax_rule_rec.ADDITIONAL_TAX
        ,P_PROV_OVERRIDE_RATE              => l_pay_ca_provtax_rule_rec.PROV_OVERRIDE_RATE
        ,P_PROV_OVERRIDE_AMOUNT            => l_pay_ca_provtax_rule_rec.PROV_OVERRIDE_AMOUNT
        ,P_PROV_EXEMPT_FLAG                => l_pay_ca_provtax_rule_rec.PROV_EXEMPT_FLAG
        ,P_PMED_EXEMPT_FLAG                => l_pay_ca_provtax_rule_rec.PMED_EXEMPT_FLAG
        ,P_WC_EXEMPT_FLAG                  => l_pay_ca_provtax_rule_rec.WC_EXEMPT_FLAG
        ,P_QPP_EXEMPT_FLAG                 => l_pay_ca_provtax_rule_rec.QPP_EXEMPT_FLAG
        ,P_EXTRA_INFO_NOT_PROVIDED         => l_pay_ca_provtax_rule_rec.EXTRA_INFO_NOT_PROVIDED
        ,P_OTHER_TAX_CREDIT                => l_pay_ca_provtax_rule_rec.OTHER_TAX_CREDIT
        ,P_CA_TAX_INFORMATION_CATEGORY     => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION_CATEGORY
        ,P_CA_TAX_INFORMATION1             => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION1
        ,P_CA_TAX_INFORMATION2             => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION2
        ,P_CA_TAX_INFORMATION3             => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION3
        ,P_CA_TAX_INFORMATION4             => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION4
        ,P_CA_TAX_INFORMATION5             => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION5
        ,P_CA_TAX_INFORMATION6             => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION6
        ,P_CA_TAX_INFORMATION7             => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION7
        ,P_CA_TAX_INFORMATION8             => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION8
        ,P_CA_TAX_INFORMATION9             => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION9
        ,P_CA_TAX_INFORMATION10            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION10
        ,P_CA_TAX_INFORMATION11            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION11
        ,P_CA_TAX_INFORMATION12            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION12
        ,P_CA_TAX_INFORMATION13            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION13
        ,P_CA_TAX_INFORMATION14            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION14
        ,P_CA_TAX_INFORMATION15            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION15
        ,P_CA_TAX_INFORMATION16            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION16
        ,P_CA_TAX_INFORMATION17            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION17
        ,P_CA_TAX_INFORMATION18            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION18
        ,P_CA_TAX_INFORMATION19            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION19
        ,P_CA_TAX_INFORMATION20            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION20
        ,P_CA_TAX_INFORMATION21            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION21
        ,P_CA_TAX_INFORMATION22            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION22
        ,P_CA_TAX_INFORMATION23            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION23
        ,P_CA_TAX_INFORMATION24            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION24
        ,P_CA_TAX_INFORMATION25            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION25
        ,P_CA_TAX_INFORMATION26            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION26
        ,P_CA_TAX_INFORMATION27            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION27
        ,P_CA_TAX_INFORMATION28            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION28
        ,P_CA_TAX_INFORMATION29            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION29
        ,P_CA_TAX_INFORMATION30            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION30
        ,P_PROV_LSP_AMOUNT                 => l_pay_ca_provtax_rule_rec.PROV_LSP_AMOUNT
        ,P_EFFECTIVE_DATE                  => l_effective_date
        ,P_DATETRACK_MODE 		   => l_datetrack_update_mode
	,p_effective_start_date            => ld_eff_start_date
        ,p_effective_end_date              => ld_eff_end_date
        ,p_object_version_number           => ln_ovn);

    hr_utility.trace('call to PAY_CA_EMP_PRVTAX_INF_API.update_ca_emp_prvtax_inf done');

   elsif p_dp_mode = 'INSERT' then

      hr_utility.trace('p_dp_mode :'||p_dp_mode);

      hr_utility.trace('Calling PAY_CA_EMP_PRVTAX_INF_API.create_ca_emp_prvtax_inf API ');
      PAY_CA_EMP_PRVTAX_INF_API.create_ca_emp_prvtax_inf(
       p_emp_province_tax_inf_id      => ln_ca_emp_prov_tax_inf_id
      ,P_LEGISLATION_CODE                => l_pay_ca_provtax_rule_rec.LEGISLATION_CODE
      ,p_business_group_id               => l_pay_ca_provtax_rule_rec.business_group_id
      ,P_ASSIGNMENT_ID                   => l_pay_ca_provtax_rule_rec.ASSIGNMENT_ID
      ,P_PROVINCE_CODE                   => l_pay_ca_provtax_rule_rec.PROVINCE_CODE
      ,P_TAX_CREDIT_AMOUNT               => l_pay_ca_provtax_rule_rec.TAX_CREDIT_AMOUNT
      ,P_BASIC_EXEMPTION_FLAG            => l_pay_ca_provtax_rule_rec.BASIC_EXEMPTION_FLAG
      ,P_EXTRA_INFO_NOT_PROVIDED         => l_pay_ca_provtax_rule_rec.EXTRA_INFO_NOT_PROVIDED
      ,P_OTHER_TAX_CREDIT                => l_pay_ca_provtax_rule_rec.OTHER_TAX_CREDIT
      ,P_MARRIAGE_STATUS                 => l_pay_ca_provtax_rule_rec.MARRIAGE_STATUS
      ,P_NO_OF_INFIRM_DEPENDANTS         => l_pay_ca_provtax_rule_rec.NO_OF_INFIRM_DEPENDANTS
      ,P_NON_RESIDENT_STATUS             => l_pay_ca_provtax_rule_rec.NON_RESIDENT_STATUS
      ,P_DISABILITY_STATUS               => l_pay_ca_provtax_rule_rec.DISABILITY_STATUS
      ,P_NO_OF_DEPENDANTS                => l_pay_ca_provtax_rule_rec.NO_OF_DEPENDANTS
      ,P_ANNUAL_DEDN                     => l_pay_ca_provtax_rule_rec.ANNUAL_DEDN
      ,P_TOTAL_EXPENSE_BY_COMMISSION     => l_pay_ca_provtax_rule_rec.TOTAL_EXPENSE_BY_COMMISSION
      ,P_TOTAL_REMNRTN_BY_COMMISSION     => l_pay_ca_provtax_rule_rec.TOTAL_REMNRTN_BY_COMMISSION
      ,P_PRESCRIBED_ZONE_DEDN_AMT        => l_pay_ca_provtax_rule_rec.PRESCRIBED_ZONE_DEDN_AMT
      ,P_ADDITIONAL_TAX                  => l_pay_ca_provtax_rule_rec.ADDITIONAL_TAX
      ,P_PROV_OVERRIDE_RATE              => l_pay_ca_provtax_rule_rec.PROV_OVERRIDE_RATE
      ,P_PROV_OVERRIDE_AMOUNT            => l_pay_ca_provtax_rule_rec.PROV_OVERRIDE_AMOUNT
      ,P_PROV_EXEMPT_FLAG                => l_pay_ca_provtax_rule_rec.PROV_EXEMPT_FLAG
      ,P_PMED_EXEMPT_FLAG                => l_pay_ca_provtax_rule_rec.PMED_EXEMPT_FLAG
      ,P_WC_EXEMPT_FLAG                  => l_pay_ca_provtax_rule_rec.WC_EXEMPT_FLAG
      ,P_QPP_EXEMPT_FLAG                 => l_pay_ca_provtax_rule_rec.QPP_EXEMPT_FLAG
      ,P_CA_TAX_INFORMATION_CATEGORY     => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION_CATEGORY
      ,P_CA_TAX_INFORMATION1             => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION1
      ,P_CA_TAX_INFORMATION2             => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION2
      ,P_CA_TAX_INFORMATION3             => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION3
      ,P_CA_TAX_INFORMATION4             => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION4
      ,P_CA_TAX_INFORMATION5             => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION5
      ,P_CA_TAX_INFORMATION6             => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION6
      ,P_CA_TAX_INFORMATION7             => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION7
      ,P_CA_TAX_INFORMATION8             => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION8
      ,P_CA_TAX_INFORMATION9             => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION9
      ,P_CA_TAX_INFORMATION10            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION10
      ,P_CA_TAX_INFORMATION11            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION11
      ,P_CA_TAX_INFORMATION12            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION12
      ,P_CA_TAX_INFORMATION13            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION13
      ,P_CA_TAX_INFORMATION14            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION14
      ,P_CA_TAX_INFORMATION15            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION15
      ,P_CA_TAX_INFORMATION16            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION16
      ,P_CA_TAX_INFORMATION17            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION17
      ,P_CA_TAX_INFORMATION18            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION18
      ,P_CA_TAX_INFORMATION19            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION19
      ,P_CA_TAX_INFORMATION20            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION20
      ,P_CA_TAX_INFORMATION21            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION21
      ,P_CA_TAX_INFORMATION22            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION22
      ,P_CA_TAX_INFORMATION23            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION23
      ,P_CA_TAX_INFORMATION24            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION24
      ,P_CA_TAX_INFORMATION25            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION25
      ,P_CA_TAX_INFORMATION26            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION26
      ,P_CA_TAX_INFORMATION27            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION27
      ,P_CA_TAX_INFORMATION28            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION28
      ,P_CA_TAX_INFORMATION29            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION29
      ,P_CA_TAX_INFORMATION30            => l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION30
      ,P_PROV_LSP_AMOUNT                 => l_pay_ca_provtax_rule_rec.PROV_LSP_AMOUNT
      ,P_EFFECTIVE_DATE                  => l_effective_date
      ,p_effective_start_date            => ld_eff_start_date
      ,p_effective_end_date            => ld_eff_end_date
      ,p_object_version_number         => ln_ovn);


       hr_utility.trace('call to PAY_CA_EMP_PRVTAX_INF_API.create_ca_emp_prvtax_inf done');
   end if; -- end if for p_dp_mode validation for Canada Provincial Tax


  end if; -- p_spreadsheet_identifier = 'PAYRICAPROVINCE'


end HR_DataPump;


procedure create_ac_emptaxrule
(
  p_business_group                 IN      number    default hr_api.g_number
  ,p_effective_date                 IN      date      default hr_api.g_date
  ,p_employee                       IN      varchar2  default hr_api.g_varchar2
  ,p_assignment                     IN      varchar2  default hr_api.g_varchar2
  ,p_legislation                    IN      varchar2  default hr_api.g_varchar2
  ,p_spreadsheet_identifier         IN      varchar2  default hr_api.g_varchar2
  ,p_sui_state                      IN      varchar2  default hr_api.g_varchar2
  ,p_state_prov_code                IN      varchar2  default hr_api.g_varchar2
  ,p_county                         IN      varchar2  default hr_api.g_varchar2
  ,p_city                           IN      varchar2  default hr_api.g_varchar2
  ,p_override_prov_of_emplt         IN      varchar2  default hr_api.g_varchar2
  ,p_basic_amt_flag                 IN      varchar2  default hr_api.g_varchar2
  ,p_basic_amt                      IN      number    default hr_api.g_number
  ,p_tax_credit                     IN      number    default hr_api.g_number
  ,p_filing_status_code             IN      varchar2  default hr_api.g_varchar2
  ,p_allowances                     IN      number    default hr_api.g_number
  ,p_additional_tax                 IN      number    default hr_api.g_number
  ,p_secondary_allowances           IN      number    default hr_api.g_number
  ,p_exemption_amt                  IN      number    default hr_api.g_number
  ,p_sit_optional_calc_ind          IN      varchar2  default hr_api.g_varchar2
  ,p_addtl_allowance_rate           IN      number    default hr_api.g_number
  ,p_pres_zone_dedn                 IN      number    default hr_api.g_number
  ,p_tax_exempt1                    IN      varchar2  default hr_api.g_varchar2
  ,p_tax_exempt2                    IN      varchar2  default hr_api.g_varchar2
  ,p_tax_exempt3                    IN      varchar2  default hr_api.g_varchar2
  ,p_tax_exempt4                    IN      varchar2  default hr_api.g_varchar2
  ,p_override_rate                  IN      number    default hr_api.g_number
  ,p_override_amount                IN      number    default hr_api.g_number
  ,p_override_supp_rate             IN      number    default hr_api.g_number
  ,p_annual_dedn                    IN      number    default hr_api.g_number
  ,p_labor_fund_contr               IN      number    default hr_api.g_number
  ,p_allowance_reject_date          IN      date      default hr_api.g_date
  ,p_eic_filing_status              IN      varchar2  default hr_api.g_varchar2
  ,p_statutory_employee             IN      varchar2  default hr_api.g_varchar2
  ,p_cumulative_taxation            IN      varchar2  default hr_api.g_varchar2
  ,p_non_resident                   IN      varchar2  default hr_api.g_varchar2
  ,p_sui_base_override_amount       IN      number    default hr_api.g_number
  ,p_school_district                IN      varchar2  default hr_api.g_varchar2
  ,p_comm_renumeration              IN      number    default hr_api.g_number
  ,p_comm_expenses                  IN      number    default hr_api.g_number
  ,p_spouse_or_equivalent           IN      varchar2  default hr_api.g_varchar2
  ,p_disability_status              IN      varchar2  default hr_api.g_varchar2
  ,p_number_of_dependents           IN      number    default hr_api.g_number
  ,p_number_of_infirm_dependents    IN      number    default hr_api.g_number
  ,p_sta_information_category       in     varchar2  default hr_api.g_varchar2
  ,p_sta_information1               in     varchar2  default hr_api.g_varchar2
  ,p_sta_information2               in     varchar2  default hr_api.g_varchar2
  ,p_sta_information3               in     varchar2  default hr_api.g_varchar2
  ,p_sta_information4               in     varchar2  default hr_api.g_varchar2
  ,p_sta_information5               in     varchar2  default hr_api.g_varchar2
  ,p_sta_information6               in     varchar2  default hr_api.g_varchar2
  ,p_sta_information7               in     varchar2  default hr_api.g_varchar2
  ,p_sta_information8               in     varchar2  default hr_api.g_varchar2
  ,p_sta_information9               in     varchar2  default hr_api.g_varchar2
  ,p_sta_information10              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information11              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information12              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information13              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information14              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information15              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information16              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information17              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information18              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information19              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information20              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information21              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information22              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information23              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information24              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information25              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information26              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information27              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information28              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information29              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information30              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information_category       in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information1               in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information2               in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information3               in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information4               in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information5               in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information6               in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information7               in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information8               in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information9               in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information10              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information11              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information12              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information13              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information14              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information15              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information16              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information17              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information18              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information19              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information20              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information21              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information22              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information23              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information24              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information25              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information26              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information27              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information28              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information29              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information30              in     varchar2  default hr_api.g_varchar2
  ,p_additional_info1                in     varchar2  default hr_api.g_varchar2
  ,p_additional_info2                in     varchar2  default hr_api.g_varchar2
  ,p_additional_info3                in     varchar2  default hr_api.g_varchar2
  ,p_additional_info4                in     varchar2  default hr_api.g_varchar2
  ,p_additional_info5                in     varchar2  default hr_api.g_varchar2
  ,p_additional_info6                in     number  default hr_api.g_number
  ,p_additional_info7                in     number  default hr_api.g_number
  ,p_additional_info8                in     number  default hr_api.g_number
  ,p_additional_info9                in     number  default hr_api.g_number
  ,p_additional_info10               in     number  default hr_api.g_number
   ) is

 ln_fedtax_rule_id          pay_us_emp_fed_tax_rules_f.EMP_FED_TAX_RULE_ID%TYPE;
 ln_statetax_rule_id        pay_us_emp_state_tax_rules_f.EMP_state_TAX_RULE_ID%TYPE;
 ln_countytax_rule_id       pay_us_emp_county_tax_rules_f.EMP_county_TAX_RULE_ID%TYPE;
 ln_citytax_rule_id         pay_us_emp_city_tax_rules_f.EMP_city_TAX_RULE_ID%TYPE;
 ln_cafedtax_inf_id         PAY_CA_EMP_FED_TAX_INFO_F.EMP_FED_TAX_INF_ID%TYPE;
 ln_caprovtax_inf_id        PAY_CA_EMP_PROV_TAX_INFO_F.EMP_PROVINCE_TAX_INF_ID%TYPE;

 ln_assignment_id           per_all_assignments_f.assignment_id%TYPE;
 ln_batch_exists            number;
 lv_lookup_code             varchar2(20);

 -- Added for datapump wrapper
 ln_ovn2                    number;
 lv_county_code             varchar2(10);
 lv_city_code               varchar2(10);
 lv_county_school_distcode  varchar2(10);
 lv_city_school_distcode  varchar2(10);


  /* US Employee Federal Tax Rule record */
  CURSOR csr_get_fedtax_id(cp_asg_id number) is
  select ftr.EMP_FED_TAX_RULE_ID,ftr.object_version_number
  from pay_us_emp_fed_tax_rules_f ftr
  where ftr.assignment_id = cp_asg_id
  and p_effective_date between ftr.effective_start_date and ftr.effective_end_date
  and ftr.business_group_id = p_business_group;


  /* US Employee State Tax Rule record */
  CURSOR csr_get_statetax_id(cp_asg_id number) is
  select str.EMP_STATE_TAX_RULE_ID,str.object_version_number
  from PAY_US_EMP_STATE_TAX_RULES_F str
  where str.assignment_id = cp_asg_id
  and p_effective_date between str.effective_start_date and str.effective_end_date
  and str.business_group_id =  p_business_group
  and str.state_code = ltrim(rtrim(p_state_prov_code));


  /* US Employee County Tax Rule record */
  CURSOR csr_get_countytax_id(cp_asg_id number,cp_county_code varchar2) is
  select ctr.EMP_COUNTY_TAX_RULE_ID,ctr.object_version_number
  from PAY_US_EMP_COUNTY_TAX_RULES_F ctr
  where ctr.assignment_id = cp_asg_id
  and p_effective_date between ctr.effective_start_date and ctr.effective_end_date
  and ctr.business_group_id =  p_business_group
  and ctr.state_code = ltrim(rtrim(p_state_prov_code))
  and ctr.county_code = ltrim(rtrim(cp_county_code));

  /* US County code cursor */
  CURSOR csr_get_county_code is
  select county_code
  from pay_us_counties
  where state_code = ltrim(rtrim(p_state_prov_code))
  and county_name = ltrim(rtrim(p_county));

  /* US County School district code */
  CURSOR csr_get_county_school_distcode(cp_county_code varchar2) is
  select school_dst_code
  from pay_us_county_school_dsts
  where state_code = ltrim(rtrim(p_state_prov_code))
  and county_code = cp_county_code
  and school_dst_name = ltrim(rtrim(P_SCHOOL_DISTRICT));

  /* US Employee City Tax Rule record */
  CURSOR csr_get_citytax_id(cp_asg_id number,
                            cp_county_code varchar2,
                            cp_city_code varchar2) is
  select ctr.EMP_CITY_TAX_RULE_ID,ctr.object_version_number
  from PAY_US_EMP_CITY_TAX_RULES_F ctr
  where ctr.assignment_id = cp_asg_id
  and ctr.business_group_id =  p_business_group
  and p_effective_date between ctr.effective_start_date and ctr.effective_end_date
  and ctr.state_code = ltrim(rtrim(p_state_prov_code))
  and ctr.county_code = ltrim(rtrim(cp_county_code))
  and ctr.city_code = ltrim(rtrim(cp_city_code));

  /* Get US City code */
  CURSOR csr_get_city_code(cp_county_code varchar2) is
  select city_code
  from pay_us_city_names
  where state_code = ltrim(rtrim(p_state_prov_code))
  and county_code = ltrim(rtrim(cp_county_code))
  and city_name = ltrim(rtrim(p_city));

  /* Get US City School District code */
  CURSOR csr_get_city_school_distcode(cp_county_code varchar2,
                                      cp_city_code varchar2) is

  select SCHOOL_DST_CODE
  from PAY_US_CITY_SCHOOL_DSTS
  where state_code = ltrim(rtrim(p_state_prov_code))
  and county_code = cp_county_code
  and city_code = cp_city_code
  and SCHOOL_DST_NAME = ltrim(rtrim(P_SCHOOL_DISTRICT));

  /* cursor to get the assignment_id */
  CURSOR csr_get_asg_id is
  select paf.assignment_id
  from per_all_assignments_f paf,
       per_all_people_f ppf
  where ppf.full_name = p_employee
  and ppf.person_id = paf.person_id
  and ppf.business_group_id = p_business_group
  and p_effective_date between ppf.effective_start_date and ppf.effective_end_date
  and paf.assignment_number = p_assignment
  and p_effective_date between paf.effective_start_date and paf.effective_end_date
  and paf.business_group_id =  p_business_group;

  /* Get lookup code */
  CURSOR c_get_lookup_code(cp_lookup_type varchar2,
                           cp_meaning varchar2) IS
  select lookup_code
  from hr_lookups
  where lookup_type = cp_lookup_type
  and meaning = cp_meaning;

  /* Check Canada Federal Tax Record */
  CURSOR csr_get_cafedtax_id(cp_asg_id number) is
  select ftr.EMP_FED_TAX_INF_ID,ftr.object_version_number
  from PAY_CA_EMP_FED_TAX_INFO_F ftr
  where ftr.assignment_id = cp_asg_id
  and p_effective_date between ftr.effective_start_date and ftr.effective_end_date
  and ftr.business_group_id =  p_business_group;


  /* Check Canada Provincial Tax Record */
  CURSOR csr_get_caprovtax_id(cp_asg_id number) is
  select pti.EMP_PROVINCE_TAX_INF_ID,pti.object_version_number
  from PAY_CA_EMP_PROV_TAX_INFO_F pti
  where pti.assignment_id = cp_asg_id
  and p_effective_date between pti.effective_start_date and pti.effective_end_date
  and pti.business_group_id =  p_business_group
  and pti.province_code = ltrim(rtrim(p_state_prov_code));


begin
  g_employee := p_employee;
  g_assignment := p_assignment;


  /*hr_utility.trace_on(null,'TESTTAX');*/

  hr_utility.trace('p_business_group :'||to_char(p_business_group));
  hr_utility.trace('p_effective_date :'||to_char(p_effective_date,'YYYY/MM/DD'));
  hr_utility.trace('p_employee :'||to_char(p_employee));
  hr_utility.trace('p_assignment :'||to_char(p_assignment));
  hr_utility.trace('p_legislation :'||p_legislation);
  hr_utility.trace('p_spreadsheet_identifier :'||p_spreadsheet_identifier);
  hr_utility.trace('p_sui_state :'||p_sui_state);
  hr_utility.trace('p_state_prov_code :'||p_state_prov_code);
  hr_utility.trace('p_county :'||p_county);
  hr_utility.trace('p_city :'||p_city);
  hr_utility.trace('p_override_prov_of_emplt :'||p_override_prov_of_emplt);
  hr_utility.trace('p_basic_amt_flag :'||p_basic_amt_flag);
  hr_utility.trace('p_basic_amt :'||to_char(p_basic_amt));
  hr_utility.trace('p_tax_credit :'||to_char(p_tax_credit));
  hr_utility.trace('p_filing_status_code :'||p_filing_status_code);
  hr_utility.trace('p_allowances :'||to_char(p_allowances));
  hr_utility.trace('p_additional_tax :'||to_char(p_additional_tax));
  hr_utility.trace('p_secondary_allowances :'||to_char(p_secondary_allowances));
  hr_utility.trace('p_exemption_amt :'||to_char(p_exemption_amt));
  hr_utility.trace('p_sit_optional_calc_ind :'||p_sit_optional_calc_ind);
  hr_utility.trace('p_addtl_allowance_rate :'||to_char(p_addtl_allowance_rate));
  hr_utility.trace('p_pres_zone_dedn :'||to_char(p_pres_zone_dedn));
  hr_utility.trace('p_tax_exempt1 :'||p_tax_exempt1);
  hr_utility.trace('p_tax_exempt2 :'||p_tax_exempt2);
  hr_utility.trace('p_tax_exempt3 :'||p_tax_exempt3);
  hr_utility.trace('p_tax_exempt4 :'||p_tax_exempt4);
  hr_utility.trace('p_override_rate :'||to_char(p_override_rate));
  hr_utility.trace('p_override_amount :'||to_char(p_override_amount));
  hr_utility.trace('p_override_supp_rate :'||to_char(p_override_supp_rate));
  hr_utility.trace('p_annual_dedn :'||to_char(p_annual_dedn));
  hr_utility.trace('p_labor_fund_contr :'||to_char(p_labor_fund_contr));
  hr_utility.trace('p_allowance_reject_date :'||to_char(p_allowance_reject_date,'YYYY/MM/DD'));
  hr_utility.trace('p_eic_filing_status :'||p_eic_filing_status);
  hr_utility.trace('p_statutory_employee :'||p_statutory_employee);
  hr_utility.trace('p_statutory_employee :'||to_char(p_annual_dedn));
  hr_utility.trace('p_cumulative_taxation :'||p_cumulative_taxation);
  hr_utility.trace('p_non_resident :'||p_non_resident);
  hr_utility.trace('p_sui_base_override_amount :'||to_char(p_sui_base_override_amount));
  hr_utility.trace('p_school_district :'||p_school_district);
  hr_utility.trace('p_comm_renumeration :'||to_char(p_comm_renumeration));
  hr_utility.trace('p_comm_expenses :'||to_char(p_comm_expenses));
  hr_utility.trace('p_spouse_or_equivalent :'||p_spouse_or_equivalent);
  hr_utility.trace('p_disability_status :'||p_disability_status);
  hr_utility.trace('p_number_of_dependents :'||to_char(p_number_of_dependents));
  hr_utility.trace('p_number_of_infirm_dependents :'||to_char(p_number_of_infirm_dependents));
  hr_utility.trace('sta_information_category :'||p_sta_information_category);
  hr_utility.trace('sta_information1 :'||p_sta_information1);
  hr_utility.trace('sta_information2 :'||p_sta_information2);
  hr_utility.trace('sta_information3 :'||p_sta_information3);
  hr_utility.trace('sta_information4 :'||p_sta_information4);
  hr_utility.trace('sta_information5 :'||p_sta_information5);
  hr_utility.trace('sta_information6 :'||p_sta_information6);
  hr_utility.trace('sta_information7 :'||p_sta_information7);
  hr_utility.trace('sta_information8 :'||p_sta_information8);
  hr_utility.trace('sta_information9 :'||p_sta_information9);
  hr_utility.trace('sta_information10 :'||p_sta_information10);
  hr_utility.trace('sta_information11 :'||p_sta_information11);
  hr_utility.trace('sta_information12 :'||p_sta_information12);
  hr_utility.trace('sta_information13 :'||p_sta_information13);
  hr_utility.trace('sta_information14 :'||p_sta_information14);
  hr_utility.trace('sta_information15 :'||p_sta_information15);
  hr_utility.trace('sta_information16 :'||p_sta_information16);
  hr_utility.trace('sta_information17 :'||p_sta_information17);
  hr_utility.trace('sta_information18 :'||p_sta_information18);
  hr_utility.trace('sta_information19 :'||p_sta_information19);
  hr_utility.trace('sta_information20 :'||p_sta_information20);
  hr_utility.trace('sta_information21 :'||p_sta_information21);
  hr_utility.trace('sta_information22 :'||p_sta_information22);
  hr_utility.trace('sta_information23 :'||p_sta_information23);
  hr_utility.trace('sta_information24 :'||p_sta_information24);
  hr_utility.trace('sta_information25 :'||p_sta_information25);
  hr_utility.trace('sta_information26 :'||p_sta_information26);
  hr_utility.trace('sta_information27 :'||p_sta_information27);
  hr_utility.trace('sta_information28 :'||p_sta_information28);
  hr_utility.trace('sta_information29 :'||p_sta_information29);
  hr_utility.trace('sta_information30 :'||p_sta_information30);

  open csr_get_asg_id;
  fetch csr_get_asg_id into ln_assignment_id;
  close csr_get_asg_id;
  hr_utility.trace('Assignment_id :'||to_char(ln_assignment_id));


  -- ========================================================================
  -- US Federal Tax Rule Information
  -- ========================================================================

  if P_SPREADSHEET_IDENTIFIER = 'PAYRIUSFED' then

    l_pay_us_fedtax_rule_rec.sui_state_code              := p_sui_state;
    l_pay_us_fedtax_rule_rec.FILING_STATUS_CODE          := p_filing_status_code;
    l_pay_us_fedtax_rule_rec.FIT_OVERRIDE_AMOUNT         := NVL(p_override_amount,0);
    l_pay_us_fedtax_rule_rec.FIT_OVERRIDE_RATE           := NVL(p_override_rate,0);
    l_pay_us_fedtax_rule_rec.WITHHOLDING_ALLOWANCES      := p_allowances;
    l_pay_us_fedtax_rule_rec.CUMULATIVE_TAXATION         := p_cumulative_taxation;
    l_pay_us_fedtax_rule_rec.EIC_FILING_STATUS_CODE      := p_eic_filing_status;
    l_pay_us_fedtax_rule_rec.FIT_ADDITIONAL_TAX          := NVL(p_additional_tax,0);
    l_pay_us_fedtax_rule_rec.FIT_EXEMPT                  := P_TAX_EXEMPT1;
    l_pay_us_fedtax_rule_rec.FUTA_TAX_EXEMPT             := P_TAX_EXEMPT2;
    l_pay_us_fedtax_rule_rec.MEDICARE_TAX_EXEMPT         := P_TAX_EXEMPT3;
    l_pay_us_fedtax_rule_rec.SS_TAX_EXEMPT               := P_TAX_EXEMPT4;
    l_pay_us_fedtax_rule_rec.STATUTORY_EMPLOYEE          := P_STATUTORY_EMPLOYEE ;
    l_pay_us_fedtax_rule_rec.SUPP_TAX_OVERRIDE_RATE      := NVL(P_OVERRIDE_SUPP_RATE,0);
    l_pay_us_fedtax_rule_rec.EXCESSIVE_WA_REJECT_DATE    := P_ALLOWANCE_REJECT_DATE;

    open csr_get_fedtax_id(ln_assignment_id);
    fetch csr_get_fedtax_id into ln_fedtax_rule_id,ln_ovn2;
    hr_utility.trace('emp_fed_tax_rule_id :'||to_char(ln_fedtax_rule_id));
    hr_utility.trace('object_version_number :'||to_char(ln_ovn2));

    if csr_get_fedtax_id%FOUND then
       l_pay_us_fedtax_rule_rec.EMP_FED_TAX_RULE_ID         := ln_fedtax_rule_id;
       l_pay_us_fedtax_rule_rec.OBJECT_VERSION_NUMBER       := ln_ovn2;
       close csr_get_fedtax_id;

       HR_DataPump( p_dp_mode                 => 'CORRECTION'
                   ,p_effective_date          => p_effective_date
                   ,p_spreadsheet_identifier  => p_spreadsheet_identifier
                  );
    end if;

    -- end of p_spreadsheet_identifier = 'PAYRIUSFED'

  -- ========================================================================
  -- US State Tax Rule Information
  -- ========================================================================

  elsif P_SPREADSHEET_IDENTIFIER = 'PAYRIUSSTATE' then

    open c_get_lookup_code('US_FS_'||P_STATE_PROV_CODE,p_filing_status_code);
    fetch c_get_lookup_code into lv_lookup_code;
    close c_get_lookup_code;

    -- Fix for bug#4526310
    lv_lookup_code := '0'||lv_lookup_code;

    hr_utility.trace('Filing Status Code :'||lv_lookup_code);
    l_pay_us_statetax_rule_rec := null;

    l_pay_us_statetax_rule_rec.state_code                  := P_STATE_PROV_CODE;
    l_pay_us_statetax_rule_rec.FILING_STATUS_CODE          := lv_lookup_code;
    l_pay_us_statetax_rule_rec.SECONDARY_WA                := P_SECONDARY_ALLOWANCES;
    l_pay_us_statetax_rule_rec.SIT_OVERRIDE_AMOUNT         := NVL(p_override_amount,0);
    l_pay_us_statetax_rule_rec.SIT_OVERRIDE_RATE           := NVL(p_override_rate,0);
    l_pay_us_statetax_rule_rec.WITHHOLDING_ALLOWANCES      := p_allowances;
    l_pay_us_statetax_rule_rec.SIT_ADDITIONAL_TAX          := NVL(p_additional_tax,0);
    l_pay_us_statetax_rule_rec.SIT_EXEMPT                  := P_TAX_EXEMPT1;
    l_pay_us_statetax_rule_rec.SDI_EXEMPT                  := P_TAX_EXEMPT2;
    l_pay_us_statetax_rule_rec.SUI_EXEMPT                  := P_TAX_EXEMPT3;
    l_pay_us_statetax_rule_rec.WC_EXEMPT                   := P_TAX_EXEMPT4;
    l_pay_us_statetax_rule_rec.SIT_OPTIONAL_CALC_IND       := P_SIT_OPTIONAL_CALC_IND;
    l_pay_us_statetax_rule_rec.STATE_NON_RESIDENT_CERT     := P_NON_RESIDENT;
    l_pay_us_statetax_rule_rec.SUI_WAGE_BASE_OVERRIDE_AMOUNT := P_SUI_BASE_OVERRIDE_AMOUNT;
    l_pay_us_statetax_rule_rec.SUPP_TAX_OVERRIDE_RATE      := NVL(P_OVERRIDE_SUPP_RATE,0);
    l_pay_us_statetax_rule_rec.EXCESSIVE_WA_REJECT_DATE    := P_ALLOWANCE_REJECT_DATE;
    l_pay_us_statetax_rule_rec.ADDITIONAL_WA_AMOUNT        := NVL(P_EXEMPTION_AMT,0);
    l_pay_us_statetax_rule_rec.ASSIGNMENT_ID               := ln_assignment_id;
    l_pay_us_statetax_rule_rec.STA_INFORMATION_CATEGORY    := p_sta_information_category;
    l_pay_us_statetax_rule_rec.STA_INFORMATION1            := p_sta_information1;
    l_pay_us_statetax_rule_rec.STA_INFORMATION2            := p_sta_information2;
    l_pay_us_statetax_rule_rec.STA_INFORMATION3            := p_sta_information3;
    l_pay_us_statetax_rule_rec.STA_INFORMATION4            := p_sta_information4;
    l_pay_us_statetax_rule_rec.STA_INFORMATION5            := p_sta_information5;
    l_pay_us_statetax_rule_rec.STA_INFORMATION6            := p_sta_information6;
    l_pay_us_statetax_rule_rec.STA_INFORMATION7            := p_sta_information7;
    l_pay_us_statetax_rule_rec.STA_INFORMATION8            := p_sta_information8;
    l_pay_us_statetax_rule_rec.STA_INFORMATION9            := p_sta_information9;
    l_pay_us_statetax_rule_rec.STA_INFORMATION10            := p_sta_information10;
    l_pay_us_statetax_rule_rec.STA_INFORMATION11            := p_sta_information11;
    l_pay_us_statetax_rule_rec.STA_INFORMATION12           := p_sta_information12;
    l_pay_us_statetax_rule_rec.STA_INFORMATION13            := p_sta_information13;
    l_pay_us_statetax_rule_rec.STA_INFORMATION14            := p_sta_information14;
    l_pay_us_statetax_rule_rec.STA_INFORMATION15            := p_sta_information15;
    l_pay_us_statetax_rule_rec.STA_INFORMATION16            := p_sta_information16;
    l_pay_us_statetax_rule_rec.STA_INFORMATION17            := p_sta_information17;
    l_pay_us_statetax_rule_rec.STA_INFORMATION18            := p_sta_information18;
    l_pay_us_statetax_rule_rec.STA_INFORMATION19            := p_sta_information19;
    l_pay_us_statetax_rule_rec.STA_INFORMATION20            := p_sta_information20;
    l_pay_us_statetax_rule_rec.STA_INFORMATION21            := p_sta_information21;
    l_pay_us_statetax_rule_rec.STA_INFORMATION22            := p_sta_information22;
    l_pay_us_statetax_rule_rec.STA_INFORMATION23            := p_sta_information23;
    l_pay_us_statetax_rule_rec.STA_INFORMATION24            := p_sta_information24;
    l_pay_us_statetax_rule_rec.STA_INFORMATION25            := p_sta_information25;
    l_pay_us_statetax_rule_rec.STA_INFORMATION26            := p_sta_information26;
    l_pay_us_statetax_rule_rec.STA_INFORMATION27            := p_sta_information27;
    l_pay_us_statetax_rule_rec.STA_INFORMATION28            := p_sta_information28;
    l_pay_us_statetax_rule_rec.STA_INFORMATION29            := p_sta_information29;
    l_pay_us_statetax_rule_rec.STA_INFORMATION30            := p_sta_information30;


    open csr_get_statetax_id(ln_assignment_id);
    fetch csr_get_statetax_id into ln_statetax_rule_id,ln_ovn2;
    hr_utility.trace('emp_state_tax_rule_id :'||to_char(ln_statetax_rule_id));
    hr_utility.trace('object_version_number :'||to_char(ln_ovn2));

    if csr_get_statetax_id%FOUND then
       l_pay_us_statetax_rule_rec.EMP_STATE_TAX_RULE_ID    := ln_statetax_rule_id;
       l_pay_us_statetax_rule_rec.OBJECT_VERSION_NUMBER    := ln_ovn2;

       close csr_get_statetax_id;
       HR_DataPump( p_dp_mode                 => 'UPDATE'
                   ,p_effective_date          => p_effective_date
                   ,p_spreadsheet_identifier  => p_spreadsheet_identifier
                  );
    else
       l_pay_us_statetax_rule_rec.ASSIGNMENT_ID := ln_assignment_id;

       close csr_get_statetax_id;
       HR_DataPump( p_dp_mode                 => 'INSERT'
                   ,p_effective_date          => p_effective_date
                   ,p_spreadsheet_identifier  => p_spreadsheet_identifier
                  );
    end if;

    -- end of p_spreadsheet_identifier = 'PAYRIUSSTATE'

  -- ========================================================================
  -- US County Tax Rule Information
  -- ========================================================================

  elsif p_spreadsheet_identifier = 'PAYRIUSCOUNTY' then

    l_pay_us_countytax_rule_rec.state_code                  := P_STATE_PROV_CODE;
    l_pay_us_countytax_rule_rec.FILING_STATUS_CODE          := p_filing_status_code;
    l_pay_us_countytax_rule_rec.ADDITIONAL_WA_RATE          := NVL(P_ADDTL_ALLOWANCE_RATE,0);
    l_pay_us_countytax_rule_rec.LIT_OVERRIDE_AMOUNT         := NVL(p_override_amount,0);
    l_pay_us_countytax_rule_rec.LIT_OVERRIDE_RATE           := NVL(p_override_rate,0);
    l_pay_us_countytax_rule_rec.WITHHOLDING_ALLOWANCES      := p_allowances;
    l_pay_us_countytax_rule_rec.LIT_ADDITIONAL_TAX          := NVL(p_additional_tax,0);
    l_pay_us_countytax_rule_rec.LIT_EXEMPT                  := P_TAX_EXEMPT1;
    l_pay_us_countytax_rule_rec.SD_EXEMPT                   := P_TAX_EXEMPT2;
    l_pay_us_countytax_rule_rec.HT_EXEMPT                   := P_TAX_EXEMPT3;
    l_pay_us_countytax_rule_rec.ASSIGNMENT_ID               := ln_assignment_id;


    open csr_get_county_code;
    fetch csr_get_county_code into lv_county_code;
    close csr_get_county_code;

    if P_SCHOOL_DISTRICT is not null then
      open csr_get_county_school_distcode(lv_county_code);
      fetch csr_get_county_school_distcode into lv_county_school_distcode;
      close csr_get_county_school_distcode;
    end if;

    l_pay_us_countytax_rule_rec.SCHOOL_DISTRICT_CODE        := lv_county_school_distcode;
    l_pay_us_countytax_rule_rec.county_code                 := lv_county_code;

    open csr_get_countytax_id(ln_assignment_id,lv_county_code);
    fetch csr_get_countytax_id into ln_countytax_rule_id,ln_ovn2;
    hr_utility.trace('emp_county_tax_rule_id :'||to_char(ln_countytax_rule_id));
    hr_utility.trace('object_version_number :'||to_char(ln_ovn2));

    if csr_get_countytax_id%FOUND then
       l_pay_us_countytax_rule_rec.EMP_COUNTY_TAX_RULE_ID    := ln_countytax_rule_id;
       l_pay_us_countytax_rule_rec.OBJECT_VERSION_NUMBER    := ln_ovn2;

       close csr_get_countytax_id;
       HR_DataPump(
                   p_dp_mode                 => 'UPDATE'
                   ,p_effective_date          => p_effective_date
                   ,p_spreadsheet_identifier  => p_spreadsheet_identifier
                  );
    else
       l_pay_us_countytax_rule_rec.ASSIGNMENT_ID := ln_assignment_id;

       close csr_get_countytax_id;
       HR_DataPump(
                   p_dp_mode                 => 'INSERT'
                   ,p_effective_date          => p_effective_date
                   ,p_spreadsheet_identifier  => p_spreadsheet_identifier
                  );
    end if;
    -- end of p_spreadsheet_identifier = 'PAYRIUSCOUNTY'

  -- ========================================================================
  -- US City Tax Rule Information
  -- ========================================================================

  elsif p_spreadsheet_identifier = 'PAYRIUSCITY' then

    l_pay_us_citytax_rule_rec.state_code                  := P_STATE_PROV_CODE;
    l_pay_us_citytax_rule_rec.FILING_STATUS_CODE          := p_filing_status_code;
    l_pay_us_citytax_rule_rec.ADDITIONAL_WA_RATE          := NVL(P_ADDTL_ALLOWANCE_RATE,0);
    l_pay_us_citytax_rule_rec.LIT_OVERRIDE_AMOUNT         := NVL(p_override_amount,0);
    l_pay_us_citytax_rule_rec.LIT_OVERRIDE_RATE           := NVL(p_override_rate,0);
    l_pay_us_citytax_rule_rec.WITHHOLDING_ALLOWANCES      := p_allowances;
    l_pay_us_citytax_rule_rec.LIT_ADDITIONAL_TAX          := NVL(p_additional_tax,0);
    l_pay_us_citytax_rule_rec.LIT_EXEMPT                  := P_TAX_EXEMPT1;
    l_pay_us_citytax_rule_rec.SD_EXEMPT                   := P_TAX_EXEMPT2;
    l_pay_us_citytax_rule_rec.HT_EXEMPT                   := P_TAX_EXEMPT3;
    l_pay_us_citytax_rule_rec.ASSIGNMENT_ID               := ln_assignment_id;

    open csr_get_county_code;
    fetch csr_get_county_code into lv_county_code;
    close csr_get_county_code;

    open csr_get_city_code(lv_county_code);
    fetch csr_get_city_code into lv_city_code;
    close csr_get_city_code;

    if ltrim(rtrim(P_SCHOOL_DISTRICT)) is not null then
      open csr_get_city_school_distcode(lv_county_code,lv_city_code);
      fetch csr_get_city_school_distcode into lv_city_school_distcode;
      close csr_get_city_school_distcode;
    end if;

    l_pay_us_citytax_rule_rec.county_code                 := lv_county_code;
    l_pay_us_citytax_rule_rec.CITY_CODE                   := lv_city_code;
    l_pay_us_citytax_rule_rec.SCHOOL_DISTRICT_CODE        := lv_city_school_distcode;

    open csr_get_citytax_id(ln_assignment_id,lv_county_code,lv_city_code);
    fetch csr_get_citytax_id into ln_citytax_rule_id,ln_ovn2;
    hr_utility.trace('emp_city_tax_rule_id :'||to_char(ln_citytax_rule_id));
    hr_utility.trace('object_version_number :'||to_char(ln_ovn2));

    if csr_get_citytax_id%FOUND then
       l_pay_us_citytax_rule_rec.EMP_CITY_TAX_RULE_ID    := ln_citytax_rule_id;
       l_pay_us_citytax_rule_rec.OBJECT_VERSION_NUMBER        := ln_ovn2;

       close csr_get_citytax_id;
       HR_DataPump(
                   p_dp_mode                 => 'UPDATE'
                   ,p_effective_date          => p_effective_date
                   ,p_spreadsheet_identifier  => p_spreadsheet_identifier
                  );
    else
       l_pay_us_citytax_rule_rec.ASSIGNMENT_ID := ln_assignment_id;

       close csr_get_citytax_id;
       HR_DataPump(
                   p_dp_mode                 => 'INSERT'
                   ,p_effective_date          => p_effective_date
                   ,p_spreadsheet_identifier  => p_spreadsheet_identifier
                  );
    end if;
    -- end of p_spreadsheet_identifier = 'PAYRIUSCITY'


  elsif P_SPREADSHEET_IDENTIFIER = 'PAYRICAFED' then

       if P_BASIC_AMT_FLAG = 'Y' and P_TAX_CREDIT is NOT NULL then
          hr_utility.set_message(800, 'HR_74007_BOTH_NOT_NULL');
          hr_utility.raise_error;
       elsif (P_BASIC_AMT_FLAG = 'N' and P_TAX_CREDIT is null) then
           l_pay_ca_fedtax_rule_rec.TAX_CREDIT_AMOUNT := 0;
       elsif (P_BASIC_AMT_FLAG = 'N' and P_TAX_CREDIT is Not null) then
           l_pay_ca_fedtax_rule_rec.TAX_CREDIT_AMOUNT := P_TAX_CREDIT;
       else
           l_pay_ca_fedtax_rule_rec.TAX_CREDIT_AMOUNT := P_TAX_CREDIT;
       end if;


    l_pay_ca_fedtax_rule_rec.LEGISLATION_CODE         := 'CA';
    l_pay_ca_fedtax_rule_rec.business_group_id        := p_business_group;
    l_pay_ca_fedtax_rule_rec.EMPLOYMENT_PROVINCE         := p_override_prov_of_emplt;
    l_pay_ca_fedtax_rule_rec.BASIC_EXEMPTION_FLAG        := P_BASIC_AMT_FLAG;
    l_pay_ca_fedtax_rule_rec.ADDITIONAL_TAX              := P_ADDITIONAL_TAX;
    l_pay_ca_fedtax_rule_rec.ANNUAL_DEDN                 := P_ANNUAL_DEDN;
    l_pay_ca_fedtax_rule_rec.TOTAL_EXPENSE_BY_COMMISSION := P_COMM_EXPENSES;
    l_pay_ca_fedtax_rule_rec.TOTAL_REMNRTN_BY_COMMISSION := P_COMM_RENUMERATION;
    l_pay_ca_fedtax_rule_rec.PRESCRIBED_ZONE_DEDN_AMT    := P_PRES_ZONE_DEDN;
    l_pay_ca_fedtax_rule_rec.OTHER_FEDTAX_CREDITS        := 0;
    l_pay_ca_fedtax_rule_rec.CPP_QPP_EXEMPT_FLAG         := NVL(P_TAX_EXEMPT3,'N');
    l_pay_ca_fedtax_rule_rec.FED_EXEMPT_FLAG             := NVL(P_TAX_EXEMPT1,'N');
    l_pay_ca_fedtax_rule_rec.EI_EXEMPT_FLAG              := NVL(P_TAX_EXEMPT2,'N');
    --l_pay_ca_fedtax_rule_rec.TAX_CALC_METHOD           := ?;
    l_pay_ca_fedtax_rule_rec.FED_OVERRIDE_AMOUNT         := P_OVERRIDE_AMOUNT;
    l_pay_ca_fedtax_rule_rec.FED_OVERRIDE_RATE           := P_OVERRIDE_RATE;
    l_pay_ca_fedtax_rule_rec.FED_LSF_AMOUNT              := P_LABOR_FUND_CONTR;
    l_pay_ca_fedtax_rule_rec.ASSIGNMENT_ID               := ln_assignment_id;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION_CATEGORY := p_CA_TAX_INFORMATION_CATEGORY;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION1         := p_CA_TAX_INFORMATION1;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION2         := p_CA_TAX_INFORMATION2;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION3         := p_CA_TAX_INFORMATION3;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION4         := p_CA_TAX_INFORMATION4;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION5         := p_CA_TAX_INFORMATION5;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION6         := p_CA_TAX_INFORMATION6;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION7         := p_CA_TAX_INFORMATION7;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION8         := p_CA_TAX_INFORMATION8;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION9         := p_CA_TAX_INFORMATION9;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION10        := p_CA_TAX_INFORMATION10;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION11        := p_CA_TAX_INFORMATION11;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION12        := p_CA_TAX_INFORMATION12;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION13        := p_CA_TAX_INFORMATION13;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION14        := p_CA_TAX_INFORMATION14;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION15        := p_CA_TAX_INFORMATION15;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION16        := p_CA_TAX_INFORMATION16;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION17        := p_CA_TAX_INFORMATION17;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION18        := p_CA_TAX_INFORMATION18;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION19        := p_CA_TAX_INFORMATION19;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION20        := p_CA_TAX_INFORMATION20;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION21        := p_CA_TAX_INFORMATION21;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION22        := p_CA_TAX_INFORMATION22;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION23        := p_CA_TAX_INFORMATION23;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION24        := p_CA_TAX_INFORMATION24;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION25        := p_CA_TAX_INFORMATION25;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION26        := p_CA_TAX_INFORMATION26;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION27        := p_CA_TAX_INFORMATION27;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION28        := p_CA_TAX_INFORMATION28;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION29        := p_CA_TAX_INFORMATION29;
    l_pay_ca_fedtax_rule_rec.CA_TAX_INFORMATION30        := p_CA_TAX_INFORMATION30;

    open csr_get_cafedtax_id(ln_assignment_id);
    fetch csr_get_cafedtax_id into ln_cafedtax_inf_id,ln_ovn2;
    hr_utility.trace('emp_cafed_tax_inf_id :'||to_char(ln_cafedtax_inf_id));
    hr_utility.trace('object_version_number :'||to_char(ln_ovn2));

    if csr_get_cafedtax_id%FOUND then
       l_pay_ca_fedtax_rule_rec.EMP_FED_TAX_INF_ID    := ln_cafedtax_inf_id;
       l_pay_ca_fedtax_rule_rec.OBJECT_VERSION_NUMBER    := ln_ovn2;

       close csr_get_cafedtax_id;
       HR_DataPump(
                   p_dp_mode                 => 'UPDATE'
                   ,p_effective_date          => p_effective_date
                   ,p_spreadsheet_identifier  => p_spreadsheet_identifier
                  );
    else
       l_pay_ca_fedtax_rule_rec.ASSIGNMENT_ID := ln_assignment_id;

       close csr_get_cafedtax_id;
       HR_DataPump(
                   p_dp_mode                 => 'INSERT'
                   ,p_effective_date          => p_effective_date
                   ,p_spreadsheet_identifier  => p_spreadsheet_identifier
                  );
    end if;

    -- end of p_spreadsheet_identifier = 'PAYRICAFED'


   elsif P_SPREADSHEET_IDENTIFIER = 'PAYRICAPROVINCE' then

       if P_BASIC_AMT_FLAG = 'Y' and P_TAX_CREDIT is not NULL then
          hr_utility.set_message(800, 'HR_74007_BOTH_NOT_NULL');
          hr_utility.raise_error;
       elsif (P_BASIC_AMT_FLAG = 'N' and P_TAX_CREDIT is null) then
           l_pay_ca_provtax_rule_rec.TAX_CREDIT_AMOUNT := 0;
       elsif (P_BASIC_AMT_FLAG = 'N' and P_TAX_CREDIT is Not null) then
           l_pay_ca_provtax_rule_rec.TAX_CREDIT_AMOUNT := P_TAX_CREDIT;
       else
           l_pay_ca_provtax_rule_rec.TAX_CREDIT_AMOUNT := P_TAX_CREDIT;
       end if;

       if P_STATE_PROV_CODE =  'QC' then
          l_pay_ca_provtax_rule_rec.PROV_EXEMPT_FLAG        := NVL(P_TAX_EXEMPT1,'N');
          l_pay_ca_provtax_rule_rec.QPP_EXEMPT_FLAG         := NVL(P_TAX_EXEMPT4,'N');
          l_pay_ca_provtax_rule_rec.PROV_OVERRIDE_AMOUNT    := NVL(P_OVERRIDE_AMOUNT,0);
          l_pay_ca_provtax_rule_rec.PROV_OVERRIDE_RATE      := NVL(P_OVERRIDE_RATE,0);
          l_pay_ca_provtax_rule_rec.ADDITIONAL_TAX          := NVL(P_ADDITIONAL_TAX,0);

       elsif P_STATE_PROV_CODE in ('NT','NU') then
          l_pay_ca_provtax_rule_rec.PROV_EXEMPT_FLAG        := NVL(P_TAX_EXEMPT1,'N');
          l_pay_ca_provtax_rule_rec.QPP_EXEMPT_FLAG         := 'N';
          l_pay_ca_provtax_rule_rec.PROV_OVERRIDE_AMOUNT    := NVL(P_OVERRIDE_AMOUNT,0);
          l_pay_ca_provtax_rule_rec.PROV_OVERRIDE_RATE      := NVL(P_OVERRIDE_RATE,0);
          l_pay_ca_provtax_rule_rec.ADDITIONAL_TAX          := NVL(P_ADDITIONAL_TAX,0);

       else
          -- These values are hardcoded because they are not enabled in PUI forms
          --   when end user enters other province values
          l_pay_ca_provtax_rule_rec.PROV_EXEMPT_FLAG        := 'N';
          l_pay_ca_provtax_rule_rec.QPP_EXEMPT_FLAG         := 'N';
          l_pay_ca_provtax_rule_rec.PROV_OVERRIDE_AMOUNT    := 0;
          l_pay_ca_provtax_rule_rec.PROV_OVERRIDE_RATE      := 0;
          l_pay_ca_provtax_rule_rec.ADDITIONAL_TAX          := 0;
       end if;

       hr_utility.trace('Assigning parameter values to province record ');
       l_pay_ca_provtax_rule_rec.LEGISLATION_CODE         := 'CA';
       l_pay_ca_provtax_rule_rec.business_group_id         := p_business_group;
       l_pay_ca_provtax_rule_rec.PROVINCE_CODE            := ltrim(rtrim(P_STATE_PROV_CODE));
       l_pay_ca_provtax_rule_rec.BASIC_EXEMPTION_FLAG     := P_BASIC_AMT_FLAG;
       l_pay_ca_provtax_rule_rec.MARRIAGE_STATUS          := p_spouse_or_equivalent;
       l_pay_ca_provtax_rule_rec.NO_OF_INFIRM_DEPENDANTS  := NVL(p_number_of_infirm_dependents,0);
       l_pay_ca_provtax_rule_rec.NON_RESIDENT_STATUS      := p_non_resident;
       l_pay_ca_provtax_rule_rec.DISABILITY_STATUS        := p_disability_status;
       l_pay_ca_provtax_rule_rec.NO_OF_DEPENDANTS         := NVL(p_number_of_dependents,0);
       l_pay_ca_provtax_rule_rec.ANNUAL_DEDN                 := P_ANNUAL_DEDN;
       l_pay_ca_provtax_rule_rec.TOTAL_EXPENSE_BY_COMMISSION := P_COMM_EXPENSES;
       l_pay_ca_provtax_rule_rec.TOTAL_REMNRTN_BY_COMMISSION := P_COMM_RENUMERATION;
       l_pay_ca_provtax_rule_rec.PRESCRIBED_ZONE_DEDN_AMT    := P_PRES_ZONE_DEDN;
       l_pay_ca_provtax_rule_rec.WC_EXEMPT_FLAG              := NVL(P_TAX_EXEMPT3,'N');
       l_pay_ca_provtax_rule_rec.PMED_EXEMPT_FLAG            := NVL(P_TAX_EXEMPT2,'N');
       l_pay_ca_provtax_rule_rec.PROV_LSP_AMOUNT             := NVL(P_LABOR_FUND_CONTR,0);
       l_pay_ca_provtax_rule_rec.ASSIGNMENT_ID               := ln_assignment_id;
        l_pay_ca_provtax_rule_rec.EXTRA_INFO_NOT_PROVIDED    := 'Y';
        l_pay_ca_provtax_rule_rec.OTHER_TAX_CREDIT           := 0;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION_CATEGORY := p_CA_TAX_INFORMATION_CATEGORY;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION1         := p_CA_TAX_INFORMATION1;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION2         := p_CA_TAX_INFORMATION2;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION3         := p_CA_TAX_INFORMATION3;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION4         := p_CA_TAX_INFORMATION4;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION5         := p_CA_TAX_INFORMATION5;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION6         := p_CA_TAX_INFORMATION6;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION7         := p_CA_TAX_INFORMATION7;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION8         := p_CA_TAX_INFORMATION8;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION9         := p_CA_TAX_INFORMATION9;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION10        := p_CA_TAX_INFORMATION10;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION11        := p_CA_TAX_INFORMATION11;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION12        := p_CA_TAX_INFORMATION12;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION13        := p_CA_TAX_INFORMATION13;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION14        := p_CA_TAX_INFORMATION14;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION15        := p_CA_TAX_INFORMATION15;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION16        := p_CA_TAX_INFORMATION16;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION17        := p_CA_TAX_INFORMATION17;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION18        := p_CA_TAX_INFORMATION18;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION19        := p_CA_TAX_INFORMATION19;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION20        := p_CA_TAX_INFORMATION20;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION21        := p_CA_TAX_INFORMATION21;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION22        := p_CA_TAX_INFORMATION22;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION23        := p_CA_TAX_INFORMATION23;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION24        := p_CA_TAX_INFORMATION24;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION25        := p_CA_TAX_INFORMATION25;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION26        := p_CA_TAX_INFORMATION26;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION27        := p_CA_TAX_INFORMATION27;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION28        := p_CA_TAX_INFORMATION28;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION29        := p_CA_TAX_INFORMATION29;
       l_pay_ca_provtax_rule_rec.CA_TAX_INFORMATION30        := p_CA_TAX_INFORMATION30;

       --l_pay_ca_provtax_rule_rec.TAX_CALC_METHOD           := ?;

    open csr_get_caprovtax_id(ln_assignment_id);
    fetch csr_get_caprovtax_id into ln_caprovtax_inf_id,ln_ovn2;
    hr_utility.trace('emp_caprov_tax_inf_id :'||to_char(ln_caprovtax_inf_id));
    hr_utility.trace('object_version_number :'||to_char(ln_ovn2));


    if csr_get_caprovtax_id%FOUND then
       l_pay_ca_provtax_rule_rec.EMP_PROVINCE_TAX_INF_ID    := ln_caprovtax_inf_id;
       l_pay_ca_provtax_rule_rec.OBJECT_VERSION_NUMBER    := ln_ovn2;

       close csr_get_caprovtax_id;
       HR_DataPump(
                    p_dp_mode                 => 'UPDATE'
                   ,p_effective_date          => p_effective_date
                   ,p_spreadsheet_identifier  => p_spreadsheet_identifier
                  );
    else
       hr_utility.trace('province record not found ');
       l_pay_ca_provtax_rule_rec.ASSIGNMENT_ID := ln_assignment_id;

       close csr_get_caprovtax_id;
       HR_DataPump(
                   p_dp_mode                 => 'INSERT'
                   ,p_effective_date          => p_effective_date
                   ,p_spreadsheet_identifier  => p_spreadsheet_identifier
                  );
    end if;

    -- end of p_spreadsheet_identifier = 'PAYRICAPROVINCE'

  end if; -- p_spreadsheet_identifier validation

end create_ac_emptaxrule;

end pay_ri_ac_tax_rule;

/
