--------------------------------------------------------
--  DDL for Package Body POS_DATA_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_DATA_SECURITY" AS
/* $Header: POSSECPB.pls 120.0.12010000.4 2013/12/14 00:13:51 dalu noship $ */

  G_PKG_NAME       CONSTANT VARCHAR2(30):= 'POS_DATA_SECURITY';
  G_LOG_HEAD       CONSTANT VARCHAR2(40):= 'fnd.plsql.pos.POS_DATA_SECURITY.';

  G_CURRENT_DEBUG_LEVEL             NUMBER;

  G_DEBUG_LEVEL_UNEXPECTED CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
  G_DEBUG_LEVEL_ERROR      CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
  G_DEBUG_LEVEL_EXCEPTION  CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_DEBUG_LEVEL_EVENT      CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
  G_DEBUG_LEVEL_PROCEDURE  CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_DEBUG_LEVEL_STATEMENT  CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;

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
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END code_debug;

  ----------------------------------------------
  --This is an internal procedure. Not in spec.
  ----------------------------------------------
  FUNCTION get_object_id(p_object_name IN VARCHAR2) RETURN NUMBER IS
    l_object_id NUMBER;
  BEGIN
    SELECT object_id
    INTO l_object_id
    FROM fnd_objects
    WHERE obj_name = p_object_name;
    RETURN l_object_id;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_object_id;

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
      WHERE group_membership_rel.RELATIONSHIP_CODE = 'EMPLOYEE_OF'
      AND group_membership_rel.status = 'A'
      AND group_membership_rel.start_date <= SYSDATE
      AND NVL(group_membership_rel.end_date, SYSDATE) >= SYSDATE
      AND group_membership_rel.subject_id = cp_orig_system_id;
  l_company_info VARCHAR2(32767);
  BEGIN
    l_company_info := '';
    FOR company_rec IN company_membership_c (p_party_id) LOOP
      l_company_info := l_company_info||''''||company_rec.company_name||''' , ';
    END LOOP;

    IF( length( l_company_info ) > 0) THEN
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
  --Bug 17336075: Use 'company' type to grant roles to all supplier users (supplier contacts)
  ----------------------------------------------
  FUNCTION get_company_info_supp (p_party_id IN NUMBER) RETURN VARCHAR2 IS
   CURSOR company_membership_c (cp_orig_system_id IN NUMBER) IS
      SELECT 'HZ_COMPANY:'||group_membership_rel.object_id company_name
      FROM hz_relationships group_membership_rel
      WHERE group_membership_rel.RELATIONSHIP_CODE = 'CONTACT_OF'  -- Supplier users are defined as supplier contacts instead of employees
      AND group_membership_rel.status = 'A'
      AND group_membership_rel.start_date <= SYSDATE
      AND NVL(group_membership_rel.end_date, SYSDATE) >= SYSDATE
      AND group_membership_rel.subject_id = cp_orig_system_id;
  l_company_info VARCHAR2(32767);
  BEGIN
    l_company_info := '';
    FOR company_rec IN company_membership_c (p_party_id) LOOP
      l_company_info := l_company_info||''''||company_rec.company_name||''' , ';
    END LOOP;

    IF( length( l_company_info ) > 0) THEN
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
  END get_company_info_supp;

  -- Bug 17336075
  -- Get privileges from 'Company' type grant on a specific supplier for supplier users
  PROCEDURE get_privileges_supp
  (
   p_party_id           IN  NUMBER,
   p_user_id            IN  NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_privileges_string  OUT NOCOPY VARCHAR2
   )
   IS

    TYPE privileges_csr_type IS REF CURSOR;

    l_api_version    CONSTANT NUMBER := 1.0;
    l_api_name       CONSTANT VARCHAR2(30) := 'GET_PRIVILEGES_SUPP';

    l_object_name    CONSTANT VARCHAR2(10) := 'HZ_PARTIES';
    l_delimiter      CONSTANT VARCHAR2(1) := ',' ;

    l_user_party_id  NUMBER;
    l_pk1_value      FND_GRANTS.INSTANCE_PK1_VALUE%TYPE;

    l_index          NUMBER;
    l_dynamic_sql    VARCHAR2(32767);
    l_privilege      VARCHAR2(480);

    l_company_info_supp   VARCHAR2(32767);
    l_object_id           NUMBER;

    l_privileges_csr    privileges_csr_type;


    l_prof_privilege_tbl    EGO_VARCHAR_TBL_TYPE;
    l_privilege_tbl         EGO_DATA_SECURITY.EGO_PRIVILEGE_NAME_TABLE_TYPE;

  BEGIN

    G_CURRENT_DEBUG_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_pk1_value := TO_CHAR(p_party_id);

    SELECT person_party_id INTO l_user_party_id
    FROM fnd_user users
    WHERE users.user_id = p_user_id;

    l_object_id := get_object_id(p_object_name => l_object_name);
    l_index := 0;
    x_privileges_string := '';

    l_company_info_supp := get_company_info_supp(p_party_id => l_user_party_id);

    l_dynamic_sql :=
      'SELECT DISTINCT fnd_functions.function_name ' ||
       ' FROM fnd_grants grants, ' ||
            ' fnd_form_functions fnd_functions, ' ||
            ' fnd_menu_entries cmf '||
      ' WHERE grants.object_id = :object_id ' ||
       ' AND grants.start_date <= SYSDATE ' ||
       ' AND NVL(grants.end_date,SYSDATE) >= SYSDATE ' ||
       ' AND ( grants.grantee_type = ''COMPANY'' AND ' ||
                ' grants.grantee_key in ( '||l_company_info_supp||' )) ' ||  -- Only privileges for 'Company type'
        ' AND cmf.function_id = fnd_functions.function_id ' ||
        ' AND cmf.menu_id = grants.menu_id ' ||
        ' AND grants.instance_type = ''INSTANCE'' ' ||
        ' AND grants.instance_pk1_value = :pk1_val ';   -- Ensure grant is only for the current supplier

      OPEN l_privileges_csr FOR l_dynamic_sql
      USING IN l_object_id,
            IN l_pk1_value;

    LOOP
      FETCH l_privileges_csr  INTO l_privilege;
      EXIT WHEN l_privileges_csr%NOTFOUND;

      l_privilege_tbl(l_index) := l_privilege;
      l_index := l_index+1;
    END LOOP;
    CLOSE l_privileges_csr;

    IF l_privilege_tbl.count > 0 THEN
      FOR i in l_privilege_tbl.first .. l_privilege_tbl.last LOOP
        x_privileges_string := x_privileges_string || l_privilege_tbl(i) || l_delimiter;
      END LOOP;

      x_privileges_string := substr(x_privileges_string, 1,
                                    length(x_privileges_string) - length(l_delimiter));
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS; -- Return Success no matter the privilege list is empty or not

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
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END get_privileges_supp;



  -- Rewrite EGO_SECURITY_PUB.get_party_privileges_d to get privileges in case of prospective suppliers
  -- Will return x_privileges_string = null if no privileges are assigned to the user and user's default profile option
  PROCEDURE get_privileges_prosp
  (
   p_supp_reg_id        IN  NUMBER,
   p_user_id            IN  NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_privileges_string  OUT NOCOPY VARCHAR2
   )
   IS

    TYPE privileges_csr_type IS REF CURSOR;

    l_api_version    CONSTANT NUMBER := 1.0;
    l_object_name    CONSTANT VARCHAR2(10) := 'HZ_PARTIES';
    l_delimiter      CONSTANT VARCHAR2(1) := ',' ;

    l_user_id        NUMBER;
    l_party_id       NUMBER;
    l_role_name      VARCHAR2(99);
    l_user_name      FND_GRANTS.GRANTEE_KEY%TYPE;

    l_index          NUMBER;
    l_dynamic_sql    VARCHAR2(32767);
    l_privilege      VARCHAR2(480);

    l_group_info     VARCHAR2(32767);
    l_company_info   VARCHAR2(32767);
    l_object_id      NUMBER;

    l_privileges_csr    privileges_csr_type;


    l_prof_privilege_tbl    EGO_VARCHAR_TBL_TYPE;
    l_privilege_tbl         EGO_DATA_SECURITY.EGO_PRIVILEGE_NAME_TABLE_TYPE;

  BEGIN

     -- get proxy user's user id in case of 'GUEST' user
     IF (p_user_id = 6) THEN
         l_user_id := FND_PROFILE.VALUE('POS_SM_PROSPECT_PROXY_LOGIN');
     ELSE
         l_user_id := p_user_id;
     END IF;

     -- Following code is modified from EGO_DATA_SECURITY.get_functions

  -- Step 1:
  -- get all the privileges set by the profile option
    l_index := 0;

    IF (p_user_id = 6) THEN  -- In case of 'GUEST' user, get default supplier profile option
        l_role_name := FND_PROFILE.VALUE('POS_SM_DEFAULT_ROLE_SUPP');
    ELSE
        l_role_name := FND_PROFILE.VALUE('POS_SM_DEFAULT_ROLE_INTERNAL');
    END IF;

    EGO_DATA_SECURITY.get_role_functions
        (p_api_version     => l_api_version,
         p_role_name       => l_role_name,
         x_return_status   => x_return_status,
         x_privilege_tbl   => l_prof_privilege_tbl
        );

    IF (x_return_status = 'T') THEN      --- 'T' is defined as success in EGO_DATA_SECURITY
      IF (l_prof_privilege_tbl.COUNT > 0) THEN
        FOR i IN l_prof_privilege_tbl.first .. l_prof_privilege_tbl.last LOOP
           l_privilege_tbl(i) := l_prof_privilege_tbl(i);
        END LOOP;
      END IF;
      l_index := l_prof_privilege_tbl.COUNT;
    END IF;

    --end of getting privileges from profile option

  -- Step 2:
  -- get All privileges of a user on a given object
  -- Skip this step if in 'GUEST' user case, no value is set for the profile option POS_SM_PROSPECT_PROXY_LOGIN

  IF l_user_id IS NOT NULL THEN

    SELECT person_party_id INTO l_party_id
    FROM fnd_user users
    WHERE users.user_id = l_user_id;

    l_user_name :='HZ_PARTY:'|| l_party_id;

    l_object_id := get_object_id(p_object_name => l_object_name);

    -- pre-fetch company/group info

    l_group_info := get_group_info(p_party_id => l_party_id);
    l_company_info := get_company_info(p_party_id => l_party_id);

    l_dynamic_sql :=
      'SELECT DISTINCT fnd_functions.function_name ' ||
       ' FROM fnd_grants grants, ' ||
            ' fnd_form_functions fnd_functions, ' ||
            ' fnd_menu_entries cmf, '||
            ' fnd_object_instance_sets sets ' ||
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
                ' grants.grantee_key in (''HZ_GLOBAL:-1000'', ''GLOBAL'') ))' ||
        ' AND cmf.function_id = fnd_functions.function_id ' ||
        ' AND cmf.menu_id = grants.menu_id ' ||
        ' AND grants.instance_set_id = sets.instance_set_id ' ||
        ' AND grants.instance_type = ''SET'' ' ||
        ' AND sets.instance_set_name = ''ORGANIZATION'' ';    -- Users need to set up it during grant process

    OPEN l_privileges_csr FOR l_dynamic_sql
    USING IN l_object_id,
          IN l_user_name;

    LOOP
        FETCH l_privileges_csr  INTO l_privilege;
        EXIT WHEN l_privileges_csr%NOTFOUND;
        l_index := l_index+1;
        l_privilege_tbl(l_index) := l_privilege;
    END LOOP;
    CLOSE l_privileges_csr;

  END IF;

  -- Step 3:
  -- Collect all privileges
    x_privileges_string := '';

    IF l_privilege_tbl.count > 0 THEN
      FOR i in l_privilege_tbl.first .. l_privilege_tbl.last LOOP
        x_privileges_string := x_privileges_string || l_privilege_tbl(i) || l_delimiter;
      END LOOP;

      x_privileges_string := substr(x_privileges_string, 1,
                                    length(x_privileges_string) - length(l_delimiter));
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS; -- Return Success no matter the privilege list is empty or not

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END get_privileges_prosp;

END POS_DATA_SECURITY;

/
