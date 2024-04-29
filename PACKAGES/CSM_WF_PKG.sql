--------------------------------------------------------
--  DDL for Package CSM_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: csmewfs.pls 120.1.12010000.3 2010/04/08 06:45:01 saradhak ship $ */

/*=========================================================
  4 WF processes for TASK MODULE
  TASK_ASSIGNMENT_POST_INS
  TASK_ASSIGNMENT_PRE_UPD
  TASK_ASSIGNMENT_PURGE
  TASK_PRE_UPD
=========================================================*/
/*--------------------------------------------------
  Description:
    Starts the TASK_ASSIGNMENT_INS workflow. Should be called when new
    task assignment is made.
    Invoked by JTF_TASK_ASSIGNMENTS_IUHK.update_task_assignment_pre
    global var jtf_task_assignments_pub.p_task_assignments_user_hooks(.task_assignment_id)

  Parameter(s):
    x_return_status
----------------------------------------------------*/

PROCEDURE Task_Assignment_Post_Ins(
     x_return_status     OUT NOCOPY      VARCHAR2
     -- p_task_assignment_id in number
);

/*-----------------------------------------------------------------
  Description:
    Start the TASK_ASSIGNMENT_UPD process. Called by
    JTF_TASK_ASSIGNMENTS_IUHK.update_task_assignment_pre
    We retrieve the old record by selecting from db with task_assignment_id
    Then, we compare the old resource id and new resource id for whether the resource has changed.
  Parameter(s):
    x_return_status
------------------------------------------------------------------*/
PROCEDURE Task_Assignment_Pre_Upd(
     x_return_status     OUT NOCOPY      VARCHAR2
     -- p_task_assignment_id in jtf_task_assignments.task_assignment_id%type,
     -- p_old_resource_id in jtf_task_assignments.resource_id%type,
     -- p_is_resource_updated in char
);

PROCEDURE Task_Assignment_Post_Upd(
     x_return_status     OUT NOCOPY      VARCHAR2
);

/*--------------------------------------------------------
  Description:
    Start the workflow process TASK_ASSIGNMENT_PURGE.
    Invoked by JTF_TASK_ASSIGNMENTS_IUHK.delete_task_assignment_post
    and by concurrent program to purge closed task assignments
    older than specified in profile: CSF_M_HISTORY.
  Parameter(s):
    x_return_status
--------------------------------------------------------*/
PROCEDURE Task_Assignment_Post_Del(
  x_return_status     OUT NOCOPY      VARCHAR2
);

/*-----------------------------------------------------------------
  Description:
    Start the workflow process TASK_UPD_USERLOOP.
    Invoked by jtf_tasks_iuhk.update_task_pre
    The global variable for IUHK is: jtf_tasks_pub.p_task_user_hooks(.task_id)
  Parameter(s):
    x_return_status
------------------------------------------------------------------*/
--  PROCEDURE Task_Pre_Upd(p_jtf_task_id jtf_tasks_b.task_id%type);
Procedure Task_Pre_Upd (
  x_return_status     OUT NOCOPY      VARCHAR2
);

Procedure Task_Post_Upd (
  x_return_status     OUT NOCOPY      VARCHAR2
);

Procedure TASK_Post_Ins(
    x_return_status     OUT NOCOPY      VARCHAR2
);

Procedure TASK_Post_DEL(
    x_return_status     OUT NOCOPY      VARCHAR2
);


/*=========================================================
  3 WF processes SERVICE REQUEST MODULE  for IUHK
  SR_Post_Ins
  SR_PRE_UPD
  SR_CONTACT_POST_INS
  SR_CONTACT_PRE_UPD
  Global variable to be used:
  user_hooks_rec     CS_ServiceRequest_PVT.internal_user_hooks_rec
  Two fields are initialized.
  user_hooks_rec.customer_id  :=  l_old_ServiceRequest_rec.customer_id ;
  user_hooks_rec.request_id   :=  p_request_id ;
  The most useful info is the request_id. We need to use this to check
  -- whether the other FK columns are changed or not.
=========================================================*/
  PROCEDURE SR_Post_Ins( x_return_status  OUT NOCOPY  VARCHAR2 );

  PROCEDURE SR_Pre_Upd( x_return_status  OUT NOCOPY  VARCHAR2 );

  PROCEDURE SR_Post_Upd( x_return_status  OUT NOCOPY  VARCHAR2 );

/* =========================================================*/

PROCEDURE CSF_Debrief_Header_Post_Ins(x_return_status  OUT NOCOPY  VARCHAR2);

PROCEDURE CSF_Debrief_Header_Pre_Upd(x_return_status  OUT NOCOPY  VARCHAR2);

PROCEDURE CSF_Debrief_Header_Post_Upd(x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE CSF_Debrief_Header_Post_Del(x_return_status OUT NOCOPY VARCHAR2);

/*=========================================================
  2 events related to Debriefing. IUHK
  CSF_DEBRIEF_LINE_POST_INS
  CSF_DEBRIEF_LINE_PRE_UPD
Global: user_hooks_rec  CSF_DEBRIEF_LINES_PKG.internal_user_hooks_rec..DEBRIEF_LINE_ID
=========================================================*/

PROCEDURE CSF_Debrief_Line_Post_Ins(x_return_status  OUT NOCOPY  VARCHAR2);

PROCEDURE CSF_Debrief_Line_Pre_Upd(x_return_status  OUT NOCOPY  VARCHAR2);

PROCEDURE CSF_Debrief_Line_Post_Upd(x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE CSF_Debrief_Line_Post_Del(x_return_status OUT NOCOPY VARCHAR2);

/*=========================================================
  2 events related to INV_LOC_ASSIGNMENT. IUHK
  CSP_INV_LOC_ASSIGNMNT_POST_INS
  CSP_INV_LOC_ASSIGNMNT_PRE_UPD
  Global variable:
    CSP_INV_LOC_ASSIGNMENTS_PKG.user_hooks_rec.CSP_INV_LOC_ASSIGNMENT_ID
=========================================================*/

PROCEDURE CSP_Inv_Loc_Assignmnt_Post_Ins(x_return_status OUT NOCOPY varchar2);

PROCEDURE CSP_Inv_Loc_Assignmnt_Pre_Upd(x_return_status OUT NOCOPY varchar2);

PROCEDURE CSP_Inv_Loc_Assignmnt_Post_Upd(x_return_status OUT NOCOPY varchar2);

PROCEDURE CSP_Inv_Loc_Assg_Post_Del(x_return_status OUT NOCOPY varchar2);

/*=========================================================
  2 events related to CSP_REQUIREMENT_LINES_PVT IUHK
  CSP_SHIP_TO_ADDRESS_POST_INS
  CSP_SHIP_TO_ADDRESS_POST_UPD
  Global variable:
    CSP_SHIP_TO_ADDRESS_PVT.G_INV_LOC_ID
=========================================================*/

PROCEDURE CSP_SHIP_TO_ADDRESS_POST_INS(x_return_status OUT NOCOPY varchar2);

PROCEDURE CSP_SHIP_TO_ADDRESS_POST_UPD(x_return_status OUT NOCOPY varchar2);

/*=========================================================
  3 events related to CSP_REQUIREMENT_HEADERS_PKG IUHK
  CSP_REQ_HEADERS_POST_INS
  CSP_REQ_HEADERS_POST_UPD
  CSP_REQ_HEADERS_PRE_DEL
  Global variable:
      CSP_REQUIREMENT_HEADERS_PKG.user_hooks_rec.REQUIREMENT_HEADER_ID
=========================================================*/

PROCEDURE CSP_REQ_HEADERS_POST_INS(x_return_status OUT NOCOPY varchar2);

PROCEDURE CSP_REQ_HEADERS_POST_UPD(x_return_status OUT NOCOPY varchar2);

PROCEDURE CSP_REQ_HEADERS_POST_DEL(x_return_status OUT NOCOPY varchar2);

/*=========================================================
  3 events related to CSP_REQUIREMENT_LINES_PKG IUHK
  CSP_REQ_LINES_POST_INS
  CSP_REQ_LINES_POST_UPD
  CSP_REQ_LINES_PRE_DEL
  Global variable:
      CSP_REQUIREMENT_LINES_PKG.user_hook_rec.REQUIREMENT_LINE_ID
=========================================================*/

PROCEDURE CSP_REQ_LINES_POST_INS(x_return_status OUT NOCOPY varchar2);

PROCEDURE CSP_REQ_LINES_POST_UPD(x_return_status OUT NOCOPY varchar2);

PROCEDURE CSP_REQ_LINES_POST_DEL(x_return_status OUT NOCOPY varchar2);

/*=========================================================
  3 events related to CSP_REQ_LINE_DETAILS_PKG IUHK
  CSP_REQ_LINE_DETAILS_POST_INS
  CSP_REQ_LINE_DETAILS_POST_UPD
  CSP_REQ_LINE_DETAILS_PRE_DEL
  Global variable:
      CSP_REQ_LINE_DETAILS_PKG.user_hook_rec.REQUIREMENT_LINE_ID
=========================================================*/

PROCEDURE CSP_REQ_LINE_DETAILS_POST_INS(x_return_status OUT NOCOPY varchar2);

PROCEDURE CSP_REQ_LINE_DETAILS_POST_UPD(x_return_status OUT NOCOPY varchar2);

PROCEDURE CSP_REQ_LINE_DETAILS_PRE_DEL(x_return_status OUT NOCOPY varchar2);

/*=============================================
  4 events for install base VUHK
  CSI_Item_Instance_Post_Ins
  CSI_ITEM_INSTANCE_PRE_UPD
  CSI_II_Relationship_Post_Ins
  CSI_II_Relationship_Pre_Upd
=============================================*/
/*  PROCEDURE CSI_Item_Instance_Post_Ins(p_user_id in number,
                                     p_csi_item_instances csi_item_instances%rowtype);
*/
   Procedure CSI_Item_Instance_Post_Ins(p_api_version IN     NUMBER
                              , p_init_msg_list       IN     VARCHAR2
                              , p_commit              IN     VARCHAR2
                              , p_validation_level    IN     NUMBER
                              , p_instance_id         IN     NUMBER
                              , x_return_status       OUT NOCOPY VARCHAR2
                              , x_msg_count           OUT NOCOPY NUMBER
                              , x_msg_data            OUT NOCOPY VARCHAR2) ;

   Procedure CSI_Item_Instance_Pre_Upd(p_api_version IN     NUMBER
                              , p_init_msg_list       IN     VARCHAR2
                              , p_commit              IN     VARCHAR2
                              , p_validation_level    IN     NUMBER
                              , p_instance_id         IN     NUMBER
                              , x_return_status       OUT NOCOPY VARCHAR2
                              , x_msg_count           OUT NOCOPY NUMBER
                              , x_msg_data            OUT NOCOPY VARCHAR2) ;

/*=========================================================
  3 WF processes for JTF_RS_Group_Member. Used by VUHK
  JTF_RS_GROUP_MEMBER_POST_INS
  JTF_RS_GROUP_MEMBER_PRE_UPD
  JTF_RS_GROUP_MEMBER_POST_DEL
=========================================================*/

  PROCEDURE JTF_RS_Group_Member_Post_Ins(p_group_member_id in jtf_rs_group_members.group_member_id%TYPE,
                                         p_group_id in jtf_rs_group_members.group_id%TYPE,
                                         p_resource_id in jtf_rs_group_members.resource_id%TYPE,
                                         x_return_status OUT NOCOPY varchar2);

  PROCEDURE JTF_RS_Group_Member_Pre_Upd(p_user_id in number,
                                     p_jtf_rs_group_memb jtf_rs_group_members%rowtype);

/*  SAGRAWAL We have pre processing vertical hook for Group Member Del
  PROCEDURE JTF_RS_Group_Member_Post_Del(p_user_id in number,
                                     p_jtf_rs_group_memb jtf_rs_group_members%rowtype);
  */
  Procedure JTF_RS_Group_Member_Pre_Del(p_group_id in jtf_rs_group_members.group_id%TYPE,
                                      p_resource_id in jtf_rs_group_members.resource_id%TYPE,
                                      x_return_status OUT NOCOPY varchar2) ;

/*=============================================
  2 events for NOTES module. VUHK
=============================================*/

  PROCEDURE JTF_Note_Post_Ins(p_api_version           IN     NUMBER
                              , p_init_msg_list       IN     VARCHAR2
                              , p_commit              IN     VARCHAR2
                              , p_validation_level    IN     NUMBER
                              , x_msg_count           OUT NOCOPY NUMBER
                              , x_msg_data            OUT NOCOPY VARCHAR2
                              , x_return_status       OUT NOCOPY VARCHAR2
                              ,p_jtf_note_id in jtf_notes_b.jtf_note_id%type);

/*  SAGRAWAL We have post processing vertical hook for update notes
  PROCEDURE JTF_Note_Pre_Upd(p_jtf_note_id in jtf_notes_b.jtf_note_id%type); */

  PROCEDURE JTF_Note_Pre_Upd(p_api_version           IN     NUMBER
                              , p_init_msg_list       IN     VARCHAR2
                              , p_commit              IN     VARCHAR2
                              , p_validation_level    IN     NUMBER
                              , x_msg_count           OUT NOCOPY NUMBER
                              , x_msg_data            OUT NOCOPY VARCHAR2
                              , x_return_status       OUT NOCOPY VARCHAR2
                              ,p_jtf_note_id in jtf_notes_b.jtf_note_id%type);

  PROCEDURE JTF_Note_Post_Upd(p_api_version           IN     NUMBER
                              , p_init_msg_list       IN     VARCHAR2
                              , p_commit              IN     VARCHAR2
                              , p_validation_level    IN     NUMBER
                              , x_msg_count           OUT NOCOPY NUMBER
                              , x_msg_data            OUT NOCOPY VARCHAR2
                              , x_return_status       OUT NOCOPY VARCHAR2
                              ,p_jtf_note_id in jtf_notes_b.jtf_note_id%type);

/*=============================================
  7 events for counters VUHK
  CS_Counter_Post_Ins  (rarely needed)
  CS_Counter_Pre_Upd (rarely needed)
  CS_Counter_Property_Post_Ins (rarely needed)
  CS_Counter_Property_Pre_Upd (rarely needed)
  CS_Counter_Value_Post_Ins
  CS_Counter_Value_Pre_Upd
  CS_Counter_Prop_Val_Post_Ins
  CS_Counter_Prop_Val_Pre_Upd  (probably not needed)
 *=============================================*/

  PROCEDURE CS_Counter_Post_Ins(
      P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_counter_id                 IN   NUMBER,
    x_object_version_number      OUT NOCOPY  NUMBER
   -- p_user_id in number,
   -- p_counter_id cs_counters.counter_id%type
);

Procedure CS_Counter_Pre_Del(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_counter_id                 IN   NUMBER
);


PROCEDURE CS_CTR_GRP_INSTANCE_CRE_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_source_object_cd           IN   VARCHAR2,
    p_source_object_id           IN   NUMBER,
    p_ctr_grp_id                 IN   NUMBER,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

PROCEDURE CS_CTR_GRP_INSTANCE_PRE_DEL(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_source_object_cd           IN   VARCHAR2,
    p_source_object_id           IN   NUMBER
    );

PROCEDURE CS_COUNTER_GRP_Post_Upd( P_Api_Version              IN  NUMBER
                                   , P_Init_Msg_List            IN  VARCHAR2
                                   , P_Commit                   IN  VARCHAR2
                                   , X_Return_Status            OUT NOCOPY VARCHAR2
                                   , X_Msg_Count                OUT NOCOPY NUMBER
                                   , X_Msg_Data                 OUT NOCOPY VARCHAR2
                                   , p_ctr_grp_id               IN  NUMBER
                                   , p_object_version_number    IN  NUMBER
                                   , p_cascade_upd_to_instances IN  VARCHAR2
                                   , x_object_version_number    OUT NOCOPY NUMBER );

PROCEDURE CS_COUNTERS_INSTANTIATE_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_counter_group_id_template  IN   NUMBER,
    p_source_object_cd         IN  VARCHAR2,
    p_source_object_id           IN  NUMBER,
    x_ctr_grp_id_template        IN  NUMBER,
    p_ctr_grp_id                 IN  NUMBER
    );

  PROCEDURE CS_Counter_Pre_Upd(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_counter_id                     IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_cascade_upd_to_instances   IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_object_version_number      OUT NOCOPY  NUMBER
--  p_user_id in number,
--  p_cs_counters cs_counters%rowtype
);
/*
  SAGRAWAL Added other parameters
  PROCEDURE CS_Counter_Value_Post_Ins(p_counter_value_id in number);
*/

  PROCEDURE CS_Counter_Post_Upd(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_counter_id                     IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_cascade_upd_to_instances   IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_object_version_number      OUT NOCOPY  NUMBER
--  p_user_id in number,
--  p_cs_counters cs_counters%rowtype
);

  PROCEDURE CS_Counter_Value_Post_Ins(p_api_version           IN     NUMBER
                              , p_init_msg_list       IN     VARCHAR2
                              , p_commit              IN     VARCHAR2
                              , p_validation_level    IN     NUMBER
                              , p_counter_grp_log_id  IN  NUMBER
                              , x_return_status       OUT NOCOPY VARCHAR2
                              , x_msg_count           OUT NOCOPY NUMBER
                              , x_msg_data            OUT NOCOPY VARCHAR2) ;

  PROCEDURE CS_Counter_Value_Pre_Upd(p_api_version    IN     NUMBER
                              , p_init_msg_list       IN     VARCHAR2
                              , p_commit              IN     VARCHAR2
                              , p_validation_level    IN     NUMBER
                              , p_counter_grp_log_id    IN  NUMBER
                              , p_object_version_number IN NUMBER
                              , x_return_status       OUT NOCOPY VARCHAR2
                              , x_msg_count           OUT NOCOPY NUMBER
                              , x_msg_data            OUT NOCOPY VARCHAR2
                                    );

  PROCEDURE CS_Counter_Property_Post_Ins(p_user_id in number,
                                     p_cs_counter_prop cs_counter_properties%rowtype);

  PROCEDURE CS_Counter_Property_Pre_Upd(p_user_id in number,
                                     p_cs_counter_prop cs_counter_properties%rowtype);

  PROCEDURE CS_Counter_Prop_Val_Post_Ins(p_user_id in number,
                                     p_cs_counter_prop_val cs_counter_prop_values%rowtype);

  PROCEDURE CS_Counter_Prop_Val_Pre_Upd(p_user_id in number,
                                     p_cs_counter_prop_val cs_counter_prop_values%rowtype);
/*=============================================
  User events
  USER_RESP_POST_INS
  USER_DEL
 =============================================*/

  Procedure User_Resp_Post_Ins(p_user_id in number,
                                p_responsibility_id in number);

/*--------------------------------------------------------
  Description:
    It starts the USER_DEL workflow process.
    Called when a Field Service Palm user is deleted
  Parameter(s):
    User_ID
--------------------------------------------------------*/
  Procedure User_Del(p_user_id in number);

/*--------------------------------------------------------
  Description:
    Raises event oracle.apps.csm.download.startsync
  Parameter(s):
    ENTITY, PK_VALUE & MODE
--------------------------------------------------------*/
  PROCEDURE RAISE_START_AUTO_SYNC_EVENT(l_entity VARCHAR2 , l_pk_value VARCHAR2, l_mode VARCHAR2);

END CSM_WF_PKG;

/
