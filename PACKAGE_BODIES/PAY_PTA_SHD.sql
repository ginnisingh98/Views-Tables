--------------------------------------------------------
--  DDL for Package Body PAY_PTA_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PTA_SHD" as
/* $Header: pyptarhi.pkb 120.0 2005/05/29 07:56:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_pta_shd.';  -- Global package name
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
  If (p_constraint_name = 'PAY_DATED_TABLES_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_DATED_TABLES_UK') Then
     -- Bug no. 3526519. Duplicate record message was not clear.
    fnd_message.set_name('PAY', 'PER_7901_SYS_DUPLICATE_RECORDS');
    fnd_message.raise_error;
/*    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;  */
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
  (p_dated_table_id                       in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       dated_table_id
      ,table_name
      ,application_id
      ,surrogate_key_name
      ,start_date_name
      ,end_date_name
      ,business_group_id
      ,legislation_code
      ,object_version_number
      ,dyn_trigger_type
      ,dyn_trigger_package_name
      ,dyn_trig_pkg_generated
    from	pay_dated_tables
    where	dated_table_id = p_dated_table_id;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_dated_table_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_dated_table_id
        = pay_pta_shd.g_old_rec.dated_table_id and
        p_object_version_number
        = pay_pta_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pay_pta_shd.g_old_rec;
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
          <> pay_pta_shd.g_old_rec.object_version_number) Then
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
  (p_dated_table_id                       in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       dated_table_id
      ,table_name
      ,application_id
      ,surrogate_key_name
      ,start_date_name
      ,end_date_name
      ,business_group_id
      ,legislation_code
      ,object_version_number
      ,dyn_trigger_type
      ,dyn_trigger_package_name
      ,dyn_trig_pkg_generated
    from	pay_dated_tables
    where	dated_table_id = p_dated_table_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'DATED_TABLE_ID'
    ,p_argument_value     => p_dated_table_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pay_pta_shd.g_old_rec;
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
      <> pay_pta_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pay_dated_tables');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_dated_table_id                 in number
  ,p_table_name                     in varchar2
  ,p_application_id                 in number
  ,p_surrogate_key_name             in varchar2
  ,p_start_date_name                in varchar2
  ,p_end_date_name                  in varchar2
  ,p_business_group_id              in number
  ,p_legislation_code               in varchar2
  ,p_object_version_number          in number
  ,p_dyn_trigger_type               in varchar2
  ,p_dyn_trigger_package_name       in varchar2
  ,p_dyn_trig_pkg_generated         in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.dated_table_id                   := p_dated_table_id;
  l_rec.table_name                       := p_table_name;
  l_rec.application_id                   := p_application_id;
  l_rec.surrogate_key_name               := p_surrogate_key_name;
  l_rec.start_date_name                  := p_start_date_name;
  l_rec.end_date_name                    := p_end_date_name;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.dyn_trigger_type                 := p_dyn_trigger_type;
  l_rec.dyn_trigger_package_name         := p_dyn_trigger_package_name;
  l_rec.dyn_trig_pkg_generated           := p_dyn_trig_pkg_generated;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pay_pta_shd;

/
