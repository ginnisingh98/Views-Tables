--------------------------------------------------------
--  DDL for Package Body EGO_DATA_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_DATA_SECURITY" AS
/* $Header: EGOPFDSB.pls 120.27.12010000.5 2009/08/20 06:08:21 yaoli ship $ */

  G_PKG_NAME       CONSTANT VARCHAR2(30):= 'EGO_DATA_SECURITY';
  G_LOG_HEAD       CONSTANT VARCHAR2(40):= 'fnd.plsql.ego.EGO_DATA_SECURITY.';
  G_TYPE_SET       CONSTANT VARCHAR2(30):= 'SET';
  G_TYPE_INSTANCE  CONSTANT VARCHAR2(30):= 'INSTANCE';
  G_TYPE_UNIVERSAL CONSTANT VARCHAR2(30):= 'UNIVERSAL';

  g_pred_buf_size CONSTANT NUMBER := 32767;
  /* This is the VPD size limit of predicates in the database.  */
  /* In 8.1.7 databases the limit is 4k, and in 8.2 it will be 32k. */
  /* Once we no longer support 8.1.7 then we can increase this to 32,000 */
  g_vpd_buf_limit CONSTANT NUMBER := 4*1024;

  -- Character-set independent NEWLINE, TAB and WHITESPACE
  --
  NEWLINE           CONSTANT VARCHAR2(4) := fnd_global.newline;
  MAX_SEG_SIZE      CONSTANT NUMBER := 200;

  G_RETURN_SUCCESS    CONSTANT VARCHAR2(1) := 'T';
  G_RETURN_FAILURE    CONSTANT VARCHAR2(1) := 'F';
  G_RETURN_UNEXP_ERR  CONSTANT VARCHAR2(1) := 'U';

  G_DEBUG_LEVEL_UNEXPECTED CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
  G_DEBUG_LEVEL_ERROR      CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
  G_DEBUG_LEVEL_EXCEPTION  CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_DEBUG_LEVEL_EVENT      CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
  G_DEBUG_LEVEL_PROCEDURE  CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_DEBUG_LEVEL_STATEMENT  CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;

  G_CURRENT_DEBUG_LEVEL             NUMBER;
  G_USER_NAME                       VARCHAR2(100);

  TYPE DYNAMIC_CUR IS REF CURSOR;

----------------------------------------------------------------------
  ----------------------------------------------
  --This is an internal procedure. Not in spec.
  ----------------------------------------------
  -- For debugging purposes.
  PROCEDURE code_debug (p_log_level  IN NUMBER
                       ,p_module     IN VARCHAR2
                       ,p_message    IN VARCHAR2
                       ) IS
  BEGIN
    IF (p_log_level >= G_CURRENT_DEBUG_LEVEL ) THEN
      fnd_log.string(log_level => p_log_level
                    ,module    => G_LOG_HEAD||p_module
                    ,message   => p_message
                    );
    END IF;
   -- sri_debug(G_PKG_NAME||' - '||p_module||' - '||p_message);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END code_debug;

  ----------------------------------------------
  --This is an internal procedure. Not in spec.
  ----------------------------------------------
  PROCEDURE SetGlobals IS
  BEGIN
    G_CURRENT_DEBUG_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    G_USER_NAME           := FND_GLOBAL.USER_NAME;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END SetGlobals;

  ----------------------------------------------
  --This is an internal procedure. Not in spec.
  ----------------------------------------------
  FUNCTION get_group_info (p_party_id IN NUMBER) RETURN VARCHAR2 IS

   CURSOR group_membership_c (cp_orig_system_id IN NUMBER) IS
    SELECT 'HZ_GROUP:'||group_membership_rel.object_id group_name
      FROM hz_relationships group_membership_rel
     WHERE group_membership_rel.RELATIONSHIP_CODE  = 'MEMBER_OF'
       AND group_membership_rel.status= 'A'
       AND group_membership_rel.start_date <= SYSDATE
       AND NVL(group_membership_rel.end_date, SYSDATE) >= SYSDATE
       AND group_membership_rel.subject_id = cp_orig_system_id;
    l_group_info VARCHAR2(32767);
  BEGIN
    l_group_info := '';
    FOR group_rec IN group_membership_c (p_party_id) LOOP
      l_group_info  :=  l_group_info ||''''||group_rec.group_name ||''' , ';
    END LOOP;

    IF( length( l_group_info ) >0) THEN
      -- strip off the trailing ', '
      l_group_info := SUBSTR(l_group_info, 1,
                       length(l_group_info) - length(', '));
    ELSE
      l_group_info := '''NULL''';
    END IF;
    RETURN l_group_info;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN '''NULL''';
  END get_group_info;

  ----------------------------------------------
  --This is an internal procedure. Not in spec.
  ----------------------------------------------

  FUNCTION get_company_info (p_party_id IN NUMBER) RETURN VARCHAR2 IS
   CURSOR company_membership_c (cp_orig_system_id IN NUMBER) IS
    SELECT 'HZ_COMPANY:'||group_membership_rel.object_id company_name
      FROM hz_relationships group_membership_rel
     WHERE group_membership_rel.RELATIONSHIP_CODE  = 'EMPLOYEE_OF'
       AND group_membership_rel.status= 'A'
       AND group_membership_rel.start_date <= SYSDATE
       AND NVL(group_membership_rel.end_date, SYSDATE) >= SYSDATE
       AND group_membership_rel.subject_id = cp_orig_system_id;
    l_company_info VARCHAR2(32767);
  BEGIN
    l_company_info := '';
    FOR company_rec IN company_membership_c (p_party_id) LOOP
      l_company_info:=l_company_info||''''||company_rec.company_name||''' , ';
    END LOOP;

    IF( length( l_company_info ) >0) THEN
      -- strip off the trailing ', '
      l_company_info := SUBSTR(l_company_info, 1,
                        length(l_company_info) - length(', '));
    ELSE
      l_company_info := '''NULL''';
    END IF;
    RETURN l_company_info;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN '''NULL''';
  END get_company_info;

  ----------------------------------------------
  --This is an internal procedure. Not in spec.
  ----------------------------------------------

  FUNCTION  getRole_mappedTo_profileOption(p_object_name  IN VARCHAR2,
                                           p_user_name    IN VARCHAR2)
  RETURN VARCHAR2
    IS
  l_role_name                 VARCHAR2(99) := '';
  l_party_id                  NUMBER;
  l_colon                     NUMBER;
  l_count                     NUMBER;
  l_ego_item_profile_option   VARCHAR2(99) := 'EGO_INTERNAL_USER_DEFAULT_ROLE';
  l_eng_change_profile_option VARCHAR2(99) := 'ENG_INTERNAL_USER_DEFAULT_ROLE';

  BEGIN

    l_colon := instr(p_user_name, ':');
    IF (l_colon <> 0) THEN
      l_party_id  :=  to_number(substr(p_user_name, l_colon+1));
    ELSE
      l_party_id  := NULL;
    END IF;

    -- check in ego_internal_people_v if the user exists.
    -- This tells if he is an internal user.
    -- If not we do not check the internal option at all
    -- We may need to go against the table rather than the view
    -- to improve performance.

    --PERF:Bug NO:6531906 --changed the query to look into the base tables instead of the View.
	--Bug NO: 8818999 - Enable the HZ_PARTIES object for supplier data hub security
    IF p_object_name IN ('EGO_ITEM','ENG_CHANGE','HZ_PARTIES') THEN
      IF l_party_id IS NULL THEN
         SELECT  count(1) into l_count
         FROM    hz_parties employee,
                 FND_USER FND_user,
                 PER_ALL_PEOPLE_F HR_EMPLOYEE
        WHERE   HR_EMPLOYEE.PERSON_ID              = FND_user.EMPLOYEE_ID
        AND fnd_user.start_date               <= SYSDATE
        AND NVL(fnd_user.end_date, SYSDATE)   >= SYSDATE
        AND (HR_EMPLOYEE.CURRENT_EMPLOYEE_FLAG = 'Y'
        OR HR_EMPLOYEE.CURRENT_NPW_FLAG       = 'Y'
           )
        AND HR_EMPLOYEE.EFFECTIVE_START_DATE            <= SYSDATE
        AND NVL(HR_EMPLOYEE.EFFECTIVE_END_DATE,SYSDATE) >= SYSDATE
        AND employee.party_type                          = 'PERSON'
        AND employee.status                              = 'A'
        AND employee.party_id                            = HR_EMPLOYEE.PARTY_ID
        AND user_name = p_user_name;
      ELSE
        SELECT  Count(1) into l_count
        FROM    hz_parties employee            ,
                FND_USER FND_user              ,
               PER_ALL_PEOPLE_F HR_EMPLOYEE
        WHERE   HR_EMPLOYEE.PERSON_ID              = FND_user.EMPLOYEE_ID
        AND fnd_user.start_date               <= SYSDATE
        AND NVL(fnd_user.end_date, SYSDATE)   >= SYSDATE
        AND (HR_EMPLOYEE.CURRENT_EMPLOYEE_FLAG = 'Y'
        OR HR_EMPLOYEE.CURRENT_NPW_FLAG       = 'Y')
        AND HR_EMPLOYEE.EFFECTIVE_START_DATE            <= SYSDATE
        AND NVL(HR_EMPLOYEE.EFFECTIVE_END_DATE,SYSDATE) >= SYSDATE
        AND employee.party_type                          = 'PERSON'
        AND employee.status                              = 'A'
        AND employee.party_id                            = HR_EMPLOYEE.PARTY_ID
        AND employee.party_id = l_party_id;
      END IF;
      IF (l_count  = 0) THEN
        l_role_name := '';
      ELSE
       IF (p_object_name = 'EGO_ITEM') THEN
         l_role_name := FND_PROFILE.VALUE(l_ego_item_profile_option);
       ELSIF (p_object_name = 'ENG_CHANGE') THEN
         l_role_name := FND_PROFILE.VALUE(l_eng_change_profile_option);
	   ELSIF (p_object_name = 'HZ_PARTIES') THEN
	     l_role_name := FND_PROFILE.VALUE('POS_SM_DEFAULT_ROLE_INTERNAL');
       END IF;
      END IF;   --l_count  = 0
    END IF;
    RETURN l_role_name;

  END getRole_mappedTo_profileOption;

  ----------------------------------------------
  --This is an internal procedure. Not in spec.
  ----------------------------------------------

  PROCEDURE getPrivilege_for_profileOption
               (p_api_version          IN NUMBER,
                p_object_name          IN VARCHAR2,
                p_user_name            IN VARCHAR2,
                x_privilege_tbl        OUT NOCOPY EGO_VARCHAR_TBL_TYPE,
                x_return_status        OUT NOCOPY VARCHAR2
                )
    IS
    l_role_name    VARCHAR2(30);
  BEGIN

    l_role_name := getRole_mappedTo_profileOption(p_object_name, p_user_name);
    -- Now we need to find all the privileges in this role
    -- add it to the out table
    get_role_functions
         (p_api_version     => p_api_version
         ,p_role_name       => l_role_name
         ,x_return_status   => x_return_status
         ,x_privilege_tbl   => x_privilege_tbl
         );

  END getPrivilege_for_profileOption;

  ----------------------------------------------
  --This is an internal procedure. Not in spec.
  ----------------------------------------------
  PROCEDURE translate_pk_values (p_instance_pk2_value  IN VARCHAR2
                                ,p_instance_pk3_value  IN VARCHAR2
                                ,p_instance_pk4_value  IN VARCHAR2
                                ,p_instance_pk5_value  IN VARCHAR2
                                ,x_trans_pk2_value    OUT NOCOPY VARCHAR2
                                ,x_trans_pk3_value    OUT NOCOPY VARCHAR2
                                ,x_trans_pk4_value    OUT NOCOPY VARCHAR2
                                ,x_trans_pk5_value    OUT NOCOPY VARCHAR2
                                ) IS
  BEGIN
    IF p_instance_pk2_value IS NULL THEN
      x_trans_pk2_value := '*NULL*';
    ELSE
      x_trans_pk2_value := p_instance_pk2_value;
    END IF;
    IF p_instance_pk3_value IS NULL THEN
      x_trans_pk3_value := '*NULL*';
    ELSE
      x_trans_pk3_value := p_instance_pk3_value;
    END IF;
    IF p_instance_pk4_value IS NULL THEN
      x_trans_pk4_value := '*NULL*';
    ELSE
      x_trans_pk4_value := p_instance_pk4_value;
    END IF;
    IF p_instance_pk5_value IS NULL THEN
      x_trans_pk5_value := '*NULL*';
    ELSE
      x_trans_pk5_value := p_instance_pk5_value;
    END IF;
  END;

 -----------------------------------------------
 -- This is an internal procedure. Not in spec.
 -----------------------------------------------
 --   Gets the orig_system_id and orig_system from wf_roles,
 --   given the user_name.  These can be used as keys for selects
 --   against WF_USER_ROLES so it hits the index (user_name alone won't).
 --   Eventually a routine to do this, more performant than
 --   wf_directory.getRoleOrigSysInfo, should become part of the workflow
 --   system and then we can replace this with a callout to that routine.
 -----------------------------------------------
PROCEDURE get_orig_key (x_user_name      IN OUT NOCOPY VARCHAR2,
--                       x_orig_system       OUT NOCOPY VARCHAR2,
                       x_orig_system_id    OUT NOCOPY NUMBER)
is
   l_api_name             CONSTANT VARCHAR2(30) := 'GET_ORIG_KEY';
   colon pls_integer;
begin

--   x_orig_system := NULL;
   x_orig_system_id := NULL;

   if x_user_name IS NULL THEN
     x_user_name := G_USER_NAME;
   end if;
   colon := instr(x_user_name, ':');
   if (colon = 0) then
      begin
/***
         -- Get the key from wf_roles.  Note that if the wf_roles view
         -- gets more parts that don't have colons in the user, those will
         -- have to be added to this SQL stmnt.
         select WR.orig_system, WR.orig_system_id
         into x_orig_system, x_orig_system_id
         from WF_ROLES WR
         where WR.NAME = x_user_name
         and   WR.ORIG_SYSTEM IN ('PER', 'FND_USR');
         x_user_name := 'HZ_PARTY:'||x_orig_system_id;
***/
        SELECT party_id
        INTO x_orig_system_id
        FROM ego_user_v
        where user_name = x_user_name;
      exception
         when no_data_found then
         if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
             g_log_head || l_api_name || '.end_nodatafound',
             'returning NULLs.');
         end if;
           return;
      end;
   else
--      x_orig_system  := substr(x_user_name, 1, colon-1);
      x_orig_system_id := to_number(substr(x_user_name, colon+1));
   end if;

end get_orig_key;


 -----------------------------------------------
 -- This is an internal procedure. Not in spec.
 -----------------------------------------------
 --   Out is a string that is a SQL call that returns the value passed in
 --   (in varchar format), in the data type specified.
 --   That description probably doesn't make much sense, so just look
 --   at the code and you'll get what it does.
 -----------------------------------------------
FUNCTION get_conv_from_char(p_instance_value in VARCHAR2,
                            p_col_type       IN VARCHAR2)
RETURN VARCHAR2 IS
BEGIN
   if(p_col_type = 'NUMBER' OR p_col_type = 'INTEGER') then
      return 'FND_NUMBER.CANONICAL_TO_NUMBER('||p_instance_value||')';
   elsif(p_col_type = 'DATE') then
      return 'FND_DATE.CANONICAL_TO_DATE('||p_instance_value||')';
   else
      return p_instance_value;
   end if;
END;

  ----------------------------------------------
  --This is an internal procedure. Not in spec.
  ----------------------------------------------
Function get_object_id(p_object_name in varchar2) return number is
  l_object_id number;
Begin
   select object_id
   into l_object_id
   from fnd_objects
   where obj_name=p_object_name;
   return l_object_id;
exception
   when no_data_found then
     return null;
end get_object_id;

  ----------------------------------------------
  --This is an internal procedure. Not in spec.
  ----------------------------------------------
Function get_role_id(p_role_name in varchar2) return number is
  l_role_id number;
Begin
select menu_id
  into l_role_id
  from fnd_menus
 where menu_name = p_role_name;
 RETURN l_role_id;
EXCEPTION
   when no_data_found then
     RETURN NULL;
end get_role_id;

 -----------------------------------------------
 -- This is an internal procedure. Not in spec.
 -----------------------------------------------
 -- Procedure get_pk_information
 --   x_aliased_pk_column returns the aliased list of columns without
 --      type conv.
 --   x_aliased_ik_column returns 'INSTANCE_PK1_VALUE' etc with type
 --      conversion from char type, with to_number() to_date() etc.
 --   x_orig_pk_column returns the unaliased list of columns
 --      without type conv.
 --  returns 'T' for success or 'U' for unexpected error.
 -----------------------------------------------
function get_pk_information(p_object_name        IN VARCHAR2,
                            x_pk1_column_name   OUT NOCOPY VARCHAR2,
                            x_pk2_column_name   OUT NOCOPY VARCHAR2,
                            x_pk3_column_name   OUT NOCOPY VARCHAR2,
                            x_pk4_column_name   OUT NOCOPY VARCHAR2,
                            x_pk5_column_name   OUT NOCOPY VARCHAR2,
                            x_aliased_pk_column OUT NOCOPY VARCHAR2,
                            x_aliased_ik_column OUT NOCOPY VARCHAR2,
                            x_orig_pk_column    OUT NOCOPY VARCHAR2,
                            x_database_object_name OUT NOCOPY VARCHAR2,
                            p_pk1_alias       IN  VARCHAR2 DEFAULT NULL,
                            p_pk2_alias       IN  VARCHAR2 DEFAULT NULL,
                            p_pk3_alias       IN  VARCHAR2 DEFAULT NULL,
                            p_pk4_alias       IN  VARCHAR2 DEFAULT NULL,
                            p_pk5_alias       IN  VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2 IS
  l_api_name             CONSTANT VARCHAR2(30) := 'GET_PK_INFORMATION';
  x_pk1_column_type varchar2(8);
  x_pk2_column_type varchar2(8);
  x_pk3_column_type varchar2(8);
  x_pk4_column_type varchar2(8);
  x_pk5_column_type varchar2(8);
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
    WHERE obj_name=p_object_name ;
begin
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
                            g_pkg_name || '.'|| l_api_name);
     fnd_message.set_token('REASON',
                'FND_OBJECTS does not have column obj_name with value:'||
                 p_object_name);
     return G_RETURN_UNEXP_ERR;
   end if;

   CLOSE c_pk;

   -- Build up the list of unaliased column names
   x_orig_pk_column := NULL;
   if(x_pk1_column_name is not NULL) then
      x_orig_pk_column := x_orig_pk_column || x_pk1_column_name;
   end if;
   if(x_pk2_column_name is not NULL) then
      x_orig_pk_column := x_orig_pk_column || ',' || x_pk2_column_name;
   end if;
   if(x_pk3_column_name is not NULL) then
      x_orig_pk_column := x_orig_pk_column || ',' || x_pk3_column_name;
   end if;
   if(x_pk4_column_name is not NULL) then
      x_orig_pk_column := x_orig_pk_column || ',' || x_pk4_column_name;
   end if;
   if(x_pk5_column_name is not NULL) then
      x_orig_pk_column := x_orig_pk_column || ',' || x_pk5_column_name;
   end if;


   -- Replace column names with aliases if aliases were passed.
   if(x_pk1_column_name is not NULL) and (p_pk1_alias is not NULL) then
      x_pk1_column_name := p_pk1_alias;
   end if;
   if(x_pk2_column_name is not NULL) and (p_pk2_alias is not NULL) then
      x_pk2_column_name := p_pk2_alias;
   end if;
   if(x_pk3_column_name is not NULL) and (p_pk3_alias is not NULL) then
      x_pk3_column_name := p_pk3_alias;
   end if;
   if(x_pk4_column_name is not NULL) and (p_pk4_alias is not NULL) then
      x_pk4_column_name := p_pk4_alias;
   end if;
   if(x_pk5_column_name is not NULL) and (p_pk5_alias is not NULL) then
      x_pk5_column_name := p_pk5_alias;
   end if;

   -- Build up the x_aliased_pk_column and x_aliased_ik_column lists
   -- by adding values for each column name.
   x_aliased_pk_column:=x_pk1_column_name;

   x_aliased_ik_column := get_conv_from_char(
                            'INSTANCE_PK1_VALUE', x_pk1_column_type);

   if x_pk2_COLUMN_name is not null then
      x_aliased_pk_column:=
         x_aliased_pk_column||','||x_pk2_COLUMN_name;
      x_aliased_ik_column := x_aliased_ik_column||','||get_conv_from_char(
                            'INSTANCE_PK2_VALUE', x_pk2_column_type);

      if x_pk3_COLUMN_name is not null then
         x_aliased_pk_column :=
            x_aliased_pk_column||','||x_pk3_COLUMN_name;
         x_aliased_ik_column := x_aliased_ik_column||','||get_conv_from_char(
                            'INSTANCE_PK3_VALUE', x_pk3_column_type);

         if x_pk4_COLUMN_name is not null then
            x_aliased_pk_column:=
               x_aliased_pk_column||','||x_pk4_COLUMN_name;
            x_aliased_ik_column := x_aliased_ik_column||','||
                           get_conv_from_char(
                            'INSTANCE_PK4_VALUE', x_pk4_column_type);

            if x_pk5_COLUMN_name is not null then
               x_aliased_pk_column:=
                  x_aliased_pk_column||','||x_pk5_COLUMN_name;
               x_aliased_ik_column := x_aliased_ik_column||','||
                  get_conv_from_char('INSTANCE_PK5_VALUE', x_pk5_column_type);
            end if;
         end if;
      end if;
   end if;

   code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
              ,p_module    => l_api_name
              ,p_message   => 'Returning PK information as ' ||
                              'p_object_name: '|| p_object_name ||
                              ' - x_pk1_column_name: '|| x_pk1_column_name ||
                              ' - x_pk2_column_name: '|| x_pk2_column_name ||
                              ' - x_pk3_column_name: '|| x_pk3_column_name ||
                              ' - x_pk4_column_name: '|| x_pk4_column_name ||
                              ' - x_pk5_column_name: '|| x_pk5_column_name ||
                              ' - x_aliased_pk_column: '|| x_aliased_pk_column ||
                              ' - x_aliased_ik_column: '|| x_aliased_ik_column ||
                              ' - x_database_object_name:  '|| x_database_object_name
               );
   return G_RETURN_SUCCESS;
end get_pk_information;
--Bug 5027160 :START
  ----------------------------------------------
  --This is an internal procedure. Not in spec.
  ----------------------------------------------
  --This will return either T or F depending on
  --whethe the user has privilege or not
  ----------------------------------------------
FUNCTION process_set_ids(
             p_db_pk1_column            IN VARCHAR2,
             p_db_pk2_column            IN VARCHAR2,
             p_db_pk3_column            IN VARCHAR2,
             p_db_pk4_column            IN VARCHAR2,
             p_db_pk5_column            IN VARCHAR2,
             p_instance_pk1_value       IN  VARCHAR2,
             p_instance_pk2_value       IN  VARCHAR2 DEFAULT NULL,
             p_instance_pk3_value       IN  VARCHAR2 DEFAULT NULL,
             p_instance_pk4_value       IN  VARCHAR2 DEFAULT NULL,
             p_instance_pk5_value       IN  VARCHAR2 DEFAULT NULL,
             p_dynamic_sql              IN VARCHAR2,
             p_instance_predicate_list  IN VARCHAR2
           ) RETURN VARCHAR2 IS
    l_api_name        CONSTANT VARCHAR2(30) := 'PROCESS_SET_IDS';
    instance_set               DYNAMIC_CUR;
    l_instance_id_col1         VARCHAR2(512);
    l_instance_id_col2         VARCHAR2(512);
    l_instance_id_col3         VARCHAR2(512);
    l_instance_id_col4         VARCHAR2(512);
    l_instance_id_col5         VARCHAR2(512);
    l_dynamic_sql              VARCHAR2(32767);
    l_instance_predicate_list  VARCHAR2(32767);
    l_inst_pred_length         NUMBER;

BEGIN
  l_instance_predicate_list := p_instance_predicate_list;
  -- if the last word  is 'OR' then strip the trailing 'OR'
  l_inst_pred_length := LENGTH(l_instance_predicate_list);
  IF l_inst_pred_length <= 1 THEN
    RETURN G_RETURN_FAILURE;
  ELSE
    l_instance_predicate_list := SUBSTR(l_instance_predicate_list, 1,
                          l_inst_pred_length - length('OR ('));
  END IF;
  l_dynamic_sql := p_dynamic_sql ||'('||l_instance_predicate_list||')';
  if(p_db_pk5_column is not NULL) THEN
     OPEN instance_set FOR l_dynamic_sql USING
        p_instance_pk1_value, p_instance_pk1_value,
        p_instance_pk2_value, p_instance_pk2_value,
        p_instance_pk3_value, p_instance_pk3_value,
        p_instance_pk4_value, p_instance_pk4_value,
        p_instance_pk5_value, p_instance_pk5_value;
      FETCH instance_set INTO l_instance_id_col1, l_instance_id_col2,
                            l_instance_id_col3, l_instance_id_col4,
                            l_instance_id_col5;
      CLOSE instance_set;
      IF (l_instance_id_col1 = p_instance_pk1_value
          and l_instance_id_col2 = p_instance_pk2_value
          and l_instance_id_col3 = p_instance_pk3_value
          and l_instance_id_col4 = p_instance_pk4_value
          and l_instance_id_col5 = p_instance_pk5_value) THEN
       RETURN G_RETURN_SUCCESS;
      ELSE
        RETURN G_RETURN_FAILURE;
      END IF;
  elsif(p_db_pk4_column is not NULL) then
     OPEN instance_set FOR l_dynamic_sql USING
        p_instance_pk1_value, p_instance_pk1_value,
        p_instance_pk2_value, p_instance_pk2_value,
        p_instance_pk3_value, p_instance_pk3_value,
        p_instance_pk4_value, p_instance_pk4_value;
      FETCH instance_set into l_instance_id_col1,
                            l_instance_id_col2,
                            l_instance_id_col3,
                            l_instance_id_col4;
      CLOSE instance_set;
      IF (l_instance_id_col1 = p_instance_pk1_value
          and l_instance_id_col2 = p_instance_pk2_value
          and l_instance_id_col3 = p_instance_pk3_value
          and l_instance_id_col4 = p_instance_pk4_value) THEN
        RETURN G_RETURN_SUCCESS;
      ELSE
        RETURN G_RETURN_FAILURE;
      END IF;
  elsif(p_db_pk3_column is not NULL) then
     OPEN instance_set FOR l_dynamic_sql USING
        p_instance_pk1_value, p_instance_pk1_value,
        p_instance_pk2_value, p_instance_pk2_value,
        p_instance_pk3_value, p_instance_pk3_value;
      FETCH instance_set INTO l_instance_id_col1,
                            l_instance_id_col2,
                            l_instance_id_col3;
      CLOSE instance_set;
      IF (l_instance_id_col1 = p_instance_pk1_value
             and l_instance_id_col2 = p_instance_pk2_value
             and l_instance_id_col3 = p_instance_pk3_value) THEN
        RETURN G_RETURN_SUCCESS;
      ELSE
        RETURN G_RETURN_FAILURE;
      END IF;
  elsif(p_db_pk2_column is not NULL) then
     OPEN instance_set FOR l_dynamic_sql USING
        p_instance_pk1_value, p_instance_pk1_value,
        p_instance_pk2_value, p_instance_pk2_value;
      FETCH instance_set INTO l_instance_id_col1, l_instance_id_col2;
      CLOSE instance_set;
      IF (l_instance_id_col1 = p_instance_pk1_value
          and l_instance_id_col2 = p_instance_pk2_value) THEN
       RETURN G_RETURN_SUCCESS;
      ELSE
        RETURN G_RETURN_FAILURE;
      END IF;
  elsif(p_db_pk1_column is not NULL) then
     OPEN instance_set FOR l_dynamic_sql USING
        p_instance_pk1_value, p_instance_pk1_value;
      FETCH instance_set INTO l_instance_id_col1;
      CLOSE instance_set;
      IF (l_instance_id_col1 = p_instance_pk1_value) THEN
        RETURN G_RETURN_SUCCESS;
      ELSE
        RETURN G_RETURN_FAILURE;
      END IF;
  else
     RETURN G_RETURN_UNEXP_ERR; /* This will never happen since pk1 is reqd*/
  end if;
EXCEPTION
  WHEN OTHERS THEN
    return G_RETURN_UNEXP_ERR;
END process_set_ids;
--------------------------------------------------------------------------
--Bug 5027160 :END

--------------------------------------------------------
----    check_function
--------------------------------------------------------
FUNCTION check_function
  (
   p_api_version                 IN  NUMBER,
   p_function                    IN  VARCHAR2,
   p_object_name                 IN  VARCHAR2,
   p_instance_pk1_value          IN  VARCHAR2,
   p_instance_pk2_value          IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk3_value          IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk4_value          IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk5_value          IN  VARCHAR2 DEFAULT NULL,
   p_user_name                   IN  VARCHAR2 DEFAULT NULL
 )
 RETURN VARCHAR2 IS

    l_api_version     CONSTANT NUMBER := 1.0;
    l_api_name        CONSTANT VARCHAR2(30) := 'CHECK_FUNCTION';
--    l_orig_system              VARCHAR2(48);
    l_orig_system_id           NUMBER;
    l_db_object_name           VARCHAR2(99);
    l_db_pk1_column            VARCHAR2(99);
    l_db_pk2_column            VARCHAR2(99);
    l_db_pk3_column            VARCHAR2(99);
    l_db_pk4_column            VARCHAR2(99);
    l_db_pk5_column            VARCHAR2(99);
    l_pk_column_names          VARCHAR2(512);
    l_pk_orig_column_names     VARCHAR2(512);
    l_type_converted_val_cols  VARCHAR2(512);
    l_result                   VARCHAR2(1);
    l_return_status            VARCHAR2(1);
    l_group_info               VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_company_info             VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_menu_info                VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_object_id                NUMBER;
    l_user_name                VARCHAR2(80);
    l_prof_privilege_tbl       EGO_VARCHAR_TBL_TYPE;

    candidate_sets_c           DYNAMIC_CUR;
    instance_set               DYNAMIC_CUR;
    l_dynamic_sql_1            VARCHAR2(32767);
    l_dynamic_sql              VARCHAR2(32767);
    l_select_query_part        VARCHAR2(3000);
    l_one_set_predicate        VARCHAR2(32767);
    l_one_set_id               NUMBER;
    --bug 5027160.
    l_instance_predicate_list  VARCHAR2(10000);
    l_has_priv                 VARCHAR2(1);
    l_set_id_cnt               NUMBER;

    CURSOR menu_functions_c (cp_function_name IN  VARCHAR2) IS
    SELECT menu_id
      FROM fnd_menu_entries
     WHERE function_id =
            (SELECT function_id
             FROM fnd_form_functions
             WHERE function_name = cp_function_name
            );

--********************************************** 8673870 *********************************
    l_return_success  CONSTANT VARCHAR2(1) := 'T';
    l_return_failure  CONSTANT VARCHAR2(1) := 'F';
    l_in_params_rec    EGO_CUSTOM_SECURITY_PUB.in_params_rec_type;
    l_out_params_rec   EGO_CUSTOM_SECURITY_PUB.out_params_rec_type;
    -- for standard API parameter
    -- l_return_status            VARCHAR2(1); --already exist above
    l_msg_count NUMBER;
    l_msg_data  VARCHAR(100);
--********************************************** 8673870 *********************************



  BEGIN
    SetGlobals();
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   =>  'Started with 9 params '||
                   ' p_api_version: '|| to_char(p_api_version) ||
                   ' - p_function: '|| p_function ||
                   ' - p_object_name: '|| p_object_name ||
                   ' - p_instance_pk1_value: '|| p_instance_pk1_value ||
                   ' - p_instance_pk2_value: '|| p_instance_pk2_value ||
                   ' - p_instance_pk3_value: '|| p_instance_pk3_value ||
                   ' - p_instance_pk4_value: '|| p_instance_pk4_value ||
                   ' - p_instance_pk5_value: '|| p_instance_pk5_value ||
                   ' - p_user_name: '|| p_user_name
               );

    if TRUNC(l_api_version) <> TRUNC(p_api_version) THEN
      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE',
                            g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON',
                            'Unsupported version '|| to_char(p_api_version)||
                            ' passed to API; expecting version '||
                            to_char(l_api_version));
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning as the call in incompatible '
                 );
      return G_RETURN_UNEXP_ERR;
    end if;
    l_user_name := p_user_name;

--********************************************** 8673870 *********************************
    l_in_params_rec.user_name := p_user_name;
    l_in_params_rec.object_name := p_object_name;
    l_in_params_rec.instance_pk1_value := p_instance_pk1_value;
    l_in_params_rec.instance_pk2_value := p_instance_pk2_value;
    l_in_params_rec.instance_pk3_value := p_instance_pk3_value;
    l_in_params_rec.instance_pk4_value := p_instance_pk4_value;
    l_in_params_rec.instance_pk5_value := p_instance_pk5_value;
    l_in_params_rec.function_name := p_function;

    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   => 'Calling EGO_CUSTOM_SECURITY_PUB.check_custom_security with params'||
               ' l_in_params_rec.user_name = '|| l_in_params_rec.user_name ||
               ' l_in_params_rec.object_name = '|| l_in_params_rec.object_name ||
               ' l_in_params_rec.instance_pk1_value = '|| l_in_params_rec.instance_pk1_value ||
               ' l_in_params_rec.instance_pk2_value = '|| l_in_params_rec.instance_pk2_value ||
               ' l_in_params_rec.instance_pk3_value = '|| l_in_params_rec.instance_pk3_value ||
               ' l_in_params_rec.instance_pk4_value = '|| l_in_params_rec.instance_pk4_value ||
               ' l_in_params_rec.instance_pk5_value = '|| l_in_params_rec.instance_pk5_value ||
               ' l_in_params_rec.function_name = '|| l_in_params_rec.function_name
               );

    EGO_CUSTOM_SECURITY_PUB.check_custom_security(
                 p_in_params_rec => l_in_params_rec
                ,x_out_params_rec => l_out_params_rec

                --standard parameters
                ,p_api_version => 1.0
                ,x_return_status => l_return_status
                ,x_msg_count => l_msg_count
                ,x_msg_data => l_msg_data
    );

    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   => 'Returned from EGO_CUSTOM_SECURITY_PUB.check_custom_security ' ||
               ' with return_status: '|| l_return_status ||
               ' l_out_params_rec.user_has_function: '|| l_out_params_rec.user_has_function
               );

    IF l_out_params_rec.user_has_function = 'T' THEN
        RETURN l_return_success;
    ELSIF l_out_params_rec.user_has_function = 'F' THEN
        RETURN l_return_failure;
    END IF;

--********************************************** 8673870 *********************************


    get_orig_key(x_user_name      => l_user_name
--                ,x_orig_system    => l_orig_system
                ,x_orig_system_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_user_name: '||l_user_name||
--                               ' - l_orig_system: '||l_orig_system||
                               ' - l_orig_system_id: '||l_orig_system_id
               );
    ------------------------------------------------------------------
    --First we see if a profile option is set and if function exists--
    -- if so we return it here itself without doing further query   --
    -------------------------------------------------------------------
    getPrivilege_for_profileOption(p_api_version     => p_api_version,
                                   p_object_name     => p_object_name,
                                   p_user_name       => l_user_name,
                                   x_privilege_tbl   => l_prof_privilege_tbl,
                                   x_return_status   => l_return_status);

    IF (l_return_status = G_RETURN_SUCCESS) THEN
      IF (l_prof_privilege_tbl.COUNT > 0) THEN
        FOR i IN l_prof_privilege_tbl.first .. l_prof_privilege_tbl.last LOOP
          IF (l_prof_privilege_tbl(i) = p_function) THEN
            code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                       ,p_module    => l_api_name
                       ,p_message   => 'Returning TRUE as privilege is obtained from profile '
                       );
             RETURN G_RETURN_SUCCESS;
          END IF; --if function match, returning T
        END LOOP;
      END IF; -- x_prof_privilege_tbl >0
    END IF; --return status is T

    ------------------------------------------------------------------
    --end of check in profile option --
    -------------------------------------------------------------------
    -- get All privileges of a user on a given object
    -- Step 1.
    -- get database object name and column
    -- cache the PK column name
    l_return_status := get_pk_information(p_object_name  ,
                       l_db_pk1_column  ,
                       l_db_pk2_column  ,
                       l_db_pk3_column  ,
                       l_db_pk4_column  ,
                       l_db_pk5_column  ,
                       l_pk_column_names  ,
                       l_type_converted_val_cols  ,
                       l_pk_orig_column_names,
                       l_db_object_name );
    IF (l_return_status <> G_RETURN_SUCCESS) THEN
      /* There will be a message on the msg dict stack. */
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning FALSE as pk values are not correct'
                  );
      return l_return_status;  /* We will return the x_return_status as out param */
    end if;

    l_object_id:=get_object_id(p_object_name => p_object_name );
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_object_id: '||l_object_id
               );
    -- step 1.1
    -- pre-fetch company/group/menu info
    l_menu_info := '';
    FOR menu_rec IN menu_functions_c (cp_function_name => p_function) LOOP
      l_menu_info:=l_menu_info||menu_rec.menu_id||', ';
    END LOOP;
    IF( length( l_menu_info ) >0) THEN
      -- strip off the trailing ', '
      l_menu_info := SUBSTR(l_menu_info,1,length(l_menu_info) - length(', '));
    ELSE
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning FALSE as function not associated to any menu'
                  );
      RETURN G_RETURN_FAILURE;
    END IF;
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_menu_info: '||l_menu_info
               );

    l_group_info := get_group_info(p_party_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_group_info: '||l_group_info
               );
    l_company_info := get_company_info (p_party_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_company_info: '||l_company_info
               );

--end_date:= DBMS_UTILITY.GET_TIME;
--millisec:= (end_date-start_date)*24*60*60*1000;
--dbms_output.put_line('2. Diff. in Get Time 100th of a sec ::'||to_char(end_date-start_date,'9999999'));
-- R12C Security Changes
   /* l_dynamic_sql :=
      'SELECT ''X'' ' ||
       ' FROM fnd_grants grants ' ||
      ' WHERE grants.object_id = :object_id ' ||
        ' AND grants.start_date <= SYSDATE '||
        ' AND NVL(grants.end_date, SYSDATE) >= SYSDATE ' ||
        ' AND grants.instance_type = :instance_type ' ||
        ' AND ( ( grants.grantee_type = ''USER'' AND ' ||
               ' grants.grantee_key = :user_name ) '||
               ' OR ( grants.grantee_type = ''GROUP'' AND '||
               ' grants.grantee_key in ( '||l_group_info||' ))' ||
               ' OR ( grants.grantee_type = ''COMPANY'' AND '||
               ' grants.grantee_key in ( '||l_company_info||' ))' ||
               ' OR (grants.grantee_type = ''GLOBAL'' AND '||
               ' grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL'') )) '||
        ' AND grants.menu_id IN (' || l_menu_info ||') ' ||
        ' AND grants.instance_pk1_value = :pk1_val ' ||
        ' AND ( grants.instance_pk2_value = :pk2_val OR' ||
        ' ( grants.instance_pk2_value = ''*NULL*'' AND :pk2_val is NULL )) '||
        ' AND ( grants.instance_pk3_value = :pk3_val OR '||
        ' ( grants.instance_pk3_value = ''*NULL*'' AND :pk3_val is NULL )) '||
        ' AND ( grants.instance_pk4_value = :pk4_val OR '||
        ' ( grants.instance_pk4_value = ''*NULL*'' AND :pk4_val is NULL )) '||
        ' AND ( grants.instance_pk5_value = :pk5_val OR '||
        ' ( grants.instance_pk5_value = ''*NULL*'' AND :pk5_val is NULL )) '; */

  IF (p_object_name = 'EGO_CATALOG_GROUP') THEN
  l_dynamic_sql :=
        'SELECT ''X'' ' ||
        ' FROM fnd_grants grants, ego_item_cat_denorm_hier cathier ' ||
        ' WHERE grants.object_id = :object_id ' ||
        ' AND grants.start_date <= SYSDATE '||
        ' AND NVL(grants.end_date, SYSDATE) >= SYSDATE ' ||
        ' AND grants.instance_type = :instance_type ' ||
        ' AND ( ( grants.grantee_type = ''USER'' AND ' ||
               ' grants.grantee_key = :user_name ) '||
               ' OR ( grants.grantee_type = ''GROUP'' AND '||
               ' grants.grantee_key in ( '||l_group_info||' ))' ||
               ' OR ( grants.grantee_type = ''COMPANY'' AND '||
               ' grants.grantee_key in ( '||l_company_info||' ))' ||
               ' OR (grants.grantee_type = ''GLOBAL'' AND '||
               ' grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL'') )) '||
        ' AND grants.menu_id IN (' || l_menu_info ||') ' ||
        ' AND grants.instance_pk1_value = cathier.parent_catalog_group_id ' ||
        ' AND cathier.child_catalog_group_id = :pk1_val ' ||
        ' AND ( grants.instance_pk2_value = :pk2_val OR' ||
        ' ( grants.instance_pk2_value = ''*NULL*'' AND :pk2_val is NULL )) '||
        ' AND ( grants.instance_pk3_value = :pk3_val OR '||
        ' ( grants.instance_pk3_value = ''*NULL*'' AND :pk3_val is NULL )) '||
        ' AND ( grants.instance_pk4_value = :pk4_val OR '||
        ' ( grants.instance_pk4_value = ''*NULL*'' AND :pk4_val is NULL )) '||
        ' AND ( grants.instance_pk5_value = :pk5_val OR '||
        ' ( grants.instance_pk5_value = ''*NULL*'' AND :pk5_val is NULL )) ';
  ELSE
  l_dynamic_sql :=
        'SELECT ''X'' ' ||
        ' FROM fnd_grants grants ' ||
        ' WHERE grants.object_id = :object_id ' ||
        ' AND grants.start_date <= SYSDATE '||
        ' AND NVL(grants.end_date, SYSDATE) >= SYSDATE ' ||
        ' AND grants.instance_type = :instance_type ' ||
        ' AND ( ( grants.grantee_type = ''USER'' AND ' ||
               ' grants.grantee_key = :user_name ) '||
               ' OR ( grants.grantee_type = ''GROUP'' AND '||
               ' grants.grantee_key in ( '||l_group_info||' ))' ||
               ' OR ( grants.grantee_type = ''COMPANY'' AND '||
               ' grants.grantee_key in ( '||l_company_info||' ))' ||
               ' OR (grants.grantee_type = ''GLOBAL'' AND '||
               ' grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL'') )) '||
        ' AND grants.menu_id IN (' || l_menu_info ||') ' ||
        ' AND grants.instance_pk1_value = :pk1_val ' ||
        ' AND ( grants.instance_pk2_value = :pk2_val OR' ||
        ' ( grants.instance_pk2_value = ''*NULL*'' AND :pk2_val is NULL )) '||
        ' AND ( grants.instance_pk3_value = :pk3_val OR '||
        ' ( grants.instance_pk3_value = ''*NULL*'' AND :pk3_val is NULL )) '||
        ' AND ( grants.instance_pk4_value = :pk4_val OR '||
        ' ( grants.instance_pk4_value = ''*NULL*'' AND :pk4_val is NULL )) '||
        ' AND ( grants.instance_pk5_value = :pk5_val OR '||
        ' ( grants.instance_pk5_value = ''*NULL*'' AND :pk5_val is NULL )) ';
        END IF;
-- R12C Security Changes

      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'Binds for instance_set sql '||
                   ' l_object_id: '||l_object_id||
                   ' - G_TYPE_INSTANCE: '||G_TYPE_INSTANCE||
                   ' - l_user_name: '||l_user_name||
                   ' - p_instance_pk1_value: '|| p_instance_pk1_value ||
                   ' - p_instance_pk2_value: '|| p_instance_pk2_value ||
                   ' - p_instance_pk3_value: '|| p_instance_pk3_value ||
                   ' - p_instance_pk4_value: '|| p_instance_pk4_value ||
                   ' - p_instance_pk5_value: '|| p_instance_pk5_value
                 );

    OPEN instance_set FOR l_dynamic_sql
    USING IN l_object_id,
          IN G_TYPE_INSTANCE,
          IN l_user_name,
          IN p_instance_pk1_value,
          IN p_instance_pk2_value,
          IN p_instance_pk2_value,
          IN p_instance_pk3_value,
          IN p_instance_pk3_value,
          IN p_instance_pk4_value,
          IN p_instance_pk4_value,
          IN p_instance_pk5_value,
          IN p_instance_pk5_value;
    FETCH instance_set  INTO l_result;
    CLOSE instance_set;
    IF (l_result = 'X') THEN
      RETURN G_RETURN_SUCCESS;
    END IF;
    -- Step 2.
    -- get instance set ids in which the given object_key exist
    -- as a set into l_instance_set
    -- R12C Security Changes
    /*l_select_query_part:=
             'SELECT '|| l_pk_column_names ||
             ' FROM  '|| l_db_object_name  ||
             ' WHERE '; */

    IF (p_object_name = 'EGO_ITEM') THEN
  l_select_query_part:=
             'SELECT '|| l_pk_column_names ||
             ' FROM  '|| l_db_object_name  || ', ego_item_cat_denorm_hier cathier'||
             ' WHERE ';
    ELSE
  l_select_query_part:=
             'SELECT '|| l_pk_column_names ||
             ' FROM  '|| l_db_object_name  ||
             ' WHERE ';
    END IF;
    -- R12C Security Changes

    IF (l_db_pk1_column IS NOT NULL) THEN
       l_select_query_part := l_select_query_part ||
            ' ( '||l_db_pk1_column||' = :pk1_val '||
             ' OR ( '||l_db_pk1_column||' is NULL AND :pk1_val is NULL))';
    END IF;
    IF (l_db_pk2_column IS NOT NULL) THEN
       l_select_query_part := l_select_query_part ||
        ' AND (  '||l_db_pk2_column||' = :pk2_val '||
             ' OR ( '||l_db_pk2_column||' is NULL AND :pk2_val is NULL))';
    END IF;
    IF (l_db_pk3_column IS NOT NULL) THEN
       l_select_query_part := l_select_query_part ||
        ' AND ( '||l_db_pk3_column||' = :pk3_val '||
             ' OR ( '||l_db_pk3_column||' is NULL AND :pk3_val is NULL))';
    END IF;
    IF (l_db_pk4_column IS NOT NULL) THEN
       l_select_query_part := l_select_query_part ||
       ' AND ( '||l_db_pk4_column||' = :pk4_val '||
             ' OR ( '||l_db_pk4_column||' is NULL AND :pk4_val is NULL))';
    END IF;
    IF (l_db_pk5_column IS NOT NULL) THEN
       l_select_query_part := l_select_query_part ||
        ' AND ( '||l_db_pk5_column||' = :pk5_val '||
             ' OR ( '||l_db_pk5_column||' is NULL AND :pk5_val is NULL))';
    END IF;

    -- R12C Security Changes
     -- l_select_query_part := l_select_query_part || ' AND ';
     IF (p_object_name = 'EGO_ITEM') THEN
           l_select_query_part := l_select_query_part || ' AND item_catalog_group_id = cathier.child_catalog_group_id AND ';
      ELSE
           l_select_query_part := l_select_query_part || ' AND ';
      END IF;
       -- R12C Security Changes

      l_dynamic_sql := l_select_query_part;
      l_instance_predicate_list := '(';
      l_set_id_cnt  := 0;


--end_date:= DBMS_UTILITY.GET_TIME;
--millisec:= (end_date-start_date)*24*60*60*1000;
--dbms_output.put_line('1. Diff. in Get Time 100th of a sec ::'||to_char(end_date-start_date,'9999999'));
    --bug 5027160.:START

    --
    -- open cursor for candidate sets and find out what all are required
    --
    l_dynamic_sql_1 :=
      ' SELECT DISTINCT sets.instance_SET_ID, sets.predicate ' ||
        ' FROM fnd_grants grants, ' ||
             ' fnd_object_instance_sets  sets '||
       ' WHERE grants.object_id = :object_id ' ||
         ' AND grants.start_date <= SYSDATE ' ||
         ' AND NVL(grants.end_date,SYSDATE) >= SYSDATE '||
         ' AND grants.instance_type = :instance_type ' ||
         ' AND ( ( grants.grantee_type = ''USER'' AND '||
               ' grants.grantee_key = :user_name ) '||
               ' OR ( grants.grantee_type = ''GROUP'' AND '||
               ' grants.grantee_key in ( '||l_group_info||' ))' ||
               ' OR ( grants.grantee_type = ''COMPANY'' AND '||
               ' grants.grantee_key in ( '||l_company_info||' ))' ||
               ' OR (grants.grantee_type = ''GLOBAL'' AND '||
               ' grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL'') )) '||
        ' AND grants.menu_id IN (' || l_menu_info ||') ' ||
        ' AND sets.instance_set_id = grants.instance_set_id ' ||
        ' AND sets.object_id = grants.object_id ';
      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'SQL for candidate_sets_cursor '||l_dynamic_sql_1
                 );
      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'Binds for candidate_sets_cursor '||
                   ' l_object_id: '||l_object_id||
                   ' - G_TYPE_SET: '||G_TYPE_SET||
                   ' - l_user_name: '||l_user_name
                 );

    OPEN candidate_sets_c FOR l_dynamic_sql_1
    USING IN l_object_id,
          IN G_TYPE_SET,
          IN l_user_name;
    LOOP
      FETCH candidate_sets_c INTO l_one_set_id, l_one_set_predicate;
        EXIT WHEN candidate_sets_c%NOTFOUND;
      --incrementing the count so that we can call the API process_set_ids if
      --the count is 10.
      l_set_id_cnt:=l_set_id_cnt+1;
      l_instance_predicate_list :=
            l_instance_predicate_list ||l_one_set_predicate ||') OR (';
      --we are collectig prdicates and trying to process 10 at a time
      --by executing the l_dynamic_sql once for ten predicates, thus reducing
      --the number of times the l_dynamic_sql is executed.
      IF (MOD(l_set_id_cnt,10) = 0) THEN
         l_has_priv := process_set_ids (
              p_db_pk1_column            => l_db_pk1_column,
              p_db_pk2_column            => l_db_pk2_column,
              p_db_pk3_column            => l_db_pk3_column,
              p_db_pk4_column            => l_db_pk4_column,
              p_db_pk5_column            => l_db_pk5_column,
              p_instance_pk1_value       => p_instance_pk1_value,
              p_instance_pk2_value       => p_instance_pk2_value,
              p_instance_pk3_value       => p_instance_pk3_value,
              p_instance_pk4_value       => p_instance_pk4_value,
              p_instance_pk5_value       => p_instance_pk5_value,
              p_dynamic_sql              => l_dynamic_sql,
              p_instance_predicate_list  => l_instance_predicate_list
              );
        --return T if the user has a privilege
        IF l_has_priv = G_RETURN_SUCCESS THEN
          code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                     ,p_module    => l_api_name
                     ,p_message   => 'Returning from set id''s '||l_has_priv
                     );
          RETURN l_has_priv;
        ELSIF l_has_priv = G_RETURN_UNEXP_ERR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSE
          l_instance_predicate_list :='(';
          l_set_id_cnt:=0;
        END IF;
      END IF;--MOD(l_set_id_cnt,10)
    END LOOP;
    CLOSE candidate_sets_c;
    --calling the API process_set_ids for the rest of the set_ids.
    l_has_priv := process_set_ids (
                   p_db_pk1_column            => l_db_pk1_column,
                   p_db_pk2_column            => l_db_pk2_column,
                   p_db_pk3_column            => l_db_pk3_column,
                   p_db_pk4_column            => l_db_pk4_column,
                   p_db_pk5_column            => l_db_pk5_column,
                   p_instance_pk1_value       => p_instance_pk1_value,
                   p_instance_pk2_value       => p_instance_pk2_value,
                   p_instance_pk3_value       => p_instance_pk3_value,
                   p_instance_pk4_value       => p_instance_pk4_value,
                   p_instance_pk5_value       => p_instance_pk5_value,
                   p_dynamic_sql              => l_dynamic_sql,
                   p_instance_predicate_list  => l_instance_predicate_list
                   );
    IF l_has_priv = G_RETURN_UNEXP_ERR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   => 'Returning status '||l_has_priv
                );
    RETURN l_has_priv;
    --bug 5027160.:END
  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      code_debug (p_log_level => G_DEBUG_LEVEL_EXCEPTION
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning EXCEPTION '||SQLERRM
                  );
      RETURN G_RETURN_UNEXP_ERR;
    WHEN OTHERS THEN
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE',G_PKG_NAME||l_api_name);
      fnd_message.set_token('ERRNO', SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      code_debug (p_log_level => G_DEBUG_LEVEL_EXCEPTION
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning EXCEPTION '||SQLERRM
                  );
    RETURN G_RETURN_UNEXP_ERR;
  END check_function;

--------------------------------------------------------
----    check_inherited_function
--------------------------------------------------------
  FUNCTION check_inherited_function
  (
   p_api_version                 IN  NUMBER,
   p_function                    IN  VARCHAR2,
   p_object_name                 IN  VARCHAR2,
   p_instance_pk1_value          IN  VARCHAR2,
   p_instance_pk2_value          IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk3_value          IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk4_value          IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk5_value          IN  VARCHAR2 DEFAULT NULL,
   p_user_name                   IN  VARCHAR2 DEFAULT NULL,
   p_object_type                 IN  VARCHAR2 DEFAULT NULL,
   p_parent_object_name          IN  VARCHAR2,
   p_parent_instance_pk1_value   IN  VARCHAR2,
   p_parent_instance_pk2_value   IN  VARCHAR2 DEFAULT NULL,
   p_parent_instance_pk3_value   IN  VARCHAR2 DEFAULT NULL,
   p_parent_instance_pk4_value   IN  VARCHAR2 DEFAULT NULL,
   p_parent_instance_pk5_value   IN  VARCHAR2 DEFAULT NULL
 )
 RETURN VARCHAR2 IS

    l_api_version       CONSTANT NUMBER := 1.0;
    l_api_name          CONSTANT VARCHAR2(30) := 'CHECK_INHERITED_FUNCTION';
    l_sysdate                    DATE := Sysdate;
    l_predicate                  VARCHAR2(32767);
--    l_orig_system                VARCHAR2(48);
    l_orig_system_id             NUMBER;
    l_dummy_id                   NUMBER;
    l_db_object_name             VARCHAR2(30);
    l_db_pk1_column              VARCHAR2(30);
    l_db_pk2_column              VARCHAR2(30);
    l_db_pk3_column              VARCHAR2(30);
    l_db_pk4_column              VARCHAR2(30);
    l_db_pk5_column              VARCHAR2(30);
    l_pk_column_names            VARCHAR2(512);
    l_pk_orig_column_names       VARCHAR2(512);
    l_type_converted_val_cols    VARCHAR2(512);
    l_result                     VARCHAR2(1);
    l_return_status              VARCHAR2(1);
    result                       VARCHAR2(30);
    l_own_result                 VARCHAR2(1);
    l_parent_object_table_count  NUMBER;
    l_set_predicates             VARCHAR2(32767);
    l_set_predicate_segment      VARCHAR2(32767);
    l_group_info                 VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_company_info               VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_menu_info                  VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_pk2_value                  VARCHAR2(200);
    l_pk3_value                  VARCHAR2(200);
    l_pk4_value                  VARCHAR2(200);
    l_pk5_value                  VARCHAR2(200);

    instance_sets_cur            DYNAMIC_CUR;
    dynamic_sql                  VARCHAR2(32767);
    parent_instance_grants_c     DYNAMIC_CUR;
    parent_instance_set_grants_c DYNAMIC_CUR;
    l_dynamic_sql_1              VARCHAR2(32767);

    CURSOR menu_id_c (cp_function    VARCHAR2, cp_object_id NUMBER,
                      cp_object_type VARCHAR2, cp_parent_object_id NUMBER)
    IS
    SELECT p.parent_role_id parent_role_id
      FROM fnd_menu_entries r, fnd_form_functions f,
           fnd_menus m, ego_obj_role_mappings p
     WHERE r.function_id       = f.function_id
       AND r.menu_id           = m.menu_id
       AND f.function_name     = cp_function
       AND m.menu_id           = p.child_role_id
       AND p.child_object_id   = cp_object_id
       AND p.parent_object_id  = cp_parent_object_id
       AND p.child_object_type = cp_object_type;

    l_object_id        NUMBER;
    l_parent_object_id NUMBER;
    l_user_name        VARCHAR2(80);
    l_inst_pred_length NUMBER;
    l_profile_role     VARCHAR2(30);
  BEGIN
    SetGlobals();
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   =>  'Started with 16 params '||
                   ' p_api_version: '|| to_char(p_api_version) ||
                   ' - p_function: '|| p_function ||
                   ' - p_object_name: '|| p_object_name ||
                   ' - p_instance_pk1_value: '|| p_instance_pk1_value ||
                   ' - p_instance_pk2_value: '|| p_instance_pk2_value ||
                   ' - p_instance_pk3_value: '|| p_instance_pk3_value ||
                   ' - p_instance_pk4_value: '|| p_instance_pk4_value ||
                   ' - p_instance_pk5_value: '|| p_instance_pk5_value ||
                   ' - p_user_name: '|| p_user_name ||
                   ' - p_object_type: '|| p_object_type ||
                   ' - p_parent_object_name: '|| p_parent_object_name ||
                   ' - p_parent_instance_pk1_value: '|| p_parent_instance_pk1_value ||
                   ' - p_parent_instance_pk2_value: '|| p_parent_instance_pk2_value ||
                   ' - p_parent_instance_pk3_value: '|| p_parent_instance_pk3_value ||
                   ' - p_parent_instance_pk4_value: '|| p_parent_instance_pk4_value ||
                   ' - p_parent_instance_pk5_value: '|| p_parent_instance_pk5_value
                );

    -- check for call compatibility.
    IF TRUNC(l_api_version) <> TRUNC(p_api_version) THEN
      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE',
                            g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON',
                            'Unsupported version '|| to_char(p_api_version)||
                            ' passed to API; expecting version '||
                            to_char(l_api_version));
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning as the call in incompatible '
                 );
      RETURN G_RETURN_UNEXP_ERR;
    END IF;

    l_user_name := p_user_name;
    get_orig_key(x_user_name      => l_user_name
--                ,x_orig_system    => l_orig_system
                ,x_orig_system_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_user_name: '||l_user_name||
--                               ' - l_orig_system: '||l_orig_system||
                               ' - l_orig_system_id: '||l_orig_system_id
               );

    --call check_function first to check its own security
    --won't check it if object_instance is -1

    if (p_instance_pk1_value<>-1) then
      l_own_result := check_function
                (p_api_version        => 1.0,
                 p_function           => p_function,
                 p_object_name        => p_object_name,
                 p_instance_pk1_value => p_instance_pk1_value,
                 p_instance_pk2_value => p_instance_pk2_value,
                 p_instance_pk3_value => p_instance_pk3_value,
                 p_instance_pk4_value => p_instance_pk4_value,
                 p_instance_pk5_value => p_instance_pk5_value,
                 p_user_name          => l_user_name);

      if (l_own_result = G_RETURN_SUCCESS) then
        code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                   ,p_module    => l_api_name
                   ,p_message   => 'Returning Success as we have direct role '
                   );
        RETURN G_RETURN_SUCCESS;
      end if;
    end if;

    l_object_id := get_object_id(p_object_name => p_object_name);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_object_id: '||l_object_id
               );
    l_parent_object_id := get_object_id(p_object_name => p_parent_object_name);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_parent_object_id: '||l_parent_object_id
               );

    l_menu_info := '';
    FOR menu_rec IN menu_id_c(p_function, l_object_id,
                              p_object_type, l_parent_object_id)
    LOOP
      l_menu_info := l_menu_info || menu_rec.parent_role_id || ', ';
    END LOOP;

    IF (length(l_menu_info) > 0) THEN
      -- strip off the trailing ', '
      l_menu_info := substr(l_menu_info, 1, length(l_menu_info) - length(', '));
    ELSE
      l_menu_info := 'NULL';
    END IF;
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_menu_info: '||l_menu_info
               );
    l_group_info := get_group_info(p_party_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_group_info: '||l_group_info
               );
    l_company_info := get_company_info (p_party_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_company_info: '||l_company_info
               );

    ------------------------------------------------------------------
    -- we see if a profile option is set and if so we add it to     --
    -- the other list of menus                                      --
    -------------------------------------------------------------------
    l_profile_role :=
        getRole_mappedTo_profileOption(p_parent_object_name, p_user_name);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'profile role for '||p_parent_object_name||
                               ' is: '||l_profile_role
               );
    IF (l_profile_role <> '') THEN
      l_dummy_id := get_role_id(l_profile_role);
      IF l_dummy_id IS NOT NULL THEN
        IF(l_menu_info = 'NULL') THEN
          l_menu_info := l_dummy_id;
        ELSE
          l_menu_info := l_menu_info || ', ' || l_dummy_id;
        END IF;
      END IF;
    END IF;

    -------------------------------------------------------
    -- We set PK query strings based on values passed in --
    -- (NOTE: following bug 2865553, FND_GRANTS will not --
    -- have null PK column values, so I'm changing this  --
    -- code to check for '*NULL*' instead of null. -Dylan--
    -------------------------------------------------------
    translate_pk_values (p_instance_pk2_value  => p_parent_instance_pk2_value
                        ,p_instance_pk3_value  => p_parent_instance_pk3_value
                        ,p_instance_pk4_value  => p_parent_instance_pk4_value
                        ,p_instance_pk5_value  => p_parent_instance_pk5_value
                        ,x_trans_pk2_value     => l_pk2_value
                        ,x_trans_pk3_value     => l_pk3_value
                        ,x_trans_pk4_value     => l_pk4_value
                        ,x_trans_pk5_value     => l_pk5_value
                        );
/***
    IF (p_instance_pk2_value IS NULL) THEN
      l_pk2_value := '*NULL*';
    else
      l_pk2_value := p_parent_instance_pk2_value;
    end if;

    IF (p_instance_pk3_value IS NULL) THEN
      l_pk3_value := '*NULL*';
    ELSE
      l_pk3_value := p_parent_instance_pk3_value;
    END IF;

    IF (p_instance_pk4_value IS NULL) THEN
      l_pk4_value := '*NULL*';
    ELSE
      l_pk4_value := p_parent_instance_pk4_value;
    END IF;

    IF (p_instance_pk5_value IS NULL) THEN
      l_pk5_value := '*NULL*';
    ELSE
      l_pk5_value := p_parent_instance_pk5_value;
    END IF;
***/
    -------------------------------------------------------------------------------
    -- Now we build dynamic SQL using the work we just did to optimize the query --
    -------------------------------------------------------------------------------
    -- R12C Security Changes
   /* l_dynamic_sql_1 :=
    ' SELECT ''X'' ' ||
      ' FROM fnd_grants grants ' ||
     ' WHERE grants.object_id = :object_id' ||
       ' AND grants.start_date <= SYSDATE ' ||
       ' AND NVL(grants.end_date,SYSDATE) >= SYSDATE ' ||
       ' AND grants.instance_type = :instance_type ' ||
       ' AND grants.instance_pk1_value = :parent_instance_pk1_value ' ||
       ' AND grants.instance_pk2_value = :pk2_value ' ||
       ' AND grants.instance_pk3_value = :pk3_value ' ||
       ' AND grants.instance_pk4_value = :pk4_value ' ||
       ' AND grants.instance_pk5_value = :pk5_value ' ||
       ' AND ( ( grants.grantee_type = ''USER'' AND ' ||
               ' grants.grantee_key = :user_name ) '||
            ' OR (grants.grantee_type = ''GROUP'' AND ' ||
                ' grants.grantee_key in ( '||l_group_info||' )) ' ||
            ' OR (grants.grantee_type = ''COMPANY'' AND ' ||
                ' grants.grantee_key in ( '||l_company_info||' )) ' ||
            ' OR (grants.grantee_type = ''GLOBAL'' AND ' ||
                ' grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL'') )) '||
       ' AND grants.menu_id IN (' || l_menu_info ||') '; */


 IF (p_object_name = 'EGO_CATALOG_GROUP') THEN
       l_dynamic_sql_1 :=
       ' SELECT ''X'' ' ||
       ' FROM fnd_grants grants , ego_item_cat_denorm_hier cathier ' ||
       ' WHERE grants.object_id = :object_id' ||
       ' AND grants.start_date <= SYSDATE ' ||
       ' AND NVL(grants.end_date,SYSDATE) >= SYSDATE ' ||
       ' AND grants.instance_type = :instance_type ' ||
       ' AND grants.instance_pk1_value = cathier.parent_catalog_group_id ' ||
       ' AND cathier.child_catalog_group_id = :parent_instance_pk1_value ' ||
       ' AND grants.instance_pk2_value = :pk2_value ' ||
       ' AND grants.instance_pk3_value = :pk3_value ' ||
       ' AND grants.instance_pk4_value = :pk4_value ' ||
       ' AND grants.instance_pk5_value = :pk5_value ' ||
       ' AND ( ( grants.grantee_type = ''USER'' AND ' ||
               ' grants.grantee_key = :user_name ) '||
            ' OR (grants.grantee_type = ''GROUP'' AND ' ||
                ' grants.grantee_key in ( '||l_group_info||' )) ' ||
            ' OR (grants.grantee_type = ''COMPANY'' AND ' ||
                ' grants.grantee_key in ( '||l_company_info||' )) ' ||
            ' OR (grants.grantee_type = ''GLOBAL'' AND ' ||
                ' grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL'') )) '||
            ' AND grants.menu_id IN (' || l_menu_info ||') ';
      ELSE
       l_dynamic_sql_1 :=
       ' SELECT ''X'' ' ||
       ' FROM fnd_grants grants ' ||
       ' WHERE grants.object_id = :object_id' ||
       ' AND grants.start_date <= SYSDATE ' ||
       ' AND NVL(grants.end_date,SYSDATE) >= SYSDATE ' ||
       ' AND grants.instance_type = :instance_type ' ||
       ' AND grants.instance_pk1_value = :parent_instance_pk1_value ' ||
       ' AND grants.instance_pk2_value = :pk2_value ' ||
       ' AND grants.instance_pk3_value = :pk3_value ' ||
       ' AND grants.instance_pk4_value = :pk4_value ' ||
       ' AND grants.instance_pk5_value = :pk5_value ' ||
       ' AND ( ( grants.grantee_type = ''USER'' AND ' ||
               ' grants.grantee_key = :user_name ) '||
            ' OR (grants.grantee_type = ''GROUP'' AND ' ||
                ' grants.grantee_key in ( '||l_group_info||' )) ' ||
            ' OR (grants.grantee_type = ''COMPANY'' AND ' ||
                ' grants.grantee_key in ( '||l_company_info||' )) ' ||
            ' OR (grants.grantee_type = ''GLOBAL'' AND ' ||
                ' grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL'') )) '||
       ' AND grants.menu_id IN (' || l_menu_info ||') ';
END IF;

--R12C Security Changes

 code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'Binds for parent direct grants '||
                   ' l_parent_object_id: '||l_parent_object_id||
                   ' - G_TYPE_INSTANCE: '||G_TYPE_INSTANCE||
                   ' - p_parent_instance_pk1_value: '|| p_parent_instance_pk1_value ||
                   ' - l_pk2_value: '|| l_pk2_value ||
                   ' - l_pk3_value: '|| l_pk3_value ||
                   ' - l_pk4_value: '|| l_pk4_value ||
                   ' - l_pk5_value: '|| l_pk5_value ||
                   ' - l_user_name: '||l_user_name
                 );
    OPEN parent_instance_grants_c
    FOR l_dynamic_sql_1
    USING IN l_parent_object_id,
          IN G_TYPE_INSTANCE,
          IN p_parent_instance_pk1_value,
          IN l_pk2_value,
          IN l_pk3_value,
          IN l_pk4_value,
          IN l_pk5_value,
          IN l_user_name;
    FETCH parent_instance_grants_c INTO l_result;
    CLOSE parent_instance_grants_c;

    IF (l_result = 'X') THEN
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning Success as function found in parent direct grants '
                 );
      RETURN G_RETURN_SUCCESS;
    ELSE
      result := get_pk_information(p_parent_object_name, l_db_pk1_column,
                                   l_db_pk2_column, l_db_pk3_column,
                                   l_db_pk4_column, l_db_pk5_column,
                                   l_pk_column_names, l_type_converted_val_cols,
                                   l_pk_orig_column_names, l_db_object_name);
      if (result <> G_RETURN_SUCCESS) then
        code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                   ,p_module    => l_api_name
                   ,p_message   => 'Parent PK informatino not available returning: '||result
                   );
        /* There will be a message on the msg dict stack. */
        return result;
      end if;

      ---------------------------------------------------------------------------------
      -- Now we build a second dynamic SQL to check instance sets (still optimizing) --
      ---------------------------------------------------------------------------------
      l_set_predicates := '(';
      l_set_predicate_segment := '';
      l_dynamic_sql_1 :=
    ' SELECT DISTINCT instance_sets.predicate ' ||
      ' FROM fnd_grants grants, fnd_object_instance_sets instance_sets ' ||
     ' WHERE grants.instance_type = :instance_type '||
       ' AND grants.start_date <= SYSDATE ' ||
       ' AND NVL(grants.end_date,SYSDATE) >= SYSDATE ' ||
       ' AND grants.instance_set_id = instance_sets.instance_set_id ' ||
       ' AND grants.object_id = :object_id ' ||
       ' AND ( ( grants.grantee_type = ''USER'' AND ' ||
               ' grants.grantee_key = :user_name ) '||
            ' OR (grants.grantee_type = ''GROUP'' AND ' ||
                ' grants.grantee_key in ( '||l_group_info||' )) ' ||
            ' OR (grants.grantee_type = ''COMPANY'' AND ' ||
                ' grants.grantee_key in ( '||l_company_info||' )) ' ||
            ' OR (grants.grantee_type = ''GLOBAL'' AND ' ||
                ' grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL'') )) '||
       ' AND grants.menu_id IN (' || l_menu_info ||') ';
      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'Binds for parent_instance_set_grants_c '||
                   ' G_TYPE_SET: '||G_TYPE_SET||
                   ' - l_parent_object_id: '||l_parent_object_id||
                   ' - l_user_name: '||l_user_name
                 );

      ----------------------------------------------------------------------
      -- Loop through the result set adding each segment to the predicate --
      ----------------------------------------------------------------------
      OPEN parent_instance_set_grants_c
      FOR l_dynamic_sql_1
      USING IN G_TYPE_SET,
             IN l_parent_object_id,
             IN l_user_name;
      LOOP
        FETCH parent_instance_set_grants_c into l_set_predicate_segment;
        EXIT WHEN parent_instance_set_grants_c%NOTFOUND;

        l_set_predicates := substrb(l_set_predicates ||
                            l_set_predicate_segment ||
                            ') OR (',
                            1, g_pred_buf_size);
      END LOOP;
      CLOSE parent_instance_set_grants_c;

      l_inst_pred_length := LENGTH(l_set_predicates);
      IF l_inst_pred_length = 1 THEN
        -- No predicate
        code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                   ,p_module    => l_api_name
                   ,p_message   => 'No instance sets available returning: '||G_RETURN_FAILURE
                   );
        RETURN G_RETURN_FAILURE;
      ELSE
        l_set_predicates := SUBSTR(l_set_predicates, 1,
                              l_inst_pred_length - length('OR ('));
      END IF;
      -- finished by.a
      l_predicate := l_set_predicates;
      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'l_set_predicates: '||l_set_predicates
                 );
     -- R12C Security Changes
      /*dynamic_sql :=
        'SELECT ''X'' '||
         ' FROM '|| l_db_object_name ||
        ' WHERE '; */

      IF (p_object_name = 'EGO_ITEM') THEN
         dynamic_sql :=
         'SELECT ''X'' '||
         ' FROM '|| l_db_object_name || ', ego_item_cat_denorm_hier cathier'||
         ' WHERE ';
      ELSE
         dynamic_sql :=
        'SELECT ''X'' '||
        ' FROM '|| l_db_object_name ||
        ' WHERE ';
      END IF;
      -- R12C Security Changes

      if (l_db_pk1_column is not NULL) then
        dynamic_sql := dynamic_sql ||
                       ' (('||l_db_pk1_column||' = :pk1_val) '||
                       ' OR (('||l_db_pk1_column||' is NULL) '||
                       ' AND (:pk1_val is NULL)))';
      end if;
      if (l_db_pk2_column is not NULL) then
        dynamic_sql := dynamic_sql ||
                       ' AND (('||l_db_pk2_column||' = :pk2_val) '||
                       ' OR (('||l_db_pk2_column||' is NULL) '||
                       ' AND (:pk2_val is NULL)))';
      end if;
      if (l_db_pk3_column is not NULL) then
         dynamic_sql := dynamic_sql ||
                        ' AND (('||l_db_pk3_column||' = :pk3_val) '||
                        ' OR (('||l_db_pk3_column||' is NULL) '||
                        ' AND (:pk3_val is NULL)))';
      end if;
      if (l_db_pk4_column is not NULL) then
        dynamic_sql := dynamic_sql ||
                       ' AND (('||l_db_pk4_column||' = :pk4_val) '||
                       ' OR (('||l_db_pk4_column||' is NULL) '||
                       ' AND (:pk4_val is NULL)))';
      end if;
      if (l_db_pk5_column is not NULL) then
        dynamic_sql := dynamic_sql ||
                       ' AND (('||l_db_pk5_column||' = :pk5_val) '||
                       ' OR (('||l_db_pk5_column||' is NULL) '||
                       ' AND (:pk2_val is NULL)))';
      end if;

       --R12C Security Changes
      /*dynamic_sql := dynamic_sql ||
                     ' AND ('||l_predicate||') ';*/
       IF (p_object_name = 'EGO_ITEM') THEN
       dynamic_sql := dynamic_sql ||
                     ' AND  item_catalog_group_id = cathier.child_catalog_group_id AND ('||l_predicate||') ';
  ELSE
        dynamic_sql := dynamic_sql ||
                     ' AND ('||l_predicate||') ';
  END IF;
      --R12C Security Changes

      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'dynamic_sql: '||dynamic_sql
                 );

      if(l_db_pk5_column is not NULL) then
        code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                   ,p_module    => l_api_name
                   ,p_message   => 'Binds for instance_sets_cur is '||
          ' - p_parent_instance_pk1_value: '|| p_parent_instance_pk1_value ||
          ' - p_parent_instance_pk1_value: '|| p_parent_instance_pk1_value ||
          ' - p_parent_instance_pk2_value: '|| p_parent_instance_pk2_value ||
          ' - p_parent_instance_pk2_value: '|| p_parent_instance_pk2_value ||
          ' - p_parent_instance_pk3_value: '|| p_parent_instance_pk3_value ||
          ' - p_parent_instance_pk3_value: '|| p_parent_instance_pk3_value ||
          ' - p_parent_instance_pk4_value: '|| p_parent_instance_pk4_value ||
          ' - p_parent_instance_pk4_value: '|| p_parent_instance_pk4_value ||
          ' - p_parent_instance_pk5_value: '|| p_parent_instance_pk5_value ||
          ' - p_parent_instance_pk5_value: '|| p_parent_instance_pk5_value
                   );
        OPEN instance_sets_cur FOR dynamic_sql USING
        p_parent_instance_pk1_value, p_parent_instance_pk1_value,
        p_parent_instance_pk2_value, p_parent_instance_pk2_value,
        p_parent_instance_pk3_value, p_parent_instance_pk3_value,
        p_parent_instance_pk4_value, p_parent_instance_pk4_value,
        p_parent_instance_pk5_value, p_parent_instance_pk5_value;
      elsif (l_db_pk4_column is not NULL) then
        code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                   ,p_module    => l_api_name
                   ,p_message   => 'Binds for instance_sets_cur is '||
          ' - p_parent_instance_pk1_value: '|| p_parent_instance_pk1_value ||
          ' - p_parent_instance_pk1_value: '|| p_parent_instance_pk1_value ||
          ' - p_parent_instance_pk2_value: '|| p_parent_instance_pk2_value ||
          ' - p_parent_instance_pk2_value: '|| p_parent_instance_pk2_value ||
          ' - p_parent_instance_pk3_value: '|| p_parent_instance_pk3_value ||
          ' - p_parent_instance_pk3_value: '|| p_parent_instance_pk3_value ||
          ' - p_parent_instance_pk4_value: '|| p_parent_instance_pk4_value ||
          ' - p_parent_instance_pk4_value: '|| p_parent_instance_pk4_value
                   );
        OPEN instance_sets_cur FOR dynamic_sql USING
        p_parent_instance_pk1_value, p_parent_instance_pk1_value,
        p_parent_instance_pk2_value, p_parent_instance_pk2_value,
        p_parent_instance_pk3_value, p_parent_instance_pk3_value,
        p_parent_instance_pk4_value, p_parent_instance_pk4_value;
      elsif (l_db_pk3_column is not NULL) then
        code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                   ,p_module    => l_api_name
                   ,p_message   => 'Binds for instance_sets_cur is '||
          ' - p_parent_instance_pk1_value: '|| p_parent_instance_pk1_value ||
          ' - p_parent_instance_pk1_value: '|| p_parent_instance_pk1_value ||
          ' - p_parent_instance_pk2_value: '|| p_parent_instance_pk2_value ||
          ' - p_parent_instance_pk2_value: '|| p_parent_instance_pk2_value ||
          ' - p_parent_instance_pk3_value: '|| p_parent_instance_pk3_value ||
          ' - p_parent_instance_pk3_value: '|| p_parent_instance_pk3_value
                   );
        OPEN instance_sets_cur FOR dynamic_sql USING
        p_parent_instance_pk1_value, p_parent_instance_pk1_value,
        p_parent_instance_pk2_value, p_parent_instance_pk2_value,
        p_parent_instance_pk3_value, p_parent_instance_pk3_value;
      elsif (l_db_pk2_column is not NULL) then
        code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                   ,p_module    => l_api_name
                   ,p_message   => 'Binds for instance_sets_cur is '||
          ' - p_parent_instance_pk1_value: '|| p_parent_instance_pk1_value ||
          ' - p_parent_instance_pk1_value: '|| p_parent_instance_pk1_value ||
          ' - p_parent_instance_pk2_value: '|| p_parent_instance_pk2_value ||
          ' - p_parent_instance_pk2_value: '|| p_parent_instance_pk2_value
                   );
        OPEN instance_sets_cur FOR dynamic_sql USING
        p_parent_instance_pk1_value, p_parent_instance_pk1_value,
        p_parent_instance_pk2_value, p_parent_instance_pk2_value;
      elsif (l_db_pk1_column is not NULL) then
        code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                   ,p_module    => l_api_name
                   ,p_message   => 'Binds for instance_sets_cur is '||
          ' - p_parent_instance_pk1_value: '|| p_parent_instance_pk1_value ||
          ' - p_parent_instance_pk1_value: '|| p_parent_instance_pk1_value
                   );
        OPEN instance_sets_cur FOR dynamic_sql USING
        p_parent_instance_pk1_value, p_parent_instance_pk1_value;
      else
        code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                   ,p_module    => l_api_name
                   ,p_message   => 'No pk values for parent!! : '||G_RETURN_UNEXP_ERR
                   );
        return G_RETURN_UNEXP_ERR; /* This will never happen since pk1 is reqd*/
      end if;

      FETCH instance_sets_cur INTO l_own_result;
      IF(instance_sets_cur%NOTFOUND) THEN
        CLOSE instance_sets_cur;
        code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                   ,p_module    => l_api_name
                   ,p_message   => 'No role from instance sets after query: '||G_RETURN_FAILURE
                   );
        RETURN G_RETURN_FAILURE;
      ELSE
        CLOSE instance_sets_cur;
        code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                   ,p_module    => l_api_name
                   ,p_message   => 'No instance sets available returning: '||G_RETURN_SUCCESS
                   );
        RETURN G_RETURN_SUCCESS;
      END IF;
    END IF; -- End of if l_result is 'X' else clause

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE',G_PKG_NAME||l_api_name);
      fnd_message.set_token('ERRNO', SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      code_debug (p_log_level => G_DEBUG_LEVEL_EXCEPTION
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning EXCEPTION '||SQLERRM
                  );
      RETURN G_RETURN_UNEXP_ERR;
  END check_inherited_function;

--------------------------------------------------------
----    get_functions
--------------------------------------------------------
  PROCEDURE get_functions
  (
   p_api_version          IN  NUMBER,
   p_object_name          IN  VARCHAR2,
   p_instance_pk1_value   IN  VARCHAR2,
   p_instance_pk2_value   IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk3_value   IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk4_value   IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk5_value   IN  VARCHAR2 DEFAULT NULL,
   p_user_name            IN  varchar2 default null,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_privilege_tbl        OUT NOCOPY EGO_PRIVILEGE_NAME_TABLE_TYPE
  ) IS

    l_api_version  CONSTANT NUMBER := 1.0;
    l_api_name     CONSTANT VARCHAR2(30)  := 'GET_FUNCTIONS';

    -- On addition of any Required parameters the major version needs
    -- to change i.e. for eg. 1.X to 2.X.
    -- On addition of any Optional parameters the minor version needs
    -- to change i.e. for eg. X.6 to X.7.
    l_sysdate              DATE := SYSDATE;

    l_index                NUMBER;
    l_dynamic_sql          VARCHAR2(32767);
    l_instance_id_col1     VARCHAR2(512);
    l_instance_id_col2     VARCHAR2(512);
    l_instance_id_col3     VARCHAR2(512);
    l_instance_id_col4     VARCHAR2(512);
    l_instance_id_col5     VARCHAR2(512);
    l_instance_sets_list   VARCHAR2(10000);
    l_privilege            VARCHAR2(480);
    l_select_query_part    VARCHAR2(3000);

    l_group_info     VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_company_info   VARCHAR2(32767); /* Must match g_pred_buf_size*/

    start_date number;
    end_date number;
    millisec number;

    instance_set DYNAMIC_CUR;

    l_one_set_predicate VARCHAR2(32767);
    l_one_set_id        NUMBER;
    candidate_sets_c DYNAMIC_CUR;
    l_dynamic_sql_1     VARCHAR2(32767);
    l_common_dyn_sql    VARCHAR2(32767);
    l_set_dyn_sql       VARCHAR2(32767);
    l_inst_dyn_sql      VARCHAR2(32767);

    l_db_object_name        varchar2(30);
    l_db_pk1_column         varchar2(30);
    l_db_pk2_column         varchar2(30);
    l_db_pk3_column         varchar2(30);
    l_db_pk4_column         varchar2(30);
    l_db_pk5_column         varchar2(30);

    l_pk_column_names       varchar2(512);
    l_pk_orig_column_names  varchar2(512);
    l_type_converted_val_cols varchar2(512);
    l_object_id             number;
    l_user_name             varchar2(80);
--    l_orig_system          varchar2(48);
    l_orig_system_id       NUMBER;
    l_prof_privilege_tbl              EGO_VARCHAR_TBL_TYPE;

    l_pk2_value                  VARCHAR2(200);
    l_pk3_value                  VARCHAR2(200);
    l_pk4_value                  VARCHAR2(200);
    l_pk5_value                  VARCHAR2(200);

  BEGIN
    SetGlobals();
--start_date:= DBMS_UTILITY.GET_TIME;
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   =>  'Started with 10 params '||
                   ' p_api_version: '|| to_char(p_api_version) ||
                   ' - p_object_name: '|| p_object_name ||
                   ' - p_instance_pk1_value: '|| p_instance_pk1_value ||
                   ' - p_instance_pk2_value: '|| p_instance_pk2_value ||
                   ' - p_instance_pk3_value: '|| p_instance_pk3_value ||
                   ' - p_instance_pk4_value: '|| p_instance_pk4_value ||
                   ' - p_instance_pk5_value: '|| p_instance_pk5_value ||
                   ' - p_user_name: '|| p_user_name
               );
    -- check for call compatibility.
    if TRUNC(l_api_version) <> TRUNC(p_api_version) THEN
      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE',
                            g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON',
         'Unsupported version '|| to_char(p_api_version)||
         ' passed to API; expecting version '||
         to_char(l_api_version));
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning as the call in incompatible '
                 );
      x_return_status := G_RETURN_UNEXP_ERR;
      RETURN;
    END IF;

    x_return_status := G_RETURN_SUCCESS; /* Assume Success */
    l_user_name := p_user_name;
    get_orig_key(x_user_name      => l_user_name
--                ,x_orig_system    => l_orig_system
                ,x_orig_system_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_user_name: '||l_user_name||
--                               ' - l_orig_system: '||l_orig_system||
                               ' - l_orig_system_id: '||l_orig_system_id
               );

    -- first get all the privileges set by the profile option
    l_index:=0;
    getPrivilege_for_profileOption
            (p_api_version    => p_api_version,
            p_object_name     => p_object_name,
            p_user_name       => l_user_name,
            x_privilege_tbl   => l_prof_privilege_tbl ,
            x_return_status   => x_return_status);

    IF (x_return_status = G_RETURN_SUCCESS) THEN
      IF (l_prof_privilege_tbl.COUNT > 0) THEN
        FOR i IN l_prof_privilege_tbl.first .. l_prof_privilege_tbl.last LOOP
          code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                     ,p_module    => l_api_name
                     ,p_message   => 'Privilege from profile at: '||i||' value: '||l_prof_privilege_tbl(i)
                     );
           x_privilege_tbl(i) := l_prof_privilege_tbl(i);
        END LOOP;
      END IF; -- x_prof_privilege_tbl >0
      l_index := l_prof_privilege_tbl.COUNT;
    END IF; --return status is T

    --end of getting privileges from profile option

    -- get All privileges of a user on a given object
    --Step 1.
    -- get database object name and column
    -- cache the PK column name
    x_return_status := get_pk_information(p_object_name  ,
                       l_db_pk1_column  ,
                       l_db_pk2_column  ,
                       l_db_pk3_column  ,
                       l_db_pk4_column  ,
                       l_db_pk5_column  ,
                       l_pk_column_names  ,
                       l_type_converted_val_cols  ,
                       l_pk_orig_column_names,
                       l_db_object_name );
     if (x_return_status <> G_RETURN_SUCCESS) then
      /* There will be a message on the msg dict stack. */
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning FALSE as pk values are not correct'
                  );
      RETURN;  /* We will return the x_return_status as out param */
    end if;

    -- Step 2.
    -- get instance set ids in which the given object_key exist
    -- as a set into l_instance_set
    l_instance_sets_list :='(';

-- R12C Security Changes
    /*l_select_query_part:=
             'SELECT '|| l_pk_column_names ||
             ' FROM  '|| l_db_object_name  ||
             ' WHERE '; */
    IF (p_object_name = 'EGO_ITEM') THEN
    l_select_query_part:=
             'SELECT '|| l_pk_column_names ||
             ' FROM  '|| l_db_object_name  || ', ego_item_cat_denorm_hier cathier'||
             ' WHERE ';
    ELSE
    l_select_query_part:=
             'SELECT '|| l_pk_column_names ||
             ' FROM  '|| l_db_object_name  ||
             ' WHERE ';
    END IF;
-- R12C Security Changes

    IF (l_db_pk1_column IS NOT NULL) THEN
       l_select_query_part := l_select_query_part ||
            ' ( '||l_db_pk1_column||' = :pk1_val '||
             ' OR ( '||l_db_pk1_column||' is NULL AND :pk1_val is NULL))';
    END IF;
    IF (l_db_pk2_column IS NOT NULL) THEN
       l_select_query_part := l_select_query_part ||
        ' AND (  '||l_db_pk2_column||' = :pk2_val '||
             ' OR ( '||l_db_pk2_column||' is NULL AND :pk2_val is NULL))';
    END IF;
    IF (l_db_pk3_column IS NOT NULL) THEN
       l_select_query_part := l_select_query_part ||
        ' AND ( '||l_db_pk3_column||' = :pk3_val '||
             ' OR ( '||l_db_pk3_column||' is NULL AND :pk3_val is NULL))';
    END IF;
    IF (l_db_pk4_column IS NOT NULL) THEN
       l_select_query_part := l_select_query_part ||
       ' AND ( '||l_db_pk4_column||' = :pk4_val '||
             ' OR ( '||l_db_pk4_column||' is NULL AND :pk4_val is NULL))';
    END IF;
    IF (l_db_pk5_column IS NOT NULL) THEN
       l_select_query_part := l_select_query_part ||
        ' AND ( '||l_db_pk5_column||' = :pk5_val '||
             ' OR ( '||l_db_pk5_column||' is NULL AND :pk5_val is NULL))';
    END IF;

    -- R12C Security Changes
    --l_select_query_part := l_select_query_part || ' AND ';
    IF (p_object_name = 'EGO_ITEM') THEN
        l_select_query_part := l_select_query_part || ' AND item_catalog_group_id = cathier.child_catalog_group_id AND ';
    ELSE
         l_select_query_part := l_select_query_part || ' AND ';
    END IF;
    -- R12C Security Changes

--end_date:= DBMS_UTILITY.GET_TIME;
--millisec:= (end_date-start_date)*24*60*60*1000;
--dbms_output.put_line('1. Diff. in Get Time 100th of a sec ::'||to_char(end_date-start_date,'9999999'));

    l_object_id:=get_object_id(p_object_name => p_object_name );
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_object_id: '||l_object_id
               );
    -- step 1.1
    -- pre-fetch company/group info
    l_group_info := get_group_info(p_party_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_group_info: '||l_group_info
               );
    l_company_info := get_company_info (p_party_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_company_info: '||l_company_info
               );
--end_date:= DBMS_UTILITY.GET_TIME;
--millisec:= (end_date-start_date)*24*60*60*1000;
--dbms_output.put_line('2. Diff. in Get Time 100th of a sec ::'||to_char(end_date-start_date,'9999999'));

    l_dynamic_sql_1 :=
      ' SELECT DISTINCT sets.instance_set_id, sets.predicate ' ||
        ' FROM fnd_grants grants, ' ||
             ' fnd_object_instance_sets  sets '||
      ' WHERE grants.instance_type = :instance_type '||
       ' AND grants.start_date <= SYSDATE ' ||
       ' AND NVL(grants.end_date,SYSDATE) >= SYSDATE ' ||
       ' AND grants.instance_set_id = sets.instance_set_id ' ||
       ' AND grants.object_id = :object_id ' ||
       ' AND ( ( grants.grantee_type = ''USER'' AND ' ||
               ' grants.grantee_key = :user_name ) '||
            ' OR (grants.grantee_type = ''GROUP'' AND ' ||
                ' grants.grantee_key in ( '||l_group_info||' )) ' ||
            ' OR (grants.grantee_type = ''COMPANY'' AND ' ||
                ' grants.grantee_key in ( '||l_company_info||' )) ' ||
            ' OR (grants.grantee_type = ''GLOBAL'' AND ' ||
                ' grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL'') )) ';
      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'Binds for candidate_sets_c '||
                   ' G_TYPE_SET: '||G_TYPE_SET||
                   ' - l_object_id: '||l_object_id||
                   ' - l_user_name: '||l_user_name
                 );
    OPEN candidate_sets_c FOR l_dynamic_sql_1
    USING IN G_TYPE_SET,
          IN l_object_id,
          IN l_user_name;
    LOOP
      l_instance_id_col1 := '';
      l_instance_id_col2 := '';
      l_instance_id_col3 := '';
      l_instance_id_col4 := '';
      l_instance_id_col5 := '';

      FETCH candidate_sets_c INTO l_one_set_id, l_one_set_predicate;
      EXIT WHEN candidate_sets_c%NOTFOUND;

      l_dynamic_sql :=l_select_query_part  ||
                      ' ( ' ||  l_one_set_predicate || ' ) ';

      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'l_dynamice_sql '||
                   ' l_select_query_part: '||l_select_query_part||
                   ' - l_one_set_predicate: '||l_one_set_predicate
                 );

      if(l_db_pk5_column is not NULL) then
        code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                   ,p_module    => l_api_name
                   ,p_message   => 'Binds for instance_sets_cur is '||
          ' - p_instance_pk1_value: '|| p_instance_pk1_value ||
          ' - p_instance_pk1_value: '|| p_instance_pk1_value ||
          ' - p_instance_pk2_value: '|| p_instance_pk2_value ||
          ' - p_instance_pk2_value: '|| p_instance_pk2_value ||
          ' - p_instance_pk3_value: '|| p_instance_pk3_value ||
          ' - p_instance_pk3_value: '|| p_instance_pk3_value ||
          ' - p_instance_pk4_value: '|| p_instance_pk4_value ||
          ' - p_instance_pk4_value: '|| p_instance_pk4_value ||
          ' - p_instance_pk5_value: '|| p_instance_pk5_value ||
          ' - p_instance_pk5_value: '|| p_instance_pk5_value
                   );
         OPEN instance_set FOR l_dynamic_sql USING
            p_instance_pk1_value, p_instance_pk1_value,
            p_instance_pk2_value, p_instance_pk2_value,
            p_instance_pk3_value, p_instance_pk3_value,
            p_instance_pk4_value, p_instance_pk4_value,
            p_instance_pk5_value, p_instance_pk5_value;
      elsif(l_db_pk4_column is not NULL) then
        code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                   ,p_module    => l_api_name
                   ,p_message   => 'Binds for instance_sets_cur is '||
          ' - p_instance_pk1_value: '|| p_instance_pk1_value ||
          ' - p_instance_pk1_value: '|| p_instance_pk1_value ||
          ' - p_instance_pk2_value: '|| p_instance_pk2_value ||
          ' - p_instance_pk2_value: '|| p_instance_pk2_value ||
          ' - p_instance_pk3_value: '|| p_instance_pk3_value ||
          ' - p_instance_pk3_value: '|| p_instance_pk3_value ||
          ' - p_instance_pk4_value: '|| p_instance_pk4_value ||
          ' - p_instance_pk4_value: '|| p_instance_pk4_value
                   );
         OPEN instance_set FOR l_dynamic_sql USING
            p_instance_pk1_value, p_instance_pk1_value,
            p_instance_pk2_value, p_instance_pk2_value,
            p_instance_pk3_value, p_instance_pk3_value,
            p_instance_pk4_value, p_instance_pk4_value;
      elsif(l_db_pk3_column is not NULL) then
        code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                   ,p_module    => l_api_name
                   ,p_message   => 'Binds for instance_sets_cur is '||
          ' - p_instance_pk1_value: '|| p_instance_pk1_value ||
          ' - p_instance_pk1_value: '|| p_instance_pk1_value ||
          ' - p_instance_pk2_value: '|| p_instance_pk2_value ||
          ' - p_instance_pk2_value: '|| p_instance_pk2_value ||
          ' - p_instance_pk3_value: '|| p_instance_pk3_value ||
          ' - p_instance_pk3_value: '|| p_instance_pk3_value
                   );
         OPEN instance_set FOR l_dynamic_sql USING
            p_instance_pk1_value, p_instance_pk1_value,
            p_instance_pk2_value, p_instance_pk2_value,
            p_instance_pk3_value, p_instance_pk3_value;
      elsif(l_db_pk2_column is not NULL) then
        code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                   ,p_module    => l_api_name
                   ,p_message   => 'Binds for instance_sets_cur is '||
          ' - p_instance_pk1_value: '|| p_instance_pk1_value ||
          ' - p_instance_pk1_value: '|| p_instance_pk1_value ||
          ' - p_instance_pk2_value: '|| p_instance_pk2_value ||
          ' - p_instance_pk2_value: '|| p_instance_pk2_value
                   );
         OPEN instance_set FOR l_dynamic_sql USING
            p_instance_pk1_value, p_instance_pk1_value,
            p_instance_pk2_value, p_instance_pk2_value;
      elsif(l_db_pk1_column is not NULL) then
        code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                   ,p_module    => l_api_name
                   ,p_message   => 'Binds for instance_sets_cur is '||
          ' - p_instance_pk1_value: '|| p_instance_pk1_value ||
          ' - p_instance_pk1_value: '|| p_instance_pk1_value
                   );
         OPEN instance_set FOR l_dynamic_sql USING
            p_instance_pk1_value, p_instance_pk1_value;
      else
        x_return_status := G_RETURN_UNEXP_ERR;
        code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                   ,p_module    => l_api_name
                   ,p_message   => 'No pk values for oobject : '||G_RETURN_UNEXP_ERR
                   );
        return; /* This will never happen since pk1 is reqd*/
      end if;

      if  l_db_pk5_column is not null
          and l_db_pk4_column is not null
          and l_db_pk3_column is not null
          and l_db_pk2_column is not null
          and l_db_pk1_column is not null then
        fetch instance_set into l_instance_id_col1, l_instance_id_col2,
                                 l_instance_id_col3,
                                 l_instance_id_col4, l_instance_id_col5;
        CLOSE instance_set;
        IF (l_instance_id_col1 = p_instance_pk1_value
                 and l_instance_id_col2 = p_instance_pk2_value
                 and l_instance_id_col3 = p_instance_pk3_value
                 and l_instance_id_col4 = p_instance_pk4_value
                 and l_instance_id_col5 = p_instance_pk5_value) THEN
                l_instance_sets_list :=l_instance_sets_list ||
                                       l_one_set_id || ',';
        END IF;
      elsif l_db_pk4_column is not null
            and l_db_pk3_column is not null
            and l_db_pk2_column is not null
            and l_db_pk1_column is not null then
         fetch instance_set into l_instance_id_col1,
                                 l_instance_id_col2,
                                 l_instance_id_col3,
                                 l_instance_id_col4;
         CLOSE instance_set;
         IF (l_instance_id_col1 = p_instance_pk1_value
                 and l_instance_id_col2 = p_instance_pk2_value
                 and l_instance_id_col3 = p_instance_pk3_value
                 and l_instance_id_col4 = p_instance_pk4_value) THEN
                l_instance_sets_list :=l_instance_sets_list ||
                    l_one_set_id || ',';
         END IF;
      elsif l_db_pk3_column is not null
             and l_db_pk2_column is not null
             and l_db_pk1_column is not null then
           fetch instance_set into l_instance_id_col1,
                                   l_instance_id_col2,
                                   l_instance_id_col3;
           CLOSE instance_set;
           IF (l_instance_id_col1 = p_instance_pk1_value
                 and l_instance_id_col2 = p_instance_pk2_value
                 and l_instance_id_col3 = p_instance_pk3_value) THEN
                l_instance_sets_list :=l_instance_sets_list
                                       || l_one_set_id || ',';
           END IF;
      elsif l_db_pk2_column is not null
               and l_db_pk1_column is not null then
               fetch instance_set into l_instance_id_col1, l_instance_id_col2;
               --EXIT WHEN instance_set%NOTFOUND;
               CLOSE instance_set;
               IF (l_instance_id_col1 = p_instance_pk1_value
                     and l_instance_id_col2 = p_instance_pk2_value) THEN
                    l_instance_sets_list :=l_instance_sets_list
                                           || l_one_set_id || ',';
               END IF;
      elsif l_db_pk1_column is not null then
               fetch instance_set into l_instance_id_col1;
               CLOSE instance_set;
               IF (l_instance_id_col1 = p_instance_pk1_value) THEN
                    l_instance_sets_list :=l_instance_sets_list
                                           || l_one_set_id || ',';
               END IF;
      end if;

      END LOOP;
      CLOSE candidate_sets_c;

--end_date:= DBMS_UTILITY.GET_TIME;
--millisec:= (end_date-start_date)*24*60*60*1000;
--dbms_output.put_line('3. Diff. in Get Time 100th of a sec ::'||to_char(end_date-start_date,'9999999'));

      -- if the last character is ',' then strip the trailing ','
      if(substr(l_instance_sets_list,
                  length(l_instance_sets_list),
                  length(','))
                               = ',')
      then
           l_instance_sets_list := substr(l_instance_sets_list, 1,
                              length(l_instance_sets_list) - length(','));
      end if;

      l_instance_sets_list :=l_instance_sets_list ||' )';
      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'l_instance_sets_list: '||l_instance_sets_list
                 );

      l_common_dyn_sql := '';
      l_set_dyn_sql  := '';
      l_inst_dyn_sql := '';

-- R12C Security Changes Bug 6507794
   /*   l_common_dyn_sql:=
      'SELECT DISTINCT fnd_functions.function_name ' ||
       ' FROM fnd_grants grants, ' ||
            ' fnd_form_functions fnd_functions, ' ||
            ' fnd_menu_entries cmf '||
      ' WHERE grants.object_id = :object_id ' ||
       ' AND grants.start_date <= SYSDATE ' ||
       ' AND NVL(grants.end_date,SYSDATE) >= SYSDATE ' ||
       ' AND ( ( grants.grantee_type = ''USER'' AND ' ||
               ' grants.grantee_key = :user_name ) '||
            ' OR (grants.grantee_type = ''GROUP'' AND ' ||
                ' grants.grantee_key in ( '||l_group_info||' )) ' ||
            ' OR (grants.grantee_type = ''COMPANY'' AND ' ||
                ' grants.grantee_key in ( '||l_company_info||' )) ' ||
            ' OR (grants.grantee_type = ''GLOBAL'' AND ' ||
                ' grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL'') ))'||
        ' AND cmf.function_id = fnd_functions.function_id ' ||
        ' AND cmf.menu_id = grants.menu_id '; */

   IF (p_object_name = 'EGO_CATALOG_GROUP') THEN
   l_common_dyn_sql:=
      'SELECT DISTINCT fnd_functions.function_name ' ||
       ' FROM fnd_grants grants, ' ||
            ' fnd_form_functions fnd_functions, ' ||
            ' fnd_menu_entries cmf, '||
            ' ego_item_cat_denorm_hier cathier '||
      ' WHERE grants.object_id = :object_id ' ||
       ' AND grants.start_date <= SYSDATE ' ||
       ' AND NVL(grants.end_date,SYSDATE) >= SYSDATE ' ||
       ' AND ( ( grants.grantee_type = ''USER'' AND ' ||
               ' grants.grantee_key = :user_name ) '||
            ' OR (grants.grantee_type = ''GROUP'' AND ' ||
                ' grants.grantee_key in ( '||l_group_info||' )) ' ||
            ' OR (grants.grantee_type = ''COMPANY'' AND ' ||
                ' grants.grantee_key in ( '||l_company_info||' )) ' ||
            ' OR (grants.grantee_type = ''GLOBAL'' AND ' ||
                ' grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL'') ))'||
        ' AND cmf.function_id = fnd_functions.function_id ' ||
        ' AND cmf.menu_id = grants.menu_id ';
   ELSE
   l_common_dyn_sql:=
      'SELECT DISTINCT fnd_functions.function_name ' ||
       ' FROM fnd_grants grants, ' ||
            ' fnd_form_functions fnd_functions, ' ||
            ' fnd_menu_entries cmf '||
      ' WHERE grants.object_id = :object_id ' ||
       ' AND grants.start_date <= SYSDATE ' ||
       ' AND NVL(grants.end_date,SYSDATE) >= SYSDATE ' ||
       ' AND ( ( grants.grantee_type = ''USER'' AND ' ||
               ' grants.grantee_key = :user_name ) '||
            ' OR (grants.grantee_type = ''GROUP'' AND ' ||
                ' grants.grantee_key in ( '||l_group_info||' )) ' ||
            ' OR (grants.grantee_type = ''COMPANY'' AND ' ||
                ' grants.grantee_key in ( '||l_company_info||' )) ' ||
            ' OR (grants.grantee_type = ''GLOBAL'' AND ' ||
                ' grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL'') ))'||
        ' AND cmf.function_id = fnd_functions.function_id ' ||
        ' AND cmf.menu_id = grants.menu_id ';
   END IF;
    -- R12C Security Changes Bug 6507794


    translate_pk_values (p_instance_pk2_value  => p_instance_pk2_value
                        ,p_instance_pk3_value  => p_instance_pk3_value
                        ,p_instance_pk4_value  => p_instance_pk4_value
                        ,p_instance_pk5_value  => p_instance_pk5_value
                        ,x_trans_pk2_value     => l_pk2_value
                        ,x_trans_pk3_value     => l_pk3_value
                        ,x_trans_pk4_value     => l_pk4_value
                        ,x_trans_pk5_value     => l_pk5_value
                        );

-- R12C Security Changes Bug 6507794
    /* l_inst_dyn_sql :=
        ' AND grants.instance_type = :instance_type_instance '||
        ' AND grants.instance_pk1_value = :pk1_val '||
        ' AND grants.instance_pk2_value = :pk2_val '||
        ' AND grants.instance_pk3_value = :pk3_val '||
        ' AND grants.instance_pk4_value = :pk4_val '||
        ' AND grants.instance_pk5_value = :pk5_val ';*/
IF (p_object_name = 'EGO_CATALOG_GROUP') THEN
        l_inst_dyn_sql :=
        ' AND grants.instance_type = :instance_type_instance '||
        ' AND grants.instance_pk1_value = cathier.parent_catalog_group_id ' ||
        ' AND cathier.child_catalog_group_id = :pk1_val '||
        ' AND grants.instance_pk2_value = :pk2_val '||
        ' AND grants.instance_pk3_value = :pk3_val '||
        ' AND grants.instance_pk4_value = :pk4_val '||
        ' AND grants.instance_pk5_value = :pk5_val ';
ELSE
        l_inst_dyn_sql :=
        ' AND grants.instance_type = :instance_type_instance '||
        ' AND grants.instance_pk1_value = :pk1_val '||
        ' AND grants.instance_pk2_value = :pk2_val '||
        ' AND grants.instance_pk3_value = :pk3_val '||
        ' AND grants.instance_pk4_value = :pk4_val '||
        ' AND grants.instance_pk5_value = :pk5_val ';
END IF;
 -- R12C Security Changes Bug 6507794

       -- check whether it is empty set
     IF( l_instance_sets_list <> '( )') THEN
          l_set_dyn_sql:=l_set_dyn_sql ||
          ' AND ' ||
          ' ( ' ||
          ' grants.instance_type = :instance_type_set '||
          ' AND grants.instance_set_id IN ' || l_instance_sets_list  ||
          ' ) ';
     END IF;

     IF( l_instance_sets_list <> '( )') THEN
       l_dynamic_sql:= l_common_dyn_sql || l_inst_dyn_sql ||
                       ' UNION ' ||
                       l_common_dyn_sql || l_set_dyn_sql;
     ELSE
       l_dynamic_sql:=l_common_dyn_sql || l_inst_dyn_sql;
     END IF;
     code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                ,p_module    => l_api_name
                ,p_message   => 'l_dynamic_sql: '||l_dynamic_sql
                );

--end_date:= DBMS_UTILITY.GET_TIME;
--millisec:= (end_date-start_date)*24*60*60*1000;
--dbms_output.put_line('4. Diff. in Get Time 100th of a sec ::'||to_char(end_date-start_date,'9999999'));

       -- Step 4.
       -- execute the dynamic SQL  and Collect all privileges

       IF( l_instance_sets_list <> '( )') THEN
          code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                     ,p_module    => l_api_name
                     ,p_message   => 'Binds for Dynamic sql '||
                        ' l_object_id: '||l_object_id||
                        ' - l_user_name: '||l_user_name||
                        ' - G_TYPE_INSTANCE: '||G_TYPE_INSTANCE||
                        ' - p_instance_pk1_value: '||p_instance_pk1_value||
                        ' - p_instance_pk2_value: '||l_pk2_value||
                        ' - p_instance_pk3_value: '||l_pk3_value||
                        ' - p_instance_pk4_value: '||l_pk4_value||
                        ' - p_instance_pk5_value: '||l_pk5_value||
                        ' - l_object_id: '||l_object_id||
                        ' - l_user_name: '||l_user_name||
                        ' - G_TYPE_SET: '||G_TYPE_SET
                     );
         OPEN instance_set FOR l_dynamic_sql
         USING IN l_object_id,
               IN l_user_name,
               IN G_TYPE_INSTANCE,
               IN p_instance_pk1_value,
               IN l_pk2_value,
               IN l_pk3_value,
               IN l_pk4_value,
               IN l_pk5_value,
               IN l_object_id,
               IN l_user_name,
               IN G_TYPE_SET;
       ELSE
          code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                     ,p_module    => l_api_name
                     ,p_message   => 'Binds for Dynamic sql '||
                        ' l_object_id: '||l_object_id||
                        ' - l_user_name: '||l_user_name||
                        ' - G_TYPE_INSTANCE: '||G_TYPE_INSTANCE||
                        ' - p_instance_pk1_value: '||p_instance_pk1_value||
                        ' - p_instance_pk2_value: '||l_pk2_value||
                        ' - p_instance_pk3_value: '||l_pk3_value||
                        ' - p_instance_pk4_value: '||l_pk4_value||
                        ' - p_instance_pk5_value: '||l_pk5_value
                     );
         OPEN instance_set FOR l_dynamic_sql
         USING IN l_object_id,
               IN l_user_name,
               IN G_TYPE_INSTANCE,
               IN p_instance_pk1_value,
               IN l_pk2_value,
               IN l_pk3_value,
               IN l_pk4_value,
               IN l_pk5_value;
       END IF;

       LOOP
         FETCH instance_set  INTO l_privilege;
         --dbms_output.put_line('in executeing the dynamic sql');
         EXIT WHEN instance_set%NOTFOUND;
         l_index:=l_index+1;
         x_privilege_tbl  (l_index):=l_privilege;
         code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                    ,p_module    => l_api_name
                    ,p_message   => 'Privilege from profile at: '||l_index||' - privilege: '||l_privilege
                    );
       END LOOP;
       CLOSE instance_set;
--end_date:= DBMS_UTILITY.GET_TIME;
--millisec:= (end_date-start_date)*24*60*60*1000;
--dbms_output.put_line('5. Diff. in Get Time 100th of a sec ::'||to_char(end_date-start_date,'9999999'));

    IF x_privilege_tbl.count > 0 THEN
      x_return_status := G_RETURN_SUCCESS; /* Success */
      FOR i in x_privilege_tbl.first .. x_privilege_tbl.last LOOP
        code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                   ,p_module    => l_api_name
                   ,p_message   => 'Index : '||i||' - privilege: '||x_privilege_tbl(i)
                   );
      END LOOP;
    ELSE
      x_return_status := G_RETURN_FAILURE; /* No functions */
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
    --dbms_output.put_line('error :' || SQLERRM);
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE',G_PKG_NAME||l_api_name);
      fnd_message.set_token('ERRNO', SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      code_debug (p_log_level => G_DEBUG_LEVEL_UNEXPECTED
                 ,p_module    => l_api_name
                 ,p_message   => 'Ending: Returning OTHER ERROR '||SQLERRM
                 );
      x_return_status := G_RETURN_UNEXP_ERR;
  END get_functions;

--------------------------------------------------------
----    get_inherited_functions
--------------------------------------------------------
  PROCEDURE get_inherited_functions
  (
   p_api_version                 IN  NUMBER,
   p_object_name                 IN  VARCHAR2,
   p_instance_pk1_value          IN  VARCHAR2,
   p_instance_pk2_value          IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk3_value          IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk4_value          IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk5_value          IN  VARCHAR2 DEFAULT NULL,
   p_user_name                   IN  VARCHAR2 DEFAULT NULL,
   p_object_type                 IN  VARCHAR2 DEFAULT NULL,
   p_parent_object_name          IN  VARCHAR2,
   p_parent_instance_pk1_value   IN  VARCHAR2,
   p_parent_instance_pk2_value   IN  VARCHAR2 DEFAULT NULL,
   p_parent_instance_pk3_value   IN  VARCHAR2 DEFAULT NULL,
   p_parent_instance_pk4_value   IN  VARCHAR2 DEFAULT NULL,
   p_parent_instance_pk5_value   IN  VARCHAR2 DEFAULT NULL,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_privilege_tbl               OUT NOCOPY EGO_VARCHAR_TBL_TYPE
  )
  IS

    l_api_name        CONSTANT VARCHAR2(30) := 'GET_INHERITED_FUNCTIONS';

    -- On addition of any Required parameters the major version needs
    -- to change i.e. for eg. 1.X to 2.X.
    -- On addition of any Optional parameters the minor version needs
    -- to change i.e. for eg. X.6 to X.7.
    l_api_version     CONSTANT NUMBER := 1.0;
    l_sysdate                  DATE := Sysdate;

    l_index                    NUMBER;
    l_dynamic_sql              VARCHAR2(32767);
    l_common_dyn_sql           VARCHAR2(32767);
    l_set_dyn_sql              VARCHAR2(32767);
    l_inst_dyn_sql             VARCHAR2(32767);

    l_instance_id_col1         VARCHAR2(512);
    l_instance_id_col2         VARCHAR2(512);
    l_instance_id_col3         VARCHAR2(512);
    l_instance_id_col4         VARCHAR2(512);
    l_instance_id_col5         VARCHAR2(512);
    l_instance_sets_list       VARCHAR2(10000);
    l_privilege                VARCHAR2(480);
    l_select_query_part        VARCHAR2(3000);
    l_group_info               VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_company_info             VARCHAR2(32767); /* Must match g_pred_buf_size*/

    l_db_object_name           VARCHAR2(30);
    l_db_pk1_column            VARCHAR2(30);
    l_db_pk2_column            VARCHAR2(30);
    l_db_pk3_column            VARCHAR2(30);
    l_db_pk4_column            VARCHAR2(30);
    l_db_pk5_column            VARCHAR2(30);

    l_pk_column_names          VARCHAR2(512);
    l_pk_orig_column_names     VARCHAR2(512);
    l_type_converted_val_cols  VARCHAR2(512);
    l_parent_object_id         NUMBER;
    l_object_id                NUMBER;
    l_user_name                VARCHAR2(80);
--    l_orig_system              VARCHAR2(48);
    l_orig_system_id           NUMBER;

    l_return_status            VARCHAR2(1);
    l_privilege_tbl            EGO_PRIVILEGE_NAME_TABLE_TYPE;
    l_privilege_tbl_count      NUMBER;
    l_privilege_tbl_index      NUMBER;
    m_privilege_tbl            EGO_PRIVILEGE_NAME_TABLE_TYPE;
    m_privilege_tbl_count      NUMBER;
    m_privilege_tbl_index      NUMBER;
    x_index                    NUMBER;

    l_prof_privilege_tbl       EGO_VARCHAR_TBL_TYPE;
    l_profile_role             VARCHAR2(80);

    instance_set               DYNAMIC_CUR;
    candidate_sets_c           DYNAMIC_CUR;
    l_dynamic_sql_1            VARCHAR2(32767);
    l_one_set_predicate        VARCHAR2(32767);
    l_one_set_id               NUMBER;

  BEGIN
    SetGlobals();
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   =>  'Started with 17 params '||
       ' p_api_version: '|| to_char(p_api_version) ||
       ' - p_object_name: '|| p_object_name ||
       ' - p_instance_pk1_value: '|| p_instance_pk1_value ||
       ' - p_instance_pk2_value: '|| p_instance_pk2_value ||
       ' - p_instance_pk3_value: '|| p_instance_pk3_value ||
       ' - p_instance_pk4_value: '|| p_instance_pk4_value ||
       ' - p_instance_pk5_value: '|| p_instance_pk5_value ||
       ' - p_user_name: '|| p_user_name ||
       ' - p_object_type: '|| p_object_type ||
       ' - p_parent_object_name: '|| p_parent_object_name ||
       ' - p_parent_instance_pk1_value: '|| p_parent_instance_pk1_value ||
       ' - p_parent_instance_pk2_value: '|| p_parent_instance_pk2_value ||
       ' - p_parent_instance_pk3_value: '|| p_parent_instance_pk3_value ||
       ' - p_parent_instance_pk4_value: '|| p_parent_instance_pk4_value ||
       ' - p_parent_instance_pk5_value: '|| p_parent_instance_pk5_value
               );

    -- check for call compatibility.
    IF TRUNC(l_api_version) <> TRUNC(p_api_version) THEN
      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE', g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON', 'Unsupported version '||
                                      to_char(p_api_version)||
                                      ' passed to API; expecting version '||
                                      to_char(l_api_version));
      x_return_status := G_RETURN_UNEXP_ERR;
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning as the call in incompatible '
               );
      RETURN;
    END IF;

    x_return_status := G_RETURN_SUCCESS; /* Assume Success */
    l_user_name := p_user_name;
    get_orig_key(x_user_name      => l_user_name
--                ,x_orig_system    => l_orig_system
                ,x_orig_system_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_user_name: '||l_user_name||
--                               ' - l_orig_system: '||l_orig_system||
                               ' - l_orig_system_id: '||l_orig_system_id
               );

    -- get All privileges of a user on a given object
    --Step 1.
    -- get database object name and column
    -- cache the PK column name
    x_return_status := get_pk_information(p_parent_object_name,
                                          l_db_pk1_column,
                                          l_db_pk2_column,
                                          l_db_pk3_column,
                                          l_db_pk4_column,
                                          l_db_pk5_column,
                                          l_pk_column_names,
                                          l_type_converted_val_cols,
                                          l_pk_orig_column_names,
                                          l_db_object_name);
    if (x_return_status <> G_RETURN_SUCCESS) then
      /* There will be a message on the msg dict stack. */
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Ending: Returning Unable to get PK info '
                 );
      return;  /* We will return the x_return_status as out param */
    end if;

    -- Step 2.
    -- get instance set ids in which the given object_key exists
    -- as a set into l_instance_set

    l_group_info := get_group_info(p_party_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_group_info: '||l_group_info
               );
    l_company_info := get_company_info (p_party_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_company_info: '||l_company_info
               );
    l_object_id := get_object_id(p_object_name => p_object_name);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_object_id: '||l_object_id
               );
    l_parent_object_id:=get_object_id(p_object_name => p_parent_object_name);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_parent_object_id: '||l_parent_object_id
               );
    --R12C Security Changes
   /* l_select_query_part:=
             'SELECT '|| l_pk_column_names ||
             ' FROM  '|| l_db_object_name  ||
             ' WHERE ';*/
    IF (p_parent_object_name = 'EGO_ITEM') THEN
    l_select_query_part:=
             'SELECT '|| l_pk_column_names ||
             ' FROM  '|| l_db_object_name  ||', ego_item_cat_denorm_hier cathier'||
             ' WHERE ';
    ELSE
    l_select_query_part:=
             'SELECT '|| l_pk_column_names ||
             ' FROM  '|| l_db_object_name  ||
             ' WHERE ';
   END IF;
   --R12C Security Changes

    IF (l_db_pk1_column IS NOT NULL) THEN
       l_select_query_part := l_select_query_part ||
            ' ( '||l_db_pk1_column||' = :pk1_val '||
             ' OR ( '||l_db_pk1_column||' is NULL AND :pk1_val is NULL))';
    END IF;
    IF (l_db_pk2_column IS NOT NULL) THEN
       l_select_query_part := l_select_query_part ||
        ' AND (  '||l_db_pk2_column||' = :pk2_val '||
             ' OR ( '||l_db_pk2_column||' is NULL AND :pk2_val is NULL))';
    END IF;
    IF (l_db_pk3_column IS NOT NULL) THEN
       l_select_query_part := l_select_query_part ||
        ' AND ( '||l_db_pk3_column||' = :pk3_val '||
             ' OR ( '||l_db_pk3_column||' is NULL AND :pk3_val is NULL))';
    END IF;
    IF (l_db_pk4_column IS NOT NULL) THEN
       l_select_query_part := l_select_query_part ||
       ' AND ( '||l_db_pk4_column||' = :pk4_val '||
             ' OR ( '||l_db_pk4_column||' is NULL AND :pk4_val is NULL))';
    END IF;
    IF (l_db_pk5_column IS NOT NULL) THEN
       l_select_query_part := l_select_query_part ||
        ' AND ( '||l_db_pk5_column||' = :pk5_val '||
             ' OR ( '||l_db_pk5_column||' is NULL AND :pk5_val is NULL))';
    END IF;
    --R12C Security Changes
    --l_select_query_part := l_select_query_part || ' AND ';
    IF (p_parent_object_name = 'EGO_ITEM') THEN
        l_select_query_part := l_select_query_part || ' AND  item_catalog_group_id = cathier.child_catalog_group_id AND ';
    ELSE
        l_select_query_part := l_select_query_part || ' AND ';
    END IF;
    --R12C Security Changes
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'Select Query Part '||l_select_query_part
               );
    -------------------------------------------------------------------------------
    -- Now we build dynamic SQL using the work we just did to optimize the query --
    -------------------------------------------------------------------------------
    l_dynamic_sql_1 :=
    ' SELECT DISTINCT sets.instance_set_id, sets.predicate ' ||
      ' FROM fnd_grants grants, fnd_object_instance_sets sets' ||
      ' WHERE grants.object_id = :object_id ' ||
        ' AND grants.start_date <= SYSDATE ' ||
        ' AND NVL(grants.end_date,SYSDATE) >= SYSDATE '||
        ' AND grants.instance_type = :instance_type ' ||
        ' AND ( ( grants.grantee_type = ''USER'' AND '||
               ' grants.grantee_key = :user_name ) '||
               ' OR ( grants.grantee_type = ''GROUP'' AND '||
               ' grants.grantee_key in ( '||l_group_info||' ))' ||
               ' OR ( grants.grantee_type = ''COMPANY'' AND '||
               ' grants.grantee_key in ( '||l_company_info||' ))' ||
               ' OR (grants.grantee_type = ''GLOBAL'' AND '||
               ' grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL'') )) '||
      ' AND sets.instance_set_id = grants.instance_set_id ' ||
      ' AND sets.object_id = grants.object_id ';

    l_instance_sets_list := '';
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'Binds for get the candidate sets '||
                               ' l_parent_object_id: '||l_parent_object_id||
                               ' - G_TYPE_SET: '||G_TYPE_SET||
                               ' - l_user_name: '||l_user_name
               );
    OPEN candidate_sets_c FOR l_dynamic_sql_1
    USING IN l_parent_object_id,
          IN G_TYPE_SET,
          IN l_user_name;
    LOOP
      l_instance_id_col1 := '';
      l_instance_id_col2 := '';
      l_instance_id_col3 := '';
      l_instance_id_col4 := '';
      l_instance_id_col5 := '';

      FETCH candidate_sets_c INTO l_one_set_id, l_one_set_predicate;
      EXIT WHEN candidate_sets_c%NOTFOUND;

      l_dynamic_sql := l_select_query_part ||
                       ' (' ||  l_one_set_predicate || ') ';

      if(l_db_pk5_column is not NULL) then
        OPEN instance_set FOR l_dynamic_sql USING
        p_parent_instance_pk1_value, p_parent_instance_pk1_value,
        p_parent_instance_pk2_value, p_parent_instance_pk2_value,
        p_parent_instance_pk3_value, p_parent_instance_pk3_value,
        p_parent_instance_pk4_value, p_parent_instance_pk4_value,
        p_parent_instance_pk5_value, p_parent_instance_pk5_value;
      elsif(l_db_pk4_column is not NULL) then
        OPEN instance_set FOR l_dynamic_sql USING
        p_parent_instance_pk1_value, p_parent_instance_pk1_value,
        p_parent_instance_pk2_value, p_parent_instance_pk2_value,
        p_parent_instance_pk3_value, p_parent_instance_pk3_value,
        p_parent_instance_pk4_value, p_parent_instance_pk4_value;
      elsif(l_db_pk3_column is not NULL) then
        OPEN instance_set FOR l_dynamic_sql USING
        p_parent_instance_pk1_value, p_parent_instance_pk1_value,
        p_parent_instance_pk2_value, p_parent_instance_pk2_value,
        p_parent_instance_pk3_value, p_parent_instance_pk3_value;
      elsif(l_db_pk2_column is not NULL) then
        OPEN instance_set FOR l_dynamic_sql USING
        p_parent_instance_pk1_value, p_parent_instance_pk1_value,
        p_parent_instance_pk2_value, p_parent_instance_pk2_value;
      elsif(l_db_pk1_column is not NULL) then
        OPEN instance_set FOR l_dynamic_sql USING
        p_parent_instance_pk1_value, p_parent_instance_pk1_value;
      else
        x_return_status := G_RETURN_UNEXP_ERR;
        code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                   ,p_module    => l_api_name
                   ,p_message   => 'Ending: PK1 not available!! '
                   );
        return; /* This will never happen since pk1 is reqd*/
      end if;

      if (l_db_pk5_column is not null
      and l_db_pk4_column is not null
      and l_db_pk3_column is not null
      and l_db_pk2_column is not null
      and l_db_pk1_column is not null) then
        fetch instance_set into l_instance_id_col1, l_instance_id_col2,
                                l_instance_id_col3, l_instance_id_col4,
                                l_instance_id_col5;
        CLOSE instance_set;
        if (l_instance_id_col1 = p_parent_instance_pk1_value
        and l_instance_id_col2 = p_parent_instance_pk2_value
        and l_instance_id_col3 = p_parent_instance_pk3_value
        and l_instance_id_col4 = p_parent_instance_pk4_value
        and l_instance_id_col5 = p_parent_instance_pk5_value) THEN
          l_instance_sets_list := l_instance_sets_list || l_one_set_id || ',';
        end if;
      elsif (l_db_pk4_column is not null
      and l_db_pk3_column is not null
      and l_db_pk2_column is not null
      and l_db_pk1_column is not null) then
        fetch instance_set into l_instance_id_col1, l_instance_id_col2,
                                l_instance_id_col3, l_instance_id_col4;
        CLOSE instance_set;
        if (l_instance_id_col1 = p_parent_instance_pk1_value
        and l_instance_id_col2 = p_parent_instance_pk2_value
        and l_instance_id_col3 = p_parent_instance_pk3_value
        and l_instance_id_col4 = p_parent_instance_pk4_value) THEN
          l_instance_sets_list :=l_instance_sets_list || l_one_set_id || ',';
        end if;
      elsif (l_db_pk3_column is not null
      and l_db_pk2_column is not null
      and l_db_pk1_column is not null) then
        fetch instance_set into l_instance_id_col1, l_instance_id_col2, l_instance_id_col3;
        CLOSE instance_set;
        if (l_instance_id_col1 = p_parent_instance_pk1_value
        and l_instance_id_col2 = p_parent_instance_pk2_value
        and l_instance_id_col3 = p_parent_instance_pk3_value) THEN
          l_instance_sets_list := l_instance_sets_list || l_one_set_id || ',';
        end if;
      elsif (l_db_pk2_column is not null
      and l_db_pk1_column is not null) then
        fetch instance_set into l_instance_id_col1, l_instance_id_col2;
        CLOSE instance_set;
        if (l_instance_id_col1 = p_parent_instance_pk1_value
        and l_instance_id_col2 = p_parent_instance_pk2_value) THEN
          l_instance_sets_list := l_instance_sets_list || l_one_set_id || ',';
        end if;
      elsif l_db_pk1_column is not null then
        fetch instance_set into l_instance_id_col1;
        CLOSE instance_set;
        if (l_instance_id_col1 = p_parent_instance_pk1_value) THEN
          l_instance_sets_list := l_instance_sets_list || l_one_set_id || ',';
        end if;
      end if;

    END LOOP;
    -- if the last character is ',' then strip the trailing ','
    if (substr(l_instance_sets_list, length(l_instance_sets_list), length(',')) = ',') then
       l_instance_sets_list := substr(l_instance_sets_list, 1,
                               length(l_instance_sets_list) - length(','));
    end if;
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => ' Instance Sets List: '||l_instance_sets_list
               );

    l_common_dyn_sql := '';
    l_set_dyn_sql  := '';
    l_inst_dyn_sql := '';

    l_common_dyn_sql:=
       'SELECT DISTINCT fnd_functions.function_name ' ||
        ' FROM fnd_grants grants, ' ||
             ' fnd_form_functions fnd_functions, ' ||
             ' fnd_menu_entries cmf, '||
             ' ego_obj_role_mappings mapping '||
       ' WHERE grants.object_id = :object_id '||
         ' AND grants.start_date <= SYSDATE '||
         ' AND NVL(grants.end_date,SYSDATE) >= SYSDATE ' ||
         ' AND ( ( grants.grantee_type = ''USER'' AND ' ||
                ' grants.grantee_key = :user_name ) '||
             ' OR (grants.grantee_type = ''GROUP'' AND ' ||
                 ' grants.grantee_key in ( '||l_group_info||' )) ' ||
             ' OR (grants.grantee_type = ''COMPANY'' AND ' ||
                 ' grants.grantee_key in ( '||l_company_info||' )) ' ||
             ' OR (grants.grantee_type = ''GLOBAL'' AND ' ||
                 ' grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL'') ))'||
         ' AND mapping.child_role_id = cmf.menu_id ' ||
         ' AND mapping.parent_role_id = grants.menu_id ' ||
         ' AND mapping.child_object_id = :child_object_id ' ||
         ' AND mapping.parent_object_id = :parent_object_id ' ||
         ' AND mapping.child_object_type = :object_type ' ||
         ' AND cmf.function_id = fnd_functions.function_id ';

    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'Binds for common dyn sql '||
                               ' l_parent_object_id: '||l_parent_object_id||
                               ' - l_user_name: '||l_user_name||
                               ' - l_object_id: '||l_object_id||
                               ' - l_parent_object_id: '||l_parent_object_id||
                               ' - p_object_type: '||p_object_type
               );

    l_inst_dyn_sql :=
        ' AND ( grants.instance_type = :instance_type_instance ' ||
        ' AND grants.instance_pk1_value = :pk1_val ' ||
        ' AND ( grants.instance_pk2_value = :pk2_val OR' ||
        ' ( grants.instance_pk2_value = ''*NULL*'' AND :pk2_val is NULL )) '||
        ' AND ( grants.instance_pk3_value = :pk3_val OR '||
        ' ( grants.instance_pk3_value = ''*NULL*'' AND :pk3_val is NULL )) '||
        ' AND ( grants.instance_pk4_value = :pk4_val OR '||
        ' ( grants.instance_pk4_value = ''*NULL*'' AND :pk4_val is NULL )) '||
        ' AND ( grants.instance_pk5_value = :pk5_val OR '||
        ' ( grants.instance_pk5_value = ''*NULL*'' AND :pk5_val is NULL )) )';

    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'Binds for inst dyn sql '||
        ' G_TYPE_INSTANCE: '||G_TYPE_INSTANCE||
        ' - p_parent_instance_pk1_value: '||p_parent_instance_pk1_value||
        ' - p_parent_instance_pk2_value: '||p_parent_instance_pk2_value||
        ' - p_parent_instance_pk2_value: '||p_parent_instance_pk2_value||
        ' - p_parent_instance_pk3_value: '||p_parent_instance_pk3_value||
        ' - p_parent_instance_pk3_value: '||p_parent_instance_pk3_value||
        ' - p_parent_instance_pk4_value: '||p_parent_instance_pk4_value||
        ' - p_parent_instance_pk4_value: '||p_parent_instance_pk4_value||
        ' - p_parent_instance_pk5_value: '||p_parent_instance_pk5_value||
        ' - p_parent_instance_pk5_value: '||p_parent_instance_pk5_value
               );

      -- check whether it is empty set
      IF( LENGTH(l_instance_sets_list) > 0) THEN
         l_set_dyn_sql:=l_set_dyn_sql ||
             ' AND ( grants.instance_type = :instance_type_set ' ||
             ' AND grants.instance_set_id IN ('||l_instance_sets_list||' )) ';
         l_dynamic_sql := l_common_dyn_sql || l_inst_dyn_sql ||
                          ' UNION ' ||
                          l_common_dyn_sql || l_set_dyn_sql;

         code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                    ,p_module    => l_api_name
                    ,p_message   => 'Dynamic sql with sets and without profile '||l_dynamic_sql
                    );
          code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                     ,p_module    => l_api_name
                     ,p_message   => 'Binds for Dynamic sql with sets and without profile '||
        ' l_parent_object_id: '||l_parent_object_id||
        ' - l_user_name: '||l_user_name||
        ' - l_object_id: '||l_object_id||
        ' - l_parent_object_id: '||l_parent_object_id||
        ' - p_object_type: '||p_object_type||
        ' - G_TYPE_INSTANCE: '||G_TYPE_INSTANCE||
        ' - p_parent_instance_pk1_value: '||p_parent_instance_pk1_value||
        ' - p_parent_instance_pk2_value: '||p_parent_instance_pk2_value||
        ' - p_parent_instance_pk2_value: '||p_parent_instance_pk2_value||
        ' - p_parent_instance_pk3_value: '||p_parent_instance_pk3_value||
        ' - p_parent_instance_pk3_value: '||p_parent_instance_pk3_value||
        ' - p_parent_instance_pk4_value: '||p_parent_instance_pk4_value||
        ' - p_parent_instance_pk4_value: '||p_parent_instance_pk4_value||
        ' - p_parent_instance_pk5_value: '||p_parent_instance_pk5_value||
        ' - p_parent_instance_pk5_value: '||p_parent_instance_pk5_value||
        ' - l_parent_object_id: '||l_parent_object_id||
        ' - l_user_name: '||l_user_name||
        ' - l_object_id: '||l_object_id||
        ' - l_parent_object_id: '||l_parent_object_id||
        ' - p_object_type: '||p_object_type||
        ' - G_TYPE_SET: '||G_TYPE_SET
                     );

      ELSE
        l_dynamic_sql := l_common_dyn_sql || l_inst_dyn_sql;
         code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                    ,p_module    => l_api_name
                    ,p_message   => 'Dynamic sql without profile '||l_dynamic_sql
                    );
          code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                     ,p_module    => l_api_name
                     ,p_message   => 'Binds for Dynamic sql '||
        ' l_parent_object_id: '||l_parent_object_id||
        ' - l_user_name: '||l_user_name||
        ' - l_object_id: '||l_object_id||
        ' - l_parent_object_id: '||l_parent_object_id||
        ' - p_object_type: '||p_object_type||
        ' - G_TYPE_INSTANCE: '||G_TYPE_INSTANCE||
        ' - p_parent_instance_pk1_value: '||p_parent_instance_pk1_value||
        ' - p_parent_instance_pk2_value: '||p_parent_instance_pk2_value||
        ' - p_parent_instance_pk2_value: '||p_parent_instance_pk2_value||
        ' - p_parent_instance_pk3_value: '||p_parent_instance_pk3_value||
        ' - p_parent_instance_pk3_value: '||p_parent_instance_pk3_value||
        ' - p_parent_instance_pk4_value: '||p_parent_instance_pk4_value||
        ' - p_parent_instance_pk4_value: '||p_parent_instance_pk4_value||
        ' - p_parent_instance_pk5_value: '||p_parent_instance_pk5_value||
        ' - p_parent_instance_pk5_value: '||p_parent_instance_pk5_value
                     );
      END IF;

     -------------------------------------------------
     -- we see if a profile option is set and if so --
     -- we add it to the other list of menus        --
     -------------------------------------------------
     l_profile_role := getRole_mappedTo_profileOption(p_parent_object_name, p_user_name);
     code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                ,p_module    => l_api_name
                ,p_message   => 'profile role for '||p_parent_object_name||
                                ' is: '||l_profile_role
                );

     IF (l_profile_role is not null) THEN
       l_dynamic_sql:= l_dynamic_sql ||
            ' UNION ' ||
            ' SELECT DISTINCT fnd_functions.function_name ' ||
              ' FROM fnd_form_functions fnd_functions, ' ||
                   ' fnd_menu_entries cmf, ' ||
                   ' ego_obj_role_mappings mapping, ' ||
                   ' fnd_menus menus ' ||
            ' WHERE menus.menu_name = :profile_role ' ||
              ' AND mapping.parent_role_id = menus.menu_id ' ||
              ' AND mapping.child_role_id = cmf.menu_id ' ||
              ' AND mapping.child_object_id = :profile_ch_object_id ' ||
              ' AND mapping.parent_object_id = :profile_parent_object_id ' ||
              ' AND mapping.child_object_type = :profile_ch_object_type ' ||
              ' AND cmf.function_id = fnd_functions.function_id ';
     END IF;

     -- Step 4.
     -- execute the dynamic SQL  and Collect all privileges
    l_index:=0;
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'Final Dynamic sql '||l_dynamic_sql
               );
    IF( LENGTH(l_instance_sets_list) > 0) THEN
      IF l_profile_role IS NOT NULL THEN
          code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                     ,p_module    => l_api_name
                     ,p_message   => 'Binds for Final Dynamic sql: '||
        ' l_parent_object_id: '||l_parent_object_id||
        ' - l_user_name: '||l_user_name||
        ' - l_object_id: '||l_object_id||
        ' - l_parent_object_id: '||l_parent_object_id||
        ' - p_object_type: '||p_object_type||
        ' - G_TYPE_INSTANCE: '||G_TYPE_INSTANCE||
        ' - p_parent_instance_pk1_value: '||p_parent_instance_pk1_value||
        ' - p_parent_instance_pk2_value: '||p_parent_instance_pk2_value||
        ' - p_parent_instance_pk2_value: '||p_parent_instance_pk2_value||
        ' - p_parent_instance_pk3_value: '||p_parent_instance_pk3_value||
        ' - p_parent_instance_pk3_value: '||p_parent_instance_pk3_value||
        ' - p_parent_instance_pk4_value: '||p_parent_instance_pk4_value||
        ' - p_parent_instance_pk4_value: '||p_parent_instance_pk4_value||
        ' - p_parent_instance_pk5_value: '||p_parent_instance_pk5_value||
        ' - p_parent_instance_pk5_value: '||p_parent_instance_pk5_value||
        ' - l_parent_object_id: '||l_parent_object_id||
        ' - l_user_name: '||l_user_name||
        ' - l_object_id: '||l_object_id||
        ' - l_parent_object_id: '||l_parent_object_id||
        ' - p_object_type: '||p_object_type||
        ' - G_TYPE_SET: '||G_TYPE_SET||
        ' - l_profile_role: '||l_profile_role||
        ' - l_object_id: '||l_object_id||
        ' - l_parent_object_id: '||l_parent_object_id||
        ' - p_object_type: '||p_object_type
                     );
        OPEN instance_set FOR l_dynamic_sql
        USING IN l_parent_object_id,
              IN l_user_name,
              IN l_object_id,
              IN l_parent_object_id,
              IN p_object_type,
              IN G_TYPE_INSTANCE,
              IN p_parent_instance_pk1_value,
              IN p_parent_instance_pk2_value,
              IN p_parent_instance_pk2_value,
              IN p_parent_instance_pk3_value,
              IN p_parent_instance_pk3_value,
              IN p_parent_instance_pk4_value,
              IN p_parent_instance_pk4_value,
              IN p_parent_instance_pk5_value,
              IN p_parent_instance_pk5_value,
              IN l_parent_object_id,
              IN l_user_name,
              IN l_object_id,
              IN l_parent_object_id,
              IN p_object_type,
              IN G_TYPE_SET,
              IN l_profile_role,
              IN l_object_id,
              IN l_parent_object_id,
              IN p_object_type;
      ELSE
          code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                     ,p_module    => l_api_name
                     ,p_message   => 'Binds for Final Dynamic sql: '||
        ' l_parent_object_id: '||l_parent_object_id||
        ' - l_user_name: '||l_user_name||
        ' - l_object_id: '||l_object_id||
        ' - l_parent_object_id: '||l_parent_object_id||
        ' - p_object_type: '||p_object_type||
        ' - G_TYPE_INSTANCE: '||G_TYPE_INSTANCE||
        ' - p_parent_instance_pk1_value: '||p_parent_instance_pk1_value||
        ' - p_parent_instance_pk2_value: '||p_parent_instance_pk2_value||
        ' - p_parent_instance_pk2_value: '||p_parent_instance_pk2_value||
        ' - p_parent_instance_pk3_value: '||p_parent_instance_pk3_value||
        ' - p_parent_instance_pk3_value: '||p_parent_instance_pk3_value||
        ' - p_parent_instance_pk4_value: '||p_parent_instance_pk4_value||
        ' - p_parent_instance_pk4_value: '||p_parent_instance_pk4_value||
        ' - p_parent_instance_pk5_value: '||p_parent_instance_pk5_value||
        ' - p_parent_instance_pk5_value: '||p_parent_instance_pk5_value||
        ' - l_parent_object_id: '||l_parent_object_id||
        ' - l_user_name: '||l_user_name||
        ' - l_object_id: '||l_object_id||
        ' - l_parent_object_id: '||l_parent_object_id||
        ' - p_object_type: '||p_object_type||
        ' - G_TYPE_SET: '||G_TYPE_SET
                     );
        OPEN instance_set FOR l_dynamic_sql
        USING IN l_parent_object_id,
              IN l_user_name,
              IN l_object_id,
              IN l_parent_object_id,
              IN p_object_type,
              IN G_TYPE_INSTANCE,
              IN p_parent_instance_pk1_value,
              IN p_parent_instance_pk2_value,
              IN p_parent_instance_pk2_value,
              IN p_parent_instance_pk3_value,
              IN p_parent_instance_pk3_value,
              IN p_parent_instance_pk4_value,
              IN p_parent_instance_pk4_value,
              IN p_parent_instance_pk5_value,
              IN p_parent_instance_pk5_value,
              IN l_parent_object_id,
              IN l_user_name,
              IN l_object_id,
              IN l_parent_object_id,
              IN p_object_type,
              IN G_TYPE_SET;
      END IF;
    ELSE
      IF l_profile_role IS NOT NULL THEN
          code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                     ,p_module    => l_api_name
                     ,p_message   => 'Binds for Final Dynamic sql: '||
        ' l_parent_object_id: '||l_parent_object_id||
        ' - l_user_name: '||l_user_name||
        ' - l_object_id: '||l_object_id||
        ' - l_parent_object_id: '||l_parent_object_id||
        ' - p_object_type: '||p_object_type||
        ' - G_TYPE_INSTANCE: '||G_TYPE_INSTANCE||
        ' - p_parent_instance_pk1_value: '||p_parent_instance_pk1_value||
        ' - p_parent_instance_pk2_value: '||p_parent_instance_pk2_value||
        ' - p_parent_instance_pk2_value: '||p_parent_instance_pk2_value||
        ' - p_parent_instance_pk3_value: '||p_parent_instance_pk3_value||
        ' - p_parent_instance_pk3_value: '||p_parent_instance_pk3_value||
        ' - p_parent_instance_pk4_value: '||p_parent_instance_pk4_value||
        ' - p_parent_instance_pk4_value: '||p_parent_instance_pk4_value||
        ' - p_parent_instance_pk5_value: '||p_parent_instance_pk5_value||
        ' - p_parent_instance_pk5_value: '||p_parent_instance_pk5_value||
        ' - l_profile_role: '||l_profile_role||
        ' - l_object_id: '||l_object_id||
        ' - l_parent_object_id: '||l_parent_object_id||
        ' - p_object_type: '||p_object_type
                     );
        OPEN instance_set FOR l_dynamic_sql
        USING IN l_parent_object_id,
              IN l_user_name,
              IN l_object_id,
              IN l_parent_object_id,
              IN p_object_type,
              IN G_TYPE_INSTANCE,
              IN p_parent_instance_pk1_value,
              IN p_parent_instance_pk2_value,
              IN p_parent_instance_pk2_value,
              IN p_parent_instance_pk3_value,
              IN p_parent_instance_pk3_value,
              IN p_parent_instance_pk4_value,
              IN p_parent_instance_pk4_value,
              IN p_parent_instance_pk5_value,
              IN p_parent_instance_pk5_value,
              IN l_profile_role,
              IN l_object_id,
              IN l_parent_object_id,
              IN p_object_type;
      ELSE
          code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                     ,p_module    => l_api_name
                     ,p_message   => 'Binds for Final Dynamic sql: '||
        ' l_parent_object_id: '||l_parent_object_id||
        ' - l_user_name: '||l_user_name||
        ' - l_object_id: '||l_object_id||
        ' - l_parent_object_id: '||l_parent_object_id||
        ' - p_object_type: '||p_object_type||
        ' - G_TYPE_INSTANCE: '||G_TYPE_INSTANCE||
        ' - p_parent_instance_pk1_value: '||p_parent_instance_pk1_value||
        ' - p_parent_instance_pk2_value: '||p_parent_instance_pk2_value||
        ' - p_parent_instance_pk2_value: '||p_parent_instance_pk2_value||
        ' - p_parent_instance_pk3_value: '||p_parent_instance_pk3_value||
        ' - p_parent_instance_pk3_value: '||p_parent_instance_pk3_value||
        ' - p_parent_instance_pk4_value: '||p_parent_instance_pk4_value||
        ' - p_parent_instance_pk4_value: '||p_parent_instance_pk4_value||
        ' - p_parent_instance_pk5_value: '||p_parent_instance_pk5_value||
        ' - p_parent_instance_pk5_value: '||p_parent_instance_pk5_value
                     );
        OPEN instance_set FOR l_dynamic_sql
        USING IN l_parent_object_id,
              IN l_user_name,
              IN l_object_id,
              IN l_parent_object_id,
              IN p_object_type,
              IN G_TYPE_INSTANCE,
              IN p_parent_instance_pk1_value,
              IN p_parent_instance_pk2_value,
              IN p_parent_instance_pk2_value,
              IN p_parent_instance_pk3_value,
              IN p_parent_instance_pk3_value,
              IN p_parent_instance_pk4_value,
              IN p_parent_instance_pk4_value,
              IN p_parent_instance_pk5_value,
              IN p_parent_instance_pk5_value;
      END IF;
    END IF;

    LOOP
      FETCH instance_set  INTO l_privilege;
      EXIT WHEN instance_set%NOTFOUND;
      m_privilege_tbl  (l_index):=l_privilege;
      l_index:=l_index+1;
    END LOOP;
    CLOSE instance_set;


    -- Step 5.
    -- get all the profile option privileges for the parent object type
    --and add to m_privilege_tbl
    get_role_functions
         (p_api_version     => p_api_version
         ,p_role_name       => l_profile_role
         ,x_return_status   => x_return_status
         ,x_privilege_tbl   => l_prof_privilege_tbl
         );
    IF (x_return_status = G_RETURN_SUCCESS) THEN
        IF (l_prof_privilege_tbl.COUNT > 0) THEN
          FOR i IN l_prof_privilege_tbl.first .. l_prof_privilege_tbl.last LOOP
                m_privilege_tbl(l_index) := l_prof_privilege_tbl(i);
                l_index:=l_index+1;
          END LOOP;
        END IF; -- x_prof_privilege_tbl >0
    END IF; --return status is T
    --end of getting privileges from profile option

    -- last step, get object function list itself to append
    get_functions(p_api_version        => 1.0,
                  p_object_name        => p_object_name,
                  p_instance_pk1_value => p_instance_pk1_value,
                  p_instance_pk2_value => p_instance_pk2_value,
                  p_instance_pk3_value => p_instance_pk3_value,
                  p_instance_pk4_value => p_instance_pk4_value,
                  p_instance_pk5_value => p_instance_pk5_value,
                  p_user_name          => l_user_name,
                  x_return_status      => l_return_status,
                  x_privilege_tbl      => l_privilege_tbl);

    l_privilege_tbl_count := l_privilege_tbl.COUNT;
    if (l_privilege_tbl_count > 0) then
      FOR i IN l_privilege_tbl.first .. l_privilege_tbl.last
      LOOP
        m_privilege_tbl(l_index):=l_privilege_tbl(i);
        l_index:=l_index+1;
      END LOOP;
    end if;

    m_privilege_tbl_count := m_privilege_tbl.COUNT;

    x_privilege_tbl := EGO_VARCHAR_TBL_TYPE();

    x_index := 0;
    if (m_privilege_tbl_count > 0) then
       x_privilege_tbl.extend(m_privilege_tbl_count);
       FOR i IN m_privilege_tbl.first .. m_privilege_tbl.last LOOP
          x_privilege_tbl(i+1) := m_privilege_tbl(i);
          --x_index := x_index+1;
       END LOOP;
    end if;

  -- last step done
    if(x_privilege_tbl.COUNT > 0) then
      x_return_status := G_RETURN_SUCCESS; /* Success */
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning Previleges '
                 );
      FOR i in x_privilege_tbl.first .. x_privilege_tbl.last LOOP
        code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                   ,p_module    => l_api_name
                   ,p_message   => 'Index : '||i||' - privilege: '||x_privilege_tbl(i)
                   );
      END LOOP;
    else
      x_return_status := G_RETURN_FAILURE; /* No functions */
    end if;
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   => 'Ending: with status: ' ||x_return_status
               );

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE',G_PKG_NAME||l_api_name);
      fnd_message.set_token('ERRNO', SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      x_return_status := G_RETURN_UNEXP_ERR;
      code_debug (p_log_level => G_DEBUG_LEVEL_UNEXPECTED
                 ,p_module    => l_api_name
                 ,p_message   => 'Ending: Returning OTHER ERROR '||SQLERRM
                 );
  END get_inherited_functions;

--------------------------------------------------------
----    get_security_predicate
--------------------------------------------------------
-- The code changes are added to procedure get_security_predicate should be
-- added to procedure get_security_predicate_clob as well
  PROCEDURE get_security_predicate
  (
    p_api_version                IN  NUMBER,
    p_function                   IN  VARCHAR2 default null,
    p_object_name                IN  VARCHAR2,
    p_grant_instance_type        IN  VARCHAR2 DEFAULT 'UNIVERSAL',/* SET, INSTANCE*/
    p_user_name                  IN  VARCHAR2 default null,
    /* stmnt_type: 'OTHER', 'BASE'=VPD, 'EXISTS'= for checking existence. */
    p_statement_type             IN  VARCHAR2 DEFAULT 'OTHER',
    p_pk1_alias                  IN  VARCHAR2 DEFAULT NULL,
    p_pk2_alias                  IN  VARCHAR2 DEFAULT NULL,
    p_pk3_alias                  IN  VARCHAR2 DEFAULT NULL,
    p_pk4_alias                  IN  VARCHAR2 DEFAULT NULL,
    p_pk5_alias                  IN  VARCHAR2 DEFAULT NULL,
    x_predicate                  OUT NOCOPY VARCHAR2,
    x_return_status              OUT NOCOPY VARCHAR2
  )  IS
    l_api_name          CONSTANT VARCHAR2(30)  := 'GET_SECURITY_PREDICATE';

        -- On addition of any Required parameters the major version needs
        -- to change i.e. for eg. 1.X to 2.X.
        -- On addition of any Optional parameters the minor version needs
        -- to change i.e. for eg. X.6 to X.7.
    l_api_version       CONSTANT NUMBER := 1.0;
    l_sysdate                    DATE := Sysdate;
    l_aggregate_predicate        VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_instance_flag              BOOLEAN   DEFAULT TRUE;
    l_instance_set_flag          BOOLEAN   DEFAULT TRUE;
    l_set_predicates             VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_db_object_name             VARCHAR2(30);
    l_db_pk1_column              VARCHAR2(61);
    l_db_pk2_column              VARCHAR2(61);
    l_db_pk3_column              VARCHAR2(61);
    l_db_pk4_column              VARCHAR2(61);
    l_db_pk5_column              VARCHAR2(61);
    l_pk_column_names            VARCHAR2(512);
    l_pk_orig_column_names       VARCHAR2(512);
    l_pk_orig_column_names_t     VARCHAR2(513);
    l_orig_pk1_column            VARCHAR2(61);
    l_orig_pk2_column            VARCHAR2(61);
    l_orig_pk3_column            VARCHAR2(61);
    l_orig_pk4_column            VARCHAR2(61);
    l_orig_pk5_column            VARCHAR2(61);
    l_type_converted_val_cols    VARCHAR2(512);
    l_user_name                  VARCHAR2(80);
--    l_orig_system                VARCHAR2(48);
    l_orig_system_id             NUMBER;

    l_group_info                 VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_company_info               VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_object_id                  NUMBER;

    instance_set_grants_c        DYNAMIC_CUR;
    l_dynamic_sql_1              VARCHAR2(32767);
    l_set_predicate_segment      VARCHAR2(32767);
    l_prof_privilege_tbl         EGO_VARCHAR_TBL_TYPE;

  BEGIN
    SetGlobals();
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   =>  'Started with 13 params '||
                   ' p_api_version: '|| to_char(p_api_version) ||
                   ' - p_function: '|| p_function ||
                   ' - p_object_name: '|| p_object_name ||
                   ' - p_grant_instance_type: '|| p_grant_instance_type ||
                   ' - p_statement_type: '|| p_statement_type ||
                   ' - p_pk1_alias: '|| p_pk1_alias ||
                   ' - p_pk2_alias: '|| p_pk2_alias ||
                   ' - p_pk3_alias: '|| p_pk3_alias ||
                   ' - p_pk4_alias: '|| p_pk4_alias ||
                   ' - p_pk5_alias: '|| p_pk5_alias
               );

    -- check for call compatibility.
    if TRUNC(l_api_version) <> TRUNC(p_api_version) THEN
      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE', g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON', 'Unsupported version '|| to_char(p_api_version)||
                                      ' passed to API; expecting version '||
                                      to_char(l_api_version));
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning as the call in incompatible '
                 );
      x_return_status := G_RETURN_UNEXP_ERR; /* Unexpected Error */
      RETURN;
    END IF;

    -- Check to make sure we're not using unsupported statement_type
    if (p_statement_type NOT IN  ('BASE', 'OTHER', 'EXISTS')) then
      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE', g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON', 'Unsupported p_statement_type: '|| p_statement_type);
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning as statement type is not supported'
                 );
      x_return_status := G_RETURN_UNEXP_ERR; /* Unexpected Error */
      return;
    end if;

    /* ### We haven't yet added support for NULL (all) function in arg. */
    /* ### Add that support since it is in the API. */
    if (p_function is NULL) then
      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE', g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON', 'Support has not yet been added for passing NULL function.');
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning as mand parameter Function is not available '
                 );
      x_return_status := G_RETURN_UNEXP_ERR; /* Unexpected Error */
      return;
    end if;

    -- Check to make sure we're not using unsupported modes
    if ((p_grant_instance_type = 'SET')
    AND((p_pk1_alias is not NULL)
        OR (p_pk2_alias is not NULL)
        OR (p_pk3_alias is not NULL)
        OR (p_pk4_alias is not NULL)
        OR (p_pk5_alias is not NULL))) then

      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE', g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON', 'Unsupported mode arguments: '||
                            ' p_grant_instance_type = SET.');
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning as incompatible combination for p_grant_instance_type = SET  '
                 );
      x_return_status := G_RETURN_UNEXP_ERR; /* Unexpected Error */
      return;
    end if;

    /* We don't currently support BASE mode; we will have to change to */
    /* a pure OR statement when VPD becomes important. */
    if (p_statement_type = 'BASE') then
      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE', g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON', 'Support has not yet been added for '|| 'p_statement_type = BASE.');
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning as incompatible statement_type = BASE '
                 );
      x_return_status := G_RETURN_UNEXP_ERR; /* Unexpected Error */
      return;
    end if;

     x_return_status := G_RETURN_SUCCESS; /* Assume Success */
    l_user_name := p_user_name;
    get_orig_key(x_user_name      => l_user_name
--                ,x_orig_system    => l_orig_system
                ,x_orig_system_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_user_name: '||l_user_name||
--                               ' - l_orig_system: '||l_orig_system||
                               ' - l_orig_system_id: '||l_orig_system_id
               );

    -----------------------------------------------------------------------------------
    --First we see if a profile option is set and if function exists                                 --
    -- if so we return and empty predicate here itself without doing further query   --
    -----------------------------------------------------------------------------------

    getPrivilege_for_profileOption(p_api_version         => p_api_version,
                         p_object_name       => p_object_name,
                         p_user_name         => p_user_name,
                         x_privilege_tbl   => l_prof_privilege_tbl,
                         x_return_status   => x_return_status);

    IF (x_return_status = G_RETURN_SUCCESS) THEN
      IF (l_prof_privilege_tbl.COUNT > 0) THEN
        FOR i IN l_prof_privilege_tbl.first .. l_prof_privilege_tbl.last LOOP
          IF (l_prof_privilege_tbl(i) = p_function) THEN
            x_predicate := '';
            code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                       ,p_module    => l_api_name
                       ,p_message   => 'No need for predicate as user has privilege through profile '
                       );
            RETURN;
          END IF; --if function match, returning empty predicate
        END LOOP;
      END IF; -- x_prof_privilege_tbl >0
    END IF; --return status is T

    -- Step 1.
    -- check whether there is any grant for this use for any role that
    -- includes the given privilege

    IF (p_grant_instance_type = G_TYPE_INSTANCE) THEN
      l_instance_set_flag:= FALSE;
    ELSIF (p_grant_instance_type = G_TYPE_SET) THEN
      l_instance_flag:= FALSE;
    END IF;

    x_return_status := get_pk_information(p_object_name  ,
                                          l_db_pk1_column  ,
                                          l_db_pk2_column  ,
                                          l_db_pk3_column  ,
                                          l_db_pk4_column  ,
                                          l_db_pk5_column  ,
                                          l_pk_column_names  ,
                                          l_type_converted_val_cols  ,
                                          l_pk_orig_column_names,
                                          l_db_object_name,
                                          p_pk1_alias,
                                          p_pk2_alias,
                                          p_pk3_alias,
                                          p_pk4_alias,
                                          p_pk5_alias );
    if (x_return_status <> G_RETURN_SUCCESS) then
      /* There will be a message on the msg dict stack. */
      return;  /* We will return the x_return_status as out param */
    end if;

    l_object_id := get_object_id(p_object_name => p_object_name);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_object_id: '||l_object_id
               );
    l_company_info := get_company_info (p_party_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_company_info: '||l_company_info
               );
    l_group_info := get_group_info(p_party_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_group_info: '||l_group_info
               );

    -- Step 2.
    l_aggregate_predicate := '';
    IF(l_instance_flag = TRUE) THEN
      if (p_statement_type = 'EXISTS') then
        l_aggregate_predicate := 'EXISTS ( SELECT ''X'' ';
      else
        l_aggregate_predicate := l_pk_column_names || ' IN ( SELECT ' ||l_type_converted_val_cols;
      end if;

      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                ,p_module    => l_api_name
                ,p_message   => 'l_aggregate_predicate : '||l_aggregate_predicate
                );


      if (p_statement_type = 'EXISTS') then
      --R12C Security Changes
           /*   l_aggregate_predicate := l_aggregate_predicate ||
              ' FROM fnd_grants grants,  fnd_form_functions functions, fnd_menu_entries cmf ' ||
              ' WHERE grants.INSTANCE_PK1_VALUE=to_char('||p_pk1_alias||')'; */
     if (p_object_name = 'EGO_CATALOG_GROUP') THEN
         l_aggregate_predicate := l_aggregate_predicate ||
              ' FROM fnd_grants grants,  fnd_form_functions functions, fnd_menu_entries cmf, ego_item_cat_denorm_hier cathier ' ||
              ' WHERE grants.INSTANCE_PK1_VALUE=to_char(cathier.parent_catalog_group_id) AND cathier.child_catalog_group_id = to_char('||p_pk1_alias||')';
     else
               l_aggregate_predicate := l_aggregate_predicate ||
              ' FROM fnd_grants grants,  fnd_form_functions functions, fnd_menu_entries cmf ' ||
              ' WHERE grants.INSTANCE_PK1_VALUE=to_char('||p_pk1_alias||')';
     end if;
      --R12C Security Changes
      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                ,p_module    => l_api_name
                ,p_message   => 'l_aggregate_predicate : '||l_aggregate_predicate
                );

        if(p_pk2_alias is not null) then
           l_aggregate_predicate := l_aggregate_predicate || ' AND grants.INSTANCE_PK2_VALUE=to_char('||p_pk2_alias||')';
        end if;

        if(p_pk3_alias is not null) then
           l_aggregate_predicate := l_aggregate_predicate || ' AND grants.INSTANCE_PK3_VALUE=to_char('||p_pk3_alias||')';
        end if;

        if(p_pk4_alias is not null) then
           l_aggregate_predicate := l_aggregate_predicate || ' AND grants.INSTANCE_PK4_VALUE=to_char('||p_pk4_alias||')';
        end if;

        if(p_pk5_alias is not null) then
           l_aggregate_predicate := l_aggregate_predicate || ' AND grants.INSTANCE_PK5_VALUE=to_char('||p_pk5_alias||')';
        end if;

        l_aggregate_predicate := l_aggregate_predicate ||
        ' AND grants.start_date <= sysdate ';

      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                ,p_module    => l_api_name
                ,p_message   => 'l_aggregate_predicate : '||l_aggregate_predicate
                );
      else
         l_aggregate_predicate := l_aggregate_predicate ||
        ' FROM fnd_grants grants,  fnd_form_functions functions, fnd_menu_entries cmf ' ||
        ' WHERE grants.start_date <= sysdate ';
        code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                ,p_module    => l_api_name
                ,p_message   => 'l_aggregate_predicate : '||l_aggregate_predicate
                );
      end if;

      l_aggregate_predicate :=
      l_aggregate_predicate ||
          ' AND (grants.end_date IS NULL OR grants.end_date >= sysdate) ' ||
          ' AND grants.instance_type = ''INSTANCE'' ' ||
          ' AND cmf.function_id = functions.function_id ' ||
          ' AND cmf.menu_id = grants.menu_id ' ||
          ' AND grants.object_id = ' || l_object_id ||
          ' AND functions.function_name = ''' || p_function || '''' ||
          ' AND ((grants.grantee_type = ''USER'' ' ||
                ' AND grants.grantee_key = '''||l_user_name||''')'||
               ' OR (grants.grantee_type = ''GROUP'' '||
                   ' AND grants.grantee_key in ('|| l_group_info || ')) ' ||
               ' OR (grants.grantee_type = ''COMPANY'' '||
                   ' AND grants.grantee_key in ('|| l_company_info || ')) ' ||
               ' OR (grants.grantee_type = ''GLOBAL'' ' ||
                   ' AND grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL''))))';
      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'l_aggregate_predicate: '||l_aggregate_predicate
                 );
    END IF;
    -- Step 3.
    l_set_predicates := '';
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                ,p_module    => l_api_name
                ,p_message   => 'l_set_predicates : '||l_set_predicates
                );
    IF (l_instance_set_flag = TRUE) THEN
      -------------------------------------------------------------------------------
      -- Now we build dynamic SQL using the work we just did to optimize the query --
      -------------------------------------------------------------------------------
      l_dynamic_sql_1 :=
      ' SELECT DISTINCT instance_sets.predicate ' ||
        ' FROM fnd_grants grants, fnd_form_functions functions, ' ||
             ' fnd_menu_entries cmf, fnd_object_instance_sets instance_sets ' ||
       ' WHERE grants.instance_type = :instance_type ' ||
         ' AND grants.start_date <= SYSDATE ' ||
         ' AND NVL(grants.end_date,SYSDATE) >= SYSDATE ' ||
         ' AND cmf.function_id = functions.function_id ' ||
         ' AND cmf.menu_id = grants.menu_id ' ||
         ' AND grants.instance_set_id = instance_sets.instance_set_id ' ||
         ' AND grants.object_id = :object_id ' ||
         ' AND functions.function_name = :function ' ||
         ' AND ((grants.grantee_type = ''USER'' ' ||
               ' AND grants.grantee_key = :grantee_key )' ||
              ' OR (grants.grantee_type = ''GROUP'' ' ||
                  ' AND grants.grantee_key in ('||l_group_info||' ))' ||
              ' OR (grants.grantee_type = ''COMPANY'' ' ||
                  ' AND grants.grantee_key in ( '||l_company_info||' ))' ||
              ' OR (grants.grantee_type = ''GLOBAL'' ' ||
                  ' AND grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL''))) ';
      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'Binds for instance_set_grants_c '||
                   ' G_TYPE_SET: '||G_TYPE_SET||
                   ' - l_parent_object_id: '||l_object_id||
                   ' - p_function: '||p_function||
                   ' - l_user_name: '||l_user_name
                 );

     code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                ,p_module    => l_api_name
                ,p_message   => 'l_dynamic_sql_1 : '||l_dynamic_sql_1
                );
      OPEN instance_set_grants_c FOR l_dynamic_sql_1
      USING IN G_TYPE_SET,
            IN l_object_id,
            IN p_function,
            IN l_user_name;
      LOOP
        FETCH instance_set_grants_c into l_set_predicate_segment;
        EXIT WHEN instance_set_grants_c%NOTFOUND;

        code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                ,p_module    => l_api_name
                ,p_message   => 'l_set_predicates : '||l_set_predicates
                );
         code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                ,p_module    => l_api_name
                ,p_message   => 'l_set_predicate_segment : '||l_set_predicate_segment
                );
        l_set_predicates := substrb(l_set_predicates ||
                            l_set_predicate_segment ||
                            ' OR ',
                            1, g_pred_buf_size);
         code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                ,p_module    => l_api_name
                ,p_message   => 'l_set_predicates : '||l_set_predicates
                );
      END LOOP;
      CLOSE instance_set_grants_c;
      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'l_set_predicates: '||l_set_predicates
                 );

      IF(length(l_set_predicates) > 0) THEN
        -- strip off the trailing 'OR '
        l_set_predicates := substr(l_set_predicates, 1,
                            length(l_set_predicates) - length('OR '));

        IF(length(l_aggregate_predicate) > 0) THEN
          -- strip off the trailing ')'
          l_aggregate_predicate := substr(l_aggregate_predicate, 1,
                                   length(l_aggregate_predicate) - length(')'));
          if (p_statement_type = 'EXISTS') then
             l_pk_orig_column_names_t := l_pk_orig_column_names||',';
             l_orig_pk1_column  := SUBSTR(l_pk_orig_column_names_t, 1, INSTR(l_pk_orig_column_names_t,',',1,1)-1);
        --R12C Security Changes
             /*l_aggregate_predicate := substrb(l_aggregate_predicate ||
                                           ' UNION ALL (SELECT ''X'' ' || ' FROM ' ||
                                           l_db_object_name || ' WHERE ' ||
                                           l_orig_pk1_column || '=' || p_pk1_alias, 1, g_pred_buf_size);*/

             IF (p_object_name = 'EGO_ITEM') THEN
             l_aggregate_predicate := substrb(l_aggregate_predicate ||
                                           ' UNION ALL (SELECT ''X'' ' || ' FROM ' ||
                                           l_db_object_name ||', ego_item_cat_denorm_hier cathier WHERE item_catalog_group_id = cathier.child_catalog_group_id AND ' ||
                                           l_orig_pk1_column || '=' || p_pk1_alias, 1, g_pred_buf_size);

             ELSE
             l_aggregate_predicate := substrb(l_aggregate_predicate ||
                                           ' UNION ALL (SELECT ''X'' ' || ' FROM ' ||
                                           l_db_object_name || ' WHERE ' ||
                                           l_orig_pk1_column || '=' || p_pk1_alias, 1, g_pred_buf_size);
             END IF;
        --R12C Security Changes

              code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                ,p_module    => l_api_name
                ,p_message   => 'l_set_predicates : '||l_set_predicates
                );
             if(p_pk2_alias is not null) then
                 l_orig_pk2_column := SUBSTR(l_pk_orig_column_names_t, INSTR(l_pk_orig_column_names_t,',',1,1)+1, INSTR(l_pk_orig_column_names_t,',',1,2)-INSTR(l_pk_orig_column_names_t,',',1,1)-1 );
                 l_aggregate_predicate := l_aggregate_predicate || ' AND ' || l_orig_pk2_column || '=' || p_pk2_alias;
             end if;
             if(p_pk3_alias is not null) then
                 l_orig_pk3_column := SUBSTR(l_pk_orig_column_names_t, INSTR(l_pk_orig_column_names_t,',',1,2)+1, INSTR(l_pk_orig_column_names_t,',',1,3)-INSTR(l_pk_orig_column_names_t,',',1,2)-1 );
                 l_aggregate_predicate := l_aggregate_predicate || ' AND ' || l_orig_pk3_column || '=' || p_pk3_alias;
             end if;
             if(p_pk4_alias is not null) then
                 l_orig_pk4_column := SUBSTR(l_pk_orig_column_names_t, INSTR(l_pk_orig_column_names_t,',',1,3)+1, INSTR(l_pk_orig_column_names_t,',',1,4)-INSTR(l_pk_orig_column_names_t,',',1,3)-1 );
                 l_aggregate_predicate := l_aggregate_predicate || ' AND ' || l_orig_pk4_column || '=' || p_pk4_alias;
             end if;
             if(p_pk5_alias is not null) then
                 l_orig_pk5_column := SUBSTR(l_pk_orig_column_names, INSTR(l_pk_orig_column_names_t,',',1,4)+1 );
                 l_aggregate_predicate := l_aggregate_predicate || ' AND ' || l_orig_pk5_column || '=' || p_pk5_alias;
             end if;

            l_aggregate_predicate := substrb(l_aggregate_predicate ||
                                           ' AND ( ' ||
                                           l_set_predicates || ' ) ' ||
                                           '))',
                                           1, g_pred_buf_size);

          else
             l_aggregate_predicate := substrb(l_aggregate_predicate ||
                                           ' UNION ALL (SELECT ' ||
                                           l_pk_orig_column_names || ' FROM ' ||
                                           l_db_object_name || ' WHERE ' ||
                                           l_set_predicates || '))',
                                           1, g_pred_buf_size);
          end if;
        ELSE
          l_aggregate_predicate:= l_set_predicates;
        END IF;
      END IF;
    END IF; -- end of if (l_instance_set_flag = TRUE) clause

    x_predicate := l_aggregate_predicate;

    if ((lengthb(l_aggregate_predicate) > g_vpd_buf_limit)
         AND (p_statement_type = 'BASE')) then
      FND_MESSAGE.SET_NAME('FND', 'GENERIC-INTERNAL ERROR');
      FND_MESSAGE.SET_TOKEN('ROUTINE', 'EGO_DATA_SECURITY.GET_SECURITY_PREDICATE');
      FND_MESSAGE.SET_TOKEN('REASON',
                            'The predicate was longer than the database VPD limit of '||
                            to_char(g_vpd_buf_limit)||' bytes for the predicate.  ');
      x_return_status := 'L'; /* Indicate Error */
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   =>  'Returning Status: '||x_return_status||' as predicate size is more'
                 );
    end if;
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   =>  'Returning Status: '||x_return_status
               );
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   =>  'Returning Predicate: '||x_predicate
               );

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE',G_PKG_NAME||l_api_name);
      fnd_message.set_token('ERRNO', SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      code_debug (p_log_level => G_DEBUG_LEVEL_EXCEPTION
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning EXCEPTION '||SQLERRM
                  );
      x_return_status := G_RETURN_UNEXP_ERR;
      return;
  END get_security_predicate;


--------------------------------------------------------
----    get_security_predicate_clob
--------------------------------------------------------
/* FP Bug 8139224 with BaseBug 7657817, Below procedure is the new procedure created with the name get_security_predicate_clob
and having the x_predicate as CLOB */
  PROCEDURE get_security_predicate_clob
  (
    p_api_version                IN  NUMBER,
    p_function                   IN  VARCHAR2 default null,
    p_object_name                IN  VARCHAR2,
    p_grant_instance_type        IN  VARCHAR2 DEFAULT 'UNIVERSAL',/* SET, INSTANCE*/
    p_user_name                  IN  VARCHAR2 default null,
    /* stmnt_type: 'OTHER', 'BASE'=VPD, 'EXISTS'= for checking existence. */
    p_statement_type             IN  VARCHAR2 DEFAULT 'OTHER',
    p_pk1_alias                  IN  VARCHAR2 DEFAULT NULL,
    p_pk2_alias                  IN  VARCHAR2 DEFAULT NULL,
    p_pk3_alias                  IN  VARCHAR2 DEFAULT NULL,
    p_pk4_alias                  IN  VARCHAR2 DEFAULT NULL,
    p_pk5_alias                  IN  VARCHAR2 DEFAULT NULL,
    x_predicate                  OUT NOCOPY CLOB, /* FP Bug 8139224 with BaseBug 7657817, use x_predicate CLOB instead of x_predicate VARCHAR2*/
    x_return_status              OUT NOCOPY VARCHAR2
  )  IS
    l_api_name          CONSTANT VARCHAR2(30)  := 'GET_SECURITY_PREDICATE_CLOB';

        -- On addition of any Required parameters the major version needs
        -- to change i.e. for eg. 1.X to 2.X.
        -- On addition of any Optional parameters the minor version needs
        -- to change i.e. for eg. X.6 to X.7.
    l_api_version       CONSTANT NUMBER := 1.0;
    l_sysdate                    DATE := Sysdate;
    l_aggregate_predicate        CLOB;/* FP Bug 8139224 with BaseBug 7657817, change to CLOB*/
    l_instance_flag              BOOLEAN   DEFAULT TRUE;
    l_instance_set_flag          BOOLEAN   DEFAULT TRUE;
    l_set_predicates             CLOB;/* FP Bug 8139224 with BaseBug 7657817, change to CLOB*/
    l_db_object_name             VARCHAR2(30);
    l_db_pk1_column              VARCHAR2(61);
    l_db_pk2_column              VARCHAR2(61);
    l_db_pk3_column              VARCHAR2(61);
    l_db_pk4_column              VARCHAR2(61);
    l_db_pk5_column              VARCHAR2(61);
    l_pk_column_names            VARCHAR2(512);
    l_pk_orig_column_names       VARCHAR2(512);
    l_pk_orig_column_names_t     VARCHAR2(513);
    l_orig_pk1_column            VARCHAR2(61);
    l_orig_pk2_column            VARCHAR2(61);
    l_orig_pk3_column            VARCHAR2(61);
    l_orig_pk4_column            VARCHAR2(61);
    l_orig_pk5_column            VARCHAR2(61);
    l_type_converted_val_cols    VARCHAR2(512);
    l_user_name                  VARCHAR2(80);
--    l_orig_system                VARCHAR2(48);
    l_orig_system_id             NUMBER;

    l_group_info                 VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_company_info               VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_object_id                  NUMBER;

    instance_set_grants_c        DYNAMIC_CUR;
    l_dynamic_sql_1              VARCHAR2(32767);
    l_set_predicate_segment      VARCHAR2(32767);
    l_prof_privilege_tbl         EGO_VARCHAR_TBL_TYPE;

  BEGIN
    SetGlobals();
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   =>  'Started with 13 params '||
                   ' p_api_version: '|| to_char(p_api_version) ||
                   ' - p_function: '|| p_function ||
                   ' - p_object_name: '|| p_object_name ||
                   ' - p_grant_instance_type: '|| p_grant_instance_type ||
                   ' - p_statement_type: '|| p_statement_type ||
                   ' - p_pk1_alias: '|| p_pk1_alias ||
                   ' - p_pk2_alias: '|| p_pk2_alias ||
                   ' - p_pk3_alias: '|| p_pk3_alias ||
                   ' - p_pk4_alias: '|| p_pk4_alias ||
                   ' - p_pk5_alias: '|| p_pk5_alias
               );

    -- check for call compatibility.
    if TRUNC(l_api_version) <> TRUNC(p_api_version) THEN
      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE', g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON', 'Unsupported version '|| to_char(p_api_version)||
                                      ' passed to API; expecting version '||
                                      to_char(l_api_version));
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning as the call in incompatible '
                 );
      x_return_status := G_RETURN_UNEXP_ERR; /* Unexpected Error */
      RETURN;
    END IF;

    -- Check to make sure we're not using unsupported statement_type
    if (p_statement_type NOT IN  ('BASE', 'OTHER', 'EXISTS')) then
      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE', g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON', 'Unsupported p_statement_type: '|| p_statement_type);
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning as statement type is not supported'
                 );
      x_return_status := G_RETURN_UNEXP_ERR; /* Unexpected Error */
      return;
    end if;

    /* ### We haven't yet added support for NULL (all) function in arg. */
    /* ### Add that support since it is in the API. */
    if (p_function is NULL) then
      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE', g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON', 'Support has not yet been added for passing NULL function.');
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning as mand parameter Function is not available '
                 );
      x_return_status := G_RETURN_UNEXP_ERR; /* Unexpected Error */
      return;
    end if;

    -- Check to make sure we're not using unsupported modes
    if ((p_grant_instance_type = 'SET')
    AND((p_pk1_alias is not NULL)
        OR (p_pk2_alias is not NULL)
        OR (p_pk3_alias is not NULL)
        OR (p_pk4_alias is not NULL)
        OR (p_pk5_alias is not NULL))) then

      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE', g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON', 'Unsupported mode arguments: '||
                            ' p_grant_instance_type = SET.');
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning as incompatible combination for p_grant_instance_type = SET  '
                 );
      x_return_status := G_RETURN_UNEXP_ERR; /* Unexpected Error */
      return;
    end if;

    /* We don't currently support BASE mode; we will have to change to */
    /* a pure OR statement when VPD becomes important. */
    if (p_statement_type = 'BASE') then
      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE', g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON', 'Support has not yet been added for '|| 'p_statement_type = BASE.');
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning as incompatible statement_type = BASE '
                 );
      x_return_status := G_RETURN_UNEXP_ERR; /* Unexpected Error */
      return;
    end if;

     x_return_status := G_RETURN_SUCCESS; /* Assume Success */
    l_user_name := p_user_name;
    get_orig_key(x_user_name      => l_user_name
--                ,x_orig_system    => l_orig_system
                ,x_orig_system_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_user_name: '||l_user_name||
--                               ' - l_orig_system: '||l_orig_system||
                               ' - l_orig_system_id: '||l_orig_system_id
               );

    -----------------------------------------------------------------------------------
    --First we see if a profile option is set and if function exists                                 --
    -- if so we return and empty predicate here itself without doing further query   --
    -----------------------------------------------------------------------------------

    getPrivilege_for_profileOption(p_api_version         => p_api_version,
                         p_object_name       => p_object_name,
                         p_user_name         => p_user_name,
                         x_privilege_tbl   => l_prof_privilege_tbl,
                         x_return_status   => x_return_status);

    IF (x_return_status = G_RETURN_SUCCESS) THEN
      IF (l_prof_privilege_tbl.COUNT > 0) THEN
        FOR i IN l_prof_privilege_tbl.first .. l_prof_privilege_tbl.last LOOP
          IF (l_prof_privilege_tbl(i) = p_function) THEN
            x_predicate := '';
            code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                       ,p_module    => l_api_name
                       ,p_message   => 'No need for predicate as user has privilege through profile '
                       );
            RETURN;
          END IF; --if function match, returning empty predicate
        END LOOP;
      END IF; -- x_prof_privilege_tbl >0
    END IF; --return status is T

    -- Step 1.
    -- check whether there is any grant for this use for any role that
    -- includes the given privilege

    IF (p_grant_instance_type = G_TYPE_INSTANCE) THEN
      l_instance_set_flag:= FALSE;
    ELSIF (p_grant_instance_type = G_TYPE_SET) THEN
      l_instance_flag:= FALSE;
    END IF;

    x_return_status := get_pk_information(p_object_name  ,
                                          l_db_pk1_column  ,
                                          l_db_pk2_column  ,
                                          l_db_pk3_column  ,
                                          l_db_pk4_column  ,
                                          l_db_pk5_column  ,
                                          l_pk_column_names  ,
                                          l_type_converted_val_cols  ,
                                          l_pk_orig_column_names,
                                          l_db_object_name,
                                          p_pk1_alias,
                                          p_pk2_alias,
                                          p_pk3_alias,
                                          p_pk4_alias,
                                          p_pk5_alias );
    if (x_return_status <> G_RETURN_SUCCESS) then
      /* There will be a message on the msg dict stack. */
      return;  /* We will return the x_return_status as out param */
    end if;

    l_object_id := get_object_id(p_object_name => p_object_name);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_object_id: '||l_object_id
               );
    l_company_info := get_company_info (p_party_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_company_info: '||l_company_info
               );
    l_group_info := get_group_info(p_party_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_group_info: '||l_group_info
               );

    -- Step 2.
    l_aggregate_predicate := '';
    IF(l_instance_flag = TRUE) THEN
      if (p_statement_type = 'EXISTS') then
        l_aggregate_predicate := 'EXISTS ( SELECT ''X'' ';
      else
        l_aggregate_predicate := l_pk_column_names || ' IN ( SELECT ' ||l_type_converted_val_cols;
      end if;

      if (p_statement_type = 'EXISTS') then
      --Bug8735615
      --R12C Security Changes
           /*   l_aggregate_predicate := l_aggregate_predicate ||
              ' FROM fnd_grants grants,  fnd_form_functions functions, fnd_menu_entries cmf ' ||
              ' WHERE grants.INSTANCE_PK1_VALUE=to_char('||p_pk1_alias||')'; */
     if (p_object_name = 'EGO_CATALOG_GROUP') THEN
         l_aggregate_predicate := l_aggregate_predicate ||
              ' FROM fnd_grants grants,  fnd_form_functions functions, fnd_menu_entries cmf, ego_item_cat_denorm_hier cathier ' ||
              ' WHERE grants.INSTANCE_PK1_VALUE=to_char(cathier.parent_catalog_group_id) AND cathier.child_catalog_group_id = to_char('||p_pk1_alias||')';
     else
               l_aggregate_predicate := l_aggregate_predicate ||
              ' FROM fnd_grants grants,  fnd_form_functions functions, fnd_menu_entries cmf ' ||
              ' WHERE grants.INSTANCE_PK1_VALUE=to_char('||p_pk1_alias||')';
     end if;
      --R12C Security Changes
      --Bug8735615
        if(p_pk2_alias is not null) then
           l_aggregate_predicate := l_aggregate_predicate || ' AND grants.INSTANCE_PK2_VALUE=to_char('||p_pk2_alias||')';
        end if;

        if(p_pk3_alias is not null) then
           l_aggregate_predicate := l_aggregate_predicate || ' AND grants.INSTANCE_PK3_VALUE=to_char('||p_pk3_alias||')';
        end if;

        if(p_pk4_alias is not null) then
           l_aggregate_predicate := l_aggregate_predicate || ' AND grants.INSTANCE_PK4_VALUE=to_char('||p_pk4_alias||')';
        end if;

        if(p_pk5_alias is not null) then
           l_aggregate_predicate := l_aggregate_predicate || ' AND grants.INSTANCE_PK5_VALUE=to_char('||p_pk5_alias||')';
        end if;

        l_aggregate_predicate := l_aggregate_predicate ||
        ' AND grants.start_date <= sysdate ';

      else
         l_aggregate_predicate := l_aggregate_predicate ||
        ' FROM fnd_grants grants,  fnd_form_functions functions, fnd_menu_entries cmf ' ||
        ' WHERE grants.start_date <= sysdate ';
      end if;

      l_aggregate_predicate :=
      l_aggregate_predicate ||
          ' AND (grants.end_date IS NULL OR grants.end_date >= sysdate) ' ||
          ' AND grants.instance_type = ''INSTANCE'' ' ||
          ' AND cmf.function_id = functions.function_id ' ||
          ' AND cmf.menu_id = grants.menu_id ' ||
          ' AND grants.object_id = ' || l_object_id ||
          ' AND functions.function_name = ''' || p_function || '''' ||
          ' AND ((grants.grantee_type = ''USER'' ' ||
                ' AND grants.grantee_key = '''||l_user_name||''')'||
               ' OR (grants.grantee_type = ''GROUP'' '||
                   ' AND grants.grantee_key in ('|| l_group_info || ')) ' ||
               ' OR (grants.grantee_type = ''COMPANY'' '||
                   ' AND grants.grantee_key in ('|| l_company_info || ')) ' ||
               ' OR (grants.grantee_type = ''GLOBAL'' ' ||
                   ' AND grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL''))))';
      /* FP Bug 8139224 with BaseBug 7657817,code_debug can only deal with VARCHAR2
      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'l_aggregate_predicate: '||l_aggregate_predicate
                 );*/
    END IF;
    -- Step 3.
    /*FP Bug 8139224 with BaseBug 7657817, initialize the CLOB prarmeter l_set_predicates as one space but not null*/
    l_set_predicates := ' ';
    IF (l_instance_set_flag = TRUE) THEN
      -------------------------------------------------------------------------------
      -- Now we build dynamic SQL using the work we just did to optimize the query --
      -------------------------------------------------------------------------------
      l_dynamic_sql_1 :=
      ' SELECT DISTINCT instance_sets.predicate ' ||
        ' FROM fnd_grants grants, fnd_form_functions functions, ' ||
             ' fnd_menu_entries cmf, fnd_object_instance_sets instance_sets ' ||
       ' WHERE grants.instance_type = :instance_type ' ||
         ' AND grants.start_date <= SYSDATE ' ||
         ' AND NVL(grants.end_date,SYSDATE) >= SYSDATE ' ||
         ' AND cmf.function_id = functions.function_id ' ||
         ' AND cmf.menu_id = grants.menu_id ' ||
         ' AND grants.instance_set_id = instance_sets.instance_set_id ' ||
         ' AND grants.object_id = :object_id ' ||
         ' AND functions.function_name = :function ' ||
         ' AND ((grants.grantee_type = ''USER'' ' ||
               ' AND grants.grantee_key = :grantee_key )' ||
              ' OR (grants.grantee_type = ''GROUP'' ' ||
                  ' AND grants.grantee_key in ('||l_group_info||' ))' ||
              ' OR (grants.grantee_type = ''COMPANY'' ' ||
                  ' AND grants.grantee_key in ( '||l_company_info||' ))' ||
              ' OR (grants.grantee_type = ''GLOBAL'' ' ||
                  ' AND grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL''))) ';
      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'Binds for instance_set_grants_c '||
                   ' G_TYPE_SET: '||G_TYPE_SET||
                   ' - l_parent_object_id: '||l_object_id||
                   ' - p_function: '||p_function||
                   ' - l_user_name: '||l_user_name
                 );

      OPEN instance_set_grants_c FOR l_dynamic_sql_1
      USING IN G_TYPE_SET,
            IN l_object_id,
            IN p_function,
            IN l_user_name;
      LOOP
        FETCH instance_set_grants_c into l_set_predicate_segment;
        EXIT WHEN instance_set_grants_c%NOTFOUND;
        /*FP Bug 8139224 with BaseBug 7657817, using DBMS_LOB to deal with CLOB variables*/
        DBMS_LOB.append (l_set_predicates, TO_CLOB (l_set_predicate_segment || ' OR '));
        /*l_set_predicates := substrb(l_set_predicates ||
                            l_set_predicate_segment ||
                            ' OR ',
                            1, g_pred_buf_size);*/
      END LOOP;
      CLOSE instance_set_grants_c;
      /* FP Bug 8139224 with BaseBug 7657817,code_debug can only deal with VARCHAR2
      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'l_set_predicates: '||l_set_predicates
                 );*/

     /*FP Bug 8139224 with BaseBug 7657817, using DBMS_LOB to deal with CLOB variables, such as DBMS_LOB.getLENGTH and DBMS_LOB.trim
     Besides that,  adding condition to verify the length of l_set_predicates and length of 'OR '*/
      IF(DBMS_LOB.getLENGTH(l_set_predicates) > 0 AND DBMS_LOB.getLENGTH(l_set_predicates)> LENGTH ('OR ')) THEN
        -- strip off the trailing 'OR '
        DBMS_LOB.trim (l_set_predicates, DBMS_LOB.getLENGTH (l_set_predicates) - LENGTH ('OR '));
        /*l_set_predicates := substr(l_set_predicates, 1,
                            length(l_set_predicates) - length('OR '));*/

        IF(DBMS_LOB.getLENGTH(l_aggregate_predicate) > 0) THEN
          -- strip off the trailing ')'
          DBMS_LOB.trim (l_aggregate_predicate, DBMS_LOB.getLENGTH (l_aggregate_predicate) - LENGTH (')'));
          /*l_aggregate_predicate := substr(l_aggregate_predicate, 1,
                                   length(l_aggregate_predicate) - length(')'));*/
          if (p_statement_type = 'EXISTS') then
             l_pk_orig_column_names_t := l_pk_orig_column_names||',';
             l_orig_pk1_column  := SUBSTR(l_pk_orig_column_names_t, 1, INSTR(l_pk_orig_column_names_t,',',1,1)-1);
                                                 /*FP Bug 8139224 with BaseBug 7657817, chenage codes to deal with CLOB variables
                                                 l_aggregate_predicate := (l_aggregate_predicate ||
                                           ' UNION ALL (SELECT ''X'' ' || ' FROM ' ||
                                           l_db_object_name || ' WHERE ' ||
                                           l_orig_pk1_column || '=' || p_pk1_alias);
             l_aggregate_predicate := substrb(l_aggregate_predicate ||
                                           ' UNION ALL (SELECT ''X'' ' || ' FROM ' ||
                                           l_db_object_name || ' WHERE ' ||
                                           l_orig_pk1_column || '=' || p_pk1_alias, 1, g_pred_buf_size);*/
        --Bug8735615
        --R12C Security Changes
             /*l_aggregate_predicate := substrb(l_aggregate_predicate ||
                                           ' UNION ALL (SELECT ''X'' ' || ' FROM ' ||
                                           l_db_object_name || ' WHERE ' ||
                                           l_orig_pk1_column || '=' || p_pk1_alias, 1, g_pred_buf_size);*/

             IF (p_object_name = 'EGO_ITEM') THEN
             l_aggregate_predicate := (l_aggregate_predicate ||
                                           ' UNION ALL (SELECT ''X'' ' || ' FROM ' ||
                                           l_db_object_name ||', ego_item_cat_denorm_hier cathier WHERE item_catalog_group_id = cathier.child_catalog_group_id AND ' ||
                                           l_orig_pk1_column || '=' || p_pk1_alias);

             ELSE
             l_aggregate_predicate := (l_aggregate_predicate ||
                                           ' UNION ALL (SELECT ''X'' ' || ' FROM ' ||
                                           l_db_object_name || ' WHERE ' ||
                                           l_orig_pk1_column || '=' || p_pk1_alias);
             END IF;
        --R12C Security Changes
        --Bug8735615

             if(p_pk2_alias is not null) then
                 l_orig_pk2_column := SUBSTR(l_pk_orig_column_names_t, INSTR(l_pk_orig_column_names_t,',',1,1)+1, INSTR(l_pk_orig_column_names_t,',',1,2)-INSTR(l_pk_orig_column_names_t,',',1,1)-1 );
                 l_aggregate_predicate := l_aggregate_predicate || ' AND ' || l_orig_pk2_column || '=' || p_pk2_alias;
             end if;
             if(p_pk3_alias is not null) then
                 l_orig_pk3_column := SUBSTR(l_pk_orig_column_names_t, INSTR(l_pk_orig_column_names_t,',',1,2)+1, INSTR(l_pk_orig_column_names_t,',',1,3)-INSTR(l_pk_orig_column_names_t,',',1,2)-1 );
                 l_aggregate_predicate := l_aggregate_predicate || ' AND ' || l_orig_pk3_column || '=' || p_pk3_alias;
             end if;
             if(p_pk4_alias is not null) then
                 l_orig_pk4_column := SUBSTR(l_pk_orig_column_names_t, INSTR(l_pk_orig_column_names_t,',',1,3)+1, INSTR(l_pk_orig_column_names_t,',',1,4)-INSTR(l_pk_orig_column_names_t,',',1,3)-1 );
                 l_aggregate_predicate := l_aggregate_predicate || ' AND ' || l_orig_pk4_column || '=' || p_pk4_alias;
             end if;
             if(p_pk5_alias is not null) then
                 l_orig_pk5_column := SUBSTR(l_pk_orig_column_names, INSTR(l_pk_orig_column_names_t,',',1,4)+1 );
                 l_aggregate_predicate := l_aggregate_predicate || ' AND ' || l_orig_pk5_column || '=' || p_pk5_alias;
             end if;
                                                /*FP Bug 8139224 with BaseBug 7657817, chenage codes to deal with CLOB variables*/
            l_aggregate_predicate := (l_aggregate_predicate ||
                                           ' AND ( ' ||
                                           l_set_predicates || ' ) ' ||
                                           '))');
            /*l_aggregate_predicate := substrb(l_aggregate_predicate ||
                                           ' AND ( ' ||
                                           l_set_predicates || ' ) ' ||
                                           '))',
                                           1, g_pred_buf_size);*/

          else
             /*FP Bug 8139224 with BaseBug 7657817, chenage codes to deal with CLOB variables*/
             l_aggregate_predicate := (l_aggregate_predicate ||
                                           ' UNION ALL (SELECT ' ||
                                           l_pk_orig_column_names || ' FROM ' ||
                                           l_db_object_name || ' WHERE ' ||
                                           l_set_predicates || '))');
             /*l_aggregate_predicate := substrb(l_aggregate_predicate ||
                                           ' UNION ALL (SELECT ' ||
                                           l_pk_orig_column_names || ' FROM ' ||
                                           l_db_object_name || ' WHERE ' ||
                                           l_set_predicates || '))',
                                           1, g_pred_buf_size);*/
          end if;
        ELSE
          l_aggregate_predicate:= l_set_predicates;
        END IF;
      END IF;
    END IF; -- end of if (l_instance_set_flag = TRUE) clause

    x_predicate := l_aggregate_predicate;
    /*FP Bug 8139224 with BaseBug 7657817, using DBMS_LOB to deal with CLOB variables*/
    if ((DBMS_LOB.getLENGTH(l_aggregate_predicate) > g_vpd_buf_limit)
         AND (p_statement_type = 'BASE')) then
      FND_MESSAGE.SET_NAME('FND', 'GENERIC-INTERNAL ERROR');
      FND_MESSAGE.SET_TOKEN('ROUTINE', 'EGO_DATA_SECURITY.GET_SECURITY_PREDICATE_CLOB');
      FND_MESSAGE.SET_TOKEN('REASON',
                            'The predicate was longer than the database VPD limit of '||
                            to_char(g_vpd_buf_limit)||' bytes for the predicate.  ');
      x_return_status := 'L'; /* Indicate Error */
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   =>  'Returning Status: '||x_return_status||' as predicate size is more'
                 );
    end if;
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   =>  'Returning Status: '||x_return_status
               );
    /* FP Bug 8139224 with BaseBug 7657817,code_debug can only deal with VARCHAR2
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   =>  'Returning Predicate: '||x_predicate
               );
    */

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE',G_PKG_NAME||l_api_name);
      fnd_message.set_token('ERRNO', SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      code_debug (p_log_level => G_DEBUG_LEVEL_EXCEPTION
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning EXCEPTION '||SQLERRM
                  );
      x_return_status := G_RETURN_UNEXP_ERR;
      return;
  END get_security_predicate_clob;


--------------------------------------------------------
----    get_sec_predicate_with_exists
--------------------------------------------------------
  PROCEDURE get_sec_predicate_with_exists
  (
    p_api_version      IN  NUMBER,
    p_function         IN  VARCHAR2 default null,
    p_object_name      IN  VARCHAR2,
    p_grant_instance_type  IN  VARCHAR2 DEFAULT 'UNIVERSAL',/* SET, INSTANCE*/
    p_party_id         IN NUMBER,
    /* stmnt_type: 'OTHER', 'BASE'=VPD, 'EXISTS'= for checking existence. */
    p_statement_type   IN  VARCHAR2 DEFAULT 'OTHER',
    p_pk1_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk2_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk3_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk4_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk5_alias        IN  VARCHAR2 DEFAULT NULL,
    x_predicate        OUT NOCOPY varchar2,
    x_return_status    OUT NOCOPY  varchar2
  )  IS
    l_api_name   CONSTANT VARCHAR2(50)  := 'GET_SEC_PREDICATE_WITH_EXISTS';

        -- On addition of any Required parameters the major version needs
        -- to change i.e. for eg. 1.X to 2.X.
        -- On addition of any Optional parameters the minor version needs
        -- to change i.e. for eg. X.6 to X.7.
    l_api_version  CONSTANT NUMBER := 1.0;
    l_sysdate               DATE := Sysdate;
    l_aggregate_predicate   VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_instance_flag         BOOLEAN   DEFAULT TRUE;
    l_instance_set_flag     BOOLEAN   DEFAULT TRUE;
    l_set_predicates        VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_db_object_name        varchar2(30);
    l_db_pk1_column         varchar2(61);
    l_db_pk2_column         varchar2(61);
    l_db_pk3_column         varchar2(61);
    l_db_pk4_column         varchar2(61);
    l_db_pk5_column         varchar2(61);
    l_pk_column_names       varchar2(512);
    l_pk_orig_column_names  varchar2(512);
    l_type_converted_val_cols varchar2(512);
    l_user_name             varchar2(80);
    l_orig_system           varchar2(48);
    l_orig_system_id        NUMBER;
    l_sub_pred_clause       varchar2(512);

    l_group_info     VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_company_info   VARCHAR2(32767); /* Must match g_pred_buf_size*/

    instance_set_grants_c DYNAMIC_CUR;
    l_dynamic_sql_1       VARCHAR2(32767);
    l_one_set_predicate   VARCHAR2(32767);
    l_prof_privilege_tbl  EGO_VARCHAR_TBL_TYPE;

     CURSOR get_user_grantee_key (cp_party_id NUMBER)
     IS
       --SELECT decode (party_type,'PERSON','HZ_PARTY:'||party_id,'GROUP','HZ_GROUP:'||party_id,'ORGANIZATION','HZ_COMPANY:'||party_id) grantee_key
       SELECT party_type
       FROM hz_parties
       WHERE party_id=cp_party_id;

     l_object_id       number;
     p_user_name  FND_GRANTS.grantee_key%TYPE;
     l_party_type VARCHAR2(30);
  BEGIN
    SetGlobals();
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   =>  'Started with 13 params '||
                   ' p_api_version: '|| to_char(p_api_version) ||
                   ' - p_function: '|| p_function ||
                   ' - p_object_name: '|| p_object_name ||
                   ' - p_grant_instance_type: '|| p_grant_instance_type ||
                   ' - p_party_id: '|| p_party_id ||
                   ' - p_statement_type: '|| p_statement_type ||
                   ' - p_pk1_alias: '|| p_pk1_alias ||
                   ' - p_pk2_alias: '|| p_pk2_alias ||
                   ' - p_pk3_alias: '|| p_pk3_alias ||
                   ' - p_pk4_alias: '|| p_pk4_alias ||
                   ' - p_pk5_alias: '|| p_pk5_alias
               );

    x_return_status := G_RETURN_SUCCESS; /* Assume Success */

    -- check for call compatibility.
    if TRUNC(l_api_version) <> TRUNC(p_api_version) THEN
      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE',
                            g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON',
         'Unsupported version '|| to_char(p_api_version)||
         ' passed to API; expecting version '||
         to_char(l_api_version));
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning as the call in incompatible '
                 );
      x_return_status := G_RETURN_UNEXP_ERR; /* Unexpected Error */
      return;
    END IF;

    -- Check to make sure we're not using unsupported statement_type
    if ((p_statement_type <> 'BASE') and (p_statement_type <>  'OTHER')
        AND (p_statement_type <> 'EXISTS')) then
      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE',
                             g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON',
         'Unsupported p_statement_type: '|| p_statement_type);
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning as statement type is not supported'
                 );
      x_return_status := G_RETURN_UNEXP_ERR; /* Unexpected Error */
      return;
    end if;

    /* ### We haven't yet added support for NULL (all) function in arg. */
    /* ### Add that support since it is in the API. */
    if (p_function is NULL) then
      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE',
                             g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON',
         'Support has not yet been added for passing NULL function.');
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning as mand parameter Function is not available '
                 );
      x_return_status := G_RETURN_UNEXP_ERR; /* Unexpected Error */
      return;
    end if;


     -- Check to make sure we're not using unsupported modes
     if ((p_grant_instance_type = 'SET')
     AND((p_pk1_alias is not NULL)
         OR (p_pk2_alias is not NULL)
         OR (p_pk3_alias is not NULL)
         OR (p_pk4_alias is not NULL)
         OR (p_pk5_alias is not NULL))) then

       fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
       fnd_message.set_token('ROUTINE', g_pkg_name || '.'|| l_api_name);
       fnd_message.set_token('REASON', 'Unsupported mode arguments: '||
                             ' p_grant_instance_type = SET.');
       code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                  ,p_module    => l_api_name
                  ,p_message   => 'Returning as incompatible combination for p_grant_instance_type = SET  '
                  );
       x_return_status := G_RETURN_UNEXP_ERR; /* Unexpected Error */
       return;
     end if;

     /* We don't currently support BASE mode; we will have to change to */
     /* a pure OR statement when VPD becomes important. */
     if (p_statement_type = 'BASE') then
       fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
       fnd_message.set_token('ROUTINE', g_pkg_name || '.'|| l_api_name);
       fnd_message.set_token('REASON', 'Support has not yet been added for '|| 'p_statement_type = BASE.');
       code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                  ,p_module    => l_api_name
                  ,p_message   => 'Returning as incompatible statement_type = BASE '
                  );
       x_return_status := G_RETURN_UNEXP_ERR; /* Unexpected Error */
       return;
     end if;

    -- Default the user name if not passed in.
    if(p_user_name is NULL) then
      l_user_name := G_USER_NAME;
    else
      l_user_name := p_user_name;
    end if;

    -- Get the key columns from the user name
    -- We are not checking for NULL returns (meaning user not in wf_roles)
    -- because right now we allow checking of grants to users not in
    -- wf_roles.

    IF(p_party_id=-1000) THEN
      l_party_type:='GLOBAL';
    ELSE
      OPEN  get_user_grantee_key (cp_party_id=>p_party_id);
      FETCH get_user_grantee_key INTO l_party_type;
      CLOSE get_user_grantee_key;
    END IF;
    l_orig_system_id:=p_party_id;
    IF(l_party_type='GLOBAL') THEN
       l_orig_system:='HZ_GLOBAL';
    ELSIF(l_party_type='GROUP') THEN
       l_orig_system:='HZ_GROUP';
    ELSIF(l_party_type='ORGANIZATION') THEN
       l_orig_system:='HZ_COMPANY';
    ELSIF(l_party_type='PERSON') THEN
       l_orig_system:='HZ_PARTY';
    END IF;
    l_user_name:=l_orig_system||':'||l_orig_system_id;

    -----------------------------------------------------------------------------------
    --First we see if a profile option is set and if function exists                                 --
    -- if so we return and empty predicate here itself without doing further query   --
    -----------------------------------------------------------------------------------

    getPrivilege_for_profileOption(p_api_version    => p_api_version,
                                   p_object_name    => p_object_name,
                                   p_user_name      => l_user_name,
                                   x_privilege_tbl  => l_prof_privilege_tbl,
                                   x_return_status  => x_return_status);

    IF (x_return_status = G_RETURN_SUCCESS) THEN
      IF (l_prof_privilege_tbl.COUNT > 0) THEN
        FOR i IN l_prof_privilege_tbl.first .. l_prof_privilege_tbl.last LOOP
          IF (l_prof_privilege_tbl(i) = p_function) THEN
            x_predicate := '';
            code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                       ,p_module    => l_api_name
                       ,p_message   => 'No need for predicate as user has privilege through profile '
                       );
            return;
          END IF; --if function match, returning empty predicate
        END LOOP;
      END IF; -- x_prof_privilege_tbl >0
    END IF; --return status is T

    -- Step 1.
    -- check whether there is any grant for this use for any role that
    -- includes the given privilege

    IF (p_grant_instance_type = G_TYPE_INSTANCE) THEN
      l_instance_set_flag:= FALSE;
    ELSIF (p_grant_instance_type = G_TYPE_SET) THEN
      l_instance_flag:= FALSE;
    END IF;

    x_return_status := get_pk_information(p_object_name  ,
                         l_db_pk1_column  ,
                         l_db_pk2_column  ,
                         l_db_pk3_column  ,
                         l_db_pk4_column  ,
                         l_db_pk5_column  ,
                         l_pk_column_names  ,
                         l_type_converted_val_cols  ,
                         l_pk_orig_column_names,
                         l_db_object_name,
                         p_pk1_alias,
                         p_pk2_alias,
                         p_pk3_alias,
                         p_pk4_alias,
                         p_pk5_alias );
    if (x_return_status <> G_RETURN_SUCCESS) then
      /* There will be a message on the msg dict stack. */
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning FALSE as pk values are not correct'
                  );
      return;  /* We will return the x_return_status as out param */
    end if;

    l_object_id :=get_object_id(p_object_name => p_object_name );
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_object_id: '||l_object_id
               );
    l_group_info := get_group_info(p_party_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_group_info: '||l_group_info
               );
    l_company_info := get_company_info (p_party_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_company_info: '||l_company_info
               );

    -- Step 2.
    l_aggregate_predicate  := '';
    IF(l_instance_flag = TRUE) THEN
       if (p_statement_type = 'EXISTS') then
          l_aggregate_predicate := 'EXISTS (';
       else
          l_aggregate_predicate := l_pk_column_names || ' IN (';
       end if;
       --R12C Security Changes
       /*l_aggregate_predicate :=
           l_aggregate_predicate ||
          ' SELECT INSTANCE_PK1_VALUE' ||
          ' FROM fnd_grants grants, ' ||
               ' fnd_form_functions functions, ' ||
               ' fnd_menu_entries cmf ' ||
          ' WHERE grants.INSTANCE_PK1_VALUE=to_char('||p_pk1_alias||')'||
          ' AND NVL(grants.end_date,SYSDATE) >= SYSDATE ' ||
          ' AND grants.instance_type= ''INSTANCE'' ' ||
          ' AND cmf.function_id = functions.function_id ' ||
          ' AND cmf.menu_id = grants.menu_id ' ||
          ' AND grants.object_id = ' || l_object_id ||
          ' AND functions.function_name = ''' || p_function || '''' ||
          ' AND   (   (    grants.grantee_type = ''USER'' ' ||
                    ' AND grants.grantee_key = '''||l_user_name||''')'||
                 ' OR (   grants.grantee_type = ''GROUP'' '||
                    ' AND grants.grantee_key in '||
                      ' ( '|| l_group_info || ')) ' ||
                 ' OR (   grants.grantee_type = ''COMPANY'' '||
                    ' AND grants.grantee_key in '||
                      ' ( '|| l_company_info || ')) ' ||
                 ' OR (grants.grantee_type = ''GLOBAL'' AND grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL'') )))';*/
   if (p_object_name = 'EGO_CATALOG_GROUP') THEN
     l_aggregate_predicate :=
           l_aggregate_predicate ||
          ' SELECT INSTANCE_PK1_VALUE' ||
          ' FROM fnd_grants grants, ' ||
               ' fnd_form_functions functions, ' ||
               ' fnd_menu_entries cmf, ' ||
         ' ego_item_cat_denorm_hier cathier ' ||
          ' WHERE grants.INSTANCE_PK1_VALUE=to_char(cathier.parent_catalog_group_id)' ||
    ' AND cathier.child_catalog_group_id = to_char('||p_pk1_alias||')' ||
          ' AND NVL(grants.end_date,SYSDATE) >= SYSDATE ' ||
          ' AND grants.instance_type= ''INSTANCE'' ' ||
          ' AND cmf.function_id = functions.function_id ' ||
          ' AND cmf.menu_id = grants.menu_id ' ||
          ' AND grants.object_id = ' || l_object_id ||
          ' AND functions.function_name = ''' || p_function || '''' ||
          ' AND   (   (    grants.grantee_type = ''USER'' ' ||
                    ' AND grants.grantee_key = '''||l_user_name||''')'||
                 ' OR (   grants.grantee_type = ''GROUP'' '||
                    ' AND grants.grantee_key in '||
                      ' ( '|| l_group_info || ')) ' ||
                 ' OR (   grants.grantee_type = ''COMPANY'' '||
                    ' AND grants.grantee_key in '||
                      ' ( '|| l_company_info || ')) ' ||
                 ' OR (grants.grantee_type = ''GLOBAL'' AND grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL'') )))';
        else
    l_aggregate_predicate :=
           l_aggregate_predicate ||
          ' SELECT INSTANCE_PK1_VALUE' ||
          ' FROM fnd_grants grants, ' ||
               ' fnd_form_functions functions, ' ||
               ' fnd_menu_entries cmf ' ||
          ' WHERE grants.INSTANCE_PK1_VALUE=to_char('||p_pk1_alias||')'||
          ' AND NVL(grants.end_date,SYSDATE) >= SYSDATE ' ||
          ' AND grants.instance_type= ''INSTANCE'' ' ||
          ' AND cmf.function_id = functions.function_id ' ||
          ' AND cmf.menu_id = grants.menu_id ' ||
          ' AND grants.object_id = ' || l_object_id ||
          ' AND functions.function_name = ''' || p_function || '''' ||
          ' AND   (   (    grants.grantee_type = ''USER'' ' ||
                    ' AND grants.grantee_key = '''||l_user_name||''')'||
                 ' OR (   grants.grantee_type = ''GROUP'' '||
                    ' AND grants.grantee_key in '||
                      ' ( '|| l_group_info || ')) ' ||
                 ' OR (   grants.grantee_type = ''COMPANY'' '||
                    ' AND grants.grantee_key in '||
                      ' ( '|| l_company_info || ')) ' ||
                 ' OR (grants.grantee_type = ''GLOBAL'' AND grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL'') )))';
         end if;
    --R12C Security Changes
    END IF;

      -- Step 3.
    l_set_predicates:='';
    -- R12C Security Changes
    /*l_sub_pred_clause:= ' UNION ALL  ( SELECT to_char('
                   ||l_pk_orig_column_names || ') FROM ' ||
                   l_db_object_name ||
                   ' WHERE ' || l_pk_orig_column_names||'='||p_pk1_alias ||
                   ' AND ';*/
     IF (p_object_name = 'EGO_ITEM') THEN
       l_sub_pred_clause:= ' UNION ALL  ( SELECT to_char('
                   ||l_pk_orig_column_names || ') FROM ' ||
                   l_db_object_name ||
                   ' , ego_item_cat_denorm_hier cathier WHERE ' || l_pk_orig_column_names||'='||p_pk1_alias ||
                   ' AND ';
     ELSE
      l_sub_pred_clause:= ' UNION ALL  ( SELECT to_char('
                   ||l_pk_orig_column_names || ') FROM ' ||
                   l_db_object_name ||
                   ' WHERE ' || l_pk_orig_column_names||'='||p_pk1_alias ||
                   ' AND ';
     END IF;
     -- R12C Security Changes

    IF(l_instance_set_flag = TRUE) THEN
      l_dynamic_sql_1 :=
      ' SELECT DISTINCT instance_sets.predicate ' ||
        ' FROM fnd_grants grants, fnd_form_functions functions, ' ||
             ' fnd_menu_entries cmf, fnd_object_instance_sets instance_sets ' ||
       ' WHERE grants.instance_type = :instance_type ' ||
         ' AND grants.start_date <= SYSDATE ' ||
         ' AND NVL(grants.end_date,SYSDATE) >= SYSDATE ' ||
         ' AND cmf.function_id = functions.function_id ' ||
         ' AND cmf.menu_id = grants.menu_id ' ||
         ' AND grants.instance_set_id = instance_sets.instance_set_id ' ||
         ' AND grants.object_id = :object_id ' ||
         ' AND functions.function_name = :function ' ||
         ' AND ((grants.grantee_type = ''USER'' ' ||
               ' AND grants.grantee_key = :grantee_key )' ||
              ' OR (grants.grantee_type = ''GROUP'' ' ||
                  ' AND grants.grantee_key in ( '||l_group_info||' ))' ||
              ' OR (grants.grantee_type = ''COMPANY'' ' ||
                  ' AND grants.grantee_key in ( '||l_company_info||' ))' ||
              ' OR (grants.grantee_type = ''GLOBAL'' ' ||
                  ' AND grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL''))) ';
      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'Binds for instance_set_grants_c '||
                   ' G_TYPE_SET: '||G_TYPE_SET||
                   ' - l_parent_object_id: '||l_object_id||
                   ' - p_function: '||p_function||
                   ' - l_user_name: '||l_user_name
                 );

      OPEN instance_set_grants_c FOR l_dynamic_sql_1
      USING IN G_TYPE_SET,
            IN l_object_id,
            IN p_function,
            IN l_user_name;
      LOOP
        FETCH instance_set_grants_c  INTO l_one_set_predicate;
        EXIT WHEN instance_set_grants_c%NOTFOUND;
        l_set_predicates := l_set_predicates ||
                            l_sub_pred_clause ||
                            l_one_set_predicate ||')';
      END LOOP;
      CLOSE instance_set_grants_c;
      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'l_set_predicates: '||l_set_predicates
                 );

      IF( length(l_set_predicates ) >0) THEN
         -- strip off the trailing 'OR '
         /*l_set_predicates := substr(l_set_predicates, 1,
                        length(l_set_predicates) - length('OR '));
         */

        IF(length(l_aggregate_predicate) >0 ) THEN
          -- strip off the trailing ')'
          l_aggregate_predicate := substr(l_aggregate_predicate, 1,
                      length(l_aggregate_predicate) - length(')'));

          l_aggregate_predicate := substrb(
               l_aggregate_predicate ||
                l_set_predicates || ')', 1, g_pred_buf_size);
        ELSE
          l_aggregate_predicate:= l_set_predicates;
        END IF;
      END IF;
    END IF;

    x_predicate := l_aggregate_predicate;

    if ((lengthb(l_aggregate_predicate) > g_vpd_buf_limit)
        AND (p_statement_type = 'BASE'))then
      FND_MESSAGE.SET_NAME('FND', 'GENERIC-INTERNAL ERROR');
      FND_MESSAGE.SET_TOKEN('ROUTINE',
        'EGO_DATA_SECURITY.GET_SECURITY_PREDICATE');
      FND_MESSAGE.SET_TOKEN('REASON',
      'The predicate was longer than the database VPD limit of '||
      to_char(g_vpd_buf_limit)||' bytes for the predicate.  ');
      x_return_status := 'L'; /* Indicate Error */
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   =>  'Returning Status: '||x_return_status||' as predicate size is more'
                 );
    end if;
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   =>  'Returning Status: '||x_return_status
               );
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   =>  'Returning Predicate: '||x_predicate
               );

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE',G_PKG_NAME||l_api_name);
      fnd_message.set_token('ERRNO', SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      x_return_status := G_RETURN_UNEXP_ERR;
      code_debug (p_log_level => G_DEBUG_LEVEL_EXCEPTION
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning EXCEPTION '||SQLERRM
                  );
      return;
  END get_sec_predicate_with_exists;

--------------------------------------------------------
----    get_sec_predicate_with_clause
--------------------------------------------------------
  PROCEDURE get_sec_predicate_with_clause
  (
    p_api_version      IN  NUMBER,
    p_function         IN  VARCHAR2 default null,
    p_object_name      IN  VARCHAR2,
    p_grant_instance_type  IN  VARCHAR2 DEFAULT 'UNIVERSAL',/* SET, INSTANCE*/
    p_party_id         IN  NUMBER,
    p_append_inst_set_predicate  IN  VARCHAR2 default null,
    /* stmnt_type: 'OTHER', 'BASE'=VPD, 'EXISTS'= for checking existence. */
    p_statement_type   IN  VARCHAR2 DEFAULT 'OTHER',
    p_pk1_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk2_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk3_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk4_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk5_alias        IN  VARCHAR2 DEFAULT NULL,
    x_predicate        OUT NOCOPY varchar2,
    x_return_status    OUT NOCOPY varchar2
  )  IS
    l_api_name   CONSTANT VARCHAR2(50)  := 'GET_SEC_PREDICATE_WITH_CLAUSE';

        -- On addition of any Required parameters the major version needs
        -- to change i.e. for eg. 1.X to 2.X.
        -- On addition of any Optional parameters the minor version needs
        -- to change i.e. for eg. X.6 to X.7.
    l_api_version  CONSTANT NUMBER := 1.0;
    l_sysdate               DATE := Sysdate;
    l_aggregate_predicate   VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_instance_flag         BOOLEAN   DEFAULT TRUE;
    l_instance_set_flag     BOOLEAN   DEFAULT TRUE;
    l_set_predicates        VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_db_object_name        varchar2(30);
    l_db_pk1_column         varchar2(61);
    l_db_pk2_column         varchar2(61);
    l_db_pk3_column         varchar2(61);
    l_db_pk4_column         varchar2(61);
    l_db_pk5_column         varchar2(61);
    l_pk_column_names       varchar2(512);
    l_pk_orig_column_names  varchar2(512);
    l_type_converted_val_cols varchar2(512);
    l_user_name             varchar2(80);
    l_orig_system           varchar2(48);
    l_orig_system_id        NUMBER;
    l_sub_pred_clause       varchar2(512);

    l_group_info            VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_company_info          VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_prof_privilege_tbl    EGO_VARCHAR_TBL_TYPE;
    l_dynamic_sql           VARCHAR2(32767);
    instance_set_grants_c   DYNAMIC_CUR;
    l_set_predicate         VARCHAR2(32767);

    CURSOR get_user_grantee_key (cp_party_id NUMBER) IS
       --SELECT decode (party_type,'PERSON','HZ_PARTY:'||party_id,'GROUP','HZ_GROUP:'||party_id,'ORGANIZATION','HZ_COMPANY:'||party_id) grantee_key
       SELECT party_type
       FROM hz_parties
       WHERE party_id=cp_party_id;
     l_object_id       NUMBER;
     p_user_name       FND_GRANTS.grantee_key%TYPE;
     l_party_type      VARCHAR2(30);
     l_append_inst_set_predicate   VARCHAR2(2000);
  BEGIN

    SetGlobals();
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   =>  'Started with 14 params '||
                   ' p_api_version: '|| to_char(p_api_version) ||
                   ' - p_function: '|| p_function ||
                   ' - p_object_name: '|| p_object_name ||
                   ' - p_grant_instance_type: '|| p_grant_instance_type ||
                   ' - p_party_id: '|| p_party_id ||
                   ' - p_append_inst_set_predicate: '|| p_append_inst_set_predicate ||
                   ' - p_statement_type: '|| p_statement_type ||
                   ' - p_pk1_alias: '|| p_pk1_alias ||
                   ' - p_pk2_alias: '|| p_pk2_alias ||
                   ' - p_pk3_alias: '|| p_pk3_alias ||
                   ' - p_pk4_alias: '|| p_pk4_alias ||
                   ' - p_pk5_alias: '|| p_pk5_alias
               );

    -- check for call compatibility.
    if TRUNC(l_api_version) <> TRUNC(p_api_version) THEN
      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE',
                            g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON',
         'Unsupported version '|| to_char(p_api_version)||
         ' passed to API; expecting version '||
         to_char(l_api_version));
      x_return_status := G_RETURN_UNEXP_ERR; /* Unexpected Error */
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning as the call in incompatible '
                 );
      return;
    END IF;

    -- Check to make sure we're not using unsupported statement_type
    if ((p_statement_type <> 'BASE') and (p_statement_type <>  'OTHER')
        AND (p_statement_type <> 'EXISTS')) then
      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE',
                             g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON',
         'Unsupported p_statement_type: '|| p_statement_type);
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning as statement type is not supported'
                 );
      x_return_status := G_RETURN_UNEXP_ERR; /* Unexpected Error */
      return;
    end if;

    /* ### We haven't yet added support for NULL (all) function in arg. */
    /* ### Add that support since it is in the API. */
    if (p_function is NULL) then
      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE',
                             g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON',
         'Support has not yet been added for passing NULL function.');
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning as mand parameter Function is not available '
                 );
      x_return_status := G_RETURN_UNEXP_ERR; /* Unexpected Error */
      return;
    end if;

    -- Check to make sure we're not using unsupported modes
     if ((p_grant_instance_type = 'SET')
     AND((p_pk1_alias is not NULL)
         OR (p_pk2_alias is not NULL)
         OR (p_pk3_alias is not NULL)
         OR (p_pk4_alias is not NULL)
         OR (p_pk5_alias is not NULL))) then
      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE',
                             g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON',
         'Unsupported mode arguments: '||
         'p_statement_type = BASE or p_grant_instance_type = SET.');
       code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                  ,p_module    => l_api_name
                  ,p_message   => 'Returning as incompatible combination for p_grant_instance_type = SET  '
                  );
      x_return_status := G_RETURN_UNEXP_ERR; /* Unexpected Error */
      return;
    end if;

    /* We don't currently support BASE mode; we will have to change to */
    /* a pure OR statement when VPD becomes important. */
    if (p_statement_type = 'BASE') then
      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE',
                             g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON',
         'Support has not yet been added for '||
         'p_statement_type = BASE.');
       code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                  ,p_module    => l_api_name
                  ,p_message   => 'Returning as incompatible statement_type = BASE '
                  );
      x_return_status := G_RETURN_UNEXP_ERR; /* Unexpected Error */
      return;
    end if;

    x_return_status := G_RETURN_SUCCESS; /* Assume Success */
    -- Default the user name if not passed in.
    if(p_user_name is NULL) then
       l_user_name := FND_GLOBAL.USER_NAME;
    else
       l_user_name := p_user_name;
    end if;

    -- Get the key columns from the user name
    -- We are not checking for NULL returns (meaning user not in wf_roles)
    -- because right now we allow checking of grants to users not in
    -- wf_roles.

    IF(p_party_id=-1000) THEN
       l_party_type:='GLOBAL';
    ELSE
       OPEN   get_user_grantee_key (cp_party_id=>p_party_id);
       FETCH get_user_grantee_key INTO l_party_type;
       CLOSE get_user_grantee_key;
    END IF;
    l_orig_system_id:=p_party_id;
    IF(l_party_type='GLOBAL') THEN
       l_orig_system:='HZ_GLOBAL';
    ELSIF(l_party_type='GROUP') THEN
       l_orig_system:='HZ_GROUP';
    ELSIF(l_party_type='ORGANIZATION') THEN
       l_orig_system:='HZ_COMPANY';
    ELSIF(l_party_type='PERSON') THEN
       l_orig_system:='HZ_PARTY';
    END IF;
    l_user_name:=l_orig_system||':'||l_orig_system_id;

    -----------------------------------------------------------------------------------
    --First we see if a profile option is set and if function exists                                --
    -- if so we return and empty predicate here itself without doing further query   --
    -----------------------------------------------------------------------------------

    getPrivilege_for_profileOption(p_api_version    => p_api_version,
                                   p_object_name    => p_object_name,
                                   p_user_name      => l_user_name,
                                   x_privilege_tbl  => l_prof_privilege_tbl,
                                   x_return_status  => x_return_status);

    IF (x_return_status = G_RETURN_SUCCESS) THEN
      IF (l_prof_privilege_tbl.COUNT > 0) THEN
        FOR i IN l_prof_privilege_tbl.first .. l_prof_privilege_tbl.last LOOP
           IF (l_prof_privilege_tbl(i) = p_function) THEN
              x_predicate := '';
              code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                         ,p_module    => l_api_name
                         ,p_message   => 'No need for predicate as user has privilege through profile '
                         );
              RETURN;
           END IF; --if function match, returning empty predicate
        END LOOP;
      END IF; -- x_prof_privilege_tbl >0
    END IF; --return status is T

    -- Step 1.
    -- check whether there is any grant for this use for any role that
    -- includes the given privilege

    IF (p_grant_instance_type = G_TYPE_INSTANCE) THEN
        l_instance_set_flag:= FALSE;
    ELSIF (p_grant_instance_type = G_TYPE_SET) THEN
        l_instance_flag:= FALSE;
    END IF;

    x_return_status := get_pk_information(p_object_name  ,
                         l_db_pk1_column  ,
                         l_db_pk2_column  ,
                         l_db_pk3_column  ,
                         l_db_pk4_column  ,
                         l_db_pk5_column  ,
                         l_pk_column_names  ,
                         l_type_converted_val_cols  ,
                         l_pk_orig_column_names,
                         l_db_object_name,
                         p_pk1_alias,
                         p_pk2_alias,
                         p_pk3_alias,
                         p_pk4_alias,
                         p_pk5_alias );
    if (x_return_status <> G_RETURN_SUCCESS) then
      /* There will be a message on the msg dict stack. */
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning FALSE as pk values are not correct'
                  );
      return;  /* We will return the x_return_status as out param */
    end if;

    l_object_id :=get_object_id(p_object_name => p_object_name );
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_object_id: '||l_object_id
               );
    l_group_info := get_group_info(p_party_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_group_info: '||l_group_info
               );
    l_company_info := get_company_info (p_party_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_company_info: '||l_company_info
               );

    -- Step 2.
    l_aggregate_predicate  := '';
    IF(l_instance_flag = TRUE) THEN
       if (p_statement_type = 'EXISTS') then
          l_aggregate_predicate := 'EXISTS (';
       else
          l_aggregate_predicate := 'to_char('||l_pk_column_names || ') IN (';
       end if;
       -- R12C Security Predicate
     /*  l_aggregate_predicate :=
           l_aggregate_predicate ||
          ' SELECT INSTANCE_PK1_VALUE' ||
          ' FROM fnd_grants grants, ' ||
               ' fnd_form_functions functions, ' ||
               ' fnd_menu_entries cmf ' ||
          ' WHERE grants.start_date <= sysdate ' ||
          ' AND NVL(grants.end_date,SYSDATE) >= SYSDATE ' ||
          ' AND grants.instance_type= ''INSTANCE'' ' ||
          ' AND cmf.function_id = functions.function_id ' ||
          ' AND cmf.menu_id = grants.menu_id ' ||
          ' AND grants.object_id = ' || l_object_id ||
          ' AND functions.function_name = ''' || p_function   || '''' ||
          ' AND   (   (    grants.grantee_type = ''USER'' ' ||
                    ' AND grants.grantee_key = '''||l_user_name||''')'||
                 ' OR (   grants.grantee_type = ''GROUP'' '||
                    ' AND grants.grantee_key in '||
                    ' ( '|| l_group_info || ')) ' ||
                 ' OR (   grants.grantee_type = ''COMPANY'' '||
                    ' AND grants.grantee_key in '||
                    ' ( '|| l_company_info || ')) ' ||
                 ' OR (grants.grantee_type = ''GLOBAL'' AND grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL'') )))';*/
       if (p_object_name = 'EGO_CATALOG_GROUP') THEN
         l_aggregate_predicate := l_aggregate_predicate ||
            ' SELECT INSTANCE_PK1_VALUE' ||
            ' FROM fnd_grants grants, ' ||
                 ' fnd_form_functions functions, ' ||
                 ' fnd_menu_entries cmf, ' ||
           'ego_item_cat_denorm_hier cathier ' ||
      'WHERE grants.INSTANCE_PK1_VALUE=to_char(cathier.parent_catalog_group_id) '||
      'AND cathier.child_catalog_group_id = to_char('||p_pk1_alias||')' ||
            ' AND grants.start_date <= sysdate ' ||
            ' AND NVL(grants.end_date,SYSDATE) >= SYSDATE ' ||
            ' AND grants.instance_type= ''INSTANCE'' ' ||
            ' AND cmf.function_id = functions.function_id ' ||
            ' AND cmf.menu_id = grants.menu_id ' ||
            ' AND grants.object_id = ' || l_object_id ||
            ' AND functions.function_name = ''' || p_function   || '''' ||
            ' AND   (   (    grants.grantee_type = ''USER'' ' ||
                      ' AND grants.grantee_key = '''||l_user_name||''')'||
                   ' OR (   grants.grantee_type = ''GROUP'' '||
                      ' AND grants.grantee_key in '||
                      ' ( '|| l_group_info || ')) ' ||
                   ' OR (   grants.grantee_type = ''COMPANY'' '||
                      ' AND grants.grantee_key in '||
                      ' ( '|| l_company_info || ')) ' ||
                   ' OR (grants.grantee_type = ''GLOBAL'' AND grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL'') )))';
       else
         l_aggregate_predicate := l_aggregate_predicate ||
            ' SELECT INSTANCE_PK1_VALUE' ||
            ' FROM fnd_grants grants, ' ||
                 ' fnd_form_functions functions, ' ||
                 ' fnd_menu_entries cmf ' ||
            ' WHERE grants.start_date <= sysdate ' ||
            ' AND NVL(grants.end_date,SYSDATE) >= SYSDATE ' ||
            ' AND grants.instance_type= ''INSTANCE'' ' ||
            ' AND cmf.function_id = functions.function_id ' ||
            ' AND cmf.menu_id = grants.menu_id ' ||
            ' AND grants.object_id = ' || l_object_id ||
            ' AND functions.function_name = ''' || p_function   || '''' ||
            ' AND   (   (   grants.grantee_type = ''USER'' ' ||
                      ' AND grants.grantee_key = '''||l_user_name||''')'||
                   ' OR (   grants.grantee_type = ''GROUP'' '||
                      ' AND grants.grantee_key in '||
                      ' ( '|| l_group_info || ')) ' ||
                   ' OR (   grants.grantee_type = ''COMPANY'' '||
                      ' AND grants.grantee_key in '||
                      ' ( '|| l_company_info || ')) ' ||
                   ' OR (grants.grantee_type = ''GLOBAL'' AND grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL'') )))';
       end if;
-- R12C Security Predicate
    END IF;

    -- Step 3.
    l_set_predicates:='';
    -- R12C Security Changes
    /*l_sub_pred_clause:=' UNION ALL  ( SELECT to_char(' ||
                   l_pk_orig_column_names || ') FROM ' ||
                   l_db_object_name || ' WHERE ';*/
    IF (p_object_name = 'EGO_ITEM') THEN
      l_sub_pred_clause:=' UNION ALL  ( SELECT to_char(' ||
                   l_pk_orig_column_names || ') FROM ' ||
                   l_db_object_name || ', ego_item_cat_denorm_hier cathier WHERE  item_catalog_group_id = cathier.child_catalog_group_id AND ';
    ELSE
      l_sub_pred_clause:=' UNION ALL  ( SELECT to_char(' ||
                   l_pk_orig_column_names || ') FROM ' ||
                   l_db_object_name || ' WHERE ';
    END IF;

    -- R12C Security Changes
    IF(p_append_inst_set_predicate IS NULL) THEN
       l_append_inst_set_predicate:='';
    ELSE
       l_append_inst_set_predicate:=' AND '||p_append_inst_set_predicate;
    END IF;

    IF(l_instance_set_flag = TRUE) THEN
      l_dynamic_sql :=
        ' SELECT DISTINCT instance_sets.predicate ' ||
          ' FROM fnd_grants grants, fnd_form_functions functions, ' ||
               ' fnd_menu_entries cmf, fnd_object_instance_sets instance_sets ' ||
         ' WHERE grants.instance_type = :instance_type ' ||
           ' AND grants.start_date <= SYSDATE ' ||
           ' AND NVL(grants.end_date,SYSDATE) >= SYSDATE ' ||
           ' AND cmf.function_id = functions.function_id ' ||
           ' AND cmf.menu_id = grants.menu_id ' ||
           ' AND grants.instance_set_id = instance_sets.instance_set_id ' ||
           ' AND grants.object_id = :object_id ' ||
           ' AND functions.function_name = :function ' ||
           ' AND ((grants.grantee_type = ''USER'' ' ||
                 ' AND grants.grantee_key = :grantee_key )' ||
                ' OR (grants.grantee_type = ''GROUP'' ' ||
                    ' AND grants.grantee_key in ( '||l_group_info||' ))' ||
                ' OR (grants.grantee_type = ''COMPANY'' ' ||
                    ' AND grants.grantee_key in ( '||l_company_info||' ))' ||
                ' OR (grants.grantee_type = ''GLOBAL'' ' ||
                    ' AND grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL''))) ';

      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'Binds for instance_set_grants_c '||
                   ' G_TYPE_SET: '||G_TYPE_SET||
                   ' - l_parent_object_id: '||l_object_id||
                   ' - p_function: '||p_function||
                   ' - l_user_name: '||l_user_name
                 );

      OPEN instance_set_grants_c FOR l_dynamic_sql
      USING IN G_TYPE_SET,
            IN l_object_id,
            IN p_function,
            IN l_user_name;
      LOOP
        FETCH instance_set_grants_c into l_set_predicate;
        EXIT WHEN instance_set_grants_c%NOTFOUND;
        l_set_predicates  := l_set_predicates ||l_sub_pred_clause||
                             l_set_predicate ||
                              l_append_inst_set_predicate||')';
      END LOOP;
      CLOSE instance_set_grants_c;
      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'l_set_predicates: '||l_set_predicates
                 );

      IF( length(l_set_predicates ) >0) THEN
        -- strip off the trailing 'OR '
        IF(length(l_aggregate_predicate) >0 ) THEN
           -- strip off the trailing ')'
           l_aggregate_predicate := substr(l_aggregate_predicate, 1,
                       length(l_aggregate_predicate) - length(')'));
           l_aggregate_predicate := substrb(
                 l_aggregate_predicate ||
                 l_set_predicates  || ')', 1, g_pred_buf_size);
         ELSE
            l_aggregate_predicate:= l_set_predicates;
         END IF;
      END IF;
    END IF;

    x_predicate :=l_aggregate_predicate;

    if (    (lengthb(l_aggregate_predicate) > g_vpd_buf_limit)
            AND (p_statement_type = 'BASE'))then
      FND_MESSAGE.SET_NAME('FND', 'GENERIC-INTERNAL ERROR');
      FND_MESSAGE.SET_TOKEN('ROUTINE','EGO_DATA_SECURITY.GET_SECURITY_PREDICATE');
      FND_MESSAGE.SET_TOKEN('REASON',
       'The predicate was longer than the database VPD limit of '||
       to_char(g_vpd_buf_limit)||' bytes for the predicate.  ');
      x_return_status := 'L'; /* Indicate Error */
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   =>  'Returning Status: '||x_return_status||' as predicate size is more'
                 );
    end if;

    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   =>  'Returning Status: '||x_return_status
               );
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   =>  'Returning Predicate: '||x_predicate
               );

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE',G_PKG_NAME||l_api_name);
      fnd_message.set_token('ERRNO', SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      x_return_status := G_RETURN_UNEXP_ERR;
      code_debug (p_log_level => G_DEBUG_LEVEL_EXCEPTION
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning EXCEPTION '||SQLERRM
                  );
      return;
  END get_sec_predicate_with_clause;

--------------------------------------------------------
----    get_inherited_predicate
--------------------------------------------------------
   PROCEDURE get_inherited_predicate
  (
    p_api_version      IN  NUMBER,
    p_function         IN  VARCHAR2 default null,
    p_object_name      IN  VARCHAR2,
    p_grant_instance_type  IN  VARCHAR2 DEFAULT 'UNIVERSAL',/* SET, INSTANCE*/
    p_user_name        IN  VARCHAR2 default null,
    /* statement_type: 'OTHER', 'BASE'=VPD, 'EXISTS'= to check existence*/
    p_statement_type   IN  VARCHAR2 DEFAULT 'OTHER',
    p_pk1_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk2_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk3_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk4_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk5_alias        IN  VARCHAR2 DEFAULT NULL,
    p_object_type      IN VARCHAR2 default null,
    p_parent_object_tbl      IN EGO_VARCHAR_TBL_TYPE,
    p_relationship_sql_tbl   IN EGO_VARCHAR_TBL_TYPE,
    p_parent_obj_alias_tbl   IN EGO_VARCHAR_TBL_TYPE,
    x_predicate        OUT NOCOPY varchar2,
    x_return_status    OUT NOCOPY varchar2
  )
   IS
   BEGIN
   --null;

   EGO_DATA_SECURITY.get_inherited_predicate
        (
          p_api_version          => p_api_version,
          p_function             => p_function,
          p_object_name          => p_object_name,
          p_grant_instance_type  => p_grant_instance_type,
          p_user_name            => p_user_name,
          p_statement_type       => p_statement_type,
          p_pk1_alias            => p_pk1_alias,
          p_pk2_alias            => p_pk2_alias,
          p_pk3_alias            => p_pk3_alias,
          p_pk4_alias            => p_pk4_alias,
          p_pk5_alias            => p_pk5_alias,
          p_object_type          => p_object_type,
          p_parent_object_tbl    => p_parent_object_tbl,
          p_relationship_sql_tbl => p_relationship_sql_tbl,
          p_parent_obj_pk1alias_tbl => p_parent_obj_alias_tbl,
          p_parent_obj_pk2alias_tbl => null,
          x_predicate               => x_predicate,
          x_return_status           => x_return_status
      );

   END get_inherited_predicate;

--------------------------------------------------------
----    get_inherited_predicate
--------------------------------------------------------
PROCEDURE get_inherited_predicate
  (
    p_api_version               IN  NUMBER,
    p_function                  IN  VARCHAR2 default null,
    p_object_name               IN  VARCHAR2,
    p_grant_instance_type       IN  VARCHAR2 DEFAULT 'UNIVERSAL',/* SET, INSTANCE*/
    p_user_name                 IN  VARCHAR2 default null,
    /* statement_type: 'OTHER', 'BASE'=VPD, 'EXISTS'= to check existence*/
    p_statement_type            IN  VARCHAR2 DEFAULT 'OTHER',
    p_pk1_alias                 IN  VARCHAR2 DEFAULT NULL,
    p_pk2_alias                 IN  VARCHAR2 DEFAULT NULL,
    p_pk3_alias                 IN  VARCHAR2 DEFAULT NULL,
    p_pk4_alias                 IN  VARCHAR2 DEFAULT NULL,
    p_pk5_alias                 IN  VARCHAR2 DEFAULT NULL,
    p_object_type               IN  VARCHAR2 default null,
    p_parent_object_tbl         IN  EGO_VARCHAR_TBL_TYPE,
    p_relationship_sql_tbl      IN  EGO_VARCHAR_TBL_TYPE,
    p_parent_obj_pk1alias_tbl   IN  EGO_VARCHAR_TBL_TYPE,
    p_parent_obj_pk2alias_tbl   IN  EGO_VARCHAR_TBL_TYPE,
    x_predicate                 OUT NOCOPY varchar2,
    x_return_status             OUT NOCOPY varchar2
  )   IS
  l_clob_predicate  CLOB;
BEGIN

   EGO_DATA_SECURITY.get_inherited_predicate
        (
          p_api_version          => p_api_version,
          p_function             => p_function,
          p_object_name          => p_object_name,
          p_grant_instance_type  => p_grant_instance_type,
          p_user_name            => p_user_name,
          p_statement_type       => p_statement_type,
          p_pk1_alias            => p_pk1_alias,
          p_pk2_alias            => p_pk2_alias,
          p_pk3_alias            => p_pk3_alias,
          p_pk4_alias            => p_pk4_alias,
          p_pk5_alias            => p_pk5_alias,
          p_object_type          => p_object_type,
          p_parent_object_tbl    => p_parent_object_tbl,
          p_relationship_sql_tbl => p_relationship_sql_tbl,
          p_parent_obj_pk1alias_tbl => p_parent_obj_pk1alias_tbl,
          p_parent_obj_pk2alias_tbl => p_parent_obj_pk2alias_tbl,
          x_predicate               => x_predicate,
          x_clob_predicate          => l_clob_predicate,
          x_return_status           => x_return_status
      );

END;

--------------------------------------------------------
----    get_inherited_predicate
--------------------------------------------------------
 PROCEDURE get_inherited_predicate
  (
    p_api_version                IN  NUMBER,
    p_function                   IN  VARCHAR2 default null,
    p_object_name                IN  VARCHAR2,
    p_grant_instance_type        IN  VARCHAR2 DEFAULT 'UNIVERSAL',/* SET, INSTANCE*/
    p_user_name                  IN  VARCHAR2 default null,
    /* statement_type: 'OTHER', 'BASE'=VPD, 'EXISTS'= to check existence*/
    p_statement_type             IN  VARCHAR2 DEFAULT 'OTHER',
    p_pk1_alias                  IN  VARCHAR2 DEFAULT NULL,
    p_pk2_alias                  IN  VARCHAR2 DEFAULT NULL,
    p_pk3_alias                  IN  VARCHAR2 DEFAULT NULL,
    p_pk4_alias                  IN  VARCHAR2 DEFAULT NULL,
    p_pk5_alias                  IN  VARCHAR2 DEFAULT NULL,
    p_object_type                IN  VARCHAR2 default null,
    p_parent_object_tbl          IN  EGO_VARCHAR_TBL_TYPE,
    p_relationship_sql_tbl       IN  EGO_VARCHAR_TBL_TYPE,
    p_parent_obj_pk1alias_tbl    IN  EGO_VARCHAR_TBL_TYPE,
    p_parent_obj_pk2alias_tbl    IN  EGO_VARCHAR_TBL_TYPE,
    x_predicate                  OUT NOCOPY varchar2,
    x_clob_predicate             OUT NOCOPY CLOB,          --gnanda:Added for Bug 4756970.
    x_return_status              OUT NOCOPY varchar2
  )   IS
    l_api_name   CONSTANT VARCHAR2(30)  := 'GET_INHERITED_PREDICATE';

        -- On addition of any Required parameters the major version needs
        -- to change i.e. for eg. 1.X to 2.X.
        -- On addition of any Optional parameters the minor version needs
        -- to change i.e. for eg. X.6 to X.7.
    l_api_version  CONSTANT NUMBER := 1.0;
    l_sysdate               DATE := Sysdate;
    l_aggregate_predicate   VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_instance_flag         BOOLEAN   DEFAULT TRUE;
    l_instance_set_flag     BOOLEAN   DEFAULT TRUE;
    l_set_predicates        VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_db_object_name        VARCHAR2(30);
    l_db_pk1_column         VARCHAR2(61);
    l_db_pk2_column         VARCHAR2(61);
    l_db_pk3_column         VARCHAR2(61);
    l_db_pk4_column         VARCHAR2(61);
    l_db_pk5_column         VARCHAR2(61);

    l_orig_pk5_column         VARCHAR2(61);
    l_pk_column_names         VARCHAR2(512);
    l_pk_orig_column_names    VARCHAR2(512);
    l_type_converted_val_cols VARCHAR2(512);
    l_user_name               VARCHAR2(80);
--    l_orig_system             VARCHAR2(48);
    l_orig_system_id            NUMBER;
    l_parent_object_table_count NUMBER;
    l_table_index               NUMBER;
    l_parent_predicate          VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_parent_object_id          NUMBER;
    l_group_info                VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_company_info              VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_parent_role_info          VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_child_role                VARCHAR2(32767);
    l_profile_role              VARCHAR2(32767);
    l_pk_alias_index            NUMBER;

    l_pk_orig_column_names_t    VARCHAR2(513);
    l_orig_pk_column            VARCHAR2(61);

    l_one_set_predicate     VARCHAR2(32767);
    l_sub_pred_clause       VARCHAR2(32767);
    instance_set_grants_c   DYNAMIC_CUR;
    l_dynamic_sql_1         VARCHAR2(32767);

    parent_instance_set_grants_c DYNAMIC_CUR;
    l_dynamic_sql_2              VARCHAR2(32767);

    l_profile_optionFound         BOOLEAN DEFAULT FALSE;
    l_prof_privilege_tbl          EGO_VARCHAR_TBL_TYPE;

    l_parent_object_name         VARCHAR2(100);

    CURSOR parent_instance_set_grants_c2 (
                              cp_user_name       varchar2,
                              cp_parent_object_id VARCHAR2,
                              cp_group_info VARCHAR2,
                              cp_company_info VARCHAR2,
                              cp_function VARCHAR2,
                              cp_object_id VARCHAR2
                              )
    IS
     SELECT DISTINCT instance_sets.predicate
       FROM fnd_grants grants,
            fnd_object_instance_sets instance_sets
      WHERE grants.instance_type = 'SET'
        AND grants.start_date <= SYSDATE
        AND (   grants.end_date IS NULL
             OR grants.end_date >= SYSDATE )
        AND grants.instance_set_id = instance_sets.instance_set_id
        AND grants.object_id = cp_parent_object_id
        AND ( grants.menu_id in
         ( SELECT p.parent_role_id
           FROM fnd_menu_entries r, fnd_form_functions f,
                fnd_menus m, ego_obj_role_mappings p
           WHERE  r.function_id = f.function_id
           AND r.menu_id = m.menu_id
           AND f.function_name = cp_function
           AND m.menu_id = p.child_role_id
           AND p.child_object_id = cp_object_id
           AND P.parent_object_id = cp_parent_object_id ))
        AND  (    (    grants.grantee_type = 'USER'
                   AND grants.grantee_key = cp_user_name)
               OR (    grants.grantee_type = 'GROUP'
                   AND grants.grantee_key in
                 (  cp_group_info ))
       OR (    grants.grantee_type = 'COMPANY'
           AND grants.grantee_key in
                  ( cp_company_info ))
               OR (grants.grantee_type = 'GLOBAL'
               AND grants.grantee_key in ('HZ_GLOBAL:-1000', 'GLOBAL') ));

    CURSOR parent_role_c (
                              cp_function  VARCHAR2,
                              cp_object_id VARCHAR2,
                              cp_parent_object_id VARCHAR2,
                              cp_object_type VARCHAR2
                             )
    IS
     SELECT DISTINCT p.parent_role_id
           FROM fnd_menu_entries r, fnd_form_functions f,
                fnd_menus m, ego_obj_role_mappings p
           WHERE  r.function_id = f.function_id
           AND r.menu_id = m.menu_id
           AND f.function_name = cp_function
           AND m.menu_id = p.child_role_id
           AND p.child_object_id = cp_object_id
           AND P.parent_object_id = cp_parent_object_id
           AND p.child_object_type = cp_object_type;

    CURSOR parent_role_c2 (
                              cp_function  VARCHAR2,
                              cp_object_id VARCHAR2,
                              cp_parent_object_id VARCHAR2
                             )
    IS
     SELECT DISTINCT p.parent_role_id
           FROM fnd_menu_entries r, fnd_form_functions f,
                fnd_menus m, ego_obj_role_mappings p
           WHERE  r.function_id = f.function_id
           AND r.menu_id = m.menu_id
           AND f.function_name = cp_function
           AND m.menu_id = p.child_role_id
           AND p.child_object_id = cp_object_id
           AND P.parent_object_id = cp_parent_object_id;

    CURSOR mapped_role_c (cp_parent_role  VARCHAR2,
                          cp_parent_object_id VARCHAR2,
                          cp_child_object_id VARCHAR2,
                          cp_child_object_type VARCHAR2
                             )
    IS
      select cm.menu_name from
      fnd_menus m, ego_obj_role_mappings r, fnd_menus cm
      where r.parent_role_id = m.menu_id and
      m.menu_name = cp_parent_role
      and r.parent_object_id = cp_parent_object_id
      and r.child_object_id = cp_child_object_id
      and r.child_object_type = cp_child_object_type
      and cm.MENU_ID = r.CHILD_ROLE_ID;

     l_object_id number;
  BEGIN
    SetGlobals();

    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   =>  'Started with 19 params '||
                   ' p_api_version: '|| to_char(p_api_version) ||
                   ' - p_function: '|| p_function ||
                   ' - p_object_name: '|| p_object_name ||
                   ' - p_grant_instance_type: '|| p_grant_instance_type ||
                   ' - p_user_name: '|| p_user_name ||
                   ' - p_statement_type: '|| p_statement_type ||
                   ' - p_pk1_alias: '|| p_pk1_alias ||
                   ' - p_pk2_alias: '|| p_pk2_alias ||
                   ' - p_pk3_alias: '|| p_pk3_alias ||
                   ' - p_pk4_alias: '|| p_pk4_alias ||
                   ' - p_pk5_alias: '|| p_pk5_alias ||
                   ' - p_object_type: '|| p_object_type
               );
    IF (p_parent_object_tbl.COUNT > 0) THEN
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Values from p_parent_object_tbl '
                  );
      FOR i IN p_parent_object_tbl.first .. p_parent_object_tbl.last LOOP
        code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                   ,p_module    => l_api_name
                   ,p_message   => 'Value at '||i||' = '||p_parent_object_tbl(i)
                   );
      END LOOP;
    ELSE
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'No Values from p_parent_object_tbl '
                  );
    END IF;

    IF (p_relationship_sql_tbl.COUNT > 0) THEN
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Values from p_relationship_sql_tbl '
                  );
      FOR i IN p_relationship_sql_tbl.first .. p_relationship_sql_tbl.last LOOP
        code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                   ,p_module    => l_api_name
                   ,p_message   => 'Value at '||i||' = '||p_relationship_sql_tbl(i)
                   );
      END LOOP;
    ELSE
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'No Values from p_relationship_sql_tbl '
                  );
    END IF;

    IF (p_parent_obj_pk1alias_tbl.COUNT > 0) THEN
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Values from p_parent_obj_pk1alias_tbl '
                  );
      FOR i IN p_parent_obj_pk1alias_tbl.first .. p_parent_obj_pk1alias_tbl.last LOOP
        code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                   ,p_module    => l_api_name
                   ,p_message   => 'Value at '||i||' = '||p_parent_obj_pk1alias_tbl(i)
                   );
      END LOOP;
    ELSE
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'No Values from p_parent_obj_pk1alias_tbl '
                  );
    END IF;

    IF (p_parent_obj_pk2alias_tbl.COUNT > 0) THEN
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Values from p_parent_obj_pk2alias_tbl '
                  );
      FOR i IN p_parent_obj_pk2alias_tbl.first .. p_parent_obj_pk2alias_tbl.last LOOP
        code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                   ,p_module    => l_api_name
                   ,p_message   => 'Value at '||i||' = '||p_parent_obj_pk2alias_tbl(i)
                   );
      END LOOP;
    ELSE
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'No Values from p_parent_obj_pk2alias_tbl '
                  );
    END IF;

    -- check for call compatibility.
    if TRUNC(l_api_version) <> TRUNC(p_api_version) THEN
      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE',
                            g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON',
         'Unsupported version '|| to_char(p_api_version)||
         ' passed to API; expecting version '||
         to_char(l_api_version));
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning as the call in incompatible '
                 );
      x_return_status := G_RETURN_UNEXP_ERR; /* Unexpected Error */
      return;
    END IF;

    -- Check to make sure we're not using unsupported statement_type
    if ((p_statement_type <> 'BASE') and (p_statement_type <>  'OTHER')
        AND (p_statement_type <> 'EXISTS')) then
      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE',
                             g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON',
         'Unsupported p_statement_type: '|| p_statement_type);
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning as statement type is not supported'
                 );
      x_return_status := G_RETURN_UNEXP_ERR; /* Unexpected Error */
      return;
    end if;

    /* ### We haven't yet added support for NULL (all) function in arg. */
    /* ### Add that support since it is in the API. */
    if (p_function is NULL) then
      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE',
                             g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON',
         'Support has not yet been added for passing NULL function.');
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning as mand parameter Function is not available '
                 );
      x_return_status := G_RETURN_UNEXP_ERR; /* Unexpected Error */
      return;
    end if;

    -- Check to make sure we're not using unsupported modes
    if ((p_grant_instance_type = 'SET')
     AND((p_pk1_alias is not NULL)
         OR (p_pk2_alias is not NULL)
         OR (p_pk3_alias is not NULL)
         OR (p_pk4_alias is not NULL)
         OR (p_pk5_alias is not NULL))) then

      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE',
                             g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON',
         'Unsupported mode arguments: '||
         'p_statement_type = BASE or p_grant_instance_type = SET.');
       code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                  ,p_module    => l_api_name
                  ,p_message   => 'Returning as incompatible combination for p_grant_instance_type = SET  '
                  );
      x_return_status := G_RETURN_UNEXP_ERR; /* Unexpected Error */
      return;
    end if;

    /* We don't currently support BASE mode; we will have to change to */
    /* a pure OR statement when VPD becomes important. */
    if (p_statement_type = 'BASE') then
      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE',
                             g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON',
         'Support has not yet been added for '||
         'p_statement_type = BASE.');
       code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                  ,p_module    => l_api_name
                  ,p_message   => 'Returning as incompatible statement_type = BASE '
                  );
      x_return_status := G_RETURN_UNEXP_ERR; /* Unexpected Error */
      return;
    end if;

    x_return_status := G_RETURN_SUCCESS; /* Assume Success */
    l_user_name := p_user_name;
    get_orig_key(x_user_name      => l_user_name
--                ,x_orig_system    => l_orig_system
                ,x_orig_system_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_user_name: '||l_user_name||
--                               ' - l_orig_system: '||l_orig_system||
                               ' - l_orig_system_id: '||l_orig_system_id
               );
    -----------------------------------------------------------------------------------
    --First we see if a profile option is set and if function exists                 --
    -- if so we return and empty predicate here itself without doing further query   --
    -----------------------------------------------------------------------------------

    getPrivilege_for_profileOption(p_api_version          => p_api_version,
                                   p_object_name          => p_object_name,
                                   p_user_name            => l_user_name,
                                   x_privilege_tbl        => l_prof_privilege_tbl,
                                   x_return_status        => x_return_status);

    If (X_Return_Status = G_RETURN_SUCCESS) Then
      If (l_prof_privilege_tbl.Count > 0) Then
        For I In l_prof_privilege_tbl.First .. l_prof_privilege_tbl.Last Loop
          If (l_prof_privilege_tbl(I) = p_function) Then
              X_predicate := '';
              code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                         ,p_module    => l_api_name
                         ,p_message   => 'No need for predicate as user has privilege through profile '
                         );
              return;
          End If; --If Function Match, Returning Empty Predicate
        End Loop;
      End If; -- X_Prof_Privilege_Tbl >0
    End If; --Return Status Is T

    -- Step 1.
    -- check whether there is any grant for this use for any role that
    -- includes the given privilege

    IF (p_grant_instance_type = G_TYPE_INSTANCE) THEN
      l_instance_set_flag:= FALSE;
    ELSIF (p_grant_instance_type = G_TYPE_SET) THEN
      l_instance_flag:= FALSE;
    END IF;

    x_return_status := get_pk_information(p_object_name  ,
                             l_db_pk1_column  ,
                             l_db_pk2_column  ,
                             l_db_pk3_column  ,
                             l_db_pk4_column  ,
                             l_db_pk5_column  ,
                             l_pk_column_names  ,
                             l_type_converted_val_cols  ,
                             l_pk_orig_column_names,
                             l_db_object_name,
                             p_pk1_alias,
                             p_pk2_alias,
                             p_pk3_alias,
                             p_pk4_alias,
                             p_pk5_alias );
    if (x_return_status <> G_RETURN_SUCCESS) then
            /* There will be a message on the msg dict stack. */
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning FALSE as pk values are not correct'
                  );
      return;  /* We will return the x_return_status as out param */
    end if;

    l_object_id :=get_object_id(p_object_name => p_object_name );
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_object_id: '||l_object_id
               );
    l_group_info := get_group_info(p_party_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_group_info: '||l_group_info
               );
    l_company_info := get_company_info (p_party_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_company_info: '||l_company_info
               );

    -- Step 2.
    l_aggregate_predicate  := '';
    IF(l_instance_flag = TRUE) THEN
      if (p_statement_type = 'EXISTS') then
         l_aggregate_predicate := 'EXISTS (';
      else
         l_aggregate_predicate := l_pk_column_names || ' IN (';
      end if;
      l_aggregate_predicate :=
          l_aggregate_predicate ||
         ' SELECT '||l_type_converted_val_cols ||
         ' FROM fnd_grants grants, ' ||
              ' fnd_form_functions functions, ' ||
              ' fnd_menu_entries cmf ';

      if (p_statement_type = 'EXISTS') then
      -- R12C Security Changes
       /*  l_aggregate_predicate := l_aggregate_predicate ||
         ' WHERE grants.INSTANCE_PK1_VALUE=to_char('||p_pk1_alias||')'||
         ' AND grants.start_date <= sysdate '; */
    if (p_object_name = 'EGO_CATALOG_GROUP') THEN
     l_aggregate_predicate := l_aggregate_predicate ||  ' , ego_item_cat_denorm_hier cathier ' ||
     ' WHERE grants.INSTANCE_PK1_VALUE = to_char(cathier.parent_catalog_group_id)' ||
     ' AND cathier.child_catalog_group_id = to_char('||p_pk1_alias||')' ||
     ' AND grants.start_date <= sysdate ';
    else
           l_aggregate_predicate := l_aggregate_predicate ||
           ' WHERE grants.INSTANCE_PK1_VALUE=to_char('||p_pk1_alias||')'||
           ' AND grants.start_date <= sysdate ';
     end if;
      -- R12C Security Changes
      else
          l_aggregate_predicate := l_aggregate_predicate ||
          ' WHERE grants.start_date <= sysdate ';
      end if;

       l_aggregate_predicate := l_aggregate_predicate ||
         ' AND (    grants.end_date IS NULL ' ||
              ' OR grants.end_date >= sysdate ) ' ||
         ' AND grants.instance_type= ''INSTANCE'' ' ||
         ' AND cmf.function_id = functions.function_id ' ||
         ' AND cmf.menu_id = grants.menu_id ' ||
         ' AND grants.object_id = ' || l_object_id ||
         ' AND functions.function_name = ''' || p_function   || '''' ||
         ' AND   (   (    grants.grantee_type = ''USER'' ' ||
                   ' AND grants.grantee_key = '''||l_user_name||''')'||
                ' OR (   grants.grantee_type = ''GROUP'' '||
                   ' AND grants.grantee_key in '||
                    ' ( '|| l_group_info || ')) ' ||
                ' OR (    grants.grantee_type = ''COMPANY'' '||
                   ' AND grants.grantee_key in '||
                     ' ( '|| l_company_info || ')) ' ||
                 ' OR (grants.grantee_type = ''GLOBAL'' AND grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL'') )))';
    END IF;

    -- Step 3.
    l_set_predicates:='';
    l_sub_pred_clause:= ' UNION ALL  ( SELECT '
                     ||l_pk_orig_column_names || ' FROM ' ||
                     l_db_object_name ||
                     ' WHERE ' || l_pk_orig_column_names||'='||p_pk1_alias ||
                     ' and ';

    IF(l_instance_set_flag = TRUE) THEN
      l_dynamic_sql_1 :=
      ' SELECT DISTINCT instance_sets.predicate ' ||
        ' FROM fnd_grants grants, fnd_form_functions functions, ' ||
             ' fnd_menu_entries cmf, fnd_object_instance_sets instance_sets ' ||
       ' WHERE grants.instance_type = :instance_type ' ||
         ' AND grants.start_date <= SYSDATE ' ||
         ' AND NVL(grants.end_date,SYSDATE) >= SYSDATE ' ||
         ' AND cmf.function_id = functions.function_id ' ||
         ' AND cmf.menu_id = grants.menu_id ' ||
         ' AND grants.instance_set_id = instance_sets.instance_set_id ' ||
         ' AND grants.object_id = :object_id ' ||
         ' AND functions.function_name = :function ' ||
         ' AND ((grants.grantee_type = ''USER'' ' ||
               ' AND grants.grantee_key = :grantee_key )' ||
              ' OR (grants.grantee_type = ''GROUP'' ' ||
                  ' AND grants.grantee_key in ( '||l_group_info||' ))' ||
              ' OR (grants.grantee_type = ''COMPANY'' ' ||
                  ' AND grants.grantee_key in ( '||l_company_info||' ))' ||
              ' OR (grants.grantee_type = ''GLOBAL'' ' ||
                  ' AND grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL''))) ';
      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'Binds for instance_set_grants_c '||
                   ' G_TYPE_SET: '||G_TYPE_SET||
                   ' - l_parent_object_id: '||l_object_id||
                   ' - p_function: '||p_function||
                   ' - l_user_name: '||l_user_name
                 );

      OPEN instance_set_grants_c FOR l_dynamic_sql_1
      USING IN G_TYPE_SET,
            IN l_object_id,
            IN p_function,
            IN l_user_name;
      LOOP
          FETCH instance_set_grants_c  INTO l_one_set_predicate;
          EXIT WHEN instance_set_grants_c%NOTFOUND;
          l_set_predicates := l_set_predicates ||
                              l_sub_pred_clause ||
                              l_one_set_predicate ||')';
      END LOOP;
      CLOSE instance_set_grants_c;

      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'l_set_predicates: '||l_set_predicates
                 );
      IF( length(l_set_predicates ) >0) THEN
        IF(length(l_aggregate_predicate) >0 ) THEN
           -- strip off the trailing ')'
           l_aggregate_predicate := substr(l_aggregate_predicate, 1,
                       length(l_aggregate_predicate) - length(')'));
           l_aggregate_predicate := substrb(
                l_aggregate_predicate ||
                 l_set_predicates || ')', 1, g_pred_buf_size);
        ELSE
           l_aggregate_predicate:= l_set_predicates;
        END IF;
      END IF;
    END IF;

    l_dynamic_sql_2 :=
        ' SELECT DISTINCT instance_sets.predicate '||
          ' FROM fnd_grants grants, '||
               ' fnd_object_instance_sets instance_sets,' ||
               ' fnd_form_functions F, fnd_menu_entries R, '||
               ' fnd_menus M, ego_obj_role_mappings P '||
        '  WHERE grants.instance_type = ''SET'' '||
           ' AND grants.start_date <= SYSDATE ' ||
           ' AND NVL(grants.end_date,SYSDATE) >= SYSDATE '||
           ' AND grants.instance_set_id = instance_sets.instance_set_id '||
           ' AND instance_sets.object_id =  :parent_object_id ' ||
           ' AND grants.object_id =  :parent_object_id1 '  ||
           ' AND grants.menu_id = p.parent_role_id ' ||
           ' AND r.function_id = f.function_id '||
           ' AND r.menu_id = m.menu_id ' ||
           ' AND f.function_name = :function_id '||
           ' AND m.menu_id = p.child_role_id ' ||
           ' AND p.child_object_id = :child_object_id '||
           ' AND p.parent_object_id = :parent_object_id2 '||
           ' AND p.child_object_type = :child_object_type ' ||
           ' AND ( ( grants.grantee_type = ''USER'' AND ' ||
                 ' grants.grantee_key = :user_name ) '||
                 ' OR (grants.grantee_type = ''GROUP'' AND '||
                 ' grants.grantee_key in ( '||l_group_info||' ))' ||
                 ' OR (grants.grantee_type = ''COMPANY'' AND '||
                 ' grants.grantee_key in ( '||l_company_info||' ))' ||
                 ' OR (grants.grantee_type = ''GLOBAL'' AND '||
                 ' grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL'') ))';

    l_aggregate_predicate := substr(l_aggregate_predicate, 1,
                          length(l_aggregate_predicate) - length(')'));

    l_parent_object_table_count := p_parent_object_tbl.COUNT;

    FOR l_table_index IN 1..l_parent_object_table_count
    LOOP

     x_return_status := get_pk_information(p_parent_object_tbl(l_table_index),
                         l_db_pk1_column  ,
                         l_db_pk2_column  ,
                         l_db_pk3_column  ,
                         l_db_pk4_column  ,
                         l_db_pk5_column  ,
                         l_pk_column_names  ,
                         l_type_converted_val_cols  ,
                         l_pk_orig_column_names,
                         l_db_object_name);

    if (x_return_status <> G_RETURN_SUCCESS) then
      /* There will be a message on the msg dict stack. */
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning FALSE as pk values are not correct'
                  );
      return;  /* We will return the x_return_status as out param */
    end if;

    l_parent_object_id :=get_object_id(
             p_object_name => p_parent_object_tbl(l_table_index)
                                      );

    l_parent_object_name := p_parent_object_tbl(l_table_index); -- Bug 6143355


    l_parent_predicate := '';
    l_parent_predicate := 'UNION ALL( ' || p_relationship_sql_tbl(l_table_index) || '(';
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'profile role for '||p_parent_object_tbl(l_table_index)||
                               ' is: '||l_profile_role
               );

    -----------------------------------------------------------------------------------
    --First we see if a profile option is set and if function exists                 --
    -- if so we return and predicate (select pkColumns from base table               --
    -- eg: select inventory_item_id, organization_id from mtl_sys_items_b_ext        --
    -----------------------------------------------------------------------------------
    l_profile_role := getRole_mappedTo_profileOption(p_parent_object_tbl(l_table_index), l_user_name);

    l_profile_optionFound := FALSE;
    FOR mapped_roles_rec IN mapped_role_c (l_profile_role, l_parent_object_id, l_object_id, p_object_type)
    LOOP
      IF (l_profile_optionFound = FALSE) THEN
        l_child_role  :=mapped_roles_rec.menu_name;
        get_role_functions
           (p_api_version     => p_api_version
           ,p_role_name       => l_child_role
           ,x_return_status   => x_return_status
           ,x_privilege_tbl   => l_prof_privilege_tbl
           );

        IF (x_return_status = G_RETURN_SUCCESS) THEN
          IF (l_prof_privilege_tbl.COUNT > 0) THEN
           FOR i IN l_prof_privilege_tbl.first .. l_prof_privilege_tbl.last LOOP
             IF (l_prof_privilege_tbl(i) = p_function) THEN
                l_parent_predicate := l_parent_predicate || 'Select ' || l_pk_orig_column_names;
                 l_parent_predicate := l_parent_predicate || ' FROM ' || l_db_object_name;
                  l_parent_predicate := l_parent_predicate || ' )';

                 l_profile_optionFound := TRUE;
             END IF; --if function match, returning empty predicate
           END LOOP;
          END IF; -- x_prof_privilege_tbl >0
        END IF; --return status is T
     --ELSE
       -- how do we come out
      END IF; --if profile option is false
    END LOOP;
    -----------------------------------------------------------------------------------
    --END check of profile option                                                                                                    --
    -----------------------------------------------------------------------------------

    IF (l_profile_optionFound = FALSE) THEN
      -- start get parent role info
      l_parent_role_info := '';
      if( p_object_type is null) then
        FOR role_rec IN parent_role_c2 (p_function,
                                        l_object_id,
                                        l_parent_object_id)
        LOOP
          l_parent_role_info  :=  l_parent_role_info ||
                                  role_rec.parent_role_id ||
                                   ' , ';
        END LOOP;
      else
        FOR role_rec IN parent_role_c (p_function,
                                       l_object_id,
                                       l_parent_object_id,
                                       p_object_type  )
        LOOP
          l_parent_role_info  :=  l_parent_role_info ||
                                  role_rec.parent_role_id ||
                                  ' , ';
        END LOOP;
      end if;

      IF( length( l_parent_role_info ) >0) THEN
           -- strip off the trailing ', '
           l_parent_role_info := substr(l_parent_role_info, 1,
                          length(l_parent_role_info) - length(', '));
      ELSE
            l_parent_role_info := 'NULL';
      END IF;

      -- end get parent role info
      -- Step 2.
      IF(l_instance_flag = TRUE) THEN
         l_parent_predicate :=
           l_parent_predicate ||
          ' SELECT '||l_type_converted_val_cols ||
          ' FROM fnd_grants grants ';

        if (p_statement_type = 'EXISTS') then
          l_parent_predicate := l_parent_predicate ||
          ' WHERE grants.INSTANCE_PK1_VALUE=to_char('|| p_parent_obj_pk1alias_tbl(l_table_index)||')';

          --dbms_output.put_line('EGO_DATA_SECURITY: l_table_index ' || l_table_index);

          --dbms_output.put_line('EGO_DATA_SECURITY: p_parent_obj_pk2alias_tbl ' || p_parent_obj_pk2alias_tbl(l_table_index));
          IF (p_parent_obj_pk2alias_tbl IS NOT NULL AND
                    p_parent_obj_pk2alias_tbl.exists(l_table_index)) THEN
           --dbms_output.put_line('EGO_DATA_SECURITY: p_parent_obj_pk2alias_tbl in if statement');
           l_parent_predicate := l_parent_predicate ||
                        ' AND grants.INSTANCE_PK2_VALUE= to_char('|| p_parent_obj_pk2alias_tbl(l_table_index)||')';
          END IF;

          l_parent_predicate := l_parent_predicate || ' AND grants.start_date <= sysdate ';

        else
           l_parent_predicate := l_parent_predicate ||' WHERE grants.start_date <= sysdate ';

        end if;

        l_parent_predicate := l_parent_predicate ||
          ' AND NVL(grants.end_date,SYSDATE) >= SYSDATE ' ||
          ' AND grants.instance_type= ''INSTANCE'' ' ||
          ' AND grants.object_id = ' || l_parent_object_id ||
          ' AND grants.menu_id in ( ' || l_parent_role_info || ') '||
          ' AND ( ( grants.grantee_type = ''USER'' AND ' ||
                    ' grants.grantee_key = '''||l_user_name||''')'||
                 ' OR ( grants.grantee_type = ''GROUP'' AND '||
                    ' grants.grantee_key in ( '|| l_group_info || ')) ' ||
                 ' OR ( grants.grantee_type = ''COMPANY'' AND '||
                    ' grants.grantee_key in ( '|| l_company_info || ')) ' ||
                 ' OR (grants.grantee_type = ''GLOBAL'' AND '||
                    ' grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL'') )))';
        END IF;

        -- Step 3.
        l_set_predicates:='';
        IF(l_instance_set_flag = TRUE) THEN
          if(p_object_type is null) then
             FOR instance_set_grants_rec IN parent_instance_set_grants_c2 (l_user_name,
                                                                 l_parent_object_id,
                                                                 l_group_info,
                                                                 l_company_info,
                                                                 p_function,
                                                                 l_object_id
                                                                  )
             LOOP
               l_set_predicates  :=  substrb( l_set_predicates  ||
                                     instance_set_grants_rec.predicate ||
                                     ' OR ',
                                      1, g_pred_buf_size);
             END LOOP;
           else
             OPEN parent_instance_set_grants_c FOR
               l_dynamic_sql_2 USING l_parent_object_id,
                                     l_parent_object_id,
                                     p_function,
                                     l_object_id,
                                     l_parent_object_id,
                                     p_object_type,
                                     l_user_name;
             LOOP
                 FETCH parent_instance_set_grants_c  INTO l_one_set_predicate;
                 EXIT WHEN parent_instance_set_grants_c%NOTFOUND;
                 l_set_predicates  :=  substrb( l_set_predicates  ||
                                           l_one_set_predicate ||
                                           ' OR ',
                                           1, g_pred_buf_size);

             END LOOP;
             CLOSE parent_instance_set_grants_c;

           end if;

           IF( length(l_set_predicates ) >0) THEN
             -- strip off the trailing 'OR '
             l_set_predicates := substr(l_set_predicates, 1,
                            length(l_set_predicates) - length('OR '));


             IF(length(l_parent_predicate) >0 ) THEN

               -- strip off the trailing ')'
               l_parent_predicate := substr(l_parent_predicate, 1,
                           length(l_parent_predicate) - length(')'));

               if (p_statement_type = 'EXISTS') then
                 l_pk_orig_column_names_t := l_pk_orig_column_names||',';
                 l_orig_pk_column  := SUBSTR(l_pk_orig_column_names_t, 1, INSTR(l_pk_orig_column_names_t,',',1,1)-1);

-- R12C Security Changes
                 /*l_parent_predicate := substrb(
                    l_parent_predicate ||
                    ' UNION ALL  ( SELECT ' ||l_pk_orig_column_names ||
                    ' FROM ' || l_db_object_name ||
                    ' WHERE ' || l_orig_pk_column || ' = ' || p_parent_obj_pk1alias_tbl(l_table_index)
                    , 1, g_pred_buf_size); */
                    IF (l_parent_object_name = 'EGO_ITEM') THEN
                    l_parent_predicate := substrb(
                    l_parent_predicate ||
                    ' UNION ALL  ( SELECT ' ||l_pk_orig_column_names ||
                    ' FROM ' || l_db_object_name || ' , ego_item_cat_denorm_hier cathier '||
                    ' WHERE item_catalog_group_id = cathier.child_catalog_group_id AND ' || l_orig_pk_column || ' = ' || p_parent_obj_pk1alias_tbl(l_table_index)
                    , 1, g_pred_buf_size);
                    ELSE
                    l_parent_predicate := substrb(
                    l_parent_predicate ||
                    ' UNION ALL  ( SELECT ' ||l_pk_orig_column_names ||
                    ' FROM ' || l_db_object_name ||
                    ' WHERE ' || l_orig_pk_column || ' = ' || p_parent_obj_pk1alias_tbl(l_table_index)
                    , 1, g_pred_buf_size);
                    END IF;

-- R12C Security Changes


                  code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Check the predicate' ||
                  ' l_parent_predicate: ' || l_parent_predicate
                  );

                 IF (p_parent_obj_pk2alias_tbl IS NOT NULL AND
                       p_parent_obj_pk2alias_tbl.exists(l_table_index)) THEN
                       l_orig_pk_column := SUBSTR(l_pk_orig_column_names_t, INSTR(l_pk_orig_column_names_t,',',1,2-1)+1, INSTR(l_pk_orig_column_names_t,',',1,2)-INSTR(l_pk_orig_column_names_t,',',1,2-1)-1 );
                       l_parent_predicate := l_parent_predicate || ' AND ' || l_orig_pk_column || '=' || p_parent_obj_pk2alias_tbl(l_table_index);

                 END IF;

                 l_parent_predicate := substrb(l_parent_predicate ||
                                              ' AND ( ' ||
                                              l_set_predicates || ' ) ' ||
                                              '))',
                                              1, g_pred_buf_size);

               else
                 l_parent_predicate := substrb(l_parent_predicate ||
                                           ' UNION ALL  ( SELECT '
                                           ||l_pk_orig_column_names || ' FROM ' ||
                                           l_db_object_name || ' WHERE '
                                           || l_set_predicates ||  '))',
                                              1, g_pred_buf_size);

               end if;
             ELSE
               -- won't be here see l_parent_preidcate>0 anyway
               l_parent_predicate:= l_set_predicates;

             END IF;
          END IF;
      END IF;
    END IF; -- if profile option not found

    l_parent_predicate := l_parent_predicate ||')';
    l_aggregate_predicate := l_aggregate_predicate || l_parent_predicate;

    END LOOP;

    --finally
    l_aggregate_predicate := l_aggregate_predicate || ' )';

    ------ ending new part

    x_predicate :=l_aggregate_predicate;
    x_clob_predicate := l_aggregate_predicate;

    if (    (lengthb(l_aggregate_predicate) > g_vpd_buf_limit)
            AND (p_statement_type = 'BASE'))then
       FND_MESSAGE.SET_NAME('FND', 'GENERIC-INTERNAL ERROR');
       FND_MESSAGE.SET_TOKEN('ROUTINE',
         'EGO_DATA_SECURITY.GET_SECURITY_PREDICATE');
       FND_MESSAGE.SET_TOKEN('REASON',
        'The predicate was longer than the database VPD limit of '||
       to_char(g_vpd_buf_limit)||' bytes for the predicate.  ');
       x_return_status := 'L'; /* Indicate Error */
       code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                  ,p_module    => l_api_name
                  ,p_message   =>  'Returning Status: '||x_return_status||' as predicate size is more'
                  );
    end if;

   EXCEPTION
     WHEN OTHERS THEN
       fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE',G_PKG_NAME||l_api_name);
       fnd_message.set_token('ERRNO', SQLCODE);
       fnd_message.set_token('REASON', SQLERRM);
       x_return_status := G_RETURN_UNEXP_ERR;
       code_debug (p_log_level => G_DEBUG_LEVEL_EXCEPTION
                  ,p_module    => l_api_name
                  ,p_message   => 'Returning EXCEPTION '||SQLERRM
                  );
       return;
  END get_inherited_predicate;


--------------------------------------------------------
----    get_instances
--------------------------------------------------------
PROCEDURE get_instances
(
    p_api_version    IN  NUMBER,
    p_function       IN  VARCHAR2 DEFAULT NULL,
    p_object_name    IN  VARCHAR2,
    p_user_name      IN  VARCHAR2 DEFAULT NULL,
    x_return_status  OUT NOCOPY VARCHAR2,
    x_object_key_tbl OUT NOCOPY EGO_INSTANCE_TABLE_TYPE
) is
    l_api_name              CONSTANT VARCHAR2(30)   := 'GET_INSTANCES';
    l_predicate             VARCHAR2(32767);
    l_dynamic_sql           VARCHAR2(32767);
    l_db_object_name        varchar2(30);
    l_db_pk1_column         varchar2(30);
    l_db_pk2_column         varchar2(30);
    l_db_pk3_column         varchar2(30);
    l_db_pk4_column         varchar2(30);
    l_db_pk5_column         varchar2(30);
    l_pk_column_names       varchar2(512);
    l_pk_orig_column_names  varchar2(512);
    l_type_converted_val_cols  varchar2(512);
    l_pk1_val               varchar2(512);
    l_pk2_val               varchar2(512);
    l_pk3_val               varchar2(512);
    l_pk4_val               varchar2(512);
    l_pk5_val               varchar2(512);
    l_index                 number;

    instances_cur DYNAMIC_CUR;
  BEGIN
    SetGlobals();
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   =>  'Started with 6 params '||
                   ' p_api_version: '|| to_char(p_api_version) ||
                   ' - p_function: '|| p_function ||
                   ' - p_object_name: '|| p_object_name ||
                   ' - p_user_name: '|| p_user_name
                );

   get_security_predicate(p_api_version         => 1.0,
                          p_function            => p_function,
                          p_object_name         => p_object_name,
                          p_grant_instance_type => G_TYPE_UNIVERSAL,
                          p_user_name           => p_user_name,
                          x_predicate           => l_predicate,
                          x_return_status       => x_return_status);
   if(x_return_status NOT IN (G_RETURN_SUCCESS, G_RETURN_FAILURE))then
       /* There will be a message on the msg dict stack. */
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning status as returned from get_security_predicate '||x_return_status
                 );
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
                             l_type_converted_val_cols  ,
                             l_pk_orig_column_names,
                             l_db_object_name );
   if (x_return_status <> G_RETURN_SUCCESS) then
     /* There will be a message on the msg dict stack. */
     code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                ,p_module    => l_api_name
                ,p_message   => 'PK informatino not available returning: '||x_return_status
                );
     return;  /* We will return the x_return_status as out param */
   end if;

   if (l_predicate is not NULL) then
      l_dynamic_sql :=
                 'SELECT  '|| l_pk_column_names ||
                  ' FROM  '|| l_db_object_name ||
                 ' WHERE '||l_predicate||' ';
   else
      x_return_status := G_RETURN_FAILURE;
      return;
   end if;

   l_index:=0;
   -- Run the statement,
   OPEN instances_cur FOR l_dynamic_sql;
   LOOP
     if(l_db_pk5_column is NOT NULL) then
        FETCH instances_cur  INTO l_pk1_val,
                                  l_pk2_val,
                                  l_pk3_val,
                                  l_pk4_val,
                                  l_pk5_val;
     elsif(l_db_pk4_column is NOT NULL) then
        FETCH instances_cur  INTO l_pk1_val,
                                  l_pk2_val,
                                  l_pk3_val,
                                  l_pk4_val;
     elsif(l_db_pk3_column is NOT NULL) then
        FETCH instances_cur  INTO l_pk1_val,
                                  l_pk2_val,
                                  l_pk3_val;
     elsif(l_db_pk2_column is NOT NULL) then
        FETCH instances_cur  INTO l_pk1_val,
                                  l_pk2_val;
     elsif(l_db_pk1_column is NOT NULL) then
        FETCH instances_cur  INTO l_pk1_val;
     else
        x_return_status := G_RETURN_UNEXP_ERR;
        return; /* This will never happen since pk1 is reqd*/
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
     code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                ,p_module    => l_api_name
                ,p_message   => 'Returning success as instances found '
                );
      x_return_status := G_RETURN_SUCCESS; /* Success */
   else
     code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                ,p_module    => l_api_name
                ,p_message   => 'Returning failure as instances are not found '
                );
      x_return_status := G_RETURN_FAILURE; /* No instances */
   end if;

   return;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE',G_PKG_NAME||l_api_name);
      fnd_message.set_token('ERRNO', SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      code_debug (p_log_level => G_DEBUG_LEVEL_EXCEPTION
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning EXCEPTION '||SQLERRM
                  );
      x_return_status := G_RETURN_UNEXP_ERR;
      RETURN;
end get_instances;


--------------------------------------------------------
----    check_instance_in_set
--------------------------------------------------------
FUNCTION check_instance_in_set
 (
  p_api_version          IN  NUMBER,
  p_instance_set_name    IN  VARCHAR2,
  p_instance_pk1_value   IN  VARCHAR2,
  p_instance_pk2_value   IN  VARCHAR2 DEFAULT NULL,
  p_instance_pk3_value   IN  VARCHAR2 DEFAULT NULL,
  p_instance_pk4_value   IN  VARCHAR2 DEFAULT NULL,
  p_instance_pk5_value   IN  VARCHAR2 DEFAULT NULL
 ) return VARCHAR2 is
    l_api_name   CONSTANT VARCHAR2(30)  := 'CHECK_INSTANCE_IN_SET';

    -- On addition of any Required parameters the major version needs
    -- to change i.e. for eg. 1.X to 2.X.
    -- On addition of any Optional parameters the minor version needs
    -- to change i.e. for eg. X.6 to X.7.
    l_api_version           CONSTANT NUMBER := 1.0;
    l_dynamic_sql           VARCHAR2(32767);
    l_predicate             VARCHAR2(32767);
    l_object_name           varchar2(30);
    l_pk1_vc_val            varchar2(80);
    l_pk2_vc_val            varchar2(80);
    l_pk3_vc_val            varchar2(80);
    l_pk4_vc_val            varchar2(80);
    l_pk5_vc_val            varchar2(80);
    l_pk1_col_name          varchar2(30);
    l_pk2_col_name          varchar2(30);
    l_pk3_col_name          varchar2(30);
    l_pk4_col_name          varchar2(30);
    l_pk5_col_name          varchar2(30);
    l_pk1_col_type          varchar2(8);
    l_pk2_col_type          varchar2(8);
    l_pk3_col_type          varchar2(8);
    l_pk4_col_type          varchar2(8);
    l_pk5_col_type          varchar2(8);
    l_dummy_val             varchar2(30);

    instance_sets_cur DYNAMIC_CUR;
  begin
    SetGlobals();
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   =>  'Started with 7 params '||
                   ' p_api_version: '|| to_char(p_api_version) ||
                   ' - p_instance_set_name: '|| p_instance_set_name ||
                   ' - p_instance_pk1_value: '|| p_instance_pk1_value ||
                   ' - p_instance_pk2_value: '|| p_instance_pk2_value ||
                   ' - p_instance_pk3_value: '|| p_instance_pk3_value ||
                   ' - p_instance_pk4_value: '|| p_instance_pk4_value ||
                   ' - p_instance_pk5_value: '|| p_instance_pk5_value
               );

    -- check for call compatibility.
    if TRUNC(l_api_version) <> TRUNC(p_api_version) THEN
       fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
       fnd_message.set_token('ROUTINE', g_pkg_name || '.'|| l_api_name);
       fnd_message.set_token('REASON',
                 'Unsupported version '|| to_char(p_api_version)||
                 ' passed to API; expecting version '||
                 to_char(l_api_version));
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning as the call in incompatible '
                 );
       return G_RETURN_UNEXP_ERR;/* Unexpected Error */
    END IF;

    begin
      -- select predicate from fnd_grant_instances
      select s.predicate,
             o.database_object_name,
             o.pk1_column_name,
             o.pk2_column_name,
             o.pk3_column_name,
             o.pk4_column_name,
             o.pk5_column_name,
             o.pk1_column_type,
             o.pk2_column_type,
             o.pk3_column_type,
             o.pk4_column_type,
             o.pk5_column_type
        into l_predicate,
             l_object_name,
             l_pk1_col_name,
             l_pk2_col_name,
             l_pk3_col_name,
             l_pk4_col_name,
             l_pk5_col_name,
             l_pk1_col_type,
             l_pk2_col_type,
             l_pk3_col_type,
             l_pk4_col_type,
             l_pk5_col_type
        from fnd_objects o, fnd_object_instance_sets s
       where s.instance_set_name =  p_instance_set_name
         and s.object_id = o.object_id;
    exception
      when no_data_found then
         fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
         fnd_message.set_token('ROUTINE', g_pkg_name || '.'|| l_api_name);
         fnd_message.set_token('REASON',
            'Data Error- couldn''t get predicate and/or object_name from '||
            'fnd_objects and fnd_object_instance_sets for instance set '||
            '"'||p_instance_set_name||'"');
         code_debug (p_log_level => G_DEBUG_LEVEL_EXCEPTION
                    ,p_module    => l_api_name
                    ,p_message   => 'The given data is not sufficient to find a valid instance set '
                    );
         return G_RETURN_UNEXP_ERR;
    end;

     -- Convert e.g. from ':n' to 'TO_NUMBER(:n)'
     l_pk1_vc_val := get_conv_from_char(':col1_value', l_pk1_col_type);
     l_pk2_vc_val := get_conv_from_char(':col2_value', l_pk2_col_type);
     l_pk3_vc_val := get_conv_from_char(':col3_value', l_pk3_col_type);
     l_pk4_vc_val := get_conv_from_char(':col4_value', l_pk4_col_type);
     l_pk5_vc_val := get_conv_from_char(':col5_value', l_pk5_col_type);

     -- Construct dynamic sql statement that will return a row if
     -- there is a row in the base object table in the instance set,
     -- with the PK passed in.
     l_dynamic_sql :=
      'SELECT ''X'' FROM sys.dual WHERE EXISTS (' ||
        'SELECT ''X'''||
         ' FROM  '|| l_object_name ||
        ' WHERE ';
     if (l_pk1_col_name  is not NULL) then
        l_dynamic_sql := l_dynamic_sql ||
           ' (   ('||l_pk1_col_name||' = '||l_pk1_vc_val||')'||
            ' OR (    ('||l_pk1_col_name||' is NULL) '||
                ' AND ( :col1_value is NULL)))';
     end if;
     if (l_pk2_col_name  is not NULL) then
        l_dynamic_sql := l_dynamic_sql ||
       ' AND (   ('||l_pk2_col_name||' = '||l_pk2_vc_val||')'||
            ' OR (    ('||l_pk2_col_name||' is NULL) '||
                ' AND ( :col2_value is NULL)))';
     end if;
     if (l_pk3_col_name  is not NULL) then
        l_dynamic_sql := l_dynamic_sql ||
       ' AND (   ('||l_pk3_col_name||' = '||l_pk3_vc_val||')'||
            ' OR (    ('||l_pk3_col_name||' is NULL) '||
                ' AND ( :col3_value is NULL)))';
     end if;
     if (l_pk4_col_name  is not NULL) then
        l_dynamic_sql := l_dynamic_sql ||
       ' AND (   ('||l_pk4_col_name||' = '||l_pk4_vc_val||')'||
            ' OR (    ('||l_pk4_col_name||' is NULL) '||
                ' AND ( :col4_value is NULL)))';
     end if;
     if (l_pk5_col_name  is not NULL) then
        l_dynamic_sql := l_dynamic_sql ||
       ' AND (   ('||l_pk5_col_name||' = '||l_pk5_vc_val||')'||
            ' OR (    ('||l_pk5_col_name||' is NULL) '||
                ' AND ( :col5_value is NULL)))';
     end if;
     l_dynamic_sql := l_dynamic_sql ||
        ' AND '|| l_predicate ||')';

     code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                ,p_module    => l_api_name
                ,p_message   => 'l_dynamic_sql '||l_dynamic_sql
                );
     -- Run the statement, binding in the pk column names and pk values.
     if (l_pk5_col_name  is not NULL) then
        OPEN instance_sets_cur FOR l_dynamic_sql USING
           p_instance_pk1_value, p_instance_pk1_value,
           p_instance_pk2_value, p_instance_pk2_value,
           p_instance_pk3_value, p_instance_pk3_value,
           p_instance_pk4_value, p_instance_pk4_value,
           p_instance_pk5_value, p_instance_pk5_value;
     elsif (l_pk4_col_name  is not NULL) then
        OPEN instance_sets_cur FOR l_dynamic_sql USING
           p_instance_pk1_value, p_instance_pk1_value,
           p_instance_pk2_value, p_instance_pk2_value,
           p_instance_pk3_value, p_instance_pk3_value,
           p_instance_pk4_value, p_instance_pk4_value;
     elsif (l_pk3_col_name  is not NULL) then
        OPEN instance_sets_cur FOR l_dynamic_sql USING
           p_instance_pk1_value, p_instance_pk1_value,
           p_instance_pk2_value, p_instance_pk2_value,
           p_instance_pk3_value, p_instance_pk3_value;
     elsif (l_pk2_col_name  is not NULL) then
        OPEN instance_sets_cur FOR l_dynamic_sql USING
           p_instance_pk1_value, p_instance_pk1_value,
           p_instance_pk2_value, p_instance_pk2_value;
     elsif (l_pk1_col_name  is not NULL) then
        OPEN instance_sets_cur FOR l_dynamic_sql USING
           p_instance_pk1_value, p_instance_pk1_value;
     else
        return G_RETURN_UNEXP_ERR; /* This will never happen since pk1 is reqd*/
     end if;


     FETCH instance_sets_cur  INTO l_dummy_val;
     IF(instance_sets_cur%NOTFOUND) THEN
       CLOSE instance_sets_cur;
       code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                  ,p_module    => l_api_name
                  ,p_message   => 'Returning failure as instance does not have the reqd function '
                  );
       RETURN G_RETURN_FAILURE;
     ELSE
       CLOSE instance_sets_cur;
       code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                  ,p_module    => l_api_name
                  ,p_message   => 'Returning success as instance set has the reqd function '
                  );
       RETURN G_RETURN_SUCCESS;
     END IF;

   EXCEPTION
     WHEN OTHERS THEN
       fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE',G_PKG_NAME||l_api_name);
       fnd_message.set_token('ERRNO', SQLCODE);
       fnd_message.set_token('REASON', SQLERRM);
       code_debug (p_log_level => G_DEBUG_LEVEL_UNEXPECTED
                  ,p_module    => l_api_name
                  ,p_message   => 'Ending: Returning OTHER ERROR '||SQLERRM
                  );
       RETURN G_RETURN_UNEXP_ERR;

end check_instance_in_set;


--------------------------------------------------------
----    Create_Role_Mapping
--------------------------------------------------------
PROCEDURE Create_Role_Mapping(
         p_api_version                  IN   NUMBER
        ,p_parent_obj_name              IN   VARCHAR2
        ,p_parent_role_name             IN   VARCHAR2
        ,p_child_obj_name               IN   VARCHAR2
        ,p_child_object_type            IN   VARCHAR2
        ,p_child_role_name              IN   VARCHAR2
        ,p_owner                        IN   NUMBER
        ,p_init_msg_list                IN   VARCHAR2   :=  fnd_api.g_FALSE
        ,p_commit                       IN   VARCHAR2   :=  fnd_api.g_FALSE
        ,x_return_status                OUT  NOCOPY VARCHAR2
        ,x_errorcode                    OUT  NOCOPY NUMBER
        ,x_msg_count                    OUT  NOCOPY NUMBER
        ,x_msg_data                     OUT  NOCOPY VARCHAR2
) IS

    l_api_name           CONSTANT VARCHAR2(30)   := 'Create_Role_Mapping';
    --we don't use this yet, but eventually we might:
    --if we change required parameters, version goes from n.x to (n+1).x
    --if we change optional parameters, version goes from x.n to x.(n+1)

    l_api_version        CONSTANT NUMBER         := 1.0;

    -- General variables
    l_parent_obj_id       fnd_objects.object_id%type;
    l_parent_role_id      fnd_menus.menu_id%type;
    l_child_obj_id        fnd_objects.object_id%type;
    l_child_role_id       fnd_menus.menu_id%type;

    l_Sysdate            DATE                    := Sysdate;
    l_owner              NUMBER;

  BEGIN
    SetGlobals();
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   => 'Started with 13 params '||
                               ' p_api_version: '|| p_api_version||
                               ' - p_parent_obj_name: '||p_parent_obj_name||
                               ' - p_parent_role_name: '||p_parent_role_name||
                               ' - p_child_obj_name: '||p_child_obj_name||
                               ' - p_child_object_type: '||p_child_object_type||
                               ' - p_child_role_name: '||p_child_role_name||
                               ' - p_owner: '||p_owner||
                               ' - p_init_msg_list: '||p_init_msg_list||
                               ' - p_commit: '||p_commit
                );

    IF FND_API.TO_BOOLEAN(p_commit) THEN
      -- Standard Start of API savepoint
      SAVEPOINT   Create_Role_Mapping_PUB;
    END IF;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    IF (p_owner IS NULL OR p_owner = -1) THEN
      l_owner :=  EGO_SCTX.get_user_id();
    ELSE
      l_owner := p_owner;
    END IF;

    l_parent_obj_id := get_object_id(p_object_name => p_parent_obj_name);
    l_child_obj_id  := get_object_id(p_object_name => p_child_obj_name);
    l_parent_role_id := get_role_id(p_role_name => p_parent_role_name);
    l_child_role_id  := get_role_id(p_role_name => p_child_role_name);

    INSERT INTO EGO_OBJ_ROLE_MAPPINGS
    (
       PARENT_OBJECT_ID
     , PARENT_ROLE_ID
     , CHILD_OBJECT_ID
     , CHILD_OBJECT_TYPE
     , CHILD_ROLE_ID
     , LAST_UPDATE_DATE
     , LAST_UPDATED_BY
     , CREATION_DATE
     , CREATED_BY
     , LAST_UPDATE_LOGIN
    )
    VALUES
    (
       l_parent_obj_id
     , l_parent_role_id
     , l_child_obj_id
     , p_child_object_type
     , l_child_role_id
     , l_Sysdate
     , l_owner
     , l_Sysdate
     , l_owner
     , FND_GLOBAL.Login_id
    );

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -----------------------------------
    -- Make a standard call to get message count
    -- and if count is 1, get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else, i.e. if x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display them all at once or display one message after another.

    FND_MSG_PUB.Count_And_Get
        (   p_count        =>      x_msg_count,
            p_data         =>      x_msg_data
        );
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   => 'Returning 13 with params '||
                               ' x_return_status: '|| x_return_status||
                               ' - x_errorcode: '||x_errorcode||
                               ' - x_msg_count: '||x_msg_count||
                               ' - x_msg_data: '||x_msg_data
                );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        ROLLBACK TO Create_Role_Mapping_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
         (   p_count        =>      x_msg_count,
             p_data         =>      x_msg_data
         );
      x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
      code_debug (p_log_level => G_DEBUG_LEVEL_ERROR
                 ,p_module    => l_api_name
                 ,p_message   => 'Ending: Returning ERROR '||
                               ' x_return_status: '|| x_return_status||
                               ' - x_errorcode: '||x_errorcode||
                               ' - x_msg_count: '||x_msg_count||
                               ' - x_msg_data: '||x_msg_data
                  );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        ROLLBACK TO Create_Function_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
         (   p_count        =>      x_msg_count,
             p_data         =>      x_msg_data
         );
      x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
      code_debug (p_log_level => G_DEBUG_LEVEL_UNEXPECTED
                 ,p_module    => l_api_name
                 ,p_message   => 'Ending: Returning UNEXPECTED ERROR '||
                               ' x_return_status: '|| x_return_status||
                               ' - x_errorcode: '||x_errorcode||
                               ' - x_msg_count: '||x_msg_count||
                               ' - x_msg_data: '||x_msg_data
                  );
    WHEN OTHERS THEN
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        ROLLBACK TO Create_Function_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level
         (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
          FND_MSG_PUB.Add_Exc_Msg
             (   G_PKG_NAME,
                 l_api_name
             );
      END IF;
      FND_MSG_PUB.Count_And_Get
         (   p_count        =>      x_msg_count,
             p_data         =>      x_msg_data
         );
      x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
      code_debug (p_log_level => G_DEBUG_LEVEL_UNEXPECTED
                 ,p_module    => l_api_name
                 ,p_message   => 'Ending: Returning UNEXPECTED ERROR '||
                               ' x_return_status: '|| x_return_status||
                               ' - x_errorcode: '||x_errorcode||
                               ' - x_msg_count: '||x_msg_count||
                               ' - x_msg_data: '||x_msg_data
                  );

END Create_Role_Mapping;


--------------------------------------------------------
----    Create_Role_Mapping
--------------------------------------------------------
PROCEDURE Create_Role_Mapping(
         p_api_version                  IN   NUMBER
        ,p_parent_obj_name              IN   VARCHAR2
        ,p_parent_role_name             IN   VARCHAR2
        ,p_child_obj_name               IN   VARCHAR2
        ,p_child_object_type            IN   VARCHAR2
        ,p_child_role_name              IN   VARCHAR2
        ,p_init_msg_list                IN   VARCHAR2   :=  fnd_api.g_FALSE
        ,p_commit                       IN   VARCHAR2   :=  fnd_api.g_FALSE
        ,x_return_status                OUT  NOCOPY VARCHAR2
        ,x_errorcode                    OUT  NOCOPY NUMBER
        ,x_msg_count                    OUT  NOCOPY NUMBER
        ,x_msg_data                     OUT  NOCOPY VARCHAR2
) IS

  BEGIN
    SetGlobals();
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => 'Create_Role_Mapping 12'
               ,p_message   => 'Started with 12 params '||
                               ' p_api_version: '|| p_api_version||
                               ' - p_parent_obj_name: '||p_parent_obj_name||
                               ' - p_parent_role_name: '||p_parent_role_name||
                               ' - p_child_obj_name: '||p_child_obj_name||
                               ' - p_child_object_type: '||p_child_object_type||
                               ' - p_child_role_name: '||p_child_role_name||
                               ' - p_init_msg_list: '||p_init_msg_list||
                               ' - p_commit: '||p_commit
                );

    Create_Role_Mapping(
         p_api_version                  => p_api_version
        ,p_parent_obj_name              => p_parent_obj_name
        ,p_parent_role_name             => p_parent_role_name
        ,p_child_obj_name               => p_child_obj_name
        ,p_child_object_type            => p_child_object_type
        ,p_child_role_name              => p_child_role_name
        ,p_owner                        => NULL
        ,p_init_msg_list                => p_init_msg_list
        ,p_commit                       => p_commit
        ,x_return_status                => x_return_status
        ,x_errorcode                    => x_errorcode
        ,x_msg_count                    => x_msg_count
        ,x_msg_data                     => x_msg_data
    );
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => 'Create_Role_Mapping'
               ,p_message   => 'Returning 12 with params '||
                               ' x_return_status: '|| x_return_status||
                               ' - x_errorcode: '||x_errorcode||
                               ' - x_msg_count: '||x_msg_count||
                               ' - x_msg_data: '||x_msg_data
                );

END Create_Role_Mapping;

--------------------------------------------------------
----    Update_Role_Mapping
--------------------------------------------------------
PROCEDURE Update_Role_Mapping(
         p_api_version                  IN   NUMBER
        ,p_parent_obj_name              IN   VARCHAR2
        ,p_parent_role_name             IN   VARCHAR2
        ,p_child_obj_name               IN   VARCHAR2
        ,p_child_object_type            IN   VARCHAR2
        ,p_child_role_name              IN   VARCHAR2
        ,p_owner                        IN   NUMBER
        ,p_init_msg_list                IN   VARCHAR2   :=  fnd_api.g_FALSE
        ,p_commit                       IN   VARCHAR2   :=  fnd_api.g_FALSE
        ,x_return_status                OUT  NOCOPY VARCHAR2
        ,x_errorcode                    OUT  NOCOPY NUMBER
        ,x_msg_count                    OUT  NOCOPY NUMBER
        ,x_msg_data                     OUT  NOCOPY VARCHAR2
) IS

    l_api_name           CONSTANT VARCHAR2(30)   := 'Update_Role_Mapping';
    --we don't use this yet, but eventually we might:
    --if we change required parameters, version goes from n.x to (n+1).x
    --if we change optional parameters, version goes from x.n to x.(n+1)

    l_api_version        CONSTANT NUMBER         := 1.0;
    l_row_count          NUMBER;
    l_curr_login_id      NUMBER;

    -- General variables

    l_parent_obj_id       fnd_objects.object_id%type;
    l_parent_role_id      fnd_menus.menu_id%type;
    l_child_obj_id        fnd_objects.object_id%type;
    l_child_role_id       fnd_menus.menu_id%type;
    l_Sysdate            DATE                    := Sysdate;
    l_owner              NUMBER;

  BEGIN
    SetGlobals();
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   => 'Started with 13 params '||
                               ' p_api_version: '|| p_api_version||
                               ' - p_parent_obj_name: '||p_parent_obj_name||
                               ' - p_parent_role_name: '||p_parent_role_name||
                               ' - p_child_obj_name: '||p_child_obj_name||
                               ' - p_child_object_type: '||p_child_object_type||
                               ' - p_child_role_name: '||p_child_role_name||
                               ' - p_owner: '||p_owner||
                               ' - p_init_msg_list: '||p_init_msg_list||
                               ' - p_commit: '||p_commit
                );
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      -- Standard Start of API savepoint
      SAVEPOINT   Update_Role_Mapping_PUB;
    END IF;

    -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (p_owner IS NULL OR p_owner = -1) THEN
      l_owner :=  EGO_SCTX.get_user_id();
    ELSE
      l_owner := p_owner;
    END IF;

    l_parent_obj_id := get_object_id(p_object_name => p_parent_obj_name);
    l_child_obj_id  := get_object_id(p_object_name => p_child_obj_name);
    l_parent_role_id := get_role_id(p_role_name => p_parent_role_name);
    l_child_role_id  := get_role_id(p_role_name => p_child_role_name);
    l_curr_login_id  :=  FND_GLOBAL.Login_id;
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'After obtaining parent and child ids '||
                               ' l_parent_obj_id: '||l_parent_obj_id||
                               ' - l_child_obj_id: '||l_child_obj_id||
                               ' - l_parent_role_id: '||l_parent_role_id||
                               ' - l_child_role_id: '||l_child_role_id
               );

  IF (p_child_object_type is not null) THEN
    UPDATE EGO_OBJ_ROLE_MAPPINGS
     SET
       CHILD_ROLE_ID     = l_child_role_id
     , LAST_UPDATE_DATE  = l_Sysdate
     , LAST_UPDATED_BY   = l_owner
     , LAST_UPDATE_LOGIN = l_curr_login_id
     WHERE
       PARENT_OBJECT_ID = l_parent_obj_id AND
       PARENT_ROLE_ID = l_parent_role_id AND
       CHILD_OBJECT_ID = l_child_obj_id AND
       CHILD_OBJECT_TYPE = p_child_object_type;
  ELSE
    UPDATE EGO_OBJ_ROLE_MAPPINGS
      SET
        CHILD_ROLE_ID     = l_child_role_id
      , LAST_UPDATE_DATE  = l_Sysdate
      , LAST_UPDATED_BY   = l_owner
      , LAST_UPDATE_LOGIN = l_curr_login_id
      WHERE
        PARENT_OBJECT_ID = l_parent_obj_id AND
        PARENT_ROLE_ID = l_parent_role_id AND
        CHILD_OBJECT_ID = l_child_obj_id AND
        CHILD_OBJECT_TYPE is null;
  END IF;

    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'After updating role mappings'
               );

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'After committing the data'
               );
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Make a standard call to get message count
    -- and if count is 1, get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else, i.e. if x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display them all at once or display one message after another.

    FND_MSG_PUB.Count_And_Get
        (   p_count        =>      x_msg_count,
            p_data         =>      x_msg_data
        );

    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => 'Update_Role_Mapping '
               ,p_message   => 'Returning 13 with params '||
                               ' x_return_status: '|| x_return_status||
                               ' - x_errorcode: '||x_errorcode||
                               ' - x_msg_count: '||x_msg_count||
                               ' - x_msg_data: '||x_msg_data
                );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        ROLLBACK TO Update_Role_Mapping_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
          (   p_count        =>      x_msg_count,
              p_data         =>      x_msg_data
          );
      x_msg_data :='Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
      code_debug (p_log_level => G_DEBUG_LEVEL_ERROR
                 ,p_module    => l_api_name
                 ,p_message   => 'Ending: Returning UNEXPECTED ERROR '||
                               ' x_return_status: '|| x_return_status||
                               ' - x_errorcode: '||x_errorcode||
                               ' - x_msg_count: '||x_msg_count||
                               ' - x_msg_data: '||x_msg_data
                  );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        ROLLBACK TO Update_Role_Mapping_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
          (   p_count        =>      x_msg_count,
              p_data         =>      x_msg_data
          );
      x_msg_data :='Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
      code_debug (p_log_level => G_DEBUG_LEVEL_UNEXPECTED
                 ,p_module    => l_api_name
                 ,p_message   => 'Ending: Returning UNEXPECTED ERROR '||
                               ' x_return_status: '|| x_return_status||
                               ' - x_errorcode: '||x_errorcode||
                               ' - x_msg_count: '||x_msg_count||
                               ' - x_msg_data: '||x_msg_data
                  );
    WHEN OTHERS THEN
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        ROLLBACK TO Update_Role_Mapping_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level
         (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
          FND_MSG_PUB.Add_Exc_Msg
          (   G_PKG_NAME,
              l_api_name
          );
      END IF;
      FND_MSG_PUB.Count_And_Get
          (   p_count        =>      x_msg_count,
              p_data         =>      x_msg_data
          );
      x_msg_data :='Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
      code_debug (p_log_level => G_DEBUG_LEVEL_UNEXPECTED
                 ,p_module    => l_api_name
                 ,p_message   => 'Ending: Returning OTHER ERROR '||
                               ' x_return_status: '|| x_return_status||
                               ' - x_errorcode: '||x_errorcode||
                               ' - x_msg_count: '||x_msg_count||
                               ' - x_msg_data: '||x_msg_data
                  );

END Update_Role_Mapping;

--------------------------------------------------------
----    Update_Role_Mapping
--------------------------------------------------------
PROCEDURE Update_Role_Mapping(
         p_api_version                  IN   NUMBER
        ,p_parent_obj_name              IN   VARCHAR2
        ,p_parent_role_name             IN   VARCHAR2
        ,p_child_obj_name               IN   VARCHAR2
        ,p_child_object_type            IN   VARCHAR2
        ,p_child_role_name              IN   VARCHAR2
        ,p_init_msg_list                IN   VARCHAR2   :=  fnd_api.g_FALSE
        ,p_commit                       IN   VARCHAR2   :=  fnd_api.g_FALSE
        ,x_return_status                OUT  NOCOPY VARCHAR2
        ,x_errorcode                    OUT  NOCOPY NUMBER
        ,x_msg_count                    OUT  NOCOPY NUMBER
        ,x_msg_data                     OUT  NOCOPY VARCHAR2
) IS

  BEGIN
    SetGlobals();
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => 'Update_Role_Mapping'
               ,p_message   => 'Started with 12 params '||
                               ' p_api_version: '|| p_api_version||
                               ' - p_parent_obj_name: '||p_parent_obj_name||
                               ' - p_parent_role_name: '||p_parent_role_name||
                               ' - p_child_obj_name: '||p_child_obj_name||
                               ' - p_child_object_type: '||p_child_object_type||
                               ' - p_child_role_name: '||p_child_role_name||
                               ' - p_init_msg_list: '||p_init_msg_list||
                               ' - p_commit: '||p_commit
                );

    Update_Role_Mapping(
         p_api_version                  => p_api_version
        ,p_parent_obj_name              => p_parent_obj_name
        ,p_parent_role_name             => p_parent_role_name
        ,p_child_obj_name               => p_child_obj_name
        ,p_child_object_type            => p_child_object_type
        ,p_child_role_name              => p_child_role_name
        ,p_owner                        => NULL
        ,p_init_msg_list                => p_init_msg_list
        ,p_commit                       => p_commit
        ,x_return_status                => x_return_status
        ,x_errorcode                    => x_errorcode
        ,x_msg_count                    => x_msg_count
        ,x_msg_data                     => x_msg_data
    );
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => 'Update_Role_Mapping'
               ,p_message   => 'Returning 12 with params '||
                               ' x_return_status: '|| x_return_status||
                               ' - x_errorcode: '||x_errorcode||
                               ' - x_msg_count: '||x_msg_count||
                               ' - x_msg_data: '||x_msg_data
                );

END Update_Role_Mapping;

--------------------------------------------------------
----    Delete_Role_Mapping
--------------------------------------------------------
PROCEDURE Delete_Role_Mapping(
         p_api_version                  IN   NUMBER
        ,p_parent_obj_name              IN   VARCHAR2
        ,p_parent_role_name             IN   VARCHAR2
        ,p_child_obj_name               IN   VARCHAR2
        ,p_child_object_type            IN   VARCHAR2
        ,p_init_msg_list                IN   VARCHAR2   :=  fnd_api.g_FALSE
        ,p_commit                       IN   VARCHAR2   :=  fnd_api.g_FALSE
        ,x_return_status                OUT  NOCOPY VARCHAR2
        ,x_errorcode                    OUT  NOCOPY NUMBER
        ,x_msg_count                    OUT  NOCOPY NUMBER
        ,x_msg_data                     OUT  NOCOPY VARCHAR2
) IS

    l_api_name           CONSTANT VARCHAR2(30)   := 'Delete_Role_Mapping';
    --we don't use this yet, but eventually we might:
    --if we change required parameters, version goes from n.x to (n+1).x
    --if we change optional parameters, version goes from x.n to x.(n+1)

    l_api_version        CONSTANT NUMBER         := 1.0;
    l_row_count          NUMBER;

    -- General variables

    l_parent_obj_id       fnd_objects.object_id%type;
    l_parent_role_id      fnd_menus.menu_id%type;
    l_child_obj_id        fnd_objects.object_id%type;

    l_Sysdate            DATE                    := Sysdate;

  BEGIN
    SetGlobals();
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   => 'Started with 11 params '||
                               ' p_api_version: '|| p_api_version||
                               ' - p_parent_obj_name: '||p_parent_obj_name||
                               ' - p_parent_role_name: '||p_parent_role_name||
                               ' - p_child_obj_name: '||p_child_obj_name||
                               ' - p_child_object_type: '||p_child_object_type||
                               ' - p_init_msg_list: '||p_init_msg_list||
                               ' - p_commit: '||p_commit
                );

    IF FND_API.TO_BOOLEAN(p_commit) THEN
      -- Standard Start of API savepoint
      SAVEPOINT   Delete_Role_Mapping_PUB;
   END IF;

    -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_parent_obj_id := get_object_id(p_object_name => p_parent_obj_name);
    l_child_obj_id  := get_object_id(p_object_name => p_child_obj_name);
    l_parent_role_id := get_role_id(p_role_name => p_parent_role_name);

    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'After obtaining parent and child ids '||
                               ' l_parent_obj_id: '||l_parent_obj_id||
                               ' - l_child_obj_id: '||l_child_obj_id||
                               ' - l_parent_role_id: '||l_parent_role_id
               );

    IF (p_child_object_type is not null) THEN
        DELETE FROM EGO_OBJ_ROLE_MAPPINGS
        WHERE
        PARENT_OBJECT_ID = l_parent_obj_id AND
        PARENT_ROLE_ID = l_parent_role_id AND
        CHILD_OBJECT_ID = l_child_obj_id AND
        CHILD_OBJECT_TYPE = p_child_object_type;
    ELSE
        DELETE FROM EGO_OBJ_ROLE_MAPPINGS
        WHERE
        PARENT_OBJECT_ID = l_parent_obj_id AND
        PARENT_ROLE_ID = l_parent_role_id AND
        CHILD_OBJECT_ID = l_child_obj_id AND
        CHILD_OBJECT_TYPE is null;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'After committing the data'
               );

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Make a standard call to get message count and if count is 1,
    -- get message info.

    FND_MSG_PUB.Count_And_Get
        (   p_count        =>      x_msg_count,
            p_data         =>      x_msg_data
        );
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   => 'Returning 11 with params '||
                               ' x_return_status: '|| x_return_status||
                               ' - x_errorcode: '||x_errorcode||
                               ' - x_msg_count: '||x_msg_count||
                               ' - x_msg_data: '||x_msg_data
                );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        ROLLBACK TO Delete_Role_Mapping_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
          (   p_count        =>      x_msg_count,
              p_data         =>      x_msg_data
          );
      x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
      code_debug (p_log_level => G_DEBUG_LEVEL_ERROR
                 ,p_module    => l_api_name
                 ,p_message   => 'Ending: Returning ERROR '||
                               ' x_return_status: '|| x_return_status||
                               ' - x_errorcode: '||x_errorcode||
                               ' - x_msg_count: '||x_msg_count||
                               ' - x_msg_data: '||x_msg_data
                  );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        ROLLBACK TO Delete_Role_Mapping_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
          (   p_count        =>      x_msg_count,
              p_data         =>      x_msg_data
          );
      x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
      code_debug (p_log_level => G_DEBUG_LEVEL_UNEXPECTED
                 ,p_module    => l_api_name
                 ,p_message   => 'Ending: Returning UNEXPECTED ERROR '||
                               ' x_return_status: '|| x_return_status||
                               ' - x_errorcode: '||x_errorcode||
                               ' - x_msg_count: '||x_msg_count||
                               ' - x_msg_data: '||x_msg_data
                  );
    WHEN OTHERS THEN
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        ROLLBACK TO Delete_Role_Mapping_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level
         (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
          FND_MSG_PUB.Add_Exc_Msg
          (   G_PKG_NAME,
              l_api_name
          );
      END IF;
      FND_MSG_PUB.Count_And_Get
          (   p_count        =>      x_msg_count,
              p_data         =>      x_msg_data
          );
      x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
      code_debug (p_log_level => G_DEBUG_LEVEL_UNEXPECTED
                 ,p_module    => l_api_name
                 ,p_message   => 'Ending: Returning OTHER ERROR '||
                               ' x_return_status: '|| x_return_status||
                               ' - x_errorcode: '||x_errorcode||
                               ' - x_msg_count: '||x_msg_count||
                               ' - x_msg_data: '||x_msg_data
                  );

END Delete_Role_Mapping;

--------------------------------------------------------
----    get_role_functions
--------------------------------------------------------
  PROCEDURE get_role_functions
  (
   p_api_version         IN  NUMBER,
   p_role_name           IN  VARCHAR2,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_privilege_tbl       OUT NOCOPY EGO_VARCHAR_TBL_TYPE
  )
  IS

    l_api_name      CONSTANT VARCHAR2(30) := 'GET_ROLE_FUNCTIONS';

    -- On addition of any Required parameters the major version needs
    -- to change i.e. for eg. 1.X to 2.X.
    -- On addition of any Optional parameters the minor version needs
    -- to change i.e. for eg. X.6 to X.7.
    l_api_version   CONSTANT NUMBER := 1.0;

    l_index                  NUMBER;

    l_privilege_tbl          EGO_PRIVILEGE_NAME_TABLE_TYPE;

    CURSOR role_function_c (cp_role_name VARCHAR2)
    IS
    SELECT functions.function_name
    FROM fnd_form_functions functions,
         fnd_menu_entries cmf,
       fnd_menus menus
    WHERE functions.function_id = cmf.function_id
    AND   menus.menu_id = cmf.menu_id
    AND   menus.menu_name = cp_role_name;


  BEGIN
    SetGlobals();
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   => 'Started with 4 params '||
                               ' p_api_version: '|| p_api_version||
                               ' - p_role_name: '||p_role_name
                );
   x_return_status := G_RETURN_SUCCESS; /* Assume Success */

   x_privilege_tbl := EGO_VARCHAR_TBL_TYPE();

   l_index := 0;

   FOR privileges_rec IN role_function_c (p_role_name)
   LOOP
      l_privilege_tbl(l_index) :=  privileges_rec.function_name;
      l_index := l_index+1;
   END LOOP;

   x_privilege_tbl.extend(l_privilege_tbl.COUNT);

   if (l_privilege_tbl.COUNT > 0) then

        FOR i IN l_privilege_tbl.first .. l_privilege_tbl.last LOOP
              x_privilege_tbl(i+1) := l_privilege_tbl(i);

        END LOOP;
   end if;


  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE',G_PKG_NAME||l_api_name);
      fnd_message.set_token('ERRNO', SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      x_return_status := G_RETURN_UNEXP_ERR;
      code_debug (p_log_level => G_DEBUG_LEVEL_UNEXPECTED
                 ,p_module    => l_api_name
                 ,p_message   => 'Ending: Returning OTHER ERROR '||SQLERRM
                 );

  END get_role_functions;

--------------------------------------------------------
----    get_inherited_functions
--------------------------------------------------------
PROCEDURE get_inherited_functions
  (
   p_api_version                 IN  NUMBER,
   p_object_name                 IN  VARCHAR2,
   p_instance_pk1_value          IN  VARCHAR2,
   p_instance_pk2_value          IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk3_value          IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk4_value          IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk5_value          IN  VARCHAR2 DEFAULT NULL,
   p_user_name                   IN  VARCHAR2 DEFAULT NULL,
   p_object_type                 IN  VARCHAR2 DEFAULT NULL,
   p_parent_object_name_tbl      IN  EGO_VARCHAR_TBL_TYPE,
   p_parent_object_sql_tbl       IN  EGO_VARCHAR_TBL_TYPE,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_privilege_tbl               OUT NOCOPY EGO_VARCHAR_TBL_TYPE
  )
  IS

    l_api_name          CONSTANT VARCHAR2(30) := 'GET_INHERITED_FUNCTIONS';

    -- On addition of any Required parameters the major version needs
    -- to change i.e. for eg. 1.X to 2.X.
    -- On addition of any Optional parameters the minor version needs
    -- to change i.e. for eg. X.6 to X.7.
    l_api_version     CONSTANT NUMBER := 1.0;
    l_sysdate                  DATE := Sysdate;

    l_index                    NUMBER;
    l_dynamic_sql              VARCHAR2(32767);
    l_common_dyn_sql           VARCHAR2(32767);
    l_set_dyn_sql              VARCHAR2(32767);
    l_inst_dyn_sql             VARCHAR2(32767);

    l_instance_sets_list       VARCHAR2(10000);
    l_privilege                VARCHAR2(480);
    l_select_query_part        VARCHAR2(3000);
    l_group_info               VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_company_info             VARCHAR2(32767); /* Must match g_pred_buf_size*/

    l_db_object_name           VARCHAR2(200);
    l_db_pk1_column            VARCHAR2(200);
    l_db_pk2_column            VARCHAR2(200);
    l_db_pk3_column            VARCHAR2(200);
    l_db_pk4_column            VARCHAR2(200);
    l_db_pk5_column            VARCHAR2(200);

    l_pk_column_names          VARCHAR2(512);
    l_pk_orig_column_names     VARCHAR2(512);
    l_type_converted_val_cols  VARCHAR2(512);
    l_parent_object_id         NUMBER;
    l_object_id                NUMBER;
    l_user_name                VARCHAR2(80);
--    l_orig_system              VARCHAR2(48);
    l_orig_system_id           NUMBER;

    l_return_status            VARCHAR2(1);
    l_privilege_tbl            EGO_PRIVILEGE_NAME_TABLE_TYPE;
    l_privilege_tbl_count      NUMBER;
    l_privilege_tbl_index      NUMBER;
    m_privilege_tbl            EGO_PRIVILEGE_NAME_TABLE_TYPE;
    m_privilege_tbl_count      NUMBER;
    m_privilege_tbl_index      NUMBER;
    x_index                    NUMBER;

    l_prof_privilege_tbl       EGO_VARCHAR_TBL_TYPE;
    l_profile_role             VARCHAR2(80);

    l_parent_object_count      NUMBER;  /**  ADDING A VARIABLE FOR COUNT ***/

    instance_set                 DYNAMIC_CUR;
    candidate_sets_c             DYNAMIC_CUR;
    l_dynamic_sql_1              VARCHAR2(32767);
    l_one_set_predicate          VARCHAR2(32767);
    l_one_set_id                 NUMBER;

  BEGIN
    SetGlobals();
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   =>  'Started with 13 params '||
                   ' p_api_version: '|| to_char(p_api_version) ||
                   ' - p_object_name: '|| p_object_name ||
                   ' - p_instance_pk1_value: '|| p_instance_pk1_value ||
                   ' - p_instance_pk2_value: '|| p_instance_pk2_value ||
                   ' - p_instance_pk3_value: '|| p_instance_pk3_value ||
                   ' - p_instance_pk4_value: '|| p_instance_pk4_value ||
                   ' - p_instance_pk5_value: '|| p_instance_pk5_value ||
                   ' - p_user_name: '|| p_user_name ||
                   ' - p_object_type: '|| p_object_type
               );
    FOR l_table_index IN 1..p_parent_object_name_tbl.COUNT LOOP
      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => ' p_parent_object_name_tbl('||l_table_index||
                                 '): '||p_parent_object_name_tbl(l_table_index)||
                                 ' - p_parent_object_sql_tbl('||l_table_index||
                                 '): '||p_parent_object_sql_tbl(l_table_index)
                 );
    END LOOP;

    -- check for call compatibility.
    IF TRUNC(l_api_version) <> TRUNC(p_api_version) THEN
      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE', g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON', 'Unsupported version '||
                                      to_char(p_api_version)||
                                      ' passed to API; expecting version '||
                                      to_char(l_api_version));
      x_return_status := G_RETURN_UNEXP_ERR;
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning as the call in incompatible '
               );
      RETURN;
    END IF;

    x_return_status := G_RETURN_SUCCESS; /* Assume Success */
    l_user_name := p_user_name;
    get_orig_key(x_user_name      => l_user_name
--                ,x_orig_system    => l_orig_system
                ,x_orig_system_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_user_name: '||l_user_name||
  --                             ' - l_orig_system: '||l_orig_system||
                               ' - l_orig_system_id: '||l_orig_system_id
               );

    -- get All privileges of a user on a given object

    --Step 1.
    -- get database object name and column
    -- cache the PK column name
    l_object_id := get_object_id(p_object_name => p_object_name);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_object_id: '||l_object_id
               );
    l_group_info := get_group_info(p_party_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_group_info: '||l_group_info
               );
    l_company_info := get_company_info (p_party_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_company_info: '||l_company_info
               );

    -- GETTING THE COUNT OF PARENT OBJECTS  HERE
    --  BEGINNING OF THE LOOP
    l_index:=0;
    FOR l_table_index IN 1..p_parent_object_name_tbl.COUNT  LOOP
      -- Please clear all the variables in the start of the loop.
      -- For eg: pk2 columns may not exist for project..
      -- but the value may be retained from the before loop for items
      l_db_pk1_column  := null;
      l_db_pk2_column  := null;
      l_db_pk3_column  := null;
      l_db_pk4_column  := null;
      l_db_pk5_column  := null;
      l_pk_column_names := null;
      l_type_converted_val_cols := null;
      l_pk_orig_column_names := null;
      l_db_object_name := null;
      x_return_status := get_pk_information
                              (p_parent_object_name_tbl(l_table_index),
                               l_db_pk1_column,
                               l_db_pk2_column,
                               l_db_pk3_column,
                               l_db_pk4_column,
                               l_db_pk5_column,
                               l_pk_column_names,
                               l_type_converted_val_cols,
                               l_pk_orig_column_names,
                               l_db_object_name);

      IF (x_return_status <> G_RETURN_SUCCESS) THEN
        code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                   ,p_module    => l_api_name
                   ,p_message   => 'Error in obtaining PK information exiting'
                   );
        /* There will be a message on the msg dict stack. */
        RETURN;  /* We will return the x_return_status as out param */
      END IF;

      -- Step 2.
      -- get instance set ids in which the given object_key exists
      -- as a set into l_instance_set
      -- R12C Security Changes
      /*l_select_query_part:= 'SELECT '|| l_pk_column_names ||
                             ' FROM '|| l_db_object_name ||
                            ' WHERE ('; */
      IF (p_object_name = 'EGO_ITEM') THEN
  l_select_query_part:= 'SELECT '|| l_pk_column_names ||
                              ' FROM '|| l_db_object_name ||', ego_item_cat_denorm_hier cathier'||
                              ' WHERE (';
      ELSE
        l_select_query_part:= 'SELECT '|| l_pk_column_names ||
                              ' FROM '|| l_db_object_name ||
                              ' WHERE (';
      END IF;
      -- R12C Security Changes
      if (l_db_pk1_column is not NULL) then
        l_select_query_part := l_select_query_part || l_db_pk1_column;
      end if;
      if (l_db_pk2_column is not NULL) then
        l_select_query_part := l_select_query_part || ',' || l_db_pk2_column;
      end if;
      if (l_db_pk3_column is not NULL) then
        l_select_query_part := l_select_query_part || ',' || l_db_pk3_column;
      end if;
      if (l_db_pk4_column is not NULL) then
        l_select_query_part := l_select_query_part  || ',' || l_db_pk4_column;
      end if;
      if (l_db_pk5_column is not NULL) then
        l_select_query_part := l_select_query_part || ',' || l_db_pk5_column;
      end if;

      /*** THIS IS WHERE THE QUERY IS APPENDED  ***/

      l_select_query_part := l_select_query_part || ') ';
      l_select_query_part := l_select_query_part ||' IN ' ||
                       ' (' || p_parent_object_sql_tbl (l_table_index) || ') ';

      -- R12C Secuirty Changes
      /*l_select_query_part := l_select_query_part || ' AND ';*/
      IF (p_object_name = 'EGO_ITEM') THEN
         l_select_query_part := l_select_query_part || ' AND item_catalog_group_id = cathier.child_catalog_group_id AND ';
      ELSE
         l_select_query_part := l_select_query_part || ' AND ';
      END IF;
      -- R12C Secuirty Changes

      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => l_select_query_part
                 );
      l_parent_object_id := get_object_id(
                     p_object_name => p_parent_object_name_tbl(l_table_index)
                                         );
      -------------------------------------------------------------------------------
      -- Now we build dynamic SQL using the work we just did to optimize the query --
      -------------------------------------------------------------------------------
      l_dynamic_sql_1 :=
      ' SELECT DISTINCT sets.instance_set_id, sets.predicate ' ||
        ' FROM fnd_grants grants, fnd_object_instance_sets sets' ||
       ' WHERE grants.object_id = :object_id ' ||
         ' AND grants.start_date <= SYSDATE ' ||
         ' AND NVL(grants.end_date, SYSDATE) >= SYSDATE ' ||
         ' AND grants.instance_type = :instance_type ' ||
          ' AND ( ( grants.grantee_type = ''USER'' AND ' ||
                 ' grants.grantee_key = :user_name ) '||
                 ' OR (grants.grantee_type = ''GROUP'' AND '||
                 ' grants.grantee_key in ( '||l_group_info||' ))' ||
                 ' OR (grants.grantee_type = ''COMPANY'' AND '||
                 ' grants.grantee_key in ( '||l_company_info||' ))' ||
                 ' OR (grants.grantee_type = ''GLOBAL'' AND '||
                 ' grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL'') )) '||
         ' AND sets.instance_set_id = grants.instance_set_id ' ||
         ' AND sets.object_id = grants.object_id ';
      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'Binds for get the candidate sets '||
                                 ' l_parent_object_id: '||l_parent_object_id||
                                 ' - G_TYPE_SET: '||G_TYPE_SET||
                                 ' - l_user_name: '||l_user_name
                 );
      l_instance_sets_list := '';
      OPEN candidate_sets_c FOR l_dynamic_sql_1
      USING IN l_parent_object_id,
            IN G_TYPE_SET,
            IN l_user_name;
      LOOP
        FETCH candidate_sets_c INTO l_one_set_id, l_one_set_predicate;
        EXIT WHEN candidate_sets_c%NOTFOUND;

        l_dynamic_sql := l_select_query_part ||
                         ' (' ||  l_one_set_predicate || ') ';

        OPEN instance_set FOR l_dynamic_sql;
        IF (instance_set % FOUND )  THEN
          l_instance_sets_list := l_instance_sets_list || l_one_set_id || ',';
        END IF;
      END LOOP;

      IF( length( l_instance_sets_list ) > 0) THEN
        -- strip off the trailing ', '
        l_instance_sets_list := SUBSTR(l_instance_sets_list, 1,
                         length(l_instance_sets_list) - length(','));
      END IF;

      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => ' Instance Sets List: '||l_instance_sets_list
                 );
      -- Step 3.
      -- Form sql using the inst Ids
      l_common_dyn_sql := '';
      l_set_dyn_sql  := '';
      l_inst_dyn_sql := '';

      l_common_dyn_sql:=
        'SELECT DISTINCT fnd_functions.function_name ' ||
         ' FROM fnd_grants grants, ' ||
              ' fnd_form_functions fnd_functions, ' ||
              ' fnd_menu_entries cmf, '||
              ' ego_obj_role_mappings mapping '||
        ' WHERE grants.object_id = :object_id '||
          ' AND grants.start_date <= SYSDATE '||
          ' AND NVL(grants.end_date,SYSDATE) >= SYSDATE ' ||
          ' AND ( ( grants.grantee_type = ''USER'' AND ' ||
                 ' grants.grantee_key = :user_name ) '||
              ' OR (grants.grantee_type = ''GROUP'' AND ' ||
                  ' grants.grantee_key in ( '||l_group_info||' )) ' ||
              ' OR (grants.grantee_type = ''COMPANY'' AND ' ||
                  ' grants.grantee_key in ( '||l_company_info||' )) ' ||
              ' OR (grants.grantee_type = ''GLOBAL'' AND ' ||
                  ' grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL'') ))'||
          ' AND mapping.child_role_id = cmf.menu_id ' ||
          ' AND mapping.parent_role_id = grants.menu_id ' ||
          ' AND mapping.child_object_id = :child_object_id ' ||
          ' AND mapping.parent_object_id = :parent_object_id ' ||
          ' AND mapping.child_object_type = :object_type ' ||
          ' AND cmf.function_id = fnd_functions.function_id ';

      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'Binds for common dyn sql '||
                                 ' l_parent_object_id: '||l_parent_object_id||
                                 ' - l_user_name: '||l_user_name||
                                 ' - l_object_id: '||l_object_id||
                                 ' - l_parent_object_id: '||l_parent_object_id||
                                 ' - p_object_type: '||p_object_type
                 );

      l_inst_dyn_sql := ' AND (grants.instance_type = :instanace_type AND (';

      if (l_db_pk1_column is not NULL) then
        l_inst_dyn_sql := l_inst_dyn_sql ||' grants.instance_pk1_value';
      end if;

      if (l_db_pk2_column is not NULL) then
        l_inst_dyn_sql := l_inst_dyn_sql || ',' ||'grants.instance_pk2_value';
      end if;

      if (l_db_pk3_column is not NULL) then
        l_inst_dyn_sql := l_inst_dyn_sql || ',' ||'grants.instance_pk3_value';
      end if;

      if (l_db_pk4_column is not NULL) then
        l_inst_dyn_sql := l_inst_dyn_sql  || ',' ||'grants.instance_pk4_value';
      end if;

      if (l_db_pk5_column is not NULL) then
        l_inst_dyn_sql := l_inst_dyn_sql || ',' ||'grants.instance_pk5_value';
      end if;
      l_inst_dyn_sql :=  l_inst_dyn_sql || ')';
      l_inst_dyn_sql :=  l_inst_dyn_sql || ' IN  ('||p_parent_object_sql_tbl (l_table_index) ||')) ';

      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'Binds for inst dyn sql '||
                                 ' G_TYPE_INSTANCE: '||G_TYPE_INSTANCE ||
                                 ' - p_parent_object_sql: '||p_parent_object_sql_tbl (l_table_index)
                 );

      l_dynamic_sql := l_common_dyn_sql || l_inst_dyn_sql;
      -- check whether it is empty set
      IF( LENGTH(l_instance_sets_list) > 0) THEN
        l_set_dyn_sql:=l_set_dyn_sql || ' AND ( ' ||
           ' grants.instance_type = :instance_type_set ' ||
           ' AND grants.instance_set_id IN ( '||l_instance_sets_list||' ) )';
        l_dynamic_sql:= l_dynamic_sql ||  ' UNION ' ||
                        l_common_dyn_sql || l_set_dyn_sql;
      END IF;
      -------------------------------------------------
      -- we see if a profile option is set and if so --
      -- we add it to the other list of menus        --
      -------------------------------------------------
      l_profile_role := getRole_mappedTo_profileOption
                                 (p_parent_object_name_tbl(l_table_index)
                                 ,p_user_name
                                 );
     code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                ,p_module    => l_api_name
                ,p_message   => 'profile role for '||p_parent_object_name_tbl(l_table_index)||
                                ' is: '||l_profile_role
                );

      IF (l_profile_role is not null) THEN
        l_dynamic_sql:= l_dynamic_sql ||' UNION ' ||
           ' SELECT DISTINCT fnd_functions.function_name ' ||
             ' FROM  fnd_form_functions fnd_functions, ' ||
                   ' fnd_menu_entries cmf, ' ||
                   ' ego_obj_role_mappings mapping, ' ||
                   ' fnd_menus  menus ' ||
             ' WHERE menus.menu_name = :profile_role ' ||
               ' AND mapping.parent_role_id = menus.menu_id ' ||
               ' AND mapping.child_role_id = cmf.menu_id  ' ||
               ' AND mapping.child_object_id =  :profile_object_id ' ||
               ' AND mapping.parent_object_id = :profile_parent_object_id ' ||
               ' AND mapping.child_object_type = :profile_object_type ' ||
               ' AND cmf.function_id = fnd_functions.function_id ';
      END IF;

      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'Final dynamic sql: '||l_dynamic_sql
                 );
      -- Step 4.
      -- execute the dynamic SQL  and Collect all privileges
      IF( LENGTH(l_instance_sets_list) > 0) THEN
        IF l_profile_role IS NOT NULL THEN
      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'Binds for Final dynamic sql '||
                       ' l_parent_object_id: '||l_parent_object_id||
                       ' - l_user_name: '||l_user_name||
                       ' - l_object_id: '||l_object_id||
                       ' - l_parent_object_id: '||l_parent_object_id||
                       ' - p_object_type: '||p_object_type||
                       ' - G_TYPE_INSTANCE: '||G_TYPE_INSTANCE ||
                       ' - p_parent_object_sql: '||p_parent_object_sql_tbl (l_table_index)||
                       ' - l_parent_object_id: '||l_parent_object_id||
                       ' - l_user_name: '||l_user_name||
                       ' - l_object_id: '||l_object_id||
                       ' - l_parent_object_id: '||l_parent_object_id||
                       ' - p_object_type: '||p_object_type||
                       ' - G_TYPE_SET: '||G_TYPE_SET||
                       ' - l_profile_role: '||l_profile_role||
                       ' - l_object_id: '||l_object_id||
                       ' - l_parent_object_id: '||l_parent_object_id||
                       ' - p_object_type: '||p_object_type
                 );
          OPEN instance_set FOR l_dynamic_sql
          USING IN l_parent_object_id,
                IN l_user_name,
                IN l_object_id,
                IN l_parent_object_id,
                IN p_object_type,
                IN G_TYPE_INSTANCE,
                IN l_parent_object_id,
                IN l_user_name,
                IN l_object_id,
                IN l_parent_object_id,
                IN p_object_type,
                IN G_TYPE_SET,
                IN l_profile_role,
                IN l_object_id,
                IN l_parent_object_id,
                IN p_object_type;
        ELSE
      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'Binds for Final dynamic sql '||
                       ' l_parent_object_id: '||l_parent_object_id||
                       ' - l_user_name: '||l_user_name||
                       ' - l_object_id: '||l_object_id||
                       ' - l_parent_object_id: '||l_parent_object_id||
                       ' - p_object_type: '||p_object_type||
                       ' - G_TYPE_INSTANCE: '||G_TYPE_INSTANCE ||
                       ' - p_parent_object_sql: '||p_parent_object_sql_tbl (l_table_index)||
                       ' - l_parent_object_id: '||l_parent_object_id||
                       ' - l_user_name: '||l_user_name||
                       ' - l_object_id: '||l_object_id||
                       ' - l_parent_object_id: '||l_parent_object_id||
                       ' - p_object_type: '||p_object_type||
                       ' - G_TYPE_SET: '||G_TYPE_SET
                 );
          OPEN instance_set FOR l_dynamic_sql
          USING IN l_parent_object_id,
                IN l_user_name,
                IN l_object_id,
                IN l_parent_object_id,
                IN p_object_type,
                IN G_TYPE_INSTANCE,
--                IN p_parent_object_sql_tbl (l_table_index),
                IN l_parent_object_id,
                IN l_user_name,
                IN l_object_id,
                IN l_parent_object_id,
                IN p_object_type,
                IN G_TYPE_SET;
        END IF;
      ELSE
        IF l_profile_role IS NOT NULL THEN
      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'Binds for Final dynamic sql '||
                       ' l_parent_object_id: '||l_parent_object_id||
                       ' - l_user_name: '||l_user_name||
                       ' - l_object_id: '||l_object_id||
                       ' - l_parent_object_id: '||l_parent_object_id||
                       ' - p_object_type: '||p_object_type||
                       ' - G_TYPE_INSTANCE: '||G_TYPE_INSTANCE ||
                       ' - p_parent_object_sql: '||p_parent_object_sql_tbl (l_table_index)||
                       ' - l_profile_role: '||l_profile_role||
                       ' - l_object_id: '||l_object_id||
                       ' - l_parent_object_id: '||l_parent_object_id||
                       ' - p_object_type: '||p_object_type
                 );
          OPEN instance_set FOR l_dynamic_sql
          USING IN l_parent_object_id,
                IN l_user_name,
                IN l_object_id,
                IN l_parent_object_id,
                IN p_object_type,
                IN G_TYPE_INSTANCE,
--                IN p_parent_object_sql_tbl (l_table_index),
                IN l_profile_role,
                IN l_object_id,
                IN l_parent_object_id,
                IN p_object_type;
        ELSE
      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'Binds for Final dynamic sql '||
                       ' l_parent_object_id: '||l_parent_object_id||
                       ' - l_user_name: '||l_user_name||
                       ' - l_object_id: '||l_object_id||
                       ' - l_parent_object_id: '||l_parent_object_id||
                       ' - p_object_type: '||p_object_type||
                       ' - G_TYPE_INSTANCE: '||G_TYPE_INSTANCE ||
                       ' - p_parent_object_sql: '||p_parent_object_sql_tbl (l_table_index)
                 );
          OPEN instance_set FOR l_dynamic_sql
          USING IN l_parent_object_id,
                IN l_user_name,
                IN l_object_id,
                IN l_parent_object_id,
                IN p_object_type,
                IN G_TYPE_INSTANCE;
--                IN p_parent_object_sql_tbl (l_table_index);
        END IF;
      END IF;

      LOOP
        FETCH instance_set  INTO l_privilege;
        EXIT WHEN instance_set%NOTFOUND;
         m_privilege_tbl  (l_index):=l_privilege;
         l_index:=l_index+1;
      END LOOP;
      CLOSE instance_set;
    END LOOP;

/**********    ENDING THE LOOP STARTED WITH THE OBJECT COUNT ***************/


    -- Step 5.
    -- get all the profile option privileges for the parent object type
    --and add to m_privilege_tbl
    get_role_functions
         (p_api_version     => p_api_version
         ,p_role_name       => l_profile_role
         ,x_return_status   => x_return_status
         ,x_privilege_tbl   => l_prof_privilege_tbl
         );
    IF (x_return_status = G_RETURN_SUCCESS) THEN
      IF (l_prof_privilege_tbl.COUNT > 0) THEN
        FOR i IN l_prof_privilege_tbl.first .. l_prof_privilege_tbl.last LOOP
          m_privilege_tbl(l_index) := l_prof_privilege_tbl(i);
          l_index:=l_index+1;
        END LOOP;
      END IF; -- x_prof_privilege_tbl >0
    END IF; --return status is T
    --end of getting privileges from profile option

    -- last step, get object function list itself to append
    get_functions(p_api_version        => 1.0,
                  p_object_name        => p_object_name,
                  p_instance_pk1_value => p_instance_pk1_value,
                  p_instance_pk2_value => p_instance_pk2_value,
                  p_instance_pk3_value => p_instance_pk3_value,
                  p_instance_pk4_value => p_instance_pk4_value,
                  p_instance_pk5_value => p_instance_pk5_value,
                  p_user_name          => l_user_name,
                  x_return_status      => l_return_status,
                  x_privilege_tbl      => l_privilege_tbl);

    l_privilege_tbl_count := l_privilege_tbl.COUNT;
    if (l_privilege_tbl_count > 0) then
      FOR i IN l_privilege_tbl.first .. l_privilege_tbl.last LOOP
        m_privilege_tbl(l_index):=l_privilege_tbl(i);
        l_index:=l_index+1;
      END LOOP;
    END IF;
    m_privilege_tbl_count := m_privilege_tbl.COUNT;
    x_privilege_tbl := EGO_VARCHAR_TBL_TYPE();
    x_index := 0;
    if (m_privilege_tbl_count > 0) then
       x_privilege_tbl.extend(m_privilege_tbl_count);
       FOR i IN m_privilege_tbl.first .. m_privilege_tbl.last LOOP
         x_privilege_tbl(i+1) := m_privilege_tbl(i);
         --x_index := x_index+1;
       END LOOP;
    end if;
    -- last step done

    if (l_index > 0) then
      x_return_status := G_RETURN_SUCCESS; /* Success */
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning previleges '
                 );
      FOR i in x_privilege_tbl.first .. x_privilege_tbl.last LOOP
        code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                   ,p_module    => l_api_name
                   ,p_message   => 'Index : '||i||' - privilege: '||x_privilege_tbl(i)
                   );
      END LOOP;
    else
      x_return_status := G_RETURN_FAILURE; /* No functions */
    end if;
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   => 'Completing with status '||x_return_status
               );

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE',G_PKG_NAME||l_api_name);
      fnd_message.set_token('ERRNO', SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      x_return_status := G_RETURN_UNEXP_ERR;
      code_debug (p_log_level => G_DEBUG_LEVEL_UNEXPECTED
                 ,p_module    => l_api_name
                 ,p_message   => 'Ending: Returning OTHER ERROR '||SQLERRM
                 );
  END get_inherited_functions;

--------------------------------------------------------
----    check_inherited_function
--------------------------------------------------------
  FUNCTION check_inherited_function
  (
   p_api_version                 IN  NUMBER,
   p_function                    IN  VARCHAR2,
   p_object_name                 IN  VARCHAR2,
   p_instance_pk1_value          IN  VARCHAR2,
   p_instance_pk2_value          IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk3_value          IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk4_value          IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk5_value          IN  VARCHAR2 DEFAULT NULL,
   p_parent_object_name_tbl      IN  EGO_VARCHAR_TBL_TYPE,
   p_parent_object_sql_tbl       IN  EGO_VARCHAR_TBL_TYPE,
   p_user_name                   IN  VARCHAR2 DEFAULT NULL,
   p_object_type                 IN  VARCHAR2 DEFAULT NULL
 )
 RETURN VARCHAR2 IS

    l_api_version       CONSTANT NUMBER := 1.0;
    l_api_name          CONSTANT VARCHAR2(30) := 'CHECK_INHERITED_FUNCTION';
    l_sysdate                    DATE := Sysdate;
    l_predicate                  VARCHAR2(32767);
--    l_orig_system                VARCHAR2(48);
    l_orig_system_id             NUMBER;
    l_dummy_id                   NUMBER;
    l_db_object_name             VARCHAR2(30);
    l_db_pk1_column              VARCHAR2(30);
    l_db_pk2_column              VARCHAR2(30);
    l_db_pk3_column              VARCHAR2(30);
    l_db_pk4_column              VARCHAR2(30);
    l_db_pk5_column              VARCHAR2(30);
    l_pk_column_names            VARCHAR2(512);
    l_pk_orig_column_names       VARCHAR2(512);
    l_type_converted_val_cols    VARCHAR2(512);
    l_result                     VARCHAR2(1);
    l_return_status              VARCHAR2(1);
    result                       VARCHAR2(30);
    l_own_result                 VARCHAR2(1);
    l_parent_object_table_count  NUMBER;
    l_set_predicates             VARCHAR2(32767);
    l_set_predicate_segment      VARCHAR2(32767);
    l_group_info                 VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_company_info               VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_menu_info                  VARCHAR2(32767); /* Must match g_pred_buf_size*/
    l_pk_values_string           VARCHAR2(2000);
    l_pk2_value_query_string     VARCHAR2(200);
    l_pk3_value_query_string     VARCHAR2(200);
    l_pk4_value_query_string     VARCHAR2(200);
    l_pk5_value_query_string     VARCHAR2(200);
    l_parent_object_count        NUMBER;

    instance_sets_cur            DYNAMIC_CUR;
    dynamic_sql                  VARCHAR2(32767);
    parent_instance_grants_c     DYNAMIC_CUR;
    parent_instance_set_grants_c DYNAMIC_CUR;
    l_dynamic_sql_1              VARCHAR2(32767);

    CURSOR menu_id_c (cp_function VARCHAR2, cp_object_id NUMBER,
                      cp_object_type VARCHAR2, cp_parent_object_id NUMBER)
    IS
    select p.parent_role_id parent_role_id
      from fnd_menu_entries r, fnd_form_functions f,
           fnd_menus m, ego_obj_role_mappings p
     where r.function_id       = f.function_id
       and r.menu_id           = m.menu_id
       and f.function_name     = cp_function
       and m.menu_id           = p.child_role_id
       and p.child_object_id   = cp_object_id
       and p.parent_object_id  = cp_parent_object_id
       and p.child_object_type = cp_object_type;

    l_object_id number;
    l_parent_object_id number;
    l_user_name varchar2(80);

    l_profile_role              VARCHAR2(30);
  BEGIN
    SetGlobals();
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   =>  'Started with 12 params '||
                   ' p_api_version: '|| to_char(p_api_version) ||
                   ' - p_function: '|| p_function ||
                   ' - p_object_name: '|| p_object_name ||
                   ' - p_instance_pk1_value: '|| p_instance_pk1_value ||
                   ' - p_instance_pk2_value: '|| p_instance_pk2_value ||
                   ' - p_instance_pk3_value: '|| p_instance_pk3_value ||
                   ' - p_instance_pk4_value: '|| p_instance_pk4_value ||
                   ' - p_instance_pk5_value: '|| p_instance_pk5_value ||
                   ' - p_user_name: '|| p_user_name ||
                   ' - p_object_type: '|| p_object_type
               );

    FOR l_table_index IN 1..p_parent_object_name_tbl.COUNT LOOP
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => ' p_parent_object_name_tbl('||l_table_index||
                                 '): '||p_parent_object_name_tbl(l_table_index)||
                                 ' - p_parent_object_sql_tbl('||l_table_index||
                                 '): '||p_parent_object_sql_tbl(l_table_index)
                 );
    END LOOP;

    -- check for call compatibility.
    if TRUNC(l_api_version) <> TRUNC(p_api_version) THEN
      fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
      fnd_message.set_token('ROUTINE',
                            g_pkg_name || '.'|| l_api_name);
      fnd_message.set_token('REASON',
                            'Unsupported version '|| to_char(p_api_version)||
                            ' passed to API; expecting version '||
                            to_char(l_api_version));
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'Returning as the call in incompatible '
               );
      return G_RETURN_UNEXP_ERR;
    end if;

    l_user_name := p_user_name;
    get_orig_key(x_user_name      => l_user_name
--                ,x_orig_system    => l_orig_system
                ,x_orig_system_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_user_name: '||l_user_name||
--                               ' - l_orig_system: '||l_orig_system||
                               ' - l_orig_system_id: '||l_orig_system_id
               );

    --call check_function first to check its own security
    --won't check it if object_instance is -1

    if (p_instance_pk1_value<>-1) then
      l_own_result := check_function(p_api_version=>1.0,
                                     p_function =>p_function,
                                     p_object_name =>p_object_name,
                                     p_instance_pk1_value => p_instance_pk1_value,
                                     p_instance_pk2_value => p_instance_pk2_value,
                                     p_instance_pk3_value => p_instance_pk3_value,
                                     p_instance_pk4_value => p_instance_pk4_value,
                                     p_instance_pk5_value => p_instance_pk5_value,
                                     p_user_name =>l_user_name);

      if (l_own_result = G_RETURN_SUCCESS) then
            RETURN l_own_result;
      end if;
    end if;

    l_object_id := get_object_id(p_object_name => p_object_name);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_object_id: '||l_object_id
               );
    l_group_info := get_group_info(p_party_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_group_info: '||l_group_info
               );
    l_company_info := get_company_info (p_party_id => l_orig_system_id);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_company_info: '||l_company_info
               );
   /**  BEGINNING OF THE LOOP ***/
  FOR l_table_index IN 1..p_parent_object_name_tbl.COUNT
    LOOP

    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'processing loop  '||l_table_index||
                               ' for object '||p_parent_object_name_tbl(l_table_index)
               );
    l_parent_object_id := get_object_id(
          p_object_name => p_parent_object_name_tbl(l_table_index)
                                       );
    ---------------
    -- Menu Info --
    ---------------
    l_menu_info := '';
    FOR menu_rec IN menu_id_c(p_function, l_object_id,
                              p_object_type,
                              l_parent_object_id)
    LOOP
      l_menu_info := l_menu_info || menu_rec.parent_role_id || ' , ';
    END LOOP;

    IF (length(l_menu_info) > 0) THEN
      -- strip off the trailing ', '
      l_menu_info := substr(l_menu_info, 1, length(l_menu_info) - length(', '));
    ELSE
      l_menu_info := 'NULL';
    END IF;

    ------------------------------------------------------------------
    -- we see if a profile option is set and if so we add it to     --
    -- the other list of menus                                      --
    ------------------------------------------------------------------
    l_profile_role := getRole_mappedTo_profileOption
                         (p_parent_object_name_tbl(l_table_index),
                          p_user_name);
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'profile role for '||p_parent_object_name_tbl(l_table_index)||
                               ' is: '||l_profile_role
               );

    IF (l_profile_role <> '') THEN
      l_dummy_id := get_role_id(l_profile_role);
      IF l_dummy_id IS NOT NULL THEN
        IF(l_menu_info = 'NULL') THEN
          l_menu_info := l_dummy_id;
        ELSE
          l_menu_info := l_menu_info || ', ' || l_dummy_id;
        END IF;
      END IF;
    END IF;
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_menu_info: '||l_menu_info
               );

    -------------------------------------------------------
    -- We set PK query strings based on values passed in --
    -- (NOTE: following bug 2865553, FND_GRANTS will not --
    -- have null PK column values, so I'm changing this  --
    -- code to check for '*NULL*' instead of null. -Dylan--
    -------------------------------------------------------
    l_db_pk1_column  := null;
    l_db_pk2_column  := null;
    l_db_pk3_column  := null;
    l_db_pk4_column  := null;
    l_db_pk5_column  := null;
    l_pk_column_names := null;
    l_type_converted_val_cols := null;
    l_pk_orig_column_names := null;
    l_db_object_name := null;

    result := get_pk_information(p_parent_object_name_tbl(l_table_index),
                                 l_db_pk1_column,
                                 l_db_pk2_column, l_db_pk3_column,
                                 l_db_pk4_column, l_db_pk5_column,
                                 l_pk_column_names, l_type_converted_val_cols,
                                 l_pk_orig_column_names, l_db_object_name);
    l_pk_values_string := '(';

    if (l_db_pk1_column is not NULL) then
      l_pk_values_string := l_pk_values_string || 'grants.instance_pk1_value';
    end if;

    if (l_db_pk2_column is not NULL) then
      l_pk_values_string := l_pk_values_string || ',' || 'grants.instance_pk2_value';
    end if;

    if (l_db_pk3_column is not NULL) then
      l_pk_values_string := l_pk_values_string || ',' || 'grants.instance_pk3_value';
    end if;

    if (l_db_pk4_column is not NULL) then
      l_pk_values_string := l_pk_values_string || ',' || 'grants.instance_pk4_value';
    end if;

    if (l_db_pk5_column is not NULL) then
      l_pk_values_string := l_pk_values_string || ',' || 'grants.instance_pk5_value';
    end if;

    l_pk_values_string := l_pk_values_string || ')';
    l_pk_values_string := l_pk_values_string || ' IN ' || '(' || p_parent_object_sql_tbl(l_table_index) || ')';
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_pk_values_string: '||l_pk_values_string
               );

    -------------------------------------------------------------------------------
    -- Now we build dynamic SQL using the work we just did to optimize the query --
    -------------------------------------------------------------------------------

    l_dynamic_sql_1 :=
      'SELECT ''X'' ' ||
       ' FROM fnd_grants grants ' ||
      ' WHERE grants.object_id = :object_id ' ||
        ' AND grants.start_date <= SYSDATE '||
        ' AND NVL(grants.end_date, SYSDATE) >= SYSDATE ' ||
        ' AND grants.instance_type = :instance_type ' ||
        ' AND ' || l_pk_values_string ||
        ' AND ( ( grants.grantee_type = ''USER'' AND ' ||
               ' grants.grantee_key = :user_name ) '||
               ' OR ( grants.grantee_type = ''GROUP'' AND '||
               ' grants.grantee_key in ( '||l_group_info||' ))' ||
               ' OR ( grants.grantee_type = ''COMPANY'' AND '||
               ' grants.grantee_key in ( '||l_company_info||' ))' ||
               ' OR (grants.grantee_type = ''GLOBAL'' AND '||
               ' grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL'') )) '||
        ' AND grants.menu_id IN (' || l_menu_info ||') ';
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'l_dynamic_sql_1: '||l_dynamic_sql_1
               );
    code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
               ,p_module    => l_api_name
               ,p_message   => 'Binds for get parent_direct_grants : '||
                               'l_parent_object_id: '||l_parent_object_id||
                               ' - G_TYPE_INSTANCE: '||G_TYPE_INSTANCE||
                               ' - l_user_name: '||l_user_name
               );

    OPEN parent_instance_grants_c
    FOR l_dynamic_sql_1
    USING IN l_parent_object_id,
          IN G_TYPE_INSTANCE,
          IN l_user_name;
    FETCH parent_instance_grants_c INTO l_result;
    CLOSE parent_instance_grants_c;

    IF (l_result = 'X') THEN
      RETURN G_RETURN_SUCCESS;
    ELSE
      ---------------------------------------------------------------------------------
      -- Now we build a second dynamic SQL to check instance sets (still optimizing) --
      ---------------------------------------------------------------------------------
      l_set_predicates := '';
      l_set_predicate_segment := '';

      l_dynamic_sql_1 :=
       ' SELECT DISTINCT instance_sets.predicate ' ||
         ' FROM fnd_grants grants, fnd_object_instance_sets instance_sets ' ||
        ' WHERE grants.instance_type = :instance_type '||
          ' AND grants.start_date <= SYSDATE ' ||
          ' AND (grants.end_date IS NULL OR grants.end_date >= SYSDATE) ' ||
          ' AND grants.instance_set_id = instance_sets.instance_set_id ' ||
          ' AND grants.object_id = :parent_object_id '||
          ' AND ( ( grants.grantee_type = ''USER'' AND ' ||
               ' grants.grantee_key = :user_name ) '||
               ' OR ( grants.grantee_type = ''GROUP'' AND '||
               ' grants.grantee_key in ( '||l_group_info||' ))' ||
               ' OR ( grants.grantee_type = ''COMPANY'' AND '||
               ' grants.grantee_key in ( '||l_company_info||' ))' ||
               ' OR (grants.grantee_type = ''GLOBAL'' AND '||
               ' grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL'') )) '||
          ' AND grants.menu_id in (' || l_menu_info || ')';

      ----------------------------------------------------------------------
      -- Loop through the result set adding each segment to the predicate --
      ----------------------------------------------------------------------

      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'l_dynamic_sql_1: '||l_dynamic_sql_1
                 );
      code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                 ,p_module    => l_api_name
                 ,p_message   => 'Binds for get parent_instance_set_grants_c : '||
                                 'G_TYPE_SET: '||G_TYPE_SET||
                                 ' - l_parent_object_id: '||l_parent_object_id||
                                 ' - l_user_name: '||l_user_name
                 );

      OPEN parent_instance_set_grants_c
      FOR l_dynamic_sql_1
      USING IN G_TYPE_SET,
            IN l_parent_object_id,
            IN l_user_name;
      LOOP
        FETCH parent_instance_set_grants_c into l_set_predicate_segment;
        EXIT WHEN parent_instance_set_grants_c%NOTFOUND;

        l_set_predicates := substrb(l_set_predicates ||
                            l_set_predicate_segment ||
                            ' OR ',
                            1, g_pred_buf_size);
      END LOOP;
      CLOSE parent_instance_set_grants_c;

      IF (length(l_set_predicates) > 0) THEN
        -- strip off the trailing 'OR'
        l_set_predicates := substr(l_set_predicates, 1,
                                   length(l_set_predicates) - length('OR '));
      END IF;
      -- finished by.a
      l_predicate := l_set_predicates;

      IF (length(l_predicate) > 1) THEN
        dynamic_sql :=
          'SELECT ''X'' '||
           ' FROM '|| l_db_object_name ||
          ' WHERE (';

        if (l_db_pk1_column is not NULL) then
           dynamic_sql := dynamic_sql ||
           l_db_pk1_column;
        end if;

        if (l_db_pk2_column is not NULL) then
           dynamic_sql := dynamic_sql || ',' ||
           l_db_pk2_column ; /** db_pk2_column||' ,'; **/
        end if;

        if (l_db_pk3_column is not NULL) then
           dynamic_sql := dynamic_sql || ',' ||
           l_db_pk3_column;
        end if;

        if (l_db_pk4_column is not NULL) then
           dynamic_sql := dynamic_sql  || ',' ||
           l_db_pk4_column;
        end if;

        if (l_db_pk5_column is not NULL) then
           dynamic_sql := dynamic_sql || ',' ||
           l_db_pk5_column;
        end if;

        dynamic_sql := dynamic_sql || ')' || 'IN' || '(';
        dynamic_sql :=  dynamic_sql ||  p_parent_object_sql_tbl (l_table_index) || ')';
        dynamic_sql := dynamic_sql || ' AND ('||l_predicate||') ';

        code_debug (p_log_level => G_DEBUG_LEVEL_STATEMENT
                   ,p_module    => l_api_name
                   ,p_message   => 'Final dynamic Sql '||dynamic_sql
                   );
        OPEN instance_sets_cur FOR dynamic_sql;
             FETCH instance_sets_cur INTO l_own_result;
        IF(instance_sets_cur%NOTFOUND) THEN
           CLOSE instance_sets_cur;
           code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                      ,p_module    => l_api_name
                      ,p_message   => 'Returning FAILURE as object not found in sets '
                      );
           RETURN G_RETURN_FAILURE;
        ELSE
           CLOSE instance_sets_cur;
           code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                      ,p_module    => l_api_name
                      ,p_message   => 'Returning SUCCESS as object found in sets '
                      );
           RETURN G_RETURN_SUCCESS;
        END IF;
      ELSE
        -- No predicate
        code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                   ,p_module    => l_api_name
                   ,p_message   => 'Returning FAILURE as no predicate is found '
                   );
        RETURN G_RETURN_FAILURE;
      END IF; -- End of if l_predicate length is greater than 0 else clause
    END IF; -- End of if l_result is 'X' else clause
   END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE',G_PKG_NAME||l_api_name);
      fnd_message.set_token('ERRNO', SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      code_debug (p_log_level => G_DEBUG_LEVEL_UNEXPECTED
                 ,p_module    => l_api_name
                 ,p_message   => 'Ending: Returning OTHER ERROR '||SQLERRM
                 );
      RETURN G_RETURN_UNEXP_ERR;
  END check_inherited_function;

  ----------------------------------------------------------------
END EGO_DATA_SECURITY;

/
