--------------------------------------------------------
--  DDL for Package OZF_FUND_REQUEST_APR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_FUND_REQUEST_APR_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvwfrs.pls 115.4 2003/06/26 05:27:32 mchang ship $ */

   -------------------------------------------------------------------------------------
   --  Start of Comments
   --
   -- NAME
   --   OZF_WF_Request_Apr_PVT
   --
   -- PURPOSE
   --   This package contains the workflow procedures for
   --   Fund Request Approvals in Oracle Marketing(Funds and Budgets)
   --
   -- HISTORY
   --   03/28/2001        MUMU PANDE        CREATION
   -----------------------------------------------------------------------------------------


   ---------------------------------------------------------------------
   -- PROCEDURE
   --   Create_Fund_Request
   --
   --
   -- PURPOSE
   --   This Procedure will create the fund request
   --
   --
   -- IN
   -- p_commit           IN  VARCHAR2 -- Transaction commit identifier
   -- p_timeout          IN  NUMBER   -- time out in DAYS specified for the workflow notifications
   -- p_update_status    IN  VARCHAR2 -- Fund status update flag
   -- p_approval_for     IN  VARCHAR2 -- Object triggering request
   -- p_approval_for_id    IN  NUMBER -- Object ID triggering request
   -- p_requester_id       IN  NUMBER -- User triggering request
   -- p_requested_amount   IN  NUMBER -- amount requested
   -- p_approval_fm        IN  VARCHAR2 -- Object towards which the request is directed
   -- p_approval_fm_id     IN  NUMBER -- Object ID which the request is directed
   -- p_workflowprocess    IN  VARCHAR2 -- Main process in the workflow
   -- p_item_type          IN  VARCHAR2 -- Item type in the workflow
   ----------------------------------------- these 2 parameter added by mpande ---------------------------------
   --p_transfer_type    IN VARCHAR2   -- indicates wether the transfer is release or transfer.Transfer is from 1 fund to another while release is from holdback_amt to
   -- available amount of the same fund
   -- p_description     IN VARCHAR2 --- indicates note associated with the transfer
   --  mpande 10/18/2001 added
   -- p_allocation_flag      IN       VARCHAR2 := 'N'  -- flag to indicate whether it is an allocation or not
   -- Used By Activities
   --
   -- NOTES
   -- IF x_is_requester_owner is set to 'YES', then this API calls Approve_Request to update the fund
   -- transfer transactions.
   -- If x_is_requester_owner then the calling API can trigger the workflow API : Start_Request_Process
   --
   -- HISTORY
   --   02/16/2000        SHITIJ VATSA        CREATION
   --   04/16/2000        MPANDE              UPDATED
   --    10/22/2001       mpande              UPDATED
   -- End of Comments

   PROCEDURE create_fund_request(
      p_commit               IN       VARCHAR2 := fnd_api.g_false
     ,p_update_status        IN       VARCHAR2 := 'Y'
     ,p_approval_for         IN       VARCHAR2 := 'FUND'
     ,p_approval_for_id      IN       NUMBER
     ,p_requester_id         IN       NUMBER
     ,p_requested_amount     IN       NUMBER
     ,p_approval_fm          IN       VARCHAR2 := 'FUND'
     ,p_approval_fm_id       IN       NUMBER DEFAULT NULL
     /* yzhao 07/17/2002 fix bug 2410322 - UPG1157:9I:OZF PACKAGE/PACKAGE BODY MISMATCHES
     ,p_transfer_type        IN       VARCHAR2 := 'TRANSFER'   --- 'REQUEST' OR 'TRANSFER'
      */
     ,p_transfer_type        IN       VARCHAR2 := 'REQUEST'   --- 'REQUEST' OR 'TRANSFER'
     ,p_child_flag           IN       VARCHAR2 := 'N'  -- flag to indicate whether it is a child fund creation
     ,p_act_budget_id        IN       NUMBER := NULL   -- request_id ( for a child fund it is null)
     ,p_init_msg_list        IN       VARCHAR2 := fnd_api.g_false
     ,p_justification        IN       VARCHAR2
      -- 10/22/2001   mpande    Changed code different owner allocation bug
     ,p_allocation_flag      IN       VARCHAR2 := 'N'  -- flag to indicate whether it is an allocation or not
     ,x_return_status        OUT NOCOPY      VARCHAR2
     ,x_msg_count            OUT NOCOPY      NUMBER
     ,x_msg_data             OUT NOCOPY      VARCHAR2
     ,x_request_id           OUT NOCOPY      NUMBER
     ,x_approver_id          OUT NOCOPY      NUMBER
     ,x_is_requester_owner   OUT NOCOPY      VARCHAR2   -- Use this variable to conditionally trigger the workflow if value ='NO'
                                              );

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
   --                      - Oracle MArketing Generic Apporval
   -- HISTORY
   --   03/15/2001        MUMU PANDE        CREATION
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
   --                      - Oracle MArketing Generic Apporval
   -- HISTORY
   --   03/15/2001        MUMU PANDE        CREATION
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
   --                      - Oracle MArketing Generic Apporval
   -- HISTORY
   --   03/15/2001        MUMU PANDE        CREATION


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
   --                      - Oracle MArketing Generic Apporval
   -- HISTORY
   --   03/15/2001        MUMU PANDE        CREATION


   PROCEDURE notify_appr_req_reminder(
      document_id     IN       VARCHAR2
     ,display_type    IN       VARCHAR2
     ,document        IN OUT NOCOPY   VARCHAR2
     ,document_type   IN OUT NOCOPY   VARCHAR2);

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
   PROCEDURE set_trans_activity_details(
      itemtype    IN       VARCHAR2
     ,itemkey     IN       VARCHAR2
     ,actid       IN       NUMBER
     ,funcmode    IN       VARCHAR2
     ,resultout   OUT NOCOPY      VARCHAR2);

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


   PROCEDURE update_budgettrans_status(
      itemtype    IN       VARCHAR2
     ,itemkey     IN       VARCHAR2
     ,actid       IN       NUMBER
     ,funcmode    IN       VARCHAR2
     ,resultout   OUT NOCOPY      VARCHAR2);
---------------------------------------------------------------------
-- PROCEDURE
--   Approve_Holback
--
--
-- PURPOSE
--   This Procedure will Update the fund where reserve is done to holdback from
--   available amount
--
-- IN
-- p_commit           IN  VARCHAR2 -- Transaction commit identifier
-- p_act_budget_id  IN  NUMBER -- Fund request identifier having the request details
-- p_transac_fund_id   IN  NUMBER -- transaction fund
-- p_requester_id     IN  NUMBER -- Person initiating the fund release --should always be the owner of the fund
-- p_requested_amount IN  NUMBER -- Requested amount
--
-- OUT
-- x_return_status    OUT VARCHAR2
-- x_msg_count        OUT NUMBER
-- x_msg_data         OUT VARCHAR2
--
-- Used By Activities
--
-- NOTES
--
--
--
-- HISTORY
--   04/06/2001        MPANDE        CREATION
--
-- End of Comments

PROCEDURE approve_holdback(
   p_commit             IN       VARCHAR2 := fnd_api.g_false
  ,p_act_budget_id      IN       NUMBER
  ,p_transfer_type      IN       VARCHAR2
  ,p_transac_fund_id    IN       NUMBER
  ,p_requester_id       IN       NUMBER
  ,p_approver_id        IN       NUMBER
  ,p_requested_amount   IN       NUMBER
  ,x_return_status      OUT NOCOPY      VARCHAR2
  ,x_msg_count          OUT NOCOPY      NUMBER
  ,x_msg_data           OUT NOCOPY      VARCHAR2);

END ozf_fund_request_apr_pvt;

 

/
