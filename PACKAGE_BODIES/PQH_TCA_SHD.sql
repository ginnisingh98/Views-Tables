--------------------------------------------------------
--  DDL for Package Body PQH_TCA_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TCA_SHD" as
/* $Header: pqtcarhi.pkb 120.2 2005/10/12 20:19:48 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_tca_shd.';  -- Global package name
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
  If (p_constraint_name = 'PQH_TXN_CATEGORY_ATTRIBUTES_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_TXN_CATEGORY_ATTRIBUTE_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_TXN_CATEGORY_ATTRIBUTE_FK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_TXN_CAT_ATTRIBUTES_FK4') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_TXN_CAT_ATTRIBUTES_FK5') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','25');
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
  p_txn_category_attribute_id          in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		txn_category_attribute_id,
	attribute_id,
	transaction_category_id,
	value_set_id,
	object_version_number,
	transaction_table_route_id,
	form_column_name,
	identifier_flag,
	list_identifying_flag,
	member_identifying_flag,
	refresh_flag,
        select_flag,
	value_style_cd
    from	pqh_txn_category_attributes
    where	txn_category_attribute_id = p_txn_category_attribute_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_txn_category_attribute_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_txn_category_attribute_id = g_old_rec.txn_category_attribute_id and
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
  p_txn_category_attribute_id          in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	txn_category_attribute_id,
	attribute_id,
	transaction_category_id,
	value_set_id,
	object_version_number,
	transaction_table_route_id,
	form_column_name,
	identifier_flag,
	list_identifying_flag,
	member_identifying_flag,
	refresh_flag,
        select_flag,
	value_style_cd
    from	pqh_txn_category_attributes
    where	txn_category_attribute_id = p_txn_category_attribute_id
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
    hr_utility.set_message_token('TABLE_NAME', 'pqh_txn_category_attributes');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_txn_category_attribute_id     in number,
	p_attribute_id                  in number,
	p_transaction_category_id       in number,
	p_value_set_id                  in number,
	p_object_version_number         in number,
	p_transaction_table_route_id    in number,
	p_form_column_name              in varchar2,
	p_identifier_flag               in varchar2,
	p_list_identifying_flag         in varchar2,
	p_member_identifying_flag       in varchar2,
	p_refresh_flag                  in varchar2,
        p_select_flag                   in varchar2,
	p_value_style_cd                in varchar2
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
  l_rec.txn_category_attribute_id        := p_txn_category_attribute_id;
  l_rec.attribute_id                     := p_attribute_id;
  l_rec.transaction_category_id          := p_transaction_category_id;
  l_rec.value_set_id                     := p_value_set_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.transaction_table_route_id       := p_transaction_table_route_id;
  l_rec.form_column_name                 := p_form_column_name;
  l_rec.identifier_flag                  := p_identifier_flag;
  l_rec.list_identifying_flag            := p_list_identifying_flag;
  l_rec.member_identifying_flag          := p_member_identifying_flag;
  l_rec.refresh_flag                     := p_refresh_flag;
  l_rec.select_flag                      := p_select_flag ;
  l_rec.value_style_cd                   := p_value_style_cd;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< load_row >---------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure load_row
 ( p_att_col_name                   in  varchar2
  ,p_att_master_table_alias_name    in  varchar2
  ,p_tran_cat_short_name            in  varchar2
  ,p_value_set_name                 in  varchar2
  ,p_transaction_table_alias_name   in  varchar2
  ,p_form_column_name               in  varchar2
  ,p_identifier_flag                in  varchar2
  ,p_list_identifying_flag          in  varchar2
  ,p_member_identifying_flag        in  varchar2
  ,p_refresh_flag                   in  varchar2
  ,p_select_flag                    in  varchar2
  ,p_value_style_cd                 in  varchar2
  ,p_legislation_code               in  varchar2
  ,p_copy_to_bg_attr                in  varchar2
  ,p_owner                          in  varchar2
  ,p_last_update_date               in  varchar2
 ) is
--
--
   l_effective_date           date  := sysdate ;
   l_object_version_number    number  := 1;
   l_language                 varchar2(30) ;
   l_delete_attr_ranges_flag  varchar2(30) := 'N';
--
   l_txn_category_attribute_id  pqh_txn_category_attributes.txn_category_attribute_id%TYPE := 0 ;
   l_attribute_id               pqh_attributes.attribute_id%TYPE := 0 ;
   l_transaction_category_id    pqh_txn_category_attributes.transaction_category_id%TYPE := 0 ;
   l_transaction_table_route_id pqh_txn_category_attributes.transaction_table_route_id%TYPE;
   l_att_master_table_route_id  pqh_txn_category_attributes.transaction_table_route_id%TYPE;
   l_flex_value_set_id          fnd_flex_value_sets.flex_value_set_id%TYPE;
--
   l_created_by                 pqh_attributes.created_by%TYPE;
   l_last_updated_by            pqh_attributes.last_updated_by%TYPE;
   l_creation_date              pqh_attributes.creation_date%TYPE;
   l_last_update_date           pqh_attributes.last_update_date%TYPE;
   l_last_update_login          pqh_attributes.last_update_login%TYPE;
--
   cursor c1 is select userenv('LANG') from dual ;
--
--
-- developer key is short_name
--
cursor csr_attribute_id(p_column_name IN VARCHAR2,
			p_table_id IN NUMBER,
			p_legislation_code varchar2) is
 select attribute_id
 from pqh_attributes
 where key_column_name = p_column_name
   and nvl(master_table_route_id,-999) = nvl(p_table_id, -999)
   and nvl(legislation_code,'$$$') = nvl(p_legislation_code, '$$$');
--
cursor csr_table_id (p_table_alias IN VARCHAR2) is
 select table_route_id
 from pqh_table_route
 where table_alias = p_table_alias;
--
cursor csr_txn_cat_id (p_tran_cat_short_name IN VARCHAR2) is
 select transaction_category_id
 from pqh_transaction_categories
 where short_name = p_tran_cat_short_name
 and   business_group_id is null;
--
cursor csr_txn_cat_att_id ( p_attribute_id IN NUMBER, p_txn_category_id IN NUMBER ) is
 select txn_category_attribute_id
 from pqh_txn_category_attributes
 where attribute_id = p_attribute_id
   and transaction_category_id = p_txn_category_id;
--
cursor csr_value_set_id (p_value_set_name IN VARCHAR2) is
 select flex_value_set_id
 from fnd_flex_value_sets
 where flex_value_set_name = p_value_set_name;
--
--
Cursor csr_local_txn_cat_id  is
     select transaction_category_id
     from pqh_transaction_categories
     where short_name = p_tran_cat_short_name
     and   business_group_id is not null;
--
--
l_data_migrator_mode varchar2(1);
--
--
Begin
--
   l_data_migrator_mode := hr_general.g_data_migrator_mode ;
   hr_general.g_data_migrator_mode := 'Y';
--  key to ids
--
   open c1;
   fetch c1 into l_language ;
   close c1;
--
  open csr_table_id(p_table_alias => p_transaction_table_alias_name );
   fetch csr_table_id into l_transaction_table_route_id;
  close csr_table_id;
--
  open csr_table_id(p_table_alias => p_att_master_table_alias_name );
   fetch csr_table_id into l_att_master_table_route_id;
  close csr_table_id;
--
  open csr_attribute_id(p_column_name => p_att_col_name,
			p_table_id => l_att_master_table_route_id,
			p_legislation_code => p_legislation_code);
   fetch csr_attribute_id into l_attribute_id;
      if csr_attribute_id%notfound then
        fnd_message.set_name(8302,'PQH_INVALID_ATTRIBUTE');
        fnd_message.set_token('ATTRIBUTE_COLUMN_NAME',p_att_col_name);
        fnd_message.set_token('TABLE_ROUTE',p_att_master_table_alias_name);
        fnd_message.set_token('LEGISLATION_CODE',p_legislation_code);
        fnd_message.raise_error;
      end if;
  close csr_attribute_id;
--
  open csr_txn_cat_id(p_tran_cat_short_name => p_tran_cat_short_name );
   fetch csr_txn_cat_id into l_transaction_category_id;
  close csr_txn_cat_id;
--
  open csr_txn_cat_att_id(p_attribute_id => l_attribute_id,
                          p_txn_category_id => l_transaction_category_id );
   fetch csr_txn_cat_att_id into l_txn_category_attribute_id;
  close csr_txn_cat_att_id;
--
  open csr_value_set_id (p_value_set_name => p_value_set_name );
    fetch csr_value_set_id into l_flex_value_set_id;
  close csr_value_set_id;
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
  l_last_updated_by := fnd_load_util.owner_id(p_owner);
  l_created_by := fnd_load_util.owner_id(p_owner);
  l_creation_date := nvl(to_date(p_last_update_date,'YYYY/MM/DD'),trunc(sysdate));
  l_last_update_date := nvl(to_date(p_last_update_date,'YYYY/MM/DD'),trunc(sysdate));
/**
  l_creation_date := sysdate;
  l_last_update_date := sysdate;
**/
  l_last_update_login := 0;
  --
   if l_txn_category_attribute_id <> 0 then
    -- row exits so update
     UPDATE pqh_txn_category_attributes
     SET value_set_id  = l_flex_value_set_id,
         transaction_table_route_id     =  l_transaction_table_route_id,
         form_column_name               =  p_form_column_name,
         identifier_flag                =  p_identifier_flag,
--         list_identifying_flag          =  p_list_identifying_flag,
--         member_identifying_flag        =  p_member_identifying_flag,
         refresh_flag                   =  p_refresh_flag,
         value_style_cd                 =  p_value_style_cd,
         select_flag                    =  p_select_flag,
         last_updated_by                =  l_last_updated_by,
         last_update_date               =  l_last_update_date,
         last_update_login              =  l_last_update_login
      WHERE txn_category_attribute_id = l_txn_category_attribute_id;
    --
    -- The foll lne was commented to allow attaching a value set
    -- later to the txn category attribute, after it has been updated by user.
    --     AND NVL(last_updated_by,-1) in (1,-1);
    --
    -- Check if the local txn categories have to be updated.
    --
    If p_copy_to_bg_attr = 'Y' then
     --
     UPDATE pqh_txn_category_attributes
     SET value_set_id  = l_flex_value_set_id,
         transaction_table_route_id     =  l_transaction_table_route_id,
         form_column_name               =  p_form_column_name,
         identifier_flag                =  p_identifier_flag,
         refresh_flag                   =  p_refresh_flag,
         value_style_cd                 =  p_value_style_cd,
         select_flag                    =  p_select_flag,
         last_updated_by                =  l_last_updated_by,
         last_update_date               =  l_last_update_date,
         last_update_login              =  l_last_update_login
      WHERE attribute_id = l_attribute_id
--         AND NVL(last_updated_by,-1) in (1,-1);
       AND transaction_category_id in (
           select transaction_category_id
             from pqh_transaction_categories
            where short_name = p_tran_cat_short_name
              and business_group_id is not null);
    End if; -- Propogate changes to bg specific txn category attributes

   else

     -- insert into pqh_txn_category_attributes table

     select pqh_txn_category_attributes_s.nextval into l_txn_category_attribute_id from dual;

      INSERT INTO pqh_txn_category_attributes
       (txn_category_attribute_id,
        attribute_id,
        transaction_category_id,
        value_set_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date ,
        last_update_login,
        object_version_number,
        transaction_table_route_id,
        form_column_name,
        identifier_flag,
        list_identifying_flag,
        member_identifying_flag,
        refresh_flag,
        select_flag,
        value_style_cd)
     VALUES
       (l_txn_category_attribute_id,
        l_attribute_id,
        l_transaction_category_id,
        l_flex_value_set_id,
        l_created_by,
        l_creation_date,
        l_last_updated_by,
        l_last_update_date ,
        l_last_update_login,
        l_object_version_number,
        l_transaction_table_route_id,
        p_form_column_name,
        p_identifier_flag,
        p_list_identifying_flag,
        p_member_identifying_flag,
        p_refresh_flag,
        p_select_flag,
        p_value_style_cd);
    --
    -- Insert the new attribute into local tct. Added as a part of pqseedtca.sql cleanup
    --
    --
    For lcl_tca_rec in csr_local_txn_cat_id  loop
        --
        l_transaction_category_id := lcl_tca_rec.transaction_category_id;

        select pqh_txn_category_attributes_s.nextval into l_txn_category_attribute_id from dual;

        INSERT INTO pqh_txn_category_attributes
       (txn_category_attribute_id,
        attribute_id,
        transaction_category_id,
        value_set_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date ,
        last_update_login,
        object_version_number,
        transaction_table_route_id,
        form_column_name,
        identifier_flag,
        list_identifying_flag,
        member_identifying_flag,
        refresh_flag,
        select_flag,
        value_style_cd)
        VALUES
       (l_txn_category_attribute_id,
        l_attribute_id,
        l_transaction_category_id,
        l_flex_value_set_id,
        l_created_by,
        l_creation_date,
        l_last_updated_by,
        l_last_update_date ,
        l_last_update_login,
        l_object_version_number,
        l_transaction_table_route_id,
        p_form_column_name,
        p_identifier_flag,
        p_list_identifying_flag,
        p_member_identifying_flag,
        p_refresh_flag,
        p_select_flag,
        p_value_style_cd);
        --
        --
    End loop;
    --
   end if;
   --
 hr_general.g_data_migrator_mode := l_data_migrator_mode;
   --
End load_row;
--
--
End pqh_tca_shd;
--

/
