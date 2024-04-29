--------------------------------------------------------
--  DDL for Package Body CSM_EMAIL_QUERY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_EMAIL_QUERY_PKG" AS
/* $Header: csmeqpb.pls 120.0.12010000.28 2010/07/07 19:39:37 rsripada noship $ */


  /*
   * The function to be called by Process Email Mobile Queries concurrent program
   */

-- Purpose: Per-seeded queries and to execute them
--
-- MODIFICATION HISTORY
-- Person      Date                 Comments
-- RAVIR    22 April 2010         Created
--
-- ---------   -------------------  ------------------------------------------

  /*** Globals ***/
  g_object_name  CONSTANT VARCHAR2(30) := 'CSM_EMAIL_QUERY_PKG';  -- package name
  g_user_id               NUMBER;
  g_user_name             VARCHAR2(240);

  /*Function to get FND_USER for the email address
    If there is a unique valid user associated to this email address
      return: USER_ID else return -1
  */
  FUNCTION IS_FND_USER
  ( p_email_id VARCHAR2)
  RETURN NUMBER
  IS

  CURSOR c_fnd_user(p_email_id VARCHAR2) IS
    SELECT user_id, count(*) over () row_count
      FROM fnd_user
    WHERE UPPER(email_address) = p_email_id
      AND start_date <= sysdate
      AND(end_date IS NULL OR end_date > sysdate);

  l_fnd_user_id NUMBER;
  l_count       NUMBER;

  BEGIN
    l_fnd_user_id := -1;
    CSM_UTIL_PKG.LOG('Entering IS_FND_USER: ' || p_email_id, g_object_name, FND_LOG.LEVEL_PROCEDURE);

    OPEN c_fnd_user(UPPER(p_email_id));
    FETCH c_fnd_user INTO l_fnd_user_id, l_count;
    CLOSE c_fnd_user;

    IF l_count > 1 THEN
       CSM_UTIL_PKG.LOG('EMAIL_ID: ' || p_email_id || ' is associated to more than one users',  g_object_name, FND_LOG.LEVEL_PROCEDURE);
      l_fnd_user_id := -1;
    ELSE
      SELECT user_name INTO g_user_name
        FROM  FND_USER
      WHERE  user_id = l_fnd_user_id;
    END IF;

    CSM_UTIL_PKG.LOG('Leaving IS_FND_USER: ' || l_fnd_user_id, g_object_name, FND_LOG.LEVEL_PROCEDURE);
    RETURN l_fnd_user_id;

  END IS_FND_USER;

  FUNCTION GET_EMAIL_PREF
  ( p_email_id VARCHAR2)
  RETURN VARCHAR2

  IS
  l_user_id       NUMBER;
  l_email_format  VARCHAR2(240);
  l_fnd_user_name VARCHAR2(240);

  BEGIN

    CSM_UTIL_PKG.LOG('Entering GET_EMAIL_PREF email_id: ' || p_email_id, g_object_name, FND_LOG.LEVEL_PROCEDURE);
    l_user_id := IS_FND_USER(p_email_id);

    IF l_user_id = -1 THEN
      l_email_format := 'MAILHTM2';
      CSM_UTIL_PKG.LOG('Not a valid FND_USER will use default: ' || l_email_format, g_object_name, FND_LOG.LEVEL_PROCEDURE);
    ELSE
      CSM_UTIL_PKG.LOG('A valid FND_USER name : ' || g_user_name, g_object_name, FND_LOG.LEVEL_PROCEDURE);
      l_email_format := fnd_preference.get(g_user_name,'WF','MAILTYPE');
    END IF;

    CSM_UTIL_PKG.LOG('Entering GET_EMAIL_PREF format: ' || l_email_format, g_object_name, FND_LOG.LEVEL_PROCEDURE);
    RETURN l_email_format;

  END GET_EMAIL_PREF;

  FUNCTION CHECK_USER_ACCESS
  ( p_user_id     NUMBER,
    p_level_id    NUMBER,
    p_level_value NUMBER)
  RETURN VARCHAR2
  IS

  CURSOR c_user_resp(p_user_id NUMBER, p_resp_id NUMBER) IS
  SELECT resp.responsibility_id
  FROM fnd_user usr,
    fnd_user_resp_groups resp
  WHERE usr.user_id = p_user_id
    AND resp.responsibility_id = p_resp_id
    AND usr.user_id = resp.user_id
    AND resp.start_date <= sysdate
    AND(resp.end_date IS NULL OR resp.end_date  >= sysdate);

  CURSOR c_mobile_user_resp(p_user_id NUMBER) IS
  SELECT resp.responsibility_id
  FROM fnd_user usr,
    fnd_user_resp_groups resp,
    asg_responsibility_vl mresp
  WHERE usr.user_id = p_user_id
    AND resp.responsibility_id = mresp.responsibility_id
    AND usr.user_id = resp.user_id
    AND resp.start_date <= sysdate
    AND(resp.end_date IS NULL OR resp.end_date  >= sysdate);

  l_responsibility_id   NUMBER;
  l_is_user_access      VARCHAR2(1);

  BEGIN
    CSM_UTIL_PKG.LOG('Entering CHECK_USER_ACCESS user_id: ' || p_user_id, g_object_name, FND_LOG.LEVEL_PROCEDURE);
    l_is_user_access := 'N';
    l_responsibility_id := -1;

    IF p_level_id = 10003 THEN
      OPEN c_user_resp(p_user_id, p_level_value);
      FETCH c_user_resp INTO l_responsibility_id;
      CLOSE c_user_resp;
    ELSIF p_level_id = 10001 THEN
      OPEN c_mobile_user_resp(p_user_id);
      FETCH c_mobile_user_resp INTO l_responsibility_id;
      CLOSE c_mobile_user_resp;
    END IF;

    IF l_responsibility_id > 0 THEN
      l_is_user_access := 'Y';
      CSM_UTIL_PKG.LOG('USER_ID: ' || p_user_id || ' have access to responsibility_id :' || p_level_value, g_object_name, FND_LOG.LEVEL_PROCEDURE);
    ELSE
      CSM_UTIL_PKG.LOG('USER_ID: ' || p_user_id || ' does not have access to responsibility_id: ' || p_level_value, g_object_name, FND_LOG.LEVEL_PROCEDURE);
    END IF;

    CSM_UTIL_PKG.LOG('Leaving CHECK_USER_ACCESS: ' || l_is_user_access, g_object_name, FND_LOG.LEVEL_PROCEDURE);

    RETURN l_is_user_access;

  END CHECK_USER_ACCESS;

  FUNCTION CHECK_TASK_ACCESS
  ( p_user_id       NUMBER,
    p_task_number   NUMBER)
  RETURN VARCHAR2
  IS

  CURSOR c_task_assignment( p_user_id NUMBER, p_task_number NUMBER)
  IS
   SELECT count(*) over () row_count
   FROM   jtf_task_assignments jta,
          jtf_tasks_b   jtb,
          jtf_rs_resource_extns res
   WHERE  res.user_id = p_user_id
    AND   jtb.task_number = p_task_number
    AND   jtb.task_id = jta.task_id
    AND   jta.resource_id = res.resource_id;

  l_task_access_flag  VARCHAR2(1);
  l_count       NUMBER;
  BEGIN
    l_task_access_flag := 'N';
    CSM_UTIL_PKG.LOG( 'Entering CHECK_TASK_ACCESS for USER_ID : ' || p_user_id ||' and TASK_NUMBER: ' || p_task_number, g_object_name, FND_LOG.LEVEL_PROCEDURE);

    OPEN c_task_assignment(p_user_id, p_task_number);
    FETCH c_task_assignment INTO l_count;
    CLOSE c_task_assignment;

    IF l_count > 0 THEN
      l_task_access_flag := 'Y';
    END IF;

    CSM_UTIL_PKG.LOG( 'Leaving CHECK_TASK_ACCESS for USER_ID : ' || p_user_id ||' and TASK_NUMBER: ' || p_task_number, g_object_name, FND_LOG.LEVEL_PROCEDURE);

    RETURN l_task_access_flag;

  END CHECK_TASK_ACCESS;

  PROCEDURE EXECUTE_COMMAND
  ( p_email_id            IN VARCHAR2,
    p_command_name        IN VARCHAR2,
    p_var_value_lst       IN CSM_VARCHAR_LIST,
    p_instance_id         OUT nocopy NUMBER,
    x_return_status       OUT nocopy VARCHAR2,
    x_error_message       OUT nocopy VARCHAR2
  )
  AS

  CURSOR c_get_query_id(p_command_name VARCHAR2)
  IS
  SELECT QUERY_ID,
         RESTRICTED_FLAG,
         DISABLED_FLAG,
         LEVEL_ID,
         LEVEL_VALUE
  FROM   CSM_QUERY_B
  WHERE  UPPER(QUERY_NAME) = p_command_name
  AND    NVL(DELETE_FLAG,'N') = 'N';

  CURSOR c_get_variables (p_query_id NUMBER)
  IS
  SELECT  variable_id,
    variable_value_char,
    variable_value_date
  FROM  CSM_QUERY_VARIABLES_B
  WHERE QUERY_ID = p_query_id;

  l_command_name        VARCHAR2(240);
  l_query_id            NUMBER;
  l_restricted_flag     VARCHAR2(1);
  l_disabled_flag       VARCHAR2(1);
  l_access_flag         VARCHAR2(1);
  l_level_id            NUMBER;
  l_level_value         NUMBER;
  l_instance_id         NUMBER;
  j                     NUMBER;
  l_variable_id_lst     CSM_INTEGER_LIST;
  l_var_value_char_lst  CSM_VARCHAR_LIST;
  l_var_value_date_lst  CSM_DATE_LIST;
  l_var_type_lst        CSM_VARCHAR_LIST;
  l_var_value_lst       CSM_VARCHAR_LIST;

  BEGIN
    CSM_UTIL_PKG.LOG( 'Entering EXECUTE_COMMAND for EMAIL_ID : ' || p_email_id ||' and COMMAND_NAME: ' || p_command_name, g_object_name, FND_LOG.LEVEL_PROCEDURE);

    IF p_email_id IS NULL OR p_command_name IS NULL THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message := 'Email address : ' || p_email_id || ' or Command Name: ' || p_command_name || 'cannot be blank';
      CSM_UTIL_PKG.LOG(x_error_message, g_object_name, FND_LOG.LEVEL_PROCEDURE);
      RETURN;
    END IF;

    l_command_name := UPPER(TRIM(p_command_name));

    OPEN   c_get_query_id (l_command_name);
    FETCH  c_get_query_id INTO l_query_id, l_restricted_flag, l_disabled_flag, l_level_id, l_level_value;
    CLOSE  c_get_query_id;
    IF l_query_id IS NULL THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message := 'Error: Invalid Query Name: '||  l_command_name;
      CSM_UTIL_PKG.LOG(x_error_message, g_object_name, FND_LOG.LEVEL_PROCEDURE);
      RETURN;
    END IF;

    IF l_disabled_flag = 'Y' THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message := 'Query Name: '||  l_command_name || ' is disabled.';
      CSM_UTIL_PKG.LOG(x_error_message, g_object_name, FND_LOG.LEVEL_PROCEDURE);
      RETURN;
    END IF;

    IF l_restricted_flag = 'Y'  THEN
      g_user_id := IS_FND_USER(p_email_id);
      IF g_user_id = -1 THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_error_message := 'Invalid FND_USER for EMAIL_ID: ' || p_email_id;
        CSM_UTIL_PKG.LOG(x_error_message, g_object_name, FND_LOG.LEVEL_PROCEDURE);
        RETURN;
      END IF;

      CSM_UTIL_PKG.LOG('EMAIL_ID: ' || p_email_id || ' associated to FND_USER_ID: ' || g_user_id, g_object_name, FND_LOG.LEVEL_PROCEDURE);

      l_access_flag := CHECK_USER_ACCESS(g_user_id,l_level_id, l_level_value);
      IF l_access_flag = 'N' THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_error_message := 'User: '||  g_user_name  ||' does not have access to execute mobile query: ' || l_command_name;
        CSM_UTIL_PKG.LOG(x_error_message, g_object_name, FND_LOG.LEVEL_PROCEDURE);
        RETURN;
      END IF;
    END IF;

    OPEN  c_get_variables (l_query_id);
    FETCH c_get_variables BULK COLLECT INTO l_variable_id_lst, l_var_value_char_lst, l_var_value_date_lst;
    CLOSE c_get_variables;

    -- Merge Actual parameter passed and Default query parameter
    -- Assuming no Date parames are passed.
    IF p_var_value_lst.count = l_variable_id_lst.count THEN
      l_var_value_lst := p_var_value_lst;
    ELSE
      l_var_value_lst := CSM_VARCHAR_LIST();
      j := 1;
      FOR i IN 1 .. l_variable_id_lst.count LOOP
        l_var_value_lst.extend(1);
        IF l_var_value_char_lst(i) IS NULL THEN
          l_var_value_lst(i) := p_var_value_lst(j);
          j := j + 1;
        ELSE
          l_var_value_lst(i) := l_var_value_char_lst(i);
        END IF;
      END LOOP;
    END IF;

    CSM_QUERY_PKG.INSERT_INSTANCE
    ( p_USER_ID              => g_user_id,
      p_QUERY_ID             => l_query_id,
      p_INSTANCE_ID          => NULL,
      p_INSTANCE_NAME        => NULL,
      p_VARIABLE_ID          => l_variable_id_lst,
      p_VARIABLE_VALUE_CHAR  => l_var_value_lst,
      p_VARIABLE_VALUE_DATE  => l_var_value_date_lst,
      p_commit               => fnd_api.G_TRUE,
      x_INSTANCE_ID          => p_instance_id,
      x_return_status        => x_return_status,
      x_error_message        => x_error_message
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message := 'Error in EXECUTE_COMMAND :'
          || ' ROOT ERROR: CSM_QUERY_PKG.INSERT_INSTANCE '
          || ' for QUERY_ID ' || l_query_id || ' Detail: ' || x_error_message;
      CSM_UTIL_PKG.LOG( x_error_message, g_object_name, FND_LOG.LEVEL_ERROR);
      RETURN ;
    END IF;

    CSM_QUERY_PKG.EXECUTE_QUERY(
      p_USER_ID              => g_user_id,
      p_QUERY_ID             => l_query_id,
      p_INSTANCE_ID          => p_instance_id,
      x_return_status        => x_return_status,
      x_error_message        => x_error_message,
      p_commit               => fnd_api.G_TRUE,
      p_source_module        => 'EMAIL');

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message := 'Error in EXECUTE_COMMAND :'
          || ' ROOT ERROR: CSM_QUERY_PKG.EXECUTE_QUERY '
          || ' for INSTANCE_ID ' || l_query_id || ' Detail: ' || x_error_message;
      CSM_UTIL_PKG.LOG( x_error_message, g_object_name, FND_LOG.LEVEL_ERROR);
      RETURN ;
    END IF;

    UPDATE csm_query_results_acc
      SET user_email_id = p_email_id
    WHERE instance_id = p_instance_id;
    COMMIT;

    CSM_UTIL_PKG.LOG( 'Leaving EXECUTE_COMMAND for EMAIL_ID : ' || p_email_id ||' and COMMAND_NAME: ' || p_command_name,g_object_name, FND_LOG.LEVEL_PROCEDURE);

  EXCEPTION
  WHEN others THEN
    x_return_status := fnd_api.g_ret_sts_error;
    x_error_message := 'Exception occurred in EXECUTE_COMMAND for Query Id : ' || sqlerrm;
    CSM_UTIL_PKG.LOG(x_error_message,g_object_name, FND_LOG.LEVEL_EXCEPTION);
  END EXECUTE_COMMAND;

  /**/
  PROCEDURE GET_TASKS
  ( p_email_id      IN VARCHAR2,
    p_result        OUT nocopy   CLOB,
    x_return_status OUT nocopy VARCHAR2,
    x_error_message OUT nocopy VARCHAR2
  )
  AS

  CURSOR c_groups(p_user_id NUMBER)
  IS
    SELECT gb.group_id,
    gtl.group_name
  FROM jtf_rs_resource_extns rs,
    jtf_rs_groups_b gb,
    jtf_rs_groups_tl gtl,
    jtf_rs_group_members gm,
    jtf_rs_roles_b rb,
    jtf_rs_role_relations rr_grp,
    jtf_rs_role_relations rr_res
  WHERE rs.user_id = p_user_id
   AND gm.resource_id = rs.resource_id
   AND gm.delete_flag = 'N'
   AND gm.group_id = gb.group_id
   AND gb.start_date_active <= sysdate
   AND(gb.end_date_active IS NULL OR gb.end_date_active >= sysdate)
   AND gtl.group_id = gb.group_id
   AND gtl.LANGUAGE = userenv('LANG')
   AND rr_grp.role_resource_type = 'RS_GROUP_MEMBER'
   AND rr_grp.role_resource_id = gm.group_member_id
   AND rr_grp.delete_flag = 'N'
   AND rr_grp.role_id = rb.role_id
   AND rr_grp.start_date_active <= sysdate
   AND(rr_grp.end_date_active IS NULL OR rr_grp.end_date_active >= sysdate)
   AND rr_res.role_resource_type = 'RS_INDIVIDUAL'
   AND rr_res.role_resource_id = gm.resource_id
   AND rr_res.delete_flag = 'N'
   AND rr_res.role_id = rb.role_id
   AND rr_res.start_date_active <= sysdate
   AND(rr_res.end_date_active IS NULL OR rr_res.end_date_active >= sysdate)
   AND rb.admin_flag = 'Y';

  CURSOR c_group_members(p_group_id NUMBER)
  IS
    SELECT fusr.user_id
    FROM fnd_user fusr,
      jtf_rs_resource_extns rs,
      jtf_rs_groups_b gb,
      jtf_rs_group_members gm,
      jtf_rs_roles_b rb,
      jtf_rs_role_relations rr_grp,
      jtf_rs_role_relations rr_res
    WHERE gb.group_id = p_group_id
     AND gb.start_date_active <= sysdate
     AND(gb.end_date_active IS NULL OR gb.end_date_active >= sysdate)
     AND gm.group_id = gb.group_id
     AND gm.delete_flag = 'N'
     AND rs.resource_id = gm.resource_id
     AND rs.start_date_active <= sysdate
     AND(rs.end_date_active IS NULL OR rs.end_date_active >= sysdate)
     AND fusr.user_id = rs.user_id
     AND fusr.start_date <= sysdate
     AND(fusr.end_date IS NULL OR fusr.end_date >= sysdate)
     AND rr_grp.role_resource_id = gm.group_member_id
     AND rr_grp.delete_flag = 'N'
     AND rr_grp.role_resource_type = 'RS_GROUP_MEMBER'
     AND rr_grp.start_date_active <= sysdate
     AND(rr_grp.end_date_active IS NULL OR rr_grp.end_date_active >= sysdate)
     AND rr_grp.role_id = rb.role_id
     AND rr_res.role_resource_id = gm.resource_id
     AND rr_res.role_resource_type = 'RS_INDIVIDUAL'
     AND rr_res.delete_flag = 'N'
     AND rr_res.start_date_active <= sysdate
     AND(rr_res.end_date_active IS NULL OR rr_res.end_date_active >= sysdate)
     AND rr_res.role_id = rb.role_id;


  l_query_text      VARCHAR2(32767);
  qrycontext        DBMS_XMLGEN.ctxHandle;
  l_user_id         NUMBER;
  l_group_id        NUMBER;
  r_groups          c_groups%ROWTYPE;
  r_group_members   c_group_members%ROWTYPE;
  l_user_lst        VARCHAR2(32767);
  l_str_length      NUMBER;
  i                 NUMBER;
  l_is_sender_admin BOOLEAN;
  l_is_user_member  BOOLEAN;

  BEGIN

    CSM_UTIL_PKG.LOG('Entering GET_TASKS for EMAIL_ID: ' || p_email_id, g_object_name, FND_LOG.LEVEL_PROCEDURE);

    l_user_id := IS_FND_USER(p_email_id);

    IF l_user_id = -1 THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message := 'Invalid user for EMAIL_ID: ' || p_email_id;
      CSM_UTIL_PKG.LOG(x_error_message, g_object_name, FND_LOG.LEVEL_PROCEDURE);
      RETURN;
    END IF;

    -- g_user_id is Sender
    -- l_user_id is User whose task to be queried.
    -- No email param: A-A, M-M
    -- Has Email param: A-A, M-M, A-A1, M-M1, A-M1, M-A1
    l_user_lst := '(';
    IF l_user_id = g_user_id THEN
      -- Default, Same user, either no email mentioned or sender's email mentioned.
      -- No email param: A-A, M-M
      -- Has Email param: A-A, M-M
      i := 0;
      FOR r_groups IN c_groups(g_user_id) LOOP
        -- A-A: Sender is Group Administrator
        CSM_UTIL_PKG.LOG('Default: Sender is a Group Administrator in group: ' || r_groups.group_name, g_object_name, FND_LOG.LEVEL_PROCEDURE);
        FOR r_group_members IN c_group_members(r_groups.group_id) LOOP
          l_user_lst := l_user_lst || r_group_members.user_id || ',';
          i := i + 1;
        END LOOP;
      END LOOP;

      IF i = 0 THEN
        -- M-M: Sender is Group Member or didnot found any member
        l_user_lst := l_user_lst || g_user_id || ',';
        i := i + 1;
      END IF;
    ELSE
      -- Different email is mentioned
      -- Has Email param:  M-M1, A-M1, M-A1, A-A1
      OPEN c_groups(g_user_id);
      FETCH c_groups INTO r_groups;
      CLOSE c_groups;

      IF r_groups.group_id IS NULL THEN
        l_is_sender_admin := FALSE;
      ELSE
        l_is_sender_admin := TRUE;
      END IF;

      r_groups := NULL;

      OPEN c_groups(l_user_id);
      FETCH c_groups INTO r_groups;
      CLOSE c_groups;

      IF r_groups.group_id IS NULL THEN
        l_is_user_member := TRUE;
      ELSE
        l_is_user_member := FALSE;
      END IF;

      IF l_is_user_member THEN
        -- M-M1 or A-M1
        IF l_is_sender_admin THEN
          --A-M1
          i := 0;
          FOR r_groups IN c_groups(g_user_id) LOOP
            -- A-M1; If member M1 belongs to same group of A, add to user list
            CSM_UTIL_PKG.LOG('Has Email ID: Sender is a Group Administrator in group: ' || r_groups.group_name, g_object_name, FND_LOG.LEVEL_PROCEDURE);
            FOR r_group_members IN c_group_members(r_groups.group_id) LOOP
              IF l_user_id = r_group_members.user_id THEN
                CSM_UTIL_PKG.LOG('Has Email ID: Sender and User belong to same group: ' || r_groups.group_name, g_object_name, FND_LOG.LEVEL_PROCEDURE);
                l_user_lst := l_user_lst || r_group_members.user_id || ',';
                i := i + 1;
              END IF;
            END LOOP;
          END LOOP;
          IF i=0 THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_error_message := 'User: '|| g_user_name ||' doesnot belong to same group.';
            CSM_UTIL_PKG.LOG(x_error_message, g_object_name, FND_LOG.LEVEL_PROCEDURE);
            RETURN;
          END IF;
        ELSE
          -- M-M1
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message := 'A group member cannot query for another group member.';
          CSM_UTIL_PKG.LOG(x_error_message, g_object_name, FND_LOG.LEVEL_PROCEDURE);
          RETURN;
        END IF;
      ELSE
        --M-A1 or A-A1
        IF l_is_sender_admin THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message := 'Group administrator cannot query for another group administator';
          CSM_UTIL_PKG.LOG(x_error_message, g_object_name, FND_LOG.LEVEL_PROCEDURE);
          RETURN;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message := 'Group member cannot query for group administator.';
          CSM_UTIL_PKG.LOG(x_error_message, g_object_name, FND_LOG.LEVEL_PROCEDURE);
          RETURN;
        END IF;
      END IF;
    END IF;

    l_str_length := LENGTH(l_user_lst);
    l_user_lst := SUBSTR(l_user_lst, 1, l_str_length - 1) || ')';

    CSM_UTIL_PKG.LOG('Query for task for Users: ' || l_user_lst, g_object_name, FND_LOG.LEVEL_PROCEDURE);

    l_query_text := ' SELECT cia.incident_number service_request,
      hzp.party_name customer,
      res.source_name assignee,
      ct.task_number task_number,
      ctl.task_name as subject,
      jtstl.name task_status,
      to_char(ct.scheduled_start_date, ''YYYY-MM-DD HH24:MI:SS'') scheduled_start_date,
      to_char(ct.scheduled_end_date,  ''YYYY-MM-DD HH24:MI:SS'') scheduled_end_date
  FROM  jtf_rs_resource_extns res,
        jtf_task_assignments a,
        jtf_tasks_b ct,
        jtf_tasks_tl ctl,
        cs_incidents_all_b cia,
        hz_parties hzp,
        jtf_task_statuses_b jts,
        jtf_task_statuses_tl jtstl
    WHERE  res.user_id IN '|| l_user_lst || '
     AND a.resource_id = res.resource_id
     AND ct.task_id = a.task_id
     AND ct.open_flag = ''Y''
     AND ct.source_object_type_code = ''SR''
     AND ct.scheduled_start_date IS NOT NULL
     AND ct.scheduled_end_date IS NOT NULL
     AND ct.source_object_id = cia.incident_id
     AND cia.customer_id = hzp.party_id
     AND ctl.task_id = ct.task_id
     AND ct.task_status_id = jts.task_status_id
     AND ctl.LANGUAGE = USERENV(''LANG'')
     AND jts.assigned_flag = ''Y''
     AND nvl(jts.COMPLETED_FLAG,''N'') = ''N''
     AND nvl(jts.CANCELLED_FLAG,''N'') = ''N''
     AND nvl(jts.CLOSED_FLAG,''N'')    = ''N''
     AND nvl(jts.REJECTED_FLAG,''N'') = ''N''
     AND jtstl.task_status_id = jts.task_status_id
     AND jtstl.LANGUAGE = USERENV(''LANG'')
     ORDER BY task_number ';

    qrycontext := DBMS_XMLGEN.newcontext(l_query_text) ;
    DBMS_XMLGEN.setnullhandling (qrycontext, DBMS_XMLGEN.empty_tag);
    p_result := DBMS_XMLGEN.getxml (qrycontext);

    CSM_UTIL_PKG.LOG('Leaving GET_TASKS for EMAIL Id: ' || p_email_id, g_object_name, FND_LOG.LEVEL_PROCEDURE);

  EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_error_message := 'Exception occurred in GET_TASKS: ' || sqlerrm;
    CSM_UTIL_PKG.LOG(x_error_message, g_object_name, FND_LOG.LEVEL_EXCEPTION);

  END GET_TASKS;

  PROCEDURE UPDATE_TASK
  ( p_task_number     IN NUMBER,
    p_task_status_id  IN VARCHAR2,
    p_result          OUT nocopy  CLOB,
    x_return_status   OUT nocopy VARCHAR2,
    x_error_message   OUT nocopy VARCHAR2
  )
  AS

  CURSOR c_task_assignments(p_task_number NUMBER, p_user_id NUMBER)
  IS
   SELECT jta.task_id,
          jta.object_version_number,
          jta.last_update_date,
          jta.last_updated_by,
          jta.task_assignment_id,
          jta.assignment_status_id
   FROM   jtf_task_assignments jta,
          jtf_tasks_b   jtb,
          jtf_rs_resource_extns res
   WHERE  jtb.task_number = p_task_number
    AND   jtb.task_id = jta.task_id
    AND   res.user_id = p_user_id
    AND   res.resource_id = jta.resource_id;

  r_task_assignments      c_task_assignments%ROWTYPE;

  l_task_access_flag      VARCHAR2(1);
  l_task_assignment_id    NUMBER;
  l_assignment_status_id  NUMBER;

  -- Declare OUT parameters
  l_task_object_version_number NUMBER;
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(4000);
  l_task_status_id    NUMBER;
  l_task_status_name  VARCHAR2(240);
  l_task_type_id      NUMBER;

  BEGIN
    CSM_UTIL_PKG.LOG('Entering UPDATE_TASK for TASK_NUMBER: ' || p_task_number || ' STATUS_ID is : ' || p_task_status_id, g_object_name, FND_LOG.LEVEL_PROCEDURE);

    l_task_access_flag := CHECK_TASK_ACCESS(g_user_id, p_task_number);

    IF l_task_access_flag = 'N' THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message := 'Task Number: ' || p_task_number || ' has no assignment for user: ' || g_user_name;
      CSM_UTIL_PKG.LOG( x_error_message, g_object_name, FND_LOG.LEVEL_PROCEDURE);
      RETURN;
    END IF;

    FOR r_task_assignments IN c_task_assignments(p_task_number, g_user_id) LOOP

      csf_task_assignments_pub.update_assignment_status
        ( p_api_version                => 1.0
        , p_init_msg_list              => FND_API.G_TRUE
        , p_commit                     => FND_API.G_TRUE
        , p_validation_level           => FND_API.G_VALID_LEVEL_NONE
        , x_return_status              => x_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_task_assignment_id         => r_task_assignments.task_assignment_id
        , p_assignment_status_id       => p_task_status_id
        , p_object_version_number      => r_task_assignments.object_version_number
        , p_update_task                => 'T'
        , x_task_object_version_number => l_task_object_version_number
        , x_task_status_id             => l_task_status_id
        );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_error_message := 'Error in UPDATE_TASK :'
            || ' ROOT ERROR: csf_task_assignments_pub.update_assignment_status'
            || ' for PK : ' || r_task_assignments.task_assignment_id
            || ' Details:' || l_msg_data;
        CSM_UTIL_PKG.LOG( x_error_message, g_object_name, FND_LOG.LEVEL_ERROR);
        RETURN ;
      END IF;
    END LOOP;

    p_result := EMPTY_CLOB();

    CSM_UTIL_PKG.LOG('Leaving UPDATE_TASK for TASK_NUMBER: ' || p_task_number, g_object_name, FND_LOG.LEVEL_PROCEDURE);

  EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_error_message := 'Exception occurred in UPDATE_TASK: ' || sqlerrm;
    CSM_UTIL_PKG.LOG(x_error_message, g_object_name, FND_LOG.LEVEL_EXCEPTION);

  END UPDATE_TASK;

  PROCEDURE ACCEPT_TASK
  ( p_task_number   IN NUMBER,
    p_result        OUT nocopy  CLOB,
    x_return_status OUT nocopy VARCHAR2,
    x_error_message OUT nocopy VARCHAR2
  )
  AS
  l_profile_value         NUMBER;
  BEGIN

    CSM_UTIL_PKG.LOG('Entering ACCEPT_TASK for TASK_NUMBER: ' || p_task_number, g_object_name, FND_LOG.LEVEL_PROCEDURE);
    l_profile_value := TO_NUMBER(fnd_profile.value('CSF_DEFAULT_ACCEPTED_STATUS'));

    UPDATE_TASK
    ( p_task_number     => p_task_number,
      p_task_status_id  => l_profile_value,
      p_result          => p_result,
      x_return_status   => x_return_status,
      x_error_message   => x_error_message);

    CSM_UTIL_PKG.LOG('Leaving ACCEPT_TASK for TASK_NUMBER: ' || p_task_number, g_object_name, FND_LOG.LEVEL_PROCEDURE);

  EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_error_message := 'Exception occurred in ACCEPT_TASK: ' || sqlerrm;
    CSM_UTIL_PKG.LOG(x_error_message, g_object_name, FND_LOG.LEVEL_EXCEPTION);

  END ACCEPT_TASK;

  PROCEDURE CANCEL_TASK
  ( p_task_number   IN NUMBER,
    p_result        OUT nocopy  CLOB,
    x_return_status OUT nocopy VARCHAR2,
    x_error_message OUT nocopy VARCHAR2
  )
  AS
  l_profile_value         NUMBER;
  BEGIN

    CSM_UTIL_PKG.LOG('Entering CANCEL_TASK for TASK_NUMBER: ' || p_task_number, g_object_name, FND_LOG.LEVEL_PROCEDURE);
    l_profile_value := TO_NUMBER(fnd_profile.value('CSF_DEFAULT_TASK_CANCELLED_STATUS'));

    UPDATE_TASK
    ( p_task_number     => p_task_number,
      p_task_status_id  => l_profile_value,
      p_result          => p_result,
      x_return_status   => x_return_status,
      x_error_message   => x_error_message);

    CSM_UTIL_PKG.LOG('Leaving CANCEL_TASK for TASK_NUMBER: ' || p_task_number, g_object_name, FND_LOG.LEVEL_PROCEDURE);

  EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_error_message := 'Exception occurred in CANCEL_TASK: ' || sqlerrm;
    CSM_UTIL_PKG.LOG(x_error_message, g_object_name, FND_LOG.LEVEL_EXCEPTION);

  END CANCEL_TASK;

  PROCEDURE CLOSE_TASK
  ( p_task_number   IN NUMBER,
    p_result        OUT nocopy  CLOB,
    x_return_status OUT nocopy VARCHAR2,
    x_error_message OUT nocopy VARCHAR2
  )
  AS
  l_profile_value         NUMBER;
  BEGIN

    CSM_UTIL_PKG.LOG('Entering CLOSE_TASK for TASK_NUMBER: ' || p_task_number, g_object_name, FND_LOG.LEVEL_PROCEDURE);

    l_profile_value := TO_NUMBER(fnd_profile.value('CSF_DFLT_AUTO_CLOSE_TASK_STATUS'));

    UPDATE_TASK
    ( p_task_number     => p_task_number,
      p_task_status_id  => l_profile_value,
      p_result          => p_result,
      x_return_status   => x_return_status,
      x_error_message   => x_error_message);

    CSM_UTIL_PKG.LOG('Leaving CLOSE_TASK for TASK_NUMBER: ' || p_task_number, g_object_name, FND_LOG.LEVEL_PROCEDURE);

  EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_error_message := 'Exception occurred in CLOSE_TASK: ' || sqlerrm;
    CSM_UTIL_PKG.LOG(x_error_message, g_object_name, FND_LOG.LEVEL_EXCEPTION);

  END CLOSE_TASK;

  /*Procedure to update task statu to Travelling*/
  PROCEDURE TRAVELING_TASK
  ( p_task_number     IN NUMBER,
    p_default_status  IN VARCHAR2,
    p_result        OUT nocopy  CLOB,
    x_return_status OUT nocopy VARCHAR2,
    x_error_message OUT nocopy VARCHAR2
  )
  AS
  CURSOR c_task_status(p_default_status VARCHAR2)
  IS
   SELECT tsb.task_status_id
   FROM   jtf_task_statuses_b tsb,
          jtf_task_statuses_tl tstl
   WHERE  tstl.name = p_default_status
    AND   tstl.language = userenv('LANG')
    AND   tsb.task_status_id = tstl.task_status_id;

  l_status_id         NUMBER;

  BEGIN
    CSM_UTIL_PKG.LOG('Entering TRAVELING_TASK for TASK_NUMBER: ' || p_task_number, g_object_name, FND_LOG.LEVEL_PROCEDURE);

    OPEN c_task_status(p_default_status);
    FETCH c_task_status INTO l_status_id;
    CLOSE c_task_status;

    IF l_status_id IS NULL THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message := 'Command Parameter DEFAULT_TASK_STATUS: ' || p_default_status || ' is not a valid task status';
      CSM_UTIL_PKG.LOG( x_error_message, g_object_name, FND_LOG.LEVEL_ERROR);
      RETURN ;
    END IF;

    UPDATE_TASK
    ( p_task_number     => p_task_number,
      p_task_status_id  => l_status_id,
      p_result          => p_result,
      x_return_status   => x_return_status,
      x_error_message   => x_error_message);

    CSM_UTIL_PKG.LOG('Leaving TRAVELING_TASK for TASK_NUMBER: ' || p_task_number, g_object_name, FND_LOG.LEVEL_PROCEDURE);

  EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_error_message := 'Exception occurred in TRAVELING_TASK: ' || sqlerrm;
    CSM_UTIL_PKG.LOG(x_error_message, g_object_name, FND_LOG.LEVEL_EXCEPTION);

  END TRAVELING_TASK;

  /*Procedure to update task statu to Working*/
  PROCEDURE WORKING_TASK
  ( p_task_number   IN NUMBER,
    p_result        OUT nocopy  CLOB,
    x_return_status OUT nocopy VARCHAR2,
    x_error_message OUT nocopy VARCHAR2
  )
  AS
  l_profile_value         NUMBER;
  BEGIN
    CSM_UTIL_PKG.LOG('Entering WORKING_TASK for TASK_NUMBER: ' || p_task_number, g_object_name, FND_LOG.LEVEL_PROCEDURE);
    l_profile_value := TO_NUMBER(fnd_profile.value('CSF_DEFAULT_TASK_WORKING_STATUS'));

    UPDATE_TASK
    ( p_task_number     => p_task_number,
      p_task_status_id  => l_profile_value,
      p_result          => p_result,
      x_return_status   => x_return_status,
      x_error_message   => x_error_message);

    CSM_UTIL_PKG.LOG('Leaving WORKING_TASK for TASK_NUMBER: ' || p_task_number, g_object_name, FND_LOG.LEVEL_PROCEDURE);

  EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_error_message := 'Exception occurred in WORKING_TASK: ' || sqlerrm;
    CSM_UTIL_PKG.LOG(x_error_message, g_object_name, FND_LOG.LEVEL_EXCEPTION);

  END WORKING_TASK;

  /*Procedure to update task statu to Completed*/
  PROCEDURE COMPLETED_TASK
  ( p_task_number     IN NUMBER,
    p_default_status  IN VARCHAR2,
    p_result        OUT nocopy  CLOB,
    x_return_status OUT nocopy VARCHAR2,
    x_error_message OUT nocopy VARCHAR2
  )
  AS
  CURSOR c_task_status(p_default_status VARCHAR2)
  IS
   SELECT tsb.task_status_id
   FROM   jtf_task_statuses_b tsb,
          jtf_task_statuses_tl tstl
   WHERE  tstl.name = p_default_status
    AND   tstl.language = userenv('LANG')
    AND   tsb.task_status_id = tstl.task_status_id;

  l_status_id         NUMBER;
  BEGIN
    CSM_UTIL_PKG.LOG('Entering COMPLETED_TASK for TASK_NUMBER: ' || p_task_number, g_object_name, FND_LOG.LEVEL_PROCEDURE);

    OPEN c_task_status(p_default_status);
    FETCH c_task_status INTO l_status_id;
    CLOSE c_task_status;

    IF l_status_id IS NULL THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message := 'Command Parameter DEFAULT_TASK_STATUS: ' || p_default_status || ' is not a valid task status';
      CSM_UTIL_PKG.LOG( x_error_message, g_object_name, FND_LOG.LEVEL_ERROR);
      RETURN ;
    END IF;

    UPDATE_TASK
    ( p_task_number     => p_task_number,
      p_task_status_id  => l_status_id,
      p_result          => p_result,
      x_return_status   => x_return_status,
      x_error_message   => x_error_message);

    CSM_UTIL_PKG.LOG('Leaving COMPLETED_TASK for TASK_NUMBER: ' || p_task_number, g_object_name, FND_LOG.LEVEL_PROCEDURE);

  EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_error_message := 'Exception occurred in COMPLETED_TASK: ' || sqlerrm;
    CSM_UTIL_PKG.LOG(x_error_message, g_object_name, FND_LOG.LEVEL_EXCEPTION);

  END COMPLETED_TASK;

  PROCEDURE ADD_TASK_NOTE
  ( p_task_number     IN NUMBER,
    p_note_text1      IN VARCHAR2,
    p_note_text2      IN VARCHAR2,
    p_note_visibility IN VARCHAR2,
    p_result          OUT nocopy CLOB,
    x_return_status   OUT nocopy VARCHAR2,
    x_error_message   OUT nocopy VARCHAR2
  )
  AS

  CURSOR c_task( p_task_number NUMBER, p_user_id NUMBER)
  IS
   SELECT jta.task_id
   FROM   jtf_task_assignments jta,
          jtf_tasks_b   jtb,
          jtf_rs_resource_extns res
   WHERE  jtb.task_number = p_task_number
    AND   jtb.task_id = jta.task_id
    AND   res.user_id = p_user_id
    AND   res.resource_id = jta.resource_id;

  CURSOR c_note_status(p_meaning VARCHAR2)
  IS
    SELECT  lookup_code
    FROM    fnd_lookup_values
    WHERE lookup_type = 'JTF_NOTE_STATUS'
      AND meaning = p_meaning
      AND language = userenv('LANG');

  l_task_access_flag  VARCHAR2(1);
  l_jtf_note_id       NUMBER;
  l_task_id           NUMBER;
  l_note_status       VARCHAR2(1);
  l_msg_count         NUMBER;
  l_notes             VARCHAR2(32767);
  BEGIN

    CSM_UTIL_PKG.LOG('Entering ADD_TASK_NOTE for TASK_NUMBER: ' || p_task_number, g_object_name, FND_LOG.LEVEL_PROCEDURE);
    l_task_access_flag := CHECK_TASK_ACCESS(g_user_id, p_task_number);

    IF l_task_access_flag = 'N' THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message := 'Task Number: ' || p_task_number || ' has no assignment for user: ' || g_user_name;
      CSM_UTIL_PKG.LOG( x_error_message, g_object_name, FND_LOG.LEVEL_ERROR);
      RETURN ;
    END IF;

    OPEN c_task(p_task_number,g_user_id);
    FETCH c_task INTO l_task_id;
    CLOSE c_task;

    OPEN c_note_status(p_note_visibility);
    FETCH c_note_status INTO l_note_status;
    CLOSE c_note_status;


    IF l_note_status IS NULL THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message := 'Command Parameter NOTE_VISIBILITY: ' || p_note_visibility || ' is not a valid Note Status';
      CSM_UTIL_PKG.LOG(x_error_message, g_object_name, FND_LOG.LEVEL_ERROR);
      RETURN ;
    END IF;

    l_notes := p_note_text1 || p_note_text2;
    IF LENGTH(l_notes) > 2000 THEN
      jtf_notes_pub.create_note
        ( p_api_version        => 1.0
        , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
        , p_init_msg_list      => FND_API.G_TRUE
        , p_commit             => FND_API.G_TRUE
        , x_return_status      => x_return_status
        , x_msg_count          => l_msg_count
        , x_msg_data           => x_error_message
        , p_source_object_id   => l_task_id
        , p_source_object_code => 'TASK'
        , p_notes              => SUBSTR(l_notes,1,2000)
        , p_notes_detail       => l_notes
        , p_note_status        => l_note_status
        , p_entered_by         => g_user_id
        , p_entered_date       => SYSDATE
        , p_created_by         => g_user_id --NVL(p_record.created_by,FND_GLOBAL.USER_ID)  --12.1
        , p_creation_date      => SYSDATE
        , p_last_updated_by    => g_user_id --NVL(p_record.last_updated_by,FND_GLOBAL.USER_ID)  --12.1
        , p_last_update_date   => SYSDATE
        , p_last_update_login  => g_user_id
        , x_jtf_note_id        => l_jtf_note_id
        );
    ELSE
      jtf_notes_pub.create_note
        ( p_api_version        => 1.0
        , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
        , p_init_msg_list      => FND_API.G_TRUE
        , p_commit             => FND_API.G_TRUE
        , x_return_status      => x_return_status
        , x_msg_count          => l_msg_count
        , x_msg_data           => x_error_message
        , p_source_object_id   => l_task_id
        , p_source_object_code => 'TASK'
        , p_notes              => l_notes
        , p_notes_detail       => NULL
        , p_note_status        => l_note_status
        , p_entered_by         => g_user_id
        , p_entered_date       => SYSDATE
        , p_created_by         => g_user_id --NVL(p_record.created_by,FND_GLOBAL.USER_ID)  --12.1
        , p_creation_date      => SYSDATE
        , p_last_updated_by    => g_user_id --NVL(p_record.last_updated_by,FND_GLOBAL.USER_ID)  --12.1
        , p_last_update_date   => SYSDATE
        , p_last_update_login  => g_user_id
        , x_jtf_note_id        => l_jtf_note_id
        );
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message := 'Error in ADD_TASK_NOTE :'
          || ' ROOT ERROR: jtf_notes_pub.Create_note'
          || ' for PK TASK_NUMBER: ' || p_task_number
          || ' Details:' || x_error_message;
      CSM_UTIL_PKG.LOG( x_error_message,g_object_name, FND_LOG.LEVEL_ERROR);
      RETURN ;
    END IF;

    p_result := EMPTY_CLOB();
    CSM_UTIL_PKG.LOG('Leaving ADD_TASK_NOTE for TASK_NUMBER: ' || p_task_number || ' JTF_NOTE_ID: ' || l_jtf_note_id , g_object_name, FND_LOG.LEVEL_PROCEDURE);

  EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_error_message := 'Exception occurred in ADD_TASK_NOTE: ' || sqlerrm;
    CSM_UTIL_PKG.LOG(x_error_message, g_object_name, FND_LOG.LEVEL_EXCEPTION);

  END ADD_TASK_NOTE;

  PROCEDURE GET_TASK_DETAILS
  ( p_task_number     IN NUMBER,
    p_result          OUT nocopy CLOB,
    x_return_status   OUT nocopy VARCHAR2,
    x_error_message   OUT nocopy VARCHAR2
  )
  AS

  CURSOR c_task_details(p_task_number NUMBER)
  IS
    SELECT tsk.task_number,
          tsk.task_id,
          tsktl.task_name,
          tsktl.description,
          tptl.name priority,
          tttl.name type,
          tstl.name status,
          hzp.party_name customer,
          to_char(tsk.scheduled_start_date,   'YYYY-MM-DD HH24:MI:SS') scheduled_start_date,
          to_char(tsk.scheduled_end_date,   'YYYY-MM-DD HH24:MI:SS') scheduled_end_date,
          csb.incident_id,
          cstl.summary,
          csb.problem_code,
          hzloc.address1 || decode(hzloc.address1,   NULL,   '',   ',')
            || hzloc.address2 || decode(hzloc.address2,   NULL,   '',   ',')
            || hzloc.city || decode(hzloc.city,   NULL,   '',   ',')
            || hzloc.state || decode(hzloc.state,   NULL,   '',   ',')
            || hzloc.postal_code || decode(hzloc.postal_code,   NULL,   '',   ',')
            || hzloc.country
            AS
          address
        FROM jtf_tasks_b tsk,
          jtf_tasks_tl tsktl,
          jtf_task_priorities_b tpb,
          jtf_task_priorities_tl tptl,
          jtf_task_types_b ttb,
          jtf_task_types_tl tttl,
          jtf_task_statuses_b ts,
          jtf_task_statuses_tl tstl,
          cs_incidents_all_b csb,
          cs_incidents_all_tl cstl,
          hz_parties hzp,
          hz_party_sites hzps,
          hz_locations hzloc
        WHERE tsk.task_number = p_task_number
         AND tsktl.task_id = tsk.task_id
         AND tsktl.LANGUAGE = userenv('LANG')
         AND tpb.task_priority_id(+) = tsk.task_priority_id
         AND tptl.task_priority_id = tpb.task_priority_id
         AND tptl.LANGUAGE = userenv('LANG')
         AND ttb.task_type_id(+) = tsk.task_type_id
         AND tttl.task_type_id = ttb.task_type_id
         AND tttl.LANGUAGE = userenv('LANG')
         AND ts.task_status_id(+) = tsk.task_status_id
         AND tstl.task_status_id = ts.task_status_id
         AND tstl.LANGUAGE = userenv('LANG')
         AND tsk.source_object_type_code = 'SR'
         AND csb.incident_id(+) = tsk.source_object_id
         AND csb.incident_id = cstl.incident_id
         AND cstl.LANGUAGE = userenv('LANG')
         AND hzp.party_id(+) = tsk.customer_id
         AND hzps.party_site_id = tsk.address_id
         AND hzloc.location_id(+) = hzps.location_id;

  CURSOR c_task_uom(p_task_id NUMBER)
  IS
    SELECT tsk.planned_effort,
           uom.unit_of_measure
    FROM jtf_tasks_b tsk,
         mtl_units_of_measure_tl uom
    WHERE tsk.task_id = p_task_id
         AND uom.uom_code(+) = tsk.planned_effort_uom
         AND uom.LANGUAGE = userenv('LANG');

  CURSOR c_system_items(p_incident_id NUMBER)
  IS
    SELECT item.segment1 AS item
    FROM cs_incidents_all_b csb,
         mtl_system_items_b item
    WHERE csb.incident_id = p_incident_id
       AND item.inventory_item_id(+) = csb.inventory_item_id
       AND item.organization_id = csb.org_id;

  CURSOR c_item_instance(p_incident_id NUMBER)
  IS
    SELECT inst.serial_number
    FROM cs_incidents_all_b csb,
         csi_item_instances inst
    WHERE csb.incident_id = p_incident_id
       AND inst.instance_id(+) = csb.customer_product_id
       AND inst.inv_master_organization_id = csb.org_id
       AND inst.inventory_item_id = csb.inventory_item_id;

  CURSOR c_task_notes(p_task_number NUMBER)
  IS
    SELECT nttl.notes note_text,
      lkp.meaning note_status,
      rs.source_name entered_by,
      to_char(ntb.entered_date,   'YYYY-MM-DD HH24:MI:SS') entered_date
    FROM jtf_tasks_b tsk,
      jtf_notes_b ntb,
      jtf_notes_tl nttl,
      jtf_rs_resource_extns rs,
      fnd_lookup_values lkp
    WHERE tsk.task_number = p_task_number
     AND ntb.source_object_id = tsk.task_id
     AND ntb.source_object_code = 'TASK'
     AND nttl.jtf_note_id = ntb.jtf_note_id
     AND nttl.LANGUAGE = userenv('LANG')
     AND rs.user_id = ntb.entered_by
     AND lkp.lookup_code = ntb.note_status
     AND lkp.lookup_type = 'JTF_NOTE_STATUS'
     AND lkp.LANGUAGE = userenv('LANG');

  r_task_details          c_task_details%ROWTYPE;
  r_task_uom              c_task_uom%ROWTYPE;
  r_task_notes            c_task_notes%ROWTYPE;
  l_item                  mtl_system_items_b.segment1%TYPE;
  l_serial_number         csi_item_instances.serial_number%TYPE;
  l_task_access_flag      VARCHAR2(1);
  l_query_text            VARCHAR2(4000);
  l_qrycontext            DBMS_XMLGEN.ctxHandle;
  l_email_format          VARCHAR2(240);
  l_xml_result            LONG;

  BEGIN
    CSM_UTIL_PKG.LOG('Entering GET_TASK_DETAILS for TASK_NUMBER: ' || p_task_number, g_object_name, FND_LOG.LEVEL_PROCEDURE);

    l_task_access_flag := CHECK_TASK_ACCESS(g_user_id, p_task_number);

    IF l_task_access_flag = 'N' THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message := 'Task Number: ' || p_task_number || ' has no assignment for user: ' || g_user_name;
      CSM_UTIL_PKG.LOG( x_error_message, g_object_name, FND_LOG.LEVEL_ERROR);
      RETURN;
    END IF;

    OPEN c_task_details(p_task_number);
    FETCH c_task_details INTO r_task_details;
    CLOSE c_task_details;

    l_xml_result := '<?xml version="1.0"?>'
              || '<ROWSET>'
              || ' <ROW>'
              || '  <TASK_NUMBER>' || r_task_details.task_number || '</TASK_NUMBER>'
              || '  <TASK_NAME><![CDATA[' || r_task_details.task_name || ']]></TASK_NAME>'
              || '  <DESCRIPTION><![CDATA[' || r_task_details.description || ']]></DESCRIPTION>'
              || '  <PRIORITY> ' || r_task_details.priority || '</PRIORITY>'
              || '  <TYPE> ' ||r_task_details.type || '</TYPE>'
              || '  <STATUS> ' ||r_task_details.status || '</STATUS>'
              || '  <CUSTOMER> ' || r_task_details.customer || '</CUSTOMER>'
              || '  <SCHEDULED_START_DATE> ' || r_task_details.scheduled_start_date || '</SCHEDULED_START_DATE>'
              || '  <SCHEDULED_END_DATE> ' || r_task_details.scheduled_end_date || '</SCHEDULED_END_DATE>'
              || '  <SUMMARY> ' || r_task_details.summary || '</SUMMARY>'
              || '  <PROBLEM_CODE> ' || r_task_details.problem_code || '</PROBLEM_CODE>'
              || '  <ADDRESS><![CDATA[' || r_task_details.address || ']]></ADDRESS>';

    OPEN c_task_uom(r_task_details.task_id);
    FETCH c_task_uom INTO r_task_uom;
    CLOSE c_task_uom;

    l_xml_result := l_xml_result
              || '  <PLANNED_EFFORT> ' || r_task_uom.planned_effort || '</PLANNED_EFFORT>'
              || '  <UNIT_OF_MEASURE> ' || r_task_uom.unit_of_measure || '</UNIT_OF_MEASURE>';

    OPEN c_system_items(r_task_details.incident_id);
    FETCH c_system_items INTO l_item;
    CLOSE c_system_items;

    l_xml_result := l_xml_result
        || '  <ITEM><![CDATA[' || l_item || ']]></ITEM>';

    OPEN c_item_instance(r_task_details.incident_id);
    FETCH c_item_instance INTO l_serial_number;
    CLOSE c_item_instance;

    l_xml_result := l_xml_result
        || '  <SERIAL_NUMBER> ' || l_serial_number || '</SERIAL_NUMBER>';

    l_xml_result := l_xml_result     || ' </ROW>';

    FOR r_task_notes IN  c_task_notes(p_task_number) LOOP
      l_xml_result := l_xml_result
                || ' <ROW> '
                || '  <NOTE_TEXT><![CDATA[' || r_task_notes.note_text || ' ]]></NOTE_TEXT>'
                || '  <NOTE_STATUS> ' || r_task_notes.note_status || '</NOTE_STATUS>'
                || '  <ENTERED_BY> ' || r_task_notes.entered_by || ' </ENTERED_BY>'
                || '  <ENTERED_DATE> ' || r_task_notes.entered_date || ' </ENTERED_DATE> '
                || ' </ROW> ';
    END LOOP;

    l_xml_result := l_xml_result     || ' </ROWSET>';

    p_result := TO_CLOB(l_xml_result);

    CSM_UTIL_PKG.LOG('Leaving GET_TASK_DETAILS for TASK_NUMBER: ' || p_task_number, g_object_name, FND_LOG.LEVEL_PROCEDURE);

  EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_error_message := 'Exception occurred in GET_TASK_DETAILS: ' || sqlerrm;
    CSM_UTIL_PKG.LOG(x_error_message, g_object_name, FND_LOG.LEVEL_EXCEPTION);

  END GET_TASK_DETAILS;

  PROCEDURE GET_SR_DETAILS
  ( p_sr_number       IN NUMBER,
    p_result          OUT nocopy CLOB,
    x_return_status   OUT nocopy VARCHAR2,
    x_error_message   OUT nocopy VARCHAR2
  )
  AS
  CURSOR c_incidents(p_incident_number NUMBER, p_user_id NUMBER)
  IS
   SELECT sr.incident_id
   FROM   cs_incidents_all_b sr,
          jtf_tasks_b   tsk,
          jtf_task_assignments tassg,
          jtf_rs_resource_extns res
   WHERE  sr.incident_number = p_incident_number
    AND   tsk.source_object_id = sr.incident_id
    AND   tsk.source_object_type_code = 'SR'
    AND   tassg.task_id = tsk.task_id
    AND   res.resource_id = tassg.resource_id
    AND   res.user_id = p_user_id;

  CURSOR c_incident_details(p_incident_id NUMBER)
  IS
    SELECT csb.incident_number,
          cstl.summary name,
          it.name type,
          isevtl.name severity,
          isttl.name status,
          hzp.party_name customer,
          csb.problem_code,
          csb.resolution_code,
          to_char(csb.incident_date,   'YYYY-MM-DD HH24:MI:SS') reported_date
        FROM cs_incidents_all_b csb,
          cs_incidents_all_tl cstl,
          cs_incident_types it,
          cs_incident_types_tl ittl,
          cs_incident_severities isev,
          cs_incident_severities_tl isevtl,
          cs_incident_statuses ist,
          cs_incident_statuses_tl isttl,
          hz_parties hzp
        WHERE csb.incident_id = p_incident_id
         AND cstl.incident_id = csb.incident_id
         AND cstl.LANGUAGE = userenv('LANG')
         AND it.incident_type_id(+) = csb.incident_type_id
         AND it.incident_type_id = ittl.incident_type_id
         AND ittl.LANGUAGE = userenv('LANG')
         AND isev.incident_severity_id(+) = csb.incident_severity_id
         AND isev.incident_severity_id = isevtl.incident_severity_id
         AND isevtl.LANGUAGE = userenv('LANG')
         AND ist.incident_status_id(+) = csb.incident_status_id
         AND ist.incident_status_id = isttl.incident_status_id
         AND isttl.LANGUAGE = userenv('LANG')
         AND hzp.party_id(+) = csb.customer_id;

  CURSOR c_system_items(p_incident_id NUMBER)
  IS
    SELECT item.segment1 AS item
    FROM cs_incidents_all_b csb,
         mtl_system_items_b item
    WHERE csb.incident_id = p_incident_id
       AND item.inventory_item_id(+) = csb.inventory_item_id
       AND item.organization_id = csb.org_id;

  CURSOR c_item_instance(p_incident_id NUMBER)
  IS
    SELECT  inst.instance_number AS instance,
        inst.serial_number
    FROM cs_incidents_all_b csb,
         csi_item_instances inst
    WHERE csb.incident_id = p_incident_id
       AND inst.instance_id(+) = csb.customer_product_id
       AND inst.inv_master_organization_id = csb.org_id
       AND inst.inventory_item_id = csb.inventory_item_id;

  CURSOR c_problem_summary(p_problem_code VARCHAR2)
  IS
    SELECT description
    FROM fnd_lookup_values
    WHERE lookup_code = p_problem_code
      AND lookup_type = 'REQUEST_PROBLEM_CODE'
      AND LANGUAGE = userenv('LANG');

  CURSOR c_resolution_summary(p_resolution_code VARCHAR2)
  IS
    SELECT description
    FROM fnd_lookup_values
    WHERE lookup_code = p_resolution_code
      AND lookup_type = 'REQUEST_RESOLUTION_CODE'
      AND LANGUAGE = userenv('LANG');

  CURSOR c_sr_notes(p_incident_number NUMBER)
  IS
    SELECT nttl.notes note_text,
      lkp.meaning note_status,
      rs.source_name entered_by,
      to_char(ntb.entered_date,   'YYYY-MM-DD HH24:MI:SS') entered_date
    FROM cs_incidents_all_b cs,
      jtf_notes_b ntb,
      jtf_notes_tl nttl,
      jtf_rs_resource_extns rs,
      fnd_lookup_values lkp
    WHERE cs.incident_number = p_incident_number
     AND ntb.source_object_id = cs.incident_id
     AND ntb.source_object_code = 'SR'
     AND nttl.jtf_note_id = ntb.jtf_note_id
     AND nttl.LANGUAGE = userenv('LANG')
     AND rs.user_id = ntb.entered_by
     AND lkp.lookup_code = ntb.note_status
     AND lkp.lookup_type = 'JTF_NOTE_STATUS'
     AND lkp.LANGUAGE = userenv('LANG');

  r_incident_details      c_incident_details%ROWTYPE;
  l_item                  mtl_system_items_b.segment1%TYPE;
  l_instance_number       csi_item_instances.instance_number%TYPE;
  l_serial_number         csi_item_instances.serial_number%TYPE;
  l_description           fnd_lookup_values.description%TYPE;
  r_sr_notes              c_sr_notes%ROWTYPE;
  l_incident_id           NUMBER;
  l_query_text            VARCHAR2(4000);
  qrycontext              DBMS_XMLGEN.ctxHandle;
  l_email_format          VARCHAR2(240);
  l_xml_result            CLOB;
  BEGIN
    CSM_UTIL_PKG.LOG('Entering GET_SR_DETAILS for SR_NUMBER: ' || p_sr_number, g_object_name, FND_LOG.LEVEL_PROCEDURE);

    OPEN c_incidents(p_sr_number,g_user_id);
    FETCH c_incidents INTO l_incident_id;
    CLOSE c_incidents;

    IF l_incident_id IS NULL THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message := 'Service Request Number: ' || p_sr_number || ' has no assignment for user: ' || g_user_name;
      CSM_UTIL_PKG.LOG( x_error_message, g_object_name, FND_LOG.LEVEL_ERROR);
      RETURN;
    END IF;

    OPEN c_incident_details(l_incident_id);
    FETCH c_incident_details INTO r_incident_details;
    CLOSE c_incident_details;

    l_xml_result := '<?xml version="1.0"?>'
              || '<ROWSET>'
              || ' <ROW>'
              || '  <NUMBER>' || r_incident_details.incident_number || '</NUMBER>'
              || '  <NAME><![CDATA[' || r_incident_details.name || ']]></NAME>'
              || '  <TYPE> ' || r_incident_details.type || '</TYPE>'
              || '  <STATUS> ' || r_incident_details.status || '</STATUS>'
              || '  <SEVERITY> ' ||r_incident_details.severity || '</SEVERITY>'
              || '  <CUSTOMER> ' || r_incident_details.customer || '</CUSTOMER>'
              || '  <REPORTED_DATE> ' || r_incident_details.reported_date || '</REPORTED_DATE>';

    OPEN c_system_items(l_incident_id);
    FETCH c_system_items INTO l_item;
    CLOSE c_system_items;

    l_xml_result := l_xml_result
        || '  <ITEM> <![CDATA[' || l_item || ']]></ITEM>';

    OPEN c_item_instance(l_incident_id);
    FETCH c_item_instance INTO l_instance_number, l_serial_number;
    CLOSE c_item_instance;

    l_xml_result := l_xml_result
        || '  <INSTANCE> ' || l_instance_number || '</INSTANCE>'
        || '  <SERIAL_NUMBER> ' || l_serial_number || '</SERIAL_NUMBER>';

    l_xml_result := l_xml_result
              || '  <PROBLEM_CODE> ' || r_incident_details.problem_code || '</PROBLEM_CODE>';

    IF r_incident_details.problem_code IS NOT NULL THEN
      OPEN c_problem_summary(r_incident_details.problem_code);
      FETCH c_problem_summary INTO l_description;
      CLOSE c_problem_summary;
      l_xml_result := l_xml_result
              || '  <PROBLEM_SUMMARY> ' || l_description || '</PROBLEM_SUMMARY>';
    END IF;

    l_xml_result := l_xml_result
              || '  <RESOLUTION_CODE> ' || r_incident_details.resolution_code || '</RESOLUTION_CODE>';

    IF r_incident_details.resolution_code IS NOT NULL THEN
      OPEN c_resolution_summary(r_incident_details.resolution_code);
      FETCH c_resolution_summary INTO l_description;
      CLOSE c_resolution_summary;
      l_xml_result := l_xml_result
              || '  <RESOLUTION_SUMMARY> ' || l_description || '</RESOLUTION_SUMMARY>';
    END IF;

    l_xml_result := l_xml_result     || ' </ROW> ';

    FOR r_sr_notes IN  c_sr_notes(p_sr_number) LOOP
      l_xml_result := l_xml_result
                || ' <ROW> '
                || '  <NOTE_TEXT> <![CDATA[' || r_sr_notes.note_text || ']]> </NOTE_TEXT>'
                || '  <NOTE_STATUS> ' || r_sr_notes.note_status || '</NOTE_STATUS>'
                || '  <ENTERED_BY> ' || r_sr_notes.entered_by || ' </ENTERED_BY>'
                || '  <ENTERED_DATE> ' || r_sr_notes.entered_date || ' </ENTERED_DATE> '
                || ' </ROW> ';
    END LOOP;

    l_xml_result := l_xml_result     || ' </ROWSET>';

    p_result := TO_CLOB(l_xml_result);

    CSM_UTIL_PKG.LOG('Leaving GET_SR_DETAILS for SR_NUMBER: ' || p_sr_number, g_object_name, FND_LOG.LEVEL_PROCEDURE);

  EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_error_message := 'Exception occurred in GET_SR_DETAILS: ' || sqlerrm;
    CSM_UTIL_PKG.LOG(x_error_message, g_object_name, FND_LOG.LEVEL_EXCEPTION);

  END GET_SR_DETAILS;

  /**/
  PROCEDURE GET_ENTITLEMENTS
  ( p_serial_number   IN VARCHAR2,
    p_result          OUT nocopy  CLOB,
    x_return_status   OUT nocopy VARCHAR2,
    x_error_message   OUT nocopy VARCHAR2
  )

  AS

  CURSOR c_inst_contracts(p_serial_number VARCHAR2, p_user_id NUMBER)
    IS
    SELECT csi.instance_id,
      cs.contract_service_id
    FROM csi_item_instances csi,
      cs_incidents_all_b cs,
      jtf_tasks_b tsk,
      jtf_task_assignments ass,
      jtf_rs_resource_extns res
    WHERE csi.serial_number = p_serial_number
     AND csi.instance_id = cs.customer_product_id
     AND tsk.source_object_id = cs.incident_id
     AND tsk.source_object_type_code = 'SR'
     AND ass.task_id = tsk.task_id
     AND res.resource_id = ass.resource_id
     AND res.user_id = p_user_id;

  l_instance_id           NUMBER;
  l_cont_serive_id        NUMBER;

  l_inp_rec               oks_entitlements_pub.input_rec_ib;
  l_ent_contracts         oks_entitlements_pub.output_tbl_ib;
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(4000);

  l_xml_result            CLOB;

  BEGIN
    CSM_UTIL_PKG.LOG('Entering GET_ENTITLEMENTS for SERIAL_NUMBER: ' || p_serial_number, g_object_name, FND_LOG.LEVEL_PROCEDURE);

    OPEN c_inst_contracts(p_serial_number, g_user_id);
    FETCH c_inst_contracts INTO l_instance_id, l_cont_serive_id;
    CLOSE c_inst_contracts;

    IF l_instance_id IS NULL THEN
      x_error_message := 'User: ' || g_user_name || ' has no task for serial number: ' || p_serial_number;
      CSM_UTIL_PKG.LOG( x_error_message, g_object_name, FND_LOG.LEVEL_ERROR);
      RETURN;
    END IF;

    l_inp_rec.service_line_id := l_cont_serive_id;
    l_inp_rec.product_id := l_instance_id;
    l_inp_rec.validate_flag := 'N';

    oks_entitlements_pub.get_contracts
    ( p_api_version   => 1.0,
      p_init_msg_list => fnd_api.g_true,
      p_inp_rec       => l_inp_rec,
      x_return_status => x_return_status,
      x_msg_count     => l_msg_count,
      x_msg_data      => l_msg_data,
      x_ent_contracts => l_ent_contracts
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message := 'Error in GET_ENTITLEMENTS :'
          || ' ROOT ERROR: oks_entitlements_pub.get_contracts'
          || ' for serial number : ' || p_serial_number
          || ' Details:' || l_msg_data;

      CSM_UTIL_PKG.LOG( x_error_message,g_object_name, FND_LOG.LEVEL_ERROR);
      RETURN ;
    END IF;

    l_xml_result := '<?xml version="1.0"?>'
              || '<ROWSET>'
              || ' <ROW>';

    FOR i IN 1..l_ent_contracts.COUNT LOOP

      l_xml_result := l_xml_result
             || '<CONTRACT_NUMBER>' || l_ent_contracts(i).contract_number || '</CONTRACT_NUMBER>'
             || '<NAME><![CDATA[' || l_ent_contracts(i).service_name || ']]></NAME>'
             || '<DESCRIPTION><![CDATA[' || l_ent_contracts(i).service_description || ']]></DESCRIPTION>'
             || '<STATUS>' || l_ent_contracts(i).sts_code || '</STATUS>'
             || '<COVERAGE_NAME><![CDATA[' || l_ent_contracts(i).coverage_term_name || ']]></COVERAGE_NAME>'
             || '<COVERAGE_DESCRIPTION><![CDATA[' || l_ent_contracts(i).coverage_term_description || ']]></COVERAGE_DESCRIPTION>'
             || '<WARRANTY>' || l_ent_contracts(i).warranty_flag || '</WARRANTY>'
             || '<START_DATE>' || l_ent_contracts(i).service_start_date || '</START_DATE>'
             || '<END_DATE>' || l_ent_contracts(i).service_end_date || '</END_DATE>';

    END LOOP;

    l_xml_result := l_xml_result
              || ' </ROW> '
              || '</ROWSET>';

    p_result := l_xml_result;

    CSM_UTIL_PKG.LOG('Leaving GET_ENTITLEMENTS for SERIAL_NUMBER: ' || p_serial_number, g_object_name, FND_LOG.LEVEL_PROCEDURE);

  EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_error_message := 'Exception occurred in GET_ENTITLEMENTS: ' || sqlerrm;
    CSM_UTIL_PKG.LOG(x_error_message, g_object_name, FND_LOG.LEVEL_EXCEPTION);

  END GET_ENTITLEMENTS;

/*Procedure to get the information of mobile query command*/
  PROCEDURE HELP_QUERY
  ( p_query_name      IN VARCHAR2,
    p_result          OUT nocopy  CLOB,
    x_return_status   OUT nocopy VARCHAR2,
    x_error_message   OUT nocopy VARCHAR2
  )
  AS
  l_query_text      VARCHAR2(4000);
  qrycontext        DBMS_XMLGEN.ctxHandle;

  BEGIN
    CSM_UTIL_PKG.LOG('Entering HELP_QUERY for query_name: ' || p_query_name, g_object_name, FND_LOG.LEVEL_PROCEDURE);

    l_query_text := 'SELECT query_name command_name,
               description
               FROM csm_query_tl qtl,
               csm_query_b qb
               WHERE UPPER(qb.query_name) like UPPER(''%'|| trim(p_query_name) ||'%'')
               AND qb.email_enabled = ''Y''
               AND NVL(qb.disabled_flag,''N'') = ''N''
               AND qtl.language = userenv(''LANG'')
               AND qb.query_id = qtl.query_id';

    qrycontext := DBMS_XMLGEN.newcontext(l_query_text) ;
    DBMS_XMLGEN.setnullhandling (qrycontext, DBMS_XMLGEN.empty_tag);
    p_result := DBMS_XMLGEN.getxml (qrycontext);

    CSM_UTIL_PKG.LOG('Leaving HELP_QUERY for query_name: ' || p_query_name, g_object_name, FND_LOG.LEVEL_PROCEDURE);

  EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_error_message := 'Exception occurred in HELP_QUERY: ' || sqlerrm;
    CSM_UTIL_PKG.LOG(x_error_message, g_object_name, FND_LOG.LEVEL_EXCEPTION);

  END HELP_QUERY;


 FUNCTION set_profile
 ( p_profile_name  VARCHAR2,
   p_profile_value VARCHAR2
 ) RETURN VARCHAR2
  IS
  l_return_stat boolean;
  l_return_flag VARCHAR2(1);
  BEGIN
     CSM_UTIL_PKG.LOG('Entering SET_PROFILE for p_profile_name: ' || p_profile_name, g_object_name, FND_LOG.LEVEL_PROCEDURE);
     l_return_flag := 'N';

     l_return_stat := fnd_profile.save(p_profile_name, p_profile_value, 'SITE');
     IF l_return_stat THEN
      l_return_flag := 'Y';
      COMMIT;
     END IF;

     CSM_UTIL_PKG.LOG('Leaving SET_PROFILE for p_profile_name: ' || p_profile_name, g_object_name, FND_LOG.LEVEL_PROCEDURE);
     RETURN l_return_flag;
  END set_profile;

  PROCEDURE NOTIFY_EMAIL_EXCEPTION
  ( p_email_id        IN   VARCHAR2,
    p_subject         IN   VARCHAR2,
    p_message         IN   VARCHAR2,
    x_return_status   OUT nocopy VARCHAR2,
    x_error_message   OUT nocopy VARCHAR2 )
  IS
  CURSOR c_role(p_email_id VARCHAR2, p_user_id NUMBER)
    IS
    SELECT wf.name as role_name, fu.user_name as user_name
      FROM wf_local_roles wf,
           fnd_user fu
    WHERE wf.email_address = p_email_id
      AND fu.user_id = p_user_id
      AND wf.status = 'ACTIVE'
      AND wf.start_date <= sysdate
      AND (wf.expiration_date IS NULL OR wf.expiration_date > sysdate);

  l_nid               NUMBER;
  l_role_name         wf_local_roles.name%type;
  l_user_name         fnd_user.user_name%type;
  l_user_id           NUMBER;
  BEGIN

    CSM_UTIL_PKG.LOG('Entering NOTIFY_EMAIL_EXCEPTION for EMAIL_ID: ' || p_email_id, g_object_name, FND_LOG.LEVEL_PROCEDURE);

    l_user_id := IS_FND_USER(p_email_id);

    IF l_user_id = -1 THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_error_message := 'EMAIL_ID: ' || p_email_id || ' is not accosiated to a valid FND_USER';
      CSM_UTIL_PKG.LOG(x_error_message, g_object_name, FND_LOG.LEVEL_ERROR);
      RETURN;
    END IF;

    OPEN c_role(p_email_id, l_user_id);
    FETCH c_role INTO l_role_name, l_user_name;
    CLOSE c_role;
    IF l_role_name IS NULL THEN

      l_role_name := l_user_name;

      wf_directory.CreateAdHocUser
        ( name => l_role_name,
          display_name => l_user_name,
          notification_preference => 'MAILTEXT',
          email_address =>p_email_id);

      CSM_UTIL_PKG.LOG('Created Role : ' || l_role_name, g_object_name, FND_LOG.LEVEL_PROCEDURE);

    END IF;

    l_nid := wf_notification.Send
                          ( role     =>  l_role_name
                          , msg_type => 'CSM_MSGS'
                          , msg_name => 'FYI_MESSAGE'
                          );
    wf_notification.SetAttrText
     ( l_nid
     , 'MESSAGE_BODY'
     , p_message
     );

    wf_notification.SetAttrText
     ( l_nid
     , 'SUBJECT'
     , p_subject
     );

    wf_notification.denormalize_notification(l_nid);
    x_return_status := fnd_api.g_ret_sts_success;
    x_error_message := 'Successfully send notification id: ' || l_nid || ' to role: ' || l_role_name;

    CSM_UTIL_PKG.LOG('Leaving NOTIFY_EMAIL_EXECPTION for EMAIL_ID: ' || p_email_id || ' NID: ' || l_nid, g_object_name, FND_LOG.LEVEL_PROCEDURE);

  EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_error_message := 'Exception occurred in NOTIFY_EMAIL_EXCEPTION: ' || sqlerrm;
    CSM_UTIL_PKG.LOG(x_error_message, g_object_name, FND_LOG.LEVEL_EXCEPTION);

  END NOTIFY_EMAIL_EXCEPTION;

END CSM_EMAIL_QUERY_PKG;


/
