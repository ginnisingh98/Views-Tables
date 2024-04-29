--------------------------------------------------------
--  DDL for Package Body OZF_ACTBUDGETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_ACTBUDGETS_PVT" AS
/*$Header: ozfvbdgb.pls 120.21.12010000.10 2010/05/05 09:34:19 nepanda ship $*/
   -- NAME
   --   OZF_ACTBUDGETS_PVT
   --
   -- HISTORY
   -- 04/12/2000  sugupta  CREATED
   --  25-Jun-2000   choang   Commented out show errors and uncommented exit
   --  14-Aug-2000   choang   1) Removed colums: contribution_amount, contribution_currency,
   --                         contribution_uom.  2) Added columns: request_amount, request_currency,
   --                         approved_amount, approved_original_amount, approved_in_currency, sent_amount, sent_currency,
   --                         transaction_type.  3) Modified partner_po_number to varchar2(50).
   --  16-Aug-2000   choang   Implemented Approve_ActBudget and Reject_ActBudget
   --  18-Aug-2000   choang   Added calls to Fund's API for update of the fund according to the action
   --                         on the budget source: 1) submit for approval - add to forecast budget of
   --                         the fund 2) approve - add to commited budget of the fund 3) reject - subtract
   --                         from the forecast budget of the fund.
   --  20-Aug-2000   choang   Added user_status_id.
   --  22-Aug-2000   choang   Added get_approver(), can_modify() and is_account_closed().
   --  24-Aug-2000   choang   approval and rejection of budget should also include approver_id.
   --  30-Aug-2000   choang   Corr ected currency conversion values when budget source is submitted for approval.
   --  05-Sep-2000   choang   Fixed bug 1397577 - added deliverable as consumer of budget source.
   --                         Modified call to ozf_funds_pvt.update_fund to include p_mode = 'WORKFLOW'
   --                         to by-pass validation of budget status.
   --  12-Sep-2000   choang   1) Moved approval API's to OZF_BudgetApproval_PVT.
   --                         2) Removed get_approver()  3) Modified trigger_approval_process()
   --  14-Sep-2000   choang   Moved approval processing steps into procedure process_approval().
   --  17-Sep-2000   choang   Added status_id's to call to ams_approval_pvt.start_lineapproval.
   --                         Added revert_approval for wf approval error handling.
   --  29-Sep-2000   choang   Added partner in budget source id validation.
   --  07-Nov-2000   choang   Rejected records do not count as record when considering
   --                         for cue card "tick".
   --  23-Jan-2001   mpande   Added validation in validation_actbudget_rec  for not to submit for approval when the requested amount is 0
   --      BUG# 1604000
   --  31-Jan-2001   mpande   Removed access from ozf_fund_details_V to ozf_funds_all_vl for cross organzation validation.
   --  02/10/2001    mpande   BUG #1637319 only for INternal rollout
   --  22-Feb-2001   mpande   Modified for All Hornet changes.
   --                          1) Addded 7 new  columns and added functional validation
   --                          2) ALL FUND_TRANSFERS and requests are going to be performed from this table--  Added code for that
   --                          3) Integrated with notes API to create justification and comments
   --  04/26/2001   MPande    1)Added code for utilizarions , requesterId , date_requred_by , transfertype and respective validations
   --                         2) Added code for Parent sourc_id -- This value is always Budget id
   --                         3) Added Code for transfer_type - Utilizations
   --                         4) Added Code fo rApproval reqd
   --                         5) Removed utlization API to ozf_fund_Adjustment_pvt
   --                         6) can modify , is account closed -- procedure removed
   --                         7) Made all functional changes reqd for different types of transfer
   -- 06/072001    feliu      Added partner_holding_type, partner_address_id, vendor_id.
   -- 06/14/2001   mpande     Added code for EONE .
   -- 10/12/2001   mpande     Changed Code to submit partner approval also (not for approval )
   --                         Commented Product Eligibility validation
   -- 10/22/2001   mpande    Changed code different owner allocation bug
  --  10/23/2001   feliu      Added recal_flag column and one more input p_act_util_rec in create_act_budgets.
  --  11/07/2001   feliu      Changed process_approval to update recal_committed column.
  --  01/15/2002   feliu      change to partner_party_id from partner_id to fix budg 2182197.
  --  01/21/2002   feliu      change back partner_id from partner_party_id.
  --  03/21/2002   mpande     added because Deliverables reconciliation was not working properly
  --  04/16/2002   feliu      Moved some functions to OZF_ACTBUDGETRULES_PVT to reduce this file size.
  --  6/11/2002    mpande     Fully accrued budget would have no committment
 --   10/28/2002   feliu       Change for 11.5.9
 --   10/27/2002   feliu      added offer validation.
  --  10/28/2002   feliu     added scan_unit,scan_unit_remaining,activity_product_id,scan_type_id for act_util_rec_type.
  --  12/05/2002   feliu      fixed nocopy issue.
--    12/23/2002   feliu       Changed for chargback.
  --  03/21/2003   feliu      fixed bug 2861097 by:
  --                          1.for budget transfer, call start wowkflow after update act budget.
  --   10-May-2004 feliu add business event for budget request approval.
 --    11-Aug-2004 rimehrot   Modified code to avoid duplicate currency conversion in process_approval.
   --   12/08/2004  feliu       fix bug 4032144.
  --  02/25/2005  feliu       fix bug 4174002.
  --  05/19/2005  gramanat    Added support for Offer Worksheet(WKST) to source from Budgets.
  --  08/05/2005  feliu       1. not create record in ozf_funds_utilized_all_b for REQUEST.
  --                          2. change validate for check_transfer_amount_exists.
  --                          3. calculate src_curr_request_amount before validation.
  --  08/17/2005  sangara     fix 11.5.9 bug 4553660
  --  09/05/2005  rimehrot    fix r12 bug 4030115
  --  11/16/2005  kdass       fixed bug 4728515
  --  03/16/2006  kdass       fixed bug 5080481 - exposed flexfields
  --  03/31/2006  kdass       fixed bug 5101720 - query fund_request_curr_code if offer has no currency defined
  --  17/May/2006 asylvia     fixed bug 5190932 - Message text for error OZF_NO_LEDGER_FOUND changed
  --  6/6/6       mkothari    reverted changes due to bug 5143254 - special price currency reqd
  --  08/01/2008  nirprasa    fixed bug 7030415
  --  10/08/2008  nirprasa    fixed bug 7425189
  --  10/08/2008  nirprasa    fixed bug 7505085 and rounding issues of bug 7425189.
  --                          skip the conversion for reconciliation flow of src_curr_req_amt.
  --  01/15/2009  nirprasa    fixed bug 7697861.
  --  06/12/2009  kdass       bug 8532055 - ADD EXCHANGE RATE DATE PARAM TO OZF_FUND_UTILIZED_PUB.CREATE_FUND_ADJUSTMENT API
  --  07/24/2009  kdass       Bug 8726683 - SSD Adjustments ER - Return utilization_id to the adjustment API
  --  2/17/2010   nepanda     Bug 9131648 : multi currency changes
  --  5/5/2010    nepanda     Bug 9625995 : Transaction currency value in Recalculated commited page is not getting converted.
  -- Note
   -- Please refer the spec for validation rules in this table
   -- The following is the mapping of the currency Columns
   -- request_currency -- act_budget_used_by_id Currency
   -- approved_in_currency -- budget_source_id Currency
   ----------------------------------------------------------------------------------------------------

   g_package_name     CONSTANT VARCHAR2 (30) := 'OZF_ACTBUDGETS_PVT';
   g_file_name        CONSTANT VARCHAR2 (12) := 'ozfvbdgb.pls';
   g_cons_fund_mode   CONSTANT VARCHAR2 (30) := 'ADJUST';
   g_recal_flag CONSTANT VARCHAR2(1) :=  NVL(fnd_profile.value('OZF_BUDGET_ADJ_ALLOW_RECAL'),'N');
   g_universal_currency   CONSTANT VARCHAR2 (15) := fnd_profile.VALUE ('OZF_UNIV_CURR_CODE');
   G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
/*****************************************************************************************/
-- Start of Comments
--
   --
   -- NAME
   --    trigger_approval_process
   -- PURPOSE
   --    Handle Workflow approval request processing.
/*****************************************************************************************/
   PROCEDURE trigger_approval_process (
      p_act_budget_rec         IN       act_budgets_rec_type
     ,x_act_budget_rec         IN OUT NOCOPY   act_budgets_rec_type
     ,x_return_status          OUT NOCOPY      VARCHAR2
     ,x_msg_count              OUT NOCOPY      NUMBER
     ,x_msg_data               OUT NOCOPY      VARCHAR2
     ,p_parent_process_flag    IN       VARCHAR2
     ,p_parent_process_key     IN       VARCHAR2
     ,p_parent_context         IN       VARCHAR2
     ,p_parent_approval_flag   IN       VARCHAR2
     ,p_continue_flow          IN       VARCHAR2
     ,p_child_approval_flag    IN       VARCHAR2 := fnd_api.g_false
      -- 10/22/2001   mpande    Changed code different owner allocation bug
     ,p_requestor_owner_flag   IN       VARCHAR2 := 'N'
     ,x_start_flow_flag        OUT NOCOPY   VARCHAR2
        -- added on 03/20/03
   ); -- added 05/22/2001 mpande


/*****************************************************************************************/
-- Start of Comments
   --
   -- NAME
   --    process_approval
   -- PURPOSE
   --    Handle all tasks needed before a budget line
   --    can be approved.
/*****************************************************************************************/
   PROCEDURE process_approval (
      p_act_budget_rec   IN       act_budgets_rec_type
     ,x_act_budget_rec   OUT NOCOPY      act_budgets_rec_type
     ,x_return_status    OUT NOCOPY      VARCHAR2
     ,x_msg_count        OUT NOCOPY      NUMBER
     ,x_msg_data         OUT NOCOPY      VARCHAR2
     ,p_mode             IN       VARCHAR2 :='UPDATE'-- added by mpande 12/27/2001
   );

/*****************************************************************************************/
-- Start of Comments
   --
   -- NAME
   --    Revert_Approval
   -- PURPOSE
   --    Revert the changes done when a budget line is
   --    submitted for approval.  For FUND lines, revert
   --    the planned amount.
/*****************************************************************************************/
   PROCEDURE revert_approval (
      p_act_budget_rec   IN       act_budgets_rec_type
     ,x_act_budget_rec   OUT NOCOPY      act_budgets_rec_type
     ,x_return_status    OUT NOCOPY      VARCHAR2
     ,x_msg_count        OUT NOCOPY      NUMBER
     ,x_msg_data         OUT NOCOPY      VARCHAR2
   );

-----------------------------------------------------------------------
-- PROCEDURE
--    raise_business_event
--
-- HISTORY
--    05/08/2004  feliu  Created.
-----------------------------------------------------------------------


PROCEDURE raise_business_event(p_object_id IN NUMBER)
IS
l_item_key varchar2(30);
l_parameter_list wf_parameter_list_t;
BEGIN
  l_item_key := p_object_id ||'_'|| TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');
  l_parameter_list := WF_PARAMETER_LIST_T();


  IF G_DEBUG THEN
    ozf_utility_pvt.debug_message(' activity budget  Id is :'||p_object_id );
  END IF;

    wf_event.AddParameterToList(p_name           => 'P_ACTBUDGET_ID',
                              p_value          => p_object_id,
                              p_parameterlist  => l_parameter_list);

   IF G_DEBUG THEN
       ozf_utility_pvt.debug_message('Item Key is  :'||l_item_key);
  END IF;

    wf_event.raise( p_event_name =>'oracle.apps.ozf.fund.request.approval',
                  p_event_key  => l_item_key,
                  p_parameters => l_parameter_list);


EXCEPTION
WHEN OTHERS THEN
RAISE Fnd_Api.g_exc_error;
ozf_utility_pvt.debug_message('Exception in raising business event');
END;


-- Start of Comments
--
-- NAME
--   Create_Act_Budgets
--
-- PURPOSE
--   This procedure is to create a Budget record that satisfy caller needs
--
-- HISTORY
-- 04/12/2000  sugupta  CREATED
-- 14-Aug-2000 choang   Modified for spec signature change.
-- 22-Feb-2001 mpande   Modified for Hornet changes.
-- 29-OCT-2001 feliu    Modified for recalculating committment.
-- End of Comments
/*****************************************************************************************/
   PROCEDURE create_act_budgets (
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,p_act_budgets_rec    IN       act_budgets_rec_type
     ,x_act_budget_id      OUT NOCOPY      NUMBER
   ) IS
     BEGIN
     create_act_budgets (
              p_api_version        => p_api_version
             ,p_init_msg_list      => p_init_msg_list
             ,p_commit             => p_commit
             ,p_validation_level   => p_validation_level
             ,x_return_status      => x_return_status
             ,x_msg_count          => x_msg_count
             ,x_msg_data           => x_msg_data
             ,p_act_budgets_rec    => p_act_budgets_rec
             ,p_act_util_rec       => G_MISS_ACT_UTIL_REC
             ,x_act_budget_id      => x_act_budget_id
             ,p_approval_flag      => fnd_api.g_false
             --p_approval_flag      IN       VARCHAR2 := fnd_api.g_false  means approval required
           );

   END create_act_budgets;


   /****************************************************************************
    *  Ying Zhao: 06/21/2004 overloaded function to return actual utilized amount for chargeback
    *             added x_utilized_amount
    */
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
   ) IS
     l_utilized_amount     NUMBER;
   BEGIN
     create_act_budgets (
              p_api_version        => p_api_version
             ,p_init_msg_list      => p_init_msg_list
             ,p_commit             => p_commit
             ,p_validation_level   => p_validation_level
             ,x_return_status      => x_return_status
             ,x_msg_count          => x_msg_count
             ,x_msg_data           => x_msg_data
             ,p_act_budgets_rec    => p_act_budgets_rec
             ,p_act_util_rec       => p_act_util_rec
             ,x_act_budget_id      => x_act_budget_id
             ,p_approval_flag      => p_approval_flag
             ,x_utilized_amount    => l_utilized_amount
           );
   END create_act_budgets;

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
   ) IS
     l_utilization_id     NUMBER;
   BEGIN

     --kdass - added for Bug 8726683
     create_act_budgets (
              p_api_version        => p_api_version
             ,p_init_msg_list      => p_init_msg_list
             ,p_commit             => p_commit
             ,p_validation_level   => p_validation_level
             ,x_return_status      => x_return_status
             ,x_msg_count          => x_msg_count
             ,x_msg_data           => x_msg_data
             ,p_act_budgets_rec    => p_act_budgets_rec
             ,p_act_util_rec       => p_act_util_rec
             ,x_act_budget_id      => x_act_budget_id
             ,p_approval_flag      => p_approval_flag
             ,x_utilized_amount    => x_utilized_amount
             ,x_utilization_id     => l_utilization_id
           );
   END create_act_budgets;

   /*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Create_Act_Budgets
--
-- PURPOSE
--   This procedure is to create a Budget record that satisfy caller needs
--
-- HISTORY
-- 04/12/2000  sugupta  CREATED
-- 14-Aug-2000 choang   Modified for spec signature change.
-- 22-Feb-2001 mpande   Modified for Hornet changes.
-- 29-OCT-2001 feliu    Modified for recalculating committment.
-- 12/18/2001  mpande   Added code for checkbook _v
                        -- p_approval_flag      IN       VARCHAR2 := fnd_api.g_false  means approval required
                        -- request amount would always be in act_budget_used_by curr
-- End of Comments
/*****************************************************************************************/
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
     ,x_utilized_amount    OUT NOCOPY      NUMBER              -- yzhao: 06/21/2004 added for chargeback
     ,x_utilization_id     OUT NOCOPY      NUMBER
   ) IS
      l_api_name      CONSTANT VARCHAR2 (30)        := 'Create_Act_Budgets';
      l_api_version   CONSTANT NUMBER               := 1.0;
      l_full_name     CONSTANT VARCHAR2 (60)        :=    g_package_name
                                                       || '.'
                                                       || l_api_name;
      l_status_type   CONSTANT VARCHAR2 (30)        := 'OZF_BUDGETSOURCE_STATUS';
      -- Status Local Variables
      l_return_status          VARCHAR2 (1); -- Return value from procedures
      l_act_budgets_rec        act_budgets_rec_type := p_act_budgets_rec;
      l_act_util_rec           act_util_rec_type := p_act_util_rec;
      l_temp_rec               act_budgets_rec_type := p_act_budgets_rec;
      l_act_budget_id          NUMBER;
      l_dummy                  NUMBER;
      l_fund_transfer_flag     VARCHAR2 (1)         := 'N';
      l_request_id   NUMBER;
      l_custom_setup_id NUMBER;
      l_fund_reconc_msg VARCHAR2(4000);
      l_act_bud_cst_msg VARCHAR2(4000);

      CURSOR c_offer_info(p_object_id IN NUMBER) IS
        SELECT custom_setup_id
        FROM ozf_offers
        WHERE qp_list_header_id = p_object_id;

      CURSOR c_act_budget_id IS
         SELECT ozf_act_budgets_s.NEXTVAL
           FROM DUAL;

      CURSOR c_id_exists (p_id IN NUMBER) IS
         SELECT 1
           FROM ozf_act_budgets
          WHERE activity_budget_id = p_id;

      CURSOR c_check_quota (p_type IN VARCHAR2, p_fund_id IN NUMBER) IS
         SELECT 1
         FROM  ozf_funds_all_b
         WHERE 'FUND' = p_type
           AND fund_type = 'QUOTA'
           AND fund_id = p_fund_id;

     --Added for bug 7030415

       CURSOR c_get_conversion_type( p_org_id IN NUMBER) IS
       SELECT exchange_rate_type
       FROM   ozf_sys_parameters_all
       WHERE  org_id = p_org_id;

      l_fc_amount                  NUMBER;
      l_set_of_books_id            NUMBER;
      l_mrc_sob_type_code          VARCHAR2(30);
      l_fc_currency_code           VARCHAR2(150);
      l_exchange_rate_type         VARCHAR2(150) := FND_API.G_MISS_CHAR;
      l_exchange_rate              NUMBER;
      -- mpande for changed checkbook view 12/17/2001
      l_src_curr_request_amt       NUMBER;
      l_src_currency               VARCHAR2(150);
      l_rate                       NUMBER;
      l_check_validation   VARCHAR2(50) := fnd_profile.value('OZF_CHECK_MKTG_PROD_ELIG');
      l_ledger_id                  NUMBER;
      l_ledger_name                VARCHAR2(30);
      l_is_quota                   NUMBER := NULL;

      --nirprasa,12.1.1
      l_transaction_currency       VARCHAR2(150);
      l_temp_request_amount        NUMBER;
      l_temp_approved_amount       NUMBER;
      l_temp_aprvd_orig_amount       NUMBER;
   BEGIN
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name
                                     || ': start');
      END IF;
      -- Standard Start of API savepoint
      SAVEPOINT create_act_budgets_pvt;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_package_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status            := fnd_api.g_ret_sts_success;

      -- API body
      -- Initialize default values before validation
      -- Get ID for activity budget from sequence.

      IF l_act_budgets_rec.activity_budget_id IS NULL THEN
         LOOP
            l_dummy                    := NULL;
            OPEN c_act_budget_id;
            FETCH c_act_budget_id INTO l_act_budgets_rec.activity_budget_id;
            CLOSE c_act_budget_id;
            OPEN c_id_exists (l_act_budgets_rec.activity_budget_id);
            FETCH c_id_exists INTO l_dummy;
            CLOSE c_id_exists;
            EXIT WHEN l_dummy IS NULL;
         END LOOP;
      END IF;

     IF G_DEBUG THEN
     ozf_utility_pvt.debug_message ('request_currency '||l_act_budgets_rec.request_currency);
     ozf_utility_pvt.debug_message ('arc_act_budget_used_by '||l_act_budgets_rec.arc_act_budget_used_by);
     ozf_utility_pvt.debug_message ('act_budget_used_by_id '||l_act_budgets_rec.act_budget_used_by_id);
     END IF;

     IF l_act_budgets_rec.request_currency IS NULL
     OR l_act_budgets_rec.request_currency = FND_API.G_MISS_CHAR THEN
      l_act_budgets_rec.request_currency :=
            get_object_currency (
               l_act_budgets_rec.arc_act_budget_used_by
              ,l_act_budgets_rec.act_budget_used_by_id
              ,l_return_status
            );
     END IF;
     --nirprasa,ER 8399134
     l_transaction_currency := l_act_util_rec.plan_currency_code;
      IF l_act_budgets_rec.request_currency <> l_transaction_currency
        AND l_act_budgets_rec.arc_act_budget_used_by = 'OFFR' THEN
          l_act_budgets_rec.request_currency := l_transaction_currency;
      END IF;

     --Added for bug 7425189
     l_fund_reconc_msg := fnd_message.get_string ('OZF', 'OZF_FUND_RECONCILE');
     l_act_bud_cst_msg := fnd_message.get_string ('OZF', 'OZF_ACT_BUDG_CST_UTIL');

      /*12/19/2001 mpande Added code for UI requirement , when a object is transfering money he would request in
       object's currency and not source currency since here the source is the object, in case of transfer */
      IF l_act_budgets_rec.transfer_type = 'TRANSFER' THEN
         l_act_budgets_rec.approved_in_currency :=
            get_object_currency (
               l_act_budgets_rec.budget_source_type
              ,l_act_budgets_rec.budget_source_id
              ,l_return_status
            );
         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message ('approved_in_currency '||l_act_budgets_rec.approved_in_currency);
            ozf_utility_pvt.debug_message ('request_currency '||l_act_budgets_rec.request_currency);
            ozf_utility_pvt.debug_message ('request_amount '||l_act_budgets_rec.request_amount);
            ozf_utility_pvt.debug_message ('src_curr_req_amt '||l_act_budgets_rec.src_curr_req_amt);
            ozf_utility_pvt.debug_message ('budget_source_type '||l_act_budgets_rec.budget_source_type);
            ozf_utility_pvt.debug_message ('l_transaction_currency '||l_transaction_currency);
         END IF;
         --nirprasa,12.2 Condition l_act_budgets_rec.budget_source_type <> 'FUND' THEN
         --is used instead of l_act_budgets_rec.budget_source_type = 'OFFR' THEN
         --because the same code gets executed for marketing objects also.
         --Except for 'fund transfer' this code will be executed for all object transfer.
         IF l_act_budgets_rec.approved_in_currency <> l_transaction_currency
         AND l_act_budgets_rec.budget_source_type <> 'FUND' THEN
		--nepanda :  fixed for bug # 9625995 : no need to convert approved in curr to transaction curr.
		-- all calculations are done based on approved in curr as the budget curr
             l_act_budgets_rec.approved_in_currency := l_act_budgets_rec.approved_in_currency; --l_transaction_currency;
         END IF;
         -- do this only if it is null because , in other case request amount should be passed correctly
         IF l_act_budgets_rec.request_amount IS NULL AND l_act_budgets_rec.src_curr_req_amt IS NOT NULL THEN
            IF l_act_budgets_rec.request_currency = l_act_budgets_rec.approved_in_currency THEN
               -- don't need to convert if currencies are equal
               l_act_budgets_rec.request_amount := l_act_budgets_rec.src_curr_req_amt;
            ELSE


               IF G_DEBUG THEN
                  ozf_utility_pvt.debug_message (   l_full_name
                                     || ' l_act_budgets_rec.exchange_rate_date1: ' || l_act_budgets_rec.exchange_rate_date);
               END IF;

               ozf_utility_pvt.convert_currency (
                  x_return_status => l_return_status
                 ,p_from_currency => l_act_budgets_rec.approved_in_currency
                 ,p_to_currency   => l_act_budgets_rec.request_currency
                 ,p_conv_date     => l_act_budgets_rec.exchange_rate_date --bug 7425189, 8532055
                 ,p_from_amount   => l_act_budgets_rec.src_curr_req_amt
                 ,x_to_amount     => l_act_budgets_rec.request_amount
               );
              /*
               -- convert the src_curr_request amount to the act_used_by  currency request amount.
               --Added for bug 7425189, pass exchange_rate_date = approval date of REQUEST
              IF l_act_budgets_rec.justification IN (l_fund_reconc_msg,l_act_bud_cst_msg)
                AND l_act_budgets_rec.exchange_rate_date IS NOT NULL
                AND l_act_budgets_rec.transfer_type = 'TRANSFER' THEN
               ozf_utility_pvt.convert_currency (
                  x_return_status=> l_return_status
                 ,p_from_currency=> l_act_budgets_rec.approved_in_currency
                 ,p_to_currency=> l_act_budgets_rec.request_currency
                 ,p_conv_date=> l_act_budgets_rec.exchange_rate_date
                 ,p_from_amount=> l_act_budgets_rec.src_curr_req_amt
                 ,x_to_amount=> l_act_budgets_rec.request_amount
               );
              ELSE

               ozf_utility_pvt.convert_currency (
                  x_return_status=> l_return_status
                 ,p_from_currency=> l_act_budgets_rec.approved_in_currency
                 ,p_to_currency=> l_act_budgets_rec.request_currency
                 ,p_from_amount=> l_act_budgets_rec.src_curr_req_amt
                 ,x_to_amount=> l_act_budgets_rec.request_amount
               );
              END IF;
              */

               IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
               END IF;
            END IF;
         END IF;
      END IF;
     /* End OF Change mpande 12/19/2001 */

      IF l_act_budgets_rec.request_currency IS NULL THEN
         ozf_utility_pvt.error_message ('OZF_ACT_BUDG_NO_CURRENCY');
         x_return_status            := fnd_api.g_ret_sts_error;
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Added 04/26/2001 mpande for new functionality changes for hornet
      ---System Populates the parent Source Id
      IF l_act_budgets_rec.transfer_type IN ('RELEASE', 'RESERVE') THEN
         l_act_budgets_rec.status_code := 'APPROVED';
         l_act_budgets_rec.approved_amount := l_act_budgets_rec.request_amount;
         l_act_budgets_rec.approved_original_amount := l_act_budgets_rec.request_amount;
         l_act_budgets_rec.approved_in_currency := l_act_budgets_rec.request_currency;

      ELSIF p_approval_flag = fnd_api.g_true THEN  -- Added by feliu for recalculating committment.
         l_act_budgets_rec.status_code := 'APPROVED';
         -- yzhao: 10/20/2003 automatically populate approved amount, currency information if it is not passed in
         --l_act_budgets_rec.approved_amount := l_act_budgets_rec.approved_amount;
         --l_act_budgets_rec.approved_original_amount := l_act_budgets_rec.approved_original_amount;
         --l_act_budgets_rec.approved_in_currency := l_act_budgets_rec.approved_in_currency;
      ELSIF l_act_budgets_rec.transfer_type IN ('TRANSFER', 'UTILIZED') THEN
         l_act_budgets_rec.status_code := NVL (l_act_budgets_rec.status_code, 'NEW');
      ELSE
         l_act_budgets_rec.status_code := 'NEW';
      END IF;

          -- Add by feliu on 05/22/04 for referal.
      IF  l_act_budgets_rec.arc_act_budget_used_by = 'OFFR' THEN
          OPEN c_offer_info(l_act_budgets_rec.act_budget_used_by_id);
          FETCH c_offer_info INTO l_custom_setup_id;
          CLOSE c_offer_info;
       END IF;

      IF  l_act_budgets_rec.status_code = 'APPROVED'
           AND NVL(l_custom_setup_id,0) = 105
          AND NVL(l_check_validation, 'NO') <> 'NO'
          AND l_act_budgets_rec.arc_act_budget_used_by = 'OFFR'
          AND l_act_budgets_rec.budget_source_type = 'FUND'
          AND  l_act_budgets_rec.transfer_type = 'REQUEST'  THEN
                l_act_budgets_rec.status_code := 'PENDING_VALIDATION';
      END IF;

      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message ('approved_amount '|| l_act_budgets_rec.approved_amount);
         ozf_utility_pvt.debug_message ('status_code '|| l_act_budgets_rec.status_code);
      END IF;

      -- yzhao: 10/20/2003 automatically populate approved amount, currency information if it is not passed in
      IF l_act_budgets_rec.status_code = 'APPROVED' THEN
         IF l_act_budgets_rec.approval_date IS NULL OR
            l_act_budgets_rec.approval_date = fnd_api.g_miss_date THEN
            l_act_budgets_rec.approval_date := sysdate;
         END IF;

         IF l_act_budgets_rec.approver_id IS NULL OR
            l_act_budgets_rec.approver_id = fnd_api.g_miss_num THEN
            l_act_budgets_rec.approver_id := ams_utility_pvt.get_resource_id (fnd_global.user_id);
         END IF;

         IF l_act_budgets_rec.approved_amount IS NULL OR
            l_act_budgets_rec.approved_amount = fnd_api.g_miss_num THEN
            l_act_budgets_rec.approved_amount := l_act_budgets_rec.request_amount;
         END IF;

         IF l_act_budgets_rec.approved_in_currency IS NULL OR
            l_act_budgets_rec.approved_in_currency = fnd_api.g_miss_char THEN
            l_act_budgets_rec.approved_in_currency :=
               get_object_currency (
                 l_act_budgets_rec.budget_source_type
                ,l_act_budgets_rec.budget_source_id
                ,l_return_status
               );
               --nirprasa,12.2 now should use transaction currency
               IF l_act_budgets_rec.approved_in_currency <> l_transaction_currency
                  AND l_act_budgets_rec.arc_act_budget_used_by = 'OFFR' THEN
                     l_act_budgets_rec.approved_in_currency := l_transaction_currency;
               END IF;
            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;



         IF l_act_budgets_rec.approved_original_amount IS NULL OR
            l_act_budgets_rec.approved_original_amount = fnd_api.g_miss_num THEN

             IF l_act_budgets_rec.request_currency = l_act_budgets_rec.approved_in_currency THEN
                -- don't need to convert if currencies are equal
                l_act_budgets_rec.approved_original_amount := l_act_budgets_rec.request_amount;
             ELSE

                --No change required.continue using conversion type profile.
                --since this code is used for fund sourcing.
                --In case of utilization flow If condition is true always.
                --Else never gets executed for utilization.

               IF G_DEBUG THEN
                  ozf_utility_pvt.debug_message (   l_full_name
                                     || ' l_act_budgets_rec.exchange_rate_date2: ' || l_act_budgets_rec.exchange_rate_date);
               END IF;

               ozf_utility_pvt.convert_currency (
                  x_return_status => l_return_status
                 ,p_from_currency => l_act_budgets_rec.request_currency
                 ,p_to_currency   => l_act_budgets_rec.approved_in_currency
                 ,p_conv_date     => l_act_budgets_rec.exchange_rate_date --bug 7425189, 8532055
                 ,p_from_amount   => l_act_budgets_rec.request_amount
                 ,x_to_amount     => l_act_budgets_rec.approved_original_amount
                );

                /*
                --nirprasa, for bug 7425189, this code gets executed for TRANSFER, i.e while
                --reconciling unutilized committed amount
                IF l_act_budgets_rec.justification IN (l_fund_reconc_msg,l_act_bud_cst_msg)
                AND l_act_budgets_rec.exchange_rate_date IS NOT NULL
                AND l_act_budgets_rec.transfer_type = 'TRANSFER' THEN
                ozf_utility_pvt.convert_currency (
                  x_return_status=> l_return_status
                 ,p_from_currency=> l_act_budgets_rec.request_currency
                 ,p_to_currency=> l_act_budgets_rec.approved_in_currency
                 ,p_conv_date=> l_act_budgets_rec.exchange_rate_date
                 ,p_from_amount=> l_act_budgets_rec.request_amount
                 ,x_to_amount=> l_act_budgets_rec.approved_original_amount
                );

                ELSE

                ozf_utility_pvt.convert_currency (
                  x_return_status=> l_return_status
                 ,p_from_currency=> l_act_budgets_rec.request_currency
                 ,p_to_currency=> l_act_budgets_rec.approved_in_currency
                 ,p_from_amount=> l_act_budgets_rec.request_amount
                 ,x_to_amount=> l_act_budgets_rec.approved_original_amount
                );
                END IF;
                */


                IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                   RAISE fnd_api.g_exc_unexpected_error;
                ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                   RAISE fnd_api.g_exc_error;
                END IF;
             END IF;
         END IF;
      END IF;   -- IF l_act_budgets_rec.status_code = 'APPROVED' THEN

      l_act_budgets_rec.user_status_id :=
              ozf_utility_pvt.get_default_user_status (l_status_type, l_act_budgets_rec.status_code);

      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;


----------------------- validate -----------------------
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name
                                     || ': validate');
      END IF;

      -- mpande added to populate request amount in request currency 12/17/2001 src_curr_request_amt
      IF l_act_budgets_rec.budget_source_type IN ('PTNR','OPTN') THEN
         l_src_currency := l_act_budgets_rec.request_currency ;
      ELSE
      l_src_currency :=
            get_object_currency (
               l_act_budgets_rec.budget_source_type
              ,l_act_budgets_rec.budget_source_id
              ,l_return_status
            );
      END IF;

      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_api_name||'l_src_currency '|| l_src_currency);
         ozf_utility_pvt.debug_message (   l_api_name||'budget_source_type '|| l_act_budgets_rec.budget_source_type);
         ozf_utility_pvt.debug_message (   l_api_name||'budget_source_id '|| l_act_budgets_rec.budget_source_id);
      END IF;

      --This call is for transfer_type='UTILIZED'/'REQUEST' both cases.
      --So, I need to do the conversion in case of utilized


      --Added for bug 7030415 , get the rate based on org only if it is for utilized.
      IF l_act_budgets_rec.transfer_type = 'UTILIZED' THEN
         OPEN c_get_conversion_type(l_act_util_rec.org_id);
         FETCH c_get_conversion_type INTO l_exchange_rate_type;
         CLOSE c_get_conversion_type;
      ELSE
         l_exchange_rate_type := FND_API.G_MISS_CHAR;
      END IF;

      IF NVL(l_act_budgets_rec.request_amount,0) <> 0 THEN

         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message (   l_full_name
                        || ' l_act_budgets_rec.exchange_rate_date3: ' || l_act_budgets_rec.exchange_rate_date);
         END IF;

      --For bug 7425189
       IF l_act_budgets_rec.justification IN (l_fund_reconc_msg,l_act_bud_cst_msg)
          AND l_act_budgets_rec.exchange_rate_date IS NOT NULL
          AND l_act_budgets_rec.transfer_type = 'TRANSFER' THEN
          IF l_act_budgets_rec.src_curr_req_amt IS NULL THEN
           ozf_utility_pvt.convert_currency(
            p_from_currency   => l_act_budgets_rec.request_currency
           ,p_to_currency     => l_src_currency
           ,p_conv_date       => l_act_budgets_rec.exchange_rate_date
           ,p_from_amount     => l_act_budgets_rec.request_amount
           ,x_return_status   => l_return_status
           ,x_to_amount       => l_act_budgets_rec.src_curr_req_amt
           ,x_rate            => l_rate);
          END IF;
        ELSE

         ozf_utility_pvt.convert_currency(
            p_from_currency   => l_act_budgets_rec.request_currency
           ,p_to_currency     => l_src_currency
           ,p_conv_type       => l_exchange_rate_type
           ,p_conv_date       => l_act_budgets_rec.exchange_rate_date --bug 8532055
           ,p_from_amount     => l_act_budgets_rec.request_amount
           ,x_return_status   => l_return_status
           ,x_to_amount       => l_act_budgets_rec.src_curr_req_amt
           ,x_rate            => l_rate);
        END IF;

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      validate_act_budgets (
         p_api_version=> 1.0
        ,p_init_msg_list=> fnd_api.g_false
        ,p_validation_level=> p_validation_level
        ,x_return_status=> l_return_status
        ,x_msg_count=> x_msg_count
        ,x_msg_data=> x_msg_data
        ,p_act_budgets_rec=> l_act_budgets_rec
      );

      -- If any errors happen abort API.
      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      -- Added 04/26/2001 mpande for new functionality changes for hornet
      IF      l_act_budgets_rec.budget_source_type = 'FUND'
          AND l_act_budgets_rec.arc_act_budget_used_by = 'FUND' THEN
         l_fund_transfer_flag       := 'Y';
      END IF;

      IF NVL(l_act_budgets_rec.approved_amount,0) <> 0 THEN
         -- R12: yzhao Oct. 10, 2005 get ledger when calculating functional currency
         IF G_DEBUG THEN
             ozf_utility_pvt.debug_message (   l_api_name
                                         || ': create_act_budgets   before getting ledger  util.org_id='
                                         || l_act_util_rec.org_id);
         END IF;

         IF l_act_util_rec.org_id IS NOT NULL THEN
            MO_UTILS.Get_Ledger_Info (
                    p_operating_unit     =>  l_act_util_rec.org_id,
                    p_ledger_id          =>  l_ledger_id,
                    p_ledger_name        =>  l_ledger_name
            );
            IF G_DEBUG THEN
                 ozf_utility_pvt.debug_message (   l_api_name
                                             || ': create_act_budgets   ledger for util.org_id('
                                             || l_act_util_rec.org_id || ')=' || l_ledger_id);
            END IF;
         ELSE
            ozf_utility_pvt.get_object_org_ledger(p_object_type => l_act_budgets_rec.arc_act_budget_used_by
                                                , p_object_id   => l_act_budgets_rec.act_budget_used_by_id
                                                , x_org_id      => l_act_util_rec.org_id
                                                , x_ledger_id   => l_ledger_id
                                                , x_return_status => l_return_status
                                           );
            IF G_DEBUG THEN
                 ozf_utility_pvt.debug_message (   l_api_name
                                             || ': create_act_budgets   ledger for '
                                             || l_act_budgets_rec.arc_act_budget_used_by
                                             || '  id('
                                             || l_act_budgets_rec.act_budget_used_by_id
                                             || ') returns ' || l_return_status
                                             || '  ledger_id=' || l_ledger_id);
            END IF;
            IF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
         END IF;

         --kdass 16-NOV-2005 bug 4728515 - for quota, bypass ledger check
         OPEN  c_check_quota (l_act_budgets_rec.budget_source_type, l_act_budgets_rec.budget_source_id);
         FETCH c_check_quota INTO l_is_quota;
         CLOSE c_check_quota;

         IF l_is_quota IS NULL THEN
            -- yzhao: R12 Oct 19 2005 No need to calculate functional currency if it is for marketing use
            IF l_ledger_id IS NULL THEN
               IF l_act_budgets_rec.budget_source_type NOT IN ('CAMP', 'CSCH', 'EVEO', 'EVEH', 'EONE') AND
                  l_act_budgets_rec.arc_act_budget_used_by NOT IN ('CAMP', 'CSCH', 'EVEO', 'EVEH', 'EONE') THEN
                  IF G_DEBUG THEN
                     ozf_utility_pvt.debug_message (   l_api_name
                                                 || ': create_act_budgets   ledger not found for '
                                                 || l_act_budgets_rec.arc_act_budget_used_by
                                                 || '  id('
                                                 || l_act_budgets_rec.act_budget_used_by_id);
                  END IF;
                  IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                     fnd_message.set_name ('OZF', 'OZF_NO_LEDGER_FOUND');
                     --Message OZF_NO_LEDGER_FOUND changed fix bug 5190932
                     --fnd_message.set_token('OBJECT_TYPE', l_act_budgets_rec.arc_act_budget_used_by);
                     --fnd_message.set_token('OBJECT_ID', l_act_budgets_rec.act_budget_used_by_id);
                     fnd_msg_pub.ADD;
                  END IF;
                  x_return_status            := fnd_api.g_ret_sts_error;
                  RAISE fnd_api.g_exc_error;
               END IF;
            ELSE


               --Added for bug 7030415,  l_act_util_rec.org_id is available. use it for time being.
               --Column approved_amount_fc is used in Offer's Performance cuecard.
               --get the conversion type. This doesn't get called in case of committed/planned amounts.

               OPEN c_get_conversion_type(l_act_util_rec.org_id);
               FETCH c_get_conversion_type INTO l_exchange_rate_type;
               CLOSE c_get_conversion_type;

               IF G_DEBUG THEN
                  ozf_utility_pvt.debug_message (   l_full_name
                                     || ' l_act_budgets_rec.exchange_rate_date4: ' || l_act_budgets_rec.exchange_rate_date);
               END IF;

              --For bug 7425189, get exchange date based on approval date
              IF l_act_budgets_rec.justification IN (l_fund_reconc_msg,l_act_bud_cst_msg)
                AND l_act_budgets_rec.exchange_rate_date IS NOT NULL
                AND l_act_budgets_rec.transfer_type = 'TRANSFER' THEN
                  l_exchange_rate_type := NULL;
                 ozf_utility_pvt.calculate_functional_currency(
                   p_from_amount        => l_act_budgets_rec.approved_amount
                  ,p_conv_date          => l_act_budgets_rec.exchange_rate_date
                  ,p_tc_currency_code   => l_act_budgets_rec.request_currency
                  ,p_ledger_id          => l_ledger_id
                  ,x_to_amount          => l_fc_amount
                  ,x_mrc_sob_type_code  => l_mrc_sob_type_code
                  ,x_fc_currency_code   => l_fc_currency_code
                  ,x_exchange_rate_type => l_exchange_rate_type
                  ,x_exchange_rate      => l_exchange_rate
                  ,x_return_status      => l_return_status);

              ELSE

               ozf_utility_pvt.calculate_functional_currency(
                   p_from_amount        => l_act_budgets_rec.approved_amount
                   ,p_conv_date         => l_act_budgets_rec.exchange_rate_date --bug 8532055
                  ,p_tc_currency_code   => l_act_budgets_rec.request_currency
                  ,p_ledger_id          => l_ledger_id
                  ,x_to_amount          => l_fc_amount
                  ,x_mrc_sob_type_code  => l_mrc_sob_type_code
                  ,x_fc_currency_code   => l_fc_currency_code
                  ,x_exchange_rate_type => l_exchange_rate_type
                  ,x_exchange_rate      => l_exchange_rate
                  ,x_return_status      => l_return_status);

              END IF;

               IF l_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
               ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;
            END IF;
         END IF;
      END IF;

      IF l_act_budgets_rec.transfer_type = 'UTILIZED'
      AND l_src_currency <> l_act_budgets_rec.request_currency THEN
         l_temp_request_amount := l_act_budgets_rec.request_amount;
         l_temp_approved_amount := l_act_budgets_rec.approved_amount;
         l_temp_aprvd_orig_amount := l_act_budgets_rec.approved_original_amount;

         IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_api_name||'l_temp_request_amount '|| l_temp_request_amount);
         ozf_utility_pvt.debug_message (   l_api_name||'l_temp_approved_amount '|| l_temp_approved_amount);
         ozf_utility_pvt.debug_message (   l_api_name||'l_temp_aprvd_orig_amount '|| l_temp_aprvd_orig_amount);
         ozf_utility_pvt.debug_message (   l_api_name||'src_curr_req_amt '|| l_act_budgets_rec.src_curr_req_amt);
         END IF;

         l_act_budgets_rec.request_amount := l_act_budgets_rec.src_curr_req_amt;
         l_act_budgets_rec.approved_original_amount := l_act_budgets_rec.src_curr_req_amt;
         l_act_budgets_rec.approved_amount := l_act_budgets_rec.src_curr_req_amt;
      END IF;

      INSERT INTO ozf_act_budgets
                  (activity_budget_id, -- standard who columns
                  last_update_date
                  , last_updated_by
                  , creation_date
                  ,created_by, last_update_login -- other columns
                  ,object_version_number
                  ,act_budget_used_by_id
                  ,arc_act_budget_used_by, budget_source_type
                  ,budget_source_id, transaction_type
                  ,request_amount, request_currency
                  ,request_date, user_status_id
                  ,status_code, approved_amount
                  ,approved_original_amount
                  ,approved_in_currency
                  ,approval_date, approver_id
                  ,spent_amount, partner_po_number
                  ,partner_po_date, partner_po_approver
                  ,posted_flag, adjusted_flag
                  ,parent_act_budget_id, contact_id
                  ,reason_code, transfer_type
                  ,requester_id
                  ,date_required_by
                  ,parent_source_id
                  ,parent_src_curr
                  ,parent_src_apprvd_amt
                  ,partner_holding_type
                  ,partner_address_id, vendor_id
                  ,owner_id
                  ,recal_flag
                  ,attribute_category, attribute1
                  ,attribute2, attribute3
                  ,attribute4, attribute5
                  ,attribute6, attribute7
                  ,attribute8, attribute9
                  ,attribute10, attribute11
                  ,attribute12, attribute13
                  ,attribute14, attribute15
                  ,approved_amount_fc
                  ,src_curr_request_amt
                  )
           VALUES (l_act_budgets_rec.activity_budget_id, -- standard who columns
                                                        SYSDATE, fnd_global.user_id, SYSDATE
                  ,fnd_global.user_id, fnd_global.conc_login_id, 1
                  , -- object_version_number
                   l_act_budgets_rec.act_budget_used_by_id
                  ,l_act_budgets_rec.arc_act_budget_used_by, l_act_budgets_rec.budget_source_type
                  ,l_act_budgets_rec.budget_source_id, l_act_budgets_rec.transaction_type
                  ,l_act_budgets_rec.request_amount, l_act_budgets_rec.request_currency
                  ,NVL (l_act_budgets_rec.request_date, SYSDATE), l_act_budgets_rec.user_status_id
                  ,NVL (l_act_budgets_rec.status_code, 'NEW'), l_act_budgets_rec.approved_amount
                  ,l_act_budgets_rec.approved_original_amount
                  ,l_act_budgets_rec.approved_in_currency
                  ,l_act_budgets_rec.approval_date
                  ,l_act_budgets_rec.approver_id
                  ,l_act_budgets_rec.spent_amount, l_act_budgets_rec.partner_po_number
                  ,l_act_budgets_rec.partner_po_date, l_act_budgets_rec.partner_po_approver
                  ,l_act_budgets_rec.posted_flag, l_act_budgets_rec.adjusted_flag
                  ,l_act_budgets_rec.parent_act_budget_id, l_act_budgets_rec.contact_id
                  ,l_act_budgets_rec.reason_code, l_act_budgets_rec.transfer_type
                  ,NVL (
                      l_act_budgets_rec.requester_id
                     ,ozf_utility_pvt.get_resource_id (fnd_global.user_id)
                   ) --l_act_budgets_rec.requester_id
                  ,l_act_budgets_rec.date_required_by
                  ,null --l_act_budgets_rec.parent_source_id
                  ,l_act_budgets_rec.parent_src_curr
                  ,l_act_budgets_rec.parent_src_apprvd_amt
                  ,l_act_budgets_rec.partner_holding_type
                  ,l_act_budgets_rec.partner_address_id, l_act_budgets_rec.vendor_id
                  ,l_act_budgets_rec.owner_id
                  ,l_act_budgets_rec.recal_flag
                  ,p_act_budgets_rec.attribute_category, p_act_budgets_rec.attribute1
                  ,p_act_budgets_rec.attribute2, p_act_budgets_rec.attribute3
                  ,p_act_budgets_rec.attribute4, p_act_budgets_rec.attribute5
                  ,p_act_budgets_rec.attribute6, p_act_budgets_rec.attribute7
                  ,p_act_budgets_rec.attribute8, p_act_budgets_rec.attribute9
                  ,p_act_budgets_rec.attribute10, p_act_budgets_rec.attribute11
                  ,p_act_budgets_rec.attribute12, p_act_budgets_rec.attribute13
                  ,p_act_budgets_rec.attribute14, p_act_budgets_rec.attribute15
                  ,l_fc_amount
                  ,l_act_budgets_rec.src_curr_req_amt);

      -- 02/22/2001 mpande Calls to ozf_object_attribute API was removed from this place.
      -- because the functionality has changed from Hornet release.
      -- set OUT value
      x_act_budget_id            := l_act_budgets_rec.activity_budget_id;

      IF l_act_budgets_rec.transfer_type = 'UTILIZED'
      AND l_src_currency <> l_act_budgets_rec.request_currency THEN

         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message (   l_api_name|| l_temp_request_amount);
            ozf_utility_pvt.debug_message (   l_api_name|| l_temp_approved_amount);
            ozf_utility_pvt.debug_message (   l_api_name|| l_temp_aprvd_orig_amount);
         END IF;

         l_act_budgets_rec.request_amount := l_temp_request_amount;
         l_act_budgets_rec.approved_original_amount := l_temp_aprvd_orig_amount;
         l_act_budgets_rec.approved_amount := l_temp_approved_amount;
      END IF;
      IF l_act_budgets_rec.justification IS NOT NULL AND l_act_budgets_rec.transfer_type <> 'UTILIZED' THEN
         OZF_ACTBUDGETRULES_PVT.create_note (
            p_activity_type=> 'FREQ'
           ,p_activity_id=> l_act_budgets_rec.activity_budget_id
           ,p_note=> l_act_budgets_rec.justification
           ,p_note_type=> 'AMS_JUSTIFICATION'
           ,p_user=> NVL (
                        l_act_budgets_rec.requester_id
                       ,ozf_utility_pvt.get_resource_id (fnd_global.user_id)
                     )
           ,x_msg_count=> x_msg_count
           ,x_msg_data=> x_msg_data
           ,x_return_status=> l_return_status
         );
      END IF;

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- update the fudn for release and reserve
      -- if the adjust_flag = 'Y' or null then only update the fund otherwise donot.
      -- during fund updating this flag is passed 'N'
      IF      l_act_budgets_rec.transfer_type IN ('RELEASE', 'RESERVE')
          AND NVL (l_act_budgets_rec.adjusted_flag, 'Y') = 'Y' THEN
         ozf_fund_request_apr_pvt.approve_holdback (
            p_commit=> fnd_api.g_false
           ,p_act_budget_id=> l_act_budget_id
           ,p_transfer_type=> l_act_budgets_rec.transfer_type
           ,p_transac_fund_id=> l_act_budgets_rec.budget_source_id
           ,p_requester_id=> l_act_budgets_rec.requester_id
           ,p_approver_id=> l_act_budgets_rec.requester_id
           ,p_requested_amount=> l_act_budgets_rec.request_amount
           ,x_return_status=> l_return_status
           ,x_msg_count=> x_msg_count
           ,x_msg_data=> x_msg_data
         );

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      -- 02/23/2001 mpande whenever user enters a amount as utlized
      -- For this amount a utilized record is entered in fund_utilized table
      --That means the budget is utilized . Budget Utlized for offers take place through orders
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_api_name
                                     || ': check items');
      END IF;

      -- 06/25/2001 mpande changed by mpande
      IF l_act_budgets_rec.status_code = 'APPROVED'
          AND l_act_budgets_rec.transfer_type NOT IN ('RELEASE', 'RESERVE')
          -- donot create a record in utilization for partners
          AND l_act_budgets_rec.budget_source_type <> 'PTNR'  THEN
         --added by feliu on 08/03/2005. only created utilization for UTILIZED.
         IF l_act_budgets_rec.transfer_type = 'UTILIZED' THEN
           ozf_fund_adjustment_pvt.create_fund_utilization (
            p_act_budget_rec=> l_act_budgets_rec
           ,x_return_status=> l_return_status
           ,x_msg_count=> x_msg_count
           ,x_msg_data=> x_msg_data
           ,p_act_util_rec => l_act_util_rec
           ,x_utilized_amount =>  x_utilized_amount
           ,x_utilization_id   => x_utilization_id --kdass - added for Bug 8726683
           );


         IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         END IF;
       END IF;

       IF (l_act_budgets_rec.arc_act_budget_used_by ='CAMP' AND l_act_budgets_rec.budget_source_type = 'CSCH') OR
         (l_act_budgets_rec.arc_act_budget_used_by ='EVEH' AND l_act_budgets_rec.budget_source_type = 'EVEO') OR
         (l_act_budgets_rec.arc_act_budget_used_by ='CAMP' AND l_act_budgets_rec.budget_source_type = 'OFFR')  THEN

          create_child_act_budget (
                  x_return_status      => l_return_status,
                  x_msg_count          =>  x_msg_count,
                  x_msg_data           => x_msg_data,
                  p_act_budgets_rec    => l_act_budgets_rec,
                  p_exchange_rate_type => l_exchange_rate_type

            );

         IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         END IF;

      END IF;


         process_approval (
            p_act_budget_rec=> l_act_budgets_rec
           ,x_act_budget_rec=> l_temp_rec
           ,x_return_status=> l_return_status
           ,x_msg_count=> x_msg_count
           ,x_msg_data=> x_msg_data
           ,p_mode    => 'CREATE'
         );

         IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;
     -- Add by feliu on 05/22/04 for referal.
      IF  l_act_budgets_rec.status_code =  'PENDING_VALIDATION'  THEN
             l_request_id := fnd_request.submit_request (
                            application   => 'OZF',
                            program       => 'OZFVALIELIG',
                            start_time    => sysdate,
                            argument1     => l_act_budgets_rec.act_budget_used_by_id,
                            argument2     =>'OFFR',
                            argument3     =>l_act_budgets_rec.activity_budget_id
                         );
            COMMIT;
      END IF;

      /******** 01/03/2002 mpande added for partner requirement -- to send a notification to the vendor****/
      IF l_act_budgets_rec.transfer_type = 'REQUEST' AND  l_act_budgets_rec.vendor_id IS NOT NULL
        THEN
         ozf_budgetapproval_pvt.notify_vendor (
           p_act_budget_rec=> l_act_budgets_rec
           ,x_return_status=> l_return_status
           ,x_msg_count=> x_msg_count
           ,x_msg_data=> x_msg_data
         );

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;
      /***** END OF Addition for Partner ********/
      --
      -- END of API body.
      --
      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit) THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count AND IF count is 1, get message info.
      fnd_msg_pub.count_and_get (
         p_count=> x_msg_count
        ,p_data=> x_msg_data
        ,p_encoded=> fnd_api.g_false
      );
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO create_act_budgets_pvt;
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO create_act_budgets_pvt;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN OTHERS THEN
         ROLLBACK TO create_act_budgets_pvt;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_package_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
   END create_act_budgets;


/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Update_Act_Budgets
--
-- PURPOSE
--   This procedure is to update a Budget record that satisfy caller needs
--
-- HISTORY
-- 04/12/2000  sugupta  CREATED
-- 14-Aug-2000 choang   Modified for spec signature change.
-- 22-Feb-2001 mpande   Modified for Hornet changes.
-- End of Comments
/*****************************************************************************************/
   PROCEDURE update_act_budgets (
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,p_act_budgets_rec    IN       act_budgets_rec_type
   ) IS
      l_utilized_amount    NUMBER;
   BEGIN
      update_act_budgets (
         p_api_version=> p_api_version
        ,p_init_msg_list=> p_init_msg_list
        ,p_commit=> p_commit
        ,p_validation_level=> p_validation_level
        ,x_return_status=> x_return_status
        ,x_msg_count=> x_msg_count
        ,x_msg_data=> x_msg_data
        ,p_act_budgets_rec=> p_act_budgets_rec
        ,p_parent_process_flag=> fnd_api.g_false
        ,p_parent_process_key=> fnd_api.g_miss_char
        ,p_parent_context=> fnd_api.g_miss_char
        ,p_parent_approval_flag=> fnd_api.g_false
        ,p_continue_flow=> fnd_api.g_false
        ,p_child_approval_flag=> fnd_api.g_false
        -- 10/22/2001   mpande    Changed code different owner allocation bug
        ,p_requestor_owner_flag  => 'N'
        ,x_utilized_amount => l_utilized_amount
      );
   END update_act_budgets;

   /*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Update_Act_Budgets
--
-- PURPOSE
--   This procedure is overloaded to take care of fund child approval
--
-- HISTORY
-- 05/22/2001  mpande  CREATED
-- End of Comments
/*****************************************************************************************/
   PROCEDURE update_act_budgets (
      p_api_version           IN       NUMBER
     ,p_init_msg_list         IN       VARCHAR2 := fnd_api.g_false
     ,p_commit                IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,x_msg_count             OUT NOCOPY      NUMBER
     ,x_msg_data              OUT NOCOPY      VARCHAR2
     ,p_act_budgets_rec       IN       act_budgets_rec_type
     ,p_child_approval_flag   IN       VARCHAR2
      -- 10/22/2001   mpande    Changed code different owner allocation bug
     ,p_requestor_owner_flag  IN       VARCHAR2 := 'N'
     ,p_act_util_rec          IN       act_util_rec_type := NULL
   ) IS
     l_utilized_amount        NUMBER;
   BEGIN
      update_act_budgets (
         p_api_version=> p_api_version
        ,p_init_msg_list=> p_init_msg_list
        ,p_commit=> p_commit
        ,p_validation_level=> p_validation_level
        ,x_return_status=> x_return_status
        ,x_msg_count=> x_msg_count
        ,x_msg_data=> x_msg_data
        ,p_act_budgets_rec=> p_act_budgets_rec
        ,p_child_approval_flag=> p_child_approval_flag
        ,p_parent_process_flag=> fnd_api.g_false
        ,p_parent_process_key=> fnd_api.g_miss_char
        ,p_parent_context=> fnd_api.g_miss_char
        ,p_parent_approval_flag=> fnd_api.g_false
        ,p_continue_flow=> fnd_api.g_false
        -- 10/22/2001   mpande    Changed code different owner allocation bug
        ,p_requestor_owner_flag  => p_requestor_owner_flag
        ,p_act_util_rec   => p_act_util_rec
        ,x_utilized_amount => l_utilized_amount
      );
   END update_act_budgets;


  /****************************************************************************
   -- yzhao: 06/21/2004  added x_utilized_amount to return actual utilized amount
   */
   PROCEDURE update_act_budgets (
      p_api_version           IN       NUMBER
     ,p_init_msg_list         IN       VARCHAR2 := fnd_api.g_false
     ,p_commit                IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,x_msg_count             OUT NOCOPY      NUMBER
     ,x_msg_data              OUT NOCOPY      VARCHAR2
     ,p_act_budgets_rec       IN       act_budgets_rec_type
     ,p_child_approval_flag   IN       VARCHAR2
      -- 10/22/2001   mpande    Changed code different owner allocation bug
     ,p_requestor_owner_flag  IN       VARCHAR2 := 'N'
     ,p_act_util_rec          IN       act_util_rec_type := NULL
     ,x_utilized_amount       OUT NOCOPY      NUMBER        -- yzhao: added 06/21/2004 to return actual utilized amount
   ) IS
   BEGIN
      update_act_budgets (
         p_api_version=> p_api_version
        ,p_init_msg_list=> p_init_msg_list
        ,p_commit=> p_commit
        ,p_validation_level=> p_validation_level
        ,x_return_status=> x_return_status
        ,x_msg_count=> x_msg_count
        ,x_msg_data=> x_msg_data
        ,p_act_budgets_rec=> p_act_budgets_rec
        ,p_child_approval_flag=> p_child_approval_flag
        ,p_parent_process_flag=> fnd_api.g_false
        ,p_parent_process_key=> fnd_api.g_miss_char
        ,p_parent_context=> fnd_api.g_miss_char
        ,p_parent_approval_flag=> fnd_api.g_false
        ,p_continue_flow=> fnd_api.g_false
        -- 10/22/2001   mpande    Changed code different owner allocation bug
        ,p_requestor_owner_flag  => p_requestor_owner_flag
        ,p_act_util_rec   => p_act_util_rec
        ,x_utilized_amount => x_utilized_amount
      );
   END update_act_budgets;


/****************************************************************************/
-- Start of Comments
--
--    API name    : Update_Act_Budgets
--    Type        : Private
--    Function    : Update a row in OZF_ACT_Budgets table
--    Note        : This overloaded procedure is to be called from
--                  Workflow to maintain the context.
---- 29-JUNE-2004  feliu   added.
-- End Of Comments
/****************************************************************************/
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
   ) IS
    l_utilized_amount        NUMBER;
   BEGIN
      update_act_budgets (
         p_api_version=> p_api_version
        ,p_init_msg_list=> p_init_msg_list
        ,p_commit=> p_commit
        ,p_validation_level=> p_validation_level
        ,x_return_status=> x_return_status
        ,x_msg_count=> x_msg_count
        ,x_msg_data=> x_msg_data
        ,p_act_budgets_rec=> p_act_budgets_rec
        ,p_child_approval_flag=> p_child_approval_flag
        ,p_parent_process_flag=>p_parent_process_flag
        ,p_parent_process_key=>p_parent_process_key
        ,p_parent_context=> p_parent_context
        ,p_parent_approval_flag=> p_parent_approval_flag
        ,p_continue_flow=> p_continue_flow
        ,p_requestor_owner_flag  => p_requestor_owner_flag
        ,p_act_util_rec   => p_act_util_rec
        ,x_utilized_amount => l_utilized_amount
      );
   END update_act_budgets;

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
   ) IS
    l_utilization_id        NUMBER;
   BEGIN

      --kdass - added for Bug 8726683
      update_act_budgets (
         p_api_version=> p_api_version
        ,p_init_msg_list=> p_init_msg_list
        ,p_commit=> p_commit
        ,p_validation_level=> p_validation_level
        ,x_return_status=> x_return_status
        ,x_msg_count=> x_msg_count
        ,x_msg_data=> x_msg_data
        ,p_act_budgets_rec=> p_act_budgets_rec
        ,p_child_approval_flag=> p_child_approval_flag
        ,p_parent_process_flag=>p_parent_process_flag
        ,p_parent_process_key=>p_parent_process_key
        ,p_parent_context=> p_parent_context
        ,p_parent_approval_flag=> p_parent_approval_flag
        ,p_continue_flow=> p_continue_flow
        ,p_requestor_owner_flag  => p_requestor_owner_flag
        ,p_act_util_rec   => p_act_util_rec
        ,x_utilized_amount => x_utilized_amount
        ,x_utilization_id  => l_utilization_id
      );
   END update_act_budgets;

/****************************************************************************/
-- Start of Comments
--
--    API name    : Update_Act_Budgets
--    Type        : Private
--    Function    : Update a row in OZF_ACT_Budgets table
--    Note        : This overloaded procedure is to be called from
--                  Workflow to maintain the context.
---- 22-Feb-2001 mpande   Modified for Hornet changes.
--   05/22/2001  mpande   Signature changes for fund child approval
--   08/26/2002  feliu    added status of "PENDING_VALIDATION"
-- End Of Comments
/****************************************************************************/
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
     ,x_utilized_amount        OUT NOCOPY     NUMBER                -- yzhao: 06/21/2004 added to return actual utilized amount\
     ,x_utilization_id         OUT NOCOPY     NUMBER
   ) IS
      l_api_name            CONSTANT VARCHAR2 (30)               := 'Update_Act_Budgets';
      l_api_version         CONSTANT NUMBER                      := 1.0;
      l_status_type         CONSTANT VARCHAR2 (30)               := 'OZF_BUDGETSOURCE_STATUS';
      l_rejected_code       CONSTANT VARCHAR2 (30)               := 'REJECTED';
      -- Status Local Variables
      l_return_status                VARCHAR2 (1); -- Return value from procedures
      l_dummy                        NUMBER;
      l_act_budgets_rec              act_budgets_rec_type;
      l_temp_rec                     act_budgets_rec_type;
      l_act_util_rec                 act_util_rec_type      := p_act_util_rec;
      l_old_status_code                  VARCHAR2 (30); -- Used to capture the current status code
      l_fund_rec                     ozf_funds_pvt.fund_rec_type;
      l_fund_object_version_number   NUMBER;
      l_fund_currency_tc             VARCHAR2 (15); -- a fund's transactional currency code
      l_fund_planned_amount          NUMBER;
      l_request_id                   NUMBER;
      l_approver_id                  NUMBER;
      l_is_requestor_owner           VARCHAR2 (2);
      l_fund_transfer_flag           VARCHAR2 (1)                := 'N';
      l_old_approved_amount          NUMBER;
      l_start_flow_flag            VARCHAR2 (1) := 'N';
      l_new_status_id              NUMBER;
      l_reject_status_id           NUMBER;
      l_exceed_flag            VARCHAR2 (1)
                                          := NVL (fnd_profile.VALUE ('OZF_COMM_BUDGET_EXCEED'), 'N');

      CURSOR c_current_status IS
         SELECT status_code,  approved_amount, parent_src_apprvd_amt
           FROM ozf_act_budgets
          WHERE activity_budget_id = p_act_budgets_rec.activity_budget_id;

      --
      -- the planned_amt will be used in approval submission,
      -- approval and rejection.  the committed_amt will only
      -- be used in the approval.
      CURSOR c_fund (l_fund_id IN NUMBER) IS
         SELECT object_version_number, currency_code_tc, planned_amt
           FROM ozf_funds_all_b
          WHERE fund_id = l_fund_id;

      CURSOR c_check_quota (p_type IN VARCHAR2, p_fund_id IN NUMBER) IS
         SELECT 1
         FROM  ozf_funds_all_b
         WHERE 'FUND' = p_type
           AND fund_type = 'QUOTA'
           AND fund_id = p_fund_id;

      l_fc_amount                  NUMBER;
      l_set_of_books_id            NUMBER;
      l_mrc_sob_type_code          VARCHAR2(30);
      l_fc_currency_code           VARCHAR2(150);
      l_exchange_rate_type         VARCHAR2(30) :=  FND_API.G_MISS_CHAR; --Added for bug 7030415
      l_exchange_rate              NUMBER;
      -- mpande for changed checkbook view 12/17/2001
      l_src_curr_request_amt       NUMBER;
      l_src_currency               VARCHAR2(150);
      l_rate                       NUMBER;
      l_old_parent_src_amt         NUMBER;
      l_check_validation   VARCHAR2(50) := fnd_profile.value('OZF_CHECK_MKTG_PROD_ELIG');
      l_offer_status               VARCHAR2(30);
      l_objfundsum_rec             ozf_objfundsum_pvt.objfundsum_rec_type := NULL;
      l_univ_amount                NUMBER;
      l_objfundsum_id              NUMBER;
      l_ledger_id                  NUMBER;
      l_ledger_name                VARCHAR2(30);
      l_is_quota                   NUMBER := NULL;

      --nirprasa, for bug 7425189
      l_fund_reconc_msg            VARCHAR2(4000);
      l_act_bud_cst_msg            VARCHAR2(4000);

      --nirprasa, added for multi currency enhancement
      l_transaction_currency       VARCHAR2(15);
--feliu
/*      CURSOR c_offer_status IS
         SELECT status_code
         FROM ozf_offers
         WHERE qp_list_header_id = p_act_budgets_rec.act_budget_used_by_id;
      fix bug 3116943 by feliu 08/28/03
*/
      CURSOR c_offer_status(l_qp_header_id IN NUMBER) IS
         SELECT status_code
         FROM ozf_offers
         WHERE qp_list_header_id = l_qp_header_id;

      -- yzhao: R12 insert/update ozf_object_fund_summary table
      CURSOR c_get_objfundsum_rec(p_object_type IN VARCHAR2, p_object_id IN NUMBER, p_fund_id IN NUMBER) IS
         SELECT objfundsum_id
              , object_version_number
              , planned_amt
              , plan_curr_planned_amt
              , univ_curr_planned_amt
         FROM   ozf_object_fund_summary
         WHERE  object_type = p_object_type
         AND    object_id = p_object_id
         AND    fund_id = p_fund_id;

       -- Added for bug 7030415
       CURSOR c_get_conversion_type( p_org_id IN NUMBER) IS
          SELECT exchange_rate_type
          FROM   ozf_sys_parameters_all
          WHERE  org_id = p_org_id;

       l_temp_request_amount  NUMBER;
       l_temp_approved_amount  NUMBER;
       l_temp_aprvd_orig_amount  NUMBER;

   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_act_budgets_pvt;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_package_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status            := fnd_api.g_ret_sts_success;
      --
      -- API body
      --
     complete_act_budgets_rec (p_act_budgets_rec, l_act_budgets_rec);
      -- we have to set the currency always because the activity currency might change
      -- after creation of the budgets
      --nirprasa, get the transaction currency for null currency offers
     IF l_act_budgets_rec.request_currency IS NULL
     OR l_act_budgets_rec.request_currency = FND_API.G_MISS_CHAR THEN
     l_act_budgets_rec.request_currency :=
            get_object_currency (
               l_act_budgets_rec.arc_act_budget_used_by
              ,l_act_budgets_rec.act_budget_used_by_id
              ,l_return_status
            );
     END IF;

     l_transaction_currency := l_act_util_rec.plan_currency_code;

      IF l_act_budgets_rec.request_currency <> l_transaction_currency
        AND l_act_budgets_rec.arc_act_budget_used_by = 'OFFR' THEN
          l_act_budgets_rec.request_currency := l_transaction_currency;
      END IF;
     --nirprasa, for bug 7425189
     l_fund_reconc_msg := fnd_message.get_string ('OZF', 'OZF_FUND_RECONCILE');
     l_act_bud_cst_msg := fnd_message.get_string ('OZF', 'OZF_ACT_BUDG_CST_UTIL');

     IF G_DEBUG THEN
        ozf_utility_pvt.debug_message ('request_amount '||l_act_budgets_rec.request_amount);
        ozf_utility_pvt.debug_message('plan_curr_amount '|| p_act_util_rec.plan_curr_amount);
     END IF;

      /*12/19/2001 mpande Added code for UI requirement , when a object is transfering money he would request in
       object's currency and not source currency since here the source is the object, in case of transfer */
     IF l_act_budgets_rec.transfer_type = 'TRANSFER' THEN
         l_act_budgets_rec.approved_in_currency :=
            get_object_currency (
               l_act_budgets_rec.budget_source_type
              ,l_act_budgets_rec.budget_source_id
              ,l_return_status
            );
            IF G_DEBUG THEN
               ozf_utility_pvt.debug_message ('approved_in_currency '||l_act_budgets_rec.approved_in_currency);
               ozf_utility_pvt.debug_message ('request_currency '||l_act_budgets_rec.request_currency);
               ozf_utility_pvt.debug_message ('request_amount '||l_act_budgets_rec.request_amount);
               ozf_utility_pvt.debug_message ('src_curr_req_amt '||l_act_budgets_rec.src_curr_req_amt);
               ozf_utility_pvt.debug_message ('budget_source_type '||l_act_budgets_rec.budget_source_type);
               ozf_utility_pvt.debug_message ('l_transaction_currency '||l_transaction_currency);
            END IF;
         -- do this only if it is null because , in other case request amount should be passed correctly
         IF p_act_budgets_rec.request_amount IS NULL AND p_act_budgets_rec.src_curr_req_amt IS NOT NULL
            AND p_act_budgets_rec.src_curr_req_amt <> FND_API.g_miss_num THEN

            IF l_act_budgets_rec.request_currency = l_act_budgets_rec.approved_in_currency THEN
               -- don't need to convert if currencies are equal
               l_act_budgets_rec.request_amount := l_act_budgets_rec.src_curr_req_amt;
            ELSE
               -- convert the src_curr_request amount to the act_used_by  currency request amount.
               --This code will not be executed for transfer_type='UTILIZED'
               --In case of util/earned amt creation.

               IF G_DEBUG THEN
                  ozf_utility_pvt.debug_message (   l_api_name
                                     || ' l_act_budgets_rec.exchange_rate_date1: ' || l_act_budgets_rec.exchange_rate_date);
               END IF;

               ozf_utility_pvt.convert_currency (
                  x_return_status => l_return_status
                 ,p_from_currency => l_act_budgets_rec.approved_in_currency
                 ,p_to_currency   => l_act_budgets_rec.request_currency
                 ,p_conv_date     => l_act_budgets_rec.exchange_rate_date --bug 7425189, 8532055
                 ,p_from_amount   => l_act_budgets_rec.src_curr_req_amt
                 ,x_to_amount     => l_act_budgets_rec.request_amount
               );

               /*

                --Added for bug 7425189
                IF l_act_budgets_rec.justification IN (l_fund_reconc_msg,l_act_bud_cst_msg)
                AND l_act_budgets_rec.exchange_rate_date IS NOT NULL THEN

               ozf_utility_pvt.convert_currency (
                  x_return_status=> l_return_status
                 ,p_from_currency=> l_act_budgets_rec.approved_in_currency
                 ,p_to_currency=> l_act_budgets_rec.request_currency
                 ,p_conv_date=> l_act_budgets_rec.exchange_rate_date
                 ,p_from_amount=> l_act_budgets_rec.src_curr_req_amt
                 ,x_to_amount=> l_act_budgets_rec.request_amount
               );
               ELSE
                ozf_utility_pvt.convert_currency (
                  x_return_status=> l_return_status
                 ,p_from_currency=> l_act_budgets_rec.approved_in_currency
                 ,p_to_currency=> l_act_budgets_rec.request_currency
                 ,p_from_amount=> l_act_budgets_rec.src_curr_req_amt
                 ,x_to_amount=> l_act_budgets_rec.request_amount
               );
               END IF;
               */

               IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
               END IF;
            END IF;
         END IF;
     END IF;
     /* End OF CHange mpande 12/19/2001 */

      IF l_act_budgets_rec.request_currency IS NULL THEN
         ozf_utility_pvt.error_message ('OZF_ACT_BUDG_NO_CURRENCY');
         x_return_status            := fnd_api.g_ret_sts_error;
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF l_act_budgets_rec.user_status_id IS NULL THEN
         l_act_budgets_rec.user_status_id :=
             ozf_utility_pvt.get_default_user_status (l_status_type, l_act_budgets_rec.status_code);
      ELSE
         l_act_budgets_rec.status_code :=
                          ozf_utility_pvt.get_system_status_code (l_act_budgets_rec.user_status_id);
      END IF;

      -- status rules for updating replace the record with one which
      -- only allows update of specific fields according to the status of the budget
      -- source line.  User can only drive the  approval process through status.
      OPEN c_current_status;
      FETCH c_current_status INTO l_old_status_code, l_old_approved_amount,l_old_parent_src_amt;

      IF c_current_status%NOTFOUND THEN
         CLOSE c_current_status;
         ozf_utility_pvt.error_message ('OZF_API_RECORD_NOT_FOUND');
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      CLOSE c_current_status;



      IF l_old_status_code = 'CLOSED' THEN
         ozf_utility_pvt.error_message ('OZF_ACT_BUDG_REJECTED');
         RAISE fnd_api.g_exc_error;
      ELSIF l_old_status_code = 'REJECTED' THEN
         ozf_utility_pvt.error_message ('OZF_ACT_BUDG_REJECTED');
         RAISE fnd_api.g_exc_error;
      --
      -- Cases of valid approval:
      --    1) WF approval process responds to request to APPROVE, in which case, old status
      --       equals PENDING and new status equals APPROVED.
      --    2) No WF approval requried, in which case, approved_in_currency and approved_original_amount
      --       have values.
      ELSIF (    (l_old_status_code = 'PENDING' OR l_old_status_code = 'PENDING_VALIDATION')
             AND l_act_budgets_rec.status_code = 'APPROVED'
            ) THEN
        --for pending validation, need pass approved_in_currency.fixed bug 2853987 by feliu.

         IF l_old_status_code = 'PENDING_VALIDATION' THEN
            --l_act_budgets_rec.approved_in_currency := l_act_budgets_rec.request_currency;
            --fix bug 3354280 by feliu on 02/07/04
        l_act_budgets_rec.approved_in_currency :=get_object_currency (
                                             l_act_budgets_rec.budget_source_type
                                            ,l_act_budgets_rec.budget_source_id
                                            ,l_return_status
                                          );
     END IF;
     -- The WF approval process will make a call to
         -- the update API with a status of APPROVED
         process_approval (
            p_act_budget_rec=> l_act_budgets_rec
           ,x_act_budget_rec=> l_temp_rec
           ,x_return_status=> l_return_status
           ,x_msg_count=> x_msg_count
           ,x_msg_data=> x_msg_data
         );

         IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         END IF;

         complete_act_budgets_rec (l_temp_rec, l_act_budgets_rec);
      ELSIF      l_old_status_code = 'PENDING'
             AND l_act_budgets_rec.status_code = 'REJECTED' THEN
         IF l_act_budgets_rec.budget_source_type = 'FUND'  AND l_act_budgets_rec.arc_act_budget_used_by <> 'FUND'THEN
           --- fix bug 4174002  to exclude budget transfer since not planned_amt  exists for pending status.
            -- if the budget source is a fund, then the fund's planned amount must be decreased
            -- by the request_amount during approval submission.
            ozf_funds_pvt.init_fund_rec (l_fund_rec);
            OPEN c_fund (l_act_budgets_rec.budget_source_id);
            FETCH c_fund INTO l_fund_object_version_number
                             ,l_fund_currency_tc
                             ,l_fund_planned_amount;
            CLOSE c_fund;
            l_fund_rec.fund_id         := l_act_budgets_rec.budget_source_id;
            l_fund_rec.object_version_number := l_fund_object_version_number;

            IF l_act_budgets_rec.request_currency = l_fund_currency_tc THEN
               -- don't need to convert if currencies are equal
               l_fund_rec.planned_amt     := l_act_budgets_rec.request_amount;
            ELSE
               -- convert the request amount to the fund's  currency.  the planned amount for a fund
               -- is stored in the table as a value based on the transactional currency, so the
               -- request amount must also be based on the  same currency.
               ozf_utility_pvt.convert_currency (
                  x_return_status=> l_return_status
                 ,p_from_currency=> l_act_budgets_rec.request_currency
                 ,p_to_currency=> l_fund_currency_tc
                 ,p_from_amount=> l_act_budgets_rec.request_amount
                 ,x_to_amount=> l_fund_rec.planned_amt
               );

               IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
               END IF;
            END IF;

            -- R12: yzhao BEGIN ozf_object_fund_summary decrease planned_amount
            IF g_universal_currency = l_act_budgets_rec.request_currency THEN
               l_univ_amount := l_act_budgets_rec.request_amount;
            ELSIF g_universal_currency = l_fund_currency_tc THEN
               l_univ_amount := l_fund_rec.planned_amt;
            ELSE
               ozf_utility_pvt.convert_currency (
                     x_return_status=> l_return_status
                    ,p_from_currency=> l_act_budgets_rec.request_currency
                    ,p_to_currency=> g_universal_currency
                    ,p_from_amount=> l_act_budgets_rec.request_amount
                    ,x_to_amount=> l_univ_amount
               );

               IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
               END IF;
            END IF;

            l_objfundsum_rec := NULL;
            OPEN c_get_objfundsum_rec(l_act_budgets_rec.arc_act_budget_used_by
                                    , l_act_budgets_rec.act_budget_used_by_id
                                    , l_act_budgets_rec.budget_source_id);
            FETCH c_get_objfundsum_rec INTO l_objfundsum_rec.objfundsum_id
                                          , l_objfundsum_rec.object_version_number
                                          , l_objfundsum_rec.planned_amt
                                          , l_objfundsum_rec.plan_curr_planned_amt
                                          , l_objfundsum_rec.univ_curr_planned_amt;
            IF c_get_objfundsum_rec%NOTFOUND THEN
               CLOSE c_get_objfundsum_rec;
               IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                  fnd_message.set_name('OZF', 'OZF_OBJFUNDSUM_RECORD_NOT_FOUND');
                  fnd_msg_pub.add;
               END IF;
               RAISE fnd_api.g_exc_error;
            END IF;
            CLOSE c_get_objfundsum_rec;
            l_objfundsum_rec.planned_amt := NVL(l_objfundsum_rec.planned_amt, 0) + NVL (l_fund_rec.planned_amt, 0);
            l_objfundsum_rec.plan_curr_planned_amt := NVL(l_objfundsum_rec.plan_curr_planned_amt, 0)
                                                    + NVL(l_act_budgets_rec.request_amount, 0);
            l_objfundsum_rec.univ_curr_planned_amt := NVL(l_objfundsum_rec.univ_curr_planned_amt, 0) + NVL(l_univ_amount, 0);
            ozf_objfundsum_pvt.update_objfundsum(
                   p_api_version                => 1.0,
                   p_init_msg_list              => Fnd_Api.G_FALSE,
                   p_validation_level           => Fnd_Api.G_VALID_LEVEL_NONE,
                   p_objfundsum_rec             => l_objfundsum_rec,
                   x_return_status              => l_return_status,
                   x_msg_count                  => x_msg_count,
                   x_msg_data                   => x_msg_data
            );
            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            END IF;
            -- R12: yzhao END ozf_object_fund_summary decrease planned_amount

            -- subtract the request amount, l_fund_rec.planned_amt, to the
            -- fund's planned amount, l_fund_planned_amount.
            l_fund_rec.planned_amt     :=   l_fund_planned_amount
                                          - l_fund_rec.planned_amt;
            ozf_funds_pvt.update_fund (
               p_api_version=> 1.0
              ,p_init_msg_list=> fnd_api.g_false
              , -- allow the calling API to handle
               p_commit=> fnd_api.g_false
              , -- allow the calling API to handle
               p_validation_level=> p_validation_level
              ,x_return_status=> l_return_status
              ,x_msg_count=> x_msg_count
              ,x_msg_data=> x_msg_data
              ,p_fund_rec=> l_fund_rec
              ,p_mode=> g_cons_fund_mode
            );

            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            END IF;

         END IF; -- if source type = FUND
      ELSIF      (l_old_status_code = 'PENDING' OR l_old_status_code = 'PENDING_VALIDATION')
             AND l_act_budgets_rec.status_code = 'NEW' THEN
         -- an error occurred during the approval process, revert back to NEW
         -- if budget source is a FUND, then revert the planned amount.
         init_act_budgets_rec (l_temp_rec);
         revert_approval (
            l_act_budgets_rec
           ,l_temp_rec
           ,x_return_status
           ,x_msg_count
           ,x_msg_data
         );
         complete_act_budgets_rec (l_temp_rec, l_act_budgets_rec);
      ELSIF l_old_status_code = 'NEW' THEN
         -- new budget source lines can get a new requested budget amount

         init_act_budgets_rec (l_temp_rec);
         l_temp_rec.activity_budget_id := l_act_budgets_rec.activity_budget_id;
         l_temp_rec.object_version_number := l_act_budgets_rec.object_version_number;
         l_temp_rec.spent_amount    := l_act_budgets_rec.spent_amount;
         l_temp_rec.request_amount  := l_act_budgets_rec.request_amount;
         l_temp_rec.date_required_by := l_act_budgets_rec.date_required_by;
         l_temp_rec.justification   := l_act_budgets_rec.justification;
         l_temp_rec.reason_code     := l_act_budgets_rec.reason_code;
         l_temp_rec.partner_holding_type := l_act_budgets_rec.partner_holding_type;
         l_temp_rec.partner_address_id := l_act_budgets_rec.partner_address_id;
         l_temp_rec.vendor_id       := l_act_budgets_rec.vendor_id;
         l_temp_rec.budget_source_id       := l_act_budgets_rec.budget_source_id;
         l_temp_rec.comment   := l_act_budgets_rec.comment;
         l_temp_rec.partner_po_number   := l_act_budgets_rec.partner_po_number;
         l_temp_rec.owner_id   := l_act_budgets_rec.owner_id;
         l_temp_rec.act_budget_used_by_id := l_act_budgets_rec.act_budget_used_by_id;
         l_temp_rec.arc_act_budget_used_by := l_act_budgets_rec.arc_act_budget_used_by;
         l_temp_rec.budget_source_type       := l_act_budgets_rec.budget_source_type;
     --
         -- changing status from NEW to APPROVED is equivalent to submitting for approval.
         IF l_act_budgets_rec.status_code = 'APPROVED' THEN
            l_temp_rec.status_code     := 'PENDING';

            IF      l_act_budgets_rec.budget_source_type = 'FUND'
                AND l_act_budgets_rec.arc_act_budget_used_by <> 'FUND' THEN
               -- if the budget source is a fund, then the fund's planned amount must be incremented
               -- by the request_amount during approval submission.
               ozf_funds_pvt.init_fund_rec (l_fund_rec);
               OPEN c_fund (l_act_budgets_rec.budget_source_id);
               FETCH c_fund INTO l_fund_object_version_number
                                ,l_fund_currency_tc
                                ,l_fund_planned_amount;
               CLOSE c_fund;
               l_fund_rec.fund_id         := l_act_budgets_rec.budget_source_id;
               l_fund_rec.object_version_number := l_fund_object_version_number;

               IF l_act_budgets_rec.request_currency = l_fund_currency_tc THEN
                  -- don't need to convert if currencies are equal
                  l_fund_rec.planned_amt     := l_act_budgets_rec.request_amount;
               ELSE
                  -- convert the request amount to the fund's currency.  the planned amount for a fund
                  -- is stored in the table as a value based on the transactional currency, so the
                  -- request amount must also be based on the same currency.

                  ozf_utility_pvt.convert_currency (
                     x_return_status=> l_return_status
                    ,p_from_currency=> l_act_budgets_rec.request_currency
                    ,p_to_currency=> l_fund_currency_tc
                    ,p_from_amount=> l_act_budgets_rec.request_amount
                    ,x_to_amount=> l_fund_rec.planned_amt
                  );

                  IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                     RAISE fnd_api.g_exc_unexpected_error;
                  ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                     RAISE fnd_api.g_exc_error;
                  END IF;
               END IF;

               -- R12: yzhao BEGIN ozf_object_fund_summary increase planned_amount
               IF g_universal_currency = l_act_budgets_rec.request_currency THEN
                  l_univ_amount := l_act_budgets_rec.request_amount;
               ELSIF g_universal_currency = l_fund_currency_tc THEN
                  l_univ_amount := l_fund_rec.planned_amt;
               ELSE
                  ozf_utility_pvt.convert_currency (
                     x_return_status=> l_return_status
                    ,p_from_currency=> l_act_budgets_rec.request_currency
                    ,p_to_currency=> g_universal_currency
                    ,p_from_amount=> l_act_budgets_rec.request_amount
                    ,x_to_amount=> l_univ_amount
                  );

                  IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                     RAISE fnd_api.g_exc_unexpected_error;
                  ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                     RAISE fnd_api.g_exc_error;
                  END IF;
               END IF;

               l_objfundsum_rec := NULL;
               OPEN c_get_objfundsum_rec(l_act_budgets_rec.arc_act_budget_used_by
                                       , l_act_budgets_rec.act_budget_used_by_id
                                       , l_act_budgets_rec.budget_source_id);
               FETCH c_get_objfundsum_rec INTO l_objfundsum_rec.objfundsum_id
                                             , l_objfundsum_rec.object_version_number
                                             , l_objfundsum_rec.planned_amt
                                             , l_objfundsum_rec.plan_curr_planned_amt
                                             , l_objfundsum_rec.univ_curr_planned_amt;
               CLOSE c_get_objfundsum_rec;
               l_objfundsum_rec.fund_id := l_act_budgets_rec.budget_source_id;
               l_objfundsum_rec.fund_currency := l_fund_currency_tc;
               l_objfundsum_rec.object_type := l_act_budgets_rec.arc_act_budget_used_by;
               l_objfundsum_rec.object_id := l_act_budgets_rec.act_budget_used_by_id;
               l_objfundsum_rec.object_currency := l_act_budgets_rec.request_currency;
               l_objfundsum_rec.planned_amt := NVL(l_objfundsum_rec.planned_amt, 0) + NVL (l_fund_rec.planned_amt, 0);
               l_objfundsum_rec.plan_curr_planned_amt := NVL(l_objfundsum_rec.plan_curr_planned_amt, 0)
                                                       + NVL(l_act_budgets_rec.request_amount, 0);
               l_objfundsum_rec.univ_curr_planned_amt := NVL(l_objfundsum_rec.univ_curr_planned_amt, 0) + NVL(l_univ_amount, 0);
               IF l_objfundsum_rec.objfundsum_id IS NULL THEN
                   ozf_objfundsum_pvt.create_objfundsum(
                       p_api_version                => 1.0,
                       p_init_msg_list              => Fnd_Api.G_FALSE,
                       p_validation_level           => Fnd_Api.G_VALID_LEVEL_NONE,
                       p_objfundsum_rec             => l_objfundsum_rec,
                       x_return_status              => l_return_status,
                       x_msg_count                  => x_msg_count,
                       x_msg_data                   => x_msg_data,
                       x_objfundsum_id              => l_objfundsum_id
                   );
               ELSE
                   ozf_objfundsum_pvt.update_objfundsum(
                       p_api_version                => 1.0,
                       p_init_msg_list              => Fnd_Api.G_FALSE,
                       p_validation_level           => Fnd_Api.G_VALID_LEVEL_NONE,
                       p_objfundsum_rec             => l_objfundsum_rec,
                       x_return_status              => l_return_status,
                       x_msg_count                  => x_msg_count,
                       x_msg_data                   => x_msg_data
                   );
               END IF;
               IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
               END IF;
               -- R12: yzhao END insert/update ozf_object_fund_summary table for planned_amount

               -- increase fund's planned amount by the new request amount
               l_fund_rec.planned_amt     :=
                                      NVL (l_fund_rec.planned_amt, 0)
                                    + NVL (l_fund_planned_amount, 0);

               -- 02/23/2001 mpande you cannot plan for more than the available budget amount

               -- 02/18/2004 feliu  check profile, if profile is N, then validate, otherwise not validate.
               IF l_exceed_flag = 'N' THEN
                  IF OZF_ACTBUDGETRULES_PVT.budget_has_enough_money (
                     p_source_id=> l_act_budgets_rec.budget_source_id
                    ,p_approved_amount=> l_fund_rec.planned_amt
                    ) = fnd_api.g_false THEN
                     ozf_utility_pvt.error_message ('OZF_ACT_BUDG_NO_MONEY');
                     RAISE fnd_api.g_exc_error;
                  END IF;
               END IF;

               ozf_funds_pvt.update_fund (
                  p_api_version=> 1.0
                 ,p_init_msg_list=> fnd_api.g_false
                 ,p_commit=> fnd_api.g_false
                 ,p_validation_level=> p_validation_level
                 ,x_return_status=> l_return_status
                 ,x_msg_count=> x_msg_count
                 ,x_msg_data=> x_msg_data
                 ,p_fund_rec=> l_fund_rec
                 ,p_mode=> g_cons_fund_mode
               );

               IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
               END IF;

            END IF; -- if source type = FUND


            -- call the approval API
            trigger_approval_process (
               p_act_budget_rec=> l_act_budgets_rec
              ,x_act_budget_rec=> l_temp_rec
              ,x_return_status=> l_return_status
              ,x_msg_count=> x_msg_count
              ,x_msg_data=> x_msg_data
              ,p_parent_process_flag=> p_parent_process_flag
              ,p_parent_process_key=> p_parent_process_key
              ,p_parent_context=> p_parent_context
              ,p_parent_approval_flag=> p_parent_approval_flag
              ,p_continue_flow=> p_continue_flow
              ,p_child_approval_flag=> p_child_approval_flag ---- added 05/22/2001 mpande
              ,p_requestor_owner_flag => p_requestor_owner_flag ---- added 10/19/2001 mpande
          ,x_start_flow_flag  => l_start_flow_flag -- if 'Y', need start workflow after updating.
            );

            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            END IF;

         END IF; -- if new.status_code = APPROVED

         complete_act_budgets_rec (l_temp_rec, l_act_budgets_rec);
      ELSE
         -- a approved utlized record could be updated with the new amount
         IF l_act_budgets_rec.transfer_type IN ('UTILIZED') THEN
            IF l_act_budgets_rec.status_code = 'APPROVED' THEN
               l_act_budgets_rec.approved_amount := l_act_budgets_rec.request_amount;
               l_act_budgets_rec.approved_in_currency :=
                     get_object_currency (
                        l_act_budgets_rec.arc_act_budget_used_by
                       ,l_act_budgets_rec.act_budget_used_by_id
                       ,l_return_status
                     );
               --nirprasa,12.1.1 now should use transaction currency
               IF l_act_budgets_rec.approved_in_currency <> l_transaction_currency
                  AND l_act_budgets_rec.arc_act_budget_used_by = 'OFFR' THEN
                     l_act_budgets_rec.approved_in_currency := l_transaction_currency;
               END IF;

               IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
               END IF;

               IF l_act_budgets_rec.request_currency = l_act_budgets_rec.approved_in_currency THEN
                  -- don't need to convert if currencies are equal
                  l_act_budgets_rec.approved_original_amount := l_act_budgets_rec.request_amount;
               ELSE
                  -- convert the request amount to the fund's  currency.
                  --both request_currency and approved_in_currency are in offer's transaction currency
                  --in case of accruals. Still do the conversion.

                  OPEN c_get_conversion_type(l_act_util_rec.org_id);
                  FETCH c_get_conversion_type INTO l_exchange_rate_type;
                  CLOSE c_get_conversion_type;

                  IF G_DEBUG THEN
                     ozf_utility_pvt.debug_message (   l_api_name
                                     || ' l_act_budgets_rec.exchange_rate_date2: ' || l_act_budgets_rec.exchange_rate_date);
                  END IF;

                  ozf_utility_pvt.convert_currency (
                     x_return_status=> l_return_status
                    ,p_from_currency=> l_act_budgets_rec.request_currency
                    ,p_to_currency=> l_act_budgets_rec.approved_in_currency
                    ,p_conv_type=> l_exchange_rate_type
                    ,p_conv_date=> l_act_budgets_rec.exchange_rate_date --bug 7425189, 8532055
                    ,p_from_amount=> l_act_budgets_rec.request_amount
                    ,x_to_amount=> l_act_budgets_rec.approved_original_amount
                    ,x_rate=> l_rate
                  );

                  /*
                  --Added for bug 7425189
                  IF l_act_budgets_rec.justification IN (l_fund_reconc_msg,l_act_bud_cst_msg)
                  AND l_act_budgets_rec.exchange_rate_date IS NOT NULL THEN
                  ozf_utility_pvt.convert_currency (
                     x_return_status=> l_return_status
                    ,p_from_currency=> l_act_budgets_rec.request_currency
                    ,p_to_currency=> l_act_budgets_rec.approved_in_currency
                    ,p_conv_type=> l_exchange_rate_type
                    ,p_conv_date=> l_act_budgets_rec.exchange_rate_date
                    ,p_from_amount=> l_act_budgets_rec.request_amount
                    ,x_to_amount=> l_act_budgets_rec.approved_original_amount
                    ,x_rate=> l_rate
                  );

                  ELSE
                  ozf_utility_pvt.convert_currency (
                     x_return_status=> l_return_status
                    ,p_from_currency=> l_act_budgets_rec.request_currency
                    ,p_to_currency=> l_act_budgets_rec.approved_in_currency
                    ,p_conv_type=> l_exchange_rate_type
                    ,p_from_amount=> l_act_budgets_rec.request_amount
                    ,x_to_amount=> l_act_budgets_rec.approved_original_amount
                    ,x_rate=> l_rate
                  );


                  END IF;
                  */

                  IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                     RAISE fnd_api.g_exc_unexpected_error;
                  ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                     RAISE fnd_api.g_exc_error;
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;

      -- get the corresponding user_status_id
      -- for the given status_code.
      l_act_budgets_rec.user_status_id :=
              ozf_utility_pvt.get_default_user_status (l_status_type, l_act_budgets_rec.status_code);
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_api_name
                                     || ': check items');
      END IF;
      l_act_budgets_rec.comment :=   p_act_budgets_rec.comment;

      -- mpande added to populate request amount in request currency 12/17/2001 src_curr_request_amt
      IF l_act_budgets_rec.budget_source_type IN ('PTNR','OPTN') THEN
         -- for these objects money is in the request currency
         l_src_currency := l_act_budgets_rec.request_currency ;
      ELSE
      l_src_currency :=
            get_object_currency (
               l_act_budgets_rec.budget_source_type
              ,l_act_budgets_rec.budget_source_id
              ,l_return_status
            );
      END IF;
      IF G_DEBUG THEN
      ozf_utility_pvt.debug_message (   l_api_name
                                     || ': l_src_currency '||l_src_currency);
      ozf_utility_pvt.debug_message (   l_api_name
                                     || ': l_act_budgets_rec.request_currency'
                                     || l_act_budgets_rec.request_currency);
      ozf_utility_pvt.debug_message (   l_api_name
                                     || ': l_act_budgets_rec.request_amount'
                                     || l_act_budgets_rec.request_amount);
      END IF;

      --Added for bug 7030415

      IF l_act_budgets_rec.transfer_type IN ('UTILIZED') THEN
        OPEN c_get_conversion_type(l_act_util_rec.org_id);
        FETCH c_get_conversion_type INTO l_exchange_rate_type;
        CLOSE c_get_conversion_type;
      ELSE
      l_exchange_rate_type := FND_API.G_MISS_CHAR;
      END IF;

      IF NVL(l_act_budgets_rec.request_amount,0) <> 0 THEN

         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message (   l_api_name
                             || ' l_act_budgets_rec.exchange_rate_date3: ' || l_act_budgets_rec.exchange_rate_date);
         END IF;

          --Added for bug 7425189
          IF l_act_budgets_rec.justification IN (l_fund_reconc_msg,l_act_bud_cst_msg)
          AND l_act_budgets_rec.exchange_rate_date IS NOT NULL THEN

            IF l_act_budgets_rec.src_curr_req_amt IS NULL THEN
            ozf_utility_pvt.convert_currency(
            p_from_currency   => l_act_budgets_rec.request_currency
           ,p_to_currency     => l_src_currency
           ,p_conv_type       => l_exchange_rate_type
           ,p_conv_date       => l_act_budgets_rec.exchange_rate_date
           ,p_from_amount     => l_act_budgets_rec.request_amount
           ,x_return_status   => l_return_status
           ,x_to_amount       => l_act_budgets_rec.src_curr_req_amt
           ,x_rate            => l_rate);
           END IF;
          ELSE
            ozf_utility_pvt.convert_currency(
            p_from_currency   => l_act_budgets_rec.request_currency
           ,p_to_currency     => l_src_currency
           ,p_conv_type       => l_exchange_rate_type
           ,p_conv_date       => l_act_budgets_rec.exchange_rate_date --bug 8532055
           ,p_from_amount     => l_act_budgets_rec.request_amount
           ,x_return_status   => l_return_status
           ,x_to_amount       => l_act_budgets_rec.src_curr_req_amt
           ,x_rate            => l_rate);
         END IF;

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;
      IF G_DEBUG THEN
      ozf_utility_pvt.debug_message (   l_api_name
                                     || ': l_act_budgets_rec.src_curr_req_amt'
                                     || l_act_budgets_rec.src_curr_req_amt);
      END IF;
      IF p_validation_level >= jtf_plsql_api.g_valid_level_item THEN
         validate_act_budgets_items (
            p_act_budgets_rec=> l_act_budgets_rec
           ,p_validation_mode=> jtf_plsql_api.g_update
           ,x_return_status=> l_return_status
         );

         -- If any errors happen abort API.
         IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_api_name
                                     || ': check records');
      END IF;

      IF p_validation_level >= jtf_plsql_api.g_valid_level_record THEN
         validate_act_budgets_record (
            p_act_budgets_rec=> l_act_budgets_rec
           ,p_validation_mode=> jtf_plsql_api.g_update
           ,x_return_status=> l_return_status
         );

         IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      -- Added 04/26/2001 mpande for new functionality changes for hornet
      IF      l_act_budgets_rec.budget_source_type = 'FUND'
          AND l_act_budgets_rec.arc_act_budget_used_by = 'FUND' THEN
         l_fund_transfer_flag       := 'Y';
     IF l_act_budgets_rec.status_code = 'APPROVED'  THEN
           l_act_budgets_rec.approval_date := SYSDATE;
         END IF;
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;






      IF NVL(l_act_budgets_rec.approved_amount,0) <> 0 THEN
         -- R12: yzhao Oct. 10, 2005 get budget ledger when calculating functional currency
         IF l_act_util_rec.org_id IS NOT NULL THEN
            MO_UTILS.Get_Ledger_Info (
                    p_operating_unit     =>  l_act_util_rec.org_id,
                    p_ledger_id          =>  l_ledger_id,
                    p_ledger_name        =>  l_ledger_name
            );
            IF G_DEBUG THEN
                 ozf_utility_pvt.debug_message (   l_api_name
                                             || ': create_act_budgets   ledger for util.org_id('
                                             || l_act_util_rec.org_id || ')=' || l_ledger_id);
            END IF;
            ozf_utility_pvt.write_conc_log (   l_api_name
                                             || ': create_act_budgets   ledger for util.org_id('
                                             || l_act_util_rec.org_id || ')=' || l_ledger_id);
         ELSE

            ozf_utility_pvt.get_object_org_ledger(p_object_type => l_act_budgets_rec.arc_act_budget_used_by
                                                , p_object_id   => l_act_budgets_rec.act_budget_used_by_id
                                                , x_org_id      => l_act_util_rec.org_id
                                                , x_ledger_id   => l_ledger_id
                                                , x_return_status => l_return_status
                                           );
            IF G_DEBUG THEN
                 ozf_utility_pvt.debug_message (   l_api_name
                                             || ': create_act_budgets   ledger for '
                                             || l_act_budgets_rec.arc_act_budget_used_by
                                             || '  id('
                                             || l_act_budgets_rec.act_budget_used_by_id
                                             || ') returns ' || l_return_status
                                             || '  ledger_id=' || l_ledger_id);
            END IF;
                  ozf_utility_pvt.write_conc_log (   l_api_name
                                             || ': create_act_budgets   ledger for '
                                             || l_act_budgets_rec.arc_act_budget_used_by
                                             || '  id('
                                             || l_act_budgets_rec.act_budget_used_by_id
                                             || ') returns ' || l_return_status
                                             || '  ledger_id=' || l_ledger_id);
            IF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
         END IF;



         --kdass 16-NOV-2005 bug 4728515 - for quota, bypass ledger check
         OPEN  c_check_quota (l_act_budgets_rec.budget_source_type, l_act_budgets_rec.budget_source_id);
         FETCH c_check_quota INTO l_is_quota;
         CLOSE c_check_quota;

         IF l_is_quota IS NULL THEN
            -- yzhao: R12 Oct 19 2005 No need to calculate functional currency if it is for marketing use
            IF l_ledger_id IS NULL AND l_is_quota IS NULL THEN
               IF l_act_budgets_rec.budget_source_type NOT IN ('CAMP', 'CSCH', 'EVEO', 'EVEH', 'EONE') AND
                  l_act_budgets_rec.arc_act_budget_used_by NOT IN ('CAMP', 'CSCH', 'EVEO', 'EVEH', 'EONE') THEN
                  IF G_DEBUG THEN
                     ozf_utility_pvt.debug_message (   l_api_name
                                                 || ': create_act_budgets   ledger not found for '
                                                 || l_act_budgets_rec.arc_act_budget_used_by
                                                 || '  id('
                                                 || l_act_budgets_rec.act_budget_used_by_id);
                  END IF;
                  IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                     fnd_message.set_name ('OZF', 'OZF_NO_LEDGER_FOUND');
                     --Message OZF_NO_LEDGER_FOUND changed fix bug 5190932
                     --fnd_message.set_token('OBJECT_TYPE', l_act_budgets_rec.arc_act_budget_used_by);
                     --fnd_message.set_token('OBJECT_ID', l_act_budgets_rec.act_budget_used_by_id);
                     fnd_msg_pub.ADD;
                  END IF;
                  x_return_status            := fnd_api.g_ret_sts_error;
                  RAISE fnd_api.g_exc_error;
               END IF;
            ELSE
                --Added for bug 7030415
                OPEN c_get_conversion_type(l_act_util_rec.org_id);
                FETCH c_get_conversion_type INTO l_exchange_rate_type;
                CLOSE c_get_conversion_type;


                IF G_DEBUG THEN
                   ozf_utility_pvt.debug_message (   l_api_name
                             || ' l_act_budgets_rec.exchange_rate_date4: ' || l_act_budgets_rec.exchange_rate_date);
                END IF;

                  --Added for bug 7425189
                  IF l_act_budgets_rec.justification IN (l_fund_reconc_msg,l_act_bud_cst_msg)
                  AND l_act_budgets_rec.exchange_rate_date IS NOT NULL THEN
                    l_exchange_rate_type := NULL;
                    ozf_utility_pvt.calculate_functional_currency(
                           p_from_amount        => l_act_budgets_rec.approved_amount
                          ,p_conv_date          => l_act_budgets_rec.exchange_rate_date
                          ,p_tc_currency_code   => l_act_budgets_rec.request_currency
                          ,p_ledger_id          => l_ledger_id
                          ,x_to_amount          => l_fc_amount
                          ,x_mrc_sob_type_code  => l_mrc_sob_type_code
                          ,x_fc_currency_code   => l_fc_currency_code
                          ,x_exchange_rate_type => l_exchange_rate_type
                          ,x_exchange_rate      => l_exchange_rate
                          ,x_return_status      => l_return_status);
                  ELSE
                    ozf_utility_pvt.calculate_functional_currency(
                         p_from_amount        => l_act_budgets_rec.approved_amount
                        ,p_conv_date          => l_act_budgets_rec.exchange_rate_date --bug 8532055
                        ,p_tc_currency_code   => l_act_budgets_rec.request_currency
                        ,p_ledger_id          => l_ledger_id
                        ,x_to_amount          => l_fc_amount
                        ,x_mrc_sob_type_code  => l_mrc_sob_type_code
                        ,x_fc_currency_code   => l_fc_currency_code
                        ,x_exchange_rate_type => l_exchange_rate_type
                        ,x_exchange_rate      => l_exchange_rate
                        ,x_return_status      => l_return_status);
                  END IF;

               IF l_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
               ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;
            END IF;
         END IF;
      END IF;


      -- Perform the database operation
      UPDATE ozf_act_budgets
         SET last_update_date = SYSDATE
            ,last_updated_by = fnd_global.user_id
            ,last_update_login = fnd_global.conc_login_id
            ,object_version_number =   l_act_budgets_rec.object_version_number
                                     + 1
            ,act_budget_used_by_id = l_act_budgets_rec.act_budget_used_by_id
            ,arc_act_budget_used_by = l_act_budgets_rec.arc_act_budget_used_by
            ,budget_source_type = l_act_budgets_rec.budget_source_type
            ,budget_source_id = l_act_budgets_rec.budget_source_id
            ,transaction_type = l_act_budgets_rec.transaction_type
            ,request_amount = l_act_budgets_rec.request_amount
            ,request_currency = l_act_budgets_rec.request_currency
            ,request_date = NVL (l_act_budgets_rec.request_date, SYSDATE)
            ,user_status_id = l_act_budgets_rec.user_status_id
            ,status_code = l_act_budgets_rec.status_code
            ,approved_amount = l_act_budgets_rec.approved_amount
            ,approved_original_amount = l_act_budgets_rec.approved_original_amount
            ,approved_in_currency = l_act_budgets_rec.approved_in_currency
            ,approval_date = l_act_budgets_rec.approval_date
            ,approver_id = l_act_budgets_rec.approver_id
            ,spent_amount = l_act_budgets_rec.spent_amount
            ,partner_po_number = l_act_budgets_rec.partner_po_number
            ,partner_po_date = l_act_budgets_rec.partner_po_date
            ,partner_po_approver = l_act_budgets_rec.partner_po_approver
            ,posted_flag = l_act_budgets_rec.posted_flag
            ,adjusted_flag = l_act_budgets_rec.adjusted_flag
            ,transfer_type = l_act_budgets_rec.transfer_type
            ,reason_code = l_act_budgets_rec.reason_code
            ,parent_act_budget_id = l_act_budgets_rec.parent_act_budget_id
            ,contact_id = l_act_budgets_rec.contact_id
            ,requester_id = NVL (
                               l_act_budgets_rec.requester_id
                              ,ozf_utility_pvt.get_resource_id (fnd_global.user_id)
                            ) --l_act_budgets_rec.requester_id
            ,date_required_by = l_act_budgets_rec.date_required_by
            ,parent_source_id = l_act_budgets_rec.parent_source_id,
             parent_src_curr = l_act_budgets_rec.parent_src_curr,
             parent_src_apprvd_amt = l_act_budgets_rec.parent_src_apprvd_amt,
             partner_holding_type = l_act_budgets_rec.partner_holding_type
            ,partner_address_id = l_act_budgets_rec.partner_address_id
            ,vendor_id = l_act_budgets_rec.vendor_id
            ,owner_id = l_act_budgets_rec.owner_id
            ,recal_flag = l_act_budgets_rec.recal_flag
            ,attribute_category = p_act_budgets_rec.attribute_category
            ,attribute1 = p_act_budgets_rec.attribute1
            ,attribute2 = p_act_budgets_rec.attribute2
            ,attribute3 = p_act_budgets_rec.attribute3
            ,attribute4 = p_act_budgets_rec.attribute4
            ,attribute5 = p_act_budgets_rec.attribute5
            ,attribute6 = p_act_budgets_rec.attribute6
            ,attribute7 = p_act_budgets_rec.attribute7
            ,attribute8 = p_act_budgets_rec.attribute8
            ,attribute9 = p_act_budgets_rec.attribute9
            ,attribute10 = p_act_budgets_rec.attribute10
            ,attribute11 = p_act_budgets_rec.attribute11
            ,attribute12 = p_act_budgets_rec.attribute12
            ,attribute13 = p_act_budgets_rec.attribute13
            ,attribute14 = p_act_budgets_rec.attribute14
            ,attribute15 = p_act_budgets_rec.attribute15
            -- 11/16/2001 mpande
            ,approved_amount_fc = l_fc_amount
            -- 12/17/2001 mpande
            ,src_curr_request_amt = l_act_budgets_rec.src_curr_req_amt
       WHERE activity_budget_id = l_act_budgets_rec.activity_budget_id
         AND object_version_number = l_act_budgets_rec.object_version_number;

      IF (SQL%NOTFOUND) THEN
         -- Error, check the msg level and added an error message to the
         -- API message list
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_API_RECORD_NOT_FOUND');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      /*IF l_act_budgets_rec.transfer_type = 'UTILIZED'
      AND l_src_currency <> l_act_budgets_rec.request_currency THEN
         l_act_budgets_rec.request_amount := l_temp_request_amount;
         l_act_budgets_rec.approved_original_amount := l_temp_aprvd_orig_amount;
         l_act_budgets_rec.approved_amount := l_temp_approved_amount;
      END IF;*/

      IF l_start_flow_flag = 'Y' THEN

         l_new_status_id :=
            ozf_utility_pvt.get_default_user_status('OZF_BUDGETSOURCE_STATUS', 'APPROVED');
         l_reject_status_id :=
            ozf_utility_pvt.get_default_user_status('OZF_BUDGETSOURCE_STATUS', 'REJECTED');

           ams_gen_approval_pvt.startprocess(
            p_activity_type =>  'FREQ'
           ,p_activity_id => l_act_budgets_rec.activity_budget_id
           ,p_approval_type => 'BUDGET'
           ,p_object_version_number => l_act_budgets_rec.object_version_number + 1
           ,p_orig_stat_id => l_act_budgets_rec.user_status_id
           ,p_new_stat_id => l_new_status_id
           ,p_reject_stat_id => l_reject_status_id
           ,p_requester_userid => l_act_budgets_rec.requester_id
           ,p_notes_from_requester => l_act_budgets_rec.justification
           ,p_workflowprocess => 'AMSGAPP'
           ,p_item_type => 'AMSGAPP'
           ,p_gen_process_flag => 'N');


      END IF;

      IF      l_act_budgets_rec.COMMENT IS NOT NULL
          AND l_act_budgets_rec.COMMENT <> fnd_api.g_miss_char THEN
         OZF_ACTBUDGETRULES_PVT.create_note (
            p_activity_type=> 'FREQ'
           ,p_activity_id=> l_act_budgets_rec.activity_budget_id
           ,p_note=> l_act_budgets_rec.COMMENT
           ,p_note_type=> 'AMS_COMMENT'
           ,p_user=> NVL (
                        l_act_budgets_rec.requester_id
                       ,ozf_utility_pvt.get_resource_id (fnd_global.user_id)
                     )
           ,x_msg_count=> x_msg_count
           ,x_msg_data=> x_msg_data
           ,x_return_status=> l_return_status
         );

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      IF      l_act_budgets_rec.justification IS NOT NULL
          AND l_act_budgets_rec.justification <> fnd_api.g_miss_char THEN
         OZF_ACTBUDGETRULES_PVT.create_note (
            p_activity_type=> 'FREQ'
           ,p_activity_id=> l_act_budgets_rec.activity_budget_id
           ,p_note=> l_act_budgets_rec.justification
           ,p_note_type=> 'AMS_JUSTIFICATION'
           ,p_user=> NVL (
                        l_act_budgets_rec.requester_id
                       ,ozf_utility_pvt.get_resource_id (fnd_global.user_id)
                     )
           ,x_msg_count=> x_msg_count
           ,x_msg_data=> x_msg_data
           ,x_return_status=> l_return_status
         );

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      -- 06/25/2001 mpande changed
      IF l_act_budgets_rec.status_code = 'APPROVED'
                                                    THEN
          -- the amount passes should be the  new utilization amount and not the
          -- whole amount
   /*       IF l_old_status_code = 'APPROVED' THEN
             l_act_budgets_rec.request_amount := l_act_budgets_rec.approved_amount -  l_old_approved_amount ;
             l_act_budgets_rec.approved_amount := l_act_budgets_rec.approved_amount -  l_old_approved_amount ;
             l_act_budgets_rec.parent_src_apprvd_amt := l_act_budgets_rec.parent_src_apprvd_amt ;
          END IF;
     */
         -- raise business event when approval request.
         raise_business_event(p_object_id => l_act_budgets_rec.activity_budget_id );

         -- added by feliu on 08/03/2005. only created utilization for UTILIZED.
         IF l_act_budgets_rec.transfer_type = 'UTILIZED' THEN

          -- the amount passes should be the  new utilization amount and not the
          -- whole amount
          IF l_old_status_code = 'APPROVED' THEN
             l_act_budgets_rec.request_amount := l_act_budgets_rec.approved_amount -  l_old_approved_amount ;
             l_act_budgets_rec.approved_amount := l_act_budgets_rec.approved_amount -  l_old_approved_amount ;
             l_act_budgets_rec.parent_src_apprvd_amt := l_act_budgets_rec.parent_src_apprvd_amt ;
          END IF;
           l_act_util_rec.plan_curr_amount := p_act_util_rec.plan_curr_amount;
           l_act_util_rec.plan_curr_amount_remaining := p_act_util_rec.plan_curr_amount_remaining;
           l_act_util_rec.plan_currency_code := p_act_util_rec.plan_currency_code;

           ozf_fund_adjustment_pvt.create_fund_utilization (
            p_act_budget_rec=> l_act_budgets_rec
           ,x_return_status=> l_return_status
           ,x_msg_count=> x_msg_count
           ,x_msg_data=> x_msg_data
           ,p_act_util_rec => l_act_util_rec
           ,x_utilized_amount => x_utilized_amount    -- yzhao: 06/21/2004 added to return actual utilized amount
           ,x_utilization_id  => x_utilization_id  --kdass - added for Bug 8726683
           );


         IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         END IF;
       END IF; --l_act_budgets_rec.transfer_type = 'UTILIZED'

       IF (l_act_budgets_rec.budget_source_type ='CAMP' AND l_act_budgets_rec.arc_act_budget_used_by = 'CSCH') OR
         (l_act_budgets_rec.budget_source_type ='EVEH' AND l_act_budgets_rec.arc_act_budget_used_by = 'EVEO') OR
         (l_act_budgets_rec.budget_source_type ='CAMP' AND l_act_budgets_rec.arc_act_budget_used_by = 'OFFR') OR
         (l_act_budgets_rec.arc_act_budget_used_by ='CAMP' AND l_act_budgets_rec.budget_source_type = 'CSCH') OR
         (l_act_budgets_rec.arc_act_budget_used_by ='EVEH' AND l_act_budgets_rec.budget_source_type = 'EVEO') OR
         (l_act_budgets_rec.arc_act_budget_used_by ='CAMP' AND l_act_budgets_rec.budget_source_type = 'OFFR')  THEN


          create_child_act_budget (
                  x_return_status      => l_return_status,
                  x_msg_count          =>  x_msg_count,
                  x_msg_data           => x_msg_data,
                  p_act_budgets_rec    => l_act_budgets_rec,
                  p_exchange_rate_type => l_exchange_rate_type
            );


         IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         END IF;

      END IF;


      END IF;

      --
      -- Since "REJECTED" records do not count as a record
      -- for the cue card "tick", validate on update that
      -- only non-rejected records exist.
      -- 02/22/2001  mpande REmoved all object attribute calls from here

      IF      l_old_status_code = 'NEW'
          AND l_act_budgets_rec.status_code = 'APPROVED' THEN
         -- initiate WF approval and return; WF will
         -- call an API to update the relevent columns.

         -- check to see if commit is needed before returning
         IF fnd_api.to_boolean (p_commit) THEN
            COMMIT WORK;
         END IF;

         RETURN;
      END IF;

      -- added by feliu for offer validation.
      IF NVL(l_check_validation, 'NO') <> 'NO'
         AND l_act_budgets_rec.arc_act_budget_used_by = 'OFFR'
         AND l_act_budgets_rec.budget_source_type = 'FUND'
         AND l_act_budgets_rec.status_code = 'PENDING_VALIDATION' THEN

         OPEN c_offer_status(l_act_budgets_rec.act_budget_used_by_id);
         FETCH c_offer_status INTO l_offer_status;
         CLOSE c_offer_status;

         IF l_offer_status = 'ACTIVE' THEN
             l_request_id := fnd_request.submit_request (
                            application   => 'OZF',
                            program       => 'OZFVALIELIG',
                            start_time    => sysdate,
                            argument1     => l_act_budgets_rec.act_budget_used_by_id,
                            argument2     =>'OFFR',
                            argument3     =>l_act_budgets_rec.activity_budget_id
                         );
            COMMIT;
         END IF;
      END IF;

      -- END of API body.
      --
      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit) THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count AND IF count is 1, get message info.
      fnd_msg_pub.count_and_get (
         p_count=> x_msg_count
        ,p_data=> x_msg_data
        ,p_encoded=> fnd_api.g_false
      );
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO update_act_budgets_pvt;
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO update_act_budgets_pvt;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN OTHERS THEN
         ROLLBACK TO update_act_budgets_pvt;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_package_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
   END update_act_budgets;


/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Delete_Act_Budgets
--
-- PURPOSE
--   This procedure is to delete a budget record that satisfy caller needs
--
-- HISTORY
-- 04/12/2000  sugupta  CREATED
-- 22-Feb-2001 mpande   Modified for Hornet changes.
-- End of Comments
/*****************************************************************************************/
   PROCEDURE delete_act_budgets (
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,p_act_budget_id      IN       NUMBER
     ,p_object_version     IN       NUMBER
   ) IS
      l_api_name        CONSTANT VARCHAR2 (30) := 'Delete_Act_Budgets';
      l_api_version     CONSTANT NUMBER        := 1.0;
      l_rejected_code   CONSTANT VARCHAR2 (30) := 'REJECTED';
      -- Status Local Variables
      l_return_status            VARCHAR2 (1); -- Return value from procedures
      l_act_budget_id            NUMBER        := p_act_budget_id;
      l_status_code              VARCHAR2 (30);

      CURSOR c_status (p_act_budget_id IN NUMBER) IS
         SELECT status_code
           FROM ozf_act_budgets
          WHERE activity_budget_id = p_act_budget_id;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_act_budgets_pvt;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_package_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status            := fnd_api.g_ret_sts_success;
      --
      -- API body
      --

      OPEN c_status (l_act_budget_id);
      FETCH c_status INTO l_status_code;
      CLOSE c_status;

      IF l_status_code NOT IN ('NEW') THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_ACT_BUDGET_NO_DELETE');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      -- Perform the database operation
      -- Delete header data
      DELETE FROM ozf_act_budgets
            WHERE activity_budget_id = l_act_budget_id
              AND object_version_number = p_object_version;

      IF SQL%NOTFOUND THEN
         --
         -- Add error message to API message list.
         --
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_API_RECORD_NOT_FOUND');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      --
      -- END of API body.
      --
      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit) THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count AND IF count is 1, get message info.
      fnd_msg_pub.count_and_get (
         p_count=> x_msg_count
        ,p_data=> x_msg_data
        ,p_encoded=> fnd_api.g_false
      );
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO delete_act_budgets_pvt;
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO delete_act_budgets_pvt;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN OTHERS THEN
         ROLLBACK TO delete_act_budgets_pvt;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_package_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
   END delete_act_budgets;


/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Lock_Act_Budgets
--
-- PURPOSE
--   This procedure is to lock a budget record that satisfy caller needs
--
-- HISTORY
-- 04/12/2000  sugupta  CREATED
-- End of Comments
/*****************************************************************************************/
   PROCEDURE lock_act_budgets (
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,p_act_budget_id      IN       NUMBER
     ,p_object_version     IN       NUMBER
   ) IS
      l_api_name      CONSTANT VARCHAR2 (30) := 'Lock_Act_Budgets';
      l_api_version   CONSTANT NUMBER        := 1.0;
      -- Status Local Variables
      l_return_status          VARCHAR2 (1); -- Return value from procedures
      l_status_code            VARCHAR2 (30);

      CURSOR c_act_budget IS
         SELECT        status_code
                  FROM ozf_act_budgets
                 WHERE activity_budget_id = p_act_budget_id
                   AND object_version_number = p_object_version
         FOR UPDATE OF activity_budget_id NOWAIT;
   BEGIN
      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_package_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status            := fnd_api.g_ret_sts_success;
      --
      -- API body
      --
      -- Perform the database operation
      OPEN c_act_budget;
      FETCH c_act_budget INTO l_status_code;

      IF (c_act_budget%NOTFOUND) THEN
         CLOSE c_act_budget;

         -- Error, check the msg level and added an error message to the
         -- API message list
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN -- MMSG
            fnd_message.set_name ('OZF', 'OZF_API_RECORD_NOT_FOUND');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE c_act_budget;
      --
      -- END of API body.
      --
      -- Standard call to get message count AND IF count is 1, get message info.
      fnd_msg_pub.count_and_get (
         p_count=> x_msg_count
        ,p_data=> x_msg_data
        ,p_encoded=> fnd_api.g_false
      );
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN ozf_utility_pvt.resource_locked THEN
         x_return_status            := fnd_api.g_ret_sts_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_API_RESOURCE_LOCKED');
            fnd_msg_pub.ADD;
         END IF;

         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN OTHERS THEN
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_package_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
   END lock_act_budgets;


/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Validate_Act_Budgets
--
-- PURPOSE
--   This procedure is to validate an activity budget record
--
-- HISTORY
-- 04/12/2000  sugupta  CREATED
-- End of Comments
/*****************************************************************************************/
   PROCEDURE validate_act_budgets (
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,p_act_budgets_rec    IN       act_budgets_rec_type
   ) IS
      l_api_name      CONSTANT VARCHAR2 (30)        := 'Validate_Act_Budgets';
      l_api_version   CONSTANT NUMBER               := 1.0;
      l_full_name     CONSTANT VARCHAR2 (60)        :=    g_package_name
                                                       || '.'
                                                       || l_api_name;
      -- Status Local Variables
      l_return_status          VARCHAR2 (1); -- Return value from procedures
      l_act_budgets_rec        act_budgets_rec_type := p_act_budgets_rec;
      l_act_budget_id          NUMBER;
   BEGIN
      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_package_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status            := fnd_api.g_ret_sts_success;
      --
      -- API body
      --
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name
                                     || ': check items');
      END IF;

      IF p_validation_level >= jtf_plsql_api.g_valid_level_item THEN
         validate_act_budgets_items (
            p_act_budgets_rec=> l_act_budgets_rec
           ,p_validation_mode=> jtf_plsql_api.g_create
           ,x_return_status=> l_return_status
         );

         -- If any errors happen abort API.
         IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      -- Perform cross attribute validation and missing attribute checks. Record
      -- level validation.
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name
                                     || ': check record level');
      END IF;

      IF p_validation_level >= jtf_plsql_api.g_valid_level_record THEN
         validate_act_budgets_record (
            p_act_budgets_rec=> l_act_budgets_rec
           ,p_validation_mode=> jtf_plsql_api.g_create
           ,x_return_status=> l_return_status
         );

         -- If any errors happen abort API.
         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;


--
-- END of API body.
--
-------------------- finish --------------------------
      fnd_msg_pub.count_and_get (
         p_encoded=> fnd_api.g_false
        ,p_count=> x_msg_count
        ,p_data=> x_msg_data
      );
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN OTHERS THEN
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_package_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
   END validate_act_budgets;


/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Validate_Act_Budgets_Items
--
-- PURPOSE
--   This procedure is to validate busget items
-- HISTORY
-- 24-Aug-2000 choang   Changed ozf_fund_details_v to ozf_fund_details_v
-- 22-Feb-2001 mpande   Modified for Hornet changes.
-- End of Comments
/*****************************************************************************************/
   PROCEDURE validate_act_budgets_items (
      p_act_budgets_rec   IN       act_budgets_rec_type
     ,p_validation_mode   IN       VARCHAR2 := jtf_plsql_api.g_create
     ,x_return_status     OUT NOCOPY      VARCHAR2
   ) IS
      l_table_name   VARCHAR2 (30);
      l_pk_name      VARCHAR2 (30);
      l_pk_value     VARCHAR2 (30);
   BEGIN
      --  Initialize API/Procedure return status to success
      x_return_status            := fnd_api.g_ret_sts_success;

      -- Check required parameters
      IF (   p_act_budgets_rec.act_budget_used_by_id = fnd_api.g_miss_num
          OR p_act_budgets_rec.act_budget_used_by_id IS NULL
         ) THEN
         -- missing required fields
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_ACT_BUDG_NO_USEDBYID');
            fnd_msg_pub.ADD;
         END IF;

         x_return_status            := fnd_api.g_ret_sts_error;
         -- If any error happens abort API.
         RETURN;
      END IF;

      --- budget sourrce id
      IF (   p_act_budgets_rec.budget_source_id = fnd_api.g_miss_num
          OR p_act_budgets_rec.budget_source_id IS NULL
         ) THEN
         -- missing required fields
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_ACT_BUDG_NO_SOURCEID');
            fnd_msg_pub.ADD;
         END IF;

         x_return_status            := fnd_api.g_ret_sts_error;
         -- If any error happens abort API.
         RETURN;
      END IF;

      -- budget source type
      IF (   p_act_budgets_rec.budget_source_type = fnd_api.g_miss_char
          OR p_act_budgets_rec.budget_source_type IS NULL
         ) THEN
         -- missing required fields
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_ACT_BUDG_NO_SOURCETYPE');
            fnd_msg_pub.ADD;
         END IF;

         x_return_status            := fnd_api.g_ret_sts_error;
         -- If any error happens abort API.
         RETURN;
      END IF;

      -- transfer type
      IF (   p_act_budgets_rec.transfer_type = fnd_api.g_miss_char
          OR p_act_budgets_rec.transfer_type IS NULL
         ) THEN
         -- missing required fields
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_ACT_BUDG_NO_TRANSYPE');
            fnd_msg_pub.ADD;
         END IF;

         x_return_status            := fnd_api.g_ret_sts_error;
         -- If any error happens abort API.
         RETURN;
      END IF;

      -- arc_act_budget_used_by
      IF (   p_act_budgets_rec.arc_act_budget_used_by = fnd_api.g_miss_char
          OR p_act_budgets_rec.arc_act_budget_used_by IS NULL
         ) THEN
         -- missing required fields
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_ACT_BUDG_NO_USEDBY');
            fnd_msg_pub.ADD;
         END IF;

         x_return_status            := fnd_api.g_ret_sts_error;
         -- If any error happens abort API.
         RETURN;
      END IF;

      -- Validate the currency code.
      -- Currency code is set in the create API and it
      -- cannot be updated, so failure condition should
      -- only happen during create.

      IF (   p_act_budgets_rec.request_currency IS NULL
          OR p_act_budgets_rec.request_currency = fnd_api.g_miss_char
         ) THEN
         ozf_utility_pvt.error_message ('OZF_ACT_BUDG_NO_CURRENCY');
         x_return_status            := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
      --   Validate uniqueness
      IF      p_validation_mode = jtf_plsql_api.g_create
          AND p_act_budgets_rec.activity_budget_id IS NOT NULL THEN
         IF ozf_utility_pvt.check_uniqueness (
               'ozf_Act_budgets'
              ,   'ACTIVITY_BUDGET_ID = '
               || p_act_budgets_rec.activity_budget_id
            ) = fnd_api.g_false THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name ('OZF', 'OZF_ACT_BUDG_DUPLICATE_ID');
               fnd_msg_pub.ADD;
            END IF;

            x_return_status            := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;

      --
      --   check for lookups....arc_act_budget_used_by
      --   TO DO: check ozf object in ozf lookup OZF_SYS_ARC_QUALIFIER, ams object in ams lookup AMS_SYS_ARC_QUALIFIER

      IF p_act_budgets_rec.arc_act_budget_used_by <> fnd_api.g_miss_char THEN
         IF ams_utility_pvt.check_lookup_exists (
               p_lookup_type=> 'AMS_SYS_ARC_QUALIFIER'
              ,p_lookup_code=> p_act_budgets_rec.arc_act_budget_used_by
            ) = fnd_api.g_false THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
               ozf_utility_pvt.debug_message ( 'Used By:'||p_act_budgets_rec.arc_act_budget_used_by);
               fnd_message.set_name ('OZF', 'OZF_ACT_BUDG_BAD_USEDBY');
               fnd_msg_pub.ADD;
            END IF;

            x_return_status            := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;

      --
      --   check for lookups....BUDGET_SOURCE_TYPE
      --
      IF p_act_budgets_rec.budget_source_type <> fnd_api.g_miss_char THEN
         IF ozf_utility_pvt.check_lookup_exists (
               p_lookup_type=> 'OZF_FUND_SOURCE'
              ,p_lookup_code=> p_act_budgets_rec.budget_source_type
            ) = fnd_api.g_false THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name ('OZF', 'OZF_ACT_BUDG_BAD_SRCTYPE');
               fnd_msg_pub.ADD;
            END IF;

            x_return_status            := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;

      --
      -- Begin Validate Referential
      --
      -- Check FK parameter: act_budget_used_by_id #1
      IF p_act_budgets_rec.act_budget_used_by_id <> fnd_api.g_miss_num THEN
         IF p_act_budgets_rec.arc_act_budget_used_by = ('EVEH') THEN
            l_table_name               := 'AMS_EVENT_HEADERS_VL';
            l_pk_name                  := 'EVENT_HEADER_ID';
         ELSIF p_act_budgets_rec.arc_act_budget_used_by IN ( 'EVEO','EONE') THEN
            l_table_name               := 'AMS_EVENT_OFFERS_VL';
            l_pk_name                  := 'EVENT_OFFER_ID';
         ELSIF p_act_budgets_rec.arc_act_budget_used_by = 'CAMP' THEN
            l_table_name               := 'AMS_CAMPAIGNS_VL';
            l_pk_name                  := 'CAMPAIGN_ID';
         -- 02/23/2001 mpande ADDED for Hornet reqmt
         ELSIF p_act_budgets_rec.arc_act_budget_used_by = 'OFFR'
            OR p_act_budgets_rec.arc_act_budget_used_by = 'PRIC' THEN    -- yzhao: 10/20/2003 added for price list
            l_table_name               := 'QP_LIST_HEADERS_B';
            l_pk_name                  := 'LIST_HEADER_ID';
         ELSIF p_act_budgets_rec.arc_act_budget_used_by = 'WKST' THEN
            l_table_name               := 'OZF_WORKSHEET_HEADERS_VL';
            l_pk_name                  := 'WORKSHEET_HEADER_ID';
         ELSIF p_act_budgets_rec.arc_act_budget_used_by = 'USER' THEN
            l_table_name               := 'ams_jtf_rs_emp_v';
            l_pk_name                  := 'RESOURCE_ID';
         ELSIF p_act_budgets_rec.arc_act_budget_used_by = 'DELV' THEN
            -- choang - 05-sep-2000
            -- Fix for bug 1397577.
            l_table_name               := 'AMS_DELIVERABLES_VL';
            l_pk_name                  := 'DELIVERABLE_ID';
         ELSIF p_act_budgets_rec.arc_act_budget_used_by = 'CSCH' THEN
            l_table_name               := 'AMS_CAMPAIGN_SCHEDULES_VL';
            l_pk_name                  := 'SCHEDULE_ID';
         ELSIF p_act_budgets_rec.arc_act_budget_used_by = 'FUND' THEN
            l_table_name               := 'OZF_FUNDS_ALL_B';
            l_pk_name                  := 'FUND_ID';
         ELSIF p_act_budgets_rec.arc_act_budget_used_by = 'SOFT_FUND' THEN
            l_table_name               := 'OZF_REQUEST_HEADERS_ALL_B';
            l_pk_name                  := 'REQUEST_HEADER_ID';
         ELSIF p_act_budgets_rec.arc_act_budget_used_by = 'SPECIAL_PRICE' THEN
            l_table_name               := 'OZF_REQUEST_HEADERS_ALL_B';
            l_pk_name                  := 'REQUEST_HEADER_ID';
         END IF;

         l_pk_value                 := p_act_budgets_rec.act_budget_used_by_id;

         IF ozf_utility_pvt.check_fk_exists (
               p_table_name=> l_table_name
              ,p_pk_name=> l_pk_name
              ,p_pk_value=> l_pk_value
            ) = fnd_api.g_false THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name ('OZF', 'OZF_ACT_BUDG_BAD_USEDBYID');
               fnd_msg_pub.ADD;
            END IF;

            x_return_status            := fnd_api.g_ret_sts_error;
            -- If any errors happen abort API/Procedure.
            RETURN;
         END IF; -- check_fk_exists
      END IF;

      -- Check FK parameter: BUDGET_SOURCE_ID #2
      -- Partner funds will not have a budget source ID
      IF      p_act_budgets_rec.budget_source_id <> fnd_api.g_miss_num
          AND p_act_budgets_rec.budget_source_id IS NOT NULL THEN
         IF p_act_budgets_rec.budget_source_type = 'EVEH' THEN
            l_table_name               := 'AMS_EVENT_HEADERS_VL';
            l_pk_name                  := 'EVENT_HEADER_ID';
         ELSIF p_act_budgets_rec.budget_source_type IN ('EONE', 'EVEO') THEN
            l_table_name               := 'AMS_EVENT_OFFERS_VL';
            l_pk_name                  := 'EVENT_OFFER_ID';
         ELSIF p_act_budgets_rec.budget_source_type = 'CAMP' THEN
            l_table_name               := 'AMS_CAMPAIGNS_VL';
            l_pk_name                  := 'CAMPAIGN_ID';
         ELSIF p_act_budgets_rec.budget_source_type = 'CSCH' THEN
            l_table_name               := 'AMS_CAMPAIGN_SCHEDULES_VL';
            l_pk_name                  := 'SCHEDULE_ID';
         ELSIF p_act_budgets_rec.budget_source_type = 'SOFT_FUND' THEN
            l_table_name               := 'OZF_REQUEST_HEADERS_ALL_B';
            l_pk_name                  := 'REQUEST_HEADER_ID';
         ELSIF p_act_budgets_rec.budget_source_type = 'SPECIAL_PRICE' THEN
            l_table_name               := 'OZF_REQUEST_HEADERS_ALL_B';
            l_pk_name                  := 'REQUEST_HEADER_ID';
         ELSIF p_act_budgets_rec.budget_source_type = 'FUND' THEN
            --  31-Jan-2001   mpande   Removed access from ozf_fund_details_V to ozf_funds_all_vl for cross organzation validation.
            --         l_table_name := 'AMS_FUND_DETAILS_V';
            l_table_name               := 'OZF_FUNDS_ALL_B';
            l_pk_name                  := 'FUND_ID';
         ELSIF p_act_budgets_rec.budget_source_type = 'PTNR' THEN
            l_table_name               := 'PV_PARTNERS_V';
            -- 09/05/2001 mpande changed as per partners new functioanlity
            l_pk_name                  := 'PARTNER_ID';
         ELSIF p_act_budgets_rec.budget_source_type = 'USER' THEN
            l_table_name               := 'ams_jtf_rs_emp_v';
            l_pk_name                  := 'RESOURCE_ID';
         /* 07/27/2001 yzhao ADDED for Hornet reqmt
            10/24/2003 yzhao ADDED for PRIC */
         ELSIF p_act_budgets_rec.budget_source_type = 'OFFR'
            OR p_act_budgets_rec.budget_source_type = 'PRIC' THEN
            l_table_name               := 'QP_LIST_HEADERS_B';
            l_pk_name                  := 'LIST_HEADER_ID';
         ELSIF p_act_budgets_rec.owner_id IS NOT NULL or
          p_act_budgets_rec.owner_id <> FND_API.g_miss_num THEN
            l_table_name               := 'ams_jtf_rs_emp_v';
            l_pk_name                  := 'RESOURCE_ID';
         -- 03/21/2002 mpande added because Deliverables reconciliation was not working properly
         ELSIF p_act_budgets_rec.budget_source_type = 'DELV' THEN
            l_table_name               := 'AMS_DELIVERABLES_VL';
            l_pk_name                  := 'DELIVERABLE_ID';
         END IF;

         l_pk_value                 := p_act_budgets_rec.budget_source_id;

         IF ozf_utility_pvt.check_fk_exists (
               p_table_name=> l_table_name
              ,p_pk_name=> l_pk_name
              ,p_pk_value=> l_pk_value
            ) = fnd_api.g_false THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name ('OZF', 'OZF_ACT_BUDG_BAD_SRCID');
               fnd_msg_pub.ADD;
            END IF;

            x_return_status            := fnd_api.g_ret_sts_error;
            -- If any errors happen abort API/Procedure.
            RETURN;
         END IF; -- check_fk_exists
      END IF;

      /* R12: yzhao July 29, 2005 comment out check FK for approver_id and requester_id
              the check is not essential. These two ids are FYI only, and not referred any where
              in the past, several customers had issue with this checking.
              For example, if the original user who created UTILIZED record left the company,
                  following update on UTILIZED record failed with approver not exists error,
                  which does not make sense.

      -- Check FK parameter: approver_id
      IF p_act_budgets_rec.approver_id <> fnd_api.g_miss_num THEN
         l_table_name               := 'ams_jtf_rs_emp_v';
         l_pk_name                  := 'RESOURCE_ID';
         l_pk_value                 := p_act_budgets_rec.approver_id;

         IF ozf_utility_pvt.check_fk_exists (
               p_table_name=> l_table_name
              ,p_pk_name=> l_pk_name
              ,p_pk_value=> l_pk_value
            ) = fnd_api.g_false THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name ('OZF', 'OZF_ACT_BUDG_BAD_APPRID');
               fnd_msg_pub.ADD;
            END IF;

            x_return_status            := fnd_api.g_ret_sts_error;
            -- If any errors happen abort API/Procedure.
            RETURN;
         END IF; -- check_fk_exists
      END IF;

      -- Check FK parameter: approver_id
      IF p_act_budgets_rec.requester_id <> fnd_api.g_miss_num THEN
         l_table_name               := 'ams_jtf_rs_emp_v';
         l_pk_name                  := 'RESOURCE_ID';
         l_pk_value                 := p_act_budgets_rec.requester_id;

         IF ozf_utility_pvt.check_fk_exists (
               p_table_name=> l_table_name
              ,p_pk_name=> l_pk_name
              ,p_pk_value=> l_pk_value
            ) = fnd_api.g_false THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name ('OZF', 'OZF_ACT_BUDG_BAD_APPRID');
               fnd_msg_pub.ADD;
            END IF;

            x_return_status            := fnd_api.g_ret_sts_error;
            -- If any errors happen abort API/Procedure.
            RETURN;
         END IF; -- check_fk_exists
      END IF;
   -- Check FK parameter:uom
   -- include checks for UOM, CURRENCY, approver_id
   -- include checks that PO fields are not null for SRC TYPE of PARTNER
   */

   END validate_act_budgets_items;



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
-- 08/05/2005  feliu    modified for R12.
-- End of Comments
/*****************************************************************************************/
   PROCEDURE validate_act_budgets_record (
      p_act_budgets_rec   IN       act_budgets_rec_type
     ,p_validation_mode   IN       VARCHAR2 := jtf_plsql_api.g_create
     ,x_return_status     OUT NOCOPY      VARCHAR2
   ) IS
      l_api_name      CONSTANT VARCHAR2 (30) := 'Validate_Act_Budgets_Record';
      l_api_version   CONSTANT NUMBER        := 1.0;
      -- Status Local Variables
      l_return_status          VARCHAR2 (1); -- Return value from procedures
      l_owner_currency         VARCHAR2 (15);
      -- flag indicating it is a fund to fund transfer.
      l_fund_transfer_flag     VARCHAR2 (1)  := fnd_api.g_false;
      l_check_amount           NUMBER := 0 ;
      l_old_approved_amount    NUMBER := 0 ;
      l_dummy                  VARCHAR2(3);
      l_exc_util_check         VARCHAR2(1):= 'F';
      CURSOR c_current_amount IS
         SELECT  approved_amount
           FROM ozf_act_budgets
          WHERE activity_budget_id = p_act_budgets_rec.activity_budget_id;

 -- Bug Fix 4030115.
 -- An offer not autogenerated from a budget should not be allow to make a negative request from a fully accrued budget.

     CURSOR c_fund_type (p_fund_id IN NUMBER , p_list_header_id IN NUMBER) IS
        SELECT 'X'
          FROM ozf_funds_all_b ozf
         WHERE  ozf.fund_type = 'FULLY_ACCRUED' and ozf.fund_id = p_fund_id
          and  ozf.plan_id = p_list_header_id;

     -- sangara - Bug - 4553660
     CURSOR c_get_offer_info(l_qp_list_header_id IN NUMBER) IS
        SELECT offer_type, org_id
        FROM ozf_offers
        WHERE qp_list_header_id = l_qp_list_header_id;

     l_offerType        VARCHAR2(30);
     l_offerOrgId         NUMBER;
     l_offerLedger        NUMBER;
     l_offerLedgerName VARCHAR2(30);

     CURSOR c_get_budget_ledger_id (p_fund_id IN NUMBER) IS
     SELECT NVL(ledger_id,0)
     FROM ozf_funds_all_b
     WHERE fund_id = p_fund_id;

     l_budgetLedger     NUMBER;
     -- sangara - Bug - 4553660 -- changes end


   BEGIN
      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version, l_api_version, l_api_name, g_package_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --  Initialize API return status to success
      x_return_status            := fnd_api.g_ret_sts_success;

      --
      -- API body
      /****************** commented by mpande 02/10/2001 only for INternal rollout*************
      /****************** changed by mpande**********************
      ---budget  requested amount should always be positive be it credit or debit transaction --
         IF  NVL(p_act_budgets_rec.request_amount,0) <= 0 THEN
            OZF_Utility_PVT.error_message ('OZF_ACT_BUDG_NEG_REQUEST');
            x_return_status := FND_API.g_ret_sts_error;
         END IF;
      ********************************************************************************************/

      -- 22-Feb-2001 mpande
      --budget  requested amount should always be positive be it credit or debit transaction --
      -- this is not true for fully accrued budgets 08/16/2001
      -- -- Bug Fix 4030115.
      /*
      IF p_act_budgets_rec.budget_source_type = 'FUND' AND
          p_act_budgets_rec.arc_act_budget_used_by = 'OFFR' THEN
        OPEN c_fund_type( p_act_budgets_rec.budget_source_id, p_act_budgets_rec.act_budget_used_by_id) ;
        FETCH c_fund_type INTO l_dummy;
        CLOSE c_fund_type;
       END IF;
*/
  --    IF l_dummy IS NULL THEN
      -- 02/20/2002 added by mpande for negative utilization
      -- allow to create budget request with zero amount, not negative amount.
      -- fixed by feliu on 02/02/2006.
         IF p_act_budgets_rec.transfer_type <> 'UTILIZED' THEN
            IF NVL (p_act_budgets_rec.request_amount, 0) <0 THEN
               ozf_utility_pvt.error_message ('OZF_ACT_BUDG_NEG_REQUEST');
               x_return_status            := fnd_api.g_ret_sts_error;
            END IF;
         END IF;
    --  END IF;

      -- 22-Feb-2001 mpande
      --budget  spent amount cannot be greateer than the approved amount
      /* 03/01/2002 mpande commented this is not there any more
      IF NVL (p_act_budgets_rec.spent_amount, 0) > NVL (p_act_budgets_rec.approved_amount, 0) THEN
         ozf_utility_pvt.error_message ('OZF_ACT_BUDG_EXCESS_SPENT');
         x_return_status            := fnd_api.g_ret_sts_error;
      END IF;
      */

      -- 04/10/2001 mpande Hornet changes
      IF      p_act_budgets_rec.arc_act_budget_used_by = 'FUND'
          AND p_act_budgets_rec.budget_source_type = 'FUND' THEN
         l_fund_transfer_flag       := fnd_api.g_true;
      END IF;

      IF l_fund_transfer_flag = fnd_api.g_false THEN
            -- only utilized records could be updated. transfer, request cannot be updated
            IF p_validation_mode   = jtf_plsql_api.g_update THEN
             OPEN c_current_amount;
             FETCH c_current_amount INTO l_old_approved_amount;

             IF c_current_amount%NOTFOUND THEN
                CLOSE c_current_amount;
                ozf_utility_pvt.error_message ('OZF_API_RECORD_NOT_FOUND');
                RAISE fnd_api.g_exc_unexpected_error;
             END IF;

             CLOSE c_current_amount;
            END IF;


            /* sangara - Bug - 4553660 - OFFER ACCURAL NOT IMPORTING TO GL.
             For non order-related offers(lumpsum, scan data), we should validate budget and offer's SOB (R12 - legder) at the time of budget request.

             For order-related offers, since offer is global and can be applied to orders from any org, we can not validate at budget request creation.
             We need to document that we only support budget utilization within single SOB setup. In case order is from a different SOB than
             budget's, Funds Accrual Engine gives warning.
            */
            IF  p_act_budgets_rec.arc_act_budget_used_by = 'OFFR' AND
                p_act_budgets_rec.budget_source_type = 'FUND' THEN

                 OPEN c_get_offer_info(p_act_budgets_rec.act_budget_used_by_id);
                 FETCH c_get_offer_info INTO l_offerType, l_offerOrgId;
                 CLOSE c_get_offer_info;

                 IF l_offerType IN ('LUMPSUM', 'SCAN_DATA' ) THEN

                       -- Get the set_of_books_id for given org_id
                       MO_UTILS.Get_Ledger_Info (
                         p_operating_unit     =>  l_offerOrgId,
                         p_ledger_id          =>  l_offerLedger,
                         p_ledger_name        =>  l_offerLedgerName
                       );

                      OPEN c_get_budget_ledger_id (p_act_budgets_rec.budget_source_id);
                      FETCH c_get_budget_ledger_id INTO l_budgetLedger;
                      CLOSE c_get_budget_ledger_id;

                     IF NVL(l_budgetLedger, 0) <> 0 AND NVL(l_budgetLedger, 0) <> l_offerLedger THEN
                            ozf_utility_pvt.error_message ('OZF_BUDGET_OFFR_LEDG_MISMATCH');
                            x_return_status := fnd_api.g_ret_sts_error;
                            RAISE fnd_api.g_exc_error;
                     END IF;

                 END IF;
              END IF;
            -- sangara changes end

            --IF p_act_budgets_rec.status_code = 'APPROVED' THEN
            IF p_act_budgets_rec.transfer_type = 'UTILIZED' THEN
               l_check_amount             := p_act_budgets_rec.approved_amount - l_old_approved_amount;
            ELSE
               l_check_amount             := p_act_budgets_rec.src_curr_req_amt;
               -- For TRANSFER, it is the amount in budget source.
            END IF;

                -- 6/11/2002 mpande fully accrued budget would have no committment
            --    l_dummy := NULL;

   /*
           IF p_act_budgets_rec.transfer_type = 'UTILIZED' THEN
               OPEN c_fund_type( p_act_budgets_rec.parent_source_id, p_list_header_id IN NUMBER) IS
               FETCH c_fund_type INTO l_dummy;
               CLOSE c_fund_type;
            END IF;
   */
            -- 10/23/2002 #2636800 commented by mpande for performance for utilized we donot wannt to check it
            -- mpande changed the transfer amount check clause.
            IF p_act_budgets_rec.transfer_type = 'TRANSFER' THEN
               IF (p_act_budgets_rec.arc_act_budget_used_by ='CAMP' AND p_act_budgets_rec.budget_source_type = 'CSCH') OR
                  (p_act_budgets_rec.arc_act_budget_used_by ='EVEH' AND p_act_budgets_rec.budget_source_type = 'EVEO') OR
                  (p_act_budgets_rec.arc_act_budget_used_by ='CAMP' AND p_act_budgets_rec.budget_source_type = 'OFFR')  THEN
                  l_exc_util_check := 'F' ;
               ELSE
                  l_exc_util_check := 'T' ;
               END IF;
            ELSIF p_act_budgets_rec.transfer_type = 'UTILIZED'  THEN
                /*
                  For utilization from accrual, it is handled in accrual engine.
                  The utilization here is for marketing object, offer adjustment, third party accrual,
                  and Chargeback.
                  The recal-committed is only for all offers except ('LUMPSUM', 'TERMS','SCAN_DATA')
                */
               IF g_recal_flag = 'N' AND p_act_budgets_rec.arc_act_budget_used_by = 'OFFR' THEN
                 l_exc_util_check := 'T'; -- for offer without recal_committed.
               ELSIF p_act_budgets_rec.arc_act_budget_used_by IN ('CAMP','CSCH','EVEH','EONE','EVEO','DELV') THEN
                   l_exc_util_check := 'T' ; -- check for marketing object.
               --ELSE
                 -- l_exc_util_check := 'F' ; -- for p_object_type IN ('PTNR','PRIC','WKST') and offer with recal_committed.
               END IF;
           -- ELSE
             --   l_exc_util_check := 'F' ; -- for REQUEST, do not check.
             END IF;

            IF l_exc_util_check = 'T' THEN

              OZF_ACTBUDGETRULES_PVT.check_transfer_amount_exists (
               p_act_budgets_rec.budget_source_id-- for 'TRANSFER', it is object id.
              ,p_act_budgets_rec.budget_source_type -- for 'TRANSFER', it is object type.
              ,p_act_budgets_rec.act_budget_used_by_id
              ,p_act_budgets_rec.arc_act_budget_used_by
              ,l_check_amount
              ,p_act_budgets_rec.transfer_type
              ,l_return_status
              );
            END IF;

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
               x_return_status            := fnd_api.g_ret_sts_error;
            END IF;
         -- donot check for utilized and transfer records -- they are not souring 08/09/2001 mpande
         --  Request amount can not more than estimated amount when object is DRAFT status.
         -- don't validate for child records from sourcing from parent.
         IF p_act_budgets_rec.transfer_type = 'REQUEST' AND p_act_budgets_rec.parent_act_budget_id is NULL
         AND p_act_budgets_rec.arc_act_budget_used_by IN ('OFFR','CAMP','CSCH','EVEH','EONE','EVEO','DELV') THEN
            IF OZF_ACTBUDGETRULES_PVT.can_plan_more_budget (
               p_object_type=> p_act_budgets_rec.arc_act_budget_used_by
              ,p_object_id=> p_act_budgets_rec.act_budget_used_by_id
              ,p_request_amount=> p_act_budgets_rec.request_amount
              ,p_act_budget_id=> p_act_budgets_rec.activity_budget_id
            ) = fnd_api.g_false THEN
            ozf_utility_pvt.error_message ( 'OZF_ACT_BUDG_EXC_OBJ_AMT');
            x_return_status            := fnd_api.g_ret_sts_error;
            END IF;
         END IF ;

         --- we will match activity and category for others also later
         --- 02/20/2002 mpande added the validation for offers also
  /*       IF      p_act_budgets_rec.arc_act_budget_used_by IN ('CSCH','OFFR')
             AND p_act_budgets_rec.budget_source_type = 'FUND' THEN
            OZF_ACTBUDGETRULES_PVT.check_cat_activity_match (
               p_act_budgets_rec.act_budget_used_by_id
              ,p_act_budgets_rec.arc_act_budget_used_by
              ,p_act_budgets_rec.budget_source_id
              ,l_return_status
            );

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
               x_return_status            := fnd_api.g_ret_sts_error;
            END IF;
         END IF; */
         -- 10/30/2001 mpande commented prod and market validation
         -- as per Leela.
         /*
         IF p_act_budgets_rec.budget_source_type = 'FUND' THEN
            OZF_ACTBUDGETRULES_PVT.check_market_elig_match (
               p_act_budgets_rec.act_budget_used_by_id
              ,p_act_budgets_rec.arc_act_budget_used_by
              ,p_act_budgets_rec.budget_source_id
              ,l_return_status
            );

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
               x_return_status            := fnd_api.g_ret_sts_error;
            ELSE
               /* yzhao: 07/20/2001  check product eligibility
               OZF_ACTBUDGETRULES_PVT.check_prod_elig_match (
                 p_act_budgets_rec.act_budget_used_by_id,
                 p_act_budgets_rec.arc_act_budget_used_by,
                 p_act_budgets_rec.budget_source_id,
                 l_return_status
               );

               IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  x_return_status            := fnd_api.g_ret_sts_error;
               END IF;
            END IF;
         END IF;
         */

      END IF;

      -- Check that transfer cannot be from and to the same source if it s not utlized record for the object
      IF p_act_budgets_rec.transfer_type NOT IN ('UTILIZED', 'RELEASE', 'RESERVE') THEN
         IF p_act_budgets_rec.arc_act_budget_used_by = p_act_budgets_rec.budget_source_type THEN
            IF p_act_budgets_rec.act_budget_used_by_id = p_act_budgets_rec.budget_source_id THEN
               ozf_utility_pvt.error_message ('OZF_FROM_TO_TRANSFER_SAME');
               x_return_status            := fnd_api.g_ret_sts_error;
            END IF;
         END IF;
      END IF;
   -- put in checks for date: required by date cannot be less than sysdate

     IF p_act_budgets_rec.date_required_by IS NOT NULL
         AND p_act_budgets_rec.date_required_by <> FND_API.G_MISS_DATE THEN
       IF p_act_budgets_rec.date_required_by < TRUNC(SYSDATE)  THEN
        Fnd_Message.SET_NAME('OZF','OZF_ACT_REQDBYDATE_LT_SYSDATE');
        Fnd_Msg_Pub.ADD;
        RAISE FND_API.G_EXC_ERROR;
       END IF;
      END IF;

   --
   -- END of API body.
   --
   END validate_act_budgets_record;

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
   PROCEDURE complete_act_budgets_rec (
      p_act_budgets_rec   IN       act_budgets_rec_type
     ,x_act_budgets_rec   OUT NOCOPY      act_budgets_rec_type
   ) IS
      CURSOR c_budget IS
         SELECT *
           FROM ozf_act_budgets
          WHERE activity_budget_id = p_act_budgets_rec.activity_budget_id;

      l_act_budgets_rec   c_budget%ROWTYPE;
   BEGIN
      x_act_budgets_rec          := p_act_budgets_rec;
      OPEN c_budget;
      FETCH c_budget INTO l_act_budgets_rec;

      IF c_budget%NOTFOUND THEN
         CLOSE c_budget;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_API_RECORD_NOT_FOUND');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE c_budget;

      --
      -- Usually, object_version_number is required from API calls,
      -- but this exception is made because approvals and rejections
      -- do not have to be synced to the screen record.  The same
      -- may apply for account closing.
      IF p_act_budgets_rec.object_version_number = fnd_api.g_miss_num THEN
         x_act_budgets_rec.object_version_number := NULL;
      END IF;
      IF p_act_budgets_rec.object_version_number IS NULL THEN
         x_act_budgets_rec.object_version_number := l_act_budgets_rec.object_version_number;
      END IF;

      IF p_act_budgets_rec.act_budget_used_by_id = fnd_api.g_miss_num THEN
         x_act_budgets_rec.act_budget_used_by_id := NULL;
      END IF;
      IF p_act_budgets_rec.act_budget_used_by_id IS NULL THEN
         x_act_budgets_rec.act_budget_used_by_id := l_act_budgets_rec.act_budget_used_by_id;
      END IF;

      IF p_act_budgets_rec.arc_act_budget_used_by = fnd_api.g_miss_char THEN
         x_act_budgets_rec.arc_act_budget_used_by := NULL;
      END IF;
      IF p_act_budgets_rec.arc_act_budget_used_by IS NULL THEN
         x_act_budgets_rec.arc_act_budget_used_by := l_act_budgets_rec.arc_act_budget_used_by;
      END IF;

      IF p_act_budgets_rec.budget_source_type = fnd_api.g_miss_char THEN
         x_act_budgets_rec.budget_source_type := NULL;
      END IF;
      IF p_act_budgets_rec.budget_source_type IS NULL THEN
         x_act_budgets_rec.budget_source_type := l_act_budgets_rec.budget_source_type;
      END IF;

      IF p_act_budgets_rec.budget_source_id = fnd_api.g_miss_num THEN
         x_act_budgets_rec.budget_source_id := NULL;
      END IF;
      IF p_act_budgets_rec.budget_source_id IS NULL THEN
         x_act_budgets_rec.budget_source_id := l_act_budgets_rec.budget_source_id;
      END IF;

      IF p_act_budgets_rec.transaction_type = fnd_api.g_miss_char THEN
         x_act_budgets_rec.transaction_type := NULL;
      END IF;
      IF p_act_budgets_rec.transaction_type IS NULL THEN
         x_act_budgets_rec.transaction_type := l_act_budgets_rec.transaction_type;
      END IF;

      IF p_act_budgets_rec.request_amount = fnd_api.g_miss_num THEN
         x_act_budgets_rec.request_amount := NULL;
      END IF;
      IF p_act_budgets_rec.request_amount IS NULL THEN
         x_act_budgets_rec.request_amount := l_act_budgets_rec.request_amount;
      END IF;

      IF p_act_budgets_rec.request_currency = fnd_api.g_miss_char THEN
         x_act_budgets_rec.request_currency := NULL;
      END IF;
      IF p_act_budgets_rec.request_currency IS NULL THEN
         x_act_budgets_rec.request_currency := l_act_budgets_rec.request_currency;
      END IF;

      IF p_act_budgets_rec.request_date = fnd_api.g_miss_date THEN
         x_act_budgets_rec.request_date := NULL;
      END IF;
      IF p_act_budgets_rec.request_date IS NULL THEN
         x_act_budgets_rec.request_date := l_act_budgets_rec.request_date;
      END IF;

      IF p_act_budgets_rec.status_code = fnd_api.g_miss_char THEN
         x_act_budgets_rec.status_code := NULL;
      END IF;
      IF p_act_budgets_rec.status_code IS NULL THEN
         x_act_budgets_rec.status_code := l_act_budgets_rec.status_code;
      END IF;

      IF p_act_budgets_rec.approved_amount = fnd_api.g_miss_num THEN
         x_act_budgets_rec.approved_amount := NULL;
      END IF;
      IF p_act_budgets_rec.approved_amount IS NULL THEN
         x_act_budgets_rec.approved_amount := l_act_budgets_rec.approved_amount;
      END IF;

      IF p_act_budgets_rec.approved_original_amount = fnd_api.g_miss_num THEN
         x_act_budgets_rec.approved_original_amount := NULL;
      END IF;
      IF p_act_budgets_rec.approved_original_amount IS NULL THEN
         x_act_budgets_rec.approved_original_amount := l_act_budgets_rec.approved_original_amount;
      END IF;

      IF p_act_budgets_rec.approved_in_currency = fnd_api.g_miss_char THEN
         x_act_budgets_rec.approved_in_currency := NULL;
      END IF;
      IF p_act_budgets_rec.approved_in_currency IS NULL THEN
         x_act_budgets_rec.approved_in_currency := l_act_budgets_rec.approved_in_currency;
      END IF;

      IF p_act_budgets_rec.approval_date = fnd_api.g_miss_date THEN
         x_act_budgets_rec.approval_date := NULL;
      END IF;
      IF p_act_budgets_rec.approval_date IS NULL THEN
         x_act_budgets_rec.approval_date := l_act_budgets_rec.approval_date;
      END IF;

      IF p_act_budgets_rec.approver_id = fnd_api.g_miss_num THEN
         x_act_budgets_rec.approver_id := NULL;
      END IF;
      IF p_act_budgets_rec.approver_id IS NULL THEN
         x_act_budgets_rec.approver_id := l_act_budgets_rec.approver_id;
      END IF;

      IF p_act_budgets_rec.spent_amount = fnd_api.g_miss_num THEN
         x_act_budgets_rec.spent_amount := NULL;
      END IF;
      IF p_act_budgets_rec.spent_amount IS NULL THEN
         x_act_budgets_rec.spent_amount := l_act_budgets_rec.spent_amount;
      END IF;

      IF p_act_budgets_rec.partner_po_number = fnd_api.g_miss_char THEN
         x_act_budgets_rec.partner_po_number := NULL;
      END IF;
      IF p_act_budgets_rec.partner_po_number IS NULL THEN
         x_act_budgets_rec.partner_po_number := l_act_budgets_rec.partner_po_number;
      END IF;

      IF p_act_budgets_rec.partner_po_date = fnd_api.g_miss_date THEN
         x_act_budgets_rec.partner_po_date := NULL;
      END IF;
      IF p_act_budgets_rec.partner_po_date IS NULL THEN
         x_act_budgets_rec.partner_po_date := l_act_budgets_rec.partner_po_date;
      END IF;

      IF p_act_budgets_rec.partner_po_approver = fnd_api.g_miss_char THEN
         x_act_budgets_rec.partner_po_approver := NULL;
      END IF;
      IF p_act_budgets_rec.partner_po_approver IS NULL THEN
         x_act_budgets_rec.partner_po_approver := l_act_budgets_rec.partner_po_approver;
      END IF;

      IF p_act_budgets_rec.posted_flag = fnd_api.g_miss_char THEN
         x_act_budgets_rec.posted_flag := NULL;
      END IF;
      IF p_act_budgets_rec.posted_flag IS NULL THEN
         x_act_budgets_rec.posted_flag := l_act_budgets_rec.posted_flag;
      END IF;

      IF p_act_budgets_rec.adjusted_flag = fnd_api.g_miss_char THEN
         x_act_budgets_rec.adjusted_flag := NULL;
      END IF;
      IF p_act_budgets_rec.adjusted_flag IS NULL THEN
         x_act_budgets_rec.adjusted_flag := l_act_budgets_rec.adjusted_flag;
      END IF;

      IF p_act_budgets_rec.transfer_type = fnd_api.g_miss_char THEN
         x_act_budgets_rec.transfer_type := NULL;
      END IF;
      IF p_act_budgets_rec.transfer_type IS NULL THEN
         x_act_budgets_rec.transfer_type := l_act_budgets_rec.transfer_type;
      END IF;

      IF p_act_budgets_rec.reason_code = fnd_api.g_miss_char THEN
         x_act_budgets_rec.reason_code := NULL;
      END IF;
      IF p_act_budgets_rec.reason_code IS NULL THEN
         x_act_budgets_rec.reason_code := l_act_budgets_rec.reason_code;
      END IF;

      IF p_act_budgets_rec.requester_id = fnd_api.g_miss_num THEN
         x_act_budgets_rec.requester_id := NULL;
      END IF;
      IF p_act_budgets_rec.requester_id IS NULL THEN
         x_act_budgets_rec.requester_id := l_act_budgets_rec.requester_id;
      END IF;

      IF p_act_budgets_rec.date_required_by = fnd_api.g_miss_date THEN
         x_act_budgets_rec.date_required_by := NULL;
      END IF;
      IF p_act_budgets_rec.date_required_by IS NULL THEN
         x_act_budgets_rec.date_required_by := l_act_budgets_rec.date_required_by;
      END IF;

      IF p_act_budgets_rec.contact_id = fnd_api.g_miss_num THEN
         x_act_budgets_rec.contact_id := NULL;
      END IF;
      IF p_act_budgets_rec.contact_id IS NULL THEN
         x_act_budgets_rec.contact_id := l_act_budgets_rec.contact_id;
      END IF;

      IF p_act_budgets_rec.parent_act_budget_id = fnd_api.g_miss_num THEN
         x_act_budgets_rec.parent_act_budget_id := NULL;
      END IF;
      IF p_act_budgets_rec.parent_act_budget_id IS NULL THEN
         x_act_budgets_rec.parent_act_budget_id := l_act_budgets_rec.parent_act_budget_id;
      END IF;

      --kdass 24-JUN-2005 fix for bug 4440342, set parent_source_id to null so that the API get_parent_src is called
      /*

      IF p_act_budgets_rec.parent_source_id = fnd_api.g_miss_num THEN
         x_act_budgets_rec.parent_source_id := NULL;
      END IF;
      IF p_act_budgets_rec.parent_source_id IS NULL THEN
         x_act_budgets_rec.parent_source_id := l_act_budgets_rec.parent_source_id;
      END IF;
      */

      IF p_act_budgets_rec.src_curr_req_amt = fnd_api.g_miss_num THEN
         x_act_budgets_rec.src_curr_req_amt := NULL;
      END IF;
      IF p_act_budgets_rec.src_curr_req_amt IS NULL THEN
         x_act_budgets_rec.src_curr_req_amt := l_act_budgets_rec.src_curr_request_amt;
      END IF;


      IF p_act_budgets_rec.partner_holding_type = fnd_api.g_miss_char THEN
         x_act_budgets_rec.partner_holding_type := NULL;
      END IF;
      IF p_act_budgets_rec.partner_holding_type IS NULL THEN
         x_act_budgets_rec.partner_holding_type := l_act_budgets_rec.partner_holding_type;
      END IF;

      IF p_act_budgets_rec.partner_address_id = fnd_api.g_miss_num THEN
         x_act_budgets_rec.partner_address_id := NULL;
      END IF;
      IF p_act_budgets_rec.partner_address_id IS NULL THEN
         x_act_budgets_rec.partner_address_id := l_act_budgets_rec.partner_address_id;
      END IF;

      IF p_act_budgets_rec.vendor_id = fnd_api.g_miss_num THEN
         x_act_budgets_rec.vendor_id := NULL;
      END IF;
      IF p_act_budgets_rec.vendor_id IS NULL THEN
         x_act_budgets_rec.vendor_id := l_act_budgets_rec.vendor_id;
      END IF;

      IF p_act_budgets_rec.owner_id = fnd_api.g_miss_num THEN
         x_act_budgets_rec.owner_id := NULL;
      END IF;
      IF p_act_budgets_rec.owner_id IS NULL THEN
         x_act_budgets_rec.owner_id := l_act_budgets_rec.owner_id;
      END IF;

      IF p_act_budgets_rec.recal_flag = fnd_api.g_miss_char THEN
         x_act_budgets_rec.recal_flag := NULL;
      END IF;
      IF p_act_budgets_rec.recal_flag IS NULL THEN
         x_act_budgets_rec.recal_flag := l_act_budgets_rec.recal_flag;
      END IF;

      IF p_act_budgets_rec.attribute_category = fnd_api.g_miss_char THEN
         x_act_budgets_rec.attribute_category := NULL;
      END IF;
      IF p_act_budgets_rec.attribute_category IS NULL THEN
         x_act_budgets_rec.attribute_category := l_act_budgets_rec.attribute_category;
      END IF;

      IF p_act_budgets_rec.attribute1 = fnd_api.g_miss_char THEN
         x_act_budgets_rec.attribute1 := NULL;
      END IF;
      IF p_act_budgets_rec.attribute1 IS NULL THEN
         x_act_budgets_rec.attribute1 := l_act_budgets_rec.attribute1;
      END IF;

      IF p_act_budgets_rec.attribute2 = fnd_api.g_miss_char THEN
         x_act_budgets_rec.attribute2 := NULL;
      END IF;
      IF p_act_budgets_rec.attribute2 IS NULL THEN
         x_act_budgets_rec.attribute2 := l_act_budgets_rec.attribute2;
      END IF;

      IF p_act_budgets_rec.attribute3 = fnd_api.g_miss_char THEN
         x_act_budgets_rec.attribute3 := NULL;
      END IF;
      IF p_act_budgets_rec.attribute3 IS NULL THEN
         x_act_budgets_rec.attribute3 := l_act_budgets_rec.attribute3;
      END IF;

      IF p_act_budgets_rec.attribute4 = fnd_api.g_miss_char THEN
         x_act_budgets_rec.attribute4 := NULL;
      END IF;
      IF p_act_budgets_rec.attribute4 IS NULL THEN
         x_act_budgets_rec.attribute4 := l_act_budgets_rec.attribute4;
      END IF;

      IF p_act_budgets_rec.attribute5 = fnd_api.g_miss_char THEN
         x_act_budgets_rec.attribute5 := NULL;
      END IF;
      IF p_act_budgets_rec.attribute5 IS NULL THEN
         x_act_budgets_rec.attribute5 := l_act_budgets_rec.attribute5;
      END IF;

      IF p_act_budgets_rec.attribute6 = fnd_api.g_miss_char THEN
         x_act_budgets_rec.attribute6 := NULL;
      END IF;
      IF p_act_budgets_rec.attribute6 IS NULL THEN
         x_act_budgets_rec.attribute6 := l_act_budgets_rec.attribute6;
      END IF;

      IF p_act_budgets_rec.attribute7 = fnd_api.g_miss_char THEN
         x_act_budgets_rec.attribute7 := NULL;
      END IF;
      IF p_act_budgets_rec.attribute7 IS NULL THEN
         x_act_budgets_rec.attribute7 := l_act_budgets_rec.attribute7;
      END IF;

      IF p_act_budgets_rec.attribute8 = fnd_api.g_miss_char THEN
         x_act_budgets_rec.attribute8 := NULL;
      END IF;
      IF p_act_budgets_rec.attribute8 IS NULL THEN
         x_act_budgets_rec.attribute8 := l_act_budgets_rec.attribute8;
      END IF;

      IF p_act_budgets_rec.attribute9 = fnd_api.g_miss_char THEN
         x_act_budgets_rec.attribute9 := NULL;
      END IF;
      IF p_act_budgets_rec.attribute9 IS NULL THEN
         x_act_budgets_rec.attribute9 := l_act_budgets_rec.attribute9;
      END IF;

      IF p_act_budgets_rec.attribute10 = fnd_api.g_miss_char THEN
         x_act_budgets_rec.attribute10 := NULL;
      END IF;
      IF p_act_budgets_rec.attribute10 IS NULL THEN
         x_act_budgets_rec.attribute10 := l_act_budgets_rec.attribute10;
      END IF;

      IF p_act_budgets_rec.attribute11 = fnd_api.g_miss_char THEN
         x_act_budgets_rec.attribute11 := NULL;
      END IF;
      IF p_act_budgets_rec.attribute11 IS NULL THEN
         x_act_budgets_rec.attribute11 := l_act_budgets_rec.attribute11;
      END IF;

      IF p_act_budgets_rec.attribute12 = fnd_api.g_miss_char THEN
         x_act_budgets_rec.attribute12 := NULL;
      END IF;
      IF p_act_budgets_rec.attribute12 IS NULL THEN
         x_act_budgets_rec.attribute12 := l_act_budgets_rec.attribute12;
      END IF;

      IF p_act_budgets_rec.attribute13 = fnd_api.g_miss_char THEN
         x_act_budgets_rec.attribute13 := NULL;
      END IF;
      IF p_act_budgets_rec.attribute13 IS NULL THEN
         x_act_budgets_rec.attribute13 := l_act_budgets_rec.attribute13;
      END IF;

      IF p_act_budgets_rec.attribute14 = fnd_api.g_miss_char THEN
         x_act_budgets_rec.attribute14 := NULL;
      END IF;
      IF p_act_budgets_rec.attribute14 IS NULL THEN
         x_act_budgets_rec.attribute14 := l_act_budgets_rec.attribute14;
      END IF;

      IF p_act_budgets_rec.attribute15 = fnd_api.g_miss_char THEN
         x_act_budgets_rec.attribute15 := NULL;
      END IF;
      IF p_act_budgets_rec.attribute15 IS NULL THEN
         x_act_budgets_rec.attribute15 := l_act_budgets_rec.attribute15;
      END IF;
      --added by feliu since 11.5.9
 /*     IF p_act_budgets_rec.user_status_id = fnd_api.g_miss_num THEN
         x_act_budgets_rec.user_status_id := l_act_budgets_rec.user_status_id;
      END IF;
*/
      IF p_act_budgets_rec.parent_src_curr = fnd_api.g_miss_char THEN
         x_act_budgets_rec.parent_src_curr := NULL;
      END IF;
      IF p_act_budgets_rec.parent_src_curr IS NULL THEN
         x_act_budgets_rec.parent_src_curr := l_act_budgets_rec.parent_src_curr;
      END IF;

      IF p_act_budgets_rec.parent_src_apprvd_amt = fnd_api.g_miss_num THEN
         x_act_budgets_rec.parent_src_apprvd_amt := NULL;
      END IF;
      IF p_act_budgets_rec.parent_src_apprvd_amt IS NULL THEN
         x_act_budgets_rec.parent_src_apprvd_amt := l_act_budgets_rec.parent_src_apprvd_amt;
      END IF;


   END complete_act_budgets_rec;


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
   PROCEDURE init_act_budgets_rec (x_act_budgets_rec OUT NOCOPY act_budgets_rec_type) IS
   BEGIN
      RETURN;
   END init_act_budgets_rec;

/*****************************************************************************************/
-- Start of Comments
   --
   -- NAME
   --    trigger_approval_process
   -- PURPOSE
   --    Handle Workflow approval request processing.
   -- HISTORY
   -- 12-Sep-2000 choang   Created.
   --  03/23/2001 mpande   Added code for fund transfer
   --  05/23/2001 mpande   changed the default falg
   -- 08/27/2002  FELIU    added offer validation.
/*****************************************************************************************/
   PROCEDURE trigger_approval_process (
      p_act_budget_rec         IN       act_budgets_rec_type
     ,x_act_budget_rec         IN OUT NOCOPY   act_budgets_rec_type
     ,x_return_status          OUT NOCOPY      VARCHAR2
     ,x_msg_count              OUT NOCOPY      NUMBER
     ,x_msg_data               OUT NOCOPY      VARCHAR2
     ,p_parent_process_flag    IN       VARCHAR2
     ,p_parent_process_key     IN       VARCHAR2
     ,p_parent_context         IN       VARCHAR2
     ,p_parent_approval_flag   IN       VARCHAR2
     ,p_continue_flow          IN       VARCHAR2
     ,p_child_approval_flag    IN       VARCHAR2 := fnd_api.g_false -- -- added 05/22/2001 mpande
     ,p_requestor_owner_flag   IN       VARCHAR2 := 'N' -- -- added 10/19/2001 mpande
     ,x_start_flow_flag        OUT NOCOPY     VARCHAR2
  ) IS
      l_budget_status_type   CONSTANT VARCHAR2 (30) := 'OZF_BUDGETSOURCE_STATUS';
      l_return_status                 VARCHAR2 (1);
      l_approved_in_currency          VARCHAR2 (15);
      l_approved_amount               NUMBER;
      l_orig_status                   NUMBER;
      l_new_status                    NUMBER;
      l_reject_status                 NUMBER;
      l_request_id                    NUMBER;
      l_approver_id                   NUMBER;
      l_is_requestor_owner            VARCHAR2 (2)  ; -- changed 09/07/2001 mpande
      l_allocation_flag               VARCHAR2 (2)  ; -- changed 09/07/2001 mpande
      l_approval_for_id               NUMBER;
      l_approval_fm_id                NUMBER;
      l_check_validation   VARCHAR2(50) := fnd_profile.value('OZF_CHECK_MKTG_PROD_ELIG');
      l_act_budget_rec        act_budgets_rec_type := x_act_budget_rec ;
      l_temp_act_rec          act_budgets_rec_type;
      l_start_flow_flag               VARCHAR2(1) := 'N';
      l_custom_setup_id      NUMBER;

      CURSOR c_user_status_id (p_status_code IN VARCHAR2) IS
         SELECT user_status_id
           FROM ams_user_statuses_vl
          WHERE system_status_type = l_budget_status_type
            AND system_status_code = p_status_code
            AND default_flag = 'Y'; -- this should be yes and not 'N'
      -- 09/07/2001 mpande added
      CURSOR c_source_fund_owner(
         p_source_fund_id   NUMBER)
      IS
         SELECT   owner
         FROM     ozf_funds_all_b
         WHERE  fund_id = p_source_fund_id;

      CURSOR c_offer_info(p_object_id IN NUMBER) IS
        SELECT custom_setup_id
        FROM ozf_offers
        WHERE qp_list_header_id = p_object_id;

   BEGIN
      -- fund to fund approval
      IF      p_act_budget_rec.arc_act_budget_used_by = 'FUND'
          AND p_act_budget_rec.budget_source_type = 'FUND' THEN
            l_approval_for_id          := p_act_budget_rec.act_budget_used_by_id;
            l_approval_fm_id           := p_act_budget_rec.budget_source_id;

         -- submit for budget approval
         IF p_child_approval_flag = fnd_api.g_false THEN
            -- yzhao: 03/14/2003 when p_requestor_owner_flag=Y, it is from allocation, should bypass workflow approval
            l_allocation_flag := p_requestor_owner_flag;
            ozf_fund_request_apr_pvt.create_fund_request (
               p_commit=> fnd_api.g_false
              ,p_approval_for_id=> l_approval_for_id
              ,p_requester_id=> p_act_budget_rec.requester_id
              ,p_requested_amount=> p_act_budget_rec.request_amount
              ,p_approval_fm=> 'FUND'
              ,p_approval_fm_id=> l_approval_fm_id
              ,p_transfer_type=> p_act_budget_rec.transfer_type
              ,p_child_flag=> 'N'
              ,p_allocation_flag => l_allocation_flag    -- yzhao: 03/14/2003 11.5.9 for allocation activation of budget hierarchy, always pass as 'Y'; all others 'N'
              ,p_act_budget_id=> p_act_budget_rec.activity_budget_id
              ,p_justification=> p_act_budget_rec.justification
              ,x_return_status=> l_return_status
              ,x_msg_count=> x_msg_count
              ,x_msg_data=> x_msg_data
              ,x_request_id=> l_request_id
              ,x_approver_id=> l_approver_id
              ,x_is_requester_owner=> l_is_requestor_owner
            );
            --used to start process.
            IF l_is_requestor_owner ='N' THEN
               l_start_flow_flag := 'Y';
            END IF;

            IF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;

         ELSE
         -- 10/22/2001   mpande    Changed code different owner allocation bug
         l_is_requestor_owner := p_requestor_owner_flag;
         END IF;


         IF l_is_requestor_owner = 'Y' THEN
            l_approved_in_currency     := get_object_currency (
                                             p_act_budget_rec.budget_source_type
                                            ,p_act_budget_rec.budget_source_id
                                            ,l_return_status
                                          );

            IF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF l_approved_in_currency <> p_act_budget_rec.request_currency THEN
               ozf_utility_pvt.convert_currency (
                  x_return_status=> l_return_status
                 ,p_from_currency=> p_act_budget_rec.request_currency
                 ,p_to_currency=> l_approved_in_currency
                 ,p_from_amount=> p_act_budget_rec.request_amount
                 ,x_to_amount=> l_approved_amount
               );

               IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
               END IF;
            ELSE
               l_approved_amount          := p_act_budget_rec.request_amount;
            END IF;

            l_act_budget_rec.approved_amount := p_act_budget_rec.request_amount;
            l_act_budget_rec.approved_in_currency := l_approved_in_currency;
            l_act_budget_rec.approved_original_amount := l_approved_amount;
            l_act_budget_rec.approver_id := p_act_budget_rec.requester_id ;
            l_act_budget_rec.status_code := 'APPROVED';
            complete_act_budgets_rec (l_act_budget_rec, x_act_budget_rec);
         END IF;
      ELSIF p_act_budget_rec.budget_source_type = 'PTNR' THEN       -- Partner funds are automatically approved
            l_act_budget_rec.approved_amount := p_act_budget_rec.request_amount;
            l_act_budget_rec.approved_original_amount := p_act_budget_rec.request_amount;
            l_act_budget_rec.approved_in_currency := p_act_budget_rec.request_currency;
            l_act_budget_rec.status_code := 'APPROVED';
            complete_act_budgets_rec (l_act_budget_rec, x_act_budget_rec);
      ELSE -- object's budget approval
         -- If approval is required, indicated by the existense of the
         -- attribute_avaliable_flag of BAPL, then initiate the Workflow process
         -- with the call to ams_approval_pvt.start_lineapproval, otherwise,
         -- the approved amount is equal to the requested amount.
         IF OZF_ACTBUDGETRULES_PVT.check_approval_required (
               p_act_budget_rec.arc_act_budget_used_by
              ,p_act_budget_rec.act_budget_used_by_id
              ,p_act_budget_rec.budget_source_type
              ,p_act_budget_rec.budget_source_id
              ,p_act_budget_rec.transfer_type
            ) = fnd_api.g_true THEN

            --
            -- For performance considerations, consolidate the three
            -- cursor open and fetches into one by using DECODE on
            -- status_code in the select and IN in the WHERE.
            OPEN c_user_status_id ('NEW');
            FETCH c_user_status_id INTO l_orig_status;
            CLOSE c_user_status_id;
            OPEN c_user_status_id (p_act_budget_rec.status_code); -- this status_code should be approved
            FETCH c_user_status_id INTO l_new_status;
            CLOSE c_user_status_id;
            OPEN c_user_status_id ('REJECTED');
            FETCH c_user_status_id INTO l_reject_status;
            CLOSE c_user_status_id;
            ams_approval_pvt.start_lineapproval (
               p_api_version=> 1.0
              ,p_init_msg_list=> fnd_api.g_false
              ,p_commit=> fnd_api.g_false
              ,p_validation_level=> fnd_api.g_valid_level_full
              ,x_return_status=> l_return_status
              ,x_msg_data=> x_msg_data
              ,x_msg_count=> x_msg_count
              ,p_user_id=> ozf_utility_pvt.get_resource_id (fnd_global.user_id)
              ,p_act_budget_id=> p_act_budget_rec.activity_budget_id
              ,p_orig_status_id=> l_orig_status
              ,p_new_status_id=> l_new_status
              ,p_rejected_status_id=> l_reject_status
              ,p_parent_process_flag=> p_parent_process_flag
              ,p_parent_process_key=> p_parent_process_key
              ,p_parent_context=> p_parent_context
              ,p_parent_approval_flag=> p_parent_approval_flag
              ,p_continue_flow=> p_continue_flow
            );

            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         ELSE

            l_approved_in_currency     := get_object_currency (
                                             p_act_budget_rec.budget_source_type
                                            ,p_act_budget_rec.budget_source_id
                                            ,l_return_status
                                          );

            IF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF l_approved_in_currency <> p_act_budget_rec.request_currency THEN
               ozf_utility_pvt.convert_currency (
                  x_return_status=> l_return_status
                 ,p_from_currency=> p_act_budget_rec.request_currency
                 ,p_to_currency=> l_approved_in_currency
                 ,p_from_amount=> p_act_budget_rec.request_amount
                 ,x_to_amount=> l_approved_amount
               );

               IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
               END IF;
            ELSE
               l_approved_amount          := p_act_budget_rec.request_amount;
            END IF;
       /*     l_act_budget_rec.approved_amount := p_act_budget_rec.request_amount;
            l_act_budget_rec.approved_in_currency := l_approved_in_currency;
            l_act_budget_rec.approved_original_amount := l_approved_amount;
            l_act_budget_rec.approver_id := x_act_budget_rec.requester_id;
            l_act_budget_rec.comment := p_act_budget_rec.comment;
            l_act_budget_rec.status_code := 'APPROVED';
         */   complete_act_budgets_rec (l_act_budget_rec, l_temp_act_rec);
         -- added by feliu on 05/05/04 for special pricing and softfund.
       IF  l_temp_act_rec.arc_act_budget_used_by = 'OFFR' THEN
          OPEN c_offer_info(l_temp_act_rec.act_budget_used_by_id);
          FETCH c_offer_info INTO l_custom_setup_id;
          CLOSE c_offer_info;
       END IF;

        IF NVL(l_check_validation, 'NO') <> 'NO' -- for offer validation
              AND l_temp_act_rec.arc_act_budget_used_by = 'OFFR'
              AND NVL(l_custom_setup_id,0) NOT IN (110,115,116,117)  -- exclude budget request for softunf and special pricing.
              AND l_temp_act_rec.budget_source_type = 'FUND' THEN
                 l_temp_act_rec.status_code := 'PENDING_VALIDATION';
                 l_temp_act_rec.approved_in_currency := l_approved_in_currency;
                 x_act_budget_rec := l_temp_act_rec;
            ELSE
              l_temp_act_rec.approved_amount := p_act_budget_rec.request_amount;
              l_temp_act_rec.approved_in_currency := l_approved_in_currency;
              l_temp_act_rec.approved_original_amount := l_approved_amount;
              l_temp_act_rec.approver_id := x_act_budget_rec.requester_id;
              l_temp_act_rec.comment := p_act_budget_rec.comment;
              l_temp_act_rec.status_code := 'APPROVED';
               process_approval (
               p_act_budget_rec=> l_temp_act_rec
              ,x_act_budget_rec=> x_act_budget_rec
              ,x_return_status=> l_return_status
              ,x_msg_count=> x_msg_count
              ,x_msg_data=> x_msg_data
            );
            END IF;
        END IF;
      END IF;
      x_start_flow_flag :=l_start_flow_flag;
   END trigger_approval_process;

/*****************************************************************************************/
-- Start of Comments
   --
   -- NAME
   --    get_object_currency
   -- PURPOSE
   --    Return the currency code of the object trying to
   --    associate a budget.
   -- NOTE
   --    To support other objects, the function will need
   --    to be modified.
   -- HISTORY
   -- 15-Aug-2000  choang     Created.
   -- 01-Sep-2000  choang     ARC qualifier for deliverables should be DELV
   -- 02/22/2001   mpande    Added validation for offer
   --    12/23/2002   feliu       Changed for chargback.
   -- 10/21/2003   yzhao      Added for price list
/*****************************************************************************************/
   FUNCTION get_object_currency (
      p_object          IN       VARCHAR2
     ,p_object_id       IN       NUMBER
     ,x_return_status   OUT NOCOPY      VARCHAR2
   )
      RETURN VARCHAR2 IS
      l_currency_code   VARCHAR2 (15);

      CURSOR c_campaign IS
         SELECT transaction_currency_code
           FROM ams_campaigns_vl
          WHERE campaign_id = p_object_id;

      CURSOR c_campaign_schl IS
         SELECT transaction_currency_code
           FROM ams_campaign_schedules_vl
          WHERE schedule_id = p_object_id;

      CURSOR c_eheader IS
         SELECT currency_code_tc
           FROM ams_event_headers_vl
          WHERE event_header_id = p_object_id;

      CURSOR c_eoffer IS
         SELECT currency_code_tc
           FROM ams_event_offers_vl
          WHERE event_offer_id = p_object_id;

      CURSOR c_deliverable IS
         SELECT transaction_currency_code
           FROM ams_deliverables_vl
          WHERE deliverable_id = p_object_id;

      CURSOR c_fund IS
         SELECT currency_code_tc
           FROM ozf_funds_all_b
          WHERE fund_id = p_object_id;

      CURSOR c_offer IS
         SELECT nvl(transaction_currency_code, fund_request_curr_code)
           FROM ozf_offers
          WHERE qp_list_header_id = p_object_id;

      CURSOR c_pricelist IS
         SELECT currency_code
           FROM qp_list_headers_b
          WHERE list_header_id = p_object_id;

      CURSOR c_worksheet IS
         SELECT currency_code
           FROM ozf_worksheet_headers_vl
          WHERE worksheet_header_id = p_object_id;

      CURSOR c_soft_fund IS
         SELECT currency_code
           FROM ozf_request_headers_all_b
          WHERE request_header_id = p_object_id;

      CURSOR c_special_price IS
         SELECT currency_code
           FROM ozf_request_headers_all_b
          WHERE request_header_id = p_object_id;

   BEGIN
      x_return_status            := fnd_api.g_ret_sts_success;

      -- Campaign
      IF p_object = 'CAMP' THEN
         OPEN c_campaign;
         FETCH c_campaign INTO l_currency_code;

         IF c_campaign%NOTFOUND THEN
            CLOSE c_campaign;
            ozf_utility_pvt.error_message ('OZF_ACT_BUDG_NO_CURRENCY');
            x_return_status            := fnd_api.g_ret_sts_error;
            RAISE fnd_api.g_exc_error;
         END IF;

         CLOSE c_campaign;
      -- Campaign Schdules
      ELSIF p_object = 'CSCH' THEN
         OPEN c_campaign_schl;
         FETCH c_campaign_schl INTO l_currency_code;

         IF c_campaign_schl%NOTFOUND THEN
            CLOSE c_campaign_schl;
            ozf_utility_pvt.error_message ('OZF_ACT_BUDG_NO_CURRENCY');
            x_return_status            := fnd_api.g_ret_sts_error;
            RAISE fnd_api.g_exc_error;
         END IF;

         CLOSE c_campaign_schl;
      -- Event Header/Rollup Event
      ELSIF p_object = 'EVEH' THEN
         OPEN c_eheader;
         FETCH c_eheader INTO l_currency_code;

         IF c_eheader%NOTFOUND THEN
            CLOSE c_eheader;
            ozf_utility_pvt.error_message ('OZF_ACT_BUDG_NO_CURRENCY');
            x_return_status            := fnd_api.g_ret_sts_error;
            RAISE fnd_api.g_exc_error;
         END IF;

         CLOSE c_eheader;
      -- Event Offer/Execution Event
      ELSIF p_object IN ('EONE','EVEO') THEN
         OPEN c_eoffer;
         FETCH c_eoffer INTO l_currency_code;

         IF c_eoffer%NOTFOUND THEN
            CLOSE c_eoffer;
            ozf_utility_pvt.error_message ('OZF_ACT_BUDG_NO_CURRENCY');
            x_return_status            := fnd_api.g_ret_sts_error;
            RAISE fnd_api.g_exc_error;
         END IF;

         CLOSE c_eoffer;
      -- Deliverable
      ELSIF p_object = 'DELV' THEN
         OPEN c_deliverable;
         FETCH c_deliverable INTO l_currency_code;

         IF c_deliverable%NOTFOUND THEN
            CLOSE c_deliverable;
            ozf_utility_pvt.error_message ('OZF_ACT_BUDG_NO_CURRENCY');
            x_return_status            := fnd_api.g_ret_sts_error;
            RAISE fnd_api.g_exc_error;
         END IF;

         CLOSE c_deliverable;
      ELSIF p_object = 'FUND' THEN
         OPEN c_fund;
         FETCH c_fund INTO l_currency_code;

         IF c_fund%NOTFOUND THEN
            CLOSE c_fund;
            ozf_utility_pvt.error_message ('OZF_ACT_BUDG_NO_CURRENCY');
            x_return_status            := fnd_api.g_ret_sts_error;
            RAISE fnd_api.g_exc_error;
         END IF;

         CLOSE c_fund;
      -- yzhao: 10/20/2003 for price list   ELSIF p_object = 'OFFR' THEN
      ELSIF p_object = 'OFFR'  THEN
         OPEN c_offer;
         FETCH c_offer INTO l_currency_code;

         IF c_offer%NOTFOUND THEN
            CLOSE c_offer;
            ozf_utility_pvt.error_message ('OZF_ACT_BUDG_NO_CURRENCY');
            x_return_status            := fnd_api.g_ret_sts_error;
            RAISE fnd_api.g_exc_error;
         END IF;

         CLOSE c_offer;
      ELSIF p_object = 'PRIC' THEN
         OPEN c_pricelist;
         FETCH c_pricelist INTO l_currency_code;

         IF c_pricelist%NOTFOUND THEN
            CLOSE c_pricelist;
            ozf_utility_pvt.error_message ('OZF_ACT_BUDG_NO_CURRENCY');
            x_return_status            := fnd_api.g_ret_sts_error;
            RAISE fnd_api.g_exc_error;
         END IF;

         CLOSE c_pricelist;
      ELSIF p_object = 'WKST' THEN
         OPEN c_worksheet;
         FETCH c_worksheet INTO l_currency_code;

         IF c_worksheet%NOTFOUND THEN
            CLOSE c_worksheet;
            ozf_utility_pvt.error_message ('OZF_ACT_BUDG_NO_CURRENCY');
            x_return_status            := fnd_api.g_ret_sts_error;
            RAISE fnd_api.g_exc_error;
         END IF;

         CLOSE c_worksheet;
      ELSIF p_object = 'SOFT_FUND' THEN
         OPEN c_soft_fund;
         FETCH c_soft_fund INTO l_currency_code;

         IF c_soft_fund%NOTFOUND THEN
            CLOSE c_soft_fund;
            ozf_utility_pvt.error_message ('OZF_ACT_BUDG_NO_CURRENCY');
            x_return_status            := fnd_api.g_ret_sts_error;
            RAISE fnd_api.g_exc_error;
         END IF;

         CLOSE c_soft_fund;
      ELSIF p_object = 'SPECIAL_PRICE' THEN
         OPEN c_special_price;
         FETCH c_special_price INTO l_currency_code;

         IF c_special_price%NOTFOUND THEN
            CLOSE c_special_price;
            ozf_utility_pvt.error_message ('OZF_ACT_BUDG_NO_CURRENCY');
            x_return_status            := fnd_api.g_ret_sts_error;
            RAISE fnd_api.g_exc_error;
         END IF;

         CLOSE c_special_price;
      ELSE

         ozf_utility_pvt.error_message ('OZF_ACT_BUDG_NO_CURRENCY');
         x_return_status            := fnd_api.g_ret_sts_error;
         RAISE fnd_api.g_exc_error;
      END IF;

      RETURN l_currency_code;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status            := fnd_api.g_ret_sts_error;

         IF c_campaign%ISOPEN THEN
            CLOSE c_campaign;
         END IF;

         IF c_campaign_schl%ISOPEN THEN
            CLOSE c_campaign_schl;
         END IF;

         IF c_eheader%ISOPEN THEN
            CLOSE c_eheader;
         END IF;

         IF c_eoffer%ISOPEN THEN
            CLOSE c_eoffer;
         END IF;

         IF c_deliverable%ISOPEN THEN
            CLOSE c_deliverable;
         END IF;

         IF c_offer%ISOPEN THEN
            CLOSE c_offer;
         END IF;

         IF c_fund%ISOPEN THEN
            CLOSE c_fund;
         END IF;

         IF c_soft_fund%ISOPEN THEN
            CLOSE c_soft_fund;
         END IF;

         IF c_special_price%ISOPEN THEN
            CLOSE c_special_price;
         END IF;

         RAISE;
   END get_object_currency;


/*****************************************************************************************/
   --
   -- NAME
   --    process_approval
   -- PURPOSE
   --    Handle all tasks needed before a budget line
   --    can be approved.
   -- HISTORY
   -- 14-Sep-2000 choang   Created.
   -- 05/02/2001  mpande   Updated
   -- 07-NOV-2001  Feliu   Added updating of recal_committed amount.
/*****************************************************************************************/
   PROCEDURE process_approval (
      p_act_budget_rec   IN       act_budgets_rec_type
     ,x_act_budget_rec   OUT NOCOPY      act_budgets_rec_type
     ,x_return_status    OUT NOCOPY      VARCHAR2
     ,x_msg_count        OUT NOCOPY      NUMBER
     ,x_msg_data         OUT NOCOPY      VARCHAR2
     ,p_mode             IN       VARCHAR2 :='UPDATE'-- added by mpande 12/27/2001
   ) IS
      l_api_name            CONSTANT VARCHAR2 (30)               := 'Process_Approval';
      l_return_status                VARCHAR2 (1);
      l_temp_rec                     act_budgets_rec_type;
      l_temp_in_rec                  act_budgets_rec_type;
      l_fund_rec                     ozf_funds_pvt.fund_rec_type;
      l_fund_object_version_number   NUMBER;
      l_fund_currency_tc             VARCHAR2 (15); -- a fund's transactional currency code
      l_fund_planned_amount          NUMBER;
      l_fund_committed_amount        NUMBER;
      l_fund_transfer_flag           VARCHAR2 (1)                := fnd_api.g_false;
      l_fund_recal_committed_amount  NUMBER;
      l_univ_planned_amount          NUMBER;
      l_univ_committed_amount        NUMBER;
      l_objfundsum_rec               ozf_objfundsum_pvt.objfundsum_rec_type := NULL;
      l_objfundsum_id     NUMBER;

      l_fund_reconc_msg VARCHAR2(4000);
      l_act_bud_cst_msg VARCHAR2(4000);

      CURSOR c_fund (l_fund_id IN NUMBER) IS
         SELECT object_version_number, currency_code_tc, planned_amt, committed_amt, recal_committed
           FROM ozf_funds_all_b
          WHERE fund_id = l_fund_id;

      -- yzhao: R12 update ozf_object_fund_summary table
      CURSOR c_get_objfundsum_rec(p_object_type IN VARCHAR2, p_object_id IN NUMBER, p_fund_id IN NUMBER) IS
         SELECT objfundsum_id
              , object_version_number
              , planned_amt
              , committed_amt
              , recal_committed_amt
              , plan_curr_planned_amt
              , plan_curr_committed_amt
              , plan_curr_recal_committed_amt
              , univ_curr_planned_amt
              , univ_curr_committed_amt
              , univ_curr_recal_committed_amt
         FROM   ozf_object_fund_summary
         WHERE  object_type = p_object_type
         AND    object_id = p_object_id
         AND    fund_id = p_fund_id;

   BEGIN
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   g_package_name
                                     || '.'
                                     || l_api_name
                                     || ': start');
      END IF;

      -- The from currency should be passed in before currency
      -- conversion can be performed.
      IF    p_act_budget_rec.approved_in_currency IS NULL
         OR p_act_budget_rec.approved_in_currency = fnd_api.g_miss_char THEN
         ozf_utility_pvt.error_message ('OZF_ACT_BUDGET_NO_APPR_CURR');
         RAISE fnd_api.g_exc_error;
      END IF;

     --Added for bug 7425189
     l_fund_reconc_msg := fnd_message.get_string ('OZF', 'OZF_FUND_RECONCILE');
     l_act_bud_cst_msg := fnd_message.get_string ('OZF', 'OZF_ACT_BUDG_CST_UTIL');

      -- check if parent has enough money. add by feliu on 03/26/04 to fix bug 3463554
      IF (p_act_budget_rec.budget_source_type ='CAMP' AND p_act_budget_rec.arc_act_budget_used_by = 'CSCH') OR
         (p_act_budget_rec.budget_source_type ='EVEH' AND p_act_budget_rec.arc_act_budget_used_by = 'EVEO')  OR
         (p_act_budget_rec.budget_source_type ='CAMP' AND p_act_budget_rec.arc_act_budget_used_by = 'OFFR')  -- added to fix bug 4018381
         THEN
        IF ozf_ACTBUDGETRULES_PVT.source_has_enough_money (
           p_source_type  => p_act_budget_rec.budget_source_type,
            p_source_id    => p_act_budget_rec.budget_source_id,
            p_approved_amount => p_act_budget_rec.approved_original_amount
         ) = FND_API.g_false THEN
            ozf_Utility_PVT.error_message ('OZF_ACT_BUDG_NO_MONEY');
            RAISE FND_API.g_exc_error;
         END IF;
      END IF;

      IF p_mode = 'UPDATE' THEN
         init_act_budgets_rec (l_temp_in_rec);
      END IF;




      l_temp_in_rec.activity_budget_id := p_act_budget_rec.activity_budget_id;
      l_temp_in_rec.object_version_number := p_act_budget_rec.object_version_number;
      l_temp_in_rec.approver_id     := p_act_budget_rec.approver_id;
     -- l_temp_in_rec.approved_original_amount := NVL(p_act_budget_rec.approved_original_amount,p_act_budget_rec.request_amount);
      --approved_original_amount is in approved_in_currency and can not use request_currency.
      l_temp_in_rec.approved_original_amount := p_act_budget_rec.approved_original_amount;
      l_temp_in_rec.approved_in_currency := p_act_budget_rec.approved_in_currency;
      l_temp_in_rec.status_code     := p_act_budget_rec.status_code;
      l_temp_in_rec.comment     := p_act_budget_rec.comment;
      l_temp_in_rec.src_curr_req_amt     := p_act_budget_rec.src_curr_req_amt;
      --
      -- Fill in the rest of the columns, to be able to reference
      -- request_currency.
      -- 12/27/2001
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (p_act_budget_rec.request_currency);
         ozf_utility_pvt.debug_message (p_act_budget_rec.request_amount);
         ozf_utility_pvt.debug_message (p_act_budget_rec.transfer_type);
      END IF;
      IF p_mode = 'UPDATE' THEN
        complete_act_budgets_rec (l_temp_in_rec, l_temp_rec);
      ELSE

         l_temp_rec.request_currency := p_act_budget_rec.request_currency;
         l_temp_rec.request_amount := p_act_budget_rec.request_amount;
         l_temp_rec.budget_source_type := p_act_budget_rec.budget_source_type;
         l_temp_rec.budget_source_id := p_act_budget_rec.budget_source_id;
         l_temp_rec.arc_Act_budget_used_by := p_act_budget_rec.arc_act_budget_used_by;
         l_temp_rec.act_budget_used_by_id := p_act_budget_rec.act_budget_used_by_id;
         l_temp_rec.transfer_type := p_act_budget_rec.transfer_type;
         l_temp_rec.approved_in_currency := p_act_budget_rec.approved_in_currency;
         l_temp_rec.approved_original_amount := p_act_budget_rec.approved_original_amount;
         l_temp_rec.parent_source_id := p_act_budget_rec.parent_source_id;

      END IF;

      -- added by feliu on 03/05/04 to fix bug 3487649
      -- modified by rimehrot to avoid duplicate currency conversion. If approved_original_amount
      -- is null, approved_amount is same as request_amount. Else approved_amount is obtained from
      -- approved_original_amount.


      IF l_temp_rec.approved_original_amount IS NULL THEN
         l_temp_rec.approved_amount := l_temp_rec.request_amount;
         IF l_temp_rec.approved_in_currency = l_temp_rec.request_currency THEN
            l_temp_rec.approved_original_amount := l_temp_rec.request_amount;
         ELSE
         -- call the currency conversion wrapper
         --In case of accruals creation, l_temp_rec.request_currency and l_temp_rec.approved_in_currency
         --are same(offer curr). check OZF_Adjustment_EXT_PVT.adjustment_net_accrual.
         --use conversion type profile.

            IF G_DEBUG THEN
               ozf_utility_pvt.debug_message (   l_api_name
                             || ' p_act_budget_rec.exchange_rate_date1: ' || p_act_budget_rec.exchange_rate_date);
            END IF;

            ozf_utility_pvt.convert_currency (
                x_return_status => l_return_status
               ,p_from_currency => l_temp_rec.request_currency
               ,p_to_currency   => l_temp_rec.approved_in_currency
               ,p_conv_date     => p_act_budget_rec.exchange_rate_date --bug 7425189, 8532055
               ,p_from_amount   => l_temp_rec.request_amount
               ,x_to_amount     => l_temp_rec.approved_original_amount
            );

        /*
        --Added for bug 7425189
        IF p_act_budget_rec.justification IN (l_fund_reconc_msg,l_act_bud_cst_msg)
        AND p_act_budget_rec.exchange_rate_date IS NOT NULL THEN
           ozf_utility_pvt.convert_currency (
               x_return_status=> l_return_status
               ,p_from_currency=> l_temp_rec.request_currency
               ,p_to_currency=> l_temp_rec.approved_in_currency
               ,p_conv_date=> p_act_budget_rec.exchange_rate_date
               ,p_from_amount=> l_temp_rec.request_amount
               ,x_to_amount=> l_temp_rec.approved_original_amount
            );
        ELSE

           ozf_utility_pvt.convert_currency (
               x_return_status=> l_return_status
               ,p_from_currency=> l_temp_rec.request_currency
               ,p_to_currency=> l_temp_rec.approved_in_currency
               ,p_from_amount=> l_temp_rec.request_amount
               ,x_to_amount=> l_temp_rec.approved_original_amount
            );
        END IF;
        */

            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      ELSE
          -- approved_original_amount is not null.
          IF l_temp_rec.approved_in_currency = l_temp_rec.request_currency THEN
          -- don't need to convert if currencies are equal
             l_temp_rec.approved_amount := l_temp_rec.approved_original_amount;
          ELSE
                 -- call the currency conversion wrapper
                 -- do not convert twice if the approved_original_amount is same as that requested.
             IF l_temp_rec.approved_original_amount = l_temp_rec.src_curr_req_amt THEN
                l_temp_rec.approved_amount := l_temp_rec.request_amount;
             ELSE

                IF G_DEBUG THEN
                   ozf_utility_pvt.debug_message (   l_api_name
                           || ' p_act_budget_rec.exchange_rate_date2: ' || p_act_budget_rec.exchange_rate_date);
                END IF;

                ozf_utility_pvt.convert_currency (
                    x_return_status => l_return_status
                   ,p_from_currency => l_temp_rec.approved_in_currency
                   ,p_to_currency   => l_temp_rec.request_currency
                   ,p_conv_date     => p_act_budget_rec.exchange_rate_date --bug 7425189, 8532055
                   ,p_from_amount   => l_temp_rec.approved_original_amount
                   ,x_to_amount     => l_temp_rec.approved_amount
                 );

             /*
             --Added for bug 7425189
             IF p_act_budget_rec.justification IN (l_fund_reconc_msg,l_act_bud_cst_msg)
             AND p_act_budget_rec.exchange_rate_date IS NOT NULL THEN
                ozf_utility_pvt.convert_currency (
                    x_return_status=> l_return_status
                   ,p_from_currency=> l_temp_rec.approved_in_currency
                   ,p_to_currency=> l_temp_rec.request_currency
                   ,p_conv_date=> p_act_budget_rec.exchange_rate_date
                   ,p_from_amount=> l_temp_rec.approved_original_amount
                   ,x_to_amount=> l_temp_rec.approved_amount
                 );
             ELSE
                ozf_utility_pvt.convert_currency (
                    x_return_status=> l_return_status
                   ,p_from_currency=> l_temp_rec.approved_in_currency
                   ,p_to_currency=> l_temp_rec.request_currency
                   ,p_from_amount=> l_temp_rec.approved_original_amount
                   ,x_to_amount=> l_temp_rec.approved_amount
                 );

             END IF;
             */

                 IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                    RAISE fnd_api.g_exc_unexpected_error;
                 ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                    RAISE fnd_api.g_exc_error;
                 END IF;
             END IF;
          END IF;
      END IF;
      -- end of added by feliu on 03/05/04


      l_temp_rec.approval_date   := NVL (p_act_budget_rec.approval_date, SYSDATE);

      IF      l_temp_rec.budget_source_type = 'FUND'
          AND l_temp_rec.arc_act_budget_used_by = 'FUND' THEN
         l_fund_transfer_flag       := fnd_api.g_true;
      END IF;

      IF l_fund_transfer_flag = fnd_api.g_false THEN
         -- if the budget source is a fund , then the
         -- fund's planned amount must be decreased
         -- by the request_amount during approval
         -- submission.
         IF    l_temp_rec.budget_source_type = 'FUND'
            OR l_temp_rec.arc_act_budget_used_by = 'FUND' THEN
            ozf_funds_pvt.init_fund_rec (l_fund_rec);

            l_objfundsum_rec := NULL;

            IF l_temp_rec.budget_source_type = 'FUND' THEN
               OPEN c_fund (l_temp_rec.budget_source_id);
               FETCH c_fund INTO l_fund_object_version_number
                                ,l_fund_currency_tc
                                ,l_fund_planned_amount
                                ,l_fund_committed_amount
                                ,l_fund_recal_committed_amount;
               CLOSE c_fund;
               l_fund_rec.fund_id         := l_temp_rec.budget_source_id;

               -- R12: yzhao ozf_object_fund_summary

               OPEN c_get_objfundsum_rec(l_temp_rec.arc_act_budget_used_by
                                       , l_temp_rec.act_budget_used_by_id
                                       , l_temp_rec.budget_source_id);

            ELSIF l_temp_rec.arc_act_budget_used_by = 'FUND' THEN
               OPEN c_fund (l_temp_rec.act_budget_used_by_id);
               FETCH c_fund INTO l_fund_object_version_number
                                ,l_fund_currency_tc
                                ,l_fund_planned_amount
                                ,l_fund_committed_amount
                                ,l_fund_recal_committed_amount;
               CLOSE c_fund;
               l_fund_rec.fund_id         := l_temp_rec.act_budget_used_by_id;
               -- R12: yzhao ozf_object_fund_summary

               OPEN c_get_objfundsum_rec(l_temp_rec.budget_source_type
                                       , l_temp_rec.budget_source_id
                                       , l_temp_rec.act_budget_used_by_id);
            END IF;

/*
            IF c_get_objfundsum_rec%NOTFOUND THEN
               CLOSE c_get_objfundsum_rec;
               IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                  fnd_message.set_name('OZF', 'OZF_OBJFUNDSUM_RECORD_NOT_FOUND');
                  fnd_msg_pub.add;
               END IF;
               RAISE fnd_api.g_exc_error;
            END IF;
*/
            FETCH c_get_objfundsum_rec INTO l_objfundsum_rec.objfundsum_id
                                          , l_objfundsum_rec.object_version_number
                                          , l_objfundsum_rec.planned_amt
                                          , l_objfundsum_rec.committed_amt
                                          , l_objfundsum_rec.recal_committed_amt
                                          , l_objfundsum_rec.plan_curr_planned_amt
                                          , l_objfundsum_rec.plan_curr_committed_amt
                                          , l_objfundsum_rec.plan_curr_recal_committed_amt
                                          , l_objfundsum_rec.univ_curr_planned_amt
                                          , l_objfundsum_rec.univ_curr_committed_amt
                                          , l_objfundsum_rec.univ_curr_recal_committed_amt;
            CLOSE c_get_objfundsum_rec;
            -- R12: yzhao END ozf_object_fund_summary


            l_fund_rec.object_version_number := l_fund_object_version_number;

            -- this is always during transfer
            IF l_temp_rec.request_currency = l_fund_currency_tc THEN
               -- don't need to convert if currencies are equal
               l_fund_rec.planned_amt     := l_temp_rec.request_amount;
            ELSE
               -- convert the request amount to the fund's
               -- currency.  the planned amount for a fund
               -- is stored in the table as a value based
               -- on the transactional currency, so the
               -- request amount must also be based on the
               -- same currency.
               --7030415,

                IF G_DEBUG THEN
                   ozf_utility_pvt.debug_message (   l_api_name
                           || ' p_act_budget_rec.exchange_rate_date3: ' || p_act_budget_rec.exchange_rate_date);
                END IF;

                ozf_utility_pvt.convert_currency (
                  x_return_status => l_return_status
                 ,p_from_currency => l_temp_rec.request_currency
                 ,p_to_currency   => l_fund_currency_tc
                 ,p_conv_date     => p_act_budget_rec.exchange_rate_date --bug 7425189, 8532055
                 ,p_from_amount   => l_temp_rec.request_amount
                 ,x_to_amount     => l_fund_rec.planned_amt
               );

               /*
               --Added for bug 7425189

            IF p_act_budget_rec.justification IN (l_fund_reconc_msg,l_act_bud_cst_msg)
                AND p_act_budget_rec.exchange_rate_date IS NOT NULL THEN

               ozf_utility_pvt.convert_currency (
                  x_return_status=> l_return_status
                 ,p_from_currency=> l_temp_rec.request_currency
                 ,p_to_currency=> l_fund_currency_tc
                 ,p_conv_date=> p_act_budget_rec.exchange_rate_date
                 ,p_from_amount=> l_temp_rec.request_amount
                 ,x_to_amount=> l_fund_rec.planned_amt
               );
           ELSE
           ozf_utility_pvt.convert_currency (
                  x_return_status=> l_return_status
                 ,p_from_currency=> l_temp_rec.request_currency
                 ,p_to_currency=> l_fund_currency_tc
                 ,p_from_amount=> l_temp_rec.request_amount
                 ,x_to_amount=> l_fund_rec.planned_amt
               );
           END IF;
           */
               IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
               END IF;
            END IF;

            IF l_temp_rec.transfer_type = 'REQUEST' THEN
                IF l_temp_rec.approved_in_currency = l_fund_currency_tc THEN
                   -- don't need to convert if currencies are equal
                   l_fund_rec.committed_amt   := l_temp_rec.approved_original_amount;
                ELSE
                   -- convert the approved amount to the fund's
                   -- currency.  the committed amount for a fund
                   -- is stored in the table as a value based
                   -- on the transactional currency, so the
                   -- approved amount must also be based on the
                   -- same currency.  for best results, we'll use
                   -- the original approved amount for conversion.
                   -- 12/26/2001 mpande changed here for transfer
                   --Since this conversion is for updating planned/committed amounts.
                   --In case of utilization the transfer_type is 'UTILIZED'.
                   --So this part will not be executed.

                   ozf_utility_pvt.convert_currency (
                      x_return_status=> l_return_status
                     ,p_from_currency=> l_temp_rec.approved_in_currency
                     ,p_to_currency=> l_fund_currency_tc
                     ,p_from_amount=> l_temp_rec.approved_original_amount
                     ,x_to_amount=> l_fund_rec.committed_amt
                   );

                   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                      RAISE fnd_api.g_exc_unexpected_error;
                   ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                      RAISE fnd_api.g_exc_error;
                   END IF;
                END IF;
            ELSE
                -- in case of transfer the fund amount is approved amount
                l_fund_rec.committed_amt := l_temp_rec.approved_amount;
            END IF ;


                   --Since the conversion given below is used in case
                   --of transfer_type='REQUEST'/'TRANSFER'. hence
                   --So this part will not be executed in case of transfer_type='UTILIZED'.
            -- R12: yzhao ozf_object_fund_summary
            IF g_universal_currency = l_temp_rec.request_currency THEN
               l_univ_planned_amount := l_temp_rec.request_amount;
               l_univ_committed_amount := l_temp_rec.approved_amount;
            ELSIF g_universal_currency = l_fund_currency_tc THEN
               l_univ_planned_amount := l_fund_rec.planned_amt;
               l_univ_committed_amount := l_fund_rec.committed_amt;
            ELSE

                IF G_DEBUG THEN
                   ozf_utility_pvt.debug_message (   l_api_name
                           || ' p_act_budget_rec.exchange_rate_date4: ' || p_act_budget_rec.exchange_rate_date);
                END IF;

                ozf_utility_pvt.convert_currency (
                     x_return_status => l_return_status
                    ,p_from_currency => l_temp_rec.request_currency
                    ,p_to_currency   => g_universal_currency
                    ,p_conv_date     => p_act_budget_rec.exchange_rate_date --bug 7425189, 8532055
                    ,p_from_amount   => l_temp_rec.request_amount
                    ,x_to_amount     => l_univ_planned_amount
                  );

                /*
                --Added for bug 7425189
                IF p_act_budget_rec.justification IN (l_fund_reconc_msg,l_act_bud_cst_msg)
                AND p_act_budget_rec.exchange_rate_date IS NOT NULL THEN
                   ozf_utility_pvt.convert_currency (
                     x_return_status=> l_return_status
                    ,p_from_currency=> l_temp_rec.request_currency
                    ,p_to_currency=> g_universal_currency
                    ,p_conv_date=> p_act_budget_rec.exchange_rate_date
                    ,p_from_amount=> l_temp_rec.request_amount
                    ,x_to_amount=> l_univ_planned_amount
                  );
               ELSE
                  ozf_utility_pvt.convert_currency (
                     x_return_status=> l_return_status
                    ,p_from_currency=> l_temp_rec.request_currency
                    ,p_to_currency=> g_universal_currency
                    ,p_from_amount=> l_temp_rec.request_amount
                    ,x_to_amount=> l_univ_planned_amount
               );
               END IF;
               IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
               END IF;
               */

               IF l_temp_rec.request_amount = l_temp_rec.approved_amount THEN
                  l_univ_committed_amount := l_univ_planned_amount;
               ELSE

                  IF G_DEBUG THEN
                     ozf_utility_pvt.debug_message (   l_api_name
                           || ' p_act_budget_rec.exchange_rate_date5: ' || p_act_budget_rec.exchange_rate_date);
                  END IF;

                  ozf_utility_pvt.convert_currency (
                     x_return_status => l_return_status
                    ,p_from_currency => l_temp_rec.request_currency
                    ,p_to_currency   => g_universal_currency
                    ,p_conv_date     => p_act_budget_rec.exchange_rate_date --bug 7425189, 8532055
                    ,p_from_amount   => l_temp_rec.approved_amount
                    ,x_to_amount     => l_univ_committed_amount
                  );

                  /*
                  --Added for bug 7425189
                  IF p_act_budget_rec.justification IN (l_fund_reconc_msg,l_act_bud_cst_msg)
                  AND p_act_budget_rec.exchange_rate_date IS NOT NULL THEN
                    ozf_utility_pvt.convert_currency (
                     x_return_status=> l_return_status
                    ,p_from_currency=> l_temp_rec.request_currency
                    ,p_to_currency=> g_universal_currency
                    ,p_conv_date=> p_act_budget_rec.exchange_rate_date
                    ,p_from_amount=> l_temp_rec.approved_amount
                    ,x_to_amount=> l_univ_committed_amount
                  );

                 ELSE
                  ozf_utility_pvt.convert_currency (
                     x_return_status=> l_return_status
                    ,p_from_currency=> l_temp_rec.request_currency
                    ,p_to_currency=> g_universal_currency
                    ,p_from_amount=> l_temp_rec.approved_amount
                    ,x_to_amount=> l_univ_committed_amount
                  );
                 END IF;
                 */

                  IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                     RAISE fnd_api.g_exc_unexpected_error;
                  ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                     RAISE fnd_api.g_exc_error;
                  END IF;
               END IF;
            END IF;

            IF G_DEBUG THEN
               ozf_utility_pvt.debug_message (
                  ' process_approval(): fund_currency=' || l_fund_currency_tc
               || '  request_curr=' || l_temp_rec.request_currency
               || '  approved_in_curr=' || l_temp_rec.approved_in_currency
               || '  univ_curr=' || g_universal_currency
               );
               ozf_utility_pvt.debug_message (
                  '  in fund currency: planned_amt=' || l_fund_rec.planned_amt
               || '  committed_amt=' || l_fund_rec.committed_amt
               || '  l_univ_planned_amount=' || l_univ_planned_amount
               || '  l_univ_committed_amount=' || l_univ_committed_amount
            );
            END IF;
            -- R12: yzhao END ozf_object_fund_summary

            IF p_mode = 'UPDATE' THEN
               IF l_temp_rec.transfer_type = 'REQUEST' THEN
                  -- R12: yzhao ozf_object_fund_summary decrease planned amount
                  l_objfundsum_rec.planned_amt := NVL(l_objfundsum_rec.planned_amt, 0) - NVL (l_fund_rec.planned_amt, 0);
                  l_objfundsum_rec.plan_curr_planned_amt := NVL(l_objfundsum_rec.plan_curr_planned_amt, 0)
                                                          - NVL(l_temp_rec.request_amount, 0);
                  l_objfundsum_rec.univ_curr_planned_amt := NVL(l_objfundsum_rec.univ_curr_planned_amt, 0)
                                                          - NVL(l_univ_planned_amount, 0);
                  -- R12: yzhao END ozf_object_fund_summary decrease planned amount
                  l_fund_rec.planned_amt     :=   l_fund_planned_amount
                                                - l_fund_rec.planned_amt;
               ELSE
                  l_fund_rec.planned_amt     := l_fund_planned_amount;
               END IF;
            -- 03/01/2002 added else for all other transactions we donot want to touch fund planned_Amt
            ELSE
               l_fund_rec.planned_amt     := l_fund_planned_amount;
            END IF;



            -- Add the approved amount to the fund's committed amount
            IF l_temp_rec.transfer_type = 'REQUEST' THEN
               IF NVL(p_act_budget_rec.recal_flag,'N') = 'N' THEN
                  l_fund_rec.committed_amt   :=
                                 NVL (l_fund_committed_amount, 0)
                               + NVL (l_fund_rec.committed_amt, 0);
                  -- R12: yzhao ozf_object_fund_summary increase committed amount
                  l_objfundsum_rec.committed_amt := NVL(l_objfundsum_rec.committed_amt, 0)
                                                  + NVL (l_temp_rec.approved_original_amount, 0);
                  l_objfundsum_rec.plan_curr_committed_amt := NVL(l_objfundsum_rec.plan_curr_committed_amt, 0)
                                                            + NVL(l_temp_rec.approved_amount, 0);
                  l_objfundsum_rec.univ_curr_committed_amt := NVL(l_objfundsum_rec.univ_curr_committed_amt, 0)
                                                            + NVL(l_univ_committed_amount, 0);
                  -- R12: yzhao END ozf_object_fund_summary increase committed amount
               ELSE
                  l_fund_rec.committed_amt   :=
                                 NVL (l_fund_committed_amount, 0);
               END IF;
               -- always add the recal committed
               l_fund_rec.recal_committed   :=
                                 NVL (l_fund_recal_committed_amount, 0)
                                + NVL (l_temp_rec.approved_original_amount, 0);
               l_objfundsum_rec.recal_committed_amt := NVL(l_objfundsum_rec.recal_committed_amt, 0)
                                                     + NVL (l_temp_rec.approved_original_amount, 0);
               l_objfundsum_rec.plan_curr_recal_committed_amt := NVL(l_objfundsum_rec.plan_curr_recal_committed_amt, 0)
                                                         + NVL(l_temp_rec.approved_amount, 0);
               l_objfundsum_rec.univ_curr_recal_committed_amt := NVL(l_objfundsum_rec.univ_curr_recal_committed_amt, 0)
                                                         + NVL(l_univ_committed_amount, 0);

            ELSIF l_temp_rec.transfer_type = 'TRANSFER' THEN

               IF NVL(p_act_budget_rec.recal_flag,'N') = 'N' THEN

                   l_fund_rec.committed_amt   :=
                                 NVL (l_fund_committed_amount, 0)
                               - NVL (l_fund_rec.committed_amt, 0);
                   -- R12: yzhao ozf_object_fund_summary decrease committed amount
                   IF G_DEBUG THEN
                   ozf_utility_pvt.debug_message('******************************************************************');
                   ozf_utility_pvt.debug_message('committed_amt '||l_objfundsum_rec.committed_amt);
                   ozf_utility_pvt.debug_message('approved_amount '||l_temp_rec.approved_amount);
                   ozf_utility_pvt.debug_message('plan_curr_committed_amt '||l_objfundsum_rec.plan_curr_committed_amt);
                   ozf_utility_pvt.debug_message('approved_original_amount '||l_temp_rec.approved_original_amount);
                   ozf_utility_pvt.debug_message('univ_curr_committed_amt '||l_objfundsum_rec.univ_curr_committed_amt);
                   ozf_utility_pvt.debug_message('l_univ_committed_amount '||l_univ_committed_amount);
                   END IF;
                   l_objfundsum_rec.committed_amt := NVL(l_objfundsum_rec.committed_amt, 0)
                                                   - NVL (l_temp_rec.approved_amount, 0);
                   l_objfundsum_rec.plan_curr_committed_amt := NVL(l_objfundsum_rec.plan_curr_committed_amt, 0)
                                                             - NVL(l_temp_rec.approved_original_amount, 0);
                   l_objfundsum_rec.univ_curr_committed_amt := NVL(l_objfundsum_rec.univ_curr_committed_amt, 0)
                                                             - NVL(l_univ_committed_amount, 0);

               ELSE
                  l_fund_rec.committed_amt   :=
                                 NVL (l_fund_committed_amount, 0);
               END IF;
               l_fund_rec.recal_committed   :=
                                 NVL (l_fund_recal_committed_amount, 0)
                               - NVL (l_temp_rec.approved_amount, 0);
               -- R12: yzhao ozf_object_fund_summary decrease recal-committed amount
               l_objfundsum_rec.recal_committed_amt := NVL(l_objfundsum_rec.recal_committed_amt, 0)
                                                     - NVL (l_temp_rec.approved_amount, 0);
               l_objfundsum_rec.plan_curr_recal_committed_amt := NVL(l_objfundsum_rec.plan_curr_recal_committed_amt, 0)
                                                         - NVL(l_temp_rec.approved_original_amount, 0);
               l_objfundsum_rec.univ_curr_recal_committed_amt := NVL(l_objfundsum_rec.univ_curr_recal_committed_amt, 0)
                                                         - NVL(l_univ_committed_amount, 0);
               -- R12: yzhao END ozf_object_fund_summary decrease committed amount
            END IF;

            IF G_DEBUG THEN
               ozf_utility_pvt.debug_message ('bef update fund ');
            END IF;

            --Added for bug 7425189, use these 3 columns in fund API to disttinguish the
            --call from reconcile API.
            IF p_act_budget_rec.justification IN (l_fund_reconc_msg,l_act_bud_cst_msg)
            AND p_act_budget_rec.exchange_rate_date IS NOT NULL THEN
                --l_fund_rec.exchange_rate_date := p_act_budget_rec.exchange_rate_date;
                l_fund_rec.description := p_act_budget_rec.justification;
                l_fund_rec.fund_usage := 'TRANSFER';
            END IF;

            --bug 8532055
            l_fund_rec.exchange_rate_date := p_act_budget_rec.exchange_rate_date;

                ozf_funds_pvt.update_fund (
                       p_api_version=> 1.0
                      ,p_init_msg_list=> fnd_api.g_false
                      ,p_commit=> fnd_api.g_false
                      ,p_validation_level=> fnd_api.g_valid_level_full
                      ,x_return_status=> l_return_status
                      ,x_msg_count=> x_msg_count
                      ,x_msg_data=> x_msg_data
                      ,p_fund_rec=> l_fund_rec
                      ,p_mode=> g_cons_fund_mode
                    );

            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            END IF;

            -- R12: yzhao ozf_object_fund_summary update planned_amount/committed_amount


               IF l_objfundsum_rec.objfundsum_id IS NULL THEN
                  l_objfundsum_rec.fund_id := l_temp_rec.budget_source_id;
                  l_objfundsum_rec.fund_currency := l_temp_rec.approved_in_currency;
                  l_objfundsum_rec.object_type := l_temp_rec.arc_act_budget_used_by;
                  l_objfundsum_rec.object_id := l_temp_rec.act_budget_used_by_id;
                  l_objfundsum_rec.object_currency := l_temp_rec.request_currency;


                  IF l_temp_rec.parent_source_id is NOT NULL THEN
                     l_objfundsum_rec.reference_object_id := l_temp_rec.parent_source_id;
                     l_objfundsum_rec.source_from_parent := 'Y';
                     IF l_objfundsum_rec.object_type ='OFFR' OR
                        l_objfundsum_rec.object_type = 'CSCH' THEN
                        l_objfundsum_rec.reference_object_type := 'CAMP';
                     ELSIF l_objfundsum_rec.object_type = 'EVEO' THEN
                        l_objfundsum_rec.reference_object_type := 'EVEH';
                     END IF;
                  END IF;

                  ozf_objfundsum_pvt.create_objfundsum(
                       p_api_version                => 1.0,
                       p_init_msg_list              => Fnd_Api.G_FALSE,
                       p_validation_level           => Fnd_Api.G_VALID_LEVEL_NONE,
                       p_objfundsum_rec             => l_objfundsum_rec,
                       p_conv_date                  => p_act_budget_rec.exchange_rate_date, --bug 8532055
                       x_return_status              => l_return_status,
                       x_msg_count                  => x_msg_count,
                       x_msg_data                   => x_msg_data,
                       x_objfundsum_id              => l_objfundsum_id
                  );
               ELSE

                  IF G_DEBUG THEN
                     ozf_utility_pvt.debug_message('committed_amt '||l_objfundsum_rec.committed_amt);
                     ozf_utility_pvt.debug_message('plan_curr_committed_amt '||l_objfundsum_rec.plan_curr_committed_amt);
                     ozf_utility_pvt.debug_message('univ_curr_committed_amt '||l_objfundsum_rec.univ_curr_committed_amt);
                     ozf_utility_pvt.debug_message('******************************************************************');
                  END IF;

                  ozf_objfundsum_pvt.update_objfundsum(
                       p_api_version                => 1.0,
                       p_init_msg_list              => Fnd_Api.G_FALSE,
                       p_validation_level           => Fnd_Api.G_VALID_LEVEL_NONE,
                       p_objfundsum_rec             => l_objfundsum_rec,
                       p_conv_date                  => p_act_budget_rec.exchange_rate_date, --bug 7425189, 8532055
                       x_return_status              => l_return_status,
                       x_msg_count                  => x_msg_count,
                       x_msg_data                   => x_msg_data
                  );

                /*
                --Added for bug 7425189, call this private API, only meant for budget reconcile.
                IF p_act_budget_rec.justification IN (l_fund_reconc_msg,l_act_bud_cst_msg)
                  AND p_act_budget_rec.exchange_rate_date IS NOT NULL THEN
                  IF G_DEBUG THEN
                    ozf_utility_pvt.debug_message('committed_amt '||l_objfundsum_rec.committed_amt);
                   ozf_utility_pvt.debug_message('plan_curr_committed_amt '||l_objfundsum_rec.plan_curr_committed_amt);
                   ozf_utility_pvt.debug_message('univ_curr_committed_amt '||l_objfundsum_rec.univ_curr_committed_amt);
                   ozf_utility_pvt.debug_message('******************************************************************');
                    END IF;
                   update_reconcile_objfundsum(
                   p_api_version                => 1.0,
                   p_init_msg_list              => Fnd_Api.G_FALSE,
                   p_validation_level           => Fnd_Api.G_VALID_LEVEL_NONE,
                   p_objfundsum_rec             => l_objfundsum_rec,
                   p_conv_date                  => p_act_budget_rec.exchange_rate_date,
                   x_return_status              => l_return_status,
                   x_msg_count                  => x_msg_count,
                   x_msg_data                   => x_msg_data
                   );
                ELSE
                  ozf_objfundsum_pvt.update_objfundsum(
                   p_api_version                => 1.0,
                   p_init_msg_list              => Fnd_Api.G_FALSE,
                   p_validation_level           => Fnd_Api.G_VALID_LEVEL_NONE,
                   p_objfundsum_rec             => l_objfundsum_rec,
                   x_return_status              => l_return_status,
                   x_msg_count                  => x_msg_count,
                   x_msg_data                   => x_msg_data
                   );
                END IF;
                */
             END IF;


            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            END IF;
            -- R12: yzhao END ozf_object_fund_summary decrease planned_amount/committed_amount

         END IF; -- end for fund check
      ELSE
         NULL;
      END IF; -- for fund transfer flag check

      x_act_budget_rec           := l_temp_rec;
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   g_package_name
                                     || '.'
                                     || l_api_name
                                     || ': end');
      END IF;
   END process_approval;

/*****************************************************************************************/
-- Start of Comments
   --
   -- NAME
   --    Revert_Approval
   -- PURPOSE
   --    Revert the changes done when a budget line is
   --    submitted for approval.  For FUND lines, revert
   --    the planned amount.
   -- HISTORY
   -- 17-Sep-2000 choang   created.
/*****************************************************************************************/
   PROCEDURE revert_approval (
      p_act_budget_rec   IN       act_budgets_rec_type
     ,x_act_budget_rec   OUT NOCOPY      act_budgets_rec_type
     ,x_return_status    OUT NOCOPY      VARCHAR2
     ,x_msg_count        OUT NOCOPY      NUMBER
     ,x_msg_data         OUT NOCOPY      VARCHAR2
   ) IS
      l_return_status                VARCHAR2 (1);
      l_temp_rec                     act_budgets_rec_type        := p_act_budget_rec;
      l_fund_rec                     ozf_funds_pvt.fund_rec_type;
      l_fund_object_version_number   NUMBER;
      l_fund_currency_tc             VARCHAR2 (15); -- a fund's transactional currency code
      l_fund_planned_amount          NUMBER;
      l_univ_planned_amount          NUMBER;
      l_objfundsum_rec               ozf_objfundsum_pvt.objfundsum_rec_type := NULL;

      CURSOR c_fund (l_fund_id IN NUMBER) IS
         SELECT object_version_number, currency_code_tc, planned_amt
           FROM ozf_funds_all_b
          WHERE fund_id = l_fund_id;

      -- yzhao: R12 update ozf_object_fund_summary table
      CURSOR c_get_objfundsum_rec(p_object_type IN VARCHAR2, p_object_id IN NUMBER, p_fund_id IN NUMBER) IS
         SELECT objfundsum_id
              , object_version_number
              , planned_amt
              , plan_curr_planned_amt
              , univ_curr_planned_amt
         FROM   ozf_object_fund_summary
         WHERE  object_type = p_object_type
         AND    object_id = p_object_id
         AND    fund_id = p_fund_id;

   BEGIN
      l_temp_rec.status_code     := 'NEW';
      l_temp_rec.comment     := p_act_budget_rec.comment;

      --- fix bug 4174002  to exclude budget transfer since not planned_amt  exists for pending status.
      IF l_temp_rec.budget_source_type = 'FUND'  AND l_temp_rec.arc_act_budget_used_by <> 'FUND' THEN
         -- if the budget source is a fund, then the
         -- fund's planned amount must be incremented
         -- by the request_amount during approval
         -- submission.
         ozf_funds_pvt.init_fund_rec (l_fund_rec);
         OPEN c_fund (l_temp_rec.budget_source_id);
         FETCH c_fund INTO l_fund_object_version_number, l_fund_currency_tc, l_fund_planned_amount;
         CLOSE c_fund;
         l_fund_rec.fund_id         := l_temp_rec.budget_source_id;
         l_fund_rec.object_version_number := l_fund_object_version_number;

         IF l_temp_rec.request_currency = l_fund_currency_tc THEN
            -- don't need to convert if currencies are equal
            l_fund_rec.planned_amt     := l_temp_rec.request_amount;
         ELSE
            -- convert the request amount to the fund's
            -- currency.  the planned amount for a fund
            -- is stored in the table as a value based
            -- on the transactional currency, so the
            -- request amount must also be based on the
            -- same currency.
            ozf_utility_pvt.convert_currency (
               x_return_status=> l_return_status
              ,p_from_currency=> l_temp_rec.request_currency
              ,p_to_currency=> l_fund_currency_tc
              ,p_from_amount=> l_temp_rec.request_amount
              ,x_to_amount=> l_fund_rec.planned_amt
            );

            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

         -- R12: yzhao ozf_object_fund_summary decrease planned_amt
         OPEN c_get_objfundsum_rec(l_temp_rec.arc_act_budget_used_by
                                 , l_temp_rec.act_budget_used_by_id
                                 , l_temp_rec.budget_source_id);
         FETCH c_get_objfundsum_rec INTO l_objfundsum_rec.objfundsum_id
                                       , l_objfundsum_rec.object_version_number
                                       , l_objfundsum_rec.planned_amt
                                       , l_objfundsum_rec.plan_curr_planned_amt
                                       , l_objfundsum_rec.univ_curr_planned_amt;
         IF c_get_objfundsum_rec%NOTFOUND THEN
            CLOSE c_get_objfundsum_rec;
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name('OZF', 'OZF_OBJFUNDSUM_RECORD_NOT_FOUND');
               fnd_msg_pub.add;
            END IF;
            RAISE fnd_api.g_exc_error;
         END IF;
         CLOSE c_get_objfundsum_rec;
         IF g_universal_currency = l_temp_rec.request_currency THEN
            l_univ_planned_amount := l_temp_rec.request_amount;
         ELSIF g_universal_currency = l_fund_currency_tc THEN
            l_univ_planned_amount := l_fund_rec.planned_amt;
         ELSE
            ozf_utility_pvt.convert_currency (
                  x_return_status=> l_return_status
                 ,p_from_currency=> l_temp_rec.request_currency
                 ,p_to_currency=> g_universal_currency
                 ,p_from_amount=> l_temp_rec.request_amount
                 ,x_to_amount=> l_univ_planned_amount
            );
            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
         l_objfundsum_rec.planned_amt := NVL(l_objfundsum_rec.planned_amt, 0) - NVL(l_fund_rec.planned_amt, 0);
         l_objfundsum_rec.plan_curr_planned_amt := NVL(l_objfundsum_rec.plan_curr_planned_amt, 0)
                                                 - NVL(l_temp_rec.request_amount, 0);
         l_objfundsum_rec.univ_curr_planned_amt := NVL(l_objfundsum_rec.univ_curr_planned_amt, 0)
                                                 - NVL(l_univ_planned_amount, 0);
         ozf_objfundsum_pvt.update_objfundsum(
                   p_api_version                => 1.0,
                   p_init_msg_list              => Fnd_Api.G_FALSE,
                   p_validation_level           => Fnd_Api.G_VALID_LEVEL_NONE,
                   p_objfundsum_rec             => l_objfundsum_rec,
                   x_return_status              => l_return_status,
                   x_msg_count                  => x_msg_count,
                   x_msg_data                   => x_msg_data
         );
         IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         END IF;
         -- R12: yzhao END ozf_object_fund_summary decrease planned amount

         -- subtract the request amount, l_fund_rec.planned_amt, from the
         -- fund's planned amount, l_fund_planned_amount.
         l_fund_rec.planned_amt     :=
                                      NVL (l_fund_planned_amount, 0)
                                    - NVL (l_fund_rec.planned_amt, 0);
         ozf_funds_pvt.update_fund (
            p_api_version=> 1.0
           ,p_init_msg_list=> fnd_api.g_false
           , -- allow the calling API to handle
            p_commit=> fnd_api.g_false
           , -- allow the calling API to handle
            p_validation_level=> fnd_api.g_valid_level_full
           ,x_return_status=> l_return_status
           ,x_msg_count=> x_msg_count
           ,x_msg_data=> x_msg_data
           ,p_fund_rec=> l_fund_rec
           ,p_mode=> g_cons_fund_mode
         );

         IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF; -- if source type = FUND

      x_act_budget_rec           := l_temp_rec;
   END revert_approval;



---------------------------------------------------------------------
-- PROCEDURE
--    create_child_act_budget
--
-- PURPOSE
--This API will be called by create_act_budgets and updat_act_budgets to create
-- child budget requests when sourcing from parent.

-- PARAMETERS
--      x_return_status     OUT NOCOPY      VARCHAR2,
--      x_msg_count         OUT NOCOPY      NUMBER,
--      x_msg_data          OUT NOCOPY      VARCHAR2,
--      p_act_budgets_rec   IN       ozf_actbudgets_pvt.act_budgets_rec_type

-- NOTES
-- HISTORY
--    09/24/2002  feliu  Create.
----------------------------------------------------------------------

PROCEDURE  create_child_act_budget (
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2,
      p_act_budgets_rec    IN       ozf_actbudgets_pvt.act_budgets_rec_type,
      p_exchange_rate_type IN VARCHAR2 DEFAULT FND_API.G_MISS_CHAR
   ) IS

      l_return_status             VARCHAR2 (10)                           := fnd_api.g_ret_sts_success;
      l_api_name         CONSTANT VARCHAR2 (30)                           := 'create_child_act_budget';
      l_api_version      CONSTANT NUMBER                                  := 1.0;
      l_msg_data               VARCHAR2 (2000);
      l_msg_count              NUMBER;
      l_full_name        CONSTANT VARCHAR2 (90)                           :=    g_package_name
                                                                             || '.'
                                                                             || l_api_name;
      l_acctd_amount      NUMBER;
      l_total_amount      NUMBER; -- campaign currency
      l_amount            NUMBER;
      l_converted_amt     NUMBER;
      l_amount_remaining  NUMBER   := p_act_budgets_rec.approved_amount;
      l_obj_currency      VARCHAR2 (30) := p_act_budgets_rec.request_currency; -- object currency.
      l_obj_id            NUMBER;  -- campaign currency
      l_act_budgets_rec           ozf_actbudgets_pvt.act_budgets_rec_type;
      l_act_util_rec          ozf_actbudgets_pvt.act_util_rec_type ;
      l_act_budget_id     NUMBER;
      l_rate              NUMBER;
      l_obj_type          VARCHAR2(30);

--nirprasa, fix for bug 8938326. p_obj_type can have values CAMP and EVEH both. So removed the hardcoded
      --value CAMP from both the cursors.
      CURSOR c_parent_source (p_object_id IN NUMBER, p_obj_type IN VARCHAR2) IS
        SELECT fund_id
               ,fund_currency
               ,NVL(committed_amt,0)-NVL(utilized_amt,0) total_amount
               ,NVL(univ_curr_committed_amt,0) total_acctd_amount
        FROM ozf_object_fund_summary
        WHERE object_id =p_object_id
        AND object_type = p_obj_type;

     CURSOR c_total_acct_amt (p_object_id IN NUMBER, p_obj_type IN VARCHAR2) IS
        SELECT SUM(NVL(univ_curr_committed_amt,0))
        FROM ozf_object_fund_summary
        WHERE object_id =p_object_id
        AND object_type = p_obj_type;

   BEGIN

      SAVEPOINT create_child_act_budget;

      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name || ': start');
      END IF;

      x_return_status            := fnd_api.g_ret_sts_success;

    /*  IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
*/

      l_act_budgets_rec.transfer_type := p_act_budgets_rec.transfer_type;

      IF l_act_budgets_rec.transfer_type = 'REQUEST' THEN
         l_obj_id := p_act_budgets_rec.budget_source_id;
         l_obj_type := p_act_budgets_rec.budget_source_type; --fix for bug 8938326
         l_total_amount := p_act_budgets_rec.approved_amount;
         l_obj_currency := p_act_budgets_rec.request_currency;
      ELSE
         l_obj_id := p_act_budgets_rec.act_budget_used_by_id;
         l_obj_type := p_act_budgets_rec.arc_act_budget_used_by;
         l_total_amount := p_act_budgets_rec.approved_original_amount;
         l_obj_currency := p_act_budgets_rec.approved_in_currency;
     END IF;

      l_act_budgets_rec.parent_source_id := l_obj_id;
      l_act_budgets_rec.parent_act_budget_id := p_act_budgets_rec.activity_budget_id;

      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   ': l_total_amount: ' || l_total_amount );
      END IF;

      OPEN c_total_acct_amt(l_obj_id,l_obj_type); --fix for bug 8938326
      FETCH c_total_acct_amt INTO l_acctd_amount;
      CLOSE c_total_acct_amt;

      FOR l_budget_util_rec IN c_parent_source(l_obj_id, l_obj_type) LOOP --fix for bug 8938326

          EXIT WHEN c_parent_source%NOTFOUND;

          l_amount := ozf_utility_pvt.currround(l_budget_util_rec.total_acctd_amount / l_acctd_amount * l_total_amount, l_obj_currency);

          l_amount_remaining :=l_amount_remaining - l_amount;

          IF l_budget_util_rec.fund_currency <> l_obj_currency THEN


          --Added for bug 7030415, This code gets executed when offer sources from Campaign.
             ozf_utility_pvt.convert_currency (
                      x_return_status=> x_return_status
                     ,p_from_currency=> l_obj_currency
                     ,p_to_currency=> l_budget_util_rec.fund_currency
                     ,p_conv_type=> p_exchange_rate_type
                     ,p_from_amount=> l_amount
                     ,x_to_amount=> l_converted_amt
                     ,x_rate=> l_rate
                     );
          ELSE
            l_converted_amt := l_amount;
          END IF;

          IF G_DEBUG THEN
             ozf_utility_pvt.debug_message (   l_full_name || ': l_amount: ' || l_amount);
             ozf_utility_pvt.debug_message (   l_full_name || ': l_converted_amt' || l_converted_amt);
          END IF;

          IF l_act_budgets_rec.transfer_type = 'REQUEST' THEN
             l_act_budgets_rec.budget_source_type := 'FUND';
             l_act_budgets_rec.budget_source_id := l_budget_util_rec.fund_id;
             l_act_budgets_rec.act_budget_used_by_id := p_act_budgets_rec.act_budget_used_by_id;
             l_act_budgets_rec.arc_act_budget_used_by := p_act_budgets_rec.arc_act_budget_used_by;
             l_act_budgets_rec.request_amount := l_amount; -- in object currency.
             l_act_budgets_rec.request_currency := l_obj_currency;
             l_act_budgets_rec.approved_in_currency := l_budget_util_rec.fund_currency;
             l_act_budgets_rec.approved_original_amount :=l_converted_amt;
       ELSE
             l_act_budgets_rec.arc_act_budget_used_by := 'FUND';
             l_act_budgets_rec.act_budget_used_by_id := l_budget_util_rec.fund_id;
             l_act_budgets_rec.budget_source_id := p_act_budgets_rec.budget_source_id;
             l_act_budgets_rec.budget_source_type := p_act_budgets_rec.budget_source_type;
             l_act_budgets_rec.request_amount := l_converted_amt; -- in object currency.
             l_act_budgets_rec.request_currency := l_budget_util_rec.fund_currency;
             l_act_budgets_rec.approved_in_currency := l_obj_currency;
             l_act_budgets_rec.approved_original_amount :=l_amount;
       END IF;

         l_act_budgets_rec.status_code := 'APPROVED';
         l_act_budgets_rec.request_date := SYSDATE;
         l_act_budgets_rec.user_status_id :=
                                         ozf_utility_pvt.get_default_user_status (
                                             'OZF_BUDGETSOURCE_STATUS'
                                             ,l_act_budgets_rec.status_code
                                            );
         l_act_budgets_rec.approval_date := SYSDATE;
         l_act_budgets_rec.approver_id :=  ozf_utility_pvt.get_resource_id (fnd_global.user_id);
         l_act_budgets_rec.requester_id := ozf_utility_pvt.get_resource_id (fnd_global.user_id);

         ozf_actbudgets_pvt.create_act_budgets (
           p_api_version=> l_api_version
          ,x_return_status=> l_return_status
          ,x_msg_count=> l_msg_count
          ,x_msg_data=> l_msg_data
          ,p_act_budgets_rec=> l_act_budgets_rec
          ,p_act_util_rec=> l_act_util_rec
          ,x_act_budget_id=> l_act_budget_id
          ,p_approval_flag=> fnd_api.g_true
         );


         IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
             ROLLBACK TO create_child_act_budget;
             fnd_msg_pub.count_and_get (
              p_count=> x_msg_count
             ,p_data=> x_msg_data
             ,p_encoded=> fnd_api.g_false
             );
         END IF;

         IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         END IF;

         EXIT WHEN l_amount_remaining <= 0;


      END LOOP;

       fnd_msg_pub.count_and_get (
         p_encoded=> fnd_api.g_false
        ,p_count=> x_msg_count
        ,p_data=> x_msg_data
      );


      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name
                                     || ': end');
      END IF;

  EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO create_child_act_budget;
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO create_child_act_budget;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN OTHERS THEN
         ROLLBACK TO create_child_act_budget;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_package_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );

    END create_child_act_budget;

/*commented for bug 8532055
-- nirprasa, Added for bug 7425189
-- NAME
--    complete_amount_fields
--
-- PURPOSE
--    This Procedure fills in amount in fund/object/universal currency if not passed in
--        x_amount_1           converted amount in p_currency_1
--        x_amount_2           converted amount in p_currency_2
--        x_amount_3           converted amount in universal_currency
--     Its accepts conversion date
--
-- NOTES
--
-- HISTORY
--
PROCEDURE complete_amount_fields (
   p_currency_1                 IN  VARCHAR2,
   p_amount_1                   IN  NUMBER,
   p_currency_2                 IN  VARCHAR2,
   p_conv_date                  IN  DATE,
   p_amount_2                   IN  NUMBER,
   p_amount_3                   IN  NUMBER,
   x_amount_1                   OUT NOCOPY NUMBER,
   x_amount_2                   OUT NOCOPY NUMBER,
   x_amount_3                   OUT NOCOPY NUMBER,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
)
IS
  l_return_status               VARCHAR2(30);
BEGIN
   x_amount_1 := p_amount_1;
   x_amount_2 := p_amount_2;
   x_amount_3 := p_amount_3;



   IF NVL(p_amount_1, 0) <> 0 THEN
      IF NVL(p_amount_2, 0) = 0 THEN
          -- fill in amount 2 from amount 1
          IF p_currency_1 = p_currency_2 THEN
             x_amount_2 := p_amount_1;
          ELSE
             ozf_utility_pvt.convert_currency (
                     x_return_status=> l_return_status
                    ,p_from_currency=> p_currency_1
                    ,p_to_currency=> p_currency_2
                    ,p_conv_date=> p_conv_date
                    ,p_from_amount=> p_amount_1
                    ,x_to_amount=> x_amount_2
             );
             IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
             ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
             END IF;
          END IF;
      END IF;

      IF NVL(p_amount_3, 0) = 0 THEN
          -- fill in amount in universal currency from amount 1
          IF g_universal_currency = p_currency_1 THEN
             x_amount_3 := p_amount_1;
          ELSE
             ozf_utility_pvt.convert_currency (
                     x_return_status=> l_return_status
                    ,p_from_currency=> p_currency_1
                    ,p_to_currency=> g_universal_currency
                    ,p_conv_date=> p_conv_date
                    ,p_from_amount=> p_amount_1
                    ,x_to_amount=> x_amount_3
             );
             IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
             ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
             END IF;
          END IF;
      END IF;
   ELSE
      IF NVL(p_amount_2, 0) <> 0 THEN
          -- fill in amount 1 from amount 2
          IF p_currency_1 = p_currency_2 THEN
             x_amount_1 := p_amount_2;
          ELSE
             ozf_utility_pvt.convert_currency (
                     x_return_status=> l_return_status
                    ,p_from_currency=> p_currency_2
                    ,p_to_currency=> p_currency_1
                    ,p_conv_date=> p_conv_date
                    ,p_from_amount=> p_amount_2
                    ,x_to_amount=> x_amount_1
             );
             IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
             ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
             END IF;
          END IF;

          IF NVL(p_amount_3, 0) = 0 THEN
              -- fill in amount in universal currency from amount 2
              IF g_universal_currency = p_currency_2 THEN
                 x_amount_3 := p_amount_2;
              ELSE
                 ozf_utility_pvt.convert_currency (
                         x_return_status=> l_return_status
                        ,p_from_currency=> p_currency_2
                        ,p_to_currency=> g_universal_currency
                        ,p_conv_date=> p_conv_date
                        ,p_from_amount=> p_amount_2
                        ,x_to_amount=> x_amount_3
                 );
                 IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                    RAISE fnd_api.g_exc_unexpected_error;
                 ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                    RAISE fnd_api.g_exc_error;
                 END IF;
              END IF;
          END IF;
      END IF;
   END IF;
END complete_amount_fields;


--nirprasa, Added for bug 7425189,
-- NAME
--    update_reconcile_objfundsum
--
-- PURPOSE
--    This Procedure updates record in object fund summary table
--    for offer's budget reconcile. This API is same as update_objfundsum
--    except it accepts conversion date.
-- NOTES
--
-- HISTORY

PROCEDURE update_reconcile_objfundsum (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_validation_level           IN  NUMBER := Fnd_Api.G_VALID_LEVEL_FULL,
   p_objfundsum_rec             IN  OZF_OBJFUNDSUM_PVT.objfundsum_rec_type,
   p_conv_date                  IN  DATE,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
)
IS
   G_PKG_NAME CONSTANT VARCHAR2(30) := 'OZF_ACTBUDGETS_PVT';
   L_API_VERSION    CONSTANT NUMBER := 1.0;
   L_API_NAME       CONSTANT VARCHAR2(30) := 'update_reconcile_objfundsum';
   L_FULL_NAME      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_objfundsum_rec  OZF_OBJFUNDSUM_PVT.objfundsum_rec_type := p_objfundsum_rec;
   l_amount_1                 NUMBER;
   l_amount_2                 NUMBER;
   l_amount_3                 NUMBER;

BEGIN

   IF (G_DEBUG) THEN
      ozf_utility_pvt.debug_message('Now updating objfundsum_id: '||p_objfundsum_rec.objfundsum_id);
   END IF;

   SAVEPOINT sp_update_reconcile_objfundsum;

   IF (G_DEBUG) THEN
       ozf_utility_pvt.debug_message(l_full_name||': start');
   END IF;

   IF Fnd_Api.To_Boolean (p_init_msg_list) THEN
      Fnd_Msg_Pub.Initialize;
   END IF;

   IF NOT Fnd_Api.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   IF (G_DEBUG) THEN
      ozf_utility_pvt.debug_message(l_full_name ||': validate');
   END IF;

   -- replace g_miss_char/num/date with current column values
   OZF_OBJFUNDSUM_PVT.Complete_objfundsum_Rec(p_objfundsum_rec, l_objfundsum_rec);

   -- currency conversion for planned amount
   complete_amount_fields (
       p_currency_1                 => l_objfundsum_rec.object_currency,
       p_amount_1                   => l_objfundsum_rec.plan_curr_planned_amt,
       p_currency_2                 => l_objfundsum_rec.fund_currency,
       p_amount_2                   => l_objfundsum_rec.planned_amt,
       p_amount_3                   => l_objfundsum_rec.univ_curr_planned_amt,
       p_conv_date                  => p_conv_date,
       x_amount_1                   => l_amount_1,
       x_amount_2                   => l_amount_2,
       x_amount_3                   => l_amount_3,
       x_return_status              => l_return_status,
       x_msg_count                  => x_msg_count,
       x_msg_data                   => x_msg_data
   );


   IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;
   l_objfundsum_rec.plan_curr_planned_amt := l_amount_1;
   l_objfundsum_rec.planned_amt := l_amount_2;
   l_objfundsum_rec.univ_curr_planned_amt := l_amount_3;



   -- currency conversion for committed amount
   complete_amount_fields (
       p_currency_1                 => l_objfundsum_rec.object_currency,
       p_amount_1                   => l_objfundsum_rec.plan_curr_committed_amt,
       p_currency_2                 => l_objfundsum_rec.fund_currency,
       p_amount_2                   => l_objfundsum_rec.committed_amt,
       p_amount_3                   => l_objfundsum_rec.univ_curr_committed_amt,
       p_conv_date                  => p_conv_date,
       x_amount_1                   => l_amount_1,
       x_amount_2                   => l_amount_2,
       x_amount_3                   => l_amount_3,
       x_return_status              => l_return_status,
       x_msg_count                  => x_msg_count,
       x_msg_data                   => x_msg_data
   );
   IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;



   l_objfundsum_rec.plan_curr_committed_amt := l_amount_1;
   l_objfundsum_rec.committed_amt := l_amount_2;
   l_objfundsum_rec.univ_curr_committed_amt := l_amount_3;



   -- currency conversion for recal committed amount
   complete_amount_fields (
       p_currency_1                 => l_objfundsum_rec.object_currency,
       p_amount_1                   => l_objfundsum_rec.plan_curr_recal_committed_amt,
       p_currency_2                 => l_objfundsum_rec.fund_currency,
       p_amount_2                   => l_objfundsum_rec.recal_committed_amt,
       p_amount_3                   => l_objfundsum_rec.univ_curr_recal_committed_amt,
       p_conv_date                  => p_conv_date,
       x_amount_1                   => l_amount_1,
       x_amount_2                   => l_amount_2,
       x_amount_3                   => l_amount_3,
       x_return_status              => l_return_status,
       x_msg_count                  => x_msg_count,
       x_msg_data                   => x_msg_data
   );
   IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;
   l_objfundsum_rec.plan_curr_recal_committed_amt := l_amount_1;
   l_objfundsum_rec.recal_committed_amt := l_amount_2;
   l_objfundsum_rec.univ_curr_recal_committed_amt := l_amount_3;

   -- currency conversion for utilized amount
   complete_amount_fields (
       p_currency_1                 => l_objfundsum_rec.object_currency,
       p_amount_1                   => l_objfundsum_rec.plan_curr_utilized_amt,
       p_currency_2                 => l_objfundsum_rec.fund_currency,
       p_amount_2                   => l_objfundsum_rec.utilized_amt,
       p_amount_3                   => l_objfundsum_rec.univ_curr_utilized_amt,
       p_conv_date                  => p_conv_date,
       x_amount_1                   => l_amount_1,
       x_amount_2                   => l_amount_2,
       x_amount_3                   => l_amount_3,
       x_return_status              => l_return_status,
       x_msg_count                  => x_msg_count,
       x_msg_data                   => x_msg_data
   );
   IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   l_objfundsum_rec.plan_curr_utilized_amt := l_amount_1;
   l_objfundsum_rec.utilized_amt := l_amount_2;
   l_objfundsum_rec.univ_curr_utilized_amt := l_amount_3;

  -- currency conversion for earned amount
   complete_amount_fields (
       p_currency_1                 => l_objfundsum_rec.object_currency,
       p_amount_1                   => l_objfundsum_rec.plan_curr_earned_amt,
       p_currency_2                 => l_objfundsum_rec.fund_currency,
       p_amount_2                   => l_objfundsum_rec.earned_amt,
       p_amount_3                   => l_objfundsum_rec.univ_curr_earned_amt,
       p_conv_date                  => p_conv_date,
       x_amount_1                   => l_amount_1,
       x_amount_2                   => l_amount_2,
       x_amount_3                   => l_amount_3,
       x_return_status              => l_return_status,
       x_msg_count                  => x_msg_count,
       x_msg_data                   => x_msg_data
   );
   IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;
   l_objfundsum_rec.plan_curr_earned_amt := l_amount_1;
   l_objfundsum_rec.earned_amt := l_amount_2;
   l_objfundsum_rec.univ_curr_earned_amt := l_amount_3;

   -- currency conversion for paid amount
   complete_amount_fields (
       p_currency_1                 => l_objfundsum_rec.object_currency,
       p_amount_1                   => l_objfundsum_rec.plan_curr_paid_amt,
       p_currency_2                 => l_objfundsum_rec.fund_currency,
       p_amount_2                   => l_objfundsum_rec.paid_amt,
       p_amount_3                   => l_objfundsum_rec.univ_curr_paid_amt,
       p_conv_date                  => p_conv_date,
       x_amount_1                   => l_amount_1,
       x_amount_2                   => l_amount_2,
       x_amount_3                   => l_amount_3,
       x_return_status              => l_return_status,
       x_msg_count                  => x_msg_count,
       x_msg_data                   => x_msg_data
   );
   IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;
   l_objfundsum_rec.plan_curr_paid_amt := l_amount_1;
   l_objfundsum_rec.paid_amt := l_amount_2;
   l_objfundsum_rec.univ_curr_paid_amt := l_amount_3;

   IF p_validation_level >= Jtf_Plsql_Api.g_valid_level_item THEN
      OZF_OBJFUNDSUM_PVT.Validate_objfundsum (
          p_api_version               => l_api_version,
          p_init_msg_list             => p_init_msg_list,
          p_validation_level          => p_validation_level,
          p_objfundsum_rec            => l_objfundsum_rec,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data,
          x_return_status             => l_return_status
      );
      IF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
         RAISE Fnd_Api.g_exc_unexpected_error;
      ELSIF l_return_status = Fnd_Api.g_ret_sts_error THEN
         RAISE Fnd_Api.g_exc_error;
      END IF;
   END IF;


   IF (G_DEBUG) THEN
     ozf_utility_pvt.debug_message(l_full_name ||': update object fund summary Table');
   END IF;

   UPDATE ozf_object_fund_summary
      SET object_version_number= object_version_number + 1,
          last_update_date         = SYSDATE,
          last_updated_by          = Fnd_Global.User_ID,
          last_update_login        = Fnd_Global.Conc_Login_ID,
          fund_id                  = l_objfundsum_rec.fund_id,
          fund_currency            = l_objfundsum_rec.fund_currency,
          object_type              = l_objfundsum_rec.object_type,
          object_id                = l_objfundsum_rec.object_id,
          object_currency          = l_objfundsum_rec.object_currency,
          reference_object_type    = l_objfundsum_rec.reference_object_type,
          reference_object_id      = l_objfundsum_rec.reference_object_id,
          source_from_parent       = l_objfundsum_rec.source_from_parent,
          planned_amt              = l_objfundsum_rec.planned_amt,
          committed_amt            = l_objfundsum_rec.committed_amt,
          recal_committed_amt      = l_objfundsum_rec.recal_committed_amt,
          utilized_amt             = l_objfundsum_rec.utilized_amt,
          earned_amt               = l_objfundsum_rec.earned_amt,
          paid_amt                 = l_objfundsum_rec.paid_amt,
          plan_curr_planned_amt    = l_objfundsum_rec.plan_curr_planned_amt,
          plan_curr_committed_amt  = l_objfundsum_rec.plan_curr_committed_amt,
          plan_curr_recal_committed_amt  = l_objfundsum_rec.plan_curr_recal_committed_amt,
          plan_curr_utilized_amt   = l_objfundsum_rec.plan_curr_utilized_amt,
          plan_curr_earned_amt     = l_objfundsum_rec.plan_curr_earned_amt,
          plan_curr_paid_amt       = l_objfundsum_rec.plan_curr_paid_amt,
          univ_curr_planned_amt    = l_objfundsum_rec.univ_curr_planned_amt,
          univ_curr_committed_amt  = l_objfundsum_rec.univ_curr_committed_amt,
          univ_curr_recal_committed_amt  = l_objfundsum_rec.univ_curr_recal_committed_amt,
          univ_curr_utilized_amt   = l_objfundsum_rec.univ_curr_utilized_amt,
          univ_curr_earned_amt     = l_objfundsum_rec.univ_curr_earned_amt,
          univ_curr_paid_amt       = l_objfundsum_rec.univ_curr_paid_amt,
          attribute_category       = l_objfundsum_rec.attribute_category,
          attribute1               = l_objfundsum_rec.attribute1,
          attribute2               = l_objfundsum_rec.attribute2,
          attribute3               = l_objfundsum_rec.attribute3,
          attribute4               = l_objfundsum_rec.attribute4,
          attribute5               = l_objfundsum_rec.attribute5,
          attribute6               = l_objfundsum_rec.attribute6,
          attribute7               = l_objfundsum_rec.attribute7,
          attribute8               = l_objfundsum_rec.attribute8,
          attribute9               = l_objfundsum_rec.attribute9,
          attribute10              = l_objfundsum_rec.attribute10,
          attribute11              = l_objfundsum_rec.attribute11,
          attribute12              = l_objfundsum_rec.attribute12,
          attribute13              = l_objfundsum_rec.attribute13,
          attribute14              = l_objfundsum_rec.attribute14,
          attribute15              = l_objfundsum_rec.attribute15
    WHERE objfundsum_id = l_objfundsum_rec.objfundsum_id
    AND   object_version_number = l_objfundsum_rec.object_version_number;

   IF  (SQL%NOTFOUND) THEN
      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         Fnd_Msg_Pub.ADD;
      END IF;
      RAISE Fnd_Api.g_exc_error;
   END IF;

   Fnd_Msg_Pub.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    Fnd_Api.G_FALSE
   );

   IF (G_DEBUG) THEN
      ozf_utility_pvt.debug_message(l_full_name ||': end');
   END IF;


EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO SP_update_reconcile_objfundsum;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO SP_update_reconcile_objfundsum;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK TO SP_update_reconcile_objfundsum;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
END update_reconcile_objfundsum;
*/

END ozf_actbudgets_pvt;

/
