--------------------------------------------------------
--  DDL for Package Body BEN_EDC_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EDC_SHD" as
/* $Header: beedcrhi.pkb 120.0 2005/05/28 01:57:04 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_edc_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_DSBL_STAT_CVG_FK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_DSBL_STAT_CVG_PK') Then
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  Else
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
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
   p_elig_dsbld_stat_cvg_id		in number,
   p_object_version_number	in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	elig_dsbld_stat_cvg_id,
	effective_start_date,
	effective_end_date,
	business_group_id,
	dpnt_cvg_eligy_prfl_id,
	cvg_strt_cd,
	cvg_strt_rl,
	cvg_thru_cd,
	cvg_thru_rl,
	dsbld_cd,
	edc_attribute_category,
	edc_attribute1,
	edc_attribute2,
	edc_attribute3,
	edc_attribute4,
	edc_attribute5,
	edc_attribute6,
	edc_attribute7,
	edc_attribute8,
	edc_attribute9,
	edc_attribute10,
	edc_attribute11,
	edc_attribute12,
	edc_attribute13,
	edc_attribute14,
	edc_attribute15,
	edc_attribute16,
	edc_attribute17,
	edc_attribute18,
	edc_attribute19,
	edc_attribute20,
	edc_attribute21,
	edc_attribute22,
	edc_attribute23,
	edc_attribute24,
	edc_attribute25,
	edc_attribute26,
	edc_attribute27,
	edc_attribute28,
	edc_attribute29,
	edc_attribute30,
	object_version_number
    from	ben_elig_dsbld_stat_cvg_f
    where	elig_dsbld_stat_cvg_id = p_elig_dsbld_stat_cvg_id
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
      p_elig_dsbld_stat_cvg_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_elig_dsbld_stat_cvg_id = g_old_rec.elig_dsbld_stat_cvg_id and
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
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
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
    select  t.dpnt_cvg_eligy_prfl_id
    from    ben_elig_dsbld_stat_cvg_f t
    where   t.elig_dsbld_stat_cvg_id = p_base_key_value
    and     p_effective_date
    between t.effective_start_date and t.effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  Open  C_Sel1;
  Fetch C_Sel1 Into l_parent_key_value1;
  If C_Sel1%notfound then
    Close C_Sel1;
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_del_modes
	(p_effective_date	=> p_effective_date,
	 p_base_table_name	=> 'ben_elig_dsbld_stat_cvg_f',
	 p_base_key_column	=> 'elig_dsbld_stat_cvg_id',
	 p_base_key_value	=> p_base_key_value,
	 p_parent_table_name1	=> 'ben_dpnt_cvg_eligy_prfl_f',
	 p_parent_key_column1	=> 'dpnt_cvg_eligy_prfl_id',
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
	 p_base_table_name	=> 'ben_elig_dsbld_stat_cvg_f',
	 p_base_key_column	=> 'elig_dsbld_stat_cvg_id',
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
	(p_base_table_name	=> 'ben_elig_dsbld_stat_cvg_f',
	 p_base_key_column	=> 'elig_dsbld_stat_cvg_id',
	 p_base_key_value	=> p_base_key_value);
  --
  hr_utility.set_location(l_proc, 10);
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  ben_elig_dsbld_stat_cvg_f t
  set	  t.effective_end_date	  = p_new_effective_end_date,
	  t.object_version_number = l_object_version_number
  where	  t.elig_dsbld_stat_cvg_id	  = p_base_key_value
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
	 p_elig_dsbld_stat_cvg_id	 in  number,
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
	elig_dsbld_stat_cvg_id,
	effective_start_date,
	effective_end_date,
	business_group_id,
	dpnt_cvg_eligy_prfl_id,
	cvg_strt_cd,
	cvg_strt_rl,
	cvg_thru_cd,
	cvg_thru_rl,
	dsbld_cd,
	edc_attribute_category,
	edc_attribute1,
	edc_attribute2,
	edc_attribute3,
	edc_attribute4,
	edc_attribute5,
	edc_attribute6,
	edc_attribute7,
	edc_attribute8,
	edc_attribute9,
	edc_attribute10,
	edc_attribute11,
	edc_attribute12,
	edc_attribute13,
	edc_attribute14,
	edc_attribute15,
	edc_attribute16,
	edc_attribute17,
	edc_attribute18,
	edc_attribute19,
	edc_attribute20,
	edc_attribute21,
	edc_attribute22,
	edc_attribute23,
	edc_attribute24,
	edc_attribute25,
	edc_attribute26,
	edc_attribute27,
	edc_attribute28,
	edc_attribute29,
	edc_attribute30,
	object_version_number
    from    ben_elig_dsbld_stat_cvg_f
    where   elig_dsbld_stat_cvg_id         = p_elig_dsbld_stat_cvg_id
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
                             p_argument       => 'elig_dsbld_stat_cvg_id',
                             p_argument_value => p_elig_dsbld_stat_cvg_id);
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
      fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    End If;
    Close C_Sel1;
    If (p_object_version_number <> g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
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
	 p_base_table_name	   => 'ben_elig_dsbld_stat_cvg_f',
	 p_base_key_column	   => 'elig_dsbld_stat_cvg_id',
	 p_base_key_value 	   => p_elig_dsbld_stat_cvg_id,
	 p_parent_table_name1      => 'ben_dpnt_cvg_eligy_prfl_f',
	 p_parent_key_column1      => 'dpnt_cvg_eligy_prfl_id',
	 p_parent_key_value1       => g_old_rec.dpnt_cvg_eligy_prfl_id,
         p_enforce_foreign_locking => true,
	 p_validation_start_date   => l_validation_start_date,
 	 p_validation_end_date	   => l_validation_end_date);
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
    fnd_message.set_token('TABLE_NAME', 'ben_elig_dsbld_stat_cvg_f');
    fnd_message.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
    fnd_message.set_token('TABLE_NAME', 'ben_elig_dsbld_stat_cvg_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_elig_dsbld_stat_cvg_id        in number,
	p_effective_start_date          in date,
	p_effective_end_date            in date,
	p_business_group_id             in number,
	p_dpnt_cvg_eligy_prfl_id        in number,
	p_cvg_strt_cd                   in varchar2,
	p_cvg_strt_rl                   in number,
	p_cvg_thru_cd                   in varchar2,
	p_cvg_thru_rl                   in number,
	p_dsbld_cd                      in varchar2,
	p_edc_attribute_category        in varchar2,
	p_edc_attribute1                in varchar2,
	p_edc_attribute2                in varchar2,
	p_edc_attribute3                in varchar2,
	p_edc_attribute4                in varchar2,
	p_edc_attribute5                in varchar2,
	p_edc_attribute6                in varchar2,
	p_edc_attribute7                in varchar2,
	p_edc_attribute8                in varchar2,
	p_edc_attribute9                in varchar2,
	p_edc_attribute10               in varchar2,
	p_edc_attribute11               in varchar2,
	p_edc_attribute12               in varchar2,
	p_edc_attribute13               in varchar2,
	p_edc_attribute14               in varchar2,
	p_edc_attribute15               in varchar2,
	p_edc_attribute16               in varchar2,
	p_edc_attribute17               in varchar2,
	p_edc_attribute18               in varchar2,
	p_edc_attribute19               in varchar2,
	p_edc_attribute20               in varchar2,
	p_edc_attribute21               in varchar2,
	p_edc_attribute22               in varchar2,
	p_edc_attribute23               in varchar2,
	p_edc_attribute24               in varchar2,
	p_edc_attribute25               in varchar2,
	p_edc_attribute26               in varchar2,
	p_edc_attribute27               in varchar2,
	p_edc_attribute28               in varchar2,
	p_edc_attribute29               in varchar2,
	p_edc_attribute30               in varchar2,
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
  l_rec.elig_dsbld_stat_cvg_id           := p_elig_dsbld_stat_cvg_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.dpnt_cvg_eligy_prfl_id           := p_dpnt_cvg_eligy_prfl_id;
  l_rec.cvg_strt_cd                      := p_cvg_strt_cd;
  l_rec.cvg_strt_rl                      := p_cvg_strt_rl;
  l_rec.cvg_thru_cd                      := p_cvg_thru_cd;
  l_rec.cvg_thru_rl                      := p_cvg_thru_rl;
  l_rec.dsbld_cd                         := p_dsbld_cd;
  l_rec.edc_attribute_category           := p_edc_attribute_category;
  l_rec.edc_attribute1                   := p_edc_attribute1;
  l_rec.edc_attribute2                   := p_edc_attribute2;
  l_rec.edc_attribute3                   := p_edc_attribute3;
  l_rec.edc_attribute4                   := p_edc_attribute4;
  l_rec.edc_attribute5                   := p_edc_attribute5;
  l_rec.edc_attribute6                   := p_edc_attribute6;
  l_rec.edc_attribute7                   := p_edc_attribute7;
  l_rec.edc_attribute8                   := p_edc_attribute8;
  l_rec.edc_attribute9                   := p_edc_attribute9;
  l_rec.edc_attribute10                  := p_edc_attribute10;
  l_rec.edc_attribute11                  := p_edc_attribute11;
  l_rec.edc_attribute12                  := p_edc_attribute12;
  l_rec.edc_attribute13                  := p_edc_attribute13;
  l_rec.edc_attribute14                  := p_edc_attribute14;
  l_rec.edc_attribute15                  := p_edc_attribute15;
  l_rec.edc_attribute16                  := p_edc_attribute16;
  l_rec.edc_attribute17                  := p_edc_attribute17;
  l_rec.edc_attribute18                  := p_edc_attribute18;
  l_rec.edc_attribute19                  := p_edc_attribute19;
  l_rec.edc_attribute20                  := p_edc_attribute20;
  l_rec.edc_attribute21                  := p_edc_attribute21;
  l_rec.edc_attribute22                  := p_edc_attribute22;
  l_rec.edc_attribute23                  := p_edc_attribute23;
  l_rec.edc_attribute24                  := p_edc_attribute24;
  l_rec.edc_attribute25                  := p_edc_attribute25;
  l_rec.edc_attribute26                  := p_edc_attribute26;
  l_rec.edc_attribute27                  := p_edc_attribute27;
  l_rec.edc_attribute28                  := p_edc_attribute28;
  l_rec.edc_attribute29                  := p_edc_attribute29;
  l_rec.edc_attribute30                  := p_edc_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_edc_shd;

/
