--------------------------------------------------------
--  DDL for Package Body AMS_METRICS_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_METRICS_ALL_PKG" as
/* $Header: amslmtcb.pls 120.1 2005/08/16 13:25:02 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_METRICS_ALL_PKG
-- Purpose
--
-- History
--   03/06/2003  dmvincen  BUG2819067: Do not update if customized.
--   08/20/2003  dmvincen  Added Display Type.
--
-- NOTE
--
-- End of Comments
-- ===============================================================
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

procedure INSERT_ROW  (
  X_ROWID in VARCHAR2,
  X_METRIC_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ARC_METRIC_USED_FOR_OBJECT in VARCHAR2,
  X_METRIC_CALCULATION_TYPE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_METRIC_CATEGORY in NUMBER,
  X_ACCRUAL_TYPE in VARCHAR2,
  X_VALUE_TYPE in VARCHAR2,
  X_SENSITIVE_DATA_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_METRIC_SUB_CATEGORY in NUMBER,
  X_FUNCTION_NAME in VARCHAR2,
  X_FUNCTION_TYPE in VARCHAR2,
  X_METRIC_PARENT_ID in NUMBER,
  X_SUMMARY_METRIC_ID in NUMBER,
  X_COMPUTE_USING_FUNCTION in VARCHAR2,
  X_DEFAULT_UOM_CODE in VARCHAR2,
  X_UOM_TYPE in VARCHAR2,
  X_FORMULA in VARCHAR2,
  X_DISPLAY_TYPE in VARCHAR2,
  X_METRICS_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_FORMULA_DISPLAY in VARCHAR2,
  X_TARGET_TYPE in VARCHAR2,
  X_DENORM_CODE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AMS_METRICS_ALL_B
    where METRIC_ID = X_METRIC_ID
    ;
  l_rowid VARCHAR2(1000);
begin
  insert into AMS_METRICS_ALL_B (
    METRIC_ID,
    OBJECT_VERSION_NUMBER,
    ARC_METRIC_USED_FOR_OBJECT,
    METRIC_CALCULATION_TYPE,
    APPLICATION_ID,
    METRIC_CATEGORY,
    ACCRUAL_TYPE,
    VALUE_TYPE,
    SENSITIVE_DATA_FLAG,
    ENABLED_FLAG,
    METRIC_SUB_CATEGORY,
    FUNCTION_NAME,
	 FUNCTION_TYPE,
    METRIC_PARENT_ID,
    SUMMARY_METRIC_ID,
    COMPUTE_USING_FUNCTION,
    DEFAULT_UOM_CODE,
    UOM_TYPE,
    FORMULA,
	 DISPLAY_TYPE,
   TARGET_TYPE,
   DENORM_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_METRIC_ID,
    X_OBJECT_VERSION_NUMBER,
    X_ARC_METRIC_USED_FOR_OBJECT,
    X_METRIC_CALCULATION_TYPE,
    X_APPLICATION_ID,
    X_METRIC_CATEGORY,
    X_ACCRUAL_TYPE,
    X_VALUE_TYPE,
    X_SENSITIVE_DATA_FLAG,
    X_ENABLED_FLAG,
    X_METRIC_SUB_CATEGORY,
    X_FUNCTION_NAME,
	 X_FUNCTION_TYPE,
    X_METRIC_PARENT_ID,
    X_SUMMARY_METRIC_ID,
    X_COMPUTE_USING_FUNCTION,
    X_DEFAULT_UOM_CODE,
    X_UOM_TYPE,
    X_FORMULA,
	 X_DISPLAY_TYPE,
   X_TARGET_TYPE,
   X_DENORM_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AMS_METRICS_ALL_TL (
    METRICS_NAME,
    DESCRIPTION,
	 FORMULA_DISPLAY,
    METRIC_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_METRICS_NAME,
    X_DESCRIPTION,
    X_FORMULA_DISPLAY,
    X_METRIC_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMS_METRICS_ALL_TL T
    where T.METRIC_ID = X_METRIC_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into l_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_METRIC_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ARC_METRIC_USED_FOR_OBJECT in VARCHAR2,
  X_METRIC_CALCULATION_TYPE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_METRIC_CATEGORY in NUMBER,
  X_ACCRUAL_TYPE in VARCHAR2,
  X_VALUE_TYPE in VARCHAR2,
  X_SENSITIVE_DATA_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_METRIC_SUB_CATEGORY in NUMBER,
  X_FUNCTION_NAME in VARCHAR2,
  X_FUNCTION_TYPE in VARCHAR2,
  X_METRIC_PARENT_ID in NUMBER,
  X_SUMMARY_METRIC_ID in NUMBER,
  X_COMPUTE_USING_FUNCTION in VARCHAR2,
  X_DEFAULT_UOM_CODE in VARCHAR2,
  X_UOM_TYPE in VARCHAR2,
  X_FORMULA in VARCHAR2,
  X_DISPLAY_TYPE in VARCHAR2,
  X_METRICS_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_FORMULA_DISPLAY in VARCHAR2,
  X_TARGET_TYPE in VARCHAR2,
  X_DENORM_CODE in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      ARC_METRIC_USED_FOR_OBJECT,
      METRIC_CALCULATION_TYPE,
      APPLICATION_ID,
      METRIC_CATEGORY,
      ACCRUAL_TYPE,
      VALUE_TYPE,
      SENSITIVE_DATA_FLAG,
      ENABLED_FLAG,
      METRIC_SUB_CATEGORY,
      FUNCTION_NAME,
		FUNCTION_TYPE,
      METRIC_PARENT_ID,
      SUMMARY_METRIC_ID,
      COMPUTE_USING_FUNCTION,
      DEFAULT_UOM_CODE,
      UOM_TYPE,
      FORMULA,
		DISPLAY_TYPE,
    TARGET_TYPE,
    DENORM_CODE
    from AMS_METRICS_ALL_B
    where METRIC_ID = X_METRIC_ID
    for update of METRIC_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      METRICS_NAME,
      DESCRIPTION,
		FORMULA_DISPLAY,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMS_METRICS_ALL_TL
    where METRIC_ID = X_METRIC_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of METRIC_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND
					(X_OBJECT_VERSION_NUMBER is null)))
      AND (recinfo.ARC_METRIC_USED_FOR_OBJECT = X_ARC_METRIC_USED_FOR_OBJECT)
      AND (recinfo.METRIC_CALCULATION_TYPE = X_METRIC_CALCULATION_TYPE)
      AND (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND (recinfo.METRIC_CATEGORY = X_METRIC_CATEGORY)
      AND (recinfo.ACCRUAL_TYPE = X_ACCRUAL_TYPE)
      AND (recinfo.VALUE_TYPE = X_VALUE_TYPE)
      AND (recinfo.SENSITIVE_DATA_FLAG = X_SENSITIVE_DATA_FLAG)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND ((recinfo.METRIC_SUB_CATEGORY = X_METRIC_SUB_CATEGORY)
           OR ((recinfo.METRIC_SUB_CATEGORY is null) AND
					(X_METRIC_SUB_CATEGORY is null)))
      AND ((recinfo.FUNCTION_NAME = X_FUNCTION_NAME)
           OR ((recinfo.FUNCTION_NAME is null) AND
					(X_FUNCTION_NAME is null)))
      AND ((recinfo.FUNCTION_TYPE = X_FUNCTION_TYPE)
           OR ((recinfo.FUNCTION_TYPE is null) AND
					(X_FUNCTION_TYPE is null)))
      AND ((recinfo.METRIC_PARENT_ID = X_METRIC_PARENT_ID)
           OR ((recinfo.METRIC_PARENT_ID is null) AND
					(X_METRIC_PARENT_ID is null)))
      AND ((recinfo.SUMMARY_METRIC_ID = X_SUMMARY_METRIC_ID)
           OR ((recinfo.SUMMARY_METRIC_ID is null) AND
					(X_SUMMARY_METRIC_ID is null)))
      AND ((recinfo.COMPUTE_USING_FUNCTION = X_COMPUTE_USING_FUNCTION)
           OR ((recinfo.COMPUTE_USING_FUNCTION is null) AND
					(X_COMPUTE_USING_FUNCTION is null)))
      AND ((recinfo.DEFAULT_UOM_CODE = X_DEFAULT_UOM_CODE)
           OR ((recinfo.DEFAULT_UOM_CODE is null) AND
					(X_DEFAULT_UOM_CODE is null)))
      AND ((recinfo.UOM_TYPE = X_UOM_TYPE)
           OR ((recinfo.UOM_TYPE is null) AND (X_UOM_TYPE is null)))
      AND ((recinfo.FORMULA = X_FORMULA)
           OR ((recinfo.FORMULA is null) AND (X_FORMULA is null)))
      AND ((recinfo.DISPLAY_TYPE = X_DISPLAY_TYPE)
           OR ((recinfo.DISPLAY_TYPE is null) AND (X_DISPLAY_TYPE is null)))
      AND ((recinfo.TARGET_TYPE = X_TARGET_TYPE)
           OR ((recinfo.TARGET_TYPE is null) AND (X_TARGET_TYPE is null)))
      AND ((recinfo.DENORM_CODE = X_DENORM_CODE)
           OR ((recinfo.DENORM_CODE is null) AND (X_DENORM_CODE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.METRICS_NAME = X_METRICS_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
          AND ((tlinfo.FORMULA_DISPLAY = X_FORMULA_DISPLAY)
               OR ((tlinfo.FORMULA_DISPLAY is null)
					    AND (X_FORMULA_DISPLAY is null)))
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
  X_METRIC_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ARC_METRIC_USED_FOR_OBJECT in VARCHAR2,
  X_METRIC_CALCULATION_TYPE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_METRIC_CATEGORY in NUMBER,
  X_ACCRUAL_TYPE in VARCHAR2,
  X_VALUE_TYPE in VARCHAR2,
  X_SENSITIVE_DATA_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_METRIC_SUB_CATEGORY in NUMBER,
  X_FUNCTION_NAME in VARCHAR2,
  X_FUNCTION_TYPE in VARCHAR2,
  X_METRIC_PARENT_ID in NUMBER,
  X_SUMMARY_METRIC_ID in NUMBER,
  X_COMPUTE_USING_FUNCTION in VARCHAR2,
  X_DEFAULT_UOM_CODE in VARCHAR2,
  X_UOM_TYPE in VARCHAR2,
  X_FORMULA in VARCHAR2,
  X_DISPLAY_TYPE in VARCHAR2,
  X_METRICS_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_FORMULA_DISPLAY in VARCHAR2,
  X_TARGET_TYPE in VARCHAR2,
  X_DENORM_CODE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_METRICS_ALL_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    ARC_METRIC_USED_FOR_OBJECT = X_ARC_METRIC_USED_FOR_OBJECT,
    METRIC_CALCULATION_TYPE = X_METRIC_CALCULATION_TYPE,
    APPLICATION_ID = X_APPLICATION_ID,
    METRIC_CATEGORY = X_METRIC_CATEGORY,
    ACCRUAL_TYPE = X_ACCRUAL_TYPE,
    VALUE_TYPE = X_VALUE_TYPE,
    SENSITIVE_DATA_FLAG = X_SENSITIVE_DATA_FLAG,
    ENABLED_FLAG = X_ENABLED_FLAG,
    METRIC_SUB_CATEGORY = X_METRIC_SUB_CATEGORY,
    FUNCTION_NAME = X_FUNCTION_NAME,
    FUNCTION_TYPE = X_FUNCTION_TYPE,
    METRIC_PARENT_ID = X_METRIC_PARENT_ID,
    SUMMARY_METRIC_ID = X_SUMMARY_METRIC_ID,
    COMPUTE_USING_FUNCTION = X_COMPUTE_USING_FUNCTION,
    DEFAULT_UOM_CODE = X_DEFAULT_UOM_CODE,
    UOM_TYPE = X_UOM_TYPE,
    FORMULA = X_FORMULA,
    DISPLAY_TYPE = X_DISPLAY_TYPE,
    TARGET_TYPE = X_TARGET_TYPE,
    DENORM_CODE = X_DENORM_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where METRIC_ID = X_METRIC_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMS_METRICS_ALL_TL set
    METRICS_NAME = X_METRICS_NAME,
    DESCRIPTION = X_DESCRIPTION,
	  FORMULA_DISPLAY = X_FORMULA_DISPLAY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where METRIC_ID = X_METRIC_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_METRIC_ID in NUMBER
) is
begin
  delete from AMS_METRICS_ALL_TL
  where METRIC_ID = X_METRIC_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMS_METRICS_ALL_B
  where METRIC_ID = X_METRIC_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_METRICS_ALL_TL T
  where not exists
    (select NULL
    from AMS_METRICS_ALL_B B
    where B.METRIC_ID = T.METRIC_ID
    );

  update AMS_METRICS_ALL_TL T set (
      METRICS_NAME,
      DESCRIPTION,
		FORMULA_DISPLAY
    ) = (select
      B.METRICS_NAME,
      B.DESCRIPTION,
		B.FORMULA_DISPLAY
    from AMS_METRICS_ALL_TL B
    where B.METRIC_ID = T.METRIC_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.METRIC_ID,
      T.LANGUAGE
  ) in (select
      SUBT.METRIC_ID,
      SUBT.LANGUAGE
    from AMS_METRICS_ALL_TL SUBB, AMS_METRICS_ALL_TL SUBT
    where SUBB.METRIC_ID = SUBT.METRIC_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.METRICS_NAME <> SUBT.METRICS_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
      or SUBB.FORMULA_DISPLAY <> SUBT.FORMULA_DISPLAY
      or (SUBB.FORMULA_DISPLAY is null and SUBT.FORMULA_DISPLAY is not null)
      or (SUBB.FORMULA_DISPLAY is not null and SUBT.FORMULA_DISPLAY is null)
  ));

  insert into AMS_METRICS_ALL_TL (
    METRICS_NAME,
    DESCRIPTION,
	 FORMULA_DISPLAY,
    METRIC_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.METRICS_NAME,
    B.DESCRIPTION,
	 B.FORMULA_DISPLAY,
    B.METRIC_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_METRICS_ALL_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_METRICS_ALL_TL T
    where T.METRIC_ID = B.METRIC_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW(
       x_metric_id    in NUMBER
     , x_metrics_name  in VARCHAR2
     , x_description    in VARCHAR2
     , x_owner   in VARCHAR2
 ) is
 begin
    update AMS_METRICS_ALL_TL set
       metrics_name = nvl(x_metrics_name, metrics_name),
       description = nvl(x_description, description),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(x_owner, 'SEED', 1, 0),
       last_update_login = 0
    where  metric_id = x_metric_id
    and      userenv('LANG') in (language, source_lang);
end TRANSLATE_ROW;

 procedure  LOAD_ROW(
  X_METRIC_ID in NUMBER,
  X_ARC_METRIC_USED_FOR_OBJECT in VARCHAR2,
  X_METRIC_CALCULATION_TYPE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_METRIC_CATEGORY in NUMBER,
  X_ACCRUAL_TYPE in VARCHAR2,
  X_VALUE_TYPE in VARCHAR2,
  X_SENSITIVE_DATA_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_METRIC_SUB_CATEGORY in NUMBER,
  X_FUNCTION_NAME in VARCHAR2,
  X_FUNCTION_TYPE in VARCHAR2,
  X_METRIC_PARENT_ID in NUMBER,
  X_SUMMARY_METRIC_ID in NUMBER,
  X_COMPUTE_USING_FUNCTION in VARCHAR2,
  X_DEFAULT_UOM_CODE in VARCHAR2,
  X_UOM_TYPE in VARCHAR2,
  X_FORMULA in VARCHAR2,
  X_DISPLAY_TYPE in VARCHAR2,
  X_METRICS_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_FORMULA_DISPLAY in VARCHAR2,
  X_TARGET_TYPE in VARCHAR2,
  X_DENORM_CODE in VARCHAR2,
  X_Owner       IN     VARCHAR2,
  X_CUSTOM_MODE IN VARCHAR2
) is

l_user_id   number := 0;
l_obj_verno  number;
l_dummy_char  varchar2(1);
l_row_id    varchar2(100);
l_metric_id   number;
l_db_luby_id NUMBER;

cursor  c_db_data_details is
  select last_updated_by, object_version_number
  from    AMS_METRICS_ALL_B
  where  metric_id =  X_METRIC_ID;

cursor c_chk_mtc_exists is
  select 'x'
  from   AMS_METRICS_ALL_B
  where  metric_id = X_METRIC_ID;

cursor c_get_mtcid is
   select AMS_METRICS_ALL_B_S.nextval
   from dual;

BEGIN

  -- set the last_updated_by to be used while updating the data in customer data.
  if X_OWNER = 'SEED' then
    l_user_id := 1;
  elsif X_OWNER = 'ORACLE' THEN
    l_user_id := 2;
  elsif X_OWNER = 'SYSADMIN' THEN
    l_user_id := 0;
  end if ;

 open c_chk_mtc_exists;
 fetch c_chk_mtc_exists into l_dummy_char;
 if c_chk_mtc_exists%notfound
 then
    close c_chk_mtc_exists;

    if x_metric_id is null then
        open c_get_mtcid;
        fetch c_get_mtcid into l_metric_id;
        close c_get_mtcid;
    else
        l_metric_id := x_metric_id ;
    end if ;

    l_obj_verno := 1;

 AMS_METRICS_ALL_PKG.INSERT_ROW (
  X_ROWID                       => l_row_id ,
  X_METRIC_ID                   => l_metric_id,
  X_OBJECT_VERSION_NUMBER       => l_obj_verno,
  X_ARC_METRIC_USED_FOR_OBJECT  => X_ARC_METRIC_USED_FOR_OBJECT,
  X_METRIC_CALCULATION_TYPE     => X_METRIC_CALCULATION_TYPE,
  X_APPLICATION_ID              => X_APPLICATION_ID,
  X_METRIC_CATEGORY             => X_METRIC_CATEGORY,
  X_ACCRUAL_TYPE                => X_ACCRUAL_TYPE,
  X_VALUE_TYPE                  => X_VALUE_TYPE,
  X_SENSITIVE_DATA_FLAG         => X_SENSITIVE_DATA_FLAG,
  X_ENABLED_FLAG                => X_ENABLED_FLAG,
  X_METRIC_SUB_CATEGORY         => X_METRIC_SUB_CATEGORY,
  X_FUNCTION_NAME               => X_FUNCTION_NAME,
  X_FUNCTION_TYPE               => X_FUNCTION_TYPE,
  X_METRIC_PARENT_ID            => X_METRIC_PARENT_ID,
  X_SUMMARY_METRIC_ID           => X_SUMMARY_METRIC_ID,
  X_COMPUTE_USING_FUNCTION      => X_COMPUTE_USING_FUNCTION,
  X_DEFAULT_UOM_CODE            => X_DEFAULT_UOM_CODE,
  X_UOM_TYPE                    => X_UOM_TYPE,
  X_FORMULA                     => X_FORMULA,
  X_DISPLAY_TYPE                => X_DISPLAY_TYPE,
  X_METRICS_NAME                => X_METRICS_NAME,
  X_DESCRIPTION                 => X_DESCRIPTION,
  X_FORMULA_DISPLAY             => X_FORMULA_DISPLAY,
  X_TARGET_TYPE                 => X_TARGET_TYPE,
  X_DENORM_CODE                 => X_DENORM_CODE,
  X_CREATION_DATE               => SYSDATE,
  X_CREATED_BY                  => l_user_id,
  X_LAST_UPDATE_DATE            => SYSDATE,
  X_LAST_UPDATED_BY             => l_user_id,
  X_LAST_UPDATE_LOGIN           => 0
) ;

else
   close c_chk_mtc_exists;
   open c_db_data_details;
   fetch c_db_data_details into l_db_luby_id, l_obj_verno;
   close c_db_data_details;
    if ( l_db_luby_id IN (1, 2, 0)
      OR NVL(x_custom_mode,'PRESERVE') = 'FORCE') THEN
    AMS_METRICS_ALL_PKG.UPDATE_ROW(
    X_METRIC_ID				      =>  X_METRIC_ID,
    X_OBJECT_VERSION_NUMBER       => l_obj_verno + 1,
    X_ARC_METRIC_USED_FOR_OBJECT  => X_ARC_METRIC_USED_FOR_OBJECT,
    X_METRIC_CALCULATION_TYPE     => X_METRIC_CALCULATION_TYPE,
    X_APPLICATION_ID              => X_APPLICATION_ID,
    X_METRIC_CATEGORY             => X_METRIC_CATEGORY,
    X_ACCRUAL_TYPE                => X_ACCRUAL_TYPE,
    X_VALUE_TYPE                  => X_VALUE_TYPE,
    X_SENSITIVE_DATA_FLAG         => X_SENSITIVE_DATA_FLAG,
    X_ENABLED_FLAG                => X_ENABLED_FLAG,
    X_METRIC_SUB_CATEGORY         => X_METRIC_SUB_CATEGORY,
    X_FUNCTION_NAME               => X_FUNCTION_NAME,
    X_FUNCTION_TYPE               => X_FUNCTION_TYPE,
    X_METRIC_PARENT_ID            => X_METRIC_PARENT_ID,
    X_SUMMARY_METRIC_ID           => X_SUMMARY_METRIC_ID,
    X_COMPUTE_USING_FUNCTION      => X_COMPUTE_USING_FUNCTION,
    X_DEFAULT_UOM_CODE            => X_DEFAULT_UOM_CODE,
    X_UOM_TYPE                    => X_UOM_TYPE,
    X_FORMULA                     => X_FORMULA,
    X_DISPLAY_TYPE                => X_DISPLAY_TYPE,
    X_METRICS_NAME                => X_METRICS_NAME,
    X_DESCRIPTION                 => X_DESCRIPTION,
    X_FORMULA_DISPLAY             => X_FORMULA_DISPLAY,
    X_TARGET_TYPE                 => X_TARGET_TYPE,
    X_DENORM_CODE                 => X_DENORM_CODE,
    X_LAST_UPDATE_DATE            => SYSDATE,
    X_LAST_UPDATED_BY             => l_user_id,
    X_LAST_UPDATE_LOGIN           => 0
  );
  end if;
end if;
END LOAD_ROW;


end AMS_METRICS_ALL_PKG;

/
