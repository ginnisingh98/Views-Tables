--------------------------------------------------------
--  DDL for Package OZF_ACTBUDGETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_ACTBUDGETS_PVT" AUTHID CURRENT_USER AS
   /*$Header: ozfvbdgs.pls 120.4.12010000.7 2010/02/17 08:33:05 nepanda ship $*/
   -- Start of Comments
   --
   -- NAME
   --   OZF_ACTBUDGETS_PVT
   --
   -- PURPOSE
   --   This package is a Private API for managing Budget information in
   --   OZF.
   --
   --   Procedures:
   --     Create_Act_Budgets (see below for specification)
   --     Update_Act_Budgets (see below for specification)
   --     Delete_Act_Budgets (see below for specification)
   --     Lock_Act_Budgets (see below for specification)
   --     Validate_Act_Budgets (see below for specification)
   --     Validate_Act_Budgets_Items (see below for specification)
   --     Validate_Act_Budgets_Record (see below for specification
   --     Complete_Act_Budgets_Rec
   --     Init_Act_Budgets_Rec
   --
   -- NOTES
   -- Added by mpande 04/26/2001
   -- The Transfer_type columns can have the follwoing values
   -- REQUEST -- When an object requests money . A workflow is submitted
   --           Workflow for FUND --> to FUND is different than FUND --> OTHER OBJECTS (CAMP,EVEH)
   -- TRANSFER -- This means it is a transfer back to the parent or the FUND
   -- RELEASE -- Only for FUND ( Releasing Holdback)
   -- RESERVE -- Only for FUND ( Reserving Holdback)
   -- UTILIZED-- Utilized budget Amounts by the objects
   --- The data in the table looks the following
   -- Budget Source is always the depleting object and used_by is always the target object
   --  Used_by_id  Used_by_type  bdg_src_id  bdg_src_type  transfer_type request_amt  req cur   apprv_amt appr_in_curr apprv_org_amt
   --  C1          CAMP          F1          FUND          'REQUEST'     1000          USD       1000       GBP         300
     --
   --                                                                                 (C1 curr)  (C1 curr)              (F1 curr)
   --  C1          CAMP          F2          FUND          'REQUEST'     2000         USD        1500       CND         500
   --                                                                                 (C1 curr)  (C1 curr)              (F2 curr)
   --  F1          CAMP          C1          FUND          'TRANSFER'    1000         USD        500        GBP          150
   --                                                                                 (F1 curr)  (F1 curr)              (F1 curr)
   --  CS1         CSCH          C1          FUND          'REQUEST'     1200         RS         60,000     USD         1200
   --                                                                                 (CS1 curr) (CS1 curr)             (C1 curr)

   --- Sourcing Rules
   -- 1) You can only source directly frma budget or from your parent object
   -- for eg. Campaign schedule can only source from its parent campaign or a budget
   --         and not from its peer or anyother object
   -- 2) Progrozf cannot source from a budget
   -- 3) Offers have to source directly from a budget . It cannot use the fund from its parent activity
   -- 4) You cannot transfer more than what you have requested
   -- History      created    sugupta  04/12/2000
   -- 25-Jun-2000  choang     Commented out show errors and uncommented exit
   -- 14-Aug-2000  choang     Modified signature of act_budgets_rec_type.
   -- 16-Aug-2000  choang     Added Init_Act_Budgets_Rec, Approve_ActBudget,
   --                         Reject_ActBudget and Close_ActBudget.
   -- 20-Aug-2000  choang     Added user_status_id.
   -- 22-Aug-2000  choang     Added can_modify() and is_account_closed().
   -- 12-Sep-2000  choang     1) Moved approval API's to OZF_BudgetApproval_PVT.
   -- 22-FEB-2001  mpande     ADDED two more columns, adjusted_flag and posted flag
   -- 22-Feb-2001  mpande   Modified for All Hornet changes.
   --                        1) Addded 7 new  columns and added functional validation
   --                        2) ALL FUND_TRANSFERS and requests are going to be performed from this table--  Added code for that
   --                        3) Integrated with notes API to create justification and comments
   -- 04/26/2001   mpande    1)Added code for utilizarions , requesterId , date_requred_by , transfertype and respective validations
   --                        2) Added code for Parent source_id -- This value is always Budget id
   --                        3) Added Code for transfer_type - Utilizations
   -- 05/22/2001   mpande    Added a new overloaded procedure for update_Act_budget
   -- 06/07/2001   feliu     Added partner_holding_type, partner_address_id, vendor_id.
   -- 06/29/2001   feliu     Added owner_id.
   -- 10/22/2001   mpande    Changed code different owner allocation bug
   -- 10/23/2001   feliu     Added record type act_util_rec_type, recal_flag in act_budgets_rec_type, and
   --                        one more input p_act_util_rec in create_act_budgets. added one overload create_act_budgets.
   -- 12/19/2001   mpande    Added Code for src_curr_request_amount
   -- 02/26/2002   fliu      added more comlumns for act_util_rec_type.
  --  04/16/2002   feliu     Moved some functions to OZF_ACTBUDGETRULES_PVT to reduce this file size.
 --   10/28/2002   feliu     Change for 11.5.9
 --   10/28/2002   feliu     added scan_unit,scan_unit_remaining,activity_product_id,scan_type_id for act_util_rec_type.
  --  11/12/2002   feliu     added volume_offer_tiers_id.
  --  11/04/2003   yzhao     11.5.10: added billto_cust_account_id, reference_type, reference_id to act_util_rec_type
  --  06/12/2005   rimehrot  R12 Changes
  --  03/16/2006   kdass     fixed bug 5080481 - exposed flexfields
  --  08/01/2008   nirprasa  fixed bug 7030415
  --  08/14/2008   nirprasa  fixed bug 6657242
  --  08/14/2008   nirprasa  fixed bug 7425189
  --  06/12/2009   kdass     bug 8532055 - ADD EXCHANGE RATE DATE PARAM TO OZF_FUND_UTILIZED_PUB.CREATE_FUND_ADJUSTMENT API
  --  07/24/2009   kdass     Bug 8726683 - SSD Adjustments ER - Return utilization_id to the adjustment API
  --  2/17/2010    nepanda   Bug 9131648 : multi currency changes
  -- End of Comments

   -- global constants

   TYPE act_budgets_rec_type IS RECORD(
      activity_budget_id            NUMBER,
      last_update_date              DATE,
      last_updated_by               NUMBER,
      creation_date                 DATE,
      created_by                    NUMBER,
      last_update_login             NUMBER,
      object_version_number         NUMBER,
      act_budget_used_by_id         NUMBER,
      arc_act_budget_used_by        VARCHAR2(30),
      budget_source_type            VARCHAR2(30),
      budget_source_id              NUMBER,
      transaction_type              VARCHAR2(30),
      request_amount                NUMBER,
      request_currency              VARCHAR2(15),
      request_date                  DATE,
      user_status_id                NUMBER,
      status_code                   VARCHAR2(30),
      approved_amount               NUMBER,
      approved_original_amount      NUMBER,
      approved_in_currency          VARCHAR2(15),
      -- ADDED 06/18/2000 SUGUPTA
      approval_date                 DATE,
      approver_id                   NUMBER,
      spent_amount                  NUMBER,
      partner_po_number             VARCHAR2(50),
      partner_po_date               DATE,
      partner_po_approver           VARCHAR2(120),
      --ADDED 02/22/2001 MPANDE
      adjusted_flag                 VARCHAR2(1),
      posted_flag                   VARCHAR2(1),
      justification                 VARCHAR(4000),
      comment                       VARCHAR(4000),
      parent_act_budget_id          NUMBER,
      contact_id                    NUMBER,
      reason_code                   VARCHAR2(30),
      transfer_type                 VARCHAR2(30),
      requester_id                  NUMBER,
      date_required_by              DATE,
      parent_source_id              NUMBER,
      parent_src_curr               VARCHAR2(30),
      parent_src_apprvd_amt         NUMBER,
      partner_holding_type          VARCHAR2(30),
      partner_address_id            NUMBER,
      vendor_id             NUMBER,
      owner_id             NUMBER,
      recal_flag                    VARCHAR2(1),
      exchange_rate_date            DATE,-- nirprasa, Added for bug 7425189
      -- **************--
      attribute_category            VARCHAR2(30),
      attribute1                    VARCHAR2(150),
      attribute2                    VARCHAR2(150),
      attribute3                    VARCHAR2(150),
      attribute4                    VARCHAR2(150),
      attribute5                    VARCHAR2(150),
      attribute6                    VARCHAR2(150),
      attribute7                    VARCHAR2(150),
      attribute8                    VARCHAR2(150),
      attribute9                    VARCHAR2(150),
      attribute10                   VARCHAR2(150),
      attribute11                   VARCHAR2(150),
      attribute12                   VARCHAR2(150),
      attribute13                   VARCHAR2(150),
      attribute14                   VARCHAR2(150),
      attribute15                   VARCHAR2(150),
      src_curr_req_amt              NUMBER);

     TYPE act_util_rec_type IS RECORD
   (
      object_type                VARCHAR2(30)
     ,object_id                 NUMBER
     ,adjustment_type           VARCHAR2(30)
     ,camp_schedule_id          NUMBER
     ,adjustment_type_id        NUMBER
     ,product_level_type        VARCHAR2(30)
     ,product_id                NUMBER
     ,cust_account_id           NUMBER
     ,price_adjustment_id       NUMBER
     ,utilization_type          VARCHAR2(30)
     ,adjustment_date           DATE
     ,gl_date                   DATE
     ,scan_unit                 NUMBER
     ,scan_unit_remaining       NUMBER
     ,activity_product_id       NUMBER
     ,scan_type_id              NUMBER -- this colums is not in the table but required for scan data offers adj
     ,volume_offer_tiers_id     NUMBER
     --  11/04/2003   yzhao     11.5.10: added
     ,billto_cust_account_id    NUMBER
     ,reference_type            VARCHAR2(30)
     ,reference_id              NUMBER
     -- 01/02/2004 kdass added for 11.5.10
     ,order_line_id             NUMBER
     ,org_id                    NUMBER
     ,orig_utilization_id       NUMBER
     ,gl_posted_flag            VARCHAR2(1)
     ,bill_to_site_use_id       NUMBER
     ,ship_to_site_use_id       NUMBER
     --07/26/2005 kdass added for 12.0
     ,gl_account_credit         NUMBER
     ,gl_account_debit          NUMBER
     ,site_use_id               NUMBER -- fix for bug 6657242
     ,exchange_rate_date        DATE -- nirprasa, Added for bug 7425189
     ,exchange_rate_type        VARCHAR2(30)--nirprasa, added for 12.2 enhancements
     --nirprasa, ER 8399134
     ,currency_code                 VARCHAR2(15)
     ,plan_curr_amount              NUMBER
     ,plan_curr_amount_remaining    NUMBER
     ,plan_currency_code            VARCHAR2(15)
     ,fund_request_amount           NUMBER
     ,fund_request_amount_remaining NUMBER
     ,fund_request_currency_code    VARCHAR2(15)
     --nirprasa, ER 8399134
     --kdass added flexfields
     ,attribute_category        VARCHAR2(30)
     ,attribute1                VARCHAR2(150)
     ,attribute2                VARCHAR2(150)
     ,attribute3                VARCHAR2(150)
     ,attribute4                VARCHAR2(150)
     ,attribute5                VARCHAR2(150)
     ,attribute6                VARCHAR2(150)
     ,attribute7                VARCHAR2(150)
     ,attribute8                VARCHAR2(150)
     ,attribute9                VARCHAR2(150)
     ,attribute10               VARCHAR2(150)
     ,attribute11               VARCHAR2(150)
     ,attribute12               VARCHAR2(150)
     ,attribute13               VARCHAR2(150)
     ,attribute14               VARCHAR2(150)
     ,attribute15               VARCHAR2(150)
   );

   G_MISS_ACT_UTIL_REC    act_util_rec_type;

   /****************************************************************************/
   -- Start of Comments
   --
   --    API name    : create_act_budgets
   --    Type        : Private
   --    Function    : Create a row in OZF_ACT_Budgets table
   --
   --    Pre-reqs    : None
   --
   --    Version    :     Current version     1.0
   --                     Initial version     1.0
   --
   --    Note
   -- End Of Comments
   /****************************************************************************/

 PROCEDURE create_act_budgets(
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,p_act_budgets_rec    IN       act_budgets_rec_type
     ,x_act_budget_id      OUT NOCOPY      NUMBER);

   /****************************************************************************/
   -- Start of Comments
   --
   --    API name    : create_act_budgets
   --    Type        : Private
   --    Function    : Create a row in OZF_ACT_Budgets table
   --
   --    Pre-reqs    : None
   --
   --    Version    :     Current version     1.0
   --                     Initial version     1.0
   --
   --    Note   : This overloaded procedure is to be called from
   --             recalculating concurrent program.
   --
   -- End Of Comments
   /****************************************************************************/

 PROCEDURE create_act_budgets(
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,p_act_budgets_rec    IN       act_budgets_rec_type
     ,p_act_util_rec       IN       act_util_rec_type
     ,x_act_budget_id      OUT NOCOPY      NUMBER
     ,p_approval_flag      IN       VARCHAR2 :=fnd_api.g_false);


   /****************************************************************************
    *  Ying Zhao: 06/21/2004 overloaded function to return actual utilized amount for chargeback
    *             added x_utilized_amount
    */
 PROCEDURE create_act_budgets(
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,p_act_budgets_rec    IN       act_budgets_rec_type
     ,p_act_util_rec       IN       act_util_rec_type
     ,x_act_budget_id      OUT NOCOPY      NUMBER
     ,p_approval_flag      IN       VARCHAR2 :=fnd_api.g_false
     ,x_utilized_amount    OUT NOCOPY      NUMBER);

--kdass - added for Bug 8726683
PROCEDURE create_act_budgets (
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,p_act_budgets_rec    IN       act_budgets_rec_type
     ,p_act_util_rec       IN       act_util_rec_type
     ,x_act_budget_id      OUT NOCOPY      NUMBER
     ,p_approval_flag      IN       VARCHAR2 := fnd_api.g_false
     ,x_utilized_amount    OUT NOCOPY      NUMBER
     ,x_utilization_id     OUT NOCOPY      NUMBER
   );

   /****************************************************************************/
   -- Start of Comments
   --
   --    API name    : Update_Act_Budgets
   --    Type        : Private
   --    Function    : Update a row in OZF_ACT_Budgets table
   --
   --    Pre-reqs    : None
   --
   --    Version    :     Current version     1.0
   --                     Initial version     1.0
   --
   --    Note   : 1. p_act_Budgets_rec.ACT_BUDGET_USED_BY_ID, ARC_ACT_BUDGET_USED_BY
   --                         BUDGET_SOURCE_TYPE, BUDGET_SOURCE_ID are required parameters
   --          Should also make CONTRIBUTION_AMOUNT mandatory
   --          2. if source type is PARTNER, then PO related fields become mandatory
   --             3. p_act_Budgets_rec.activity_budget_id is not updatable
   --
   -- End Of Comments
   /****************************************************************************/

   PROCEDURE update_act_budgets(
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,p_act_budgets_rec    IN       act_budgets_rec_type);
   /****************************************************************************/
   -- Start of Comments
   --
   --    API name    : Update_Act_Budgets
   --    Type        : Private
   --    Function    : Update a row in OZF_ACT_Budgets table
   --    Note        : This overloaded procedure is to be called from
   --                  Workflow to maintain the context.
   --
   -- End Of Comments
   /****************************************************************************/
   PROCEDURE update_act_budgets(
      p_api_version            IN       NUMBER
     ,p_init_msg_list          IN       VARCHAR2 := fnd_api.g_false
     ,p_commit                 IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level       IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status          OUT NOCOPY      VARCHAR2
     ,x_msg_count              OUT NOCOPY      NUMBER
     ,x_msg_data               OUT NOCOPY      VARCHAR2
     ,p_act_budgets_rec        IN       act_budgets_rec_type
     ,p_parent_process_flag    IN       VARCHAR2
     ,p_parent_process_key     IN       VARCHAR2
     ,p_parent_context         IN       VARCHAR2
     ,p_parent_approval_flag   IN       VARCHAR2
     ,p_continue_flow          IN       VARCHAR2
     ,p_child_approval_flag    IN       VARCHAR2 := fnd_api.g_false
     -- 10/22/2001 mpande added for allocation bug
     ,p_requestor_owner_flag  IN        VARCHAR2 := 'N'
     ,p_act_util_rec           IN       act_util_rec_type := NULL
   );



   /****************************************************************************/
   -- Start of Comments
   --
   --    API name    : Update_Act_Budgets
   --    Type        : Private
   --    Function    : Update a row in OZF_ACT_Budgets table
   --    Note        : This overloaded procedure is to be called from
   --                  Workflow to maintain the context.
   --
   -- End Of Comments
   /****************************************************************************/
   PROCEDURE update_act_budgets(
      p_api_version            IN       NUMBER
     ,p_init_msg_list          IN       VARCHAR2 := fnd_api.g_false
     ,p_commit                 IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level       IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status          OUT NOCOPY      VARCHAR2
     ,x_msg_count              OUT NOCOPY      NUMBER
     ,x_msg_data               OUT NOCOPY      VARCHAR2
     ,p_act_budgets_rec        IN       act_budgets_rec_type
     ,p_parent_process_flag    IN       VARCHAR2
     ,p_parent_process_key     IN       VARCHAR2
     ,p_parent_context         IN       VARCHAR2
     ,p_parent_approval_flag   IN       VARCHAR2
     ,p_continue_flow          IN       VARCHAR2
     ,p_child_approval_flag    IN       VARCHAR2 := fnd_api.g_false
     -- 10/22/2001 mpande added for allocation bug
     ,p_requestor_owner_flag  IN        VARCHAR2 := 'N'
     ,p_act_util_rec           IN       act_util_rec_type := NULL
     ,x_utilized_amount        OUT NOCOPY      NUMBER);


   /****************************************************************************/
   -- Start of Comments
   --
   --    API name    : Update_Act_Budgets
   --    Type        : Private
   --    Function    : Update a row in OZF_ACT_Budgets table
   --    Note        : This overloaded procedure is to be called from fund module for child -- parent approval
   --                  Workflow to maintain the context.
   --
   -- End Of Comments
   /****************************************************************************/
   PROCEDURE update_act_budgets(
      p_api_version            IN       NUMBER
     ,p_init_msg_list          IN       VARCHAR2 := fnd_api.g_false
     ,p_commit                 IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level       IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status          OUT NOCOPY      VARCHAR2
     ,x_msg_count              OUT NOCOPY      NUMBER
     ,x_msg_data               OUT NOCOPY      VARCHAR2
     ,p_act_budgets_rec        IN       act_budgets_rec_type
     ,p_child_approval_flag    IN       VARCHAR2
     -- 10/22/2001 mpande added for allocation bug
     ,p_requestor_owner_flag   IN       VARCHAR2 := 'N'
     ,p_act_util_rec           IN       act_util_rec_type := NULL
     );


   /****************************************************************************
    *  Ying Zhao: 06/21/2004 overloaded function to return actual utilized amount for chargeback
    *             added x_utilized_amount
    */
   PROCEDURE update_act_budgets(
      p_api_version            IN       NUMBER
     ,p_init_msg_list          IN       VARCHAR2 := fnd_api.g_false
     ,p_commit                 IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level       IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status          OUT NOCOPY      VARCHAR2
     ,x_msg_count              OUT NOCOPY      NUMBER
     ,x_msg_data               OUT NOCOPY      VARCHAR2
     ,p_act_budgets_rec        IN       act_budgets_rec_type
     ,p_child_approval_flag    IN       VARCHAR2
     -- 10/22/2001 mpande added for allocation bug
     ,p_requestor_owner_flag   IN       VARCHAR2 := 'N'
     ,p_act_util_rec           IN       act_util_rec_type := NULL
     ,x_utilized_amount        OUT NOCOPY      NUMBER
     );

   --kdass - added for Bug 8726683
   PROCEDURE update_act_budgets (
      p_api_version            IN       NUMBER
     ,p_init_msg_list          IN       VARCHAR2 := fnd_api.g_false
     ,p_commit                 IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level       IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status          OUT NOCOPY      VARCHAR2
     ,x_msg_count              OUT NOCOPY      NUMBER
     ,x_msg_data               OUT NOCOPY      VARCHAR2
     ,p_act_budgets_rec        IN       act_budgets_rec_type
     ,p_parent_process_flag    IN       VARCHAR2
     ,p_parent_process_key     IN       VARCHAR2
     ,p_parent_context         IN       VARCHAR2
     ,p_parent_approval_flag   IN       VARCHAR2
     ,p_continue_flow          IN       VARCHAR2
     ,p_child_approval_flag    IN       VARCHAR2 := fnd_api.g_false
     ,p_requestor_owner_flag   IN       VARCHAR2 := 'N'
     ,p_act_util_rec           IN       act_util_rec_type  := NULL
     ,x_utilized_amount        OUT NOCOPY     NUMBER
     ,x_utilization_id         OUT NOCOPY     NUMBER
   );

   /*****************************************************************************************/
   -- Start of Comments
   --
   --    API name    : Delete_Act_Budgets
   --    Type        : Private
   --    Function    : Delete a row in OZF_ACT_BudgetsS table
   --
   --    Pre-reqs    : None
   --    Version    :     Current version     1.0
   --                     Initial version     1.0
   --
   --    Note   : 1. p_Budgets_rec.activity_budget_id, object_version_number is a required parameter
   --
   -- End Of Comments

   PROCEDURE delete_act_budgets(
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,p_act_budget_id      IN       NUMBER
     ,p_object_version     IN       NUMBER);

   /*****************************************************************************************/
   -- Start of Comments
   --
   --    API name    : Lock_Act_Budgets
   --    Type        : Private
   --    Function    : Lock a row in OZF_ACT_BudgetsS table
   --
   --    Pre-reqs    : None
   --    Paramaeters :
   --    IN        :
   --    Version    :     Current version     1.0
   --                     Initial version     1.0
   --
   --    Note   : p_Budgets_rec.activity_Budget_id, object_version_number is a required parameter
   --
   -- End Of Comments

   PROCEDURE lock_act_budgets(
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,p_act_budget_id      IN       NUMBER
     ,p_object_version     IN       NUMBER);

   /*****************************************************************************************/
   -- Start of Comments
   --
   --    API name    : Validate_Act_Budgets
   --    Type        : Private
   --    Function    : Validate a row in OZF_ACT_BudgetsS table
   --
   --    Pre-reqs    : None
   --    Version    :     Current version     1.0
   --                     Initial version     1.0
   --
   --    Note : 1. p_Budgets_rec.activity_Budget_id is a required parameter
   --           2. x_return_status will be FND_API.G_RET_STS_SUCCESS,
   --                            FND_API.G_RET_STS_ERROR, or
   --                            FND_API.G_RET_STS_UNEXP_ERROR
   --
   -- End Of Comments
   /*****************************************************************************************/
   PROCEDURE validate_act_budgets(
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,p_act_budgets_rec    IN       act_budgets_rec_type);

/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Validate_Act_Budgets_Items
--
-- PURPOSE
--   This procedure is to validate busget items
-- HISTORY
-- 24-Aug-2000 choang   Changed ams_fund_details_v to ams_fund_details_v
-- 22-Feb-2001 mpande   Modified for Hornet changes.
-- End of Comments
/*****************************************************************************************/
   PROCEDURE validate_act_budgets_items(
      p_act_budgets_rec   IN       act_budgets_rec_type
     ,p_validation_mode   IN       VARCHAR2 := jtf_plsql_api.g_create
     ,x_return_status     OUT NOCOPY      VARCHAR2);
/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Validate_Act_Budgets_Record
--
-- PURPOSE
--   This procedure is to validate budget record
--
-- NOTES
-- HISTORY
-- 22-Aug-2000 choang   Added validation of credit request amounts.
-- 23-Jan-2001 mpande   Added validation in validation_actbudget_rec  for not
--    to submit for approval when the requested amount is 0.  BUG# 1604000
-- 22-Feb-2001 mpande   Modified for Hornet changes.
-- End of Comments
/*****************************************************************************************/
   PROCEDURE validate_act_budgets_record(
      p_act_budgets_rec   IN       act_budgets_rec_type
     ,p_validation_mode   IN       VARCHAR2 := jtf_plsql_api.g_create
     ,x_return_status     OUT NOCOPY      VARCHAR2);
/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   complete_act_budgets_rec
--
-- PURPOSE
--   This procedure is to complete budget record
--
-- NOTES
-- HISTORY
-- End of Comments
/*****************************************************************************************/
   PROCEDURE complete_act_budgets_rec(
      p_act_budgets_rec   IN       act_budgets_rec_type
     ,x_act_budgets_rec   OUT NOCOPY      act_budgets_rec_type);


/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--    Init_Act_Budgets_Rec
-- PURPOSE
--    Initialize all column values to FND_API.g_miss_char/num/date
-- HISTORY
-- 15-Aug-2000 choang   Created.
-- 22-Feb-2001 mpande   Modified for Hornet changes.
/*****************************************************************************************/
   PROCEDURE init_act_budgets_rec(
      x_act_budgets_rec   OUT NOCOPY   act_budgets_rec_type);
   /*****************************************************************************************/
   -- Start of Comments
   --
   -- Procedure and function declarations.
   --
   -- NAME
   --    get_object_currency
   -- PURPOSE
   --    Return the currency code of the object trying to
   --    associate a budget.
   /*****************************************************************************************/
   FUNCTION get_object_currency(
      p_object          IN       VARCHAR2
     ,p_object_id       IN       NUMBER
     ,x_return_status   OUT NOCOPY      VARCHAR2)
      RETURN VARCHAR2;


/*****************************************************************************************/
   -- Start of Comments
   --
   -- Procedure and function declarations.
   --
   -- NAME
   --    create_child_act_budget
   -- PURPOSE
   --    create child requests when sourcing from parent.
   --
/*****************************************************************************************/

PROCEDURE  create_child_act_budget (
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2,
      p_act_budgets_rec    IN       ozf_actbudgets_pvt.act_budgets_rec_type,
      p_exchange_rate_type IN VARCHAR2 DEFAULT FND_API.G_MISS_CHAR --Added for bug 7030415
    );

/*****************************************************************************************/
-- nirprasa, Added for bug 7425189
-- NAME
--    update_reconcile_objfundsum
--
-- PURPOSE
--    This Procedure updates record in object fund summary table
--    for budget reconcile. This will not affect any other flow.
--
-- NOTES
--
-- HISTORY

/******************************************************************************************/
/*commented for bug 8532055
PROCEDURE update_reconcile_objfundsum (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_validation_level           IN  NUMBER := Fnd_Api.G_VALID_LEVEL_FULL,
   p_objfundsum_rec             IN  OZF_OBJFUNDSUM_PVT.objfundsum_rec_type,
   p_conv_date                  IN  DATE,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
);
*/
/******************************************************************************************/
END ozf_actbudgets_pvt;

/
