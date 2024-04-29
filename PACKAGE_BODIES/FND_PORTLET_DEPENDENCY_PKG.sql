--------------------------------------------------------
--  DDL for Package Body FND_PORTLET_DEPENDENCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_PORTLET_DEPENDENCY_PKG" as
/* $Header: FNDPRTRB.pls 120.2 2005/11/04 13:55:18 sdstratt noship $ */

procedure INSERT_CONCURRENT_ROW (
  X_CONCURRENT_PROGRAM_NAME in VARCHAR2,
  X_CONCURRENT_APPLICATION_CODE in VARCHAR2,
  X_FUNCTION_NAME in VARCHAR2
) IS

l_rowid rowid;

begin

   FND_PORTLET_DEPENDENCY_PKG.INSERT_ROW (
      l_rowid,
      X_CONCURRENT_PROGRAM_NAME,
      X_CONCURRENT_APPLICATION_CODE,
      X_FUNCTION_NAME,
      sysdate,
      2,
      sysdate,
      2,
      0);

end INSERT_CONCURRENT_ROW;

procedure DELETE_CONCURRENT_ROW (
  X_CONCURRENT_PROGRAM_NAME in VARCHAR2,
  X_CONCURRENT_APPLICATION_CODE in VARCHAR2,
  X_FUNCTION_NAME in VARCHAR2
) IS


begin

   FND_PORTLET_DEPENDENCY_PKG.DELETE_ROW (
      X_CONCURRENT_PROGRAM_NAME,
      X_CONCURRENT_APPLICATION_CODE,
      X_FUNCTION_NAME);

end DELETE_CONCURRENT_ROW;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_REFRESH_DEPENDENCY in VARCHAR2,
  X_REFRESH_DEPENDENCY_CONTEXT in VARCHAR2,
  X_FUNCTION_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_PORTLET_DEPENDENCY
    where REFRESH_DEPENDENCY = X_REFRESH_DEPENDENCY
    and REFRESH_DEPENDENCY_CONTEXT = X_REFRESH_DEPENDENCY_CONTEXT
    and FUNCTION_NAME = X_FUNCTION_NAME
    ;
begin

  insert into FND_PORTLET_DEPENDENCY (
    REFRESH_DEPENDENCY,
    REFRESH_DEPENDENCY_CONTEXT,
    FUNCTION_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) SELECT
    X_REFRESH_DEPENDENCY,
    X_REFRESH_DEPENDENCY_CONTEXT,
    X_FUNCTION_NAME,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
    FROM DUAL
    where not exists
    (select NULL
    from FND_PORTLET_DEPENDENCY D
    where D.REFRESH_DEPENDENCY = X_REFRESH_DEPENDENCY
      and D.REFRESH_DEPENDENCY_CONTEXT = X_REFRESH_DEPENDENCY_CONTEXT
      and D.FUNCTION_NAME = X_FUNCTION_NAME);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure DELETE_ROW (
  X_REFRESH_DEPENDENCY in VARCHAR2,
  X_REFRESH_DEPENDENCY_CONTEXT in VARCHAR2,
  X_FUNCTION_NAME in VARCHAR2
) is
begin
  delete from FND_PORTLET_DEPENDENCY
  where REFRESH_DEPENDENCY = X_REFRESH_DEPENDENCY
  and   REFRESH_DEPENDENCY_CONTEXT = X_REFRESH_DEPENDENCY_CONTEXT
  and   FUNCTION_NAME = X_FUNCTION_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

Procedure PP_ACTION ( errbuff out NOCOPY varchar2,
                      retcode out NOCOPY varchar2,
                      step    in  number  ) is

   request_id number;
   program_name varchar2(30);
   program_application_name varchar2(30);

  cursor portlet_dependency (c_REFRESH_DEPENDENCY         varchar2,
                             c_REFRESH_DEPENDENCY_CONTEXT varchar2)is
    select PORT.FUNCTION_NAME FUNCTION_NAME
    from  FND_PORTLET_DEPENDENCY PORT
    where PORT.REFRESH_DEPENDENCY = c_REFRESH_DEPENDENCY
     and  PORT.REFRESH_DEPENDENCY_CONTEXT = c_REFRESH_DEPENDENCY_CONTEXT;

begin
   request_id  := FND_GLOBAL.CONC_REQUEST_ID;

   -- call FND_CONC_PP.RETRIVE procedure to get any parameters set at the
   -- time of assigning this PP_ACTION
   --

   -- call FND_REQUEST_INFO.INITIALIZE followed by GET_PARAM_INFO/GET_PROGRAM
   -- GET_PARAMETER to get request specific information

   select p.concurrent_program_name, a.APPLICATION_SHORT_NAME
     into program_name, program_application_name
     from fnd_application A, fnd_concurrent_programs P
    where P.concurrent_program_id = fnd_global.conc_program_id
      and P.application_id = fnd_global.prog_appl_id
      and P.application_id = A.application_id;

--   insert into geo_test values ('Program: ' || program_name);
--   insert into geo_test values ('Program App: ' || program_application_name);

   -- code your logic
   -- get the portlet functions that should be marked as dirty based on the
   -- execution of this concurrent program
   for func in portlet_dependency (program_name, program_application_name) loop

--      insert into geo_test values ('Found Func: ' || func.function_name);

      icx_portlet.updCacheByFuncName (func.function_name);

   end loop;


   -- Assing errbuff, retcode values to see the assigned value in request log
   -- file .
   pp_action.errbuff := 'FND_CP_TEMPLATE.pp_action Completed';
   pp_action.retcode := 0;

   commit;
end;

end FND_PORTLET_DEPENDENCY_PKG;

/
