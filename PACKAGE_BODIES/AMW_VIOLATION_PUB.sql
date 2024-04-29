--------------------------------------------------------
--  DDL for Package Body AMW_VIOLATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_VIOLATION_PUB" as
/* $Header: amwvpubb.pls 120.9 2008/02/18 09:23:59 ptulasi ship $ */


l_curr_log_level number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_log_stmt_level number := FND_LOG.LEVEL_STATEMENT;
g_menu_id_list G_NUMBER_TABLE;
g_function_id_list G_NUMBER_TABLE;
g_menu_function_id_list G_NUMBER_TABLE;

-- ===============================================================
-- Private Function name
--          get_User_Id
--
-- Purpose
--          This function takes user_name as input and returns user_id
-- Params
--          p_user_name          := user_name
-- Return
-- Notes
-- History
--          18.02.2008 ptulasi: Created for bug 6715425
--
-- ===============================================================
Function get_User_Id (
    p_user_name     IN  VARCHAR2
) return NUMBER IS
p_user_id NUMBER;
BEGIN

    SELECT user_id INTO p_user_id  FROM fnd_user WHERE user_name = p_user_name;
    RETURN p_user_id;
END get_User_Id;

-- ===============================================================
-- Private Function name
--          PROCESS_MENU_TREE_DOWN_FOR_MN
--
-- Purpose
--          Plow through the menu tree to find all the functions in it.
-- Params
--          p_menu_id           := menu_id
-- Return
-- Notes
-- History
--          07.05.2007 psomanat: Created for bug 6010908
--
-- ===============================================================
FUNCTION PROCESS_MENU_TREE_DOWN_FOR_MN( p_menu_id IN number )
RETURN boolean IS
    L_API_NAME                  CONSTANT VARCHAR2(30) := 'PROCESS_MENU_TREE_DOWN_FOR_MN';
    L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

    TYPE NUMBER_TABLE_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE MENULIST_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE MNESCURTYP IS REF CURSOR;

    get_mnes_c MNESCURTYP;
    l_mnes_dynamic_sql   VARCHAR2(200)  :=
        'SELECT MENU_ID,FUNCTION_ID, SUB_MENU_ID '
      ||'  FROM '||G_AMW_MENU_ENTRIES
      ||' WHERE menu_id  = :1 ';


    tbl_func_id NUMBER_TABLE_TYPE;
    tbl_submnu_id NUMBER_TABLE_TYPE;
    tbl_menu_id NUMBER_TABLE_TYPE;

    menulist  MENULIST_TYPE;
    menulist_cur PLS_INTEGER;
    menulist_size PLS_INTEGER;
    last_index PLS_INTEGER;
    c_max_menu_entries CONSTANT PLS_INTEGER := 10000;
    l_sub_menu_id NUMBER;



BEGIN
    -- Initialize menulist working list to parent menu
    menulist_cur := 0;
    menulist_size := 1;
    menulist(0) := p_menu_id;

    -- Continue processing until reach the end of list
    WHILE (menulist_cur < menulist_size)
    LOOP
        -- Check if recursion limit exceeded
        IF (menulist_cur > c_max_menu_entries) THEN
            /* If the function were accessible from this menu, then we should */
            /* have found it before getting to this point, so we are confident */
            /* that the function is not on this menu. */
            RETURN false;
        END IF;

        l_sub_menu_id := menulist(menulist_cur);

        IF g_menu_id_list.EXISTS(l_sub_menu_id) THEN
             menulist_cur := menulist_cur + 1;
        ELSE
            IF l_sub_menu_id IS NOT NULL THEN
                g_menu_id_list(l_sub_menu_id):=l_sub_menu_id;

            END IF;

            OPEN get_mnes_c FOR l_mnes_dynamic_sql USING l_sub_menu_id;
            FETCH get_mnes_c BULK COLLECT INTO tbl_menu_id,tbl_func_id, tbl_submnu_id;
            CLOSE get_mnes_c;

            -- See if we found any rows. If not set last_index to zero.
            BEGIN
                IF((tbl_menu_id.FIRST IS NULL) OR (tbl_menu_id.FIRST <> 1)) THEN
                    last_index := 0;
                ELSE
                    IF (tbl_menu_id.FIRST IS NOT NULL) THEN
                        last_index := tbl_menu_id.LAST;
                    ELSE
                        last_index := 0;
                    END IF;
                END IF;
            EXCEPTION
                WHEN others THEN
                    last_index := 0;
            END;

            -- Process each of the child entries fetched
            FOR i IN 1 .. last_index LOOP

                -- If this is a submenu, then add it to the end of the
                -- working list for processing.
                IF (tbl_submnu_id(i) IS NOT NULL) THEN
                    menulist(menulist_size) := tbl_submnu_id(i);
                    menulist_size := menulist_size + 1;
                ELSE
                    IF NOT(g_function_id_list.EXISTS(tbl_func_id(i))) THEN
                        g_function_id_list(tbl_func_id(i)):=tbl_func_id(i);
                        g_menu_function_id_list(g_menu_function_id_list.count+1):=tbl_func_id(i);
                    END IF;
                END IF;
            END LOOP;  -- For loop processing child entries

            -- Advance to next menu on working list
            menulist_cur := menulist_cur + 1;
        END IF;
    END LOOP;
    -- We couldn't find the function anywhere, so it's not available
    RETURN true;
END PROCESS_MENU_TREE_DOWN_FOR_MN;


-- ===============================================================
-- Function name
--          Check_Resp_Violations
--
-- Purpose
--          check for OICM SOD constriants that will be violated
--          if the user is assigned the additional responsibility
-- Params
--          p_user_id            := input fnd user_id
--          p_responsibility_id  := input fnd responsibility_id
-- Return
--          'N'                  := if no SOD violation found.
--          'Y'                  := if SOD violation exists.
--                                  The SOD violation should NOT be restricted to
--                                  only the new responsiblity.
--                                  If the existing responsibilities have any violations,
--                                  the function should return 'Y' as well.
--
-- History
-- 		  	07/13/2005    tsho     Create
--          08/03/2005    tsho     Consider User Waivers
--          08/22/2005    tsho     Consider only prevent(PR) constraint objective
-- ===============================================================
Function Check_Resp_Violations (
    p_user_id               IN  NUMBER,
    p_responsibility_id     IN  NUMBER
) return VARCHAR2
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Has_Violation_Due_To_Resp';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

-- return result
has_violation VARCHAR2(10);

-- find all valid preventive constraints
CURSOR c_all_valid_constraints IS
      SELECT constraint_rev_id, type_code
        FROM amw_constraints_b
       WHERE start_date <= sysdate AND (end_date IS NULL OR end_date >= sysdate)
       AND objective_code = 'PR';


l_all_valid_constraints c_all_valid_constraints%ROWTYPE;

-- find the number of constraint entries(incompatible functions) by specified constraint_rev_id
l_constraint_entries_count NUMBER;
l_func_access_count NUMBER;
l_group_access_count NUMBER;
l_resp_access_count NUMBER;


CURSOR c_constraint_entries_count (l_constraint_rev_id IN NUMBER) IS
      SELECT count(*)
        FROM amw_constraint_entries
	   WHERE constraint_rev_id=l_constraint_rev_id;

TYPE refCurTyp IS REF CURSOR;
func_acess_count_c refCurTyp;
group_acess_count_c refCurTyp;
new_violation_count_c refCurTyp;
resp_acess_count_c refCurTyp;

l_vio_new_resp_sql VARCHAR2(32767);

l_func_sql VARCHAR2(32767);
-- in amw.e, we don't consider UMX integration and role/resp hierarchy structure
l_func_id_sql   VARCHAR2(32767)  :=
    'select distinct function_id from ( '
  ||'  select rcd.function_id '
  ||'  from amw_role_constraint_denorm rcd '
  ||'      ,'||G_AMW_USER_ROLES||' ur '
  ||'      ,'||G_AMW_user||' u '
  ||'  where rcd.constraint_rev_id = :1 '
  ||'    and u.user_id = :2 '
  ||'    and u.user_name = ur.user_name '
  ||'    and ur.role_name = rcd.role_name '
  ||'    and ur.role_orig_system = ''UMX'' '
  ||'  UNION ALL '
  ||'  select rcd.function_id '
  ||'  from amw_role_constraint_denorm rcd '
  ||'      ,'||G_AMW_USER_ROLES||' ur '
  ||'      ,'||G_AMW_user||' u '
  ||'  where rcd.constraint_rev_id = :3 '
  ||'    and u.user_id = :4 '
  ||'    and u.user_name = ur.user_name '
  ||'    and ur.role_orig_system_id = rcd.responsibility_id '
  ||'    and ur.role_orig_system = ''FND_RESP'' '
  ||'  UNION ALL '
  ||'  select rcd.function_id '
  ||'  from amw_role_constraint_denorm rcd '
  ||'      ,'||G_AMW_GRANTS||' gra '
  ||'      ,'||G_AMW_USER||' u '
  ||'  where rcd.constraint_rev_id = :5 '
  ||'    and u.user_id = :6 '
  ||'    and u.user_name = gra.grantee_key '
  ||'    and gra.grantee_type = ''USER'' '
  ||'    and gra.menu_id = rcd.menu_id '
  ||'    and gra.instance_type = ''GLOBAL'' '
  ||'    and gra.object_id = -1 '
  ||'  UNION ALL '
  ||'  select rcd.function_id '
  ||'  from amw_role_constraint_denorm rcd '
  ||'      ,'||G_AMW_GRANTS||' gra '
  ||'  where rcd.constraint_rev_id = :7 '
  ||'    and gra.grantee_key = ''GLOBAL'' '
  ||'    and gra.grantee_type = ''GLOBAL'' '
  ||'    and gra.menu_id = rcd.menu_id '
  ||'    and gra.instance_type = ''GLOBAL'' '
  ||'    and gra.object_id = -1 '
  ||'  UNION ALL '
  ||'  select rcd.function_id '
  ||'  from amw_role_constraint_denorm rcd '
  ||'  where rcd.constraint_rev_id = :8 '
  ||'    and rcd.responsibility_id = :9 '
  ||') ';

l_func_dynamic_sql   VARCHAR2(32767)  :=
    'select count(function_id) from ( '
    || l_func_id_sql
    || ') ';

l_func_set_id_sql   VARCHAR2(2500)  :=
    'select distinct group_code from ( '
  ||'  select rcd.group_code '
  ||'  from amw_role_constraint_denorm rcd '
  ||'      ,'||G_AMW_USER_ROLES||' ur '
  ||'      ,'||G_AMW_user||' u '
  ||'  where rcd.constraint_rev_id = :1 '
  ||'    and u.user_id = :2 '
  ||'    and u.user_name = ur.user_name '
  ||'    and ur.role_name = rcd.role_name '
  ||'    and ur.role_orig_system = ''UMX'' '
  ||'  UNION ALL '
  ||'  select rcd.group_code '
  ||'  from amw_role_constraint_denorm rcd '
  ||'      ,'||G_AMW_USER_ROLES||' ur '
  ||'      ,'||G_AMW_user||' u '
  ||'  where rcd.constraint_rev_id = :3 '
  ||'    and u.user_id = :4 '
  ||'    and u.user_name = ur.user_name '
  ||'    and ur.role_orig_system_id = rcd.responsibility_id '
  ||'    and ur.role_orig_system = ''FND_RESP'' '
  ||'  UNION ALL '
  ||'  select rcd.group_code '
  ||'  from amw_role_constraint_denorm rcd '
  ||'      ,'||G_AMW_GRANTS||' gra '
  ||'      ,'||G_AMW_USER||' u '
  ||'  where rcd.constraint_rev_id = :5 '
  ||'    and u.user_id = :6 '
  ||'    and u.user_name = gra.grantee_key '
  ||'    and gra.grantee_type = ''USER'' '
  ||'    and gra.menu_id = rcd.menu_id '
  ||'    and gra.instance_type = ''GLOBAL'' '
  ||'    and gra.object_id = -1 '
  ||'  UNION ALL '
  ||'  select rcd.group_code '
  ||'  from amw_role_constraint_denorm rcd '
  ||'      ,'||G_AMW_GRANTS||' gra '
  ||'  where rcd.constraint_rev_id = :7 '
  ||'    and gra.grantee_key = ''GLOBAL'' '
  ||'    and gra.grantee_type = ''GLOBAL'' '
  ||'    and gra.menu_id = rcd.menu_id '
  ||'    and gra.instance_type = ''GLOBAL'' '
  ||'    and gra.object_id = -1 '
  ||'  UNION ALL '
  ||'  select rcd.group_code '
  ||'  from amw_role_constraint_denorm rcd '
  ||'  where rcd.constraint_rev_id = :8 '
  ||'  and rcd.responsibility_id = :9 '
  ||') ';

  l_func_set_dynamic_sql   VARCHAR2(2500)  :=
    'select count(group_code) from ( '
    || l_func_set_id_sql
    ||' ) ';


 l_resp_sql VARCHAR2(32767);


-- all of roles including the existing ones and the newly assigned ones
l_resp_all_sql   VARCHAR2(32767)  :=
  '  select ur.role_orig_system_id '
  ||'  from '
  || G_AMW_USER_ROLES||' ur '
  ||'      ,'||G_AMW_user||' u '
  ||'      ,amw_constraint_entries cst '
  ||'  where  u.user_id = :1 '
  ||'    and  cst.constraint_rev_id = :2 '
  ||'    and u.user_name = ur.user_name '
  ||'    and ur.role_orig_system_id = cst.function_id '
  ||'    and ur.role_orig_system = ''FND_RESP'' '
  ||'  UNION '
  ||'  select cst.function_id as orig_system_id '
  ||'  from  amw_constraint_entries cst '
  ||'  where  cst.constraint_rev_id = :3 '
  ||'  and cst.function_id = :4 ';


l_resp_dynamic_sql  VARCHAR2(32767) :=
' select count(role_orig_system_id) from ( '
|| l_resp_all_sql
||')';


l_resp_set_all_sql   VARCHAR2(32767)  :=
  '  select cst.group_code '
  ||'  from '
  || G_AMW_USER_ROLES||' ur '
  ||'      ,'||G_AMW_user||' u '
  ||'      ,amw_constraint_entries cst '
  ||'  where  u.user_id = :1 '
  ||'    and  cst.constraint_rev_id = :2 '
  ||'    and u.user_name = ur.user_name '
  ||'    and ur.role_orig_system_id = cst.function_id '
  ||'    and ur.role_orig_system = ''FND_RESP'' '
  ||'  UNION '
  ||'  select cst.group_code '
  ||'  from   amw_constraint_entries cst '
  ||'  where  cst.constraint_rev_id = :3 '
  ||'  and cst.function_id = :4 ';

  l_resp_set_dynamic_sql   VARCHAR2(32767) :=
  ' select count(group_code) from ( '
|| l_resp_set_all_sql
||')';


-- get valid user waiver
l_valid_user_waiver_count NUMBER;
CURSOR c_valid_user_waivers (l_constraint_rev_id IN NUMBER, l_user_id IN NUMBER) IS
    SELECT count(*)
      FROM amw_constraint_waivers_vl
     WHERE constraint_rev_id = l_constraint_rev_id
       AND object_type = 'USER'
       AND PK1 = l_user_id
       AND start_date <= sysdate AND (end_date >= sysdate or end_date is null);

       l_cst_new_violation_sql   VARCHAR2(5000) ;

BEGIN

    IF( l_log_stmt_level >= l_curr_log_level ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','Check_Resp_Violations Start');
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','p_user_id             = '|| p_user_id );
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','p_responsibility_id   = '|| p_responsibility_id);
	END IF;

  -- default to 'N', which means user doesn't have violations
  has_violation := 'N';
  l_valid_user_waiver_count := 0;

  IF (p_user_id IS NOT NULL AND p_responsibility_id IS NOT NULL) THEN
    -- check all valid constraints
    OPEN c_all_valid_constraints;
    LOOP
     FETCH c_all_valid_constraints INTO l_all_valid_constraints;
     EXIT WHEN c_all_valid_constraints%NOTFOUND;

     -- check if this user is waived (due to User Waiver) from this constraint
     OPEN c_valid_user_waivers(l_all_valid_constraints.constraint_rev_id, p_user_id);
     FETCH c_valid_user_waivers INTO l_valid_user_waiver_count;
     CLOSE c_valid_user_waivers;

    IF l_valid_user_waiver_count <= 0 THEN

      IF 'ALL' = l_all_valid_constraints.type_code THEN

        -- find the number of constraint entries(incompatible functions) by specified constraint_rev_id
        OPEN c_constraint_entries_count (l_all_valid_constraints.constraint_rev_id);
        FETCH c_constraint_entries_count INTO l_constraint_entries_count;
        CLOSE c_constraint_entries_count;

        OPEN func_acess_count_c FOR l_func_dynamic_sql USING
              l_all_valid_constraints.constraint_rev_id,
              p_user_id,
              l_all_valid_constraints.constraint_rev_id,
              p_user_id,
              l_all_valid_constraints.constraint_rev_id,
              p_user_id,
              l_all_valid_constraints.constraint_rev_id,
              l_all_valid_constraints.constraint_rev_id,
              p_responsibility_id;
        FETCH func_acess_count_c INTO l_func_access_count;
        CLOSE func_acess_count_c;

        -- in ALL type: if user can access to all entries of this constraint,
        -- he violates this constraint
        IF l_func_access_count = l_constraint_entries_count THEN

            -- Check to see if the fuction enteries in the constraint is same
            -- as the functions the user can access due to the assigning of
            -- this role
            l_func_sql :='select count(function_id)'
                        ||'from ('
                        ||'select function_id from ( '
                        ||   l_func_id_sql
                        ||') '
                        ||' MINUS '
                        ||' select FUNCTION_ID from amw_constraint_entries where constraint_rev_id = :10'
                        ||')';



            OPEN func_acess_count_c FOR l_func_sql USING
                l_all_valid_constraints.constraint_rev_id,
                p_user_id,
                l_all_valid_constraints.constraint_rev_id,
                p_user_id,
                l_all_valid_constraints.constraint_rev_id,
                p_user_id,
                l_all_valid_constraints.constraint_rev_id,
                l_all_valid_constraints.constraint_rev_id,
                p_responsibility_id,
                l_all_valid_constraints.constraint_rev_id;
            FETCH func_acess_count_c INTO l_func_access_count;
            CLOSE func_acess_count_c;

            IF l_func_access_count = 0 THEN
           	    -- once he violates at least one constraint, break the loop and inform FALSE to the caller
               	FND_FILE.put_line(fnd_file.log, '------------ fail on constraint - ALL = '||l_all_valid_constraints.constraint_rev_id ||' ---------------');
               	has_violation := 'Y';
               	return has_violation;
           	END IF;
        END IF;
      ELSIF 'ME' = l_all_valid_constraints.type_code THEN

        -- find the number of distinct constraint entries this user can access
        OPEN func_acess_count_c FOR l_func_dynamic_sql USING
              l_all_valid_constraints.constraint_rev_id,
              p_user_id,
              l_all_valid_constraints.constraint_rev_id,
              p_user_id,
              l_all_valid_constraints.constraint_rev_id,
              p_user_id,
              l_all_valid_constraints.constraint_rev_id,
              l_all_valid_constraints.constraint_rev_id,
              p_responsibility_id;
        FETCH func_acess_count_c INTO l_func_access_count;
        CLOSE func_acess_count_c;

        -- in ME type: if user can access at least two entries of this constraint,
        -- he violates this constraint
        IF l_func_access_count >= 2 THEN
            -- once he violates at least one constraint, break the loop and inform FALSE to the caller
            FND_FILE.put_line(fnd_file.log,'------------ fail on constraint - ME = '||l_all_valid_constraints.constraint_rev_id ||' ---------------');
            has_violation := 'Y';
            return has_violation;
        END IF;
      ELSIF 'SET' = l_all_valid_constraints.type_code THEN

        -- find the number of distinct constraint entries this user can access
        OPEN group_acess_count_c FOR l_func_set_dynamic_sql USING
              l_all_valid_constraints.constraint_rev_id,
              p_user_id,
              l_all_valid_constraints.constraint_rev_id,
              p_user_id,
              l_all_valid_constraints.constraint_rev_id,
              p_user_id,
              l_all_valid_constraints.constraint_rev_id,
              l_all_valid_constraints.constraint_rev_id,
              p_responsibility_id;
        FETCH group_acess_count_c INTO l_group_access_count;
        CLOSE group_acess_count_c;

        -- in SET type: if user can access at least two distinct groups(set) of this constraint,
        -- he violates this constraint
        IF l_group_access_count >= 2 THEN
            -- once he violates at least one constraint, break the loop and inform FALSE to the caller
            -- FND_FILE.put_line(fnd_file.log,'------------ fail on constraint - SET = '||l_all_valid_constraints.constraint_rev_id ||' ---------------');
            has_violation := 'Y';
            return has_violation;
        END IF;
     ELSIF 'RESPALL' = l_all_valid_constraints.type_code THEN
        -- find the number of constraint entries(incompatible functions) by specified constraint_rev_id
        OPEN c_constraint_entries_count (l_all_valid_constraints.constraint_rev_id);
        FETCH c_constraint_entries_count INTO l_constraint_entries_count;
        CLOSE c_constraint_entries_count;

            OPEN resp_acess_count_c FOR l_resp_dynamic_sql USING
            p_user_id,
            l_all_valid_constraints.constraint_rev_id,
            l_all_valid_constraints.constraint_rev_id,
             p_responsibility_id;
            FETCH resp_acess_count_c INTO l_resp_access_count;
            CLOSE resp_acess_count_c;

            -- in ALL type: if user can access to all entries of this constraint,
            -- he violates this constraint
            IF l_resp_access_count = l_constraint_entries_count THEN

            -- Check to see if the fuction enteries in the constraint is same
            -- as the functions the user can access due to the assigning of
            -- this role

            l_resp_sql := 'select count(distinct role_orig_system_id)'
             ||' from ('
             ||  l_resp_all_sql
             ||' MINUS '
             ||' select FUNCTION_ID from amw_constraint_entries where constraint_rev_id = :5'
             ||')';


                OPEN resp_acess_count_c FOR l_resp_sql USING
                p_user_id,
                l_all_valid_constraints.constraint_rev_id,
                l_all_valid_constraints.constraint_rev_id,
                p_responsibility_id,
                l_all_valid_constraints.constraint_rev_id;
                FETCH resp_acess_count_c INTO l_resp_access_count;
                CLOSE resp_acess_count_c;

                IF l_resp_access_count = 0 THEN
                 -- once he violates at least one constraint, break the loop and inform FALSE to the caller
                    FND_FILE.put_line(fnd_file.log, '----fail on constraint - ALL = '||l_all_valid_constraints.constraint_rev_id ||' ---------------');
                    has_violation := 'Y';
                    return has_violation;
                END IF;
            END IF;

        ELSIF 'RESPME' = l_all_valid_constraints.type_code THEN


                -- find the number of distinct constraint entries this user can access
                OPEN resp_acess_count_c FOR l_resp_dynamic_sql USING
                p_user_id,
                l_all_valid_constraints.constraint_rev_id,
                l_all_valid_constraints.constraint_rev_id,
                p_responsibility_id;
                FETCH resp_acess_count_c INTO l_resp_access_count;
                CLOSE resp_acess_count_c;


                IF( l_log_stmt_level >= l_curr_log_level ) THEN
    	           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','l_resp_access_count = '|| l_resp_access_count );
                END IF;

                -- in ME type: if user can access at least two entries of this constraint,
                -- he violates this constraint
                IF l_resp_access_count >= 2 THEN
                    -- once he violates at least one constraint, break the loop and inform FALSE to the caller
                    FND_FILE.put_line(fnd_file.log,'------------ fail on constraint - ME = '||l_all_valid_constraints.constraint_rev_id ||' ---------------');
                    has_violation := 'Y';

                    IF( l_log_stmt_level >= l_curr_log_level ) THEN
    	               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','has_violation = '|| has_violation );
    	               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','Check_Resp_Violations End');
                    END IF;

                    return has_violation;
                END IF;

      ELSIF 'RESPSET' = l_all_valid_constraints.type_code THEN


              -- find the number of distinct constraint entries this user can access

                OPEN resp_acess_count_c FOR l_resp_set_dynamic_sql USING
                p_user_id,
                l_all_valid_constraints.constraint_rev_id,
                l_all_valid_constraints.constraint_rev_id,
                p_responsibility_id;
                FETCH resp_acess_count_c INTO l_resp_access_count;
                CLOSE resp_acess_count_c;

                -- in SET type: if user can access at least two distinct groups(set) of this constraint,
                -- he violates this constraint
                IF l_resp_access_count >= 2 THEN
                    -- once he violates at least one constraint, break the loop and inform FALSE to the caller
                    FND_FILE.put_line(fnd_file.log,'------------ fail on constraint - SET = '||l_all_valid_constraints.constraint_rev_id ||' ---------------');
                    has_violation := 'Y';
                    return has_violation;
                END IF;
      ELSE
        -- other constraint types
        NULL;
      END IF; -- end of if: constraint type_code

     END IF; -- end of if: l_valid_user_waiver_count <= 0

    END LOOP; --end of loop: c_all_valid_constraints
    CLOSE c_all_valid_constraints;

  END IF; -- end of if: p_user_id IS NOT NULL AND p_responsibility_id IS NOT NULL

    IF( l_log_stmt_level >= l_curr_log_level ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','Last has_violation = '|| has_violation );
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','Check_Resp_Violations End');
	END IF;

  return has_violation;

EXCEPTION
    WHEN OTHERS THEN
    IF( l_log_stmt_level >= l_curr_log_level ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','Error '||TO_CHAR(SQLCODE)||': '||SQLERRM);
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','Check_Resp_Violations End');
	END IF;
	RAISE;

END Check_Resp_Violations;



-- ===============================================================
-- Function name
--          User_Resp_Violation_Details
--
-- Purpose
--          check for OICM SOD constriants that will be violated
--          if the user is assigned the additional responsibility
-- Params
--          p_user_id            := input fnd user_id
--          p_responsibility_id  := input fnd responsibility_id
-- Return
--          'N'                            := if no SOD violation found.
--          'ConstraintName:Resp_name1;Resp_name2;...'    := if SOD violation exists.
--                                            The SOD violation should NOT be restricted to
--                                            only the new responsiblity.
--                                            If the existing responsibilities have any violations,
--                                            the function should return 'Y' as well.
--
-- History
-- 		  	08/01/2005    tsho     Create
--          08/03/2005    tsho     Consider User Waivers
--          08/22/2005    tsho     Consider only prevent(PR) constraint objective
-- ===============================================================
Function User_Resp_Violation_Details (
    p_user_id               IN  NUMBER,
    p_responsibility_id     IN  NUMBER
) return VARCHAR2
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Violation_Detail_Due_To_Resp';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

-- return result
has_violation VARCHAR2(32767);
l_violat_existing_resp VARCHAR2(10000);
l_violat_existing_role VARCHAR2(10000);
l_violat_existing_menu VARCHAR2(10000);
l_violat_new_resp VARCHAR2(10000);
l_violat_new_func VARCHAR2(10000);

l_resp_access_count NUMBER;

l_new_func_table JTF_VARCHAR2_TABLE_400;

-- 05.23.2006 dliao: consider only Prevent Constraint Objective
CURSOR c_all_valid_constraints IS
      SELECT constraint_rev_id, type_code, constraint_name
        FROM amw_constraints_vl
       WHERE start_date <= sysdate AND (end_date IS NULL OR end_date >= sysdate)
       and objective_code = 'PR';
l_all_valid_constraints c_all_valid_constraints%ROWTYPE;

-- find the number of constraint entries(incompatible functions) by specified constraint_rev_id
l_constraint_entries_count NUMBER;
l_func_access_count NUMBER;
l_group_access_count NUMBER;
CURSOR c_constraint_entries_count (l_constraint_rev_id IN NUMBER) IS
      SELECT count(*)
        FROM amw_constraint_entries
	   WHERE constraint_rev_id=l_constraint_rev_id;


TYPE refCurTyp IS REF CURSOR;
func_acess_count_c refCurTyp;
group_acess_count_c refCurTyp;
resp_acess_count_c refCurTyp;

l_func_dynamic_sql   VARCHAR2(2500)  :=
    'select count(distinct function_id) from ( '
  ||'  select rcd.function_id '
  ||'  from amw_role_constraint_denorm rcd '
  ||'      ,'||G_AMW_USER_ROLES||' ur '
  ||'      ,'||G_AMW_user||' u '
  ||'  where rcd.constraint_rev_id = :1 '
  ||'    and u.user_id = :2 '
  ||'    and u.user_name = ur.user_name '
  ||'    and ur.role_name = rcd.role_name '
  ||'    and ur.role_orig_system = ''UMX'' '
  ||'  UNION ALL '
  ||'  select rcd.function_id '
  ||'  from amw_role_constraint_denorm rcd '
  ||'      ,'||G_AMW_USER_ROLES||' ur '
  ||'      ,'||G_AMW_user||' u '
  ||'  where rcd.constraint_rev_id = :3 '
  ||'    and u.user_id = :4 '
  ||'    and u.user_name = ur.user_name '
  ||'    and ur.role_orig_system_id = rcd.responsibility_id '
  ||'    and ur.role_orig_system = ''FND_RESP'' '
  ||'  UNION ALL '
  ||'  select rcd.function_id '
  ||'  from amw_role_constraint_denorm rcd '
  ||'      ,'||G_AMW_GRANTS||' gra '
  ||'      ,'||G_AMW_USER||' u '
  ||'  where rcd.constraint_rev_id = :5 '
  ||'    and u.user_id = :6 '
  ||'    and u.user_name = gra.grantee_key '
  ||'    and gra.grantee_type = ''USER'' '
  ||'    and gra.menu_id = rcd.menu_id '
  ||'    and gra.instance_type = ''GLOBAL'' '
  ||'    and gra.object_id = -1 '
  ||'  UNION ALL '
  ||'  select rcd.function_id '
  ||'  from amw_role_constraint_denorm rcd '
  ||'      ,'||G_AMW_GRANTS||' gra '
  ||'  where rcd.constraint_rev_id = :7 '
  ||'    and gra.grantee_key = ''GLOBAL'' '
  ||'    and gra.grantee_type = ''GLOBAL'' '
  ||'    and gra.menu_id = rcd.menu_id '
  ||'    and gra.instance_type = ''GLOBAL'' '
  ||'    and gra.object_id = -1 '
  ||'  UNION ALL '
  ||'  select rcd.function_id '
  ||'  from amw_role_constraint_denorm rcd '
  ||'  where rcd.constraint_rev_id = :8 '
  ||'    and rcd.responsibility_id = :9 '
  ||') ';

l_func_set_dynamic_sql   VARCHAR2(2500)  :=
    'select count(distinct group_code) from ( '
  ||'  select rcd.group_code '
  ||'  from amw_role_constraint_denorm rcd '
  ||'      ,'||G_AMW_USER_ROLES||' ur '
  ||'      ,'||G_AMW_user||' u '
  ||'  where rcd.constraint_rev_id = :1 '
  ||'    and u.user_id = :2 '
  ||'    and u.user_name = ur.user_name '
  ||'    and ur.role_name = rcd.role_name '
  ||'    and ur.role_orig_system = ''UMX'' '
  ||'  UNION ALL '
  ||'  select rcd.group_code '
  ||'  from amw_role_constraint_denorm rcd '
  ||'      ,'||G_AMW_USER_ROLES||' ur '
  ||'      ,'||G_AMW_user||' u '
  ||'  where rcd.constraint_rev_id = :3 '
  ||'    and u.user_id = :4 '
  ||'    and u.user_name = ur.user_name '
  ||'    and ur.role_orig_system_id = rcd.responsibility_id '
  ||'    and ur.role_orig_system = ''FND_RESP'' '
  ||'  UNION ALL '
  ||'  select rcd.group_code '
  ||'  from amw_role_constraint_denorm rcd '
  ||'      ,'||G_AMW_GRANTS||' gra '
  ||'      ,'||G_AMW_USER||' u '
  ||'  where rcd.constraint_rev_id = :5 '
  ||'    and u.user_id = :6 '
  ||'    and u.user_name = gra.grantee_key '
  ||'    and gra.grantee_type = ''USER'' '
  ||'    and gra.menu_id = rcd.menu_id '
  ||'    and gra.instance_type = ''GLOBAL'' '
  ||'    and gra.object_id = -1 '
  ||'  UNION ALL '
  ||'  select rcd.group_code '
  ||'  from amw_role_constraint_denorm rcd '
  ||'      ,'||G_AMW_GRANTS||' gra '
  ||'  where rcd.constraint_rev_id = :7 '
  ||'    and gra.grantee_key = ''GLOBAL'' '
  ||'    and gra.grantee_type = ''GLOBAL'' '
  ||'    and gra.menu_id = rcd.menu_id '
  ||'    and gra.instance_type = ''GLOBAL'' '
  ||'    and gra.object_id = -1 '
  ||'  UNION ALL '
  ||'  select rcd.group_code '
  ||'  from amw_role_constraint_denorm rcd '
  ||'  where rcd.constraint_rev_id = :8 '
  ||'    and rcd.responsibility_id = :9 '
  ||') ';

-- get the name of the new respsonsibility which this user intends to have
new_resp_c refCurTyp;
l_new_resp_dynamic_sql   VARCHAR2(500)  :=
    'select resp.responsibility_name '
  ||'  from amw_constraint_entries rcd '
  ||'      ,'||G_AMW_RESPONSIBILITY_VL||' resp '
  ||'  where rcd.constraint_rev_id = :1 and resp.responsibility_id = :2 '
  ||'    and rcd.function_id = resp.responsibility_id ';

new_func_c refCurTyp;
l_new_func_dynamic_sql VARCHAR2(500) :=
    'select func.user_function_name '
  ||'  from amw_constraint_entries rcd '
  ||'      ,'|| G_AMW_FORM_FUNCTIONS_VL ||' func '
  ||'  where rcd.constraint_rev_id = :1  '
  ||'    and rcd.function_id = func.function_id ';

-- get valid user waiver
l_valid_user_waiver_count NUMBER;
CURSOR c_valid_user_waivers (l_constraint_rev_id IN NUMBER, l_user_id IN NUMBER) IS
    SELECT count(*)
      FROM amw_constraint_waivers_vl
     WHERE constraint_rev_id = l_constraint_rev_id
       AND object_type = 'USER'
       AND PK1 = l_user_id
       AND start_date <= sysdate AND (end_date >= sysdate or end_date is null);

 l_resp_sql VARCHAR2(32767);


-- all of roles including the existing ones and the newly assigned ones
l_resp_all_sql   VARCHAR2(32767)  :=
  '  select ur.role_orig_system_id '
  ||'  from '
  || G_AMW_USER_ROLES||' ur '
  ||'      ,'||G_AMW_user||' u '
  ||'      ,amw_constraint_entries cst '
  ||'  where  u.user_id = :1 '
  ||'    and  cst.constraint_rev_id = :2 '
  ||'    and u.user_name = ur.user_name '
  ||'    and ur.role_orig_system_id = cst.function_id '
  ||'    and ur.role_orig_system = ''FND_RESP'' '
  ||'  UNION '
  ||'  select cst.function_id as orig_system_id '
  ||'  from  amw_constraint_entries cst '
  ||'  where  cst.constraint_rev_id = :3 '
  ||'  and cst.function_id = :4 ';


l_resp_dynamic_sql  VARCHAR2(32767) :=
' select count(role_orig_system_id) from ( '
|| l_resp_all_sql
||')';


l_resp_set_all_sql   VARCHAR2(32767)  :=
  '  select cst.group_code '
  ||'  from '
  || G_AMW_USER_ROLES||' ur '
  ||'      ,'||G_AMW_user||' u '
  ||'      ,amw_constraint_entries cst '
  ||'  where  u.user_id = :1 '
  ||'    and  cst.constraint_rev_id = :2 '
  ||'    and u.user_name = ur.user_name '
  ||'    and ur.role_orig_system_id = cst.function_id '
  ||'    and ur.role_orig_system = ''FND_RESP'' '
  ||'  UNION '
  ||'  select cst.group_code '
  ||'  from   amw_constraint_entries cst '
  ||'  where  cst.constraint_rev_id = :3 '
  ||'  and cst.function_id = :4 ';

  l_resp_set_dynamic_sql   VARCHAR2(32767) :=
  ' select count(group_code) from ( '
|| l_resp_set_all_sql
||')';


BEGIN
    IF( l_log_stmt_level >= l_curr_log_level ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','User_Resp_Violation_Details Start');
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','p_user_id             = '|| p_user_id );
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','p_responsibility_id   = '|| p_responsibility_id);
	END IF;

  -- default to 'N', which means user doesn't have violations
  has_violation := 'N';
  l_violat_existing_resp := NULL;
  l_violat_existing_role := NULL;
  l_violat_existing_menu := NULL;
  l_violat_new_resp := NULL;
  l_violat_new_func := NULL;
  l_valid_user_waiver_count := 0;

  IF (p_user_id IS NOT NULL AND p_responsibility_id IS NOT NULL) THEN
    -- check all valid constraints
    OPEN c_all_valid_constraints;
    LOOP
     FETCH c_all_valid_constraints INTO l_all_valid_constraints;
     EXIT WHEN c_all_valid_constraints%NOTFOUND;

     -- check if this user is waived (due to User Waiver) from this constraint
     OPEN c_valid_user_waivers(l_all_valid_constraints.constraint_rev_id, p_user_id);
     FETCH c_valid_user_waivers INTO l_valid_user_waiver_count;
     CLOSE c_valid_user_waivers;


     -- IF l_valid_user_waiver_count <= 0 THEN
     IF l_valid_user_waiver_count <= 0  THEN

      -- get the name of the new responsibility if combining this will results in violation against this constraint
      OPEN new_resp_c FOR l_new_resp_dynamic_sql USING
         l_all_valid_constraints.constraint_rev_id
        ,p_responsibility_id;
      FETCH new_resp_c INTO l_violat_new_resp;
      CLOSE new_resp_c;

         -- get the name of the new function if combining this will results in violation against this constraint
      OPEN new_func_c FOR l_new_func_dynamic_sql USING
         l_all_valid_constraints.constraint_rev_id;
      FETCH new_func_c BULK COLLECT INTO l_new_func_table;
      CLOSE new_func_c;

    IF l_new_func_table IS NOT NULL AND l_new_func_table.FIRST IS NOT NULL THEN
      l_violat_new_func := l_new_func_table(1);
      FOR i in 2 .. l_new_func_table.COUNT
      LOOP
        l_violat_new_func := l_violat_new_func ||', '||l_new_func_table(i);
      END LOOP;
    END IF; -- end of if: l_new_func_table IS NOT NULL

      IF 'ALL' = l_all_valid_constraints.type_code THEN
        -- find the number of constraint entries(incompatible functions) by specified constraint_rev_id
        OPEN c_constraint_entries_count (l_all_valid_constraints.constraint_rev_id);
        FETCH c_constraint_entries_count INTO l_constraint_entries_count;
        CLOSE c_constraint_entries_count;

        -- find the number of distinct constraint entries this user can access
        OPEN func_acess_count_c FOR l_func_dynamic_sql USING
          l_all_valid_constraints.constraint_rev_id,
          p_user_id,
          l_all_valid_constraints.constraint_rev_id,
          p_user_id,
          l_all_valid_constraints.constraint_rev_id,
          p_user_id,
          l_all_valid_constraints.constraint_rev_id,
          l_all_valid_constraints.constraint_rev_id,
          p_responsibility_id;
        FETCH func_acess_count_c INTO l_func_access_count;
        CLOSE func_acess_count_c;

        -- in ALL type: if user can access to all entries of this constraint,
        -- he violates this constraint
        IF l_func_access_count = l_constraint_entries_count THEN
          -- once he violates at least one constraint, break the loop and inform FALSE to the caller
          FND_FILE.put_line(fnd_file.log, '------------ fail on constraint - ALL = '||l_all_valid_constraints.constraint_rev_id ||' ---------------');
          l_violat_existing_resp := Get_Violat_Existing_Resp_List (
                p_user_id                   => p_user_id,
                p_constraint_rev_id         => l_all_valid_constraints.constraint_rev_id,
                p_constraint_type_code      => l_all_valid_constraints.type_code);
          l_violat_existing_role := Get_Violat_Existing_Role_List (
                p_user_id                   => p_user_id,
                p_constraint_rev_id         => l_all_valid_constraints.constraint_rev_id,
                p_constraint_type_code      => l_all_valid_constraints.type_code);
          l_violat_existing_menu := Get_Violat_Existing_Menu_List (
                p_user_id                   => p_user_id,
                p_constraint_rev_id         => l_all_valid_constraints.constraint_rev_id,
                p_constraint_type_code      => l_all_valid_constraints.type_code);

          -- concatinate return result(Violation Details)
          has_violation := substrb(l_violat_new_func, 1, 4000);
          IF l_violat_existing_resp IS NOT NULL THEN
            IF has_violation IS NOT NULL THEN
              has_violation := substrb((has_violation||', '), 1, 4000);
            END IF;
            has_violation := substrb((has_violation||l_violat_existing_resp), 1, 4000);
          END IF;
          IF l_violat_existing_role IS NOT NULL THEN
            IF has_violation IS NOT NULL THEN
              has_violation := substrb((has_violation||', '), 1, 4000);
            END IF;
            has_violation := substrb((has_violation||l_violat_existing_role), 1, 4000);
          END IF;
          IF l_violat_existing_menu IS NOT NULL THEN
            IF has_violation IS NOT NULL THEN
              has_violation := substrb((has_violation||', '), 1, 4000);
            END IF;
            has_violation := substrb((has_violation||l_violat_existing_menu), 1, 4000);
          END IF;

	      fnd_message.set_name('AMW', 'AMW_SOD_VIOLATION');
	      fnd_message.set_token('CONSTRAINT', l_all_valid_constraints.constraint_name);
	      fnd_message.set_token('CONST_DETAILS', has_violation);
          return substrb((FND_MESSAGE.GET), 1, 2000);
        END IF;

      ELSIF 'ME' = l_all_valid_constraints.type_code THEN
        -- find the number of distinct constraint entries this user can access
        OPEN func_acess_count_c FOR l_func_dynamic_sql USING
          l_all_valid_constraints.constraint_rev_id,
          p_user_id,
          l_all_valid_constraints.constraint_rev_id,
          p_user_id,
          l_all_valid_constraints.constraint_rev_id,
          p_user_id,
          l_all_valid_constraints.constraint_rev_id,
          l_all_valid_constraints.constraint_rev_id,
          p_responsibility_id;
        FETCH func_acess_count_c INTO l_func_access_count;
        CLOSE func_acess_count_c;

        -- in ME type: if user can access at least two entries of this constraint,
        -- he violates this constraint
        IF l_func_access_count >= 2 THEN
          -- once he violates at least one constraint, break the loop and inform FALSE to the caller
          FND_FILE.put_line(fnd_file.log,'------------ fail on constraint - ME = '||l_all_valid_constraints.constraint_rev_id ||' ---------------');
          l_violat_existing_resp := Get_Violat_Existing_Resp_List (
                p_user_id                   => p_user_id,
                p_constraint_rev_id         => l_all_valid_constraints.constraint_rev_id,
                p_constraint_type_code      => l_all_valid_constraints.type_code);
          l_violat_existing_role := Get_Violat_Existing_Role_List (
                p_user_id                   => p_user_id,
                p_constraint_rev_id         => l_all_valid_constraints.constraint_rev_id,
                p_constraint_type_code      => l_all_valid_constraints.type_code);
          l_violat_existing_menu := Get_Violat_Existing_Menu_List (
                p_user_id                   => p_user_id,
                p_constraint_rev_id         => l_all_valid_constraints.constraint_rev_id,
                p_constraint_type_code      => l_all_valid_constraints.type_code);

          -- concatinate return result(Violation Details)
          has_violation := substrb(l_violat_new_func, 1, 4000);
          IF l_violat_existing_resp IS NOT NULL THEN
            IF has_violation IS NOT NULL THEN
              has_violation := substrb((has_violation||', '), 1, 4000);
            END IF;
            has_violation := substrb((has_violation||l_violat_existing_resp), 1, 4000);
          END IF;
          IF l_violat_existing_role IS NOT NULL THEN
            IF has_violation IS NOT NULL THEN
              has_violation := substrb((has_violation||', '), 1, 4000);
            END IF;
            has_violation := substrb((has_violation||l_violat_existing_role), 1, 4000);
          END IF;
          IF l_violat_existing_menu IS NOT NULL THEN
            IF has_violation IS NOT NULL THEN
              has_violation := has_violation||', ';
            END IF;
            has_violation := substrb((has_violation||l_violat_existing_menu), 1, 4000);
          END IF;

		  fnd_message.set_name('AMW', 'AMW_SOD_VIOLATION');
	      fnd_message.set_token('CONSTRAINT', l_all_valid_constraints.constraint_name);
	      fnd_message.set_token('CONST_DETAILS', has_violation);
          return substrb((FND_MESSAGE.GET), 1, 2000);
        END IF;

      ELSIF 'SET' = l_all_valid_constraints.type_code THEN
        -- find the number of distinct constraint entries this user can access
        OPEN group_acess_count_c FOR l_func_set_dynamic_sql USING
          l_all_valid_constraints.constraint_rev_id,
          p_user_id,
          l_all_valid_constraints.constraint_rev_id,
          p_user_id,
          l_all_valid_constraints.constraint_rev_id,
          p_user_id,
          l_all_valid_constraints.constraint_rev_id,
          l_all_valid_constraints.constraint_rev_id,
          p_responsibility_id;
        FETCH group_acess_count_c INTO l_group_access_count;
        CLOSE group_acess_count_c;

        -- in SET type: if user can access at least two distinct groups(set) of this constraint,
        -- he violates this constraint
        IF l_group_access_count >= 2 THEN
          -- once he violates at least one constraint, break the loop and inform FALSE to the caller
          FND_FILE.put_line(fnd_file.log,'------------ fail on constraint - SET = '||l_all_valid_constraints.constraint_rev_id ||' ---------------');
          l_violat_existing_resp := Get_Violat_Existing_Resp_List (
                p_user_id                   => p_user_id,
                p_constraint_rev_id         => l_all_valid_constraints.constraint_rev_id,
                p_constraint_type_code      => l_all_valid_constraints.type_code);
          l_violat_existing_role := Get_Violat_Existing_Role_List (
                p_user_id                   => p_user_id,
                p_constraint_rev_id         => l_all_valid_constraints.constraint_rev_id,
                p_constraint_type_code      => l_all_valid_constraints.type_code);
          l_violat_existing_menu := Get_Violat_Existing_Menu_List (
                p_user_id                   => p_user_id,
                p_constraint_rev_id         => l_all_valid_constraints.constraint_rev_id,
                p_constraint_type_code      => l_all_valid_constraints.type_code);

          -- concatinate return result(Violation Details)
           has_violation := substrb(l_violat_new_func, 1, 4000);
          IF l_violat_existing_resp IS NOT NULL THEN
            IF has_violation IS NOT NULL THEN
              has_violation := has_violation||', ';
            END IF;
            has_violation := substrb((has_violation||l_violat_existing_resp), 1, 4000);
          END IF;
          IF l_violat_existing_role IS NOT NULL THEN
            IF has_violation IS NOT NULL THEN
              has_violation := has_violation||', ';
            END IF;
            has_violation := substrb((has_violation||l_violat_existing_role), 1, 4000);
          END IF;
          IF l_violat_existing_menu IS NOT NULL THEN
            IF has_violation IS NOT NULL THEN
              has_violation := has_violation||', ';
            END IF;
            has_violation := substrb((has_violation||l_violat_existing_menu), 1, 4000);
          END IF;

		  fnd_message.set_name('AMW', 'AMW_SOD_VIOLATION');
	      fnd_message.set_token('CONSTRAINT', l_all_valid_constraints.constraint_name);
	      fnd_message.set_token('CONST_DETAILS', has_violation);
          return substrb((FND_MESSAGE.GET), 1, 2000);
        END IF;

       ELSIF 'RESPALL' = l_all_valid_constraints.type_code THEN
         -- find the number of constraint entries(incompatible functions) by specified constraint_rev_id
        OPEN c_constraint_entries_count (l_all_valid_constraints.constraint_rev_id);
        FETCH c_constraint_entries_count INTO l_constraint_entries_count;
        CLOSE c_constraint_entries_count;



            OPEN resp_acess_count_c FOR l_resp_dynamic_sql USING
            p_user_id,
            l_all_valid_constraints.constraint_rev_id,
            l_all_valid_constraints.constraint_rev_id,
             p_responsibility_id;
            FETCH resp_acess_count_c INTO l_resp_access_count;
            CLOSE resp_acess_count_c;

            -- in ALL type: if user can access to all entries of this constraint,
            -- he violates this constraint
       IF l_resp_access_count = l_constraint_entries_count THEN

            -- Check to see if the fuction enteries in the constraint is same
            -- as the functions the user can access due to the assigning of
            -- this role

            l_resp_sql := 'select count(distinct role_orig_system_id)'
             ||' from ('
             ||  l_resp_all_sql
             ||' MINUS '
             ||' select FUNCTION_ID from amw_constraint_entries where constraint_rev_id = :5'
             ||')';


                OPEN resp_acess_count_c FOR l_resp_sql USING
                p_user_id,
                l_all_valid_constraints.constraint_rev_id,
                l_all_valid_constraints.constraint_rev_id,
                p_responsibility_id,
                l_all_valid_constraints.constraint_rev_id;
                FETCH resp_acess_count_c INTO l_resp_access_count;
                CLOSE resp_acess_count_c;

       IF l_resp_access_count = 0 THEN
       -- once he violates at least one constraint, break the loop and inform FALSE to the caller
          FND_FILE.put_line(fnd_file.log, '------------ fail on constraint - ALL = '||l_all_valid_constraints.constraint_rev_id ||' ---------------');
          l_violat_existing_resp := Get_Violat_Existing_Resp_List (
                p_user_id                   => p_user_id,
                p_constraint_rev_id         => l_all_valid_constraints.constraint_rev_id,
                p_constraint_type_code      => l_all_valid_constraints.type_code);
          l_violat_existing_role := Get_Violat_Existing_Role_List (
                p_user_id                   => p_user_id,
                p_constraint_rev_id         => l_all_valid_constraints.constraint_rev_id,
                p_constraint_type_code      => l_all_valid_constraints.type_code);
          l_violat_existing_menu := Get_Violat_Existing_Menu_List (
                p_user_id                   => p_user_id,
                p_constraint_rev_id         => l_all_valid_constraints.constraint_rev_id,
                p_constraint_type_code      => l_all_valid_constraints.type_code);

          -- concatinate return result(Violation Details)
          has_violation := l_violat_new_resp;
          IF l_violat_existing_resp IS NOT NULL THEN
            IF has_violation IS NOT NULL THEN
              has_violation := has_violation||', ';
            END IF;
            has_violation := substrb((has_violation||l_violat_existing_resp), 1, 4000);
          END IF;
          IF l_violat_existing_role IS NOT NULL THEN
            IF has_violation IS NOT NULL THEN
              has_violation := has_violation||', ';
            END IF;
            has_violation := substrb((has_violation||l_violat_existing_role), 1, 4000);
          END IF;
          IF l_violat_existing_menu IS NOT NULL THEN
            IF has_violation IS NOT NULL THEN
              has_violation := has_violation||', ';
            END IF;
            has_violation := substrb((has_violation||l_violat_existing_menu), 1, 4000);
          END IF;

		  fnd_message.set_name('AMW', 'AMW_SOD_VIOLATION');
	      fnd_message.set_token('CONSTRAINT', l_all_valid_constraints.constraint_name);
	      fnd_message.set_token('CONST_DETAILS', has_violation);
          return substrb((FND_MESSAGE.GET), 1, 2000);
        END IF; -- end of l_resp_access_count = 0
            END IF;  -- l_resp_access_count = l_constraint_entries_count

        ELSIF 'RESPME' = l_all_valid_constraints.type_code THEN


                -- find the number of distinct constraint entries this user can access
                OPEN resp_acess_count_c FOR l_resp_dynamic_sql USING
                p_user_id,
                l_all_valid_constraints.constraint_rev_id,
                l_all_valid_constraints.constraint_rev_id,
                p_responsibility_id;
                FETCH resp_acess_count_c INTO l_resp_access_count;
                CLOSE resp_acess_count_c;

                IF( l_log_stmt_level >= l_curr_log_level ) THEN
    	           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','l_resp_access_count = '|| l_resp_access_count );
                END IF;


                -- in ME type: if user can access at least two entries of this constraint,
                -- he violates this constraint
          IF l_resp_access_count >= 2 THEN
                 -- once he violates at least one constraint, break the loop and inform FALSE to the caller
          FND_FILE.put_line(fnd_file.log, '------------ fail on constraint - ALL = '||l_all_valid_constraints.constraint_rev_id ||' ---------------');
          l_violat_existing_resp := Get_Violat_Existing_Resp_List (
                p_user_id                   => p_user_id,
                p_constraint_rev_id         => l_all_valid_constraints.constraint_rev_id,
                p_constraint_type_code      => l_all_valid_constraints.type_code);
          l_violat_existing_role := Get_Violat_Existing_Role_List (
                p_user_id                   => p_user_id,
                p_constraint_rev_id         => l_all_valid_constraints.constraint_rev_id,
                p_constraint_type_code      => l_all_valid_constraints.type_code);
          l_violat_existing_menu := Get_Violat_Existing_Menu_List (
                p_user_id                   => p_user_id,
                p_constraint_rev_id         => l_all_valid_constraints.constraint_rev_id,
                p_constraint_type_code      => l_all_valid_constraints.type_code);

            IF( l_log_stmt_level >= l_curr_log_level ) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','l_violat_new_resp = '|| l_violat_new_resp );
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','l_violat_existing_resp = '|| l_violat_existing_resp );
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','l_violat_existing_role = '|| l_violat_existing_role );
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','l_violat_existing_menu = '|| l_violat_existing_menu );
            END IF;

          -- concatinate return result(Violation Details)
          has_violation := l_violat_new_resp;
          IF l_violat_existing_resp IS NOT NULL THEN
            IF has_violation IS NOT NULL THEN
              has_violation := has_violation||', ';
            END IF;
            has_violation := substrb((has_violation||l_violat_existing_resp), 1, 4000);
          END IF;
          IF l_violat_existing_role IS NOT NULL THEN
            IF has_violation IS NOT NULL THEN
              has_violation := has_violation||', ';
            END IF;
            has_violation := substrb((has_violation||l_violat_existing_role), 1, 4000);
          END IF;
          IF l_violat_existing_menu IS NOT NULL THEN
            IF has_violation IS NOT NULL THEN
              has_violation := has_violation||', ';
            END IF;
            has_violation := substrb((has_violation||l_violat_existing_menu), 1, 4000);
          END IF;

		 fnd_message.set_name('AMW', 'AMW_SOD_VIOLATION');
	      fnd_message.set_token('CONSTRAINT', l_all_valid_constraints.constraint_name);
	      fnd_message.set_token('CONST_DETAILS', has_violation);


        IF( l_log_stmt_level >= l_curr_log_level ) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','User_Resp_Violation_Details End');
        END IF;

          return substrb((FND_MESSAGE.GET), 1, 2000);
        END IF; -- end of l_resp_access_count >= 2


      ELSIF 'RESPSET' = l_all_valid_constraints.type_code THEN


              -- find the number of distinct constraint entries this user can access

                OPEN resp_acess_count_c FOR l_resp_set_dynamic_sql USING
                p_user_id,
                l_all_valid_constraints.constraint_rev_id,
                l_all_valid_constraints.constraint_rev_id,
                p_responsibility_id;
                FETCH resp_acess_count_c INTO l_resp_access_count;
                CLOSE resp_acess_count_c;

                -- in SET type: if user can access at least two distinct groups(set) of this constraint,
                -- he violates this constraint
          IF l_resp_access_count >= 2 THEN
                  -- once he violates at least one constraint, break the loop and inform FALSE to the caller
          FND_FILE.put_line(fnd_file.log, '------------ fail on constraint - ALL = '||l_all_valid_constraints.constraint_rev_id ||' ---------------');
          l_violat_existing_resp := Get_Violat_Existing_Resp_List (
                p_user_id                   => p_user_id,
                p_constraint_rev_id         => l_all_valid_constraints.constraint_rev_id,
                p_constraint_type_code      => l_all_valid_constraints.type_code);
          l_violat_existing_role := Get_Violat_Existing_Role_List (
                p_user_id                   => p_user_id,
                p_constraint_rev_id         => l_all_valid_constraints.constraint_rev_id,
                p_constraint_type_code      => l_all_valid_constraints.type_code);
          l_violat_existing_menu := Get_Violat_Existing_Menu_List (
                p_user_id                   => p_user_id,
                p_constraint_rev_id         => l_all_valid_constraints.constraint_rev_id,
                p_constraint_type_code      => l_all_valid_constraints.type_code);

          -- concatinate return result(Violation Details)
          has_violation := l_violat_new_resp;
          IF l_violat_existing_resp IS NOT NULL THEN
            IF has_violation IS NOT NULL THEN
              has_violation := has_violation||', ';
            END IF;
            has_violation := substrb((has_violation||l_violat_existing_resp), 1, 4000);
          END IF;
          IF l_violat_existing_role IS NOT NULL THEN
            IF has_violation IS NOT NULL THEN
              has_violation := has_violation||', ';
            END IF;
            has_violation := substrb((has_violation||l_violat_existing_role), 1, 4000);
          END IF;
          IF l_violat_existing_menu IS NOT NULL THEN
            IF has_violation IS NOT NULL THEN
              has_violation := has_violation||', ';
            END IF;
            has_violation := substrb((has_violation||l_violat_existing_menu), 1, 4000);
          END IF;

		 fnd_message.set_name('AMW', 'AMW_SOD_VIOLATION');
	      fnd_message.set_token('CONSTRAINT', l_all_valid_constraints.constraint_name);
	      fnd_message.set_token('CONST_DETAILS', has_violation);
          return substrb((FND_MESSAGE.GET), 1, 2000);
                END IF; -- end of l_resp_access_count >= 2
      ELSE
        -- other constraint types
        NULL;
      END IF; -- end of if: constraint type_code

     END IF; --end of if: l_valid_user_waiver_count > 0

    END LOOP; --end of loop: c_all_valid_constraints
    CLOSE c_all_valid_constraints;

  END IF; -- end of if: p_user_id IS NOT NULL AND p_responsibility_id IS NOT NULL

    IF( l_log_stmt_level >= l_curr_log_level ) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','Last has_violation '|| has_violation);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','User_Resp_Violation_Details End');
    END IF;

  return has_violation;

EXCEPTION
    WHEN OTHERS THEN
    IF( l_log_stmt_level >= l_curr_log_level ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','Error '||TO_CHAR(SQLCODE)||': '||SQLERRM);
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','User_Resp_Violation_Details End');
	END IF;
	RAISE;

END User_Resp_Violation_Details;




-- ===============================================================
-- Function name
--          Get_Violat_Existing_Role_List
--
-- Purpose
--          get a flat string list of this user's existing role display name, together with those new assigned role(among p_role_names_string)
--          may violate the specified constraint
--
-- Params
--          p_user_id            := input fnd user_id
--          p_constraint_rev_id  := input constraint_rev_id
--          p_constraint_type_code  := input constraint type for p_constraint_rev_id
--
-- Return
--          a string list of role display names which violates the specified constraint,
--          each display name is seperated by ','
--
-- History
-- 		  	07/27/2005    tsho     Create
-- ===============================================================
Function Get_Violat_Existing_Role_List (
    p_user_id                   IN  NUMBER,
    p_constraint_rev_id         IN  NUMBER,
    p_constraint_type_code      IN  VARCHAR2
) RETURN VARCHAR2
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Get_Violat_Existing_Role_List';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

-- store the return value
l_existing_role_string VARCHAR2(32767);

-- store the existing role this user has against this constraint
l_existing_role_table JTF_VARCHAR2_TABLE_400;

TYPE refCurTyp IS REF CURSOR;
existing_role_c refCurTyp;

-- find existing roles this user has (results in violating the specified constraint)
l_existing_role_dynamic_sql   VARCHAR2(500)  :=
    'select distinct rv.display_name '
  ||'  from amw_role_constraint_denorm rcd '
  ||'      ,'||G_AMW_USER_ROLES||' ur '
  ||'      ,'||G_AMW_user||' u '
  ||'      ,'||G_AMW_ALL_ROLES_VL||' rv '
  ||'  where rcd.constraint_rev_id = :1 '
  ||'    and u.user_id = :2 '
  ||'    and u.user_name = ur.user_name '
  ||'    and ur.role_name = rcd.role_name '
  ||'    and ur.role_orig_system = ''UMX'' '
  ||'    and ur.role_name = rv.name ';

BEGIN
    IF( l_log_stmt_level >= l_curr_log_level ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','Get_Violat_Existing_Role_List Start');
	END IF;

  l_existing_role_string := NULL;

  IF (p_user_id IS NOT NULL AND p_constraint_rev_id IS NOT NULL AND p_constraint_type_code IS NOT NULL) THEN
    OPEN existing_role_c FOR l_existing_role_dynamic_sql USING
          p_constraint_rev_id,
          p_user_id;
    FETCH existing_role_c BULK COLLECT INTO l_existing_role_table;
    CLOSE existing_role_c;

    IF l_existing_role_table IS NOT NULL AND l_existing_role_table.FIRST IS NOT NULL THEN
      l_existing_role_string := l_existing_role_table(1);
      FOR i in 2 .. l_existing_role_table.COUNT
      LOOP
        l_existing_role_string := l_existing_role_string||', '||l_existing_role_table(i);
      END LOOP;
    END IF; -- end of if: l_existing_role_table IS NOT NULL

  END IF; --end of if: p_user_id IS NOT NULL AND p_constraint_rev_id IS NOT NULL AND p_constraint_type_code IS NOT NULL

    IF( l_log_stmt_level >= l_curr_log_level ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','Get_Violat_Existing_Role_List End');
	END IF;

  return l_existing_role_string;

EXCEPTION
    WHEN OTHERS THEN
    IF( l_log_stmt_level >= l_curr_log_level ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','Error '||TO_CHAR(SQLCODE)||': '||SQLERRM);
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','Get_Violat_Existing_Role_List End');
	END IF;
	RAISE;
END Get_Violat_Existing_Role_List;




-- ===============================================================
-- Function name
--          Get_Violat_Existing_Resp_List
--
-- Purpose
--          get a flat string list of this user's existing responsibility display name, together with those new assigned role(among p_role_names_string)
--          may violate the specified constraint
--
-- Params
--          p_user_id            := input fnd user_id
--          p_constraint_rev_id  := input constraint_rev_id
--          p_constraint_type_code  := input constraint type for p_constraint_rev_id
--
-- Return
--          a string list of role display names which violates the specified constraint,
--          each display name is seperated by ','
--
-- History
-- 		  	07/27/2005    tsho     Create
-- ===============================================================
Function Get_Violat_Existing_Resp_List (
    p_user_id                   IN  NUMBER,
    p_constraint_rev_id         IN  NUMBER,
    p_constraint_type_code      IN  VARCHAR2
) RETURN VARCHAR2
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Get_Violat_Existing_Resp_List';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

-- store the return value
l_existing_resp_string VARCHAR2(32767);

-- store the existing responsibilities this user has against this constraint
l_existing_resp_table JTF_VARCHAR2_TABLE_400;

TYPE refCurTyp IS REF CURSOR;
existing_resp_c refCurTyp;


-- find existing responsibilities this user has (results in violating the specified constraint)
l_existing_resp_dynamic_sql   VARCHAR2(2000)  :=
    'select distinct resp.responsibility_name '
  ||'  from amw_role_constraint_denorm rcd '
  ||'      ,'||G_AMW_USER_ROLES||' ur '
  ||'      ,'||G_AMW_user||' u '
  ||'      ,'||G_AMW_RESPONSIBILITY_VL||' resp '
  ||'  where rcd.constraint_rev_id = :1 '
  ||'    and u.user_id = :2 '
  ||'    and u.user_name = ur.user_name '
  ||'    and ur.role_orig_system_id = rcd.responsibility_id '
  ||'    and ur.role_orig_system = ''FND_RESP'' '
  ||'    and ur.role_orig_system_id = resp.responsibility_id  '
  ||' UNION ALL  '
  ||' select distinct resp.responsibility_name '
  ||' from amw_constraint_entries cste '
  ||'      ,'||G_AMW_USER_ROLES||' ur '
  ||'      ,'||G_AMW_user||' u '
  ||'      ,'||G_AMW_RESPONSIBILITY_VL||' resp '
  ||'  where cste.constraint_rev_id = :3 '
  ||'    and u.user_id = :4 '
  ||'    and u.user_name = ur.user_name '
  ||'    and ur.role_orig_system_id = cste.function_id '
  ||'    and ur.role_orig_system = ''FND_RESP'' '
  ||'    and ur.role_orig_system_id = resp.responsibility_id ';

BEGIN

    IF( l_log_stmt_level >= l_curr_log_level ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','Get_Violat_Existing_Resp_List Start');
	END IF;

  l_existing_resp_string := NULL;

  IF (p_user_id IS NOT NULL AND p_constraint_rev_id IS NOT NULL AND p_constraint_type_code IS NOT NULL) THEN
    OPEN existing_resp_c FOR l_existing_resp_dynamic_sql USING
          p_constraint_rev_id,
          p_user_id,
          p_constraint_rev_id,
          p_user_id;
    FETCH existing_resp_c BULK COLLECT INTO l_existing_resp_table;
    CLOSE existing_resp_c;

    IF l_existing_resp_table IS NOT NULL AND l_existing_resp_table.FIRST IS NOT NULL THEN
      l_existing_resp_string := l_existing_resp_table(1);
      FOR i in 2 .. l_existing_resp_table.COUNT
      LOOP
        l_existing_resp_string := l_existing_resp_string||', '||l_existing_resp_table(i);
      END LOOP;
    END IF; -- end of if: l_existing_resp_table IS NOT NULL

  END IF; --end of if: p_user_id IS NOT NULL AND p_constraint_rev_id IS NOT NULL AND p_constraint_type_code IS NOT NULL

    IF( l_log_stmt_level >= l_curr_log_level ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','Get_Violat_Existing_Resp_List End');
	END IF;

  return l_existing_resp_string;
EXCEPTION
    WHEN OTHERS THEN
    IF( l_log_stmt_level >= l_curr_log_level ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','Error '||TO_CHAR(SQLCODE)||': '||SQLERRM);
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','Get_Violat_Existing_Resp_List End');
	END IF;
	RAISE;

END Get_Violat_Existing_Resp_List;




-- ===============================================================
-- Function name
--          Get_Violat_Existing_Menu_List
--
-- Purpose
--          get a flat string list of this user's existing permission set(menu) display name, ]
--          together with those new assigned role(among p_role_names_string)
--          may violate the specified constraint
--
-- Params
--          p_user_id            := input fnd user_id
--          p_constraint_rev_id  := input constraint_rev_id
--          p_constraint_type_code  := input constraint type for p_constraint_rev_id
--
-- Return
--          a string list of role display names which violates the specified constraint,
--          each display name is seperated by ','
--
-- History
-- 		  	07/27/2005    tsho     Create
-- ===============================================================
Function Get_Violat_Existing_Menu_List (
    p_user_id                   IN  NUMBER,
    p_constraint_rev_id         IN  NUMBER,
    p_constraint_type_code      IN  VARCHAR2
) RETURN VARCHAR2
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Get_Violat_Existing_Menu_List';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

-- store the return value
l_existing_menu_string VARCHAR2(32767);

-- store the existing menus this user has against this constraint
l_existing_menu_table JTF_VARCHAR2_TABLE_400;

TYPE refCurTyp IS REF CURSOR;
existing_menu_c refCurTyp;

-- find existing menus this user has (results in violating the specified constraint)
l_existing_menu_dynamic_sql   VARCHAR2(1500)  :=
    '  select menu.user_menu_name '
  ||'  from amw_role_constraint_denorm rcd '
  ||'      ,'||G_AMW_MENUS_VL||' menu '
  ||'      ,'||G_AMW_user||' u '
  ||'      ,'||G_AMW_GRANTS||' gra '
  ||'  where rcd.constraint_rev_id = :1 '
  ||'    and u.user_id = :2 '
  ||'    and u.user_name = gra.grantee_key '
  ||'    and gra.grantee_type = ''USER'' '
  ||'    and gra.instance_type = ''GLOBAL'' '
  ||'    and gra.object_id = -1 '
  ||'    and gra.menu_id = rcd.menu_id '
  ||'    and gra.menu_id = menu.menu_id '
  ||' UNION '
  ||'  select menu.user_menu_name '
  ||'  from amw_role_constraint_denorm rcd '
  ||'      ,'||G_AMW_MENUS_VL||' menu '
  ||'      ,'||G_AMW_GRANTS||' gra '
  ||'  where rcd.constraint_rev_id = :3 '
  ||'    and gra.grantee_key = ''GLOBAL'' '
  ||'    and gra.grantee_type = ''GLOBAL'' '
  ||'    and gra.instance_type = ''GLOBAL'' '
  ||'    and gra.object_id = -1 '
  ||'    and gra.menu_id = rcd.menu_id '
  ||'    and gra.menu_id = menu.menu_id ';

BEGIN

    IF( l_log_stmt_level >= l_curr_log_level ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','Get_Violat_Existing_Menu_List Start');
	END IF;

  l_existing_menu_string := NULL;

  IF (p_user_id IS NOT NULL AND p_constraint_rev_id IS NOT NULL AND p_constraint_type_code IS NOT NULL) THEN
    OPEN existing_menu_c FOR l_existing_menu_dynamic_sql USING
          p_constraint_rev_id,
          p_user_id,
          p_constraint_rev_id;
    FETCH existing_menu_c BULK COLLECT INTO l_existing_menu_table;
    CLOSE existing_menu_c;

    IF l_existing_menu_table IS NOT NULL AND l_existing_menu_table.FIRST IS NOT NULL THEN
      l_existing_menu_string := l_existing_menu_table(1);
      FOR i in 2 .. l_existing_menu_table.COUNT
      LOOP
        l_existing_menu_string := l_existing_menu_string||', '||l_existing_menu_table(i);
      END LOOP;
    END IF; -- end of if: l_existing_menu_table IS NOT NULL

  END IF; --end of if: p_user_id IS NOT NULL AND p_constraint_rev_id IS NOT NULL AND p_constraint_type_code IS NOT NULL

  IF( l_log_stmt_level >= l_curr_log_level ) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','Get_Violat_Existing_Menu_List End');
  END IF;

  return l_existing_menu_string;
EXCEPTION
    WHEN OTHERS THEN
    IF( l_log_stmt_level >= l_curr_log_level ) THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','Error '||TO_CHAR(SQLCODE)||': '||SQLERRM);
    	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'amw.plsql.PreventFormCustomization','Get_Violat_Existing_Menu_List End');
	END IF;
	RAISE;

END Get_Violat_Existing_Menu_List;


/*
 * cpetriuc
 * ---------------------
 * CHECK_MENU_VIOLATIONS
 * ---------------------
 * Checks if the menu provided as argument violates any SOD (Segregation of Duties)
 * constraints.  If a constraint is violated, the function returns an error message
 * containing the name of the violated constraint together with the list of functions
 * that define the constraint.  Otherwise, the function returns 'N'.
 *
 * psomanat : bug 5692905 : consider Responsibility waiver. Added the parameters
 * p_responsibility_id,p_application_id
 */
function CHECK_MENU_VIOLATIONS(p_menu_id NUMBER,
                               p_responsibility_id     IN  NUMBER :=NULL,
                               p_application_id         IN  NUMBER :=NULL
) return VARCHAR2 is

g_menu_function_id_list G_NUMBER_TABLE;


cursor MENU_FUNCTIONS(p_menu_id NUMBER) is
select distinct FUNCTION_ID
from FND_COMPILED_MENU_FUNCTIONS
where MENU_ID = p_menu_id;


begin

g_menu_function_id_list.delete();
open MENU_FUNCTIONS(p_menu_id);
fetch MENU_FUNCTIONS bulk collect into g_menu_function_id_list;
close MENU_FUNCTIONS;

return CHECK_FUNCTION_LIST_VIOLATIONS(g_menu_function_id_list,p_responsibility_id,p_application_id);


end CHECK_MENU_VIOLATIONS;




/*
 * cpetriuc
 * -------------------------
 * CHECK_FUNCTION_VIOLATIONS
 * -------------------------
 * Checks if any SOD (Segregation of Duties) constraints would be violated if the
 * argument function or submenu would be added to the menu provided as argument.  If a
 * constraint would be violated, the function returns an error message containing the name
 * of the potentially violated constraint together with the list of functions that define
 * the constraint.  Otherwise, the function returns 'N'.
 */
function CHECK_FUNCTION_VIOLATIONS(p_menu_id NUMBER, p_sub_menu_id NUMBER, p_function_id NUMBER) return VARCHAR2 is
    l_menu_id_list G_NUMBER_TABLE;

m_return_text VARCHAR2(3000);

    CURSOR all_menus_in_hierarchy(p_menu_id NUMBER) is
        SELECT sub_menu_id menu_id
        FROM   fnd_menu_entries
        START WITH menu_id =p_menu_id
        CONNECT BY PRIOR sub_menu_id = menu_id
        UNION
        SELECT menu_id
        FROM fnd_menu_entries
        START WITH menu_id =p_menu_id
        CONNECT BY PRIOR menu_id = sub_menu_id;


        /** dliao modified on 11/08/2006 for the bug 5610537
            use FND_MENU_ENTRIES i.s.o. FND_COMPILED_MENU_FUNCTION because FND_COMPILED_MENU_FUNCTION
            won't be populated until all of menu entries are created. Our goal is to check multiple
            menu entries that violating the sod before they are created in the database.
        ***/

    cursor MENU_FUNCTIONS(p_menu_id NUMBER) is
        select distinct FUNCTION_ID
        from FND_MENU_ENTRIES  --FND_COMPILED_MENU_FUNCTIONS
        where MENU_ID = p_menu_id;

    cursor MENU_AND_SUB_MENU_FUNCTIONS(p_menu_id NUMBER, p_sub_menu_id NUMBER) is
        select distinct FUNCTION_ID
        from FND_MENU_ENTRIES --FND_COMPILED_MENU_FUNCTIONS
        where MENU_ID = p_menu_id or MENU_ID = p_sub_menu_id;

    flag BOOLEAN;

BEGIN

    g_menu_id_list.delete();
    g_function_id_list.delete();
    g_menu_function_id_list.delete();

    OPEN all_menus_in_hierarchy(p_menu_id);
    FETCH all_menus_in_hierarchy BULK COLLECT INTO l_menu_id_list;
    CLOSE all_menus_in_hierarchy;

    IF l_menu_id_list.COUNT <> 0 THEN
        FOR i IN 1 .. l_menu_id_list.COUNT
        LOOP
            IF NOT (g_menu_id_list.EXISTS(i)) THEN
                flag:=process_menu_tree_down_for_mn(l_menu_id_list(i));
            END IF;
        END LOOP;
    END IF;

    -- ptulasi : 07/11/2007
    -- bug: 6208788 : Modified below code to eliminate the duplicate entry of
    -- pfunction id to g_menu_function_id_list
    IF p_function_id IS NOT NULL THEN
        IF NOT (g_function_id_list.EXISTS(p_function_id)) THEN
            g_menu_function_id_list(g_menu_function_id_list.count+1):=p_function_id;
        END IF;
    END IF;

    IF p_sub_menu_id IS NOT NULL THEN
        flag:=process_menu_tree_down_for_mn(p_sub_menu_id);
    END IF;

    m_return_text := CHECK_FUNCTION_LIST_VIOLATIONS(g_menu_function_id_list,NULL,NULL);
    if (m_return_text <> 'N') then
        return m_return_text;
    end if;

    return 'N';


-- psomanat : Commenting the below code for bug 6010908

/*for menu in ALL_MENUS_IN_HIERARCHY(p_menu_id) loop

g_menu_function_id_list.delete();

if (p_sub_menu_id is null) then
open MENU_FUNCTIONS(menu.MENU_ID);
fetch MENU_FUNCTIONS bulk collect into g_menu_function_id_list;
close MENU_FUNCTIONS;
else
open MENU_AND_SUB_MENU_FUNCTIONS(menu.MENU_ID, p_sub_menu_id);
fetch MENU_AND_SUB_MENU_FUNCTIONS bulk collect into g_menu_function_id_list;
close MENU_AND_SUB_MENU_FUNCTIONS;
m_return_text := CHECK_FUNCTION_LIST_VIOLATIONS(g_menu_function_id_list,NULL,NULL);
if (m_return_text <> 'N') then return m_return_text; end if;
end if;

if (p_function_id is not null) then
m_return_text := CHECK_ADD_FUNCTION_VIOLATIONS(g_menu_function_id_list, p_function_id);
if (m_return_text <> 'N') then return m_return_text; end if;
end if;

end loop;

return 'N'; */


end CHECK_FUNCTION_VIOLATIONS;




/*
 * cpetriuc
 * ------------------------------
 * CHECK_FUNCTION_LIST_VIOLATIONS
 * ------------------------------
 * Created initially as a helper function, to be used internally.
 *
 * Checks if the list of menu functions provided as argument violates any SOD
 * (Segregation of Duties) constraints.  If a constraint is violated, the function
 * returns an error message containing the name of the violated constraint together
 * with the list of functions that define the constraint.  Otherwise, the function
 * returns 'N'.
 *
 * psomanat : bug 5692905 : consider Responsibility waiver. Added the parameters
 * p_responsibility_id,p_application_id
 */
function CHECK_FUNCTION_LIST_VIOLATIONS(g_menu_function_id_list G_NUMBER_TABLE,
                               p_responsibility_id     IN  NUMBER,
                               p_application_id         IN  NUMBER) return VARCHAR2 is

g_constraint_function_id_list G_NUMBER_TABLE;
g_constraint_group_code_list G_NUMBER_TABLE;
g_group_code_list G_NUMBER_TABLE;
m_constraint_details VARCHAR2(4000);
m_counter NUMBER;
m_failed BOOLEAN;
m_function_name VARCHAR2(240);
--fnd.message returns up to 2000 bytes of message
m_return_text VARCHAR2(2000);


cursor CONSTRAINTS is
select *
from AMW_CONSTRAINTS_VL
where
(TYPE_CODE = 'ALL' or TYPE_CODE = 'ME' or TYPE_CODE = 'SET') and
START_DATE <= sysdate and
(END_DATE is null or END_DATE >= sysdate)
and objective_code = 'PR';

cursor CONSTRAINT_ENTRIES(p_constraint_rev_id NUMBER) is
select distinct FUNCTION_ID, GROUP_CODE
from AMW_CONSTRAINT_ENTRIES
where
CONSTRAINT_REV_ID = p_constraint_rev_id and
(OBJECT_TYPE = 'FUNC' or OBJECT_TYPE is null);

cursor CONSTRAINT_GROUP_CODES(p_constraint_rev_id NUMBER) is
select distinct GROUP_CODE
from AMW_CONSTRAINT_ENTRIES
where
CONSTRAINT_REV_ID = p_constraint_rev_id and
(OBJECT_TYPE = 'FUNC' or OBJECT_TYPE is null);

l_valid_resp_waiver_count NUMBER;
CURSOR c_valid_resp_waivers (l_constraint_rev_id IN NUMBER, l_resp_id IN NUMBER, l_appl_id IN NUMBER) IS
    SELECT count(*)
      FROM amw_constraint_waivers_vl
     WHERE constraint_rev_id = l_constraint_rev_id
       AND object_type = 'RESP'
       AND PK1 = l_resp_id
       AND PK2 = l_appl_id
       AND start_date <= sysdate AND (end_date >= sysdate or end_date is null);

begin

    for constraint in CONSTRAINTS loop
        m_failed := FALSE;
        g_constraint_function_id_list.delete();
        g_constraint_group_code_list.delete();

        open CONSTRAINT_ENTRIES(constraint.CONSTRAINT_REV_ID);
        fetch CONSTRAINT_ENTRIES bulk collect into
            g_constraint_function_id_list,
            g_constraint_group_code_list;
        close CONSTRAINT_ENTRIES;

        for i in 1 .. g_constraint_function_id_list.COUNT loop
            select USER_FUNCTION_NAME into m_function_name
            from FND_FORM_FUNCTIONS_VL
            where FUNCTION_ID = g_constraint_function_id_list(i);

            if i = 1 then m_constraint_details := m_function_name;
            else m_constraint_details := substrb((m_constraint_details || ', ' || m_function_name), 1, 4000);
            end if;

        end loop;

        ------------------------------------
        -- Process a constraint of type ALL.
        ------------------------------------

        if constraint.TYPE_CODE = 'ALL' then
            for i in 1 .. g_constraint_function_id_list.COUNT loop
                m_failed := FALSE;  -- Each constraint function must exist among the menu functions.
                for j in 1 .. g_menu_function_id_list.COUNT loop
                    if g_constraint_function_id_list(i) = g_menu_function_id_list(j) then
                        m_failed := TRUE;  -- This constraint function exists among the menu functions.
                        exit;
                    end if;
                end loop;
                if m_failed = FALSE then
                    exit;  -- A constraint function has not been found among the menu functions.
                end if;
            end loop;
        end if;

        ------------------------------------------------------
        -- Process a constraint of type ME (Mutual Exclusion).
        ------------------------------------------------------

        if constraint.TYPE_CODE = 'ME' then
            m_counter := 0;
            for i in 1 .. g_constraint_function_id_list.COUNT loop
                for j in 1 .. g_menu_function_id_list.COUNT loop
                    if g_constraint_function_id_list(i) = g_menu_function_id_list(j) then
                        m_counter := m_counter + 1;
                    end if;
                end loop;
            end loop;

            if m_counter >= 2 then
                m_failed := TRUE;
            end if;
        end if;

        ------------------------------------
        -- Process a constraint of type SET.
        ------------------------------------
        if constraint.TYPE_CODE = 'SET' then
            g_group_code_list.delete();

            open CONSTRAINT_GROUP_CODES(constraint.CONSTRAINT_REV_ID);
            fetch CONSTRAINT_GROUP_CODES bulk collect into g_group_code_list;
            close CONSTRAINT_GROUP_CODES;

            m_failed := TRUE;  -- Assume the contrary.

            for i in 1 .. g_constraint_function_id_list.COUNT loop
                for j in 1 .. g_menu_function_id_list.COUNT loop
                    if g_constraint_function_id_list(i) = g_menu_function_id_list(j) then
                        g_group_code_list(g_constraint_group_code_list(i)) := 0;
                    end if;
                end loop;
            end loop;

            for k in 1 .. g_group_code_list.COUNT loop
                if g_group_code_list(k) <> 0 then
                    m_failed := FALSE;  -- Not all groups have at least one function among the menu functions.
                    exit;
                end if;
            end loop;

        end if;

-- psomanat : bug 5692905 : consider Responsibility waiver when this function
-- is called from CHECK_MENU_VIOLATIONS
IF  p_responsibility_id IS NOT NULL AND p_application_id IS NOT NULL THEN
    -- check if this responsibility is waived (due to User Waiver) from this constraint
    OPEN c_valid_resp_waivers(constraint.CONSTRAINT_REV_ID,p_responsibility_id,p_application_id);
    FETCH c_valid_resp_waivers INTO l_valid_resp_waiver_count;
    CLOSE c_valid_resp_waivers;

    IF (l_valid_resp_waiver_count > 0) THEN
        m_failed := FALSE;
    END IF;
END IF;

-----------------------------------------------------------------------
-- If this constraint has been violated, return an appropriate message.
-----------------------------------------------------------------------

if m_failed = TRUE then

    FND_MESSAGE.SET_NAME('AMW', 'AMW_SOD_VIOLATION');
    FND_MESSAGE.SET_TOKEN('CONSTRAINT', constraint.CONSTRAINT_NAME);
    FND_MESSAGE.SET_TOKEN('CONST_DETAILS', m_constraint_details);
    m_return_text := substrb((FND_MESSAGE.GET), 1, 2000);

    return m_return_text;

end if;

end loop;  -- CONSTRAINTS cursor loop

return 'N';


end CHECK_FUNCTION_LIST_VIOLATIONS;




/*
 * cpetriuc
 * -----------------------------
 * CHECK_ADD_FUNCTION_VIOLATIONS
 * -----------------------------
 * Created initially as a helper function, to be used internally.
 *
 * Checks if adding the argument function to the list of menu functions provided as
 * argument violates any SOD (Segregation of Duties) constraints.  If a constraint is
 * violated, the function returns an error message containing the name of the violated
 * constraint together with the list of functions that define the constraint.  Otherwise,
 * the function returns 'N'.
 */
function CHECK_ADD_FUNCTION_VIOLATIONS(g_menu_function_id_list G_NUMBER_TABLE, p_function_id NUMBER) return VARCHAR2 is

g_constraint_function_id_list G_NUMBER_TABLE;
g_constraint_group_code_list G_NUMBER_TABLE;
g_group_code_list G_NUMBER_TABLE;
m_constraint_details VARCHAR2(4000);
m_failed BOOLEAN;
m_function_name VARCHAR2(240);
--fnd_message.get returns up to 2000 bytes of message
m_return_text VARCHAR2(2000);


cursor CONSTRAINTS is
select *
from AMW_CONSTRAINTS_VL
where
(TYPE_CODE = 'ALL' or TYPE_CODE = 'ME' or TYPE_CODE = 'SET') and
START_DATE <= sysdate and
(END_DATE is null or END_DATE >= sysdate)
and objective_code = 'PR';

cursor CONSTRAINT_ENTRIES(p_constraint_rev_id NUMBER) is
select distinct FUNCTION_ID, GROUP_CODE
from AMW_CONSTRAINT_ENTRIES
where
CONSTRAINT_REV_ID = p_constraint_rev_id and
(OBJECT_TYPE = 'FUNC' or OBJECT_TYPE is null);

cursor CONSTRAINT_GROUP_CODES(p_constraint_rev_id NUMBER) is
select distinct GROUP_CODE
from AMW_CONSTRAINT_ENTRIES
where
CONSTRAINT_REV_ID = p_constraint_rev_id and
(OBJECT_TYPE = 'FUNC' or OBJECT_TYPE is null);


begin

for constraint in CONSTRAINTS loop
    m_failed := FALSE;

    g_constraint_function_id_list.delete();
    g_constraint_group_code_list.delete();

    open CONSTRAINT_ENTRIES(constraint.CONSTRAINT_REV_ID);
    fetch CONSTRAINT_ENTRIES bulk collect into
        g_constraint_function_id_list,
        g_constraint_group_code_list;
    close CONSTRAINT_ENTRIES;

    for i in 1 .. g_constraint_function_id_list.COUNT loop

        select USER_FUNCTION_NAME into m_function_name
        from FND_FORM_FUNCTIONS_VL
        where FUNCTION_ID = g_constraint_function_id_list(i);

        if i = 1 then m_constraint_details := m_function_name;
        else m_constraint_details := m_constraint_details || ', ' || m_function_name;
        end if;

    end loop;

    for i in 1 .. g_constraint_function_id_list.COUNT loop
        if g_constraint_function_id_list(i) = p_function_id then
            ------------------------------------
            -- Process a constraint of type ALL.
            ------------------------------------
            if constraint.TYPE_CODE = 'ALL' then
                for j in 1 .. g_constraint_function_id_list.COUNT loop
                    m_failed := FALSE;  -- Each constraint function must exist among the menu functions.
                    if i <> j then
                        for k in 1 .. g_menu_function_id_list.COUNT loop
                            if g_constraint_function_id_list(j) = g_menu_function_id_list(k) then
                                m_failed := TRUE;  -- This constraint function exists among the menu functions.
                                exit;
                            end if;
                        end loop;
                    else
                        m_failed := TRUE;  -- If i = j, continue the loop.
                    end if;
                    if m_failed = FALSE then
                        exit;  -- A constraint function has not been found among the menu functions.
                    end if;
                end loop;
            end if;

            ------------------------------------------------------
            -- Process a constraint of type ME (Mutual Exclusion).
            ------------------------------------------------------
            if constraint.TYPE_CODE = 'ME' then
                for j in 1 .. g_constraint_function_id_list.COUNT loop
                    if i <> j then
                        for k in 1 .. g_menu_function_id_list.COUNT loop
                            if g_constraint_function_id_list(j) = g_menu_function_id_list(k) then
                                m_failed := TRUE;
                                exit;
                            end if;
                        end loop;
                    end if;

                    if m_failed = TRUE then
                        exit;  -- At least one mutual exclusivity has been violated.
                    end if;
                end loop;
            end if;

            ------------------------------------
            -- Process a constraint of type SET.
            ------------------------------------
            if constraint.TYPE_CODE = 'SET' then
                g_group_code_list.delete();
                open CONSTRAINT_GROUP_CODES(constraint.CONSTRAINT_REV_ID);
                fetch CONSTRAINT_GROUP_CODES bulk collect into g_group_code_list;
                close CONSTRAINT_GROUP_CODES;

                g_group_code_list(g_constraint_group_code_list(i)) := 0;
                m_failed := TRUE;  -- Assume the contrary.
                for j in 1 .. g_constraint_function_id_list.COUNT loop
                    if i <> j then
                        for k in 1 .. g_menu_function_id_list.COUNT loop
                            if g_constraint_function_id_list(j) = g_menu_function_id_list(k) then
                                g_group_code_list(g_constraint_group_code_list(j)) := 0;
                            end if;
                        end loop;
                    end if;
                end loop;

                for l in 1 .. g_group_code_list.COUNT loop
                    if g_group_code_list(l) <> 0 then
                        m_failed := FALSE;  -- Not all groups have at least one function among the menu functions.
                        exit;
                    end if;
                end loop;
            end if;

            -----------------------------------------------------------------------
            -- If this constraint has been violated, return an appropriate message.
            -----------------------------------------------------------------------
            if m_failed = TRUE then
                FND_MESSAGE.SET_NAME('AMW', 'AMW_SOD_VIOLATION');
                FND_MESSAGE.SET_TOKEN('CONSTRAINT', constraint.CONSTRAINT_NAME);
                FND_MESSAGE.SET_TOKEN('CONST_DETAILS', m_constraint_details);
                m_return_text := substrb((FND_MESSAGE.GET), 1, 2000);
                return m_return_text;
            end if;

        end if;  -- if g_constraint_function_id_list(i) = p_function_id
    end loop;  -- g_constraint_function_id_list loop

end loop;  -- CONSTRAINTS cursor loop

return 'N';


end CHECK_ADD_FUNCTION_VIOLATIONS;





end AMW_VIOLATION_PUB;

/
