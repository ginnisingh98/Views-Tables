--------------------------------------------------------
--  DDL for Package Body PER_PTU_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PTU_SHD" as
/* $Header: pepturhi.pkb 120.0 2005/05/31 15:57:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_ptu_shd.';  -- Global package name

-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc    varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'PER_PERSON_TYPE_USAGES_F_FK1') Then
    hr_utility.set_message(801, 'HR_52361_PTU_INVALID_PERSON_ID');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  elsif (p_constraint_name = 'PER_PERSON_TYPE_USAGES_F_UK1') Then
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  elsif (p_constraint_name = 'PER_PERSON_TYPE_USAGES_F_FK2') Then
    hr_utility.set_message(801, 'HR_52362_PTU_INV_PER_TYPE_ID');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_effective_date     in date,
   p_person_type_usage_id     in number,
   p_object_version_number in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
   person_type_usage_id,
   person_id,
   person_type_id,
   effective_start_date,
   effective_end_date,
   object_version_number,
   request_id,
   program_application_id,
   program_id,
   program_update_date,
   attribute_category,
   attribute1,
   attribute2,
   attribute3,
   attribute4,
   attribute5,
   attribute6,
   attribute7,
   attribute8,
   attribute9,
   attribute10,
   attribute11,
   attribute12,
   attribute13,
   attribute14,
   attribute15,
   attribute16,
   attribute17,
   attribute18,
   attribute19,
   attribute20,
   attribute21,
   attribute22,
   attribute23,
   attribute24,
   attribute25,
   attribute26,
   attribute27,
   attribute28,
   attribute29,
   attribute30
    from per_person_type_usages_f
    where   person_type_usage_id = p_person_type_usage_id
    and     p_effective_date
    between effective_start_date and effective_end_date;
--
  l_proc varchar2(72)   := g_package||'api_updating';
  l_fct_ret boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_effective_date is null or
      p_person_type_usage_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_person_type_usage_id = g_old_rec.person_type_usage_id and
        p_object_version_number = g_old_rec.object_version_number) Then
      hr_utility.set_location(l_proc, 10);
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
-- |--------------------------< find_dt_del_modes >---------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_del_modes
   (p_effective_date in  date,
    p_base_key_value in  number,
    p_zap       out nocopy boolean,
    p_delete    out nocopy boolean,
    p_future_change out nocopy boolean,
    p_delete_next_change out nocopy boolean) is
--
  l_proc       varchar2(72)   := g_package||'find_dt_del_modes';
--
  l_parent_key_value1   number;
  --
  Cursor C_Sel1 Is
    select  ptu.person_id
    from    per_person_type_usages_f ptu
    where   ptu.person_type_usage_id = p_base_key_value
    and     p_effective_date  between ptu.effective_start_date
                              and     ptu.effective_end_date;
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  Open  C_Sel1;
  Fetch C_Sel1 Into l_parent_key_value1;
  If C_Sel1%notfound then
    Close C_Sel1;
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_del_modes
   (p_effective_date => p_effective_date,
    p_base_table_name   => 'per_person_type_usages_f',
    p_base_key_column   => 'person_type_usage_id',
    p_base_key_value => p_base_key_value,
    p_parent_table_name1   => 'per_people_f',
    p_parent_key_column1   => 'person_id',
    p_parent_key_value1 => l_parent_key_value1,
    p_zap         => p_zap,
    p_delete      => p_delete,
         p_future_change   => p_future_change,
    p_delete_next_change   => p_delete_next_change
        );
  --
  -- Set the disallowed modes to false.
  --
--  p_zap := false;
--  p_delete := false;
--  p_future_change := false;
--  p_delete_next_change := false;

  if hr_person_type_usage_info.IsNonCoreHRPersonType
      (p_base_key_value,
       p_effective_date)
  then
   p_future_change := false;
   p_delete_next_change := false;
  else
   if hr_person_type_usage_info.FutSysPerTypeChgExists
      (p_base_key_value,
       p_effective_date)
   then
    p_zap := false;
    p_delete := false;
    p_future_change := false;
    p_delete_next_change := false;
   else
    p_zap := false;
    p_delete := false;
--    p_future_change := true;
--    p_delete_next_change := true;
   end if;
  end if;
--
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_del_modes;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_upd_modes >---------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_upd_modes
   (p_effective_date in  date,
    p_base_key_value in  number,
    p_correction   out nocopy boolean,
    p_update    out nocopy boolean,
    p_update_override out nocopy boolean,
    p_update_change_insert out nocopy boolean) is
--
  l_proc    varchar2(72) := g_package||'find_dt_upd_modes';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_upd_modes
   (p_effective_date => p_effective_date,
    p_base_table_name   => 'per_person_type_usages_f',
    p_base_key_column   => 'person_type_usage_id',
    p_base_key_value => p_base_key_value,
    p_correction     => p_correction,
    p_update      => p_update,
    p_update_override   => p_update_override,
    p_update_change_insert => p_update_change_insert
         );
  --
  -- Set the disallowed modes to false.
  --
--   p_update_override := false;
--   p_update_change_insert := false;
--   p_update := false;
  --
  if hr_person_type_usage_info.IsNonCoreHRPersonType
      (p_base_key_value,
       p_effective_date)
  then
   p_update_override := false;
   p_update_change_insert := false;
   p_update := false;
   else
    if hr_person_type_usage_info.FutSysPerTypeChgExists
      (p_base_key_value,
       p_effective_date)
    then
    p_update_override := false;
    p_update := false;
    end if;
   end if;
--

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_upd_modes;
--
-- ----------------------------------------------------------------------------
-- |------------------------< upd_effective_end_date >------------------------|
-- ----------------------------------------------------------------------------
Procedure upd_effective_end_date
   (p_effective_date    in date,
    p_base_key_value    in number,
    p_new_effective_end_date  in date,
    p_validation_start_date   in date,
    p_validation_end_date     in date,
         p_object_version_number       out nocopy number) is
--
  l_proc         varchar2(72) := g_package||'upd_effective_end_date';
  l_object_version_number number;
  --
  -- Start of Fix for WWBUG 1408379
  --
  l_old ben_ptu_ler.g_ptu_ler_rec;
  l_new ben_ptu_ler.g_ptu_ler_rec;
  --
  cursor c1 is
    select *
    from   per_person_type_usages_f
    where  person_type_usage_id = p_base_key_value
    and    p_effective_date
           between effective_start_date
           and     effective_end_date;
  --
  l_c1 c1%rowtype;
  l_rows_found boolean := false;
  --
  -- End of Fix for WWBUG 1408379
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Because we are updating a row we must get the next object
  -- version number.
  --
  l_object_version_number :=
    dt_api.get_object_version_number
   (p_base_table_name   => 'per_person_type_usages_f',
    p_base_key_column   => 'person_type_usage_id',
    p_base_key_value => p_base_key_value);
  --
  hr_utility.set_location(l_proc, 10);
  --
  --
  -- Start of Fix for WWBUG 1408379
  --
  open c1;
    --
    fetch c1 into l_c1;
    if c1%found then
      --
      l_rows_found := true;
      --
    end if;
    --
  close c1;
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  per_person_type_usages_f t
  set   t.effective_end_date    = p_new_effective_end_date,
     t.object_version_number = l_object_version_number
  where    t.person_type_usage_id     = p_base_key_value
  and   p_effective_date
  between t.effective_start_date and t.effective_end_date;
  --
  -- Start of Fix for WWBUG 1408379
  --
  if l_rows_found then
    --
    l_old.person_type_usage_id := l_c1.person_type_usage_id;
    l_old.person_id := l_c1.person_id;
    l_old.person_type_id := l_c1.person_type_id;
    l_old.effective_start_date := l_c1.effective_start_date;
    l_old.effective_end_date := l_c1.effective_end_date;
    l_new.person_type_usage_id := l_c1.person_type_usage_id;
    l_new.person_id := l_c1.person_id;
    l_new.person_type_id := l_c1.person_type_id;
    l_new.effective_start_date := l_c1.effective_start_date;
    l_new.effective_end_date := p_new_effective_end_date;
    --
    ben_ptu_ler.ler_chk(p_old            => l_old,
                        p_new            => l_new,
                        p_effective_date => p_effective_date);
    --
  end if;
  --
  -- End of Fix for WWBUG 1408379
  --
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When Others Then
    Raise;
End upd_effective_end_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
   (p_effective_date  in  date,
    p_datetrack_mode  in  varchar2,
    p_person_type_usage_id  in  number,
    p_object_version_number in  number,
    p_validation_start_date out nocopy date,
    p_validation_end_date   out nocopy date) is
--
  l_proc      varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date   date;
  l_object_invalid     exception;
  l_argument        varchar2(30);
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  Cursor C_Sel1 is
    select
   person_type_usage_id,
   person_id,
   person_type_id,
   effective_start_date,
   effective_end_date,
   object_version_number,
   request_id,
   program_application_id,
   program_id,
   program_update_date,
   attribute_category,
   attribute1,
   attribute2,
   attribute3,
   attribute4,
   attribute5,
   attribute6,
   attribute7,
   attribute8,
   attribute9,
   attribute10,
   attribute11,
   attribute12,
   attribute13,
   attribute14,
   attribute15,
   attribute16,
   attribute17,
   attribute18,
   attribute19,
   attribute20,
   attribute21,
   attribute22,
   attribute23,
   attribute24,
   attribute25,
   attribute26,
   attribute27,
   attribute28,
   attribute29,
   attribute30
    from    per_person_type_usages_f
    where   person_type_usage_id         = p_person_type_usage_id
    and      p_effective_date
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
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'effective_date',
                             p_argument_value => p_effective_date);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'datetrack_mode',
                             p_argument_value => p_datetrack_mode);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'person_type_usage_id',
                             p_argument_value => p_person_type_usage_id);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'object_version_number',
                             p_argument_value => p_object_version_number);
  --
  -- Check to ensure the datetrack mode is not INSERT.
  --
  If (p_datetrack_mode <> 'INSERT') then
    --
    -- We must select and lock the current row.
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
    hr_utility.set_location(l_proc, 15);
    --
    --
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
    dt_api.validate_dt_mode
   (p_effective_date    => p_effective_date,
    p_datetrack_mode    => p_datetrack_mode,
    p_base_table_name      => 'per_person_type_usages_f',
    p_base_key_column      => 'person_type_usage_id',
    p_base_key_value       => p_person_type_usage_id,
         p_parent_table_name1      => 'per_all_people_f',
         p_parent_key_column1      => 'person_id',
         p_parent_key_value1       => g_old_rec.person_id,
         p_enforce_foreign_locking => true,
    p_validation_start_date   => l_validation_start_date,
    p_validation_end_date     => l_validation_end_date);
  Else
    --
    -- We are doing a datetrack 'INSERT' which is illegal within this
    -- procedure therefore we must error (note: to lck on insert the
    -- private procedure ins_lck should be called).
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
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
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'per_person_type_usages_f');
    hr_utility.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
    hr_utility.set_message_token('TABLE_NAME', 'per_person_type_usages_f');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
   (
   p_person_type_usage_id          in number,
   p_person_id                     in number,
   p_person_type_id                in number,
   p_effective_start_date          in date,
   p_effective_end_date            in date,
   p_object_version_number         in number,
   p_request_id                    in number,
   p_program_application_id        in number,
   p_program_id                    in number,
   p_program_update_date           in date,
   p_attribute_category            in varchar2,
   p_attribute1                    in varchar2,
   p_attribute2                    in varchar2,
   p_attribute3                    in varchar2,
   p_attribute4                    in varchar2,
   p_attribute5                    in varchar2,
   p_attribute6                    in varchar2,
   p_attribute7                    in varchar2,
   p_attribute8                    in varchar2,
   p_attribute9                    in varchar2,
   p_attribute10                   in varchar2,
   p_attribute11                   in varchar2,
   p_attribute12                   in varchar2,
   p_attribute13                   in varchar2,
   p_attribute14                   in varchar2,
   p_attribute15                   in varchar2,
   p_attribute16                   in varchar2,
   p_attribute17                   in varchar2,
   p_attribute18                   in varchar2,
   p_attribute19                   in varchar2,
   p_attribute20                   in varchar2,
   p_attribute21                   in varchar2,
   p_attribute22                   in varchar2,
   p_attribute23                   in varchar2,
   p_attribute24                   in varchar2,
   p_attribute25                   in varchar2,
   p_attribute26                   in varchar2,
   p_attribute27                   in varchar2,
   p_attribute28                   in varchar2,
   p_attribute29                   in varchar2,
   p_attribute30                   in varchar2
   )
   Return g_rec_type is
--
  l_rec    g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.person_type_usage_id             := p_person_type_usage_id;
  l_rec.person_id                        := p_person_id;
  l_rec.person_type_id                   := p_person_type_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
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
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< set_called_from_form >------------------------|
-- ----------------------------------------------------------------------------
procedure set_called_from_form
   ( p_flag     in boolean ) as
begin
   g_called_from_form:=p_flag;
end;
--

end per_ptu_shd;

/
