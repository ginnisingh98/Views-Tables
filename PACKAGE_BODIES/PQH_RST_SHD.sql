--------------------------------------------------------
--  DDL for Package Body PQH_RST_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RST_SHD" as
/* $Header: pqrstrhi.pkb 120.2.12000000.2 2007/04/19 12:46:34 brsinha noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_rst_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
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
  If (p_constraint_name = 'HR_ALL_ORGANIZATION_UNITS_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_RULE_SETS_FK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_RULE_SETS_FK3') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_RULE_SETS_FK4') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_RULE_SETS_UK') Then
    hr_utility.set_message(8302, 'PQH_DUPL_SHORT_NAME');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'RULE_SETS_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','30');
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
  p_rule_set_id                        in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	business_group_id,
	rule_set_id,
	rule_set_name,
	organization_structure_id,
	organization_id,
	referenced_rule_set_id,
	rule_level_cd,
	object_version_number,
	short_name,
	rule_applicability,
	rule_category,
	starting_organization_id,
	seeded_rule_flag,
        status
    from	pqh_rule_sets
    where	rule_set_id = p_rule_set_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_rule_set_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_rule_set_id = g_old_rec.rule_set_id and
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
  p_rule_set_id                        in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	business_group_id,
	rule_set_id,
	rule_set_name,
	organization_structure_id,
	organization_id,
	referenced_rule_set_id,
	rule_level_cd,
	object_version_number,
	short_name,
	rule_applicability,
	rule_category,
	starting_organization_id,
	seeded_rule_flag,
        status
    from	pqh_rule_sets
    where	rule_set_id = p_rule_set_id
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
    hr_utility.set_message_token('TABLE_NAME', 'pqh_rule_sets');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_business_group_id             in number,
	p_rule_set_id                   in number,
	p_rule_set_name                 in varchar2,
	p_organization_structure_id     in number,
	p_organization_id               in number,
	p_referenced_rule_set_id        in number,
	p_rule_level_cd                 in varchar2,
	p_object_version_number         in number,
	p_short_name                    in varchar2,
  	p_rule_applicability		in varchar2,
  	p_rule_category		  	in varchar2,
  	p_starting_organization_id	in number,
  	p_seeded_rule_flag		in varchar2,
        p_status                        in varchar2
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
  l_rec.business_group_id                := p_business_group_id;
  l_rec.rule_set_id                      := p_rule_set_id;
  l_rec.rule_set_name                    := p_rule_set_name;
  l_rec.organization_structure_id        := p_organization_structure_id;
  l_rec.organization_id                  := p_organization_id;
  l_rec.referenced_rule_set_id           := p_referenced_rule_set_id;
  l_rec.rule_level_cd                    := p_rule_level_cd;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.short_name                       := p_short_name;
  l_rec.rule_applicability               := p_rule_applicability;
  l_rec.rule_category			 := p_rule_category;
  l_rec.starting_organization_id	 := p_starting_organization_id;
  l_rec.seeded_rule_flag		 := p_seeded_rule_flag;
  l_rec.status                         	 := p_status;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
--
Procedure load_row
  (
   p_short_name                     in  varchar2
  ,p_rule_set_name                  in  varchar2
  ,p_description                    in  varchar2
  ,p_referenced_rule_set_name       in  varchar2
  ,p_rule_level_cd                  in  varchar2
  ,p_rule_category                  in  varchar2
  ,p_rule_applicability             in  varchar2
  ,p_owner                          in  varchar2
  ,p_last_update_date               in varchar2
  ) is
--
   l_effective_date            date  := sysdate ;
   l_object_version_number     number  := 1;
   l_language                  varchar2(30) ;

--
 l_rule_set_id               pqh_rule_sets.rule_set_id%type := 0;
 l_referenced_rule_set_id    pqh_rule_sets.referenced_rule_set_id%type;
--
--
   l_created_by                 pqh_rule_sets.created_by%TYPE;
   l_last_updated_by            pqh_rule_sets.last_updated_by%TYPE;
   l_creation_date              pqh_rule_sets.creation_date%TYPE;
   l_last_update_date           pqh_rule_sets.last_update_date%TYPE;
   l_last_update_login          pqh_rule_sets.last_update_login%TYPE;
--
--
  cursor c1 is select userenv('LANG') from dual ;
--
  Cursor c5(p_short_name in varchar2) is
               select rule_set_id
               from pqh_rule_sets
               where short_name = p_short_name ;
--
--
  Cursor C_Sel1 is select pqh_rule_sets_s.nextval from sys.dual;
--
--
BEGIN
--
   open c1;
   fetch c1 into l_language ;
   close c1;
--
   Open c5(p_short_name => p_short_name);
   Fetch c5 into l_rule_set_id;
   Close c5;
--
   Open c5(p_short_name => p_referenced_rule_set_name);
   Fetch c5 into l_referenced_rule_set_id;
   Close c5;
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
  If l_rule_set_id <> 0 then
       --
       -- If there is a row for the rule sets
       -- update the row in the base table
       --
    update pqh_rule_sets
    set
       rule_set_name                     = p_rule_set_name,
       short_name                        = p_short_name,
       referenced_rule_set_id            = l_referenced_rule_set_id,
       rule_level_cd                     = p_rule_level_cd,
       rule_category                     = p_rule_category,
       rule_applicability                = p_rule_applicability,
       last_updated_by                   = l_last_updated_by,
       last_update_date                  = l_last_update_date,
       last_update_login                 = l_last_update_login,
       seeded_rule_flag                  = 'Y'
    where rule_set_id = l_rule_set_id
      and nvl(last_updated_by, -1)       in (l_last_updated_by,-1,0,1);
       --
       -- update the tl table
       --
    if sql%found then
       UPDATE pqh_rule_sets_tl
       SET  rule_set_name                  =  p_rule_set_name,
            description                    =  p_description,
            last_updated_by                =  l_last_updated_by,
            last_update_date               =  l_last_update_date,
            last_update_login              =  l_last_update_login,
            source_lang                    = userenv('LANG')
         WHERE rule_set_id                 =  l_rule_set_id
           AND userenv('LANG') in (LANGUAGE, SOURCE_LANG);

       If (sql%notfound) then
          -- no row in TL table so insert row

         --
         insert into pqh_rule_sets_tl(
           rule_set_id,
           rule_set_name,
           description,
	   language,
	   source_lang,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date ,
           last_update_login
          )
          Select
           l_rule_set_id,
	   p_rule_set_name,
           p_description,
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
                     from pqh_rule_sets_tl rtl
                     where rtl.rule_set_id = l_rule_set_id
                       and rtl.language    = l.language_code );
       --
       --
       End if;

    end if; -- sql%found
    --
  Else
      --
      -- Select the next sequence number
      --
      Open C_Sel1;
      Fetch C_Sel1 Into l_rule_set_id;
      Close C_Sel1;
      --
       --
       -- Insert row into the base table
       --

      insert into pqh_rule_sets(
        rule_set_id,
        rule_set_name,
        short_name,
        referenced_rule_set_id,
        rule_level_cd,
        rule_category,
        rule_applicability,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date ,
        last_update_login,
        seeded_rule_flag
      )
     Values(
        l_rule_set_id,
        p_rule_set_name,
        p_short_name,
        l_referenced_rule_set_id,
        p_rule_level_cd,
        p_rule_category,
        p_rule_applicability,
        l_object_version_number,
        l_created_by,
        l_creation_date,
        l_last_updated_by,
        l_last_update_date,
        l_last_update_login,
        'Y'
      );

      insert into pqh_rule_sets_tl(
        rule_set_id,
        rule_set_name,
        description,
	language,
	source_lang,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date ,
        last_update_login
       )
       Select
        l_rule_set_id,
	p_rule_set_name,
	p_description,
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
                  from pqh_rule_sets_tl rtl
                  where rtl.rule_set_id = l_rule_set_id
                    and rtl.language    = l.language_code );
      --
      --
      --
   End if;
   --
 End;
 --
End load_row;
--
Procedure load_seed_row
  (
   p_upload_mode                    in  varchar2
  ,p_short_name                     in  varchar2
  ,p_rule_set_name                  in  varchar2
  ,p_description                    in  varchar2
  ,p_referenced_rule_set_name       in  varchar2
  ,p_rule_level_cd                  in  varchar2
  ,p_rule_category                  in  varchar2
  ,p_rule_applicability             in  varchar2
  ,p_owner                          in  varchar2
  ,p_last_update_date               in  varchar2
  ) is
--
l_data_migrator_mode varchar2(1);
--
Begin
        l_data_migrator_mode := hr_general.g_data_migrator_mode ;
   hr_general.g_data_migrator_mode := 'Y';

     if (p_upload_mode = 'NLS') then
        pqh_rtl_upd.translate_row (
            p_rule_set_name    => p_rule_set_name,
            p_description    => p_description,
            p_short_name       => p_short_name ,
            p_owner            => p_owner);
      else
        pqh_rst_shd.load_row(
             p_rule_set_name                 => p_rule_set_name
            ,p_description                   => p_description
            ,p_short_name                    => p_short_name
            ,p_referenced_rule_set_name      => p_referenced_rule_set_name
            ,p_rule_level_cd                 => p_rule_level_cd
            ,p_rule_category                 => p_rule_category
            ,p_rule_applicability            => p_rule_applicability
            ,p_owner                         => p_owner
            ,p_last_update_date              => p_last_update_date);
      end if;
      hr_general.g_data_migrator_mode := l_data_migrator_mode;
End;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
-- Procedure added as a fix for bug 5484366

Procedure ADD_LANGUAGE
is
begin
  delete from PQH_RULE_SETS_TL T
  where not exists
    (select NULL
    from PQH_RULE_SETS B
    where B.RULE_SET_ID = T.RULE_SET_ID
    );

  update PQH_RULE_SETS_TL T set (
      RULE_SET_NAME
    ) = (select
      B.RULE_SET_NAME
    from PQH_RULE_SETS_TL B
    where B.RULE_SET_ID = T.RULE_SET_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RULE_SET_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RULE_SET_ID,
      SUBT.LANGUAGE
    from PQH_RULE_SETS_TL SUBB, PQH_RULE_SETS_TL SUBT
    where SUBB.RULE_SET_ID = SUBT.RULE_SET_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.RULE_SET_NAME <> SUBT.RULE_SET_NAME
  ));

  insert into PQH_RULE_SETS_TL (
    RULE_SET_ID,
    RULE_SET_NAME,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.RULE_SET_ID,
    B.RULE_SET_NAME,
    B.LAST_UPDATE_DATE,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PQH_RULE_SETS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PQH_RULE_SETS_TL T
    where T.RULE_SET_ID = B.RULE_SET_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
-- --
-- --
end pqh_rst_shd;

/
