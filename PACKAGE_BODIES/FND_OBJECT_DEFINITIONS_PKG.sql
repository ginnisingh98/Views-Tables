--------------------------------------------------------
--  DDL for Package Body FND_OBJECT_DEFINITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OBJECT_DEFINITIONS_PKG" as
/* $Header: AFOBDEFB.pls 120.1.12010000.3 2009/08/26 13:15:37 vsoolapa noship $*/

procedure INSERT_ROW (
  X_OBJECT_DEFINITION_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_ID in NUMBER,
  X_OBJECT_DEFINITION_TYPE in VARCHAR2,
  X_OBJECT_VERSION in VARCHAR2,
  X_OBJECT_EXTENSION_VERSION in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_DEFINITION in XMLTYPE,
  X_OBJECT_REFERENCE in XMLTYPE
) is
begin

  insert into FND_OBJECT_DEFINITIONS (
    OBJECT_DEFINITION_ID,
    APPLICATION_ID,
    OBJECT_ID,
    OBJECT_DEFINITION_TYPE,
    OBJECT_VERSION,
    OBJECT_EXTENSION_VERSION,
    STATUS,
    ENABLED_FLAG,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_DEFINITION,
    OBJECT_REFERENCE
  ) values (
    X_OBJECT_DEFINITION_ID,
    X_APPLICATION_ID,
    X_OBJECT_ID,
    X_OBJECT_DEFINITION_TYPE,
    X_OBJECT_VERSION,
    X_OBJECT_EXTENSION_VERSION,
    X_STATUS,
    X_ENABLED_FLAG,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_OBJECT_DEFINITION,
    X_OBJECT_REFERENCE
  );

end INSERT_ROW;

procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_ID in NUMBER,
  X_OBJECT_DEFINITION_TYPE in VARCHAR2,
  X_OBJECT_VERSION in VARCHAR2,
  X_OBJECT_EXTENSION_VERSION in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_DEFINITION in XMLTYPE,
  X_OBJECT_REFERENCE in XMLTYPE
) is
begin

  update FND_OBJECT_DEFINITIONS set
    APPLICATION_ID = X_APPLICATION_ID,
    OBJECT_DEFINITION_TYPE = X_OBJECT_DEFINITION_TYPE,
    OBJECT_VERSION = X_OBJECT_VERSION,
    OBJECT_EXTENSION_VERSION = X_OBJECT_EXTENSION_VERSION,
    STATUS = X_STATUS,
    ENABLED_FLAG = X_ENABLED_FLAG,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    CREATION_DATE = X_CREATION_DATE,
    CREATED_BY = X_CREATED_BY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    OBJECT_DEFINITION = X_OBJECT_DEFINITION,
    OBJECT_REFERENCE = X_OBJECT_REFERENCE
  where OBJECT_ID = X_OBJECT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

-- LOAD_ROW is called from Modeler code.
procedure LOAD_ROW (
  X_OBJ_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_DEFINITION_TYPE in VARCHAR2,
  X_OBJECT_EXTENSION_VERSION in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_DEFINITION in XMLTYPE,
  X_OBJECT_REFERENCE in XMLTYPE
) is
 app_id     number;
 obj_id     number;
 obj_def_id number;
 row_id     varchar2(64);
 f_luby     number;  -- entity owner in file
 f_ludate   date;    -- entity update date in file
 db_luby    number;  -- entity owner in db
 db_ludate  date;    -- entity update date in db
begin

  select object_id, last_updated_by, last_update_date
  into obj_id, db_luby, db_ludate
  from fnd_objects
  where obj_name = X_OBJ_NAME;

  fnd_object_definitions_pkg.UPDATE_ROW (
      X_APPLICATION_ID             => X_APPLICATION_ID,
      X_OBJECT_ID                  => obj_id,
      X_OBJECT_DEFINITION_TYPE     => X_OBJECT_DEFINITION_TYPE,
      X_OBJECT_VERSION             => '12.0',
      X_OBJECT_EXTENSION_VERSION   => X_OBJECT_EXTENSION_VERSION,
      X_STATUS                     => X_STATUS,
      X_ENABLED_FLAG               => X_ENABLED_FLAG,
      X_START_DATE_ACTIVE          => X_START_DATE_ACTIVE,
      X_END_DATE_ACTIVE            => '',
      X_CREATION_DATE              => X_CREATION_DATE,
      X_CREATED_BY                 => X_CREATED_BY,
      X_LAST_UPDATE_DATE           => X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY            => X_LAST_UPDATED_BY,
      X_LAST_UPDATE_LOGIN          => X_LAST_UPDATE_LOGIN,
      X_OBJECT_DEFINITION          => X_OBJECT_DEFINITION,
      X_OBJECT_REFERENCE           => X_OBJECT_REFERENCE);

exception
  when NO_DATA_FOUND then

  select fnd_object_definitions_s.nextval into obj_def_id from dual;

  fnd_object_definitions_pkg.INSERT_ROW (
      X_OBJECT_DEFINITION_ID       => obj_def_id,
      X_APPLICATION_ID             => X_APPLICATION_ID,
      X_OBJECT_ID                  => obj_id,
      X_OBJECT_DEFINITION_TYPE     => X_OBJECT_DEFINITION_TYPE,
      X_OBJECT_VERSION             => '12.0',
      X_OBJECT_EXTENSION_VERSION   => X_OBJECT_EXTENSION_VERSION,
      X_STATUS                     => X_STATUS,
      X_ENABLED_FLAG               => X_ENABLED_FLAG,
      X_START_DATE_ACTIVE          => X_START_DATE_ACTIVE,
      X_END_DATE_ACTIVE            => '',
      X_CREATION_DATE              => X_CREATION_DATE,
      X_CREATED_BY                 => X_CREATED_BY,
      X_LAST_UPDATE_DATE           => X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY            => X_LAST_UPDATED_BY,
      X_LAST_UPDATE_LOGIN          => X_LAST_UPDATE_LOGIN,
      X_OBJECT_DEFINITION          => X_OBJECT_DEFINITION,
      X_OBJECT_REFERENCE           => X_OBJECT_REFERENCE);

end LOAD_ROW;

-- LOAD_ROW is called from afsearch.lct
procedure LOAD_ROW (
  X_OBJ_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_DEFINITION_TYPE in VARCHAR2,
  X_OBJECT_EXTENSION_VERSION in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_DEFINITION in XMLTYPE,
  X_OBJECT_REFERENCE in XMLTYPE,
  X_CUSTOM_MODE in VARCHAR2
) is
 app_id     number;
 obj_id     number;
 obj_def_id number;
 row_id     varchar2(64);
 f_luby     number;  -- entity owner in file
 f_ludate   date;    -- entity update date in file
 db_luby    number;  -- entity owner in db
 db_ludate  date;    -- entity update date in db
begin

  select fo.object_id, fod.last_updated_by, fod.last_update_date
  into obj_id, db_luby, db_ludate
  from fnd_objects fo, fnd_object_definitions fod
  where obj_name = X_OBJ_NAME
  and fo.object_id = fod.object_id(+);

  f_luby := X_LAST_UPDATED_BY;
  f_ludate := nvl(X_LAST_UPDATE_DATE, sysdate);

  if (db_luby is null OR db_ludate is null) then

  select fnd_object_definitions_s.nextval into obj_def_id from dual;

  fnd_object_definitions_pkg.INSERT_ROW (
      X_OBJECT_DEFINITION_ID       => obj_def_id,
      X_APPLICATION_ID             => X_APPLICATION_ID,
      X_OBJECT_ID                  => obj_id,
      X_OBJECT_DEFINITION_TYPE     => X_OBJECT_DEFINITION_TYPE,
      X_OBJECT_VERSION             => '12.0',
      X_OBJECT_EXTENSION_VERSION   => X_OBJECT_EXTENSION_VERSION,
      X_STATUS                     => X_STATUS,
      X_ENABLED_FLAG               => X_ENABLED_FLAG,
      X_START_DATE_ACTIVE          => X_START_DATE_ACTIVE,
      X_END_DATE_ACTIVE            => '',
      X_CREATION_DATE              => X_CREATION_DATE,
      X_CREATED_BY                 => X_CREATED_BY,
      X_LAST_UPDATE_DATE           => X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY            => X_LAST_UPDATED_BY,
      X_LAST_UPDATE_LOGIN          => X_LAST_UPDATE_LOGIN,
      X_OBJECT_DEFINITION          => X_OBJECT_DEFINITION,
      X_OBJECT_REFERENCE           => X_OBJECT_REFERENCE);

  elsif (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then
  fnd_object_definitions_pkg.UPDATE_ROW (
      X_APPLICATION_ID             => X_APPLICATION_ID,
      X_OBJECT_ID                  => obj_id,
      X_OBJECT_DEFINITION_TYPE     => X_OBJECT_DEFINITION_TYPE,
      X_OBJECT_VERSION             => '12.0',
      X_OBJECT_EXTENSION_VERSION   => X_OBJECT_EXTENSION_VERSION,
      X_STATUS                     => X_STATUS,
      X_ENABLED_FLAG               => X_ENABLED_FLAG,
      X_START_DATE_ACTIVE          => X_START_DATE_ACTIVE,
      X_END_DATE_ACTIVE            => '',
      X_CREATION_DATE              => X_CREATION_DATE,
      X_CREATED_BY                 => X_CREATED_BY,
      X_LAST_UPDATE_DATE           => X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY            => X_LAST_UPDATED_BY,
      X_LAST_UPDATE_LOGIN          => X_LAST_UPDATE_LOGIN,
      X_OBJECT_DEFINITION          => X_OBJECT_DEFINITION,
      X_OBJECT_REFERENCE           => X_OBJECT_REFERENCE);
  end if;

end LOAD_ROW;

end FND_OBJECT_DEFINITIONS_PKG;

/
