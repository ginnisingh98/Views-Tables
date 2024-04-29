--------------------------------------------------------
--  DDL for Package Body BIS_FN_SAVE_FIELDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_FN_SAVE_FIELDS_PKG" as
/* $Header: BISVSFNB.pls 115.0 1999/11/19 16:10:16 pkm ship    $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |    BISVSFNS.pls
REM |
REM | DESCRIPTION                                                           |
REM |     PL/SQL body for package:  BIS_FN_SAVE_FIELDS_PKG
REM |
REM +=======================================================================+
*/
procedure INSERT_ROW (
  X_ROWID in out VARCHAR2,
  X_FUNCTION_ID in NUMBER,
  X_FIELD in VARCHAR2,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from BIS_FN_SAVE_FIELDS
    where FUNCTION_ID = X_FUNCTION_ID
    and FIELD = X_FIELD
    ;
begin
  insert into BIS_FN_SAVE_FIELDS (
    FIELD,
    FUNCTION_ID,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ATTRIBUTE_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE
  ) values
(
    X_FIELD,
    X_FUNCTION_ID,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_ATTRIBUTE_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE
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
  X_FUNCTION_ID in NUMBER,
  X_FIELD in VARCHAR2,
  X_ATTRIBUTE_CODE in VARCHAR2
) is
  cursor c1 is select
      ATTRIBUTE_CODE
    from BIS_FN_SAVE_FIELDS
    where FUNCTION_ID = X_FUNCTION_ID
    and FIELD = X_FIELD
    for update of FUNCTION_ID nowait;
begin
  for tlinfo in c1 loop
      if (    (tlinfo.ATTRIBUTE_CODE = X_ATTRIBUTE_CODE)
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
  X_FUNCTION_ID in NUMBER,
  X_FIELD in VARCHAR2,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update BIS_FN_SAVE_FIELDS set
    ATTRIBUTE_CODE = X_ATTRIBUTE_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where FUNCTION_ID = X_FUNCTION_ID
  and FIELD = X_FIELD;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_FUNCTION_ID in NUMBER,
  X_FIELD in VARCHAR2
) is
begin
  delete from BIS_FN_SAVE_FIELDS
  where FUNCTION_ID = X_FUNCTION_ID
  and FIELD = X_FIELD;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

END BIS_FN_SAVE_FIELDS_PKG;

/
