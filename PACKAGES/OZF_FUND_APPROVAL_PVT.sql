--------------------------------------------------------
--  DDL for Package OZF_FUND_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_FUND_APPROVAL_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvfaps.pls 120.0 2005/06/01 00:00:13 appldev noship $ */

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
   --                      - Oracle MArketing Generic Apporval
   -- HISTORY
   --   03/15/2001        MUMU PANDE        CREATION
   -----------------------------------------------------------------
   PROCEDURE notify_requestor_fyi(
      document_id     IN		VARCHAR2
     ,display_type    IN		VARCHAR2
     ,document        IN OUT NOCOPY	VARCHAR2
     ,document_type   IN OUT NOCOPY	VARCHAR2);

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
   --                      - Oracle MArketing Generic Apporval
   -- HISTORY
   --   03/15/2001        MUMU PANDE        CREATION
   ----------------------------------------------------------------------------

   PROCEDURE notify_requestor_of_approval(
      document_id     IN		VARCHAR2
     ,display_type    IN		VARCHAR2
     ,document        IN OUT NOCOPY	VARCHAR2
     ,document_type   IN OUT NOCOPY	VARCHAR2);

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
   --                      - Oracle MArketing Generic Apporval
   -- HISTORY
   --   03/15/2001        MUMU PANDE        CREATION
   -------------------------------------------------------------------------------

   PROCEDURE notify_requestor_of_rejection(
      document_id     IN		VARCHAR2
     ,display_type    IN		VARCHAR2
     ,document        IN OUT NOCOPY	VARCHAR2
     ,document_type   IN OUT NOCOPY	VARCHAR2);

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
   --                      - Oracle MArketing Generic Apporval
   -- HISTORY
   --   03/15/2001        MUMU PANDE        CREATION


   PROCEDURE notify_approval_required(
      document_id     IN		VARCHAR2
     ,display_type    IN		VARCHAR2
     ,document        IN OUT NOCOPY	VARCHAR2
     ,document_type   IN OUT NOCOPY	VARCHAR2);

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
   --                      - Oracle MArketing Generic Apporval
   -- HISTORY
   --   03/15/2001        MUMU PANDE        CREATION


   PROCEDURE notify_appr_req_reminder(
      document_id     IN		VARCHAR2
     ,display_type    IN		VARCHAR2
     ,document        IN OUT NOCOPY	VARCHAR2
     ,document_type   IN OUT NOCOPY	VARCHAR2);

   ---------------------------------------------------------------------
   -- PROCEDURE
   --   Set_ParBudget_Activity_details
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
   --   02/20/2001        MUMU PANDE        CREATION
   -- End of Comments
   --------------------------------------------------------------------
   PROCEDURE set_parbudget_activity_details(
      itemtype    IN		VARCHAR2
     ,itemkey     IN		VARCHAR2
     ,actid       IN		NUMBER
     ,funcmode    IN		VARCHAR2
     ,resultout   OUT NOCOPY    VARCHAR2);

   ---------------------------------------------------------------------
   -- PROCEDURE
   --  Update_ParBudget_Statas
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
   --   02/20/2001        MUMU PANDE        CREATION
   -- End of Comments
   --------------------------------------------------------------------


   PROCEDURE update_parbudget_status(
      itemtype    IN		VARCHAR2
     ,itemkey     IN		VARCHAR2
     ,actid       IN		NUMBER
     ,funcmode    IN		VARCHAR2
     ,resultout   OUT NOCOPY    VARCHAR2);

   ---------------------------------------------------------------------
   -- PROCEDURE
   --  revert_ParBudget_Statas
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
   --   02/20/2001        MUMU PANDE        CREATION
   -- End of Comments
   --------------------------------------------------------------------
   /*
   PROCEDURE revert_parbudget_status(
      itemtype    IN       VARCHAR2
     ,itemkey     IN       VARCHAR2
     ,actid       IN       NUMBER
     ,funcmode    IN       VARCHAR2
     ,resultout   OUT      VARCHAR2);
   */
   ---------------------------------------------------------------------
   -- PROCEDURE
   --  get_parent_fund_owner
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
   --   02/20/2001        MUMU PANDE        CREATION
   -- End of Comments
   --------------------------------------------------------------------

   PROCEDURE get_fund_parent_owner(
      itemtype          IN		VARCHAR2
     ,itemkey           IN		VARCHAR2
     ,x_approver_id     OUT NOCOPY	NUMBER
     ,x_return_status   OUT NOCOPY	VARCHAR2);
END ozf_fund_approval_pvt;

 

/
