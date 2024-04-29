--------------------------------------------------------
--  DDL for Package Body FF_ARC_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_ARC_SHD" as
/* $Header: ffarcrhi.pkb 115.4 2002/12/23 13:59:55 arashid ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ff_arc_shd.';  -- Global package name
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
  If (p_constraint_name = 'FF_ARCHIVE_ITEMS_FK1') Then
    hr_utility.set_message(800, 'FF_34956_INVALID_USER_ENTITY');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'FF_ARCHIVE_ITEMS_PK') Then
    /*Raise Generic Primary Key Constraint violation, supplying con. name*/
    hr_utility.set_message(800, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
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
  p_archive_item_id                    in number,
  p_object_version_number              in number
  )      Return Boolean Is
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	archive_item_id,
	user_entity_id,
        archive_type,
	context1,
	value,
	object_version_number
    from	ff_archive_items
    where	archive_item_id = p_archive_item_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_archive_item_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_archive_item_id = g_old_rec.archive_item_id and
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
  p_archive_item_id                    in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	archive_item_id,
	user_entity_id,
        archive_type,
	context1,
	value,
	object_version_number
    from	ff_archive_items
    where	archive_item_id = p_archive_item_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Add any mandatory argument checking here:
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'object_version_number',
     p_argument_value => p_object_version_number);
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
    hr_utility.set_message_token('TABLE_NAME', 'ff_archive_items');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_archive_item_id               in number,
	p_user_entity_id                in number,
        p_archive_type                  in varchar2,
	p_context1                      in number,
	p_value                         in varchar2,
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
  l_rec.archive_item_id                  := p_archive_item_id;
  l_rec.user_entity_id                   := p_user_entity_id;
  l_rec.archive_type                     := p_archive_type;
  l_rec.context1                         := p_context1;
  l_rec.value                            := p_value;
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
-- |-----------------------------< chk_value >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Check that the User entity exists, and that the data type is correct
-- (of the value).
--
procedure chk_value
   (p_value	     in	  ff_archive_items.value%TYPE,
    p_user_entity_id in   ff_archive_items.user_entity_id%TYPE)
is
--
proc_error      exception;
l_data_type     varchar2(1);
l_item_name     varchar2(80);
l_proc		varchar2(72)   := g_package||'chk_value';
l_conv_number   number;
l_conv_date     date;
--
-- Cursor to check that UE is the correct type
-- (X for archive items) and obtain the data
-- type.
--
cursor csr_entity_chk (c_user_entity_id number) is
 select db.data_type, db.user_name
 from ff_database_items db,
      ff_user_entities ue
 where ue.user_entity_id = c_user_entity_id
 and ue.creator_type = 'X'
 and ue.user_entity_id = db.user_entity_id;
--
Begin
--
hr_utility.set_location('Entering:'||l_proc, 5);
hr_utility.trace('p_value:'||p_value);
--
-- Only execute the checking code if the value has changed on
-- update (or insert and is not null).
--
  if (((p_value is not null) and
    nvl(ff_arc_shd.g_old_rec.value, hr_api.g_varchar2) <>
     nvl(p_value, hr_api.g_varchar2))
   or (p_value is null)) then
   --
   -- The value has changed or this is new, so check.
   --
   hr_utility.set_location(l_proc, 7);
   --
   -- Obtain the data type and name from the DBI
   -- If this is not found, the creator type may be
   -- wrong, or rows missing for this ue, so error.
   --
      open csr_entity_chk(p_user_entity_id);
      fetch csr_entity_chk into l_data_type, l_item_name;
      IF csr_entity_chk%notfound then
         raise proc_error;
      END IF;
      close csr_entity_chk;
   --
   hr_utility.trace('Data type'||l_data_type);
   hr_utility.trace('Name: '||l_item_name);
   --
   -- Ensure that this value is of the correct data type.
   -- raising Oracle errors where necessary. This removes the
   -- need for complex string manipulation to ascertain
   -- value's correct formatting.
   -- Note that the p_value string is not changed.
   --
     If l_data_type = 'N' then
        --Number type, check the value.
        --If this fails, an invalid_number exception will be raised.
        --Otherwise the program can carry on as normal.
        l_conv_number := to_number(p_value);
     Elsif l_data_type = 'D' then
        -- Date type must be in Canonical format. If this conversion
        -- fails, raise invalid value error. Although this would
        -- normally raise an ORA-1858, this saves user seeing the
        -- default all_procedure_fail.
        BEGIN
        l_conv_date := fnd_date.canonical_to_date(p_value);
        EXCEPTION WHEN others THEN
           raise value_error;
        END;
        hr_utility.trace('Date:'||to_char(l_conv_date));
     Elsif l_data_type = 'T' then
        -- This data type (subj to checking) can hold any alpha-numeric
        -- string. No checking as yet.
        NULL;
     End If;
   --
  end if;
--
  hr_utility.set_location('Leaving:'||l_proc, 10);
--
exception
when proc_error then
  -- The User Entity does not exist, or is not type X.
  -- raise apt error.
  hr_utility.set_message(800, 'FF_34956_INVALID_USER_ENTITY');
  hr_utility.raise_error;
--
-- Raise Incorrect Datatype error in two circumstances.
--
when value_error then
  hr_utility.set_message(800, 'FF_34960_INVALID_ARCHIVE_VALUE');
  hr_utility.set_message_token('ITEM_NAME', l_item_name);
  hr_utility.set_message_token('ITEM_VALUE', p_value);
  hr_utility.raise_error;
when invalid_number then
  hr_utility.set_message(800, 'FF_34960_INVALID_ARCHIVE_VALUE');
  hr_utility.set_message_token('ITEM_NAME', l_item_name);
  hr_utility.set_message_token('ITEM_VALUE', p_value);
  hr_utility.raise_error;
when others then -- catch all for any other errors (standard).
  hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
  hr_utility.set_message_token('PROCEDURE', l_proc);
  hr_utility.set_message_token('STEP','20');
  hr_utility.raise_error;
--
end chk_value;

end ff_arc_shd;

/
