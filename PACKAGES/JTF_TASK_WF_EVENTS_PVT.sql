--------------------------------------------------------
--  DDL for Package JTF_TASK_WF_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_WF_EVENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: jtftkbes.pls 115.2 2003/09/25 19:46:06 sachoudh noship $ */


   PROCEDURE publish_create_task (
     P_TASK_REC		 IN	jtf_tasks_pvt.Task_Rec_type,
     x_return_status OUT NOCOPY       VARCHAR2
   );

   PROCEDURE publish_update_task (
     P_TASK_REC_OLD		 IN	jtf_tasks_pvt.Task_Rec_type,
     P_TASK_REC_NEW		 IN	jtf_tasks_pvt.Task_Rec_type,
     x_return_status OUT NOCOPY       VARCHAR2
   );

   PROCEDURE publish_delete_task (
       P_TASK_REC		IN	jtf_tasks_pvt.Task_Rec_type,
       x_return_status  OUT NOCOPY       VARCHAR2
   );

   PROCEDURE publish_create_assignment (
      P_ASSIGNMENT_REC IN jtf_task_assignments_pvt.task_assignments_rec,
      x_return_status OUT NOCOPY       VARCHAR2
   );

   PROCEDURE publish_update_assignment (
      P_ASSIGNMENT_REC_NEW IN jtf_task_assignments_pvt.task_assignments_rec,
      P_ASSIGNMENT_REC_OLD IN jtf_task_assignments_pvt.task_assignments_rec,
      x_return_status OUT NOCOPY       VARCHAR2
  );

   PROCEDURE publish_delete_assignment (
      P_ASSIGNMENT_REC	IN	jtf_task_assignments_pvt.task_assignments_rec,
      x_return_status OUT NOCOPY       VARCHAR2
   );

  FUNCTION get_item_key(p_event_name IN VARCHAR2)
  RETURN VARCHAR2;


  PROCEDURE compare_and_set_attr_to_list (
    P_ATTRIBUTE_NAME IN VARCHAR2,
    P_OLD_VALUE IN VARCHAR2,
    P_NEW_VALUE IN VARCHAR2,
    P_ACTION    IN VARCHAR2,
    P_LIST      IN OUT NOCOPY WF_PARAMETER_LIST_T,
    PUBLISH_IF_CHANGE    IN VARCHAR2 DEFAULT 'Y'
  );

  PROCEDURE compare_and_set_attr_to_list (
    P_ATTRIBUTE_NAME IN VARCHAR2,
    P_OLD_VALUE IN NUMBER,
    P_NEW_VALUE IN NUMBER,
    P_ACTION    IN VARCHAR2,
    P_LIST      IN OUT NOCOPY WF_PARAMETER_LIST_T,
    PUBLISH_IF_CHANGE    IN VARCHAR2 DEFAULT 'Y'
  );

  PROCEDURE compare_and_set_attr_to_list (
    P_ATTRIBUTE_NAME IN VARCHAR2,
    P_OLD_VALUE IN DATE,
    P_NEW_VALUE IN DATE,
    P_ACTION    IN VARCHAR2,
    P_LIST      IN OUT NOCOPY WF_PARAMETER_LIST_T,
    PUBLISH_IF_CHANGE    IN VARCHAR2 DEFAULT 'Y'
  );

END;

 

/
