--------------------------------------------------------
--  DDL for Package OZF_CLAIM_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CLAIM_APPROVAL_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvcaws.pls 115.1 2003/11/11 03:12:07 mchang noship $ */
--------------------------------------------------------------------------
-- PROCEDURE
--   notify_requestor_fyi
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
--   Oracle MArketing Generic Apporval
--
-- HISTORY
--   04/25/2001  Prashanth Nerella     CREATION
--   05/29/2001  MICHELLE CHANG        MODIFIED
--------------------------------------------------------------------------
PROCEDURE notify_requestor_fyi(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
);

--------------------------------------------------------------------------
-- PROCEDURE
--   notify_approval_required
--
-- PURPOSE
--   Generate the Rejection Document for display in messages, either text or html
--
-- IN
--   document_id  - Item Key
--   display_type - either 'text/plain' or 'text/html'
--   document     - document buffer
--   document_type   - type of document buffer created, either 'text/plain'
--                     or 'text/html'
--
-- OUT
--
-- USED BY
--   Oracle MArketing Generic Apporval
--
-- HISTORY
--   04/25/2001   Prashanth Nerella   CREATION
--   05/29/2001   MICHELLE CHANG      MODIFIED
-------------------------------------------------------------------------------
PROCEDURE notify_approval_required(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
);


--------------------------------------------------------------------------
-- PROCEDURE
--   notify_appr_req_reminder
--
-- PURPOSE
--   Generate the Rejection Document for display in messages, either text or html
--
-- IN
--   document_id  - Item Key
--   display_type - either 'text/plain' or 'text/html'
--   document     - document buffer
--   document_type   - type of document buffer created, either 'text/plain'
--                     or 'text/html'
-- OUT
--
-- USED BY
--   Oracle MArketing Generic Apporval
--
-- HISTORY
--   04/25/2001   Prashanth Nerella    CREATION
--   05/29/2001   Michelle Chang       MODIFIED
-------------------------------------------------------------------------------
PROCEDURE notify_appr_req_reminder(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
);


--------------------------------------------------------------------------
-- PROCEDURE
--   Notify_requestor_of Approval
--
-- PURPOSE
--   Generate the Approval Document for display in messages, either text or html
--
-- IN
--   document_id  - Item Key
--   display_type - either 'text/plain' or 'text/html'
--   document     - document buffer
--   document_type   - type of document buffer created, either 'text/plain'
--                     or 'text/html'
-- OUT
--
-- USED BY
--   Oracle MArketing Generic Apporval
--
-- HISTORY
--   04/25/2001   Prashanth Nerella   CREATION
--   05/30/2001   MICHELLE CHANG      MODIFIED
----------------------------------------------------------------------------
PROCEDURE notify_requestor_of_approval(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
);


--------------------------------------------------------------------------
-- PROCEDURE
--   Notify_requestor_of rejection
--
-- PURPOSE
--   Generate the Rejection Document for display in messages, either text or html
--
-- IN
--   document_id  - Item Key
--   display_type - either 'text/plain' or 'text/html'
--   document     - document buffer
--   document_type   - type of document buffer created, either 'text/plain'
--                     or 'text/html'
-- OUT
--
-- USED BY
--   Oracle MArketing Generic Apporval
--
-- HISTORY
--   04/25/2001    Prashanth Nerella      CREATION
--   05/30/2001    MICHELLE CHANG         MODIFIED
-------------------------------------------------------------------------------
PROCEDURE notify_requestor_of_rejection(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--   Set_claim_Activity_details
--
-- PURPOSE
--   This Procedure will set all the item attribute details
--
-- IN
--
-- OUT
--
-- Used By Activities
--
-- NOTES
--
-- HISTORY
--   04/25/2001     Prashanth Nerella      CREATION
--   05/30/2001     MICHELLE CHANG         MODIFIED
-------------------------------------------------------------------------------
PROCEDURE set_claim_activity_details(
   itemtype    IN       VARCHAR2
  ,itemkey     IN       VARCHAR2
  ,actid       IN       NUMBER
  ,funcmode    IN       VARCHAR2
  ,resultout   OUT NOCOPY      VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--  Update_Claim_Statas
--
-- PURPOSE
--   This Procedure will update the status
--
-- IN
--
-- OUT
--
-- Used By Activities
--
-- NOTES
--
-- HISTORY
--   04/25/2001    Prashanth Nerella       CREATION
--   05/30/2001    MICHELLE CHANG          MODIFIED
-------------------------------------------------------------------------------
PROCEDURE update_claim_status(
   itemtype    IN       VARCHAR2
  ,itemkey     IN       VARCHAR2
  ,actid       IN       NUMBER
  ,funcmode    IN       VARCHAR2
  ,resultout   OUT NOCOPY      VARCHAR2
);


END OZF_Claim_Approval_Pvt;

 

/
