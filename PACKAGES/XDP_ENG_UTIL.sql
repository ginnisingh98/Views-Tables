--------------------------------------------------------
--  DDL for Package XDP_ENG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_ENG_UTIL" AUTHID CURRENT_USER AS
/* $Header: XDPENGUS.pls 120.1 2005/06/15 22:57:33 appldev  $ */

-- PL/SQL Specification
-- Datastructure Definitions


 -- API specifications

-- Start of comments
--	API name 	: Add_FA_toWI
--	Type		: Public
--	Function	: Add a fulfillment action instnace to a workitem instance.
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_wi_instance_id:	NUMBER	Required
--					The internal ID for a given work item instance
--				p_fa_name:	VARCHAR2 	Required
--					The name of the fulfillment action
--				p_fe_name:	VARCHAR2 	Optional
--					The name of the fulfillment element to be provisioned
--				p_priority:	NUMBER 	Optional
--					The provisioning priority of the fulfillment action
--					Default to be 100.
--				p_provisioning_seq:	NUMBER 	Optional
--					The provisioning sequence of the fulfillment action
--					Default to be 0 which means it has no dependency with
--					other fulfillment actions associated with the work item.
--  @return  	The runtime ID of the fulfillment action instance
--
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
 FUNCTION Add_FA_toWI(
	p_wi_instance_id IN NUMBER,
	p_fa_name   IN VARCHAR2,
	p_fe_name  IN VARCHAR2 DEFAULT NULL,
	p_priority  IN number default 100,
	p_provisioning_seq  IN NUMBER default 0)
   return NUMBER;


-- Start of comments
--	API name 	: Add_FA_toWI
--	Type		: Private
--	Function	: Overload function. Add a fulfillment action instnace to a workitem instance.
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_wi_instance_id:	NUMBER	Required
--					The internal ID for a given work item instance
--				p_fulfillment_action_id:	NUMBER 	Required
--					The internal ID of the fulfillment action
--				p_fe_name:	VARCHAR2 	Optional
--					The name of the fulfillment element to be provisioned
--				p_priority:	NUMBER 	Optional
--					The provisioning priority of the fulfillment action
--					Default to be 100.
--				p_provisioning_seq:	NUMBER 	Optional
--					The provisioning sequence of the fulfillment action
--					Default to be 0 which means it has no dependency with
--					other fulfillment actions associated with the work item.
--  @return  	The runtime ID of the fulfillment action instance
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
 FUNCTION Add_FA_toWI(
	p_wi_instance_id 		IN   NUMBER,
	p_fulfillment_action_id IN   NUMBER,
	p_fe_name  IN VARCHAR2 DEFAULT NULL,
	p_priority  IN number default 100,
	p_provisioning_seq  IN NUMBER default 0)
   return NUMBER;

-- Start of comments
--	API name 	: Add_FA_toWI
--	Type		: Public
--	Function	: Add a fulfillment action instnace to a workitem instance.
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_wi_instance_id:	NUMBER	Required
--					The internal ID for a given work item instance
--				p_fa_name:	VARCHAR2 	Required
--					The name of the fulfillment action
--				p_fe_id:	NUMBER 	Optional
--					The ID of the fulfillment element to be provisioned
--				p_priority:	NUMBER 	Optional
--					The provisioning priority of the fulfillment action
--					Default to be 100.
--				p_provisioning_seq:	NUMBER 	Optional
--					The provisioning sequence of the fulfillment action
--					Default to be 0 which means it has no dependency with
--					other fulfillment actions associated with the work item.
--  @return  	The runtime ID of the fulfillment action instance
--
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
 FUNCTION Add_FA_toWI(
	p_wi_instance_id IN NUMBER,
	p_fa_name   IN VARCHAR2,
	p_fe_id  IN NUMBER DEFAULT NULL,
	p_priority  IN number default 100,
	p_provisioning_seq  IN NUMBER default 0)
   return NUMBER;

-- Start of comments
--	API name 	: Resubmit_FA
--	Type		: Private
--	Function	: Re-execute a fulfillment action for a workitem instance.
--	Pre-reqs	: None.
--  @return  	The new runtime ID of the fulfillment action instance
--
--	Version	: Current version	11.5
--	Notes	:
--				The fulfillment action instance to be resubmitted must
--				have been completed previously.
-- End of comments
 FUNCTION Resubmit_FA(
	p_resubmission_job_id 	IN   NUMBER,
	p_resub_fa_instance_id  IN   NUMBER)
   return NUMBER;


-- Start of comments
--	API name 	: Execute_FA
--	Type		: Group
--	Function	: Execute the fulfillment action provisioning process.
--	Pre-reqs	: None.
--	Version	: Current version	11.5
--	Notes	:
--   This procedure will execute the fulfillment action
--   provisioning process.  The workflow item type and
--	 item key for the workitem are needed to establish parent
--   child relationship between the WI workflow and the FA
--   process.  At the end of the FA process, a call
--   to CONTINUEFLOW will be made to notify its parent
--   to continue process.
-- End of comments
 PROCEDURE Execute_FA(
		p_order_id       IN NUMBER,
		p_wi_instance_id IN NUMBER,
		p_fa_instance_id IN NUMBER,
		p_wi_item_type   IN varchar2,
		p_wi_item_key    IN varchar2,
		p_return_code    OUT NOCOPY NUMBER,
		p_error_description  OUT NOCOPY VARCHAR2,
		p_fa_caller  IN VARCHAR2 DEFAULT 'EXTERNAL');

-- Start of comments
--	API name 	: Execute_FA
--	Type		: Group
--	Function	: Execute the fulfillment action provisioning process.
--	Pre-reqs	: None.
--	Version	: Current version	11.5
--	Notes	:
--   This procedure will execute the fulfillment action
--   provisioning process for resubmission.  The workflow item type and
--	 item key for the workitem are needed to establish parent
--   child relationship between the WI workflow and the FA
--   process.  At the end of the FA process, a call
--   to CONTINUEFLOW will be made to notify its parent
--   to continue process.
-- End of comments
 PROCEDURE Execute_Resubmit_FA(
		p_order_id       IN NUMBER,
		p_line_item_id   IN NUMBER,
		p_wi_instance_id IN NUMBER,
		p_fa_instance_id IN NUMBER,
		p_oru_item_type   IN varchar2,
		p_oru_item_key    IN varchar2,
		p_fa_master		IN VARCHAR2,
		p_resubmission_job_id IN NUMBER,
		p_return_code    OUT NOCOPY NUMBER,
		p_error_description  OUT NOCOPY VARCHAR2,
		p_fa_caller  IN VARCHAR2 DEFAULT 'EXTERNAL');

END XDP_ENG_UTIL;

 

/
