--------------------------------------------------------
--  DDL for Package Body OZF_TRADE_PROFILE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_TRADE_PROFILE_PVT" as
/* $Header: ozfvctpb.pls 120.5.12010000.3 2010/04/26 07:13:17 kpatro ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Trade_Profile_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
--   4/5/2010     nepanda    Bug 9539273 - 12.1.3 multi currency - trade profile / autopay issues
--   4/25/2010    kpatro     ER#9453443 - RBS PAD/ CLAIM OFFER CODE CREATE/ UPDATE FLOW CHANGES
-- ===============================================================
G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Trade_Profile_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvctpb.pls';

G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);

CURSOR g_functional_currency_code_csr IS
SELECT gs.currency_code
FROM   gl_sets_of_books gs,
       ozf_sys_parameters osp
WHERE  gs.set_of_books_id = osp.set_of_books_id
AND    osp.org_id = MO_GLOBAL.get_current_org_id();

-------------------------------------------------------------------------------
PROCEDURE Complete_trade_profile_Rec
(
   p_trade_profile_rec     IN    trade_profile_rec_type,
   x_complete_rec        OUT NOCOPY    trade_profile_rec_type
)
IS

CURSOR c_trade IS
   SELECT *
     FROM ozf_cust_trd_prfls_all
     WHERE trade_profile_id = p_trade_profile_rec.trade_profile_id;
l_trade_profile_rec         c_trade%rowtype;

BEGIN
   x_complete_rec := p_trade_profile_rec;
   OPEN c_trade;
      FETCH c_trade INTO l_trade_profile_rec;
      IF c_trade%NOTFOUND THEN
         CLOSE c_trade;
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_TRADE_PROFILE_MISSING');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      END IF;
   CLOSE c_trade;

   -- This procedure should complete the record by going through all the items in the incoming record.

--   IF p_trade_profile_rec.last_update_date = FND_API.g_miss_date THEN
--      x_complete_rec.last_update_date := l_trade_profile_rec.last_update_date;
--   END IF;

--   IF p_trade_profile_rec.object_version_number = FND_API.g_miss_num THEN
--      x_complete_rec.object_version_number := l_trade_profile_rec.object_version_number;
--   END IF;

--   IF p_trade_profile_rec.last_updated_by = FND_API.g_miss_num THEN
--      x_complete_rec.last_updated_by := l_trade_profile_rec.last_updated_by;
--   END IF;

--   IF p_trade_profile_rec.creation_date = FND_API.g_miss_date THEN
--      x_complete_rec.creation_date := l_trade_profile_rec.creation_date;
--   END IF;

--   IF p_trade_profile_rec.last_update_login = FND_API.g_miss_num THEN
--      x_complete_rec.last_update_login := l_trade_profile_rec.last_update_login;
--   END IF;

   IF p_trade_profile_rec.request_id = FND_API.g_miss_num THEN
      x_complete_rec.request_id := null;
   END IF;
   IF p_trade_profile_rec.request_id is null THEN
      x_complete_rec.request_id := l_trade_profile_rec.request_id;
   END IF;


   IF p_trade_profile_rec.program_application_id = FND_API.g_miss_num THEN
      x_complete_rec.program_application_id := null;
   END IF;
   IF p_trade_profile_rec.program_application_id is null THEN
      x_complete_rec.program_application_id := l_trade_profile_rec.program_application_id;
   END IF;


   IF p_trade_profile_rec.program_update_date = FND_API.g_miss_date THEN
      x_complete_rec.program_update_date := null;
   END IF;
   IF p_trade_profile_rec.program_update_date is null THEN
      x_complete_rec.program_update_date := l_trade_profile_rec.program_update_date;
   END IF;


   IF p_trade_profile_rec.program_id = FND_API.g_miss_num THEN
      x_complete_rec.program_id := null;
   END IF;
   IF p_trade_profile_rec.program_id is null THEN
      x_complete_rec.program_id := l_trade_profile_rec.program_id;
   END IF;


   IF p_trade_profile_rec.created_from = FND_API.g_miss_char THEN
      x_complete_rec.created_from := null;
   END IF;
   IF p_trade_profile_rec.created_from is null THEN
      x_complete_rec.created_from := l_trade_profile_rec.created_from;
   END IF;


   IF p_trade_profile_rec.party_id = FND_API.g_miss_num THEN
      x_complete_rec.party_id := null;
   END IF;
   IF p_trade_profile_rec.party_id is null THEN
      x_complete_rec.party_id := l_trade_profile_rec.party_id;
   END IF;

   IF p_trade_profile_rec.site_use_id = FND_API.g_miss_num THEN
      x_complete_rec.site_use_id := null;
   END IF;
   IF p_trade_profile_rec.site_use_id is null THEN
      x_complete_rec.site_use_id := l_trade_profile_rec.site_use_id;
   END IF;

   IF p_trade_profile_rec.autopay_flag = FND_API.g_miss_char THEN
      x_complete_rec.autopay_flag := null;
   END IF;
   IF p_trade_profile_rec.autopay_flag is null THEN
      x_complete_rec.autopay_flag := l_trade_profile_rec.autopay_flag;
   END IF;


   IF p_trade_profile_rec.claim_currency = FND_API.g_miss_char THEN
      x_complete_rec.claim_currency := null;
   END IF;
   IF p_trade_profile_rec.claim_currency is null THEN
      x_complete_rec.claim_currency := l_trade_profile_rec.claim_currency;
   END IF;

   IF p_trade_profile_rec.print_flag = FND_API.g_miss_char THEN
      x_complete_rec.print_flag := null;
   END IF;
   IF p_trade_profile_rec.print_flag is null THEN
      x_complete_rec.print_flag := l_trade_profile_rec.print_flag;
   END IF;

   IF p_trade_profile_rec.internet_deal_view_flag = FND_API.g_miss_char THEN
      x_complete_rec.internet_deal_view_flag := null;
   END IF;
   IF p_trade_profile_rec.internet_deal_view_flag is null THEN
      x_complete_rec.internet_deal_view_flag := l_trade_profile_rec.internet_deal_view_flag;
   END IF;


   IF p_trade_profile_rec.internet_claims_flag = FND_API.g_miss_char THEN
      x_complete_rec.internet_claims_flag := null;
   END IF;
   IF p_trade_profile_rec.internet_claims_flag is null THEN
      x_complete_rec.internet_claims_flag := l_trade_profile_rec.internet_claims_flag;
   END IF;

   IF p_trade_profile_rec.payment_method = FND_API.g_miss_char THEN
      x_complete_rec.payment_method := null;
   END IF;
   IF p_trade_profile_rec.payment_method is null THEN
      x_complete_rec.payment_method := l_trade_profile_rec.payment_method;
   END IF;

   IF p_trade_profile_rec.discount_type = FND_API.g_miss_char THEN
      x_complete_rec.discount_type := null;
   END IF;
   IF p_trade_profile_rec.discount_type is null THEN
      x_complete_rec.discount_type := l_trade_profile_rec.discount_type;
   END IF;

   IF p_trade_profile_rec.cust_account_id = FND_API.g_miss_num THEN
      x_complete_rec.cust_account_id := null;
   END IF;
   IF p_trade_profile_rec.cust_account_id is null THEN
      x_complete_rec.cust_account_id := l_trade_profile_rec.cust_account_id;
   END IF;

   IF p_trade_profile_rec.internet_deal_view_flag = FND_API.g_miss_char THEN
      x_complete_rec.internet_deal_view_flag := null;
   END IF;
   IF p_trade_profile_rec.internet_deal_view_flag is null THEN
      x_complete_rec.internet_deal_view_flag := l_trade_profile_rec.internet_deal_view_flag;
   END IF;

   IF p_trade_profile_rec.cust_acct_site_id = FND_API.g_miss_num THEN
      x_complete_rec.cust_acct_site_id := null;
   END IF;
   IF p_trade_profile_rec.cust_acct_site_id is null THEN
      x_complete_rec.cust_acct_site_id := l_trade_profile_rec.cust_acct_site_id;
   END IF;

   IF p_trade_profile_rec.vendor_id = FND_API.g_miss_num THEN
      x_complete_rec.vendor_id := null;
   END IF;
   IF p_trade_profile_rec.vendor_id is null THEN
      x_complete_rec.vendor_id := l_trade_profile_rec.vendor_id;
   END IF;

   IF p_trade_profile_rec.vendor_site_id = FND_API.g_miss_num THEN
      x_complete_rec.vendor_site_id := null;
   END IF;
   IF p_trade_profile_rec.vendor_site_id is null THEN
      x_complete_rec.vendor_site_id := l_trade_profile_rec.vendor_site_id;
   END IF;

   IF p_trade_profile_rec.vendor_site_code = FND_API.g_miss_char THEN
      x_complete_rec.vendor_site_code := null;
   END IF;
   IF p_trade_profile_rec.vendor_site_code is null THEN
      x_complete_rec.vendor_site_code := l_trade_profile_rec.vendor_site_code;
   END IF;

  IF p_trade_profile_rec.attribute_category = FND_API.g_miss_char THEN
      x_complete_rec.attribute_category := null;
   END IF;
  IF p_trade_profile_rec.attribute_category is null THEN
      x_complete_rec.attribute_category := l_trade_profile_rec.attribute_category;
   END IF;

   IF p_trade_profile_rec.context = FND_API.g_miss_char THEN
      x_complete_rec.context := null;
   END IF;
   IF p_trade_profile_rec.context is null THEN
      x_complete_rec.context := l_trade_profile_rec.context;
   END IF;

   IF p_trade_profile_rec.org_id = FND_API.g_miss_num THEN
      x_complete_rec.org_id := null;
   END IF;
   IF p_trade_profile_rec.org_id is null THEN
      x_complete_rec.org_id := l_trade_profile_rec.org_id;
   END IF;


   IF p_trade_profile_rec.days_due = FND_API.g_miss_num THEN
      x_complete_rec.days_due := null;
   END IF;
   IF p_trade_profile_rec.days_due is null THEN
      x_complete_rec.days_due := l_trade_profile_rec.days_due;
   END IF;

   IF p_trade_profile_rec.autopay_periodicity = FND_API.g_miss_num THEN
      x_complete_rec.autopay_periodicity := null;
   END IF;
   IF p_trade_profile_rec.autopay_periodicity is null THEN
      x_complete_rec.autopay_periodicity := l_trade_profile_rec.autopay_periodicity;
   END IF;


   IF p_trade_profile_rec.claim_threshold = FND_API.g_miss_num THEN
      x_complete_rec.claim_threshold := null;
   END IF;
   IF p_trade_profile_rec.claim_threshold is null THEN
      x_complete_rec.claim_threshold := l_trade_profile_rec.claim_threshold;
   END IF;


   IF p_trade_profile_rec.pos_write_off_threshold = FND_API.g_miss_num THEN
      x_complete_rec.pos_write_off_threshold := null;
   END IF;
   IF p_trade_profile_rec.pos_write_off_threshold is null THEN
      x_complete_rec.pos_write_off_threshold := l_trade_profile_rec.pos_write_off_threshold;
   END IF;

   IF p_trade_profile_rec.neg_write_off_threshold = FND_API.g_miss_num THEN
      x_complete_rec.neg_write_off_threshold := null;
   END IF;
   IF p_trade_profile_rec.neg_write_off_threshold is null THEN
      x_complete_rec.neg_write_off_threshold := l_trade_profile_rec.neg_write_off_threshold;
   END IF;

   IF p_trade_profile_rec.un_earned_pay_allow_to = FND_API.g_miss_char THEN
      x_complete_rec.un_earned_pay_allow_to := null;
   END IF;
   IF p_trade_profile_rec.un_earned_pay_allow_to is null THEN
      x_complete_rec.un_earned_pay_allow_to := l_trade_profile_rec.un_earned_pay_allow_to;
   END IF;

   IF p_trade_profile_rec.un_earned_pay_thold_type = FND_API.g_miss_char THEN
      x_complete_rec.un_earned_pay_thold_type := null;
   END IF;
   IF p_trade_profile_rec.un_earned_pay_thold_type is null THEN
      x_complete_rec.un_earned_pay_thold_type := l_trade_profile_rec.un_earned_pay_thold_type;
   END IF;

   IF p_trade_profile_rec.un_earned_pay_threshold = FND_API.g_miss_num THEN
      x_complete_rec.un_earned_pay_threshold := null;
   END IF;
   IF p_trade_profile_rec.un_earned_pay_threshold is null THEN
      x_complete_rec.un_earned_pay_threshold := l_trade_profile_rec.un_earned_pay_thold_amount;
   END IF;

   IF p_trade_profile_rec.un_earned_pay_thold_flag = FND_API.g_miss_char THEN
      x_complete_rec.un_earned_pay_thold_flag := null;
   END IF;
   IF p_trade_profile_rec.un_earned_pay_thold_flag is null THEN
      x_complete_rec.un_earned_pay_thold_flag := l_trade_profile_rec.un_earned_pay_thold_flag;
   END IF;

   IF p_trade_profile_rec.header_tolerance_calc_code = FND_API.g_miss_char THEN
      x_complete_rec.header_tolerance_calc_code := null;
   END IF;
   IF p_trade_profile_rec.header_tolerance_calc_code is null THEN
      x_complete_rec.header_tolerance_calc_code := l_trade_profile_rec.header_tolerance_calc_code;
   END IF;

   IF p_trade_profile_rec.header_tolerance_operand = FND_API.g_miss_num THEN
      x_complete_rec.header_tolerance_operand := null;
   END IF;
   IF p_trade_profile_rec.header_tolerance_operand is null THEN
      x_complete_rec.header_tolerance_operand := l_trade_profile_rec.header_tolerance_operand;
   END IF;

   IF p_trade_profile_rec.line_tolerance_calc_code = FND_API.g_miss_char THEN
      x_complete_rec.line_tolerance_calc_code := null;
   END IF;
   IF p_trade_profile_rec.line_tolerance_calc_code is null THEN
      x_complete_rec.line_tolerance_calc_code := l_trade_profile_rec.line_tolerance_calc_code;
   END IF;

   IF p_trade_profile_rec.line_tolerance_operand = FND_API.g_miss_num THEN
      x_complete_rec.line_tolerance_operand := null;
   END IF;
   IF p_trade_profile_rec.line_tolerance_operand is null THEN
      x_complete_rec.line_tolerance_operand := l_trade_profile_rec.line_tolerance_operand;
   END IF;


END Complete_trade_profile_Rec;
-------------------------------------------------------------------------------
PROCEDURE populate_defaults(
   p_trade_profile_rec         IN   trade_profile_rec_type,
   x_trade_profile_rec         OUT NOCOPY  trade_profile_rec_type,
   x_return_status             OUT NOCOPY  VARCHAR2
)
IS
l_cust_acct_site_id                 NUMBER;
l_vendor_site_code        VARCHAR2(80);
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Populate_Defaults';

   CURSOR c_cust_acct_site_id (a_id IN NUMBER) IS
      SELECT cust_acct_site_id
      from   HZ_CUST_SITE_USES
      WHERE  site_use_id = a_id;

   CURSOR vendor_site_code_csr (a_id IN NUMBER) IS
      SELECT vendor_site_code
      from   PO_VENDOR_SITES
      WHERE  vendor_site_id = a_id;

BEGIN
   x_trade_profile_rec := p_trade_profile_rec;

   -- defaulting flags not shown on screen and mandatory in db
   x_trade_profile_rec.internet_deal_view_flag :='F';
   x_trade_profile_rec.print_flag :='F';

   -- set autopay flag to F if null
   IF x_trade_profile_rec.autopay_flag = FND_API.g_miss_char OR
      x_trade_profile_rec.autopay_flag IS NULL
   THEN
      x_trade_profile_rec.autopay_flag :='F';
   END IF;

   -- default cust_acct_site_id if site use is is found
   IF x_trade_profile_rec.cust_account_id <> FND_API.g_miss_num OR
      x_trade_profile_rec.cust_account_id IS NOT NULL
   THEN
      IF x_trade_profile_rec.site_use_id <> FND_API.g_miss_num OR
         x_trade_profile_rec.site_use_id IS NOT NULL
      THEN
         OPEN c_cust_acct_site_id(x_trade_profile_rec.site_use_id);
            FETCH c_cust_acct_site_id INTO l_cust_acct_site_id;
         CLOSE c_cust_acct_site_id;
      END IF;
      x_trade_profile_rec.cust_acct_site_id :=l_cust_acct_site_id;
   END IF;

   -- store vendor_code if not passed
   IF x_trade_profile_rec.vendor_site_id <> FND_API.g_miss_num OR
      x_trade_profile_rec.vendor_site_id IS NOT NULL
   THEN
      IF x_trade_profile_rec.vendor_id <> FND_API.g_miss_num OR
         x_trade_profile_rec.vendor_id IS NOT NULL
      THEN
         OPEN vendor_site_code_csr(x_trade_profile_rec.vendor_site_id);
            FETCH vendor_site_code_csr INTO l_vendor_site_code;
         CLOSE vendor_site_code_csr;
      END IF;
      x_trade_profile_rec.vendor_site_code :=l_vendor_site_code;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
END populate_defaults;
--------------------------------------------------------------------------------
PROCEDURE Create_Trade_Profile(
   p_api_version_number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
   p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
   p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2,
   p_trade_profile_rec         IN   trade_profile_rec_type,
   x_trade_profile_id      OUT NOCOPY  NUMBER
   )
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Trade_Profile';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER ;
   l_TRADE_PROFILE_ID                  NUMBER;
   l_CUST_ACCOUNT_ID                   NUMBER;
   l_cust_acct_site_id                 NUMBER;
   l_dummy       NUMBER;
   l_cust_dummy  NUMBER;
   l_party_dummy NUMBER;
   l_party_dummy1 NUMBER;
   l_party_id    NUMBER;

   l_trade_profile_rec         trade_profile_rec_type;
   l_x_trade_profile_rec       trade_profile_rec_type;
   l_null  VARCHAR2(10) := 'NULL';

   CURSOR c_id IS
      SELECT ozf_cust_trd_prfls_all_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT count(trade_profile_id)
      FROM   ozf_cust_trd_prfls_all
      WHERE  TRADE_PROFILE_ID = l_id;

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
   SAVEPOINT CREATE_Trade_Profile_PVT;
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
   IF p_trade_profile_rec.TRADE_PROFILE_ID IS NULL OR
      p_trade_profile_rec.TRADE_PROFILE_ID = FND_API.g_miss_num
   THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_TRADE_PROFILE_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_TRADE_PROFILE_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy=0;
      END LOOP;
   END IF;

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
   l_trade_profile_rec := p_trade_profile_rec;

   -- checking party and defaulting it if cust_account_id is passed
   IF p_trade_profile_rec.party_id = FND_API.g_miss_num OR
      p_trade_profile_rec.party_id IS NULL
   THEN
      IF g_debug THEN
         OZF_UTILITY_PVT.debug_message('Party Id is null');
      END IF;
      IF l_trade_profile_rec.cust_account_id = FND_API.g_miss_num OR
         l_trade_profile_rec.cust_account_id IS NULL
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_TRADE_CUST_MISSING');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
         OPEN c_party_id(l_trade_profile_rec.cust_account_id);
            FETCH c_party_id INTO l_party_id;
         CLOSE c_party_id;
         l_trade_profile_rec.party_id := l_party_id;
      END IF;
   END IF;

	IF l_trade_profile_rec.claim_currency is null OR
	   l_trade_profile_rec.claim_currency = FND_API.g_miss_char THEN

      OPEN  g_functional_currency_code_csr;
      FETCH g_functional_currency_code_csr INTO l_trade_profile_rec.claim_currency;
      CLOSE g_functional_currency_code_csr;
	END IF;

   -- populate defaults
   populate_defaults (p_trade_profile_rec => l_trade_profile_rec,
                      x_trade_profile_rec => l_x_trade_profile_rec,
                      x_return_status => x_return_status);

   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   l_trade_profile_rec := l_x_trade_profile_rec;

   IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
   THEN
      -- Invoke validation procedures
      Validate_trade_profile(
         p_api_version_number     => 1.0,
         p_init_msg_list    => FND_API.G_FALSE,
         p_validation_level => p_validation_level,
         p_trade_profile_rec  =>l_trade_profile_rec,
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
   -- Invoke table handler(OZF_cust_trd_prfls_PKG.Insert_Row)
   BEGIN
      OZF_cust_trd_prfls_PKG.Insert_Row(
         px_trade_profile_id  => l_trade_profile_id,
         px_object_version_number  => l_object_version_number,
         p_last_update_date  => SYSDATE,
         p_last_updated_by  => FND_GLOBAL.USER_ID,
         p_creation_date  => SYSDATE,
         p_created_by  => FND_GLOBAL.USER_ID,
         p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
         p_request_id  => l_trade_profile_rec.request_id,
         p_program_application_id  => l_trade_profile_rec.program_application_id,
         p_program_update_date  => l_trade_profile_rec.program_update_date,
         p_program_id  => l_trade_profile_rec.program_id,
         p_created_from  => l_trade_profile_rec.created_from,
         p_party_id  => l_trade_profile_rec.party_id,
         p_site_use_id  => l_trade_profile_rec.site_use_id,
         p_autopay_flag  => l_trade_profile_rec.autopay_flag,
         p_claim_threshold  => l_trade_profile_rec.claim_threshold,
         p_claim_currency  => l_trade_profile_rec.claim_currency,
         p_print_flag  => l_trade_profile_rec.print_flag,
         p_internet_deal_view_flag  => l_trade_profile_rec.internet_deal_view_flag,
         p_internet_claims_flag  => l_trade_profile_rec.internet_claims_flag,
         p_autopay_periodicity  => l_trade_profile_rec.autopay_periodicity,
         p_autopay_periodicity_type  => l_trade_profile_rec.autopay_periodicity_type,
         p_payment_method  => l_trade_profile_rec.payment_method,
         p_discount_type  => l_trade_profile_rec.discount_type,
         p_cust_account_id  => l_trade_profile_rec.cust_account_id,
         p_cust_acct_site_id  => l_trade_profile_rec.cust_acct_site_id,
         p_vendor_id  => l_trade_profile_rec.vendor_id,
         p_vendor_site_id  => l_trade_profile_rec.vendor_site_id,
         p_vendor_site_code  => l_trade_profile_rec.vendor_site_code,
         p_context  => l_trade_profile_rec.context,
         p_attribute_category  => l_trade_profile_rec.attribute_category,
         p_attribute1  => l_trade_profile_rec.attribute1,
         p_attribute2  => l_trade_profile_rec.attribute2,
         p_attribute3  => l_trade_profile_rec.attribute3,
         p_attribute4  => l_trade_profile_rec.attribute4,
         p_attribute5  => l_trade_profile_rec.attribute5,
         p_attribute6  => l_trade_profile_rec.attribute6,
         p_attribute7  => l_trade_profile_rec.attribute7,
         p_attribute8  => l_trade_profile_rec.attribute8,
         p_attribute9  => l_trade_profile_rec.attribute9,
         p_attribute10  => l_trade_profile_rec.attribute10,
         p_attribute11  => l_trade_profile_rec.attribute11,
         p_attribute12  => l_trade_profile_rec.attribute12,
         p_attribute13  => l_trade_profile_rec.attribute13,
         p_attribute14  => l_trade_profile_rec.attribute14,
         p_attribute15  => l_trade_profile_rec.attribute15,
         px_org_id  => l_trade_profile_rec.org_id,
         p_days_due  => l_trade_profile_rec.days_due,
	 p_pos_write_off_threshold	=>	l_trade_profile_rec.pos_write_off_threshold,
	 p_neg_write_off_threshold	=>	l_trade_profile_rec.neg_write_off_threshold,
	 p_un_earned_pay_allow_to	=>	l_trade_profile_rec.un_earned_pay_allow_to,
	 p_un_earned_pay_thold_type	=>	l_trade_profile_rec.un_earned_pay_thold_type,
	 p_un_earned_pay_threshold	=>	l_trade_profile_rec.un_earned_pay_threshold,
	 p_un_earned_pay_thold_flag	=>	l_trade_profile_rec.un_earned_pay_thold_flag,
   	 p_header_tolerance_calc_code	=>	l_trade_profile_rec.header_tolerance_calc_code,
	 p_header_tolerance_operand	=>	l_trade_profile_rec.header_tolerance_operand,
	 p_line_tolerance_calc_code	=>	l_trade_profile_rec.line_tolerance_calc_code,
	 p_line_tolerance_operand	=>	l_trade_profile_rec.line_tolerance_operand
         );

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
     ROLLBACK TO CREATE_Trade_Profile_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Trade_Profile_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
  WHEN OTHERS THEN
     ROLLBACK TO CREATE_Trade_Profile_PVT;
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
End Create_Trade_Profile;
-------------------------------------------------------------------------------
PROCEDURE Update_Trade_Profile(
   p_api_version_number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
   p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2,
   p_trade_profile_rec               IN    trade_profile_rec_type,
   x_object_version_number      OUT NOCOPY  NUMBER
                               )
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Trade_Profile';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   -- Local Variables
   l_object_version_number     NUMBER;
   l_TRADE_PROFILE_ID          NUMBER;
   --l_cust_account_id         NUMBER;
   l_site_use_id               NUMBER;
   l_cust_acct_site_id         NUMBER;
   l_org_id                    NUMBER;

   CURSOR c_trade IS
   SELECT *
     FROM ozf_cust_trd_prfls_all
     WHERE trade_profile_id = p_trade_profile_rec.trade_profile_id;

   CURSOR c_get_trade_profile(v_trade_profile_id in NUMBER) IS
     SELECT *
     FROM  ozf_cust_trd_prfls_all
     WHERE trade_profile_id = v_trade_profile_id;

   CURSOR c_cust_acct_site_id (a_id IN NUMBER) IS
      SELECT cust_acct_site_id
      from HZ_CUST_SITE_USES
      WHERE site_use_id = a_id;

   --l_ref_trade_profile_rec  c_get_Trade_Profile%ROWTYPE;
   l_ref_trade_profile_rec  c_trade%ROWTYPE;
   l_tar_trade_profile_rec  trade_profile_rec_type := p_trade_profile_rec;
   l_rowid  ROWID;
   l_trade_profile_rec      trade_profile_rec_type;
   l_x_trade_profile_rec    trade_profile_rec_type;

   /*CURSOR check_acct_profile (p_id in number) IS
   SELECT  cust_account_id
   FROM    ozf_cust_trd_prfls_all   -- R12 Enhancements
   WHERE   trade_profile_id = p_id;*/

   CURSOR check_site_profile (p_id in number) IS
   SELECT  site_use_id
   FROM    ozf_cust_trd_prfls_all   --For R12.1 Enhancements
   WHERE   trade_profile_id = p_id;


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT UPDATE_Trade_Profile_PVT;
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
   l_org_id := l_tar_trade_profile_rec.org_id;  -- R12 Enhancements

   -- Debug Message
   IF g_debug THEN
      OZF_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');
   END IF;
   OPEN c_trade;
     FETCH c_trade INTO l_ref_trade_profile_rec;
     IF ( c_trade%NOTFOUND) THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
           FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
     END IF;
   CLOSE  c_trade;
   -- Debug Message
   IF g_debug THEN
      OZF_UTILITY_PVT.debug_message('Private API: - Close Cursor');
   END IF;

   IF (l_tar_trade_profile_rec.object_version_number is NULL or
      l_tar_trade_profile_rec.object_version_number = FND_API.G_MISS_NUM ) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_API_NO_OBJ_VER_NUM');
         FND_MSG_PUB.add;
   END IF;
      raise FND_API.G_EXC_ERROR;
   End if;

   -- check if site use id exists and is different than the one in db for trade profile
   -- For R12.1 Enhancements
   OPEN check_site_profile(p_trade_profile_rec.trade_profile_id);
      FETCH check_site_profile INTO l_site_use_id;
   CLOSE check_site_profile;
   -- set to miss num if value is null
   IF l_site_use_id is null THEN
      l_site_use_id := FND_API.G_MISS_NUM;
   END IF;

   -- if cust account id in db is not the same as the account from user create a trade profile
     IF g_debug THEN
        OZF_UTILITY_PVT.debug_message('before create in update!!');
     END IF;
   IF l_site_use_id <> p_trade_profile_rec.site_use_id THEN
         IF g_debug THEN
            OZF_UTILITY_PVT.debug_message('into create');
         END IF;
      Create_Trade_Profile (
         p_api_version_number         =>   1.0,
         p_init_msg_list              =>   FND_API.G_FALSE,
         p_commit                     =>   FND_API.G_FALSE,
         p_validation_level           =>   p_validation_level,
         x_return_status              =>   x_return_status,
         x_msg_count                  =>   x_msg_count,
         x_msg_data                   =>   x_msg_data,
         p_trade_profile_rec          =>   p_trade_profile_rec,
         x_trade_profile_id           =>   l_trade_profile_id
         );
      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      x_object_version_number := 1;
   ELSE -- update for existing trade profiles at party or account levels
      -- complete the record (get missing values filled from db)
      Complete_trade_profile_Rec(
         p_trade_profile_rec   => p_trade_profile_rec,
         x_complete_rec        => l_trade_profile_rec
      );
        IF g_debug THEN
           OZF_UTILITY_PVT.debug_message('into update part');
        END IF;
     -- populate defaults
      populate_defaults (p_trade_profile_rec => l_trade_profile_rec,
                      x_trade_profile_rec => l_x_trade_profile_rec,
                      x_return_status => x_return_status);

      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      l_trade_profile_rec := l_x_trade_profile_rec;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Check_trade_profile_Items(
                                 p_trade_profile_rec => l_trade_profile_rec,
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
         Validate_trade_profile_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_trade_profile_rec      => l_trade_profile_rec
                                   );
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;
      IF g_debug THEN
         OZF_UTILITY_PVT.debug_message('cust_account_id'||l_trade_profile_rec.cust_account_id);
      END IF;

      -- Debug Message
      OZF_cust_trd_prfls_PKG.Update_Row(
             p_trade_profile_id  => l_trade_profile_rec.trade_profile_id,
             p_object_version_number  => l_trade_profile_rec.object_version_number,
             p_last_update_date  => SYSDATE,
             p_last_updated_by  => FND_GLOBAL.USER_ID,
             p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
             p_request_id  => l_trade_profile_rec.request_id,
             p_program_application_id  => l_trade_profile_rec.program_application_id,
             p_program_update_date  => l_trade_profile_rec.program_update_date,
             p_program_id  => l_trade_profile_rec.program_id,
             p_created_from  => l_trade_profile_rec.created_from,
             p_party_id  => l_trade_profile_rec.party_id,
             p_site_use_id  => l_trade_profile_rec.site_use_id,
             p_autopay_flag  => l_trade_profile_rec.autopay_flag,
             p_claim_threshold  => l_trade_profile_rec.claim_threshold,
             p_claim_currency  => l_trade_profile_rec.claim_currency,
             p_print_flag  => l_trade_profile_rec.print_flag,
             p_internet_deal_view_flag  => l_trade_profile_rec.internet_deal_view_flag,
             p_internet_claims_flag  => l_trade_profile_rec.internet_claims_flag,
             p_autopay_periodicity  => l_trade_profile_rec.autopay_periodicity,
             p_autopay_periodicity_type  => l_trade_profile_rec.autopay_periodicity_type,
             p_payment_method  => p_trade_profile_rec.payment_method,
             p_discount_type  => l_trade_profile_rec.discount_type,
             p_cust_account_id  => l_trade_profile_rec.cust_account_id,
             p_cust_acct_site_id  => l_trade_profile_rec.cust_acct_site_id,
             p_vendor_id  => l_trade_profile_rec.vendor_id,
             p_vendor_site_id  => l_trade_profile_rec.vendor_site_id,
             p_vendor_site_code  => l_trade_profile_rec.vendor_site_code,
             p_context  => l_trade_profile_rec.context,
             p_attribute_category  => l_trade_profile_rec.attribute_category,
             p_attribute1  => l_trade_profile_rec.attribute1,
             p_attribute2  => l_trade_profile_rec.attribute2,
             p_attribute3  => l_trade_profile_rec.attribute3,
             p_attribute4  => l_trade_profile_rec.attribute4,
             p_attribute5  => l_trade_profile_rec.attribute5,
             p_attribute6  => p_trade_profile_rec.attribute6,
             p_attribute7  => l_trade_profile_rec.attribute7,
             p_attribute8  => l_trade_profile_rec.attribute8,
             p_attribute9  => l_trade_profile_rec.attribute9,
             p_attribute10  => l_trade_profile_rec.attribute10,
             p_attribute11  => l_trade_profile_rec.attribute11,
             p_attribute12  => l_trade_profile_rec.attribute12,
             p_attribute13  => l_trade_profile_rec.attribute13,
             p_attribute14  => l_trade_profile_rec.attribute14,
             p_attribute15  => l_trade_profile_rec.attribute15,
             p_org_id  => l_org_id,
             p_days_due  => l_trade_profile_rec.days_due,
    	     p_pos_write_off_threshold	=>	l_trade_profile_rec.pos_write_off_threshold,
	     p_neg_write_off_threshold	=>	l_trade_profile_rec.neg_write_off_threshold,
	     p_un_earned_pay_allow_to	=>	l_trade_profile_rec.un_earned_pay_allow_to,
    	     p_un_earned_pay_thold_type	=>	l_trade_profile_rec.un_earned_pay_thold_type,
	     p_un_earned_pay_threshold	=>	l_trade_profile_rec.un_earned_pay_threshold,
	     p_un_earned_pay_thold_flag	=>	l_trade_profile_rec.un_earned_pay_thold_flag,
    	     p_header_tolerance_calc_code	=>	l_trade_profile_rec.header_tolerance_calc_code,
	     p_header_tolerance_operand	=>	l_trade_profile_rec.header_tolerance_operand,
	     p_line_tolerance_calc_code	=>	l_trade_profile_rec.line_tolerance_calc_code,
    	     p_line_tolerance_operand	=>	l_trade_profile_rec.line_tolerance_operand
 );
         -- set the return object version number
         x_object_version_number := l_trade_profile_rec.object_version_number;
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
     ROLLBACK TO UPDATE_Trade_Profile_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
                               );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_Trade_Profile_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
                                 );
   WHEN OTHERS THEN
      ROLLBACK TO UPDATE_Trade_Profile_PVT;
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
End Update_Trade_Profile;
-------------------------------------------------------------------------------
PROCEDURE Delete_Trade_Profile(
   p_api_version_number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
   p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
   p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2,
   p_trade_profile_id                   IN  NUMBER,
   p_object_version_number      IN   NUMBER
                              )

IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Trade_Profile';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT DELETE_Trade_Profile_PVT;
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
   -- Invoke table handler(OZF_cust_trd_prfls_PKG.Delete_Row)
   OZF_cust_trd_prfls_PKG.Delete_Row(
          p_TRADE_PROFILE_ID  => p_TRADE_PROFILE_ID);
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
     ROLLBACK TO DELETE_Trade_Profile_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
                               );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO DELETE_Trade_Profile_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
                                );
   WHEN OTHERS THEN
      ROLLBACK TO DELETE_Trade_Profile_PVT;
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
End Delete_Trade_Profile;
-------------------------------------------------------------------------------
PROCEDURE Lock_Trade_Profile(
   p_api_version_number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2,
   p_trade_profile_id                   IN  NUMBER,
   p_object_version             IN  NUMBER
)
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Trade_Profile';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_TRADE_PROFILE_ID                  NUMBER;

CURSOR c_Trade_Profile IS
   SELECT TRADE_PROFILE_ID
   FROM ozf_cust_trd_prfls_all
   WHERE TRADE_PROFILE_ID = p_TRADE_PROFILE_ID
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
   OPEN c_Trade_Profile;
   FETCH c_Trade_Profile INTO l_TRADE_PROFILE_ID;
   IF (c_Trade_Profile%NOTFOUND) THEN
     CLOSE c_Trade_Profile;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
     END IF;
     RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_Trade_Profile;
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
     ROLLBACK TO LOCK_Trade_Profile_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Trade_Profile_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
     );
   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Trade_Profile_PVT;
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
End Lock_Trade_Profile;
-------------------------------------------------------------------------------
PROCEDURE check_trade_profile_uk_items(
   p_trade_profile_rec          IN   trade_profile_rec_type,
   p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);
l_CUST_ACCOUNT_ID  NUMBER;
l_site_use_ID  NUMBER;
l_party_id      NUMBER;

--l_cust_dummy    NUMBER;
l_site_dummy    NUMBER;
l_party_dummy   NUMBER;

--For R12.1 Enhancements
-- one trade profile per cust account
/*CURSOR c_cust_id_exists (l_id IN NUMBER) IS
SELECT count(cust_account_id)
FROM ozf_cust_trd_prfls
WHERE CUST_ACCOUNT_ID = l_id;*/



-- one trade profile per party (without cust account)
CURSOR c_party_id_exists(l_id in NUMBER) IS
SELECT count(party_id)
FROM ozf_cust_trd_prfls
WHERE CUST_ACCOUNT_ID is NULL
AND   PARTY_ID = l_id;

--For R12.1 Enhancements
-- one trade profile per cust bill_to site
CURSOR c_cust_site_use_exists (l_id IN NUMBER) IS
SELECT count(site_use_id)
FROM ozf_cust_trd_prfls
WHERE site_use_id = l_id;

BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      -- check if customer account id is unique
      IF p_trade_profile_rec.site_use_id = FND_API.g_miss_num OR
         p_trade_profile_rec.site_use_id is null
      THEN
         -- check if party without cust account id is unique
         IF p_trade_profile_rec.party_id = FND_API.g_miss_num OR
            p_trade_profile_rec.party_id is null
         THEN
            -- raise error
            l_valid_flag := FND_API.g_false;
         ELSE
            l_party_dummy := NULL;
            l_party_id := p_trade_profile_rec.party_id;
            OPEN c_party_id_exists(l_party_id);
               FETCH c_party_id_exists INTO l_party_dummy;
            CLOSE c_party_id_exists;
            IF l_party_dummy <> 0 THEN
	  IF g_debug THEN
	     OZF_UTILITY_PVT.debug_message('no cust or party 2'|| l_party_dummy ||l_valid_flag);
	  END IF;
              -- l_valid_flag := FND_API.g_false;
	    END IF;
         END IF;
      ELSE
        --For R12.1 Enhancements
         /*l_cust_dummy := NULL;
         l_CUST_ACCOUNT_ID := p_trade_profile_rec.cust_account_id;*/

         l_site_dummy := NULL;
         l_site_use_id := p_trade_profile_rec.site_use_id;

         OPEN c_cust_site_use_exists(l_CUST_ACCOUNT_ID);
            FETCH c_cust_site_use_exists INTO l_site_dummy;
         CLOSE c_cust_site_use_exists;
	OZF_UTILITY_PVT.debug_message('no l_site_dummy '|| l_site_dummy );
         IF l_site_dummy <> 0 THEN
            l_valid_flag := FND_API.g_false;
         END IF;
      END IF;
   ELSE
      l_valid_flag :=  FND_API.g_true;
   END IF;

   IF l_valid_flag = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_TRADE_CUST_DUPLICATE');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;
END check_trade_profile_uk_items;
-------------------------------------------------------------------------------
PROCEDURE check_trade_profile_req_items(
   p_trade_profile_rec          IN  trade_profile_rec_type,
   p_validation_mode            IN VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status              OUT NOCOPY VARCHAR2
                                       )
IS
l_check1                      NUMBER;
l_check2                      NUMBER;
l_party_id                    NUMBER;
l_trade_profile_rec           trade_profile_rec_type;

CURSOR c_party_id (c_id IN NUMBER) IS
SELECT party_id
from   HZ_CUST_ACCOUNTS
WHERE  cust_account_id = c_id;

BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- checking if party id exists
   OPEN c_party_id(p_trade_profile_rec.cust_account_id);
      FETCH c_party_id INTO l_party_id;
   CLOSE c_party_id;

   IF p_trade_profile_rec.party_id = FND_API.g_miss_num OR
      p_trade_profile_rec.party_id IS NULL THEN
      IF p_trade_profile_rec.site_use_id = FND_API.g_miss_num OR --For R12.1 Enhancements
         p_trade_profile_rec.site_use_id IS NULL
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_TRADE_PARTY_MISSING');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;
   OZF_UTILITY_PVT.debug_message('p_trade_profile_rec.payment_method : ' || p_trade_profile_rec.payment_method);
   -- Fix for ER#9453443
   IF p_trade_profile_rec.payment_method IN ('CHECK','EFT','WIRE','AP_DEBIT','AP_DEFAULT') THEN
   IF p_trade_profile_rec.vendor_id = FND_API.g_miss_num OR
      p_trade_profile_rec.vendor_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_TRADE_VENDOR_MISSING');
         FND_MSG_PUB.add;
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   IF p_trade_profile_rec.vendor_site_id = FND_API.g_miss_num OR
      p_trade_profile_rec.vendor_site_id IS NULL
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_TRADE_VENSITE_MISSING');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   END IF;
   IF p_trade_profile_rec.autopay_flag = FND_API.g_miss_char OR
      p_trade_profile_rec.autopay_flag IS NULL
   THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_TRADE_AUTO_MISSING ');
          FND_MSG_PUB.add;
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- defaulted to F in the create api
   IF p_trade_profile_rec.autopay_flag = FND_API.g_miss_char OR
      p_trade_profile_rec.internet_deal_view_flag IS NULL
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_TRADE_INTERNET_MISSING');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   IF p_trade_profile_rec.autopay_flag = FND_API.g_miss_char OR
      p_trade_profile_rec.print_flag IS NULL
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_TRADE_PRINT_MISSING');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- bill to site requitred for credit memos
   --nepanda : fix for bug # 9539273 - issue #2
/*   IF p_trade_profile_rec.payment_method = 'CREDIT_MEMO' THEN
      IF p_trade_profile_rec.site_use_id IS NULL OR
         p_trade_profile_rec.site_use_id = FND_API.G_MISS_NUM
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_TRADE_SITE_MISSING');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;*/

   /*
   IF p_trade_profile_rec.autopay_periodicity IS NULL AND
      p_trade_profile_rec.autopay_periodicity_type IS NULL
   THEN
      IF p_trade_profile_rec.claim_currency IS NULL AND
         p_trade_profile_rec.claim_threshold IS NULL
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'ERROR1');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   ELSE
        IF p_trade_profile_rec.autopay_periodicity IS NULL OR
           p_trade_profile_rec.autopay_periodicity_type IS NULL
	THEN
	     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                 FND_MESSAGE.set_name('OZF', 'ERROR1');
                 FND_MSG_PUB.add;
              END IF;
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
   END IF;

   IF p_trade_profile_rec.claim_currency IS NULL AND
      p_trade_profile_rec.claim_threshold IS NULL
   THEN
      IF p_trade_profile_rec.autopay_periodicity IS NULL AND
         p_trade_profile_rec.autopay_periodicity_type IS NULL
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'ERROR3');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   ELSE
        IF p_trade_profile_rec.claim_currency IS NULL OR
           p_trade_profile_rec.claim_threshold IS NULL
        THEN
           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                 FND_MESSAGE.set_name('OZF', 'ERROR4');
                 FND_MSG_PUB.add;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
   END IF;
   */
END check_trade_profile_req_items;
-------------------------------------------------------------------------------
PROCEDURE check_trade_profile_FK_items(
   p_trade_profile_rec IN trade_profile_rec_type,
   x_return_status OUT NOCOPY VARCHAR2)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
END check_trade_profile_FK_items;

PROCEDURE check_trade_profile_Lk_items(
   p_trade_profile_rec IN trade_profile_rec_type,
   x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
END check_trade_profile_Lk_items;



-- PROCEDURE
--    Check_Batch_Tolerances
--
-- HISTORY
--    05/18/2004  upoluri  Create.
---------------------------------------------------------------------
PROCEDURE Check_Batch_Tolerances(
   p_trade_profile_rec IN  trade_profile_rec_type
  ,x_return_status     OUT NOCOPY VARCHAR2
)
IS

BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF (p_trade_profile_rec.header_tolerance_calc_code is null
         AND p_trade_profile_rec.header_tolerance_operand is not null)
         THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
               THEN
                  FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_BATCH_TOL_TYPE_REQ');
                  FND_MSG_PUB.add;
              END IF;
              x_return_status := FND_API.g_ret_sts_error;
              RETURN;
      ELSIF (p_trade_profile_rec.header_tolerance_calc_code is not null
         AND p_trade_profile_rec.header_tolerance_operand is null)
         THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
               THEN
                  FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_BATCH_TOL_VAL_REQ');
                  FND_MSG_PUB.add;
              END IF;
              x_return_status := FND_API.g_ret_sts_error;
              RETURN;
      END IF;



      IF (p_trade_profile_rec.line_tolerance_calc_code is null
         AND p_trade_profile_rec.line_tolerance_operand is not null )
         THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
               THEN
                  FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_TOL_TYPE_REQ');
                  FND_MSG_PUB.add;
              END IF;
              x_return_status := FND_API.g_ret_sts_error;
              RETURN;
      ELSIF (p_trade_profile_rec.line_tolerance_calc_code is not null
         AND p_trade_profile_rec.line_tolerance_operand is null)
         THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
               THEN
                  FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_TOL_VAL_REQ');
                  FND_MSG_PUB.add;
              END IF;
              x_return_status := FND_API.g_ret_sts_error;
              RETURN;
      END IF;

END Check_Batch_Tolerances;




-------------------------------------------------------------------------------
PROCEDURE Check_trade_profile_Items (
   p_trade_profile_rec     IN    trade_profile_rec_type,
   p_validation_mode  IN    VARCHAR2,
   x_return_status    OUT NOCOPY   VARCHAR2
   )
IS
BEGIN
   -- Check Items Uniqueness API calls
   check_trade_profile_uk_items(
      p_trade_profile_rec => p_trade_profile_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Required/NOT NULL API calls
   check_trade_profile_req_items(
      p_trade_profile_rec => p_trade_profile_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls
   check_trade_profile_FK_items(
      p_trade_profile_rec => p_trade_profile_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups
   check_trade_profile_Lk_items(
      p_trade_profile_rec => p_trade_profile_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;


   --Check the tolerances.
   Check_Batch_Tolerances(
      p_trade_profile_rec =>  p_trade_profile_rec,
      x_return_status      =>  x_return_status
    );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
END Check_trade_profile_Items;
-------------------------------------------------------------------------------
PROCEDURE Validate_trade_profile(
   p_api_version_number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
   p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
   p_trade_profile_rec          IN   trade_profile_rec_type,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2
   )
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Trade_Profile';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_trade_profile_rec  OZF_Trade_Profile_PVT.trade_profile_rec_type;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Trade_Profile_PVT;
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
         Check_trade_profile_Items(
                         p_trade_profile_rec        => p_trade_profile_rec,
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
         Validate_trade_profile_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_trade_profile_rec      => p_trade_profile_rec);
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
      ROLLBACK TO VALIDATE_Trade_Profile_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Trade_Profile_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Trade_Profile_PVT;
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
End Validate_Trade_Profile;
-------------------------------------------------------------------------------
PROCEDURE Validate_trade_profile_rec(
   p_api_version_number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2,
   p_trade_profile_rec               IN    trade_profile_rec_type
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

   -- Hint: Validate data
   -- If data not valid
   -- THEN
   -- x_return_status := FND_API.G_RET_STS_ERROR;
   -- Debug Message
   IF g_debug THEN
      OZF_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
      (p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
      );
END Validate_trade_profile_Rec;
-------------------------------------------------------------------------------
END OZF_Trade_Profile_PVT;

/
