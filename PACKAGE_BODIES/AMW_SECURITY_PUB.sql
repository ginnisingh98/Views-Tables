--------------------------------------------------------
--  DDL for Package Body AMW_SECURITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_SECURITY_PUB" as
/*$Header: amwpsecb.pls 120.2 2006/09/14 10:32:11 yreddy noship $*/



  C_PKG_NAME       CONSTANT VARCHAR2(30) := 'AMW_SECURITY_PUB';
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
  /* In 8.1.7 databases the limit is 4k, and in 8.2 it will be 32k. */
  /* Once we no longer support 8.1.7 then we can increase this to 32,000 */
  c_vpd_buf_limit CONSTANT NUMBER := 32*1024;

  /* One level cache for get_object_id() */
  g_obj_id_cache     NUMBER := NULL;
  g_obj_name_cache   VARCHAR2(30) := NULL;

  /* One level cache for get_function_id() */
  g_func_id_cache    NUMBER := NULL;
  g_func_name_cache  VARCHAR2(30) := NULL;

  /* One level cache for get_security_predicate */
  g_gsp_function             VARCHAR2(30)  := '*EMPTY*';
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



  ------------------------------------
--  Directly copied from fnd_data_security, slightly modified
  ------------------------------------

function replace_str(in_pred  in varchar2, /* must be uppercased */
                      from_str in varchar2,
                      to_str   in varchar2) return varchar2 is
  punctuation varchar2(255);
  justspaces  varchar2(255);
  compare_pred varchar2(32767);
  out_pred    varchar2(32767);
  pred_frag   varchar2(32767);
  out_offset  number; /* difference in sizes as we are replacing smaller */
                      /* strings with bigger strings */
  xoldlen     number;
  xnewlen     number;
  i           number;
  j           number;
  maxlen      number := 32767; /* maximum length of predicate */
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


  ------------------------------------
--  Directly copied from fnd_data_security, slightly modified
  ------------------------------------

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


  ------------------------------------
--  Directly copied from fnd_data_security, slightly modified
  ------------------------------------

Function get_object_id(p_object_name in varchar2
                       ) return number is
v_object_id number;
l_api_name             CONSTANT VARCHAR2(30) := 'GET_OBJECT_ID';
Begin
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

   return v_object_id;
exception
   when no_data_found then
     return null;
end;


  ------------------------------------
--  Directly copied from fnd_data_security, slightly modified
  ------------------------------------

Function get_function_id(p_function_name in varchar2
                       ) return number is
v_function_id number;
l_api_name             CONSTANT VARCHAR2(30) := 'GET_FUNCTION_ID';
Begin
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

   return v_function_id;
exception
   when no_data_found then
     return null;
end;


  ------------------------------------
--  Directly copied from fnd_data_security, slightly modified
  ------------------------------------

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

         select 1
         into l_dummy
         from wf_user_roles
         where user_name = p_user_name
         and rownum = 1;

      g_ck_user_role_result := 'T';
      g_ck_user_role_name := p_user_name;
      return g_ck_user_role_result;

  exception when no_data_found then
    g_ck_user_role_result := 'F';
    g_ck_user_role_name := p_user_name;
    return g_ck_user_role_result;

end CHECK_USER_ROLE;


  ------------------------------------
--  Directly copied from fnd_data_security, slightly modified
  ------------------------------------


procedure get_name_bind(p_user_name in VARCHAR2,
                      x_user_name_bind      out NOCOPY varchar2) is
   l_api_name         CONSTANT VARCHAR2(30) := 'GET_NAME_BIND';
   colon pls_integer;
   l_unfound BOOLEAN;
   x_user_id number;
   x_is_per_person number;
begin

   if ((p_user_name is NULL) or (p_user_name = 'GLOBAL')) then
     x_user_name_bind := ''''|| replace(p_user_name, '''','''''')||'''';
     return;
   end if;

   if (p_user_name =  SYS_CONTEXT('FND','USER_NAME')) then
     x_user_name_bind := 'SYS_CONTEXT(''FND'',''USER_NAME'')';
     return;
   else
     x_user_name_bind := ''''||replace(p_user_name, '''', '''''')||'''';
     return;
   end if;

   /* This line should never be reached. */
   x_user_name_bind := 'ERROR_IN_GET_NAME_BIND';
   return;

end;


  ------------------------------------
--  Directly copied from fnd_data_security, slightly modified
  ------------------------------------

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
       return 'U';
   end if;

   CLOSE c_pk;

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

   return 'T';
end;


  ------------------------------------
--  Directly copied from fnd_data_security, slightly modified
  ------------------------------------

FUNCTION upgrade_predicate(in_pred in varchar2) return VARCHAR2 is
  xpos number;
  gpos number;
  compare_pred varchar2(32767);
  out_pred    varchar2(32767);
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


  ------------------------------------
--  Directly copied from fnd_data_security, slightly modified
  ------------------------------------

FUNCTION substitute_predicate(in_pred in varchar2,
                             in_table_alias in varchar2) return VARCHAR2 is
  out_pred varchar2(32767);
  maxlen   number := 32767;
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

  ------------------------------------
--  Grant Role
  ------------------------------------
  PROCEDURE grant_role_guid
  (
   p_api_version           IN  NUMBER,
   p_role_name             IN  VARCHAR2,
   p_object_name           IN  VARCHAR2,
   p_instance_type         IN  VARCHAR2,
   p_instance_set_id       IN  NUMBER,
   p_instance_pk1_value    IN  VARCHAR2,
   p_instance_pk2_value    IN  VARCHAR2,
   p_instance_pk3_value    IN  VARCHAR2,
   p_instance_pk4_value    IN  VARCHAR2,
   p_instance_pk5_value    IN  VARCHAR2,
   p_party_id              IN  NUMBER,
   p_start_date            IN  DATE,
   p_end_date              IN  DATE,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_errorcode             OUT NOCOPY NUMBER,
   x_grant_guid            OUT NOCOPY RAW,
   p_check_for_existing    IN VARCHAR2 := FND_API.G_TRUE
  )
  IS

  --x_grant_guid         fnd_grants.grant_guid%TYPE;
  l_grantee_type       hz_parties.party_type%TYPE;
  l_instance_type      fnd_grants.instance_type%TYPE;
  l_grantee_key        fnd_grants.grantee_key%TYPE;
  l_dummy              VARCHAR2(1);
  l_not_found		   boolean := true;
  CURSOR get_party_type (cp_party_id NUMBER)
  IS
    SELECT party_type
      FROM hz_parties
    WHERE party_id=cp_party_id;

  CURSOR check_fnd_grant_exist (cp_grantee_key       VARCHAR2,
                               cp_grantee_type            VARCHAR2,
                               cp_menu_name               VARCHAR2,
                               cp_object_name             VARCHAR2,
                               cp_instance_type           VARCHAR2,
                               cp_instance_pk1_value      VARCHAR2,
                               cp_instance_pk2_value      VARCHAR2,
                               cp_instance_pk3_value      VARCHAR2,
                               cp_instance_pk4_value      VARCHAR2,
                               cp_instance_pk5_value      VARCHAR2,
                               cp_instance_set_id         NUMBER,
                               cp_start_date              DATE,
                               cp_end_date                DATE) IS

        SELECT 'X'
        FROM fnd_grants grants,
             fnd_objects obj,
             fnd_menus menus
        WHERE grants.grantee_key=cp_grantee_key
        AND  grants.grantee_type=cp_grantee_type
        AND  grants.menu_id=menus.menu_id
        AND  menus.menu_name=cp_menu_name
        AND  grants.object_id = obj.object_id
        AND obj.obj_name=cp_object_name
        AND grants.instance_type=cp_instance_type
        AND ((grants.instance_pk1_value=cp_instance_pk1_value )
            OR((grants.instance_pk1_value = '*NULL*') AND (cp_instance_pk1_value IS NULL)))
        AND ((grants.instance_pk2_value=cp_instance_pk2_value )
            OR((grants.instance_pk2_value = '*NULL*') AND (cp_instance_pk2_value IS NULL)))
        AND ((grants.instance_pk3_value=cp_instance_pk3_value )
            OR((grants.instance_pk3_value = '*NULL*') AND (cp_instance_pk3_value IS NULL)))
        AND ((grants.instance_pk4_value=cp_instance_pk4_value )
            OR((grants.instance_pk4_value = '*NULL*') AND (cp_instance_pk4_value IS NULL)))
        AND ((grants.instance_pk5_value=cp_instance_pk5_value )
            OR((grants.instance_pk5_value = '*NULL*') AND (cp_instance_pk5_value IS NULL)))
        AND ((grants.instance_set_id=cp_instance_set_id )
            OR((grants.instance_set_id IS NULL ) AND (cp_instance_set_id IS NULL)))
        AND (((grants.start_date<=cp_start_date )
            AND (( grants.end_date IS NULL) OR (cp_start_date <=grants.end_date )))
        OR ((grants.start_date >= cp_start_date )
            AND (( cp_end_date IS NULL)  OR (cp_end_date >=grants.start_date))));

    v_start_date DATE := sysdate;

  BEGIN
       if (p_start_date IS NULL) THEN
      v_start_date := sysdate;
       else
      v_start_date := p_start_date;
       end if;

       IF( p_instance_type <> 'INSTANCE') THEN
          l_instance_type:='SET';
       ELSE
          l_instance_type:=p_instance_type;
       END IF;
       OPEN get_party_type (cp_party_id =>p_party_id);
       FETCH get_party_type INTO l_grantee_type;
       CLOSE get_party_type;
       IF(  p_party_id = -1000) THEN
          l_grantee_type :='GLOBAL';
          l_grantee_key:='HZ_GLOBAL:'||p_party_id;
       ELSIF (l_grantee_type ='PERSON') THEN
          l_grantee_type:='USER';
          l_grantee_key:='HZ_PARTY:'||p_party_id;
       ELSIF (l_grantee_type ='GROUP') THEN
          l_grantee_type:='GROUP';
          l_grantee_key:='HZ_GROUP:'||p_party_id;
       ELSIF (l_grantee_type ='ORGANIZATION') THEN
          l_grantee_type:='COMPANY';
          l_grantee_key:='HZ_COMPANY:'||p_party_id;
       ELSE
           null;
       END IF;
	   IF (p_check_for_existing = FND_API.G_TRUE ) THEN
       	OPEN check_fnd_grant_exist(cp_grantee_key  => l_grantee_key,
                      cp_grantee_type       => l_grantee_type,
                      cp_menu_name          => p_role_name,
                      cp_object_name        => p_object_name,
                      cp_instance_type      => l_instance_type,
                      cp_instance_pk1_value => p_instance_pk1_value,
                      cp_instance_pk2_value => p_instance_pk2_value,
                      cp_instance_pk3_value => p_instance_pk3_value,
                      cp_instance_pk4_value => p_instance_pk4_value,
                      cp_instance_pk5_value => p_instance_pk5_value,
                      cp_instance_set_id    => p_instance_set_id,
                      cp_start_date         => v_start_date,
                      cp_end_date           => p_end_date);

       	FETCH check_fnd_grant_exist INTO l_dummy;
       	IF( check_fnd_grant_exist%FOUND) THEN
       		l_not_found := false;
	   	END IF;
	   	CLOSE check_fnd_grant_exist;
	   END IF;
	   IF (l_not_found) THEN
         fnd_grants_pkg.grant_function(
              p_api_version        => 1.0,
              p_menu_name          => p_role_name ,
              p_object_name        => p_object_name,
              p_instance_type      => l_instance_type,
              p_instance_set_id    => p_instance_set_id,
              p_instance_pk1_value => p_instance_pk1_value,
              p_instance_pk2_value => p_instance_pk2_value,
              p_instance_pk3_value => p_instance_pk3_value,
              p_instance_pk4_value => p_instance_pk4_value,
              p_instance_pk5_value => p_instance_pk5_value,
              p_grantee_type       => l_grantee_type,
              p_grantee_key        => l_grantee_key,
              p_start_date         => v_start_date,
              p_end_date           => p_end_date,
              p_program_name       => null,
              p_program_tag        => null,
              x_grant_guid         => x_grant_guid,
              x_success            => x_return_status,
              x_errorcode          => x_errorcode
          );
              if(p_instance_type = 'INSTANCE') then
                AMW_SECURITY_UTILS_PVT.give_dependant_grants (
                                p_grant_guid		=> x_grant_guid,
                                p_parent_obj_name	=> p_object_name,
                                p_parent_role		=> p_role_name,
                                p_parent_pk1		=> p_instance_pk1_value,
                                p_parent_pk2		=> p_instance_pk2_value,
                                p_parent_pk3		=> p_instance_pk3_value,
                                p_parent_pk4		=> p_instance_pk4_value,
                                p_parent_pk5		=> p_instance_pk5_value,
                                p_grantee_type		=> l_grantee_type,
                                p_grantee_key		=> l_grantee_key,
                                p_start_date		=> v_start_date,
                                p_end_date		    => p_end_date,
                                x_success		    => x_return_status,
                                x_errorcode 		=> x_errorcode);
              end if;


        ELSE
          x_return_status:='F';
        END IF;



  END grant_role_guid;


  ------------------------------------
--  Grant Privilege
  ------------------------------------
  PROCEDURE grant_role_guid
  (
   p_api_version           IN  NUMBER,
   p_role_name             IN  VARCHAR2,
   p_object_name           IN  VARCHAR2,
   p_instance_type         IN  VARCHAR2,
   p_object_key            IN  NUMBER,
   p_party_id              IN  NUMBER,
   p_start_date            IN  DATE,
   p_end_date              IN  DATE,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_errorcode             OUT NOCOPY NUMBER,
   x_grant_guid            OUT NOCOPY RAW
  )
  IS
    -- Start OF comments
    -- API name  : Grant
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Grant a Role on object instances to a Party.
    --             If this operation fails then the grant is not
    --             done and error code is returned.
    --
    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
  l_instance_set_id    fnd_grants.instance_set_id%TYPE;
  l_instance_pk1_value fnd_grants.instance_pk1_value%TYPE;
  v_start_date  DATE := sysdate;

  BEGIN
      IF( p_instance_type ='SET') THEN
         l_instance_set_id:=p_object_key;
         l_instance_pk1_value:= null;
       ELSE
         l_instance_set_id:=null;
         l_instance_pk1_value:= to_char(p_object_key);
       END IF;

       if (p_start_date IS NULL) THEN
      v_start_date := sysdate;
       else
      v_start_date := p_start_date;
       end if;

       grant_role_guid
       (
         p_api_version         => p_api_version,
         p_role_name           => p_role_name,
         p_object_name         => p_object_name,
         p_instance_type       => p_instance_type,
         p_instance_set_id     => l_instance_set_id,
         p_instance_pk1_value  => l_instance_pk1_value,
         p_instance_pk2_value  => null,
         p_instance_pk3_value  => null,
         p_instance_pk4_value  => null,
         p_instance_pk5_value  => null,
         p_party_id            => p_party_id,
         p_start_date          => v_start_date,
         p_end_date            => p_end_date,
         x_return_status       => x_return_status,
         x_errorcode           => x_errorcode,
         x_grant_guid          => x_grant_guid
       );

   END grant_role_guid;


  --------------------------
--  Revoke Grant
  --------------------------
  PROCEDURE revoke_grant
  (
   p_api_version    IN  NUMBER,
   p_grant_guid     IN  VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_errorcode      OUT NOCOPY NUMBER
  )
  IS
    -- Start OF comments
    -- API name  : Revoke
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Revoke a Party's role on object instances.
    --             If this operation fails then the revoke is
    --             done and error code is returned.
    --
    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments

   l_grant_guid   fnd_grants.grant_guid%TYPE;
   CURSOR get_grant_guid(cp_grant_id VARCHAR2)
   IS
     SELECT grant_guid
     FROM fnd_grants
     WHERE grant_guid=HEXTORAW(cp_grant_id);

   BEGIN
      OPEN get_grant_guid(cp_grant_id=>p_grant_guid);
      FETCH get_grant_guid INTO l_grant_guid;
      CLOSE get_grant_guid;

        AMW_SECURITY_UTILS_PVT.revoke_dependant_grants(
                                 p_grant_guid => l_grant_guid,
                                 x_success    => x_return_status,
                                 x_errorcode  => x_errorcode);

      fnd_grants_pkg.revoke_grant(
        p_api_version  => p_api_version,
        p_grant_guid   => l_grant_guid  ,
        x_success      => x_return_status,
        x_errorcode    => x_errorcode
      );

  END revoke_grant;


 ------------------------------------
--  Set end date to a grant
  ------------------------------------
  PROCEDURE set_grant_date
  (
   p_api_version    IN  NUMBER,
   p_grant_guid     IN  VARCHAR2,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   x_return_status  OUT NOCOPY VARCHAR2
  )IS
   -- Start OF comments
   -- API name : SET_GRANT_DATE
   -- TYPE : Public
   -- Pre-reqs : None
   -- FUNCTION :sets start date and end date to a grant
   --
   --
   --
   -- Version: Current Version 1.0
   -- Previous Version :  None
   -- Notes  :
   --
   -- END OF comments

  --x_success  VARCHAR2(2);
  l_dummy              VARCHAR2(1);
  l_grant_guid   fnd_grants.grant_guid%TYPE;
   CURSOR get_grant_guid(cp_grant_id VARCHAR2,
                         cp_start_date DATE,
                         cp_end_date DATE)
   IS
     SELECT g1.grant_guid
     FROM fnd_grants g1, fnd_grants g2
     WHERE g1.grant_guid=HEXTORAW(cp_grant_id)
      AND g2.grant_guid<>HEXTORAW(cp_grant_id)
      AND g1.object_id=g2.object_id
      AND g1.menu_id=g2.menu_id
      AND g1.instance_type=g2.instance_type
      AND g1.instance_pk1_value=g2.instance_pk1_value
      AND g1.grantee_type=g2.grantee_type
      AND g1.grantee_key=g2.grantee_key
      AND (
            ((g2.start_date<=cp_start_date )
            AND (( g2.end_date IS NULL) OR (cp_start_date<=g2.end_date )))
        OR ((g2.start_date >= cp_start_date )
            AND (( cp_end_date IS NULL)  OR (cp_end_date>=g2.start_date)))
      );

   BEGIN
      OPEN get_grant_guid(cp_grant_id=>p_grant_guid,
                          cp_start_date=>p_start_date,
                          cp_end_date=>p_end_date);
      FETCH get_grant_guid INTO l_grant_guid;

      IF( get_grant_guid%NOTFOUND) THEN
           fnd_grants_pkg.update_grant (
              p_api_version => p_api_version,
              p_grant_guid  => HEXTORAW(p_grant_guid),
              p_start_date  => p_start_date,
              p_end_date    => p_end_date,
              x_success     => x_return_status
           );

            AMW_SECURITY_UTILS_PVT.update_dependant_grants(
                                 p_grant_guid		=> HEXTORAW(p_grant_guid),
                                 p_new_start_date	=> p_start_date,
                                 p_new_end_date		=> p_end_date,
                                 x_success		=> x_return_status);

      ELSE
            x_return_status:='F';

      END IF;

      CLOSE get_grant_guid;

  END set_grant_date;


-- abedajna: basically copied from fnd_data_security
-- gets rid of some useless backsupport stuff
-- and uses a different of constructing predicate
-- such the the 32k buffer limit is never hit.

  PROCEDURE get_security_predicate_intrnl(
    p_api_version      IN  NUMBER,
    p_function         IN  VARCHAR2,
    p_object_name      IN  VARCHAR2,
    p_grant_instance_type  IN  VARCHAR2,/* SET, INSTANCE*/
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

    l_api_name   CONSTANT VARCHAR2(30)      := 'GET_SECURITY_PREDICATE_INTRNL';

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
    l_last_pred             varchar2(32767);
    l_need_to_close_pred    BOOLEAN;
    l_refers_to_grants      BOOLEAN;
    l_last_was_hextoraw     BOOLEAN;
    l_pred                  varchar2(32767);
    l_uses_params           BOOLEAN;
    d_predicate             VARCHAR2(32767);
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
    -- abedajna
    top varchar2(500);
    mid1 varchar2(1000);
    mid2 varchar2(1000);
    mid3 varchar2(1000);
    bottom varchar2(2000);
    guid_subquery varchar2(32767);


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
         SELECT /*+ INDEX(g, FND_GRANTS_N1) */ 1
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


     l_object_id number   := -2;
     l_function_id number := -2;

    BEGIN

       x_function_id := NULL;
       x_object_id := NULL;
       x_bind_order := NULL;
       x_predicate := NULL;
       x_return_status := 'T'; /* Assume Success */

       -- check for call compatibility.
       if TRUNC(l_api_version) <> TRUNC(p_api_version) THEN
               x_return_status := 'U'; /* Unexpected Error */
               return;
       END IF;

       /* default username if necessary. */
       if (p_user_name is NULL) then
          l_user_name := SYS_CONTEXT('FND','USER_NAME');
       else
          l_user_name := p_user_name;
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
        return;
       end if;

       -- Check to make sure we're not using unsupported statement_type
       if (     (p_statement_type <> 'VPD')
            AND (p_statement_type <> 'BASE' /* Deprecated, same as VPD */)
            AND (p_statement_type <> 'OTHER')
            AND (p_statement_type <> 'EXISTS')) then
               x_return_status := 'U'; /* Unexpected Error */
               return;
       end if;


       /* Make sure that the FND_COMPILED_MENU_FUNCTIONS table is compiled */
       if (FND_FUNCTION.G_ALREADY_FAST_COMPILED <> 'T') then
         FND_FUNCTION.FAST_COMPILE;
       end if;


       /* check if we need to call through to old routine */
--       IF (   (p_grant_instance_type = 'FUNCLIST')
--            OR (p_grant_instance_type = 'FUNCLIST_NOINST')
--            OR (p_grant_instance_type = 'GRANTS_ONLY'))THEN
--           /* If this is one of the modes that require the old-style */
--           /* statement, just call the old code for that.  */
--           get_security_predicate_helper(
--            p_function,
--            p_object_name,
--            p_grant_instance_type,
--            p_user_name,
--            p_statement_type,
--            x_predicate,
--            x_return_status,
--            p_table_alias);
--           return;
--       end if;

       -- Check to make sure a valid role is passed or defaulted for user_name
       if (check_user_role (l_user_name) = 'F') then
         -- If we got here then the grantee will never be found because
         -- it isn't even a role, so we know there won't be a matching grant.
         l_aggregate_predicate := '1=2';
         x_return_status := 'E'; /* Error condition */
         goto return_and_cache;
       end if;

       /* Set up flags depending on which mode we are running in. */
       IF (p_grant_instance_type = C_TYPE_INSTANCE) THEN
            l_instance_set_flag:= FALSE;
       ELSIF (p_grant_instance_type = C_TYPE_SET) THEN
            l_instance_flag:= FALSE;
       ELSIF (p_grant_instance_type = 'UNIVERSAL') THEN
        null;
       END IF;


       -- Get the key columns from the user name
       -- We are not checking for NULL returns (meaning user not in wf_roles)
       -- because right now we allow checking of grants to users not in
       -- wf_roles.
       get_name_bind(l_user_name,
                          l_user_name_bind);


        if (p_object_name is NULL) THEN
            x_return_status := 'U';
            return;
        END IF;

        if(p_object_name = 'GLOBAL') then
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
            x_return_status := 'U';
            return;
          END IF;
        end if;

        if(p_function is NULL) then
          l_function_id := -1;
        else
          l_function_id := get_function_id(p_function);
          if (l_function_id is NULL) THEN
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


        end if; /* l_instance_flag */

<<global_inst_type>>

        /* If we have a global instance type grant, then all rows are */
        /* in scope, so just return 1=1 */
        if(l_global_instance_type = TRUE) then
           l_aggregate_predicate := '1=1';
           x_return_status := 'T';
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
           goto return_and_cache;
        end if;

        /* If we have an instance type grant, but no recognized grantee, */
        /* that is a data error, so signal that error */
        if(l_inst_instance_type = TRUE and
           l_inst_group_grantee_type = FALSE and
           l_inst_global_grantee_type = FALSE) then
           l_set_instance_type := TRUE;
        end if;

        /* Build up the instance set part of the predicate */
        l_last_pred := '*NO_PRED*';
        if(l_set_instance_type = TRUE) then

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

           elsif(  l_set_group_grantee_type
               AND (NOT l_set_global_grantee_type)
               AND l_function_id <> -1) then

                   OPEN isg_grp_fn_c (l_user_name,
                                      l_function_id,
                                      l_object_id);
                   l_grp_fn := TRUE;

           elsif(NOT l_set_group_grantee_type
               AND l_set_global_grantee_type
               AND l_function_id <> -1) then
              OPEN isg_glob_fn_c (l_user_name,
                                          l_function_id,
                                          l_object_id);
              l_glob_fn := TRUE;
           else
              x_return_status := 'U';
              return;
           end if;

           l_cursor_is_open := TRUE;
           LOOP
              if (l_grp_glob_fn) then
                 FETCH isg_grp_glob_fn_c INTO d_predicate, d_instance_set_id,
                                             d_grant_guid;
                 if (isg_grp_glob_fn_c%notfound) then
                    close isg_grp_glob_fn_c;
                    l_cursor_is_open := FALSE;
                    exit; -- exit loop
                 end if;
              elsif (l_grp_fn) then
                    FETCH isg_grp_fn_c INTO d_predicate, d_instance_set_id,
                                               d_grant_guid;
                    if (isg_grp_fn_c%notfound) then
                       close isg_grp_fn_c;
                       l_cursor_is_open := FALSE;
                       exit; -- exit loop
                    end if;

              elsif (l_glob_fn) then
                 FETCH isg_glob_fn_c INTO d_predicate, d_instance_set_id,
                                             d_grant_guid;
                 if (isg_glob_fn_c%notfound) then
                    close isg_glob_fn_c;
                    l_cursor_is_open := FALSE;
                    exit; -- exit loop
                 end if;
              else
                 x_return_status := 'U';
                 return;
              end if;

              /* If we are coming upon a new instance set */
              if (d_instance_set_id <>
                  l_last_instance_set_id) then
                 if (l_need_to_close_pred) then /* Close off the last pred */
                   l_aggregate_predicate := substrb( l_aggregate_predicate ||
                        ') AND '|| l_pred ||')', 1, c_pred_buf_size);
                   l_need_to_close_pred := FALSE;
                   l_last_was_hextoraw := FALSE;
                 end if;

                 /* If we need to add an OR, do so. */
                 if (l_last_pred <> '*NO_PRED*') then
                   l_aggregate_predicate := substrb( l_aggregate_predicate ||
                        ' OR ', 1, c_pred_buf_size);
                 end if;

                 /* Upgrade and substitute predicate */
                 l_pred := upgrade_predicate(
                                 d_predicate);

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

                 /* If this is the simple form of predicate that does not */
                 /* refer to parameters in the grant table */
                 if ( NOT l_uses_params) then
                    l_aggregate_predicate  :=
                              substrb( l_aggregate_predicate ||
                                 '('|| l_pred ||')', 1, c_pred_buf_size);
                    l_need_to_close_pred := FALSE;
                    l_refers_to_grants := FALSE;
                 else /* Has references to grant table so we subselect */
                      /* against the grants table */
-- abedajna begin

top := 	' SELECT g.grant_guid ' ||
           ' FROM fnd_grants g, fnd_compiled_menu_functions cmf ' ||
          '  WHERE g.instance_type = '||''''||'SET'||'''' ||
          '  and g.instance_set_id = ' || d_instance_set_id ||
          '  AND g.menu_id = cmf.menu_id AND cmf.function_id = '|| l_function_id;



mid1 :=           '   AND ((g.grantee_key in ' ||
                  ' (select role_name ' ||
                  '    from wf_user_roles ' ||
                  '   where user_name in ' ||
                  '    (select incrns.name ' ||
                  '       from wf_local_roles src, ' ||
                  '            wf_local_roles incrns ' ||
                  '      where src.name                = '||''''||l_user_name||''''  ||
                  '        and src.parent_orig_system  = incrns.parent_orig_system ' ||
                  '        and src.parent_orig_system_id  = incrns.parent_orig_system_id) ' ||
                  '  )) ' ||
                  '  OR (g.grantee_type = '||''''|| 'GLOBAL'|| '''' || ')) ';


mid2 :=           '   AND (g.grantee_key in ' ||
                  ' (select role_name ' ||
                  '    from wf_user_roles ' ||
                  '   where user_name in ' ||
                  '    (select incrns.name ' ||
                  '       from wf_local_roles src ' ||
                  '            ,wf_local_roles incrns ' ||
                  '      where src.name                = '||''''||l_user_name||''''  ||
                  '        and src.parent_orig_system  = ' ||
                  '                        incrns.parent_orig_system ' ||
                  '        and src.parent_orig_system_id  = ' ||
                  '                        incrns.parent_orig_system_id) ' ||
                  ' )) ';

mid3 :=            ' AND  (g.grantee_type = '||''''|| 'GLOBAL' ||'''' || ') ';


bottom := ' AND g.object_id = ' || l_object_id  ||
          '  AND (   g.ctx_secgrp_id    = -1 ' ||
          '       OR g.ctx_secgrp_id    = ' ||
          '                          SYS_CONTEXT('||''''||'FND'||''''||','||''''||'SECURITY_GROUP_ID'||''''||')) ' ||
          '  AND (   g.ctx_resp_id      = -1 ' ||
          '       OR g.ctx_resp_id      = SYS_CONTEXT('||''''||'FND'||''''||','||''''||'RESP_ID'||''''||')) ' ||
          '  AND (   g.ctx_resp_appl_id = -1 ' ||
          '       OR g.ctx_resp_appl_id = SYS_CONTEXT('||''''||'FND'||''''||','||''''||'RESP_APPL_ID'||''''||')) ' ||
          '  AND (   g.ctx_org_id       = -1 ' ||
          '       OR g.ctx_org_id       = SYS_CONTEXT('||''''||'FND'||''''||', '||''''||'ORG_ID'||''''||')) ' ||
          '  AND g.start_date <= SYSDATE ' ||
          '  AND (   g.end_date IS NULL ' ||
          '       OR g.end_date >= SYSDATE ) ';


if (l_grp_glob_fn) then
	guid_subquery := ' ( '||top || mid1 || bottom;
elsif (l_grp_fn) then
	guid_subquery := ' ( '||top || mid2 || bottom;
elsif (l_glob_fn) then
	guid_subquery := ' ( '||top || mid3 || bottom;
end if;


-- abedajna end

                    l_aggregate_predicate  :=
                         substrb( l_aggregate_predicate ||
                         ' exists (select null'||
                                      ' from fnd_grants gnt'||
                                     ' where gnt.grant_guid in ' || guid_subquery,
                                                    1, c_pred_buf_size);
                    l_need_to_close_pred := TRUE;
                    l_refers_to_grants := TRUE;
                 end if;
              end if;

              l_last_instance_set_id := d_instance_set_id;
              l_last_pred := d_predicate;

              /* Add this grant_guid to the predicate */
--              if (l_refers_to_grants) then
--                 if (l_last_was_hextoraw) then /* Add a comma if necessary */
--                    l_aggregate_predicate  :=
--                       substrb(l_aggregate_predicate ||
--                         ', ', 1, c_pred_buf_size);
--                 end if;
--                 l_aggregate_predicate  :=
--                       substrb( l_aggregate_predicate ||
--                         'hextoraw('''|| d_grant_guid
--                         ||''')', 1, c_pred_buf_size);
--                 l_last_was_hextoraw := TRUE;
--              else
--                 l_last_was_hextoraw := FALSE;
--              end if;
           END LOOP;

           /* Close the cursor */
           if (l_cursor_is_open) then
             if (l_grp_glob_fn) then
                close isg_grp_glob_fn_c;
             elsif (l_grp_fn) then
                close isg_grp_fn_c;
             elsif (l_glob_fn) then
                close isg_glob_fn_c;
             else
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

                         l_instance_predicate :=
                         l_instance_predicate ||
                             ' (    GNT.grantee_key in ' ||
                                  ' (select role_name '||
                                     ' from wf_user_roles wur'||
                                    ' where wur.user_name  in '||
                                       ' (select incrns.name '||
                                          ' from wf_local_roles src '||
                                              ' ,wf_local_roles incrns '||
                                         ' where src.name = ' ||
                                              l_user_name_bind ||
                                           ' and src.parent_orig_system '||
                                               ' = incrns.parent_orig_system '||
                                           ' and src.parent_orig_system_id  '||
                                               ' = incrns.parent_orig_system_id)))';
          end if;

          if (l_inst_global_grantee_type) then
             if (l_inst_group_grantee_type) then
                l_instance_predicate :=
                 l_instance_predicate ||
                 ' OR';
             end if;
             l_instance_predicate := l_instance_predicate ||
                  ' (GNT.grantee_type = ''GLOBAL'')';
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
          x_predicate :='ROWNUM=1 and ('||l_aggregate_predicate||')';
        else
          x_predicate :='('||l_aggregate_predicate||')';
        end if;

        if (    (lengthb(l_aggregate_predicate) > c_vpd_buf_limit)
            AND (   (p_statement_type = 'BASE') /* deprecated, same as VPD*/
                 or (p_statement_type = 'VPD')))then
           FND_MESSAGE.SET_NAME('FND', 'GENERIC-INTERNAL ERROR');
           FND_MESSAGE.SET_TOKEN('ROUTINE',
             'FND_DATA_SECURITY.GET_SECURITY_PREDICATE');
           FND_MESSAGE.SET_TOKEN('REASON',
            'The predicate was longer than the database VPD limit of '||
            to_char(c_vpd_buf_limit)||' bytes for the predicate.  ');
            x_return_status := 'L'; /* Indicate Error */
        end if;

        /* For VPD, null predicate is logically equivalent to and performs */
        /* similarly to (1=1) so return that. */
        if (    (x_predicate = '(1=1)')
            AND (   (p_statement_type = 'BASE') /* deprecated, same as VPD*/
                 or (p_statement_type = 'VPD'))) then
           x_predicate := NULL;
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
        WHEN OTHERS THEN
            x_return_status := 'U';
            return;
  END get_security_predicate_intrnl;


-- abedajna: same as the one in fnd_data_security, except that it
-- calls my own get_security_predicate_internal.

  PROCEDURE get_security_predicate(
    p_api_version      IN  NUMBER,
    p_function         IN  VARCHAR2,
    p_object_name      IN  VARCHAR2,
    p_grant_instance_type  IN  VARCHAR2,/* SET, INSTANCE*/
    p_user_name        IN  VARCHAR2,
    /* stmnt_type: 'OTHER', 'VPD'=VPD, 'EXISTS'= for checking existence. */
    p_statement_type   IN  VARCHAR2,
    x_predicate        out NOCOPY varchar2,
    x_return_status    out NOCOPY varchar2,
    p_table_alias      IN  VARCHAR2 DEFAULT NULL
  )  IS
    l_api_name   CONSTANT VARCHAR2(30)  := 'GET_SECURITY_PREDICATE';
    l_api_version           CONSTANT NUMBER := 1.0;
    x_function_id  NUMBER;
    x_object_id    NUMBER;
    x_bind_order   varchar2(256);
    BEGIN

       -- check for call compatibility.
       if TRUNC(l_api_version) <> TRUNC(p_api_version) THEN
               x_return_status := 'U'; /* Unexpected Error */
               return;
       END IF;

       get_security_predicate_intrnl(
          p_api_version, p_function, p_object_name, p_grant_instance_type,
          p_user_name, p_statement_type, p_table_alias, 'N',
          x_predicate, x_return_status,
          x_function_id, x_object_id, x_bind_order);

    END;

end AMW_SECURITY_PUB;

/
