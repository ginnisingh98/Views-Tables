--------------------------------------------------------
--  DDL for Package Body OZF_DISC_LINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_DISC_LINE_PVT" as
/* $Header: ozfvodlb.pls 120.4 2006/05/04 15:25:35 julou noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Disc_Line_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- Wed Jan 14 2004:1/45 PM RSSHARMA Changed AMS_API_MISSING_FIELD messages to OZF_API_MISSING_FIELD
-- Thu Jan 29 2004:3/18 PM RSSHARMA Fixed bug # 3402308.
-- checkUOM did not initialize return so return status was initialized to null. This was fine in
-- dev and UT instances but in QA instance it errors out and rightly so.
-- So every function that is called which accepts x_return_status will initialize it as per standerds
-- ALso removed the validation on volume_break_type and Volume_operator as these are manully set every time
-- End of Comments
-- RSSHARMA Fixed Issue where unable to create Discount Tiers in MASS1R10 instance. The issue here was that
-- the SQL%NOTFOUND did not work properly. Worked around the issue by checking the value of tier level instead of SQL%NOTFOUND
-- Thu Feb 12 2004:5/23 PM RSSHARMA Fixed bug # 3429734. Dont allow adding duplicate Product to an Offer
-- Tue Feb 17 2004:1/58 PM RSSHARMA Fixed bug # 3429749. Error creating Exclusions as the Product relation was duplicate if the Tier Level is Offer.
-- Put the product relation check only if the Tier Leve = Product
-- Tue Feb 17 2004:5/45 PM RSSHARMA Added Delete Exclusions to delete exclusions for a discount line
-- ALso added validation to not delete lines if the Offer is not in draft status
-- Thu Feb 26 2004:12/3 PM RSSHARMA Fixed bug # 3468608.Default Excluder_flag to N if not passed in
-- Wed Oct 26 2005:5/47 PM RSSHARMA Fixed bug # 4673434. Disable duplicate validation exclusions
-- Thu Apr 06 2006:4/41 PM RSSHARMA Fixed bug # 5142859. Added Null Currency validation. DOnt allow amount discount if currency is null
-- ===============================================================
G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Disc_Line_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvodlb.pls';
-- G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
-- G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
--
--======================Discount Line Methods ========================================
-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Ozf_Disc_Line
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ozf_offer_line_rec            IN   ozf_offer_line_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================
FUNCTION is_delete_valid(p_offer_id IN NUMBER)
RETURN VARCHAR2
IS
    CURSOR c_offer_status(p_offer_id NUMBER) IS
    SELECT status_code FROM ozf_offers where offer_id = p_offer_id;
    l_offer_status VARCHAR2(30);
    l_return VARCHAR2(1) := 'N';
BEGIN
    OPEN c_offer_status(p_offer_id);
        fetch c_offer_status INTO l_offer_status;
    CLOSE c_offer_status;

    IF l_offer_status = 'DRAFT' THEN
        l_return := 'Y';
    END IF;

    return l_return;

END;

PROCEDURE Lock_Ozf_Disc_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offer_discount_line_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Ozf_Disc_Line';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_offer_discount_line_id                  NUMBER;

BEGIN

      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


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
OZF_DISC_LINE_PKG.Lock_Row(l_offer_discount_line_id,p_object_version);


 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  OZF_Utility_PVT.debug_message(l_full_name ||': end');
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Ozf_Disc_Line_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Ozf_Disc_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Ozf_Disc_Line_PVT;
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
End Lock_Ozf_Disc_Line;




PROCEDURE check_Ozf_Offer_Line_Uk_Items(
    p_ozf_offer_line_rec               IN   ozf_offer_line_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_ozf_offer_line_rec.offer_discount_line_id IS NOT NULL
      THEN
         l_valid_flag := OZF_Utility_PVT.check_uniqueness(
         'ozf_offer_discount_lines',
         'offer_discount_line_id = ''' || p_ozf_offer_line_rec.offer_discount_line_id ||''''
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_DISC_LINE_ID_DUP');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

END check_Ozf_Offer_Line_Uk_Items;

/**
Helper procedure to check Volume Items
Checks the following conditions
1)If Volume From is entered Volume Type is required
2)If Volume Type is entered Volume From is required
3)If Volume From and Volume Type are entered and if Volume Type = QUANTITY then UOM is required
4)If Tier Level is header then Volume To is required
*/
PROCEDURE check_volume_req_items(
    p_ozf_offer_line_rec               IN  ozf_offer_line_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
CURSOR c_tier_level(p_offer_id NUMBER) IS
select tier_level FROM ozf_offers where offer_id = p_offer_id;

l_tier_level ozf_offers.tier_level%type;

BEGIN
open c_tier_level(p_ozf_offer_line_rec.offer_id);
    fetch c_tier_level into l_tier_level;
close c_tier_level;
 IF p_validation_mode = JTF_PLSQL_API.g_create THEN
    IF p_ozf_offer_line_rec.volume_from IS NOT NULL OR p_ozf_offer_line_rec.volume_from <> FND_API.G_MISS_NUM THEN
        IF p_ozf_offer_line_rec.volume_type IS NULL OR p_ozf_offer_line_rec.volume_type = FND_API.G_MISS_CHAR THEN
                   OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'VOLUME_TYPE' );
                   x_return_status := FND_API.g_ret_sts_error;
                   return;
        ELSE
            IF p_ozf_offer_line_rec.volume_type = 'PRICING_ATTRIBUTE10' THEN
                    IF p_ozf_offer_line_rec.uom_code IS NULL OR  p_ozf_offer_line_rec.uom_code = FND_API.G_MISS_CHAR THEN
                       OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_ACT_PRD_NO_UOM');
                       x_return_status := FND_API.g_ret_sts_error;
                       return;
                    ELSE
                        null;
    --                p_ozf_offer_line_rec.uom_code := null;
                    END IF;
            END IF;
        END IF;
    ELSE IF p_ozf_offer_line_rec.volume_from IS NULL OR p_ozf_offer_line_rec.volume_from = FND_API.G_MISS_NUM  THEN
        IF p_ozf_offer_line_rec.volume_type IS NOT NULL OR p_ozf_offer_line_rec.volume_type <> FND_API.G_MISS_CHAR THEN
                   OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'VOLUME_FROM' );
                   x_return_status := FND_API.g_ret_sts_error;
                   return;
        ELSE
        null;
--            p_ozf_offer_line_rec.uom_code := null;
        END IF;
    END IF;
   END IF;
   IF l_tier_level = 'HEADER' THEN
        IF p_ozf_offer_line_rec.volume_to IS NULL OR p_ozf_offer_line_rec.volume_to = FND_API.G_MISS_NUM THEN
            OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'VOLUME_TO' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
        END IF;
   END IF;
 ELSE
    IF  p_ozf_offer_line_rec.volume_from <> FND_API.G_MISS_NUM THEN
        IF  p_ozf_offer_line_rec.volume_type = FND_API.G_MISS_CHAR THEN
                   OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'VOLUME_TYPE' );
                   x_return_status := FND_API.g_ret_sts_error;
            return;
        ELSE
            IF p_ozf_offer_line_rec.volume_type = 'PRICING_ATTRIBUTE10' THEN
                    IF  p_ozf_offer_line_rec.uom_code = FND_API.G_MISS_CHAR THEN
                       OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_ACT_PRD_NO_UOM');
                       x_return_status := FND_API.g_ret_sts_error;
                       return;
                    ELSE
                        null;
    --                p_ozf_offer_line_rec.uom_code := null;
                    END IF;
            END IF;
        END IF;
    ELSE IF  p_ozf_offer_line_rec.volume_from = FND_API.G_MISS_NUM  THEN
        IF  p_ozf_offer_line_rec.volume_type <> FND_API.G_MISS_CHAR THEN
                   OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'VOLUME_FROM' );
                   x_return_status := FND_API.g_ret_sts_error;
                   return;
        ELSE
        null;
--            p_ozf_offer_line_rec.uom_code := null;
        END IF;
    END IF;
   END IF;
   IF l_tier_level = 'HEADER' THEN
        IF p_ozf_offer_line_rec.volume_to = FND_API.G_MISS_NUM THEN
            OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'VOLUME_TO' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
        END IF;
   END IF;
 END IF;
END check_volume_req_items;

PROCEDURE check_Ozf_Offer_Line_Req_Items(
    p_ozf_offer_line_rec               IN  ozf_offer_line_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_ozf_offer_line_rec.offer_discount_line_id = FND_API.G_MISS_NUM OR p_ozf_offer_line_rec.offer_discount_line_id IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFFER_DISCOUNT_LINE_ID' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;

      IF p_ozf_offer_line_rec.offer_id = FND_API.G_MISS_NUM OR p_ozf_offer_line_rec.offer_id IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFFER_ID' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;

      IF p_ozf_offer_line_rec.discount = FND_API.G_MISS_NUM OR p_ozf_offer_line_rec.discount IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'DISCOUNT' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;


      IF p_ozf_offer_line_rec.discount_type = FND_API.g_miss_char OR p_ozf_offer_line_rec.discount_type IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'DISCOUNT_TYPE' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;


      IF p_ozf_offer_line_rec.tier_type = FND_API.g_miss_char OR p_ozf_offer_line_rec.tier_type IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'TIER_TYPE' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;


      IF p_ozf_offer_line_rec.tier_level = FND_API.g_miss_char OR p_ozf_offer_line_rec.tier_level IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'TIER_LEVEL' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;


   ELSE


      IF p_ozf_offer_line_rec.offer_discount_line_id = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFFER_DISCOUNT_LINE_ID' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;


      IF p_ozf_offer_line_rec.discount = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'DISCOUNT' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;


      IF p_ozf_offer_line_rec.discount_type = FND_API.g_miss_char THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'DISCOUNT_TYPE' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;


      IF p_ozf_offer_line_rec.tier_type = FND_API.g_miss_char THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'TIER_TYPE' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;


      IF p_ozf_offer_line_rec.tier_level = FND_API.g_miss_char THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'TIER_LEVEL' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;
   END IF;

check_volume_req_items(
    p_ozf_offer_line_rec               => p_ozf_offer_line_rec
    ,p_validation_mode => p_validation_mode
    ,x_return_status         => x_return_status
);
END check_Ozf_Offer_Line_Req_Items;



PROCEDURE check_Ozf_Offer_Line_Fk_Items(
    p_ozf_offer_line_rec IN ozf_offer_line_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- Enter custom code here

    IF p_ozf_offer_line_rec.offer_id IS NOT NULL AND p_ozf_offer_line_rec.offer_id  <> FND_API.G_MISS_NUM
    THEN
        IF ozf_utility_pvt.check_fk_exists('OZF_OFFERS','OFFER_ID',to_char(p_ozf_offer_line_rec.offer_id)) = FND_API.g_false THEN
            OZF_Utility_PVT.Error_Message('OZF_OFFER_ID_DUP' ); -- correct message
            x_return_status := FND_API.g_ret_sts_error;
            return;
        END IF;
    END IF;
END check_Ozf_Offer_Line_Fk_Items;



PROCEDURE check_Offer_Line_Lookup_Items(
    p_ozf_offer_line_rec IN ozf_offer_line_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Offer_Line_Lookup_Items;

/**
Does validation between offer attributes and the Discount line attributes
*/
PROCEDURE checkNaInterEntity(
    p_ozf_offer_line_rec IN ozf_offer_line_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
 CURSOR c_currency(cp_offerId NUMBER)
 IS
 SELECT transaction_currency_code
 FROM ozf_offers
 WHERE offer_id = cp_offerId;
 l_currency ozf_offers.transaction_currency_code%TYPE;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
OPEN c_currency(cp_offerId => p_ozf_offer_line_rec.offer_id);
FETCH c_currency INTO l_currency;
IF c_currency%NOTFOUND THEN
l_currency := NULL;
END IF;
CLOSE C_currency;
IF l_currency IS NULL  THEN
    IF p_ozf_offer_line_rec.discount_type<> FND_API.G_MISS_CHAR AND p_ozf_offer_line_rec.discount_type IS NOT NULL
    THEN
            IF
            (p_ozf_offer_line_rec.discount_type <> '%' )
            THEN
                 OZF_Utility_PVT.error_message('OZF_OFFR_OPT_CURR_PCNT');
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  return;
            END IF;
    END IF;
END IF;
END checkNaInterEntity;

PROCEDURE Check_Ozf_Offer_Line_Items (
    P_ozf_offer_line_rec     IN    ozf_offer_line_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
   l_return_status   VARCHAR2(1);
BEGIN

    l_return_status := FND_API.g_ret_sts_success;
   -- Check Items Uniqueness API calls
   check_Ozf_offer_line_Uk_Items(
      p_ozf_offer_line_rec => p_ozf_offer_line_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   check_ozf_offer_line_req_items(
      p_ozf_offer_line_rec => p_ozf_offer_line_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Foreign Keys API calls

   check_ozf_offer_line_FK_items(
      p_ozf_offer_line_rec => p_ozf_offer_line_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Lookups

   check_Offer_Line_Lookup_Items(
      p_ozf_offer_line_rec => p_ozf_offer_line_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
    checkNaInterEntity
    (
      p_ozf_offer_line_rec => p_ozf_offer_line_rec,
      x_return_status => x_return_status
     );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   x_return_status := l_return_status;

END Check_ozf_offer_line_Items;





PROCEDURE Complete_Ozf_Offer_Line_Rec (
   p_ozf_offer_line_rec IN ozf_offer_line_rec_type,
   x_complete_rec OUT NOCOPY ozf_offer_line_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ozf_offer_discount_lines
      WHERE offer_discount_line_id = p_ozf_offer_line_rec.offer_discount_line_id;
   l_ozf_offer_line_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_ozf_offer_line_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_ozf_offer_line_rec;
   CLOSE c_complete;

   -- offer_discount_line_id
   IF p_ozf_offer_line_rec.offer_discount_line_id IS NULL THEN
      x_complete_rec.offer_discount_line_id := l_ozf_offer_line_rec.offer_discount_line_id;
   END IF;

   -- parent_discount_line_id
   IF p_ozf_offer_line_rec.parent_discount_line_id IS NULL THEN
      x_complete_rec.parent_discount_line_id := l_ozf_offer_line_rec.parent_discount_line_id;
   END IF;

   -- volume_from
   IF p_ozf_offer_line_rec.volume_from IS NULL THEN
      x_complete_rec.volume_from := l_ozf_offer_line_rec.volume_from;
   END IF;

   -- volume_to
   IF p_ozf_offer_line_rec.volume_to IS NULL THEN
      x_complete_rec.volume_to := l_ozf_offer_line_rec.volume_to;
   END IF;

   -- volume_operator
   IF p_ozf_offer_line_rec.volume_operator IS NULL THEN
      x_complete_rec.volume_operator := l_ozf_offer_line_rec.volume_operator;
   END IF;

   -- volume_type
   IF p_ozf_offer_line_rec.volume_type IS NULL THEN
      x_complete_rec.volume_type := l_ozf_offer_line_rec.volume_type;
   END IF;

   -- volume_break_type
   IF p_ozf_offer_line_rec.volume_break_type IS NULL THEN
      x_complete_rec.volume_break_type := l_ozf_offer_line_rec.volume_break_type;
   END IF;

   -- discount
   IF p_ozf_offer_line_rec.discount IS NULL THEN
      x_complete_rec.discount := l_ozf_offer_line_rec.discount;
   END IF;

   -- discount_type
   IF p_ozf_offer_line_rec.discount_type IS NULL THEN
      x_complete_rec.discount_type := l_ozf_offer_line_rec.discount_type;
   END IF;

   -- tier_type
   IF p_ozf_offer_line_rec.tier_type IS NULL THEN
      x_complete_rec.tier_type := l_ozf_offer_line_rec.tier_type;
   END IF;

   -- tier_level
   IF p_ozf_offer_line_rec.tier_level IS NULL THEN
      x_complete_rec.tier_level := l_ozf_offer_line_rec.tier_level;
   END IF;

   -- incompatibility_group
   IF p_ozf_offer_line_rec.incompatibility_group IS NULL THEN
      x_complete_rec.incompatibility_group := l_ozf_offer_line_rec.incompatibility_group;
   END IF;

   -- precedence
   IF p_ozf_offer_line_rec.precedence IS NULL THEN
      x_complete_rec.precedence := l_ozf_offer_line_rec.precedence;
   END IF;

   -- bucket
   IF p_ozf_offer_line_rec.bucket IS NULL THEN
      x_complete_rec.bucket := l_ozf_offer_line_rec.bucket;
   END IF;

   -- scan_value
   IF p_ozf_offer_line_rec.scan_value IS NULL THEN
      x_complete_rec.scan_value := l_ozf_offer_line_rec.scan_value;
   END IF;

   -- scan_data_quantity
   IF p_ozf_offer_line_rec.scan_data_quantity IS NULL THEN
      x_complete_rec.scan_data_quantity := l_ozf_offer_line_rec.scan_data_quantity;
   END IF;

   -- scan_unit_forecast
   IF p_ozf_offer_line_rec.scan_unit_forecast IS NULL THEN
      x_complete_rec.scan_unit_forecast := l_ozf_offer_line_rec.scan_unit_forecast;
   END IF;

   -- channel_id
   IF p_ozf_offer_line_rec.channel_id IS NULL THEN
      x_complete_rec.channel_id := l_ozf_offer_line_rec.channel_id;
   END IF;

   -- adjustment_flag
   IF p_ozf_offer_line_rec.adjustment_flag IS NULL THEN
      x_complete_rec.adjustment_flag := l_ozf_offer_line_rec.adjustment_flag;
   END IF;

   -- start_date_active
   IF p_ozf_offer_line_rec.start_date_active IS NULL THEN
      x_complete_rec.start_date_active := l_ozf_offer_line_rec.start_date_active;
   END IF;

   -- end_date_active
   IF p_ozf_offer_line_rec.end_date_active IS NULL THEN
      x_complete_rec.end_date_active := l_ozf_offer_line_rec.end_date_active;
   END IF;

   -- uom_code
   IF p_ozf_offer_line_rec.uom_code IS NULL THEN
      x_complete_rec.uom_code := l_ozf_offer_line_rec.uom_code;
   END IF;

   -- creation_date
   IF p_ozf_offer_line_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_ozf_offer_line_rec.creation_date;
   END IF;

   -- created_by
   IF p_ozf_offer_line_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_ozf_offer_line_rec.created_by;
   END IF;

   -- last_update_date
   IF p_ozf_offer_line_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_ozf_offer_line_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_ozf_offer_line_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_ozf_offer_line_rec.last_updated_by;
   END IF;

   -- last_update_login
   IF p_ozf_offer_line_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_ozf_offer_line_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_ozf_offer_line_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_ozf_offer_line_rec.object_version_number;
   END IF;

   -- offer_id
   IF p_ozf_offer_line_rec.offer_id IS NULL THEN
      x_complete_rec.offer_id := l_ozf_offer_line_rec.offer_id;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_Ozf_Offer_Line_Rec;




PROCEDURE Default_Ozf_Offer_Line_Items ( p_ozf_offer_line_rec IN ozf_offer_line_rec_type ,
                                x_ozf_offer_line_rec OUT NOCOPY ozf_offer_line_rec_type )
IS
   l_ozf_offer_line_rec ozf_offer_line_rec_type := p_ozf_offer_line_rec;
BEGIN
   -- Developers should put their code to default the record type
   -- e.g. IF p_campaign_rec.status_code IS NULL
   --      OR p_campaign_rec.status_code = FND_API.G_MISS_CHAR THEN
   --         l_campaign_rec.status_code := 'NEW' ;
   --      END IF ;
   --
   NULL ;
END;


PROCEDURE Validate_Ozf_Offer_Line_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_ozf_offer_line_rec               IN    ozf_offer_line_rec_type
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
      OZF_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_ozf_offer_line_Rec;


PROCEDURE Validate_Ozf_Disc_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_ozf_offer_line_rec               IN   ozf_offer_line_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Ozf_Disc_Line';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_ozf_offer_line_rec  ozf_offer_line_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_ozf_disc_line_;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              Check_ozf_offer_line_Items(
                 p_ozf_offer_line_rec        => p_ozf_offer_line_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         Default_Ozf_Offer_Line_Items (p_ozf_offer_line_rec => p_ozf_offer_line_rec ,
                                x_ozf_offer_line_rec => l_ozf_offer_line_rec) ;
      END IF ;


--      IF p_validation_mode = JTF_PLSQL_API.g_update THEN
      Complete_ozf_offer_line_Rec(
         p_ozf_offer_line_rec        => l_ozf_offer_line_rec,
         x_complete_rec        => l_ozf_offer_line_rec
      );
--      END IF;
      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_ozf_offer_line_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_ozf_offer_line_rec           =>    l_ozf_offer_line_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;



      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


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
     ROLLBACK TO VALIDATE_Ozf_Disc_Line_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Ozf_Disc_Line_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Ozf_Disc_Line_;
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
End Validate_Ozf_Disc_Line;









-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Ozf_Disc_Line
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ozf_offer_line_rec            IN   ozf_offer_line_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Create_Ozf_Disc_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ozf_offer_line_rec              IN   ozf_offer_line_rec_type  := g_miss_ozf_offer_line_rec,
    x_offer_discount_line_id              OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Ozf_Disc_Line';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_offer_discount_line_id              NUMBER;
   l_dummy                     NUMBER;
    l_ozf_offer_line_rec              ozf_offer_line_rec_type;
   CURSOR c_id IS
      SELECT ozf_offer_discount_lines_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM OZF_OFFER_DISCOUNT_LINES
      WHERE offer_discount_line_id = l_id;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_ozf_disc_line_pvt;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.USER_ID IS NULL
      THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;




   -- Local variable initialization
    l_ozf_offer_line_rec := p_ozf_offer_line_rec;
   IF p_ozf_offer_line_rec.offer_discount_line_id IS NULL OR p_ozf_offer_line_rec.offer_discount_line_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_offer_discount_line_id;
         CLOSE c_id;

         OPEN c_id_exists(l_offer_discount_line_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
         l_offer_discount_line_id := p_ozf_offer_line_rec.offer_discount_line_id;
   END IF;


l_ozf_offer_line_rec.offer_discount_line_id := l_offer_discount_line_id;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          OZF_UTILITY_PVT.debug_message('Private API: Validate_Ozf_Disc_Line');

          -- Invoke validation procedures
          Validate_ozf_disc_line(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            p_ozf_offer_line_rec  =>  l_ozf_offer_line_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      OZF_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      -- Invoke table handler(OZF_DISC_LINE_PKG.Insert_Row)
      OZF_DISC_LINE_PKG.Insert_Row(
          px_offer_discount_line_id  => l_offer_discount_line_id,
          p_parent_discount_line_id  => l_ozf_offer_line_rec.parent_discount_line_id,
          p_volume_from  => l_ozf_offer_line_rec.volume_from,
          p_volume_to  => l_ozf_offer_line_rec.volume_to,
          p_volume_operator  => l_ozf_offer_line_rec.volume_operator,
          p_volume_type  => l_ozf_offer_line_rec.volume_type,
          p_volume_break_type  => l_ozf_offer_line_rec.volume_break_type,
          p_discount  => l_ozf_offer_line_rec.discount,
          p_discount_type  => l_ozf_offer_line_rec.discount_type,
          p_tier_type  => l_ozf_offer_line_rec.tier_type,
          p_tier_level  => l_ozf_offer_line_rec.tier_level,
          p_incompatibility_group  => l_ozf_offer_line_rec.incompatibility_group,
          p_precedence  => l_ozf_offer_line_rec.precedence,
          p_bucket  => l_ozf_offer_line_rec.bucket,
          p_scan_value  => l_ozf_offer_line_rec.scan_value,
          p_scan_data_quantity  => l_ozf_offer_line_rec.scan_data_quantity,
          p_scan_unit_forecast  => l_ozf_offer_line_rec.scan_unit_forecast,
          p_channel_id  => l_ozf_offer_line_rec.channel_id,
          p_adjustment_flag  => l_ozf_offer_line_rec.adjustment_flag,
          p_start_date_active  => l_ozf_offer_line_rec.start_date_active,
          p_end_date_active  => l_ozf_offer_line_rec.end_date_active,
          p_uom_code  => l_ozf_offer_line_rec.uom_code,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          px_object_version_number  => l_object_version_number,
           p_context     => l_ozf_offer_line_rec.context,
           p_attribute1  => l_ozf_offer_line_rec.attribute1,
           p_attribute2  => l_ozf_offer_line_rec.attribute2,
           p_attribute3  => l_ozf_offer_line_rec.attribute3,
           p_attribute4  => l_ozf_offer_line_rec.attribute4,
           p_attribute5  => l_ozf_offer_line_rec.attribute5,
           p_attribute6  => l_ozf_offer_line_rec.attribute6,
           p_attribute7  => l_ozf_offer_line_rec.attribute7,
           p_attribute8  => l_ozf_offer_line_rec.attribute8,
           p_attribute9  => l_ozf_offer_line_rec.attribute9,
           p_attribute10 => l_ozf_offer_line_rec.attribute10,
           p_attribute11 => l_ozf_offer_line_rec.attribute11,
           p_attribute12 => l_ozf_offer_line_rec.attribute12,
           p_attribute13 => l_ozf_offer_line_rec.attribute13,
           p_attribute14 => l_ozf_offer_line_rec.attribute14,
           p_attribute15 => l_ozf_offer_line_rec.attribute15,
          p_offer_id  => l_ozf_offer_line_rec.offer_id
);

          x_offer_discount_line_id := l_offer_discount_line_id;
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
--
-- End of API body
--

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

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
     ROLLBACK TO CREATE_Ozf_Disc_Line_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Ozf_Disc_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Ozf_Disc_Line_PVT;
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
End Create_Ozf_Disc_Line;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Ozf_Disc_Line
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ozf_offer_line_rec            IN   ozf_offer_line_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Update_Ozf_Disc_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ozf_offer_line_rec               IN    ozf_offer_line_rec_type
    )

 IS


CURSOR c_get_ozf_disc_line(offer_discount_line_id NUMBER) IS
    SELECT *
    FROM  OZF_OFFER_DISCOUNT_LINES
    WHERE  offer_discount_line_id = p_ozf_offer_line_rec.offer_discount_line_id;
    -- Hint: Developer need to provide Where clause


L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Ozf_Disc_Line';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_offer_discount_line_id    NUMBER;
l_ref_ozf_offer_line_rec  c_get_Ozf_Disc_Line%ROWTYPE ;
l_tar_ozf_offer_line_rec  ozf_offer_line_rec_type := P_ozf_offer_line_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_ozf_disc_line_pvt;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');

      OPEN c_get_Ozf_Disc_Line( l_tar_ozf_offer_line_rec.offer_discount_line_id);
      FETCH c_get_Ozf_Disc_Line INTO l_ref_ozf_offer_line_rec  ;
       If ( c_get_Ozf_Disc_Line%NOTFOUND) THEN
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Ozf_Disc_Line') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       CLOSE     c_get_Ozf_Disc_Line;


      If (l_tar_ozf_offer_line_rec.object_version_number is NULL or
          l_tar_ozf_offer_line_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_ozf_offer_line_rec.object_version_number <> l_ref_ozf_offer_line_rec.object_version_number) Then
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Ozf_Disc_Line') ;
          raise FND_API.G_EXC_ERROR;
      End if;


      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          OZF_UTILITY_PVT.debug_message('Private API: Validate_Ozf_Disc_Line');

          -- Invoke validation procedures
          Validate_ozf_disc_line(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_ozf_offer_line_rec  =>  p_ozf_offer_line_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message

      -- Invoke table handler(OZF_DISC_LINE_PKG.Update_Row)
      OZF_DISC_LINE_PKG.Update_Row(
          p_offer_discount_line_id  => p_ozf_offer_line_rec.offer_discount_line_id,
          p_parent_discount_line_id  => p_ozf_offer_line_rec.parent_discount_line_id,
          p_volume_from  => p_ozf_offer_line_rec.volume_from,
          p_volume_to  => p_ozf_offer_line_rec.volume_to,
          p_volume_operator  => p_ozf_offer_line_rec.volume_operator,
          p_volume_type  => p_ozf_offer_line_rec.volume_type,
          p_volume_break_type  => p_ozf_offer_line_rec.volume_break_type,
          p_discount  => p_ozf_offer_line_rec.discount,
          p_discount_type  => p_ozf_offer_line_rec.discount_type,
          p_tier_type  => p_ozf_offer_line_rec.tier_type,
          p_tier_level  => p_ozf_offer_line_rec.tier_level,
          p_incompatibility_group  => p_ozf_offer_line_rec.incompatibility_group,
          p_precedence  => p_ozf_offer_line_rec.precedence,
          p_bucket  => p_ozf_offer_line_rec.bucket,
          p_scan_value  => p_ozf_offer_line_rec.scan_value,
          p_scan_data_quantity  => p_ozf_offer_line_rec.scan_data_quantity,
          p_scan_unit_forecast  => p_ozf_offer_line_rec.scan_unit_forecast,
          p_channel_id  => p_ozf_offer_line_rec.channel_id,
          p_adjustment_flag  => p_ozf_offer_line_rec.adjustment_flag,
          p_start_date_active  => p_ozf_offer_line_rec.start_date_active,
          p_end_date_active  => p_ozf_offer_line_rec.end_date_active,
          p_uom_code  => p_ozf_offer_line_rec.uom_code,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_object_version_number  => p_ozf_offer_line_rec.object_version_number,
           p_context     => p_ozf_offer_line_rec.context,
           p_attribute1  => p_ozf_offer_line_rec.attribute1,
           p_attribute2  => p_ozf_offer_line_rec.attribute2,
           p_attribute3  => p_ozf_offer_line_rec.attribute3,
           p_attribute4  => p_ozf_offer_line_rec.attribute4,
           p_attribute5  => p_ozf_offer_line_rec.attribute5,
           p_attribute6  => p_ozf_offer_line_rec.attribute6,
           p_attribute7  => p_ozf_offer_line_rec.attribute7,
           p_attribute8  => p_ozf_offer_line_rec.attribute8,
           p_attribute9  => p_ozf_offer_line_rec.attribute9,
           p_attribute10 => p_ozf_offer_line_rec.attribute10,
           p_attribute11 => p_ozf_offer_line_rec.attribute11,
           p_attribute12 => p_ozf_offer_line_rec.attribute12,
           p_attribute13 => p_ozf_offer_line_rec.attribute13,
           p_attribute14 => p_ozf_offer_line_rec.attribute14,
           p_attribute15 => p_ozf_offer_line_rec.attribute15,
          p_offer_id  => p_ozf_offer_line_rec.offer_id
);

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


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
     ROLLBACK TO UPDATE_Ozf_Disc_Line_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Ozf_Disc_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Ozf_Disc_Line_PVT;
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
End Update_Ozf_Disc_Line;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Ozf_Disc_Line
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_offer_discount_line_id                IN   NUMBER
--       p_object_version_number   IN   NUMBER     Optional  Default = NULL
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Delete_Ozf_Disc_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_offer_discount_line_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Ozf_Disc_Line';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_ozf_disc_line_pvt;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      OZF_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');

      -- Invoke table handler(OZF_DISC_LINE_PKG.Delete_Row)
      OZF_DISC_LINE_PKG.Delete_Row(
          p_offer_discount_line_id  => p_offer_discount_line_id,
          p_object_version_number => p_object_version_number     );
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


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
     ROLLBACK TO DELETE_Ozf_Disc_Line_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Ozf_Disc_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Ozf_Disc_Line_PVT;
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
End Delete_Ozf_Disc_Line;


--==================================End Discount Line Methods ===============================


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Ozf_Prod_Line
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ozf_prod_rec            IN   ozf_prod_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Lock_Ozf_Prod_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_off_discount_product_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Ozf_Prod_Line';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_off_discount_product_id                  NUMBER;

BEGIN

      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


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
Ozf_Create_Ozf_Prod_Line_Pkg.Lock_Row(l_off_discount_product_id,p_object_version);


 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  OZF_Utility_PVT.debug_message(l_full_name ||': end');
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Lock_Ozf_Prod_Line_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Lock_Ozf_Prod_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Lock_Ozf_Prod_Line_PVT;
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
End Lock_Ozf_Prod_Line;


FUNCTION check_item_exists(    p_product_level               IN   VARCHAR2
                               ,p_product_id                 IN NUMBER
                               ,p_offer_id                   IN NUMBER
                               ,p_excluder_flag              IN VARCHAR2)
    RETURN VARCHAR2
    IS
    CURSOR c_item_exists(p_item_level VARCHAR2,p_item_number NUMBER,p_excluder_flag VARCHAR2 , p_offer_id NUMBER) IS
    SELECT 1 from ozf_offer_discount_products
                                WHERE   product_level = p_item_level
                                AND product_id = p_item_number
                                AND excluder_flag = p_excluder_flag
                                AND offer_id = p_offer_id ;
    l_item_exists NUMBER := 0;
    l_return VARCHAR2(1) := 'N';
    BEGIN
    OPEN c_item_exists(p_product_level,p_product_id,p_excluder_flag ,p_offer_id);
    FETCH c_item_exists INTO l_item_exists;
    CLOSE c_item_exists;
    IF l_item_exists <> 0 THEN
    l_return := 'Y';
    END IF;
    return l_return;
    END check_item_exists;

PROCEDURE check_Ozf_Prod_Uk_Items(
    p_ozf_prod_rec               IN   ozf_prod_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);
BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_ozf_prod_rec.off_discount_product_id IS NOT NULL
      THEN
         l_valid_flag := OZF_Utility_PVT.check_uniqueness(
         'ozf_offer_discount_products',
         'off_discount_product_id = ''' || p_ozf_prod_rec.off_discount_product_id ||''''
         );
      END IF;
      IF l_valid_flag = FND_API.g_false THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFF_DISC_PROD_ID_DUP');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

END check_Ozf_Prod_Uk_Items;



PROCEDURE check_Ozf_Prod_Req_Items(
    p_ozf_prod_rec               IN  ozf_prod_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_ozf_prod_rec.offer_id = FND_API.G_MISS_NUM OR p_ozf_prod_rec.offer_id IS NULL THEN
      OZF_Utility_PVT.Error_Message('OZF_API_MISSING' , 'MISS_FIELD','OFFER_ID');
              x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_ozf_prod_rec.offer_discount_line_id = FND_API.G_MISS_NUM OR p_ozf_prod_rec.offer_discount_line_id IS NULL THEN
      OZF_Utility_PVT.Error_Message('OZF_API_MISSING' , 'MISS_FIELD','OFFER_DISCOUNT_LINE_ID');
              x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_ozf_prod_rec.off_discount_product_id = FND_API.G_MISS_NUM OR p_ozf_prod_rec.off_discount_product_id IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFF_DISCOUNT_PRODUCT_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_ozf_prod_rec.product_level = FND_API.g_miss_char OR p_ozf_prod_rec.product_level IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'PRODUCT_LEVEL' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_ozf_prod_rec.product_id = FND_API.G_MISS_NUM OR p_ozf_prod_rec.product_id IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'PRODUCT_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_ozf_prod_rec.excluder_flag = FND_API.g_miss_char OR p_ozf_prod_rec.excluder_flag IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'EXCLUDER_FLAG' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


/*      IF p_ozf_prod_rec.uom_code = FND_API.g_miss_char OR p_ozf_prod_rec.uom_code IS NULL THEN
               OZF_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'UOM_CODE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
*/

   ELSE

      IF p_ozf_prod_rec.offer_id = FND_API.G_MISS_NUM THEN
              OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','OFFER_ID');
              x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_ozf_prod_rec.offer_discount_line_id = FND_API.G_MISS_NUM THEN
              OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','OFFER_DISCOUNT_LINE_ID');
              x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_ozf_prod_rec.off_discount_product_id = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFF_DISCOUNT_PRODUCT_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_ozf_prod_rec.product_level = FND_API.g_miss_char THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'PRODUCT_LEVEL' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_ozf_prod_rec.product_id = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'PRODUCT_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_ozf_prod_rec.excluder_flag = FND_API.g_miss_char THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'EXCLUDER_FLAG' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


/*      IF p_ozf_prod_rec.uom_code = FND_API.g_miss_char THEN
               OZF_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'UOM_CODE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;  */
   END IF;

END check_Ozf_Prod_Req_Items;



PROCEDURE check_Ozf_Prod_Fk_Items(
    p_ozf_prod_rec IN ozf_prod_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here
IF p_ozf_prod_rec.offer_id is not null AND p_ozf_prod_rec.offer_id <> FND_API.G_MISS_NUM THEN
IF ozf_utility_pvt.check_fk_exists('OZF_OFFERS','OFFER_ID',to_char(p_ozf_prod_rec.offer_id)) = FND_API.g_false THEN
    OZF_Utility_PVT.Error_Message('OZF_PROD_OFFER_ID_FK_DUP' ); -- correct message
    x_return_status := FND_API.g_ret_sts_error;
END IF;
END IF;

IF p_ozf_prod_rec.offer_discount_line_id <> -1 THEN
IF p_ozf_prod_rec.offer_discount_line_id is not null AND p_ozf_prod_rec.offer_discount_line_id <> fnd_api.g_miss_num THEN
IF ozf_utility_pvt.check_fk_exists('OZF_OFFER_DISCOUNT_LINES','OFFER_DISCOUNT_LINE_ID',to_char(p_ozf_prod_rec.offer_discount_line_id)) = FND_API.g_false THEN
    OZF_Utility_PVT.Error_Message('OZF_DISC_LINE_FK_DUP' ); -- correct message
    x_return_status := FND_API.g_ret_sts_error;
END IF;
END IF;
END IF;

END check_Ozf_Prod_Fk_Items;



PROCEDURE check_Ozf_Prod_Lookup_Items(
    p_ozf_prod_rec IN ozf_prod_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Ozf_Prod_Lookup_Items;


PROCEDURE check_Ozf_Prod_attr_Items(
    p_ozf_prod_rec IN ozf_prod_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
l_item_exists VARCHAR2(1) := NULL;
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here
    IF p_ozf_prod_rec.excluder_flag = 'N' THEN
       l_item_exists := check_item_exists(p_ozf_prod_rec.product_level,p_ozf_prod_rec.product_id,p_ozf_prod_rec.offer_id,p_ozf_prod_rec.excluder_flag);
       IF l_item_exists = 'Y' THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFR_DUPL_ITEM');
         x_return_status := FND_API.g_ret_sts_error;
         return;
       END IF;
    END IF;

END check_Ozf_Prod_attr_Items;


PROCEDURE Check_Ozf_Prod_Items (
    P_ozf_prod_rec     IN    ozf_prod_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
   l_return_status   VARCHAR2(1);
BEGIN

    l_return_status := FND_API.g_ret_sts_success;
   -- Check Items Uniqueness API calls
   check_Ozf_prod_Uk_Items(
      p_ozf_prod_rec => p_ozf_prod_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Required/NOT NULL API calls
   check_ozf_prod_req_items(
      p_ozf_prod_rec => p_ozf_prod_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Foreign Keys API calls
   check_ozf_prod_FK_items(
      p_ozf_prod_rec => p_ozf_prod_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Lookups
   check_ozf_prod_Lookup_items(
      p_ozf_prod_rec => p_ozf_prod_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   check_Ozf_Prod_attr_Items
   (
      p_ozf_prod_rec => p_ozf_prod_rec,
      x_return_status => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   x_return_status := l_return_status;

END Check_ozf_prod_Items;





PROCEDURE Complete_Ozf_Prod_Rec (
   p_ozf_prod_rec IN ozf_prod_rec_type,
   x_complete_rec OUT NOCOPY ozf_prod_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ozf_offer_discount_products
      WHERE off_discount_product_id = p_ozf_prod_rec.off_discount_product_id;
   l_ozf_prod_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_ozf_prod_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_ozf_prod_rec;
   CLOSE c_complete;

   -- off_discount_product_id
   IF p_ozf_prod_rec.off_discount_product_id IS NULL THEN
      x_complete_rec.off_discount_product_id := l_ozf_prod_rec.off_discount_product_id;
   END IF;

   -- product_level
   IF p_ozf_prod_rec.product_level IS NULL THEN
      x_complete_rec.product_level := l_ozf_prod_rec.product_level;
   END IF;

   -- product_id
   IF p_ozf_prod_rec.product_id IS NULL THEN
      x_complete_rec.product_id := l_ozf_prod_rec.product_id;
   END IF;

   -- excluder_flag
   IF p_ozf_prod_rec.excluder_flag IS NULL THEN
      x_complete_rec.excluder_flag := l_ozf_prod_rec.excluder_flag;
   END IF;

   -- uom_code
   IF p_ozf_prod_rec.uom_code IS NULL THEN
      x_complete_rec.uom_code := l_ozf_prod_rec.uom_code;
   END IF;

   -- start_date_active
   IF p_ozf_prod_rec.start_date_active IS NULL THEN
      x_complete_rec.start_date_active := l_ozf_prod_rec.start_date_active;
   END IF;

   -- end_date_active
   IF p_ozf_prod_rec.end_date_active IS NULL THEN
      x_complete_rec.end_date_active := l_ozf_prod_rec.end_date_active;
   END IF;

   -- offer_discount_line_id
   IF p_ozf_prod_rec.offer_discount_line_id IS NULL THEN
      x_complete_rec.offer_discount_line_id := l_ozf_prod_rec.offer_discount_line_id;
   END IF;

   -- offer_id
   IF p_ozf_prod_rec.offer_id IS NULL THEN
      x_complete_rec.offer_id := l_ozf_prod_rec.offer_id;
   END IF;

   -- creation_date
   IF p_ozf_prod_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_ozf_prod_rec.creation_date;
   END IF;

   -- created_by
   IF p_ozf_prod_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_ozf_prod_rec.created_by;
   END IF;

   -- last_update_date
   IF p_ozf_prod_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_ozf_prod_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_ozf_prod_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_ozf_prod_rec.last_updated_by;
   END IF;

   -- last_update_login
   IF p_ozf_prod_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_ozf_prod_rec.last_update_login;
   END IF;

   -- object_version_number
/*   IF p_ozf_prod_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_ozf_prod_rec.object_version_number;
   END IF;
   */
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_Ozf_Prod_Rec;




PROCEDURE Default_Ozf_Prod_Items ( p_ozf_prod_rec IN ozf_prod_rec_type ,
                                x_ozf_prod_rec OUT NOCOPY ozf_prod_rec_type )
IS
   l_ozf_prod_rec ozf_prod_rec_type := p_ozf_prod_rec;
BEGIN
   -- Developers should put their code to default the record type
   -- e.g. IF p_campaign_rec.status_code IS NULL
   --      OR p_campaign_rec.status_code = FND_API.G_MISS_CHAR THEN
   --         l_campaign_rec.status_code := 'NEW' ;
   --      END IF ;
   --
   NULL ;
END;






PROCEDURE Validate_Ozf_Prod_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_ozf_prod_rec               IN    ozf_prod_rec_type
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
      OZF_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_ozf_prod_Rec;
PROCEDURE Validate_Create_Ozf_Prod_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_ozf_prod_rec               IN   ozf_prod_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Create_Ozf_Prod_Line';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_ozf_prod_rec  ozf_prod_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_create_ozf_prod_line_;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              Check_ozf_prod_Items(
                 p_ozf_prod_rec        => p_ozf_prod_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         Default_Ozf_Prod_Items (p_ozf_prod_rec => p_ozf_prod_rec ,
                                x_ozf_prod_rec => l_ozf_prod_rec) ;
      END IF ;

      Complete_ozf_prod_Rec(
         p_ozf_prod_rec        => l_ozf_prod_rec,
         x_complete_rec        => l_ozf_prod_rec
      );
      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_ozf_prod_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_ozf_prod_rec           =>    l_ozf_prod_rec);
              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;
      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


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
     ROLLBACK TO VALIDATE_Create_Ozf_Prod_Line_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Create_Ozf_Prod_Line_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Create_Ozf_Prod_Line_;
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
End Validate_Create_Ozf_Prod_Line;

--============================Product Line Methods ==========================================
-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Ozf_Prod_Line
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ozf_prod_rec            IN   ozf_prod_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Create_Ozf_Prod_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ozf_prod_rec              IN   ozf_prod_rec_type,
    x_off_discount_product_id              OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Ozf_Prod_Line';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_off_discount_product_id              NUMBER;
   l_dummy                     NUMBER;
    l_ozf_prod_rec              ozf_prod_rec_type  := g_miss_ozf_prod_rec;

   CURSOR c_id IS
      SELECT ozf_offer_discount_products_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM OZF_OFFER_DISCOUNT_PRODUCTS
      WHERE off_discount_product_id = l_id;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Create_Ozf_Prod_Line_pvt;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.USER_ID IS NULL
      THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;



   -- Local variable initialization
l_ozf_prod_rec := p_ozf_prod_rec;
   IF p_ozf_prod_rec.off_discount_product_id IS NULL OR p_ozf_prod_rec.off_discount_product_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_off_discount_product_id;
         CLOSE c_id;

         OPEN c_id_exists(l_off_discount_product_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
         l_off_discount_product_id := p_ozf_prod_rec.off_discount_product_id;
   END IF;
l_ozf_prod_rec.off_discount_product_id := l_off_discount_product_id;
IF p_ozf_prod_rec.excluder_flag IS NOT NULL THEN
l_ozf_prod_rec.excluder_flag := p_ozf_prod_rec.excluder_flag;
ELSE
l_ozf_prod_rec.excluder_flag := 'N';
END IF;


      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          OZF_UTILITY_PVT.debug_message('Private API: Validate_Create_Ozf_Prod_Line');

          -- Invoke validation procedures
          Validate_create_ozf_prod_line(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            p_ozf_prod_rec  =>  l_ozf_prod_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      OZF_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');

      -- Invoke table handler(Ozf_Create_Ozf_Prod_Line_Pkg.Insert_Row)
      Ozf_Create_Ozf_Prod_Line_Pkg.Insert_Row(
          px_off_discount_product_id  => l_off_discount_product_id,
          p_parent_off_disc_prod_id => l_ozf_prod_rec.parent_off_disc_prod_id,
          p_product_level  => l_ozf_prod_rec.product_level,
          p_product_id  => l_ozf_prod_rec.product_id,
          p_excluder_flag  => l_ozf_prod_rec.excluder_flag,
          p_uom_code  => l_ozf_prod_rec.uom_code,
          p_start_date_active  => l_ozf_prod_rec.start_date_active,
          p_end_date_active  => l_ozf_prod_rec.end_date_active,
          p_offer_discount_line_id  => l_ozf_prod_rec.offer_discount_line_id,
          p_offer_id  => l_ozf_prod_rec.offer_id,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          px_object_version_number  => l_object_version_number
);

          x_off_discount_product_id := l_off_discount_product_id;
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
--
-- End of API body
--

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


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
     ROLLBACK TO Create_Ozf_Prod_Line_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_Ozf_Prod_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Create_Ozf_Prod_Line_PVT;
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
End Create_Ozf_Prod_Line;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Create_Ozf_Prod_Line
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ozf_prod_rec            IN   ozf_prod_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Update_Ozf_Prod_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ozf_prod_rec               IN    ozf_prod_rec_type
    )

 IS


CURSOR c_get_create_ozf_prod_line(off_discount_product_id NUMBER) IS
    SELECT *
    FROM  OZF_OFFER_DISCOUNT_PRODUCTS
    WHERE  off_discount_product_id = p_ozf_prod_rec.off_discount_product_id;
    -- Hint: Developer need to provide Where clause


L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Ozf_Prod_Line';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_off_discount_product_id    NUMBER;
l_ref_ozf_prod_rec  c_get_Create_Ozf_Prod_Line%ROWTYPE ;
l_tar_ozf_prod_rec  ozf_prod_rec_type := P_ozf_prod_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Update_Ozf_Prod_Line_pvt;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');

      OPEN c_get_Create_Ozf_Prod_Line( l_tar_ozf_prod_rec.off_discount_product_id);

      FETCH c_get_Create_Ozf_Prod_Line INTO l_ref_ozf_prod_rec  ;

       If ( c_get_Create_Ozf_Prod_Line%NOTFOUND) THEN
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Create_Ozf_Prod_Line') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       OZF_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       CLOSE     c_get_Create_Ozf_Prod_Line;


/*      If (l_tar_ozf_prod_rec.object_version_number is NULL or
          l_tar_ozf_prod_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_ozf_prod_rec.object_version_number <> l_ref_ozf_prod_rec.object_version_number) Then
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Create_Ozf_Prod_Line') ;
          raise FND_API.G_EXC_ERROR;
      End if;
*/

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          OZF_UTILITY_PVT.debug_message('Private API: Validate_Create_Ozf_Prod_Line');

          -- Invoke validation procedures
          Validate_create_ozf_prod_line(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_ozf_prod_rec  =>  p_ozf_prod_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
--      OZF_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');

      -- Invoke table handler(Ozf_Create_Ozf_Prod_Line_Pkg.Update_Row)
      Ozf_Create_Ozf_Prod_Line_Pkg.Update_Row(
          p_off_discount_product_id  => p_ozf_prod_rec.off_discount_product_id,
          p_parent_off_disc_prod_id => p_ozf_prod_rec.parent_off_disc_prod_id,
          p_product_level  => p_ozf_prod_rec.product_level,
          p_product_id  => p_ozf_prod_rec.product_id,
          p_excluder_flag  => p_ozf_prod_rec.excluder_flag,
          p_uom_code  => p_ozf_prod_rec.uom_code,
          p_start_date_active  => p_ozf_prod_rec.start_date_active,
          p_end_date_active  => p_ozf_prod_rec.end_date_active,
          p_offer_discount_line_id  => p_ozf_prod_rec.offer_discount_line_id,
          p_offer_id  => p_ozf_prod_rec.offer_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_object_version_number  => p_ozf_prod_rec.object_version_number
);
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


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
     ROLLBACK TO Update_Ozf_Prod_Line_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Ozf_Prod_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Update_Ozf_Prod_Line_PVT;
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
End Update_Ozf_Prod_Line;

-- ==========================================================================================
-- Description: deletes Product Lines for given discount line id.
-- This method is basically used for deleting all the products (including exc;usion) rules
-- for given discount Rule
--==========================================================================================
PROCEDURE DELETE_EXCLUSIONS(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_parent_off_disc_prod_id    IN NUMBER
)
IS
CURSOR c_excl_id IS
select * FROM ozf_offer_discount_products where parent_off_disc_prod_id = p_parent_off_disc_prod_id;
L_API_NAME                  CONSTANT VARCHAR2(30) := 'DELETE_EXCLUSIONS';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;

BEGIN
SAVEPOINT Delete_Exclusions_sp;
x_return_status := FND_API.G_RET_STS_SUCCESS;

ozf_utility_pvt.debug_message('@# Parent Prod Id is '||p_parent_off_disc_prod_id);
FOR excl_rec IN c_excl_id LOOP
ozf_utility_pvt.debug_message('@# Prod id is '||excl_rec.off_discount_product_id);
    OZF_Create_Ozf_Prod_Line_PKG.Delete_row(
                                            p_off_discount_product_id  => excl_rec.off_discount_product_id,
                                            p_object_version_number  => excl_rec.object_version_number);
END LOOP;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Delete_Exclusions_sp;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Delete_Exclusions_sp;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Delete_Exclusions_sp;
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

END DELETE_EXCLUSIONS;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Ozf_Prod_Line
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_off_discount_product_id                IN   NUMBER
--       p_object_version_number   IN   NUMBER     Optional  Default = NULL
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Delete_Ozf_Prod_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_off_discount_product_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Ozf_Prod_Line';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

CURSOR c_offer_id (p_off_discount_product_id NUMBER) IS
select offer_id FROM ozf_offer_discount_products where off_discount_product_id = p_off_discount_product_id;
l_offer_id ozf_offers.offer_id%type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Delete_Ozf_Prod_Line_pvt;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      OZF_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
      -- Invoke table handler(Ozf_Create_Ozf_Prod_Line_Pkg.Delete_Row)
        open c_offer_id(p_off_discount_product_id);
            fetch c_offer_id INTO l_offer_id;
        close c_offer_id;
        IF is_delete_valid(l_offer_id) = 'N' THEN
            OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFR_CANT_DELETE_LINE');
            RAISE FND_API.G_EXC_ERROR;
        END IF;
DELETE_EXCLUSIONS(
    p_api_version_number         => p_api_version_number,
    p_init_msg_list              => p_init_msg_list,
    p_commit                     => p_commit,
    p_validation_level           => p_validation_level,
    x_return_status              => x_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data,
    p_parent_off_disc_prod_id    => p_off_discount_product_id
);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      Ozf_Create_Ozf_Prod_Line_Pkg.Delete_Row(
          p_off_discount_product_id  => p_off_discount_product_id,
          p_object_version_number => p_object_version_number     );
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


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
     ROLLBACK TO Delete_Ozf_Prod_Line_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Delete_Ozf_Prod_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Delete_Ozf_Prod_Line_PVT;
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
End Delete_Ozf_Prod_Line;



-- Hint: Primary key needs to be returned.
--=========================End Product Line Methods ============================
-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Prod_Reln
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_prod_reln_rec            IN   prod_reln_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Lock_Prod_Reln(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_discount_product_reln_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Prod_Reln';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_discount_product_reln_id                  NUMBER;

BEGIN

      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


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
Ozf_Prod_Reln_Pkg.Lock_Row(l_discount_product_reln_id,p_object_version);


 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  OZF_Utility_PVT.debug_message(l_full_name ||': end');
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Prod_Reln_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Prod_Reln_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Prod_Reln_PVT;
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
End Lock_Prod_Reln;


PROCEDURE check_Prod_Reln_Uk_Items(
    p_prod_reln_rec               IN   prod_reln_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(10);
BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_prod_reln_rec.discount_product_reln_id IS NOT NULL
      THEN
         IF OZF_Utility_PVT.check_uniqueness(
         'ozf_discount_product_reln',
         'discount_product_reln_id = ''' || p_prod_reln_rec.discount_product_reln_id ||''''
         ) = FND_API.g_false THEN

         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_DISC_PROD_RELN_ID_DUP');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      END IF;
      l_valid_flag := OZF_Utility_PVT.check_uniqueness('ozf_discount_product_reln'
                                          ,'offer_discount_line_id = '
                                          ||p_prod_reln_rec.offer_discount_line_id
                                          ||' AND off_discount_product_id = '
                                          ||p_prod_reln_rec.off_discount_product_id);
      IF l_valid_flag = FND_API.g_false THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_DISC_PROD_RELN_ID_DUP');
         x_return_status := FND_API.g_ret_sts_error; -- Correct Message
     END IF;

END check_Prod_Reln_Uk_Items;



PROCEDURE check_Prod_Reln_Req_Items(
    p_prod_reln_rec               IN  prod_reln_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_prod_reln_rec.discount_product_reln_id = FND_API.G_MISS_NUM OR p_prod_reln_rec.discount_product_reln_id IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'DISCOUNT_PRODUCT_RELN_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_prod_reln_rec.offer_discount_line_id = FND_API.G_MISS_NUM OR p_prod_reln_rec.offer_discount_line_id IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFFER_DISCOUNT_LINE_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_prod_reln_rec.off_discount_product_id = FND_API.G_MISS_NUM OR p_prod_reln_rec.off_discount_product_id IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFF_DISCOUNT_PRODUCT_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


   ELSE


      IF p_prod_reln_rec.discount_product_reln_id = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'DISCOUNT_PRODUCT_RELN_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_prod_reln_rec.offer_discount_line_id = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFFER_DISCOUNT_LINE_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_prod_reln_rec.off_discount_product_id = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFF_DISCOUNT_PRODUCT_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

END check_Prod_Reln_Req_Items;



PROCEDURE check_Prod_Reln_Fk_Items(
    p_prod_reln_rec IN prod_reln_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here
   IF p_prod_reln_rec.offer_discount_line_id <> -1 THEN
IF ozf_utility_pvt.check_fk_exists('OZF_OFFER_DISCOUNT_LINES','OFFER_DISCOUNT_LINE_ID',to_char(p_prod_reln_rec.offer_discount_line_id)) = FND_API.g_false THEN
    OZF_Utility_PVT.Error_Message('OZF_PROD_RELN_FK_DUP' ); -- correct message
    x_return_status := FND_API.g_ret_sts_error;
END IF;
IF ozf_utility_pvt.check_fk_exists('OZF_OFFER_DISCOUNT_PRODUCTS','OFF_DISCOUNT_PRODUCT_ID',to_char(p_prod_reln_rec.off_discount_product_id)) = FND_API.g_false THEN
    OZF_Utility_PVT.Error_Message('Prod_ReL_FK_Dupliucate2' );--correct message
    x_return_status := FND_API.g_ret_sts_error;
END IF;
   END IF;


END check_Prod_Reln_Fk_Items;



PROCEDURE check_Prod_Reln_Lookup_Items(
    p_prod_reln_rec IN prod_reln_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Prod_Reln_Lookup_Items;



PROCEDURE Check_Prod_Reln_Items (
    P_prod_reln_rec     IN    prod_reln_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
   l_return_status   VARCHAR2(1);
BEGIN

    l_return_status := FND_API.g_ret_sts_success;
   -- Check Items Uniqueness API calls

   check_Prod_reln_Uk_Items(
      p_prod_reln_rec => p_prod_reln_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_prod_reln_req_items(
      p_prod_reln_rec => p_prod_reln_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Foreign Keys API calls
   check_prod_reln_FK_items(
      p_prod_reln_rec => p_prod_reln_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Lookups

   check_prod_reln_Lookup_items(
      p_prod_reln_rec => p_prod_reln_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   x_return_status := l_return_status;

END Check_prod_reln_Items;





PROCEDURE Complete_Prod_Reln_Rec (
   p_prod_reln_rec IN prod_reln_rec_type,
   x_complete_rec OUT NOCOPY prod_reln_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ozf_discount_product_reln
      WHERE discount_product_reln_id = p_prod_reln_rec.discount_product_reln_id;
   l_prod_reln_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_prod_reln_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_prod_reln_rec;
   CLOSE c_complete;

   -- discount_product_reln_id
   IF p_prod_reln_rec.discount_product_reln_id IS NULL THEN
      x_complete_rec.discount_product_reln_id := l_prod_reln_rec.discount_product_reln_id;
   END IF;

   -- offer_discount_line_id
   IF p_prod_reln_rec.offer_discount_line_id IS NULL THEN
      x_complete_rec.offer_discount_line_id := l_prod_reln_rec.offer_discount_line_id;
   END IF;

   -- off_discount_product_id
   IF p_prod_reln_rec.off_discount_product_id IS NULL THEN
      x_complete_rec.off_discount_product_id := l_prod_reln_rec.off_discount_product_id;
   END IF;

   -- creation_date
   IF p_prod_reln_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_prod_reln_rec.creation_date;
   END IF;

   -- created_by
   IF p_prod_reln_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_prod_reln_rec.created_by;
   END IF;

   -- last_update_date
   IF p_prod_reln_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_prod_reln_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_prod_reln_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_prod_reln_rec.last_updated_by;
   END IF;

   -- last_update_login
   IF p_prod_reln_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_prod_reln_rec.last_update_login;
   END IF;

   -- object_version_number
/*   IF p_prod_reln_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_prod_reln_rec.object_version_number;
   END IF;
   */
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_Prod_Reln_Rec;




PROCEDURE Default_Prod_Reln_Items ( p_prod_reln_rec IN prod_reln_rec_type ,
                                x_prod_reln_rec OUT NOCOPY prod_reln_rec_type )
IS
   l_prod_reln_rec prod_reln_rec_type := p_prod_reln_rec;
BEGIN
   -- Developers should put their code to default the record type
   -- e.g. IF p_campaign_rec.status_code IS NULL
   --      OR p_campaign_rec.status_code = FND_API.G_MISS_CHAR THEN
   --         l_campaign_rec.status_code := 'NEW' ;
   --      END IF ;
   --
   NULL ;
END;

PROCEDURE Validate_Prod_Reln_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_prod_reln_rec               IN    prod_reln_rec_type
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
      OZF_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_prod_reln_Rec;



PROCEDURE Validate_Prod_Reln(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_prod_reln_rec               IN   prod_reln_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Prod_Reln';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_prod_reln_rec  prod_reln_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_prod_reln_;

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
              Check_prod_reln_Items(
                 p_prod_reln_rec        => p_prod_reln_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         Default_Prod_Reln_Items (p_prod_reln_rec => p_prod_reln_rec ,
                                x_prod_reln_rec => l_prod_reln_rec) ;
      END IF ;


      Complete_prod_reln_Rec(
         p_prod_reln_rec        => l_prod_reln_rec,
         x_complete_rec        => l_prod_reln_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_prod_reln_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_prod_reln_rec           =>    l_prod_reln_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


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
     ROLLBACK TO VALIDATE_Prod_Reln_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Prod_Reln_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Prod_Reln_;
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
End Validate_Prod_Reln;




--=======================Begin Product Discount Relation methods ==============
-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Prod_Reln
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_prod_reln_rec            IN   prod_reln_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Create_Prod_Reln(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_prod_reln_rec              IN   prod_reln_rec_type  := g_miss_prod_reln_rec,
    x_discount_product_reln_id              OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Prod_Reln';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_discount_product_reln_id              NUMBER;
   l_dummy                     NUMBER;
   l_prod_reln_rec              prod_reln_rec_type  := g_miss_prod_reln_rec;

   CURSOR c_id IS
      SELECT ozf_discount_product_reln_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM OZF_DISCOUNT_PRODUCT_RELN
      WHERE discount_product_reln_id = l_id;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_prod_reln_pvt;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.USER_ID IS NULL
      THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;




   -- Local variable initialization

   IF p_prod_reln_rec.discount_product_reln_id IS NULL OR p_prod_reln_rec.discount_product_reln_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_discount_product_reln_id;
         CLOSE c_id;

         OPEN c_id_exists(l_discount_product_reln_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
         l_discount_product_reln_id := p_prod_reln_rec.discount_product_reln_id;
   END IF;

l_prod_reln_rec := p_prod_reln_rec;
l_prod_reln_rec.discount_product_reln_id := l_discount_product_reln_id;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          OZF_UTILITY_PVT.debug_message('Private API: Validate_Prod_Reln');
          -- Invoke validation procedures
          Validate_prod_reln(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            p_prod_reln_rec  =>  l_prod_reln_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      OZF_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');

      -- Invoke table handler(Ozf_Prod_Reln_Pkg.Insert_Row)
      Ozf_Prod_Reln_Pkg.Insert_Row(
          px_discount_product_reln_id  => l_discount_product_reln_id,
          p_offer_discount_line_id  => l_prod_reln_rec.offer_discount_line_id,
          p_off_discount_product_id  => l_prod_reln_rec.off_discount_product_id,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          px_object_version_number  => l_object_version_number
);

          x_discount_product_reln_id := l_discount_product_reln_id;
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
--
-- End of API body
--

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


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
     ROLLBACK TO CREATE_Prod_Reln_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Prod_Reln_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Prod_Reln_PVT;
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
End Create_Prod_Reln;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Prod_Reln
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_prod_reln_rec            IN   prod_reln_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Update_Prod_Reln(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_prod_reln_rec               IN    prod_reln_rec_type
    )

 IS


CURSOR c_get_prod_reln(discount_product_reln_id NUMBER) IS
    SELECT *
    FROM  OZF_DISCOUNT_PRODUCT_RELN
    WHERE  discount_product_reln_id = p_prod_reln_rec.discount_product_reln_id;
    -- Hint: Developer need to provide Where clause


L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Prod_Reln';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_discount_product_reln_id    NUMBER;
l_ref_prod_reln_rec  c_get_Prod_Reln%ROWTYPE ;
l_tar_prod_reln_rec  prod_reln_rec_type := P_prod_reln_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_prod_reln_pvt;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');

      OPEN c_get_Prod_Reln( l_tar_prod_reln_rec.discount_product_reln_id);

      FETCH c_get_Prod_Reln INTO l_ref_prod_reln_rec  ;

       If ( c_get_Prod_Reln%NOTFOUND) THEN
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Prod_Reln') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       OZF_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       CLOSE     c_get_Prod_Reln;


/*      If (l_tar_prod_reln_rec.object_version_number is NULL or
          l_tar_prod_reln_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_prod_reln_rec.object_version_number <> l_ref_prod_reln_rec.object_version_number) Then
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Prod_Reln') ;
          raise FND_API.G_EXC_ERROR;
      End if;
*/

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          OZF_UTILITY_PVT.debug_message('Private API: Validate_Prod_Reln');

          -- Invoke validation procedures
          Validate_prod_reln(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_prod_reln_rec  =>  p_prod_reln_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
--      OZF_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');

      -- Invoke table handler(Ozf_Prod_Reln_Pkg.Update_Row)
      Ozf_Prod_Reln_Pkg.Update_Row(
          p_discount_product_reln_id  => p_prod_reln_rec.discount_product_reln_id,
          p_offer_discount_line_id  => p_prod_reln_rec.offer_discount_line_id,
          p_off_discount_product_id  => p_prod_reln_rec.off_discount_product_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_object_version_number  => p_prod_reln_rec.object_version_number
);
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


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
     ROLLBACK TO UPDATE_Prod_Reln_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Prod_Reln_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Prod_Reln_PVT;
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
End Update_Prod_Reln;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Prod_Reln
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_discount_product_reln_id                IN   NUMBER
--       p_object_version_number   IN   NUMBER     Optional  Default = NULL
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Delete_Prod_Reln(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_discount_product_reln_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Prod_Reln';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_prod_reln_pvt;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      OZF_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');

      -- Invoke table handler(Ozf_Prod_Reln_Pkg.Delete_Row)
      Ozf_Prod_Reln_Pkg.Delete_Row(
          p_discount_product_reln_id  => p_discount_product_reln_id,
          p_object_version_number => p_object_version_number     );
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


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
     ROLLBACK TO DELETE_Prod_Reln_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Prod_Reln_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Prod_Reln_PVT;
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
End Delete_Prod_Reln;



--=================End Product Discount relation methods =================================

--=================Begin Complete methods ================================================

PROCEDURE check_off_disc_prod(x_return_status IN OUT NOCOPY VARCHAR2
                                    , p_ozf_prod_rec IN   ozf_prod_rec_type  := g_miss_ozf_prod_rec
                                    )
IS
CURSOR C_SQL (p_offer_id NUMBER, p_offer_discount_line_id NUMBER) IS
SELECT 1 FROM dual WHERE EXISTS
    (
    SELECT 1 FROM OZF_OFFER_DISCOUNT_LINES
    WHERE offer_id = p_offer_id
    AND offer_discount_line_id = p_offer_discount_line_id
    );
    l_count NUMBER:= 0;
BEGIN
--ozf_utility_pvt.debug_message('COunt is : '||l_count);
IF p_ozf_prod_rec.offer_discount_line_id <> -1 THEN -- If creating complete disount line
OPEN C_SQL( p_ozf_prod_rec.offer_id,p_ozf_prod_rec.offer_discount_line_id);
fetch c_sql INTO l_count;
CLOSE C_SQL;

IF l_count = 0 THEN
x_return_status := FND_API.g_ret_sts_error;
ELSE
x_return_status := FND_API.G_RET_STS_SUCCESS;
END IF;

ELSE -- if creating just prooducts
    x_return_status := FND_API.G_RET_STS_SUCCESS;
END IF;
END check_off_disc_prod;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Product
--   Type
--           Private
--   Pre-Req
--             Create_Ozf_Prod_Line,check_off_disc_prod,Create_Prod_Reln
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ozf_prod_rec            IN   ozf_prod_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_off_discount_product_id OUT  NUMBER
--   Version : Current version 1.0
--
--   History
--            Wed Oct 01 2003:5/21 PM RSSHARMA Created
--
--   Description
--              : Helper method to create Products for Discount Lines.
--              Does the following validations
--              1)If offer_discount_line_id should be a valid offer_discount_line_id for the same offer
--   End of Comments
--   ==============================================================================

PROCEDURE Create_Product
(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ozf_prod_rec               IN   ozf_prod_rec_type  := g_miss_ozf_prod_rec,
    x_off_discount_product_id    OUT NOCOPY  NUMBER
     )
IS
    l_api_name                  CONSTANT VARCHAR2(30) := 'Create_Product';
    l_api_version_number        CONSTANT NUMBER   := 1.0;

--    l_return_status VARCHAR2(30);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_off_discount_product_id NUMBER;
    l_prod_reln_id NUMBER;
    l_prod_reln_rec              prod_reln_rec_type  ;

     BEGIN
      SAVEPOINT Create_Product_Pvt;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


check_off_disc_prod(x_return_status => x_return_status
                    , p_ozf_prod_rec => p_ozf_prod_rec
                                    );

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
       OZF_Utility_PVT.Error_Message('INVALID OFFER_ID:DISCOUNT ID' );-- CHANGE MESSAGE
          RAISE FND_API.G_EXC_ERROR;
      END IF;


Create_Ozf_Prod_Line(
    p_api_version_number         => p_api_version_number,
    p_init_msg_list              => p_init_msg_list,
    p_commit                     => p_commit,
    p_validation_level           => p_validation_level,

    x_return_status              => x_return_status,
    x_msg_count                  => l_msg_count,
    x_msg_data                   => l_msg_data,

    p_ozf_prod_rec               => p_ozf_prod_rec,
    x_off_discount_product_id    => l_off_discount_product_id
     );
l_prod_reln_rec.offer_discount_line_id := p_ozf_prod_rec.offer_discount_line_id;
l_prod_reln_rec.off_discount_product_id := l_off_discount_product_id;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

Create_Prod_Reln(
    p_api_version_number         => p_api_version_number,
    p_init_msg_list              => p_init_msg_list,
    p_commit                     => p_commit,
    p_validation_level           => p_validation_level,

    x_return_status              => x_return_status,
    x_msg_count                  => l_msg_count,
    x_msg_data                   => l_msg_data,

    p_prod_reln_rec              => l_prod_reln_rec,
    x_discount_product_reln_id   => l_prod_reln_id
     );

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

x_off_discount_product_id := l_off_discount_product_id;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Create_Product_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => l_msg_count,
            p_data    => l_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_Product_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => l_msg_count,
            p_data  => l_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Create_Product_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => l_msg_count,
            p_data  => l_msg_data
     );
     END Create_Product;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_offer_Line
--   Type
--           Private
--   Pre-Req
--             Create_Ozf_Disc_Line,Create Product
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ozf_offer_line_rec      IN   ozf_offer_line_rec_type   Required Record containing Discount Line Data
--       p_ozf_prod_rec            IN   ozf_prod_rec_type   Required Record containing Product Data
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_offer_discount_line_id  OUT  NUMBER. Discount Line Id of Discount Line Created
--   Version : Current version 1.0
--
--   History
--            Wed Oct 01 2003:5/21 PM RSSHARMA Created
--
--   Description
--              : Method to Create New Discount Lines.
--   End of Comments
--   ==============================================================================

PROCEDURE Create_offer_line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ozf_offer_line_rec         IN   ozf_offer_line_rec_type  ,
    p_ozf_prod_rec               IN   ozf_prod_rec_type  ,
--    p_prod_reln_rec              IN   prod_reln_rec_type  := g_miss_prod_reln_rec,
    x_offer_discount_line_id     OUT NOCOPY  NUMBER
)
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_offer_line';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;

l_offer_discount_line_id NUMBER ;
l_off_dicount_product_id NUMBER;
l_discount_product_reln_id NUMBER;

    l_ozf_offer_line_rec        ozf_offer_line_rec_type  := g_miss_ozf_offer_line_rec;
    l_ozf_prod_rec              ozf_prod_rec_type  := g_miss_ozf_prod_rec;
    l_prod_reln_rec             prod_reln_rec_type  := g_miss_prod_reln_rec;

    l_return_status VARCHAR2(30);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);

BEGIN
      SAVEPOINT Create_offer_line_pvt;
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
Create_Ozf_Disc_Line(
    p_api_version_number => p_api_version_number,
    p_init_msg_list => p_init_msg_list,
    p_commit => p_commit,
    p_validation_level => p_validation_level,
    x_return_status    => l_return_status,
    x_msg_count        => l_msg_count,
    x_msg_data         => l_msg_data,
    p_ozf_offer_line_rec =>p_ozf_offer_line_rec,
    x_offer_discount_line_id => l_offer_discount_line_id
     );
l_ozf_prod_rec := p_ozf_prod_rec;

l_ozf_prod_rec.offer_discount_line_id := l_offer_discount_line_id;

      IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
Create_Product
(
    p_api_version_number         => p_api_version_number,
    p_init_msg_list              => p_init_msg_list,
    p_commit                     => p_commit,
    p_validation_level           => p_validation_level,
    x_return_status              => x_return_status,
    x_msg_count                  => l_msg_count,
    x_msg_data                   => l_msg_data,
    p_ozf_prod_rec               => l_ozf_prod_rec,
    x_off_discount_product_id    => l_off_dicount_product_id
     );

--ozf_utility_pvt.debug_message('@ Done calling Create Reln, Reln Id is '||l_discount_product_reln_id);

      IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION


   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Create_offer_line_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_offer_line_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Create_offer_line_pvt;
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

END Create_offer_line;




--=========================================================================
-- Name : default Disc rec
-- Description : Helper method to populate fields which are not visible in the UI
-- Defaults :
--             Volume Operator - BETWEEN, Volume Break Type - POINT , Volume To
--              If tier level = HEADER , OFFER DISCOUNT LINE I
--=========================================================================
 procedure default_disc_rec(p_discount_rec IN OUT NOCOPY ozf_offer_line_rec_type)
 IS
CURSOR c_tier_level(p_offer_id NUMBER) is
SELECT tier_level FROM ozf_offers
WHERE offer_id = p_offer_id;

l_tier_level ozf_offer_discount_lines.tier_level%type := 'HEADER';

 BEGIN
    p_discount_rec.volume_operator := 'BETWEEN';
    p_discount_rec.volume_break_type := 'POINT';
    IF p_discount_rec.tier_type <> 'PBH' THEN
        p_discount_rec.volume_to := 999999999999999999;
    END IF;
    OPEN c_tier_level(p_discount_rec.offer_id);
    FETCH c_tier_level INTO l_tier_level;
    CLOSE c_tier_level;
       p_discount_rec.tier_level := l_tier_level;
    END default_disc_rec;
PROCEDURE populate_discount_rec(p_discount_rec OUT NOCOPY ozf_offer_line_rec_type
                                , p_offer_rec IN ozf_discount_line_rec_type)
IS

BEGIN
       p_discount_rec.offer_discount_line_id          := p_offer_rec.offer_discount_line_id;
       p_discount_rec.parent_discount_line_id         := p_offer_rec.parent_discount_line_id;
       p_discount_rec.volume_from                     := p_offer_rec.volume_from;
       p_discount_rec.volume_to                       := p_offer_rec.volume_to;
       p_discount_rec.volume_operator                 := p_offer_rec.volume_operator;
       p_discount_rec.volume_type                     := p_offer_rec.volume_type;
       p_discount_rec.volume_break_type               := p_offer_rec.volume_break_type;
       p_discount_rec.discount                        := p_offer_rec.discount;
       p_discount_rec.discount_type                   := p_offer_rec.discount_type;
       p_discount_rec.tier_type                       := p_offer_rec.tier_type;
       p_discount_rec.tier_level                      := p_offer_rec.tier_level;
       p_discount_rec.scan_value                      := p_offer_rec.scan_value;
       p_discount_rec.scan_data_quantity              := p_offer_rec.scan_data_quantity;
       p_discount_rec.scan_unit_forecast              := p_offer_rec.scan_unit_forecast;
       p_discount_rec.channel_id                      := p_offer_rec.channel_id;
       p_discount_rec.adjustment_flag                 := p_offer_rec.adjustment_flag;
       p_discount_rec.start_date_active               := p_offer_rec.start_date_active;
       p_discount_rec.end_date_active                 := p_offer_rec.end_date_active;
       p_discount_rec.uom_code                        := p_offer_rec.uom_code;
       p_discount_rec.creation_date                   := p_offer_rec.creation_date;
       p_discount_rec.created_by                      := p_offer_rec.created_by;
       p_discount_rec.last_update_date                := p_offer_rec.last_update_date;
       p_discount_rec.last_updated_by                 := p_offer_rec.last_updated_by;
       p_discount_rec.last_update_login               := p_offer_rec.last_update_login;
       p_discount_rec.object_version_number           := p_offer_rec.object_version_number;
       p_discount_rec.offer_id                        :=p_offer_rec.offer_id;
       default_disc_rec(p_discount_rec);
END populate_discount_rec;


PROCEDURE default_prod_rec(p_product_rec IN OUT NOCOPY ozf_prod_rec_type)
is
CURSOR c_tier_level(p_offer_id NUMBER) is
SELECT tier_level FROM ozf_offers
WHERE offer_id = p_offer_id;
l_tier_level ozf_offer_discount_lines.tier_level%type := 'HEADER';
BEGIN
    OPEN c_tier_level(p_product_rec.offer_id);
    FETCH c_tier_level INTO l_tier_level;
    CLOSE c_tier_level;
        IF(l_tier_level = 'HEADER') THEN
            p_product_rec.offer_discount_line_id := -1;
        END IF;
END default_prod_rec;
PROCEDURE populate_product_rec(p_product_rec IN OUT NOCOPY ozf_prod_rec_type
                                , p_offer_rec IN ozf_discount_line_rec_type)
IS
BEGIN
       p_product_rec.off_discount_product_id         := p_offer_rec.off_discount_product_id         ;
       p_product_rec.parent_off_disc_prod_id         := p_offer_rec.parent_off_disc_prod_id         ;
       p_product_rec.product_level                   := p_offer_rec.product_level                   ;
       p_product_rec.product_id                      := p_offer_rec.product_id                      ;
       p_product_rec.excluder_flag                   := p_offer_rec.excluder_flag                   ;
       p_product_rec.uom_code                        := p_offer_rec.uom_code                        ;
       p_product_rec.start_date_active               := p_offer_rec.start_date_active               ;
       p_product_rec.end_date_active                 := p_offer_rec.end_date_active                 ;
       p_product_rec.offer_discount_line_id          := p_offer_rec.offer_discount_line_id          ;
       p_product_rec.offer_id                        := p_offer_rec.offer_id                        ;
       p_product_rec.creation_date                   := p_offer_rec.creation_date                   ;
       p_product_rec.created_by                      := p_offer_rec.created_by                      ;
       p_product_rec.last_update_date                := p_offer_rec.last_update_date                ;
       p_product_rec.last_updated_by                 := p_offer_rec.last_updated_by                 ;
       p_product_rec.last_update_login               := p_offer_rec.last_update_login               ;
       p_product_rec.object_version_number           := p_offer_rec.object_version_number           ;
       default_prod_rec(p_product_rec);
END populate_product_rec;

PROCEDURE Create_discount_line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ozf_discount_line_rec              IN   ozf_discount_line_rec_type  ,
    x_offer_discount_line_id              OUT NOCOPY  NUMBER
)
IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Create_discount_line';
l_api_version_number        CONSTANT NUMBER   := 1.0;

l_offer_discount_line_id NUMBER ;
l_off_dicount_product_id NUMBER;
l_discount_product_reln_id NUMBER;

    l_ozf_offer_line_rec        ozf_offer_line_rec_type  := g_miss_ozf_offer_line_rec;
    l_ozf_prod_rec              ozf_prod_rec_type  := g_miss_ozf_prod_rec;
    l_prod_reln_rec             prod_reln_rec_type  := g_miss_prod_reln_rec;


BEGIN
      SAVEPOINT Create_discount_line_pvt;
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
populate_discount_rec(p_discount_rec =>l_ozf_offer_line_rec
                                , p_offer_rec =>p_ozf_discount_line_rec );
--IF p_discount_rec.tier_type <> 'PBH' THEN
populate_product_rec(p_product_rec =>l_ozf_prod_rec
                      , p_offer_rec => p_ozf_discount_line_rec);
--l_ozf_prod_rec.excluder_flag := 'N';
--END IF;
Create_offer_line(
    p_api_version_number         => p_api_version_number,
    p_init_msg_list              => p_init_msg_list,
    p_commit                     => p_commit,
    p_validation_level           => p_validation_level,

    x_return_status              => x_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data,

    p_ozf_offer_line_rec         => l_ozf_offer_line_rec,
    p_ozf_prod_rec               => l_ozf_prod_rec,
--    p_prod_reln_rec              IN   prod_reln_rec_type  := g_miss_prod_reln_rec,
    x_offer_discount_line_id     => x_offer_discount_line_id
);




      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Create_discount_line_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_discount_line_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Create_discount_line_pvt;
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

END;
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Offer_line
--   Type
--           Private
--   Pre-Req
--             Update_Ozf_Prod_Line,Update_Ozf_Disc_Line
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ozf_offer_line_rec      IN   ozf_offer_line_rec_type   Required Record containing Discount Line Data
--       p_ozf_prod_rec            IN   ozf_prod_rec_type   Required Record containing Product Data
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--   History
--            Wed Oct 01 2003:5/21 PM RSSHARMA Created
--
--   Description
--              : Method to Update the Discount Lines.
--               Since Discount and Product information is stored in separate tables
--               and in separate records , thei method sallows selective update to
--               each of the tables.
--               If offer_discount_line_id in "p_ozf_offer_line_rec" is not null then
--               UPdate to Discount Lines is called
--               If off_discount_product_id in "p_ozf_prod_rec" is not null then Update to
--               Products is called
--   End of Comments
--   ==============================================================================

PROCEDURE Update_offer_line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ozf_offer_line_rec        IN   ozf_offer_line_rec_type  ,
    p_ozf_prod_rec              IN   ozf_prod_rec_type
)
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_offer_line';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;


    l_return_status VARCHAR2(30);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);

    l_ozf_prod_rec ozf_prod_rec_type;
    l_ozf_offer_line_rec ozf_offer_line_rec_type  ;
BEGIN
      SAVEPOINT Update_offer_line_pvt;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

Update_Ozf_Disc_Line(
    p_api_version_number => p_api_version_number,
    p_init_msg_list => p_init_msg_list,
    p_commit => p_commit,
    p_validation_level => p_validation_level,
    x_return_status    => l_return_status,
    x_msg_count        => l_msg_count,
    x_msg_data         => l_msg_data,
    p_ozf_offer_line_rec => p_ozf_offer_line_rec
    );
      IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

l_ozf_prod_rec := p_ozf_prod_rec;
l_ozf_prod_rec.offer_id  := p_ozf_offer_line_rec.offer_id;
l_ozf_prod_rec.offer_discount_line_id := p_ozf_offer_line_rec.offer_discount_line_id;

--IF p_ozf_prod_rec.off_discount_product_id IS NOT NULL then
Update_Ozf_Prod_Line(
    p_api_version_number => p_api_version_number,
    p_init_msg_list => p_init_msg_list,
    p_commit => p_commit,
    p_validation_level => p_validation_level,
    x_return_status    => l_return_status,
    x_msg_count        => l_msg_count,
    x_msg_data         => l_msg_data,
    p_ozf_prod_rec =>l_ozf_prod_rec
    );

--end if;
      IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Update_offer_line_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_offer_line_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Update_offer_line_pvt;
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

END Update_offer_line;

PROCEDURE Update_discount_line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ozf_discount_line_rec              IN   ozf_discount_line_rec_type
)
IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Update_discount_line';
l_api_version_number        CONSTANT NUMBER   := 1.0;

l_offer_discount_line_id NUMBER ;
l_off_dicount_product_id NUMBER ;
l_discount_product_reln_id NUMBER ;

    l_ozf_offer_line_rec        ozf_offer_line_rec_type  := g_miss_ozf_offer_line_rec;
    l_ozf_prod_rec              ozf_prod_rec_type  := g_miss_ozf_prod_rec;
    l_prod_reln_rec             prod_reln_rec_type  := g_miss_prod_reln_rec;


/*CURSOR c_get_ozf_disc_line(offer_discount_line_id NUMBER) IS
    SELECT *
    FROM  OZF_OFFER_DISCOUNT_LINES
    WHERE  offer_discount_line_id = p_ozf_offer_line_rec.offer_discount_line_id;
    l_rec c_get_ozf_disc_line%rowtype;
    */
BEGIN
      SAVEPOINT Update_discount_line_pvt;
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

/*
    open c_get_ozf_disc_line(p_ozf_discount_line_rec.offer_discount_line_id);
    FETCH c_get_ozf_disc_line into l_rec;
    close c_get_ozf_disc_line;

      If (p_ozf_discount_line_rec.object_version_number is NULL or
          p_ozf_discount_line_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (p_ozf_discount_line_rec.object_version_number <> l_rec.object_version_number) Then
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Ozf_Disc_Line') ;
          raise FND_API.G_EXC_ERROR;
      End if;
*/
--
populate_discount_rec(p_discount_rec =>l_ozf_offer_line_rec
                                , p_offer_rec =>p_ozf_discount_line_rec );
populate_product_rec(p_product_rec =>l_ozf_prod_rec
                      , p_offer_rec => p_ozf_discount_line_rec);

Update_offer_line(
    p_api_version_number         => p_api_version_number,
    p_init_msg_list              => p_init_msg_list,
    p_commit                     => p_commit,
    p_validation_level           => p_validation_level,

    x_return_status              => x_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data,

    p_ozf_offer_line_rec        => l_ozf_offer_line_rec,
    p_ozf_prod_rec              => l_ozf_prod_rec
);


      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION


   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Update_discount_line_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_discount_line_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Update_discount_line_pvt;
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

END;


procedure Init_dl_rec (     p_ozf_offer_line_rec   IN OUT NOCOPY ozf_offer_line_rec_type )
IS
BEGIN
       p_ozf_offer_line_rec.offer_discount_line_id := FND_API.G_MISS_NUM;
       p_ozf_offer_line_rec.parent_discount_line_id := FND_API.G_MISS_NUM;
       p_ozf_offer_line_rec.volume_from             := FND_API.G_MISS_NUM;
       p_ozf_offer_line_rec.volume_to               := FND_API.G_MISS_NUM;
       p_ozf_offer_line_rec.volume_operator         := FND_API.G_MISS_CHAR;
       p_ozf_offer_line_rec.volume_type             := FND_API.G_MISS_CHAR;
       p_ozf_offer_line_rec.volume_break_type       := FND_API.G_MISS_CHAR;
       p_ozf_offer_line_rec.discount                := FND_API.G_MISS_NUM;
       p_ozf_offer_line_rec.discount_type           := FND_API.G_MISS_CHAR;
       p_ozf_offer_line_rec.tier_type               := FND_API.G_MISS_CHAR;
       p_ozf_offer_line_rec.tier_level              := FND_API.G_MISS_CHAR;
       p_ozf_offer_line_rec.scan_value              := FND_API.G_MISS_NUM;
       p_ozf_offer_line_rec.scan_data_quantity      := FND_API.G_MISS_NUM;
       p_ozf_offer_line_rec.scan_unit_forecast      := FND_API.G_MISS_NUM;
       p_ozf_offer_line_rec.channel_id              := FND_API.G_MISS_NUM;
       p_ozf_offer_line_rec.adjustment_flag         := FND_API.G_MISS_CHAR;
       p_ozf_offer_line_rec.start_date_active       := FND_API.G_MISS_DATE;
       p_ozf_offer_line_rec.end_date_active         := FND_API.G_MISS_DATE;
       p_ozf_offer_line_rec.creation_date           := FND_API.G_MISS_DATE;
       p_ozf_offer_line_rec.created_by              := FND_API.G_MISS_NUM;
       p_ozf_offer_line_rec.last_update_date        := FND_API.G_MISS_DATE;
       p_ozf_offer_line_rec.last_updated_by         := FND_API.G_MISS_NUM;
       p_ozf_offer_line_rec.last_update_login       := FND_API.G_MISS_NUM;
       p_ozf_offer_line_rec.object_version_number   := FND_API.G_MISS_NUM;
       p_ozf_offer_line_rec.offer_id                := FND_API.G_MISS_NUM;
END Init_dl_rec;



--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Product
--   Type
--           Private
--   Pre-Req
--             Update_Ozf_Prod_Line,Update_Ozf_Disc_Line
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ozf_prod_rec            IN   ozf_prod_rec_type  Required Record Used for Updating the Product
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--   History
--            Wed Oct 01 2003:5/21 PM RSSHARMA Created
--
--   Description
--              : Helper method to Update the Product Details.Also Maintains the Object Version no of the Discount Line ID
--              This methods makes the Discount Line Id as the Transaction Unit for all Updates related to Discount Lines
--              Products , Exclusions.Updates Object Version number of Discount Line Id for every change to Products linked to Discount line id
--   End of Comments
--   ==============================================================================

PROCEDURE Update_Product
(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_ozf_prod_rec              IN   ozf_prod_rec_type

)
IS
    l_api_name                  CONSTANT VARCHAR2(30) := 'Update_Product';
    l_api_version_number        CONSTANT NUMBER   := 1.0;
    l_return_status VARCHAR2(30);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);

    l_ozf_offer_line_rec              ozf_offer_line_rec_type ;

CURSOR C_DL_INFO (p_offer_discount_line_id NUMBER)is
SELECT offer_discount_line_id,offer_id,object_version_number
FROM ozf_offer_discount_lines
WHERE offer_discount_line_id = p_offer_discount_line_id;
 l_dl_rec C_DL_INFO%rowtype;


CURSOR c_discount_line_id(p_off_discount_product_id NUMBER) IS
SELECT offer_discount_line_id FROM ozf_offer_discount_products
WHERE off_discount_product_id = p_off_discount_product_id;
l_discount_line_id NUMBER;
BEGIN
      SAVEPOINT Update_product_Pvt;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
-- Update Product Line
Update_Ozf_Prod_Line(
    p_api_version_number => p_api_version_number,
    p_init_msg_list => p_init_msg_list,
    p_commit => p_commit,
    p_validation_level => p_validation_level,
    x_return_status    => x_return_status,
    x_msg_count        => l_msg_count,
    x_msg_data         => l_msg_data,
    p_ozf_prod_rec =>p_ozf_prod_rec
    );

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

-- get Discount Line Information
OPEN c_discount_line_id(p_ozf_prod_rec.off_discount_product_id);
FETCH c_discount_line_id into l_discount_line_id;
CLOSE c_discount_line_id;
OPEN C_DL_INFO(l_discount_line_id);
fetch C_DL_INFO INTO l_dl_rec;
CLOSE C_DL_INFO;

--Init_dl_rec (     p_ozf_offer_line_rec   => l_ozf_offer_line_rec );

-- POpulate Discount Line Rec
/*l_ozf_offer_line_rec.offer_discount_line_id := l_dl_rec.offer_discount_line_id;
l_ozf_offer_line_rec.object_version_number := l_dl_rec.object_version_number;
l_ozf_offer_line_rec.offer_id := l_dl_rec.offer_id;

-- Update Object version number for discount line
Update_Ozf_Disc_Line(
    p_api_version_number => p_api_version_number,
    p_init_msg_list => p_init_msg_list,
    p_commit => p_commit,
    p_validation_level => p_validation_level,
    x_return_status    => x_return_status,
    x_msg_count        => l_msg_count,
    x_msg_data         => l_msg_data,
    p_ozf_offer_line_rec => l_ozf_offer_line_rec
    );
*/
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   l_msg_count,
         p_data           =>   l_msg_data
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Update_product_Pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => l_msg_count,
            p_data    => l_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_product_Pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => l_msg_count,
            p_data  => l_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Update_product_Pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => l_msg_count,
            p_data  => l_msg_data
     );

END Update_Product;



--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Relation
--   Type
--           Private
--   Pre-Req
--             Ozf_Prod_Reln_Pkg.Delete
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_offer_discount_line_id  IN NUMBER       Required  All the Relations attached to this discount line will be deleted
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--   History
--            Wed Oct 01 2003:5/21 PM RSSHARMA Created
--
--   Description
--              : Helper method to Hard Delete All the Relations for a given discount line
--   End of Comments
--   ==============================================================================

PROCEDURE Delete_Relation(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_offer_discount_line_id    IN  NUMBER
    )
    IS
    L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Relation';
    L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
    l_return_status VARCHAR2(30);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);

BEGIN
      SAVEPOINT Delete_Relation_Pvt;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      Ozf_Prod_Reln_Pkg.Delete(
          p_offer_discount_line_id => p_offer_discount_line_id
);


      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   l_msg_count,
         p_data           =>   l_msg_data
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Delete_Relation_Pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => l_msg_count,
            p_data    => l_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Delete_Relation_Pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => l_msg_count,
            p_data  => l_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Delete_Relation_Pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => l_msg_count,
            p_data  => l_msg_data
     );
    END Delete_Relation;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Product
--   Type
--           Private
--   Pre-Req
--             Delete_Relation,OZF_Create_Ozf_Prod_Line_PKG.Delete_product
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_offer_discount_line_id  IN NUMBER       Required  All the products attached to this discount line will be deleted
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--   History
--            Wed Oct 01 2003:5/21 PM RSSHARMA Created
--
--   Description
--              : Helper method to Hard Delete All the Products for a given discount line
--   End of Comments
--   ==============================================================================

PROCEDURE Delete_Product(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_offer_discount_line_id     IN NUMBER
)
    IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Product';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;

    l_ozf_offer_line_rec              ozf_offer_line_rec_type ;
    l_ozf_prod_rec                    ozf_prod_rec_type  ;

    l_return_status VARCHAR2(30);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);



BEGIN
      SAVEPOINT Delete_Product_Pvt;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


Delete_Relation(
    p_api_version_number         => p_api_version_number,
    p_init_msg_list              => p_init_msg_list,
    p_commit                     => p_commit,
    p_validation_level           => p_validation_level,
    x_return_status              => x_return_status,
    x_msg_count                  => l_msg_count,
    x_msg_data                   => l_msg_data,
    p_offer_discount_line_id    => p_offer_discount_line_id
    );
      IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
OZF_Create_Ozf_Prod_Line_PKG.Delete_product(p_offer_discount_line_id => p_offer_discount_line_id);
      IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   l_msg_count,
         p_data           =>   l_msg_data
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Delete_Product_Pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => l_msg_count,
            p_data    => l_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Delete_Product_Pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => l_msg_count,
            p_data  => l_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Delete_Product_Pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => l_msg_count,
            p_data  => l_msg_data
     );
END Delete_Product;



--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Offer_line
--   Type
--           Private
--   Pre-Req
--             Delete_Product,delete_Ozf_Disc_Line
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_offer_discount_line_id  IN   NUMBER     Required  Discount Line id to be deleted
--       p_object_version_number   IN   NUMBER     Required  Object Version No. Of Discount Line to be deleted
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_off_discount_product_id OUT  NUMBER
--   Version : Current version 1.0
--
--   History
--            Wed Oct 01 2003:5/21 PM RSSHARMA Created
--
--   Description
--              : Helper method to Hard Delete a Discount Line and all the Related Product Lines and relations.
--   End of Comments
--   ==============================================================================

PROCEDURE Delete_offer_line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offer_discount_line_id     IN NUMBER,
    p_object_version_number      IN NUMBER
)
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_offer_line';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;

    l_ozf_offer_line_rec              ozf_offer_line_rec_type ;
    l_ozf_prod_rec                    ozf_prod_rec_type  ;

/*    l_return_status VARCHAR2(30);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
*/
    CURSOR C_PARENT_DISC_LINE(p_offer_discount_line_id NUMBER )IS
    SELECT * FROM ozf_offer_discount_lines
    WHERE offer_discount_line_id = p_offer_discount_line_id;

    l_parent_disc_line C_PARENT_DISC_LINE%rowtype;

    cursor c_offer_id(p_offer_discount_line_id NUMBER) IS
    select offer_id FROM ozf_offer_discount_lines where offer_discount_line_id = p_offer_discount_line_id;

    l_offer_id NUMBER;

BEGIN
      SAVEPOINT Delete_offer_line_Pvt;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

        open c_offer_id(p_offer_discount_line_id);
            fetch c_offer_id INTO l_offer_id;
        close c_offer_id;
        IF is_delete_valid(l_offer_id) = 'N' THEN
            OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFR_CANT_DELETE_LINE');
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    OPEN C_PARENT_DISC_LINE(p_offer_discount_line_id);
    FETCH C_PARENT_DISC_LINE into l_parent_disc_line;
    CLOSE C_PARENT_DISC_LINE;

    IF l_parent_disc_line.tier_type = 'PBH' THEN
    delete_disc_tiers(
    p_api_version_number         => p_api_version_number,
    p_init_msg_list              => p_init_msg_list,
    p_commit                     => p_commit,
    p_validation_level           => p_validation_level,
    x_return_status              => x_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data,
    p_parent_discount_line_id    => p_offer_discount_line_id
    );
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;



Delete_Product(
    p_api_version_number         => p_api_version_number,
    p_init_msg_list              => p_init_msg_list,
    p_commit                     => p_commit,
    p_validation_level           => p_validation_level,
    x_return_status              => x_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data,
    p_offer_discount_line_id     => p_offer_discount_line_id
);
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

delete_Ozf_Disc_Line
(
    p_api_version_number         => p_api_version_number,
    p_init_msg_list              => p_init_msg_list,
    p_commit                     => p_commit,
    p_validation_level           => p_validation_level,
    x_return_status              => x_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data,
    p_offer_discount_line_id     => p_offer_discount_line_id,
    p_object_version_number      => p_object_version_number
    );

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Delete_offer_line_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Delete_offer_line_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Delete_offer_line_pvt;
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
END Delete_offer_line;





PROCEDURE check_parent_off_disc_prod(x_return_status IN OUT NOCOPY VARCHAR2
                                    , p_ozf_prod_rec IN   ozf_prod_rec_type  := g_miss_ozf_prod_rec
                                    )
IS
CURSOR C_SQL (p_offer_id NUMBER, p_off_discount_product_id NUMBER,p_offer_discount_line_id NUMBER) IS
SELECT 1 FROM dual WHERE EXISTS
    (
    SELECT 1 FROM OZF_OFFER_DISCOUNT_PRODUCTS
    WHERE offer_id = p_offer_id
    AND off_discount_product_id = p_off_discount_product_id
--    AND offer_discount_line_id = p_offer_discount_line_id
    AND excluder_flag = 'N'
    );
    l_count NUMBER:= 0;
BEGIN
OPEN C_SQL( p_ozf_prod_rec.offer_id,p_ozf_prod_rec.parent_off_disc_prod_id,p_ozf_prod_rec.offer_discount_line_id);
fetch c_sql INTO l_count;
CLOSE C_SQL;
IF l_count = 0 THEN
x_return_status := FND_API.g_ret_sts_error;
ELSE
x_return_status := FND_API.G_RET_STS_SUCCESS;
END IF;

END check_parent_off_disc_prod;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Product_Exclusion
--   Type
--           Private
--   Pre-Req
--             Create_Product,check_parent_off_disc_prod
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ozf_prod_rec            IN   ozf_prod_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_off_discount_product_id OUT  NUMBER
--   Version : Current version 1.0
--
--   History
--            Wed Oct 01 2003:5/21 PM RSSHARMA Created
--
--   Description
--              : Helper method to create Exclusions for Discount Lines.
--              Does the following validations
--              1)if excluder flag is not Y then it is set to Y
--              2)If parent_off_disc_prod_id should not be null
--              3)If parent_off_disc_prod_id should be a valid off_discount_product_id for the same offer
--   End of Comments
--   ==============================================================================

PROCEDURE Create_Product_Exclusion
(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ozf_excl_rec               IN   ozf_excl_rec_type,
    x_off_discount_product_id    OUT NOCOPY  NUMBER
     )
IS
    l_api_name                  CONSTANT VARCHAR2(30) := 'Create_Product_Exclusion';
    l_api_version_number        CONSTANT NUMBER   := 1.0;

--    l_return_status VARCHAR2(30);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_off_discount_product_id NUMBER;
    l_prod_reln_id NUMBER;
    l_prod_reln_rec              prod_reln_rec_type  ;
    l_ozf_prod_rec ozf_prod_rec_type  ;

    CURSOR c_prod_info(p_off_discount_product_id NUMBER) IS
    SELECT *
    FROM ozf_offer_discount_products
    WHERE off_discount_product_id = p_off_discount_product_id;

    l_prod_rec c_prod_info%rowtype;
     BEGIN
      SAVEPOINT Create_Product_Exclusion_PVT;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Validations for Exclusions
-- 1)if excluder flag is not Y then it is set to Y
-- 2)If parent_off_disc_prod_id should not be null
-- 3)If parent_off_disc_prod_id should be a valid off_discount_product_id for the same offer

--      l_ozf_prod_rec := p_ozf_prod_rec;


       l_ozf_prod_rec.parent_off_disc_prod_id := p_ozf_excl_rec.parent_off_disc_prod_id;
       l_ozf_prod_rec.product_level           := p_ozf_excl_rec.product_level;
       l_ozf_prod_rec.product_id              := p_ozf_excl_rec.product_id;
      l_ozf_prod_rec.excluder_flag := 'Y';

    open c_prod_info(p_ozf_excl_rec.parent_off_disc_prod_id);
    fetch c_prod_info into l_prod_rec;
    close c_prod_info;
    l_ozf_prod_rec.offer_id :=  l_prod_rec.offer_id;
    l_ozf_prod_rec.offer_discount_line_id := l_prod_rec.offer_discount_line_id;

      IF l_ozf_prod_rec.parent_off_disc_prod_id = FND_API.G_MISS_NUM OR l_ozf_prod_rec.parent_off_disc_prod_id IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'PARENT_OFF_DISC_PROD_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      END IF;

      IF ozf_utility_pvt.check_fk_exists('OZF_OFFER_DISCOUNT_PRODUCTS','OFF_DISCOUNT_PRODUCT_ID',to_char(l_ozf_prod_rec.parent_off_disc_prod_id)) = FND_API.g_false THEN
                OZF_Utility_PVT.Error_Message('FK_Non_exist' ); -- correct message
                x_return_status := FND_API.g_ret_sts_error;
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
     END IF;


     check_parent_off_disc_prod(x_return_status , l_ozf_prod_rec );

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;



Create_Product
(
    p_api_version_number         => p_api_version_number,
    p_init_msg_list              => p_init_msg_list,
    p_commit                     => p_commit,
    p_validation_level           => p_validation_level,

    x_return_status              => x_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data,

    p_ozf_prod_rec               => l_ozf_prod_rec,
    x_off_discount_product_id    => x_off_discount_product_id
     );

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


-- Custom Code here
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Create_Product_Exclusion_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_Product_Exclusion_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Create_Product_Exclusion_PVT;
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
END Create_product_exclusion;

PROCEDURE Update_Product_Exclusion(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ozf_excl_rec               IN   ozf_excl_rec_type
     )
IS
    l_api_name                  CONSTANT VARCHAR2(30) := 'Update_Product_Exclusion';
    l_api_version_number        CONSTANT NUMBER   := 1.0;

--    l_return_status VARCHAR2(30);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_off_discount_product_id NUMBER;
    l_prod_reln_id NUMBER;
    l_prod_reln_rec              prod_reln_rec_type  ;
    l_ozf_prod_rec ozf_prod_rec_type  ;

    CURSOR C_ozf_prod_rec(p_off_discount_product_id NUMBER)IS
    SELECT * FROM ozf_offer_discount_products
    WHERE off_discount_product_id = p_off_discount_product_id;

    l_ref_ozf_prod_rec C_ozf_prod_rec%rowtype;

     BEGIN
      SAVEPOINT Update_Product_Exclusion_PVT;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      OPEN C_ozf_prod_rec(p_ozf_excl_rec.off_discount_product_id);
      FETCH C_ozf_prod_rec INTO l_ref_ozf_prod_rec;
      CLOSE C_ozf_prod_rec;

      If (p_ozf_excl_rec.object_version_number is NULL or
          p_ozf_excl_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (p_ozf_excl_rec.object_version_number <> l_ref_ozf_prod_rec.object_version_number) Then
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Create_Ozf_Prod_Line') ;
          raise FND_API.G_EXC_ERROR;
      End if;

/*      If (p_ozf_prod_rec.excluder_flag <> 'Y' ) Then
          OZF_Utility_PVT.Error_Message(p_message_name => 'NOT EXCLUSION') ;
          raise FND_API.G_EXC_ERROR;
      End if;
*/


       l_ozf_prod_rec.off_discount_product_id := p_ozf_excl_rec.off_discount_product_id;
       l_ozf_prod_rec.product_level          := p_ozf_excl_rec.product_level;
       l_ozf_prod_rec.product_id             := p_ozf_excl_rec.product_id;
       l_ozf_prod_rec.object_version_number  := p_ozf_excl_rec.object_version_number;

Update_Product
(
    p_api_version_number         => p_api_version_number,
    p_init_msg_list              => p_init_msg_list,
    p_commit                     => p_commit,
    p_validation_level           => p_validation_level,

    x_return_status              => x_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data,
    p_ozf_prod_rec              => l_ozf_prod_rec
);


      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Update_Product_Exclusion_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Product_Exclusion_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Update_Product_Exclusion_PVT;
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

END Update_Product_Exclusion;



PROCEDURE check_parent_disc(x_return_status OUT NOCOPY VARCHAR2
                                    ,     p_tier_rec               IN   ozf_offer_tier_rec_type
                                    )
IS
CURSOR c_tier_level(p_offer_id NUMBER) IS
SELECT tier_level FROM ozf_offers
WHERE offer_id = p_offer_id;
l_tier_level ozf_offers.tier_level%type;

CURSOR C_SQL ( p_offer_discount_line_id NUMBER) IS
SELECT 1 FROM dual WHERE EXISTS
    (
    SELECT 1 FROM OZF_OFFER_DISCOUNT_LINES
    WHERE offer_discount_line_id = p_offer_discount_line_id
    AND tier_type = 'PBH'
    );
    l_count NUMBER:= 0;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
OPEN c_tier_level(p_tier_rec.offer_id);
FETCH c_tier_level INTO l_tier_level;
close c_tier_level;

IF l_tier_level <> 'HEADER' THEN

    OPEN C_SQL( p_tier_rec.parent_discount_line_id);
    fetch c_sql INTO l_count;
    CLOSE C_SQL;

    IF l_count = 0 THEN
        ozf_utility_pvt.error_message('INVALID_parent_disc_offer');
        x_return_status := FND_API.g_ret_sts_error;
    ELSE
        x_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;
END IF;
END check_parent_disc;



PROCEDURE populate_disc_rec(p_disc_rec IN OUT NOCOPY ozf_offer_line_rec_type,
                               p_tier_rec IN ozf_offer_tier_rec_type  )
 IS
 BEGIN
       p_disc_rec.offer_discount_line_id := p_tier_rec.offer_discount_line_id;
       p_disc_rec.parent_discount_line_id:= p_tier_rec.parent_discount_line_id;
       p_disc_rec.volume_from            := p_tier_rec.volume_from;
       p_disc_rec.volume_to              := p_tier_rec.volume_to              ;
       p_disc_rec.volume_operator        := 'BETWEEN';
       p_disc_rec.volume_type            := p_tier_rec.volume_type            ;
       p_disc_rec.volume_break_type      := 'POINT';
       p_disc_rec.discount               := p_tier_rec.discount               ;
       p_disc_rec.discount_type          := p_tier_rec.discount_type          ;
       p_disc_rec.start_date_active      := p_tier_rec.start_date_active      ;
       p_disc_rec.end_date_active        := p_tier_rec.end_date_active        ;
       p_disc_rec.uom_code               := p_tier_rec.uom_code               ;
       p_disc_rec.object_version_number  := p_tier_rec.object_version_number  ;
--       p_disc_rec.offer_id             := p_tier_rec.offer_id;
 END;

PROCEDURE complete_disc_tier_rec(p_disc_rec IN OUT NOCOPY ozf_offer_line_rec_type
                                ,p_tier_rec IN ozf_offer_tier_rec_type
                                ,x_return_status         OUT NOCOPY VARCHAR2
                                )
IS
    CURSOR c_tier_level (p_offer_id NUMBER)
    is
    SELECT tier_level FROM ozf_offers
    where offer_id = p_offer_id;
    l_tier_level ozf_offers.tier_level%type;
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
        p_disc_rec.tier_type := 'DIS';
        p_disc_rec.offer_id := p_tier_rec.offer_id;
        open c_tier_level(p_tier_rec.offer_id);
        fetch c_tier_level into l_tier_level;
        close c_tier_level;
        IF  l_tier_level IS NULL THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        End If;
        p_disc_rec.tier_level := l_tier_level;
--   If (SQL%NOTFOUND) then
END complete_disc_tier_rec;


PROCEDURE check_line_level_tiers(
    p_tier_rec               IN  ozf_offer_tier_rec_type,
    p_validation_mode        IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
CURSOR c_tier_level(p_offer_id  NUMBER) IS
SELECT tier_level FROM ozf_offers
WHERE offer_id = p_offer_id;
l_tier_level VARCHAR2(30);

BEGIN
   x_return_status := FND_API.g_ret_sts_success;
OPEN c_tier_level(p_tier_rec.offer_id);
fetch c_tier_level into l_tier_level;
close c_tier_level;

   If l_tier_level IS NULL then
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;

IF l_tier_level <> 'HEADER' THEN
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      IF p_tier_rec.parent_discount_line_id = FND_API.g_miss_num OR p_tier_rec.parent_discount_line_id IS NULL THEN -- change check for parent tiers
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'PARENT_DISCOUNT_LINE_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
    ELSE
            IF p_tier_rec.parent_discount_line_id = FND_API.g_miss_num THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'PARENT_DISCOUNT_LINE_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
    END IF;
END IF;

END check_line_level_tiers;

PROCEDURE check_tier_Req_Items(
    p_tier_rec               IN  ozf_offer_tier_rec_type,
    p_validation_mode        IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

      IF p_tier_rec.volume_from = FND_API.g_miss_num OR p_tier_rec.volume_from IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'VOLUME_FROM' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_tier_rec.volume_to = FND_API.g_miss_num OR p_tier_rec.volume_to IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'VOLUME_TO' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
/*
      IF p_tier_rec.volume_operator = FND_API.g_miss_char OR p_tier_rec.volume_operator IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'VOLUME_OPERATOR' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
*/
      IF p_tier_rec.volume_type = FND_API.g_miss_char OR p_tier_rec.volume_type IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'VOLUME_TYPE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
/*
      IF p_tier_rec.volume_break_type = FND_API.g_miss_char OR p_tier_rec.volume_break_type IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'VOLUME_BREAK_TYPE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
      */
   ELSE
      IF p_tier_rec.volume_from = FND_API.g_miss_num THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'VOLUME_FROM' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_tier_rec.volume_to = FND_API.g_miss_num THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'VOLUME_TO' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
/*
      IF p_tier_rec.volume_operator = FND_API.g_miss_char THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'VOLUME_OPERATOR' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
*/
      IF p_tier_rec.volume_type = FND_API.g_miss_char THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'VOLUME_TYPE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
/*
      IF p_tier_rec.volume_break_type = FND_API.g_miss_char THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'VOLUME_BREAK_TYPE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;  */
    END IF;
    ozf_utility_pvt.debug_message('@# Ending check tier req items : return status '||x_return_status);
check_line_level_tiers( p_tier_rec , p_validation_mode , x_return_status);
END check_tier_Req_Items;

PROCEDURE check_uom(
    p_tier_rec               IN  ozf_offer_tier_rec_type,
    p_validation_mode        IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
g_qty VARCHAR2(30):= 'PRICING_ATTRIBUTE10';
g_amt VARCHAR2(30):= 'PRICING_ATTRIBUTE12';
BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
        IF p_tier_rec.volume_type = g_qty THEN
            IF p_tier_rec.uom_code IS NULL OR p_tier_rec.uom_code = FND_API.G_MISS_CHAR THEN
                       OZF_Utility_PVT.Error_Message('OZF_ACT_PRD_NO_UOM' );
                       x_return_status := FND_API.g_ret_sts_error;
            END IF;
        END IF;
    ELSE
        IF p_tier_rec.volume_type = g_qty THEN
            IF p_tier_rec.uom_code = FND_API.G_MISS_CHAR THEN
                       OZF_Utility_PVT.Error_Message('OZF_ACT_PRD_NO_UOM' );
                       x_return_status := FND_API.g_ret_sts_error;
            END IF;
        END IF;
    END IF;
END check_uom;


PROCEDURE Create_Disc_Tiers(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_tier_rec               IN   ozf_offer_tier_rec_type  ,
    x_offer_discount_line_id     OUT NOCOPY NUMBER
)
IS

    l_api_name                  CONSTANT VARCHAR2(30) := 'Create_Disc_tiers';
    l_api_version_number        CONSTANT NUMBER   := 1.0;

--    l_return_status VARCHAR2(30);

/*    l_offer_line_rec ozf_offer_line_rec_type;
    CURSOR C_ozf_disc_rec(p_offer_discount_line_id NUMBER)IS
    SELECT * FROM ozf_offer_discount_lines
    WHERE offer_discount_line_id = p_offer_discount_line_id;

    l_ozf_disc_rec C_ozf_disc_rec%rowtype;
*/
    l_disc_rec  ozf_offer_line_rec_type;
    l_tier_rec  ozf_offer_tier_rec_type := p_tier_rec;
     BEGIN
      SAVEPOINT Create_Disc_tiers_PVT;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      -- bug 3402308 populate volume_operator and volume_break_type befoer checking required items
      l_tier_rec.volume_operator := 'BETWEEN';
      l_tier_rec.volume_break_type := 'POINT';
      -- end comment
        check_parent_disc(x_return_status => x_return_status -- not required for header tiers
                                    , p_tier_rec => l_tier_rec
                                    );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;
           check_tier_Req_Items(-- change for header level tiers
                                p_tier_rec  => l_tier_rec,
                                p_validation_mode => JTF_PLSQL_API.g_create,
                                x_return_status	   => x_return_status
                                );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;
        check_uom(
                    p_tier_rec      => l_tier_rec,
                    p_validation_mode => JTF_PLSQL_API.g_create,
                    x_return_status	  => x_return_status
                  );

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;
    ozf_utility_pvt.debug_message('@# After Calling Check UOM : '||x_return_status);

/*    OPEN C_ozf_disc_rec(p_tier_rec.parent_discount_line_id);
    fetch C_ozf_disc_rec into l_ozf_disc_rec ;
    CLOSE C_ozf_disc_rec;
*/
        populate_disc_rec(p_disc_rec => l_disc_rec,p_tier_rec => l_tier_rec);
        complete_disc_tier_rec(p_disc_rec => l_disc_rec,p_tier_rec => l_tier_rec,x_return_status => x_return_status);
ozf_utility_pvt.debug_message('#@Completed Rec'||x_return_status);
        Create_Ozf_Disc_Line(
            p_api_version_number => p_api_version_number,
            p_init_msg_list => p_init_msg_list,
            p_commit => p_commit,
            p_validation_level => p_validation_level,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data,
            p_ozf_offer_line_rec =>l_disc_rec,
            x_offer_discount_line_id => x_offer_discount_line_id
             );
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
    ozf_utility_pvt.debug_message('@# After Calling Create Disc Line : '||x_return_status);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Create_Disc_tiers_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_Disc_tiers_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Create_Disc_tiers_PVT;
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

END Create_Disc_Tiers;


PROCEDURE Update_Disc_Tiers(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_tier_rec               IN   ozf_offer_tier_rec_type
)
IS
    l_api_name                  CONSTANT VARCHAR2(30) := 'Create_Disc_tiers';
    l_api_version_number        CONSTANT NUMBER   := 1.0;

--    l_return_status VARCHAR2(30);

/*    l_offer_line_rec ozf_offer_line_rec_type;
    CURSOR C_ozf_disc_rec(p_offer_discount_line_id NUMBER)IS
    SELECT * FROM ozf_offer_discount_lines
    WHERE offer_discount_line_id = p_offer_discount_line_id;

    l_ozf_disc_rec C_ozf_disc_rec%rowtype;
*/
    l_disc_rec  ozf_offer_line_rec_type;
    l_tier_rec  ozf_offer_tier_rec_type := p_tier_rec;
     BEGIN
      SAVEPOINT Create_Disc_tiers_PVT;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


---
      -- bug 3402308 populate volume_operator and volume_break_type befoer checking required items
      l_tier_rec.volume_operator := 'BETWEEN';
      l_tier_rec.volume_break_type := 'POINT';
      -- end comment

           check_tier_Req_Items(
                                p_tier_rec  => l_tier_rec,
                                p_validation_mode => JTF_PLSQL_API.g_update,
                                x_return_status	   => x_return_status
                                );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;
        check_uom(
                    p_tier_rec      => l_tier_rec,
                    p_validation_mode => JTF_PLSQL_API.g_update,
                    x_return_status	  => x_return_status
                  );

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;
        populate_disc_rec(p_disc_rec => l_disc_rec,p_tier_rec => l_tier_rec);
        complete_disc_tier_rec(p_disc_rec => l_disc_rec,p_tier_rec => l_tier_rec , x_return_status => x_return_status);

        Update_Ozf_Disc_Line(
            p_api_version_number => p_api_version_number,
            p_init_msg_list => p_init_msg_list,
            p_commit => p_commit,
            p_validation_level => p_validation_level,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data,
            p_ozf_offer_line_rec =>l_disc_rec
             );

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;




EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Create_Disc_tiers_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_Disc_tiers_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Create_Disc_tiers_PVT;
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

END Update_Disc_tiers;

PROCEDURE Delete_Disc_tiers(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_parent_discount_line_id     IN NUMBER
)
IS
    l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_Disc_tiers';
    l_api_version_number        CONSTANT NUMBER   := 1.0;

--    l_return_status VARCHAR2(30);

    CURSOR C_PARENT_DISC_LINE(p_offer_discount_line_id NUMBER )IS
    SELECT * FROM ozf_offer_discount_lines
    WHERE offer_discount_line_id = p_offer_discount_line_id;

    l_parent_disc_line C_PARENT_DISC_LINE%rowtype;

     BEGIN
      SAVEPOINT Delete_Disc_tiers_PVT;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


    OPEN C_PARENT_DISC_LINE(p_parent_discount_line_id);
    FETCH C_PARENT_DISC_LINE INTO l_parent_disc_line;
    CLOSE C_PARENT_DISC_LINE;

    IF l_parent_disc_line.tier_type <> 'PBH' THEN
    OZF_UTILITY_PVT.ERROR_MESSAGE('PARENT_NOT_PBH');
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    OZF_DISC_LINE_PKG.delete_tiers(p_parent_discount_line_id);
--
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Delete_Disc_tiers_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Delete_Disc_tiers_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Delete_Disc_tiers_PVT;
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

END Delete_Disc_tiers;



--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_tier_line
--   Type
--           Private
--   Pre-Req
--             Delete_Product,delete_Ozf_Disc_Line
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_offer_discount_line_id  IN   NUMBER     Required  Discount Line id to be deleted
--       p_object_version_number   IN   NUMBER     Required  Object Version No. Of Discount Line to be deleted
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_off_discount_product_id OUT  NUMBER
--   Version : Current version 1.0
--
--   History
--            Wed Oct 01 2003:5/21 PM RSSHARMA Created
--
--   Description
--              : Helper method to Hard Delete a Discount Line and all the Related Product Lines and relations.
--   End of Comments
--   ==============================================================================

PROCEDURE Delete_Tier_line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offer_discount_line_id     IN NUMBER,
    p_object_version_number      IN NUMBER
)
IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_tier_line';
l_api_version_number        CONSTANT NUMBER   := 1.0;


CURSOR c_tier_level(p_offer_discount_line_id NUMBER)
is
SELECT tier_level FROM ozf_offers where offer_id =
    (SELECT offer_id FROM ozf_offer_discount_lines
        WHERE offer_discount_line_id = p_offer_discount_line_id );

l_tier_level ozf_offers.tier_level%type;

BEGIN
      SAVEPOINT Delete_tier_line_Pvt;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

    open c_tier_level(p_offer_discount_line_id);
    fetch c_tier_level into l_tier_level;
    close c_tier_level;


   If l_tier_level IS NULL then
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;

IF l_tier_level <> 'HEADER' THEN
    OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_NOT_HEADER_TIER');
    RAISE FND_API.G_EXC_ERROR;
END IF;

delete_Ozf_Disc_Line
(
    p_api_version_number         => p_api_version_number,
    p_init_msg_list              => p_init_msg_list,
    p_commit                     => p_commit,
    p_validation_level           => p_validation_level,
    x_return_status              => x_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data,
    p_offer_discount_line_id     => p_offer_discount_line_id,
    p_object_version_number      => p_object_version_number
    );

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Delete_tier_line_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Delete_tier_line_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Delete_tier_line_pvt;
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
END Delete_Tier_line;

--=================End Complete Methods ==================================================
END OZF_Disc_Line_PVT;

/
