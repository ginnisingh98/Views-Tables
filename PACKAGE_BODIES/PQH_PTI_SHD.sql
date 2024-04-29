--------------------------------------------------------
--  DDL for Package Body PQH_PTI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PTI_SHD" as
/* $Header: pqptirhi.pkb 120.2 2005/10/12 20:18:49 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_pti_shd.';  -- Global package name
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
  If (p_constraint_name = 'PQH_PTX_INFO_TYPES_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
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
  p_information_type                   in varchar2,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		information_type,
	active_inactive_flag,
	description,
	multiple_occurences_flag,
	legislation_code,
	object_version_number
    from	pqh_ptx_info_types
    where	information_type = p_information_type;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_information_type is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_information_type = g_old_rec.information_type and
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
  p_information_type                   in varchar2,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	information_type,
	active_inactive_flag,
	description,
	multiple_occurences_flag,
	legislation_code,
	object_version_number
    from	pqh_ptx_info_types
    where	information_type = p_information_type
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
    hr_utility.set_message_token('TABLE_NAME', 'pqh_ptx_info_types');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_information_type              in varchar2,
	p_active_inactive_flag          in varchar2,
	p_description                   in varchar2,
	p_multiple_occurences_flag      in varchar2,
	p_legislation_code              in varchar2,
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
  l_rec.information_type                 := p_information_type;
  l_rec.active_inactive_flag             := p_active_inactive_flag;
  l_rec.description                      := p_description;
  l_rec.multiple_occurences_flag         := p_multiple_occurences_flag;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< LOAD_ROW >----------------------|
-- ----------------------------------------------------------------------------
--
procedure LOAD_ROW
  (p_information_type               in  varchar2
  ,p_active_inactive_flag           in  varchar2
  ,p_description                    in  varchar2
  ,p_multiple_occurences_flag       in  varchar2
  ,p_legislation_code               in  varchar2
  ,p_owner			    in  varchar2
  ,p_last_update_date               in varchar2
  ) is
l_created_by        number;
l_last_updated_by   number;
l_creation_date        date;
l_last_update_date  date;
l_last_update_login number;
l_updated    number := 0;
cursor c0 is
   select pti.* from pqh_ptx_info_types pti
   where information_type = p_information_type
   for update;
--
l_data_migrator_mode varchar2(1);
--
begin
--
--
-- populate WHO columns
--
  /**
  if p_owner = 'SEED' then
    l_created_by := 1;
    l_last_updated_by := -1;
  else
    l_created_by := 0;
    l_last_updated_by := 0;
  end if;
  **/
     l_data_migrator_mode := hr_general.g_data_migrator_mode ;
   hr_general.g_data_migrator_mode := 'Y';
  l_last_updated_by := fnd_load_util.owner_id(p_owner);
  l_created_by := fnd_load_util.owner_id(p_owner);
    l_creation_date := nvl(to_date(p_last_update_date,'YYYY/MM/DD'),trunc(sysdate));
  l_last_update_date := nvl(to_date(p_last_update_date,'YYYY/MM/DD'),trunc(sysdate));
/**
  l_creation_date := trunc(sysdate);
  l_last_update_date := trunc(sysdate);
**/
  l_last_update_login := 0;

--
  for r0 in c0 loop
    if NVL(r0.last_updated_by,-1) in (l_last_updated_by,1,-1) then
    update pqh_ptx_info_types
      set
        active_inactive_flag                = p_active_inactive_flag,
        description                         = p_description,
        multiple_occurences_flag            = p_multiple_occurences_flag,
        legislation_code                    = p_legislation_code,
        last_updated_by                     = l_last_updated_by,
        last_update_date                    = l_last_update_date,
        last_update_login                   = l_last_update_login
      where current of c0;
    end if;
    l_updated := 1;
  end loop;
  if l_updated = 0 then
    insert into pqh_ptx_info_types(
        information_type,
        active_inactive_flag,
        description,
        multiple_occurences_flag,
        legislation_code,
        object_version_number,
        last_update_date,
        last_updated_by,
        last_update_login,
        created_by,
        creation_date
      )
    Values(
        p_information_type,
        p_active_inactive_flag,
        p_description,
        p_multiple_occurences_flag,
        p_legislation_code,
        1,
        l_last_update_date,
        l_last_updated_by,
        l_last_update_login,
        l_created_by,
        l_creation_date
      );
  end if;
   hr_general.g_data_migrator_mode := l_data_migrator_mode;
 --
End load_row;
--
end pqh_pti_shd;

/
