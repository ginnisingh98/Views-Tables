--------------------------------------------------------
--  DDL for Package Body AME_FIELD_HELP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_FIELD_HELP_API" AS
/* $Header: amefhapi.pkb 120.0 2005/07/26 06:00:13 mbocutt noship $ */

procedure GET_CURRENT_FIELD_HELP_ROW (
  X_FIELD_NAME                      in VARCHAR2,
  X_PROCEDURE_NAME                  in VARCHAR2,
  X_PACKAGE_NAME                    in VARCHAR2,
  X_FIELD_HELP_ROWID                out nocopy VARCHAR2
)
is
   cursor CSR_GET_CURRENT_FIELD_HELP
    (
        X_FIELD_NAME                      in VARCHAR2,
        X_PROCEDURE_NAME                  in VARCHAR2,
        X_PACKAGE_NAME                    in VARCHAR2
    ) is
     select ROWID
     from AME_FIELD_HELP
     where FIELD_NAME    = X_FIELD_NAME
      and PROCEDURE_NAME = X_PROCEDURE_NAME
      and PACKAGE_NAME   = X_PACKAGE_NAME;
begin

  open CSR_GET_CURRENT_FIELD_HELP (
      X_FIELD_NAME,
      X_PROCEDURE_NAME,
      X_PACKAGE_NAME
    );
  fetch CSR_GET_CURRENT_FIELD_HELP into X_FIELD_HELP_ROWID;
    if (CSR_GET_CURRENT_FIELD_HELP%notfound) then
      X_FIELD_HELP_ROWID := null;
    end if;
  close CSR_GET_CURRENT_FIELD_HELP;
end GET_CURRENT_FIELD_HELP_ROW;

procedure INSERT_ROW (
 X_FIELD_NAME                      in VARCHAR2,
 X_PROCEDURE_NAME                  in VARCHAR2,
 X_PACKAGE_NAME                    in VARCHAR2,
 X_HELP_TEXT                       in VARCHAR2)
 is

begin
  insert into AME_FIELD_HELP
  (
   FIELD_NAME,
   PROCEDURE_NAME,
   PACKAGE_NAME,
   HELP_TEXT
  ) values (
   X_FIELD_NAME,
   X_PROCEDURE_NAME,
   X_PACKAGE_NAME,
   X_HELP_TEXT
  );

end INSERT_ROW;

procedure UPDATE_ROW (
        X_FIELD_HELP_ROWID                in VARCHAR2,
        X_HELP_TEXT                       in VARCHAR2)
 is
begin
  update AME_FIELD_HELP set
    HELP_TEXT            = X_HELP_TEXT
   where ROWID           = X_FIELD_HELP_ROWID;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_FIELD_NAME      in VARCHAR2,
  X_PROCEDURE_NAME  in VARCHAR2,
  X_PACKAGE_NAME    in VARCHAR2
) is
begin
  delete from AME_FIELD_HELP
  where FIELD_NAME     = X_FIELD_NAME
      and PROCEDURE_NAME = X_PROCEDURE_NAME
      and PACKAGE_NAME   = X_PACKAGE_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure LOAD_ROW (
        X_FIELD_NAME                      in VARCHAR2,
        X_PROCEDURE_NAME                  in VARCHAR2,
        X_PACKAGE_NAME                    in VARCHAR2,
        X_HELP_TEXT                       in VARCHAR2)
is
  X_FIELD_HELP_ROWID ROWID;
  X_CREATION_DATE DATE;
  X_CREATED_BY NUMBER;
  X_LAST_UPDATE_DATE DATE;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
begin
   begin
    GET_CURRENT_FIELD_HELP_ROW (
        X_FIELD_NAME,
        X_PROCEDURE_NAME,
        X_PACKAGE_NAME,
        X_FIELD_HELP_ROWID
     );
    if X_FIELD_HELP_ROWID is null then
      INSERT_ROW (
        X_FIELD_NAME,
        X_PROCEDURE_NAME,
        X_PACKAGE_NAME,
        X_HELP_TEXT);
    else
      UPDATE_ROW (
        X_FIELD_HELP_ROWID,
        X_HELP_TEXT);
    end if;
  end;
exception
    when others then
    ame_util.runtimeException('ame_field_help_api',
                         'load_row',
                         sqlcode,
                         sqlerrm);
        raise;
end LOAD_ROW;

END AME_FIELD_HELP_API;

/
