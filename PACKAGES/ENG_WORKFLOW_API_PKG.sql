--------------------------------------------------------
--  DDL for Package ENG_WORKFLOW_API_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_WORKFLOW_API_PKG" AUTHID CURRENT_USER as
/* $Header: engwkfws.pls 120.0.12010000.1 2008/07/28 06:27:51 appldev ship $ */

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


-- PROCEDURE Get_ECO_and_OrgId
--
-- From the Item Key, get the ECO name and Organization Id.
   l_open_doc BOOLEAN := TRUE;

   PROCEDURE Get_ECO_and_OrgId	(itemtype	IN VARCHAR2,
		 	    	 itemkey	IN VARCHAR2,
			    	 actid		IN NUMBER,
			    	 funcmode	IN VARCHAR2,
			    	 result		IN OUT NOCOPY VARCHAR2);


-- PROCEDURE Get_ECO_Attributes
--
-- Get the attributes for an ECO.  Copy these attributes into the Workflow
-- Attributes belonging to the Item Type ECO_APP.

   PROCEDURE Get_Eco_Attributes (itemtype	IN VARCHAR2,
		 	    	 itemkey	IN VARCHAR2,
			    	 actid		IN NUMBER,
			    	 funcmode	IN VARCHAR2,
			    	 result		IN OUT NOCOPY VARCHAR2);


-- PROCEDURE Approve_ECO
--
-- This procedure updates an ECO's Approval Status to "Approved".
-- The Approval Date gets updated to today's date.  Also sets all "Open"
-- Revised Items to "Scheduled".

   PROCEDURE Approve_Eco       (itemtype        IN VARCHAR2,
                                itemkey         IN VARCHAR2,
                                actid           IN NUMBER,
                                funcmode        IN VARCHAR2,
                                result	        IN OUT NOCOPY VARCHAR2);


-- PROCEDURE Reject_ECO
--
-- This procedure updates an ECO's Approval Status to "Rejected".
-- The Approval Date gets nulled out.

   PROCEDURE Reject_Eco		(itemtype       IN VARCHAR2,
                                itemkey         IN VARCHAR2,
                                actid           IN NUMBER,
                                funcmode        IN VARCHAR2,
                                result		IN OUT NOCOPY VARCHAR2);


-- PROCEDURE Set_Eco_Approval_Error
--
-- This procedure sets an ECO's Approval Status to 'Processing Error'.  This
-- procedure is used in the Engineering Error Process.

   PROCEDURE Set_Eco_Approval_Error(itemtype        IN VARCHAR2,
                                    itemkey         IN VARCHAR2,
                                    actid           IN NUMBER,
                                    funcmode        IN VARCHAR2,
                                    result	    IN OUT NOCOPY VARCHAR2);


-- PROCEDURE Set_Mrp_Active
--
-- This procedure updates the MRP Active flag to 'Yes' for all the revised
-- items for a given ECO only if the revised item is at Status 'Open' or
-- 'Scheduled'.

   PROCEDURE Set_Mrp_Active	(itemtype        IN VARCHAR2,
                                 itemkey         IN VARCHAR2,
                                 actid           IN NUMBER,
                                 funcmode        IN VARCHAR2,
                                 result	         IN OUT NOCOPY VARCHAR2);


-- PROCEDURE Set_Mrp_Inactive
--
-- This procedure updates the MRP Active flag to 'No' for all the revised
-- items for a given ECO only if the revised item is at Status 'Open' or
-- 'Scheduled'.

   PROCEDURE Set_Mrp_Inactive	(itemtype        IN VARCHAR2,
                                 itemkey         IN VARCHAR2,
                                 actid           IN NUMBER,
                                 funcmode        IN VARCHAR2,
                                 result          IN OUT NOCOPY VARCHAR2);

-- PROCEDURE UPDATE_EVIDENCE
--
-- This procedure will post ERES record for ECO Approval wrk flow
-- into the evidence store. For both Approve and Rejected case.
--

   PROCEDURE UPDATE_EVIDENCE  (p_itemtype   IN VARCHAR2,
      	                       p_itemkey    IN VARCHAR2,
      	                       p_actid      IN NUMBER,
                               p_funcmode   IN VARCHAR2,
                               p_resultout  OUT NOCOPY VARCHAR2
  );

                            -- PROCEDURE Get_ERES_Attributes
--
-- Get the attributes for ERES process.  Copy these attributes into the Workflow
-- Attributes belonging to the Item Type ECO_APP.

   PROCEDURE Get_ERES_Attributes (itemtype	IN VARCHAR2,
		 	    	 itemkey	IN VARCHAR2,
			    	 actid		IN NUMBER,
			    	 funcmode	IN VARCHAR2,
			    	 result		IN OUT NOCOPY VARCHAR2);

-- VoteForResultType
--     Standard Voting Function
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   result    -
-- ACTIVITY ATTRIBUTES REFERENCED
--      VOTING_OPTION
--          - WAIT_FOR_ALL_VOTES  - Evaluate voting after all votes are cast
--                                - or a Timeout condition closes the voting
--                                - polls.  When a Timeout occurs the
--                                - voting percentages are calculated as a
--                                - percentage ofvotes cast.
--
--          - REQUIRE_ALL_VOTES   - Evaluate voting after all votes are cast.
--                                - If a Timeout occurs and all votes have not
--                                - been cast then the standard timeout
--                                - transition is taken.  Votes are calculated
--                                - as a percenatage of users notified to vote.
--
--          - TALLY_ON_EVERY_VOTE - Evaluate voting after every vote or a
--                                - Timeout condition closes the voting polls.
--                                - After every vote voting percentages are
--                                - calculated as a percentage of user notified
--                                - to vote.  After a timeout voting
--                                - percentages are calculated as a percentage
--                                - of votes cast.
--
--      "One attribute for each of the activities result type codes"
--
--          - The standard Activity VOTEFORRESULTTYPE has the WFSTD_YES_NO
--          - result type assigned.
--          - Thefore activity has two activity attributes.
--
--                  Y       - Percenatage required for Yes transition
--                  N       - Percentage required for No transition
--
procedure VoteForResultType(    itemtype   in varchar2,
                                itemkey    in varchar2,
                                actid      in number,
                                funcmode   in varchar2,
                                resultout  in out nocopy varchar2);

-- PROCEDURE CLOSE_AND_ACK_ERES_DOC
--
-- This procedure will closed and Acknowledge ERES document once completed
--
--

   PROCEDURE CLOSE_AND_ACK_ERES_DOC  (p_itemtype   IN VARCHAR2,
      	                              p_itemkey    IN VARCHAR2,
      	                              p_actid      IN NUMBER,
                                      p_funcmode   IN VARCHAR2,
                                      p_resultout  OUT NOCOPY VARCHAR2
  );



END ENG_WORKFLOW_API_PKG;

/
