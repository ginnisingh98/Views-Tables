--------------------------------------------------------
--  DDL for Package JTF_TASK_WF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_WF_UTIL" AUTHID CURRENT_USER AS
  /* $Header: jtftkwus.pls 120.1.12000000.2 2007/10/04 13:20:43 venjayar ship $ */
  g_pkg_name            CONSTANT VARCHAR2(30)   := 'JTF_TASK_WF_UTIL';
  jtf_task_wf_item_type CONSTANT VARCHAR2(8)    := 'JTFTASK';
  jtf_task_main_process CONSTANT VARCHAR2(30)   := 'TASK_WORKFLOW';

  TYPE nlist_rec_type IS RECORD(
    NAME          wf_users.NAME%TYPE            := fnd_api.g_miss_char
  , display_name  wf_users.display_name%TYPE    := fnd_api.g_miss_char
  , email_address wf_users.email_address%TYPE   := fnd_api.g_miss_char
  );

  TYPE nlist_tbl_type IS TABLE OF nlist_rec_type
    INDEX BY BINARY_INTEGER;

  notiflist                      nlist_tbl_type;
  g_miss_notiflist               nlist_tbl_type;
  g_miss_nlist_rec               nlist_rec_type;
  g_event                        VARCHAR2(80);
  g_task_id                      jtf_tasks_b.task_id%TYPE;
  g_old_owner_id                 jtf_tasks_b.owner_id%TYPE;
  g_old_owner_code               jtf_tasks_b.owner_type_code%TYPE;
  g_owner_id                     jtf_tasks_b.owner_id%TYPE;
  g_owner_type_code              jtf_tasks_b.owner_type_code%TYPE;
  g_old_assignee_id              jtf_tasks_b.owner_id%TYPE;
  g_old_assignee_code            jtf_tasks_b.owner_type_code%TYPE;
  g_new_assignee_id              jtf_tasks_b.owner_id%TYPE;
  g_new_assignee_code            jtf_tasks_b.owner_type_code%TYPE;

  FUNCTION do_notification(p_task_id IN NUMBER)
    RETURN BOOLEAN;

  PROCEDURE create_notification(
    p_event                    IN         VARCHAR2
  , p_task_id                  IN         NUMBER
  , p_old_owner_id             IN         NUMBER   DEFAULT jtf_task_utl.g_miss_number
  , p_old_owner_code           IN         VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_old_assignee_id          IN         NUMBER   DEFAULT jtf_task_utl.g_miss_number
  , p_old_assignee_code        IN         VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_new_assignee_id          IN         NUMBER   DEFAULT jtf_task_utl.g_miss_number
  , p_new_assignee_code        IN         VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_old_type                 IN         NUMBER   DEFAULT jtf_task_utl.g_miss_number
  , p_old_priority             IN         NUMBER   DEFAULT jtf_task_utl.g_miss_number
  , p_old_status               IN         NUMBER   DEFAULT jtf_task_utl.g_miss_number
  , p_old_planned_start_date   IN         DATE     DEFAULT jtf_task_utl.g_miss_date
  , p_old_planned_end_date     IN         DATE     DEFAULT jtf_task_utl.g_miss_date
  , p_old_scheduled_start_date IN         DATE     DEFAULT jtf_task_utl.g_miss_date
  , p_old_scheduled_end_date   IN         DATE     DEFAULT jtf_task_utl.g_miss_date
  , p_old_actual_start_date    IN         DATE     DEFAULT jtf_task_utl.g_miss_date
  , p_old_actual_end_date      IN         DATE     DEFAULT jtf_task_utl.g_miss_date
  , p_old_description          IN         VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_abort_workflow           IN         VARCHAR2 DEFAULT fnd_profile.VALUE('JTF_TASK_ABORT_PREV_WF')
  , x_return_status            OUT NOCOPY VARCHAR2
  , x_msg_count                OUT NOCOPY NUMBER
  , x_msg_data                 OUT NOCOPY VARCHAR2
  );

  PROCEDURE set_notif_message(
    itemtype  IN            VARCHAR2
  , itemkey   IN            VARCHAR2
  , actid     IN            NUMBER
  , funcmode  IN            VARCHAR2
  , resultout OUT NOCOPY    VARCHAR2
  );

  PROCEDURE set_notif_performer(
    itemtype  IN            VARCHAR2
  , itemkey   IN            VARCHAR2
  , actid     IN            NUMBER
  , funcmode  IN            VARCHAR2
  , resultout OUT NOCOPY    VARCHAR2
  );

  PROCEDURE set_notif_list(
    itemtype  IN            VARCHAR2
  , itemkey   IN            VARCHAR2
  , actid     IN            NUMBER
  , funcmode  IN            VARCHAR2
  , resultout OUT NOCOPY    VARCHAR2
  );
END jtf_task_wf_util;

 

/
