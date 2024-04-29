--------------------------------------------------------
--  DDL for Package Body PAY_PSD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PSD_SHD" as
/* $Header: pypsdrhi.pkb 120.1 2005/12/08 05:08 ssekhar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_psd_shd.';  -- Global package name
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
  If (p_constraint_name = 'PAY_PL_SII_DETAILS_F_PK') Then
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
  ,p_sii_details_id                   in number
  ,p_object_version_number            in number
  ) Return Boolean Is
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
     sii_details_id
    ,effective_start_date
    ,effective_end_date
    ,per_or_asg_id
    ,business_group_id
    ,contract_category
    ,object_version_number
    ,emp_social_security_info
    ,old_age_contribution
    ,pension_contribution
    ,sickness_contribution
    ,work_injury_contribution
    ,labor_contribution
    ,health_contribution
    ,unemployment_contribution
    ,old_age_cont_end_reason
    ,pension_cont_end_reason
    ,sickness_cont_end_reason
    ,work_injury_cont_end_reason
    ,labor_fund_cont_end_reason
    ,health_cont_end_reason
    ,unemployment_cont_end_reason
    ,program_id
    ,program_login_id
    ,program_application_id
    ,request_id
    from        pay_pl_sii_details_f
    where       sii_details_id = p_sii_details_id
    and         p_effective_date
    between     effective_start_date and effective_end_date;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_effective_date is null or
      p_sii_details_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_sii_details_id =
        pay_psd_shd.g_old_rec.sii_details_id and
        p_object_version_number =
        pay_psd_shd.g_old_rec.object_version_number
) Then
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
      Fetch C_Sel1 Into pay_psd_shd.g_old_rec;
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
          <> pay_psd_shd.g_old_rec.object_version_number) Then
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
  ,p_correction_start_date	OUT NOCOPY DATE
  ,p_correction_end_date	OUT NOCOPY DATE
  ,p_update_start_date		OUT NOCOPY DATE
  ,p_update_end_date		OUT NOCOPY DATE
  ,p_override_start_date	OUT NOCOPY DATE
  ,p_override_end_date		OUT NOCOPY DATE
  ,p_upd_chg_start_date		OUT NOCOPY DATE
  ,p_upd_chg_end_date		OUT NOCOPY DATE
  ) is
--
  l_proc        varchar2(72) := g_package||'find_dt_upd_modes';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_upd_modes_and_dates
    (p_effective_date        => p_effective_date
    ,p_base_table_name       => 'pay_pl_sii_details_f'
    ,p_base_key_column       => 'sii_details_id'
    ,p_base_key_value        => p_base_key_value
    ,p_correction            => p_correction
    ,p_update                => p_update
    ,p_update_override       => p_update_override
    ,p_update_change_insert  => p_update_change_insert
    ,p_correction_start_date	=> p_correction_start_date
    ,p_correction_end_date		=> p_correction_end_date
    ,p_update_start_date		=> p_update_start_date
    ,p_update_end_date		=> p_update_end_date
    ,p_override_start_date		=> p_override_start_date
    ,p_override_end_date		=> p_override_end_date
    ,p_upd_chg_start_date		=> p_upd_chg_start_date
    ,p_upd_chg_end_date		=> p_upd_chg_end_date
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
   ,p_base_table_name               => 'pay_pl_sii_details_f'
   ,p_base_key_column               => 'sii_details_id'
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
      (p_base_table_name    => 'pay_pl_sii_details_f'
      ,p_base_key_column    => 'sii_details_id'
      ,p_base_key_value     => p_base_key_value
      );
  --
  hr_utility.set_location(l_proc, 10);
  --
--
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  pay_pl_sii_details_f t
  set     t.effective_end_date    = p_new_effective_end_date
    ,     t.object_version_number = l_object_version_number
  where   t.sii_details_id        = p_base_key_value
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
  ,p_sii_details_id                   in number
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
     sii_details_id
    ,effective_start_date
    ,effective_end_date
    ,per_or_asg_id
    ,business_group_id
    ,contract_category
    ,object_version_number
    ,emp_social_security_info
    ,old_age_contribution
    ,pension_contribution
    ,sickness_contribution
    ,work_injury_contribution
    ,labor_contribution
    ,health_contribution
    ,unemployment_contribution
    ,old_age_cont_end_reason
    ,pension_cont_end_reason
    ,sickness_cont_end_reason
    ,work_injury_cont_end_reason
    ,labor_fund_cont_end_reason
    ,health_cont_end_reason
    ,unemployment_cont_end_reason
    ,program_id
    ,program_login_id
    ,program_application_id
    ,request_id
    from    pay_pl_sii_details_f
    where   sii_details_id = p_sii_details_id
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
                            ,p_argument       => 'sii_details_id'
                            ,p_argument_value => p_sii_details_id
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
    Fetch C_Sel1 Into pay_psd_shd.g_old_rec;
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
          <> pay_psd_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
    End If;
    --
    --
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --

 if g_old_rec.contract_category in ('CIVIL','TERM_NORMAL','LUMP','F_LUMP') then

  -- Here we are locking the corresponding Assignment record
  -- a) if the Contract category is "CIVIL" since the SII record for Civil Contracts are stored at the Assignment level
  -- b) If the Contract category is 'Normal' and the Assignment is terminated. This is cos for Normal Terminated assignments
  -- the SII record is stored at the Assignment level.
  -- c) if the Contract category is "LUMP" or "F_LUMP"

    dt_api.validate_dt_mode
      (p_effective_date          => p_effective_date
      ,p_datetrack_mode          => p_datetrack_mode
      ,p_base_table_name         => 'pay_pl_sii_details_f'
      ,p_base_key_column         => 'sii_details_id'
      ,p_base_key_value          => p_sii_details_id
      ,p_parent_table_name1      => 'per_all_assignments_f'
      ,p_parent_key_column1      => 'assignment_id'
      ,p_parent_key_value1       => g_old_rec.per_or_asg_id
      ,p_enforce_foreign_locking => true
      ,p_validation_start_date   => l_validation_start_date
      ,p_validation_end_date     => l_validation_end_date
      );

 elsif g_old_rec.contract_category = 'NORMAL' then

  -- Here we are locking the corresponding Person record if the Contract category is
  -- "NORMAL" since the SII record for Normal Contracts are stored at the Person level

   dt_api.validate_dt_mode
      (p_effective_date          => p_effective_date
      ,p_datetrack_mode          => p_datetrack_mode
      ,p_base_table_name         => 'pay_pl_sii_details_f'
      ,p_base_key_column         => 'sii_details_id'
      ,p_base_key_value          => p_sii_details_id
      ,p_parent_table_name1      => 'per_people_f'
      ,p_parent_key_column1      => 'person_id'
      ,p_parent_key_value1       => g_old_rec.per_or_asg_id
      ,p_enforce_foreign_locking => true
      ,p_validation_start_date   => l_validation_start_date
      ,p_validation_end_date     => l_validation_end_date
      );

  end if;


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
    fnd_message.set_token('TABLE_NAME', 'pay_pl_sii_details_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_sii_details_id                 in number
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_per_or_asg_id                  in number
  ,p_business_group_id              in number
  ,p_contract_category              in varchar2
  ,p_object_version_number          in number
  ,p_emp_social_security_info       in varchar2
  ,p_old_age_contribution           in varchar2
  ,p_pension_contribution           in varchar2
  ,p_sickness_contribution          in varchar2
  ,p_work_injury_contribution       in varchar2
  ,p_labor_contribution             in varchar2
  ,p_health_contribution            in varchar2
  ,p_unemployment_contribution      in varchar2
  ,p_old_age_cont_end_reason        in varchar2
  ,p_pension_cont_end_reason        in varchar2
  ,p_sickness_cont_end_reason       in varchar2
  ,p_work_injury_cont_end_reason    in varchar2
  ,p_labor_fund_cont_end_reason     in varchar2
  ,p_health_cont_end_reason         in varchar2
  ,p_unemployment_cont_end_reason   in varchar2
  ,p_program_id                     in number
  ,p_program_login_id               in number
  ,p_program_application_id         in number
  ,p_request_id                     in number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.sii_details_id                   := p_sii_details_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.per_or_asg_id                    := p_per_or_asg_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.contract_category                := p_contract_category;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.emp_social_security_info         := p_emp_social_security_info;
  l_rec.old_age_contribution             := p_old_age_contribution;
  l_rec.pension_contribution             := p_pension_contribution;
  l_rec.sickness_contribution            := p_sickness_contribution;
  l_rec.work_injury_contribution         := p_work_injury_contribution;
  l_rec.labor_contribution               := p_labor_contribution;
  l_rec.health_contribution              := p_health_contribution;
  l_rec.unemployment_contribution        := p_unemployment_contribution;
  l_rec.old_age_cont_end_reason          := p_old_age_cont_end_reason;
  l_rec.pension_cont_end_reason          := p_pension_cont_end_reason;
  l_rec.sickness_cont_end_reason         := p_sickness_cont_end_reason;
  l_rec.work_injury_cont_end_reason      := p_work_injury_cont_end_reason;
  l_rec.labor_fund_cont_end_reason       := p_labor_fund_cont_end_reason;
  l_rec.health_cont_end_reason           := p_health_cont_end_reason;
  l_rec.unemployment_cont_end_reason     := p_unemployment_cont_end_reason;
  l_rec.program_id                       := p_program_id;
  l_rec.program_login_id                 := p_program_login_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.request_id                       := p_request_id;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pay_psd_shd;

/
