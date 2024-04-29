--------------------------------------------------------
--  DDL for Package CSM_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: csmeutls.pls 120.12.12010000.2 2009/08/06 12:27:19 saradhak ship $ */

/***
  Debug levels:
  0 = No debug
  1 = Log errors
  2 = Log errors and functional messages
  3 = Log errors, functional messages and SQL statements
  4 = Full Debug
***/
g_debug_level_none        CONSTANT NUMBER := 0;
g_debug_level_error       CONSTANT NUMBER := 1;
g_debug_level_medium      CONSTANT NUMBER := 2;
g_debug_level_sql         CONSTANT NUMBER := 3;
g_debug_level_full        CONSTANT NUMBER := 4;
--g_flow_type varchar2(20) := 'NORMAL' ;

FUNCTION Get_Debug_Level
RETURN NUMBER;

--Contains information needed to refresh/sync an acc table with backend
TYPE Acc_Refresh_Desc_Rec_Type IS RECORD
(
  --backend table name that provides the primary key
  BACKEND_TABLE_NAME                VARCHAR2(30),
  --name of the primary key column
  PRIMARY_KEY_COLUMN                VARCHAR2(30),
  --name of the acc table to be updated
  ACC_TABLE_NAME                    VARCHAR2(30),
  --name of the acc sequence
  ACC_SEQUENCE_NAME                 VARCHAR2(50),
  --TL table name, if involved
  TL_TABLE_NAME                     VARCHAR2(30),
  --name of the publication item on PDA
  PUBLICATION_ITEM_NAME             VARCHAR2(30),
  --determines which entries user have access to
  --must select the primary_key_column
  --e.g. select task_status_id from jtf_task_statuses_b
  ACCESS_QUERY                      VARCHAR2(2048)
);

TYPE Acc_Refresh_Desc_Tbl_Type IS VARRAY(20) OF Acc_Refresh_Desc_Rec_Type;

TYPE Changed_Records_Cur_Type IS REF CURSOR;

-- Commented out as olite does not support large numbers
--Function generate_NumPK_FromStr(strPK varchar2 ) return number ;

Function GetLocalTime(p_server_time date, p_userid number) return date;

Function Get_Responsibility_ID(p_userid in number) RETURN NUMBER;

FUNCTION get_user_name(p_user_id IN number) RETURN varchar2;

Function MakeDirtyForUser ( p_publication_item in varchar2,
							p_accessList in number,
							p_resourceList in number,
							p_dmlList in char,
							p_timestamp in date) return boolean;

Function MakeDirtyForUser ( p_publication_item in varchar2,
							p_accessList in asg_download.access_list,
							p_resourceList in asg_download.user_list,
							p_dmlList in asg_download.dml_list,
							p_timestamp in date) return boolean;

Function MakeDirtyForUser ( p_publication_item in varchar2,
							p_accessList in asg_download.access_list,
							p_resourceList in asg_download.user_list,
							p_dmlList in char,
							p_timestamp in date) return boolean;

FUNCTION MakeDirtyForUser(p_publication_item in varchar2,
							    p_accessList in number,
							    p_resourceList in number,
							    p_dmlList in char,
							    p_timestamp in date,
           p_pkvalueslist IN asg_download.pk_list) RETURN BOOLEAN;

FUNCTION GetAsgDmlConstant( p_dml in char) return char;

function get_tl_omfs_palm_resources(p_language varchar2)
  return asg_download.user_list;

function get_tl_omfs_palm_users(p_language varchar2)
  return asg_download.user_list;

FUNCTION is_palm_resource(p_resource_id IN number)
RETURN boolean;

FUNCTION is_palm_user(p_user_id IN number)
RETURN boolean;

function get_all_omfs_palm_res_list return asg_download.user_list;

function get_all_omfs_palm_user_list return asg_download.user_list;

FUNCTION get_user_language(p_user_id IN NUMBER)
return VARCHAR2;

PROCEDURE refresh_all_app_level_acc (p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2);

Function MakeDirtyForResource ( p_publication_item in varchar2,
							    p_accessList in asg_download.access_list,
							    p_resourceList in asg_download.user_list,
							    p_dmlList in char,
							    p_timestamp in date)
return boolean;
  Function MakeDirtyForResource ( p_publication_item in varchar2,
							    p_accessList in number,
							    p_resourceList in number,
							    p_dmlList in char,
							    p_timestamp in date)
return boolean;

FUNCTION MakeDirtyForResource(p_publication_item in varchar2,
							    p_accessList in number,
							    p_resourceList in number,
							    p_dmlList in char,
							    p_timestamp in date,
           p_pkvalueslist IN asg_download.pk_list)
RETURN BOOLEAN;

--  procedure log (mesg varchar2);

/*--------------------------------
  This function returns a translated error message string. If p_api_error is FALSE, it gets
  message with MESSAGE_NAME = p_message from FND_NEW_MESSAGES and replaces any tokens with
  the supplied token values. If p_api_error is TRUE, it just returns the api error in the
  FND_MSG_PUB message stack.
--------------------------------*/
FUNCTION GET_ERROR_MESSAGE_TEXT(
          p_api_error      IN BOOLEAN  DEFAULT FALSE
         , p_message        IN FND_NEW_MESSAGES.MESSAGE_NAME%TYPE DEFAULT NULL
         , p_token_name1    IN VARCHAR2 DEFAULT NULL
         , p_token_value1   IN VARCHAR2 DEFAULT NULL
         , p_token_name2    IN VARCHAR2 DEFAULT NULL
         , p_token_value2   IN VARCHAR2 DEFAULT NULL
         , p_token_name3    IN VARCHAR2 DEFAULT NULL
         , p_token_value3   IN VARCHAR2 DEFAULT NULL
         )
RETURN VARCHAR2;

/*------------------------------------------------
  This procedure is called by APPLY_CLIENT_CHANGES wrapper procedure when a record was successfully
  applied and needs to be deleted from the in-queue.
------------------------------------------------*/
PROCEDURE DELETE_RECORD
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_seqno         IN NUMBER,
           p_pk            IN VARCHAR2,
           p_object_name   IN VARCHAR2,
           p_pub_name      IN VARCHAR2,
           p_error_msg     OUT NOCOPY VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         );

/*------------------------------------------------
  This procedure is called by APPLY_CLIENT_CHANGES wrapper procedure
  when a record failed to be processed and needs to be deferred and rejected from mobile.
------------------------------------------------*/
PROCEDURE DEFER_RECORD
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_seqno         IN NUMBER,
           p_pk            IN VARCHAR2,
           p_object_name   IN VARCHAR2,
           p_pub_name      IN VARCHAR2,
           p_error_msg     IN VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2,
           p_dml_type      IN VARCHAR2
         );

/***
  This procedure is called by APPLY_CLIENT_CHANGES wrapper procedure
  when the PK of the inserted record is created in the API.
  We need to remove the local PK from local
***/
PROCEDURE REJECT_RECORD
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_seqno         IN NUMBER,
           p_pk            IN VARCHAR2,
           p_object_name   IN VARCHAR2,
           p_pub_name      IN VARCHAR2,
           p_error_msg     IN VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         );

FUNCTION GET_TASK_ESC_LEVEL( p_task_id IN NUMBER) RETURN VARCHAR2;

/* Two functions to check if field service palm is enabled. */
FUNCTION IS_FIELD_SERVICE_PALM_ENABLED RETURN BOOLEAN;

/* logs messages using the JTT framework */
PROCEDURE log(message IN VARCHAR2,
              module IN VARCHAR2 DEFAULT 'CSM',
              log_level IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT);

  procedure pvt_log (mesg varchar2);
  Function GetServerTime(p_client_time date, p_user_name varchar2)
return date;

FUNCTION item_name(p_item_name IN varchar2) RETURN varchar2;

FUNCTION is_flow_history(p_flowtype IN VARCHAR2) RETURN BOOLEAN;

/*R12-Function is called in CSF_M_DEBRIEF_EXPENSES_V to make debrief_header_id column nullable*/
FUNCTION get_debrief_header_id(p_debrief_header_id in CSF_DEBRIEF_HEADERS.DEBRIEF_HEADER_ID%TYPE)
RETURN NUMBER;

/*R12-Function to return nullable number type for not null numbers*/
FUNCTION get_number(p_number IN NUMBER) RETURN NUMBER;

/*R12-Function to return nullable varchar type for not null varchar*/
FUNCTION get_varchar(p_varchar IN VARCHAR2) RETURN VARCHAR2;

/*R12-Function to return nullable date type for not null date*/
FUNCTION get_date(p_date IN DATE) RETURN DATE;

/*R12-Function to get owner's full/group name*/
FUNCTION get_owner_name(p_owner_type_code IN VARCHAR2,p_owner_id IN NUMBER,p_language IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION get_wf_attrText(p_notification_id IN NUMBER,p_attribute IN VARCHAR2)
RETURN VARCHAR2;

/*------------------------------------------------
  This Function is used to find the difference  between dates and convert it
to the required UOM given
------------------------------------------------*/
FUNCTION Get_Datediff_For_Req_UOM
					(	p_start_date IN DATE,
						p_end_date 	 IN DATE,
						p_class 	 IN MTL_UNITS_OF_MEASURE.UOM_CLASS%TYPE,
						p_to_uom 	 IN CSM_UNIT_OF_MEASURE_TL_ACC.UOM_CODE%TYPE,
					 	p_min_uom  	 IN CSM_UNIT_OF_MEASURE_TL_ACC.UOM_CODE%TYPE
					) RETURN NUMBER;

--12.1
FUNCTION is_mfs_group(p_group_id NUMBER) RETURN BOOLEAN;
--12.1
FUNCTION get_group_owner(p_group_id NUMBER) RETURN NUMBER;

--12.1
FUNCTION from_same_group(p_member1_resource_id NUMBER,p_member2_resource_id NUMBER) RETURN BOOLEAN;
--12.1 gets the owner id of the given user
FUNCTION get_owner(p_user_id NUMBER) RETURN NUMBER;

--12.1 gets the Group Name for a given Group
FUNCTION get_group_name(p_group_id NUMBER, p_language VARCHAR2) RETURN VARCHAR2;

/*returns True if the asg user name passed is just/being created by mmu*/
FUNCTION is_new_mmu_user(p_user_name IN VARCHAR2) RETURN BOOLEAN;

END CSM_UTIL_PKG; -- Package spec

/
