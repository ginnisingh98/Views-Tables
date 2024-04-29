--------------------------------------------------------
--  DDL for Package Body CN_CW_WORKBENCH_ITEMS_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CW_WORKBENCH_ITEMS_ALL_PKG" as
/* $Header: cntcwwib.pls 120.0 2005/09/08 04:12 raramasa noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_WORKBENCH_ITEM_CODE in VARCHAR2,
  X_WORKBENCH_ITEM_SEQUENCE in NUMBER,
  X_WORKBENCH_PARENT_ITEM_CODE in VARCHAR2,
  X_WORKBENCH_ITEM_TYPE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_WORKBENCH_ITEM_NAME in VARCHAR2,
  X_WORKBENCH_ITEM_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ORG_ID IN NUMBER
) is
  cursor C is select ROWID from CN_CW_WORKBENCH_ITEMS_ALL_B
    where WORKBENCH_ITEM_CODE = X_WORKBENCH_ITEM_CODE AND
    ORG_ID=X_ORG_ID;
begin
  insert into CN_CW_WORKBENCH_ITEMS_ALL_B (
    WORKBENCH_ITEM_CODE,
    WORKBENCH_ITEM_SEQUENCE,
    WORKBENCH_PARENT_ITEM_CODE,
    WORKBENCH_ITEM_TYPE,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    X_WORKBENCH_ITEM_CODE,
    X_WORKBENCH_ITEM_SEQUENCE,
    X_WORKBENCH_PARENT_ITEM_CODE,
    X_WORKBENCH_ITEM_TYPE,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_ORG_ID
  );

  insert into CN_CW_WORKBENCH_ITEMS_ALL_TL (
    WORKBENCH_ITEM_CODE,
    WORKBENCH_ITEM_NAME,
    WORKBENCH_ITEM_DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG,
    ORG_ID
  ) select
    X_WORKBENCH_ITEM_CODE,
    X_WORKBENCH_ITEM_NAME,
    X_WORKBENCH_ITEM_DESCRIPTION,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATED_BY,
    X_CREATION_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    X_ORG_ID
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CN_CW_WORKBENCH_ITEMS_ALL_TL T
    where T.WORKBENCH_ITEM_CODE = X_WORKBENCH_ITEM_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE AND
    ORG_ID=X_ORG_ID);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_WORKBENCH_ITEM_CODE in VARCHAR2,
  X_WORKBENCH_ITEM_SEQUENCE in NUMBER,
  X_WORKBENCH_PARENT_ITEM_CODE in VARCHAR2,
  X_WORKBENCH_ITEM_TYPE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_WORKBENCH_ITEM_NAME in VARCHAR2,
  X_WORKBENCH_ITEM_DESCRIPTION in VARCHAR2,
  X_ORG_ID IN NUMBER
) is
  cursor c is select
      WORKBENCH_ITEM_SEQUENCE,
      WORKBENCH_PARENT_ITEM_CODE,
      WORKBENCH_ITEM_TYPE,
      OBJECT_VERSION_NUMBER,
      ORG_ID
    from CN_CW_WORKBENCH_ITEMS_ALL_B
    where WORKBENCH_ITEM_CODE = X_WORKBENCH_ITEM_CODE AND
    ORG_ID=X_ORG_ID
    for update of WORKBENCH_ITEM_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      WORKBENCH_ITEM_NAME,
      WORKBENCH_ITEM_DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CN_CW_WORKBENCH_ITEMS_ALL_TL
    where WORKBENCH_ITEM_CODE = X_WORKBENCH_ITEM_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG) AND
    ORG_ID=X_ORG_ID
    for update of WORKBENCH_ITEM_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if ((recinfo.WORKBENCH_ITEM_SEQUENCE = X_WORKBENCH_ITEM_SEQUENCE)
      AND ((recinfo.WORKBENCH_PARENT_ITEM_CODE = X_WORKBENCH_PARENT_ITEM_CODE)
           OR ((recinfo.WORKBENCH_PARENT_ITEM_CODE is null) AND (X_WORKBENCH_PARENT_ITEM_CODE is null)))
      AND ((recinfo.WORKBENCH_ITEM_TYPE = X_WORKBENCH_ITEM_TYPE)
           OR ((recinfo.WORKBENCH_ITEM_TYPE is null) AND (X_WORKBENCH_ITEM_TYPE is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.WORKBENCH_ITEM_NAME = X_WORKBENCH_ITEM_NAME)
          AND (tlinfo.WORKBENCH_ITEM_DESCRIPTION = X_WORKBENCH_ITEM_DESCRIPTION)
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
  X_WORKBENCH_ITEM_CODE in VARCHAR2,
  X_WORKBENCH_ITEM_SEQUENCE in NUMBER,
  X_WORKBENCH_PARENT_ITEM_CODE in VARCHAR2,
  X_WORKBENCH_ITEM_TYPE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_WORKBENCH_ITEM_NAME in VARCHAR2,
  X_WORKBENCH_ITEM_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ORG_ID IN NUMBER
) is
begin
  update CN_CW_WORKBENCH_ITEMS_ALL_B set
    WORKBENCH_ITEM_SEQUENCE = X_WORKBENCH_ITEM_SEQUENCE,
    WORKBENCH_PARENT_ITEM_CODE = X_WORKBENCH_PARENT_ITEM_CODE,
    WORKBENCH_ITEM_TYPE = X_WORKBENCH_ITEM_TYPE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where WORKBENCH_ITEM_CODE = X_WORKBENCH_ITEM_CODE AND
  ORG_ID=X_ORG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CN_CW_WORKBENCH_ITEMS_ALL_TL set
    WORKBENCH_ITEM_NAME = X_WORKBENCH_ITEM_NAME,
    WORKBENCH_ITEM_DESCRIPTION = X_WORKBENCH_ITEM_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where WORKBENCH_ITEM_CODE = X_WORKBENCH_ITEM_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG) AND
  ORG_ID=X_ORG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_WORKBENCH_ITEM_CODE in VARCHAR2,
  X_ORG_ID IN NUMBER
) is
begin
  delete from CN_CW_WORKBENCH_ITEMS_ALL_TL
  where WORKBENCH_ITEM_CODE = X_WORKBENCH_ITEM_CODE AND
  ORG_ID=X_ORG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CN_CW_WORKBENCH_ITEMS_ALL_B
  where WORKBENCH_ITEM_CODE = X_WORKBENCH_ITEM_CODE AND
  ORG_ID=X_ORG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CN_CW_WORKBENCH_ITEMS_ALL_TL T
  where not exists
    (select NULL
    from CN_CW_WORKBENCH_ITEMS_ALL_B B
    where B.WORKBENCH_ITEM_CODE = T.WORKBENCH_ITEM_CODE AND
    B.ORG_ID=T.ORG_ID
    );

  update CN_CW_WORKBENCH_ITEMS_ALL_TL T set (
      WORKBENCH_ITEM_NAME,
      WORKBENCH_ITEM_DESCRIPTION
    ) = (select
      B.WORKBENCH_ITEM_NAME,
      B.WORKBENCH_ITEM_DESCRIPTION
    from CN_CW_WORKBENCH_ITEMS_ALL_TL B
    where B.WORKBENCH_ITEM_CODE = T.WORKBENCH_ITEM_CODE
    and B.LANGUAGE = T.SOURCE_LANG AND B.ORG_ID=T.ORG_ID)
  where (
      T.WORKBENCH_ITEM_CODE,
      T.LANGUAGE,
      T.ORG_ID
  ) in (select
      SUBT.WORKBENCH_ITEM_CODE,
      SUBT.LANGUAGE,
      SUBT.ORG_ID
    from CN_CW_WORKBENCH_ITEMS_ALL_TL SUBB, CN_CW_WORKBENCH_ITEMS_ALL_TL SUBT
    where SUBB.WORKBENCH_ITEM_CODE = SUBT.WORKBENCH_ITEM_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG AND
    SUBB.ORG_ID=SUBT.ORG_ID
    and (SUBB.WORKBENCH_ITEM_NAME <> SUBT.WORKBENCH_ITEM_NAME
      or SUBB.WORKBENCH_ITEM_DESCRIPTION <> SUBT.WORKBENCH_ITEM_DESCRIPTION
  ));

  insert into CN_CW_WORKBENCH_ITEMS_ALL_TL (
    WORKBENCH_ITEM_CODE,
    WORKBENCH_ITEM_NAME,
    WORKBENCH_ITEM_DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG,
    ORG_ID
  ) select /*+ ORDERED */
    B.WORKBENCH_ITEM_CODE,
    B.WORKBENCH_ITEM_NAME,
    B.WORKBENCH_ITEM_DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG,
    B.ORG_ID
  from CN_CW_WORKBENCH_ITEMS_ALL_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CN_CW_WORKBENCH_ITEMS_ALL_TL T
    where T.WORKBENCH_ITEM_CODE = B.WORKBENCH_ITEM_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE AND
    T.ORG_ID=B.ORG_ID);
end ADD_LANGUAGE;

PROCEDURE TRANSLATE_ROW
  ( X_WORKBENCH_ITEM_CODE IN VARCHAR2,
    X_WORKBENCH_ITEM_NAME IN VARCHAR2,
    X_WORKBENCH_ITEM_DESCRIPTION IN VARCHAR2,
    X_OWNER IN VARCHAR2
    ) IS
       user_id NUMBER;
BEGIN
    -- Validate input data
   IF (X_WORKBENCH_ITEM_CODE IS NULL)
     OR (X_WORKBENCH_ITEM_NAME IS NULL) OR (X_WORKBENCH_ITEM_DESCRIPTION IS NULL) THEN
      GOTO end_translate_row;
   END IF;

   IF (X_OWNER IS NOT NULL) AND (X_OWNER = 'SEED') THEN
      user_id := 1;
    ELSE
      user_id := 0;
   END IF;
   -- Update the translation
   UPDATE CN_CW_WORKBENCH_ITEMS_ALL_TL  SET
   WORKBENCH_ITEM_NAME = X_WORKBENCH_ITEM_NAME,
   WORKBENCH_ITEM_DESCRIPTION=X_WORKBENCH_ITEM_DESCRIPTION,
   last_update_date = sysdate,
   last_updated_by = user_id,
   last_update_login = 0,
   source_lang = userenv('LANG')
   WHERE WORKBENCH_ITEM_CODE = X_WORKBENCH_ITEM_CODE
   AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

   << end_translate_row >>
     NULL;
END TRANSLATE_ROW;

PROCEDURE LOAD_ROW
  ( X_WORKBENCH_ITEM_CODE IN VARCHAR2,
    X_WORKBENCH_ITEM_SEQUENCE IN NUMBER,
    X_WORKBENCH_PARENT_ITEM_CODE IN VARCHAR2,
    X_WORKBENCH_ITEM_TYPE IN VARCHAR2,
    X_ORG_ID IN NUMBER,
    X_WORKBENCH_ITEM_NAME IN VARCHAR2,
    X_WORKBENCH_ITEM_DESCRIPTION IN VARCHAR2,
    X_OWNER IN VARCHAR2)
 IS
 USER_ID NUMBER;
 BEGIN
   IF (X_WORKBENCH_ITEM_CODE IS NULL) OR (X_WORKBENCH_ITEM_NAME IS NULL) THEN
       GOTO end_load_row;
   END IF;
   IF (X_OWNER IS NOT NULL) AND (X_OWNER = 'SEED') THEN
      USER_ID := 1;
    ELSE
      USER_ID := 0;
   END IF;
   UPDATE CN_CW_WORKBENCH_ITEMS_ALL_B SET
    WORKBENCH_ITEM_SEQUENCE = X_WORKBENCH_ITEM_SEQUENCE,
    WORKBENCH_PARENT_ITEM_CODE = X_WORKBENCH_PARENT_ITEM_CODE,
    WORKBENCH_ITEM_TYPE = X_WORKBENCH_ITEM_TYPE,
    LAST_UPDATE_DATE = SYSDATE,
    LAST_UPDATED_BY = USER_ID,
    LAST_UPDATE_LOGIN = 0
   where WORKBENCH_ITEM_CODE = X_WORKBENCH_ITEM_CODE;

   IF (SQL%NOTFOUND)  THEN
     -- Insert new record to _B table
    insert into CN_CW_WORKBENCH_ITEMS_ALL_B (
    WORKBENCH_ITEM_CODE,
    WORKBENCH_ITEM_SEQUENCE,
    WORKBENCH_PARENT_ITEM_CODE,
    WORKBENCH_ITEM_TYPE,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID) values (
    X_WORKBENCH_ITEM_CODE,
    X_WORKBENCH_ITEM_SEQUENCE,
    X_WORKBENCH_PARENT_ITEM_CODE,
    X_WORKBENCH_ITEM_TYPE,
    1,
    SYSDATE,
    USER_ID,
    SYSDATE,
    USER_ID,
    0,
    X_ORG_ID
  );
  END IF;

  UPDATE CN_CW_WORKBENCH_ITEMS_ALL_TL set
    WORKBENCH_ITEM_NAME = X_WORKBENCH_ITEM_NAME,
    WORKBENCH_ITEM_DESCRIPTION = X_WORKBENCH_ITEM_DESCRIPTION,
    LAST_UPDATED_BY = USER_ID,
    LAST_UPDATE_LOGIN = 0,
    SOURCE_LANG = userenv('LANG')
  where WORKBENCH_ITEM_CODE = X_WORKBENCH_ITEM_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  IF (SQL%NOTFOUND) THEN
  insert into CN_CW_WORKBENCH_ITEMS_ALL_TL (
    WORKBENCH_ITEM_CODE,
    WORKBENCH_ITEM_NAME,
    WORKBENCH_ITEM_DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG,
    ORG_ID
  ) select
    X_WORKBENCH_ITEM_CODE,
    X_WORKBENCH_ITEM_NAME,
    X_WORKBENCH_ITEM_DESCRIPTION,
    SYSDATE,
    USER_ID,
    0,
    USER_ID,
    SYSDATE,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    X_ORG_ID
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CN_CW_WORKBENCH_ITEMS_ALL_TL T
    where T.WORKBENCH_ITEM_CODE = X_WORKBENCH_ITEM_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE AND
    ORG_ID=X_ORG_ID);
  END IF;

<< end_load_row >>
NULL;
END LOAD_ROW;

PROCEDURE LOAD_SEED_ROW (
x_upload_mode in varchar2,
x_owner in varchar2,
x_workbench_item_code  in varchar2,
x_workbench_item_name  in varchar2,
x_workbench_item_description  in varchar2,
x_workbench_item_sequence  in varchar2,
x_workbench_parent_item_code  in varchar2,
x_workbench_item_type  in varchar2,
x_org_id  in varchar2
)
IS
BEGIN
     if (x_upload_mode = 'NLS') then
       CN_CW_WORKBENCH_ITEMS_ALL_PKG.TRANSLATE_ROW
                            (x_workbench_item_code,
                             x_workbench_item_name,
                             x_workbench_item_description,
                        	 x_owner);
     else
       CN_CW_WORKBENCH_ITEMS_ALL_PKG.LOAD_ROW (x_workbench_item_code,
            					    to_number(x_workbench_item_sequence),
			             		    x_workbench_parent_item_code,
                                    		    x_workbench_item_type,
            					    to_number(x_org_id),
            					    x_workbench_item_name,
            					    x_workbench_item_description,
                				    x_owner);
     end if;
END LOAD_SEED_ROW;

end CN_CW_WORKBENCH_ITEMS_ALL_PKG;

/