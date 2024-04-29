--------------------------------------------------------
--  DDL for Package IGI_ITR_APPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_ITR_APPROVAL_PKG" AUTHID CURRENT_USER AS
-- $Header: igiitrws.pls 120.4.12010000.2 2008/08/04 13:04:57 sasukuma ship $
--

  --
  -- Package
  --   IGI_ITR_APPROVAL_PKG
  -- Purpose
  --   Functions for ITR  approval workflow
  -- History
  --   27-SEP-2000    S Brewer      Created
  --
  --	Public variables
   diagn_msg_flag	BOOLEAN := TRUE;    -- Determines if diagnostic messages are displayed

  --
  -- Procedure
  --   Start_Approval_Workflow
  -- Purpose
  --   Start approval workflow for a process.
  -- History
  --   27-SEP-2000    S Brewer      Created
  -- Arguments
  --   p_cc_id           ID of cross charge (JE_UK_ITR_CHARGE_LINES.IT_HEADER_ID)
  --   p_cc_line_num       line number of cross charge line(JE_UK_ITR_CHARGE_LINES.IT_LINE_NUM)
  --   p_preparer_fnd_user_id  FND UserID of preparer (JE_UK_ITR_CHARGE_HEADERS.CREATED_BY)
  --  p_cc_name   cross charge name (JE_UK_ITR_CHARGE_HEADERS.NAME)
  --  p_prep_auth    does preparer have approval authority (parameter)
  --  p_sec_apprv_fnd_id  secondary approver id (if one was selected by preparer)
  -- Example
  --   ITR_APPROVAL_PKG.Start_Approval_Workflow (42789,1,1045,'charge1','Y',1021);
  --
  -- Notes
  --   Called from ITR enter charges form
  --   Must be called after a cross charge and all it's headers and lines have
  --   been inserted into the DB.
  --
  PROCEDURE start_approval_workflow ( p_cc_id                 IN NUMBER,
                                      p_cc_line_num           IN NUMBER,
                                      p_preparer_fnd_user_id  IN NUMBER,
                                      p_cc_name               IN VARCHAR2,
                                      p_prep_auth             IN VARCHAR2,
                                      p_sec_apprv_fnd_id      IN NUMBER);



  --
  -- Procedure
  --   Get_SOB_Attributes
  -- Purpose
  --   Copy information about the SOB to worklow tables
  -- History
  --   27-SEP-2000    S Brewer      Created
  -- Arguments
  --   itemtype   	   Workflow item type (Cross Charge)
  --   itemkey    	   ID of cross charge/cross charge line num
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or CANCEL)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine
  --   It retrieves data elements about the Set of Books (identified by the itemkey
  --   argument) and stores them in the workflow tables to make them available
  --   for messages and subsequent procedures.
  --
  PROCEDURE get_sob_attributes  (itemtype	IN VARCHAR2,
		     		 itemkey	IN VARCHAR2,
                       		 actid      	IN NUMBER,
                       		 funcmode    	IN VARCHAR2,
                                 result         OUT NOCOPY VARCHAR2 );



  --
  -- Procedure
  --   Get_cc_Attributes
  -- Purpose
  --   Copy information about cross charge to worklow tables
  -- History
  --   27-SEP-2000  S Brewer    Created.
  -- Arguments
  --   itemtype   	   Workflow item type (Cross charge)
  --   itemkey    	   ID of cross charge/cross charge line num
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or CANCEL)
  --   result              Result code
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine
  --   It retrieves data elements about the cross charge (identified by the itemkey
  --   argument) and stores them in the workflow tables to make them available
  --   for messages and subsequent procedures: cross charge name
  --   , preparer's name,
  --   total cross charge line amount and the functional currency code.
  --
  PROCEDURE get_cc_attributes  (itemtype	IN VARCHAR2,
		     		 itemkey	IN VARCHAR2,
                       		 actid      	IN NUMBER,
                       		 funcmode    	IN VARCHAR2,
                                 result         OUT NOCOPY VARCHAR2 );


  --
  -- Procedure
  --   did_preparer_approve
  -- Purpose
  --   Checks whether the preparer had authority to finally approve cross
  --    charge.
  -- History
  --   27-SEP-2000  S Brewer    Created.
  -- Arguments
  --   itemtype   	   Workflow item type (ITR Approval)
  --   itemkey    	   ID of cross charge/cross charge line/wkf run id
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or CANCEL)
  --   result              Result code
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine
  --   It checks whether the preparer had authority to finally approve cross
  --   charge and returns a value of 'Y' or 'N'
  --

  PROCEDURE did_preparer_approve( itemtype	  IN VARCHAR2,
		                  itemkey         IN VARCHAR2,
                                  actid	          IN NUMBER,
		                  funcmode	  IN VARCHAR2,
                                  result          OUT NOCOPY VARCHAR2 );

  --
  -- Procedure
  --   set_approver_name_to_prep
  -- Purpose
  --   Sets the workflow 'APPROVER' attributes to the values for the preparer
  -- History
  --   27-SEP-2000  S Brewer    Created.
  -- Arguments
  --   itemtype   	   Workflow item type (ITR Approval)
  --   itemkey    	   ID of cross charge/cross charge line/wkf run id
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or CANCEL)
  --   result              Result code
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine
  --   It sets the workflow 'APPROVER' attributes to the values for the
  --   preparer.
  --

  PROCEDURE set_approver_name_to_prep( itemtype	       IN VARCHAR2,
		                       itemkey         IN VARCHAR2,
                                       actid	       IN NUMBER,
		                       funcmode	       IN VARCHAR2,
                                       result          OUT NOCOPY VARCHAR2 );


  --
  -- Procedure
  --   secondary_approver_selected
  -- Purpose
  --   Checks whether a secondary approver was selected for the cross charge
  -- History
  --   27-SEP-2000  S Brewer    Created.
  -- Arguments
  --   itemtype   	   Workflow item type (ITR Approval)
  --   itemkey    	   ID of cross charge/cross charge line/wkf run id
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or CANCEL)
  --   result              Result code
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine
  --   It checks whether a secondary approver was selected for the cross charge
  --

  PROCEDURE secondary_approver_selected( itemtype	 IN VARCHAR2,
		                         itemkey         IN VARCHAR2,
                                         actid	         IN NUMBER,
		                         funcmode	 IN VARCHAR2,
                                         result          OUT NOCOPY VARCHAR2 );



  --
  -- Procedure
  --   set_approver_name_to_sec_app
  -- Purpose
  --   Sets the 'APPROVER' attributes to the values for the secondary approver
  -- History
  --   27-SEP-2000  S Brewer    Created.
  -- Arguments
  --   itemtype   	   Workflow item type (ITR Approval)
  --   itemkey    	   ID of cross charge/cross charge line/wkf run id
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or CANCEL)
  --   result              Result code
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine
  --   It sets the workflow 'APPROVER' attributes to the values for the
  --   secondary approver
  --

  PROCEDURE set_approver_name_to_sec_app( itemtype	 IN VARCHAR2,
		                          itemkey         IN VARCHAR2,
                                         actid	         IN NUMBER,
		                         funcmode	 IN VARCHAR2,
                                         result          OUT NOCOPY VARCHAR2 );



  --
  -- Procedure
  --   maintain_history
  -- Purpose
  --   Inserts a row into the ITR action history table to maintain
  --   an approval history of the actions performed
  -- History
  --   09-Mar-2001  S Brewer    Created.
  -- Arguments
  --   itemtype   	   Workflow item type (ITR Approval)
  --   itemkey    	   ID of cross charge/cross charge line/wkf run id
  --   actid		   ID of activity, provided by workflow engine
  --   funcmode		   Function mode (RUN or CANCEL)
  --   result              Result code
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine
  --   It is used to maintain an approval history (in the ITR action
  --   history table) for the service line.  It stores such things as
  --   the action performed (e.g. approval or rejection) and the user who
  --   performed the action.
  --

  PROCEDURE maintain_history( itemtype	 IN VARCHAR2,
		              itemkey    IN VARCHAR2,
                              actid	 IN NUMBER,
		              funcmode	 IN VARCHAR2,
                              result     OUT NOCOPY VARCHAR2 );



  --
  -- Procedure
  --   submit_cc_line
  -- Purpose
  --   Sets cross charge line status to 'submitted' and sends to receiving
  --   department
  -- History
  --   27-SEP-2000  S Brewer    Created.
  -- Arguments
  --   itemtype   	   Workflow item type (ITR Approval)
  --   itemkey    	   ID of cross charge/cross charge line/wkf run id
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or CANCEL)
  --   result              Result code
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine
  --   It sets the cross charge line status to 'submitted' and sends to
  --   receiving department
  --

  PROCEDURE submit_cc_line( itemtype	 IN VARCHAR2,
		            itemkey      IN VARCHAR2,
                            actid	 IN NUMBER,
		            funcmode	 IN VARCHAR2,
                            result       OUT NOCOPY VARCHAR2 );


  --
  -- Procedure
  --   no_submit_cc_line
  -- Purpose
  --   Sets cross charge line status to 'not submitted'
  -- History
  --   27-SEP-2000  S Brewer    Created.
  -- Arguments
  --   itemtype   	   Workflow item type (ITR Approval)
  --   itemkey    	   ID of cross charge/cross charge line/wkf run id
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or CANCEL)
  --   result              Result code
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine
  --   It sets the cross charge line status to 'not submitted'
  --

  PROCEDURE no_submit_cc_line( itemtype	 IN VARCHAR2,
		            itemkey      IN VARCHAR2,
                            actid	 IN NUMBER,
		            funcmode	 IN VARCHAR2,
                            result       OUT NOCOPY VARCHAR2 );



  --
  -- Procedure
  --   find_cc_receiver
  -- Purpose
  --   Find the first receiver for approval of the cross charge line
  -- History
  --   27-SEP-2000  S Brewer    Created.
  -- Arguments
  --   itemtype   	   Workflow item type (ITR Approval)
  --   itemkey    	   ID of cross charge/cross charge line
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or CANCEL)
  --   result              Result code
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine
  --   It finds the first receiver for approval of the cross charge line
  --   based upon the charge center  and sets the 'RECEIVER%' workflow
  --   attributes
  --

  PROCEDURE find_cc_receiver( itemtype	  IN VARCHAR2,
		            itemkey       IN VARCHAR2,
                            actid	  IN NUMBER,
		            funcmode	  IN VARCHAR2,
                            result        OUT NOCOPY VARCHAR2 );




  --
  -- Procedure
  --   Set_Approver_Name_to_rec
  -- Purpose
  --   Sets the workflow 'APPROVER' attributes to the values for the
  --   Receiver
  -- History
  --   27-SEP-2000 S Brewer  Created
  -- Arguments
  --   itemtype    Workflow item type (Cross Charge)
  --   itemkey     ID of cross charge/cross charge line
  --   actid       ID of activity, provided by workflow engine
  --                 (not used in this procedure)
  --   funcmode     Function mode (RUN or CANCEL)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --   It sets the approver name equal to the receiver name
  --
  PROCEDURE set_approver_name_to_rec( itemtype	   IN VARCHAR2,
		                      itemkey     IN VARCHAR2,
		                      actid	   IN NUMBER,
		                      funcmode	   IN VARCHAR2,
                                      result      OUT NOCOPY VARCHAR2 );


  --
  -- Procedure
  --   Double_Timeout
  -- Purpose
  --   Checks if the double timeout option is enabled
  -- History
  --   26-FEB-2001 S Brewer  Created
  -- Arguments
  --   itemtype    Workflow item type (Cross Charge)
  --   itemkey     ID of cross charge/cross charge line
  --   actid       ID of activity, provided by workflow engine
  --                 (not used in this procedure)
  --   funcmode     Function mode (RUN or CANCEL)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --   Checks if the double timeout option is enabled for the final
  --   approver
  --
  PROCEDURE double_timeout( itemtype	   IN VARCHAR2,
		            itemkey        IN VARCHAR2,
		            actid	   IN NUMBER,
		            funcmode	   IN VARCHAR2,
                            result         OUT NOCOPY VARCHAR2 );

  --
  -- Procedure
  --   Final_Approver
  -- Purpose
  --   Checks if this is the final approver
  -- History
  --   27-SEP-2000 S Brewer  Created
  -- Arguments
  --   itemtype    Workflow item type (Cross Charge)
  --   itemkey     ID of cross charge/cross charge line
  --   actid       ID of activity, provided by workflow engine
  --                 (not used in this procedure)
  --   funcmode     Function mode (RUN or CANCEL)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --   Checks if this is the final approver
  --
  PROCEDURE final_approver( itemtype	   IN VARCHAR2,
		            itemkey     IN VARCHAR2,
		            actid	   IN NUMBER,
		            funcmode	   IN VARCHAR2,
                            result      OUT NOCOPY VARCHAR2 );


  --
  -- Procedure
  --   Is_Receiver_Final_Approver
  -- Purpose
  --   Checks if the final approver is the receiver
  -- History
  --   27-SEP-2000 S Brewer  Created
  -- Arguments
  --   itemtype    Workflow item type (Cross Charge)
  --   itemkey     ID of cross charge/cross charge line
  --   actid       ID of activity, provided by workflow engine
  --                 (not used in this procedure)
  --   funcmode     Function mode (RUN or CANCEL)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --   Checks if the final approver is the receiver
  --
  PROCEDURE is_receiver_final_approver( itemtype	   IN VARCHAR2,
		                        itemkey     IN VARCHAR2,
		                        actid	   IN NUMBER,
		                        funcmode	   IN VARCHAR2,
                                        result      OUT NOCOPY VARCHAR2 );



  --
  -- Procedure
  --   Verify_Authority
  -- Purpose
  --   Hook to perform additional authoritization checks.
  -- History
  --   27-SEP-2000 S Brewer     Created
  -- Arguments
  --   itemtype	   Workflow item type (Cross charge)
  --   itemkey 	   ID of Cross Charge /cross charge line num
  --   actid	   ID of activity, provided by workflow engine
  --		     (not used in this procedure)
  --   funcmode	   Function mode (RUN or CANCEL)
  --   result	   Result of activity (PASS or FAIL)
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --   It performs additional checks to determine if the approver has sufficient
  --   authority.
  --
  PROCEDURE verify_authority( itemtype	IN VARCHAR2,
			      itemkey  	IN VARCHAR2,
			      actid	IN NUMBER,
			      funcmode	IN VARCHAR2,
			      result	OUT NOCOPY VARCHAR2 );
  --
  -- Procedure
  --   Approve_cc_line
  -- Purpose
  --   Approve cross charge line.
  -- History
  --   27-SEP-2000 S Brewer   Created
  -- Arguments
  --   itemtype	   Workflow item type ( Cross Charge)
  --   itemkey 	   ID of  cross charge /cross charge line
  --   actid	   ID of activity, provided by workflow engine
  --		     (not used in this procedure)
  --   funcmode	   Function mode (RUN or CANCEL)
  --   result	   Result of activity (not used in this procedure)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --   It updates the cross charge status to 'Approved'.

  PROCEDURE approve_cc_line( itemtype	 IN VARCHAR2,
		             itemkey  	 IN VARCHAR2,
		             actid	         IN NUMBER,
	                     funcmode	 IN VARCHAR2,
                             result           OUT NOCOPY VARCHAR2 );

  --
  -- Procedure
  --   Reject_cc_line
  -- Purpose
  --   Reject cross charge line.
  -- History
  --   27-SEP-2000 S Brewer   Created
  -- Arguments
  --   itemtype    Workflow item type (Cross Charge)
  --   itemkey     ID of Cross Charge /cross charge line num
  --   actid       ID of activity, provided by workflow engine
  --                 (not used in this procedure)
  --   funcmode     Function mode (RUN or CANCEL)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --   It sets the cross charge line status to 'Rejected' by updating the
  --   corresponding record in JE_UK_ITR_CHARGE_LINES.
  --

  PROCEDURE reject_cc_line( itemtype	  IN VARCHAR2,
		            itemkey    IN VARCHAR2,
		            actid	  IN NUMBER,
		            funcmode	  IN VARCHAR2,
                            result     OUT NOCOPY VARCHAR2 );




  --
  -- Procedure
  --  GetManager
  -- Purpose
  --  Gets the manager of the given employee id
  -- History
  --   27-SEP-2000 S Brewer   Created
  -- Arguments
  --   employee_id  employee_id whose manager is to be retrieved
  --   manager_id   manager_id of the given employee_id
  -- Example
  --   N/A (not user-callable)
  --
  --
  PROCEDURE getmanager( employee_id 	IN NUMBER,
                        manager_id	OUT NOCOPY NUMBER) ;



  --
  -- Procedure
  --   setpersonas
  -- Purpose
  --   Set the given manager_id as either tha manager or the approver
  --   based upon the manager_target
  -- History
  --   27-SEP-2000 S Brewer   Created
  -- Arguments
  --   manager_id       manager_id
  --   item_type        Workflow item type (Cross Charge)
  --   itemkey          ID of Cross Charge/cross charge line num
  --   manager_target   value it should be set to i.e. either a MANAGER
  --                    or APPROVER.
  -- Example
  --   N/A (not user-callable)
  --
  PROCEDURE setpersonas( manager_id     IN NUMBER,
                       item_type	IN VARCHAR2,
		       item_key	        IN VARCHAR2,
		       manager_target	IN VARCHAR2) ;


  --
  -- Procedure
  --   getfinalapprover
  -- Purpose
  --   Get the final approver for a given employee id
  -- History
  --   27-SEP-2000 S Brewer   Created
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
		      	      p_approval_amount		IN NUMBER,
			      p_item_type		IN VARCHAR2,
		      	      p_final_approver_id	OUT NOCOPY NUMBER) ;



  --
  -- Procedure
  --   getapprover
  -- Purpose
  --   Get the approver for a given employee id based upon the
  --   find_approver_method
  -- History
  --   27-SEP-2000 S Brewer   Created
  -- Arguments
  --   employee_id	     Employee ID
  --   approval_amount       Approval Amount
  --   item_type             Workflow item type
  --   curr_approver_id	     Current Approver ID
  --   find_approver_method  Find Approver Method
  --   next_approver_id      Next approver ID that the procedure computes.
  --
  PROCEDURE getapprover( employee_id		IN NUMBER,
		       approval_amount		IN NUMBER,
		       item_type		IN VARCHAR2,
                       item_key                 IN VARCHAR2,
		       curr_approver_id	        IN NUMBER,
                       find_approver_method	IN VARCHAR2,
		       next_approver_id	        IN OUT NOCOPY NUMBER );



  --
  -- Procedure
  --   find_approver
  -- Purpose
  --   Find the approver for the preparer of the journal entry
  -- History
  --   27-SEP-2000 S Brewer   Created
  -- Arguments
  --   itemtype    Workflow item type (Cross Charge)
  --   itemkey     ID of Cross Charge /cross charge line num
  --   actid       ID of activity, provided by workflow engine
  --                 (not used in this procedure)
  --   funcmode     Function mode (RUN or CANCEL)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --   It finds the approver for the receiver of the cross charge.
  --
  PROCEDURE find_approver( item_type	IN VARCHAR2,
		           item_key	IN VARCHAR2,
		           actid	IN NUMBER,
		           funmode	IN VARCHAR2,
		           result	OUT NOCOPY VARCHAR2) ;



  --
  -- Procedure
  --   record_forward_from_info
  -- Purpose
  --   Record the forward from info i.e. the approver from whom the entry
  --   is being forwarded from.
  -- History
  --   27-SEP-2000 S Brewer   Created
  -- Arguments
  --   itemtype    Workflow item type ( Cross Charge)
  --   itemkey     ID of Cross Charge/cross charge line num
  --   actid       ID of activity, provided by workflow engine
  --                 (not used in this procedure)
  --   funcmode     Function mode (RUN or CANCEL)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --   It records the forward from info.
  --
  PROCEDURE record_forward_from_info( p_item_type   IN VARCHAR2,
		     	  	      p_item_key    IN VARCHAR2,
		     	  	      p_actid	    IN NUMBER,
		     	  	      p_funmode     IN VARCHAR2,
		     	              p_result	    OUT NOCOPY VARCHAR2) ;



  --
  -- Procedure
  --   mgr_equalto_aprv
  -- Purpose
  --   Checks if the approver is the direct manager
  -- History
  --   27-SEP-2000 S Brewer   Created
  -- Arguments
  --   itemtype    Workflow item type ( Cross Charge)
  --   itemkey     ID of Cross Charge/cross charge line num
  --   actid       ID of activity, provided by workflow engine
  --                 (not used in this procedure)
  --   funcmode     Function mode (RUN or CANCEL)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --   It checks if the approver is the direct manager.
  --
  PROCEDURE mgr_equalto_aprv( p_item_type   IN VARCHAR2,
		     	      p_item_key    IN VARCHAR2,
		     	      p_actid	    IN NUMBER,
		     	      p_funmode     IN VARCHAR2,
		     	      p_result	    OUT NOCOPY VARCHAR2) ;



  --
  -- Procedure
  --   first_approver
  -- Purpose
  --   Finds out NOCOPY if this is the first approver
  -- History
  --   27-SEP-2000 S Brewer   Created
  -- Arguments
  --   itemtype    Workflow item type ( Cross Charge)
  --   itemkey     ID of Cross Charge/cross charge line num
  --   actid       ID of activity, provided by workflow engine
  --                 (not used in this procedure)
  --   funcmode     Function mode (RUN or CANCEL)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --   Finds out NOCOPY if this is the first approver
  --
  PROCEDURE first_approver( p_item_type   IN VARCHAR2,
		     	    p_item_key    IN VARCHAR2,
		     	    p_actid	    IN NUMBER,
		     	    p_funmode     IN VARCHAR2,
		     	    p_result	    OUT NOCOPY VARCHAR2) ;



  --
  -- Procedure
  --   set_employee_name_to_prep
  -- Purpose
  --   Sets workflow employee attributes to Preparer so that the find_approver
  --   procedure can be used for the Creation Approval Process and the
  --   Receiving Approval Process.
  -- History
  --   27-SEP-2000 S Brewer   Created
  -- Arguments
  --   itemtype    Workflow item type ( Cross Charge)
  --   itemkey     ID of Cross Charge/cross charge line num
  --   actid       ID of activity, provided by workflow engine
  --                 (not used in this procedure)
  --   funcmode     Function mode (RUN or CANCEL)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --   It sets workflow employee attributes to preparer so that the
  --   find_approver procedure can be used for the Creation Approval Process and
  --   the Receiving Approval Process.
  --
  PROCEDURE set_employee_name_to_prep(itemtype   IN VARCHAR2,
		     	               itemkey    IN VARCHAR2,
		     	               actid	    IN NUMBER,
		     	               funcmode     IN VARCHAR2,
		     	               result	    OUT NOCOPY VARCHAR2) ;


  --
  -- Procedure
  --   set_employee_name_to_rec
  -- Purpose
  --   Sets workflow employee attributes to receiver so that the find_approver
  --   procedure can be used for the Creation Approval Process and the
  --   Receiving Approval Process.
  -- History
  --   27-SEP-2000 S Brewer   Created
  -- Arguments
  --   itemtype    Workflow item type ( Cross Charge)
  --   itemkey     ID of Cross Charge/cross charge line num
  --   actid       ID of activity, provided by workflow engine
  --                 (not used in this procedure)
  --   funcmode     Function mode (RUN or CANCEL)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --   It sets workflow employee attributes to receiver so that the
  --   find_approver procedure can be used for the Creation Approval Process and
  --   the Receiving Approval Process.
  --
  PROCEDURE set_employee_name_to_rec( itemtype   IN VARCHAR2,
		     	               itemkey    IN VARCHAR2,
		     	               actid	    IN NUMBER,
		     	               funcmode     IN VARCHAR2,
		     	               result	    OUT NOCOPY VARCHAR2) ;



  --
  -- Procedure
  --   reset_approval_attributes
  -- Purpose
  --   Resets workflow approval attributes for the Receiving Approval
  --   Process.
  -- History
  --   27-SEP-2000 S Brewer   Created
  -- Arguments
  --   itemtype    Workflow item type ( Cross Charge)
  --   itemkey     ID of Cross Charge/cross charge line num
  --   actid       ID of activity, provided by workflow engine
  --                 (not used in this procedure)
  --   funcmode     Function mode (RUN or CANCEL)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine.
  --   It resets the workflow approval attributes for the Receiving Approval
  --   Process.
  --
  PROCEDURE reset_approval_attributes( itemtype   IN VARCHAR2,
		     	               itemkey    IN VARCHAR2,
		     	               actid	    IN NUMBER,
		     	               funcmode     IN VARCHAR2,
		     	               result	    OUT NOCOPY VARCHAR2) ;



END IGI_ITR_APPROVAL_PKG;

/
