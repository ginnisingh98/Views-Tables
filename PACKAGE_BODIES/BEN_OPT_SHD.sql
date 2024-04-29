--------------------------------------------------------
--  DDL for Package Body BEN_OPT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_OPT_SHD" as
/* $Header: beoptrhi.pkb 120.0 2005/05/28 09:56:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_opt_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_OPT_F_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_OPT_F_PK') Then
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
   p_opt_id		in number,
   p_object_version_number	in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	opt_id,
	effective_start_date,
	effective_end_date,
	name,
	cmbn_ptip_opt_id,
	business_group_id,
	opt_attribute_category,
	opt_attribute1,
	opt_attribute2,
	opt_attribute3,
	opt_attribute4,
	opt_attribute5,
	opt_attribute6,
	opt_attribute7,
	opt_attribute8,
	opt_attribute9,
	opt_attribute10,
	opt_attribute11,
	opt_attribute12,
	opt_attribute13,
	opt_attribute14,
	opt_attribute15,
	opt_attribute16,
	opt_attribute17,
	opt_attribute18,
	opt_attribute19,
	opt_attribute20,
	opt_attribute21,
	opt_attribute22,
	opt_attribute23,
	opt_attribute24,
	opt_attribute25,
	opt_attribute26,
	opt_attribute27,
	opt_attribute28,
	opt_attribute29,
	opt_attribute30,
	object_version_number,
	rqd_perd_enrt_nenrt_uom,
	rqd_perd_enrt_nenrt_val,
	rqd_perd_enrt_nenrt_rl,
	invk_wv_opt_flag,
	short_name,
	short_code,
	legislation_code,
	legislation_subgroup,
        group_opt_id,
	component_reason,
        mapping_table_name,
        mapping_table_pk_id
    from	ben_opt_f
    where	opt_id = p_opt_id
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
      p_opt_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_opt_id = g_old_rec.opt_id and
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
    select  t.cmbn_ptip_opt_id
    from    ben_opt_f t
    where   t.opt_id = p_base_key_value
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
	 p_base_table_name	=> 'ben_opt_f',
	 p_base_key_column	=> 'opt_id',
	 p_base_key_value	=> p_base_key_value,
	 p_parent_table_name1	=> 'ben_cmbn_ptip_opt_f',
	 p_parent_key_column1	=> 'cmbn_ptip_opt_id',
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
	 p_base_table_name	=> 'ben_opt_f',
	 p_base_key_column	=> 'opt_id',
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
	(p_base_table_name	=> 'ben_opt_f',
	 p_base_key_column	=> 'opt_id',
	 p_base_key_value	=> p_base_key_value);
  --
  hr_utility.set_location(l_proc, 10);
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  ben_opt_f t
  set	  t.effective_end_date	  = p_new_effective_end_date,
	  t.object_version_number = l_object_version_number
  where	  t.opt_id	  = p_base_key_value
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
	 p_opt_id	 in  number,
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
	opt_id,
	effective_start_date,
	effective_end_date,
	name,
	cmbn_ptip_opt_id,
	business_group_id,
	opt_attribute_category,
	opt_attribute1,
	opt_attribute2,
	opt_attribute3,
	opt_attribute4,
	opt_attribute5,
	opt_attribute6,
	opt_attribute7,
	opt_attribute8,
	opt_attribute9,
	opt_attribute10,
	opt_attribute11,
	opt_attribute12,
	opt_attribute13,
	opt_attribute14,
	opt_attribute15,
	opt_attribute16,
	opt_attribute17,
	opt_attribute18,
	opt_attribute19,
	opt_attribute20,
	opt_attribute21,
	opt_attribute22,
	opt_attribute23,
	opt_attribute24,
	opt_attribute25,
	opt_attribute26,
	opt_attribute27,
	opt_attribute28,
	opt_attribute29,
	opt_attribute30,
	object_version_number,
	rqd_perd_enrt_nenrt_uom,
	rqd_perd_enrt_nenrt_val,
	rqd_perd_enrt_nenrt_rl,
	invk_wv_opt_flag,
	short_name,
	short_code,
	legislation_code,
	legislation_subgroup,
        group_opt_id ,
	component_reason,
        mapping_table_name,
        mapping_table_pk_id
    from    ben_opt_f
    where   opt_id         = p_opt_id
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
                             p_argument       => 'opt_id',
                             p_argument_value => p_opt_id);
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
	 p_base_table_name	   => 'ben_opt_f',
	 p_base_key_column	   => 'opt_id',
	 p_base_key_value 	   => p_opt_id,
	 p_parent_table_name1      => 'ben_cmbn_ptip_opt_f',
	 p_parent_key_column1      => 'cmbn_ptip_opt_id',
	 p_parent_key_value1       => g_old_rec.cmbn_ptip_opt_id,
         p_enforce_foreign_locking => true,
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
    hr_utility.set_message_token('TABLE_NAME', 'ben_opt_f');
    hr_utility.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
    hr_utility.set_message_token('TABLE_NAME', 'ben_opt_f');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_opt_id                        in number,
	p_effective_start_date          in date,
	p_effective_end_date            in date,
	p_name                          in varchar2,
	p_cmbn_ptip_opt_id              in number,
	p_business_group_id             in number,
	p_opt_attribute_category        in varchar2,
	p_opt_attribute1                in varchar2,
	p_opt_attribute2                in varchar2,
	p_opt_attribute3                in varchar2,
	p_opt_attribute4                in varchar2,
	p_opt_attribute5                in varchar2,
	p_opt_attribute6                in varchar2,
	p_opt_attribute7                in varchar2,
	p_opt_attribute8                in varchar2,
	p_opt_attribute9                in varchar2,
	p_opt_attribute10               in varchar2,
	p_opt_attribute11               in varchar2,
	p_opt_attribute12               in varchar2,
	p_opt_attribute13               in varchar2,
	p_opt_attribute14               in varchar2,
	p_opt_attribute15               in varchar2,
	p_opt_attribute16               in varchar2,
	p_opt_attribute17               in varchar2,
	p_opt_attribute18               in varchar2,
	p_opt_attribute19               in varchar2,
	p_opt_attribute20               in varchar2,
	p_opt_attribute21               in varchar2,
	p_opt_attribute22               in varchar2,
	p_opt_attribute23               in varchar2,
	p_opt_attribute24               in varchar2,
	p_opt_attribute25               in varchar2,
	p_opt_attribute26               in varchar2,
	p_opt_attribute27               in varchar2,
	p_opt_attribute28               in varchar2,
	p_opt_attribute29               in varchar2,
	p_opt_attribute30               in varchar2,
	p_object_version_number         in number,
	p_rqd_perd_enrt_nenrt_uom       in varchar2,
	p_rqd_perd_enrt_nenrt_val       in number,
	p_rqd_perd_enrt_nenrt_rl        in number,
	p_invk_wv_opt_flag              in varchar2,
	p_short_name			in varchar2,
	p_short_code			in varchar2,
	p_legislation_code		in varchar2,
	p_legislation_subgroup		in varchar2,
	p_group_opt_id      		in number,
	p_component_reason              in varchar2,
        p_mapping_table_name            in varchar2,
        p_mapping_table_pk_id           in number
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
  l_rec.opt_id                           := p_opt_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.name                             := p_name;
  l_rec.cmbn_ptip_opt_id                 := p_cmbn_ptip_opt_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.opt_attribute_category           := p_opt_attribute_category;
  l_rec.opt_attribute1                   := p_opt_attribute1;
  l_rec.opt_attribute2                   := p_opt_attribute2;
  l_rec.opt_attribute3                   := p_opt_attribute3;
  l_rec.opt_attribute4                   := p_opt_attribute4;
  l_rec.opt_attribute5                   := p_opt_attribute5;
  l_rec.opt_attribute6                   := p_opt_attribute6;
  l_rec.opt_attribute7                   := p_opt_attribute7;
  l_rec.opt_attribute8                   := p_opt_attribute8;
  l_rec.opt_attribute9                   := p_opt_attribute9;
  l_rec.opt_attribute10                  := p_opt_attribute10;
  l_rec.opt_attribute11                  := p_opt_attribute11;
  l_rec.opt_attribute12                  := p_opt_attribute12;
  l_rec.opt_attribute13                  := p_opt_attribute13;
  l_rec.opt_attribute14                  := p_opt_attribute14;
  l_rec.opt_attribute15                  := p_opt_attribute15;
  l_rec.opt_attribute16                  := p_opt_attribute16;
  l_rec.opt_attribute17                  := p_opt_attribute17;
  l_rec.opt_attribute18                  := p_opt_attribute18;
  l_rec.opt_attribute19                  := p_opt_attribute19;
  l_rec.opt_attribute20                  := p_opt_attribute20;
  l_rec.opt_attribute21                  := p_opt_attribute21;
  l_rec.opt_attribute22                  := p_opt_attribute22;
  l_rec.opt_attribute23                  := p_opt_attribute23;
  l_rec.opt_attribute24                  := p_opt_attribute24;
  l_rec.opt_attribute25                  := p_opt_attribute25;
  l_rec.opt_attribute26                  := p_opt_attribute26;
  l_rec.opt_attribute27                  := p_opt_attribute27;
  l_rec.opt_attribute28                  := p_opt_attribute28;
  l_rec.opt_attribute29                  := p_opt_attribute29;
  l_rec.opt_attribute30                  := p_opt_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.rqd_perd_enrt_nenrt_uom          := p_rqd_perd_enrt_nenrt_uom;
  l_rec.rqd_perd_enrt_nenrt_val          := p_rqd_perd_enrt_nenrt_val;
  l_rec.rqd_perd_enrt_nenrt_rl           := p_rqd_perd_enrt_nenrt_rl;
  l_rec.invk_wv_opt_flag                 := p_invk_wv_opt_flag;
  l_rec.short_name                       := p_short_name;
  l_rec.short_code                       := p_short_code;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.legislation_subgroup             := p_legislation_subgroup;
  l_rec.group_opt_id                     := p_group_opt_id;
  l_rec.component_reason                 := p_component_reason;
  l_rec.mapping_table_name               := p_mapping_table_name;
  l_rec.mapping_table_pk_id              := p_mapping_table_pk_id;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_opt_shd;

/
