--------------------------------------------------------
--  DDL for Package Body PER_DIS_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DIS_SHD" as
/* $Header: pedisrhi.pkb 115.8 2002/12/04 18:57:24 pkakar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_dis_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'PER_DISABILITIES_F_FK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_DISABILITIES_F_FK3') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_DISABILITIES_F_PK') Then
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
  ,p_disability_id                    in number
  ,p_object_version_number            in number
  ) Return Boolean Is
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
     disability_id
    ,effective_start_date
    ,effective_end_date
    ,person_id
    ,incident_id
    ,organization_id
    ,registration_id
    ,registration_date
    ,registration_exp_date
    ,category
    ,status
    ,description
    ,degree
    ,quota_fte
    ,reason
    ,pre_registration_job
    ,work_restriction
    ,attribute_category
    ,attribute1
    ,attribute2
    ,attribute3
    ,attribute4
    ,attribute5
    ,attribute6
    ,attribute7
    ,attribute8
    ,attribute9
    ,attribute10
    ,attribute11
    ,attribute12
    ,attribute13
    ,attribute14
    ,attribute15
    ,attribute16
    ,attribute17
    ,attribute18
    ,attribute19
    ,attribute20
    ,attribute21
    ,attribute22
    ,attribute23
    ,attribute24
    ,attribute25
    ,attribute26
    ,attribute27
    ,attribute28
    ,attribute29
    ,attribute30
    ,dis_information_category
    ,dis_information1
    ,dis_information2
    ,dis_information3
    ,dis_information4
    ,dis_information5
    ,dis_information6
    ,dis_information7
    ,dis_information8
    ,dis_information9
    ,dis_information10
    ,dis_information11
    ,dis_information12
    ,dis_information13
    ,dis_information14
    ,dis_information15
    ,dis_information16
    ,dis_information17
    ,dis_information18
    ,dis_information19
    ,dis_information20
    ,dis_information21
    ,dis_information22
    ,dis_information23
    ,dis_information24
    ,dis_information25
    ,dis_information26
    ,dis_information27
    ,dis_information28
    ,dis_information29
    ,dis_information30
    ,object_version_number
    from	per_disabilities_f
    where	disability_id = p_disability_id
    and		p_effective_date
    between	effective_start_date and effective_end_date;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_effective_date is null or
      p_disability_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_disability_id =
        per_dis_shd.g_old_rec.disability_id and
        p_object_version_number =
        per_dis_shd.g_old_rec.object_version_number) Then
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
      Fetch C_Sel1 Into per_dis_shd.g_old_rec;
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
          <> per_dis_shd.g_old_rec.object_version_number) Then
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
  l_proc 	varchar2(72) := g_package||'find_dt_upd_modes';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_upd_modes
    (p_effective_date        => p_effective_date
    ,p_base_table_name       => 'per_disabilities_f'
    ,p_base_key_column       => 'disability_id'
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
  l_proc 		varchar2(72) 	:= g_package||'find_dt_del_modes';
  --
  l_parent_key_value1     number;
  --
  Cursor C_Sel1 Is
    select
     t.person_id
    from   per_disabilities_f t
    where  t.disability_id = p_base_key_value
    and    p_effective_date
    between t.effective_start_date and t.effective_end_date;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  Open C_sel1;
  Fetch C_Sel1 Into
     l_parent_key_value1;
  If C_Sel1%NOTFOUND then
    Close C_Sel1;
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE',l_proc);
     fnd_message.set_token('STEP','10');
     fnd_message.raise_error;
  End If;
  Close C_Sel1;
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_del_modes
   (p_effective_date                => p_effective_date
   ,p_base_table_name               => 'per_disabilities_f'
   ,p_base_key_column               => 'disability_id'
   ,p_base_key_value                => p_base_key_value
   ,p_parent_table_name1            => 'per_all_people_f'
   ,p_parent_key_column1            => 'person_id'
   ,p_parent_key_value1             => l_parent_key_value1
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
  l_proc 		  varchar2(72) := g_package||'upd_effective_end_date';
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
      (p_base_table_name    => 'per_disabilities_f'
      ,p_base_key_column    => 'disability_id'
      ,p_base_key_value     => p_base_key_value
      );
  --
  hr_utility.set_location(l_proc, 10);
  --
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  per_disabilities_f t
  set     t.effective_end_date    = p_new_effective_end_date
    ,     t.object_version_number = l_object_version_number
  where   t.disability_id        = p_base_key_value
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
  ,p_disability_id                    in number
  ,p_object_version_number            in number
  ,p_validation_start_date            out nocopy date
  ,p_validation_end_date              out nocopy date
  ) is
--
  l_proc		  varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date	  date;
  l_argument		  varchar2(30);
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  Cursor C_Sel1 is
    select
     disability_id
    ,effective_start_date
    ,effective_end_date
    ,person_id
    ,incident_id
    ,organization_id
    ,registration_id
    ,registration_date
    ,registration_exp_date
    ,category
    ,status
    ,description
    ,degree
    ,quota_fte
    ,reason
    ,pre_registration_job
    ,work_restriction
    ,attribute_category
    ,attribute1
    ,attribute2
    ,attribute3
    ,attribute4
    ,attribute5
    ,attribute6
    ,attribute7
    ,attribute8
    ,attribute9
    ,attribute10
    ,attribute11
    ,attribute12
    ,attribute13
    ,attribute14
    ,attribute15
    ,attribute16
    ,attribute17
    ,attribute18
    ,attribute19
    ,attribute20
    ,attribute21
    ,attribute22
    ,attribute23
    ,attribute24
    ,attribute25
    ,attribute26
    ,attribute27
    ,attribute28
    ,attribute29
    ,attribute30
    ,dis_information_category
    ,dis_information1
    ,dis_information2
    ,dis_information3
    ,dis_information4
    ,dis_information5
    ,dis_information6
    ,dis_information7
    ,dis_information8
    ,dis_information9
    ,dis_information10
    ,dis_information11
    ,dis_information12
    ,dis_information13
    ,dis_information14
    ,dis_information15
    ,dis_information16
    ,dis_information17
    ,dis_information18
    ,dis_information19
    ,dis_information20
    ,dis_information21
    ,dis_information22
    ,dis_information23
    ,dis_information24
    ,dis_information25
    ,dis_information26
    ,dis_information27
    ,dis_information28
    ,dis_information29
    ,dis_information30
    ,object_version_number
    from    per_disabilities_f
    where   disability_id = p_disability_id
    and	    p_effective_date
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
                            ,p_argument       => 'disability_id'
                            ,p_argument_value => p_disability_id
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
    Fetch C_Sel1 Into per_dis_shd.g_old_rec;
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
          <> per_dis_shd.g_old_rec.object_version_number) Then
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
      ,p_base_table_name         => 'per_disabilities_f'
      ,p_base_key_column         => 'disability_id'
      ,p_base_key_value          => p_disability_id
      ,p_parent_table_name1      => 'per_all_people_f'
      ,p_parent_key_column1      => 'person_id'
      ,p_parent_key_value1       => per_dis_shd.g_old_rec.person_id
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
    fnd_message.set_token('TABLE_NAME', 'per_disabilities_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_disability_id                  in number
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_person_id                      in number
  ,p_incident_id                    in number
  ,p_organization_id                in number
  ,p_registration_id                in varchar2
  ,p_registration_date              in date
  ,p_registration_exp_date          in date
  ,p_category                       in varchar2
  ,p_status                         in varchar2
  ,p_description                    in varchar2
  ,p_degree                         in number
  ,p_quota_fte                      in number
  ,p_reason                         in varchar2
  ,p_pre_registration_job           in varchar2
  ,p_work_restriction               in varchar2
  ,p_attribute_category             in varchar2
  ,p_attribute1                     in varchar2
  ,p_attribute2                     in varchar2
  ,p_attribute3                     in varchar2
  ,p_attribute4                     in varchar2
  ,p_attribute5                     in varchar2
  ,p_attribute6                     in varchar2
  ,p_attribute7                     in varchar2
  ,p_attribute8                     in varchar2
  ,p_attribute9                     in varchar2
  ,p_attribute10                    in varchar2
  ,p_attribute11                    in varchar2
  ,p_attribute12                    in varchar2
  ,p_attribute13                    in varchar2
  ,p_attribute14                    in varchar2
  ,p_attribute15                    in varchar2
  ,p_attribute16                    in varchar2
  ,p_attribute17                    in varchar2
  ,p_attribute18                    in varchar2
  ,p_attribute19                    in varchar2
  ,p_attribute20                    in varchar2
  ,p_attribute21                    in varchar2
  ,p_attribute22                    in varchar2
  ,p_attribute23                    in varchar2
  ,p_attribute24                    in varchar2
  ,p_attribute25                    in varchar2
  ,p_attribute26                    in varchar2
  ,p_attribute27                    in varchar2
  ,p_attribute28                    in varchar2
  ,p_attribute29                    in varchar2
  ,p_attribute30                    in varchar2
  ,p_dis_information_category       in varchar2
  ,p_dis_information1               in varchar2
  ,p_dis_information2               in varchar2
  ,p_dis_information3               in varchar2
  ,p_dis_information4               in varchar2
  ,p_dis_information5               in varchar2
  ,p_dis_information6               in varchar2
  ,p_dis_information7               in varchar2
  ,p_dis_information8               in varchar2
  ,p_dis_information9               in varchar2
  ,p_dis_information10              in varchar2
  ,p_dis_information11              in varchar2
  ,p_dis_information12              in varchar2
  ,p_dis_information13              in varchar2
  ,p_dis_information14              in varchar2
  ,p_dis_information15              in varchar2
  ,p_dis_information16              in varchar2
  ,p_dis_information17              in varchar2
  ,p_dis_information18              in varchar2
  ,p_dis_information19              in varchar2
  ,p_dis_information20              in varchar2
  ,p_dis_information21              in varchar2
  ,p_dis_information22              in varchar2
  ,p_dis_information23              in varchar2
  ,p_dis_information24              in varchar2
  ,p_dis_information25              in varchar2
  ,p_dis_information26              in varchar2
  ,p_dis_information27              in varchar2
  ,p_dis_information28              in varchar2
  ,p_dis_information29              in varchar2
  ,p_dis_information30              in varchar2
  ,p_object_version_number          in number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.disability_id                    := p_disability_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.person_id                        := p_person_id;
  l_rec.incident_id                      := p_incident_id;
  l_rec.organization_id                  := p_organization_id;
  l_rec.registration_id                  := p_registration_id;
  l_rec.registration_date                := p_registration_date;
  l_rec.registration_exp_date            := p_registration_exp_date;
  l_rec.category                         := p_category;
  l_rec.status                           := p_status;
  l_rec.description                      := p_description;
  l_rec.degree                           := p_degree;
  l_rec.quota_fte                        := p_quota_fte;
  l_rec.reason                           := p_reason;
  l_rec.pre_registration_job             := p_pre_registration_job;
  l_rec.work_restriction                 := p_work_restriction;
  l_rec.attribute_category               := p_attribute_category;
  l_rec.attribute1                       := p_attribute1;
  l_rec.attribute2                       := p_attribute2;
  l_rec.attribute3                       := p_attribute3;
  l_rec.attribute4                       := p_attribute4;
  l_rec.attribute5                       := p_attribute5;
  l_rec.attribute6                       := p_attribute6;
  l_rec.attribute7                       := p_attribute7;
  l_rec.attribute8                       := p_attribute8;
  l_rec.attribute9                       := p_attribute9;
  l_rec.attribute10                      := p_attribute10;
  l_rec.attribute11                      := p_attribute11;
  l_rec.attribute12                      := p_attribute12;
  l_rec.attribute13                      := p_attribute13;
  l_rec.attribute14                      := p_attribute14;
  l_rec.attribute15                      := p_attribute15;
  l_rec.attribute16                      := p_attribute16;
  l_rec.attribute17                      := p_attribute17;
  l_rec.attribute18                      := p_attribute18;
  l_rec.attribute19                      := p_attribute19;
  l_rec.attribute20                      := p_attribute20;
  l_rec.attribute21                      := p_attribute21;
  l_rec.attribute22                      := p_attribute22;
  l_rec.attribute23                      := p_attribute23;
  l_rec.attribute24                      := p_attribute24;
  l_rec.attribute25                      := p_attribute25;
  l_rec.attribute26                      := p_attribute26;
  l_rec.attribute27                      := p_attribute27;
  l_rec.attribute28                      := p_attribute28;
  l_rec.attribute29                      := p_attribute29;
  l_rec.attribute30                      := p_attribute30;
  l_rec.dis_information_category         := p_dis_information_category;
  l_rec.dis_information1                 := p_dis_information1;
  l_rec.dis_information2                 := p_dis_information2;
  l_rec.dis_information3                 := p_dis_information3;
  l_rec.dis_information4                 := p_dis_information4;
  l_rec.dis_information5                 := p_dis_information5;
  l_rec.dis_information6                 := p_dis_information6;
  l_rec.dis_information7                 := p_dis_information7;
  l_rec.dis_information8                 := p_dis_information8;
  l_rec.dis_information9                 := p_dis_information9;
  l_rec.dis_information10                := p_dis_information10;
  l_rec.dis_information11                := p_dis_information11;
  l_rec.dis_information12                := p_dis_information12;
  l_rec.dis_information13                := p_dis_information13;
  l_rec.dis_information14                := p_dis_information14;
  l_rec.dis_information15                := p_dis_information15;
  l_rec.dis_information16                := p_dis_information16;
  l_rec.dis_information17                := p_dis_information17;
  l_rec.dis_information18                := p_dis_information18;
  l_rec.dis_information19                := p_dis_information19;
  l_rec.dis_information20                := p_dis_information20;
  l_rec.dis_information21                := p_dis_information21;
  l_rec.dis_information22                := p_dis_information22;
  l_rec.dis_information23                := p_dis_information23;
  l_rec.dis_information24                := p_dis_information24;
  l_rec.dis_information25                := p_dis_information25;
  l_rec.dis_information26                := p_dis_information26;
  l_rec.dis_information27                := p_dis_information27;
  l_rec.dis_information28                := p_dis_information28;
  l_rec.dis_information29                := p_dis_information29;
  l_rec.dis_information30                := p_dis_information30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_dis_shd;

/
