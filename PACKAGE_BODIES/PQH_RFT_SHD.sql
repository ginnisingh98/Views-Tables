--------------------------------------------------------
--  DDL for Package Body PQH_RFT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RFT_SHD" as
/* $Header: pqrftrhi.pkb 120.2 2005/10/12 20:19:02 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_rft_shd.';  -- Global package name
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
  If (p_constraint_name = 'PQH_REF_TEMPLATES_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_REF_TEMPLATES_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_REF_TEMPLATES_FK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_REF_TEMPLATES_UK') Then
    hr_utility.set_message(8302, 'PQH_DUPLICATE_REF_TEMPLATE');
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
  p_ref_template_id                    in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		ref_template_id,
	base_template_id,
	parent_template_id,
        reference_type_cd,
	object_version_number
    from	pqh_ref_templates
    where	ref_template_id = p_ref_template_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_ref_template_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_ref_template_id = g_old_rec.ref_template_id and
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
  p_ref_template_id                    in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	ref_template_id,
	base_template_id,
	parent_template_id,
        reference_type_cd,
	object_version_number
    from	pqh_ref_templates
    where	ref_template_id = p_ref_template_id
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
    hr_utility.set_message_token('TABLE_NAME', 'pqh_ref_templates');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_ref_template_id               in number,
	p_base_template_id              in number,
	p_parent_template_id            in number,
        p_reference_type_cd             in varchar2,
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
  l_rec.ref_template_id                  := p_ref_template_id;
  l_rec.base_template_id                 := p_base_template_id;
  l_rec.parent_template_id               := p_parent_template_id;
  l_rec.reference_type_cd                := p_reference_type_cd;
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
-------------------------------------------------------------------------------
-- |----------------< create_update_copied_attribute >------------------------
-------------------------------------------------------------------------------
--
procedure create_update_copied_attribute
  (
   p_copied_attributes      in     pqh_prvcalc.t_attid_priv,
   p_template_id            in     number,
   p_owner                  in  varchar2  default null) is
  --
  Cursor csr_tem_attr(p_attribute_id in number) is
   Select template_attribute_id,object_version_number
     From pqh_template_attributes
    Where template_id = p_template_id
      and attribute_id = p_attribute_id
      FOR UPDATE ;
  --
  cursor c_select_flag(p_attribute_id number, p_template_id number) is
  select 'x'
  from pqh_attributes att, pqh_txn_category_attributes tct, pqh_templates tem
  where
  att.attribute_id = p_attribute_id
  and att.attribute_id = tct.attribute_id
  and tem.template_id = p_template_id
  and tct.transaction_category_id = tem.transaction_category_id
  and nvl(tct.select_flag,'N')='Y';
  --
  l_template_attribute_id pqh_template_attributes.template_attribute_id%type;
  l_ovn                   pqh_template_attributes.object_version_number%type;
  l_view_flag             pqh_template_attributes.view_flag%type;
  l_edit_flag             pqh_template_attributes.edit_flag%type;
  --
  l_dummy		  varchar2(30);
  --
  l_proc varchar2(72) := g_package||'create_update_copied_attribute';
  --
--
 l_created_by                 pqh_template_attributes.created_by%TYPE;
 l_last_updated_by            pqh_template_attributes.last_updated_by%TYPE;
 l_creation_date              pqh_template_attributes.creation_date%TYPE;
 l_last_update_date           pqh_template_attributes.last_update_date%TYPE;
 l_last_update_login          pqh_template_attributes.last_update_login%TYPE;
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
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
  l_created_by := l_last_updated_by;

  l_creation_date := sysdate;
  l_last_update_date := sysdate;
  l_last_update_login := 0;
  --
  For cnt in p_copied_attributes.FIRST .. p_copied_attributes.LAST loop
  --
    open c_select_flag(p_copied_attributes(cnt).attribute_id, p_template_id);
    fetch c_select_flag into l_dummy;
    if c_select_flag%found then
      --
      If  p_copied_attributes(cnt).mode_flag = 'E' then
          l_view_flag := 'Y';
          l_edit_flag := 'Y';
      elsif p_copied_attributes(cnt).mode_flag ='V' then
          l_view_flag := 'Y';
          l_edit_flag := 'N';
      Else
          l_view_flag := 'N';
          l_edit_flag := 'N';
      End if;
      --
     Open csr_tem_attr(p_attribute_id =>p_copied_attributes(cnt).attribute_id);
     --
     Fetch csr_tem_attr into l_template_attribute_id,l_ovn;
     --
     If csr_tem_attr%found then
        --
        update pqh_template_attributes
        set
         required_flag            = p_copied_attributes(cnt).reqd_flag
        ,view_flag                = l_view_flag
        ,edit_flag                = l_edit_flag
        ,last_update_date = l_last_update_date
        ,last_updated_by = l_last_updated_by
        ,last_update_login = l_last_update_login
        where template_attribute_id = l_template_attribute_id;
        --
      Else
        --
        insert into pqh_template_attributes
        (
         required_flag
        ,view_flag
        ,edit_flag
        ,template_attribute_id
        ,attribute_id
        ,template_id
        ,object_version_number
        ,LAST_UPDATE_DATE, LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN, CREATED_BY, CREATION_DATE
       )
       values
       (
         p_copied_attributes(cnt).reqd_flag
        ,l_view_flag
        ,l_edit_flag
        ,pqh_template_attributes_s.nextval
        ,p_copied_attributes(cnt).attribute_id
        ,p_template_id
        ,1
        ,L_LAST_UPDATE_DATE, L_LAST_UPDATED_BY,
         L_LAST_UPDATE_LOGIN, L_CREATED_BY, L_CREATION_DATE);

        --
      End if;
      --
      Close csr_tem_attr;
    end if;
    close c_select_flag;
  --

  End loop;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end create_update_copied_attribute;
--
--
procedure apply_copy_template(
    p_parent_template_id number,
    p_base_template_id number,
    p_owner                          in  varchar2  default null) is
    --
 copied_attr_tab  pqh_prvcalc.t_attid_priv;
begin
  pqh_prvcalc.task_result_update(p_parent_template_id,
                                 'T',
                                 copied_attr_tab);
  pqh_prvcalc.task_result_update(p_base_template_id,
                                 'T',
                                 copied_attr_tab);
  --
  -- Save up the copied attributes in the database
  --
  If copied_attr_tab.count > 0 then

     create_update_copied_attribute
                            (p_copied_attributes => copied_attr_tab
                            ,p_template_id       => p_parent_template_id
                            ,p_owner             => p_owner);
     --
     --
     --
  End if;
end;
--
procedure LOAD_ROW
  (p_parent_template_short_name     in  varchar2
  ,p_base_template_short_name       in  varchar2
  ,p_reference_type_cd              in  varchar2
  ,p_owner                          in  varchar2
  ,p_last_update_date               in  varchar2
)  is
  l_dummy                       varchar2(10);
  l_object_version_number       number(15) := 1;
  l_parent_template_id          pqh_ref_templates.parent_template_id%type;
  l_base_template_id            pqh_ref_templates.base_template_id%type;
--
 l_created_by                 pqh_templates.created_by%TYPE;
 l_last_updated_by            pqh_templates.last_updated_by%TYPE;
 l_creation_date              pqh_templates.creation_date%TYPE;
 l_last_update_date           pqh_templates.last_update_date%TYPE;
 l_last_update_login          pqh_templates.last_update_login%TYPE;
--
  cursor c_templates(p_template_short_name varchar2) is
  select template_id
  from pqh_templates_vl
  where short_name = p_template_short_name;
  --
  cursor c_ref_templates(p_parent_template_id varchar2,
                         p_base_template_id varchar2) is
  select 'x'
  from pqh_ref_templates
  where parent_template_id = p_parent_template_id
  and base_template_id = p_base_template_id;
  --
--
l_data_migrator_mode varchar2(1);
--
BEGIN
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
  --
  l_creation_date := nvl(to_date(p_last_update_date,'YYYY/MM/DD'),trunc(sysdate));
  l_last_update_date := nvl(to_date(p_last_update_date,'YYYY/MM/DD'),trunc(sysdate));
/**
  l_creation_date := sysdate;
  l_last_update_date := sysdate;
**/
  l_last_update_login := 0;
--
  open c_templates(p_parent_template_short_name);
  fetch c_templates into l_parent_template_id;
  if c_templates%found then
     close c_templates;
     open c_templates(p_base_template_short_name);
     fetch c_templates into l_base_template_id;
       if c_templates%found then
       close c_templates;
       --
       open c_ref_templates(l_parent_template_id, l_base_template_id);
       fetch c_ref_templates into l_dummy;
       if c_ref_templates%found then
          close c_ref_templates;
          update PQH_REF_TEMPLATES
          set reference_type_cd = p_reference_type_cd,
            last_update_date = l_last_update_date,
            last_updated_by = l_last_updated_by,
            last_update_login = l_last_update_login
          where parent_template_id = l_parent_template_id
          and base_template_id = l_base_template_id;
       else
         close c_ref_templates;
         --
         insert into pqh_ref_templates
        (REF_TEMPLATE_ID, BASE_TEMPLATE_ID, PARENT_TEMPLATE_ID,
         OBJECT_VERSION_NUMBER, LAST_UPDATE_DATE, LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN, CREATED_BY, CREATION_DATE,
         REFERENCE_TYPE_CD )
         values
        (PQH_REF_TEMPLATES_S.NEXTVAL, L_BASE_TEMPLATE_ID, L_PARENT_TEMPLATE_ID,
         L_OBJECT_VERSION_NUMBER, L_LAST_UPDATE_DATE, L_LAST_UPDATED_BY,
         L_LAST_UPDATE_LOGIN, L_CREATED_BY, L_CREATION_DATE,
         P_REFERENCE_TYPE_CD );
        --
        if p_reference_type_cd = 'COPY' then
           --
           apply_copy_template(l_parent_template_id, l_base_template_id,p_owner);
        end if;
      end if;
    else
      close c_templates;
      fnd_message.set_name(8302,'PQH_INVALID_TEMPLATE');
      fnd_message.set_token('TEMPLATE_SHORT_NAME',p_base_template_short_name);
      fnd_message.raise_error;
    end if;
  else
    close c_templates;
    fnd_message.set_name(8302,'PQH_INVALID_TEMPLATE');
    fnd_message.set_token('TEMPLATE_SHORT_NAME',p_parent_template_short_name);
    fnd_message.raise_error;
  end if;
  hr_general.g_data_migrator_mode := l_data_migrator_mode;
END;
--
end pqh_rft_shd;

/
