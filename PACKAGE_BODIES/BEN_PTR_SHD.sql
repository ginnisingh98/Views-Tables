--------------------------------------------------------
--  DDL for Package Body BEN_PTR_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PTR_SHD" as
/* $Header: beptrrhi.pkb 120.0.12010000.2 2008/08/05 15:24:01 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ptr_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc 	varchar2(72) := g_package||'return_api_dml_status';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Return (nvl(g_api_dml, false));
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End return_api_dml_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'BEN_PER_TYP_RTS_F_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
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
  (p_effective_date		in date,
   p_per_typ_rt_id		in number,
   p_object_version_number	in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	per_typ_rt_id,
	effective_start_date,
	effective_end_date,
	vrbl_rt_prfl_id,
	per_typ_cd,
        person_type_id,
	excld_flag,
	ordr_num,
	business_group_id,
	ptr_attribute_category,
	ptr_attribute1,
	ptr_attribute2,
	ptr_attribute3,
	ptr_attribute4,
	ptr_attribute5,
	ptr_attribute6,
	ptr_attribute7,
	ptr_attribute8,
	ptr_attribute9,
	ptr_attribute10,
	ptr_attribute11,
	ptr_attribute12,
	ptr_attribute13,
	ptr_attribute14,
	ptr_attribute15,
	ptr_attribute16,
	ptr_attribute17,
	ptr_attribute18,
	ptr_attribute19,
	ptr_attribute20,
	ptr_attribute21,
	ptr_attribute22,
	ptr_attribute23,
	ptr_attribute24,
	ptr_attribute25,
	ptr_attribute26,
	ptr_attribute27,
	ptr_attribute28,
	ptr_attribute29,
	ptr_attribute30,
	object_version_number
    from	ben_per_typ_rt_f
    where	per_typ_rt_id = p_per_typ_rt_id
    and		p_effective_date
    between	effective_start_date and effective_end_date;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_effective_date is null or
      p_per_typ_rt_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_per_typ_rt_id = g_old_rec.per_typ_rt_id and
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
	(p_effective_date	in  date,
	 p_base_key_value	in  number,
	 p_zap		 out nocopy boolean,
	 p_delete	 out nocopy boolean,
	 p_future_change out nocopy boolean,
	 p_delete_next_change out nocopy boolean) is
--
  l_proc 		varchar2(72) 	:= g_package||'find_dt_del_modes';
--
  l_parent_key_value1   number;
  --
  Cursor C_Sel1 Is
    select  t.vrbl_rt_prfl_id
    from    ben_per_typ_rt_f t
    where   t.per_typ_rt_id = p_base_key_value
    and     p_effective_date
    between t.effective_start_date and t.effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    --
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
	(p_effective_date	=> p_effective_date,
	 p_base_table_name	=> 'ben_per_typ_rt_f',
	 p_base_key_column	=> 'per_typ_rt_id',
	 p_base_key_value	=> p_base_key_value,
         p_parent_table_name1   => 'ben_vrbl_rt_prfl_f',
         p_parent_key_column1   => 'vrbl_rt_prfl_id',
         p_parent_key_value1    => l_parent_key_value1,
	 p_zap			=> p_zap,
	 p_delete		=> p_delete,
	 p_future_change	=> p_future_change,
	 p_delete_next_change	=> p_delete_next_change);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_del_modes;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_upd_modes >---------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_upd_modes
	(p_effective_date	in  date,
	 p_base_key_value	in  number,
	 p_correction	 out nocopy boolean,
	 p_update	 out nocopy boolean,
	 p_update_override out nocopy boolean,
	 p_update_change_insert out nocopy boolean) is
--
  l_proc 	varchar2(72) := g_package||'find_dt_upd_modes';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_upd_modes
	(p_effective_date	=> p_effective_date,
	 p_base_table_name	=> 'ben_per_typ_rt_f',
	 p_base_key_column	=> 'per_typ_rt_id',
	 p_base_key_value	=> p_base_key_value,
	 p_correction		=> p_correction,
	 p_update		=> p_update,
	 p_update_override	=> p_update_override,
	 p_update_change_insert	=> p_update_change_insert);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_upd_modes;
--
-- ----------------------------------------------------------------------------
-- |------------------------< upd_effective_end_date >------------------------|
-- ----------------------------------------------------------------------------
Procedure upd_effective_end_date
	(p_effective_date		in date,
	 p_base_key_value		in number,
	 p_new_effective_end_date	in date,
	 p_validation_start_date	in date,
	 p_validation_end_date		in date,
         p_object_version_number       out nocopy number) is
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
	(p_base_table_name	=> 'ben_per_typ_rt_f',
	 p_base_key_column	=> 'per_typ_rt_id',
	 p_base_key_value	=> p_base_key_value);
  --
  hr_utility.set_location(l_proc, 10);
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  ben_per_typ_rt_f t
  set	  t.effective_end_date	  = p_new_effective_end_date,
	  t.object_version_number = l_object_version_number
  where	  t.per_typ_rt_id	  = p_base_key_value
  and	  p_effective_date
  between t.effective_start_date and t.effective_end_date;
  --
  g_api_dml := false;   -- Unset the api dml status
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When Others Then
    g_api_dml := false;   -- Unset the api dml status
    Raise;
End upd_effective_end_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
	(p_effective_date	 in  date,
	 p_datetrack_mode	 in  varchar2,
	 p_per_typ_rt_id	 in  number,
	 p_object_version_number in  number,
	 p_validation_start_date out nocopy date,
	 p_validation_end_date	 out nocopy date) is
--
  l_proc		  varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date	  date;
  l_object_invalid 	  exception;
  l_argument		  varchar2(30);
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  Cursor C_Sel1 is
    select
	per_typ_rt_id,
	effective_start_date,
	effective_end_date,
	vrbl_rt_prfl_id,
	per_typ_cd,
        person_type_id,
	excld_flag,
	ordr_num,
	business_group_id,
	ptr_attribute_category,
	ptr_attribute1,
	ptr_attribute2,
	ptr_attribute3,
	ptr_attribute4,
	ptr_attribute5,
	ptr_attribute6,
	ptr_attribute7,
	ptr_attribute8,
	ptr_attribute9,
	ptr_attribute10,
	ptr_attribute11,
	ptr_attribute12,
	ptr_attribute13,
	ptr_attribute14,
	ptr_attribute15,
	ptr_attribute16,
	ptr_attribute17,
	ptr_attribute18,
	ptr_attribute19,
	ptr_attribute20,
	ptr_attribute21,
	ptr_attribute22,
	ptr_attribute23,
	ptr_attribute24,
	ptr_attribute25,
	ptr_attribute26,
	ptr_attribute27,
	ptr_attribute28,
	ptr_attribute29,
	ptr_attribute30,
	object_version_number
    from    ben_per_typ_rt_f
    where   per_typ_rt_id         = p_per_typ_rt_id
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
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'effective_date',
                             p_argument_value => p_effective_date);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'datetrack_mode',
                             p_argument_value => p_datetrack_mode);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'per_typ_rt_id',
                             p_argument_value => p_per_typ_rt_id);
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
	(p_effective_date	   => p_effective_date,
	 p_datetrack_mode	   => p_datetrack_mode,
	 p_base_table_name	   => 'ben_per_typ_rt_f',
	 p_base_key_column	   => 'per_typ_rt_id',
	 p_base_key_value 	   => p_per_typ_rt_id,
         p_parent_table_name1      => 'ben_vrbl_rt_prfl_f',
         p_parent_key_column1      => 'vrbl_rt_prfl_id',
         p_parent_key_value1       => g_old_rec.vrbl_rt_prfl_id,
         p_enforce_foreign_locking => false , --true,
	 p_validation_start_date   => l_validation_start_date,
 	 p_validation_end_date	   => l_validation_end_date);
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
    hr_utility.set_message_token('TABLE_NAME', 'ben_per_typ_rt_f');
    hr_utility.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
    hr_utility.set_message_token('TABLE_NAME', 'ben_per_typ_rt_f');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_per_typ_rt_id                 in number,
	p_effective_start_date          in date,
	p_effective_end_date            in date,
	p_vrbl_rt_prfl_id               in number,
	p_per_typ_cd                    in varchar2,
        p_person_type_id                in number,
	p_excld_flag                    in varchar2,
	p_ordr_num                      in number,
	p_business_group_id             in number,
	p_ptr_attribute_category        in varchar2,
	p_ptr_attribute1                in varchar2,
	p_ptr_attribute2                in varchar2,
	p_ptr_attribute3                in varchar2,
	p_ptr_attribute4                in varchar2,
	p_ptr_attribute5                in varchar2,
	p_ptr_attribute6                in varchar2,
	p_ptr_attribute7                in varchar2,
	p_ptr_attribute8                in varchar2,
	p_ptr_attribute9                in varchar2,
	p_ptr_attribute10               in varchar2,
	p_ptr_attribute11               in varchar2,
	p_ptr_attribute12               in varchar2,
	p_ptr_attribute13               in varchar2,
	p_ptr_attribute14               in varchar2,
	p_ptr_attribute15               in varchar2,
	p_ptr_attribute16               in varchar2,
	p_ptr_attribute17               in varchar2,
	p_ptr_attribute18               in varchar2,
	p_ptr_attribute19               in varchar2,
	p_ptr_attribute20               in varchar2,
	p_ptr_attribute21               in varchar2,
	p_ptr_attribute22               in varchar2,
	p_ptr_attribute23               in varchar2,
	p_ptr_attribute24               in varchar2,
	p_ptr_attribute25               in varchar2,
	p_ptr_attribute26               in varchar2,
	p_ptr_attribute27               in varchar2,
	p_ptr_attribute28               in varchar2,
	p_ptr_attribute29               in varchar2,
	p_ptr_attribute30               in varchar2,
	p_object_version_number         in number
	)
	Return g_rec_type is
--
  l_rec	  g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.per_typ_rt_id                    := p_per_typ_rt_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.vrbl_rt_prfl_id                  := p_vrbl_rt_prfl_id;
  l_rec.per_typ_cd                       := p_per_typ_cd;
  l_rec.person_type_id	                 := p_person_type_id;
  l_rec.excld_flag                       := p_excld_flag;
  l_rec.ordr_num                         := p_ordr_num;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.ptr_attribute_category           := p_ptr_attribute_category;
  l_rec.ptr_attribute1                   := p_ptr_attribute1;
  l_rec.ptr_attribute2                   := p_ptr_attribute2;
  l_rec.ptr_attribute3                   := p_ptr_attribute3;
  l_rec.ptr_attribute4                   := p_ptr_attribute4;
  l_rec.ptr_attribute5                   := p_ptr_attribute5;
  l_rec.ptr_attribute6                   := p_ptr_attribute6;
  l_rec.ptr_attribute7                   := p_ptr_attribute7;
  l_rec.ptr_attribute8                   := p_ptr_attribute8;
  l_rec.ptr_attribute9                   := p_ptr_attribute9;
  l_rec.ptr_attribute10                  := p_ptr_attribute10;
  l_rec.ptr_attribute11                  := p_ptr_attribute11;
  l_rec.ptr_attribute12                  := p_ptr_attribute12;
  l_rec.ptr_attribute13                  := p_ptr_attribute13;
  l_rec.ptr_attribute14                  := p_ptr_attribute14;
  l_rec.ptr_attribute15                  := p_ptr_attribute15;
  l_rec.ptr_attribute16                  := p_ptr_attribute16;
  l_rec.ptr_attribute17                  := p_ptr_attribute17;
  l_rec.ptr_attribute18                  := p_ptr_attribute18;
  l_rec.ptr_attribute19                  := p_ptr_attribute19;
  l_rec.ptr_attribute20                  := p_ptr_attribute20;
  l_rec.ptr_attribute21                  := p_ptr_attribute21;
  l_rec.ptr_attribute22                  := p_ptr_attribute22;
  l_rec.ptr_attribute23                  := p_ptr_attribute23;
  l_rec.ptr_attribute24                  := p_ptr_attribute24;
  l_rec.ptr_attribute25                  := p_ptr_attribute25;
  l_rec.ptr_attribute26                  := p_ptr_attribute26;
  l_rec.ptr_attribute27                  := p_ptr_attribute27;
  l_rec.ptr_attribute28                  := p_ptr_attribute28;
  l_rec.ptr_attribute29                  := p_ptr_attribute29;
  l_rec.ptr_attribute30                  := p_ptr_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_ptr_shd;

/
