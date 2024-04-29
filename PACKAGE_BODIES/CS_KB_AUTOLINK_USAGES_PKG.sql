--------------------------------------------------------
--  DDL for Package Body CS_KB_AUTOLINK_USAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_AUTOLINK_USAGES_PKG" as
/* $Header: cskbalub.pls 120.0 2005/07/13 10:20:18 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_AUTOLINK_USAGE_ID in NUMBER,
  X_AUTOLINK_ID in NUMBER,
  X_OBJECT_CODE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from CS_KB_AUTOLINK_USAGES
    where AUTOLINK_USAGE_ID = X_AUTOLINK_USAGE_ID
    ;
begin
  insert into CS_KB_AUTOLINK_USAGES (
    AUTOLINK_USAGE_ID,
    AUTOLINK_ID,
    OBJECT_CODE,
    SEQUENCE_NUMBER,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_AUTOLINK_USAGE_ID,
    X_AUTOLINK_ID,
    X_OBJECT_CODE,
    X_SEQUENCE_NUMBER,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_AUTOLINK_USAGE_ID in NUMBER,
  X_AUTOLINK_ID in NUMBER,
  X_OBJECT_CODE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      AUTOLINK_ID,
      OBJECT_CODE,
      SEQUENCE_NUMBER,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      OBJECT_VERSION_NUMBER
    from CS_KB_AUTOLINK_USAGES
    where AUTOLINK_USAGE_ID = X_AUTOLINK_USAGE_ID
    for update of AUTOLINK_USAGE_ID nowait;
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
  if (    (recinfo.AUTOLINK_ID = X_AUTOLINK_ID)
      AND (recinfo.OBJECT_CODE = X_OBJECT_CODE)
      AND (recinfo.SEQUENCE_NUMBER = X_SEQUENCE_NUMBER)
      AND ((recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
           OR ((recinfo.START_DATE_ACTIVE is null) AND (X_START_DATE_ACTIVE is null)))
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

end LOCK_ROW;

procedure UPDATE_ROW (
  X_AUTOLINK_USAGE_ID in NUMBER,
  X_AUTOLINK_ID in NUMBER,
  X_OBJECT_CODE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update CS_KB_AUTOLINK_USAGES set
    AUTOLINK_ID = X_AUTOLINK_ID,
    OBJECT_CODE = X_OBJECT_CODE,
    SEQUENCE_NUMBER = X_SEQUENCE_NUMBER,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where AUTOLINK_USAGE_ID = X_AUTOLINK_USAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_AUTOLINK_USAGE_ID in NUMBER
) is
begin
  delete from CS_KB_AUTOLINK_USAGES
  where AUTOLINK_USAGE_ID = X_AUTOLINK_USAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end CS_KB_AUTOLINK_USAGES_PKG;

/
