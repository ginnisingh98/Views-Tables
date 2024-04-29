--------------------------------------------------------
--  DDL for Package Body CN_CW_SETUP_TASKS_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CW_SETUP_TASKS_ALL_PKG" as
/* $Header: cntcwstb.pls 120.0 2005/09/08 04:09 raramasa noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_SETUP_TASK_CODE in VARCHAR2,
  X_WORKBENCH_ITEM_CODE in VARCHAR2,
  X_SETUP_TASK_SEQUENCE in NUMBER,
  X_SETUP_TASK_STATUS in VARCHAR2,
  X_SETUP_TASK_TYPE in VARCHAR2,
  X_SETUP_TASK_ACTION in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SETUP_TASK_NAME in VARCHAR2,
  X_SETUP_TASK_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ORG_ID  in  NUMBER
) is
  cursor C is select ROWID from CN_CW_SETUP_TASKS_ALL_B
    where SETUP_TASK_CODE = X_SETUP_TASK_CODE
    AND ORG_ID  = X_ORG_ID
    ;
begin
  insert into CN_CW_SETUP_TASKS_ALL_B (
    SETUP_TASK_CODE,
    WORKBENCH_ITEM_CODE,
    SETUP_TASK_SEQUENCE,
    SETUP_TASK_STATUS,
    SETUP_TASK_TYPE,
    SETUP_TASK_ACTION,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    X_SETUP_TASK_CODE,
    X_WORKBENCH_ITEM_CODE,
    X_SETUP_TASK_SEQUENCE,
    X_SETUP_TASK_STATUS,
    X_SETUP_TASK_TYPE,
    X_SETUP_TASK_ACTION,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_ORG_ID
  );

  insert into CN_CW_SETUP_TASKS_ALL_TL (
    SETUP_TASK_CODE,
    SETUP_TASK_NAME,
    SETUP_TASK_DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG,
    ORG_ID
  ) select
    X_SETUP_TASK_CODE,
    X_SETUP_TASK_NAME,
    X_SETUP_TASK_DESCRIPTION,
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
    from CN_CW_SETUP_TASKS_ALL_TL T
    where T.SETUP_TASK_CODE = X_SETUP_TASK_CODE
    and T.ORG_ID    = X_ORG_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_SETUP_TASK_CODE in VARCHAR2,
  X_WORKBENCH_ITEM_CODE in VARCHAR2,
  X_SETUP_TASK_SEQUENCE in NUMBER,
  X_SETUP_TASK_STATUS in VARCHAR2,
  X_SETUP_TASK_TYPE in VARCHAR2,
  X_SETUP_TASK_ACTION in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SETUP_TASK_NAME in VARCHAR2,
  X_SETUP_TASK_DESCRIPTION in VARCHAR2,
  X_ORG_ID  in  NUMBER
) is
  cursor c is select
      WORKBENCH_ITEM_CODE,
      SETUP_TASK_SEQUENCE,
      SETUP_TASK_STATUS,
      SETUP_TASK_TYPE,
      SETUP_TASK_ACTION,
      OBJECT_VERSION_NUMBER
    from CN_CW_SETUP_TASKS_ALL_B
    where SETUP_TASK_CODE = X_SETUP_TASK_CODE
    and ORG_ID  = X_ORG_ID
    for update of SETUP_TASK_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      SETUP_TASK_NAME,
      SETUP_TASK_DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CN_CW_SETUP_TASKS_ALL_TL
    where SETUP_TASK_CODE = X_SETUP_TASK_CODE
    and ORG_ID  = X_ORG_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of SETUP_TASK_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.WORKBENCH_ITEM_CODE = X_WORKBENCH_ITEM_CODE)
      AND (recinfo.SETUP_TASK_SEQUENCE = X_SETUP_TASK_SEQUENCE)
      AND (recinfo.SETUP_TASK_STATUS = X_SETUP_TASK_STATUS)
      AND ((recinfo.SETUP_TASK_TYPE = X_SETUP_TASK_TYPE)
           OR ((recinfo.SETUP_TASK_TYPE is null) AND (X_SETUP_TASK_TYPE is null)))
      AND ((recinfo.SETUP_TASK_ACTION = X_SETUP_TASK_ACTION)
           OR ((recinfo.SETUP_TASK_ACTION is null) AND (X_SETUP_TASK_ACTION is null)))
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
      if (    (tlinfo.SETUP_TASK_NAME = X_SETUP_TASK_NAME)
          AND (tlinfo.SETUP_TASK_DESCRIPTION = X_SETUP_TASK_DESCRIPTION)
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
  X_SETUP_TASK_CODE in VARCHAR2,
  X_WORKBENCH_ITEM_CODE in VARCHAR2,
  X_SETUP_TASK_SEQUENCE in NUMBER,
  X_SETUP_TASK_STATUS in VARCHAR2,
  X_SETUP_TASK_TYPE in VARCHAR2,
  X_SETUP_TASK_ACTION in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SETUP_TASK_NAME in VARCHAR2,
  X_SETUP_TASK_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ORG_ID  in  NUMBER
) is
begin
  update CN_CW_SETUP_TASKS_ALL_B set
    WORKBENCH_ITEM_CODE = X_WORKBENCH_ITEM_CODE,
    SETUP_TASK_SEQUENCE = X_SETUP_TASK_SEQUENCE,
    SETUP_TASK_STATUS = X_SETUP_TASK_STATUS,
    SETUP_TASK_TYPE = X_SETUP_TASK_TYPE,
    SETUP_TASK_ACTION = X_SETUP_TASK_ACTION,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where SETUP_TASK_CODE = X_SETUP_TASK_CODE
  and ORG_ID  = X_ORG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CN_CW_SETUP_TASKS_ALL_TL set
    SETUP_TASK_NAME = X_SETUP_TASK_NAME,
    SETUP_TASK_DESCRIPTION = X_SETUP_TASK_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where SETUP_TASK_CODE = X_SETUP_TASK_CODE
  and ORG_ID  = X_ORG_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_SETUP_TASK_CODE in VARCHAR2,
  X_ORG_ID  in  NUMBER
) is
begin
  delete from CN_CW_SETUP_TASKS_ALL_TL
  where SETUP_TASK_CODE = X_SETUP_TASK_CODE
  and ORG_ID  = X_ORG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CN_CW_SETUP_TASKS_ALL_B
  where SETUP_TASK_CODE = X_SETUP_TASK_CODE
  and ORG_ID  = X_ORG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

PROCEDURE TRANSLATE_ROW
  ( X_SETUP_TASK_CODE IN VARCHAR2,
    X_SETUP_TASK_NAME IN VARCHAR2,
    X_SETUP_TASK_DESCRIPTION IN VARCHAR2,
    X_OWNER IN VARCHAR2
    ) IS
       user_id NUMBER;
BEGIN
    -- Validate input data
   IF (X_SETUP_TASK_CODE IS NULL)
     OR (X_SETUP_TASK_NAME IS NULL) OR (X_SETUP_TASK_DESCRIPTION IS NULL) THEN
      GOTO end_translate_row;
   END IF;

   IF (X_OWNER IS NOT NULL) AND (X_OWNER = 'SEED') THEN
      user_id := 1;
    ELSE
      user_id := 0;
   END IF;
   -- Update the translation
   UPDATE CN_CW_SETUP_TASKS_ALL_TL  SET
   SETUP_TASK_NAME = X_SETUP_TASK_NAME,
   SETUP_TASK_DESCRIPTION=X_SETUP_TASK_DESCRIPTION,
   last_update_date = sysdate,
   last_updated_by = user_id,
   last_update_login = 0,
   source_lang = userenv('LANG')
   WHERE SETUP_TASK_CODE = X_SETUP_TASK_CODE
   AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

   << end_translate_row >>
     NULL;
END TRANSLATE_ROW;

PROCEDURE LOAD_ROW
  ( X_SETUP_TASK_CODE IN VARCHAR2,
    X_WORKBENCH_ITEM_CODE IN VARCHAR2,
    X_SETUP_TASK_SEQUENCE IN NUMBER,
    X_SETUP_TASK_STATUS IN VARCHAR2,
    X_SETUP_TASK_TYPE IN VARCHAR2,
    X_SETUP_TASK_ACTION IN VARCHAR2,
    X_ORG_ID IN NUMBER,
    X_SETUP_TASK_NAME IN VARCHAR2,
    X_SETUP_TASK_DESCRIPTION IN VARCHAR2,
    X_OWNER IN VARCHAR2)
 IS
 USER_ID NUMBER;
 BEGIN
   IF (X_SETUP_TASK_CODE IS NULL) OR (X_SETUP_TASK_NAME IS NULL) THEN
       GOTO end_load_row;
   END IF;
   IF (X_OWNER IS NOT NULL) AND (X_OWNER = 'SEED') THEN
      USER_ID := 1;
    ELSE
      USER_ID := 0;
   END IF;
   UPDATE CN_CW_SETUP_TASKS_ALL_B SET
    WORKBENCH_ITEM_CODE = X_WORKBENCH_ITEM_CODE,
    SETUP_TASK_SEQUENCE = X_SETUP_TASK_SEQUENCE,
    SETUP_TASK_STATUS =  X_SETUP_TASK_STATUS,
    SETUP_TASK_TYPE = X_SETUP_TASK_TYPE,
    SETUP_TASK_ACTION = X_SETUP_TASK_ACTION,
    LAST_UPDATE_DATE = SYSDATE,
    LAST_UPDATED_BY = USER_ID,
    LAST_UPDATE_LOGIN = 0
   where SETUP_TASK_CODE = X_SETUP_TASK_CODE;

   IF (SQL%NOTFOUND)  THEN
     -- Insert new record to _B table
    INSERT INTO CN_CW_SETUP_TASKS_ALL_B (
    SETUP_TASK_CODE,
    WORKBENCH_ITEM_CODE,
    SETUP_TASK_SEQUENCE,
    SETUP_TASK_STATUS,
    SETUP_TASK_TYPE,
    SETUP_TASK_ACTION,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID) values (
    X_SETUP_TASK_CODE,
    X_WORKBENCH_ITEM_CODE,
    X_SETUP_TASK_SEQUENCE,
    X_SETUP_TASK_STATUS,
    X_SETUP_TASK_TYPE,
    X_SETUP_TASK_ACTION,
    1,
    SYSDATE,
    USER_ID,
    SYSDATE,
    USER_ID,
    0,
    X_ORG_ID
  );
  END IF;

  UPDATE CN_CW_SETUP_TASKS_ALL_TL set
    SETUP_TASK_NAME = X_SETUP_TASK_NAME,
    SETUP_TASK_DESCRIPTION = X_SETUP_TASK_DESCRIPTION,
    LAST_UPDATED_BY = USER_ID,
    LAST_UPDATE_LOGIN = 0,
    SOURCE_LANG = userenv('LANG')
  where SETUP_TASK_CODE = X_SETUP_TASK_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  IF (SQL%NOTFOUND) THEN
  insert into CN_CW_SETUP_TASKS_ALL_TL (
    SETUP_TASK_CODE,
    SETUP_TASK_NAME,
    SETUP_TASK_DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG,
    ORG_ID
  ) select
    X_SETUP_TASK_CODE,
    X_SETUP_TASK_NAME,
    X_SETUP_TASK_DESCRIPTION,
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
    from CN_CW_SETUP_TASKS_ALL_TL T
    where T.SETUP_TASK_CODE = X_SETUP_TASK_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE AND
    ORG_ID=X_ORG_ID);
  END IF;

<< end_load_row >>
NULL;
END LOAD_ROW;


procedure ADD_LANGUAGE
is
begin
  delete from CN_CW_SETUP_TASKS_ALL_TL T
  where not exists
    (select NULL
    from CN_CW_SETUP_TASKS_ALL_B B
    where B.SETUP_TASK_CODE = T.SETUP_TASK_CODE
    and B.ORG_ID  = T.ORG_ID
    );

  update CN_CW_SETUP_TASKS_ALL_TL T set (
      SETUP_TASK_NAME,
      SETUP_TASK_DESCRIPTION
    ) = (select
      B.SETUP_TASK_NAME,
      B.SETUP_TASK_DESCRIPTION
    from CN_CW_SETUP_TASKS_ALL_TL B
    where B.SETUP_TASK_CODE = T.SETUP_TASK_CODE
    and ORG_ID  = T.ORG_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SETUP_TASK_CODE,
      T.ORG_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SETUP_TASK_CODE,
      SUBT.ORG_ID,
      SUBT.LANGUAGE
    from CN_CW_SETUP_TASKS_ALL_TL SUBB, CN_CW_SETUP_TASKS_ALL_TL SUBT
    where SUBB.SETUP_TASK_CODE = SUBT.SETUP_TASK_CODE
    and SUBB.ORG_ID = SUBT.ORG_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.SETUP_TASK_NAME <> SUBT.SETUP_TASK_NAME
      or SUBB.SETUP_TASK_DESCRIPTION <> SUBT.SETUP_TASK_DESCRIPTION
  ));

  insert into CN_CW_SETUP_TASKS_ALL_TL (
    SETUP_TASK_CODE,
    SETUP_TASK_NAME,
    SETUP_TASK_DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG,
    ORG_ID
  ) select /*+ ORDERED */
    B.SETUP_TASK_CODE,
    B.SETUP_TASK_NAME,
    B.SETUP_TASK_DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG,
    B.ORG_ID
  from CN_CW_SETUP_TASKS_ALL_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CN_CW_SETUP_TASKS_ALL_TL T
    where T.SETUP_TASK_CODE = B.SETUP_TASK_CODE
      and T.ORG_ID = B.ORG_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE LOAD_SEED_ROW (
x_upload_mode in varchar2,
x_owner  in varchar2,
x_setup_task_code  in varchar2,
x_setup_task_name  in varchar2,
x_setup_task_description  in varchar2,
x_workbench_item_code  in varchar2,
x_setup_task_sequence  in varchar2,
x_setup_task_status  in varchar2,
x_setup_task_type  in varchar2,
x_setup_task_action  in varchar2,
x_org_id  in varchar2
)
IS
BEGIN
     if (x_upload_mode = 'NLS') then
       cn_cw_setup_tasks_all_pkg.translate_row
        	(x_setup_task_code,
    	     x_setup_task_name,
        	 x_setup_task_description,
        	 x_owner);
     else
       cn_cw_setup_tasks_all_pkg.load_row
				(x_setup_task_code,
				x_workbench_item_code,
				to_number(x_setup_task_sequence),
				x_setup_task_status,
				x_setup_task_type,
				x_setup_task_action,
				to_number(x_org_id),
				x_setup_task_name,
				x_setup_task_description,
				x_owner);
     end if;
END LOAD_SEED_ROW;


end CN_CW_SETUP_TASKS_ALL_PKG;

/
