--------------------------------------------------------
--  DDL for Package Body FND_DATA_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_DATA_SECURITY" AS
/* $Header: AFSCDSCB.pls 120.18 2006/11/15 07:26:42 stadepal noship $ */

  C_PKG_NAME       CONSTANT VARCHAR2(30) := 'FND_DATA_SECURITY';
  C_LOG_HEAD       CONSTANT VARCHAR2(30) := 'fnd.plsql.FND_DATA_SECURITY.';
  C_TYPE_SET       CONSTANT VARCHAR2(30) := 'SET';
  C_TYPE_GLOBAL    CONSTANT VARCHAR2(30) := 'GLOBAL';
  C_TYPE_INSTANCE  CONSTANT VARCHAR2(30) := 'INSTANCE';
  C_TYPE_UNIVERSAL CONSTANT VARCHAR2(30) := 'UNIVERSAL';

  C_NULL_STR       CONSTANT VARCHAR2(30) := '*NULL*';


  C_AMP_STR         CONSTANT VARCHAR2(30) := '&';
  C_GRANT_ALIAS_TOK CONSTANT VARCHAR2(30) := C_AMP_STR || 'GRANT_ALIAS.';
  C_TABLE_ALIAS_TOK CONSTANT VARCHAR2(30) := C_AMP_STR || 'TABLE_ALIAS.';


  c_pred_buf_size CONSTANT NUMBER := 32767;

  /* This is the VPD size limit of predicates in the database.  */
  /* In 8.1.7 databases the limit is 4k, and in 8.2+ it will be 32k. */
  /* Set by the code to 4k for 8.1.7- or ~32k if db version is 8.2+ */
  g_vpd_buf_limit NUMBER := -1; /* 0 means needs to be initialized */

  /* One level cache for get_object_id() */
  g_obj_id_cache     NUMBER := NULL;
  g_obj_name_cache   VARCHAR2(30) := NULL;

  /* One level cache for get_function_id() */
  g_func_id_cache    NUMBER := NULL;
  -- modified for bug#5395351
  g_func_name_cache  fnd_form_functions.function_name%type := NULL;

  /* One level cache for get_security_predicate */
  -- modified for bug#5395351
  g_gsp_function             fnd_form_functions.function_name%type  := '*EMPTY*';
  g_gsp_object_name          VARCHAR2(30)  := '*EMPTY*';
  g_gsp_grant_instance_type  VARCHAR2(30)  := '*EMPTY*';
  g_gsp_user_name            VARCHAR2(255) := '*EMPTY*';
  g_gsp_statement_type       VARCHAR2(30)  := '*EMPTY*';
  g_gsp_predicate            VARCHAR2(32767):= '*EMPTY*';
  g_gsp_return_status        VARCHAR2(30)  := '*EMPTY*';
  g_gsp_table_alias          VARCHAR2(255) := '*EMPTY*';
  g_gsp_bind_order           VARCHAR2(255) := '*EMPTY*';
  g_gsp_with_binds           VARCHAR2(30)  := '*EMPTY*';
  g_gsp_context_user_id      NUMBER := -11111;
  g_gsp_context_secgrpid     NUMBER := -11111;
  g_gsp_context_resp_id      NUMBER := -11111;
  g_gsp_context_resp_appl_id NUMBER := -11111;
  g_gsp_context_org_id       NUMBER := -11111;
  g_gsp_object_id            NUMBER := -11111;
  g_gsp_function_id          NUMBER := -11111;

  /* One level cache for CHECK_USER_ROLE() */
  g_ck_user_role_result    VARCHAR2(1)   := NULL;
  g_ck_user_role_name      VARCHAR2(255) := NULL;


  /* Returning this value indicates date conversion failed. */
  g_bad_date         DATE := fnd_date.canonical_to_date('1970/11/11');

  /* Define the exception that will be used for reraising exception */
  /* concerning a call to deprecated APIs */
  FND_MESSAGE_RAISED_ERR EXCEPTION;
  pragma exception_init(FND_MESSAGE_RAISED_ERR, -20001);


 ---This is an internal procedure. Not for general use.
 --   Initializes the max vpd predicate size depending on the database version.
 --   In 8.1.7 databases the limit is 4k, and in 8.2 it will be 32k.
 -----------------------------------------------
function self_init_pred_size return number is
  limit_up_to_8_1_7 number := 4*1024; /* 4k */
  /* Keep the limit smaller than c_pred_buf_size so that we can detect when */
  /* we have filled a predicate buffer past the limit. */
  limit_after_8_1_7 number := c_pred_buf_size-1; /* approx 32k */
  l_pos1 pls_integer;
  l_pos2 pls_integer;
  l_version_string varchar2(80);
  l_version_major varchar2(80);
  l_version_minor varchar2(80);
begin

   /* Version will be something like '9.2.0.5.0' meaning major 9, minor 2*/
   SELECT version
     INTO l_version_string
     FROM v$instance;

   l_pos1 := instr(l_version_string, '.');
   if((l_pos1) = 0) then
     /* Cant parse version.  Should never happen.  Assume the worst */
     return limit_up_to_8_1_7;
   end if;

   l_version_major := to_number(substr(l_version_string,
                                       1,
                                       l_pos1 - 1));

   if(l_version_major > 8) then
     /* Db version is higher, so use higher limit */
     return limit_after_8_1_7;
   end if;

   if(l_version_major < 8) then
     /* Db version is lower, so use lower limit */
     return limit_up_to_8_1_7;
   end if;

   /* If we got here then the major version is 8, so check minor version*/

   l_pos2 := instr(l_version_string, '.', 1, 2);
   if((l_pos2) = 0) then
     /* Cant parse version.  Should never happen.  Assume the worst */
     return limit_up_to_8_1_7;
   end if;

   l_version_minor := to_number(substr(l_version_string,
                                       l_pos1 + 1,
                                       l_pos2 - l_pos1 - 1));

   if(l_version_minor >= 2) then
     /* Db version is higher, so use higher limit */
     return limit_after_8_1_7;
   else
     /* Db version is lower, so use lower limit */
     return limit_up_to_8_1_7;
   end if;

end;

 ---This is an internal procedure. Not for general use.
 --   Gets returns a result indicating whether the user has a role.
 -----------------------------------------------
function CHECK_USER_ROLE(P_USER_NAME      in         varchar2)
                       return  varchar2 /* T/F */
is
 l_dummy number := 0;
 colon pls_integer;

begin

  if(   (g_ck_user_role_name is not NULL)
     and (g_ck_user_role_name = p_user_name)) then
    return g_ck_user_role_result;
  end if;


      --Changes for Bug#3867925
      -- Fix Non Backward change made for universal person support
      colon := instr(p_user_name, 'PER:');
      if (colon <> 0) then
         -- Fix for bug 4308825: This code was preventing global grantee type
         -- grants from working in the PER case, so it's commented out.
         -- select 1
         -- into l_dummy
         -- from fnd_grants
         -- where rownum = 1
         -- and grantee_type = 'USER'
         -- and grantee_key = p_user_name;
         null;
      else
         select 1
         into l_dummy
         from wf_user_roles
         where user_name = p_user_name
         and rownum = 1;
      end if;

      g_ck_user_role_result := 'T';
      g_ck_user_role_name := p_user_name;
      return g_ck_user_role_result;

  exception when no_data_found then
    g_ck_user_role_result := 'F';
    g_ck_user_role_name := p_user_name;
    return g_ck_user_role_result;

end CHECK_USER_ROLE;

 ---This is an internal procedure. Not for general use.
 --   Gets the user_name bind value, e.g.
 --    SYS_CONTEXT('FND','USER_NAME')
 --   This will return references to the sys_context rather
 --   than literal values if it can, so that a statement
 --   can be reused without parsing.
 -----------------------------------------------
procedure get_name_bind(p_user_name in VARCHAR2,
                      x_user_name_bind      out NOCOPY varchar2) is
   l_api_name         CONSTANT VARCHAR2(30) := 'GET_NAME_BIND';
   colon pls_integer;
   l_unfound BOOLEAN;
   x_user_id number;
   x_is_per_person number;
begin

   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name|| '(' ||
          'p_user_name =>'|| p_user_name ||');');
   end if;

   if ((p_user_name is NULL) or (p_user_name = 'GLOBAL')) then
     x_user_name_bind := ''''|| replace(p_user_name, '''','''''')||'''';
     if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
           c_log_head || l_api_name || '.end_quick',
            'returning NULLs for user_name bind.');
     end if;
     return;
   end if;

   if (p_user_name =  SYS_CONTEXT('FND','USER_NAME')) then
     x_user_name_bind := 'SYS_CONTEXT(''FND'',''USER_NAME'')';
     if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
         c_log_head || l_api_name || '.end_global_user_name',
         'returning x_user_name_bind:' || x_user_name_bind);
     end if;
     return;
   else
     x_user_name_bind := ''''||replace(p_user_name, '''', '''''')||'''';
     if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
         c_log_head || l_api_name || '.end_literal',
         'returning x_user_name_bind:' || x_user_name_bind);
     end if;
     return;
   end if;

   /* This line should never be reached. */
   if (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
     fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
            c_log_head || l_api_name || '.end_interr',
             'Internal Error.  This line should not be executed.');
   end if;
   x_user_name_bind := 'ERROR_IN_GET_NAME_BIND';
   return;

end;



 ---This is an internal procedure. Not for general use.
 --   Gets the orig_system_id and orig_system from wf_roles,
 --   given the user_name.
 --   This is around mostly for backward compatibility with our
 --   grants loader, but we may eliminate even that use and this
 --   routine may disappear entirely, so outside code should
 --   not call it or their code will break in the future.
 -----------------------------------------------
-- DEPRECATED    DEPRECATED     DEPRECATED     DEPRECATED     DEPRECATED
procedure get_orig_key(p_user_name in VARCHAR2,
                      x_orig_system    out NOCOPY varchar2,
                      x_orig_system_id out NOCOPY NUMBER)
is
   l_api_name             CONSTANT VARCHAR2(30) := 'GET_ORIG_KEY';
   colon pls_integer;
begin
   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name|| '(' ||
          'p_user_name =>'|| p_user_name ||');');
   end if;

   if (fnd_data_security.DISALLOW_DEPRECATED = 'Y') then
              /* In R12 this routine is deprecated, because it effectively */
              /* does a blind query, potentially returning zillions of */
              /* records, which is unsupportable from a performance */
              /* perspective. */
              /* So we raise a runtime exception to help people to know */
              /* they need to change their code. */
              fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
              fnd_message.set_token('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
              fnd_message.set_token('REASON',
                    'Invalid API call.  API '
                    ||c_pkg_name || '.'|| l_api_name ||
                    ' is desupported and should not be called in R12.'||
                    ' Any product team that calls it '||
                    'must correct their code because it does not work '||
                    'correctly.  Please see the deprecated API document at '||
                    'http://files.oraclecorp.com/content/AllPublic/'||
                    'SharedFolders/ATG%20Requirements-Public/R12/'||
                    'Requirements%20Definition%20Document/'||
                    'Application%20Object%20Library/DeprecatedApiRDD.doc '||
                    'Oracle employees who encounter this error should log '||
                    'a bug against the product that owns the call to this '||
                    'routine');
              if (fnd_log.LEVEL_EXCEPTION >=
                      fnd_log.g_current_runtime_level) then
                  fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.end_unsupported',
                     FALSE);
              end if;
              fnd_message.raise_error;
   end if;

   x_orig_system := NULL;
   x_orig_system_id := NULL;

   /* Note that this logic is written to accomodate VGEORGE's case where*/
   /* the grantee_type is 'GLOBAL' but the grantee_key is something */
   /* parsable. */
   if ((p_user_name is NULL) or (p_user_name = 'GLOBAL')) then
     if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
           c_log_head || l_api_name || '.end_quick',
            'returning NULLs for x_orig_system and x_orig_system_id');
     end if;
     return;
   end if;


   /* This routine may not perform as well as the old implementation of*/
   /* our get_orig_key() but since it's only called when uploading grants*/
   /* now this should suffice. */
   wf_directory.GetRoleOrigSysInfo(
      Role => p_user_name,
      Orig_System => x_orig_system,
      Orig_System_Id => x_orig_system_id);

   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
         c_log_head || l_api_name || '.end',
          'returning x_orig_system:' || x_orig_system ||
          'x_orig_system_id:'||to_char(x_orig_system_id));
   end if;
end;



---This is an internal function. Not in spec
---Function get_object_id
------------------------------
Function get_object_id(p_object_name in varchar2
                       ) return number is
v_object_id number;
l_api_name             CONSTANT VARCHAR2(30) := 'GET_OBJECT_ID';
Begin
   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name|| '(' ||
          'p_object_name =>'|| p_object_name ||');');
   end if;
   if (p_object_name = g_obj_name_cache) then
      v_object_id := g_obj_id_cache; /* If we have it cached, use value */
   else    /* not cached, hit db */
      select object_id
      into v_object_id
      from fnd_objects
      where obj_name=p_object_name;

      /* Store in cache */
      g_obj_id_cache := v_object_id;
      g_obj_name_cache := p_object_name;
   end if;

   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
         c_log_head || l_api_name || '.end',
          'returning v_object_id:' || v_object_id);
   end if;
   return v_object_id;
exception
   when no_data_found then
     if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end_null',
          'returning null');
     end if;
     return null;
end;

---This is an internal function. Not in spec
---Function get_function_id
------------------------------
Function get_function_id(p_function_name in varchar2
                       ) return number is
v_function_id number;
l_api_name             CONSTANT VARCHAR2(30) := 'GET_FUNCTION_ID';
Begin
   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name|| '(' ||
          'p_function_name =>'|| p_function_name ||');');
   end if;

   if (p_function_name = g_func_name_cache) then
      v_function_id := g_func_id_cache; /* If we have it cached, use value */
   else    /* not cached, hit db */
      select function_id
      into v_function_id
      from fnd_form_functions
      where function_name=p_function_name;

      /* Store in cache */
      g_func_id_cache := v_function_id;
      g_func_name_cache := p_function_name;
   end if;


   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
         c_log_head || l_api_name || '.end',
          'returning v_function_id:' || v_function_id);
   end if;
   return v_function_id;
exception
   when no_data_found then
     if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end_null',
          'returning null');
     end if;
     return null;
end;

-- get_to_char-
-- This is an internal procedure not in spec.
------------------------------
function get_to_char(x_column_name in varchar2,
                             x_column_type in varchar2) return varchar2 is
  retval varchar2(255);
begin
  /* INTEGER type... no format mask needed.  NUMBER is an obsolete type */
  /* that we support like INTEGER for backward compatibility. */
  if (x_column_type = 'INTEGER') or (x_column_type = 'NUMBER') then
    retval := 'TO_CHAR('||x_column_name||')';
  elsif (x_column_type = 'FLOAT') then
    retval := 'TO_CHAR('||x_column_name||
              ', ''FM999999999999999999999.99999999999999999999'')';
  elsif (x_column_type = 'DATE') then
    retval := 'TO_CHAR('||x_column_name||', ''YYYY/MM/DD HH24:MI:SS'')';
  else
    retval := '/* ERROR_UNK_TYPE:'||x_column_type
              ||' */ TO_CHAR('||x_column_name||')';
  end if;
  return retval;
end;

 ---This is an internal procedure. Not in spec.
 -- Procedure get_pk_information
 --   x_pk_column returns the aliased list of columns without
 --      type conv.
 --   x_ik_clause returns the clause of the where statement for
 --      instance grants, which looks something like this:
 --      ((gnt.instance_type = 'INSTANCE')
 --        AND
 --      (TO_NUMBER(gnt.instance_pk1_value) = objtab.pk_id)
 --        AND
 --      (TO_NUMBER(gnt.instance_pk2_value) = objtab.pk_app_id)
 --      )
 --   x_orig_pk_column returns the list of columns
 --      without the table aliases (X.)
 --  returns 'T' for success or 'U' for unexpected error.
 -----------------------------------------------
function get_pk_information(p_object_name in VARCHAR2,
                             x_pk1_column_name out NOCOPY varchar2,
                             x_pk2_column_name out NOCOPY varchar2,
                             x_pk3_column_name out NOCOPY varchar2,
                             x_pk4_column_name out NOCOPY varchar2,
                             x_pk5_column_name out NOCOPY varchar2,
                             x_pk_column out NOCOPY varchar2,
                             x_ik_clause out NOCOPY varchar2,
                             x_exact_clause out NOCOPY varchar2,
                             x_orig_pk_column    out NOCOPY varchar2,
                             x_database_object_name out NOCOPY varchar2,
                             x_table_alias     in varchar2,
                             x_grant_alias     in varchar2)
return VARCHAR2 IS
l_api_name             CONSTANT VARCHAR2(30) := 'GET_PK_INFORMATION';
x_pk1_column_type varchar2(8);
x_pk2_column_type varchar2(8);
x_pk3_column_type varchar2(8);
x_pk4_column_type varchar2(8);
x_pk5_column_type varchar2(8);
l_table_alias     varchar2(255);
l_grant_alias     varchar2(255);
cursor c_pk is
    SELECT pk1_column_name
            ,pk2_column_name
           ,pk3_column_name
           ,pk4_column_name
           ,pk5_column_name
           ,pk1_column_type
           ,pk2_column_type
           ,pk3_column_type
           ,pk4_column_type
           ,pk5_column_type
           , database_object_name
    FROM fnd_objects
    WHERE obj_name=p_object_name  ;
begin
   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name|| '(' ||
          'p_object_name=>'|| p_object_name ||
          'x_table_alias=>'|| x_table_alias ||
          'x_grant_alias=>'|| x_grant_alias
          ||');');
   end if;

   if(x_table_alias is NULL) then
     l_table_alias := NULL;
   else
     l_table_alias := x_table_alias || '.';
   end if;

   if(x_grant_alias is NULL) then
     l_grant_alias := NULL;
   else
     l_grant_alias := x_grant_alias || '.';
   end if;

   open c_pk;
   fetch c_pk into
   x_pk1_column_name ,
   x_pk2_column_name ,
   x_pk3_column_name ,
   x_pk4_column_name ,
   x_pk5_column_name ,
   x_pk1_column_type ,
   x_pk2_column_type ,
   x_pk3_column_type ,
   x_pk4_column_type ,
   x_pk5_column_type ,
   x_database_object_name;

   IF(c_pk%NOTFOUND) THEN
       fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
       fnd_message.set_token('ROUTINE',
                                c_pkg_name || '.'|| l_api_name);
       fnd_message.set_token('REASON',
                    'FND_OBJECTS does not have column obj_name with value:'||
                     p_object_name);
       if (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
         fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.bad_objname',
                     FALSE);
       end if;
       if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
            c_log_head || l_api_name || '.end_bad_objname',
            'returning: ' ||'U');
       end if;
       return 'U';
   end if;

   CLOSE c_pk;

   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.after_fetch',
          ' x_pk1_column_name: '|| x_pk1_column_name||
          ' x_pk2_column_name: '|| x_pk2_column_name||
          ' x_pk3_column_name: '|| x_pk3_column_name||
          ' x_pk4_column_name: '|| x_pk4_column_name||
          ' x_pk5_column_name: '|| x_pk5_column_name||
          ' x_pk1_column_type: '|| x_pk1_column_type||
          ' x_pk2_column_type: '|| x_pk2_column_type||
          ' x_pk3_column_type: '|| x_pk3_column_type||
          ' x_pk4_column_type: '|| x_pk4_column_type||
          ' x_pk5_column_type: '|| x_pk5_column_type||
          ' x_database_object_name: '|| x_database_object_name);
   end if;


   -- Build up the list of column names without 'X.' (table alias)
   x_orig_pk_column := NULL;
   if(    (x_pk1_column_name is not NULL)
      AND (x_pk1_column_name <> C_NULL_STR)) then
      x_orig_pk_column := x_orig_pk_column ||x_pk1_column_name;
   end if;
   if(    (x_pk2_column_name is not NULL)
      AND (x_pk2_column_name <> C_NULL_STR)) then
      x_orig_pk_column := x_orig_pk_column || ', ' || x_pk2_column_name;
   end if;
   if(    (x_pk3_column_name is not NULL)
      AND (x_pk3_column_name <> C_NULL_STR)) then
      x_orig_pk_column := x_orig_pk_column || ', ' || x_pk3_column_name;
   end if;
   if(    (x_pk4_column_name is not NULL)
      AND (x_pk4_column_name <> C_NULL_STR)) then
      x_orig_pk_column := x_orig_pk_column || ', ' || x_pk4_column_name;
   end if;
   if(    (x_pk5_column_name is not NULL)
      AND (x_pk5_column_name <> C_NULL_STR)) then
      x_orig_pk_column := x_orig_pk_column || ', ' || x_pk5_column_name;
   end if;



   -- Build up the x_pk_column and x_ik_clause lists
   -- by adding values for each column name.
   x_ik_clause :=  '(('||l_grant_alias||'INSTANCE_TYPE = ''INSTANCE'')';
   x_exact_clause :=  '(';

   if (   (x_pk1_column_name is not null)
      AND (x_pk1_column_name <> C_NULL_STR))then
       x_pk_column := x_pk_column||l_table_alias||x_pk1_column_name;
       x_ik_clause := x_ik_clause||' AND ('||l_grant_alias
                       ||'INSTANCE_PK1_VALUE' ||
                       ' = '||get_to_char(l_table_alias|| x_pk1_column_name,
                                           x_pk1_column_type)
                       || ')';
       x_exact_clause :=  x_exact_clause||
                      ' ( :pk1 = '||l_table_alias|| x_pk1_column_name || ')';
    if (     (x_pk2_COLUMN_name is not null)
         AND (x_pk2_column_name <> C_NULL_STR)) then
         x_pk_column:=
          x_pk_column||', '||l_table_alias||x_pk2_COLUMN_name;
         x_ik_clause := x_ik_clause||' AND ('||
                               l_grant_alias ||'INSTANCE_PK2_VALUE'||
                               ' = '||get_to_char(l_table_alias
                               || x_pk2_column_name,  x_pk2_column_type)
                               || ')';
         x_exact_clause :=  x_exact_clause||
                            ' AND ( :pk2 = '||l_table_alias
                                    || x_pk2_column_name || ')';
      if (    (x_pk3_COLUMN_name is not null)
          AND (x_pk3_column_name <> C_NULL_STR)) then
           x_pk_column :=
            x_pk_column||', '||l_table_alias||x_pk3_COLUMN_name;
           x_ik_clause := x_ik_clause||' AND ('||l_grant_alias
                            ||'INSTANCE_PK3_VALUE'||
                            ' = '||get_to_char(l_table_alias||
                                                x_pk3_column_name,
                                               x_pk3_column_type)
                            || ')';
           x_exact_clause :=  x_exact_clause||
                            ' AND ( :pk3 = '||l_table_alias
                                 || x_pk3_column_name || ')';
         if (    (x_pk4_COLUMN_name is not null)
             AND (x_pk4_column_name <> C_NULL_STR))  then
              x_pk_column:=
               x_pk_column||', '||l_table_alias||x_pk4_COLUMN_name;
              x_ik_clause := x_ik_clause||' AND ('||
                            l_grant_alias
                            ||'INSTANCE_PK4_VALUE'||
                            ' = '||get_to_char(l_table_alias||
                                               x_pk4_column_name,
                                               x_pk4_column_type)
                            || ')';
              x_exact_clause := x_exact_clause||
                              ' AND ( :pk4 = '||l_table_alias
                                     || x_pk4_column_name || ')';
            if (    (x_pk5_COLUMN_name is not null)
                AND (x_pk5_column_name <> C_NULL_STR)) then
                 x_pk_column:=
                  x_pk_column||', '||l_table_alias||x_pk5_COLUMN_name;
                 x_ik_clause := x_ik_clause||' AND ('|| l_grant_alias
                                      ||'INSTANCE_PK5_VALUE'||
                   ' = '||get_to_char(l_table_alias|| x_pk5_column_name,
                                       x_pk5_column_type)
                   || ')';
                 x_exact_clause :=  x_exact_clause||
                           ' AND ( :pk5 = '||l_table_alias
                                  || x_pk5_column_name || ')';
            end if;
         end if;
      end if;
   end if;
   end if;

   x_ik_clause := x_ik_clause||' )';
   x_exact_clause :=  x_exact_clause||' )';

   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end',
          'returning: ' ||
          ' p_object_name=>'|| p_object_name ||','||
          ' x_pk1_column_name=>'|| x_pk1_column_name ||','||
          ' x_pk2_column_name=>'|| x_pk2_column_name ||','||
          ' x_pk3_column_name=>'|| x_pk3_column_name ||','||
          ' x_pk4_column_name=>'|| x_pk4_column_name ||','||
          ' x_pk5_column_name=>'|| x_pk5_column_name  ||','||
          ' x_pk_column=>'|| x_pk_column ||','||
          ' x_ik_clause=>'|| x_ik_clause ||','||
          ' x_exact_clause=>'|| x_exact_clause ||','||
          ' x_orig_pk_column=>'|| x_orig_pk_column ||','||
          ' x_database_object_name=>'|| x_database_object_name);
   end if;
   return 'T';
end;

------Function check_global_object_grant-------------
-- Is a particular function granted globally to all objects or a
--  particular object in the current context?
--  passing 'GLOBAL' for object_name means check global object type grants
FUNCTION check_global_object_grant
  (
   p_api_version         IN NUMBER,
   p_function            IN VARCHAR2,
   p_user_name           in varchar2,
   p_object_name         in varchar2
 )
 RETURN VARCHAR2 IS

    l_api_version          CONSTANT NUMBER := 1.0;
    l_api_name             CONSTANT VARCHAR2(30) :='CHECK_GLOBAL_OBJECT_GRANT';
    l_sysdate              DATE := Sysdate;
    dummy_item_id          NUMBER;
    l_result               VARCHAR2(1);
    l_return_status        varchar2(1);
    result                 varchar2(30);
    l_nrows                pls_integer;
    l_object_id            NUMBER;
    colon                  pls_integer;
    l_function_id          number;
    l_user_name            varchar2(80);

    -- Performance bug 5080621. Flipped the order of 'union all' to do
    -- select 'GLOBAL' from dual first.
    -- Done similar changes in the following cursors also.
    -- instance_set_grants_c (in get_security_predicate_helper api)
    -- isg_grp_glob_fn_c (in get_security_predicate_intrnl api)
    -- isg_grp_glob_nofn_c (in get_security_predicate_intrnl api)

    CURSOR global_grants_c(  cp_user_name       varchar2,
                               cp_function_id   NUMBER,
                               cp_sysdate  DATE,
                               cp_object_id in NUMBER
                               )  IS
    SELECT  /*+ leading(u2) use_nl(g) index(g,FND_GRANTS_N9) */ 'X'
      FROM
       ( select /*+ NO_MERGE */ 'GLOBAL' role_name from dual
          union all
         select role_name
         from wf_user_roles wur,
           (
           select cp_user_name name from dual
             union all
           select incr1.name name
             from wf_local_roles incr1, fnd_user u1
            where 'HZ_PARTY'           = incr1.orig_system
              and u1.user_name         = cp_user_name
              and u1.person_party_id   = incr1.orig_system_id
              and incr1.partition_id  = 9 /* HZ_PARTY */
            ) incr2
         where wur.user_name = incr2.name
        ) u2,
        fnd_grants g
    WHERE rownum = 1
      AND g.grantee_key = u2.role_name
      AND g.menu_id in
               (select cmf.menu_id
                 from fnd_compiled_menu_functions cmf
                where cmf.function_id = cp_function_id)
      AND(   g.ctx_secgrp_id    = -1
          OR g.ctx_secgrp_id    =  SYS_CONTEXT('FND','SECURITY_GROUP_ID'))
      AND(   g.ctx_resp_id      = -1
          OR g.ctx_resp_id      =  SYS_CONTEXT('FND','RESP_ID'))
      AND(   g.ctx_resp_appl_id = -1
          OR g.ctx_resp_appl_id =  SYS_CONTEXT('FND','RESP_APPL_ID'))
      AND(   g.ctx_org_id       = -1
          OR g.ctx_org_id       =  SYS_CONTEXT('FND', 'ORG_ID'))
      AND
       (   g.end_date  IS NULL
        OR g.end_date >= cp_sysdate )
      AND
       g.start_date <= cp_sysdate
      AND
         (   (g.instance_type = 'GLOBAL')
         AND (g.object_id =  cp_object_id))
      ;

    --Changes for Bug#3867925
    -- Fix Non Backward change made for universal person support
    --
    -- Performance note: This statement has not received the optimizations
    -- to the WF User portion of the SQL because the separation of the
    -- USER and GROUP clauses prevent that.  Since this is only used for
    -- deprecated code that is okay.
    CURSOR global_grants_bkwd_c (  cp_user_name       varchar2,
                                   cp_function_id   NUMBER,
                                   cp_sysdate  DATE,
                                   cp_object_id in NUMBER
                                 )
    IS
           SELECT 'X'
           FROM fnd_grants g
           WHERE rownum = 1
            AND(
               (    g.grantee_type = 'USER'
                and g.grantee_key =  cp_user_name)
            OR (g.grantee_type = 'GROUP'
                and (g.grantee_key in
                  (select role_name
                   from wf_user_roles wur
                  where wur.user_name in
                   ( (select cp_user_name from dual)
                          union all
                     (select incrns.name from wf_local_roles incrns, fnd_user f
                       where 'HZ_PARTY'        = incrns.orig_system
                         and f.user_name       = cp_user_name
                         and f.person_party_id = incrns.orig_system_id)))))
            OR (g.grantee_type = 'GLOBAL'))
            AND g.menu_id in
                     (select cmf.menu_id
                       from fnd_compiled_menu_functions cmf
                      where cmf.function_id = cp_function_id)
            AND(   g.ctx_secgrp_id    = -1
                OR g.ctx_secgrp_id    = SYS_CONTEXT('FND','SECURITY_GROUP_ID'))
            AND(   g.ctx_resp_id      = -1
                OR g.ctx_resp_id      =  SYS_CONTEXT('FND','RESP_ID'))
            AND(   g.ctx_resp_appl_id = -1
                OR g.ctx_resp_appl_id =  SYS_CONTEXT('FND','RESP_APPL_ID'))
            AND(   g.ctx_org_id       = -1
                OR g.ctx_org_id       =  SYS_CONTEXT('FND', 'ORG_ID'))
            AND
             (   g.end_date  IS NULL
              OR g.end_date >= cp_sysdate )
            AND
             g.start_date <= cp_sysdate
            AND
               (   (g.instance_type = 'GLOBAL')
               AND (g.object_id = cp_object_id));


    -- This cursor is the same as the global_grants_c above except the
    -- clause for GLOBAL grantee_key is removed, because the guest
    -- user should not have access to global grants.
    CURSOR global_grants_guest_c (  cp_user_name       varchar2,
                                    cp_function_id   NUMBER,
                                    cp_sysdate  DATE,
                                    cp_object_id in NUMBER
                                  )
    IS
    SELECT  /*+ leading(u2) use_nl(g) index(g,FND_GRANTS_N9) */ 'X'
      FROM
       ( select /*+ NO_MERGE */  role_name
         from wf_user_roles wur,
           (
           select cp_user_name name from dual
             union all
           select incr1.name name
             from wf_local_roles incr1, fnd_user u1
            where 'HZ_PARTY'           = incr1.orig_system
              and u1.user_name         = cp_user_name
              and u1.person_party_id   = incr1.orig_system_id
              and incr1.partition_id  = 9 /* HZ_PARTY */
            ) incr2
         where  wur.user_name = incr2.name
        ) u2,
        fnd_grants g
    WHERE rownum = 1
      AND g.grantee_key = u2.role_name
      AND g.menu_id in
               (select cmf.menu_id
                 from fnd_compiled_menu_functions cmf
                where cmf.function_id = cp_function_id)
      AND(   g.ctx_secgrp_id    = -1
          OR g.ctx_secgrp_id    =  SYS_CONTEXT('FND','SECURITY_GROUP_ID'))
      AND(   g.ctx_resp_id      = -1
          OR g.ctx_resp_id      =  SYS_CONTEXT('FND','RESP_ID'))
      AND(   g.ctx_resp_appl_id = -1
          OR g.ctx_resp_appl_id =  SYS_CONTEXT('FND','RESP_APPL_ID'))
      AND(   g.ctx_org_id       = -1
          OR g.ctx_org_id       =  SYS_CONTEXT('FND', 'ORG_ID'))
      AND
       (   g.end_date  IS NULL
        OR g.end_date >= cp_sysdate )
      AND
       g.start_date <= cp_sysdate
      AND
         (   (g.instance_type = 'GLOBAL')
         AND (g.object_id =  cp_object_id))
      ;

   BEGIN
       if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name|| '(' ||
          ' p_api_version=>'|| to_char(p_api_version) ||','||
          ' p_function=>'|| p_function ||','||
          ' p_user_name=>'|| p_user_name ||');');
        end if;

        -- check for call compatibility.
        if TRUNC(l_api_version) <> TRUNC(p_api_version) THEN
               fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
               fnd_message.set_token('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
               fnd_message.set_token('REASON',
                    'Unsupported version '|| to_char(p_api_version)||
                    ' passed to API; expecting version '||
                    to_char(l_api_version));
               if (fnd_log.LEVEL_EXCEPTION >=
                   fnd_log.g_current_runtime_level) then
                 fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.end_bad_api_ver',
                     FALSE);
               end if;
               return 'U';
        END IF;

        -- Check for null arguments.
        if (p_function is NULL) THEN
               fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
               fnd_message.set_token('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
               fnd_message.set_token('REASON',
                     'NULL value passed for p_function:'||p_function);

               if (fnd_log.LEVEL_EXCEPTION >=
                   fnd_log.g_current_runtime_level) then
                 fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.end_bad_param',
                     FALSE);
               end if;
               return 'U';
        END IF;

        /* Make sure that the FND_COMPILED_MENU_FUNCTIONS table is compiled */
        if (FND_FUNCTION.G_ALREADY_FAST_COMPILED <> 'T') then
          FND_FUNCTION.FAST_COMPILE;
        end if;

        /* Convert object name to id */
        if (p_object_name = 'GLOBAL') then
           l_object_id := -1;
        else
           l_object_id := get_object_id(p_object_name);
           if (l_object_id is NULL) THEN
             fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
             fnd_message.set_token('ROUTINE',
                                      c_pkg_name || '.'|| l_api_name);
             fnd_message.set_token('REASON',
                  'The parameter value p_object_name is not a valid object.'||
                  ' p_object_name:'||p_object_name);
             if (fnd_log.LEVEL_EXCEPTION >=
                 fnd_log.g_current_runtime_level) then
               fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                   c_log_head || l_api_name || '.end_bad_obj',
                   FALSE);
             end if;
             return 'U';
           END IF;
        end if;

        -- Default the user name if not passed in.
        if(p_user_name is NULL) then
           l_user_name :=  SYS_CONTEXT('FND','USER_NAME');
        else
           if (    (fnd_data_security.DISALLOW_DEPRECATED = 'Y')
               and (substr(p_user_name, 1, LENGTH('GET_MNUIDS_NBVCXDS')) <>
                 'GET_MNUIDS_NBVCXDS')
               and (   (p_user_name <> SYS_CONTEXT('FND','USER_NAME'))
                    or (     (p_user_name is not null)
                         and (SYS_CONTEXT('FND','USER_NAME') is null)))) then
              /* In R12 we do not allow passing values other than */
              /* the current user name (which is the default), */
              /* so we raise a runtime exception if that deprecated */
              /* kind of call is made to this routine. */
              fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
              fnd_message.set_token('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
              fnd_message.set_token('REASON',
                    'Invalid API call.  Parameter p_user_name: '||p_user_name||
                    ' was passed to API '||c_pkg_name || '.'|| l_api_name ||
                    '.  p_object_name: '||p_object_name||'.  '||
                    ' In Release 12 and beyond the p_user_name parameter '||
                    'is unsupported, and any product team that passes it '||
                    'must correct their code because it does not work '||
                    'correctly.  Please see the deprecated API document at '||
                    'http://files.oraclecorp.com/content/AllPublic/'||
                    'SharedFolders/ATG%20Requirements-Public/R12/'||
                    'Requirements%20Definition%20Document/'||
                    'Application%20Object%20Library/DeprecatedApiRDD.doc '||
                    'Oracle employees who encounter this error should log '||
                    'a bug against the product that owns the call to this '||
                    'routine, which is likely the owner of the object that '||
                    'was passed to this routine: '||
                    p_object_name);
              if (fnd_log.LEVEL_EXCEPTION >=
                      fnd_log.g_current_runtime_level) then
                fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.end_depr_param',
                     FALSE);
              end if;
              fnd_message.raise_error;
           end if;
           l_user_name := p_user_name;
        end if;

        -- look up function id from function name
        l_function_id:=get_function_id(p_function);
        if (l_function_id is NULL) THEN
            fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
            fnd_message.set_token('ROUTINE',
                                      c_pkg_name || '.'|| l_api_name);
            fnd_message.set_token('REASON',
               'The parameter value p_function is not a valid function name.'||
               ' p_function:'||p_function);
            if (fnd_log.LEVEL_EXCEPTION >=
                fnd_log.g_current_runtime_level) then
              fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                  c_log_head || l_api_name || '.end_bad_func',
                  FALSE);
            end if;
            return 'U';
        END IF;

        IF (l_user_name <> 'GUEST') THEN
          --Changes for Bug#3867925
          -- Fix Non Backward change made for universal person support
          colon := instr(p_user_name, 'PER:');
          if (colon <> 0) then
             OPEN global_grants_bkwd_c (cp_user_name   => l_user_name,
                                        cp_function_id => l_function_id,
                                        cp_sysdate     => l_sysdate,
                                        cp_object_id   => l_object_id);

               if (fnd_log.LEVEL_STATEMENT >=
                                fnd_log.g_current_runtime_level) then
                  fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                                 c_log_head||l_api_name||
                                     '.open_grants_bkwd_cursor',
                                 ' cp_user_name: '|| l_user_name||
                                 ' cp_function_id: '|| l_function_id||
                                 ' l_sysdate: '|| to_char(l_sysdate)||
                                 ' cp_object_id: '|| l_object_id);
               end if;

              FETCH global_grants_bkwd_c INTO l_result;
              CLOSE global_grants_bkwd_c;
          else
             OPEN global_grants_c (cp_user_name   => l_user_name,
                                   cp_function_id => l_function_id,
                                   cp_sysdate     => l_sysdate,
                                   cp_object_id   => l_object_id);
             if (fnd_log.LEVEL_STATEMENT >=
                     fnd_log.g_current_runtime_level) then
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                c_log_head || l_api_name || '.open_grants_cursor',
                ' cp_user_name: '|| l_user_name||
                ' cp_function_id: '|| l_function_id||
                ' l_sysdate: '|| to_char(l_sysdate)||
                ' cp_object_id: '|| l_object_id);
              end if;

              FETCH global_grants_c INTO l_result;
              CLOSE global_grants_c;
          end if;
        ELSE
         OPEN global_grants_guest_c (cp_user_name   => l_user_name,
                                     cp_function_id => l_function_id,
                                     cp_sysdate     => l_sysdate,
                                     cp_object_id   => l_object_id);
         if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
            c_log_head || l_api_name || '.open_grants_guest_cursor',
            ' cp_user_name: '|| l_user_name||
            ' cp_function_id: '|| l_function_id||
            ' l_sysdate: '|| to_char(l_sysdate)||
            ' cp_object_id: '|| l_object_id);
          end if;

         FETCH global_grants_guest_c INTO l_result;
         CLOSE global_grants_guest_c;

        END IF;

        if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
            c_log_head || l_api_name || '.fetch_instance_grants',
            ' l_result:'||l_result);
        end if;
        IF (l_result = 'X') THEN
           if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
             fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
              c_log_head || l_api_name || '.end_inst_grant',
              'T');
            end if;
            RETURN  'T';
        ELSE

            if (fnd_log.LEVEL_PROCEDURE >=
                fnd_log.g_current_runtime_level) then
                fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                  c_log_head || l_api_name || '.end_no_inst','F');
            end if;
            RETURN  'F';
        END IF;


   EXCEPTION
         /* If API called with deprecated p_user_name arg, */
         /* propagate that up so the caller gets exception */
         WHEN FND_MESSAGE_RAISED_ERR THEN
             /* Re raise the error for the caller */
             fnd_message.raise_error;
             return 'U'; /* This line should never be executed */

         WHEN OTHERS THEN
             fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
             fnd_message.set_token('ROUTINE',
                                    c_pkg_name||','||l_api_name);
             fnd_message.set_token('ERRNO', SQLCODE);
             fnd_message.set_token('REASON', SQLERRM);

             if (fnd_log.LEVEL_EXCEPTION >=
                 fnd_log.g_current_runtime_level) then
               fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.other_err',
                     FALSE);
             end if;
             if (fnd_log.LEVEL_PROCEDURE >=
                 fnd_log.g_current_runtime_level) then
               fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                 c_log_head || l_api_name || '.end_after_other',
                 'U' );
             end if;
             RETURN 'U';
  END check_global_object_grant;
  -----------------------------------------------------------------

------Function check_global_object_type_grant-------------
-- Is a particular function granted globally to all objects in
-- the current context?
FUNCTION check_global_object_type_grant
  (
   p_api_version         IN  NUMBER,
   p_function            IN  VARCHAR2,
   p_user_name           in varchar2
 )
 RETURN VARCHAR2 IS

    l_api_version          CONSTANT NUMBER := 1.0;
    l_api_name             CONSTANT VARCHAR2(30) :=
                              'CHECK_GLOBAL_OBJECT_TYPE_GRANT';
    l_result                  varchar2(30);
   BEGIN
       if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
           c_log_head || l_api_name || '.begin',
           c_pkg_name || '.' ||l_api_name|| '(' ||
           ' p_api_version=>'|| to_char(p_api_version) ||','||
           ' p_function=>'|| p_function ||','||
           ' p_user_name=>'|| p_user_name ||');');
        end if;

        -- check for call compatibility.
        if TRUNC(l_api_version) <> TRUNC(p_api_version) THEN
               fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
               fnd_message.set_token('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
               fnd_message.set_token('REASON',
                    'Unsupported version '|| to_char(p_api_version)||
                    ' passed to API; expecting version '||
                    to_char(l_api_version));
               if (fnd_log.LEVEL_EXCEPTION >=
                   fnd_log.g_current_runtime_level) then
                 fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.end_bad_api_ver',
                     FALSE);
               end if;
               return 'U';
        END IF;

        l_result := check_global_object_grant
                  ( 1.0,
                    p_function,
                    p_user_name,
                    'GLOBAL');

        if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
            c_log_head || l_api_name || '.end',
            l_result);
        end if;

        RETURN  l_result;
  END check_global_object_type_grant;
  -----------------------------------------------------------------

------Function check_function-------------
FUNCTION check_function
  (
   p_api_version         IN  NUMBER,
   p_function            IN  VARCHAR2,
   p_object_name         IN  VARCHAR2,
   p_instance_pk1_value  IN  VARCHAR2,
   p_instance_pk2_value  IN  VARCHAR2,
   p_instance_pk3_value  IN  VARCHAR2,
   p_instance_pk4_value  IN  VARCHAR2,
   p_instance_pk5_value  IN  VARCHAR2,
   p_user_name           in varchar2
 )
 RETURN VARCHAR2 IS

    l_api_version          CONSTANT NUMBER := 1.0;
    l_api_name             CONSTANT VARCHAR2(30) := 'CHECK_FUNCTION';
    l_sysdate              DATE := Sysdate;
    l_predicate            VARCHAR2(32767);
    dummy_item_id          NUMBER;
    dynamic_sql            VARCHAR2(32767);
    l_db_object_name       varchar2(30);
    l_db_pk1_column         varchar2(256);
    l_db_pk2_column         varchar2(256);
    l_db_pk3_column         varchar2(256);
    l_db_pk4_column         varchar2(256);
    l_db_pk5_column         varchar2(256);
    l_pk_column_names       varchar2(512);
    l_pk_orig_column_names  varchar2(512);
    l_ik_clause  varchar2(2048);
    l_exact_clause  varchar2(2048);
    l_result  VARCHAR2(1);
    l_return_status varchar2(1);
    result                  varchar2(30);
    l_nrows                   pls_integer;
    l_instance_pk1_value      varchar2(256);
    l_instance_pk2_value      varchar2(256);
    l_instance_pk3_value      varchar2(256);
    l_instance_pk4_value      varchar2(256);
    l_instance_pk5_value      varchar2(256);
    l_bind_pk1                boolean := FALSE;
    l_bind_pk2                boolean := FALSE;
    l_bind_pk3                boolean := FALSE;
    l_bind_pk4                boolean := FALSE;
    l_bind_pk5                boolean := FALSE;

    l_object_id number := NULL;
    l_function_id number := NULL;
    l_user_name varchar2(80);
    l_cursor int;
    l_rows_processed number;
    i number;
    l_bind_order varchar2(256);
   BEGIN

       if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name|| '(' ||
          ' p_api_version=>'|| to_char(p_api_version) ||','||
          ' p_function=>'|| p_function ||','||
          ' p_object_name=>'|| p_object_name ||','||
          ' p_instance_pk1_value=>'|| p_instance_pk1_value ||','||
          ' p_instance_pk2_value=>'|| p_instance_pk2_value ||','||
          ' p_instance_pk3_value=>'|| p_instance_pk3_value ||','||
          ' p_instance_pk4_value=>'|| p_instance_pk4_value ||','||
          ' p_instance_pk5_value=>'|| p_instance_pk5_value ||','||
          ' p_user_name=>'|| p_user_name ||');');
        end if;

        -- check for call compatibility.
        if TRUNC(l_api_version) <> TRUNC(p_api_version) THEN
              fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
              fnd_message.set_token('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
              fnd_message.set_token('REASON',
                    'Unsupported version '|| to_char(p_api_version)||
                    ' passed to API; expecting version '||
                    to_char(l_api_version));

               if (fnd_log.LEVEL_EXCEPTION >=
                   fnd_log.g_current_runtime_level) then
                 fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.end_bad_api_ver',
                     FALSE);
               end if;
               return 'U';
        END IF;

        -- Check for null arguments.
        if ((p_function is NULL) or (p_object_name is NULL)) THEN
               fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
               fnd_message.set_token('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
               fnd_message.set_token('REASON',
                    'NULL value passed for p_function:'||p_function||
                    ' or for p_object_name:'||p_object_name);
               if (fnd_log.LEVEL_EXCEPTION >=
                   fnd_log.g_current_runtime_level) then
                 fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.end_bad_param',
                     FALSE);
               end if;
               return 'U';
        END IF;


        -- Default the user name if not passed in.
        if(p_user_name is NULL) then
           l_user_name := SYS_CONTEXT('FND','USER_NAME');
        else
           if (    (fnd_data_security.DISALLOW_DEPRECATED = 'Y')
                and (substr(p_user_name, 1, LENGTH('GET_MNUIDS_NBVCXDS')) <>
                      'GET_MNUIDS_NBVCXDS')
                and (   (p_user_name <> SYS_CONTEXT('FND','USER_NAME'))
                     or (     (p_user_name is not null)
                          and (SYS_CONTEXT('FND','USER_NAME') is null)))) then
               /* In R12 we do not allow passing values other than */
               /* the current user name (which is the default), */
               /* so we raise a runtime exception if that deprecated */
               /* kind of call is made to this routine. */
               fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
               fnd_message.set_token('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
               fnd_message.set_token('REASON',
                    'Invalid API call.  Parameter p_user_name: '||p_user_name||
                    ' was passed to API '||c_pkg_name || '.'|| l_api_name ||
                    '.  p_object_name: '||p_object_name||'.  '||
                    ' In Release 12 and beyond the p_user_name parameter '||
                    'is unsupported, and any product team that passes it '||
                    'must correct their code because it does not work '||
                    'correctly.  Please see the deprecated API document at '||
                    'http://files.oraclecorp.com/content/AllPublic/'||
                    'SharedFolders/ATG%20Requirements-Public/R12/'||
                    'Requirements%20Definition%20Document/'||
                    'Application%20Object%20Library/DeprecatedApiRDD.doc '||
                    'Oracle employees who encounter this error should log '||
                    'a bug against the product that owns the call to this '||
                    'routine, which is likely the owner of the object that '||
                    'was passed to this routine: '||
                    p_object_name);
               if (fnd_log.LEVEL_EXCEPTION >=
                      fnd_log.g_current_runtime_level) then
                 fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.end_depr_param',
                     FALSE);
               end if;
               fnd_message.raise_error;
            end if;
            l_user_name := p_user_name;
        end if;

        /* Make sure that the FND_COMPILED_MENU_FUNCTIONS table is compiled */
        if (FND_FUNCTION.G_ALREADY_FAST_COMPILED <> 'T') then
          FND_FUNCTION.FAST_COMPILE;
        end if;

        l_instance_pk1_value := p_instance_pk1_value;
        l_instance_pk2_value := p_instance_pk2_value;
        l_instance_pk3_value := p_instance_pk3_value;
        l_instance_pk4_value := p_instance_pk4_value;
        l_instance_pk5_value := p_instance_pk5_value;

        /* As a special accomodation for bug 2082465, we won't compile */
        /* the menu_funcs if the caller guarantees they've already compiled */
        /* them by passing the value 'FCMF_GUARANTEED_COMPILED' for */
        /* p_instance_pk5_value.  This is not for public use, just a */
        /* hackish solution to a specific need.  Actually this is no longer */
        /* necessary since we aren't compiling inline anymore anyway, */
        /* but it is left in place for backward compatibility. */
        if(l_instance_pk5_value = 'FCMF_GUARANTEED_COMPILED') then
          l_instance_pk5_value := C_NULL_STR;
        end if;

        /* As a special temporary accomodation for bug 2766313, */
        /* If the pk values passed in are all NULL, assume that the caller*/
        /* wants to check global object instance grants for their context. */
        /* This is not a feature that anyone should rely on going forward; */
        /* This code will be removed in 11ir2.  */
        /* See the following document for more details: */
        /* http://www-apps.us.oracle.com/atg/plans/r1159/nulldatapk.txt */
        if (    p_instance_pk1_value is NULL
            AND p_instance_pk2_value is NULL
            AND p_instance_pk3_value is NULL
            AND p_instance_pk4_value is NULL
            AND p_instance_pk5_value is NULL) then
              l_result := check_global_object_grant
                          (1.0,
                           p_function,
                           l_user_name,
                           p_object_name);

            /* If we found a global object grant, we're done. */
            if (l_result = 'T') then
               if (fnd_log.LEVEL_PROCEDURE >=
                   fnd_log.g_current_runtime_level) then
                 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                   c_log_head || l_api_name || '.end_shortckt',
                  'T');
                end if;
                return 'T';
            elsif (l_result <> 'F') then
               if (fnd_log.LEVEL_PROCEDURE >=
                   fnd_log.g_current_runtime_level) then
                 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                   c_log_head || l_api_name || '.end_sckterr',
                  l_result);
                end if;
                return l_result;
             end if;
        end if;
        /* End special accomodation for bug 2766313*/


           -- Get PK information
           result := get_pk_information(p_object_name  ,
                             l_db_pk1_column  ,
                             l_db_pk2_column  ,
                             l_db_pk3_column  ,
                             l_db_pk4_column  ,
                             l_db_pk5_column  ,
                             l_pk_column_names  ,
                             l_ik_clause  ,
                             l_exact_clause,
                             l_pk_orig_column_names,
                             l_db_object_name,
                             'OBJTAB', 'GNT' );
           if (result <> 'T') then
               if (fnd_log.LEVEL_PROCEDURE >=
                   fnd_log.g_current_runtime_level) then
                 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                  c_log_head || l_api_name || '.end_pk_info_err',
                  'returning status: '|| result);
               end if;
               /* There will be a message on the msg dict stack. */
               return result;
           end if;

           get_security_predicate_w_binds(p_api_version=>1.0,
                                   p_function =>p_function,
                                   p_object_name =>p_object_name,
                                   p_grant_instance_type =>C_TYPE_UNIVERSAL,
                                   p_user_name =>l_user_name,
                                   p_table_alias => 'CKALIAS',
                                   x_predicate=>l_predicate,
                                   x_return_status=>l_return_status,
                                   x_object_id=>l_object_id,
                                   x_function_id=>l_function_id,
                                   x_bind_order=>l_bind_order
                                   );

           if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
             fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                c_log_head || l_api_name || '.after_gsp',
                'l_predicate:'||l_predicate||
                'l_return_status:'||l_return_status||
                'l_object_id:'||l_object_id||
                'l_function_id:'||l_function_id);
           end if;

           IF( l_return_status <> 'T' AND  l_return_status <> 'F') then
              /* There will be a message on the stack from gsp */
              if (fnd_log.LEVEL_EXCEPTION >=
                  fnd_log.g_current_runtime_level) then
                fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                  c_log_head || l_api_name || '.end_gsp_fail',
                  FALSE);
              end if;
              if (l_return_status = 'L') then
                 return 'U';
              else
                 /* Else return E, or U status code, whatever gsp returned. */
                 return l_return_status;
              end if;
           end if;

           IF( l_return_status = 'F') then /* If there weren't enough grants */
                                      /* to make a predicate, we are done. */
              if (fnd_log.LEVEL_PROCEDURE >=
                  fnd_log.g_current_runtime_level) then
                fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                  c_log_head || l_api_name || '.end_gsp_nopred',
                  'F');
              end if;
              return 'F';
           end if;

           IF( length(l_predicate ) >1) THEN
               dynamic_sql :=
                 'SELECT '|| '1' ||
                  ' FROM '|| l_db_object_name || ' CKALIAS'||
                 ' WHERE ROWNUM =1 AND ';
               if (    (l_db_pk1_column is not NULL)
                   AND (l_db_pk1_column <> C_NULL_STR)) then
                  if (l_instance_pk1_value is NULL) then
                    dynamic_sql := dynamic_sql ||
                         ' (CKALIAS.'||l_db_pk1_column||' is NULL) ';
                  else
                    dynamic_sql := dynamic_sql ||
                         ' (CKALIAS.'||l_db_pk1_column||' = :pk1_val) ';
                    l_bind_pk1 := TRUE;
                  end if;
               end if;
               if (    (l_db_pk2_column is not NULL)
                   AND (l_db_pk2_column <> C_NULL_STR)) then
                  if (l_instance_pk2_value is NULL) then
                    dynamic_sql := dynamic_sql ||
                         ' AND (CKALIAS.'||l_db_pk2_column||' is NULL) ';
                  else
                    dynamic_sql := dynamic_sql ||
                         ' AND (CKALIAS.'||l_db_pk2_column||' = :pk2_val) ';
                    l_bind_pk2 := TRUE;
                  end if;
               end if;
               if (    (l_db_pk3_column is not NULL)
                   AND (l_db_pk3_column <> C_NULL_STR)) then
                  if (l_instance_pk3_value is NULL) then
                    dynamic_sql := dynamic_sql ||
                         ' AND (CKALIAS.'||l_db_pk3_column||' is NULL) ';
                  else
                    dynamic_sql := dynamic_sql ||
                         ' AND (CKALIAS.'||l_db_pk3_column||' = :pk3_val) ';
                    l_bind_pk3 := TRUE;
                  end if;
               end if;
               if (    (l_db_pk4_column is not NULL)
                   AND (l_db_pk4_column <> C_NULL_STR)) then
                  if (l_instance_pk4_value is NULL) then
                    dynamic_sql := dynamic_sql ||
                         ' AND (CKALIAS.'||l_db_pk4_column||' is NULL) ';
                  else
                    dynamic_sql := dynamic_sql ||
                         ' AND (CKALIAS.'||l_db_pk4_column||' = :pk4_val) ';
                    l_bind_pk4 := TRUE;
                  end if;
               end if;
               if (    (l_db_pk5_column is not NULL)
                   AND (l_db_pk5_column <> C_NULL_STR)) then
                  if (l_instance_pk5_value is NULL) then
                    dynamic_sql := dynamic_sql ||
                         ' AND (CKALIAS.'||l_db_pk5_column||' is NULL) ';
                  else
                    dynamic_sql := dynamic_sql ||
                         ' AND (CKALIAS.'||l_db_pk5_column||' = :pk5_val) ';
                    l_bind_pk5 := TRUE;
                  end if;
               end if;
               dynamic_sql := dynamic_sql ||
                  '  AND ('||l_predicate||') ';

               if (fnd_log.LEVEL_STATEMENT >=
                   fnd_log.g_current_runtime_level) then
                 fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  c_log_head || l_api_name || '.create_dy_sql',
                  'dynamic_sql:'||dynamic_sql);
              end if;

               l_cursor := dbms_sql.open_cursor;
               dbms_sql.parse(l_cursor, dynamic_sql, dbms_sql.native);

               if l_bind_pk1 then
                 dbms_sql.bind_variable(
                     l_cursor, 'pk1_val', l_instance_pk1_value);
                 if (fnd_log.LEVEL_STATEMENT >=
                     fnd_log.g_current_runtime_level) then
                   fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     c_log_head || l_api_name || '.open1bind',
                     ' l_instance_pk1_value:'||l_instance_pk1_value);
                 end if;
               end if;

               if l_bind_pk2 then
                 dbms_sql.bind_variable(
                     l_cursor, 'pk2_val', l_instance_pk2_value);
                 if (fnd_log.LEVEL_STATEMENT >=
                     fnd_log.g_current_runtime_level) then
                   fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     c_log_head || l_api_name || '.open2bind',
                     ' l_instance_pk2_value:'||l_instance_pk2_value);
                 end if;
               end if;

               if l_bind_pk3 then
                 dbms_sql.bind_variable(
                     l_cursor, 'pk3_val', l_instance_pk3_value);
                 if (fnd_log.LEVEL_STATEMENT >=
                     fnd_log.g_current_runtime_level) then
                   fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     c_log_head || l_api_name || '.open3bind',
                     ' l_instance_pk3_value:'||l_instance_pk3_value);
                 end if;
               end if;

               if l_bind_pk4 then
                 dbms_sql.bind_variable(
                     l_cursor, 'pk4_val', l_instance_pk4_value);
                 if (fnd_log.LEVEL_STATEMENT >=
                     fnd_log.g_current_runtime_level) then
                   fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     c_log_head || l_api_name || '.open4bind',
                     ' l_instance_pk4_value:'||l_instance_pk4_value);
                 end if;
               end if;

               if l_bind_pk5 then
                 dbms_sql.bind_variable(
                     l_cursor, 'pk5_val', l_instance_pk5_value);
                 if (fnd_log.LEVEL_STATEMENT >=
                     fnd_log.g_current_runtime_level) then
                   fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     c_log_head || l_api_name || '.open5bind',
                     ' l_instance_pk5_value:'||l_instance_pk5_value);
                 end if;
               end if;


               if(l_function_id is not NULL) then
                  if (fnd_log.LEVEL_STATEMENT >=
                      fnd_log.g_current_runtime_level) then
                    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     c_log_head || l_api_name || '.fnidbind',
                     ' l_function_id:'||l_function_id);
                  end if;
                  dbms_sql.bind_variable(
                      l_cursor, 'FUNCTION_ID_BIND',l_function_id);
               end if;

               if(l_object_id is not NULL) then
                  if (fnd_log.LEVEL_STATEMENT >=
                      fnd_log.g_current_runtime_level) then
                    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     c_log_head || l_api_name || '.objidbind',
                     ' l_object_id:'||l_object_id);
                  end if;
                  dbms_sql.bind_variable(
                       l_cursor, 'OBJECT_ID_BIND',l_object_id);
               end if;

               dbms_sql.define_column(l_cursor, 1, dummy_item_id);
               l_rows_processed := dbms_sql.execute(l_cursor);

               IF( dbms_sql.fetch_rows(l_cursor) > 0 ) THEN
                 dbms_sql.close_cursor(l_cursor); -- close cursor
                 if (fnd_log.LEVEL_PROCEDURE >=
                     fnd_log.g_current_runtime_level) then
                   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                   c_log_head || l_api_name || '.end_found',
                   'T');
                 end if;
                 RETURN 'T';
               ELSE
                 dbms_sql.close_cursor(l_cursor); -- close cursor
                 if (fnd_log.LEVEL_PROCEDURE >=
                     fnd_log.g_current_runtime_level) then
                   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                   c_log_head || l_api_name || '.end_notfnd',
                   'F');
                 end if;
                 RETURN 'F';
               END IF;

            ELSE
               -- No predicate
               if (fnd_log.LEVEL_PROCEDURE >=
                   fnd_log.g_current_runtime_level) then
                 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                   c_log_head || l_api_name || '.end_nopred',
                  'F');
               end if;
               RETURN 'F';
            END IF; -- End of l_predicate  checking   */



   EXCEPTION
         /* If API called with deprecated p_user_name arg, */
         /* propagate that up so the caller gets exception */
         WHEN FND_MESSAGE_RAISED_ERR THEN
             /* Re raise the error for the caller */
             fnd_message.raise_error;
             return 'U'; /* This line should never be executed */

         WHEN OTHERS THEN

             fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
             fnd_message.set_token('ROUTINE',
                                    c_pkg_name||','||l_api_name);
             fnd_message.set_token('ERRNO', SQLCODE);
             fnd_message.set_token('REASON', SQLERRM);

             if (fnd_log.LEVEL_EXCEPTION >=
                 fnd_log.g_current_runtime_level) then
               fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.other_err',
                     FALSE);
             end if;
             if (fnd_log.LEVEL_PROCEDURE >=
                 fnd_log.g_current_runtime_level) then
               fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                 c_log_head || l_api_name || '.end_after_other',
                 'U' );
             end if;
             RETURN 'U';
  END check_function;
  -----------------------------------------------------------------




------Function get_functions-------------
/* Note that this routine has a special not publicly documented feature used*/
/* by the ATG java code where it will return a list of the menuids rather than*/
/* functions, if the special magic cookie  */
/* is passed for the p_user_name */
PROCEDURE get_functions(
   p_api_version         IN  NUMBER,
   p_object_name         IN  VARCHAR2,
   p_instance_pk1_value  IN  VARCHAR2,
   p_instance_pk2_value  IN  VARCHAR2,
   p_instance_pk3_value  IN  VARCHAR2,
   p_instance_pk4_value  IN  VARCHAR2,
   p_instance_pk5_value  IN  VARCHAR2,
   p_user_name           IN  VARCHAR2,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_privilege_tbl       OUT NOCOPY FND_PRIVILEGE_NAME_TABLE_TYPE
 ) IS
    l_api_version          CONSTANT NUMBER := 1.0;
    l_api_name             CONSTANT VARCHAR2(30) := 'GET_FUNCTIONS';
    l_sysdate              DATE := Sysdate;
    l_predicate            VARCHAR2(32767);
    -- modified for bug#5395351
    function_name          fnd_form_functions.function_name%type;
    dynamic_sql            VARCHAR2(32767);
    l_return_status varchar2(1);
    result                  varchar2(30);
    l_nrows                   pls_integer;
    l_index                 NUMBER;
    l_grant_inst_type       varchar2(30);


    TYPE  DYNAMIC_CUR IS REF CURSOR;
    instance_sets_cur DYNAMIC_CUR;

        l_object_id number;
        l_user_name varchar2(80);
   BEGIN
      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name|| '(' ||
          ' p_api_version=>'|| to_char(p_api_version) ||','||
          ' p_object_name=>'|| p_object_name ||','||
          ' p_instance_pk1_value=>'|| p_instance_pk1_value ||','||
          ' p_instance_pk2_value=>'|| p_instance_pk2_value ||','||
          ' p_instance_pk3_value=>'|| p_instance_pk3_value ||','||
          ' p_instance_pk4_value=>'|| p_instance_pk4_value ||','||
          ' p_instance_pk5_value=>'|| p_instance_pk5_value ||','||
          ' p_user_name=>'|| p_user_name ||
          ');');
        end if;

        -- check for call compatibility.
        if TRUNC(l_api_version) <> TRUNC(p_api_version) THEN
               fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
               fnd_message.set_token('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
               fnd_message.set_token('REASON',
                    'Unsupported version '|| to_char(p_api_version)||
                    ' passed to API; expecting version '||
                    to_char(l_api_version));

               if (fnd_log.LEVEL_EXCEPTION >=
                   fnd_log.g_current_runtime_level) then
                 fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.end_bad_api_ver',
                     FALSE);
               end if;
               x_return_status := 'U';
               return;
        END IF;

        -- Check for null arguments.
        if (p_object_name is NULL) THEN
               fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
               fnd_message.set_token('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
               fnd_message.set_token('REASON',
                    'NULL value passed for p_object_name:'|| p_object_name);

               if (fnd_log.LEVEL_EXCEPTION >=
                   fnd_log.g_current_runtime_level) then
                 fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.end_bad_param',
                     FALSE);
               end if;
               x_return_status := 'U';
               return;
        END IF;

        /* Make sure that the FND_COMPILED_MENU_FUNCTIONS table is compiled */
        if (FND_FUNCTION.G_ALREADY_FAST_COMPILED <> 'T') then
          FND_FUNCTION.FAST_COMPILE;
        end if;

        -- Default the user name if not passed in.
        if(p_user_name is NULL) then
           l_user_name := SYS_CONTEXT('FND','USER_NAME');
        else
           if (    (fnd_data_security.DISALLOW_DEPRECATED = 'Y')
               and (substr(p_user_name, 1, LENGTH('GET_MNUIDS_NBVCXDS')) <>
                      'GET_MNUIDS_NBVCXDS')
               and (   (p_user_name <> SYS_CONTEXT('FND','USER_NAME'))
                    or (     (p_user_name is not null)
                         and (SYS_CONTEXT('FND','USER_NAME') is null)))) then
              /* In R12 we do not allow passing values other than */
              /* the current user name (which is the default), */
              /* so we raise a runtime exception if that deprecated */
              /* kind of call is made to this routine. */
              fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
              fnd_message.set_token('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
              fnd_message.set_token('REASON',
                    'Invalid API call.  Parameter p_user_name: '||p_user_name||
                    ' was passed to API '||c_pkg_name || '.'|| l_api_name ||
                    '.  p_object_name: '||p_object_name||'.  '||
                    ' In Release 12 and beyond the p_user_name parameter '||
                    'is unsupported, and any product team that passes it '||
                    'must correct their code because it does not work '||
                    'correctly.  Please see the deprecated API document at '||
                    'http://files.oraclecorp.com/content/AllPublic/'||
                    'SharedFolders/ATG%20Requirements-Public/R12/'||
                    'Requirements%20Definition%20Document/'||
                    'Application%20Object%20Library/DeprecatedApiRDD.doc '||
                    'Oracle employees who encounter this error should log '||
                    'a bug against the product that owns the call to this '||
                    'routine, which is likely the owner of the object that '||
                    'was passed to this routine: '||
                    p_object_name);
              if (fnd_log.LEVEL_EXCEPTION >=
                      fnd_log.g_current_runtime_level) then
                fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.end_depr_param',
                     FALSE);
              end if;
              fnd_message.raise_error;
           end if;
           l_user_name := p_user_name;
        end if;

        if (p_instance_pk1_value is not NULL) then
          l_grant_inst_type := 'FUNCLIST';
        else
          l_grant_inst_type := 'FUNCLIST_NOINST';
        end if;

        get_security_predicate(p_api_version=>1.0,
                                p_function =>NULL,
                                p_object_name =>p_object_name,
                                p_grant_instance_type =>l_grant_inst_type,
                                p_user_name =>l_user_name,
                                x_predicate=>l_predicate,
                                x_return_status=>l_return_status
                                );
        if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
           c_log_head || l_api_name || '.after_gsp',
           'l_predicate:'||l_predicate);
        end if;

        IF( l_return_status <> 'T' AND  l_return_status <> 'F') then
            /* There will be a message on the stack from gsp */
            if (fnd_log.LEVEL_EXCEPTION >=
                fnd_log.g_current_runtime_level) then
              fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                c_log_head || l_api_name || '.end_gsp_fail',
                FALSE);
            end if;
            if (l_return_status = 'L') then
               x_return_status := 'U';
            else
               /* Else return E, U, status code, whatever gsp returned. */
               x_return_status := l_return_status;
            end if;
            return;
        end if;

        IF( l_return_status = 'F') then /* If there weren't enough grants */
                                        /* to make a predicate, we are done. */
            if (fnd_log.LEVEL_PROCEDURE >=
                fnd_log.g_current_runtime_level) then
              fnd_log.message(FND_LOG.LEVEL_PROCEDURE,
                c_log_head || l_api_name || '.end_gsp_nopred',
                FALSE);
            end if;
            x_return_status := 'F';
            return;
        end if;

        IF( length(l_predicate ) >1) THEN
            dynamic_sql :=  l_predicate;

            if (fnd_log.LEVEL_STATEMENT >=
                fnd_log.g_current_runtime_level) then
              fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               c_log_head || l_api_name || '.create_dy_sql',
               'dynamic_sql:'||dynamic_sql);
            end if;

            if(p_instance_pk5_value is not NULL) then
               OPEN instance_sets_cur FOR dynamic_sql USING
                  p_instance_pk1_value,
                  p_instance_pk2_value,
                  p_instance_pk3_value,
                  p_instance_pk4_value,
                  p_instance_pk5_value;
            elsif (p_instance_pk4_value is not NULL) then
               OPEN instance_sets_cur FOR dynamic_sql USING
                  p_instance_pk1_value,
                  p_instance_pk2_value,
                  p_instance_pk3_value,
                  p_instance_pk4_value;
            elsif (p_instance_pk3_value is not NULL) then
               OPEN instance_sets_cur FOR dynamic_sql USING
                  p_instance_pk1_value,
                  p_instance_pk2_value,
                  p_instance_pk3_value;
            elsif (p_instance_pk2_value is not NULL) then
               OPEN instance_sets_cur FOR dynamic_sql USING
                  p_instance_pk1_value,
                  p_instance_pk2_value;
            elsif (p_instance_pk1_value is not NULL) then
               OPEN instance_sets_cur FOR dynamic_sql USING
                  p_instance_pk1_value;
            else
               OPEN instance_sets_cur FOR dynamic_sql;
            end if;
            l_index := 0;
            LOOP
               FETCH instance_sets_cur  INTO function_name ;
               if (fnd_log.LEVEL_STATEMENT >=
                   fnd_log.g_current_runtime_level) then
                 fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                   c_log_head || l_api_name || '.got_priv',
                   'function_name:' || function_name);
               end if;
               EXIT WHEN instance_sets_cur%NOTFOUND;
               x_privilege_tbl (l_index):=function_name;
               l_index:=l_index+1;
            END LOOP;
            CLOSE instance_sets_cur;
            if(l_index > 0) then
               x_return_status := 'T'; /* Success */
            else
               x_return_status := 'F'; /* No functions */
            end if;
            if (fnd_log.LEVEL_PROCEDURE >=
                fnd_log.g_current_runtime_level) then
              fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
               c_log_head || l_api_name || '.end',
               'returning '|| x_return_status );
            end if;
         ELSE
            -- No predicate
            if (fnd_log.LEVEL_PROCEDURE >=
                fnd_log.g_current_runtime_level) then
              fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                c_log_head || l_api_name || '.end_nopred',
               'F');
             end if;
             x_return_status := 'F';
            RETURN;
         END IF; -- End of l_predicate  checking   */

         return;

   EXCEPTION
         /* If API called with deprecated p_user_name arg, */
         /* propagate that up so the caller gets exception */
         WHEN FND_MESSAGE_RAISED_ERR THEN
             /* Re raise the error for the caller */
             fnd_message.raise_error;

             x_return_status := 'U'; /* This line should never be executed */
             return;

         WHEN OTHERS THEN
             fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
             fnd_message.set_token('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
             fnd_message.set_token('ERRNO', SQLCODE);
             fnd_message.set_token('REASON', SQLERRM);

             if (fnd_log.LEVEL_EXCEPTION >=
                 fnd_log.g_current_runtime_level) then
               fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.other_err',
                     FALSE);
             end if;
             if (fnd_log.LEVEL_PROCEDURE >=
                 fnd_log.g_current_runtime_level) then
               fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                 c_log_head || l_api_name || '.end_after_other',
                 'returning '|| 'U' );
             end if;
             x_return_status := 'U';
             return;
  END get_functions;
  -----------------------------------------------------------------


------Procedure GET_MENUS-------------
/* INTERNAL ATG USE ONLY.  NOT FOR PUBLIC USE.  This is primarily used */
/* by the ATG java code where it will return a list of the menuids. */
/* Currently the user_name argument is ignored and the current user */
/* is used. */
PROCEDURE get_menus
  (
   p_api_version         IN  NUMBER,
   p_object_name         IN  VARCHAR2,
   p_instance_pk1_value  IN  VARCHAR2,
   p_instance_pk2_value  IN  VARCHAR2,
   p_instance_pk3_value  IN  VARCHAR2,
   p_instance_pk4_value  IN  VARCHAR2,
   p_instance_pk5_value  IN  VARCHAR2,
   p_user_name           IN  VARCHAR2,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_menu_tbl            OUT NOCOPY FND_TABLE_OF_NUMBER
 ) IS
    l_api_version          CONSTANT NUMBER := 1.0;
    l_api_name             CONSTANT VARCHAR2(30) := 'GET_MENUS';
    l_menu_tbl             FND_PRIVILEGE_NAME_TABLE_TYPE;
    l_index                NUMBER;
    l_return_status        VARCHAR2(30);
    l_menu_id              NUMBER;
    l_out_menu_tbl         FND_TABLE_OF_NUMBER;
    l_user_id_str          VARCHAR2(255);
begin
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name|| '(' ||
          ' p_api_version=>'|| to_char(p_api_version) ||','||
          ' p_object_name=>'|| p_object_name ||','||
          ' p_instance_pk1_value=>'|| p_instance_pk1_value ||','||
          ' p_instance_pk2_value=>'|| p_instance_pk2_value ||','||
          ' p_instance_pk3_value=>'|| p_instance_pk3_value ||','||
          ' p_instance_pk4_value=>'|| p_instance_pk4_value ||','||
          ' p_instance_pk5_value=>'|| p_instance_pk5_value ||','||
          ' p_user_name=>'|| p_user_name ||');');
  end if;

  -- check for call compatibility.
  if TRUNC(l_api_version) <> TRUNC(p_api_version) THEN
     fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
     fnd_message.set_token('ROUTINE',
                              c_pkg_name || '.'|| l_api_name);
     fnd_message.set_token('REASON',
                    'Unsupported version '|| to_char(p_api_version)||
                    ' passed to API; expecting version '||
                    to_char(l_api_version));
     if (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
       fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.end_bad_api_ver',
                     FALSE);
     end if;
     x_return_status := 'U';
     return;
  END IF;

  if(p_user_name is NULL) then
     l_user_id_str := 'GET_MNUIDS_NBVCXDS';
  else
     l_user_id_str := 'GET_MNUIDS_NBVCXDS:'||p_user_name;
  end if;

  fnd_data_security.get_functions
  (
   p_api_version        => 1.0,
   p_object_name        => p_object_name,
   p_instance_pk1_value => p_instance_pk1_value,
   p_instance_pk2_value => p_instance_pk2_value,
   p_instance_pk3_value => p_instance_pk3_value,
   p_instance_pk4_value => p_instance_pk4_value,
   p_instance_pk5_value => p_instance_pk5_value,
   p_user_name          => l_user_id_str,
   x_return_status      => x_return_status,
   x_privilege_tbl      => l_menu_tbl );

  l_index := 0;
  l_out_menu_tbl := FND_TABLE_OF_NUMBER();

  LOOP
    begin
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,
          c_log_head || l_api_name || '.got_menu',
          'menu_id:' || l_menu_tbl(l_index));
      end if;
      l_menu_id := to_number(l_menu_tbl(l_index));
      l_out_menu_tbl.EXTEND;
      l_out_menu_tbl(l_index+1):= l_menu_id;
      l_index:=l_index+1;
    exception
      when no_data_found then
        exit;
    end;
  END LOOP;

  if (l_out_menu_tbl is not NULL) then
    x_menu_tbl := l_out_menu_tbl;
  else
    x_menu_tbl := NULL;
    x_return_status := 'F';
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end',
          'returning status'|| x_return_status );
  end if;

end GET_MENUS;


  ----- get_security_predicate_helper- this is not a public API
  ----- This is the OLD version of the get_security_predicate code, used
  ----- only for certain rare modes.
  ----- Get the predicate.  This handles the modes (p_grant_instance_type)
  ----- FUNCLIST, FUNCLIST_NOINST, and GRANTS_ONLY.
  ----- Undocumented unsupported feature for internal use only:
  ----- passing 'FUNCLIST' for p_grant_instance_type will yield pred
  ----- for use in get_functions.
  --------------------------------------------
  PROCEDURE get_security_predicate_helper
  (
    p_function         IN  VARCHAR2,
    p_object_name      IN  VARCHAR2,
    p_grant_instance_type  IN  VARCHAR2,/* SET, INSTANCE*/
                           /* Undocumented value: FUNCLIST, FUNCLIST_NOINST */
                           /* Documented value: GRANTS_ONLY */
    p_user_name        IN  VARCHAR2,
    /* stmnt_type: 'OTHER', 'VPD'=VPD, 'EXISTS'= for checking existence. */
    p_statement_type   IN  VARCHAR2,
    x_predicate        out NOCOPY varchar2,
    x_return_status    out NOCOPY varchar2,
    p_table_alias      IN  VARCHAR2
  )  IS
        l_api_name   CONSTANT VARCHAR2(30):= 'GET_SECURITY_PREDICATE_HELPER';

    l_sysdate              DATE := Sysdate;
    l_aggregate_predicate   VARCHAR2(32767); /* Must match c_pred_buf_size*/
    l_instance_flag         BOOLEAN  := TRUE;
    l_instance_set_flag     BOOLEAN  := TRUE;
    l_grants_only_flag      BOOLEAN  := FALSE;
    l_funclist_flag         BOOLEAN  := FALSE;
    l_menulist_flag         BOOLEAN  := FALSE;
    l_set_predicates        VARCHAR2(32767); /* Must match c_pred_buf_size*/
    l_db_object_name        varchar2(30);
    l_db_pk1_column         varchar2(256);
    l_db_pk2_column         varchar2(256);
    l_db_pk3_column         varchar2(256);
    l_db_pk4_column         varchar2(256);
    l_db_pk5_column         varchar2(256);
    l_pk_column_names       varchar2(512);
    l_pk_orig_column_names  varchar2(512);
    l_ik_clause             varchar2(2048);
    l_exact_clause          varchar2(2048);
    l_user_name             varchar2(80);
    l_nrows                 pls_integer;
    l_table_alias           varchar2(256);
    l_pred                  varchar2(4000);
    colon                   pls_integer;

    CURSOR instance_set_grants_c (cp_user_name       varchar2,
                                  cp_function_id NUMBER,
                                  cp_object_id VARCHAR2)
        IS
         SELECT  /*+ leading(u2) use_nl(g) index(g,FND_GRANTS_N9) */
                UNIQUE
                instance_sets.predicate, instance_sets.instance_set_id
           FROM
           ( select /*+ NO_MERGE */ 'GLOBAL' role_name from dual
              union all
             select role_name
             from wf_user_roles wur,
               (
               select cp_user_name name from dual
                 union all
               select incr1.name name
                 from wf_local_roles incr1, fnd_user u1
               where 'HZ_PARTY'           = incr1.orig_system
                  and u1.user_name         = cp_user_name
                  and u1.person_party_id   = incr1.orig_system_id
                  and incr1.partition_id  = 9 /* HZ_PARTY */
                ) incr2
             where wur.user_name = incr2.name
            ) u2,
            fnd_grants g,
            fnd_object_instance_sets instance_sets
          WHERE g.instance_type = 'SET'
            AND g.grantee_key = u2.role_name
            AND g.object_id = cp_object_id
            AND (   (cp_function_id = -1)
                 OR (g.menu_id in
                      (select cmf.menu_id
                         from fnd_compiled_menu_functions cmf
                        where cmf.function_id = cp_function_id)))
            AND g.instance_set_id = instance_sets.instance_set_id
            AND (   g.ctx_secgrp_id    = -1
                 OR g.ctx_secgrp_id    =
                                    SYS_CONTEXT('FND','SECURITY_GROUP_ID'))
            AND (   g.ctx_resp_id      = -1
                 OR g.ctx_resp_id      = SYS_CONTEXT('FND','RESP_ID'))
            AND (   g.ctx_resp_appl_id = -1
                 OR g.ctx_resp_appl_id = SYS_CONTEXT('FND','RESP_APPL_ID'))
            AND (   g.ctx_org_id       = -1
                 OR g.ctx_org_id       = SYS_CONTEXT('FND', 'ORG_ID'))
            AND g.start_date <= SYSDATE
            AND (   g.end_date IS NULL
                 OR g.end_date >= SYSDATE );

    --Changes for Bug#3867925
    -- Fix Non Backward change made for universal person support
    --
    -- Performance note: This statement has not received the optimizations
    -- to the WF User portion of the SQL because the separation of the
    -- USER and GROUP clauses prevent that.  Since this is only used for
    -- deprecated code that is okay.
        CURSOR instance_set_grants_bkwd_c (cp_user_name varchar2,
                                           cp_function_id NUMBER,
                                           cp_object_id VARCHAR2)
        IS
         SELECT UNIQUE
                instance_sets.predicate, instance_sets.instance_set_id
           FROM fnd_grants g,
                fnd_object_instance_sets instance_sets
          WHERE g.instance_type = 'SET'
             AND  (( g.grantee_type = 'USER'
                       AND g.grantee_key = cp_user_name)
                    OR (     g.grantee_type = 'GROUP'
                        AND (g.grantee_key in
                  (select role_name
                   from wf_user_roles wur
                  where wur.user_name in
                   ( (select cp_user_name from dual)
                          union all
                     (select incrns.name from wf_local_roles incrns, fnd_user f
                       where 'HZ_PARTY'       = incrns.orig_system
                         and f.user_name           = cp_user_name
                         and f.person_party_id  = incrns.orig_system_id)))))
                   OR (g.grantee_type = 'GLOBAL'))
            AND g.object_id = cp_object_id
            AND (   (cp_function_id = -1)
                 OR (g.menu_id in
                      (select cmf.menu_id
                         from fnd_compiled_menu_functions cmf
                        where cmf.function_id = cp_function_id)))
            AND g.instance_set_id = instance_sets.instance_set_id
            AND (   g.ctx_secgrp_id    = -1
                 OR g.ctx_secgrp_id    =
                                    SYS_CONTEXT('FND','SECURITY_GROUP_ID'))
            AND (   g.ctx_resp_id      = -1
                 OR g.ctx_resp_id      = SYS_CONTEXT('FND','RESP_ID'))
            AND (   g.ctx_resp_appl_id = -1
                 OR g.ctx_resp_appl_id = SYS_CONTEXT('FND','RESP_APPL_ID'))
            AND (   g.ctx_org_id       = -1
                 OR g.ctx_org_id       = SYS_CONTEXT('FND', 'ORG_ID'))
            AND g.start_date <= SYSDATE
            AND (   g.end_date IS NULL
                 OR g.end_date >= SYSDATE );

    CURSOR instance_set_grants_guest_c (cp_user_name varchar2,
                                        cp_function_id NUMBER,
                                        cp_object_id VARCHAR2)
        IS
         SELECT  /*+ leading(u2) use_nl(g) index(g,FND_GRANTS_N9) */
                UNIQUE
                instance_sets.predicate, instance_sets.instance_set_id
           FROM
           ( select /*+ NO_MERGE */  role_name
             from wf_user_roles wur,
               (
               select cp_user_name name from dual
                 union all
               select incr1.name name
                 from wf_local_roles incr1, fnd_user u1
               where 'HZ_PARTY'           = incr1.orig_system
                  and u1.user_name         = cp_user_name
                  and u1.person_party_id   = incr1.orig_system_id
                  and incr1.partition_id  = 9 /* HZ_PARTY */
                ) incr2
             where wur.user_name = incr2.name
            ) u2,
            fnd_grants g,
            fnd_object_instance_sets instance_sets
          WHERE g.instance_type = 'SET'
            AND g.grantee_key = u2.role_name
            AND g.object_id = cp_object_id
            AND (   (cp_function_id = -1)
                 OR (g.menu_id in
                      (select cmf.menu_id
                         from fnd_compiled_menu_functions cmf
                        where cmf.function_id = cp_function_id)))
            AND g.instance_set_id = instance_sets.instance_set_id
            AND (   g.ctx_secgrp_id    = -1
                 OR g.ctx_secgrp_id    =
                                    SYS_CONTEXT('FND','SECURITY_GROUP_ID'))
            AND (   g.ctx_resp_id      = -1
                 OR g.ctx_resp_id      = SYS_CONTEXT('FND','RESP_ID'))
            AND (   g.ctx_resp_appl_id = -1
                 OR g.ctx_resp_appl_id = SYS_CONTEXT('FND','RESP_APPL_ID'))
            AND (   g.ctx_org_id       = -1
                 OR g.ctx_org_id       = SYS_CONTEXT('FND', 'ORG_ID'))
            AND g.start_date <= SYSDATE
            AND (   g.end_date IS NULL
                 OR g.end_date >= SYSDATE );

     l_object_id number;
     l_function_id number;
    BEGIN

      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name|| '(' ||
          ', p_function=>'|| p_function ||
          ', p_object_name=>'|| p_object_name ||
          ', p_grant_instance_type=>'|| p_grant_instance_type ||
          ', p_user_name=>'|| p_user_name ||
          ', p_table_alias=>'|| p_table_alias
          ||');');
       end if;

       x_return_status := 'T'; /* Assume Success */

       /* Make sure that the FND_COMPILED_MENU_FUNCTIONS table is compiled */
       if (FND_FUNCTION.G_ALREADY_FAST_COMPILED <> 'T') then
         FND_FUNCTION.FAST_COMPILE;
       end if;

       -- Default the user name if not passed in
       if(substr(p_user_name, 1, LENGTH('GET_MNUIDS_NBVCXDS')) =
                 'GET_MNUIDS_NBVCXDS') then
          l_menulist_flag := TRUE; /* For a special mode called from java */
          if(substr(p_user_name, 1, LENGTH('GET_MNUIDS_NBVCXDS:')) =
                 'GET_MNUIDS_NBVCXDS:') then
            if (    (fnd_data_security.DISALLOW_DEPRECATED = 'Y')
               and (substr(p_user_name, 1, LENGTH('GET_MNUIDS_NBVCXDS')) <>
                 'GET_MNUIDS_NBVCXDS')
               and (   (p_user_name <> SYS_CONTEXT('FND','USER_NAME'))
                    or (     (p_user_name is not null)
                         and (SYS_CONTEXT('FND','USER_NAME') is null)))) then
              /* In R12 we do not allow passing values other than */
              /* the current user name (which is the default), */
              /* so we raise a runtime exception if that deprecated */
              /* kind of call is made to this routine. */
              fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
              fnd_message.set_token('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
              fnd_message.set_token('REASON',
                    'Invalid API call.  Parameter p_user_name: '||p_user_name||
                    ' was passed to API '||c_pkg_name || '.'|| l_api_name ||
                    '.  p_object_name: '||p_object_name||'.  '||
                    ' In Release 12 and beyond the p_user_name parameter '||
                    'is unsupported, and any product team that passes it '||
                    'must correct their code because it does not work '||
                    'correctly.  Please see the deprecated API document at '||
                    'http://files.oraclecorp.com/content/AllPublic/'||
                    'SharedFolders/ATG%20Requirements-Public/R12/'||
                    'Requirements%20Definition%20Document/'||
                    'Application%20Object%20Library/DeprecatedApiRDD.doc '||
                    'Oracle employees who encounter this error should log '||
                    'a bug against the product that owns the call to this '||
                    'routine, which is likely the owner of the object that '||
                    'was passed to this routine: '||
                    p_object_name);
              if (fnd_log.LEVEL_EXCEPTION >=
                      fnd_log.g_current_runtime_level) then
                fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.end_depr_param',
                     FALSE);
              end if;
              fnd_message.raise_error;
            end if;
            l_user_name := SUBSTR(p_user_name,
                             LENGTH('GET_MNUIDS_NBVCXDS:')+1);
          else
            l_user_name := SYS_CONTEXT('FND','USER_NAME');
          end if;
          if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               c_log_head || l_api_name || '.get_mnuid',
               'l_user_name= '||l_user_name);
          end if;
       elsif (p_user_name is NULL) then
          l_user_name := SYS_CONTEXT('FND','USER_NAME');
          if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               c_log_head || l_api_name || '.null_username',
               'l_user_name= '||l_user_name);
          end if;
       else
          if (    (fnd_data_security.DISALLOW_DEPRECATED = 'Y')
              and (substr(p_user_name, 1, LENGTH('GET_MNUIDS_NBVCXDS')) <>
                 'GET_MNUIDS_NBVCXDS')
              and (   (p_user_name <> SYS_CONTEXT('FND','USER_NAME'))
                   or (     (p_user_name is not null)
                        and (SYS_CONTEXT('FND','USER_NAME') is null)))) then
              /* In R12 we do not allow passing values other than */
              /* the current user name (which is the default), */
              /* so we raise a runtime exception if that deprecated */
              /* kind of call is made to this routine. */
              fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
              fnd_message.set_token('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
              fnd_message.set_token('REASON',
                    'Invalid API call.  Parameter p_user_name: '||p_user_name||
                    ' was passed to API '||c_pkg_name || '.'|| l_api_name ||
                    '.  p_object_name: '||p_object_name||'.  '||
                    ' In Release 12 and beyond the p_user_name parameter '||
                    'is unsupported, and any product team that passes it '||
                    'must correct their code because it does not work '||
                    'correctly.  Please see the deprecated API document at '||
                    'http://files.oraclecorp.com/content/AllPublic/'||
                    'SharedFolders/ATG%20Requirements-Public/R12/'||
                    'Requirements%20Definition%20Document/'||
                    'Application%20Object%20Library/DeprecatedApiRDD.doc '||
                    'Oracle employees who encounter this error should log '||
                    'a bug against the product that owns the call to this '||
                    'routine, which is likely the owner of the object that '||
                    'was passed to this routine: '||
                    p_object_name);
              if (fnd_log.LEVEL_EXCEPTION >=
                      fnd_log.g_current_runtime_level) then
                fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.end_depr_param',
                     FALSE);
              end if;
              fnd_message.raise_error;
          end if;
          l_user_name := p_user_name;
          if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               c_log_head || l_api_name || '.passed_uname',
               'l_user_name= '||l_user_name);
          end if;
       end if;



       -- Check to make sure a valid role is passed or defaulted for user_name
       if (check_user_role(l_user_name) = 'F') then
         -- If we got here then the grantee will never be found because
         -- it isn't even a role, so we know there won't be a matching grant.
         fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
         fnd_message.set_token('ROUTINE',
                                   c_pkg_name || '.'|| l_api_name);
         fnd_message.set_token('REASON',
               'The user_name passed or defaulted is not a valid user_name '||
               'in wf_user_roles. '||
               'Invalid user_name: '||l_user_name ||
               ' Passed p_user_name: '||p_user_name);
         if (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
           fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                c_log_head || l_api_name || '.end_no_wf_user_role',
                FALSE);
         end if;
         l_aggregate_predicate := '1=2';
         x_return_status := 'E'; /* Error condition */
         return;
       end if;


       -- Step 1.

        if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               c_log_head || l_api_name || '.step1start',
               'p_grant_instance_type:'||p_grant_instance_type);
        end if;
        IF (p_grant_instance_type = C_TYPE_INSTANCE) THEN
            if (fnd_log.LEVEL_STATEMENT >=
                fnd_log.g_current_runtime_level) then
              fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               c_log_head || l_api_name || '.chk_instance',
               ' l_instance_set_flag := FALSE ');
            end if;
            l_instance_set_flag:= FALSE;
        ELSIF (p_grant_instance_type = C_TYPE_SET) THEN
            if (fnd_log.LEVEL_STATEMENT >=
                fnd_log.g_current_runtime_level) then
              fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               c_log_head || l_api_name || '.chk_set',
               ' l_instance_flag := FALSE ');
            end if;
            l_instance_flag:= FALSE;
        ELSIF (p_grant_instance_type = 'FUNCLIST') THEN
            if (fnd_log.LEVEL_STATEMENT >=
                fnd_log.g_current_runtime_level) then
              fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               c_log_head || l_api_name || '.chk_funclist',
               ' l_funclist_flag := TRUE ');
            end if;
            l_funclist_flag:= TRUE;
        ELSIF (p_grant_instance_type = 'FUNCLIST_NOINST') THEN
            if (fnd_log.LEVEL_STATEMENT >=
                fnd_log.g_current_runtime_level) then
              fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               c_log_head || l_api_name || '.chk_funclist_noinst',
               ' l_funclist_flag := TRUE ');
            end if;
            l_funclist_flag:= TRUE;
            l_instance_flag:= FALSE;
            l_instance_set_flag:= FALSE;
        ELSIF (p_grant_instance_type = 'GRANTS_ONLY') THEN
            if (fnd_log.LEVEL_STATEMENT >=
                fnd_log.g_current_runtime_level) then
              fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               c_log_head || l_api_name || '.chk_grants_only',
               ' l_funclist_flag := FALSE ');
            end if;
            l_grants_only_flag:= TRUE;
            l_funclist_flag:= FALSE;
            l_instance_flag:= FALSE;
            l_instance_set_flag:= FALSE;
        ELSIF (p_grant_instance_type = 'UNIVERSAL') THEN
            if (fnd_log.LEVEL_STATEMENT >=
                fnd_log.g_current_runtime_level) then
              fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               c_log_head || l_api_name || '.chk_universal',
               '  ');
            end if;
        END IF;

        if (p_object_name is NULL) THEN
            fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
            fnd_message.set_token('ROUTINE',
                                     c_pkg_name || '.'|| l_api_name);
            fnd_message.set_token('REASON',
                 'The parameter p_object_name can not be NULL.');
            if (fnd_log.LEVEL_EXCEPTION >=
                fnd_log.g_current_runtime_level) then
              fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                  c_log_head || l_api_name || '.end_null_obj',
                  FALSE);
            end if;
            x_return_status := 'U';
            return;
        END IF;

        if(p_object_name = 'GLOBAL') then
          /* As a special hack to allow Raymond to retrieve the */
          /* global grants by calling the internal get_menus routine, */
          /* we allow 'GLOBAL' only for that particular case. */

          /* Bug 5580650.
           * Don't support any special hacking.
           * Don't support object_name=GLOBAL even for 'l_menulist_flag=TRUE'
           * case. With the following code though it appears object_name=GLOBAL
           * is allowed for 'l_menulist_flag=TRUE' case, it is failing with
           * SQL parse error ORA-00942 at the end while executing the
           * dynamically generated sql predicate. So the below code is commented
           * so that instead of deferring the error to SQL parse stage,
           * now it throws the error as soon as  object_name=GLOBAL case is
           * identified.
           */
          /******
          if (l_menulist_flag = FALSE) then
            fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
            fnd_message.set_token('ROUTINE',
                                     c_pkg_name || '.'|| l_api_name);
            fnd_message.set_token('REASON',
                 'The parameter p_object_name can not be ''GLOBAL''. ');
            if (fnd_log.LEVEL_EXCEPTION >=
                fnd_log.g_current_runtime_level) then
              fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                  c_log_head || l_api_name || '.end_glob_obj',
                  FALSE);
            end if;
            x_return_status := 'U';
            return;
          else
            l_object_id := -1;
          end if;
          ********/
          fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
          fnd_message.set_token('ROUTINE',
                                   c_pkg_name || '.'|| l_api_name);
          fnd_message.set_token('REASON',
               'The parameter p_object_name can not be ''GLOBAL''. ');
          if (fnd_log.LEVEL_EXCEPTION >=
              fnd_log.g_current_runtime_level) then
            fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                c_log_head || l_api_name || '.end_glob_obj',
                FALSE);
          end if;
          x_return_status := 'U';
          return;
        else /* Normal case */
          /* Get the primary key lists and info for this object */
          x_return_status := get_pk_information(p_object_name,
                             l_db_pk1_column  ,
                             l_db_pk2_column  ,
                             l_db_pk3_column  ,
                             l_db_pk4_column  ,
                             l_db_pk5_column  ,
                             l_pk_column_names  ,
                             l_ik_clause,
                             l_exact_clause,
                             l_pk_orig_column_names,
                             l_db_object_name,
                             'OBJTAB', 'GNT');
          if (x_return_status <> 'T') then
              if (fnd_log.LEVEL_PROCEDURE >=
                  fnd_log.g_current_runtime_level) then
                fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                 c_log_head || l_api_name || '.end_pk_info_err',
                 'returning status: '|| x_return_status);
              end if;
              /* There will be a message on the msg dict stack. */
              return;  /* We will return the x_return_status as out param */
          end if;

          l_object_id :=get_object_id(p_object_name );
          if (l_object_id is NULL) THEN
            fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
            fnd_message.set_token('ROUTINE',
                                     c_pkg_name || '.'|| l_api_name);
            fnd_message.set_token('REASON',
                 'The parameter value p_object_name is not a valid object.'||
                 ' p_object_name:'||p_object_name);
            if (fnd_log.LEVEL_EXCEPTION >=
                fnd_log.g_current_runtime_level) then
              fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                 c_log_head || l_api_name || '.end_bad_obj',
                  FALSE);
            end if;
            x_return_status := 'U';
            return;
          END IF;
        end if;

        if(p_function is NULL) then
          l_function_id := -1;
        else
          l_function_id := get_function_id(p_function);
          if (l_function_id is NULL) THEN
              fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
              fnd_message.set_token('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
              fnd_message.set_token('REASON',
               'The parameter value p_function is not a valid function name.'||
                   ' p_function:'||p_function);
              if (fnd_log.LEVEL_EXCEPTION >=
                  fnd_log.g_current_runtime_level) then
                fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                    c_log_head || l_api_name || '.end_bad_func',
                    FALSE);
              end if;
              x_return_status := 'U';
              return;
          END IF;
        end if;

        l_aggregate_predicate  := '';


        if (p_table_alias is not NULL) then
          l_table_alias := p_table_alias || '.';
          l_pk_orig_column_names := l_table_alias ||
                               replace (l_pk_orig_column_names, ', ',
                                        ', '||l_table_alias);
        else
          l_table_alias := NULL;
        end if;

        -- Step 2.
        if (l_funclist_flag = TRUE) then
           l_aggregate_predicate := '';
        elsif (p_statement_type = 'EXISTS') then
           l_aggregate_predicate := 'EXISTS (';
        elsif (l_grants_only_flag = TRUE) then
           l_aggregate_predicate := '';
        else /* This is the normal case */
           l_aggregate_predicate := '('||l_pk_orig_column_names || ') IN (';
        end if;

        IF (l_menulist_flag = TRUE) then
           l_aggregate_predicate := l_aggregate_predicate ||
                  'SELECT unique to_char(GNT.MENU_ID) '||
                   ' FROM fnd_grants GNT, ' ||
                          l_db_object_name||' OBJTAB'||
                 ' WHERE ';
        ELSIF(l_funclist_flag = TRUE) THEN
           l_aggregate_predicate := l_aggregate_predicate ||
                 'SELECT unique FF.FUNCTION_NAME '||
                  ' FROM fnd_grants GNT, ' ||
                         l_db_object_name||' OBJTAB, '||
                         'fnd_compiled_menu_functions CMF, '||
                         'fnd_form_functions FF '||
                 ' WHERE ';
        ELSIF (l_grants_only_flag = TRUE) then
           NULL;
        ELSE
           l_aggregate_predicate := l_aggregate_predicate ||
              ' SELECT '|| l_pk_column_names ||
                ' FROM fnd_grants GNT';
           IF ((l_instance_flag = TRUE) OR (l_instance_set_flag = TRUE)) then
              l_aggregate_predicate := l_aggregate_predicate ||
                          ', '||l_db_object_name||' OBJTAB';
           END IF;
           l_aggregate_predicate := l_aggregate_predicate || ' WHERE ';
        END IF;

        --Changes for Bug#3867925
        -- Fix Non Backward change made for universal person support
        --
        -- Performance note: This statement has not received the optimizations
        -- to the WF User portion of the SQL because the separation of the
        -- USER and GROUP clauses prevent that.  Since this is only used for
        -- deprecated code that is okay.
         colon := instr(p_user_name, 'PER:');
         if (colon <> 0) then
             l_aggregate_predicate :=
                          l_aggregate_predicate ||
                           ' GNT.object_id = ' || l_object_id ||
                           ' AND ((GNT.grantee_type = ''USER'' ' ||
                                  ' AND GNT.grantee_key = '''||
                                     replace(l_user_name,'''','''''')||''')'||
                                  ' OR (GNT.grantee_type = ''GROUP'' '||
                                     ' AND GNT.grantee_key in ';
             l_aggregate_predicate := l_aggregate_predicate ||
                 ' (select role_name '||
                 ' from wf_user_roles wur '||
                 ' where wur.user_name in '||
                  ' ( (select '||
                      ' '''||replace(l_user_name,'''','''''')||''' '||
                          ' from dual) '||
                         ' union all '||
                   ' (select incrns.name from wf_local_roles incrns, '||
                                             ' fnd_user f '||
                     ' where ''HZ_PARTY''       = incrns.orig_system '||
                       ' and f.user_name           = '||
                        ' '''||replace(l_user_name,'''','''''')||''' '||
                       ' and f.person_party_id  = incrns.orig_system_id)))) '||
                     ' OR (GNT.grantee_type = ''GLOBAL''))';
         else
             l_aggregate_predicate :=
                l_aggregate_predicate ||
               ' GNT.object_id = ' || l_object_id ||
               ' AND (GNT.grantee_key in '||
                 ' (select role_name '||
                 ' from wf_user_roles wur, '||
                  ' ( select '||
                      ' '''||replace(l_user_name,'''','''''')||''' '||
                          ' name from dual '||
                       ' union all '||
                   ' (select incrns.name from wf_local_roles incrns, '||
                                             ' fnd_user f '||
                     ' where ''HZ_PARTY''       = incrns.orig_system '||
                       ' and f.user_name           = '||
                        ' '''||replace(l_user_name,'''','''''')||''' '||
                       ' and f.person_party_id  = incrns.orig_system_id '||
                       ' and incrns.partition_id  = 9 ) '||
                   ' ) incr2 '||
                   ' where wur.user_name = incr2.name '||
                      ' union all '||
                   ' select ''GLOBAL'' from dual))';
        end if;
        if (l_function_id <> -1) then
            l_aggregate_predicate := l_aggregate_predicate ||
           ' AND GNT.menu_id in'||
              ' (select cmf.menu_id'||
                 ' from fnd_compiled_menu_functions cmf'||
                ' where cmf.function_id = '||l_function_id||')';
        end if;
        l_aggregate_predicate := l_aggregate_predicate ||
           ' AND(   GNT.ctx_secgrp_id = -1'||
               ' OR GNT.ctx_secgrp_id  = '||
                  ' SYS_CONTEXT(''FND'',''SECURITY_GROUP_ID''))'||
           ' AND(   GNT.ctx_resp_id = -1'||
               ' OR GNT.ctx_resp_id = '||
                  ' SYS_CONTEXT(''FND'',''RESP_ID''))'||
           ' AND(   GNT.ctx_resp_appl_id = -1'||
               ' OR GNT.ctx_resp_appl_id ='||
                  ' SYS_CONTEXT(''FND'',''RESP_APPL_ID''))'||
           ' AND(   GNT.ctx_org_id = -1'||
               ' OR GNT.ctx_org_id ='||
                  ' SYS_CONTEXT(''FND'', ''ORG_ID''))'||
           ' AND GNT.start_date <= sysdate ' ||
           ' AND (    GNT.end_date IS NULL ' ||
                ' OR GNT.end_date >= sysdate ) ';
        IF(l_funclist_flag = TRUE) THEN
           if (l_menulist_flag = FALSE) then /* usual case */
             l_aggregate_predicate := l_aggregate_predicate ||
             ' AND CMF.MENU_ID = GNT.MENU_ID '||
             ' AND CMF.FUNCTION_ID = FF.FUNCTION_ID ';
           end if;
           /* Add on the clause that */
           /* gives bind vars for an exact pk match */
           IF ((l_instance_flag = TRUE) OR (l_instance_set_flag = TRUE)) then
              l_aggregate_predicate := l_aggregate_predicate ||
               ' AND '||l_exact_clause;
           END IF;
           if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
             fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               c_log_head || l_api_name || '.step2astart','step2astart');
           end if;
        END IF;
        if(l_grants_only_flag = FALSE) then
        l_aggregate_predicate := l_aggregate_predicate ||
           ' AND(';
        end if;
        IF(l_instance_flag = TRUE) THEN
           /* Add on the clause for INSTANCE_TYPE = 'INSTANCE' */
           l_aggregate_predicate := l_aggregate_predicate || l_ik_clause;
           if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
             fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               c_log_head || l_api_name || '.step2start','step2start');
           end if;
        END IF;
        IF(l_instance_set_flag = TRUE) THEN
           /* Add on the clause for INSTANCE_TYPE = 'SET' */
           if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
             fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               c_log_head || l_api_name || '.step3start',
               ' user_name: '|| l_user_name ||
               ' function: '|| p_function ||
               ' l_object_id: '|| l_object_id);
           end if;
           l_set_predicates:='';


           if (l_user_name <> 'GUEST') then

             --Changes for Bug#3867925
             -- Fix Non Backward change made for universal person support
             if (colon <> 0) then
                FOR instance_set_grants_bkwd_rec IN
                       instance_set_grants_bkwd_c (l_user_name,
                                                   l_function_id,
                                                   l_object_id)
                LOOP
                  /* Upgrade and substitute predicate */
                  l_pred := upgrade_predicate(
                                     instance_set_grants_bkwd_rec.predicate);

                  if (fnd_log.LEVEL_STATEMENT >=
                      fnd_log.g_current_runtime_level) then
                    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                         c_log_head || l_api_name || '.upgd_pred',
                         'l_pred:'||l_pred);
                  end if;

                  /* in funclist mode, alias is 'OBJTAB'*/
                  if (l_funclist_flag OR l_menulist_flag) then
                    l_pred := substitute_predicate(
                                     l_pred,
                                     'OBJTAB');
                  else
                    l_pred := substitute_predicate(
                                     l_pred,
                                     p_table_alias);
                  end if;
                  if (fnd_log.LEVEL_STATEMENT >=
                      fnd_log.g_current_runtime_level) then
                    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                         c_log_head || l_api_name || '.subbed_pred',
                         'l_pred:'||l_pred);
                  end if;

                  l_set_predicates  :=  substrb( l_set_predicates  ||
                       ' (  (gnt.instance_set_id = '||
                             instance_set_grants_bkwd_rec.instance_set_id ||
                         '  ) AND ('||
                             l_pred ||
                          ' )) OR ', 1, c_pred_buf_size);
                   if (fnd_log.LEVEL_STATEMENT >=
                       fnd_log.g_current_runtime_level) then
                     fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                         c_log_head || l_api_name || '.step3loop',
                         ' l_set_predicates: ' || l_set_predicates);
                   end if;
                END LOOP;
              else
                  FOR instance_set_grants_rec
                   IN instance_set_grants_c (l_user_name,
                                             l_function_id,
                                             l_object_id)
                  LOOP
                    /* Upgrade and substitute predicate */
                    l_pred := upgrade_predicate(
                                       instance_set_grants_rec.predicate);

                    if (fnd_log.LEVEL_STATEMENT >=
                        fnd_log.g_current_runtime_level) then
                      fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                           c_log_head || l_api_name || '.upgd_pred',
                           'l_pred:'||l_pred);
                    end if;

                    /* in funclist mode, alias is 'OBJTAB'*/
                    if (l_funclist_flag OR l_menulist_flag) then
                      l_pred := substitute_predicate(
                                       l_pred,
                                       'OBJTAB');
                    else
                      l_pred := substitute_predicate(
                                       l_pred,
                                       p_table_alias);
                    end if;
                    if (fnd_log.LEVEL_STATEMENT >=
                        fnd_log.g_current_runtime_level) then
                      fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                           c_log_head || l_api_name || '.subbed_pred',
                           'l_pred:'||l_pred);
                    end if;

                    l_set_predicates  :=  substrb( l_set_predicates  ||
                         ' (  (gnt.instance_set_id = '||
                               instance_set_grants_rec.instance_set_id ||
                           '  ) AND ('||
                               l_pred ||
                            ' )) OR ', 1, c_pred_buf_size);
                     if (fnd_log.LEVEL_STATEMENT >=
                         fnd_log.g_current_runtime_level) then
                       fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                           c_log_head || l_api_name || '.step3loop',
                           ' l_set_predicates: ' || l_set_predicates);
                     end if;
                  END LOOP;
              end if;
           else

            -- Handle for user GUEST
            FOR instance_set_grants_guest_rec IN
                    instance_set_grants_guest_c (l_user_name,
                                                 l_function_id,
                                                 l_object_id)
            LOOP
              /* Upgrade and substitute predicate */
              l_pred := upgrade_predicate(
                                 instance_set_grants_guest_rec.predicate);

              if (fnd_log.LEVEL_STATEMENT >=
                  fnd_log.g_current_runtime_level) then
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     c_log_head || l_api_name || '.upgd_pred',
                     'l_pred:'||l_pred);
              end if;

              /* in funclist mode, alias is 'OBJTAB'*/
              if (l_funclist_flag OR l_menulist_flag) then
                l_pred := substitute_predicate(
                                 l_pred,
                                 'OBJTAB');
              else
                l_pred := substitute_predicate(
                                 l_pred,
                                 p_table_alias);
              end if;
              if (fnd_log.LEVEL_STATEMENT >=
                  fnd_log.g_current_runtime_level) then
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     c_log_head || l_api_name || '.subbed_pred',
                     'l_pred:'||l_pred);
              end if;

              l_set_predicates  :=  substrb( l_set_predicates  ||
                   ' (  (gnt.instance_set_id = '||
                         instance_set_grants_guest_rec.instance_set_id ||
                     '  ) AND ('||
                         l_pred ||
                      ' )) OR ', 1, c_pred_buf_size);
               if (fnd_log.LEVEL_STATEMENT >=
                   fnd_log.g_current_runtime_level) then
                 fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     c_log_head || l_api_name || '.step3loop',
                     ' l_set_predicates: ' || l_set_predicates);
               end if;
            END LOOP;
           end if;

           IF( length(l_set_predicates ) >0) THEN
              -- strip off the trailing 'OR '
              l_set_predicates := substr(l_set_predicates, 1,
                             length(l_set_predicates) - length('OR '));

              if (l_instance_flag = TRUE) then /* If necc, add OR on front*/
                 l_aggregate_predicate := substrb(
                           l_aggregate_predicate || ' OR',
                           1, c_pred_buf_size);
              end if;
              l_aggregate_predicate := substrb(
                        l_aggregate_predicate ||
                        ' ( (gnt.instance_type = ''SET'') AND ( ' ||
                        l_set_predicates ||'))',
                        1, c_pred_buf_size);
              if (fnd_log.LEVEL_STATEMENT >=
                  fnd_log.g_current_runtime_level) then
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                    c_log_head || l_api_name || '.setpreds',
                    ' l_aggregate_predicate: ' || l_aggregate_predicate);
              end if;
           ELSE
              /* If there weren't any instance sets and not instance mode,
              /* predicate will not return any rows, so just return '1=2' */
              if (l_instance_flag = FALSE) then
                 x_predicate := '(1=2)';
                 if (fnd_log.LEVEL_PROCEDURE >=
                     fnd_log.g_current_runtime_level) then
                   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                      c_log_head || l_api_name || '.end_no_row_pred',
                      'x_predicate: '|| x_predicate ||
                      ', x_return_status:'||x_return_status);
                 end if;
                 x_return_status := 'T';
                 return;
              end if;
           END IF;
        END IF;

        /* Add the clause for the global */
        IF ((l_instance_flag = TRUE) OR (l_instance_set_flag = TRUE)) then
                 l_aggregate_predicate := substrb(
                           l_aggregate_predicate || ' OR',
                           1, c_pred_buf_size);
        END IF;
        IF (l_grants_only_flag = FALSE) then
          l_aggregate_predicate := substrb( l_aggregate_predicate ||
                        ' (    (gnt.instance_type = ''GLOBAL'')'||
                        /* The object_id here isn't functionally necessary */
                        /* since it appears elsewhere in the SQL but putting */
                        /* it here helps the CBO choose a good plan; removing*/
                        /* made the whole stmnt several times slower. */
                         ' AND (gnt.object_id = '||l_object_id||'))',
                        1, c_pred_buf_size);
        end if;

        IF (l_grants_only_flag = FALSE) then
          /* Close off parenthesis 'AND (' that started instance/set clauses*/
          l_aggregate_predicate  :=  substrb( l_aggregate_predicate||')',
                                       1, c_pred_buf_size);
          if (l_funclist_flag = FALSE) then /* Close off subselect parens */

              l_aggregate_predicate  :=  substrb( l_aggregate_predicate||')',
                                       1, c_pred_buf_size);
          end if;
        end if;


        /* Put parentheses around the statement in order to make it */
        /* amenable to ANDing with another statement */
        if(    (p_statement_type <> 'EXISTS')
           AND (l_funclist_flag = FALSE)
           AND (l_grants_only_flag = FALSE)) then
          /* tmorrow- for bug 4592098 added substr to prevent buf overflows*/
          x_predicate := substrb(
                           '('||l_aggregate_predicate||')',
                           1, c_pred_buf_size);
        else
          x_predicate :=l_aggregate_predicate;
        end if;

        if (g_vpd_buf_limit = -1) then /* If not initialized */
          g_vpd_buf_limit := self_init_pred_size(); /* init from db version */
        end if;

        /* tmorrow- for bug 4592098 check x_predicate rather than l_aggreg..*/
        if (    (lengthb(x_predicate) > g_vpd_buf_limit)
            AND (   (p_statement_type = 'VPD')
                 OR (p_statement_type = 'BASE'/* deprecated */)))then
           FND_MESSAGE.SET_NAME('FND', 'GENERIC-INTERNAL ERROR');
           FND_MESSAGE.SET_TOKEN('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
           FND_MESSAGE.SET_TOKEN('REASON',
            'The predicate was longer than the database VPD limit of '||
            to_char(g_vpd_buf_limit)||' bytes for the predicate.  ');

           if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
             fnd_log.message(FND_LOG.LEVEL_PROCEDURE,
                   c_log_head || l_api_name || '.end',
                  FALSE);
           end if;
           x_return_status := 'L'; /* Indicate Error */

        end if;

   EXCEPTION
         /* If API called with deprecated p_user_name arg, */
         /* propagate that up so the caller gets exception */
         WHEN FND_MESSAGE_RAISED_ERR THEN
             /* Re raise the error for the caller */
             fnd_message.raise_error;

             x_return_status := 'U';  /* This line should never be executed */
             return;

        WHEN OTHERS THEN
            fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
            fnd_message.set_token('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
            fnd_message.set_token('ERRNO', SQLCODE);
            fnd_message.set_token('REASON', SQLERRM);

            if (fnd_log.LEVEL_EXCEPTION >=
                fnd_log.g_current_runtime_level) then
              fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.other_err',
                     FALSE);
            end if;
            x_return_status := 'U';
            if (fnd_log.LEVEL_PROCEDURE >=
                fnd_log.g_current_runtime_level) then
              fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                   c_log_head || l_api_name || '.end_after_other',
                  'x_predicate: '|| x_predicate ||
                  ', x_return_status:'||x_return_status);
            end if;
            return;
  END get_security_predicate_helper;
-------------------------------------------------------------------------------

  ----- Not for external use.
  ----- Internal routine which actually implements get_security_predicate.
  ----- This is the routine called by get_security_predicate[_w_binds]
  --------------------------------------------
  PROCEDURE get_security_predicate_intrnl(
    p_api_version      IN  NUMBER,
    p_function         IN  VARCHAR2,
    p_object_name      IN  VARCHAR2,
    p_grant_instance_type  IN  VARCHAR2,/* SET, INSTANCE*/
                           /* Undocumented value: FUNCLIST, FUNCLIST_NOINST */
                           /* Documented value: GRANTS_ONLY */
    p_user_name        IN  VARCHAR2,
    /* stmnt_type: 'OTHER', 'VPD'=VPD, 'EXISTS'= for checking existence. */
    p_statement_type   IN  VARCHAR2,
    p_table_alias      IN  VARCHAR2,
    p_with_binds       IN  VARCHAR2,
    x_predicate        out NOCOPY varchar2,
    x_return_status    out NOCOPY varchar2,
    x_function_id      out NOCOPY NUMBER,
    x_object_id        out NOCOPY NUMBER,
    x_bind_order       out NOCOPY VARCHAR2
  )  IS

        l_api_name   CONSTANT VARCHAR2(30)      := 'GET_SECURITY_PREDICATE';

        -- On addition of any Required parameters the major version needs
        -- to change i.e. for eg. 1.X to 2.X.
        -- On addition of any Optional parameters the minor version needs
        -- to change i.e. for eg. X.6 to X.7.
        l_api_version           CONSTANT NUMBER := 1.0;
    l_sysdate              DATE := Sysdate;
    l_aggregate_predicate   VARCHAR2(32767); /* Must match c_pred_buf_size*/
    l_instance_predicate    VARCHAR2(32767); /* Must match c_pred_buf_size*/
    l_instance_flag         BOOLEAN   := TRUE;
    l_instance_set_flag     BOOLEAN   := TRUE;
    l_inst_group_grantee_type  BOOLEAN   := FALSE;
    l_inst_global_grantee_type BOOLEAN   := FALSE;
    l_set_group_grantee_type   BOOLEAN   := FALSE;
    l_set_global_grantee_type  BOOLEAN   := FALSE;
    l_inst_instance_type    BOOLEAN   := FALSE;
    l_set_instance_type     BOOLEAN   := FALSE;
    l_global_instance_type  BOOLEAN   := FALSE;
    l_db_object_name        varchar2(30);
    l_db_pk1_column         varchar2(256);
    l_db_pk2_column         varchar2(256);
    l_db_pk3_column         varchar2(256);
    l_db_pk4_column         varchar2(256);
    l_db_pk5_column         varchar2(256);
    l_pk_column_names       varchar2(512);
    l_pk_orig_column_names  varchar2(512);
    l_ik_clause             varchar2(2048);
    l_exact_clause          varchar2(2048);
    l_user_name_bind        varchar2(255);
    l_user_name             varchar2(80);
    l_nrows                 pls_integer;
    l_table_alias           varchar2(256);
    l_last_instance_set_id  NUMBER;
    l_last_pred             varchar2(4000);
    l_need_to_close_pred    BOOLEAN;
    l_refers_to_grants      BOOLEAN;
    l_last_was_hextoraw     BOOLEAN;
    l_pred                  varchar2(4000);
    l_uses_params           BOOLEAN;
    d_predicate             VARCHAR2(4000);
    d_instance_set_id       number;
    d_grant_guid            RAW(16);
    l_grp_glob_fn           BOOLEAN;
    l_grp_glob_nofn         BOOLEAN;
    l_glob_fn               BOOLEAN;
    l_glob_nofn             BOOLEAN;
    l_grp_fn                BOOLEAN;
    l_grp_nofn              BOOLEAN;
    l_cursor_is_open        BOOLEAN;
    l_dummy                 NUMBER;
    colon                   PLS_INTEGER;
    l_pop_message           BOOLEAN;

    /* This cursor determines if there are any grants to GLOBAL grantee, */
    /* for a particular instance type */
    CURSOR grant_types_global_c (cp_user_name       varchar2,
                                  cp_function_id NUMBER,
                                  cp_object_id VARCHAR2,
                                  cp_instance_type VARCHAR2)
        IS
         select 1 from
          dual
         where exists
         (
         SELECT  1
           FROM fnd_grants g
          WHERE  (g.grantee_type = 'GLOBAL')
            AND g.object_id = cp_object_id
            AND (   (cp_function_id = -1)
                 OR (g.menu_id in
                      (select cmf.menu_id
                         from fnd_compiled_menu_functions cmf
                        where cmf.function_id = cp_function_id)))
            AND (   g.ctx_secgrp_id    = -1
                 OR g.ctx_secgrp_id    =
                                   SYS_CONTEXT('FND','SECURITY_GROUP_ID'))
            AND (   g.ctx_resp_id      = -1
                 OR g.ctx_resp_id      = SYS_CONTEXT('FND','RESP_ID'))
            AND (   g.ctx_resp_appl_id = -1
                 OR g.ctx_resp_appl_id = SYS_CONTEXT('FND','RESP_APPL_ID'))
            AND (   g.ctx_org_id       = -1
                 OR g.ctx_org_id       = SYS_CONTEXT('FND', 'ORG_ID'))
            AND g.start_date <= SYSDATE
            AND (   g.end_date IS NULL
                 OR g.end_date >= SYSDATE )
            AND g.instance_type = cp_instance_type
          );


        --Changes for Bug#3867925
        -- Fix Non Backward change made for universal person support
        --
        -- Performance note: This statement has not received the optimizations
        -- to the WF User portion of the SQL because the separation of the
        -- USER and GROUP clauses prevent that.  Since this is only used for
        -- deprecated code that is okay.
        CURSOR grant_types_group_bkwd_c(cp_user_name       varchar2,
                                  cp_function_id NUMBER,
                                  cp_object_id VARCHAR2,
                                  cp_instance_type VARCHAR2)
        IS
         select 1
         from dual
         where exists
              (
               select 1
               from fnd_grants g
               where (( g.grantee_type = 'USER'
                       AND g.grantee_key = cp_user_name)
                    OR (g.grantee_type = 'GROUP'
                       AND (g.grantee_key in
                  (select role_name
                   from wf_user_roles wur
                  where wur.user_name in
                   ( (select cp_user_name from dual)
                          union all
                     (select incrns.name from wf_local_roles incrns, fnd_user f
                       where 'HZ_PARTY'       = incrns.orig_system
                         and f.user_name           = cp_user_name
                         and f.person_party_id  = incrns.orig_system_id))))))
              and g.object_id = cp_object_id
              and ((cp_function_id = -1)
                   or (g.menu_id in
                        (select cmf.menu_id
                           from fnd_compiled_menu_functions cmf
                          where cmf.function_id = cp_function_id)))
              and (   g.ctx_secgrp_id    = -1
                   or g.ctx_secgrp_id    =
                               SYS_CONTEXT('FND','SECURITY_GROUP_ID'))
              and (   g.ctx_resp_id      = -1
                   OR g.ctx_resp_id      = SYS_CONTEXT('FND','RESP_ID'))
              and (   g.ctx_resp_appl_id = -1
                   OR g.ctx_resp_appl_id = SYS_CONTEXT('FND','RESP_APPL_ID'))
              and (   g.ctx_org_id       = -1
                   OR g.ctx_org_id       = SYS_CONTEXT('FND', 'ORG_ID'))
              and g.start_date <= SYSDATE
              and (   g.end_date IS NULL
                   OR g.end_date >= SYSDATE )
              and g.instance_type = cp_instance_type
          );


    /* This cursor determines if there are any grants to USER or GROUP */
    /* grantee, for a particular instance type */
    CURSOR grant_types_group_c (cp_user_name     varchar2,
                                cp_function_id   NUMBER,
                                cp_object_id     VARCHAR2,
                                cp_instance_type VARCHAR2)
        IS
         select 1 from
          dual
         where exists
         (
         SELECT  /*+ leading(u2) use_nl(g) index(g,FND_GRANTS_N9) */ 'X'
           FROM
            ( select /*+ NO_MERGE */  role_name
              from wf_user_roles wur,
                (
                select cp_user_name name from dual
                  union all
                select incr1.name name
                  from wf_local_roles incr1, fnd_user u1
                 where 'HZ_PARTY'           = incr1.orig_system
                   and u1.user_name         = cp_user_name
                   and u1.person_party_id   = incr1.orig_system_id
                   and incr1.partition_id  = 9 /* HZ_PARTY */
                 ) incr2
              where wur.user_name = incr2.name
             ) u2,
             fnd_grants g
         WHERE rownum = 1
              AND g.grantee_key = u2.role_name
              and g.object_id = cp_object_id
              and ((cp_function_id = -1)
                   or (g.menu_id in
                        (select cmf.menu_id
                           from fnd_compiled_menu_functions cmf
                          where cmf.function_id = cp_function_id)))
              and (   g.ctx_secgrp_id    = -1
                   or g.ctx_secgrp_id    =
                                 SYS_CONTEXT('FND','SECURITY_GROUP_ID'))
              and (   g.ctx_resp_id      = -1
                   OR g.ctx_resp_id      = SYS_CONTEXT('FND','RESP_ID'))
              and (   g.ctx_resp_appl_id = -1
                   OR g.ctx_resp_appl_id = SYS_CONTEXT('FND','RESP_APPL_ID'))
              and (   g.ctx_org_id       = -1
                   OR g.ctx_org_id       = SYS_CONTEXT('FND', 'ORG_ID'))
              and g.start_date <= SYSDATE
              and (   g.end_date IS NULL
                   OR g.end_date >= SYSDATE )
              and g.instance_type = cp_instance_type
          );

    /*
    ** Note: following are six different cursors that leave out or
    ** include different combinations of the following 3 things:
    ** Group grantee type (includes User grantee type)
    ** Global grantee type
    ** function_id (left out if function_id = -1 meaning all functions)
    ** Besides those three clauses, the cursors are the same and should
    ** all be maintained with whatever changes are made to any one.
    */

    /* Which instance sets are granted to specific function? */
    CURSOR isg_grp_glob_fn_c (cp_user_name       varchar2,
                                  cp_function_id NUMBER,
                                  cp_object_id VARCHAR2)
        IS
         SELECT  /*+ leading(u2) use_nl(g) index(g,FND_GRANTS_N9) */
                 instance_sets.predicate, instance_sets.instance_set_id,
                 g.grant_guid
           FROM
            ( select /*+ NO_MERGE */ 'GLOBAL' role_name from dual
               union all
              select  role_name
              from wf_user_roles wur,
                (
                select cp_user_name name from dual
                  union all
                select incr1.name name
                  from wf_local_roles incr1, fnd_user u1
                 where 'HZ_PARTY'           = incr1.orig_system
                   and u1.user_name         = cp_user_name
                   and u1.person_party_id   = incr1.orig_system_id
                   and incr1.partition_id  = 9 /* HZ_PARTY */
                 ) incr2
              where wur.user_name = incr2.name
             ) u2,
             fnd_grants g,
             fnd_object_instance_sets instance_sets
          WHERE g.grantee_key = u2.role_name
            AND g.instance_type = 'SET'
            AND g.object_id = cp_object_id
            AND (g.menu_id in
                      (select cmf.menu_id
                         from fnd_compiled_menu_functions cmf
                        where cmf.function_id = cp_function_id))
            AND g.instance_set_id = instance_sets.instance_set_id
            AND (   g.ctx_secgrp_id    = -1
                 OR g.ctx_secgrp_id    =
                                     SYS_CONTEXT('FND','SECURITY_GROUP_ID'))
            AND (   g.ctx_resp_id      = -1
                 OR g.ctx_resp_id      = SYS_CONTEXT('FND','RESP_ID'))
            AND (   g.ctx_resp_appl_id = -1
                 OR g.ctx_resp_appl_id = SYS_CONTEXT('FND','RESP_APPL_ID'))
            AND (   g.ctx_org_id       = -1
                 OR g.ctx_org_id       = SYS_CONTEXT('FND', 'ORG_ID'))
            AND g.start_date <= SYSDATE
            AND (   g.end_date IS NULL
                 OR g.end_date >= SYSDATE )
          ORDER BY instance_sets.predicate,
                   instance_sets.instance_set_id desc;

    /* Which instance sets are granted for any function?   */
    CURSOR isg_grp_glob_nofn_c (cp_user_name       varchar2,
                                  cp_object_id VARCHAR2)
        IS
         SELECT  /*+ leading(u2) use_nl(g) index(g,FND_GRANTS_N9) */
                 instance_sets.predicate, instance_sets.instance_set_id,
                 g.grant_guid
           FROM
            ( select /*+ NO_MERGE */ 'GLOBAL' role_name from dual
               union all
              select  role_name
              from wf_user_roles wur,
                (
                select cp_user_name name from dual
                  union all
                select incr1.name name
                  from wf_local_roles incr1, fnd_user u1
                 where 'HZ_PARTY'           = incr1.orig_system
                   and u1.user_name         = cp_user_name
                   and u1.person_party_id   = incr1.orig_system_id
                   and incr1.partition_id  = 9 /* HZ_PARTY */
                 ) incr2
              where wur.user_name = incr2.name
             ) u2,
             fnd_grants g,
             fnd_object_instance_sets instance_sets
          WHERE g.grantee_key = u2.role_name
            AND g.object_id = cp_object_id
            AND g.instance_set_id = instance_sets.instance_set_id
            AND (   g.ctx_secgrp_id    = -1
                 OR g.ctx_secgrp_id    =
                                   SYS_CONTEXT('FND','SECURITY_GROUP_ID'))
            AND (   g.ctx_resp_id      = -1
                 OR g.ctx_resp_id      = SYS_CONTEXT('FND','RESP_ID'))
            AND (   g.ctx_resp_appl_id = -1
                 OR g.ctx_resp_appl_id = SYS_CONTEXT('FND','RESP_APPL_ID'))
            AND (   g.ctx_org_id       = -1
                 OR g.ctx_org_id       = SYS_CONTEXT('FND', 'ORG_ID'))
            AND g.start_date <= SYSDATE
            AND (   g.end_date IS NULL
                 OR g.end_date >= SYSDATE )
          ORDER BY instance_sets.predicate,
                   instance_sets.instance_set_id desc;

     --Changes for Bug#3867925
     -- Fix Non Backward change made for universal person support
     --
     -- Performance note: This statement has not received the optimizations
     -- to the WF User portion of the SQL because the separation of the
     -- USER and GROUP clauses prevent that.  Since this is only used for
     -- deprecated code that is okay.
     CURSOR isg_grp_glob_nofn_bkwd_c (cp_user_name varchar2,
                                        cp_object_id VARCHAR2)
        IS
         SELECT instance_sets.predicate, instance_sets.instance_set_id,
                g.grant_guid
           FROM fnd_grants g,
                fnd_object_instance_sets instance_sets
          WHERE g.instance_type = 'SET'
          AND(     (g.grantee_type = 'USER'
                  AND g.grantee_key = cp_user_name)
                OR (g.grantee_type = 'GROUP'
                  AND (g.grantee_key in
                  (select role_name
                   from wf_user_roles wur
                  where wur.user_name in
                   ( (select cp_user_name from dual)
                          union all
                     (select incrns.name from wf_local_roles incrns, fnd_user f
                       where 'HZ_PARTY'       = incrns.orig_system
                         and f.user_name           = cp_user_name
                         and f.person_party_id  = incrns.orig_system_id)))))
                 OR (g.grantee_type = 'GLOBAL'))
            AND g.object_id = cp_object_id
            AND g.instance_set_id = instance_sets.instance_set_id
            AND (   g.ctx_secgrp_id    = -1
                 OR g.ctx_secgrp_id    =
                                   SYS_CONTEXT('FND','SECURITY_GROUP_ID'))
            AND (   g.ctx_resp_id      = -1
                 OR g.ctx_resp_id      = SYS_CONTEXT('FND','RESP_ID'))
            AND (   g.ctx_resp_appl_id = -1
                 OR g.ctx_resp_appl_id = SYS_CONTEXT('FND','RESP_APPL_ID'))
            AND (   g.ctx_org_id       = -1
                 OR g.ctx_org_id       = SYS_CONTEXT('FND', 'ORG_ID'))
            AND g.start_date <= SYSDATE
            AND (   g.end_date IS NULL
                 OR g.end_date >= SYSDATE )
          ORDER BY instance_sets.predicate,
                   instance_sets.instance_set_id desc;

    /* Which instance sets are granted to specific function? */
    CURSOR isg_grp_fn_c (cp_user_name       varchar2,
                                  cp_function_id NUMBER,
                                  cp_object_id VARCHAR2)
        IS
         SELECT  /*+ leading(u2) use_nl(g) index(g,FND_GRANTS_N9) */
                 instance_sets.predicate, instance_sets.instance_set_id,
                 g.grant_guid
           FROM
            ( select /*+ NO_MERGE */  role_name
              from wf_user_roles wur,
                (
                select cp_user_name name from dual
                  union all
                select incr1.name name
                  from wf_local_roles incr1, fnd_user u1
                 where 'HZ_PARTY'           = incr1.orig_system
                   and u1.user_name         = cp_user_name
                   and u1.person_party_id   = incr1.orig_system_id
                   and incr1.partition_id  = 9 /* HZ_PARTY */
                 ) incr2
              where wur.user_name = incr2.name
             ) u2,
             fnd_grants g,
             fnd_object_instance_sets instance_sets
          WHERE g.grantee_key = u2.role_name
            AND g.object_id = cp_object_id
            AND (g.menu_id in
                      (select cmf.menu_id
                         from fnd_compiled_menu_functions cmf
                        where cmf.function_id = cp_function_id))
            AND g.instance_set_id = instance_sets.instance_set_id
            AND (   g.ctx_secgrp_id    = -1
                 OR g.ctx_secgrp_id    =
                                    SYS_CONTEXT('FND','SECURITY_GROUP_ID'))
            AND (   g.ctx_resp_id      = -1
                 OR g.ctx_resp_id      = SYS_CONTEXT('FND','RESP_ID'))
            AND (   g.ctx_resp_appl_id = -1
                 OR g.ctx_resp_appl_id = SYS_CONTEXT('FND','RESP_APPL_ID'))
            AND (   g.ctx_org_id       = -1
                 OR g.ctx_org_id       = SYS_CONTEXT('FND', 'ORG_ID'))
            AND g.start_date <= SYSDATE
            AND (   g.end_date IS NULL
                 OR g.end_date >= SYSDATE )
          ORDER BY instance_sets.predicate,
                   instance_sets.instance_set_id desc;

        --Changes for Bug#3867925
        -- Fix Non Backward change made for universal person support
        --
        -- Performance note: This statement has not received the optimizations
        -- to the WF User portion of the SQL because the separation of the
        -- USER and GROUP clauses prevent that.  Since this is only used for
        -- deprecated code that is okay.
        CURSOR isg_grp_fn_bkwd_c (cp_user_name varchar2,
                                  cp_function_id NUMBER,
                                  cp_object_id VARCHAR2)
        IS
         SELECT instance_sets.predicate, instance_sets.instance_set_id,
                g.grant_guid
           FROM fnd_grants g,
                fnd_object_instance_sets instance_sets
          WHERE g.instance_type = 'SET'
           AND  (         (g.grantee_type = 'USER'
                       AND g.grantee_key = cp_user_name)
                   OR (    g.grantee_type = 'GROUP'
                       AND (g.grantee_key in
                  (select role_name
                   from wf_user_roles wur
                  where wur.user_name in
                   ( (select cp_user_name from dual)
                          union all
                     (select incrns.name from wf_local_roles incrns, fnd_user f
                       where 'HZ_PARTY'       = incrns.orig_system
                         and f.user_name           = cp_user_name
                         and f.person_party_id  = incrns.orig_system_id))))))
            AND g.object_id = cp_object_id
            AND (g.menu_id in
                      (select cmf.menu_id
                         from fnd_compiled_menu_functions cmf
                        where cmf.function_id = cp_function_id))
            AND g.instance_set_id = instance_sets.instance_set_id
            AND (   g.ctx_secgrp_id    = -1
                 OR g.ctx_secgrp_id    =
                                    SYS_CONTEXT('FND','SECURITY_GROUP_ID'))
            AND (   g.ctx_resp_id      = -1
                 OR g.ctx_resp_id      = SYS_CONTEXT('FND','RESP_ID'))
            AND (   g.ctx_resp_appl_id = -1
                 OR g.ctx_resp_appl_id = SYS_CONTEXT('FND','RESP_APPL_ID'))
            AND (   g.ctx_org_id       = -1
                 OR g.ctx_org_id       = SYS_CONTEXT('FND', 'ORG_ID'))
            AND g.start_date <= SYSDATE
            AND (   g.end_date IS NULL
                 OR g.end_date >= SYSDATE )
          ORDER BY instance_sets.predicate,
                   instance_sets.instance_set_id desc;


    /* Which instance sets are granted for any function?   */
    CURSOR isg_grp_nofn_c (cp_user_name       varchar2,
                                  cp_object_id VARCHAR2)
        IS
         SELECT  /*+ leading(u2) use_nl(g) index(g,FND_GRANTS_N9) */
                 instance_sets.predicate, instance_sets.instance_set_id,
                 g.grant_guid
           FROM
            ( select /*+ NO_MERGE */  role_name
              from wf_user_roles wur,
                (
                select cp_user_name name from dual
                  union all
                select incr1.name name
                  from wf_local_roles incr1, fnd_user u1
                 where 'HZ_PARTY'           = incr1.orig_system
                   and u1.user_name         = cp_user_name
                   and u1.person_party_id   = incr1.orig_system_id
                   and incr1.partition_id  = 9 /* HZ_PARTY */
                 ) incr2
              where wur.user_name = incr2.name
             ) u2,
             fnd_grants g,
             fnd_object_instance_sets instance_sets
          WHERE g.grantee_key = u2.role_name
            AND g.object_id = cp_object_id
            AND g.instance_set_id = instance_sets.instance_set_id
            AND (   g.ctx_secgrp_id    = -1
                 OR g.ctx_secgrp_id    =
                                   SYS_CONTEXT('FND','SECURITY_GROUP_ID'))
            AND (   g.ctx_resp_id      = -1
                 OR g.ctx_resp_id      = SYS_CONTEXT('FND','RESP_ID'))
            AND (   g.ctx_resp_appl_id = -1
                 OR g.ctx_resp_appl_id = SYS_CONTEXT('FND','RESP_APPL_ID'))
            AND (   g.ctx_org_id       = -1
                 OR g.ctx_org_id       = SYS_CONTEXT('FND', 'ORG_ID'))
            AND g.start_date <= SYSDATE
            AND (   g.end_date IS NULL
                 OR g.end_date >= SYSDATE )
          ORDER BY instance_sets.predicate,
                   instance_sets.instance_set_id desc;

     --Changes for Bug#3867925
     -- Fix Non Backward change made for universal person support
     -- Performance note: This statement has not received the optimizations
     -- to the WF User portion of the SQL because the separation of the
     -- USER and GROUP clauses prevent that.  Since this is only used for
     -- deprecated code that is okay.
        CURSOR isg_grp_nofn_bkwd_c (cp_user_name varchar2,
                                  cp_object_id VARCHAR2)
        IS
        SELECT instance_sets.predicate, instance_sets.instance_set_id,
                g.grant_guid
        FROM fnd_grants g, fnd_object_instance_sets instance_sets
        WHERE g.instance_type = 'SET'
            AND  (        (g.grantee_type = 'USER'
                       AND g.grantee_key = cp_user_name)
                   OR     (g.grantee_type = 'GROUP'
                       AND (g.grantee_key in
                  (select role_name
                   from wf_user_roles wur
                  where wur.user_name in
                   ( (select cp_user_name from dual)
                          union all
                     (select incrns.name from wf_local_roles incrns, fnd_user f
                       where 'HZ_PARTY'       = incrns.orig_system
                         and f.user_name           = cp_user_name
                         and f.person_party_id  = incrns.orig_system_id))))))
            AND g.object_id = cp_object_id
            AND g.instance_set_id = instance_sets.instance_set_id
            AND (   g.ctx_secgrp_id    = -1
                 OR g.ctx_secgrp_id    =
                                   SYS_CONTEXT('FND','SECURITY_GROUP_ID'))
            AND (   g.ctx_resp_id      = -1
                 OR g.ctx_resp_id      = SYS_CONTEXT('FND','RESP_ID'))
            AND (   g.ctx_resp_appl_id = -1
                 OR g.ctx_resp_appl_id = SYS_CONTEXT('FND','RESP_APPL_ID'))
            AND (   g.ctx_org_id       = -1
                 OR g.ctx_org_id       = SYS_CONTEXT('FND', 'ORG_ID'))
            AND g.start_date <= SYSDATE
            AND (   g.end_date IS NULL
                 OR g.end_date >= SYSDATE )
          ORDER BY instance_sets.predicate,
                   instance_sets.instance_set_id desc;


    /* Which instance sets are granted to specific function? */
    CURSOR isg_glob_fn_c (cp_user_name       varchar2,
                                  cp_function_id NUMBER,
                                  cp_object_id VARCHAR2)
        IS
         SELECT instance_sets.predicate, instance_sets.instance_set_id,
                g.grant_guid
           FROM fnd_grants g,
                fnd_object_instance_sets instance_sets
          WHERE g.instance_type = 'SET'
            AND  (g.grantee_type = 'GLOBAL')
            AND g.object_id = cp_object_id
            AND (g.menu_id in
                      (select cmf.menu_id
                         from fnd_compiled_menu_functions cmf
                        where cmf.function_id = cp_function_id))
            AND g.instance_set_id = instance_sets.instance_set_id
            AND (   g.ctx_secgrp_id    = -1
                 OR g.ctx_secgrp_id    =
                                 SYS_CONTEXT('FND','SECURITY_GROUP_ID'))
            AND (   g.ctx_resp_id      = -1
                 OR g.ctx_resp_id      = SYS_CONTEXT('FND','RESP_ID'))
            AND (   g.ctx_resp_appl_id = -1
                 OR g.ctx_resp_appl_id = SYS_CONTEXT('FND','RESP_APPL_ID'))
            AND (   g.ctx_org_id       = -1
                 OR g.ctx_org_id       = SYS_CONTEXT('FND', 'ORG_ID'))
            AND g.start_date <= SYSDATE
            AND (   g.end_date IS NULL
                 OR g.end_date >= SYSDATE )
          ORDER BY instance_sets.predicate,
                   instance_sets.instance_set_id desc;

    /* Which instance sets are granted for any function?   */
    CURSOR isg_glob_nofn_c (cp_user_name       varchar2,
                                  cp_object_id VARCHAR2)
        IS
         SELECT instance_sets.predicate, instance_sets.instance_set_id,
                g.grant_guid
           FROM fnd_grants g,
                fnd_object_instance_sets instance_sets
          WHERE g.instance_type = 'SET'
            AND  (g.grantee_type = 'GLOBAL')
            AND g.object_id = cp_object_id
            AND g.instance_set_id = instance_sets.instance_set_id
            AND (   g.ctx_secgrp_id    = -1
                 OR g.ctx_secgrp_id    =
                              SYS_CONTEXT('FND','SECURITY_GROUP_ID'))
            AND (   g.ctx_resp_id      = -1
                 OR g.ctx_resp_id      = SYS_CONTEXT('FND','RESP_ID'))
            AND (   g.ctx_resp_appl_id = -1
                 OR g.ctx_resp_appl_id = SYS_CONTEXT('FND','RESP_APPL_ID'))
            AND (   g.ctx_org_id       = -1
                 OR g.ctx_org_id       = SYS_CONTEXT('FND', 'ORG_ID'))
            AND g.start_date <= SYSDATE
            AND (   g.end_date IS NULL
                 OR g.end_date >= SYSDATE )
          ORDER BY instance_sets.predicate,
                   instance_sets.instance_set_id desc;


     l_object_id number   := -2;
     l_function_id number := -2;

    BEGIN

      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name|| '(' ||
          'p_api_version=>'|| to_char(p_api_version) ||
          ', p_function=>'|| p_function ||
          ', p_object_name=>'|| p_object_name ||
          ', p_grant_instance_type=>'|| p_grant_instance_type ||
          ', p_user_name=>'|| p_user_name ||');');
       end if;

       x_function_id := NULL;
       x_object_id := NULL;
       x_bind_order := NULL;
       x_predicate := NULL;
       x_return_status := 'T'; /* Assume Success */

       -- For sneeruga fix for bug#4238074- check_function returns 'E'
       colon := instr(p_user_name, 'PER:');

       -- check for call compatibility.
       if TRUNC(l_api_version) <> TRUNC(p_api_version) THEN
               fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
               fnd_message.set_token('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
               fnd_message.set_token('REASON',
                    'Unsupported version '|| to_char(p_api_version)||
                    ' passed to API; expecting version '||
                    to_char(l_api_version));
               if (fnd_log.LEVEL_EXCEPTION >=
                   fnd_log.g_current_runtime_level) then
                 fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.end_bad_api_ver',
                     FALSE);
               end if;
               x_return_status := 'U'; /* Unexpected Error */
               return;
       END IF;

       /* default the username if necessary. */
       if (p_user_name is NULL) then
          l_user_name := SYS_CONTEXT('FND','USER_NAME');
          if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               c_log_head || l_api_name || '.null_username',
               'l_user_name= '||l_user_name);
          end if;
       else
          if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               c_log_head || l_api_name || '.passed_uname',
               'l_user_name= '||l_user_name);
          end if;

          if (    (fnd_data_security.DISALLOW_DEPRECATED = 'Y')
               and (substr(p_user_name, 1, LENGTH('GET_MNUIDS_NBVCXDS')) <>
                 'GET_MNUIDS_NBVCXDS')
               and (   (p_user_name <> SYS_CONTEXT('FND','USER_NAME'))
                    or (     (p_user_name is not null)
                         and (SYS_CONTEXT('FND','USER_NAME') is null)))) then
              /* In R12 we do not allow passing values other than */
              /* the current user name (which is the default), */
              /* so we raise a runtime exception if that deprecated */
              /* kind of call is made to this routine. */
              fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
              fnd_message.set_token('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
              fnd_message.set_token('REASON',
                    'Invalid API call.  Parameter p_user_name: '||p_user_name||
                    ' was passed to API '||c_pkg_name || '.'|| l_api_name ||
                    '.  p_object_name: '||p_object_name||'.  '||
                    ' In Release 12 and beyond the p_user_name parameter '||
                    'is unsupported, and any product team that passes it '||
                    'must correct their code because it does not work '||
                    'correctly.  Please see the deprecated API document at '||
                    'http://files.oraclecorp.com/content/AllPublic/'||
                    'SharedFolders/ATG%20Requirements-Public/R12/'||
                    'Requirements%20Definition%20Document/'||
                    'Application%20Object%20Library/DeprecatedApiRDD.doc '||
                    'Oracle employees who encounter this error should log '||
                    'a bug against the product that owns the call to this '||
                    'routine, which is likely the owner of the object that '||
                    'was passed to this routine: '||
                    p_object_name);
              if (fnd_log.LEVEL_EXCEPTION >=
                      fnd_log.g_current_runtime_level) then
                fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.end_depr_param',
                     FALSE);
              end if;
              fnd_message.raise_error;
          end if;
          l_user_name := p_user_name;
       end if;


       if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
         fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                   c_log_head || l_api_name || '.b4cachechk',
                  ' g_gsp_function: '|| g_gsp_function ||
                  ' p_function: '|| p_function ||
                  ' g_gsp_object_name: '|| g_gsp_object_name ||
                  ' p_object_name: '|| p_object_name ||
                  ' g_gsp_grant_instance_type: '|| p_grant_instance_type  ||
                  ' p_grant_instance_type: '||  p_grant_instance_type ||
                  ' g_gsp_user_name: '|| g_gsp_user_name ||
                  ' l_user_name: '|| l_user_name ||
                  ' g_gsp_statement_type: '|| g_gsp_statement_type  ||
                  ' p_statement_type: '|| p_statement_type  ||
                  ' g_gsp_table_alias: '|| g_gsp_table_alias ||
                  ' p_table_alias: '|| p_table_alias ||
                  ' g_gsp_grant_instance_type: '||g_gsp_grant_instance_type||
                  ' p_grant_instance_type: '|| p_grant_instance_type  ||
                  ' g_gsp_with_binds: '|| g_gsp_with_binds  ||
                  ' p_with_binds: '||  p_with_binds ||
                  ' g_gsp_context_user_id: '||g_gsp_context_user_id  ||
                  ' SYS_CONTEXT(''FND'',''USER_ID''): '||
                    SYS_CONTEXT('FND','USER_ID') ||
                  ' g_gsp_context_resp_id: '||g_gsp_context_resp_id  ||
                  ' SYS_CONTEXT(''FND'',''RESP_ID''): '||
                    SYS_CONTEXT('FND','RESP_ID') ||
                  ' g_gsp_context_secgrpid: '|| g_gsp_context_secgrpid ||
                  ' SYS_CONTEXT(''FND'',''SECURITY_GROUP_ID''): '||
                    SYS_CONTEXT('FND','SECURITY_GROUP_ID')  ||
                  ' g_gsp_context_resp_appl_id: '||
                    g_gsp_context_resp_appl_id ||
                  ' SYS_CONTEXT(''FND'',''RESP_APPL_ID''): '||
                    SYS_CONTEXT('FND','RESP_APPL_ID') ||
                  ' g_gsp_context_org_id: '||g_gsp_context_org_id||
                  ' SYS_CONTEXT(''FND'', ''ORG_ID''): '||
                    SYS_CONTEXT('FND', 'ORG_ID')
                  );
        end if;


       /* Check one level cache to see if we have this value cached already*/
       if (   (g_gsp_function = p_function
               or (g_gsp_function is NULL and  p_function is NULL))
           AND (g_gsp_object_name = p_object_name
                or (g_gsp_object_name is NULL and p_object_name is NULL))
           AND (g_gsp_grant_instance_type = p_grant_instance_type)
           AND (g_gsp_user_name = l_user_name
                or (g_gsp_user_name is NULL and l_user_name is NULL))
           AND (g_gsp_statement_type = p_statement_type)
           AND (    g_gsp_table_alias = p_table_alias
                or (g_gsp_table_alias is NULL and p_table_alias is NULL))
           AND (g_gsp_with_binds = p_with_binds)
           AND (g_gsp_context_user_id = SYS_CONTEXT('FND','USER_ID'))
           AND (g_gsp_context_resp_id = SYS_CONTEXT('FND','RESP_ID'))
           AND (g_gsp_context_secgrpid =
                            SYS_CONTEXT('FND','SECURITY_GROUP_ID'))
           AND (g_gsp_context_resp_appl_id =
                            SYS_CONTEXT('FND','RESP_APPL_ID'))
           AND (   (g_gsp_context_org_id = SYS_CONTEXT('FND', 'ORG_ID'))
                or (    g_gsp_context_org_id is NULL
                    and SYS_CONTEXT('FND', 'ORG_ID') is NULL))) then
        x_predicate := g_gsp_predicate;
        x_return_status := g_gsp_return_status;
        x_object_id := g_gsp_object_id;
        x_function_id := g_gsp_function_id;
        x_bind_order := g_gsp_bind_order;
        if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                   c_log_head || l_api_name || '.end_cachehit',
                  'x_predicate: '|| x_predicate ||
                  ', x_return_status:'||x_return_status||
                  ', x_object_id:'||x_object_id||
                  ', x_function_id:'||x_function_id||
                  ', x_bind_order:'||x_bind_order
                  );
        end if;
        return;
       end if;

       -- Check to make sure we're not using unsupported statement_type
       if (     (p_statement_type <> 'VPD')
            AND (p_statement_type <> 'BASE' /* Deprecated, same as VPD */)
            AND (p_statement_type <> 'OTHER')
            AND (p_statement_type <> 'EXISTS')) then
               fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
               fnd_message.set_token('ROUTINE',
                                        c_pkg_name || '.'|| l_api_name);
               fnd_message.set_token('REASON',
                    'Unsupported p_statement_type: '|| p_statement_type);
               if (fnd_log.LEVEL_EXCEPTION >=
                   fnd_log.g_current_runtime_level) then
                 fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.end_bad_stm_typ',
                     FALSE);
               end if;
               x_return_status := 'U'; /* Unexpected Error */
               return;
       end if;


       /* Make sure that the FND_COMPILED_MENU_FUNCTIONS table is compiled */
       if (FND_FUNCTION.G_ALREADY_FAST_COMPILED <> 'T') then
         FND_FUNCTION.FAST_COMPILE;
       end if;

       if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
         fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               c_log_head || l_api_name || '.step1start',
               'p_grant_instance_type:'||p_grant_instance_type);
       end if;

       /* check if we need to call through to old routine */
       IF (   (p_grant_instance_type = 'FUNCLIST')
            OR (p_grant_instance_type = 'FUNCLIST_NOINST')
            OR (p_grant_instance_type = 'GRANTS_ONLY'))THEN
           /* If this is one of the modes that require the old-style */
           /* statement, just call the old code for that.  */
           get_security_predicate_helper(
            p_function,
            p_object_name,
            p_grant_instance_type,
            p_user_name,
            p_statement_type,
            x_predicate,
            x_return_status,
            p_table_alias);
           return;
       end if;

       -- Check to make sure a valid role is passed or defaulted for user_name
       if (check_user_role (l_user_name) = 'F') then

         -- If we got here then the grantee will never be found because
         -- it isn't even a role, so we know there won't be a matching grant.
         fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
         fnd_message.set_token('ROUTINE',
                                   c_pkg_name || '.'|| l_api_name);
         fnd_message.set_token('REASON',
               'The user_name passed or defaulted is not a valid user_name '||
               'in wf_user_roles. '||
               'Invalid user_name: '||l_user_name ||
               ' Passed p_user_name: '||p_user_name);
         if (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
           fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                c_log_head || l_api_name || '.end_no_wf_user_role',
                FALSE);
         end if;

         l_aggregate_predicate := '1=2';
         x_return_status := 'E'; /* Error condition */
         goto return_and_cache;
       end if;

       /* Set up flags depending on which mode we are running in. */
       IF (p_grant_instance_type = C_TYPE_INSTANCE) THEN
            if (fnd_log.LEVEL_STATEMENT >=
                fnd_log.g_current_runtime_level) then
              fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               c_log_head || l_api_name || '.chk_instance',
               ' l_instance_set_flag := FALSE ');
            end if;
            l_instance_set_flag:= FALSE;
       ELSIF (p_grant_instance_type = C_TYPE_SET) THEN
            if (fnd_log.LEVEL_STATEMENT >=
                fnd_log.g_current_runtime_level) then
              fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               c_log_head || l_api_name || '.chk_set',
               ' l_instance_flag := FALSE ');
            end if;
            l_instance_flag:= FALSE;
       ELSIF (p_grant_instance_type = 'UNIVERSAL') THEN
            if (fnd_log.LEVEL_STATEMENT >=
                fnd_log.g_current_runtime_level) then
              fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               c_log_head || l_api_name || '.chk_universal',
               '  ');
            end if;
       END IF;


       -- Get the key columns from the user name
       -- We are not checking for NULL returns (meaning user not in wf_roles)
       -- because right now we allow checking of grants to users not in
       -- wf_roles.
       get_name_bind(l_user_name,
                          l_user_name_bind);


        if (p_object_name is NULL) THEN
            fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
            fnd_message.set_token('ROUTINE',
                                     c_pkg_name || '.'|| l_api_name);
            fnd_message.set_token('REASON',
                 'The parameter p_object_name can not be NULL.');
            if (fnd_log.LEVEL_EXCEPTION >=
                fnd_log.g_current_runtime_level) then
              fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                  c_log_head || l_api_name || '.end_null_obj',
                  FALSE);
            end if;
            x_return_status := 'U';
            return;
        END IF;

        if(p_object_name = 'GLOBAL') then
          fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
          fnd_message.set_token('ROUTINE',
                                     c_pkg_name || '.'|| l_api_name);
          fnd_message.set_token('REASON',
                 'The parameter p_object_name can not be ''GLOBAL''. ');
          if (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
            fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                  c_log_head || l_api_name || '.end_glob_obj',
                  FALSE);
          end if;
          x_return_status := 'U';
          return;
        else /* Normal case */
          /* Get the primary key lists and info for this object */
          x_return_status := get_pk_information(p_object_name,
                             l_db_pk1_column  ,
                             l_db_pk2_column  ,
                             l_db_pk3_column  ,
                             l_db_pk4_column  ,
                             l_db_pk5_column  ,
                             l_pk_column_names  ,
                             l_ik_clause,
                             l_exact_clause,
                             l_pk_orig_column_names,
                             l_db_object_name,
                             p_table_alias,
                             'GNT');
          if (x_return_status <> 'T') then
              if (fnd_log.LEVEL_PROCEDURE >=
                  fnd_log.g_current_runtime_level) then
                fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                 c_log_head || l_api_name || '.end_pk_info_err',
                 'returning status: '|| x_return_status);
              end if;
              /* There will be a message on the msg dict stack. */
              return;  /* We will return the x_return_status as out param */
          end if;

          if (p_table_alias is not NULL) then
             l_table_alias := p_table_alias || '.';
             l_pk_orig_column_names := l_table_alias ||
                               replace (l_pk_orig_column_names, ', ',
                                        ', '||l_table_alias);
          else
             l_table_alias := NULL;
          end if;

          l_object_id :=get_object_id(p_object_name );
          if (l_object_id is NULL) THEN
            fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
            fnd_message.set_token('ROUTINE',
                                     c_pkg_name || '.'|| l_api_name);
            fnd_message.set_token('REASON',
                 'The parameter value p_object_name is not a valid object.'||
                 ' p_object_name:'||p_object_name);
            if (fnd_log.LEVEL_EXCEPTION >=
                fnd_log.g_current_runtime_level) then
              fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                  c_log_head || l_api_name || '.end_bad_obj',
                  FALSE);
            end if;
            x_return_status := 'U';
            return;
          END IF;
        end if;

        if(p_function is NULL) then
          l_function_id := -1;
        else
          l_function_id := get_function_id(p_function);
          if (l_function_id is NULL) THEN
              fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
              fnd_message.set_token('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
              fnd_message.set_token('REASON',
               'The parameter value p_function is not a valid function name.'||
                   ' p_function:'||p_function);
              if (fnd_log.LEVEL_EXCEPTION >=
                  fnd_log.g_current_runtime_level) then
                fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                    c_log_head || l_api_name || '.end_bad_func',
                    FALSE);
              end if;
              x_return_status := 'U';
              return;
          END IF;
        end if;

        -- Performance note: we are doing up to six SQL statements in order
        -- to determine whether there exists all the possible combinations
        -- of grantee_type either GROUP (including USER) or GLOBAL
        -- and instance_type GLOBAL, INSTANCE, or SET.
        -- We had originally tried to check all these possibilities with
        -- a single statement, but it didn't perform adequately due to
        -- the ORs and sorting necessary, so this is the best solution.
        -- Perhaps if we get the WF folks to put GLOBAL (all) users into the
        -- a group in WF_USER_ROLES then we could go down to only 3 SQL
        -- or even one.

        --
        -- Do not check for GLOBAL grants when the user is GUEST
        --
        if (l_user_name <> 'GUEST') then
        --
        -- check for 'GLOBAL' instance type
        --
        /* See if there are any grants with */
        /* grantee_type='GLOBAL' and instance_type = 'GLOBAL' that apply*/
         l_dummy := -1;
         open grant_types_global_c (l_user_name,
                                          l_function_id,
                                          l_object_id,
                                          'GLOBAL');
         fetch grant_types_global_c into l_dummy;
         IF(grant_types_global_c%NOTFOUND) THEN
            NULL;
         else
           if(l_dummy = 1) then
              l_global_instance_type := TRUE;
              close grant_types_global_c;
              goto global_inst_type;
           end if;
         end if;
         close grant_types_global_c;
        end if;

        /* See if there are any grants with */
        /* grantee_type='GROUP' and instance_type = 'GLOBAL' that apply*/
         l_dummy := -1;

         --Changes for Bug#3867925
         -- Fix Non Backward change made for universal person support
         /*open grant_types_group_c (l_user_name,
                                          l_function_id,
                                          l_object_id,
                                          'GLOBAL');
         fetch grant_types_group_c into l_dummy;
         IF(grant_types_group_c%NOTFOUND) THEN
           NULL;
         else
           if(l_dummy = 1) then
              l_global_instance_type := TRUE;
              close grant_types_group_c;
              goto global_inst_type;
           end if;
         end if;
         close grant_types_group_c;*/

         if (colon <> 0) then
            open grant_types_group_bkwd_c (l_user_name,
                                          l_function_id,
                                          l_object_id,
                                          'GLOBAL');
           fetch grant_types_group_bkwd_c into l_dummy;
             IF(grant_types_group_bkwd_c%NOTFOUND) THEN
               NULL;
             else
               if(l_dummy = 1) then
                  l_global_instance_type := TRUE;
                  close grant_types_group_bkwd_c;
                  goto global_inst_type;
               end if;
             end if;
             close grant_types_group_bkwd_c;
         else
            open grant_types_group_c (l_user_name,
                                          l_function_id,
                                          l_object_id,
                                          'GLOBAL');
           fetch grant_types_group_c into l_dummy;
             IF(grant_types_group_c%NOTFOUND) THEN
               NULL;
             else
               if(l_dummy = 1) then
                  l_global_instance_type := TRUE;
                  close grant_types_group_c;
                  goto global_inst_type;
               end if;
             end if;
             close grant_types_group_c;
        end if;

        --
        -- check for 'SET' instance type
        --
        if l_instance_set_flag then
          /* See if there are any grants with */
        --
        -- Do not check for GLOBAL grants when the user is GUEST
        --
        if (l_user_name <> 'GUEST') then
          /* grantee_type='GLOBAL' and instance_type = 'SET' that apply*/
          l_dummy := -1;
          open grant_types_global_c (l_user_name,
                                            l_function_id,
                                            l_object_id,
                                            'SET');
          fetch grant_types_global_c into l_dummy;
          IF(grant_types_global_c%NOTFOUND) THEN
             NULL;
          else
             if(l_dummy = 1) then
                l_set_instance_type := TRUE;
                l_set_global_grantee_type := TRUE;
             end if;
          end if;
          close grant_types_global_c;
        end if;


          /* See if there are any grants with */
          /* grantee_type='GROUP' and instance_type = 'SET' that apply*/

          l_dummy := -1;

           --Changes for Bug#3867925
           -- Fix Non Backward change made for universal person support
          /*open grant_types_group_c (l_user_name,
                                            l_function_id,
                                            l_object_id,
                                            'SET');
          fetch grant_types_group_c into l_dummy;
          IF(grant_types_group_c%NOTFOUND) THEN
             NULL;
          else
             if(l_dummy = 1) then
                l_set_instance_type := TRUE;
                l_set_group_grantee_type := TRUE;
             end if;
          end if;
          close grant_types_group_c;*/

          if (colon <> 0) then
                 open grant_types_group_bkwd_c (l_user_name,
                                                l_function_id,
                                                l_object_id,
                                                'SET');
                fetch grant_types_group_bkwd_c into l_dummy;
                IF(grant_types_group_bkwd_c%NOTFOUND) THEN
                    NULL;
                else
                   if(l_dummy = 1) then
                      l_set_instance_type := TRUE;
                      l_set_group_grantee_type := TRUE;
                end if;
              end if;
              close grant_types_group_bkwd_c;
           else
               open grant_types_group_c (l_user_name,
                                                l_function_id,
                                                l_object_id,
                                                'SET');
                fetch grant_types_group_c into l_dummy;
                IF(grant_types_group_c%NOTFOUND) THEN
                    NULL;
                else
                   if(l_dummy = 1) then
                      l_set_instance_type := TRUE;
                      l_set_group_grantee_type := TRUE;
                end if;
              end if;
              close grant_types_group_c;
           end if;

        end if; /* l_instance_set_flag */

        --
        -- check for 'INSTANCE' instance type
        --
        if l_instance_flag then
          /* See if there are any grants with */
        --
        -- Do not check for GLOBAL grants when the user is GUEST
        --
        if (l_user_name <> 'GUEST') then

          /* grantee_type='GLOBAL' and instance_type = 'INSTANCE' that apply*/
          l_dummy := -1;
          open grant_types_global_c (l_user_name,
                                          l_function_id,
                                          l_object_id,
                                          'INSTANCE');
          fetch grant_types_global_c into l_dummy;
          IF(grant_types_global_c%NOTFOUND) THEN
             NULL;
          else
             if(l_dummy = 1) then
                l_inst_instance_type := TRUE;
                l_inst_global_grantee_type := TRUE;
             end if;
          end if;
          close grant_types_global_c;
         end if;

          /* See if there are any grants with */
          /* grantee_type='GROUP' and instance_type = 'INSTANCE' that apply*/
          l_dummy := -1;

          --Changes for Bug#3867925
          -- Fix Non Backward change made for universal person support
          /*open grant_types_group_c (l_user_name,
                                    l_function_id,
                                    l_object_id,
                                    'INSTANCE');
          fetch grant_types_group_c into l_dummy;
          IF(grant_types_group_c%NOTFOUND) THEN
             NULL;
          else
             if(l_dummy = 1) then
                l_inst_instance_type := TRUE;
                l_inst_group_grantee_type := TRUE;
             end if;
          end if;
          close grant_types_group_c;*/

          if (colon <> 0) then
              open grant_types_group_bkwd_c (l_user_name,
                                    l_function_id,
                                    l_object_id,
                                    'INSTANCE');
             fetch grant_types_group_bkwd_c into l_dummy;
            IF(grant_types_group_bkwd_c%NOTFOUND) THEN
               NULL;
            else
             if(l_dummy = 1) then
                l_inst_instance_type := TRUE;
                l_inst_group_grantee_type := TRUE;
             end if;
           end if;
             close grant_types_group_bkwd_c;
          else
             open grant_types_group_c (l_user_name,
                                    l_function_id,
                                    l_object_id,
                                    'INSTANCE');
             fetch grant_types_group_c into l_dummy;
              IF(grant_types_group_c%NOTFOUND) THEN
                 NULL;
              else
               if(l_dummy = 1) then
                  l_inst_instance_type := TRUE;
                  l_inst_group_grantee_type := TRUE;
               end if;
             end if;
             close grant_types_group_c;
          end if;

        end if; /* l_instance_flag */

<<global_inst_type>>

        /* If we have a global instance type grant, then all rows are */
        /* in scope, so just return 1=1 */
        if(l_global_instance_type = TRUE) then
           l_aggregate_predicate := '1=1';
           x_return_status := 'T';
           if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
             fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                      c_log_head || l_api_name || '.11global_inst',
                      'l_aggregate_predicate: '|| l_aggregate_predicate ||
                      ', x_return_status:'||x_return_status);
           end if;
           goto return_and_cache;
        end if;

        /* If there are no instance sets and we aren't looking for */
        /* instances, then there won't be any rows returned by the */
        /* predicate so return (1=2) */
        if(l_global_instance_type = FALSE and
           l_inst_instance_type = FALSE and
           l_set_instance_type = FALSE) then
           l_aggregate_predicate := '1=2';
           x_return_status := 'T';
           if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
             fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                      c_log_head || l_api_name || '.12no_inst',
                      'l_aggregate_predicate: '|| l_aggregate_predicate ||
                      ', x_return_status:'||x_return_status);
           end if;
           goto return_and_cache;
        end if;

        /* If we have an instance type grant, but no recognized grantee, */
        /* that is a data error, so signal that error */
        if(l_inst_instance_type = TRUE and
           l_inst_group_grantee_type = FALSE and
           l_inst_global_grantee_type = FALSE) then
           l_set_instance_type := TRUE;
           if (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
             fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                      c_log_head || l_api_name || '.err_inst_no_gnt_typ',
                      'x_predicate: '|| x_predicate);
           end if;
        end if;

        /* Build up the instance set part of the predicate */
        l_last_pred := '*NO_PRED*';
        if(l_set_instance_type = TRUE) then
           if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
             fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     c_log_head || l_api_name || '.in_set_instyp',
                     '.');
           end if;

           l_last_instance_set_id := -11162202;
           l_need_to_close_pred := FALSE;
           l_refers_to_grants := FALSE;

           l_grp_glob_fn    := FALSE;
           l_grp_glob_nofn  := FALSE;
           l_grp_fn         := FALSE;
           l_grp_nofn       := FALSE;
           l_glob_fn        := FALSE;
           l_glob_nofn      := FALSE;

           /* Open one of six different cursors  */
           if (    l_set_group_grantee_type
               AND l_set_global_grantee_type
               AND l_function_id <> -1) then
              OPEN isg_grp_glob_fn_c (    l_user_name,
                                          l_function_id,
                                          l_object_id);
              l_grp_glob_fn := TRUE;
              if (fnd_log.LEVEL_STATEMENT >=
                  fnd_log.g_current_runtime_level) then
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  c_log_head || l_api_name || '.open_grp_glob_fn_cursor',
                  ' open');
              end if;
           elsif(  l_set_group_grantee_type
               AND l_set_global_grantee_type
               AND l_function_id = -1) then
              --Changes for Bug#3867925
              --- Fix Non Backward change made for universal person support
              /*OPEN isg_grp_glob_nofn_c (  l_user_name,
                                          l_object_id);
              l_grp_glob_nofn := TRUE;
              if (fnd_log.LEVEL_STATEMENT >=
                  fnd_log.g_current_runtime_level) then
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  c_log_head || l_api_name || '.open_grp_glob_nofn_cursor',
                  ' open');
              end if;*/
              if (colon <> 0) then
                  OPEN isg_grp_glob_nofn_bkwd_c (  l_user_name,
                                          l_object_id);
                  l_grp_glob_nofn := TRUE;
                  if (fnd_log.LEVEL_STATEMENT >=
                      fnd_log.g_current_runtime_level) then
                    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                      c_log_head || l_api_name ||
                           '.open_grp_glob_nofn_bkwd_cursor',
                      ' open');
                  end if;
              else
                  OPEN isg_grp_glob_nofn_c (  l_user_name,
                                          l_object_id);
                  l_grp_glob_nofn := TRUE;
                  if (fnd_log.LEVEL_STATEMENT >=
                      fnd_log.g_current_runtime_level) then
                    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                      c_log_head || l_api_name || '.open_grp_glob_nofn_cursor',
                      ' open');
                  end if;
              end if;
           elsif(  l_set_group_grantee_type
               AND (NOT l_set_global_grantee_type)
               AND l_function_id <> -1) then
              /*OPEN isg_grp_fn_c (         l_user_name,
                                          l_function_id,
                                          l_object_id);
              l_grp_fn := TRUE;
              if (fnd_log.LEVEL_STATEMENT >=
                  fnd_log.g_current_runtime_level) then
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  c_log_head || l_api_name || '.open_grp_fn_cursor',
                  ' open');
              end if;*/

              if (colon <> 0 ) then
                 OPEN isg_grp_fn_bkwd_c (l_user_name,
                                    l_function_id,
                                    l_object_id);
                 l_grp_fn := TRUE;
                  if (fnd_log.LEVEL_STATEMENT >=
                      fnd_log.g_current_runtime_level) then
                    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                      c_log_head || l_api_name || '.open_grp_fn_bkwd_cursor',
                      ' open');
                  end if;
              else
                   OPEN isg_grp_fn_c (l_user_name,
                                      l_function_id,
                                      l_object_id);
                   l_grp_fn := TRUE;
                   if (fnd_log.LEVEL_STATEMENT >=
                      fnd_log.g_current_runtime_level) then
                      fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                      c_log_head || l_api_name || '.open_grp_fn_cursor',
                      ' open');
                   end if;
              end if;
           elsif(  l_set_group_grantee_type
               AND NOT l_set_global_grantee_type
               AND l_function_id = -1) then
              --Changes for Bug#3867925
              -- Fix Non Backward change made for universal person support
              /*OPEN isg_grp_nofn_c (       l_user_name,
                                          l_object_id);
              l_grp_nofn := TRUE;
              if (fnd_log.LEVEL_STATEMENT >=
                  fnd_log.g_current_runtime_level) then
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  c_log_head || l_api_name || '.open_grp_nofn_cursor',
                  ' open');
              end if;*/
              if (colon <> 0) then
                 OPEN isg_grp_nofn_bkwd_c (l_user_name,
                                      l_object_id);
                l_grp_nofn := TRUE;
                  if (fnd_log.LEVEL_STATEMENT >=
                      fnd_log.g_current_runtime_level) then
                    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                      c_log_head || l_api_name || '.open_grp_nofn_bkwd_cursor',
                      ' open');
                  end if;
              else
                  OPEN isg_grp_nofn_c (l_user_name,
                                      l_object_id);
                  l_grp_nofn := TRUE;
                  if (fnd_log.LEVEL_STATEMENT >=
                      fnd_log.g_current_runtime_level) then
                    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                      c_log_head || l_api_name || '.open_grp_nofn_cursor',
                      ' open');
                  end if;
              end if;
           elsif(NOT l_set_group_grantee_type
               AND l_set_global_grantee_type
               AND l_function_id <> -1) then
              OPEN isg_glob_fn_c (l_user_name,
                                          l_function_id,
                                          l_object_id);
              l_glob_fn := TRUE;
              if (fnd_log.LEVEL_STATEMENT >=
                  fnd_log.g_current_runtime_level) then
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  c_log_head || l_api_name || '.open_glob_fn_cursor',
                  ' open');
              end if;
           elsif(NOT l_set_group_grantee_type
               AND l_set_global_grantee_type
               AND l_function_id = -1) then
              OPEN isg_glob_nofn_c (l_user_name,
                                          l_object_id);
              l_glob_nofn := TRUE;
              if (fnd_log.LEVEL_STATEMENT >=
                  fnd_log.g_current_runtime_level) then
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  c_log_head || l_api_name || '.open_glob_nofn_cursor',
                  ' open');
              end if;
           else
              fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
              fnd_message.set_token('ROUTINE',
                                     c_pkg_name || '.'|| l_api_name);
              fnd_message.set_token('REASON',
                    ' Fell through where we shouldnt have (1)');
              if (fnd_log.LEVEL_EXCEPTION >=
                  fnd_log.g_current_runtime_level) then
                fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                    c_log_head || l_api_name || '.end_fallthru1',
                    FALSE);
              end if;
              x_return_status := 'U';
              return;
           end if;

           l_cursor_is_open := TRUE;
           LOOP
              if (l_grp_glob_fn) then
                 if (fnd_log.LEVEL_STATEMENT >=
                     fnd_log.g_current_runtime_level) then
                   fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     c_log_head || l_api_name || '.fetch_grp_glob_fn_cursor',
                     ' fetch');
                 end if;
                 FETCH isg_grp_glob_fn_c INTO d_predicate, d_instance_set_id,
                                             d_grant_guid;
                 if (isg_grp_glob_fn_c%notfound) then
                    close isg_grp_glob_fn_c;
                    l_cursor_is_open := FALSE;
                    exit; -- exit loop
                 end if;
              elsif (l_grp_glob_nofn) then
                 --Changes for Bug#3867925
                 -- Fix Non Backward change made for universal person support
                 /*if (fnd_log.LEVEL_STATEMENT >=
                     fnd_log.g_current_runtime_level) then
                   fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     c_log_head || l_api_name || '.fetch_grp_glob_nofn_cursor',
                     ' fetch');
                 end if;
                 FETCH isg_grp_glob_nofn_c INTO d_predicate, d_instance_set_id,
                                             d_grant_guid;
                 if (isg_grp_glob_nofn_c%notfound) then
                    close isg_grp_glob_nofn_c;
                    l_cursor_is_open := FALSE;
                    exit; -- exit loop
                 end if;*/

                 if (colon <> 0) then
                    if (fnd_log.LEVEL_STATEMENT >=
                       fnd_log.g_current_runtime_level) then
                       fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                       c_log_head || l_api_name ||
                                    '.fetch_grp_glob_nofn_bkwd_cursor',
                       ' fetch');
                   end if;
                   FETCH isg_grp_glob_nofn_bkwd_c
                      INTO d_predicate, d_instance_set_id, d_grant_guid;
                   if (isg_grp_glob_nofn_bkwd_c%notfound) then
                      close isg_grp_glob_nofn_bkwd_c;
                      l_cursor_is_open := FALSE;
                      exit; -- exit loop
                   end if;
                 else
                   if (fnd_log.LEVEL_STATEMENT >=
                       fnd_log.g_current_runtime_level) then
                       fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                       c_log_head || l_api_name||'.fetch_grp_glob_nofn_cursor',
                       ' fetch');
                   end if;
                   FETCH isg_grp_glob_nofn_c
                                      INTO d_predicate, d_instance_set_id,
                                           d_grant_guid;
                   if (isg_grp_glob_nofn_c%notfound) then
                      close isg_grp_glob_nofn_c;
                      l_cursor_is_open := FALSE;
                      exit; -- exit loop
                   end if;
                 end if;
              elsif (l_grp_fn) then
                   --Changes for Bug#3867925
                   -- Fix Non Backward change made for universal person support
                  /*if (fnd_log.LEVEL_STATEMENT >=
                      fnd_log.g_current_runtime_level) then
                    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                      c_log_head || l_api_name || '.fetch_grp_fn_cursor',
                      ' fetch');
                  end if;
                  FETCH isg_grp_fn_c INTO d_predicate, d_instance_set_id,
                                             d_grant_guid;
                  if (isg_grp_fn_c%notfound) then
                     close isg_grp_fn_c;
                     l_cursor_is_open := FALSE;
                     exit; -- exit loop
                  end if;*/

                  if (colon <> 0) then
                      if (fnd_log.LEVEL_STATEMENT >=
                          fnd_log.g_current_runtime_level) then
                          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                          c_log_head || l_api_name||'.fetch_grp_fn_bkwd_cursor',
                          ' fetch');
                      end if;
                      FETCH isg_grp_fn_bkwd_c INTO
                                               d_predicate, d_instance_set_id,
                                               d_grant_guid;
                      if (isg_grp_fn_bkwd_c%notfound) then
                         close isg_grp_fn_bkwd_c;
                         l_cursor_is_open := FALSE;
                         exit; -- exit loop
                      end if;
                  else
                    if (fnd_log.LEVEL_STATEMENT >=
                        fnd_log.g_current_runtime_level) then
                        fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                        c_log_head || l_api_name || '.fetch_grp_fn_cursor',
                        ' fetch');
                    end if;
                    FETCH isg_grp_fn_c INTO d_predicate, d_instance_set_id,
                                               d_grant_guid;
                    if (isg_grp_fn_c%notfound) then
                       close isg_grp_fn_c;
                       l_cursor_is_open := FALSE;
                       exit; -- exit loop
                    end if;
                  end if;
              elsif (l_grp_nofn) then
                 --Changes for Bug#3867925
                 -- Fix Non Backward change made for universal person support
                 /*if (fnd_log.LEVEL_STATEMENT >=
                     fnd_log.g_current_runtime_level) then
                   fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     c_log_head || l_api_name || '.fetch_grp_nofn_cursor',
                     ' fetch');
                 end if;
                 FETCH isg_grp_nofn_c INTO d_predicate, d_instance_set_id,
                                             d_grant_guid;
                 if (isg_grp_fn_c%notfound) then
                    close isg_grp_fn_c;
                    l_cursor_is_open := FALSE;
                    exit; -- exit loop
                 end if; */

                 if (colon <> 0) then
                   if (fnd_log.LEVEL_STATEMENT >=
                       fnd_log.g_current_runtime_level) then
                       fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                       c_log_head || l_api_name ||'.fetch_grp_nofn_bkwd_cursor',
                       ' fetch');
                   end if;
                   FETCH isg_grp_nofn_bkwd_c
                    INTO d_predicate, d_instance_set_id,
                         d_grant_guid;
                   if (isg_grp_nofn_bkwd_c%notfound) then
                      close isg_grp_nofn_bkwd_c;
                      l_cursor_is_open := FALSE;
                      exit; -- exit loop
                   end if;
                 else
                   if (fnd_log.LEVEL_STATEMENT >=
                       fnd_log.g_current_runtime_level) then
                       fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                       c_log_head || l_api_name || '.fetch_grp_nofn_cursor',
                       ' fetch');
                   end if;
                   FETCH isg_grp_nofn_c INTO d_predicate, d_instance_set_id,
                                             d_grant_guid;
                   if (isg_grp_nofn_c%notfound) then
                      close isg_grp_nofn_c;
                      l_cursor_is_open := FALSE;
                      exit; -- exit loop
                   end if;
                 end if;
              elsif (l_glob_fn) then
                 if (fnd_log.LEVEL_STATEMENT >=
                     fnd_log.g_current_runtime_level) then
                   fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                   c_log_head || l_api_name || '.fetch_glob_fn_cursor',
                   ' fetch');
                 end if;
                 FETCH isg_glob_fn_c INTO d_predicate, d_instance_set_id,
                                             d_grant_guid;
                 if (isg_glob_fn_c%notfound) then
                    close isg_glob_fn_c;
                    l_cursor_is_open := FALSE;
                    exit; -- exit loop
                 end if;
              elsif (l_glob_nofn) then
                 if (fnd_log.LEVEL_STATEMENT >=
                     fnd_log.g_current_runtime_level) then
                   fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     c_log_head || l_api_name || '.fetch_glob_nofn_cursor',
                     ' fetch');
                 end if;
                 FETCH isg_glob_nofn_c INTO d_predicate, d_instance_set_id,
                                             d_grant_guid;
                 if (isg_glob_nofn_c%notfound) then
                    close isg_glob_nofn_c;
                    l_cursor_is_open := FALSE;
                    exit; -- exit loop
                 end if;
              else
                fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
                fnd_message.set_token('ROUTINE',
                                    c_pkg_name || '.'|| l_api_name);
                fnd_message.set_token('REASON',
                    ' Fell through where we shouldnt have (2)');
                if (fnd_log.LEVEL_EXCEPTION >=
                    fnd_log.g_current_runtime_level) then
                  fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                    c_log_head || l_api_name || '.end_fallthru2',
                    FALSE);
                 end if;
                 x_return_status := 'U';
                 return;
              end if;

              if (fnd_log.LEVEL_STATEMENT >=
                  fnd_log.g_current_runtime_level) then
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     c_log_head || l_api_name || '.loop_isg',
                     ' d_instance_set_id: '||
                     d_instance_set_id ||
                     ' d_predicate: '||
                     d_predicate ||
                     ' d_grant_guid: '||
                     d_grant_guid);
              end if;

              /* If we are coming upon a new instance set */
              if (d_instance_set_id <>
                  l_last_instance_set_id) then
                 if (l_need_to_close_pred) then /* Close off the last pred */
                   l_aggregate_predicate := substrb( l_aggregate_predicate ||
                        ') AND '|| l_pred ||')', 1, c_pred_buf_size);
                   l_need_to_close_pred := FALSE;
                   l_last_was_hextoraw := FALSE;
                   if (fnd_log.LEVEL_STATEMENT >=
                       fnd_log.g_current_runtime_level) then
                     fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     c_log_head || l_api_name || '.close_pred',
                     'l_pred:'||l_pred);
                   end if;
                 end if;

                 /* If we need to add an OR, do so. */
                 if (l_last_pred <> '*NO_PRED*') then
                   l_aggregate_predicate := substrb( l_aggregate_predicate ||
                        ' OR ', 1, c_pred_buf_size);
                 end if;

                 /* Upgrade and substitute predicate */
                 l_pred := upgrade_predicate(
                                 d_predicate);

                 if (fnd_log.LEVEL_STATEMENT >=
                     fnd_log.g_current_runtime_level) then
                   fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     c_log_head || l_api_name || '.upgd_pred',
                     'l_pred:'||l_pred);
                 end if;

                 /* If this is the simple form of predicate that does not */
                 /* refer to parameters in the grant table */
                 if (instr(l_pred, C_GRANT_ALIAS_TOK) <> 0) then
                    l_uses_params := TRUE;
                 else
                    l_uses_params := FALSE;
                 end if;

                 l_pred := substitute_predicate(
                                 l_pred,
                                 p_table_alias);

                 if (fnd_log.LEVEL_STATEMENT >=
                     fnd_log.g_current_runtime_level) then
                   fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     c_log_head || l_api_name || '.subbed_pred',
                     'l_pred:'||l_pred);
                 end if;

                 /* If this is the simple form of predicate that does not */
                 /* refer to parameters in the grant table */
                 if ( NOT l_uses_params) then
                    l_aggregate_predicate  :=
                              substrb( l_aggregate_predicate ||
                                 '('|| l_pred ||')', 1, c_pred_buf_size);
                    l_need_to_close_pred := FALSE;
                    l_refers_to_grants := FALSE;
                    if (fnd_log.LEVEL_STATEMENT >=
                        fnd_log.g_current_runtime_level) then
                      fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                         c_log_head || l_api_name || '.simple_pred',
                         'l_pred:'||l_pred);
                    end if;
                 else /* Has references to grant table so we subselect */
                      /* against the grants table */
                    l_aggregate_predicate  :=
                         substrb( l_aggregate_predicate ||
                         ' exists (select null'||
                                      ' from fnd_grants gnt'||
                                     ' where gnt.grant_guid in (',
                                                    1, c_pred_buf_size);
                    l_need_to_close_pred := TRUE;
                    l_refers_to_grants := TRUE;
                    if (fnd_log.LEVEL_STATEMENT >=
                         fnd_log.g_current_runtime_level) then
                      fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                        c_log_head || l_api_name || '.compl_pred',
                        'l_pred:'||l_pred);
                    end if;
                 end if;
              end if;

              l_last_instance_set_id := d_instance_set_id;
              l_last_pred := d_predicate;

              /* Add this grant_guid to the predicate */
              if (l_refers_to_grants) then
                 if (l_last_was_hextoraw) then /* Add a comma if necessary */
                    l_aggregate_predicate  :=
                       substrb(l_aggregate_predicate ||
                         ', ', 1, c_pred_buf_size);
                 end if;
                 l_aggregate_predicate  :=
                       substrb( l_aggregate_predicate ||
                         'hextoraw('''|| d_grant_guid
                         ||''')', 1, c_pred_buf_size);
                 l_last_was_hextoraw := TRUE;
              else
                 l_last_was_hextoraw := FALSE;
              end if;
              if (fnd_log.LEVEL_STATEMENT >=
                  fnd_log.g_current_runtime_level) then
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     c_log_head || l_api_name || '.instsetloop',
                     ' l_aggregate_predicate: ' || l_aggregate_predicate);
              end if;
           END LOOP;

           /* Close the cursor */
           if (l_cursor_is_open) then
             if (l_grp_glob_fn) then
                close isg_grp_glob_fn_c;
             elsif (l_grp_glob_nofn) then
                close isg_grp_glob_nofn_c;
                close isg_grp_glob_nofn_bkwd_c;
             elsif (l_grp_fn) then
                close isg_grp_fn_c;
             elsif (l_grp_nofn) then
                close isg_grp_nofn_c;
                close isg_grp_nofn_bkwd_c;
             elsif (l_glob_fn) then
                close isg_glob_fn_c;
             elsif (l_glob_nofn) then
                close isg_glob_nofn_c;
             else
                fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
                fnd_message.set_token('ROUTINE',
                                     c_pkg_name || '.'|| l_api_name);
                    fnd_message.set_token('REASON',
                   ' Fell through where we shouldnt have (3)');
                if (fnd_log.LEVEL_EXCEPTION >=
                    fnd_log.g_current_runtime_level) then
                  fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                   c_log_head || l_api_name || '.end_fallthru3',
                   FALSE);
                end if;
                x_return_status := 'U';
                return;
             end if;
           end if;

           if (l_need_to_close_pred) then /* Close off the last pred */
              l_aggregate_predicate := substrb( l_aggregate_predicate ||
                   ') AND '|| l_pred ||')', 1, c_pred_buf_size);
              l_need_to_close_pred := FALSE;
              l_last_was_hextoraw := FALSE;
           end if;

        end if;

        /* If there were no predicates found */
        if (l_last_pred = '*NO_PRED*') then
          l_set_instance_type := FALSE;
        end if;

        if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     c_log_head || l_api_name || '.afterinstset',
                     ' l_aggregate_predicate: ' || l_aggregate_predicate);
        end if;

        /* ---------- Instance part */
        if (l_inst_instance_type) then
          l_instance_predicate :=
            l_instance_predicate ||
           ' exists (select null'||
                     ' from fnd_grants gnt';
          if (p_with_binds = 'Y') then
            l_instance_predicate :=
              l_instance_predicate ||
                      ' where (GNT.object_id = :OBJECT_ID_BIND'||
                        ' AND (';
            x_object_id := l_object_id;
            if(x_bind_order is not NULL) then
               x_bind_order := x_bind_order || 'O';
            else
               x_bind_order := 'O';
            end if;
          else
            l_instance_predicate :=
              l_instance_predicate ||
                      ' where (GNT.object_id = ' || l_object_id ||
                        ' AND (';
          end if;

          if (l_inst_group_grantee_type) then

              --Changes for Bug#3867925
              -- Fix Non Backward change made for universal person support

                  if (colon <> 0) then

                    l_instance_predicate := l_instance_predicate ||
        ' (   (    GNT.grantee_type = ''USER'' '||
             ' AND GNT.grantee_key = '|| l_user_name_bind||') '||
        '  OR (    GNT.grantee_type = ''GROUP'' '||
             ' AND GNT.grantee_key in ' ||
                 ' (select role_name '||
                 ' from wf_user_roles wur '||
                 ' where wur.user_name in '||
                  ' ( (select '||l_user_name_bind ||' from dual) '||
                         ' union all '||
                   ' (select incrns.name from wf_local_roles incrns, '||
                                             ' fnd_user f '||
                     ' where ''HZ_PARTY''       = incrns.orig_system '||
                       ' and f.user_name           = '||l_user_name_bind ||
                       ' and f.person_party_id  = incrns.orig_system_id)))))';

                    if (l_inst_global_grantee_type) then
                      l_instance_predicate := l_instance_predicate ||
                       ' OR' ||
                       ' (GNT.grantee_type = ''GLOBAL'')';
                    end if;

                  else /* colon <> 0 */

                    l_instance_predicate := l_instance_predicate ||
               ' (GNT.grantee_key in '||
                 ' (select role_name '||
                 ' from wf_user_roles wur, '||
                  ' ( select '||l_user_name_bind ||' name from dual '||
                       ' union all '||
                   ' (select incrns.name from wf_local_roles incrns, '||
                                             ' fnd_user f '||
                     ' where ''HZ_PARTY''       = incrns.orig_system '||
                       ' and f.user_name           = '||l_user_name_bind ||
                       ' and f.person_party_id  = incrns.orig_system_id '||
                       ' and incrns.partition_id  = 9 ) '||
                   ' ) incr2 '||
                   ' where wur.user_name = incr2.name ';

                    if (l_inst_global_grantee_type) then
                         l_instance_predicate := l_instance_predicate ||
                            ' union all '||
                            ' select ''GLOBAL'' from dual ';
                    end if;

                    l_instance_predicate := l_instance_predicate ||
                         ' ) ) ';

                 end if;  /* colon <> 0 */

          else /* (l_inst_group_grantee_type) */

            if (l_inst_global_grantee_type) then
               l_instance_predicate := l_instance_predicate ||
                    ' (GNT.grantee_type = ''GLOBAL'')';
            end if;

          end if;

          /* Close off the grantee part */
          l_instance_predicate := l_instance_predicate ||
                  ' )';
          if (p_with_binds = 'Y') then /* If returning a stmnt w/ binds*/
            if (l_function_id <> -1) then
               l_instance_predicate := l_instance_predicate ||
                ' AND GNT.menu_id in'||
                  ' (select cmf.menu_id'||
                     ' from fnd_compiled_menu_functions cmf'||
                    ' where cmf.function_id = :FUNCTION_ID_BIND )';
               x_function_id := l_function_id;
               if(x_bind_order is not NULL) then
                  x_bind_order := x_bind_order || 'F';
               else
                  x_bind_order := 'F';
               end if;
            end if;
          else
            if (l_function_id <> -1) then
               l_instance_predicate := l_instance_predicate ||
               ' AND GNT.menu_id in'||
                  ' (select cmf.menu_id'||
                     ' from fnd_compiled_menu_functions cmf'||
                    ' where cmf.function_id = '||l_function_id||')';
            end if;
          end if;
          l_instance_predicate := l_instance_predicate ||
             ' AND(   GNT.ctx_secgrp_id = -1'||
                 ' OR GNT.ctx_secgrp_id  = '||
                    ' SYS_CONTEXT(''FND'',''SECURITY_GROUP_ID''))'||
             ' AND(   GNT.ctx_resp_id = -1'||
                 ' OR GNT.ctx_resp_id = '||
                    ' SYS_CONTEXT(''FND'',''RESP_ID''))'||
             ' AND(   GNT.ctx_resp_appl_id = -1'||
                 ' OR GNT.ctx_resp_appl_id ='||
                    ' SYS_CONTEXT(''FND'',''RESP_APPL_ID''))'||
             ' AND(   GNT.ctx_org_id = -1'||
                 ' OR GNT.ctx_org_id ='||
                    ' SYS_CONTEXT(''FND'', ''ORG_ID''))'||
             ' AND GNT.start_date <= sysdate ' ||
             ' AND (    GNT.end_date IS NULL ' ||
                  ' OR GNT.end_date >= sysdate ) ';

          /* Add on the clause for INSTANCE_TYPE = 'INSTANCE' */
          l_instance_predicate := l_instance_predicate ||
             ' AND'|| l_ik_clause||'))';
          if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               c_log_head || l_api_name || '.instpred','instpred');
          end if;
        end if;

        /* Add the instance predicate on to the end */
        if (l_set_instance_type and l_inst_instance_type) then
          l_aggregate_predicate :=  substrb(l_aggregate_predicate ||
            ' OR', 1, c_pred_buf_size);
        end if;
        if(l_inst_instance_type) then
          l_aggregate_predicate :=  substrb(l_aggregate_predicate ||
           l_instance_predicate, 1, c_pred_buf_size);
        end if;

        /* If we have no predicate, then return 1=2.  This is for robustness*/
        /* but probably isn't needed in practice. */
        if(   l_aggregate_predicate is NULL
           or l_aggregate_predicate = '*NO_PRED*') then
           l_aggregate_predicate := '1=2';
        end if;

<<return_and_cache>>



        /* Put parentheses around the statement in order to make it */
        /* amenable to ANDing with another statement */
        if(p_statement_type = 'EXISTS')then
          /* tmorrow- for bug 4592098 added substr to prevent buf overflows*/
          l_aggregate_predicate :=substrb(
                          'ROWNUM=1 and ('||l_aggregate_predicate||')',
                          1, c_pred_buf_size);
        else
          /* tmorrow- for bug 4592098 added substr to prevent buf overflows*/
          l_aggregate_predicate :=substrb('('||l_aggregate_predicate||')',
                          1, c_pred_buf_size);
        end if;

        if (g_vpd_buf_limit = -1) then /* If not initialized */
          g_vpd_buf_limit := self_init_pred_size(); /* init from db version */
        end if;

        if (    (lengthb(l_aggregate_predicate) > g_vpd_buf_limit)
            AND (   (p_statement_type = 'BASE') /* deprecated, same as VPD*/
                 or (p_statement_type = 'VPD')))then
           FND_MESSAGE.SET_NAME('FND', 'GENERIC-INTERNAL ERROR');
           FND_MESSAGE.SET_TOKEN('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
           FND_MESSAGE.SET_TOKEN('REASON',
            'The predicate was longer than the database VPD limit of '||
            to_char(g_vpd_buf_limit)||' bytes for the predicate.  ');

           if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
             fnd_log.message(FND_LOG.LEVEL_PROCEDURE,
                   c_log_head || l_api_name || '.end',
                  FALSE);
           end if;
           x_return_status := 'L'; /* Indicate Error */
        end if;

        x_predicate := l_aggregate_predicate;

        /* For VPD, null predicate is logically equivalent to and performs */
        /* similarly to (1=1) so return that. */
        if (    (x_predicate = '(1=1)')
            AND (   (p_statement_type = 'BASE') /* deprecated, same as VPD*/
                 or (p_statement_type = 'VPD'))) then
           x_predicate := NULL;
        end if;

        if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                   c_log_head || l_api_name || '.end',
                  'x_predicate: '|| x_predicate ||
                  ', x_return_status:'||x_return_status);
        end if;

        /* Set params and results into 1-level cache for next time */
        g_gsp_function := p_function;
        g_gsp_object_name := p_object_name;
        g_gsp_grant_instance_type := p_grant_instance_type;
        g_gsp_user_name := l_user_name;
        g_gsp_statement_type := p_statement_type;
        g_gsp_table_alias := p_table_alias;
        g_gsp_with_binds := p_with_binds;
        g_gsp_context_user_id := SYS_CONTEXT('FND','USER_ID');
        g_gsp_context_resp_id := SYS_CONTEXT('FND','RESP_ID');
        g_gsp_context_secgrpid :=  SYS_CONTEXT('FND','SECURITY_GROUP_ID');
        g_gsp_context_resp_appl_id := SYS_CONTEXT('FND','RESP_APPL_ID');
        g_gsp_context_org_id := SYS_CONTEXT('FND', 'ORG_ID');
        g_gsp_predicate := x_predicate;
        g_gsp_return_status := x_return_status;
        g_gsp_object_id := x_object_id;
        g_gsp_function_id := x_function_id;
        g_gsp_bind_order := x_bind_order;

   EXCEPTION
         /* If API called with deprecated p_user_name arg, */
         /* propagate that up so the caller gets exception */
         WHEN FND_MESSAGE_RAISED_ERR THEN
             /* Re raise the error for the caller */
             fnd_message.raise_error;

             x_return_status := 'U';  /* This line should never be executed */
             return;

        WHEN OTHERS THEN
            fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
            fnd_message.set_token('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
            fnd_message.set_token('ERRNO', SQLCODE);
            fnd_message.set_token('REASON', SQLERRM);

            if (fnd_log.LEVEL_EXCEPTION >=
                fnd_log.g_current_runtime_level) then
              fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.other_err',
                     FALSE);
            end if;
            x_return_status := 'U';
            if (fnd_log.LEVEL_PROCEDURE >=
                fnd_log.g_current_runtime_level) then
              fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                   c_log_head || l_api_name || '.end_after_other',
                  'x_predicate: '|| x_predicate ||
                  ', x_return_status:'||x_return_status);
            end if;
            return;
  END get_security_predicate_intrnl;
------------------------------------------------------------------------------------

  PROCEDURE get_security_predicate_w_binds
  (
    p_api_version      IN  NUMBER,
    p_function         IN  VARCHAR2,
    p_object_name      IN  VARCHAR2,
    p_grant_instance_type  IN  VARCHAR2,/* SET, INSTANCE*/
    p_user_name        IN  VARCHAR2,
    /* statement_type: 'OTHER', 'VPD'=VPD, 'EXISTS'= to check existence*/
    p_statement_type   IN  VARCHAR2,
    p_table_alias      IN  VARCHAR2,
    x_predicate        out NOCOPY varchar2,
    x_return_status    out NOCOPY varchar2,
    x_function_id      out NOCOPY NUMBER,
    x_object_id        out NOCOPY NUMBER,
    x_bind_order       out NOCOPY varchar2
  )
  IS
    l_api_name   CONSTANT VARCHAR2(30)  := 'GET_SECURITY_PREDICATE_W_BINDS';
    l_api_version           CONSTANT NUMBER := 1.0;
    BEGIN

      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name|| '(' ||
          'p_api_version=>'|| to_char(p_api_version) ||
          ', p_function=>'|| p_function ||
          ', p_object_name=>'|| p_object_name ||
          ', p_grant_instance_type=>'|| p_grant_instance_type ||
          ', p_user_name=>'|| p_user_name ||
          ', p_statement_type=>'|| p_statement_type ||
          ', p_table_alias=>'|| p_table_alias ||');');
       end if;


       -- check for call compatibility.
       if TRUNC(l_api_version) <> TRUNC(p_api_version) THEN
               fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
               fnd_message.set_token('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
               fnd_message.set_token('REASON',
                    'Unsupported version '|| to_char(p_api_version)||
                    ' passed to API; expecting version '||
                    to_char(l_api_version));
               if (fnd_log.LEVEL_EXCEPTION >=
                 fnd_log.g_current_runtime_level) then
                 fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.end_bad_api_ver',
                     FALSE);
               end if;
               x_return_status := 'U'; /* Unexpected Error */
               return;
       END IF;

       fnd_data_security.get_security_predicate_intrnl(
          p_api_version, p_function, p_object_name, p_grant_instance_type,
          p_user_name, p_statement_type, p_table_alias,'Y',
          x_predicate, x_return_status,
          x_function_id, x_object_id, x_bind_order);

       if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                   c_log_head || l_api_name || '.end',
                  ' x_predicate: '|| x_predicate ||
                  ' x_return_status:'||x_return_status||
                  ' x_function_id: '|| x_function_id ||
                  ' x_object_id: '|| x_object_id ||
                  ' x_bind_order:'|| x_bind_order );
       end if;
    END;


  ----- THIS IS THE RIGHT VERSION OF GET_SECURITY_PREDICATE TO USE.
  ----- Get the list of predicates Strings
  ----- Undocumented unsupported feature for internal use only:
  ----- passing 'FUNCLIST' for p_grant_instance_type will yield pred
  ----- for use in get_functions.
  --------------------------------------------
  PROCEDURE get_security_predicate(
    p_api_version      IN  NUMBER,
    p_function         IN  VARCHAR2,
    p_object_name      IN  VARCHAR2,
    p_grant_instance_type  IN  VARCHAR2,/* SET, INSTANCE*/
                           /* Undocumented value: FUNCLIST, FUNCLIST_NOINST */
                           /* Documented value: GRANTS_ONLY */
    p_user_name        IN  VARCHAR2,
    /* stmnt_type: 'OTHER', 'VPD'=VPD, 'EXISTS'= for checking existence. */
    p_statement_type   IN  VARCHAR2,
    x_predicate        out NOCOPY varchar2,
    x_return_status    out NOCOPY varchar2,
    p_table_alias      IN  VARCHAR2
  )  IS
    l_api_name   CONSTANT VARCHAR2(30)  := 'GET_SECURITY_PREDICATE';
    l_api_version           CONSTANT NUMBER := 1.0;
    x_function_id  NUMBER;
    x_object_id    NUMBER;
    x_bind_order   varchar2(256);
    BEGIN

      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name|| '(' ||
          'p_api_version=>'|| to_char(p_api_version) ||
          ', p_function=>'|| p_function ||
          ', p_object_name=>'|| p_object_name ||
          ', p_grant_instance_type=>'|| p_grant_instance_type ||
          ', p_user_name=>'|| p_user_name ||
          ', p_statement_type=>'|| p_statement_type ||
          ', p_table_alias=>'|| p_table_alias ||');');
      end if;

       -- check for call compatibility.
       if TRUNC(l_api_version) <> TRUNC(p_api_version) THEN
               fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
               fnd_message.set_token('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
               fnd_message.set_token('REASON',
                    'Unsupported version '|| to_char(p_api_version)||
                    ' passed to API; expecting version '||
                    to_char(l_api_version));
               if (fnd_log.LEVEL_EXCEPTION >=
                   fnd_log.g_current_runtime_level) then
                 fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.end_bad_api_ver',
                     FALSE);
               end if;
               x_return_status := 'U'; /* Unexpected Error */
               return;
       END IF;

       fnd_data_security.get_security_predicate_intrnl(
          p_api_version, p_function, p_object_name, p_grant_instance_type,
          p_user_name, p_statement_type, p_table_alias, 'N',
          x_predicate, x_return_status,
          x_function_id, x_object_id, x_bind_order);

       if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                   c_log_head || l_api_name || '.end',
                  ' x_predicate: '|| x_predicate ||
                  ' x_return_status:'||x_return_status||
                  ' x_function_id: '|| x_function_id ||
                  ' x_object_id: '|| x_object_id ||
                  ' x_bind_order:'|| x_bind_order);
       end if;
    END;


  -- DEPRECATED.  DO NOT CALL THIS.  USE THE OTHER OVERLOADED PROCEDURE.
  -- This version of get_security_predicate is no longer supported because
  -- the pk aliases that it takes in the params do not work in our new
  -- SQL which now puts the object name in the SQL for parameterized
  -- instance sets.  It is being left in the API simply for patching
  -- reasons but should NEVER be called from new code.  The pk aliases
  -- will be ignored.  In some upcoming release this may be dropped
  -- from the API.
  -- New code should call the overloaded get_security_predicate without
  -- the pk aliases.
  PROCEDURE get_security_predicate
  (
    p_api_version      IN  NUMBER,
    p_function         IN  VARCHAR2,
    p_object_name      IN  VARCHAR2,
    p_grant_instance_type  IN  VARCHAR2,/* SET, INSTANCE*/
    p_user_name        IN  VARCHAR2,
    /* stmnt_type: 'OTHER', 'VPD'=VPD, 'EXISTS'= for checking existence. */
    p_statement_type   IN  VARCHAR2,
    p_pk1_alias        IN  VARCHAR2,
    p_pk2_alias        IN  VARCHAR2,
    p_pk3_alias        IN  VARCHAR2,
    p_pk4_alias        IN  VARCHAR2,
    p_pk5_alias        IN  VARCHAR2,
    x_predicate        out NOCOPY varchar2,
    x_return_status    out NOCOPY varchar2
  )  IS
    l_api_name   CONSTANT VARCHAR2(30)  := 'GET_SECURITY_PREDICATE';
  begin


    -- Check to make sure we're not using unsupported modes
    if (   (   (p_statement_type = 'BASE')/* deprecated, same as VPD */
            or (p_statement_type = 'VPD')
         /* or (p_grant_instance_type = 'SET')*/
            OR(p_pk1_alias is not NULL)
            OR (p_pk2_alias is not NULL)
            OR (p_pk3_alias is not NULL)
            OR (p_pk4_alias is not NULL)
            OR (p_pk5_alias is not NULL))) then

            fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
            fnd_message.set_token('ROUTINE',
                                        c_pkg_name || '.'|| l_api_name);
            fnd_message.set_token('REASON',
                 'Unsupported mode arguments: '||
                 'p_statement_type = BASE|VPD,'||
                 ' or p_pkX_alias values passed.');
            if (fnd_log.LEVEL_EXCEPTION >=
                  fnd_log.g_current_runtime_level) then
              fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                  c_log_head || l_api_name || '.end_bad_mode',
                  FALSE);
            end if;
            x_return_status := 'U'; /* Unexpected Error */
            return;
    end if;

    if (fnd_data_security.DISALLOW_DEPRECATED = 'Y') then
              /* In R12 this routine is deprecated */
              /* So we raise a runtime exception to help people to know */
              /* they need to change their code. */
              fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
              fnd_message.set_token('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
              fnd_message.set_token('REASON',
                    'Invalid API call.  API '
                    ||c_pkg_name || '.'|| l_api_name ||
                    ' is desupported and should not be called in R12.'||
                    ' Any product team that calls it '||
                    'must correct their code because it does not work '||
                    'correctly.  Please see the deprecated API document at '||
                    'http://files.oraclecorp.com/content/AllPublic/'||
                    'SharedFolders/ATG%20Requirements-Public/R12/'||
                    'Requirements%20Definition%20Document/'||
                    'Application%20Object%20Library/DeprecatedApiRDD.doc '||
                    'Oracle employees who encounter this error should log '||
                    'a bug against the product that owns the call to this '||
                    'routine, which is likely the owner of the object that '||
                    'was passed to this routine: '||
                    p_object_name);
              if (fnd_log.LEVEL_EXCEPTION >=
                      fnd_log.g_current_runtime_level) then
                fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.end_unsupported',
                     FALSE);
              end if;
              fnd_message.raise_error;
    end if;


    fnd_data_security.get_security_predicate(
      p_api_version, p_function, p_object_name, p_grant_instance_type,
      p_user_name, p_statement_type, x_predicate, x_return_status);
  end;

/* THIS ROUTINE IS DEPRECATED AND MAY BE DESUPPORTED.  DO NOT CALL IT. */
PROCEDURE get_instances
(
    p_api_version    IN  NUMBER,
    p_function       IN  VARCHAR2,
    p_object_name    IN  VARCHAR2,
    p_user_name      IN  VARCHAR2,
    x_return_status  OUT NOCOPY VARCHAR2,
    x_object_key_tbl OUT NOCOPY FND_INSTANCE_TABLE_TYPE
) is
    l_api_name              CONSTANT VARCHAR2(30)       := 'GET_INSTANCES';
    l_predicate             VARCHAR2(32767);
    l_dynamic_sql           VARCHAR2(32767);
    l_db_object_name        varchar2(30);
    l_db_pk1_column         varchar2(256);
    l_db_pk2_column         varchar2(256);
    l_db_pk3_column         varchar2(256);
    l_db_pk4_column         varchar2(256);
    l_db_pk5_column         varchar2(256);
    l_pk_column_names       varchar2(512);
    l_pk_orig_column_names  varchar2(512);
    l_ik_clause             varchar2(2048);
    l_exact_clause             varchar2(2048);
    l_pk1_val               varchar2(512);
    l_pk2_val               varchar2(512);
    l_pk3_val               varchar2(512);
    l_pk4_val               varchar2(512);
    l_pk5_val               varchar2(512);
    l_index                 number;

    TYPE  DYNAMIC_CUR IS REF CURSOR;
    instances_cur DYNAMIC_CUR;
begin
   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name|| '(' ||
          'p_api_version=>'|| to_char(p_api_version) ||
          ', p_function=>'|| p_function ||
          ', p_object_name=>'|| p_object_name ||
          ', p_user_name=>'|| p_user_name ||
          ')');
   end if;

   if (fnd_data_security.DISALLOW_DEPRECATED = 'Y') then
              /* In R12 this routine is deprecated, because it effectively */
              /* does a blind query, potentially returning zillions of */
              /* records, which is unsupportable from a performance */
              /* perspective. */
              /* So we raise a runtime exception to help people to know */
              /* they need to change their code. */
              fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
              fnd_message.set_token('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
              fnd_message.set_token('REASON',
                    'Invalid API call.  API '
                    ||c_pkg_name || '.'|| l_api_name ||
                    ' is desupported and should not be called in R12.'||
                    ' Any product team that calls it '||
                    'must correct their code because it does not work '||
                    'correctly.  Please see the deprecated API document at '||
                    'http://files.oraclecorp.com/content/AllPublic/'||
                    'SharedFolders/ATG%20Requirements-Public/R12/'||
                    'Requirements%20Definition%20Document/'||
                    'Application%20Object%20Library/DeprecatedApiRDD.doc '||
                    'Oracle employees who encounter this error should log '||
                    'a bug against the product that owns the call to this '||
                    'routine, which is likely the owner of the object that '||
                    'was passed to this routine: '||
                    p_object_name);
              if (fnd_log.LEVEL_EXCEPTION >=
                      fnd_log.g_current_runtime_level) then
                fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.end_unsupported',
                     FALSE);
              end if;
              fnd_message.raise_error;
   end if;

   get_security_predicate(p_api_version=>1.0,
                                   p_function =>p_function,
                                   p_object_name =>p_object_name,
                                   p_grant_instance_type =>C_TYPE_UNIVERSAL,
                                   p_user_name =>p_user_name,
                                   x_predicate=>l_predicate,
                                   x_return_status=>x_return_status);
   if((x_return_status <> 'T') AND (x_return_status <> 'F'))then
      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end_gsp_err',
          'returning status: '|| x_return_status);
      end if;
               /* There will be a message on the msg dict stack. */
      return;  /* We will return the x_return_status as an out param */
   end if;

   -- Get names and list of primary keys for this object.
   x_return_status := get_pk_information(p_object_name  ,
                             l_db_pk1_column  ,
                             l_db_pk2_column  ,
                             l_db_pk3_column  ,
                             l_db_pk4_column  ,
                             l_db_pk5_column  ,
                             l_pk_column_names  ,
                             l_ik_clause  ,
                             l_exact_clause,
                             l_pk_orig_column_names,
                             l_db_object_name,
                             'OBJTAB', 'GNT');
   if (x_return_status <> 'T') then
      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end_pk_info_err',
          'returning status: '|| x_return_status);
      end if;
      /* There will be a message on the msg dict stack. */
      return;  /* We will return the x_return_status as out param */
   end if;


   if (l_predicate is not NULL) then
      l_dynamic_sql :=
                 'SELECT  '|| l_pk_orig_column_names ||
                  ' FROM  '|| l_db_object_name ||
                 ' WHERE '||l_predicate||' ';
   else
      x_return_status := 'F';
      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end_nopred',
          'returning '|| x_return_status );
      end if;
      return;
   end if;

   if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
     fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  c_log_head || l_api_name || '.create_dy_sql',
                  'dynamic_sql:'||l_dynamic_sql);
   end if;

   l_index:=0;

   -- Run the statement,
   OPEN instances_cur FOR l_dynamic_sql;
   if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
     fnd_log.string(FND_LOG.LEVEL_STATEMENT,
          c_log_head || l_api_name || '.startloop',
          ' startloop');
   end if;
   LOOP
         if(    (l_db_pk5_column is NOT NULL)
            AND (l_db_pk5_column <> C_NULL_STR)) then
            FETCH instances_cur  INTO l_pk1_val,
                                      l_pk2_val,
                                      l_pk3_val,
                                      l_pk4_val,
                                      l_pk5_val;
         elsif(    (l_db_pk4_column is NOT NULL)
               AND (l_db_pk4_column <> C_NULL_STR)) then
            FETCH instances_cur  INTO l_pk1_val,
                                      l_pk2_val,
                                      l_pk3_val,
                                      l_pk4_val;
         elsif(    (l_db_pk3_column is NOT NULL)
               AND (l_db_pk3_column <> C_NULL_STR)) then
            FETCH instances_cur  INTO l_pk1_val,
                                      l_pk2_val,
                                      l_pk3_val;
         elsif(    (l_db_pk2_column is NOT NULL)
               AND (l_db_pk2_column <> C_NULL_STR)) then
            FETCH instances_cur  INTO l_pk1_val,
                                      l_pk2_val;
         elsif(    (l_db_pk1_column is NOT NULL)
               AND (l_db_pk1_column <> C_NULL_STR)) then
            FETCH instances_cur  INTO l_pk1_val;
         else
            x_return_status := 'U';
            return; /* This will never happen since pk1 is reqd*/
         end if;


         if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
           fnd_log.string(FND_LOG.LEVEL_STATEMENT,
             c_log_head || l_api_name || '.did_fetch',
             ' l_pk1_val: ' || l_pk1_val ||
             ' l_pk2_val: ' || l_pk2_val ||
             ' l_pk3_val: ' || l_pk3_val ||
             ' l_pk4_val: ' || l_pk4_val ||
             ' l_pk5_val: ' || l_pk5_val );
         end if;
         EXIT WHEN instances_cur%NOTFOUND;
         x_object_key_tbl(l_index).pk1_value := l_pk1_val;
         x_object_key_tbl(l_index).pk2_value := l_pk2_val;
         x_object_key_tbl(l_index).pk3_value := l_pk3_val;
         x_object_key_tbl(l_index).pk4_value := l_pk4_val;
         x_object_key_tbl(l_index).pk5_value := l_pk5_val;
         l_index:=l_index+1;
   END LOOP;
   CLOSE instances_cur;
   if(l_index > 0) then
      x_return_status := 'T'; /* Success */
   else
      x_return_status := 'F'; /* No instances */
   end if;

   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end',
          'returning '|| x_return_status );
   end if;
   return;

   EXCEPTION
      /* If API called where it is unsupported, */
      /* propagate that up so the caller gets exception */
      WHEN FND_MESSAGE_RAISED_ERR THEN
             /* Re raise the error for the caller */
             fnd_message.raise_error;
             x_return_status := 'U'; /* This line should never be executed */
             return;

      WHEN OTHERS THEN
        fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
        fnd_message.set_token('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
        fnd_message.set_token('ERRNO', SQLCODE);
        fnd_message.set_token('REASON', SQLERRM);

        if (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
          fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.other_err',
                   FALSE);
        end if;
        x_return_status := 'U';
        if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                  c_log_head || l_api_name || '.end_after_other',
                  ', x_return_status:'||x_return_status);
        end if;
        RETURN ;
end get_instances;

/* THIS FUNCTION IS DESUPPORTED.  DO NOT CALL THIS FUNCTION. */
/* FUNCTIONALITY HAS BEEN STRIPPED OUT.  THIS WON'T DO ANYTHING */
/* This nonfunctional stub is left in the API just to prevent compilation */
/* problems with old code from old patches. */
FUNCTION check_instance_in_set
 (
  p_api_version          IN  NUMBER,
  p_instance_set_name    IN  VARCHAR2,
  p_instance_pk1_value   IN  VARCHAR2,
  p_instance_pk2_value   IN  VARCHAR2,
  p_instance_pk3_value   IN  VARCHAR2,
  p_instance_pk4_value   IN  VARCHAR2,
  p_instance_pk5_value   IN  VARCHAR2
 ) return VARCHAR2 is
    l_api_name   CONSTANT VARCHAR2(30)  := 'CHECK_INSTANCE_IN_SET';

begin
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name|| '(' ||
          'p_api_version=>'|| to_char(p_api_version) ||
          ', p_instance_set_name=>'|| p_instance_set_name ||
          ', p_instance_pk1_value=>'|| p_instance_pk1_value ||
          ', p_instance_pk2_value=>'|| p_instance_pk2_value ||
          ', p_instance_pk3_value=>'|| p_instance_pk3_value ||
          ', p_instance_pk4_value=>'|| p_instance_pk4_value ||
          ', p_instance_pk5_value=>'|| p_instance_pk5_value ||')');
     end if;

     fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
     fnd_message.set_token('ROUTINE', c_pkg_name || '.'|| l_api_name);
     fnd_message.set_token('REASON',
                    'Desupported API called.  This routine is no longer '||
                    'supported because it is incompatible with  '||
                    'parameterized instance sets which were introduced '||
                    'in 4/2002. ');
     if (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
       fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.end_desupported',
                     FALSE);
     end if;

     fnd_message.raise_error;
     return 'u';/* unexpected error */

end check_instance_in_set;

/*
** replace_str- internal user only.  not in api.
** replace a character string if it doesn't occur in the middle of an
** alphanumeric string.
*/
function replace_str(in_pred  in varchar2, /* must be uppercased */
                      from_str in varchar2,
                      to_str   in varchar2) return varchar2 is
  punctuation varchar2(255);
  justspaces  varchar2(255);
  compare_pred varchar2(4000);
  out_pred    varchar2(4000);
  pred_frag   varchar2(4000);
  out_offset  number; /* difference in sizes as we are replacing smaller */
                      /* strings with bigger strings */
  xoldlen     number;
  xnewlen     number;
  i           number;
  j           number;
  maxlen      number := 4000; /* maximum length of predicate */
  before_char varchar2(30);
  match       boolean;
begin
  /* convert punctuation in predicate to spaces for comparison */
  punctuation := fnd_global.newline||'`~!@#$%^*()-=+|][{}\";:,<>/?''.';
  justspaces  := '                              ';
  compare_pred := upper(in_pred);
  out_pred := in_pred;
  xoldlen  := LENGTH(from_str);
  xnewlen  := LENGTH(to_str);

  i:= 99999;
  j:= 1;
  out_offset := 0;
  while (i<>0) loop
    i := instr(compare_pred, from_str, 1, j);
    if i=0 then
       exit;
    end if;

    if i<>1 then
      /* Make sure the character before the X isnt alphanumeric */
      /* or underscore, which would mean this is not a match */
      before_char := substr(compare_pred, i-1, 1);
      before_char := translate(before_char, punctuation, justspaces);
      if before_char = ' ' then
        match := TRUE;
      else
        match := FALSE;
      end if;
    else
      match := TRUE;
    end if;

    if (match) then
      /* Replace the string in the output
      ** predicate.  Clip the string to the max byte size allowed.
      */
      out_pred := substrb(   substr(out_pred, 1, i  + out_offset - 1)
                           || to_str
                           || substr(out_pred, i  + out_offset + xoldlen),
                        1, maxlen);
      out_offset := out_offset + xnewlen - xoldlen ;
    end if;

    j := j + 1;
  end loop;

  return out_pred;
end;

/*
** upgrade_predicate-
** an internal-only routine that upgrades the predicate
** from the 11.5.8- style predicate "X.column_name = G.parameter1"
** format to the new "[Amp]TABLE_ALIAS.column_name =
** [Amp]GRANT_ALIAS.parameter1"
** format where [Amp] represents an ampersand.
**
*/
FUNCTION upgrade_predicate(in_pred in varchar2) return VARCHAR2 is
  xpos number;
  gpos number;
  compare_pred varchar2(4000);
  out_pred    varchar2(4000);
  xoldval     varchar2(255) := 'X.';
  goldval     varchar2(255) := 'G.PARAMETER';
  xnewval     varchar2(255) := C_TABLE_ALIAS_TOK;
  gnewval     varchar2(255) := C_GRANT_ALIAS_TOK||'PARAMETER';
begin
  /* upper case the predicate for comparison */
  compare_pred := UPPER(in_pred);
  xpos := INSTR(compare_pred, xoldval);
  gpos := INSTR(compare_pred, goldval);
  if (xpos = 0 and gpos = 0) then
    return in_pred; /* Short circuit return if no upgrade candidates */
  end if;

  out_pred := in_pred;
  if(xpos <> 0) then
    out_pred := replace_str(out_pred, xoldval, xnewval);
  end if;
  if(gpos <> 0) then
    out_pred := replace_str(out_pred, goldval, gnewval);
  end if;
  return out_pred;
end upgrade_predicate;



/*
** upgrade_column_type-
** an internal-only routine that upgrades the FND_OBJECT column types
** from the obsolete NUMBER type to INTEGER type (leaving other types
** alone)
**
*/
FUNCTION upgrade_column_type(in_col_type in varchar2) return VARCHAR2 is
begin
  if (in_col_type = 'NUMBER') then
    return 'INTEGER';
  else
    return in_col_type;
  end if;
end upgrade_column_type;


/*
** upgrade_grantee_key-
** an internal-only routine that upgrades the GRANTEE_KEY to 'GLOBAL'
** in any case where the GRANTEE_TYPE is 'GLOBAL'.  This will go in 11.5.10.
**
*/
FUNCTION upgrade_grantee_key(in_grantee_type in varchar2,
                             in_grantee_key  in varchar2) return VARCHAR2 is
begin
  if (in_grantee_type = 'GLOBAL') then
    return 'GLOBAL';
  else
    return in_grantee_key;
  end if;
end upgrade_grantee_key;


/*
** substitute_pred-
**
** an internal-only routine that substitutes in the object table alias
** and the grant table alias in the fnd_grants table.
**
**
*/
FUNCTION substitute_predicate(in_pred in varchar2,
                             in_table_alias in varchar2) return VARCHAR2 is
  out_pred varchar2(4000);
  maxlen   number := 4000;
  gsubval     varchar2(255) := 'GNT.';
  l_table_alias varchar2(255);
begin
  if (in_table_alias is not NULL) then
     l_table_alias := in_table_alias || '.';
  else
     l_table_alias := NULL;
  end if;

  out_pred := in_pred;
  out_pred := substrb(replace(out_pred, C_TABLE_ALIAS_TOK,
                              l_table_alias), 1, maxlen);

  out_pred := substrb(replace(out_pred, C_GRANT_ALIAS_TOK,
                              gsubval), 1, maxlen);

  return out_pred;
end substitute_predicate;

/*
** to_int-
** Convert an integer (no decimal) canonical format VARCHAR2 into NUMBER.
** This should be used with id type numbers that don't have decimals
** because it performs better than to_decimal().
** If due to the SQL statement being evaluated in an unanticipated order,
** this is being called on non-numerical data, just returns -11111.
** The reason that it is essential that this is called instead of to_number()
** on grant parameters is that this routine will not cause an exception if
** the generated predicate ends up being evaluated such that the grant
** rows are not filtered before going through the fnd_data_security.to_int()
** routine.  Some grant rows may have non-numeric data if they are for other
** object instance sets.  We need to make sure that the data security
** clause will not generate an exception no matter what order the database
** decides to evaluate the statement in.
*/
FUNCTION to_int(inval in varchar2) return NUMBER is
  outval NUMBER;
begin
  if (inval is NULL) then
    return NULL;
  end if;

  begin
    outval := to_number(inval);
  exception
    when value_error then
      outval := -11111;
  end;
  return outval;
end;

/*
** to_decimal-
** Convert a canonical format VARCHAR2 with a decimal into a NUMBER.
** This must be used rather than to_int() whenever the data has a decimal
** character.
** If due to the SQL statement being evaluated in an unanticipated order,
** this is being called on non-numerical data, just return -11111.
*/
FUNCTION to_decimal(inval in varchar2) return NUMBER is
  outval NUMBER;
begin
  if (inval is NULL) then
    return NULL;
  end if;

  begin
    outval := fnd_number.canonical_to_number(inval);
  exception
    when value_error then
      outval := -11111;
  end;
  return outval;
end;

/*
** to_date-
** Convert a canonical format date VARCHAR2 into a DATE.
** If due to the SQL statement being evaluated in an unanticipated order,
** this is being called on non-date data, returns 1970/11/11.
*/
FUNCTION to_date(inval in varchar2/* format 'YYYY/MM/DD' */) return DATE is
  outval DATE;
/* GSSC note: the above line may errantly cause File.Date.5 but this file */
/* AFSCDSCB.pls is grandfathered in so it will still build */
begin
  if (inval is NULL) then
    return NULL;
  end if;

  begin
    outval := fnd_date.canonical_to_date(inval);
  exception
    when others then
      outval := g_bad_date;
  end;
  return outval;
end;

END FND_DATA_SECURITY;

/
