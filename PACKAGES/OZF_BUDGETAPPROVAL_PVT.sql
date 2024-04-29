--------------------------------------------------------
--  DDL for Package OZF_BUDGETAPPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_BUDGETAPPROVAL_PVT" AUTHID CURRENT_USER as
/*$Header: ozfvbdas.pls 120.0.12010000.2 2009/08/06 10:11:43 nirprasa ship $*/

-- Start of Comments
--
-- NAME
--   OZF_BudgetApproval_PVT
--
-- PURPOSE
--    This package is a Private API for interfacing with Workflow
--    budget approval.
--
--   Procedures:
--     WF_Respond
--     Close_ActBudget
--
-- NOTES
--
-- History
-- 12-Sep-2000 choang   Created.
-- 01/12/2001  mpande   UPDATED for Note
-- 10/28/2002  feliu   Change for 11.5.9
-- 10/28/2002  feliu    added budget_request_approval for non_approval budget request.
-- 22-Aug-2003 kdass	added validate_object_budget_all for 11.5.10 Offer Budget Validation.
-- 06-Aug-2009 nirprasa.
-- End of Comments

-- global constants


-------------------------------------------------------------------
-- NAME
--    WF_Respond
-- PURPOSE
--    Called by the money owner to approve the
--    requested budget amount.  The API is called
--    from Workflow.
PROCEDURE WF_Respond (
   p_api_version        IN     NUMBER,
   p_init_msg_list      IN     VARCHAR2 := FND_API.G_FALSE,
   p_commit             IN     VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN     NUMBER := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY    VARCHAR2,
   x_msg_count          OUT NOCOPY    NUMBER,
   x_msg_data           OUT NOCOPY    VARCHAR2,

   p_respond_status_id  IN     VARCHAR2,
   p_activity_budget_id IN     NUMBER,
   p_approver_id        IN     NUMBER := NULL,
   p_approved_amount    IN     NUMBER := NULL,
   p_approved_currency  IN     VARCHAR2 := NULL,
   -- 11/12/2001 mpande added the following
   p_comment               IN     VARCHAR2 := NULL

);


-------------------------------------------------------------------
-- NAME
--    Close_ActBudget
-- PURPOSE
--    Close the books for the budget source line.
PROCEDURE Close_ActBudget (
   p_api_version        IN     NUMBER,
   p_init_msg_list      IN     VARCHAR2 := FND_API.G_FALSE,
   p_commit             IN     VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN     NUMBER := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY    VARCHAR2,
   x_msg_count          OUT NOCOPY    NUMBER,
   x_msg_data           OUT NOCOPY    VARCHAR2,

   p_activity_budget_id IN     NUMBER
);

-------------------------------------------------------------------
-- NAME
--    notify vendor
-- PURPOSE
--    notify the vendor wheneever a partner creates a budget line
-- History
-- Created Mpande  01/03/2002
----------------------------------------------------------------
PROCEDURE notify_vendor (
   p_act_budget_rec IN OZF_ACTBUDGETS_PVT.Act_Budgets_Rec_Type,
   x_return_status      OUT NOCOPY    VARCHAR2,
   x_msg_count          OUT NOCOPY    NUMBER,
   x_msg_data           OUT NOCOPY    VARCHAR2);


-------------------------------------------------------------------
-- NAME
--   given a customer and product, check if a budget is qualified
-- PURPOSE
--
-- History
--    Created   yzhao   02/06/2004
----------------------------------------------------------------
PROCEDURE check_budget_qualification(
      p_budget_id          IN NUMBER
    , p_cust_account_id    IN NUMBER := NULL
    , p_product_item_id    IN NUMBER := NULL
    , x_qualify_flag       OUT NOCOPY BOOLEAN
    , x_return_status      OUT NOCOPY    VARCHAR2
    , x_msg_count          OUT NOCOPY    NUMBER
    , x_msg_data           OUT NOCOPY    VARCHAR2
);


-------------------------------------------------------------------
-- NAME
--    validate_object_budget
-- PURPOSE
--    this API will be called by the Workflow API for each budget line to
--    validate whether a budget is qualified to fund an offer in terms of
--    market and product eligibility
-- History
--    Created   yzhao   01/22/2002
--    Modified	kdass	22-Aug-2003  modified for 11.5.10 Offer Budget Validation
----------------------------------------------------------------
PROCEDURE validate_object_budget (
   p_object_id          IN     NUMBER,
   p_object_type        IN     VARCHAR2,
   p_actbudget_id       IN     NUMBER,
   x_return_status      OUT NOCOPY    VARCHAR2,
   x_msg_count          OUT NOCOPY    NUMBER,
   x_msg_data           OUT NOCOPY    VARCHAR2);

-----------------------------------------------------------------
-- NAME
--    validate_object_budget_all
-- PURPOSE
--    this API will be called by the Workflow API after all the budget line
--    approvals are done. it will validate the offer's market and product
--    eligibility in terms of all budget lines
-- History
--    Created   kdass   22-Aug-2003	11.5.10 Offer Budget Validation
----------------------------------------------------------------
PROCEDURE validate_object_budget_all (
   p_object_id          IN     NUMBER,
   p_object_type        IN     VARCHAR2,
   x_return_status      OUT NOCOPY    VARCHAR2,
   x_msg_count          OUT NOCOPY    NUMBER,
   x_msg_data           OUT NOCOPY    VARCHAR2);

-------------------------------------------------------------------
-- NAME
--    concurrent program for budget-object eligibility validation
-- PURPOSE
--    Validate whether a budget is qualified to fund an object(offer only for now)
--       in terms of market and product eligibility
--       if validation succeeds, budget request is set to APPROVED
--       otherwise, budget request is reverted to NEW.
--       if it is called for offer activation, offer status is updated based on validation result
--    This process is kicked off when object's budget approval is not required
--       but budget-object validation is needed
-- History
--    Created   yzhao   07/11/2002
----------------------------------------------------------------
PROCEDURE conc_validate_offer_budget (
   x_errbuf               OUT NOCOPY    VARCHAR2,
   x_retcode              OUT NOCOPY    NUMBER,
   p_object_id          IN     NUMBER,
   p_object_type        IN     VARCHAR2,
   p_actbudget_id       IN     NUMBER DEFAULT NULL
);

-------------------------------------------------------------------
-- NAME
--    budget_request_approval
-- PURPOSE
--    called by each activity update api to approval budget request
--    when budget request approval is not required.
-- History
--    Created   feliu   07/11/2002
----------------------------------------------------------------

PROCEDURE budget_request_approval(
   p_init_msg_list         IN   VARCHAR2,
   p_api_version           IN   NUMBER,
   p_commit                IN   VARCHAR2,
   x_return_status         OUT NOCOPY  VARCHAR2,
   x_msg_count             OUT NOCOPY  NUMBER,
   x_msg_data              OUT NOCOPY  VARCHAR2,
   p_object_type           IN  VARCHAR2,
   p_object_id             NUMBER,
   x_status_code           OUT NOCOPY  VARCHAR2
   );

-------------------------------------------------------------------
-- NAME
--    budget_request_approval
-- PURPOSE
--    called by each activity update api to approval budget request
--    when budget request approval is not required.
--    called by objects except offer.
-- History
--    Created   feliu   07/11/2002
----------------------------------------------------------------

PROCEDURE budget_request_approval(
   p_init_msg_list         IN   VARCHAR2,
   p_api_version           IN   NUMBER,
   p_commit                IN   VARCHAR2,
   x_return_status         OUT NOCOPY  VARCHAR2,
   x_msg_count             OUT NOCOPY  NUMBER,
   x_msg_data              OUT NOCOPY  VARCHAR2,
   p_object_type           IN  VARCHAR2,
   p_object_id             NUMBER
   );

END OZF_BudgetApproval_PVT;

/
