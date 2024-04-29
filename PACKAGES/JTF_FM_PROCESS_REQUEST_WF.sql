--------------------------------------------------------
--  DDL for Package JTF_FM_PROCESS_REQUEST_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_FM_PROCESS_REQUEST_WF" AUTHID CURRENT_USER AS
/* $Header: jtffmwfs.pls 120.0 2005/05/11 08:14:29 appldev ship $ */
-- PROCEDURE start fulfillment request
-- DESCRIPTION	This procedure is called to start standard fulfillment workflow,
--assigns all attributes what jtf_fm_request_grp.submit_request api needs and launches the work flow.
--IN OUT
--p_api_version,p_init_msg_list,p_commit,p_validation_level,x_return_status,x_msg_data,x_msg_count are standard
-- api parameters.
--x_msg_count		:	Message count holds the number of messages in the API message list if this no
--								is one ,then message data holds the message in an encoded format.
--x_msg_data		:	Message in encoded format.
--x_return_status:represents the result of all operations performed by the API and must have one of the following
-- 'S'  (success)or 'E' (error) or 'U' (un explained).
-- content xml	:	The content xml formed by calling the Get_Content_XML.
-- content id		:	unique id of the content(	Required)
--								for content type of 'ATTACHMENT' ,the document must be stored in the fnd_lobs table and the
--								file_id (primary key in FND_LOBS table) must be passed as content_id.
--								for content_type of 'COLLATERAL','DATA', and 'QUERY' the item_id for the document in the MES tables
--								must be passed as content_id.
--request_id		:	Request ID obtained by calling the Start_Request API (system generated unique request id)
--template id		:	Fulfillment request template id (request templates are predefined and stored in the
--								database).The template id is null if the request does not correspond to a predefined template.
--subject				:
--party_id			:	Customer ID.
--party_name
--user_id				:	Agent/user_id.
--priority			:	These are defined as global constants in package JTF_FM_Request_GRP.
-- 	  User Note - Unused priority numbers are for future use.
--source_code_id:	Campaign/promotion field.
--source_code		:	Campaign/promotion field.
--object_type		:	Campaign/promotion field.
--object_id			:	Campaign/promotion field.
--order_id			:	Unique identifier of the order.
--doc_id				:
--doc_ref				:
--server_id			:	Unique identifier of the sever.
--queue_response:	Field to specify if response needs to queued in Response queue.
--extended_header:
---------------------------------------------------------------------
PROCEDURE start_fulfillment_request(item_type   						IN 			VARCHAR2,
																		item_key	 							IN			VARCHAR2,
																		item_user_key 					IN 			VARCHAR2,
																		p_content_xml						IN			VARCHAR2,
																		p_content_id						IN			NUMBER,
																		p_Request_id						IN 			NUMBER,
																		p_template_id         	IN  		NUMBER ,
																		p_subject             	IN  		VARCHAR2,
																		p_party_id 			   			IN  		NUMBER ,
																		p_party_name 			   		IN  		VARCHAR2 ,
																		p_user_id								IN 			VARCHAR2,
																		p_priority              IN  		NUMBER ,
																		p_source_code_id        IN			NUMBER,
																		p_source_code						IN			VARCHAR2,
																		p_object_type			   		IN  		VARCHAR2 ,
																		p_object_id 			   		IN  		NUMBER ,
																		p_order_id			   			IN  		NUMBER ,
																		p_doc_id				   			IN  		NUMBER ,
																		p_doc_ref 			   			IN  		VARCHAR2 ,
																		p_server_id			   			IN  		NUMBER ,
																		p_queue_response		  	IN  		VARCHAR2,
																		p_extended_header		  	IN  		VARCHAR2 ,
																		p_api_version 					IN 			NUMBER,
																		p_init_msg_list 				IN 			VARCHAR2,
																		p_commit								IN 			VARCHAR2,
																		p_validation_level   		IN  		NUMBER ,
																		x_Result								IN OUT NOCOPY	VARCHAR2,
																		x_msg_count							IN OUT NOCOPY	VARCHAR2,
																		x_msg_data							IN OUT NOCOPY	VARCHAR2,
																		x_return_status					IN OUT  NOCOPY		VARCHAR2);
----------------------------------------------------------------------
--PROCEDURE submit_fulfillment_request
--DESCRIPTION calls the jtf_fm_request_grp.submit_request
-- IN
--	itemtype  :	type of the current item
--  itemkey   :	key of the current item
--  actid    	:	process activity instance id
--  funcmode  :	function execution mode ('RUN','CANCEL','TIMEOUT');
--	OUT
--  resultout	:
--	COMPLETE : <resultout>
--activity has completed with indicated result
--	WAITING
--activity is waiting for additional transitions
--DEFERED
--execution should be deferred to background
--NOTIFIED	<notification_id> <assigned_user>
--activity has notified an external entity that this step must be
--performed . A call to wf_engine , complete activity will signal when this step is complete
--return of notification id and assigned user
--ERROR <error_code>
--function encountered an error
-----------------------------
PROCEDURE submit_fulfillment_request (
  itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    resultout OUT  NOCOPY VARCHAR2);
---------------------------------------------------------------------
--PROCEDURE check_request_result
--DESCRIPTION : checks the result from the submit_fulfillment_request
-- IN
--	itemtype  :	type of the current item
--  itemkey   :	key of the current item
--  actid    	:	process activity instance id
--  funcmode  :	function execution mode ('RUN','CANCEL','TIMEOUT');
--	OUT
--  resultout	:
--	COMPLETE : <resultout>
--activity has completed with indicated result
--	WAITING
--activity is waiting for additional transitions
--DEFERED
--execution should be deferred to background
--NOTIFIED	<notification_id> <assigned_user>
--activity has notified an external entity that this step must be
--performed . A call to wf_engine , complete activity will signal when this step is complete
--return of notification id and assigned user
--ERROR <error_code>
--function encountered an error
PROCEDURE Check_request_result (
  itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    resultout OUT NOCOPY  VARCHAR2);
-----------------------------------------------------------------------
-- PROCEDURE schedule_Callback
--
-- Description	 Creates a callback.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.
PROCEDURE schedule_Callback  		 (itemtype		in VARCHAR2,
		  				itemkey 		in VARCHAR2,
						actid 		in NUMBER,
						funcmode		in VARCHAR2,
						result 	out nocopy VARCHAR2 );
-----------------------------------------------------
-- PROCEDURE schedule_Callback
--
-- Description	 Creates a callback.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.
PROCEDURE check_if_callback_required 		 (itemtype		in VARCHAR2,
		  				itemkey 		in VARCHAR2,
						actid 		in NUMBER,
						funcmode		in VARCHAR2,
						result 	out nocopy VARCHAR2 );
--------------------------------------------------------
-- PROCEDURE verify_external
--
-- Description	 perform third party verification
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.
PROCEDURE verify_external (itemtype		in VARCHAR2,
		  				itemkey 		in VARCHAR2,
						actid 		in NUMBER,
						funcmode		in VARCHAR2,
						result 	out nocopy VARCHAR2 );
-----------------------------------------------------------
-- PROCEDURE verification_failed_notification
--
-- Description	 sends notification
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.
PROCEDURE verification_failed(itemtype		in VARCHAR2,
		  				itemkey 		in VARCHAR2,
						actid 		in NUMBER,
						funcmode		in VARCHAR2,
						result 	out nocopy VARCHAR2 );
END jtf_fm_process_request_wf ;


 

/
