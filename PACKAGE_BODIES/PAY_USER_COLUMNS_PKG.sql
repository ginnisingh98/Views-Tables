--------------------------------------------------------
--  DDL for Package Body PAY_USER_COLUMNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_USER_COLUMNS_PKG" AS
/* $Header: pyusc01t.pkb 120.1 2005/07/29 05:08:17 shisriva noship $ */
--
g_dummy	number(1);	-- Dummy for cursor returns which are not needed
g_user_table_id number(9); -- For validating translation;
g_business_group_id number(15); -- For validating translation;
g_legislation_code varchar2(150); -- For validating translation;
--

  procedure insert_row(p_rowid                in out NOCOPY varchar2,
		       p_user_column_id	      in out NOCOPY number,
		       p_user_table_id	      in number,
		       p_business_group_id    in number,
		       p_legislation_code     in varchar2,
		       p_legislation_subgroup in varchar2,
		       p_user_column_name     in varchar2,
		       p_formula_id	      in number ) is
  cursor c1 is
      select pay_user_columns_s.nextval
      from   sys.dual ;

  cursor c2 is
      select rowid
      from   pay_user_columns
      where  user_column_id  = p_user_column_id ;
  --
  begin
  --
    open c1 ;
    fetch c1 into p_user_column_id ;
    close c1 ;

    insert into PAY_USER_COLUMNS
	   ( USER_COLUMN_ID,
	     USER_TABLE_ID,
	     BUSINESS_GROUP_ID,
	     LEGISLATION_CODE,
	     LEGISLATION_SUBGROUP,
	     USER_COLUMN_NAME,
	     FORMULA_ID )
    values ( p_user_column_id,
             p_user_table_id,
	     p_business_group_id,
	     p_legislation_code,
             p_legislation_subgroup,
	     p_user_column_name,
	     p_formula_id ) ;
--
     open c2 ;
     fetch c2 into p_rowid ;
     close c2 ;
--
g_dml_status := TRUE;
--For MLS------------------------------------------------------------------
pay_pct_ins.ins_tl(userenv('LANG'),p_user_column_id,p_user_column_name);
---------------------------------------------------------------------------
g_dml_status := FALSE;
Exception
  When Others then
  g_dml_status := FALSE;
  raise;
  end insert_row ;
--
--
 procedure update_row(p_rowid                in varchar2,
		      p_user_column_id	     in number,
		      p_user_table_id	     in number,
		      p_business_group_id    in number,
		      p_legislation_code     in varchar2,
		      p_legislation_subgroup in varchar2,
		      p_user_column_name     in varchar2,
		      p_formula_id	     in number,
		      p_base_user_column_name in varchar2 default hr_api.g_varchar2)  is
  begin
  --
   update PAY_USER_COLUMNS
   set    USER_COLUMN_ID       = p_user_column_id,
          USER_TABLE_ID        = p_user_table_id,
          BUSINESS_GROUP_ID    = p_business_group_id ,
	  LEGISLATION_CODE     = p_legislation_code,
          LEGISLATION_SUBGROUP = p_legislation_subgroup ,
	  USER_COLUMN_NAME     = p_base_user_column_name,
	  FORMULA_ID 	       = p_formula_id
   where  ROWID = p_rowid;
  --
  g_dml_status := TRUE;
--For MLS------------------------------------------------------------------
pay_pct_upd.upd_tl(userenv('LANG'),p_user_column_id,p_user_column_name);
---------------------------------------------------------------------------
g_dml_status := FALSE;
Exception
  When Others then
  g_dml_status := FALSE;
  raise;
  end update_row;
--
  procedure delete_row(p_rowid   in varchar2) is
  --
  ucid NUMBER;
  begin
  --
  g_dml_status := TRUE;
--For MLS------------------------------------------------------------------
select user_column_id into ucid from pay_user_columns
where rowid = p_rowid;
pay_pct_del.del_tl(ucid);
---------------------------------------------------------------------------
  g_dml_status := FALSE;
     delete from PAY_USER_COLUMNS
    where  ROWID = p_rowid;
  --
   Exception
    When Others then
    g_dml_status := FALSE;
    raise;
  end delete_row;
--
  procedure lock_row (p_rowid                in varchar2,
		      p_user_column_id	     in number,
		      p_user_table_id	     in number,
		      p_business_group_id    in number,
		      p_legislation_code     in varchar2,
		      p_legislation_subgroup in varchar2,
		      p_user_column_name     in varchar2,
		      p_formula_id           in number,
		      p_base_user_column_name in varchar2 default hr_api.g_varchar2) is
--_TL cursor--
  cursor T is select *
              from PAY_USER_COLUMNS_TL
              where user_column_id = p_user_column_id
              and   language = userenv('lang')
              for update NOWAIT ;
  --
    tlrowinfo T%rowtype;
  --
  --
    cursor C is select *
                from   PAY_USER_COLUMNS
                where  rowid = p_rowid
                for update of USER_COLUMN_ID NOWAIT ;
  --
    rowinfo  C%rowtype;
  --
  begin
  --
    open C;
    fetch C into rowinfo;
    close C;
    --
    rowinfo.legislation_code := rtrim(rowinfo.legislation_code);
    rowinfo.user_column_name := rtrim(rowinfo.user_column_name);
    rowinfo.legislation_subgroup := rtrim(rowinfo.legislation_subgroup);
    --
    if ( (rowinfo.USER_COLUMN_ID = p_user_column_id )
     or  (rowinfo.USER_COLUMN_ID is null and p_user_column_id
	  is null ))
    and( (rowinfo.USER_TABLE_ID = p_user_table_id )
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
    and ( (rowinfo.USER_COLUMN_NAME = p_base_user_column_name )
     or  (rowinfo.USER_COLUMN_NAME is null and p_base_user_column_name
	  is null ))
    and ( (rowinfo.FORMULA_ID = p_formula_id )
     or  (rowinfo.FORMULA_ID is null and p_formula_id
	  is null ))
    then
       return ;
    else
       fnd_message.set_name('FND','FORM_RECORD_CHANGED');
       app_exception.raise_exception ;
    end if;

 --_TL table lock
    open T;
    fetch T into tlrowinfo;
    close T;
    --
    -- Remove trailing blanks from char fields
    tlrowinfo.user_column_name      := rtrim(tlrowinfo.user_column_name);
    --
    if ( (tlrowinfo.USER_COLUMN_NAME = p_user_column_name )
     or  (tlrowinfo.USER_COLUMN_NAME is null and p_user_column_name
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
                           p_user_column_name  in varchar2,
                           p_user_table_id     in number,
                           p_business_group_id in number,
			   p_base_user_column_name in varchar2 default hr_api.g_varchar2) is

  cursor c1 is
        select '1'
        from   pay_user_columns uc
        where  upper(uc.user_column_name)          = upper( p_base_user_column_name)
        and    uc.user_table_id                    = p_user_table_id
        and ( p_rowid is null
              or ( p_rowid is not null
                   and p_rowid <> uc.rowid ) )
        and    nvl(uc.business_group_id,nvl(p_business_group_id, -1))
                               = nvl(p_business_group_id, -1);
  l_dummy varchar2(1) ;
  begin
--
     open c1 ;
     fetch c1 into l_dummy ;
     if  c1%found
     then close c1 ;
          fnd_message.set_name( 'PAY' , 'PAY_7885_USER_TABLE_UNIQUE' ) ;
          fnd_message.raise_error ;
     end if ;
     close c1 ;
  end check_unique ;
--
 procedure check_unique_f ( p_rowid             in varchar2,
			   p_user_column_name  in varchar2,
                           p_user_table_id     in number,
                           p_business_group_id in number,
                           p_legislation_code  in varchar2,
			   p_base_user_column_name   in varchar2 default hr_api.g_varchar2) is
  cursor c1 is
        select '1'
        from   pay_user_columns uc
        where  upper(uc.user_column_name)          = upper( p_base_user_column_name)
        and    uc.user_table_id                    = p_user_table_id
        and ( p_rowid is null
              or ( p_rowid is not null
                   and p_rowid <> uc.rowid ) )
        and    nvl(uc.business_group_id,nvl(p_business_group_id, -1))
                               = nvl(p_business_group_id, -1)
        and    nvl(uc.legislation_code, nvl(p_legislation_code,'~~nvl~~'))
                               = nvl(p_legislation_code, '~~nvl~~');

 --_TL cursor
cursor c2 is
	select '1'
	from   pay_user_columns uc,pay_user_columns_tl ucl
	where  upper(ucl.user_column_name)           = upper(p_user_column_name)
	and    ucl.user_column_id = uc.user_column_id
	and    uc.user_table_id   = p_user_table_id
	and    nvl(uc.business_group_id,nvl(p_business_group_id, -1))
                               = nvl(p_business_group_id, -1)
	and    nvl(uc.legislation_code, nvl(p_legislation_code,'~~nvl~~'))
                               = nvl(p_legislation_code, '~~nvl~~')
        and    (ucl.rowid not in ((select rowid from pay_user_columns_tl pct
                         where  pct.user_column_id = (select user_column_id from
                                                     pay_user_columns
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
          fnd_message.set_name( 'PAY' , 'PAY_7885_USER_TABLE_UNIQUE' ) ;
          fnd_message.raise_error ;
     end if ;
     close c1 ;

  --check _TL uniqeness
     open c2 ;
     fetch c2 into l_dummy ;
     if  c2%found
     then close c2 ;
           fnd_message.set_name( 'PAY' , 'PAY_7885_USER_TABLE_UNIQUE' ) ;
           fnd_message.raise_error ;
     end if ;
     close c2 ;
--

  end check_unique_f ;
--

  procedure check_delete ( p_user_column_id in number ) is
  cursor c1 is
      select null
      from   pay_user_column_instances_f
      where  user_column_id = p_user_column_id ;
--
  l_dummy        varchar2(1) ;
  begin
--
--   Check PAY_USER_COLUMN_INSTANCES_F
     open c1 ;
     fetch c1 into l_dummy ;
     if c1%found then
	close c1 ;
           fnd_message.set_name ( 'PAY' , 'HR_6980_USERTAB_VALUES_FIRST' ) ;
	   fnd_message.set_token ( 'ROWCOL' , 'column' ) ;
	   fnd_message.raise_error ;
     end if ;
     close c1 ;
--
 end check_delete ;

--
----For MLS---------------------------------------------------------------------

 procedure check_base_update(p_base_user_column_name   in varchar2,
                             p_rowid                   in varchar2) is
 l_package_name VARCHAR2(80) := 'PAY_USER_COLUMNS_PKG.CHECK_UPDATE';
 original_user_column_name  varchar2(80);
begin
select base_user_column_name into original_user_column_name
from pay_user_columns_vl
where row_id = p_rowid;
 if(p_base_user_column_name <> original_user_column_name) then
  hr_utility.set_location (l_package_name,1);
  fnd_message.set_name ('PER','PER_52480_SSM_NON_UPD_FIELD'); -- checkformat failure
  fnd_message.raise_error;
 end if;
--
end check_base_update;
--

procedure ADD_LANGUAGE
is
begin
  delete from PAY_USER_COLUMNS_TL T
  where not exists
    (select NULL
     from PAY_USER_COLUMNS B
     where B.USER_COLUMN_ID = T.USER_COLUMN_ID
    );
  update PAY_USER_COLUMNS_TL T
  set (USER_COLUMN_NAME) =
  (select B.USER_COLUMN_NAME
   from PAY_USER_COLUMNS_TL B
   where B.USER_COLUMN_ID = T.USER_COLUMN_ID
   and B.LANGUAGE = T.SOURCE_LANG)
  where (T.USER_COLUMN_ID,T.LANGUAGE) in
  (select SUBT.USER_COLUMN_ID,SUBT.LANGUAGE
    from PAY_USER_COLUMNS_TL SUBB, PAY_USER_COLUMNS_TL SUBT
    where SUBB.USER_COLUMN_ID = SUBT.USER_COLUMN_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_COLUMN_NAME <> SUBT.USER_COLUMN_NAME
  ));

  insert into PAY_USER_COLUMNS_TL (
    USER_COLUMN_ID,
    USER_COLUMN_NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.USER_COLUMN_ID,
    B.USER_COLUMN_NAME,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PAY_USER_COLUMNS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PAY_USER_COLUMNS_TL T
    where T.USER_COLUMN_ID = B.USER_COLUMN_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
--
procedure TRANSLATE_ROW (
   X_B_USER_COLUMN_NAME in VARCHAR2,
   X_B_LEGISLATION_CODE in VARCHAR2,
   X_USER_COLUMN_NAME in VARCHAR2,
   X_OWNER in VARCHAR2
) is
begin
  UPDATE PAY_USER_COLUMNS_TL
    SET USER_COLUMN_NAME = nvl(X_USER_COLUMN_NAME,USER_COLUMN_NAME),
        last_update_date = SYSDATE,
        last_updated_by = decode(x_owner,'SEED',1,0),
        last_update_login = 0,
        source_lang = userenv('LANG')
  WHERE userenv('LANG') IN (language,source_lang)
    AND USER_COLUMN_ID in
        (select USER_COLUMN_ID
           from PAY_USER_COLUMNS
          where nvl(USER_COLUMN_NAME,'~null~')=nvl(X_B_USER_COLUMN_NAME,'~null~')
            and nvl(LEGISLATION_CODE,'~null~') = nvl(X_B_LEGISLATION_CODE,'~null~')
            and BUSINESS_GROUP_ID is NULL);
  if (sql%notfound) then
  null;
  end if;
end TRANSLATE_ROW;
--
--
PROCEDURE set_translation_globals(p_business_group_id IN NUMBER,
				  p_legislation_code IN VARCHAR2,
                                  p_user_table_id IN NUMBER) IS
BEGIN
   g_business_group_id := p_business_group_id;
   g_legislation_code := p_legislation_code;
   g_user_table_id := p_user_table_id;
END;
--
--

procedure validate_translation(user_column_id	NUMBER,
			       language		VARCHAR2,
			       user_column_name	VARCHAR2,
			       p_business_group_id IN NUMBER DEFAULT NULL,
			       p_legislation_code IN VARCHAR2 DEFAULT NULL) IS
/*

This procedure fails if a user_column translation is already present in
the table for a given language.  Otherwise, no action is performed.  It is
used to ensure uniqueness of translated user_column names.

*/

--
-- This cursor implements the validation we require,
-- and expects that the various package globals are set before
-- the call to this procedure is made.  This is done from the
-- user-named trigger 'TRANSLATIONS' in the form
--
cursor c_translation(p_language IN VARCHAR2,
                     p_user_column_name IN VARCHAR2,
                     p_user_column_id IN NUMBER,
                     p_user_table_id IN NUMBER,
                     p_bus_grp_id IN NUMBER,
		     p_leg_code IN varchar2)  IS
       select '1'
	from   pay_user_columns uc,
	       pay_user_columns_tl ucl
	where  upper(ucl.user_column_name) = upper(p_user_column_name)
	AND   uc.user_column_id = ucl.user_column_id
	AND   (ucl.user_column_id <> p_user_column_id OR p_user_column_id IS NULL)
	AND   uc.user_table_id   = p_user_table_id
    AND   ucl.language = p_language
	AND   (nvl(uc.business_group_id,-1) = nvl(p_bus_grp_id,-1) OR p_bus_grp_id IS NULL)
	AND   (nvl(uc.LEGISLATION_CODE,'~null~') = nvl(p_leg_code,'~null~') OR p_leg_code IS NULL);

       l_package_name VARCHAR2(80);
       l_business_group_id NUMBER;
       l_legislation_code VARCHAR2(150);


BEGIN
   l_package_name  := 'PAY_USER_COLUMNS_PKG.VALIDATE_TRANSLATION';
   l_business_group_id := p_business_group_id;
   l_legislation_code  := p_legislation_code;
   hr_utility.set_location (l_package_name,10);
   OPEN c_translation(language, user_column_name,user_column_id,g_user_table_id,
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
--------------------------------------------------------------------------------
END PAY_USER_COLUMNS_PKG;

/
