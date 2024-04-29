--------------------------------------------------------
--  DDL for Package Body QP_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_SECURITY" AS
/* $Header: QPXSECUB.pls 120.3.12010000.2 2008/08/29 10:47:21 hmohamme ship $ */
G_MENU_MAINTAIN_ID NUMBER := null;
FUNCTION GET_OBJECT_ID_FOR_INSTANCE(p_instance_type IN VARCHAR2 default null)
RETURN NUMBER IS
v_object_id NUMBER := null;
v_object_name VARCHAR2(30) := null;
v_instance_type qp_grants.instance_type%TYPE; --VARCHAR2(5);
BEGIN

v_instance_type := nvl(p_instance_type, 'ALL');

IF(G_INSTANCE_TYPE_CACHE = v_instance_type) THEN
  v_object_id := G_OBJECT_ID_CACHE;
ELSE
  BEGIN
  IF(G_PRICELIST_OBJECT = v_instance_type OR
    G_MODIFIER_OBJECT = v_instance_type OR
    G_AGREEMENT_OBJECT = v_instance_type OR
    v_instance_type = 'ALL') THEN
    v_object_name := 'QP_LIST_HEADERS';
  ELSIF(G_FORMULA_OBJECT = v_instance_type) THEN
    v_object_name := 'QP_PRICE_FORMULAS';
  END IF;

  SELECT object_id
  INTO v_object_id
  FROM FND_OBJECTS
  WHERE obj_name = v_object_name and application_id=661;

  G_INSTANCE_TYPE_CACHE := v_instance_type;
  G_OBJECT_ID_CACHE := v_object_id;
  END;
END IF;

RETURN v_object_id;
END;

FUNCTION GET_OBJECT_NAME_FOR_INSTANCE(p_instance_type IN VARCHAR2)
RETURN VARCHAR2 IS
v_object_name VARCHAR2(30) := null;
v_instance_type qp_grants.instance_type%TYPE;--varchar2(10);
BEGIN
 v_instance_type := nvl(p_instance_type, 'ALL');

  IF(G_PRICELIST_OBJECT = v_instance_type OR
    G_MODIFIER_OBJECT = v_instance_type OR
    G_AGREEMENT_OBJECT = v_instance_type OR
    v_instance_type = 'ALL') THEN
    v_object_name := 'QP_LIST_HEADERS';
  ELSIF(G_FORMULA_OBJECT = v_instance_type) THEN
    v_object_name := 'QP_PRICE_FORMULAS';
  END IF;
  RETURN v_object_name;
END;

FUNCTION GET_FUNCTION_ID(p_function_name IN VARCHAR2)
RETURN NUMBER IS
v_function_id NUMBER;

BEGIN
IF(p_function_name = G_FUNCTION_NAME_CACHE) THEN
	v_function_id := G_FUNCTION_ID_CACHE; /*we have it cached,use it*/
ELSE /*didn't cached, hit db*/
  SELECT function_id
  INTO v_function_id
  FROM FND_FORM_FUNCTIONS
  WHERE function_name = p_function_name;
  /*store in cache*/
  g_function_name_cache := p_function_name;
  g_function_id_cache := v_function_id;
END IF;
RETURN v_function_id;
END;

FUNCTION GET_USER_ID(l_user_name IN VARCHAR2)
RETURN NUMBER IS
v_user_id NUMBER;
BEGIN
        /* commented for FP 7310389 If G_USER_ID Is NULL or l_user_name <> G_USER_NAME
        Then*/
	  SELECT USER_ID
	  INTO G_USER_ID
	  FROM FND_USER
	  WHERE USER_NAME = l_user_name;
          G_USER_NAME := l_user_name;
        --End If;

        RETURN G_USER_ID;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		return -1;
END;
/*+----------------------------------------------------------------------
  | Function check_function
  | API name: check_function
  | TYPE:  Public
  | FUNCTION: Determines whether user is granted a particular
  |           function for a particular pricing entity
  | Input:  p_function_name ->
  | 		QP_SECU_VIEW
  | 		QP_SECU_UPDATE
  | Input:  p_instance_type ->
  |		'PRL' for standard pricelist
  |		'MOD' for modifier
  |		'AGR' for agreement pricelist
  |		'FOR' for formula -- not used yet
  | Input:  p_instance_pk1_value -> list_header_id in qp_list_headers_b
  |			 other primary key for formulas, qualifiers...
  |         p_instance_pk2_value -> optional, not used currently
  |	    p_instance_pk3_vaue -> optional, not used currently
  | Input:  p_user_name -> optional, default is current user
  |         p_resp_id -> optional, default is current logged in responsibility
  |         p_org_id -> optional,default is current logged in operating unit
  | Output: varchar2 ->
  |    G_AUTHORIZED='T': authorized
  |    G_DENIED='F':denied
  |    G_ERROR='E': error happened
  +----------------------------------------------------------------------
*/
FUNCTION check_function(
        p_function_name IN VARCHAR2,
	p_instance_type  IN VARCHAR2,
        p_instance_pk1 IN  NUMBER,
        p_instance_pk2 IN  NUMBER default null,
        p_instance_pk3 IN  NUMBER default null,
	p_user_name IN VARCHAR2 default null,
        p_resp_id IN NUMBER default null,
 	p_org_id IN NUMBER default null
) RETURN VARCHAR2 IS
	E_ROUTINE_ERROR EXCEPTION;
	l_security_control varchar2(5);
	l_user_name varchar2(80);
	l_sysdate DATE := sysdate;
        l_user_id NUMBER;
        l_resp_id NUMBER;
	l_org_id NUMBER;
	l_result VARCHAR2(1);
	l_status VARCHAR2(1);
	l_object_name VARCHAR2(30);
	l_function_id NUMBER;
	l_object_id NUMBER;
	error_message VARCHAR2(1000);
        l_mo_access_mode VARCHAR2(30);
  CURSOR qp_grants_c (  cp_user_id       NUMBER,
			cp_resp_id       NUMBER,
			cp_org_id        NUMBER,
                        cp_function_id   NUMBER,
                        cp_object_id NUMBER,
                        cp_instance_id  NUMBER,
                        cp_mo_access_mode VARCHAR2
  ) IS
     SELECT 'X'
     FROM qp_grants g
     WHERE rownum = 1
	AND g.object_id = cp_object_id
	AND ( ( g.grantee_type = 'USER' AND
                g.grantee_id =  cp_user_id) OR
            ( g.grantee_type = 'RESP' AND
              g.grantee_id = cp_resp_id) OR
            ( g.grantee_type = 'GLOBAL' AND
              g.grantee_id = -1) OR
            ( g.grantee_type = 'OU' AND
              ((cp_mo_access_mode = 'S' and g.grantee_id = sys_context('multi_org2','current_org_id'))
              or (cp_mo_access_mode = 'M' and mo_global.check_access(g.grantee_id) = 'Y')
              or (cp_mo_access_mode = 'A')))
--              g.grantee_id = cp_org_id)
           ) AND
	   g.menu_id IN
               (select cmf.menu_id
                 from fnd_compiled_menu_functions cmf
                where cmf.function_id = cp_function_id)
      AND (G.instance_id = cp_instance_id)
      AND ( g.end_date  IS NULL OR g.end_date >= l_sysdate )
      AND g.start_date <= l_sysdate;

BEGIN
--added for moac
l_mo_access_mode := MO_GLOBAL.get_access_mode;

-- the global_flag in qp_list_headers_b table is for run-time engine use
-- only. For setup time, we use 'GLOBAL' as a grantee, and if a pricing
-- entity is granted to 'GLOBAL' with a specific function, it becomes
-- globally accessed with such function.

l_security_control := nvl(FND_PROFILE.value(G_SECURITY_CONTROL_PROFILE), G_SECURITY_OFF);
IF(l_security_control = G_SECURITY_OFF) THEN /*always return authorized*/
  RETURN G_AUTHORIZED;
ELSE /*security is on*/
  IF(( p_function_name is NULL) or (p_instance_type is NULL)
	or (p_instance_pk1 is NULL)) THEN
		RAISE E_ROUTINE_ERROR;
  END IF;

  -- Default the user name if not passed in
  IF( p_user_name is NULL) THEN
	l_user_name := FND_GLOBAL.USER_NAME;
  ELSE
	l_user_name := p_user_name;
  END IF;

  l_user_id := GET_USER_ID(l_user_name);

  --GET_ORIG_KEY(l_user_name, l_orig_system, l_orig_system_id);

  -- Default the responsibility id if not passed in
  IF( p_resp_id is NULL) THEN
	l_resp_id := FND_GLOBAL.RESP_ID;
  ELSE
	l_resp_id := p_resp_id;
  END IF;
  --CHECK_RESP_FOR_USER(l_user_name, l_resp_id);

  -- Default the operating unit id if not passed in
/*
  IF( p_org_id is NULL) THEN
	l_org_id := FND_PROFILE.VALUE('ORG_ID');
  ELSE
	l_org_id := p_org_id;
  END IF;
*/
  --added for MOAC to populate operating_unit
  l_org_id := nvl(p_org_id, QP_UTIL.get_org_id);

  --CHECK_ORG_FOR_USER(l_user_name, l_org_id);

  -- get object_id from instance_type
  l_object_id := GET_OBJECT_ID_FOR_INSTANCE(p_instance_type);
  l_object_name := GET_OBJECT_NAME_FOR_INSTANCE(p_instance_type);
  -- get function_id from function_name
  l_function_id := GET_FUNCTION_ID(p_function_name);

  /* check qp_grants table and see if the fnd_menu_id for the object
   includes the ask-for function or not
   if no data found, which means no any access on the object,
   return DENIED
   or ask for a function which doesn't be included in the object role,
   return DENIED;
  */
  BEGIN
    -----------------open cursor here
    OPEN qp_grants_c(l_user_id,
		     l_resp_id,
                     l_org_id,
                     l_function_id,
                     l_object_id,
                     p_instance_pk1, l_mo_access_mode);

    FETCH qp_grants_c INTO l_result;
    CLOSE qp_grants_c;

    IF ( l_result = 'X') THEN
	RETURN G_AUTHORIZED;
    END IF;
  EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN G_DENIED;
  END;

  /* check fnd_grants table and see the access_role for the object
     instead of calling FND_DATA_SECURITY.check_function,
     call get_security_predicate() could improve performance
   */
	FND_MSG_PUB.initialize;
	l_status := FND_DATA_SECURITY.check_function(
			p_api_version => 1.0,
			p_function => p_function_name,
			p_object_name => l_object_name,
			p_instance_pk1_value => p_instance_pk1,
			p_instance_pk2_value => null,
			p_instance_pk3_value => null,
 			p_instance_pk4_value => null,
			p_instance_pk5_value => null,
			p_user_name =>l_user_name );
  	IF(l_status = 'F') THEN
		RETURN G_DENIED;
	ELSIF(l_status = 'T') THEN
		RETURN G_AUTHORIZED;
	ELSE
		RAISE E_ROUTINE_ERROR;
	END IF;

  RETURN G_DENIED;
END IF; /*end security is on*/
EXCEPTION
	WHEN E_ROUTINE_ERROR THEN
		error_message := FND_MESSAGE.GET_ENCODED;
		RETURN G_ERROR;
END;


/*+----------------------------------------------------------------------
  | Function auth_instances
  | API name: auth_instances
  | TYPE: Public
  | FUNCTION: Get all pricing entities ids which can be accessed by
  | the use with the particular function
  | Input:  p_function_name ->
  |           'QP_SECU_VIEW' for view, 'QP_SECU_UPDATE' for update
  | Input:  p_instance_type ->
  |	      'PRL' for standard pricelists,
  |           'MOD' for modifier,
  |           'AGR' for agreement pricelists,
  |           'FOR' for formulas --not used yet
  |           null for all list headers
  | Input:  p_user_name -> optional, default is current user
  |         p_resp_id -> optional, default is current logged in
  |			 responsibility
  |         p_org_id -> optional, default is current logged in
  |                     operating unit
  | Output: system.qp_inst_pk_vals ->
  | 	all the object ids which can be accessed with the specific
  |     function for current user
  +----------------------------------------------------------------------
*/

FUNCTION auth_instances(
 p_function_name IN VARCHAR2,
 p_instance_type IN VARCHAR2 default null,
 p_user_name IN VARCHAR2 default G_USER_NAME,
 p_resp_id IN NUMBER default G_RESP_ID,
 p_org_id IN NUMBER default G_ORG_ID
) RETURN system.qp_inst_pk_vals IS
  l_instance_pk1_value	fnd_grants.instance_pk1_value%TYPE;
  l_instance_pk2_value	fnd_grants.instance_pk2_value%TYPE;
  l_instance_pk_values	system.qp_inst_pk_vals := system.qp_inst_pk_vals();
  TYPE qp_inst_pk_vals_cur_type IS REF CURSOR;
  qp_inst_pk_vals_cur	qp_inst_pk_vals_cur_type;
  err_msg	varchar2(256);
  count_num number := 0;

  l_database_object_name fnd_objects.database_object_name%TYPE;
  l_pk1_column_name  fnd_objects.pk1_column_name%TYPE;
  l_pk2_column_name  fnd_objects.pk2_column_name%TYPE;
  l_predicate varchar2(32767);
  l_return_status varchar2(1);
  l_sql_stmt varchar2(32767);

  l_security_control varchar2(5);
  l_grantee_type	varchar2(10);
  l_grantee_id		number;
  E_ROUTINE_ERROR EXCEPTION;
  l_user_id NUMBER;
  l_user_name VARCHAR2(80);
  l_resp_id NUMBER;
  l_org_id NUMBER;
  l_sysdate DATE := sysdate;
  l_object_id number;
  l_function_id number;
  l_object_name varchar2(30);
  error_message varchar2(1000);

  CURSOR l_pricelist_id_cur IS
	SELECT list_header_id
	FROM qp_list_headers_b
	WHERE list_type_code = G_PRICELIST_TYPE;

  CURSOR l_modifier_id_cur IS
	SELECT list_header_id
	FROM qp_list_headers_b
	WHERE list_type_code in (G_MODIFIER_SUR,G_MODIFIER_PRO,
		G_MODIFIER_DLT,G_MODIFIER_DEL,G_MODIFIER_CHARGES);

  CURSOR l_agreement_id_cur IS
	SELECT list_header_id
	FROM qp_list_headers_b
	WHERE list_type_code = G_AGREEMENT_TYPE;

  CURSOR l_list_headers_id_cur IS
	SELECT list_header_id
	FROM qp_list_headers_b;

  CURSOR l_grants_list_headers_id_cur(cp_user_id NUMBER,
				      cp_resp_id NUMBER,
				      cp_org_id NUMBER,
			              cp_function_id NUMBER,
				      cp_object_id NUMBER
				      ) IS
	SELECT  g.instance_id
	FROM    qp_grants g
	WHERE   ((g.grantee_type = 'USER' AND
		 g.grantee_id = cp_user_id) OR
		(g.grantee_type = 'RESP' AND
		 g.grantee_id = cp_resp_id) OR
                (g.grantee_type = 'OU' AND
		 g.grantee_id = cp_org_id) OR
		(g.grantee_type = 'GLOBAL' AND
		g.grantee_id = -1)) AND
		g.object_id = cp_object_id AND
		g.menu_id IN
		(SELECT cmf.menu_id
		 FROM fnd_compiled_menu_functions cmf
		 WHERE cmf.function_id = cp_function_id) AND
                (g.end_date IS NULL OR g.end_date >= l_sysdate) AND
		g.start_date <= l_sysdate;

  CURSOR l_grants_entities_id_cur(cp_user_id NUMBER,
				      cp_resp_id NUMBER,
				      cp_org_id NUMBER,
			              cp_function_id NUMBER,
				      cp_object_id NUMBER,
				      cp_instance_type VARCHAR2
				      ) IS
	SELECT  g.instance_id
	FROM    qp_grants g
	WHERE   ((g.grantee_type = 'USER' AND
		 g.grantee_id = cp_user_id) OR
		(g.grantee_type = 'RESP' AND
		 g.grantee_id = cp_resp_id) OR
                (g.grantee_type = 'OU' AND
		 g.grantee_id = cp_org_id) OR
		(g.grantee_type = 'GLOBAL' AND
		g.grantee_id = -1)) AND
		g.object_id = cp_object_id AND
		g.instance_type = cp_instance_type AND
		g.menu_id IN
		(SELECT cmf.menu_id
		 FROM fnd_compiled_menu_functions cmf
		 WHERE cmf.function_id = cp_function_id) AND
                (g.end_date IS NULL OR g.end_date >= l_sysdate) AND
		g.start_date <= l_sysdate;
BEGIN
 /* we have three profile for security
   QP_SECURITY_CONTROL: ON/OFF
   QP_SECUIRTY_DEFAULT_VIEW: NONE, OU, RESP, USER
   QP_SECURITY_DEFAULT_UPDATE: NONE, OU, RESP, USER
  */
 /* check 'QP_SECURITY_CONTROL' profile to see security is on/off.
   In case of 'OFF', return all object ids
  */
l_security_control := nvl(FND_PROFILE.value(G_SECURITY_CONTROL_PROFILE), G_SECURITY_OFF);

IF(l_security_control = G_SECURITY_OFF) THEN
	/*return all list_headers_id */
    IF( p_instance_type = G_PRICELIST_OBJECT) THEN
    	OPEN l_pricelist_id_cur;
    	LOOP
            FETCH 	l_pricelist_id_cur
            INTO 	l_instance_pk1_value;
            EXIT WHEN l_pricelist_id_cur%NOTFOUND;
            l_instance_pk2_value := null;

            l_instance_pk_values.extend;
	    count_num:= count_num + 1;
            l_instance_pk_values(l_instance_pk_values.last):=
   		system.qp_inst_pk_vals_object(l_instance_pk1_value,
			       l_instance_pk2_value);
       END LOOP;
       CLOSE l_pricelist_id_cur;
    ELSIF( p_instance_type = G_MODIFIER_OBJECT) THEN
    	OPEN l_modifier_id_cur;
    	LOOP
            FETCH 	l_modifier_id_cur
            INTO 	l_instance_pk1_value;
            EXIT WHEN l_modifier_id_cur%NOTFOUND;
            l_instance_pk2_value := null;

            l_instance_pk_values.extend;
	    count_num:= count_num + 1;
            l_instance_pk_values(l_instance_pk_values.last):=
   		system.qp_inst_pk_vals_object(l_instance_pk1_value,
			       l_instance_pk2_value);
       END LOOP;
       CLOSE l_modifier_id_cur;
    ELSIF( p_instance_type = G_AGREEMENT_OBJECT) THEN
	OPEN l_agreement_id_cur;
	LOOP
            FETCH 	l_agreement_id_cur
            INTO 	l_instance_pk1_value;
            EXIT WHEN l_agreement_id_cur%NOTFOUND;
            l_instance_pk2_value := null;

            l_instance_pk_values.extend;
	    count_num:= count_num + 1;
            l_instance_pk_values(l_instance_pk_values.last):=
   		system.qp_inst_pk_vals_object(l_instance_pk1_value,
			       l_instance_pk2_value);
        END LOOP;
	CLOSE l_agreement_id_cur;
    ELSE /*null for all*/
	OPEN l_list_headers_id_cur;
    	LOOP
            FETCH 	l_list_headers_id_cur
            INTO 	l_instance_pk1_value;
            EXIT WHEN l_list_headers_id_cur%NOTFOUND;
            l_instance_pk2_value := null;

            l_instance_pk_values.extend;
	    count_num:= count_num + 1;
            l_instance_pk_values(l_instance_pk_values.last):=
   		system.qp_inst_pk_vals_object(l_instance_pk1_value,
			       l_instance_pk2_value);
       END LOOP;
       CLOSE l_list_headers_id_cur;
    END IF;

    RETURN l_instance_pk_values;
ELSE /*security is on*/
  IF( p_function_name is NULL ) THEN
		RAISE E_ROUTINE_ERROR;
  END IF;

  -- Default the user name if not passed in
  IF( p_user_name is NULL) THEN
	l_user_name := FND_GLOBAL.USER_NAME;
  ELSE
	l_user_name := p_user_name;
  END IF;

  l_user_id := GET_USER_ID(l_user_name);
  --l_user_id := FND_GLOBAL.USER_ID;

  --GET_ORIG_KEY(l_user_name, l_orig_system, l_orig_system_id);

  -- Default the responsibility id if not passed in
  IF( p_resp_id is NULL) THEN
	l_resp_id := FND_GLOBAL.RESP_ID;
  ELSE
	l_resp_id := p_resp_id;
  END IF;
  --CHECK_RESP_FOR_USER(l_user_name, l_resp_id);

  -- Default the operating unit id if not passed in
/*
  IF( p_org_id is NULL) THEN
	l_org_id := to_number(FND_PROFILE.VALUE('ORG_ID'));
  ELSE
	l_org_id := p_org_id;
  END IF;
*/
  --added for MOAC
  l_org_id := nvl(p_org_id, QP_UTIL.get_org_id);

  --CHECK_ORG_FOR_USER(l_user_name, l_org_id);

  l_object_id := GET_OBJECT_ID_FOR_INSTANCE(p_instance_type);
  l_object_name := GET_OBJECT_NAME_FOR_INSTANCE(p_instance_type);
  l_function_id := GET_FUNCTION_ID(p_function_name);

  /*check qp_grants INSTANCE table to get all list_header_ids which
    can be accessed with the specific function*/
  IF ( p_instance_type is null) THEN /*get list_headers_id for all types*/
      OPEN l_grants_list_headers_id_cur(l_user_id,
					l_resp_id,
					l_org_id,
					l_function_id,
					l_object_id);
      LOOP
	FETCH 	l_grants_list_headers_id_cur
	INTO 	l_instance_pk1_value;
	EXIT WHEN l_grants_list_headers_id_cur%NOTFOUND;
	l_instance_pk2_value := null;
	l_instance_pk_values.extend;
	count_num:= count_num + 1;

	l_instance_pk_values(l_instance_pk_values.last):=
		system.qp_inst_pk_vals_object(l_instance_pk1_value,
				       l_instance_pk2_value);
      END LOOP;
      CLOSE l_grants_list_headers_id_cur;
  ELSIF( p_instance_type = G_PRICELIST_OBJECT or
	p_instance_type = G_MODIFIER_OBJECT or
	p_instance_type = G_AGREEMENT_OBJECT or
	p_instance_type = G_FORMULA_OBJECT) THEN
      OPEN l_grants_entities_id_cur(l_user_id,
				    l_resp_id,
				    l_org_id,
			            l_function_id,
				    l_object_id,
				    p_instance_type);
      LOOP
	FETCH 	l_grants_entities_id_cur
	INTO 	l_instance_pk1_value;
	EXIT WHEN l_grants_entities_id_cur%NOTFOUND;
	l_instance_pk2_value := null;
	l_instance_pk_values.extend;
	count_num:= count_num + 1;

	l_instance_pk_values(l_instance_pk_values.last):=
		system.qp_inst_pk_vals_object(l_instance_pk1_value,
				       l_instance_pk2_value);
      END LOOP;
      CLOSE l_grants_entities_id_cur;
  END IF;

----------------------------------------------------------------------
--  check fnd_grants SET table to get all list_header_ids which
--  can be accessed
------------------------------------------------------------------------
  --get database_object_name and primary key column name from FND_OBJECTS
  SELECT database_object_name,
	 pk1_column_name,
	 pk2_column_name
  INTO l_database_object_name,
       l_pk1_column_name,
	l_pk2_column_name
  FROM  fnd_objects
  WHERE obj_name = l_object_name;


  --get security predicate to filter authorized instances
  FND_DATA_SECURITY.get_security_predicate(
		p_api_version => 1.0,
		p_function => p_function_name,
		p_object_name => l_object_name,
		p_grant_instance_type =>'SET',
		p_user_name => p_user_name,
		x_predicate => l_predicate,
		x_return_status => l_return_status);

  IF(l_return_status = 'T') THEN
    --dynamically contruct a sql statement
    l_sql_stmt := 'Select ' ||
		nvl(l_pk1_column_name, 'NULL') ||
		' from ' || l_database_object_name ||
		' where ' || l_predicate;
    -- return collection of authorized objects ids
    OPEN qp_inst_pk_vals_cur FOR l_sql_stmt;
    LOOP
	FETCH qp_inst_pk_vals_cur
	INTO l_instance_pk1_value;
        EXIT WHEN qp_inst_pk_vals_cur%NOTFOUND;
	l_instance_pk2_value := null;
        l_instance_pk_values.extend;
	count_num:= count_num + 1;

	l_instance_pk_values(l_instance_pk_values.last) :=
		system.qp_inst_pk_vals_object(l_instance_pk1_value,
					l_instance_pk2_value);
    END LOOP;
    CLOSE qp_inst_pk_vals_cur;
  ELSIF(l_return_status = 'E' or
	l_return_status = 'U' or
	l_return_status = 'L') THEN  /*E, U, L*/
    error_message := FND_MESSAGE.GET_ENCODED;
    RAISE E_ROUTINE_ERROR;
  END IF;

  RETURN l_instance_pk_values;

END IF;	/*end security is on*/
/* catching general exceptions is necessary because oracle 8i terminates
   a connection upon encountering a pl_sql error in function
 */
EXCEPTION
WHEN E_ROUTINE_ERROR THEN
	return null;
WHEN OTHERS THEN
	err_msg := fnd_message.get;
END auth_instances;

FUNCTION  get_menu_id(p_menu_name IN VARCHAR2)
RETURN NUMBER IS
v_menu_id number;
BEGIN
  SELECT menu_id
  INTO v_menu_id
  FROM fnd_menus
  WHERE menu_name = p_menu_name;

  RETURN v_menu_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
  RETURN null;
END get_menu_id;

/*+----------------------------------------------------------------------
  | Procedure create_default_grants
  | API name: create_default_grants
  | TYPE: Public
  | PROCEDURE Create default grants for newly created pricing entitiy
  | based on the defaulting security profile settings.
  | IMPORANT NOTE: This API should be called ONLY when creating a NEW pricing entity.
  | Input:  p_instance_type ->
  |	      'PRL' for standard pricelists,
  |           'MOD' for modifier,
  |           'AGR' for agreement pricelists,
  |           'FOR' for formulas --not used yet
  | Input:  p_instance_pk1 -> id of the newly created pricing entity
  | 	    p_instance_pk2 -> not used in current release
  | 	    p_instance_pk3 -> not used in current release
  | Input:  p_user_name -> optional, default is current user
  |         p_resp_id -> optional, default is current logged in
  |			 responsibility
  |         p_org_id -> optional, default is current logged in
  |                     operating unit
  | Output: x_return_status ->
  |		'S'-> successfully done
  |		'E'-> error, possible reason is: p_instance_pk1 is already existing in qp_list_headers_b
  |                                             as one list_header_id. Make sure you didn't call commit()
  |                                             before you call this API when creating a new pricing entity.
  +----------------------------------------------------------------------
*/
PROCEDURE create_default_grants(p_instance_type IN VARCHAR2,
			p_instance_pk1 IN NUMBER,
			p_instance_pk2 IN NUMBER default null,
			p_instance_pk3 IN NUMBER default null,
			p_user_name IN VARCHAR2 default null,
			p_resp_id IN NUMBER default null,
			p_org_id IN NUMBER default null,
			x_return_status OUT NOCOPY VARCHAR2) IS
  l_security_control varchar2(5);
  l_security_default_viewonly varchar2(10);
  l_security_default_maintain varchar2(10);
  l_grantee_type varchar2(10);
  l_grantee_id number;
  l_user_name varchar2(30);
  l_grant_id number;
  l_object_id number;
  l_menu_id number;
  l_start_date date;
  l_end_date date;
  l_last_update_date date;
  l_last_updated_by number;
  l_creation_date number;
  l_created_by number;
  l_last_update_login number;
  l_list_type_code varchar2(30);
  CURSOR list_header_id_exist_cur(cp_instance_id number) IS
    SELECT list_type_code
    FROM qp_list_headers_b
    WHERE list_header_id = cp_instance_id;
  l_dummy varchar2(1);
  CURSOR grant_exist_cur(cp_grantee_type varchar2,
                         cp_grantee_id number,
                         cp_instance_type varchar2,
	                 cp_instance_id number,
                         cp_object_id number) IS
    SELECT 'X'
    FROM qp_grants
    WHERE grantee_type = cp_grantee_type  AND
	  grantee_id =  cp_grantee_id   AND
          instance_type =  cp_instance_type AND
	  instance_id =  cp_instance_id  AND
          object_id =   cp_object_id ;
BEGIN
 /* QP_SECUIRTY_DEFAULT_VIEW: GLOBAL, OU, RESP, USER, NONE
   QP_SECURITY_DEFAULT_UPDATE: GLOBAL, OU, RESP, USER, NONE
  */
 /* validate p_instance_pk1
  */
  OPEN list_header_id_exist_cur(p_instance_pk1);
  FETCH list_header_id_exist_cur into l_list_type_code;
  IF list_header_id_exist_cur%FOUND THEN
    IF(l_list_type_code <> p_instance_type) THEN
      IF(l_list_type_code not in ('CHARGES', 'DEL', 'DLT', 'PRO', 'SLT')
	or p_instance_type <> 'MOD') THEN
        x_return_status := 'E';
        CLOSE list_header_id_exist_cur;
        RETURN;
      END IF;/*else, 'CHARGES','DEL','DLT','PRO','SLT' matches 'MOD'. pass valdiation*/
    END IF; /*else 'AGR'='AGR' || 'PRL'='PRL'. pass validation*/
  END IF; /*else, new id*/
  CLOSE list_header_id_exist_cur;

 /* check 'QP_SECURITY_CONTROL' profile to see security is on/off.
   In case of 'OFF', return default is GLOBAL MAINTAIN
  */
l_security_control := nvl(FND_PROFILE.value(G_SECURITY_CONTROL_PROFILE), G_SECURITY_OFF);
IF(l_security_control = G_SECURITY_OFF) THEN
		/*security is off, do nothing*/
  l_security_default_viewonly := G_SECURITY_LEVEL_NONE;
  l_security_default_maintain := G_SECURITY_LEVEL_NONE;
ELSE/*security is on*/
  l_security_default_viewonly := nvl(FND_PROFILE.value(G_SECURITY_DEFAULT_VIEWONLY), G_SECURITY_LEVEL_GLOBAL);
  l_security_default_maintain := nvl(FND_PROFILE.value(G_SECURITY_DEFAULT_MAINTAIN), G_SECURITY_LEVEL_GLOBAL);
END IF;

--in case l_security_default_viewonly == l_security_default_maintain,
-- we only take l_security_default_maintain privilege
IF(l_security_default_viewonly <> G_SECURITY_LEVEL_NONE and
	l_security_default_viewonly <> l_security_default_maintain) THEN
BEGIN
    IF(l_security_default_viewonly = G_SECURITY_LEVEL_GLOBAL)THEN
      l_grantee_type := 'GLOBAL';
      l_grantee_id := -1;
    ELSIF(l_security_default_viewonly = G_SECURITY_LEVEL_OU) THEN
      l_grantee_type := 'OU';
      --l_grantee_id :=nvl(p_org_id, FND_PROFILE.VALUE('ORG_ID'));
      --added for MOAC
      l_grantee_id := nvl(p_org_id, QP_UTIL.get_org_id);
    ELSIF(l_security_default_viewonly = G_SECURITY_LEVEL_RESP) THEN
      l_grantee_type := 'RESP';
      l_grantee_id :=nvl(p_resp_id, FND_GLOBAL.RESP_ID);
    ELSIF(l_security_default_viewonly = G_SECURITY_LEVEL_USER) THEN
      l_grantee_type := 'USER';
      l_user_name := nvl(p_user_name, FND_GLOBAL.USER_NAME);
      l_grantee_id :=GET_USER_ID(l_user_name);
    END IF;

    /*make sure the wanted privilege is not existing already
      If already, update the privilege; otherwise, insert new.*/

    l_object_id := GET_OBJECT_ID_FOR_INSTANCE(p_instance_type);
    l_menu_id := GET_MENU_ID('QP_SECU_VIEWONLY');
    --l_start_date := sysdate;
    --l_end_date := null;
    --l_last_update_date := sysdate;
    --l_last_updated_by := GET_USER_ID(nvl(p_user_name, FND_GLOBAL.USER_NAME));
    l_last_updated_by := FND_GLOBAL.USER_ID;
    --l_creation_date := sysdate;
    l_created_by := l_last_updated_by;
    l_last_update_login := FND_GLOBAL.LOGIN_ID ;

    /*if not existing, insert new*/
    OPEN grant_exist_cur(l_grantee_type, l_grantee_id,
			p_instance_type, p_instance_pk1, l_object_id);
    FETCH grant_exist_cur INTO l_dummy;
    IF(grant_exist_cur%NOTFOUND) THEN
      SELECT QP_GRANTS_S.nextval INTO l_grant_id FROM DUAL;
      INSERT INTO qp_grants
      (GRANT_ID,
       OBJECT_ID,
       INSTANCE_TYPE,
       INSTANCE_ID,
       GRANTEE_TYPE,
       GRANTEE_ID,
       MENU_ID,
       START_DATE,
       END_DATE,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN)
      VALUES
      (l_grant_id,
       l_object_id,
       p_instance_type,
       p_instance_pk1,
       l_grantee_type,
       l_grantee_id,
       l_menu_id,
       sysdate, --l_start_date,
       null, --l_end_date,
       sysdate, --l_last_update_date,
       l_last_updated_by,
       sysdate, --l_creation_date,
       l_created_by,
       l_last_update_login );
     ELSE /*update the existing one*/
      UPDATE qp_grants
      SET MENU_ID = l_menu_id,
       START_DATE = sysdate ,
       END_DATE = null,
       LAST_UPDATE_DATE = sysdate,
       LAST_UPDATED_BY = l_created_by,
       LAST_UPDATE_LOGIN = l_last_update_login
      WHERE GRANT_ID = (select grant_id
    		        FROM qp_grants
    	                WHERE grantee_type = l_grantee_type  AND
	                      grantee_id =  l_grantee_id   AND
                              instance_type =  p_instance_type AND
	                      instance_id =  p_instance_pk1  AND
                              object_id =   l_object_id AND
			      ROWNUM = 1);
     END IF;
     CLOSE grant_exist_cur;
END;
END IF; /*else do nothing*/

IF(l_security_default_maintain <> G_SECURITY_LEVEL_NONE) THEN
BEGIN
    IF(l_security_default_maintain = G_SECURITY_LEVEL_GLOBAL)THEN
      l_grantee_type := 'GLOBAL';
      l_grantee_id := -1;
    ELSIF(l_security_default_maintain = G_SECURITY_LEVEL_OU) THEN
      l_grantee_type := 'OU';
      --l_grantee_id :=nvl(p_org_id, FND_PROFILE.VALUE('ORG_ID'));
      --added for MOAC
      l_grantee_id := nvl(p_org_id, QP_UTIL.get_org_id);
    ELSIF(l_security_default_maintain = G_SECURITY_LEVEL_RESP) THEN
      l_grantee_type := 'RESP';
      l_grantee_id :=nvl(p_resp_id, FND_GLOBAL.RESP_ID);
    ELSIF(l_security_default_maintain = G_SECURITY_LEVEL_USER) THEN
      l_grantee_type := 'USER';
      l_user_name := nvl(p_user_name, FND_GLOBAL.USER_NAME);
      l_grantee_id :=GET_USER_ID(l_user_name);
    END IF;

    l_object_id := GET_OBJECT_ID_FOR_INSTANCE(p_instance_type);
    l_menu_id := GET_MENU_ID('QP_SECU_MAINTAIN');
    --l_start_date := sysdate;
    l_end_date := null;
    --l_last_update_date := sysdate;
    --l_last_updated_by := GET_USER_ID(nvl(p_user_name, FND_GLOBAL.USER_NAME));
    l_last_updated_by := FND_GLOBAL.USER_ID;
    --l_creation_date := sysdate;
    l_created_by := l_last_updated_by;
    l_last_update_login := FND_GLOBAL.LOGIN_ID ;

    /*if not existing, insert new*/
    OPEN grant_exist_cur(l_grantee_type, l_grantee_id,
			p_instance_type, p_instance_pk1, l_object_id);
    FETCH grant_exist_cur INTO l_dummy;
    IF(grant_exist_cur%NOTFOUND) THEN
      SELECT QP_GRANTS_S.nextval INTO l_grant_id FROM DUAL;
      INSERT INTO qp_grants
      (GRANT_ID,
       OBJECT_ID,
       INSTANCE_TYPE,
       INSTANCE_ID,
       GRANTEE_TYPE,
       GRANTEE_ID,
       MENU_ID,
       START_DATE,
       END_DATE,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN)
      VALUES
      (l_grant_id,
       l_object_id,
       p_instance_type,
       p_instance_pk1,
       l_grantee_type,
       l_grantee_id,
       l_menu_id,
       sysdate, --l_start_date,
       null, --l_end_date,
       sysdate, --l_last_update_date,
       l_last_updated_by,
       sysdate, --l_creation_date,
       l_created_by,
       l_last_update_login );
     ELSE /*update the existing one*/
      UPDATE qp_grants
      SET MENU_ID = l_menu_id,
       START_DATE = sysdate ,
       END_DATE = null,
       LAST_UPDATE_DATE = sysdate,
       LAST_UPDATED_BY = l_created_by,
       LAST_UPDATE_LOGIN = l_last_update_login
      WHERE GRANT_ID = (select grant_id
    		        FROM qp_grants
    	                WHERE grantee_type = l_grantee_type  AND
	                      grantee_id =  l_grantee_id   AND
                              instance_type =  p_instance_type AND
	                      instance_id =  p_instance_pk1  AND
                              object_id =   l_object_id AND
			      ROWNUM = 1);
    END IF;
    CLOSE grant_exist_cur;
END;
END IF;/*end of security is on*/

x_return_status := 'S';

RETURN;
EXCEPTION
When OTHERS THEN
 x_return_status := 'E';
END create_default_grants;

function security_on
RETURN VARCHAR2 IS
l_security_control varchar2(5);
BEGIN
  l_security_control :=
	nvl(FND_PROFILE.value(G_SECURITY_CONTROL_PROFILE), G_SECURITY_OFF);
  IF(l_security_control = G_SECURITY_OFF) THEN
    RETURN 'N';
  ELSE
    RETURN 'Y';
  END IF;
END security_on;

Procedure Set_Grants(p_user_name IN VARCHAR2,
                     p_resp_id   IN NUMBER,
                     p_org_id    IN NUMBER
                    )
IS
BEGIN

  G_USER_NAME   := p_user_name;
  G_RESP_ID     := p_resp_id;
  G_ORG_ID      := p_org_id;

END Set_Grants;

FUNCTION qp_v_sec(owner varchar2, objname varchar2)
  RETURN varchar2 IS
  l_predicate varchar2(32767);
  l_return_status varchar2(1);
  l_user_name varchar2(80);
  l_security_control varchar2(5);
BEGIN
l_security_control := nvl(FND_PROFILE.value(G_SECURITY_CONTROL_PROFILE), G_SECURITY_OFF);
IF(l_security_control = G_SECURITY_OFF) THEN /*always return authorized*/
  RETURN '(1=1)';
ELSE /*security is on*/
  FND_DATA_SECURITY.get_security_predicate(
		p_api_version => 1.0,
		p_function => 'QP_SECU_VIEW',
		p_object_name => 'QP_LIST_HEADERS',
		p_grant_instance_type =>'SET',
		p_user_name => qp_security.g_user_name,
		x_predicate => l_predicate,
		x_return_status => l_return_status);

  IF(l_return_status = 'T') THEN
    RETURN l_predicate;
  ELSIF(l_return_status = 'E' or
	l_return_status = 'U' or
	l_return_status = 'L') THEN  /*E, U, L*/
     FND_MESSAGE.CLEAR();
    --error_message := FND_MESSAGE.GET_ENCODED;
    --RAISE E_ROUTINE_ERROR;
    l_predicate := '(1=2)';
    RETURN l_predicate;
  END IF;
END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_predicate := '(1=2)';
    RETURN l_predicate;
END qp_v_sec;

FUNCTION qp_vl_sec(owner varchar2, objname varchar2)
  RETURN varchar2 IS
  l_predicate varchar2(32767);
  l_return_status varchar2(1);
  l_user_name varchar2(80);
  l_security_control varchar2(5);
BEGIN
l_security_control := nvl(FND_PROFILE.value(G_SECURITY_CONTROL_PROFILE), G_SECURITY_OFF);
IF(l_security_control = G_SECURITY_OFF) THEN /*always return authorized*/
  RETURN '(1=1)';
ELSE /*security is on*/
  FND_DATA_SECURITY.get_security_predicate(
		p_api_version => 1.0,
		p_function => 'QP_SECU_VIEW',
		p_object_name => 'QP_LIST_HEADERS',
		p_grant_instance_type =>'SET',
		p_user_name => qp_security.g_user_name,
		x_predicate => l_predicate,
		x_return_status => l_return_status);

  IF(l_return_status = 'T') THEN
    RETURN l_predicate;
  ELSIF(l_return_status = 'E' or
	l_return_status = 'U' or
	l_return_status = 'L') THEN  /*E, U, L*/
     FND_MESSAGE.CLEAR();
    --error_message := FND_MESSAGE.GET_ENCODED;
    --RAISE E_ROUTINE_ERROR;
    l_predicate := '(1=2)';
    RETURN l_predicate;
  END IF;
END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_predicate := '(1=2)';
    RETURN l_predicate;
END qp_vl_sec;

FUNCTION GET_RESP_ID
RETURN NUMBER IS
BEGIN
	/* commented for FP 7310389 If G_RESP_ID Is NULL
	Then*/
		G_RESP_ID := FND_GLOBAL.RESP_ID;
	--End If;

	RETURN G_RESP_ID;
END GET_RESP_ID;

FUNCTION GET_ORG_ID
RETURN NUMBER IS
BEGIN
	If G_ORG_ID Is NULL
	Then
		--G_ORG_ID := FND_PROFILE.VALUE ('ORG_ID');
                --added for MOAC
                G_ORG_ID := QP_UTIL.get_org_id;
	End If;

	RETURN G_ORG_ID;
END GET_ORG_ID;

FUNCTION GET_USER_NAME
RETURN VARCHAR2 IS
BEGIN
	If G_USER_NAME Is NULL
	Then
		G_USER_NAME := FND_GLOBAL.USER_NAME;
	End If;

	RETURN G_USER_NAME;
END GET_USER_NAME;

FUNCTION GET_MENU_MAINTAIN_ID
RETURN NUMBER IS

l_menu_id NUMBER;
BEGIN
        IF G_MENU_MAINTAIN_ID Is NULL
        THEN
	  select function_id into l_menu_id from fnd_form_functions where function_name = 'QP_SECU_UPDATE';
          G_MENU_MAINTAIN_ID := l_menu_id;
        ELSE
          l_menu_id := G_MENU_MAINTAIN_ID;
        END IF;
	RETURN l_menu_id;
END GET_MENU_MAINTAIN_ID;


FUNCTION GET_UPDATE_ALLOWED (p_object_name IN VARCHAR2, p_list_header_id IN NUMBER)
RETURN VARCHAR2 IS

l_result VARCHAR2(1);
CURSOR qp_grants_c (  cp_user_id       NUMBER,
			cp_resp_id       NUMBER,
			cp_org_id        NUMBER,
                        cp_function_id   NUMBER,
                        cp_instance_id  NUMBER
  ) IS
     SELECT 'X'
     FROM qp_grants g
     WHERE rownum = 1
	AND ( ( g.grantee_type = 'USER' AND
                g.grantee_id =  cp_user_id) OR
            ( g.grantee_type = 'RESP' AND
              g.grantee_id = cp_resp_id) OR
            ( g.grantee_type = 'GLOBAL' AND
              g.grantee_id = -1) OR
            ( g.grantee_type = 'OU' AND
              (mo_global.get_access_mode = 'S' and sys_context('multi_org2', 'current_org_id') = g.grantee_id)
              OR (mo_global.get_access_mode = 'A')
              OR (mo_global.get_access_mode = 'M' and mo_global.check_access(g.grantee_id) = 'Y'))
           ) AND
	   g.menu_id IN
               (select cmf.menu_id
                 from fnd_compiled_menu_functions cmf
                where cmf.function_id = cp_function_id)
      AND (G.instance_id = cp_instance_id)
      AND ( g.end_date  IS NULL OR g.end_date >= sysdate )
      AND g.start_date <= sysdate;

  BEGIN

    if(FND_PROFILE.value('QP_SECURITY_CONTROL') = 'OFF') then
	l_result := 'Y';
      return l_result;
    end if;

    OPEN qp_grants_c(qp_SECURITY.get_user_id ,
		     qp_SECURITY.get_resp_id ,
                     qp_SECURITY.get_org_id ,
                     qp_SECURITY.get_menu_maintain_id,
                     p_list_header_id);

    FETCH qp_grants_c INTO l_result;
    CLOSE qp_grants_c;

    IF ( l_result = 'X') THEN
	RETURN 'Y';
    END IF;

	l_result := FND_DATA_SECURITY.check_function(
			p_api_version => 1.0,
			p_function => 'QP_SECU_UPDATE',
			p_object_name => p_object_name,
			p_instance_pk1_value => p_list_header_id,
			p_instance_pk2_value => null,
			p_instance_pk3_value => null,
 			p_instance_pk4_value => null,
			p_instance_pk5_value => null,
			p_user_name => qp_SECURITY.g_user_name );
  	IF(l_result = 'F') THEN
		RETURN 'N';
	ELSIF(l_result = 'T') THEN
		RETURN 'Y';
	ELSE
		RETURN 'N';
	END IF;

    RETURN 'N';

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN 'N';
    END GET_UPDATE_ALLOWED;


-------------moac vpd --------------
--added for MOAC
--this will be the VPD policy for the secured synonym qp_list_headers_b
--
-- Name
--   qp_org_security
--
-- Purpose
--   This function implements the security policy for the Multi-Org
--   Access Control mechanism for QP_LIST_HEADERS_B.
--   It is automatically called by the oracle
--   server whenever a secured table or view is referenced by a SQL
--   statement. Products should not call this function directly.
--
--   The security policy function is expected to return a predicate
--   (a WHERE clause) that will control which records can be accessed
--   or modified by the SQL statement. After incorporating the
--   predicate, the server will parse, optimize and execute the
--   modified statement.
--
-- Arguments
--   obj_schema - the schema that owns the secured object
--   obj_name   - the name of the secured object
--

FUNCTION QP_ORG_SECURITY(obj_schema VARCHAR2,
                      obj_name   VARCHAR2) RETURN VARCHAR2
IS
l_access_mode VARCHAR2(10);
BEGIN

l_access_mode := MO_GLOBAL.get_access_mode;

  --  IF PRICING SECURITY IS ON
  --  Returns different predicates based on the access_mode
  --  The codes for access_mode are
  --  M - Multiple OU Access
  --  A - All OU Access
  --  S - Single OU Access
  --  Null - Backward Compatibility - CLIENT_INFO case
  --

  -- IF PRICING SECURITY IS OFF
  -- Returns Null

  --  The Predicates will be appended to Multi-Org synonyms

  IF Security_On = 'Y' THEN
    IF l_access_mode IS NOT NULL THEN
      IF l_access_mode = 'M' THEN
        RETURN 'global_flag = ''Y''
              or EXISTS (SELECT 1
                        FROM mo_glob_org_access_tmp oa
                       WHERE oa.organization_id = orig_org_id)';
      ELSIF l_access_mode = 'A' THEN -- for future use
        RETURN NULL;
      ELSIF l_access_mode = 'S' THEN -- this is for backward compatibility to MO: Operating Unit
        RETURN 'global_flag = ''Y'' or orig_org_id = sys_context(''multi_org2'',''current_org_id'')';
      END IF;
    ELSE
      return null;
    END IF;
  ELSE -- Pricing Security OFF
    return null;
  END IF;
EXCEPTION
When OTHERS Then
  return null;
END QP_ORG_SECURITY;

END QP_SECURITY;

/
