--------------------------------------------------------
--  DDL for Package Body BEN_XEL_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XEL_SHD" as
/* $Header: bexelrhi.pkb 120.1 2005/06/08 13:15:34 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xel_shd.';  -- Global package name
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
  cursor c1 is
   select xrc.name
   from ben_ext_rcd xrc,
   ben_ext_data_elmt_in_rcd xer
   where g_old_rec.ext_data_elmt_id = xer.ext_data_elmt_id
   and xrc.ext_rcd_id = xer.ext_rcd_id;

  cursor c2 is
   select xel.name
   from ben_ext_data_elmt xel
   where g_old_rec.ext_data_elmt_id = xel.ttl_sum_ext_data_elmt_id;

  cursor c3 is
   select xel.name
   from ben_ext_data_elmt xel,
        ben_ext_where_clause xwc
   where g_old_rec.ext_data_elmt_id = xwc.cond_ext_data_elmt_id
   and   xel.ext_data_elmt_id = xwc.ext_data_elmt_id;

  l_proc 	varchar2(72) := g_package||'constraint_error';
  l_name ben_ext_data_elmt.name%type ;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'BEN_EXT_DATA_ELMT_FK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_DATA_ELMT_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_DATA_ELMT_DECD_FK1') Then
    fnd_message.set_name('BEN', 'BEN_92477_ELMT_HAS_CHLD2');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_WHERE_CLAUSE_FK1') Then
    fnd_message.set_name('BEN', 'BEN_92476_ELMT_HAS_CHLD1');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_DATA_ELMT_FK3') Then
    open c2;
    fetch c2 into l_name;
    close c2;
    fnd_message.set_name('BEN', 'BEN_92475_ELMT_USED_IN_TTL');
    fnd_message.set_token('DATA_ELMT', l_name);
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_WHERE_CLAUSE_FK2') Then
    open c3;
    fetch c3 into l_name;
    close c3;
    fnd_message.set_name('BEN', 'BEN_92475_ELMT_USED_IN_TTL');
    fnd_message.set_token('DATA_ELMT', l_name);
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_DATA_ELMT_IN_RCD_FK1') Then
    open c1;
    fetch c1 into l_name;
    close c1;
    fnd_message.set_name('BEN', 'BEN_92474_ELMT_USED_IN_RCD');
    fnd_message.set_token('RECORD', l_name);
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
  (
  p_ext_data_elmt_id                   in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		ext_data_elmt_id,
	name,
        xml_tag_name,
	data_elmt_typ_cd,
	data_elmt_rl,
	frmt_mask_cd,
	string_val,
	dflt_val,
	max_length_num,
	just_cd,
	ttl_fnctn_cd,
	ttl_cond_oper_cd,
	ttl_cond_val,
	ttl_sum_ext_data_elmt_id,
	ttl_cond_ext_data_elmt_id,
	ext_fld_id,
	business_group_id,
	legislation_code,
	xel_attribute_category,
	xel_attribute1,
	xel_attribute2,
	xel_attribute3,
	xel_attribute4,
	xel_attribute5,
	xel_attribute6,
	xel_attribute7,
	xel_attribute8,
	xel_attribute9,
	xel_attribute10,
	xel_attribute11,
	xel_attribute12,
	xel_attribute13,
	xel_attribute14,
	xel_attribute15,
	xel_attribute16,
	xel_attribute17,
	xel_attribute18,
	xel_attribute19,
	xel_attribute20,
	xel_attribute21,
	xel_attribute22,
	xel_attribute23,
	xel_attribute24,
	xel_attribute25,
	xel_attribute26,
	xel_attribute27,
	xel_attribute28,
	xel_attribute29,
	xel_attribute30,
	defined_balance_id,
        last_update_date,
        creation_date,
        last_updated_by,
        last_update_login,
        created_by ,
	object_version_number
    from	ben_ext_data_elmt
    where	ext_data_elmt_id = p_ext_data_elmt_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_ext_data_elmt_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_ext_data_elmt_id = g_old_rec.ext_data_elmt_id and
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
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_ext_data_elmt_id                   in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	ext_data_elmt_id,
	name,
        xml_tag_name,
	data_elmt_typ_cd,
	data_elmt_rl,
	frmt_mask_cd,
	string_val,
	dflt_val,
	max_length_num,
	just_cd,
	ttl_fnctn_cd,
	ttl_cond_oper_cd,
	ttl_cond_val,
	ttl_sum_ext_data_elmt_id,
	ttl_cond_ext_data_elmt_id,
	ext_fld_id,
	business_group_id,
	legislation_code,
	xel_attribute_category,
	xel_attribute1,
	xel_attribute2,
	xel_attribute3,
	xel_attribute4,
	xel_attribute5,
	xel_attribute6,
	xel_attribute7,
	xel_attribute8,
	xel_attribute9,
	xel_attribute10,
	xel_attribute11,
	xel_attribute12,
	xel_attribute13,
	xel_attribute14,
	xel_attribute15,
	xel_attribute16,
	xel_attribute17,
	xel_attribute18,
	xel_attribute19,
	xel_attribute20,
	xel_attribute21,
	xel_attribute22,
	xel_attribute23,
	xel_attribute24,
	xel_attribute25,
	xel_attribute26,
	xel_attribute27,
	xel_attribute28,
	xel_attribute29,
	xel_attribute30,
	defined_balance_id,
        last_update_date,
        creation_date,
        last_updated_by,
        last_update_login,
        created_by ,
	object_version_number
    from	ben_ext_data_elmt
    where	ext_data_elmt_id = p_ext_data_elmt_id
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
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number <> g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
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
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'ben_ext_data_elmt');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_ext_data_elmt_id              in number,
	p_name                          in varchar2,
	p_xml_tag_name                  in varchar2,
	p_data_elmt_typ_cd              in varchar2,
	p_data_elmt_rl                  in number,
	p_frmt_mask_cd                  in varchar2,
	p_string_val                    in varchar2,
	p_dflt_val                      in varchar2,
	p_max_length_num                in number,
	p_just_cd                      in varchar2,
	p_ttl_fnctn_cd			in varchar2,
	p_ttl_cond_oper_cd 		in varchar2,
	p_ttl_cond_val			in varchar2,
	p_ttl_sum_ext_data_elmt_id	in number,
	p_ttl_cond_ext_data_elmt_id	in number,
	p_ext_fld_id                    in number,
	p_business_group_id             in number,
	p_legislation_code              in varchar2,
	p_xel_attribute_category        in varchar2,
	p_xel_attribute1                in varchar2,
	p_xel_attribute2                in varchar2,
	p_xel_attribute3                in varchar2,
	p_xel_attribute4                in varchar2,
	p_xel_attribute5                in varchar2,
	p_xel_attribute6                in varchar2,
	p_xel_attribute7                in varchar2,
	p_xel_attribute8                in varchar2,
	p_xel_attribute9                in varchar2,
	p_xel_attribute10               in varchar2,
	p_xel_attribute11               in varchar2,
	p_xel_attribute12               in varchar2,
	p_xel_attribute13               in varchar2,
	p_xel_attribute14               in varchar2,
	p_xel_attribute15               in varchar2,
	p_xel_attribute16               in varchar2,
	p_xel_attribute17               in varchar2,
	p_xel_attribute18               in varchar2,
	p_xel_attribute19               in varchar2,
	p_xel_attribute20               in varchar2,
	p_xel_attribute21               in varchar2,
	p_xel_attribute22               in varchar2,
	p_xel_attribute23               in varchar2,
	p_xel_attribute24               in varchar2,
	p_xel_attribute25               in varchar2,
	p_xel_attribute26               in varchar2,
	p_xel_attribute27               in varchar2,
	p_xel_attribute28               in varchar2,
	p_xel_attribute29               in varchar2,
	p_xel_attribute30               in varchar2,
	p_defined_balance_id            in number,
        p_last_update_date              in date,
        p_creation_date                 in date,
        p_last_updated_by               in number,
        p_last_update_login             in number,
        p_created_by                    in number,
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
  l_rec.ext_data_elmt_id                 := p_ext_data_elmt_id;
  l_rec.name                             := p_name;
  l_rec.xml_tag_name                     := p_xml_tag_name ;
  l_rec.data_elmt_typ_cd                 := p_data_elmt_typ_cd;
  l_rec.data_elmt_rl                     := p_data_elmt_rl;
  l_rec.frmt_mask_cd                     := p_frmt_mask_cd;
  l_rec.string_val                       := p_string_val;
  l_rec.dflt_val                         := p_dflt_val;
  l_rec.max_length_num                   := p_max_length_num;
  l_rec.just_cd                          := p_just_cd;
  l_rec.ttl_fnctn_cd		   	 := p_ttl_fnctn_cd;
  l_rec.ttl_cond_oper_cd 		 := p_ttl_cond_oper_cd;
  l_rec.ttl_cond_val			 := p_ttl_cond_val;
  l_rec.ttl_sum_ext_data_elmt_id	 := p_ttl_sum_ext_data_elmt_id;
  l_rec.ttl_cond_ext_data_elmt_id	 := p_ttl_cond_ext_data_elmt_id;
  l_rec.ext_fld_id                       := p_ext_fld_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.xel_attribute_category           := p_xel_attribute_category;
  l_rec.xel_attribute1                   := p_xel_attribute1;
  l_rec.xel_attribute2                   := p_xel_attribute2;
  l_rec.xel_attribute3                   := p_xel_attribute3;
  l_rec.xel_attribute4                   := p_xel_attribute4;
  l_rec.xel_attribute5                   := p_xel_attribute5;
  l_rec.xel_attribute6                   := p_xel_attribute6;
  l_rec.xel_attribute7                   := p_xel_attribute7;
  l_rec.xel_attribute8                   := p_xel_attribute8;
  l_rec.xel_attribute9                   := p_xel_attribute9;
  l_rec.xel_attribute10                  := p_xel_attribute10;
  l_rec.xel_attribute11                  := p_xel_attribute11;
  l_rec.xel_attribute12                  := p_xel_attribute12;
  l_rec.xel_attribute13                  := p_xel_attribute13;
  l_rec.xel_attribute14                  := p_xel_attribute14;
  l_rec.xel_attribute15                  := p_xel_attribute15;
  l_rec.xel_attribute16                  := p_xel_attribute16;
  l_rec.xel_attribute17                  := p_xel_attribute17;
  l_rec.xel_attribute18                  := p_xel_attribute18;
  l_rec.xel_attribute19                  := p_xel_attribute19;
  l_rec.xel_attribute20                  := p_xel_attribute20;
  l_rec.xel_attribute21                  := p_xel_attribute21;
  l_rec.xel_attribute22                  := p_xel_attribute22;
  l_rec.xel_attribute23                  := p_xel_attribute23;
  l_rec.xel_attribute24                  := p_xel_attribute24;
  l_rec.xel_attribute25                  := p_xel_attribute25;
  l_rec.xel_attribute26                  := p_xel_attribute26;
  l_rec.xel_attribute27                  := p_xel_attribute27;
  l_rec.xel_attribute28                  := p_xel_attribute28;
  l_rec.xel_attribute29                  := p_xel_attribute29;
  l_rec.xel_attribute30                  := p_xel_attribute30;
  l_rec.defined_balance_id               := p_defined_balance_id;
  l_rec.last_update_date                 := p_last_update_date;
  l_rec.creation_date                    := p_creation_date;
  l_rec.last_updated_by                  := p_last_updated_by;
  l_rec.last_update_login                := p_last_update_login;
  l_rec.created_by                       := p_created_by;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_xel_shd;

/
