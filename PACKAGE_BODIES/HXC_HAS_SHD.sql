--------------------------------------------------------
--  DDL for Package Body HXC_HAS_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HAS_SHD" as
/* $Header: hxchasrhi.pkb 120.5 2006/06/11 12:53:42 gsirigin noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_has_shd.';  -- Global package name
g_debug boolean	:=hr_utility.debug_enabled;
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
  If (p_constraint_name = 'HXC_APPROVAL_STYLES_PK') Then
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
  (p_approval_style_id                    in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       approval_style_id
      ,object_version_number
      ,name
      ,business_group_id
      ,legislation_code
      ,description
      ,run_recipient_extensions
      ,admin_role
      ,error_admin_role
    from	hxc_approval_styles
    where	approval_style_id = p_approval_style_id;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_approval_style_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_approval_style_id
        = hxc_has_shd.g_old_rec.approval_style_id and
        p_object_version_number
        = hxc_has_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into hxc_has_shd.g_old_rec;
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
          <> hxc_has_shd.g_old_rec.object_version_number) Then
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
  (p_approval_style_id                    in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       approval_style_id
      ,object_version_number
      ,name
      ,business_group_id
      ,legislation_code
      ,description
      ,run_recipient_extensions
      ,admin_role
      ,error_admin_role
    from	hxc_approval_styles
    where	approval_style_id = p_approval_style_id
    for	update nowait;
--
  l_proc	varchar2(72);
--
Begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'lck';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'APPROVAL_STYLE_ID'
    ,p_argument_value     => p_approval_style_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into hxc_has_shd.g_old_rec;
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
      <> hxc_has_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'hxc_approval_styles');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_approval_style_id              in number
  ,p_object_version_number          in number
  ,p_name                           in varchar2
  ,p_business_group_id		    in number
  ,p_legislation_code		    in varchar2
  ,p_description                    in varchar2
  ,p_run_recipient_extensions       in varchar2
  ,p_admin_role                     in varchar2
  ,p_error_admin_role               in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.approval_style_id                := p_approval_style_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.name                             := p_name;
  l_rec.business_group_id		 := p_business_group_id;
  l_rec.legislation_code		 := p_legislation_code;
  l_rec.description                      := p_description;
  l_rec.run_recipient_extensions         := p_run_recipient_extensions;
  l_rec.admin_role		         := p_admin_role;
  l_rec.error_admin_role                 := p_error_admin_role;

  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end hxc_has_shd;

/
