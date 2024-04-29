--------------------------------------------------------
--  DDL for Package Body AMW_VIOLATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_VIOLATION_PVT" AS
/* $Header: amwvvlab.pls 120.40 2007/09/18 10:58:44 ptulasi ship $ */
-- ===============================================================
-- Package name
--          AMW_VIOLATION_PVT
-- Purpose
--
-- History
-- 		  	06/01/2005    tsho     Create
-- ===============================================================


-- store potential violation info (valid for one constraint)
G_ROLE_NAME_LIST            G_VARCHAR2_LONG_TABLE;
G_RESPONSIBILITY_ID_LIST    G_NUMBER_TABLE;
G_MENU_ID_LIST              G_NUMBER_TABLE;
G_FUNCTION_ID_LIST          G_NUMBER_TABLE;
G_ENTRY_OBJECT_TYPE_LIST    G_VARCHAR2_CODE_TABLE;
G_GROUP_CODE_LIST           G_VARCHAR2_CODE_TABLE;
G_PV_COUNT                  NUMBER;

--store role/resp hierarchy structure
G_ROLE_NAME_LIST_HIER            G_VARCHAR2_LONG_TABLE;
G_RESPONSIBILITY_ID_LIST_HIER   G_NUMBER_TABLE;
G_MENU_ID_LIST_HIER           G_NUMBER_TABLE;
G_FUNCTION_ID_LIST_HIER        G_NUMBER_TABLE;
G_ENTRY_OBJECT_TYPE_LIST_HIER    G_VARCHAR2_CODE_TABLE;
G_GROUP_CODE_LIST_HIER          G_VARCHAR2_CODE_TABLE;
G_PV_COUNT_HIER                NUMBER;


G_BULK_COLLECTS_SUPPORTED 	VARCHAR2(30) := 'TRUE';

-- copy from FND_FUNCTION.C_MAX_MENU_ENTRIES (AFSCFNSB.pls 115.51 2003/08/01)
-- This constant is used for recursion detection in the fallback
-- runtime menu scan.  We keep track of how many items are on the menu,
-- and assume if the number of entries on the current
-- menu is too high then it's caused by recursion.
C_MAX_MENU_ENTRIES CONSTANT pls_integer := 10000;


-- copy from FND_FUNCTION.P_LAST_RESP_ID (AFSCFNSB.pls 115.51 2003/08/01)
-- copy from FND_FUNCTION.P_LAST_RESP_APPL_ID (AFSCFNSB.pls 115.51 2003/08/01)
-- copy from FND_FUNCTION.P_LAST_MENU_ID (AFSCFNSB.pls 115.51 2003/08/01)
-- This simple cache will avoid the need to find which menu is on
-- the current responsibility with SQL every time.  We just store
-- the menu around after we get it for the current resp.
P_LAST_RESP_ID NUMBER := -1;
P_LAST_RESP_APPL_ID NUMBER := -1;
P_LAST_MENU_ID NUMBER := -1;

-- ===============================================================
-- Function name
--          Is_ICM_Installed
--
-- Purpose
--          check to see if ICM is installed or not.
--          other ICM API should be called only when 'Y' is return from Is_ICM_Installed
-- Params
--
-- Return
--          'Y' := ICM is installed
--          'N' := ICM is not installed
-- History
-- 		  	07/19/2005    tsho     Create
-- ===============================================================
Function Is_ICM_Installed
RETURN VARCHAR2
IS
is_icm_valid    varchar2(1);
dummy           varchar2(1);

TYPE icmCurTyp IS REF CURSOR;
c_has_icm icmCurTyp;
l_has_icm_sql varchar2(64) := 'select null from AMW_CONSTRAINTS_B where rownum = 1';

BEGIN

  is_icm_valid := 'N';

  OPEN c_has_icm FOR l_has_icm_sql;
  FETCH c_has_icm INTO dummy;
  IF (c_has_icm%notfound) THEN
    is_icm_valid := 'N';
  ELSE
    is_icm_valid := 'Y';
  END IF;
  CLOSE c_has_icm;

  return is_icm_valid;

EXCEPTION
    WHEN others then
        return 'N';
END Is_ICM_Installed;


-- ===============================================================
-- Procedure name
--          Has_Violations_For_Mode
--
-- Purpose
--          check for OICM SOD constriants that will be violated
--          if the user is assigned these additional roles as well as inherited roles
--          This Procedure is called from the UMX_REGISTRATION_UTIL.ICM_VIOLATION_CHECK
-- Params
--          p_user_id            := input fnd user_id
--          p_role_names         := input a list of new roles
--          p_mode               := input check mode ('ADMIN', 'APPROVE', 'SUBS')
--          x_violat_hashtable   := This API will put return parameters in a Associate Table format,
--                                  it at least contains the following key/value pairs:
--                                  HasViolations      : 'Y' or 'N' to indicate if introducing violations when trying to add those roles to the user
--                                  ViolationDetail   : the OAFunc/Region containing violation details for the user , mainly used for Notification.
--
-- History
-- 		  	07/19/2005    tsho     Create
-- ===============================================================
Procedure Has_Violations_For_Mode (
    p_user_id               IN  NUMBER,
    p_role_names            IN  JTF_VARCHAR2_TABLE_400,
    p_mode                  IN  VARCHAR2,
    x_violat_hashtable      OUT NOCOPY G_VARCHAR2_HASHTABLE
)
IS
    l_violat_region     VARCHAR2(320);
    l_violat_btn_region VARCHAR2(320);
    l_has_violation     VARCHAR2(1);
    l_return_status     VARCHAR2(10);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(5000);
BEGIN
  Has_Violations (
    p_user_id=>p_user_id,
    p_role_names=>p_role_names,
    p_mode=>p_mode,
    x_violat_region=>l_violat_region,
    x_violat_btn_region=>l_violat_btn_region,
    x_has_violation=>l_has_violation,
    x_return_status=>l_return_status,
    x_msg_count=>l_msg_count,
    x_msg_data=>l_msg_data);

    IF (l_has_violation = 'Y') THEN

        x_violat_hashtable('HasViolations') := 'Y';

	  -- 07/13/2006 psomanat : Fix for bug 5388850
	  -- ptulasi : 09/03/07
        -- bug: 6371514 : Modified below code to correct the url
        x_violat_hashtable('ViolationDetail') := 'AMW_ROLE_APPROVAL_NOTIFY&pNewRoleName='||p_role_names(1)||'&pUserId='||p_user_id;
        --x_violat_hashtable('ViolationDetail') := 'AMW_ROLE_APPROVAL_NOTIFY='||p_role_names(1)||'='||p_user_id;
        --x_violat_hashtable('ViolationDetail') := 'AMW_ROLE_APPROVAL_NOTIFY=--=--';
    ELSE
        x_violat_hashtable('HasViolations') := 'N';
        x_violat_hashtable('ViolationDetail') := NULL;
    END IF;

END Has_Violations_For_Mode;

-- ===============================================================
-- Procedure name
--          Has_Violations
-- This procedure is obsolated due to bug 5407266
-- ===============================================================
Procedure Has_Violations (
    p_user_id               IN  NUMBER,
    p_role_names            IN  JTF_VARCHAR2_TABLE_400,
    p_mode                  IN  VARCHAR2,
    x_violat_region         OUT NOCOPY VARCHAR2,
    x_violat_btn_region     OUT NOCOPY VARCHAR2,
    x_has_violation         OUT NOCOPY VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
)
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Has_Violations';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

l_new_resp_name VARCHAR2(320);
l_existing_resp_name VARCHAR2(320);


BEGIN

 Has_Violations (
    p_user_id=>p_user_id,
    p_role_names=>p_role_names,
    p_revoked_role_names   => NULL,
    p_mode  => p_mode,
    x_violat_region => x_violat_region,
    x_violat_btn_region => x_violat_btn_region,
    x_has_violation => x_has_violation,
    x_new_resp_name  => l_new_resp_name,
    x_existing_resp_name => l_existing_resp_name,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data);

END Has_Violations;


-- ===============================================================
-- Procedure name
--          Has_Violations
--
-- Purpose
--          check for OICM SOD constriants that will be violated
--          if the user is assigned these additional roles as well as inherited roles
-- Params
--          p_user_id            := input fnd user_id
--          p_role_names         := input a list of new roles
--          p_revoked_role_names  := input a list of revoked roles
--          p_mode               := input check mode ('ADMIN', 'APPROVE', 'SUBS')
--          x_violat_region      := output full path dialog region name to display potential violation detials.
--                                  (ie. /oracle/apps/amw/audit/duty/webui/....RN)
--          x_violat_btn_region  := output full path dialog button region name to display page level buttons.
--                                  (ie. /oracle/apps/amw/audit/duty/webui/....RN)
--                                  this button region is different depending on the override privilege of Administrator
--          x_has_violation      := output 'Y' if this user will have violations with the new roles assigned; output 'N' otherwise.
--
--          x_new_resp_name      := output a list of newly assigned resps/roles which violate the sod
--          x_existing_resp_name := output a list of existing resps/roles which violate the sod
-- History
-- 		  	06/01/2005    tsho     Create
--          08/03/2005    tsho     Consider User Waivers
--          04/28/2006    dliao	   Consider RESPALL/RESPME/RESPSET
-- ===============================================================
Procedure Has_Violations (
    p_user_id               IN  NUMBER,
    p_role_names            IN  JTF_VARCHAR2_TABLE_400,
    p_revoked_role_names    IN  JTF_VARCHAR2_TABLE_400,
    p_mode                  IN  VARCHAR2,
    x_violat_region         OUT NOCOPY VARCHAR2,
    x_violat_btn_region     OUT NOCOPY VARCHAR2,
    x_has_violation         OUT NOCOPY VARCHAR2,
    x_new_resp_name         OUT NOCOPY VARCHAR2,
    x_existing_resp_name    OUT NOCOPY VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
)
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Has_Violations';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;


-- find all valid constraints
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
      WHERE constraint_rev_id = l_constraint_rev_id;

TYPE refCurTyp IS REF CURSOR;
func_acess_count_c refCurTyp;
group_acess_count_c refCurTyp;
new_violation_count_c refCurTyp;
resp_acess_count_c refCurTyp;
violating_new_resps_c refCurTyp;
violating_old_resps_c refCurTyp;
existing_violation_c refCurTyp;

-- store passed-in p_role_names, p_revoked_role_names as string, sperated by ','
l_role_names VARCHAR2(32767);
l_sub_role_names VARCHAR2(32767);
l_revoked_role_names VARCHAR2(32767);

l_func_dynamic_sql   VARCHAR2(32767);
l_vio_exist_role_sql VARCHAR2(32767);
l_vio_exist_resp_sql VARCHAR2(32767);

l_func_sql VARCHAR2(32767);
l_func_existing_sql   VARCHAR2(32767);


l_func_set_dynamic_sql   VARCHAR2(32767);
l_func_set_existing_sql   VARCHAR2(32767);

l_resp_sql VARCHAR2(32767);
l_resp_dynamic_sql  VARCHAR2(32767);
l_resp_existing_sql   VARCHAR2(32767);

l_resp_set_dynamic_sql   VARCHAR2(32767);
l_resp_set_existing_sql   VARCHAR2(32767);



-- get valid user waiver
l_valid_user_waiver_count NUMBER;
CURSOR c_valid_user_waivers (l_constraint_rev_id IN NUMBER, l_user_id IN NUMBER) IS
    SELECT count(*)
      FROM amw_constraint_waivers_vl
     WHERE constraint_rev_id = l_constraint_rev_id
       AND object_type = 'USER'
       AND PK1 = l_user_id
       AND start_date <= sysdate AND (end_date >= sysdate or end_date is null);

-- get violated responsibilities
CURSOR c_violated_responsibilities(l_constraint_rev_id IN NUMBER) IS
	SELECT resp.responsibility_name
	  FROM fnd_responsibility_vl resp
	WHERE resp.responsibility_id in (
		SELECT function_id
		FROM amw_constraint_entries cons
		WHERE constraint_rev_id = l_constraint_rev_id
		AND cons.application_id = resp.application_id);

l_cst_new_violation_sql   VARCHAR2(5000) ;
l_sub_revoked_role_names    VARCHAR2(32767);


l_violating_new_roles_sql varchar2(32767);
l_violating_new_resp_table JTF_VARCHAR2_TABLE_400;
l_violating_existing_roles_sql VARCHAR2(32767);
l_violating_old_resp_table JTF_VARCHAR2_TABLE_400;

l_existing_violation_sql varchar2(32676);
l_new_violation_table JTF_VARCHAR2_TABLE_400;
l_existing_violation_table JTF_VARCHAR2_TABLE_400;


BEGIN
  l_role_names := NULL;
  l_revoked_role_names := NULL;
  x_violat_region := NULL;
  x_violat_btn_region := NULL;
  l_valid_user_waiver_count := 0;

  -- default to 'N', which means user doesn't have violations
  x_has_violation := 'N';

  IF (p_revoked_role_names IS NULL or p_revoked_role_names.FIRST IS NULL or p_revoked_role_names(1) IS NULL
    or p_revoked_role_names(1) = '' ) THEN
	  l_sub_revoked_role_names := '';
  ELSE
  	-- store pass-in p_revoked_role_names as flat string
    l_revoked_role_names := ''''||p_revoked_role_names(1) || '''';
    FOR i IN 2 .. p_revoked_role_names.COUNT
    LOOP
      l_revoked_role_names := l_revoked_role_names||',''' ||p_revoked_role_names(i) || '''';
    END LOOP;

    l_sub_revoked_role_names := ' and uar.role_name not in ( ' ||
          ' select  distinct ROLE_NAME  from wf_user_role_assignments_v a '||
          ' where a.assigning_role IN ( ' || l_revoked_role_names || ' ) '||
          ' AND a.role_name = a.assigning_role  ) ';

          /*** add the inherited roles
          ' UNION ALL  '||
          ' select distinct ROLE_NAME  from wf_user_role_assignments_v b  '||
          ' where user_name = (select user_name from fnd_user where user_id = ' || p_user_id  || ' ) '||
          ' and b.assigning_role IN ( ' || l_revoked_role_names || ' ) '||
          ' and b.role_name <> b.assigning_role  '||
          ' and b.start_date <= sysdate and (b.end_date is null or b.end_date > sysdate)  '||
          ' and b.role_name not in  '||
          ' (SELECT c.ROLE_NAME FROM wf_user_role_assignments_v c WHERE  '||
          ' c.start_date <= sysdate and (c.end_date is null or c.end_date > sysdate)  '||
          ' and c.ASSIGNING_ROLE IN (  '||
          ' select ROLE_NAME from wf_user_role_assignments_v d  '||
          ' where d.role_name = d.assigning_role  '||
          ' and d.role_name not in (' || l_revoked_role_names || ' ) '||
          ' and d.start_date <= sysdate and (d.end_date is null or d.end_date > sysdate))))';
          *************/

 END IF;

 l_func_existing_sql :=
    '  select rcd.function_id '
  ||'  from amw_role_constraint_denorm rcd '
  ||'      ,'||G_AMW_USER_ROLES||' ur '
  ||'      ,'||G_AMW_user||' u '
  ||'      ,'||G_AMW_USER_ROLE_ASSIGNMENTS_V || ' uar '
  ||'  where rcd.constraint_rev_id = :1 '
  ||'    and u.user_id = :2 '
  ||'    and u.user_name = ur.user_name '
  ||'    and uar.user_name = ur.user_name '
  ||'    and uar.role_name = ur.role_name '
  ||'    and uar.start_date <= sysdate '
  ||'    and (uar.end_date is null or uar.end_date >= sysdate) '
  ||'    and ( (ur.role_name = rcd.role_name '
  ||'    and ur.role_orig_system = ''UMX'' ) '
  ||'    or ( ur.role_orig_system_id = rcd.responsibility_id '
  ||'    and ur.role_orig_system = ''FND_RESP'' ) ) '
  ||     l_sub_revoked_role_names
  ||'  UNION ALL '
  ||'  select rcd.function_id '
  ||'  from amw_role_constraint_denorm rcd '
  ||'      ,'||G_AMW_GRANTS||' gra '
  ||'  where rcd.constraint_rev_id = :3 '
  ||'    and gra.instance_type = ''GLOBAL'' and gra.menu_id = rcd.menu_id '
  ||'    and gra.object_id = -1 and ( gra.grantee_type = ''GLOBAL'' '
  ||'    or ( gra.grantee_type = ''USER'' and gra.grantee_key = (select u.user_name from '
  ||    G_AMW_USER || ' u where u.user_id = :4 ))) ';


l_func_set_existing_sql :=
    '  select rcd.group_code '
  ||'  from amw_role_constraint_denorm rcd '
  ||'      ,'||G_AMW_USER_ROLES||' ur '
  ||'      ,'||G_AMW_user||' u '
  ||'      ,'||G_AMW_USER_ROLE_ASSIGNMENTS_V || ' uar '
  ||'  where rcd.constraint_rev_id = :1 '
  ||'    and u.user_id = :2 '
  ||'    and u.user_name = ur.user_name '
  ||'    and uar.user_name = ur.user_name '
  ||'    and uar.role_name = ur.role_name '
  ||'    and uar.start_date <= sysdate '
  ||'    and (uar.end_date is null or uar.end_date >= sysdate) '
  ||'    and ( (ur.role_name = rcd.role_name '
  ||'    and ur.role_orig_system = ''UMX'' ) '
  ||'    or ( ur.role_orig_system_id = rcd.responsibility_id '
  ||'    and ur.role_orig_system = ''FND_RESP'' ) ) '
  ||     l_sub_revoked_role_names
  ||'  UNION ALL '
  ||'  select rcd.group_code '
  ||'  from amw_role_constraint_denorm rcd '
  ||'      ,'||G_AMW_GRANTS||' gra '
  ||'  where rcd.constraint_rev_id = :3 '
  ||'    and gra.instance_type = ''GLOBAL'' and gra.menu_id = rcd.menu_id '
  ||'    and gra.object_id = -1 and ( gra.grantee_type = ''GLOBAL'' '
  ||'    or ( gra.grantee_type = ''USER'' and gra.grantee_key = (select u.user_name from '
  ||    G_AMW_USER || ' u where u.user_id = :4 ))) ';

l_resp_existing_sql :=
  '  select ur.role_orig_system_id '
  ||'  from '
  || G_AMW_USER_ROLES||' ur '
  ||'      ,'||G_AMW_user||' u '
  ||'      ,amw_constraint_entries cst '
  ||'      ,'||G_AMW_USER_ROLE_ASSIGNMENTS_V || ' uar '
  ||'  where  u.user_id = :1 '
  ||'    and  cst.constraint_rev_id = :2 '
  ||'    and u.user_name = ur.user_name '
  ||'    and ur.role_orig_system_id = cst.function_id '
  ||'    and ur.role_orig_system = ''FND_RESP'' '
  ||'    and uar.user_name = ur.user_name '
  ||'    and uar.role_name = ur.role_name '
  ||'    and uar.start_date <= sysdate '
  ||'    and (uar.end_date is null or uar.end_date >= sysdate) '
  ||     l_sub_revoked_role_names ;

l_resp_set_existing_sql :=
  '  select cst.group_code '
  ||'  from '
  || G_AMW_USER_ROLES||' ur '
  ||'      ,'||G_AMW_user||' u '
  ||'      ,amw_constraint_entries cst '
  ||'      ,'||G_AMW_USER_ROLE_ASSIGNMENTS_V || ' uar '
  ||'  where  u.user_id = :1 '
  ||'    and  cst.constraint_rev_id = :2 '
  ||'    and u.user_name = ur.user_name '
  ||'    and ur.role_orig_system_id = cst.function_id '
  ||'    and ur.role_orig_system = ''FND_RESP'' '
  ||'    and uar.user_name = ur.user_name '
  ||'    and uar.role_name = ur.role_name '
  ||'    and uar.start_date <= sysdate '
  ||'    and (uar.end_date is null or uar.end_date >= sysdate) '
  ||     l_sub_revoked_role_names;


  IF (p_user_id IS NOT NULL AND p_role_names IS NOT NULL AND p_role_names.FIRST IS NOT NULL) THEN

    -- store pass-in p_role_names as flat string
    l_role_names := ''''||p_role_names(1)||'''';
    FOR i IN 2 .. p_role_names.COUNT
    LOOP
      l_role_names := l_role_names||','''||p_role_names(i)||'''';
    END LOOP;

    l_sub_role_names :=
         ' SELECT distinct SUPER_NAME '||
         ' FROM              WF_ROLE_HIERARCHIES '||
         ' WHERE ENABLED_FLAG = ''Y''  '||
         ' CONNECT BY PRIOR  SUPER_NAME = SUB_NAME  '||
         ' AND  PRIOR        ENABLED_FLAG = ''Y''  '||
         ' START WITH        SUB_NAME in (  '|| l_role_names || ' ) ' ||
         ' union all '||
         ' SELECT NAME '||
         ' FROM WF_ROLES '||
         ' WHERE NAME IN (  '|| l_role_names || ' ) ';


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

      l_func_dynamic_sql :=
          'select count(distinct function_id) from ( '
        ||   l_func_existing_sql
        ||'  UNION ALL '
        ||'  select rcd.function_id '
        ||'  from amw_role_constraint_denorm rcd '
        ||'  where rcd.constraint_rev_id = :5 '
        ||'    and rcd.role_name in ( '||l_sub_role_names||' ) '
        ||') ';

      l_func_set_dynamic_sql :=
          'select count(distinct group_code) from ( '
        ||   l_func_set_existing_sql
        ||'  UNION ALL '
        ||'  select rcd.group_code '
        ||'  from amw_role_constraint_denorm rcd '
        ||'  where rcd.constraint_rev_id = :5 '
        ||'    and rcd.role_name in ( '||l_sub_role_names||' ) '
        ||') ';

        l_resp_dynamic_sql  :=
         'select count(distinct role_orig_system_id) from ( '
        ||   l_resp_existing_sql
        ||'  UNION ALL '
        ||'  select distinct rle.orig_system_id '
        ||'  from  ' || G_AMW_ALL_ROLES_VL || ' rle '
        ||'  , amw_constraint_entries cst '
        ||'  where rle.orig_system = ''FND_RESP'' '
        ||'  and cst.constraint_rev_id = :3 '
        ||'  and cst.function_id = rle.orig_system_id '
        ||'  and rle.name in ( '||l_sub_role_names||' ) '
        ||') ';

         l_resp_set_dynamic_sql :=
          'select count(distinct group_code) from ( '
        ||   l_resp_set_existing_sql
        ||'  UNION ALL '
        ||'  select cst.group_code '
        ||'  from  ' || G_AMW_ALL_ROLES_VL || ' rle '
        ||'  , amw_constraint_entries cst '
        ||'  where rle.orig_system = ''FND_RESP'' '
        ||'  and cst.constraint_rev_id = :3 '
        ||'  and cst.function_id = rle.orig_system_id '
        ||'  and rle.name in ( '||l_sub_role_names||' ) '
        ||') ';

        l_violating_new_roles_sql :=
        'select resp.responsibility_name from fnd_responsibility_vl resp'
        ||' where resp.responsibility_id in ( '
	||' select function_id from amw_constraint_entries cons, wf_roles rl '
	||' where constraint_rev_id = :1 '
        ||' and cons.application_id = resp.application_id '
	||' and cons.function_id = rl.orig_system_id '
        ||' and rl.orig_system = ''FND_RESP'' '
        ||' and rl.name in (' ||l_sub_role_names||' ) '
        ||' and rl.owner_tag = (select application_short_name '
	||' from fnd_application app where app.application_id = resp.application_id)) ';

        l_violating_existing_roles_sql :=
        'select resp.responsibility_name from fnd_responsibility_vl resp'
        ||' where resp.responsibility_id in ( '
	||' select function_id from amw_constraint_entries cons, wf_roles rl '
	||' where constraint_rev_id = :1 '
        ||' and cons.application_id = resp.application_id '
	||' and cons.function_id = rl.orig_system_id '
        ||' and rl.orig_system = ''FND_RESP'' '
        ||' and rl.name not in (' ||l_sub_role_names||' ) '
        ||' and rl.owner_tag = (select application_short_name '
	||' from fnd_application app where app.application_id = resp.application_id)) ';


      IF 'ALL' = l_all_valid_constraints.type_code THEN
        -- find the number of constraint entries(incompatible functions) by specified constraint_rev_id
        OPEN c_constraint_entries_count (l_all_valid_constraints.constraint_rev_id);
        FETCH c_constraint_entries_count INTO l_constraint_entries_count;
        CLOSE c_constraint_entries_count;

        -- 12:16:05 : psomanat
        -- Check to see if violation is due to the allready
        -- assigned violating roles

        -- 5:15:06 by dliao remove because we need check if the new assigned roles violate the constraint
        -- even if the allready assigned violating roles exist.
        /***
        l_vio_exist_role_sql :='select count(distinct function_id)'
            ||'from ('
            ||' select function_id from amw_constraint_entries where constraint_rev_id = :1'
            ||' MINUS '
            ||'select distinct function_id from ( '
            ||   l_func_existing_sql
            ||') '
            ||')';
         ***/

         --add 5:15:06 by dliao
         --check the new roles
        l_cst_new_violation_sql :=
                '  select count(rcd.function_id) '
                ||' from amw_role_constraint_denorm rcd '
                ||'  where rcd.constraint_rev_id = :1 '
                ||'    and rcd.role_name in ( '||l_sub_role_names||' ) ' ;


        OPEN func_acess_count_c FOR l_cst_new_violation_sql USING
            l_all_valid_constraints.constraint_rev_id;
        FETCH func_acess_count_c INTO l_func_access_count;
        CLOSE func_acess_count_c;

        -- If the count is 0 then the violation is due to the allready
        -- assigned violating role.
        IF l_func_access_count > 0 THEN

            OPEN func_acess_count_c FOR l_func_dynamic_sql USING
            l_all_valid_constraints.constraint_rev_id,
            p_user_id,
            l_all_valid_constraints.constraint_rev_id,
            p_user_id,
            l_all_valid_constraints.constraint_rev_id;
            FETCH func_acess_count_c INTO l_func_access_count;
            CLOSE func_acess_count_c;

            -- in ALL type: if user can access to all entries of this constraint,
            -- he violates this constraint
            IF l_func_access_count = l_constraint_entries_count THEN



            -- Check to see if the fuction enteries in the constraint is same
            -- as the functions the user can access due to the assigning of
            -- this role
            l_func_sql :='select count(distinct function_id)'
                    ||'from ('
                    ||'select distinct function_id from ( '
                    ||   l_func_existing_sql
                    ||'  UNION ALL '
                    ||'  select rcd.function_id '
                    ||'  from amw_role_constraint_denorm rcd '
                    ||'  where rcd.constraint_rev_id = :5 '
                    ||'  and rcd.role_name in ( '||l_sub_role_names||' ) '
                    ||') '
                    ||' MINUS '
                    ||' select FUNCTION_ID from amw_constraint_entries where constraint_rev_id = :6'
                    ||')';


                OPEN func_acess_count_c FOR l_func_sql USING
                l_all_valid_constraints.constraint_rev_id,
                p_user_id,
                l_all_valid_constraints.constraint_rev_id,
                p_user_id,
                l_all_valid_constraints.constraint_rev_id,
                l_all_valid_constraints.constraint_rev_id;
                FETCH func_acess_count_c INTO l_func_access_count;
                CLOSE func_acess_count_c;

                IF l_func_access_count = 0 THEN
                 -- once he violates at least one constraint, break the loop and inform FALSE to the caller
                    FND_FILE.put_line(fnd_file.log, '----fail on constraint - ALL = '||l_all_valid_constraints.constraint_rev_id ||' ---------------');
                    x_has_violation := 'Y';
                    EXIT;
                END IF;
            END IF;
        END IF;
      ELSIF 'ME' = l_all_valid_constraints.type_code THEN

        -- 12:16:2005 : psomanat
        -- Check to see if violation is due to the allready
        -- assigned violating roles
        -- 5:15:06 by dliao remove because we need check if the new assigned roles violate the constraint
        -- even if the allready assigned violating roles exist.
        /********************************************************
        l_vio_exist_role_sql :='select count(distinct function_id) from ( '
            ||   l_func_existing_sql
            ||')';

         OPEN func_acess_count_c FOR l_vio_exist_role_sql USING
          l_all_valid_constraints.constraint_rev_id,
          p_user_id,
          l_all_valid_constraints.constraint_rev_id,
          p_user_id,
          l_all_valid_constraints.constraint_rev_id,
          p_user_id,
          l_all_valid_constraints.constraint_rev_id;
        FETCH func_acess_count_c INTO l_func_access_count;
        CLOSE func_acess_count_c;
        ****************************************************/

        --PSOMANAT :23:01:2006
        -- scenario added : The user allready violates a constraint and again
        -- a new violating role is added

        --DLIAO 05:12:2006
        -- remove this condition because l_func_access_count will be 0 if the existing
        -- roles which the user was assigned don't violate any constraint.
        -- IF l_func_access_count >= 1 THEN


            l_cst_new_violation_sql :=
                '  select count(rcd.function_id) '
                ||' from amw_role_constraint_denorm rcd '
                ||'  where rcd.constraint_rev_id = :1 '
                ||'    and rcd.role_name in ( '||l_sub_role_names||' ) ' ;


            -- The cursor checks if the current constraint violation is related
            -- role being added to the user.
            -- This is done to avoid the following problem :
            --      The user may allready have roles violating a differnt constraint
            -- then the one under process. If we don't check to see if the role
            -- assigned is related with the current constraint, there is a possibility
            -- of reporting the existing violation again and again even thought they are
            -- allready assigned.

            OPEN new_violation_count_c FOR l_cst_new_violation_sql USING
                l_all_valid_constraints.constraint_rev_id;
            FETCH new_violation_count_c INTO l_func_access_count;
            CLOSE new_violation_count_c;

            -- If the function count is > 0 then the violation is due to
            -- the current constraint.
            -- If not then the violation is due to some other constraint.
            -- So we need to continue to find the correct constraint
            IF l_func_access_count > 0 THEN

               -- find the number of distinct constraint entries this user can access
                OPEN func_acess_count_c FOR l_func_dynamic_sql USING
                    l_all_valid_constraints.constraint_rev_id,
                    p_user_id,
                    l_all_valid_constraints.constraint_rev_id,
                    p_user_id,
                    l_all_valid_constraints.constraint_rev_id;
                FETCH func_acess_count_c INTO l_func_access_count;
                CLOSE func_acess_count_c;

                -- in ME type: if user can access at least two entries of this constraint,
                -- he violates this constraint
                IF l_func_access_count >= 2 THEN
                    -- once he violates at least one constraint, break the loop and inform FALSE to the caller
                    FND_FILE.put_line(fnd_file.log,'------------ fail on constraint - ME = '||l_all_valid_constraints.constraint_rev_id ||' ---------------');
                    x_has_violation := 'Y';
                    exit;
                END IF;
            END IF;

      ELSIF 'SET' = l_all_valid_constraints.type_code THEN
        -- 12:16:2005 : psomanat
        -- Check to see if violation is due to the allready
        -- assigned violating roles
        -- 5:15:06 by dliao remove because we need check if the new assigned roles violate the constraint
        -- even if the allready assigned violating roles exist.
        /******************************************
        l_vio_exist_role_sql :='select count(distinct group_code) from ( '
            ||  l_func_set_existing_sql
            ||  ') ';
        OPEN group_acess_count_c FOR l_vio_exist_role_sql USING
          l_all_valid_constraints.constraint_rev_id,
          p_user_id,
          l_all_valid_constraints.constraint_rev_id,
          p_user_id,
          l_all_valid_constraints.constraint_rev_id,
          p_user_id,
          l_all_valid_constraints.constraint_rev_id;
        FETCH group_acess_count_c INTO l_group_access_count;
        CLOSE group_acess_count_c;
        *********************************************/

        -- PSOMANAT :23:01:2006
        -- scenario added : The user allready violates a constraint and again
        -- a new violating role is added
         --DLIAO 05:12:2006
        -- remove this condition because l_func_access_count will be 0 if the existing
        -- roles which the user was assigned don't violate any constraint.

        --IF l_group_access_count >= 1 THEN

            l_cst_new_violation_sql :=
                '  select count( distinct rcd.group_code) '
                ||' from amw_role_constraint_denorm rcd '
                ||'  where rcd.constraint_rev_id = :1 '
                ||'    and rcd.role_name in ( '||l_sub_role_names||' ) ' ;

            -- The cursor checks if the current constraint violation is related
            -- role being added to the user.
            -- This is done to avoid the following problem :
            --      The user may allready have roles violating a differnt constraint
            -- then the one under process. If we don't check to see if the role
            -- assigned is related with the current constraint, there is a possibility
            -- of reporting the existing violation again and again even thought they are
            -- allready assigned.

            OPEN new_violation_count_c FOR l_cst_new_violation_sql USING
                l_all_valid_constraints.constraint_rev_id;
            FETCH new_violation_count_c INTO l_group_access_count;
            CLOSE new_violation_count_c;

            -- If the group access count is > 0 then the violation is due to
            -- the current constraint.
            -- If not then the violation is due to some other constraint.
            -- So we need to continue to find the correct constraint
            IF l_group_access_count > 0 THEN
                -- find the number of distinct constraint entries this user can access
                OPEN group_acess_count_c FOR l_func_set_dynamic_sql USING
                    l_all_valid_constraints.constraint_rev_id,
                    p_user_id,
                    l_all_valid_constraints.constraint_rev_id,
                    p_user_id,
                    l_all_valid_constraints.constraint_rev_id;
                FETCH group_acess_count_c INTO l_group_access_count;
                CLOSE group_acess_count_c;


                -- in SET type: if user can access at least two distinct groups(set) of this constraint,
                -- he violates this constraint
                IF l_group_access_count >= 2 THEN
                    -- once he violates at least one constraint, break the loop and inform FALSE to the caller
                    FND_FILE.put_line(fnd_file.log,'------------ fail on constraint - SET = '||l_all_valid_constraints.constraint_rev_id ||' ---------------');
                    x_has_violation := 'Y';
                END IF;
            END IF;

        ELSIF 'RESPALL' = l_all_valid_constraints.type_code THEN

        -- find the number of constraint entries(incompatible functions) by specified constraint_rev_id
        OPEN c_constraint_entries_count (l_all_valid_constraints.constraint_rev_id);
        FETCH c_constraint_entries_count INTO l_constraint_entries_count;
        CLOSE c_constraint_entries_count;

        -- Check to see if violation is due to the allready
        -- assigned violating roles
        l_vio_exist_resp_sql :='select count(distinct function_id)'
            ||'from ('
            ||' select function_id from amw_constraint_entries where constraint_rev_id = :1'
            ||' MINUS '
            ||'select distinct role_orig_system_id from ( '
            ||   l_resp_existing_sql
            ||') '
            ||')';

        OPEN resp_acess_count_c FOR l_vio_exist_resp_sql USING
            l_all_valid_constraints.constraint_rev_id,
            p_user_id,
            l_all_valid_constraints.constraint_rev_id;
        FETCH resp_acess_count_c INTO l_resp_access_count;
        CLOSE resp_acess_count_c;


        -- If the count is 0 then the violation is due to the allready
        -- assigned violating role.
        IF l_resp_access_count <> 0 THEN

            OPEN resp_acess_count_c FOR l_resp_dynamic_sql USING
            p_user_id,
            l_all_valid_constraints.constraint_rev_id,
            l_all_valid_constraints.constraint_rev_id;
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
             ||   l_resp_existing_sql
             ||'  UNION ALL '
             ||'  select distinct rle.orig_system_id  as role_orig_system_id '
             ||'  from  ' || G_AMW_ALL_ROLES_VL || ' rle '
             ||'  , amw_constraint_entries cst '
             ||'  where rle.orig_system = ''FND_RESP'' '
             ||'  and cst.constraint_rev_id = :3 '
             ||'  and cst.function_id = rle.orig_system_id '
             ||'  and rle.name in ( '||l_sub_role_names||' ) '
             ||' MINUS '
             ||' select FUNCTION_ID from amw_constraint_entries where constraint_rev_id = :4'
             ||')';



                OPEN resp_acess_count_c FOR l_resp_sql USING
                p_user_id,
                l_all_valid_constraints.constraint_rev_id,
                l_all_valid_constraints.constraint_rev_id,
                l_all_valid_constraints.constraint_rev_id;
                FETCH resp_acess_count_c INTO l_resp_access_count;
                CLOSE resp_acess_count_c;

                IF l_resp_access_count = 0 THEN
                 -- once he violates at least one constraint, break the loop and inform FALSE to the caller
                    FND_FILE.put_line(fnd_file.log, '----fail on constraint - ALL = '||l_all_valid_constraints.constraint_rev_id ||' ---------------');
                    x_has_violation := 'Y';

                 OPEN violating_new_resps_c FOR l_violating_new_roles_sql USING
                 l_all_valid_constraints.constraint_rev_id;
		 FETCH violating_new_resps_c BULK COLLECT INTO l_violating_new_resp_table;
    		 CLOSE violating_new_resps_c;

    		 OPEN violating_old_resps_c FOR l_violating_existing_roles_sql USING
                 l_all_valid_constraints.constraint_rev_id;
		 FETCH violating_old_resps_c BULK COLLECT INTO l_violating_old_resp_table;
    		 CLOSE violating_old_resps_c;

    		  IF l_violating_new_resp_table IS NOT NULL AND l_violating_new_resp_table.FIRST IS NOT NULL THEN
    		 	x_new_resp_name := l_violating_new_resp_table(1);
      			FOR i in 2 .. l_violating_new_resp_table.COUNT
      			LOOP
        		   x_new_resp_name := x_new_resp_name ||','|| l_violating_new_resp_table(i);
      			END LOOP;
    		END IF; -- end of if: l_violating_new_resp_table IS NOT NULL

    		 IF l_violating_old_resp_table IS NOT NULL AND l_violating_old_resp_table.FIRST IS NOT NULL THEN
    		 	x_existing_resp_name := '''' || l_violating_old_resp_table(1);
      			FOR j in 2 .. l_violating_old_resp_table.COUNT
      			LOOP
      			 x_existing_resp_name := x_existing_resp_name ||','|| l_violating_old_resp_table(j);
      			END LOOP;
      			x_existing_resp_name := x_existing_resp_name || '''';
    		END IF; -- end of if: l_violating_old_resp_table IS NOT NULL

                    EXIT;
                END IF;
            END IF;
        END IF;

        ELSIF 'RESPME' = l_all_valid_constraints.type_code THEN

        -- Check to see if violation is due to the allready
        -- assigned violating roles
       /*********************
        l_vio_exist_resp_sql :='select count(distinct role_orig_system_id)'
            ||'from ('
            ||   l_resp_existing_sql
            ||')';

        OPEN resp_acess_count_c FOR l_vio_exist_resp_sql USING
            p_user_id,
            l_all_valid_constraints.constraint_rev_id;
        FETCH resp_acess_count_c INTO l_resp_access_count;
        CLOSE resp_acess_count_c;

        *********************/

        -- scenario added : The user allready violates a constraint and again
        -- a new violating role is added
        -- remove this condition because l_resp_access_count will be 0 if the existing
        -- roles which the user is assigned don't violate any constraint.
       -- IF l_resp_access_count >= 1 THEN


            l_cst_new_violation_sql :=
             '  select distinct rle.display_name '
             ||'  from  ' || G_AMW_ALL_ROLES_VL || ' rle '
             ||'  , amw_constraint_entries cst '
             ||'  where rle.orig_system = ''FND_RESP'' '
             ||'  and cst.constraint_rev_id = :1 '
             ||'  and cst.function_id = rle.orig_system_id '
             ||'  and rle.name in ( '||l_sub_role_names||' ) '
             ||'  and rle.owner_tag = (select application_short_name '
             ||'  from fnd_application app where app.application_id = cst.application_id)';


            -- The cursor checks if the current constraint violation is related
            -- role being added to the user.
            -- This is done to avoid the following problem :
            --      The user may allready have roles violating a differnt constraint
            -- then the one under process. If we don't check to see if the role
            -- assigned is related with the current constraint, there is a possibility
            -- of reporting the existing violation again and again even thought they are
            -- allready assigned.

            OPEN new_violation_count_c FOR l_cst_new_violation_sql USING
                l_all_valid_constraints.constraint_rev_id;
            FETCH new_violation_count_c BULK COLLECT INTO l_new_violation_table;
            CLOSE new_violation_count_c;

            l_existing_violation_sql :=
               '  select distinct rle.display_name '
               ||'  from '
               || G_AMW_USER_ROLES||' ur '
               ||'      ,'||G_AMW_user||' u '
               ||'      ,amw_constraint_entries cst '
               ||'      ,'||G_AMW_USER_ROLE_ASSIGNMENTS_V || ' uar '
               ||'      ,'||G_AMW_ALL_ROLES_VL || ' rle '
               ||'  where  u.user_id = :1 '
               ||'    and  cst.constraint_rev_id = :2 '
               ||'    and u.user_name = ur.user_name '
               ||'    and ur.role_orig_system_id = cst.function_id '
               ||'    and ur.role_orig_system = ''FND_RESP'' '
               ||'    and ur.role_orig_system = rle.orig_system '
               ||'    and ur.role_orig_system_id = rle.orig_system_id '
               ||'    and ur.role_name = rle.name '
               ||'    and rle.owner_tag = (select application_short_name '
               ||'    from fnd_application app where app.application_id = cst.application_id) '
               ||'    and uar.user_name = ur.user_name '
               ||'    and uar.role_name = ur.role_name '
               ||'    and uar.start_date <= sysdate '
               ||'    and (uar.end_date is null or uar.end_date >= sysdate) '
               ||     l_sub_revoked_role_names ;



            OPEN existing_violation_c FOR l_existing_violation_sql USING
                p_user_id,
                l_all_valid_constraints.constraint_rev_id;
            FETCH existing_violation_c BULK COLLECT INTO l_existing_violation_table;
            CLOSE existing_violation_c;

            -- If the function count is > 0 then the violation is due to
            -- the current constraint.
            -- If not then the violation is due to some other constraint.
            -- So we need to continue to find the correct constraint
            -- in ME type: if user can access at least two entries of this constraint,
            -- he violates this constraint

            IF ( l_new_violation_table.COUNT > 0) AND (l_existing_violation_table.COUNT +  l_new_violation_table.COUNT >= 2) THEN

            -- Check to see if the fuction enteries in the constraint is same
            -- as the functions the user can access due to the assigning of
            -- this role

            l_resp_sql := 'select count(distinct role_orig_system_id)'
             ||' from ('
             ||   l_resp_existing_sql
             ||'  UNION ALL '
             ||'  select distinct rle.orig_system_id  as role_orig_system_id '
             ||'  from  ' || G_AMW_ALL_ROLES_VL || ' rle '
             ||'  , amw_constraint_entries cst '
             ||'  where rle.orig_system = ''FND_RESP'' '
             ||'  and cst.constraint_rev_id = :3 '
             ||'  and cst.function_id = rle.orig_system_id '
             ||'  and rle.name in ( '||l_sub_role_names||' ) '
             ||'  and rle.owner_tag = (select application_short_name '
             ||'  from fnd_application app where app.application_id = cst.application_id)'
             ||' MINUS '
             ||' select FUNCTION_ID from amw_constraint_entries where constraint_rev_id = :4'
             ||')';


                -- find the number of distinct constraint entries this user can access

                OPEN resp_acess_count_c FOR l_resp_sql USING
                p_user_id,
                l_all_valid_constraints.constraint_rev_id,
                l_all_valid_constraints.constraint_rev_id,
                l_all_valid_constraints.constraint_rev_id;
                FETCH resp_acess_count_c INTO l_resp_access_count;
                CLOSE resp_acess_count_c;



                IF l_resp_access_count = 0 THEN
                    -- once he violates at least one constraint, break the loop and inform FALSE to the caller
                    FND_FILE.put_line(fnd_file.log,'------------ fail on constraint - ME = '||l_all_valid_constraints.constraint_rev_id ||' ---------------');
                    x_has_violation := 'Y';

                     IF l_new_violation_table IS NOT NULL AND l_new_violation_table.FIRST IS NOT NULL THEN
    		 	x_new_resp_name := l_new_violation_table(1);
      			FOR i in 2 .. l_new_violation_table.COUNT
      			LOOP
        		   x_new_resp_name := x_new_resp_name ||','|| l_new_violation_table(i);
      			END LOOP;
    		   END IF; -- end of if: l_new_violation_table IS NOT NULL

    		 IF l_existing_violation_table IS NOT NULL AND l_existing_violation_table.FIRST IS NOT NULL THEN
    		 	x_existing_resp_name := '''' || l_existing_violation_table(1);
      			FOR j in 2 .. l_existing_violation_table.COUNT
      			LOOP
        		  x_existing_resp_name := x_existing_resp_name ||','|| l_existing_violation_table(j);
      			END LOOP;
      			x_existing_resp_name := x_existing_resp_name || '''';
    		END IF; -- end of if: l_existing_violation_table IS NOT NULL

                    exit;
                END IF;
            END IF;
        --END IF;

      ELSIF 'RESPSET' = l_all_valid_constraints.type_code THEN

        -- Check to see if violation is due to the allready
        -- assigned violating roles
        -- 5:15:06 by dliao remove because we need check if the new assigned roles violate the constraint
        -- even if the allready assigned violating roles exist.
        /***********************************************
        l_vio_exist_resp_sql :='select count(distinct role_orig_system_id)'
            ||'from ('
            ||'select distinct role_orig_system_id from ( '
            ||   l_resp_existing_sql
            ||') '
            ||')';


        OPEN group_acess_count_c FOR l_vio_exist_resp_sql USING
          p_user_id,
          l_all_valid_constraints.constraint_rev_id;
        FETCH group_acess_count_c INTO l_group_access_count;
        CLOSE group_acess_count_c;

        *****************************************************/

        -- scenario added : The user allready violates a constraint and again
        -- a new violating role is added
	--IF l_group_access_count >= 1 THEN

	l_cst_new_violation_sql :=
             '  select distinct rle.display_name '
             ||'  from  ' || G_AMW_ALL_ROLES_VL || ' rle '
             ||'  , amw_constraint_entries cst '
             ||'  where rle.orig_system = ''FND_RESP'' '
             ||'  and cst.constraint_rev_id = :1 '
             ||'  and cst.function_id = rle.orig_system_id '
             ||'  and rle.name in ( '||l_sub_role_names||' ) '
             ||'  and rle.owner_tag = (select application_short_name '
             ||'  from fnd_application app where app.application_id = cst.application_id)';

            -- The cursor checks if the current constraint violation is related
            -- role being added to the user.
            -- This is done to avoid the following problem :
            --      The user may allready have roles violating a differnt constraint
            -- then the one under process. If we don't check to see if the role
            -- assigned is related with the current constraint, there is a possibility
            -- of reporting the existing violation again and again even thought they are
            -- allready assigned.


            OPEN new_violation_count_c FOR l_cst_new_violation_sql USING
                l_all_valid_constraints.constraint_rev_id;
            FETCH new_violation_count_c BULK COLLECT INTO l_new_violation_table;
            CLOSE new_violation_count_c;

	   l_existing_violation_sql :=
               '  select distinct rle.display_name '
               ||'  from '
               || G_AMW_USER_ROLES||' ur '
               ||'      ,'||G_AMW_user||' u '
               ||'      ,amw_constraint_entries cst '
               ||'      ,'||G_AMW_USER_ROLE_ASSIGNMENTS_V || ' uar '
               ||'      ,'||G_AMW_ALL_ROLES_VL || ' rle '
               ||'  where  u.user_id = :1 '
               ||'    and  cst.constraint_rev_id = :2 '
               ||'    and u.user_name = ur.user_name '
               ||'    and ur.role_orig_system_id = cst.function_id '
               ||'    and ur.role_orig_system = ''FND_RESP'' '
               ||'    and ur.role_orig_system = rle.orig_system '
               ||'    and ur.role_orig_system_id = rle.orig_system_id '
               ||'    and ur.role_name = rle.name '
               ||'    and rle.owner_tag = (select application_short_name '
               ||'    from fnd_application app where app.application_id = cst.application_id) '
               ||'    and uar.user_name = ur.user_name '
               ||'    and uar.role_name = ur.role_name '
               ||'    and uar.start_date <= sysdate '
               ||'    and (uar.end_date is null or uar.end_date >= sysdate) '
               ||     l_sub_revoked_role_names ;



            OPEN existing_violation_c FOR l_existing_violation_sql USING
                p_user_id,
                l_all_valid_constraints.constraint_rev_id;
            FETCH existing_violation_c BULK COLLECT INTO l_existing_violation_table;
            CLOSE existing_violation_c;





            -- If the function count is > 0 then the violation is due to
            -- the current constraint.
            -- If not then the violation is due to some other constraint.
            -- So we need to continue to find the correct constraint
            IF l_new_violation_table.COUNT > 0 THEN

              -- find the number of distinct constraint entries this user can access

                OPEN resp_acess_count_c FOR l_resp_set_dynamic_sql USING
                p_user_id,
                l_all_valid_constraints.constraint_rev_id,
                l_all_valid_constraints.constraint_rev_id;
                FETCH resp_acess_count_c INTO l_resp_access_count;
                CLOSE resp_acess_count_c;

                -- in SET type: if user can access at least two distinct groups(set) of this constraint,
                -- he violates this constraint
                IF l_resp_access_count >= 2 THEN
                    -- once he violates at least one constraint, break the loop and inform FALSE to the caller
                    FND_FILE.put_line(fnd_file.log,'------------ fail on constraint - SET = '||l_all_valid_constraints.constraint_rev_id ||' ---------------');
                    x_has_violation := 'Y';


                     IF l_new_violation_table IS NOT NULL AND l_new_violation_table.FIRST IS NOT NULL THEN
    		 	x_new_resp_name := l_new_violation_table(1);
      			FOR i in 2 .. l_new_violation_table.COUNT
      			LOOP
        		   x_new_resp_name := x_new_resp_name ||','|| l_new_violation_table(i);
      			END LOOP;
    		   END IF; -- end of if: l_new_violation_table IS NOT NULL

    		 IF l_existing_violation_table IS NOT NULL AND l_existing_violation_table.FIRST IS NOT NULL THEN
    		 	x_existing_resp_name := '''' || l_existing_violation_table(1);
      			FOR j in 2 .. l_existing_violation_table.COUNT
      			LOOP
        		   x_existing_resp_name := x_existing_resp_name ||','|| l_existing_violation_table(j);
      			END LOOP;
      			x_existing_resp_name := x_existing_resp_name || '''';
    		END IF; -- end of if: l_existing_violation_table IS NOT NULL


                    EXIT;
                END IF;
            END IF;
      ELSE
        -- other constraint types
        NULL;
      END IF; -- end of if: constraint type_code
     END IF; -- end of if: l_valid_user_waiver_count <= 0
    END LOOP; --end of loop: c_all_valid_constraints
    CLOSE c_all_valid_constraints;

  END IF; -- end of if: p_user_id IS NOT NULL AND p_responsibility_id IS NOT NULL AND p_role_names IS NOT NULL AND p_role_names.FIRST IS NOT NULL
  -- only output valid region name if having violation; otherwise, NULL

  IF x_has_violation = 'Y' THEN
    x_violat_region := '/oracle/apps/amw/audit/duty/webui/RoleAssignViolationRN';
    x_violat_btn_region := '/oracle/apps/amw/audit/duty/webui/RoleAssignViolationOverrideBtnRN';
  END IF;
exception
    when others then
            dbms_output.put_line('exception');
END Has_Violations;



-- ===============================================================
-- Function name
--          Has_Violation_Due_To_Resp
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
Function Has_Violation_Due_To_Resp (
    p_user_id               IN  NUMBER,
    p_responsibility_id     IN  NUMBER
) return VARCHAR2
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Has_Violation_Due_To_Resp';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

-- return result
has_violation VARCHAR2(32767);

-- find all valid constraints
CURSOR c_all_valid_constraints IS
      SELECT constraint_rev_id, type_code, objective_code
        FROM amw_constraints_b
       WHERE start_date <= sysdate AND (end_date IS NULL OR end_date >= sysdate);
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

-- get valid user waiver
l_valid_user_waiver_count NUMBER;
CURSOR c_valid_user_waivers (l_constraint_rev_id IN NUMBER, l_user_id IN NUMBER) IS
    SELECT count(*)
      FROM amw_constraint_waivers
     WHERE constraint_rev_id = l_constraint_rev_id
       AND object_type = 'USER'
       AND PK1 = l_user_id
       AND start_date <= sysdate AND (end_date >= sysdate or end_date is null);

BEGIN
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

     -- 08.22.2005 tsho: consider only Prevent Constraint Objective
	 -- IF l_valid_user_waiver_count <= 0 THEN
	 IF l_valid_user_waiver_count <= 0 AND l_all_valid_constraints.objective_code = 'PR' THEN

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
          has_violation := 'Y';
          return has_violation;
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

  return has_violation;

END Has_Violation_Due_To_Resp;



-- ===============================================================
-- Private Procedure name
--          Clear_List
--
-- Purpose
--          to clear the global list:
--              G_FUNCTION_ID_LIST
--              G_MENU_ID_LIST
--              G_RESPONSIBILITY_ID_LIST
--              G_ROLE_NAME_LIST
--              G_ENTRY_OBJECT_TYPE_LIST
--              G_GROUP_CODE_LIST
--
-- ===============================================================
PROCEDURE Clear_List
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Clear_List';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);
    G_ROLE_NAME_LIST.DELETE();
    G_RESPONSIBILITY_ID_LIST.DELETE();
    G_MENU_ID_LIST.DELETE();
    G_FUNCTION_ID_LIST.DELETE();
    G_ENTRY_OBJECT_TYPE_LIST.DELETE();
    G_GROUP_CODE_LIST.DELETE();
    G_PV_COUNT  := 1;

    G_ROLE_NAME_LIST_HIER.DELETE();
    G_RESPONSIBILITY_ID_LIST_HIER.DELETE();
    G_MENU_ID_LIST_HIER.DELETE();
    G_FUNCTION_ID_LIST_HIER.DELETE();
    G_ENTRY_OBJECT_TYPE_LIST_HIER.DELETE();
    G_GROUP_CODE_LIST_HIER.DELETE();
    G_PV_COUNT_HIER  := 1;


END Clear_List;


-- ===============================================================
-- Private Function name
--          PROCESS_MENU_TREE_DOWN_FOR_MN
--
-- Purpose
--          Plow through the menu tree, processing exclusions and figuring
--          out which functions are accessible.
--
--          This routine processes the menu hierarchy and exclusion rules in PL/SQL
--          rather than in the database.
--          The basic algorithm of this routine is:
--          Populate the list of exclusions by selecting from FND_RESP_FUNCTIONS
--          menulist(1) = p_menu_id
--          while (elements on menulist)
--          {
--              Remove first element off menulist
--              if this menu is not excluded with a menu exclusion rule
--              {
--                  Query all menu entry children of current menu
--                  for (each child) loop
--                  {
--                      If it's excluded by a func exclusion rule, go on to the next one.
--                      If we've got the function we're looking for,
--                        and grant_flag = Y, we're done- return TRUE;
--                      If it's got a sub_menu_id, add it to the end of menulist
--                        to be processed
--                  }
--                  Move to next element on menulist
--              }
--          }
--
-- Params
--          p_menu_id           := menu_id
--          p_function_id       := function to check for
--
--          Don't pass values for the following two params if you don't want
--          exclusions processed.
--          p_appl_id           := application id of resp
--          p_resp_id           := responsibility id
--
--          p_access_given_date := start_date of user resp  (added for AMW)
--          p_access_given_by   := created_by of user resp  (added for AMW)
--
-- Return
--          True    := function accessible
--          False   := function not accessible
--
-- Notes
--          copy from FND_FUNCTION.PROCESS_MENU_TREE_DOWN_FOR_MN (AFSCFNSB.pls 115.51 2003/08/01)
--          and modify for AMW to use dynamic sql
--
--          12.21.2004 tsho: set default NULL for p_access_given_date, p_access_given_by
--          12.21.2004 tsho: fix for performance bug 4036679
-- History
--          05.24.2005 tsho: AMW.E Incompatible Sets,
--          need to pass in amw_constraint_entries.group_code for each item
-- ===============================================================
FUNCTION PROCESS_MENU_TREE_DOWN_FOR_MN(
  p_menu_id     in number,
  p_function_id in number,
  p_appl_id     in number,
  p_resp_id     in number,
  p_role_name   in varchar2 := NULL,
  p_entry_object_type_list  in varchar2 := NULL,
  p_group_code              in varchar2 := NULL
) RETURN boolean
IS

  L_API_NAME                  CONSTANT VARCHAR2(30) := 'PROCESS_MENU_TREE_DOWN_FOR_MN';
  L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

  l_sub_menu_id number;

  /* Table to store the list of submenus that we are looking for */
  TYPE MENULIST_TYPE is table of NUMBER INDEX BY BINARY_INTEGER;
  MENULIST  MENULIST_TYPE;

  TYPE NUMBER_TABLE_TYPE is table of NUMBER INDEX BY BINARY_INTEGER;
  TYPE VARCHAR2_TABLE_TYPE is table of VARCHAR2(1) INDEX BY BINARY_INTEGER;

  /* The table of exclusions.  The index in is the action_id, and the */
  /* value stored in each element is the rule_type.*/
  EXCLUSIONS VARCHAR2_TABLE_TYPE;

  /* Returns from the bulk collect (fetches) */
  TBL_MENU_ID NUMBER_TABLE_TYPE;
  TBL_ENT_SEQ NUMBER_TABLE_TYPE;
  TBL_FUNC_ID NUMBER_TABLE_TYPE;
  TBL_SUBMNU_ID NUMBER_TABLE_TYPE;
  TBL_GNT_FLG VARCHAR2_TABLE_TYPE;

  /* Cursor to get exclusions */
  TYPE exclCurTyp IS REF CURSOR;
  excl_c exclCurTyp;
  l_excl_rule_type     VARCHAR2(30);
  l_excl_action_id     NUMBER;
  l_excl_dynamic_sql   VARCHAR2(200)  :=
        'SELECT RULE_TYPE, ACTION_ID '
      ||'  FROM '||G_AMW_RESP_FUNCTIONS
      ||' WHERE application_id = :1 '
      ||'   AND responsibility_id = :2 ';

  /* Cursor to get menu entries on a particular menu.*/
  TYPE mnesCurTyp IS REF CURSOR;
  get_mnes_c mnesCurTyp;
  l_mnes_menu_id        NUMBER;
  l_mnes_entry_sequence NUMBER;
  l_mnes_function_id    NUMBER;
  l_mnes_sub_menu_id    NUMBER;
  l_mnes_grant_flag     VARCHAR2(1);
  l_mnes_dynamic_sql   VARCHAR2(200)  :=
        'SELECT MENU_ID, ENTRY_SEQUENCE, FUNCTION_ID, SUB_MENU_ID, GRANT_FLAG '
      ||'  FROM '||G_AMW_MENU_ENTRIES
      ||' WHERE menu_id  = :1 ';

  menulist_cur pls_integer;
  menulist_size pls_integer;

  entry_excluded boolean;
  last_index pls_integer;
  i number;
  z number;

BEGIN
  --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

  if(p_appl_id is not NULL) then
    /* Select the list of exclusion rules into our cache */
    OPEN excl_c FOR l_excl_dynamic_sql USING
        p_appl_id,
        p_resp_id;
    LOOP
        FETCH excl_c INTO l_excl_rule_type, l_excl_action_id;
        EXIT WHEN excl_c%NOTFOUND;
        EXCLUSIONS(l_excl_action_id) := l_excl_rule_type;
    END LOOP;
    CLOSE excl_c;

  end if;

  -- Initialize menulist working list to parent menu
  menulist_cur := 0;
  menulist_size := 1;
  menulist(0) := p_menu_id;

  -- Continue processing until reach the end of list
  while (menulist_cur < menulist_size) loop
    -- Check if recursion limit exceeded
    if (menulist_cur > C_MAX_MENU_ENTRIES) then
      /* If the function were accessible from this menu, then we should */
      /* have found it before getting to this point, so we are confident */
      /* that the function is not on this menu. */
      return FALSE;
    end if;

    l_sub_menu_id := menulist(menulist_cur);

    -- See whether the current menu is excluded or not.
    entry_excluded := FALSE;
    begin
      if(    (l_sub_menu_id is not NULL)
         and (exclusions(l_sub_menu_id) = 'M')) then
        entry_excluded := TRUE;
      end if;
    exception
      when no_data_found then
        null;
    end;

    if (entry_excluded) then
      last_index := 0; /* Indicate that no rows were returned */
    else
      /* This menu isn't excluded, so find out whats entries are on it. */
      if (G_BULK_COLLECTS_SUPPORTED='TRUE') then
        open get_mnes_c for l_mnes_dynamic_sql USING
            l_sub_menu_id;

        fetch get_mnes_c bulk collect into tbl_menu_id, tbl_ent_seq,
             tbl_func_id, tbl_submnu_id, tbl_gnt_flg;
        close get_mnes_c;

        -- See if we found any rows. If not set last_index to zero.
        begin
          if((tbl_menu_id.FIRST is NULL) or (tbl_menu_id.FIRST <> 1)) then
            last_index := 0;
          else
            if (tbl_menu_id.FIRST is not NULL) then
              last_index := tbl_menu_id.LAST;
            else
              last_index := 0;
            end if;
          end if;
        exception
          when others then
            last_index := 0;
        end;
      else
        z:= 0;
        OPEN get_mnes_c FOR l_mnes_dynamic_sql USING
            l_sub_menu_id;
        LOOP
            FETCH get_mnes_c INTO l_mnes_menu_id,
                                  l_mnes_entry_sequence,
                                  l_mnes_function_id,
                                  l_mnes_sub_menu_id,
                                  l_mnes_grant_flag;
            EXIT WHEN get_mnes_c%NOTFOUND;
            tbl_menu_id(z) := l_mnes_menu_id;
            tbl_ent_seq(z) := l_mnes_entry_sequence;
            tbl_func_id(z) := l_mnes_function_id;
            tbl_submnu_id (z):= l_mnes_sub_menu_id;
            tbl_gnt_flg(z) := l_mnes_grant_flag;
        END LOOP;
        CLOSE get_mnes_c;

        last_index := z;
      end if;

    end if; /* entry_excluded */

    -- Process each of the child entries fetched
    for i in 1 .. last_index loop
      -- Check if there is an exclusion rule for this entry
      entry_excluded := FALSE;
      begin
        if(    (tbl_func_id(i) is not NULL)
           and (exclusions(tbl_func_id(i)) = 'F')) then
          entry_excluded := TRUE;
        end if;
      exception
        when no_data_found then
          null;
      end;

      -- Skip this entry if it's excluded
      if (not entry_excluded) then
        -- Check if this is a matching function.  If so, return success.
        if(    (tbl_func_id(i) = p_function_id)
           and (tbl_gnt_flg(i) = 'Y'))
        then
          G_ROLE_NAME_LIST(G_PV_COUNT)           := p_role_name;
          G_MENU_ID_LIST(G_PV_COUNT)             := tbl_menu_id(i);
          G_FUNCTION_ID_LIST(G_PV_COUNT)         := p_function_id;
          G_RESPONSIBILITY_ID_LIST(G_PV_COUNT)   := p_resp_id;
          G_ENTRY_OBJECT_TYPE_LIST(G_PV_COUNT)   := p_entry_object_type_list;
          G_GROUP_CODE_LIST(G_PV_COUNT)          := p_group_code; -- 05.24.2005 tsho: AMW.E Incompatible Sets
          G_PV_COUNT := G_PV_COUNT +1;
          return TRUE;
        end if;

        -- If this is a submenu, then add it to the end of the
        -- working list for processing.
        if (tbl_submnu_id(i) is not NULL) then
          menulist(menulist_size) := tbl_submnu_id(i);
          menulist_size := menulist_size + 1;
        end if;
      end if; -- End if not excluded
    end loop;  -- For loop processing child entries

    -- Advance to next menu on working list
    menulist_cur := menulist_cur + 1;
  end loop;

  -- We couldn't find the function anywhere, so it's not available
  return FALSE;

END PROCESS_MENU_TREE_DOWN_FOR_MN;




-- ===============================================================
-- Private Procedure name
--          BUILD_ROLE_AND_RESP_HIER
--
-- Purpose
--          Plow through the role/resp hierarchy
-- History
--          05.23.2006 dliao created
-- ===============================================================
PROCEDURE BUILD_ROLE_AND_RESP_HIER(
P_ROLE_NAME_LIST_HIER          in   G_VARCHAR2_LONG_TABLE,
P_RESPONSIBILITY_ID_LIST_HIER   in G_NUMBER_TABLE,
P_MENU_ID_LIST_HIER           in G_NUMBER_TABLE,
P_FUNCTION_ID_LIST_HIER       in  G_NUMBER_TABLE,
P_ENTRY_OBJECT_TYPE_LIST_HIER  in G_VARCHAR2_CODE_TABLE,
P_GROUP_CODE_LIST_HIER          in G_VARCHAR2_CODE_TABLE
)
IS

  L_API_NAME                  CONSTANT VARCHAR2(30) := 'BUILD_ROLE_AND_RESP_HIER';
  L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

p_superiors WF_ROLE_HIERARCHY.RELTAB;
p_subordinates WF_ROLE_HIERARCHY.RELTAB;

BEGIN

G_ROLE_NAME_LIST_HIER := P_ROLE_NAME_LIST_HIER;
G_RESPONSIBILITY_ID_LIST_HIER := P_RESPONSIBILITY_ID_LIST_HIER;
G_MENU_ID_LIST_HIER    := P_MENU_ID_LIST_HIER;
G_FUNCTION_ID_LIST_HIER    := P_FUNCTION_ID_LIST_HIER;
G_ENTRY_OBJECT_TYPE_LIST_HIER   := P_ENTRY_OBJECT_TYPE_LIST_HIER;
G_GROUP_CODE_LIST_HIER       := P_GROUP_CODE_LIST_HIER;

G_PV_COUNT_HIER := P_FUNCTION_ID_LIST_HIER.COUNT;


	FOR i IN 1 .. P_FUNCTION_ID_LIST_HIER.COUNT LOOP
	wf_role_hierarchy.getrelationships(P_ROLE_NAME_LIST_HIER(i),p_superiors,p_subordinates,'SUBORDINATES');

  	IF p_subordinates.count > 0 THEN
    		FOR k IN p_subordinates.first..p_subordinates.last LOOP
      		IF p_subordinates.exists(k) THEN

      		     G_PV_COUNT_HIER := G_PV_COUNT_HIER + 1;

      		G_ROLE_NAME_LIST_HIER(G_PV_COUNT_HIER) := p_subordinates(k).sub_name  ;
		G_RESPONSIBILITY_ID_LIST_HIER(G_PV_COUNT_HIER) :=   P_RESPONSIBILITY_ID_LIST_HIER(i);
		G_MENU_ID_LIST_HIER(G_PV_COUNT_HIER) :=  P_MENU_ID_LIST_HIER(i);
		G_FUNCTION_ID_LIST_HIER(G_PV_COUNT_HIER) :=  P_FUNCTION_ID_LIST_HIER(i);
		G_ENTRY_OBJECT_TYPE_LIST_HIER(G_PV_COUNT_HIER) :=  P_ENTRY_OBJECT_TYPE_LIST_HIER(i);
		G_GROUP_CODE_LIST_HIER(G_PV_COUNT_HIER) :=   P_GROUP_CODE_LIST_HIER(i);

      		END IF;
    		END LOOP;-- end of p_subordinates

 	 END IF;


	END LOOP; -- end of P_FUNCTION_ID_LIST_HIER

EXCEPTION
    WHEN others then
        RAISE;
END BUILD_ROLE_AND_RESP_HIER;



-- ===============================================================
-- Procedure name
--          Update_Role_Constraint_Denorm
--
-- Purpose
--          populate AMW_ROLE_CONSTRAINT_DENORM table
-- Params
--          p_constraint_rev_id       := input constraint_rev_id (Default is NULL)
--                                       if p_constraint_rev_id is specified, only update/create
--                                       the corresponding role/resp with that constraint.
--
-- History
-- 		  	07/14/2005    tsho     Create
--          08/03/2005    tsho     Consider Responsibility Waivers, leave User Waiver check to the run-time
--          09/16/2005    tsho     Consider Concurrent Program and Exclusion (function/menu exclusion from Responsibility)
-- ===============================================================
Procedure Update_Role_Constraint_Denorm (
    errbuf                       OUT  NOCOPY VARCHAR2,
    retcode                      OUT  NOCOPY VARCHAR2,
    p_constraint_rev_id     IN  NUMBER := NULL
)
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Role_Constraint_Denorm';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

TYPE respCurTyp IS REF CURSOR;
role_c respCurTyp;
resp_c respCurTyp;

p_superiors WF_ROLE_HIERARCHY.RELTAB;
p_subordinates WF_ROLE_HIERARCHY.RELTAB;

l_g_role_name             VARCHAR2(320);
l_g_responsibility_id     NUMBER;
l_g_menu_id               NUMBER;
l_g_function_id           NUMBER;
l_g_entry_object_type    VARCHAR2(30);
l_g_group_code           VARCHAR2(30);


-- 09.16.2005 tsho: Consider Concurrent Program and Exclusion (function/menu exclusion from Responsibility)
-- seperate the responsibility query from role
-- 05.23.2006 dliao: remove the grant_flag
l_role_dynamic_sql   VARCHAR2(4000)  :=
        '(SELECT gra.GRANTEE_KEY ROLE_NAME, gra.GRANTEE_ORIG_SYSTEM_ID as responsibility_id, gra.menu_id, ce.function_id, ce.object_type, ce.group_code '
      ||'  FROM AMW_CONSTRAINT_ENTRIES ce '
      ||'      ,'||G_AMW_GRANTS ||' gra '
      ||'      ,'||G_AMW_COMPILED_MENU_FUNCTIONS ||' cmf '
      ||' WHERE gra.menu_id = cmf.menu_id '
      ||'   AND cmf.function_id = ce.function_id '
      --and cmf.grant_flag = ''Y'' '
      ||'   AND ce.CONSTRAINT_REV_ID = :1 '
      ||'   AND gra.INSTANCE_TYPE = ''GLOBAL'' '
      ||'   AND gra.OBJECT_ID = -1 '
      ||'   AND gra.GRANTEE_TYPE = ''GROUP'' '
      ||'   AND gra.start_date <= sysdate AND (gra.end_date >= sysdate or gra.end_date is null) '
      ||' UNION '
      ||' SELECT gra.GRANTEE_KEY ROLE_NAME, gra.GRANTEE_ORIG_SYSTEM_ID as responsibility_id, gra.menu_id, ce.function_id, ce.object_type, ce.group_code '
      ||'  FROM AMW_CONSTRAINT_ENTRIES ce '
      ||'      ,'||G_AMW_GRANTS ||' gra '
      ||'      ,'||G_AMW_COMPILED_MENU_FUNCTIONS ||' cmf '
      ||' WHERE gra.menu_id = cmf.menu_id '
      ||'   AND cmf.function_id = ce.function_id '
      --and cmf.grant_flag = ''Y'' '
      ||'   AND ce.CONSTRAINT_REV_ID = :2 '
      ||'   AND gra.INSTANCE_TYPE = ''GLOBAL'' '
      ||'   AND gra.OBJECT_ID = -1 '
      ||'   AND gra.GRANTEE_TYPE = ''GLOBAL'' '
      ||'   AND gra.start_date <= sysdate AND (gra.end_date >= sysdate or gra.end_date is null) '
      ||') UNION ALL '
      ||' SELECT to_char(null) role_name, resp.responsibility_id, resp.request_group_id menu_id, ce.function_id, ce.object_type, ce.group_code '
      ||' FROM  '||G_AMW_RESPONSIBILITY ||' resp '
      ||'      ,'||G_AMW_REQUEST_GROUP_UNITS ||' rgu '
      ||'      ,AMW_CONSTRAINT_ENTRIES ce '
      ||' WHERE resp.request_group_id = rgu.request_group_id '
      ||'   AND rgu.request_unit_type = ''P'' '
      ||'   AND rgu.request_unit_id = ce.function_id AND ce.object_type = ''CP'' '
      ||'   AND ce.CONSTRAINT_REV_ID = :3 '
      ||'   AND resp.responsibility_id NOT IN (select cw.pk1 from amw_constraint_waivers_vl cw '
      ||'                 where cw.constraint_rev_id=ce.CONSTRAINT_REV_ID '
      ||'                 and cw.object_type=''RESP'' '
      ||'                 and cw.start_date<=sysdate '
      ||'                 and (cw.end_date >= sysdate or cw.end_date is null)) '
      ||'   AND resp.start_date <= sysdate AND (resp.end_date >= sysdate or resp.end_date is null) '
      ;

-- 09.16.2005 tsho: Consider Exclusion (function/menu exclusion from Responsibility)
-- seperate the responsibility query from role
l_applcation_id_list        G_NUMBER_TABLE;
l_responsibility_id_list    G_NUMBER_TABLE;
l_menu_id_list              G_NUMBER_TABLE;
l_function_id_list          G_NUMBER_TABLE;
l_role_name_id_list         G_VARCHAR2_LONG_TABLE;
l_entry_object_type_list    G_VARCHAR2_CODE_TABLE;
l_group_code_list           G_VARCHAR2_CODE_TABLE;
--17.12.06 psomanat : The FND creates a role for each responsibity.So the role name is added here.
l_resp_dynamic_sql   VARCHAR2(2000)  :=
        ' SELECT war.name, resp.application_id, resp.responsibility_id, resp.menu_id, ce.function_id, ce.object_type, ce.group_code '
      ||'  FROM AMW_CONSTRAINT_ENTRIES ce '
      ||'      ,'||G_AMW_RESPONSIBILITY_VL ||' resp '
      ||'      ,'||G_AMW_COMPILED_MENU_FUNCTIONS ||' cmf '
      ||'      ,'||G_AMW_ALL_ROLES_VL ||' war '
      ||' WHERE resp.menu_id = cmf.menu_id '
      ||'   AND cmf.function_id = ce.function_id and cmf.grant_flag = ''Y'' '
      ||'   AND (ce.OBJECT_TYPE is null OR ce.OBJECT_TYPE = ''FUNC'') '
      ||'   AND ce.CONSTRAINT_REV_ID = :1 '
      ||'   AND resp.responsibility_id NOT IN (select cw.pk1 from amw_constraint_waivers_vl cw '
      ||'                 where cw.constraint_rev_id=ce.CONSTRAINT_REV_ID '
      ||'                 and cw.object_type=''RESP'' '
      ||'                 and cw.start_date<=sysdate '
      ||'                 and (cw.end_date >= sysdate or cw.end_date is null)) '
      ||'   AND resp.start_date <= sysdate AND (resp.end_date >= sysdate or resp.end_date is null) '
      ||'   AND resp.responsibility_name = war.display_name '
      ||'   AND war.ORIG_SYSTEM = ''FND_RESP'' '
      ||'   AND STATUS = ''ACTIVE'' ';

-- find all valid constraints
CURSOR c_all_valid_constraints IS
      SELECT constraint_rev_id
        FROM amw_constraints_b
       WHERE start_date <= sysdate AND (end_date IS NULL OR end_date >= sysdate);
l_all_valid_constraints c_all_valid_constraints%ROWTYPE;

--09.20.2005 tsho Consider Exclusion
-- store the access right
l_accessible    BOOLEAN;
TYPE exclFuncCurTyp IS REF CURSOR;
excl_func_c exclFuncCurTyp;
l_excl_func_count     NUMBER;

l_excl_func_dynamic_sql   VARCHAR2(200)  :=
      'SELECT count(*) '
    ||'  FROM '||G_AMW_RESP_FUNCTIONS
    ||'  WHERE application_id = :1 '
    ||'  AND responsibility_id = :2 '
    ||'  AND rule_type = :3 '
    ||'  AND action_id = :4 ';

BEGIN
    IF p_constraint_rev_id IS NULL THEN
        -- delete all the records from amw_role_constraint_denorm
        DELETE FROM AMW_ROLE_CONSTRAINT_DENORM;

        -- check all constraints
        OPEN c_all_valid_constraints;
        LOOP
            FETCH c_all_valid_constraints INTO l_all_valid_constraints;
            EXIT WHEN c_all_valid_constraints%NOTFOUND;

            -- clear global list for each constraint
            Clear_List();

            OPEN role_c FOR l_role_dynamic_sql USING
                l_all_valid_constraints.constraint_rev_id, l_all_valid_constraints.constraint_rev_id, l_all_valid_constraints.constraint_rev_id;
            FETCH role_c BULK COLLECT INTO
                G_ROLE_NAME_LIST
               ,G_RESPONSIBILITY_ID_LIST
               ,G_MENU_ID_LIST
               ,G_FUNCTION_ID_LIST
               ,G_ENTRY_OBJECT_TYPE_LIST
               ,G_GROUP_CODE_LIST;
            CLOSE role_c;


         BUILD_ROLE_AND_RESP_HIER(
                        P_ROLE_NAME_LIST_HIER => G_ROLE_NAME_LIST,
                        P_RESPONSIBILITY_ID_LIST_HIER   => G_RESPONSIBILITY_ID_LIST,
                        P_MENU_ID_LIST_HIER   => G_MENU_ID_LIST,
                        P_FUNCTION_ID_LIST_HIER   => G_FUNCTION_ID_LIST,
                        P_ENTRY_OBJECT_TYPE_LIST_HIER  => G_ENTRY_OBJECT_TYPE_LIST,
                        P_GROUP_CODE_LIST_HIER    => G_GROUP_CODE_LIST);

	IF(G_FUNCTION_ID_LIST_HIER.COUNT > 0) THEN
            FORALL i IN 1 .. G_FUNCTION_ID_LIST_HIER.COUNT
                INSERT INTO AMW_ROLE_CONSTRAINT_DENORM
                VALUES(sysdate     -- last_update_date
                      ,G_USER_ID   -- last_updated_by
                      ,G_LOGIN_ID  -- last_update_login
                      ,sysdate     -- creation_date
                      ,G_USER_ID   -- created_by
                      ,G_FUNCTION_ID_LIST_HIER(i)    -- function_id
                      ,G_MENU_ID_LIST_HIER(i)        -- menu_id
                      ,l_all_valid_constraints.constraint_rev_id    -- constraint_rev_id
                      ,G_ENTRY_OBJECT_TYPE_LIST_HIER(i)                  -- object_type
                      ,G_GROUP_CODE_LIST_HIER(i)     -- group_code
                      ,G_ROLE_NAME_LIST_HIER(i)      -- role_name
                      ,G_RESPONSIBILITY_ID_LIST_HIER(i));                -- responsibility_id
	END IF;

            -- 09.20.2005 tsho: consider Exclusion
            -- clear global list for each constraint
            Clear_List();
            l_applcation_id_list.delete();
            l_responsibility_id_list.delete();
            l_role_name_id_list.delete();
            l_menu_id_list.delete();
            l_function_id_list.delete();
            l_entry_object_type_list.delete();
            l_group_code_list.delete();

            OPEN resp_c FOR l_resp_dynamic_sql USING
                l_all_valid_constraints.constraint_rev_id;
            FETCH resp_c BULK COLLECT INTO
                l_role_name_id_list
               ,l_applcation_id_list
               ,l_responsibility_id_list
               ,l_menu_id_list
               ,l_function_id_list
               ,l_entry_object_type_list
               ,l_group_code_list;
            CLOSE resp_c;

            FOR j IN 1 .. l_function_id_list.COUNT
            LOOP
                -- check function exclusion
                OPEN excl_func_c FOR l_excl_func_dynamic_sql USING
                    l_applcation_id_list(j), l_responsibility_id_list(j), 'F', l_function_id_list(j);
                FETCH excl_func_c INTO l_excl_func_count;
                CLOSE excl_func_c;

                IF (l_excl_func_count > 0) THEN
                    -- the function i is excluded from the reponsibility j, check next responsibility
                    l_accessible := FALSE;
                ELSE
                    -- need to check if any menu excluded from the responsibility j
                    l_accessible := PROCESS_MENU_TREE_DOWN_FOR_MN(
                                       p_menu_id        => l_menu_id_list(j),
                                       p_function_id    => l_function_id_list(j),
                                       p_appl_id        => l_applcation_id_list(j),
                                       p_resp_id        => l_responsibility_id_list(j),
                                       p_role_name      => l_role_name_id_list(j),
                                       p_entry_object_type_list => l_entry_object_type_list(j),
                                       p_group_code     => l_group_code_list(j));

                        BUILD_ROLE_AND_RESP_HIER(
                        P_ROLE_NAME_LIST_HIER => G_ROLE_NAME_LIST,
                        P_RESPONSIBILITY_ID_LIST_HIER   => G_RESPONSIBILITY_ID_LIST,
                        P_MENU_ID_LIST_HIER   => G_MENU_ID_LIST,
                        P_FUNCTION_ID_LIST_HIER   => G_FUNCTION_ID_LIST,
                        P_ENTRY_OBJECT_TYPE_LIST_HIER  => G_ENTRY_OBJECT_TYPE_LIST,
                        P_GROUP_CODE_LIST_HIER    => G_GROUP_CODE_LIST);


                END IF; -- end of if: l_excl_func_id IS NOT NULL

            END LOOP; --end of for: l_function_id_list

              -- populate non-exclusion function to defnorm table
               IF(G_FUNCTION_ID_LIST_HIER.COUNT > 0) THEN
            FORALL i IN 1 .. G_FUNCTION_ID_LIST_HIER.COUNT

                INSERT INTO AMW_ROLE_CONSTRAINT_DENORM
                VALUES(sysdate     -- last_update_date
                      ,G_USER_ID   -- last_updated_by
                      ,G_LOGIN_ID  -- last_update_login
                      ,sysdate     -- creation_date
                      ,G_USER_ID   -- created_by
                      ,G_FUNCTION_ID_LIST_HIER(i)    -- function_id
                      ,G_MENU_ID_LIST_HIER(i)        -- menu_id
                      ,l_all_valid_constraints.constraint_rev_id    -- constraint_rev_id
                      ,G_ENTRY_OBJECT_TYPE_LIST_HIER(i)                  -- object_type
                      ,G_GROUP_CODE_LIST_HIER(i)     -- group_code
                      ,G_ROLE_NAME_LIST_HIER(i)      -- role_name
                      ,G_RESPONSIBILITY_ID_LIST_HIER(i));                -- responsibility_id

	   END IF;  --end of g_function_id_list_hier.count > 0

        END LOOP;

        CLOSE c_all_valid_constraints;
    ELSE
        -- check specified constraint
        -- delete the records from amw_role_constraint_denorm for the specified constraint
        DELETE FROM AMW_ROLE_CONSTRAINT_DENORM
        WHERE constraint_rev_id = p_constraint_rev_id;

        -- clear global list for each constraint
        Clear_List();


        OPEN role_c FOR l_role_dynamic_sql USING
            p_constraint_rev_id, p_constraint_rev_id, p_constraint_rev_id;
        FETCH role_c BULK COLLECT INTO
            G_ROLE_NAME_LIST
           ,G_RESPONSIBILITY_ID_LIST
           ,G_MENU_ID_LIST
           ,G_FUNCTION_ID_LIST
           ,G_ENTRY_OBJECT_TYPE_LIST
           ,G_GROUP_CODE_LIST;
        CLOSE role_c;

         BUILD_ROLE_AND_RESP_HIER(
                        P_ROLE_NAME_LIST_HIER => G_ROLE_NAME_LIST,
                        P_RESPONSIBILITY_ID_LIST_HIER   => G_RESPONSIBILITY_ID_LIST,
                        P_MENU_ID_LIST_HIER   => G_MENU_ID_LIST,
                        P_FUNCTION_ID_LIST_HIER   => G_FUNCTION_ID_LIST,
                        P_ENTRY_OBJECT_TYPE_LIST_HIER  => G_ENTRY_OBJECT_TYPE_LIST,
                        P_GROUP_CODE_LIST_HIER    => G_GROUP_CODE_LIST);

	IF(G_FUNCTION_ID_LIST_HIER.COUNT > 0) THEN
        FORALL i IN 1 .. G_FUNCTION_ID_LIST_HIER.COUNT
            INSERT INTO AMW_ROLE_CONSTRAINT_DENORM
            VALUES(sysdate     -- last_update_date
                  ,G_USER_ID   -- last_updated_by
                  ,G_LOGIN_ID  -- last_update_login
                  ,sysdate     -- creation_date
                  ,G_USER_ID   -- created_by
                  ,G_FUNCTION_ID_LIST_HIER(i)    -- function_id
                  ,G_MENU_ID_LIST_HIER(i)        -- menu_id
                  ,p_constraint_rev_id      -- constraint_rev_id
                  ,G_ENTRY_OBJECT_TYPE_LIST_HIER(i)                  -- object_type
                  ,G_GROUP_CODE_LIST_HIER(i)     -- group_code
                  ,G_ROLE_NAME_LIST_HIER(i)      -- role_name
                  ,G_RESPONSIBILITY_ID_LIST_HIER(i));                -- responsibility_id
	END IF;
        -- 09.20.2005 tsho: consider Exclusion
        -- clear global list for each constraint
        Clear_List();
        l_applcation_id_list.delete();
        l_responsibility_id_list.delete();
        l_role_name_id_list.delete();
        l_menu_id_list.delete();
        l_function_id_list.delete();
        l_entry_object_type_list.delete();
        l_group_code_list.delete();



        OPEN resp_c FOR l_resp_dynamic_sql USING
            p_constraint_rev_id;
        FETCH resp_c BULK COLLECT INTO
            l_role_name_id_list
           ,l_applcation_id_list
           ,l_responsibility_id_list
           ,l_menu_id_list
           ,l_function_id_list
           ,l_entry_object_type_list
           ,l_group_code_list;
        CLOSE resp_c;

        FOR j IN 1 .. l_function_id_list.COUNT
        LOOP
            -- check function exclusion
            OPEN excl_func_c FOR l_excl_func_dynamic_sql USING
                l_applcation_id_list(j), l_responsibility_id_list(j), 'F', l_function_id_list(j);
            FETCH excl_func_c INTO l_excl_func_count;
            CLOSE excl_func_c;
            IF (l_excl_func_count > 0) THEN
                -- the function i is excluded from the reponsibility j, check next responsibility
                l_accessible := FALSE;
            ELSE
                -- need to check if any menu excluded from the responsibility j
                l_accessible := PROCESS_MENU_TREE_DOWN_FOR_MN(
                                   p_menu_id        => l_menu_id_list(j),
                                   p_function_id    => l_function_id_list(j),
                                   p_appl_id        => l_applcation_id_list(j),
                                   p_resp_id        => l_responsibility_id_list(j),
                                   p_role_name      => l_role_name_id_list(j),
                                   p_entry_object_type_list => l_entry_object_type_list(j),
                                   p_group_code     => l_group_code_list(j));

                     BUILD_ROLE_AND_RESP_HIER(
                        P_ROLE_NAME_LIST_HIER => G_ROLE_NAME_LIST,
                        P_RESPONSIBILITY_ID_LIST_HIER   => G_RESPONSIBILITY_ID_LIST,
                        P_MENU_ID_LIST_HIER   => G_MENU_ID_LIST,
                        P_FUNCTION_ID_LIST_HIER   => G_FUNCTION_ID_LIST,
                        P_ENTRY_OBJECT_TYPE_LIST_HIER  => G_ENTRY_OBJECT_TYPE_LIST,
                        P_GROUP_CODE_LIST_HIER    => G_GROUP_CODE_LIST);


            END IF; -- end of if: l_excl_func_id IS NOT NULL
        END LOOP; --end of for: l_function_id_list


        -- populate non-exclusion function to defnorm table
           IF(G_FUNCTION_ID_LIST_HIER.COUNT > 0) THEN
            FORALL i IN 1 .. G_FUNCTION_ID_LIST_HIER.COUNT

                INSERT INTO AMW_ROLE_CONSTRAINT_DENORM
                VALUES(sysdate     -- last_update_date
                      ,G_USER_ID   -- last_updated_by
                      ,G_LOGIN_ID  -- last_update_login
                      ,sysdate     -- creation_date
                      ,G_USER_ID   -- created_by
                      ,G_FUNCTION_ID_LIST_HIER(i)    -- function_id
                      ,G_MENU_ID_LIST_HIER(i)        -- menu_id
                      ,p_constraint_rev_id    -- constraint_rev_id
                      ,G_ENTRY_OBJECT_TYPE_LIST_HIER(i)                  -- object_type
                      ,G_GROUP_CODE_LIST_HIER(i)     -- group_code
                      ,G_ROLE_NAME_LIST_HIER(i)      -- role_name
                      ,G_RESPONSIBILITY_ID_LIST_HIER(i));                -- responsibility_id
	    END IF; --end of if g_function_id_list_hier.count > 0

    END IF; --end of if: p_constraint_rev_id = NULL

    COMMIT;

EXCEPTION
    WHEN others then
        RAISE;

END Update_Role_Constraint_Denorm;

-- ===============================================================
-- Function name
--          Get_Violat_New_Role_List
--
-- Purpose
--          get a flat string list of new role display name, which together with this user's
--          exisiting role/resp , or together with those new assigned role(among p_role_names_string)
--          may violate the specified constraint
--
-- Params
--          p_user_id            := input fnd user_id
--          p_constraint_rev_id  := input constraint_rev_id
--          p_constraint_type_code  := input constraint type for p_constraint_rev_id
--          p_new_role_names_string  := input a string list of new roles assigning to this user,
--                                  the role_name is seperated by ','
--
-- Return
--          a string list of role display names which violates the specified constraint,
--          each display name is seperated by ','
--
-- History
-- 		  	07/27/2005    tsho     Create
-- ===============================================================
Function Get_Violat_New_Role_List (
    p_user_id                   IN  NUMBER,
    p_constraint_rev_id         IN  NUMBER,
    p_constraint_type_code      IN  VARCHAR2,
    p_new_role_names_string     IN  VARCHAR2
) RETURN VARCHAR2
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Get_Violat_New_Role_List';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

-- store the new role this user has against this constraint
l_new_role_table JTF_VARCHAR2_TABLE_400;

-- store the return value
l_new_role_string VARCHAR2(32767);

l_new_role_names_string VARCHAR2(32767):=p_new_role_names_string;

TYPE refCurTyp IS REF CURSOR;
new_role_c refCurTyp;

-- find new roles this user has (results in violating the specified constraint)
l_new_role_dynamic_sql   VARCHAR2(500)  :=
    'select distinct rv.display_name '
  ||'  from amw_role_constraint_denorm rcd '
  ||'      ,'||G_AMW_ALL_ROLES_VL||' rv '
  ||'  where rcd.constraint_rev_id = :1 '
  ||'    and (rcd.role_name = rv.name or (rv.orig_system = ''FND_RESP'' and rcd.responsibility_id = rv.orig_system_id ) ) '
  ||'    and rv.name in (:2) ';


 -- ptulasi : 08/22/2007
 -- Bug 5558490 : Added below query to find new responsibilities user has
 -- (results in violating the specified constraint)
 l_new_resp_dynamic_sql   VARCHAR2(1500)  :=
  ' SELECT distinct rv.display_name '
  ||' FROM fnd_responsibility_vl frv '
  ||'      ,'||G_AMW_ALL_ROLES_VL||' rv ,'
  ||'      amw_constraint_entries ace'
  ||' WHERE rv.name IN (:1)'
  ||'       AND frv.responsibility_id = ace.function_id '
  ||'       AND frv.APPLICATION_ID = ace.APPLICATION_ID '
  ||'       AND ace.object_type = ''RESP'''
  ||'       AND ace.constraint_rev_id = :2'
  ||'       AND ( rv.display_name = frv.responsibility_name OR ( rv.orig_system = ''FND_RESP'' AND frv.responsibility_id = rv.orig_system_id ))'
  ||'       AND (frv.end_date is null OR (frv.end_date is not null AND frv.end_date > sysdate))';

BEGIN
  l_new_role_string := NULL;

  IF (p_user_id IS NOT NULL AND p_constraint_rev_id IS NOT NULL AND p_constraint_type_code IS NOT NULL AND p_new_role_names_string IS NOT NULL) THEN

    -- 24-12-2005 : psomanat
    -- When the Send_Notif_To_Process_Owner call this function the role name
    -- does not have the @ delimiter at the last.
    IF (instr(l_new_role_names_string,'@') = 0) THEN
       l_new_role_names_string := l_new_role_names_string || '@';
    END IF;

    WHILE (substr(l_new_role_names_string,1,instr(l_new_role_names_string,'@')-1) IS NOT NULL)
    LOOP

        -- ptulasi : 08/22/2007
        -- Bug 5558490 : Added below code to execute the query based on the constraint type
        IF p_constraint_type_code <> 'RESP' THEN
           OPEN new_role_c FOR l_new_role_dynamic_sql USING
              p_constraint_rev_id, substr(l_new_role_names_string,1,instr(l_new_role_names_string,'@')-1) ;
        ELSE
           OPEN new_role_c FOR l_new_resp_dynamic_sql USING
              substr(l_new_role_names_string,1,instr(l_new_role_names_string,'@')-1), p_constraint_rev_id;
        END IF;

        FETCH new_role_c BULK COLLECT INTO l_new_role_table;
        CLOSE new_role_c;

        IF l_new_role_table IS NOT NULL AND l_new_role_table.FIRST IS NOT NULL THEN
            IF l_new_role_string IS NULL THEN
                l_new_role_string :=l_new_role_table(1);
            ELSE
                l_new_role_string :=l_new_role_string||', '||l_new_role_table(1);
            END IF;
            FOR i in 2 .. l_new_role_table.COUNT
            LOOP
                l_new_role_string := l_new_role_string||', '||l_new_role_table(i);
            END LOOP;
        END IF; -- end of if: l_new_role_table IS NOT NULL
        l_new_role_names_string:=substr(l_new_role_names_string,instr(l_new_role_names_string,'@')+1);
    END LOOP;
  END IF; --end of if: p_user_id IS NOT NULL AND p_constraint_rev_id IS NOT NULL AND p_constraint_type_code IS NOT NULL AND p_new_role_names_string IS NOT NULL
return l_new_role_string;
END Get_Violat_New_Role_List;


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

  return l_existing_role_string;

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
l_existing_resp_dynamic_sql   VARCHAR2(500)  :=
    'select distinct resp.responsibility_name '
  ||'  from amw_role_constraint_denorm rcd '
  ||'      ,'||G_AMW_USER_ROLES||' ur '
  ||'      ,'||G_AMW_user||' u '
  ||'      ,'||G_AMW_RESPONSIBILITY_VL||' resp '
  ||'  where rcd.constraint_rev_id = :1 '
  ||'    and u.user_id = :2 '
  ||'    and u.user_name = ur.user_name '
  ||'    and rcd.responsibility_id = resp.responsibility_id '
  ||'    and ur.role_orig_system_id = rcd.responsibility_id '
  ||'    and ur.role_orig_system = ''FND_RESP'' '
  ||'    and ur.role_orig_system_id = resp.responsibility_id ';

BEGIN
  l_existing_resp_string := NULL;

  IF (p_user_id IS NOT NULL AND p_constraint_rev_id IS NOT NULL AND p_constraint_type_code IS NOT NULL) THEN
    OPEN existing_resp_c FOR l_existing_resp_dynamic_sql USING
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

  return l_existing_resp_string;

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

  return l_existing_menu_string;

END Get_Violat_Existing_Menu_List;


-- ===============================================================
-- Function name
--          Get_Violat_Comments
--
-- Purpose
--          get comments(instruction) for specified constraint_rev_id
--
-- Params
--          p_constraint_rev_id  := input constraint_rev_id
--          p_constraint_type_code  := input constraint type for p_constraint_rev_id
--
-- Return
--          a seeded mesg
--
-- History
-- 		  	07/27/2005    tsho     Create
-- ===============================================================
Function Get_Violat_Comments (
    p_constraint_rev_id         IN  NUMBER,
    p_constraint_type_code      IN  VARCHAR2
) RETURN VARCHAR2
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Get_Violat_Comments';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

-- store the return value
l_violat_comments VARCHAR2(80);

BEGIN
  l_violat_comments := NULL;

  IF p_constraint_type_code IS NOT NULL THEN
    IF p_constraint_type_code = 'ALL' THEN
      l_violat_comments := AMW_UTILITY_PVT.get_message_text('AMW_ROLE_VIOLAT_ALL_COMMENT');
    ELSE
      l_violat_comments := AMW_UTILITY_PVT.get_message_text('AMW_ROLE_VIOLAT_ME_COMMENT');
    END IF;
  END IF; -- end of if: p_constraint_type_code IS NOT NULL

  return l_Violat_Comments;

END Get_Violat_Comments;


-- ===============================================================
-- Function name
--          Do_On_Role_Assigned
--
-- Purpose
--          listen to the worflow business event(mainly uses for oracle.apps.fnd.wf.ds.userRole.created)
--          and do corresponding actions
--
-- Params
--          p_subscription_guid
--          p_event
--
-- Return
--          'SUCCESS' | 'ERROR'
--
-- History
-- 		  	07/29/2005    tsho     Create
-- ===============================================================
FUNCTION Do_On_Role_Assigned (
    p_subscription_guid   in     raw,
	p_event               in out NOCOPY WF_EVENT_T
) return VARCHAR2
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Do_On_Role_Assigned';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

l_user_name	      VARCHAR2(100);
l_role_name	      VARCHAR2(320);
l_assigned_date   DATE;
l_assigned_by_id  NUMBER;
l_user_id	      VARCHAR2(100);

TYPE curTyp IS REF CURSOR;
c_user_dynamic_sql curTyp;
l_user_dynamic_sql   VARCHAR2(200)  :=
        'SELECT u.user_id '
      ||'  FROM '||G_AMW_USER ||' u '
      ||' WHERE u.user_name = :1  ';

BEGIN
    SAVEPOINT Do_On_Role_Assigned;

    IF p_event.EVENT_NAME = 'oracle.apps.fnd.umx.requestapproved' THEN
        -- This event is raised when a a role is assigned to a user.
        l_user_id   := p_event.GetValueForParameter('REQUESTED_FOR_USER_ID');
        l_role_name := p_event.GetValueForParameter('WF_ROLE_NAME');
        l_assigned_by_id := p_event.GetValueForParameter('REQUESTED_BY_USER_ID');

    ELSE
        -- This event is raised when a assigned role is updated.
        l_user_name := p_event.GetValueForParameter('USER_NAME');
        l_role_name := p_event.GetValueForParameter('ROLE_NAME');
        l_assigned_by_id := p_event.GetValueForParameter('CREATED_BY');

        OPEN c_user_dynamic_sql FOR l_user_dynamic_sql USING
             l_user_name;
        FETCH c_user_dynamic_sql INTO l_user_id;
        CLOSE c_user_dynamic_sql;

    END IF;

    IF l_user_id IS NOT NULL AND l_role_name IS NOT NULL THEN
        Send_Notif_To_Affected_Process(p_user_id     => l_user_id,
                                       p_role_name      => l_role_name,
                                       p_assigned_by_id => l_assigned_by_id);
     -- updated by dliao on 7-31-06 because the role_name could be null for the user
     -- registration (bug 5396917)
     -- Return 'SUCCESS';
    END IF;

    Return 'SUCCESS';

EXCEPTION
  WHEN OTHERS  THEN
     ROLLBACK TO Do_On_Role_Assigned;
     FND_MESSAGE.SET_NAME( 'AMW', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AMW_VIOLATION_PVT','Do_On_Role_Assigned error', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event,'ERROR');
     RETURN 'ERROR';
END Do_On_Role_Assigned;


-- ===============================================================
-- Procedure name
--          Send_Notif_To_Affected_Process
--
-- Purpose
--          send violation notification to affected process owners
--          it'll find which constraints have been violated due to the user role assignment
--          and send notification to each process owner of those constraints
-- Params
--          p_item_type       := worflow template (default : AMWNOTIF)
--          p_message_name    := workflow mesg template (default : MWVIOLATUSERROLENOTIF)
--          p_user_name       := the user who got the role assigned
--          p_role_name       := the new role which is assigned to this user
--          p_assigned_date   := the assigned date
--          p_assigned_by_id  := the role is assigned by which user (user_id)
--
-- History
-- 		  	07/29/2005    tsho     Create
--          02/23/2006    psomanat removied the parameter p_user_name
--          02/23/2006    psomanat added the parameter p_user_id
-- ===============================================================
Procedure Send_Notif_To_Affected_Process(
    p_item_type      IN VARCHAR2 := 'AMWNOTIF',
	p_message_name   IN VARCHAR2 := 'VIOLATIONNOTIF',
    p_user_id        IN NUMBER,
    p_role_name      IN VARCHAR2,
    p_assigned_by_id IN NUMBER
)
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Send_Notif_To_Affected_Process';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

l_return_status   varchar2(30);

-- store the result of l_violated_cst_dynamic_sql
violated_cst_rev_id_list G_NUMBER_TABLE;
new_role_list G_VARCHAR2_LONG_TABLE;

-- store the result of C_Proc_Owner
affected_proc_owner_id_list G_NUMBER_TABLE;

-- store the result of C_Controls_Ids
associated_cont_ids_list G_NUMBER_TABLE;
TYPE curTyp IS REF CURSOR;
-- get violated constraint for specified p_user_name and newly assigned p_role_name
c_violated_cst_dynamic_sql curTyp;
l_violated_cst_dynamic_sql   VARCHAR2(32767) :=
   'select * from ( '
   -- ALL
 ||' select AMW_VIOLATION_PVT.get_violat_new_role_list(:1,cst.constraint_rev_id,cst.type_code,:2) NEW_ROLE '
 ||'       ,cst.constraint_rev_id '
 ||' from amw_constraints_b cst '
 ||' where cst.type_code = ''ALL'' '
 ||'   and cst.start_date <= sysdate AND (cst.end_date IS NULL OR cst.end_date >= sysdate) '
 ||'   and (select count(*) '
 ||'        from amw_constraint_entries ce '
 ||'        where ce.constraint_rev_id = cst.constraint_rev_id) = ( '
 ||' select count(distinct rcd.function_id) '
 ||' from amw_role_constraint_denorm rcd '
 ||' where rcd.constraint_rev_id = cst.constraint_rev_id '
 ||'   and ( rcd.role_name = :3 '
 ||'      or (rcd.role_name in ( '
 ||'          select ur.role_name '
 ||'          from '||G_AMW_USER_ROLES||' ur '
 ||'              ,'||G_AMW_USER||' u '
 ||'          where u.user_id = :4 '
 ||'            and u.user_name = ur.user_name '
 ||'            and ur.role_orig_system = ''UMX'') '
 ||'          ) '
 ||'      or (rcd.responsibility_id in ( '
 ||'          select ur.role_orig_system_id '
 ||'          from '||G_AMW_USER_ROLES||' ur '
 ||'              ,'||G_AMW_USER||' u '
 ||'          where u.user_id = :5 '
 ||'            and u.user_name = ur.user_name '
 ||'            and ur.role_orig_system = ''FND_RESP'') '
 ||'          ) '
 ||'       or (rcd.menu_id in ( '
 ||'           select gra.menu_id '
 ||'           from '||G_AMW_GRANTS||' gra '
 ||'               ,'||G_AMW_USER||' u '
 ||'           where u.user_id = :6 '
 ||'             and u.user_name = gra.grantee_key '
 ||'             and gra.grantee_type = ''USER'' '
 ||'             and gra.instance_type = ''GLOBAL'' '
 ||'             and gra.object_id = -1) '
 ||'           ) '
 ||'       or (rcd.menu_id in ( '
 ||'           select gra.menu_id '
 ||'           from '||G_AMW_GRANTS||' gra '
 ||'           where gra.grantee_key = ''GLOBAL'' '
 ||'             and gra.grantee_type = ''GLOBAL'' '
 ||'             and gra.instance_type = ''GLOBAL'' '
 ||'             and gra.object_id = -1) '
 ||'           ) '
 ||'   ) '
 ||' ) '
 ||' UNION ALL '
 -- ME
 ||' select AMW_VIOLATION_PVT.get_violat_new_role_list(:7,cst.constraint_rev_id,cst.type_code,:8) NEW_ROLE '
 ||'      , cst.constraint_rev_id '
 ||' from amw_constraints_b cst '
 ||' where cst.type_code = ''ME'' '
 ||'   and cst.start_date <= sysdate AND (cst.end_date IS NULL OR cst.end_date >= sysdate) '
 ||'   and (select count(distinct rcd.function_id) '
 ||'        from amw_role_constraint_denorm rcd '
 ||'        where rcd.constraint_rev_id = cst.constraint_rev_id '
 ||'          and ( rcd.role_name = :9 '
 ||'             or (rcd.role_name in ( '
 ||'                 select ur.role_name '
 ||'                 from '||G_AMW_USER_ROLES||' ur '
 ||'                     ,'||G_AMW_USER||' u '
 ||'                 where u.user_id = :10 '
 ||'                   and u.user_name = ur.user_name '
 ||'                   and ur.role_orig_system = ''UMX'') '
 ||'                 ) '
 ||'             or (rcd.responsibility_id in ( '
 ||'                 select ur.role_orig_system_id '
 ||'                 from '||G_AMW_USER_ROLES||' ur '
 ||'                     ,'||G_AMW_USER||' u '
 ||'                 where u.user_id = :11 '
 ||'                   and u.user_name = ur.user_name '
 ||'                   and ur.role_orig_system = ''FND_RESP'') '
 ||'                 ) '
 ||'             or (rcd.menu_id in ( '
 ||'                 select gra.menu_id '
 ||'                 from '||G_AMW_GRANTS||' gra '
 ||'                     ,'||G_AMW_USER||' u '
 ||'                 where u.user_id = :12 '
 ||'                   and u.user_name = gra.grantee_key '
 ||'                   and gra.grantee_type = ''USER'' '
 ||'                   and gra.instance_type = ''GLOBAL'' '
 ||'                   and gra.object_id = -1) '
 ||'                 ) '
 ||'              or (rcd.menu_id in ( '
 ||'                  select gra.menu_id '
 ||'                  from '||G_AMW_GRANTS||' gra '
 ||'                  where gra.grantee_key = ''GLOBAL'' '
 ||'                    and gra.grantee_type = ''GLOBAL'' '
 ||'                    and gra.instance_type = ''GLOBAL'' '
 ||'                    and gra.object_id = -1) '
 ||'                  ) '
 ||'          ) '
 ||'       ) >= 2 '
 ||' UNION ALL '
 -- SET
 ||' select AMW_VIOLATION_PVT.get_violat_new_role_list(:13,cst.constraint_rev_id,cst.type_code,:14) NEW_ROLE '
 ||'       ,cst.constraint_rev_id '
 ||' from amw_constraints_b cst '
 ||' where cst.type_code = ''SET'' '
 ||'   and cst.start_date <= sysdate AND (cst.end_date IS NULL OR cst.end_date >= sysdate) '
 ||'   and (select count(distinct rcd.group_code) '
 ||'        from amw_role_constraint_denorm rcd '
 ||'        where rcd.constraint_rev_id = cst.constraint_rev_id '
 ||'          and (rcd.role_name = :15 '
 ||'            or (rcd.role_name in ( '
 ||'                select ur.role_name '
 ||'                from '||G_AMW_USER_ROLES||' ur '
 ||'                    ,'||G_AMW_USER||' u '
 ||'                where u.user_id = :16 '
 ||'                  and u.user_name = ur.user_name '
 ||'                  and ur.role_orig_system = ''UMX'') '
 ||'               ) '
 ||'            or (rcd.responsibility_id in ( '
 ||'                select ur.role_orig_system_id '
 ||'                from '||G_AMW_USER_ROLES||' ur '
 ||'                    ,'||G_AMW_USER||' u '
 ||'                where u.user_id = :17 '
 ||'                  and u.user_name = ur.user_name '
 ||'                  and ur.role_orig_system = ''FND_RESP'') '
 ||'               ) '
 ||'            or (rcd.menu_id in ( '
 ||'                select gra.menu_id '
 ||'                from '||G_AMW_GRANTS||' gra '
 ||'                    ,'||G_AMW_USER||' u '
 ||'                where u.user_id = :18 '
 ||'                  and u.user_name = gra.grantee_key '
 ||'                  and gra.grantee_type = ''USER'' '
 ||'                  and gra.instance_type = ''GLOBAL'' '
 ||'                  and gra.object_id = -1) '
 ||'               ) '
 ||'            or (rcd.menu_id in ( '
 ||'                select gra.menu_id '
 ||'                from '||G_AMW_GRANTS||' gra '
 ||'                where gra.grantee_key = ''GLOBAL'' '
 ||'                  and gra.grantee_type = ''GLOBAL'' '
 ||'                  and gra.instance_type = ''GLOBAL'' '
 ||'                  and gra.object_id = -1) '
 ||'               ) '
 ||'          ) '
 ||'       ) >= 2 '
 ||' UNION ALL '
   -- RESPALL
 ||' select AMW_VIOLATION_PVT.get_violat_new_role_list(:19,cst.constraint_rev_id,cst.type_code,:20) NEW_ROLE '
 ||'       ,cst.constraint_rev_id '
 ||' from amw_constraints_b cst '
 ||' where cst.type_code = ''RESPALL'' '
 ||'   and cst.start_date <= sysdate AND (cst.end_date IS NULL OR cst.end_date >= sysdate) '
 ||'   and (select count(*) '
 ||'        from amw_constraint_entries ce '
 ||'        where ce.constraint_rev_id = cst.constraint_rev_id) = ( '
 ||        '  select count(distinct ur.role_orig_system_id) '
 ||'  from '
 || G_AMW_USER_ROLES||' ur '
 ||'      ,'||G_AMW_user||' u '
 ||'      ,amw_constraint_entries ce '
 ||'  where  u.user_id = :21 '
 ||'    and  ce.constraint_rev_id = cst.constraint_rev_id '
 ||'    and u.user_name = ur.user_name '
 ||'    and ur.role_orig_system_id = ce.function_id '
 ||'    and (ur.role_orig_system = ''FND_RESP'' '
 ||'    or ur.role_orig_system_id in ( '
 ||'  select distinct rle.orig_system_id '
 ||'  from  ' || G_AMW_ALL_ROLES_VL || ' rle '
 ||'  where rle.orig_system = ''FND_RESP'' '
 ||'  and ce.function_id = rle.orig_system_id '
 ||'  and rle.name in (:22)) '
 ||') '
 || ') '
 ||' UNION ALL '
   -- RESPME
  ||' select AMW_VIOLATION_PVT.get_violat_new_role_list(:23,cst.constraint_rev_id,cst.type_code,:24) NEW_ROLE '
 ||'      , cst.constraint_rev_id '
 ||' from amw_constraints_b cst '
 ||' where cst.type_code = ''RESPME'' '
 ||'   and cst.start_date <= sysdate AND (cst.end_date IS NULL OR cst.end_date >= sysdate) '
 ||'   and '
 || '  (select count(distinct ur.role_orig_system_id ) '
 ||'  from '
 || G_AMW_USER_ROLES||' ur '
 ||'      ,'||G_AMW_user||' u '
 ||'      ,amw_constraint_entries ce '
 ||'  where  u.user_id = :25 '
 ||'    and  ce.constraint_rev_id = cst.constraint_rev_id '
 ||'    and u.user_name = ur.user_name '
 ||'    and ur.role_orig_system_id = ce.function_id '
 ||'    and (ur.role_orig_system = ''FND_RESP'' '
 ||'    or ur.role_orig_system_id in ( '
 ||'  select distinct rle.orig_system_id '
 ||'  from  ' || G_AMW_ALL_ROLES_VL || ' rle '
 ||'  where rle.orig_system = ''FND_RESP'' '
 ||'  and ce.function_id = rle.orig_system_id '
 ||'  and rle.name in (:26 )) '
 ||') '
 ||') '
 ||' >= 2 '
 ||' UNION ALL '
 -- RESPSET
  ||' select AMW_VIOLATION_PVT.get_violat_new_role_list(:27,cst.constraint_rev_id,cst.type_code,:28) NEW_ROLE '
 ||'      , cst.constraint_rev_id '
 ||' from amw_constraints_b cst '
 ||' where cst.type_code = ''RESPME'' '
 ||'   and cst.start_date <= sysdate AND (cst.end_date IS NULL OR cst.end_date >= sysdate) '
 ||'   and '
 || '  (select count(distinct ur.role_orig_system_id ) '
 ||'  from '
 || G_AMW_USER_ROLES||' ur '
 ||'      ,'||G_AMW_user||' u '
 ||'      ,amw_constraint_entries ce '
 ||'  where  u.user_id = :29 '
 ||'    and  ce.constraint_rev_id = cst.constraint_rev_id '
 ||'    and u.user_name = ur.user_name '
 ||'    and ur.role_orig_system_id = ce.function_id '
 ||'    and (ur.role_orig_system = ''FND_RESP'' '
 ||'    or ur.role_orig_system_id in ( '
 ||'  select distinct rle.orig_system_id '
 ||'  from  ' || G_AMW_ALL_ROLES_VL || ' rle '
 ||'  where rle.orig_system = ''FND_RESP'' '
 ||'  and ce.function_id = rle.orig_system_id '
 ||'  and rle.name in (:30 )) '
 ||') '
 ||') '
 ||' >= 2 '
  ||' ) where NEW_ROLE IS NOT NULL ';

--27:12:05 : psomanat
-- holds the control associated with the Constraint
CURSOR C_Control_Ids(l_constraint_id in NUMBER) IS
SELECT CONTROL_ID
          FROM AMW_CONTROLS_ALL_VL ctl
          WHERE ctl.AUTOMATION_TYPE ='SOD'
            AND CURR_APPROVED_FLAG ='Y'
            AND ctl.SOURCE =l_constraint_id;

-- Store the Constraint id for the given constraint revision id.
l_constraint_id number;

--27:12:05 : psomanat
-- A Control is associated a Constraint. So get the process owners of all the process
-- that uses this control to mitigate the associated risk.
CURSOR C_Proc_Owner(l_cont_id in NUMBER) IS
SELECT distinct TO_NUMBER(REPLACE(grants.grantee_key,'HZ_PARTY:','')) party_id
FROM AMW_control_Associations ca,
     fnd_grants grants,
     fnd_menus granted_menu,
     fnd_objects obj
WHERE   CONTROL_ID = l_cont_id
   AND  OBJECT_TYPE ='RISK'
   AND  APPROVAL_DATE IS NOT NULL
   AND  DELETION_APPROVAL_DATE IS NULL
   and obj.obj_name = 'AMW_PROCESS_APPR_ETTY'
   AND grants.object_id = obj.object_id
   AND   grants.grantee_type ='USER'
   AND   grantee_key like 'HZ_PARTY%'
   AND   NVL(grants.end_date, SYSDATE+1) >= TRUNC(SYSDATE)
   AND   grants.menu_id = granted_menu.menu_id
   AND   grants.instance_type = 'INSTANCE'
   AND   grants.instance_pk1_value = TO_CHAR(ca.PK1)
   AND   grants.instance_pk2_value = '*NULL*'
   AND   grants.instance_pk3_value = '*NULL*'
   AND   grants.instance_pk4_value = '*NULL*'
   AND   grants.instance_pk5_value = '*NULL*'
   AND   granted_menu.menu_name =  'AMW_RL_PROC_OWNER_ROLE'
   UNION
   SELECT   distinct TO_NUMBER(REPLACE(grants.grantee_key,'HZ_PARTY:','')) party_id
    FROM    AMW_control_Associations ca,
            fnd_grants grants,
            fnd_menus granted_menu,
            fnd_objects obj
    WHERE CONTROL_ID = l_cont_id
        AND  OBJECT_TYPE ='RISK_ORG'
        AND  APPROVAL_DATE IS NOT NULL
        AND  DELETION_APPROVAL_DATE IS NULL
        AND  obj.obj_name = 'AMW_PROCESS_ORGANIZATION'
        AND   grants.object_id = obj.object_id
        AND   grants.grantee_type ='USER'
        AND   grantee_key like 'HZ_PARTY%'
        AND   NVL(grants.end_date, SYSDATE+1) >= TRUNC(SYSDATE)
        AND   grants.menu_id = granted_menu.menu_id
        AND   grants.instance_type = 'INSTANCE'
        AND   grants.instance_pk1_value = to_char(ca.pk1)      -- PASS ORG_ID AS STRING
        AND   grants.instance_pk2_value = to_char(ca.pk2)      -- PASS PROCESS_ID AS STRING I.E. to_char(process_id)
        AND   grants.instance_pk3_value = '*NULL*'
        AND   grants.instance_pk4_value = '*NULL*'
        AND   grants.instance_pk5_value = '*NULL*'
        and   granted_menu.menu_name = 'AMW_ORG_PROC_OWNER_ROLE';

BEGIN
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_user_id IS NULL or p_role_name IS NULL) THEN
        RETURN;
    END IF;

    -- get list of violated constraint id
    OPEN c_violated_cst_dynamic_sql FOR l_violated_cst_dynamic_sql USING
        -- ALL
        p_user_id
        ,p_role_name
        ,p_role_name
        ,p_user_id
        ,p_user_id
        ,p_user_id
        -- ME
        ,p_user_id
        ,p_role_name
        ,p_role_name
        ,p_user_id
        ,p_user_id
        ,p_user_id
        -- SET
        ,p_user_id
        ,p_role_name
        ,p_role_name
        ,p_user_id
        ,p_user_id
        ,p_user_id
        -- RESPALL
        ,p_user_id
        ,p_role_name
        ,p_user_id
        ,p_role_name
        --RESPME
        ,p_user_id
        ,p_role_name
        ,p_user_id
        ,p_role_name
        --RESPSET
        ,p_user_id
        ,p_role_name
        ,p_user_id
        ,p_role_name
        ;
    FETCH c_violated_cst_dynamic_sql BULK COLLECT INTO new_role_list, violated_cst_rev_id_list;
    CLOSE c_violated_cst_dynamic_sql;

    IF violated_cst_rev_id_list IS NULL OR NOT violated_cst_rev_id_list.exists(1) THEN
        RETURN;
    END IF;

    FOR i in 1 .. violated_cst_rev_id_list.COUNT
    LOOP
        -- The Constraint _id is associated to the control. So we get the
        --Constraint _id corresponding to the violated constraint_rev_id
        SELECT  constraint_id into l_constraint_id
        FROM    AMW_CONSTRAINTS_VL
        WHERE   constraint_rev_id=violated_cst_rev_id_list(i);

        -- A constraint can be associate to many controls. So we get the all
        -- the constrols with source as the constraint.
        OPEN C_Control_Ids(l_constraint_id);
        FETCH C_Control_Ids BULK COLLECT INTO associated_cont_ids_list;
        CLOSE C_Control_Ids;

        -- For each control we find the affected process owner
        -- and send notification to them
        FOR k IN 1 .. associated_cont_ids_list.COUNT
        LOOP
            -- get all the affected process owners
            OPEN C_Proc_Owner(associated_cont_ids_list(k));
            FETCH C_Proc_Owner BULK COLLECT INTO affected_proc_owner_id_list;
            CLOSE C_Proc_Owner;

            IF affected_proc_owner_id_list IS NOT NULL THEN
                FOR j in 1 ..affected_proc_owner_id_list.COUNT
                LOOP
                    IF affected_proc_owner_id_list(j) IS NOT NULL THEN
                        Send_Notif_To_Process_Owner(
                            p_item_type         => p_item_type,
            	            p_message_name      => p_message_name,
                            p_user_id           => p_user_id,
                            p_role_name         => p_role_name,
                            p_assigned_by_id    => p_assigned_by_id,
                            p_constraint_rev_id => violated_cst_rev_id_list(i),
                            p_process_owner_id  => affected_proc_owner_id_list(j),
                            x_return_status     => l_return_status);
                    END IF;--end of if: affected_proc_owner_id_list(j) IS NOT NULL
                END LOOP; -- end of for: affected_proc_owner_id_list.COUNT
            END IF; --end of if: affected_proc_owner_id_list IS NOT NULL
        END LOOP; --end of for :associated_cont_ids_list.COUNT
    END LOOP; --end of for: violated_cst_rev_id_list.COUNT
EXCEPTION
   WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.LOG,'unexpected error in Send_Notif_To_Affected_Process: '||sqlerrm);
      l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Send_Notif_To_Affected_Process;

-- ===============================================================
-- Procedure name
--          Send_Notif_To_Process_Owner
--
-- Purpose
--          send violation notification to specified process owner
-- Params
--          p_item_type       := worflow template (default : AMWNOTIF)
--          p_message_name    := workflow mesg template (default : MWVIOLATUSERROLENOTIF)
--          p_user_name       := the user who got the role assigned
--          p_role_name       := the new role which is assigned to this user
--          p_assigned_date   := the assigned date
--          p_assigned_by_id  := the role is assigned by which user (user_id)
--          p_constraint_rev_id   := which constraint has been violated
--          p_process_owner_id    := the process owner of that constraint, to whom this notif will be sent
--
-- History
-- 		  	07/29/2005    tsho     Create
--          02/23/2006    psomanat removied the parameter p_user_name
--          02/23/2006    psomanat added the parameter p_user_id
-- ===============================================================
Procedure Send_Notif_To_Process_Owner(
    p_item_type           IN VARCHAR2 := 'AMWNOTIF',
	p_message_name        IN VARCHAR2 := 'VIOLATIONNOTIF',
    p_user_id             IN NUMBER,
    p_role_name           IN VARCHAR2,
    p_assigned_by_id      IN NUMBER,
    p_constraint_rev_id   IN NUMBER,
    p_process_owner_id    IN NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2
)
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Send_Notif_To_Process_Owner';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

    l_constraint_name    VARCHAR2(240);
    l_to_role_name       VARCHAR2(100);
    l_display_role_name	 VARCHAR2(320);
    l_subject		     VARCHAR2(2000);
    l_user_name		     Varchar2(240);
    l_role_name          VARCHAR2(320) :=p_role_name;
    l_assigned_by_id     NUMBER :=p_assigned_by_id;
    l_notif_id		     NUMBER;
    emp_id_list          G_NUMBER_TABLE;

    cursor c_constraint (l_constraint_rev_id NUMBER) is
       select constraint_name
       from   amw_constraints_vl
       where  constraint_rev_id = l_constraint_rev_id;

    cursor c_person (c_party_id NUMBER) is
       select employee_id
       from   amw_employees_current_v
       where  party_id = c_party_id;

    TYPE curTyp IS REF CURSOR;
    c_user_dynamic_sql curTyp;
    l_user_dynamic_sql   VARCHAR2(200)  :=
            'SELECT u.user_name '
          ||'  FROM '||G_AMW_USER ||' u '
          ||' WHERE u.user_id = :1  ';
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    open c_constraint(p_constraint_rev_id);
    fetch c_constraint into l_constraint_name;
    close c_constraint;

    open c_person(p_process_owner_id);
    fetch c_person bulk collect into emp_id_list;
    close c_person;

    FOR i in 1 .. emp_id_list.COUNT
    LOOP
        l_to_role_name:=NULL;

        WF_DIRECTORY.getrolename(   p_orig_system      => 'PER',
	                                p_orig_system_id   => emp_id_list(i),
                                    p_name             => l_to_role_name,
                                    p_display_name     => l_display_role_name );

        IF l_to_role_name IS NULL THEN

            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.set_name('AMW','AMW_APPR_INVALID_ROLE');
            FND_MSG_PUB.ADD;
            fnd_file.put_line(fnd_file.LOG, 'to_role is null');
        ELSE

            OPEN c_user_dynamic_sql FOR l_user_dynamic_sql USING
                p_user_id;
            FETCH c_user_dynamic_sql INTO l_user_name;
            CLOSE c_user_dynamic_sql;

            FND_MESSAGE.set_name('AMW', 'AMW_VIOLAT_CONFIRM_NOTIF_SUBJ');
            FND_MESSAGE.set_token('CONSTRAINT_NAME', l_constraint_name, TRUE);
            FND_MESSAGE.set_token('USER_NAME', l_user_name, TRUE);
            FND_MSG_PUB.add;
            l_subject := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.G_LAST,
				                         p_encoded => fnd_api.g_false);

            l_notif_id := WF_NOTIFICATION.send(
                role => l_to_role_name,
			     msg_type => p_item_type,
			     msg_name => p_message_name);

            WF_NOTIFICATION.SetAttrText(l_notif_id,'VN_MSG_SUBJECT',l_subject);
            WF_NOTIFICATION.setattrnumber(l_notif_id,'VN_CONSTRAINT_REV_ID',p_constraint_rev_id);
            WF_NOTIFICATION.SetAttrText(l_notif_id,'VN_ROLE_NAME',l_role_name);
            WF_NOTIFICATION.setattrnumber(l_notif_id,'VN_USER_ID',p_user_id);
            WF_NOTIFICATION.setattrnumber(l_notif_id,'VN_ASSIGNED_BY_ID',l_assigned_by_id);

        END IF; --end of if: l_to_role_name IS NULL
    END LOOP; --end of for: emp_id_list.COUNT
EXCEPTION
   WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.LOG,'unexpected error in Send_Notif_To_Process_Owner: '||sqlerrm);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;


-- ===============================================================
-- Function name
--          Violation_Detail_Due_To_Resp
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
Function Violation_Detail_Due_To_Resp (
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
l_violat_new_resp VARCHAR2(100);

-- find all valid constraints
CURSOR c_all_valid_constraints IS
      SELECT constraint_rev_id, type_code, constraint_name, objective_code
        FROM amw_constraints_vl
       WHERE start_date <= sysdate AND (end_date IS NULL OR end_date >= sysdate);
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
  ||'  from amw_role_constraint_denorm rcd '
  ||'      ,'||G_AMW_RESPONSIBILITY_VL||' resp '
  ||'  where rcd.constraint_rev_id = :1 and resp.responsibility_id = :2 '
  ||'    and rcd.responsibility_id = resp.responsibility_id ';

-- get valid user waiver
l_valid_user_waiver_count NUMBER;
CURSOR c_valid_user_waivers (l_constraint_rev_id IN NUMBER, l_user_id IN NUMBER) IS
    SELECT count(*)
      FROM amw_constraint_waivers
     WHERE constraint_rev_id = l_constraint_rev_id
       AND object_type = 'USER'
       AND PK1 = l_user_id
       AND start_date <= sysdate AND (end_date >= sysdate or end_date is null);

BEGIN
  -- default to 'N', which means user doesn't have violations
  has_violation := 'N';
  l_violat_existing_resp := NULL;
  l_violat_existing_role := NULL;
  l_violat_existing_menu := NULL;
  l_violat_new_resp := NULL;
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

     -- 08.22.2005 tsho: consider only Prevent Constraint Objective
     -- IF l_valid_user_waiver_count <= 0 THEN
     IF l_valid_user_waiver_count <= 0 AND l_all_valid_constraints.objective_code = 'PR' THEN

      -- get the name of the new responsibility if combining this will results in violation against this constraint
      OPEN new_resp_c FOR l_new_resp_dynamic_sql USING
         l_all_valid_constraints.constraint_rev_id
        ,p_responsibility_id;
      FETCH new_resp_c INTO l_violat_new_resp;
      CLOSE new_resp_c;

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
          has_violation := l_violat_new_resp;
          IF l_violat_existing_resp IS NOT NULL THEN
            IF has_violation IS NOT NULL THEN
              has_violation := has_violation||', ';
            END IF;
            has_violation := has_violation||l_violat_existing_resp;
          END IF;
          IF l_violat_existing_role IS NOT NULL THEN
            IF has_violation IS NOT NULL THEN
              has_violation := has_violation||', ';
            END IF;
            has_violation := has_violation||l_violat_existing_role;
          END IF;
          IF l_violat_existing_menu IS NOT NULL THEN
            IF has_violation IS NOT NULL THEN
              has_violation := has_violation||', ';
            END IF;
            has_violation := has_violation||l_violat_existing_menu;
          END IF;

		  fnd_message.set_name('AMW', 'AMW_SOD_VIOLATION');
	      fnd_message.set_token('CONSTRAINT', l_all_valid_constraints.constraint_name);
	      fnd_message.set_token('CONST_DETAILS', has_violation);
          return fnd_message.get;
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
          has_violation := l_violat_new_resp;
          IF l_violat_existing_resp IS NOT NULL THEN
            IF has_violation IS NOT NULL THEN
              has_violation := has_violation||', ';
            END IF;
            has_violation := has_violation||l_violat_existing_resp;
          END IF;
          IF l_violat_existing_role IS NOT NULL THEN
            IF has_violation IS NOT NULL THEN
              has_violation := has_violation||', ';
            END IF;
            has_violation := has_violation||l_violat_existing_role;
          END IF;
          IF l_violat_existing_menu IS NOT NULL THEN
            IF has_violation IS NOT NULL THEN
              has_violation := has_violation||', ';
            END IF;
            has_violation := has_violation||l_violat_existing_menu;
          END IF;

		  fnd_message.set_name('AMW', 'AMW_SOD_VIOLATION');
	      fnd_message.set_token('CONSTRAINT', l_all_valid_constraints.constraint_name);
	      fnd_message.set_token('CONST_DETAILS', has_violation);
          return fnd_message.get;
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
          has_violation := l_violat_new_resp;
          IF l_violat_existing_resp IS NOT NULL THEN
            IF has_violation IS NOT NULL THEN
              has_violation := has_violation||', ';
            END IF;
            has_violation := has_violation||l_violat_existing_resp;
          END IF;
          IF l_violat_existing_role IS NOT NULL THEN
            IF has_violation IS NOT NULL THEN
              has_violation := has_violation||', ';
            END IF;
            has_violation := has_violation||l_violat_existing_role;
          END IF;
          IF l_violat_existing_menu IS NOT NULL THEN
            IF has_violation IS NOT NULL THEN
              has_violation := has_violation||', ';
            END IF;
            has_violation := has_violation||l_violat_existing_menu;
          END IF;

		  fnd_message.set_name('AMW', 'AMW_SOD_VIOLATION');
	      fnd_message.set_token('CONSTRAINT', l_all_valid_constraints.constraint_name);
	      fnd_message.set_token('CONST_DETAILS', has_violation);
          return fnd_message.get;
        END IF;
      ELSE
        -- other constraint types
        NULL;
      END IF; -- end of if: constraint type_code

     END IF; --end of if: l_valid_user_waiver_count > 0

    END LOOP; --end of loop: c_all_valid_constraints
    CLOSE c_all_valid_constraints;

  END IF; -- end of if: p_user_id IS NOT NULL AND p_responsibility_id IS NOT NULL

  return has_violation;
END;




/*
 * cpetriuc
 * -------------
 * MENU_VIOLATES
 * -------------
 * Checks if the menu provided as argument violates any SOD (Segregation of Duties)
 * constraints.  If a constraint is violated, the function returns an error message
 * containing the name of the violated constraint together with the list of functions
 * that define the constraint.  Otherwise, the function returns 'N'.
 */
function MENU_VIOLATES(p_menu_id NUMBER) return VARCHAR2 is

g_constraint_function_id_list G_NUMBER_TABLE;
g_constraint_group_code_list G_NUMBER_TABLE;
g_group_code_list G_NUMBER_TABLE;
g_menu_function_id_list G_NUMBER_TABLE;
m_constraint_details VARCHAR2(3000);
m_counter NUMBER;
m_failed BOOLEAN;
m_function_name VARCHAR2(240);
m_return_text VARCHAR2(3000);


cursor MENU_FUNCTIONS(p_menu_id NUMBER) is
select distinct FUNCTION_ID
from FND_COMPILED_MENU_FUNCTIONS
where MENU_ID = p_menu_id;

cursor CONSTRAINTS is
select *
from AMW_CONSTRAINTS_VL
where
(TYPE_CODE = 'ALL' or TYPE_CODE = 'ME' or TYPE_CODE = 'SET') and
START_DATE <= sysdate and
(END_DATE is null or END_DATE >= sysdate);

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

open MENU_FUNCTIONS(p_menu_id);
fetch MENU_FUNCTIONS bulk collect into g_menu_function_id_list;
close MENU_FUNCTIONS;

for constraint in CONSTRAINTS loop

m_failed := FALSE;

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

if m_counter >= 2 then m_failed := TRUE; end if;

end if;

------------------------------------
-- Process a constraint of type SET.
------------------------------------
if constraint.TYPE_CODE = 'SET' then

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

-----------------------------------------------------------------------
-- If this constraint has been violated, return an appropriate message.
-----------------------------------------------------------------------
if m_failed = TRUE then

FND_MESSAGE.SET_NAME('AMW', 'AMW_SOD_VIOLATION');
FND_MESSAGE.SET_TOKEN('CONSTRAINT', constraint.CONSTRAINT_NAME);
FND_MESSAGE.SET_TOKEN('CONST_DETAILS', m_constraint_details);
m_return_text := FND_MESSAGE.GET;

return m_return_text;

end if;

end loop;  -- CONSTRAINTS cursor loop

return 'N';


end MENU_VIOLATES;




/*
 * cpetriuc
 * ----------------------
 * FUNCTION_VIOLATES_MENU
 * ----------------------
 * Checks if any SOD (Segregation of Duties) constraints would be violated if the
 * argument function would be added to the menu provided as argument.  If a constraint
 * would be violated, the function returns an error message containing the name of the
 * potentially violated constraint together with the list of functions that define the
 * constraint.  Otherwise, the function returns 'N'.
 */
function FUNCTION_VIOLATES_MENU(p_menu_id NUMBER, p_function_id NUMBER) return VARCHAR2 is

g_constraint_function_id_list G_NUMBER_TABLE;
g_constraint_group_code_list G_NUMBER_TABLE;
g_group_code_list G_NUMBER_TABLE;
g_menu_function_id_list G_NUMBER_TABLE;
m_constraint_details VARCHAR2(3000);
m_failed BOOLEAN;
m_function_name VARCHAR2(240);
m_return_text VARCHAR2(3000);


cursor MENU_FUNCTIONS(p_menu_id NUMBER) is
select distinct FUNCTION_ID
from FND_COMPILED_MENU_FUNCTIONS
where MENU_ID in
(
select MENU_ID
from FND_MENU_ENTRIES
start with MENU_ID = p_menu_id
connect by prior MENU_ID = SUB_MENU_ID
);

cursor CONSTRAINTS is
select *
from AMW_CONSTRAINTS_VL
where
(TYPE_CODE = 'ALL' or TYPE_CODE = 'ME' or TYPE_CODE = 'SET') and
START_DATE <= sysdate and
(END_DATE is null or END_DATE >= sysdate);

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

open MENU_FUNCTIONS(p_menu_id);
fetch MENU_FUNCTIONS bulk collect into g_menu_function_id_list;
close MENU_FUNCTIONS;

for constraint in CONSTRAINTS loop

m_failed := FALSE;

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
else m_failed := TRUE;  -- If i = j, continue the loop.
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
m_return_text := FND_MESSAGE.GET;

return m_return_text;

end if;

end if;  -- if g_constraint_function_id_list(i) = p_function_id
end loop;  -- g_constraint_function_id_list loop

end loop;  -- CONSTRAINTS cursor loop

return 'N';


end FUNCTION_VIOLATES_MENU;

-- ----------------------------------------------------------------------
END AMW_VIOLATION_PVT;

/
