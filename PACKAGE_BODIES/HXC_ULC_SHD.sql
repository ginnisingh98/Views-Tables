--------------------------------------------------------
--  DDL for Package Body HXC_ULC_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ULC_SHD" as
/* $Header: hxculcrhi.pkb 120.2 2005/09/23 06:07:43 rchennur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_ulc_shd.';  -- Global package name
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
  If (p_constraint_name = 'HXC_LAYOUT_COMPONENTS_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HXC_LAYOUT_COMPONENTS_FK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HXC_LAYOUT_COMPONENTS_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HXC_LAYOUT_COMPONENTS_UK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
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
  (p_layout_component_id                  in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the hxc Schema
  --
  Cursor C_Sel1 is
    select
       layout_component_id
      ,layout_id
      ,parent_component_id
      ,component_name
      ,component_value
      ,sequence
      ,name_value_string
      ,region_code
      ,region_code_app_id
      ,attribute_code
      ,attribute_code_app_id
      ,object_version_number
      ,layout_comp_definition_id
      ,component_alias
      ,parent_bean
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
    from	hxc_layout_components
    where	layout_component_id = p_layout_component_id;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_layout_component_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_layout_component_id
        = hxc_ulc_shd.g_old_rec.layout_component_id and
        p_object_version_number
        = hxc_ulc_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into hxc_ulc_shd.g_old_rec;
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
          <> hxc_ulc_shd.g_old_rec.object_version_number) Then
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
  (p_layout_component_id                  in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the hxc Schema
--
  Cursor C_Sel1 is
    select
       layout_component_id
      ,layout_id
      ,parent_component_id
      ,component_name
      ,component_value
      ,sequence
      ,name_value_string
      ,region_code
      ,region_code_app_id
      ,attribute_code
      ,attribute_code_app_id
      ,object_version_number
      ,layout_comp_definition_id
      ,component_alias
      ,parent_bean
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
    from	hxc_layout_components
    where	layout_component_id = p_layout_component_id
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
    ,p_argument           => 'LAYOUT_COMPONENT_ID'
    ,p_argument_value     => p_layout_component_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into hxc_ulc_shd.g_old_rec;
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
      <> hxc_ulc_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'hxc_layout_components');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_layout_component_id            in number
  ,p_layout_id                      in number
  ,p_parent_component_id            in number
  ,p_component_name                 in varchar2
  ,p_component_value                in varchar2
  ,p_sequence                       in number
  ,p_name_value_string              in varchar2
  ,p_region_code                    in varchar2
  ,p_region_code_app_id             in number
  ,p_attribute_code                 in varchar2
  ,p_attribute_code_app_id          in number
  ,p_object_version_number          in number
  ,p_layout_comp_definition_id      in number
  ,p_component_alias                in varchar2
  ,p_parent_bean                    in varchar2
  ,p_attribute1                     in varchar2
  ,p_attribute2                     in varchar2
  ,p_attribute3                     in varchar2
  ,p_attribute4                     in varchar2
  ,p_attribute5                     in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.layout_component_id              := p_layout_component_id;
  l_rec.layout_id                        := p_layout_id;
  l_rec.parent_component_id              := p_parent_component_id;
  l_rec.component_name                   := p_component_name;
  l_rec.component_value                  := p_component_value;
  l_rec.sequence                         := p_sequence;
  l_rec.name_value_string                := p_name_value_string;
  l_rec.region_code                      := p_region_code;
  l_rec.region_code_app_id               := p_region_code_app_id;
  l_rec.attribute_code                   := p_attribute_code;
  l_rec.attribute_code_app_id            := p_attribute_code_app_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.layout_comp_definition_id        := p_layout_comp_definition_id;
  l_rec.component_alias                  := p_component_alias;
  l_rec.parent_bean                      := p_parent_bean;
  l_rec.attribute1                       := p_attribute1;
  l_rec.attribute2                       := p_attribute2;
  l_rec.attribute3                       := p_attribute3;
  l_rec.attribute4                       := p_attribute4;
  l_rec.attribute5                       := p_attribute5;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end hxc_ulc_shd;

/
