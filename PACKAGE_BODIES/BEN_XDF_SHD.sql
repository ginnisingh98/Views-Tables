--------------------------------------------------------
--  DDL for Package Body BEN_XDF_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XDF_SHD" as
/* $Header: bexdfrhi.pkb 120.6 2006/07/10 21:53:55 tjesumic ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xdf_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_EXT_DFN_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_DFN_FK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_DFN_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
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
  (
  p_ext_dfn_id                         in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		ext_dfn_id,
	name,
	xml_tag_name,
	xdo_template_id,
	data_typ_cd,
	ext_typ_cd,
	output_name,
	output_type,
	apnd_rqst_id_flag,
	prmy_sort_cd,
	scnd_sort_cd,
	strt_dt,
	end_dt,
	ext_crit_prfl_id,
	ext_file_id,
	business_group_id,
        legislation_code,
	xdf_attribute_category,
	xdf_attribute1,
	xdf_attribute2,
	xdf_attribute3,
	xdf_attribute4,
	xdf_attribute5,
	xdf_attribute6,
	xdf_attribute7,
	xdf_attribute8,
	xdf_attribute9,
	xdf_attribute10,
	xdf_attribute11,
	xdf_attribute12,
	xdf_attribute13,
	xdf_attribute14,
	xdf_attribute15,
	xdf_attribute16,
	xdf_attribute17,
	xdf_attribute18,
	xdf_attribute19,
	xdf_attribute20,
	xdf_attribute21,
	xdf_attribute22,
	xdf_attribute23,
	xdf_attribute24,
	xdf_attribute25,
	xdf_attribute26,
	xdf_attribute27,
	xdf_attribute28,
	xdf_attribute29,
	xdf_attribute30,
        last_update_date,
        creation_date,
        last_updated_by,
        last_update_login,
        created_by ,
	object_version_number,
	drctry_name,
	kickoff_wrt_prc_flag,
	upd_cm_sent_dt_flag,
	spcl_hndl_flag,
	ext_global_flag,
	cm_display_flag,
	use_eff_dt_for_chgs_flag,
      ext_post_prcs_rl
    from	ben_ext_dfn
    where	ext_dfn_id = p_ext_dfn_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_ext_dfn_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_ext_dfn_id = g_old_rec.ext_dfn_id and
	p_object_version_number = g_old_rec.object_version_number
       ) Then
      hr_utility.set_location(l_proc, 10);
      --
      -- The g_old_rec is current therefore we must
      -- set the returning function to true
      --
      l_fct_ret := true;
    Else
      --
      -- Select the current row into g_old_rec
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
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_ext_dfn_id                         in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	ext_dfn_id,
	name,
	xml_tag_name,
	xdo_template_id,
	data_typ_cd,
	ext_typ_cd,
	output_name,
	output_type,
	apnd_rqst_id_flag,
	prmy_sort_cd,
	scnd_sort_cd,
	strt_dt,
	end_dt,
	ext_crit_prfl_id,
	ext_file_id,
	business_group_id,
        legislation_code,
	xdf_attribute_category,
	xdf_attribute1,
	xdf_attribute2,
	xdf_attribute3,
	xdf_attribute4,
	xdf_attribute5,
	xdf_attribute6,
	xdf_attribute7,
	xdf_attribute8,
	xdf_attribute9,
	xdf_attribute10,
	xdf_attribute11,
	xdf_attribute12,
	xdf_attribute13,
	xdf_attribute14,
	xdf_attribute15,
	xdf_attribute16,
	xdf_attribute17,
	xdf_attribute18,
	xdf_attribute19,
	xdf_attribute20,
	xdf_attribute21,
	xdf_attribute22,
	xdf_attribute23,
	xdf_attribute24,
	xdf_attribute25,
	xdf_attribute26,
	xdf_attribute27,
	xdf_attribute28,
	xdf_attribute29,
	xdf_attribute30,
        last_update_date,
        creation_date,
        last_updated_by,
        last_update_login,
        created_by ,
	object_version_number,
	drctry_name,
	kickoff_wrt_prc_flag,
	upd_cm_sent_dt_flag,
	spcl_hndl_flag,
	ext_global_flag,
	cm_display_flag,
	use_eff_dt_for_chgs_flag,
      ext_post_prcs_rl
    from	ben_ext_dfn
    where	ext_dfn_id = p_ext_dfn_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Add any mandatory argument checking here:
  -- Example:
  -- hr_api.mandatory_arg_error
  --   (p_api_name       => l_proc,
  --    p_argument       => 'object_version_number',
  --    p_argument_value => p_object_version_number);
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
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
    hr_utility.set_message_token('TABLE_NAME', 'ben_ext_dfn');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_ext_dfn_id                    in number,
	p_name                          in varchar2,
	p_xml_tag_name                  in varchar2,
	p_xdo_template_id               in number,
	p_data_typ_cd                   in varchar2,
	p_ext_typ_cd                    in varchar2,
	p_output_name                   in varchar2,
	p_output_type                   in varchar2,
	p_apnd_rqst_id_flag             in varchar2,
	p_prmy_sort_cd                  in varchar2,
	p_scnd_sort_cd                  in varchar2,
	p_strt_dt                       in varchar2,
	p_end_dt                        in varchar2,
	p_ext_crit_prfl_id              in number,
	p_ext_file_id                   in number,
	p_business_group_id             in number,
        p_legislation_code              in varchar2,
	p_xdf_attribute_category        in varchar2,
	p_xdf_attribute1                in varchar2,
	p_xdf_attribute2                in varchar2,
	p_xdf_attribute3                in varchar2,
	p_xdf_attribute4                in varchar2,
	p_xdf_attribute5                in varchar2,
	p_xdf_attribute6                in varchar2,
	p_xdf_attribute7                in varchar2,
	p_xdf_attribute8                in varchar2,
	p_xdf_attribute9                in varchar2,
	p_xdf_attribute10               in varchar2,
	p_xdf_attribute11               in varchar2,
	p_xdf_attribute12               in varchar2,
	p_xdf_attribute13               in varchar2,
	p_xdf_attribute14               in varchar2,
	p_xdf_attribute15               in varchar2,
	p_xdf_attribute16               in varchar2,
	p_xdf_attribute17               in varchar2,
	p_xdf_attribute18               in varchar2,
	p_xdf_attribute19               in varchar2,
	p_xdf_attribute20               in varchar2,
	p_xdf_attribute21               in varchar2,
	p_xdf_attribute22               in varchar2,
	p_xdf_attribute23               in varchar2,
	p_xdf_attribute24               in varchar2,
	p_xdf_attribute25               in varchar2,
	p_xdf_attribute26               in varchar2,
	p_xdf_attribute27               in varchar2,
	p_xdf_attribute28               in varchar2,
	p_xdf_attribute29               in varchar2,
	p_xdf_attribute30               in varchar2,
        p_last_update_date              in date,
        p_creation_date                 in date,
        p_last_updated_by               in number,
        p_last_update_login             in number,
        p_created_by                    in number,
	p_object_version_number         in number,
	p_drctry_name                   in varchar2,
	p_kickoff_wrt_prc_flag          in varchar2,
	p_upd_cm_sent_dt_flag           in varchar2,
	p_spcl_hndl_flag                in varchar2,
	p_ext_global_flag               in varchar2,
	p_cm_display_flag               in varchar2,
	p_use_eff_dt_for_chgs_flag      in varchar2,
	p_ext_post_prcs_rl              in number
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
  l_rec.ext_dfn_id                       := p_ext_dfn_id;
  l_rec.name                             := p_name;
  l_rec.xml_tag_name                     := p_xml_tag_name;
  l_rec.xdo_template_id                  := p_xdo_template_id;
  l_rec.data_typ_cd                      := p_data_typ_cd;
  l_rec.ext_typ_cd                       := p_ext_typ_cd;
  l_rec.output_name                      := p_output_name;
  l_rec.output_type                      := p_output_type;
  l_rec.apnd_rqst_id_flag                := p_apnd_rqst_id_flag;
  l_rec.prmy_sort_cd                     := p_prmy_sort_cd;
  l_rec.scnd_sort_cd                     := p_scnd_sort_cd;
  l_rec.strt_dt                          := p_strt_dt;
  l_rec.end_dt                           := p_end_dt;
  l_rec.ext_crit_prfl_id                 := p_ext_crit_prfl_id;
  l_rec.ext_file_id                      := p_ext_file_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.xdf_attribute_category           := p_xdf_attribute_category;
  l_rec.xdf_attribute1                   := p_xdf_attribute1;
  l_rec.xdf_attribute2                   := p_xdf_attribute2;
  l_rec.xdf_attribute3                   := p_xdf_attribute3;
  l_rec.xdf_attribute4                   := p_xdf_attribute4;
  l_rec.xdf_attribute5                   := p_xdf_attribute5;
  l_rec.xdf_attribute6                   := p_xdf_attribute6;
  l_rec.xdf_attribute7                   := p_xdf_attribute7;
  l_rec.xdf_attribute8                   := p_xdf_attribute8;
  l_rec.xdf_attribute9                   := p_xdf_attribute9;
  l_rec.xdf_attribute10                  := p_xdf_attribute10;
  l_rec.xdf_attribute11                  := p_xdf_attribute11;
  l_rec.xdf_attribute12                  := p_xdf_attribute12;
  l_rec.xdf_attribute13                  := p_xdf_attribute13;
  l_rec.xdf_attribute14                  := p_xdf_attribute14;
  l_rec.xdf_attribute15                  := p_xdf_attribute15;
  l_rec.xdf_attribute16                  := p_xdf_attribute16;
  l_rec.xdf_attribute17                  := p_xdf_attribute17;
  l_rec.xdf_attribute18                  := p_xdf_attribute18;
  l_rec.xdf_attribute19                  := p_xdf_attribute19;
  l_rec.xdf_attribute20                  := p_xdf_attribute20;
  l_rec.xdf_attribute21                  := p_xdf_attribute21;
  l_rec.xdf_attribute22                  := p_xdf_attribute22;
  l_rec.xdf_attribute23                  := p_xdf_attribute23;
  l_rec.xdf_attribute24                  := p_xdf_attribute24;
  l_rec.xdf_attribute25                  := p_xdf_attribute25;
  l_rec.xdf_attribute26                  := p_xdf_attribute26;
  l_rec.xdf_attribute27                  := p_xdf_attribute27;
  l_rec.xdf_attribute28                  := p_xdf_attribute28;
  l_rec.xdf_attribute29                  := p_xdf_attribute29;
  l_rec.xdf_attribute30                  := p_xdf_attribute30;
  l_rec.last_update_date                 := p_last_update_date;
  l_rec.creation_date                    := p_creation_date;
  l_rec.last_updated_by                  := p_last_updated_by;
  l_rec.last_update_login                := p_last_update_login;
  l_rec.created_by                       := p_created_by;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.drctry_name                      := p_drctry_name;
  l_rec.kickoff_wrt_prc_flag             := p_kickoff_wrt_prc_flag;
  l_rec.upd_cm_sent_dt_flag              := p_upd_cm_sent_dt_flag;
  l_rec.spcl_hndl_flag                   := p_spcl_hndl_flag;
  l_rec.ext_global_flag                  := p_ext_global_flag;
  l_rec.cm_display_flag                  := p_cm_display_flag;
  l_rec.use_eff_dt_for_chgs_flag         := p_use_eff_dt_for_chgs_flag;
  l_rec.ext_post_prcs_rl                 := p_ext_post_prcs_rl;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_xdf_shd;

/
