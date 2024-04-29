--------------------------------------------------------
--  DDL for Package Body OZF_BUDGETAPPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_BUDGETAPPROVAL_PVT" as
/*$Header: ozfvbdab.pls 120.9.12010000.5 2010/05/10 10:58:08 nirprasa ship $*/
-- NAME
--   OZF_BudgetApproval_PVT
--
-- HISTORY
-- 04/12/2000  sugupta  CREATED
-- 05/17/2001  mpande   UPDATED to pass user_status_id
-- 01/12/2001  mpande   UPDATED for Note
-- 01/16/2002  feliu    add vendor notification.
-- 01/30/2002  feliu    fix bug 2205213.
-- 02/05/2002  feliu    changed query for partner name.
-- 02/21/2002  feliu    fixed bug 2231003.
-- 10/28/2002  feliu    Change for 11.5.9
-- 10/28/2002  feliu    added budget_request_approval for non_approval budget request.
-- 05/09/2003  feliu    use bind variable for dynamic sql.
-- 12/14/2003  kdass    changed table name from ams_temp_eligibility to ozf_temp_eligibility
-- 01/29/2004  kdass    fix bug 3402233 -- removed the check for debug level for the messages.
-- 02/03/2004  kdass    fix bug 3380548 -- added new procedure revert_approved_request
-- 02/12/2004  kdass    fix bug 3436425 -- removed raise and exit statements from conc_validate_offer_budget
-- 02/23/2004  kdass    fix bug 3457111 -- modified the cursor query c_check_items in check_product_market_strict
-- 06/08/2004  Ribha    Fix Bug 3661777 -- modified the notification message OZF_OFFER_VALIDATION_MESSAGE to include budget and offer names
-- 12/06/2004  feliu    fix bug 4032040.
-- 03/16/2005  feliu    change size from 50 to 240 to fix issue 2 in bug 4240968
-- 08/31/2005  kdass    fixed bug 4338544
-- 12/05/2005  kdass    fixed bug 4662453
-- 12/09/2005  kdass    bug 4870218 - SQL Repository fixes
-- 04/24/2008  nirprasa bug 6995376 - SD offer issue.
-- 11/28/2008  nirprasa bug 7272250 - changed size of l_temp_sql in denorm_product_for_one_budget
-- 8/4/2009    nepanda  Fix for bug # 8556176 -- change size from 50 to 2000 to accomodate long offer names
-- 08/06/2009  nirprasa Fix Bug 7599501 change size from 2000 to 32000 of l_temp_sql in validate_product_by_each_line
-- 05/10/2010  nirprasa Fix Bug 9305526 SDR CREATION API WAITS TILL OFFER VALIDATION PROGRAM COMPLETES, CAUSING MAJOR PE

G_PACKAGE_NAME CONSTANT VARCHAR2(30) := 'OZF_BudgetApproval_PVT';
G_FILE_NAME    CONSTANT VARCHAR2(12) := 'ozfvbdab.pls';
g_cons_fund_mode  CONSTANT VARCHAR2(30) := 'WORKFLOW';
g_status_type    CONSTANT VARCHAR2(30)         := 'OZF_BUDGETSOURCE_STATUS';
G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);

-------------------------------------------------------------------
-- NAME
--    Approve_ActBudget
-- PURPOSE
--    Called by the money owner to approve the
--    requested budget amount.  The API is called
--    from Workflow.

PROCEDURE Approve_ActBudget (
   p_api_version        IN     NUMBER,
   p_init_msg_list      IN     VARCHAR2 := FND_API.G_FALSE,
   p_commit             IN     VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN     NUMBER := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY    VARCHAR2,
   x_msg_count          OUT NOCOPY    NUMBER,
   x_msg_data           OUT NOCOPY    VARCHAR2,

   p_activity_budget_id IN     NUMBER,
   p_approver_id        IN     NUMBER,
   p_approved_amount    IN     NUMBER,
   p_approved_currency  IN     VARCHAR2,
   -- 11/12/2001 mpande added the following
   p_comment               IN     VARCHAR2 := NULL

);

-------------------------------------------------------------------
-- NAME
--    Reject_ActBudget
-- PURPOSE
--    Called by the money owner to reject the
--    requested budget amount.  The API is called
--    from Workflow.
PROCEDURE Reject_ActBudget (
   p_api_version        IN     NUMBER,
   p_init_msg_list      IN     VARCHAR2 := FND_API.G_FALSE,
   p_commit             IN     VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN     NUMBER := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY    VARCHAR2,
   x_msg_count          OUT NOCOPY    NUMBER,
   x_msg_data           OUT NOCOPY    VARCHAR2,

   p_activity_budget_id IN     NUMBER,
   p_approver_id        IN     NUMBER,
   -- 11/12/2001 mpande added the following
   p_comment               IN     VARCHAR2 := NULL

);

--------------------------------------------------------------------------
--  yzhao: internal procedure called by wf_respond() to fix bug 2750841(same as 2741039)
--------------------------------------------------------------------------
    FUNCTION find_org_id (p_actbudget_id IN NUMBER) RETURN number IS
      l_org_id number := NULL;

      CURSOR get_fund_org_csr(p_id in number) IS
      SELECT org_id
      FROM ozf_funds_all_b
      WHERE fund_id = (SELECT budget_source_id FROM ozf_act_budgets
                       WHERE activity_budget_id = p_id);

    BEGIN

     OPEN  get_fund_org_csr(p_actbudget_id);
     FETCH get_fund_org_csr INTO l_org_id;
     CLOSE get_fund_org_csr;

     RETURN l_org_id;
    END find_org_id;
--------------------------------------------------------------------------
--  yzhao: internal procedure called by wf_respond() to fix bug 2750841(same as 2741039)
--------------------------------------------------------------------------
    PROCEDURE set_org_ctx (p_org_id IN NUMBER) IS
    BEGIN

         IF p_org_id is not NULL THEN
           fnd_client_info.set_org_context(to_char(p_org_id));
         END IF;

    END set_org_ctx;
--------------------------------------------------------------------------


-------------------------------------------------------------------
-- NAME
--    WF_Respond
-- PURPOSE
--    Interface for Workflow to communicate the approver's
--    response to the request for money.
-- HISTORY
-- 12-Sep-2000 choang   Created.
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
)
IS
   l_api_name        CONSTANT VARCHAR2(30) := 'WF_Respond';
   l_api_version     CONSTANT NUMBER := 1.0;

   l_status_code     VARCHAR2(30);
   l_act_budget_rec  OZF_ActBudgets_PVT.Act_Budgets_Rec_Type;
   l_org_id          NUMBER;

   CURSOR c_status_code (p_status_id IN NUMBER) IS
      SELECT system_status_code
      FROM   ams_user_statuses_vl
      WHERE  user_status_id = p_status_id;
BEGIN
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                              p_api_version,
                              l_api_name,
                              G_PACKAGE_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN c_status_code (p_respond_status_id);
   FETCH c_status_code INTO l_status_code;
   CLOSE c_status_code;

   -- [BEGIN OF BUG 2750841(same as 2741039) FIXING by yzhao 01/10/2003]
   -- get budget's org_id so workflow resumes requestor's responsibility
   l_org_id := find_org_id (p_activity_budget_id);
   -- set org_context since workflow mailer does not set the context
   set_org_ctx (l_org_id);
   -- [END OF BUG 2750841(same as 2741039) FIXING by yzhao 01/10/2003]

   IF l_status_code = 'APPROVED' THEN
      Approve_ActBudget (
         p_api_version        => 1.0,
         p_init_msg_list      => FND_API.g_false,
         p_commit             => FND_API.g_false,
         p_validation_level   => p_validation_level,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data,

         p_activity_budget_id => p_activity_budget_id,
         p_approver_id        => p_approver_id,
         p_approved_amount    => p_approved_amount,
         p_approved_currency  => p_approved_currency,
          -- 11/12/2001 mpande added the following
         p_comment            => p_comment
      );
   ELSIF l_status_code = 'REJECTED' THEN
      Reject_ActBudget (
         p_api_version        => 1.0,
         p_init_msg_list      => FND_API.g_false,
         p_commit             => FND_API.g_false,
         p_validation_level   => p_validation_level,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data,

         p_activity_budget_id => p_activity_budget_id,
         p_approver_id        => p_approver_id,
          -- 11/12/2001 mpande added the following
         p_comment            => p_comment
      );
   ELSE
      -- an error has occurred during the Workflow
      -- process, so revert the status to NEW -- rely
      -- on WF to generate a notification.
      OZF_ActBudgets_PVT.Init_Act_Budgets_Rec (l_act_budget_rec);
      l_act_budget_rec.activity_budget_id := p_activity_budget_id;
      l_act_budget_rec.status_code := 'NEW';
      l_act_budget_rec.user_status_id := ozf_utility_pvt.get_default_user_status(g_status_type, l_act_budget_rec.status_code);
      -- 11/12/2001 mpande added the following
      l_act_budget_rec.comment := p_comment ;
      OZF_ActBudgets_PVT.Update_Act_Budgets (
         p_api_version     => 1.0,
         p_init_msg_list      => FND_API.g_false,
         p_commit             => FND_API.g_false,
         p_validation_level   => p_validation_level,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         p_act_budgets_rec => l_act_budget_rec
      );
   END IF;

   IF (p_commit = FND_API.g_true) THEN
      COMMIT WORK;
   END IF;
END WF_Respond;


-------------------------------------------------------------------
-- NAME
--    Approve_ActBudget
-- PURPOSE
--    Called by the money owner to approve the
--    requested budget amount.  The API is called
--    from Workflow.
-- HISTORY
-- 16-Aug-2000 choang   Created.
PROCEDURE Approve_ActBudget (
   p_api_version        IN     NUMBER,
   p_init_msg_list      IN     VARCHAR2 := FND_API.G_FALSE,
   p_commit             IN     VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN     NUMBER := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY    VARCHAR2,
   x_msg_count          OUT NOCOPY    NUMBER,
   x_msg_data           OUT NOCOPY    VARCHAR2,

   p_activity_budget_id IN     NUMBER,
   p_approver_id        IN     NUMBER,
   p_approved_amount    IN     NUMBER,
   p_approved_currency  IN     VARCHAR2,
   -- 11/12/2001 mpande added the following
   p_comment               IN     VARCHAR2 := NULL
)
IS
   l_act_budgets_rec    OZF_ActBudgets_PVT.Act_Budgets_Rec_Type;
BEGIN
   OZF_ActBudgets_PVT.Init_Act_Budgets_Rec (l_act_budgets_rec);
   l_act_budgets_rec.activity_budget_id := p_activity_budget_id;
   l_act_budgets_rec.status_code := 'APPROVED';
      --05/17/2001 mpande
   l_act_budgets_rec.user_status_id := ozf_utility_pvt.get_default_user_status(g_status_type, l_act_budgets_rec.status_code);
   l_act_budgets_rec.approver_id := p_approver_id;
   l_act_budgets_rec.approved_in_currency := p_approved_currency;
   l_act_budgets_rec.approved_original_amount := p_approved_amount;
      -- 11/12/2001 mpande added the following
      l_act_budgets_rec.comment := p_comment ;
   OZF_ActBudgets_PVT.Update_Act_Budgets (
      p_api_version     => 1.0,
      p_init_msg_list   => p_init_msg_list,
      p_commit          => p_commit,
      p_validation_level   => p_validation_level,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_act_budgets_rec => l_act_budgets_rec
   );
END Approve_ActBudget;

-------------------------------------------------------------------
-- NAME
--    Reject_ActBudget
-- PURPOSE
--    Called by the money owner to reject the
--    requested budget amount.  The API is called
--    from Workflow.
-- HISTORY
-- 16-Aug-2000 choang   Created.
PROCEDURE Reject_ActBudget (
   p_api_version        IN     NUMBER,
   p_init_msg_list      IN     VARCHAR2 := FND_API.G_FALSE,
   p_commit             IN     VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN     NUMBER := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY    VARCHAR2,
   x_msg_count          OUT NOCOPY    NUMBER,
   x_msg_data           OUT NOCOPY    VARCHAR2,

   p_activity_budget_id IN     NUMBER,
   p_approver_id        IN     NUMBER,
   -- 11/12/2001 mpande added the following
   p_comment               IN     VARCHAR2 := NULL
)
IS
   l_act_budgets_rec    OZF_ActBudgets_PVT.Act_Budgets_Rec_Type;
   -- add by feliu on 02/24/04 for soft fund. when request is rejected, the soft fund
   -- approval should be revoke.
   l_request_header_id  NUMBER;

   CURSOR c_req_rec (p_act_budget_id IN NUMBER )IS
     SELECT req.request_header_id
     FROM ozf_request_headers_all_b req, ozf_act_budgets act
     WHERE req.offer_id = act.act_budget_used_by_id
     AND act.activity_budget_id = p_act_budget_id;

BEGIN
   OPEN c_req_rec(p_activity_budget_id);
   FETCH c_req_rec INTO l_request_header_id;
   CLOSE c_req_rec;

   IF l_request_header_id is NOT NULL THEN
       UPDATE ozf_approval_access
       SET    approval_access_flag = 'Y'
       WHERE object_type ='SOFT_FUND'
       AND object_id = l_request_header_id
       AND approval_level = (SELECT min(approval_level) from ozf_approval_access  WHERE object_type ='SOFT_FUND'
       AND object_id = l_request_header_id );
   END IF;

   OZF_ActBudgets_PVT.Init_Act_Budgets_Rec (l_act_budgets_rec);
   l_act_budgets_rec.activity_budget_id := p_activity_budget_id;
   l_act_budgets_rec.approver_id := p_approver_id;
   l_act_budgets_rec.status_code := 'REJECTED';
   --05/17/2001 mpande
   l_act_budgets_rec.user_status_id := ozf_utility_pvt.get_default_user_status(g_status_type, l_act_budgets_rec.status_code);
      -- 11/12/2001 mpande added the following
      l_act_budgets_rec.comment := p_comment ;
   OZF_ActBudgets_PVT.Update_Act_Budgets (
      p_api_version     => 1.0,
      p_init_msg_list   => p_init_msg_list,
      p_commit          => p_commit,
      p_validation_level   => p_validation_level,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_act_budgets_rec => l_act_budgets_rec
   );
END Reject_ActBudget;

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
)
IS
BEGIN
   null;
END Close_ActBudget;

-------------------------------------------------------------------
-- NAME
--  Notify vendor
-- PURPOSE
--  Notify the vendor wheneever a partner creates a budget line
-- History
-- Created Mpande  01/03/2002
----------------------------------------------------------------
PROCEDURE notify_vendor (
   p_act_budget_rec IN OZF_ACTBUDGETS_PVT.Act_Budgets_Rec_Type,
   x_return_status      OUT NOCOPY    VARCHAR2,
   x_msg_count          OUT NOCOPY    NUMBER,
   x_msg_data           OUT NOCOPY    VARCHAR2)
IS

   CURSOR c_camp_owner IS
      SELECT owner_user_id ,status_code
      FROM  ams_campaigns_all_b
      WHERE campaign_id = p_act_budget_rec.act_budget_used_by_id;

   CURSOR c_partner_name IS
      SELECT  act.request_amount,NVL(rsc.partner_party_name,'Partner')
         , NVL(camp.description,''),
             camp.source_code, TO_CHAR(camp.actual_exec_start_date),TO_CHAR(camp.actual_exec_end_date),camp.campaign_name
      FROM ozf_act_budgets act, ams_campaigns_vl camp, pv_resource_info_v rsc
      WHERE act.activity_budget_id = p_act_budget_rec.activity_budget_id
      AND act.act_budget_used_by_id = camp.campaign_id
      AND act.requester_Id = rsc.rsc_resource_id(+);

   CURSOR c_approved_amt IS
      SELECT SUM(approved_amount)
      FROM ozf_act_budgets
      WHERE act_budget_used_by_id = p_act_budget_rec.act_budget_used_by_id
      AND arc_act_budget_used_by = 'CAMP'
      AND budget_source_type = 'FUND'
      AND status_code = 'APPROVED';

l_camp_owner_id         NUMBER;
l_return_status         VARCHAR2(1) := FND_API.g_ret_sts_success;
l_notification_id       NUMBER;
l_camp_status           VARCHAR2(30);
l_strSubject            VARCHAR2(200);
l_partner_name          VARCHAR2(30);
l_campaign_name         VARCHAR2(30);
l_campaign_id           NUMBER;
l_source_code           VARCHAR2(30);
l_request_amt           NUMBER;
l_approved_amt          NUMBER;
l_start_date            VARCHAR2(30);
l_end_date              VARCHAR2(30);
l_camp_desc             VARCHAR2(100);
l_strBody               VARCHAR2(2000);

BEGIN
   OPEN c_camp_owner;
   FETCH c_camp_owner INTO l_camp_owner_id,l_camp_status;
   CLOSE c_camp_owner;

   IF l_camp_status = 'ACTIVE' THEN

      OPEN c_partner_name;
      FETCH c_partner_name INTO l_request_amt, l_partner_name
               ,l_camp_desc,l_source_code,l_start_date,l_end_date,l_campaign_name;
      CLOSE c_partner_name;

      OPEN c_approved_amt ;
      FETCH c_approved_amt INTO l_approved_amt;
      CLOSE c_approved_amt;

      fnd_message.set_name('OZF', 'OZF_PARTNER_SOURCING_SUBJECT');
      fnd_message.set_token ('BUDGET_AMT', l_request_amt, FALSE);
      fnd_message.set_token ('PARTNER_NAME', l_partner_name, FALSE);
      l_strSubject := Substr(fnd_message.get,1,200);

      fnd_message.set_name('OZF', 'OZF_NOTIFY_HEADERLINE');
      l_strBody := fnd_message.get ||fnd_global.local_chr(10)||fnd_global.local_chr(10);
      fnd_message.set_name ('OZF', 'OZF_VENDOR_MESSAGE');
      fnd_message.set_token ('PARTNER_NAME', l_partner_name, FALSE);
      fnd_message.set_token ('CAMP_NUMBER', l_source_code, FALSE);
      fnd_message.set_token ('CAMP_NAME', l_campaign_name, FALSE);
      fnd_message.set_token ('CAMP_DESC', l_camp_desc, FALSE);
      fnd_message.set_token ('START_DATE', l_start_date, FALSE);
      fnd_message.set_token ('END_DATE', l_end_date, FALSE);
      fnd_message.set_token ('REQUEST_AMT', l_request_amt, FALSE);
      fnd_message.set_token ('APPROVED_AMT', l_approved_amt, FALSE);
      l_strBody   := l_strBody || Substr(fnd_message.get,1,1000);

      fnd_message.set_name('OZF', 'OZF_NOTIFY_FOOTER');
      l_strBody := l_strBody || fnd_global.local_chr(10) || fnd_global.local_chr(10) ||fnd_message.get ;

      ozf_utility_pvt.send_wf_standalone_message(
                          p_subject => l_strSubject
                          ,p_body  => l_strBody
                          ,p_send_to_res_id  => l_camp_owner_id
                          ,x_notif_id  => l_notification_id
                          ,x_return_status  => l_return_status
                         );

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

   END IF;
EXCEPTION
WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
END notify_vendor;


/* zy: print whole string. For debug only. Remove them when done
PROCEDURE zy_print( p_str  VARCHAR2) IS
  l_int       NUMBER := 1;
  l_len       NUMBER;
BEGIN
  l_len := length(p_str);
  WHILE l_int <= l_len LOOP
    dbms_output.put_line(substr(p_str, l_int, 250));
    l_int := l_int + 250;
  END LOOP;
END;
*/


-------------------------------------------------------------------
-- NAME
--    revert_approved_request
-- PURPOSE
--    reverts all the approved budget lines for an offer in case the
--    relaxed product/customer validation fails
-- History
--    Created  kdass    02-Feb-2004
--    changed by feliu  08/05/2005
----------------------------------------------------------------
PROCEDURE revert_approved_request (
   p_offer_id          IN     NUMBER,    -- offer id
   x_return_status     OUT NOCOPY    VARCHAR2,
   x_msg_count         OUT NOCOPY    NUMBER,
   x_msg_data          OUT NOCOPY    VARCHAR2)
IS

   l_act_budgets_rec        ozf_actbudgets_pvt.act_budgets_rec_type;
   l_fund_rec               ozf_funds_pvt.fund_rec_type;
   l_activity_budget_id     NUMBER;
   l_budget_source_id       NUMBER;
   l_committed_amt          NUMBER;
   l_return_status          VARCHAR2(20);
   l_msg_data               VARCHAR2(2000) := NULL;
   l_msg_count            NUMBER;
   l_object_version_number  NUMBER;
  -- l_util_object_version    NUMBER;
  -- l_utilization_id         NUMBER;

   --kdass 09-DEC-2005 bug 4870218 - SQL ID# 14892067
   -- get all the approved budget lines for an offer
   CURSOR c_get_actbudgets IS
     SELECT act.activity_budget_id, act.budget_source_id,
            (fund.committed_amt - act.request_amount) committed_amt,
        fund.object_version_number
     FROM ozf_act_budgets act, ozf_funds_all_b fund
     WHERE act.arc_act_budget_used_by = 'OFFR'
       AND act.act_budget_used_by_id = p_offer_id
       AND act.transfer_type = 'REQUEST'
       AND act.status_code = 'APPROVED'
       AND act.budget_source_id = fund.fund_id;

/*
     SELECT act.activity_budget_id, act.budget_source_id,
            (fund.committed_amt - act.request_amount) committed_amt,
        fund.object_version_number, util.object_version_number util_object_version,
        util.utilization_id
     FROM ozf_act_budgets act, ozf_fund_details_v fund, ozf_funds_utilized_all_b util
     WHERE act.arc_act_budget_used_by = 'OFFR'
       AND act.act_budget_used_by_id = p_offer_id
       AND act.transfer_type = 'REQUEST'
       AND act.status_code = 'APPROVED'
       AND act.budget_source_id = fund.fund_id
       AND act.activity_budget_id = util.ams_activity_budget_id;
*/
BEGIN

   SAVEPOINT revert_approved_request;

   OPEN c_get_actbudgets;
   LOOP
      FETCH c_get_actbudgets INTO l_activity_budget_id, l_budget_source_id, l_committed_amt,
            l_object_version_number;
      EXIT WHEN c_get_actbudgets%NOTFOUND OR c_get_actbudgets%NOTFOUND is NULL;

      l_fund_rec.fund_id := l_budget_source_id;
      l_fund_rec.committed_amt := l_committed_amt;
      l_fund_rec.object_version_number := l_object_version_number;

      -- reduce the committed amount of the budget
      ozf_funds_pvt.update_fund( p_api_version => 1.0
                ,p_init_msg_list => fnd_api.g_false
                ,p_commit => fnd_api.g_false
                ,p_validation_level => fnd_api.g_valid_level_full
                ,x_return_status => l_return_status
                ,x_msg_count => l_msg_count
                ,x_msg_data => l_msg_data
                ,p_fund_rec => l_fund_rec
                ,p_mode => jtf_plsql_api.g_update
                   );

      IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         RAISE fnd_api.G_EXC_ERROR;
      END IF;

      l_act_budgets_rec.activity_budget_id := l_activity_budget_id;
      l_act_budgets_rec.status_code := 'NEW';
      l_act_budgets_rec.approval_date := fnd_api.g_miss_date;
      l_act_budgets_rec.approver_id := fnd_api.g_miss_num;
      l_act_budgets_rec.approved_amount := fnd_api.g_miss_num;
      l_act_budgets_rec.approved_original_amount := fnd_api.g_miss_num;
      l_act_budgets_rec.approved_in_currency := fnd_api.g_miss_char;

      -- revert the APPROVED budget line to NEW
      ozf_actbudgets_pvt.update_act_budgets ( p_api_version => 1.0
                         ,p_init_msg_list  =>  fnd_api.g_false
                         ,p_commit => fnd_api.g_false
                         ,p_validation_level => fnd_api.g_valid_level_full
                         ,x_return_status => l_return_status
                         ,x_msg_count => l_msg_count
                         ,x_msg_data =>  l_msg_data
                         ,p_act_budgets_rec  => l_act_budgets_rec);

      IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         RAISE fnd_api.G_EXC_ERROR;
      END IF;

/*
      -- delete utilization record
      ozf_fund_utilized_pvt.delete_utilization ( p_api_version => 1.0
                        ,p_init_msg_list => fnd_api.g_false
                        ,p_commit => fnd_api.g_false
                            ,x_return_status => l_return_status
                            ,x_msg_count => l_msg_count
                            ,x_msg_data =>  l_msg_data
                            ,p_utilization_id => l_utilization_id
                            ,p_object_version => l_util_object_version);

      IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         RAISE fnd_api.G_EXC_ERROR;
      END IF;
  */
   END LOOP;

   CLOSE c_get_actbudgets;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO revert_approved_request;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (
          p_count   => x_msg_count
        , p_data    => x_msg_data
        , p_encoded => fnd_api.g_false
      );

END revert_approved_request;

-------------------------------------------------------------------
-- NAME
--    check_product_market_strict
-- PURPOSE
--    private procedure to check for
--        any offer's product, if it is not in budget's product list
--        any offer's party, if it is not in budget's party list
--        any budget's excluded product, if it is in offer's product list
--        any budget's excluded party, if it is in offer's party list
-- History
--    Created  kdass    22-Sep-2003    11.5.10 Offer Budget Validation
----------------------------------------------------------------
PROCEDURE check_product_market_strict (
   p_exclude_only    IN            BOOLEAN,
   x_return_status      OUT NOCOPY    VARCHAR2,
   x_valid_flag         OUT NOCOPY    VARCHAR2)
IS
   CURSOR c_check_items IS
     SELECT 1
     FROM   ozf_temp_eligibility  offr
     WHERE  object_type = 'OFFR'
     AND    offr.eligibility_id > 0
     AND   (
             (NOT EXISTS
                (SELECT 1
                 FROM   ozf_temp_eligibility fund
                 WHERE  fund.object_type = 'FUND'
                 AND    fund.exclude_flag = 'N'
                 AND    fund.eligibility_id > 0
                 AND    fund.eligibility_id = offr.eligibility_id))
             OR
             (EXISTS
                (SELECT 1
                 FROM   ozf_temp_eligibility fund
                 WHERE  fund.object_type = 'FUND'
                 AND    fund.exclude_flag = 'Y'
                 AND    fund.eligibility_id > 0
                 AND    fund.eligibility_id = offr.eligibility_id))
           );

   CURSOR c_check_exclude_items IS
     SELECT 1
     FROM   ozf_temp_eligibility fund
     WHERE  fund.object_type = 'FUND'
     AND    exclude_flag = 'Y'
     AND    fund.eligibility_id > 0
     AND    EXISTS
     (SELECT 1
      FROM   ozf_temp_eligibility offr
      WHERE  offr.object_type = 'OFFR'
      AND    offr.eligibility_id > 0
      AND    offr.eligibility_id = fund.eligibility_id);

   l_exist_number NUMBER := NULL;

BEGIN

    IF p_exclude_only THEN
        OPEN c_check_exclude_items;
        FETCH c_check_exclude_items INTO l_exist_number;
        CLOSE c_check_exclude_items;
        --dbms_output.put_line('l_exist_number: ' || l_exist_number);
        IF l_exist_number = 1 THEN
            x_return_status := fnd_api.g_ret_sts_success;
            x_valid_flag := fnd_api.g_false;
            RETURN;
        END IF;
    ELSE
        OPEN c_check_items;
        FETCH c_check_items INTO l_exist_number;
        CLOSE c_check_items;
        ----dbms_output.put_line('l_exist_number: ' || l_exist_number);
        IF l_exist_number = 1 THEN
        x_return_status := fnd_api.g_ret_sts_success;
        x_valid_flag := fnd_api.g_false;
        RETURN;
        END IF;
    END IF;
END check_product_market_strict;


-------------------------------------------------------------------
-- NAME
--    check_product_market_loose
-- PURPOSE
--    private procedure to check for
--        any offer's product, if it is not in budget's product list when relaxed offer budget validation
--        any offer's party, if it is not in budget's party list when relaxed offer budget validation
--        any budget's excluded product, if it is in offer's product list when relaxed offer budget validation
--        any budget's excluded party, if it is in offer's party list when relaxed offer budget validation
-- History
--    Created  kdass    22-Sep-2003    11.5.10 Offer Budget Validation
----------------------------------------------------------------
PROCEDURE check_product_market_loose (
   p_exclude_only    IN            BOOLEAN,
   x_return_status      OUT NOCOPY    VARCHAR2,
   x_valid_flag         OUT NOCOPY    VARCHAR2)
IS
   CURSOR c_check_exclude_items IS
     SELECT 1
     FROM   ozf_temp_eligibility offr
     WHERE  object_type = 'OFFR'
     AND    offr.eligibility_id > 0
     AND    NOT EXISTS
     (SELECT 1
      FROM   ozf_temp_eligibility fund
      WHERE  offr.eligibility_id = fund.eligibility_id
      AND    fund.object_type = 'FUND'
          AND    fund.eligibility_id > 0
          AND    fund.exclude_flag = 'Y');

   CURSOR c_check_items IS
     SELECT 1
     FROM   ozf_temp_eligibility  offr, ozf_temp_eligibility fund
     WHERE  offr.object_type = 'OFFR'
         AND    fund.eligibility_id > 0
     AND    offr.eligibility_id > 0
     AND    fund.object_type = 'FUND'
     AND    fund.exclude_flag = 'N'
     AND    offr.eligibility_id = fund.eligibility_id;

   l_exist_number NUMBER := NULL;

BEGIN

    IF p_exclude_only THEN
        OPEN c_check_exclude_items;
    FETCH c_check_exclude_items INTO l_exist_number;
    CLOSE c_check_exclude_items;
    --dbms_output.put_line('l_exist_number: ' || l_exist_number);
    IF NVL(l_exist_number,0) <> 1 THEN
        x_return_status := fnd_api.g_ret_sts_success;
        x_valid_flag := fnd_api.g_false;
        RETURN;
        END IF;
    ELSE
    OPEN c_check_items;
    FETCH c_check_items INTO l_exist_number;
    CLOSE c_check_items;
    --dbms_output.put_line('l_exist_number: ' || l_exist_number);
    IF NVL(l_exist_number,0) <> 1 THEN
        x_return_status := fnd_api.g_ret_sts_success;
        x_valid_flag := fnd_api.g_false;
        RETURN;
    END IF;
    END IF;

END check_product_market_loose;


-------------------------------------------------------------------
-- NAME
--    denorm_product_for_one_budget
-- PURPOSE
--    this API will denorm budget's product eligibility to temp table
--    p_budget_id:   fund_id
-- History
--    Created   yzhao   02/03/2004
----------------------------------------------------------------
PROCEDURE denorm_product_for_one_budget (
   p_budget_id          IN     NUMBER,
   x_budget_prod        OUT NOCOPY    BOOLEAN,
   x_exclude_prod       OUT NOCOPY    BOOLEAN,
   x_return_status      OUT NOCOPY    VARCHAR2,
   x_msg_count          OUT NOCOPY    NUMBER,
   x_msg_data           OUT NOCOPY    VARCHAR2)
IS
   l_attribute              VARCHAR2(50)    := NULL;
   l_attr_value             VARCHAR2(200)   := NULL;
   l_excluded_flag          VARCHAR2(1);
   l_temp_sql               VARCHAR2(32000)  := NULL;
   l_denorm_csr             NUMBER;
   l_stmt_denorm            VARCHAR2(32000) := NULL;
   l_ignore                 NUMBER;

   -- get budget's and offer's products
   CURSOR c_get_products(p_act_product_used_by_id IN NUMBER, p_arc_act_product_used_by IN VARCHAR2, p_excluded_flag IN VARCHAR2) IS
     SELECT  decode(level_type_code, 'PRODUCT', inventory_item_id, category_id)
        ,excluded_flag
        ,decode(level_type_code, 'PRODUCT', 'PRICING_ATTRIBUTE1', 'PRICING_ATTRIBUTE2') attribute
     FROM   ams_act_products
     WHERE  act_product_used_by_id = p_act_product_used_by_id
     AND    arc_act_product_used_by = p_arc_act_product_used_by
     AND    excluded_flag = p_excluded_flag;

BEGIN
   x_return_status := fnd_api.G_RET_STS_SUCCESS;
   x_budget_prod := FALSE;
   x_exclude_prod := FALSE;
   SAVEPOINT denorm_product_for_one_budget;

   FND_DSQL.init;
   FND_DSQL.add_text('INSERT INTO ozf_temp_eligibility(object_type, exclude_flag, eligibility_id) ');
   FND_DSQL.add_text('SELECT  ''FUND'', ''N'', product_id FROM (');
   -- Get all product qualifiers for 'FUND'
   OPEN c_get_products(p_budget_id, 'FUND', 'N');
   LOOP
       FETCH c_get_products INTO l_attr_value,l_excluded_flag,l_attribute;
       EXIT WHEN c_get_products%NOTFOUND OR c_get_products%NOTFOUND is NULL;
       IF c_get_products%ROWCOUNT > 0 THEN
          x_budget_prod := TRUE;
       END IF;

       IF c_get_products%ROWCOUNT = 1 THEN -- for first row.
          FND_DSQL.add_text('(');
          l_temp_sql := OZF_OFFR_ELIG_PROD_DENORM_PVT.get_sql
                     ( p_context => 'ITEM',
                       p_attribute => l_attribute,
                       p_attr_value_from => l_attr_value,
                       p_attr_value_to  => NULL,
                       p_comparison => NULL,
                       p_type => 'PROD'
                      );
          FND_DSQL.add_text(')');
        ELSE
          FND_DSQL.add_text('UNION (');
          l_temp_sql := OZF_OFFR_ELIG_PROD_DENORM_PVT.get_sql
                     ( p_context => 'ITEM',
                       p_attribute => l_attribute,
                       p_attr_value_from => l_attr_value,
                       p_attr_value_to  => NULL,
                       p_comparison => NULL,
                       p_type => 'PROD'
                      );
          FND_DSQL.add_text(')');
       END IF;

   END LOOP;

   CLOSE c_get_products;
   FND_DSQL.add_text(')');

   IF x_budget_prod THEN

        l_denorm_csr := DBMS_SQL.open_cursor;
        FND_DSQL.set_cursor(l_denorm_csr);

        l_stmt_denorm := FND_DSQL.get_text(FALSE);
        --dbms_output.put_line('budget query:' || l_stmt_denorm);
        DBMS_SQL.parse(l_denorm_csr, l_stmt_denorm, DBMS_SQL.native);
        FND_DSQL.do_binds;
        l_ignore := DBMS_SQL.execute(l_denorm_csr);
   END IF;

   FND_DSQL.init;
   FND_DSQL.add_text('INSERT INTO ozf_temp_eligibility(object_type, exclude_flag, eligibility_id) ');
   FND_DSQL.add_text('SELECT  ''FUND'', ''Y'', product_id FROM (');
   -- for exclude product of FUND.

   OPEN c_get_products(p_budget_id,'FUND','Y');
   LOOP
       FETCH c_get_products INTO l_attr_value,l_excluded_flag,l_attribute;
       EXIT WHEN c_get_products%NOTFOUND OR c_get_products%NOTFOUND is NULL;
       IF c_get_products%ROWCOUNT > 0 THEN
          x_exclude_prod := TRUE;
       END IF;

       IF c_get_products%ROWCOUNT = 1 THEN
            -- l_exclude_sql := '(' || l_temp_sql || ')';
          FND_DSQL.add_text('(');
          l_temp_sql := OZF_OFFR_ELIG_PROD_DENORM_PVT.get_sql
                     ( p_context => 'ITEM',
                       p_attribute => l_attribute,
                       p_attr_value_from => l_attr_value,
                       p_attr_value_to  => NULL,
                       p_comparison => NULL,
                       p_type => 'PROD'
                      );
          FND_DSQL.add_text(')');
       ELSE
             --l_exclude_sql := l_exclude_sql || ' UNION (' || l_temp_sql || ')';
         FND_DSQL.add_text('UNION (');
         l_temp_sql := OZF_OFFR_ELIG_PROD_DENORM_PVT.get_sql
                     ( p_context => 'ITEM',
                       p_attribute => l_attribute,
                       p_attr_value_from => l_attr_value,
                       p_attr_value_to  => NULL,
                       p_comparison => NULL,
                       p_type => 'PROD'
                      );
         FND_DSQL.add_text(')');
       END IF;

    END LOOP;
    CLOSE c_get_products;
    FND_DSQL.add_text(')');

    IF x_exclude_prod THEN
        l_denorm_csr := DBMS_SQL.open_cursor;
        FND_DSQL.set_cursor(l_denorm_csr);
        l_stmt_denorm := FND_DSQL.get_text(FALSE);
        DBMS_SQL.parse(l_denorm_csr, l_stmt_denorm, DBMS_SQL.native);
        FND_DSQL.do_binds;
        l_ignore := DBMS_SQL.execute(l_denorm_csr);
    END IF;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO denorm_product_for_one_budget;
      x_return_status            := fnd_api.g_ret_sts_error;
END denorm_product_for_one_budget;


-------------------------------------------------------------------
-- NAME
--    denorm_market_for_one_budget
-- PURPOSE
--    this API will denorm budget's market eligibility to temp table
--    p_budget_id:   fund_id
-- History
--    Created   yzhao   02/03/2004
----------------------------------------------------------------
PROCEDURE denorm_market_for_one_budget (
   p_budget_id          IN            NUMBER,
   x_budget_mark        OUT NOCOPY    BOOLEAN,
   x_exclude_mark       OUT NOCOPY    BOOLEAN,
   x_return_status      OUT NOCOPY    VARCHAR2,
   x_msg_count          OUT NOCOPY    NUMBER,
   x_msg_data           OUT NOCOPY    VARCHAR2)
IS
   l_segment_id             NUMBER;
   l_excluded_flag          VARCHAR2(1);
   l_segment_type           VARCHAR2(30);
   l_context                VARCHAR2(50)    := NULL;
   l_attribute              VARCHAR2(50)    := NULL;
   l_attr_value             VARCHAR2(200)   := NULL;
   l_temp_sql               VARCHAR2(2000)  := NULL;
   l_denorm_csr             NUMBER;
   l_ignore                 NUMBER;
   l_stmt_denorm            VARCHAR2(32000) := NULL;

   -- get budget's included and excluded market qualifier ids
   CURSOR c_get_budget_market_qualifiers(p_exclude_flag IN VARCHAR2) IS
     SELECT market_segment_id, segment_type, exclude_flag
     FROM   ams_act_market_segments
     WHERE  act_market_segment_used_by_id = p_budget_id
     AND    arc_act_market_segment_used_by = 'FUND'
     AND exclude_flag = p_exclude_flag;

BEGIN
   x_return_status := fnd_api.G_RET_STS_SUCCESS;
   x_budget_mark := FALSE;
   x_exclude_mark := FALSE;
   SAVEPOINT denorm_market_for_one_budget;

   FND_DSQL.init;
   FND_DSQL.add_text('INSERT INTO ozf_temp_eligibility(object_type, exclude_flag, eligibility_id) ');
   FND_DSQL.add_text('SELECT  ''FUND'', ''N'', party_id FROM (');

   OPEN c_get_budget_market_qualifiers('N');

   -- Get all market qualifiers for 'FUND'
   LOOP
       FETCH c_get_budget_market_qualifiers INTO l_segment_id,l_segment_type,l_excluded_flag;
       EXIT WHEN c_get_budget_market_qualifiers%NOTFOUND OR c_get_budget_market_qualifiers%NOTFOUND is NULL;

       IF c_get_budget_market_qualifiers%ROWCOUNT > 0 THEN
          x_budget_mark := TRUE;
       END IF;
       -- should be the same as how they are created in amsvfrub.pls process_offers()
       IF l_segment_type = 'CUSTOMER' THEN
          l_context := 'CUSTOMER';                    -- for customer sold to
          l_attribute := 'QUALIFIER_ATTRIBUTE2';
       /* yzhao: 02/07/2003 fix bug 2789518 - MKTF1R9:1159.0203:FUNC-BUDGET WITH MARKET ELIGIBILITY CUSTOMER BILL TO FAILS */
       ELSIF l_segment_type = 'CUSTOMER_BILL_TO' THEN
          l_context := 'CUSTOMER';                    -- for customer bill to
          l_attribute := 'QUALIFIER_ATTRIBUTE14';
       /* yzhao: 02/07/2003 fix bug 2789518 ends */
       ELSIF l_segment_type = 'LIST' THEN
          l_context := 'CUSTOMER_GROUP';
          l_attribute := 'QUALIFIER_ATTRIBUTE1';
       ELSIF l_segment_type = 'SEGMENT' THEN
          l_context := 'CUSTOMER_GROUP';
          l_attribute := 'QUALIFIER_ATTRIBUTE2';
       ELSIF l_segment_type = 'BUYER' THEN
          l_context := 'CUSTOMER_GROUP';
          l_attribute := 'QUALIFIER_ATTRIBUTE3';
       ELSIF l_segment_type = 'TERRITORY' THEN
          l_context := 'TERRITORY';
          l_attribute := 'QUALIFIER_ATTRIBUTE1';
       /* feliu: 04/02/2003 fix bug 2778138 */
       ELSIF l_segment_type = 'SHIP_TO' THEN
          l_context := 'CUSTOMER';
          l_attribute := 'QUALIFIER_ATTRIBUTE11';
       END IF;

       l_attr_value := l_segment_id;

       IF  c_get_budget_market_qualifiers%ROWCOUNT = 1 THEN -- for first row.
            -- l_budget_product_sql := '(' || l_temp_sql || ')';
          FND_DSQL.add_text('(');
          l_temp_sql := OZF_OFFR_ELIG_PROD_DENORM_PVT.get_sql
                     ( p_context => l_context,
                       p_attribute => l_attribute,
                       p_attr_value_from => l_attr_value,
                       p_attr_value_to  => NULL,
                       p_comparison => '=',
                       p_type => 'ELIG'
                      );
          FND_DSQL.add_text(')');
       ELSE
             --l_budget_product_sql := l_budget_product_sql || ' UNION (' || l_temp_sql || ')';
          FND_DSQL.add_text('UNION (');
          l_temp_sql := OZF_OFFR_ELIG_PROD_DENORM_PVT.get_sql
                     ( p_context => l_context,
                       p_attribute => l_attribute,
                       p_attr_value_from => l_attr_value,
                       p_attr_value_to  => NULL,
                       p_comparison => '=',
                       p_type => 'ELIG'
                      );
          FND_DSQL.add_text(')');
       END IF;
       ----dbms_output.put_line('budget:' || l_temp_sql );

   END LOOP;
   CLOSE c_get_budget_market_qualifiers;
   FND_DSQL.add_text(')');

   IF x_budget_mark THEN
        l_denorm_csr := DBMS_SQL.open_cursor;
        FND_DSQL.set_cursor(l_denorm_csr);
        l_stmt_denorm := FND_DSQL.get_text(FALSE);
        -- l_budget_market_sql := l_stmt_denorm;
        DBMS_SQL.parse(l_denorm_csr, l_stmt_denorm, DBMS_SQL.native);
        FND_DSQL.do_binds;
        l_ignore := DBMS_SQL.execute(l_denorm_csr);
        --dbms_output.put_line(l_ignore);
   END IF;

   FND_DSQL.init;
   FND_DSQL.add_text('INSERT INTO ozf_temp_eligibility(object_type, exclude_flag, eligibility_id) ');
   FND_DSQL.add_text('SELECT  ''FUND'', ''Y'', party_id FROM (');

   OPEN c_get_budget_market_qualifiers('Y');
   -- Get all excluded market qualifiers for 'FUND'
   LOOP
       FETCH c_get_budget_market_qualifiers INTO l_segment_id,l_segment_type,l_excluded_flag;
       EXIT WHEN c_get_budget_market_qualifiers%NOTFOUND OR c_get_budget_market_qualifiers%NOTFOUND is NULL;

       IF c_get_budget_market_qualifiers%ROWCOUNT > 0 THEN
          x_exclude_mark := TRUE;
       END IF;
       -- should be the same as how they are created in amsvfrub.pls process_offers()
       IF l_segment_type = 'CUSTOMER' THEN
          l_context := 'CUSTOMER';                    -- for customer sold to
          l_attribute := 'QUALIFIER_ATTRIBUTE2';
       /* yzhao: 02/07/2003 fix bug 2789518 - MKTF1R9:1159.0203:FUNC-BUDGET WITH MARKET ELIGIBILITY CUSTOMER BILL TO FAILS */
       ELSIF l_segment_type = 'CUSTOMER_BILL_TO' THEN
          l_context := 'CUSTOMER';                    -- for customer bill to
          l_attribute := 'QUALIFIER_ATTRIBUTE14';
       /* yzhao: 02/07/2003 fix bug 2789518 ends */
       ELSIF l_segment_type = 'LIST' THEN
          l_context := 'CUSTOMER_GROUP';
          l_attribute := 'QUALIFIER_ATTRIBUTE1';
       ELSIF l_segment_type = 'SEGMENT' THEN
          l_context := 'CUSTOMER_GROUP';
          l_attribute := 'QUALIFIER_ATTRIBUTE2';
       ELSIF l_segment_type = 'BUYER' THEN
          l_context := 'CUSTOMER_GROUP';
          l_attribute := 'QUALIFIER_ATTRIBUTE3';
       ELSIF l_segment_type = 'TERRITORY' THEN
          l_context := 'TERRITORY';
          l_attribute := 'QUALIFIER_ATTRIBUTE1';
       /* feliu: 04/02/2003 fix bug 2778138 */
       ELSIF l_segment_type = 'SHIP_TO' THEN
          l_context := 'CUSTOMER';
          l_attribute := 'QUALIFIER_ATTRIBUTE11';
       END IF;

       l_attr_value := l_segment_id;

       IF  c_get_budget_market_qualifiers%ROWCOUNT = 1 THEN -- for first row.
           -- l_budget_product_sql := '(' || l_temp_sql || ')';
           FND_DSQL.add_text('(');
           l_temp_sql := OZF_OFFR_ELIG_PROD_DENORM_PVT.get_sql
                     ( p_context => l_context,
                       p_attribute => l_attribute,
                       p_attr_value_from => l_attr_value,
                       p_attr_value_to  => NULL,
                       p_comparison => '=',
                       p_type => 'ELIG'
                      );
           FND_DSQL.add_text(')');
        ELSE
           --l_budget_product_sql := l_budget_product_sql || ' UNION (' || l_temp_sql || ')';
           FND_DSQL.add_text('UNION (');
           l_temp_sql := OZF_OFFR_ELIG_PROD_DENORM_PVT.get_sql
                     ( p_context => l_context,
                       p_attribute => l_attribute,
                       p_attr_value_from => l_attr_value,
                       p_attr_value_to  => NULL,
                       p_comparison => '=',
                       p_type => 'ELIG'
                      );
           FND_DSQL.add_text(')');
        END IF;

   END LOOP;
   CLOSE c_get_budget_market_qualifiers;
   FND_DSQL.add_text(')');
   IF x_exclude_mark THEN
        l_denorm_csr := DBMS_SQL.open_cursor;
        FND_DSQL.set_cursor(l_denorm_csr);
        l_stmt_denorm := FND_DSQL.get_text(FALSE);
        --dbms_output.put_line('Budget exclude query:' || l_stmt_denorm);
        DBMS_SQL.parse(l_denorm_csr, l_stmt_denorm, DBMS_SQL.native);
        FND_DSQL.do_binds;
        l_ignore := DBMS_SQL.execute(l_denorm_csr);
        --dbms_output.put_line(l_ignore);
    END IF;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO denorm_market_for_one_budget;
      x_return_status            := fnd_api.g_ret_sts_error;

END denorm_market_for_one_budget;


-------------------------------------------------------------------
-- NAME
--    validate_product_by_each_line
-- PURPOSE
--    validate product by each budget line or to check if the budget has least one of offer's product
--    private procedure called by validate_object_budget
--      evolved from the old API validate_product_budget
-- History
--    Created  kdass    25-Aug-2003    11.5.10 Offer Budget Validation
----------------------------------------------------------------
PROCEDURE validate_product_by_each_line (
   p_object_id          IN     NUMBER,
   p_object_type        IN     VARCHAR2,
   p_offer_type         IN     VARCHAR2,
   p_actbudget_id       IN     NUMBER,
   p_mode        IN     VARCHAR2,
   x_return_status      OUT NOCOPY    VARCHAR2,
   x_valid_flag         OUT NOCOPY    VARCHAR2)
IS
   l_offer_product_sql      VARCHAR2(32000) := NULL;
   l_temp_sql               VARCHAR2(32000)  := NULL; --nirprasa, fix for bug 7599501.
   l_attribute              VARCHAR2(50)    := NULL;
   l_attr_value             VARCHAR2(200)   := NULL;
   l_exist_number           NUMBER := NULL;
   l_exclude_only           BOOLEAN := FALSE;
   l_return_status          VARCHAR2(20);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(2000)  := null;
   l_budget_prod            BOOLEAN := FALSE;
   l_exclude_prod           BOOLEAN := FALSE;
   l_offer_prod             BOOLEAN := FALSE;
   l_denorm_csr             NUMBER;
   l_ignore                 NUMBER;
   l_level_code             VARCHAR2(30);
   l_inventory_id           NUMBER;
   l_category_id            NUMBER;
   l_excluded_flag          VARCHAR2(1);
   l_stmt_denorm            VARCHAR2(32000) := NULL;
   l_count_offer_prod       NUMBER := 0;

   CURSOR c_get_products(p_act_product_used_by_id IN NUMBER, p_arc_act_product_used_by IN VARCHAR2, p_excluded_flag IN VARCHAR2) IS
     SELECT  decode(level_type_code, 'PRODUCT', inventory_item_id, category_id)
           , excluded_flag
           , decode(level_type_code, 'PRODUCT', 'PRICING_ATTRIBUTE1', 'PRICING_ATTRIBUTE2') attribute
     FROM   ams_act_products
     WHERE  act_product_used_by_id = p_act_product_used_by_id
     AND    arc_act_product_used_by = p_arc_act_product_used_by
     AND    excluded_flag = p_excluded_flag;

   CURSOR c_count_offer_prod IS
     SELECT count(*)
     FROM ozf_temp_eligibility
     WHERE object_type = 'OFFR';

BEGIN

   x_return_status := fnd_api.G_RET_STS_SUCCESS;
   x_valid_flag := fnd_api.G_TRUE;

   EXECUTE IMMEDIATE 'DELETE FROM ozf_temp_eligibility';

   denorm_product_for_one_budget (
            p_budget_id          => p_actbudget_id,
            x_budget_prod        => l_budget_prod,
            x_exclude_prod       => l_exclude_prod,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data);
   IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
       RAISE fnd_api.G_EXC_ERROR;
   END IF;

   -- no product eligibility for budget, validation is true.
   IF l_budget_prod = FALSE AND l_exclude_prod = FALSE THEN
       x_return_status := fnd_api.g_ret_sts_success;
       x_valid_flag := fnd_api.g_true;
       RETURN;
   END IF;
   IF l_budget_prod = FALSE AND l_exclude_prod = TRUE THEN
      l_exclude_only := TRUE;
   END IF;


   FND_DSQL.init;
   FND_DSQL.add_text('INSERT INTO ozf_temp_eligibility(object_type, exclude_flag, eligibility_id) ');
   FND_DSQL.add_text('SELECT  ''OFFR'', ''N'', product_id FROM (' );
   IF p_offer_type IN ('LUMPSUM', 'SCAN_DATA') THEN
      OPEN c_get_products(p_object_id,'OFFR','N');
      LOOP
         FETCH c_get_products INTO l_attr_value,l_excluded_flag,l_attribute;
         EXIT WHEN c_get_products%NOTFOUND OR c_get_products%NOTFOUND is NULL;
         IF c_get_products%ROWCOUNT > 0 THEN
           l_offer_prod := TRUE;
         END IF;

         IF c_get_products%ROWCOUNT = 1 THEN
            --  l_offer_product_sql := '(' || l_temp_sql || ')';
           FND_DSQL.add_text('(');
           l_temp_sql := OZF_OFFR_ELIG_PROD_DENORM_PVT.get_sql
                     ( p_context => 'ITEM',
                       p_attribute => l_attribute,
                       p_attr_value_from => l_attr_value,
                       p_attr_value_to  => NULL,
                       p_comparison => NULL,
                       p_type => 'PROD'
                      );
           FND_DSQL.add_text(')');
         ELSE
             --l_offer_product_sql := l_offer_product_sql || ' UNION (' || l_temp_sql || ')';
           FND_DSQL.add_text('UNION (');
           l_temp_sql := OZF_OFFR_ELIG_PROD_DENORM_PVT.get_sql
                     ( p_context => 'ITEM',
                       p_attribute => l_attribute,
                       p_attr_value_from => l_attr_value,
                       p_attr_value_to  => NULL,
                       p_comparison => NULL,
                       p_type => 'PROD'
                      );
           FND_DSQL.add_text(')');
         END IF;
      END LOOP;
      CLOSE c_get_products;

   ELSE -- for other offer,
      -- get offer's product eligibility query
      OZF_OFFR_ELIG_PROD_DENORM_PVT.refresh_products(
                  p_api_version    => 1.0,
                  p_init_msg_list  => fnd_api.g_false,
                  p_commit         => fnd_api.g_false,
                  p_list_header_id => p_object_id,
                  p_calling_from_den => 'N',
                  x_return_status  => l_return_status,
                  x_msg_count      => l_msg_count,
                  x_msg_data       => l_msg_data,
                  x_product_stmt   => l_offer_product_sql
      );

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         x_return_status := l_return_status;
         RAISE fnd_api.G_EXC_ERROR;
      END IF;

   END IF;
   FND_DSQL.add_text(')');

   IF l_offer_product_sql IS NULL AND l_offer_prod = FALSE THEN
      x_return_status := fnd_api.g_ret_sts_success;
      x_valid_flag := fnd_api.g_false;
      RETURN;
   END IF;

   IF l_offer_product_sql IS NOT NULL OR l_offer_prod THEN
      l_denorm_csr := DBMS_SQL.open_cursor;
      FND_DSQL.set_cursor(l_denorm_csr);
      l_stmt_denorm := FND_DSQL.get_text(FALSE);
      DBMS_SQL.parse(l_denorm_csr, l_stmt_denorm, DBMS_SQL.native);
      FND_DSQL.do_binds;
      l_ignore := DBMS_SQL.execute(l_denorm_csr);
      --dbms_output.put_line(l_ignore);
    END IF;

   --kdass 08/31/2005 fixed bug 4338544 - if offer has no products (can happen when the
   --offer category has no products) then raise exception
   OPEN c_count_offer_prod;
   FETCH c_count_offer_prod INTO l_count_offer_prod;
   CLOSE c_count_offer_prod;

   ozf_utility_pvt.write_conc_log('Number of products in offer: ' || l_count_offer_prod);

   IF l_count_offer_prod = 0 THEN
      FND_MESSAGE.Set_Name ('OZF', 'OZF_OFFER_NO_PROD');
      FND_MSG_PUB.Add;
      RAISE fnd_api.G_EXC_ERROR;
    END IF;

   IF p_mode = 'LOOSE' THEN
       check_product_market_loose(
           p_exclude_only   =>  l_exclude_only,
           x_return_status  =>  l_return_status,
           x_valid_flag     =>  x_valid_flag
       );

        IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
        RAISE fnd_api.G_EXC_ERROR;
        ELSIF x_valid_flag <> fnd_api.G_TRUE THEN
            FND_MESSAGE.Set_Name ('OZF', 'OZF_API_DEBUG_MESSAGE');
            FND_MESSAGE.SET_TOKEN('text', 'Product validation fails. Offer does not have a single product that matches the product of the budget');
            FND_MSG_PUB.Add;
            RAISE fnd_api.G_EXC_ERROR;
        END IF;
   ELSIF p_mode = 'STRICT' THEN
       check_product_market_strict(
           p_exclude_only   =>  l_exclude_only,
           x_return_status  =>  l_return_status,
           x_valid_flag     =>  x_valid_flag
       );

       IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
           x_return_status := l_return_status;
           RAISE fnd_api.G_EXC_ERROR;
       ELSIF x_valid_flag <> fnd_api.G_TRUE THEN
           FND_MESSAGE.Set_Name ('OZF', 'OZF_API_DEBUG_MESSAGE');
           FND_MESSAGE.SET_TOKEN('text', 'Product validation fails. Offer has product that is not in budget product list');
           FND_MSG_PUB.Add;
           RAISE fnd_api.G_EXC_ERROR;
       END IF;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status            := fnd_api.g_ret_sts_error;
END validate_product_by_each_line;

-------------------------------------------------------------------
-- NAME
--    validate_product_by_all_lines
-- PURPOSE
--    validate product by all budget lines
--    private procedure called by validate_object_budget_all
-- History
--    Created  kdass    25-Aug-2003    11.5.10 Offer Budget Validation
----------------------------------------------------------------
PROCEDURE validate_product_by_all_lines (
   p_object_id          IN     NUMBER,
   p_object_type        IN     VARCHAR2,
   p_offer_type         IN     VARCHAR2,
   x_return_status      OUT NOCOPY    VARCHAR2,
   x_valid_flag         OUT NOCOPY    VARCHAR2)
IS
   l_offer_product_sql      VARCHAR2(32000) := NULL;
   l_temp_sql               VARCHAR2(2000)  := NULL;
   l_attribute              VARCHAR2(50)    := NULL;
   l_attr_value             VARCHAR2(200)   := NULL;
   l_exist_number           NUMBER := NULL;
   l_exclude_only           BOOLEAN := FALSE;
   l_return_status          VARCHAR2(20);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(2000)  := null;
   l_budget_prod            BOOLEAN := FALSE;
   l_exclude_prod           BOOLEAN := FALSE;
   l_offer_prod             BOOLEAN := FALSE;
   l_denorm_csr             NUMBER;
   l_ignore                 NUMBER;
   l_level_code             VARCHAR2(30);
   l_inventory_id           NUMBER;
   l_category_id            NUMBER;
   l_excluded_flag          VARCHAR2(1);
   l_stmt_denorm            VARCHAR2(32000) := NULL;
 -- get budget's included and excluded product id and product family id
   CURSOR c_get_budget_products(p_excluded_flag IN VARCHAR2) IS
     SELECT  distinct decode(level_type_code, 'PRODUCT', inventory_item_id, category_id)
        ,excluded_flag
        ,decode(level_type_code, 'PRODUCT', 'PRICING_ATTRIBUTE1', 'PRICING_ATTRIBUTE2') attribute
     FROM   ams_act_products
     WHERE  act_product_used_by_id
        IN
        (SELECT budget_source_id FROM ozf_act_budgets
        WHERE arc_act_budget_used_by = 'OFFR'
        AND act_budget_used_by_id = p_object_id
        AND transfer_type = 'REQUEST'
        AND status_code = 'APPROVED')
     AND    arc_act_product_used_by = 'FUND'
     AND    excluded_flag = p_excluded_flag;

   -- get budget's product id and product family id
   CURSOR c_get_offer_products IS
     SELECT  decode(level_type_code, 'PRODUCT', inventory_item_id, category_id)
        ,excluded_flag
        ,decode(level_type_code, 'PRODUCT', 'PRICING_ATTRIBUTE1', 'PRICING_ATTRIBUTE2') attribute
     FROM   ams_act_products
     WHERE  act_product_used_by_id = p_object_id
     AND    arc_act_product_used_by = 'OFFR'
     AND    excluded_flag = 'N';
BEGIN

   x_return_status := fnd_api.G_RET_STS_SUCCESS;
   x_valid_flag := fnd_api.G_TRUE;

   EXECUTE IMMEDIATE 'DELETE FROM ozf_temp_eligibility';

   FND_DSQL.init;
   FND_DSQL.add_text('INSERT INTO ozf_temp_eligibility(object_type, exclude_flag, eligibility_id) ');
   FND_DSQL.add_text('SELECT  ''FUND'', ''N'', product_id FROM (');
   -- Get all product qualifiers for 'FUND'
   OPEN c_get_budget_products('N');
   LOOP
       FETCH c_get_budget_products INTO l_attr_value,l_excluded_flag,l_attribute;
       EXIT WHEN c_get_budget_products%NOTFOUND OR c_get_budget_products%NOTFOUND is NULL;

       IF c_get_budget_products%ROWCOUNT > 0 THEN
          l_budget_prod := TRUE;
       END IF;

       IF  c_get_budget_products%ROWCOUNT = 1 THEN -- for first row.
          FND_DSQL.add_text('(');
          l_temp_sql := OZF_OFFR_ELIG_PROD_DENORM_PVT.get_sql
                     ( p_context => 'ITEM',
                       p_attribute => l_attribute,
                       p_attr_value_from => l_attr_value,
                       p_attr_value_to  => NULL,
                       p_comparison => NULL,
                       p_type => 'PROD'
                      );
          FND_DSQL.add_text(')');
        ELSE
            FND_DSQL.add_text('UNION (');
          l_temp_sql := OZF_OFFR_ELIG_PROD_DENORM_PVT.get_sql
                     ( p_context => 'ITEM',
                       p_attribute => l_attribute,
                       p_attr_value_from => l_attr_value,
                       p_attr_value_to  => NULL,
                       p_comparison => NULL,
                       p_type => 'PROD'
                      );
          FND_DSQL.add_text(')');
       END IF;
       --dbms_output.put_line('validate_product_by_all_lines: budget:');
       --dbms_output.put_line('validate_product_by_all_lines: budget:' || l_temp_sql);

   END LOOP;
   CLOSE c_get_budget_products;
   FND_DSQL.add_text(')');

   IF l_budget_prod THEN
        l_denorm_csr := DBMS_SQL.open_cursor;
        FND_DSQL.set_cursor(l_denorm_csr);
        l_stmt_denorm := FND_DSQL.get_text(FALSE);
        DBMS_SQL.parse(l_denorm_csr, l_stmt_denorm, DBMS_SQL.native);
        FND_DSQL.do_binds;
        l_ignore := DBMS_SQL.execute(l_denorm_csr);
        --dbms_output.put_line(l_ignore);
   END IF;

   FND_DSQL.init;
   FND_DSQL.add_text('INSERT INTO ozf_temp_eligibility(object_type, exclude_flag, eligibility_id) ');
   FND_DSQL.add_text('SELECT  ''FUND'', ''Y'', product_id FROM (');
   -- for exclude product of FUND.

   OPEN c_get_budget_products('Y');
   LOOP
       FETCH c_get_budget_products INTO l_attr_value,l_excluded_flag,l_attribute;
       EXIT WHEN c_get_budget_products%NOTFOUND OR c_get_budget_products%NOTFOUND is NULL;

       IF c_get_budget_products%ROWCOUNT > 0 THEN
          l_exclude_prod := TRUE;
       END IF;

       IF c_get_budget_products%ROWCOUNT = 1 THEN
            -- l_exclude_sql := '(' || l_temp_sql || ')';
      FND_DSQL.add_text('(');
          l_temp_sql := OZF_OFFR_ELIG_PROD_DENORM_PVT.get_sql
                     ( p_context => 'ITEM',
                       p_attribute => l_attribute,
                       p_attr_value_from => l_attr_value,
                       p_attr_value_to  => NULL,
                       p_comparison => NULL,
                       p_type => 'PROD'
                      );
      FND_DSQL.add_text(')');
       ELSE
             --l_exclude_sql := l_exclude_sql || ' UNION (' || l_temp_sql || ')';
     FND_DSQL.add_text('UNION (');
         l_temp_sql := OZF_OFFR_ELIG_PROD_DENORM_PVT.get_sql
                     ( p_context => 'ITEM',
                       p_attribute => l_attribute,
                       p_attr_value_from => l_attr_value,
                       p_attr_value_to  => NULL,
                       p_comparison => NULL,
                       p_type => 'PROD'
                      );
     FND_DSQL.add_text(')');
       END IF;

    END LOOP;
    CLOSE c_get_budget_products;
    FND_DSQL.add_text(')');

    IF l_exclude_prod THEN
        l_denorm_csr := DBMS_SQL.open_cursor;
        FND_DSQL.set_cursor(l_denorm_csr);
        l_stmt_denorm := FND_DSQL.get_text(FALSE);
        --dbms_output.put_line('validate_product_by_all_lines: in budget exclude');
        DBMS_SQL.parse(l_denorm_csr, l_stmt_denorm, DBMS_SQL.native);
        FND_DSQL.do_binds;
        l_ignore := DBMS_SQL.execute(l_denorm_csr);
        --dbms_output.put_line(l_ignore);
    END IF;
    -- not product eligibility for budget, validation is true.
    IF l_budget_prod = FALSE AND l_exclude_prod = FALSE THEN
       x_return_status := fnd_api.g_ret_sts_success;
       x_valid_flag := fnd_api.g_true;
       RETURN;
   END IF;

   IF l_budget_prod = FALSE AND l_exclude_prod = TRUE THEN
      l_exclude_only := TRUE;
   END IF;

   FND_DSQL.init;
   FND_DSQL.add_text('INSERT INTO ozf_temp_eligibility(object_type, exclude_flag, eligibility_id) ');
   FND_DSQL.add_text('SELECT  ''OFFR'', ''N'', product_id FROM (' );
   IF p_offer_type IN ('LUMPSUM', 'SCAN_DATA') THEN
      OPEN c_get_offer_products;
      LOOP
         FETCH c_get_offer_products INTO l_attr_value,l_excluded_flag,l_attribute;
         EXIT WHEN c_get_offer_products%NOTFOUND OR c_get_offer_products%NOTFOUND is NULL;
         IF c_get_offer_products%ROWCOUNT > 0 THEN
           l_offer_prod := TRUE;
         END IF;

         IF c_get_offer_products%ROWCOUNT = 1 THEN
            --  l_offer_product_sql := '(' || l_temp_sql || ')';
           FND_DSQL.add_text('(');
           l_temp_sql := OZF_OFFR_ELIG_PROD_DENORM_PVT.get_sql
                     ( p_context => 'ITEM',
                       p_attribute => l_attribute,
                       p_attr_value_from => l_attr_value,
                       p_attr_value_to  => NULL,
                       p_comparison => NULL,
                       p_type => 'PROD'
                      );
           FND_DSQL.add_text(')');
         ELSE
           --l_offer_product_sql := l_offer_product_sql || ' UNION (' || l_temp_sql || ')';
           FND_DSQL.add_text('UNION (');
           l_temp_sql := OZF_OFFR_ELIG_PROD_DENORM_PVT.get_sql
                     ( p_context => 'ITEM',
                       p_attribute => l_attribute,
                       p_attr_value_from => l_attr_value,
                       p_attr_value_to  => NULL,
                       p_comparison => NULL,
                       p_type => 'PROD'
                      );
           FND_DSQL.add_text(')');
         END IF;
      END LOOP;
      CLOSE c_get_offer_products;

   ELSE -- for other offer,
      -- get offer's product eligibility query
      OZF_OFFR_ELIG_PROD_DENORM_PVT.refresh_products(
                  p_api_version    => 1.0,
                  p_init_msg_list  => fnd_api.g_false,
                  p_commit         => fnd_api.g_false,
                  p_list_header_id => p_object_id,
                  p_calling_from_den => 'N',
                  x_return_status  => l_return_status,
                  x_msg_count      => l_msg_count,
                  x_msg_data       => l_msg_data,
                  x_product_stmt   => l_offer_product_sql
      );
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         x_return_status := l_return_status;
         RAISE fnd_api.G_EXC_ERROR;
      END IF;
   END IF;
   FND_DSQL.add_text(')');

   IF l_offer_product_sql IS NULL AND l_offer_prod = FALSE THEN
      x_return_status := fnd_api.g_ret_sts_success;
      x_valid_flag := fnd_api.g_false;
      RETURN;
   END IF;

    IF l_offer_product_sql IS NOT NULL OR l_offer_prod THEN
        l_denorm_csr := DBMS_SQL.open_cursor;
        FND_DSQL.set_cursor(l_denorm_csr);
        l_stmt_denorm := FND_DSQL.get_text(FALSE);
        DBMS_SQL.parse(l_denorm_csr, l_stmt_denorm, DBMS_SQL.native);
        FND_DSQL.do_binds;
        l_ignore := DBMS_SQL.execute(l_denorm_csr);
        --dbms_output.put_line(l_ignore);
    END IF;

   l_exist_number := NULL;

   check_product_market_strict(
       p_exclude_only   =>  l_exclude_only,
       x_return_status  =>  l_return_status,
       x_valid_flag     =>  x_valid_flag
   );

   IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
       RAISE fnd_api.G_EXC_ERROR;
   ELSIF x_valid_flag <> fnd_api.G_TRUE THEN
       FND_MESSAGE.Set_Name ('OZF', 'OZF_API_DEBUG_MESSAGE');
       FND_MESSAGE.SET_TOKEN('text', 'Product validation fails. Offer has product that is not in product list of all budgets');
       FND_MSG_PUB.Add;
       RAISE fnd_api.G_EXC_ERROR;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status            := fnd_api.g_ret_sts_error;
END validate_product_by_all_lines;


/*  --------------------------------------------------------------------------
    --  yzhao: internal procedure called by validate_market_budget() to
    fix bug 2789492 - MKTF1R9:1159.0203:FUNC-BUDGET WITH MARKET ELIGIBILITY BUYING GROUP DOES NOT VALI
        set org id since for customer bill to, denorm query on org-striped table ra_addresses party,ra_site_uses
   --------------------------------------------------------------------------
 */
PROCEDURE set_budget_org (p_budget_id IN NUMBER) IS

  l_org_id        NUMBER;
--  l_org_string    VARCHAR2(10);

  CURSOR get_fund_org_csr IS
  SELECT org_id
  FROM   ozf_funds_all_b
  WHERE  fund_id = p_budget_id;

BEGIN

--  l_org_string := SUBSTRB(userenv('CLIENT_INFO'),1,10);
--  IF (l_org_string IS NULL) THEN
      OPEN  get_fund_org_csr;
      FETCH get_fund_org_csr INTO l_org_id;
      CLOSE get_fund_org_csr;

      set_org_ctx(l_org_id);
--  END IF;

END set_budget_org;


-------------------------------------------------------------------
-- NAME
--    validate_market_by_each_line
-- PURPOSE
--    validate customer by each budget line or to check if the budget has least one of offer's customer
--    private procedure called by validate_object_budget
--      evolved from the old API validate_market_budget
-- History
--    Created  kdass    25-Aug-2003    11.5.10 Offer Budget Validation
----------------------------------------------------------------
PROCEDURE validate_market_by_each_line (
   p_object_id          IN     NUMBER,
   p_object_type        IN     VARCHAR2,
   p_actbudget_id       IN     NUMBER,
   p_mode        IN     VARCHAR2,
   x_return_status      OUT NOCOPY    VARCHAR2,
   x_valid_flag         OUT NOCOPY    VARCHAR2)
IS
   l_offer_market_sql       VARCHAR2(32000) := NULL;
   l_budget_market_sql      VARCHAR2(32000) := NULL;
   l_exclude_sql            VARCHAR2(32000) := NULL;
   l_context                VARCHAR2(50)    := NULL;
   l_attribute              VARCHAR2(50)    := NULL;
   l_attr_value             VARCHAR2(200)   := NULL;
   l_exist_number           NUMBER := NULL;
   l_exclude_only           BOOLEAN := FALSE;
   l_return_status          VARCHAR2(20);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(2000)  := null;
   l_offer_type             VARCHAR2(30);
   l_offer_qualifier_id     NUMBER;
   l_denorm_csr             NUMBER;
   l_ignore                 NUMBER;
   l_stmt_denorm            VARCHAR2(32000) := NULL;
   l_budget_mark            BOOLEAN := FALSE;
   l_exclude_mark           BOOLEAN := FALSE;
   l_offer_mark             BOOLEAN := FALSE;

   -- yzhao: 02/13/2003 fix bug 2761622 AMS: VALIDATE MARKET ELIGIBILITY AND PRODUCT ELIGIBILITY BREAKS BUDGET APPROVAL
   -- get lumpsum or scan data offer's market qualifier
   CURSOR c_get_offer_customer IS
     SELECT offer_type, qualifier_id
     FROM   ozf_offers
     WHERE  qp_list_header_id = p_object_id;
BEGIN

   x_return_status := fnd_api.G_RET_STS_SUCCESS;
   x_valid_flag := fnd_api.g_true;

   /* yzhao: 02/07/2003 fix bug 2789518 - MKTF1R9:1159.0203:FUNC-BUDGET WITH MARKET ELIGIBILITY CUSTOMER BILL TO FAILS
       set org id since for customer bill to, denorm query on org-striped table ra_addresses party,ra_site_uses
    */
   set_budget_org(p_budget_id => p_actbudget_id);

   EXECUTE IMMEDIATE 'DELETE FROM ozf_temp_eligibility';

   denorm_market_for_one_budget (
            p_budget_id          => p_actbudget_id,
            x_budget_mark        => l_budget_mark,
            x_exclude_mark       => l_exclude_mark,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data);
   IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
       RAISE fnd_api.G_EXC_ERROR;
   END IF;

   -- no market eligibility for budget, validation is true.
   IF l_budget_mark = FALSE AND l_exclude_mark = FALSE THEN
       --dbms_output.put_line('budget does not have market eligiblity.');
       x_return_status := fnd_api.g_ret_sts_success;
       x_valid_flag := fnd_api.g_true;
       RETURN;
   END IF;

   IF l_budget_mark = FALSE AND l_exclude_mark = TRUE THEN
      --dbms_output.put_line('budget only has exclude market eligiblity.');
      l_exclude_only := TRUE;
   END IF;

   -- yzhao: 02/13/2003 fix bug 2761622 AMS: VALIDATE MARKET ELIGIBILITY AND PRODUCT ELIGIBILITY BREAKS BUDGET APPROVAL
   OPEN c_get_offer_customer;
   FETCH c_get_offer_customer INTO l_offer_type, l_offer_qualifier_id;
   CLOSE c_get_offer_customer;

   FND_DSQL.init;
   FND_DSQL.add_text('INSERT INTO ozf_temp_eligibility(object_type, exclude_flag, eligibility_id) ');
   FND_DSQL.add_text('SELECT  ''OFFR'', ''N'', party_id FROM (' );

   IF l_offer_type IN ('LUMPSUM', 'SCAN_DATA') THEN
       -- for lumpsum and scandata, market eligibility can be only one customer
       IF l_offer_qualifier_id IS NULL THEN
          l_offer_market_sql := NULL;
       ELSE
          /* yzhao: 02/28/2003 fix bug 2828596(2761622) AMS: VALIDATE MARKET ELIGIBILITY AND PRODUCT ELIGIBILITY BREAKS BUDGET APPROVAL
          -- l_offer_market_sql := 'SELECT ' || l_offer_qualifier_id || ' party_id FROM DUAL';
             select party.party_id from hz_cust_accounts account,hz_parties party where account.party_id=party.party_id and account.cust_account_id =
           */
          l_offer_mark := TRUE;
          l_context := 'CUSTOMER';                   -- same as customer sold to
          l_attribute := 'QUALIFIER_ATTRIBUTE2';
          l_attr_value := l_offer_qualifier_id;
          l_offer_market_sql := OZF_OFFR_ELIG_PROD_DENORM_PVT.get_sql
                         ( p_context => l_context,
                           p_attribute => l_attribute,
                           p_attr_value_from => l_attr_value,
                           p_attr_value_to  => NULL,
                           p_comparison => '=',
                           p_type => 'ELIG'
                          );
       END IF;
   ELSE
        -- get offer's market eligibility query
        OZF_OFFR_ELIG_PROD_DENORM_PVT.refresh_parties(
                      p_api_version    => 1.0,
                      p_init_msg_list  => fnd_api.g_false,
                      p_commit         => fnd_api.g_false,
                      p_list_header_id => p_object_id,
                      p_calling_from_den => 'N',
                      x_return_status  => l_return_status,
                      x_msg_count      => l_msg_count,
                      x_msg_data       => l_msg_data,
                      x_party_stmt     => l_offer_market_sql
        );
        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          x_return_status := l_return_status;
          RAISE fnd_api.G_EXC_ERROR;
        END IF;
   END IF;
   FND_DSQL.add_text(')');

   IF l_offer_market_sql IS NULL AND l_offer_mark = FALSE THEN
      x_return_status := fnd_api.g_ret_sts_success;
      x_valid_flag := fnd_api.g_false;
      RETURN;
   ELSE
      l_denorm_csr := DBMS_SQL.open_cursor;
      FND_DSQL.set_cursor(l_denorm_csr);
      l_stmt_denorm := FND_DSQL.get_text(FALSE);
      --dbms_output.put_line('offer query: '|| l_stmt_denorm);
      DBMS_SQL.parse(l_denorm_csr, l_stmt_denorm, DBMS_SQL.native);
      l_offer_market_sql := l_stmt_denorm;
      FND_DSQL.do_binds;
      l_ignore := DBMS_SQL.execute(l_denorm_csr);
      --dbms_output.put_line(l_ignore);
   END IF;

   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH) THEN
      FND_MESSAGE.Set_Name ('OZF', 'OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.SET_TOKEN('text', 'Offer market sql: ' || l_offer_market_sql);
      FND_MSG_PUB.Add;
      FND_MESSAGE.Set_Name ('OZF', 'OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.SET_TOKEN('text', 'Budget market sql: ' || l_budget_market_sql);
      FND_MSG_PUB.Add;
   END IF;

   l_exist_number := NULL;

   IF p_mode = 'LOOSE' THEN
       check_product_market_loose(
           p_exclude_only   =>  l_exclude_only,
           x_return_status  =>  l_return_status,
           x_valid_flag     =>  x_valid_flag
       );

       IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
           x_return_status := l_return_status;
       RAISE fnd_api.G_EXC_ERROR;
       ELSIF x_valid_flag <> fnd_api.G_TRUE THEN
           FND_MESSAGE.Set_Name ('OZF', 'OZF_API_DEBUG_MESSAGE');
           FND_MESSAGE.SET_TOKEN('text', 'Market validation fails. Offer does not have a single party that matches the party of the budget');
           FND_MSG_PUB.Add;
           RAISE fnd_api.G_EXC_ERROR;
       END IF;
   ELSIF p_mode = 'STRICT' THEN
       check_product_market_strict(
           p_exclude_only   =>  l_exclude_only,
           x_return_status  =>  l_return_status,
           x_valid_flag     =>  x_valid_flag
       );

       IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
           x_return_status := l_return_status;
           RAISE fnd_api.G_EXC_ERROR;
       ELSIF x_valid_flag <> fnd_api.G_TRUE THEN
           FND_MESSAGE.Set_Name ('OZF', 'OZF_API_DEBUG_MESSAGE');
           FND_MESSAGE.SET_TOKEN('text', 'Market validation fails. Offer has party that is not in budget market list');
           FND_MSG_PUB.Add;
           RAISE fnd_api.G_EXC_ERROR;
       END IF;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status            := fnd_api.g_ret_sts_error;

END validate_market_by_each_line;

-------------------------------------------------------------------
-- NAME
--    validate_market_by_all_lines
-- PURPOSE
--    validate customer by all budget lines
--    private procedure called by validate_object_budget_all
-- History
--    Created  kdass    25-Aug-2003    11.5.10 Offer Budget Validation
----------------------------------------------------------------
PROCEDURE validate_market_by_all_lines (
   p_object_id          IN     NUMBER,
   p_object_type        IN     VARCHAR2,
   x_return_status      OUT NOCOPY    VARCHAR2,
   x_valid_flag         OUT NOCOPY    VARCHAR2)
IS
   l_offer_market_sql       VARCHAR2(32000) := NULL;
   l_budget_market_sql      VARCHAR2(32000) := NULL;
   l_exclude_sql            VARCHAR2(32000) := NULL;
   l_temp_sql               VARCHAR2(2000)  := NULL;
   l_context                VARCHAR2(50)    := NULL;
   l_attribute              VARCHAR2(50)    := NULL;
   l_attr_value             VARCHAR2(200)   := NULL;
   l_exist_number           NUMBER := NULL;
   l_exclude_only           BOOLEAN := FALSE;
   l_return_status          VARCHAR2(20);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(2000)  := null;
   l_offer_type             VARCHAR2(30);
   l_offer_qualifier_id     NUMBER;
   l_denorm_csr             NUMBER;
   l_ignore                 NUMBER;
   l_segment_type           VARCHAR2(30);
   l_segment_id             NUMBER;
   l_excluded_flag          VARCHAR2(1);
   l_stmt_denorm        VARCHAR2(32000) := NULL;
   l_budget_mark            BOOLEAN := FALSE;
   l_exclude_mark           BOOLEAN := FALSE;
   l_offer_mark             BOOLEAN := FALSE;

   -- get budget's included and excluded market qualifier ids
   CURSOR c_get_budget_market_qualifiers(p_exclude_flag IN VARCHAR2) IS
     SELECT distinct market_segment_id, segment_type, exclude_flag
     FROM   ams_act_market_segments
     WHERE  act_market_segment_used_by_id
        IN
        (SELECT budget_source_id FROM ozf_act_budgets
        WHERE arc_act_budget_used_by = 'OFFR'
        AND act_budget_used_by_id = p_object_id
        AND transfer_type = 'REQUEST'
        AND status_code = 'APPROVED')
     AND arc_act_market_segment_used_by = 'FUND'
     AND exclude_flag = p_exclude_flag;

   -- yzhao: 02/13/2003 fix bug 2761622 AMS: VALIDATE MARKET ELIGIBILITY AND PRODUCT ELIGIBILITY BREAKS BUDGET APPROVAL
   -- get lumpsum or scan data offer's market qualifier
   CURSOR c_get_offer_customer IS
     SELECT offer_type, qualifier_id
     FROM   ozf_offers
     WHERE  qp_list_header_id = p_object_id;

BEGIN

   x_return_status := fnd_api.G_RET_STS_SUCCESS;
   x_valid_flag := fnd_api.g_true;

   /* yzhao: 02/07/2003 fix bug 2789518 - MKTF1R9:1159.0203:FUNC-BUDGET WITH MARKET ELIGIBILITY CUSTOMER BILL TO FAILS
       set org id since for customer bill to, denorm query on org-striped table ra_addresses party,ra_site_uses
    */
   --set_budget_org(p_budget_id => p_actbudget_id);

   EXECUTE IMMEDIATE 'DELETE FROM ozf_temp_eligibility';

   FND_DSQL.init;
   FND_DSQL.add_text('INSERT INTO ozf_temp_eligibility(object_type, exclude_flag, eligibility_id) ');
   FND_DSQL.add_text('SELECT  ''FUND'', ''N'', party_id FROM (');

   OPEN c_get_budget_market_qualifiers('N');

   -- Get all market qualifiers for 'FUND'
   LOOP
       FETCH c_get_budget_market_qualifiers INTO l_segment_id,l_segment_type,l_excluded_flag;
       EXIT WHEN c_get_budget_market_qualifiers%NOTFOUND OR c_get_budget_market_qualifiers%NOTFOUND is NULL;
       IF c_get_budget_market_qualifiers%ROWCOUNT > 0 THEN
          l_budget_mark := TRUE;
       END IF;
       -- should be the same as how they are created in amsvfrub.pls process_offers()
       IF l_segment_type = 'CUSTOMER' THEN
          l_context := 'CUSTOMER';                    -- for customer sold to
          l_attribute := 'QUALIFIER_ATTRIBUTE2';
       /* yzhao: 02/07/2003 fix bug 2789518 - MKTF1R9:1159.0203:FUNC-BUDGET WITH MARKET ELIGIBILITY CUSTOMER BILL TO FAILS */
       ELSIF l_segment_type = 'CUSTOMER_BILL_TO' THEN
          l_context := 'CUSTOMER';                    -- for customer bill to
          l_attribute := 'QUALIFIER_ATTRIBUTE14';
       /* yzhao: 02/07/2003 fix bug 2789518 ends */
       ELSIF l_segment_type = 'LIST' THEN
          l_context := 'CUSTOMER_GROUP';
          l_attribute := 'QUALIFIER_ATTRIBUTE1';
       ELSIF l_segment_type = 'SEGMENT' THEN
          l_context := 'CUSTOMER_GROUP';
          l_attribute := 'QUALIFIER_ATTRIBUTE2';
       ELSIF l_segment_type = 'BUYER' THEN
          l_context := 'CUSTOMER_GROUP';
          l_attribute := 'QUALIFIER_ATTRIBUTE3';
       ELSIF l_segment_type = 'TERRITORY' THEN
          l_context := 'TERRITORY';
          l_attribute := 'QUALIFIER_ATTRIBUTE1';
       /* feliu: 04/02/2003 fix bug 2778138 */
       ELSIF l_segment_type = 'SHIP_TO' THEN
          l_context := 'CUSTOMER';
          l_attribute := 'QUALIFIER_ATTRIBUTE11';
       END IF;

       l_attr_value := l_segment_id;

       IF  c_get_budget_market_qualifiers%ROWCOUNT = 1 THEN -- for first row.
            -- l_budget_product_sql := '(' || l_temp_sql || ')';
      FND_DSQL.add_text('(');
         l_temp_sql := OZF_OFFR_ELIG_PROD_DENORM_PVT.get_sql
                     ( p_context => l_context,
                       p_attribute => l_attribute,
                       p_attr_value_from => l_attr_value,
                       p_attr_value_to  => NULL,
                       p_comparison => '=',
                       p_type => 'ELIG'
                      );
      FND_DSQL.add_text(')');
        ELSE
             --l_budget_product_sql := l_budget_product_sql || ' UNION (' || l_temp_sql || ')';
            FND_DSQL.add_text('UNION (');
         l_temp_sql := OZF_OFFR_ELIG_PROD_DENORM_PVT.get_sql
                     ( p_context => l_context,
                       p_attribute => l_attribute,
                       p_attr_value_from => l_attr_value,
                       p_attr_value_to  => NULL,
                       p_comparison => '=',
                       p_type => 'ELIG'
                      );
      FND_DSQL.add_text(')');
       END IF;
       --dbms_output.put_line('validate_market_by_all_lines: budget:' || l_temp_sql );

   END LOOP;
   CLOSE c_get_budget_market_qualifiers;
   FND_DSQL.add_text(')');

   IF l_budget_mark THEN
        l_denorm_csr := DBMS_SQL.open_cursor;
        FND_DSQL.set_cursor(l_denorm_csr);
        l_stmt_denorm := FND_DSQL.get_text(FALSE);
        l_budget_market_sql := l_stmt_denorm;
        DBMS_SQL.parse(l_denorm_csr, l_stmt_denorm, DBMS_SQL.native);
        FND_DSQL.do_binds;
        l_ignore := DBMS_SQL.execute(l_denorm_csr);
        --dbms_output.put_line(l_ignore);
   END IF;

   FND_DSQL.init;
   FND_DSQL.add_text('INSERT INTO ozf_temp_eligibility(object_type, exclude_flag, eligibility_id) ');
   FND_DSQL.add_text('SELECT  ''FUND'', ''Y'', party_id FROM (');

   OPEN c_get_budget_market_qualifiers('Y');
   -- Get all excluded market qualifiers for 'FUND'
   LOOP
       FETCH c_get_budget_market_qualifiers INTO l_segment_id,l_segment_type,l_excluded_flag;
       EXIT WHEN c_get_budget_market_qualifiers%NOTFOUND OR c_get_budget_market_qualifiers%NOTFOUND is NULL;
       IF c_get_budget_market_qualifiers%ROWCOUNT > 0 THEN
          l_exclude_mark := TRUE;
       END IF;
       -- should be the same as how they are created in amsvfrub.pls process_offers()
       IF l_segment_type = 'CUSTOMER' THEN
          l_context := 'CUSTOMER';                    -- for customer sold to
          l_attribute := 'QUALIFIER_ATTRIBUTE2';
       /* yzhao: 02/07/2003 fix bug 2789518 - MKTF1R9:1159.0203:FUNC-BUDGET WITH MARKET ELIGIBILITY CUSTOMER BILL TO FAILS */
       ELSIF l_segment_type = 'CUSTOMER_BILL_TO' THEN
          l_context := 'CUSTOMER';                    -- for customer bill to
          l_attribute := 'QUALIFIER_ATTRIBUTE14';
       /* yzhao: 02/07/2003 fix bug 2789518 ends */
       ELSIF l_segment_type = 'LIST' THEN
          l_context := 'CUSTOMER_GROUP';
          l_attribute := 'QUALIFIER_ATTRIBUTE1';
       ELSIF l_segment_type = 'SEGMENT' THEN
          l_context := 'CUSTOMER_GROUP';
          l_attribute := 'QUALIFIER_ATTRIBUTE2';
       ELSIF l_segment_type = 'BUYER' THEN
          l_context := 'CUSTOMER_GROUP';
          l_attribute := 'QUALIFIER_ATTRIBUTE3';
       ELSIF l_segment_type = 'TERRITORY' THEN
          l_context := 'TERRITORY';
          l_attribute := 'QUALIFIER_ATTRIBUTE1';
       /* feliu: 04/02/2003 fix bug 2778138 */
       ELSIF l_segment_type = 'SHIP_TO' THEN
          l_context := 'CUSTOMER';
          l_attribute := 'QUALIFIER_ATTRIBUTE11';
       END IF;

       l_attr_value := l_segment_id;

       IF  c_get_budget_market_qualifiers%ROWCOUNT = 1 THEN -- for first row.
            -- l_budget_product_sql := '(' || l_temp_sql || ')';
      FND_DSQL.add_text('(');
         l_temp_sql := OZF_OFFR_ELIG_PROD_DENORM_PVT.get_sql
                     ( p_context => l_context,
                       p_attribute => l_attribute,
                       p_attr_value_from => l_attr_value,
                       p_attr_value_to  => NULL,
                       p_comparison => '=',
                       p_type => 'ELIG'
                      );
      FND_DSQL.add_text(')');
        ELSE
             --l_budget_product_sql := l_budget_product_sql || ' UNION (' || l_temp_sql || ')';
            FND_DSQL.add_text('UNION (');
         l_temp_sql := OZF_OFFR_ELIG_PROD_DENORM_PVT.get_sql
                     ( p_context => l_context,
                       p_attribute => l_attribute,
                       p_attr_value_from => l_attr_value,
                       p_attr_value_to  => NULL,
                       p_comparison => '=',
                       p_type => 'ELIG'
                      );
      FND_DSQL.add_text(')');
       END IF;

   END LOOP;
   CLOSE c_get_budget_market_qualifiers;
   FND_DSQL.add_text(')');

    IF l_exclude_mark THEN
        l_denorm_csr := DBMS_SQL.open_cursor;
        FND_DSQL.set_cursor(l_denorm_csr);
        l_stmt_denorm := FND_DSQL.get_text(FALSE);
        --dbms_output.put_line('validate_market_by_all_lines: Budget exclude query:' || l_stmt_denorm);
        DBMS_SQL.parse(l_denorm_csr, l_stmt_denorm, DBMS_SQL.native);
        FND_DSQL.do_binds;
        l_ignore := DBMS_SQL.execute(l_denorm_csr);
        --dbms_output.put_line(l_ignore);
    END IF;
    -- not product eligibility for budget, validation is true.
    IF l_budget_mark = FALSE AND l_exclude_mark = FALSE THEN
       --dbms_output.put_line('validate_market_by_all_lines: budget do not has market eligiblity.');
       x_return_status := fnd_api.g_ret_sts_success;
       x_valid_flag := fnd_api.g_true;
       RETURN;
   END IF;

   IF l_budget_mark = FALSE AND l_exclude_mark = TRUE THEN
      --dbms_output.put_line('validate_market_by_all_lines: budget only has exclude market eligiblity.');
      l_exclude_only := TRUE;
   END IF;

   -- yzhao: 02/13/2003 fix bug 2761622 AMS: VALIDATE MARKET ELIGIBILITY AND PRODUCT ELIGIBILITY BREAKS BUDGET APPROVAL
   OPEN c_get_offer_customer;
   FETCH c_get_offer_customer INTO l_offer_type, l_offer_qualifier_id;
   CLOSE c_get_offer_customer;

   FND_DSQL.init;
   FND_DSQL.add_text('INSERT INTO ozf_temp_eligibility(object_type, exclude_flag, eligibility_id) ');
   FND_DSQL.add_text('SELECT  ''OFFR'', ''N'', party_id FROM (' );

   IF l_offer_type IN ('LUMPSUM', 'SCAN_DATA') THEN
       -- for lumpsum and scandata, market eligibility can be only one customer
       IF l_offer_qualifier_id IS NULL THEN
          l_offer_market_sql := NULL;
       ELSE
          /* yzhao: 02/28/2003 fix bug 2828596(2761622) AMS: VALIDATE MARKET ELIGIBILITY AND PRODUCT ELIGIBILITY BREAKS BUDGET APPROVAL
          -- l_offer_market_sql := 'SELECT ' || l_offer_qualifier_id || ' party_id FROM DUAL';
             select party.party_id from hz_cust_accounts account,hz_parties party where account.party_id=party.party_id and account.cust_account_id =
           */
          l_offer_mark := TRUE;
          l_context := 'CUSTOMER';                   -- same as customer sold to
          l_attribute := 'QUALIFIER_ATTRIBUTE2';
          l_attr_value := l_offer_qualifier_id;
          l_offer_market_sql := OZF_OFFR_ELIG_PROD_DENORM_PVT.get_sql
                         ( p_context => l_context,
                           p_attribute => l_attribute,
                           p_attr_value_from => l_attr_value,
                           p_attr_value_to  => NULL,
                           p_comparison => '=',
                           p_type => 'ELIG'
                          );
       END IF;
   ELSE
        -- get offer's market eligibility query
        OZF_OFFR_ELIG_PROD_DENORM_PVT.refresh_parties(
                      p_api_version    => 1.0,
                      p_init_msg_list  => fnd_api.g_false,
                      p_commit         => fnd_api.g_false,
                      p_list_header_id => p_object_id,
                      p_calling_from_den => 'N',
                      x_return_status  => l_return_status,
                      x_msg_count      => l_msg_count,
                      x_msg_data       => l_msg_data,
                      x_party_stmt     => l_offer_market_sql
        );
        --dbms_output.put_line('validate_market_by_all_lines: Offer party sql returns ' || l_offer_market_sql);
        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          x_return_status := l_return_status;
          RAISE fnd_api.G_EXC_ERROR;
        END IF;
   END IF;
   FND_DSQL.add_text(')');

   IF l_offer_market_sql IS NULL AND l_offer_mark = FALSE THEN
      x_return_status := fnd_api.g_ret_sts_success;
      x_valid_flag := fnd_api.g_false;
      RETURN;
   ELSE
      l_denorm_csr := DBMS_SQL.open_cursor;
      FND_DSQL.set_cursor(l_denorm_csr);
      l_stmt_denorm := FND_DSQL.get_text(FALSE);
      --dbms_output.put_line('validate_market_by_all_lines: offer query: '|| l_stmt_denorm);
      DBMS_SQL.parse(l_denorm_csr, l_stmt_denorm, DBMS_SQL.native);
      l_offer_market_sql := l_stmt_denorm;
      FND_DSQL.do_binds;
      l_ignore := DBMS_SQL.execute(l_denorm_csr);
      --dbms_output.put_line(l_ignore);
   END IF;

   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH) THEN
      FND_MESSAGE.Set_Name ('OZF', 'OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.SET_TOKEN('text', 'Offer market sql: ' || l_offer_market_sql);
      FND_MSG_PUB.Add;
      FND_MESSAGE.Set_Name ('OZF', 'OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.SET_TOKEN('text', 'Budget market sql: ' || l_budget_market_sql);
      FND_MSG_PUB.Add;
   END IF;

   l_exist_number := NULL;
   check_product_market_strict(
       p_exclude_only   =>  l_exclude_only,
       x_return_status  =>  l_return_status,
       x_valid_flag     =>  x_valid_flag
   );

   IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
       RAISE fnd_api.G_EXC_ERROR;
   ELSIF x_valid_flag <> fnd_api.G_TRUE THEN
       FND_MESSAGE.Set_Name ('OZF', 'OZF_API_DEBUG_MESSAGE');
       FND_MESSAGE.SET_TOKEN('text', 'Market validation fails. Offer has party that is not in market list of all budgets');
       FND_MSG_PUB.Add;
       RAISE fnd_api.G_EXC_ERROR;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := fnd_api.g_ret_sts_error;

END validate_market_by_all_lines;


-------------------------------------------------------------------
-- NAME
--    validate_object_budget
-- PURPOSE
--      this API will be called by the Workflow API for each budget line to
--    validate whether a budget is qualified to fund an offer in terms of
--      market and product eligibility
-- History
--    Created   yzhao   01/22/2002
--              CREATE GLOBAL TEMPORARY TABLE ozf_temp_eligibility(
--                     OBJECT_TYPE  VARCHAR2(30),
--                     ELIGIBILITY_ID NUMBER,
--                     EXCLUDE_FLAG VARCHAR2(1))
--                     ON COMMIT DELETE ROWS;
--    Modified    kdass    22-Aug-2003  modified for 11.5.10 Offer Budget Validation
----------------------------------------------------------------
PROCEDURE validate_object_budget (
   p_object_id          IN     NUMBER,
   p_object_type        IN     VARCHAR2,
   p_actbudget_id       IN     NUMBER,
   x_return_status      OUT NOCOPY    VARCHAR2,
   x_msg_count          OUT NOCOPY    NUMBER,
   x_msg_data           OUT NOCOPY    VARCHAR2)
IS
   l_check_validation   VARCHAR2(50);
   l_return_status      VARCHAR2(20);
   l_valid_flag         VARCHAR2(5);
   l_offer_type         VARCHAR2(30);
   l_budget_id          NUMBER;
   l_msg_data           VARCHAR2(2000) := NULL;
   l_mode_product        VARCHAR2(20);
   l_mode_market        VARCHAR2(20);

   CURSOR c_get_fund_info IS
     SELECT budget_source_id
     FROM   ozf_act_budgets
     WHERE  activity_budget_id = p_actbudget_id;

   CURSOR c_get_offer_type IS
     SELECT offer_type
     FROM   ozf_offers
     WHERE  qp_list_header_id = p_object_id;

BEGIN

   SAVEPOINT validate_object_budget;

    l_check_validation := fnd_profile.value('OZF_CHECK_MKTG_PROD_ELIG');

    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message(' profile value:' || l_check_validation);
    END IF;

   IF (NVL(l_check_validation, 'NO') = 'NO') THEN
      -- return success if profile value is NO
      x_return_status := fnd_api.G_RET_STS_SUCCESS;
      RETURN;
   END IF;

   IF p_object_type <> 'OFFR' THEN
      -- return success. right now we only validate offer
      x_return_status := fnd_api.G_RET_STS_SUCCESS;
      RETURN;
   END IF;

   x_return_status := fnd_api.G_RET_STS_SUCCESS;

   OPEN c_get_fund_info;
   FETCH c_get_fund_info INTO l_budget_id;
   CLOSE c_get_fund_info;

   OPEN c_get_offer_type;
   FETCH c_get_offer_type INTO l_offer_type;
   CLOSE c_get_offer_type;

   IF l_check_validation = 'PRODUCT_STRICT_CUSTOMER_STRICT' THEN
        l_mode_product := 'STRICT';
        l_mode_market  := 'STRICT';
   ELSIF l_check_validation = 'PRODUCT_STRICT_CUSTOMER_LOOSE' THEN
        l_mode_product := 'STRICT';
        l_mode_market  := 'LOOSE';
   ELSIF l_check_validation = 'PRODUCT_LOOSE_CUSTOMER_STRICT' THEN
        l_mode_product := 'LOOSE';
        l_mode_market  := 'STRICT';
   END IF;

   IF l_offer_type <> 'ORDER' THEN
      -- offer type 'ORDER VALUE' does not have product eligibility, so do not check
       validate_product_by_each_line(
      p_object_id      =>  p_object_id,
      p_object_type    =>  p_object_type,
      p_offer_type     =>  l_offer_type,
      p_actbudget_id   =>  l_budget_id,
      p_mode       =>  l_mode_product,
      x_return_status  =>  l_return_status,
      x_valid_flag     =>  l_valid_flag
       );
    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message(' validate_product_by_each_line returns ' || l_return_status || ' valid_flag=' || l_valid_flag);
    END IF;
       IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RAISE fnd_api.G_EXC_ERROR;
       ELSIF l_valid_flag <> fnd_api.G_TRUE THEN
      -- how to return back message? through fnd_message?
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name ('OZF', 'OZF_PRODUCT_ELIG_MISMATCH');
         FND_MSG_PUB.Add;
      END IF;
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message('FAILURE: budget product eligibility does not match that of offer');
      END IF;
      RAISE fnd_api.G_EXC_ERROR;
       END IF;
   END IF;

   validate_market_by_each_line(
      p_object_id      =>  p_object_id,
      p_object_type    =>  p_object_type,
      p_actbudget_id   =>  l_budget_id,
      p_mode           =>  l_mode_market,
      x_return_status  =>  l_return_status,
      x_valid_flag     =>  l_valid_flag
   );
    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message(' validate_market_by_each_line returns ' || l_return_status);
    END IF;
   IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RAISE fnd_api.G_EXC_ERROR;
   ELSIF l_valid_flag <> fnd_api.G_TRUE THEN
      -- how to return back message? through fnd_message?
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name ('OZF', 'OZF_MARKET_ELIG_MISMATCH');
        FND_MSG_PUB.Add;
      END IF;
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message('FAILURE: budget market eligibility does not match that of offer');
      END IF;
      RAISE fnd_api.G_EXC_ERROR;
   END IF;
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(' SUCCESS ');
   END IF;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO validate_object_budget;
     x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO validate_object_budget;
     x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);

   WHEN OTHERS THEN
      ROLLBACK TO validate_object_budget;
      x_return_status            := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (
          p_count   => x_msg_count
        , p_data    => x_msg_data
        , p_encoded => fnd_api.g_false
      );

 END validate_object_budget;

-----------------------------------------------------------------
-- NAME
--    validate_object_budget_all
-- PURPOSE
--      this API will be called by the Workflow API after all the budget line
--    approvals are done. it will validate the offer's market and product
--    eligibility in terms of all budget lines
-- History
--    Created   kdass   22-Aug-2003    11.5.10 Offer Budget Validation
----------------------------------------------------------------
PROCEDURE validate_object_budget_all (
   p_object_id          IN     NUMBER,
   p_object_type        IN     VARCHAR2,
   x_return_status      OUT NOCOPY    VARCHAR2,
   x_msg_count          OUT NOCOPY    NUMBER,
   x_msg_data           OUT NOCOPY    VARCHAR2)
IS
   l_check_validation   VARCHAR2(50);
   l_return_status      VARCHAR2(20);
   l_valid_flag         VARCHAR2(5);
   l_offer_type         VARCHAR2(30);
   l_msg_data           VARCHAR2(2000) := NULL;

   CURSOR c_get_offer_type IS
     SELECT offer_type
     FROM   ozf_offers
     WHERE  qp_list_header_id = p_object_id;

BEGIN

   l_check_validation := fnd_profile.value('OZF_CHECK_MKTG_PROD_ELIG');

   IF (NVL(l_check_validation, 'NO') = 'NO') OR (l_check_validation = 'PRODUCT_STRICT_CUSTOMER_STRICT') THEN
      -- return success if profile value is NO or PRODUCT_STRICT_CUSTOMER_STRICT
      x_return_status := fnd_api.G_RET_STS_SUCCESS;
      RETURN;
   END IF;

   IF p_object_type <> 'OFFR' THEN
      -- return success. right now we only validate offer
      x_return_status := fnd_api.G_RET_STS_SUCCESS;
      RETURN;
   END IF;

   x_return_status := fnd_api.G_RET_STS_SUCCESS;

   OPEN c_get_offer_type;
   FETCH c_get_offer_type INTO l_offer_type;
   CLOSE c_get_offer_type;

   IF l_check_validation = 'PRODUCT_STRICT_CUSTOMER_LOOSE' THEN
   --  validate customer by all budget lines
       validate_market_by_all_lines(
          p_object_id      =>  p_object_id,
          p_object_type    =>  p_object_type,
          x_return_status  =>  l_return_status,
          x_valid_flag     =>  l_valid_flag
       );
       IF G_DEBUG THEN
          ozf_utility_pvt.debug_message(' validate_market_by_all_lines returns ' || l_return_status);
       END IF;
       IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
          x_return_status := l_return_status;
          -- revert all the approved budget lines
              revert_approved_request ( p_offer_id => p_object_id
                           ,x_return_status => l_return_status
                           ,x_msg_count => x_msg_count
                           ,x_msg_data => l_msg_data
                          );
          RAISE fnd_api.G_EXC_ERROR;
       ELSIF l_valid_flag <> fnd_api.G_TRUE THEN
          -- how to return back message? through fnd_message?
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name ('OZF', 'OZF_MARKET_ELIG_MISMATCH');
             FND_MSG_PUB.Add;
          END IF;
          IF G_DEBUG THEN
             ozf_utility_pvt.debug_message('FAILURE: all budgets market eligibility does not match that of offer');
          END IF;
          -- revert all the approved budget lines
              revert_approved_request ( p_offer_id => p_object_id
                           ,x_return_status => l_return_status
                           ,x_msg_count => x_msg_count
                           ,x_msg_data => l_msg_data
                          );
          RAISE fnd_api.G_EXC_ERROR;
       END IF;
   ELSIF l_check_validation = 'PRODUCT_LOOSE_CUSTOMER_STRICT' THEN
   --  validate product by all budget lines
       IF l_offer_type <> 'ORDER' THEN
          -- offer type 'ORDER VALUE' does not have product eligibility, so do not check
           validate_product_by_all_lines(
            p_object_id      =>  p_object_id,
            p_object_type    =>  p_object_type,
            p_offer_type     =>  l_offer_type,
            x_return_status  =>  l_return_status,
            x_valid_flag     =>  l_valid_flag
           );
          IF G_DEBUG THEN
             ozf_utility_pvt.debug_message(' validate_product_by_all_lines returns ' || l_return_status || ' valid_flag=' || l_valid_flag);
          END IF;
          IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
             x_return_status := l_return_status;
             -- revert all the approved budget lines
                 revert_approved_request ( p_offer_id => p_object_id
                              ,x_return_status => l_return_status
                              ,x_msg_count => x_msg_count
                              ,x_msg_data => l_msg_data
                              );
             RAISE fnd_api.G_EXC_ERROR;
          ELSIF l_valid_flag <> fnd_api.G_TRUE THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name ('OZF', 'OZF_PRODUCT_ELIG_MISMATCH');
            FND_MSG_PUB.Add;
             END IF;
             IF G_DEBUG THEN
                    ozf_utility_pvt.debug_message('FAILURE: all budgets product eligibility does not match that of offer');
             END IF;
             -- revert all the approved budget lines
                 revert_approved_request ( p_offer_id => p_object_id
                              ,x_return_status => l_return_status
                              ,x_msg_count => x_msg_count
                              ,x_msg_data => l_msg_data
                              );
             RAISE fnd_api.G_EXC_ERROR;
          END IF;
       END IF;
   END IF;


   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(' SUCCESS ');
   END IF;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
     x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
   WHEN fnd_api.g_exc_unexpected_error THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);

   WHEN OTHERS THEN
      x_return_status            := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (
          p_count   => x_msg_count
        , p_data    => x_msg_data
        , p_encoded => fnd_api.g_false
      );

 END validate_object_budget_all;



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
    , x_msg_data           OUT NOCOPY    VARCHAR2)
IS
  l_qualify_flag           BOOLEAN := false;
  l_budget_mark            BOOLEAN := FALSE;
  l_exclude_mark           BOOLEAN := FALSE;
  l_temp_id                NUMBER := null;
  l_party_id               NUMBER;
  l_return_status          VARCHAR2(30);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2048);

  CURSOR c_check_items(p_item_id NUMBER) IS
     SELECT 1
     FROM   dual
     WHERE    (EXISTS
     (SELECT 1
      FROM   ozf_temp_eligibility
      WHERE  object_type = 'FUND'
      AND    exclude_flag = 'N'
      AND    eligibility_id = p_item_id))
      AND (
          NOT EXISTS
     (SELECT 1
      FROM   ozf_temp_eligibility
      WHERE  object_type = 'FUND'
      AND    exclude_flag = 'Y'
      AND    eligibility_id = p_item_id));

  CURSOR c_check_exclude_items(p_item_id NUMBER) IS
     SELECT 1
     FROM   ozf_temp_eligibility
     WHERE  object_type = 'FUND'
     AND    exclude_flag = 'Y'
     AND    eligibility_id = p_item_id;

  /* currently validation use party_id, so get party_id only */
  CURSOR c_get_party_id IS
    SELECT party_id
    FROM   hz_cust_accounts
    WHERE  cust_account_id = p_cust_account_id;

BEGIN
  x_qualify_flag := false;
  x_return_status := fnd_api.G_RET_STS_SUCCESS;

  IF p_cust_account_id IS NULL THEN
     l_qualify_flag := true;
  ELSE
     OPEN c_get_party_id;
     FETCH c_get_party_id INTO l_party_id;
     CLOSE c_get_party_id;

     EXECUTE IMMEDIATE 'DELETE FROM ozf_temp_eligibility';

     denorm_market_for_one_budget (
            p_budget_id          => p_budget_id,
            x_budget_mark        => l_budget_mark,
            x_exclude_mark       => l_exclude_mark,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data);
     IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
         RAISE fnd_api.G_EXC_ERROR;
     END IF;

    IF l_budget_mark = FALSE AND l_exclude_mark = FALSE THEN
       -- no market eligibility for budget, validation is true.
       --dbms_output.put_line('budget does not have market eligiblity.');
       l_qualify_flag := true;
    ELSIF l_budget_mark = FALSE AND l_exclude_mark = TRUE THEN
       -- exclude items only
       --dbms_output.put_line('budget only has exclude market eligiblity.');
       OPEN c_check_exclude_items(l_party_id);
       FETCH c_check_exclude_items INTO l_temp_id;
       CLOSE c_check_exclude_items ;
       IF l_temp_id IS NULL THEN
          l_qualify_flag := true;
       ELSIF l_temp_id = 1 THEN
          l_qualify_flag := false;
       END IF;
   ELSE
       -- defined include items
       --dbms_output.put_line('budget defines include market eligiblity.');
       OPEN c_check_items(l_party_id);
       FETCH c_check_items INTO l_temp_id;
       CLOSE c_check_items ;
       IF l_temp_id = 1 THEN
          l_qualify_flag := true;
       ELSE
          l_qualify_flag := false;
       END IF;
    END IF;

  END IF;

  IF NOT l_qualify_flag THEN
      x_qualify_flag := false;
      x_return_status := fnd_api.G_RET_STS_SUCCESS;
      RETURN;
  END IF;

  IF p_product_item_id IS NULL THEN
      x_qualify_flag := true;
      x_return_status := fnd_api.G_RET_STS_SUCCESS;
      RETURN;
  END IF;

  l_temp_id := null;
  l_qualify_flag := false;
  EXECUTE IMMEDIATE 'DELETE FROM ozf_temp_eligibility';

  denorm_product_for_one_budget (
            p_budget_id          => p_budget_id,
            x_budget_prod        => l_budget_mark,
            x_exclude_prod       => l_exclude_mark,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data);
  IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
      RAISE fnd_api.G_EXC_ERROR;
  END IF;

  IF l_budget_mark = FALSE AND l_exclude_mark = FALSE THEN
       -- no product eligibility for budget, validation is true.
       --dbms_output.put_line('budget does not have product eligiblity.');
       l_qualify_flag := true;
  ELSIF l_budget_mark = FALSE AND l_exclude_mark = TRUE THEN
       -- exclude items only
       --dbms_output.put_line('budget only has exclude product eligiblity.');
       OPEN c_check_exclude_items(p_product_item_id);
       FETCH c_check_exclude_items INTO l_temp_id;
       CLOSE c_check_exclude_items ;
       IF l_temp_id IS NULL THEN
          l_qualify_flag := true;
       ELSIF l_temp_id = 1 THEN
          l_qualify_flag := false;
       END IF;
  ELSE
       -- defined include items
       --dbms_output.put_line('budget defines include market eligiblity.');
       OPEN c_check_items(p_product_item_id);
       FETCH c_check_items INTO l_temp_id;
       CLOSE c_check_items ;
       IF l_temp_id = 1 THEN
          l_qualify_flag := true;
       ELSE
          l_qualify_flag := false;
       END IF;
  END IF;

  x_qualify_flag := l_qualify_flag;
  x_return_status := fnd_api.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status            := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (
          p_count   => x_msg_count
        , p_data    => x_msg_data
        , p_encoded => fnd_api.g_false
      );

END check_budget_qualification;



-------------------------------------------------------------------
-- NAME
--   check if offer's budget threshold is met
--     if so, return offer status as 'APPROVED'
--     else, send notification to offer owner, and return offer status as 'NEW'
-- PURPOSE
--
-- History
--    Created   yzhao   07/11/2002
----------------------------------------------------------------
/*
PROCEDURE check_budget_threshold (
   p_object_type        IN     VARCHAR2,
   p_object_id          IN     NUMBER,
   x_new_status      OUT NOCOPY    VARCHAR2,
   x_return_status      OUT NOCOPY    VARCHAR2
)
IS
  l_notification_id            NUMBER;
  l_return_status              NUMBER;
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(4000);
  l_percent           NUMBER;
  TYPE obj_csr_type IS REF CURSOR ;
  l_obj_details   obj_csr_type;
  l_budget_amount              NUMBER;
  l_owner_id              NUMBER;
  l_total_amt             NUMBER;
  l_strSubject            VARCHAR2(300);
  l_strBody               VARCHAR2(2000);

CURSOR c_total_amount IS
  SELECT SUM(NVL(request_amount,0))
  FROM ozf_act_budgets
  WHERE act_budget_used_by_id= p_object_id
  AND arc_act_budget_used_by = p_object_type;

BEGIN

  x_return_status := fnd_api.g_ret_sts_success;
  l_percent := NVL(Fnd_Profile.Value('AMS_APPROVAL_CUTOFF_PERCENT'),0)/100;

  IF l_percent = 0 THEN -- if profile value is set to zero, x_new_status is 'ACTIVE'
     x_new_status := 'ACTIVE';
  ELSE
    IF p_object_type = 'CAMP' THEN
       OPEN l_obj_details  FOR
       SELECT budget_amount_tc,owner_user_id
       FROM ams_campaigns_vl
       WHERE campaign_id = p_object_id;
    ELSIF p_object_type = 'CSCH' THEN
       OPEN l_obj_details  FOR
       SELECT budget_amount_tc,owner_user_id
       FROM ams_campaign_schedules_vl
       WHERE schedule_id=p_object_id;
    ELSIF p_object_type = 'OFFR' THEN
       OPEN l_obj_details  FOR
       SELECT  budget_amount_tc,owner_id
       FROM ozf_offers
       WHERE qp_list_header_id=p_object_id;
    ELSIF p_object_type =  'EVEH' THEN
       OPEN l_obj_details FOR
       SELECT fund_amount_tc,owner_user_id
       FROM ams_event_headers_vl
       WHERE event_header_id = p_object_id;
    ELSIF p_object_type = 'EVEO' THEN
       OPEN l_obj_details FOR
       SELECT fund_amount_tc,owner_user_id
       FROM ams_event_offers_vl
       WHERE event_offer_id = p_object_id;
    ELSIF p_object_type = 'EONE' THEN
       OPEN l_obj_details FOR
       SELECT fund_amount_tc,owner_user_id
       FROM ams_event_offers_vl
       WHERE event_offer_id = p_object_id;
    ELSIF p_object_type = 'DELV' THEN
       OPEN l_obj_details FOR
       SELECT budget_amount_tc,owner_user_id
       FROM ams_deliverables_vl
       WHERE deliverable_id = p_object_id;
    ELSE
       Fnd_Message.Set_Name('OZF','OZF_BAD_APPROVAL_OBJECT_TYPE');
       Fnd_Msg_Pub.ADD;
       x_return_status := Fnd_Api.G_RET_STS_ERROR;
       RETURN;
    END IF ;

    FETCH l_obj_details INTO l_budget_amount,l_owner_id;
    IF l_obj_details%NOTFOUND THEN
       CLOSE l_obj_details;
       Fnd_Message.Set_Name('OZF','OZF_APPR_BAD_DETAILS');
       Fnd_Msg_Pub.ADD;
       x_return_status := Fnd_Api.G_RET_STS_ERROR;
       RETURN;
    END IF;
    CLOSE l_obj_details;

    OPEN c_total_amount;
    FETCH c_total_amount INTO l_total_amt;
    CLOSE c_total_amount;
    --if total request amount equal estimated amount multiple threshold,
    -- set x_new_status to 'ACTIVE', else set to 'DRAFT' and send notification.
    IF l_total_amt >= l_budget_amount * l_percent THEN
       x_new_status := 'ACTIVE';
    ELSE
       x_new_status := 'DRAFT';

      fnd_message.set_name('OZF', 'OZF_PARTNER_SOURCING_SUBJECT');
      --fnd_message.set_token ('BUDGET_AMT', l_request_amt, FALSE);
      --fnd_message.set_token ('PARTNER_NAME', l_partner_name, FALSE);
      l_strSubject := Substr(fnd_message.get,1,200);

      fnd_message.set_name('OZF', 'OZF_NOTIFY_HEADERLINE');
      --l_strBody := fnd_message.get ||fnd_global.local_chr(10)||fnd_global.local_chr(10);
      fnd_message.set_name ('OZF', 'OZF_VENDOR_MESSAGE');
      --fnd_message.set_token ('PARTNER_NAME', l_partner_name, FALSE);
      l_strBody   := l_strBody || Substr(fnd_message.get,1,1000);

      fnd_message.set_name('OZF', 'OZF_NOTIFY_FOOTER');
      l_strBody := l_strBody || fnd_global.local_chr(10) || fnd_global.local_chr(10) ||fnd_message.get ;

      ozf_utility_pvt.send_wf_standalone_message(
                          p_subject => l_strSubject
                          ,p_body  => l_strBody
                          ,p_send_to_res_id  => l_owner_id
                          ,x_notif_id  => l_notification_id
                          ,x_return_status  => l_return_status
                         );
    END IF; -- end of l_total_amt

  END IF; -- end of l_percent.

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (
          p_count   => l_msg_count
        , p_data    => l_msg_data
        , p_encoded => fnd_api.g_false
      );
END check_budget_threshold;
*/

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
   p_actbudget_id       IN     NUMBER
)
IS
  l_api_name            CONSTANT VARCHAR2(30)    := 'conc_validate_offer_budget';
  l_full_name           CONSTANT VARCHAR2(60)
                         := G_PACKAGE_NAME || '.' || l_api_name;
  l_new_status_id          NUMBER;
  l_return_status          VARCHAR2(30);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2048);
  l_act_budgets_rec        ozf_actbudgets_pvt.act_budgets_rec_type ;
  l_offer_status           VARCHAR2(30) := 'ACTIVE';
  l_strSubject             VARCHAR2(300);
  l_strBody                VARCHAR2(2000);
  l_owner_id               NUMBER;
  l_notification_id        NUMBER;
  l_amount_error           VARCHAR2(300);
  l_modifier_list_rec      Ozf_Offer_Pvt.modifier_list_rec_type;
  l_offer_code             VARCHAR2(50);
  l_offer_name             VARCHAR2(2000); -- change size from 50 to 2000 to accomodate long offer names
  l_budget_name            VARCHAR2(240);  -- change size from 50 to 240 to fix issue 2 in bug 4240968
  l_final_data             VARCHAR2(2000);
  l_msg_index              NUMBER ;
  l_cnt                    NUMBER := 0 ;

  CURSOR c_get_requests IS
    SELECT activity_budget_id, act_budget_used_by_id,arc_act_budget_used_by,requester_id
    FROM   ozf_act_budgets
    WHERE  arc_act_budget_used_by = p_object_type
    AND    act_budget_used_by_id = p_object_id
    AND    transfer_type = 'REQUEST';
 -- AND    status_code = 'PENDING';   -- should it be pending validation?

 CURSOR c_offer_info(p_object_id IN NUMBER) IS
    SELECT offer_type,custom_setup_id, reusable,offer_amount,offer_code,owner_id, qph.description
    FROM ozf_offers , qp_list_headers qph
    WHERE qp_list_header_id = p_object_id
    and qp_list_header_id = qph.list_header_id ;

  --kdass 09-DEC-2005 bug 4870218 - SQL ID# 14892629
  CURSOR c_get_budget_name(p_activity_id IN NUMBER) IS
   SELECT fun.short_name
   FROM   ozf_act_budgets , ozf_funds_all_tl fun
   WHERE  activity_budget_id = p_activity_id
   AND    budget_source_id = fun.fund_id
   AND USERENV('LANG') IN (fun.language, fun.source_lang);
  /*
  CURSOR c_get_budget_name(p_activity_id IN NUMBER) IS
   SELECT fun.short_name
   FROM   ozf_act_budgets , ozf_fund_details_v fun
   WHERE  activity_budget_id = p_activity_id
   AND    budget_source_id = fun.fund_id;
  */

BEGIN
  SAVEPOINT conc_validate_offer_budget;

  x_errbuf := null;
  x_retcode := 0;
  fnd_msg_pub.initialize;

  l_modifier_list_rec.QP_LIST_HEADER_ID := p_object_id;

  OPEN c_offer_info(p_object_id);
  FETCH c_offer_info INTO l_modifier_list_rec.offer_type,l_modifier_list_rec.custom_setup_id,
          l_modifier_list_rec.reusable,l_modifier_list_rec.offer_amount,l_offer_code,l_owner_id, l_offer_name;
  CLOSE c_offer_info;

  ozf_utility_pvt.Write_Conc_log('offer_type = ' || l_modifier_list_rec.offer_type);
  ozf_utility_pvt.Write_Conc_log('custom_setup_id = ' || l_modifier_list_rec.custom_setup_id);
  ozf_utility_pvt.Write_Conc_log('reusable = ' || l_modifier_list_rec.reusable);
  ozf_utility_pvt.Write_Conc_log('offer_amount = ' || l_modifier_list_rec.offer_amount);

  IF p_actbudget_id IS NOT NULL THEN

     ozf_utility_pvt.Write_Conc_log('p_actbudget_id IS NOT NULL');

     -- single budget request submission. called from ozf_actbudgets_pvt.
     validate_object_budget ( p_object_id          => p_object_id,
                            p_object_type        => p_object_type,
                            p_actbudget_id       => p_actbudget_id,
                            x_return_status      => l_return_status,
                            x_msg_count          => l_msg_count,
                            x_msg_data           => l_msg_data);


     ozf_actbudgets_pvt.init_act_budgets_rec(l_act_budgets_rec);
     l_act_budgets_rec.activity_budget_id := p_actbudget_id;

     IF l_return_status = fnd_api.G_RET_STS_SUCCESS THEN
        ozf_utility_pvt.Write_Conc_log('validation succeeds');
        -- validation succeeds. Change budget request status to 'APPROVED'
        l_act_budgets_rec.status_code := 'APPROVED';
        l_act_budgets_rec.user_status_id :=
                   ozf_utility_pvt.get_default_user_status ('OZF_BUDGETSOURCE_STATUS', l_act_budgets_rec.status_code);

        /*bug 4662453
        IF l_offer_status <> 'DRAFT' THEN
           l_offer_status := 'ACTIVE';
           ozf_utility_pvt.Write_Conc_log('l_offer_status1 : ' || l_offer_status);
        END IF;
        */

     ELSE
        ozf_utility_pvt.Write_Conc_log('validation fails');
        -- validation fail. Change budget request status to 'NEW'
        l_act_budgets_rec.status_code := 'NEW';
        l_act_budgets_rec.user_status_id :=
                  ozf_utility_pvt.get_default_user_status ('OZF_BUDGETSOURCE_STATUS', l_act_budgets_rec.status_code);

        /*bug 4662453
        l_offer_status := 'DRAFT';
        ozf_utility_pvt.Write_Conc_log('l_offer_status2 : ' || l_offer_status);
        */

        OPEN c_get_budget_name(p_actbudget_id);
        FETCH c_get_budget_name INTO l_budget_name;
        CLOSE c_get_budget_name;

        -- send notification to offer owner of budget request validation failure
        fnd_message.set_name('OZF', 'OZF_OFFER_VALIDATION_SUBJECT');
        fnd_message.set_token ('OFFER_CODE', l_offer_code, FALSE);
        l_strSubject := Substr(fnd_message.get,1,200);

        fnd_message.set_name('OZF', 'OZF_TM_NOTIFY_HEADERLINE');
        l_strBody := fnd_message.get ||fnd_global.local_chr(10)||fnd_global.local_chr(10);
        fnd_message.set_name ('OZF', 'OZF_OFFER_VALIDATION_MESSAGE');
        fnd_message.set_token ('OFFER_NAME', l_offer_name, FALSE);
        fnd_message.set_token ('FUND_NAME', l_budget_name, FALSE);
        fnd_message.set_token ('REQUEST_ID', p_actbudget_id, FALSE);
        l_strBody   := l_strBody || Substr(fnd_message.get,1,200);

        WHILE l_cnt < l_msg_count
         LOOP
           Fnd_Msg_Pub.Get
               (p_msg_index       => l_cnt + 1,
                p_encoded         => Fnd_Api.G_FALSE,
                p_data            => l_msg_data,
                p_msg_index_out   => l_msg_index );

                --kdass fix for bug 4621638
                l_final_data := Substr((l_final_data || l_msg_index || ': ' || l_msg_data || Fnd_Global.local_chr(10)),1,1500);
                /*
                l_final_data := l_final_data ||l_msg_index||': '
                         ||l_msg_data||Fnd_Global.local_chr(10) ;
                l_final_data := Substr(l_final_data,1,1500);   -- fix bug 4032040
                */
                l_cnt := l_cnt + 1 ;
         END LOOP ;

        l_strBody := l_strBody || fnd_global.local_chr(10) || fnd_global.local_chr(10) ||fnd_message.get ;
        l_strBody := l_strBody || Substr(l_final_data,1,1500) ;

        fnd_message.set_name('OZF', 'OZF_NOTIFY_FOOTER');
        l_strBody := l_strBody || fnd_global.local_chr(10) || fnd_global.local_chr(10) ||fnd_message.get ;

        ozf_utility_pvt.send_wf_standalone_message( p_subject => l_strSubject
                                                   ,p_body  => l_strBody
                                                   ,p_send_to_res_id  => l_owner_id
                                                   ,x_notif_id  => l_notification_id
                                                   ,x_return_status  => l_return_status
                                                  );

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
           ozf_utility_pvt.Write_Conc_log('Sent notification fails.');
        END IF;

    END IF; -- end of validation fail.

    ozf_actbudgets_pvt.Update_Act_Budgets (
         p_api_version     => 1.0,
         p_init_msg_list      => FND_API.g_false,
         p_commit             => FND_API.g_false,
         p_validation_level   => fnd_api.g_valid_level_full,
         x_return_status   => l_return_status,
         x_msg_count       => l_msg_count,
         x_msg_data        => l_msg_data,
         p_act_budgets_rec => l_act_budgets_rec
      );

     IF l_return_status <> fnd_api.g_ret_sts_success THEN
        ozf_utility_pvt.Write_Conc_log('Update_Act_Budgets fails.');
     END IF;

  ELSE -- called from offer activation. Check all budget requests of this offer
     ozf_utility_pvt.Write_Conc_log('p_actbudget_id IS NULL');
     ozf_utility_pvt.Write_Conc_log('Validate budget requests for offer id = ' || p_object_id);
     FOR request_rec IN c_get_requests LOOP

        ozf_utility_pvt.Write_Conc_log('Valid budget request id = ' || request_rec.activity_budget_id);

        validate_object_budget( p_object_id          => request_rec.act_budget_used_by_id,
                                p_object_type        => request_rec.arc_act_budget_used_by,
                                p_actbudget_id       => request_rec.activity_budget_id,
                                x_return_status      => l_return_status,
                                x_msg_count          => l_msg_count,
                                x_msg_data           => l_msg_data);

        ozf_actbudgets_pvt.init_act_budgets_rec(l_act_budgets_rec);
        l_act_budgets_rec.activity_budget_id := request_rec.activity_budget_id;

        ozf_utility_pvt.Write_Conc_log('Validation return status = ' || l_return_status);

        IF l_return_status = fnd_api.G_RET_STS_SUCCESS THEN
           ozf_utility_pvt.Write_Conc_log('validation succeeds');

           -- validation succeeds. Change budget request status to 'APPROVED'
           l_act_budgets_rec.status_code := 'APPROVED';
           l_act_budgets_rec.user_status_id :=
                   ozf_utility_pvt.get_default_user_status ('OZF_BUDGETSOURCE_STATUS', l_act_budgets_rec.status_code);

           IF l_offer_status <> 'DRAFT' THEN
              l_offer_status := 'ACTIVE';
              ozf_utility_pvt.Write_Conc_log('l_offer_status3 : ' || l_offer_status);
           END IF;

        ELSE
           ozf_utility_pvt.Write_Conc_log('validation fails');

           l_act_budgets_rec.status_code := 'NEW';
           l_offer_status := 'DRAFT';
           ozf_utility_pvt.Write_Conc_log('l_offer_status4 : ' || l_offer_status);
           l_act_budgets_rec.user_status_id :=
                   ozf_utility_pvt.get_default_user_status ('OZF_BUDGETSOURCE_STATUS', l_act_budgets_rec.status_code);

           OPEN c_get_budget_name(request_rec.activity_budget_id);
           FETCH c_get_budget_name INTO l_budget_name;
           CLOSE c_get_budget_name;

            fnd_message.set_name('OZF', 'OZF_OFFER_VALIDATION_SUBJECT');
            fnd_message.set_token ('OFFER_CODE', l_offer_code, FALSE);
            l_strSubject := Substr(fnd_message.get,1,200);

            fnd_message.set_name('OZF', 'OZF_TM_NOTIFY_HEADERLINE');
            l_strBody := fnd_message.get ||fnd_global.local_chr(10)||fnd_global.local_chr(10);
            fnd_message.set_name ('OZF', 'OZF_OFFER_VALIDATION_MESSAGE');
            fnd_message.set_token ('OFFER_NAME', l_offer_name, FALSE);
            fnd_message.set_token ('FUND_NAME', l_budget_name, FALSE);
            fnd_message.set_token ('REQUEST_ID', request_rec.activity_budget_id, FALSE);
            l_strBody   := l_strBody || Substr(fnd_message.get,1,200);

            WHILE l_cnt < l_msg_count
             LOOP
              Fnd_Msg_Pub.Get
               (p_msg_index       => l_cnt + 1,
                p_encoded         => Fnd_Api.G_FALSE,
                p_data            => l_msg_data,
                p_msg_index_out   => l_msg_index );

                --kdass fix for bug 4621638
                l_final_data := Substr((l_final_data || l_msg_index || ': ' || l_msg_data || Fnd_Global.local_chr(10)),1,1500);
                /*
                l_final_data := l_final_data ||l_msg_index||': '
                         ||l_msg_data||Fnd_Global.local_chr(10) ;
                l_final_data := Substr(l_final_data,1,1500);   -- fix bug 4032040
                */
                l_cnt := l_cnt + 1 ;
             END LOOP ;

            l_strBody := l_strBody || fnd_global.local_chr(10) || fnd_global.local_chr(10) ||fnd_message.get ;
            l_strBody := l_strBody || Substr(l_final_data,1,1500) ;

            fnd_message.set_name('OZF', 'OZF_NOTIFY_FOOTER');
            l_strBody := l_strBody || fnd_global.local_chr(10) || fnd_global.local_chr(10) ||fnd_message.get ;

            ozf_utility_pvt.send_wf_standalone_message( p_subject => l_strSubject
                                                       ,p_body  => l_strBody
                                                       ,p_send_to_res_id  => request_rec.requester_id
                                                       ,x_notif_id  => l_notification_id
                                                       ,x_return_status  => l_return_status
                                                      );

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
               ozf_utility_pvt.Write_Conc_log('Sent notification fails.');
            END IF;


            ozf_utility_pvt.Write_Conc_log('l_act_budgets_rec.activity_budget_id: ' || l_act_budgets_rec.activity_budget_id);

            /*kdass 05-DEC-2005 bug 4662453 - Update_Act_Budgets is being called twice, so removing this one
            ozf_actbudgets_pvt.Update_Act_Budgets ( p_api_version        => 1.0,
                                                    p_init_msg_list      => FND_API.g_false,
                                                    p_commit             => FND_API.g_false,
                                                    p_validation_level   => fnd_api.g_valid_level_full,
                                                    x_return_status      => l_return_status,
                                                    x_msg_count          => l_msg_count,
                                                    x_msg_data           => l_msg_data,
                                                    p_act_budgets_rec    => l_act_budgets_rec
                                                  );

            ozf_utility_pvt.Write_Conc_log('return status from Update_Act_Budgets = ' || l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
               ozf_utility_pvt.Write_Conc_log('Update_Act_Budgets fails');
            END IF;
            */

         END IF; -- end of validation fail

         ozf_actbudgets_pvt.Update_Act_Budgets ( p_api_version       => 1.0,
                                                 p_init_msg_list     => FND_API.g_false,
                                                 p_commit            => FND_API.g_false,
                                                 p_validation_level  => fnd_api.g_valid_level_full,
                                                 x_return_status     => l_return_status,
                                                 x_msg_count         => l_msg_count,
                                                 x_msg_data          => l_msg_data,
                                                 p_act_budgets_rec   => l_act_budgets_rec
                                               );

         ozf_utility_pvt.Write_Conc_log('Update_Act_Budgets returns = ' || l_return_status);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            ozf_utility_pvt.Write_Conc_log('Valid budget request id = ' || p_actbudget_id);
         ELSE
            ozf_utility_pvt.Write_Conc_log('Invalid budget request id = ' || p_actbudget_id);
         END IF;

      END LOOP;

  END IF; -- end of p_actbudget_id.

  ozf_utility_pvt.Write_Conc_log('validate_object_budget_all start');

  validate_object_budget_all ( p_object_id     => p_object_id,
                               p_object_type   => p_object_type,
                               x_return_status => l_return_status,
                               x_msg_count     => l_msg_count,
                               x_msg_data      => l_msg_data
                             );

  ozf_utility_pvt.Write_Conc_log('return status = ' || l_return_status);

  IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
     l_offer_status := 'DRAFT';
     ozf_utility_pvt.Write_Conc_log('Relaxed validation failed');
  END IF;

  --kdass 05-DEC-2005 bug 4662453 - offer activation API should only be called from offer activation.
  IF p_actbudget_id IS NULL THEN

     ozf_utility_pvt.Write_Conc_log('l_offer_status : ' || l_offer_status);
     l_modifier_list_rec.STATUS_CODE := l_offer_status;
     l_modifier_list_rec.USER_STATUS_ID :=
                ozf_utility_pvt.get_default_user_status ('OZF_OFFER_STATUS', l_modifier_list_rec.status_code);

     ozf_utility_pvt.Write_Conc_log('STATUS_CODE = ' || l_modifier_list_rec.STATUS_CODE);
     ozf_utility_pvt.Write_Conc_log('USER_STATUS_ID = ' || l_modifier_list_rec.USER_STATUS_ID);

     -- update offer status. if validation fail.
     --- otherwise to 'ACTIVE'
     Ozf_Offer_Pvt.Activate_Offer_Over( p_api_version     => 1.0
                                       ,p_init_msg_list   => FND_API.g_false
                                       ,p_commit          => FND_API.g_false
                                       ,x_return_status   =>  l_return_status
                                       ,x_msg_count       =>  l_msg_count
                                       ,x_msg_data        =>  l_msg_data
                                       ,p_called_from     => 'R'
                                       ,p_offer_rec       => l_modifier_list_rec
                                       ,x_amount_error    => l_amount_error
                                      );

     ozf_utility_pvt.Write_Conc_log('Activate_Offer_Over returns = ' || l_return_status);

     IF l_return_status <> fnd_api.g_ret_sts_success THEN
        ozf_utility_pvt.Write_Conc_log('exception raised');
        RAISE fnd_api.g_exc_error;
     END IF;

  END IF;

  COMMIT;

  x_retcode                  := 0;

  ozf_utility_pvt.Write_Conc_log(l_msg_data);

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ozf_utility_pvt.Write_Conc_log('fnd_api.g_exc_error');

      ROLLBACK TO conc_validate_offer_budget;

        -- revert to draft status
        UPDATE ozf_offers
        SET    status_code = 'DRAFT'
          ,user_status_id = OZF_Utility_PVT.get_default_user_status ('OZF_OFFER_STATUS', 'DRAFT')
          ,status_date = SYSDATE
          ,object_version_number = object_version_number + 1
        WHERE  qp_list_header_id = l_modifier_list_rec.qp_list_header_id;

        --kdass 05-DEC-2005 bug 4662453 - reverting budget line status from pending validation to draft
        IF p_actbudget_id IS NOT NULL THEN
           UPDATE ozf_act_budgets
           SET    status_code = 'DRAFT'
                 ,user_status_id = OZF_Utility_PVT.get_default_user_status ('OZF_BUDGETSOURCE_STATUS', 'DRAFT')
                 ,object_version_number = object_version_number + 1
           WHERE  activity_budget_id = p_actbudget_id
              AND status_code = 'PENDING';
        ELSE
           FOR request_rec IN c_get_requests
           LOOP
              UPDATE ozf_act_budgets
              SET    status_code = 'DRAFT'
                    ,user_status_id = OZF_Utility_PVT.get_default_user_status ('OZF_BUDGETSOURCE_STATUS', 'DRAFT')
                    ,object_version_number = object_version_number + 1
              WHERE  activity_budget_id = request_rec.activity_budget_id
                 AND status_code = 'PENDING';
           END LOOP;
        END IF;

        COMMIT;

         -- send notifiction.
         WHILE l_cnt < l_msg_count
          LOOP
           Fnd_Msg_Pub.Get
               (p_msg_index       => l_cnt + 1,
                p_encoded         => Fnd_Api.G_FALSE,
                p_data            => l_msg_data,
                p_msg_index_out   => l_msg_index );

                --kdass fix for bug 4621638
                l_final_data := Substr((l_final_data || l_msg_index || ': ' || l_msg_data || Fnd_Global.local_chr(10)),1,1500);
                /*
                l_final_data := l_final_data ||l_msg_index||': '
                         ||l_msg_data||Fnd_Global.local_chr(10) ;
                */
                l_cnt := l_cnt + 1 ;
         END LOOP ;

       fnd_message.set_name('OZF', 'OZF_TM_CONCURR_SUBJECT');
       fnd_message.set_token ('OFFER_CODE', l_offer_code, FALSE);
       l_strSubject := Substr(fnd_message.get,1,200);

       fnd_message.set_name('OZF', 'OZF_TM_NOTIFY_HEADERLINE');
       l_strBody := fnd_message.get ||fnd_global.local_chr(10)||fnd_global.local_chr(10);
       fnd_message.set_name ('OZF', 'OZF_TM_CONCURR_MESSAGE');
       fnd_message.set_token ('OFFER_CODE', l_offer_code, FALSE);
       l_strBody   := l_strBody || Substr(fnd_message.get,1,200);

       WHILE l_cnt < l_msg_count
          LOOP
           Fnd_Msg_Pub.Get
               (p_msg_index       => l_cnt + 1,
                p_encoded         => Fnd_Api.G_FALSE,
                p_data            => l_msg_data,
                p_msg_index_out   => l_msg_index );

                --kdass fix for bug 4621638
                l_final_data := Substr((l_final_data || l_msg_index || ': ' || l_msg_data || Fnd_Global.local_chr(10)),1,1500);
                /*
                l_final_data := l_final_data ||l_msg_index||': '
                         ||l_msg_data||Fnd_Global.local_chr(10) ;
                */
                l_cnt := l_cnt + 1 ;
          END LOOP ;
       l_strBody := l_strBody || fnd_global.local_chr(10) || fnd_global.local_chr(10) ||fnd_message.get ;
       l_strBody := l_strBody || Substr(l_final_data,1,1500) ;

       fnd_message.set_name('OZF', 'OZF_NOTIFY_FOOTER');
       l_strBody := l_strBody || fnd_global.local_chr(10) || fnd_global.local_chr(10) ||fnd_message.get ;

       ozf_utility_pvt.send_wf_standalone_message( p_subject => l_strSubject
                                                    ,p_body  => l_strBody
                                                    ,p_send_to_res_id  => l_owner_id
                                                    ,x_notif_id  => l_notification_id
                                                    ,x_return_status  => l_return_status
                                                   );

    WHEN OTHERS THEN
       ozf_utility_pvt.Write_Conc_log('other exception');
       ROLLBACK TO conc_validate_offer_budget;
       x_retcode                  := 1;
       x_errbuf                   := l_msg_data;
       ozf_utility_pvt.write_conc_log (x_errbuf);

END conc_validate_offer_budget;

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
   p_object_type           IN   VARCHAR2,
   p_object_id             IN   NUMBER,
   x_status_code           OUT NOCOPY  VARCHAR2
   )IS
      -- Local variables
      l_api_name            CONSTANT VARCHAR2(30)    := 'budget_request_approval';
      l_full_name           CONSTANT VARCHAR2(60)
               := G_PACKAGE_NAME || '.' || l_api_name;
      l_api_version         CONSTANT NUMBER                                  := 1.0;
      l_msg_count                    NUMBER;
      l_msg_data                     VARCHAR2(4000);
      l_return_status                VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_object_version_number        NUMBER;
      l_custom_setup_id              NUMBER;
      -- Cursor to find fund details
      CURSOR c_act_budgets(p_object_type VARCHAR2,p_object_id   NUMBER)
      IS
      select activity_budget_id
      from ozf_act_budgets
      where act_budget_used_by_id = p_object_id
      and arc_act_budget_used_by = p_object_type
      and transfer_type = 'REQUEST'
      and status_code = 'NEW';

      CURSOR c_total_budgets(p_object_type VARCHAR2,p_object_id   NUMBER)
      IS
        select NVL(SUM(request_amount),0)
        from ozf_act_budgets
        where act_budget_used_by_id = p_object_id
        and arc_act_budget_used_by = p_object_type
        and transfer_type = 'REQUEST';

      CURSOR l_budget_required (p_custom_setup_id IN NUMBER) IS
        SELECT NVL(attr_available_flag,'N')
        FROM   ams_custom_setup_attr
        WHERE  custom_setup_id = p_custom_setup_id
        AND    object_attribute = 'BREQ';

      CURSOR c_offer_info(p_object_id IN NUMBER) IS
        SELECT NVL(offer_amount,0),owner_id,custom_setup_id,offer_code
    FROM ozf_offers
        WHERE qp_list_header_id = p_object_id;

      l_act_budget_id      NUMBER;
      l_act_budgets_rec    ozf_actbudgets_pvt.act_budgets_rec_type ;
      l_check_validation   VARCHAR2(50) := fnd_profile.value('OZF_CHECK_MKTG_PROD_ELIG');
      l_request_id         NUMBER;
      l_status_code        VARCHAR2(50):= 'APPROVED';
      l_total_budget       NUMBER;
      l_recal_flag         VARCHAR2(1):= NVL (fnd_profile.VALUE ('AMS_BUDGET_ADJ_ALLOW_RECAL'), 'N');
      l_offer_amount       NUMBER;
      l_notify_message     VARCHAR2(50);
      l_owner_id           NUMBER;
      l_budget_req_flag    VARCHAR2(1);
      l_strSubject         VARCHAR2(300);
      l_strBody            VARCHAR2(1000);
      l_notification_id   NUMBER;
      l_offer_code         VARCHAR2(50);

   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      -- Initialize
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_full_name || ': start');
      END IF;

      IF p_object_type = 'OFFR' THEN

      OPEN c_total_budgets(p_object_type,p_object_id);
          FETCH c_total_budgets INTO l_total_budget;
          CLOSE c_total_budgets;

      -- get offer information.
          OPEN c_offer_info(p_object_id);
          FETCH c_offer_info INTO l_offer_amount,l_owner_id,l_custom_setup_id,l_offer_code;
          CLOSE c_offer_info;

/*  -- remove by feliu on 05/23/2006 according to offer's request.
          -- get budget required information.
          OPEN l_budget_required(l_custom_setup_id);
          FETCH l_budget_required INTO l_budget_req_flag;
          CLOSE l_budget_required;
*/
  --       IF l_budget_req_flag = 'Y' THEN -- required budget
            --IF l_total_budget > 0 THEN
               IF l_recal_flag = 'N' AND l_offer_amount > 0 AND l_offer_amount > l_total_budget THEN  -- if there is offer committed amount.
                  l_status_code := 'NEW';
               ELSE
                  l_status_code := 'PENDING_VALIDATION';
               END IF; -- offer amount
            --END IF; -- end of total budget.
    --     ELSE  -- for budget not required.
           -- IF l_total_budget > 0 THEN -- if there is budget line
             --  l_status_code := 'PENDING_VALIDATION';
           -- ELSE -- no budget line.
      --         l_status_code := 'APPROVED';
           -- END IF;
      --   END IF;  -- budget required.
      ELSE -- for other object type.
          l_status_code := 'APPROVED';
      END IF; -- end of offer type.
     -- added by feliu on 05/05/04 for special pricing and softfund.  exclude softunf and special pricing.
      IF (NVL(l_check_validation, 'NO') <> 'NO' AND l_status_code = 'PENDING_VALIDATION'  AND  NVL(l_custom_setup_id,0) NOT IN (110,115,116,117))
        --OR NVL(l_custom_setup_id,0) = 118 fix for bug 9305526
      THEN
         l_status_code := 'PENDING_VALIDATION';
      ELSIF l_status_code = 'NEW' THEN
         l_status_code := 'NEW';
      ELSE
         l_status_code := 'APPROVED';
      END IF;


      IF l_status_code <> 'NEW' THEN

      FOR actbudget_rec IN c_act_budgets(p_object_type,p_object_id)
         LOOP
            ozf_actbudgets_pvt.init_act_budgets_rec(l_act_budgets_rec);
            l_act_budgets_rec.activity_budget_id := actbudget_rec.activity_budget_id;

            l_act_budgets_rec.status_code :=  'APPROVED'; -- will changed to "PENDING_VALIDATION" by api.
            l_act_budgets_rec.user_status_id :=
                   ozf_utility_pvt.get_default_user_status ('OZF_BUDGETSOURCE_STATUS', l_act_budgets_rec.status_code);

        ozf_actbudgets_pvt.update_act_budgets (
               p_api_version=> 1.0
              ,p_init_msg_list=> fnd_api.g_false
              ,p_commit=> fnd_api.g_false
              ,p_validation_level=> fnd_api.g_valid_level_full
              ,x_return_status=> l_return_status
              ,x_msg_data=> x_msg_data
              ,x_msg_count=> x_msg_count
              ,p_act_budgets_rec=> l_act_budgets_rec
            );

            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            END IF;

         END LOOP;

      END IF;

      IF l_status_code = 'NEW' THEN

        fnd_message.set_name('OZF', 'OZF_OFFER_VALIDATION_SUBJECT');
        fnd_message.set_token ('OFFER_CODE', l_offer_code, FALSE);
        l_strSubject := Substr(fnd_message.get,1,200);

        fnd_message.set_name('OZF', 'OZF_TM_NOTIFY_HEADERLINE');
        l_strBody := fnd_message.get ||fnd_global.local_chr(10)||fnd_global.local_chr(10);
        fnd_message.set_name ('OZF', 'OZF_OFF_REQ_NOT_ENOUGH');
        l_strBody   := l_strBody || Substr(fnd_message.get,1,200);

        fnd_message.set_name('OZF', 'OZF_NOTIFY_FOOTER');
        l_strBody := l_strBody || fnd_global.local_chr(10) || fnd_global.local_chr(10) ||fnd_message.get ;

        ozf_utility_pvt.send_wf_standalone_message(
                          p_subject => l_strSubject
                          ,p_body  => l_strBody
                          ,p_send_to_res_id  => l_owner_id
                          ,x_notif_id  => l_notification_id
                          ,x_return_status  => l_return_status
                         );

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
       RAISE fnd_api.g_exc_error;
        END IF;

      END IF; -- end of status of draft.

      IF l_status_code = 'PENDING_VALIDATION' THEN
         l_request_id := fnd_request.submit_request (
                            application   => 'OZF',
                            program       => 'OZFVALIELIG',
                            start_time    => sysdate,
                argument1     => p_object_id,
                argument2     => p_object_type
                         );
         COMMIT;
         IF l_request_id <> 0 THEN
            x_status_code := 'PENDING_VALIDATION';
         ELSE
            RAISE fnd_api.g_exc_error;
         END IF;
      ELSIF  l_status_code = 'NEW' THEN
         x_status_code := 'DRAFT';
      ELSE
         x_status_code := 'ACTIVE';
      END IF;

      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_full_name || ': end');
      END IF;

      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);

    EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(G_PACKAGE_NAME, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
   END budget_request_approval;


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
   p_object_type           IN   VARCHAR2,
   p_object_id             IN   NUMBER
   )IS

   l_budget_status     VARCHAR2(30);
   BEGIN
            budget_request_approval(
   p_init_msg_list         => p_init_msg_list,
   p_api_version           => p_api_version,
   p_commit                => p_commit,
   x_return_status         => x_return_status,
   x_msg_count             => x_msg_count,
   x_msg_data              => x_msg_data,
   p_object_type           => p_object_type,
   p_object_id             => p_object_id,
   x_status_code           => l_budget_status
  );

END budget_request_approval;

END OZF_BudgetApproval_PVT;

/
