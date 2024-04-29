--------------------------------------------------------
--  DDL for Package Body PVX_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PVX_UTILITY_PVT" AS
/* $Header: pvxvutlb.pls 120.7 2008/01/14 23:04:07 rnori ship $ */

  TYPE col_val_rec IS RECORD (
      col_name    VARCHAR2(2000),
      col_op      VARCHAR2(10),
      col_value   VARCHAR2(2000) );

  TYPE col_val_tbl IS TABLE OF col_val_rec INDEX BY BINARY_INTEGER;

---------------------------------------------------------------------
-- FUNCTION
--    bind_parse
--
-- DESCRIPTION
--    Given a string containing the WHERE conditions in a WHERE
--    clause, return a tuple of column name and column value.
---------------------------------------------------------------------
  PROCEDURE bind_parse (
     p_string IN VARCHAR2,
     x_col_val_tbl OUT NOCOPY col_val_tbl
  );


---------------------------------------------------------------------
-- FUNCTION
--    check_fk_exists
--
---------------------------------------------------------------------
FUNCTION check_fk_exists(
   p_table_name   IN VARCHAR2,
   p_pk_name      IN VARCHAR2,
   p_pk_value     IN VARCHAR2,
   p_pk_data_type IN NUMBER := g_number,
   p_additional_where_clause  IN VARCHAR2 := NULL
)
RETURN VARCHAR2
IS

   l_sql   VARCHAR2(4000);
   l_count NUMBER;

BEGIN
   l_sql := 'SELECT 1 FROM DUAL WHERE EXISTS (SELECT 1 FROM ' || UPPER(p_table_name);
   l_sql := l_sql || ' WHERE ' || UPPER(p_pk_name) || ' = :b1';

   IF p_additional_where_clause IS NOT NULL THEN
      -- given time, incorporate bind_parse
      l_sql := l_sql || ' AND ' || p_additional_where_clause;
   END IF;

   l_sql := l_sql || ')';

   debug_message('SQL statement: '||l_sql);
   BEGIN
      EXECUTE IMMEDIATE l_sql INTO l_count
      USING p_pk_value;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_count := 0;
   END;

   IF l_count = 0 THEN
      RETURN FND_API.g_false;
   ELSE
      RETURN FND_API.g_true;
   END IF;

END check_fk_exists;



---------------------------------------------------------------------
-- FUNCTION
--    is_vendor_admin_user
--
---------------------------------------------------------------------
FUNCTION is_vendor_admin_user(
 p_resource_id   IN NUMBER
)
RETURN VARCHAR2
IS

   l_temp varchar2(1);
   is_vendor_admin varchar2(1):=FND_API.g_false;

   CURSOR isvendor_csr(p_res_id NUMBER) IS
   SELECT 'Y'
   FROM   jtf_rs_role_relations role_reln,  jtf_rs_roles_vl rl
   WHERE  rl.ROLE_TYPE_CODE = 'PRM'
   AND    rl.role_code = 'PV_VENDOR_ADMINISTRATOR'
   AND    rl.role_id = role_reln.role_id
   AND    role_reln.role_resource_type = 'RS_INDIVIDUAL'
   AND    role_reln.ROLE_RESOURCE_ID = p_res_id
   AND    delete_flag = 'N'
   AND    TRUNC(SYSDATE) BETWEEN TRUNC(role_reln.start_date_active)
   AND    TRUNC(NVL(role_reln.end_date_active,SYSDATE));

BEGIN
   OPEN isvendor_csr(p_resource_id);
      FETCH  isvendor_csr into l_temp;
   IF isvendor_csr%FOUND THEN
      is_vendor_admin:=FND_API.g_true;
   END IF;
   CLOSE isvendor_csr;

   RETURN is_vendor_admin ;

END is_vendor_admin_user;

---------------------------------------------------------------------
-- FUNCTION
--    check_lookup_exists
--
---------------------------------------------------------------------
FUNCTION check_lookup_exists(
   p_lookup_table_name  IN VARCHAR2 := g_pv_lookups,
   p_lookup_type        IN VARCHAR2,
   p_lookup_code        IN VARCHAR2
)
Return VARCHAR2
IS

   l_sql   VARCHAR2(4000);
   l_count NUMBER;

BEGIN

   l_sql := 'SELECT 1 FROM DUAL WHERE EXISTS (SELECT 1 FROM ' || p_lookup_table_name;
   l_sql := l_sql || ' WHERE LOOKUP_TYPE = :b1';
   l_sql := l_sql || ' AND LOOKUP_CODE = :b2';
   l_sql := l_sql || ' AND ENABLED_FLAG = ''Y'')';

   debug_message('SQL statement: '||l_sql);
   BEGIN
      EXECUTE IMMEDIATE l_sql INTO l_count
      USING p_lookup_type, p_lookup_code;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_count := 0;
   END;

   IF l_count = 0 THEN
      RETURN FND_API.g_false;
   ELSE
      RETURN FND_API.g_true;
   END IF;

END check_lookup_exists;


---------------------------------------------------------------------
-- FUNCTION
--    check_uniqueness
--
-- HISTORY
--   05/19/99  cklee  Created.
-- 25-Apr-2000 choang   Use bind_parse to enable use of bind variables.
---------------------------------------------------------------------
FUNCTION check_uniqueness(
   p_table_name    IN VARCHAR2,
   p_where_clause  IN VARCHAR2
)
RETURN VARCHAR2
IS

   l_sql   VARCHAR2(4000);
   l_count NUMBER;

   l_bind_tbl  col_val_tbl;

BEGIN

   l_sql := 'SELECT 1 FROM DUAL WHERE EXISTS (SELECT 1 FROM ' || UPPER(p_table_name);
--   l_sql := l_sql || ' WHERE ' || p_where_clause;

   bind_parse (p_where_clause, l_bind_tbl);

   --
   -- Support up to 4 WHERE conditions for uniqueness.  If
   -- the number of conditions changes, then must also revise
   -- the execute portion of the code.

   IF l_bind_tbl.COUNT <= 6 THEN
      l_sql := l_sql || ' WHERE ' || l_bind_tbl(1).col_name || ' ' || l_bind_tbl(1).col_op || ' :b1';
      FOR i IN 2..l_bind_tbl.COUNT LOOP
         l_sql := l_sql || ' AND ' || l_bind_tbl(i).col_name || ' ' || l_bind_tbl(i).col_op || ' :b' || i;
      END LOOP;
   ELSE
      -- Exceeded the number of conditions supported
      -- for bind variables.
      l_sql := l_sql || ' WHERE ' || p_where_clause;
   END IF;

   l_sql := l_sql || ')';

   debug_message('SQL statement: '||l_sql);
   --
   -- Modify here if number of WHERE conditions
   -- supported changes.
   BEGIN
      IF l_bind_tbl.COUNT = 1 THEN
         EXECUTE IMMEDIATE l_sql INTO l_count
         USING l_bind_tbl(1).col_value;
      ELSIF l_bind_tbl.COUNT = 2 THEN
         EXECUTE IMMEDIATE l_sql INTO l_count
         USING l_bind_tbl(1).col_value, l_bind_tbl(2).col_value;
      ELSIF l_bind_tbl.COUNT = 3 THEN
         EXECUTE IMMEDIATE l_sql INTO l_count
         USING l_bind_tbl(1).col_value, l_bind_tbl(2).col_value, l_bind_tbl(3).col_value;
      ELSIF l_bind_tbl.COUNT = 4 THEN
         EXECUTE IMMEDIATE l_sql INTO l_count
         USING l_bind_tbl(1).col_value, l_bind_tbl(2).col_value, l_bind_tbl(3).col_value, l_bind_tbl(4).col_value;
      ELSIF l_bind_tbl.COUNT = 5 THEN
         EXECUTE IMMEDIATE l_sql INTO l_count
         USING l_bind_tbl(1).col_value, l_bind_tbl(2).col_value, l_bind_tbl(3).col_value, l_bind_tbl(4).col_value, l_bind_tbl(5).col_value;
      ELSIF l_bind_tbl.COUNT = 6 THEN
         EXECUTE IMMEDIATE l_sql INTO l_count
         USING l_bind_tbl(1).col_value, l_bind_tbl(2).col_value, l_bind_tbl(3).col_value, l_bind_tbl(4).col_value, l_bind_tbl(5).col_value, l_bind_tbl(6).col_value;
      ELSE
         EXECUTE IMMEDIATE l_sql INTO l_count;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_count := 0;
   END;

   IF l_count = 0 THEN
      RETURN FND_API.g_true;
   ELSE
      RETURN FND_API.g_false;
   END IF;

END check_uniqueness;


---------------------------------------------------------------------
-- FUNCTION
--    is_Y_or_N
--
---------------------------------------------------------------------
FUNCTION is_Y_or_N(
   p_value IN VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN
   IF p_value = 'Y' or p_value = 'N' THEN
      RETURN FND_API.g_true;
   ELSE
      RETURN FND_API.g_false;
   END IF;
END is_Y_or_N;


---------------------------------------------------------------------
-- PROCEDURE
--    debug_message
--
---------------------------------------------------------------------
PROCEDURE debug_message(
   p_message_text   IN  VARCHAR2,
   p_message_level  IN  NUMBER := FND_MSG_PUB.g_msg_lvl_debug_high
)
IS
BEGIN
   IF FND_MSG_PUB.check_msg_level(p_message_level) THEN
      FND_MESSAGE.set_name('PV', 'PV_DEBUG_MESSAGE');
      FND_MESSAGE.set_token('TEXT', p_message_text);
      FND_MSG_PUB.add;
   END IF;
END debug_message;


---------------------------------------------------------------------
-- PROCEDURE
--    error_message
--
---------------------------------------------------------------------
PROCEDURE error_message(
   p_message_name VARCHAR2,
   p_token_name   VARCHAR2 := NULL,
   P_token_value  VARCHAR2 := NULL
)
IS
BEGIN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('PV', p_message_name);
      IF p_token_name IS NOT NULL THEN
         FND_MESSAGE.set_token(p_token_name, p_token_value);
      END IF;
      FND_MSG_PUB.add;
   END IF;
END error_message;


---------------------------------------------------------------------
-- PROCEDURE
--    display_messages
--
---------------------------------------------------------------------
PROCEDURE display_messages
IS
   l_count  NUMBER;
   l_msg    VARCHAR2(2000);
BEGIN
   l_count := FND_MSG_PUB.count_msg;
   FOR i IN 1 .. l_count LOOP
      l_msg := FND_MSG_PUB.get(i, FND_API.g_false);
      -- holiu: remove since adchkdrv does not like it
--      DBMS_OUTPUT.put_line('(' || i || ') ' || l_msg);
   END LOOP;
END display_messages;


PROCEDURE get_lookup_meaning (
   p_lookup_type      IN    VARCHAR2,
   p_lookup_code      IN   VARCHAR2,
   x_return_status OUT NOCOPY   VARCHAR2,
   x_meaning       OUT NOCOPY   VARCHAR2
)
IS
   CURSOR c_meaning IS
      SELECT meaning
      FROM   pv_lookups
      WHERE  lookup_type = UPPER (p_lookup_type)
      AND    lookup_code = UPPER (p_lookup_code);
BEGIN
   OPEN c_meaning;
   FETCH c_meaning INTO x_meaning;
   IF c_meaning%NOTFOUND THEN
      CLOSE c_meaning;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_meaning:=  NULL;
   ELSE
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF c_meaning%ISOPEN THEN
         CLOSE c_meaning;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_meaning :=  NULL;
END get_lookup_meaning;


---------------------------------------------------------------------
-- PROCEDURE
--    get_System_Timezone
--
-- PURPOSE
--    This procedure will return the timezone from the System Timezone profile option
---------------------------------------------------------------------
PROCEDURE get_System_Timezone(

x_return_status   OUT NOCOPY VARCHAR2,
x_sys_time_id     OUT NOCOPY NUMBER,
x_sys_time_name	  OUT NOCOPY VARCHAR2
) IS

l_sys_time_id  NUMBER;
l_sys_name   VARCHAR2(80);

cursor c_get_name(l_time_id IN NUMBER) is
select NAME
 from  FND_TIMEZONES_VL  --HZ_TIMEZONES_VL
where  UPGRADE_TZ_ID = l_time_id;
-- where TIMEZONE_ID = l_time_id;

BEGIN
	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_sys_time_id := FND_PROFILE.VALUE('AMS_SYSTEM_TIMEZONE_ID');
	OPEN c_get_name(l_sys_time_id);
	FETCH c_get_name into l_sys_name;
	IF (c_get_name%NOTFOUND) THEN
      CLOSE c_get_name;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	  return;
    END IF;
	CLOSE c_get_name;

	x_sys_time_id := l_sys_time_id;
	x_sys_time_name := l_sys_name;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		IF (c_get_name%ISOPEN) THEN
			CLOSE c_get_name;
		END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END get_System_Timezone;

---------------------------------------------------------------------
-- PROCEDURE
--    get_User_Timezone
--
-- PURPOSE
--    This procedure will return the timezone from the User Timezone profile option
---------------------------------------------------------------------
PROCEDURE get_User_Timezone(

x_return_status   OUT NOCOPY VARCHAR2,
x_user_time_id    OUT NOCOPY NUMBER,
x_user_time_name  OUT NOCOPY VARCHAR2
) IS

l_user_time_id  NUMBER;
l_user_time_name   VARCHAR2(80);

cursor get_name(l_time_id IN NUMBER) is
select NAME
 from  FND_TIMEZONES_VL   --HZ_TIMEZONES_VL
where  UPGRADE_TZ_ID = l_time_id;
-- where TIMEZONE_ID = l_time_id;

BEGIN
	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_user_time_id := FND_PROFILE.VALUE('AMS_USER_TIMEZONE_ID');
	OPEN get_name(l_user_time_id);
	FETCH get_name into l_user_time_name;
	IF (get_name%NOTFOUND) THEN
      CLOSE get_name;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	  return;
    END IF;
	CLOSE get_name;

	x_user_time_id := l_user_time_id;
	x_user_time_name := l_user_time_name;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		IF (get_name%ISOPEN) THEN
			CLOSE get_name;
		END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END get_User_Timezone;

-------------------------------------------------------------------------------------------------
-- PROCEDURE
--    Convert_Timezone
--
-- PURPOSE
--    This procedure will take the user timezone and the input time, depending on the parameter
--    p_convert_type it will convert the input time to System timezone or sent Usertimezone
---------------------------------------------------------------------------------------------------
PROCEDURE Convert_Timezone(
  p_init_msg_list       IN     VARCHAR2	:= FND_API.G_FALSE,
  x_return_status       OUT NOCOPY    VARCHAR2,
  x_msg_count           OUT NOCOPY    NUMBER,
  x_msg_data            OUT NOCOPY    VARCHAR2,

  p_user_tz_id          IN     NUMBER ,
  p_in_time             IN     DATE  ,  -- required
  p_convert_type        IN     VARCHAR2 := 'SYS' , --  (SYS/USER)

  x_out_time            OUT NOCOPY    DATE
) IS

	l_sys_time_id		NUMBER;
	l_user_tz_id		NUMBER := p_user_tz_id ;
	l_sys_time_name		VARCHAR2(80);
	l_user_time_name		VARCHAR2(80);
	l_return_status		VARCHAR2(1);  -- Return value from procedures

        l_from_timezone_id      NUMBER ;
        l_to_timezone_id        NUMBEr ;
BEGIN

	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	get_System_Timezone(
		l_return_status,
		l_sys_time_id,
		l_sys_time_name);

	IF (l_return_status = FND_API.G_RET_STS_ERROR OR
		l_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	THEN
		x_return_status := l_return_status;
		RETURN;
	END IF;

        -- If the user timezone is not sent
        -- get it from profiles
        IF l_user_tz_id IS NULL THEN
              Get_User_Timezone(
                    x_return_status    => l_return_status,
                    x_user_time_id     => l_user_tz_id ,
                    x_user_time_name   => l_user_time_name
                    ) ;
        END IF;

        IF (l_return_status = FND_API.G_RET_STS_ERROR OR
		l_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	THEN
		x_return_status := l_return_status;
		RETURN;
	END IF;

        IF p_convert_type = 'SYS' THEN
            l_from_timezone_id := l_user_tz_id ;
            l_to_timezone_id   := l_sys_time_id ;
        ELSIF p_convert_type = 'USER' THEN
            l_from_timezone_id := l_sys_time_id ;
            l_to_timezone_id   :=  l_user_tz_id ;
        END IF;

	HZ_TIMEZONE_PUB.get_time(
		   p_api_version       => 1.0,
		   p_init_msg_list     => p_init_msg_list,
		   p_source_tz_id      => l_from_timezone_id ,
		   p_dest_tz_id        => l_to_timezone_id ,
		   p_source_day_time   => p_in_time,
		   x_dest_day_time     => x_out_time,
		   x_return_status     => x_return_status,
		   x_msg_count         => x_msg_count,
		   x_msg_data          => x_msg_data
	                          );

END Convert_Timezone ;


---------------------------------------------------------------------
-- PROCEDURE
--    bind_parse
-- USAGE
--    bind_parse (varchar2, col_val_tbl);
--    The input string must have a space between the AND and operator clause
--    and it must exclude the initial WHERE/AND statement.
--    Example: pv_attr_code = 'xyz' and pv_attribute_id <> 1
---------------------------------------------------------------------
PROCEDURE bind_parse (
   p_string IN VARCHAR2,
   x_col_val_tbl OUT NOCOPY col_val_tbl)
IS
   l_new_str   VARCHAR2(4000);
   l_str       VARCHAR2(4000) := p_string;
   l_curr_pos  NUMBER;  -- the position index of the operator string
   l_eq_pos    NUMBER;
   l_not_pos   NUMBER;
   l_and_pos   NUMBER;
   i         NUMBER := 1;
BEGIN
   LOOP
      l_and_pos := INSTR (UPPER (l_str), ' AND ');
      -- handle condition where no more AND's are
      -- left -- usually if only one condition or
      -- the last condition in the WHERE clause.
      IF l_and_pos = 0 THEN
         l_new_str := l_str;
      ELSE
         l_new_str := SUBSTR (l_str, 1, l_and_pos - 1);
      END IF;

      --
      -- The operator should also be passed
      -- back to the calling program.
      l_eq_pos := INSTR (l_new_str, '=');
      l_not_pos := INSTR (l_new_str, '<>');
      --
      -----------------------------------
      -- operator    equal    not equal
      -- error       0        0
      -- =           1        0
      -- <>          0        1
      -- =           1        2
      -- <>          2        1
      -----------------------------------
      IF l_eq_pos = 0 AND l_not_pos = 0 THEN
         -- Could not find either an = or an <>
         -- operator.
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_UTIL_NO_WHERE_OPERATOR');
            FND_MSG_PUB.add;
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
      ELSIF l_eq_pos > 0 AND l_not_pos = 0 THEN
         l_curr_pos := l_eq_pos;
         x_col_val_tbl(i).col_op := '=';
      ELSIF l_not_pos > 0 AND l_eq_pos = 0 THEN
         l_curr_pos := l_not_pos;
         x_col_val_tbl(i).col_op := '<>';
      ELSIF l_eq_pos < l_not_pos THEN
         l_curr_pos := l_eq_pos;
         x_col_val_tbl(i).col_op := '=';
      ELSE
         l_curr_pos := l_not_pos;
         x_col_val_tbl(i).col_op := '<>';
      END IF;

      x_col_val_tbl(i).col_name := UPPER (LTRIM (RTRIM (SUBSTR (l_new_str, 1, l_curr_pos - 1))));
      -- Add 2 to the current position for '<>'.
      x_col_val_tbl(i).col_value := LTRIM (RTRIM (SUBSTR (l_new_str, l_curr_pos + 2)));
      --
      -- Remove the single quotes from the begin and end of the string value;
      -- no action if a numeric value.
      IF INSTR (x_col_val_tbl(i).col_value, '''', 1) = 1 THEN
         x_col_val_tbl(i).col_value := SUBSTR (x_col_val_tbl(i).col_value,2);
         x_col_val_tbl(i).col_value := SUBSTR (x_col_val_tbl(i).col_value, 1, LENGTH(x_col_val_tbl(i).col_value) - 1);
      END IF;

      IF l_and_pos = 0 THEN
         EXIT; -- no more to parse
      END IF;

      l_str := SUBSTR (l_str, l_and_pos + 4);
      i := i + 1;
   END LOOP;
END bind_parse;


---------------------------------------------------------------------
-- FUNCTION
--    get_lookup_meaning
---------------------------------------------------------------------
FUNCTION get_lookup_meaning (
   p_lookup_type IN VARCHAR2,
   p_lookup_code IN VARCHAR2
)
RETURN VARCHAR2
IS
   l_meaning   VARCHAR2(80);

   CURSOR c_meaning IS
      SELECT meaning
      FROM   pv_lookups
      WHERE  lookup_type = UPPER (p_lookup_type)
      AND    lookup_code = UPPER (p_lookup_code);
BEGIN
   OPEN c_meaning;
   FETCH c_meaning INTO l_meaning;
   CLOSE c_meaning;

   RETURN l_meaning;
END get_lookup_meaning;


---------------------------------------------------------------------
-- FUNCTION
--    get_resource_name
-- USAGE
---------------------------------------------------------------------
FUNCTION get_resource_name (
   p_resource_id IN VARCHAR2
)
RETURN VARCHAR2
IS
   l_resource_name   VARCHAR2(240);

/*   CURSOR c_resource_name IS
      SELECT full_name
      FROM   jtf_rs_res_emp_vl
      WHERE  resource_id = p_resource_id; */

--  Vanitha - Changes for performance
   CURSOR c_resource_name IS
     SELECT full_name
     FROM   jtf_rs_resource_extns rsc,
            per_all_people_f ppl
     WHERE  rsc.category  = 'EMPLOYEE'
     AND    ppl.person_id = rsc.source_id
     AND    resource_id   = p_resource_id;

BEGIN
   IF p_resource_id IS NULL THEN
      RETURN NULL;
   END IF;

   OPEN c_resource_name;
   FETCH c_resource_name INTO l_resource_name;
   CLOSE c_resource_name;

   RETURN l_resource_name;
END get_resource_name;



---------------------------------------------------------------------
-- FUNCTION
--    get_contact_account_id
--
---------------------------------------------------------------------
FUNCTION get_contact_account_id(
 p_contact_rel_party_id   IN NUMBER
)
RETURN NUMBER
IS

   l_account_id NUMBER;

   CURSOR get_primary_account(cv_contact_rel_party_id NUMBER) IS
    select b.cust_account_id
    from hz_party_preferences a, hz_cust_accounts b
    where category = 'PRIMARY_ACCOUNT'
    and a.preference_code = 'CUSTOMER_ACCOUNT_ID'
    and a.party_id = cv_contact_rel_party_id
    and b.cust_account_id=a.value_number and nvl(status,'A')='A';

   CURSOR get_account(cv_contact_rel_party_id NUMBER) IS
    select cust_account_id
    from hz_cust_accounts where cust_account_id in
    (select  cust_account_id
     from hz_cust_account_roles
     where party_id = cv_contact_rel_party_id
     and nvl(status,'A')='A'
    )
    and nvl(status,'A')='A'
    order by creation_date asc;


BEGIN
   OPEN get_primary_account(p_contact_rel_party_id);
   FETCH  get_primary_account into l_account_id;
   CLOSE get_primary_account;

   IF l_account_id IS NULL THEN

    OPEN  get_account(p_contact_rel_party_id);
    FETCH  get_account into l_account_id;
    CLOSE get_account;

   END IF;


   RETURN l_account_id;

END get_contact_account_id;


-------------------------------------------------------------------------------
-- PROCEDURE
--	create_history_log
-- DESCRIPTION
--	Creates a history log
-------------------------------------------------------------------------------
PROCEDURE create_history_log(
  p_arc_history_for_entity_code  	IN	VARCHAR2,
  p_history_for_entity_id  	      IN	NUMBER,
  p_history_category_code		      IN	VARCHAR2	DEFAULT NULL,
  p_message_code			            IN	VARCHAR2,
  p_partner_id                      IN  NUMBER,
  p_access_level_flag               IN  VARCHAR2 DEFAULT  'V',
  p_interaction_level               IN  NUMBER   DEFAULT G_INTERACTION_LEVEL_10,
  p_comments			               IN	VARCHAR2	DEFAULT NULL,
  p_log_params_tbl		            IN	PVX_UTILITY_PVT.log_params_tbl_type,
  p_init_msg_list                   IN   VARCHAR2     := Fnd_Api.G_FALSE,
  p_commit                          IN   VARCHAR2     := Fnd_Api.G_FALSE,
  x_return_status    	            OUT NOCOPY 	  VARCHAR2,
  x_msg_count                       OUT NOCOPY    NUMBER,
  x_msg_data                        OUT NOCOPY    VARCHAR2
)
IS

--PRAGMA AUTONOMOUS_TRANSACTION; commenting out by pukken as per bug no 2907727

   l_lookup_exists VARCHAR2(30);
   l_history_code  VARCHAR2(30);
   l_entity_history_log_id NUMBER;
   l_history_log_param_id NUMBER;

   x_object_version_number NUMBER := FND_API.G_MISS_NUM;
   --x1_entity_history_log_id NUMBER :=1;
   --x1_object_version_number NUMBER(9) := 1;

   CURSOR c_id IS
      SELECT PV_GE_HISTORY_LOG_B_S.NEXTVAL
      FROM dual;

   CURSOR c_message_code (cv_message_code IN VARCHAR2) IS
   SELECT 'Y'
   FROM fnd_new_messages
   WHERE message_name = cv_message_code
     AND application_id in (691, 682);

   l_exists VARCHAR2(1);
   l_lookup_type VARCHAR2(30);
   l_lookup_code VARCHAR2(30);

   CURSOR c_param_id IS
	   SELECT PV_GE_HISTORY_LOG_PARAMS_S.NEXTVAL
	   FROM dual;

BEGIN

  /*  Standard Start of API savepoint */
  SAVEPOINT history_log_sp;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

  x_return_status := FND_API.g_ret_sts_success;

  l_lookup_type := 'PV_INTERACTION_OBJECT_TYPE';--'AMS_SYS_ARC_QUALIFIER';
  l_lookup_code := p_arc_history_for_entity_code;

   -- Validate histry entity code against lookup table
  l_lookup_exists := PVX_UTILITY_PVT.check_lookup_exists( p_lookup_table_name => 'PV_LOOKUPS',
                                                          p_lookup_type => l_lookup_type,
                                                          p_lookup_code => l_lookup_code );

  IF NOT FND_API.to_boolean(l_lookup_exists) THEN
    x_return_status := FND_API.g_ret_sts_error;
    FND_MESSAGE.set_name('PV', 'PV_INVALID_LOOKUP_CODE');
    FND_MESSAGE.set_token('LOOKUP_TYPE', l_lookup_type );
    FND_MESSAGE.set_token('LOOKUP_CODE', l_lookup_code );
    FND_MSG_PUB.add;
  END IF;

  IF x_return_status = FND_API.g_ret_sts_error THEN
    RAISE FND_API.g_exc_error;
  END IF;

  l_lookup_type := 'PV_HISTORY_CATEGORY';
  l_lookup_code := p_history_category_code;

  -- Validate History Catagory Code
  l_history_code := PVX_UTILITY_PVT.check_lookup_exists( p_lookup_table_name => 'PV_LOOKUPS',
                                                         p_lookup_type => l_lookup_type,
                                                         p_lookup_code => l_lookup_code );



  IF NOT FND_API.to_boolean(l_history_code) THEN
    x_return_status := FND_API.g_ret_sts_error;
    FND_MESSAGE.set_name('PV', 'PV_INVALID_LOOKUP_CODE');
    FND_MESSAGE.set_token('LOOKUP_TYPE',l_lookup_type );
    FND_MESSAGE.set_token('LOOKUP_CODE',l_lookup_code );
    FND_MSG_PUB.add;
  END IF;

  IF x_return_status = FND_API.g_ret_sts_error THEN
    RAISE FND_API.g_exc_error;
  END IF;


  OPEN c_message_code(p_message_code);
  FETCH c_message_code INTO l_exists;
  IF c_message_code%NOTFOUND THEN
    CLOSE c_message_code;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MESSAGE.set_name('PV', 'PV_INVALID_MESSAGE_CODE');
    FND_MESSAGE.set_token('MESSAGE_CODE',p_message_code );
    FND_MSG_PUB.add;
    RAISE FND_API.g_exc_error;
  ELSE
    CLOSE c_message_code;
  END IF;


  OPEN c_id;
  FETCH c_id INTO l_entity_history_log_id;
  CLOSE c_id;

  -- Insert a row into the tables
  PV_Ge_Hist_Log_PKG.Insert_Row (
          px_entity_history_log_id      => l_entity_history_log_id,
          px_object_version_number      => x_object_version_number,
          p_arc_history_for_entity_code => p_arc_history_for_entity_code ,
          p_history_for_entity_id       => p_history_for_entity_id ,
          p_message_code                => p_message_code,
          p_history_category_code       => p_history_category_code ,
          p_partner_id                  => p_partner_id,
          p_access_level_flag           => p_access_level_flag,
          p_interaction_level           => p_interaction_level,
          p_comments                    => p_comments,
          p_created_by                  => FND_GLOBAL.USER_ID,
          p_creation_date               => SYSDATE,
          p_last_updated_by             => FND_GLOBAL.USER_ID,
          p_last_update_date            => SYSDATE,
          p_last_update_login           => NULL
	  );



  FOR i IN 1..p_log_params_tbl.count LOOP
    OPEN c_param_id;
		FETCH c_param_id INTO l_history_log_param_id;
		CLOSE c_param_id;

    PV_Ge_Hl_Param_PKG.Insert_Row (
          px_history_log_param_id    => l_history_log_param_id,
          p_entity_history_log_id   => l_entity_history_log_id,
          p_param_name               => p_log_params_tbl(i).param_name,
          px_object_version_number   => x_object_version_number,
          p_param_value              => p_log_params_tbl(i).param_value,
          p_created_by               => FND_GLOBAL.USER_ID,
          p_creation_date            => SYSDATE,
          p_last_updated_by          => FND_GLOBAL.USER_ID,
          p_last_update_date         => SYSDATE,
          p_last_update_login        => NULL,
          p_param_type               => p_log_params_tbl(i).param_type,
          p_lookup_type              => p_log_params_tbl(i).param_lookup_type
	  );

  END LOOP;



  FND_MSG_PUB.Count_And_Get
     (   p_encoded => FND_API.G_FALSE,
         p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
     );

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

EXCEPTION
  WHEN FND_API.g_exc_error THEN
    ROLLBACK TO history_log_sp;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO history_log_sp;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );
  WHEN OTHERS THEN
    ROLLBACK TO history_log_sp;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get(
          p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );
END create_history_log;

PROCEDURE get_business_days
(
    p_from_date         IN  DATE,
    p_to_date           IN  DATE,
    x_bus_days         OUT  NOCOPY NUMBER

)
IS
   CURSOR C
   IS
   select count(*)
      from ( select rownum rnum
               from sys.all_objects
              where rownum <= p_to_date - p_from_date)
     where to_char( p_from_date+rnum, 'DY' ,'nls_date_language=english')
                      not in ( 'SAT', 'SUN' );
BEGIN
    IF p_from_date = p_to_date THEN

      IF to_char(p_from_date, 'DY','nls_date_language=english') IN ('SAT','SUN')  THEN
           x_bus_days := 0;
      ELSE
           x_bus_days := 1;
      END IF;
    ELSE
      OPEN C;
      FETCH C into x_bus_days;
      CLOSE C;
    END IF;
END get_business_days;

PROCEDURE add_business_days
(
    p_no_of_days         IN  NUMBER,
    x_business_date       OUT NOCOPY DATE

)
IS
   l_no_of_wkend        number(30);
   l_date		DATE;

BEGIN

   l_Date  :=  sysdate;

    x_business_date := l_Date;

    -- If this program is run in the weekend the actual day the calculation starts will
    -- be from the following business day:  Monday,  00:00 AM

    IF to_char(l_Date, 'DY','nls_date_language=english') = 'SAT'  THEN
	x_business_date := trunc(x_business_date + 2);
    ELSIF to_char(l_Date, 'DY','nls_date_language=english') = 'SUN'  THEN
        x_business_date := trunc(x_business_date + 1);
    END IF;

     -- If interval specified is 9 or 8 , this program is run on thurdays or fridays
    -- then actual weekends will be 2 instead of one .
    IF to_char(l_Date,'DY','nls_date_language=english') IN ('THU','FRI')  THEN
        IF mod(p_no_of_days,5) = 4 OR  mod(p_no_of_days,5) = 3  THEN
            x_business_date := x_business_date+2;
        END IF;
    END IF;

   -- Now add no of business days
    x_business_date := x_business_date + p_no_of_days;

    l_no_of_wkend := trunc(p_no_of_days/5);

    -- Here the interval means the number of business days excluding weekends
    -- If the interval crosses the weekends the number of weekends will be added
    -- to the output date

    IF l_no_of_wkend <> 0 THEN
       x_business_date := x_business_date + l_no_of_wkend*2;
    END IF;

    -- If the calculated date falls on the weekend, then move it to the following business day
    IF to_char(x_business_date, 'DY','nls_date_language=english') IN ('SAT')   THEN
        x_business_date     := x_business_date + 2;
    ELSIF to_char(x_business_date, 'DY','nls_date_language=english') IN ('SUN')   THEN
        x_business_date     := x_business_date + 2;
    END IF;

END;

END PVX_Utility_PVT;

/
