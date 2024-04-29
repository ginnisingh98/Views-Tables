--------------------------------------------------------
--  DDL for Package Body PQP_AAT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_AAT_SHD" as
/* $Header: pqaatrhi.pkb 120.2.12010000.3 2009/07/01 10:58:37 dchindar ship $ */
--
-- ---------------------------------------------------------------------------+
-- |                     Private Global Definitions                           |
-- ---------------------------------------------------------------------------+
--
g_package  varchar2(33) := '  pqp_aat_shd.';  -- Global package name
--
-- ---------------------------------------------------------------------------+
-- |------------------------< return_api_dml_status >-------------------------|
-- ---------------------------------------------------------------------------+
Function return_api_dml_status Return Boolean Is
--
Begin
  --
  Return (nvl(g_api_dml, false));
  --
End return_api_dml_status;
--
-- ---------------------------------------------------------------------------+
-- |---------------------------< constraint_error >---------------------------|
-- ---------------------------------------------------------------------------+
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc        varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'PQP_ASSIGNMENT_ATTRIBUTES_F_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  Elsif (p_constraint_name = 'PQP_INVALID_JOB_STATUS') Then
    fnd_message.set_name('PQP', 'PQP_230561_JOB_STATUS_INVALID');
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
-- ---------------------------------------------------------------------------+
-- |-----------------------------< api_updating >-----------------------------|
-- ---------------------------------------------------------------------------+
Function api_updating
  (p_effective_date                   in date
  ,p_assignment_attribute_id          in number
  ,p_object_version_number            in number
  ) Return Boolean Is
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
     assignment_attribute_id
    ,effective_start_date
    ,effective_end_date
    ,business_group_id
    ,assignment_id
    ,contract_type
    ,work_pattern
    ,start_day
    ,object_version_number
    ,primary_company_car
    ,primary_car_fuel_benefit
    ,primary_class_1a
    ,primary_capital_contribution
    ,primary_private_contribution
    ,secondary_company_car
    ,secondary_car_fuel_benefit
    ,secondary_class_1a
    ,secondary_capital_contribution
    ,secondary_private_contribution
    ,company_car_calc_method
    ,company_car_rates_table_id
    ,company_car_secondary_table_id
    ,private_car
    ,private_car_calc_method
    ,private_car_rates_table_id
    ,private_car_essential_table_id
    ,tp_is_teacher
    ,tp_headteacher_grp_code --added for head Teacher seconded location for salary scale calculation
    ,tp_safeguarded_grade
    ,tp_safeguarded_grade_id
    ,tp_safeguarded_rate_type
    ,tp_safeguarded_rate_id
    ,tp_safeguarded_spinal_point_id
    ,tp_elected_pension
    ,tp_fast_track
    ,aat_attribute_category
    ,aat_attribute1
    ,aat_attribute2
    ,aat_attribute3
    ,aat_attribute4
    ,aat_attribute5
    ,aat_attribute6
    ,aat_attribute7
    ,aat_attribute8
    ,aat_attribute9
    ,aat_attribute10
    ,aat_attribute11
    ,aat_attribute12
    ,aat_attribute13
    ,aat_attribute14
    ,aat_attribute15
    ,aat_attribute16
    ,aat_attribute17
    ,aat_attribute18
    ,aat_attribute19
    ,aat_attribute20
    ,aat_information_category
    ,aat_information1
    ,aat_information2
    ,aat_information3
    ,aat_information4
    ,aat_information5
    ,aat_information6
    ,aat_information7
    ,aat_information8
    ,aat_information9
    ,aat_information10
    ,aat_information11
    ,aat_information12
    ,aat_information13
    ,aat_information14
    ,aat_information15
    ,aat_information16
    ,aat_information17
    ,aat_information18
    ,aat_information19
    ,aat_information20
    ,lgps_process_flag
    ,lgps_exclusion_type
    ,lgps_pensionable_pay
    ,lgps_trans_arrang_flag
    ,lgps_membership_number
    from        pqp_assignment_attributes_f
    where       assignment_attribute_id = p_assignment_attribute_id
    and         p_effective_date
    between     effective_start_date and effective_end_date;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_effective_date is null or
      p_assignment_attribute_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_assignment_attribute_id =
        pqp_aat_shd.g_old_rec.assignment_attribute_id and
        p_object_version_number =
        pqp_aat_shd.g_old_rec.object_version_number) Then
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
      Fetch C_Sel1 Into pqp_aat_shd.g_old_rec;
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
          <> pqp_aat_shd.g_old_rec.object_version_number) Then
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
-- ---------------------------------------------------------------------------+
-- |---------------------------< find_dt_upd_modes >--------------------------|
-- ---------------------------------------------------------------------------+
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
    ,p_base_table_name       => 'pqp_assignment_attributes_f'
    ,p_base_key_column       => 'assignment_attribute_id'
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
-- ---------------------------------------------------------------------------+
-- |---------------------------< find_dt_del_modes >--------------------------|
-- ---------------------------------------------------------------------------+
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
   ,p_base_table_name               => 'pqp_assignment_attributes_f'
   ,p_base_key_column               => 'assignment_attribute_id'
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
-- ---------------------------------------------------------------------------+
-- |-----------------------< upd_effective_end_date >-------------------------|
-- ---------------------------------------------------------------------------+
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
      (p_base_table_name    => 'pqp_assignment_attributes_f'
      ,p_base_key_column    => 'assignment_attribute_id'
      ,p_base_key_value     => p_base_key_value
      );
  --
  hr_utility.set_location(l_proc, 10);
  pqp_aat_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  pqp_assignment_attributes_f t
  set     t.effective_end_date    = p_new_effective_end_date
    ,     t.object_version_number = l_object_version_number
  where   t.assignment_attribute_id        = p_base_key_value
  and     p_effective_date
  between t.effective_start_date and t.effective_end_date;
  --
  pqp_aat_shd.g_api_dml := false;   -- Unset the api dml status
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When Others Then
    pqp_aat_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
--
End upd_effective_end_date;
--
-- ---------------------------------------------------------------------------+
-- |---------------------------------< lck >----------------------------------|
-- ---------------------------------------------------------------------------+
Procedure lck
  (p_effective_date                   in date
  ,p_datetrack_mode                   in varchar2
  ,p_assignment_attribute_id          in number
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
     assignment_attribute_id
    ,effective_start_date
    ,effective_end_date
    ,business_group_id
    ,assignment_id
    ,contract_type
    ,work_pattern
    ,start_day
    ,object_version_number
    ,primary_company_car
    ,primary_car_fuel_benefit
    ,primary_class_1a
    ,primary_capital_contribution
    ,primary_private_contribution
    ,secondary_company_car
    ,secondary_car_fuel_benefit
    ,secondary_class_1a
    ,secondary_capital_contribution
    ,secondary_private_contribution
    ,company_car_calc_method
    ,company_car_rates_table_id
    ,company_car_secondary_table_id
    ,private_car
    ,private_car_calc_method
    ,private_car_rates_table_id
    ,private_car_essential_table_id
    ,tp_is_teacher
    ,tp_headteacher_grp_code --added for head Teacher seconded location for salary scale calculation
    ,tp_safeguarded_grade
    ,tp_safeguarded_grade_id
    ,tp_safeguarded_rate_type
    ,tp_safeguarded_rate_id
    ,tp_safeguarded_spinal_point_id
    ,tp_elected_pension
    ,tp_fast_track
    ,aat_attribute_category
    ,aat_attribute1
    ,aat_attribute2
    ,aat_attribute3
    ,aat_attribute4
    ,aat_attribute5
    ,aat_attribute6
    ,aat_attribute7
    ,aat_attribute8
    ,aat_attribute9
    ,aat_attribute10
    ,aat_attribute11
    ,aat_attribute12
    ,aat_attribute13
    ,aat_attribute14
    ,aat_attribute15
    ,aat_attribute16
    ,aat_attribute17
    ,aat_attribute18
    ,aat_attribute19
    ,aat_attribute20
    ,aat_information_category
    ,aat_information1
    ,aat_information2
    ,aat_information3
    ,aat_information4
    ,aat_information5
    ,aat_information6
    ,aat_information7
    ,aat_information8
    ,aat_information9
    ,aat_information10
    ,aat_information11
    ,aat_information12
    ,aat_information13
    ,aat_information14
    ,aat_information15
    ,aat_information16
    ,aat_information17
    ,aat_information18
    ,aat_information19
    ,aat_information20
    ,lgps_process_flag
    ,lgps_exclusion_type
    ,lgps_pensionable_pay
    ,lgps_trans_arrang_flag
    ,lgps_membership_number
    from    pqp_assignment_attributes_f
    where   assignment_attribute_id = p_assignment_attribute_id
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
                            ,p_argument       => 'assignment_attribute_id'
                            ,p_argument_value => p_assignment_attribute_id
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
    Fetch C_Sel1 Into pqp_aat_shd.g_old_rec;
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
          <> pqp_aat_shd.g_old_rec.object_version_number) Then
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
      ,p_base_table_name         => 'pqp_assignment_attributes_f'
      ,p_base_key_column         => 'assignment_attribute_id'
      ,p_base_key_value          => p_assignment_attribute_id
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
    fnd_message.set_token('TABLE_NAME', 'pqp_assignment_attributes_f');
    fnd_message.raise_error;
End lck;
--
-- ---------------------------------------------------------------------------+
-- |-----------------------------< convert_args >-----------------------------|
-- ---------------------------------------------------------------------------+
Function convert_args
  (p_assignment_attribute_id        in number
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_business_group_id              in number
  ,p_assignment_id                  in number
  ,p_contract_type                  in varchar2
  ,p_work_pattern                   in varchar2
  ,p_start_day                      in varchar2
  ,p_object_version_number          in number
  ,p_primary_company_car            in number
  ,p_primary_car_fuel_benefit       in varchar2
  ,p_primary_class_1a               in varchar2
  ,p_primary_capital_contribution   in number
  ,p_primary_private_contribution   in number
  ,p_secondary_company_car          in number
  ,p_secondary_car_fuel_benefit     in varchar2
  ,p_secondary_class_1a             in varchar2
  ,p_secondary_capital_contributi   in number
  ,p_secondary_private_contributi   in number
  ,p_company_car_calc_method        in varchar2
  ,p_company_car_rates_table_id     in number
  ,p_company_car_secondary_table    in number
  ,p_private_car                    in number
  ,p_private_car_calc_method        in varchar2
  ,p_private_car_rates_table_id     in number
  ,p_private_car_essential_table    in number
  ,p_tp_is_teacher                  in varchar2
  ,p_tp_headteacher_grp_code        in number  --added for head Teacher seconded location for salary scale calculation
  ,p_tp_safeguarded_grade           in varchar2
  ,p_tp_safeguarded_grade_id        in number
  ,p_tp_safeguarded_rate_type       in varchar2
  ,p_tp_safeguarded_rate_id         in number
  ,p_tp_spinal_point_id             in number
  ,p_tp_elected_pension             in varchar2
  ,p_tp_fast_track                  in varchar2
  ,p_aat_attribute_category         in varchar2
  ,p_aat_attribute1                 in varchar2
  ,p_aat_attribute2                 in varchar2
  ,p_aat_attribute3                 in varchar2
  ,p_aat_attribute4                 in varchar2
  ,p_aat_attribute5                 in varchar2
  ,p_aat_attribute6                 in varchar2
  ,p_aat_attribute7                 in varchar2
  ,p_aat_attribute8                 in varchar2
  ,p_aat_attribute9                 in varchar2
  ,p_aat_attribute10                in varchar2
  ,p_aat_attribute11                in varchar2
  ,p_aat_attribute12                in varchar2
  ,p_aat_attribute13                in varchar2
  ,p_aat_attribute14                in varchar2
  ,p_aat_attribute15                in varchar2
  ,p_aat_attribute16                in varchar2
  ,p_aat_attribute17                in varchar2
  ,p_aat_attribute18                in varchar2
  ,p_aat_attribute19                in varchar2
  ,p_aat_attribute20                in varchar2
  ,p_aat_information_category       in varchar2
  ,p_aat_information1               in varchar2
  ,p_aat_information2               in varchar2
  ,p_aat_information3               in varchar2
  ,p_aat_information4               in varchar2
  ,p_aat_information5               in varchar2
  ,p_aat_information6               in varchar2
  ,p_aat_information7               in varchar2
  ,p_aat_information8               in varchar2
  ,p_aat_information9               in varchar2
  ,p_aat_information10              in varchar2
  ,p_aat_information11              in varchar2
  ,p_aat_information12              in varchar2
  ,p_aat_information13              in varchar2
  ,p_aat_information14              in varchar2
  ,p_aat_information15              in varchar2
  ,p_aat_information16              in varchar2
  ,p_aat_information17              in varchar2
  ,p_aat_information18              in varchar2
  ,p_aat_information19              in varchar2
  ,p_aat_information20              in varchar2
  ,p_lgps_process_flag              in varchar2
  ,p_lgps_exclusion_type            in varchar2
  ,p_lgps_pensionable_pay           in varchar2
  ,p_lgps_trans_arrang_flag         in varchar2
  ,p_lgps_membership_number         in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.assignment_attribute_id          := p_assignment_attribute_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.assignment_id                    := p_assignment_id;
  l_rec.contract_type                    := p_contract_type;
  l_rec.work_pattern                     := p_work_pattern;
  l_rec.start_day                        := p_start_day;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.primary_company_car              := p_primary_company_car;
  l_rec.primary_car_fuel_benefit         := p_primary_car_fuel_benefit;
  l_rec.primary_class_1a                 := p_primary_class_1a;
  l_rec.primary_capital_contribution     := p_primary_capital_contribution;
  l_rec.primary_private_contribution     := p_primary_private_contribution;
  l_rec.secondary_company_car            := p_secondary_company_car;
  l_rec.secondary_car_fuel_benefit       := p_secondary_car_fuel_benefit;
  l_rec.secondary_class_1a               := p_secondary_class_1a;
  l_rec.secondary_capital_contribution   := p_secondary_capital_contributi;
  l_rec.secondary_private_contribution   := p_secondary_private_contributi;
  l_rec.company_car_calc_method          := p_company_car_calc_method;
  l_rec.company_car_rates_table_id       := p_company_car_rates_table_id;
  l_rec.company_car_secondary_table_id   := p_company_car_secondary_table;
  l_rec.private_car                      := p_private_car;
  l_rec.private_car_calc_method          := p_private_car_calc_method;
  l_rec.private_car_rates_table_id       := p_private_car_rates_table_id;
  l_rec.private_car_essential_table_id   := p_private_car_essential_table;
  l_rec.tp_is_teacher                    := p_tp_is_teacher;
  l_rec.tp_headteacher_grp_code          := p_tp_headteacher_grp_code; --added for head Teacher seconded location for salary scale calculation
  l_rec.tp_safeguarded_grade             := p_tp_safeguarded_grade;
  l_rec.tp_safeguarded_grade_id          := p_tp_safeguarded_grade_id;
  l_rec.tp_safeguarded_rate_type         := p_tp_safeguarded_rate_type;
  l_rec.tp_safeguarded_rate_id           := p_tp_safeguarded_rate_id;
  l_rec.tp_safeguarded_spinal_point_id   := p_tp_spinal_point_id;
  l_rec.tp_elected_pension               := p_tp_elected_pension;
  l_rec.tp_fast_track                    := p_tp_fast_track;
  l_rec.aat_attribute_category           := p_aat_attribute_category;
  l_rec.aat_attribute1                   := p_aat_attribute1;
  l_rec.aat_attribute2                   := p_aat_attribute2;
  l_rec.aat_attribute3                   := p_aat_attribute3;
  l_rec.aat_attribute4                   := p_aat_attribute4;
  l_rec.aat_attribute5                   := p_aat_attribute5;
  l_rec.aat_attribute6                   := p_aat_attribute6;
  l_rec.aat_attribute7                   := p_aat_attribute7;
  l_rec.aat_attribute8                   := p_aat_attribute8;
  l_rec.aat_attribute9                   := p_aat_attribute9;
  l_rec.aat_attribute10                  := p_aat_attribute10;
  l_rec.aat_attribute11                  := p_aat_attribute11;
  l_rec.aat_attribute12                  := p_aat_attribute12;
  l_rec.aat_attribute13                  := p_aat_attribute13;
  l_rec.aat_attribute14                  := p_aat_attribute14;
  l_rec.aat_attribute15                  := p_aat_attribute15;
  l_rec.aat_attribute16                  := p_aat_attribute16;
  l_rec.aat_attribute17                  := p_aat_attribute17;
  l_rec.aat_attribute18                  := p_aat_attribute18;
  l_rec.aat_attribute19                  := p_aat_attribute19;
  l_rec.aat_attribute20                  := p_aat_attribute20;
  l_rec.aat_information_category         := p_aat_information_category;
  l_rec.aat_information1                 := p_aat_information1;
  l_rec.aat_information2                 := p_aat_information2;
  l_rec.aat_information3                 := p_aat_information3;
  l_rec.aat_information4                 := p_aat_information4;
  l_rec.aat_information5                 := p_aat_information5;
  l_rec.aat_information6                 := p_aat_information6;
  l_rec.aat_information7                 := p_aat_information7;
  l_rec.aat_information8                 := p_aat_information8;
  l_rec.aat_information9                 := p_aat_information9;
  l_rec.aat_information10                := p_aat_information10;
  l_rec.aat_information11                := p_aat_information11;
  l_rec.aat_information12                := p_aat_information12;
  l_rec.aat_information13                := p_aat_information13;
  l_rec.aat_information14                := p_aat_information14;
  l_rec.aat_information15                := p_aat_information15;
  l_rec.aat_information16                := p_aat_information16;
  l_rec.aat_information17                := p_aat_information17;
  l_rec.aat_information18                := p_aat_information18;
  l_rec.aat_information19                := p_aat_information19;
  l_rec.aat_information20                := p_aat_information20;
  l_rec.lgps_process_flag                := p_lgps_process_flag;
  l_rec.lgps_exclusion_type              := p_lgps_exclusion_type;
  l_rec.lgps_pensionable_pay             := p_lgps_pensionable_pay;
  l_rec.lgps_trans_arrang_flag           := p_lgps_trans_arrang_flag;
  l_rec.lgps_membership_number           := p_lgps_membership_number;

  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pqp_aat_shd;

/
