--------------------------------------------------------
--  DDL for Package Body OZF_PROMOTIONAL_OFFERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_PROMOTIONAL_OFFERS_PVT" as
/* $Header: ozfvopob.pls 120.6 2006/05/22 21:21:00 rssharma ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Promotional_Offers_PVT
-- Purpose
--
-- History
--   MAY-17-2002    julou    modified. See bug 2380113
--                  1. changed G_USER_ID to FND_GLOBAL.user_id
--                  2. changed G_LOGIN_ID to FND_GLOBAL.conc_login_id
--                  3. removed created_by and creation_date from update api
--   17-Oct-2002  RSSHARMA added last_recal_date and buyer_name
--                last_recal_date is inserted as sysdate (when created)
--   18-Oct-2002  RSSHARMA Fixed issue where the complete rec was called
--                later than check items.Also the completed rec was not
--                for validate
--   24-Oct-2002  RSSHARMA Added date_qualifier_profile_value.This value is sent using
--                fnd_profile function and there is no place holder for it in the record
--   24-OCT-2002  julou    1. defaulting last_recal_date to offer start date
--                         2. add activity to required check
--   07-JAN-2003  julou modified to handle no object_version_number
--                      -- Fully Accrued Budget Offers
-- Wed Apr 05 2006:2/27 PM RSSHARMA Fixed bug # 5142859. Pass fund_request_curr_code to table handler.
-- Mon May 22 2006:2/18 PM RSSHARMA Fixed bug # 5131158. In update send g_miss value for date_qualifier_profile_value
-- since it is not supposed to be updated
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Promotional_Offers_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvopob.pls';

-- ==============================================================
-- Procedure
--          handle_status
--  History
--    20-APR-2001  MUSMAN     created
--
-- ==============================================================
PROCEDURE handle_status(
   p_user_status_id  IN  NUMBER,
   x_status_code     OUT NOCOPY VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
);
--=============================================================
-- Procedure
--          handle_status
--  History
--    20-APR-2001  MUSMAN     created
--
-- ==============================================================
PROCEDURE handle_status(
   x_status_id       OUT NOCOPY NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2
);




-- Hint: Primary key needs to be returned.
PROCEDURE Create_Offers(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offers_rec                 IN   offers_rec_type  := g_miss_offers_rec,
    x_offer_id                   OUT NOCOPY  NUMBER
     )

 IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'Create_Offers';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_offer_id                  NUMBER;
   l_dummy       NUMBER;

   CURSOR c_id IS
      SELECT OZF_OFFERS_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM OZF_OFFERS
      WHERE OFFER_ID = l_id;

   l_status_code  VARCHAR2(30);
   l_status_id    NUMBER;

   l_offers_Rec   offers_rec_type := p_offers_rec;
   l_access_rec   AMS_access_PVT.access_rec_type;
   l_access_id    NUMBER;

   CURSOR c_get_start_end_date(l_list_header_id NUMBER) IS
   SELECT start_date_active, end_date_active
     FROM qp_list_headers_b
    WHERE list_header_id = l_list_header_id;

   CURSOR c_get_start_date IS
   SELECT start_date_active
     FROM qp_list_headers_b
    WHERE list_header_id = p_offers_rec.qp_list_header_id;

   l_start_date  DATE;
   l_end_date    DATE;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Offers_PVT;

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

   IF p_offers_rec.OFFER_ID IS NULL OR p_offers_rec.OFFER_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_OFFER_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_OFFER_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
      l_offers_rec.offer_id := l_offer_id;
   END IF;


   IF  p_offers_rec.user_status_id = FND_API.G_MISS_NUM
   OR p_offers_rec.user_status_id IS NULL
   THEN
      handle_status(
          x_status_id     => l_status_id
         ,x_return_status  => x_return_status
         );
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status =FND_API.G_RET_STS_SUCCESS THEN
        l_offers_rec.user_status_id := l_status_id;
      END IF;
   END IF;


   -- get the status_code for the the user_status_id
   IF l_offers_rec.user_status_id <> FND_API.G_MISS_NUM
   AND l_offers_rec.user_status_id IS NOT NULL
   THEN
      handle_status(
         p_user_status_id  => l_offers_rec.user_status_id
         ,x_status_code    => l_status_code
         ,x_return_status  => x_return_status
         );
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status =FND_API.G_RET_STS_SUCCESS THEN
        l_offers_rec.status_code := l_status_code;
      END IF;
   END IF;


   --getting the source code for the offers
   IF p_offers_rec.offer_code IS NULL
   OR p_offers_rec.offer_code = FND_API.g_miss_CHAR
   THEN
      l_offers_rec.offer_code := AMS_SourceCode_PVT.get_new_source_code (
         p_object_type  => 'OFFR',
         p_custsetup_id => p_offers_rec.custom_setup_id,
         p_global_flag  => FND_API.g_false
      );
   END IF;

   -- =========================================================================
   -- Validate Environment
   -- =========================================================================

   IF FND_GLOBAL.User_Id IS NULL
   THEN
      OZF_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

  IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
  THEN
     -- Invoke validation procedures
     Validate_offers(
        p_api_version_number     => 1.0,
        p_init_msg_list    => FND_API.G_FALSE,
        p_validation_level => p_validation_level,
        p_offers_rec       =>  l_offers_rec,
        x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data);
   END IF;
   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- julou defaulting last_recal_date to offer start date
   OPEN c_get_start_date;
   FETCH c_get_start_date INTO l_offers_rec.last_recal_date;
   CLOSE c_get_start_date;
   -- end julou
   --l_offers_rec.last_recal_date := sysdate;

   -- Invoke table handler(OZF_Promotional_Offers_PKG.Insert_Row)
    OZF_Promotional_Offers_PKG.Insert_Row(
        px_offer_id                   => l_offer_id,
        p_qp_list_header_id           => l_offers_rec.qp_list_header_id,
        p_offer_type                  => l_offers_rec.offer_type,
        p_offer_code                  => l_offers_rec.offer_code,
        p_activity_media_id           => l_offers_rec.activity_media_id,
        p_reusable                    => l_offers_rec.reusable,
        p_user_status_id              => l_offers_rec.user_status_id,
        p_owner_id                    => l_offers_rec.owner_id,
        p_wf_item_key                 => l_offers_rec.wf_item_key,
        p_customer_reference          => l_offers_rec.customer_reference,
        p_buying_group_contact_id     => l_offers_rec.buying_group_contact_id,
        p_last_update_date            => SYSDATE,
        p_last_updated_by             => FND_GLOBAL.user_id,
        p_creation_date               => SYSDATE,
        p_created_by                  => FND_GLOBAL.user_id,
        p_last_update_login           => FND_GLOBAL.conc_login_id,
        px_object_version_number      => l_object_version_number,
        p_perf_date_from              => l_offers_rec.perf_date_from,
        p_perf_date_to                => l_offers_rec.perf_date_to,
        p_status_code                 => l_offers_rec.status_code,
        p_status_date                 => l_offers_rec.status_date,
        p_modifier_level_code         => l_offers_rec.modifier_level_code,
        p_order_value_discount_type   => l_offers_rec.order_value_discount_type,
        p_offer_amount                => l_offers_rec.offer_amount,
        p_lumpsum_amount              => l_offers_rec.lumpsum_amount,
        p_lumpsum_payment_type        => l_offers_rec.lumpsum_payment_type,
        p_custom_setup_id             => l_offers_rec.custom_setup_id,
        p_security_group_id           => l_offers_rec.security_group_id,
        p_budget_amount_tc            => l_offers_rec.budget_amount_tc,
        p_budget_amount_fc            => l_offers_rec.budget_amount_fc,
        p_transaction_currency_Code   => l_offers_rec.transaction_currency_Code ,
        p_functional_currency_code    => l_offers_rec.functional_currency_code,
        p_distribution_type           => l_offers_rec.distribution_type,
        p_qualifier_id                => l_offers_rec.qualifier_id,
        p_qualifier_type              => l_offers_rec.qualifier_type,
	      p_account_closed_flag         => l_offers_rec.account_closed_flag,
        p_budget_offer_yn             => l_offers_rec.budget_offer_yn,
        p_break_type                  => l_offers_rec.break_type,
        p_retroactive                 => l_offers_rec.retroactive,
        p_volume_offer_type           => l_offers_rec.volume_offer_type,
        p_confidential_flag           => l_offers_rec.confidential_flag,
        p_budget_source_type          => l_offers_rec.budget_source_type,
        p_budget_source_id            => l_offers_rec.budget_source_id,
        p_source_from_parent          => l_offers_rec.source_from_parent,
        p_buyer_name                  => l_offers_rec.buyer_name,
        p_last_recal_date             => l_offers_rec.last_recal_date,
        p_date_qualifier              => FND_PROFILE.value('OZF_STORE_DATE_IN_QUALIFIERS'),
        p_autopay_flag                => l_offers_rec.autopay_flag,
        p_autopay_days                => l_offers_rec.autopay_days,
        p_autopay_method              => l_offers_rec.autopay_method,
        p_autopay_party_attr          => l_offers_rec.autopay_party_attr,
        p_autopay_party_id            => l_offers_rec.autopay_party_id,
        p_tier_level                  => l_offers_rec.tier_level,
        p_na_rule_header_id           => l_offers_rec.na_rule_header_id,
        p_beneficiary_account_id      => l_offers_rec.beneficiary_account_id,
        p_sales_method_flag           => l_offers_rec.sales_method_flag,
        p_org_id                      => l_offers_rec.org_id,
        p_fund_request_curr_code      => nvl(l_offers_rec.transaction_currency_Code,FND_PROFILE.VALUE('JTF_PROFILE_DEFAULT_CURRENCY'))
        );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      x_offer_id := l_offer_id;
      -- added by julou 07/29/2002  offer security. create an entry in ams_act_access
      OPEN c_get_start_end_date(l_offers_rec.qp_list_header_id);
      FETCH c_get_start_end_date INTO l_start_date, l_end_date;
      CLOSE c_get_start_end_date;

      l_access_rec.act_access_to_object_id := l_offers_rec.qp_list_header_id;
      l_access_rec.arc_act_access_to_object := 'OFFR';
      l_access_rec.user_or_role_id := l_offers_rec.owner_id;
      l_access_rec.arc_user_or_role_type := 'USER';
      l_access_rec.active_from_date := l_start_date;
      l_access_rec.active_to_date := l_end_date;
      l_access_rec.admin_flag := 'Y';
      l_access_rec.owner_flag := 'Y';

      -- create access for the owner of the offer
      AMS_access_PVT.create_access(
        p_api_version       => l_api_version_number,
        p_init_msg_list     => FND_API.g_false,
        p_commit            => FND_API.g_false,
        p_validation_level  => FND_API.g_valid_level_full,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_access_rec        => l_access_rec,
        x_access_id         => l_access_id
      );

      -- create access for default team of the offer
      l_access_rec.user_or_role_id := FND_PROFILE.value('OZF_DEFAULT_OFFER_TEAM');
      IF l_access_rec.user_or_role_id IS NOT NULL THEN
        l_access_rec.owner_flag := 'N';
        l_access_rec.arc_user_or_role_type := 'GROUP';
        AMS_access_PVT.create_access(
          p_api_version       => l_api_version_number,
          p_init_msg_list     => FND_API.g_false,
          p_commit            => FND_API.g_false,
          p_validation_level  => FND_API.g_valid_level_full,
          x_return_status     => x_return_status,
          x_msg_count         => x_msg_count,
          x_msg_data          => x_msg_data,
          p_access_rec        => l_access_rec,
          x_access_id         => l_access_id
        );
      END IF;

      -- end of creating access

--
-- End of API body
--

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Offers_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Offers_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Offers_PVT;
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
End Create_Offers;

PROCEDURE Complete_offers_Rec (
   p_offers_rec IN offers_rec_type,
   x_complete_rec OUT NOCOPY offers_rec_type)
IS

   CURSOR c_complete IS
      SELECT *
      FROM ozf_offers
      WHERE qp_list_header_id = p_offers_rec.qp_list_header_id;
   l_offers_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_offers_rec;

   OPEN c_complete;
   FETCH c_complete INTO l_offers_rec;
   CLOSE c_complete;

   -- offer_id
   IF p_offers_rec.offer_id = FND_API.g_miss_num THEN
      x_complete_rec.offer_id := l_offers_rec.offer_id;
   END IF;

   -- qp_list_header_id
   IF p_offers_rec.qp_list_header_id = FND_API.g_miss_num THEN
      x_complete_rec.qp_list_header_id := l_offers_rec.qp_list_header_id;
   END IF;

   -- offer_type
   IF p_offers_rec.offer_type = FND_API.g_miss_char THEN
      x_complete_rec.offer_type := l_offers_rec.offer_type;
   END IF;

   -- offer_code
   IF p_offers_rec.offer_code = FND_API.g_miss_char THEN
      x_complete_rec.offer_code := l_offers_rec.offer_code;
   END IF;

   -- activity_media_id
   IF p_offers_rec.activity_media_id = FND_API.g_miss_num THEN
      x_complete_rec.activity_media_id := l_offers_rec.activity_media_id;
   END IF;

   -- reusable
   IF p_offers_rec.reusable = FND_API.g_miss_char THEN
      x_complete_rec.reusable := l_offers_rec.reusable;
   END IF;

   -- user_status_id
   IF p_offers_rec.user_status_id = FND_API.g_miss_num THEN
      x_complete_rec.user_status_id := l_offers_rec.user_status_id;
   END IF;
   -- owner_id
   IF p_offers_rec.owner_id = FND_API.g_miss_num THEN
      x_complete_rec.owner_id := l_offers_rec.owner_id;
   END IF;
   -- wf_item_key
   IF p_offers_rec.wf_item_key = FND_API.g_miss_char THEN
      x_complete_rec.wf_item_key := l_offers_rec.wf_item_key;
   END IF;

   -- customer_reference
   IF p_offers_rec.customer_reference = FND_API.g_miss_char THEN
      x_complete_rec.customer_reference := l_offers_rec.customer_reference;
   END IF;

   -- buying_group_contact_id
   IF p_offers_rec.buying_group_contact_id = FND_API.g_miss_num THEN
      x_complete_rec.buying_group_contact_id := l_offers_rec.buying_group_contact_id;
   END IF;

   -- last_update_date
   IF p_offers_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_offers_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_offers_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_offers_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_offers_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_offers_rec.creation_date;
   END IF;

   -- created_by
   IF p_offers_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_offers_rec.created_by;
   END IF;

   -- last_update_login
   IF p_offers_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_offers_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_offers_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_offers_rec.object_version_number;
   END IF;


   -- perf_date_from
   IF p_offers_rec.perf_date_from = FND_API.g_miss_date THEN
      x_complete_rec.perf_date_from := l_offers_rec.perf_date_from;
   END IF;

   -- perf_date_to
   IF p_offers_rec.perf_date_to = FND_API.g_miss_date THEN
      x_complete_rec.perf_date_to := l_offers_rec.perf_date_to;
   END IF;

   -- status_code
   IF p_offers_rec.status_code = FND_API.g_miss_char THEN
      x_complete_rec.status_code := l_offers_rec.status_code;
   END IF;

   -- status_date
   IF p_offers_rec.status_date = FND_API.g_miss_date THEN
      x_complete_rec.status_date := l_offers_rec.status_date;
   END IF;

   -- modifier_level_code
   IF p_offers_rec.modifier_level_code = FND_API.g_miss_char THEN
      x_complete_rec.modifier_level_code := l_offers_rec.modifier_level_code;
   END IF;

   -- order_value_discount_type
   IF p_offers_rec.order_value_discount_type = FND_API.g_miss_char THEN
      x_complete_rec.order_value_discount_type := l_offers_rec.order_value_discount_type;
   END IF;

   -- offer_amount
   IF p_offers_rec.offer_amount = FND_API.g_miss_num THEN
      x_complete_rec.offer_amount := l_offers_rec.offer_amount;
   END IF;

   -- lumpsum_amount
   IF p_offers_rec.lumpsum_amount = FND_API.g_miss_num THEN
      x_complete_rec.lumpsum_amount := l_offers_rec.lumpsum_amount;
   END IF;

   -- lumpsum_payment_type
   IF p_offers_rec.lumpsum_payment_type = FND_API.g_miss_char THEN
      x_complete_rec.lumpsum_payment_type := l_offers_rec.lumpsum_payment_type;
   END IF;

   -- custom_setup_id
   IF p_offers_rec.custom_setup_id = FND_API.g_miss_num THEN
      x_complete_rec.custom_setup_id := l_offers_rec.custom_setup_id;
   END IF;

   -- security_group_id
   IF p_offers_rec.security_group_id = FND_API.g_miss_num THEN
      x_complete_rec.security_group_id := l_offers_rec.security_group_id;
   END IF;

   -- budget_amount_tc
   IF p_offers_rec.budget_amount_tc = FND_API.g_miss_num THEN
      x_complete_rec.budget_amount_tc := l_offers_rec.budget_amount_tc;
   END IF;

      -- security_group_id
   IF p_offers_rec.budget_amount_fc = FND_API.g_miss_num THEN
      x_complete_rec.budget_amount_fc := l_offers_rec.budget_amount_fc;
   END IF;

   -- transaction_currency_code
   IF p_offers_rec.transaction_currency_code = FND_API.g_miss_char THEN
      x_complete_rec.transaction_currency_code := l_offers_rec.transaction_currency_code;
   END IF;

   -- functional_currency_Code
   IF p_offers_rec.functional_currency_Code = FND_API.g_miss_char THEN
      x_complete_rec.functional_currency_Code := l_offers_rec.functional_currency_Code;
   END IF;

  -- qualifier_type
   IF p_offers_rec.qualifier_type = FND_API.g_miss_char THEN
      x_complete_rec.qualifier_type := l_offers_rec.qualifier_type;
   END IF;

  -- qualifier_id
   IF p_offers_rec.qualifier_id = FND_API.g_miss_num THEN
      x_complete_rec.qualifier_id := l_offers_rec.qualifier_id;
   END IF;

  -- distribution_type
   IF p_offers_rec.distribution_type = FND_API.g_miss_char THEN
      x_complete_rec.distribution_type := l_offers_rec.distribution_type;
   END IF;

  -- account_closed_flag
   IF p_offers_rec.account_closed_flag = FND_API.g_miss_char THEN
      x_complete_rec.account_closed_flag := l_offers_rec.account_closed_flag;
   END IF;

   -- budget_offer_yn
   IF p_offers_rec.budget_offer_yn = FND_API.g_miss_char THEN
      x_complete_rec.budget_offer_yn := l_offers_rec.budget_offer_yn;
   END IF;

   -- break_type
   IF p_offers_rec.break_type = FND_API.g_miss_char THEN
      x_complete_rec.break_type := l_offers_rec.break_type;
   END IF;

   -- budget_source_type
   IF p_offers_rec.budget_source_type = FND_API.g_miss_char THEN
      x_complete_rec.budget_source_type := l_offers_rec.budget_source_type;
   END IF;

   -- budget_source_id
   IF p_offers_rec.budget_source_id = FND_API.g_miss_num THEN
      x_complete_rec.budget_source_id := l_offers_rec.budget_source_id;
   END IF;

   -- confidential_flag
   IF p_offers_rec.confidential_flag = FND_API.g_miss_char THEN
      x_complete_rec.confidential_flag := l_offers_rec.confidential_flag;
   END IF;

   IF p_offers_rec.source_from_parent = FND_API.g_miss_char THEN
      x_complete_rec.source_from_parent := l_offers_rec.source_from_parent;
   END IF;

   IF p_offers_rec.buyer_name = FND_API.g_miss_char THEN
      x_complete_rec.buyer_name := l_offers_rec.buyer_name;
   END IF;

   IF p_offers_rec.last_recal_date = FND_API.g_miss_date THEN
      x_complete_rec.last_recal_date := l_offers_rec.last_recal_date;
   END IF;

   -- autopay_flag
   IF p_offers_rec.autopay_flag = FND_API.g_miss_char THEN
      x_complete_rec.autopay_flag := l_offers_rec.autopay_flag;
   END IF;

   -- autopay_days
   IF p_offers_rec.autopay_days = FND_API.g_miss_num THEN
      x_complete_rec.autopay_days := l_offers_rec.autopay_days;
   END IF;

   -- autopay_method
   IF p_offers_rec.autopay_method = FND_API.g_miss_char THEN
      x_complete_rec.autopay_method := l_offers_rec.autopay_method;
   END IF;

   -- autopay_party_attr
   IF p_offers_rec.autopay_party_attr = FND_API.g_miss_char THEN
      x_complete_rec.autopay_party_attr := l_offers_rec.autopay_party_attr;
   END IF;

   -- autopay_party_id
   IF p_offers_rec.autopay_party_id = FND_API.g_miss_num THEN
      x_complete_rec.autopay_party_id := l_offers_rec.autopay_party_id;
   END IF;

   IF p_offers_rec.tier_level = FND_API.g_miss_char THEN
--      x_complete_rec.tier_level := l_offers_rec.tier_level;
      x_complete_rec.tier_level := l_offers_rec.tier_level;
   END IF;


   IF p_offers_rec.na_rule_header_id = FND_API.g_miss_num THEN
      x_complete_rec.na_rule_header_id := l_offers_rec.na_rule_header_id;
   END IF;

   IF p_offers_rec.beneficiary_account_id = FND_API.g_miss_num THEN
      x_complete_rec.beneficiary_account_id := l_offers_rec.beneficiary_account_id;
   END IF;

   IF p_offers_rec.sales_method_flag = FND_API.G_MISS_CHAR THEN
      x_complete_rec.sales_method_flag := l_offers_rec.sales_method_flag;
   END IF;

   IF p_offers_rec.org_id = FND_API.g_miss_num THEN
      x_complete_rec.org_id := l_offers_rec.org_id;
   END IF;

   -- Note: Developers need to modify the procedure

   -- to handle any business specific requirements.
END Complete_offers_Rec;

PROCEDURE Update_Offers(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offers_rec               IN    offers_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS

  CURSOR c_get_offers(p_offer_id NUMBER) IS
  SELECT object_version_number
    FROM  OZF_OFFERS
   WHERE qp_list_header_id = p_offer_id;
   -- Hint: Developer need to provide Where clause

  CURSOR c_get_old_owner(l_list_header_id NUMBER) IS
  SELECT owner_id
    FROM ozf_offers
   WHERE qp_list_header_id = l_list_header_id;

   CURSOR c_get_start_date IS
   SELECT q.start_date_active, o.start_date
     FROM qp_list_headers_b q, ozf_offers o
    WHERE o.qp_list_header_id = q.list_header_id
      AND q.list_header_id = p_offers_rec.qp_list_header_id;

  l_api_name                  CONSTANT VARCHAR2(30) := 'Update_Offers';
  l_api_version_number        CONSTANT NUMBER   := 1.0;
  -- Local Variables
  l_object_version_number     NUMBER;
  l_OFFER_ID    NUMBER;

  l_tar_offers_rec  OZF_Promotional_Offers_PVT.offers_rec_type := P_offers_rec;
  l_rowid  ROWID;
  l_is_owner      VARCHAR2(1);
  l_is_admin      BOOLEAN;
  l_old_owner_id  NUMBER;
  l_offers_rec OZF_Promotional_Offers_PVT.offers_rec_type;
  l_last_recal_date DATE;
  l_start_date_o    DATE;
  l_start_date      DATE;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Offers_PVT;

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

      OPEN c_get_Offers( l_tar_offers_rec.qp_list_header_id);
      FETCH c_get_Offers INTO l_object_version_number;

       If ( c_get_Offers%NOTFOUND) THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
              p_token_name   => 'INFO',
              p_token_value  => 'Offers') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE     c_get_Offers;

      -- Check Whether record has been changed by someone else
      If l_tar_offers_rec.object_version_number IS NOT NULL
      AND l_tar_offers_rec.object_version_number <> FND_API.G_MISS_NUM
      AND l_tar_offers_rec.object_version_number <> l_object_version_number Then
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Offers') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Invoke validation procedures
          Validate_offers(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_offers_rec  =>  p_offers_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- added by julou 07/29/2002  check if the owner is changed. if so, update the owner inof in ams_act_access
      -- only the owner and super user can change the owner
      -- check if login user is the owner.
      OPEN c_get_old_owner(p_offers_rec.qp_list_header_id);
      FETCH c_get_old_owner INTO l_old_owner_id;
      CLOSE c_get_old_owner;

      Complete_offers_Rec(
         p_offers_rec        => p_offers_rec,
         x_complete_rec        => l_offers_rec
      );

      IF l_offers_rec.owner_id <> l_old_owner_id THEN
        l_is_owner := AMS_access_PVT.check_owner(p_object_id         => l_offers_rec.qp_list_header_id
                                                ,p_object_type       => 'OFFR'
                                                ,p_user_or_role_id   => ozf_utility_pvt.get_resource_id(FND_GLOBAL.user_id)
                                                ,p_user_or_role_type => 'USER');
        -- check if login user is super user
        l_is_admin := AMS_Access_PVT.Check_Admin_Access(ozf_utility_pvt.get_resource_id(FND_GLOBAL.user_id));

        IF l_is_owner = 'Y' OR l_is_admin THEN -- curent user is owner/admin, changing owner is allowed
          AMS_access_PVT.update_object_owner(
            p_api_version       => l_api_version_number,
            p_init_msg_list     => FND_API.g_false,
            p_commit            => FND_API.g_false,
            p_validation_level  => FND_API.g_valid_level_full,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_object_type       => 'OFFR',
            p_object_id         => l_offers_rec.qp_list_header_id,
            p_resource_id       => l_offers_rec.owner_id,
            p_old_resource_id   => l_old_owner_id);

          IF x_return_status =  fnd_api.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
          ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
          END IF;
        ELSE -- not owner nor super user
          OZF_Utility_PVT.error_message('OZF_OFFR_UPDT_OWNER_PERM');
          RAISE FND_API.g_exc_error;
        END IF;
      END IF;
      -- end of offer security change
   -- julou defaulting last_recal_date to offer start date
   OPEN c_get_start_date;
   FETCH c_get_start_date INTO l_last_recal_date, l_start_date_o;
   CLOSE c_get_start_date;

   IF l_offers_rec.status_code = 'ACTIVE' THEN
     IF l_start_date_o IS NULL THEN
       l_start_date := GREATEST(NVL(l_last_recal_date, SYSDATE), SYSDATE);
     ELSE
       l_start_date := l_start_date_o;
     END IF;
   ELSE
     l_start_date := l_start_date_o;
   END IF;
   -- end julou

      -- Invoke table handler(OZF_Promotional_Offers_PKG.Update_Row)
      OZF_Promotional_Offers_PKG.Update_Row(
          p_offer_id  => l_offers_rec.offer_id,
          p_qp_list_header_id  => l_offers_rec.qp_list_header_id,
          p_offer_type  => l_offers_rec.offer_type,
          p_offer_code  => l_offers_rec.offer_code,
          p_activity_media_id  => l_offers_rec.activity_media_id,
          p_reusable  => l_offers_rec.reusable,
          p_user_status_id  => l_offers_rec.user_status_id,
          p_owner_id  => l_offers_rec.owner_id,
          p_wf_item_key  => l_offers_rec.wf_item_key,
          p_customer_reference  => l_offers_rec.customer_reference,
          p_buying_group_contact_id  => l_offers_rec.buying_group_contact_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.user_id,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_object_version_number  => l_offers_rec.object_version_number,
          p_perf_date_from  => l_offers_rec.perf_date_from,
          p_perf_date_to  => l_offers_rec.perf_date_to,
          p_status_code  => l_offers_rec.status_code,
          p_status_date  => l_offers_rec.status_date,
          p_modifier_level_code  => l_offers_rec.modifier_level_code,
          p_order_value_discount_type  => l_offers_rec.order_value_discount_type,
          p_offer_amount  => l_offers_rec.offer_amount,
          p_lumpsum_amount  => l_offers_rec.lumpsum_amount,
          p_lumpsum_payment_type  => l_offers_rec.lumpsum_payment_type,
          p_custom_setup_id             => l_offers_rec.custom_setup_id,
          p_security_group_id           => l_offers_rec.security_group_id,
          p_budget_amount_tc            => l_offers_rec.budget_amount_tc,
          p_budget_amount_fc            => l_offers_rec.budget_amount_fc,
          p_transaction_currency_Code   => l_offers_rec.transaction_currency_Code ,
          p_functional_currency_code    => l_offers_rec.functional_currency_code,
          p_distribution_type           => l_offers_rec.distribution_type,
          p_qualifier_id                => l_offers_rec.qualifier_id,
          p_qualifier_type              => l_offers_rec.qualifier_type,
	        p_account_closed_flag         => l_offers_rec.account_closed_flag,
          p_budget_offer_yn             => l_offers_rec.budget_offer_yn,
          p_break_type                  => l_offers_rec.break_type,
          p_retroactive                 => l_offers_rec.retroactive,
          p_volume_offer_type           => l_offers_rec.volume_offer_type,
          p_confidential_flag           => l_offers_rec.confidential_flag,
          p_budget_source_type          => l_offers_rec.budget_source_type,
          p_budget_source_id            => l_offers_rec.budget_source_id,
          p_source_from_parent          => l_offers_rec.source_from_parent,
          p_buyer_name                  => l_offers_rec.buyer_name,
          p_last_recal_date             => l_last_recal_date,
          p_date_qualifier              => FND_API.G_MISS_CHAR,
          p_autopay_flag                => l_offers_rec.autopay_flag,
          p_autopay_days                => l_offers_rec.autopay_days,
          p_autopay_method              => l_offers_rec.autopay_method,
          p_autopay_party_attr          => l_offers_rec.autopay_party_attr,
          p_autopay_party_id            => l_offers_rec.autopay_party_id,
          p_tier_level                  => l_offers_rec.tier_level,
          p_na_rule_header_id           => l_offers_rec.na_rule_header_id,
          p_beneficiary_account_id      => l_offers_rec.beneficiary_account_id,
          p_sales_method_flag                => l_offers_rec.sales_method_flag,
          p_org_id                      => l_offers_rec.org_id,
          p_start_date                  => l_start_date
          );
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data,
         p_encoded        =>   FND_API.G_FALSE
      );
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Offers_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Offers_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
/*
   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Offers_PVT;
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
     */
End Update_Offers;


PROCEDURE Delete_Offers(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_offer_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Offers';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Offers_PVT;

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

      --
      -- Api body
      --

      -- Invoke table handler(OZF_Promotional_Offers_PKG.Delete_Row)
      OZF_Promotional_Offers_PKG.Delete_Row(
          p_OFFER_ID  => p_OFFER_ID);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Offers_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Offers_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Offers_PVT;
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
End Delete_Offers;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Offers(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offer_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Offers';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_OFFER_ID                  NUMBER;

CURSOR c_Offers IS
   SELECT OFFER_ID
   FROM OZF_OFFERS
   WHERE OFFER_ID = p_OFFER_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN

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

  OPEN c_Offers;

  FETCH c_Offers INTO l_OFFER_ID;

  IF (c_Offers%NOTFOUND) THEN
    CLOSE c_Offers;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Offers;

 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);

EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Offers_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Offers_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Offers_PVT;
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
End Lock_Offers;


PROCEDURE check_offers_uk_items(
    p_offers_rec               IN   offers_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create  THEN

         l_valid_flag := OZF_Utility_PVT.check_uniqueness(
                                       'OZF_OFFERS',
                                       'OFFER_ID = '|| p_offers_rec.OFFER_ID
                                        );

      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFER_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_validation_mode = JTF_PLSQL_API.g_create  THEN

         l_valid_flag := OZF_Utility_PVT.check_uniqueness(
                                       'OZF_OFFERS',
                                       'qp_list_header_id = '|| p_offers_rec.qp_list_header_id
                                        );

      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFER_QP_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


END check_offers_uk_items;

PROCEDURE check_offers_req_items(
    p_offers_rec               IN  offers_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2
)
IS

  CURSOR C_OFFER_END_DATE IS
  SELECT end_date_active
  FROM   qp_list_headers_b
  WHERE  list_header_id = p_offers_rec.qp_list_header_id;

  l_offer_end_date    DATE;

BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_offers_rec.offer_id = FND_API.g_miss_num OR p_offers_rec.offer_id IS NULL THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFERS_NO_OFFER_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_offers_rec.qp_list_header_id = FND_API.g_miss_num OR p_offers_rec.qp_list_header_id IS NULL THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFERS_NO_LIST_HEADER_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_offers_rec.offer_type = FND_API.g_miss_char OR p_offers_rec.offer_type IS NULL THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFERS_NO_OFFER_TYPE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_offers_rec.offer_code = FND_API.g_miss_char OR p_offers_rec.offer_code IS NULL THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFERS_NO_OFFER_CODE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_offers_rec.user_status_id = FND_API.g_miss_num OR p_offers_rec.user_status_id IS NULL THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFERS_NO_USER_STATUS_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_offers_rec.offer_type = 'SCAN_DATA' THEN
        IF p_offers_rec.activity_media_id = FND_API.g_miss_num OR p_offers_rec.activity_media_id IS NULL THEN
          OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFERS_NO_ACTIVITY');
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
        END IF;
      END IF;

     IF p_offers_rec.autopay_flag = 'Y' THEN
       IF p_offers_rec.autopay_days IS NULL THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFR_NO_AUTOPAY_DAYS');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
       END IF;

       IF p_offers_rec.autopay_method IS NULL THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFR_NO_AUTOPAY_METHOD');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
       END IF;

       IF p_offers_rec.autopay_party_id IS NULL THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFR_NO_AUTOPAY_PARTY_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
       END IF;

       OPEN c_offer_end_date;
       FETCH c_offer_end_date INTO l_offer_end_date;
       CLOSE c_offer_end_date;
       IF l_offer_end_date IS NULL THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFR_NO_END_DATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
       END IF;
     END IF;

      IF p_offers_rec.offer_type = 'NET_ACCRUAL' THEN
        IF p_offers_rec.tier_level = FND_API.g_miss_char OR p_offers_rec.tier_level IS NULL THEN
          OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFR_INVALID_TIER_LVL');
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
        END IF;

        IF p_offers_rec.custom_setup_id <> 105 THEN -- customer not required for PV offer
          IF p_offers_rec.qualifier_id IS NULL OR p_offers_rec.qualifier_id = FND_API.g_miss_num THEN
            OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFR_NO_CUSTOMER');
            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
          END IF;
        END IF;
      END IF;
   ELSE


      IF p_offers_rec.offer_id IS NULL THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFERS_NO_OFFER_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_offers_rec.qp_list_header_id IS NULL THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFERS_NO_LIST_HEADER_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_offers_rec.offer_type IS NULL THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFERS_NO_OFFER_TYPE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_offers_rec.offer_code IS NULL THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFERS_NO_OFFER_CODE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_offers_rec.user_status_id IS NULL THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFERS_NO_USER_STATUS_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_offers_rec.offer_type = 'SCAN_DATA' THEN
        IF p_offers_rec.activity_media_id IS NULL OR p_offers_rec.activity_media_id = FND_API.g_miss_num THEN
          OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFERS_NO_ACTIVITY');
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
        END IF;
      END IF;

      IF p_offers_rec.offer_type = 'NET_ACCRUAL' THEN
        IF p_offers_rec.tier_level = FND_API.g_miss_char OR p_offers_rec.tier_level IS NULL THEN
          OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFR_INVALID_TIER_LVL');
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
        END IF;

        IF p_offers_rec.custom_setup_id <> 105 THEN -- customer not required for PV offer
          IF p_offers_rec.qualifier_id IS NULL OR p_offers_rec.qualifier_id = FND_API.g_miss_num THEN
            OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFR_NO_CUSTOMER');
            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
          END IF;
        END IF;
      END IF;
   END IF;


END check_offers_req_items;

PROCEDURE check_offers_FK_items(
    p_offers_rec IN offers_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS

  CURSOR c_media_id(l_id NUMBER) IS
  SELECT 1
  FROM   ams_media_vl
  WHERE  media_type_code = 'DEAL'
  AND    media_id = l_id;

  l_dummy  NUMBER;

BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   ---  checking the owner_id
   IF p_offers_rec.owner_id <> FND_API.g_miss_num   THEN
      IF OZF_Utility_PVT.check_fk_exists(
            'jtf_rs_resource_extns',
            'resource_id',
            p_offers_rec.owner_id ) = FND_API.g_false
      THEN
         OZF_Utility_PVT.Error_Message('OZF_OFR_BAD_USER_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ---  checking the qp_list_header_id
   IF p_offers_rec.qp_list_header_id <> FND_API.G_MISS_NUM  THEN
      IF OZF_Utility_PVT.check_fk_exists(
                      'qp_list_headers_b'
                      ,'list_header_id '
                      ,p_offers_rec.qp_list_header_id) = FND_API.g_false
      THEN
         OZF_Utility_PVT.Error_Message('OZF_OFFR_BAD_QP_LIST_HEADER_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- checking the  custom_setup_id
   IF p_offers_rec.custom_setup_id <> FND_API.g_miss_num
   AND p_offers_rec.custom_setup_id IS NOT NULL
   THEN
      IF OZF_Utility_PVT.check_fk_exists(
                      'ams_custom_setups_vl'
                      ,'custom_setup_id '
                      ,p_offers_rec.custom_setup_id) = FND_API.g_false
      THEN
         OZF_Utility_PVT.Error_Message('OZF_OFFR_BAD_CUSTOM_SETUP_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- checking the user_status_id
   IF p_offers_rec.user_status_id <> FND_API.G_MISS_NUM
   AND p_offers_rec.user_status_id IS NOT NULL
   THEN
      IF OZF_Utility_PVT.check_fk_exists(
                      'ams_user_statuses_vl'
                      ,'user_status_id '
                      ,p_offers_rec.user_status_id) = FND_API.g_false
      THEN
         OZF_Utility_PVT.Error_Message('OZF_OFFR_BAD_USER_STATUS_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;


   -- checking the activity_media_id
   IF p_offers_rec.activity_media_id <> FND_API.G_MISS_NUM
   AND p_offers_rec.activity_media_id IS NOT NULL
   THEN
     OPEN c_media_id(p_offers_rec.activity_media_id);
     FETCH c_media_id INTO l_dummy;
     CLOSE c_media_id;

     IF l_dummy IS NULL
     THEN
       OZF_Utility_PVT.Error_Message('OZF_OFFR_BAD_MEDIA_ID');
       x_return_status := FND_API.g_ret_sts_error;
       RETURN;
     END IF;
  END IF;

    IF p_offers_rec.offer_type = 'NET_ACCRUAL' THEN
        IF p_offers_rec.na_rule_header_id IS NOT NULL AND p_offers_rec.na_rule_header_id <> FND_API.G_MISS_NUM THEN
            IF ozf_utility_pvt.check_fk_exists('ozf_na_rule_headers_b'
                                            ,'NA_RULE_HEADER_ID'
                                            ,p_offers_rec.na_rule_header_id) = FND_API.G_FALSE
              THEN
             OZF_Utility_PVT.Error_Message('OZF_OFFR_BAD_NA_RULE_HEADER_ID');
             x_return_status := FND_API.g_ret_sts_error;
             RETURN;
             END IF;
        END IF;
    END IF;
END check_offers_FK_items;

PROCEDURE check_offers_Lookup_items(
    p_offers_rec IN offers_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   --  modifier_level_code
   IF p_offers_rec.modifier_level_code <> FND_API.g_miss_char
   AND p_offers_rec.modifier_level_code IS NOT NULL
   THEN
      IF OZF_Utility_PVT.check_lookup_exists(
            p_lookup_table_name => 'qp_lookups'
            ,p_lookup_type       => 'MODIFIER_LEVEL_CODE'
            ,p_lookup_code       => p_offers_rec.modifier_level_code
         ) = FND_API.g_false
      THEN
         --OZF_Utility_PVT.Error_Message('OZF_OFR_BAD_MODIFIER_LEVEL_CODE') ;
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('OZF', 'OZF_OFR_BAD_MODIFIER_LEVEL_COD');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --- order_value_discount_type
   --- reminder : This lookup has to be created . -musman 04/20
   IF p_offers_rec.order_value_discount_type <> FND_API.g_miss_char
   AND p_offers_rec.order_value_discount_type IS NOT NULL
   THEN
      IF OZF_Utility_PVT.check_lookup_exists(
            p_lookup_type       => 'OZF_OFFER_OV_DISCOUNT_TYPE',
            p_lookup_code       => p_offers_rec.order_value_discount_type
         ) = FND_API.g_false
      THEN
         OZF_Utility_PVT.Error_Message('OZF_OFR_BAD_DISCOUNT_TYPE') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   IF p_offers_rec.lumpsum_payment_type <> FND_API.g_miss_char
   AND p_offers_rec.lumpsum_payment_type IS NOT NULL
   THEN
      IF OZF_Utility_PVT.check_lookup_exists(
            p_lookup_type       => 'OZF_OFFER_LUMPSUM_PAYMENT',
            p_lookup_code       => p_offers_rec.lumpsum_payment_type
         ) = FND_API.g_false
      THEN
         OZF_Utility_PVT.Error_Message('OZF_OFR_BAD_DISCOUNT_TYPE') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- status code
   IF p_offers_rec.status_code <> FND_API.g_miss_char
   AND p_offers_rec.status_code IS NOT NULL
   THEN
      IF OZF_Utility_PVT.check_lookup_exists(
            p_lookup_type       => 'OZF_OFFER_STATUS',
            p_lookup_code       => p_offers_rec.status_code
         ) = FND_API.g_false
      THEN
         OZF_Utility_PVT.Error_Message('OZF_OFR_BAD_STATUS_CODE') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- offer_type
   IF p_offers_rec.offer_type <> FND_API.g_miss_char
   AND p_offers_rec.offer_type IS NOT NULL
   THEN
      IF OZF_Utility_PVT.check_lookup_exists(
            p_lookup_type       => 'OZF_OFFER_TYPE',
            p_lookup_code       => p_offers_rec.offer_type
         ) = FND_API.g_false
      THEN
         OZF_Utility_PVT.Error_Message('OZF_OFR_BAD_OFFER_TYPE') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- break_type
   IF p_offers_rec.offer_type = 'OID' THEN
      IF OZF_Utility_PVT.check_lookup_exists(
            p_lookup_type       => 'OZF_OFFER_BREAK_TYPE',
            p_lookup_code       => p_offers_rec.break_type
         ) = FND_API.g_false
      THEN
         OZF_Utility_PVT.Error_Message('OZF_OFR_BAD_BREAK_TYPE') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
/*
   IF p_offers_rec.autopay_method <> FND_API.g_miss_char
   AND p_offers_rec.autopay_method IS NOT NULL
   THEN
      IF OZF_Utility_PVT.check_lookup_exists(
            p_lookup_table_name => 'OZF_lookups'
            ,p_lookup_type       => 'OZF_OFFER_AUTOPAY_METHOD'
            ,p_lookup_code       => p_offers_rec.autopay_method
         ) = FND_API.g_false
      THEN
         --OZF_Utility_PVT.Error_Message('OZF_OFR_BAD_MODIFIER_LEVEL_CODE') ;
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('OZF', 'OZF_OFFR_BAD_PAYMENT_METHOD');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   IF p_offers_rec.autopay_party_attr <> FND_API.g_miss_char
   AND p_offers_rec.autopay_party_attr IS NOT NULL
   THEN
      IF OZF_Utility_PVT.check_lookup_exists(
            p_lookup_table_name => 'ozf_lookups'
            ,p_lookup_type       => 'OZF_AUTOPAY_CUST_TYPES'
            ,p_lookup_code       => p_offers_rec.autopay_party_attr
         ) = FND_API.g_false
      THEN
         --OZF_Utility_PVT.Error_Message('OZF_OFR_BAD_MODIFIER_LEVEL_CODE') ;
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('OZF', 'OZF_OFFR_BAD_AUTOPAY_CUSTTYPE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
*/
END check_offers_Lookup_items;

PROCEDURE check_offers_flag_items(
   p_offers_rec      IN  offers_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- active_flag ------------------------
   IF p_offers_rec.reusable <> FND_API.g_miss_char
   AND p_offers_rec.reusable IS NOT NULL
   THEN
      IF OZF_Utility_PVT.is_Y_or_N(p_offers_rec.reusable) = FND_API.g_false
      THEN
         OZF_Utility_PVT.Error_Message('OZF_OFR_BAD_REUSABLE_FLAG');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_offers_flag_items;


PROCEDURE check_offers_inter_entity(
   p_offers_rec           IN    offers_rec_type
   ,x_return_status       OUT NOCOPY   VARCHAR2
   )
IS

l_start_date  DATE ;
l_end_date    DATE;

BEGIN

    x_return_status := FND_API.g_ret_sts_success;

   --checking the perf date from and to

   IF p_offers_rec.perf_date_from IS NOT NULL
   AND p_offers_rec.perf_date_from <> FND_API.G_MISS_DATE
   AND p_offers_rec.perf_date_to IS NOT NULL
   AND p_offers_rec.perf_date_to <> FND_API.G_MISS_DATE
   THEN
      l_start_date := p_offers_rec.perf_date_from;
      l_end_date := p_offers_rec.perf_date_to;
      IF l_start_date > l_end_date THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('OZF', 'OZF_OFR_SHIP_START_AFTER_END');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

END check_offers_inter_entity;



PROCEDURE Check_offers_Items (
    P_offers_rec     IN    offers_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls
   check_offers_uk_items(
      p_offers_rec => p_offers_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls
   check_offers_req_items(
      p_offers_rec => p_offers_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Foreign Keys API calls

   check_offers_FK_items(
      p_offers_rec => p_offers_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Lookups

   check_offers_Lookup_items(
      p_offers_rec => p_offers_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- check  the flags

   check_offers_flag_items(
      p_offers_rec    =>  p_offers_rec
     ,x_return_status =>  x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   --check the offer inter entity
   check_offers_inter_entity(
      p_offers_rec    =>  p_offers_rec
     ,x_return_status =>  x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_offers_Items;



PROCEDURE Validate_offers(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_offers_rec               IN   offers_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Offers';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_offers_rec  OZF_Promotional_Offers_PVT.offers_rec_type;


 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Offers_;

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

      x_return_status := FND_API.g_ret_sts_success;

      Complete_offers_Rec(
         p_offers_rec        => p_offers_rec,
         x_complete_rec        => l_offers_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              Check_offers_Items(
                 p_offers_rec        => l_offers_rec,
                 p_validation_mode   => JTF_PLSQL_API.g_update,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_offers_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_offers_rec           =>    l_offers_rec);

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
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Offers_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Offers_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Offers_;
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
End Validate_Offers;


PROCEDURE Validate_offers_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_offers_rec               IN    offers_rec_type
    )
IS

    l_api_name varchar2(20) := 'Validate_offers_rec';
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

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_offers_Rec;

PROCEDURE handle_status(
   p_user_status_id  IN  NUMBER,
   x_status_code     OUT NOCOPY VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS

   l_status_code     VARCHAR2(30);

   CURSOR c_status_code IS
   SELECT system_status_code
     FROM ams_user_statuses_vl
    WHERE user_status_id = p_user_status_id
      AND system_status_type = 'OZF_OFFER_STATUS'
      AND enabled_flag = 'Y';

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   OPEN c_status_code;
   FETCH c_status_code INTO l_status_code;
   CLOSE c_status_code;

   IF l_status_code IS NULL THEN
      x_return_status := FND_API.g_ret_sts_error;
      OZF_Utility_PVT.error_message('OZF_OFFR_BAD_USER_STATUS_ID');
   END IF;

   x_status_code := l_status_code;

END handle_status;

PROCEDURE handle_status(
   x_status_id       OUT NOCOPY NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS

   l_status_id  NUMBER;

   CURSOR c_status_id IS
   SELECT user_status_id
     FROM ams_user_statuses_vl
    WHERE system_status_type = 'OZF_OFFER_STATUS'
      AND system_status_code = 'DRAFT'
      AND default_flag = 'Y'
      AND enabled_flag = 'Y';

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   OPEN c_status_id;
   FETCH c_status_id INTO l_status_id;
   CLOSE c_status_id;

   IF l_status_id IS NULL THEN
      x_return_status := FND_API.g_ret_sts_error;
      OZF_Utility_PVT.error_message('OZF_OFFR_BAD_USER_STATUS_ID');
   END IF;

   x_status_id := l_status_id;

END handle_status;

END OZF_Promotional_Offers_PVT;

/
