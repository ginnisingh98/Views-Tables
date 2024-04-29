--------------------------------------------------------
--  DDL for Package Body JTF_RESOURCE_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RESOURCE_UTL" AS
  /* $Header: jtfrspub.pls 120.5.12010000.4 2009/12/31 05:02:34 rgokavar ship $ */

  /*****************************************************************************************
   This package body defines all the routines which are declared in the package
   specification.
   ******************************************************************************************/


  /* Function to get the created_by who column. */

  FUNCTION created_by
    RETURN NUMBER
  IS
    l_created_by    NUMBER;
  BEGIN

    SELECT fnd_global.user_id
    INTO l_created_by
    FROM dual;

    RETURN l_created_by;

  END;


  /* Function to get the updated_by who column. */

  FUNCTION updated_by
    RETURN NUMBER
  IS
    l_updated_by    NUMBER;
  BEGIN

    SELECT fnd_global.user_id
    INTO l_updated_by
    FROM dual;

    RETURN l_updated_by;

  END;


  /* Function to get the login_id who column. */

  FUNCTION login_id
    RETURN NUMBER
  IS
    l_login_id    NUMBER;
  BEGIN

    SELECT fnd_global.login_id
    INTO l_login_id
    FROM dual;

    RETURN l_login_id;

  END;


  /* Procedure to call internal user hook. */

   PROCEDURE call_internal_hook
    (p_package_name     IN      VARCHAR2 ,
     p_api_name         IN      VARCHAR2 ,
     p_processing_type  IN      VARCHAR2,
     x_return_status    OUT NOCOPY    VARCHAR2
   ) IS

      CURSOR c1
      IS
         SELECT hook_PACKAGE, hook_api
           FROM jtf_hooks_data
          WHERE PACKAGE_NAME = p_PACKAGE_name
            AND api_name = p_api_name
            AND execute_flag = 'Y'
            AND processing_type = p_processing_type
          ORDER BY execution_order;

          v_cursorid integer ;
          v_blockstr varchar2(2000);
          v_dummy integer;
          l_hook_package varchar2(30);
          l_hook_api     varchar2 (30);
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      FOR i IN c1  LOOP
         v_cursorid := dbms_sql.open_cursor ;
/* BINDVAR_SCAN_IGNORE [1] */
         v_blockstr := ' begin '||i.hook_PACKAGE || '.' ||i.hook_api||'(:1); end; ' ;
         dbms_sql.parse( v_cursorid , v_blockstr , dbms_sql.v7 ) ;
         dbms_sql.bind_variable( v_cursorid , ':1' , x_return_status , 20 );
         v_dummy := dbms_sql.execute(v_cursorid);
         dbms_sql.variable_value( v_cursorid , ':1' , x_return_status );
         dbms_sql.close_cursor(v_cursorid);

         IF NOT (x_return_status = fnd_api.g_ret_sts_success)
         THEN
             fnd_message.set_name ('JTF', 'JTF_RS_MISSING_RETURN_STATUS');
             fnd_message.set_token('P_PROCEDURE',i.hook_PACKAGE || '.' ||i.hook_api);
             fnd_msg_pub.add ;
             --x_return_status :=fnd_api.g_ret_sts_error;
             RAISE fnd_api.g_exc_error;
         END IF;

         IF X_RETURN_status IS null then
             fnd_message.set_name ('JTF', 'JTF_RS_MISSING_RETURN_STATUS');
             fnd_msg_pub.add ;
             x_return_status := fnd_api.g_ret_sts_error;
             RAISE fnd_api.g_exc_error;
         END IF ;

      END LOOP;

   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS
      THEN
        fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME','CALL_INTERNAL_HOOK');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

   END call_internal_hook;


  /* Procedure to validate the resource group. */

  PROCEDURE  validate_resource_group
  (p_group_id             IN   NUMBER,
   p_group_number         IN   VARCHAR2,
   x_return_status        OUT NOCOPY  VARCHAR2,
   x_group_id             OUT NOCOPY  NUMBER
  ) IS

    CURSOR c_group_id IS
      SELECT group_id
      FROM jtf_rs_groups_b
      WHERE group_id = p_group_id;

    CURSOR c_group_number IS
      SELECT group_id
      FROM jtf_rs_groups_b
      WHERE group_number = p_group_number;


  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF p_group_id IS NULL AND p_group_number is NULL THEN

--      dbms_output.put_line('Group Id and Group Number are null');

      fnd_message.set_name('JTF', 'JTF_RS_GROUP_NULL');
      fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_error;

    END IF;


    IF p_group_id IS NOT NULL THEN

      OPEN c_group_id;

      FETCH c_group_id INTO x_group_id;

      IF c_group_id%NOTFOUND THEN

--        dbms_output.put_line('Invalid Group Id');

        fnd_message.set_name('JTF', 'JTF_RS_INVALID_GROUP');
        fnd_message.set_token('P_GROUP_ID', p_group_id);
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_error;

      END IF;

      CLOSE c_group_id;

    ELSIF p_group_number IS NOT NULL THEN

      OPEN c_group_number;

      FETCH c_group_number INTO x_group_id;

      IF c_group_number%NOTFOUND THEN

--        dbms_output.put_line('Invalid Group Number');

        fnd_message.set_name('JTF', 'JTF_RS_INVALID_GROUP_NUMBER');
        fnd_message.set_token('P_GROUP_NUMBER', p_group_number);
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_error;

      END IF;

      CLOSE c_group_number;

    END IF;

  END validate_resource_group;



  /* Procedure to validate the resource number. */

  PROCEDURE  validate_resource_number
  (p_resource_id          IN   NUMBER,
   p_resource_number      IN   NUMBER,
   x_return_status        OUT NOCOPY  VARCHAR2,
   x_resource_id          OUT NOCOPY  NUMBER
  ) IS

    CURSOR c_resource_id IS
      SELECT resource_id
      FROM jtf_rs_resource_extns
      WHERE resource_id = p_resource_id
        AND ( end_date_active is null OR
		    trunc(end_date_active) >= trunc(sysdate) );

    CURSOR c_resource_number IS
      SELECT resource_id
      FROM jtf_rs_resource_extns
      WHERE resource_number = p_resource_number
        AND ( end_date_active is null OR
		    trunc(end_date_active) >= trunc(sysdate) );

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF p_resource_id IS NULL AND p_resource_number is NULL THEN

--      dbms_output.put_line('Resource Id and Resource Number are null');

      fnd_message.set_name('JTF', 'JTF_RS_RESOURCE_NULL');
      fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

    END IF;


    IF p_resource_id IS NOT NULL THEN

      OPEN c_resource_id;

      FETCH c_resource_id INTO x_resource_id;

      IF c_resource_id%NOTFOUND THEN

--        dbms_output.put_line('Invalid or Inactive Resource');

        fnd_message.set_name('JTF', 'JTF_RS_INVALID_RESOURCE');
        fnd_message.set_token('P_RESOURCE_ID', p_resource_id);
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_error;

      END IF;

      CLOSE c_resource_id;

    ELSIF p_resource_number IS NOT NULL THEN

      OPEN c_resource_number;

      FETCH c_resource_number INTO x_resource_id;

      IF c_resource_number%NOTFOUND THEN

--        dbms_output.put_line('Invalid or Inactive Resource');

        fnd_message.set_name('JTF', 'JTF_RS_INVALID_RESOURCE_NUMBER');
        fnd_message.set_token('P_RESOURCE_NUMBER', p_resource_number);
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_error;

      END IF;

      CLOSE c_resource_number;

    END IF;

  END validate_resource_number;



  /* Procedure to validate the input dates. */

  PROCEDURE  validate_input_dates
  (p_start_date_active    IN   DATE,
   p_end_date_active      IN   DATE,
   x_return_status        OUT NOCOPY VARCHAR2
  ) IS

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF p_start_date_active IS NULL THEN

--	 dbms_output.put_line('Start Date Active cannot be null');

      fnd_message.set_name('JTF', 'JTF_RS_START_DATE_NULL');
      fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_error;

    END IF;


    /* Validate that the passed start date is less than the end date. */

    IF p_end_date_active IS NOT NULL THEN
--Bug 9083841
--Changed the format of date before comparing. (Truncate format is not comparing properly)
      --IF trunc(p_start_date_active) > trunc(p_end_date_active) THEN
      IF  to_date(to_char(p_start_date_active,'MM/DD/RRRR'),'MM/DD/RRRR') > to_date(to_char(p_end_date_active,'MM/DD/RRRR'),'MM/DD/RRRR') THEN

--        dbms_output.put_line('Start Date cannot be greater than the end date');

	   x_return_status := fnd_api.g_ret_sts_error;

	   fnd_message.set_name('JTF', 'JTF_RS_ERR_STDT_GREATER_EDDT');
	   fnd_msg_pub.add;

      END IF;

    END IF;


  END validate_input_dates;



  /* Procedure to validate the resource group usage. */

  PROCEDURE  validate_usage
  (p_usage                IN   VARCHAR2,
   x_return_status        OUT NOCOPY  VARCHAR2
  ) IS

    l_usage         jtf_rs_group_usages.usage%TYPE;

    CURSOR c_usage(p_lookup_type in varchar2,p_enabled_flag in varchar2) IS
      SELECT lookup_code
      FROM fnd_lookups
      WHERE lookup_type = p_lookup_type
        AND upper(lookup_code) = upper(p_usage)
        AND trunc(nvl(end_date_active, sysdate)) >= trunc(sysdate)
	   AND enabled_flag = p_enabled_flag;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF p_usage IS NULL THEN

--      dbms_output.put_line('Usage is null');

      fnd_message.set_name('JTF', 'JTF_RS_USAGE_NULL');
      fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_error;

    END IF;

    IF p_usage IS NOT NULL THEN

      OPEN c_usage('JTF_RS_USAGE','Y');

      FETCH c_usage INTO l_usage;

      IF c_usage%NOTFOUND THEN

--        dbms_output.put_line('Invalid Usage');

        fnd_message.set_name('JTF', 'JTF_RS_INVALID_USAGE');
        fnd_message.set_token('P_USAGE', p_usage);
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_error;

      END IF;

      CLOSE c_usage;

    END IF;

  END validate_usage;



  /* Procedure to validate the resource category. */

  PROCEDURE  validate_resource_category
  (p_category             IN   VARCHAR2,
   x_return_status        OUT NOCOPY VARCHAR2
  ) IS

    l_category            jtf_rs_resource_extns.category%TYPE;

    -- fix for performance bug # 4956628
    -- SQL ID : 14841989 from  SQL Repository
    -- mofified the below cusror to change
    -- the table jtf_objects_vl to jtf_objects_b from FROM clause.

    CURSOR c_resource_category IS
      SELECT jo.object_code
      FROM jtf_objects_b jo,
	   jtf_object_usages jou
      WHERE jo.object_code = jou.object_code
        AND jou.object_user_code = 'RESOURCE_CATEGORIES'
	   AND upper(jo.object_code) = upper(p_category)
        AND trunc(nvl(jo.end_date_active, sysdate)) >= trunc(sysdate);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF p_category IS NULL THEN

--      dbms_output.put_line('Resource Category is null');

      fnd_message.set_name('JTF', 'JTF_RS_RESOURCE_CATEGORY_NULL');
      fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_error;

    END IF;

    IF p_category IS NOT NULL THEN

      OPEN c_resource_category;

      FETCH c_resource_category INTO l_category;

      IF c_resource_category%NOTFOUND THEN

--        dbms_output.put_line('Invalid Resource Category');

        fnd_message.set_name('JTF', 'JTF_RS_INVALID_RES_CATEGORY');
        fnd_message.set_token('P_RESOURCE_CATEGORY', p_category);
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_error;

      END IF;

      CLOSE c_resource_category;

    END IF;

  END validate_resource_category;


 /* Procedure to validate the source id. */

  PROCEDURE  validate_source_id
  (p_category             IN   VARCHAR2,
   p_source_id            IN   NUMBER,
   p_address_id           IN   NUMBER,
   x_return_status        OUT NOCOPY VARCHAR2
  ) IS

  CURSOR c_emp_dup_source_id IS
     SELECT 1
     FROM jtf_rs_resource_extns
     WHERE source_id = p_source_id
       AND category = 'EMPLOYEE';
/* Removed the below code for bug # 3455951 */
/*
  CURSOR c_cwk_dup_source_id IS
     SELECT 1
     FROM jtf_rs_resource_extns
     WHERE source_id = p_source_id
       AND category = 'WORKER';
*/
  CURSOR c_ven_dup_source_id IS
     SELECT 1
     FROM jtf_rs_resource_extns
     WHERE source_id = p_source_id
       AND category = 'VENUE';

  CURSOR c_party_dup_source_id IS
     SELECT 1
     FROM jtf_rs_resource_extns
     WHERE source_id = p_source_id
       AND category = 'PARTY';

  CURSOR c_vend_dup_source_id IS
     SELECT 1
     FROM jtf_rs_resource_extns
     WHERE source_id = p_source_id
       AND category = 'SUPPLIER_CONTACT';

  CURSOR c_partner_dup_source_id IS
     SELECT 1
     FROM jtf_rs_resource_extns
     WHERE source_id = p_source_id
AND nvl(address_id,-99) = nvl(p_address_id,-99)  --uncommented this to accomodate migr 09/25
AND category = 'PARTNER';

  check_num	number;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF p_category = 'EMPLOYEE' THEN
       OPEN c_emp_dup_source_id;
       FETCH c_emp_dup_source_id into check_num;
       IF c_emp_dup_source_id%FOUND THEN
--        dbms_output.put_line('Source ID already exists ');
          fnd_message.set_name('JTF', 'JTF_RS_DUP_SOURCE_ID');
          fnd_message.set_token('P_SOURCE_ID', p_source_id);
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
       END IF;
       CLOSE c_emp_dup_source_id;
/* Removed the below code for bug # 3455951 */
/*
    ELSIF p_category = 'WORKER' THEN
       OPEN c_cwk_dup_source_id;
       FETCH c_cwk_dup_source_id into check_num;
       IF c_cwk_dup_source_id%FOUND THEN
          fnd_message.set_name('JTF', 'JTF_RS_DUP_SOURCE_ID');
          fnd_message.set_token('P_SOURCE_ID', p_source_id);
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
       END IF;
       CLOSE c_cwk_dup_source_id;
*/
    ELSIF p_category = 'PARTY' THEN
       OPEN c_party_dup_source_id;
       FETCH c_party_dup_source_id into check_num;
       IF c_party_dup_source_id%FOUND THEN
--        dbms_output.put_line('Source ID already exists ');
          fnd_message.set_name('JTF', 'JTF_RS_DUP_SOURCE_ID');
          fnd_message.set_token('P_SOURCE_ID', p_source_id);
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
       END IF;
       CLOSE c_party_dup_source_id;

    ELSIF p_category = 'SUPPLIER_CONTACT' THEN
       OPEN c_vend_dup_source_id;
       FETCH c_vend_dup_source_id into check_num;
       IF c_vend_dup_source_id%FOUND THEN
--        dbms_output.put_line('Source ID already exists ');
          fnd_message.set_name('JTF', 'JTF_RS_DUP_SOURCE_ID');
          fnd_message.set_token('P_SOURCE_ID', p_source_id);
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
       END IF;
       CLOSE c_vend_dup_source_id;

    ELSIF p_category = 'PARTNER' THEN
       OPEN c_partner_dup_source_id;
       FETCH c_partner_dup_source_id into check_num;
       IF c_partner_dup_source_id%FOUND THEN
--        dbms_output.put_line('Source ID already exists ');
          fnd_message.set_name('JTF', 'JTF_RS_DUP_SOURCE_ID');
          fnd_message.set_token('P_SOURCE_ID', p_source_id);
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
       END IF;
       CLOSE c_partner_dup_source_id;

    ELSIF p_category = 'VENUE' THEN
       OPEN c_ven_dup_source_id;
       FETCH c_ven_dup_source_id into check_num;
       IF c_ven_dup_source_id%FOUND THEN
--        dbms_output.put_line('Source ID already exists ');
          fnd_message.set_name('JTF', 'JTF_RS_DUP_SOURCE_ID');
          fnd_message.set_token('P_SOURCE_ID', p_source_id);
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
       END IF;
       CLOSE c_ven_dup_source_id;

    END IF;

  END validate_source_id;


  /* Procedure to validate the Employee Resource */

  PROCEDURE  validate_employee_resource
  (p_emp_resource_id      IN   NUMBER,
   p_emp_resource_number  IN   NUMBER,
   x_return_status        OUT NOCOPY  VARCHAR2,
   x_emp_resource_id      OUT NOCOPY  NUMBER
  ) IS

    CURSOR c_ppf_person_id IS
      SELECT person_id
      FROM per_people_f
      WHERE person_id = p_emp_resource_id;

    --CURSOR c_ppf_emp_num IS
    --SELECT person_id
    --FROM per_people_f
    --WHERE employee_number = p_emp_resource_number;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF p_emp_resource_id IS NOT NULL THEN
      OPEN c_ppf_person_id;
      FETCH c_ppf_person_id INTO x_emp_resource_id;
      IF c_ppf_person_id%NOTFOUND THEN
--        dbms_output.put_line('Invalid or Inactive Employee Resource');
          fnd_message.set_name('JTF', 'JTF_RS_INVALID_EMP_RESOURCE_ID');
          fnd_message.set_token('P_EMP_RESOURCE_ID', p_emp_resource_id);
          fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;
      CLOSE c_ppf_person_id;

  --ELSIF p_emp_resource_number IS NOT NULL THEN
    --  OPEN c_ppf_emp_num;
    --  FETCH c_ppf_emp_num INTO x_emp_resource_id;
    --  IF c_ppf_emp_num%NOTFOUND THEN
--        dbms_output.put_line('Invalid or Inactive Employee Resource');
     --   fnd_message.set_name('JTF', 'JTF_RS_INVALID_EMP_RES_NUMBER');
     --   fnd_message.set_token('P_EMP_RESOURCE_NUMBER', p_emp_resource_number);
     --   fnd_msg_pub.add;
     --   x_return_status := fnd_api.g_ret_sts_unexp_error;
     -- END IF;
     -- CLOSE c_ppf_emp_num;

    END IF;
  END validate_employee_resource;


  /* Procedure to validate the Time Zone. */

  PROCEDURE  validate_time_zone
  (p_time_zone_id         IN   NUMBER,
   x_return_status        OUT NOCOPY VARCHAR2
  ) IS

    l_time_zone_id        hz_timezones.timezone_id%TYPE;

    CURSOR c_time_zone_id IS
     /* Bug 7290999 (changed reference from hz_timezones_vl to fnd_timezones_vl)
      SELECT timezone_id
      FROM hz_timezones
      WHERE timezone_id = p_time_zone_id;
     */
      SELECT upgrade_tz_id
      FROM   fnd_timezones_vl
      WHERE  upgrade_tz_id = p_time_zone_id;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF p_time_zone_id IS NULL THEN

--      dbms_output.put_line('Time Zone Id is null');

      fnd_message.set_name('JTF', 'JTF_RS_TIME_ZONE_NULL');
      fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_error;

    END IF;

    IF p_time_zone_id IS NOT NULL THEN

      OPEN c_time_zone_id;

      FETCH c_time_zone_id INTO l_time_zone_id;

      IF c_time_zone_id%NOTFOUND THEN

--        dbms_output.put_line('Invalid Time Zone');

        fnd_message.set_name('JTF', 'JTF_RS_INVALID_TIME_ZONE');
        fnd_message.set_token('P_TIME_ZONE_ID', p_time_zone_id);
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_error;

      END IF;

      CLOSE c_time_zone_id;

    END IF;

  END validate_time_zone;



  /* Procedure to validate the Language. */

  PROCEDURE  validate_nls_language
  (p_nls_language         IN   VARCHAR2,
   x_return_status        OUT NOCOPY VARCHAR2
  ) IS

    l_nls_language        fnd_languages.nls_language%TYPE;

    CURSOR c_nls_language IS
      SELECT nls_language
      FROM fnd_languages
      WHERE nls_language = p_nls_language;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF p_nls_language IS NULL THEN

--      dbms_output.put_line('Language is null');

      fnd_message.set_name('JTF', 'JTF_RS_LANGUAGE_NULL');
      fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_error;

    END IF;

    IF p_nls_language IS NOT NULL THEN

      OPEN c_nls_language;

      FETCH c_nls_language INTO l_nls_language;

      IF c_nls_language%NOTFOUND THEN

--        dbms_output.put_line('Invalid Language');

        fnd_message.set_name('JTF', 'JTF_RS_INVALID_LANGUAGE');
        fnd_message.set_token('P_LANGUAGE', p_nls_language);
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_error;

      END IF;

      CLOSE c_nls_language;

    END IF;

  END validate_nls_language;



  /* Procedure to validate the Support Site. */

  PROCEDURE  validate_support_site_id
  (p_support_site_id      IN   NUMBER,
   x_return_status        OUT NOCOPY VARCHAR2
  ) IS

    l_support_site_id        jtf_rs_resource_extns.support_site_id%TYPE;

    CURSOR c_support_site_id IS
      SELECT hps.party_site_id
	 FROM hz_party_sites hps,
	      hz_party_site_uses hpsu
      WHERE hpsu.site_use_type = 'SUPPORT_SITE'
	   AND hpsu.party_site_id = hps.party_site_id
	   AND hps.party_site_id = p_support_site_id;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF p_support_site_id IS NULL THEN

--      dbms_output.put_line('Support Site is null');

      fnd_message.set_name('JTF', 'JTF_RS_SUPPORT_SITE_NULL');
      fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_error;

    END IF;

    IF p_support_site_id IS NOT NULL THEN

      OPEN c_support_site_id;

      FETCH c_support_site_id INTO l_support_site_id;

      IF c_support_site_id%NOTFOUND THEN

--        dbms_output.put_line('Invalid Support Site');

        fnd_message.set_name('JTF', 'JTF_RS_INVALID_SUPPORT_SITE');
        fnd_message.set_token('P_SUPPORT_SITE_ID', p_support_site_id);
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_error;

      END IF;

      CLOSE c_support_site_id;

    END IF;

  END validate_support_site_id;



  /* Validate the Server Group. */

  PROCEDURE  validate_server_group
  (p_server_group_id        IN    NUMBER,
   p_server_group_name      IN    VARCHAR2,
   x_return_status          OUT NOCOPY   VARCHAR2,
   x_server_group_id        OUT NOCOPY   NUMBER
  ) IS

    CURSOR c_server_group_id IS
      SELECT server_group_id
      FROM ieo_svr_groups
      WHERE server_group_id = p_server_group_id;

    CURSOR c_server_group_name IS
      SELECT server_group_id
      FROM ieo_svr_groups
      WHERE group_name = p_server_group_name;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF p_server_group_id IS NOT NULL THEN
      OPEN c_server_group_id;

      FETCH c_server_group_id INTO x_server_group_id;

      IF c_server_group_id%NOTFOUND THEN

--        dbms_output.put_line('Invalid Server Group Id');

        fnd_message.set_name('JTF', 'JTF_RS_INVALID_SRV_GROUP_ID');
        fnd_message.set_token('P_SERVER_GROUP_ID', p_server_group_id);
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_error;

      END IF;

      CLOSE c_server_group_id;

    ELSIF p_server_group_name IS NOT NULL THEN

      OPEN c_server_group_name;

      FETCH c_server_group_name INTO x_server_group_id;

      IF c_server_group_name%NOTFOUND THEN

--        dbms_output.put_line('Invalid Interaction Center Name');

        fnd_message.set_name('JTF', 'JTF_RS_INVALID_SVR_GROUP_NAME');
        fnd_message.set_token('P_SERVER_GROUP_NAME', p_server_group_name);
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_error;

      END IF;

      CLOSE c_server_group_name;

    END IF;

  END validate_server_group;



  /* Procedure to validate the Currency Code. */

  PROCEDURE  validate_currency_code
  (p_currency_code        IN   VARCHAR2,
   x_return_status        OUT NOCOPY VARCHAR2
  ) IS

    l_currency_code       fnd_currencies_active_monet_v.currency_code%TYPE;

    CURSOR c_currency_code IS
      SELECT currency_code
      FROM fnd_currencies_active_monet_v
      WHERE currency_code = p_currency_code;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF p_currency_code IS NULL THEN

--      dbms_output.put_line('Currency Code is null');

      fnd_message.set_name('JTF', 'JTF_RS_CURRENCY_NULL');
      fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_error;

    END IF;

    IF p_currency_code IS NOT NULL THEN

      OPEN c_currency_code;

      FETCH c_currency_code INTO l_currency_code;

      IF c_currency_code%NOTFOUND THEN

--        dbms_output.put_line('Invalid Currency Code');

        fnd_message.set_name('JTF', 'JTF_RS_INVALID_CURRENCY');
        fnd_message.set_token('P_CURRENCY', p_currency_code);
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_error;

      END IF;

      CLOSE c_currency_code;

    END IF;

  END validate_currency_code;



  /* Procedure to validate the Hold Reason Code. */

  PROCEDURE  validate_hold_reason_code
  (p_hold_reason_code     IN   VARCHAR2,
   x_return_status        OUT NOCOPY VARCHAR2
  ) IS

    l_hold_reason_code         VARCHAR2(30);

    CURSOR c_hold_reason_code IS
      SELECT lookup_code
      FROM fnd_lookups
      WHERE lookup_type = 'JTF_RS_HOLD_REASON_TYPE'
	   AND lookup_code = p_hold_reason_code;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF p_hold_reason_code IS NULL THEN

--      dbms_output.put_line('Hold Reason Code is null');

      fnd_message.set_name('JTF', 'JTF_RS_HOLD_REASON_CODE_NULL');
      fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_error;

    END IF;

    IF p_hold_reason_code IS NOT NULL THEN

      OPEN c_hold_reason_code;

      FETCH c_hold_reason_code INTO l_hold_reason_code;

      IF c_hold_reason_code%NOTFOUND THEN

--        dbms_output.put_line('Invalid Hold Reason Code');

        fnd_message.set_name('JTF', 'JTF_RS_INVALID_HOLD_REASON_COD');
        fnd_message.set_token('P_HOLD_REASON_CODE', p_hold_reason_code);
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_error;

      END IF;

      CLOSE c_hold_reason_code;

    END IF;

  END validate_hold_reason_code;



  /* Procedure to validate the Resource Team. */

  PROCEDURE  validate_resource_team
  (p_team_id              IN   NUMBER,
   p_team_number          IN   VARCHAR2,
   x_return_status        OUT NOCOPY  VARCHAR2,
   x_team_id              OUT NOCOPY  NUMBER
  ) IS

    CURSOR c_team_id IS
      SELECT team_id
      FROM jtf_rs_teams_b
      WHERE team_id = p_team_id;

    CURSOR c_team_number IS
      SELECT team_id
      FROM jtf_rs_teams_b
      WHERE team_number = p_team_number;


  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF p_team_id IS NULL AND p_team_number is NULL THEN

--      dbms_output.put_line('Team Id and Team Number are null');

      fnd_message.set_name('JTF', 'JTF_RS_TEAM_NULL');
      fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_error;

    END IF;


    IF p_team_id IS NOT NULL THEN

      OPEN c_team_id;

      FETCH c_team_id INTO x_team_id;

      IF c_team_id%NOTFOUND THEN

--        dbms_output.put_line('Invalid Team Id');

        fnd_message.set_name('JTF', 'JTF_RS_INVALID_TEAM');
        fnd_message.set_token('P_TEAM_ID', p_team_id);
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_error;

      END IF;

      CLOSE c_team_id;

    ELSIF p_team_number IS NOT NULL THEN

      OPEN c_team_number;

      FETCH c_team_number INTO x_team_id;

      IF c_team_number%NOTFOUND THEN

--        dbms_output.put_line('Invalid Team Number');

        fnd_message.set_name('JTF', 'JTF_RS_INVALID_TEAM_NUMBER');
        fnd_message.set_token('P_TEAM_NUMBER', p_team_number);
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_error;

      END IF;

      CLOSE c_team_number;

    END IF;

  END validate_resource_team;



  /* Procedure to validate the User Id. */

  PROCEDURE  validate_user_id
  (p_user_id              IN   NUMBER,
   p_category             IN   VARCHAR2,
   p_source_id            IN   NUMBER,
   x_return_status        OUT NOCOPY VARCHAR2
  ) IS

    l_user_id             fnd_user.user_id%TYPE;

/* Removed 'WORKER' from the below code for bug # 3455951 */
    CURSOR c_user_id IS
      SELECT user_id
      FROM fnd_user
      WHERE decode(p_category, 'EMPLOYEE', EMPLOYEE_ID, 'PARTY', CUSTOMER_ID, 'SUPPLIER_CONTACT', SUPPLIER_ID, null) = p_source_id
	   AND user_id = p_user_id;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF p_user_id IS NULL THEN

--      dbms_output.put_line('User Id is null');

      fnd_message.set_name('JTF', 'JTF_RS_USER_ID_NULL');
      fnd_msg_pub.add;

      x_return_status := fnd_api.g_ret_sts_error;

    END IF;

    IF p_user_id IS NOT NULL THEN

      OPEN c_user_id;

      FETCH c_user_id INTO l_user_id;

      IF c_user_id%NOTFOUND THEN

--        dbms_output.put_line('Invalid User Id');

        fnd_message.set_name('JTF', 'JTF_RS_INVALID_USER_ID');
        fnd_message.set_token('P_USER_ID', p_user_id);
        fnd_msg_pub.add;

        x_return_status := fnd_api.g_ret_sts_error;

      END IF;

      CLOSE c_user_id;

    END IF;

  END validate_user_id;



  /* Validate the Salesrep Id */

  PROCEDURE  validate_salesrep_id
  (p_salesrep_id	IN   NUMBER,
   p_org_id	        IN   NUMBER,
   x_return_status	OUT NOCOPY VARCHAR2
  ) IS

    l_salesrep_id       jtf_rs_salesreps.salesrep_id%TYPE;
    l_org_id            jtf_rs_salesreps.org_id%TYPE;

    CURSOR c_salesrep_id IS
      SELECT salesrep_id
      FROM jtf_rs_salesreps
      WHERE salesrep_id = p_salesrep_id
-- NVL function for ORG_ID should be removed, as Multi-Org is mandatory for Release 11i.11.(MOAC changes)
--      AND nvl (org_id,-99) = nvl (p_org_id,-99);
      AND org_id = p_org_id;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    IF p_salesrep_id IS NULL THEN
--      dbms_output.put_line('Salesrep Id is null');
      fnd_message.set_name('JTF', 'JTF_RS_SALESREP_ID_NULL');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;
    IF p_salesrep_id IS NOT NULL THEN
      OPEN c_salesrep_id;
      FETCH c_salesrep_id INTO l_salesrep_id;
      IF c_salesrep_id%NOTFOUND THEN
--        dbms_output.put_line('Invalid Salesrep Id');
        fnd_message.set_name('JTF', 'JTF_RS_INVALID_SALESREP_ID');
        fnd_message.set_token('P_SALESREP_ID', p_salesrep_id);
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;
      CLOSE c_salesrep_id;
    END IF;
  END validate_salesrep_id;

  /*
     Procedure : Validate Salesrep Dates
     Procedure created by Nishant on 17-Oct-2005 to fix bug 4354269. It will
     validate both start date and end date against resource start date and end date
  */
  PROCEDURE validate_salesrep_dates
  (P_ID               IN   VARCHAR2,
   P_ORG_ID		      IN   NUMBER,
   P_SRP_START_DATE   IN   DATE,
   p_SRP_END_DATE     IN   DATE,
   P_CR_UPD_MODE      IN   VARCHAR2,
   X_RETURN_STATUS    OUT NOCOPY VARCHAR2
  ) IS

  L_SRP_START_DATE DATE;
  L_SRP_END_DATE   DATE;
  L_RES_START_DATE DATE;
  L_RES_END_DATE   DATE;

  CURSOR c_get_res_dates_cr (l_resource_id IN NUMBER, l_org_id IN NUMBER) IS
	SELECT a.start_date_active, nvl(a.end_date_active,TO_DATE('12/31/4712','MM/DD/RRRR'))
	FROM   jtf_rs_resource_extns a
	      , jtf_rs_salesreps b
	WHERE a.resource_id = b.resource_id
	AND   b.resource_id = l_resource_id
	AND   b.org_id      = l_org_id
	;

  CURSOR c_get_res_dates_upd (l_salesrep_id IN NUMBER, l_org_id IN NUMBER) IS
	SELECT a.start_date_active, nvl(a.end_date_active,TO_DATE('12/31/4712','MM/DD/RRRR'))
	FROM   jtf_rs_resource_extns a
	      , jtf_rs_salesreps b
	WHERE a.resource_id = b.resource_id
	AND   b.salesrep_id = l_salesrep_id
	AND   b.org_id      = l_org_id
	;

  CURSOR c_get_srp_start_date (l_salesrep_id IN NUMBER, l_org_id IN NUMBER) IS
	SELECT b.start_date_active
	FROM   jtf_rs_salesreps b
	WHERE b.salesrep_id = l_salesrep_id
	AND   b.org_id      = l_org_id
	;

  CURSOR c_get_srp_end_date (l_salesrep_id IN NUMBER, l_org_id IN NUMBER) IS
	SELECT NVL(b.end_date_active,TO_DATE('12/31/4712','MM/DD/RRRR'))
	FROM   jtf_rs_salesreps b
	WHERE b.salesrep_id = l_salesrep_id
	AND   b.org_id      = l_org_id
	;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    -- if mode is create, p_id is resource_id
    IF (p_cr_upd_mode = 'C') THEN
	  L_SRP_START_DATE := P_SRP_START_DATE;

  	  IF (P_SRP_END_DATE IS NOT NULL) THEN
	    L_SRP_END_DATE := P_SRP_END_DATE;
	  ELSE
	    L_SRP_END_DATE := TO_DATE('12/31/4712','MM/DD/RRRR');
	  END IF;

  	  OPEN c_get_res_dates_cr (p_id, p_org_id);
	  FETCH c_get_res_dates_cr INTO l_res_start_date, l_res_end_date;
	  CLOSE c_get_res_dates_cr;
    END IF;

    -- if mode is create, p_id is salesrep_id
    IF (p_cr_upd_mode = 'U') THEN
  	  IF (P_SRP_START_DATE = FND_API.G_MISS_DATE) THEN
	    OPEN c_get_srp_start_date(p_id, p_org_id);
	    FETCH c_get_srp_start_date INTO L_SRP_START_DATE;
	    CLOSE c_get_srp_start_date;
	  ELSE
	    L_SRP_START_DATE := P_SRP_START_DATE;
	  END IF;

	  IF (P_SRP_END_DATE = FND_API.G_MISS_DATE) THEN
	    OPEN c_get_srp_end_date(p_id, p_org_id);
	    FETCH c_get_srp_end_date INTO L_SRP_END_DATE;
	    CLOSE c_get_srp_end_date;
	  ELSIF (P_SRP_END_DATE IS NOT NULL) THEN
	    L_SRP_END_DATE := P_SRP_END_DATE;
	  ELSE
	    L_SRP_END_DATE := TO_DATE('12/31/4712','MM/DD/RRRR');
	  END IF;

	  OPEN c_get_res_dates_upd (p_id, p_org_id);
	  FETCH c_get_res_dates_upd INTO l_res_start_date, l_res_end_date;
	  CLOSE c_get_res_dates_upd;

	END IF;

	IF (l_srp_start_date < l_res_start_date) THEN
      fnd_message.set_name('JTF', 'JTF_RS_SRP_STDT_GRTR_RES_STDT');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
	END IF;

	IF (l_srp_end_date > l_res_end_date) THEN
      fnd_message.set_name('JTF', 'JTF_RS_SRP_EDDT_GRTR_RES_EDDT');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
	END IF;

  END validate_salesrep_dates;

  /* Validate the Territory Id */

  PROCEDURE  validate_territory_id
  (p_territory_id        IN   NUMBER,
   x_return_status      OUT NOCOPY  VARCHAR2
  ) IS

    l_territory_id       ra_territories.territory_id%TYPE;

    CURSOR c_territory_id IS
      SELECT territory_id
      FROM ra_territories
      WHERE territory_id = p_territory_id;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    IF p_territory_id IS NULL THEN
--      dbms_output.put_line('Territory Id is null');
      fnd_message.set_name('JTF', 'JTF_RS_TERRITORY_ID_NULL');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;
    IF p_territory_id IS NOT NULL THEN
      OPEN c_territory_id;
      FETCH c_territory_id INTO l_territory_id;
      IF c_territory_id%NOTFOUND THEN
--        dbms_output.put_line('Invalid Territory Id');
        fnd_message.set_name('JTF', 'JTF_RS_INVALID_TERRITORY_ID');
        fnd_message.set_token('P_TERRITORY_ID', p_territory_id);
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;
      CLOSE c_territory_id;
    END IF;
  END validate_territory_id;



  PROCEDURE validate_salesrep_number (
    P_SALESREP_NUMBER      IN   VARCHAR2,
    P_ORG_ID	           IN   NUMBER,
    X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  ) IS

    CURSOR c_salesrep_number IS
      SELECT 'X'
      FROM   jtf_rs_salesreps
      WHERE  salesrep_number = p_salesrep_number
-- NVL function for ORG_ID should be removed, as Multi-Org is mandatory for Release 11i.11.(MOAC changes)
--      AND    nvl(org_id,-99) = nvl(p_org_id,-99);
      AND org_id = p_org_id;

--      AND    org_id = to_number(decode(substrb(userenv('CLIENT_INFO'),1,1),' ',null,substrb(userenv('CLIENT_INFO'),1,10)));

    l_salesrep_number     jtf_rs_salesreps.salesrep_number%TYPE;
    l_val                 VARCHAR2(1);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    /* Record is being inserted, check that salesrep number does not already exist */
    IF (p_salesrep_number IS NOT NULL) THEN

      OPEN c_salesrep_number;

      FETCH c_salesrep_number INTO l_val;

      IF (c_salesrep_number%FOUND) THEN
        fnd_message.set_name('JTF', 'JTF_RS_ERR_SALESREP_NUMBER');
        fnd_message.set_token('P_SALESREP_NUMBER', p_salesrep_number);
        fnd_msg_pub.add;
--        dbms_output.put_line('Salesrep already exists');
        x_return_status := fnd_api.g_ret_sts_error;

      END IF;

      CLOSE c_salesrep_number;

    ELSE

      fnd_message.set_name('JTF', 'JTF_RS_SALESREP_NUMBER_NULL');
      fnd_msg_pub.add;
--      dbms_output.put_line('Salesrep number is null');
      x_return_status := fnd_api.g_ret_sts_error;
    /* Commented the below line to fix the bug # 3436895 */
--      CLOSE c_salesrep_number;

    END IF;

  END validate_salesrep_number;


  /* Validate the Sales Credit Type Id */

  PROCEDURE  validate_sales_credit_type (
   P_SALES_CREDIT_TYPE_ID      IN   NUMBER,
   X_RETURN_STATUS             OUT NOCOPY VARCHAR2
    )
  IS

    CURSOR   c_credit_type IS
      SELECT 'X'
      FROM   oe_sales_credit_types
      WHERE  quota_flag = 'Y'
      AND    enabled_flag = 'Y'
      AND    sales_credit_type_id = p_sales_credit_type_id;

      l_val VARCHAR2(1);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    /* Check credit type id is NOT NULL or not*/

    IF (p_sales_credit_type_id is NOT NULL) THEN

      OPEN c_credit_type;
      FETCH c_credit_type INTO l_val;

      IF (c_credit_type%NOTFOUND) THEN

        fnd_message.set_name('JTF', 'JTF_RS_ERR_SALES_CREDIT_TYPE');
        fnd_message.set_token('P_SALES_CREDIT_TYPE_ID', p_sales_credit_type_id);
        fnd_msg_pub.add;
--        dbms_output.put_line('Invalid Sales Credit Type');
        x_return_status := fnd_api.g_ret_sts_error;

      END IF;

      CLOSE c_credit_type;

    ELSE

      fnd_message.set_name('JTF', 'JTF_RS_SALES_CREDIT_TYPE_NULL');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
--      dbms_output.put_line('Sales Credit type id is NULL');

    END IF;

  END validate_sales_credit_type;


  PROCEDURE check_object_existence
  (P_OBJECT_CODE              IN   JTF_OBJECTS_B.OBJECT_CODE%TYPE,
   P_SELECT_ID                IN   VARCHAR2,
   P_OBJECT_USER_CODE     IN   VARCHAR2,
   X_FOUND                    OUT NOCOPY  BOOLEAN ,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  ) AS

  CURSOR  object_dtls_cur(l_object_code JTF_OBJECTS_B.OBJECT_CODE%TYPE,
                          l_object_user_code JTF_OBJECT_USAGES.OBJECT_USER_CODE%TYPE)
      IS
  SELECT a.select_id
        ,a.from_table
        ,a.where_clause
   FROM jtf_objects_B a,
        jtf_object_usages b
  WHERE b.OBJECT_USER_CODE  = l_object_user_code
    AND b.object_code = a.object_code
    and A.object_code = l_object_code;

  object_dtls_rec object_dtls_cur%rowtype;

  CURSOR  object_code_cur(l_object_user_code JTF_OBJECT_USAGES.OBJECT_USER_CODE%TYPE)
      IS
  SELECT 'x'
   FROM jtf_object_usages b
  WHERE b.OBJECT_USER_CODE  = l_object_user_code;

  object_code_rec object_code_cur%rowtype;

  CURSOR  c_res_existence(c_resource_id IN NUMBER)
      IS
  SELECT  'X'
  FROM   jtf_rs_resource_extns
  WHERE  resource_id = c_resource_id;

  l_temp           varchar2(1);

  l_object_code    JTF_OBJECTS_B.OBJECT_CODE%TYPE;
  l_select_id      number;

  ll_object_user_code JTF_OBJECT_USAGES.OBJECT_USER_CODE%type;
  l_select_clause  VARCHAR2(4000);

  --FOR DYNAMIC SQL
  l_cursorid  NUMBER;
  v_dummy  integer;

  --STANDARD VARIABLES
   l_date      Date;
   l_user_id   Number;
   l_login_id  Number;

  BEGIN

    l_object_code       := p_object_code;
    l_select_id         := to_number(p_select_id);
    ll_object_user_code := UPPER(p_object_user_code);

    X_FOUND := FALSE;

    open object_code_cur(ll_object_user_code);
    fetch object_code_cur INTO object_code_rec;
    IF(object_code_cur%FOUND)
    THEN
      if object_code_cur%ISOPEN THEN
	close object_code_cur;
      end if;
      --open the cursor to get the related values from jtf_objects_b
      open object_dtls_cur(l_object_code, ll_object_user_code);
      fetch object_dtls_cur INTO object_dtls_rec;
      IF(object_dtls_cur%FOUND)
      THEN
        if object_dtls_cur%ISOPEN THEN
	  close object_dtls_cur;
        end if;
        x_return_status := fnd_api.g_ret_sts_success;
        /* Added the below code to fix the bug # 3357906
           Changed the object existence validation for 'RS_INDIVIDUAL' to jtf_rs_resource_extns from jtf_objects,
           because we do not have enough time to investigate the impact of changing the
           jtf_objects definition for the object type 'RS_INDIVIDUAL'. */
        if l_object_code = 'RS_INDIVIDUAL' then

           OPEN c_res_existence(l_select_id);
           FETCH c_res_existence INTO l_temp;
           IF c_res_existence%FOUND THEN
              x_found := TRUE;
              x_return_status := FND_API.G_RET_STS_SUCCESS;
              CLOSE c_res_existence;
              return;
           ELSE
              x_found := FALSE;
              x_return_status := FND_API.G_RET_STS_SUCCESS;
              CLOSE c_res_existence;
              return;
           END IF;
        else
        --create the sql staement based on the values fetched from jtf_objects_b
        IF object_dtls_rec.where_clause IS NOT NULL
        THEN
/* BINDVAR_SCAN_IGNORE [1] */
          l_select_clause := 'SELECT  '|| object_dtls_rec.select_id ||' '
                      ||' FROM  '||object_dtls_rec.from_table ||' '
                      ||' WHERE ( '||object_dtls_rec.where_clause ||')'
                      ||' AND   '|| object_dtls_rec.select_id ||' = :x';
        ELSE
/* BINDVAR_SCAN_IGNORE [1] */
          l_select_clause := 'SELECT  '|| object_dtls_rec.select_id ||' '
                      ||' FROM  '||object_dtls_rec.from_table ||' '
                      ||' WHERE   '|| object_dtls_rec.select_id ||' =  :x';

        END IF;

        --process the dynamic sql statement
        l_cursorid := DBMS_SQL.OPEN_CURSOR;

        DBMS_SQL.PARSE(l_cursorid, l_select_clause, DBMS_SQL.V7);
	DBMS_SQL.BIND_VARIABLE(l_cursorid,':x',l_select_id);

        v_dummy := DBMS_SQL.EXECUTE(l_cursorid);


        IF DBMS_SQL.FETCH_ROWS(l_cursorid) = 0
        THEN
          X_FOUND := FALSE;
        ELSE
          X_FOUND := TRUE;
        END IF;

        DBMS_SQL.CLOSE_CURSOR(l_cursorid);

        end if;
      ELSE
        --if object not found
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_message.set_name ('JTF', 'JTF_RS_INVALID_RL_RES_TYPE');
        FND_MSG_PUB.add;

      END IF;

      if object_dtls_cur%ISOPEN THEN
        close object_dtls_cur;
      end if;

    ELSE

      --IF object user code is not valid
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name ('JTF', 'JTF_RS_INVALID_OBJ_USER_CODE');
      FND_MSG_PUB.add;

    END IF;

   --FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION

    WHEN fnd_api.g_exc_unexpected_error
    THEN
      if object_code_cur%ISOPEN THEN
	close object_code_cur;
      end if;
        if object_dtls_cur%ISOPEN THEN
	  close object_dtls_cur;
        end if;
      fnd_message.set_name ('JTF', 'JTF_OBJECT_ERR');
      FND_MSG_PUB.add;
    WHEN fnd_api.g_exc_error
    THEN
      null;

    WHEN OTHERS
    THEN
      if object_code_cur%ISOPEN THEN
	close object_code_cur;
      end if;
      if object_dtls_cur%ISOPEN THEN
	  close object_dtls_cur;
      end if;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME','CHECK_OBJECT_EXISTENCE');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

   END check_object_existence;


  PROCEDURE check_object_existence_migr
  (P_OBJECT_CODE	IN   JTF_OBJECTS_B.OBJECT_CODE%TYPE,
   P_SELECT_ID		IN   VARCHAR2,
   P_OBJECT_USER_CODE   IN   VARCHAR2,
   P_RS_ID_PUB_FLAG	IN   VARCHAR2,
   X_FOUND		OUT NOCOPY BOOLEAN,
   X_RETURN_STATUS      OUT NOCOPY VARCHAR2
  ) AS

  CURSOR  object_dtls_cur(l_object_code JTF_OBJECTS_B.OBJECT_CODE%TYPE,
                          l_object_user_code JTF_OBJECT_USAGES.OBJECT_USER_CODE%TYPE)
      IS
  SELECT a.select_id
        ,a.from_table
        ,a.where_clause
   FROM jtf_objects_B a,
        jtf_object_usages b
  WHERE b.OBJECT_USER_CODE  = l_object_user_code
    AND b.object_code = a.object_code
    and A.object_code = l_object_code;

  object_dtls_rec object_dtls_cur%rowtype;

  CURSOR  object_code_cur(l_object_user_code JTF_OBJECT_USAGES.OBJECT_USER_CODE%TYPE)
      IS
  SELECT 'x'
   FROM jtf_object_usages b
  WHERE b.OBJECT_USER_CODE  = l_object_user_code;

  CURSOR  emp_existence(p_person_id IN NUMBER)
      IS
  SELECT 'x',full_name
   FROM per_all_people_f
  WHERE person_id  = p_person_id;

  CURSOR c_party_existence(c_party_id IN NUMBER) IS
  SELECT hz.party_id
  FROM   hz_parties hz
  WHERE  party_type  not in ('ORGANIZATION', 'GROUP')
  AND    hz.party_id  = c_party_id
  AND not exists ( select person_id
                   from per_all_people_f per
                   where per.party_id = hz.party_id);

  object_code_rec object_code_cur%rowtype;

  l_object_code	   JTF_OBJECTS_B.OBJECT_CODE%TYPE;
  l_select_id      number;

  ll_object_user_code JTF_OBJECT_USAGES.OBJECT_USER_CODE%type;
  l_select_clause  VARCHAR2(4000);

  --FOR DYNAMIC SQL
  l_cursorid  NUMBER;
  v_dummy  integer;

  --STANDARD VARIABLES
   l_date      Date;
   l_user_id   Number;
   l_login_id  Number;
   l_temp      Varchar2(1);
   l_party_id  Number;

  BEGIN

    l_object_code       := p_object_code;
    l_select_id         := to_number(p_select_id);
    ll_object_user_code := UPPER(p_object_user_code);
    l_temp              := '?';

    X_FOUND := FALSE;

    open object_code_cur(ll_object_user_code);
    fetch object_code_cur INTO object_code_rec;
    IF(object_code_cur%FOUND)
    THEN
      if object_code_cur%ISOPEN then
	close object_code_cur;
      end if;
      --open the cursor to get the related values from jtf_objects_b
      open object_dtls_cur(l_object_code, ll_object_user_code);
      fetch object_dtls_cur INTO object_dtls_rec;
      IF(object_dtls_cur%FOUND)
      THEN
        if object_dtls_cur%ISOPEN then
  	  close object_dtls_cur;
        end if;
        x_return_status := fnd_api.g_ret_sts_success;

        --create the sql staement based on the values fetched from jtf_objects_b

        IF (P_OBJECT_CODE <> 'EMPLOYEE' and P_OBJECT_CODE <> 'PARTY') THEN
           IF object_dtls_rec.where_clause IS NOT NULL
           THEN
/* BINDVAR_SCAN_IGNORE [1] */
              l_select_clause := 'SELECT  '|| object_dtls_rec.select_id ||' '
                      ||' FROM  '||object_dtls_rec.from_table ||' '
                      ||' WHERE ( '||object_dtls_rec.where_clause ||')'
                      ||' AND   '|| object_dtls_rec.select_id ||' = :x';
           ELSE
/* BINDVAR_SCAN_IGNORE [1] */
              l_select_clause := 'SELECT  '|| object_dtls_rec.select_id ||' '
                      ||' FROM  '||object_dtls_rec.from_table ||' '
                      ||' WHERE   '|| object_dtls_rec.select_id ||' = :x';
           END IF;
        ELSIF P_OBJECT_CODE = 'EMPLOYEE' THEN
           IF P_RS_ID_PUB_FLAG = 'Y'
           THEN
/* BINDVAR_SCAN_IGNORE [1] */
              l_select_clause := 'SELECT  '|| object_dtls_rec.select_id ||' '
                      ||' FROM  '||object_dtls_rec.from_table ||' '
                      ||' WHERE ( '||object_dtls_rec.where_clause ||')'
                      ||' AND   '|| object_dtls_rec.select_id ||' = :x';
           ELSIF P_RS_ID_PUB_FLAG = 'N'
           THEN

	     OPEN emp_existence(l_select_id);
	     FETCH emp_existence INTO l_temp,G_SOURCE_NAME;
	     CLOSE emp_existence;

             if l_temp = 'x' then
               x_found := TRUE;
               x_return_status := FND_API.G_RET_STS_SUCCESS;
               return;
	     else
               x_found := FALSE;
               x_return_status := fnd_api.g_ret_sts_unexp_error;
             end if;
           END IF;
        ELSIF P_OBJECT_CODE = 'PARTY' THEN
           OPEN c_party_existence(l_select_id);
           FETCH c_party_existence INTO l_party_id;
           IF c_party_existence%FOUND THEN
              x_found := TRUE;
              x_return_status := FND_API.G_RET_STS_SUCCESS;
              return;
           ELSE
              x_found := FALSE;
              x_return_status := FND_API.G_RET_STS_SUCCESS;
              return;
           END IF;
           CLOSE c_party_existence;

        END IF;

        --process the dynamic sql statement
        l_cursorid := DBMS_SQL.OPEN_CURSOR;

        DBMS_SQL.PARSE(l_cursorid, l_select_clause, DBMS_SQL.V7);

	DBMS_SQL.BIND_VARIABLE(l_cursorid,':x',l_select_id);
        v_dummy := DBMS_SQL.EXECUTE(l_cursorid);


        IF DBMS_SQL.FETCH_ROWS(l_cursorid) = 0
        THEN
          X_FOUND := FALSE;
        ELSE
          X_FOUND := TRUE;
        END IF;

        DBMS_SQL.CLOSE_CURSOR(l_cursorid);

      ELSE
        --if object not found
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_message.set_name ('JTF', 'JTF_RS_INVALID_RL_RES_TYPE');
        FND_MSG_PUB.add;

      END IF;

        if object_dtls_cur%ISOPEN then
  	  close object_dtls_cur;
        end if;

    ELSE

      --IF object user code is not valid
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('JTF', 'JTF_RS_INVALID_OBJ_USER_CODE');
      FND_MSG_PUB.add;

    END IF;

   --FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION

    WHEN fnd_api.g_exc_unexpected_error
    THEN
      if object_code_cur%ISOPEN then
	close object_code_cur;
      end if;
      if object_dtls_cur%ISOPEN then
        close object_dtls_cur;
      end if;

      fnd_message.set_name ('JTF', 'JTF_OBJECT_ERR');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      --FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN fnd_api.g_exc_error
    THEN
       x_return_status := fnd_api.g_ret_sts_error;
    WHEN OTHERS
    THEN
      if object_code_cur%ISOPEN then
	close object_code_cur;
      end if;
      if object_dtls_cur%ISOPEN then
        close object_dtls_cur;
      end if;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME','CHECK_OBJECT_EXISTENCE_MIGR');
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      --FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  END check_object_existence_migr;



   /* Procedure to validate Resource Param Id */

   PROCEDURE  validate_resource_param_id (
      p_resource_param_id	IN	NUMBER,
      x_return_status      	OUT NOCOPY	VARCHAR2
   )
   IS

   l_resource_param_id	JTF_RS_RESOURCE_PARAMS.resource_param_id%TYPE;

   CURSOR c_resource_param_id IS
      SELECT resource_param_id
      FROM jtf_rs_resource_params
      WHERE resource_param_id = p_resource_param_id;

   BEGIN

      x_return_status := fnd_api.g_ret_sts_success;

      IF p_resource_param_id IS NULL THEN
         fnd_message.set_name('JTF', 'JTF_RS_RESOURCE_PARAM_ID_NULL');
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      IF p_resource_param_id IS NOT NULL THEN

         OPEN c_resource_param_id;
         FETCH c_resource_param_id INTO l_resource_param_id;

         IF c_resource_param_id%NOTFOUND THEN
            fnd_message.set_name('JTF', 'JTF_RS_INVALID_RS_PRM_ID');
            fnd_message.set_token('P_RESOURCE_PARAM_ID', p_resource_param_id);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_error;
         END IF;
         CLOSE c_resource_param_id;
      END IF;

   END validate_resource_param_id;


   /* Procedure to Validate Resource Value Type */

   PROCEDURE  validate_rs_value_type (
      p_resource_param_id	IN	JTF_RS_RESOURCE_VALUES.RESOURCE_PARAM_ID%TYPE,
      p_value_type		IN   	JTF_RS_RESOURCE_VALUES.VALUE_TYPE%TYPE,
      x_return_status      	OUT NOCOPY 	VARCHAR2
   )
   IS

   l_value_type		JTF_RS_RESOURCE_VALUES.VALUE_TYPE%TYPE;
   c_application_id	JTF_RS_RESOURCE_PARAMS.APPLICATION_ID%TYPE;

    CURSOR c_value_type_m (l_application_id JTF_RS_RESOURCE_PARAMS.APPLICATION_ID%TYPE)
   IS
      SELECT value_type
      FROM jtf_rs_cct_middlewares_v cctmv, jtf_rs_resource_params jrspm
      WHERE cctmv.value_type = p_value_type
         AND jrspm.application_id = l_application_id;

   CURSOR c_value_type_e (l_application_id JTF_RS_RESOURCE_PARAMS.APPLICATION_ID%TYPE)
   IS
      SELECT value_type
      FROM jtf_rs_email_accounts_v iemac, jtf_rs_resource_params jtrpm
      WHERE iemac.value_type = p_value_type
         AND jtrpm.application_id = l_application_id;

   CURSOR c_value_type_no_sg_check
   IS
     SELECT email_account_id
     FROM   iem_email_accounts
     WHERE  email_account_id = p_value_type;

   server_group_check   varchar2(100);

   BEGIN

      x_return_status := fnd_api.g_ret_sts_success;

      fnd_profile.get('JTF_RS_SERVER_GROUP_CHECK',server_group_check);

        SELECT application_id
         INTO c_application_id
	 FROM jtf_rs_resource_params
    	 WHERE resource_param_id = p_resource_param_id;

      x_return_status := fnd_api.g_ret_sts_success;
      IF p_value_type IS NOT NULL THEN

         IF c_application_id = 172 THEN
      	    OPEN c_value_type_m (c_application_id);
      	    FETCH c_value_type_m INTO l_value_type;

            IF c_value_type_m%NOTFOUND THEN

               fnd_message.set_name('JTF', 'JTF_RS_INVALID_VALUE_TYPE');
               fnd_message.set_token('P_VALUE_TYPE', p_value_type);
               fnd_msg_pub.add;

               x_return_status := fnd_api.g_ret_sts_error;
            END IF;

            CLOSE c_value_type_m;

         ELSIF c_application_id = 680 THEN
            if server_group_check = 'N' then
               OPEN c_value_type_no_sg_check;
               FETCH c_value_type_no_sg_check INTO l_value_type;
               IF c_value_type_no_sg_check%NOTFOUND THEN
                  fnd_message.set_name('JTF', 'JTF_RS_INVALID_VALUE_TYPE');
                  fnd_message.set_token('P_VALUE_TYPE', p_value_type);
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
               END IF;
               CLOSE c_value_type_no_sg_check;
            else
               OPEN c_value_type_e (c_application_id);
               FETCH c_value_type_e INTO l_value_type;
               IF c_value_type_e%NOTFOUND THEN
                  fnd_message.set_name('JTF', 'JTF_RS_INVALID_VALUE_TYPE');
                  fnd_message.set_token('P_VALUE_TYPE', p_value_type);
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
               END IF;
               CLOSE c_value_type_e;
            end if;
         END IF;
      END IF;

   END validate_rs_value_type;


   /* Procedure to validate the resource value */

   PROCEDURE  validate_resource_value (
      p_resource_param_id	IN	JTF_RS_RESOURCE_VALUES.RESOURCE_PARAM_ID%TYPE,
      p_value         		IN	JTF_RS_RESOURCE_VALUES.VALUE%TYPE,
      x_return_status      	OUT NOCOPY 	VARCHAR2
   )
   IS

   l_value	      	JTF_RS_RESOURCE_VALUES.VALUE%TYPE;
   l_lookup_code	FND_LOOKUPS.LOOKUP_CODE%TYPE;
   v_type 		VARCHAR2(32);
   v_length 		VARCHAR2(32);
   p_length 		NUMBER;
   i 			NUMBER;

   CURSOR c_lookup_code IS
      SELECT lookup_code
      FROM fnd_lookups fnl, jtf_rs_resource_params jrp
      WHERE fnl.lookup_type           	= jrp.domain_lookup_type
         AND jrp.resource_param_id    	= p_resource_param_id
         AND lookup_code		= p_value;

   BEGIN

      l_value    := p_value;

      SELECT type , length into v_type ,v_length
      FROM jtf_rs_resource_params
      WHERE resource_param_id 	= p_resource_param_id;

      p_length:=LENGTH(p_value);
      x_return_status := fnd_api.g_ret_sts_success;
      IF p_value IS NULL THEN
         fnd_message.set_name('JTF', 'JTF_RS_VALUE_NULL');
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      OPEN c_lookup_code;
      FETCH c_lookup_code INTO l_lookup_code;
      IF c_lookup_code%NOTFOUND THEN
         IF (v_type in ('INT','INTEGER','NUMBER')) THEN
            FOR i in 1..p_length LOOP
               IF NOT ((SUBSTR(l_value,i,1)='0') or (SUBSTR(l_value,i,1)='1') or (SUBSTR(l_value,i,1)='2') or
                  (SUBSTR(l_value,i,1)='3') or (SUBSTR(l_value,i,1)='4') or (SUBSTR(l_value,i,1)='5') or
                  (SUBSTR(l_value,i,1)='6') or (SUBSTR(l_value,i,1)='7') or (SUBSTR(l_value,i,1)='8') or
                  (SUBSTR(l_value,i,1)='9')) THEN
      		     fnd_message.set_name('JTF', 'JTF_RS_VALUE_ERR_DATA_TYPE');
      		     fnd_msg_pub.add;
      		     x_return_status := fnd_api.g_ret_sts_error;
               END IF;
            END LOOP;
         END IF;
         IF (p_length > to_number(v_length)) or (p_length = 0 ) THEN
            fnd_message.set_name('JTF', 'JTF_RS_VALUE_INCORRECT_LENGTH');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_error;
         END IF;
      END IF;
      CLOSE c_lookup_code;
   END validate_resource_value;


   /* Procedure to validate the resource role */

   PROCEDURE  validate_resource_role (
      p_role_id            IN      JTF_RS_ROLES_B.ROLE_ID%TYPE,
      p_role_code          IN      JTF_RS_ROLES_B.ROLE_CODE%TYPE,
      x_return_status      OUT NOCOPY     VARCHAR2,
      x_role_id            OUT NOCOPY     JTF_RS_ROLES_B.ROLE_ID%TYPE
   )
   IS

   CURSOR c_role_id IS
      SELECT role_id
      FROM jtf_rs_roles_vl
      WHERE role_id = p_role_id;

   CURSOR c_role_code IS
      SELECT role_id
      FROM jtf_rs_roles_vl
      WHERE role_code = p_role_code;

   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      IF p_role_id IS NULL AND p_role_code is NULL THEN
         fnd_message.set_name('JTF', 'JTF_RS_ROLE_NULL');
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      IF p_role_id IS NOT NULL THEN
         OPEN c_role_id;
         FETCH c_role_id INTO x_role_id;
         IF c_role_id%NOTFOUND THEN
            fnd_message.set_name('JTF', 'JTF_RS_INVALID_ROLE');
            fnd_message.set_token('P_ROLE_ID', p_role_id);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_error;
         END IF;
         CLOSE c_role_id;

      ELSIF p_role_code IS NOT NULL THEN
         OPEN c_role_code;
         FETCH c_role_code INTO x_role_id;
         IF c_role_code%NOTFOUND THEN
            fnd_message.set_name('JTF', 'JTF_RS_INVALID_ROLE_CODE');
            fnd_message.set_token('P_ROLE_CODE', p_role_code);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_error;
         END IF;
         CLOSE c_role_code;
      END IF;

   END validate_resource_role;


   /* Procedure to validate resource role flags */

   PROCEDURE  validate_rs_role_flags (
      p_rs_role_flag	IN      VARCHAR2,
      x_return_status   OUT NOCOPY    VARCHAR2
   )
   IS
      l_rs_role_flag  varchar2(1);

   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      l_rs_role_flag := upper(p_rs_role_flag);
      IF ( l_rs_role_flag <> 'Y' and l_rs_role_flag <>'N') THEN
         fnd_message.set_name('JTF', 'JTF_RS_INVALID_FLAG');
         fnd_message.set_token('P_RS_ROLE_FLAG', p_rs_role_flag);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_error;
      END IF;
   END validate_rs_role_flags;

   /* Function  : get_g_miss_char */

   FUNCTION get_g_miss_num RETURN NUMBER is
   begin
      return (fnd_api.g_miss_num);
   end get_g_miss_num;

   /* Function  : get_g_miss_char */

   FUNCTION get_g_miss_char RETURN VARCHAR2 is
   begin
      return (fnd_api.g_miss_char);
   end get_g_miss_char;

   /*Function  : get_g_miss_date */

   FUNCTION get_g_miss_date RETURN DATE is
   begin
      return (fnd_api.g_miss_date);
   end get_g_miss_date;



     /*Function to check whether the ok_to_execute flag is ON or not */

  Function	Ok_To_Execute(	p_Pkg_name		varchar2,
				p_API_name		varchar2,
				p_Process_type		varchar2,
				p_User_hook_type	varchar2
  ) Return Boolean
IS
 l_execute	Varchar2(1);
l_conc_pgm_id   Number;
l_conc_pgm_name Varchar2(25);

Begin

   l_conc_pgm_name := 'DEFAULT';

   begin
     Select EXECUTE_FLAG
      into  l_execute
      from  JTF_USER_HOOKS
      Where
 	pkg_name = p_pkg_name	and
	api_name = p_api_name	and
	processing_type = p_process_type and
	user_hook_type = p_user_hook_type;
	Exception
		When NO_DATA_FOUND  then
			Return FALSE;

     End;

     If ( l_execute = 'Y' ) then
           Return TRUE;
     ELSE
           Return FALSE;
     End if;
   END Ok_To_Execute;


-- The below function will not be called from any API's.
-- Removing as a part of fixing GSCC errors in R12
-- Right now it is only called from jtfrsvrb.pls
    /* Function to check for access to XMLGEN and valid status of JTF_USR_HKS*/
/*
    Function  check_access( x_pkg_name		out NOCOPY varchar2
                          ) Return Boolean
   IS
      l_pkg_name VARCHAR2(30);

      CURSOR xml_cur
          IS
      SELECT obj.owner,
             obj.object_name
       FROM  all_objects obj
      WHERE  obj.object_name = 'XMLGEN'
      AND    obj.owner IN ('APPS', 'PUBLIC');

    xml_rec xml_cur%rowtype;


    CURSOR hk_cur
        IS
    SELECT obj.status,
           obj.object_type
      FROM all_objects obj
     WHERE obj.object_name = 'JTF_USR_HKS'
      AND  obj.object_type = 'PACKAGE BODY'
      AND  obj.owner in ('APPS', 'PUBLIC');

    hk_rec  hk_cur%rowtype;

   BEGIN

    open hk_cur;
      fetch hk_cur into hk_rec;
      if(hk_cur%found)
      then
         IF(hk_rec.status <> 'VALID')
         THEN
             --check xmlgen as the cause
             open xml_cur;
             fetch xml_cur into xml_rec;
             if(xml_cur%notfound)
             then
                x_pkg_name := 'XMLGEN';
                close xml_cur;
                return false;
             end if;
             close xml_cur;
             --else ret user hook error
             x_pkg_name := 'JTF_USR_HKS';
             close hk_cur;
             return false;
          END IF;
       end if;
      close hk_cur;

      return true;

   END check_access;
*/
   Function get_inventory_org_id RETURN NUMBER IS
     inventory_org_id varchar2(250);
   BEGIN
     fnd_profile.get('CS_INV_VALIDATION_ORG',inventory_org_id);
     RETURN(to_number(inventory_org_id));
   END get_inventory_org_id;

END jtf_resource_utl;

/
