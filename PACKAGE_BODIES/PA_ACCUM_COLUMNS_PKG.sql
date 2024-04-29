--------------------------------------------------------
--  DDL for Package Body PA_ACCUM_COLUMNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ACCUM_COLUMNS_PKG" as
/* $Header: PAREPACB.pls 120.0 2005/05/29 12:15:16 appldev noship $ */
procedure INSERT_ROW (
  X_PROJECT_TYPE_CLASS_CODE  in VARCHAR2,
  X_COLUMN_ID                in NUMBER,
  X_ACCUM_CATEGORY_CODE      in VARCHAR2,
  X_ACCUM_COLUMN_CODE        in VARCHAR2,
  X_DESCRIPTION              in VARCHAR2,
  X_ACCUM_FLAG               in VARCHAR2,
  X_CREATION_DATE            in DATE,
  X_CREATED_BY               in NUMBER,
  X_LAST_UPDATE_DATE         in DATE,
  X_LAST_UPDATED_BY          in NUMBER,
  X_LAST_UPDATE_LOGIN        in NUMBER
) is
begin
  insert into PA_ACCUM_COLUMNS (
    PROJECT_TYPE_CLASS_CODE,
    COLUMN_ID,
    ACCUM_CATEGORY_CODE,
    ACCUM_COLUMN_CODE,
    DESCRIPTION,
    ACCUM_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_PROJECT_TYPE_CLASS_CODE,
    X_COLUMN_ID,
    X_ACCUM_CATEGORY_CODE,
    X_ACCUM_COLUMN_CODE,
    X_DESCRIPTION,
    X_ACCUM_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  exception
    when others then
      raise;

end INSERT_ROW;

procedure TRANSLATE_ROW (
  X_COLUMN_ID                IN NUMBER,
  X_OWNER                    IN VARCHAR2,
  X_DESCRIPTION              IN VARCHAR2) is
begin

  update PA_ACCUM_COLUMNS set
    DESCRIPTION       = X_DESCRIPTION,
    LAST_UPDATE_DATE  = sysdate,
    LAST_UPDATED_BY   = decode(X_OWNER, 'SEED', 1, 0),
    LAST_UPDATE_LOGIN = 0
  where COLUMN_ID     = X_COLUMN_ID
  and userenv('LANG') =
         (select LANGUAGE_CODE from FND_LANGUAGES where INSTALLED_FLAG = 'B');

/* Commented for bug 3857076.
  if (sql%notfound) then
    raise no_data_found;
  end if;
*/

  exception
    when others then
      raise;

end TRANSLATE_ROW;


procedure UPDATE_ROW (
  X_PROJECT_TYPE_CLASS_CODE  in VARCHAR2,
  X_COLUMN_ID                in NUMBER,
  X_ACCUM_COLUMN_CODE        in VARCHAR2,
  X_ACCUM_CATEGORY_CODE      in VARCHAR2,
  X_ACCUM_FLAG               in VARCHAR2,
  X_DESCRIPTION              in VARCHAR2,
  X_LAST_UPDATE_DATE         in DATE,
  X_LAST_UPDATED_BY          in NUMBER,
  X_LAST_UPDATE_LOGIN        in NUMBER
) is
begin
  update PA_ACCUM_COLUMNS set
    PROJECT_TYPE_CLASS_CODE = X_PROJECT_TYPE_CLASS_CODE,
    ACCUM_COLUMN_CODE       = X_ACCUM_COLUMN_CODE,
    ACCUM_CATEGORY_CODE     = X_ACCUM_CATEGORY_CODE,
    ACCUM_FLAG              = X_ACCUM_FLAG,
    DESCRIPTION             = X_DESCRIPTION,
    LAST_UPDATE_DATE        = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY         = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN       = X_LAST_UPDATE_LOGIN
  where COLUMN_ID           = X_COLUMN_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  exception
    when others then
      raise;

end UPDATE_ROW;

end PA_ACCUM_COLUMNS_PKG;

/
