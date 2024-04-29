--------------------------------------------------------
--  DDL for Package Body PER_CUSTOMIZED_RESTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CUSTOMIZED_RESTR_PKG" as
/* $Header: perpepcr.pkb 115.5 2003/07/03 13:33:09 tvankayl noship $ */
------------------------------------------------------------------------------
/*
==============================================================================

	 01-JUL-03      tvankayl       Modified table handles Insert_row,
				       Update_Row , Lock_ Row , Delete_row

				       1. prototypes were changed to follow
					  AOL standards.
				       2. DML operations were applied on
				          Translation table also.

					 Load_row and Translate_row were
				         modified to compensate for changes in
					 insert_row and update_row
 115.5    03-JUL-03      tvankayl       Removed unnecessary comments.
==============================================================================
                                                                            */

--------------------------------------------------------------------------------
g_dummy	number(1);	-- Dummy for cursor returns which are not needed
g_business_group_id number(15) default null; -- For validating translation;
g_legislation_code varchar2(30) default null; -- For validating translation;

--------------------------------------------------------------------------------
--

PROCEDURE UNIQUENESS_CHECK(P_APPLICATION_SHORT_NAME     VARCHAR2,
                            P_FORM_NAME              VARCHAR2,
                            P_NAME                   VARCHAR2,
                            P_BUSINESS_GROUP_NAME    VARCHAR2,
                            P_LEGISLATION_CODE       VARCHAR2,
                            P_ROWID                  VARCHAR2)
IS
  L_DUMMY1  number;
  l_appl_id number;
  CURSOR C_APPL IS
         select application_id
         from fnd_application
         where application_short_name = upper(P_APPLICATION_SHORT_NAME);
 CURSOR C1 (c1_p_appl_id number) IS
  	select  1
  	from    PAY_CUSTOMIZED_RESTRICTIONS pcr
         where   pcr.application_id = c1_p_appl_id
         and     pcr.form_name = P_FORM_NAME
         and     pcr.name = P_NAME
         and     pcr.legislation_code = P_LEGISLATION_CODE
  	and     (P_ROWID        is null
         	 or P_ROWID    <> pcr.rowid);
 BEGIN
   OPEN C_APPL;
   FETCH C_APPL INTO l_appl_id;
   CLOSE C_APPL;
   OPEN C1(l_appl_id);
   FETCH C1 INTO L_DUMMY1;
   IF C1%NOTFOUND THEN
    CLOSE C1;
   ELSE
    CLOSE C1;
    hr_utility.set_message('801','HR_7777_DEF_DESCR_EXISTS');
    hr_utility.raise_error;
   END IF;

 end UNIQUENESS_CHECK;



procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CUSTOMIZED_RESTRICTION_ID in out nocopy NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_LEGISLATION_CODE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FORM_NAME in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_COMMENTS in LONG,
  X_LEGISLATION_SUBGROUP in VARCHAR2,
  X_QUERY_FORM_TITLE in VARCHAR2,
  X_STANDARD_FORM_TITLE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from PAY_CUSTOMIZED_RESTRICTIONS
    where CUSTOMIZED_RESTRICTION_ID = X_CUSTOMIZED_RESTRICTION_ID;

  cursor C_NEXTVAL is select PAY_CUSTOMIZED_RESTRICTIONS_S.NEXTVAL from SYS.DUAL;

begin


  OPEN  C_NEXTVAL;
	FETCH C_NEXTVAL INTO X_CUSTOMIZED_RESTRICTION_ID;
  CLOSE C_NEXTVAL;


  insert into PAY_CUSTOMIZED_RESTRICTIONS (
    CUSTOMIZED_RESTRICTION_ID,
    BUSINESS_GROUP_ID,
    LEGISLATION_CODE,
    APPLICATION_ID,
    FORM_NAME,
    ENABLED_FLAG,
    NAME,
    COMMENTS,
    LEGISLATION_SUBGROUP,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_CUSTOMIZED_RESTRICTION_ID,
    X_BUSINESS_GROUP_ID,
    X_LEGISLATION_CODE,
    X_APPLICATION_ID,
    X_FORM_NAME,
    X_ENABLED_FLAG,
    X_NAME,
    X_COMMENTS,
    X_LEGISLATION_SUBGROUP,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into PAY_CUSTOM_RESTRICTIONS_TL (
    CUSTOMIZED_RESTRICTION_ID,
    QUERY_FORM_TITLE,
    STANDARD_FORM_TITLE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CUSTOMIZED_RESTRICTION_ID,
    X_QUERY_FORM_TITLE,
    X_STANDARD_FORM_TITLE,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from PAY_CUSTOM_RESTRICTIONS_TL T
    where T.CUSTOMIZED_RESTRICTION_ID = X_CUSTOMIZED_RESTRICTION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
      close c;
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE',
                                   'per_customized_restr_pkg.insert_row');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;

      raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_CUSTOMIZED_RESTRICTION_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_LEGISLATION_CODE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FORM_NAME in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_COMMENTS in LONG,
  X_LEGISLATION_SUBGROUP in VARCHAR2,
  X_QUERY_FORM_TITLE in VARCHAR2,
  X_STANDARD_FORM_TITLE in VARCHAR2
) is
  cursor c is select
      BUSINESS_GROUP_ID,
      LEGISLATION_CODE,
      APPLICATION_ID,
      FORM_NAME,
      ENABLED_FLAG,
      NAME,
      COMMENTS,
      LEGISLATION_SUBGROUP
    from PAY_CUSTOMIZED_RESTRICTIONS
    where CUSTOMIZED_RESTRICTION_ID = X_CUSTOMIZED_RESTRICTION_ID
    for update of CUSTOMIZED_RESTRICTION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      QUERY_FORM_TITLE,
      STANDARD_FORM_TITLE,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PAY_CUSTOM_RESTRICTIONS_TL
    where CUSTOMIZED_RESTRICTION_ID = X_CUSTOMIZED_RESTRICTION_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CUSTOMIZED_RESTRICTION_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.BUSINESS_GROUP_ID = X_BUSINESS_GROUP_ID)
           OR ((recinfo.BUSINESS_GROUP_ID is null) AND (X_BUSINESS_GROUP_ID is null)))
      AND ((recinfo.LEGISLATION_CODE = X_LEGISLATION_CODE)
           OR ((recinfo.LEGISLATION_CODE is null) AND (X_LEGISLATION_CODE is null)))
      AND (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND (recinfo.FORM_NAME = X_FORM_NAME)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.NAME = X_NAME)
      AND ((recinfo.COMMENTS = X_COMMENTS)
           OR ((recinfo.COMMENTS is null) AND (X_COMMENTS is null)))
      AND ((recinfo.LEGISLATION_SUBGROUP = X_LEGISLATION_SUBGROUP)
           OR ((recinfo.LEGISLATION_SUBGROUP is null) AND (X_LEGISLATION_SUBGROUP is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.QUERY_FORM_TITLE = X_QUERY_FORM_TITLE)
          AND (tlinfo.STANDARD_FORM_TITLE = X_STANDARD_FORM_TITLE)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_CUSTOMIZED_RESTRICTION_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_LEGISLATION_CODE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FORM_NAME in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_COMMENTS in LONG,
  X_LEGISLATION_SUBGROUP in VARCHAR2,
  X_QUERY_FORM_TITLE in VARCHAR2,
  X_STANDARD_FORM_TITLE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update PAY_CUSTOMIZED_RESTRICTIONS set
    BUSINESS_GROUP_ID = X_BUSINESS_GROUP_ID,
    LEGISLATION_CODE = X_LEGISLATION_CODE,
    APPLICATION_ID = X_APPLICATION_ID,
    FORM_NAME = X_FORM_NAME,
    ENABLED_FLAG = X_ENABLED_FLAG,
    NAME = X_NAME,
    COMMENTS = X_COMMENTS,
    LEGISLATION_SUBGROUP = X_LEGISLATION_SUBGROUP,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CUSTOMIZED_RESTRICTION_ID = X_CUSTOMIZED_RESTRICTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update PAY_CUSTOM_RESTRICTIONS_TL set
    QUERY_FORM_TITLE = X_QUERY_FORM_TITLE,
    STANDARD_FORM_TITLE = X_STANDARD_FORM_TITLE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CUSTOMIZED_RESTRICTION_ID = X_CUSTOMIZED_RESTRICTION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then

	insert into PAY_CUSTOM_RESTRICTIONS_TL (
		        CUSTOMIZED_RESTRICTION_ID,
			QUERY_FORM_TITLE,
		        STANDARD_FORM_TITLE,
			CREATED_BY,
			CREATION_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_DATE,
			LAST_UPDATE_LOGIN,
			LANGUAGE,
			SOURCE_LANG
	  ) select
		X_CUSTOMIZED_RESTRICTION_ID,
		X_QUERY_FORM_TITLE,
		X_STANDARD_FORM_TITLE,
		0 ,
		SYSDATE,
		X_LAST_UPDATED_BY,
		X_LAST_UPDATE_DATE,
		X_LAST_UPDATE_LOGIN,
		L.LANGUAGE_CODE,
		userenv('LANG')
	  from FND_LANGUAGES L
	where L.INSTALLED_FLAG in ('I', 'B')
	  and not exists
	    (select NULL
		    from PAY_CUSTOM_RESTRICTIONS_TL T
		    where T.CUSTOMIZED_RESTRICTION_ID = X_CUSTOMIZED_RESTRICTION_ID
		    and T.LANGUAGE = L.LANGUAGE_CODE);

  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CUSTOMIZED_RESTRICTION_ID in NUMBER
) is
begin
  delete from PAY_CUSTOM_RESTRICTIONS_TL
  where CUSTOMIZED_RESTRICTION_ID = X_CUSTOMIZED_RESTRICTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from PAY_CUSTOMIZED_RESTRICTIONS
  where CUSTOMIZED_RESTRICTION_ID = X_CUSTOMIZED_RESTRICTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;


procedure LOAD_ROW
  (X_APPLICATION_SHORT_NAME   in varchar2,
  X_FORM_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_BUSINESS_GROUP_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_QUERY_FORM_TITLE in VARCHAR2,
  X_STANDARD_FORM_TITLE in VARCHAR2,
  X_LEGISLATION_SUBGROUP in VARCHAR2,
  X_OWNER in VARCHAR2
  )
is
  l_proc               VARCHAR2(61) := 'PER_CUSTOMIZED_RESTR_PKG.LOAD_ROW';
  l_rowid              rowid;
  l_created_by         PAY_CUSTOMIZED_RESTRICTIONS.created_by%TYPE             := 0;
  l_creation_date      PAY_CUSTOMIZED_RESTRICTIONS.creation_date%TYPE          := SYSDATE;
  l_last_update_date   PAY_CUSTOMIZED_RESTRICTIONS.last_update_date%TYPE       := SYSDATE;
  l_last_updated_by    PAY_CUSTOMIZED_RESTRICTIONS.last_updated_by%TYPE         := 0;
  l_last_update_login  PAY_CUSTOMIZED_RESTRICTIONS.last_update_login%TYPE       := 0;
  l_cust_rest_id       PAY_CUSTOMIZED_RESTRICTIONS.customized_restriction_id%TYPE ;
  l_comments           PAY_CUSTOMIZED_RESTRICTIONS.comments%TYPE ;
  l_business_group_id  PAY_CUSTOMIZED_RESTRICTIONS.business_group_id%TYPE;
  l_appl_id            PAY_CUSTOMIZED_RESTRICTIONS.application_id%TYPE;

  CURSOR C_APPL IS
        select application_id
        from fnd_application
        where application_short_name = upper(X_APPLICATION_SHORT_NAME);

  CURSOR C1  IS
 	select customized_restriction_id , comments , business_group_id
 	from    PAY_CUSTOMIZED_RESTRICTIONS pcr
        where   pcr.application_id = l_appl_id
        and     pcr.form_name = X_FORM_NAME
        and     pcr.name = X_NAME
	and     nvl(pcr.legislation_code,'XXX') = nvl(X_LEGISLATION_CODE,'XXX') ;

  begin

  -- Translate developer keys to internal parameters

  if X_OWNER = 'SEED' then
    l_created_by := 1;
    l_last_updated_by := 1;
  end if;

  -- Update or insert row as appropriate
  begin

  OPEN C_APPL;
  FETCH C_APPL INTO l_appl_id;
  CLOSE C_APPL;


  OPEN C1;
  FETCH C1 INTO l_cust_rest_id , l_comments , l_business_group_id;

  if (C1%NOTFOUND) then
    close C1;
    raise no_data_found;
  end if;

  close C1;

  UPDATE_ROW
      (	X_CUSTOMIZED_RESTRICTION_ID => l_cust_rest_id
      ,X_APPLICATION_ID   => l_appl_id
      ,X_FORM_NAME                => X_FORM_NAME
      ,X_NAME                     => X_NAME
      ,X_BUSINESS_GROUP_ID        => l_business_group_id
      ,X_LEGISLATION_CODE         => X_LEGISLATION_CODE
      ,X_ENABLED_FLAG             => X_ENABLED_FLAG
      ,X_QUERY_FORM_TITLE         => X_QUERY_FORM_TITLE
      ,X_STANDARD_FORM_TITLE      => X_STANDARD_FORM_TITLE
      ,X_COMMENTS                 => l_comments
      ,X_LEGISLATION_SUBGROUP     => X_LEGISLATION_SUBGROUP
      ,X_LAST_UPDATE_DATE         => l_last_update_date
      ,X_LAST_UPDATED_BY          => l_last_updated_by
      ,X_LAST_UPDATE_LOGIN        => l_last_update_login
      );


  exception
    when no_data_found then
      INSERT_ROW
        (X_ROWID                    => l_rowid
	,X_CUSTOMIZED_RESTRICTION_ID => l_cust_rest_id
        ,X_APPLICATION_ID   => l_appl_id
        ,X_FORM_NAME                => X_FORM_NAME
        ,X_NAME                     => X_NAME
        ,X_BUSINESS_GROUP_ID        => null
        ,X_LEGISLATION_CODE         => X_LEGISLATION_CODE
        ,X_ENABLED_FLAG             => X_ENABLED_FLAG
        ,X_QUERY_FORM_TITLE         => X_QUERY_FORM_TITLE
        ,X_STANDARD_FORM_TITLE      => X_STANDARD_FORM_TITLE
	,X_COMMENTS                 => l_comments
        ,X_LEGISLATION_SUBGROUP     => X_LEGISLATION_SUBGROUP
        ,X_CREATED_BY               => l_created_by
        ,X_CREATION_DATE            => l_creation_date
        ,X_LAST_UPDATE_DATE         => l_last_update_date
        ,X_LAST_UPDATED_BY          => l_last_updated_by
        ,X_LAST_UPDATE_LOGIN        => l_last_update_login
        );
  end;
--
end LOAD_ROW;

procedure TRANSLATE_ROW
  (X_APPLICATION_SHORT_NAME in varchar2,
  X_FORM_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_BUSINESS_GROUP_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_QUERY_FORM_TITLE in VARCHAR2,
  X_STANDARD_FORM_TITLE in VARCHAR2,
  X_OWNER in varchar2
  )
is
   l_appl_id            PAY_CUSTOMIZED_RESTRICTIONS.application_id%TYPE;
   l_cust_rest_id       PAY_CUSTOMIZED_RESTRICTIONS.customized_restriction_id%TYPE ;

   CURSOR C_APPL IS
        select application_id
        from fnd_application
        where application_short_name = upper(X_APPLICATION_SHORT_NAME);

   CURSOR C1  IS
 	select customized_restriction_id
 	from    PAY_CUSTOMIZED_RESTRICTIONS pcr
        where   pcr.application_id = l_appl_id
        and     pcr.form_name = X_FORM_NAME
        and     pcr.name = X_NAME
	and     nvl(pcr.legislation_code,'XXX') = nvl(X_LEGISLATION_CODE,'XXX') ;

begin

  OPEN C_APPL;
  FETCH C_APPL INTO l_appl_id;
  CLOSE C_APPL;

  OPEN C1;
  FETCH C1 INTO l_cust_rest_id ;
    IF C1%FOUND THEN

	UPDATE PAY_CUSTOM_RESTRICTIONS_TL
        SET
            QUERY_FORM_TITLE = X_QUERY_FORM_TITLE ,
	    STANDARD_FORM_TITLE = X_STANDARD_FORM_TITLE ,
	    LAST_UPDATE_DATE = sysdate ,
	    LAST_UPDATED_BY = decode(X_OWNER , 'SEED', 1, 0),
	    LAST_UPDATE_LOGIN = 0,
	    SOURCE_LANG = userenv('LANG')
	    where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
	       and  CUSTOMIZED_RESTRICTION_ID = l_cust_rest_id;

    END IF;

    CLOSE C1;

end TRANSLATE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from PAY_CUSTOM_RESTRICTIONS_TL T
  where not exists
    (select NULL
    from PAY_CUSTOMIZED_RESTRICTIONS B
    where B.CUSTOMIZED_RESTRICTION_ID = T.CUSTOMIZED_RESTRICTION_ID
    );

  update PAY_CUSTOM_RESTRICTIONS_TL T set (
      QUERY_FORM_TITLE,
      STANDARD_FORM_TITLE
    ) = (select
      B.QUERY_FORM_TITLE,
      B.STANDARD_FORM_TITLE
    from PAY_CUSTOM_RESTRICTIONS_TL B
    where B.CUSTOMIZED_RESTRICTION_ID = T.CUSTOMIZED_RESTRICTION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CUSTOMIZED_RESTRICTION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CUSTOMIZED_RESTRICTION_ID,
      SUBT.LANGUAGE
    from PAY_CUSTOM_RESTRICTIONS_TL SUBB, PAY_CUSTOM_RESTRICTIONS_TL SUBT
    where SUBB.CUSTOMIZED_RESTRICTION_ID = SUBT.CUSTOMIZED_RESTRICTION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.QUERY_FORM_TITLE <> SUBT.QUERY_FORM_TITLE
      or SUBB.STANDARD_FORM_TITLE <> SUBT.STANDARD_FORM_TITLE
  ));

  insert into PAY_CUSTOM_RESTRICTIONS_TL (
    CUSTOMIZED_RESTRICTION_ID,
    QUERY_FORM_TITLE,
    STANDARD_FORM_TITLE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CUSTOMIZED_RESTRICTION_ID,
    B.QUERY_FORM_TITLE,
    B.STANDARD_FORM_TITLE,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PAY_CUSTOM_RESTRICTIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PAY_CUSTOM_RESTRICTIONS_TL T
    where T.CUSTOMIZED_RESTRICTION_ID = B.CUSTOMIZED_RESTRICTION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

END PER_CUSTOMIZED_RESTR_PKG;

/
