--------------------------------------------------------
--  DDL for Package Body PER_REI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_REI_SHD" as
/* $Header: pereirhi.pkb 115.6 2003/10/07 19:01:25 ttagawa noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_rei_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
Begin
  --
  Return (nvl(g_api_dml, false));
  --
End return_api_dml_status;
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
  If (p_constraint_name = 'PER_CONTACT_EXTRA_INFO_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_CONTACT_EXTRA_INFO_FK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_CONTACT_EXTRA_INFO_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
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
  ,p_contact_extra_info_id            in number
  ,p_object_version_number            in number
  ) Return Boolean Is
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
     contact_extra_info_id
    ,effective_start_date
    ,effective_end_date
    ,contact_relationship_id
    ,information_type
    ,cei_information_category
    ,cei_information1
    ,cei_information2
    ,cei_information3
    ,cei_information4
    ,cei_information5
    ,cei_information6
    ,cei_information7
    ,cei_information8
    ,cei_information9
    ,cei_information10
    ,cei_information11
    ,cei_information12
    ,cei_information13
    ,cei_information14
    ,cei_information15
    ,cei_information16
    ,cei_information17
    ,cei_information18
    ,cei_information19
    ,cei_information20
    ,cei_information21
    ,cei_information22
    ,cei_information23
    ,cei_information24
    ,cei_information25
    ,cei_information26
    ,cei_information27
    ,cei_information28
    ,cei_information29
    ,cei_information30
    ,cei_attribute_category
    ,cei_attribute1
    ,cei_attribute2
    ,cei_attribute3
    ,cei_attribute4
    ,cei_attribute5
    ,cei_attribute6
    ,cei_attribute7
    ,cei_attribute8
    ,cei_attribute9
    ,cei_attribute10
    ,cei_attribute11
    ,cei_attribute12
    ,cei_attribute13
    ,cei_attribute14
    ,cei_attribute15
    ,cei_attribute16
    ,cei_attribute17
    ,cei_attribute18
    ,cei_attribute19
    ,cei_attribute20
    ,object_version_number
    ,request_id
    ,program_application_id
    ,program_id
    ,program_update_date
    from        per_contact_extra_info_f
    where       contact_extra_info_id = p_contact_extra_info_id
    and         p_effective_date
    between     effective_start_date and effective_end_date;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_effective_date is null or
      p_contact_extra_info_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_contact_extra_info_id =
        per_rei_shd.g_old_rec.contact_extra_info_id and
        p_object_version_number =
        per_rei_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into per_rei_shd.g_old_rec;
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
          <> per_rei_shd.g_old_rec.object_version_number) Then
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
    ,p_base_table_name       => 'per_contact_extra_info_f'
    ,p_base_key_column       => 'contact_extra_info_id'
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
   ,p_base_table_name               => 'per_contact_extra_info_f'
   ,p_base_key_column               => 'contact_extra_info_id'
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
      (p_base_table_name    => 'per_contact_extra_info_f'
      ,p_base_key_column    => 'contact_extra_info_id'
      ,p_base_key_value     => p_base_key_value
      );
  --
  hr_utility.set_location(l_proc, 10);
  per_rei_shd.g_api_dml := true;  -- Set the api dml status
--
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  per_contact_extra_info_f t
  set     t.effective_end_date    = p_new_effective_end_date
    ,     t.object_version_number = l_object_version_number
  where   t.contact_extra_info_id        = p_base_key_value
  and     p_effective_date
  between t.effective_start_date and t.effective_end_date;
  --
  per_rei_shd.g_api_dml := false;   -- Unset the api dml status
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When Others Then
    per_rei_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
--
End upd_effective_end_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (p_effective_date                   in date
  ,p_datetrack_mode                   in varchar2
  ,p_contact_extra_info_id            in number
  ,p_object_version_number            in number
  ,p_validation_start_date            out nocopy date
  ,p_validation_end_date              out nocopy date
  ) is
--
  l_proc                  varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date   date;
  l_argument              varchar2(30);
  l_person_id             number;
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  Cursor C_Sel1 is
    select
     contact_extra_info_id
    ,effective_start_date
    ,effective_end_date
    ,contact_relationship_id
    ,information_type
    ,cei_information_category
    ,cei_information1
    ,cei_information2
    ,cei_information3
    ,cei_information4
    ,cei_information5
    ,cei_information6
    ,cei_information7
    ,cei_information8
    ,cei_information9
    ,cei_information10
    ,cei_information11
    ,cei_information12
    ,cei_information13
    ,cei_information14
    ,cei_information15
    ,cei_information16
    ,cei_information17
    ,cei_information18
    ,cei_information19
    ,cei_information20
    ,cei_information21
    ,cei_information22
    ,cei_information23
    ,cei_information24
    ,cei_information25
    ,cei_information26
    ,cei_information27
    ,cei_information28
    ,cei_information29
    ,cei_information30
    ,cei_attribute_category
    ,cei_attribute1
    ,cei_attribute2
    ,cei_attribute3
    ,cei_attribute4
    ,cei_attribute5
    ,cei_attribute6
    ,cei_attribute7
    ,cei_attribute8
    ,cei_attribute9
    ,cei_attribute10
    ,cei_attribute11
    ,cei_attribute12
    ,cei_attribute13
    ,cei_attribute14
    ,cei_attribute15
    ,cei_attribute16
    ,cei_attribute17
    ,cei_attribute18
    ,cei_attribute19
    ,cei_attribute20
    ,object_version_number
    ,request_id
    ,program_application_id
    ,program_id
    ,program_update_date
    from    per_contact_extra_info_f
    where   contact_extra_info_id = p_contact_extra_info_id
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
                            ,p_argument       => 'contact_extra_info_id'
                            ,p_argument_value => p_contact_extra_info_id
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
    Fetch C_Sel1 Into per_rei_shd.g_old_rec;
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
          <> per_rei_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
    End If;
    --
    -- PER_CONTACT_EXTRA_INFO_F is a little bit different from the other datetrack tables.
    -- The parent of this table is PER_ALL_PEOPLE_F, but does not have column "PERSON_ID".
    -- So we need to derive PERSON_ID from PER_CONTACT_RELATIONSHIPS table to pass
    -- it to validate_dt_mode.
    --
    select  person_id
    into    l_person_id
    from    per_contact_relationships
    where   contact_relationship_id = g_old_rec.contact_relationship_id;
    --
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
    dt_api.validate_dt_mode
      (p_effective_date          => p_effective_date
      ,p_datetrack_mode          => p_datetrack_mode
      ,p_base_table_name         => 'per_contact_extra_info_f'
      ,p_base_key_column         => 'contact_extra_info_id'
      ,p_base_key_value          => p_contact_extra_info_id
      ,p_parent_table_name1      => 'per_all_people_f'
      ,p_parent_key_column1      => 'person_id'
      ,p_parent_key_value1       => l_person_id
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
    fnd_message.set_token('TABLE_NAME', 'per_contact_extra_info_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_contact_extra_info_id          in number
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_contact_relationship_id        in number
  ,p_information_type               in varchar2
  ,p_cei_information_category       in varchar2
  ,p_cei_information1               in varchar2
  ,p_cei_information2               in varchar2
  ,p_cei_information3               in varchar2
  ,p_cei_information4               in varchar2
  ,p_cei_information5               in varchar2
  ,p_cei_information6               in varchar2
  ,p_cei_information7               in varchar2
  ,p_cei_information8               in varchar2
  ,p_cei_information9               in varchar2
  ,p_cei_information10              in varchar2
  ,p_cei_information11              in varchar2
  ,p_cei_information12              in varchar2
  ,p_cei_information13              in varchar2
  ,p_cei_information14              in varchar2
  ,p_cei_information15              in varchar2
  ,p_cei_information16              in varchar2
  ,p_cei_information17              in varchar2
  ,p_cei_information18              in varchar2
  ,p_cei_information19              in varchar2
  ,p_cei_information20              in varchar2
  ,p_cei_information21              in varchar2
  ,p_cei_information22              in varchar2
  ,p_cei_information23              in varchar2
  ,p_cei_information24              in varchar2
  ,p_cei_information25              in varchar2
  ,p_cei_information26              in varchar2
  ,p_cei_information27              in varchar2
  ,p_cei_information28              in varchar2
  ,p_cei_information29              in varchar2
  ,p_cei_information30              in varchar2
  ,p_cei_attribute_category         in varchar2
  ,p_cei_attribute1                 in varchar2
  ,p_cei_attribute2                 in varchar2
  ,p_cei_attribute3                 in varchar2
  ,p_cei_attribute4                 in varchar2
  ,p_cei_attribute5                 in varchar2
  ,p_cei_attribute6                 in varchar2
  ,p_cei_attribute7                 in varchar2
  ,p_cei_attribute8                 in varchar2
  ,p_cei_attribute9                 in varchar2
  ,p_cei_attribute10                in varchar2
  ,p_cei_attribute11                in varchar2
  ,p_cei_attribute12                in varchar2
  ,p_cei_attribute13                in varchar2
  ,p_cei_attribute14                in varchar2
  ,p_cei_attribute15                in varchar2
  ,p_cei_attribute16                in varchar2
  ,p_cei_attribute17                in varchar2
  ,p_cei_attribute18                in varchar2
  ,p_cei_attribute19                in varchar2
  ,p_cei_attribute20                in varchar2
  ,p_object_version_number          in number
  ,p_request_id                     in number
  ,p_program_application_id         in number
  ,p_program_id                     in number
  ,p_program_update_date            in date
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.contact_extra_info_id            := p_contact_extra_info_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.contact_relationship_id          := p_contact_relationship_id;
  l_rec.information_type                 := p_information_type;
  l_rec.cei_information_category         := p_cei_information_category;
  l_rec.cei_information1                 := p_cei_information1;
  l_rec.cei_information2                 := p_cei_information2;
  l_rec.cei_information3                 := p_cei_information3;
  l_rec.cei_information4                 := p_cei_information4;
  l_rec.cei_information5                 := p_cei_information5;
  l_rec.cei_information6                 := p_cei_information6;
  l_rec.cei_information7                 := p_cei_information7;
  l_rec.cei_information8                 := p_cei_information8;
  l_rec.cei_information9                 := p_cei_information9;
  l_rec.cei_information10                := p_cei_information10;
  l_rec.cei_information11                := p_cei_information11;
  l_rec.cei_information12                := p_cei_information12;
  l_rec.cei_information13                := p_cei_information13;
  l_rec.cei_information14                := p_cei_information14;
  l_rec.cei_information15                := p_cei_information15;
  l_rec.cei_information16                := p_cei_information16;
  l_rec.cei_information17                := p_cei_information17;
  l_rec.cei_information18                := p_cei_information18;
  l_rec.cei_information19                := p_cei_information19;
  l_rec.cei_information20                := p_cei_information20;
  l_rec.cei_information21                := p_cei_information21;
  l_rec.cei_information22                := p_cei_information22;
  l_rec.cei_information23                := p_cei_information23;
  l_rec.cei_information24                := p_cei_information24;
  l_rec.cei_information25                := p_cei_information25;
  l_rec.cei_information26                := p_cei_information26;
  l_rec.cei_information27                := p_cei_information27;
  l_rec.cei_information28                := p_cei_information28;
  l_rec.cei_information29                := p_cei_information29;
  l_rec.cei_information30                := p_cei_information30;
  l_rec.cei_attribute_category           := p_cei_attribute_category;
  l_rec.cei_attribute1                   := p_cei_attribute1;
  l_rec.cei_attribute2                   := p_cei_attribute2;
  l_rec.cei_attribute3                   := p_cei_attribute3;
  l_rec.cei_attribute4                   := p_cei_attribute4;
  l_rec.cei_attribute5                   := p_cei_attribute5;
  l_rec.cei_attribute6                   := p_cei_attribute6;
  l_rec.cei_attribute7                   := p_cei_attribute7;
  l_rec.cei_attribute8                   := p_cei_attribute8;
  l_rec.cei_attribute9                   := p_cei_attribute9;
  l_rec.cei_attribute10                  := p_cei_attribute10;
  l_rec.cei_attribute11                  := p_cei_attribute11;
  l_rec.cei_attribute12                  := p_cei_attribute12;
  l_rec.cei_attribute13                  := p_cei_attribute13;
  l_rec.cei_attribute14                  := p_cei_attribute14;
  l_rec.cei_attribute15                  := p_cei_attribute15;
  l_rec.cei_attribute16                  := p_cei_attribute16;
  l_rec.cei_attribute17                  := p_cei_attribute17;
  l_rec.cei_attribute18                  := p_cei_attribute18;
  l_rec.cei_attribute19                  := p_cei_attribute19;
  l_rec.cei_attribute20                  := p_cei_attribute20;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< set_called_from_form >------------------------|
-- ----------------------------------------------------------------------------
 PROCEDURE set_called_from_form(
  p_flag	IN	BOOLEAN) AS
 BEGIN
   g_called_from_form := p_flag;
 END set_called_from_form;
--
end per_rei_shd;

/
