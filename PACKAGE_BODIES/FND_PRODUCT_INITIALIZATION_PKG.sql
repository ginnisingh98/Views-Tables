--------------------------------------------------------
--  DDL for Package Body FND_PRODUCT_INITIALIZATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_PRODUCT_INITIALIZATION_PKG" as
/* $Header: AFPINITB.pls 120.6 2007/01/17 18:01:23 rsheh ship $ */

--
-- Register (PUBLIC)
--   Called by product team to register their re-initialization function
-- Input
--   x_apps_name: application short name
--   x_init_function: re-initialization function
procedure Register(x_apps_name          in varchar2,
                   x_init_function      in varchar2 default null,
                   x_owner              in varchar2 default 'SEED') is
begin
 Register(x_apps_name           => x_apps_name,
          x_init_function       => x_init_function,
          x_owner               => x_owner,
          x_last_update_date    => null,
          x_custom_mode         => null);

end Register;

--
-- Remove (PUBLIC)
--   Called by product team to delete their re-initialization function
-- Input
--   x_apps_name: application short name
--   x_init_function: re-initialization function
procedure Remove(x_apps_name     in varchar2) is
begin
  begin
    delete from FND_PRODUCT_INITIALIZATION
    where APPLICATION_SHORT_NAME = upper(x_apps_name);

  exception
    when others then
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', 'Remove');
      fnd_message.set_token('ERRNO', to_char(sqlcode));
      fnd_message.set_token('REASON', sqlerrm);
      app_exception.raise_exception(NULL, NULL,
        'Exception in FND_PRODUCT_INITIALIZATION_PKG.REMOVE');
      raise;
  end;

end Remove;

-- AddInitCondition (PUBLIC)
--   Called by anybody who wants to register their product's re-initialization
--   conditions.
--
-- Input
--   x_apps_name:  the application short name
--   x_condition:  one of the following conditions:
--                 'APPL', 'RESP', 'USER', 'NLS', 'ORG'
--
procedure AddInitCondition(x_apps_name in varchar2,
                           x_condition in varchar2,
                           x_owner     in varchar2) is
begin
 AddInitCondition(x_apps_name              => x_apps_name,
                  x_condition              => x_condition,
                  x_owner                  => x_owner,
                  x_last_update_date       => null,
                  x_custom_mode            => null);
end AddInitCondition;

-- RemoveInitCondition (PUBLIC)
--   Called by anybody who wants to remove their product's re-initialization
--   conditions.
--
-- Input
--   x_apps_name:  the application short name
--   x_condition:  one of the following conditions:
--                 'APPL', 'RESP', 'USER', 'NLS', 'ORG'
--
procedure RemoveInitCondition(x_apps_name in varchar2,
                              x_condition in varchar2) is
begin
  begin
    delete from FND_PRODUCT_INIT_CONDITION
    where APPLICATION_SHORT_NAME = upper(x_apps_name)
    and   RE_INIT_CONDITION = upper(x_condition);

  exception
    when others then
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', 'RemoveInitCondition');
      fnd_message.set_token('ERRNO', to_char(sqlcode));
      fnd_message.set_token('REASON', sqlerrm);
      app_exception.raise_exception(NULL, NULL,
        'Exception in FND_PRODUCT_INITIALIZATION_PKG.RemoveInitCondition');
      raise;
  end;

end RemoveInitCondition;

--
-- AddDependency (PUBLIC)
--   Called by anybody who wants to register their product dependency
--
-- Input
--   x_apps_name:  the application short name
--   x_dependency: the dependency application short name
--
procedure AddDependency(x_apps_name   in varchar2,
                        x_dependency  in varchar2,
                        x_owner       in varchar2) is
begin
 AddDependency(x_apps_name              => x_apps_name,
               x_dependency             => x_dependency,
               x_owner                  => x_owner,
               x_last_update_date       => null,
               x_custom_mode            => null);

end AddDependency;

--
-- RemoveDependency (PUBLIC)
--   Called by anybody who wants to remove their product dependency
--
-- Input
--   x_apps_name:  the application short name
--   x_dependency: the dependency application short name
--
procedure RemoveDependency(x_apps_name   in varchar2,
                           x_dependency  in varchar2) is

begin
  begin
    delete from FND_PRODUCT_INIT_DEPENDENCY
    where APPLICATION_SHORT_NAME = upper(x_apps_name)
    and   PRODUCT_DEPENDENCY = upper(x_dependency);

  exception
    when others then
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', 'RemoveDependency');
      fnd_message.set_token('ERRNO', to_char(sqlcode));
      fnd_message.set_token('REASON', sqlerrm);
      app_exception.raise_exception(NULL, NULL,
        'Exception in FND_PRODUCT_INITIALIZATION_PKG.RemoveDependency');
      raise;
  end;

end RemoveDependency;

--
-- ExecInitFunction (PUBLIC)
--   Called by FND_GLOBAL.INITIALIZE() which decides the current application
--   short name and the conditions occurred.
--
-- Input
--   x_apps_name:  the application short name
--   x_conditions: it is assumed in the format of ('APPL', 'USER')
--
-- Note:
--   WE HAVE TO HAVE GOOD ERROR HANDLING HERE BECAUSE IT IS CALLED BY
--   BY GLOBAL.INITIALIZE()
procedure ExecInitFunction(x_apps_name in varchar2,
                           x_conditions in varchar2) is
  conditions varchar2(80);
  sqlbuf varchar2(2000);
  init_function varchar2(240);
  deparr TextArrayTyp;
  i number;
  tmpbuf varchar2(240);

  -- Construct a dependency list for x_apps_name.
  -- Duplidate dependency is taken care by using distinct command.
  -- And the invoking ordering is taken care by the LEVEL order by.
  cursor dependency is
  select distinct PRODUCT_DEPENDENCY, LEVEL
  from FND_PRODUCT_INIT_DEPENDENCY p1
  where LEVEL =
    (select max(LEVEL)
     from FND_PRODUCT_INIT_DEPENDENCY p2
     where p2.PRODUCT_DEPENDENCY = p1.PRODUCT_DEPENDENCY
     connect by prior p2.PRODUCT_DEPENDENCY = p2.APPLICATION_SHORT_NAME
     start with p2.APPLICATION_SHORT_NAME = upper(x_apps_name))
  connect by prior PRODUCT_DEPENDENCY = APPLICATION_SHORT_NAME
  start with APPLICATION_SHORT_NAME = upper(x_apps_name)
  order by LEVEL desc;

  -- The following was added to fix Bug#3654609
    n number :=0;
    pos number :=0;
    initfunc_str varchar2(240);
    TYPE initfunc_array IS TABLE OF VARCHAR2(25)
    INDEX BY BINARY_INTEGER;
    strings initfunc_array;
    p_delim varchar2(6):= ',';

begin

  -- Logging info
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE,
                 'PLSQL.FND.SECURITY.INIT.FND_INITIALIZATION_PKG',
                 'Entering Fnd_Product_Initialization.ExecInitFunction');
    tmpbuf := 'The current Apps and Context condition is'||
              '('||x_apps_name||','||x_conditions||')';
    fnd_log.string(fnd_log.LEVEL_PROCEDURE,
                   'PLSQL.FND.SECURITY.INIT.FND_INITIALIZATION_PKG',tmpbuf);
  end if;

  -- Reformat the x_conditions so that we can use that in our IN clause.
  conditions := replace(x_conditions, '_', ',');
  initfunc_str := conditions;

  Fnd_Product_Initialization_Pkg.init_conditions := conditions;

   -- Added the following to fix Bug#3654609
        -- determine first chuck of string
        pos := instr(initfunc_str,p_delim,1,1);

        if (pos <> 0) then
              -- while there are chunks left, loop
              while ( pos <> 0) loop
                    -- increment counter
                    n := n + 1;
                    -- create array element for chuck of string
                    strings(n) := ltrim(rtrim(substr(initfunc_str,1,pos-1), ''''), '''');
                    -- remove chunk from string
                    initfunc_str := substr(initfunc_str,pos+1,length(initfunc_str));
                    -- determine next chunk
                    pos := instr(initfunc_str,p_delim,1,1);
                    -- no last chunk, add to array
                    if pos = 0 then
                       strings(n+1) := ltrim(rtrim(initfunc_str, ''''), '''');
                    end if;
              end loop;
              n := n+1;
        else
             if (pos = 0) and (conditions is not null) then
                 strings(1) := ltrim(rtrim(initfunc_str, ''''), '''');
                 n := 1;
             end if;
        end if;

  begin
  i := 0;
  for dep in dependency loop
    deparr(i) := upper(dep.PRODUCT_DEPENDENCY);
    i := i+1;
  end loop;
  deparr(i) := upper(x_apps_name);
  deparr(i+1) := '';

  exception
    when others then
    if (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
      fnd_log.string(fnd_log.LEVEL_EXCEPTION,
                   'PLSQL.FND.SECURITY.INIT.FND_INITIALIZATION_PKG',
                   'Unable to fetch product dependency');
    end if;
    fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
    fnd_message.set_token('ROUTINE',sqlbuf);
    fnd_message.set_token('ERRNO', to_char(sqlcode));
    fnd_message.set_token('REASON', sqlerrm);
    app_exception.raise_exception;
  end;

  i := 0;
  while(deparr(i) is not null) loop
    -- For a given application, check if any of its re-init-conditions
    -- match with our input x_conditions.
    -- don't need to trap "no row selected"
    begin
      init_function := null;

      -- Fix Bug#3654609 - Performance issue using dynamic sql
      /* sqlbuf := 'select INIT_FUNCTION_NAME '||
      'from FND_PRODUCT_INITIALIZATION '||
      'where APPLICATION_SHORT_NAME = :v1 '||
      'and exists '||
      '(select 1 '||
      'from FND_PRODUCT_INIT_CONDITION C '||
      'where C.APPLICATION_SHORT_NAME = :v2 '||
      'and C.RE_INIT_CONDITION in ('||conditions||'))';

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
        tmpbuf := 'Start fetching init_function for product '||deparr(i);
        fnd_log.string(fnd_log.LEVEL_STATEMENT,
                      'PLSQL.FND.SECURITY.INIT.FND_INITIALIZATION_PKG',tmpbuf);
      end if;

      execute immediate sqlbuf into init_function
      using deparr(i), deparr(i); */

      -- Fetch init function
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
        tmpbuf := 'Start fetching init_function for product '||deparr(i);
        fnd_log.string(fnd_log.LEVEL_STATEMENT,
                     'PLSQL.FND.SECURITY.INIT.FND_INITIALIZATION_PKG',tmpbuf);
      end if;

      if (n = 1) then
         select INIT_FUNCTION_NAME
         into init_function
         from FND_PRODUCT_INITIALIZATION
         where APPLICATION_SHORT_NAME = deparr(i)
         and exists
          (select 1
           from FND_PRODUCT_INIT_CONDITION C
           where C.APPLICATION_SHORT_NAME = deparr(i)
           and C.RE_INIT_CONDITION in (strings(1)));
      elsif (n = 2) then
         select INIT_FUNCTION_NAME
         into init_function
         from FND_PRODUCT_INITIALIZATION
         where APPLICATION_SHORT_NAME = deparr(i)
         and exists
          (select 1
           from FND_PRODUCT_INIT_CONDITION C
           where C.APPLICATION_SHORT_NAME = deparr(i)
           and C.RE_INIT_CONDITION in (strings(1), strings(2)));
      elsif (n = 3) then
         select INIT_FUNCTION_NAME
         into init_function
         from FND_PRODUCT_INITIALIZATION
         where APPLICATION_SHORT_NAME = deparr(i)
         and exists
          (select 1
           from FND_PRODUCT_INIT_CONDITION C
           where C.APPLICATION_SHORT_NAME = deparr(i)
           and C.RE_INIT_CONDITION in (strings(1), strings(2), strings(3)));
      elsif (n = 4) then
         select INIT_FUNCTION_NAME
         into init_function
         from FND_PRODUCT_INITIALIZATION
         where APPLICATION_SHORT_NAME = deparr(i)
         and exists
         (select 1
          from FND_PRODUCT_INIT_CONDITION C
          where C.APPLICATION_SHORT_NAME = deparr(i)
          and C.RE_INIT_CONDITION in (strings(1), strings(2), strings(3), strings(4)));
      elsif (n = 5) then
         select INIT_FUNCTION_NAME
         into init_function
         from FND_PRODUCT_INITIALIZATION
         where APPLICATION_SHORT_NAME = deparr(i)
         and exists
         (select 1
          from FND_PRODUCT_INIT_CONDITION C
          where C.APPLICATION_SHORT_NAME = deparr(i)
          and C.RE_INIT_CONDITION in (strings(1), strings(2), strings(3), strings(4), strings(5)));
      elsif (n = 6) then
         select INIT_FUNCTION_NAME
         into init_function
         from FND_PRODUCT_INITIALIZATION
         where APPLICATION_SHORT_NAME = deparr(i)
         and exists
         (select 1
          from FND_PRODUCT_INIT_CONDITION C
          where C.APPLICATION_SHORT_NAME = deparr(i)
          and C.RE_INIT_CONDITION in (strings(1), strings(2), strings(3), strings(4), strings(5), strings(6)));
      elsif (n = 7) then
         select INIT_FUNCTION_NAME
         into init_function
         from FND_PRODUCT_INITIALIZATION
         where APPLICATION_SHORT_NAME = deparr(i)
         and exists
         (select 1
          from FND_PRODUCT_INIT_CONDITION C
          where C.APPLICATION_SHORT_NAME = deparr(i)
          and C.RE_INIT_CONDITION in (strings(1), strings(2), strings(3), strings(4), strings(5), strings(6), strings(7)));
      elsif (n = 8) then
         select INIT_FUNCTION_NAME
         into init_function
         from FND_PRODUCT_INITIALIZATION
         where APPLICATION_SHORT_NAME = deparr(i)
         and exists
         (select 1
          from FND_PRODUCT_INIT_CONDITION C
          where C.APPLICATION_SHORT_NAME = deparr(i)
          and C.RE_INIT_CONDITION in (strings(1), strings(2), strings(3), strings(4), strings(5), strings(6), strings(7), strings(8)));
      elsif (n = 9) then
         select INIT_FUNCTION_NAME
         into init_function
         from FND_PRODUCT_INITIALIZATION
         where APPLICATION_SHORT_NAME = deparr(i)
         and exists
         (select 1
          from FND_PRODUCT_INIT_CONDITION C
          where C.APPLICATION_SHORT_NAME = deparr(i)
          and C.RE_INIT_CONDITION in (strings(1), strings(2), strings(3), strings(4), strings(5), strings(6), strings(7), strings(8), strings(9)));
      elsif (n = 10) then
         select INIT_FUNCTION_NAME
         into init_function
         from FND_PRODUCT_INITIALIZATION
         where APPLICATION_SHORT_NAME = deparr(i)
         and exists
         (select 1
          from FND_PRODUCT_INIT_CONDITION C
          where C.APPLICATION_SHORT_NAME = deparr(i)
          and C.RE_INIT_CONDITION in (strings(1), strings(2), strings(3), strings(4), strings(5), strings(6), strings(7), strings(8), strings(9), strings(10)));
      end if;
    exception
      when no_data_found then
        -- This is ok. It means that the dependency product has no
        -- initialization routine or don't care about the current conditions.
        if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
          tmpbuf := deparr(i)||' has either no init routine or no matching '||
                    'init condition';
          fnd_log.string(fnd_log.LEVEL_STATEMENT,
                         'PLSQL.FND.SECURITY.INIT.FND_INITIALIZATION_PKG',
                         tmpbuf);
        end if;
      when others then
        if (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
          tmpbuf := 'Unable to fetch init_function of product '||deparr(i);
          fnd_log.string(fnd_log.LEVEL_EXCEPTION,
                         'PLSQL.FND.SECURITY.INIT.FND_INITIALIZATION_PKG',
                         tmpbuf);
        end if;
        fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
        fnd_message.set_token('ROUTINE',sqlbuf);
        fnd_message.set_token('ERRNO', to_char(sqlcode));
        fnd_message.set_token('REASON', sqlerrm);
        app_exception.raise_exception;
    end;

    if (init_function is not null) then
      -- Execute the init function
      begin
        if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
          tmpbuf := 'Calling initialization routine: '||init_function;
          fnd_log.string(fnd_log.LEVEL_STATEMENT,
                         'PLSQL.FND.SECURITY.INIT.FND_INITIALIZATION_PKG',
                         tmpbuf);
        end if;

        init_function := 'begin '||init_function||'; end;';
        execute immediate init_function;

      exception
        when others then
          if (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
            tmpbuf := 'Unable to execute init_function of product '||deparr(i);
            fnd_log.string(fnd_log.LEVEL_EXCEPTION,
                           'PLSQL.FND.SECURITY.INIT.FND_INITIALIZATION_PKG',
                           tmpbuf);
          end if;
          fnd_message.set_name('FND', 'PRODUCT_INITIALIZATION_FAILED');
          fnd_message.set_token('APPS', deparr(i));
          fnd_message.set_token('ROUTINE', init_function);
          fnd_message.set_token('SQLCODE', to_char(sqlcode));
          fnd_message.set_token('SQLERROR', sqlerrm);
          app_exception.raise_exception;
      end;
    end if;
    i := i+1;
  end loop;

end ExecInitFunction;


procedure Test(x_apps_name in varchar2) is
begin

  fnd_product_initialization_pkg.execinitfunction(x_apps_name,
                              '''APPL''_''RESP''');
end Test;

-- Register (PUBLIC)
--   Called by product team to register their re-initialization function
-- Input
--   x_apps_name: application short name
--   x_init_function: re-initialization function
procedure Register(x_apps_name          in varchar2,
                   x_init_function      in varchar2 default null,
                   x_owner              in varchar2 default 'SEED',
                   x_last_update_date   in varchar2,
                   x_custom_mode        in varchar2) is
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
begin

 -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from FND_PRODUCT_INITIALIZATION
    where APPLICATION_SHORT_NAME = upper(x_apps_name);

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then

     update FND_PRODUCT_INITIALIZATION
     set INIT_FUNCTION_NAME = upper(x_init_function),
        LAST_UPDATED_BY = f_luby,
        LAST_UPDATE_DATE = f_ludate,
        LAST_UPDATE_LOGIN = f_luby
     where APPLICATION_SHORT_NAME = upper(x_apps_name);
    end if;

    exception
     when no_data_found then
      insert into FND_PRODUCT_INITIALIZATION(
      APPLICATION_SHORT_NAME,
      INIT_FUNCTION_NAME,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      CREATION_DATE,
      CREATED_BY)
      values(
      upper(x_apps_name),
      upper(x_init_function),
      f_luby,
      f_ludate,
      f_luby,
      f_ludate,
      f_luby);

    when others then
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', 'Register');
      fnd_message.set_token('ERRNO', to_char(sqlcode));
      fnd_message.set_token('REASON', sqlerrm);
      app_exception.raise_exception(NULL, NULL,
        'Exception in FND_PRODUCT_INITIALIZATION_PKG.REGISTER');
 end;
end Register;

--
-- AddDependency (PUBLIC) - Overloaded
--   Called by anybody who wants to register their product dependency
--
-- Input
--   x_apps_name:  the application short name
--   x_dependency: the dependency application short name
--
procedure AddDependency(x_apps_name   in varchar2,
                        x_dependency  in varchar2,
                        x_owner       in varchar2,
                        x_last_update_date   in varchar2,
                        x_custom_mode        in varchar2) is

  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file

begin
 -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  begin
    insert into FND_PRODUCT_INIT_DEPENDENCY(
    APPLICATION_SHORT_NAME,
    PRODUCT_DEPENDENCY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY)
    values(
    upper(x_apps_name),
    upper(x_dependency),
    f_luby,
    f_ludate,
    f_luby,
    f_ludate,
    f_luby);
  exception
    when dup_val_on_index then
      null;
    when others then
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', 'AddDependency');
      fnd_message.set_token('ERRNO', to_char(sqlcode));
      fnd_message.set_token('REASON', sqlerrm);
      app_exception.raise_exception(NULL, NULL,
        'Exception in FND_PRODUCT_INITIALIZATION_PKG.AddDependency');
      raise;
  end;

end AddDependency;
-- AddInitCondition (PUBLIC)
--   Called by anybody who wants to register their product's re-initialization
--   conditions.
--
-- Input
--   x_apps_name:  the application short name
--   x_condition:  one of the following conditions:
--                 'APPL', 'RESP', 'USER', 'NLS', 'ORG'
--
procedure AddInitCondition(x_apps_name in varchar2,
                           x_condition in varchar2,
                           x_owner     in varchar2,
                           x_last_update_date   in varchar2,
                           x_custom_mode        in varchar2) is

  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file

begin
 -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  begin
    insert into FND_PRODUCT_INIT_CONDITION(
    APPLICATION_SHORT_NAME,
    RE_INIT_CONDITION,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY)
    values(
    upper(x_apps_name),
    upper(x_condition),
    f_luby,
    f_ludate,
    f_luby,
    f_ludate,
    f_luby);

  exception
    when dup_val_on_index then
      null;
    when others then
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', 'AddInitCondition');
      fnd_message.set_token('ERRNO', to_char(sqlcode));
      fnd_message.set_token('REASON', sqlerrm);
      app_exception.raise_exception(NULL, NULL,
        'Exception in FND_PRODUCT_INITIALIZATION_PKG.AddInitCondition');
  end;

end AddInitCondition;

-- DiscoInit (PUBLIC)
--   Called by Disco trigger to run all product initialization code inside
--   fnd_product_initialization table with all true conditions.
--
-- Input
--   no input argument
--
function DiscoInit return number is
begin

  fnd_product_initialization_pkg.ExecInitFunction(
                          fnd_global.application_short_name,
                          '''APPL''_''RESP''_''USER''_''NLS''_''ORG''');
  return(ExecInitSuccess);

exception
  when others then
    return(ExecInitFailure);

end DiscoInit;

-- RemoveAll (PUBLIC)
--   Called by anybody who wants to remove all their product initialization
--   data.
--
-- Input
--   x_apps_short_name:  the application short name
--
procedure RemoveAll(apps_short_name in varchar2) is
begin
  delete from fnd_product_init_dependency
  where application_short_name = apps_short_name;

  delete from fnd_product_init_condition
  where application_short_name = apps_short_name;

  delete from fnd_product_initialization
  where application_short_name = apps_short_name;

end RemoveAll;



end Fnd_Product_Initialization_Pkg;

/
