--------------------------------------------------------
--  DDL for Package GL_WF_JE_APPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_WF_JE_APPROVAL_PKG" AUTHID CURRENT_USER AS
/* $Header: glwfjeas.pls 120.5 2005/08/25 23:32:39 ticheng ship $ */

  --
  -- Package
  --   GL_WF_JE_APPROVAL_PKG
  -- Purpose
  --   Functions for JE approval workflow
  -- History
  --   06/30/97   R Goyal      Created
  --
  --	Public variables
  diagn_msg_flag  BOOLEAN := FALSE; -- whether to display diagnostic messages

  --
  -- Procedure
  --   start_approval_workflow
  -- Purpose
  --   Start approval workflow for a process.
  -- History
  --   06/30/97    R Goyal     Created
  -- Arguments
  --   p_je_batch_id           ID of batch (GL_JE_BATCHES.JE_BATCH_ID)
  --   p_preparer_fnd_user_id  FND UserID of preparer
  --                             (GL_JE_BATCHES.CREATED_BY)
  --   p_preparer_resp_id      ID of responsibility while JE was entered
  --                             or created
  -- Example
  --   GL_WF_JE_APPROVAL_PKG.Start_Approval_Workflow(42789,1045,1003,'abc');
  --
  -- Notes
  --   Called from Enter Journals form or from separate process.
  --   Must be called after a JE batch and all it's headers and lines have
  --   been inserted into the DB.
  --
  PROCEDURE start_approval_workflow(p_je_batch_id           IN NUMBER,
                                    p_preparer_fnd_user_id  IN NUMBER,
                                    p_preparer_resp_id      IN NUMBER,
                                    p_je_batch_name         IN VARCHAR2);

  --
  -- Procedure
  --   is_employee_set
  -- Purpose
  --   Checks whether the employee is set
  -- History
  --   08/11/99       R Goyal     Created.
  -- Arguments
  --   itemtype   	   Workflow item type (JE Batch)
  --   itemkey    	   ID of JE batch
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or CANCEL)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine
  --   It checks whether an employee is associated with the user.
  --
  PROCEDURE is_employee_set(itemtype   IN VARCHAR2,
			    itemkey    IN VARCHAR2,
			    actid      IN NUMBER,
			    funcmode   IN VARCHAR2,
			    result     OUT NOCOPY VARCHAR2);

  --
  -- Procedure
  --   get_sob_attributes (DO NOT CHANGE THIS NAME FOR UPGRADE CONSIDERATIONS)
  -- Purpose
  --   Copy information about a ledger in the batch to worklow tables
  -- History
  --   06/30/97       R Goyal     Created.
  -- Arguments
  --   itemtype   	   Workflow item type (JE Batch)
  --   itemkey    	   ID of JE batch
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or CANCEL)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine
  --   It retrieves data elements about the Ledgers in the batch, one ledger
  --   at a time, and stores them in the workflow tables to make them
  --   available for messages and subsequent procedures.
  --
  PROCEDURE get_sob_attributes(itemtype    IN VARCHAR2,
			       itemkey     IN VARCHAR2,
			       actid       IN NUMBER,
			       funcmode    IN VARCHAR2,
			       result      OUT NOCOPY VARCHAR2);

  --
  -- Procedure
  --   get_jeb_attributes
  -- Purpose
  --   Copy information about JE to worklow tables
  -- History
  --   06/30/97     R Goyal     Created.
  -- Arguments
  --   itemtype   	   Workflow item type (JE Batch)
  --   itemkey    	   ID of JE batch
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or CANCEL)
  --   result              Result code
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine
  --   It retrieves data elements about the JE batch (identified by the itemkey
  --   argument) and stores them in the workflow tables to make them available
  --   for messages and subsequent procedures.
  --
  PROCEDURE get_jeb_attributes(itemtype		IN VARCHAR2,
			       itemkey		IN VARCHAR2,
			       actid		IN NUMBER,
			       funcmode		IN VARCHAR2,
			       result		OUT NOCOPY VARCHAR2);

  --
  -- Procedure
  --   is_je_valid
  -- Purpose
  --   Check whether the JE is valid
  -- History
  --   06/30/97     R Goyal     Created.
  -- Arguments
  --   itemtype   	   Workflow item type (JE Batch)
  --   itemkey    	   ID of JE batch
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or CANCEL)
  --   result		   Result of activity (not used in this procedure)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine
  --   It determines whether the je is valid.
  --
  PROCEDURE is_je_valid(itemtype	IN VARCHAR2,
			itemkey		IN VARCHAR2,
			actid		IN NUMBER,
			funcmode	IN VARCHAR2,
			result		OUT NOCOPY VARCHAR2);

  --
  -- Procedure
  --   set_je_invalid
  -- Purpose
  --   Set the batch's approval status to Validation Failed
  -- History
  --   06/30/97    R Goyal    Created
  -- Arguments
  --   itemtype    Workflow item type (JE Batch)
  --   itemkey     ID of JE batch
  --   actid       ID of activity, provided by workflow engine
  --   funcmode    Function mode (RUN or CANCEL)
  --   result      Result code
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --   It sets the batch's approval status to 'Invalid' by updating the
  --   corresponding record in GL_JE_BATCHES.
  --
  PROCEDURE set_je_invalid(itemtype	IN VARCHAR2,
			   itemkey	IN VARCHAR2,
			   actid	IN NUMBER,
			   funcmode	IN VARCHAR2,
			   result	OUT NOCOPY VARCHAR2);

  --
  -- Procedure
  --   does_je_need_approval
  -- Purpose
  --   Determines if the JE needs approval.
  -- History
  --   06/30/97      R Goyal    Created.
  -- Arguments
  --   itemtype   	   Workflow item type (JE Batch)
  --   itemkey    	   ID of JE batch
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or CANCEL)
  --   result		   Result of activity (PASS or FAIL)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --   It determines whether the je needs approval.
  --
  PROCEDURE does_je_need_approval(itemtype	IN VARCHAR2,
				  itemkey	IN VARCHAR2,
				  actid		IN NUMBER,
				  funcmode	IN VARCHAR2,
				  result	OUT NOCOPY VARCHAR2);

  --
  -- Procedure
  --   set_approval_not_required
  -- Purpose
  --   Set the batch's approval status to approval not required.
  -- History
  --   06/30/97    R Goyal    Created
  -- Arguments
  --   itemtype    Workflow item type (JE Batch)
  --   itemkey     ID of JE batch
  --   actid       ID of activity, provided by workflow engine
  --                 (not used in this procedure)
  --   funcmode    Function mode (RUN or CANCEL)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --   It sets the batch's approval status to 'Not applicable' by updating the
  --   corresponding record in GL_JE_BATCHES.
  --
  PROCEDURE set_approval_not_required(itemtype	IN VARCHAR2,
				      itemkey	IN VARCHAR2,
				      actid	IN NUMBER,
				      funcmode	IN VARCHAR2,
				      result	OUT NOCOPY VARCHAR2);

  --
  -- Procedure
  --   can_preparer_approve
  -- Purpose
  --   Check whether the JE is valid
  -- History
  --   06/30/97     R Goyal     Created.
  -- Arguments
  --   itemtype   	   Workflow item type (JE Batch)
  --   itemkey    	   ID of JE batch
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or CANCEL)
  --   result		   Result of activity (not used in this procedure)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine
  --   It determines whether the preparer can auto-approve.
  --
  PROCEDURE can_preparer_approve(itemtype	IN VARCHAR2,
				 itemkey	IN VARCHAR2,
				 actid		IN NUMBER,
				 funcmode	IN VARCHAR2,
				 result		OUT NOCOPY VARCHAR2);

  --
  -- Procedure
  --   set_approver_name
  -- Purpose
  --   Set the Approver name to the Preparer Name
  -- History
  --   07/10/97    R Goyal    Created
  -- Arguments
  --   itemtype    Workflow item type (JE Batch)
  --   itemkey     ID of JE batch
  --   actid       ID of activity, provided by workflow engine
  --                 (not used in this procedure)
  --   funcmode    Function mode (RUN or CANCEL)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --   It sets the approver name equal to the preparer name
  --   when the batch is auto-approved.
  --
  PROCEDURE set_approver_name(itemtype	IN VARCHAR2,
		              itemkey	IN VARCHAR2,
		              actid	IN NUMBER,
		              funcmode	IN VARCHAR2,
                              result	OUT NOCOPY VARCHAR2);

  --
  -- Procedure
  --   set_je_approver
  -- Purpose
  --   Set the current or final approver of the batch.
  -- History
  --   11/19/03    T Cheng    Created
  -- Arguments
  --   itemtype	   Workflow item type (JE Batch)
  --   itemkey 	   ID of JE batch
  --   actid	   ID of activity, provided by workflow engine
  --		     (not used in this procedure)
  --   funcmode	   Function mode (RUN or CANCEL)
  --   result	   Result of activity (not used in this procedure)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --   It updates the batch approver.
  --
  PROCEDURE set_je_approver(itemtype	IN VARCHAR2,
			    itemkey	IN VARCHAR2,
			    actid	IN NUMBER,
			    funcmode	IN VARCHAR2,
			    result	OUT NOCOPY VARCHAR2);

  --
  -- Procedure
  --   approve_je
  -- Purpose
  --   Approve journal entry batch.
  -- History
  --   06/23/97    R Goyal    Created
  -- Arguments
  --   itemtype	   Workflow item type (JE Batch)
  --   itemkey 	   ID of JE batch
  --   actid	   ID of activity, provided by workflow engine
  --		     (not used in this procedure)
  --   funcmode	   Function mode (RUN or CANCEL)
  --   result	   Result of activity (not used in this procedure)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --   It updates the batch status to 'Approved'.
  --
  PROCEDURE approve_je(itemtype	IN VARCHAR2,
		       itemkey	IN VARCHAR2,
		       actid	IN NUMBER,
		       funcmode	IN VARCHAR2,
                       result	OUT NOCOPY VARCHAR2);

  --
  -- Procedure
  --   reject_je
  -- Purpose
  --   Reject journal entry batch.
  -- History
  --   06/30/97    R Goyal    Created
  -- Arguments
  --   itemtype    Workflow item type (JE Batch)
  --   itemkey     ID of JE batch
  --   actid       ID of activity, provided by workflow engine
  --                 (not used in this procedure)
  --   funcmode    Function mode (RUN or CANCEL)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --   It sets the batch status to 'Rejected' by updating the
  --   corresponding record in GL_JE_BATCHES.
  --
  PROCEDURE reject_je(itemtype	IN VARCHAR2,
		      itemkey	IN VARCHAR2,
		      actid	IN NUMBER,
		      funcmode	IN VARCHAR2,
                      result	OUT NOCOPY VARCHAR2);

  --
  -- Procedure
  --   find_approver
  -- Purpose
  --   Find the approver for the preparer of the journal entry
  -- History
  --   07/10/97    R Goyal    Created
  -- Arguments
  --   itemtype    Workflow item type (JE Batch)
  --   itemkey     ID of JE batch
  --   actid       ID of activity, provided by workflow engine
  --                 (not used in this procedure)
  --   funcmode    Function mode (RUN or CANCEL)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --   It finds the approver for the preparer of the journal entry.
  --
  PROCEDURE find_approver(item_type	IN VARCHAR2,
			  item_key	IN VARCHAR2,
			  actid		IN NUMBER,
			  funcmode	IN VARCHAR2,
			  result	OUT NOCOPY VARCHAR2);

  --
  -- Procedure
  --   first_approver
  -- Purpose
  --   Finds out whether the current approver is the first approver for
  --   the preparer's batch.
  -- History
  --   07/10/97    R Goyal    Created
  -- Arguments
  --   itemtype    Workflow item type (JE Batch)
  --   itemkey     ID of JE batch
  --   actid       ID of activity, provided by workflow engine
  --                 (not used in this procedure)
  --   funcmode    Function mode (RUN or CANCEL)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --   It finds out whether the current approver is the first approver
  --   for the preparer's batch.
  --
  PROCEDURE first_approver(item_type	IN VARCHAR2,
			   item_key	IN VARCHAR2,
			   actid	IN NUMBER,
			   funcmode	IN VARCHAR2,
			   result	OUT NOCOPY VARCHAR2);

  --
  -- Procedure
  --   set_curr_approver
  -- Purpose
  --   When approver is reassigned, update the approver's name
  -- History
  --   01/26/05     T Cheng     Created.
  -- Arguments
  --   itemtype   	   Workflow item type (JE Batch)
  --   itemkey    	   ID of JE batch
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or RESPOND or CANCEL)
  --   result		   Result of activity (not used in this procedure)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine
  --   It updates approver name in this post-notification function.
  --
  PROCEDURE set_curr_approver(itemtype	IN VARCHAR2,
			      itemkey	IN VARCHAR2,
			      actid	IN NUMBER,
			      funcmode	IN VARCHAR2,
			      result	OUT NOCOPY VARCHAR2);

  --
  -- Procedure
  --   mgr_equalto_aprv
  -- Purpose
  --   Find out whether the manager is equal to the approver
  -- History
  --   07/10/97    R Goyal    Created
  -- Arguments
  --   itemtype    Workflow item type (JE Batch)
  --   itemkey     ID of JE batch
  --   actid       ID of activity, provided by workflow engine
  --                 (not used in this procedure)
  --   funcmode    Function mode (RUN or CANCEL)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --   It finds out whether the manager is equal to the
  --   approver.
  --
  PROCEDURE mgr_equalto_aprv(item_type	IN VARCHAR2,
			     item_key	IN VARCHAR2,
			     actid	IN NUMBER,
			     funcmode	IN VARCHAR2,
			     result	OUT NOCOPY VARCHAR2);

  --
  -- Procedure
  --   notifyprep_noaprvresp
  -- Purpose
  --   Finds out whether the preparer should be notified about the
  --   approver not responding
  -- History
  --   07/10/97    R Goyal    Created
  -- Arguments
  --   itemtype    Workflow item type (JE Batch)
  --   itemkey     ID of JE batch
  --   actid       ID of activity, provided by workflow engine
  --                 (not used in this procedure)
  --   funcmode    Function mode (RUN or CANCEL)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --   It finds out whether the preparer should be notified about the
  --   manager not responding.
  --
  PROCEDURE notifyprep_noaprvresp(item_type	IN VARCHAR2,
				  item_key	IN VARCHAR2,
				  actid		IN NUMBER,
				  funcmode	IN VARCHAR2,
				  result	OUT NOCOPY VARCHAR2);

  --
  -- Procedure
  --   get_approver_manager
  -- Purpose
  --   Get the manager of the approver
  -- History
  --   07/10/97    R Goyal    Created
  -- Arguments
  --   itemtype    Workflow item type (JE Batch)
  --   itemkey     ID of JE batch
  --   actid       ID of activity, provided by workflow engine
  --                 (not used in this procedure)
  --   funcmode    Function mode (RUN or CANCEL)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --   It gets the approver's manager.
  --
  PROCEDURE get_approver_manager(item_type	IN VARCHAR2,
				 item_key	IN VARCHAR2,
				 actid		IN NUMBER,
				 funcmode	IN VARCHAR2,
				 result		OUT NOCOPY VARCHAR2);

  --
  -- Procedure
  --   record_forward_from_info
  -- Purpose
  --   Record the forward from info i.e. the approver from whom the entry
  --   is being forwarded from.
  -- History
  --   07/10/97    R Goyal    Created
  -- Arguments
  --   itemtype    Workflow item type (JE Batch)
  --   itemkey     ID of JE batch
  --   actid       ID of activity, provided by workflow engine
  --                 (not used in this procedure)
  --   funcmode    Function mode (RUN or CANCEL)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --   It records the forward from info.
  --
  PROCEDURE record_forward_from_info(item_type	IN VARCHAR2,
		     	  	     item_key	IN VARCHAR2,
		     	  	     actid	IN NUMBER,
		     	  	     funcmode	IN VARCHAR2,
		     	             result	OUT NOCOPY VARCHAR2);

  --
  -- Procedure
  --   verify_authority
  -- Purpose
  --   Hook to perform additional authoritization checks.
  -- History
  --   06/30/97    R Goyal      Created
  -- Arguments
  --   itemtype	   Workflow item type (JE Batch)
  --   itemkey 	   ID of JE batch
  --   actid	   ID of activity, provided by workflow engine
  --		     (not used in this procedure)
  --   funcmode	   Function mode (RUN or CANCEL)
  --   result	   Result of activity (PASS or FAIL)
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --   It performs additional checks to determine if the approver has
  --   sufficient authority.
  --
  PROCEDURE verify_authority(itemtype	IN VARCHAR2,
			     itemkey  	IN VARCHAR2,
			     actid	IN NUMBER,
			     funcmode	IN VARCHAR2,
			     result	OUT NOCOPY VARCHAR2);

  --
  -- Procedure
  --   abort_process
  -- Purpose
  --   Abort the request process.
  -- History
  --   08/23/05    T Cheng    Created.
  -- Arguments
  --   itemtype   	   Workflow item type (JE Batch)
  --   itemkey    	   ID of JE batch
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or RESPOND or CANCEL)
  --   result		   Result of activity (not used in this procedure)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --
  PROCEDURE abort_process(itemtype IN VARCHAR2,
                          itemkey  IN VARCHAR2,
                          actid    IN NUMBER,
                          funcmode IN VARCHAR2,
                          result   OUT NOCOPY VARCHAR2);


/********** The following four procedures are changed to private. **********

  --
  -- Procedure
  --   setpersonas
  -- Purpose
  --   Set the given manager_id as either tha manager or the approver
  --   based upon the manager_target
  -- History
  --   07/10/97    R Goyal    Created
  -- Arguments
  --   manager_id       manager_id
  --   item_type        Workflow item type (JE Batch)
  --   itemkey          ID of JE batch
  --   manager_target   value it should be set to i.e. either a MANAGER
  --                    or APPROVER.
  -- Example
  --   N/A (not user-callable)
  --
  PROCEDURE setpersonas( manager_id	IN NUMBER,
			 item_type	IN VARCHAR2,
			 item_key	IN VARCHAR2,
			 manager_target	IN VARCHAR2 );

  --
  -- Procedure
  --   getfinalapprover
  -- Purpose
  --   Get the final approver for a given employee id
  -- History
  --   07/10/97    R Goyal    Created
  -- Arguments
  --   p_employee_id           Employee ID
  --   p_approval_amount       Amount that needs to be approved
  --   p_item_type	       Workflow Item Type
  --   p_final_approver_id     Approver's ID
  -- Example
  --   N/A (not user-callable)
  --
  PROCEDURE getfinalapprover( p_employee_id		IN NUMBER,
                              p_set_of_books_id         IN NUMBER,
--		      	      p_approval_amount		IN NUMBER,
--			      p_item_type		IN VARCHAR2,
		      	      p_final_approver_id	OUT NOCOPY NUMBER );

  --
  -- Procedure
  --   getapprover
  -- Purpose
  --   Get the approver for a given employee id based upon the
  --   find_approver_method
  -- History
  --   07/10/97    R Goyal    Created
  -- Arguments
  --   employee_id	     Employee ID
  --   approval_amount       Approval Amount
  --   item_type             Workflow item type
  --   curr_approver_id	     Current Approver ID
  --   find_approver_method  Find Approver Method
  --   next_approver_id      Next approver ID that the procedure computes.
  --
  PROCEDURE getapprover( employee_id			IN NUMBER,
--			 approval_amount		IN NUMBER,
			 item_type			IN VARCHAR2,
			 item_key			IN VARCHAR2,
			 curr_approver_id		IN NUMBER,
			 find_approver_method		IN VARCHAR2,
			 next_approver_id    IN OUT NOCOPY NUMBER );

  --
  -- Procedure
  --  GetManager
  -- Purpose
  --  Gets the manager of the given employee id
  -- History
  --   07/10/97    R Goyal    Created
  -- Arguments
  --   employee_id  employee_id whose manager is to be retrieved
  --   manager_id   manager_id of the given employee_id
  -- Example
  --   N/A (not user-callable)
  --
  --
  PROCEDURE getmanager( employee_id 	IN NUMBER,
                        manager_id	OUT NOCOPY NUMBER );

***************************************************************************/


END GL_WF_JE_APPROVAL_PKG;

 

/
