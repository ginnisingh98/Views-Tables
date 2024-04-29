--------------------------------------------------------
--  DDL for Package Body JTF_TASK_WF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_WF_UTIL" AS
  /* $Header: jtftkwub.pls 120.4.12010000.3 2008/11/18 10:51:56 rkamasam ship $ */
  FUNCTION do_notification(p_task_id IN NUMBER)
    RETURN BOOLEAN IS
    CURSOR c_task_flag(b_task_id jtf_tasks_b.task_id%TYPE) IS
      SELECT tt.notification_flag
           , ta.notification_flag
        FROM jtf_task_types_b tt, jtf_tasks_b ta
       WHERE ta.task_id = b_task_id AND ta.task_type_id = tt.task_type_id;

    l_type_notif_flag jtf_tasks_b.notification_flag%TYPE;
    l_task_notif_flag jtf_tasks_b.notification_flag%TYPE;
  BEGIN
    ---
    --- Check if notification flag is set on the Task or for the Task type
    ---
    OPEN c_task_flag(p_task_id);
    FETCH c_task_flag INTO l_type_notif_flag, l_task_notif_flag;
    IF c_task_flag%NOTFOUND THEN
      CLOSE c_task_flag;
      RETURN FALSE;
    END IF;
    CLOSE c_task_flag;

    IF l_type_notif_flag = 'Y' OR l_task_notif_flag = 'Y' THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END do_notification;

  FUNCTION wf_process(p_task_id IN NUMBER)
    RETURN VARCHAR2 IS
    CURSOR c_process(b_task_id jtf_tasks_b.task_id%TYPE) IS
      SELECT tt.workflow_type || ',' || tt.workflow workflow
        FROM jtf_task_types_b tt, jtf_tasks_b ta
       WHERE ta.task_id = b_task_id AND ta.task_type_id = tt.task_type_id;

    l_workflow VARCHAR2(200);   --jtf_task_types_b.workflow%type; --Bug 4289436
  BEGIN
    ---
    --- Find the name of the Workflow process to be run
    ---
    OPEN c_process(p_task_id);
    FETCH c_process INTO l_workflow;
    CLOSE c_process;

    IF (l_workflow IS NULL) OR(l_workflow = ',') THEN
      l_workflow  := 'JTFTASK,TASK_WORKFLOW';
    END IF;

    RETURN l_workflow;
  END wf_process;

  FUNCTION get_resource_name(p_resource_type IN VARCHAR2, p_resource_id IN NUMBER)
    RETURN VARCHAR2 IS
    TYPE cur_typ IS REF CURSOR;

    c               cur_typ;
    l_sql_statement VARCHAR2(500)                         := NULL;
    l_resource_name jtf_tasks_b.source_object_name%TYPE   := NULL;
    l_where_clause  jtf_objects_b.where_clause%TYPE       := NULL;

    -------------------------------------------------------------------------
    -- Create a SQL statement for getting the resource name
    -------------------------------------------------------------------------
    CURSOR c_get_res_name(b_resource_type jtf_tasks_b.owner_type_code%TYPE) IS
      SELECT where_clause
           , 'SELECT ' || select_name || ' FROM ' || from_table || ' WHERE ' || select_id || ' = :RES'
        FROM jtf_objects_vl
       WHERE object_code = b_resource_type;
  BEGIN
    OPEN c_get_res_name(p_resource_type);
    FETCH c_get_res_name INTO l_where_clause, l_sql_statement;
    IF c_get_res_name%NOTFOUND THEN
      CLOSE c_get_res_name;
      RETURN NULL;
    END IF;
    CLOSE c_get_res_name;

    -- assign the value again so it is null-terminated, to avoid ORA-600 [12261]
    l_sql_statement  := l_sql_statement;

    IF l_sql_statement IS NOT NULL THEN
      IF l_where_clause IS NOT NULL THEN
        l_sql_statement  := l_sql_statement || ' AND ' || l_where_clause;
      END IF;

      OPEN c FOR l_sql_statement USING p_resource_id;
      FETCH c INTO l_resource_name;
      CLOSE c;

      RETURN l_resource_name;
    ELSE
      RETURN NULL;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_resource_name;

  FUNCTION check_backcomp(p_itemtype IN VARCHAR2)
    RETURN VARCHAR2 IS
    l_type     VARCHAR2(100);
    l_subtype  VARCHAR2(100);
    l_format   VARCHAR2(100);
    e_wf_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_wf_error, -20002);
  BEGIN
    ---
    --- Using this procedure to find out if the Workflow we are
    --- calling has to have the backward-compatible attributes set
    ---
    wf_engine.getitemattrinfo(
      itemtype => p_itemtype
    , aname    => 'TASK_EVENT'
    , atype    => l_type
    , SUBTYPE  => l_subtype
    , format   => l_format
    );

    RETURN('N');
  EXCEPTION
    WHEN e_wf_error THEN
      IF SUBSTR(SQLERRM, 12, 4) = '3103' THEN
        RETURN('Y');
      ELSE
        RAISE;
      END IF;
  END check_backcomp;

  PROCEDURE include_role(p_role_name IN VARCHAR2) IS
    l_index        NUMBER               := jtf_task_wf_util.notiflist.COUNT;
    l_search_index NUMBER;
    l_role_name    wf_roles.NAME%TYPE;
  BEGIN
    -- check to see if the role is already in the list
    l_role_name  := p_role_name;

    IF l_index > 0 THEN
      FOR l_search_index IN jtf_task_wf_util.notiflist.FIRST .. jtf_task_wf_util.notiflist.LAST LOOP
        IF l_role_name = jtf_task_wf_util.notiflist(l_search_index).NAME THEN
          l_role_name  := NULL;
          EXIT;
        END IF;
      END LOOP;
    END IF;

    IF l_role_name IS NOT NULL THEN
      -- add the role to the list
      jtf_task_wf_util.notiflist(l_index + 1).NAME  := l_role_name;
    END IF;
  END include_role;

  PROCEDURE get_party_details(p_resource_id IN NUMBER, p_resource_type_code IN VARCHAR2, x_role_name OUT NOCOPY VARCHAR2) IS
    CURSOR c_resource_party(b_resource_id jtf_tasks_b.owner_id%TYPE) IS
      SELECT source_id
        FROM jtf_rs_resource_extns
       WHERE resource_id = b_resource_id;

    l_party_id     hz_parties.party_id%TYPE;
    l_display_name VARCHAR2(100);   -- check this declaration
  BEGIN
    x_role_name  := NULL;

    IF p_resource_type_code IN('RS_SUPPLIER_CONTACT', 'RS_PARTNER', 'RS_PARTY') THEN
      -- supplier or party resource
      OPEN c_resource_party(p_resource_id);
      FETCH c_resource_party INTO l_party_id;
      IF c_resource_party%NOTFOUND THEN
        CLOSE c_resource_party;
        RETURN;
      END IF;
      CLOSE c_resource_party;
    ELSE
      -- party
      l_party_id  := p_resource_id;
    END IF;

    wf_directory.getusername('HZ_PARTY', l_party_id, x_role_name, l_display_name);
  END get_party_details;

  PROCEDURE find_role(p_resource_id IN NUMBER, p_resource_type_code IN VARCHAR2) IS
    CURSOR c_group_members(b_group_id jtf_rs_group_members.GROUP_ID%TYPE) IS
      SELECT resource_id
           , 'RS_' || CATEGORY resource_type_code
        FROM jtf_rs_resource_extns
       WHERE resource_id IN(SELECT resource_id
                              FROM jtf_rs_group_members
                             WHERE GROUP_ID = b_group_id AND NVL(delete_flag, 'N') = 'N');

    CURSOR c_team_members(b_team_id jtf_rs_team_members.team_id%TYPE) IS
      SELECT resource_id
           , 'RS_' || CATEGORY resource_type_code
        FROM jtf_rs_resource_extns
       WHERE resource_id IN(SELECT team_resource_id
                              FROM jtf_rs_team_members
                             WHERE team_id = b_team_id AND NVL(delete_flag, 'N') = 'N');

    CURSOR c_group_team_role(b_orig_system wf_local_roles.orig_system%TYPE, b_orig_system_id wf_local_roles.orig_system_id%TYPE) IS
		  SELECT name
        FROM wf_local_roles
			 WHERE orig_system = b_orig_system
         AND orig_system_id = b_orig_system_id
         AND user_flag='N';

    l_group_rec c_group_members%ROWTYPE;
    l_team_rec  c_team_members%ROWTYPE;
    l_role_name wf_roles.NAME%TYPE;
    l_members   VARCHAR2(80)              := fnd_profile.VALUE('JTF_TASK_NOTIFY_MEMBERS');
  BEGIN
    l_role_name  := NULL;

    IF p_resource_type_code = 'RS_EMPLOYEE' THEN
      -- employee resource
      l_role_name  := jtf_rs_resource_pub.get_wf_role(p_resource_id);

      IF l_role_name IS NOT NULL THEN
        include_role(p_role_name => l_role_name);
      ELSE
        fnd_message.set_name('JTF', 'JTF_RS_ROLE_NOTFOUND');
        fnd_message.set_token('P_RESOURCE_NAME', get_resource_name(p_resource_type_code, p_resource_id));
        fnd_msg_pub.ADD;
      END IF;
    ELSIF p_resource_type_code IN('RS_GROUP', 'RS_TEAM') THEN
      -- group or team resource
      IF l_members = 'Y' THEN
        -- expand into individual members
        IF p_resource_type_code = 'RS_GROUP' THEN
          FOR l_group_rec IN c_group_members(p_resource_id) LOOP
            IF l_group_rec.resource_type_code = 'RS_EMPLOYEE' THEN
              -- employee resource
              l_role_name  := jtf_rs_resource_pub.get_wf_role(l_group_rec.resource_id);

              IF l_role_name IS NOT NULL THEN
                include_role(p_role_name => l_role_name);
              ELSE
                fnd_message.set_name('JTF', 'JTF_RS_ROLE_NOTFOUND');
                fnd_message.set_token('P_RESOURCE_NAME', get_resource_name(p_resource_type_code, p_resource_id));
                fnd_msg_pub.ADD;
              END IF;
            ELSIF l_group_rec.resource_type_code IN('RS_SUPPLIER_CONTACT', 'RS_PARTNER', 'RS_PARTY', 'PARTY_PERSON') THEN
              get_party_details(
                p_resource_id                => l_group_rec.resource_id
              , p_resource_type_code         => l_group_rec.resource_type_code
              , x_role_name                  => l_role_name
              );

              IF l_role_name IS NOT NULL THEN
                include_role(p_role_name => l_role_name);
              ELSE
                fnd_message.set_name('JTF', 'JTF_RS_ROLE_NOTFOUND');
                fnd_message.set_token('P_RESOURCE_NAME', get_resource_name(p_resource_type_code, p_resource_id));
                fnd_msg_pub.ADD;
              END IF;
            ELSE
              fnd_message.set_name('JTF', 'JTF_RS_ROLE_NOTFOUND');
              fnd_message.set_token('P_RESOURCE_NAME', get_resource_name(p_resource_type_code, p_resource_id));
              fnd_msg_pub.ADD;
            END IF;
          END LOOP;
        ELSIF p_resource_type_code = 'RS_TEAM' THEN
          FOR l_team_rec IN c_team_members(p_resource_id) LOOP
            IF l_team_rec.resource_type_code = 'RS_EMPLOYEE' THEN
              -- employee resource
              l_role_name  := jtf_rs_resource_pub.get_wf_role(l_team_rec.resource_id);

              IF l_role_name IS NOT NULL THEN
                include_role(p_role_name => l_role_name);
              ELSE
                fnd_message.set_name('JTF', 'JTF_RS_ROLE_NOTFOUND');
                fnd_message.set_token('P_RESOURCE_NAME', get_resource_name(p_resource_type_code, p_resource_id));
                fnd_msg_pub.ADD;
              END IF;
            ELSIF l_team_rec.resource_type_code IN('RS_SUPPLIER_CONTACT', 'RS_PARTNER', 'RS_PARTY', 'PARTY_PERSON') THEN
              get_party_details(
                p_resource_id         => l_team_rec.resource_id
              , p_resource_type_code  => l_team_rec.resource_type_code
              , x_role_name           => l_role_name
              );

              IF l_role_name IS NOT NULL THEN
                include_role(p_role_name => l_role_name);
              ELSE
                fnd_message.set_name('JTF', 'JTF_RS_ROLE_NOTFOUND');
                fnd_message.set_token('P_RESOURCE_NAME', get_resource_name(p_resource_type_code, p_resource_id));
                fnd_msg_pub.ADD;
              END IF;
            ELSE
              fnd_message.set_name('JTF', 'JTF_RS_ROLE_NOTFOUND');
              fnd_message.set_token('P_RESOURCE_NAME', get_resource_name(p_resource_type_code, p_resource_id));
              fnd_msg_pub.ADD;
            END IF;
          END LOOP;
        ELSE
          fnd_message.set_name('JTF', 'JTF_RS_ROLE_NOTFOUND');
          fnd_message.set_token('P_RESOURCE_NAME', get_resource_name(p_resource_type_code, p_resource_id));
          fnd_msg_pub.ADD;
        END IF;
      ELSE
        IF p_resource_type_code = 'RS_GROUP' THEN
          OPEN c_group_team_role('JRES_GRP', p_resource_id);
          FETCH c_group_team_role INTO l_role_name;
          CLOSE c_group_team_role;

          IF l_role_name IS NOT NULL Then
           include_role(p_role_name => l_role_name);
          ELSE
           fnd_message.set_name('JTF', 'JTF_RS_ROLE_NOTFOUND');
           fnd_message.set_token('P_RESOURCE_NAME', get_resource_name(p_resource_type_code, p_resource_id));
           fnd_msg_pub.add;
          END IF;
        ELSIF p_resource_type_code = 'RS_TEAM' THEN
          OPEN c_group_team_role('JRES_TEAM', p_resource_id);
          FETCH c_group_team_role INTO l_role_name;
          CLOSE c_group_team_role;

          IF l_role_name IS NOT NULL THEN
            include_role(p_role_name => l_role_name);
          ELSE
            fnd_message.set_name('JTF', 'JTF_RS_ROLE_NOTFOUND');
            fnd_message.set_token('P_RESOURCE_NAME', get_resource_name(p_resource_type_code, p_resource_id) );
            fnd_msg_pub.add;
          END IF;
        END IF;
      END IF;
    ELSIF p_resource_type_code IN('RS_SUPPLIER_CONTACT', 'RS_PARTNER', 'RS_PARTY', 'PARTY_PERSON') THEN
      get_party_details(
        p_resource_id        => p_resource_id
      , p_resource_type_code => p_resource_type_code
      , x_role_name          => l_role_name
      );

      IF l_role_name IS NOT NULL THEN
        include_role(p_role_name => l_role_name);
      ELSE
        fnd_message.set_name('JTF', 'JTF_RS_ROLE_NOTFOUND');
        fnd_message.set_token('P_RESOURCE_NAME', get_resource_name(p_resource_type_code, p_resource_id));
        fnd_msg_pub.ADD;
      END IF;
    ELSE
      fnd_message.set_name('JTF', 'JTF_RS_ROLE_NOTFOUND');
      fnd_message.set_token('P_RESOURCE_NAME', get_resource_name(p_resource_type_code, p_resource_id));
      fnd_msg_pub.ADD;
    END IF;
  END find_role;

  PROCEDURE set_text_attr(
    p_itemtype   IN VARCHAR2
  , p_itemkey    IN VARCHAR2
  , p_attr_name  IN VARCHAR2
  , p_attr_value IN VARCHAR2
  ) IS
    e_wf_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_wf_error, -20002);
  BEGIN
    ---
    --- Using this procedure to ignore Workflow error 3103 when an
    --- attribute does not exist
    ---
    wf_engine.setitemattrtext(
      itemtype => p_itemtype
    , itemkey  => p_itemkey
    , aname    => p_attr_name
    , avalue   => p_attr_value
    );
  EXCEPTION
    WHEN e_wf_error THEN
      IF SUBSTR(SQLERRM, 12, 4) = '3103' THEN
        NULL;
      ELSE
        RAISE;
      END IF;
  END set_text_attr;

  PROCEDURE set_num_attr(p_itemtype IN VARCHAR2, p_itemkey IN VARCHAR2, p_attr_name IN VARCHAR2, p_attr_value IN NUMBER) IS
    e_wf_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_wf_error, -20002);
  BEGIN
    ---
    --- Using this procedure to ignore Workflow error 3103 when an
    --- attribute does not exist
    ---
    wf_engine.setitemattrnumber(
      itemtype => p_itemtype
    , itemkey  => p_itemkey
    , aname    => p_attr_name
    , avalue   => p_attr_value
    );
  EXCEPTION
    WHEN e_wf_error THEN
      IF SUBSTR(SQLERRM, 12, 4) = '3103' THEN
        NULL;
      ELSE
        RAISE;
      END IF;
  END set_num_attr;

  PROCEDURE list_notify_roles(
    p_event             IN VARCHAR2
  , p_task_id           IN VARCHAR2
  , p_old_owner_id      IN NUMBER DEFAULT jtf_task_utl.g_miss_number
  , p_old_owner_code    IN VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_new_owner_id      IN NUMBER
  , p_new_owner_code    IN VARCHAR2
  , p_old_assignee_id   IN NUMBER DEFAULT jtf_task_utl.g_miss_number
  , p_old_assignee_code IN VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_new_assignee_id   IN NUMBER DEFAULT jtf_task_utl.g_miss_number
  , p_new_assignee_code IN VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  ) IS
    CURSOR c_assignees(b_task_id jtf_tasks_b.task_id%TYPE) IS
      SELECT resource_id
           , resource_type_code
        FROM jtf_task_all_assignments
       WHERE task_id = b_task_id AND assignee_role = 'ASSIGNEE';

    l_assignees c_assignees%ROWTYPE;
  BEGIN
    -- Always notify the current owner
    find_role(p_resource_id => p_new_owner_id, p_resource_type_code => p_new_owner_code);

    -- For DELETE_TASK, CHANGE_TASK_DETAILS and NO_UPDATE events, notify all assignees
    -- For CREATE_TASK, Assignees are not notified (Refer Bug# 4251583)
    IF p_event IN('DELETE_TASK', 'CHANGE_TASK_DETAILS', 'NO_UPDATE') THEN
      FOR l_assignees IN c_assignees(p_task_id) LOOP
        find_role(p_resource_id => l_assignees.resource_id, p_resource_type_code => l_assignees.resource_type_code);
      END LOOP;
    END IF;

    -- For CHANGE_OWNER notify the old owner
    IF p_event = 'CHANGE_OWNER' THEN
      find_role(p_resource_id => p_old_owner_id, p_resource_type_code => p_old_owner_code);
    END IF;

    -- For ADD_ASSIGNEE and CHANGE_ASSIGNEE notify the new assignee
    IF p_event IN('ADD_ASSIGNEE', 'CHANGE_ASSIGNEE') THEN
      find_role(p_resource_id => p_new_assignee_id, p_resource_type_code => p_new_assignee_code);
    END IF;

    -- For CHANGE_ASSIGNEE and DELETE_ASSIGNEE notify the old assignee
    IF p_event IN('CHANGE_ASSIGNEE', 'DELETE_ASSIGNEE') THEN
      find_role(p_resource_id => p_old_assignee_id, p_resource_type_code => p_old_assignee_code);
    END IF;
  END list_notify_roles;

  PROCEDURE abort_previous_wf(p_task_id IN NUMBER, p_workflow_process_id IN NUMBER) IS
    l_itemtype    VARCHAR2(8);
    l_itemkey     wf_item_activity_statuses.item_key%TYPE;
    l_context     VARCHAR2(100);
    wf_not_active EXCEPTION;
    l_end_date    DATE;
    l_result      VARCHAR2(1);

    CURSOR l_wf_date(b_itemtype VARCHAR2, b_itemkey wf_item_activity_statuses.item_key%TYPE) IS
      SELECT end_date
        FROM wf_items
       WHERE item_type = b_itemtype AND item_key = b_itemkey;
  BEGIN
    l_itemkey   := TO_CHAR(p_task_id) || '-' || TO_CHAR(p_workflow_process_id);
    l_itemtype  := 'JTFTASK';

    --
    -- An item is considered active if its end_date is NULL
    --
    OPEN l_wf_date(l_itemtype, l_itemkey);

    FETCH l_wf_date
     INTO l_end_date;

    IF ((l_wf_date%NOTFOUND) OR(l_end_date IS NOT NULL)) THEN
      l_result  := 'N';
    ELSE
      l_result  := 'Y';
    END IF;

    CLOSE l_wf_date;

    IF l_result = 'Y' THEN
      wf_engine.abortprocess(itemtype => l_itemtype, itemkey => l_itemkey);
    END IF;
  END abort_previous_wf;

  PROCEDURE create_notification(
    p_event                    IN            VARCHAR2
  , p_task_id                  IN            NUMBER
  , p_old_owner_id             IN            NUMBER DEFAULT jtf_task_utl.g_miss_number
  , p_old_owner_code           IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_old_assignee_id          IN            NUMBER DEFAULT jtf_task_utl.g_miss_number
  , p_old_assignee_code        IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_new_assignee_id          IN            NUMBER DEFAULT jtf_task_utl.g_miss_number
  , p_new_assignee_code        IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_old_type                 IN            NUMBER DEFAULT jtf_task_utl.g_miss_number
  , p_old_priority             IN            NUMBER DEFAULT jtf_task_utl.g_miss_number
  , p_old_status               IN            NUMBER DEFAULT jtf_task_utl.g_miss_number
  , p_old_planned_start_date   IN            DATE DEFAULT jtf_task_utl.g_miss_date
  , p_old_planned_end_date     IN            DATE DEFAULT jtf_task_utl.g_miss_date
  , p_old_scheduled_start_date IN            DATE DEFAULT jtf_task_utl.g_miss_date
  , p_old_scheduled_end_date   IN            DATE DEFAULT jtf_task_utl.g_miss_date
  , p_old_actual_start_date    IN            DATE DEFAULT jtf_task_utl.g_miss_date
  , p_old_actual_end_date      IN            DATE DEFAULT jtf_task_utl.g_miss_date
  , p_old_description          IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_abort_workflow           IN            VARCHAR2 DEFAULT fnd_profile.VALUE('JTF_TASK_ABORT_PREV_WF')
  , x_return_status            OUT NOCOPY    VARCHAR2
  , x_msg_count                OUT NOCOPY    NUMBER
  , x_msg_data                 OUT NOCOPY    VARCHAR2
  ) IS
    l_format_mask  CONSTANT VARCHAR2(80) := fnd_profile.VALUE('ICX_DATE_FORMAT_MASK') || ' HH24:MI:SS';

    l_process       jtf_task_types_b.workflow%TYPE;
    l_itemtype      VARCHAR2(8)  := 'JTFTASK';
    l_itemkey       wf_item_activity_statuses.item_key%TYPE;
    l_wf_process_id NUMBER;

    CURSOR c_task_details IS
      SELECT t.task_number
           , t.owner_id
           , t.owner_type_code
           , t.planned_start_date
           , t.planned_end_date
           , t.scheduled_start_date
           , t.scheduled_end_date
           , t.actual_start_date
           , t.actual_end_date
           , t.workflow_process_id
           , tl.task_name
           , tl.description
           , t.task_type_id
           , tt.name task_type_name
           , t.task_priority_id
           , tp.name task_priority_name
           , t.task_status_id
           , ts.name task_status_name
        FROM jtf_tasks_b t
           , jtf_tasks_tl tl
           , jtf_task_statuses_tl ts
           , jtf_task_types_tl tt
           , jtf_task_priorities_tl tp
       WHERE t.task_id = p_task_id
         AND tl.language = userenv('LANG')
         AND tl.task_id = t.task_id
         AND ts.task_status_id(+) = t.task_status_id
         AND ts.language(+) = userenv('LANG')
         AND tt.task_type_id(+) = t.task_type_id
         AND tt.language(+) = userenv('LANG')
         AND tp.task_priority_id(+) = t.task_priority_id
         AND tp.language(+) = userenv('LANG');

    CURSOR c_wf_processs_id IS
      SELECT jtf_task_workflow_process_s.NEXTVAL
        FROM DUAL;

    CURSOR c_type_name(b_type jtf_tasks_b.task_type_id%TYPE) IS
      SELECT NAME
        FROM jtf_task_types_vl
       WHERE task_type_id = b_type;

    CURSOR c_priority_name(b_priority jtf_tasks_b.task_priority_id%TYPE) IS
      SELECT NAME
        FROM jtf_task_priorities_vl
       WHERE task_priority_id = b_priority;

    CURSOR c_status_name(b_status jtf_tasks_b.task_status_id%TYPE) IS
      SELECT NAME
        FROM jtf_task_statuses_vl
       WHERE task_status_id = b_status;

    CURSOR c_logged_res_id IS
    SELECT resource_id
      FROM jtf_rs_resource_extns
     WHERE user_id = fnd_global.user_id;

    l_task_rec                c_task_details%ROWTYPE;

    l_old_type_name           jtf_task_types_tl.name%TYPE;
    l_old_priority_name       jtf_task_priorities_tl.name%TYPE;
    l_old_status_name         jtf_task_statuses_tl.name%TYPE;
    l_old_desc                jtf_tasks_tl.description%TYPE;

    l_type_change_text        VARCHAR2(70);
    l_status_change_text      VARCHAR2(70);
    l_priority_change_text    VARCHAR2(70);
    l_pln_start_change_text   VARCHAR2(100);
    l_pln_end_change_text     VARCHAR2(100);
    l_sch_start_change_text   VARCHAR2(100);
    l_sch_end_change_text     VARCHAR2(100);
    l_act_start_change_text   VARCHAR2(100);
    l_act_end_change_text     VARCHAR2(100);

    l_old_date                VARCHAR2(50);
    l_not_entered             VARCHAR2(2000);

    l_task_text               VARCHAR2(1050);
    l_backcomp_flag           VARCHAR2(1);

    l_logged_res_id           jtf_rs_resource_extns.resource_id%TYPE;

    l_wf_items      VARCHAR2(500);
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    -- check whether we need to be backward-compatible for this Workflow
    l_backcomp_flag := check_backcomp(p_itemtype => 'JTFTASK');

    IF l_backcomp_flag = 'Y' AND p_event IN('CREATE_TASK', 'DELETE_TASK') THEN
      -- previous functionality did not have CREATE_TASK or DELETE_TASK events,
      -- so we can bail out now
      RETURN;
    END IF;

    l_wf_items := wf_process(p_task_id => p_task_id);

    OPEN c_task_details;
    FETCH c_task_details INTO l_task_rec;
    IF c_task_details%NOTFOUND THEN
      CLOSE c_task_details;
      RETURN;
    END IF;
    CLOSE c_task_details;

    OPEN  c_logged_res_id;
    FETCH c_logged_res_id INTO l_logged_res_id;
    CLOSE c_logged_res_id;

    l_itemtype := SUBSTR(l_wf_items, 1, INSTR(l_wf_items, ',') - 1);
    l_process  := SUBSTR(l_wf_items, INSTR(l_wf_items, ',') + 1);

    --- Set global attributes so we can use this data later
    jtf_task_wf_util.g_event              := p_event;
    jtf_task_wf_util.g_task_id            := p_task_id;
    jtf_task_wf_util.g_old_owner_id       := p_old_owner_id;
    jtf_task_wf_util.g_old_owner_code     := p_old_owner_code;
    jtf_task_wf_util.g_owner_id           := l_task_rec.owner_id;
    jtf_task_wf_util.g_owner_type_code    := l_task_rec.owner_type_code;
    jtf_task_wf_util.g_old_assignee_id    := p_old_assignee_id;
    jtf_task_wf_util.g_old_assignee_code  := p_old_assignee_code;
    jtf_task_wf_util.g_new_assignee_id    := p_new_assignee_id;
    jtf_task_wf_util.g_new_assignee_code  := p_new_assignee_code;

    -- Get the Translated Text for 'Not Entered' from message dictionary
    fnd_message.set_name('JTF', 'JTF_TASK_DATA_NOT_ENTERED');
    l_not_entered := fnd_message.get;

    l_type_change_text      := l_task_rec.task_type_name;
    l_status_change_text    := l_task_rec.task_status_name;

    l_priority_change_text  := NVL(l_task_rec.task_priority_name, l_not_entered);
    l_task_rec.description  := NVL(l_task_rec.description, l_not_entered);

    l_pln_start_change_text := NVL(TO_CHAR(l_task_rec.planned_start_date, l_format_mask), l_not_entered);
    l_pln_end_change_text   := NVL(TO_CHAR(l_task_rec.planned_end_date, l_format_mask), l_not_entered);
    l_sch_start_change_text := NVL(TO_CHAR(l_task_rec.scheduled_start_date, l_format_mask), l_not_entered);
    l_sch_end_change_text   := NVL(TO_CHAR(l_task_rec.scheduled_end_date, l_format_mask), l_not_entered);
    l_act_start_change_text := NVL(TO_CHAR(l_task_rec.actual_start_date, l_format_mask), l_not_entered);
    l_act_end_change_text   := NVL(TO_CHAR(l_task_rec.actual_end_date, l_format_mask), l_not_entered);

    -- Find out the changed Attributes in the Task
    IF p_event = 'CHANGE_TASK_DETAILS' THEN
      l_old_desc  := NVL(p_old_description, l_not_entered);

      -- Task Type
      IF p_old_type NOT IN(l_task_rec.task_type_id, jtf_task_utl.g_miss_number) THEN
        OPEN c_type_name(p_old_type);
        FETCH c_type_name INTO l_old_type_name;
        IF c_type_name%NOTFOUND THEN
          l_old_type_name  := NULL;
        END IF;
        CLOSE c_type_name;

        -- for backward compatibility
        IF l_backcomp_flag = 'Y' THEN
          l_task_text  := l_task_text || 'Task Type             ' || l_task_rec.task_type_name || '             ' || l_old_type_name;
        END IF;

        l_task_rec.task_type_name := l_task_rec.task_type_name || ' (' || l_old_type_name || ')';
      END IF;

      -- Task Priority
      IF l_task_rec.task_priority_id IS NULL THEN
        l_task_rec.task_priority_name  := l_not_entered;
      END IF;

      IF p_old_priority IS NULL THEN
        IF l_task_rec.task_priority_id IS NOT NULL THEN
          l_task_rec.task_priority_name  := l_task_rec.task_priority_name || ' (' || l_not_entered || ')';
        END IF;
      ELSIF p_old_priority NOT IN(NVL(l_task_rec.task_priority_id, 0), jtf_task_utl.g_miss_number) THEN
        OPEN c_priority_name(p_old_priority);
        FETCH c_priority_name INTO l_old_priority_name;
        IF c_priority_name%NOTFOUND THEN
          l_old_priority_name := NULL;
        END IF;
        CLOSE c_priority_name;

        l_task_rec.task_priority_name := l_task_rec.task_priority_name || ' (' || l_old_priority_name || ')';
      END IF;

      -- Task Status
      IF p_old_status NOT IN(l_task_rec.task_status_id, jtf_task_utl.g_miss_number) THEN
        OPEN c_status_name(p_old_status);
        FETCH c_status_name INTO l_old_status_name;
        IF c_status_name%NOTFOUND THEN
          l_old_status_name  := NULL;
        END IF;
        CLOSE c_status_name;

        -- for backward compatibility
        IF l_backcomp_flag = 'Y' THEN
          l_task_text  := l_task_text || 'Status Type             ' || l_task_rec.task_status_name || '             ' || l_old_status_name;
        END IF;

        l_task_rec.task_status_name := l_task_rec.task_status_name || ' (' || l_old_status_name || ')';
      END IF;

      -- Planned Start Date
      IF (p_old_planned_start_date NOT IN (l_task_rec.planned_start_date, jtf_task_utl.g_miss_date))
         OR (p_old_planned_start_date IS NULL AND l_task_rec.planned_start_date IS NOT NULL)
      THEN
        IF p_old_planned_start_date IS NULL THEN
          l_old_date  := l_not_entered;
        ELSE
          l_old_date  := TO_CHAR(p_old_planned_start_date, l_format_mask);
        END IF;

        -- for backward compatibility
        IF l_backcomp_flag = 'Y' THEN
          l_task_text  := l_task_text || 'Planned Start Date             ' || l_pln_start_change_text || '             ' || l_old_date;
        END IF;

        l_pln_start_change_text  := l_pln_start_change_text || ' (' || l_old_date || ')';
      END IF;

      -- Planned End Date
      IF (p_old_planned_end_date NOT IN (l_task_rec.planned_end_date, jtf_task_utl.g_miss_date))
         OR (p_old_planned_end_date IS NULL AND l_task_rec.planned_end_date IS NOT NULL)
      THEN
        IF p_old_planned_end_date IS NULL THEN
          l_old_date  := l_not_entered;
        ELSE
          l_old_date  := TO_CHAR(p_old_planned_end_date, l_format_mask);
        END IF;

        -- for backward compatibility
        IF l_backcomp_flag = 'Y' THEN
          l_task_text  := l_task_text || 'Planned End Date             ' || l_pln_end_change_text || '             ' || l_old_date;
        END IF;

        l_pln_end_change_text  := l_pln_end_change_text || ' (' || l_old_date || ')';
      END IF;

      -- Scheduled Start Date
      IF ( p_old_scheduled_start_date NOT IN (l_task_rec.scheduled_start_date, jtf_task_utl.g_miss_date) )
         OR (p_old_scheduled_start_date IS NULL AND l_task_rec.scheduled_start_date IS NOT NULL)
      THEN
        IF p_old_scheduled_start_date IS NULL THEN
          l_old_date  := l_not_entered;
        ELSE
          l_old_date  := TO_CHAR(p_old_scheduled_start_date, l_format_mask);
        END IF;

        -- for backward compatibility
        IF l_backcomp_flag = 'Y' THEN
          l_task_text  := l_task_text || 'Scheduled Start Date             ' || l_sch_start_change_text || '             ' || l_old_date;
        END IF;

        l_sch_start_change_text  := l_sch_start_change_text || ' (' || l_old_date || ')';
      END IF;

      -- Scheduled End Date
      IF ( p_old_scheduled_end_date NOT IN (l_task_rec.scheduled_end_date, jtf_task_utl.g_miss_date) )
         OR (p_old_scheduled_end_date IS NULL AND l_task_rec.scheduled_end_date IS NOT NULL)
      THEN
        IF p_old_scheduled_end_date IS NULL THEN
          l_old_date  := l_not_entered;
        ELSE
          l_old_date  := TO_CHAR(p_old_scheduled_end_date, l_format_mask);
        END IF;

        -- for backward compatibility
        IF l_backcomp_flag = 'Y' THEN
          l_task_text  := l_task_text || 'Scheduled End Date             ' || l_sch_end_change_text || '             ' || l_old_date;
        END IF;

        l_sch_end_change_text  := l_sch_end_change_text || ' (' || l_old_date || ')';
      END IF;

      -- Actual Start Date
      IF ( p_old_actual_start_date NOT IN (l_task_rec.actual_start_date, jtf_task_utl.g_miss_date) )
         OR (p_old_actual_start_date IS NULL AND l_task_rec.actual_start_date IS NOT NULL)
      THEN
        IF p_old_actual_start_date IS NULL THEN
          l_old_date  := l_not_entered;
        ELSE
          l_old_date  := TO_CHAR(p_old_actual_start_date, l_format_mask);
        END IF;

        l_act_start_change_text  := l_act_start_change_text || ' (' || l_old_date || ')';
      END IF;

      -- Actual End Date
      IF ( p_old_actual_end_date NOT IN (l_task_rec.actual_end_date, jtf_task_utl.g_miss_date) )
         OR (p_old_actual_end_date IS NULL AND l_task_rec.actual_end_date IS NOT NULL)
      THEN
        IF p_old_actual_end_date IS NULL THEN
          l_old_date  := l_not_entered;
        ELSE
          l_old_date  := TO_CHAR(p_old_actual_end_date, l_format_mask);
        END IF;

        l_act_end_change_text  := l_act_end_change_text || ' (' || l_old_date || ')';
      END IF;
    END IF;

    jtf_task_wf_util.notiflist.DELETE;

    -- Abort the previous WF if the parameter is set
    IF p_abort_workflow = 'Y' AND l_task_rec.workflow_process_id IS NOT NULL THEN
      abort_previous_wf(p_task_id => p_task_id, p_workflow_process_id => l_task_rec.workflow_process_id);
    END IF;

    -- Create the itemkey for the WF process
    OPEN c_wf_processs_id;
    FETCH c_wf_processs_id INTO l_wf_process_id;
    CLOSE c_wf_processs_id;

    l_itemkey := TO_CHAR(p_task_id) || '-' || TO_CHAR(l_wf_process_id);

    -- initialise the WF using the itemkey
    wf_engine.createprocess(itemtype => l_itemtype, itemkey => l_itemkey, process => l_process);
    wf_engine.setitemuserkey(itemtype => l_itemtype, itemkey => l_itemkey, userkey => l_task_rec.task_name);

    set_text_attr(l_itemtype, l_itemkey, 'MESSAGE_NAME', 'MESSAGE_' || p_event);
    set_text_attr(l_itemtype, l_itemkey, 'TASK_EVENT', p_event);
    set_text_attr(l_itemtype, l_itemkey, 'TASK_ID', p_task_id);
    set_text_attr(l_itemtype, l_itemkey, 'TASK_NUMBER', l_task_rec.task_number);
    set_text_attr(l_itemtype, l_itemkey, 'TASK_NAME', l_task_rec.task_name);
    set_text_attr(l_itemtype, l_itemkey, 'TASK_TYPE_NAME', l_type_change_text);
    set_text_attr(l_itemtype, l_itemkey, 'TASK_PRIORITY_NAME', l_priority_change_text);
    set_text_attr(l_itemtype, l_itemkey, 'TASK_STATUS_NAME', l_status_change_text);
    set_text_attr(l_itemtype, l_itemkey, 'TASK_DESC', l_task_rec.description);
    set_text_attr(l_itemtype, l_itemkey, 'PLANNED_START_DATE', l_pln_start_change_text);
    set_text_attr(l_itemtype, l_itemkey, 'PLANNED_END_DATE', l_pln_end_change_text);
    set_text_attr(l_itemtype, l_itemkey, 'SCHEDULED_START_DATE', l_sch_start_change_text);
    set_text_attr(l_itemtype, l_itemkey, 'SCHEDULED_END_DATE', l_sch_end_change_text);
    set_text_attr(l_itemtype, l_itemkey, 'ACTUAL_START_DATE', l_act_start_change_text);
    set_text_attr(l_itemtype, l_itemkey, 'ACTUAL_END_DATE', l_act_end_change_text);
    set_text_attr(l_itemtype, l_itemkey, 'PREV_PROCESS_ID', l_task_rec.workflow_process_id);
    set_text_attr(l_itemtype, l_itemkey, 'MESSAGE_SENDER', jtf_rs_resource_pub.get_wf_role(l_logged_res_id));

    IF p_event IN('DELETE_TASK', 'CHANGE_OWNER') THEN
      -- set the old owner
      set_text_attr(
        l_itemtype
      , l_itemkey
      , 'OLD_TASK_OWNER_NAME'
      , get_resource_name(p_old_owner_code, p_old_owner_id)
      );
    END IF;

    IF p_event IN('DELETE_TASK', 'CHANGE_OWNER') THEN
      -- set the old owner
      IF p_event = 'DELETE_TASK' THEN
        set_text_attr(
          l_itemtype
        , l_itemkey
        , 'OLD_TASK_OWNER_NAME'
        , get_resource_name(l_task_rec.owner_type_code, l_task_rec.owner_id)
        );
      ELSE
        set_text_attr(
          l_itemtype
        , l_itemkey
        , 'OLD_TASK_OWNER_NAME'
        , get_resource_name(p_old_owner_code, p_old_owner_id)
        );
      END IF;
    END IF;

    IF p_event <> 'DELETE_TASK' THEN
      -- set the new owner
      set_text_attr(
        l_itemtype
      , l_itemkey
      , 'NEW_TASK_OWNER_NAME'
      , get_resource_name(l_task_rec.owner_type_code, l_task_rec.owner_id)
      );

      set_text_attr(
        l_itemtype
      , l_itemkey
      , 'OWNER_NAME'
      , get_resource_name(l_task_rec.owner_type_code, l_task_rec.owner_id)
      );
    END IF;

    IF p_event IN('CHANGE_ASSIGNEE', 'DELETE_ASSIGNEE') THEN
      -- set the old assignee
      set_text_attr(
        l_itemtype
      , l_itemkey
      , 'OLD_TASK_ASSIGNEE_NAME'
      , get_resource_name(p_old_assignee_code, p_old_assignee_id)
      );
    END IF;

    IF p_event IN('ADD_ASSIGNEE', 'CHANGE_ASSIGNEE') THEN
      -- set the new assignee
      set_text_attr(
        l_itemtype
      , l_itemkey
      , 'NEW_TASK_ASSIGNEE_NAME'
      , get_resource_name(p_new_assignee_code, p_new_assignee_id)
      );
    END IF;

    -- for backward compatibility
    IF l_backcomp_flag = 'Y' THEN
      -- set the old owner
      IF p_event IN('DELETE_TASK', 'CHANGE_OWNER')  AND p_old_owner_code = 'RS_EMPLOYEE' THEN
        set_text_attr(
          l_itemtype
        , l_itemkey
        , 'OLD_TASK_OWNER_ID'
        , jtf_rs_resource_pub.get_wf_role(p_old_owner_id)
        );
      END IF;

      -- set the new owner
      IF p_event <> 'DELETE_TASK' AND l_task_rec.owner_type_code = 'RS_EMPLOYEE' THEN
        set_text_attr(
          l_itemtype
        , l_itemkey
        , 'NEW_TASK_OWNER_ID'
        , jtf_rs_resource_pub.get_wf_role(l_task_rec.owner_id)
        );

        set_text_attr(
          l_itemtype
        , l_itemkey
        , 'OWNER_ID'
        , jtf_rs_resource_pub.get_wf_role(l_task_rec.owner_id)
        );
      END IF;

      -- set the old assignee
      IF p_event IN('CHANGE_ASSIGNEE', 'DELETE_ASSIGNEE') AND p_old_assignee_code = 'RS_EMPLOYEE' THEN
        set_text_attr(
          l_itemtype
        , l_itemkey
        , 'OLD_TASK_ASSIGNEE_ID'
        , jtf_rs_resource_pub.get_wf_role(p_old_assignee_id)
        );
      END IF;

      -- set the new assignee
      IF p_event IN('ADD_ASSIGNEE', 'CHANGE_ASSIGNEE') AND p_new_assignee_code = 'RS_EMPLOYEE' THEN
        set_text_attr(
          l_itemtype
        , l_itemkey
        , 'NEW_TASK_ASSIGNEE_ID'
        , jtf_rs_resource_pub.get_wf_role(p_new_assignee_id)
        );
      END IF;

      -- Task Details
      IF p_event = 'CHANGE_TASK_DETAILS' THEN
        set_text_attr(
          l_itemtype
        , l_itemkey
        , 'TASK_TEXT'
        , l_task_text
        );
      END IF;

      IF p_event = 'ADD_ASSIGNEE' THEN
        set_text_attr(
          l_itemtype
        , l_itemkey
        , 'EVENT'
        , 'NOTIFY_NEW_ASSIGNEE'
        );
      ELSIF p_event = 'DELETE_ASSIGNEE' THEN
        set_text_attr(
          l_itemtype
        , l_itemkey
        , 'EVENT'
        , 'ASSIGNEE_REMOVAL'
        );
      ELSIF p_event IN('CHANGE_OWNER', 'CHANGE_ASSIGNEE', 'CHANGE_TASK_DETAILS') THEN
        set_text_attr(
          l_itemtype
        , l_itemkey
        , 'EVENT'
        , p_event
        );
      END IF;
    END IF;

    wf_engine.startprocess(itemtype => l_itemtype, itemkey => l_itemkey);

    UPDATE jtf_tasks_b
       SET workflow_process_id = l_wf_process_id
     WHERE task_id = p_task_id;
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'CREATE_NOTIFICATION');
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END create_notification;

  PROCEDURE set_notif_message(
    itemtype  IN            VARCHAR2
  , itemkey   IN            VARCHAR2
  , actid     IN            NUMBER
  , funcmode  IN            VARCHAR2
  , resultout OUT NOCOPY    VARCHAR2
  ) IS
    l_event VARCHAR2(200);
  BEGIN
    IF funcmode = 'RUN' THEN
      l_event    := wf_engine.getitemattrtext(itemtype => itemtype, itemkey => itemkey, aname => 'TASK_EVENT');
      set_text_attr(
        p_itemtype                   => itemtype
      , p_itemkey                    => itemkey
      , p_attr_name                  => 'MESSAGE_NAME'
      , p_attr_value                 => 'NOTIFY_' || l_event
      );
      resultout  := 'COMPLETE';
      RETURN;
    END IF;

    IF funcmode = 'CANCEL' THEN
      resultout  := 'COMPLETE';
      RETURN;
    END IF;

    IF funcmode = 'TIMEOUT' THEN
      resultout  := 'COMPLETE';
      RETURN;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      wf_core.CONTEXT(g_pkg_name, 'Set_Notif_Message', itemtype, itemkey, TO_CHAR(actid), funcmode);
      RAISE;
  END set_notif_message;

  PROCEDURE set_notif_performer(
    itemtype  IN            VARCHAR2
  , itemkey   IN            VARCHAR2
  , actid     IN            NUMBER
  , funcmode  IN            VARCHAR2
  , resultout OUT NOCOPY    VARCHAR2
  ) IS
    l_counter BINARY_INTEGER;
    l_role    wf_roles.NAME%TYPE;
  BEGIN
    IF funcmode = 'RUN' THEN
      l_counter  := wf_engine.getitemattrnumber(itemtype => itemtype, itemkey => itemkey, aname => 'LIST_COUNTER');
      l_role     := jtf_task_wf_util.notiflist(l_counter).NAME;

      IF l_role IS NOT NULL THEN
        set_text_attr(p_itemtype       => itemtype, p_itemkey => itemkey, p_attr_name => 'MESSAGE_RECIPIENT'
        , p_attr_value                 => l_role);
      END IF;

      l_counter  := l_counter + 1;
      set_num_attr(
        p_itemtype   => itemtype
      , p_itemkey    => itemkey
      , p_attr_name  => 'LIST_COUNTER'
      , p_attr_value => l_counter
      );
      resultout  := 'COMPLETE';
      RETURN;
    END IF;

    IF funcmode = 'CANCEL' THEN
      resultout  := 'COMPLETE';
      RETURN;
    END IF;

    IF funcmode = 'TIMEOUT' THEN
      resultout  := 'COMPLETE';
      RETURN;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      wf_core.CONTEXT(g_pkg_name, 'Set_Notif_Performer', itemtype, itemkey, TO_CHAR(actid), funcmode);
      RAISE;
  END set_notif_performer;

  PROCEDURE set_notif_list(
    itemtype  IN            VARCHAR2
  , itemkey   IN            VARCHAR2
  , actid     IN            NUMBER
  , funcmode  IN            VARCHAR2
  , resultout OUT NOCOPY    VARCHAR2
  ) IS
    l_counter BINARY_INTEGER;
  BEGIN
    IF funcmode = 'RUN' THEN
      -------------------------------------------------------------------------
      -- Set the Notification List
      -------------------------------------------------------------------------
      list_notify_roles(
        p_event                      => jtf_task_wf_util.g_event
      , p_task_id                    => jtf_task_wf_util.g_task_id
      , p_old_owner_id               => jtf_task_wf_util.g_old_owner_id
      , p_old_owner_code             => jtf_task_wf_util.g_old_owner_code
      , p_new_owner_id               => jtf_task_wf_util.g_owner_id
      , p_new_owner_code             => jtf_task_wf_util.g_owner_type_code
      , p_old_assignee_id            => jtf_task_wf_util.g_old_assignee_id
      , p_old_assignee_code          => jtf_task_wf_util.g_old_assignee_code
      , p_new_assignee_id            => jtf_task_wf_util.g_new_assignee_id
      , p_new_assignee_code          => jtf_task_wf_util.g_new_assignee_code
      );

      IF jtf_task_wf_util.notiflist.COUNT > 0 THEN
        -------------------------------------------------------------------------
        -- Set the process counters
        -------------------------------------------------------------------------
        l_counter  := jtf_task_wf_util.notiflist.COUNT;
        set_num_attr(
          p_itemtype => itemtype
        , p_itemkey => itemkey
        , p_attr_name => 'LIST_COUNTER'
        , p_attr_value => 1
        );
        set_num_attr(
          p_itemtype   => itemtype
        , p_itemkey    => itemkey
        , p_attr_name  => 'PERFORMER_LIMIT'
        , p_attr_value => l_counter
        );
        resultout  := 'COMPLETE:T';
      ELSE
        resultout  := 'COMPLETE:F';
      END IF;

      RETURN;
    END IF;

    IF funcmode = 'CANCEL' THEN
      resultout  := 'COMPLETE:F';
      RETURN;
    END IF;

    IF funcmode = 'TIMEOUT' THEN
      resultout  := 'COMPLETE:F';
      RETURN;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      wf_core.CONTEXT(g_pkg_name, 'Set_Notif_List', itemtype, itemkey, TO_CHAR(actid), funcmode);
      RAISE;
  END set_notif_list;
END jtf_task_wf_util;

/
