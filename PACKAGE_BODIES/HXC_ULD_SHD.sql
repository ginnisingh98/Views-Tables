--------------------------------------------------------
--  DDL for Package Body HXC_ULD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ULD_SHD" as
/* $Header: hxculdrhi.pkb 120.2 2005/09/23 06:19:32 rchennur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_uld_shd.';  -- Global package name
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
  If (p_constraint_name = 'HXC_LAYOUT_COMP_DEFINITIONS_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HXC_LAYOUT_COMP_DEFINITIONS_UK1') Then
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
  (p_layout_comp_definition_id            in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the hxc Schema
  --
  Cursor C_Sel1 is
    select
       layout_comp_definition_id
      ,component_type
      ,component_class
      ,render_type
      ,object_version_number
    from	hxc_layout_comp_definitions
    where	layout_comp_definition_id = p_layout_comp_definition_id;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_layout_comp_definition_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_layout_comp_definition_id
        = hxc_uld_shd.g_old_rec.layout_comp_definition_id and
        p_object_version_number
        = hxc_uld_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into hxc_uld_shd.g_old_rec;
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
          <> hxc_uld_shd.g_old_rec.object_version_number) Then
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
  (p_layout_comp_definition_id            in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the hxc Schema
--
  Cursor C_Sel1 is
    select
       layout_comp_definition_id
      ,component_type
      ,component_class
      ,render_type
      ,object_version_number
    from	hxc_layout_comp_definitions
    where	layout_comp_definition_id = p_layout_comp_definition_id
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
    ,p_argument           => 'LAYOUT_COMP_DEFINITION_ID'
    ,p_argument_value     => p_layout_comp_definition_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into hxc_uld_shd.g_old_rec;
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
      <> hxc_uld_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'hxc_layout_comp_definitions');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_layout_comp_definition_id      in number
  ,p_component_type                 in varchar2
  ,p_component_class                in varchar2
  ,p_render_type                    in varchar2
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
  l_rec.layout_comp_definition_id        := p_layout_comp_definition_id;
  l_rec.component_type                   := p_component_type;
  l_rec.component_class                  := p_component_class;
  l_rec.render_type                      := p_render_type;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end hxc_uld_shd;

/
