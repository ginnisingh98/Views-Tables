--------------------------------------------------------
--  DDL for Package Body OZF_FUNDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_FUNDS_PVT" AS
/* $Header: ozfvfunb.pls 120.25.12010000.4 2010/05/03 09:11:22 nepanda ship $ */
-----------------------------------------------------------
-- PACKAGE
--    OZF_Funds_PVT
--
-- PROCEDURES
--
--    Create_Fund
--    Delete_Fund
--    Lock_Fund
--    Update_Fund
--    Validate_Fund
--
--    Check_Fund_Req_Items
--    Check_Fund_Uk_Items
--    Check_Fund_Fk_Items
--    Check_Fund_Lookup_Items
--    Check_Fund_Flag_Items
--
--    Check_Fund_Items
--    Check_Fund_Record
--
--    Init_Fund_Rec
--    Complete_Fund_Rec
--    GET_DEFAULT_GL_INFO
-- HISTORY
--    02/02/2000  Shitij Vatsa  Create.
--    06/12/2000  Mumu Pande Made all fund record validation
--    06/13/2000  Mumu Pande Added all access calls
--    06/15/2000  Mumu Pande Added all amount validation and status_vaidation
--    07/06/2000  Mumu Pande Added accrual_type fund validations fo rR2
---   07/06/2000  COMPLETE_DEFAULT_GL_INFO ADDED FOR R2 Requirements to get default GL info--- mpande
--    07/28/2000  Added MC Transactions calls ,added convert_currency calls ,added 3 procedures check_fund_type_vs_child
--                and check_fund_dates_vs_child and check_fund_amount_vs_child
--    08/03/2000  Commented out uniqueness validation on fund short_name
--    08/28/2001  mpande bug#1950117
--    10/11/2001  yzhao  bug#2020218 publish: child budget market eligibility and product eligibility not set
--    03/11/2003  feliu  added copy for accrual budget.
-- DESCRIPTION
-- Amount columns in Budgets
-- Original budget -- When you create a budget you enter this amount and update it when fund_status is DRAFT.
--    You cannot update this amount once the fund status is ACTIVE
-- Holdback Budget -- This is like putting aside some money which wont be calculated in your avalaible budget
-- Available budget-- This is always a calculated amount and the formula is
--    (OB (Original)-HB (Holback)) +(TI(Transfer in) - TO(Transfer out))
-- Total Budget -- This is always a calculated amount and the formula is
--    (AB (Available) + HB (Holback))
--    08/29/2000   mchang   insert org_id value into OZF_FUNDS_ALL_TL when creating a fund.
--    09/12/2000   mpande   added code to facilitate team and other user update access
--    09/26/2000   mpande   added code to facilitate user_status
--    11/30/2000   mpande   BUG#1494231
--------------major changes for 11.5.5----------------------------------------------------------------
--   1) All functionality related to statistical fund removed.
--   2) Added the five columns ,  start_period_name,  end_period_name,  accrual_quantity,
--       accrue_to_level_id,fund_calendar
--   3) Introduced new API check_fund-inter_entity
--   4) Removed some of the fund rules validations to package OZFFundRulesPvt (for clarity)
--   5) Removed all active fund transactions to package OZFFundRulesPvt
--   6) Added approval and other fully accrued fund related transactions
--   05/09/2001 MPande added   l_act_budget_rec.adjusted_flag ='N' when calling create_act_budget
--   06/22/2001 MPande Added code for business_ubit, threshold, country task
--   07/10/2001 Mpande bug#1875760
--   07/30/2001 Feliu  add accrual_rate, accrual_basis,country_id as required field for copy.
--   10/23/2001 Feliu  add recal_committed.
--   11/06/2001 mpande Updated for updating transfered in amount and not original budget for child fund
--                     Commented security group id
--                     Added validation for dated for fully accrued budget
--                     Added extra parameters in copy
------------------------------------------------------------  ------------------------------- /
--   02/08/2002 Feliu  1)Added columns for rollup amount and procedure for updating rollup amount.
--                     for create, first create rollup amount, if parent_fund_id is not null
--                     call update_rollup_amount to update rollup amount for parent fund.
--                     for update, first update rollup amount. if parent_fund_id is not null,
--                     pass rollup diffence to update_rollup_amount for all parent fund.
--                     if parent_id is remove, then pass fund own rollup amount in negative and
--                     call update_rollup_amount for all_parent fund.
--                     2)Added update_funds_access procedure for updating parent fund access. If parent_fund_id is
--                     not null, call this procedure to create access for all parent fund. if parent_fund_id
--                     is removed, call this procedure to remove access for all parent fund. if parent_fund_id
--                     or fund owner has been changed, first remove access then create access for all
--                     parent funds.
--   03/11/2002        Modify rollup amount calculation.
--   6/11/2002  mpande Accrual Offer Original budget Updatoin Fixed
--   07/01/2002 feliu  Removed default g_universal_currency and added error message.
--   07/15/2002 yzhao  fix bug 2457199 UNABLE TO CREATE FULLY ACCRUED BUDGET DUE TO START DATE PROBLEM
--   11/06/2002 feliu  fix bug 2637445 OWNER OF CHILD BUDGET CAN REMOVE OWNER OF PARENT BUDGET FROM TEAM by setting
--                     owner_flag to 'Y' when adding access for parent budget owner.
--   11/06/2002 feliu  fix bug 2654263 CHILD LINE MISSING FROM TREE OVERVIEW by adding access during create budget.
--   03/13/2003 feliu  fix bug copy of accrual budget and market eligibility.
--   03/18/2003 yzhao  handle allocation activation on territory hiearchy of different owners - bypass workflow approval
--   06/03/2003 yzhao  fix bug 2984497 - TST1159.14 MASTER: BUDGET APPROVAL VALIDATION FAILS UPON APPROVAL IN WORKFLOW
--   11/07/2003 yzhao: fix bug 3238497 - allow fully accrual budget to go below 0
--   Wed Mar 10 2004:1/59 PM RSSHARMA Call raise_business_event on request approval.
--                                    This will raise a business event if the fund type is Quota
--   06-APR-2004 mkothari  Changed bussiness event param to oracle.apps.ozf.quota.QuotaApproval
--   20-Apr-2004 rimehrot Check fund amount should not be <= 0: bug fix 3580531
--   10-May-2004 feliu add business event for budget create, update, and approval.
--   09/09/2004 Ribha  Bug Fix 3498826. Validate for fund_number uniqueness modified. Validate for fund_name uniqueness removed.
--   12/28/2004 kdass  fix for 11.5.10 bug 4089720, when the fund is created from mass transfer, do not check for end date
--   01/04/2005 Ribha  Bug Fix 4087106 - Rollup holdback amount not updated when holdback amt updated manualy.
--   10/10/2005 kdass  R12 bug 4613689 - validate accrual budget's ledger and offer's org
--   10/26/2005 mkothari Forward port 11.5.10 Bug 4701105
--   11/09/2005 kdass  fixed bug 4618523
--   04-Feb-2006 asylvia fixed bug 5073532 . Duplicate Budget Number error .
--   27-Mar-2006 asylvia fixed bug 5107243 . Copy Budget doesnt copy all the fields .
--   06-APR-2006 kdass   fixed bug 5104398
--   19-Apr-2006 asylvia fixed bug 5169099 . Copy Activity of Accrual Budget to new Budget.
--   25-APR-2006 kdass   fixed bug 5176819 - Ledger is required field
--   26-APR-2006 asylvia fixed bug 5185302 . Remove copying end date to new budget .
--   08-OCT-2008 nirprasa fixed bug 7425189 - Use old conversion date for reconcile flow
--   12-JUN-2009 kdass    bug 8532055 - ADD EXCHANGE RATE DATE PARAM TO OZF_FUND_UTILIZED_PUB.CREATE_FUND_ADJUSTMENT API
--   03-MAY-2010 nepanda  bug 9616725 - not able to get the fund_id in subscription for ozf budget create business event
   g_pkg_name    CONSTANT VARCHAR2(30) := 'OZF_Funds_PVT';
   -- 08/14/2001 mpande updated for approval and object type
   G_PARENT_APPROVAL_TYPE CONSTANT VARCHAR2(30) := 'BUDGET';
   -- addded 08/14/2001 mpande
   g_activity_type             CONSTANT VARCHAR2(30) := 'RFRQ';
   -- added 02/08/2002 by feliu
   g_universal_currency   CONSTANT VARCHAR2 (15) := fnd_profile.VALUE ('OZF_UNIV_CURR_CODE');
   G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);


-----------------------------------------------------------------------
-- PROCEDURE
--    handle_fund_status
--
-- HISTORY
--    20/09/00  mpande  Created.
-----------------------------------------------------------------------


PROCEDURE handle_fund_status(
   p_user_status_id   IN       NUMBER
  ,x_status_code      OUT NOCOPY      VARCHAR2
  ,x_return_status    OUT NOCOPY      VARCHAR2)
IS
   l_status_code    VARCHAR2(30);

   CURSOR c_status_code
   IS
      SELECT   system_status_code
      FROM     ams_user_statuses_vl
      WHERE  user_status_id = p_user_status_id
         AND system_status_type = 'OZF_FUND_STATUS'
         AND enabled_flag = 'Y';
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
   OPEN c_status_code;
   FETCH c_status_code INTO l_status_code;
   CLOSE c_status_code;

   IF l_status_code IS NULL THEN
      x_return_status := fnd_api.g_ret_sts_error;
      Ozf_utility_pvt.error_message('OZF_FUND_BAD_USER_STATUS');
   END IF;

   x_status_code := l_status_code;
END handle_fund_status;

-----------------------------------------------------------------------
-- PROCEDURE
--    get_user_status
--
-- HISTORY
--    20/09/00  mpande  Created.
-- this packagge is created because ,if there are already records in funds table
-- then it would be taken care of them .
-----------------------------------------------------------------------

PROCEDURE get_user_status(
   p_status_code      IN       VARCHAR2
  ,x_user_status_id   OUT NOCOPY      NUMBER
  ,x_return_status    OUT NOCOPY      VARCHAR2)
IS
   l_user_status_id    NUMBER;

   CURSOR c_user_status_id
   IS
      SELECT   user_status_id
      FROM     ams_user_statuses_vl
      WHERE  UPPER(system_status_code) = UPPER(p_status_code)
         AND system_status_type = 'OZF_FUND_STATUS'
         AND enabled_flag = 'Y';
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
   OPEN c_user_status_id;
   FETCH c_user_status_id INTO l_user_status_id;
   CLOSE c_user_status_id;

   IF l_user_status_id IS NULL THEN
      x_return_status := fnd_api.g_ret_sts_error;
      Ozf_utility_pvt.error_message('OZF_FUND_BAD_USER_STATUS');
   END IF;

   x_user_status_id := l_user_status_id;
END get_user_status;
-----------------------------------------------------------------------
-- PROCEDURE
--    get_child_source_code
--
-- HISTORY
--    02/20/2001  mpande  Created.
-----------------------------------------------------------------------

PROCEDURE get_child_source_code(
   p_parent_fund_id   IN       NUMBER
  ,x_code             OUT NOCOPY      VARCHAR2
  ,x_return_status    OUT NOCOPY      VARCHAR2)
IS
   l_par_number    VARCHAR2(30);
   l_count         NUMBER       := 0;

   CURSOR c_child_count(
      p_fund_id   IN   NUMBER)
   IS
      SELECT   COUNT(fund_id)
      FROM     ozf_funds_all_b
      WHERE  parent_fund_id = p_fund_id;

   CURSOR c_parent_number(
      p_fund_id   IN   NUMBER)
   IS
      SELECT   fund_number
      FROM     ozf_funds_all_b
      WHERE  fund_id = p_fund_id;
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
   OPEN c_child_count(p_parent_fund_id);
   FETCH c_child_count INTO l_count;
   CLOSE c_child_count;
   OPEN c_parent_number(p_parent_fund_id);
   FETCH c_parent_number INTO l_par_number;
   CLOSE c_parent_number;

   IF l_par_number IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         fnd_msg_pub.add;
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
   END IF;

   x_code := SUBSTRB(l_par_number || l_count, 1, 30);

   --asylvia Fixed bug 5073532
   WHILE ozf_utility_pvt.check_uniqueness('ozf_funds_all_b'
         ,'fund_number = ''' || x_code || '''') =
            fnd_api.g_false LOOP
                  l_count := l_count + 1 ;
                  x_code :=SUBSTRB(l_par_number || l_count, 1, 30);
  END LOOP;

END get_child_source_code;

-----------------------------------------------------------------------
-- PROCEDURE
--    raise_business_event
--
-- HISTORY
--    05/08/2004  feliu  Created.
-----------------------------------------------------------------------


PROCEDURE raise_business_event(p_object_id IN NUMBER,p_event_type IN VARCHAR2)
IS
CURSOR c_fund_type(p_fund_id NUMBER) IS
SELECT fund_type FROM ozf_funds_all_b
WHERE fund_id = p_fund_id;

l_fund_type varchar2(30);
l_item_key varchar2(30);
l_event_name varchar2(80);

l_parameter_list wf_parameter_list_t;
BEGIN
  l_item_key := p_object_id ||'_'|| TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');
  l_parameter_list := WF_PARAMETER_LIST_T();

  OPEN c_fund_type(p_object_id);
  FETCH c_fund_type into l_fund_type;
  CLOSE c_fund_type;

  IF l_fund_type = 'QUOTA' THEN
    l_event_name :=  'oracle.apps.ozf.quota.QuotaApproval';
  ELSE
       IF p_event_type = 'CREATE' THEN
              l_event_name :=  'oracle.apps.ozf.fund.budget.creation';
       ELSIF  p_event_type = 'UPDATE' THEN
               l_event_name :=  'oracle.apps.ozf.fund.budget.update';
       ELSE
              l_event_name :=  'oracle.apps.ozf.fund.budget.approval';
       END IF;
  END IF;

  IF G_DEBUG THEN
    ozf_utility_pvt.debug_message('p_event_type is :'||p_event_type || '    Fund Id is :'||p_object_id );
  END IF;

    wf_event.AddParameterToList(p_name           => 'P_FUND_ID',
                              p_value          => p_object_id,
                              p_parameterlist  => l_parameter_list);

   IF G_DEBUG THEN
       ozf_utility_pvt.debug_message('Item Key is  :'||l_item_key);
  END IF;

    wf_event.raise( p_event_name =>l_event_name,
                  p_event_key  => l_item_key,
                  p_parameters => l_parameter_list);


EXCEPTION
WHEN OTHERS THEN
RAISE Fnd_Api.g_exc_error;
ozf_utility_pvt.debug_message('Exception in raising business event');
END;


---------------------------------------------------------------------
-- PROCEDURE
--    Create_Fund
--
-- HISTORY
--    02/02/2000  Shitij Vatsa  Create.
--    06/13/2000  Added access calls and other validations
--    07/24/2000  Added Multiple Currency Calls


--    01/15/2001  Made all necessary changes for 11.5.5 .
--    02/08/2002  Added create rollup amount.
-- NOTE
--    For all bug fixes for prior 11.5.5 please arcs out the
--    earlier versions.
--    The create API is called with a 'active' fund status only from allocation
--    where no approval is required . Create fund doesnot handle the approval process.
---------------------------------------------------------------------

PROCEDURE create_fund(
   p_api_version        IN       NUMBER
  ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
  ,p_commit             IN       VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
  ,x_return_status      OUT NOCOPY      VARCHAR2
  ,x_msg_count          OUT NOCOPY      NUMBER
  ,x_msg_data           OUT NOCOPY      VARCHAR2
  ,p_fund_rec           IN       fund_rec_type
  ,x_fund_id            OUT NOCOPY      NUMBER)
IS
   l_api_version     CONSTANT NUMBER       := 1.0;
   l_api_name        CONSTANT VARCHAR2(30) := 'Create_Fund';

   l_full_name       CONSTANT VARCHAR2(60)
            := g_pkg_name || '.' || l_api_name;
   l_return_status            VARCHAR2(1);
   l_fund_rec                 fund_rec_type
         := p_fund_rec;
   l_fund_count               NUMBER;
   l_object_version_number    NUMBER                                           := 1;
   --//mpande
   l_request_id               NUMBER;
   l_approver_id              NUMBER;
   l_is_requester_owner       VARCHAR2(10);
--   l_request_rec              ozf_fund_request_pvt.request_rec_type;
   -- variable for creating access //mpande
   l_access_rec               ams_access_pvt.access_rec_type;
   l_access_id                NUMBER;
   l_par_fund_owner           NUMBER;
   /* R12: yzhao bug 4669269 - obsolete ozf_mc_transactions
   -- record and table variable for creating FC record // mpande
   l_mc_transaction_rec       ozf_mc_transactions_pvt.mc_transactions_rec_type;
   l_mc_transaction_id        NUMBER;
    */
   l_act_budget_rec              ozf_actbudgets_pvt.act_budgets_rec_type;
   l_act_budget_id               NUMBER                                ;
   l_is_requestor_owner       VARCHAR2(30);
   l_rate                     NUMBER;
   l_valid_flag               VARCHAR2(1);
   l_ledger_name              VARCHAR2(50);

   CURSOR c_fund_seq
   IS
      SELECT   ozf_funds_s.nextval
      FROM     dual;

   --changed by mpande
   CURSOR c_fund_count(
      cv_fund_id   IN   NUMBER)
   IS
      SELECT   COUNT(fund_id)
      FROM     ozf_funds_all_b
      WHERE  fund_id = cv_fund_id;


     CURSOR c_prog_fund_number (cl_fund_number IN VARCHAR2)
     IS
     SELECT count(fund_id) from ozf_funds_all_b
     WHERE fund_number = cl_fund_number;

BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT create_fund;
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name || ': start');
   END IF;
   x_return_status := fnd_api.g_ret_sts_success;

   IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- check fund status and fill in system status
   handle_fund_status(
      p_user_status_id => l_fund_rec.user_status_id
     ,x_status_code => l_fund_rec.status_code
     ,x_return_status => x_return_status);

   IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- default fund calendar
   IF     l_fund_rec.fund_calendar IS NULL
      AND (   l_fund_rec.start_period_name IS NOT NULL
           OR l_fund_rec.end_period_name IS NOT NULL) THEN
      l_fund_rec.fund_calendar := fnd_profile.VALUE('AMS_CAMPAIGN_DEFAULT_CALENDER');
   END IF;

   IF p_fund_rec.fund_number IS NULL THEN
      IF p_fund_rec.parent_fund_id IS NULL  THEN
            /*l_fund_rec.fund_number :=
               ams_sourcecode_pvt.get_source_code(
                  p_category_id => p_fund_rec.category_id
                 ,p_arc_object_for => 'FUND');*/
          l_valid_flag := 1;
          WHILE  l_valid_flag <> 0 LOOP
           l_fund_rec.fund_number :=
               ams_sourcecode_pvt.get_source_code(
                  p_category_id => p_fund_rec.category_id
                 ,p_arc_object_for => 'FUND');

             OPEN c_prog_fund_number (l_fund_rec.fund_number);
             FETCH c_prog_fund_number INTO l_valid_flag;
             CLOSE c_prog_fund_number; -- Bug Fix 3498826

           /*l_valid_flag := ams_utility_pvt.check_uniqueness(
            'ozf_funds_all_vl'
           ,'fund_number = ''' || l_fund_rec.fund_number || '''');*/

        END LOOP;
        -- by feliu on 11/10/03 to fix bug  3244033
      ELSE
         get_child_source_code(
            p_fund_rec.parent_fund_id
           ,l_fund_rec.fund_number
           ,x_return_status);
         IF x_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;
   END IF;

   ----------------------- validate -----------------------
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name || ': validate');
   END IF;
   validate_fund(
      p_api_version => l_api_version
     ,p_init_msg_list => p_init_msg_list
     ,p_validation_level => p_validation_level
     ,x_return_status => l_return_status
     ,x_msg_count => x_msg_count
     ,x_msg_data => x_msg_data
     ,p_fund_rec => l_fund_rec);


   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -------------------------- insert --------------------------
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name || ': insert');
   END IF;

   IF l_fund_rec.fund_id IS NULL THEN
      LOOP
         OPEN c_fund_seq;
         FETCH c_fund_seq INTO l_fund_rec.fund_id;
         CLOSE c_fund_seq;
         OPEN c_fund_count(l_fund_rec.fund_id);
         FETCH c_fund_count INTO l_fund_count;
         CLOSE c_fund_count;
         EXIT WHEN l_fund_count = 0;
      END LOOP;
   END IF;


   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name || ': get_category');
   END IF;

   -- kdass 09-NOV-05 Bug 4618523
   /*
   --added by mpande 6th JULY-2000 get default category GL Info
   IF p_fund_rec.category_id IS NOT NULL THEN
      complete_default_gl_info(
         l_fund_rec.category_id
        ,l_fund_rec.accrued_liable_account
        ,l_fund_rec.ded_adjustment_account
        ,l_return_status);

      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END IF;
   */

   -- 11/06/2001 mpande added for updating transfered in amount
   IF p_fund_rec.status_code = 'ON_HOLD' OR  l_fund_rec.status_code = 'ACTIVE' THEN
      IF p_fund_rec.parent_fund_id IS NOT NULL THEN
         l_fund_rec.transfered_in_amt := l_fund_rec.original_budget;
         l_fund_rec.original_budget := 0 ;
      END IF;
   END IF;

   IF g_universal_currency IS NULL THEN

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_UNIV_CURR_NOT_FOUND');
         fnd_msg_pub.add;
      END IF;

      RAISE fnd_api.g_exc_error;

   END IF;

-- Calculate rollup amount columns, added by feliu 02/08/02
   IF l_fund_rec.original_budget IS NOT NULL
     AND l_fund_rec.original_budget <> fnd_api.g_miss_num THEN
         Ozf_utility_pvt.convert_currency(
            x_return_status => l_return_status
           ,p_from_currency => l_fund_rec.currency_code_tc
           ,p_to_currency => g_universal_currency
           ,p_from_amount => l_fund_rec.original_budget
           ,x_to_amount => l_fund_rec.rollup_original_budget
           ,x_rate => l_rate);

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

   END IF;

   IF l_fund_rec.transfered_in_amt IS NOT NULL
     AND l_rate is NOT NULL
     AND l_fund_rec.transfered_in_amt <> fnd_api.g_miss_num THEN

     l_fund_rec.rollup_transfered_in_amt := l_fund_rec.transfered_in_amt * l_rate;

   END IF;

   IF l_fund_rec.transfered_out_amt IS NOT NULL
     AND l_rate is NOT NULL
     AND l_fund_rec.transfered_out_amt <> fnd_api.g_miss_num THEN

     l_fund_rec.rollup_transfered_out_amt := l_fund_rec.transfered_out_amt * l_rate;

   END IF;


   IF l_fund_rec.holdback_amt IS NOT NULL
     AND l_rate is NOT NULL
     AND l_fund_rec.holdback_amt <> fnd_api.g_miss_num THEN
     l_fund_rec.rollup_holdback_amt := l_fund_rec.holdback_amt * l_rate;
   END IF;

  -- make liability_flag to be 'N' for sales accrual.
   IF l_fund_rec.accrual_basis ='SALES' THEN
      l_fund_rec.liability_flag := 'N';
   END IF;

   -- kdass 09-NOV-05 Bug 4618523
   -- if ledger_id is null, derive it from org_id which is the default OU for the user
   IF l_fund_rec.ledger_id = fnd_api.g_miss_num OR l_fund_rec.ledger_id IS NULL THEN

      IF l_fund_rec.org_id <> fnd_api.g_miss_num AND l_fund_rec.org_id IS NOT NULL THEN
         MO_UTILS.Get_Ledger_Info (
                    p_operating_unit     =>  l_fund_rec.org_id,
                    p_ledger_id          =>  l_fund_rec.ledger_id,
                    p_ledger_name        =>  l_ledger_name
            );
      END IF;

   END IF;

   INSERT INTO ozf_funds_all_b
               (
                              fund_id,
                              last_update_date,
                              last_updated_by,
                              last_update_login,
                              creation_date,
                              created_by,
                              created_from,
                              request_id,
                              program_application_id,
                              program_id,
                              program_update_date,
                              fund_number,
                              parent_fund_id,
                              category_id,
                              fund_type,
                              fund_usage,   -- obsolete
                              status_code,
                              user_status_id,
                              status_date,
                              accrued_liable_account,
                              ded_adjustment_account,
                              liability_flag,
                              set_of_books_id,   -- obsolete
                              start_period_id,   -- obsolete
                              end_period_id,   -- obsolete
                              start_date_active,
                              end_date_active,
                              budget_amount_tc,   -- obsolete
                              budget_amount_fc,   -- obsolete
                              available_amount,   -- obsolete
                              distributed_amount,   -- obsolete
                              currency_code_tc,
                              currency_code_fc,   -- obsolete
                              exchange_rate_type,   -- obsolete
                              exchange_rate_date,   -- obsolete
                              exchange_rate,   -- obsolete
                              department_id,   -- obsolete
                              costcentre_id,   -- obsolete
                              owner,
                              accrual_method,
                              accrual_operand,
                              accrual_rate,
                              accrual_basis,
                              hierarchy,
                              hierarchy_level,
                              hierarchy_id,
                              parent_node_id,
                              node_id,   --,level_value
                              budget_flag,
                              earned_flag,
                              apply_accrual_on,   -- obsolete
                              accrual_phase,
                              accrual_cap,
                              accrual_uom,
                              object_version_number,
                              attribute_category,
                              attribute1,
                              attribute2,
                              attribute3,
                              attribute4,
                              attribute5,
                              attribute6,
                              attribute7,
                              attribute8,
                              attribute9,
                              attribute10,
                              attribute11,
                              attribute12,
                              attribute13,
                              attribute14,
                              attribute15,
                              org_id,
                              original_budget,
                              transfered_in_amt,
                              transfered_out_amt,
                              holdback_amt,
                              planned_amt,
                              committed_amt,
                              earned_amt,
                              paid_amt,
                              plan_type,   -- obsolete
                              plan_id,   -- obsolete
                              liable_accnt_segments,   -- obsolete
                              adjustment_accnt_segments,   -- obsolete
                              fund_calendar,
                              start_period_name,
                              end_period_name,
                              accrual_quantity,
                              accrue_to_level_id,
                              accrual_discount_level,
                              custom_setup_id,
                              threshold_id,
                              business_unit_id,
                              country_id,
                              task_id,
                              rollup_original_budget,
                              rollup_transfered_in_amt,
                              rollup_transfered_out_amt,
                              rollup_holdback_amt,
                              retroactive_flag,
                              qualifier_id,
                              -- niprakas added
                              prev_fund_id,
                              transfered_flag,
                              utilized_amt,
                              rollup_utilized_amt,
                              product_spread_time_id,
                              ledger_id  -- kdass - R12 MOAC changes
        )
        VALUES(
           l_fund_rec.fund_id
          ,SYSDATE   -- LAST_UPDATE_DATE
          ,NVL(fnd_global.user_id, -1)   -- LAST_UPDATED_BY
          ,NVL(fnd_global.conc_login_id, -1)   -- LAST_UPDATE_LOGIN
          ,SYSDATE   -- CREATION_DATE
          ,NVL(fnd_global.user_id, -1)   -- CREATED_BY
          ,NULL   -- l_fund_rec.created_from                -- CREATED_FROM -- we donot use this column
          ,fnd_global.conc_request_id   -- REQUEST_ID
          ,fnd_global.prog_appl_id   -- PROGRAM_APPLICATION_ID
          ,fnd_global.conc_program_id   -- PROGRAM_ID
          ,SYSDATE   -- PROGRAM_UPDATE_DATE
          ,l_fund_rec.fund_number
          ,l_fund_rec.parent_fund_id
          ,l_fund_rec.category_id
          ,l_fund_rec.fund_type
          ,l_fund_rec.fund_usage
          ,l_fund_rec.status_code
          ,l_fund_rec.user_status_id
          ,NVL(l_fund_rec.status_date, SYSDATE)
          ,l_fund_rec.accrued_liable_account
          ,l_fund_rec.ded_adjustment_account
          ,NVL(l_fund_rec.liability_flag, 'N')
          ,l_fund_rec.set_of_books_id
          ,l_fund_rec.start_period_id
          ,l_fund_rec.end_period_id
          ,NVL(l_fund_rec.start_date_active, SYSDATE)
          ,l_fund_rec.end_date_active
          ,l_fund_rec.budget_amount_tc
          ,l_fund_rec.budget_amount_fc
          ,l_fund_rec.available_amount
          ,l_fund_rec.distributed_amount
          ,l_fund_rec.currency_code_tc
          ,l_fund_rec.currency_code_fc
          ,l_fund_rec.exchange_rate_type
          ,l_fund_rec.exchange_rate_date
          ,l_fund_rec.exchange_rate
          ,l_fund_rec.department_id
          ,l_fund_rec.costcentre_id
          ,NVL(l_fund_rec.owner, NVL(fnd_global.user_id, -1))   -- OWNER
          ,l_fund_rec.accrual_method
          ,l_fund_rec.accrual_operand
          ,l_fund_rec.accrual_rate
          ,l_fund_rec.accrual_basis
          ,l_fund_rec.hierarchy
          ,l_fund_rec.hierarchy_level
          ,l_fund_rec.hierarchy_id
          ,l_fund_rec.parent_node_id
          ,l_fund_rec.node_id   --,l_fund_rec.level_value
          ,NVL(l_fund_rec.budget_flag, 'N')
          ,NVL(l_fund_rec.earned_flag, 'N')
          ,l_fund_rec.apply_accrual_on
          ,l_fund_rec.accrual_phase
          ,l_fund_rec.accrual_cap
          ,l_fund_rec.accrual_uom
          ,l_object_version_number   -- OBJECT_VERSION_NUMBER
          ,l_fund_rec.attribute_category
          ,l_fund_rec.attribute1
          ,l_fund_rec.attribute2
          ,l_fund_rec.attribute3
          ,l_fund_rec.attribute4
          ,l_fund_rec.attribute5
          ,l_fund_rec.attribute6
          ,l_fund_rec.attribute7
          ,l_fund_rec.attribute8
          ,l_fund_rec.attribute9
          ,l_fund_rec.attribute10
          ,l_fund_rec.attribute11
          ,l_fund_rec.attribute12
          ,l_fund_rec.attribute13
          ,l_fund_rec.attribute14
          ,l_fund_rec.attribute15
          --,TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1, 10))   -- org_id
          ,l_fund_rec.org_id  -- kdass - R12 MOAC changes
          ,l_fund_rec.original_budget
          ,l_fund_rec.transfered_in_amt
          ,l_fund_rec.transfered_out_amt
          ,l_fund_rec.holdback_amt
          ,l_fund_rec.planned_amt
          ,l_fund_rec.committed_amt
          ,l_fund_rec.earned_amt
          ,l_fund_rec.paid_amt
          ,l_fund_rec.plan_type
          ,l_fund_rec.plan_id
          ,l_fund_rec.liable_accnt_segments
          ,l_fund_rec.adjustment_accnt_segments
          ,l_fund_rec.fund_calendar
          ,l_fund_rec.start_period_name
          ,l_fund_rec.end_period_name
          ,l_fund_rec.accrual_quantity
          ,l_fund_rec.accrue_to_level_id
          ,l_fund_rec.accrual_discount_level
          ,l_fund_rec.custom_setup_id
          ,l_fund_rec.threshold_id
          ,l_fund_rec.business_unit_id
          ,l_fund_rec.country_id
          ,l_fund_rec.task_id
          ,l_fund_rec.rollup_original_budget
          ,l_fund_rec.rollup_transfered_in_amt
          ,l_fund_rec.rollup_transfered_out_amt
          ,l_fund_rec.rollup_holdback_amt
          ,l_fund_rec.retroactive_flag
          ,l_fund_rec.qualifier_id
           -- niprakas added
          ,l_fund_rec.prev_fund_id
          ,l_fund_rec.transfered_flag
          ,l_fund_rec.utilized_amt
          ,l_fund_rec.rollup_utilized_amt
          ,l_fund_rec.product_spread_time_id
          ,l_fund_rec.ledger_id
);

   INSERT INTO ozf_funds_all_tl
               (fund_id,
                last_update_date,
                last_updated_by,
                last_update_login,
                creation_date,
                created_by,
                created_from,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
                short_name,
                description,
                source_lang,
                language,
                org_id     )
      SELECT   l_fund_rec.fund_id
              ,SYSDATE   -- LAST_UPDATE_DATE
              ,NVL(fnd_global.user_id, -1)   -- LAST_UPDATED_BY
              ,NVL(fnd_global.conc_login_id, -1)   -- LAST_UPDATE_LOGIN
              ,SYSDATE   -- CREATION_DATE
              ,NVL(fnd_global.user_id, -1)   -- CREATED_BY
              ,NULL   -- CREATED_FROM
              ,fnd_global.conc_request_id   -- REQUEST_ID
              ,fnd_global.prog_appl_id   -- PROGRAM_APPLICATION_ID
              ,fnd_global.conc_program_id   -- PROGRAM_ID
              ,SYSDATE   -- PROGRAM_UPDATE_DATE
              ,l_fund_rec.short_name
              ,l_fund_rec.description
              ,USERENV('LANG')
              ,l.language_code
              --,TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1, 10))
              ,l_fund_rec.org_id  -- kdass - R12 MOAC changes
      FROM     fnd_languages l
      WHERE  l.installed_flag IN('I', 'B')
         AND NOT EXISTS(SELECT   NULL
                        FROM     ozf_funds_all_tl t
                        WHERE  t.fund_id = l_fund_rec.fund_id
                           AND t.language = l.language_code);

   ------------------------- finish -------------------------------
   x_fund_id := l_fund_rec.fund_id;
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name || ': insert object attribute');
   END IF;

   -- If the fund_status is 'ACTIVE', we need to create a record in th ACT_BUDGET table for the holdback amount
   -- fixed bug for validation level and p_commit

   IF ((l_fund_rec.status_code = 'ACTIVE')
       AND (NVL(l_fund_rec.holdback_amt, 0) <> 0)) THEN
      l_act_budget_rec.status_code := 'APPROVED';
      l_act_budget_rec.arc_act_budget_used_by := 'FUND';   -- hardcoded to fund
      l_act_budget_rec.act_budget_used_by_id := l_fund_rec.fund_id;
      l_act_budget_rec.requester_id := l_fund_rec.owner;
      l_act_budget_rec.approver_id := l_fund_rec.owner;
      l_act_budget_rec.request_amount := l_fund_rec.holdback_amt;   --- in transferring to fund currency
      l_act_budget_rec.approved_amount := l_fund_rec.holdback_amt;   --- in transferring to fund currency
      l_act_budget_rec.approved_original_amount := l_fund_rec.holdback_amt;   --- in transferring to fund currency
      l_act_budget_rec.budget_source_type := 'FUND';
      l_act_budget_rec.budget_source_id := l_fund_rec.fund_id;
      l_act_budget_rec.transfer_type := 'RESERVE';
      l_act_budget_rec.transaction_type := 'CREDIT';
      l_act_budget_rec.approved_in_currency := l_fund_rec.currency_code_tc;
      l_act_budget_rec.adjusted_flag :='N';
      --l_act_budget_rec.date_required_by := p_needbydate;
      -- Create_transfer record
      ozf_actbudgets_pvt.create_act_budgets(
         p_api_version => l_api_version
        ,x_return_status => l_return_status
        ,x_msg_count => x_msg_count
        ,x_msg_data => x_msg_data
        ,p_act_budgets_rec => l_act_budget_rec
        ,x_act_budget_id => l_act_budget_id);

      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END IF;

   /* R12: yzhao bug 4669269 - obsolete ozf_mc_transactions
   --- Insert a record in OZF_MC_TRANSACTIONS_ALL IN functional currency
   --  so that we have the functional currency amounts
   --   The exchange_rate_type is picked up by the MC_TRAnSACTIONS API from proile
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name || ': insert Functional currency record');
   END IF;
   -- Populate the record variable
   l_mc_transaction_rec.source_object_name := 'FUND';
   l_mc_transaction_rec.source_object_id := l_fund_rec.fund_id;
   l_mc_transaction_rec.currency_code := l_fund_rec.currency_code_tc;
   l_mc_transaction_rec.amount_column1 := l_fund_rec.original_budget;
   l_mc_transaction_rec.amount_column2 := l_fund_rec.transfered_in_amt;
   l_mc_transaction_rec.amount_column3 := l_fund_rec.transfered_out_amt;
   l_mc_transaction_rec.amount_column4 := l_fund_rec.holdback_amt;
   l_mc_transaction_rec.amount_column5 := l_fund_rec.planned_amt;
   l_mc_transaction_rec.amount_column6 := l_fund_rec.committed_amt;
   l_mc_transaction_rec.amount_column7 := l_fund_rec.earned_amt;
   l_mc_transaction_rec.amount_column8 := l_fund_rec.paid_amt;
   l_mc_transaction_rec.amount_column9 := l_fund_rec.utilized_amt;   -- yzhao: 11.5.10
   -- Call mc_transaction API if the fund type is not QUOTA
   IF l_fund_rec.fund_type <> 'QUOTA' THEN
           ozf_mc_transactions_pvt.insert_mc_transactions(
              p_api_version => l_api_version
             ,p_init_msg_list => fnd_api.g_false
             ,p_commit => fnd_api.g_false
             ,x_return_status => l_return_status
             ,x_msg_count => x_msg_count
             ,x_msg_data => x_msg_data
             ,p_mc_transactions_rec => l_mc_transaction_rec
             ,x_mc_transaction_id => l_mc_transaction_id);

           IF l_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
           ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
           END IF;
   END IF;
   */

   /************************   MPANDE JAN-15 2001 ************************************************
      For 11.5.5 release fund status will not be 'active' but will be always 'Draft' in the create
      mode except during allocation .During fund allocation we donot need a approval for a child
   **********************************************************************************************/
   -- 07/10/2001 mpande bug#1875760
   IF p_fund_rec.status_code = 'ACTIVE' THEN
         IF p_fund_rec.parent_fund_id IS NOT NULL AND
            p_fund_rec.fund_type <> 'FULLY_ACCRUED'  THEN

               -- changing status from 'DRAFT or 'REJECTED' to 'ACTIVE or ON_HOLD  is
               -- equivalent to submitting for approval.
               -- Approval submission   child fund
               IF G_DEBUG THEN
                  ozf_utility_pvt.debug_message(l_full_name || 'owner' || p_fund_rec.owner);
               END IF;

               ozf_fund_request_apr_pvt.create_fund_request(
                  p_commit => fnd_api.g_false
                 ,p_approval_for_id => l_fund_rec.fund_id
                 ,p_requester_id => l_fund_rec.owner
                 ,p_requested_amount => l_fund_rec.transfered_in_amt ---l_fund_rec.original_budget mpande 11/06/2001
                 ,p_approval_fm => 'FUND'
                 ,p_approval_fm_id => l_fund_rec.parent_fund_id
                 ,p_transfer_type => 'TRANSFER'
                 ,p_child_flag =>'Y'
                 ,p_justification => l_fund_rec.description
                  -- 10/22/2001   mpande    Changed code different owner allocation bug
                 ,p_allocation_flag => 'Y' -- set this flag to yes to by pass workflow approval
                 ,x_return_status => l_return_status
                 ,x_msg_count => x_msg_count
                 ,x_msg_data => x_msg_data
                 ,x_request_id => l_request_id
                 ,x_approver_id => l_approver_id
                 ,x_is_requester_owner => l_is_requestor_owner);

               IF l_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
               ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;

         -- mpande end if end
         END IF;

    END IF ;
   --added by mpande
   -- insert a access for the owner
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name || ': insert access owner');
   END IF;

   IF l_fund_rec.fund_id IS NOT NULL THEN

      l_access_rec.act_access_to_object_id := l_fund_rec.fund_id;
      l_access_rec.arc_act_access_to_object := 'FUND';
      l_access_rec.user_or_role_id := l_fund_rec.owner;
      l_access_rec.arc_user_or_role_type := 'USER';
      l_access_rec.admin_flag := 'Y';
      l_access_rec.owner_flag := 'Y';
      ams_access_pvt.create_access(
         p_api_version => l_api_version
        ,p_init_msg_list => fnd_api.g_false
        ,p_validation_level => p_validation_level
        ,x_return_status => l_return_status
        ,x_msg_count => x_msg_count
        ,x_msg_data => x_msg_data
        ,p_commit => fnd_api.g_false
        ,p_access_rec => l_access_rec
        ,x_access_id => l_access_id);

      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END IF;

   --added by mpande
   -- if parent id is not null during creation , a row is created in the ams_act_access to give access
   -- to the owner of the parent fund to this child
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name || ': insert access parent');
   END IF;

   IF l_fund_rec.parent_fund_id IS NOT NULL THEN
   -- added updating rollup columns by feliu.
      IF l_fund_rec.status_code = 'ACTIVE' THEN
         update_rollup_amount(
                         p_api_version  => l_api_version
                        ,p_init_msg_list  => fnd_api.g_false
                        ,p_commit     => fnd_api.g_false
                        ,p_validation_level   => p_validation_level
                        ,x_return_status      => l_return_status
                        ,x_msg_count  => x_msg_count
                        ,x_msg_data   => x_msg_data
                        ,p_fund_rec => l_fund_rec
                        );
/* move this part to update_rollup_amount by feliu.

      OPEN c_par_fund_owner(l_fund_rec.parent_fund_id);
      FETCH c_par_fund_owner INTO l_par_fund_owner;
      CLOSE c_par_fund_owner;
      --if the owner of the parent and child fund is different then only add access
      IF l_fund_rec.owner <> l_par_fund_owner THEN
         l_access_rec.act_access_to_object_id := l_fund_rec.fund_id;
         l_access_rec.arc_act_access_to_object := 'FUND';
         l_access_rec.user_or_role_id := l_par_fund_owner;
         l_access_rec.arc_user_or_role_type := 'USER';
         l_access_rec.admin_flag := 'Y';    -- 12/03/2001 yzhao: give admin access to parent
         l_access_rec.owner_flag := 'N';
         ams_access_pvt.create_access(
            p_api_version => l_api_version
           ,p_init_msg_list => fnd_api.g_false
           ,p_validation_level => p_validation_level
           ,x_return_status => l_return_status
           ,x_msg_count => x_msg_count
           ,x_msg_data => x_msg_data
           ,p_commit => fnd_api.g_false
           ,p_access_rec => l_access_rec
           ,x_access_id => l_access_id);
      END IF;
*/
      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

     END IF;
  -- added by feliu to fix bug 2654263

      update_funds_access(
                         p_api_version  => l_api_version
                        ,p_init_msg_list  => fnd_api.g_false
                                    ,p_commit     => fnd_api.g_false
                                    ,p_validation_level   => p_validation_level
                                    ,x_return_status      => l_return_status
                                    ,x_msg_count  => x_msg_count
                                    ,x_msg_data   => x_msg_data
                        ,p_fund_rec => l_fund_rec
                        ,p_mode => 'CREATE'
                       );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   END IF;
     -- mpadne 10/14/2002 for 11.5.9
     IF G_DEBUG THEN
        OZF_UTILITY_PVT.DEBUG_MESSAGE('ACCRUAL BASIS ='||L_FUND_REC.accrual_basis);
     END IF;
   IF p_fund_rec.fund_type = 'FULLY_ACCRUED'  AND p_fund_rec.plan_id is null THEN
              ozf_fundrules_pvt.process_accrual    (
                          p_fund_rec => l_fund_rec
                         ,p_api_version  => l_api_version
                         ,p_mode   => 'CREATE'
                         ,x_return_status      => l_return_status
                         ,x_msg_count  => x_msg_count
                         ,x_msg_data   => x_msg_data );
       IF l_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;
   END IF;
   -- Check for commit
   IF fnd_api.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

 -- raise business event.
 --nepanda : fix for bug # 9616725
  raise_business_event(p_object_id => l_fund_rec.fund_id ,p_event_type =>'CREATE');

   fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false
     ,p_count => x_msg_count
     ,p_data => x_msg_data);
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name || ': end');
   END IF;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_fund;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_fund;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
   WHEN OTHERS THEN
      ROLLBACK TO create_fund;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
END create_fund;



---------------------------------------------------------------
-- PROCEDURE
--    Delete_Fund
--
-- HISTORY
--    02/02/2000  Shitij Vatsa  Create.
---------------------------------------------------------------
PROCEDURE delete_fund(
   p_api_version      IN       NUMBER
  ,p_init_msg_list    IN       VARCHAR2 := fnd_api.g_false
  ,p_commit           IN       VARCHAR2 := fnd_api.g_false
  ,x_return_status    OUT NOCOPY      VARCHAR2
  ,x_msg_count        OUT NOCOPY      NUMBER
  ,x_msg_data         OUT NOCOPY      VARCHAR2
  ,p_fund_id          IN       NUMBER
  ,p_object_version   IN       NUMBER)
IS
   l_api_version    CONSTANT NUMBER       := 1.0;
   l_api_name       CONSTANT VARCHAR2(30) := 'Delete_Fund';
   l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT delete_fund;
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name || ': start');
   END IF;

   IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_return_status := fnd_api.g_ret_sts_success;
   ------------------------ delete ------------------------
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name || ': delete');
   END IF;

   DELETE
     FROM ozf_funds_all_b
    WHERE fund_id = p_fund_id
      AND object_version_number = p_object_version;

   IF (SQL%NOTFOUND) THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         fnd_msg_pub.add;
      END IF;

      RAISE fnd_api.g_exc_error;
   END IF;

   DELETE
     FROM ozf_funds_all_tl
    WHERE fund_id = p_fund_id;

   IF (SQL%NOTFOUND) THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         fnd_msg_pub.add;
      END IF;

      RAISE fnd_api.g_exc_error;
   END IF;

   -------------------- finish --------------------------
   IF fnd_api.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false
     ,p_count => x_msg_count
     ,p_data => x_msg_data);
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name || ': end');
   END IF;
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO delete_fund;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO delete_fund;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
   WHEN OTHERS THEN
      ROLLBACK TO delete_fund;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
END delete_fund;



-------------------------------------------------------------------
-- PROCEDURE
--    Lock_Fund
--
-- HISTORY
--    02/02/2000  Shitij Vatsa  Create.
--------------------------------------------------------------------
PROCEDURE lock_fund(
   p_api_version      IN       NUMBER
  ,p_init_msg_list    IN       VARCHAR2 := fnd_api.g_false
  ,x_return_status    OUT NOCOPY      VARCHAR2
  ,x_msg_count        OUT NOCOPY      NUMBER
  ,x_msg_data         OUT NOCOPY      VARCHAR2
  ,p_fund_id          IN       NUMBER
  ,p_object_version   IN       NUMBER)
IS
   l_api_version    CONSTANT NUMBER       := 1.0;
   l_api_name       CONSTANT VARCHAR2(30) := 'Lock_Fund';
   l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
   l_fund_id                 NUMBER;

   CURSOR c_fund_b
   IS
      SELECT   fund_id
      FROM     ozf_funds_all_b
      WHERE  fund_id = p_fund_id
         AND object_version_number = p_object_version
         FOR UPDATE OF fund_id NOWAIT;

   CURSOR c_fund_tl
   IS
      SELECT   fund_id
      FROM     ozf_funds_all_tl
      WHERE  fund_id = p_fund_id
         AND USERENV('LANG') IN(language, source_lang)
         FOR UPDATE OF fund_id NOWAIT;
BEGIN
   -------------------- initialize ------------------------
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name || ': start');
   END IF;

   IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_return_status := fnd_api.g_ret_sts_success;
   ------------------------ lock -------------------------
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name || ': lock');
   END IF;
   OPEN c_fund_b;
   FETCH c_fund_b INTO l_fund_id;

   IF (c_fund_b%NOTFOUND) THEN
      CLOSE c_fund_b;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         fnd_msg_pub.add;
      END IF;

      RAISE fnd_api.g_exc_error;
   END IF;

   CLOSE c_fund_b;
   OPEN c_fund_tl;
   CLOSE c_fund_tl;
   -------------------- finish --------------------------
   fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false
     ,p_count => x_msg_count
     ,p_data => x_msg_data);
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name || ': end');
   END IF;
EXCEPTION
   WHEN ozf_utility_pvt.resource_locked THEN
      x_return_status := fnd_api.g_ret_sts_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_API_RESOURCE_LOCKED');
         fnd_msg_pub.add;
      END IF;

      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
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
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
END lock_fund;

---------------------------------------------------------------------
-- PROCEDURE
--    Update_Fund
--
-- HISTORY
--    02/02/2000  Shitij Vatsa  Create.
--    06/13/2000  mpande Added access calls
--    06/13/2000  mpande fixed bug complete rec
--    06/13/2000  Added access calls and other validations
--    07/24/2000  Added Multiple Currency Enabling Calls
--    07/28/2000  Added parent_validation against child
--    02/08/2002  Added rollup amount update.
/*************major changes for 11.5.5*********************************
--  All functionality related to statistical fund removed.
-- 2) Added the five columns ,  start_period_name,  end_period_name,  accrual_quantity,
--       accrue_to_level_id,fund_calendar
--      3) Introduced new API check_fund-inter_entity
-- 4) Removed some of the fund rules validations to package OzfFundRulesPvt (because this Api was getging bigger)
-- 5) Removed all active fund transactions to package OzfFundRulesPvt
-- 6) Added approval and other fully accrued fund related transactions
--
**********************************************************************/



----------------------------------------------------------------------
PROCEDURE update_fund(
   p_api_version        IN       NUMBER
  ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
  ,p_commit             IN       VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
  ,x_return_status      OUT NOCOPY      VARCHAR2
  ,x_msg_count          OUT NOCOPY      NUMBER
  ,x_msg_data           OUT NOCOPY      VARCHAR2
  ,p_fund_rec           IN       fund_rec_type
  ,p_mode               IN       VARCHAR2 := jtf_plsql_api.g_update)
IS
   l_api_version    CONSTANT NUMBER                                           := 1.0;
   l_api_name       CONSTANT VARCHAR2(30)
            := 'Update_Fund';
   l_full_name      CONSTANT VARCHAR2(60)
            := g_pkg_name || '.' || l_api_name;
   l_fund_rec                fund_rec_type;
   l_return_status           VARCHAR2(1) := FND_API.g_ret_sts_success;
   l_mode                    VARCHAR2(30);
   l_request_id              NUMBER;
   /* R12: yzhao bug 4669269 - obsolete ozf_mc_transactions
   l_mc_obj_number           NUMBER;
   l_mc_record_id            NUMBER;
   l_mc_transaction_rec      ozf_mc_transactions_pvt.mc_transactions_rec_type;
    */
   --- variable for creating access //mpande
   l_access_rec              ams_access_pvt.access_rec_type;
   l_access_id               NUMBER;
   l_act_access_id           NUMBER;
   l_acc_obj_ver_num         NUMBER;
   l_par_fund_owner          NUMBER;
   --  l_request_rec             ozf_fund_request_pvt.request_rec_type;
   l_status_code             VARCHAR2(30);
   --  08/14/2001 mpande added
   l_submit_budget_approval  VARCHAR2(1):= FND_API.g_false;
   l_submit_child_approval   VARCHAR2(1):= FND_API.g_false;
   l_approver_id             NUMBER;
   l_workflow_process        VARCHAR2(30) := 'AMSGAPP';
   l_item_type               VARCHAR2(30) := 'AMSGAPP';
   l_old_user_status_id      NUMBER;
   l_status_type             VARCHAR2(30) := 'OZF_FUND_STATUS';
   l_is_requestor_owner      VARCHAR2(1);
   l_reject_status_id        NUMBER;
   l_child_request_amt           NUMBER ; -- mpande 11/06/2001 added

   -- CURSOR for old status code //updated by mpande
   CURSOR c_old_status(
      cv_fund_id   IN   NUMBER)
   IS
      SELECT   status_code
              ,parent_fund_id
              ,user_status_id
      FROM     ozf_funds_all_b
      WHERE  fund_id = cv_fund_id;

   l_old_status              VARCHAR2(30);
   l_old_parent_fund_id      NUMBER;
   l_old_par_fund_owner      NUMBER;

   --added by mpande cursor to get parent fund owner
   CURSOR c_par_fund_owner(
      par_fund_id   IN   NUMBER)
   IS
      SELECT   owner
      FROM     ozf_funds_all_b
      WHERE  fund_id = par_fund_id;

   /* R12: yzhao bug 4669269 - obsolete ozf_mc_transactions
   CURSOR c_mc_record(
      source_id   IN   NUMBER)
   IS
      SELECT   mc_record_id
              ,object_version_number
      FROM     ozf_mc_transactions_all
      WHERE  source_object_id = source_id
         AND source_object_name = 'FUND';
    */

   CURSOR c_access(
      p_fund_id   IN   NUMBER)
   IS
      SELECT   activity_access_id
              ,object_version_number
      FROM     ams_act_access
      WHERE  act_access_to_object_id = p_fund_id
         AND arc_act_access_to_object = 'FUND'
         AND owner_flag = 'Y';

   CURSOR c_par_access(
      p_fund_id        IN   NUMBER
     ,p_par_owner_id   IN   NUMBER)
   IS
      SELECT   activity_access_id
              ,object_version_number
      FROM     ams_act_access
      WHERE  act_access_to_object_id = p_fund_id
         AND arc_act_access_to_object = 'FUND'
         AND arc_user_or_role_type = 'USER'
         AND user_or_role_id = p_par_owner_id
         -- 09/05/2001 mpande
         AND NVL(owner_flag,'N') = 'N' ;

   --- cursor to get old (TC) currency_code
   CURSOR c_old_curr(
      cv_fund_id   IN   NUMBER)
   IS
      SELECT   currency_code_tc , owner
      FROM     ozf_funds_all_b
      WHERE  fund_id = cv_fund_id;

   l_old_curr                VARCHAR2(30);
   l_rate                    NUMBER;
   l_owner                   NUMBER;

 -- added by feliu for rollup amount updating.
   CURSOR c_amt IS
     SELECT planned_amt,committed_amt,
     earned_amt,paid_amt,transfered_in_amt
     ,transfered_out_amt,original_budget
     ,recal_committed,holdback_amt
     ,utilized_amt   -- yzhao: 11.5.10
     FROM ozf_funds_all_b
     WHERE fund_id = p_fund_rec.fund_id;

   CURSOR c_rollup_amt IS
     SELECT rollup_planned_amt,rollup_committed_amt
     ,rollup_earned_amt,rollup_paid_amt,rollup_transfered_in_amt
     ,rollup_transfered_out_amt,rollup_original_budget
     ,rollup_recal_committed,rollup_holdback_amt
     ,rollup_utilized_amt   -- yzhao: 11.5.10
     FROM ozf_funds_all_b
     WHERE fund_id = p_fund_rec.fund_id;

   /* kdass - R12 MOAC changes
   CURSOR c_get_org_id IS
     SELECT org_id
     FROM   ozf_funds_all_b
     WHERE  fund_id = p_fund_rec.fund_id;
   */

    l_original_budget        NUMBER;
    l_old_original_budget    NUMBER;
    l_old_transfered_in_amt  NUMBER;
    l_old_transfered_out_amt NUMBER;
    l_old_holdback_amt       NUMBER;
    l_old_planned_amt        NUMBER;
    l_old_committed_amt      NUMBER;
    l_old_utilized_amt       NUMBER;    -- yzhao: 11.5.10
    l_old_earned_amt         NUMBER;
    l_old_paid_amt           NUMBER;
    l_old_recal_committed    NUMBER;


    l_or_original_budget    NUMBER;
    l_or_transfered_in_amt  NUMBER;
    l_or_transfered_out_amt NUMBER;
    l_or_holdback_amt       NUMBER;
    l_or_planned_amt        NUMBER;
    l_or_committed_amt      NUMBER;
    l_or_utilized_amt       NUMBER;     -- yzhao: 11.5.10
    l_or_earned_amt         NUMBER;
    l_or_paid_amt           NUMBER;
    l_or_recal_committed    NUMBER;

    l_rollup_original_budget    NUMBER;
    l_rollup_transfered_in_amt  NUMBER;
    l_rollup_transfered_out_amt NUMBER;
    l_rollup_holdback_amt       NUMBER;
    l_rollup_planned_amt        NUMBER;
    l_rollup_committed_amt      NUMBER;
    l_rollup_utilized_amt       NUMBER;   -- yzhao: 11.5.10
    l_rollup_earned_amt         NUMBER;
    l_rollup_paid_amt           NUMBER;
    l_rollup_recal_committed    NUMBER;
    l_active_flag               BOOLEAN := false;
    l_allocation_flag           VARCHAR2(2) := 'N';  -- yzhao: 03/18/2003 added

    l_tmp_status_code           VARCHAR2(30);
    l_tmp_status_id             NUMBER;

    --Added for bug 7425189
    l_fund_reconc_msg VARCHAR2(4000);
    l_act_bud_cst_msg VARCHAR2(4000);

BEGIN
   -------------------- initialize -------------------------
   SAVEPOINT update_fund;
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name || ': start');
   END IF;

   IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_return_status := fnd_api.g_ret_sts_success;

   --      //added on Sep20 for user status validation
    complete_fund_rec(p_fund_rec, l_fund_rec);
   -- check fund status and fill in system status
   IF p_fund_rec.user_status_id <> fnd_api.g_miss_num THEN
      handle_fund_status(
         p_user_status_id => p_fund_rec.user_status_id
        ,x_status_code => l_status_code
        ,x_return_status => x_return_status);

      IF x_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_fund_rec.status_code := l_status_code;
   ELSIF p_fund_rec.status_code <> fnd_api.g_miss_char THEN
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_full_name || 'debug' || p_fund_rec.status_code);
      END IF;
      get_user_status(
         p_status_code => p_fund_rec.status_code
        ,x_user_status_id => l_fund_rec.user_status_id
        ,x_return_status => x_return_status);

      IF x_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   --- this we need because there could be some records in the database with no user status
   ELSE
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_full_name || 'in else ');
      END IF;

      IF l_fund_rec.user_status_id IS NOT NULL THEN
         handle_fund_status(
            p_user_status_id => l_fund_rec.user_status_id
           ,x_status_code => l_status_code
           ,x_return_status => x_return_status);

         IF x_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      ELSE
         -- if user_status_id is null in database then we will populate it with the corrsponnding system status value form user_status_table
         get_user_status(
            p_status_code => l_fund_rec.status_code
           ,x_user_status_id => l_fund_rec.user_status_id
           ,x_return_status => x_return_status);

         IF x_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      l_fund_rec.status_code := l_status_code;
   END IF;

     --Added for bug 7425189
     l_fund_reconc_msg := fnd_message.get_string ('OZF', 'OZF_FUND_RECONCILE');
     l_act_bud_cst_msg := fnd_message.get_string ('OZF', 'OZF_ACT_BUDG_CST_UTIL');

   --changed by mpande
   -- Fetch the old status code and old parentID
   OPEN c_old_status(p_fund_rec.fund_id);
   FETCH c_old_status INTO l_old_status, l_old_parent_fund_id,l_old_user_status_id;
   CLOSE c_old_status;
   ----------------------- validate ----------------------
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name || ': validate');
   END IF;
   -- replace g_miss_char/num/date with current column values
   --added by mpande 27th JULY-2000
   ---if the fund is active and the currency_code_tc passed is different than the fund_currency_code
   -- then this is either a transfer of fund or utlization record or updation of planned amount .
   -- The amount could only be updated in fund currency
   -- All the amounts passed should be converted to the fund_currency and then updated

   OPEN c_old_curr(p_fund_rec.fund_id);
   FETCH c_old_curr INTO l_old_curr,l_owner;
   CLOSE c_old_curr;
   ----dbms_output.put_line ('OLD CURR = '||l_old_curr);
   ----dbms_output.put_line ('PASSED CURR = '||p_fund_rec.currency_code_tc);
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name || ': convert currrency');
   END IF;
-- changed the status call here to check for the changed status
   IF     l_fund_rec.status_code <> 'DRAFT' AND l_old_status <> 'DRAFT'
      AND l_old_curr <> l_fund_rec.currency_code_tc THEN
      IF     p_fund_rec.original_budget IS NOT NULL
         AND p_fund_rec.original_budget <> fnd_api.g_miss_num THEN


         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message (l_full_name
                        || ' p_fund_rec.exchange_rate_date1: ' || p_fund_rec.exchange_rate_date);
         END IF;

         ozf_utility_pvt.convert_currency(
              x_return_status => l_return_status
             ,p_from_currency => p_fund_rec.currency_code_tc
             ,p_to_currency   => l_old_curr
             ,p_conv_date     => p_fund_rec.exchange_rate_date --bug 7425189, 8532055
             ,p_from_amount   => p_fund_rec.original_budget
             ,x_to_amount     => l_fund_rec.original_budget
             ,x_rate          => l_rate);
         /*
         --nirprasa, added for bug 7425189
         IF p_fund_rec.description IN (l_fund_reconc_msg,l_act_bud_cst_msg)
         AND p_fund_rec.exchange_rate_date IS NOT NULL THEN
           Ozf_utility_pvt.convert_currency(
              x_return_status => l_return_status
             ,p_from_currency => p_fund_rec.currency_code_tc
             ,p_to_currency => l_old_curr
             ,p_conv_date => p_fund_rec.exchange_rate_date
             ,p_from_amount => p_fund_rec.original_budget
             ,x_to_amount => l_fund_rec.original_budget
             ,x_rate => l_rate);
         ELSE
         Ozf_utility_pvt.convert_currency(
            x_return_status => l_return_status
           ,p_from_currency => p_fund_rec.currency_code_tc
           ,p_to_currency => l_old_curr
           ,p_from_amount => p_fund_rec.original_budget
           ,x_to_amount => l_fund_rec.original_budget
           ,x_rate => l_rate);
         END IF;
         */

         -- we need to pass the fund currency after calculating
         l_fund_rec.currency_code_tc := l_old_curr;

         ----dbms_output.put_line ('DEBUG ');
         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      IF     p_fund_rec.transfered_in_amt IS NOT NULL
         AND p_fund_rec.transfered_in_amt <> fnd_api.g_miss_num THEN


         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message (l_full_name
                        || ' p_fund_rec.exchange_rate_date2: ' || p_fund_rec.exchange_rate_date);
         END IF;

         ozf_utility_pvt.convert_currency(
            x_return_status => l_return_status
           ,p_from_currency => p_fund_rec.currency_code_tc
           ,p_to_currency   => l_old_curr
           ,p_conv_date     => p_fund_rec.exchange_rate_date --bug 7425189, 8532055
           ,p_from_amount   => p_fund_rec.transfered_in_amt
           ,x_to_amount     => l_fund_rec.transfered_in_amt
           ,x_rate          => l_rate);

         /*
         --nirprasa, added for bug 7425189
         IF p_fund_rec.description IN (l_fund_reconc_msg,l_act_bud_cst_msg)
           AND p_fund_rec.exchange_rate_date IS NOT NULL THEN
           Ozf_utility_pvt.convert_currency(
            x_return_status => l_return_status
           ,p_from_currency => p_fund_rec.currency_code_tc
           ,p_to_currency => l_old_curr
           ,p_conv_date => p_fund_rec.exchange_rate_date
           ,p_from_amount => p_fund_rec.transfered_in_amt
           ,x_to_amount => l_fund_rec.transfered_in_amt
           ,x_rate => l_rate);
         ELSE
         Ozf_utility_pvt.convert_currency(
            x_return_status => l_return_status
           ,p_from_currency => p_fund_rec.currency_code_tc
           ,p_to_currency => l_old_curr
           ,p_from_amount => p_fund_rec.transfered_in_amt
           ,x_to_amount => l_fund_rec.transfered_in_amt
           ,x_rate => l_rate);
        END IF;
        */

         -- we need to pass the fund currency after calculating
         l_fund_rec.currency_code_tc := l_old_curr;

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      IF     p_fund_rec.transfered_out_amt IS NOT NULL
         AND p_fund_rec.transfered_out_amt <> fnd_api.g_miss_num THEN

         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message (l_full_name
                        || ' p_fund_rec.exchange_rate_date3: ' || p_fund_rec.exchange_rate_date);
         END IF;

         ozf_utility_pvt.convert_currency(
            x_return_status => l_return_status
           ,p_from_currency => p_fund_rec.currency_code_tc
           ,p_to_currency   => l_old_curr
           ,p_conv_date     => p_fund_rec.exchange_rate_date --bug 7425189, 8532055
           ,p_from_amount   => p_fund_rec.transfered_in_amt
           ,x_to_amount     => l_fund_rec.transfered_in_amt
           ,x_rate          => l_rate);
         /*
         --nirprasa, added for bug 7425189
         IF p_fund_rec.description IN (l_fund_reconc_msg,l_act_bud_cst_msg)
         AND p_fund_rec.exchange_rate_date IS NOT NULL THEN
         Ozf_utility_pvt.convert_currency(
            x_return_status => l_return_status
           ,p_from_currency => p_fund_rec.currency_code_tc
           ,p_to_currency => l_old_curr
           ,p_conv_date => p_fund_rec.exchange_rate_date
           ,p_from_amount => p_fund_rec.transfered_in_amt
           ,x_to_amount => l_fund_rec.transfered_in_amt
           ,x_rate => l_rate);
         ELSE
          Ozf_utility_pvt.convert_currency(
            x_return_status => l_return_status
           ,p_from_currency => p_fund_rec.currency_code_tc
           ,p_to_currency => l_old_curr
           ,p_from_amount => p_fund_rec.transfered_in_amt
           ,x_to_amount => l_fund_rec.transfered_in_amt
           ,x_rate => l_rate);
         END IF;
         */

         -- we need to pass the fund currency after calculating
         l_fund_rec.currency_code_tc := l_old_curr;

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      IF     p_fund_rec.planned_amt IS NOT NULL
         AND p_fund_rec.planned_amt <> fnd_api.g_miss_num THEN

         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message (l_full_name
                        || ' p_fund_rec.exchange_rate_date4: ' || p_fund_rec.exchange_rate_date);
         END IF;

         ozf_utility_pvt.convert_currency(
            x_return_status => l_return_status
           ,p_from_currency => p_fund_rec.currency_code_tc
           ,p_to_currency   => l_old_curr
           ,p_conv_date     => p_fund_rec.exchange_rate_date --bug 7425189, 8532055
           ,p_from_amount   => p_fund_rec.planned_amt
           ,x_to_amount     => l_fund_rec.planned_amt
           ,x_rate          => l_rate);

         /*
         --nirprasa, added for bug 7425189
         IF p_fund_rec.description IN (l_fund_reconc_msg,l_act_bud_cst_msg)
           AND p_fund_rec.exchange_rate_date IS NOT NULL THEN
            Ozf_utility_pvt.convert_currency(
            x_return_status => l_return_status
           ,p_from_currency => p_fund_rec.currency_code_tc
           ,p_to_currency => l_old_curr
           ,p_conv_date => p_fund_rec.exchange_rate_date
           ,p_from_amount => p_fund_rec.planned_amt
           ,x_to_amount => l_fund_rec.planned_amt
           ,x_rate => l_rate);
         ELSE
          Ozf_utility_pvt.convert_currency(
            x_return_status => l_return_status
           ,p_from_currency => p_fund_rec.currency_code_tc
           ,p_to_currency => l_old_curr
           ,p_from_amount => p_fund_rec.planned_amt
           ,x_to_amount => l_fund_rec.planned_amt
           ,x_rate => l_rate);
         END IF;
         */

         -- we need to pass the fund currency after calculating
         l_fund_rec.currency_code_tc := l_old_curr;

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      -- yzhao: 11.5.10
      IF     p_fund_rec.utilized_amt IS NOT NULL
         AND p_fund_rec.utilized_amt <> fnd_api.g_miss_num THEN

         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message (l_full_name
                        || ' p_fund_rec.exchange_rate_date5: ' || p_fund_rec.exchange_rate_date);
         END IF;

         ozf_utility_pvt.convert_currency(
            x_return_status => l_return_status
           ,p_from_currency => p_fund_rec.currency_code_tc
           ,p_to_currency   => l_old_curr
           ,p_conv_date     => p_fund_rec.exchange_rate_date --bug 7425189, 8532055
           ,p_from_amount   => p_fund_rec.utilized_amt
           ,x_to_amount     => l_fund_rec.utilized_amt
           ,x_rate          => l_rate);

         /*
         --nirprasa, added for bug 7425189
         IF p_fund_rec.description IN (l_fund_reconc_msg,l_act_bud_cst_msg)
           AND p_fund_rec.exchange_rate_date IS NOT NULL THEN
         Ozf_utility_pvt.convert_currency(
            x_return_status => l_return_status
           ,p_from_currency => p_fund_rec.currency_code_tc
           ,p_to_currency => l_old_curr
           ,p_conv_date => p_fund_rec.exchange_rate_date
           ,p_from_amount => p_fund_rec.utilized_amt
           ,x_to_amount => l_fund_rec.utilized_amt
           ,x_rate => l_rate);
         ELSE
         Ozf_utility_pvt.convert_currency(
            x_return_status => l_return_status
           ,p_from_currency => p_fund_rec.currency_code_tc
           ,p_to_currency => l_old_curr
           ,p_from_amount => p_fund_rec.utilized_amt
           ,x_to_amount => l_fund_rec.utilized_amt
           ,x_rate => l_rate);
         END IF;
         */
         -- we need to pass the fund currency after calculating
         l_fund_rec.currency_code_tc := l_old_curr;

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      IF     p_fund_rec.earned_amt IS NOT NULL
         AND p_fund_rec.earned_amt <> fnd_api.g_miss_num THEN

         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message (l_full_name
                        || ' p_fund_rec.exchange_rate_date6: ' || p_fund_rec.exchange_rate_date);
         END IF;

         ozf_utility_pvt.convert_currency(
            x_return_status => l_return_status
           ,p_from_currency => p_fund_rec.currency_code_tc
           ,p_to_currency   => l_old_curr
           ,p_conv_date     => p_fund_rec.exchange_rate_date --bug 7425189, 8532055
           ,p_from_amount   => p_fund_rec.earned_amt
           ,x_to_amount     => l_fund_rec.earned_amt
           ,x_rate          => l_rate);

         /*
         --nirprasa, added for bug 7425189
         IF p_fund_rec.description IN (l_fund_reconc_msg,l_act_bud_cst_msg)
           AND p_fund_rec.exchange_rate_date IS NOT NULL THEN
         Ozf_utility_pvt.convert_currency(
            x_return_status => l_return_status
           ,p_from_currency => p_fund_rec.currency_code_tc
           ,p_to_currency => l_old_curr
           ,p_conv_date => p_fund_rec.exchange_rate_date
           ,p_from_amount => p_fund_rec.earned_amt
           ,x_to_amount => l_fund_rec.earned_amt
           ,x_rate => l_rate);
         ELSE
         Ozf_utility_pvt.convert_currency(
            x_return_status => l_return_status
           ,p_from_currency => p_fund_rec.currency_code_tc
           ,p_to_currency => l_old_curr
           ,p_from_amount => p_fund_rec.earned_amt
           ,x_to_amount => l_fund_rec.earned_amt
           ,x_rate => l_rate);
         END IF;
         */
         -- we need to pass the fund currency after calculating
         l_fund_rec.currency_code_tc := l_old_curr;

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      IF     p_fund_rec.committed_amt IS NOT NULL
         AND p_fund_rec.committed_amt <> fnd_api.g_miss_num THEN

         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message (l_full_name
                        || ' p_fund_rec.exchange_rate_date7: ' || p_fund_rec.exchange_rate_date);
         END IF;

         ozf_utility_pvt.convert_currency(
            x_return_status => l_return_status
           ,p_from_currency => p_fund_rec.currency_code_tc
           ,p_to_currency   => l_old_curr
           ,p_conv_date     => p_fund_rec.exchange_rate_date --bug 7425189, 8532055
           ,p_from_amount   => p_fund_rec.committed_amt
           ,x_to_amount     => l_fund_rec.committed_amt
           ,x_rate          => l_rate);

         /*
         --nirprasa, added for bug 7425189
         IF p_fund_rec.description IN (l_fund_reconc_msg,l_act_bud_cst_msg)
           AND p_fund_rec.exchange_rate_date IS NOT NULL THEN
         Ozf_utility_pvt.convert_currency(
            x_return_status => l_return_status
           ,p_from_currency => p_fund_rec.currency_code_tc
           ,p_to_currency => l_old_curr
           ,p_conv_date => p_fund_rec.exchange_rate_date
           ,p_from_amount => p_fund_rec.committed_amt
           ,x_to_amount => l_fund_rec.committed_amt
           ,x_rate => l_rate);
         ELSE
         Ozf_utility_pvt.convert_currency(
            x_return_status => l_return_status
           ,p_from_currency => p_fund_rec.currency_code_tc
           ,p_to_currency => l_old_curr
           ,p_from_amount => p_fund_rec.committed_amt
           ,x_to_amount => l_fund_rec.committed_amt
           ,x_rate => l_rate);
         END IF;
         */
         -- we need to pass the fund currency after calculating
         l_fund_rec.currency_code_tc := l_old_curr;

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      IF     p_fund_rec.paid_amt IS NOT NULL
         AND p_fund_rec.paid_amt <> fnd_api.g_miss_num THEN

         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message (l_full_name
                        || ' p_fund_rec.exchange_rate_date8: ' || p_fund_rec.exchange_rate_date);
         END IF;

         Ozf_utility_pvt.convert_currency(
            x_return_status => l_return_status
           ,p_from_currency => p_fund_rec.currency_code_tc
           ,p_to_currency   => l_old_curr
           ,p_conv_date     => p_fund_rec.exchange_rate_date --bug 7425189, 8532055
           ,p_from_amount   => p_fund_rec.paid_amt
           ,x_to_amount     => l_fund_rec.paid_amt
           ,x_rate          => l_rate);

         /*
         --nirprasa, added for bug 7425189
         IF p_fund_rec.description IN (l_fund_reconc_msg,l_act_bud_cst_msg)
           AND p_fund_rec.exchange_rate_date IS NOT NULL THEN
         Ozf_utility_pvt.convert_currency(
            x_return_status => l_return_status
           ,p_from_currency => p_fund_rec.currency_code_tc
           ,p_to_currency => l_old_curr
           ,p_conv_date => p_fund_rec.exchange_rate_date
           ,p_from_amount => p_fund_rec.paid_amt
           ,x_to_amount => l_fund_rec.paid_amt
           ,x_rate => l_rate);
         ELSE
         Ozf_utility_pvt.convert_currency(
            x_return_status => l_return_status
           ,p_from_currency => p_fund_rec.currency_code_tc
           ,p_to_currency => l_old_curr
           ,p_from_amount => p_fund_rec.paid_amt
           ,x_to_amount => l_fund_rec.paid_amt
           ,x_rate => l_rate);
         END IF;
         */
         -- we need to pass the fund currency after calculating
         l_fund_rec.currency_code_tc := l_old_curr;

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;
   END IF;

   -- default fund_calendar
   IF     l_fund_rec.start_period_name IS NULL
      AND l_fund_rec.end_period_name IS NULL THEN
      l_fund_rec.fund_calendar := NULL;
   ELSE
      l_fund_rec.fund_calendar := fnd_profile.VALUE('AMS_CAMPAIGN_DEFAULT_CALENDER');
   END IF;

   -- generate source code
   IF     p_fund_rec.parent_fund_id IS NOT NULL
      AND p_fund_rec.parent_fund_id <> fnd_api.g_miss_num
      AND p_fund_rec.fund_number IS NULL THEN
      get_child_source_code(
         p_fund_rec.parent_fund_id
        ,l_fund_rec.fund_number
        ,x_return_status);

      IF x_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END IF;

   IF p_validation_level >= jtf_plsql_api.g_valid_level_item THEN
      ----dbms_output.put_line ('Calling Check_Fund_Items');
      check_fund_items(
         /* yzhao: 06/03/2003 fix bug 2984497 - TST1159.14 MASTER: BUDGET APPROVAL VALIDATION FAILS UPON APPROVAL IN WORKFLOW
         p_fund_rec => p_fund_rec
          */
         p_fund_rec => l_fund_rec
        ,p_validation_mode => jtf_plsql_api.g_update
        ,x_return_status => l_return_status);

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      END IF;
   END IF;

   -- record level
   IF p_validation_level >= jtf_plsql_api.g_valid_level_record THEN
      check_fund_record(
         p_fund_rec => p_fund_rec
        ,p_complete_rec => l_fund_rec
        ,p_mode => p_mode
        ,x_return_status => l_return_status);

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      END IF;
   END IF;

   -- inter-entity level
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name || ': check inter-entity');
   END IF;

   IF p_validation_level >= jtf_plsql_api.g_valid_level_inter_entity THEN
      check_fund_inter_entity(
         p_fund_rec => p_fund_rec
        ,p_complete_rec => l_fund_rec
        ,p_validation_mode => jtf_plsql_api.g_update
        ,x_return_status => l_return_status);

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      END IF;
   END IF;

   -------------------------- update --------------------
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name || ': update');

      ozf_utility_pvt.debug_message(l_full_name || ': get_category');
   END IF;

   -- kdass 09-NOV-05 Bug 4618523
   /*
   --added by mpande 6th JULY-2000
   --get default category GL Info not for statistical funds
   IF     p_fund_rec.category_id <> fnd_api.g_miss_num
      AND l_fund_rec.category_id IS NOT NULL THEN
      complete_default_gl_info(
         l_fund_rec.category_id
        ,l_fund_rec.accrued_liable_account
        ,l_fund_rec.ded_adjustment_account
        ,l_return_status);

      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END IF;
   */

   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name || 'before update status' ||l_fund_rec.original_budget);
   END IF;
   -- perform all status related  updation and if it is successful then only update the fund record
   -- Update fund could be called by other APIS in active status to update earned amt or committed amt .
   -- We do allow them to update the record then
   IF l_return_status = fnd_api.g_ret_sts_success THEN
      IF p_mode IN  (jtf_PLSQL_API.G_UPDATE, 'WORKFLOW') THEN
         Ozf_fundrules_pvt.update_fund_status(
          p_fund_rec => l_fund_rec
         /* yzhao: 11/26/2002 how weird to pass IN parameter l_fund_rec, and use member as OUT parameter
                              most importantly, it breaks with NOCOPY hint
         ,x_new_status_code => l_fund_rec.status_code
         ,x_new_status_id => l_fund_rec.user_status_id
          */
         ,x_new_status_code => l_tmp_status_code
         ,x_new_status_id => l_tmp_status_id
         ,x_submit_budget_approval => l_submit_budget_approval
         ,x_submit_child_approval =>l_submit_child_approval
         ,x_return_status => l_return_status
         ,x_msg_count => x_msg_count
         ,x_msg_data => x_msg_data
         ,p_api_version => 1.0);

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
             RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         l_fund_rec.status_code := l_tmp_status_code;
         l_fund_rec.user_status_id := l_tmp_status_id;

         -- sangara added for R12
         IF l_tmp_status_code = 'ACTIVE' THEN
            l_fund_rec.activation_date := sysdate;
         END IF;

      END IF;
   END IF;

   -- 11/02/2001 mpande added for child fund we donot want to update original_budget but transfered_in_amt
   -- when no approval required , other the approval API will do the needful
   -- 11/06/2001 mpande added
   l_child_request_amt := l_fund_rec.original_budget;
   -- when setting the status directly to active
   IF l_fund_rec.parent_fund_id IS NOT NULL THEN
      IF l_fund_rec.status_code = 'ON_HOLD' OR  l_fund_rec.status_code = 'ACTIVE' THEN
      --OR  l_fund_rec.status_code = 'PENDING'
         IF l_old_status = 'DRAFT' THEN
            l_fund_rec.transfered_in_amt := l_fund_rec.original_budget;
            l_fund_rec.original_budget := 0 ;
         END IF ;

         IF l_old_status = 'PENDING' OR l_old_status = 'DRAFT' THEN
            l_active_flag := true;
         END IF ;

       END IF;
   END IF;

   OPEN c_amt;
   FETCH c_amt INTO
    l_old_planned_amt,
    l_old_committed_amt,
    l_old_earned_amt,
    l_old_paid_amt,
    l_old_transfered_in_amt ,
    l_old_transfered_out_amt ,
    l_old_original_budget,
    l_old_recal_committed,
    l_old_holdback_amt,
    l_old_utilized_amt;   -- yzhao: 11.5.10
   CLOSE c_amt;

   OPEN c_rollup_amt;
   FETCH c_rollup_amt INTO
    l_or_planned_amt,
    l_or_committed_amt,
    l_or_earned_amt,
    l_or_paid_amt,
    l_or_transfered_in_amt ,
    l_or_transfered_out_amt ,
    l_or_original_budget,
    l_or_recal_committed,
    l_or_holdback_amt,
    l_or_utilized_amt;
   CLOSE c_rollup_amt;

   IF l_fund_rec.original_budget IS NOT NULL
     THEN

         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message (l_full_name
                        || ' p_fund_rec.exchange_rate_date9: ' || p_fund_rec.exchange_rate_date);
         END IF;

         ozf_utility_pvt.convert_currency(
            x_return_status => l_return_status
           ,p_from_currency => l_fund_rec.currency_code_tc
           ,p_to_currency   => g_universal_currency
           ,p_conv_date     => p_fund_rec.exchange_rate_date --bug 7425189, 8532055
           ,p_from_amount   => l_fund_rec.original_budget
           ,x_to_amount     => l_original_budget
           ,x_rate          => l_rate);

         /*
         --nirprasa, added for bug 7425189
         IF p_fund_rec.description IN (l_fund_reconc_msg,l_act_bud_cst_msg)
         AND p_fund_rec.exchange_rate_date IS NOT NULL THEN
         Ozf_utility_pvt.convert_currency(
            x_return_status => l_return_status
           ,p_from_currency => l_fund_rec.currency_code_tc
           ,p_to_currency => g_universal_currency
           ,p_conv_date => p_fund_rec.exchange_rate_date
           ,p_from_amount => l_fund_rec.original_budget
           ,x_to_amount => l_original_budget
           ,x_rate => l_rate);
         ELSE
         Ozf_utility_pvt.convert_currency(
            x_return_status => l_return_status
           ,p_from_currency => l_fund_rec.currency_code_tc
           ,p_to_currency => g_universal_currency
           ,p_from_amount => l_fund_rec.original_budget
           ,x_to_amount => l_original_budget
           ,x_rate => l_rate);
         END IF;
         */


     --l_rollup_original_budget :=  l_original_budget - NVL(l_or_original_budget,0);
     --l_fund_rec.rollup_original_budget := l_original_budget;

     l_fund_rec.rollup_original_budget := ozf_utility_pvt.CurrRound((l_fund_rec.original_budget - NVL(l_old_original_budget,0)) * l_rate
                                                                       ,g_universal_currency) + NVL(l_or_original_budget,0);
     l_rollup_original_budget := l_fund_rec.rollup_original_budget - NVL(l_or_original_budget,0);


      IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

   END IF;

   IF l_fund_rec.transfered_in_amt IS NOT NULL
     AND l_rate is NOT NULL
     AND l_fund_rec.transfered_in_amt <> NVL(l_old_transfered_in_amt,0) THEN

     l_fund_rec.rollup_transfered_in_amt := ozf_utility_pvt.CurrRound((l_fund_rec.transfered_in_amt - NVL(l_old_transfered_in_amt,0)) * l_rate
                                                                       ,g_universal_currency) + NVL(l_or_transfered_in_amt,0);
     l_rollup_transfered_in_amt := l_fund_rec.rollup_transfered_in_amt - NVL(l_or_transfered_in_amt,0);

   END IF;

   IF l_fund_rec.transfered_out_amt IS NOT NULL
     AND l_rate is NOT NULL
     AND l_fund_rec.transfered_out_amt <> NVL(l_old_transfered_out_amt,0) THEN

     l_fund_rec.rollup_transfered_out_amt := ozf_utility_pvt.CurrRound((l_fund_rec.transfered_out_amt-NVL(l_old_transfered_out_amt,0)) * l_rate
                                                                       ,g_universal_currency) + NVL(l_or_transfered_out_amt,0);
     l_rollup_transfered_out_amt := l_fund_rec.rollup_transfered_out_amt - NVL(l_or_transfered_out_amt,0);

   END IF;


   --IF l_fund_rec.holdback_amt IS NOT NULL
   --Bug Fix 4087106, Rollup holdback amt not updated when manually updated.
     IF l_rate is NOT NULL
     AND NVL(l_fund_rec.holdback_amt,0) <> NVL(l_old_holdback_amt,0) THEN

     l_fund_rec.rollup_holdback_amt := ozf_utility_pvt.CurrRound((NVL(l_fund_rec.holdback_amt,0)-NVL(l_old_holdback_amt,0)) * l_rate
                                                                 ,g_universal_currency)+ NVL(l_or_holdback_amt,0);
     l_rollup_holdback_amt := l_fund_rec.rollup_holdback_amt - NVL(l_or_holdback_amt,0);

   END IF;


   IF l_fund_rec.planned_amt IS NOT NULL
     AND l_rate is NOT NULL
     AND l_fund_rec.planned_amt <> NVL(l_old_planned_amt,0) THEN

     l_fund_rec.rollup_planned_amt := ozf_utility_pvt.CurrRound((l_fund_rec.planned_amt-NVL(l_old_planned_amt,0)) * l_rate
                                                                 ,g_universal_currency)+ NVL(l_or_planned_amt,0);
     l_rollup_planned_amt := l_fund_rec.rollup_planned_amt - NVL(l_or_planned_amt,0);

   END IF;

   IF l_fund_rec.committed_amt IS NOT NULL
     AND l_rate is NOT NULL
     AND l_fund_rec.committed_amt <> NVL(l_old_committed_amt,0) THEN

     l_fund_rec.rollup_committed_amt := ozf_utility_pvt.CurrRound((l_fund_rec.committed_amt-NVL(l_old_committed_amt,0)) * l_rate
                                                                 ,g_universal_currency) + NVL(l_or_committed_amt,0);
     l_rollup_committed_amt :=l_fund_rec.rollup_committed_amt - NVL(l_or_committed_amt,0);

   END IF;

   IF l_fund_rec.utilized_amt IS NOT NULL
     AND l_rate is NOT NULL
     AND l_fund_rec.utilized_amt <> NVL(l_old_utilized_amt,0) THEN

     l_fund_rec.rollup_utilized_amt := ozf_utility_pvt.CurrRound((l_fund_rec.utilized_amt-NVL(l_old_utilized_amt,0)) * l_rate
                                                                 ,g_universal_currency) + NVL(l_or_utilized_amt,0);
     l_rollup_utilized_amt := l_fund_rec.rollup_utilized_amt - NVL(l_or_utilized_amt,0);

   END IF;

   IF l_fund_rec.earned_amt IS NOT NULL
     AND l_rate is NOT NULL
     AND l_fund_rec.earned_amt <> NVL(l_old_earned_amt,0) THEN

     l_fund_rec.rollup_earned_amt := ozf_utility_pvt.CurrRound((l_fund_rec.earned_amt-NVL(l_old_earned_amt,0)) * l_rate
                                                                 ,g_universal_currency) + NVL(l_or_earned_amt,0);
     l_rollup_earned_amt := l_fund_rec.rollup_earned_amt - NVL(l_or_earned_amt,0);

   END IF;


   IF l_fund_rec.paid_amt IS NOT NULL
     AND l_rate is NOT NULL
     AND l_fund_rec.paid_amt <> NVL(l_old_paid_amt,0) THEN

     l_fund_rec.rollup_paid_amt := ozf_utility_pvt.CurrRound((l_fund_rec.paid_amt-NVL(l_old_paid_amt,0)) * l_rate
                                                                 ,g_universal_currency) +NVL(l_or_paid_amt,0);
     l_rollup_paid_amt := l_fund_rec.rollup_paid_amt - NVL(l_or_paid_amt,0);

   END IF;

   IF l_fund_rec.recal_committed IS NOT NULL
     AND l_rate is NOT NULL
     AND l_fund_rec.recal_committed <> NVL(l_old_recal_committed,0) THEN

     l_fund_rec.rollup_recal_committed := ozf_utility_pvt.CurrRound((l_fund_rec.recal_committed-NVL(l_old_recal_committed,0)) * l_rate
                                                                 ,g_universal_currency) +NVL(l_or_recal_committed,0);
     l_rollup_recal_committed :=l_fund_rec.rollup_recal_committed - NVL(l_or_recal_committed,0);

   END IF;

-- added by feliu to fix bug 2654263
   IF l_fund_rec.parent_fund_id IS NOT NULL THEN
      OPEN c_par_fund_owner(l_fund_rec.parent_fund_id);
      FETCH c_par_fund_owner INTO l_par_fund_owner;
      CLOSE c_par_fund_owner;
   END IF;

  -- delete access before update budget because we delete access by loop through tree.
   --if the parent fundowner and the child fund owner is not same.
   IF  l_fund_rec.parent_fund_id IS NOT NULL AND l_fund_rec.owner <> l_par_fund_owner THEN
     --if there is no parent fund OR (09/05/2001 mpande) when no records exists in ams_act_access for the fund
     --then create a access for the new parent ownner
    --if the old parent fund  and the new parent fund  is diffrent then delete the access
       IF  l_old_parent_fund_id <> l_fund_rec.parent_fund_id THEN
          -- remove old access.
          update_funds_access(
                              p_api_version  => l_api_version
                              ,p_init_msg_list  => fnd_api.g_false
                              ,p_commit     => fnd_api.g_false
                              ,p_validation_level   => p_validation_level
                              ,x_return_status      => l_return_status
                              ,x_msg_count  => x_msg_count
                              ,x_msg_data   => x_msg_data
                              ,p_fund_rec => l_fund_rec
                              ,p_mode => 'DELETE'
                              );

          IF l_return_status = fnd_api.g_ret_sts_error THEN
             RAISE fnd_api.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF; -- end of l_old_parent_fund_id <> l_fund_rec.parent_fund_id.
    END IF;  -- end of l_fund_rec.parent_fund_id IS NOT NULL

      -- if removing parent then remove access
    IF l_fund_rec.parent_fund_id IS NULL AND l_old_parent_fund_id IS NOT NULL THEN
       update_funds_access(
                           p_api_version  => l_api_version
                           ,p_init_msg_list  => fnd_api.g_false
                           ,p_commit     => fnd_api.g_false
                           ,p_validation_level   => p_validation_level
                           ,x_return_status      => l_return_status
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data   => x_msg_data
                           ,p_fund_rec => l_fund_rec
                           ,p_mode => 'DELETE'
                           );

       IF l_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;

   END IF; -- l_fund_rec.parent_fund_id
-- added by feliu to fix bug 2654263

  -- feliu 04/08/04 to fix bug 3551038 to update status_date.
  IF l_fund_rec.status_code <> l_old_status THEN
     l_fund_rec.status_date := SYSDATE;
  END IF;


   UPDATE ozf_funds_all_b
      SET last_update_date = SYSDATE
         ,last_updated_by = NVL(fnd_global.user_id, -1)
         ,last_update_login = NVL(fnd_global.conc_login_id, -1)
         ,created_from = NULL
         ,request_id = fnd_global.conc_request_id
         ,program_application_id = fnd_global.prog_appl_id
         ,program_id = fnd_global.conc_program_id
         ,program_update_date = SYSDATE
         ,fund_number = l_fund_rec.fund_number
         ,parent_fund_id = l_fund_rec.parent_fund_id
         ,category_id = l_fund_rec.category_id
         ,fund_type = l_fund_rec.fund_type
         ,fund_usage = l_fund_rec.fund_usage
         ,status_code = l_fund_rec.status_code
         ,user_status_id = l_fund_rec.user_status_id
         ,status_date = NVL(l_fund_rec.status_date, SYSDATE)
         ,accrued_liable_account = l_fund_rec.accrued_liable_account
         ,ded_adjustment_account = l_fund_rec.ded_adjustment_account
         ,liability_flag = l_fund_rec.liability_flag
         ,set_of_books_id = l_fund_rec.set_of_books_id
         ,start_period_id = l_fund_rec.start_period_id
         ,end_period_id = l_fund_rec.end_period_id
         ,start_date_active = l_fund_rec.start_date_active
         ,end_date_active = l_fund_rec.end_date_active
         ,budget_amount_tc = l_fund_rec.budget_amount_tc
         ,budget_amount_fc = l_fund_rec.budget_amount_fc
         ,available_amount = l_fund_rec.available_amount
         ,distributed_amount = l_fund_rec.distributed_amount
         ,currency_code_tc = l_fund_rec.currency_code_tc
         ,currency_code_fc = l_fund_rec.currency_code_fc
         ,exchange_rate_type = l_fund_rec.exchange_rate_type
         ,exchange_rate_date = l_fund_rec.exchange_rate_date
         ,exchange_rate = l_fund_rec.exchange_rate
         ,department_id = l_fund_rec.department_id
         ,costcentre_id = l_fund_rec.costcentre_id
         ,owner = l_fund_rec.owner
         ,accrual_method = l_fund_rec.accrual_method
         ,accrual_operand = l_fund_rec.accrual_operand
         ,accrual_rate = l_fund_rec.accrual_rate
         ,accrual_basis = l_fund_rec.accrual_basis
         ,hierarchy = l_fund_rec.hierarchy
         ,hierarchy_level = l_fund_rec.hierarchy_level
         ,hierarchy_id = l_fund_rec.hierarchy_id
         ,parent_node_id = l_fund_rec.parent_node_id
         ,node_id = l_fund_rec.node_id   --,level_value                   = l_fund_rec.level_value
         ,budget_flag = l_fund_rec.budget_flag
         ,earned_flag = l_fund_rec.earned_flag
         ,apply_accrual_on = l_fund_rec.apply_accrual_on
         ,accrual_phase = l_fund_rec.accrual_phase
         ,accrual_cap = l_fund_rec.accrual_cap
         ,accrual_uom = l_fund_rec.accrual_uom
         ,object_version_number = l_fund_rec.object_version_number + 1
         ,recal_committed = l_fund_rec.recal_committed
         ,attribute_category = l_fund_rec.attribute_category
         ,attribute1 = l_fund_rec.attribute1
         ,attribute2 = l_fund_rec.attribute2
         ,attribute3 = l_fund_rec.attribute3
         ,attribute4 = l_fund_rec.attribute4
         ,attribute5 = l_fund_rec.attribute5
         ,attribute6 = l_fund_rec.attribute6
         ,attribute7 = l_fund_rec.attribute7
         ,attribute8 = l_fund_rec.attribute8
         ,attribute9 = l_fund_rec.attribute9
         ,attribute10 = l_fund_rec.attribute10
         ,attribute11 = l_fund_rec.attribute11
         ,attribute12 = l_fund_rec.attribute12
         ,attribute13 = l_fund_rec.attribute13
         ,attribute14 = l_fund_rec.attribute14
         ,attribute15 = l_fund_rec.attribute15
         ,original_budget = l_fund_rec.original_budget
         ,transfered_in_amt = l_fund_rec.transfered_in_amt
         ,transfered_out_amt = l_fund_rec.transfered_out_amt
         ,holdback_amt = l_fund_rec.holdback_amt
         ,planned_amt = l_fund_rec.planned_amt
         ,committed_amt = l_fund_rec.committed_amt
         ,earned_amt = l_fund_rec.earned_amt
         ,paid_amt = l_fund_rec.paid_amt
         ,plan_type = l_fund_rec.plan_type
         ,plan_id = l_fund_rec.plan_id
         ,liable_accnt_segments = l_fund_rec.liable_accnt_segments
         ,adjustment_accnt_segments = l_fund_rec.adjustment_accnt_segments
         ,fund_calendar = l_fund_rec.fund_calendar
         ,start_period_name = l_fund_rec.start_period_name
         ,end_period_name = l_fund_rec.end_period_name
         ,accrual_quantity = l_fund_rec.accrual_quantity
         ,accrue_to_level_id = l_fund_rec.accrue_to_level_id
         ,accrual_discount_level = l_fund_rec.accrual_discount_level
         ,custom_setup_id       =  l_fund_rec.custom_setup_id
         ,threshold_id       =  l_fund_rec.threshold_id
         ,business_unit_id = l_fund_rec.business_unit_id
         ,country_id    =    l_fund_rec.country_id
         ,task_id     =       l_fund_rec.task_id
         ,rollup_original_budget = l_fund_rec.rollup_original_budget
         ,rollup_transfered_in_amt = l_fund_rec.rollup_transfered_in_amt
         ,rollup_transfered_out_amt = l_fund_rec.rollup_transfered_out_amt
         ,rollup_holdback_amt = l_fund_rec.rollup_holdback_amt
         ,rollup_planned_amt = l_fund_rec.rollup_planned_amt
         ,rollup_committed_amt = l_fund_rec.rollup_committed_amt
         ,rollup_earned_amt = l_fund_rec.rollup_earned_amt
         ,rollup_paid_amt = l_fund_rec.rollup_paid_amt
         ,rollup_recal_committed  = l_fund_rec.rollup_recal_committed
         ,retroactive_flag         =  l_fund_rec.retroactive_flag
         ,qualifier_id              = l_fund_rec.qualifier_id
         -- niprakas added
         ,prev_fund_id       = l_fund_rec.prev_fund_id
         ,transfered_flag    = l_fund_rec.transfered_flag
         ,utilized_amt = l_fund_rec.utilized_amt
         ,rollup_utilized_amt = l_fund_rec.rollup_utilized_amt
         ,product_spread_time_id    = l_fund_rec.product_spread_time_id
         -- sangara added
         ,activation_date = l_fund_rec.activation_date
         -- kdass - R12 MOAC changes
         ,ledger_id = l_fund_rec.ledger_id
    WHERE fund_id = l_fund_rec.fund_id
      AND object_version_number = l_fund_rec.object_version_number;

   IF (SQL%NOTFOUND) THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         fnd_msg_pub.add;
      END IF;

      RAISE fnd_api.g_exc_error;
   END IF;

   UPDATE ozf_funds_all_tl
      SET last_update_date = SYSDATE
         ,last_updated_by = NVL(fnd_global.user_id, -1)
         ,last_update_login = NVL(fnd_global.conc_login_id, -1)
         ,created_from = NULL
         ,request_id = fnd_global.conc_request_id
         ,program_application_id = fnd_global.prog_appl_id
         ,program_id = fnd_global.conc_program_id
         ,program_update_date = SYSDATE
         ,short_name = l_fund_rec.short_name
         ,description = l_fund_rec.description
         ,source_lang = USERENV('LANG')
    WHERE fund_id = l_fund_rec.fund_id
      AND USERENV('LANG') IN(language, source_lang);

   IF (SQL%NOTFOUND) THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         fnd_msg_pub.add;
      END IF;

      RAISE fnd_api.g_exc_error;
   END IF;

   IF l_return_status = fnd_api.g_ret_sts_success THEN

      -- added by feliu for updating rollup amount columns.
      --  if parent_fund_id is not null, update parent's rollup amount by using this fund's
      --  rollup amount change.
      --dbms_output.put_line('parent_fund_id  '||l_fund_rec.parent_fund_id);

      IF l_fund_rec.status_code NOT IN (  'DRAFT' ,'REJECTED','PENDING')
          AND (l_rollup_original_budget IS NOT NULL OR
          l_rollup_transfered_in_amt  IS NOT NULL OR
          l_rollup_transfered_out_amt IS NOT NULL OR
          l_rollup_holdback_amt       IS NOT NULL OR
          l_rollup_planned_amt        IS NOT NULL OR
          l_rollup_committed_amt      IS NOT NULL OR
          l_rollup_utilized_amt       IS NOT NULL OR
          l_rollup_earned_amt         IS NOT NULL OR   -- yzhao: 11.5.10
          l_rollup_paid_amt           IS NOT NULL OR
          l_rollup_recal_committed    IS NOT NULL)
         THEN

          --nirprasa, no chnage needed as parent_fund_id is NULL for reconcile flow
         IF  l_fund_rec.parent_fund_id IS NOT NULL THEN
           --For case from draft to active, update with own value, other case use difference to update rollup
            IF l_active_flag = false THEN
               l_fund_rec.rollup_original_budget := NVL(l_rollup_original_budget,0);
               l_fund_rec.rollup_transfered_in_amt := NVL(l_rollup_transfered_in_amt,0);
               l_fund_rec.rollup_transfered_out_amt := NVL(l_rollup_transfered_out_amt,0);
               l_fund_rec.rollup_holdback_amt       := NVL(l_rollup_holdback_amt,0);
               l_fund_rec.rollup_planned_amt        := NVL(l_rollup_planned_amt,0);
               l_fund_rec.rollup_committed_amt      := NVL(l_rollup_committed_amt,0);
               l_fund_rec.rollup_utilized_amt       := NVL(l_rollup_utilized_amt,0);    -- yzhao: 11.5.10
               l_fund_rec.rollup_earned_amt         := NVL(l_rollup_earned_amt,0);
               l_fund_rec.rollup_paid_amt           := NVL(l_rollup_paid_amt,0);
               l_fund_rec.rollup_recal_committed    := NVL(l_rollup_recal_committed,0);
            END IF;

            update_rollup_amount(
                         p_api_version  => l_api_version
                        ,p_init_msg_list  => fnd_api.g_false
                        ,p_commit     => fnd_api.g_false
                        ,p_validation_level   => p_validation_level
                        ,x_return_status      => l_return_status
                        ,x_msg_count  => x_msg_count
                        ,x_msg_data   => x_msg_data
                        ,p_fund_rec => l_fund_rec
                        );
            IF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;

     -- commented by feliu to fix bug 2654263
     /*      IF l_active_flag = true THEN

            update_funds_access(
                                    p_api_version  => l_api_version
                                    ,p_init_msg_list  => fnd_api.g_false
                                    ,p_commit     => fnd_api.g_false
                                    ,p_validation_level   => p_validation_level
                                    ,x_return_status      => l_return_status
                                    ,x_msg_count  => x_msg_count
                                    ,x_msg_data   => x_msg_data
                                    ,p_fund_rec => l_fund_rec
                                    ,p_mode => 'CREATE'
                                  );
            IF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
         END IF; */
         END IF; -- end if for parent fund
      END IF; -- end if for status code


      -- yzhao 04/02/2002 no need to call process_approval if it's from actbudget update
      IF p_mode <> 'ADJUST' THEN
        -- 10/14/2002 mode is always update in QP
         /*IF l_fund_rec.status_code IN ('CLOSED','CANCELLED','ACTIVE','ON_HOLD')
              AND  l_old_status IN ('ACTIVE','ON_HOLD') THEN
         */
             l_mode := 'UPDATE' ; -- when not creating act_budgets
         IF l_fund_rec.status_code IN ('ACTIVE','ON_HOLD')
              AND  l_old_status IN ('PENDING','DRAFT') THEN
             l_mode := 'ACTIVE' ; -- when creating act budgets for active funds
         END IF;
         -- call when it is active after submitting for approval
         IF l_mode IN ('ACTIVE' , 'UPDATE' ) THEN
            ozf_fundrules_pvt.process_approval(
                p_fund_rec => l_fund_rec
               ,p_mode     => l_mode
               ,p_old_fund_status => l_old_status
               ,x_return_status => l_return_status
               ,x_msg_count => x_msg_count
               ,x_msg_data => x_msg_data
               ,p_api_version => 1.0);
         END IF;

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
     END IF;    -- yzhao: end of IF p_mode <> 'ADJUST'

     -- call when it is submitting for approval
     IF l_submit_child_approval = FND_API.g_true THEN
        -- yzhao: 03/18/2003 handle budget allocation as well
        IF l_fund_rec.fund_usage IS NOT NULL AND l_fund_rec.fund_usage = 'ALLOC' THEN
            -- yzhao: 03/18/2003 budget allocation does not need workflow approval process so pass allocation_flag='Y'
           l_allocation_flag := 'Y';
        ELSE
           l_allocation_flag := 'N';
        END IF;
        --nirprasa, no chnage needed as this flow is for request
        ozf_fund_request_apr_pvt.create_fund_request(
                  p_commit => fnd_api.g_false
                 ,p_approval_for_id => p_fund_rec.fund_id
                  /* yzhao: Jan 16 2005 fix bug 4943323(4912954) pass in correct requester id
                 ,p_requester_id => l_fund_rec.owner
                   */
                 ,p_requester_id => ozf_utility_pvt.get_resource_id(p_user_id => fnd_global.user_id)
                 ,p_requested_amount => l_child_request_amt
                 ,p_approval_fm => 'FUND'
                 ,p_approval_fm_id => l_fund_rec.parent_fund_id
                 ,p_transfer_type => 'REQUEST'
                 ,p_child_flag =>'Y'
                  -- yzhao: 03/18/2003 11.5.9 for allocation activation of territory hierarchy, always pass as 'Y'; all others 'N'
                 ,p_allocation_flag => l_allocation_flag
                 ,p_justification => l_fund_rec.description
                 ,x_return_status => l_return_status
                 ,x_msg_count => x_msg_count
                 ,x_msg_data => x_msg_data
                 ,x_request_id => l_request_id
                 ,x_approver_id => l_approver_id
                 ,x_is_requester_owner => l_is_requestor_owner);

        IF l_return_status = fnd_api.g_ret_sts_error THEN
           RAISE fnd_api.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;
     END IF;
     -- call when it is submitting for approval
     IF l_submit_budget_approval = FND_API.g_true THEN
         l_reject_status_id :=ozf_utility_pvt.get_default_user_status(
                        l_status_type
                       ,'REJECTED');

                AMS_GEN_APPROVAL_PVT.StartProcess
                 (p_activity_type  => g_activity_type
                  ,p_activity_id    => p_fund_rec.fund_id
                  ,p_approval_type  => G_PARENT_APPROVAL_TYPE
                  ,p_object_version_number  =>p_fund_rec.object_version_number -- old object version number
                  ,p_orig_stat_id           =>l_old_user_status_id
                  ,p_new_stat_id            =>p_fund_rec.user_status_id -- active status
                  ,p_reject_stat_id         =>l_reject_status_id
                  /* yzhao: Jan 16 2005 fix bug 4943323(4912954) pass in correct requester id
                  ,p_requester_userid       =>l_fund_rec.owner
                   */
                  ,p_requester_userid       =>ozf_utility_pvt.get_resource_id(p_user_id => fnd_global.user_id)
                  ,p_notes_from_requester   =>l_fund_rec.description
                  ,p_workflowprocess        => l_workflow_process
                  ,p_item_type              => l_item_type);

         raise_business_event(p_object_id => p_fund_rec.fund_id , p_event_type =>'APPROVAL');
     ELSE
        -- raise business event.
         raise_business_event(p_object_id => p_fund_rec.fund_id ,p_event_type =>'UPDATE');
     END IF;

      /************************   MPANDE JAN-16 2001 ************************************************
      ..The calls that were made to the following API for child fund  workflow process
                  ozf_wf_request_apr_pvt.create_fund_request
         was removed from this place and put in update_fund_status APIS
         The code was removed and not commented because of clarity and cleanliness. Please refer to
         earlier versions for bug fixes etc. in releases prior to 11.5.5. (hornet)
      **********************************************************************************************/
      -- reinitialize the variables
      l_act_access_id := NULL;
      l_acc_obj_ver_num := NULL;
       -- if owner is changing update acesss
      IF  p_fund_rec.owner <> fnd_api.g_miss_num
         AND l_owner <> p_fund_rec.owner THEN
            IF G_DEBUG THEN
               ozf_utility_pvt.debug_message(l_full_name || ': insert access owner');
            END IF;
/*     commented by feliu on 05/13/2003 to fix bug 2969498;
            OPEN c_access(p_fund_rec.fund_id);
            FETCH c_access INTO l_act_access_id, l_acc_obj_ver_num;
            CLOSE c_access;
            ams_access_pvt.init_access_rec(l_access_rec);
            l_access_rec.activity_access_id := l_act_access_id;
            l_access_rec.object_version_number := l_acc_obj_ver_num;
            l_access_rec.act_access_to_object_id := l_fund_rec.fund_id;
            l_access_rec.arc_act_access_to_object := 'FUND';
            l_access_rec.user_or_role_id := l_fund_rec.owner;
            l_access_rec.arc_user_or_role_type := 'USER';
            l_access_rec.admin_flag := 'Y';
            l_access_rec.owner_flag := 'Y';
            ams_access_pvt.update_access(
               p_api_version => l_api_version
              ,p_init_msg_list => fnd_api.g_false
              ,p_validation_level => p_validation_level
              ,x_return_status => l_return_status
              ,x_msg_count => x_msg_count
              ,x_msg_data => x_msg_data
              ,p_commit => fnd_api.g_false
              ,p_access_rec => l_access_rec);
*/

           AMS_Access_PVT.update_object_owner
              ( p_api_version        => 1.0
                ,p_init_msg_list      => FND_API.G_FALSE
                ,p_commit             => FND_API.G_FALSE
                ,p_validation_level   => p_validation_level
                ,x_return_status      => x_return_status
                ,x_msg_count          => x_msg_count
                ,x_msg_data           => x_msg_data
                ,p_object_type        => 'FUND'
                ,p_object_id          => l_fund_rec.fund_id
                ,p_resource_id        => l_fund_rec.owner
                ,p_old_resource_id    => l_owner
              );
            IF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
       END IF; -- end of owner is changing

     -- added by feliu to fix bug 2654263
      -- if parent id is not null during updation and old parent id is null ,
      -- a row is created in the ams_act_access to give access
      -- to the owner of the parent fund to this child
      --if the parent fund owner and the child fund owner is not same then only create this
       IF l_fund_rec.parent_fund_id IS NOT NULL AND l_fund_rec.owner <> l_par_fund_owner THEN
       --if there is no parent fund OR (09/05/2001 mpande) when no records exists in ams_act_access for the fund
        --then create a access for the new parent ownner
          IF l_old_parent_fund_id IS NULL THEN
             update_funds_access(
                              p_api_version  => l_api_version
                              ,p_init_msg_list  => fnd_api.g_false
                              ,p_commit     => fnd_api.g_false
                              ,p_validation_level   => p_validation_level
                              ,x_return_status      => l_return_status
                              ,x_msg_count  => x_msg_count
                              ,x_msg_data   => x_msg_data
                              ,p_fund_rec => l_fund_rec
                              ,p_mode => 'CREATE'
                              );
             IF l_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
             ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
             END IF;

            --if the old parent fund  and the new parent fund  is diffrent.
          ELSIF  l_old_parent_fund_id <> l_fund_rec.parent_fund_id THEN
             update_funds_access(
                              p_api_version  => l_api_version
                              ,p_init_msg_list  => fnd_api.g_false
                              ,p_commit     => fnd_api.g_false
                              ,p_validation_level   => p_validation_level
                              ,x_return_status      => l_return_status
                              ,x_msg_count  => x_msg_count
                              ,x_msg_data   => x_msg_data
                              ,p_fund_rec => l_fund_rec
                              ,p_mode => 'CREATE'
                              );
             IF l_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
             ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
             END IF;
          END IF; -- end of l_old_parent_fund_id <> l_fund_rec.parent_fund_id.
       END IF;  -- end of l_fund_rec.parent_fund_id IS NOT NULL
       -- added by feliu to fix bug 2654263

       /* R12: yzhao bug 4669269 - obsolete ozf_mc_transactions
       IF   p_fund_rec.original_budget <> FND_API.g_miss_num
           OR p_fund_rec.transfered_in_amt <> FND_API.g_miss_num
           OR p_fund_rec.transfered_out_amt <> FND_API.g_miss_num
           OR p_fund_rec.holdback_amt <> FND_API.g_miss_num
           OR p_fund_rec.planned_amt <> FND_API.g_miss_num
           OR p_fund_rec.committed_amt <> FND_API.g_miss_num
           OR p_fund_rec.utilized_amt <> FND_API.g_miss_num            -- yzhao: 11.5.10
           OR p_fund_rec.earned_amt <> FND_API.g_miss_num
           OR p_fund_rec.paid_amt <> FND_API.g_miss_num
           OR p_fund_rec.currency_code_tc <> FND_API.g_miss_char   THEN

          OPEN c_mc_record(p_fund_rec.fund_id);
          FETCH c_mc_record INTO l_mc_record_id, l_mc_obj_number;
          CLOSE c_mc_record;
          --///mpande
          -- Insert a record in OZF_MC_TRANSACTIONS_ALL IN functional currency
          --  so that we have the functional currency amounts
          --   The exchange_rate_type is picked up by the MC_TRAnSACTIONS API
          -- from proile
          -- update the transaction table on all cases.

          IF G_DEBUG THEN
             ozf_utility_pvt.debug_message(l_full_name ||': insert FC record' ||l_fund_rec.currency_code_tc);
          END IF;
          ozf_mc_transactions_pvt.init_transaction_rec(x_mc_transactions_rec => l_mc_transaction_rec);
          -- Populate the record variable
          l_mc_transaction_rec.mc_record_id := l_mc_record_id;
          l_mc_transaction_rec.object_version_number := l_mc_obj_number;
          l_mc_transaction_rec.source_object_name := 'FUND';
          l_mc_transaction_rec.source_object_id := l_fund_rec.fund_id;
          l_mc_transaction_rec.currency_code := l_fund_rec.currency_code_tc;
          l_mc_transaction_rec.amount_column1 := l_fund_rec.original_budget;
          l_mc_transaction_rec.amount_column2 := l_fund_rec.transfered_in_amt;
          l_mc_transaction_rec.amount_column3 := l_fund_rec.transfered_out_amt;
          l_mc_transaction_rec.amount_column4 := l_fund_rec.holdback_amt;
          l_mc_transaction_rec.amount_column5 := l_fund_rec.planned_amt;
          l_mc_transaction_rec.amount_column6 := l_fund_rec.committed_amt;
          l_mc_transaction_rec.amount_column7 := l_fund_rec.earned_amt;
          l_mc_transaction_rec.amount_column8 := l_fund_rec.paid_amt;
          l_mc_transaction_rec.amount_column9 := l_fund_rec.utilized_amt;          -- yzhao: 11.5.10

          -- kdass - R12 MOAC changes
          OPEN c_get_org_id;
          FETCH c_get_org_id INTO l_fund_rec.org_id;
          CLOSE c_get_org_id;

          -- Call mc_transaction API if fund type is not QUOTA
          IF l_fund_rec.fund_type <> 'QUOTA' THEN
              ozf_mc_transactions_pvt.update_mc_transactions(
                 p_api_version => l_api_version
                ,p_init_msg_list => fnd_api.g_false
                ,p_commit => fnd_api.g_false
                 -- 01/13/2003  yzhao fix bug BUG 2750841(same as 2741039) pass in org_id
                ,p_org_id => l_fund_rec.org_id
                ,x_return_status => l_return_status
                ,x_msg_count => x_msg_count
                ,x_msg_data => x_msg_data
                ,p_mc_transactions_rec => l_mc_transaction_rec);

                 IF l_return_status = fnd_api.g_ret_sts_error THEN
                        RAISE fnd_api.g_exc_error;
                 ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                        RAISE fnd_api.g_exc_unexpected_error;
                 END IF;
          END IF;

       END IF ; --check for amount
       */

   END IF;-- end return status

   -- Check for commit
   IF fnd_api.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false
     ,p_count => x_msg_count
     ,p_data => x_msg_data);
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name || ': end');
   END IF;
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_fund;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_fund;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
   WHEN OTHERS THEN
      ROLLBACK TO update_fund;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
END update_fund;

--------------------------------------------------------------------
-- PROCEDURE
--    Validate_Fund
--
-- HISTORY
--    02/02/2000  Shitij Vatsa  Create.
--    06/13/2000  Mumu PAnde Added validations
--    07/28/2000  Mumu Pande Added parent_validation against child
--    01/20/2001  Mumu Pande Added call for fund inter entity validations
--------------------------------------------------------------------
PROCEDURE validate_fund(
   p_api_version        IN       NUMBER
  ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
  ,x_return_status      OUT NOCOPY      VARCHAR2
  ,x_msg_count          OUT NOCOPY      NUMBER
  ,x_msg_data           OUT NOCOPY      VARCHAR2
  ,p_fund_rec           IN       fund_rec_type)
IS
   l_api_version    CONSTANT NUMBER       := 1.0;
   l_api_name       CONSTANT VARCHAR2(30) := 'Validate_Fund';
   l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
   l_return_status           VARCHAR2(1);
BEGIN
   ----------------------- initialize --------------------
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name || ': start');
   END IF;

   IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_return_status := fnd_api.g_ret_sts_success;
   ---------------------- validate ------------------------
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name || ': check items');
   END IF;

   IF p_validation_level >= jtf_plsql_api.g_valid_level_item THEN
      ----dbms_output.put_line ('Calling Check_Fund_Items from validate');
      check_fund_items(
         p_fund_rec => p_fund_rec
        ,p_validation_mode => jtf_plsql_api.g_create
        ,x_return_status => l_return_status);

      ----dbms_output.put_line ('Called Check_Fund_Items from validate');
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      END IF;
   END IF;

   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name || ': check record');
   END IF;

   IF p_validation_level >= jtf_plsql_api.g_valid_level_record THEN
      check_fund_record(
         p_fund_rec => p_fund_rec
        ,p_complete_rec => p_fund_rec
        ,p_mode => jtf_plsql_api.g_create
        ,x_return_status => l_return_status);

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      END IF;
   END IF;

   -- added on 01/20/2001  for all inter entity validations Mumu Pande
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name || ': check inter-entity');
   END IF;

   IF p_validation_level >= jtf_plsql_api.g_valid_level_inter_entity THEN
      check_fund_inter_entity(
         p_fund_rec => p_fund_rec
        ,p_complete_rec => p_fund_rec
        ,p_validation_mode => jtf_plsql_api.g_create
        ,x_return_status => l_return_status);

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      END IF;
   END IF;

   -------------------- finish --------------------------
   fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false
     ,p_count => x_msg_count
     ,p_data => x_msg_data);
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name || ': end');
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
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
END validate_fund;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Fund_Req_Items
--
-- HISTORY
--    02/02/2000  Shitij Vatsa  Create.
--   09/20/2000  Mumu Pande for user status
--   01/20/2001  Mumu Pande for category
---------------------------------------------------------------------
PROCEDURE check_fund_req_items(
   p_fund_rec        IN       fund_rec_type
  ,x_return_status   OUT NOCOPY      VARCHAR2)
IS

BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   -- Commented by mpande  02/16/2001 We are going to generate the number if it is null
   ------------------------ fund_number --------------------------
   /*   IF p_fund_rec.fund_number IS NULL THEN   -- check for fund number
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            IF p_fund_rec.fund_type = 'QUOTA' THEN
              fnd_message.set_name('OZF', 'OZF_TP_NO_QUOTA_NUMBER');
            ELSE
              fnd_message.set_name('OZF', 'OZF_FUND_NO_FUND_NUMBER');
            END IF;
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   */
   ------------------------ owner -------------------------------
   IF p_fund_rec.owner IS NULL THEN   -- check for fund owner
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         IF p_fund_rec.fund_type = 'QUOTA' THEN
            fnd_message.set_name('OZF', 'OZF_TP_NO_QUOTA_OWNER');
         ELSE
            fnd_message.set_name('OZF', 'OZF_FUND_NO_FUND_OWNER');
         END IF;
         fnd_msg_pub.add;
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_fund_rec.fund_type IS NULL THEN   -- check for fund owner
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_FUND_NO_FUND_TYPE');
         fnd_msg_pub.add;
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;

   --   09/20/2000  Mumu Pande for user status
   IF p_fund_rec.user_status_id IS NULL THEN   -- check for fund user status
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_FUND_NO_USER_STATUS');
         fnd_msg_pub.add;
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;

   --   01/20/2001  Mumu Pande for category
   IF p_fund_rec.fund_type <> 'QUOTA' AND p_fund_rec.category_id IS NULL THEN   -- check for fund category
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_FUND_NO_CATEGORY');
         fnd_msg_pub.add;
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;
   --   01/20/2001  Mumu Pande for custom_setup_id
   IF p_fund_rec.custom_setup_id IS NULL THEN   -- check for fund category
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_FUND_NO_CUSTOM_SETUP');
         fnd_msg_pub.add;
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;
   --  11/13/2001 mpande added budget amount cannot be euqal to 0 for root budgets
  --   12/23/04 by feliu. For the budgets created from mass transfer, don't  validate. fix bug 3580531.

   IF p_fund_rec.prev_fund_id IS NULL AND p_fund_rec.parent_fund_id IS NULL AND p_fund_rec.fund_type = 'FIXED' THEN

      -- niprakas changed <= to <
      -- rimehrot changed back to <= for bug fix 3580531
      IF NVL(p_fund_rec.original_budget,0) <= 0 THEN   -- check for fund amount
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
           IF p_fund_rec.fund_type = 'QUOTA' THEN
             fnd_message.set_name('OZF', 'OZF_TP_NO_ORG_QUOTA');
           ELSE
             fnd_message.set_name('OZF', 'OZF_FUND_NO_ORG_BUDGET');
           END IF;
           fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --kdass 25-APR-2006 bug 5176819 - Ledger is required field
   IF p_fund_rec.fund_type <> 'QUOTA' AND p_fund_rec.ledger_id IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_FUND_NO_LEDGER');
         fnd_msg_pub.add;
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;

   /* yzhao: bug 4669461: R12 budget is org aware, but not org stripped. quota is not org aware
                          so org_id is not required
   IF p_fund_rec.org_id IS NULL THEN   -- check for org id
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_NO_DEFAULT_ORG_ID');
         fnd_msg_pub.add;
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;
    */

END check_fund_req_items;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Fund_Uk_Items
--
-- HISTORY
--    02/02/2000  Shitij Vatsa  Create.
--  2nd August200 MPAnde Updated
---------------------------------------------------------------------
PROCEDURE check_fund_uk_items(
   p_fund_rec          IN       fund_rec_type
  ,p_validation_mode   IN       VARCHAR2 := jtf_plsql_api.g_create
  ,x_return_status     OUT NOCOPY      VARCHAR2)
IS
   l_valid_flag    VARCHAR2(1);

    -- Added for Bug #3498826
     CURSOR c_prog_fund_number_create
     IS
     SELECT 1 from ozf_funds_all_b
     WHERE fund_number = p_fund_rec.fund_number;

      CURSOR c_prog_fund_number_update
      IS
      SELECT 1 from ozf_funds_all_b
      WHERE fund_number = p_fund_rec.fund_number
      AND fund_id <> p_fund_rec.fund_id;


BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   -- For Create_Fund, when fund_id is passed in, we need to
   -- check if this fund_id is unique.
   IF     p_validation_mode = jtf_plsql_api.g_create
      AND p_fund_rec.fund_id IS NOT NULL THEN
      IF ozf_utility_pvt.check_uniqueness(
            'ozf_funds_all_vl'
           ,'fund_id = ' || p_fund_rec.fund_id) =
            fnd_api.g_false THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            IF p_fund_rec.fund_type = 'QUOTA' THEN
               fnd_message.set_name('OZF', 'OZF_TP_DUPLICATE_ID');
             ELSE
               fnd_message.set_name('OZF', 'OZF_FUND_DUPLICATE_ID');
             END IF;
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- Check if fund_number is unique. Need to handle create and
   -- update differently.
   IF p_validation_mode = jtf_plsql_api.g_create THEN
      /*l_valid_flag :=
         ozf_utility_pvt.check_uniqueness(
            'ozf_funds_all_vl'
           ,'fund_number = ''' || p_fund_rec.fund_number || '''');*/
      OPEN c_prog_fund_number_create;
     FETCH c_prog_fund_number_create INTO l_valid_flag;
     CLOSE c_prog_fund_number_create;
   ELSE
     /* l_valid_flag :=
         ozf_utility_pvt.check_uniqueness(
            'ozf_funds_all_vl'
           ,'fund_number = ''' ||
            p_fund_rec.fund_number ||
            ''' AND fund_id <> ' ||
            p_fund_rec.fund_id);*/
     OPEN c_prog_fund_number_update;
     FETCH c_prog_fund_number_update INTO l_valid_flag;
     CLOSE c_prog_fund_number_update;
   END IF;

   IF l_valid_flag = 1 THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         IF p_fund_rec.fund_type = 'QUOTA' THEN
            fnd_message.set_name('OZF', 'OZF_TP_DUPLICATE_NUMBER');
          ELSE
            fnd_message.set_name('OZF', 'OZF_FUND_DUPLICATE_NUMBER');
          END IF;
         fnd_msg_pub.add;
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;
   -- Check if fund_name is unique if it is accrual fund/offer name . Need to handle create and
   -- update differently.
   -- Commented for Bug Fix #3498826
  /*
   IF p_fund_rec.fund_type = 'FULLY_ACCRUED' THEN
   IF p_validation_mode = jtf_plsql_api.g_create THEN
      l_valid_flag :=
         ozf_utility_pvt.check_uniqueness(
            'ozf_funds_all_vl'
           ,'short_name = ''' || p_fund_rec.short_name || '''');
   ELSE
      l_valid_flag :=
         ozf_utility_pvt.check_uniqueness(
            'ozf_funds_all_vl'
           ,'short_name = ''' ||
            p_fund_rec.short_name ||
            ''' AND fund_id <> ' ||
            p_fund_rec.fund_id);
   END IF;

   IF l_valid_flag = fnd_api.g_false THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         IF p_fund_rec.fund_type = 'QUOTA' THEN
            fnd_message.set_name('OZF', 'OZF_TP_DUPLICATE_NAME');
          ELSE
            fnd_message.set_name('OZF', 'OZF_FUND_DUPLICATE_NAME');
          END IF;
         fnd_msg_pub.add;
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;
   END IF;*/

END check_fund_uk_items;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Fund_Fk_Items
--
-- HISTORY
--    20/09/2000  Mumu Pande  Create.
--   09/20/2000  Mumu Pande for user status
--    01/20/2001  Mumu PAnde for category validations
---------------------------------------------------------------------
PROCEDURE check_fund_fk_items(
   p_fund_rec        IN       fund_rec_type
  ,x_return_status   OUT NOCOPY      VARCHAR2)
IS
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   ----------------------- user_status_id ------------------------
   IF p_fund_rec.user_status_id <> fnd_api.g_miss_num THEN
      IF ozf_utility_pvt.check_fk_exists(
            'ams_user_statuses_vl'
           ,'user_status_id'
           ,p_fund_rec.user_status_id) =
            fnd_api.g_false THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_FUND_BAD_USER_STATUS_ID');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- added on 01/20/2001  MPANDE
   ----------------------- category_id ------------------------
  -- mkothari - Bug 4701105 - start ----
  IF p_fund_rec.fund_type <> 'QUOTA' THEN
   IF p_fund_rec.category_id <> fnd_api.g_miss_num THEN
      IF ozf_utility_pvt.check_fk_exists(
            'ams_categories_vl'
           ,'category_id'
           ,p_fund_rec.category_id) =
            fnd_api.g_false THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_FUND_BAD_CAT_ID');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
  END IF;
  -- mkothari - Bug 4701105 - end ----
-- check other fk items

END check_fund_fk_items;



---------------------------------------------------------------------
-- PROCEDURE
--    Check_Fund_Lookup_Items
--
-- HISTORY
--    02/02/2000  Shitij Vatsa  Create.
---------------------------------------------------------------------
PROCEDURE check_fund_lookup_items(
   p_fund_rec        IN       fund_rec_type
  ,x_return_status   OUT NOCOPY      VARCHAR2)
IS
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   ----------------------- fund_type ------------------------
   IF p_fund_rec.fund_type <> fnd_api.g_miss_char THEN
      IF ozf_utility_pvt.check_lookup_exists(
            p_lookup_table_name => 'OZF_LOOKUPS'
           ,p_lookup_type => 'OZF_FUND_TYPE'
           ,p_lookup_code => p_fund_rec.fund_type) =
            fnd_api.g_false THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
             IF p_fund_rec.fund_type = 'QUOTA' THEN
               fnd_message.set_name('OZF', 'OZF_TP_BAD_QUOTA_TYPE');
             ELSE
               fnd_message.set_name('OZF', 'OZF_FUND_BAD_FUND_TYPE');
             END IF;
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;


   ----------------------- status_code ------------------------
   IF p_fund_rec.status_code <> fnd_api.g_miss_char THEN
      IF ozf_utility_pvt.check_lookup_exists(
            p_lookup_table_name => 'OZF_LOOKUPS'
           ,p_lookup_type => 'OZF_FUND_STATUS'
           ,p_lookup_code => p_fund_rec.status_code) =
            fnd_api.g_false THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
             IF p_fund_rec.fund_type = 'QUOTA' THEN
               fnd_message.set_name('OZF', 'OZF_TP_BAD_STATUS_CODE');
             ELSE
               fnd_message.set_name('OZF', 'OZF_FUND_BAD_STATUS_CODE');
             END IF;
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
-- check other lookup codes

END check_fund_lookup_items;



---------------------------------------------------------------------
-- PROCEDURE
--    Check_Fund_Flag_Items
--
-- HISTORY
--    02/02/2000  Shitij Vatsa  Create.
---------------------------------------------------------------------
PROCEDURE check_fund_flag_items(
   p_fund_rec        IN       fund_rec_type
  ,x_return_status   OUT NOCOPY      VARCHAR2)
IS
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   ----------------------- liability_flag ------------------------
   IF     p_fund_rec.liability_flag <> fnd_api.g_miss_char
      AND p_fund_rec.liability_flag IS NOT NULL THEN
      IF ozf_utility_pvt.is_y_or_n(p_fund_rec.liability_flag) = fnd_api.g_false THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_FUND_BAD_LIABILITY_FLAG');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- budget_flag ------------------------
   IF     p_fund_rec.budget_flag <> fnd_api.g_miss_char
      AND p_fund_rec.budget_flag IS NOT NULL THEN
      IF ozf_utility_pvt.is_y_or_n(p_fund_rec.budget_flag) = fnd_api.g_false THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
             IF p_fund_rec.fund_type = 'QUOTA' THEN
               fnd_message.set_name('OZF', 'OZF_TP_BAD_QUOTA_FLAG');
             ELSE
               fnd_message.set_name('OZF', 'OZF_FUND_BAD_BUDGET_FLAG');
             END IF;
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- earned_flag ------------------------
   IF     p_fund_rec.earned_flag <> fnd_api.g_miss_char
      AND p_fund_rec.earned_flag IS NOT NULL THEN
      IF ozf_utility_pvt.is_y_or_n(p_fund_rec.earned_flag) = fnd_api.g_false THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_FUND_BAD_EARNED_FLAG');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
-- check other flags

END check_fund_flag_items;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Fund_Items
--
-- HISTORY
--    02/02/2000  Shitij Vatsa  Create.
---------------------------------------------------------------------
PROCEDURE check_fund_items(
   p_validation_mode   IN       VARCHAR2 := jtf_plsql_api.g_create
  ,x_return_status     OUT NOCOPY      VARCHAR2
  ,p_fund_rec          IN       fund_rec_type)
IS
BEGIN
   ----dbms_output.put_line('Calling Req_Items');
   check_fund_req_items(p_fund_rec => p_fund_rec, x_return_status => x_return_status);

   IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RETURN;
   END IF;

   ----dbms_output.put_line('Calling Uk_Items');
   check_fund_uk_items(
      p_fund_rec => p_fund_rec
     ,p_validation_mode => p_validation_mode
     ,x_return_status => x_return_status);

   IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RETURN;
   END IF;

   ----dbms_output.put_line('Calling Fk_Items');
   check_fund_fk_items(p_fund_rec => p_fund_rec, x_return_status => x_return_status);

   IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RETURN;
   END IF;

   ----dbms_output.put_line('Calling Lookup_Items');

   check_fund_lookup_items(p_fund_rec => p_fund_rec, x_return_status => x_return_status);

   IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RETURN;
   END IF;

   ----dbms_output.put_line('Calling Flag_Items');
   check_fund_flag_items(p_fund_rec => p_fund_rec, x_return_status => x_return_status);

   IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RETURN;
   END IF;
END check_fund_items;



---------------------------------------------------------------------
-- PROCEDURE
--    Check_Fund_Record
--
-- HISTORY
--    02/02/2000  Shitij Vatsa  Create.
--    06/14/2000  Mumu Pande  Added validation and chaged some of the earlier validations
--   01/20/2001  Mumu Pande  Rempved all fund inter entity validation to procedure check_fund_inter_entity
--   01/20/2001  Mumu Pande  Added  all calls for fund accrual  validation
--    11/05/2003 yzhao: fix bug 3238497 - allow fully accrual budget to go below 0
---------------------------------------------------------------------
PROCEDURE check_fund_record(
   p_fund_rec        IN       fund_rec_type
  ,p_complete_rec    IN       fund_rec_type
  ,p_mode            IN       VARCHAR2
  ,x_return_status   OUT NOCOPY      VARCHAR2)
IS
   l_fund_id            NUMBER;
   l_start_date         DATE;
   l_end_date           DATE;

   -- Check old fund status
   CURSOR c_old_status(
      cv_fund_id   IN   NUMBER)
   IS
      SELECT   status_code, original_budget
      FROM     ozf_funds_all_b
      WHERE  fund_id = cv_fund_id;

   CURSOR c_offer_org(p_list_header_id IN NUMBER)
   IS
      SELECT org_id
      FROM  ozf_offers
      WHERE qp_list_header_id = p_list_header_id;

   l_fund_old_status    VARCHAR2(30);
   l_fund_old_amount    NUMBER;
   l_return_status      VARCHAR2(1);
   l_resource_id        NUMBER;
   l_offer_org          NUMBER := NULL;
   l_offer_ledger       NUMBER;
   l_offer_ledgerName   VARCHAR2(50);

BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
   -- Check all modes validations

   -- Ensure that start date is greater than the end date --
   l_start_date := p_complete_rec.start_date_active;
   l_end_date := p_complete_rec.end_date_active;
   IF p_complete_rec.status_code = 'DRAFT' THEN
    IF p_fund_rec.fund_type = 'FULLY_ACCRUED' THEN
       -- yzhao 07/15/2002 fix bug 2457199 UNABLE TO CREATE FULLY ACCRUED BUDGET DUE TO START DATE PROB
       --   start date passed in is midnight of the selected day. So trunc sysdate to get midnight time
       IF NVL(l_start_date, sysdate) < trunc(sysdate) THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_FUND_STARTDATE_MISMATCH');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
       END IF;
    END IF ;
   END IF;

   /* yzhao: 01/14/2003 fix BUG 2750445 - UNABLE TO CLOSE BUDGET, BUDGET 'END DATE' CANNOT BE BEFORE TODAY'S DATE
   IF p_fund_rec.end_date_active <> FND_API.g_miss_date
      AND l_end_date IS NOT NULL OR p_complete_rec.status_code = 'DRAFT'
      AND p_fund_rec.status_code = FND_API.g_miss_char THEN
    */
   IF p_complete_rec.status_code NOT IN ('CLOSED','CANCELLED','ARCHIVED') AND
      l_end_date IS NOT NULL THEN
       -- validate only if status changes or date changes
       OPEN c_old_status(p_fund_rec.fund_id);
       FETCH c_old_status INTO l_fund_old_status,l_fund_old_amount;
       CLOSE c_old_status;
       IF ((p_fund_rec.status_code <> FND_API.G_MISS_CHAR AND
            p_fund_rec.status_code <> l_fund_old_status) OR
           p_fund_rec.end_date_active <> FND_API.g_miss_date) THEN
   /* yzhao: 01/14/2003 fix bug 2750445 ends */

            -- yzhao 09/03/2002 fix bug 2540628 TST 1158.7 FUNC MASTER : CANNOT END DATE A BUDGET ON CURRENT DATE
            --   end date passed in is midnight of the selected day. So trunc sysdate to get midnight time
            -- IF NVL(l_end_date,sysdate) < sysdate THEN
            /* kdass 28-Dec-2004 fix for 11.5.10 bug 4089720, when the fund is created from mass transfer,
               do not check for end date */
            --IF NVL(l_end_date,sysdate) < trunc(sysdate) THEN
            IF NVL(l_end_date,sysdate) < trunc(sysdate) AND p_fund_rec.prev_fund_id IS NULL THEN
              IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                 IF p_fund_rec.fund_type = 'QUOTA' THEN
                   fnd_message.set_name('OZF', 'OZF_TP_ENDDATE_MISMATCH');
                 ELSE
                    fnd_message.set_name('OZF', 'OZF_FUND_ENDDATE_MISMATCH');
                 END IF;
                 fnd_msg_pub.add;
              END IF;
              x_return_status := fnd_api.g_ret_sts_error;
            END IF;
       END IF;
   END IF;

/*   -- Budget Amount cannot be updated for an active budget. #3570045 -- reverted change.
   IF p_complete_rec.status_code = 'ACTIVE' THEN
        OPEN c_old_status(p_fund_rec.fund_id);
        FETCH c_old_status INTO l_fund_old_status, l_fund_old_amount;
        CLOSE c_old_status;

        IF l_fund_old_status = 'ACTIVE' AND p_complete_rec.original_budget <> l_fund_old_amount THEN
            fnd_message.set_name('OZF', 'OZF_ACTIVE_FUND_AMT');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_error;
        END IF;
   END IF;
*/
   --original amount should be within 15 digits
      IF p_complete_rec.original_budget > 999999999999999 THEN
         IF p_fund_rec.fund_type = 'QUOTA' THEN
             fnd_message.set_name('OZF', 'OZF_TP_MAX_AMT_EXCEEDED');
          ELSE
             fnd_message.set_name('OZF', 'OZF_FUND_MAX_AMT_EXCEEDED');
          END IF;
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

   IF l_start_date > l_end_date THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_FUND_DATE_MISMATCH');
         fnd_msg_pub.add;
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
   END IF;

   IF p_mode = jtf_plsql_api.g_update THEN
      IF     p_fund_rec.parent_fund_id <> fnd_api.g_miss_num
         AND p_fund_rec.parent_fund_id IS NOT NULL THEN
         IF p_complete_rec.fund_id = p_complete_rec.parent_fund_id THEN
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                IF p_fund_rec.fund_type = 'QUOTA' THEN
                  fnd_message.set_name('OZF', 'OZF_TP_WRONG_PARENT');
                ELSE
                   fnd_message.set_name('OZF', 'OZF_FUND_WRONG_PARENT');
                END IF;
               fnd_msg_pub.add;
               x_return_status := fnd_api.g_ret_sts_error;
            END IF;
         END IF;
      END IF;
   END IF;

   -- added by mpande
   -- holdback amt cannot be greater than total budget which is equal to
   -- (ORG_BUDG - Holdback_amt + Trasfered_in_amt - Transfered_out_amt)
   -- in a active fund where as in a draft fund holdback should be more than original budget
   IF p_complete_rec.status_code = 'ACTIVE' THEN
      -- 11/05/2003 yzhao: fix bug 3238497 - allow fully accrual budget to go below 0
      IF p_complete_rec.fund_type <> 'FULLY_ACCRUED' OR
         p_complete_rec.original_budget >= 0 OR
         NVL(p_complete_rec.holdback_amt, 0) <> 0 THEN
         IF p_complete_rec.holdback_amt >
            (  NVL(p_complete_rec.original_budget, 0) +
               NVL(p_complete_rec.transfered_in_amt, 0) -
               NVL(p_complete_rec.transfered_out_amt, 0)) THEN
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name('OZF', 'OZF_EXCESS_HOLDBACK_AMT');
               fnd_msg_pub.add;
            END IF;
            x_return_status := fnd_api.g_ret_sts_error;
         END IF;
      END IF;

        -- hold back amount should not be negative fix for bug#3352216
      IF p_complete_rec.holdback_amt < 0 THEN
         fnd_message.set_name('OZF', 'OZF_FUND_NO_HOLDBACK_BUDGET');
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

   ELSE
      IF p_complete_rec.holdback_amt > (NVL(p_complete_rec.original_budget, 0)) THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_EXCESS_HOLDBACK_AMT');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      --RAISE FND_API.g_exc_error;
      END IF;

       -- holdback amount should not be negative. Fix for bug#3352216
      IF p_complete_rec.holdback_amt < 0 THEN
         fnd_message.set_name('OZF', 'OZF_FUND_NO_HOLDBACK_BUDGET');
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

   END IF;

   -- For a accrual type fund whenever it becomes active the original budget should be 0
   --   01/20/2001  Mumu Pande  Added  all calls for fund accrual  validation
   -- 6/11/2002 mpande Check for Original Budget = 0 when the status is not ACTIVE
   IF p_complete_rec.fund_type = 'FULLY_ACCRUED' THEN

      /* yzhao: 02/04/2003 fix bug: can not close an accrual budget if it already accrued some fund
      IF NVL(p_complete_rec.original_budget, 0) <> 0 AND p_complete_rec.status_code IN ('DRAFT','CLOSED','CANCELLED','ARCHIVED')  THEN
       */
      IF NVL(p_complete_rec.original_budget, 0) <> 0 AND p_complete_rec.status_code = 'DRAFT'  THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_ACCRUAL_NO_ORG_BUDGET');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;
      /* 11.5.9
      IF p_complete_rec.accrual_basis IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_ACCRUAL_NO_BASIS');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;*/
      /*
      IF p_complete_rec.accrual_operand IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_ACCRUAL_NO_OPERAND');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;
      */
      /* -- we donot need to give the UOM
      IF p_complete_rec.accrual_uom IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_ACCRUAL_NO_UOM');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;
      */
      /*
      -- sangara - R12 enhancement - not mandatory, as they are moved to Market Options cuecard
      IF p_complete_rec.accrual_phase IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_ACCRUAL_NO_PHASE');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;
      */
      /*
      IF NVL(p_complete_rec.accrual_rate, 0) <= 0 THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_ACCRUAL_NO_RATE');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;
      -- default the quantity to 1
      /*
      IF NVL(p_complete_rec.accrual_quantity, 0) <= 0 THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_ACCRUAL_NO_QUANTITY');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      --- for a active accrual fund product eligibiilty should exist 01/20/2001 mpande
      -- not when a active fund is created automatically
      IF p_complete_rec.status_code = 'ACTIVE' AND
      p_mode <> jtf_plsql_api.g_create THEN
         Ozf_fundrules_pvt.check_product_elig_exists(
            p_complete_rec.fund_id
           ,l_return_status);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            x_return_status := l_return_status;
         END IF;
      END IF; */
   END IF;

   -- Check for update validations
   IF p_mode = jtf_plsql_api.g_update THEN
      -- mpande added on Sep 11 for giving update access to owner and persons who have access with edit metric flag = 'Y'
      l_resource_id := ozf_utility_pvt.get_resource_id(p_user_id => fnd_global.user_id);

         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message('resource'||ams_access_pvt.check_update_access(p_complete_rec.fund_id, 'FUND', l_resource_id, 'USER'));
         END IF;

      IF l_resource_id <> -1 THEN
         IF ams_access_pvt.check_update_access(
               p_complete_rec.fund_id
              ,'FUND'
              ,l_resource_id
              ,'USER') <>
               'F' THEN
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                IF p_fund_rec.fund_type = 'QUOTA' THEN
                  fnd_message.set_name('OZF', 'OZF_TP_ILLEGAL_OWNER');
                ELSE
                   fnd_message.set_name('OZF', 'OZF_FUND_ILLEGAL_OWNER');
                END IF;
               fnd_msg_pub.add;
            END IF;

            x_return_status := fnd_api.g_ret_sts_error;
         END IF;
      ELSIF l_resource_id = -1 THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_NO_RESOURCE_ID');
            fnd_msg_pub.add;
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      --kdass 10-OCT-05 - R12 bug 4613689 validate accrual budget's ledger and offer's org
      IF p_fund_rec.fund_type = 'FULLY_ACCRUED' AND p_complete_rec.ledger_id IS NOT NULL THEN
         OPEN c_offer_org (p_complete_rec.plan_id);
         FETCH c_offer_org INTO l_offer_org;
         CLOSE c_offer_org;

         IF l_offer_org IS NOT NULL THEN
            -- Get offer's ledger
            MO_UTILS.Get_Ledger_Info (p_operating_unit =>  l_offer_org,
                                      p_ledger_id      =>  l_offer_ledger,
                                      p_ledger_name    =>  l_offer_ledgerName
                                     );
            IF p_complete_rec.ledger_id <> l_offer_ledger THEN
               IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                  fnd_message.set_name('OZF', 'OZF_BUDGET_OFFR_LEDG_MISMATCH');
                  fnd_msg_pub.add;
               END IF;
               x_return_status := fnd_api.g_ret_sts_error;
            END IF;
         END IF;
      END IF;

   END IF;

END check_fund_record;

---------------------------------------------------------------------
-- PROCEDURE
--    check_fund_inter_entity
--
-- HISTORY
--    1/15/01  mpande  Created.
---------------------------------------------------------------------

PROCEDURE check_fund_inter_entity(
   p_fund_rec          IN       fund_rec_type
  ,p_complete_rec      IN       fund_rec_type
  ,p_validation_mode   IN       VARCHAR2
  ,x_return_status     OUT NOCOPY      VARCHAR2)
IS
   l_return_status    VARCHAR2(1);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   ------------------- check calendar ----------------------
   IF    p_fund_rec.fund_calendar <> fnd_api.g_miss_char
      OR p_fund_rec.start_period_name <> fnd_api.g_miss_char
      OR p_fund_rec.end_period_name <> fnd_api.g_miss_char
      OR p_fund_rec.start_date_active <> fnd_api.g_miss_date
      OR p_fund_rec.end_date_active <> fnd_api.g_miss_date THEN
      Ozf_fundrules_pvt.check_fund_calendar(
         p_complete_rec.fund_calendar
        ,p_complete_rec.start_period_name
        ,p_complete_rec.end_period_name
        ,p_complete_rec.start_date_active
        ,p_complete_rec.end_date_active
        ,p_complete_rec.fund_type
        ,l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         x_return_status := l_return_status;
      END IF;
   END IF;

   ------------------- check dates ------------------------------
   IF    p_fund_rec.start_date_active <> fnd_api.g_miss_date
      OR p_fund_rec.end_date_active <> fnd_api.g_miss_date THEN
      Ozf_fundrules_pvt.check_fund_dates_vs_parent(
         p_complete_rec.parent_fund_id
        ,p_complete_rec.start_date_active
        ,p_complete_rec.end_date_active
        ,l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         x_return_status := l_return_status;
      END IF;

      IF p_validation_mode = jtf_plsql_api.g_update THEN
         Ozf_fundrules_pvt.check_fund_dates_vs_child(
            p_complete_rec.fund_id
           ,p_complete_rec.start_date_active
           ,p_complete_rec.end_date_active
           ,l_return_status);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            x_return_status := l_return_status;
         END IF;
      END IF;
   END IF;

   ------------------- check budget amounts ------------------------------
  -- only in planning stage  --07/23/2001 mpande
   IF p_complete_rec.status_code NOT IN ('ACTIVE','ON_HOLD','CANCELLED','ARCHIVED','CLOSED') THEN
   IF    p_fund_rec.original_budget <> fnd_api.g_miss_num
      OR p_fund_rec.transfered_in_amt <> fnd_api.g_miss_num
      OR p_fund_rec.transfered_out_amt <> fnd_api.g_miss_num THEN
         -- updated 09/04/2001 mpande for Multi Currency Child
      Ozf_fundrules_pvt.check_fund_amount_vs_parent(
         p_complete_rec.parent_fund_id
        ,p_complete_rec.currency_code_tc
        ,p_complete_rec.original_budget
        ,l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         x_return_status := l_return_status;
      END IF;

      IF p_validation_mode = jtf_plsql_api.g_update  THEN
         -- updated 09/04/2001 mpande for Multi Currency Child
         Ozf_fundrules_pvt.check_fund_amount_vs_child(
            p_complete_rec.fund_id
           ,p_complete_rec.original_budget
           ,p_complete_rec.transfered_in_amt
           ,p_complete_rec.transfered_out_amt
           ,p_complete_rec.currency_code_tc
           ,l_return_status);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            x_return_status := l_return_status;
         END IF;
      END IF;
   END IF;
   END IF;

   ------------------- check fund type ------------------------------
   IF    p_fund_rec.fund_type <> fnd_api.g_miss_char
      OR p_fund_rec.parent_fund_id <> fnd_api.g_miss_num THEN
      --- the chikd parent validation  is done always
      Ozf_fundrules_pvt.check_fund_type_vs_parent(
         p_complete_rec.parent_fund_id
        ,p_complete_rec.fund_type
        ,l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         x_return_status := l_return_status;
      END IF;

      -- check for change of fund type only when the status is going active
      -- cause in a draft mode the user can change the fund type
      IF     p_validation_mode = jtf_plsql_api.g_update
         AND p_complete_rec.status_code = 'ACTIVE' THEN
         Ozf_fundrules_pvt.check_fund_type_vs_child(
            p_complete_rec.fund_id
           ,p_complete_rec.fund_type
           ,l_return_status);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            x_return_status := l_return_status;
         END IF;
      END IF;
   END IF;

   ------------------- check fund curr ------------------------------
   --09/04/2001 mpande commented
   /*
   IF    p_fund_rec.currency_code_tc <> fnd_api.g_miss_char
      OR p_fund_rec.parent_fund_id <> fnd_api.g_miss_num THEN
      --- the child parent validation  is done always
      Ozf_fundrules_pvt.check_fund_curr_vs_parent(
         p_complete_rec.parent_fund_id
        ,p_complete_rec.currency_code_tc
        ,l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         x_return_status := l_return_status;
      END IF;

      -- check for change of fund currency only when the status is going active
      -- cause in a draft mode the user can change the fund currency
      IF     p_validation_mode = jtf_plsql_api.g_update
         AND p_complete_rec.status_code = 'ACTIVE' THEN
         Ozf_fundrules_pvt.check_fund_curr_vs_child(
            p_complete_rec.fund_id
           ,p_complete_rec.currency_code_tc
           ,l_return_status);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            x_return_status := l_return_status;
         END IF;
      END IF;
   END IF;
   */

   ------------------- check fund_status ------------------------------
   IF    p_fund_rec.status_code <> fnd_api.g_miss_char
      OR p_fund_rec.parent_fund_id <> fnd_api.g_miss_num THEN
      Ozf_fundrules_pvt.check_fund_status_vs_parent(
         p_complete_rec.parent_fund_id
        ,p_complete_rec.status_code
        ,l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         x_return_status := l_return_status;
      END IF;
   END IF;
END check_fund_inter_entity;



---------------------------------------------------------------------
-- PROCEDURE
--    Init_Fund_Rec
--
-- HISTORY
--    02/02/2000  Shitij Vatsa  Create.
---------------------------------------------------------------------
PROCEDURE init_fund_rec(
   x_fund_rec   OUT NOCOPY   fund_rec_type)
IS
BEGIN

   RETURN;
END init_fund_rec;



---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Fund_Rec
--
-- HISTORY
--    02/02/2000  Shitij Vatsa  Create.
---------------------------------------------------------------------
PROCEDURE complete_fund_rec(
   p_fund_rec       IN       fund_rec_type
  ,x_complete_rec   OUT NOCOPY      fund_rec_type)
IS
   CURSOR c_fund
   IS
      SELECT   *
      FROM     ozf_funds_all_vl
      WHERE  fund_id = p_fund_rec.fund_id;

   l_fund_rec    c_fund%ROWTYPE;
BEGIN
   x_complete_rec := p_fund_rec;
   OPEN c_fund;
   FETCH c_fund INTO l_fund_rec;

   IF c_fund%NOTFOUND THEN
      CLOSE c_fund;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         fnd_msg_pub.add;
      END IF;

      RAISE fnd_api.g_exc_error;
   END IF;

   CLOSE c_fund;

   IF p_fund_rec.fund_number = fnd_api.g_miss_char THEN
      x_complete_rec.fund_number := NULL;
   END IF;
   IF p_fund_rec.fund_number IS NULL THEN
      x_complete_rec.fund_number := l_fund_rec.fund_number;
   END IF;

   IF p_fund_rec.parent_fund_id = fnd_api.g_miss_num THEN
      x_complete_rec.parent_fund_id := NULL;
   END IF;
   IF p_fund_rec.parent_fund_id IS NULL THEN
      x_complete_rec.parent_fund_id := l_fund_rec.parent_fund_id;
   END IF;

   IF p_fund_rec.category_id = fnd_api.g_miss_num THEN
      x_complete_rec.category_id := NULL;
   END IF;
   IF p_fund_rec.category_id IS NULL THEN
      x_complete_rec.category_id := l_fund_rec.category_id;
   END IF;

   IF p_fund_rec.fund_type = fnd_api.g_miss_char THEN
      x_complete_rec.fund_type := NULL;
   END IF;
   IF p_fund_rec.fund_type IS NULL THEN
      x_complete_rec.fund_type := l_fund_rec.fund_type;
   END IF;

   IF p_fund_rec.fund_usage = fnd_api.g_miss_char THEN
      x_complete_rec.fund_usage := NULL;
   END IF;
   IF p_fund_rec.fund_usage IS NULL THEN
      x_complete_rec.fund_usage := l_fund_rec.fund_usage;
   END IF;

   IF p_fund_rec.status_code = fnd_api.g_miss_char THEN
      x_complete_rec.status_code := NULL;
   END IF;
   IF p_fund_rec.status_code IS NULL THEN
      x_complete_rec.status_code := l_fund_rec.status_code;
   END IF;

   IF p_fund_rec.user_status_id = fnd_api.g_miss_num THEN
      x_complete_rec.user_status_id := NULL;
   END IF;
   IF p_fund_rec.user_status_id IS NULL THEN
      x_complete_rec.user_status_id := l_fund_rec.user_status_id;
   END IF;

   IF p_fund_rec.status_date = fnd_api.g_miss_date THEN
      x_complete_rec.status_date := NULL;
   END IF;
   IF p_fund_rec.status_date IS NULL THEN
      x_complete_rec.status_date := l_fund_rec.status_date;
   END IF;

   IF p_fund_rec.accrued_liable_account = fnd_api.g_miss_num THEN
      x_complete_rec.accrued_liable_account := NULL;
   END IF;
   IF p_fund_rec.accrued_liable_account IS NULL THEN
      x_complete_rec.accrued_liable_account := l_fund_rec.accrued_liable_account;
   END IF;

   IF p_fund_rec.ded_adjustment_account = fnd_api.g_miss_num THEN
      x_complete_rec.ded_adjustment_account := NULL;
   END IF;
   IF p_fund_rec.ded_adjustment_account IS NULL THEN
      x_complete_rec.ded_adjustment_account := l_fund_rec.ded_adjustment_account;
   END IF;

   IF p_fund_rec.liability_flag = fnd_api.g_miss_char THEN
      x_complete_rec.liability_flag := NULL;
   END IF;
   IF p_fund_rec.liability_flag IS NULL THEN
      x_complete_rec.liability_flag := l_fund_rec.liability_flag;
   END IF;

   IF p_fund_rec.set_of_books_id = fnd_api.g_miss_num THEN
      x_complete_rec.set_of_books_id := NULL;
   END IF;
   IF p_fund_rec.set_of_books_id IS NULL THEN
      x_complete_rec.set_of_books_id := l_fund_rec.set_of_books_id;
   END IF;

   IF p_fund_rec.start_period_id = fnd_api.g_miss_num THEN
      x_complete_rec.start_period_id := NULL;
   END IF;
   IF p_fund_rec.start_period_id IS NULL THEN
      x_complete_rec.start_period_id := l_fund_rec.start_period_id;
   END IF;

   IF p_fund_rec.end_period_id = fnd_api.g_miss_num THEN
      x_complete_rec.end_period_id := NULL;
   END IF;
   IF p_fund_rec.end_period_id IS NULL THEN
      x_complete_rec.end_period_id := l_fund_rec.end_period_id;
   END IF;

   IF p_fund_rec.start_date_active = fnd_api.g_miss_date THEN
      x_complete_rec.start_date_active := NULL;
   END IF;
   IF p_fund_rec.start_date_active IS NULL THEN
      x_complete_rec.start_date_active := l_fund_rec.start_date_active;
   END IF;

   IF p_fund_rec.end_date_active = fnd_api.g_miss_date THEN
      x_complete_rec.end_date_active := NULL;
   END IF;
   IF p_fund_rec.end_date_active IS NULL THEN
      x_complete_rec.end_date_active := l_fund_rec.end_date_active;
   END IF;

   IF p_fund_rec.budget_amount_tc = fnd_api.g_miss_num THEN
      x_complete_rec.budget_amount_tc := NULL;
   END IF;
   IF p_fund_rec.budget_amount_tc IS NULL THEN
      x_complete_rec.budget_amount_tc := l_fund_rec.budget_amount_tc;
   END IF;

   IF p_fund_rec.budget_amount_fc = fnd_api.g_miss_num THEN
      x_complete_rec.budget_amount_fc := NULL;
   END IF;
   IF p_fund_rec.budget_amount_fc IS NULL THEN
      x_complete_rec.budget_amount_fc := l_fund_rec.budget_amount_fc;
   END IF;

   IF p_fund_rec.available_amount = fnd_api.g_miss_num THEN
      x_complete_rec.available_amount := NULL;
   END IF;
   IF p_fund_rec.available_amount IS NULL THEN
      x_complete_rec.available_amount := l_fund_rec.available_amount;
   END IF;

   IF p_fund_rec.distributed_amount = fnd_api.g_miss_num THEN
      x_complete_rec.distributed_amount := NULL;
   END IF;
   IF p_fund_rec.distributed_amount IS NULL THEN
      x_complete_rec.distributed_amount := l_fund_rec.distributed_amount;
   END IF;

   IF p_fund_rec.currency_code_tc = fnd_api.g_miss_char THEN
      x_complete_rec.currency_code_tc := NULL;
   END IF;
   IF p_fund_rec.currency_code_tc IS NULL THEN
      x_complete_rec.currency_code_tc := l_fund_rec.currency_code_tc;
   END IF;

   IF p_fund_rec.currency_code_fc = fnd_api.g_miss_char THEN
      x_complete_rec.currency_code_fc := NULL;
   END IF;
   IF p_fund_rec.currency_code_fc IS NULL THEN
      x_complete_rec.currency_code_fc := l_fund_rec.currency_code_fc;
   END IF;

   IF p_fund_rec.exchange_rate_type = fnd_api.g_miss_char THEN
      x_complete_rec.exchange_rate_type := NULL;
   END IF;
   IF p_fund_rec.exchange_rate_type IS NULL THEN
      x_complete_rec.exchange_rate_type := l_fund_rec.exchange_rate_type;
   END IF;

   IF p_fund_rec.exchange_rate_date = fnd_api.g_miss_date THEN
      x_complete_rec.exchange_rate_date := NULL;
   END IF;
   IF p_fund_rec.exchange_rate_date IS NULL THEN
      x_complete_rec.exchange_rate_date := l_fund_rec.exchange_rate_date;
   END IF;

   IF p_fund_rec.exchange_rate = fnd_api.g_miss_num THEN
      x_complete_rec.exchange_rate := NULL;
   END IF;
   IF p_fund_rec.exchange_rate IS NULL THEN
      x_complete_rec.exchange_rate := l_fund_rec.exchange_rate;
   END IF;

   IF p_fund_rec.department_id = fnd_api.g_miss_num THEN
      x_complete_rec.department_id := NULL;
   END IF;
   IF p_fund_rec.department_id IS NULL THEN
      x_complete_rec.department_id := l_fund_rec.department_id;
   END IF;

   IF p_fund_rec.costcentre_id = fnd_api.g_miss_num THEN
      x_complete_rec.costcentre_id := NULL;
   END IF;
   IF p_fund_rec.costcentre_id IS NULL THEN
      x_complete_rec.costcentre_id := l_fund_rec.costcentre_id;
   END IF;

   IF p_fund_rec.owner = fnd_api.g_miss_num THEN
      x_complete_rec.owner := NULL;
   END IF;
   IF p_fund_rec.owner IS NULL THEN
      x_complete_rec.owner := l_fund_rec.owner;
   END IF;

   IF p_fund_rec.accrual_method = fnd_api.g_miss_char THEN
      x_complete_rec.accrual_method := NULL;
   END IF;
   IF p_fund_rec.accrual_method IS NULL THEN
      x_complete_rec.accrual_method := l_fund_rec.accrual_method;
   END IF;

   IF p_fund_rec.accrual_operand = fnd_api.g_miss_char THEN
      x_complete_rec.accrual_operand := NULL;
   END IF;
   IF p_fund_rec.accrual_operand IS NULL THEN
      x_complete_rec.accrual_operand := l_fund_rec.accrual_operand;
   END IF;

   IF p_fund_rec.accrual_rate = fnd_api.g_miss_num THEN
      x_complete_rec.accrual_rate := NULL;
   END IF;
   IF p_fund_rec.accrual_rate IS NULL THEN
      x_complete_rec.accrual_rate := l_fund_rec.accrual_rate;
   END IF;

   IF p_fund_rec.accrual_basis = fnd_api.g_miss_char THEN
      x_complete_rec.accrual_basis := NULL;
   END IF;
   IF p_fund_rec.accrual_basis IS NULL THEN
      x_complete_rec.accrual_basis := l_fund_rec.accrual_basis;
   END IF;

   IF p_fund_rec.hierarchy = fnd_api.g_miss_char THEN
      x_complete_rec.hierarchy := NULL;
   END IF;
   IF p_fund_rec.hierarchy IS NULL THEN
      x_complete_rec.hierarchy := l_fund_rec.hierarchy;
   END IF;

   IF p_fund_rec.hierarchy_level = fnd_api.g_miss_char THEN
      x_complete_rec.hierarchy_level := NULL;
   END IF;
   IF p_fund_rec.hierarchy_level IS NULL THEN
      x_complete_rec.hierarchy_level := l_fund_rec.hierarchy_level;
   END IF;

   IF p_fund_rec.hierarchy_id = fnd_api.g_miss_num THEN
      x_complete_rec.hierarchy_id := NULL;
   END IF;
   IF p_fund_rec.hierarchy_id IS NULL THEN
      x_complete_rec.hierarchy_id := l_fund_rec.hierarchy_id;
   END IF;

   IF p_fund_rec.parent_node_id = fnd_api.g_miss_num THEN
      x_complete_rec.parent_node_id := NULL;
   END IF;
   IF p_fund_rec.parent_node_id IS NULL THEN
      x_complete_rec.parent_node_id := l_fund_rec.parent_node_id;
   END IF;

   IF p_fund_rec.node_id = fnd_api.g_miss_num THEN
      x_complete_rec.node_id := NULL;
   END IF;
   IF p_fund_rec.node_id IS NULL THEN
      x_complete_rec.node_id := l_fund_rec.node_id;
   END IF;

   IF p_fund_rec.budget_flag = fnd_api.g_miss_char THEN
      x_complete_rec.budget_flag := NULL;
   END IF;
   IF p_fund_rec.budget_flag IS NULL THEN
      x_complete_rec.budget_flag := l_fund_rec.budget_flag;
   END IF;

   IF p_fund_rec.earned_flag = fnd_api.g_miss_char THEN
      x_complete_rec.earned_flag := NULL;
   END IF;
   IF p_fund_rec.earned_flag IS NULL THEN
      x_complete_rec.earned_flag := l_fund_rec.earned_flag;
   END IF;

   IF p_fund_rec.apply_accrual_on = fnd_api.g_miss_char THEN
      x_complete_rec.apply_accrual_on := NULL;
   END IF;
   IF p_fund_rec.apply_accrual_on IS NULL THEN
      x_complete_rec.apply_accrual_on := l_fund_rec.apply_accrual_on;
   END IF;

   IF p_fund_rec.accrual_phase = fnd_api.g_miss_char THEN
      x_complete_rec.accrual_phase := NULL;
   END IF;
   IF p_fund_rec.accrual_phase IS NULL THEN
      x_complete_rec.accrual_phase := l_fund_rec.accrual_phase;
   END IF;

   IF p_fund_rec.accrual_cap = fnd_api.g_miss_num THEN
      x_complete_rec.accrual_cap := NULL;
   END IF;
   IF p_fund_rec.accrual_cap IS NULL THEN
      x_complete_rec.accrual_cap := l_fund_rec.accrual_cap;
   END IF;

   IF p_fund_rec.accrual_uom = fnd_api.g_miss_char THEN
      x_complete_rec.accrual_uom := NULL;
   END IF;
   IF p_fund_rec.accrual_uom IS NULL THEN
      x_complete_rec.accrual_uom := l_fund_rec.accrual_uom;
   END IF;


   IF p_fund_rec.recal_committed = fnd_api.g_miss_num THEN
      x_complete_rec.recal_committed := NULL;
   END IF;
   IF p_fund_rec.recal_committed IS NULL THEN
      x_complete_rec.recal_committed := l_fund_rec.recal_committed;
   END IF;


   IF p_fund_rec.attribute_category = fnd_api.g_miss_char THEN
      x_complete_rec.attribute_category := NULL;
   END IF;
   IF p_fund_rec.attribute_category IS NULL THEN
      x_complete_rec.attribute_category := l_fund_rec.attribute_category;
   END IF;

   IF p_fund_rec.attribute1 = fnd_api.g_miss_char THEN
      x_complete_rec.attribute1 := NULL;
   END IF;
   IF p_fund_rec.attribute1 IS NULL THEN
      x_complete_rec.attribute1 := l_fund_rec.attribute1;
   END IF;

   IF p_fund_rec.attribute2 = fnd_api.g_miss_char THEN
      x_complete_rec.attribute2 := NULL;
   END IF;
   IF p_fund_rec.attribute2 IS NULL THEN
      x_complete_rec.attribute2 := l_fund_rec.attribute2;
   END IF;

   IF p_fund_rec.attribute3 = fnd_api.g_miss_char THEN
      x_complete_rec.attribute3 := NULL;
   END IF;
   IF p_fund_rec.attribute3 IS NULL THEN
      x_complete_rec.attribute3 := l_fund_rec.attribute3;
   END IF;

   IF p_fund_rec.attribute4 = fnd_api.g_miss_char THEN
      x_complete_rec.attribute4 := NULL;
   END IF;
   IF p_fund_rec.attribute4 IS NULL THEN
      x_complete_rec.attribute4 := l_fund_rec.attribute4;
   END IF;

   IF p_fund_rec.attribute5 = fnd_api.g_miss_char THEN
      x_complete_rec.attribute5 := NULL;
   END IF;
   IF p_fund_rec.attribute5 IS NULL THEN
      x_complete_rec.attribute5 := l_fund_rec.attribute5;
   END IF;

   IF p_fund_rec.attribute6 = fnd_api.g_miss_char THEN
      x_complete_rec.attribute6 := NULL;
   END IF;
   IF p_fund_rec.attribute6 IS NULL THEN
      x_complete_rec.attribute6 := l_fund_rec.attribute6;
   END IF;

   IF p_fund_rec.attribute7 = fnd_api.g_miss_char THEN
      x_complete_rec.attribute7 := NULL;
   END IF;
   IF p_fund_rec.attribute7 IS NULL THEN
      x_complete_rec.attribute7 := l_fund_rec.attribute7;
   END IF;

   IF p_fund_rec.attribute8 = fnd_api.g_miss_char THEN
      x_complete_rec.attribute8 := NULL;
   END IF;
   IF p_fund_rec.attribute8 IS NULL THEN
      x_complete_rec.attribute8 := l_fund_rec.attribute8;
   END IF;

   IF p_fund_rec.attribute9 = fnd_api.g_miss_char THEN
      x_complete_rec.attribute9 := NULL;
   END IF;
   IF p_fund_rec.attribute9 IS NULL THEN
      x_complete_rec.attribute9 := l_fund_rec.attribute9;
   END IF;

   IF p_fund_rec.attribute10 = fnd_api.g_miss_char THEN
      x_complete_rec.attribute10 := NULL;
   END IF;
   IF p_fund_rec.attribute10 IS NULL THEN
      x_complete_rec.attribute10 := l_fund_rec.attribute10;
   END IF;

   IF p_fund_rec.attribute11 = fnd_api.g_miss_char THEN
      x_complete_rec.attribute11 := NULL;
   END IF;
   IF p_fund_rec.attribute11 IS NULL THEN
      x_complete_rec.attribute11 := l_fund_rec.attribute11;
   END IF;

   IF p_fund_rec.attribute12 = fnd_api.g_miss_char THEN
      x_complete_rec.attribute12 := NULL;
   END IF;
   IF p_fund_rec.attribute12 IS NULL THEN
      x_complete_rec.attribute12 := l_fund_rec.attribute12;
   END IF;

   IF p_fund_rec.attribute13 = fnd_api.g_miss_char THEN
      x_complete_rec.attribute13 := NULL;
   END IF;
   IF p_fund_rec.attribute13 IS NULL THEN
      x_complete_rec.attribute13 := l_fund_rec.attribute13;
   END IF;

   IF p_fund_rec.attribute14 = fnd_api.g_miss_char THEN
      x_complete_rec.attribute14 := NULL;
   END IF;
   IF p_fund_rec.attribute14 IS NULL THEN
      x_complete_rec.attribute14 := l_fund_rec.attribute14;
   END IF;

   IF p_fund_rec.attribute15 = fnd_api.g_miss_char THEN
      x_complete_rec.attribute15 := NULL;
   END IF;
   IF p_fund_rec.attribute15 IS NULL THEN
      x_complete_rec.attribute15 := l_fund_rec.attribute15;
   END IF;

   IF p_fund_rec.original_budget = fnd_api.g_miss_num THEN
      x_complete_rec.original_budget := NULL;
   END IF;
   IF p_fund_rec.original_budget IS NULL THEN
      x_complete_rec.original_budget := l_fund_rec.original_budget;
   END IF;

   IF p_fund_rec.transfered_in_amt = fnd_api.g_miss_num THEN
      x_complete_rec.transfered_in_amt := NULL;
   END IF;
   IF p_fund_rec.transfered_in_amt IS NULL THEN
      x_complete_rec.transfered_in_amt := l_fund_rec.transfered_in_amt;
   END IF;

   IF p_fund_rec.transfered_out_amt = fnd_api.g_miss_num THEN
      x_complete_rec.transfered_out_amt := NULL;
   END IF;
   IF p_fund_rec.transfered_out_amt IS NULL THEN
      x_complete_rec.transfered_out_amt := l_fund_rec.transfered_out_amt;
   END IF;

   IF p_fund_rec.holdback_amt = fnd_api.g_miss_num THEN
      x_complete_rec.holdback_amt := NULL;
   END IF;
   IF p_fund_rec.holdback_amt IS NULL THEN
      x_complete_rec.holdback_amt := l_fund_rec.holdback_amt;
   END IF;

   IF p_fund_rec.planned_amt = fnd_api.g_miss_num THEN
      x_complete_rec.planned_amt := NULL;
   END IF;
   IF p_fund_rec.planned_amt IS NULL THEN
      x_complete_rec.planned_amt := l_fund_rec.planned_amt;
   END IF;

   IF p_fund_rec.committed_amt = fnd_api.g_miss_num THEN
      x_complete_rec.committed_amt := NULL;
   END IF;
   IF p_fund_rec.committed_amt IS NULL THEN
      x_complete_rec.committed_amt := l_fund_rec.committed_amt;
   END IF;

   -- yzhao: 11.5.10
   IF p_fund_rec.utilized_amt = fnd_api.g_miss_num THEN
      x_complete_rec.utilized_amt := NULL;
   END IF;
   IF p_fund_rec.utilized_amt IS NULL THEN
      x_complete_rec.utilized_amt := l_fund_rec.utilized_amt;
   END IF;

   IF p_fund_rec.earned_amt = fnd_api.g_miss_num THEN
      x_complete_rec.earned_amt := NULL;
   END IF;
   IF p_fund_rec.earned_amt IS NULL THEN
      x_complete_rec.earned_amt := l_fund_rec.earned_amt;
   END IF;

   IF p_fund_rec.paid_amt = fnd_api.g_miss_num THEN
      x_complete_rec.paid_amt := NULL;
   END IF;
   IF p_fund_rec.paid_amt IS NULL THEN
      x_complete_rec.paid_amt := l_fund_rec.paid_amt;
   END IF;

   IF p_fund_rec.plan_type = fnd_api.g_miss_char THEN
      x_complete_rec.plan_type := NULL;
   END IF;
   IF p_fund_rec.plan_type IS NULL THEN
      x_complete_rec.plan_type := l_fund_rec.plan_type;
   END IF;

   IF p_fund_rec.plan_id = fnd_api.g_miss_num THEN
      x_complete_rec.plan_id := NULL;
   END IF;
   IF p_fund_rec.plan_id IS NULL THEN
      x_complete_rec.plan_id := l_fund_rec.plan_id;
   END IF;

   IF p_fund_rec.liable_accnt_segments = fnd_api.g_miss_char THEN
      x_complete_rec.liable_accnt_segments := NULL;
   END IF;
   IF p_fund_rec.liable_accnt_segments IS NULL THEN
      x_complete_rec.liable_accnt_segments := l_fund_rec.liable_accnt_segments;
   END IF;

   IF p_fund_rec.adjustment_accnt_segments = fnd_api.g_miss_char THEN
      x_complete_rec.adjustment_accnt_segments := NULL;
   END IF;
   IF p_fund_rec.adjustment_accnt_segments IS NULL THEN
      x_complete_rec.adjustment_accnt_segments := l_fund_rec.adjustment_accnt_segments;
   END IF;

   IF p_fund_rec.short_name = fnd_api.g_miss_char THEN
      x_complete_rec.short_name := NULL;
   END IF;
   IF p_fund_rec.short_name IS NULL THEN
      x_complete_rec.short_name := l_fund_rec.short_name;
   END IF;

   IF p_fund_rec.description = fnd_api.g_miss_char THEN
      x_complete_rec.description := NULL;
   END IF;
   IF p_fund_rec.description IS NULL THEN
      x_complete_rec.description := l_fund_rec.description;
   END IF;
   --08/28/2001 mpande bug#1950117
   /*
   IF p_fund_rec.language = fnd_api.g_miss_char THEN
      x_complete_rec.language := NULL;
   END IF;
   IF p_fund_rec.language IS NULL THEN
      x_complete_rec.language := l_fund_rec.language;
   END IF;

   IF p_fund_rec.source_lang = fnd_api.g_miss_char THEN
      x_complete_rec.source_lang := NULL;
   END IF;
   IF p_fund_rec.source_lang IS NULL THEN
      x_complete_rec.source_lang := l_fund_rec.source_lang;
   END IF;
   */
   IF p_fund_rec.fund_calendar = fnd_api.g_miss_char THEN
      x_complete_rec.fund_calendar := NULL;
   END IF;
   IF p_fund_rec.fund_calendar IS NULL THEN
      x_complete_rec.fund_calendar := l_fund_rec.fund_calendar;
   END IF;

   IF p_fund_rec.start_period_name = fnd_api.g_miss_char THEN
      x_complete_rec.start_period_name := NULL;
   END IF;
   IF p_fund_rec.start_period_name IS NULL THEN
      x_complete_rec.start_period_name := l_fund_rec.start_period_name;
   END IF;

   IF p_fund_rec.end_period_name = fnd_api.g_miss_char THEN
      x_complete_rec.end_period_name := NULL;
   END IF;
   IF p_fund_rec.end_period_name IS NULL THEN
      x_complete_rec.end_period_name := l_fund_rec.end_period_name;
   END IF;

   IF p_fund_rec.accrual_quantity = fnd_api.g_miss_num THEN
      x_complete_rec.accrual_quantity := NULL;
   END IF;
   IF p_fund_rec.accrual_quantity IS NULL THEN
      x_complete_rec.accrual_quantity := l_fund_rec.accrual_quantity;
   END IF;

   IF p_fund_rec.accrue_to_level_id = fnd_api.g_miss_num THEN
      x_complete_rec.accrue_to_level_id := NULL;
   END IF;
   IF p_fund_rec.accrue_to_level_id IS NULL THEN
      x_complete_rec.accrue_to_level_id := l_fund_rec.accrue_to_level_id;
   END IF;

   IF p_fund_rec.accrual_discount_level = fnd_api.g_miss_char THEN
      x_complete_rec.accrual_discount_level := NULL;
   END IF;
   IF p_fund_rec.accrual_discount_level IS NULL THEN
      x_complete_rec.accrual_discount_level := l_fund_rec.accrual_discount_level;
   END IF;
   IF p_fund_rec.custom_setup_id = fnd_api.g_miss_num THEN
      x_complete_rec.custom_setup_id := NULL;
   END IF;
   IF p_fund_rec.custom_setup_id IS NULL THEN
      x_complete_rec.custom_setup_id := l_fund_rec.custom_setup_id;
   END IF;
   IF p_fund_rec.threshold_id = fnd_api.g_miss_num THEN
      x_complete_rec.threshold_id := NULL;
   END IF;
   IF p_fund_rec.threshold_id IS NULL THEN
      x_complete_rec.threshold_id := l_fund_rec.threshold_id;
   END IF;
   IF p_fund_rec.business_unit_id = fnd_api.g_miss_num THEN
      x_complete_rec.business_unit_id := NULL;
   END IF;
   IF p_fund_rec.business_unit_id IS NULL THEN
      x_complete_rec.business_unit_id := l_fund_rec.business_unit_id;
   END IF;
   IF p_fund_rec.task_id = fnd_api.g_miss_num THEN
      x_complete_rec.task_id := NULL;
   END IF;
   IF p_fund_rec.task_id IS NULL THEN
      x_complete_rec.task_id := l_fund_rec.task_id;
   END IF;
   IF p_fund_rec.country_id = fnd_api.g_miss_num THEN
      x_complete_rec.country_id := NULL;
   END IF;
   IF p_fund_rec.country_id IS NULL THEN
      x_complete_rec.country_id := l_fund_rec.country_id;
   END IF;
 -- added by feliu 02/08/2002 for rollup amount columns
    IF p_fund_rec.rollup_original_budget = fnd_api.g_miss_num THEN
      x_complete_rec.rollup_original_budget := NULL;
   END IF;
    IF p_fund_rec.rollup_original_budget IS NULL THEN
      x_complete_rec.rollup_original_budget := l_fund_rec.rollup_original_budget;
   END IF;
   IF p_fund_rec.rollup_holdback_amt = fnd_api.g_miss_num THEN
      x_complete_rec.rollup_holdback_amt := NULL;
   END IF;
   IF p_fund_rec.rollup_holdback_amt IS NULL THEN
      x_complete_rec.rollup_holdback_amt := l_fund_rec.rollup_holdback_amt;
   END IF;
   IF p_fund_rec.rollup_transfered_in_amt = fnd_api.g_miss_num THEN
      x_complete_rec.rollup_transfered_in_amt := NULL;
   END IF;
   IF p_fund_rec.rollup_transfered_in_amt IS NULL THEN
      x_complete_rec.rollup_transfered_in_amt := l_fund_rec.rollup_transfered_in_amt;
   END IF;
   IF p_fund_rec.rollup_transfered_out_amt = fnd_api.g_miss_num THEN
      x_complete_rec.rollup_transfered_out_amt := NULL;
   END IF;
   IF p_fund_rec.rollup_transfered_out_amt IS NULL THEN
      x_complete_rec.rollup_transfered_out_amt := l_fund_rec.rollup_transfered_out_amt;
   END IF;
   IF p_fund_rec.rollup_planned_amt = fnd_api.g_miss_num THEN
      x_complete_rec.rollup_planned_amt := NULL;
   END IF;
   IF p_fund_rec.rollup_planned_amt IS NULL THEN
      x_complete_rec.rollup_planned_amt := l_fund_rec.rollup_planned_amt;
   END IF;
   IF p_fund_rec.rollup_committed_amt = fnd_api.g_miss_num THEN
      x_complete_rec.rollup_committed_amt := NULL;
   END IF;
   IF p_fund_rec.rollup_committed_amt IS NULL THEN
      x_complete_rec.rollup_committed_amt := l_fund_rec.rollup_committed_amt;
   END IF;
   -- yzhao: 11.5.10
   IF p_fund_rec.rollup_utilized_amt = fnd_api.g_miss_num THEN
      x_complete_rec.rollup_utilized_amt := NULL;
   END IF;
   IF p_fund_rec.rollup_utilized_amt IS NULL THEN
      x_complete_rec.rollup_utilized_amt := l_fund_rec.rollup_utilized_amt;
   END IF;
   IF p_fund_rec.rollup_earned_amt = fnd_api.g_miss_num THEN
      x_complete_rec.rollup_earned_amt := NULL;
   END IF;
   IF p_fund_rec.rollup_earned_amt IS NULL THEN
      x_complete_rec.rollup_earned_amt := l_fund_rec.rollup_earned_amt;
   END IF;
   IF p_fund_rec.rollup_paid_amt = fnd_api.g_miss_num THEN
      x_complete_rec.rollup_paid_amt := NULL;
   END IF;
   IF p_fund_rec.rollup_paid_amt IS NULL THEN
      x_complete_rec.rollup_paid_amt := l_fund_rec.rollup_paid_amt;
   END IF;
   IF p_fund_rec.rollup_recal_committed  = fnd_api.g_miss_num THEN
      x_complete_rec.rollup_recal_committed  := NULL;
   END IF;
   IF p_fund_rec.rollup_recal_committed  IS NULL THEN
      x_complete_rec.rollup_recal_committed  := l_fund_rec.rollup_recal_committed ;
   END IF;
    IF p_fund_rec.retroactive_flag  = fnd_api.g_miss_char THEN
       x_complete_rec.retroactive_flag  := NULL;
    END IF;
    IF p_fund_rec.retroactive_flag  IS NULL THEN
       x_complete_rec.retroactive_flag  := l_fund_rec.retroactive_flag ;
    END IF;
    IF p_fund_rec.qualifier_id  = fnd_api.g_miss_num THEN
       x_complete_rec.qualifier_id  := NULL;
    END IF;
    IF p_fund_rec.qualifier_id  IS NULL THEN
       x_complete_rec.qualifier_id  := l_fund_rec.qualifier_id;
    END IF;

    -- niprakas added
    IF p_fund_rec.prev_fund_id  = fnd_api.g_miss_num THEN
       x_complete_rec.prev_fund_id  := NULL;
    END IF;
    IF p_fund_rec.prev_fund_id IS NULL THEN
      x_complete_rec.prev_fund_id := l_fund_rec.prev_fund_id;
    END IF;

    -- niprakas added

    IF p_fund_rec.transfered_flag  = fnd_api.g_miss_char THEN
       x_complete_rec.transfered_flag  := NULL;
    END IF;
    IF p_fund_rec.transfered_flag IS NULL THEN
      x_complete_rec.transfered_flag := l_fund_rec.transfered_flag;
    END IF;

     -- niprakas added
    IF p_fund_rec.utilized_amt  = fnd_api.g_miss_num THEN
       x_complete_rec.utilized_amt  := NULL;
    END IF;
    IF p_fund_rec.utilized_amt = fnd_api.g_miss_num THEN
      x_complete_rec.utilized_amt := l_fund_rec.utilized_amt;
    END IF;

    -- niprakas added
    IF p_fund_rec.rollup_utilized_amt  = fnd_api.g_miss_num THEN
       x_complete_rec.rollup_utilized_amt  := NULL;
    END IF;
    IF p_fund_rec.rollup_utilized_amt = fnd_api.g_miss_num THEN
      x_complete_rec.rollup_utilized_amt := l_fund_rec.rollup_utilized_amt;
    END IF;

        --kdass added
    IF p_fund_rec.product_spread_time_id  = fnd_api.g_miss_num THEN
       x_complete_rec.product_spread_time_id  := NULL;
    END IF;
    IF p_fund_rec.product_spread_time_id IS NULL THEN
      x_complete_rec.product_spread_time_id := l_fund_rec.product_spread_time_id;
    END IF;

    --kdass - R12 MOAC changes
    IF p_fund_rec.org_id  = fnd_api.g_miss_num THEN
       x_complete_rec.org_id  := NULL;
    END IF;
    IF p_fund_rec.org_id IS NULL THEN
      x_complete_rec.org_id := l_fund_rec.org_id;
    END IF;

    IF p_fund_rec.ledger_id  = fnd_api.g_miss_num THEN
       x_complete_rec.ledger_id  := NULL;
    END IF;
    IF p_fund_rec.ledger_id IS NULL THEN
      x_complete_rec.ledger_id := l_fund_rec.ledger_id;
    END IF;

END complete_fund_rec;


-- ADDED FOR R2 Requirements to get default GL info--- by mpande //6th JULY-2000
---------------------------------------------------------------------
-- PROCEDURE
--    GET_DEFAULT_GL_INFO
--
-- PURPOSE : A fund should always have a category . When creating a category the user can
--           give the GL info 1) ACCRUED_LIABILITY_ACCOUNT 2) DED_ADJUSTMENT_ACCOUNT
--          When the user is creating a fund the funds API should pickup
--         the default GL INFO from the associated category of the fund if the user has not passed anything.
--        This API gets the defauls GL INFO.
-- PARAMETERS
--  p_category_id    IN  NUMBER,
--   p_accrued_liability_account  IN OUT  NUMBER -- if null will deafult it otherwise will return whatever was passed
--   p_ded_adjustment_account     IN OUT  NUMBER,-- if null will deafult it otherwise will return whatever was passed
--   x_return_status              OUT VARCHAR2
--  Created  by mpande 07/07/2000
---------------------------------------------------------------------
PROCEDURE complete_default_gl_info(
   p_category_id                 IN       NUMBER
  ,p_accrued_liability_account   IN OUT NOCOPY   NUMBER
  ,p_ded_adjustment_account      IN OUT NOCOPY   NUMBER
  ,x_return_status               OUT NOCOPY      VARCHAR2)
IS
   CURSOR c_gl_info(
      p_cat_id   IN   NUMBER)
   IS
      SELECT   accrued_liability_account
              ,ded_adjustment_account
      FROM     ams_categories_vl
      WHERE  category_id = p_cat_id;

   l_accrued_liability_account    NUMBER;
   l_ded_adjustment_account       NUMBER;
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
   OPEN c_gl_info(p_category_id);
   FETCH c_gl_info INTO l_accrued_liability_account, l_ded_adjustment_account;
   CLOSE c_gl_info;

   --- if p_categroy_id is null then return null----
   IF p_category_id IS NULL THEN
      x_return_status := fnd_api.g_ret_sts_success;
   ELSIF p_category_id IS NOT NULL THEN
      IF p_accrued_liability_account IS NULL THEN   --if present keep the value else default it
         p_accrued_liability_account := l_accrued_liability_account;
      END IF;

      IF p_ded_adjustment_account IS NULL THEN   --if present keep the value else default it
         p_ded_adjustment_account := l_ded_adjustment_account;
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
END complete_default_gl_info;


-- 14-May-2001 feliu  added for copy function.
---------------------------------------------------------------------
-- PROCEDURE
--    copy_fund
--
-- PURPOSE : -- Copy is broken into 4 sections:
--    - copy all required fields of the object
--    - copy all fields passed in thru the UI, but
--      use the value of the base object if the field
--      isn't passed through the UI
--    - copy all fields passed in thru the UI, but
--      leave the field as null if it isn't passed in
--    - copy all attributes passed in from the UI
-- PARAMETERS
--   p_source_object_id: Original object id,
--   p_attributes_table: AMS_CpyUtility_PVT.copy_attributes_table_type,
--   p_copy_columns_table: AMS_CpyUtility_PVT.copy_columns_table_type,
--   x_new_object_id: New object Id.
--   x_custom_setup_id: custom_setup_id.
---------------------------------------------------------------------
PROCEDURE copy_fund (
   p_api_version        IN NUMBER,
   p_init_msg_list      IN VARCHAR2 := FND_API.G_FALSE,
   p_commit             IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,
   p_source_object_id   IN NUMBER,
   p_attributes_table   IN AMS_CpyUtility_PVT.copy_attributes_table_type,
   p_copy_columns_table IN AMS_CpyUtility_PVT.copy_columns_table_type,
   x_new_object_id      OUT NOCOPY NUMBER,
   x_custom_setup_id    OUT NOCOPY NUMBER
)
IS
   L_API_NAME           CONSTANT VARCHAR2(30) := 'copy_fund';
   L_API_VERSION_NUMBER CONSTANT NUMBER := 1.0;
   L_OBJECT_TYPE_FUND        CONSTANT VARCHAR2(30) := 'FUND';
   L_FUND_STATUS_TYPE        CONSTANT VARCHAR2(30) := 'OZF_FUND_STATUS';
   L_DEFAULT_STATUS           CONSTANT VARCHAR2(30) := 'DRAFT';
   l_return_status            VARCHAR2(1);

   l_new_fund_id    NUMBER;
   l_fund_rec       fund_rec_type;

   -- for non-standard out params in copy_act_access
   l_errnum          NUMBER;
   l_errcode         VARCHAR2(30);
   l_errmsg          VARCHAR2(4000);

   CURSOR c_fund (p_fund_id IN NUMBER) IS
      SELECT *
      FROM   ozf_funds_all_vl
      WHERE  fund_id = p_fund_id
      ;
   CURSOR c_user_status_id (p_status_type IN VARCHAR2, p_status_code IN VARCHAR2) IS
      SELECT user_status_id
      FROM   ams_user_statuses_b
      WHERE  system_status_type = p_status_type
      AND    system_status_code = p_status_code
      AND    default_flag = 'Y'
      AND    enabled_flag = 'Y'
   ;
   l_reference_rec      c_fund%ROWTYPE;
   l_new_fund_rec      c_fund%ROWTYPE;
   l_offer_custsetup  NUMBER;
   l_plan_id          NUMBER;
   l_attr_table      AMS_CpyUtility_PVT.copy_attributes_table_type;
   l_copy_columns_table  AMS_CpyUtility_PVT.copy_columns_table_type;

   -- julou: get custom_setup_id for FAB offer. bug fix for copy offer enhancement
   CURSOR c_custom_setup_id(p_obj_id NUMBER) IS
   SELECT custom_setup_id
   FROM   ozf_offers
   WHERE  qp_list_header_id = p_obj_id;
   -- julou: end

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT copy_fund;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF G_DEBUG THEN
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Start of API body.
   --
   -- Initialize the new fund record
   -- use ams_cpyutility_pvt.get_column_value to fetch a value
   -- to replace the reference column value with a new value
   -- passed in from the UI through p_copy_columns_table.
   OPEN c_fund (p_source_object_id);
   FETCH c_fund INTO l_reference_rec;
   CLOSE c_fund;

   -- copy all required fields
   l_fund_rec.fund_type := l_reference_rec.fund_type;
   l_fund_rec.fund_number := null;
   l_fund_rec.status_code := L_DEFAULT_STATUS;
   l_fund_rec.category_id := l_reference_rec.category_id;
   l_fund_rec.currency_code_tc := l_reference_rec.currency_code_tc;

   -- 08/13/2004  kdass when the budget has a parent budget, then the original budget amount is 0, so copy budget gives error.
   -- l_fund_rec.original_budget := l_reference_rec.original_budget;
   l_fund_rec.original_budget :=   NVL(l_reference_rec.original_budget, 0)
                                 + NVL(l_reference_rec.transfered_in_amt, 0)
                                 - NVL(l_reference_rec.transfered_out_amt, 0);

   l_fund_rec.custom_setup_id := l_reference_rec.custom_setup_id;
   l_fund_rec.accrual_rate := l_reference_rec.accrual_rate;
   l_fund_rec.accrual_basis := l_reference_rec.accrual_basis;
   l_fund_rec.country_id := l_reference_rec.country_id;
   l_fund_rec.holdback_amt := l_reference_rec.holdback_amt;

   -- kdass R12 Bug 4621165 - copy org_id and ledger_id to the new budget
   l_fund_rec.org_id := l_reference_rec.org_id;
   l_fund_rec.ledger_id := l_reference_rec.ledger_id;

   -- 10/22/2001 mpande added to copy all other accrual parameters and not copy org budget for fully accrued
   IF l_fund_rec.fund_type = 'FULLY_ACCRUED' THEN
      l_fund_rec.original_budget := 0;
      l_fund_rec.plan_type := 'OFFR';
   END IF;

   l_fund_rec.apply_accrual_on := l_reference_rec.apply_accrual_on;
   l_fund_rec.accrual_quantity := l_reference_rec.accrual_quantity;
   l_fund_rec.retroactive_flag := l_reference_rec.retroactive_flag;
   l_fund_rec.qualifier_id := l_reference_rec.qualifier_id;
   l_fund_rec.accrue_to_level_id := l_reference_rec.accrue_to_level_id;
   l_fund_rec.business_unit_id := l_reference_rec.business_unit_id;
   l_fund_rec.accrual_method := l_reference_rec.accrual_method;
   l_fund_rec.liability_flag := l_reference_rec.liability_flag;
   l_fund_rec.accrual_operand := l_reference_rec.accrual_operand;
   l_fund_rec.accrual_discount_level := l_reference_rec.accrual_discount_level;
   l_fund_rec.liability_flag := l_reference_rec.liability_flag;
   l_fund_rec.accrual_cap := l_reference_rec.accrual_cap;
   l_fund_rec.accrual_method := l_reference_rec.accrual_method;

   -- 02/05/2003 yzhao fix bug 2788123 MKTF1R9:1159.0204:FUNC:COPY BUDGET THROWING ERROR OZF_ACCRUAL_NO_PHASE
   l_fund_rec.accrual_phase := l_reference_rec.accrual_phase;
   l_fund_rec.accrual_uom := l_reference_rec.accrual_uom;
   -- 02/05/2003 yzhao fix bug 2788123 ends

   --asylvia fixed bug 5169099 - Activity copied to new budget.
   l_fund_rec.task_id := l_reference_rec.task_id;
   --asylvia start bug 5107243
   l_fund_rec.parent_fund_id := l_reference_rec.parent_fund_id ;
   l_fund_rec.accrued_liable_account := l_reference_rec.accrued_liable_account;
   l_fund_rec.ded_adjustment_account := l_reference_rec.ded_adjustment_account;
   l_fund_rec.description := l_reference_rec.description;
   l_fund_rec.threshold_id := l_reference_rec.threshold_id;
   --l_fund_rec.start_period_id:= l_reference_rec.start_period_id;
   --l_fund_rec.end_period_id:= l_reference_rec.end_period_id;
   --l_fund_rec.end_date_active := NVL (l_fund_rec.end_date_active, l_reference_rec.end_date_active);
   l_fund_rec.attribute_category :=  l_reference_rec.attribute_category;
   l_fund_rec.attribute1 := l_reference_rec.attribute1;
   l_fund_rec.attribute2 := l_reference_rec.attribute2;
   l_fund_rec.attribute3 := l_reference_rec.attribute3;
   l_fund_rec.attribute4 := l_reference_rec.attribute4;
   l_fund_rec.attribute5 := l_reference_rec.attribute5;
   l_fund_rec.attribute6 := l_reference_rec.attribute6;
   l_fund_rec.attribute7 := l_reference_rec.attribute7;
   l_fund_rec.attribute8 := l_reference_rec.attribute8;
   l_fund_rec.attribute9 := l_reference_rec.attribute9;
   l_fund_rec.attribute10 := l_reference_rec.attribute10;
   l_fund_rec.attribute11 := l_reference_rec.attribute11;
   l_fund_rec.attribute12 := l_reference_rec.attribute12;
   l_fund_rec.attribute13 := l_reference_rec.attribute13;
   l_fund_rec.attribute14 := l_reference_rec.attribute14;
   l_fund_rec.attribute15 := l_reference_rec.attribute15;
   --asylvia end bug 5107243

   OPEN c_user_status_id (L_FUND_STATUS_TYPE, l_fund_rec.status_code);
   FETCH c_user_status_id INTO l_fund_rec.user_status_id;
   CLOSE c_user_status_id;
   l_fund_rec.currency_code_tc := l_reference_rec.currency_code_tc;

   -- if field is not passed in from copy_columns_table
   -- copy from the base object
   AMS_CpyUtility_PVT.get_column_value ('ownerId', p_copy_columns_table, l_fund_rec.owner);
   l_fund_rec.owner := NVL (l_fund_rec.owner, l_reference_rec.owner);

   AMS_CpyUtility_PVT.get_column_value ('startDate', p_copy_columns_table, l_fund_rec.start_date_active);
   l_fund_rec.start_date_active := NVL (l_fund_rec.start_date_active, l_reference_rec.start_date_active);

   -- if field is not passed in from copy_columns_table
   -- don't copy
   AMS_CpyUtility_PVT.get_column_value ('newObjName', p_copy_columns_table, l_fund_rec.short_name);

   IF l_fund_rec.fund_type = 'FULLY_ACCRUED' THEN
        -- to fix bug 3240787
      IF l_fund_rec.parent_fund_id IS NULL  THEN
            l_fund_rec.fund_number :=
               ams_sourcecode_pvt.get_source_code(
                  p_category_id => l_fund_rec.category_id
                 ,p_arc_object_for => 'FUND');
      ELSE
         get_child_source_code(
            l_fund_rec.parent_fund_id
           ,l_fund_rec.fund_number
           ,x_return_status);
         IF x_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;
      -- to fix bug 3240787

      l_attr_table(1) := 'DETL';
      l_attr_table(2) := 'ELIG';
      l_copy_columns_table(1).column_name := 'offerCode';
      l_copy_columns_table(1).column_value := l_fund_rec.fund_number;
      l_copy_columns_table(2).column_name := 'startDateActive';
      l_copy_columns_table(2).column_value := l_fund_rec.start_date_active;
      l_copy_columns_table(3).column_name := 'endDateActive';
      l_copy_columns_table(3).column_value := '';
      l_copy_columns_table(4).column_name := 'ownerId';
      l_copy_columns_table(4).column_value := l_fund_rec.owner;
      l_copy_columns_table(5).column_name := 'description';
      l_copy_columns_table(5).column_value := '';
      l_copy_columns_table(6).column_name :='newObjName';
      l_copy_columns_table(6).column_value := l_fund_rec.short_name;

      OPEN  c_custom_setup_id(l_reference_rec.plan_id);
      FETCH c_custom_setup_id INTO l_offer_custsetup;
      CLOSE c_custom_setup_id;

      OZF_COPY_OFFER_PVT.copy_offer_detail(
                                    p_api_version=> 1.0,
                                    p_init_msg_list=> FND_API.G_FALSE,
                                    p_commit=> FND_API.G_FALSE,
                                    p_validation_level=> p_validation_level,
                                    x_return_status=> l_return_status,
                                    x_msg_count=> x_msg_count,
                                    x_msg_data=> x_msg_data,
                                    p_source_object_id => l_reference_rec.plan_id,
                                    p_attributes_table =>l_attr_table,
                                    p_copy_columns_table =>l_copy_columns_table,
                                    x_new_object_id =>l_plan_id,
                                    p_custom_setup_id =>l_offer_custsetup);

     l_fund_rec.plan_id := l_plan_id;

      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   END IF;

   OZF_Funds_PVT.Create_Fund (
      p_api_version => 1.0,
      p_init_msg_list   => FND_API.G_FALSE,
      p_commit          => FND_API.G_FALSE,
      p_validation_level   => p_validation_level,
      x_return_status   => l_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_fund_rec    => l_fund_rec,
      x_fund_id        => l_new_fund_id
   );

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- copy market_segments


   IF AMS_CpyUtility_PVT.is_copy_attribute ('ELIG', p_attributes_table) = FND_API.G_TRUE THEN

      AMS_CopyElements_PVT.copy_act_market_segments (
         p_src_act_type   => L_OBJECT_TYPE_FUND,
         p_new_act_type   => L_OBJECT_TYPE_FUND,
         p_src_act_id     => p_source_object_id,
         p_new_act_id     => l_new_fund_id,
         p_errnum         => l_errnum,
         p_errcode        => l_errcode,
         p_errmsg         => l_errmsg
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   -- copy product
   IF AMS_CpyUtility_PVT.is_copy_attribute (AMS_CopyElements_PVT.G_ATTRIBUTE_PROD, p_attributes_table) = FND_API.G_TRUE THEN
      AMS_CopyElements_PVT.copy_act_prod(
         p_src_act_type   => L_OBJECT_TYPE_FUND,
         p_new_act_type   => L_OBJECT_TYPE_FUND,
         p_src_act_id     => p_source_object_id,
         p_new_act_id     => l_new_fund_id,
         p_errnum         => l_errnum,
         p_errcode        => l_errcode,
         p_errmsg         => l_errmsg
      );
   END IF;

   -- currently, only needed to fetch custom_setup_id
   -- but can be used to return other values later.
   OPEN c_fund (l_new_fund_id);
   FETCH c_fund INTO l_new_fund_rec;
   CLOSE c_fund;

   x_new_object_id := l_new_fund_id;
   x_custom_setup_id := l_new_fund_rec.custom_setup_id;
   --
   -- End of API body.
   --

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;


   -- Debug Message
   IF G_DEBUG THEN
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get (
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO copy_fund;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO copy_fund;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO copy_fund;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );
END copy_fund;


---------------------------------------------------------------------
-- PROCEDURE
---   update_rollup_amount
--
-- PURPOSE
--    Update rollup columns. added by feliu
--
-- PARAMETERS
--  p_fund_rec    fund record.
---------------------------------------------------------------------

PROCEDURE  update_rollup_amount(
   p_api_version        IN       NUMBER
  ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
  ,p_commit             IN       VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
  ,x_return_status      OUT NOCOPY      VARCHAR2
  ,x_msg_count          OUT NOCOPY      NUMBER
  ,x_msg_data           OUT NOCOPY      VARCHAR2
  ,p_fund_rec           IN       fund_rec_type
) IS
 l_api_version    CONSTANT NUMBER  := 1.0;
 l_api_name       CONSTANT VARCHAR2(30)
            := 'update_rollup_amount';
 l_full_name      CONSTANT VARCHAR2(60)
            := g_pkg_name || '.' || l_api_name;

--Get all of parent fund through bottom up tree walking.
 CURSOR c_parent
 IS
   SELECT fund_id
     ,object_version_number
     ,rollup_original_budget
     ,rollup_transfered_in_amt
     ,rollup_transfered_out_amt
     ,rollup_holdback_amt
     ,rollup_planned_amt
     ,rollup_committed_amt
     ,rollup_utilized_amt           -- yzhao: 11.5.10
     ,rollup_earned_amt
     ,rollup_paid_amt
     ,rollup_recal_committed
   FROM ozf_funds_all_b
   connect by prior  parent_fund_id =fund_id
   start with fund_id =  p_fund_rec.fund_id;

BEGIN

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF G_DEBUG THEN
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR fund IN c_parent
   LOOP
      IF fund.fund_id <> p_fund_rec.fund_id THEN

         UPDATE ozf_funds_all_b
         SET object_version_number = fund.object_version_number + 1
            ,rollup_original_budget = NVL(fund.rollup_original_budget,0) + NVL(p_fund_rec.rollup_original_budget,0)
            ,rollup_transfered_in_amt = NVL(fund.rollup_transfered_in_amt,0) + NVL(p_fund_rec.rollup_transfered_in_amt,0)
            ,rollup_transfered_out_amt = NVL(fund.rollup_transfered_out_amt,0) + NVL(p_fund_rec.rollup_transfered_out_amt,0)
            ,rollup_holdback_amt = NVL(fund.rollup_holdback_amt,0) + NVL(p_fund_rec.rollup_holdback_amt,0)
            ,rollup_planned_amt = NVL(fund.rollup_planned_amt,0)+ NVL(p_fund_rec.rollup_planned_amt,0)
            ,rollup_committed_amt = NVL(fund.rollup_committed_amt,0) +  NVL(p_fund_rec.rollup_committed_amt,0)
            ,rollup_utilized_amt = NVL(fund.rollup_utilized_amt,0) + NVL(p_fund_rec.rollup_utilized_amt,0)   -- yzhao: 11.5.10
            ,rollup_earned_amt = NVL(fund.rollup_earned_amt,0) + NVL(p_fund_rec.rollup_earned_amt,0)
            ,rollup_paid_amt = NVL(fund.rollup_paid_amt,0) + NVL(p_fund_rec.rollup_paid_amt,0)
            ,rollup_recal_committed  = NVL(fund.rollup_recal_committed ,0)+ NVL(p_fund_rec.rollup_recal_committed,0)
         WHERE fund_id = fund.fund_id
         AND object_version_number = fund.object_version_number;

         IF (SQL%NOTFOUND) THEN
           IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
              fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
              fnd_msg_pub.add;
           END IF;

           RAISE fnd_api.g_exc_error;
         END IF;
      END IF;
   END LOOP;
   -------------------- finish --------------------------
   fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false
     ,p_count => x_msg_count
     ,p_data => x_msg_data);
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message( l_api_name || ': end');
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
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);

END update_rollup_amount;

---------------------------------------------------------------------
-- PROCEDURE
---   update_funds_access
--
-- PURPOSE
--    Update parent funds access. added by feliu
--
-- PARAMETERS
-- p_fund_rec: the fund record.
-- p_mode: the mode for create, and delete.
---------------------------------------------------------------------

PROCEDURE  update_funds_access(
   p_api_version        IN       NUMBER
  ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
  ,p_commit             IN       VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
  ,x_return_status      OUT NOCOPY      VARCHAR2
  ,x_msg_count          OUT NOCOPY      NUMBER
  ,x_msg_data           OUT NOCOPY      VARCHAR2
  ,p_fund_rec           IN       fund_rec_type
  ,p_mode               IN       VARCHAR2 := JTF_PLSQL_API.G_CREATE
) IS

 l_api_version    CONSTANT NUMBER  := 1.0;
 l_api_name       CONSTANT VARCHAR2(30)
            := 'update_funds_access';
 l_full_name      CONSTANT VARCHAR2(60)
            := g_pkg_name || '.' || l_api_name;

 l_access_rec               ams_access_pvt.access_rec_type;
--l_fund_owner    NUMBER;
l_return_status     VARCHAR2(1);
l_access_id         NUMBER;
l_acc_obj_ver_num   NUMBER;
--Get all of parent fund through bottom up tree walking.
 CURSOR c_parent
 IS
   SELECT fund_id,owner
   FROM ozf_funds_all_b
   connect by prior  parent_fund_id =fund_id
   start with fund_id =  p_fund_rec.fund_id;

 CURSOR c_fund_access(
      p_fund_id        IN   NUMBER
     ,p_owner_id   IN   NUMBER)
 IS
    SELECT   activity_access_id
              ,object_version_number
    FROM     ams_act_access
    WHERE  act_access_to_object_id = p_fund_id
    AND arc_act_access_to_object = 'FUND'
    AND arc_user_or_role_type = 'USER'
    AND user_or_role_id = p_owner_id;
    --AND NVL(owner_flag,'N') = 'N' ;


 TYPE owner_table_type IS TABLE of NUMBER
      INDEX BY BINARY_INTEGER;
 l_owner_table       owner_table_type;
 l_count           NUMBER  := 1 ;
 l_owner_exist       BOOLEAN := false;

BEGIN
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF G_DEBUG THEN
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');
   END IF;

   FOR fund IN c_parent
   LOOP
     --Remove last level fund.
     IF fund.fund_id <> p_fund_rec.fund_id THEN
       IF p_mode = 'CREATE' THEN
         --check if access has been created for same owner at children level.
         FOR i IN  NVL(l_owner_table.FIRST, 0)..NVL(l_owner_table.LAST, 0) LOOP
           EXIT WHEN l_owner_table.COUNT = 0;
           IF l_owner_table(i) = fund.owner THEN
             l_owner_exist := true;
           END IF;
         END LOOP;

         --if the owner of the parent and child fund is different then only add access
       IF l_owner_exist = false AND fund.owner <> p_fund_rec.owner THEN
           --added owner to owner table to avoide creating another access next time.
           l_owner_table(l_count) := fund.owner;
           l_count := l_count + 1;

            l_access_rec.act_access_to_object_id := p_fund_rec.fund_id;
            l_access_rec.arc_act_access_to_object := 'FUND';
            l_access_rec.user_or_role_id := fund.owner;
            l_access_rec.arc_user_or_role_type := 'USER';
            l_access_rec.admin_flag := 'Y';
            l_access_rec.owner_flag := 'Y';
            ams_access_pvt.create_access(
               p_api_version => l_api_version
               ,p_init_msg_list => fnd_api.g_false
               ,p_validation_level => p_validation_level
               ,x_return_status => l_return_status
               ,x_msg_count => x_msg_count
               ,x_msg_data => x_msg_data
               ,p_commit => fnd_api.g_false
               ,p_access_rec => l_access_rec
               ,x_access_id => l_access_id);

               --l_return_status := fnd_api.g_ret_sts_error;
            IF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        END IF;
      ELSE -- end create access mode.

          OPEN c_fund_access(p_fund_rec.fund_id, fund.owner);
          FETCH c_fund_access INTO l_access_id, l_acc_obj_ver_num;
          CLOSE c_fund_access;
          l_access_rec.activity_access_id := l_access_id;
          l_access_rec.object_version_number := l_acc_obj_ver_num;

          IF  fund.owner <>p_fund_rec.owner AND l_access_rec.activity_access_id is NOT NULL THEN
               ams_access_pvt.delete_access(
                  p_api_version => l_api_version
                 ,p_init_msg_list => fnd_api.g_false
                 ,p_validation_level => p_validation_level
                 ,x_return_status => l_return_status
                 ,x_msg_count => x_msg_count
                 ,x_msg_data => x_msg_data
                 ,p_commit => fnd_api.g_false
                 ,p_access_id => l_access_id
                 ,p_object_version => l_acc_obj_ver_num);

               IF l_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
               ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;
          END IF; -- end of l_access_rec.activity_access_id is NOT NULL

       END IF; -- end delete access mode.
     END IF;
   END LOOP;
   -------------------- finish --------------------------
   fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false
     ,p_count => x_msg_count
     ,p_data => x_msg_data);
   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message( l_api_name ||': end');
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
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

       fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);

END update_funds_access;

END Ozf_funds_pvt;


/
