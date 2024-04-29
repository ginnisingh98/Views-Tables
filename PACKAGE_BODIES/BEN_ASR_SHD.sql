--------------------------------------------------------
--  DDL for Package Body BEN_ASR_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ASR_SHD" as
/* $Header: beasrrhi.pkb 120.0.12010000.3 2008/08/25 14:11:44 ppentapa ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_asr_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_ASNT_SET_RTS_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_ASNT_SET_RTS_F_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
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
   p_asnt_set_rt_id		in number,
   p_object_version_number	in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	asnt_set_rt_id,
	effective_start_date,
	effective_end_date,
	vrbl_rt_prfl_id,
	assignment_set_id,
	ordr_num,
	excld_flag,
	business_group_id,
	asr_attribute_category,
	asr_attribute1,
	asr_attribute2,
	asr_attribute3,
	asr_attribute4,
	asr_attribute5,
	asr_attribute6,
	asr_attribute7,
	asr_attribute8,
	asr_attribute9,
	asr_attribute10,
	asr_attribute11,
	asr_attribute12,
	asr_attribute13,
	asr_attribute14,
	asr_attribute15,
	asr_attribute16,
	asr_attribute17,
	asr_attribute18,
	asr_attribute19,
	asr_attribute20,
	asr_attribute21,
	asr_attribute22,
	asr_attribute23,
	asr_attribute24,
	asr_attribute25,
	asr_attribute26,
	asr_attribute27,
	asr_attribute28,
	asr_attribute29,
	asr_attribute30,
	object_version_number
    from	ben_asnt_set_rt_f
    where	asnt_set_rt_id = p_asnt_set_rt_id
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
      p_asnt_set_rt_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_asnt_set_rt_id = g_old_rec.asnt_set_rt_id and
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
  l_parent_key_value1	number;
  --
  Cursor C_Sel1 Is
    select  t.vrbl_rt_prfl_id
    from    ben_asnt_set_rt_f t
    where   t.asnt_set_rt_id = p_base_key_value
    and     p_effective_date
    between t.effective_start_date and t.effective_end_date;
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
	(p_effective_date	=> p_effective_date,
	 p_base_table_name	=> 'ben_asnt_set_rt_f',
	 p_base_key_column	=> 'asnt_set_rt_id',
	 p_base_key_value	=> p_base_key_value,
	 p_parent_table_name1	=> 'ben_vrbl_rt_prfl_f',
	 p_parent_key_column1	=> 'vrbl_rt_prfl_id',
	 p_parent_key_value1	=> l_parent_key_value1,
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
	 p_base_table_name	=> 'ben_asnt_set_rt_f',
	 p_base_key_column	=> 'asnt_set_rt_id',
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
	(p_base_table_name	=> 'ben_asnt_set_rt_f',
	 p_base_key_column	=> 'asnt_set_rt_id',
	 p_base_key_value	=> p_base_key_value);
  --
  hr_utility.set_location(l_proc, 10);
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  ben_asnt_set_rt_f t
  set	  t.effective_end_date	  = p_new_effective_end_date,
	  t.object_version_number = l_object_version_number
  where	  t.asnt_set_rt_id	  = p_base_key_value
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
	 p_asnt_set_rt_id	 in  number,
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
	asnt_set_rt_id,
	effective_start_date,
	effective_end_date,
	vrbl_rt_prfl_id,
	assignment_set_id,
	ordr_num,
	excld_flag,
	business_group_id,
	asr_attribute_category,
	asr_attribute1,
	asr_attribute2,
	asr_attribute3,
	asr_attribute4,
	asr_attribute5,
	asr_attribute6,
	asr_attribute7,
	asr_attribute8,
	asr_attribute9,
	asr_attribute10,
	asr_attribute11,
	asr_attribute12,
	asr_attribute13,
	asr_attribute14,
	asr_attribute15,
	asr_attribute16,
	asr_attribute17,
	asr_attribute18,
	asr_attribute19,
	asr_attribute20,
	asr_attribute21,
	asr_attribute22,
	asr_attribute23,
	asr_attribute24,
	asr_attribute25,
	asr_attribute26,
	asr_attribute27,
	asr_attribute28,
	asr_attribute29,
	asr_attribute30,
	object_version_number
    from    ben_asnt_set_rt_f
    where   asnt_set_rt_id         = p_asnt_set_rt_id
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
                             p_argument       => 'asnt_set_rt_id',
                             p_argument_value => p_asnt_set_rt_id);
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
	 p_base_table_name	   => 'ben_asnt_set_rt_f',
	 p_base_key_column	   => 'asnt_set_rt_id',
	 p_base_key_value 	   => p_asnt_set_rt_id,
	 p_parent_table_name1      => 'ben_vrbl_rt_prfl_f',
	 p_parent_key_column1      => 'vrbl_rt_prfl_id',
	 p_parent_key_value1       => g_old_rec.vrbl_rt_prfl_id,
         p_enforce_foreign_locking => false, --true,
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
    hr_utility.set_message_token('TABLE_NAME', 'ben_asnt_set_rt_f');
    hr_utility.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
    hr_utility.set_message_token('TABLE_NAME', 'ben_asnt_set_rt_f');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_asnt_set_rt_id                in number,
	p_effective_start_date          in date,
	p_effective_end_date            in date,
	p_vrbl_rt_prfl_id               in number,
	p_assignment_set_id             in number,
	p_ordr_num                      in number,
	p_excld_flag                    in varchar2,
	p_business_group_id             in number,
	p_asr_attribute_category        in varchar2,
	p_asr_attribute1                in varchar2,
	p_asr_attribute2                in varchar2,
	p_asr_attribute3                in varchar2,
	p_asr_attribute4                in varchar2,
	p_asr_attribute5                in varchar2,
	p_asr_attribute6                in varchar2,
	p_asr_attribute7                in varchar2,
	p_asr_attribute8                in varchar2,
	p_asr_attribute9                in varchar2,
	p_asr_attribute10               in varchar2,
	p_asr_attribute11               in varchar2,
	p_asr_attribute12               in varchar2,
	p_asr_attribute13               in varchar2,
	p_asr_attribute14               in varchar2,
	p_asr_attribute15               in varchar2,
	p_asr_attribute16               in varchar2,
	p_asr_attribute17               in varchar2,
	p_asr_attribute18               in varchar2,
	p_asr_attribute19               in varchar2,
	p_asr_attribute20               in varchar2,
	p_asr_attribute21               in varchar2,
	p_asr_attribute22               in varchar2,
	p_asr_attribute23               in varchar2,
	p_asr_attribute24               in varchar2,
	p_asr_attribute25               in varchar2,
	p_asr_attribute26               in varchar2,
	p_asr_attribute27               in varchar2,
	p_asr_attribute28               in varchar2,
	p_asr_attribute29               in varchar2,
	p_asr_attribute30               in varchar2,
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
  l_rec.asnt_set_rt_id                   := p_asnt_set_rt_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.vrbl_rt_prfl_id                  := p_vrbl_rt_prfl_id;
  l_rec.assignment_set_id                := p_assignment_set_id;
  l_rec.ordr_num                         := p_ordr_num;
  l_rec.excld_flag                       := p_excld_flag;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.asr_attribute_category           := p_asr_attribute_category;
  l_rec.asr_attribute1                   := p_asr_attribute1;
  l_rec.asr_attribute2                   := p_asr_attribute2;
  l_rec.asr_attribute3                   := p_asr_attribute3;
  l_rec.asr_attribute4                   := p_asr_attribute4;
  l_rec.asr_attribute5                   := p_asr_attribute5;
  l_rec.asr_attribute6                   := p_asr_attribute6;
  l_rec.asr_attribute7                   := p_asr_attribute7;
  l_rec.asr_attribute8                   := p_asr_attribute8;
  l_rec.asr_attribute9                   := p_asr_attribute9;
  l_rec.asr_attribute10                  := p_asr_attribute10;
  l_rec.asr_attribute11                  := p_asr_attribute11;
  l_rec.asr_attribute12                  := p_asr_attribute12;
  l_rec.asr_attribute13                  := p_asr_attribute13;
  l_rec.asr_attribute14                  := p_asr_attribute14;
  l_rec.asr_attribute15                  := p_asr_attribute15;
  l_rec.asr_attribute16                  := p_asr_attribute16;
  l_rec.asr_attribute17                  := p_asr_attribute17;
  l_rec.asr_attribute18                  := p_asr_attribute18;
  l_rec.asr_attribute19                  := p_asr_attribute19;
  l_rec.asr_attribute20                  := p_asr_attribute20;
  l_rec.asr_attribute21                  := p_asr_attribute21;
  l_rec.asr_attribute22                  := p_asr_attribute22;
  l_rec.asr_attribute23                  := p_asr_attribute23;
  l_rec.asr_attribute24                  := p_asr_attribute24;
  l_rec.asr_attribute25                  := p_asr_attribute25;
  l_rec.asr_attribute26                  := p_asr_attribute26;
  l_rec.asr_attribute27                  := p_asr_attribute27;
  l_rec.asr_attribute28                  := p_asr_attribute28;
  l_rec.asr_attribute29                  := p_asr_attribute29;
  l_rec.asr_attribute30                  := p_asr_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_asr_shd;

/
