--------------------------------------------------------
--  DDL for Package AHL_ITEMGROUPS_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_ITEMGROUPS_APPROVAL_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVIWFS.pls 115.0 2003/07/03 14:36:54 sjayacha noship $ */
--------------------------------------------------------------------------
-- PROCEDURE
--   Set_Activity_Details
--
-- PURPOSE
--   This procedure will set the workflow attributes for the details of the activity.
--
-- IN
--   itemtype -  The internale name of the Item Type
--   itemkey  - Unique key formulated in Start_WF_Process for WF internal reference
--   actid    - The ID number of the activity from which this procedure is called.
--   funcmode -  The execution mode of the activity
-- OUT
--   resultout - The expected result thats returned when the procedure comletes.
-- USED BY
--   Oracle CMRO Apporval
--
-- HISTORY
--   04/23/2003  Senthil Kumar  created
--------------------------------------------------------------------------

PROCEDURE Set_Activity_Details(
	 itemtype    IN       VARCHAR2
	,itemkey     IN       VARCHAR2
	,actid       IN       NUMBER
	,funcmode    IN       VARCHAR2
        ,resultout   OUT NOCOPY      VARCHAR2);


PROCEDURE Ntf_Forward_FYI(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
);


PROCEDURE Ntf_Approved_FYI(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
);

--------------------------------------------------------------------------
-- PROCEDURE
--   Ntf_Final_Approval_FYI
--
-- PURPOSE
--   Generate the FYI Document for display in messages, either text or html
--
-- IN
--   document_id   - Item Key
--   display_type  - either 'text/plain' or 'text/html'
--   document      - document buffer
--   document_type - type of document buffer created, either 'text/plain'
--                   or 'text/html'
-- OUT
--
-- USED BY
--   Oracle CMRO Apporval
--
-- HISTORY
--   04/23/2003  Senthil Kumar  created
--------------------------------------------------------------------------
PROCEDURE Ntf_Final_Approval_FYI(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
);

--------------------------------------------------------------------------
-- PROCEDURE
--   Ntf_Rejected_FYI
--
-- PURPOSE
--   Generate the FYI Document for display in messages, either text or html
--
-- IN
--   document_id   - Item Key
--   display_type  - either 'text/plain' or 'text/html'
--   document      - document buffer
--   document_type - type of document buffer created, either 'text/plain'
--                   or 'text/html'
-- OUT
--
-- USED BY
--   Oracle CMRO Apporval
--
-- HISTORY
--   04/23/2003  Senthil Kumar  created
--------------------------------------------------------------------------
PROCEDURE Ntf_Rejected_FYI(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
);


--------------------------------------------------------------------------
-- PROCEDURE
--   Ntf_Approval
--
-- PURPOSE
--   Generate the Document to ask for approval, either text or html
--
-- IN
--   document_id   - Item Key
--   display_type  - either 'text/plain' or 'text/html'
--   document      - document buffer
--   document_type - type of document buffer created, either 'text/plain'
--                   or 'text/html'
-- OUT
--
-- USED BY
--   Oracle CMRO Apporval
--
-- HISTORY
--   04/23/2003  Senthil Kumar  created
--------------------------------------------------------------------------
PROCEDURE Ntf_Approval(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
);

--------------------------------------------------------------------------
-- PROCEDURE
--   Ntf_Approval_Reminder
--
-- PURPOSE
--   Generate the Reminder Document for display in messages, either text or html
--
-- IN
--   document_id   - Item Key
--   display_type  - either 'text/plain' or 'text/html'
--   document      - document buffer
--   document_type - type of document buffer created, either 'text/plain'
--                   or 'text/html'
-- OUT
--
-- USED BY
--   Oracle CMRO Apporval
--
-- HISTORY
--   04/23/2003  Senthil Kumar  created
--------------------------------------------------------------------------
PROCEDURE Ntf_Approval_Reminder(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
);


--------------------------------------------------------------------------
-- PROCEDURE
--   Ntf_Error_Act
--
-- PURPOSE
--   Generate the Document to request action to handle error, either text or html
--
-- IN
--   document_id   - Item Key
--   display_type  - either 'text/plain' or 'text/html'
--   document      - document buffer
--   document_type - type of document buffer created, either 'text/plain'
--                   or 'text/html'
-- OUT
--
-- USED BY
--   Oracle CMRO Apporval
--
-- HISTORY
--   04/23/2003  Senthil Kumar  created
--------------------------------------------------------------------------
PROCEDURE Ntf_Error_Act(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--  Update_Status
--
-- PURPOSE
--   This Procedure will update the status
--
-- IN
--
-- OUT
--
-- USED BY
--   Oracle CMRO Apporval
--
-- HISTORY
--   04/23/2003  Senthil Kumar  created
--------------------------------------------------------------------------
PROCEDURE Update_Status(
   itemtype    IN       VARCHAR2
  ,itemkey     IN       VARCHAR2
  ,actid       IN       NUMBER
  ,funcmode    IN       VARCHAR2
  ,resultout   OUT NOCOPY      VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--  Revert_Status
--
-- PURPOSE
--   This Procedure will revert the status in the case of an error
--
-- IN
--
-- OUT
--
-- USED BY
--   Oracle CMRO Apporval
--
-- HISTORY
--   04/23/2003  Senthil Kumar  created
--------------------------------------------------------------------------
PROCEDURE Revert_Status(
   itemtype    IN       VARCHAR2
  ,itemkey     IN       VARCHAR2
  ,actid       IN       NUMBER
  ,funcmode    IN       VARCHAR2
  ,resultout   OUT NOCOPY      VARCHAR2
);

END AHL_ITEMGROUPS_APPROVAL_PVT;

 

/
