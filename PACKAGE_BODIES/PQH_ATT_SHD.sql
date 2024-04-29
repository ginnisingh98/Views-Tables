--------------------------------------------------------
--  DDL for Package Body PQH_ATT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_ATT_SHD" as
/* $Header: pqattrhi.pkb 120.3.12000000.2 2007/04/19 12:37:00 brsinha noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_att_shd.';  -- Global package name
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
  If (p_constraint_name = 'AVCON_14619306_ENABL_000') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_ATTRIBUTES_FK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQH_ATTRIBUTES_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
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
  p_attribute_id                       in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		attribute_id,
	attribute_name,
	master_attribute_id,
	master_table_route_id,
	column_name,
	column_type,
	enable_flag,
	width,
	object_version_number,
        region_itemname,
        attribute_itemname,
        decode_function_name
    from	pqh_attributes
    where	attribute_id = p_attribute_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_attribute_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_attribute_id = g_old_rec.attribute_id and
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
  p_attribute_id                       in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	attribute_id,
	attribute_name,
	master_attribute_id,
	master_table_route_id,
	column_name,
	column_type,
	enable_flag,
	width,
	object_version_number,
        region_itemname,
        attribute_itemname,
        decode_function_name
    from	pqh_attributes
    where	attribute_id = p_attribute_id
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
    hr_utility.set_message_token('TABLE_NAME', 'pqh_attributes');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_attribute_id                  in number,
	p_attribute_name                in varchar2,
	p_master_attribute_id           in number,
	p_master_table_route_id         in number,
	p_column_name                   in varchar2,
	p_column_type                   in varchar2,
	p_enable_flag                   in varchar2,
	p_width                         in number,
	p_object_version_number         in number,
	p_region_itemname               in varchar2,
        p_attribute_itemname            in varchar2,
        p_decode_function_name          in varchar2
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
  l_rec.attribute_id                     := p_attribute_id;
  l_rec.attribute_name                   := p_attribute_name;
  l_rec.master_attribute_id              := p_master_attribute_id;
  l_rec.master_table_route_id            := p_master_table_route_id;
  l_rec.column_name                      := p_column_name;
  l_rec.column_type                      := p_column_type;
  l_rec.enable_flag                      := p_enable_flag;
  l_rec.width                            := p_width;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.region_itemname                  := p_region_itemname;
  l_rec.attribute_itemname               := p_attribute_itemname;
  l_rec.decode_function_name             := p_decode_function_name;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< load_seed_row >---------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure load_seed_row
 ( p_upload_mode                    in  varchar2
  ,p_attribute_name                 in  varchar2
  ,p_master_attr_key_col_name       in  varchar2
  ,p_master_attribute_col_name      in  varchar2
  ,p_master_att_table_alias_name    in  varchar2
  ,p_master_table_alias_name        in  varchar2
  ,p_master_legislation_code	    in  varchar2
  ,p_key_column_name                in  varchar2
  ,p_column_name                    in  varchar2
  ,p_column_type                    in  varchar2
  ,p_enable_flag                    in  varchar2
  ,p_width                          in  number
  ,p_refresh_col_name		    in  varchar2
  ,p_legislation_code		    in  varchar2
  ,p_region_itemname                in  varchar2
  ,p_attribute_itemname             in  varchar2
  ,p_decode_function_name           in  varchar2
  ,p_last_update_date               in varchar2
  ,p_owner                          in  varchar2
 )  is
--
l_data_migrator_mode varchar2(1);
--
Begin
     --
  l_data_migrator_mode := hr_general.g_data_migrator_mode ;
   hr_general.g_data_migrator_mode := 'Y';

       if (p_upload_mode = 'NLS') then
         pqh_atl_upd.translate_row
            ( p_attribute_name                 => p_attribute_name
             ,p_att_col_name                   => p_key_column_name
             ,p_att_master_table_alias_name    => p_master_table_alias_name
             ,p_legislation_code               => p_legislation_code
             ,p_owner                          => p_owner );
       else
        pqh_att_shd.load_row
            ( p_attribute_name                 => p_attribute_name
             ,p_master_attr_key_col_name       => p_master_attr_key_col_name
             ,p_master_attribute_col_name      => p_master_attribute_col_name
             ,p_master_att_table_alias_name    => p_master_att_table_alias_name
             ,p_master_table_alias_name        => p_master_table_alias_name
             ,p_master_legislation_code        => p_master_legislation_code
             ,p_column_name                    => p_column_name
             ,p_key_column_name                => p_key_column_name
             ,p_column_type                    => p_column_type
             ,p_enable_flag                    => p_enable_flag
             ,p_width                          => p_width
             ,p_refresh_col_name               => p_refresh_col_name
             ,p_legislation_code               => p_legislation_code
             ,p_region_itemname                => p_region_itemname
             ,p_attribute_itemname             => p_attribute_itemname
             ,p_decode_function_name           => p_decode_function_name
             ,p_last_update_date               => p_last_update_date
             ,p_owner                          => p_owner );
      end if;

 hr_general.g_data_migrator_mode := l_data_migrator_mode;
End;
-- ----------------------------------------------------------------------------
-- |-----------------------------< load_row >---------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure load_row
 ( p_attribute_name                 in  varchar2
  ,p_master_attr_key_col_name       in  varchar2
  ,p_master_attribute_col_name      in  varchar2
  ,p_master_att_table_alias_name    in  varchar2
  ,p_master_table_alias_name        in  varchar2
  ,p_master_legislation_code	    in  varchar2
  ,p_key_column_name                in  varchar2
  ,p_column_name                    in  varchar2
  ,p_column_type                    in  varchar2
  ,p_enable_flag                    in  varchar2
  ,p_width                          in  number
  ,p_refresh_col_name		    in  varchar2
  ,p_legislation_code		    in  varchar2
  ,p_region_itemname                in  varchar2
  ,p_attribute_itemname             in  varchar2
  ,p_decode_function_name           in  varchar2
  ,p_last_update_date               in varchar2
  ,p_owner                          in  varchar2
 )  is
--
--
   l_effective_date           date  := sysdate ;
   l_object_version_number    number  := 1;
   l_language                 varchar2(30) ;
   l_delete_attr_ranges_flag  varchar2(30) := 'N';
--
   l_attribute_id               pqh_attributes.attribute_id%TYPE := 0 ;
   l_master_attribute_id        pqh_attributes.master_attribute_id%TYPE;
   l_master_table_route_id      pqh_attributes.master_table_route_id%TYPE;
   l_master_att_table_route_id  pqh_attributes.master_table_route_id%TYPE;
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
-- developer key is column_name and master_table_alias
--
cursor csr_attribute_id(p_key_column_name IN VARCHAR2, p_table_id IN NUMBER,
                        p_legislation_code varchar2) is
 select attribute_id,last_update_date
 from pqh_attributes
 where  key_column_name = p_key_column_name
   and nvl(legislation_code,'$$$') = nvl(p_legislation_code,'$$$')
   and nvl(master_table_route_id,-999) = nvl(p_table_id, -999);
--
cursor csr_table_id (p_table_alias IN VARCHAR2) is
 select table_route_id
 from pqh_table_route
 where table_alias = p_table_alias;
--
l_last_upd_in_db           pqh_attributes.last_update_date%TYPE;
l_dummy                    pqh_attributes.last_update_date%TYPE;
--
--
--
Begin
--
--  key to ids
--
   open c1;
   fetch c1 into l_language ;
   close c1;
--
  open csr_table_id(p_table_alias => p_master_table_alias_name );
   fetch csr_table_id into l_master_table_route_id;
  close csr_table_id;
--
  open csr_table_id(p_table_alias => p_master_att_table_alias_name );
   fetch csr_table_id into l_master_att_table_route_id;
  close csr_table_id;
--
  open csr_attribute_id(p_key_column_name => p_key_column_name,
                        p_table_id => l_master_table_route_id,
			p_legislation_code => p_legislation_code);
   fetch csr_attribute_id into l_attribute_id,l_last_upd_in_db;
  close csr_attribute_id;
--
  open csr_attribute_id(p_key_column_name => p_master_attr_key_col_name,
			p_table_id => l_master_att_table_route_id,
			p_legislation_code => p_master_legislation_code);
   fetch csr_attribute_id into l_master_attribute_id,l_dummy;
  close csr_attribute_id;
--
  If p_master_table_alias_name is not null and l_master_table_route_id is null then
     --
     hr_utility.set_message(8302,'PQH_INVALID_MASTER_TABLE_ROUTE');
     hr_utility.raise_error;
     --
  End if;
--
-- populate WHO columns
--
   /**
   l_created_by := 1;
   l_last_updated_by := -1;

  l_creation_date := sysdate;
  l_last_update_date := sysdate;
  **/
  l_last_update_login := 0;

  l_created_by := fnd_load_util.owner_id(p_owner);
  l_last_updated_by := fnd_load_util.owner_id(p_owner);
  l_creation_date := nvl(to_date(p_last_update_date,'YYYY/MM/DD'),trunc(sysdate));
  l_last_update_date := nvl(to_date(p_last_update_date,'YYYY/MM/DD'),trunc(sysdate));
--
--
   Begin
   --
   if l_attribute_id <> 0 then
    -- row exits so update
    If l_last_update_date > l_last_upd_in_db then

     UPDATE pqh_attributes
     SET attribute_name                 =  p_attribute_name,
         master_attribute_id            =  l_master_attribute_id,
         master_table_route_id          =  l_master_table_route_id,
         key_column_name                =  p_key_column_name,
         column_name                    =  nvl(p_column_name,p_key_column_name),
         column_type                    =  p_column_type,
         enable_flag                    =  p_enable_flag,
         width                          =  p_width,
         refresh_col_name		=  p_refresh_col_name,
         legislation_code		=  p_legislation_code,
         region_itemname                =  p_region_itemname,
         attribute_itemname             =  p_attribute_itemname,
         decode_function_name           =  p_decode_function_name,
         last_updated_by                =  l_last_updated_by,
         last_update_date               =  l_last_update_date,
         last_update_login              =  l_last_update_login
      WHERE attribute_id  =  l_attribute_id ;
         --AND NVL(last_updated_by,-1) in (-1,1);
         -- update attributes

      -- update the tl table
     if (sql%found) then

      UPDATE pqh_attributes_tl
      SET  attribute_name               =  p_attribute_name,
         last_updated_by                =  l_last_updated_by,
         last_update_date               =  l_last_update_date,
         last_update_login              =  l_last_update_login,
         source_lang                    = userenv('LANG')
      WHERE attribute_id  =  l_attribute_id
        AND userenv('LANG') in (LANGUAGE, SOURCE_LANG);


        if (sql%notfound) then
         -- no row in TL table so insert row

          insert into pqh_attributes_tl
          (     attribute_id,
                attribute_name,
                language,
                source_lang,
                creation_date,
                created_by,
                last_update_date,
                last_update_login,
                last_updated_by
          )
          Select
                l_attribute_id,
                p_attribute_name,
                L.LANGUAGE_CODE,
                userenv('LANG'),
                l_creation_date,
                l_created_by,
                l_last_update_date,
                l_last_update_login,
                l_last_updated_by
          from FND_LANGUAGES L
          where L.INSTALLED_FLAG in ('I', 'B')
            and not exists
              (select NULL
               from pqh_attributes_tl T
               where T.attribute_id = l_attribute_id
                 and T.LANGUAGE = L.LANGUAGE_CODE);


        end if;

    end if; -- sql%found for main table

    End if;
   else

     -- insert into pqh_attributes and pqh_attributes_tl

      select pqh_attributes_s.nextval into l_attribute_id from dual;

       INSERT INTO pqh_attributes
        (attribute_id ,
         attribute_name,
         master_attribute_id,
         master_table_route_id ,
         key_column_name,
         column_name,
         column_type,
         enable_flag,
         width,
         refresh_col_name,
         legislation_code,
         region_itemname,
         attribute_itemname,
         decode_function_name,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date ,
         last_update_login,
         object_version_number)
       VALUES
         (l_attribute_id,
          p_attribute_name,
          l_master_attribute_id,
          l_master_table_route_id,
          p_key_column_name,
          nvl(p_column_name,p_key_column_name),
          p_column_type,
          p_enable_flag,
          p_width,
          p_refresh_col_name,
          p_legislation_code,
          p_region_itemname,
          p_attribute_itemname,
          p_decode_function_name,
          l_created_by,
          l_creation_date,
          l_last_updated_by,
          l_last_update_date,
          l_last_update_login,
          1 );

        -- insert into tl table

          insert into pqh_attributes_tl
          (     attribute_id,
                attribute_name,
                language,
                source_lang,
                creation_date,
                created_by,
                last_update_date,
                last_update_login,
                last_updated_by
          )
          Select
                l_attribute_id,
                p_attribute_name,
                L.LANGUAGE_CODE,
                userenv('LANG'),
                l_creation_date,
                l_created_by,
                l_last_update_date,
                l_last_update_login,
                l_last_updated_by
          from FND_LANGUAGES L
          where L.INSTALLED_FLAG in ('I', 'B')
            and not exists
              (select NULL
               from pqh_attributes_tl T
               where T.attribute_id = l_attribute_id
                 and T.LANGUAGE = L.LANGUAGE_CODE);


     end if;
   end;
end load_row;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
Procedure ADD_LANGUAGE
is
begin
  delete from PQH_ATTRIBUTES_TL T
  where not exists
    (select NULL
    from PQH_ATTRIBUTES B
    where B.ATTRIBUTE_ID = T.ATTRIBUTE_ID
    );

  update PQH_ATTRIBUTES_TL T set (
      ATTRIBUTE_NAME
    ) = (select
      B.ATTRIBUTE_NAME
    from PQH_ATTRIBUTES_TL B
    where B.ATTRIBUTE_ID = T.ATTRIBUTE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ATTRIBUTE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ATTRIBUTE_ID,
      SUBT.LANGUAGE
    from PQH_ATTRIBUTES_TL SUBB, PQH_ATTRIBUTES_TL SUBT
    where SUBB.ATTRIBUTE_ID = SUBT.ATTRIBUTE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.ATTRIBUTE_NAME <> SUBT.ATTRIBUTE_NAME
  ));

  insert into PQH_ATTRIBUTES_TL (
    ATTRIBUTE_ID,
    ATTRIBUTE_NAME,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ATTRIBUTE_ID,
    B.ATTRIBUTE_NAME,
    B.LAST_UPDATE_DATE,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PQH_ATTRIBUTES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PQH_ATTRIBUTES_TL T
    where T.ATTRIBUTE_ID = B.ATTRIBUTE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
--
--
End pqh_att_shd;
--

/
