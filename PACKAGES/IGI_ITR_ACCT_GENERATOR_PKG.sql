--------------------------------------------------------
--  DDL for Package IGI_ITR_ACCT_GENERATOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_ITR_ACCT_GENERATOR_PKG" AUTHID CURRENT_USER AS
-- $Header: igiitrrs.pls 120.3.12000000.1 2007/09/12 10:32:35 mbremkum ship $
--

  --
  -- Package
  --    IGI_ITR_ACCT_GENERATOR_PKG
  -- Purpose
  --   Functions for self service ITR account generator workflow
  -- History
  --   01-NOV-2000    S Brewer      Created
  --
  --	Public variables
   diagn_msg_flag	BOOLEAN := TRUE;    -- Determines if diagnostic messages are displayed

  --
  -- Function
  --   Start_Acct_Generator_Workflow
  -- Purpose
  --   Start account generator workflow.
  -- History
  --   01-NOV-2000    S Brewer      Created
  -- Arguments
  --   p_coa_id               ID of chart of accounts being used (parameter)
  --   p_sob_id               ID of set of books being used (parameter)
  --   p_acct_type            Specifies which type of account is needed
  --                          Creation account or Receiving account
  --                          (C or R) (parameter)
  --  p_charge_center_id      ID of the charge center
  --  p_preparer_id           User ID of the preparer
  --  p_charge_service_id     Charge service id chosen by user for receiving
  --                          and creation accounts
  --  p_cost_center_value     value of cost center if chosen by user when
  --                          entering service line
  --  p_additional_seg_value  value of additional segment, if chosen by user
  --                          when entering service line
  --  x_return_ccid           ccid returned by account code generator
  --  x_concat_segs           concatenated segments returned by account
  --                          code generator
  --
  -- Example
  --   IGI_ITR_ACCT_GENERATOR_PKG.Start_Acct_Generator_Workflow(42789,12,'C',1045,1356,145,'100','ITR',x_return_ccid, x_concat_segs);
  --
  -- Notes
  --   Called from ITR enter charges form
  --
  FUNCTION start_acct_generator_workflow ( p_coa_id                 IN NUMBER,
                                      p_sob_id                IN NUMBER,
                                      p_acct_type             IN VARCHAR2,
                                      p_charge_center_id      IN NUMBER,
                                      p_preparer_id           IN NUMBER,
                                      p_charge_service_id     IN NUMBER,
                                      p_cost_center_value     IN VARCHAR2,
                                      p_additional_seg_value  IN VARCHAR2,
                                      x_return_ccid           IN OUT NOCOPY NUMBER,
                                      x_concat_segs           IN OUT NOCOPY VARCHAR2)
     return boolean;



  --
  -- Procedure
  --   account_type
  -- Purpose
  --   Retrieve the account type for which the code combination is required
  --   i.e. creating charge center's account or receiving charge center's
  --   account
  --   This is important because creation account and receiving account
  --   combinations are generated using different rules.
  -- History
  --   03-NOV-2000    S Brewer      Created
  -- Arguments
  --   itemtype   	   Workflow item type (ITR Account Generator)
  --   itemkey    	   fnd flex workflow item key
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or CANCEL)
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine
  --   It retrieves the account type for which the code combination
  --   is required, which is then used to determine which process the
  --   workflow should call next
  --

  PROCEDURE account_type  (itemtype	IN VARCHAR2,
		           itemkey	IN VARCHAR2,
                           actid    	IN NUMBER,
                           funcmode  	IN VARCHAR2,
                           result     OUT NOCOPY VARCHAR2 );



  --
  -- Procedure
  --  Fetch_creation_account
  -- Purpose
  --   Retrieve the creation account defined for the service
  --   to be used as a default account
  -- History
  --   03-NOV-2000  S Brewer    Created.
  -- Arguments
  --   itemtype   	   Workflow item type (ITR account generator)
  --   itemkey    	   fnd flex workflow item key
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or CANCEL)
  --   result              Result code
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine
  --   It retrieves the receipt account set up for the originating charge
  --   center.  This account is used as a default account when building
  --   the account for the header level of a cross charge
  --
  PROCEDURE fetch_creation_account  (itemtype	IN VARCHAR2,
		     	             itemkey	IN VARCHAR2,
                       		     actid     	IN NUMBER,
                       		     funcmode  	IN VARCHAR2,
                                     result     OUT NOCOPY VARCHAR2 );


  --
  -- Procedure
  --  Find_No_Of_Segs
  -- Purpose
  --   Retrieve the number of segments used for the chart of accounts
  -- History
  --   02-FEB-2001  S Brewer    Created.
  -- Arguments
  --   itemtype   	   Workflow item type (ITR account generator)
  --   itemkey    	   fnd flex workflow item key
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or CANCEL)
  --   result              Result code
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine
  --   It retrieves the number of segments defined for the chart of
  --   accounts for use in determining the number of times to execute
  --   the loop in the workflow.
  --

  PROCEDURE find_no_of_segs  (itemtype	IN VARCHAR2,
		     	      itemkey	IN VARCHAR2,
                       	      actid    	IN NUMBER,
                      	      funcmode  IN VARCHAR2,
                              result    OUT NOCOPY VARCHAR2 );


  --
  -- Procedure
  --  Increase_Counter
  -- Purpose
  --   Increase the workflow attribute counter by one
  -- History
  --   02-FEB-2001  S Brewer    Created.
  -- Arguments
  --   itemtype   	   Workflow item type (ITR account generator)
  --   itemkey    	   fnd flex workflow item key
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or CANCEL)
  --   result              Result code
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine
  --   It increases the workflow attribute 'COUNTER' by one and
  --   the next segment number
  --

  PROCEDURE increase_counter (itemtype	IN VARCHAR2,
		     	      itemkey	IN VARCHAR2,
                       	      actid    	IN NUMBER,
                      	      funcmode  IN VARCHAR2,
                              result    OUT NOCOPY VARCHAR2 );

  --
  -- Procedure
  --  Fetch_Segmenti_Value
  -- Purpose
  --   Fetches the value for the segmenti
  -- History
  --   02-FEB-2001  S Brewer    Created.
  -- Arguments
  --   itemtype   	   Workflow item type (ITR account generator)
  --   itemkey    	   fnd flex workflow item key
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or CANCEL)
  --   result              Result code
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine
  --   It fetches the value entered during originator setup for the
  --   segmenti (i being the value of the counter during the looping
  --   process)
  --

  PROCEDURE fetch_segmenti_value (itemtype	IN VARCHAR2,
		     	          itemkey	IN VARCHAR2,
                       	          actid    	IN NUMBER,
                      	          funcmode      IN VARCHAR2,
                                  result        OUT NOCOPY VARCHAR2 );


  --
  -- Procedure
  --  Fetch_Segmenti_Name
  -- Purpose
  --   Fetches the segment name for the segmenti
  -- History
  --   02-FEB-2001  S Brewer    Created.
  -- Arguments
  --   itemtype   	   Workflow item type (ITR account generator)
  --   itemkey    	   fnd flex workflow item key
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or CANCEL)
  --   result              Result code
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine
  --   It fetches the segment name of the segment i
  --   (i being the value of the counter during the looping process)
  --

  PROCEDURE fetch_segmenti_name  (itemtype	IN VARCHAR2,
		     	          itemkey	IN VARCHAR2,
                       	          actid    	IN NUMBER,
                      	          funcmode      IN VARCHAR2,
                                  result        OUT NOCOPY VARCHAR2 );



  --
  -- Procedure
  --   cost_center_value_chosen
  -- Purpose
  --   Checks whether a cost center value has been chosen by user
  -- History
  --   03-NOV-2000  S Brewer    Created.
  -- Arguments
  --   itemtype   	   Workflow item type (ITR Account Generator)
  --   itemkey    	   fnd flex workflow item key
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or CANCEL)
  --   result              Result code
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine
  --   It checks whether a cost center value has been chosen by the user
  --   Used when generating an account for the header level of a cross charge
  --

  PROCEDURE cost_center_value_chosen( itemtype	       IN VARCHAR2,
		                      itemkey          IN VARCHAR2,
                                      actid	       IN NUMBER,
		                      funcmode	       IN VARCHAR2,
                                      result           OUT NOCOPY VARCHAR2 );


  --
  -- Procedure
  --   additional_seg_value_chosen
  -- Purpose
  --   Checks whether an additional segment value was chosen by user when
  --   entering cross charge
  --   Returns 'Y' or 'N'
  -- History
  --   03-NOV-2000  S Brewer    Created.
  -- Arguments
  --   itemtype   	   Workflow item type (ITR Account Generator)
  --   itemkey    	   fnd flex workflow item key
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or CANCEL)
  --   result              Result code
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine
  --   It checks whether an additional segment value was chosen by a user
  --   when entering a cross charge.  Returns 'Y' or 'N'.
  --   It is used for both header level and line level account generation,
  --   since the additional segment can optionally be entered at both line
  --   and header level
  --

  PROCEDURE additional_seg_value_chosen( itemtype	 IN VARCHAR2,
		                         itemkey         IN VARCHAR2,
                                         actid	         IN NUMBER,
		                         funcmode	 IN VARCHAR2,
                                         result          OUT NOCOPY VARCHAR2 );



  --
  -- Procedure
  --   fetch_additional_seg_name
  -- Purpose
  --   Fetches the name of the additional segment
  -- History
  --   03-NOV-2000  S Brewer    Created.
  -- Arguments
  --   itemtype   	   Workflow item type (ITR Account Generator)
  --   itemkey    	   fnd flex workflow item key
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or CANCEL)
  --   result              Result code
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine
  --   It fetches the name of the additional segment if an additional segment
  --   value was chosen by the user when entering a cross charge.
  --   It is used for both header level and line level account generation,
  --   since the additional segment can optionally be entered at both line
  --   and header level
  --

  PROCEDURE fetch_additional_seg_name( itemtype	 IN VARCHAR2,
		                       itemkey   IN VARCHAR2,
                                       actid     IN NUMBER,
		                       funcmode	 IN VARCHAR2,
                                       result    OUT NOCOPY VARCHAR2 );



  --
  -- Procedure
  --   fetch_service_receiving_acct
  -- Purpose
  --   Fetches the service receiving account defined for charge center.
  -- History
  --   03-NOV-2000  S Brewer    Created.
  -- Arguments
  --   itemtype   	   Workflow item type (ITR Account Generator)
  --   itemkey    	   fnd flex workflow item key
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or CANCEL)
  --   result              Result code
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine
  --   It fetches the service receiving account defined for the charge center.
  --   This account is used as the default account for generating a receiving account
  --   at the service line level
  --

  PROCEDURE fetch_service_receiving_acct( itemtype	 IN VARCHAR2,
		                          itemkey       IN VARCHAR2,
                                          actid         IN NUMBER,
		                          funcmode	 IN VARCHAR2,
                                          result        OUT NOCOPY VARCHAR2 );



END IGI_ITR_ACCT_GENERATOR_PKG;

 

/
