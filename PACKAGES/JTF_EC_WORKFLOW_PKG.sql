--------------------------------------------------------
--  DDL for Package JTF_EC_WORKFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_EC_WORKFLOW_PKG" AUTHID CURRENT_USER as
/* $Header: jtfecwfs.pls 120.1.12010000.2 2009/01/29 12:21:01 ramchint ship $ */
/*#
 * This is the private interface to the JTF Escalation Management.
 * This Interface is used for handling workflow notifications.
 *
 * @rep:scope private
 * @rep:product JTF
 * @rep:lifecycle active
 * @rep:displayname Escalation Management
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY JTA_ESCALATION
*/

-- Start of comments
--	API name 	: JTF_EC_WORKFLOW_PKG
--	Type		: Private.
--	Function	: Private package used from JTFEC workflow item - sends --			  notifications for Reactive Escalation module.
--	Pre-reqs	: None.
--	Parameters	:
--      name                 direction  type     required?
--      ----                 ---------  ----     ---------
--      p_api_version         	IN	NUMBER	  required
--      p_init_msg_list       	IN	VARCHAR2  optional  DEFAULT fnd_api.g_false
--      p_commit              	IN	VARCHAR2  optional  DEFAULT fnd_api.g_false
--      x_return_status       	OUT     VARCHAR2  required
--      x_msg_count           	OUT     NUMBER	  required
--      x_msg_data            	OUT     VARCHAR2  required
--      p_task_id	      	IN 	NUMBER    required
--      p_doc_created           IN      VARCHAR2  optional  value 'Y' indicates that the document is created
--      p_owner_changed		IN      VARCHAR2  optional  value 'Y' indicates that the owner is changed
--      p_level_changed		IN      VARCHAR2  optional  value 'Y' indicates that the level is changed
--      p_status_changed	IN      VARCHAR2  optional  value 'Y' indicates that the status is changed
--      p_target_date_changed	IN      VARCHAR2  optional  value 'Y' indicates that the target_date is changed
--      p_old_owner_id        	IN      NUMBER 	  optional, required with OWNER_CHANGED event
--      p_old_level       	IN      VARCHAR2  optional, required with LEVEL_CHANGED event
--      p_old_status_id		IN      NUMBER	  optional, required with STATUS_CHANGED event
--      p_old_target_date	IN	DATE 	  optional, required with TARGET_DATE_CHANGED event
--      p_wf_process_name       IN 	VARCHAR2  optional    							--				                  DEFAULT  'ESC_NOTIF_PROCESS'
--	p_wf_item_type_name     IN      VARCHAR2
--						  DEFAULT  'JTFEC'
--	x_wf_process_id		OUT	NUMBER    required
--
--	Version	: Current version	1.0
--
--	Notes		:
--------------------------------------------------------------------------------
-- 	Currently we support the following events:
--	=============
--	OWNER_CHANGED
--	LEVEL_CHANGED
--	ESC_DOC_CREATED
--	STATUS_CHANGED
--	TARGET_DATE_CHANGED
--
---------------------------------------------------------------------------------
--
-- End of comments

G_PKG_NAME   		CONSTANT VARCHAR2(30) := 'JTF_EC_WORKFLOW_PKG';
jtf_resc_item_type 	CONSTANT VARCHAR2(8)  := 'JTFEC';
jtf_resc_main_process 	CONSTANT VARCHAR2(30) := 'ESC_NOTIF_PROCESS';
g_notif_not_sent	VARCHAR2(2000) := NULL;

--Record type added for ER 7032664
TYPE esc_rec_type IS RECORD(
     task_id                       NUMBER,
     doc_created             VARCHAR2(1),
     owner_changed           VARCHAR2(1),
     owner_type_changed      VARCHAR2(1),
     level_changed           VARCHAR2(1),
     status_changed          VARCHAR2(1),
     target_date_changed     VARCHAR2(1),
     old_owner_id            NUMBER,
     old_owner_type_code     VARCHAR2(30),
     old_level               VARCHAR2(30),
     old_status_id           NUMBER,
     old_target_date         DATE
  );


TYPE 	nlist_rec_type is RECORD (
	name 		wf_users.name%TYPE		:= FND_API.G_MISS_CHAR,
	display_name	wf_users.display_name%TYPE	:= FND_API.G_MISS_CHAR,
	email_address 	wf_users.email_address%TYPE	:= FND_API.G_MISS_CHAR);


TYPE	task_details_rec_type is RECORD(
	task_name	jtf_tasks_vl.task_name%TYPE,
	task_number	jtf_tasks_vl.task_number%TYPE,
	description 	jtf_tasks_vl.description%TYPE,
	owner_code 	jtf_tasks_vl.owner_type_code%TYPE,
	owner_id	jtf_tasks_vl.owner_id%TYPE,
	escalation_level jtf_tasks_vl.escalation_level%TYPE,
	task_status_id	jtf_tasks_vl.task_status_id%TYPE,
	target_date 	jtf_tasks_vl.planned_end_date%TYPE,
	date_opened 	jtf_tasks_vl.creation_date%TYPE,
	date_changed 	jtf_tasks_vl.last_update_date%TYPE,
	update_id 	jtf_tasks_vl.last_updated_by%TYPE,
	create_id 	jtf_tasks_vl.created_by%TYPE);


TYPE  	nlist_tbl_type is TABLE of nlist_rec_type
INDEX BY BINARY_INTEGER;

G_Miss_NotifList 	nlist_tbl_type;
G_Miss_Nlist_Rec	nlist_rec_type;

NotifList 	nlist_tbl_type;


/*#
* Starts the workflow for the resources related to the Escalation
*
* @param p_api_version the standard API version number
* @param p_init_msg_list the standard API flag allows API callers to request
* that the API does the initialization of the message list on their behalf.
* By default, the message list will not be initialized.
* @param p_commit the standard API flag is used by API callers to ask
* the API to commit on their behalf after performing its function
* By default, the commit will not be performed.
* @param x_return_status the parameter that returns the result of all the operations performed.
* by the API and must have one of the following values:
*   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
*   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
*   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
* @param x_msg_data the parameter that returns the FND Message in encoded format.
* @param x_msg_count the parameter that returns the number of messages in the FND message list.
* @param p_task_id the escalation id
* @param p_doc_created  the document created flag
* @param p_owner_changed the owner changed flag
* @param p_owner_type_changed the owner type changed flag
* @param p_level_changed the level changed flag
* @param p_status_changed the status changed flag
* @param p_target_date_changed the target date changed flag
* @param p_old_owner_id the old owner id
* @param p_old_owner_type_code the old owner type code
* @param p_old_level the old level
* @param p_old_status_id the old status id
* @param p_old_target_date the old target date
* @param p_wf_process_name the name of the workflow process
* @param p_wf_item_type_name the name of the workflow item type
* @param x_notif_not_sent the parameter that return the flag on notifications sent
* @param x_wf_process_id the parameter that returns the workflow process id
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Start Workflow Notifications
* @rep:compatibility S
*/
PROCEDURE Start_Resc_Workflow(
      p_api_version         	IN	NUMBER,
      p_init_msg_list       	IN	VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit              	IN	VARCHAR2 DEFAULT fnd_api.g_false,
      x_return_status       	OUT NOCOPY    VARCHAR2,
      x_msg_count           	OUT NOCOPY    NUMBER,
      x_msg_data            	OUT NOCOPY    VARCHAR2,
      p_task_id	      		IN 	NUMBER,
      p_doc_created            	IN      VARCHAR2	:= FND_API.G_MISS_CHAR,
      p_owner_changed		IN      VARCHAR2	:= FND_API.G_MISS_CHAR,
      p_owner_type_changed	IN      VARCHAR2	:= FND_API.G_MISS_CHAR,
      p_level_changed		IN      VARCHAR2	:= FND_API.G_MISS_CHAR,
      p_status_changed		IN      VARCHAR2	:= FND_API.G_MISS_CHAR,
      p_target_date_changed	IN      VARCHAR2	:= FND_API.G_MISS_CHAR,
      p_old_owner_id        	IN      NUMBER 		:= FND_API.G_MISS_NUM,
      p_old_owner_type_code    	IN      VARCHAR2 	:= FND_API.G_MISS_CHAR,
      p_old_level       	IN      VARCHAR2 	:= FND_API.G_MISS_CHAR,
      p_old_status_id		IN      NUMBER	 	:= FND_API.G_MISS_NUM,
      p_old_target_date		IN	DATE 		:= FND_API.G_MISS_DATE,
      p_wf_process_name         IN      VARCHAR2 	DEFAULT	'ESC_NOTIF_PROCESS',
      p_wf_item_type_name       IN      VARCHAR2 	DEFAULT 'JTFEC',
      x_notif_not_sent		OUT NOCOPY 	VARCHAR2,
      x_wf_process_id		OUT NOCOPY	NUMBER

   );

/*#
* Checks for the event based on the function mode
*
* @param itemtype the type of the workflow item
* @param itemkey the key of the workflow item
* @param actid the activity id
* @param funcmode the mode of activity - run / complete / cancel
* @param resultout the parameter the returns the status of the event
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Event
* @rep:compatibility S
*/
PROCEDURE Check_Event(
      itemtype    	IN       VARCHAR2,
      itemkey     	IN       VARCHAR2,
      actid       	IN       NUMBER,
      funcmode    	IN       VARCHAR2,
      resultout   	OUT NOCOPY    VARCHAR2
      );

/*#
* Sets the Notification Messages
*
* @param itemtype the type of the workflow item
* @param itemkey the key of the workflow item
* @param actid the activity id
* @param funcmode the mode of activity
* @param resultout the parameter the returns the status of the event
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Set Notification Message
* @rep:compatibility S
*/
PROCEDURE Set_Notif_Message(
      itemtype    IN       VARCHAR2,
      itemkey     IN       VARCHAR2,
      actid       IN       NUMBER,
      funcmode    IN       VARCHAR2,
      resultout   OUT NOCOPY     VARCHAR2
      );

/*#
* Sets the Notification Performer
*
* @param itemtype the type of the workflow item
* @param itemkey the key of the workflow item
* @param actid the activity id
* @param funcmode the mode of activity
* @param resultout the parameter the returns the status of the event
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Set Notification Performer
* @rep:compatibility S
*/
PROCEDURE Set_Notif_Performer(
      itemtype    IN       VARCHAR2,
      itemkey     IN       VARCHAR2,
      actid       IN       NUMBER,
      funcmode    IN       VARCHAR2,
      resultout   OUT NOCOPY     VARCHAR2
      );

/*#
* Gets the document details
*
* @param p_task_id the escalation id
* @param x_doc_type the parameter that returns type of reference document
* @param x_doc_number the parameter that returns number of the reference document
* @param x_doc_owner_name the parameter that returns owner name of the reference document
* @param x_doc_details_t the parameter that returns the document details in text format
* @param x_doc_details_h the paramter that returns the document details in html format
* @param x_return_status the parameter that returns the result of all the operations performed.
* by the API and must have one of the following values:
*   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
*   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
*   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Get Document Details
* @rep:compatibility S
*/
PROCEDURE get_doc_details(
			  p_task_id		IN 	VARCHAR2,
			  x_doc_type		OUT NOCOPY	VARCHAR2,
			  x_doc_number		OUT NOCOPY	VARCHAR2,
			  x_doc_owner_name	OUT NOCOPY	VARCHAR2,
			  x_doc_details_t	OUT NOCOPY	VARCHAR2,
			  x_doc_details_h	OUT NOCOPY	VARCHAR2,
			  x_return_status	OUT NOCOPY	VARCHAR2);

--Start of code for ER 7032664

Procedure Raise_Esc_Create_Event(P_TASK_ID IN NUMBER);

Procedure Raise_Esc_Update_Event(P_ESC_REC IN JTF_EC_WORKFLOW_PKG.esc_rec_type);

 FUNCTION create_esc_notif_subs (
      p_subscription_guid   IN              RAW,
      p_event               IN OUT NOCOPY   wf_event_t
      )
 RETURN VARCHAR2;

 FUNCTION update_esc_notif_subs (
      p_subscription_guid   IN              RAW,
      p_event               IN OUT NOCOPY   wf_event_t
      )
  RETURN VARCHAR2;

--End of code for ER 7032664

END JTF_EC_WORKFLOW_PKG;

/
