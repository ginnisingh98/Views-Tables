--------------------------------------------------------
--  DDL for Package AMW_AP_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_AP_APPROVAL_PVT" AUTHID CURRENT_USER AS
/* $Header: amwvaaps.pls 115.2 2003/06/26 06:06:51 npanandi noship $ */

   -- PROCEDURE
   --   Notify_requestor_FYI
   --
   -- PURPOSE
   --   Generate the Requisition Document for display in messages, either
   --   text or html
   -- IN
   --   document_id  - Item Key
   --   display_type - either 'text/plain' or 'text/html'
   --   document     - document buffer
   --   document_type   - type of document buffer created, either 'text/plain'
   --         or 'text/html'
   -- OUT
   -- USED BY
   --                      - Oracle Internal Controls Generic Apporval
   -- HISTORY
   --   6/4/2003        MUMU PANDE        CREATION
   -----------------------------------------------------------------
   PROCEDURE notify_requestor_fyi(
      document_id     IN       VARCHAR2
     ,display_type    IN       VARCHAR2
     ,document        IN OUT NOCOPY   VARCHAR2
     ,document_type   IN OUT NOCOPY   VARCHAR2);

   --------------------------------------------------------------------------
   -- PROCEDURE
   --   Notify_requestor_of Approval
   --
   -- PURPOSE
   --   Generate the Approval Document for display in messages, either
   --   text or html
   -- IN
   --   document_id  - Item Key
   --   display_type - either 'text/plain' or 'text/html'
   --   document     - document buffer
   --   document_type   - type of document buffer created, either 'text/plain'
   --         or 'text/html'
   -- OUT
   -- USED BY
   --                      - Oracle Internal Controls Generic Apporval
   -- HISTORY
   --   6/4/2003        MUMU PANDE        CREATION
   ----------------------------------------------------------------------------

   PROCEDURE notify_requestor_of_approval(
      document_id     IN       VARCHAR2
     ,display_type    IN       VARCHAR2
     ,document        IN OUT NOCOPY   VARCHAR2
     ,document_type   IN OUT NOCOPY   VARCHAR2);

   --------------------------------------------------------------------------
   -- PROCEDURE
   --   Notify_requestor_of rejection
   --
   -- PURPOSE
   --   Generate the Rejection Document for display in messages, either
   --   text or html
   -- IN
   --   document_id  - Item Key
   --   display_type - either 'text/plain' or 'text/html'
   --   document     - document buffer
   --   document_type   - type of document buffer created, either 'text/plain'
   --         or 'text/html'
   -- OUT
   -- USED BY
   --                      - Oracle Internal Controls Generic Apporval
   -- HISTORY
   --   6/4/2003        MUMU PANDE        CREATION
   -------------------------------------------------------------------------------

   PROCEDURE notify_requestor_of_rejection(
      document_id     IN       VARCHAR2
     ,display_type    IN       VARCHAR2
     ,document        IN OUT NOCOPY   VARCHAR2
     ,document_type   IN OUT NOCOPY   VARCHAR2);

   --------------------------------------------------------------------------
   -- PROCEDURE
   --   Notify_requestor_of rejection
   --
   -- PURPOSE
   --   Generate the Rejection Document for display in messages, either
   --   text or html
   -- IN
   --   document_id  - Item Key
   --   display_type - either 'text/plain' or 'text/html'
   --   document     - document buffer
   --   document_type   - type of document buffer created, either 'text/plain'
   --         or 'text/html'
   -- OUT
   -- USED BY
   --                      - Oracle Internal Controls Generic Apporval
   -- HISTORY
   --   6/4/2003        MUMU PANDE        CREATION


   PROCEDURE notify_approval_required(
      document_id     IN       VARCHAR2
     ,display_type    IN       VARCHAR2
     ,document        IN OUT NOCOPY   VARCHAR2
     ,document_type   IN OUT NOCOPY   VARCHAR2);

   --------------------------------------------------------------------------
   -- PROCEDURE
   --   notify_appr_req_reminder
   --
   -- PURPOSE
   --   Generate the Rejection Document for display in messages, either
   --   text or html
   -- IN
   --   document_id  - Item Key
   --   display_type - either 'text/plain' or 'text/html'
   --   document     - document buffer
   --   document_type   - type of document buffer created, either 'text/plain'
   --         or 'text/html'
   -- OUT
   -- USED BY
   --                      - Oracle Internal Controls Generic Apporval
   -- HISTORY
   --   6/4/2003        MUMU PANDE        CREATION


   PROCEDURE notify_appr_req_reminder(
      document_id     IN       VARCHAR2
     ,display_type    IN       VARCHAR2
     ,document        IN OUT NOCOPY   VARCHAR2
     ,document_type   IN OUT NOCOPY   VARCHAR2);

   ---------------------------------------------------------------------
   -- PROCEDURE
   --   Set_ap_object_details
   --
   --
   -- PURPOSE
   --   This Procedure will set all the item attribute details
   --
   --
   -- IN
   --
   --
   -- OUT
   --
   -- Used By Activities
   --
   -- NOTES
   --
   --
   --
   -- HISTORY
   --   6/4/2003        MUMU PANDE        CREATION
   -- End of Comments
   --------------------------------------------------------------------
   PROCEDURE set_ap_object_details(
      itemtype    IN       VARCHAR2
     ,itemkey     IN       VARCHAR2
     ,actid       IN       NUMBER
     ,funcmode    IN       VARCHAR2
     ,resultout   OUT NOCOPY      VARCHAR2);

   ---------------------------------------------------------------------
   -- PROCEDURE
   --  Update_ap_Status
   --
   --
   -- PURPOSE
   --   This Procedure will update the status
   --
   --
   -- IN
   --
   --
   -- OUT
   --
   -- Used By Activities
   --
   -- NOTES
   --
   --
   --
   -- HISTORY
   --  6/4/2003        MUMU PANDE        CREATION
   -- End of Comments
   --------------------------------------------------------------------


   PROCEDURE update_ap_status(
      itemtype    IN       VARCHAR2
     ,itemkey     IN       VARCHAR2
     ,actid       IN       NUMBER
     ,funcmode    IN       VARCHAR2
     ,resultout   OUT NOCOPY      VARCHAR2);

END amw_ap_approval_pvt;

 

/
