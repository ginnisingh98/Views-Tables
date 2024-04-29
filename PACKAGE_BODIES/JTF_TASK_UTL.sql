--------------------------------------------------------
--  DDL for Package Body JTF_TASK_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_UTL" AS
/* $Header: jtfptklb.pls 120.8.12010000.2 2010/03/31 12:07:40 anangupt ship $ */

 /******** Start of addition by SBARAT on 29/12/2005 for bug# 4866066 ********/
   FUNCTION g_yes
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN 'Y';
   END;

   FUNCTION g_no
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN 'N';
   END;
 /******** End of addition by SBARAT on 29/12/2005 for bug# 4866066 ********/

   FUNCTION get_escalation_owner (p_task_id IN NUMBER)
      RETURN VARCHAR2
   IS
      l_owner	VARCHAR2(120);
   BEGIN
      SELECT jtf_task_utl.get_owner (esc.owner_type_code, esc.owner_id)
    INTO
	 l_owner
    FROM jtf_tasks_b esc
       WHERE task_id IN (SELECT task_id
	       FROM jtf_task_references_b
	      WHERE object_id = p_task_id
		AND object_type_code = 'TASK'
		AND reference_code = 'ESC')
     AND task_type_id = 22;
      RETURN l_owner;
   EXCEPTION
      WHEN OTHERS
      THEN
     RETURN NULL;
   END;

   FUNCTION get_escalation_level (p_task_id IN NUMBER)
      RETURN VARCHAR2
   IS
      l_meaning   VARCHAR2(30);
   BEGIN
      SELECT lookups.meaning
    INTO l_meaning
    FROM jtf_tasks_b, fnd_lookups lookups
       WHERE task_id IN (SELECT task_id
	       FROM jtf_task_references_b
	      WHERE object_id = p_task_id
		AND object_type_code = 'TASK'
		AND reference_code = 'ESC')
     AND task_type_id = 22
     AND lookups.lookup_type = 'JTF_TASK_ESC_LEVEL'
     AND lookups.lookup_code = jtf_tasks_b.escalation_level;
      RETURN l_meaning;
   EXCEPTION
      WHEN OTHERS
      THEN
     RETURN NULL;
   END;

   PROCEDURE call_internal_hook (
      p_package_name	  IN	   VARCHAR2,
      p_api_name      IN       VARCHAR2,
      p_processing_type   IN	   VARCHAR2,
      x_return_status	  OUT NOCOPY	  VARCHAR2
   )
   IS
      CURSOR c1
      IS
     SELECT hd.hook_package, hd.hook_api, fa.application_id -- Fix bug 2512087
       FROM fnd_application fa
	  , jtf_hooks_data hd
      WHERE hd.package_name = p_package_name
	AND hd.api_name = p_api_name
	AND hd.execute_flag = 'Y'
	AND hd.processing_type = p_processing_type
	and fa.application_short_name = hd.product_code
      ORDER BY execution_order;

      v_cursorid   INTEGER;
      v_blockstr   VARCHAR2(2000);
      v_dummy	   INTEGER;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      FOR i IN c1
      LOOP
     v_cursorid := DBMS_SQL.open_cursor;
     v_blockstr :=
	' begin ' || i.hook_package || '.' || i.hook_api || '(:1); end; ';
     DBMS_SQL.parse (v_cursorid, v_blockstr, DBMS_SQL.v7);
     DBMS_SQL.bind_variable (v_cursorid, ':1', x_return_status, 20);
     v_dummy := DBMS_SQL.execute (v_cursorid);
     DBMS_SQL.variable_value (v_cursorid, ':1', x_return_status);
     DBMS_SQL.close_cursor (v_cursorid);

-- check for null first
-- record the package name in the error stack
     IF x_return_status IS NULL
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_RETURN_STATUS');
	/**** Fix Bug# 2042516 *****/
	fnd_message.set_token (
	   'P_PROCEDURE',
	   i.hook_package || '.' || i.hook_api
	);
	/*-------------------------*/
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

-- return an error to indicate that the hook failed, to fix bug #2231728
-- record the package name in the error stack
     IF NOT (x_return_status = fnd_api.g_ret_sts_success)
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_HOOK_RETURN_ERROR');
	fnd_message.set_token (
	   'P_PROCEDURE',
	   i.hook_package || '.' || i.hook_api
	);
	-- Fix bug 2512087
	-- Display application_id
	fnd_message.set_token (
	   'APPL_ID',
	   i.application_id
	);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

      END LOOP;
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS
      THEN
     fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
     fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
     fnd_msg_pub.add;
     x_return_status := fnd_api.g_ret_sts_unexp_error;
   END;

   PROCEDURE validate_location_id (
      				     p_location_id	 IN         NUMBER,
      				     p_address_id	       IN         NUMBER,
					     p_task_id           IN         NUMBER,
      				     x_return_status	 OUT NOCOPY VARCHAR2
 					    )
   IS
	Cursor C_Task Is
		     Select DECODE (
                                p_address_id,
                                fnd_api.g_miss_num,
                                address_id,
                                p_address_id
                               ) address_id,
                        DECODE (
                                p_location_id,
                                fnd_api.g_miss_num,
                                location_id,
                                p_location_id
                               ) location_id
                         From JTF_TASKS_VL
                              Where Task_Id=p_task_id;
      V_task       C_Task%Rowtype;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      IF (p_location_id IS NOT NULL And p_address_id IS NOT NULL)
      THEN
          IF (p_task_id IS NOT NULL)
          THEN
             IF ((p_location_id <> fnd_api.g_miss_num AND p_address_id <> fnd_api.g_miss_num))
             THEN
                fnd_message.set_name ('JTF', 'JTF_TASK_LOCATION_VALIDATION');
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_unexp_error;

             ELSIF (p_address_id <> fnd_api.g_miss_num)
             THEN
                Open C_Task;
                Fetch C_Task into V_task;
                Close C_Task;
                IF (V_Task.Location_Id IS NOT NULL AND V_Task.Address_Id IS NOT NULL)
                THEN
                   fnd_message.set_name ('JTF', 'JTF_TASK_LOCATION_EXIST');
                   fnd_msg_pub.add;
                   x_return_status := fnd_api.g_ret_sts_unexp_error;
                END IF;

             ELSIF (p_location_id <> fnd_api.g_miss_num)
             THEN
                Open C_Task;
                Fetch C_Task into V_task;
                Close C_Task;
                IF (V_Task.Location_Id IS NOT NULL AND V_Task.Address_Id IS NOT NULL)
                THEN
                   fnd_message.set_name ('JTF', 'JTF_TASK_ADDRESS_EXIST');
                   fnd_msg_pub.add;
                   x_return_status := fnd_api.g_ret_sts_unexp_error;
                END IF;
             END IF;
          ELSE
             fnd_message.set_name ('JTF', 'JTF_TASK_LOCATION_VALIDATION');
             fnd_msg_pub.add;
             x_return_status := fnd_api.g_ret_sts_unexp_error;
          END IF;
 	END IF;
   END validate_location_id;

   FUNCTION validate_shift_construct (p_shift_construct_id IN NUMBER)
      RETURN BOOLEAN
   IS
      x   CHAR;
   BEGIN
      SELECT 1
    INTO x
    FROM jtf_cal_shift_cons_v
       WHERE shift_construct_id = p_shift_construct_id;
      RETURN TRUE;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
     RETURN FALSE;
      WHEN TOO_MANY_ROWS
      THEN
     RETURN TRUE;
      WHEN OTHERS
      THEN
     fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
     fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
     fnd_msg_pub.add;
     RETURN FALSE;
   END;

   PROCEDURE validate_distance (
      p_distance_units	 IN   NUMBER,
      p_distance_tag	 IN   VARCHAR2,
      x_return_status	 OUT NOCOPY	 VARCHAR2
   )
   IS
   BEGIN
   -- to fix bug#2401431
      x_return_status := fnd_api.g_ret_sts_success;
      IF p_distance_units IS NOT NULL
      THEN
     IF p_distance_units < 0
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_DISTANCE_UNITS');
	fnd_message.set_token ('P_DISTANCE_TAG', p_distance_tag);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
     END IF;
      END IF;
   END;

   FUNCTION validate_lookup (
      p_lookup_type    IN   VARCHAR2,
      p_lookup_code    IN   VARCHAR2,
      p_lookup_type_name   IN	VARCHAR2
      )
      RETURN BOOLEAN
   IS
      l_return_status	BOOLEAN := TRUE;
      x 	NUMBER;
   BEGIN
      SELECT 1
    INTO x
    FROM fnd_lookups
       WHERE lookup_type = p_lookup_type
     AND lookup_code = p_lookup_code;
      RETURN TRUE;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
     fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_LOOKUP');
     fnd_message.set_token ('P_LOOKUP_CODE', p_lookup_code);
     fnd_message.set_token ('P_LOOKUP_TYPE', p_lookup_type);
     fnd_msg_pub.add;
     RETURN FALSE;
      WHEN TOO_MANY_ROWS
      THEN
     RETURN TRUE;
      WHEN OTHERS
      THEN
     fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
     fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
     fnd_msg_pub.add;
     RETURN FALSE;
   END;

   PROCEDURE validate_contact_point (
      p_contact_id     IN	NUMBER,
      p_phone_id       IN	NUMBER,
      x_return_status	   OUT NOCOPY	   VARCHAR2,
      p_owner_table_name   IN	    VARCHAR2
   )
   IS
      x 	    VARCHAR2(1);
      l_contact_type_code   jtf_task_contacts.contact_type_code%TYPE;

      l_person_party_id     hz_parties.party_id%TYPE;
      l_rel_party_id	    hz_parties.party_id%TYPE;

      cursor get_party_ids (p_contact_id Number) Is
      select pc.party_id, pc.subject_party_id
      from jtf_party_all_contacts_v pc,
       jtf_task_contacts tc
      where tc.task_contact_id = p_contact_id
      and  tc.contact_id IN (pc.party_id, pc.subject_party_id);

   BEGIN

      x_return_status := fnd_api.g_ret_sts_success;

      --- for backward compatibility, the owner table name is defaulted to p_owner_table_name
      IF    p_owner_table_name = 'JTF_TASK_CONTACTS'
     OR p_owner_table_name IS NULL
      THEN
     --- for backward compatibility, the contact_type_code is assumed to be CUST.
     SELECT NVL (contact_type_code, 'CUST')
       INTO l_contact_type_code
       FROM jtf_task_contacts
      WHERE task_contact_id = p_contact_id;
      END IF;

      IF p_owner_table_name = 'JTF_TASKS_B'
      THEN
     l_contact_type_code := 'CUST';
      END IF;



      BEGIN
     IF l_contact_type_code = 'CUST'
     THEN


	IF p_owner_table_name = 'JTF_TASK_CONTACTS'
	THEN

	   open get_party_ids(p_contact_id);
	   fetch get_party_ids into l_rel_party_id ,l_person_party_id;
	   if get_party_ids%NOTFOUND then
	  close get_party_ids;
	  raise no_data_found;
	   else
	  close get_party_ids;
	   end if;

	   SELECT 1
	 INTO x
	 FROM jtf_party_cont_points_v
	 WHERE party_id in (l_rel_party_id ,l_person_party_id)
	 AND contact_point_id = p_phone_id
	 AND status = 'A'
	 AND ROWNUM < 2;
	ELSE

	   SELECT 1
	 INTO x
	 FROM jtf_party_cont_points_v
	WHERE party_id = (SELECT customer_id
		    FROM jtf_tasks_b
		   WHERE task_id = p_contact_id)
	  AND contact_point_id = p_phone_id
	  AND status = 'A'
	  AND ROWNUM < 2;

	END IF;
     ELSE
	SELECT 1
	  INTO x
	  FROM per_phones
	 WHERE parent_table = 'PER_ALL_PEOPLE_F'
	   AND parent_id = (SELECT contact_id
		  FROM jtf_task_contacts
		 WHERE task_contact_id = p_contact_id)
	   AND phone_id = p_phone_id;
     END IF;


      EXCEPTION
     WHEN NO_DATA_FOUND
     THEN
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_PHONE_ID');
	fnd_message.set_token ('P_PHONE_ID', p_phone_id);
	fnd_msg_pub.add;
     WHEN OTHERS
     THEN
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
	fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
	fnd_msg_pub.add;
      END;
   END;

   FUNCTION get_owner (p_object_type_code IN VARCHAR2, p_object_id IN NUMBER)
      RETURN VARCHAR2
   IS
      CURSOR c_references
      IS
     SELECT select_id, select_name, from_table, where_clause
       FROM jtf_objects_b
      WHERE object_code = p_object_type_code;
      --- Removed the reference from JTF_OBJECTS_VL to JT_OBJECTS_B.


      l_id_column      jtf_objects_b.select_id%TYPE;
      l_name_column    jtf_objects_b.select_name%TYPE;
      l_from_clause    jtf_objects_b.from_table%TYPE;
      l_where_clause   jtf_objects_b.where_clause%TYPE;
      l_object_code    jtf_tasks_b.source_object_type_code%TYPE
	   := p_object_type_code;
      l_object_name    VARCHAR2(2000);
      l_object_id      jtf_tasks_b.source_object_id%TYPE
	   := p_object_id;
      is_null	       BOOLEAN			:= FALSE;
      is_not_null      BOOLEAN			:= FALSE;
      sql_stmt	       VARCHAR2(2000);
   BEGIN
      OPEN c_references;
      FETCH c_references INTO l_id_column,
		  l_name_column,
		  l_from_clause,
		  l_where_clause;

      IF c_references%NOTFOUND
      THEN
     NULL;
      END IF;

     -- SELECT DECODE (l_where_clause, NULL, '	', l_where_clause || ' AND ')
     --INTO
     --	   l_where_clause
     --FROM dual;

     -- Fix for bug 2932012
     IF (l_where_clause IS NULL)
     THEN
       l_where_clause := '	';
     ELSE
       l_where_clause := l_where_clause || ' AND ';
     END IF;

     -- Added 'rownum = 1' bshih
     sql_stmt := ' SELECT ' ||
                 l_name_column ||
                 ' from ' ||
                 l_from_clause ||
                 '  where ' ||
                 l_where_clause ||
                 l_id_column ||
                 ' = :object_id and rownum = 1';

     EXECUTE IMMEDIATE sql_stmt INTO l_object_name
       USING p_object_id;
     RETURN l_object_name;
   EXCEPTION
     WHEN OTHERS
      THEN
     RETURN NULL;
   END;

   PROCEDURE validate_contact (
      p_contact_id	IN	 NUMBER,
      p_task_id 	IN	 NUMBER,
      p_contact_type_code   IN	     VARCHAR2,
      x_return_status	    OUT NOCOPY	    VARCHAR2
   )
   IS
      l_customer_id   NUMBER;
      x_return	      BOOLEAN := TRUE;
      x 	  CHAR;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      BEGIN
     IF p_contact_type_code = 'CUST'
     THEN
	BEGIN
	   SELECT 1
	 INTO x
	 FROM jtf_party_all_contacts_v contacts
	WHERE contacts.object_party_id = (SELECT customer_id
			    FROM jtf_tasks_b
			   WHERE task_id = p_task_id)
	  AND p_contact_id in (contacts.subject_party_id, contacts.party_id)
	  AND ROWNUM < 2;
	END;
     ELSE
	BEGIN
	   SELECT 1
	 INTO x
	 FROM per_people_f
	WHERE person_id = p_contact_id
	  AND SYSDATE BETWEEN
	     effective_start_date AND effective_end_date;
	END;
     END IF;
      EXCEPTION
     WHEN NO_DATA_FOUND
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_CONTACT');
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
     WHEN TOO_MANY_ROWS
     THEN
	NULL;
      END;
   END;

   PROCEDURE check_duplicate_contact (
      p_contact_id          IN           NUMBER,
      p_task_id             IN           NUMBER,
      p_contact_type_code   IN           VARCHAR2,
      p_task_contact_id     IN           NUMBER  DEFAULT NULL,
      x_return_status       OUT NOCOPY   VARCHAR2
   ) IS
       Cursor c_dup_contact IS
         Select 'Y' From JTF_TASK_CONTACTS
            Where task_id    = p_task_id
              And contact_id = p_contact_id
              And contact_type_code = p_contact_type_code
              And task_contact_id <> NVL(p_task_contact_id, -99999);

       l_dup_contact     VARCHAR2(10);

   Begin

      x_return_status := fnd_api.g_ret_sts_success;

      Open c_dup_contact;
      Fetch c_dup_contact Into l_dup_contact;
      If c_dup_contact%FOUND
      Then
         fnd_message.set_name ('JTF', 'JTF_TASK_DUPLICATE_CONTACT');
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      End If;

      Close c_dup_contact;

   End;

---------
---------   Validate Task Template Group
---------
   PROCEDURE validate_task_template_group (
      p_task_template_group_id	   IN	    NUMBER,
      p_task_template_group_name   IN	    VARCHAR2,
      x_return_status	       OUT NOCOPY      VARCHAR2,
      x_task_template_group_id	   IN OUT NOCOPY      NUMBER -- Fixed from OUT to IN OUT
   )
   IS
      CURSOR c_task_template_group_id
      IS
     SELECT task_template_group_id
       FROM jtf_task_temp_groups_b
      WHERE task_template_group_id = p_task_template_group_id
	AND trunc(NVL (end_date_active, SYSDATE)) >= trunc(SYSDATE)
	AND trunc(NVL (start_date_active, SYSDATE)) <= trunc(SYSDATE);

      CURSOR c_task_template_group_name
      IS
     SELECT task_template_group_id
       FROM jtf_task_temp_groups_vl
      WHERE template_group_name = p_task_template_group_name
	AND trunc(NVL (end_date_active, SYSDATE)) >= trunc(SYSDATE)
	AND trunc(NVL (start_date_active, SYSDATE)) <= trunc(SYSDATE);
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_task_template_group_id IS NOT NULL
      THEN
     OPEN c_task_template_group_id;
     FETCH c_task_template_group_id INTO x_task_template_group_id;

     IF c_task_template_group_id%NOTFOUND
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_TEMP_GRP_ID');
	fnd_message.set_token (
	   'JTF_TASK_INVALID_TEMP_GROUP_ID',
	   p_task_template_group_id
	);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     CLOSE c_task_template_group_id;
      ELSIF p_task_template_group_name IS NOT NULL
      THEN
     OPEN c_task_template_group_name;
     FETCH c_task_template_group_name INTO x_task_template_group_id;

     IF c_task_template_group_name%NOTFOUND
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_TEMP_GRP_NAME');
	fnd_message.set_token (
	   'JTF_TASK_INVALID_TEMP_GROUP_NAME',
	   p_task_template_group_name
	);
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     CLOSE c_task_template_group_name;
      END IF;
   END;

---------
---------   Validate Costs
---------
   PROCEDURE validate_costs (
      x_return_status	OUT NOCOPY  VARCHAR2,
      p_costs	    IN	 NUMBER,
      p_currency_code	IN   VARCHAR2
   )
   IS
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF (   p_costs IS NULL
     AND p_currency_code IS NOT NULL)
      THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_COST');
     fnd_message.set_token ('P_currency_code', p_currency_code);
     fnd_msg_pub.add;
      ELSIF (	p_costs IS NOT NULL
	AND p_currency_code IS NULL)
      THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_CURRENCY_CODE');
     fnd_message.set_token ('P_cOSTs', p_costs);
     fnd_msg_pub.add;
      ELSIF (	p_costs IS NOT NULL
	AND p_currency_code IS NOT NULL)
      THEN
     IF NOT fnd_api.to_boolean (
	   jtf_task_utl.currency_code (p_currency_code)
	)
     THEN
	x_return_status := fnd_api.g_ret_sts_unexp_error;
     END IF;
      ELSE
     NULL;
      END IF;
   END;

---------
---------   FND currencies
---------
   FUNCTION currency_code (p_currency_code IN VARCHAR2)
      RETURN VARCHAR2
   IS
      CURSOR c_jtf_currencies
      IS
     SELECT 1
       FROM fnd_currencies
      WHERE currency_code = p_currency_code;

      x      CHAR;
      l_result	 CHAR;
   BEGIN
      OPEN c_jtf_currencies;
      FETCH c_jtf_currencies INTO x;

      IF c_jtf_currencies%NOTFOUND
      THEN
     l_result := fnd_api.g_false;
     fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_CURRENCY_CODE');
     fnd_message.set_token ('P_CURRENCY_CODE', p_currency_code);
     fnd_msg_pub.add;
      ELSE
     l_result := fnd_api.g_true;
      END IF;

      CLOSE c_jtf_currencies;
      RETURN l_result;
   END;

---------------------
----- Task Object type code
---------------------
---------------------
   PROCEDURE validate_object_type (
      p_object_code    IN	VARCHAR2,
      p_object_type_name   IN	    VARCHAR2,
      p_object_type_tag    IN	    VARCHAR2,
      p_object_usage	   IN	    VARCHAR2,
      x_return_status	   OUT NOCOPY	   VARCHAR2,
      x_object_code    IN OUT NOCOPY	  VARCHAR2 -- Fixed from OUT to IN OUT
   )
   IS
      CURSOR c_object_code
      IS
     SELECT object_code
       FROM jtf_objects_b
      WHERE object_code = p_object_code
	AND trunc(NVL (end_date_active, SYSDATE)) >= trunc(SYSDATE)
	AND trunc(NVL (start_date_active, SYSDATE)) <= trunc(SYSDATE)
	AND (object_code IN
	   (SELECT object_code
	      FROM jtf_object_usages
	     WHERE object_user_code =
		  NVL (p_object_usage, object_user_code)));

      CURSOR c_object_type_name
      IS
     SELECT object_code
       FROM jtf_objects_vl
      WHERE name = p_object_type_name
	AND trunc(NVL (end_date_active, SYSDATE)) >= trunc(SYSDATE)
	AND trunc(NVL (start_date_active, SYSDATE)) <= trunc(SYSDATE)
	AND (object_code IN
	   (SELECT object_code
	      FROM jtf_object_usages
	     WHERE object_user_code =
		  NVL (p_object_usage, object_user_code)));

   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_object_code IS NOT NULL
      THEN
     OPEN c_object_code;
     FETCH c_object_code INTO x_object_code;

     IF c_object_code%NOTFOUND
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_OBJECT_CODE');
	fnd_message.set_token ('P_OBJECT_CODE', p_object_type_tag);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     CLOSE c_object_code;
      ELSIF p_object_type_name IS NOT NULL
      THEN
     OPEN c_object_type_name;
     FETCH c_object_type_name INTO x_object_code;

     IF c_object_type_name%NOTFOUND
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_OBJECT_NAME');
	fnd_message.set_token ('P_TAG_NAME', p_object_type_tag);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     CLOSE c_object_type_name;
      END IF;
   END;

------------
------------  Validate Reference codes
------------
   PROCEDURE validate_reference_codes (
      p_reference_code	 IN   VARCHAR2,
      x_return_status	 OUT NOCOPY	 VARCHAR2
   )
   IS
      CURSOR c_reference_codes
      IS
     SELECT 1
       FROM fnd_lookups
      WHERE lookup_type = 'JTF_TASK_REFERENCE_CODES'
	AND lookup_code = p_reference_code;

      x   CHAR;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_reference_code IS NOT NULL
      THEN
     OPEN c_reference_codes;
     FETCH c_reference_codes INTO x;

     IF c_reference_codes%NOTFOUND
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_REFERENCE_CODE');
	fnd_message.set_token ('P_REFERENCE_CODE', p_reference_code);
	fnd_msg_pub.add;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;
      END IF;

      CLOSE c_reference_codes;
   END;

------------
------------  Validate Assigned By
------------
   PROCEDURE validate_assigned_by (
      p_assigned_by_id	   IN	    NUMBER,
      p_assigned_by_name   IN	    VARCHAR2,
      x_return_status	   OUT NOCOPY	   VARCHAR2,
      x_assigned_by_id	   IN OUT NOCOPY      NUMBER -- Fixed from OUT to IN OUT
   )
   IS
      CURSOR c_assigned_by_id
      IS
     SELECT user_id assigned_by_id
       FROM fnd_user
      WHERE user_id = p_assigned_by_id
	AND NVL (end_date, SYSDATE) >= SYSDATE
	AND NVL (start_date, SYSDATE) <= SYSDATE;

      CURSOR c_assigned_by_name
      IS
     SELECT user_id assigned_by_id
       FROM fnd_user
      WHERE user_name = p_assigned_by_name
	AND NVL (end_date, SYSDATE) >= SYSDATE
	AND NVL (start_date, SYSDATE) <= SYSDATE;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_assigned_by_id IS NOT NULL
      THEN
     OPEN c_assigned_by_id;
     FETCH c_assigned_by_id INTO x_assigned_by_id;

     IF c_assigned_by_id%NOTFOUND
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_ASSIGNED_ID');
	fnd_message.set_token ('P_ASSIGNED_BY_ID', p_assigned_by_id);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     CLOSE c_assigned_by_id;
      ELSIF p_assigned_by_name IS NOT NULL
      THEN
     OPEN c_assigned_by_name;
     FETCH c_assigned_by_name INTO x_assigned_by_id;

     IF c_assigned_by_name%NOTFOUND
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_ASSIGNED_NAME');
	fnd_message.set_token ('P_ASSIGNED_BY_NAME', p_assigned_by_name);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     CLOSE c_assigned_by_name;
      END IF;
   END;

------------
------------
------------
   FUNCTION validate_dependency_id (p_dependency_id IN NUMBER)
      RETURN BOOLEAN
   IS
      CURSOR c_dependency
      IS
     SELECT 1
       FROM jtf_task_depends
      WHERE dependency_id = p_dependency_id;

      x   CHAR;
   BEGIN
      OPEN c_dependency;
      FETCH c_dependency INTO x;

      IF c_dependency%NOTFOUND
      THEN
     fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_DEPENDS_ID');
     fnd_message.set_token (
	'JTF_TASK_INVALID_DEPENDS_ID',
	p_dependency_id
     );
     fnd_msg_pub.add;
     CLOSE c_dependency;
     RETURN FALSE;
      ELSE
     CLOSE c_dependency;
     RETURN TRUE;
      END IF;
   END;

   FUNCTION to_boolean (x VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      IF x = jtf_task_utl.g_yes
      THEN
     RETURN TRUE;
      ELSIF x = jtf_task_utl.g_no
      THEN
     RETURN FALSE;
      ELSE
     RETURN NULL;
      END IF;
   END;

   -- Fix For Bug 2932012
   FUNCTION created_by
      RETURN NUMBER
   IS
   BEGIN
      RETURN fnd_global.user_id;
   END;

   -- Fix For Bug 2932012
   FUNCTION updated_by
      RETURN NUMBER
   IS
   BEGIN
      RETURN fnd_global.user_id;
   END;

   -- Fix For Bug 2932012
   FUNCTION login_id
      RETURN NUMBER
   IS
   BEGIN
      RETURN fnd_global.login_id;
   END;

   FUNCTION get_task_template_group (p_task_template_id IN NUMBER)
      RETURN NUMBER
   IS
      CURSOR c_task_template_group
      IS
     SELECT task_template_group_id
       FROM jtf_task_temp_groups_b
      WHERE task_template_group_id =
	   (SELECT task_group_id
	      FROM jtf_task_templates_b
	     WHERE task_template_id = p_task_template_id);

      l_task_template_group_id	 jtf_task_temp_groups_b.task_template_group_id%TYPE;
   BEGIN
      OPEN c_task_template_group;
      FETCH c_task_template_group INTO l_task_template_group_id;

      IF    c_task_template_group%NOTFOUND
     OR l_task_template_group_id IS NULL
      THEN
     IF c_task_template_group%NOTFOUND
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_TEMP_GRP_ID');
	fnd_message.set_token (
	   'P_TASK_TEMPLATE_GROUP_ID',
	   l_task_template_group_id
	);
	fnd_msg_pub.add;
	CLOSE c_task_template_group;
     END IF;

     RAISE fnd_api.g_exc_unexpected_error;
      ELSE
     CLOSE c_task_template_group;
     RETURN l_task_template_group_id;
      END IF;
   END;

------------
------------
------------
   PROCEDURE validate_dates (
      p_date_tag    IN	 VARCHAR2,
      p_start_date  IN	 DATE,
      p_end_date    IN	 DATE,
      x_return_status	OUT NOCOPY  VARCHAR2
   )
   IS
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF     (p_start_date IS NOT NULL)
     AND (p_end_date IS NOT NULL)
      THEN
     IF p_start_date > p_end_date
     THEN
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_DATES');
	fnd_message.set_token ('P_DATE_TAG', p_date_tag);
	fnd_msg_pub.add;
     END IF;
      END IF;
   END;

------------
------------
------------
   PROCEDURE validate_flag (
      p_api_name    IN	 VARCHAR2,
      p_init_msg_list	IN   VARCHAR2,
      x_return_status	OUT NOCOPY  VARCHAR2,
      p_flag_name   IN	 VARCHAR2,
      p_flag_value  IN	 VARCHAR2
   )
   IS
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT (	p_flag_value IN (jtf_task_utl.g_yes, jtf_task_utl.g_no)
	 OR p_flag_value IS NULL)
      THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_FLAG');
     fnd_message.set_token ('P_FLAG_NAME', p_flag_name);
     fnd_msg_pub.add;
      END IF;
   END;

   PROCEDURE get_object_details (
      p_task_id 	 IN	  NUMBER,
      p_template_flag	     IN       VARCHAR2,
      x_return_status	     OUT NOCOPY      VARCHAR2,
      x_source_object_code   OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR c_task_object_details
      IS
     SELECT source_object_type_code
       FROM jtf_tasks_b
      WHERE task_id = p_task_id;

      CURSOR c_template_object_details
      IS
     SELECT source_object_type_code
       FROM jtf_task_temp_groups_b
      WHERE task_template_group_id = (SELECT task_group_id
			FROM jtf_task_templates_b
		       WHERE task_template_id = p_task_id);
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_template_flag = jtf_task_utl.g_yes
      THEN
     OPEN c_template_object_details;
     FETCH c_template_object_details INTO x_source_object_code;

     IF c_template_object_details%NOTFOUND
     THEN
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_TEMP_ID');
	fnd_message.set_token ('P_TASK_TEMPLATE_ID', p_task_id);
	fnd_msg_pub.add;
     END IF;
      ELSE
     OPEN c_task_object_details;
     FETCH c_task_object_details INTO x_source_object_code;

     IF c_task_object_details%NOTFOUND
     THEN
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_TASK_ID');
	fnd_message.set_token ('P_TASK_ID', p_task_id);
	fnd_msg_pub.add;
     END IF;
      END IF;
   END;

-----------
----------- Validate Party Site/Addres
-----------
   PROCEDURE validate_party_site (
      p_party_site_id	    IN	     NUMBER,
      p_party_site_number   IN	     VARCHAR2,
      x_return_status	    OUT NOCOPY	    VARCHAR2,
      x_party_site_id	    IN OUT NOCOPY      NUMBER -- Fixed from OUT to IN OUT
   )
   IS
      CURSOR c_party_site_id
      IS
     SELECT party_site_id
       FROM hz_party_sites
      WHERE party_site_id = p_party_site_id;

      CURSOR c_party_site_number
      IS
     SELECT party_site_id
       FROM hz_party_sites
      WHERE party_site_number = p_party_site_number;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_party_site_id IS NOT NULL
      THEN
     OPEN c_party_site_id;
     FETCH c_party_site_id INTO x_party_site_id;

     IF c_party_site_id%NOTFOUND
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_SITE_ID');
	fnd_message.set_token ('P_PARTY_SITE_ID', p_party_site_id);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     CLOSE c_party_site_id;
      ELSIF p_party_site_number IS NOT NULL
      THEN
     OPEN c_party_site_number;
     FETCH c_party_site_number INTO x_party_site_id;

     IF c_party_site_number%NOTFOUND
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_SITE_NUMBER');
	fnd_message.set_token ('P_PARTY_SITE_NUMBER', p_party_site_number);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     CLOSE c_party_site_number;
      END IF;
   END;

-----------
----------- Validate Party/Customer
-----------
   PROCEDURE validate_party (
      p_party_id    IN	 NUMBER,
      p_party_number	IN   VARCHAR2,
      x_return_status	OUT NOCOPY  VARCHAR2,
      x_party_id    IN OUT NOCOPY  NUMBER -- Fixed from OUT to IN OUT
   )
   IS
      CURSOR c_party_id
      IS
     SELECT party_id
       FROM hz_parties
      WHERE party_id = p_party_id;

      CURSOR c_party_number
      IS
     SELECT party_id
       FROM hz_parties
      WHERE party_number = p_party_number;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_party_id IS NOT NULL
      THEN
     OPEN c_party_id;
     FETCH c_party_id INTO x_party_id;

     IF c_party_id%NOTFOUND
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_PARTY_ID');
	fnd_message.set_token ('P_PARTY_ID', p_party_id);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     CLOSE c_party_id;
      ELSIF p_party_number IS NOT NULL
      THEN
     OPEN c_party_number;
     FETCH c_party_number INTO x_party_id;

     IF c_party_number%NOTFOUND
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_PARTY_NUMBER');
	fnd_message.set_token (
	   'PARTY_NUMBER', -- Bug# 2120668
	   p_party_number
	);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     CLOSE c_party_number;
      END IF;
   END;

-----------
-----------  Validate customer Account
-----------
   PROCEDURE validate_cust_account (
      p_cust_account_id       IN       NUMBER,
      p_cust_account_number   IN       VARCHAR2,
      x_return_status	      OUT NOCOPY      VARCHAR2,
      x_cust_account_id       IN OUT NOCOPY	 NUMBER -- Fixed from OUT to IN OUT
   )
   IS
      CURSOR c_cust_account_id
      IS
     SELECT cust_account_id
       FROM hz_cust_accounts
      WHERE cust_account_id = p_cust_account_id;

      CURSOR c_cust_account_number
      IS
     SELECT cust_account_id
       FROM hz_cust_accounts
      WHERE account_number = p_cust_account_number;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_cust_account_id IS NOT NULL
      THEN
     OPEN c_cust_account_id;
     FETCH c_cust_account_id INTO x_cust_account_id;

     IF c_cust_account_id%NOTFOUND
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_CUST_ACCT_ID');
	fnd_message.set_token ('P_CUST_ACCOUNT_ID', p_cust_account_id);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     CLOSE c_cust_account_id;
      ELSIF p_cust_account_number IS NOT NULL
      THEN
     OPEN c_cust_account_number;
     FETCH c_cust_account_number INTO x_cust_account_id;

     IF c_cust_account_number%NOTFOUND
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_CUST_ACCT_NUM'); -- Bug# 2120231
	fnd_message.set_token ('P_CUST_ACCOUNT_NUMBER', p_cust_account_number);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     CLOSE c_cust_account_number;
      END IF;
   END;

-----------
-----------  Validate customer info.
-----------
   PROCEDURE validate_customer_info (
      p_cust_account_number   IN       VARCHAR2,
      p_cust_account_id       IN       NUMBER,
      p_customer_number       IN       VARCHAR2,
      p_customer_id	  IN	   NUMBER,
      p_address_id	  IN	   NUMBER,
      p_address_number	      IN       VARCHAR2,
      x_return_status	      OUT NOCOPY      VARCHAR2,
      x_cust_account_id      IN OUT NOCOPY	NUMBER, -- Fixed from OUT to IN OUT
      x_customer_id	  IN OUT NOCOPY      NUMBER, -- Fixed from OUT to IN OUT
      x_address_id	  IN OUT NOCOPY      NUMBER -- Fixed from OUT to IN OUT
   )
   IS
   BEGIN
      jtf_task_utl.validate_cust_account (
     p_cust_account_id => p_cust_account_id,
     p_cust_account_number => p_cust_account_number,
     x_return_status => x_return_status,
     x_cust_account_id => x_cust_account_id
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      jtf_task_utl.validate_party (
     p_party_id => p_customer_id,
     p_party_number => p_customer_number,
     x_return_status => x_return_status,
     x_party_id => x_customer_id
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      jtf_task_utl.validate_party_site (
     p_party_site_id => p_address_id,
     p_party_site_number => p_address_number,
     x_return_status => x_return_status,
     x_party_site_id => x_address_id
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     RAISE fnd_api.g_exc_unexpected_error;
      END IF;
/*  removing fix for bug #1628560
      ----
      ----  Cross-validate customer/address/account
      ----
      jtf_task_utl.validate_party_site_acct (
     p_party_id => p_customer_id,
     p_party_site_id => p_address_id,
     p_cust_account_id => p_cust_account_id,
     x_return_status => x_return_status
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     RAISE fnd_api.g_exc_unexpected_error;
      END IF;
*/

   END;

-----------
-----------  Validate Source Object Details
-----------
   PROCEDURE validate_source_object (
      p_object_code IN	 VARCHAR2,
      p_object_id   IN	 NUMBER,
      p_tag	IN   VARCHAR2,
      p_object_name IN	 VARCHAR2,
      x_return_status	OUT NOCOPY  VARCHAR2
   )
   IS
      CURSOR c_references
      IS
      SELECT select_id, select_name, from_table, where_clause
        FROM jtf_objects_b
      WHERE object_code = p_object_code
	AND object_code IN (SELECT object_code
		  FROM jtf_object_usages
		 WHERE object_user_code = 'TASK');


      l_id_column      jtf_objects_b.select_id%TYPE;
      l_name_column    jtf_objects_b.select_name%TYPE;
      l_from_clause    jtf_objects_b.from_table%TYPE;
      l_where_clause   jtf_objects_b.where_clause%TYPE;
      l_object_code    jtf_tasks_b.source_object_type_code%TYPE
	   := p_object_code;
    --Fix bug 2430516, when EXECUTE IMMEDIATE sql_stmt below, the length of
    --l_object_name could exceed 80 chars
    --l_object_name    jtf_tasks_b.source_object_name%TYPE
      l_object_name    VARCHAR2(2000)
	   := p_object_name;
      l_object_id      jtf_tasks_b.source_object_id%TYPE
	   := p_object_id;
      /************* Comment out (Bug 2118130) *****************************
      --is_null      BOOLEAN		      := FALSE;
      --is_not_null  BOOLEAN		      := FALSE;
      *********************************************************************/
      sql_stmt     VARCHAR2(2000);
      x            NUMBER;
      l_tag        VARCHAR2(2000);
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      /************* Comment out (Bug 2118130) *****************************
      --IF (  l_object_code IS NULL
      --   OR l_object_name IS NULL
      --   OR l_object_id IS NULL)
      --THEN
      --   is_null := TRUE;
      --END IF;
      --
      --IF (  l_object_code IS NOT NULL
      --   OR l_object_name IS NOT NULL
      --   OR l_object_id IS NOT NULL)
      --THEN
      --   is_not_null := TRUE;
      --END IF;
      --
      --IF     is_null
      --   AND is_not_null
      --THEN
      *********************************************************************/

      /**** Make the statement clear (Bug 2118130) ***********************/
      /** Fixing Bug 2602732 **/
      IF ( l_object_code IS NULL AND
       l_object_name IS NULL AND
       l_object_id   IS NULL)
      THEN
     return;
      ELSIF NOT ( l_object_code IS NOT NULL AND
		  l_object_id	IS NOT NULL)
      THEN
     fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_SOURCE_DTLS');
     fnd_msg_pub.add;
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      /**** Make the statement clear (Bug 2118130) ***********************/

      /************* Comment out (Bug 2118130) *****************************
      --IF is_null
      --THEN
      --   RETURN;
      --END IF;
      *********************************************************************/

      OPEN c_references;
      FETCH c_references INTO l_id_column,
		  l_name_column,
		  l_from_clause,
		  l_where_clause;

      IF c_references%NOTFOUND
      THEN
     fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_OBJECT_CODE');
     -- Bug 3418166 message token is null if p_tag is not passed in.
     -- Added message token to ensure that message token has accurate data.
     IF p_tag IS NOT NULL THEN
        l_tag := p_tag;
     ELSIF p_object_name IS NOT NULL THEN
        l_tag := p_object_name;
     ELSIF p_object_code IS NOT NULL THEN
        l_tag := p_object_code;
     ELSIF p_object_id IS NOT NULL THEN
        l_tag := p_object_id;
     END IF;

     fnd_message.set_token ('P_OBJECT_CODE', l_tag);
     fnd_msg_pub.add;
     RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      /************* Comment out (Bug 2118130) *****************************
      --IF    p_object_name IS NULL
      --   OR p_object_id IS NULL
      --THEN
      --   fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_SOURCE_DTLS');
      --   fnd_msg_pub.add;
      --   RAISE fnd_api.g_exc_unexpected_error;
      --END IF;
      *********************************************************************/

   --	SELECT DECODE (
   --	  l_where_clause,
   --	  NULL, ' where ',
   --	  ' where ' || l_where_clause || ' AND '
   --	   )
   -- INTO
   --	   l_where_clause
   -- FROM dual;

    -- Fix for bug 2932012
	IF (l_where_clause IS NULL)
	THEN
	   l_where_clause := ' where ';
	ELSE
	   l_where_clause := ' where ' || l_where_clause || ' AND ';
	END IF;

      -- Added 'rownum = 1' bshih
      sql_stmt := ' SELECT ' ||
	  l_name_column ||
	  ' , ' ||
	  l_id_column ||
	  ' from ' ||
	  l_from_clause ||
	  l_where_clause ||
	  l_id_column ||
	  ' = :object_id and rownum = 1';

      EXECUTE IMMEDIATE sql_stmt INTO l_object_name, l_object_id
      USING p_object_id;

-- fix bug #2180381
-- fix bug# 2602732
-- removing the validation for p_object_name
   IF (l_object_id <> p_object_id)
      THEN
      fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_SOURCE_DTLS');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN NO_DATA_FOUND
      THEN
     fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_SOURCE_DTLS');
     fnd_msg_pub.add;
     x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS
      THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
     fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
     fnd_msg_pub.add;
   END;

-----------
-----------  Validate Task
-----------
   PROCEDURE validate_task (
      x_return_status	OUT NOCOPY  VARCHAR2,
      p_task_id     IN	 NUMBER,
      p_task_number IN	 VARCHAR2,
      x_task_id     IN OUT NOCOPY  NUMBER -- Fixed from OUT to IN OUT
   )
   IS
      CURSOR c_task_id
      IS
     SELECT task_id
       FROM jtf_tasks_b
      WHERE task_id = p_task_id;

      CURSOR c_task_number
      IS
     SELECT task_id
       FROM jtf_tasks_b
      WHERE task_number = p_task_number;

      l_task_id       jtf_tasks_b.task_id%TYPE;
      l_task_number   jtf_tasks_b.task_number%TYPE;
      l_task_name     jtf_tasks_vl.task_name%TYPE;
      done	  BOOLEAN	       := FALSE;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      --- Assume correct task id is supplied
      IF p_task_id IS NOT NULL
      THEN
     OPEN c_task_id;
     FETCH c_task_id INTO l_task_id;

     IF c_task_id%NOTFOUND
     THEN
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_TASK_ID');
	fnd_message.set_token ('P_TASK_ID', p_task_id);
	fnd_msg_pub.add;
     END IF;
      ELSIF   --- if the task id is null, then ignore
	(p_task_number IS NOT NULL)
      THEN
     OPEN c_task_number;
     FETCH c_task_number INTO l_task_id;

     IF c_task_number%NOTFOUND
     THEN
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_TASK_NUMBER');
	fnd_message.set_token ('P_TASK_NUMBER', p_task_number);
	fnd_msg_pub.add;
     END IF;
      END IF;

      x_task_id := l_task_id;
   END;

   PROCEDURE validate_task_template (
      x_return_status	OUT NOCOPY  VARCHAR2,
      p_task_id     IN	 NUMBER,
      p_task_number IN	 VARCHAR2,
      x_task_id     IN OUT NOCOPY  NUMBER -- Fixed from OUT to IN OUT
   )
   IS
      CURSOR c_task_id
      IS
     SELECT task_template_id task_id
       FROM jtf_task_templates_b
      WHERE task_template_id = p_task_id;

      CURSOR c_task_number
      IS
     SELECT task_template_id task_id
       FROM jtf_task_templates_b
      WHERE task_number = p_task_number;

      l_task_id       jtf_tasks_b.task_id%TYPE;
      l_task_number   jtf_tasks_b.task_number%TYPE;
      l_task_name     jtf_tasks_vl.task_name%TYPE;
      done	  BOOLEAN	       := FALSE;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      --- Assume correct task id is supplied
      IF p_task_id IS NOT NULL
      THEN
     OPEN c_task_id;
     FETCH c_task_id INTO l_task_id;

     IF c_task_id%NOTFOUND
     THEN
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_TEMP_ID');
	fnd_message.set_token ('P_TASK_TEMPLATE_ID', p_task_id);
	fnd_msg_pub.add;
     END IF;
      ELSIF   --- if the task id is null, then ignore
	(p_task_number IS NOT NULL)
      THEN
     OPEN c_task_number;
     FETCH c_task_number INTO l_task_id;

     IF c_task_number%NOTFOUND
     THEN
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_TEMP_NUMBER');
	fnd_message.set_token ('P_TASK_TEMPLATE_NUMBER', p_task_number);
	fnd_msg_pub.add;
     END IF;
      END IF;

      x_task_id := l_task_id;
   END;

------------
------------
------------
   FUNCTION validate_dependency_code (p_dependency_code IN VARCHAR2)
      RETURN BOOLEAN
   IS
      CURSOR c_dependency_type_code
      IS
     SELECT 1
       FROM fnd_lookup_values
      WHERE lookup_type = 'JTF_TASK_DEPENDENCY_TYPES'
	AND lookup_code = p_dependency_code;

      x      CHAR;
      l_result	 BOOLEAN;
   BEGIN
      OPEN c_dependency_type_code;
      FETCH c_dependency_type_code INTO x;

      IF c_dependency_type_code%NOTFOUND
      THEN
     fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_DEPENDS_CODE');
     fnd_message.set_token ('P_DEPENDENCY_CODE', p_dependency_code);
     fnd_msg_pub.add;
     l_result := FALSE;
      ELSE
     l_result := TRUE;
      END IF;

      CLOSE c_dependency_type_code;
      RETURN l_result;
   END;

   FUNCTION validate_time_uom (p_uom_code IN VARCHAR2)
      RETURN VARCHAR2
   IS
      CURSOR c_jtf_uom
      IS
     SELECT 1
       FROM mtl_units_of_measure
      WHERE uom_class = g_uom_time_class
	AND uom_code = p_uom_code;

      x      CHAR;
      l_result	 CHAR;
   BEGIN
      OPEN c_jtf_uom;
      FETCH c_jtf_uom INTO x;

      IF c_jtf_uom%NOTFOUND
      THEN
     l_result := fnd_api.g_false;
      ELSE
     l_result := fnd_api.g_true;
      END IF;

      CLOSE c_jtf_uom;
      RETURN l_result;
   END;

---------
---------  Validate effort
---------
   PROCEDURE validate_effort (
      p_api_name    IN	 VARCHAR2,
      p_init_msg_list	IN   VARCHAR2,
      p_tag	IN   VARCHAR2,
      p_tag_uom     IN	 VARCHAR2,
      x_return_status	OUT NOCOPY  VARCHAR2,
      p_effort	    IN	 NUMBER,
      p_effort_uom  IN	 VARCHAR2
   )
   IS
      l_effort number;
      l_effort_uom varchar2(3);
   BEGIN
     x_return_status := fnd_api.g_ret_sts_success;

     if (p_effort = fnd_api.g_miss_num)
     then
       l_effort := null;
     else
       l_effort := p_effort;
     end if;

     if (p_effort_uom = fnd_api.g_miss_char)
     then
       l_effort_uom := null;
     else
       l_effort_uom := p_effort_uom;
     end if;

     IF (l_effort IS NULL AND l_effort_uom IS NOT NULL)
     THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_QUANTITY');
       fnd_message.set_token ('P_TAG', p_tag);
       fnd_msg_pub.add;
     ELSIF (l_effort IS NOT NULL AND l_effort_uom IS NULL)
     THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_UOM');
       fnd_message.set_token ('P_TAG', p_tag);
       fnd_msg_pub.add;
     ELSIF (l_effort IS NOT NULL AND l_effort_uom IS NOT NULL)
     THEN
       IF l_effort < g_minimum_effort
       THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_QUANTITY');
         fnd_message.set_token ('P_TAG', p_tag);
         fnd_msg_pub.add;
       END IF;

       IF NOT fnd_api.to_boolean (jtf_task_utl.validate_time_uom(l_effort_uom))
       THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_UOM');
         fnd_message.set_token ('P_UOM_CODE', l_effort_uom); -- Fix Bug 2118718
         fnd_msg_pub.add;
        END IF;
      ELSE
        NULL;
      END IF;
   END;

---------------------
----- Task Type
---------------------
---------------------
   PROCEDURE validate_task_type (
      p_task_type_id	 IN   NUMBER,
      p_task_type_name	 IN   VARCHAR2,
      x_return_status	 OUT NOCOPY	 VARCHAR2,
      x_task_type_id	 IN OUT NOCOPY	    NUMBER -- Fixed from OUT to IN OUT
   )
   IS
      CURSOR c_task_type_id
      IS
     SELECT task_type_id
       FROM jtf_task_types_b
      WHERE task_type_id = p_task_type_id
	AND trunc(NVL (end_date_active, SYSDATE)) >= trunc(SYSDATE)
	AND trunc(NVL (start_date_active, SYSDATE)) <= trunc(SYSDATE);

      CURSOR c_task_type_name
      IS
     SELECT task_type_id
       FROM jtf_task_types_vl
      WHERE name = p_task_type_name
	AND trunc(NVL (end_date_active, SYSDATE)) >= trunc(SYSDATE)
	AND trunc(NVL (start_date_active, SYSDATE)) <= trunc(SYSDATE);
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_task_type_id IS NOT NULL
      THEN
     OPEN c_task_type_id;
     FETCH c_task_type_id INTO x_task_type_id;

     IF c_task_type_id%NOTFOUND
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_TYPE_ID');
	fnd_message.set_token ('P_TASK_TYPE_ID', p_task_type_id);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
     END IF;

     CLOSE c_task_type_id;
      ELSIF p_task_type_name IS NOT NULL
      THEN
     OPEN c_task_type_name;
     FETCH c_task_type_name INTO x_task_type_id;

     IF c_task_type_name%NOTFOUND
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_TYPE_NAME');
	fnd_message.set_token ('P_TASK_TYPE_NAME', p_task_type_name);
	fnd_msg_pub.add;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     CLOSE c_task_type_name;
      END IF;
   END;

---------------------
----- Task status
---------------------
---------------------
   PROCEDURE validate_task_status (
      p_task_status_id	   IN	    NUMBER,
      p_task_status_name   IN	    VARCHAR2,
      p_validation_type    IN	    VARCHAR2,
      x_return_status	   OUT NOCOPY	   VARCHAR2,
      x_task_status_id	   IN OUT NOCOPY      NUMBER -- Fixed from OUT to IN OUT
   )
   IS
      CURSOR c_task_status_id
      IS
     SELECT task_status_id
       FROM jtf_task_statuses_b
      WHERE task_status_id = p_task_status_id
	AND trunc(NVL (end_date_active, SYSDATE)) >= trunc(SYSDATE)
	AND trunc(NVL (start_date_active, SYSDATE)) <= trunc(SYSDATE);

      CURSOR c_task_status_name
      IS
     SELECT task_status_id
       FROM jtf_task_statuses_vl
      WHERE name = p_task_status_name
	AND trunc(NVL (end_date_active, SYSDATE)) >= trunc(SYSDATE)
	AND trunc(NVL (start_date_active, SYSDATE)) <= trunc(SYSDATE);

      l_type	    varchar2(10);

   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_task_status_id IS NOT NULL
      THEN
     OPEN c_task_status_id;
     FETCH c_task_status_id INTO x_task_status_id;

     IF c_task_status_id%NOTFOUND
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_STATUS_ID');
	fnd_message.set_token ('P_TASK_STATUS_ID', p_task_status_id);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     CLOSE c_task_status_id;
      ELSIF p_task_status_name IS NOT NULL
      THEN
     OPEN c_task_status_name;
     FETCH c_task_status_name INTO x_task_status_id;

     IF c_task_status_name%NOTFOUND
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_STATUS_NAME');
	fnd_message.set_token ('P_TASK_STATUS_NAME', p_task_status_name);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     CLOSE c_task_status_name;
      END IF;

   ---
   --- call new procedure to validate the status, to fix bug #1878669
   ---
      jtf_task_utl.validate_status (
     p_status_id     => x_task_status_id,
     p_type	 => p_validation_type,
     x_return_status => x_return_status);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   END;

---------------------
----- Task priority
---------------------
---------------------
   PROCEDURE validate_task_priority (
      p_task_priority_id     IN       NUMBER,
      p_task_priority_name   IN       VARCHAR2,
      x_return_status	     OUT NOCOPY      VARCHAR2,
      x_task_priority_id     IN OUT NOCOPY	NUMBER -- Fixed from OUT to IN OUT
   )
   IS
      CURSOR c_task_priority_id
      IS
     SELECT task_priority_id
       FROM jtf_task_priorities_b
      WHERE task_priority_id = p_task_priority_id
	AND trunc(NVL (end_date_active, SYSDATE)) >= trunc(SYSDATE)
	AND trunc(NVL (start_date_active, SYSDATE)) <= trunc(SYSDATE);

      CURSOR c_task_priority_name
      IS
     SELECT task_priority_id
       FROM jtf_task_priorities_vl
      WHERE name = p_task_priority_name
	AND trunc(NVL (end_date_active, SYSDATE)) >= trunc(SYSDATE)
	AND trunc(NVL (start_date_active, SYSDATE)) <= trunc(SYSDATE);
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      -- Bug Fix 2865490
      IF (p_task_priority_id IS NOT NULL) AND (p_task_priority_id <> fnd_api.g_miss_num)
      THEN
     OPEN c_task_priority_id;
     FETCH c_task_priority_id INTO x_task_priority_id;

     IF c_task_priority_id%NOTFOUND
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_PRIORITY_ID');
	fnd_message.set_token ('P_TASK_PRIORITY_ID', p_task_priority_id);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     CLOSE c_task_priority_id;
      -- Bug Fix 2865490
      ELSE IF (p_task_priority_name IS NOT NULL) AND (p_task_priority_name <> fnd_api.g_miss_char)
      THEN
     OPEN c_task_priority_name;
     FETCH c_task_priority_name INTO x_task_priority_id;

     IF c_task_priority_name%NOTFOUND
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_PRIORITY_NAME');
	fnd_message.set_token (
	   'P_TASK_PRIORITY_NAME',
	   p_task_priority_name
	);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     CLOSE c_task_priority_name;
      ELSE
	  --Enhn 2496234 task priority should be defaulted to  Unprioritized
	  x_task_priority_id := 8;
      END IF;
      END IF;
   END;

--------------
-------------- Date Types
--------------
   PROCEDURE validate_date_types (
      p_date_type_id	IN   NUMBER,
      p_date_type   IN	 VARCHAR2,
      x_return_status	OUT NOCOPY  VARCHAR2,
      x_date_type_id	IN OUT NOCOPY  NUMBER -- Fixed from OUT to IN OUT
   )
   IS
      CURSOR c_date_type_id
      IS
     SELECT date_type_id
       FROM jtf_task_date_types_b
      WHERE date_type_id = p_date_type_id;

      CURSOR c_date_type_name
      IS
     SELECT date_type_id
       FROM jtf_task_date_types_vl
      WHERE date_type = p_date_type;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_date_type_id IS NOT NULL
      THEN
     OPEN c_date_type_id;
     FETCH c_date_type_id INTO x_date_type_id;

     IF c_date_type_id%NOTFOUND
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_DATE_TYPE_ID');
	fnd_message.set_token ('P_DATE_TYPE_ID', p_date_type_id);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
     END IF;

     CLOSE c_date_type_id;
      ELSIF p_date_type IS NOT NULL
      THEN
     OPEN c_date_type_name;
     FETCH c_date_type_name INTO x_date_type_id;

     IF c_date_type_name%NOTFOUND
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_DATE_TYPE_NAME');
	fnd_message.set_token ('P_DATE_TYPE', p_date_type);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
     END IF;

     CLOSE c_date_type_name;
      END IF;
   END;

--------------
--------------
--------------
-- Commented out this procedure by SBARAT on 19/01/2006 for bug# 4888496.
-- Since validate_escalation has already been commented out and validate_territory
-- is not being referred from any other place. Unnecessarily, the query of c_terr_name
-- comes in SQL Repository's violation list for Full Table Scan
--
   /*PROCEDURE validate_territory (
      p_terr_id     IN	 NUMBER,
      p_terr_name   IN	 VARCHAR2,
      x_return_status	OUT NOCOPY  VARCHAR2,
      x_terr_id     OUT NOCOPY	NUMBER
   )
   IS
      CURSOR c_terr_id
      IS
     SELECT terr_id
       FROM jtf_terr_all
      WHERE terr_id = p_terr_id
	AND trunc(NVL (end_date_active, SYSDATE)) >= trunc(SYSDATE)
	AND trunc(NVL (start_date_active, SYSDATE)) <= trunc(SYSDATE);

      CURSOR c_terr_name
      IS
     SELECT terr_id
       FROM jtf_terr_all
      WHERE name = p_terr_name
	AND trunc(NVL (end_date_active, SYSDATE)) >= trunc(SYSDATE)
	AND trunc(NVL (start_date_active, SYSDATE)) <= trunc(SYSDATE);
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_terr_id IS NOT NULL
      THEN
     OPEN c_terr_id;
     FETCH c_terr_id INTO x_terr_id;

     IF c_terr_id%NOTFOUND
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_TERR_ID');
	fnd_message.set_token ('P_TERR_ID', p_terr_id);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     CLOSE c_terr_id;
      ELSIF p_terr_name IS NOT NULL
      THEN
     OPEN c_terr_name;
     FETCH c_terr_name INTO x_terr_id;

     IF c_terr_name%NOTFOUND
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_TERR_NAME');
	fnd_message.set_token ('P_TERR_NAME', p_terr_name);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     CLOSE c_terr_name;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
   END;*/

-----------
----------- Validate Escalation
-----------
/*    PROCEDURE validate_escalation (
    p_escalation_flag	  IN	   VARCHAR2,
    p_owner_id	      IN       NUMBER,
    p_terr_id	      IN       NUMBER,
    p_terr_name       IN       VARCHAR2,
    x_owner_id	      OUT      NUMBER,
    x_terr_id	      OUT      NUMBER,
    x_return_status	  OUT	   VARCHAR2
    )
    IS
    CURSOR c_owner
    IS
	SELECT person_id
	  FROM per_all_people_f
	 WHERE person_id = p_owner_id;
    BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    jtf_task_utl.validate_flag (
	p_api_name => NULL,
	p_init_msg_list => fnd_api.g_false,
	x_return_status => x_return_status,
	p_flag_name => 'Escalation Flag',
	p_flag_value => p_escalation_flag
    );

    IF NOT (x_return_status = fnd_api.g_ret_sts_success)
    THEN
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (  jtf_task_utl.to_boolean (p_escalation_flag) = FALSE
       OR p_escalation_flag IS NULL)
    THEN
	IF    (p_owner_id IS NOT NULL)
	   OR (p_terr_id IS NOT NULL)
	   OR (p_terr_name IS NOT NULL)
	THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_ESC_DTLS');
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
	ELSE
	RETURN;
	END IF;
    END IF;

    IF	   (p_owner_id IS NULL)
       AND (  p_terr_id IS NULL
	   OR p_terr_name IS NULL)
    THEN
	fnd_message.set_name ('JTF', 'OWNER_OR_TERRITORY');
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF p_owner_id IS NOT NULL
    THEN
	OPEN c_owner;
	FETCH c_owner INTO x_owner_id;

	IF c_owner%NOTFOUND
	THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_OWNER_ID');
	fnd_message.set_token ('P_OWNER_ID', p_owner_id);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
	END IF;
    END IF;

    IF (  p_terr_id IS NOT NULL
       OR p_terr_name IS NOT NULL)
    THEN
	jtf_task_utl.validate_territory (
	p_terr_id => p_terr_id,
	p_terr_name => p_terr_name,
	x_return_status => x_return_status,
	x_terr_id => x_terr_id
	);

	IF NOT (x_return_status = fnd_api.g_ret_sts_success)
	THEN
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
	END IF;
    END IF;


    EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
	x_return_status := fnd_api.g_ret_sts_unexp_error;
    END;
*/
--------------
-------------- Validate Task Object Type
--------------
/*    PROCEDURE validate_task_object_type (
    p_object_type_name	IN   VARCHAR2,
    p_object_code	 IN	  NUMBER,
    x_return_status	  OUT	   VARCHAR2,
    x_object_code	OUT	 NUMBER
    )
    IS
    CURSOR c_object_code
    IS
	SELECT object_code
	  FROM jtf_objects_b
	 WHERE object_code = p_object_code;

    CURSOR c_object_type_name
    IS
	SELECT object_code
	  FROM jtf_objects_vl
	 WHERE name = p_object_type_name;

    BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF p_object_code IS NOT NULL
    THEN
	OPEN c_object_code;
	FETCH c_object_code INTO x_object_code;

	IF c_object_code%NOTFOUND
	THEN
	fnd_message.set_name ('JTF', 'invalid_object_type');
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	END IF;

	CLOSE c_object_code;
    ELSIF p_object_type_name IS NOT NULL
    THEN
	OPEN c_object_type_name;
	FETCH c_object_type_name INTO x_object_code;

	IF c_object_type_name%NOTFOUND
	THEN
	fnd_message.set_name ('JTF', 'invalid_object_type');
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	END IF;

	CLOSE c_object_type_name;
    END IF;
    END;
*/
   PROCEDURE validate_task_owner (
      p_owner_type_name   IN	   VARCHAR2,
      p_owner_type_code   IN	   VARCHAR2,
      p_owner_id      IN       NUMBER,
      x_return_status	  OUT NOCOPY	  VARCHAR2,
      x_owner_id      IN OUT NOCOPY	 NUMBER, -- Fixed from OUT to IN OUT
      x_owner_type_code   IN OUT NOCOPY      VARCHAR2 -- Fixed from OUT to IN OUT
   )
   IS
      l_owner_type_code   jtf_objects_b.object_code%TYPE
	   := p_owner_type_code;
      l_owner_type_name   jtf_objects_tl.name%TYPE
	   := p_owner_type_name;
      l_id_column     jtf_objects_b.select_id%TYPE;
      l_from_clause   jtf_objects_b.from_table%TYPE;
      l_where_clause	  jtf_objects_b.where_clause%TYPE;
      sql_stmt	      VARCHAR2(4000);
      l_owner_id      jtf_tasks_b.owner_id%TYPE   := p_owner_id;

      CURSOR c_owner_type
      IS

      SELECT select_id, from_table, where_clause
        FROM jtf_objects_b
      WHERE object_code = l_owner_type_code;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      jtf_task_utl.validate_object_type (
     p_object_code => p_owner_type_code,
     p_object_type_name => p_owner_type_name,
     p_object_type_tag => 'Owner',
     p_object_usage => 'RESOURCES',
     x_return_status => x_return_status,
     x_object_code => l_owner_type_code
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      OPEN c_owner_type;
      FETCH c_owner_type INTO l_id_column, l_from_clause, l_where_clause;

	-- Bug 3128054 fixed by TSINGHAL removed dbms messages
      IF c_owner_type%NOTFOUND THEN
     fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_OBJECT_CODE');
     fnd_message.set_token ('P_OBJECT_CODE', 'Owner');
     fnd_msg_pub.add;
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     RAISE fnd_api.g_exc_unexpected_error;
      END IF;

     -- SELECT DECODE (
     --   l_where_clause,
     --   NULL, l_where_clause,
     --   l_where_clause || ' AND '
     --    )
    --INTO
    --	   l_where_clause
    --FROM dual;

    -- Fix for bug 2932012
	IF (l_where_clause IS NULL)
	THEN
	   NULL;
	ELSE
	   l_where_clause := l_where_clause || ' AND ';
	END IF;

      -- Added 'rownum = 1' bshih
      sql_stmt := 'SELECT ' ||
	  l_id_column ||
	  ' from ' ||
	  l_from_clause ||
	  '  where ' ||
	  l_where_clause ||
	  l_id_column ||
	  ' = :owner_id and rownum = 1';

      BEGIN
        EXECUTE IMMEDIATE sql_stmt INTO l_owner_id
	USING l_owner_id;
      EXCEPTION
      WHEN OTHERS
      THEN
	x_owner_id := NULL;
	x_owner_type_code := NULL;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_OWNER_ID');
	fnd_message.set_token ('P_OWNER_ID', p_owner_id);
	fnd_msg_pub.add;
	RAISE fnd_api.g_exc_unexpected_error;
      END;

      x_owner_id := l_owner_id;
      x_owner_type_code := l_owner_type_code;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
     x_owner_id := NULL;
     x_owner_type_code := NULL;
     fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_OWNER_ID');
     fnd_message.set_token ('P_OWNER_ID', p_owner_id);
     fnd_msg_pub.add;
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     RAISE fnd_api.g_exc_unexpected_error;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     RAISE fnd_api.g_exc_unexpected_error;
      WHEN OTHERS
      THEN
     x_owner_id := NULL;
     x_owner_type_code := NULL;
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
     fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
     fnd_msg_pub.add;
     RAISE fnd_api.g_exc_unexpected_error;
   END;

-----------------------------------------------------------
-----------------------------------------------------------
---------------- Time zones
-----------------------------------------------------------
   PROCEDURE validate_timezones (
      p_timezone_id IN	 NUMBER,
      p_timezone_name	IN   VARCHAR2,
      x_return_status	OUT NOCOPY  VARCHAR2,
      x_timezone_id IN OUT NOCOPY  NUMBER -- Fixed from OUT to IN OUT
   )
   IS
      CURSOR c_timezone_id
      IS
     SELECT timezone_id
       FROM hz_timezones
      WHERE timezone_id = p_timezone_id;

      CURSOR c_timezone_name
      IS
     SELECT timezone_id
       FROM hz_timezones
      WHERE global_timezone_name = p_timezone_name;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_timezone_id IS NOT NULL
      THEN
     OPEN c_timezone_id;
     FETCH c_timezone_id INTO x_timezone_id;

     IF c_timezone_id%NOTFOUND
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_TIMEZONE_ID');
	fnd_message.set_token ('P_TIMEZONE_ID', p_timezone_id);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
     END IF;

     CLOSE c_timezone_id;
      ELSIF p_timezone_name IS NOT NULL
      THEN
     OPEN c_timezone_name;
     FETCH c_timezone_name INTO x_timezone_id;

     IF c_timezone_name%NOTFOUND
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_TIMEZONE_NAME');
	fnd_message.set_token ('P_TIMEZONE_NAME', p_timezone_name);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
     END IF;

     CLOSE c_timezone_name;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
     x_timezone_id := NULL;
     x_return_status := fnd_api.g_ret_sts_unexp_error;
   END;

-----------------------------------------------------------
-----------------------------------------------------------
   PROCEDURE validate_parent_task_id (
      p_parent_task_id	     IN       NUMBER,
      p_source_object_code   IN       VARCHAR2,
      p_source_object_id     IN       NUMBER,
      x_return_status	     OUT NOCOPY      VARCHAR2
   )
   IS
      l_p_source_object_code   jtf_tasks_b.source_object_type_code%TYPE;
      l_source_object_code     jtf_tasks_b.source_object_type_code%TYPE
	   := p_source_object_code;
      l_parent_task_id	       jtf_tasks_b.task_id%TYPE
	   := p_parent_task_id;
      l_source_object_id       jtf_tasks_b.source_object_id%TYPE
	   := p_source_object_id;
      l_p_source_object_id     jtf_tasks_b.source_object_id%TYPE;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      SELECT source_object_type_code, source_object_id
    INTO l_p_source_object_code, l_p_source_object_id
    FROM jtf_tasks_b
       WHERE task_id = p_parent_task_id;

      IF    (	l_p_source_object_code IS NOT NULL
	AND l_source_object_code IS NULL)
     OR (   l_p_source_object_code IS NULL
	AND l_source_object_code IS NOT NULL)
      THEN
     fnd_message.set_name ('JTF', 'JTF_TASK_PARENT_TYPE_CODE');
     fnd_msg_pub.add;
     x_return_status := fnd_api.g_ret_sts_unexp_error;
      END IF;

      IF (   l_p_source_object_code IS NOT NULL
     AND l_source_object_code IS NOT NULL)
      THEN
     IF l_p_source_object_code <> l_source_object_code
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_PARENT_TYPE_CODE');
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
     END IF;
      END IF;

      SELECT source_object_id
    INTO l_p_source_object_id
    FROM jtf_tasks_b
       WHERE task_id = p_parent_task_id;

      IF    (	l_p_source_object_id IS NOT NULL
	AND l_source_object_id IS NULL)
     OR (   l_p_source_object_id IS NULL
	AND l_source_object_id IS NOT NULL)
      THEN
     fnd_message.set_name ('JTF', 'JTF_TASK_PARENT');
     fnd_msg_pub.add;
     x_return_status := fnd_api.g_ret_sts_unexp_error;
      END IF;

      IF (   l_p_source_object_id IS NOT NULL
     AND l_source_object_id IS NOT NULL)
      THEN
     IF l_p_source_object_id <> l_source_object_id
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_PARENT');
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
     END IF;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS
      THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
   END;

-----------------------------------------------------------
-----------------------------------------------------------
   PROCEDURE validate_notification (
      p_notification_flag     IN       VARCHAR2,
      p_notification_period   IN       NUMBER,
      p_notification_period_uom   IN	   VARCHAR2,
      x_return_status	      OUT NOCOPY      VARCHAR2
   )
   IS
      l_notification_flag   jtf_tasks_b.notification_flag%TYPE
	   := p_notification_flag;
      l_period		jtf_tasks_b.notification_period%TYPE
	   := p_notification_period;
      l_period_uom	jtf_tasks_b.notification_period_uom%TYPE
	   := p_notification_period_uom;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      jtf_task_utl.validate_flag (
     x_return_status => x_return_status,
     p_flag_name => 'Notification
 Flag',
     p_flag_value => p_notification_flag
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
     RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      ------- Commented out (Bug 2118464) -----------------
      --IF    (   l_period IS NOT NULL
      --      AND l_period_uom IS NULL)
      --   OR (   l_period IS NOT NULL
      --      AND l_period_uom IS NULL)
      --THEN
      --   fnd_message.set_name ('JTF', 'INVALID_EFFORT');
      --   fnd_msg_pub.add;
      --   x_return_status := fnd_api.g_ret_sts_unexp_error;
      --END IF;
      -----------------------------------------------------

      --------- Fixed bug 2137765 --------------------------
      --jtf_task_utl.validate_effort (
      --   x_return_status => x_return_status,
      --   p_effort => l_period,
      --   p_effort_uom => l_period_uom
      --);
      jtf_task_utl.validate_effort (
     p_tag => jtf_task_utl.get_translated_lookup (
	     'JTF_TASK_TRANSLATED_MESSAGES',
	     'NOTIFICATION_PERIOD'
	  ),
     p_tag_uom => jtf_task_utl.get_translated_lookup (
	     'JTF_TASK_TRANSLATED_MESSAGES',
	     'NOTIFICATION_PERIOD_UOM'
	      ),
     x_return_status => x_return_status,
     p_effort => l_period,
     p_effort_uom => l_period_uom
      );
      -----------------------------------------------------
      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
     RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS
      THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
   END;

-----------------------------------------------------------
-----------------------------------------------------------
-----------------------------------------------------------
-----------------------------------------------------------
   PROCEDURE validate_alarm (
      p_alarm_start	 IN	  NUMBER,
      p_alarm_start_uom      IN       VARCHAR2,
      p_alarm_on	 IN	  VARCHAR2,
      p_alarm_count	 IN	  NUMBER,
      p_alarm_interval	     IN       NUMBER,
      p_alarm_interval_uom   IN       VARCHAR2,
      x_return_status	     OUT NOCOPY      VARCHAR2
   )
   IS
      is_null		 BOOLEAN		 := FALSE;
      is_not_null	 BOOLEAN		 := FALSE;
      l_alarm_start	 jtf_tasks_b.alarm_start%TYPE
	   := p_alarm_start;
      l_alarm_start_uom      jtf_tasks_b.alarm_start_uom%TYPE
	   := p_alarm_start_uom;
      l_alarm_on	 jtf_tasks_b.alarm_on%TYPE
	   := p_alarm_on;
      l_alarm_count	 jtf_tasks_b.alarm_count%TYPE
	   := p_alarm_count;
      l_alarm_interval	     jtf_tasks_b.alarm_interval%TYPE
	   := p_alarm_interval;
      l_alarm_interval_uom   jtf_tasks_b.alarm_interval_uom%TYPE
	   := p_alarm_interval_uom;
----
----	This api validates the alarm parameters for the task.
----
----

   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      jtf_task_utl.validate_flag (
     x_return_status => x_return_status,
     p_flag_name => 'Alarm Flag',
     p_flag_value => l_alarm_on
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
     RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF jtf_task_utl.to_boolean (p_alarm_on)
      THEN
     IF    (l_alarm_start IS NULL)
	OR (l_alarm_start_uom IS NULL)
	OR (l_alarm_count IS NULL)
	OR (l_alarm_interval IS NULL)
	OR (l_alarm_interval_uom IS NULL)
     THEN
	fnd_message.set_name ('JTF', 'INVALID_ALARM_PARAMETERS');
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     jtf_task_utl.validate_effort (
	x_return_status => x_return_status,
	p_effort => l_alarm_start,
	p_effort_uom => l_alarm_start_uom
     );

     IF NOT (x_return_status = fnd_api.g_ret_sts_success)
     THEN
     --   fnd_message.set_name ('JTF', 'Invalid_ALARM');
     --   fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     /*** Fixed Bug 2118582  ***********/
     --IF is_not_null
     --THEN
	jtf_task_utl.validate_effort (
	   x_return_status => x_return_status,
	   p_effort => l_alarm_interval,
	   p_effort_uom => l_alarm_interval_uom
	);

	IF NOT (x_return_status = fnd_api.g_ret_sts_success)
	THEN
     --  fnd_message.set_name ('JTF', 'Invalid_ALARM');
     --  fnd_msg_pub.add;
	   x_return_status := fnd_api.g_ret_sts_unexp_error;
	   RAISE fnd_api.g_exc_unexpected_error;
	END IF;
     --END IF;
      ELSE
     IF    (l_alarm_start IS NOT NULL)
	OR (l_alarm_start_uom IS NOT NULL)
	OR (l_alarm_count IS NOT NULL)
	OR (l_alarm_interval IS NOT NULL)
	OR (l_alarm_interval_uom IS NOT NULL)
     THEN
	fnd_message.set_name ('JTF', 'INVALID_ALARM_PARAMETERS');
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
     END IF;
      END IF;
   END;

-----------------------------------------------------------
-----------------------------------------------------------
   FUNCTION g_miss_char
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN fnd_api.g_miss_char;
   END;

   FUNCTION g_miss_date
      RETURN DATE
   IS
   BEGIN
      RETURN fnd_api.g_miss_date;
   END;

   FUNCTION g_miss_number
      RETURN NUMBER
   IS
   BEGIN
      RETURN fnd_api.g_miss_num;
   END;

   FUNCTION get_translated_lookup (
      p_lookup_type   IN   VARCHAR2,
      p_lookup_code   IN   VARCHAR2
      )
      RETURN VARCHAR2
   IS
      l_description   fnd_lookups.description%TYPE;
   BEGIN
      SELECT description
    INTO l_description
    FROM fnd_lookups
       WHERE lookup_type = p_lookup_type
     AND lookup_code = p_lookup_code;
      RETURN l_description;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
     RETURN NULL;
   END;

    -----------------------------
    -----------------------------
    -----------------------------
   PROCEDURE privelege_all_tasks (
      p_profile_name	      IN       VARCHAR2,
      x_privelege_all_tasks   OUT NOCOPY      VARCHAR2,
      x_return_status	      OUT NOCOPY      VARCHAR2
   )
   IS
      privelege_all_tasks   VARCHAR2(1);
      l_resource_id	NUMBER;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      fnd_profile.get (p_profile_name, privelege_all_tasks);

      IF    privelege_all_tasks = 'Y'
     OR privelege_all_tasks IS NULL
      THEN
     RETURN;
      END IF;

      SELECT resource_id
    INTO l_resource_id
    FROM jtf_rs_resource_extns
       WHERE user_id = fnd_global.user_id;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_USER_MAPPING');
     fnd_msg_pub.add;
      WHEN OTHERS
      THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
     fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
     fnd_msg_pub.add;
     RAISE fnd_api.g_exc_unexpected_error;
   END;

    -----------------------------
    -----------------------------
    -----------------------------
   PROCEDURE get_default_owner (
      x_owner_type_code        OUT NOCOPY   VARCHAR2,
      x_owner_id	   OUT NOCOPY	NUMBER,
      x_owner_type_code_name   OUT NOCOPY   VARCHAR2,
      x_owner_name	   OUT NOCOPY	VARCHAR2,
      x_return_status	       OUT NOCOPY   VARCHAR2
   )
   AS
      profile_set   BOOLEAN := TRUE;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      BEGIN
     x_owner_type_code :=
	fnd_profile.VALUE ('JTF_TASK_DEFAULT_OWNER_TYPE');
     x_owner_id := fnd_profile.VALUE ('JTF_TASK_DEFAULT_OWNER');
      EXCEPTION
     WHEN NO_DATA_FOUND
     THEN
	profile_set := FALSE;
      END;

      IF    (	x_owner_type_code IS NULL
	AND x_owner_id IS NOT NULL)
     OR (   x_owner_id IS NULL
	AND x_owner_type_code IS NOT NULL)
      THEN
     fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_DEFAULT_OWNER');
     fnd_msg_pub.add;
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     profile_set := FALSE;
     RETURN;
      END IF;

      IF profile_set
      THEN
     BEGIN
	x_owner_name :=
	   jtf_task_utl.get_owner (x_owner_type_code, x_owner_id);
     EXCEPTION
	WHEN NO_DATA_FOUND
	THEN
	   profile_set := FALSE;
     END;
      END IF;

      IF (x_owner_name IS NOT NULL)
      THEN
     SELECT name
       INTO x_owner_type_code_name
       FROM jtf_objects_vl
      WHERE object_code = x_owner_type_code;
     RETURN;
      ELSE
     BEGIN
	SELECT resource_id,
	   DECODE (
	      category,
	      'EMPLOYEE', 'RS_EMPLOYEE',
	      'PARTNER', 'RS_PARTNER',
	      'PARTY', 'RS_PARTY',
	      'OTHER', 'RS_OTHER',
	      'SUPPLIER_CONTACT', 'RS_SUPPLIER_CONTACT'
	   )
	  INTO x_owner_id,
	   x_owner_type_code
	  FROM jtf_rs_resource_extns
	 WHERE user_id = fnd_global.user_id;
	SELECT name
	  INTO x_owner_type_code_name
	  FROM jtf_objects_vl
	 WHERE object_code = x_owner_type_code;
	x_owner_name :=
	   jtf_task_utl.get_owner (x_owner_type_code, x_owner_id);
     EXCEPTION
	WHEN NO_DATA_FOUND
	THEN
	   NULL;
     END;
      END IF;
   END;

    -----------------------------
   --- USAGE
   ---	1. Used in the task main form.
   ---
   ---
    -----------------------------
   FUNCTION get_uom_time_class
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN jtf_task_utl.g_uom_time_class;
   END;

    -----------------------------
    ----------------------------
   --- USAGE
   ---	1. JTF_TASK_UWQ_V procedure to get if the task is closed or open.
   ---
   ---
    -----------------------------
    -----------------------------
   FUNCTION get_customer_name (p_customer_id IN NUMBER)
      RETURN VARCHAR2
   AS
      l_customer_name	VARCHAR2(120);
   BEGIN
      IF p_customer_id IS NULL
      THEN
     RETURN NULL;
      ELSE
     SELECT party_name
       INTO l_customer_name
       FROM hz_parties
      WHERE party_id = p_customer_id;
      END IF;

      RETURN l_customer_name;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
     RETURN NULL;
      WHEN OTHERS
      THEN
     RETURN NULL;
   END;

    -----------------------------
    --------------------------
   --- USAGE
   ---	1. JTF_TASK_UWQ_V procedure to get if the task is closed or open.
   ---
   ---
    -----------------------------
    -----------------------------
   FUNCTION is_task_closed (p_task_status_id IN NUMBER)
      RETURN VARCHAR2
   IS
      l_closed_flag  VARCHAR2(1);
      l_completed_flag	 VARCHAR2(1);
      l_cancelled_flag	 VARCHAR2(1);
      l_rejected_flag	 VARCHAR2(1);
   BEGIN
      --- Added to check for rejected flag on 6th October.
      SELECT closed_flag, completed_flag, cancelled_flag,
	 rejected_flag
    INTO l_closed_flag, l_completed_flag, l_cancelled_flag,
	 l_rejected_flag
    FROM jtf_task_statuses_vl
       WHERE task_status_id = p_task_status_id;

      --- Added to check for rejected flag on 6th October.
      IF     (	l_closed_flag IS NULL
	 OR l_closed_flag = 'N')
     AND (  l_completed_flag IS NULL
	 OR l_completed_flag = 'N')
     AND (  l_cancelled_flag IS NULL
	 OR l_cancelled_flag = 'N')
     AND (  l_rejected_flag IS NULL
	 OR l_rejected_flag = 'N')
      THEN
     RETURN 'N';
      ELSE
     RETURN 'Y';
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
     RETURN 'Y';
   END;

    -----------------------------
    -----------------------------
    -----------------------------
   PROCEDURE validate_missing_task_id (
      p_task_id     IN	 NUMBER,
      x_return_status	OUT NOCOPY  VARCHAR2
   )
   IS
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_task_id IS NULL
      THEN
     fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_TASK');
     fnd_msg_pub.add;
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END;

    -----------------------------
    -----------------------------
    -----------------------------
   PROCEDURE validate_missing_contact_id (
      p_task_contact_id   IN	   NUMBER,
      x_return_status	  OUT NOCOPY	  VARCHAR2
   )
   IS
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_task_contact_id IS NULL
      THEN
     fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_CONTACT');
     fnd_msg_pub.add;
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END;

    -----------------------------
    -----------------------------
    -----------------------------
   PROCEDURE validate_missing_phone_id (
      p_task_phone_id	IN   NUMBER,
      x_return_status	OUT NOCOPY  VARCHAR2
   )
   IS
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_task_phone_id IS NULL
      THEN
     fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_PHONE');
     fnd_msg_pub.add;
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END;

    -----------------------------
    -----------------------------
    -----------------------------
   --- This is used to validate application id in task template groups.
    -----------------------------
    -----------------------------
   PROCEDURE validate_application_id (
      p_application_id	 IN   NUMBER,
      x_return_status	 OUT NOCOPY	 VARCHAR2
   )
   IS
      l_application_id	 NUMBER;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      SELECT application_id
    INTO l_application_id
    FROM fnd_application_vl
       WHERE application_id = p_application_id;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
     fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_APPL_ID');
     fnd_message.set_token ('P_APPL_ID', p_application_id);
     fnd_msg_pub.add;
     x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN TOO_MANY_ROWS
      THEN
     NULL;
      WHEN OTHERS
      THEN
     fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
     fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
     fnd_msg_pub.add;
     x_return_status := fnd_api.g_ret_sts_unexp_error;
   END;

    -----------------------------
    -----------------------------
    -----------------------------
   --- This is used to get the user name for the JTF_TASKS_V
    -----------------------------
    -----------------------------
   FUNCTION get_user_name (p_user_id IN NUMBER)
      RETURN VARCHAR2
   IS
      l_user_name   fnd_user.user_name%TYPE;
   BEGIN
      IF p_user_id IS NULL
      THEN
     RETURN NULL;
      ELSE
     SELECT user_name
       INTO l_user_name
       FROM fnd_user
      WHERE user_id = p_user_id;
     RETURN l_user_name;
      END IF;
   END;

-----
-----
-----
   FUNCTION get_parent_task_number (p_task_id IN NUMBER)
      RETURN VARCHAR2
   IS
      l_task_number   VARCHAR2(30);
   BEGIN
      IF p_task_id IS NOT NULL
      THEN
     SELECT task_number
       INTO l_task_number
       FROM jtf_tasks_b task
      WHERE task_id = p_task_id ;
      END IF;

      RETURN l_task_number;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
     RETURN l_task_number;
   END;

-----
-----
-----
   FUNCTION get_territory_name (p_terr_id IN NUMBER)
      RETURN VARCHAR2
   IS
      l_terr_name   VARCHAR2(2000);
   BEGIN
      IF p_terr_id IS NOT NULL
      THEN
     SELECT name
       INTO l_terr_name
       FROM jtf_terr
      WHERE terr_id = p_terr_id;
      END IF;

      RETURN l_terr_name;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
     RETURN l_terr_name;
   END;

-----
-----
-----
   PROCEDURE validate_phones_table (
      p_owner_table_name   IN	    VARCHAR2,
      x_return_status	   OUT NOCOPY	   VARCHAR2
   )
   IS
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_owner_table_name IS NOT NULL
      THEN
     IF p_owner_table_name NOT IN ('JTF_TASKS_B', 'JTF_TASK_CONTACTS')
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_PHONE_TABLE');
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
     END IF;
      END IF;
   END;
-----
-----
PROCEDURE validate_category (
    p_category_id in number,
    x_return_status OUT NOCOPY varchar2)

     IS
    l_category_id number;
    l_resource_id number;
    l_profile_name varchar2(30);


   BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
  --	to verify user's category
    IF p_category_id is not null THEN
	  SELECT resource_id
	  INTO l_resource_id
	  FROM jtf_rs_resource_extns
	  WHERE user_id = fnd_global.user_id;

	  l_profile_name := TO_CHAR(l_resource_id)||g_perz_suffix;

	  SELECT perz_data_id into l_category_id
	  FROM jtf_perz_data
	  WHERE profile_id = (SELECT profile_id
		  FROM jtf_perz_profile
		  WHERE  profile_name = l_profile_name)
	  AND perz_data_id = p_category_id;
    END IF;
    EXCEPTION
       WHEN no_data_found THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_CATEGORY_ID');
	fnd_message.set_token ('P_CATEGORY_ID', p_category_id );
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
      END;
-----
-----
/************************ Commented out and rewrote : Bug 2120569
  PROCEDURE check_security_privilege(
	 p_task_id number,
	 p_session varchar2,
         x_return_status OUT NOCOPY VARCHAR2
  )
  IS

    l_rs_id	     number;
    l_rs_id_type	 varchar2(30);
    l_rs_type_code	 varchar2(30);
    l_resource_id	 number;
    l_resource_type_code varchar2(30);
    l_owner_id	     number;
    l_owner_type_code	 varchar2(30);
    l_privilege      varchar2(30) default null;
    l_private_flag	 jtf_tasks_b.private_flag%TYPE default null;


     BEGIN

     x_return_status := fnd_api.g_ret_sts_success;
     IF fnd_profile.value('JTF_TASK_CHECK_SECURITY') = jtf_task_utl.g_yes_char
     THEN

    -- select the owner info from task table for this task id
       SELECT owner_id, owner_type_code, private_flag
       INTO l_owner_id, l_owner_type_code, l_private_flag
       FROM jtf_tasks_b
       WHERE task_id = p_task_id;


    -- user's id and type
       SELECT resource_id
       INTO l_rs_id
       FROM jtf_rs_resource_extns
       WHERE user_id = fnd_global.user_id;


       IF p_session = 'UPDATE'
       THEN
	  BEGIN
       -- check when resource_type_code is a group
	  SELECT group_id
	  INTO l_resource_id
	  FROM jtf_rs_group_members
	  WHERE resource_id = l_rs_id
	  AND group_id IN (SELECT resource_id
		   FROM jtf_task_all_assignments
		   WHERE task_id = p_task_id
		   AND resource_type_code = 'RS_GROUP');
	  EXCEPTION
	 WHEN no_data_found THEN
	    BEGIN
	    SELECT team_id
	    INTO l_resource_id
	    FROM jtf_rs_team_members
	    WHERE team_resource_id = l_rs_id
	    AND team_id IN (SELECT resource_id
		    FROM jtf_task_all_assignments
		    WHERE task_id = p_task_id
		    AND resource_type_code = 'RS_TEAM');
	    EXCEPTION
	       when no_data_found then
	      -- compare user's id with the id list on assignment
	       SELECT resource_id
	       INTO l_resource_id
	       FROM jtf_task_all_assignments
	       WHERE task_id = p_task_id
	       AND resource_id = l_rs_id;


	       IF SQL%FOUND THEN
	      x_return_status := fnd_api.g_ret_sts_success;
	       ELSE
	       --  check to see if the user has the privilege when private flag is set to 'N'
	      IF l_private_flag = jtf_task_utl.g_no_char or l_private_flag is null
	      THEN
		 SELECT function_name into l_privilege
		 FROM fnd_form_functions fff, fnd_menu_entries fme
		 WHERE fff.function_id = fme.function_id
		 AND fme.menu_id = (select fm.menu_id from fnd_menus fm, fnd_grants fg
			where  fm.menu_id = fg.menu_id
			and fg.instance_pk1_value = l_owner_id
			and fg.instance_pk2_value = l_owner_type_code
			and fg.grantee_key = TO_CHAR(l_rs_id)
			and fg.object_id = (select object_id from fnd_objects
				    where obj_name = 'JTF_TASK_RESOURCE'
				    )
			)
		 AND function_name = jtf_task_utl.g_tasks_full_privelege;

		 IF SQL%FOUND THEN
		x_return_status := fnd_api.g_ret_sts_success;
		 ELSE
		fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_USER_ID');
		fnd_message.set_token ('P_USER_ID', l_rs_id );
		fnd_msg_pub.add;
		x_return_status := fnd_api.g_ret_sts_unexp_error;
		 END IF;
	      END IF;
	       END IF;
	    END;
	  END;
       END IF;
     End IF;
     EXCEPTION

     WHEN OTHERS
     THEN

	fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_SECURITY_CHK');
	fnd_message.set_token ('P_USER_ID', l_rs_id );
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;

  END;
************************************************************************************/
  /******** Rewote : Bug 2120569 **********/
  PROCEDURE check_security_privilege(
		p_task_id NUMBER,
		p_session VARCHAR2,
		x_return_status OUT NOCOPY VARCHAR2)
  IS
    l_user_id  NUMBER := fnd_global.user_id;

    -- select the owner info from task table for this task id
    CURSOR c_task_owner IS
    SELECT owner_id, owner_type_code, private_flag
    FROM jtf_tasks_b
    WHERE task_id = p_task_id;

    rec_task_owner  c_task_owner%ROWTYPE;

    -- user's id and type
    CURSOR c_resource IS
    SELECT resource_id
      FROM jtf_rs_resource_extns
     WHERE user_id = l_user_id;

    rec_resource    c_resource%ROWTYPE;

    CURSOR c_group (pc_rs_id NUMBER) IS
    SELECT group_id
      FROM jtf_rs_group_members
     WHERE resource_id = pc_rs_id
       AND group_id IN (SELECT resource_id
	      FROM jtf_task_all_assignments
	     WHERE task_id = p_task_id
	       AND resource_type_code = 'RS_GROUP');

    rec_group	c_group%ROWTYPE;

    CURSOR c_team  (pc_rs_id NUMBER) IS
    SELECT team_id
      FROM jtf_rs_team_members
     WHERE team_resource_id = pc_rs_id
       AND team_id IN (SELECT resource_id
	     FROM jtf_task_all_assignments
	    WHERE task_id = p_task_id
	      AND resource_type_code = 'RS_TEAM');

    rec_team   c_team%ROWTYPE;

    CURSOR c_assignee_or_owner (pc_rs_id NUMBER) IS
    SELECT resource_id
      FROM jtf_task_all_assignments
     WHERE task_id = p_task_id
       AND resource_id = pc_rs_id;

    rec_assignee_or_owner   c_assignee_or_owner%ROWTYPE;

    CURSOR c_grant (pc_pk1_value VARCHAR2, pc_pk2_value VARCHAR2, pc_grantee_key VARCHAR2) IS
    SELECT function_name
      FROM fnd_form_functions fff
     , fnd_menu_entries fme
     WHERE fff.function_id = fme.function_id
       AND fme.menu_id = (SELECT fm.menu_id
		FROM fnd_menus fm
		   , fnd_grants fg
	       WHERE fm.menu_id = fg.menu_id
		 AND fg.instance_pk1_value = pc_pk1_value
		 AND fg.instance_pk2_value = pc_pk2_value
		 AND fg.grantee_key = pc_grantee_key
		 AND fg.object_id =
		    (SELECT object_id
		       FROM fnd_objects
		      WHERE obj_name = 'JTF_TASK_RESOURCE'
		     )
	      )
       AND function_name = jtf_task_utl.g_tasks_full_privelege;

    rec_grant	c_grant%ROWTYPE;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF fnd_profile.value('JTF_TASK_CHECK_SECURITY') = jtf_task_utl.g_yes_char
    THEN
    OPEN c_task_owner;
    FETCH c_task_owner INTO rec_task_owner;
    IF c_task_owner%NOTFOUND
    THEN
	fnd_message.set_name('JTF', 'JTF_TASK_INVALID_TASK_ID');
	fnd_message.set_token('P_TASK_ID', p_task_id);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_error;
	RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE c_task_owner;

    OPEN c_resource;
    FETCH c_resource INTO rec_resource;
    IF c_resource%NOTFOUND
    THEN
	fnd_message.set_name('JTF', 'JTF_TASK_MISSING_USER_MAPPING');
	fnd_message.set_token('P_USER_ID', l_user_id);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_error;
	RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE c_resource;

    IF p_session = 'UPDATE'
    THEN
	-- Check group
	OPEN c_group (rec_resource.resource_id);
	FETCH c_group INTO rec_group;
	IF c_group%NOTFOUND
	THEN
	CLOSE c_group;
	-- Check team
	OPEN c_team (rec_resource.resource_id);
	FETCH c_team INTO rec_team;
	IF c_team%NOTFOUND
	THEN
	    CLOSE c_team;
	    --Check Assignment
	    OPEN c_assignee_or_owner (rec_resource.resource_id);
	    FETCH c_assignee_or_owner INTO rec_assignee_or_owner;
	    IF c_assignee_or_owner%NOTFOUND
	    THEN
	    --	check to see if the user has the privilege when private flag is set to 'N'
	    IF rec_task_owner.private_flag = jtf_task_utl.g_no_char or
	       rec_task_owner.private_flag is null
	    THEN
		OPEN c_grant (rec_task_owner.owner_id,
		      rec_task_owner.owner_type_code,
		      rec_resource.resource_id);
		FETCH c_grant INTO rec_grant;
		IF c_grant%NOTFOUND
		THEN
		fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_USER_ID');
		fnd_message.set_token ('P_USER_ID', rec_resource.resource_id);
		fnd_msg_pub.add;
		x_return_status := fnd_api.g_ret_sts_error;
		-- Don't raise any exception.
		-- This is not an exception, but insufficient privilege error.
		ELSE
		CLOSE c_grant;
		END IF; -- Check grant
	    ELSE
		fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_USER_ID');
		fnd_message.set_token ('P_USER_ID', rec_resource.resource_id);
		fnd_msg_pub.add;
		x_return_status := fnd_api.g_ret_sts_error;
		-- Don't raise any exception.
		-- This is not an exception, but insufficient privilege error.
	    END IF;
	    ELSE
	    CLOSE c_assignee_or_owner;
	    END IF; -- Check assignee_or_owner
	ELSE
	    CLOSE c_team;
	END IF; -- Check team
	ELSE
	CLOSE c_group;
	END IF; -- Check group
    END IF; -- p_session = UPDATE
    End IF; -- fnd_profile.value('JTF_TASK_CHECK_SECURITY') = Yes
  EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
    IF c_task_owner%ISOPEN THEN
	CLOSE c_task_owner;
    END IF;
    IF c_resource%ISOPEN THEN
	CLOSE c_resource;
    END IF;
    IF c_group%ISOPEN THEN
	CLOSE c_group;
    END IF;
    IF c_team%ISOPEN THEN
	CLOSE c_team;
    END IF;
    IF c_assignee_or_owner%ISOPEN THEN
	CLOSE c_assignee_or_owner;
    END IF;
    IF c_grant%ISOPEN THEN
	CLOSE c_grant;
    END IF;

    WHEN OTHERS
    THEN
    IF c_task_owner%ISOPEN THEN
	CLOSE c_task_owner;
    END IF;
    IF c_resource%ISOPEN THEN
	CLOSE c_resource;
    END IF;
    IF c_group%ISOPEN THEN
	CLOSE c_group;
    END IF;
    IF c_team%ISOPEN THEN
	CLOSE c_team;
    END IF;
    IF c_assignee_or_owner%ISOPEN THEN
	CLOSE c_assignee_or_owner;
    END IF;
    IF c_grant%ISOPEN THEN
	CLOSE c_grant;
    END IF;
    fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_SECURITY_CHK');
    fnd_message.set_token ('P_TEXT', SQLCODE ||' '|| SQLERRM);
    fnd_msg_pub.add;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    RAISE;
  END;

-----
-----
  FUNCTION g_no_char
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN 'N';
   END;
-----
-----
  FUNCTION g_yes_char
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN 'Y';
   END;

-----
-----
  FUNCTION g_false_char
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN 'F';
   END;
-----
-----
  FUNCTION g_true_char
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN 'T';
   END;

  PROCEDURE validate_party_site_acct (
     p_party_id number,
     p_party_site_id number,
     p_cust_account_id number,
     x_return_status OUT NOCOPY varchar2)
   IS

   CURSOR c_party_site(b_site_id number,
	       b_party_id number)
   IS
      SELECT 'found'
    FROM hz_party_sites
       WHERE party_site_id = b_site_id
     AND party_id = b_party_id;

   CURSOR c_party_acct(b_acct_id number,
	       b_party_id number)
   IS
      SELECT 'found'
    FROM hz_cust_accounts
       WHERE cust_account_id = b_acct_id
     AND party_id = b_party_id;

      x 	  varchar2(10);

   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_party_id IS NULL
    AND (p_party_site_id   IS NOT NULL
      OR p_cust_account_id IS NOT NULL) THEN
    -- cannot validate if there is no customer
    -- return a warning message
      fnd_message.set_name ('JTF', 'JTF_TASK_NO_PARTY');
      fnd_msg_pub.add;
      RETURN;
      END IF;

      IF p_party_site_id IS NOT NULL
      THEN
     OPEN c_party_site(p_party_site_id,
	       p_party_id);
     FETCH c_party_site into x;

     IF c_party_site%NOTFOUND
     THEN
	CLOSE c_party_site;
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_SITE_ID');
	fnd_message.set_token ('P_PARTY_SITE_ID', p_party_site_id);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     CLOSE c_party_site;
      END IF;

      IF p_cust_account_id IS NOT NULL
      THEN
     OPEN c_party_acct(p_cust_account_id,
	       p_party_id);
     FETCH c_party_acct into x;

     IF c_party_acct%NOTFOUND
     THEN
	CLOSE c_party_acct;
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_CUST_ACCT_ID');
	fnd_message.set_token ('P_CUST_ACCOUNT_ID', p_cust_account_id);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     CLOSE c_party_acct;
      END IF;
   END;


FUNCTION GET_CATEGORY_NAME ( p_category_id  in number  )
  RETURN  varchar2  IS

  l_msg_data varchar2(240); -- Fix bug 2540772

BEGIN
    if p_category_id is null then
       fnd_msg_pub.initialize ;
    fnd_message.set_name('JTF','JTF_CAL_COMMON_CATEGORY');
    fnd_msg_pub.add ;
    l_msg_data := substrb(fnd_msg_pub.get( 1 , 'F' ),1,240); -- Fixed for bug 2540722
    else
    select perz_data_desc
    into l_msg_data
    from jtf_perz_data
    where perz_data_id = p_category_id ;
    end if;

    return l_msg_data;
EXCEPTION
    when no_data_found then
    return null ;
END;



FUNCTION GET_CATEGORY_NAME_FOR_TASK ( p_task_id in number,
    p_resource_id in number,
    p_resource_type_code in varchar2 )
  RETURN  varchar2  IS
  l_category_id number ;
  l_category_name varchar2(240); -- Fix bug 2540772
BEGIN
  /* Make sure that only one row is returned */
  /* if the same  resource is assigned to the task*/
  select category_id
  into l_category_id
  from jtf_task_all_assignments
  where task_id = p_task_id
  and resource_id = p_resource_id
  and resource_type_code = p_resource_type_code
  and rownum < 2 ;

  -- For fix bug 2540722
  -- If l_category_id is null, return the translated message for "Unfiled"
  l_category_name := jtf_task_utl.get_category_name(l_category_id);

  return l_category_name;

EXCEPTION
when no_data_found then
  l_category_name := jtf_task_utl.get_category_name(null);
  return l_category_name;
END;


procedure delete_category( p_category_name in varchar2 )
as
begin

   update jtf_cal_addresses
   set category = null
   where category in ( select perz_data_id from jtf_perz_data where perz_data_name = p_category_name )	;


   update jtf_task_all_assignments
   set category_id = null
   where category_id in ( select perz_data_id from jtf_perz_data where perz_data_name = p_category_name )  ;


   delete from jtf_perz_data where perz_data_name = p_category_name ;

    commit ;
exception
    when others then
      raise ;
end ;

   PROCEDURE set_calendar_dates (
       p_show_on_calendar      IN VARCHAR2,
       p_date_selected	       IN VARCHAR2,
       p_planned_start_date    IN DATE,
       p_planned_end_date      IN DATE,
       p_scheduled_start_date  IN DATE,
       p_scheduled_end_date    IN DATE,
       p_actual_start_date     IN DATE,
       p_actual_end_date       IN DATE,
       x_show_on_calendar      IN OUT NOCOPY VARCHAR2,-- Fixed from OUT to IN OUT
       x_date_selected	       IN OUT NOCOPY VARCHAR2,-- Fixed from OUT to IN OUT
       x_calendar_start_date   OUT NOCOPY DATE,
       x_calendar_end_date     OUT NOCOPY DATE,
       x_return_status	       OUT NOCOPY VARCHAR2
   )
   is
   begin
       jtf_task_utl_ext.set_calendar_dates (
	   p_show_on_calendar	  => p_show_on_calendar    ,
	   p_date_selected	  => p_date_selected	   ,
	   p_planned_start_date   => p_planned_start_date  ,
	   p_planned_end_date	  => p_planned_end_date    ,
	   p_scheduled_start_date => p_scheduled_start_date,
	   p_scheduled_end_date   => p_scheduled_end_date  ,
	   p_actual_start_date	  => p_actual_start_date   ,
	   p_actual_end_date	  => p_actual_end_date	   ,
	   x_show_on_calendar	  => x_show_on_calendar    ,
	   x_date_selected	  => x_date_selected	   ,
	   x_calendar_start_date  => x_calendar_start_date ,
	   x_calendar_end_date	  => x_calendar_end_date   ,
	   x_return_status	  => x_return_status	   ,
	   p_task_status_id	  => NULL,
	   p_creation_date	  => NULL
       );
   EXCEPTION
      WHEN OTHERS THEN
	 fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
	 fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
	 fnd_msg_pub.add;
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
   END;
-----
-----
PROCEDURE validate_status (
    p_status_id in number,
    p_type in varchar2,
    x_return_status OUT NOCOPY varchar2)

     IS
    l_task_status_flag varchar2(1);
    l_assignment_status_flag varchar2(1);
    l_status_id number;
    l_usage  varchar2(15);

   BEGIN
    x_return_status := fnd_api.g_ret_sts_unexp_error;

    SELECT task_status_id, task_status_flag, assignment_status_flag, usage
    INTO l_status_id, l_task_status_flag, l_assignment_status_flag, l_usage
    FROM jtf_task_statuses_b
    WHERE task_status_id = p_status_id;

    IF SQL%FOUND THEN
       IF p_type = 'TASK' AND l_task_status_flag = jtf_task_utl.g_yes_char
       THEN
	 x_return_status := fnd_api.g_ret_sts_success;
       ELSE
	  IF p_type = 'ASSIGNMENT' AND l_assignment_status_flag = jtf_task_utl.g_yes_char
	  THEN
	 x_return_status := fnd_api.g_ret_sts_success;
	  ELSE
	 IF p_type = 'ESCALATION' AND l_usage = 'ESCALATION'
	 THEN
	    x_return_status := fnd_api.g_ret_sts_success;
	 ELSE
	    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_STATUS_NAME');
		  fnd_message.set_token ('P_TASK_STATUS_NAME', jtf_task_utl.get_status_name(l_status_id));
		  fnd_msg_pub.add;
	    x_return_status := fnd_api.g_ret_sts_unexp_error;
	 END IF;
	  END IF;
       END IF;
    END IF;

    EXCEPTION
     WHEN OTHERS
     THEN
	fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_STATUS_NAME');
	      fnd_message.set_token ('P_TASK_STATUS_NAME', jtf_task_utl.get_status_name(l_status_id));
	      fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
      END;
-------------
-------------
function getURL ( p_web_function_name in varchar2 )
return varchar2
as l_jsp_name varchar2(200);
begin
     if p_web_function_name is not null then
      select web_html_call into l_jsp_name
      from fnd_form_functions
      where function_name = p_web_function_name ;

      return l_jsp_name ;
     else
      return null ;
     end if ;
end;
-------------
-------------
function getURLparameter ( p_object_code in varchar2 )
return varchar2
as
l_object_parameters varchar2(60);
begin
     select OBJECT_PARAMETERS into l_object_parameters
     from jtf_objects_b
     where object_code = p_object_code ;

     return l_object_parameters ;
end ;
-------------
-------------
-- fix bug #2224949
   FUNCTION check_truncation (p_object_name in varchar2)
      return varchar2
   is

   x_object_name    varchar2(60);

   begin

      if lengthb(p_object_name) > 60 then
     x_object_name := substrb(p_object_name, 1, 57) || '...';
      else
     x_object_name := p_object_name;
      end if;

      return x_object_name;

   end;
-------------
-------------
-- Function added for Enhancement # 2102281
   FUNCTION check_duplicate_reference (p_task_id jtf_tasks_b.task_id%type,
	       p_object_id hz_relationships.object_id%type,
	       p_object_type_code jtf_task_references_b.object_type_code%type)
      return boolean
   is

   x_count NUMBER := 0;
   x_return_value boolean := true;

   begin
    select count(object_id)
    INTO x_count
      FROM JTF_TASK_REFERENCES_b
      WHERE task_id = p_task_id
      AND object_id = p_object_id
      AND object_type_code = p_object_type_code
      AND rownum = 1;

    if x_count > 0 then
    x_return_value := false;
    else
    x_return_value := true;
    end if;

   return x_return_value;

   end check_duplicate_reference;

-------------
-------------
-- Function added for Enhancement # 2102281
  FUNCTION check_reference_delete (p_task_id jtf_tasks_b.task_id%type,
		   p_object_id hz_relationships.object_id%type)
  return boolean
     is

     l_delete_status boolean := true;
     l_dummy varchar2(100);

  begin


  --Check from the Customer Details WRT Subject ID

  if l_delete_status then

    /* Check if the incoming object is shared by
    ** any of the subject of the Customer
    ** for the incoming task
    */

  begin

  select 'Exists' into l_dummy from hz_relationships
       where party_id in (select customer_id id
	       from jtf_tasks_b
	       where task_id = p_task_id)
       and subject_id = p_object_id;

  l_delete_status := false;

    Exception
    when too_many_rows then
	l_delete_status := false;
    when no_data_found then
	l_delete_status := true;
  end;

  end if;


  --Check from the Assignment Details WRT Subject ID

  if l_delete_status then

    begin

    /* Check if the incoming object is shared by
    ** any of the subject of the assignment(s)
    ** for the incoming task
    */

  select 'Exists' into l_dummy from hz_relationships
       where party_id in (select resource_id id
	     from jtf_task_assignments
	     where task_id = p_task_id)
  and subject_id = p_object_id;


  l_delete_status := false;

    Exception
    when too_many_rows then
	l_delete_status := false;
    when no_data_found then
	l_delete_status := true;
    end;


  end if;


  --Check from the Contact Details WRT Subject ID

  if l_delete_status then

    begin
    /* Check if the incoming object is shared by
    ** any of the subject of the contact(s)
    ** for the incoming task
    */

  select 'Exists' into l_dummy from hz_relationships
     where party_id in (select contact_id id
	     from jtf_task_contacts
	     where task_id = p_task_id)
  and subject_id = p_object_id;


  l_delete_status := false;

    Exception
    when too_many_rows then
	l_delete_status := false;
    when no_data_found then
	l_delete_status := true;
    end;


  end if;

  --Check from the Source Details WRT Subject ID

  if l_delete_status then

    begin

    /* Check if the incoming object is shared by
    ** the Source
    ** for the incoming task
    */

    select 'Exists' into l_dummy from hz_relationships
	where party_id in (select source_object_id
	   from jtf_tasks_b
		   where task_id = p_task_id)
    and subject_id = p_object_id;

  l_delete_status := false;

    Exception
    when too_many_rows then
	l_delete_status := false;
    when no_data_found then
	l_delete_status := true;
    end;

  end if;


  -- Check references shared by Contact(s)

  if l_delete_status then

    begin

    /* Check if the incoming object is shared by
    ** the contact(s)
    ** for the incoming task
    */

    select 'Party exists' into l_dummy from hz_parties
	where party_id in (select contact_id id
	     from jtf_task_contacts
	     where task_id = p_task_id
		     and contact_id = p_object_id);


  l_delete_status := false;

    Exception
    when too_many_rows then
	l_delete_status := false;
    when no_data_found then
	l_delete_status := true;
    end;


  end if;


  -- Check from the Source Details for other types - People
  --   or Organization

  if l_delete_status then

    begin

    /* Check if the incoming object is shared by
    ** the Source
    ** for the incoming task
    */

    select 'Party exists' into l_dummy from hz_parties
	where party_id in (select source_object_id
	   from jtf_tasks_b
		   where task_id = p_task_id
		   and source_object_id = p_object_id);

  l_delete_status := false;

    Exception
    when too_many_rows then
	l_delete_status := false;
    when no_data_found then
	l_delete_status := true;
    end;

  end if;

  -- Check from the Customer Details for other types - People
  --   or Organization

  if l_delete_status then

  begin

  select 'party exists' into l_dummy from hz_parties
  where party_id = (select customer_id
	     from jtf_tasks_b
	     where task_id = p_task_id
		     and customer_id = p_object_id);


  l_delete_status := false;

    Exception
    when too_many_rows then
	l_delete_status := false;
    when no_data_found then
	l_delete_status := true;
    end;

  end if;


  -- Check from the Assignment Details for other types -
  --	People / Organization

  if l_delete_status then

  begin

  select 'party exists' into l_dummy from hz_parties
  where party_id in (select resource_id id
	from jtf_task_assignments
	where task_id = p_task_id
		and resource_id = p_object_id);


  l_delete_status := false;

    Exception
    when too_many_rows then
	l_delete_status := false;
    when no_data_found then
	l_delete_status := true;
    end;

  end if;

  return l_delete_status;

  end check_reference_delete;

-------------
-------------

PROCEDURE create_party_reference (
    p_reference_from	in  varchar2,
    p_task_id	in  number,
    p_party_type_code	in  varchar2,
    p_party_id	in  number,
    x_msg_count OUT NOCOPY number,
    x_msg_data	OUT NOCOPY varchar2,
    x_return_status	OUT NOCOPY varchar2)

---
--- This procedure creates a reference for each of the parties
--- associated with a task
---
--- p_reference_from can be 'TASK', 'ASSIGNMENT' or 'CONTACT'
--- if p_reference_from is 'TASK' then only p_party_id is passed
--- if p_reference_from is 'ASSIGNMENT' or 'CONTACT' then both
--- p_party_id and p_party_type_code are passed
---

     IS

   l_reference_id   jtf_task_references_b.task_reference_id%type;
   l_object_id	    hz_parties.party_id%type;
   l_subject_id     hz_parties.party_id%type;
   l_party_name     hz_parties.party_name%type;
   l_party_type     hz_parties.party_type%type;
   l_task_type	    jtf_tasks_b.task_type_id%type;
   l_api_version    CONSTANT NUMBER := 1.0;

   cursor c_type (b_task_id jtf_tasks_b.task_id%type) is
   select task_type_id
     from jtf_tasks_b
    where task_id = b_task_id;

   cursor c_party (b_party_id hz_parties.party_id%type) is
   select party_name,
      party_type
     from hz_parties
    where party_id = b_party_id;

   cursor c_relation (b_relation_id hz_parties.party_id%type) is
   select object_id,
      subject_id
     from hz_relationships
    where party_id = b_relation_id
      and directional_flag = 'F' ;


   BEGIN

      x_return_status := fnd_api.g_ret_sts_success;

--/*
      if p_party_id is null then
     return;
      end if;
---
--- For assignments, check if it is for type PARTY_PERSON or PARTY_RELATIONSHIP,
--- as these are the only types we are interested in
---
      if p_reference_from = 'ASSIGNMENT' and
     p_party_type_code not in ('PARTY_PERSON', 'PARTY_RELATIONSHIP') then
     return;
      end if;
---
--- For contacts, check if it is for type CUST, as this is the only type we are
--- interested in
---
      if p_reference_from = 'CONTACT' and
     p_party_type_code <> 'CUST' then
     return;
      end if;
---
--- Check if the Task is an Escalation - we only create the references
--- for Tasks that are not Escalation documents
---
      open c_type(p_task_id);
      fetch c_type into l_task_type;
      if c_type%NOTFOUND then
     close c_type;
     raise fnd_api.g_exc_unexpected_error;
      end if;
      close c_type;
      if l_task_type <> 22 then
     if p_reference_from in ('TASK', 'CONTACT', 'ASSIGNMENT') then
	open c_party(p_party_id);
	fetch c_party into l_party_name,
		   l_party_type;
	if c_party%NOTFOUND then
	   close c_party;
	   raise fnd_api.g_exc_unexpected_error;
	end if;
	close c_party;
---
--- Create a reference for the party
---

-- Added for Enhancement # 2102281
g_show_error_for_dup_reference := False;

	jtf_task_references_pvt.create_references (
	   p_api_version => l_api_version,
	   p_init_msg_list => fnd_api.g_false,
	   p_commit => fnd_api.g_false,
	   p_task_id => p_task_id,
	   p_object_type_code => 'PARTY',
	   p_object_name => l_party_name,
	   p_object_id => p_party_id,
	   x_return_status => x_return_status,
	   x_msg_count => x_msg_count,
	   x_msg_data => x_msg_data,
	   x_task_reference_id => l_reference_id
	);

	if (x_return_status = fnd_api.g_ret_sts_error) then
	   raise fnd_api.g_exc_error;
	elsif (x_return_status = fnd_api.g_ret_sts_unexp_error) then
	   raise fnd_api.g_exc_unexpected_error;
	end if;

	if l_party_type = 'PARTY_RELATIONSHIP' then
---
--- Create two additional references - one for the SUBJECT of the
--- relationship and (not when p_reference_from = 'CONTACT') one for
--- the OBJECT of the relationship
---
	   open c_relation(p_party_id);
	   fetch c_relation into l_object_id,
		     l_subject_id;
	   if c_relation%NOTFOUND then
	  close c_relation;
	  raise fnd_api.g_exc_unexpected_error;
	   end if;
	   close c_relation;
---
--- Get the party details for the SUBJECT of the relationship
---
	   open c_party(l_subject_id);
	   fetch c_party into l_party_name,
		  l_party_type;
	   if c_party%NOTFOUND then
	  close c_party;
	  raise fnd_api.g_exc_unexpected_error;
	   end if;
	   close c_party;

-- Added for Enhancement # 2102281
g_show_error_for_dup_reference := False;

	   jtf_task_references_pvt.create_references (
	  p_api_version => l_api_version,
	  p_init_msg_list => fnd_api.g_false,
	  p_commit => fnd_api.g_false,
	  p_task_id => p_task_id,
	  p_object_type_code => 'PARTY',
	  p_object_name => l_party_name,
	  p_object_id => l_subject_id,
	  x_return_status => x_return_status,
	  x_msg_count => x_msg_count,
	  x_msg_data => x_msg_data,
	  x_task_reference_id => l_reference_id
	   );

	   if (x_return_status = fnd_api.g_ret_sts_error) then
	  raise fnd_api.g_exc_error;
	   elsif (x_return_status = fnd_api.g_ret_sts_unexp_error) then
	  raise fnd_api.g_exc_unexpected_error;
	   end if;
	   if p_reference_from in ('TASK', 'ASSIGNMENT') then
---
--- Get the party details for the OBJECT of the relationship
---
	  open c_party(l_object_id);
	  fetch c_party into l_party_name,
		     l_party_type;
	  if c_party%NOTFOUND then
	     close c_party;
	     raise fnd_api.g_exc_unexpected_error;
	  end if;
	  close c_party;

-- Added for Enhancement # 2102281
g_show_error_for_dup_reference := False;

	  jtf_task_references_pvt.create_references (
	     p_api_version => l_api_version,
	     p_init_msg_list => fnd_api.g_false,
	     p_commit => fnd_api.g_false,
	     p_task_id => p_task_id,
	     p_object_type_code => 'PARTY',
	     p_object_name => l_party_name,
	     p_object_id => l_object_id,
	     x_return_status => x_return_status,
	     x_msg_count => x_msg_count,
	     x_msg_data => x_msg_data,
	     x_task_reference_id => l_reference_id
	  );

	  if (x_return_status = fnd_api.g_ret_sts_error) then
	     raise fnd_api.g_exc_error;
	  elsif (x_return_status = fnd_api.g_ret_sts_unexp_error) then
	     raise fnd_api.g_exc_unexpected_error;
	  end if;

	   elsif l_party_type not in ('ORGANIZATION', 'PERSON') then
	  raise fnd_api.g_exc_unexpected_error;
	   end if;
	end if;
     else
---
--- Invalid value for p_reference_from
---
	raise fnd_api.g_exc_unexpected_error;
     end if;
      end if;

--*/
      exception
    when others
    then
       fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
       fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
       fnd_msg_pub.add;
       x_return_status := fnd_api.g_ret_sts_unexp_error;
   end;

PROCEDURE delete_party_reference (
    p_reference_from	in  varchar2,
    p_task_id	in  number,
    p_party_type_code	in  varchar2,
    p_party_id	in  number,
    x_msg_count OUT NOCOPY number,
    x_msg_data	OUT NOCOPY varchar2,
    x_return_status	OUT NOCOPY varchar2)
   IS

   l_reference_id   jtf_task_references_b.task_reference_id%type;
   l_object_version jtf_task_references_b.object_version_number%type;
   l_object_id	    hz_parties.party_id%type;
   l_subject_id     hz_parties.party_id%type;
   l_party_type     hz_parties.party_type%type;
   l_task_type	    jtf_tasks_b.task_type_id%type;
   l_api_version    CONSTANT NUMBER := 1.0;

   cursor c_type (b_task_id jtf_tasks_b.task_id%type) is
   select task_type_id
     from jtf_tasks_b
    where task_id = b_task_id;

   cursor c_party (b_party_id hz_parties.party_id%type) is
   select party_type
     from hz_parties
    where party_id = b_party_id;

   cursor c_relation (b_relation_id hz_parties.party_id%type) is
   select object_id,
      subject_id
     from hz_relationships
    where party_id = b_relation_id
      and directional_flag = 'F' ;

   cursor c_reference (b_task_id jtf_tasks_b.task_id%type,
	       b_party_id hz_parties.party_id%type) is
   select task_reference_id,
      object_version_number
     from jtf_task_references_b
    where task_id = b_task_id
      and object_id = b_party_id;

   BEGIN

      x_return_status := fnd_api.g_ret_sts_success;

--/*
      if p_party_id is null then
     return;
      end if;
---
--- For assignments, check if it is for type PARTY_PERSON or PARTY_RELATIONSHIP,
--- as these are the only types we are interested in
---
      if p_reference_from = 'ASSIGNMENT' and
     p_party_type_code not in ('PARTY_PERSON', 'PARTY_RELATIONSHIP') then
     return;
      end if;
---
--- For contacts, check if it is for type CUST, as this is the only type we are
--- interested in
---
      if p_reference_from = 'CONTACT' and
     p_party_type_code <> 'CUST' then
     return;
      end if;
---
--- Check if the Task is an Escalation - we only need to delete references
--- for Tasks that are not Escalation documents
---
      open c_type(p_task_id);
      fetch c_type into l_task_type;
      if c_type%NOTFOUND then
     close c_type;
     raise fnd_api.g_exc_unexpected_error;
      end if;
      close c_type;
      if l_task_type <> 22 then
     if p_reference_from in ('TASK', 'CONTACT', 'ASSIGNMENT') then
	open c_party(p_party_id);
	fetch c_party into l_party_type;
	if c_party%NOTFOUND then
	   close c_party;
	   raise fnd_api.g_exc_unexpected_error;
	end if;
	close c_party;
---
--- Find the reference to be deleted
---
	open c_reference(p_task_id, p_party_id);
	fetch c_reference into l_reference_id,
		   l_object_version;
	if c_reference%NOTFOUND then
---
--- Ignore it if the reference does not exist
---
	   close c_reference;
	else
	   close c_reference;
---
--- Delete the reference for the party
---
-- Added for Enhancement # 2102281
g_show_error_for_dup_reference := False;

	   jtf_task_references_pvt.delete_references (
	  p_api_version => l_api_version,
	  p_init_msg_list => fnd_api.g_false,
	  p_commit => fnd_api.g_false,
	  p_object_version_number => l_object_version,
	  p_task_reference_id => l_reference_id,
	  x_return_status => x_return_status,
	  x_msg_count => x_msg_count,
	  x_msg_data => x_msg_data
	   );

	   if (x_return_status = fnd_api.g_ret_sts_error) then
	  raise fnd_api.g_exc_error;
	   elsif (x_return_status = fnd_api.g_ret_sts_unexp_error) then
	  raise fnd_api.g_exc_unexpected_error;
	   end if;
	end if;

	if l_party_type = 'PARTY_RELATIONSHIP' then
---
--- Delete two additional references - one for the SUBJECT of the
--- relationship and (not when p_reference_from = 'CONTACT') one for
--- the OBJECT of the relationship
---
	   open c_relation(p_party_id);
	   fetch c_relation into l_object_id,
		     l_subject_id;
	   if c_relation%NOTFOUND then
	  close c_relation;
	  raise fnd_api.g_exc_unexpected_error;
	   end if;
	   close c_relation;
---
--- Get the party details for the SUBJECT of the relationship
---
	   open c_party(l_subject_id);
	   fetch c_party into l_party_type;
	   if c_party%NOTFOUND then
	  close c_party;
	  raise fnd_api.g_exc_unexpected_error;
	   end if;
	   close c_party;
---
--- Find the reference to be deleted
---
	   open c_reference(p_task_id, l_subject_id);
	   fetch c_reference into l_reference_id,
		      l_object_version;
	   if c_reference%NOTFOUND then
---
--- Ignore it if the reference does not exist
---
	  close c_reference;
	   else
	  close c_reference;
---
--- Delete the reference for the party
---
-- Added for Enhancement # 2102281
g_show_error_for_dup_reference := False;

	  jtf_task_references_pvt.delete_references (
	     p_api_version => l_api_version,
	     p_init_msg_list => fnd_api.g_false,
	     p_commit => fnd_api.g_false,
	     p_object_version_number => l_object_version,
	     p_task_reference_id => l_reference_id,
	     x_return_status => x_return_status,
	     x_msg_count => x_msg_count,
	     x_msg_data => x_msg_data
	  );

	  if (x_return_status = fnd_api.g_ret_sts_error) then
	     raise fnd_api.g_exc_error;
	  elsif (x_return_status = fnd_api.g_ret_sts_unexp_error) then
	     raise fnd_api.g_exc_unexpected_error;
	  end if;
	   end if;

	   if p_reference_from in ('TASK', 'ASSIGNMENT') then
---
--- Get the party details for the OBJECT of the relationship
---
	  open c_party(l_object_id);
	  fetch c_party into l_party_type;
	  if c_party%NOTFOUND then
	     close c_party;
	     raise fnd_api.g_exc_unexpected_error;
	  end if;
	  close c_party;
---
--- Find the reference to be deleted
---
	  open c_reference(p_task_id, l_object_id);
	  fetch c_reference into l_reference_id,
		     l_object_version;
	  if c_reference%NOTFOUND then
---
--- Ignore it if the reference does not exist
---
	     close c_reference;
	  else
	     close c_reference;
---
--- Delete the reference for the party
---
-- Added for Enhancement # 2102281
g_show_error_for_dup_reference := False;

	 jtf_task_references_pvt.delete_references (
	    p_api_version => l_api_version,
	    p_init_msg_list => fnd_api.g_false,
	    p_commit => fnd_api.g_false,
	    p_object_version_number => l_object_version,
	    p_task_reference_id => l_reference_id,
	    x_return_status => x_return_status,
	    x_msg_count => x_msg_count,
	    x_msg_data => x_msg_data
	     );

	     if (x_return_status = fnd_api.g_ret_sts_error) then
	    raise fnd_api.g_exc_error;
	     elsif (x_return_status = fnd_api.g_ret_sts_unexp_error) then
	    raise fnd_api.g_exc_unexpected_error;
	     end if;
	  end if;

	   elsif l_party_type not in ('ORGANIZATION', 'PERSON') then
	  raise fnd_api.g_exc_unexpected_error;
	   end if;
	end if;
     else
---
--- Invalid value for p_reference_from
---
	raise fnd_api.g_exc_unexpected_error;
     end if;
      end if;

--*/
      exception
    when others
    then
       fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
       fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
       fnd_msg_pub.add;
       x_return_status := fnd_api.g_ret_sts_unexp_error;
   end;

   --Bug 2467222  for assignee category update
   --- update_task_assignee procedure begin

    PROCEDURE update_task_category (
    p_api_version	    IN	     NUMBER,
    p_object_version_number IN OUT NOCOPY   NUMBER,
    p_task_assignment_id    IN	     NUMBER,
    p_category_id	    IN	     NUMBER,
    x_return_status	   OUT NOCOPY	    VARCHAR2,
    x_msg_count 	   OUT NOCOPY	    NUMBER,
    x_msg_data		   OUT NOCOPY	    VARCHAR2
    )
    IS

    BEGIN
    jtf_task_assignments_pvt.update_task_assignment (
	p_api_version => p_api_version,
	p_object_version_number => p_object_version_number,
	p_init_msg_list => fnd_api.g_false,
	p_commit => fnd_api.g_false,
	p_task_assignment_id => p_task_assignment_id,
	x_msg_data => x_msg_data,
	x_msg_count => x_msg_count,
	x_return_status => x_return_status,
	P_CATEGORY_ID => p_category_id
      );

     IF NOT (x_return_status = fnd_api.g_ret_sts_success)
     THEN
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

    END;

   FUNCTION get_owner_detail (p_object_type_code IN VARCHAR2, p_object_id IN NUMBER)
      RETURN VARCHAR2
   IS
      CURSOR c_references
      IS
     SELECT select_id, select_details, from_table, where_clause
       FROM jtf_objects_b
      WHERE object_code = p_object_type_code;
      --- Removed the reference from JTF_OBJECTS_VL to JT_OBJECTS_B.


      l_id_column      jtf_objects_b.select_id%TYPE;
      l_details_column	  jtf_objects_b.select_details%TYPE;
      l_from_clause    jtf_objects_b.from_table%TYPE;
      l_where_clause   jtf_objects_b.where_clause%TYPE;
      l_object_code    jtf_tasks_b.source_object_type_code%TYPE
	   := p_object_type_code;
      l_object_details	  VARCHAR2(2000);
      is_null	       BOOLEAN			:= FALSE;
      is_not_null      BOOLEAN			:= FALSE;
      sql_stmt	       VARCHAR2(2000);
   BEGIN
      OPEN c_references;
      FETCH c_references INTO l_id_column,
		  l_details_column,
		  l_from_clause,
		  l_where_clause;

      IF c_references%NOTFOUND
      THEN
     NULL;
      END IF;

    IF (l_where_clause IS NULL)
	THEN
	   l_where_clause := '	';
	ELSE
	   l_where_clause := l_where_clause || ' AND ';
	END IF;

      -- Added 'rownum = 1' bshih
      sql_stmt := ' SELECT ' ||
	  l_details_column ||
	  ' from ' ||
	  l_from_clause ||
	  '  where ' ||
	  l_where_clause ||
	  l_id_column ||
	  ' = :object_id and rownum = 1';

      EXECUTE IMMEDIATE sql_stmt INTO l_object_details
        USING p_object_id;
      RETURN l_object_details;

   EXCEPTION
      WHEN OTHERS
      THEN
     RETURN NULL;
   END;

   -- Function to convert status id into status name
   FUNCTION get_status_name (p_status_id IN NUMBER)
      RETURN VARCHAR2
   AS
      l_status_name	VARCHAR2(30);
   BEGIN
      IF p_status_id IS NULL
      THEN
     RETURN NULL;
      ELSE
      SELECT name
	   INTO  l_status_name
       FROM jtf_task_statuses_vl
      WHERE task_status_id = p_status_id;
      END IF;

      RETURN l_status_name;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
     RETURN NULL;
      WHEN OTHERS
      THEN
     RETURN NULL;
   END;

  FUNCTION enable_audit (p_enable IN BOOLEAN)
      RETURN BOOLEAN
  AS PRAGMA autonomous_transaction;
    l_status BOOLEAN := FALSE;
  BEGIN
    IF( p_enable ) THEN
      l_status:=fnd_profile.save('JTF_TASK_ENABLE_AUDIT',g_yes,'SITE');
    ELSE
      l_status:=fnd_profile.save('JTF_TASK_ENABLE_AUDIT',g_no,'SITE');
    END IF;
    IF(l_status) THEN
      COMMIT;
    END IF;
    RETURN l_status;
  END;

END;

/
