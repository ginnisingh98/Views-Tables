--------------------------------------------------------
--  DDL for Package Body PER_WBI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_WBI_SHD" as
/* $Header: pewbirhi.pkb 115.0 2003/07/03 05:55:25 kavenkat noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_wbi_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc        varchar2(72) := g_package||'constraint_error';
--
Begin
  --
   If (p_constraint_name = 'PER_RI_WORKBENCH_ITEMS_PK') Then
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
  (p_workbench_item_code                  in     varchar2
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       workbench_item_code
      ,menu_id
      ,workbench_item_sequence
      ,workbench_parent_item_code
      ,workbench_item_creation_date
      ,workbench_item_type
      ,object_version_number
    from        per_ri_workbench_items
    where       workbench_item_code = p_workbench_item_code;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_workbench_item_code is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_workbench_item_code
        = per_wbi_shd.g_old_rec.workbench_item_code and
        p_object_version_number
        = per_wbi_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into per_wbi_shd.g_old_rec;
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
          <> per_wbi_shd.g_old_rec.object_version_number) Then
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
  (p_workbench_item_code                  in     varchar2
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       workbench_item_code
      ,menu_id
      ,workbench_item_sequence
      ,workbench_parent_item_code
      ,workbench_item_creation_date
      ,workbench_item_type
      ,object_version_number
    from        per_ri_workbench_items
    where       workbench_item_code = p_workbench_item_code
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'WORKBENCH_ITEM_CODE'
    ,p_argument_value     => p_workbench_item_code
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_wbi_shd.g_old_rec;
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
      <> per_wbi_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'per_ri_workbench_items');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_workbench_item_code            in varchar2
  ,p_menu_id                        in number
  ,p_workbench_item_sequence        in number
  ,p_workbench_parent_item_code     in varchar2
  ,p_workbench_item_creation_date   in date
  ,p_workbench_item_type            in varchar2
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
  l_rec.workbench_item_code              := p_workbench_item_code;
  l_rec.menu_id                          := p_menu_id;
  l_rec.workbench_item_sequence          := p_workbench_item_sequence;
  l_rec.workbench_parent_item_code       := p_workbench_parent_item_code;
  l_rec.workbench_item_creation_date     := p_workbench_item_creation_date;
  l_rec.workbench_item_type              := p_workbench_item_type;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_wbi_shd;

/
