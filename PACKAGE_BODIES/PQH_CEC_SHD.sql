--------------------------------------------------------
--  DDL for Package Body PQH_CEC_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CEC_SHD" as
/* $Header: pqcecrhi.pkb 120.2 2005/10/12 20:18:10 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_cec_shd.';  -- Global package name
--
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
  If (p_constraint_name = 'PQH_COPY_ENTITY_CONTEXTS_UK') Then
    hr_utility.set_message(8302, 'PQH_COPY_ENTITY_CONTEXTS_UK');
    --  hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    --  hr_utility.set_message_token('PROCEDURE', l_proc);
    --  hr_utility.set_message_token('STEP','5');
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
  p_context                            in varchar2,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		context,
	application_short_name,
	legislation_code,
	responsibility_key,
	transaction_short_name,
	object_version_number
    from	pqh_copy_entity_contexts
    where	context = p_context;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('Context '||p_context, 6);
  hr_utility.set_location('OVN '||p_object_version_number, 6);
  --
  If (
	-- p_context is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_context = g_old_rec.context and
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
        hr_utility.set_location(l_proc, 11);
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
  p_context                            in varchar2,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	context,
	application_short_name,
	legislation_code,
	responsibility_key,
	transaction_short_name,
	object_version_number
    from	pqh_copy_entity_contexts
    where	context = p_context
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
    hr_utility.set_message_token('TABLE_NAME', 'pqh_copy_entity_contexts');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_context                       in varchar2,
	p_application_short_name        in varchar2,
	p_legislation_code              in varchar2,
	p_responsibility_key            in varchar2,
	p_transaction_short_name        in varchar2,
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
  l_rec.context                          := p_context;
  l_rec.application_short_name           := p_application_short_name;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.responsibility_key               := p_responsibility_key;
  l_rec.transaction_short_name           := p_transaction_short_name;
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
-- |----------------------------------< load_row >---------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure load_row
(  p_context                        in  varchar2
  ,p_application_short_name         in  varchar2
  ,p_legislation_code               in  varchar2
  ,p_responsibility_key             in  varchar2
  ,p_transaction_short_name         in  varchar2
  ,p_owner                          in  varchar2
    ,p_last_update_date               in varchar2
 ) is

--
   l_effective_date           date  := sysdate ;
   l_object_version_number    number  := 1;
   l_language                 varchar2(30) ;
   l_context                  pqh_copy_entity_contexts.context%TYPE := '';
--
   l_created_by                 pqh_copy_entity_contexts.created_by%TYPE;
   l_last_updated_by            pqh_copy_entity_contexts.last_updated_by%TYPE;
   l_creation_date              pqh_copy_entity_contexts.creation_date%TYPE;
   l_last_update_date           pqh_copy_entity_contexts.last_update_date%TYPE;
   l_last_update_login          pqh_copy_entity_contexts.last_update_login%TYPE;
--
   cursor c1 is select userenv('LANG') from dual ;
--
--
-- developer key is context
--
l_data_migrator_mode varchar2(1);
--
cursor csr_contexts(p_context IN varchar2) is
 select context
 from pqh_copy_entity_contexts
 where context = p_context;
--

Begin

--
     l_data_migrator_mode := hr_general.g_data_migrator_mode ;
   hr_general.g_data_migrator_mode := 'Y';
   open c1;
   fetch c1 into l_language ;
   close c1;
--
   open csr_contexts(p_context => p_context);
   fetch csr_contexts into l_context;
   close csr_contexts;
--
--
-- populate WHO columns
--
  /**
  l_created_by := 1;
  l_last_updated_by := 1;
  **/
  l_last_updated_by := fnd_load_util.owner_id(p_owner);
  l_created_by :=  fnd_load_util.owner_id(p_owner);
  l_creation_date := nvl(to_date(p_last_update_date,'YYYY/MM/DD'),trunc(sysdate));
  l_last_update_date := nvl(to_date(p_last_update_date,'YYYY/MM/DD'),trunc(sysdate));
/**
  l_creation_date := sysdate;
  l_last_update_date := sysdate;
**/
  l_last_update_login := 0;

--
--
   Begin
   --
    if l_context IS NULL then
     -- Insert the row into: pqh_copy_entity_contexts
  insert into pqh_copy_entity_contexts
  (     context,
        application_short_name,
        legislation_code,
        responsibility_key,
        transaction_short_name,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date ,
        last_update_login
  )
  Values
  (  p_context,
     p_application_short_name,
     p_legislation_code,
     p_responsibility_key,
     p_transaction_short_name,
     l_object_version_number,
     l_created_by,
     l_creation_date,
     l_last_updated_by,
     l_last_update_date,
     l_last_update_login
  );


    else

     -- update row
    update pqh_copy_entity_contexts
     set  application_short_name = p_application_short_name,
          legislation_code       = p_legislation_code,
          responsibility_key     = p_responsibility_key,
          transaction_short_name = p_transaction_short_name,
          last_updated_by        =  l_last_updated_by,
          last_update_date       =  l_last_update_date,
          last_update_login      =  l_last_update_login
     where context = p_context
       and nvl(last_updated_by,-1) in (l_last_updated_by,-1,1) ;

    end if;
   End;
   hr_general.g_data_migrator_mode := l_data_migrator_mode;

end load_row;

--
--


end pqh_cec_shd;

/
