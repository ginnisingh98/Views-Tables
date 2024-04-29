--------------------------------------------------------
--  DDL for Package OZF_PRICELIST_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_PRICELIST_APPROVAL_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvplws.pls 120.0 2005/06/01 03:35:12 appldev noship $ */
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
--   08/20/2001  julou  created
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
--   08/20/2001  julou  created
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
--   08/20/2001  julou  created
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
--   08/20/2001  julou  created
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
--   08/20/2001  julou  created
-------------------------------------------------------------------------------
PROCEDURE notify_requestor_of_rejection(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--   Set_PriceList_Activity_details
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
--   08/20/2001  julou  created
-------------------------------------------------------------------------------
PROCEDURE Set_PriceList_Activity_details(
   itemtype    IN       VARCHAR2
  ,itemkey     IN       VARCHAR2
  ,actid       IN       NUMBER
  ,funcmode    IN       VARCHAR2
  ,resultout   OUT NOCOPY      VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--  Update_PriceList_Status
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
--   08/20/2001  julou  created
-------------------------------------------------------------------------------
PROCEDURE Update_PriceList_Status(
   itemtype    IN       VARCHAR2
  ,itemkey     IN       VARCHAR2
  ,actid       IN       NUMBER
  ,funcmode    IN       VARCHAR2
  ,resultout   OUT NOCOPY      VARCHAR2
);


END OZF_PriceList_Approval_PVT;

 

/
