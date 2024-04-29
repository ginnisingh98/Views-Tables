--------------------------------------------------------
--  DDL for Package Body JTF_UM_TEMPLATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_UM_TEMPLATES_PKG" as
/* $Header: JTFUMTLB.pls 120.5 2006/03/13 09:11:05 vimohan ship $ */
procedure INSERT_ROW (
  X_TEMPLATE_ID out NOCOPY NUMBER,
  X_TEMPLATE_KEY in VARCHAR2,
  X_TEMPLATE_TYPE_CODE in VARCHAR2,
  X_PAGE_NAME in VARCHAR2,
  X_TEMPLATE_HANDLER in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_EFFECTIVE_START_DATE in DATE,
  X_APPLICATION_ID in NUMBER,
  X_EFFECTIVE_END_DATE in DATE,
  X_TEMPLATE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_UM_TEMPLATES_B
    where TEMPLATE_ID = X_TEMPLATE_ID
    ;
begin
  insert into JTF_UM_TEMPLATES_B (
    TEMPLATE_ID,
    TEMPLATE_KEY,
    TEMPLATE_TYPE_CODE,
    PAGE_NAME,
    TEMPLATE_HANDLER,
    ENABLED_FLAG,
    EFFECTIVE_START_DATE,
    APPLICATION_ID,
    EFFECTIVE_END_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    JTF_UM_TEMPLATES_B_S.NEXTVAL,
    X_TEMPLATE_KEY,
    X_TEMPLATE_TYPE_CODE,
    X_PAGE_NAME,
    X_TEMPLATE_HANDLER,
    X_ENABLED_FLAG,
    X_EFFECTIVE_START_DATE,
    X_APPLICATION_ID,
    X_EFFECTIVE_END_DATE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  )RETURNING TEMPLATE_ID INTO X_TEMPLATE_ID;

  insert into JTF_UM_TEMPLATES_TL (
    TEMPLATE_ID,
    TEMPLATE_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TEMPLATE_ID,
    X_TEMPLATE_NAME,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_UM_TEMPLATES_TL T
    where T.TEMPLATE_ID = X_TEMPLATE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_TEMPLATE_ID in NUMBER,
  X_TEMPLATE_KEY in VARCHAR2,
  X_TEMPLATE_TYPE_CODE in VARCHAR2,
  X_PAGE_NAME in VARCHAR2,
  X_TEMPLATE_HANDLER in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_EFFECTIVE_START_DATE in DATE,
  X_APPLICATION_ID in NUMBER,
  X_EFFECTIVE_END_DATE in DATE,
  X_TEMPLATE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      TEMPLATE_KEY,
      TEMPLATE_TYPE_CODE,
      PAGE_NAME,
      TEMPLATE_HANDLER,
      ENABLED_FLAG,
      EFFECTIVE_START_DATE,
      APPLICATION_ID,
      EFFECTIVE_END_DATE
    from JTF_UM_TEMPLATES_B
    where TEMPLATE_ID = X_TEMPLATE_ID
    for update of TEMPLATE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      TEMPLATE_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_UM_TEMPLATES_TL
    where TEMPLATE_ID = X_TEMPLATE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TEMPLATE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.TEMPLATE_KEY = X_TEMPLATE_KEY)
      AND (recinfo.TEMPLATE_TYPE_CODE = X_TEMPLATE_TYPE_CODE)
      AND (recinfo.PAGE_NAME = X_PAGE_NAME)
      AND (recinfo.TEMPLATE_HANDLER = X_TEMPLATE_HANDLER)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.EFFECTIVE_START_DATE = X_EFFECTIVE_START_DATE)
      AND (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND ((recinfo.EFFECTIVE_END_DATE = X_EFFECTIVE_END_DATE)
           OR ((recinfo.EFFECTIVE_END_DATE is null) AND (X_EFFECTIVE_END_DATE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.TEMPLATE_NAME = X_TEMPLATE_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
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
  X_TEMPLATE_ID in NUMBER,
  X_TEMPLATE_KEY in VARCHAR2,
  X_TEMPLATE_TYPE_CODE in VARCHAR2,
  X_PAGE_NAME in VARCHAR2,
  X_TEMPLATE_HANDLER in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_EFFECTIVE_END_DATE in DATE,
  X_TEMPLATE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_UM_TEMPLATES_B set
    TEMPLATE_KEY = X_TEMPLATE_KEY,
    TEMPLATE_TYPE_CODE = X_TEMPLATE_TYPE_CODE,
    PAGE_NAME = X_PAGE_NAME,
    TEMPLATE_HANDLER = X_TEMPLATE_HANDLER,
    ENABLED_FLAG = X_ENABLED_FLAG,
    APPLICATION_ID = X_APPLICATION_ID,
    EFFECTIVE_END_DATE = X_EFFECTIVE_END_DATE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where TEMPLATE_ID = X_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_UM_TEMPLATES_TL set
    TEMPLATE_NAME = X_TEMPLATE_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TEMPLATE_ID = X_TEMPLATE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TEMPLATE_ID in NUMBER
) is
begin
  delete from JTF_UM_TEMPLATES_TL
  where TEMPLATE_ID = X_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_UM_TEMPLATES_B
  where TEMPLATE_ID = X_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_UM_TEMPLATES_TL T
  where not exists
    (select NULL
    from JTF_UM_TEMPLATES_B B
    where B.TEMPLATE_ID = T.TEMPLATE_ID
    );

  update JTF_UM_TEMPLATES_TL T set (
      TEMPLATE_NAME,
      DESCRIPTION
    ) = (select
      B.TEMPLATE_NAME,
      B.DESCRIPTION
    from JTF_UM_TEMPLATES_TL B
    where B.TEMPLATE_ID = T.TEMPLATE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TEMPLATE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TEMPLATE_ID,
      SUBT.LANGUAGE
    from JTF_UM_TEMPLATES_TL SUBB, JTF_UM_TEMPLATES_TL SUBT
    where SUBB.TEMPLATE_ID = SUBT.TEMPLATE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TEMPLATE_NAME <> SUBT.TEMPLATE_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into JTF_UM_TEMPLATES_TL (
    TEMPLATE_ID,
    TEMPLATE_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.TEMPLATE_ID,
    B.TEMPLATE_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_UM_TEMPLATES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_UM_TEMPLATES_TL T
    where T.TEMPLATE_ID = B.TEMPLATE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;



--For this procedure, if TEMPLATE_ID passed as input is NULL, then create a new record
-- otherwise, modify the existing record.

procedure LOAD_ROW (
    X_TEMPLATE_ID            IN NUMBER,
    X_EFFECTIVE_START_DATE   IN DATE,
    X_EFFECTIVE_END_DATE     IN DATE,
    X_OWNER                  IN VARCHAR2,
    X_APPLICATION_ID         IN NUMBER,
    X_ENABLED_FLAG           IN VARCHAR2,
    X_TEMPLATE_TYPE_CODE     IN VARCHAR2,
    X_PAGE_NAME              IN VARCHAR2,
    X_TEMPLATE_HANDLER       IN VARCHAR2,
    X_TEMPLATE_KEY           IN VARCHAR2,
    X_TEMPLATE_NAME          IN VARCHAR2,
    X_DESCRIPTION            IN VARCHAR2,
    x_last_update_date       in varchar2 default NULL,
    X_CUSTOM_MODE            in varchar2 default NULL

) is
        l_user_id NUMBER := fnd_load_util.owner_id(x_owner);
        l_template_id NUMBER := 0;
	  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
begin
    --     if (x_owner = '0') then
    --             l_user_id := 1;
    --     end if;

	   -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(x_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

        -- If TEMPLATE_ID passed in NULL, insert the record
        if ( X_TEMPLATE_ID is NULL ) THEN
           INSERT_ROW(
		X_TEMPLATE_ID 		=> l_template_id,
                X_EFFECTIVE_START_DATE 	=> X_EFFECTIVE_START_DATE,
		X_EFFECTIVE_END_DATE 	=> X_EFFECTIVE_END_DATE,
		X_APPLICATION_ID 	=> X_APPLICATION_ID,
		X_ENABLED_FLAG 		=> X_ENABLED_FLAG,
		X_TEMPLATE_TYPE_CODE    => X_TEMPLATE_TYPE_CODE,
		X_PAGE_NAME		=> X_PAGE_NAME,
		X_TEMPLATE_HANDLER      => X_TEMPLATE_HANDLER,
		X_TEMPLATE_KEY		=> X_TEMPLATE_KEY,
		X_TEMPLATE_NAME		=> X_TEMPLATE_NAME,
		X_DESCRIPTION		=> X_DESCRIPTION,
                X_CREATION_DATE         => f_ludate,
                X_CREATED_BY            => f_luby,
                X_LAST_UPDATE_DATE      => f_ludate,
                X_LAST_UPDATED_BY       => f_luby,
                X_LAST_UPDATE_LOGIN     => l_user_id
             );
          else
             -- This select stmnt also checks if
             -- there is a row for this app_id and this app_short_name
             -- Exception is thrown otherwise.
             select LAST_UPDATED_BY, LAST_UPDATE_DATE
               into db_luby, db_ludate
	      FROM JTF_UM_TEMPLATES_B
	      where TEMPLATE_ID = X_TEMPLATE_ID;

              if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                            db_ludate, X_CUSTOM_MODE)) then

                     UPDATE_ROW(
		          X_TEMPLATE_ID 		=> X_TEMPLATE_ID,
		          X_EFFECTIVE_END_DATE 	=> X_EFFECTIVE_END_DATE,
		          X_APPLICATION_ID 	=> X_APPLICATION_ID,
		          X_ENABLED_FLAG 		=> X_ENABLED_FLAG,
		          X_TEMPLATE_TYPE_CODE    => X_TEMPLATE_TYPE_CODE,
		          X_PAGE_NAME		=> X_PAGE_NAME,
		          X_TEMPLATE_HANDLER      => X_TEMPLATE_HANDLER,
		          X_TEMPLATE_KEY		=> X_TEMPLATE_KEY,
		          X_TEMPLATE_NAME		=> X_TEMPLATE_NAME,
		          X_DESCRIPTION		=> X_DESCRIPTION,
                          X_LAST_UPDATE_DATE      => f_ludate,
                          X_LAST_UPDATED_BY       => f_luby,
                          X_LAST_UPDATE_LOGIN     => l_user_id
                       );

	       end if;

          end if;

end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_TEMPLATE_ID in NUMBER, -- key field
  X_TEMPLATE_NAME in VARCHAR2, -- translated name
  X_DESCRIPTION in VARCHAR2, -- translated description
  X_OWNER in VARCHAR2, -- owner field
  x_last_update_date       in varchar2 default NULL,
  X_CUSTOM_MODE            in varchar2 default NULL


) is

f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

begin

  -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(x_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

    -- This select stmnt also checks if
    -- there is a row for this app_id and this app_short_name
    -- Exception is thrown otherwise.
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
      into db_luby, db_ludate
      FROM JTF_UM_TEMPLATES_TL
     where TEMPLATE_ID = X_TEMPLATE_ID
     and LANGUAGE = userenv('LANG');

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then


  update JTF_UM_TEMPLATES_TL set
	TEMPLATE_NAME 	  = X_TEMPLATE_NAME,
	DESCRIPTION       = X_DESCRIPTION,
	LAST_UPDATE_DATE  = f_ludate,
	LAST_UPDATED_BY   = f_luby,
	LAST_UPDATE_LOGIN = 0,
	SOURCE_LANG       = userenv('LANG')
  where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
  	and TEMPLATE_ID = X_TEMPLATE_ID;


end if;


end TRANSLATE_ROW;

end JTF_UM_TEMPLATES_PKG;

/
