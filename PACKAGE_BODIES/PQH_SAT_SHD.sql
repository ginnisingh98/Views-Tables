--------------------------------------------------------
--  DDL for Package Body PQH_SAT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_SAT_SHD" as
/* $Header: pqsatrhi.pkb 120.2 2005/10/12 20:19:29 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_sat_shd.';  -- Global package name
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
  If (p_constraint_name = 'PQH_SPECIAL_ATTRIBUTES_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_SPECIAL_ATTRIBUTES_FK2') Then
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
  p_special_attribute_id               in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		special_attribute_id,
	txn_category_attribute_id,
	attribute_type_cd,
	key_attribute_type,
	enable_flag,
	flex_code,
	object_version_number,
	ddf_column_name,
	ddf_value_column_name,
	context
    from	pqh_special_attributes
    where	special_attribute_id = p_special_attribute_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_special_attribute_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_special_attribute_id = g_old_rec.special_attribute_id and
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
  p_special_attribute_id               in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	special_attribute_id,
	txn_category_attribute_id,
	attribute_type_cd,
	key_attribute_type,
	enable_flag,
	flex_code,
	object_version_number,
	ddf_column_name,
	ddf_value_column_name,
	context
    from	pqh_special_attributes
    where	special_attribute_id = p_special_attribute_id
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
    hr_utility.set_message_token('TABLE_NAME', 'pqh_special_attributes');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_special_attribute_id          in number,
	p_txn_category_attribute_id     in number,
	p_attribute_type_cd             in varchar2,
	p_key_attribute_type             in varchar2,
	p_enable_flag             in varchar2,
	p_flex_code                     in varchar2,
	p_object_version_number         in number,
	p_ddf_column_name               in varchar2,
	p_ddf_value_column_name         in varchar2,
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
  l_rec.special_attribute_id             := p_special_attribute_id;
  l_rec.txn_category_attribute_id        := p_txn_category_attribute_id;
  l_rec.attribute_type_cd                := p_attribute_type_cd;
  l_rec.key_attribute_type                := p_key_attribute_type;
  l_rec.enable_flag                := p_enable_flag;
  l_rec.flex_code                        := p_flex_code;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.ddf_column_name                  := p_ddf_column_name;
  l_rec.ddf_value_column_name            := p_ddf_value_column_name;
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
(  p_txn_category_short_name        in  varchar2
  ,p_attribute_table_alias          in  varchar2
  ,p_attribute_column_name          in  varchar2
  ,p_key_attribute_type             in  varchar2
  ,p_attribute_type_cd              in  varchar2
  ,p_enable_flag                    in  varchar2
  ,p_flex_code                      in  varchar2
  ,p_ddf_column_name                in  varchar2
  ,p_ddf_value_column_name          in  varchar2
  ,p_context                        in  varchar2
  ,p_owner                          in  varchar2
  ,p_last_update_date               in  varchar2
 ) is
--
   l_effective_date           date  := sysdate ;
   l_object_version_number    number  := 1;
   l_language                 varchar2(30) ;
--
   l_attribute_id               pqh_attributes.attribute_id%TYPE ;
   l_table_route_id             pqh_attributes.master_table_route_id%TYPE;
   l_transaction_category_id    pqh_transaction_categories.transaction_category_id%TYPE;
   l_special_attribute_id       pqh_special_attributes.special_attribute_id%TYPE := 0;
   l_txn_category_attribute_id  pqh_special_attributes.txn_category_attribute_id%TYPE;
--
   l_created_by                 pqh_special_attributes.created_by%TYPE;
   l_last_updated_by            pqh_special_attributes.last_updated_by%TYPE;
   l_creation_date              pqh_special_attributes.creation_date%TYPE;
   l_last_update_date           pqh_special_attributes.last_update_date%TYPE;
   l_last_update_login          pqh_special_attributes.last_update_login%TYPE;
--
   cursor c1 is select userenv('LANG') from dual ;
--
--
-- developer key is TXN_CATEGORY_ATTRIBUTE_ID + ATTRIBUTE_TYPE_CD + CONTEXT
--
cursor csr_attribute_id(p_column_name IN VARCHAR2, p_table_id IN NUMBER) is
 select attribute_id
 from pqh_attributes
 where key_column_name = p_column_name
   and legislation_code is null
   and nvl(master_table_route_id,-999) = nvl(p_table_id, -999);
--
cursor cst_txn_cat_id(p_short_name IN VARCHAR2) is
 select transaction_category_id
 from pqh_transaction_categories
 where short_name = p_short_name
 and   business_group_id is null;
--
--
cursor csr_table_id (p_table_alias IN VARCHAR2) is
 select table_route_id
 from pqh_table_route
 where table_alias = p_table_alias;
--
cursor csr_txn_cat_att_id (p_attribute_id in number, p_transaction_category_id in number) is
 select txn_category_attribute_id
 from pqh_txn_category_attributes
 where attribute_id = p_attribute_id
   and transaction_category_id = p_transaction_category_id;
--
cursor csr_special_att_id(p_txn_category_attribute_id in number,
                          p_key_attribute_type  in varchar2,
                          p_context in varchar2) is
 select special_attribute_id
 from pqh_special_attributes
 where txn_category_attribute_id = p_txn_category_attribute_id
   and key_attribute_type  = p_key_attribute_type
   and context  = p_context;
--
--
l_data_migrator_mode varchar2(1);
--
--
Begin
--
--  key to ids
--
     l_data_migrator_mode := hr_general.g_data_migrator_mode ;
   hr_general.g_data_migrator_mode := 'Y';
   open c1;
   fetch c1 into l_language ;
   close c1;
--
  open cst_txn_cat_id(p_short_name => p_txn_category_short_name );
   fetch cst_txn_cat_id into l_transaction_category_id;
  close cst_txn_cat_id;
--
  open csr_table_id(p_table_alias => p_attribute_table_alias );
   fetch csr_table_id into l_table_route_id;
  close csr_table_id;
--
--
  open csr_attribute_id(p_column_name => p_attribute_column_name, p_table_id => l_table_route_id);
   fetch csr_attribute_id into l_attribute_id;
      if csr_attribute_id%notfound then
        fnd_message.set_name(8302,'PQH_INVALID_ATTRIBUTE');
        fnd_message.set_token('ATTRIBUTE_COLUMN_NAME',p_attribute_column_name);
        fnd_message.raise_error;
      end if;
  close csr_attribute_id;
--
  open csr_txn_cat_att_id(p_attribute_id => l_attribute_id, p_transaction_category_id => l_transaction_category_id);
   fetch csr_txn_cat_att_id into l_txn_category_attribute_id;
  close csr_txn_cat_att_id;
--
  open csr_special_att_id(p_txn_category_attribute_id => l_txn_category_attribute_id,
                          p_key_attribute_type => p_key_attribute_type,
                          p_context => p_context);
    fetch csr_special_att_id into l_special_attribute_id;
  close csr_special_att_id;
--
-- populate WHO columns
--
  /**
  if p_owner = 'SEED' then
    l_created_by := 1;
    l_last_updated_by := -1;
  else
    l_created_by := 0;
    l_last_updated_by := -1;
  end if;
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
    if l_special_attribute_id <> 0 then
    -- row exits so update
      update pqh_special_attributes
      set flex_code = p_flex_code,
          ddf_column_name = p_ddf_column_name,
          ddf_value_column_name = p_ddf_value_column_name,
          key_attribute_type             =  p_key_attribute_type,
          attribute_type_cd              =  nvl(p_attribute_type_cd,p_key_attribute_type),
          enable_flag                    =  nvl(p_enable_flag,'Y'),
          last_updated_by                =  l_last_updated_by,
          last_update_date               =  l_last_update_date,
          last_update_login              =  l_last_update_login
      where special_attribute_id  = l_special_attribute_id
        and nvl(last_updated_by, -1) in (l_last_updated_by,-1,0,1);

    else
     -- insert
     select pqh_special_attributes_s.nextval into l_special_attribute_id from dual;


     insert into pqh_special_attributes
  (     special_attribute_id,
        txn_category_attribute_id,
        key_attribute_type,
        attribute_type_cd,
        enable_flag,
        flex_code,
        object_version_number,
        ddf_column_name,
        ddf_value_column_name,
        context,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date ,
        last_update_login

  )
  Values
  (    l_special_attribute_id,
       l_txn_category_attribute_id,
       p_key_attribute_type,
       nvl(p_attribute_type_cd,p_key_attribute_type),
       nvl(p_enable_flag,'Y'),
       p_flex_code,
       l_object_version_number,
       p_ddf_column_name,
       p_ddf_value_column_name,
       p_context,
       l_created_by,
       l_creation_date,
       l_last_updated_by,
       l_last_update_date,
       l_last_update_login
  );
    end if;

  End;
   hr_general.g_data_migrator_mode := l_data_migrator_mode;
end load_row;


end pqh_sat_shd;

/
