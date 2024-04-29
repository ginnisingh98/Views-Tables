--------------------------------------------------------
--  DDL for Package Body PER_ASS_STATUS_TYPE_AMENDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ASS_STATUS_TYPE_AMENDS_PKG" as
/* $Header: peastamd.pkb 120.2 2006/06/27 10:41:15 bshukla noship $ */
procedure KEY_TO_IDS (
  X_USER_STATUS in VARCHAR2,
  X_BUSINESS_GROUP_NAME in VARCHAR2,
  X_ASSIGNMENT_STATUS_TYPE_ID out nocopy VARCHAR2,
  X_BUSINESS_GROUP_ID out nocopy NUMBER
) is
  cursor CSR_BUSINESS_GROUP (
    L_NAME in VARCHAR2
  ) is
    select BUSINESS_GROUP_ID
    from PER_BUSINESS_GROUPS
    WHERE NAME = L_NAME;

  cursor CSR_ASS_STATUS_TYPE_AMEND (
    L_STATUS in VARCHAR2,
    L_BUSINESS_GROUP_ID in NUMBER
  ) is

    select ASS_STATUS_TYPE_AMEND_ID
    from PER_ASS_STATUS_TYPE_AMENDS
    where USER_STATUS = L_STATUS
    and BUSINESS_GROUP_ID = L_BUSINESS_GROUP_ID;

    L_BUSINESS_GROUP_ID NUMBER;
begin
  open CSR_BUSINESS_GROUP (
    X_BUSINESS_GROUP_NAME
  );
  fetch CSR_BUSINESS_GROUP into L_BUSINESS_GROUP_ID;
  close CSR_BUSINESS_GROUP;

  X_BUSINESS_GROUP_ID := L_BUSINESS_GROUP_ID;

  open CSR_ASS_STATUS_TYPE_AMEND (
    X_USER_STATUS,
    L_BUSINESS_GROUP_ID
  );
  fetch CSR_ASS_STATUS_TYPE_AMEND into X_ASSIGNMENT_STATUS_TYPE_ID;
  close CSR_ASS_STATUS_TYPE_AMEND;
end KEY_TO_IDS;

procedure OWNER_TO_WHO (
  X_OWNER	in VARCHAR2,
  X_CREATION_DATE out nocopy DATE,
  X_CREATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_DATE out nocopy DATE,
  X_LAST_UPDATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_LOGIN out nocopy NUMBER
) is
begin
  if X_OWNER = 'SEED' then
    X_CREATED_BY := 1;
    X_LAST_UPDATED_BY := 1;
  else
    X_CREATED_BY := 0;
    X_LAST_UPDATED_BY := 0;
  end if;
  X_CREATION_DATE := sysdate;
  X_LAST_UPDATE_DATE := sysdate;
  X_LAST_UPDATE_LOGIN := 0;
end OWNER_TO_WHO;

procedure INSERT_ROW (
  X_ASS_STATUS_TYPE_AMEND_ID in NUMBER,
  X_USER_STATUS		in VARCHAR2,
  X_LAST_UPDATE_DATE	in DATE,
  X_LAST_UPDATED_BY	in NUMBER,
  X_LAST_UPDATE_LOGIN	in NUMBER,
  X_CREATION_DATE	in DATE,
  X_CREATED_BY		in NUMBER
) is
begin
  insert into PER_ASS_STATUS_TYPE_AMENDS_TL (
    ASS_STATUS_TYPE_AMEND_ID,
    USER_STATUS,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
	X_ASS_STATUS_TYPE_AMEND_ID,
	X_USER_STATUS,
	X_LAST_UPDATE_DATE,
	X_LAST_UPDATED_BY,
	X_LAST_UPDATE_LOGIN,
	X_CREATED_BY,
	X_CREATION_DATE,
	L.LANGUAGE_CODE,
	USERENV('LANG')
    from FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I','B')
    and   not exists (
		select null
		from PER_ASS_STATUS_TYPE_AMENDS_TL
		where ASS_STATUS_TYPE_AMEND_ID = X_ASS_STATUS_TYPE_AMEND_ID
		and LANGUAGE = L.LANGUAGE_CODE );
end INSERT_ROW;

procedure UPDATE_ROW (
  X_ASS_STATUS_TYPE_AMEND_ID in NUMBER,
  X_USER_STATUS		in VARCHAR2,
  X_LAST_UPDATE_DATE	in DATE,
  X_LAST_UPDATED_BY	in NUMBER,
  X_LAST_UPDATE_LOGIN	in NUMBER,
  X_CREATION_DATE	in DATE,
  X_CREATED_BY		in NUMBER
) is
begin
  update PER_ASS_STATUS_TYPE_AMENDS_TL
  set    USER_STATUS = X_USER_STATUS,
	 LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	 LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	 LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	 SOURCE_LANG = userenv('LANG')
  where	 ASS_STATUS_TYPE_AMEND_ID = X_ASS_STATUS_TYPE_AMEND_ID
  and    userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ASS_STATUS_TYPE_AMEND_ID in NUMBER
) is
begin
  delete from PER_ASS_STATUS_TYPE_AMENDS_TL
  where ASS_STATUS_TYPE_AMEND_ID = X_ASS_STATUS_TYPE_AMEND_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from PER_ASS_STATUS_TYPE_AMENDS_TL T
  where not exists
    (select NULL
    from PER_ASS_STATUS_TYPE_AMENDS B
    where B.ASS_STATUS_TYPE_AMEND_ID = T.ASS_STATUS_TYPE_AMEND_ID
    );

  update PER_ASS_STATUS_TYPE_AMENDS_TL T set (
      USER_STATUS
    ) = (select B.USER_STATUS
	 from PER_ASS_STATUS_TYPE_AMENDS_TL B
	 where B.ASS_STATUS_TYPE_AMEND_ID = T.ASS_STATUS_TYPE_AMEND_ID
	 and B.LANGUAGE = T.SOURCE_LANG)
	 where (
  	   T.ASS_STATUS_TYPE_AMEND_ID,
	   T.LANGUAGE
	   ) in (select
		   SUBT.ASS_STATUS_TYPE_AMEND_ID,
		   SUBT.LANGUAGE
		   from PER_ASS_STATUS_TYPE_AMENDS_TL SUBB,
		         PER_ASS_STATUS_TYPE_AMENDS_TL SUBT
		   where SUBB.ASS_STATUS_TYPE_AMEND_ID =
			SUBT.ASS_STATUS_TYPE_AMEND_ID
		   and SUBB.LANGUAGE = SUBT.SOURCE_LANG
		   and (SUBB.USER_STATUS <> SUBT.USER_STATUS));

  insert into PER_ASS_STATUS_TYPE_AMENDS_TL (
    ASS_STATUS_TYPE_AMEND_ID,
    USER_STATUS,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ASS_STATUS_TYPE_AMEND_ID,
    B.USER_STATUS,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PER_ASS_STATUS_TYPE_AMENDS_TL B,
       FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and   B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PER_ASS_STATUS_TYPE_AMENDS_TL T
    where T.ASS_STATUS_TYPE_AMEND_ID = B.ASS_STATUS_TYPE_AMEND_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW(
  X_STATUS		in VARCHAR2,
  X_BUSINESS_GROUP_NAME in VARCHAR2,
  X_OWNER          	in VARCHAR2,
  X_USER_STATUS         in VARCHAR2,
  X_LAST_UPDATE_DATE IN VARCHAR2 default sysdate,
  X_CUSTOM_MODE IN VARCHAR2 default null
) IS
  X_ASS_STATUS_TYPE_AMEND_ID NUMBER;
  X_BUSINESS_GROUP_ID NUMBER;
  X_CREATION_DATE DATE :=sysdate;
  X_CREATED_BY NUMBER;
--  X_LAST_UPDATE_DATE DATE;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

begin
  if X_OWNER = 'SEED' then
    X_CREATED_BY := 1;
  else
    X_CREATED_BY := 0;
  end if;

  KEY_TO_IDS (
    X_STATUS,
    X_BUSINESS_GROUP_NAME,
    X_ASS_STATUS_TYPE_AMEND_ID,
    X_BUSINESS_GROUP_ID
  );
 -- Commenting this as X_LAST_UPDATE_DATE is now an Input parameter.
 /* OWNER_TO_WHO (
    X_OWNER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  ); */

 begin
  f_luby := fnd_load_util.owner_id(X_OWNER);
   -- Translate char last_update_date to date
   f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);
     select LAST_UPDATED_BY, LAST_UPDATE_DATE
     into db_luby, db_ludate
     from PER_ASS_STATUS_TYPE_AMENDS
     where ASS_STATUS_TYPE_AMEND_ID = TO_NUMBER(X_ASS_STATUS_TYPE_AMEND_ID);

   -- Test for customization and version
   if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                 db_ludate, X_CUSTOM_MODE)) then

   UPDATE_ROW (
     X_ASS_STATUS_TYPE_AMEND_ID,
     X_USER_STATUS,
     f_ludate,
     f_luby,
     0,
     X_CREATION_DATE,
     X_CREATED_BY
   );
  end if;
 exception
  when no_data_found then

    INSERT_ROW (
      X_ASS_STATUS_TYPE_AMEND_ID,
      X_USER_STATUS,
      f_ludate,
      f_luby,
      0,
      X_CREATION_DATE,
      X_CREATED_BY
      );
 end;
end LOAD_ROW;

procedure TRANSLATE_ROW(
  X_STATUS		in VARCHAR2,
  X_BUSINESS_GROUP_NAME in VARCHAR2,
  X_OWNER               in VARCHAR2,
  X_USER_STATUS         in VARCHAR2,
  X_LAST_UPDATE_DATE IN VARCHAR2 default sysdate,
  X_CUSTOM_MODE IN VARCHAR2 default null
) IS
  X_ASS_STATUS_TYPE_AMEND_ID NUMBER;
  X_BUSINESS_GROUP_ID NUMBER;
  X_CREATION_DATE DATE;
  X_CREATED_BY NUMBER;
--  X_LAST_UPDATE_DATE DATE;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

begin
  KEY_TO_IDS (
    X_STATUS,
    X_BUSINESS_GROUP_NAME,
    X_ASS_STATUS_TYPE_AMEND_ID,
    X_BUSINESS_GROUP_ID
  );
-- Commenting this as X_LAST_UPDATE_DATE is now an Input parameter.
 /* OWNER_TO_WHO (
    X_OWNER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
    ); */
  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

      select LAST_UPDATED_BY, LAST_UPDATE_DATE
      into db_luby, db_ludate
      from PER_ASS_STATUS_TYPE_AMENDS_TL
      where ASS_STATUS_TYPE_AMEND_ID = TO_NUMBER(X_ASS_STATUS_TYPE_AMEND_ID)
      and LANGUAGE=userenv('LANG');

if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate,X_CUSTOM_MODE)) then
  update PER_ASS_STATUS_TYPE_AMENDS_TL set
  USER_STATUS = X_USER_STATUS,
  LAST_UPDATE_DATE = db_ludate,
  LAST_UPDATED_BY = db_luby,
  LAST_UPDATE_LOGIN = 0,
  SOURCE_LANG = userenv('LANG')
 where userenv('LANG') in (LANGUAGE,SOURCE_LANG)
 and ASS_STATUS_TYPE_AMEND_ID = TO_NUMBER(x_ASS_STATUS_TYPE_AMEND_ID);

 end if;
end TRANSLATE_ROW;

end PER_ASS_STATUS_TYPE_AMENDS_PKG;

/
