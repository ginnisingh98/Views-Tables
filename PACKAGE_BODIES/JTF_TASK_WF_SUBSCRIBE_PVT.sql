--------------------------------------------------------
--  DDL for Package Body JTF_TASK_WF_SUBSCRIBE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_WF_SUBSCRIBE_PVT" AS
  /* $Header: jtftkwkb.pls 120.1.12000000.2 2007/10/04 14:16:11 venjayar ship $ */
  FUNCTION create_task_notif_subs(p_subscription_guid IN RAW, p_event IN OUT NOCOPY wf_event_t)
    RETURN VARCHAR2 IS
    l_task_id                 jtf_tasks_b.task_id%TYPE;
    l_source_object_type_code jtf_tasks_b.source_object_type_code%TYPE;
    l_enable_workflow         VARCHAR2(1);
    l_abort_workflow          VARCHAR2(1);
    x_return_status           VARCHAR2(200);
    x_msg_count               NUMBER;
    x_msg_data                VARCHAR2(1000);
  BEGIN
    l_task_id                  := wf_event.getvalueforparameter('TASK_ID', p_event.parameter_list);
    l_enable_workflow          := wf_event.getvalueforparameter('ENABLE_WORKFLOW', p_event.parameter_list);
    l_abort_workflow           := wf_event.getvalueforparameter('ABORT_WORKFLOW', p_event.parameter_list);
    l_source_object_type_code  := wf_event.getvalueforparameter('SOURCE_OBJECT_TYPE_CODE', p_event.parameter_list);

    IF (l_source_object_type_code <> 'APPOINTMENT') THEN
      IF (l_enable_workflow = 'Y') THEN
        IF (jtf_task_wf_util.do_notification(l_task_id)) THEN
          jtf_task_wf_util.create_notification(
            p_event                      => 'CREATE_TASK'
          , p_task_id                    => l_task_id
          , p_abort_workflow             => l_abort_workflow
          , x_return_status              => x_return_status
          , x_msg_count                  => x_msg_count
          , x_msg_data                   => x_msg_data
          );
        END IF;
      END IF;
    END IF;

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      wf_core.CONTEXT('jtf_task_wf_subscribe_pvt', 'create_task_notif_subs', p_event.event_name, p_subscription_guid);
      wf_event.seterrorinfo(p_event, 'WARNING');
      RETURN 'WARNING';
    END IF;

    RETURN 'SUCCESS';
  EXCEPTION
    WHEN OTHERS THEN
      wf_core.CONTEXT('jtf_task_wf_subscribe_pvt', 'create_task_notif_subs', p_event.event_name, p_subscription_guid);
      wf_event.seterrorinfo(p_event, 'WARNING');
      RETURN 'WARNING';
  END create_task_notif_subs;

  FUNCTION update_task_notif_subs(p_subscription_guid IN RAW, p_event IN OUT NOCOPY wf_event_t)
    RETURN VARCHAR2 IS
    l_task_id                 jtf_tasks_b.task_id%TYPE;
    l_task_audit_id           jtf_task_audits_b.task_audit_id%TYPE;
    l_source_object_type_code jtf_tasks_b.source_object_type_code%TYPE;
    l_enable_workflow         VARCHAR2(1);
    l_abort_workflow          VARCHAR2(1);
    x_return_status           VARCHAR2(200);
    x_msg_count               NUMBER;
    x_msg_data                VARCHAR2(1000);

    CURSOR c_task_detail(b_task_audit_id IN NUMBER) IS
      SELECT new_task_type_id
           , old_task_type_id
           , new_task_status_id
           , old_task_status_id
           , new_description
           , old_description
           , new_task_priority_id
           , old_task_priority_id
           , new_planned_start_date
           , old_planned_start_date
           , new_planned_end_date
           , old_planned_end_date
           , new_scheduled_start_date
           , old_scheduled_start_date
           , new_scheduled_end_date
           , old_scheduled_end_date
           , new_actual_start_date
           , old_actual_start_date
           , new_actual_end_date
           , old_actual_end_date
           , new_owner_id
           , old_owner_id
           , new_owner_type_code
           , old_owner_type_code
        FROM jtf_task_audits_vl
       WHERE task_audit_id = b_task_audit_id;

    rec_task                  c_task_detail%ROWTYPE;
  BEGIN
    l_task_id                  := wf_event.getvalueforparameter('TASK_ID', p_event.parameter_list);
    l_task_audit_id            := wf_event.getvalueforparameter('TASK_AUDIT_ID', p_event.parameter_list);
    l_enable_workflow          := wf_event.getvalueforparameter('ENABLE_WORKFLOW', p_event.parameter_list);
    l_abort_workflow           := wf_event.getvalueforparameter('ABORT_WORKFLOW', p_event.parameter_list);
    l_source_object_type_code  := wf_event.getvalueforparameter('SOURCE_OBJECT_TYPE_CODE', p_event.parameter_list);

    OPEN c_task_detail(l_task_audit_id);

    FETCH c_task_detail
     INTO rec_task;

    CLOSE c_task_detail;

    IF (l_source_object_type_code <> 'APPOINTMENT') THEN
      IF (l_enable_workflow = 'Y') THEN
        IF    compare_old_new_param(rec_task.new_task_type_id, rec_task.old_task_type_id)
           OR compare_old_new_param(rec_task.new_task_status_id, rec_task.old_task_status_id)
           OR compare_old_new_param(rec_task.new_description, rec_task.old_description)
           OR compare_old_new_param(rec_task.new_task_priority_id, rec_task.old_task_priority_id)
           OR compare_old_new_param(rec_task.new_planned_start_date, rec_task.old_planned_start_date)
           OR compare_old_new_param(rec_task.new_planned_end_date, rec_task.old_planned_end_date)
           OR compare_old_new_param(rec_task.new_scheduled_start_date, rec_task.old_scheduled_start_date)
           OR compare_old_new_param(rec_task.new_scheduled_end_date, rec_task.old_scheduled_end_date)
           OR compare_old_new_param(rec_task.new_actual_start_date, rec_task.old_actual_start_date)
           OR compare_old_new_param(rec_task.new_actual_end_date, rec_task.old_actual_end_date)
        THEN
          IF (jtf_task_wf_util.do_notification(l_task_id)) THEN
            jtf_task_wf_util.create_notification(
              p_event                      => 'CHANGE_TASK_DETAILS'
            , p_task_id                    => l_task_id
            , p_old_type                   => rec_task.old_task_type_id
            , p_old_priority               => rec_task.old_task_priority_id
            , p_old_status                 => rec_task.old_task_status_id
            , p_old_planned_start_date     => rec_task.old_planned_start_date
            , p_old_planned_end_date       => rec_task.old_planned_end_date
            , p_old_scheduled_start_date   => rec_task.old_scheduled_start_date
            , p_old_scheduled_end_date     => rec_task.old_scheduled_end_date
            , p_old_actual_start_date      => rec_task.old_actual_start_date
            , p_old_actual_end_date        => rec_task.old_actual_end_date
            , p_old_description            => rec_task.old_description
            , p_old_owner_id               => rec_task.old_owner_id
            , p_old_owner_code             => rec_task.old_owner_type_code
            , p_abort_workflow             => l_abort_workflow
            , x_return_status              => x_return_status
            , x_msg_count                  => x_msg_count
            , x_msg_data                   => x_msg_data
            );
          END IF;
        END IF;
      END IF;
    END IF;

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      wf_core.CONTEXT('jtf_task_wf_subscribe_pvt', 'update_task_notif_subs', p_event.event_name, p_subscription_guid);
      wf_event.seterrorinfo(p_event, 'WARNING');
      RETURN 'WARNING';
    END IF;

    RETURN 'SUCCESS';
  EXCEPTION
    WHEN OTHERS THEN
      wf_core.CONTEXT('jtf_task_wf_subscribe_pvt', 'update_task_notif_subs', p_event.event_name, p_subscription_guid);
      wf_event.seterrorinfo(p_event, 'WARNING');
      RETURN 'WARNING';
  END update_task_notif_subs;

  FUNCTION delete_task_notif_subs(p_subscription_guid IN RAW, p_event IN OUT NOCOPY wf_event_t)
    RETURN VARCHAR2 IS
    l_task_id                 jtf_tasks_b.task_id%TYPE;
    l_source_object_type_code jtf_tasks_b.source_object_type_code%TYPE;
    l_enable_workflow         VARCHAR2(1);
    l_abort_workflow          VARCHAR2(1);
    x_return_status           VARCHAR2(200);
    x_msg_count               NUMBER;
    x_msg_data                VARCHAR2(1000);
  BEGIN
    l_task_id                  := wf_event.getvalueforparameter('TASK_ID', p_event.parameter_list);
    l_enable_workflow          := wf_event.getvalueforparameter('ENABLE_WORKFLOW', p_event.parameter_list);
    l_abort_workflow           := wf_event.getvalueforparameter('ABORT_WORKFLOW', p_event.parameter_list);
    l_source_object_type_code  := wf_event.getvalueforparameter('SOURCE_OBJECT_TYPE_CODE', p_event.parameter_list);

    IF (l_source_object_type_code <> 'APPOINTMENT') THEN
      IF (l_enable_workflow = 'Y') THEN
        IF (jtf_task_wf_util.do_notification(l_task_id)) THEN
          jtf_task_wf_util.create_notification(
            p_event                      => 'DELETE_TASK'
          , p_task_id                    => l_task_id
          , p_abort_workflow             => l_abort_workflow
          , x_return_status              => x_return_status
          , x_msg_count                  => x_msg_count
          , x_msg_data                   => x_msg_data
          );
        END IF;
      END IF;
    END IF;

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      wf_core.CONTEXT('jtf_task_wf_subscribe_pvt', 'delete_task_notif_subs', p_event.event_name, p_subscription_guid);
      wf_event.seterrorinfo(p_event, 'WARNING');
      RETURN 'WARNING';
    END IF;

    RETURN 'SUCCESS';
  EXCEPTION
    WHEN OTHERS THEN
      wf_core.CONTEXT('jtf_task_wf_subscribe_pvt', 'delete_task_notif_subs', p_event.event_name, p_subscription_guid);
      wf_event.seterrorinfo(p_event, 'WARNING');
      RETURN 'WARNING';
  END delete_task_notif_subs;

  FUNCTION create_assg_notif_subs(p_subscription_guid IN RAW, p_event IN OUT NOCOPY wf_event_t)
    RETURN VARCHAR2 IS
    l_enable_workflow    VARCHAR2(1);
    l_abort_workflow     VARCHAR2(1);
    x_return_status      VARCHAR2(200);
    x_msg_count          NUMBER;
    x_msg_data           VARCHAR2(1000);
    l_task_id            jtf_tasks_b.task_id%TYPE;
    l_resource_type_code jtf_task_all_assignments.resource_type_code%TYPE;
    l_resource_id        jtf_task_all_assignments.resource_id%TYPE;
    l_assignee_role      jtf_task_all_assignments.assignee_role%TYPE;
  BEGIN
    l_task_id             := wf_event.getvalueforparameter('TASK_ID', p_event.parameter_list);
    l_resource_type_code  := wf_event.getvalueforparameter('RESOURCE_TYPE_CODE', p_event.parameter_list);
    l_resource_id         := wf_event.getvalueforparameter('RESOURCE_ID', p_event.parameter_list);
    l_enable_workflow     := wf_event.getvalueforparameter('ENABLE_WORKFLOW', p_event.parameter_list);
    l_abort_workflow      := wf_event.getvalueforparameter('ABORT_WORKFLOW', p_event.parameter_list);
    l_assignee_role       := wf_event.getvalueforparameter('ASSIGNEE_ROLE', p_event.parameter_list);

    IF (l_assignee_role <> 'OWNER') AND(l_enable_workflow = 'Y') THEN
      IF (jtf_task_wf_util.do_notification(l_task_id)) THEN
        jtf_task_wf_util.create_notification(
          p_event                      => 'ADD_ASSIGNEE'
        , p_task_id                    => l_task_id
        , p_new_assignee_id            => l_resource_id
        , p_new_assignee_code          => l_resource_type_code
        , p_abort_workflow             => l_abort_workflow
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        );
      END IF;
    END IF;

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      wf_core.CONTEXT('jtf_task_wf_subscribe_pvt', 'create_assg_notif_subs', p_event.event_name, p_subscription_guid);
      wf_event.seterrorinfo(p_event, 'WARNING');
      RETURN 'WARNING';
    END IF;

    RETURN 'SUCCESS';
  EXCEPTION
    WHEN OTHERS THEN
      wf_core.CONTEXT('jtf_task_wf_subscribe_pvt', 'create_assg_notif_subs', p_event.event_name, p_subscription_guid);
      wf_event.seterrorinfo(p_event, 'WARNING');
      RETURN 'WARNING';
  END create_assg_notif_subs;

  FUNCTION update_assg_notif_subs(p_subscription_guid IN RAW, p_event IN OUT NOCOPY wf_event_t)
    RETURN VARCHAR2 IS
    l_enable_workflow         VARCHAR2(1);
    l_abort_workflow          VARCHAR2(1);
    l_assignee_role_db        jtf_task_all_assignments.assignee_role%TYPE;
    x_return_status           VARCHAR2(200);
    x_msg_count               NUMBER;
    x_msg_data                VARCHAR2(1000);
    l_task_assignment_id      jtf_task_all_assignments.task_assignment_id%TYPE;
    l_task_id                 jtf_tasks_b.task_id%TYPE;
    l_resource_type_code      jtf_task_all_assignments.resource_type_code%TYPE;
    l_resource_id             jtf_task_all_assignments.resource_id%TYPE;
    l_orig_resource_type_code jtf_task_all_assignments.resource_type_code%TYPE;
    l_orig_resource_id        jtf_task_all_assignments.resource_id%TYPE;
  BEGIN
    l_task_assignment_id       := wf_event.getvalueforparameter('TASK_ASSIGNMENT_ID', p_event.parameter_list);
    l_task_id                  := wf_event.getvalueforparameter('TASK_ID', p_event.parameter_list);
    l_resource_type_code       := wf_event.getvalueforparameter('NEW_RESOURCE_TYPE_CODE', p_event.parameter_list);
    l_resource_id              := wf_event.getvalueforparameter('NEW_RESOURCE_ID', p_event.parameter_list);
    l_orig_resource_type_code  := wf_event.getvalueforparameter('OLD_RESOURCE_TYPE_CODE', p_event.parameter_list);
    l_orig_resource_id         := wf_event.getvalueforparameter('OLD_RESOURCE_ID', p_event.parameter_list);
    l_enable_workflow          := wf_event.getvalueforparameter('ENABLE_WORKFLOW', p_event.parameter_list);
    l_abort_workflow           := wf_event.getvalueforparameter('ABORT_WORKFLOW', p_event.parameter_list);
    l_assignee_role_db         := wf_event.getvalueforparameter('ASSIGNEE_ROLE', p_event.parameter_list);

    IF (l_assignee_role_db IS NULL) THEN
      l_assignee_role_db  := wf_event.getvalueforparameter('NEW_ASSIGNEE_ROLE', p_event.parameter_list);
    END IF;

    IF (l_assignee_role_db IS NOT NULL) THEN
      IF (l_enable_workflow = 'Y') THEN
        IF    (NVL(l_resource_id, 0) <> fnd_api.g_miss_num AND NVL(l_resource_id, 0) <> NVL(l_orig_resource_id, 0))
           OR (NVL(l_resource_type_code, fnd_api.g_miss_char) <> NVL(l_orig_resource_type_code, fnd_api.g_miss_char)) THEN
          IF (jtf_task_wf_util.do_notification(l_task_id)) THEN
            IF (l_assignee_role_db = 'OWNER') THEN
              jtf_task_wf_util.create_notification(
                p_event                      => 'CHANGE_OWNER'
              , p_task_id                    => l_task_id
              , p_old_owner_id               => l_orig_resource_id
              , p_old_owner_code             => l_orig_resource_type_code
              , p_abort_workflow             => l_abort_workflow
              , x_return_status              => x_return_status
              , x_msg_count                  => x_msg_count
              , x_msg_data                   => x_msg_data
              );
            ELSE
              jtf_task_wf_util.create_notification(
                p_event                      => 'CHANGE_ASSIGNEE'
              , p_task_id                    => l_task_id
              , p_old_assignee_id            => l_orig_resource_id
              , p_old_assignee_code          => l_orig_resource_type_code
              , p_new_assignee_id            => l_resource_id
              , p_new_assignee_code          => l_resource_type_code
              , p_abort_workflow             => l_abort_workflow
              , x_return_status              => x_return_status
              , x_msg_count                  => x_msg_count
              , x_msg_data                   => x_msg_data
              );
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      wf_core.CONTEXT('jtf_task_wf_subscribe_pvt', 'update_assg_notif_subs', p_event.event_name, p_subscription_guid);
      wf_event.seterrorinfo(p_event, 'WARNING');
      RETURN 'WARNING';
    END IF;

    RETURN 'SUCCESS';
  EXCEPTION
    WHEN OTHERS THEN
      wf_core.CONTEXT('jtf_task_wf_subscribe_pvt', 'update_assg_notif_subs', p_event.event_name, p_subscription_guid);
      wf_event.seterrorinfo(p_event, 'WARNING');
      RETURN 'WARNING';
  END update_assg_notif_subs;

  FUNCTION delete_assg_notif_subs(p_subscription_guid IN RAW, p_event IN OUT NOCOPY wf_event_t)
    RETURN VARCHAR2 IS
    l_enable_workflow    VARCHAR2(1);
    l_abort_workflow     VARCHAR2(1);
    x_return_status      VARCHAR2(200);
    x_msg_count          NUMBER;
    x_msg_data           VARCHAR2(1000);
    l_task_assignment_id jtf_task_all_assignments.task_assignment_id%TYPE;
    l_task_id            jtf_tasks_b.task_id%TYPE;
    l_resource_type_code jtf_task_all_assignments.resource_type_code%TYPE;
    l_resource_id        jtf_task_all_assignments.resource_id%TYPE;
    l_assignee_role      jtf_task_all_assignments.assignee_role%TYPE;
  BEGIN
    l_task_assignment_id  := wf_event.getvalueforparameter('TASK_ASSIGNMENT_ID', p_event.parameter_list);
    l_task_id             := wf_event.getvalueforparameter('TASK_ID', p_event.parameter_list);
    l_resource_type_code  := wf_event.getvalueforparameter('RESOURCE_TYPE_CODE', p_event.parameter_list);
    l_resource_id         := wf_event.getvalueforparameter('RESOURCE_ID', p_event.parameter_list);
    l_enable_workflow     := wf_event.getvalueforparameter('ENABLE_WORKFLOW', p_event.parameter_list);
    l_abort_workflow      := wf_event.getvalueforparameter('ABORT_WORKFLOW', p_event.parameter_list);
    l_assignee_role       := wf_event.getvalueforparameter('ASSIGNEE_ROLE', p_event.parameter_list);

    IF (l_assignee_role <> 'OWNER') AND(l_enable_workflow = 'Y') THEN
      IF (jtf_task_wf_util.do_notification(l_task_id)) THEN
        jtf_task_wf_util.create_notification(
          p_event                      => 'DELETE_ASSIGNEE'
        , p_task_id                    => l_task_id
        , p_old_assignee_id            => l_resource_id
        , p_old_assignee_code          => l_resource_type_code
        , p_abort_workflow             => l_abort_workflow
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        );
      END IF;
    END IF;

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      wf_core.CONTEXT('jtf_task_wf_subscribe_pvt', 'delete_assg_notif_subs', p_event.event_name, p_subscription_guid);
      wf_event.seterrorinfo(p_event, 'WARNING');
      RETURN 'WARNING';
    END IF;

    RETURN 'SUCCESS';
  EXCEPTION
    WHEN OTHERS THEN
      wf_core.CONTEXT('jtf_task_wf_subscribe_pvt', 'delete_assg_notif_subs', p_event.event_name, p_subscription_guid);
      wf_event.seterrorinfo(p_event, 'WARNING');
      RETURN 'WARNING';
  END delete_assg_notif_subs;

  FUNCTION compare_old_new_param(p_new_param IN VARCHAR2, p_old_param IN VARCHAR2)
    RETURN BOOLEAN IS
    l_old_param VARCHAR2(4000) := p_old_param;
    l_new_param VARCHAR2(4000) := p_new_param;
  BEGIN
    IF (l_old_param IS NULL) THEN
      l_old_param  := fnd_api.g_miss_char;
    END IF;

    IF (l_new_param IS NULL) THEN
      l_new_param  := fnd_api.g_miss_char;
    END IF;

    RETURN(l_old_param <> l_new_param);
  END compare_old_new_param;

  FUNCTION compare_old_new_param(p_new_param IN NUMBER, p_old_param IN NUMBER)
    RETURN BOOLEAN IS
  BEGIN
    RETURN compare_old_new_param(TO_CHAR(p_new_param), TO_CHAR(p_old_param));
  END compare_old_new_param;

  FUNCTION compare_old_new_param(p_new_param IN DATE, p_old_param IN DATE)
    RETURN BOOLEAN IS
  BEGIN
    RETURN compare_old_new_param(
             TO_CHAR(p_new_param, 'YYYY-MM-DD HH24:MI:SS')
           , TO_CHAR(p_old_param, 'YYYY-MM-DD HH24:MI:SS')
           );
  END compare_old_new_param;
END;

/
