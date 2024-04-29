--------------------------------------------------------
--  DDL for Package Body PA_STATUS_COLUMN_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_STATUS_COLUMN_SETUP_PKG" as
/* $Header: PAREPSCB.pls 120.3 2005/08/19 16:50:29 mwasowic ship $ */
procedure INSERT_ROW (
  X_FOLDER_CODE 	     in	VARCHAR2,
  X_COLUMN_ORDER	     in NUMBER,
  X_FORMAT_CODE              in VARCHAR2,
  X_COLUMN_NAME     	     in VARCHAR2,
  X_CURRENCY_FORMAT_FLAG     in	VARCHAR2,
  X_TOTAL_FLAG               in VARCHAR2,
  X_COLUMN_PROMPT     	     in VARCHAR2,
  X_CREATION_DATE            in DATE,
  X_CREATED_BY               in NUMBER,
  X_LAST_UPDATE_DATE         in DATE,
  X_LAST_UPDATED_BY          in NUMBER,
  X_LAST_UPDATE_LOGIN        in NUMBER
) is
begin
  insert into PA_STATUS_COLUMN_SETUP (
    FOLDER_CODE,
    COLUMN_ORDER,
    FORMAT_CODE,
    COLUMN_NAME,
    CURRENCY_FORMAT_FLAG,
    TOTAL_FLAG,
    COLUMN_PROMPT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_FOLDER_CODE,
    X_COLUMN_ORDER,
    X_FORMAT_CODE,
    X_COLUMN_NAME,
    X_CURRENCY_FORMAT_FLAG,
    X_TOTAL_FLAG,
    X_COLUMN_PROMPT,
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
  X_FOLDER_CODE            in VARCHAR2,
  X_COLUMN_ORDER           in NUMBER,
  X_FORMAT_CODE            in VARCHAR2,
  X_OWNER                  in VARCHAR2,
  X_COLUMN_PROMPT          in VARCHAR2) is
begin

  update PA_STATUS_COLUMN_SETUP set
    COLUMN_PROMPT     = X_COLUMN_PROMPT,
    LAST_UPDATE_DATE  = sysdate,
    LAST_UPDATED_BY   = decode(X_OWNER, 'SEED', 1, 0),
    LAST_UPDATE_LOGIN = 0
  where FOLDER_CODE   = X_FOLDER_CODE
  and   COLUMN_ORDER  = X_COLUMN_ORDER
  and   FORMAT_CODE   = X_FORMAT_CODE
  and userenv('LANG') =
         (select LANGUAGE_CODE from FND_LANGUAGES where INSTALLED_FLAG = 'B')
  and last_update_login = 0;

--  Commented for Bug 3857092
--  if (sql%notfound) then
--    raise no_data_found;
--  end if;

  exception
    when others then
      raise;

end TRANSLATE_ROW;

procedure GET_INSERT_STATUS (
  X_INSERTFLAG   out NOCOPY BOOLEAN --File.Sql.39 bug 4440895
) is
  X_COUNT  NUMBER;
begin

  if (g_insertflag IS NULL) then
    select count(*)
    into X_COUNT
    from PA_STATUS_COLUMN_SETUP;

    if (X_COUNT > 0) then
       g_insertflag := false;
    else
       g_insertflag := true;
    end if;
  end if;

  X_INSERTFLAG := g_insertflag;

  exception
    when others then
      raise;

end GET_INSERT_STATUS;

end PA_STATUS_COLUMN_SETUP_PKG;

/
