--------------------------------------------------------
--  DDL for Package Body BEN_BNR_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BNR_SHD" as
/* $Header: bebnrrhi.pkb 120.0 2005/05/28 00:46:03 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_bnr_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_RPTG_GRP_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_RPTG_GRP_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_PL_REGN_FK2') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_PL_REGN_F');
  ElsIf (p_constraint_name = 'BEN_POPL_RPTG_GRP_FK1') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_POPL_RPTG_GRP_F');
  ElsIf (p_constraint_name = 'BEN_PL_REGY_BOD_FK1') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_PL_REGY_BOD_F');
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
  p_rptg_grp_id                        in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		rptg_grp_id,
	name,
	business_group_id,
	rptg_prps_cd,
	rpg_desc,
	bnr_attribute_category,
	bnr_attribute1,
	bnr_attribute2,
	bnr_attribute3,
	bnr_attribute4,
	bnr_attribute5,
	bnr_attribute6,
	bnr_attribute7,
	bnr_attribute8,
	bnr_attribute9,
	bnr_attribute10,
	bnr_attribute11,
	bnr_attribute12,
	bnr_attribute13,
	bnr_attribute14,
	bnr_attribute15,
	bnr_attribute16,
	bnr_attribute17,
	bnr_attribute18,
	bnr_attribute19,
	bnr_attribute20,
	bnr_attribute21,
	bnr_attribute22,
	bnr_attribute23,
	bnr_attribute24,
	bnr_attribute25,
	bnr_attribute26,
	bnr_attribute27,
	bnr_attribute28,
	bnr_attribute29,
	bnr_attribute30,
        function_code,
        legislation_code,
	object_version_number,
	ordr_num                            --iRec
    from	ben_rptg_grp
    where	rptg_grp_id = p_rptg_grp_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_rptg_grp_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_rptg_grp_id = g_old_rec.rptg_grp_id and
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
  p_rptg_grp_id                        in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	rptg_grp_id,
	name,
	business_group_id,
	rptg_prps_cd,
	rpg_desc,
	bnr_attribute_category,
	bnr_attribute1,
	bnr_attribute2,
	bnr_attribute3,
	bnr_attribute4,
	bnr_attribute5,
	bnr_attribute6,
	bnr_attribute7,
	bnr_attribute8,
	bnr_attribute9,
	bnr_attribute10,
	bnr_attribute11,
	bnr_attribute12,
	bnr_attribute13,
	bnr_attribute14,
	bnr_attribute15,
	bnr_attribute16,
	bnr_attribute17,
	bnr_attribute18,
	bnr_attribute19,
	bnr_attribute20,
	bnr_attribute21,
	bnr_attribute22,
	bnr_attribute23,
	bnr_attribute24,
	bnr_attribute25,
	bnr_attribute26,
	bnr_attribute27,
	bnr_attribute28,
	bnr_attribute29,
	bnr_attribute30,
        function_code,
        legislation_code,
	object_version_number,
	ordr_num                      --iRec
    from	ben_rptg_grp
    where	rptg_grp_id = p_rptg_grp_id
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
    fnd_message.set_token('TABLE_NAME', 'ben_rptg_grp');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_rptg_grp_id                   in number,
	p_name                          in varchar2,
	p_business_group_id             in number,
	p_rptg_prps_cd                  in varchar2,
	p_rpg_desc                      in varchar2,
	p_bnr_attribute_category        in varchar2,
	p_bnr_attribute1                in varchar2,
	p_bnr_attribute2                in varchar2,
	p_bnr_attribute3                in varchar2,
	p_bnr_attribute4                in varchar2,
	p_bnr_attribute5                in varchar2,
	p_bnr_attribute6                in varchar2,
	p_bnr_attribute7                in varchar2,
	p_bnr_attribute8                in varchar2,
	p_bnr_attribute9                in varchar2,
	p_bnr_attribute10               in varchar2,
	p_bnr_attribute11               in varchar2,
	p_bnr_attribute12               in varchar2,
	p_bnr_attribute13               in varchar2,
	p_bnr_attribute14               in varchar2,
	p_bnr_attribute15               in varchar2,
	p_bnr_attribute16               in varchar2,
	p_bnr_attribute17               in varchar2,
	p_bnr_attribute18               in varchar2,
	p_bnr_attribute19               in varchar2,
	p_bnr_attribute20               in varchar2,
	p_bnr_attribute21               in varchar2,
	p_bnr_attribute22               in varchar2,
	p_bnr_attribute23               in varchar2,
	p_bnr_attribute24               in varchar2,
	p_bnr_attribute25               in varchar2,
	p_bnr_attribute26               in varchar2,
	p_bnr_attribute27               in varchar2,
	p_bnr_attribute28               in varchar2,
	p_bnr_attribute29               in varchar2,
	p_bnr_attribute30               in varchar2,
        p_function_code                 in varchar2,
        p_legislation_code              in varchar2,
	p_object_version_number         in number,
	p_ordr_num                      in number                      --iRec
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
  l_rec.rptg_grp_id                      := p_rptg_grp_id;
  l_rec.name                             := p_name;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.rptg_prps_cd                     := p_rptg_prps_cd;
  l_rec.rpg_desc                         := p_rpg_desc;
  l_rec.bnr_attribute_category           := p_bnr_attribute_category;
  l_rec.bnr_attribute1                   := p_bnr_attribute1;
  l_rec.bnr_attribute2                   := p_bnr_attribute2;
  l_rec.bnr_attribute3                   := p_bnr_attribute3;
  l_rec.bnr_attribute4                   := p_bnr_attribute4;
  l_rec.bnr_attribute5                   := p_bnr_attribute5;
  l_rec.bnr_attribute6                   := p_bnr_attribute6;
  l_rec.bnr_attribute7                   := p_bnr_attribute7;
  l_rec.bnr_attribute8                   := p_bnr_attribute8;
  l_rec.bnr_attribute9                   := p_bnr_attribute9;
  l_rec.bnr_attribute10                  := p_bnr_attribute10;
  l_rec.bnr_attribute11                  := p_bnr_attribute11;
  l_rec.bnr_attribute12                  := p_bnr_attribute12;
  l_rec.bnr_attribute13                  := p_bnr_attribute13;
  l_rec.bnr_attribute14                  := p_bnr_attribute14;
  l_rec.bnr_attribute15                  := p_bnr_attribute15;
  l_rec.bnr_attribute16                  := p_bnr_attribute16;
  l_rec.bnr_attribute17                  := p_bnr_attribute17;
  l_rec.bnr_attribute18                  := p_bnr_attribute18;
  l_rec.bnr_attribute19                  := p_bnr_attribute19;
  l_rec.bnr_attribute20                  := p_bnr_attribute20;
  l_rec.bnr_attribute21                  := p_bnr_attribute21;
  l_rec.bnr_attribute22                  := p_bnr_attribute22;
  l_rec.bnr_attribute23                  := p_bnr_attribute23;
  l_rec.bnr_attribute24                  := p_bnr_attribute24;
  l_rec.bnr_attribute25                  := p_bnr_attribute25;
  l_rec.bnr_attribute26                  := p_bnr_attribute26;
  l_rec.bnr_attribute27                  := p_bnr_attribute27;
  l_rec.bnr_attribute28                  := p_bnr_attribute28;
  l_rec.bnr_attribute29                  := p_bnr_attribute29;
  l_rec.bnr_attribute30                  := p_bnr_attribute30;
  l_rec.function_code                    := p_function_code;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.ordr_num                         := p_ordr_num;                      --iRec
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--

-- ----------------------------------------------------------------------------
-- |--------------------------<add_language>----------------------------------|
-- ----------------------------------------------------------------------------
Procedure add_language
is
begin

  delete from BEN_RPTG_GRP_TL T
  where not exists
    (select NULL
    from BEN_RPTG_GRP B
    where B.RPTG_GRP_ID = T.RPTG_GRP_ID
    );

  update ben_rptg_grp_tl t set (
      function_code,
      name
    ) = (select
      b.function_code,
      b.name
    from ben_rptg_grp_tl b
    where b.RPTG_GRP_ID = t.RPTG_GRP_ID
    and b.language = t.source_lang)
  where (
      t.RPTG_GRP_ID,
      t.language
  ) in (select
      subt.RPTG_GRP_ID,
      subt.language
    from ben_rptg_grp_tl subb, ben_rptg_grp_tl subt
    where subb.RPTG_GRP_ID = subt.RPTG_GRP_ID
    and   subb.language = subt.source_lang
    and (subb.name <> subt.name
         or subb.function_code <> subt.function_code
  ));

  insert into ben_rptg_grp_tl (
    RPTG_GRP_ID,
    function_code,
    name,
    language,
    source_lang,
    last_update_date,
    last_updated_by,
    last_update_login,
    created_by,
    creation_date
  ) select
    b.RPTG_GRP_ID,
    b.function_code,
    b.name,
    l.language_code,
    b.source_lang,
    b.last_update_date,
    b.last_updated_by,
    b.last_update_login,
    b.created_by,
    b.creation_date
  from ben_rptg_grp_tl b, fnd_languages l
  where l.installed_flag in ('I', 'B')
  and b.language = userenv('LANG')
  and not exists
    (select null
    from ben_rptg_grp_tl t
    where t.rptg_grp_id = b.rptg_grp_id
    and   t.language = l.language_code);
end add_language;
--
end ben_bnr_shd;

/
