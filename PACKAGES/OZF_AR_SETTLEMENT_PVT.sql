--------------------------------------------------------
--  DDL for Package OZF_AR_SETTLEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_AR_SETTLEMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvcaps.pls 120.2 2006/02/06 04:26:46 sashetty ship $ */

PROCEDURE set_org_context(p_item_type   IN VARCHAR2,
			              p_item_key    IN VARCHAR2,
			              p_activity_id IN VARCHAR2,
	 		              p_command     IN VARCHAR2,
                          p_resultout   IN OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------------------
-- PROCEDURE
--   Start_Settlement
--
-- DESCRIPTION
--
-- IN
--   p_claim_id      - claim_id
--   p_prev_status   - previous_status
--   p_curr_status   - current_status
--   p_next_status   - next_status
--
---------------------------------------------------------------------------------
PROCEDURE Start_Settlement(
    p_claim_id              IN  NUMBER,
    p_prev_status           IN  VARCHAR2,
    p_curr_status           IN  VARCHAR2,
    p_next_status           IN  VARCHAR2,
    p_promotional_claim     IN  VARCHAR2 := 'N',
    p_process               IN  VARCHAR2 := 'OZF_CLAIM_GENERIC_SETTLEMENT'
);

--------------------------------------------------------------------------------
-- PROCEDURE
--   Set_Reminder
--
--   Workflow cover:
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:ERROR'
--             - 'COMPLETE:'
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE>               <ACTIVITY>
--   OZF_AR_SETTLEMENT_PVT    OZF_SET_REMINDER
--------------------------------------------------------------------------------
PROCEDURE Set_Reminder(
    itemtype       IN  VARCHAR2,
    itemkey        IN  VARCHAR2,
    actid          IN  NUMBER,
    funcmode       IN  VARCHAR2,
    resultout      OUT NOCOPY VARCHAR2
);

--------------------------------------------------------------------------------
-- PROCEDURE
--   Incomplete_Claim
--
--   Workflow cover:
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:ERROR'
--             - 'COMPLETE:'
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE>               <ACTIVITY>
--   OZF_AR_SETTLEMENT_PVT    OZF_INCOMPLETE_CLAIM
--------------------------------------------------------------------------------
PROCEDURE Incomplete_Claim(
    itemtype       IN  VARCHAR2,
    itemkey        IN  VARCHAR2,
    actid          IN  NUMBER,
    funcmode       IN  VARCHAR2,
    resultout      OUT NOCOPY VARCHAR2
);

--------------------------------------------------------------------------------
-- PROCEDURE
--   Prepare_Instructions
--
--   Workflow cover:
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:ERROR'
--             - 'COMPLETE:'
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE>               <ACTIVITY>
--   OZF_AR_SETTLEMENT_PVT    OZF_RECEIVABLE_INSTRUCTION
---------------------------------------------------------------------------------
PROCEDURE Prepare_Instructions(
    itemtype    IN  VARCHAR2,
    itemkey     IN  VARCHAR2,
    actid       IN  NUMBER,
    funcmode    IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
);

--------------------------------------------------------------------------------
-- PROCEDURE
--   Update_Docs
--
--   Workflow cover:
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:ERROR'
--             - 'COMPLETE:'
--
-- USED BY ACTIVITIES
--   <ITEM_TYPE>              <ACTIVITY>
--   OZF_AR_SETTLEMENT_PVT    OZF_UPDATE_DOCS
---------------------------------------------------------------------------------
PROCEDURE Update_Docs(
    itemtype    IN  VARCHAR2,
    itemkey     IN  VARCHAR2,
    actid       IN  NUMBER,
    funcmode    IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
);

--------------------------------------------------------------------------------
-- PROCEDURE
--   Close_Claim
--
--   Workflow cover:
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:ERROR'
--             - 'COMPLETE:'
--
-- USED BY ACTIVITIES
--   <ITEM_TYPE>              <ACTIVITY>
--   OZF_AR_SETTLEMENT_PVT    OZF_CLOSE_CLAIM
---------------------------------------------------------------------------------
PROCEDURE Close_Claim(
    itemtype    IN  VARCHAR2,
    itemkey     IN  VARCHAR2,
    actid       IN  NUMBER,
    funcmode    IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
);

------------------------------------------------------------------------------
-- PROCEDURE
--   Reset_Status
--
--   Workflow cover:
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:'
--
-- USED BY ACTIVITIES
--   <ITEM_TYPE>              <ACTIVITY>
--   OZF_AR_SETTLEMENT_PVT    OZF_RESET_STATUS
---------------------------------------------------------------------------------
PROCEDURE Reset_Status(
    itemtype    IN  VARCHAR2,
    itemkey     IN  VARCHAR2,
    actid       IN  NUMBER,
    funcmode    IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
);

------------------------------------------------------------------------------
-- PROCEDURE
--   Check_Promo_Claim
--
--   Workflow cover:
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:Y'
--             - 'COMPLETE:N'
--
-- USED BY ACTIVITIES
--   <ITEM_TYPE>              <ACTIVITY>
--   OZF_AR_SETTLEMENT_PVT    OZF_CHECK_PROMO_CLAIM
---------------------------------------------------------------------------------
PROCEDURE Check_Promo_Claim(
    itemtype    IN  VARCHAR2,
    itemkey     IN  VARCHAR2,
    actid       IN  NUMBER,
    funcmode    IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
);
------------------------------------------------------------------------------
-- PROCEDURE
--   Create_GL_Entries
--
--   Workflow cover:
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:SUCCESS'
--             - 'COMPLETE:ERROR'
--
-- USED BY ACTIVITIES
--   <ITEM_TYPE>              <ACTIVITY>
--   OZF_AR_SETTLEMENT_PVT    OZF_CREATE_GL_ENTRIES
---------------------------------------------------------------------------------
PROCEDURE Create_GL_Entries(
    itemtype    IN  VARCHAR2,
    itemkey     IN  VARCHAR2,
    actid       IN  NUMBER,
    funcmode    IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
);
------------------------------------------------------------------------------
-- PROCEDURE
--   Revert_GL_Entries
--
--   Workflow cover:
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:SUCCESS'
--             - 'COMPLETE:ERROR'
--
---------------------------------------------------------------------------------
PROCEDURE Revert_GL_Entries(
    itemtype    IN  VARCHAR2,
    itemkey     IN  VARCHAR2,
    actid       IN  NUMBER,
    funcmode    IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
);

------------------------------------------------------------------------------
-- PROCEDURE
--   Create_Payment
--
--   Workflow cover:
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:SUCCESS'
--             - 'COMPLETE:ERROR'
--
-- USED BY ACTIVITIES
--   <ITEM_TYPE>              <ACTIVITY>
--   OZF_AR_SETTLEMENT_PVT    OZF_CREATE_PAYMENT
---------------------------------------------------------------------------------
PROCEDURE Create_Payment(
    itemtype    IN  VARCHAR2,
    itemkey     IN  VARCHAR2,
    actid       IN  NUMBER,
    funcmode    IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
);
------------------------------------------------------------------------------
-- PROCEDURE
--   Check_Claim_Class
--
--   Workflow cover:
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:CLAIM'
--             - 'COMPLETE:DEDUCTION'
--
-- USED BY ACTIVITIES
--   <ITEM_TYPE>              <ACTIVITY>
--   OZF_AR_SETTLEMENT_PVT    CHECK_CLAIM_CLASS
---------------------------------------------------------------------------------
PROCEDURE Check_Claim_Class(
    itemtype    IN  VARCHAR2,
    itemkey     IN  VARCHAR2,
    actid       IN  NUMBER,
    funcmode    IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
);

PROCEDURE Handle_Error(
    p_itemtype        IN  VARCHAR2,
    p_itemkey         IN  VARCHAR2,
    p_msg_count       IN  NUMBER,
    p_msg_data        IN  VARCHAR2,
    p_process_name    IN  VARCHAR2,
    x_error_msg       OUT NOCOPY VARCHAR2
);

PROCEDURE Check_Payment_Method(
    itemtype    IN  VARCHAR2,
    itemkey     IN  VARCHAR2,
    actid       IN  NUMBER,
    funcmode    IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
);

PROCEDURE Prepare_Docs(
    itemtype       IN  VARCHAR2,
    itemkey        IN  VARCHAR2,
    actid          IN  NUMBER,
    funcmode       IN  VARCHAR2,
    resultout      OUT NOCOPY VARCHAR2
);

PROCEDURE Check_Auto_Setl_Process(
    itemtype    IN  VARCHAR2,
    itemkey     IN  VARCHAR2,
    actid       IN  NUMBER,
    funcmode    IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
);

PROCEDURE Create_Settle_Doc(
    itemtype       IN  VARCHAR2,
    itemkey        IN  VARCHAR2,
    actid          IN  NUMBER,
    funcmode       IN  VARCHAR2,
    resultout      OUT NOCOPY VARCHAR2
);

END OZF_AR_SETTLEMENT_PVT;

 

/
