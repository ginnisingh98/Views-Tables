--------------------------------------------------------
--  DDL for Package Body OZF_PARTNER_CLAIM_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_PARTNER_CLAIM_GRP" AS
/* $Header: ozfgpclb.pls 120.3 2005/10/05 00:22:30 kdhulipa ship $ */
-- Start of Comments
-- Package name     : OZF_PARTNER_CLAIM_GRP
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME                 CONSTANT  VARCHAR2(30) := 'OZF_PARTNER_CLAIM_GRP';
G_FILE_NAME                CONSTANT  VARCHAR2(12) := 'ozfgpclb.pls';

OZF_DEBUG_HIGH_ON          CONSTANT  BOOLEAN      := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON           CONSTANT  BOOLEAN      := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);

---------------------------------------------------------------------
--   PROCEDURE:  Create_Claim
--
--   PURPOSE:
--
--   PARAMETERS:
--   IN
--       p_api_version_number      IN   NUMBER                      Required
--       p_init_msg_list           IN   VARCHAR2                    Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2                    Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER                      Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_claim_rec               IN   CLAIM_REC_TYPE              Required
--       p_promotion_activity_tbl  IN   PROMOTION_ACTIVITY_TBL_TYPE Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_claim_id                OUT  NUMBER
--       x_claim_number            OUT  VARCHAR2
--       x_claim_amount            OUT  NUMBER
--
--   NOTES:
--
---------------------------------------------------------------------
PROCEDURE Create_Claim(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_commit                     IN   VARCHAR2,

    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,

    p_claim_rec                  IN   CLAIM_REC_TYPE,
    p_promotion_activity_rec     IN   PROMOTION_ACTIVITY_REC_TYPE,
    x_claim_id                   OUT  NOCOPY NUMBER,
    x_claim_number               OUT  NOCOPY VARCHAR2,
    x_claim_amount               OUT  NOCOPY NUMBER
)
IS
l_api_version                CONSTANT NUMBER       := 1.0;
l_api_name                   CONSTANT VARCHAR2(30) := 'Create_Claim';
l_full_name                  CONSTANT VARCHAR2(60) := G_PKG_NAME||'.'||l_api_name;
l_return_status                       VARCHAR2(1);
---
CURSOR csr_claim(cv_claim_id IN NUMBER) IS
   SELECT claim_id
   ,      claim_number
   ,      amount
   FROM ozf_claims_all
   WHERE claim_id = cv_claim_id;

l_claim_pub_rec                       CLAIM_REC_TYPE := p_claim_rec;
l_claim_pvt_rec                       OZF_Claim_PVT.claim_rec_type;
l_funds_util_flt                      OZF_Claim_Accrual_PVT.funds_util_flt_type;
l_claim_id                            NUMBER;

-- [BEGIN OF BUG 4067282 FIXING]
l_session_org_id                      NUMBER;

CURSOR csr_utiz_order(cv_claim_id IN NUMBER) IS
   SELECT ln.claim_line_id
   ,      ut.object_type
   ,      ut.object_id
   FROM ozf_funds_utilized_all_b ut
   ,    ozf_claim_lines_util_all lu
   ,    ozf_claim_lines_all ln
   WHERE ln.claim_id = cv_claim_id
   AND   ln.claim_line_id = lu.claim_line_id
   AND   lu.utilization_id = ut.utilization_id
   AND   ut.object_type = 'ORDER';

l_claim_line_id         NUMBER;
l_source_object_class   OZF_CLAIMS_ALL.source_object_class%TYPE;
l_source_object_id      OZF_CLAIMS_ALL.source_object_id%TYPE;

-- [END OF BUG 4067282 FIXING]

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Create_Partner_Claim;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      FND_MESSAGE.Set_Name('AMS','AMS_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
      FND_MSG_PUB.Add;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- [BEGIN OF BUG 4067282 FIXING]
   l_session_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();  -- R12 Enahancements.

   IF p_claim_rec.org_id IS NOT NULL THEN
      MO_GLOBAL.set_policy_context('S', p_claim_rec.org_id);  -- R12 Enhancements
   END IF;
   -- [END OF BUG 4067282 FIXING]

   -----------------------------
   -- 1. Assignment Qualifier --
   -----------------------------
   -- raise business event
   OZF_CLAIM_SETTLEMENT_PVT.Raise_Business_Event(
       p_api_version            => l_api_version
      ,p_init_msg_list          => FND_API.g_false
      ,p_commit                 => FND_API.g_false
      ,p_validation_level       => FND_API.g_valid_level_full
      ,x_return_status          => l_return_status
      ,x_msg_data               => x_msg_data
      ,x_msg_count              => x_msg_count

      ,p_claim_id               => 000999
      ,p_old_status             => NULL
      ,p_new_status             => 'NEW'
      ,p_event_name             => 'oracle.apps.ozf.claim.assignQualifier'
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -----------------------------------------
   -- 2. Minimum required fields checking --
   -----------------------------------------
   -- First, check whether all the required fields are filled for deductions.
   -- These fields are
   --                  cust_account_id
   --                  currency_code
   --                  source_object_id
   --                  source_object_class
   --                  source_object_number
   IF l_claim_pub_rec.source_object_id IS NULL OR
      l_claim_pub_rec.source_object_class IS NULL OR
      l_claim_pub_rec.source_object_number IS NULL OR
      l_claim_pub_rec.currency_code IS NULL OR
      l_claim_pub_rec.cust_account_id IS NULL THEN
      IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name('OZF','OZF_REQUIRED_FIELDS_MISSING');
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   ------------------------------------------
   -- 3. Default and derive column valude  --
   ------------------------------------------
   l_claim_pvt_rec.claim_type_id                := l_claim_pub_rec.claim_type_id;
   l_claim_pvt_rec.claim_date                   := l_claim_pub_rec.claim_date;
   l_claim_pvt_rec.due_date                     := l_claim_pub_rec.due_date;
   l_claim_pvt_rec.gl_date                      := l_claim_pub_rec.gl_date;
   l_claim_pvt_rec.owner_id                     := l_claim_pub_rec.owner_id;
   l_claim_pvt_rec.amount                       := l_claim_pub_rec.amount;
   l_claim_pvt_rec.currency_code                := l_claim_pub_rec.currency_code;
   l_claim_pvt_rec.exchange_rate_type           := l_claim_pub_rec.exchange_rate_type;
   l_claim_pvt_rec.exchange_rate_date           := l_claim_pub_rec.exchange_rate_date;
   l_claim_pvt_rec.exchange_rate                := l_claim_pub_rec.exchange_rate;
   l_claim_pvt_rec.set_of_books_id              := l_claim_pub_rec.set_of_books_id;
   l_claim_pvt_rec.source_object_id             := l_claim_pub_rec.source_object_id;
   l_claim_pvt_rec.source_object_class          := l_claim_pub_rec.source_object_class;
   l_claim_pvt_rec.source_object_type_id        := l_claim_pub_rec.source_object_type_id;
   l_claim_pvt_rec.source_object_number         := l_claim_pub_rec.source_object_number;
   l_claim_pvt_rec.cust_account_id              := l_claim_pub_rec.cust_account_id;
   l_claim_pvt_rec.cust_billto_acct_site_id     := l_claim_pub_rec.cust_billto_acct_site_id;
   l_claim_pvt_rec.cust_shipto_acct_site_id     := l_claim_pub_rec.cust_shipto_acct_site_id;
   l_claim_pvt_rec.related_cust_account_id      := l_claim_pub_rec.pay_to_cust_account_id;
   l_claim_pvt_rec.reason_code_id               := l_claim_pub_rec.reason_code_id;
   l_claim_pvt_rec.customer_reason              := l_claim_pub_rec.customer_reason;
   l_claim_pvt_rec.status_code                  := l_claim_pub_rec.status_code;
   l_claim_pvt_rec.user_status_id               := l_claim_pub_rec.user_status_id;
   l_claim_pvt_rec.sales_rep_id                 := l_claim_pub_rec.sales_rep_id;
   l_claim_pvt_rec.collector_id                 := l_claim_pub_rec.collector_id;
   l_claim_pvt_rec.contact_id                   := l_claim_pub_rec.contact_id;
   l_claim_pvt_rec.broker_id                    := l_claim_pub_rec.broker_id;
   l_claim_pvt_rec.customer_ref_date            := l_claim_pub_rec.customer_ref_date;
   l_claim_pvt_rec.customer_ref_number          := l_claim_pub_rec.customer_ref_number;
   l_claim_pvt_rec.comments                     := l_claim_pub_rec.comments;
   l_claim_pvt_rec.attribute_category           := l_claim_pub_rec.attribute_category;
   l_claim_pvt_rec.attribute1                   := l_claim_pub_rec.attribute1;
   l_claim_pvt_rec.attribute2                   := l_claim_pub_rec.attribute2;
   l_claim_pvt_rec.attribute3                   := l_claim_pub_rec.attribute3;
   l_claim_pvt_rec.attribute4                   := l_claim_pub_rec.attribute4;
   l_claim_pvt_rec.attribute5                   := l_claim_pub_rec.attribute5;
   l_claim_pvt_rec.attribute6                   := l_claim_pub_rec.attribute6;
   l_claim_pvt_rec.attribute7                   := l_claim_pub_rec.attribute7;
   l_claim_pvt_rec.attribute8                   := l_claim_pub_rec.attribute8;
   l_claim_pvt_rec.attribute9                   := l_claim_pub_rec.attribute9;
   l_claim_pvt_rec.attribute10                  := l_claim_pub_rec.attribute10;
   l_claim_pvt_rec.attribute11                  := l_claim_pub_rec.attribute11;
   l_claim_pvt_rec.attribute12                  := l_claim_pub_rec.attribute12;
   l_claim_pvt_rec.attribute13                  := l_claim_pub_rec.attribute13;
   l_claim_pvt_rec.attribute14                  := l_claim_pub_rec.attribute14;
   l_claim_pvt_rec.attribute15                  := l_claim_pub_rec.attribute15;
   l_claim_pvt_rec.org_id                       := l_claim_pub_rec.org_id;

   l_funds_util_flt.activity_type               := 'OFFR';
   l_funds_util_flt.activity_id                 := p_promotion_activity_rec.offer_id;
   l_funds_util_flt.activity_product_id         := p_promotion_activity_rec.item_id;
   l_funds_util_flt.reference_type              := p_promotion_activity_rec.reference_type;
   l_funds_util_flt.reference_id                := p_promotion_activity_rec.reference_id;


   ------------------------------------------
   -- 4. Call OZF_CLAIM_ACCRUL_PVT
   ------------------------------------------
   OZF_Claim_Accrual_PVT.Create_Claim_For_Accruals(
     p_api_version         => l_api_version
    ,p_init_msg_list       => FND_API.g_false
    ,p_commit              => FND_API.g_false
    ,p_validation_level    => FND_API.g_valid_level_full

    ,x_return_status       => l_return_status
    ,x_msg_count           => x_msg_count
    ,x_msg_data            => x_msg_data

    ,p_claim_rec           => l_claim_pvt_rec
    ,p_funds_util_flt      => l_funds_util_flt

    ,x_claim_id            => l_claim_id
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- [BEGIN OF BUG 4067282 FIXING]: Update Claim Line with Order information
   -- Assumption: per referral claim <--> per order
   -- Fix for Bug4576309: Replaced call to table handler with a direct update
   OPEN csr_utiz_order(l_claim_id);
   LOOP
       FETCH csr_utiz_order INTO l_claim_line_id
                           , l_source_object_class
                           , l_source_object_id;
       EXIT WHEN csr_utiz_order%NOTFOUND;
       IF l_source_object_id IS NOT NULL THEN
          UPDATE ozf_claim_lines_all
           SET   source_object_class = l_source_object_class,
                 source_object_id    = l_source_object_id,
                 object_version_number = object_version_number + 1
           WHERE claim_line_id = l_claim_line_id;
       END IF;
   END LOOP;
   CLOSE csr_utiz_order;

   -- [END OF BUG 4067282 FIXING]


   OPEN csr_claim(l_claim_id);
   FETCH csr_claim INTO x_claim_id
                      , x_claim_number
                      , x_claim_amount;
   CLOSE csr_claim;

   -- [BEGIN OF BUG 4067282 FIXING]
   IF l_session_org_id IS NOT NULL THEN
      MO_GLOBAL.set_policy_context('S', l_session_org_id);  -- R12 Enhancements
   ELSE
      MO_GLOBAL.set_policy_context('M', NULL); -- BUG 4650224
   END IF;
   -- [END OF BUG 4067282 FIXING]


   -- Standard check for p_commit
   IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
      FND_MSG_PUB.Add;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(
         p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
   );

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Partner_Claim;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Partner_Claim;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CRE_DEDU_ERR');
         FND_MSG_PUB.add;
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Create_Partner_Claim;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CRE_DEDU_ERR');
         FND_MSG_PUB.add;
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );

End Create_Claim;


---------------------------------------------------------------------
--   PROCEDURE: Update_Claim
--
--   PURPOSE:
--
--   PARAMETERS:
--   IN:
--       p_api_version_number      IN   NUMBER              Required
--       p_init_msg_list           IN   VARCHAR2            Optional  Default = FND_API_G_FALSE
--       p_validation_level        IN   NUMBER              Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_commit                  IN   VARCHAR2            Optional  Default = FND_API.G_FALSE
--       P_claim_id                IN   NUMBER              Required
--       P_status_code             IN   VARCHAR2            Required
--       P_note_type               IN   VARCHAR2            Optional  Default = NULL
--       p_note_detail             IN   VARCHAR2            Optional  Default = NULL
--
--   OUT:
--       x_return_status           OUT NOCOPY VARCHAR2
--       x_msg_count               OUT NOCOPY NUMBER
--       x_msg_data                OUT NOCOPY VARCHAR2
--
--   Note:
--
---------------------------------------------------------------------
PROCEDURE Update_Claim(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_commit                     IN   VARCHAR2,

    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,

    p_claim_id                   IN   NUMBER,
    p_status_code                IN   VARCHAR2,
    p_comments                   IN   VARCHAR2,
    p_note_type                  IN   VARCHAR2,
    p_note_detail                IN   VARCHAR2
)
IS
l_api_version                CONSTANT NUMBER       := 1.0;
l_api_name                   CONSTANT VARCHAR2(30) := 'Update_Claim';
l_full_name                  CONSTANT VARCHAR2(60) := G_PKG_NAME||'.'||l_api_name;
l_return_status                       VARCHAR2(1);
--
l_dummy_number                        NUMBER;
l_status_code                         VARCHAR2(30);
l_claim_pvt_rec                       OZF_Claim_PVT.claim_rec_type;
l_x_note_id                           NUMBER;

CURSOR csr_claim_status(cv_status_code IN VARCHAR2) IS
  SELECT lookup_code
  FROM ozf_lookups
  WHERE lookup_type = 'OZF_CLAIM_STATUS';

CURSOR csr_claim_obj_num(cv_claim_id IN NUMBER) IS
  SELECT object_version_number
  ,      org_id
  FROM ozf_claims_all
  WHERE claim_id = cv_claim_id;


-- [BEGIN OF BUG 4067282 FIXING]
l_session_org_id                      NUMBER;
l_claim_org_id                        NUMBER;
-- [END OF BUG 4067282 FIXING]


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Update_Partner_Claim;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -----------------------------------------
   -- 1. Minimum required fields checking --
   -----------------------------------------
   IF p_claim_id IS NULL OR
      p_status_code IS NULL THEN
      IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name('OZF','OZF_REQUIRED_FIELDS_MISSING');
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   ELSE
      OPEN csr_claim_status(p_status_code);
      FETCH csr_claim_status INTO l_status_code;
      CLOSE csr_claim_status;
      IF l_status_code IS NULL THEN
         IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_INVALID_STATUS');
            FND_MSG_PUB.Add;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   -----------------------------------------
   -- 2. Update Claim
   -----------------------------------------
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('1. Update Claim');
   END IF;

   l_claim_pvt_rec.claim_id := p_claim_id;

   OPEN csr_claim_obj_num(p_claim_id);
   FETCH csr_claim_obj_num INTO l_claim_pvt_rec.object_version_number
                              , l_claim_org_id;
   CLOSE csr_claim_obj_num;

   -- [BEGIN OF BUG 4067282 FIXING]
   l_session_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();  -- R12 Enahancements.

   IF l_claim_org_id IS NOT NULL THEN
      MO_GLOBAL.set_policy_context('S', l_claim_org_id);  -- R12 Enhancements, BUG 4650224
   END IF;
   -- [END OF BUG 4067282 FIXING]

   IF p_status_code = 'APPROVED' THEN
      BEGIN
          UPDATE ozf_claims_all
          SET status_code = 'APPROVED'
          ,   user_status_id = OZF_UTILITY_PVT.get_default_user_status('OZF_CLAIM_STATUS', 'APPROVED')
          WHERE claim_id = p_claim_id;
      EXCEPTION
          WHEN OTHERS THEN
            IF OZF_DEBUG_LOW_ON THEN
               FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
               FND_MESSAGE.Set_Token('TEXT',sqlerrm);
               FND_MSG_PUB.Add;
            END IF;
            RAISE FND_API.g_exc_unexpected_error;
      END;
      l_claim_pvt_rec.status_code := 'CLOSED';
   ELSE
      l_claim_pvt_rec.status_code := p_status_code;
   END IF;

   l_claim_pvt_rec.comments := SUBSTR(p_comments, 1, 2000);

   OZF_claim_PVT.Update_Claim (
          p_api_version            => l_api_version
         ,p_init_msg_list          => FND_API.G_FALSE
         ,p_commit                 => FND_API.G_FALSE
         ,p_validation_level       => FND_API.G_VALID_LEVEL_FULL
         ,x_return_status          => l_return_status
         ,x_msg_data               => x_msg_data
         ,x_msg_count              => x_msg_count
         ,p_claim                  => l_claim_pvt_rec
         ,p_event                  => 'UPDATE'
         ,p_mode                   => OZF_Claim_Utility_PVT.G_AUTO_MODE
         ,x_object_version_number  => l_dummy_number
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -----------------------------------------
   -- 3. Create Note
   -----------------------------------------
   IF p_note_detail IS NOT NULL THEN
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_Utility_PVT.debug_message('2. Create Note');
      END IF;

      JTF_NOTES_PUB.Create_Note(
           p_api_version              => l_api_version
          ,x_return_status            => l_return_status
          ,x_msg_count                => x_msg_count
          ,x_msg_data                 => x_msg_data
          ,p_source_object_id         => p_claim_id
          ,p_source_object_code       => 'AMS_CLAM'
          ,p_notes                    => p_note_detail
          ,p_note_status              => NULL
          ,p_entered_by               => FND_GLOBAL.user_id
          ,p_entered_date             => SYSDATE
          ,p_last_updated_by          => FND_GLOBAL.user_id
          ,x_jtf_note_id              => l_x_note_id
          ,p_note_type                => p_note_type
          ,p_last_update_date         => SYSDATE
          ,p_creation_date            => SYSDATE
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- [BEGIN OF BUG 4067282 FIXING]
   IF l_session_org_id IS NOT NULL THEN
      MO_GLOBAL.set_policy_context('S', l_session_org_id);  -- R12 Enhancements
   ELSE
      MO_GLOBAL.set_policy_context('M', NULL);  -- BUG 4650224
   END IF;
   -- [END OF BUG 4067282 FIXING]

   -- Standard check for p_commit
   IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(
      p_count    => x_msg_count,
      p_data     => x_msg_data
   );

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Partner_Claim;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Partner_Claim;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Update_Partner_Claim;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CLAIM_UPD_DEDU_ERR');
         FND_MSG_PUB.add;
      END IF;
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

End Update_Claim;


END OZF_PARTNER_CLAIM_GRP;

/
