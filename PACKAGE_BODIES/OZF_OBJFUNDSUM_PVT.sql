--------------------------------------------------------
--  DDL for Package Body OZF_OBJFUNDSUM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OBJFUNDSUM_PVT" AS
/* $Header: ozfvfsub.pls 120.4.12010000.2 2009/06/19 08:41:15 kdass ship $ */

------------------------------------------------------------------------------
--
-- NAME
--    OZF_OBJFUNDSUM_PVT  12.0
--
-- HISTORY
--    06/30/2005  YZHAO     CREATION
--    06/12/2009  kdass     Bug 8532055 - ADD EXCHANGE RATE DATE PARAM TO OZF_FUND_UTILIZED_PUB.CREATE_FUND_ADJUSTMENT API

G_PKG_NAME CONSTANT VARCHAR2(30) := 'OZF_OBJFUNDSUM_PVT';

OZF_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
OZF_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
OZF_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

g_universal_currency   CONSTANT VARCHAR2 (15) := fnd_profile.VALUE ('OZF_UNIV_CURR_CODE');



-- NAME
--    complete_amount_fields
--
-- PURPOSE
--    This Procedure fills in amount in fund/object/universal currency if not passed in
--        x_amount_1           converted amount in p_currency_1
--        x_amount_2           converted amount in p_currency_2
--        x_amount_3           converted amount in universal_currency
--
-- NOTES
--
-- HISTORY
--    07/25/2005   yzhao         Created.
PROCEDURE complete_amount_fields (
   p_currency_1                 IN  VARCHAR2,
   p_amount_1                   IN  NUMBER,
   p_currency_2                 IN  VARCHAR2,
   p_amount_2                   IN  NUMBER,
   p_amount_3                   IN  NUMBER,
   p_conv_date                  IN  DATE DEFAULT NULL, --bug 8532055
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
                    ,p_conv_date=> p_conv_date --bug 8532055
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
                    ,p_conv_date=> p_conv_date --bug 8532055
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
                    ,p_conv_date=> p_conv_date --bug 8532055
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
                        ,p_conv_date=> p_conv_date --bug 8532055
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


-- NAME
--    create_objfundsum
--
-- PURPOSE
--    This Procedure creates a record in object fund summary table.
--
-- NOTES
--
-- HISTORY
--    06/30/2005   yzhao         Created.
--
PROCEDURE Create_objfundsum (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_validation_level           IN  NUMBER   := Fnd_Api.G_Valid_Level_Full,
   p_objfundsum_rec             IN  objfundsum_rec_type,
   p_conv_date                  IN  DATE DEFAULT NULL, --bug 8532055
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,
   x_objfundsum_id              OUT NOCOPY NUMBER
)
IS
   L_API_VERSION     CONSTANT NUMBER := 1.0;
   L_API_NAME        CONSTANT VARCHAR2(30) := 'CREATE_OBJFUNDSUM';
   L_FULL_NAME       CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;

   l_return_status            VARCHAR2(1);
   l_objfundsum_rec           objfundsum_rec_type := p_objfundsum_rec;
   l_objfundsum_count         NUMBER := NULL;
   l_amount_1                 NUMBER;
   l_amount_2                 NUMBER;
   l_amount_3                 NUMBER;

   CURSOR c_objfundsum_seq IS
      SELECT   ozf_object_fund_summary_s.nextval
      FROM     dual;

   CURSOR c_objfundsum_count(p_objfundsum_id   IN   NUMBER) IS
      SELECT   COUNT(objfundsum_id)
      FROM     ozf_object_fund_summary
      WHERE    objfundsum_id = p_objfundsum_id;

   CURSOR c_get_fund_currency(p_fund_id IN NUMBER) IS
      SELECT   currency_code_tc
      FROM     ozf_funds_all_b
      WHERE    fund_id = p_fund_id;

   CURSOR c_get_reference(p_offer_id IN NUMBER) IS
      SELECT arc_act_offer_used_by,act_offer_used_by_id
      FROM ozf_act_offers
      WHERE qp_list_header_id = p_offer_id;

BEGIN

   IF (OZF_DEBUG_HIGH_ON) THEN
      ozf_utility_pvt.Debug_Message(l_full_name||': start');
   END IF;

   IF Fnd_Api.To_Boolean (p_init_msg_list) THEN
      Fnd_Msg_Pub.Initialize;
   END IF;

   IF NOT Fnd_Api.Compatible_API_Call (L_API_VERSION, p_api_version, L_API_NAME, G_PKG_NAME) THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   SAVEPOINT  sp_create_objfundsum;

   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   x_objfundsum_id := NULL;

   IF l_objfundsum_rec.fund_currency IS NULL THEN
      OPEN c_get_fund_currency(l_objfundsum_rec.fund_id);
      FETCH c_get_fund_currency INTO l_objfundsum_rec.fund_currency;
      CLOSE c_get_fund_currency;
   END IF;

   IF l_objfundsum_rec.object_currency IS NULL THEN
      l_objfundsum_rec.object_currency := ozf_actbudgets_pvt.get_object_currency (
                                               p_object          => l_objfundsum_rec.object_type
                                             , p_object_id       => l_objfundsum_rec.object_id
                                             , x_return_status   => l_return_status
                                         );
      IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
         RAISE Fnd_Api.G_EXC_ERROR;
      ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
         RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   -- currency conversion for planned amount
   complete_amount_fields (
       p_currency_1                 => l_objfundsum_rec.object_currency,
       p_amount_1                   => l_objfundsum_rec.plan_curr_planned_amt,
       p_currency_2                 => l_objfundsum_rec.fund_currency,
       p_amount_2                   => l_objfundsum_rec.planned_amt,
       p_amount_3                   => l_objfundsum_rec.univ_curr_planned_amt,
       p_conv_date                  => p_conv_date, --bug 8532055
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
       p_conv_date                  => p_conv_date, --bug 8532055
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
       p_conv_date                  => p_conv_date, --bug 8532055
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
       p_conv_date                  => p_conv_date, --bug 8532055
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
       p_conv_date                  => p_conv_date, --bug 8532055
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
       p_conv_date                  => p_conv_date, --bug 8532055
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

   validate_objfundsum (
      p_api_version               => l_api_version,
      p_init_msg_list             => p_init_msg_list,
      p_validation_level          => p_validation_level,
      p_objfundsum_rec            => l_objfundsum_rec,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data,
      x_return_status             => l_return_status
   );

   IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
      RAISE Fnd_Api.G_EXC_ERROR;
   ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF (OZF_DEBUG_HIGH_ON) THEN
       ozf_utility_pvt.debug_message(l_full_name ||': insert');
   END IF;

   IF l_objfundsum_rec.objfundsum_id IS NULL THEN
      LOOP
         OPEN c_objfundsum_seq;
         FETCH c_objfundsum_seq INTO l_objfundsum_rec.objfundsum_id;
         CLOSE c_objfundsum_seq;

         OPEN  c_objfundsum_count(l_objfundsum_rec.objfundsum_id);
         FETCH c_objfundsum_count INTO l_objfundsum_count ;
         CLOSE c_objfundsum_count ;

         EXIT WHEN l_objfundsum_count = 0 ;
      END LOOP ;
   END IF;

   IF l_objfundsum_rec.reference_object_type IS NULL
      AND l_objfundsum_rec.object_type = 'OFFR' THEN
      OPEN c_get_reference(l_objfundsum_rec.object_id);
      FETCH c_get_reference INTO l_objfundsum_rec.reference_object_type, l_objfundsum_rec.reference_object_id;
      CLOSE c_get_reference;
   END IF;

   --dbms_output.put_line('Stat Before Insert : '||l_return_status);

   INSERT INTO ozf_object_fund_summary(
         objfundsum_id,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login,
         object_version_number,
         fund_id,
         fund_currency,
         object_type,
         object_id,
         object_currency,
         reference_object_type,
         reference_object_id,
         source_from_parent,
         planned_amt,
         committed_amt,
         recal_committed_amt,
         utilized_amt,
         earned_amt,
         paid_amt,
         plan_curr_planned_amt,
         plan_curr_committed_amt,
         plan_curr_recal_committed_amt,
         plan_curr_utilized_amt,
         plan_curr_earned_amt,
         plan_curr_paid_amt,
         univ_curr_planned_amt,
         univ_curr_committed_amt,
         univ_curr_recal_committed_amt,
         univ_curr_utilized_amt,
         univ_curr_earned_amt,
         univ_curr_paid_amt,
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
         attribute15
   )
   VALUES (
        l_objfundsum_rec.objfundsum_id,
        sysdate,
        Fnd_Global.User_ID,
        sysdate,
        Fnd_Global.User_ID,
        Fnd_Global.Conc_Login_ID,
        1, --Object Version Number
        l_objfundsum_rec.fund_id,
        l_objfundsum_rec.fund_currency,
        l_objfundsum_rec.object_type,
        l_objfundsum_rec.object_id,
        l_objfundsum_rec.object_currency,
        l_objfundsum_rec.reference_object_type,
        l_objfundsum_rec.reference_object_id,
        l_objfundsum_rec.source_from_parent,
        l_objfundsum_rec.planned_amt,
        l_objfundsum_rec.committed_amt,
        l_objfundsum_rec.recal_committed_amt,
        l_objfundsum_rec.utilized_amt,
        l_objfundsum_rec.earned_amt,
        l_objfundsum_rec.paid_amt,
        l_objfundsum_rec.plan_curr_planned_amt,
        l_objfundsum_rec.plan_curr_committed_amt,
        l_objfundsum_rec.plan_curr_recal_committed_amt,
        l_objfundsum_rec.plan_curr_utilized_amt,
        l_objfundsum_rec.plan_curr_earned_amt,
        l_objfundsum_rec.plan_curr_paid_amt,
        l_objfundsum_rec.univ_curr_planned_amt,
        l_objfundsum_rec.univ_curr_committed_amt,
        l_objfundsum_rec.univ_curr_recal_committed_amt,
        l_objfundsum_rec.univ_curr_utilized_amt,
        l_objfundsum_rec.univ_curr_earned_amt,
        l_objfundsum_rec.univ_curr_paid_amt,
        l_objfundsum_rec.attribute_category,
        l_objfundsum_rec.attribute1,
        l_objfundsum_rec.attribute2,
        l_objfundsum_rec.attribute3,
        l_objfundsum_rec.attribute4,
        l_objfundsum_rec.attribute5,
        l_objfundsum_rec.attribute6,
        l_objfundsum_rec.attribute7,
        l_objfundsum_rec.attribute8,
        l_objfundsum_rec.attribute9,
        l_objfundsum_rec.attribute10,
        l_objfundsum_rec.attribute11,
        l_objfundsum_rec.attribute12,
        l_objfundsum_rec.attribute13,
        l_objfundsum_rec.attribute14,
        l_objfundsum_rec.attribute15
     );

   x_objfundsum_id := l_objfundsum_rec.objfundsum_id;

   Fnd_Msg_Pub.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    Fnd_Api.G_FALSE
   );

   IF (OZF_DEBUG_HIGH_ON) THEN
      ozf_utility_pvt.debug_message(l_full_name ||': end Success');
   END IF;

EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO sp_create_objfundsum;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_create_objfundsum;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK TO sp_create_objfundsum;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
END Create_objfundsum;


-- NAME
--    update_objfundsum
--
-- PURPOSE
--    This Procedure updates record in object fund summary table.
--
-- NOTES
--
-- HISTORY
-- 05/26/1999   choang         Created.
PROCEDURE Update_objfundsum (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_validation_level           IN  NUMBER := Fnd_Api.G_VALID_LEVEL_FULL,
   p_objfundsum_rec             IN  objfundsum_rec_type,
   p_conv_date                  IN  DATE DEFAULT NULL, --bug 8532055
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
)
IS
   L_API_VERSION    CONSTANT NUMBER := 1.0;
   L_API_NAME       CONSTANT VARCHAR2(30) := 'UPDATE_objfundsum';
   L_FULL_NAME      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_objfundsum_rec  objfundsum_rec_type := p_objfundsum_rec;
   l_amount_1                 NUMBER;
   l_amount_2                 NUMBER;
   l_amount_3                 NUMBER;

BEGIN

   IF (OZF_DEBUG_HIGH_ON) THEN
      ozf_utility_pvt.debug_message('Now updating objfundsum_id: '||p_objfundsum_rec.objfundsum_id);
   END IF;

   SAVEPOINT sp_Update_objfundsum;

   IF (OZF_DEBUG_HIGH_ON) THEN
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

   IF (OZF_DEBUG_HIGH_ON) THEN
      ozf_utility_pvt.debug_message(l_full_name ||': validate');
   END IF;

   -- replace g_miss_char/num/date with current column values
   Complete_objfundsum_Rec(p_objfundsum_rec, l_objfundsum_rec);

   -- currency conversion for planned amount
   complete_amount_fields (
       p_currency_1                 => l_objfundsum_rec.object_currency,
       p_amount_1                   => l_objfundsum_rec.plan_curr_planned_amt,
       p_currency_2                 => l_objfundsum_rec.fund_currency,
       p_amount_2                   => l_objfundsum_rec.planned_amt,
       p_amount_3                   => l_objfundsum_rec.univ_curr_planned_amt,
       p_conv_date                  => p_conv_date, --bug 8532055
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
       p_conv_date                  => p_conv_date, --bug 8532055
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
       p_conv_date                  => p_conv_date, --bug 8532055
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
       p_conv_date                  => p_conv_date, --bug 8532055
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
       p_conv_date                  => p_conv_date, --bug 8532055
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
       p_conv_date                  => p_conv_date, --bug 8532055
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
      Validate_objfundsum (
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


   IF (OZF_DEBUG_HIGH_ON) THEN
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

   IF (OZF_DEBUG_HIGH_ON) THEN
      ozf_utility_pvt.debug_message(l_full_name ||': end');
   END IF;


EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO SP_Update_objfundsum;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO SP_Update_objfundsum;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK TO SP_Update_objfundsum;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
END Update_objfundsum;


-- NAME
--    process_objfundsum
--
-- PURPOSE
--    This Procedure creates a record in object fund summary table if it's not there.
--                   update  a record in object fund summary table if it's already there
--                   for update, it does cumulative update. E.g. existing record has earned_amount=$100
--                               if p_objfundsum_rec.earned_amount=$50, after this call earned_amount=$150
--
-- NOTES
--
--
PROCEDURE process_objfundsum (
   p_api_version                IN      NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_validation_level           IN  NUMBER   := Fnd_Api.G_Valid_Level_Full,
   p_objfundsum_rec             IN  objfundsum_rec_type,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,
   x_objfundsum_id              OUT NOCOPY NUMBER
)
IS
   L_API_NAME        CONSTANT VARCHAR2(30) := 'CREATE_OBJFUNDSUM';
   l_tmp_objfundsum_rec         ozf_objfundsum_pvt.objfundsum_rec_type := NULL;
   l_objfundsum_rec             ozf_objfundsum_pvt.objfundsum_rec_type := p_objfundsum_rec;
   l_objfundsum_id              NUMBER;
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(240);
   l_return_status              VARCHAR2(30);

  CURSOR c_get_objfundsum_rec(p_object_type IN VARCHAR2, p_object_id IN NUMBER, p_fund_id IN NUMBER) IS
     SELECT objfundsum_id
          , object_version_number
          , planned_amt
          , plan_curr_planned_amt
          , univ_curr_planned_amt
          , committed_amt
          , plan_curr_committed_amt
          , univ_curr_committed_amt
          , recal_committed_amt
          , plan_curr_recal_committed_amt
          , univ_curr_recal_committed_amt
          , utilized_amt
          , plan_curr_utilized_amt
          , univ_curr_utilized_amt
          , earned_amt
          , plan_curr_earned_amt
          , univ_curr_earned_amt
          , paid_amt
          , plan_curr_paid_amt
          , univ_curr_paid_amt
     FROM   ozf_object_fund_summary
     WHERE  object_type = p_object_type
     AND    object_id = p_object_id
     AND    fund_id = p_fund_id;

BEGIN
   SAVEPOINT SP_process_objfundsum;

   -- dbms_output.put_line('process_objfunsum: id=' || p_objfundsum_rec.objfundsum_id);
   IF p_objfundsum_rec.objfundsum_id IS NULL THEN
       OPEN c_get_objfundsum_rec(p_objfundsum_rec.object_type
                               , p_objfundsum_rec.object_id
                               , p_objfundsum_rec.fund_id);
       FETCH c_get_objfundsum_rec INTO l_objfundsum_rec.objfundsum_id
                                     , l_objfundsum_rec.object_version_number
                                     , l_tmp_objfundsum_rec.planned_amt
                                     , l_tmp_objfundsum_rec.plan_curr_planned_amt
                                     , l_tmp_objfundsum_rec.univ_curr_planned_amt
                                     , l_tmp_objfundsum_rec.committed_amt
                                     , l_tmp_objfundsum_rec.plan_curr_committed_amt
                                     , l_tmp_objfundsum_rec.univ_curr_committed_amt
                                     , l_tmp_objfundsum_rec.recal_committed_amt
                                     , l_tmp_objfundsum_rec.plan_curr_recal_committed_amt
                                     , l_tmp_objfundsum_rec.univ_curr_recal_committed_amt
                                     , l_tmp_objfundsum_rec.utilized_amt
                                     , l_tmp_objfundsum_rec.plan_curr_utilized_amt
                                     , l_tmp_objfundsum_rec.univ_curr_utilized_amt
                                     , l_tmp_objfundsum_rec.earned_amt
                                     , l_tmp_objfundsum_rec.plan_curr_earned_amt
                                     , l_tmp_objfundsum_rec.univ_curr_earned_amt
                                     , l_tmp_objfundsum_rec.paid_amt
                                     , l_tmp_objfundsum_rec.plan_curr_paid_amt
                                     , l_tmp_objfundsum_rec.univ_curr_paid_amt;
       IF c_get_objfundsum_rec%NOTFOUND THEN
           CLOSE c_get_objfundsum_rec;
           ozf_objfundsum_pvt.create_objfundsum(
               p_api_version                => 1.0,
               p_init_msg_list              => p_init_msg_list,
               p_validation_level           => p_validation_level,
               p_objfundsum_rec             => p_objfundsum_rec,
               x_return_status              => x_return_status,
               x_msg_count                  => x_msg_count,
               x_msg_data                   => x_msg_data,
               x_objfundsum_id              => l_objfundsum_id
           );
           -- dbms_output.put_line('process_objfunsum: create_objfunsum returns ' || l_return_status);
           IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              RAISE fnd_api.g_exc_unexpected_error;
           ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
              RAISE fnd_api.g_exc_error;
           END IF;
           RETURN;
       ELSE
           CLOSE c_get_objfundsum_rec;
       END IF;  -- IF c_get_objfundsum_rec%NOTFOUND THEN
   END IF;  -- IF p_objfundsum_rec.objfundsum_id IS NULL

   IF NVL(p_objfundsum_rec.planned_amt, 0) <> 0 THEN
       l_objfundsum_rec.planned_amt := NVL(l_tmp_objfundsum_rec.planned_amt, 0) + p_objfundsum_rec.planned_amt;
   END IF;
   IF NVL(p_objfundsum_rec.plan_curr_planned_amt, 0) <> 0 THEN
       l_objfundsum_rec.plan_curr_planned_amt := NVL(l_tmp_objfundsum_rec.plan_curr_planned_amt, 0)
                                           + p_objfundsum_rec.plan_curr_planned_amt;
   END IF;
   IF NVL(p_objfundsum_rec.univ_curr_planned_amt, 0) <> 0 THEN
       l_objfundsum_rec.univ_curr_planned_amt := NVL(l_tmp_objfundsum_rec.univ_curr_planned_amt, 0)
                                           + p_objfundsum_rec.univ_curr_planned_amt;
   END IF;
   IF NVL(p_objfundsum_rec.committed_amt, 0) <> 0 THEN
       l_objfundsum_rec.committed_amt := NVL(l_tmp_objfundsum_rec.committed_amt, 0) + p_objfundsum_rec.committed_amt;
   END IF;
   IF NVL(p_objfundsum_rec.plan_curr_committed_amt, 0) <> 0 THEN
       l_objfundsum_rec.plan_curr_committed_amt := NVL(l_tmp_objfundsum_rec.plan_curr_committed_amt, 0)
                                           + p_objfundsum_rec.plan_curr_committed_amt;
   END IF;
   IF NVL(p_objfundsum_rec.univ_curr_committed_amt, 0) <> 0 THEN
       l_objfundsum_rec.univ_curr_committed_amt := NVL(l_tmp_objfundsum_rec.univ_curr_committed_amt, 0)
                                           + p_objfundsum_rec.univ_curr_committed_amt;
   END IF;
   IF NVL(p_objfundsum_rec.recal_committed_amt, 0) <> 0 THEN
       l_objfundsum_rec.recal_committed_amt := NVL(l_tmp_objfundsum_rec.recal_committed_amt, 0)
                                          + p_objfundsum_rec.recal_committed_amt;
   END IF;
   IF NVL(p_objfundsum_rec.plan_curr_recal_committed_amt, 0) <> 0 THEN
       l_objfundsum_rec.plan_curr_recal_committed_amt := NVL(l_tmp_objfundsum_rec.plan_curr_recal_committed_amt, 0)
                                           + p_objfundsum_rec.plan_curr_recal_committed_amt;
   END IF;
   IF NVL(p_objfundsum_rec.univ_curr_recal_committed_amt, 0) <> 0 THEN
       l_objfundsum_rec.univ_curr_recal_committed_amt := NVL(l_tmp_objfundsum_rec.univ_curr_recal_committed_amt, 0)
                                           + p_objfundsum_rec.univ_curr_recal_committed_amt;
   END IF;
   IF NVL(p_objfundsum_rec.utilized_amt, 0) <> 0 THEN
       l_objfundsum_rec.utilized_amt := NVL(l_tmp_objfundsum_rec.utilized_amt, 0) + p_objfundsum_rec.utilized_amt;
   END IF;
   IF NVL(p_objfundsum_rec.plan_curr_utilized_amt, 0) <> 0 THEN
       l_objfundsum_rec.plan_curr_utilized_amt := NVL(l_tmp_objfundsum_rec.plan_curr_utilized_amt, 0)
                                           + p_objfundsum_rec.plan_curr_utilized_amt;
   END IF;
   IF NVL(p_objfundsum_rec.univ_curr_utilized_amt, 0) <> 0 THEN
       l_objfundsum_rec.univ_curr_utilized_amt := NVL(l_tmp_objfundsum_rec.univ_curr_utilized_amt, 0)
                                           + p_objfundsum_rec.univ_curr_utilized_amt;
   END IF;
   IF NVL(p_objfundsum_rec.earned_amt, 0) <> 0 THEN
       l_objfundsum_rec.earned_amt := NVL(l_tmp_objfundsum_rec.earned_amt, 0) + p_objfundsum_rec.earned_amt;
   END IF;
   IF NVL(p_objfundsum_rec.plan_curr_earned_amt, 0) <> 0 THEN
       l_objfundsum_rec.plan_curr_earned_amt := NVL(l_tmp_objfundsum_rec.plan_curr_earned_amt, 0)
                                           + p_objfundsum_rec.plan_curr_earned_amt;
   END IF;
   IF NVL(p_objfundsum_rec.univ_curr_earned_amt, 0) <> 0 THEN
       l_objfundsum_rec.univ_curr_earned_amt := NVL(l_tmp_objfundsum_rec.univ_curr_earned_amt, 0)
                                           + p_objfundsum_rec.univ_curr_earned_amt;
   END IF;
   IF NVL(p_objfundsum_rec.paid_amt, 0) <> 0 THEN
       l_objfundsum_rec.paid_amt := NVL(l_tmp_objfundsum_rec.paid_amt, 0) + p_objfundsum_rec.paid_amt;
   END IF;
   IF NVL(p_objfundsum_rec.plan_curr_paid_amt, 0) <> 0 THEN
       l_objfundsum_rec.plan_curr_paid_amt := NVL(l_tmp_objfundsum_rec.plan_curr_paid_amt, 0)
                                           + p_objfundsum_rec.plan_curr_paid_amt;
   END IF;
   IF NVL(p_objfundsum_rec.univ_curr_paid_amt, 0) <> 0 THEN
       l_objfundsum_rec.univ_curr_paid_amt := NVL(l_tmp_objfundsum_rec.univ_curr_paid_amt, 0)
                                           + p_objfundsum_rec.univ_curr_paid_amt;
   END IF;

   ozf_objfundsum_pvt.update_objfundsum(
       p_api_version                => p_api_version,
       p_init_msg_list              => p_init_msg_list,
       p_validation_level           => p_validation_level,
       p_objfundsum_rec             => l_objfundsum_rec,
       x_return_status              => x_return_status,
       x_msg_count                  => x_msg_count,
       x_msg_data                   => x_msg_data
   );
   -- dbms_output.put_line('process_objfunsum: update_objfunsum returns ' || x_return_status);
   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;

EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO SP_process_objfundsum;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO SP_process_objfundsum;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK TO SP_process_objfundsum;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
END process_objfundsum;


-- NAME
--    Validate_objfundsum
--
-- PURPOSE
--   Validation API for Activity metrics.
--
-- NOTES
--
-- HISTORY
--   06/30/2005   yzhao         Created.

PROCEDURE Validate_objfundsum (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_validation_level           IN  NUMBER   := Fnd_Api.G_Valid_Level_Full,
   p_objfundsum_rec             IN  objfundsum_rec_type,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
)
IS
   L_API_VERSION    CONSTANT NUMBER := 1.0;
   L_API_NAME       CONSTANT VARCHAR2(30) := 'VALIDATE_OBJFUNDSUM';
   L_FULL_NAME      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_table_name   VARCHAR2 (30);
   l_pk_name      VARCHAR2 (30);
   l_pk_value     VARCHAR2 (30);
   l_return_status  VARCHAR2(1);

BEGIN
   IF (OZF_DEBUG_HIGH_ON) THEN
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

   x_return_status := NULL;

   IF (OZF_DEBUG_HIGH_ON) THEN
      ozf_utility_pvt.debug_message(l_full_name||': Validation');
   END IF;

   IF p_validation_level >= Jtf_Plsql_Api.g_valid_level_item THEN
       -- fund_id is required
       IF p_objfundsum_rec.fund_id IS NULL OR
          p_objfundsum_rec.fund_id = fnd_api.g_miss_num
       THEN
          IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR)
          THEN
             Fnd_Message.Set_Name('OZF', 'OZF_OBJFUNDSUM_MISSING_FUND_ID');
             Fnd_Msg_Pub.ADD;
          END IF;
          RAISE Fnd_Api.G_EXC_ERROR;
       END IF;

       -- fund_currency is required
       IF p_objfundsum_rec.fund_currency IS NULL OR
          p_objfundsum_rec.fund_currency = fnd_api.g_miss_char
       THEN
          IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR)
          THEN
             Fnd_Message.Set_Name('OZF', 'OZF_OBJFUNDSUM_MISSING_FUND_CURRENCY');
             Fnd_Msg_Pub.ADD;
          END IF;
          RAISE Fnd_Api.G_EXC_ERROR;
       END IF;

       -- object_type is required
       IF p_objfundsum_rec.object_type IS NULL OR
          p_objfundsum_rec.object_type = fnd_api.g_miss_char
       THEN
          IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR)
          THEN
             Fnd_Message.Set_Name('OZF', 'OZF_OBJFUNDSUM_MISSING_OBJECT_TYPE');
             Fnd_Msg_Pub.ADD;
          END IF;
          RAISE Fnd_Api.G_EXC_ERROR;
       END IF;

       -- object_id is required
       IF p_objfundsum_rec.object_id IS NULL OR
          p_objfundsum_rec.object_id = fnd_api.g_miss_num
       THEN
          IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR)
          THEN
             Fnd_Message.Set_Name('OZF', 'OZF_OBJFUNDSUM_MISSING_OBJECT_ID');
             Fnd_Msg_Pub.ADD;
          END IF;
          RAISE Fnd_Api.G_EXC_ERROR;
       END IF;

       -- object_currency is required
       IF p_objfundsum_rec.object_currency IS NULL OR
          p_objfundsum_rec.object_currency = fnd_api.g_miss_char
       THEN
          IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR)
          THEN
             Fnd_Message.Set_Name('OZF', 'OZF_OBJFUNDSUM_MISSING_OBJECT_CURRENCY');
             Fnd_Msg_Pub.ADD;
          END IF;
          RAISE Fnd_Api.G_EXC_ERROR;
       END IF;

       -- object_type should be valid code in lookup type OZF_FUND_TYPE
       IF ozf_utility_pvt.check_lookup_exists (
            p_lookup_type=> 'OZF_FUND_SOURCE'
           ,p_lookup_code=> p_objfundsum_rec.object_type
          ) = fnd_api.g_false THEN
          IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
             fnd_message.set_name ('OZF', 'OZF_OBJFUNDSUM_BAD_OBJTYPE');
             fnd_msg_pub.ADD;
          END IF;
          RAISE Fnd_Api.G_EXC_ERROR;
       END IF;

       -- fund_id should be valid in ozf_funds_all_b
       IF ozf_utility_pvt.check_fk_exists (
               p_table_name=> 'OZF_FUNDS_ALL_B'
              ,p_pk_name=> 'FUND_ID'
              ,p_pk_value=> p_objfundsum_rec.fund_id
          ) = fnd_api.g_false THEN
          IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
             fnd_message.set_name ('OZF', 'OZF_OBJFUNDSUM_BAD_FUNDID');
             fnd_msg_pub.ADD;
          END IF;
          RAISE Fnd_Api.G_EXC_ERROR;
       END IF;

       -- Check FK parameter: object_id
       IF p_objfundsum_rec.object_type = ('EVEH') THEN
          l_table_name               := 'AMS_EVENT_HEADERS_B';
          l_pk_name                  := 'EVENT_HEADER_ID';
        ELSIF p_objfundsum_rec.object_type IN ( 'EVEO','EONE') THEN
          l_table_name               := 'AMS_EVENT_OFFERS_B';
          l_pk_name                  := 'EVENT_OFFER_ID';
       ELSIF p_objfundsum_rec.object_type = 'DELV' THEN
          l_table_name               := 'AMS_DELIVERABLES_B';
          l_pk_name                  := 'DELIVERABLE_ID';
       ELSIF p_objfundsum_rec.object_type = 'CAMP' THEN
          l_table_name               := 'AMS_CAMPAIGNS_B';
          l_pk_name                  := 'CAMPAIGN_ID';
       ELSIF p_objfundsum_rec.object_type = 'CSCH' THEN
          l_table_name               := 'AMS_CAMPAIGN_SCHEDULES_B';
          l_pk_name                  := 'SCHEDULE_ID';
       ELSIF p_objfundsum_rec.object_type = 'OFFR'
          OR p_objfundsum_rec.object_type = 'PRIC' THEN
          l_table_name               := 'QP_LIST_HEADERS';
          l_pk_name                  := 'LIST_HEADER_ID';
       END IF;
       l_pk_value                 := p_objfundsum_rec.object_id;
       IF ozf_utility_pvt.check_fk_exists (
               p_table_name=> l_table_name
              ,p_pk_name=> l_pk_name
              ,p_pk_value=> l_pk_value
          ) = fnd_api.g_false THEN
          IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
             fnd_message.set_name ('OZF', 'OZF_OBJFUNDSUM_BAD_OBJID');
             fnd_msg_pub.ADD;
          END IF;
          RAISE Fnd_Api.G_EXC_ERROR;
       END IF;

   END IF;

   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   Fnd_Msg_Pub.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    Fnd_Api.G_FALSE
   );

   IF (OZF_DEBUG_HIGH_ON) THEN
      ozf_utility_pvt.debug_message(l_full_name ||': end');
   END IF;

EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>   FND_API.G_FALSE
      );
END Validate_objfundsum;



--
-- NAME
--    Complete_objfundsum_Rec
--
-- PURPOSE
--   Returns the Initialized objectfundsummary Record
--
-- NOTES
--
-- HISTORY
-- 07/19/1999   choang         Created.
--
PROCEDURE Complete_objfundsum_Rec(
   p_objfundsum_rec      IN  objfundsum_rec_type,
   x_complete_rec        IN OUT NOCOPY objfundsum_rec_type
)
IS
   CURSOR c_objfundsum IS
   SELECT *
     FROM ozf_object_fund_summary
    WHERE objfundsum_id = p_objfundsum_rec.objfundsum_id;

   l_objfundsum_rec  c_objfundsum%ROWTYPE;
BEGIN

   x_complete_rec := p_objfundsum_rec;

   OPEN c_objfundsum;
   FETCH c_objfundsum INTO l_objfundsum_rec;
   IF c_objfundsum%NOTFOUND THEN
      CLOSE c_objfundsum;
      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         Fnd_Msg_Pub.ADD;
      END IF;
      RAISE Fnd_Api.g_exc_error;
   END IF;
   CLOSE c_objfundsum;

   IF p_objfundsum_rec.fund_id = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.fund_id := NULL;
   END IF;
   IF p_objfundsum_rec.fund_id IS NULL THEN
      x_complete_rec.fund_id := l_objfundsum_rec.fund_id;
   END IF;

   IF p_objfundsum_rec.fund_currency = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.fund_currency := NULL;
   END IF;
   IF p_objfundsum_rec.fund_currency IS NULL THEN
      x_complete_rec.fund_currency := l_objfundsum_rec.fund_currency;
   END IF;

   IF p_objfundsum_rec.object_type = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.object_type := NULL;
   END IF;
   IF p_objfundsum_rec.object_type IS NULL THEN
      x_complete_rec.object_type := l_objfundsum_rec.object_type;
   END IF;

   IF p_objfundsum_rec.object_id = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.object_id := NULL;
   END IF;
   IF p_objfundsum_rec.object_id IS NULL THEN
      x_complete_rec.object_id := l_objfundsum_rec.object_id;
   END IF;

   IF p_objfundsum_rec.object_currency = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.object_currency := NULL;
   END IF;
   IF p_objfundsum_rec.object_currency IS NULL THEN
      x_complete_rec.object_currency := l_objfundsum_rec.object_currency;
   END IF;

   IF p_objfundsum_rec.reference_object_type = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.reference_object_type := NULL;
   END IF;
   IF p_objfundsum_rec.reference_object_type IS NULL THEN
      x_complete_rec.reference_object_type := l_objfundsum_rec.reference_object_type;
   END IF;

   IF p_objfundsum_rec.reference_object_id = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.reference_object_id := NULL;
   END IF;
   IF p_objfundsum_rec.reference_object_id IS NULL THEN
      x_complete_rec.reference_object_id := l_objfundsum_rec.reference_object_id;
   END IF;

   IF p_objfundsum_rec.source_from_parent = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.source_from_parent := NULL;
   END IF;
   IF p_objfundsum_rec.source_from_parent IS NULL THEN
      x_complete_rec.source_from_parent := l_objfundsum_rec.source_from_parent;
   END IF;

   IF p_objfundsum_rec.planned_amt = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.planned_amt := NULL;
   END IF;
   IF p_objfundsum_rec.planned_amt IS NULL THEN
      x_complete_rec.planned_amt := l_objfundsum_rec.planned_amt;
   END IF;

   IF p_objfundsum_rec.committed_amt = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.committed_amt := NULL;
   END IF;
   IF p_objfundsum_rec.committed_amt IS NULL THEN
      x_complete_rec.committed_amt := l_objfundsum_rec.committed_amt;
   END IF;

   IF p_objfundsum_rec.recal_committed_amt = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.recal_committed_amt := NULL;
   END IF;
   IF p_objfundsum_rec.recal_committed_amt IS NULL THEN
      x_complete_rec.recal_committed_amt := l_objfundsum_rec.recal_committed_amt;
   END IF;

   IF p_objfundsum_rec.utilized_amt = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.utilized_amt := NULL;
   END IF;
   IF p_objfundsum_rec.utilized_amt IS NULL THEN
      x_complete_rec.utilized_amt := l_objfundsum_rec.utilized_amt;
   END IF;

   IF p_objfundsum_rec.earned_amt = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.earned_amt := NULL;
   END IF;
   IF p_objfundsum_rec.earned_amt IS NULL THEN
      x_complete_rec.earned_amt := l_objfundsum_rec.earned_amt;
   END IF;

   IF p_objfundsum_rec.paid_amt = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.paid_amt := NULL;
   END IF;
   IF p_objfundsum_rec.paid_amt IS NULL THEN
      x_complete_rec.paid_amt := l_objfundsum_rec.paid_amt;
   END IF;

   IF p_objfundsum_rec.plan_curr_planned_amt = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.plan_curr_planned_amt := NULL;
   END IF;
   IF p_objfundsum_rec.plan_curr_planned_amt IS NULL THEN
      x_complete_rec.plan_curr_planned_amt := l_objfundsum_rec.plan_curr_planned_amt;
   END IF;

   IF p_objfundsum_rec.plan_curr_committed_amt = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.plan_curr_committed_amt := NULL;
   END IF;
   IF p_objfundsum_rec.plan_curr_committed_amt IS NULL THEN
      x_complete_rec.plan_curr_committed_amt := l_objfundsum_rec.plan_curr_committed_amt;
   END IF;

   IF p_objfundsum_rec.plan_curr_recal_committed_amt = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.plan_curr_recal_committed_amt := NULL;
   END IF;
   IF p_objfundsum_rec.plan_curr_recal_committed_amt IS NULL THEN
      x_complete_rec.plan_curr_recal_committed_amt := l_objfundsum_rec.plan_curr_recal_committed_amt;
   END IF;

   IF p_objfundsum_rec.plan_curr_utilized_amt = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.plan_curr_utilized_amt := NULL;
   END IF;
   IF p_objfundsum_rec.plan_curr_utilized_amt IS NULL THEN
      x_complete_rec.plan_curr_utilized_amt := l_objfundsum_rec.plan_curr_utilized_amt;
   END IF;

   IF p_objfundsum_rec.plan_curr_earned_amt = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.plan_curr_earned_amt := NULL;
   END IF;
   IF p_objfundsum_rec.plan_curr_earned_amt IS NULL THEN
      x_complete_rec.plan_curr_earned_amt := l_objfundsum_rec.plan_curr_earned_amt;
   END IF;

   IF p_objfundsum_rec.plan_curr_paid_amt = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.plan_curr_paid_amt := NULL;
   END IF;
   IF p_objfundsum_rec.plan_curr_paid_amt IS NULL THEN
      x_complete_rec.plan_curr_paid_amt := l_objfundsum_rec.plan_curr_paid_amt;
   END IF;

   IF p_objfundsum_rec.univ_curr_planned_amt = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.univ_curr_planned_amt := NULL;
   END IF;
   IF p_objfundsum_rec.univ_curr_planned_amt IS NULL THEN
      x_complete_rec.univ_curr_planned_amt := l_objfundsum_rec.univ_curr_planned_amt;
   END IF;

   IF p_objfundsum_rec.univ_curr_committed_amt = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.univ_curr_committed_amt := NULL;
   END IF;
   IF p_objfundsum_rec.univ_curr_committed_amt IS NULL THEN
      x_complete_rec.univ_curr_committed_amt := l_objfundsum_rec.univ_curr_committed_amt;
   END IF;

   IF p_objfundsum_rec.univ_curr_recal_committed_amt = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.univ_curr_recal_committed_amt := NULL;
   END IF;
   IF p_objfundsum_rec.univ_curr_recal_committed_amt IS NULL THEN
      x_complete_rec.univ_curr_recal_committed_amt := l_objfundsum_rec.univ_curr_recal_committed_amt;
   END IF;

   IF p_objfundsum_rec.univ_curr_utilized_amt = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.univ_curr_utilized_amt := NULL;
   END IF;
   IF p_objfundsum_rec.univ_curr_utilized_amt IS NULL THEN
      x_complete_rec.univ_curr_utilized_amt := l_objfundsum_rec.univ_curr_utilized_amt;
   END IF;

   IF p_objfundsum_rec.univ_curr_earned_amt = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.univ_curr_earned_amt := NULL;
   END IF;
   IF p_objfundsum_rec.univ_curr_earned_amt IS NULL THEN
      x_complete_rec.univ_curr_earned_amt := l_objfundsum_rec.univ_curr_earned_amt;
   END IF;

   IF p_objfundsum_rec.univ_curr_paid_amt = Fnd_Api.G_MISS_NUM THEN
      x_complete_rec.univ_curr_paid_amt := NULL;
   END IF;
   IF p_objfundsum_rec.univ_curr_paid_amt IS NULL THEN
      x_complete_rec.univ_curr_paid_amt := l_objfundsum_rec.univ_curr_paid_amt;
   END IF;


   IF p_objfundsum_rec.attribute_category = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute_category := NULL;
   END IF;
   IF p_objfundsum_rec.attribute_category IS NULL THEN
      x_complete_rec.attribute_category := l_objfundsum_rec.attribute_category;
   END IF;

   IF p_objfundsum_rec.attribute1 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute1 := NULL;
   END IF;
   IF p_objfundsum_rec.attribute1 IS NULL THEN
      x_complete_rec.attribute1 := l_objfundsum_rec.attribute1;
   END IF;

   IF p_objfundsum_rec.attribute2 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute2 := NULL;
   END IF;
   IF p_objfundsum_rec.attribute2 IS NULL THEN
      x_complete_rec.attribute2 := l_objfundsum_rec.attribute2;
   END IF;

   IF p_objfundsum_rec.attribute3 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute3 := NULL;
   END IF;
   IF p_objfundsum_rec.attribute3 IS NULL THEN
      x_complete_rec.attribute3 := l_objfundsum_rec.attribute3;
   END IF;

   IF p_objfundsum_rec.attribute4 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute4 := NULL;
   END IF;
   IF p_objfundsum_rec.attribute4 IS NULL THEN
      x_complete_rec.attribute4 := l_objfundsum_rec.attribute4;
   END IF;

   IF p_objfundsum_rec.attribute5 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute5 := NULL;
   END IF;
   IF p_objfundsum_rec.attribute5 IS NULL THEN
      x_complete_rec.attribute5 := l_objfundsum_rec.attribute5;
   END IF;

   IF p_objfundsum_rec.attribute6 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute6 := NULL;
   END IF;
   IF p_objfundsum_rec.attribute6 IS NULL THEN
      x_complete_rec.attribute6 := l_objfundsum_rec.attribute6;
   END IF;

   IF p_objfundsum_rec.attribute7 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute7 := NULL;
   END IF;
   IF p_objfundsum_rec.attribute7 IS NULL THEN
      x_complete_rec.attribute7 := l_objfundsum_rec.attribute7;
   END IF;

   IF p_objfundsum_rec.attribute8 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute8 := NULL;
   END IF;
   IF p_objfundsum_rec.attribute8 IS NULL THEN
      x_complete_rec.attribute8 := l_objfundsum_rec.attribute8;
   END IF;

   IF p_objfundsum_rec.attribute9 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute9 := NULL;
   END IF;
   IF p_objfundsum_rec.attribute9 IS NULL THEN
      x_complete_rec.attribute9 := l_objfundsum_rec.attribute9;
   END IF;

   IF p_objfundsum_rec.attribute10 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute10 := NULL;
   END IF;
   IF p_objfundsum_rec.attribute10 IS NULL THEN
      x_complete_rec.attribute10 := l_objfundsum_rec.attribute10;
   END IF;

   IF p_objfundsum_rec.attribute11 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute11 := NULL;
   END IF;
   IF p_objfundsum_rec.attribute11 IS NULL THEN
      x_complete_rec.attribute11 := l_objfundsum_rec.attribute11;
   END IF;

   IF p_objfundsum_rec.attribute12 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute12 := NULL;
   END IF;
   IF p_objfundsum_rec.attribute12 IS NULL THEN
      x_complete_rec.attribute12 := l_objfundsum_rec.attribute12;
   END IF;

   IF p_objfundsum_rec.attribute13 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute13 := NULL;
   END IF;
   IF p_objfundsum_rec.attribute13 IS NULL THEN
      x_complete_rec.attribute13 := l_objfundsum_rec.attribute13;
   END IF;

   IF p_objfundsum_rec.attribute14 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute14 := NULL;
   END IF;
   IF p_objfundsum_rec.attribute14 IS NULL THEN
      x_complete_rec.attribute14 := l_objfundsum_rec.attribute14;
   END IF;

   IF p_objfundsum_rec.attribute15 = Fnd_Api.G_MISS_CHAR THEN
      x_complete_rec.attribute15 := NULL;
   END IF;
   IF p_objfundsum_rec.attribute15 IS NULL THEN
      x_complete_rec.attribute15 := l_objfundsum_rec.attribute15;
   END IF;

END Complete_objfundsum_Rec ;


END Ozf_objfundsum_Pvt;

/
