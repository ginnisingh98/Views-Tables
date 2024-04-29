--------------------------------------------------------
--  DDL for Package Body OZF_SUPP_TRADE_PROFILE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_SUPP_TRADE_PROFILE_PVT" as
/* $Header: ozfvstpb.pls 120.5.12010000.11 2010/02/09 09:03:23 amlal ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_SUPP_TRADE_PROFILE_PVT
-- Purpose
--
-- History
--
-- 18-JUN-2008 KPATRO Fix for bug 7165146
-- 16-SEP-2008 kdass  ER 7377460 - added DFFs for DPP section
-- 09-OCT-2008 kdass  ER 7475578 - Supplier Trade Profile changes for Price Protection price increase enhancement
-- 03-Nov-2008 kpatro Bug#7524863 - 12.1 ARROW - FLEXFIELD VALUES NOT DISPLAYED ON UI AFTER UPDATE
-- 03-AUG-2009 kdass  ER 8755134 - STP: PRICE PROTECTION OPTIONS FOR SKIP APPROVAL AND SKIP ADJUSTMENT
-- 23-SEP-2009 nepanda ER 8932673 - er: credit memo scenario not handled in current price protection product

-- NOTE
--
-- End of Comments
-- ===============================================================
G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_SUPP_TRADE_PROFILE_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvstpb.pls';

G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);

CURSOR g_functional_currency_code_csr IS
SELECT gs.currency_code
FROM   gl_sets_of_books gs,
       ozf_sys_parameters osp
WHERE  gs.set_of_books_id = osp.set_of_books_id
AND    osp.org_id = MO_GLOBAL.get_current_org_id();
-------------------------------------------------------------------------------
PROCEDURE Complete_supp_trade_prfl_rec
(
   p_supp_trade_profile_rec     IN    supp_trade_profile_rec_type,
   x_complete_rec        OUT NOCOPY    supp_trade_profile_rec_type
)
IS

CURSOR c_supp_trade IS
   SELECT *
     FROM ozf_supp_trd_prfls_all
     WHERE supp_trade_profile_id = p_supp_trade_profile_rec.supp_trade_profile_id;
     l_supp_trade_profile_rec         c_supp_trade%rowtype;

BEGIN
   x_complete_rec := p_supp_trade_profile_rec;
   OPEN c_supp_trade;
      FETCH c_supp_trade INTO l_supp_trade_profile_rec;
   CLOSE c_supp_trade;

   -- This procedure should complete the record by going through all the items in the incoming record.


   IF p_supp_trade_profile_rec.request_id = FND_API.g_miss_num THEN
      x_complete_rec.request_id := null;
   END IF;
   IF p_supp_trade_profile_rec.request_id is null THEN
      x_complete_rec.request_id := l_supp_trade_profile_rec.request_id;
   END IF;


   IF p_supp_trade_profile_rec.program_application_id = FND_API.g_miss_num THEN
      x_complete_rec.program_application_id := null;
   END IF;
   IF p_supp_trade_profile_rec.program_application_id is null THEN
      x_complete_rec.program_application_id := l_supp_trade_profile_rec.program_application_id;
   END IF;


   IF p_supp_trade_profile_rec.program_update_date = FND_API.g_miss_date THEN
      x_complete_rec.program_update_date := null;
   END IF;
   IF p_supp_trade_profile_rec.program_update_date is null THEN
      x_complete_rec.program_update_date := l_supp_trade_profile_rec.program_update_date;
   END IF;


   IF p_supp_trade_profile_rec.program_id = FND_API.g_miss_num THEN
      x_complete_rec.program_id := null;
   END IF;
   IF p_supp_trade_profile_rec.program_id is null THEN
      x_complete_rec.program_id := l_supp_trade_profile_rec.program_id;
   END IF;


   IF p_supp_trade_profile_rec.created_from = FND_API.g_miss_char THEN
      x_complete_rec.created_from := null;
   END IF;
   IF p_supp_trade_profile_rec.created_from is null THEN
      x_complete_rec.created_from := l_supp_trade_profile_rec.created_from;
   END IF;


   IF p_supp_trade_profile_rec.party_id = FND_API.g_miss_num THEN
      x_complete_rec.party_id := null;
   END IF;
   IF p_supp_trade_profile_rec.party_id is null THEN
      x_complete_rec.party_id := l_supp_trade_profile_rec.party_id;
   END IF;

   IF p_supp_trade_profile_rec.site_use_id = FND_API.g_miss_num THEN
      x_complete_rec.site_use_id := null;
   END IF;
   IF p_supp_trade_profile_rec.site_use_id is null THEN
      x_complete_rec.site_use_id := l_supp_trade_profile_rec.site_use_id;
   END IF;


   IF p_supp_trade_profile_rec.cust_account_id = FND_API.g_miss_num THEN
      x_complete_rec.cust_account_id := null;
   END IF;
   IF p_supp_trade_profile_rec.cust_account_id is null THEN
      x_complete_rec.cust_account_id := l_supp_trade_profile_rec.cust_account_id;
   END IF;


   IF p_supp_trade_profile_rec.cust_acct_site_id = FND_API.g_miss_num THEN
      x_complete_rec.cust_acct_site_id := null;
   END IF;
   IF p_supp_trade_profile_rec.cust_acct_site_id is null THEN
      x_complete_rec.cust_acct_site_id := l_supp_trade_profile_rec.cust_acct_site_id;
   END IF;

   IF p_supp_trade_profile_rec.supplier_id = FND_API.g_miss_num THEN
      x_complete_rec.supplier_id := null;
   END IF;
   IF p_supp_trade_profile_rec.supplier_id is null THEN
      x_complete_rec.supplier_id := l_supp_trade_profile_rec.supplier_id;
   END IF;

   IF p_supp_trade_profile_rec.supplier_site_id = FND_API.g_miss_num THEN
      x_complete_rec.supplier_site_id := null;
   END IF;
   IF p_supp_trade_profile_rec.supplier_site_id is null THEN
      x_complete_rec.supplier_site_id := l_supp_trade_profile_rec.supplier_site_id;
   END IF;

  IF p_supp_trade_profile_rec.attribute_category = FND_API.g_miss_char THEN
      x_complete_rec.attribute_category := null;
   END IF;
  IF p_supp_trade_profile_rec.attribute_category is null THEN
      x_complete_rec.attribute_category := l_supp_trade_profile_rec.attribute_category;
   END IF;

  IF p_supp_trade_profile_rec.dpp_attribute_category = FND_API.g_miss_char THEN
      x_complete_rec.dpp_attribute_category := null;
   END IF;
  IF p_supp_trade_profile_rec.dpp_attribute_category is null THEN
      x_complete_rec.dpp_attribute_category := l_supp_trade_profile_rec.dpp_attribute_category;
  END IF;

   --pre-approval -flag
   IF p_supp_trade_profile_rec.pre_approval_flag = FND_API.g_miss_char THEN
      x_complete_rec.pre_approval_flag := null;
   END IF;
  IF p_supp_trade_profile_rec.pre_approval_flag is null THEN
      x_complete_rec.pre_approval_flag := l_supp_trade_profile_rec.pre_approval_flag;
   END IF;
   --approval_communication
   IF p_supp_trade_profile_rec.approval_communication = FND_API.g_miss_char THEN
      x_complete_rec.approval_communication := null;
   END IF;
   IF p_supp_trade_profile_rec.approval_communication is null THEN
      x_complete_rec.approval_communication := l_supp_trade_profile_rec.approval_communication;
   END IF;
   --gl_contra_liability_acct
   IF p_supp_trade_profile_rec.gl_contra_liability_acct = FND_API.g_miss_num THEN
      x_complete_rec.gl_contra_liability_acct := null;
   END IF;
   IF p_supp_trade_profile_rec.gl_contra_liability_acct is null THEN
      x_complete_rec.gl_contra_liability_acct := l_supp_trade_profile_rec.gl_contra_liability_acct;
   END IF;
   --gl_cost_adjustment_acct
     IF p_supp_trade_profile_rec.gl_cost_adjustment_acct = FND_API.g_miss_num THEN
      x_complete_rec.gl_cost_adjustment_acct := null;
   END IF;
   IF p_supp_trade_profile_rec.gl_cost_adjustment_acct is null THEN
      x_complete_rec.gl_cost_adjustment_acct := l_supp_trade_profile_rec.gl_cost_adjustment_acct;
   END IF;
   --default_days_covered
   IF p_supp_trade_profile_rec.default_days_covered = FND_API.g_miss_num THEN
      x_complete_rec.default_days_covered := null;
   END IF;
   IF p_supp_trade_profile_rec.default_days_covered is null THEN
      x_complete_rec.default_days_covered := l_supp_trade_profile_rec.default_days_covered;
   END IF;
   --create_claim_price_increase
   IF p_supp_trade_profile_rec.create_claim_price_increase = FND_API.g_miss_char THEN
      x_complete_rec.create_claim_price_increase := null;
   END IF;
   IF p_supp_trade_profile_rec.create_claim_price_increase is null THEN
      x_complete_rec.create_claim_price_increase := l_supp_trade_profile_rec.create_claim_price_increase;
   END IF;
   --skip_approval_flag
   IF p_supp_trade_profile_rec.skip_approval_flag = FND_API.g_miss_char THEN
      x_complete_rec.skip_approval_flag := null;
   END IF;
   IF p_supp_trade_profile_rec.skip_approval_flag is null THEN
      x_complete_rec.skip_approval_flag := l_supp_trade_profile_rec.skip_approval_flag;
   END IF;
   --skip_adjustment_flag
   IF p_supp_trade_profile_rec.skip_adjustment_flag = FND_API.g_miss_char THEN
      x_complete_rec.skip_adjustment_flag := null;
   END IF;
   IF p_supp_trade_profile_rec.skip_adjustment_flag is null THEN
      x_complete_rec.skip_adjustment_flag := l_supp_trade_profile_rec.skip_adjustment_flag;
   END IF;

--nepanda : ER 8932673 : start
   --Default Settlement for Supplier Price Increase Claims
   IF p_supp_trade_profile_rec.settlement_method_supplier_inc = FND_API.g_miss_char THEN
      x_complete_rec.settlement_method_supplier_inc := null;
   END IF;
   IF p_supp_trade_profile_rec.settlement_method_supplier_inc is null THEN
      x_complete_rec.settlement_method_supplier_inc := l_supp_trade_profile_rec.settlement_method_supplier_inc;
   END IF;

   --Default Settlement for Supplier Price Decrease Claims
   IF p_supp_trade_profile_rec.settlement_method_supplier_dec = FND_API.g_miss_char THEN
      x_complete_rec.settlement_method_supplier_dec := null;
   END IF;
   IF p_supp_trade_profile_rec.settlement_method_supplier_dec is null THEN
      x_complete_rec.settlement_method_supplier_dec := l_supp_trade_profile_rec.settlement_method_supplier_dec;
   END IF;

   --Default Settlement for Customer Claims
  IF p_supp_trade_profile_rec.settlement_method_customer = FND_API.g_miss_char THEN
      x_complete_rec.settlement_method_customer := null;
   END IF;
   IF p_supp_trade_profile_rec.settlement_method_customer is null THEN
      x_complete_rec.settlement_method_customer := l_supp_trade_profile_rec.settlement_method_customer;
   END IF;
--nepanda : ER 8932673 : end

   --allow_qty_increase
   IF p_supp_trade_profile_rec.allow_qty_increase = FND_API.g_miss_char THEN
      x_complete_rec.allow_qty_increase := null;
   END IF;
   IF p_supp_trade_profile_rec.allow_qty_increase is null THEN
      x_complete_rec.allow_qty_increase := l_supp_trade_profile_rec.allow_qty_increase;
   END IF;
   --qty_increase_tolerance
   IF p_supp_trade_profile_rec.qty_increase_tolerance = FND_API.g_miss_num THEN
      x_complete_rec.qty_increase_tolerance := null;
   END IF;
   IF p_supp_trade_profile_rec.qty_increase_tolerance is null THEN
      x_complete_rec.qty_increase_tolerance := l_supp_trade_profile_rec.qty_increase_tolerance;
   END IF;
 --authorization_period
  IF p_supp_trade_profile_rec.authorization_period = FND_API.g_miss_num THEN
      x_complete_rec.authorization_period := null;
   END IF;
   IF p_supp_trade_profile_rec.authorization_period is null THEN
      x_complete_rec.authorization_period := l_supp_trade_profile_rec.authorization_period;
   END IF;
   --grace_days
  IF p_supp_trade_profile_rec.grace_days = FND_API.g_miss_num THEN
      x_complete_rec.grace_days := null;
   END IF;
   IF p_supp_trade_profile_rec.grace_days is null THEN
      x_complete_rec.grace_days := l_supp_trade_profile_rec.grace_days;
   END IF;
   --request_communication
    IF p_supp_trade_profile_rec.request_communication = FND_API.g_miss_char THEN
      x_complete_rec.request_communication := null;
   END IF;
   IF p_supp_trade_profile_rec.request_communication is null THEN
      x_complete_rec.request_communication := l_supp_trade_profile_rec.request_communication;
   END IF;
   --claim_communication
   IF p_supp_trade_profile_rec.claim_communication = FND_API.g_miss_char THEN
      x_complete_rec.claim_communication := null;
   END IF;
   IF p_supp_trade_profile_rec.claim_communication is null THEN
      x_complete_rec.claim_communication := l_supp_trade_profile_rec.claim_communication;
   END IF;
   --claim_frequency
   IF p_supp_trade_profile_rec.claim_frequency = FND_API.g_miss_num THEN
      x_complete_rec.claim_frequency := null;
   END IF;
   IF p_supp_trade_profile_rec.claim_frequency is null THEN
      x_complete_rec.claim_frequency := l_supp_trade_profile_rec.claim_frequency;
   END IF;
   --claim_frequency_unit
   IF p_supp_trade_profile_rec.claim_frequency_unit = FND_API.g_miss_char THEN
      x_complete_rec.claim_frequency_unit := null;
   END IF;
   IF p_supp_trade_profile_rec.claim_frequency_unit is null THEN
      x_complete_rec.claim_frequency_unit := l_supp_trade_profile_rec.claim_frequency_unit;
   END IF;
   --claim_computation_basis
   IF p_supp_trade_profile_rec.claim_computation_basis = FND_API.g_miss_num THEN
      x_complete_rec.claim_computation_basis := null;
   END IF;
   IF p_supp_trade_profile_rec.claim_computation_basis is null THEN
      x_complete_rec.claim_computation_basis := l_supp_trade_profile_rec.claim_computation_basis;
   END IF;
   --claim_currency_code
      IF p_supp_trade_profile_rec.claim_currency_code = FND_API.g_miss_char THEN
      x_complete_rec.claim_currency_code := null;
   END IF;
   IF p_supp_trade_profile_rec.claim_currency_code is null THEN
      x_complete_rec.claim_currency_code := l_supp_trade_profile_rec.claim_currency_code;
   END IF;
   --auto_debit
   IF p_supp_trade_profile_rec.auto_debit = FND_API.g_miss_char THEN
      x_complete_rec.auto_debit := null;
   END IF;
   IF p_supp_trade_profile_rec.auto_debit is null THEN
      x_complete_rec.auto_debit := l_supp_trade_profile_rec.auto_debit;
   END IF;

   IF p_supp_trade_profile_rec.min_claim_amt = FND_API.g_miss_num THEN
      x_complete_rec.min_claim_amt := null;
   END IF;
   IF p_supp_trade_profile_rec.min_claim_amt is null THEN
      x_complete_rec.min_claim_amt := l_supp_trade_profile_rec.min_claim_amt;
   END IF;

   IF p_supp_trade_profile_rec.min_claim_amt_line_lvl = FND_API.g_miss_num THEN
      x_complete_rec.min_claim_amt_line_lvl := null;
   END IF;
   IF p_supp_trade_profile_rec.min_claim_amt_line_lvl is null THEN
      x_complete_rec.min_claim_amt_line_lvl := l_supp_trade_profile_rec.min_claim_amt_line_lvl;
   END IF;

   IF p_supp_trade_profile_rec.days_before_claiming_debit = FND_API.g_miss_num THEN
      x_complete_rec.days_before_claiming_debit := null;
   END IF;
   IF p_supp_trade_profile_rec.days_before_claiming_debit is null THEN
      x_complete_rec.days_before_claiming_debit := l_supp_trade_profile_rec.days_before_claiming_debit;
   END IF;
   IF p_supp_trade_profile_rec.org_id = FND_API.g_miss_num THEN
      x_complete_rec.org_id := null;
   END IF;
   IF p_supp_trade_profile_rec.org_id is null THEN
      x_complete_rec.org_id := l_supp_trade_profile_rec.org_id;
   END IF;

END Complete_supp_trade_prfl_rec;
-------------------------------------------------------------------------------
PROCEDURE populate_supp_defaults(
   p_supp_trade_profile_rec         IN   supp_trade_profile_rec_type,
   x_supp_trade_profile_rec         OUT NOCOPY  supp_trade_profile_rec_type,
   x_return_status             OUT NOCOPY  VARCHAR2
)
IS
l_cust_acct_site_id                 NUMBER;

L_API_NAME                  CONSTANT VARCHAR2(30) := 'populate_supp_defaults';

   CURSOR c_cust_acct_site_id (a_id IN NUMBER) IS
      SELECT cust_acct_site_id
      from   HZ_CUST_SITE_USES
      WHERE  site_use_id = a_id;
BEGIN
   x_supp_trade_profile_rec := p_supp_trade_profile_rec;

 /*  -- defaulting flags not shown on screen and mandatory in db
   x_supp_trade_profile_rec.internet_deal_view_flag :='F';
   x_supp_trade_profile_rec.print_flag :='F';
*/
   -- set pre-approval-flag to N if null
   IF x_supp_trade_profile_rec.pre_approval_flag = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.pre_approval_flag IS NULL
   THEN
      x_supp_trade_profile_rec.pre_approval_flag :='N';
   END IF;

   IF x_supp_trade_profile_rec.allow_qty_increase = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.allow_qty_increase IS NULL
   THEN
      x_supp_trade_profile_rec.allow_qty_increase :='N';
   END IF;

   IF x_supp_trade_profile_rec.auto_debit = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.auto_debit IS NULL
   THEN
      x_supp_trade_profile_rec.auto_debit :='N';
   END IF;

   -- default cust_acct_site_id if site use is is found
   IF x_supp_trade_profile_rec.cust_account_id <> FND_API.g_miss_num OR
      x_supp_trade_profile_rec.cust_account_id IS NOT NULL
   THEN
      IF x_supp_trade_profile_rec.site_use_id <> FND_API.g_miss_num OR
         x_supp_trade_profile_rec.site_use_id IS NOT NULL
      THEN
         OPEN c_cust_acct_site_id(x_supp_trade_profile_rec.site_use_id);
            FETCH c_cust_acct_site_id INTO l_cust_acct_site_id;
         CLOSE c_cust_acct_site_id;
      END IF;
      x_supp_trade_profile_rec.cust_acct_site_id :=l_cust_acct_site_id;
   END IF;
   -- Start of Fix for Bug 7165146
   IF x_supp_trade_profile_rec.default_days_covered = FND_API.g_miss_num OR
      x_supp_trade_profile_rec.default_days_covered IS NULL
   THEN
      x_supp_trade_profile_rec.default_days_covered := null;
   END IF;

   IF x_supp_trade_profile_rec.create_claim_price_increase = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.create_claim_price_increase IS NULL
   THEN
      x_supp_trade_profile_rec.create_claim_price_increase := null;
   END IF;

   IF x_supp_trade_profile_rec.skip_approval_flag = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.skip_approval_flag IS NULL
   THEN
      x_supp_trade_profile_rec.skip_approval_flag := null;
   END IF;

   IF x_supp_trade_profile_rec.skip_adjustment_flag = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.skip_adjustment_flag IS NULL
   THEN
      x_supp_trade_profile_rec.skip_adjustment_flag := null;
   END IF;

--nepanda : ER 8932673 : start
     IF x_supp_trade_profile_rec.settlement_method_supplier_inc = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.settlement_method_supplier_inc IS NULL
   THEN
      x_supp_trade_profile_rec.settlement_method_supplier_inc := null;
   END IF;

     IF x_supp_trade_profile_rec.settlement_method_supplier_dec = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.settlement_method_supplier_dec IS NULL
   THEN
      x_supp_trade_profile_rec.settlement_method_supplier_dec := null;
   END IF;

     IF x_supp_trade_profile_rec.settlement_method_customer = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.settlement_method_customer IS NULL
   THEN
      x_supp_trade_profile_rec.settlement_method_customer := null;
   END IF;
--nepanda : ER 8932673 : end

   IF x_supp_trade_profile_rec.qty_increase_tolerance = FND_API.g_miss_num OR
      x_supp_trade_profile_rec.qty_increase_tolerance IS NULL
   THEN
      x_supp_trade_profile_rec.qty_increase_tolerance := null;
   END IF;

   IF x_supp_trade_profile_rec.authorization_period = FND_API.g_miss_num OR
      x_supp_trade_profile_rec.authorization_period IS NULL
   THEN
      x_supp_trade_profile_rec.authorization_period := null;
   END IF;

   IF x_supp_trade_profile_rec.grace_days = FND_API.g_miss_num OR
      x_supp_trade_profile_rec.grace_days IS NULL
   THEN
      x_supp_trade_profile_rec.grace_days := null;
   END IF;

   IF x_supp_trade_profile_rec.days_before_claiming_debit = FND_API.g_miss_num OR
      x_supp_trade_profile_rec.days_before_claiming_debit IS NULL
   THEN
      x_supp_trade_profile_rec.days_before_claiming_debit := null;
   END IF;
   -- End of Fix for Bug 7165146

   -- Fix for Bug 7524863
   IF x_supp_trade_profile_rec.ATTRIBUTE_CATEGORY = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE_CATEGORY IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE_CATEGORY := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE1 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE1 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE1 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE2 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE2 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE2 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE3 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE3 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE3 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE4 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE4 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE4 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE5 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE5 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE5 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE6 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE6 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE6 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE7 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE7 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE7 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE8 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE8 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE8 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE9 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE9 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE9 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE10 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE10 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE10 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE11 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE11 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE11 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE12 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE12 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE12 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE13 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE13 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE13 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE14 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE14 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE14 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE15 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE15 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE15 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE16 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE16 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE16 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE17 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE17 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE17 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE18 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE18 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE18 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE19 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE19 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE19 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE20 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE20 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE20 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE21 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE21 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE21 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE22 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE22 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE22 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE23 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE23 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE23 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE24 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE24 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE24 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE25 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE25 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE25 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE26 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE26 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE26 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE27 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE27 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE27 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE28 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE28 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE28 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE29 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE29 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE29 := null;
   END IF;
   IF x_supp_trade_profile_rec.ATTRIBUTE30 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.ATTRIBUTE30 IS NULL
   THEN
      x_supp_trade_profile_rec.ATTRIBUTE30 := null;
   END IF;

   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE_CATEGORY = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE_CATEGORY IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE_CATEGORY := null;
   END IF;

   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE1 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE1 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE1 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE2 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE2 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE2 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE3 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE3 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE3 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE4 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE4 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE4 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE5 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE5 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE5 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE6 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE6 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE6 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE7 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE7 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE7 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE8 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE8 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE8 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE9 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE9 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE9 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE10 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE10 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE10 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE11 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE11 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE11 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE12 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE12 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE12 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE13 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE13 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE13 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE14 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE14 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE14 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE15 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE15 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE15 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE16 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE16 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE16 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE17 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE17 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE17 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE18 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE18 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE18 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE19 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE19 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE19 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE20 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE20 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE20 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE21 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE21 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE21 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE22 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE22 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE22 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE23 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE23 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE23 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE24 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE24 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE24 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE25 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE25 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE25 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE26 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE26 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE26 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE27 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE27 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE27 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE28 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE28 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE28 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE29 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE29 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE29 := null;
   END IF;
   IF x_supp_trade_profile_rec.DPP_ATTRIBUTE30 = FND_API.g_miss_char OR
      x_supp_trade_profile_rec.DPP_ATTRIBUTE30 IS NULL
   THEN
      x_supp_trade_profile_rec.DPP_ATTRIBUTE30 := null;
   END IF;
-- End Fix for Bug 7524863

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
END populate_supp_defaults;
--------------------------------------------------------------------------------
PROCEDURE Create_Supp_Trade_Profile(
   p_api_version_number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
   p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
   p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2,
   p_supp_trade_profile_rec     IN   supp_trade_profile_rec_type,
   x_supp_trade_profile_id      OUT NOCOPY  NUMBER
   )
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Supp_Trade_Profile';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER ;
   l_SUPP_TRADE_PROFILE_ID                  NUMBER;
   l_CUST_ACCOUNT_ID                   NUMBER;
   l_cust_acct_site_id                 NUMBER;
   l_dummy       NUMBER;
   l_cust_dummy  NUMBER;
   l_party_dummy NUMBER;
   l_party_dummy1 NUMBER;
   l_party_id    NUMBER;

   l_supp_trade_profile_rec         supp_trade_profile_rec_type;
   l_x_supp_trade_profile_rec       supp_trade_profile_rec_type;
   l_null  VARCHAR2(10) := 'NULL';

   CURSOR c_id IS
      SELECT ozf_supp_trd_prfls_all_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT count(supp_trade_profile_id)
      FROM   ozf_supp_trd_prfls_all
      WHERE  SUPP_TRADE_PROFILE_ID = l_id;

   CURSOR c_customer_id (p_id IN NUMBER) IS
      SELECT cust_account_id
      from   HZ_CUST_ACCOUNTS
      WHERE  party_id = p_id
      AND    status = 'A';

   CURSOR c_party_id (c_id IN NUMBER) IS
      SELECT party_id
      from   HZ_CUST_ACCOUNTS
      WHERE  cust_account_id = c_id;

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT Create_Supp_Trade_Profile_PVT;
   IF g_debug THEN
      OZF_UTILITY_PVT.debug_message('Private API: Create trade profile');
   END IF;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Local variable initialization
   --IF p_supp_trade_profile_rec.SUPP_TRADE_PROFILE_ID IS NULL OR
     -- p_supp_trade_profile_rec.SUPP_TRADE_PROFILE_ID = FND_API.g_miss_num
  -- THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_SUPP_TRADE_PROFILE_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_SUPP_TRADE_PROFILE_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy=0;
      END LOOP;
   --END IF;

   -- =========================================================================
   -- Validate Environment
   -- =========================================================================
   IF FND_GLOBAL.User_Id IS NULL
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_USER_PROFILE_MISSING');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Assign the record to a local variable
   l_supp_trade_profile_rec := p_supp_trade_profile_rec;

   -- populate defaults
   populate_supp_defaults (p_supp_trade_profile_rec => l_supp_trade_profile_rec,
                      x_supp_trade_profile_rec => l_x_supp_trade_profile_rec,
                      x_return_status => x_return_status);

   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   l_supp_trade_profile_rec := l_x_supp_trade_profile_rec;

   IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
   THEN
      -- Invoke validation procedures
      Validate_supp_trade_profile(
         p_api_version_number     => 1.0,
         p_init_msg_list    => FND_API.G_FALSE,
         p_validation_level => p_validation_level,
         p_supp_trade_profile_rec  =>l_supp_trade_profile_rec,
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data
         );
   END IF;

   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Debug Message
   -- Invoke table handler(OZF_supp_trd_prfls_PKG.Insert_Row)
   BEGIN
      OZF_supp_trd_prfls_PKG.Insert_Row(
         px_supp_trade_profile_id  => l_supp_trade_profile_id,
         px_object_version_number  => l_object_version_number,
         p_last_update_date  => SYSDATE,
         p_last_updated_by  => FND_GLOBAL.USER_ID,
         p_creation_date  => SYSDATE,
         p_created_by  => FND_GLOBAL.USER_ID,
         p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
         p_request_id  => l_supp_trade_profile_rec.request_id,
         p_program_application_id  => l_supp_trade_profile_rec.program_application_id,
         p_program_update_date  => l_supp_trade_profile_rec.program_update_date,
         p_program_id  => l_supp_trade_profile_rec.program_id,
         p_created_from  => l_supp_trade_profile_rec.created_from,
         p_party_id  => l_supp_trade_profile_rec.party_id,
         p_site_use_id  => l_supp_trade_profile_rec.site_use_id,
         p_cust_account_id  => l_supp_trade_profile_rec.cust_account_id,
         p_cust_acct_site_id  => l_supp_trade_profile_rec.cust_acct_site_id,
         p_supplier_id  => l_supp_trade_profile_rec.supplier_id,
         p_supplier_site_id  => l_supp_trade_profile_rec.supplier_site_id,
         p_attribute_category  => l_supp_trade_profile_rec.attribute_category,
         p_attribute1  => l_supp_trade_profile_rec.attribute1,
         p_attribute2  => l_supp_trade_profile_rec.attribute2,
         p_attribute3  => l_supp_trade_profile_rec.attribute3,
         p_attribute4  => l_supp_trade_profile_rec.attribute4,
         p_attribute5  => l_supp_trade_profile_rec.attribute5,
         p_attribute6  => l_supp_trade_profile_rec.attribute6,
         p_attribute7  => l_supp_trade_profile_rec.attribute7,
         p_attribute8  => l_supp_trade_profile_rec.attribute8,
         p_attribute9  => l_supp_trade_profile_rec.attribute9,
         p_attribute10  => l_supp_trade_profile_rec.attribute10,
         p_attribute11  => l_supp_trade_profile_rec.attribute11,
         p_attribute12  => l_supp_trade_profile_rec.attribute12,
         p_attribute13  => l_supp_trade_profile_rec.attribute13,
         p_attribute14  => l_supp_trade_profile_rec.attribute14,
         p_attribute15  => l_supp_trade_profile_rec.attribute15,
         p_attribute16  => l_supp_trade_profile_rec.attribute16,
         p_attribute17  => l_supp_trade_profile_rec.attribute17,
         p_attribute18  => l_supp_trade_profile_rec.attribute18,
         p_attribute19  => l_supp_trade_profile_rec.attribute19,
         p_attribute20  => l_supp_trade_profile_rec.attribute20,
         p_attribute21  => l_supp_trade_profile_rec.attribute21,
         p_attribute22  => l_supp_trade_profile_rec.attribute22,
         p_attribute23  => l_supp_trade_profile_rec.attribute23,
         p_attribute24  => l_supp_trade_profile_rec.attribute24,
         p_attribute25  => l_supp_trade_profile_rec.attribute25,
         p_attribute26  => l_supp_trade_profile_rec.attribute26,
         p_attribute27  => l_supp_trade_profile_rec.attribute27,
         p_attribute28  => l_supp_trade_profile_rec.attribute28,
         p_attribute29  => l_supp_trade_profile_rec.attribute29,
         p_attribute30  => l_supp_trade_profile_rec.attribute30,
         p_dpp_attribute_category  => l_supp_trade_profile_rec.dpp_attribute_category,
         p_dpp_attribute1  => l_supp_trade_profile_rec.dpp_attribute1,
         p_dpp_attribute2  => l_supp_trade_profile_rec.dpp_attribute2,
         p_dpp_attribute3  => l_supp_trade_profile_rec.dpp_attribute3,
         p_dpp_attribute4  => l_supp_trade_profile_rec.dpp_attribute4,
         p_dpp_attribute5  => l_supp_trade_profile_rec.dpp_attribute5,
         p_dpp_attribute6  => l_supp_trade_profile_rec.dpp_attribute6,
         p_dpp_attribute7  => l_supp_trade_profile_rec.dpp_attribute7,
         p_dpp_attribute8  => l_supp_trade_profile_rec.dpp_attribute8,
         p_dpp_attribute9  => l_supp_trade_profile_rec.dpp_attribute9,
         p_dpp_attribute10  => l_supp_trade_profile_rec.dpp_attribute10,
         p_dpp_attribute11  => l_supp_trade_profile_rec.dpp_attribute11,
         p_dpp_attribute12  => l_supp_trade_profile_rec.dpp_attribute12,
         p_dpp_attribute13  => l_supp_trade_profile_rec.dpp_attribute13,
         p_dpp_attribute14  => l_supp_trade_profile_rec.dpp_attribute14,
         p_dpp_attribute15  => l_supp_trade_profile_rec.dpp_attribute15,
         p_dpp_attribute16  => l_supp_trade_profile_rec.dpp_attribute16,
         p_dpp_attribute17  => l_supp_trade_profile_rec.dpp_attribute17,
         p_dpp_attribute18  => l_supp_trade_profile_rec.dpp_attribute18,
         p_dpp_attribute19  => l_supp_trade_profile_rec.dpp_attribute19,
         p_dpp_attribute20  => l_supp_trade_profile_rec.dpp_attribute20,
         p_dpp_attribute21  => l_supp_trade_profile_rec.dpp_attribute21,
         p_dpp_attribute22  => l_supp_trade_profile_rec.dpp_attribute22,
         p_dpp_attribute23  => l_supp_trade_profile_rec.dpp_attribute23,
         p_dpp_attribute24  => l_supp_trade_profile_rec.dpp_attribute24,
         p_dpp_attribute25  => l_supp_trade_profile_rec.dpp_attribute25,
         p_dpp_attribute26  => l_supp_trade_profile_rec.dpp_attribute26,
         p_dpp_attribute27  => l_supp_trade_profile_rec.dpp_attribute27,
         p_dpp_attribute28  => l_supp_trade_profile_rec.dpp_attribute28,
         p_dpp_attribute29  => l_supp_trade_profile_rec.dpp_attribute29,
         p_dpp_attribute30  => l_supp_trade_profile_rec.dpp_attribute30,
         px_org_id  => l_supp_trade_profile_rec.org_id  ,
         p_pre_approval_flag            => l_supp_trade_profile_rec.pre_approval_flag          ,
         p_approval_communication       => l_supp_trade_profile_rec.approval_communication    ,
         p_gl_contra_liability_acct     => l_supp_trade_profile_rec.gl_contra_liability_acct  ,
         p_gl_cost_adjustment_acct      => l_supp_trade_profile_rec.gl_cost_adjustment_acct   ,
         p_default_days_covered         => l_supp_trade_profile_rec.default_days_covered      ,
         p_create_claim_price_increase  => l_supp_trade_profile_rec.create_claim_price_increase ,
         p_skip_approval_flag           => l_supp_trade_profile_rec.skip_approval_flag ,
         p_skip_adjustment_flag         => l_supp_trade_profile_rec.skip_adjustment_flag ,
	--nepanda : ER 8932673 : start
         p_settlement_method_supp_inc => l_supp_trade_profile_rec.settlement_method_supplier_inc ,
         p_settlement_method_supp_dec => l_supp_trade_profile_rec.settlement_method_supplier_dec ,
         p_settlement_method_customer  => l_supp_trade_profile_rec.settlement_method_customer ,
	----nepanda : ER 8932673 : end
         p_authorization_period         => l_supp_trade_profile_rec.authorization_period      ,
         p_grace_days                   => l_supp_trade_profile_rec.grace_days                ,
         p_allow_qty_increase           => l_supp_trade_profile_rec.allow_qty_increase        ,
         p_qty_increase_tolerance       => l_supp_trade_profile_rec.qty_increase_tolerance   ,
         p_request_communication        => l_supp_trade_profile_rec.request_communication     ,
         p_claim_communication          => l_supp_trade_profile_rec.claim_communication       ,
         p_claim_frequency              => l_supp_trade_profile_rec.claim_frequency          ,
         p_claim_frequency_unit         => l_supp_trade_profile_rec.claim_frequency_unit      ,
         p_claim_computation_basis      => l_supp_trade_profile_rec.claim_computation_basis   ,
         p_claim_currency_code          => l_supp_trade_profile_rec.claim_currency_code   ,
         p_min_claim_amt                => l_supp_trade_profile_rec.min_claim_amt   ,
         p_min_claim_amt_line_lvl       => l_supp_trade_profile_rec.min_claim_amt_line_lvl   ,
         p_auto_debit                   => l_supp_trade_profile_rec.auto_debit   ,
         p_days_before_claiming_debit   => l_supp_trade_profile_rec.days_before_claiming_debit

         );

	 x_supp_trade_profile_id := l_supp_trade_profile_id ;

   EXCEPTION
      WHEN OTHERS THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_TABLE_HANDLER_ERROR');
             FND_MSG_PUB.add;
          END IF;

         RAISE FND_API.G_EXC_ERROR;
   END;
   --
   -- End of API body
   --

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   -- Debug Message
   IF g_debug THEN
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
   );

EXCEPTION
  WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_API_RESOURCES_LOCKED');
            FND_MSG_PUB.add;
     END IF;
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Create_Supp_Trade_Profile_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_Supp_Trade_Profile_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
  WHEN OTHERS THEN
     ROLLBACK TO Create_Supp_Trade_Profile_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Create_Supp_Trade_Profile;
-------------------------------------------------------------------------------
PROCEDURE Update_Supp_Trade_Profile(
   p_api_version_number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
   p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2,
   p_supp_trade_profile_rec               IN    supp_trade_profile_rec_type,
   x_object_version_number      OUT NOCOPY  NUMBER
                               )
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Supp_Trade_Profile';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   -- Local Variables
   l_object_version_number     NUMBER;
   l_SUPP_TRADE_PROFILE_ID     NUMBER;
   l_cust_account_id           NUMBER;
   l_cust_acct_site_id         NUMBER;
   l_org_id                    NUMBER;
   l_supp_site_id              NUMBER;
   l_supp_id                   NUMBER;

   CURSOR c_supp_trade IS
   SELECT *
     FROM ozf_supp_trd_prfls_all
     WHERE supp_trade_profile_id = p_supp_trade_profile_rec.supp_trade_profile_id;

   CURSOR c_get_supp_trade_profile(v_supp_trade_profile_id in NUMBER) IS
     SELECT *
     FROM  ozf_supp_trd_prfls_all
     WHERE supp_trade_profile_id = v_supp_trade_profile_id;


   l_ref_supp_trade_profile_rec  c_supp_trade%ROWTYPE;
   l_tar_supp_trade_profile_rec  supp_trade_profile_rec_type := p_supp_trade_profile_rec;
   l_rowid  ROWID;
   l_supp_trade_profile_rec      supp_trade_profile_rec_type;
   l_x_supp_trade_profile_rec    supp_trade_profile_rec_type;


   CURSOR check_supp_profile (p_id in number) IS
   SELECT  supplier_id , supplier_site_id
   FROM    ozf_supp_trd_prfls_all   -- R12 Enhancements
   WHERE   supp_trade_profile_id = p_id;


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT UPDATE_Supp_Trade_Profile_PVT;
 --  OZF_UTILITY_PVT.debug_message('IN UPDATE_Supp_Trade_Profile_PVT org id '||p_supp_trade_profile_rec.org_id);
  -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME
                                      )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;
   -- Debug Message
   --OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_org_id := l_tar_supp_trade_profile_rec.org_id;  -- R12 Enhancements

   -- Debug Message
   IF g_debug THEN
      OZF_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');
   END IF;
   OPEN c_supp_trade;
     FETCH c_supp_trade INTO l_ref_supp_trade_profile_rec;
     IF ( c_supp_trade%NOTFOUND) THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
           FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
     END IF;
   CLOSE  c_supp_trade;
   -- Debug Message
   IF g_debug THEN
      OZF_UTILITY_PVT.debug_message('Private API: - Close Cursor');
   END IF;

   IF (l_tar_supp_trade_profile_rec.object_version_number is NULL or
      l_tar_supp_trade_profile_rec.object_version_number = FND_API.G_MISS_NUM ) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_API_NO_OBJ_VER_NUM');
         FND_MSG_PUB.add;
   END IF;
      raise FND_API.G_EXC_ERROR;
   End if;

   -- get the supplier and supplier site values for the supplier trade profile id
   OPEN check_supp_profile(p_supp_trade_profile_rec.supp_trade_profile_id);
      FETCH check_supp_profile INTO l_supp_id,l_supp_site_id;
   CLOSE check_supp_profile;
   -- set to miss num if value is null
   IF l_supp_id is null THEN
      l_supp_id := FND_API.G_MISS_NUM;
   END IF;
   IF l_supp_site_id is null THEN
      l_supp_site_id := FND_API.G_MISS_NUM;
   END IF;


   -- if the supplier and supplier site from the record are the same as in the db.then update else create

   IF l_supp_id <> p_supp_trade_profile_rec.supplier_id or
       l_supp_site_id <> p_supp_trade_profile_rec.supplier_site_id
    THEN
         IF g_debug THEN
            OZF_UTILITY_PVT.debug_message('Calling create in update method');
         END IF;
      Create_Supp_Trade_Profile (
         p_api_version_number         =>   1.0,
         p_init_msg_list              =>   FND_API.G_FALSE,
         p_commit                     =>   FND_API.G_FALSE,
         p_validation_level           =>   p_validation_level,
         x_return_status              =>   x_return_status,
         x_msg_count                  =>   x_msg_count,
         x_msg_data                   =>   x_msg_data,
         p_supp_trade_profile_rec     =>   p_supp_trade_profile_rec,
         x_supp_trade_profile_id      =>   l_supp_trade_profile_id
         );
      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      x_object_version_number := 1;
   ELSE -- update mode
      -- complete the record (get missing values filled from db)
      Complete_supp_trade_prfl_rec(
         p_supp_trade_profile_rec   => p_supp_trade_profile_rec,
         x_complete_rec        => l_supp_trade_profile_rec
      );
        IF g_debug THEN
           OZF_UTILITY_PVT.debug_message('In the update');
        END IF;
     -- populate defaults
      populate_supp_defaults (p_supp_trade_profile_rec => l_supp_trade_profile_rec,
                      x_supp_trade_profile_rec => l_x_supp_trade_profile_rec,
                      x_return_status => x_return_status);

      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      l_supp_trade_profile_rec := l_x_supp_trade_profile_rec;


      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Check_supp_trd_prfl_items(
                                 p_supp_trade_profile_rec => l_supp_trade_profile_rec,
                                 p_validation_mode   => JTF_PLSQL_API.g_update,
                                 x_return_status     => x_return_status
                                  );
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
         Validate_supp_trd_prfl_rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_supp_trade_profile_rec  => l_supp_trade_profile_rec
                                   );
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

     -- Debug Message
   OZF_supp_trd_prfls_PKG.Update_Row(
        p_supp_trade_profile_id  => l_supp_trade_profile_rec.supp_trade_profile_id,
        p_object_version_number  => l_supp_trade_profile_rec.object_version_number,
        p_last_update_date  => SYSDATE,
        p_last_updated_by  => FND_GLOBAL.USER_ID,
        p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
        p_request_id  => l_supp_trade_profile_rec.request_id,
        p_program_application_id  => l_supp_trade_profile_rec.program_application_id,
        p_program_update_date  => l_supp_trade_profile_rec.program_update_date,
        p_program_id  => l_supp_trade_profile_rec.program_id,
        p_created_from  => l_supp_trade_profile_rec.created_from,
        p_party_id  => l_supp_trade_profile_rec.party_id,
        p_site_use_id  => l_supp_trade_profile_rec.site_use_id,
        p_cust_account_id  => l_supp_trade_profile_rec.cust_account_id,
        p_cust_acct_site_id  => l_supp_trade_profile_rec.cust_acct_site_id,
        p_supplier_id  => l_supp_trade_profile_rec.supplier_id,
        p_supplier_site_id  => l_supp_trade_profile_rec.supplier_site_id,
        p_attribute_category  => l_supp_trade_profile_rec.attribute_category,
        p_attribute1  => l_supp_trade_profile_rec.attribute1,
        p_attribute2  => l_supp_trade_profile_rec.attribute2,
        p_attribute3  => l_supp_trade_profile_rec.attribute3,
        p_attribute4  => l_supp_trade_profile_rec.attribute4,
        p_attribute5  => l_supp_trade_profile_rec.attribute5,
        p_attribute6  => l_supp_trade_profile_rec.attribute6,
        p_attribute7  => l_supp_trade_profile_rec.attribute7,
        p_attribute8  => l_supp_trade_profile_rec.attribute8,
        p_attribute9  => l_supp_trade_profile_rec.attribute9,
        p_attribute10  => l_supp_trade_profile_rec.attribute10,
        p_attribute11  => l_supp_trade_profile_rec.attribute11,
        p_attribute12  => l_supp_trade_profile_rec.attribute12,
        p_attribute13  => l_supp_trade_profile_rec.attribute13,
        p_attribute14  => l_supp_trade_profile_rec.attribute14,
        p_attribute15  => l_supp_trade_profile_rec.attribute15,
        p_attribute16  => l_supp_trade_profile_rec.attribute16,
        p_attribute17  => l_supp_trade_profile_rec.attribute17,
        p_attribute18  => l_supp_trade_profile_rec.attribute18,
        p_attribute19  => l_supp_trade_profile_rec.attribute19,
        p_attribute20  => l_supp_trade_profile_rec.attribute20,
        p_attribute21  => l_supp_trade_profile_rec.attribute21,
        p_attribute22 => l_supp_trade_profile_rec.attribute22,
        p_attribute23 => l_supp_trade_profile_rec.attribute23,
        p_attribute24  => l_supp_trade_profile_rec.attribute24,
        p_attribute25  => l_supp_trade_profile_rec.attribute25,
        p_attribute26  => l_supp_trade_profile_rec.attribute26,
        p_attribute27  => l_supp_trade_profile_rec.attribute27,
        p_attribute28  => l_supp_trade_profile_rec.attribute28,
        p_attribute29  => l_supp_trade_profile_rec.attribute29,
        p_attribute30  => l_supp_trade_profile_rec.attribute30,
        p_dpp_attribute_category  => l_supp_trade_profile_rec.dpp_attribute_category,
        p_dpp_attribute1  => l_supp_trade_profile_rec.dpp_attribute1,
        p_dpp_attribute2  => l_supp_trade_profile_rec.dpp_attribute2,
        p_dpp_attribute3  => l_supp_trade_profile_rec.dpp_attribute3,
        p_dpp_attribute4  => l_supp_trade_profile_rec.dpp_attribute4,
        p_dpp_attribute5  => l_supp_trade_profile_rec.dpp_attribute5,
        p_dpp_attribute6  => l_supp_trade_profile_rec.dpp_attribute6,
        p_dpp_attribute7  => l_supp_trade_profile_rec.dpp_attribute7,
        p_dpp_attribute8  => l_supp_trade_profile_rec.dpp_attribute8,
        p_dpp_attribute9  => l_supp_trade_profile_rec.dpp_attribute9,
        p_dpp_attribute10 => l_supp_trade_profile_rec.dpp_attribute10,
        p_dpp_attribute11 => l_supp_trade_profile_rec.dpp_attribute11,
        p_dpp_attribute12 => l_supp_trade_profile_rec.dpp_attribute12,
        p_dpp_attribute13 => l_supp_trade_profile_rec.dpp_attribute13,
        p_dpp_attribute14 => l_supp_trade_profile_rec.dpp_attribute14,
        p_dpp_attribute15 => l_supp_trade_profile_rec.dpp_attribute15,
        p_dpp_attribute16 => l_supp_trade_profile_rec.dpp_attribute16,
        p_dpp_attribute17 => l_supp_trade_profile_rec.dpp_attribute17,
        p_dpp_attribute18 => l_supp_trade_profile_rec.dpp_attribute18,
        p_dpp_attribute19 => l_supp_trade_profile_rec.dpp_attribute19,
        p_dpp_attribute20 => l_supp_trade_profile_rec.dpp_attribute20,
        p_dpp_attribute21 => l_supp_trade_profile_rec.dpp_attribute21,
        p_dpp_attribute22 => l_supp_trade_profile_rec.dpp_attribute22,
        p_dpp_attribute23 => l_supp_trade_profile_rec.dpp_attribute23,
        p_dpp_attribute24 => l_supp_trade_profile_rec.dpp_attribute24,
        p_dpp_attribute25 => l_supp_trade_profile_rec.dpp_attribute25,
        p_dpp_attribute26 => l_supp_trade_profile_rec.dpp_attribute26,
        p_dpp_attribute27 => l_supp_trade_profile_rec.dpp_attribute27,
        p_dpp_attribute28 => l_supp_trade_profile_rec.dpp_attribute28,
        p_dpp_attribute29 => l_supp_trade_profile_rec.dpp_attribute29,
        p_dpp_attribute30 => l_supp_trade_profile_rec.dpp_attribute30,
        p_org_id       => l_org_id ,
        p_pre_approval_flag             =>      l_supp_trade_profile_rec.pre_approval_flag          ,
        p_approval_communication        =>      l_supp_trade_profile_rec.approval_communication    ,
        p_gl_contra_liability_acct      =>      l_supp_trade_profile_rec.gl_contra_liability_acct  ,
        p_gl_cost_adjustment_acct       =>      l_supp_trade_profile_rec.gl_cost_adjustment_acct   ,
        p_default_days_covered          =>      l_supp_trade_profile_rec.default_days_covered      ,
        p_create_claim_price_increase   =>      l_supp_trade_profile_rec.create_claim_price_increase ,
        p_skip_approval_flag            =>      l_supp_trade_profile_rec.skip_approval_flag ,
        p_skip_adjustment_flag          =>      l_supp_trade_profile_rec.skip_adjustment_flag ,
	--nepanda : ER 8932673 : start
        p_settlement_method_supp_inc =>      l_supp_trade_profile_rec.settlement_method_supplier_inc ,
        p_settlement_method_supp_dec =>      l_supp_trade_profile_rec.settlement_method_supplier_dec ,
        p_settlement_method_customer     =>      l_supp_trade_profile_rec.settlement_method_customer ,
	--nepanda : ER 8932673 : start
        p_authorization_period          =>      l_supp_trade_profile_rec.authorization_period      ,
        p_grace_days                    =>      l_supp_trade_profile_rec.grace_days                ,
        p_allow_qty_increase            =>      l_supp_trade_profile_rec.allow_qty_increase        ,
        p_qty_increase_tolerance        =>      l_supp_trade_profile_rec.qty_increase_tolerance   ,
        p_request_communication         =>      l_supp_trade_profile_rec.request_communication     ,
        p_claim_communication           =>      l_supp_trade_profile_rec.claim_communication       ,
        p_claim_frequency               =>      l_supp_trade_profile_rec.claim_frequency          ,
        p_claim_frequency_unit          =>      l_supp_trade_profile_rec.claim_frequency_unit      ,
        p_claim_computation_basis       =>      l_supp_trade_profile_rec.claim_computation_basis  ,
        p_claim_currency_code           =>      l_supp_trade_profile_rec.claim_currency_code,
        p_min_claim_amt                     =>  l_supp_trade_profile_rec.min_claim_amt,
        p_min_claim_amt_line_lvl        =>      l_supp_trade_profile_rec.min_claim_amt_line_lvl,
        p_auto_debit                        =>  l_supp_trade_profile_rec.auto_debit,
        p_days_before_claiming_debit => l_supp_trade_profile_rec.days_before_claiming_debit
 );
         -- set the return object version number
         x_object_version_number := l_supp_trade_profile_rec.object_version_number;
      END IF; -- end of check for create or update of trade profile
   -- End of API body.
   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;
   -- Debug Message
   IF g_debug THEN
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
  );
EXCEPTION
   WHEN OZF_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_API_RESOURCE_LOCKED');
         FND_MSG_PUB.add;
      END IF;
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Supp_Trade_Profile_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
                               );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_Supp_Trade_Profile_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
                                 );
   WHEN OTHERS THEN
      ROLLBACK TO UPDATE_Supp_Trade_Profile_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
      );
End Update_Supp_Trade_Profile;
-------------------------------------------------------------------------------
PROCEDURE Delete_Supp_Trade_Profile(
   p_api_version_number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
   p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
   p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2,
   p_supp_trade_profile_id                   IN  NUMBER,
   p_object_version_number      IN   NUMBER
                              )

IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Supp_Trade_Profile';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Delete_Supp_Trade_Profile_PVT;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
     FND_MSG_PUB.initialize;
      END IF;
   -- Debug Message
   IF g_debug THEN
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Api body
   --
   -- Debug Message
   IF g_debug THEN
      OZF_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
   END IF;
   -- Invoke table handler(OZF_supp_trd_prfls_PKG.Delete_Row)
   OZF_supp_trd_prfls_PKG.Delete_Row(
          p_SUPP_TRADE_PROFILE_ID  => p_SUPP_TRADE_PROFILE_ID);
   -- End of API body
   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;
   -- Debug Message
   IF g_debug THEN
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
      (p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
       );

EXCEPTION
   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_API_RESOURCES_LOCKED');
        FND_MSG_PUB.add;
     END IF;
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Delete_Supp_Trade_Profile_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
                               );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Supp_Trade_Profile_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
                                );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Supp_Trade_Profile_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
                                );
End Delete_Supp_Trade_Profile;
-------------------------------------------------------------------------------
PROCEDURE Lock_Supp_Trade_Profile(
   p_api_version_number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2,
   p_supp_trade_profile_id                   IN  NUMBER,
   p_object_version             IN  NUMBER
)
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Supp_Trade_Profile';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_SUPP_TRADE_PROFILE_ID                  NUMBER;

CURSOR c_Supp_Trade_Profile IS
   SELECT SUPP_TRADE_PROFILE_ID
   FROM ozf_supp_trd_prfls_all
   WHERE SUPP_TRADE_PROFILE_ID = p_SUPP_TRADE_PROFILE_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;
BEGIN
   -- Debug Message
   IF g_debug THEN
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
------------------------ lock -------------------------
   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;
   OPEN c_Supp_Trade_Profile;
   FETCH c_Supp_Trade_Profile INTO l_SUPP_TRADE_PROFILE_ID;
   IF (c_Supp_Trade_Profile%NOTFOUND) THEN
     CLOSE c_Supp_Trade_Profile;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
     END IF;
     RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_Supp_Trade_Profile;
 -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(
     p_encoded => FND_API.g_false,
     p_count   => x_msg_count,
     p_data    => x_msg_data);
   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;
EXCEPTION
   WHEN OZF_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_API_RESOURCES LOCKED');
         FND_MSG_PUB.add;
      END IF;
     WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Supp_Trade_Profile_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Supp_Trade_Profile_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
     );
   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Supp_Trade_Profile_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
     );
End Lock_Supp_Trade_Profile;
-------------------------------------------------------------------------------
PROCEDURE check_supp_trd_prfl_uk_items(
   p_supp_trade_profile_rec          IN   supp_trade_profile_rec_type,
   p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);
l_supp_id NUMBER;
l_supp_site_id NUMBER;
l_dummy NUMBER;


-- one supplier trade profile per supplier and supplier site and org id combination

CURSOR c_dupl_profile_exists(l_id in NUMBER,l_supp_site_id in NUMBER) IS
SELECT supp_trade_profile_id
FROM ozf_supp_trd_prfls
WHERE SUPPLIER_SITE_ID = l_supp_site_id
AND   SUPPLIER_ID = l_id;


BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   l_valid_flag :=  FND_API.g_true;
      IF (p_supp_trade_profile_rec.supplier_id <> FND_API.g_miss_num AND
         p_supp_trade_profile_rec.supplier_id IS NOT NULL AND
         p_supp_trade_profile_rec.supplier_site_id <> FND_API.g_miss_num AND
         p_supp_trade_profile_rec.supplier_site_id IS NOT NULL )
      THEN
         l_supp_id := p_supp_trade_profile_rec.supplier_id;
         l_supp_site_id := p_supp_trade_profile_rec.supplier_site_id;
         OPEN c_dupl_profile_exists(l_supp_id,l_supp_site_id);
         FETCH c_dupl_profile_exists into l_dummy;
         CLOSE c_dupl_profile_exists;
         IF p_validation_mode = JTF_PLSQL_API.g_create THEN

         -- if there is another record then throw duplicate exception
           IF l_dummy IS NOT NULL
            THEN
              l_valid_flag := FND_API.g_false;
            END IF;
         ELSE

         -- if there is another record then throw duplicate exception
           IF l_dummy <> p_supp_trade_profile_rec.supp_trade_profile_id
            THEN
              l_valid_flag := FND_API.g_false;
            END IF;
         END IF; -- end of p_validation_mode = create
     END IF;
    --Seed the message OZF_SUPP_TRADE_DUPLICATE
   IF l_valid_flag = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SUPP_TRADE_PROFILE_DUPLIC');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;
END check_supp_trd_prfl_uk_items;
-------------------------------------------------------------------------------
PROCEDURE check_supp_trd_prfl_req_items(
   p_supp_trade_profile_rec     IN  supp_trade_profile_rec_type,
   p_validation_mode            IN VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status              OUT NOCOPY VARCHAR2
                                       )
IS
l_check1                      NUMBER;
l_check2                      NUMBER;
l_party_id                    NUMBER;
l_supp_trade_profile_rec      supp_trade_profile_rec_type;

CURSOR c_party_id (c_id IN NUMBER) IS
SELECT party_id
from   HZ_CUST_ACCOUNTS
WHERE  cust_account_id = c_id;

BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_supp_trade_profile_rec.supplier_id = FND_API.g_miss_num OR
       p_supp_trade_profile_rec.supplier_id IS NULL
   THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SUPPLIER_MISSING');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   IF p_supp_trade_profile_rec.supplier_site_id = FND_API.g_miss_num OR
       p_supp_trade_profile_rec.supplier_site_id IS NULL
   THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SUPPLIER_SITE_MISSING');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF p_supp_trade_profile_rec.party_id = FND_API.g_miss_num OR
      p_supp_trade_profile_rec.party_id IS NULL
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_CUSTOMER_MISSING');
            FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   IF p_supp_trade_profile_rec.cust_account_id = FND_API.g_miss_num OR
       p_supp_trade_profile_rec.cust_account_id IS NULL
   THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CUSTOMER_ACCOUNT_MISSING');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


END check_supp_trd_prfl_req_items;
-------------------------------------------------------------------------------
PROCEDURE check_supp_trd_prfl_FK_items(
   p_supp_trade_profile_rec IN supp_trade_profile_rec_type,
   x_return_status OUT NOCOPY VARCHAR2)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
END check_supp_trd_prfl_FK_items;

PROCEDURE check_supp_trd_prfl_Lk_items(
   p_supp_trade_profile_rec IN supp_trade_profile_rec_type,
   x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
END check_supp_trd_prfl_Lk_items;


-------------------------------------------------------------------------------
PROCEDURE Check_supp_trd_prfl_items (
   p_supp_trade_profile_rec     IN    supp_trade_profile_rec_type,
   p_validation_mode  IN    VARCHAR2,
   x_return_status    OUT NOCOPY   VARCHAR2
   )
IS
BEGIN
   -- Check Items Uniqueness API calls
   check_supp_trd_prfl_uk_items(
      p_supp_trade_profile_rec => p_supp_trade_profile_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Required/NOT NULL API calls
   check_supp_trd_prfl_req_items(
      p_supp_trade_profile_rec => p_supp_trade_profile_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls
   check_supp_trd_prfl_FK_items(
      p_supp_trade_profile_rec => p_supp_trade_profile_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups
   check_supp_trd_prfl_Lk_items(
      p_supp_trade_profile_rec => p_supp_trade_profile_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;



   --Check the tolerances.--not required -deepika
  /* Check_Batch_Tolerances(
      p_supp_trade_profile_rec =>  p_supp_trade_profile_rec,
      x_return_status      =>  x_return_status
    );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF; */
END Check_supp_trd_prfl_Items;
-------------------------------------------------------------------------------
PROCEDURE Validate_supp_trade_profile(
   p_api_version_number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
   p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
   p_supp_trade_profile_rec     IN   supp_trade_profile_rec_type,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2
   )
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Trade_Profile';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_supp_trade_profile_rec  OZF_SUPP_TRADE_PROFILE_PVT.supp_trade_profile_rec_type;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Supp_Trade_Prfl_PVT;
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;
      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Check_supp_trd_prfl_Items(
                         p_supp_trade_profile_rec  => p_supp_trade_profile_rec,
                         p_validation_mode   => JTF_PLSQL_API.g_create,
                         x_return_status     => x_return_status
                         );
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_supp_trd_prfl_rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_supp_trade_profile_rec  => p_supp_trade_profile_rec);
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
        );
EXCEPTION
   WHEN OZF_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_API_RESOURCE_LOCKED ');
            FND_MSG_PUB.add;
      END IF;
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO VALIDATE_Supp_Trade_Prfl_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Supp_Trade_Prfl_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Supp_Trade_Prfl_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Validate_Supp_Trade_Profile;
-------------------------------------------------------------------------------
PROCEDURE Validate_supp_trd_prfl_rec(
   p_api_version_number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2,
   p_supp_trade_profile_rec               IN    supp_trade_profile_rec_type
                                     )
IS
BEGIN
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Hint: Default days covered shd lie in 0-9999
    IF p_supp_trade_profile_rec.default_days_covered is not null and
    (  p_supp_trade_profile_rec.default_days_covered > 9999 or
      p_supp_trade_profile_rec.default_days_covered < 0)
    THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_DEFAULT_DAYS_INVALID_VAL');
        FND_MSG_PUB.add;
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF ;
     -- Hint: qty_increase_tolerance  shd lie in 1-100
     IF p_supp_trade_profile_rec.qty_increase_tolerance is not null and
      (p_supp_trade_profile_rec.qty_increase_tolerance > 100 or
      p_supp_trade_profile_rec.qty_increase_tolerance < 0)
    THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_QTY_INC_TOLERANCE_INVALID');
        FND_MSG_PUB.add;
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF ;
    IF p_supp_trade_profile_rec.grace_days is not null and
    ( p_supp_trade_profile_rec.grace_days > 9999 or
      p_supp_trade_profile_rec.grace_days < 0)
    THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_GRACE_DAYS_INVALID_VAL');
        FND_MSG_PUB.add;
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF ;
   IF p_supp_trade_profile_rec.authorization_period is not null and
    (p_supp_trade_profile_rec.authorization_period > 9999 or
      p_supp_trade_profile_rec.authorization_period < 0)
    THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_AUTH_PERIOD_INVALID_VAL');
        FND_MSG_PUB.add;
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF ;
    --gdeepika 2/21/2008 claim frequency cannot be negetive--
    IF p_supp_trade_profile_rec.claim_frequency is not null and
      p_supp_trade_profile_rec.claim_frequency < 0
    THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_FREQ_NEG');
        FND_MSG_PUB.add;
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF ;
 --2/22/2008 gdeepika- claim amount thresholds cannot be negative -6839040
 IF(p_supp_trade_profile_rec.min_claim_amt IS NOT  null)
   THEN
    IF (p_supp_trade_profile_rec.min_claim_amt  < 0)
    THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_AMT_INVALID');
           FND_MSG_PUB.add;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF ;
    END IF;

 IF( p_supp_trade_profile_rec.min_claim_amt_line_lvl IS NOT null )
   THEN
    IF (p_supp_trade_profile_rec.min_claim_amt_line_lvl  < 0)
    THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_AMT_NEG');
           FND_MSG_PUB.add;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF ;
    END IF;

 --2/22/2008 gdeepika- end of fix -6839040
 --check whether the claim line amount is greater than the claim line level amount
   IF(p_supp_trade_profile_rec.min_claim_amt IS NOT  null
      AND p_supp_trade_profile_rec.min_claim_amt_line_lvl IS NOT null )
   THEN

    IF (p_supp_trade_profile_rec.min_claim_amt  < p_supp_trade_profile_rec.min_claim_amt_line_lvl)
    THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_AMT_ERROR');
           FND_MSG_PUB.add;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF ;
    END IF;

   IF p_supp_trade_profile_rec.days_before_claiming_debit is not null and
     p_supp_trade_profile_rec.days_before_claiming_debit > 9999 or
      p_supp_trade_profile_rec.days_before_claiming_debit < 0
    THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_DAYS_BEF_CLAIMING_DEBIT');
        FND_MSG_PUB.add;
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF ;
   -- Debug Message
   IF g_debug THEN
      OZF_UTILITY_PVT.debug_message('Private API: Validate the trade profile record');
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
      (p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
      );
END Validate_supp_trd_prfl_rec;
--------------------------------------------------------------------------------------
END OZF_SUPP_TRADE_PROFILE_PVT;



/
