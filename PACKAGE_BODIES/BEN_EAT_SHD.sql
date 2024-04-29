--------------------------------------------------------
--  DDL for Package Body BEN_EAT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EAT_SHD" as
/* $Header: beeatrhi.pkb 115.11 2002/12/16 11:53:54 vsethi ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_eat_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_ACTN_TYP_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  Elsif(p_constraint_name = 'BEN_CM_TYP_USG_F_FK1') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_CM_TYP_USG_F');
  Elsif(p_constraint_name = 'BEN_POPL_ACTN_TYP_F_FK1') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_POPL_ACTN_TYP_F');
  Elsif(p_constraint_name = 'BEN_PRTT_ENRT_ACTN_F_FK2') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_PRTT_ENRT_ACTN_F');
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
  p_actn_typ_id                        in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		actn_typ_id,
	business_group_id,
	type_cd,
	name,
        description,
	eat_attribute_category,
	eat_attribute1,
	eat_attribute2,
	eat_attribute3,
	eat_attribute4,
	eat_attribute5,
	eat_attribute6,
	eat_attribute7,
	eat_attribute8,
	eat_attribute9,
	eat_attribute10,
	eat_attribute11,
	eat_attribute12,
	eat_attribute13,
	eat_attribute14,
	eat_attribute15,
	eat_attribute16,
	eat_attribute17,
	eat_attribute18,
	eat_attribute19,
	eat_attribute20,
	eat_attribute21,
	eat_attribute22,
	eat_attribute23,
	eat_attribute24,
	eat_attribute25,
	eat_attribute26,
	eat_attribute27,
	eat_attribute28,
	eat_attribute29,
	eat_attribute30,
	object_version_number
    from	ben_actn_typ
    where	actn_typ_id = p_actn_typ_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_actn_typ_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_actn_typ_id = g_old_rec.actn_typ_id and
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
  p_actn_typ_id                        in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	actn_typ_id,
	business_group_id,
	type_cd,
	name,
        description,
	eat_attribute_category,
	eat_attribute1,
	eat_attribute2,
	eat_attribute3,
	eat_attribute4,
	eat_attribute5,
	eat_attribute6,
	eat_attribute7,
	eat_attribute8,
	eat_attribute9,
	eat_attribute10,
	eat_attribute11,
	eat_attribute12,
	eat_attribute13,
	eat_attribute14,
	eat_attribute15,
	eat_attribute16,
	eat_attribute17,
	eat_attribute18,
	eat_attribute19,
	eat_attribute20,
	eat_attribute21,
	eat_attribute22,
	eat_attribute23,
	eat_attribute24,
	eat_attribute25,
	eat_attribute26,
	eat_attribute27,
	eat_attribute28,
	eat_attribute29,
	eat_attribute30,
	object_version_number
    from	ben_actn_typ
    where	actn_typ_id = p_actn_typ_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ben_actn_typ');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_actn_typ_id                   in number,
	p_business_group_id             in number,
	p_type_cd                       in varchar2,
	p_name                          in varchar2,
        p_description                   in varchar2,
	p_eat_attribute_category        in varchar2,
	p_eat_attribute1                in varchar2,
	p_eat_attribute2                in varchar2,
	p_eat_attribute3                in varchar2,
	p_eat_attribute4                in varchar2,
	p_eat_attribute5                in varchar2,
	p_eat_attribute6                in varchar2,
	p_eat_attribute7                in varchar2,
	p_eat_attribute8                in varchar2,
	p_eat_attribute9                in varchar2,
	p_eat_attribute10               in varchar2,
	p_eat_attribute11               in varchar2,
	p_eat_attribute12               in varchar2,
	p_eat_attribute13               in varchar2,
	p_eat_attribute14               in varchar2,
	p_eat_attribute15               in varchar2,
	p_eat_attribute16               in varchar2,
	p_eat_attribute17               in varchar2,
	p_eat_attribute18               in varchar2,
	p_eat_attribute19               in varchar2,
	p_eat_attribute20               in varchar2,
	p_eat_attribute21               in varchar2,
	p_eat_attribute22               in varchar2,
	p_eat_attribute23               in varchar2,
	p_eat_attribute24               in varchar2,
	p_eat_attribute25               in varchar2,
	p_eat_attribute26               in varchar2,
	p_eat_attribute27               in varchar2,
	p_eat_attribute28               in varchar2,
	p_eat_attribute29               in varchar2,
	p_eat_attribute30               in varchar2,
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
  l_rec.actn_typ_id                      := p_actn_typ_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.type_cd                          := p_type_cd;
  l_rec.name                             := p_name;
  l_rec.description                      := p_description;
  l_rec.eat_attribute_category           := p_eat_attribute_category;
  l_rec.eat_attribute1                   := p_eat_attribute1;
  l_rec.eat_attribute2                   := p_eat_attribute2;
  l_rec.eat_attribute3                   := p_eat_attribute3;
  l_rec.eat_attribute4                   := p_eat_attribute4;
  l_rec.eat_attribute5                   := p_eat_attribute5;
  l_rec.eat_attribute6                   := p_eat_attribute6;
  l_rec.eat_attribute7                   := p_eat_attribute7;
  l_rec.eat_attribute8                   := p_eat_attribute8;
  l_rec.eat_attribute9                   := p_eat_attribute9;
  l_rec.eat_attribute10                  := p_eat_attribute10;
  l_rec.eat_attribute11                  := p_eat_attribute11;
  l_rec.eat_attribute12                  := p_eat_attribute12;
  l_rec.eat_attribute13                  := p_eat_attribute13;
  l_rec.eat_attribute14                  := p_eat_attribute14;
  l_rec.eat_attribute15                  := p_eat_attribute15;
  l_rec.eat_attribute16                  := p_eat_attribute16;
  l_rec.eat_attribute17                  := p_eat_attribute17;
  l_rec.eat_attribute18                  := p_eat_attribute18;
  l_rec.eat_attribute19                  := p_eat_attribute19;
  l_rec.eat_attribute20                  := p_eat_attribute20;
  l_rec.eat_attribute21                  := p_eat_attribute21;
  l_rec.eat_attribute22                  := p_eat_attribute22;
  l_rec.eat_attribute23                  := p_eat_attribute23;
  l_rec.eat_attribute24                  := p_eat_attribute24;
  l_rec.eat_attribute25                  := p_eat_attribute25;
  l_rec.eat_attribute26                  := p_eat_attribute26;
  l_rec.eat_attribute27                  := p_eat_attribute27;
  l_rec.eat_attribute28                  := p_eat_attribute28;
  l_rec.eat_attribute29                  := p_eat_attribute29;
  l_rec.eat_attribute30                  := p_eat_attribute30;
  l_rec.object_version_number            := p_object_version_number;
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
  delete from ben_actn_typ_tl t
  where not exists
    (select null
    from ben_actn_typ_tl b
    where b.actn_typ_id = t.actn_typ_id
    );

  update ben_actn_typ_tl t set (
      name,
      description,
      type_cd
    ) = (select
      b.name,
      b.description,
      b.type_cd
    from ben_actn_typ_tl b
    where b.actn_typ_id = t.actn_typ_id
    and b.language = t.source_lang)
  where (
      t.actn_typ_id,
      t.language
  ) in (select
      subt.actn_typ_id,
      subt.language
    from ben_actn_typ_tl subb, ben_actn_typ_tl subt
    where subb.actn_typ_id = subt.actn_typ_id
    and   subb.language = subt.source_lang
    and (subb.name <> subt.name
        or  subb.description <> subt.description
        or  subb.type_cd <> subt.type_cd
    ));
  insert into ben_actn_typ_tl (
    actn_typ_id,
    name,
    description,
    language,
    type_cd,
    source_lang,
    last_update_date,
    last_updated_by,
    last_update_login,
    created_by,
    creation_date
  ) select
    b.actn_typ_id,
    b.name,
    b.description,
    l.language_code,
    b.type_cd,
    b.source_lang,
    b.last_update_date,
    b.last_updated_by,
    b.last_update_login,
    b.created_by,
    b.creation_date
  from ben_actn_typ_tl b, fnd_languages l
  where l.installed_flag in ('I', 'B')
  and b.language = userenv('LANG')
  and not exists
    (select null
    from ben_actn_typ_tl t
    where t.actn_typ_id = b.actn_typ_id
    and   t.language = l.language_code);
end add_language;
--
end ben_eat_shd;

/
