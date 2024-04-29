--------------------------------------------------------
--  DDL for Package Body PAY_PUT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PUT_SHD" as
/* $Header: pyputrhi.pkb 115.0 2003/09/23 08:07 tvankayl noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_put_shd.';  -- Global package name
--
-- The following two global variables are only to be used
-- by the chk_compatible_startup_mode function.
--
g_CSMC_business_group_id      number         default null;
g_CSMC_legislation_code       varchar2(150)  default null;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_startup_mode_compatible >----------------------|
-- ----------------------------------------------------------------------------
function chk_startup_mode_compatible
(p_parent_bgid    in number
,p_parent_legcode in varchar2
,p_child_bgid     in number
,p_child_legcode  in varchar2
) return boolean is
--
cursor csr_legcode(p_business_group_id in number) is
select legislation_code
from   per_business_groups_perf
where  business_group_id = p_business_group_id;
--
l_legcode varchar2(150);
begin
  --
  -- Parent startup mode is GENERIC. Anything is compatible in this case.
  --
  if p_parent_bgid is null and p_parent_legcode is null then
    return true;
  --
  -- Parent startup mode is USER. Child is only compatible if it has a
  -- matching BUSINESS_GROUP_ID.
  --
  elsif p_parent_bgid is not null then
    return p_parent_bgid = p_child_bgid;
  --
  -- Parent startup mode is STARTUP. Match is either on LEGISLATION_CODE
  -- or if child BUSINESS_GROUP belongs to the parent's legislation.
  --
  elsif p_parent_legcode is not null then
    if p_parent_legcode = p_child_legcode then
      return true;
    --
    -- Look for cached LEGISLATION_CODE.
    --
    elsif p_child_bgid = g_CSMC_business_group_id then
      return p_parent_legcode = g_CSMC_legislation_code;
    --
    -- Update the cached LEGISLATION_CODE from the database and try again.
    --
    else
      open csr_legcode(p_business_group_id => p_child_bgid);
      fetch csr_legcode
      into  l_legcode;
      if csr_legcode%notfound then
        close csr_legcode;
        hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
        hr_utility.raise_error;
      end if;
      close csr_legcode;
      --
      g_CSMC_business_group_id := p_child_bgid;
      g_CSMC_legislation_code := l_legcode;
      return p_parent_legcode = g_CSMC_legislation_code;
    end if;
  end if;
  return false;
end chk_startup_mode_compatible;
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
  l_proc        varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'PAY_USER_TABLES_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_USER_TABLES_UK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_UTAB_RANGE_OR_MATCH_CHK') Then
    fnd_message.set_name('PAY', 'HR_52966_INVALID_LOOKUP');
    fnd_message.set_token('COLUMN', 'RANGE_OR_MATCH');
    fnd_message.set_token('LOOKUP_TYPE','RANGE_MATCH');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_UTAB_USER_KEY_UNITS_CHK') Then
    fnd_message.set_name('PAY', 'HR_52966_INVALID_LOOKUP');
    fnd_message.set_token('COLUMN', 'USER_KEY_UNITS');
    fnd_message.set_token('LOOKUP_TYPE','DATA_TYPE');
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
  (p_user_table_id                        in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       user_table_id
      ,business_group_id
      ,legislation_code
      ,range_or_match
      ,user_key_units
      ,user_table_name
      ,user_row_title
      ,object_version_number
    from        pay_user_tables
    where       user_table_id = p_user_table_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_user_table_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_user_table_id
        = pay_put_shd.g_old_rec.user_table_id and
        p_object_version_number
        = pay_put_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pay_put_shd.g_old_rec;
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
          <> pay_put_shd.g_old_rec.object_version_number) Then
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
  (p_user_table_id                        in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       user_table_id
      ,business_group_id
      ,legislation_code
      ,range_or_match
      ,user_key_units
      ,user_table_name
      ,user_row_title
      ,object_version_number
    from        pay_user_tables
    where       user_table_id = p_user_table_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'USER_TABLE_ID'
    ,p_argument_value     => p_user_table_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pay_put_shd.g_old_rec;
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
      <> pay_put_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pay_user_tables');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_user_table_id                  in number
  ,p_business_group_id              in number
  ,p_legislation_code               in varchar2
  ,p_range_or_match                 in varchar2
  ,p_user_key_units                 in varchar2
  ,p_user_table_name                in varchar2
  ,p_user_row_title                 in varchar2
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
  l_rec.user_table_id                    := p_user_table_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.range_or_match                   := p_range_or_match;
  l_rec.user_key_units                   := p_user_key_units;
  l_rec.user_table_name                  := p_user_table_name;
  l_rec.user_row_title                   := p_user_row_title;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pay_put_shd;

/
