--------------------------------------------------------
--  DDL for Package Body PQH_TEM_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TEM_SHD" as
/* $Header: pqtemrhi.pkb 120.2.12000000.2 2007/04/19 12:48:53 brsinha noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_tem_shd.';  -- Global package name
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
  If (p_constraint_name = 'PQH_TEMPLATES_FK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_TEMPLATES_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_TEMPLATES_FK2') Then
    hr_utility.set_message(8302, 'PQH_TEM_LEG_CODE_NOT_EXIST');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_TEMPLATES_UK') Then
    hr_utility.set_message(8302, 'PQH_DUPLICATE_TEM_SHORT_NAME');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_TRANSACTION_TEMPLATE_FK2') Then
    hr_utility.set_message(8302, 'PQH_TRANS_TEMPLATE_FK_EXIST');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_ROLE_TEMPLATES_FK3') Then
    hr_utility.set_message(8302, 'PQH_ROLE_TEMPLATE_FK_EXIST');
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
  p_template_id                        in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		template_name,
        short_name,
	template_id,
	attribute_only_flag,
	enable_flag,
	create_flag,
	transaction_category_id,
	under_review_flag,
	object_version_number,
	freeze_status_cd,
        template_type_cd,
	legislation_code
    from	pqh_templates
    where	template_id = p_template_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_template_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_template_id = g_old_rec.template_id and
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
  p_template_id                        in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	template_name,
        short_name,
	template_id,
	attribute_only_flag,
	enable_flag,
	create_flag,
	transaction_category_id,
	under_review_flag,
	object_version_number,
	freeze_status_cd,
        template_type_cd,
	legislation_code
    from	pqh_templates
    where	template_id = p_template_id
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
    hr_utility.set_message_token('TABLE_NAME', 'pqh_templates');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_template_name                 in varchar2,
        p_short_name                     in  varchar2,
	p_template_id                   in number,
	p_attribute_only_flag           in varchar2,
	p_enable_flag                   in varchar2,
	p_create_flag                   in varchar2,
	p_transaction_category_id       in number,
	p_under_review_flag             in varchar2,
	p_object_version_number         in number,
	p_freeze_status_cd              in varchar2,
	p_template_type_cd              in varchar2,
	p_legislation_code              in varchar2
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
  l_rec.template_name                    := p_template_name;
  l_rec.short_name                    := p_short_name;
  l_rec.template_id                      := p_template_id;
  l_rec.attribute_only_flag              := p_attribute_only_flag;
  l_rec.enable_flag                      := p_enable_flag;
  l_rec.create_flag                      := p_create_flag;
  l_rec.transaction_category_id          := p_transaction_category_id;
  l_rec.under_review_flag                := p_under_review_flag;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.freeze_status_cd                 := p_freeze_status_cd;
  l_rec.template_type_cd                 := p_template_type_cd;
  l_rec.legislation_code                 := p_legislation_code;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
-- ----------------------------------------------------------------------------
-- |------------------------< load_seed_row >----------------------|
-- ----------------------------------------------------------------------------
--
Procedure load_seed_row
  (p_upload_mode                    in  varchar2
  ,p_short_name                     in  varchar2
  ,p_template_name                  in  varchar2
  ,p_attribute_only_flag            in  varchar2
  ,p_enable_flag                    in  varchar2
  ,p_create_flag                    in  varchar2
  ,p_tran_cat_short_name            in  varchar2
  ,p_under_review_flag              in  varchar2
  ,p_freeze_status_cd               in  varchar2
  ,p_template_type_cd               in  varchar2
  ,p_legislation_code               in  varchar2
  ,p_owner                          in  varchar2
  ,p_last_update_date               in  varchar2
  ) is
--
--
l_data_migrator_mode varchar2(1);
--
Begin
--
   l_data_migrator_mode := hr_general.g_data_migrator_mode ;
   hr_general.g_data_migrator_mode := 'Y';
if (p_upload_mode = 'NLS') then
  PQH_TTL_UPD.TRANSLATE_ROW
  (p_short_name                     => p_short_name
  ,p_template_name                  => p_template_name
  ,p_owner                          => p_owner
  );
else
  PQH_TEM_SHD.LOAD_ROW
  (p_short_name                     => p_short_name
  ,p_template_name                  => p_template_name
  ,p_tran_cat_short_name            => p_tran_cat_short_name
  ,p_attribute_only_flag            => p_attribute_only_flag
  ,p_enable_flag                    => p_enable_flag
  ,p_create_flag                    => p_create_flag
  ,p_under_review_flag              => p_under_review_flag
  ,p_freeze_status_cd               => p_freeze_status_cd
  ,p_template_type_cd               => p_template_type_cd
  ,p_legislation_code               => p_legislation_code
  ,p_owner                          => p_owner
  ,p_last_update_date               => p_last_update_date);
 End if;
--
 hr_general.g_data_migrator_mode := l_data_migrator_mode;
End;
--
-- ----------------------------------------------------------------------------
-- |------------------------< LOAD_ROW >----------------------|
-- ----------------------------------------------------------------------------
--
Procedure load_row
  (
   p_short_name                     in  varchar2
  ,p_template_name                  in  varchar2
  ,p_attribute_only_flag            in  varchar2
  ,p_enable_flag                    in  varchar2
  ,p_create_flag                    in  varchar2
  ,p_tran_cat_short_name            in  varchar2
  ,p_under_review_flag              in  varchar2
  ,p_freeze_status_cd               in  varchar2
  ,p_template_type_cd               in  varchar2
  ,p_legislation_code               in  varchar2
  ,p_owner                          in  varchar2
  ,p_last_update_date               in  varchar2
  ) is
--
   l_effective_date            date  := sysdate ;
   l_object_version_number     number  := 1;
   l_language                  varchar2(30) ;

--
 l_template_id                pqh_templates.template_id%type := 0;
 l_transaction_category_id    pqh_transaction_categories.transaction_category_id%type;
--
--
 l_created_by                 pqh_templates.created_by%TYPE;
 l_last_updated_by            pqh_templates.last_updated_by%TYPE;
 l_creation_date              pqh_templates.creation_date%TYPE;
 l_last_update_date           pqh_templates.last_update_date%TYPE;
 l_last_update_login          pqh_templates.last_update_login%TYPE;
--
--
  cursor c1 is select userenv('LANG') from dual ;
--
  Cursor c2 is select transaction_category_id
               from pqh_transaction_categories
               where short_name = p_tran_cat_short_name
               and business_group_id is null;
--
  Cursor c3 is select template_id
               from pqh_templates
               where short_name = p_short_name ;
--
--
  Cursor C_Sel1 is select pqh_templates_s.nextval from sys.dual;
--
--
BEGIN
--
   open c1;
   fetch c1 into l_language ;
   close c1;
--
   Open c2;
   Fetch c2 into l_transaction_category_id;
   Close c2;
--
   Open c3;
   Fetch c3 into l_template_id;
   Close c3;
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
  l_last_updated_by := fnd_load_util.owner_id(p_owner);
  l_created_by := fnd_load_util.owner_id(p_owner);
/**
  l_creation_date := sysdate;
  l_last_update_date := sysdate;
**/
  l_creation_date := nvl(to_date(p_last_update_date,'YYYY/MM/DD'),trunc(sysdate));
  l_last_update_date := nvl(to_date(p_last_update_date,'YYYY/MM/DD'),trunc(sysdate));
  l_last_update_login := 0;
  --
  begin
  --
  If l_template_id <> 0 then
    --
    -- If there is a row for the rule sets update the row in the base table
    --
    update pqh_templates
    set
       template_name                     = p_template_name,
       short_name                        = p_short_name,
       attribute_only_flag               = p_attribute_only_flag,
       enable_flag                       = p_enable_flag,
       create_flag                       = p_create_flag,
       transaction_category_id           = l_transaction_category_id,
       under_review_flag                 = p_under_review_flag,
       freeze_status_cd                  = p_freeze_status_cd,
       template_type_cd                  = p_template_type_cd,
       legislation_code                  = p_legislation_code,
       last_updated_by                   = l_last_updated_by,
       last_update_date                  = l_last_update_date,
       last_update_login                 = l_last_update_login
    where template_id = l_template_id;
       --  AND NVL(last_updated_by,-1) in (1,-1);
       --
       -- update the tl table
 if (sql%found) then
       --
    UPDATE pqh_templates_tl
    SET  template_name                  = p_template_name,
         last_updated_by                =  l_last_updated_by,
         last_update_date               =  l_last_update_date,
         last_update_login              =  l_last_update_login,
         source_lang                    = userenv('LANG')
      WHERE template_id                 =  l_template_id
        AND userenv('LANG') in (LANGUAGE, SOURCE_LANG);

    If (sql%notfound) then
       -- no row in TL table so insert row

      --
      insert into pqh_templates_tl(
        template_id,
        template_name,
	language,
	source_lang,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date ,
        last_update_login
       )
       Select
        l_template_id,
	p_template_name,
	l.language_code,
	l_language ,
        l_created_by,
        l_creation_date,
        l_last_updated_by,
        l_last_update_date,
        l_last_update_login
       from fnd_languages l
       where l.installed_flag in ('I','B')
       and not exists (select null
                  from pqh_templates_tl ttl
                  where ttl.template_id = l_template_id
                    and ttl.language    = l.language_code );
    --
    --
    End if;
    --
  end if; -- sql%found for main table

  Else
      --
      -- Select the next sequence number
      --
      Open C_Sel1;
      Fetch C_Sel1 Into l_template_id;
      Close C_Sel1;
      --
       --
       -- Insert row into the base table
       --

      insert into pqh_templates(
        template_name,
        template_id,
        attribute_only_flag,
        enable_flag,
        create_flag,
        transaction_category_id,
        under_review_flag,
        object_version_number,
        last_update_date,
        last_updated_by,
        last_update_login,
        created_by,
        creation_date,
        freeze_status_cd,
        template_type_cd,
        legislation_code,
        short_name
      )
     Values(
        p_template_name,
        l_template_id,
        p_attribute_only_flag,
        p_enable_flag,
        p_create_flag,
        l_transaction_category_id,
        p_under_review_flag,
        1,
        l_last_update_date,
        l_last_updated_by,
        l_last_update_login,
        l_created_by,
        l_creation_date,
        p_freeze_status_cd,
        p_template_type_cd,
        p_legislation_code,
        p_short_name
      );
      --

      insert into pqh_templates_tl(
        template_id,
        template_name,
	language,
	source_lang,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date ,
        last_update_login
       )
       Select
        l_template_id,
	p_template_name,
	l.language_code,
	l_language ,
        l_created_by,
        l_creation_date,
        l_last_updated_by,
        l_last_update_date,
        l_last_update_login
       from fnd_languages l
       where l.installed_flag in ('I','B')
       and not exists (select null
                  from pqh_templates_tl ttl
                  where ttl.template_id = l_template_id
                    and ttl.language    = l.language_code );
      --
      --
   End if;
   --
 End;
 --
End load_row;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
-- Procedure added as a fix for bug 5484366
--
Procedure ADD_LANGUAGE
is
begin
  delete from PQH_TEMPLATES_TL T
  where not exists
    (select NULL
    from PQH_TEMPLATES B
    where B.TEMPLATE_ID = T.TEMPLATE_ID
    );

  update PQH_TEMPLATES_TL T set (
      TEMPLATE_NAME
    ) = (select
      B.TEMPLATE_NAME
    from PQH_TEMPLATES_TL B
    where B.TEMPLATE_ID = T.TEMPLATE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TEMPLATE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TEMPLATE_ID,
      SUBT.LANGUAGE
    from PQH_TEMPLATES_TL SUBB, PQH_TEMPLATES_TL SUBT
    where SUBB.TEMPLATE_ID = SUBT.TEMPLATE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TEMPLATE_NAME <> SUBT.TEMPLATE_NAME
  ));

  insert into PQH_TEMPLATES_TL (
    TEMPLATE_ID,
    TEMPLATE_NAME,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TEMPLATE_ID,
    B.TEMPLATE_NAME,
    B.LAST_UPDATE_DATE,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PQH_TEMPLATES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PQH_TEMPLATES_TL T
    where T.TEMPLATE_ID = B.TEMPLATE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
-- --
-- --
end pqh_tem_shd;

/
