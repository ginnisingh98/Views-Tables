--------------------------------------------------------
--  DDL for Package Body HXC_TCC_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TCC_SHD" as
/* $Header: hxctccrhi.pkb 120.3 2006/07/07 06:27:47 gsirigin noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_tcc_shd.';  -- Global package name

g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
Begin
  --
  Return (nvl(g_api_dml, false));
  --
End return_api_dml_status;
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
  If (p_constraint_name = 'HXC_MAPPING_COMPS_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
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
  (p_time_category_comp_id                in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
           time_category_comp_id
          ,time_category_id
          ,ref_time_category_id
          ,component_type_id
          ,flex_value_set_id
          ,value_id
          ,is_null
          ,equal_to
          ,type
          ,object_version_number
    from	hxc_time_category_comps
    where	time_category_comp_id = p_time_category_comp_id;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_time_category_comp_id is null and
      p_object_version_number is null
     ) Then

    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false

    l_fct_ret := false;
  Else
    If (p_time_category_comp_id
        = hxc_tcc_shd.g_old_rec.time_category_comp_id and
        p_object_version_number
        = hxc_tcc_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into hxc_tcc_shd.g_old_rec;
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
          <> hxc_tcc_shd.g_old_rec.object_version_number) Then
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
  (p_time_category_comp_id                in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is

    select
           time_category_comp_id
          ,time_category_id
          ,ref_time_category_id
          ,component_type_id
          ,flex_value_set_id
          ,value_id
          ,is_null
          ,equal_to
          ,type
          ,object_version_number
    from	hxc_time_category_comps
    where	time_category_comp_id = p_time_category_comp_id
    for	update nowait;
--
  l_proc	varchar2(72);
--
Begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'lck';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'TIME_CATEGORY_COMP_ID'
    ,p_argument_value     => p_time_category_comp_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into hxc_tcc_shd.g_old_rec;
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
      <> hxc_tcc_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'hxc_time_category_comps');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (
   p_time_category_comp_id          in number
  ,p_time_category_id               in number
  ,p_ref_time_category_id           in number
  ,p_component_type_id              in number
  ,p_flex_value_set_id              in number
  ,p_value_id                       in varchar2
  ,p_is_null                        in varchar2
  ,p_equal_to                       in varchar2
  ,p_type                           in varchar2
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
  l_rec.time_category_comp_id            := p_time_category_comp_id;
  l_rec.time_category_id                 := p_time_category_id;
  l_rec.ref_time_category_id             := p_ref_time_category_id;
  l_rec.component_type_id                := p_component_type_id;
  l_rec.flex_value_set_id                := p_flex_value_set_id;
  l_rec.value_id                         := p_value_id;
  l_rec.is_null                          := p_is_null;
  l_rec.equal_to                         := p_equal_to;
  l_rec.type                             := p_type;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end hxc_tcc_shd;

/
