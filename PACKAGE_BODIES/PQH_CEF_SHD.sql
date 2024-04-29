--------------------------------------------------------
--  DDL for Package Body PQH_CEF_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CEF_SHD" as
/* $Header: pqcefrhi.pkb 120.2 2005/10/12 20:18:19 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_cef_shd.';  -- Global package name
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
  If (p_constraint_name = 'PQH_COPY_ENTITY_FUNCTIONS_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_COPY_ENTITY_FUNCTIONS_FK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
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
  p_copy_entity_function_id            in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		copy_entity_function_id,
	table_route_id,
	function_type_cd,
	pre_copy_function_name,
	copy_function_name,
	post_copy_function_name,
	object_version_number,
	context
    from	pqh_copy_entity_functions
    where	copy_entity_function_id = p_copy_entity_function_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_copy_entity_function_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_copy_entity_function_id = g_old_rec.copy_entity_function_id and
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
  p_copy_entity_function_id            in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	copy_entity_function_id,
	table_route_id,
	function_type_cd,
	pre_copy_function_name,
	copy_function_name,
	post_copy_function_name,
	object_version_number,
	context
    from	pqh_copy_entity_functions
    where	copy_entity_function_id = p_copy_entity_function_id
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
    hr_utility.set_message_token('TABLE_NAME', 'pqh_copy_entity_functions');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_copy_entity_function_id       in number,
	p_table_route_id                in number,
	p_function_type_cd              in varchar2,
	p_pre_copy_function_name        in varchar2,
	p_copy_function_name            in varchar2,
	p_post_copy_function_name       in varchar2,
	p_object_version_number         in number,
	p_context                       in varchar2
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
  l_rec.copy_entity_function_id          := p_copy_entity_function_id;
  l_rec.table_route_id                   := p_table_route_id;
  l_rec.function_type_cd                 := p_function_type_cd;
  l_rec.pre_copy_function_name           := p_pre_copy_function_name;
  l_rec.copy_function_name               := p_copy_function_name;
  l_rec.post_copy_function_name          := p_post_copy_function_name;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.context                          := p_context;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< load_row >---------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure load_row
(  p_table_alias                    in  varchar2
  ,p_function_type_cd               in  varchar2
  ,p_pre_copy_function_name         in  varchar2
  ,p_copy_function_name             in  varchar2
  ,p_post_copy_function_name        in  varchar2
  ,p_context                        in  varchar2
  ,p_owner                          in  varchar2
  ,p_last_update_date               in  varchar2
 ) is
--
--
   l_effective_date           date  := sysdate ;
   l_object_version_number    number  := 1;
   l_language                 varchar2(30) ;
--
l_table_route_id              pqh_copy_entity_functions.table_route_id%TYPE;
l_copy_entity_function_id     pqh_copy_entity_functions.copy_entity_function_id%TYPE := 0;
--
--
   l_created_by                 pqh_copy_entity_functions.created_by%TYPE;
   l_last_updated_by            pqh_copy_entity_functions.last_updated_by%TYPE;
   l_creation_date              pqh_copy_entity_functions.creation_date%TYPE;
   l_last_update_date           pqh_copy_entity_functions.last_update_date%TYPE;
   l_last_update_login          pqh_copy_entity_functions.last_update_login%TYPE;
--
   cursor c1 is select userenv('LANG') from dual ;
--
--
-- developer key is table_alias + function_type_cd + context
--
cursor csr_table_route_id(p_table_alias in varchar2)  is
 select table_route_id
 from pqh_table_route
 where table_alias = p_table_alias;
--
cursor csr_cef_id (p_table_route_id in number,
                   p_function_type_cd in varchar2,
                   p_context in varchar2) is
 select copy_entity_function_id
 from pqh_copy_entity_functions
 where table_route_id = p_table_route_id
   and function_type_cd = p_function_type_cd
   and context   = p_context;

--
l_data_migrator_mode varchar2(1);
--
--
--
--
Begin
--
--  key to ids
--
    l_data_migrator_mode := hr_general.g_data_migrator_mode ;
   hr_general.g_data_migrator_mode := 'Y';
--
   open c1;
   fetch c1 into l_language ;
   close c1;
--
  open csr_table_route_id(p_table_alias => p_table_alias );
   fetch csr_table_route_id into l_table_route_id;
  close csr_table_route_id;
--
  open csr_cef_id(p_table_route_id => l_table_route_id,
                  p_function_type_cd => p_function_type_cd,
                  p_context => p_context);
   fetch csr_cef_id into l_copy_entity_function_id;
  close csr_cef_id;
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
   --
   if l_copy_entity_function_id <> 0 then
    -- row exits so update
     update pqh_copy_entity_functions
      set pre_copy_function_name         = p_pre_copy_function_name,
          copy_function_name             = p_copy_function_name,
          post_copy_function_name        = p_post_copy_function_name,
          last_updated_by                =  l_last_updated_by,
          last_update_date               =  l_last_update_date,
          last_update_login              =  l_last_update_login
      where copy_entity_function_id = l_copy_entity_function_id
        and nvl(last_updated_by , -1) in (l_last_updated_by,-1,1);
   else
     -- insert row

  select pqh_copy_entity_functions_s.nextval into l_copy_entity_function_id from dual;

  insert into pqh_copy_entity_functions
  (     copy_entity_function_id,
        table_route_id,
        function_type_cd,
        pre_copy_function_name,
        copy_function_name,
        post_copy_function_name,
        object_version_number,
        context,
        creation_date,
        created_by,
        last_update_date,
        last_update_login,
        last_updated_by
  )
  Values
  (
      l_copy_entity_function_id,
      l_table_route_id,
      p_function_type_cd,
      p_pre_copy_function_name,
      p_copy_function_name,
      p_post_copy_function_name,
      l_object_version_number,
      p_context,
      l_creation_date,
      l_created_by,
      l_last_update_date,
      l_last_update_login,
      l_last_updated_by
  );

   end if;

   End;


 hr_general.g_data_migrator_mode := l_data_migrator_mode;


end load_row;

--
--

end pqh_cef_shd;

/
