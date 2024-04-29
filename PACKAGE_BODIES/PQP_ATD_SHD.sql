--------------------------------------------------------
--  DDL for Package Body PQP_ATD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_ATD_SHD" as
/* $Header: pqatdrhi.pkb 115.10 2003/02/17 22:13:56 tmehra ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  VARCHAR2(33)  := '  pqp_atd_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
FUNCTION return_api_dml_status RETURN BOOLEAN IS
--
  l_proc         varchar2(72) := g_package||'return_api_dml_status';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Return (nvl(g_api_dml, false));
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END return_api_dml_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc         varchar2(72) := g_package||'constraint_error';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  IF (p_constraint_name = 'PQP_ALIEN_TRANSACTION_DATA_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ELSE
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
FUNCTION api_updating
(
    p_alien_transaction_id               IN NUMBER,
    p_object_version_number              IN NUMBER
)      RETURN BOOLEAN IS
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
        alien_transaction_id,
        person_id,
        data_source_type,
        tax_year,
        income_code,
        withholding_rate,
        income_code_sub_type,
        exemption_code,
        maximum_benefit_amount,
        retro_lose_ben_amt_flag,
        date_benefit_ends,
        retro_lose_ben_date_flag,
        current_residency_status,
        nra_to_ra_date,
        target_departure_date,
        tax_residence_country_code,
        treaty_info_update_date,
        nra_exempt_from_fica,
        student_exempt_from_fica,
        addl_withholding_flag,
        addl_withholding_amt,
        addl_wthldng_amt_period_type,
        personal_exemption,
        addl_exemption_allowed,
        number_of_days_in_usa,
        wthldg_allow_eligible_flag,
        treaty_ben_allowed_flag,
        treaty_benefits_start_date,
        ra_effective_date,
        state_code,
        state_honors_treaty_flag,
        ytd_payments,
        ytd_w2_payments,
        ytd_w2_withholding,
        ytd_withholding_allowance,
        ytd_treaty_payments,
        ytd_treaty_withheld_amt,
        record_source,
        visa_type,
        j_sub_type,
        primary_activity,
        non_us_country_code,
        citizenship_country_code,
        constant_addl_tax,
        date_8233_signed,
        date_w4_signed,
        error_indicator,
        prev_er_treaty_benefit_amt,
        error_text,
        object_version_number ,
        current_analysis,
        forecast_income_code
    from        pqp_alien_transaction_data
    where        alien_transaction_id = p_alien_transaction_id;
--
  l_proc        varchar2(72)        := g_package||'api_updating';
  l_fct_ret        boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
        p_alien_transaction_id is null and
        p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
        p_alien_transaction_id = g_old_rec.alien_transaction_id and
        p_object_version_number = g_old_rec.object_version_number
       ) Then
      hr_utility.set_location(l_proc, 10);
      --
      -- The g_old_rec is current therefore we must
      -- set the returning function to true
      --
      l_fct_ret := true;
    Else
      --
      -- Select the current row into g_old_rec
      --
      Open C_Sel1;
      Fetch C_Sel1 Into g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
        hr_utility.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
      hr_utility.set_location(l_proc, 15);
      l_fct_ret := true;
    End If;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_alien_transaction_id               in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select         alien_transaction_id,
        person_id,
        data_source_type,
        tax_year,
        income_code,
        withholding_rate,
        income_code_sub_type,
        exemption_code,
        maximum_benefit_amount,
        retro_lose_ben_amt_flag,
        date_benefit_ends,
        retro_lose_ben_date_flag,
        current_residency_status,
        nra_to_ra_date,
        target_departure_date,
        tax_residence_country_code,
        treaty_info_update_date,
        nra_exempt_from_fica,
        student_exempt_from_fica,
        addl_withholding_flag,
        addl_withholding_amt,
        addl_wthldng_amt_period_type,
        personal_exemption,
        addl_exemption_allowed,
        number_of_days_in_usa,
        wthldg_allow_eligible_flag,
        treaty_ben_allowed_flag,
        treaty_benefits_start_date,
        ra_effective_date,
        state_code,
        state_honors_treaty_flag,
        ytd_payments,
        ytd_w2_payments,
        ytd_w2_withholding,
        ytd_withholding_allowance,
        ytd_treaty_payments,
        ytd_treaty_withheld_amt,
        record_source,
        visa_type,
        j_sub_type,
        primary_activity,
        non_us_country_code,
        citizenship_country_code,
        constant_addl_tax,
        date_8233_signed,
        date_w4_signed,
        error_indicator,
        prev_er_treaty_benefit_amt,
        error_text,
        object_version_number,
        current_analysis,
        forecast_income_code
    from        pqp_alien_transaction_data
    where        alien_transaction_id = p_alien_transaction_id
    for        update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Add any mandatory argument checking here:
  -- Example:
  -- hr_api.mandatory_arg_error
  --   (p_api_name       => l_proc,
  --    p_argument       => 'object_version_number',
  --    p_argument_value => p_object_version_number);
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
-- We need to trap the ORA LOCK exception
--
Exception
  When HR_Api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'pqp_alien_transaction_data');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
        (
        p_alien_transaction_id          in number,
        p_person_id                     in number,
        p_data_source_type              in varchar2,
        p_tax_year                      in number,
        p_income_code                   in varchar2,
        p_withholding_rate              in number,
        p_income_code_sub_type          in varchar2,
        p_exemption_code                in varchar2,
        p_maximum_benefit_amount        in number,
        p_retro_lose_ben_amt_flag       in varchar2,
        p_date_benefit_ends             in date,
        p_retro_lose_ben_date_flag      in varchar2,
        p_current_residency_status      in varchar2,
        p_nra_to_ra_date                in date,
        p_target_departure_date         in date,
        p_tax_residence_country_code    in varchar2,
        p_treaty_info_update_date       in date,
        p_nra_exempt_from_fica          in varchar2,
        p_student_exempt_from_fica      in varchar2,
        p_addl_withholding_flag         in varchar2,
        p_addl_withholding_amt          in number,
        p_addl_wthldng_amt_period_type  in varchar2,
        p_personal_exemption            in number,
        p_addl_exemption_allowed        in number,
        p_number_of_days_in_usa         in number,
        p_wthldg_allow_eligible_flag    in varchar2,
        p_treaty_ben_allowed_flag       in varchar2,
        p_treaty_benefits_start_date    in date,
        p_ra_effective_date             in date,
        p_state_code                    in varchar2,
        p_state_honors_treaty_flag      in varchar2,
        p_ytd_payments                  in number,
        p_ytd_w2_payments               in number,
        p_ytd_w2_withholding            in number,
        p_ytd_withholding_allowance     in number,
        p_ytd_treaty_payments           in number,
        p_ytd_treaty_withheld_amt       in number,
        p_record_source                 in varchar2,
        p_visa_type                     in varchar2,
        p_j_sub_type                    in varchar2,
        p_primary_activity              in varchar2,
        p_non_us_country_code           in varchar2,
        p_citizenship_country_code      in varchar2,
        p_constant_addl_tax             in number,
        p_date_8233_signed              in date,
        p_date_w4_signed                in date,
        p_error_indicator               in varchar2,
        p_prev_er_treaty_benefit_amt    in number,
        p_error_text                    in varchar2,
        p_object_version_number         in number,
        p_current_analysis              in varchar2,
        p_forecast_income_code          in varchar2
        )
        Return g_rec_type is
--
  l_rec          g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.alien_transaction_id             := p_alien_transaction_id;
  l_rec.person_id                        := p_person_id;
  l_rec.data_source_type                 := p_data_source_type;
  l_rec.tax_year                         := p_tax_year;
  l_rec.income_code                      := p_income_code;
  l_rec.withholding_rate                 := p_withholding_rate;
  l_rec.income_code_sub_type             := p_income_code_sub_type;
  l_rec.exemption_code                   := p_exemption_code;
  l_rec.maximum_benefit_amount           := p_maximum_benefit_amount;
  l_rec.retro_lose_ben_amt_flag          := p_retro_lose_ben_amt_flag;
  l_rec.date_benefit_ends                := p_date_benefit_ends;
  l_rec.retro_lose_ben_date_flag         := p_retro_lose_ben_date_flag;
  l_rec.current_residency_status         := p_current_residency_status;
  l_rec.nra_to_ra_date                   := p_nra_to_ra_date;
  l_rec.target_departure_date            := p_target_departure_date;
  l_rec.tax_residence_country_code       := p_tax_residence_country_code;
  l_rec.treaty_info_update_date          := p_treaty_info_update_date;
  l_rec.nra_exempt_from_fica             := p_nra_exempt_from_fica;
  l_rec.student_exempt_from_fica         := p_student_exempt_from_fica;
  l_rec.addl_withholding_flag            := p_addl_withholding_flag;
  l_rec.addl_withholding_amt             := p_addl_withholding_amt;
  l_rec.addl_wthldng_amt_period_type     := p_addl_wthldng_amt_period_type;
  l_rec.personal_exemption               := p_personal_exemption;
  l_rec.addl_exemption_allowed           := p_addl_exemption_allowed;
  l_rec.number_of_days_in_usa            := p_number_of_days_in_usa;
  l_rec.wthldg_allow_eligible_flag       := p_wthldg_allow_eligible_flag;
  l_rec.treaty_ben_allowed_flag          := p_treaty_ben_allowed_flag;
  l_rec.treaty_benefits_start_date       := p_treaty_benefits_start_date;
  l_rec.ra_effective_date                := p_ra_effective_date;
  l_rec.state_code                       := p_state_code;
  l_rec.state_honors_treaty_flag         := p_state_honors_treaty_flag;
  l_rec.ytd_payments                     := p_ytd_payments;
  l_rec.ytd_w2_payments                  := p_ytd_w2_payments;
  l_rec.ytd_w2_withholding               := p_ytd_w2_withholding;
  l_rec.ytd_withholding_allowance        := p_ytd_withholding_allowance;
  l_rec.ytd_treaty_payments              := p_ytd_treaty_payments;
  l_rec.ytd_treaty_withheld_amt          := p_ytd_treaty_withheld_amt;
  l_rec.record_source                    := p_record_source;
  l_rec.visa_type                        := p_visa_type;
  l_rec.j_sub_type                       := p_j_sub_type;
  l_rec.primary_activity                 := p_primary_activity;
  l_rec.non_us_country_code              := p_non_us_country_code;
  l_rec.citizenship_country_code         := p_citizenship_country_code;
  l_rec.constant_addl_tax                := p_constant_addl_tax;
  l_rec.date_8233_signed                 := p_date_8233_signed;
  l_rec.date_w4_signed                   := p_date_w4_signed;
  l_rec.error_indicator                  := p_error_indicator;
  l_rec.prev_er_treaty_benefit_amt       := p_prev_er_treaty_benefit_amt;
  l_rec.error_text                       := p_error_text;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.current_analysis                 := p_current_analysis;
  l_rec.forecast_income_code             := p_forecast_income_code;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end pqp_atd_shd;

/
