--------------------------------------------------------
--  DDL for Package Body AMS_METRIC_FORMULAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_METRIC_FORMULAS_PKG" as
/* $Header: amslmtfb.pls 115.2 2003/09/30 22:47:57 dmvincen noship $ */
-- ===============================================================
-- Package name
--          AMS_METRIC_FORMULAS_PKG
-- Purpose
--
-- History
--   08/20/2003  dmvincen  Created.
--
-- NOTE
--
-- ===============================================================
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

procedure INSERT_ROW (
   X_ROWID in VARCHAR2,
   X_METRIC_FORMULA_ID IN NUMBER,
   X_METRIC_ID IN NUMBER,
   X_SOURCE_TYPE in VARCHAR2,
   X_SOURCE_ID IN NUMBER,
   X_SOURCE_SUB_ID IN NUMBER,
   X_USE_SUB_ID_FLAG IN VARCHAR2,
   X_SOURCE_VALUE IN NUMBER,
   X_TOKEN IN VARCHAR2,
   X_SEQUENCE IN NUMBER,
   X_NOTATION_TYPE in VARCHAR2,
   X_OBJECT_VERSION_NUMBER in NUMBER,
   X_CREATION_DATE in DATE,
   X_CREATED_BY in NUMBER,
   X_LAST_UPDATE_DATE in DATE,
   X_LAST_UPDATED_BY in NUMBER,
   X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AMS_METRIC_FORMULAS
    where METRIC_FORMULA_ID = X_METRIC_FORMULA_ID;
  l_rowid VARCHAR2(1000);
begin
  insert into AMS_METRIC_FORMULAS (
   METRIC_FORMULA_ID,
   METRIC_ID,
   SOURCE_TYPE,
   SOURCE_ID,
   SOURCE_SUB_ID,
   USE_SUB_ID_FLAG,
   SOURCE_VALUE,
   TOKEN,
   SEQUENCE,
   NOTATION_TYPE,
   OBJECT_VERSION_NUMBER,
   CREATION_DATE,
   CREATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_LOGIN
  ) values (
   X_METRIC_FORMULA_ID,
   X_METRIC_ID,
   X_SOURCE_TYPE,
   X_SOURCE_ID,
   X_SOURCE_SUB_ID,
   X_USE_SUB_ID_FLAG,
   X_SOURCE_VALUE,
   X_TOKEN,
   X_SEQUENCE,
   X_NOTATION_TYPE,
   X_OBJECT_VERSION_NUMBER,
   X_CREATION_DATE,
   X_CREATED_BY,
   X_LAST_UPDATE_DATE,
   X_LAST_UPDATED_BY,
   X_LAST_UPDATE_LOGIN
  );

  open c;
  fetch c into l_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
   X_METRIC_FORMULA_ID IN NUMBER,
   X_METRIC_ID IN NUMBER,
   X_SOURCE_TYPE in VARCHAR2,
   X_SOURCE_ID IN NUMBER,
   X_SOURCE_SUB_ID IN NUMBER,
   X_USE_SUB_ID_FLAG IN VARCHAR2,
   X_SOURCE_VALUE IN NUMBER,
   X_TOKEN in VARCHAR2,
   X_SEQUENCE IN NUMBER,
   X_NOTATION_TYPE in VARCHAR2,
   X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      METRIC_ID,
      SOURCE_TYPE,
      SOURCE_ID,
      SOURCE_SUB_ID,
      USE_SUB_ID_FLAG,
      SOURCE_VALUE,
      TOKEN,
      SEQUENCE,
      NOTATION_TYPE
    from AMS_METRIC_FORMULAS
    where METRIC_FORMULA_ID = X_METRIC_FORMULA_ID
    for update of METRIC_FORMULA_ID nowait;
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
  if (((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND (recinfo.METRIC_ID = X_METRIC_ID)
      AND (recinfo.SOURCE_TYPE = X_SOURCE_TYPE)
      AND (recinfo.SEQUENCE = X_SEQUENCE)
      AND (recinfo.NOTATION_TYPE = X_NOTATION_TYPE)
      AND (recinfo.USE_SUB_ID_FLAG = X_USE_SUB_ID_FLAG)
      AND ((recinfo.SOURCE_ID = X_SOURCE_ID)
           OR ((recinfo.SOURCE_ID is null) AND (X_SOURCE_ID is null)))
      AND ((recinfo.SOURCE_SUB_ID = X_SOURCE_SUB_ID)
           OR ((recinfo.SOURCE_SUB_ID is null) AND (X_SOURCE_SUB_ID is null)))
      AND ((recinfo.SOURCE_VALUE = X_SOURCE_VALUE)
           OR ((recinfo.SOURCE_VALUE is null) AND (X_SOURCE_VALUE is null)))
      AND ((recinfo.TOKEN = X_TOKEN)
           OR ((recinfo.TOKEN is null) AND (X_TOKEN is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

end LOCK_ROW;

procedure UPDATE_ROW (
   X_METRIC_FORMULA_ID IN NUMBER,
   X_METRIC_ID IN NUMBER,
   X_SOURCE_TYPE in VARCHAR2,
   X_SOURCE_ID IN NUMBER,
   X_SOURCE_SUB_ID IN NUMBER,
   X_USE_SUB_ID_FLAG IN VARCHAR2,
   X_SOURCE_VALUE IN NUMBER,
   X_TOKEN in VARCHAR2,
   X_SEQUENCE IN NUMBER,
   X_NOTATION_TYPE in VARCHAR2,
   X_OBJECT_VERSION_NUMBER in NUMBER,
   X_LAST_UPDATE_DATE in DATE,
   X_LAST_UPDATED_BY in NUMBER,
   X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_METRIC_FORMULAS set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    METRIC_ID = X_METRIC_ID,
    SOURCE_TYPE = X_SOURCE_TYPE,
    SOURCE_ID = X_SOURCE_ID,
    SOURCE_SUB_ID = X_SOURCE_SUB_ID,
    USE_SUB_ID_FLAG = X_USE_SUB_ID_FLAG,
    SOURCE_VALUE = X_SOURCE_VALUE,
    TOKEN = X_TOKEN,
    SEQUENCE = X_SEQUENCE,
    NOTATION_TYPE = X_NOTATION_TYPE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where METRIC_FORMULA_ID = X_METRIC_FORMULA_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_METRIC_FORMULA_ID in NUMBER
) is
begin
  delete from AMS_METRIC_FORMULAS
  where METRIC_FORMULA_ID = X_METRIC_FORMULA_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure  LOAD_ROW(
   X_METRIC_FORMULA_ID IN NUMBER,
   X_METRIC_ID IN NUMBER,
   X_SOURCE_TYPE in VARCHAR2,
   X_SOURCE_ID IN NUMBER,
   X_SOURCE_SUB_ID IN NUMBER,
   X_USE_SUB_ID_FLAG IN VARCHAR2,
   X_SOURCE_VALUE IN NUMBER,
   X_TOKEN in VARCHAR2,
   X_SEQUENCE IN NUMBER,
   X_NOTATION_TYPE in VARCHAR2,
   X_Owner   IN VARCHAR2,
   X_CUSTOM_MODE IN VARCHAR2
) is

l_user_id   number := 0;
l_obj_verno  number;
l_row_id    varchar2(100);
l_metric_formula_id   number;
l_db_luby_id NUMBER;

cursor  c_db_data_details is
  select last_updated_by, object_version_number
  from    AMS_METRIC_FORMULAS
  where  metric_formula_id =  X_METRIC_FORMULA_ID;

cursor c_get_mtfid is
   select AMS_METRIC_FORMULAS_S.nextval
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

  open c_db_data_details;
  fetch c_db_data_details into l_db_luby_id, l_obj_verno;
  if c_db_data_details%notfound
  then
    close c_db_data_details;

    if X_METRIC_FORMULA_ID is null then
        open c_get_mtfid;
        fetch c_get_mtfid into l_metric_formula_id;
        close c_get_mtfid;
    else
        l_metric_formula_id := X_METRIC_FORMULA_ID;
    end if ;

    l_obj_verno := 1;

    INSERT_ROW (
       X_ROWID                       => l_row_id ,
       X_METRIC_FORMULA_ID           => l_metric_formula_id,
       X_METRIC_ID                   => X_METRIC_ID,
       X_SOURCE_TYPE                 => X_SOURCE_TYPE,
       X_SOURCE_ID                   => X_SOURCE_ID,
       X_SOURCE_SUB_ID               => X_SOURCE_SUB_ID,
       X_USE_SUB_ID_FLAG             => X_USE_SUB_ID_FLAG,
       X_SOURCE_VALUE                => X_SOURCE_VALUE,
       X_TOKEN                       => X_TOKEN,
       X_SEQUENCE                    => X_SEQUENCE,
       X_NOTATION_TYPE               => X_NOTATION_TYPE,
       X_OBJECT_VERSION_NUMBER       => l_obj_verno,
       X_CREATION_DATE               => SYSDATE,
       X_CREATED_BY                  => l_user_id,
       X_LAST_UPDATE_DATE            => SYSDATE,
       X_LAST_UPDATED_BY             => l_user_id,
       X_LAST_UPDATE_LOGIN           => 0
    );

  else
    close c_db_data_details;
    if ( l_db_luby_id IN (1, 2, 0)
      OR NVL(x_custom_mode,'PRESERVE') = 'FORCE') THEN
       UPDATE_ROW(
          X_METRIC_FORMULA_ID           => X_METRIC_FORMULA_ID,
          X_METRIC_ID                   => X_METRIC_ID,
          X_SOURCE_TYPE                 => X_SOURCE_TYPE,
          X_SOURCE_ID                   => X_SOURCE_ID,
          X_SOURCE_SUB_ID               => X_SOURCE_SUB_ID,
          X_USE_SUB_ID_FLAG             => X_USE_SUB_ID_FLAG,
          X_SOURCE_VALUE                => X_SOURCE_VALUE,
          X_TOKEN                       => X_TOKEN,
          X_SEQUENCE                    => X_SEQUENCE,
          X_NOTATION_TYPE               => X_NOTATION_TYPE,
          X_OBJECT_VERSION_NUMBER       => l_obj_verno + 1,
          X_LAST_UPDATE_DATE            => SYSDATE,
          X_LAST_UPDATED_BY             => l_user_id,
          X_LAST_UPDATE_LOGIN           => 0
       );
    end if;
  end if;
END LOAD_ROW;

end AMS_METRIC_FORMULAS_PKG;

/
