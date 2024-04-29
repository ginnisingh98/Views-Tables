--------------------------------------------------------
--  DDL for Package Body PQP_VAL_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VAL_SHD" as
/* $Header: pqvalrhi.pkb 120.0.12010000.3 2008/08/08 07:22:41 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_val_shd.';  -- Global package name
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
  If (p_constraint_name = 'PQP_VEHICLE_ALLOCATIONS_F_PK') Then
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
  ,p_vehicle_allocation_id            in number
  ,p_object_version_number            in number
  ) Return Boolean Is
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
     vehicle_allocation_id
    ,effective_start_date
    ,effective_end_date
    ,assignment_id
    ,business_group_id
    ,across_assignments
    ,vehicle_repository_id
    ,usage_type
    ,capital_contribution
    ,private_contribution
    ,default_vehicle
    ,fuel_card
    ,fuel_card_number
    ,calculation_method
    ,rates_table_id
    ,element_type_id
    ,private_use_flag
    ,insurance_number
    ,insurance_expiry_date
    ,val_attribute_category
    ,val_attribute1
    ,val_attribute2
    ,val_attribute3
    ,val_attribute4
    ,val_attribute5
    ,val_attribute6
    ,val_attribute7
    ,val_attribute8
    ,val_attribute9
    ,val_attribute10
    ,val_attribute11
    ,val_attribute12
    ,val_attribute13
    ,val_attribute14
    ,val_attribute15
    ,val_attribute16
    ,val_attribute17
    ,val_attribute18
    ,val_attribute19
    ,val_attribute20
    ,val_information_category
    ,val_information1
    ,val_information2
    ,val_information3
    ,val_information4
    ,val_information5
    ,val_information6
    ,val_information7
    ,val_information8
    ,val_information9
    ,val_information10
    ,val_information11
    ,val_information12
    ,val_information13
    ,val_information14
    ,val_information15
    ,val_information16
    ,val_information17
    ,val_information18
    ,val_information19
    ,val_information20
    ,object_version_number
    ,fuel_benefit
    ,sliding_rates_info
    from        pqp_vehicle_allocations_f
    where       vehicle_allocation_id = p_vehicle_allocation_id
    and         p_effective_date
    between     effective_start_date and effective_end_date;
--
  l_fct_ret     boolean;
--
Begin
  --

  If (p_effective_date is null or
      p_vehicle_allocation_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_vehicle_allocation_id =
        pqp_val_shd.g_old_rec.vehicle_allocation_id and
        p_object_version_number =
        pqp_val_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pqp_val_shd.g_old_rec;
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
          <> pqp_val_shd.g_old_rec.object_version_number) Then
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
-----------------------------------------------------------------------------
Function pqp_get_global_msg_value return varchar2 is
begin
  return pqp_val_shd.g_message ;
end ;


------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- |---------------------------< find_dt_upd_modes >--------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_upd_modes
  (p_effective_date         in  date
  ,p_base_key_value         in  number
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
    ,p_base_table_name       => 'pqp_vehicle_allocations_f'
    ,p_base_key_column       => 'vehicle_allocation_id'
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
   ,p_base_table_name               => 'pqp_vehicle_allocations_f'
   ,p_base_key_column               => 'vehicle_allocation_id'
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
  ,p_object_version_number            out nocopy number
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
      (p_base_table_name    => 'pqp_vehicle_allocations_f'
      ,p_base_key_column    => 'vehicle_allocation_id'
      ,p_base_key_value     => p_base_key_value
      );
  --
  hr_utility.set_location(l_proc, 10);
  --
--
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  pqp_vehicle_allocations_f t
  set     t.effective_end_date    = p_new_effective_end_date
    ,     t.object_version_number = l_object_version_number
  where   t.vehicle_allocation_id        = p_base_key_value
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
  ,p_vehicle_allocation_id            in number
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
     vehicle_allocation_id
    ,effective_start_date
    ,effective_end_date
    ,assignment_id
    ,business_group_id
    ,across_assignments
    ,vehicle_repository_id
    ,usage_type
    ,capital_contribution
    ,private_contribution
    ,default_vehicle
    ,fuel_card
    ,fuel_card_number
    ,calculation_method
    ,rates_table_id
    ,element_type_id
    ,private_use_flag
    ,insurance_number
    ,insurance_expiry_date
    ,val_attribute_category
    ,val_attribute1
    ,val_attribute2
    ,val_attribute3
    ,val_attribute4
    ,val_attribute5
    ,val_attribute6
    ,val_attribute7
    ,val_attribute8
    ,val_attribute9
    ,val_attribute10
    ,val_attribute11
    ,val_attribute12
    ,val_attribute13
    ,val_attribute14
    ,val_attribute15
    ,val_attribute16
    ,val_attribute17
    ,val_attribute18
    ,val_attribute19
    ,val_attribute20
    ,val_information_category
    ,val_information1
    ,val_information2
    ,val_information3
    ,val_information4
    ,val_information5
    ,val_information6
    ,val_information7
    ,val_information8
    ,val_information9
    ,val_information10
    ,val_information11
    ,val_information12
    ,val_information13
    ,val_information14
    ,val_information15
    ,val_information16
    ,val_information17
    ,val_information18
    ,val_information19
    ,val_information20
    ,object_version_number
    ,fuel_benefit
    ,sliding_rates_info
    from    pqp_vehicle_allocations_f
    where   vehicle_allocation_id = p_vehicle_allocation_id
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
                            ,p_argument       => 'vehicle_allocation_id'
                            ,p_argument_value => p_vehicle_allocation_id
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
    Fetch C_Sel1 Into pqp_val_shd.g_old_rec;
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
          <> pqp_val_shd.g_old_rec.object_version_number) Then
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
      ,p_base_table_name         => 'pqp_vehicle_allocations_f'
      ,p_base_key_column         => 'vehicle_allocation_id'
      ,p_base_key_value          => p_vehicle_allocation_id
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
    fnd_message.set_token('TABLE_NAME', 'pqp_vehicle_allocations_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_vehicle_allocation_id          in number
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_assignment_id                  in number
  ,p_business_group_id              in number
  ,p_across_assignments             in varchar2
  ,p_vehicle_repository_id          in number
  ,p_usage_type                     in varchar2
  ,p_capital_contribution           in number
  ,p_private_contribution           in number
  ,p_default_vehicle                in varchar2
  ,p_fuel_card                      in varchar2
  ,p_fuel_card_number               in varchar2
  ,p_calculation_method             in varchar2
  ,p_rates_table_id                 in number
  ,p_element_type_id                in number
  ,p_private_use_flag               in varchar2
  ,p_insurance_number               in varchar2
  ,p_insurance_expiry_date          in date
  ,p_val_attribute_category         in varchar2
  ,p_val_attribute1                 in varchar2
  ,p_val_attribute2                 in varchar2
  ,p_val_attribute3                 in varchar2
  ,p_val_attribute4                 in varchar2
  ,p_val_attribute5                 in varchar2
  ,p_val_attribute6                 in varchar2
  ,p_val_attribute7                 in varchar2
  ,p_val_attribute8                 in varchar2
  ,p_val_attribute9                 in varchar2
  ,p_val_attribute10                in varchar2
  ,p_val_attribute11                in varchar2
  ,p_val_attribute12                in varchar2
  ,p_val_attribute13                in varchar2
  ,p_val_attribute14                in varchar2
  ,p_val_attribute15                in varchar2
  ,p_val_attribute16                in varchar2
  ,p_val_attribute17                in varchar2
  ,p_val_attribute18                in varchar2
  ,p_val_attribute19                in varchar2
  ,p_val_attribute20                in varchar2
  ,p_val_information_category       in varchar2
  ,p_val_information1               in varchar2
  ,p_val_information2               in varchar2
  ,p_val_information3               in varchar2
  ,p_val_information4               in varchar2
  ,p_val_information5               in varchar2
  ,p_val_information6               in varchar2
  ,p_val_information7               in varchar2
  ,p_val_information8               in varchar2
  ,p_val_information9               in varchar2
  ,p_val_information10              in varchar2
  ,p_val_information11              in varchar2
  ,p_val_information12              in varchar2
  ,p_val_information13              in varchar2
  ,p_val_information14              in varchar2
  ,p_val_information15              in varchar2
  ,p_val_information16              in varchar2
  ,p_val_information17              in varchar2
  ,p_val_information18              in varchar2
  ,p_val_information19              in varchar2
  ,p_val_information20              in varchar2
  ,p_object_version_number          in number
  ,p_fuel_benefit                   in varchar2
  ,p_sliding_rates_info                  in varchar2

  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.vehicle_allocation_id            := p_vehicle_allocation_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.assignment_id                    := p_assignment_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.across_assignments               := p_across_assignments;
  l_rec.vehicle_repository_id            := p_vehicle_repository_id;
  l_rec.usage_type                       := p_usage_type;
  l_rec.capital_contribution             := p_capital_contribution;
  l_rec.private_contribution             := p_private_contribution;
  l_rec.default_vehicle                  := p_default_vehicle;
  l_rec.fuel_card                        := p_fuel_card;
  l_rec.fuel_card_number                 := p_fuel_card_number;
  l_rec.calculation_method               := p_calculation_method;
  l_rec.rates_table_id                   := p_rates_table_id;
  l_rec.element_type_id                  := p_element_type_id;
  l_rec.private_use_flag                 := p_private_use_flag;
  l_rec.insurance_number                 := p_insurance_number;
  l_rec.insurance_expiry_date            := p_insurance_expiry_date;
  l_rec.val_attribute_category           := p_val_attribute_category;
  l_rec.val_attribute1                   := p_val_attribute1;
  l_rec.val_attribute2                   := p_val_attribute2;
  l_rec.val_attribute3                   := p_val_attribute3;
  l_rec.val_attribute4                   := p_val_attribute4;
  l_rec.val_attribute5                   := p_val_attribute5;
  l_rec.val_attribute6                   := p_val_attribute6;
  l_rec.val_attribute7                   := p_val_attribute7;
  l_rec.val_attribute8                   := p_val_attribute8;
  l_rec.val_attribute9                   := p_val_attribute9;
  l_rec.val_attribute10                  := p_val_attribute10;
  l_rec.val_attribute11                  := p_val_attribute11;
  l_rec.val_attribute12                  := p_val_attribute12;
  l_rec.val_attribute13                  := p_val_attribute13;
  l_rec.val_attribute14                  := p_val_attribute14;
  l_rec.val_attribute15                  := p_val_attribute15;
  l_rec.val_attribute16                  := p_val_attribute16;
  l_rec.val_attribute17                  := p_val_attribute17;
  l_rec.val_attribute18                  := p_val_attribute18;
  l_rec.val_attribute19                  := p_val_attribute19;
  l_rec.val_attribute20                  := p_val_attribute20;
  l_rec.val_information_category         := p_val_information_category;
  l_rec.val_information1                 := p_val_information1;
  l_rec.val_information2                 := p_val_information2;
  l_rec.val_information3                 := p_val_information3;
  l_rec.val_information4                 := p_val_information4;
  l_rec.val_information5                 := p_val_information5;
  l_rec.val_information6                 := p_val_information6;
  l_rec.val_information7                 := p_val_information7;
  l_rec.val_information8                 := p_val_information8;
  l_rec.val_information9                 := p_val_information9;
  l_rec.val_information10                := p_val_information10;
  l_rec.val_information11                := p_val_information11;
  l_rec.val_information12                := p_val_information12;
  l_rec.val_information13                := p_val_information13;
  l_rec.val_information14                := p_val_information14;
  l_rec.val_information15                := p_val_information15;
  l_rec.val_information16                := p_val_information16;
  l_rec.val_information17                := p_val_information17;
  l_rec.val_information18                := p_val_information18;
  l_rec.val_information19                := p_val_information19;
  l_rec.val_information20                := p_val_information20;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.fuel_benefit                     := p_fuel_benefit;
  l_rec.sliding_rates_info               := p_sliding_rates_info;

  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pqp_val_shd;

/
