--------------------------------------------------------
--  DDL for Package Body HXC_ULQ_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ULQ_SHD" as
/* $Header: hxculqrhi.pkb 120.2 2005/09/23 06:26:40 rchennur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_ulq_shd.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'HXC_LAYOUT_COMP_QUALIFIERS_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HXC_LAYOUT_COMP_QUALIFIERS_UK1') Then
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
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_layout_comp_qualifier_id             in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       layout_comp_qualifier_id
      ,layout_component_id
      ,qualifier_name
      ,qualifier_attribute_category
      ,qualifier_attribute1
      ,qualifier_attribute2
      ,qualifier_attribute3
      ,qualifier_attribute4
      ,qualifier_attribute5
      ,qualifier_attribute6
      ,qualifier_attribute7
      ,qualifier_attribute8
      ,qualifier_attribute9
      ,qualifier_attribute10
      ,qualifier_attribute11
      ,qualifier_attribute12
      ,qualifier_attribute13
      ,qualifier_attribute14
      ,qualifier_attribute15
      ,qualifier_attribute16
      ,qualifier_attribute17
      ,qualifier_attribute18
      ,qualifier_attribute19
      ,qualifier_attribute20
      ,qualifier_attribute21
      ,qualifier_attribute22
      ,qualifier_attribute23
      ,qualifier_attribute24
      ,qualifier_attribute25
      ,qualifier_attribute26
      ,qualifier_attribute27
      ,qualifier_attribute28
      ,qualifier_attribute29
      ,qualifier_attribute30
      ,object_version_number
    from	hxc_layout_comp_qualifiers
    where	layout_comp_qualifier_id = p_layout_comp_qualifier_id;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_layout_comp_qualifier_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_layout_comp_qualifier_id
        = hxc_ulq_shd.g_old_rec.layout_comp_qualifier_id and
        p_object_version_number
        = hxc_ulq_shd.g_old_rec.object_version_number
       ) Then
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
      Fetch C_Sel1 Into hxc_ulq_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number
          <> hxc_ulq_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
      End If;
      l_fct_ret := true;
    End If;
  End If;
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (p_layout_comp_qualifier_id             in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the hxc Schema
--
  Cursor C_Sel1 is
    select
       layout_comp_qualifier_id
      ,layout_component_id
      ,qualifier_name
      ,qualifier_attribute_category
      ,qualifier_attribute1
      ,qualifier_attribute2
      ,qualifier_attribute3
      ,qualifier_attribute4
      ,qualifier_attribute5
      ,qualifier_attribute6
      ,qualifier_attribute7
      ,qualifier_attribute8
      ,qualifier_attribute9
      ,qualifier_attribute10
      ,qualifier_attribute11
      ,qualifier_attribute12
      ,qualifier_attribute13
      ,qualifier_attribute14
      ,qualifier_attribute15
      ,qualifier_attribute16
      ,qualifier_attribute17
      ,qualifier_attribute18
      ,qualifier_attribute19
      ,qualifier_attribute20
      ,qualifier_attribute21
      ,qualifier_attribute22
      ,qualifier_attribute23
      ,qualifier_attribute24
      ,qualifier_attribute25
      ,qualifier_attribute26
      ,qualifier_attribute27
      ,qualifier_attribute28
      ,qualifier_attribute29
      ,qualifier_attribute30
      ,object_version_number
    from	hxc_layout_comp_qualifiers
    where	layout_comp_qualifier_id = p_layout_comp_qualifier_id
    for	update nowait;
--
  l_proc	varchar2(72) ;
--
Begin
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package||'lck';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LAYOUT_COMP_QUALIFIER_ID'
    ,p_argument_value     => p_layout_comp_qualifier_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into hxc_ulq_shd.g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number
      <> hxc_ulq_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
  End If;
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
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
    fnd_message.set_token('TABLE_NAME', 'hxc_layout_comp_qualifiers');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_layout_comp_qualifier_id       in number
  ,p_layout_component_id            in number
  ,p_qualifier_name                 in varchar2
  ,p_qualifier_attribute_category   in varchar2
  ,p_qualifier_attribute1           in varchar2
  ,p_qualifier_attribute2           in varchar2
  ,p_qualifier_attribute3           in varchar2
  ,p_qualifier_attribute4           in varchar2
  ,p_qualifier_attribute5           in varchar2
  ,p_qualifier_attribute6           in varchar2
  ,p_qualifier_attribute7           in varchar2
  ,p_qualifier_attribute8           in varchar2
  ,p_qualifier_attribute9           in varchar2
  ,p_qualifier_attribute10          in varchar2
  ,p_qualifier_attribute11          in varchar2
  ,p_qualifier_attribute12          in varchar2
  ,p_qualifier_attribute13          in varchar2
  ,p_qualifier_attribute14          in varchar2
  ,p_qualifier_attribute15          in varchar2
  ,p_qualifier_attribute16          in varchar2
  ,p_qualifier_attribute17          in varchar2
  ,p_qualifier_attribute18          in varchar2
  ,p_qualifier_attribute19          in varchar2
  ,p_qualifier_attribute20          in varchar2
  ,p_qualifier_attribute21          in varchar2
  ,p_qualifier_attribute22          in varchar2
  ,p_qualifier_attribute23          in varchar2
  ,p_qualifier_attribute24          in varchar2
  ,p_qualifier_attribute25          in varchar2
  ,p_qualifier_attribute26          in varchar2
  ,p_qualifier_attribute27          in varchar2
  ,p_qualifier_attribute28          in varchar2
  ,p_qualifier_attribute29          in varchar2
  ,p_qualifier_attribute30          in varchar2
  ,p_object_version_number          in number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.layout_comp_qualifier_id         := p_layout_comp_qualifier_id;
  l_rec.layout_component_id              := p_layout_component_id;
  l_rec.qualifier_name                   := p_qualifier_name;
  l_rec.qualifier_attribute_category     := p_qualifier_attribute_category;
  l_rec.qualifier_attribute1             := p_qualifier_attribute1;
  l_rec.qualifier_attribute2             := p_qualifier_attribute2;
  l_rec.qualifier_attribute3             := p_qualifier_attribute3;
  l_rec.qualifier_attribute4             := p_qualifier_attribute4;
  l_rec.qualifier_attribute5             := p_qualifier_attribute5;
  l_rec.qualifier_attribute6             := p_qualifier_attribute6;
  l_rec.qualifier_attribute7             := p_qualifier_attribute7;
  l_rec.qualifier_attribute8             := p_qualifier_attribute8;
  l_rec.qualifier_attribute9             := p_qualifier_attribute9;
  l_rec.qualifier_attribute10            := p_qualifier_attribute10;
  l_rec.qualifier_attribute11            := p_qualifier_attribute11;
  l_rec.qualifier_attribute12            := p_qualifier_attribute12;
  l_rec.qualifier_attribute13            := p_qualifier_attribute13;
  l_rec.qualifier_attribute14            := p_qualifier_attribute14;
  l_rec.qualifier_attribute15            := p_qualifier_attribute15;
  l_rec.qualifier_attribute16            := p_qualifier_attribute16;
  l_rec.qualifier_attribute17            := p_qualifier_attribute17;
  l_rec.qualifier_attribute18            := p_qualifier_attribute18;
  l_rec.qualifier_attribute19            := p_qualifier_attribute19;
  l_rec.qualifier_attribute20            := p_qualifier_attribute20;
  l_rec.qualifier_attribute21            := p_qualifier_attribute21;
  l_rec.qualifier_attribute22            := p_qualifier_attribute22;
  l_rec.qualifier_attribute23            := p_qualifier_attribute23;
  l_rec.qualifier_attribute24            := p_qualifier_attribute24;
  l_rec.qualifier_attribute25            := p_qualifier_attribute25;
  l_rec.qualifier_attribute26            := p_qualifier_attribute26;
  l_rec.qualifier_attribute27            := p_qualifier_attribute27;
  l_rec.qualifier_attribute28            := p_qualifier_attribute28;
  l_rec.qualifier_attribute29            := p_qualifier_attribute29;
  l_rec.qualifier_attribute30            := p_qualifier_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end hxc_ulq_shd;

/
