--------------------------------------------------------
--  DDL for Package Body PAY_USER_TABLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_USER_TABLES_PKG" AS
/* $Header: pyust01t.pkb 120.2 2006/05/12 02:45:59 snekkala noship $ */
--
g_dummy	number(1);	-- Dummy for cursor returns which are not needed
--
  procedure insert_row(p_rowid                in out 	NOCOPY	varchar2,
		       p_user_table_id	      in out 	NOCOPY	number,
		       p_business_group_id    in 		number,
		       p_legislation_code     in 		varchar2,
		       p_legislation_subgroup in 		varchar2,
		       p_range_or_match       in 		varchar2,
		       p_user_key_units       in 		varchar2,
		       p_user_table_name      in 		varchar2,
		       p_user_row_title	      in 		varchar2 )  is
  cursor c1 is
      select pay_user_tables_s.nextval
      from   sys.dual ;
  --
  cursor c2 is
      select rowid
      from   pay_user_tables
      where  user_table_id  = p_user_table_id ;
  --
  begin
  --
    check_unique ( p_rowid             => p_rowid,
                   p_user_table_name   => p_user_table_name,
		   p_business_group_id => p_business_group_id,
		   p_legislation_code  => p_legislation_code,
		   p_base_user_table_name   => p_user_table_name) ;
    --
    open c1 ;
    fetch c1 into p_user_table_id ;
    close c1 ;
    --
    insert into PAY_USER_TABLES
	   ( USER_TABLE_ID,
	     BUSINESS_GROUP_ID,
	     LEGISLATION_CODE,
	     LEGISLATION_SUBGROUP,
	     RANGE_OR_MATCH,
	     USER_KEY_UNITS,
	     USER_TABLE_NAME,
	     USER_ROW_TITLE )
    values ( p_user_table_id,
	     p_business_group_id,
	     p_legislation_code,
             p_legislation_subgroup,
             p_range_or_match,
	     p_user_key_units,
	     p_user_table_name,
	     p_user_row_title ) ;
--
     open c2 ;
     fetch c2 into p_rowid ;
     close c2 ;
--
g_dml_status := TRUE;
---For MLS-----------------------------------------------------------------------
pay_ptt_ins.ins_tl(userenv('LANG'),p_user_table_id,
                             p_user_table_name,p_user_row_title);
--------------------------------------------------------------------------------
g_dml_status := FALSE;
Exception
  When Others then
  g_dml_status := FALSE;
  raise;

  end insert_row ;
--
 procedure update_row(p_rowid                in varchar2,
		      p_user_table_id	     in number,
		      p_business_group_id    in number,
		      p_legislation_code     in varchar2,
		      p_legislation_subgroup in varchar2,
		      p_range_or_match       in varchar2,
		      p_user_key_units       in varchar2,
		      p_user_table_name      in varchar2,
		      p_user_row_title	     in varchar2,
		      p_base_user_table_name in varchar2 default hr_api.g_varchar2,
		      p_base_user_row_title  in varchar2 default hr_api.g_varchar2)  is
  begin
  --
    check_unique ( p_rowid             => p_rowid,
                   p_user_table_name   => p_user_table_name,
		   p_business_group_id => p_business_group_id,
		   p_legislation_code  => p_legislation_code,
		   p_base_user_table_name   => p_base_user_table_name) ;
    --
   update PAY_USER_TABLES
   set    USER_TABLE_ID        = p_user_table_id,
          BUSINESS_GROUP_ID    = p_business_group_id ,
	  LEGISLATION_CODE     = p_legislation_code,
          LEGISLATION_SUBGROUP = p_legislation_subgroup ,
          RANGE_OR_MATCH       = p_range_or_match,
          USER_KEY_UNITS       = p_user_key_units,
	  USER_TABLE_NAME      = p_base_user_table_name,
          USER_ROW_TITLE       = p_base_user_row_title
   where  ROWID = p_rowid;
  --
g_dml_status := TRUE;
---For MLS-----------------------------------------------------------------------
pay_ptt_upd.upd_tl(userenv('LANG'),p_user_table_id,
                   p_user_table_name,p_user_row_title);
---------------------------------------------------------------------------------
g_dml_status := FALSE;
Exception
  When Others then
  g_dml_status := FALSE;
  raise;
  end update_row;
--
  procedure delete_row(p_rowid         in varchar2,
		       p_user_table_id in number ) is
  --
  begin
    check_references( p_user_table_id => p_user_table_id ) ;
g_dml_status := TRUE;
---For MLS-----------------------------------------------------------------------
pay_ptt_del.del_tl(p_user_table_id);
--------------------------------------------------------------------------------
 g_dml_status := FALSE;
  --
    delete from PAY_USER_TABLES
    where  ROWID = p_rowid;
  --
  Exception
  When Others then
  g_dml_status := FALSE;
  raise;
  end delete_row;
--
  procedure lock_row (p_rowid                in varchar2,
		      p_user_table_id	     in number,
		      p_business_group_id    in number,
		      p_legislation_code     in varchar2,
		      p_legislation_subgroup in varchar2,
		      p_range_or_match       in varchar2,
		      p_user_key_units       in varchar2,
		      p_user_table_name      in varchar2,
		      p_user_row_title	     in varchar2,
		      p_base_user_table_name      in varchar2 default hr_api.g_varchar2,
		      p_base_user_row_title	  in varchar2 default hr_api.g_varchar2)  is

  --_TL cursor--
  cursor T is select *
              from PAY_USER_TABLES_TL
              where user_table_id = p_user_table_id
              and   language = userenv('lang')
	      for update NOWAIT ;
  --
    tlrowinfo T%rowtype;
  --
  --
    cursor C is select *
                from   PAY_USER_TABLES
                where  rowid = p_rowid
                for update of USER_TABLE_ID NOWAIT ;
  --
    rowinfo  C%rowtype;
  --

  begin
  --
    open C;
    fetch C into rowinfo;
    close C;
    --
    --
    -- Remove trailing blanks from char fields
    rowinfo.legislation_code     := rtrim(rowinfo.legislation_code);
    rowinfo.range_or_match       := rtrim(rowinfo.range_or_match);
    rowinfo.user_key_units       := rtrim(rowinfo.user_key_units);
    rowinfo.user_table_name      := rtrim(rowinfo.user_table_name);
    rowinfo.legislation_subgroup := rtrim(rowinfo.legislation_subgroup);
    rowinfo.user_row_title       := rtrim(rowinfo.user_row_title);
    --
    if ( (rowinfo.USER_TABLE_ID = p_user_table_id )
     or  (rowinfo.USER_TABLE_ID is null and p_user_table_id
	  is null ))
    and( (rowinfo.BUSINESS_GROUP_ID = p_business_group_id )
     or  (rowinfo.BUSINESS_GROUP_ID is null and p_business_group_id
	  is null ))
    and( (rowinfo.LEGISLATION_CODE = p_legislation_code )
     or  (rowinfo.LEGISLATION_CODE is null and p_legislation_code
	  is null ))
    and( (rowinfo.LEGISLATION_SUBGROUP = p_legislation_subgroup )
     or  (rowinfo.LEGISLATION_SUBGROUP is null and p_legislation_subgroup
	  is null ))
    and( (rowinfo.RANGE_OR_MATCH = p_range_or_match )
     or  (rowinfo.RANGE_OR_MATCH is null and p_range_or_match
	  is null ))
    and ( (rowinfo.USER_KEY_UNITS = p_user_key_units )
     or  (rowinfo.USER_KEY_UNITS is null and p_user_key_units
	  is null ))
    and ( (rowinfo.USER_TABLE_NAME = p_base_user_table_name )
     or  (rowinfo.USER_TABLE_NAME is null and p_base_user_table_name
	  is null ))
    and ( (rowinfo.USER_ROW_TITLE = p_base_user_row_title )
     or  (rowinfo.USER_ROW_TITLE is null and p_base_user_row_title
	  is null ))
    then
       return ;
    else
       fnd_message.set_name( 'FND' , 'FORM_RECORD_CHANGED' ) ;
       app_exception.raise_exception ;
    end if;

--_TL table lock
    open T;
    fetch T into tlrowinfo;
    close T;
    --
    --
    -- Remove trailing blanks from char fields
    tlrowinfo.user_table_name      := rtrim(tlrowinfo.user_table_name);
    tlrowinfo.user_row_title       := rtrim(tlrowinfo.user_row_title);
    --
    if ( (tlrowinfo.USER_TABLE_NAME = p_user_table_name )
     or  (tlrowinfo.USER_TABLE_NAME is null and p_user_table_name
	  is null ))
    and ( (tlrowinfo.USER_ROW_TITLE = p_user_row_title )
     or  (tlrowinfo.USER_ROW_TITLE is null and p_user_row_title
	  is null ))
    then
       return ;
    else
       fnd_message.set_name( 'FND' , 'FORM_RECORD_CHANGED' ) ;
       app_exception.raise_exception ;
    end if;

  end lock_row;
--

  procedure check_unique ( p_rowid             in varchar2,
			   p_user_table_name   in varchar2,
			   p_business_group_id in number,
			   p_legislation_code  in varchar2,
  			   p_base_user_table_name   in varchar2 default hr_api.g_varchar2) is
  cursor c1 is
	select '1'
	from   pay_user_tables ut
	where  upper(ut.user_table_name)           = upper(p_base_user_table_name)
	and    nvl(ut.business_group_id,nvl(p_business_group_id, -1))
                               = nvl(p_business_group_id, -1)
	and    nvl(ut.legislation_code, nvl(p_legislation_code,'~~nvl~~'))
                               = nvl(p_legislation_code, '~~nvl~~')
	and ( p_rowid is null
              or ( p_rowid is not null
                   and p_rowid <> ut.rowid )
	    ) ;
  cursor c2 is
	select '1'
	from   pay_user_tables ut,pay_user_tables_tl utl
	where  upper(utl.user_table_name)           = upper(p_user_table_name)
	and     utl.user_table_id                           = ut.user_table_id
	and    nvl(ut.business_group_id,nvl(p_business_group_id, -1))
                               = nvl(p_business_group_id, -1)
	and    nvl(ut.legislation_code, nvl(p_legislation_code,'~~nvl~~'))
                               = nvl(p_legislation_code, '~~nvl~~')
	and    (utl.rowid not in ((select rowid from pay_user_tables_tl ptt
                         where  ptt.user_table_id = (select user_table_id from
                                                     pay_user_tables
                                                     where rowid = p_rowid)
                         --and language = userenv('lang')
			 )));
  l_dummy varchar2(1) ;
  begin
--
     open c1 ;
     fetch c1 into l_dummy ;
     if  c1%found
     then close c1 ;
          hr_utility.set_message( 801 , 'PAY_7689_USER_TAB_TAB_UNIQUE' ) ;
	  hr_utility.raise_error ;
     end if ;
     close c1 ;
--
--check _TL uniqeness
     open c2 ;
     fetch c2 into l_dummy ;
     if  c2%found
     then close c2 ;
          hr_utility.set_message( 801 , 'PAY_7689_USER_TAB_TAB_UNIQUE' ) ;
	  hr_utility.raise_error ;
     end if ;
     close c2 ;
--
  end check_unique ;
--
  procedure check_references ( p_user_table_id in number ) is
  cursor c1 is
      select '1'
      from   pay_user_columns
      where  user_table_id = p_user_table_id ;
--
  cursor c2 is
      select '1'
      from   pay_user_rows_f
      where  user_table_id = p_user_table_id ;
  l_dummy        varchar2(1) ;
  l_detail_found boolean := FALSE ;
  begin
--
--   Check PAY_USER_COLUMNS
     open c1 ;
     fetch c1 into l_dummy ;
     if c1%found then
	close c1 ;
        hr_utility.set_message ( 801 , 'PAY_6368_USERTAB_COLUMNS_FIRST' ) ;
	hr_utility.raise_error ;
     end if ;
     close c1 ;
--
--   Check PAY_USER_ROWS_F
     open c2 ;
     fetch c2 into l_dummy ;
     if c2%found then
	 close c2 ;
         hr_utility.set_message ( 801 , 'PAY_6369_USERTAB_ROWS_FIRST' ) ;
         hr_utility.raise_error ;
     end if ;
     close c2 ;
--
 end check_references ;
--

 procedure check_base_update(p_base_user_table_name   in varchar2,
                             p_rowid                  in varchar2) is
 l_package_name VARCHAR2(80) := 'PAY_USER_TABLES_PKG.CHECK_UPDATE';
 original_user_table_name  varchar2(80);
begin
select base_user_table_name into original_user_table_name
from pay_user_tables_vl
where row_id = p_rowid;
 if(p_base_user_table_name <> original_user_table_name) then
  hr_utility.set_location (l_package_name,1);
  fnd_message.set_name ('PER','PER_52480_SSM_NON_UPD_FIELD'); -- checkformat failure
  fnd_message.raise_error;
 end if;
--
end check_base_update;
--

 procedure get_db_defaults ( p_lower_bound  in out NOCOPY varchar2,
			     p_upper_bound  in out NOCOPY varchar2,
			     p_match_prompt in out NOCOPY varchar2,
			     p_number_text  in out NOCOPY varchar2 ) is
 cursor c1 is
   select lo.lookup_code,
          lo.meaning
   from   hr_lookups lo
   where  lookup_type = 'USER_VALUES_PROMPT'
   and    lo.lookup_code in ( 'L' , 'U' , 'E' ) ;
begin
     for range_prompt in c1
     loop
         if ( range_prompt.lookup_code = 'L' ) then
            p_lower_bound  := range_prompt.meaning ;
         elsif ( range_prompt.lookup_code = 'U' ) then
            p_upper_bound  := range_prompt.meaning ;
         else
	    p_match_prompt := range_prompt.meaning ;
         end if ;
     end loop ;
--
  p_number_text := hr_general.decode_lookup( 'DATA_TYPE' , 'N' ) ;
--
end get_db_defaults ;
--
function ut_lov_conversion ( p_value in varchar2,
			     p_uom in varchar2 ) return varchar2 is
--
  l_display varchar2 (80);
--
begin
--
  if ( p_uom = 'D' ) then
    l_display :=  fnd_date.date_to_displaydate ( fnd_date.canonical_to_date ( p_value ) );
  elsif  ( p_uom = 'N' ) then
--    l_display :=  fnd_number.canonical_to_number ( p_value );
      l_display := hr_chkfmt.changeformat(p_value,'N',NULL);
  else
    l_display := p_value;  -- for Text data type
  end if;
  return l_display;
--
exception
  when others then
    l_display := p_value;
    return l_display;
--
end ut_lov_conversion;
--
--For MLS-----------------------------------------------------------------------
procedure ADD_LANGUAGE
is
begin
  delete from PAY_USER_TABLES_TL T
  where not exists
    (select NULL
    from PAY_USER_TABLES B
    where B.USER_TABLE_ID = T.USER_TABLE_ID
    );
  update PAY_USER_TABLES_TL T set (
      USER_TABLE_NAME,
      USER_ROW_TITLE
    ) = (select
      B.USER_TABLE_NAME,
      B.USER_ROW_TITLE
    from PAY_USER_TABLES_TL B
    where B.USER_TABLE_ID = T.USER_TABLE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.USER_TABLE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.USER_TABLE_ID,
      SUBT.LANGUAGE
    from PAY_USER_TABLES_TL SUBB, PAY_USER_TABLES_TL SUBT
    where SUBB.USER_TABLE_ID = SUBT.USER_TABLE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_TABLE_NAME <> SUBT.USER_TABLE_NAME
      or SUBB.USER_ROW_TITLE <> SUBT.USER_ROW_TITLE
      or (SUBB.USER_ROW_TITLE is null and SUBT.USER_ROW_TITLE is not null)
      or (SUBB.USER_ROW_TITLE is not null and SUBT.USER_ROW_TITLE is null)
  ));
  insert into PAY_USER_TABLES_TL (
    USER_TABLE_ID,
    USER_TABLE_NAME,
    USER_ROW_TITLE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.USER_TABLE_ID,
    B.USER_TABLE_NAME,
    B.USER_ROW_TITLE,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PAY_USER_TABLES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PAY_USER_TABLES_TL T
    where T.USER_TABLE_ID = B.USER_TABLE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
--
procedure TRANSLATE_ROW (
   X_B_USER_TABLE_NAME in VARCHAR2,
   X_B_LEGISLATION_CODE in VARCHAR2,
   X_USER_TABLE_NAME in VARCHAR2,
   X_USER_ROW_TITLE in VARCHAR2,
   X_OWNER in VARCHAR2
) is
begin
  UPDATE PAY_USER_TABLES_tl
    SET USER_TABLE_NAME = nvl(X_USER_TABLE_NAME,USER_TABLE_NAME),
        USER_ROW_TITLE = nvl(X_USER_ROW_TITLE,USER_ROW_TITLE),
        last_update_date = SYSDATE,
        last_updated_by = decode(x_owner,'SEED',1,0),
        last_update_login = 0,
        source_lang = userenv('LANG')
  WHERE userenv('LANG') IN (language,source_lang)
    AND USER_TABLE_ID in
        (select USER_TABLE_ID
           from PAY_USER_TABLES
          where nvl(USER_TABLE_NAME,'~null~')=nvl(X_B_USER_TABLE_NAME,'~null~')
            and nvl(LEGISLATION_CODE,'~null~') = nvl(X_B_LEGISLATION_CODE,'~null~')
            and BUSINESS_GROUP_ID is NULL);
  if (sql%notfound) then
  null;
  end if;
end TRANSLATE_ROW;

--

procedure validate_translation(user_table_id	NUMBER,
			       language		VARCHAR2,
			       user_table_name	VARCHAR2,
			       user_row_title	VARCHAR2,
			       p_business_group_id IN NUMBER DEFAULT NULL,
			       p_legislation_code IN VARCHAR2 DEFAULT NULL) IS
/*

This procedure fails if a user_table translation is already present in
the table for a given language.  Otherwise, no action is performed.  It is
used to ensure uniqueness of translated user_table names.

*/

--
-- This cursor implements the validation we require,
-- and expects that the various package globals are set before
-- the call to this procedure is made.  This is done from the
-- user-named trigger 'TRANSLATIONS' in the form
--
cursor c_translation(p_language IN VARCHAR2,
                     p_user_table_name IN VARCHAR2,
                     p_user_table_id IN NUMBER,
                     p_bus_grp_id IN NUMBER,
		     p_leg_code IN varchar2)  IS
       SELECT  1
	 FROM  pay_user_tables_tl ptt,
	       pay_user_tables    put
	 WHERE upper(ptt.user_table_name)=upper(p_user_table_name)
	 AND   ptt.user_table_id = put.user_table_id
	 AND   ptt.language = p_language
	 AND   (put.user_table_id <> p_user_table_id OR p_user_table_id IS NULL)
	 AND   (nvl(put.business_group_id,-1) = nvl(p_bus_grp_id,-1) OR p_bus_grp_id IS NULL)
	 AND   (nvl(put.LEGISLATION_CODE,'~null~') = nvl(p_leg_code,'~null~') OR p_leg_code IS NULL);

       l_package_name VARCHAR2(80);
       l_business_group_id NUMBER;
       l_legislation_code VARCHAR2(150);

BEGIN
   l_package_name  := 'PAY_USER_TABLES_PKG.VALIDATE_TRANSLATION';
   l_business_group_id := p_business_group_id;
   l_legislation_code  := p_legislation_code;
   hr_utility.set_location (l_package_name,10);
   OPEN c_translation(language, user_table_name,user_table_id,
		     l_business_group_id,l_legislation_code);
      	hr_utility.set_location (l_package_name,50);
       FETCH c_translation INTO g_dummy;

       IF c_translation%NOTFOUND THEN
      	hr_utility.set_location (l_package_name,60);
	  CLOSE c_translation;
       ELSE
      	hr_utility.set_location (l_package_name,70);
	  CLOSE c_translation;
	  fnd_message.set_name('PAY','HR_TRANSLATION_EXISTS');
	  fnd_message.raise_error;
       END IF;
      	hr_utility.set_location ('Leaving:'||l_package_name,80);
END validate_translation;
--

function return_dml_status
return boolean
IS
begin
return g_dml_status;
end return_dml_status;
--
END PAY_USER_TABLES_PKG;

/
