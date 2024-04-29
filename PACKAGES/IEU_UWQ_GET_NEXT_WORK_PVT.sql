--------------------------------------------------------
--  DDL for Package IEU_UWQ_GET_NEXT_WORK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_UWQ_GET_NEXT_WORK_PVT" AUTHID CURRENT_USER AS
/* $Header: IEUVGNWS.pls 120.3 2006/03/08 21:35:11 msathyan noship $ */

g_pkg_name     CONSTANT VARCHAR2(30)  := 'IEU_UWQ_GET_NEXT_WORK_PVT';

 TYPE IEU_UWQ_BINDVAR_REC is RECORD
 ( BIND_NAME VARCHAR2(1000),
   VALUE VARCHAR2(1000) );

  TYPE IEU_UWQ_BINDVAR_LIST IS
  TABLE OF IEU_UWQ_BINDVAR_REC INDEX BY BINARY_INTEGER;



 TYPE IEU_UWQ_NEXTWORK_ITEM_REC is RECORD
 ( WORK_ITEM_ID      NUMBER := null,
   PRIORITY_LEVEL    NUMBER := null,
   DUE_DATE          VARCHAR2(30) := null,
   WORKITEM_OBJ_CODE VARCHAR2(30) := null
 );

 TYPE IEU_UWQ_NEXTWORK_ITEM_LIST IS
  TABLE OF IEU_UWQ_NEXTWORK_ITEM_REC INDEX BY BINARY_INTEGER;

 TYPE IEU_UWQM_ITEM_DATA_REC is RECORD
 (
   WORK_ITEM_ID              NUMBER(15),
   WORKITEM_OBJ_CODE         VARCHAR2(30),
   WORKITEM_PK_ID            NUMBER(15),
   STATUS_ID                 NUMBER(15),
   PRIORITY_ID               NUMBER(15),
   PRIORITY_LEVEL            NUMBER(3),
   PRIORITY                  VARCHAR2(80),
   DUE_DATE                  DATE,
   TITLE                     VARCHAR2(1990),
   PARTY_ID                  NUMBER(15),
   OWNER_ID                  NUMBER,
   OWNER_TYPE                VARCHAR2(25),
   ASSIGNEE_ID               NUMBER,
   ASSIGNEE_TYPE             VARCHAR2(25),
   SOURCE_OBJECT_ID          NUMBER,
   SOURCE_OBJECT_TYPE_CODE   VARCHAR2(30),
   OWNER_TYPE_ACTUAL         VARCHAR2(30),
   ASSIGNEE_TYPE_ACTUAL      VARCHAR2(30),
   APPLICATION_ID            NUMBER,
   IEU_ENUM_TYPE_UUID        VARCHAR2(38),
   STATUS_UPDATE_USER_ID     NUMBER,
   WORK_ITEM_NUMBER          VARCHAR2(30),
   RESCHEDULE_TIME            DATE,
   WORK_TYPE		     VARCHAR2(80),
   STATUS_CODE		     VARCHAR2(80)
 );

 TYPE IEU_UWQM_ITEM_DATA IS
 TABLE OF IEU_UWQM_ITEM_DATA_REC INDEX BY BINARY_INTEGER;

 TYPE l_get_work IS REF CURSOR;


 TYPE IEU_WR_ITEM_DATA_REC is RECORD
 (
   WORK_ITEM_ID              NUMBER(15),
   WORKITEM_OBJ_CODE         VARCHAR2(30),
   WORKITEM_PK_ID            NUMBER(15),
   STATUS_ID                 NUMBER(15),
   PRIORITY_ID               NUMBER(15),
   PRIORITY_LEVEL            NUMBER(3),
   PRIORITY_CODE             VARCHAR2(30),
   DUE_DATE                  DATE,
   TITLE                     VARCHAR2(1990),
   PARTY_ID                  NUMBER(15),
   OWNER_ID                  NUMBER,
   OWNER_TYPE                VARCHAR2(25),
   ASSIGNEE_ID               NUMBER,
   ASSIGNEE_TYPE             VARCHAR2(25),
   SOURCE_OBJECT_ID          NUMBER,
   SOURCE_OBJECT_TYPE_CODE   VARCHAR2(30),
   APPLICATION_ID            NUMBER,
   IEU_ENUM_TYPE_UUID        VARCHAR2(38),
   WORK_ITEM_NUMBER          VARCHAR2(30),
   RESCHEDULE_TIME           DATE,
   WS_ID            	     NUMBER
 );

 TYPE IEU_WR_ITEM_DATA IS
 TABLE OF IEU_WR_ITEM_DATA_REC INDEX BY BINARY_INTEGER;


 TYPE IEU_WR_ITEM_ACT_DATA_REC is RECORD
 (
   IEU_OBJECT_FUNCTION       VARCHAR2(30),
   IEU_OBJECT_PARAMETERS     VARCHAR2(2000),
   IEU_MEDIA_TYPE_UUID       NUMBER,
   IEU_PARAM_PK_VALUE        VARCHAR2(40),
   IEU_PARAM_PK_COL          VARCHAR2(40),
   WORK_ITEM_ID              NUMBER(15),
   WORKITEM_OBJ_CODE         VARCHAR2(30),
   WORKITEM_PK_ID            NUMBER(15),
   STATUS_ID                 NUMBER(15),
   PRIORITY_ID               NUMBER(15),
   PRIORITY_LEVEL            NUMBER(3),
   DUE_DATE                  DATE,
   TITLE                     VARCHAR2(1990),
   PARTY_ID                  NUMBER(15),
   OWNER_ID                  NUMBER,
   OWNER_TYPE                VARCHAR2(25),
   ASSIGNEE_ID               NUMBER,
   ASSIGNEE_TYPE             VARCHAR2(25),
   SOURCE_OBJECT_ID          NUMBER,
   SOURCE_OBJECT_TYPE_CODE   VARCHAR2(30),
   APPLICATION_ID            NUMBER,
   IEU_ACTION_OBJECT_CODE    VARCHAR2(60),
   IEU_ENUM_TYPE_UUID        VARCHAR2(38),
   WORK_ITEM_NUMBER          VARCHAR2(30),
   RESCHEDULE_TIME           DATE,
   IEU_GET_NEXTWORK_FLAG     VARCHAR2(10),
   WS_ID                     NUMBER
);

 TYPE IEU_WR_ITEM_ACT_DATA_LIST IS
 TABLE OF IEU_WR_ITEM_ACT_DATA_REC INDEX BY BINARY_INTEGER;

 TYPE IEU_WS_DETAILS_REC is RECORD
 (
   WS_CODE                   IEU_UWQM_WORK_SOURCES_B.WS_CODE%TYPE
 );

 TYPE IEU_WS_DETAILS_LIST IS
 TABLE OF IEU_WS_DETAILS_REC INDEX BY BINARY_INTEGER;

 TYPE IEU_GRP_ID_REC is RECORD
 (
   GROUP_ID                   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE
 );

 TYPE IEU_GRP_ID_LIST IS
 TABLE OF IEU_GRP_ID_REC INDEX BY BINARY_INTEGER;

 PROCEDURE GET_NEXT_WORKITEM
 ( p_api_version           IN  NUMBER,
   p_resource_id           IN  NUMBER,
   p_user_id               IN  NUMBER,
   x_uwqm_workitem_data    OUT NOCOPY IEU_FRM_PVT.T_IEU_MEDIA_DATA,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   x_return_status         OUT NOCOPY VARCHAR2);

PROCEDURE GET_WORKITEM_ACTION_FUNC_DATA
 ( p_workitem_data         IN IEU_UWQ_GET_NEXT_WORK_PVT.ieu_uwqm_item_data_rec,
   x_workitem_action_data OUT NOCOPY IEU_FRM_PVT.T_IEU_MEDIA_DATA );

PROCEDURE GET_NEXT_WORK_ITEM_CONT
 (p_release_api_version   IN NUMBER,
  p_next_work_api_version IN NUMBER,
  p_workitem_obj_code     IN VARCHAR2,
  p_workitem_pk_id        IN NUMBER,
  p_work_item_id          IN NUMBER,
  p_user_id               IN NUMBER,
  p_resource_id           IN NUMBER,
  p_worklist_cont_mode    IN VARCHAR2,
  x_uwqm_workitem_data    OUT NOCOPY IEU_FRM_PVT.T_IEU_MEDIA_DATA,
  x_release_return_status OUT NOCOPY VARCHAR2,
  x_release_msg_count     OUT NOCOPY NUMBER,
  x_release_msg_data      OUT NOCOPY VARCHAR2,
  x_nw_return_status      OUT NOCOPY VARCHAR2,
  x_nw_msg_count          OUT NOCOPY NUMBER,
  x_nw_msg_data           OUT NOCOPY VARCHAR2);

 PROCEDURE GET_WORKLIST_QUEUE
 ( p_api_version           IN  NUMBER,
   p_resource_id           IN  NUMBER,
   p_user_id               IN  NUMBER,
   p_no_of_recs            IN  NUMBER,
   x_uwqm_workitem_data    OUT NOCOPY IEU_UWQ_GET_NEXT_WORK_PVT.IEU_UWQM_ITEM_DATA,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   x_return_status         OUT NOCOPY VARCHAR2);

 FUNCTION GET_WORKLIST_QUEUE_COUNT
 ( p_resource_id           IN  NUMBER,
   p_status_id             IN  NUMBER,
   p_node_type             IN  NUMBER)
   RETURN NUMBER;

PROCEDURE DISTRIBUTE_AND_DELIVER_WR_ITEM
 ( p_api_version               IN  NUMBER,
   p_resource_id               IN  NUMBER,
   p_language                  IN  VARCHAR2,
   p_source_lang               IN  VARCHAR2,
   p_dist_from_extra_where_clause   IN  VARCHAR2,
   p_dist_to_extra_where_clause    IN  VARCHAR2,
   p_bindvar_from_list        IN  IEU_UWQ_BINDVAR_LIST,
   p_bindvar_to_list          IN  IEU_UWQ_BINDVAR_LIST,
   x_uwqm_workitem_data       OUT NOCOPY IEU_FRM_PVT.T_IEU_MEDIA_DATA,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,
   x_return_status            OUT NOCOPY VARCHAR2);

PROCEDURE DISTRIBUTE_WR_ITEMS
 ( p_api_version               IN  NUMBER,
   p_resource_id               IN  NUMBER,
   p_language                  IN  VARCHAR2,
   p_source_lang               IN  VARCHAR2,
   p_num_of_dist_items         IN  NUMBER,                                 -- Number of Items Requested to be Distributed
   p_extra_where_clause        IN  VARCHAR2,
   p_bindvar_list              IN  IEU_UWQ_BINDVAR_LIST,
   x_uwqm_workitem_data       OUT NOCOPY IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WR_ITEM_ACT_DATA_LIST,
   x_num_of_items_distributed OUT NOCOPY NUMBER,                           -- Number of Items finally Distributed
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,
   x_return_status            OUT NOCOPY VARCHAR2);

PROCEDURE GET_DIST_WR_ITEMS
 ( p_api_version               IN  NUMBER,
   p_resource_id               IN  NUMBER,
   p_language                  IN  VARCHAR2,
   p_source_lang               IN  VARCHAR2,
   p_num_of_dist_items         IN  NUMBER,
   p_extra_where_clause        IN  VARCHAR2,
   p_bindvar_list              IN  IEU_UWQ_BINDVAR_LIST,
   x_uwqm_workitem_data       OUT NOCOPY SYSTEM.WR_ITEM_DATA_NST,
   x_num_of_items_distributed OUT NOCOPY NUMBER,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,
   x_return_status            OUT NOCOPY VARCHAR2);

PROCEDURE SET_WR_ITEM_DATA_REC( p_var_in_type_code IN VARCHAR2,
                                p_dist_workitem_data IN SYSTEM.WR_ITEM_DATA_NST,
                                p_dist_del_workitem_data IN IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WR_ITEM_DATA_REC,
                                x_ctr IN OUT NOCOPY NUMBER,
                                x_uwqm_workitem_data IN OUT NOCOPY IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WR_ITEM_ACT_DATA_LIST);

PROCEDURE SET_DIST_AND_DEL_ITEM_DATA_REC( p_var_in_type_code IN VARCHAR2,
                                p_dist_workitem_data IN SYSTEM.WR_ITEM_DATA_NST,
                                p_dist_del_workitem_data IN IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WR_ITEM_DATA_REC,
                                x_ctr IN OUT NOCOPY NUMBER,
                                x_workitem_action_data IN OUT NOCOPY IEU_FRM_PVT.T_IEU_MEDIA_DATA);

PROCEDURE GET_WS_WHERE_CLAUSE
    (p_type             IN VARCHAR2,
     p_ws_det_list      IN IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WS_DETAILS_LIST,
     p_resource_id      IN NUMBER,
     x_dist_from_where OUT NOCOPY VARCHAR2,
     x_dist_to_where   OUT NOCOPY VARCHAR2,
     x_bindvar_from_list  OUT NOCOPY IEU_UWQ_BINDVAR_LIST,
     x_bindvar_to_list    OUT NOCOPY IEU_UWQ_BINDVAR_LIST);

PROCEDURE CLEANUP_DISTRIBUTING_STATUS
 (
  P_resource_id IN NUMBER,
  X_MSG_DATA OUT NOCOPY VARCHAR2,
  X_RETURN_STATUS OUT NOCOPY VARCHAR2
 );

PROCEDURE GET_WS_WHERE_CLAUSE
    (p_ws_det_list      IN IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WS_DETAILS_LIST,
     p_resource_id      IN NUMBER,
     x_dist_from_where OUT NOCOPY VARCHAR2,
     x_dist_to_where   OUT NOCOPY VARCHAR2);

end IEU_UWQ_GET_NEXT_WORK_PVT;


 

/
