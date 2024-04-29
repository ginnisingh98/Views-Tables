--------------------------------------------------------
--  DDL for Package Body AME_HELP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_HELP_API" AS
/* $Header: ameheapi.pkb 120.0 2005/07/26 06:00:24 mbocutt noship $ */


procedure GET_CURRENT_HELP_ROW (
  X_CONTEXT                         in VARCHAR2,
  X_HELP_ROWID                      out nocopy VARCHAR2
)
is
   cursor CSR_GET_CURRENT_HELP
    (
     X_CONTEXT                     in VARCHAR2
    ) is
     select ROWID
     from AME_HELP
     where context = X_CONTEXT;
begin

  open CSR_GET_CURRENT_HELP (
    X_CONTEXT
  );
  fetch CSR_GET_CURRENT_HELP into X_HELP_ROWID;
    if (CSR_GET_CURRENT_HELP%notfound) then
      X_HELP_ROWID := null;
    end if;
  close CSR_GET_CURRENT_HELP;
end GET_CURRENT_HELP_ROW;

procedure INSERT_ROW (
 X_CONTEXT                         in VARCHAR2,
 X_FILE_NAME                       in VARCHAR2)
 is

begin
  insert into AME_HELP
  (
   CONTEXT,
   FILE_NAME
  ) values (
   X_CONTEXT,
   X_FILE_NAME
  );

end INSERT_ROW;

procedure UPDATE_ROW (
   X_HELP_ROWID                       in VARCHAR2,
   X_FILE_NAME                        in VARCHAR2)
 is
begin
  update AME_HELP set
    FILE_NAME  = X_FILE_NAME
   where ROWID = X_HELP_ROWID;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_CONTEXT   in VARCHAR2,
  X_FILE_NAME in VARCHAR2
) is
begin
  delete from AME_HELP
  where CONTEXT   = X_CONTEXT
    and FILE_NAME = X_FILE_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure LOAD_ROW (
          X_CONTEXT   in VARCHAR2,
          X_FILE_NAME in VARCHAR2)
is
  X_HELP_ROWID ROWID;
  X_CREATION_DATE DATE;
  X_CREATED_BY NUMBER;
  X_LAST_UPDATE_DATE DATE;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
begin
   begin
    GET_CURRENT_HELP_ROW (
      X_CONTEXT,
      X_HELP_ROWID
      );
    if X_HELP_ROWID is null then
      INSERT_ROW (
       X_CONTEXT,
       X_FILE_NAME);
    else
       UPDATE_ROW (
       X_HELP_ROWID,
       X_FILE_NAME
       );
    end if;
  end;
exception
    when others then
    ame_util.runtimeException('ame_help_api',
                         'load_row',
                         sqlcode,
                         sqlerrm);
        raise;
end LOAD_ROW;

END AME_HELP_API;

/
