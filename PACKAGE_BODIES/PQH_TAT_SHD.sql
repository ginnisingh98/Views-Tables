--------------------------------------------------------
--  DDL for Package Body PQH_TAT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TAT_SHD" as
/* $Header: pqtatrhi.pkb 120.2 2005/10/12 20:19:38 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_tat_shd.';  -- Global package name
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
  If (p_constraint_name = 'PQH_TEMPLATE_ATTRIBUTES_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_TEMPLATE_ATTRIBUTES_FK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_TEMPLATE_ATTRIBUTES_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_TEMPLATE_ATTRIBUTES_UK') Then
    hr_utility.set_message(8302, 'PQH_DUPLICATE_TEM_ATTRIBUTE');
    hr_utility.raise_error;
    /**
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
    **/
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
  p_template_attribute_id              in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		required_flag,
	view_flag,
	edit_flag,
	template_attribute_id,
	attribute_id,
	template_id,
	object_version_number
    from	pqh_template_attributes
    where	template_attribute_id = p_template_attribute_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_template_attribute_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_template_attribute_id = g_old_rec.template_attribute_id and
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
  p_template_attribute_id              in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	required_flag,
	view_flag,
	edit_flag,
	template_attribute_id,
	attribute_id,
	template_id,
	object_version_number
    from	pqh_template_attributes
    where	template_attribute_id = p_template_attribute_id
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
    hr_utility.set_message_token('TABLE_NAME', 'pqh_template_attributes');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_required_flag                 in varchar2,
	p_view_flag                     in varchar2,
	p_edit_flag                     in varchar2,
	p_template_attribute_id         in number,
	p_attribute_id                  in number,
	p_template_id                   in number,
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
  l_rec.required_flag                    := p_required_flag;
  l_rec.view_flag                        := p_view_flag;
  l_rec.edit_flag                        := p_edit_flag;
  l_rec.template_attribute_id            := p_template_attribute_id;
  l_rec.attribute_id                     := p_attribute_id;
  l_rec.template_id                      := p_template_id;
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
procedure LOAD_ROW
  (p_required_flag                  in  varchar2
  ,p_view_flag                      in  varchar2
  ,p_edit_flag                      in  varchar2
  ,p_att_column_name                in  varchar2
  ,p_att_master_table_alias_name    in  varchar2
  ,p_template_short_name            in  varchar2
  ,p_legislation_code               in  varchar2
  ,p_owner			    in  varchar2
  ,p_last_update_date			    in  varchar2
  )  is
  l_object_version_number       number(15);
  l_template_id                 pqh_template_attributes.template_id%type;
  l_tem_txn_category_id         pqh_templates.transaction_category_id%type;
  l_att_txn_category_id         pqh_transaction_categories.transaction_category_id%type;
  l_attribute_id                pqh_template_attributes.attribute_id%type;
  l_template_attribute_id       pqh_template_attributes.template_attribute_id%type;
--
 l_created_by                 pqh_templates.created_by%TYPE;
 l_last_updated_by            pqh_templates.last_updated_by%TYPE;
 l_creation_date              pqh_templates.creation_date%TYPE;
 l_last_update_date           pqh_templates.last_update_date%TYPE;
 l_last_update_login          pqh_templates.last_update_login%TYPE;
--
  cursor c_attributes is
  select attribute_id
  from pqh_attributes a,pqh_table_route t
  where a.key_column_name = p_att_column_name
  and a.master_table_route_id= t.table_route_id(+)
  and nvl(t.table_alias,'$$$$$') = nvl(p_att_master_table_alias_name,'$$$$$')
  and nvl(a.legislation_code,'$$$$$') = nvl(p_legislation_code,'$$$$$');

  cursor c_templates is
  select template_id, transaction_category_id
  from pqh_templates_vl
  where short_name = p_template_short_name;

  cursor c_att_txn_category(p_attribute_id number,p_tem_txn_category_id number) is
  select transaction_category_id
  from pqh_txn_category_attributes
  where attribute_id = p_attribute_id
  and transaction_category_id = p_tem_txn_category_id;

  cursor c_template_attributes (p_template_id number, p_attribute_id number) is
  select template_attribute_id
  from pqh_template_attributes
  where template_id = p_template_id
    and attribute_id = p_attribute_id;
--
l_data_migrator_mode varchar2(1);
--
BEGIN
--
  l_data_migrator_mode := hr_general.g_data_migrator_mode ;
   hr_general.g_data_migrator_mode := 'Y';
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

  l_created_by := fnd_load_util.owner_id(p_owner);
  l_last_updated_by := fnd_load_util.owner_id(p_owner);
/**
  l_creation_date := sysdate;
  l_last_update_date := sysdate;
**/
  l_creation_date := nvl(to_date(p_last_update_date,'YYYY/MM/DD'),trunc(sysdate));
  l_last_update_date := nvl(to_date(p_last_update_date,'YYYY/MM/DD'),trunc(sysdate));
  l_last_update_login := 0;
--
  open c_attributes;
  fetch c_attributes into l_attribute_id;

  if c_attributes%found then
    close c_attributes;
    open c_templates;
    fetch c_templates into l_template_id, l_tem_txn_category_id;

    if c_templates%found then
      close c_templates;
      open c_att_txn_category(l_attribute_id ,l_tem_txn_category_id);
      fetch c_att_txn_category into l_template_attribute_id;

      if c_att_txn_category%found then
        close c_att_txn_category;
        open c_template_attributes(l_template_id, l_attribute_id);
        fetch c_template_attributes into l_att_txn_category_id;

        if c_template_attributes%found then
          close c_template_attributes;
          update PQH_TEMPLATE_ATTRIBUTES
          set required_flag = p_required_flag,
              view_flag = p_view_flag,
              edit_flag = p_edit_flag,
              last_update_date = l_last_update_date,
              last_updated_by = l_last_updated_by,
              last_update_login = l_last_update_login
          where attribute_id = l_attribute_id
            and template_id = l_template_id;
            --AND NVL(last_updated_by,-1) in (1,-1);
        else
          close c_template_attributes;
          --
          insert into pqh_template_attributes
          (required_flag, view_flag, edit_flag, template_attribute_id, attribute_id,
          template_id, object_version_number, last_update_date, last_updated_by, last_update_login,
          created_by, creation_date)
          values
          (p_required_flag, p_view_flag, p_edit_flag, pqh_template_attributes_s.nextval, l_attribute_id,
          l_template_id, 1, l_last_update_date, l_last_updated_by, l_last_update_login,
          l_created_by, l_creation_date);
          --
         end if;
      else
        close c_att_txn_category;
        fnd_message.set_name(8302,'PQH_INVALID_TXN_CAT_ATTR');
        fnd_message.set_token('ATTRIBUTE_COLUMN_NAME',p_att_column_name);
        fnd_message.set_token('TEMPLATE_SHORT_NAME',p_template_short_name);
        fnd_message.raise_error;
      end if;
    else
      close c_templates;
      fnd_message.set_name(8302,'PQH_INVALID_TEMPLATE');
      fnd_message.set_token('TEMPLATE_SHORT_NAME',p_template_short_name);
      fnd_message.raise_error;
    end if;
  else
    close c_attributes;
    fnd_message.set_name(8302,'PQH_INVALID_ATTRIBUTE');
    fnd_message.set_token('ATTRIBUTE_COLUMN_NAME',p_att_column_name);
    fnd_message.raise_error;
  end if;
   hr_general.g_data_migrator_mode := l_data_migrator_mode;
END;
--
--
end pqh_tat_shd;

/
