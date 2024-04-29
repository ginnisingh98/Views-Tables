--------------------------------------------------------
--  DDL for Package PA_SELF_SERVICE_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_SELF_SERVICE_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXSSWFS.pls 120.1 2005/08/09 04:31:49 avajain noship $ */

-- Constant names for projects workflow

-----------------------------------------------------------------------------
PROCEDURE EmployeeEqualToPreparer(p_s_item_type   IN VARCHAR2,
                          	   p_s_item_key    IN VARCHAR2,
                          	   p_n_actid       IN NUMBER,
                          	   p_s_funmode     IN VARCHAR2,
                          	   p_s_result      OUT NOCOPY VARCHAR2);
----------------------------------------------------------------------
/**
Purpose: This procedure checks if the timecard can be autoapproved.

Input:  This procedure is called from workflow activity - so it has
	standard parameters for workflow function activity APIs
	p_s_item_type - 	Internal Name of the workflow itemtype calling this
		      	procedure.
	p_s_item_key  -	Unique workflow instance identifier for the item type
			calling this procedure.
	p_n_actid     -	The ID number of the activity that this procedure is
			called from.
	p_s_funmode   -	The execution mode of the function activity.It could
			be RUN/CANCEL/TIMEOUT.
Output:
	p_s_result    - 	If a result type is specified for the activity then
			this parameter indicates the result returned when the
			activity completes.
**/

PROCEDURE Autoapprove(		p_s_item_type   IN VARCHAR2,
                           	p_s_item_key    IN VARCHAR2,
                                p_n_actid       IN NUMBER,
                          	p_s_funmode     IN VARCHAR2,
                          	p_s_result      OUT NOCOPY VARCHAR2);
-----------------------------------------------------------------------------
/**
Purpose: This procedure finds an approver. It calls client extensions to find
	 an approver setup by the user.

Input:  This procedure is called from workflow activity - so it has
	standard parameters for workflow function activity APIs.
	The parameter descriptions are given for procedure 'Autoapprove'.
**/

PROCEDURE FindApprover(		p_s_item_type   IN VARCHAR2,
                           	p_s_item_key    IN VARCHAR2,
                                p_n_actid       IN NUMBER,
                          	p_s_funmode     IN VARCHAR2,
                          	p_s_result      OUT NOCOPY VARCHAR2);
-----------------------------------------------------------------------------
/**
Purpose: This procedure checks if the timecard is routed to the FirstApprover.

Input:  This procedure is called from workflow activity - so it has
	standard parameters for workflow function activity APIs.
	The parameter descriptions are given for procedure 'Autoapprove'.
**/
PROCEDURE FirstApprover(	p_s_item_type	IN VARCHAR2,
		     		p_s_item_key	IN VARCHAR2,
		     		p_n_actid		IN NUMBER,
		     		p_s_funmode	IN VARCHAR2,
		     		p_s_result	OUT NOCOPY VARCHAR2);
-----------------------------------------------------------------------------
/**
Purpose: This procedure checks if the timecard is routed to the Approver who
	 is not a first approver.

Input:  This procedure is called from workflow activity - so it has
	standard parameters for workflow function activity APIs.
	The parameter descriptions are given for procedure 'Autoapprove'.
**/
PROCEDURE ApprovalForwarded(	p_s_item_type	IN VARCHAR2,
		     	    	p_s_item_key	IN VARCHAR2,
		     	    	p_n_actid		IN NUMBER,
		     	    	p_s_funmode	IN VARCHAR2,
		     	    	p_s_result	OUT NOCOPY VARCHAR2);
----------------------------------------------------------------------------
/**
Purpose: This procedure checks if the approver is the direct manager of the
	 employee.

Input:  This procedure is called from workflow activity - so it has
	standard parameters for workflow function activity APIs.
	The parameter descriptions are given for procedure 'Autoapprove'.
**/
PROCEDURE IsApproverManager(	p_s_item_type	IN VARCHAR2,
		     	      	p_s_item_key	IN VARCHAR2,
		     	      	p_n_actid		IN NUMBER,
		     	  	p_s_funmode	IN VARCHAR2,
		     	  	p_s_result	OUT NOCOPY VARCHAR2);
----------------------------------------------------------------------------
/**
Purpose: This procedure records information about the previous approver
	 everytime the timecard is routed to another approver.

Input:  This procedure is called from workflow activity - so it has
	standard parameters for workflow function activity APIs.
	The parameter descriptions are given for procedure 'Autoapprove'.
**/
PROCEDURE RecordForwardFromInfo(p_s_item_type	IN VARCHAR2,
		     	  	p_s_item_key	IN VARCHAR2,
		     	  	p_n_actid		IN NUMBER,
		     	  	p_s_funmode	IN VARCHAR2,
		     	  	p_s_result	OUT NOCOPY VARCHAR2);
----------------------------------------------------------------------------
/**
Purpose: This procedure calls client extension to check authority of the
	 approver.

Input:  This procedure is called from workflow activity - so it has
	standard parameters for workflow function activity APIs.
	The parameter descriptions are given for procedure 'Autoapprove'.
**/
PROCEDURE VerifyAuthority(	p_s_item_type	IN VARCHAR2,
		     	    	p_s_item_key	IN VARCHAR2,
		     	    	p_n_actid		IN NUMBER,
		     	    	p_s_funmode	IN VARCHAR2,
		     	    	p_s_result	OUT NOCOPY VARCHAR2);
---------------------------------------------------------------------------
/**
Purpose: This procedure updates the PA_EXPENDITURE_ALL table once timecard
	 is approved.

Input:  This procedure is called from workflow activity - so it has
	standard parameters for workflow function activity APIs.
	The parameter descriptions are given for procedure 'Autoapprove'.
**/
PROCEDURE Approved(		p_s_item_type	IN VARCHAR2,
		   		p_s_item_key	IN VARCHAR2,
		   		p_n_actid		IN NUMBER,
		   		p_s_funmode	IN VARCHAR2,
		   		p_s_result	OUT NOCOPY VARCHAR2);
---------------------------------------------------------------------------
/**
Purpose: This procedure sets the status to Rejected and reset workflow
	 attributes since the instance can be restarted.

Input:  This procedure is called from workflow activity - so it has
	standard parameters for workflow function activity APIs.
	The parameter descriptions are given for procedure 'Autoapprove'.
**/
PROCEDURE Rejected(		p_s_item_type      IN VARCHAR2,
                          	p_s_item_key       IN VARCHAR2,
                          	p_n_actid          IN NUMBER,
                          	p_s_funmode        IN VARCHAR2,
                          	p_s_result         OUT NOCOPY VARCHAR2);
--------------------------------------------------------------------------
/**
Purpose: This procedure gets the manager of the employee .

Input:  This procedure is called from StartTimecardProcess procedure - as
	it sets the attribute value manager_id.
**/

PROCEDURE CallbackFunction(	p_s_item_type      IN VARCHAR2,
                          	p_s_item_key       IN VARCHAR2,
                          	p_n_actid          IN NUMBER,
                          	p_s_command        IN VARCHAR2,
                          	p_s_result         OUT NOCOPY VARCHAR2);


PROCEDURE GenerateTimecardLines(p_s_document_id	IN VARCHAR2,
				p_s_display_type IN VARCHAR2,
				p_s_document	IN OUT NOCOPY VARCHAR2,
				p_s_document_type IN OUT NOCOPY VARCHAR2);
-------------------------------------------------------------------------------
PROCEDURE GenerateDocumentAttributeValue(p_s_document_id	IN VARCHAR2,
					p_s_display_type	IN VARCHAR2,
					p_s_document		IN OUT NOCOPY VARCHAR2,
					p_s_document_type	IN OUT NOCOPY VARCHAR2);
----------------------------------------------------------------------------------
PROCEDURE IsTimecardTransferred(	p_s_item_type      IN VARCHAR2,
                          	p_s_item_key       IN VARCHAR2,
                          	p_n_actid          IN NUMBER,
                          	p_s_funmode        IN VARCHAR2,
                          	p_s_result         OUT NOCOPY VARCHAR2);


-------------------------------------------------------------------------------------
PROCEDURE ClearTransferInfo(	p_s_item_type      IN VARCHAR2,
                          	p_s_item_key       IN VARCHAR2,
                          	p_n_actid          IN NUMBER,
                          	p_s_funmode        IN VARCHAR2,
                          	p_s_result         OUT NOCOPY VARCHAR2);

--------------------------------------------------------------------------------------
PROCEDURE SetTransferInfo(	p_s_item_type      IN VARCHAR2,
                          	p_s_item_key       IN VARCHAR2,
                          	p_n_actid          IN NUMBER,
                          	p_s_funmode        IN VARCHAR2,
                          	p_s_result         OUT NOCOPY VARCHAR2);

END PA_SELF_SERVICE_WF_PKG;

 

/
