--------------------------------------------------------
--  DDL for Package Body JTF_OBJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_OBJECTS_PKG" as
/* $Header: jtftkobb.pls 120.2 2005/12/19 17:19:41 rhshriva ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_SELECT_NAME in VARCHAR2,
  X_SELECT_DETAILS in VARCHAR2,
  X_FROM_TABLE in VARCHAR2,
  X_WHERE_CLAUSE in VARCHAR2,
  X_ORDER_BY_CLAUSE in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_ENTER_FROM_TASK in VARCHAR2,
  X_END_DATE_ACTIVE in DATE,
  X_OBJECT_PARAMETERS in VARCHAR2,
  X_SELECT_ID in VARCHAR2,
  X_OBJECT_CODE in VARCHAR2,
  X_OBJECT_FUNCTION in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LOV_WINDOW_TITLE in VARCHAR2,
  X_LOV_NAME_TITLE in VARCHAR2,
  X_LOV_DETAILS_TITLE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_URL in VARCHAR2 ,
  X_APPLICATION_ID in NUMBER,
  X_LAUNCH_METHOD in VARCHAR2,
  X_WEB_FUNCTION_NAME in VARCHAR2,
  X_WEB_FUNCTION_PARAMETERS in VARCHAR2,
  X_FND_OBJ_NAME in VARCHAR2,
  X_PREDICATE_ALIAS in VARCHAR2,
  X_INACTIVE_CLAUSE in VARCHAR2,
  X_OA_WEB_FUNCTION_NAME in VARCHAR2,
  X_OA_WEB_FUNCTION_PARAMETERS in VARCHAR2
  ) is
  cursor C is select ROWID from JTF_OBJECTS_B
    where OBJECT_CODE = X_OBJECT_CODE
    ;
begin
  insert into JTF_OBJECTS_B (
    SEEDED_FLAG,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    ATTRIBUTE_CATEGORY,
    SELECT_NAME,
    SELECT_DETAILS,
    FROM_TABLE,
    WHERE_CLAUSE,
    ORDER_BY_CLAUSE,
    START_DATE_ACTIVE,
    ENTER_FROM_TASK,
    END_DATE_ACTIVE,
    OBJECT_PARAMETERS,
    SELECT_ID,
    OBJECT_CODE,
    OBJECT_FUNCTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    URL,
    APPLICATION_ID,
    LAUNCH_METHOD,
    WEB_FUNCTION_NAME,
    WEB_FUNCTION_PARAMETERS,
    FND_OBJ_NAME,
    PREDICATE_ALIAS,
    INACTIVE_CLAUSE,
    OA_WEB_FUNCTION_NAME ,
    OA_WEB_FUNCTION_PARAMETERS
  ) values (
    X_SEEDED_FLAG,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_ATTRIBUTE_CATEGORY,
    X_SELECT_NAME,
    X_SELECT_DETAILS,
    X_FROM_TABLE,
    X_WHERE_CLAUSE,
    X_ORDER_BY_CLAUSE,
    X_START_DATE_ACTIVE,
    X_ENTER_FROM_TASK,
    X_END_DATE_ACTIVE,
    X_OBJECT_PARAMETERS,
    X_SELECT_ID,
    X_OBJECT_CODE,
    X_OBJECT_FUNCTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    1,
    X_URL,
    X_APPLICATION_ID,
    X_LAUNCH_METHOD,
    X_WEB_FUNCTION_NAME,
    X_WEB_FUNCTION_PARAMETERS,
    X_FND_OBJ_NAME ,
    X_PREDICATE_ALIAS,
    X_INACTIVE_CLAUSE,
    X_OA_WEB_FUNCTION_NAME,
    X_OA_WEB_FUNCTION_PARAMETERS
  );

  insert into JTF_OBJECTS_TL (
    OBJECT_CODE,
    NAME,
    DESCRIPTION,
    LOV_WINDOW_TITLE,
    LOV_NAME_TITLE,
    LOV_DETAILS_TITLE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_OBJECT_CODE,
    X_NAME,
    X_DESCRIPTION,
    X_LOV_WINDOW_TITLE,
    X_LOV_NAME_TITLE,
    X_LOV_DETAILS_TITLE,
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
    from JTF_OBJECTS_TL T
    where T.OBJECT_CODE = X_OBJECT_CODE
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
  X_object_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
        OBJECT_VERSION_NUMBER
    from JTF_objects_vl
    where object_CODE = X_object_CODE
    for update of object_CODE nowait;
  recinfo c%rowtype;


begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;

  if (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;


procedure UPDATE_ROW (
  X_SEEDED_FLAG in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_SELECT_NAME in VARCHAR2,
  X_SELECT_DETAILS in VARCHAR2,
  X_FROM_TABLE in VARCHAR2,
  X_WHERE_CLAUSE in VARCHAR2,
  X_ORDER_BY_CLAUSE in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_ENTER_FROM_TASK in VARCHAR2,
  X_END_DATE_ACTIVE in DATE,
  X_OBJECT_PARAMETERS in VARCHAR2,
  X_SELECT_ID in VARCHAR2,
  X_OBJECT_CODE in VARCHAR2,
  X_OBJECT_FUNCTION in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LOV_WINDOW_TITLE in VARCHAR2,
  X_LOV_NAME_TITLE in VARCHAR2,
  X_LOV_DETAILS_TITLE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_URL in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_LAUNCH_METHOD in VARCHAR2,
  X_WEB_FUNCTION_NAME in VARCHAR2,
  X_WEB_FUNCTION_PARAMETERS in VARCHAR2,
  X_FND_OBJ_NAME in VARCHAR2,
  X_PREDICATE_ALIAS in VARCHAR2,
  X_INACTIVE_CLAUSE in VARCHAR2,
  X_OA_WEB_FUNCTION_NAME in VARCHAR2,
  X_OA_WEB_FUNCTION_PARAMETERS in VARCHAR2
) is
begin
  update JTF_OBJECTS_B set
    SEEDED_FLAG = X_SEEDED_FLAG,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    SELECT_NAME = X_SELECT_NAME,
    SELECT_DETAILS = X_SELECT_DETAILS,
    FROM_TABLE = X_FROM_TABLE,
    WHERE_CLAUSE = X_WHERE_CLAUSE,
    ORDER_BY_CLAUSE = X_ORDER_BY_CLAUSE,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    ENTER_FROM_TASK = X_ENTER_FROM_TASK,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    OBJECT_PARAMETERS = X_OBJECT_PARAMETERS,
    SELECT_ID = X_SELECT_ID,
    OBJECT_CODE = X_OBJECT_CODE,
    OBJECT_FUNCTION = X_OBJECT_FUNCTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    URL = x_URL,
    APPLICATION_ID = X_APPLICATION_ID,
    LAUNCH_METHOD =  X_LAUNCH_METHOD,
    WEB_FUNCTION_NAME = X_WEB_FUNCTION_NAME,
    WEB_FUNCTION_PARAMETERS = X_WEB_FUNCTION_PARAMETERS,
    FND_OBJ_NAME = X_FND_OBJ_NAME,
    PREDICATE_ALIAS = X_PREDICATE_ALIAS,
    INACTIVE_CLAUSE = X_INACTIVE_CLAUSE,
    OA_WEB_FUNCTION_NAME = X_OA_WEB_FUNCTION_NAME,
    OA_WEB_FUNCTION_PARAMETERS = X_OA_WEB_FUNCTION_PARAMETERS
  where OBJECT_CODE = X_OBJECT_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_OBJECTS_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LOV_WINDOW_TITLE = X_LOV_WINDOW_TITLE,
    LOV_NAME_TITLE = X_LOV_NAME_TITLE,
    LOV_DETAILS_TITLE = X_LOV_DETAILS_TITLE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where OBJECT_CODE = X_OBJECT_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_OBJECT_CODE in  VARCHAR2
) is
begin
  delete from JTF_OBJECTS_TL
  where OBJECT_CODE = X_OBJECT_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_OBJECTS_B
  where OBJECT_CODE = X_OBJECT_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is



TYPE ob_tab IS TABLE OF jtf_objects_tl.object_code%type ;
ob_tab_var ob_tab:=ob_tab();
cursor c is
select distinct object_code from JTF_OBJECTS_TL;


begin
  /* Solving Perf. Bug 3723927*/
     /* The following delete and update statements are commented out */
     /* as a quick workaround to fix the time-consuming table handler issue */
     /*

  delete from JTF_OBJECTS_TL T
  where not exists
    (select NULL
    from JTF_OBJECTS_B B
    where B.OBJECT_CODE = T.OBJECT_CODE
    );

  update JTF_OBJECTS_TL T set (
      NAME,
      DESCRIPTION,
      LOV_WINDOW_TITLE,
      LOV_NAME_TITLE,
      LOV_DETAILS_TITLE
    ) = (select
      B.NAME,
      B.DESCRIPTION,
      B.LOV_WINDOW_TITLE,
      B.LOV_NAME_TITLE,
      B.LOV_DETAILS_TITLE
    from JTF_OBJECTS_TL B
    where B.OBJECT_CODE = T.OBJECT_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.OBJECT_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.OBJECT_CODE,
      SUBT.LANGUAGE
    from JTF_OBJECTS_TL SUBB, JTF_OBJECTS_TL SUBT
    where SUBB.OBJECT_CODE = SUBT.OBJECT_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
      or SUBB.LOV_WINDOW_TITLE <> SUBT.LOV_WINDOW_TITLE
      or (SUBB.LOV_WINDOW_TITLE is null and SUBT.LOV_WINDOW_TITLE is not null)
      or (SUBB.LOV_WINDOW_TITLE is not null and SUBT.LOV_WINDOW_TITLE is null)
      or SUBB.LOV_NAME_TITLE <> SUBT.LOV_NAME_TITLE
      or (SUBB.LOV_NAME_TITLE is null and SUBT.LOV_NAME_TITLE is not null)
      or (SUBB.LOV_NAME_TITLE is not null and SUBT.LOV_NAME_TITLE is null)
      or SUBB.LOV_DETAILS_TITLE <> SUBT.LOV_DETAILS_TITLE
      or (SUBB.LOV_DETAILS_TITLE is null and SUBT.LOV_DETAILS_TITLE is not null)
      or (SUBB.LOV_DETAILS_TITLE is not null and SUBT.LOV_DETAILS_TITLE is null)
  ));
  */



   OPEN c;

   FETCH c BULK COLLECT INTO ob_tab_var;

    if    (c%ISOPEN)  then
         Close c;
    END IF;

      If ( ob_tab_var.COUNT > 0)  then


 FORALL i in ob_tab_var.first..ob_tab_var.last

  insert into JTF_OBJECTS_TL (
    OBJECT_CODE,
    NAME,
    DESCRIPTION,
    LOV_WINDOW_TITLE,
    LOV_NAME_TITLE,
    LOV_DETAILS_TITLE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.OBJECT_CODE,
    B.NAME,
    B.DESCRIPTION,
    B.LOV_WINDOW_TITLE,
    B.LOV_NAME_TITLE,
    B.LOV_DETAILS_TITLE,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_OBJECTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and b.object_code=ob_tab_var(i)
  and not exists
    (select NULL
    from JTF_OBJECTS_TL T
    where T.OBJECT_CODE = B.OBJECT_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);

end if; -- for If ( ob_tab_var.COUNT > 0)  then

end ADD_LANGUAGE;

procedure TRANSLATE_ROW(
  X_object_code in varchar2,
  X_NAME in varchar2,
  X_DESCRIPTION in varchar2,
  X_lov_window_title in varchar2,
  X_lov_name_title in varchar2,
  X_lov_details_title in varchar2 ) is
begin
 update jtf_objects_tl set
    NAME= X_NAME,
    DESCRIPTION= X_DESCRIPTION,
    lov_window_title = X_lov_window_title ,
    lov_name_title = X_lov_name_title,
    lov_details_title = X_lov_details_title,
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATE_LOGIN = 0,
    SOURCE_LANG = userenv('LANG')
  where object_code = X_object_code
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end TRANSLATE_ROW;

end JTF_OBJECTS_PKG;

/
