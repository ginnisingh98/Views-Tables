--------------------------------------------------------
--  DDL for Package Body FND_PURPOSE_ATTRIBUTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_PURPOSE_ATTRIBUTES_PKG" as
/* $Header: fndpipab.pls 120.1 2005/07/02 03:34:53 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_PURPOSE_ATTRIBUTE_ID in NUMBER,
  X_PRIVACY_ATTRIBUTE_CODE in VARCHAR2,
  X_PURPOSE_CODE in VARCHAR2,
  X_ATTRIBUTE_DEFAULT_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_PURPOSE_ATTRIBUTES
    where PURPOSE_ATTRIBUTE_ID = X_PURPOSE_ATTRIBUTE_ID
    ;
begin
  insert into FND_PURPOSE_ATTRIBUTES (
    PURPOSE_ATTRIBUTE_ID,
    PRIVACY_ATTRIBUTE_CODE,
    PURPOSE_CODE,
    ATTRIBUTE_DEFAULT_CODE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER
  ) values (
    X_PURPOSE_ATTRIBUTE_ID,
    X_PRIVACY_ATTRIBUTE_CODE,
    X_PURPOSE_CODE,
    X_ATTRIBUTE_DEFAULT_CODE,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_OBJECT_VERSION_NUMBER);
/*  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_PURPOSE_ATTRIBUTES T
    where T.PURPOSE_ATTRIBUTE_ID = X_PURPOSE_ATTRIBUTE_ID);
*/

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_PURPOSE_ATTRIBUTE_ID in NUMBER,
  X_PRIVACY_ATTRIBUTE_CODE in VARCHAR2,
  X_PURPOSE_CODE in VARCHAR2,
  X_ATTRIBUTE_DEFAULT_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATED_BY in NUMBER
) is
  cursor c1 is select
      PRIVACY_ATTRIBUTE_CODE,
      PURPOSE_CODE,
      ATTRIBUTE_DEFAULT_CODE,
      OBJECT_VERSION_NUMBER,
      CREATED_BY
    from FND_PURPOSE_ATTRIBUTES
    where PURPOSE_ATTRIBUTE_ID = X_PURPOSE_ATTRIBUTE_ID
    for update of PURPOSE_ATTRIBUTE_ID nowait;
begin
  for tlinfo in c1 loop
      if (    (tlinfo.CREATED_BY = X_CREATED_BY)
          AND (tlinfo.PRIVACY_ATTRIBUTE_CODE = X_PRIVACY_ATTRIBUTE_CODE)
          AND (tlinfo.PURPOSE_CODE = X_PURPOSE_CODE)
          AND (tlinfo.ATTRIBUTE_DEFAULT_CODE = X_ATTRIBUTE_DEFAULT_CODE)
          AND (tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_PURPOSE_ATTRIBUTE_ID in NUMBER,
  X_PRIVACY_ATTRIBUTE_CODE in VARCHAR2,
  X_PURPOSE_CODE in VARCHAR2,
  X_ATTRIBUTE_DEFAULT_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_PURPOSE_ATTRIBUTES set
    PRIVACY_ATTRIBUTE_CODE = X_PRIVACY_ATTRIBUTE_CODE,
    PURPOSE_CODE = X_PURPOSE_CODE,
    ATTRIBUTE_DEFAULT_CODE = X_ATTRIBUTE_DEFAULT_CODE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PURPOSE_ATTRIBUTE_ID = X_PURPOSE_ATTRIBUTE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PURPOSE_ATTRIBUTE_ID in NUMBER
) is
begin
  delete from FND_PURPOSE_ATTRIBUTES
  where PURPOSE_ATTRIBUTE_ID = X_PURPOSE_ATTRIBUTE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end FND_PURPOSE_ATTRIBUTES_PKG;

/