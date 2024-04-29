--------------------------------------------------------
--  DDL for Package Body PQP_PTY_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_PTY_SHD" as
/* $Header: pqptyrhi.pkb 120.0.12000000.1 2007/01/16 04:29:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_pty_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc        varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'PQP_PENSION_TYPES_PK_F') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  Else
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
  End If;
  --
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_effective_date                   in date
  ,p_pension_type_id                  in number
  ,p_object_version_number            in number
  ) Return Boolean Is
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
     pension_type_id
    ,effective_start_date
    ,effective_end_date
    ,pension_type_name
    ,pension_category
    ,pension_provider_type
    ,salary_calculation_method
    ,threshold_conversion_rule
    ,contribution_conversion_rule
    ,er_annual_limit
    ,ee_annual_limit
    ,er_annual_salary_threshold
    ,ee_annual_salary_threshold
    ,object_version_number
    ,business_group_id
    ,legislation_code
    ,description
    ,minimum_age
    ,ee_contribution_percent
    ,maximum_age
    ,er_contribution_percent
    ,ee_annual_contribution
    ,er_annual_contribution
    ,annual_premium_amount
    ,ee_contribution_bal_type_id
    ,er_contribution_bal_type_id
    ,balance_init_element_type_id
    ,ee_contribution_fixed_rate     -- added for UK
    ,er_contribution_fixed_rate     -- added for UK
    ,pty_attribute_category
    ,pty_attribute1
    ,pty_attribute2
    ,pty_attribute3
    ,pty_attribute4
    ,pty_attribute5
    ,pty_attribute6
    ,pty_attribute7
    ,pty_attribute8
    ,pty_attribute9
    ,pty_attribute10
    ,pty_attribute11
    ,pty_attribute12
    ,pty_attribute13
    ,pty_attribute14
    ,pty_attribute15
    ,pty_attribute16
    ,pty_attribute17
    ,pty_attribute18
    ,pty_attribute19
    ,pty_attribute20
    ,pty_information_category
    ,pty_information1
    ,pty_information2
    ,pty_information3
    ,pty_information4
    ,pty_information5
    ,pty_information6
    ,pty_information7
    ,pty_information8
    ,pty_information9
    ,pty_information10
    ,pty_information11
    ,pty_information12
    ,pty_information13
    ,pty_information14
    ,pty_information15
    ,pty_information16
    ,pty_information17
    ,pty_information18
    ,pty_information19
    ,pty_information20
    ,special_pension_type_code          -- added for NL Phase 2B
    ,pension_sub_category               -- added for NL Phase 2B
    ,pension_basis_calc_method          -- added for NL Phase 2B
    ,pension_salary_balance             -- added for NL Phase 2B
    ,recurring_bonus_percent            -- added for NL Phase 2B
    ,non_recurring_bonus_percent        -- added for NL Phase 2B
    ,recurring_bonus_balance            -- added for NL Phase 2B
    ,non_recurring_bonus_balance        -- added for NL Phase 2B
    ,std_tax_reduction                  -- added for NL Phase 2B
    ,spl_tax_reduction                  -- added for NL Phase 2B
    ,sig_sal_spl_tax_reduction          -- added for NL Phase 2B
    ,sig_sal_non_tax_reduction          -- added for NL Phase 2B
    ,sig_sal_std_tax_reduction          -- added for NL Phase 2B
    ,sii_std_tax_reduction              -- added for NL Phase 2B
    ,sii_spl_tax_reduction              -- added for NL Phase 2B
    ,sii_non_tax_reduction              -- added for NL Phase 2B
    ,previous_year_bonus_included       -- added for NL Phase 2B
    ,recurring_bonus_period             -- added for NL Phase 2B
    ,non_recurring_bonus_period         -- added for NL Phase 2B
    ,ee_age_threshold                   -- added for ABP TAR fixes
    ,er_age_threshold                   -- added for ABP TAR fixes
    ,ee_age_contribution                -- added for ABP TAR fixes
    ,er_age_contribution                -- added for ABP TAR fixes
    from        pqp_pension_types_f
    where       pension_type_id = p_pension_type_id
    and         p_effective_date
    between     effective_start_date and effective_end_date;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_effective_date is null or
      p_pension_type_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_pension_type_id =
        pqp_pty_shd.g_old_rec.pension_type_id and
        p_object_version_number =
        pqp_pty_shd.g_old_rec.object_version_number ) Then
      --
      -- The g_old_rec is current therefore we must
      -- set the returning function to true
      --
      l_fct_ret := true;
    Else
      --
      -- Select the current row
      --
      Open C_Sel1;
      Fetch C_Sel1 Into pqp_pty_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number
          <> pqp_pty_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
      End If;
      l_fct_ret := true;
    End If;
  End If;
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< find_dt_upd_modes >--------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_upd_modes
  (p_effective_date         in date
  ,p_base_key_value         in number
  ,p_correction             out nocopy boolean
  ,p_update                 out nocopy boolean
  ,p_update_override        out nocopy boolean
  ,p_update_change_insert   out nocopy boolean
  ) is
--
  l_proc        varchar2(72) := g_package||'find_dt_upd_modes';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_upd_modes
    (p_effective_date        => p_effective_date
    ,p_base_table_name       => 'pqp_pension_types_f'
    ,p_base_key_column       => 'pension_type_id'
    ,p_base_key_value        => p_base_key_value
    ,p_correction            => p_correction
    ,p_update                => p_update
    ,p_update_override       => p_update_override
    ,p_update_change_insert  => p_update_change_insert
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_upd_modes;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< find_dt_del_modes >--------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_del_modes
  (p_effective_date        in date
  ,p_base_key_value        in number
  ,p_zap                   out nocopy boolean
  ,p_delete                out nocopy boolean
  ,p_future_change         out nocopy boolean
  ,p_delete_next_change    out nocopy boolean
  ) is
  --
  l_proc                varchar2(72)    := g_package||'find_dt_del_modes';
  --
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_del_modes
   (p_effective_date                => p_effective_date
   ,p_base_table_name               => 'pqp_pension_types_f'
   ,p_base_key_column               => 'pension_type_id'
   ,p_base_key_value                => p_base_key_value
   ,p_zap                           => p_zap
   ,p_delete                        => p_delete
   ,p_future_change                 => p_future_change
   ,p_delete_next_change            => p_delete_next_change
   );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_del_modes;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< upd_effective_end_date >-------------------------|
-- ----------------------------------------------------------------------------
Procedure upd_effective_end_date
  (p_effective_date                   in date
  ,p_base_key_value                   in number
  ,p_new_effective_end_date           in date
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ,p_object_version_number  out nocopy number
  ) is
--
  l_proc                  varchar2(72) := g_package||'upd_effective_end_date';
  l_object_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Because we are updating a row we must get the next object
  -- version number.
  --
  l_object_version_number :=
    dt_api.get_object_version_number
      (p_base_table_name    => 'pqp_pension_types_f'
      ,p_base_key_column    => 'pension_type_id'
      ,p_base_key_value     => p_base_key_value
      );
  --
  hr_utility.set_location(l_proc, 10);
  --
--
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  pqp_pension_types_f t
  set     t.effective_end_date    = p_new_effective_end_date
    ,     t.object_version_number = l_object_version_number
  where   t.pension_type_id        = p_base_key_value
  and     p_effective_date
  between t.effective_start_date and t.effective_end_date;
  --
  --
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
End upd_effective_end_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (p_effective_date                   in date
  ,p_datetrack_mode                   in varchar2
  ,p_pension_type_id                  in number
  ,p_object_version_number            in number
  ,p_validation_start_date            out nocopy date
  ,p_validation_end_date              out nocopy date
  ) is
--
  l_proc                  varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date   date;
  l_argument              varchar2(30);
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  Cursor C_Sel1 is
    select
     pension_type_id
    ,effective_start_date
    ,effective_end_date
    ,pension_type_name
    ,pension_category
    ,pension_provider_type
    ,salary_calculation_method
    ,threshold_conversion_rule
    ,contribution_conversion_rule
    ,er_annual_limit
    ,ee_annual_limit
    ,er_annual_salary_threshold
    ,ee_annual_salary_threshold
    ,object_version_number
    ,business_group_id
    ,legislation_code
    ,description
    ,minimum_age
    ,ee_contribution_percent
    ,maximum_age
    ,er_contribution_percent
    ,ee_annual_contribution
    ,er_annual_contribution
    ,annual_premium_amount
    ,ee_contribution_bal_type_id
    ,er_contribution_bal_type_id
    ,balance_init_element_type_id
    ,ee_contribution_fixed_rate   -- added for UK
    ,er_contribution_fixed_rate   -- added for UK
    ,pty_attribute_category
    ,pty_attribute1
    ,pty_attribute2
    ,pty_attribute3
    ,pty_attribute4
    ,pty_attribute5
    ,pty_attribute6
    ,pty_attribute7
    ,pty_attribute8
    ,pty_attribute9
    ,pty_attribute10
    ,pty_attribute11
    ,pty_attribute12
    ,pty_attribute13
    ,pty_attribute14
    ,pty_attribute15
    ,pty_attribute16
    ,pty_attribute17
    ,pty_attribute18
    ,pty_attribute19
    ,pty_attribute20
    ,pty_information_category
    ,pty_information1
    ,pty_information2
    ,pty_information3
    ,pty_information4
    ,pty_information5
    ,pty_information6
    ,pty_information7
    ,pty_information8
    ,pty_information9
    ,pty_information10
    ,pty_information11
    ,pty_information12
    ,pty_information13
    ,pty_information14
    ,pty_information15
    ,pty_information16
    ,pty_information17
    ,pty_information18
    ,pty_information19
    ,pty_information20
    ,special_pension_type_code          -- added for NL Phase 2B
    ,pension_sub_category               -- added for NL Phase 2B
    ,pension_basis_calc_method          -- added for NL Phase 2B
    ,pension_salary_balance             -- added for NL Phase 2B
    ,recurring_bonus_percent            -- added for NL Phase 2B
    ,non_recurring_bonus_percent        -- added for NL Phase 2B
    ,recurring_bonus_balance            -- added for NL Phase 2B
    ,non_recurring_bonus_balance        -- added for NL Phase 2B
    ,std_tax_reduction                  -- added for NL Phase 2B
    ,spl_tax_reduction                  -- added for NL Phase 2B
    ,sig_sal_spl_tax_reduction          -- added for NL Phase 2B
    ,sig_sal_non_tax_reduction          -- added for NL Phase 2B
    ,sig_sal_std_tax_reduction          -- added for NL Phase 2B
    ,sii_std_tax_reduction              -- added for NL Phase 2B
    ,sii_spl_tax_reduction              -- added for NL Phase 2B
    ,sii_non_tax_reduction              -- added for NL Phase 2B
    ,previous_year_bonus_included       -- added for NL Phase 2B
    ,recurring_bonus_period             -- added for NL Phase 2B
    ,non_recurring_bonus_period         -- added for NL Phase 2B
    ,ee_age_threshold                   -- added for ABP TAR fixes
    ,er_age_threshold                   -- added for ABP TAR fixes
    ,ee_age_contribution                -- added for ABP TAR fixes
    ,er_age_contribution                -- added for ABP TAR fixes
    from    pqp_pension_types_f
    where   pension_type_id = p_pension_type_id
    and     p_effective_date
    between effective_start_date and effective_end_date
    for update nowait;
  --
  --
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that all the mandatory arguments are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'effective_date'
                            ,p_argument_value => p_effective_date
                            );
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'datetrack_mode'
                            ,p_argument_value => p_datetrack_mode
                            );
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'pension_type_id'
                            ,p_argument_value => p_pension_type_id
                            );
  --
    hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'object_version_number'
                            ,p_argument_value => p_object_version_number
                            );
  --
  -- Check to ensure the datetrack mode is not INSERT.
  --
  If (p_datetrack_mode <> hr_api.g_insert) then
    --
    -- We must select and lock the current row.
    --
    Open  C_Sel1;
    Fetch C_Sel1 Into pqp_pty_shd.g_old_rec;
    If C_Sel1%notfound then
      Close C_Sel1;
      --
      -- The primary key is invalid therefore we must error
      --
      fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    End If;
    Close C_Sel1;
    If (p_object_version_number
          <> pqp_pty_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
    End If;
    --
    --
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
    dt_api.validate_dt_mode
      (p_effective_date          => p_effective_date
      ,p_datetrack_mode          => p_datetrack_mode
      ,p_base_table_name         => 'pqp_pension_types_f'
      ,p_base_key_column         => 'pension_type_id'
      ,p_base_key_value          => p_pension_type_id
      ,p_enforce_foreign_locking => true
      ,p_validation_start_date   => l_validation_start_date
      ,p_validation_end_date     => l_validation_end_date
      );
  Else
    --
    -- We are doing a datetrack 'INSERT' which is illegal within this
    -- procedure therefore we must error (note: to lck on insert the
    -- private procedure ins_lck should be called).
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
  End If;
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
--
-- We need to trap the ORA LOCK exception
--
Exception
  When HR_Api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'pqp_pension_types_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_pension_type_id                in number
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_pension_type_name              in varchar2
  ,p_pension_category               in varchar2
  ,p_pension_provider_type          in varchar2
  ,p_salary_calculation_method      in varchar2
  ,p_threshold_conversion_rule      in varchar2
  ,p_contribution_conversion_rule   in varchar2
  ,p_er_annual_limit                in number
  ,p_ee_annual_limit                in number
  ,p_er_annual_salary_threshold     in number
  ,p_ee_annual_salary_threshold     in number
  ,p_object_version_number          in number
  ,p_business_group_id              in number
  ,p_legislation_code               in varchar2
  ,p_description                    in varchar2
  ,p_minimum_age                    in number
  ,p_ee_contribution_percent        in number
  ,p_maximum_age                    in number
  ,p_er_contribution_percent        in number
  ,p_ee_annual_contribution         in number
  ,p_er_annual_contribution         in number
  ,p_annual_premium_amount          in number
  ,p_ee_contribution_bal_type_id    in number
  ,p_er_contribution_bal_type_id    in number
  ,p_balance_init_element_type_id   in number
  ,p_ee_contribution_fixed_rate     in number    --added for UK
  ,p_er_contribution_fixed_rate     in number    --added for UK
  ,p_pty_attribute_category         in varchar2
  ,p_pty_attribute1                 in varchar2
  ,p_pty_attribute2                 in varchar2
  ,p_pty_attribute3                 in varchar2
  ,p_pty_attribute4                 in varchar2
  ,p_pty_attribute5                 in varchar2
  ,p_pty_attribute6                 in varchar2
  ,p_pty_attribute7                 in varchar2
  ,p_pty_attribute8                 in varchar2
  ,p_pty_attribute9                 in varchar2
  ,p_pty_attribute10                in varchar2
  ,p_pty_attribute11                in varchar2
  ,p_pty_attribute12                in varchar2
  ,p_pty_attribute13                in varchar2
  ,p_pty_attribute14                in varchar2
  ,p_pty_attribute15                in varchar2
  ,p_pty_attribute16                in varchar2
  ,p_pty_attribute17                in varchar2
  ,p_pty_attribute18                in varchar2
  ,p_pty_attribute19                in varchar2
  ,p_pty_attribute20                in varchar2
  ,p_pty_information_category       in varchar2
  ,p_pty_information1               in varchar2
  ,p_pty_information2               in varchar2
  ,p_pty_information3               in varchar2
  ,p_pty_information4               in varchar2
  ,p_pty_information5               in varchar2
  ,p_pty_information6               in varchar2
  ,p_pty_information7               in varchar2
  ,p_pty_information8               in varchar2
  ,p_pty_information9               in varchar2
  ,p_pty_information10              in varchar2
  ,p_pty_information11              in varchar2
  ,p_pty_information12              in varchar2
  ,p_pty_information13              in varchar2
  ,p_pty_information14              in varchar2
  ,p_pty_information15              in varchar2
  ,p_pty_information16              in varchar2
  ,p_pty_information17              in varchar2
  ,p_pty_information18              in varchar2
  ,p_pty_information19              in varchar2
  ,p_pty_information20              in varchar2
  ,p_special_pension_type_code      in varchar2    -- added for NL Phase 2B
  ,p_pension_sub_category           in varchar2    -- added for NL Phase 2B
  ,p_pension_basis_calc_method      in varchar2    -- added for NL Phase 2B
  ,p_pension_salary_balance         in number      -- added for NL Phase 2B
  ,p_recurring_bonus_percent        in number      -- added for NL Phase 2B
  ,p_non_recurring_bonus_percent    in number      -- added for NL Phase 2B
  ,p_recurring_bonus_balance        in number      -- added for NL Phase 2B
  ,p_non_recurring_bonus_balance    in number      -- added for NL Phase 2B
  ,p_std_tax_reduction              in varchar2    -- added for NL Phase 2B
  ,p_spl_tax_reduction              in varchar2    -- added for NL Phase 2B
  ,p_sig_sal_spl_tax_reduction      in varchar2    -- added for NL Phase 2B
  ,p_sig_sal_non_tax_reduction      in varchar2    -- added for NL Phase 2B
  ,p_sig_sal_std_tax_reduction      in varchar2    -- added for NL Phase 2B
  ,p_sii_std_tax_reduction          in varchar2    -- added for NL Phase 2B
  ,p_sii_spl_tax_reduction          in varchar2    -- added for NL Phase 2B
  ,p_sii_non_tax_reduction          in varchar2    -- added for NL Phase 2B
  ,p_previous_year_bonus_included   in varchar2    -- added for NL Phase 2B
  ,p_recurring_bonus_period         in varchar2    -- added for NL Phase 2B
  ,p_non_recurring_bonus_period     in varchar2    -- added for NL Phase 2B
  ,p_ee_age_threshold               in varchar2    -- added for ABP TAR fixes
  ,p_er_age_threshold               in varchar2    -- added for ABP TAR fixes
  ,p_ee_age_contribution            in varchar2    -- added for ABP TAR fixes
  ,p_er_age_contribution            in varchar2    -- added for ABP TAR fixes
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.pension_type_id                  := p_pension_type_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.pension_type_name                := p_pension_type_name;
  l_rec.pension_category                 := p_pension_category;
  l_rec.pension_provider_type            := p_pension_provider_type;
  l_rec.salary_calculation_method        := p_salary_calculation_method;
  l_rec.threshold_conversion_rule        := p_threshold_conversion_rule;
  l_rec.contribution_conversion_rule     := p_contribution_conversion_rule;
  l_rec.er_annual_limit                  := p_er_annual_limit;
  l_rec.ee_annual_limit                  := p_ee_annual_limit;
  l_rec.er_annual_salary_threshold       := p_er_annual_salary_threshold;
  l_rec.ee_annual_salary_threshold       := p_ee_annual_salary_threshold;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.description                      := p_description;
  l_rec.minimum_age                      := p_minimum_age;
  l_rec.ee_contribution_percent          := p_ee_contribution_percent;
  l_rec.maximum_age                      := p_maximum_age;
  l_rec.er_contribution_percent          := p_er_contribution_percent;
  l_rec.ee_annual_contribution           := p_ee_annual_contribution;
  l_rec.er_annual_contribution           := p_er_annual_contribution;
  l_rec.annual_premium_amount            := p_annual_premium_amount;
  l_rec.ee_contribution_bal_type_id      := p_ee_contribution_bal_type_id;
  l_rec.er_contribution_bal_type_id      := p_er_contribution_bal_type_id;
  l_rec.balance_init_element_type_id     := p_balance_init_element_type_id;
  l_rec.ee_contribution_fixed_rate     := p_ee_contribution_fixed_rate ; -- added for UK
  l_rec.er_contribution_fixed_rate     := p_er_contribution_fixed_rate ;  -- added for UK
  l_rec.pty_attribute_category           := p_pty_attribute_category;
  l_rec.pty_attribute1                   := p_pty_attribute1;
  l_rec.pty_attribute2                   := p_pty_attribute2;
  l_rec.pty_attribute3                   := p_pty_attribute3;
  l_rec.pty_attribute4                   := p_pty_attribute4;
  l_rec.pty_attribute5                   := p_pty_attribute5;
  l_rec.pty_attribute6                   := p_pty_attribute6;
  l_rec.pty_attribute7                   := p_pty_attribute7;
  l_rec.pty_attribute8                   := p_pty_attribute8;
  l_rec.pty_attribute9                   := p_pty_attribute9;
  l_rec.pty_attribute10                  := p_pty_attribute10;
  l_rec.pty_attribute11                  := p_pty_attribute11;
  l_rec.pty_attribute12                  := p_pty_attribute12;
  l_rec.pty_attribute13                  := p_pty_attribute13;
  l_rec.pty_attribute14                  := p_pty_attribute14;
  l_rec.pty_attribute15                  := p_pty_attribute15;
  l_rec.pty_attribute16                  := p_pty_attribute16;
  l_rec.pty_attribute17                  := p_pty_attribute17;
  l_rec.pty_attribute18                  := p_pty_attribute18;
  l_rec.pty_attribute19                  := p_pty_attribute19;
  l_rec.pty_attribute20                  := p_pty_attribute20;
  l_rec.pty_information_category         := p_pty_information_category;
  l_rec.pty_information1                 := p_pty_information1;
  l_rec.pty_information2                 := p_pty_information2;
  l_rec.pty_information3                 := p_pty_information3;
  l_rec.pty_information4                 := p_pty_information4;
  l_rec.pty_information5                 := p_pty_information5;
  l_rec.pty_information6                 := p_pty_information6;
  l_rec.pty_information7                 := p_pty_information7;
  l_rec.pty_information8                 := p_pty_information8;
  l_rec.pty_information9                 := p_pty_information9;
  l_rec.pty_information10                := p_pty_information10;
  l_rec.pty_information11                := p_pty_information11;
  l_rec.pty_information12                := p_pty_information12;
  l_rec.pty_information13                := p_pty_information13;
  l_rec.pty_information14                := p_pty_information14;
  l_rec.pty_information15                := p_pty_information15;
  l_rec.pty_information16                := p_pty_information16;
  l_rec.pty_information17                := p_pty_information17;
  l_rec.pty_information18                := p_pty_information18;
  l_rec.pty_information19                := p_pty_information19;
  l_rec.pty_information20                := p_pty_information20;
  l_rec.special_pension_type_code        := p_special_pension_type_code;        -- added for NL Phase 2B
  l_rec.pension_sub_category         	 := p_pension_sub_category;             -- added for NL Phase 2B
  l_rec.pension_basis_calc_method    	 := p_pension_basis_calc_method;        -- added for NL Phase 2B
  l_rec.pension_salary_balance       	 := p_pension_salary_balance ;          -- added for NL Phase 2B
  l_rec.recurring_bonus_percent      	 := p_recurring_bonus_percent ;         -- added for NL Phase 2B
  l_rec.non_recurring_bonus_percent  	 := p_non_recurring_bonus_percent ;     -- added for NL Phase 2B
  l_rec.recurring_bonus_balance      	 := p_recurring_bonus_balance  ;        -- added for NL Phase 2B
  l_rec.non_recurring_bonus_balance  	 := p_non_recurring_bonus_balance;      -- added for NL Phase 2B
  l_rec.std_tax_reduction            	 := p_std_tax_reduction;                -- added for NL Phase 2B
  l_rec.spl_tax_reduction            	 := p_spl_tax_reduction;                -- added for NL Phase 2B
  l_rec.sig_sal_spl_tax_reduction    	 := p_sig_sal_spl_tax_reduction;        -- added for NL Phase 2B
  l_rec.sig_sal_non_tax_reduction    	 := p_sig_sal_non_tax_reduction ;       -- added for NL Phase 2B
  l_rec.sig_sal_std_tax_reduction    	 := p_sig_sal_std_tax_reduction;        -- added for NL Phase 2B
  l_rec.sii_std_tax_reduction        	 := p_sii_std_tax_reduction;            -- added for NL Phase 2B
  l_rec.sii_spl_tax_reduction        	 := p_sii_spl_tax_reduction;            -- added for NL Phase 2B
  l_rec.sii_non_tax_reduction        	 := p_sii_non_tax_reduction ;           -- added for NL Phase 2B
  l_rec.previous_year_bonus_included 	 := p_previous_year_bonus_included;     -- added for NL Phase 2B
  l_rec.recurring_bonus_period   	 := p_recurring_bonus_period;           -- added for NL Phase 2B
  l_rec.non_recurring_bonus_period 	 := p_non_recurring_bonus_period;      -- added for NL Phase 2B
  l_rec.ee_age_threshold                 := p_ee_age_threshold;                 -- added for ABP TAR fixes
  l_rec.er_age_threshold                 := p_er_age_threshold;                 -- added for ABP TAR fixes
  l_rec.ee_age_contribution              := p_ee_age_contribution;              -- added for ABP TAR fixes
  l_rec.er_age_contribution              := p_er_age_contribution;              -- added for ABP TAR fixes
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--


end pqp_pty_shd;


/
