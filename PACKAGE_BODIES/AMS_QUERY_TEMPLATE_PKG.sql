--------------------------------------------------------
--  DDL for Package Body AMS_QUERY_TEMPLATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_QUERY_TEMPLATE_PKG" as
/* $Header: amstqtmb.pls 120.0 2005/05/31 16:46:59 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TEMPLATE_ID in NUMBER,
  X_AQE_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_TEMPLATE_TYPE in VARCHAR2,
  X_IN_USE_FLAG in VARCHAR2,
  X_LIST_SRC_TYPE in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_MV_NAME in VARCHAR2,
  X_MV_AVAILABLE_FLAG in VARCHAR2,
  X_SAMPLE_PCT in NUMBER,
  X_MASTER_DS_REC_NUMBERS in NUMBER,
  X_SAMPLE_PCT_RECORDS in NUMBER,
  X_RECALC_TABLE_STATUS in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_VIEW_APPLICATION_ID in NUMBER,
  X_SEEDED_FLAG in VARCHAR2,
  X_TEMPLATE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE
) is
  cursor C is select ROWID from AMS_QUERY_TEMPLATE_ALL
    where TEMPLATE_ID = X_TEMPLATE_ID
    ;
begin
  insert into AMS_QUERY_TEMPLATE_ALL (
    AQE_ID,
    ENABLED_FLAG,
    TEMPLATE_TYPE,
    IN_USE_FLAG,
    LIST_SRC_TYPE,
    SECURITY_GROUP_ID,
    MV_NAME,
    MV_AVAILABLE_FLAG,
    SAMPLE_PCT,
    MASTER_DS_REC_NUMBERS,
    SAMPLE_PCT_RECORDS,
    RECALC_TABLE_STATUS,
    TEMPLATE_ID,
    OBJECT_VERSION_NUMBER,
    REQUEST_ID,
    VIEW_APPLICATION_ID,
    SEEDED_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE
  ) values (
    X_AQE_ID,
    X_ENABLED_FLAG,
    X_TEMPLATE_TYPE,
    X_IN_USE_FLAG,
    X_LIST_SRC_TYPE,
    X_SECURITY_GROUP_ID,
    X_MV_NAME,
    X_MV_AVAILABLE_FLAG,
    X_SAMPLE_PCT,
    X_MASTER_DS_REC_NUMBERS,
    X_SAMPLE_PCT_RECORDS,
    X_RECALC_TABLE_STATUS,
    X_TEMPLATE_ID,
    X_OBJECT_VERSION_NUMBER,
    X_REQUEST_ID,
    X_VIEW_APPLICATION_ID,
    X_SEEDED_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE
  );

  insert into AMS_QUERY_TEMPLATE_TL (
    TEMPLATE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    TEMPLATE_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TEMPLATE_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_TEMPLATE_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMS_QUERY_TEMPLATE_TL T
    where T.TEMPLATE_ID = X_TEMPLATE_ID
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
  X_TEMPLATE_ID in NUMBER,
  X_AQE_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_TEMPLATE_TYPE in VARCHAR2,
  X_IN_USE_FLAG in VARCHAR2,
  X_LIST_SRC_TYPE in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_MV_NAME in VARCHAR2,
  X_MV_AVAILABLE_FLAG in VARCHAR2,
  X_SAMPLE_PCT in NUMBER,
  X_MASTER_DS_REC_NUMBERS in NUMBER,
  X_SAMPLE_PCT_RECORDS in NUMBER,
  X_RECALC_TABLE_STATUS in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_VIEW_APPLICATION_ID in NUMBER,
  X_SEEDED_FLAG in VARCHAR2,
  X_TEMPLATE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE

) is
  cursor c is select
      AQE_ID,
      ENABLED_FLAG,
      TEMPLATE_TYPE,
      IN_USE_FLAG,
      LIST_SRC_TYPE,
      SECURITY_GROUP_ID,
      MV_NAME,
      MV_AVAILABLE_FLAG,
      SAMPLE_PCT,
      MASTER_DS_REC_NUMBERS,
      SAMPLE_PCT_RECORDS,
      RECALC_TABLE_STATUS,
      OBJECT_VERSION_NUMBER,
      REQUEST_ID,
      VIEW_APPLICATION_ID,
      SEEDED_FLAG
    from AMS_QUERY_TEMPLATE_ALL
    where TEMPLATE_ID = X_TEMPLATE_ID
    for update of TEMPLATE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      TEMPLATE_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMS_QUERY_TEMPLATE_TL
    where TEMPLATE_ID = X_TEMPLATE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TEMPLATE_ID nowait;
begin
/*

 commented vbhandar Feb 24 to fix template package locking issue

  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.AQE_ID = X_AQE_ID)
           OR ((recinfo.AQE_ID is null) AND (X_AQE_ID is null)))
      AND ((recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
           OR ((recinfo.ENABLED_FLAG is null) AND (X_ENABLED_FLAG is null)))
      AND ((recinfo.TEMPLATE_TYPE = X_TEMPLATE_TYPE)
           OR ((recinfo.TEMPLATE_TYPE is null) AND (X_TEMPLATE_TYPE is null)))
      AND ((recinfo.IN_USE_FLAG = X_IN_USE_FLAG)
           OR ((recinfo.IN_USE_FLAG is null) AND (X_IN_USE_FLAG is null)))
      AND ((recinfo.LIST_SRC_TYPE = X_LIST_SRC_TYPE)
           OR ((recinfo.LIST_SRC_TYPE is null) AND (X_LIST_SRC_TYPE is null)))
      AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
      AND ((recinfo.MV_NAME = X_MV_NAME)
           OR ((recinfo.MV_NAME is null) AND (X_MV_NAME is null)))
      AND ((recinfo.MV_AVAILABLE_FLAG = X_MV_AVAILABLE_FLAG)
           OR ((recinfo.MV_AVAILABLE_FLAG is null) AND (X_MV_AVAILABLE_FLAG is null)))
      AND ((recinfo.SAMPLE_PCT = X_SAMPLE_PCT)
           OR ((recinfo.SAMPLE_PCT is null) AND (X_SAMPLE_PCT is null)))
      AND ((recinfo.MASTER_DS_REC_NUMBERS = X_MASTER_DS_REC_NUMBERS)
           OR ((recinfo.MASTER_DS_REC_NUMBERS is null) AND (X_MASTER_DS_REC_NUMBERS is null)))
      AND ((recinfo.SAMPLE_PCT_RECORDS = X_SAMPLE_PCT_RECORDS)
           OR ((recinfo.SAMPLE_PCT_RECORDS is null) AND (X_SAMPLE_PCT_RECORDS is null)))
      AND ((recinfo.RECALC_TABLE_STATUS = X_RECALC_TABLE_STATUS)
           OR ((recinfo.RECALC_TABLE_STATUS is null) AND (X_RECALC_TABLE_STATUS is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND ((recinfo.REQUEST_ID = X_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
      AND ((recinfo.VIEW_APPLICATION_ID = X_VIEW_APPLICATION_ID)
           OR ((recinfo.VIEW_APPLICATION_ID is null) AND (X_VIEW_APPLICATION_ID is null)))
      AND ((recinfo.SEEDED_FLAG = X_SEEDED_FLAG)
           OR ((recinfo.SEEDED_FLAG is null) AND (X_SEEDED_FLAG is null)))
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
  return;*/
  null;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_TEMPLATE_ID in NUMBER,
  X_AQE_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_TEMPLATE_TYPE in VARCHAR2,
  X_IN_USE_FLAG in VARCHAR2,
  X_LIST_SRC_TYPE in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_MV_NAME in VARCHAR2,
  X_MV_AVAILABLE_FLAG in VARCHAR2,
  X_SAMPLE_PCT in NUMBER,
  X_MASTER_DS_REC_NUMBERS in NUMBER,
  X_SAMPLE_PCT_RECORDS in NUMBER,
  X_RECALC_TABLE_STATUS in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_VIEW_APPLICATION_ID in NUMBER,
  X_SEEDED_FLAG in VARCHAR2,
  X_TEMPLATE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE
) is
begin
  update AMS_QUERY_TEMPLATE_ALL set
    AQE_ID = X_AQE_ID,
    ENABLED_FLAG = X_ENABLED_FLAG,
    TEMPLATE_TYPE = X_TEMPLATE_TYPE,
    IN_USE_FLAG = X_IN_USE_FLAG,
    LIST_SRC_TYPE = X_LIST_SRC_TYPE,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    MV_NAME = X_MV_NAME,
    MV_AVAILABLE_FLAG = X_MV_AVAILABLE_FLAG,
    SAMPLE_PCT = X_SAMPLE_PCT,
    MASTER_DS_REC_NUMBERS = X_MASTER_DS_REC_NUMBERS,
    SAMPLE_PCT_RECORDS = X_SAMPLE_PCT_RECORDS,
    RECALC_TABLE_STATUS = X_RECALC_TABLE_STATUS,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    REQUEST_ID = X_REQUEST_ID,
    VIEW_APPLICATION_ID = X_VIEW_APPLICATION_ID,
    SEEDED_FLAG = X_SEEDED_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE
  where TEMPLATE_ID = X_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMS_QUERY_TEMPLATE_TL set
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
  delete from AMS_QUERY_TEMPLATE_TL
  where TEMPLATE_ID = X_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMS_QUERY_TEMPLATE_ALL
  where TEMPLATE_ID = X_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

PROCEDURE LOAD_ROW (
  X_TEMPLATE_ID in NUMBER,
  X_VIEW_APPLICATION_ID in NUMBER,
  X_SEEDED_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_TEMPLATE_TYPE in VARCHAR2,
  X_IN_USE_FLAG in VARCHAR2,
  X_LIST_SRC_TYPE in VARCHAR2,
  X_TEMPLATE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  x_owner IN VARCHAR2,
  x_custom_mode IN VARCHAR2

)
IS
   l_user_id   number := 0;
   l_obj_verno  number;
   l_dummy_char  varchar2(1);
   l_row_id    varchar2(100);
   l_template_id   number;
   l_db_luby_id   number;

   CURSOR  c_obj_verno IS
     SELECT object_version_number, last_updated_by
     FROM   AMS_QUERY_TEMPLATE_ALL
     WHERE  template_id =  X_TEMPLATE_ID;

   CURSOR c_chk_exists is
     SELECT 'x'
     FROM   AMS_QUERY_TEMPLATE_ALL
     WHERE  TEMPLATE_ID = X_TEMPLATE_ID;

   CURSOR c_get_id is
      SELECT AMS_QUERY_TEMPLATE_ALL_s.NEXTVAL
      FROM DUAL;
BEGIN
   if X_OWNER = 'SEED' then
      l_user_id := 1;
   elsif X_OWNER = 'ORACLE' then
         l_user_id := 2;
   elsif X_OWNER = 'SYSADMIN' then
         l_user_id := 0;
   end if;

   OPEN c_chk_exists;
   FETCH c_chk_exists INTO l_dummy_char;
   IF c_chk_exists%notfound THEN
      CLOSE c_chk_exists;

      IF X_TEMPLATE_ID IS NULL THEN
         OPEN c_get_id;
         FETCH c_get_id INTO l_template_id;
         CLOSE c_get_id;
      ELSE
         l_template_id := x_template_id;
      END IF;

      l_obj_verno := 1;

      AMS_QUERY_TEMPLATE_PKG.Insert_Row (
         X_ROWID                    => l_row_id,
         X_TEMPLATE_ID              => l_template_id,
	 X_AQE_ID		    => null,
	 X_ENABLED_FLAG             => X_ENABLED_FLAG,
	 X_TEMPLATE_TYPE            => X_TEMPLATE_TYPE,
         X_IN_USE_FLAG              => X_IN_USE_FLAG,
         X_LIST_SRC_TYPE            => X_LIST_SRC_TYPE,
	 X_SECURITY_GROUP_ID        => 0,
	 X_MV_NAME		    => null,
	 X_MV_AVAILABLE_FLAG        => null,
	 X_SAMPLE_PCT               => null,
	 X_MASTER_DS_REC_NUMBERS    => null,
	 X_SAMPLE_PCT_RECORDS       => null,
         X_RECALC_TABLE_STATUS      => 'DRAFT',
         X_OBJECT_VERSION_NUMBER    => l_obj_verno,
	 X_REQUEST_ID               => 0,
	 X_VIEW_APPLICATION_ID      => X_VIEW_APPLICATION_ID,
         X_SEEDED_FLAG              => X_SEEDED_FLAG,
         X_TEMPLATE_NAME            => X_TEMPLATE_NAME,
         X_DESCRIPTION              => X_DESCRIPTION,
         X_creation_date            => SYSDATE,
         X_created_by               => l_user_id,
         X_last_update_date         => SYSDATE,
         X_last_updated_by          => l_user_id,
         X_last_update_login        => 0,
	 X_PROGRAM_ID               => 0,
         X_PROGRAM_APPLICATION_ID   => 0,
         X_PROGRAM_UPDATE_DATE      => SYSDATE
      );
   ELSE
      CLOSE c_chk_exists;
      OPEN c_obj_verno;
      FETCH c_obj_verno INTO l_obj_verno, l_db_luby_id;
      CLOSE c_obj_verno;


      if (l_db_luby_id IN (0, 1, 2) or NVL(x_custom_mode, 'PRESERVE')='FORCE')
         then
      AMS_QUERY_TEMPLATE_PKG.Update_Row (
         X_TEMPLATE_ID              => X_TEMPLATE_ID,
	 X_AQE_ID                   => null,
	 X_ENABLED_FLAG             => X_ENABLED_FLAG,
         X_TEMPLATE_TYPE            => X_TEMPLATE_TYPE,
         X_IN_USE_FLAG              => X_IN_USE_FLAG,
         X_LIST_SRC_TYPE            => X_LIST_SRC_TYPE,
 	 X_SECURITY_GROUP_ID        => 0,
	 X_MV_NAME		    => null,
	 X_MV_AVAILABLE_FLAG	    => null,
	 X_SAMPLE_PCT               => null,
	 X_MASTER_DS_REC_NUMBERS    => null,
	 X_SAMPLE_PCT_RECORDS       => null,
         X_RECALC_TABLE_STATUS      => 'DRAFT',
         X_OBJECT_VERSION_NUMBER    => l_obj_verno,
	 X_REQUEST_ID               => 0,
	 X_VIEW_APPLICATION_ID      => X_VIEW_APPLICATION_ID,
	 X_SEEDED_FLAG              => X_SEEDED_FLAG,
         X_TEMPLATE_NAME            => X_TEMPLATE_NAME,
         X_DESCRIPTION              => X_DESCRIPTION,
         X_last_update_date         => SYSDATE,
         X_last_updated_by          => l_user_id,
         X_last_update_login        => 0,
	 X_PROGRAM_ID               => 0,
         X_PROGRAM_APPLICATION_ID   => 0,
         X_PROGRAM_UPDATE_DATE      => SYSDATE

      );
     end if;
   END IF;
END LOAD_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_QUERY_TEMPLATE_TL T
  where not exists
    (select NULL
    from AMS_QUERY_TEMPLATE_ALL B
    where B.TEMPLATE_ID = T.TEMPLATE_ID
    );

  update AMS_QUERY_TEMPLATE_TL T set (
      TEMPLATE_NAME,
      DESCRIPTION
    ) = (select
      B.TEMPLATE_NAME,
      B.DESCRIPTION
    from AMS_QUERY_TEMPLATE_TL B
    where B.TEMPLATE_ID = T.TEMPLATE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TEMPLATE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TEMPLATE_ID,
      SUBT.LANGUAGE
    from AMS_QUERY_TEMPLATE_TL SUBB, AMS_QUERY_TEMPLATE_TL SUBT
    where SUBB.TEMPLATE_ID = SUBT.TEMPLATE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TEMPLATE_NAME <> SUBT.TEMPLATE_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMS_QUERY_TEMPLATE_TL (
    TEMPLATE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    TEMPLATE_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.TEMPLATE_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.TEMPLATE_NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_QUERY_TEMPLATE_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_QUERY_TEMPLATE_TL T
    where T.TEMPLATE_ID = B.TEMPLATE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW(
  X_TEMPLATE_ID in NUMBER,
  X_TEMPLATE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  x_owner   in VARCHAR2,
  x_custom_mode IN VARCHAR2

 )  is

   cursor c_last_updated_by is
        select last_updated_by
        from AMS_QUERY_TEMPLATE_TL
        where TEMPLATE_ID = x_TEMPLATE_ID
        and  USERENV('LANG') = LANGUAGE;

        l_luby number; --last updated by

begin

open c_last_updated_by;
fetch c_last_updated_by into l_luby;
close c_last_updated_by;

if (l_luby IN (0, 1, 2) or NVL(x_custom_mode, 'PRESERVE')='FORCE')
then

    update AMS_QUERY_TEMPLATE_TL set
       TEMPLATE_NAME= nvl(x_TEMPLATE_NAME, TEMPLATE_NAME),
       description = nvl(x_description, description),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(x_owner, 'SEED', 1, 'ORACLE', 2,  'SYSADMIN', 0, -1),
       last_update_login = 0
    where  TEMPLATE_ID = x_TEMPLATE_ID
    and      userenv('LANG') in (language, source_lang);

end if;
end TRANSLATE_ROW;

end AMS_QUERY_TEMPLATE_PKG;

/
