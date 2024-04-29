--------------------------------------------------------
--  DDL for Package Body BEN_LPR_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LPR_SHD" as
/* $Header: belprrhi.pkb 115.11 2004/01/18 23:15:35 abparekh ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_lpr_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_LER_CHG_PLIP_ENRT_FK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_LER_CHG_PLIP_EN_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
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
   p_ler_chg_plip_enrt_id		in number,
   p_object_version_number	in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	ler_chg_plip_enrt_id,
	effective_start_date,
	effective_end_date,
	business_group_id,
	auto_enrt_mthd_rl,
	plip_id,
	ler_id,
	tco_chg_enrt_cd,
	crnt_enrt_prclds_chg_flag,
	dflt_flag,
	dflt_enrt_rl,
	enrt_rl,
	dflt_enrt_cd,
	enrt_mthd_cd,
	stl_elig_cant_chg_flag,
	enrt_cd,
	lpr_attribute_category,
	lpr_attribute1,
	lpr_attribute2,
	lpr_attribute3,
	lpr_attribute4,
	lpr_attribute5,
	lpr_attribute6,
	lpr_attribute7,
	lpr_attribute8,
	lpr_attribute9,
	lpr_attribute10,
	lpr_attribute11,
	lpr_attribute12,
	lpr_attribute13,
	lpr_attribute14,
	lpr_attribute15,
	lpr_attribute16,
	lpr_attribute17,
	lpr_attribute18,
	lpr_attribute19,
	lpr_attribute20,
	lpr_attribute21,
	lpr_attribute22,
	lpr_attribute23,
	lpr_attribute24,
	lpr_attribute25,
	lpr_attribute26,
	lpr_attribute27,
	lpr_attribute28,
	lpr_attribute29,
	lpr_attribute30,
	object_version_number
    from	ben_ler_chg_plip_enrt_f
    where	ler_chg_plip_enrt_id = p_ler_chg_plip_enrt_id
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
      p_ler_chg_plip_enrt_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_ler_chg_plip_enrt_id = g_old_rec.ler_chg_plip_enrt_id and
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
  l_parent_key_value2	number;
  --
  Cursor C_Sel1 Is
    select  t.plip_id,
	    t.ler_id
    from    ben_ler_chg_plip_enrt_f t
    where   t.ler_chg_plip_enrt_id = p_base_key_value
    and     p_effective_date
    between t.effective_start_date and t.effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  Open  C_Sel1;
  Fetch C_Sel1 Into l_parent_key_value1,
		    l_parent_key_value2;
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
	 p_base_table_name	=> 'ben_ler_chg_plip_enrt_f',
	 p_base_key_column	=> 'ler_chg_plip_enrt_id',
	 p_base_key_value	=> p_base_key_value,
	 p_parent_table_name1	=> 'ben_plip_f',
	 p_parent_key_column1	=> 'plip_id',
	 p_parent_key_value1	=> l_parent_key_value1,
	 p_parent_table_name2	=> 'ben_ler_f',
	 p_parent_key_column2	=> 'ler_id',
	 p_parent_key_value2	=> l_parent_key_value2,
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
	 p_base_table_name	=> 'ben_ler_chg_plip_enrt_f',
	 p_base_key_column	=> 'ler_chg_plip_enrt_id',
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
	(p_base_table_name	=> 'ben_ler_chg_plip_enrt_f',
	 p_base_key_column	=> 'ler_chg_plip_enrt_id',
	 p_base_key_value	=> p_base_key_value);
  --
  hr_utility.set_location(l_proc, 10);
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  ben_ler_chg_plip_enrt_f t
  set	  t.effective_end_date	  = p_new_effective_end_date,
	  t.object_version_number = l_object_version_number
  where	  t.ler_chg_plip_enrt_id	  = p_base_key_value
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
	 p_ler_chg_plip_enrt_id	 in  number,
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
	ler_chg_plip_enrt_id,
	effective_start_date,
	effective_end_date,
	business_group_id,
	auto_enrt_mthd_rl,
	plip_id,
	ler_id,
	tco_chg_enrt_cd,
	crnt_enrt_prclds_chg_flag,
	dflt_flag,
	dflt_enrt_rl,
	enrt_rl,
	dflt_enrt_cd,
	enrt_mthd_cd,
	stl_elig_cant_chg_flag,
	enrt_cd,
	lpr_attribute_category,
	lpr_attribute1,
	lpr_attribute2,
	lpr_attribute3,
	lpr_attribute4,
	lpr_attribute5,
	lpr_attribute6,
	lpr_attribute7,
	lpr_attribute8,
	lpr_attribute9,
	lpr_attribute10,
	lpr_attribute11,
	lpr_attribute12,
	lpr_attribute13,
	lpr_attribute14,
	lpr_attribute15,
	lpr_attribute16,
	lpr_attribute17,
	lpr_attribute18,
	lpr_attribute19,
	lpr_attribute20,
	lpr_attribute21,
	lpr_attribute22,
	lpr_attribute23,
	lpr_attribute24,
	lpr_attribute25,
	lpr_attribute26,
	lpr_attribute27,
	lpr_attribute28,
	lpr_attribute29,
	lpr_attribute30,
	object_version_number
    from    ben_ler_chg_plip_enrt_f
    where   ler_chg_plip_enrt_id         = p_ler_chg_plip_enrt_id
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
                             p_argument       => 'ler_chg_plip_enrt_id',
                             p_argument_value => p_ler_chg_plip_enrt_id);
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
	 p_base_table_name	   => 'ben_ler_chg_plip_enrt_f',
	 p_base_key_column	   => 'ler_chg_plip_enrt_id',
	 p_base_key_value 	   => p_ler_chg_plip_enrt_id,
	 p_parent_table_name1      => 'ben_plip_f',
	 p_parent_key_column1      => 'plip_id',
	 p_parent_key_value1       => g_old_rec.plip_id,
	 p_parent_table_name2      => 'ben_ler_f',
	 p_parent_key_column2      => 'ler_id',
	 p_parent_key_value2       => g_old_rec.ler_id,
	 p_child_table_name1       => 'ben_ler_chg_plip_enrt_rl_f',
	 p_child_key_column1       => 'ler_chg_plip_enrt_rl_id',
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
    fnd_message.set_token('TABLE_NAME', 'ben_ler_chg_plip_enrt_f');
    fnd_message.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
    fnd_message.set_token('TABLE_NAME', 'ben_ler_chg_plip_enrt_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_ler_chg_plip_enrt_id          in number,
	p_effective_start_date          in date,
	p_effective_end_date            in date,
	p_business_group_id             in number,
	p_auto_enrt_mthd_rl             in number,
	p_plip_id                       in number,
	p_ler_id                        in number,
	p_tco_chg_enrt_cd               in varchar2,
	p_crnt_enrt_prclds_chg_flag     in varchar2,
	p_dflt_flag                     in varchar2,
	p_dflt_enrt_rl                  in number,
	p_enrt_rl                       in number,
	p_dflt_enrt_cd                  in varchar2,
	p_enrt_mthd_cd                  in varchar2,
	p_stl_elig_cant_chg_flag        in varchar2,
	p_enrt_cd                       in varchar2,
	p_lpr_attribute_category        in varchar2,
	p_lpr_attribute1                in varchar2,
	p_lpr_attribute2                in varchar2,
	p_lpr_attribute3                in varchar2,
	p_lpr_attribute4                in varchar2,
	p_lpr_attribute5                in varchar2,
	p_lpr_attribute6                in varchar2,
	p_lpr_attribute7                in varchar2,
	p_lpr_attribute8                in varchar2,
	p_lpr_attribute9                in varchar2,
	p_lpr_attribute10               in varchar2,
	p_lpr_attribute11               in varchar2,
	p_lpr_attribute12               in varchar2,
	p_lpr_attribute13               in varchar2,
	p_lpr_attribute14               in varchar2,
	p_lpr_attribute15               in varchar2,
	p_lpr_attribute16               in varchar2,
	p_lpr_attribute17               in varchar2,
	p_lpr_attribute18               in varchar2,
	p_lpr_attribute19               in varchar2,
	p_lpr_attribute20               in varchar2,
	p_lpr_attribute21               in varchar2,
	p_lpr_attribute22               in varchar2,
	p_lpr_attribute23               in varchar2,
	p_lpr_attribute24               in varchar2,
	p_lpr_attribute25               in varchar2,
	p_lpr_attribute26               in varchar2,
	p_lpr_attribute27               in varchar2,
	p_lpr_attribute28               in varchar2,
	p_lpr_attribute29               in varchar2,
	p_lpr_attribute30               in varchar2,
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
  l_rec.ler_chg_plip_enrt_id             := p_ler_chg_plip_enrt_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.auto_enrt_mthd_rl                := p_auto_enrt_mthd_rl;
  l_rec.plip_id                          := p_plip_id;
  l_rec.ler_id                           := p_ler_id;
  l_rec.tco_chg_enrt_cd                  := p_tco_chg_enrt_cd;
  l_rec.crnt_enrt_prclds_chg_flag        := p_crnt_enrt_prclds_chg_flag;
  l_rec.dflt_flag                        := p_dflt_flag;
  l_rec.dflt_enrt_rl                     := p_dflt_enrt_rl;
  l_rec.enrt_rl                          := p_enrt_rl;
  l_rec.dflt_enrt_cd                     := p_dflt_enrt_cd;
  l_rec.enrt_mthd_cd                     := p_enrt_mthd_cd;
  l_rec.stl_elig_cant_chg_flag           := p_stl_elig_cant_chg_flag;
  l_rec.enrt_cd                          := p_enrt_cd;
  l_rec.lpr_attribute_category           := p_lpr_attribute_category;
  l_rec.lpr_attribute1                   := p_lpr_attribute1;
  l_rec.lpr_attribute2                   := p_lpr_attribute2;
  l_rec.lpr_attribute3                   := p_lpr_attribute3;
  l_rec.lpr_attribute4                   := p_lpr_attribute4;
  l_rec.lpr_attribute5                   := p_lpr_attribute5;
  l_rec.lpr_attribute6                   := p_lpr_attribute6;
  l_rec.lpr_attribute7                   := p_lpr_attribute7;
  l_rec.lpr_attribute8                   := p_lpr_attribute8;
  l_rec.lpr_attribute9                   := p_lpr_attribute9;
  l_rec.lpr_attribute10                  := p_lpr_attribute10;
  l_rec.lpr_attribute11                  := p_lpr_attribute11;
  l_rec.lpr_attribute12                  := p_lpr_attribute12;
  l_rec.lpr_attribute13                  := p_lpr_attribute13;
  l_rec.lpr_attribute14                  := p_lpr_attribute14;
  l_rec.lpr_attribute15                  := p_lpr_attribute15;
  l_rec.lpr_attribute16                  := p_lpr_attribute16;
  l_rec.lpr_attribute17                  := p_lpr_attribute17;
  l_rec.lpr_attribute18                  := p_lpr_attribute18;
  l_rec.lpr_attribute19                  := p_lpr_attribute19;
  l_rec.lpr_attribute20                  := p_lpr_attribute20;
  l_rec.lpr_attribute21                  := p_lpr_attribute21;
  l_rec.lpr_attribute22                  := p_lpr_attribute22;
  l_rec.lpr_attribute23                  := p_lpr_attribute23;
  l_rec.lpr_attribute24                  := p_lpr_attribute24;
  l_rec.lpr_attribute25                  := p_lpr_attribute25;
  l_rec.lpr_attribute26                  := p_lpr_attribute26;
  l_rec.lpr_attribute27                  := p_lpr_attribute27;
  l_rec.lpr_attribute28                  := p_lpr_attribute28;
  l_rec.lpr_attribute29                  := p_lpr_attribute29;
  l_rec.lpr_attribute30                  := p_lpr_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_lpr_shd;

/
