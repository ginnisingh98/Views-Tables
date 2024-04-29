--------------------------------------------------------
--  DDL for Package Body AHL_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UTILITY_PVT" AS
/* $Header: AHLVUTLB.pls 120.3 2006/06/30 09:11:54 sathapli noship $ */

  -- Added for use by bind_parse.
  TYPE col_val_rec IS RECORD (
      col_name    VARCHAR2(2000),
      col_op      VARCHAR2(10),
      col_value   VARCHAR2(2000) );

  TYPE col_val_tbl IS TABLE OF col_val_rec INDEX BY BINARY_INTEGER;


---------------------------------------------------------------------
-- PROCEDURE
--    bind_parse
-- USAGE
--    bind_parse (varchar2, col_val_tbl);
--    The input string must have a space between the AND and operator clause
--    and it must exclude the initial WHERE/AND statement.
--    Example: source_code = 'xyz' and campaign_id <> 1
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
         IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_unexp_error) THEN
            Fnd_Message.set_name('AHL', 'AHL_UTIL_NO_WHERE_OPERATOR');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.g_exc_unexpected_error;
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
--    check_fk_exists
--
-- HISTORY
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
      RETURN Fnd_Api.g_false;
   ELSE
      RETURN Fnd_Api.g_true;
   END IF;

END check_fk_exists;


---------------------------------------------------------------------
-- FUNCTION
--    check_lookup_exists
--
-- HISTORY
---------------------------------------------------------------------
FUNCTION check_lookup_exists(
   p_lookup_table_name  IN VARCHAR2 := g_ahl_lookups,
   p_lookup_type        IN VARCHAR2,
   p_lookup_code        IN VARCHAR2
)
RETURN VARCHAR2
IS

   l_sql   VARCHAR2(4000);
   l_count NUMBER;

BEGIN

   l_sql := 'SELECT 1 FROM DUAL WHERE EXISTS (SELECT 1 FROM ' || p_lookup_table_name;
   l_sql := l_sql || ' WHERE LOOKUP_TYPE = :b1';
   l_sql := l_sql || ' AND LOOKUP_CODE = :b2';
   l_sql := l_sql || ' AND ENABLED_FLAG = ''Y'')';

   IF Ahl_Debug_Pub.G_FILE_DEBUG THEN
       Ahl_Debug_Pub.debug( 'SQL statement'||l_sql);
    END IF;
   debug_message('SQL statement: '||l_sql);
   BEGIN
      EXECUTE IMMEDIATE l_sql INTO l_count
      USING p_lookup_type, p_lookup_code;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_count := 0;
   END;

   IF l_count = 0 THEN
      RETURN Fnd_Api.g_false;
   ELSE
      RETURN Fnd_Api.g_true;
   END IF;

END check_lookup_exists;


---------------------------------------------------------------------
-- FUNCTION
--    check_uniqueness
--
-- HISTORY
--    Use bind_parse to enable use of bind variables.
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
   bind_parse (p_where_clause, l_bind_tbl);
   --
   -- Support up to 4 WHERE conditions for uniqueness.  If
   -- the number of conditions changes, then must also revise
   -- the execute portion of the code.
   IF l_bind_tbl.COUNT <= 4 THEN
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
      ELSE
         EXECUTE IMMEDIATE l_sql INTO l_count;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_count := 0;
   END;

   IF l_count = 0 THEN
      RETURN Fnd_Api.g_true;
   ELSE
      RETURN Fnd_Api.g_false;
   END IF;

END check_uniqueness;

---------------------------------------------------------------------
-- FUNCTION
--    is_Y_or_N
--
-- HISTORY
--
---------------------------------------------------------------------
FUNCTION is_Y_or_N(
   p_value IN VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN
   IF p_value = 'Y' OR p_value = 'N' THEN
      RETURN Fnd_Api.g_true;
   ELSE
      RETURN Fnd_Api.g_false;
   END IF;
END is_Y_or_N;


---------------------------------------------------------------------
-- PROCEDURE
--    debug_message
--
-- HISTORY
--   Modified cxcheng fix bug 3856899
--
---------------------------------------------------------------------
PROCEDURE debug_message(
   p_message_text   IN  VARCHAR2,
   p_message_level  IN  NUMBER := Fnd_Msg_Pub.g_msg_lvl_debug_high --Not used
)
IS
BEGIN

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(
        fnd_log.level_statement,
        'ahl.plsql.AHL_UTILITY_PVT.debug_message',
        p_message_text);
    END IF;
END debug_message;

---------------------------------------------------------------------
-- PROCEDURE
--    error_message
--
-- HISTORY
--
---------------------------------------------------------------------
PROCEDURE error_message(
   p_message_name VARCHAR2,
   p_token_name   VARCHAR2 := NULL,
   P_token_value  VARCHAR2 := NULL
)
IS
BEGIN
   IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
      Fnd_Message.set_name('AHL', p_message_name);
      IF p_token_name IS NOT NULL THEN
         Fnd_Message.set_token(p_token_name, p_token_value);
      END IF;
      Fnd_Msg_Pub.ADD;
   END IF;
END error_message;

--======================================================================
-- FUNCTION
--    Check_User_Status
--
-- PURPOSE
--    Created to check if the User has status change permissions
--    Returns true, if it is allowed user status
--
-- HISTORY
--    18-Dec-2001  srini  Create.
--======================================================================
FUNCTION Check_User_Status(
   p_user_status_id  IN VARCHAR2,
   p_status_type     IN  VARCHAR2,
   p_next_status     IN VARCHAR2)

RETURN VARCHAR2
IS
  CURSOR cur_usr_stat_det IS
  SELECT  1 FROM DUAL
  WHERE EXISTS (SELECT *  FROM AHL_USER_STATUSES_VL
                WHERE user_status_id = p_user_status_id
                  AND system_status_type = p_status_type
                  AND system_status_code = p_next_status
                  AND active_flag = 'Y');

l_dummy NUMBER;
BEGIN
     OPEN cur_usr_stat_det;
     FETCH cur_usr_stat_det INTO l_dummy;
     CLOSE cur_usr_stat_det;

     IF l_dummy IS NULL THEN
        RETURN Fnd_Api.G_FALSE;
     ELSE
         RETURN Fnd_Api.G_TRUE;
     END IF;
END Check_User_Status;

--======================================================================
-- PROCEDURE
--    Check_Status_Change
--
-- PURPOSE
--    Created to check if the status change is valid and allowed or not.
--    Returns success, if it is valid allowed status change
--
-- HISTORY
--    18-Dec-2001  srini  Create.
--======================================================================

PROCEDURE Check_status_change (
   p_object_type      IN  VARCHAR2,
   p_user_status_id   IN  NUMBER,
   p_status_type      IN  VARCHAR2,
   p_current_status   IN  VARCHAR2,
   p_next_status      IN  VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2)
IS
-- Cursor to check next status code is valid
  CURSOR cur_stat_det IS
  SELECT  1 FROM DUAL
  WHERE EXISTS (SELECT *  FROM AHL_STATUS_ORDER_RULES
                WHERE system_status_type = p_status_type
                  AND current_status_code = p_current_status
                  AND next_status_code = p_next_status);
-- Cursor to get system status code
  CURSOR cur_user_stat  (c_status_type IN VARCHAR2,
                         c_status_code IN VARCHAR2)
      IS
  SELECT system_status_code
    FROM AHL_USER_STATUSES_VL
   WHERE system_status_type = c_status_type
     AND name               = c_status_code;
   l_dummy            NUMBER;
   l_c_system_status  VARCHAR2(30);
   l_n_system_status  VARCHAR2(30);
BEGIN
     -- get currant system status code
     OPEN cur_user_stat(p_status_type,p_current_status);
     FETCH cur_user_stat INTO l_c_system_status;
     IF cur_user_stat%NOTFOUND THEN
        Fnd_Message.set_name('AHL', 'AHL_COM_RECORD_FOUND');
        Fnd_Msg_Pub.ADD;
     END IF;
     CLOSE cur_user_stat;
     -- get system status code for new status code
     OPEN cur_user_stat(p_status_type,p_next_status);
     FETCH cur_user_stat INTO l_n_system_status;
     IF cur_user_stat%NOTFOUND THEN
        Fnd_Message.set_name('AHL', 'AHL_COM_RECORD_FOUND');
        Fnd_Msg_Pub.ADD;
     END IF;
     CLOSE cur_user_stat;
     -- System status is same then return
     IF l_c_system_status = l_n_system_status THEN
         RETURN;
     END IF;
     --
     OPEN cur_stat_det;
     FETCH cur_stat_det INTO l_dummy;
     CLOSE cur_stat_det;
    IF l_dummy IS NOT NULL THEN
       x_return_status:= Fnd_Api.G_RET_STS_SUCCESS;
         ELSE
       x_return_status := Fnd_Api.G_RET_STS_ERROR;
    END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
   WHEN TOO_MANY_ROWS THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE;

END check_status_change;

--======================================================================
-- PROCEDURE
--    Check_Status_Order_Change
--
-- PURPOSE
--    Created to check if the status change is valid and allowed or not.
--    Returns success, if it is valid allowed status change
--
-- HISTORY
--    18-Dec-2001  srini  Create.
--======================================================================

PROCEDURE check_status_order_change (
   p_status_type      IN  VARCHAR2,
   p_current_status   IN  VARCHAR2,
   p_next_status      IN  VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2)
IS
-- Cursor to check next status code is valid
  CURSOR cur_stat_det (c_status_type  IN VARCHAR2,
                       c_current_status  IN  VARCHAR2,
                       c_next_status  IN VARCHAR2)
  IS
  SELECT '1'  FROM AHL_STATUS_ORDER_RULES
    WHERE system_status_type = c_status_type
      AND current_status_code = c_current_status
      AND next_status_code = c_next_status;
   l_dummy            NUMBER;

BEGIN

   Ahl_Debug_Pub.enable_debug;
   -- Debug info.
   IF Ahl_Debug_Pub.G_FILE_DEBUG THEN
       Ahl_Debug_Pub.debug( 'status TYPE'||p_status_type);
       Ahl_Debug_Pub.debug( 'status TYPE'||p_status_type);
       Ahl_Debug_Pub.debug('ccode' ||p_current_status);
       Ahl_Debug_Pub.debug('ncode:' ||p_next_status);
    END IF;

     -- get currant system status code
     OPEN cur_stat_det(p_status_type,
                       p_current_status,
                       p_next_status);
     FETCH cur_stat_det INTO l_dummy;
     IF l_dummy IS NULL THEN
        Fnd_Message.set_name('AHL', 'AHL_INVALID_STATUS');
        Fnd_Msg_Pub.ADD;
        x_return_status:= Fnd_Api.G_RET_STS_ERROR;
    ELSE
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
     END IF;
     CLOSE cur_stat_det;
     --
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
   WHEN TOO_MANY_ROWS THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE;

END check_status_order_change;

--======================================================================
-- PROCEDURE
--   Get_WF_Process_Name
--
-- PURPOSE
--    Returns workflow process name for the given type object
--    Returns 'E' for active if the no workflow is defined.
--
--======================================================================

PROCEDURE Get_WF_Process_Name (
   p_object         IN  VARCHAR2,
   p_application_usg_code IN VARCHAR2 DEFAULT 'AHL',
   x_active         OUT NOCOPY VARCHAR2,
   x_process_name   OUT NOCOPY VARCHAR2,
   x_item_type      OUT NOCOPY VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY VARCHAR2,
   x_msg_data       OUT NOCOPY VARCHAR2)

IS
   l_active         VARCHAR2(1);
   l_process_name   VARCHAR2(30);
   l_item_type      VARCHAR2(8);
   l_count          NUMBER;

      CURSOR c_wf_data (in_object IN VARCHAR2,
        in_appl_usg_code IN VARCHAR2) IS
      SELECT  wf_process_name, Item_type, Active_flag
      FROM    AHL_WF_MAPPING
      WHERE   Approval_object = in_object
      AND APPLICATION_USG_CODE = in_appl_usg_code;

    CURSOR c_wf_data_null (in_appl_usg_code IN VARCHAR2) IS
      SELECT  wf_process_name, Item_type, Active_flag
      FROM    AHL_WF_MAPPING
      WHERE   Approval_object IS NULL
      AND APPLICATION_USG_CODE = in_appl_usg_code;

   CURSOR chk_appl_usg_code IS
    SELECT 1 FROM FND_LOOKUPS
    WHERE lookup_code = p_application_usg_code
    AND LOOKUP_TYPE = 'AHL_APPLICATION_USAGE_CODE';
  BEGIN
   OPEN chk_appl_usg_code;
      FETCH chk_appl_usg_code INTO l_count;
    IF chk_appl_usg_code%NOTFOUND THEN
          CLOSE chk_appl_usg_code;
          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
          Fnd_Message.set_name ('AHL', 'AHL_APPR_APPUSG_INVALID');
          Fnd_Msg_Pub.ADD;
          END IF;
             x_return_status := Fnd_Api.g_ret_sts_error;
             RETURN;
      ELSE
          CLOSE chk_appl_usg_code;
      END IF;

    OPEN c_wf_data(p_object, p_application_usg_code);
    FETCH c_wf_data INTO l_process_name,l_item_type,l_active;
   IF c_wf_data%FOUND THEN
       CLOSE c_wf_data;

       x_active       := l_active;
       x_process_name := l_process_name;
       x_item_type    := l_item_type;
       x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
       RETURN;
   ELSE
      CLOSE c_wf_data;
      OPEN c_wf_data_null(p_application_usg_code);
      FETCH c_wf_data_null INTO l_process_name,l_item_type,l_active;
      IF c_wf_data_null%NOTFOUND THEN
           CLOSE c_wf_data_null;
            x_active       := 'E';
            x_process_name := NULL;
            x_item_type    := NULL;
--should not return error if no wf is found as this condition is not an error, and each module should handle it as they see fit.
            x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
           RETURN;
      ELSE
           CLOSE c_wf_data_null;

            x_active       := l_active;
            x_process_name := l_process_name;
            x_item_type    := l_item_type;
            x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
            RETURN;
      END IF;
   END IF;

   Fnd_Msg_Pub.count_and_get (
         p_encoded => Fnd_Api.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

END Get_WF_Process_Name;

--This function is to get the highest standalone unit name to which the instance belongs to
--This unit name is not the sub unit but the root unit
FUNCTION   Get_Unit_Name(p_instance_id Number) RETURN VARCHAR2 IS
  l_unit_name VARCHAR2(80);
  l_instance_id    NUMBER;
  CURSOR get_uc_instance_id IS
    SELECT object_id
      FROM csi_ii_relationships
     WHERE object_id IN (SELECT csi_item_instance_id
                           FROM ahl_unit_config_headers
                          WHERE trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE))
START WITH subject_id = p_instance_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY subject_id = PRIOR object_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  CURSOR get_uc_header_name(c_instance_id NUMBER) IS
    SELECT name
      FROM ahl_unit_config_headers
     WHERE csi_item_instance_id = c_instance_id
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

BEGIN
  OPEN get_uc_instance_id;
  LOOP
    FETCH get_uc_instance_id INTO l_instance_id;
    EXIT when get_uc_instance_id%NOTFOUND;
  END LOOP;
  CLOSE get_uc_instance_id;

  IF l_instance_id IS NULL THEN
    l_instance_id := p_instance_id;
  END IF;
  OPEN get_uc_header_name(l_instance_id);
  FETCH get_uc_header_name INTO l_unit_name;
  CLOSE get_uc_header_name;
  RETURN l_unit_name;
END;

--======================================================================
-- FUNCTION
--    Is_Org_In_User_Ou
--
-- PURPOSE
--    Created to check if the Organization is in users operating unit or not.
--    Returns FND_API.G_TRUE if the org belongs to user's operating unit
--    Returns FND_API.G_FALSE if the org doesnt belong to user's operating unit
--    Returns 'X' on error.
--======================================================================
-- Function added for transit check.
FUNCTION IS_ORG_IN_USER_OU
(
p_org_id        IN          NUMBER,
p_org_name      IN          VARCHAR2,
x_return_status OUT NOCOPY  VARCHAR2,
x_msg_data  OUT NOCOPY  VARCHAR2
)
RETURN VARCHAR2
IS

-- Cursor for getting organization id out of org name
CURSOR get_org_id_csr(p_org_name IN VARCHAR2)
IS
SELECT hou.organization_id
FROM HR_ORGANIZATION_UNITS hou
WHERE hou.name = p_org_name;

--Cursor for checking if the given organization belongs to user's OU.
-- SATHAPLI::Bug# 5246136 fix
-- Changed reference of ORG_ORGANIZATION_DEFINITIONS to INV_ORGANIZATION_INFO_V
CURSOR is_user_in_ou_csr(p_org_id IN NUMBER)
IS
SELECT hou.organization_id
FROM HR_ORGANIZATION_UNITS hou,
MTL_PARAMETERS mtl
WHERE
hou.organization_id IN (
                SELECT organization_id
                FROM INV_ORGANIZATION_INFO_V

                WHERE NVL(operating_unit, mo_global.get_current_org_id()) =
                                      mo_global.get_current_org_id()

                   )
AND mtl.organization_id = hou.organization_id
AND mtl.eam_enabled_flag = 'Y'
AND hou.organization_id = p_org_id;

l_org_id NUMBER;
l_ou_org_id NUMBER;

BEGIN
    --Initialize return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_org_id IS NULL AND
       p_org_name IS NULL
    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_data  := 'AHL_UA_ORG_INFO_NULL';
        RETURN 'X';
    END IF;

    l_org_id  := p_org_id;
    IF p_org_id IS NULL THEN
        OPEN get_org_id_csr(p_org_name);
        FETCH get_org_id_csr INTO l_org_id;
        CLOSE get_org_id_csr;
    END IF;

    -- operating unit check
    IF l_org_id IS NOT NULL
    THEN
        OPEN is_user_in_ou_csr(l_org_id);
        FETCH is_user_in_ou_csr INTO l_ou_org_id;
        CLOSE is_user_in_ou_csr;
        IF l_ou_org_id IS NOT NULL
        THEN
            RETURN FND_API.G_TRUE;
        ELSE
            RETURN FND_API.G_FALSE;
        END IF;
    ELSE
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_data  := 'AHL_UA_ORG_INFO_NULL';
        RETURN 'X';
    END IF;

END IS_ORG_IN_USER_OU;

--======================================================================
-- FUNCTION
--    GET_LOOKUP_MEANING
--
-- PURPOSE
--    Return fnd_lookup_values_vl.meaning, given lookup_type and lookup_code.
--    This function will either return the correct meaning, or return null.
--    This function also will not raise any error.
--======================================================================
FUNCTION GET_LOOKUP_MEANING
(
    p_lookup_type   IN  VARCHAR2,
    p_lookup_code   IN  VARCHAR2
)
RETURN VARCHAR2
IS
    l_meaning   VARCHAR2(80);

    CURSOR get_meaning
    IS
        SELECT meaning
        FROM fnd_lookup_values
        WHERE lookup_type = p_lookup_type
        AND lookup_code = p_lookup_code
        AND language = userenv('LANG');
BEGIN
    OPEN get_meaning;
    FETCH get_meaning INTO l_meaning;
    CLOSE get_meaning;

    RETURN l_meaning;
END GET_LOOKUP_MEANING;

END Ahl_Utility_Pvt;


/
