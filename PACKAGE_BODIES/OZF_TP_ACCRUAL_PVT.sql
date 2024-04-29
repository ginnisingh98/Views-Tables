--------------------------------------------------------
--  DDL for Package Body OZF_TP_ACCRUAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_TP_ACCRUAL_PVT" AS
/* $Header: ozfvtpab.pls 120.24.12010000.8 2010/02/17 08:54:26 nepanda ship $ */

-- Package name     : OZF_TP_ACCRUAL_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- END of Comments

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'OZF_TP_ACCRUAL_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(30) := 'ozfvtpab.pls';

G_PRICING_EVENT        CONSTANT VARCHAR2(30) := 'PRICING';

G_TP_ACCRUAL_UTIL_TYPE CONSTANT VARCHAR2(30) :='ADJUSTMENT';

OZF_DEBUG_HIGH_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);

G_PRC_DIFF_BUDGET            NUMBER := FND_PROFILE.value('OZF_THRDPTY_PRCDIFF_BUDGET');
G_TP_DEFAULT_PRICE_LIST      NUMBER := FND_PROFILE.value('OZF_TP_ACCRUAL_PRICE_LIST');
G_PRICING_SIM_EVENT          VARCHAR2(30) := FND_PROFILE.value('OZF_PRICING_SIMULATION_EVENT');
G_ACCRUAL_ON_SELLING         VARCHAR2(1)  := FND_PROFILE.value('OZF_ACC_ON_SELLING_PRICE');
G_BULK_LIMIT                 NUMBER := NVL(FND_PROFILE.value('OZF_BULK_LIMIT_SIZE') , 500);
G_ALLOW_INTER_COMMIT         VARCHAR2(1) := NVL(FND_PROFILE.value('OZF_ALLOW_INTER_COMMIT'), 'Y');
G_CONC_REQUEST_ID            NUMBER := FND_GLOBAL.CONC_REQUEST_ID;

---------------------------------------------------------------------
-- FUNCTION
--    is_valid_offer
--
-- PURPOSE
--    This procedure this offer should be accrued or not
--
-- PARAMETERS
--   p_list_header_id
--
-- NOTES
--------------------------------------------------------------------
PROCEDURE Is_Valid_Offer(
   p_list_header_id IN NUMBER,
   p_list_line_id   IN NUMBER,
   p_line_id        IN NUMBER,
   p_object_type    IN VARCHAR2,
   x_result          OUT NOCOPY BOOLEAN,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
l_result VARCHAR2(2) := NULL;

CURSOR omo_offer_csr IS
SELECT 1
FROM ozf_offers
WHERE qp_list_header_id = p_list_header_id;

CURSOR line_adjustment_csr IS
SELECT 1
FROM ozf_resale_adjustments
WHERE resale_line_id = p_line_id
AND list_header_id = p_list_header_id
AND list_line_id = p_list_line_id;

BEGIN
   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_object_type <> 'PL' THEN
      -- First it has to be an OMO offer
      OPEN omo_offer_csr;
      FETCH omo_offer_csr INTO l_result;
      CLOSE omo_offer_csr;

      IF l_result is not NULL AND
         l_result = '1' THEN

         x_result:= true;
      ELSE
         x_result:= false;
      END IF;
   ELSE
      x_result:= true;
   END IF;

   l_result := null;
   IF x_result THEN
      -- Second it has not been accrued before
      OPEN line_adjustment_csr;
      FETCH line_adjustment_csr INTO l_result;
      CLOSE line_adjustment_csr;
      IF l_result is not NULL THEN
         x_result:= false;
      END IF;
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ozf_utility_pvt.error_message('OZF_RESALE_IS_TM_OFFER');
END is_valid_offer;

---------------------------------------------------------------------
-- PROCEDURE
--   Validate_Batch
--
-- PURPOSE
--    This procedure validates the batch information
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Validate_Batch(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN    NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)IS
l_api_name          CONSTANT VARCHAR2(30) := 'Validate_Batch';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--

CURSOR batch_info_csr IS
SELECT status_code
,      org_id
from ozf_resale_batches
WHERE resale_batch_id = p_resale_batch_id;

l_status_code varchar2(30);
l_org_id      NUMBER;

BEGIN
   -- Standard begin of API savepoint
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
     l_api_version,
     p_api_version,
     l_api_name,
     G_PKG_NAME)
   THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Initialize message list if p_init_msg_list is TRUE.
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': Start');
   END IF;

   -- First, do some basic check

   OPEN batch_info_csr;
   FETCH batch_info_csr INTO l_status_code, l_org_id;
   CLOSE batch_info_csr;

   -- Check status
   IF l_status_code <> 'CLOSED' THEN

      x_return_status := FND_API.G_RET_STS_ERROR;
      ozf_utility_pvt.error_message('OZF_BATCH_STATUS_WNG');
      BEGIN
         INSERT INTO ozf_resale_logs_all(
            resale_log_id,
            resale_id,
            resale_id_type,
            error_code,
            error_message,
            column_name,
            column_value,
            org_id
         ) SELECT
               ozf_resale_logs_all_s.nextval,
               p_resale_batch_id,
               'BATCH',
               'OZF_BATCH_STATUS_WNG',
               FND_MESSAGE.get_string('OZF','OZF_BATCH_STATUS_WNG'),
               'STATUS_CODE',
               l_status_code,
               l_org_id
           FROM dual
           WHERE NOT EXISTS (
               SELECT 1
               FROM ozf_resale_logs a
               WHERE a.resale_id = p_resale_batch_id
               AND   a.resale_id_type = 'BATCH'
               AND   a.error_code = 'OZF_BATCH_STATUS_WNG'
           );
      EXCEPTION
         WHEN OTHERS THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_INS_RESALE_LOG_WRG');
               FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
               FND_MSG_PUB.add;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
      END;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': End');
   END IF;

   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
END Validate_Batch;

---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Order_Record
--
-- PURPOSE
--    This procedure validates the order information
--    These are validation specific to third party accrual process
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Validate_Order_Record(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN    NUMBER
   ,p_caller_type            IN    VARCHAR2
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)IS
l_api_name          CONSTANT VARCHAR2(30) := 'Validate_Order_Record';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--

BEGIN
   -- Standard BEGIN of API savepoint
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
      l_api_version,
      p_api_version,
      l_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Initialize message list if p_init_msg_list is TRUE.
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': Start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Make sure that selling_price is not NULL for direct customers
   IF p_caller_type = 'IFACE' THEN
      BEGIN
         INSERT INTO ozf_resale_logs_all(
            resale_log_id,
            resale_id,
            resale_id_type,
            error_code,
            error_message,
            column_name,
            column_value,
            org_id
         ) SELECT
               ozf_resale_logs_all_s.nextval,
               resale_line_int_id,
               'IFACE',
               'OZF_RESALE_SELL_PRICE_NULL',
               FND_MESSAGE.get_string('OZF','OZF_RESALE_SELL_PRICE_NULL'),
               'SELLING_PRICE',
               NULL,
               org_id
           FROM ozf_resale_lines_int_all b
           WHERE b.status_code = 'OPEN'
           AND b.direct_customer_flag = 'T'
           AND b.selling_price IS NULL
           AND b.resale_batch_id = p_resale_batch_id
           AND NOT EXISTS(
               SELECT 1
               FROM ozf_resale_logs_all a
               WHERE a.resale_id = b.resale_line_int_id
               AND a.resale_id_type = 'IFACE'
               AND a.error_code ='OZF_RESALE_SELL_PRICE_NULL'
           );
      EXCEPTION
         WHEN OTHERS THEN
            ozf_utility_pvt.error_message('OZF_INS_RESALE_LOG_WRG');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;

      BEGIN
         UPDATE ozf_resale_lines_int_all
         SET status_code = 'DISPUTED',
             dispute_code = 'OZF_RESALE_SELL_PRICE_NULL'
         WHERE status_code = 'OPEN'
         AND direct_customer_flag = 'T'
         AND selling_price IS NULL
         AND resale_batch_id = p_resale_batch_id;
      EXCEPTION
         WHEN OTHERS THEN
            ozf_utility_pvt.error_message('OZF_UPD_RESALE_INT_WRG');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;

   ELSE
      BEGIN
        INSERT INTO ozf_resale_logs_all(
           resale_log_id,
           resale_id,
           resale_id_type,
           error_code,
           error_message,
           column_name,
           column_value,
           org_id
       ) SELECT
            ozf_resale_logs_all_s.nextval,
            b.resale_line_id,
            'LINE',
            'OZF_RESALE_SELL_PRICE_NULL',
            FND_MESSAGE.get_string('OZF','OZF_RESALE_SELL_PRICE_NULL'),
            'SELLING_PRICE',
            NULL,
            b.org_id
         FROM ozf_resale_lines_all b
            , ozf_resale_batch_line_maps_all c
         WHERE b.direct_customer_flag = 'T'
         AND b.selling_price IS NULL
         AND b.resale_line_id = c.resale_line_id
         AND c.resale_batch_id = p_resale_batch_id
         AND NOT EXISTS(SELECT 1
            FROM ozf_resale_logs_all a
            WHERE a.resale_id = b.resale_line_id
            AND a.resale_id_type = 'LINE'
            AND a.error_code ='OZF_RESALE_SELL_PRICE_NULL'
         );
       EXCEPTION
        WHEN OTHERS THEN
            ozf_utility_pvt.error_message('OZF_INS_RESALE_LOG_WRG');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;
   END IF;

    -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': End');
   END IF;
   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
END Validate_Order_Record;

---------------------------------------------------------------------
-- PROCEDURE
--    process_one_line
--
-- PURPOSE
--    This procedure process the pricing call result for third party accrual.
--    It creates resale lines and accruals based on the discount information.
--
-- PARAMETERS
--    p_resale_line_int_rec IN OZF_RESALE_COMMON_PVT.g_interface_rec_csr%rowtype,
--    p_resale_line_rec     IN OZF_RESALE_LINES_ALL%rowtype,
--    p_line_result_rec     IN OZF_ORDER_PRICE_PVT.LINE_REC_TYPE,
--    p_header_id           IN NUMBER,
--    p_resale_batch_id     IN NUMBER,
--    p_inventory_tracking  IN BOOLEAN,
--    p_price_diff_fund_id  IN NUMBER,
--    p_object_type         IN VARCHAR2,
--    x_return_status       OUT NOCOPY VARCHAR2)
--
-- NOTES
--   1. Non-monetray accruals have not been considered. Should look INTO ldets.benefit_qty
--      and ldets.benefit_uom for calculation.
--
---------------------------------------------------------------------
PROCEDURE Process_One_Line(
    p_resale_line_int_rec    IN OZF_RESALE_COMMON_PVT.g_interface_rec_csr%rowtype,
    p_resale_line_rec        IN OZF_RESALE_LINES%rowtype,
    p_line_result_rec        IN OZF_ORDER_PRICE_PVT.LINE_REC_TYPE,
    p_header_id              IN NUMBER,
    p_resale_batch_id        IN NUMBER,
    p_inventory_tracking     IN BOOLEAN,
    p_price_diff_fund_id     IN NUMBER,
    p_caller_type            IN VARCHAR2,
    p_approver_id            IN NUMBER,
    x_return_status          OUT NOCOPY VARCHAR2
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Process_One_Line';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
---
l_msg_data                   VARCHAR2(2000);
l_msg_count                  NUMBER;
l_return_status              VARCHAR2(30);
--
-- NOTES: PPL has pricing_group_sequence as 0
CURSOR line_ldets_tbl_csr(p_index IN NUMBER) IS
   SELECT *
   FROM qp_ldets_v
   WHERE line_index = p_index
   ORDER BY pricing_group_sequence;

TYPE line_ldets_tbl_type IS TABLE OF line_ldets_tbl_csr%rowtype
INDEX BY binary_integer;

l_line_ldets_tbl             line_ldets_tbl_type;
l_line_id                    NUMBER := NULL;
l_ldets_tbl                  OZF_ORDER_PRICE_PVT.LDETS_TBL_TYPE;

--j NUMBER :=1;
m                            NUMBER := 1;

--l_pric_act_budgets_rec ozf_actbudgets_pvt.act_budgets_rec_type;
--l_pric_act_util_rec    ozf_actbudgets_pvt.act_util_rec_type;
--l_pric_price_adj_rec   ozf_resale_adjustments_all%rowtype;

l_act_budgets_rec            OZF_ACTBUDGETS_PVT.act_budgets_rec_type;
l_act_util_rec               OZF_ACTBUDGETS_PVT.act_util_rec_type;
l_adjustment_rec             OZF_RESALE_ADJUSTMENTS_ALL%rowtype;

l_is_valid_offer             BOOLEAN;
l_price_diff_util            BOOLEAN;
l_object_type                VARCHAR2(30);
l_line_int_rec               OZF_RESALE_LINES_INT%rowtype;

l_rate                       NUMBER;
l_exchange_type              VARCHAR2(30);
l_to_create_utilization      BOOLEAN;

/*
-- Only chargeback batch can share the agreement information.
CURSOR adjustment_info( p_line_id NUMBER,
                        p_batch_id NUMBER) IS
SELECT a.orig_system_agreement_uom,
       a.orig_system_agreement_name,
       a.orig_system_agreement_type,
       a.orig_system_agreement_status,
       a.orig_system_agreement_curr,
       a.orig_system_agreement_price,
       a.orig_system_agreement_quantity,
       a.agreement_id, a.agreement_type,
       a.agreement_name, a.agreement_price,
       a.agreement_uom_code,
       a.corrected_agreement_id,
       a.corrected_agreement_name,
       a.credit_code,
       a.credit_advice_date
FROM ozf_resale_adjustments a, ozf_resale_batches b
WHERE a.resale_line_id = p_line_id
AND a.resale_batch_id = p_batch_id
AND a.line_agreement_flag = 'T'
AND a.resale_batch_id = b.resale_batch_id
AND b.batch_type = OZF_RESALE_COMMON_PVT.G_CHARGEBACK
AND rownum = 1;
*/
l_log_id                     NUMBER;

l_sales_transaction_id       NUMBER;
l_sales_transaction_rec      OZF_SALES_TRANSACTIONS_PVT.sales_transaction_rec_type;
l_vol_offr_apply_discount    NUMBER;

CURSOR party_id_csr(p_cust_account_id IN NUMBER) IS
   SELECT party_id
   FROM hz_cust_accounts
   WHERE cust_account_id = p_cust_account_id;

CURSOR party_site_id_csr(p_account_site_id number) is
   SELECT party_site_id
   FROM hz_cust_acct_sites
   WHERE cust_acct_site_id = p_account_site_id;

l_new_request_amount         NUMBER;

-- julou 5723309: create util for VO PBH line only
CURSOR c_offer_type(p_qp_list_header_id NUMBER) IS
SELECT offer_type
FROM   ozf_offers
WHERE  qp_list_header_id = p_qp_list_header_id;
l_offer_type VARCHAR2(30);
-- end julou 5723309
BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': Start');
   END IF;

   SAVEPOINT  PROC_ONE_LINE;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Make sure that records are passed in due to different caller type
   IF p_caller_type = 'IFACE' AND
      p_resale_line_int_rec.resale_line_int_id IS NULL THEN
      ozf_utility_pvt.error_message('OZF_RESALE_INT_RECD_NULL');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF p_caller_type = 'RESALE' AND
      p_resale_line_rec.resale_line_id IS NULL THEN
      ozf_utility_pvt.error_message('OZF_RESALE_RECD_NULL');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- create a resale line record, if it's FROM iface
   IF p_caller_type = 'IFACE' THEN
      OZF_RESALE_COMMON_PVT.Insert_resale_line(
         p_api_version       => 1
        ,p_init_msg_list     => FND_API.G_FALSE
        ,p_commit            => FND_API.G_FALSE
        ,p_validation_level  => FND_API.G_VALID_LEVEL_FULL
        ,p_line_int_rec      => p_resale_line_int_rec
        ,p_header_id         => p_header_id
        ,x_line_id           => l_line_id
        ,x_return_status     => l_return_status
        ,x_msg_data          => l_msg_data
        ,x_msg_count         => l_msg_count
      );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         ozf_utility_pvt.error_message('OZF_INS_RESALE_LINE_WRG');
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      OZF_RESALE_COMMON_PVT.Insert_Resale_Line_Mapping(
          p_api_version            => 1
         ,p_init_msg_list          => FND_API.G_FALSE
         ,p_commit                 => FND_API.G_FALSE
         ,p_validation_level       => FND_API.G_VALID_LEVEL_FULL
         ,p_resale_batch_id        => p_resale_batch_id
         ,p_line_id                => l_line_id
         ,x_return_status          => l_return_status
         ,x_msg_data               => l_msg_data
         ,x_msg_count              => l_msg_count
      );
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      OZF_RESALE_COMMON_PVT.Create_Sales_Transaction(
        p_api_version           => 1
        ,p_init_msg_list        => FND_API.G_FALSE
        ,p_commit               => FND_API.G_FALSE
        ,p_validation_level     => FND_API.G_VALID_LEVEL_FULL
        ,p_line_int_rec         => p_resale_line_int_rec
        ,p_header_id            => p_header_id
        ,p_line_id              => l_line_id
        ,x_sales_transaction_id => l_sales_transaction_id
        ,x_return_status        => l_return_status
        ,x_msg_data             => l_msg_data
        ,x_msg_count            => l_msg_count
      );
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Bug 4380203 (+)
      -- Bug 4380203 Fixing: Inventory Temp table is already updated in Validate_Inventory_Level
      /*
      IF p_inventory_tracking THEN
         OZF_SALES_TRANSACTIONS_PVT.update_inventory_tmp (
            p_api_version      => 1.0
           ,p_init_msg_list    => FND_API.G_FALSE
           ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
           ,p_sales_transaction_id => l_sales_transaction_id
           ,x_return_status    => l_return_status
           ,x_msg_data         => l_msg_data
           ,x_msg_count        => l_msg_count
         );
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;
      */
      -- Bug 4380203 (-)
   ELSE
      -- For resale caller, just need to gat the id
      l_line_id := p_resale_line_rec.resale_line_id;
   END IF;

   -- I create adjustment, if a line was created before and adjustment is new
   -- or a new line is just created

   -- clear up the temparory result PL/SQL table
   IF l_ldets_tbl.EXISTS(1) THEN
      l_ldets_tbl.DELETE;
   END IF;

   m:=1;

   OPEN line_ldets_tbl_csr(p_line_result_rec.line_index);
   FETCH line_ldets_tbl_csr BULK COLLECT INTO l_ldets_tbl;
   --LOOP
   --   FETCH line_ldets_tbl_csr INTO l_ldets_tbl(m);
   --   EXIT when line_ldets_tbl_csr%NOTFOUND;
   --   m := m + 1;
   --END LOOP;
   CLOSE line_ldets_tbl_csr;

   l_price_diff_util := ( p_caller_type = 'IFACE' AND
                          p_line_result_rec.unit_price < p_resale_line_int_rec.selling_price
                        )
                        OR
                        ( p_caller_type = 'RESALE' AND
                          p_line_result_rec.unit_price < p_resale_line_rec.selling_price
                        );

   IF OZF_DEBUG_LOW_ON THEN
      IF l_price_diff_util THEN
         ozf_utility_PVT.debug_message(l_api_name||' >> do price adjustment');
      ELSE
         ozf_utility_pvt.debug_message(l_api_name||' >> no price adjustment');
      END IF;
   END IF;

   IF l_ldets_tbl.EXISTS(1) THEN
      FOR k IN 1..l_ldets_tbl.LAST LOOP

         l_adjustment_rec  := NULL;
         l_act_budgets_rec := NULL;
         l_act_util_rec    := NULL;

         -- Look in to list_line_type_code in view or CREATED_FROM_LIST_LINE_TYPE in tbl = 'DIS'
         -- IF applied_flag= 'Y' OR
         --    applied_flag= 'N' AND accrual_flag = 'Y' AND automatic_flag ='Y'THEN
         --    create a price adjustment record
         --    create a util_rec and act_budet_rec based on the discount
         -- END IF;
         -- INSERT INTO price adustment table
         -- call budget api
         -- Create an accrual for this accrual, pass in l_header_id as a refrence.
         -- IF CREATED_FROM_LIST_LINE_TYPE = 'PBH' Then
         --    do the same thing for each child line
         -- END IF;
         -- list_line_type_code 'PLL' is added.

         IF OZF_DEBUG_LOW_ON THEN
            ozf_utility_pvt.debug_message(l_api_name||' >> qp_ldets_v (+)');
            ozf_utility_pvt.debug_message('l_ldets_tbl('||k||').list_header_id      = '||l_ldets_tbl(k).list_header_id);
            ozf_utility_pvt.debug_message('l_ldets_tbl('||k||').list_line_type_code = '||l_ldets_tbl(k).list_line_type_code);
            ozf_utility_pvt.debug_message('l_ldets_tbl('||k||').applied_flag        = '||l_ldets_tbl(k).applied_flag);
            ozf_utility_pvt.debug_message('l_ldets_tbl('||k||').accrual_flag        = '||l_ldets_tbl(k).accrual_flag);
            ozf_utility_pvt.debug_message('l_ldets_tbl('||k||').automatic_flag      = '||l_ldets_tbl(k).automatic_flag);
            ozf_utility_pvt.debug_message(l_api_name||' >> qp_ldets_v (-)');
         END IF;

         IF l_ldets_tbl(k).list_line_type_code IN ('DIS','PBH', 'PLL') THEN
            -- create utilization based on an offer

            IF (l_ldets_tbl(k).applied_flag = 'Y' AND
                l_ldets_tbl(k).accrual_flag = 'N'
               )
               OR
               (l_ldets_tbl(k).accrual_flag = 'Y' AND
                l_ldets_tbl(k).automatic_flag = 'Y'
               )
               OR
               l_ldets_tbl(k).list_line_type_code = 'PLL' THEN

               IF l_ldets_tbl(k).list_line_type_code = 'PLL' THEN
                  l_object_type := 'PL';
               ELSE
                  l_object_type := 'OFFR';
               END IF;

               -- only accrual for TM offers
               Is_Valid_Offer(p_list_header_id => l_ldets_tbl(k).list_header_id,
                              p_list_line_id   => l_ldets_tbl(k).list_line_id,
                              p_line_id        => l_line_id,
                              p_object_type    => l_object_type,
                              x_result         => l_is_valid_offer,
                              x_return_status  => l_return_status
                             );
               IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
               ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;

               IF OZF_DEBUG_LOW_ON THEN
                  IF l_is_valid_offer OR l_ldets_tbl(k).list_line_type_code = 'PLL' THEN
                     ozf_utility_pvt.debug_message(l_api_name||' >> Accrual for TM OFFR or PLL adjustment (+)');
                     ozf_utility_pvt.debug_message('l_ldets_tbl('||k||').list_header_id    = '||l_ldets_tbl(k).list_header_id);
                     ozf_utility_pvt.debug_message('l_ldets_tbl('||k||').order_qty_adj_amt = '||l_ldets_tbl(k).order_qty_adj_amt);
                     ozf_utility_pvt.debug_message('l_ldets_tbl('||k||').line_quantity     = '||l_ldets_tbl(k).line_quantity);
                     ozf_utility_pvt.debug_message('order line priced_quantity        = '||p_line_result_rec.priced_quantity);
                     IF l_ldets_tbl(k).list_line_type_code = 'PLL' THEN
                     ozf_utility_pvt.debug_message('order line unit_price             = '||p_line_result_rec.unit_price);
                     END IF;
                     ozf_utility_pvt.debug_message(l_api_name||' >> Accrual for TM OFFR or PLL adjustment (-)');
                  END IF;
               END IF;

               IF l_is_valid_offer THEN
                  IF (l_ldets_tbl(k).list_line_type_code = 'PLL' AND
                      l_price_diff_util
                     )
                     OR
                     l_ldets_tbl(k).list_line_type_code IN ('DIS','PBH') THEN

--                     IF l_ldets_tbl(k).line_quantity IS NULL THEN
                        l_ldets_tbl(k).line_quantity := NVL(p_line_result_rec.priced_quantity, ABS(p_resale_line_int_rec.quantity));
--                     END IF;

                     -- BUG 4581928 (+)
                     IF p_caller_type = 'IFACE' THEN
                        l_ldets_tbl(k).line_quantity :=  l_ldets_tbl(k).line_quantity
                                                       * SIGN(p_resale_line_int_rec.quantity);
                     ELSE  --  p_caller_type = 'RESALE'
                        l_ldets_tbl(k).line_quantity :=  l_ldets_tbl(k).line_quantity
                                                       * SIGN(p_resale_line_rec.quantity);
                     END IF;
                     -- BUG 4581928 (-)

                     -- R12 Volumn Offer Enhancement (+)
                     IF l_object_type = 'OFFR' THEN
                        OZF_VOLUME_CALCULATION_PUB.Update_Tracking_Line(
                           p_init_msg_list     => FND_API.g_false
                          ,p_api_version       => 1.0
                          ,p_commit            => FND_API.g_false
                          ,x_return_status     => l_return_status
                          ,x_msg_count         => l_msg_count
                          ,x_msg_data          => l_msg_data
                          ,p_list_header_id    => l_ldets_tbl(k).list_header_id
                          ,p_interface_line_id => p_resale_line_int_rec.resale_line_int_id
                          ,p_resale_line_id    => l_line_id
                        );
                        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                           RAISE FND_API.G_EXC_ERROR;
                        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                     END IF;
                     -- R12 Volumn Offer Enhancement (-)

                     OPEN OZF_RESALE_COMMON_PVT.g_adjustment_id_csr;
                     FETCH OZF_RESALE_COMMON_PVT.g_adjustment_id_csr INTO l_adjustment_rec.resale_adjustment_id;
                     CLOSE OZF_RESALE_COMMON_PVT.g_adjustment_id_csr;

                     l_adjustment_rec.resale_batch_id          := p_resale_batch_id;
                     l_adjustment_rec.resale_line_id           := l_line_id;
                     l_adjustment_rec.list_header_id           := l_ldets_tbl(k).list_header_id;
                     l_adjustment_rec.list_line_id             := l_ldets_tbl(k).list_line_id;
                     IF l_ldets_tbl(k).list_line_type_code = 'PLL' THEN
                        IF p_caller_type = 'IFACE' THEN
                           l_adjustment_rec.accepted_amount    :=
                              -1 * (p_resale_line_int_rec.selling_price - p_line_result_rec.unit_price);
                        ELSE
                           l_adjustment_rec.accepted_amount    :=
                              -1 * (p_resale_line_rec.selling_price - p_line_result_rec.unit_price);
                        END IF;
                     ELSE
                        IF l_ldets_tbl(k).applied_flag = 'Y' THEN
                           l_adjustment_rec.accepted_amount       := l_ldets_tbl(k).order_qty_adj_amt;
                        END IF;
                     END IF;
                     -- BUG 4558568 (+)
                     --l_adjustment_rec.total_accepted_amount    :=
                           --l_adjustment_rec.accepted_amount * ABS(l_ldets_tbl(k).line_quantity); --abs(p_line_result_rec.priced_quantity);
                     --l_adjustment_rec.priced_quantity          := ABS(l_ldets_tbl(k).line_quantity); --abs(p_line_result_rec.priced_quantity);
                     l_adjustment_rec.total_accepted_amount    :=
                           l_adjustment_rec.accepted_amount * l_ldets_tbl(k).line_quantity;
                     l_adjustment_rec.priced_quantity          := l_ldets_tbl(k).line_quantity;
                     -- BUG 4558568 (-)
                     l_adjustment_rec.priced_uom_code          := p_line_result_rec.priced_uom_code;
                     l_adjustment_rec.operand                  := l_ldets_tbl(k).operand_value;
                     l_adjustment_rec.operand_calculation_code := l_ldets_tbl(k).operand_calculation_code;
                     l_adjustment_rec.priced_unit_price        := p_line_result_rec.unit_price;
                     l_adjustment_rec.calculated_price         := p_line_result_rec.unit_price;
                     l_adjustment_rec.STATUS_CODE              := 'CLOSED';
                     l_adjustment_rec.claimed_amount           := 0;
                     l_adjustment_rec.total_claimed_amount     := 0;
                     l_adjustment_rec.allowed_amount           := 0;
                     l_adjustment_rec.total_allowed_amount     := 0;
                     l_adjustment_rec.tolerance_flag           := 'F';
                     l_adjustment_rec.line_tolerance_amount    := 0;

                     IF l_ldets_tbl(k).list_line_type_code = 'PLL' AND
                        p_caller_type = 'IFACE' THEN
                        l_adjustment_rec.orig_system_agreement_uom      := p_resale_line_int_rec.orig_system_agreement_uom;
                        l_adjustment_rec.orig_system_agreement_name     := p_resale_line_int_rec.orig_system_agreement_name;
                        l_adjustment_rec.orig_system_agreement_type     := p_resale_line_int_rec.orig_system_agreement_type;
                        l_adjustment_rec.orig_system_agreement_status   := p_resale_line_int_rec.orig_system_agreement_status;
                        l_adjustment_rec.orig_system_agreement_curr     := p_resale_line_int_rec.orig_system_agreement_curr;
                        l_adjustment_rec.orig_system_agreement_price    := p_resale_line_int_rec.orig_system_agreement_price;
                        l_adjustment_rec.orig_system_agreement_quantity := p_resale_line_int_rec.orig_system_agreement_quantity;
                        l_adjustment_rec.agreement_id                   := p_resale_line_int_rec.agreement_id;
                        l_adjustment_rec.agreement_type                 := p_resale_line_int_rec.agreement_type;
                        l_adjustment_rec.agreement_name                 := p_resale_line_int_rec.agreement_name;
                        l_adjustment_rec.agreement_price                := p_resale_line_int_rec.agreement_price;
                        l_adjustment_rec.AGREEMENT_uom_code             := p_resale_line_int_rec.agreement_uom_code;
                        l_adjustment_rec.corrected_agreement_id         := p_resale_line_int_rec.corrected_agreement_id;
                        l_adjustment_rec.corrected_agreement_name       := p_resale_line_int_rec.corrected_agreement_name;
                        l_adjustment_rec.credit_code                    := p_resale_line_int_rec.credit_code;
                        l_adjustment_rec.credit_advice_date             := p_resale_line_int_rec.credit_advice_date;
                        l_adjustment_rec.line_agreement_flag            := 'T';
                     ELSE
                        l_adjustment_rec.orig_system_agreement_uom      := NULL;
                        l_adjustment_rec.orig_system_agreement_name     := NULL;
                        l_adjustment_rec.orig_system_agreement_type     := NULL;
                        l_adjustment_rec.orig_system_agreement_status   := NULL;
                        l_adjustment_rec.orig_system_agreement_curr     := NULL;
                        l_adjustment_rec.orig_system_agreement_price    := NULL;
                        l_adjustment_rec.orig_system_agreement_quantity := NULL;
                        l_adjustment_rec.agreement_id                   := NULL;
                        l_adjustment_rec.agreement_type                 := NULL;
                        l_adjustment_rec.agreement_name                 := NULL;
                        l_adjustment_rec.agreement_price                := NULL;
                        l_adjustment_rec.agreement_uom_code             := NULL;
                        l_adjustment_rec.corrected_agreement_id         := NULL;
                        l_adjustment_rec.corrected_agreement_name       := NULL;
                        l_adjustment_rec.credit_code                    := NULL;
                        l_adjustment_rec.credit_advice_date             := NULL;
                        l_adjustment_rec.line_agreement_flag            := 'F';
                     END IF;

                     -- R12 MOAC (+)
                     IF p_caller_type = 'IFACE' THEN
                        l_adjustment_rec.org_id := p_resale_line_int_rec.org_id;
                     ELSE
                        l_adjustment_rec.org_id := p_resale_line_rec.org_id;
                     END IF;
                     -- R12 MOAC (-)

                     -- Create act Utilization Record.
                     l_act_util_rec.object_type        := 'TP_ORDER';
                     l_act_util_rec.object_id          :=  l_line_id;
                     l_act_util_rec.product_level_type :='PRODUCT';

                     l_act_util_rec.bill_to_site_use_id := p_resale_line_rec.bill_to_site_use_id;
                     l_act_util_rec.ship_to_site_use_id := p_resale_line_rec.ship_to_site_use_id;
                     ozf_utility_pvt.write_conc_log('JL: bill_to_site_use_id = ' || p_resale_line_rec.bill_to_site_use_id);
                     ozf_utility_pvt.write_conc_log('JL: ship_to_site_use_id = ' || p_resale_line_rec.ship_to_site_use_id);
                     IF p_caller_type = 'IFACE' THEN
                        l_act_util_rec.product_id      := p_resale_line_int_rec.inventory_item_Id;
                        -- Here, there is a need to look INTO trading group issue
                        -- Handled by budget
                        l_act_util_rec.billto_cust_account_id := p_resale_line_int_rec.bill_to_cust_account_id ;
                        l_act_util_rec.gl_date                := p_resale_line_int_rec.date_shipped;
                        -- R12 MOAC (+)
                        l_act_util_rec.org_id                 := p_resale_line_int_rec.org_id;
                        -- R12 MOAC (-)
                     ELSE
                        l_act_util_rec.product_id      := p_resale_line_rec.inventory_item_Id;
                        -- Here, there is a need to look INTO trading group issue
                        -- Handled by budget
                        l_act_util_rec.billto_cust_account_id := p_resale_line_rec.bill_to_cust_account_id;
                        l_act_util_rec.gl_date                := p_resale_line_rec.date_shipped;
                        -- R12 MOAC (+)
                        l_act_util_rec.org_id                 := p_resale_line_rec.org_id;
                        -- R12 MOAC (-)
                     END IF;

                     -- Reference for batch
                     l_act_util_rec.reference_type      := 'BATCH';
                     l_act_util_rec.reference_id        := p_resale_batch_id;
                     l_act_util_rec.price_adjustment_id := l_adjustment_rec.resale_adjustment_id;

                     IF l_ldets_tbl(k).list_line_type_code = 'PLL' THEN
                        l_act_util_rec.utilization_type :='ADJUSTMENT' ; -- Adjustmen for price difference
                        l_act_util_rec.adjustment_type_id := -10;
                     ELSE
                        l_act_util_rec.utilization_type :='UTILIZED' ; -- Always it is utilized.
                     END IF;

                     -- Create act Budget Record.
                     l_act_budgets_rec.act_budget_used_by_id  := l_ldets_tbl(k).list_header_id;
                     l_act_budgets_rec.budget_source_id       := l_ldets_tbl(k).list_header_id;
                     l_act_budgets_rec.status_code            := 'APPROVED';
                     l_act_budgets_rec.transfer_type          := 'UTILIZED';

                     IF l_ldets_tbl(k).list_line_type_code = 'PLL' THEN
                        l_act_budgets_rec.arc_act_budget_used_by := 'PRIC';
                        l_act_budgets_rec.budget_source_type     := 'PRIC';
                        l_act_budgets_rec.approver_id            := ozf_utility_pvt.get_resource_id(p_approver_id);
                        l_act_budgets_rec.requester_id           := ozf_utility_pvt.get_resource_id(p_approver_id);
                        l_act_budgets_rec.request_currency       := p_line_result_rec.currency_code;

                        -- Get fund info for price difference
                        -- get chargeback budget id FROM profile
                        IF p_price_diff_fund_id IS NULL THEN
                           ozf_utility_pvt.error_message('OZF_THRDPTY_BUDGET_ERR');
                           RAISE FND_API.g_exc_error;
                        ELSE
                           l_act_budgets_rec.parent_source_id := p_price_diff_fund_id;
                        END IF;

                        l_act_budgets_rec.parent_src_curr     := OZF_ACTBUDGETS_PVT.get_object_currency (
                                                                      'FUND'
                                                                     ,l_act_budgets_rec.parent_source_id
                                                                     ,l_return_status
                                                                 );
                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                        l_act_budgets_rec.justification       := 'THIRD PARTY PRICE DIFF';
                     ELSE
                        l_act_budgets_rec.arc_act_budget_used_by := 'OFFR';
                        l_act_budgets_rec.budget_source_type     := 'OFFR';

                        --nirprasa,12.2 ER 8399134
                        /*l_act_budgets_rec.request_currency       := OZF_ACTBUDGETS_PVT.get_object_currency (
                                                                      'OFFR'
                                                                     ,l_ldets_tbl(k).list_header_id
                                                                     ,l_return_status
                                                                    );*/
                        l_act_budgets_rec.request_currency       := p_line_result_rec.currency_code;
                        --nirprasa,12.2
                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                     END IF;

                     -- get adjusted amount in budget currency
                     -- Problem in 115.9 is fixed. no need here.
                     l_act_budgets_rec.request_amount := l_adjustment_rec.total_accepted_amount;
                     --nirprasa 12.2 ER 8399134
                     l_act_util_rec.plan_currency_code := l_act_budgets_rec.request_currency;
                     l_act_util_rec.fund_request_currency_code := OZF_ACTBUDGETS_PVT.get_object_currency (
                                                                      'OFFR'
                                                                     ,l_ldets_tbl(k).list_header_id
                                                                     ,l_return_status
                                                                    );

                     --nirprasa,12.2 remove currency conversion b/w order and offer currency
                     /*IF p_line_result_rec.currency_code <> l_act_budgets_rec.request_currency THEN
                        -- get convert type
                        OPEN OZF_RESALE_COMMON_PVT.g_exchange_rate_type_csr;
                        FETCH OZF_RESALE_COMMON_PVT.g_exchange_rate_type_csr INTO l_exchange_type;
                        CLOSE OZF_RESALE_COMMON_PVT.g_exchange_rate_type_csr;

                        OZF_UTILITY_PVT.convert_currency(
                               p_from_currency   => p_line_result_rec.currency_code
                              ,p_to_currency     => l_act_budgets_rec.request_currency
                              ,p_conv_type       => l_exchange_type
                              ,p_conv_rate       => FND_API.G_MISS_NUM
                              ,p_conv_date       => sysdate
                              ,p_from_amount     => l_act_budgets_rec.request_amount
                              ,x_return_status   => l_return_status
                              ,x_to_amount       => l_new_request_amount
                              ,x_rate            => l_rate
                        );
                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                        l_act_budgets_rec.request_amount := l_new_request_amount;
                     END IF;*/
                     --nirprasa,12.2
                     IF OZF_DEBUG_LOW_ON THEN
                        ozf_utility_PVT.debug_message('act budget: '||l_act_budgets_rec.request_amount);
                     END IF;

                     -- Utilization always have different sign than the price adjustment
                     l_adjustment_rec.calculated_amount := l_act_budgets_rec.request_amount;
                     l_act_budgets_rec.request_amount   := l_act_budgets_rec.request_amount * -1;

                     IF l_ldets_tbl(k).list_line_type_code = 'PLL' THEN
                        l_act_budgets_rec.parent_src_apprvd_amt := l_act_budgets_rec.request_amount;
                        IF p_line_result_rec.currency_code <> l_act_budgets_rec.parent_src_curr THEN
                           -- get convert type
                           OPEN OZF_RESALE_COMMON_PVT.g_exchange_rate_type_csr;
                           FETCH OZF_RESALE_COMMON_PVT.g_exchange_rate_type_csr INTO l_exchange_type;
                           CLOSE OZF_RESALE_COMMON_PVT.g_exchange_rate_type_csr;

                           OZF_UTILITY_PVT.convert_currency(
                              p_FROM_currency   => p_line_result_rec.currency_code
                              ,p_to_currency     => l_act_budgets_rec.parent_src_curr
                              ,p_conv_type       => l_exchange_type
                              ,p_conv_rate       => FND_API.G_MISS_NUM
                              ,p_conv_date       => sysdate
                              ,p_FROM_amount     => l_act_budgets_rec.parent_src_apprvd_amt
                              ,x_return_status   => l_return_status
                              ,x_to_amount       => l_new_request_amount
                              ,x_rate            => l_rate
                           );
                           IF l_return_status = FND_API.g_ret_sts_error THEN
                              RAISE FND_API.g_exc_error;
                           ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                              RAISE FND_API.g_exc_error;
                           END IF;
                           l_act_budgets_rec.parent_src_apprvd_amt := l_new_request_amount;
                        END IF;
                     END IF;

                     -- julou 5723309: create util for VO PBH line only
                     OPEN  c_offer_type(l_ldets_tbl(k).list_header_id);
                     FETCH c_offer_type INTO l_offer_type;
                     CLOSE c_offer_type;

                     IF OZF_DEBUG_LOW_ON THEN
                       ozf_utility_pvt.debug_message(' JL offer_type: ' || l_offer_type);
                       ozf_utility_pvt.debug_message(' JL list_line_type_code: ' || l_ldets_tbl(k).list_line_type_code);
                       ozf_utility_pvt.debug_message(' JL calculated_amount: ' || l_adjustment_rec.calculated_amount);
                     END IF;

                     l_to_create_utilization := (l_ldets_tbl(k).list_line_type_code = 'PLL' AND
                                                 l_adjustment_rec.calculated_amount IS NOT NULL)
                                                OR
                                                (l_ldets_tbl(k).list_line_type_code = 'DIS' AND
                                                 l_offer_type <> 'VOLUME_OFFER' AND
                                                 l_adjustment_rec.calculated_amount IS NOT NULL)
                                                OR
                                                (l_ldets_tbl(k).list_line_type_code = 'PBH' AND
                                                --l_offer_type = 'VOLUME_OFFER' AND --multi-tier offer also stores effective accrual on PBH line
                                                 l_adjustment_rec.calculated_amount IS NOT NULL);
                     -- end julou 5723309
/*
                     l_to_create_utilization := (l_ldets_tbl(k).list_line_type_code = 'PLL' AND
                                                 l_adjustment_rec.calculated_amount IS NOT NULL)
                                                OR
                                                (l_ldets_tbl(k).list_line_type_code = 'DIS' AND
                                                 l_adjustment_rec.calculated_amount IS NOT NULL);
*/
                     OZF_RESALE_COMMON_PVT.Create_Adj_and_Utilization(
                            p_api_version     => 1
                           ,p_init_msg_list   => FND_API.G_FALSE
                           ,p_commit          => FND_API.G_FALSE
                           ,p_validation_level=> FND_API.G_VALID_LEVEL_FULL
                           ,p_price_adj_rec   => l_adjustment_rec
                           ,p_act_budgets_rec => l_act_budgets_rec
                           ,p_act_util_rec    => l_act_util_rec
                           ,p_to_create_utilization  => l_to_create_utilization
                           ,x_return_status   => l_return_status
                           ,x_msg_data        => l_msg_data
                           ,x_msg_count       => l_msg_count
                     );
                     --IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                     --   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                     --END IF;

                     IF l_return_status = fnd_api.g_ret_sts_error THEN
                        RAISE fnd_api.g_exc_error;
                     ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                        RAISE fnd_api.g_exc_unexpected_error;
                     END IF;

                     IF l_to_create_utilization AND
                        l_act_budgets_rec.arc_act_budget_used_by = 'OFFR' THEN

                        IF p_caller_type = 'IFACE' THEN
                           l_sales_transaction_rec.sold_from_cust_account_id := p_resale_line_int_rec.sold_from_cust_account_id;
                           l_sales_transaction_rec.sold_to_cust_account_id := p_resale_line_int_rec.bill_to_cust_account_id;
                           l_sales_transaction_rec.sold_to_party_id        := p_resale_line_int_rec.bill_to_party_id;
                           l_sales_transaction_rec.sold_to_party_site_id   := p_resale_line_int_rec.bill_to_party_site_id;
                           l_sales_transaction_rec.bill_to_site_use_id  := p_resale_line_int_rec.bill_to_site_use_id;
                           l_sales_transaction_rec.ship_to_site_use_id  := p_resale_line_int_rec.ship_to_site_use_id;
                           l_sales_transaction_rec.transaction_date := p_resale_line_int_rec.date_ordered;
                           IF p_resale_line_int_rec.product_transfer_movement_type = 'TI' THEN
                              l_sales_transaction_rec.transfer_type    := 'IN';
                           ELSIF p_resale_line_int_rec.product_transfer_movement_type = 'TO' THEN
                              l_sales_transaction_rec.transfer_type    := 'OUT';
                           ELSIF p_resale_line_int_rec.product_transfer_movement_type = 'DC' THEN
                              l_sales_transaction_rec.transfer_type    := 'OUT';
                           ELSIF p_resale_line_int_rec.product_transfer_movement_type = 'CD' THEN
                              l_sales_transaction_rec.transfer_type    := 'IN';
                           END IF;
                           l_sales_transaction_rec.quantity     := p_resale_line_int_rec.quantity;
                           l_sales_transaction_rec.uom_code             := p_resale_line_int_rec.uom_code;
                          -- l_sales_transaction_rec.amount          := ABS(p_resale_line_int_rec.selling_price * p_resale_line_int_rec.quantity);
                           l_sales_transaction_rec.amount          := ABS(p_line_result_rec.unit_price * p_resale_line_int_rec.quantity);
                           l_sales_transaction_rec.currency_code   := p_resale_line_int_rec.currency_code;
                           l_sales_transaction_rec.inventory_item_id := p_resale_line_int_rec.inventory_item_id;
                           l_sales_transaction_rec.header_id    := p_header_id;
                           l_sales_transaction_rec.line_id      := l_line_id;
                           l_sales_transaction_rec.source_code  := 'IS';
                        ELSIF p_caller_type = 'RESALE' THEN
                           l_sales_transaction_rec.sold_from_cust_account_id := p_resale_line_rec.sold_from_cust_account_id;
                           l_sales_transaction_rec.sold_to_cust_account_id := p_resale_line_rec.bill_to_cust_account_id;
                           l_sales_transaction_rec.sold_to_party_id        := p_resale_line_rec.bill_to_party_id;
                           l_sales_transaction_rec.sold_to_party_site_id   := p_resale_line_rec.bill_to_party_site_id;
                           l_sales_transaction_rec.bill_to_site_use_id  := p_resale_line_rec.bill_to_site_use_id;
                           l_sales_transaction_rec.ship_to_site_use_id  := p_resale_line_rec.ship_to_site_use_id;
                           l_sales_transaction_rec.transaction_date := p_resale_line_rec.date_ordered;
                           IF p_resale_line_rec.product_transfer_movement_type = 'TI' THEN
                              l_sales_transaction_rec.transfer_type    := 'IN';
                           ELSIF p_resale_line_rec.product_transfer_movement_type = 'TO' THEN
                              l_sales_transaction_rec.transfer_type    := 'OUT';
                           ELSIF p_resale_line_rec.product_transfer_movement_type = 'DC' THEN
                              l_sales_transaction_rec.transfer_type    := 'OUT';
                           ELSIF p_resale_line_rec.product_transfer_movement_type = 'CD' THEN
                              l_sales_transaction_rec.transfer_type    := 'IN';
                           END IF;
                           l_sales_transaction_rec.quantity     := p_resale_line_rec.quantity;
                           l_sales_transaction_rec.uom_code             := p_resale_line_rec.uom_code;
                           --l_sales_transaction_rec.amount          := ABS(p_resale_line_rec.selling_price * p_resale_line_rec.quantity);
                           -- changed by feliu on 12/13/06 since selling_price could be null.
                           l_sales_transaction_rec.amount          := ABS(p_line_result_rec.unit_price * p_resale_line_rec.quantity);
                           l_sales_transaction_rec.currency_code   := p_resale_line_rec.currency_code;
                           l_sales_transaction_rec.inventory_item_id := p_resale_line_rec.inventory_item_id;
                           l_sales_transaction_rec.header_id    := p_header_id;
                           l_sales_transaction_rec.line_id      := l_line_id;
                           l_sales_transaction_rec.source_code  := 'IS';
                        END IF;

                        OZF_VOLUME_CALCULATION_PUB.Create_Volume(
                           p_init_msg_list     => FND_API.g_false
                          ,p_api_version       => 1.0
                          ,p_commit            => FND_API.g_false
                          ,x_return_status     => l_return_status
                          ,x_msg_count         => l_msg_count
                          ,x_msg_data          => l_msg_data
                          ,p_volume_detail_rec => l_sales_transaction_rec
                          ,p_qp_list_header_id => l_ldets_tbl(k).list_header_id
                          ,x_apply_discount    => l_vol_offr_apply_discount
                        );
                        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                           RAISE FND_API.G_EXC_ERROR;
                        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;


                     END IF;
                  END IF; -- END line_type_code is the 'PLL' and price differ or in ('PHB','DIS')
               END IF;  -- END is valid offer
            END IF;  -- END accrual flag
         END IF;  -- END list type
      END LOOP; -- END LOOP through ldets_lines
   END IF; -- END if ldets_line has nothing

   x_return_status := l_return_status;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': start');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO PROC_ONE_LINE;
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO PROC_ONE_LINE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      ROLLBACK TO PROC_ONE_LINE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END process_one_line;

---------------------------------------------------------------------
-- PROCEDURE
--    process_pricing_result
--
-- PURPOSE
--    This procedure process the pricing call result. It creates accruals based
--    on the discount information.
--
-- PARAMETERS
--         p_resale_batch_id   IN NUMBER,
--         p_line_tbl          IN OZF_ORDER_PRICE_PVT.LINE_REC_TBL_TYPE,
--         p_caller_type       IN VARCHAR2,
--         x_return_status     OUT NOCOPY VARCHAR2
--
-- NOTES
--   1. Non-monetray accruals have not been considered. Should look INTO ldets.benefit_qty
--      and ldets.benefit_uom for calculation.
--   2. We will not do third party accruals on tracing data
--
---------------------------------------------------------------------
PROCEDURE Process_Pricing_Result(
   p_resale_batch_id         IN NUMBER,
   p_line_tbl                IN OZF_ORDER_PRICE_PVT.LINE_REC_TBL_TYPE,
   p_caller_type             IN VARCHAR2,
   x_return_status           OUT NOCOPY VARCHAR2
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Process_Pricing_Result';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
---
l_msg_data                   VARCHAR2(2000);
l_msg_count                  NUMBER;
l_return_status              VARCHAR2(30);
--
CURSOR order_identifiers_csr (p_id IN NUMBER) IS
   SELECT order_number
        , bill_to_cust_account_id
        , date_ordered
   FROM ozf_resale_lines_int_all
   WHERE resale_line_int_id = p_id;

CURSOR resale_info_csr (p_id IN NUMBER) IS
   SELECT resale_header_id
   FROM ozf_resale_lines
   WHERE resale_line_id = p_id;

l_order_number               VARCHAR2(30);
l_cust_account_id            NUMBER;
l_date_ordered               DATE;

l_has_error                  BOOLEAN := FALSE;
l_log_id                     NUMBER;

CURSOR resale_rec_csr (p_id IN NUMBER) IS
  SELECT *
  FROM ozf_resale_lines
  WHERE resale_line_id = p_id;

l_resale_int_rec             OZF_RESALE_COMMON_PVT.g_interface_rec_csr%rowtype;
l_resale_rec                 OZF_RESALE_LINES%rowtype;

l_header_id                  NUMBER;
l_line_id                    NUMBER;

CURSOR exchange_rate_type_csr IS
   SELECT exchange_rate_type
   FROM   ozf_sys_parameters;

l_default_exchange_type      VARCHAR2(30);
l_exchange_type              VARCHAR2(30);
l_exchange_date              DATE;
l_acctd_adj_unit_price       NUMBER;
l_acctd_selling_price        NUMBER;
l_rate                       NUMBER;

CURSOR func_currency_cd_csr IS
   SELECT gs.currency_code
   FROM   gl_sets_of_books gs,
          ozf_sys_parameters osp
   WHERE  gs.set_of_books_id = osp.set_of_books_id
   AND    osp.org_id = MO_GLOBAL.GET_CURRENT_ORG_ID(); -- BUG 5058027

l_func_currency_code         VARCHAR2(15);


CURSOR dup_line_csr( p_id           IN NUMBER
                   , p_order_number IN VARCHAR2
                   , p_cust_id      IN NUMBER
                   , p_date         IN DATE
                   ) IS
   SELECT 1
   FROM ozf_resale_lines_int_all
   WHERE resale_batch_id = p_id
   AND order_number = p_order_number
   AND bill_to_cust_account_id = p_cust_id
   AND date_ordered = p_date
   AND status_code = 'DUPLICATED';


l_create_order_header        BOOLEAN;
l_dup_line_count             NUMBER;
l_inventory_tracking         VARCHAR2(30);

CURSOR dup_header_csr( p_id           IN NUMBER
                     , p_order_number IN VARCHAR2
                     , p_cust_id      IN NUMBER
                     , p_date         IN DATE
                     ) IS
   SELECT a.resale_header_id
   FROM ozf_resale_headers_all a
      , ozf_resale_lines_int_all b
      , ozf_resale_lines_all c
   WHERE b.resale_batch_id = p_id
   AND b.order_number = p_order_number
   AND b.bill_to_cust_account_id = p_cust_id
   AND b.date_ordered = p_date
   AND b.status_code = 'DUPLICATED'
   AND b.duplicated_line_id = c.resale_line_id
   AND c.resale_header_id = a.resale_header_id;

l_fund_id                    NUMBER:= G_PRC_DIFF_BUDGET; --fnd_profile.value('OZF_THRDPTY_PRCDIFF_BUDGET');
l_id_type                    VARCHAR2(30);

CURSOR batch_info_csr (p_id IN NUMBER) IS
   SELECT partner_cust_account_id,
          partner_party_id,
          report_start_date,
          report_end_date,
          last_updated_by
   FROM ozf_resale_batches_all
   WHERE resale_batch_id = p_id;

l_partner_cust_account_id    NUMBER;
l_partner_party_id           NUMBER;
l_report_start_date          DATE;
l_report_end_date            DATE;
l_last_updated_by            NUMBER(15);
-- Bug 4380203 (+)
l_inventory_level_valid      BOOLEAN;
-- Bug 4380203 (-)
  -- bug 6317120
  l_org_id                   NUMBER;
  -- end bug 6317120
BEGIN
   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': start');
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   SAVEPOINT  PROC_PRIC_RESULT;

   OPEN batch_info_csr(p_resale_batch_id);
   FETCH batch_info_csr into l_partner_cust_account_id,
                             l_partner_party_id,
                             l_report_start_date,
                             l_report_end_date,
                             l_last_updated_by;
   CLOSE batch_info_csr;

   IF l_fund_id is null THEN
      ozf_utility_pvt.error_message('OZF_THRDPTY_BUDGET_ERR');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Please setup Profile OZF : Price Difference Budget before running Third Party Accrual.');
      RAISE FND_API.g_exc_error;
   END IF;

   -- First check whether the order result collection EXISTS or not
   IF p_line_tbl.EXISTS(1) THEN
     -- get order identification
      IF p_caller_type = 'IFACE' THEN
         OPEN order_identifiers_csr(p_line_tbl(1).chargeback_int_id);
         FETCH order_identifiers_csr INTO l_order_number,
                                          l_cust_account_id,
                                          l_date_ordered;
         CLOSE order_identifiers_csr;
      ELSE
         OPEN resale_info_csr(p_line_tbl(1).chargeback_int_id);
         FETCH resale_info_csr INTO l_header_id;
         CLOSE resale_info_csr;
      END IF;

      -- LOOP through the result to find if there is an error in the result.
      FOR i in 1..p_line_tbl.LAST LOOP
         l_has_error := p_line_tbl(i).pricing_status_code <> QP_PREQ_PUB.G_STATUS_NEW AND
                        p_line_tbl(i).pricing_status_code <> QP_PREQ_PUB.G_STATUS_UNCHANGED AND
                        p_line_tbl(i).pricing_status_code <> QP_PREQ_PUB.G_STATUS_UPDATED;

         EXIT WHEN l_has_error;
      END LOOP;

      IF l_has_error THEN
        -- IF there is an error for a line or lines, we need to UPDATE the whole order as error;
        -- nothing to UPDATE if it's FROM line.
         IF p_caller_type = 'IFACE' THEN
            BEGIN
               UPDATE ozf_resale_lines_int_all
               SET status_code = 'DISPUTED'
               WHERE status_code = 'OPEN'
               AND order_NUMBER = l_order_number
               AND bill_to_cust_account_id = l_cust_account_id
               AND date_ordered = l_date_ordered
               AND resale_batch_id = p_resale_batch_id;
            EXCEPTION
               WHEN OTHERS THEN
                  ozf_utility_pvt.error_message('OZF_UPD_RESALE_INT_WRG');
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END;
            l_id_type := 'IFACE';
         ELSE
            l_id_type := 'LINE';
         END IF;

         FOR i in 1..p_line_tbl.LAST LOOP
            BEGIN
               OPEN OZF_RESALE_COMMON_PVT.g_log_id_csr;
               FETCH OZF_RESALE_COMMON_PVT.g_log_id_csr INTO l_log_id;
               CLOSE OZF_RESALE_COMMON_PVT.g_log_id_csr;

               -- julou bug 6317120. get org_id from table
               IF l_id_type = 'LINE' THEN
                 OPEN  OZF_RESALE_COMMON_PVT.gc_line_org_id(p_line_tbl(i).chargeback_int_id);
                 FETCH OZF_RESALE_COMMON_PVT.gc_line_org_id INTO l_org_id;
                 CLOSE OZF_RESALE_COMMON_PVT.gc_line_org_id;
               ELSIF l_id_type = 'IFACE' THEN
                 OPEN  OZF_RESALE_COMMON_PVT.gc_iface_org_id(p_line_tbl(i).chargeback_int_id);
                 FETCH OZF_RESALE_COMMON_PVT.gc_iface_org_id INTO l_org_id;
                 CLOSE OZF_RESALE_COMMON_PVT.gc_iface_org_id;
               END IF;

               OZF_RESALE_LOGS_PKG.Insert_Row(
                    px_resale_log_id           => l_log_id,
                    p_resale_id                => p_line_tbl(i).chargeback_int_id,
                    p_resale_id_type           => l_id_type,
                    p_error_code               => p_line_tbl(i).pricing_status_code,
                    p_error_message            => p_line_tbl(i).pricing_status_text,                    p_column_name              => NULL,
                    p_column_value             => NULL,
                    --px_org_id                  => OZF_RESALE_COMMON_PVT.g_org_id
                    px_org_id                  => l_org_id
               );
            EXCEPTION
               WHEN OTHERS THEN
                  ozf_utility_pvt.error_message('OZF_INS_RESALE_LOG_WRG');
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END;
         END LOOP;
      ELSE
         -- There is no error in the resulting. We need to process the result one by one.
         -- Since there is no time overlap between data process and payment initiatioin, I will
         -- not check duplicates again

         IF p_caller_type = 'IFACE' THEN
            --We need to check create an order header first.
            OPEN dup_line_csr( p_resale_batch_id
                             , l_order_number
                             , l_cust_account_id
                             , l_date_ordered
                             );
            FETCH dup_line_csr INTO l_dup_line_count;
            CLOSE dup_line_csr;

            -- Here, I assume if a line is the duplicate of another line, then they share
            -- the same order header. Hence all order with this duplicated line share the
            -- the same order with the oringinal lines.

            l_create_order_header := l_dup_line_count IS NULL;

            -- Check whether there is a need to do inventory_verification
            OPEN OZF_RESALE_COMMON_PVT.g_inventory_tracking_csr;
            FETCH OZF_RESALE_COMMON_PVT.g_inventory_tracking_csr INTO l_inventory_tracking;
            CLOSE OZF_RESALE_COMMON_PVT.g_inventory_tracking_csr;

            IF l_inventory_tracking = 'T' THEN
               OZF_SALES_TRANSACTIONS_PVT.Initiate_Inventory_tmp (
                 p_api_version            => 1.0
                ,p_init_msg_list          => FND_API.G_FALSE
                ,p_validation_level       => FND_API.G_VALID_LEVEL_FULL
                ,p_resale_batch_id        => p_resale_batch_id
                ,p_start_date             => l_report_start_date
                ,p_end_date               => l_report_end_date
                ,x_return_status          => l_return_status
                ,x_msg_count              => l_msg_count
                ,x_msg_data               => l_msg_data
               );
               IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  OZF_UTILITY_PVT.error_message('OZF_RESALE_INIT_INV_TMP_ERR');
                  RAISE FND_API.G_EXC_ERROR;
               ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  OZF_UTILITY_PVT.error_message('OZF_RESALE_INIT_INV_TMP_ERR');
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
               /*
               OZF_SALES_TRANSACTIONS_PVT.Initiate_Inventory_tmp (
                 p_api_version            => 1.0
                ,p_init_msg_list          => FND_API.G_FALSE
                ,p_validation_level       => FND_API.G_VALID_LEVEL_FULL
                ,p_party_id               => l_partner_party_id
                ,p_start_date             => l_report_start_date
                ,x_return_status          => l_return_status
                ,x_msg_count              => l_msg_count
                ,x_msg_data               => l_msg_data
               );
               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  ozf_utility_pvt.error_message('OZF_RESALE_INIT_INV_TMP_ERR');
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
               */
               -- Bug
            END IF;

            -- get functional currency code and convertion type
            OPEN func_currency_cd_csr;
            FETCH func_currency_cd_csr INTO l_func_currency_code;
            CLOSE func_currency_cd_csr;

            OPEN exchange_rate_type_csr;
            FETCH exchange_rate_type_csr INTO l_default_exchange_type;
            CLOSE exchange_rate_type_csr;
         END IF;

         -- For each chargeback of the line, we will update the line and
         -- create an record in the ozf_resale_adjustment_all.
         For i in 1..p_line_tbl.LAST LOOP
            IF p_line_tbl(i).line_type_code = 'LINE' THEN

               IF p_caller_type = 'IFACE' THEN
                  -- Process interface data

                  OPEN OZF_RESALE_COMMON_PVT.g_interface_rec_csr(p_line_tbl(i).chargeback_int_id);
                  FETCH OZF_RESALE_COMMON_PVT.g_interface_rec_csr INTO l_resale_int_rec;
                  CLOSE OZF_RESALE_COMMON_PVT.g_interface_rec_csr;

                  -- Bug 4380203 (+)

                  -- Check inventory level FOR thIS order.
                  -- If inventory level IS lower than the asked, then there IS no need to
                  -- continue processing
                  IF l_inventory_tracking = 'T'  THEN
                     IF OZF_DEBUG_LOW_ON THEN
                        OZF_UTILITY_PVT.debug_message(l_api_name||' >> Need inventory tracking' );
                     END IF;

                     -- Check inventory level first
                     OZF_SALES_TRANSACTIONS_PVT.Validate_Inventory_level (
                         p_api_version      => 1.0
                        ,p_init_msg_list    => FND_API.G_FALSE
                        ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
                        ,p_line_int_rec     => l_resale_int_rec
                        ,x_valid            => l_inventory_level_valid
                        ,x_return_status    => l_return_status
                        ,x_msg_count        => l_msg_count
                        ,x_msg_data         => l_msg_data
                     );

                     IF NOT l_inventory_level_valid THEN
                        IF OZF_DEBUG_LOW_ON THEN
                           OZF_UTILITY_PVT.debug_message(l_api_name||' >> Did not pass inventory checking');
                        END IF;
                        --
                        OZF_RESALE_COMMON_PVT.Insert_Resale_Log (
                           p_id_value      => l_resale_int_rec.resale_line_int_id,
                           p_id_type       => 'IFACE',
                           p_error_code    => 'OZF_RESALE_INV_LEVEL_ERROR',
                           p_column_name   => NULL,
                           p_column_value  => NULL,
                           x_return_status => l_return_status
                        );
                        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                           RAISE FND_API.g_exc_error;
                        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                           RAISE FND_API.g_exc_unexpected_error;
                        END IF;

                        -- Delink resale interface line from batch
                        UPDATE ozf_resale_lines_int_all
                        SET resale_batch_id = null,
                            request_id = null,
                            status_code = 'DISPUTED',
                            dispute_code = 'OZF_LT_INVT'
                        WHERE resale_line_int_id = l_resale_int_rec.resale_line_int_id;

                        RAISE FND_API.g_exc_error;

                        -- Batch status won't be set to DISPUTED.
                        -- TP Accrual Process will still continue.
                     ELSE
                        IF OZF_DEBUG_LOW_ON THEN
                           OZF_UTILITY_PVT.debug_message(l_api_name||' >> Pass inventory validation');
                        END IF;
                     END IF;
                     --
                  END IF;
                  -- Bug 4380203 (-)

                  IF i = 1 THEN
                  -- I need to create a header
                     IF l_create_order_header THEN
                        OZF_RESALE_COMMON_PVT.Insert_Resale_Header(
                              p_api_version       => 1
                             ,p_init_msg_list     => FND_API.G_FALSE
                             ,p_commit            => FND_API.G_FALSE
                             ,p_validation_level  => FND_API.G_VALID_LEVEL_FULL
                             ,p_line_int_rec      => l_resale_int_rec
                             ,x_header_id         => l_header_id
                             ,x_return_status     => l_return_status
                             ,x_msg_data          => l_msg_data
                             ,x_msg_count         => l_msg_count
                        );
                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                     ELSE
                        -- get header id of the dup lines
                        OPEN dup_header_csr( p_resale_batch_id
                                           , l_order_number
                                           , l_cust_account_id
                                           , l_date_ordered
                                           );
                        FETCH dup_header_csr INTO l_header_id;
                        CLOSE dup_header_csr;

                     END IF;
                  END IF;

                  -- I will convert the adjusted amount to functional currency code.
                  l_exchange_type := l_resale_int_rec.exchange_rate_type;
                  l_exchange_date := l_resale_int_rec.exchange_rate_date;
                  l_rate          := l_resale_int_rec.exchange_rate;

                  IF l_func_currency_code <> l_resale_int_rec.currency_code THEN
                     IF l_rate IS NULL THEN
                        IF l_exchange_type IS NULL THEN
                           l_exchange_type := l_default_exchange_type;
                        END IF;

                        IF l_exchange_type IS NULL THEN
                           ozf_utility_pvt.error_message('OZF_CLAIM_CONTYPE_MISSING');
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;

                        IF l_exchange_date IS NULL THEN
                           l_exchange_date := sysdate;
                        END IF;

                        IF OZF_DEBUG_LOW_ON THEN
                           OZF_UTILITY_PVT.debug_message(l_api_name||' >> Convert Currency <<');
                           OZF_UTILITY_PVT.debug_message(l_api_name||' >> from currency :' || l_resale_int_rec.currency_code);
                           OZF_UTILITY_PVT.debug_message(l_api_name||' >> to currency   :' || l_func_currency_code);
                           OZF_UTILITY_PVT.debug_message(l_api_name||' >> rate          :' || l_rate);
                           OZF_UTILITY_PVT.debug_message(l_api_name||' >> exchange date :' || l_exchange_date);
                           OZF_UTILITY_PVT.debug_message(l_api_name||' >> exchange type :' || l_exchange_type);
                        END IF;

                        OZF_UTILITY_PVT.Convert_Currency(
                            p_from_currency  => l_resale_int_rec.currency_code
                           ,p_to_currency     => l_func_currency_code
                           ,p_conv_type       => l_exchange_type
                           ,p_conv_rate       => l_rate
                           ,p_conv_date       => l_exchange_date
                           ,p_from_amount     => p_line_tbl(i).adjusted_unit_price
                           ,x_return_status   => l_return_status
                           ,x_to_amount       => l_acctd_adj_unit_price
                           ,x_rate            => l_rate
                        );
                        IF l_return_status = FND_API.g_ret_sts_error THEN
                           RAISE FND_API.g_exc_error;
                        ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;

                        OZF_UTILITY_PVT.Convert_Currency(
                            p_from_currency   => l_resale_int_rec.currency_code
                           ,p_to_currency     => l_func_currency_code
                           ,p_conv_type       => l_exchange_type
                           ,p_conv_rate       => l_rate
                           ,p_conv_date       => l_exchange_date
                           ,p_FROM_amount     => l_resale_int_rec.selling_price
                           ,x_return_status   => l_return_status
                           ,x_to_amount       => l_acctd_selling_price
                           ,x_rate            => l_rate);
                        IF l_return_status = FND_API.g_ret_sts_error THEN
                           RAISE FND_API.g_exc_error;
                        ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                     ELSE
                        l_acctd_adj_unit_price := OZF_UTILITY_PVT.CurrRound(p_line_tbl(i).adjusted_unit_price*l_rate, l_func_currency_code);
                        l_acctd_selling_price  := OZF_UTILITY_PVT.CurrRound(l_resale_int_rec.selling_price*l_rate, l_func_currency_code);
                     END IF;
                  ELSE
                     l_rate := 1;
                     l_acctd_adj_unit_price := p_line_tbl(i).adjusted_unit_price;
                     l_acctd_selling_price := l_resale_int_rec.selling_price;
                  END IF;
               ELSE
                  -- Process Resale Data
                  l_inventory_tracking := 'F';
                  -- get resale_rec
                  OPEN  resale_rec_csr(p_line_tbl(i).chargeback_int_id);
                  FETCH resale_rec_csr INTO l_resale_rec;
                  CLOSE resale_rec_csr;
               END IF;

               Process_One_Line(
                  p_resale_line_int_rec  => l_resale_int_rec,
                  p_resale_line_rec      => l_resale_rec,
                  p_line_result_rec      => p_line_tbl(i),
                  p_header_id            => l_header_id,
                  p_resale_batch_id      => p_resale_batch_id,
                  p_inventory_tracking   => l_inventory_tracking = 'T',
                  p_price_diff_fund_id   => l_fund_id,
                  p_caller_type          => p_caller_type,
                  p_approver_id          => l_last_updated_by,
                  x_return_status        => l_return_status
               );
               IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                  -- drop this line from batch if it is from interface
                  IF p_caller_type = 'IFACE' THEN
                     BEGIN
                        UPDATE ozf_resale_lines_int_all
                        SET resale_batch_id = NULL,
                            request_id = NULL,
                            status_code = 'DISPUTED',
                            dispute_code = 'OZF_PRIC_RESULT_ERR'
                        WHERE resale_line_int_id = p_line_tbl(i).chargeback_int_id;
                     EXCEPTION
                        WHEN OTHERS THEN
                           ozf_utility_pvt.error_message('OZF_UPD_RESALE_INT_WRG');
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                     END;
                  END IF;
               ELSE
                  -- CLOSE THIS LINE If it is from interface
                  IF p_caller_type = 'IFACE' THEN
                     BEGIN
                        UPDATE ozf_resale_lines_int_all
                        SET status_code= 'CLOSED'
                        WHERE resale_line_int_id = p_line_tbl(i).chargeback_int_id;
                     EXCEPTION
                        WHEN OTHERS THEN
                           ozf_utility_pvt.error_message('OZF_UPD_RESALE_INT_WRG');
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                     END;
                  END IF;
               END IF;
            END IF; -- END if current record is a line
         END LOOP; -- END LOOP through lines
      END IF; -- END of checking error
   END IF; -- END of EXISTS

   x_return_status := l_return_status;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': end');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO PROC_PRIC_RESULT;
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO PROC_PRIC_RESULT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      ROLLBACK TO PROC_PRIC_RESULT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END process_pricing_result;

---------------------------------------------------------------------
-- PROCEDURE
--    Process_Resale_Order
--
-- PURPOSE
--    Process resale batch information. Reads date FROM ozf_reasle_lines table.
--
-- PARAMETERS
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE Process_Resale_Order
(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN    NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)IS
l_api_name          CONSTANT VARCHAR2(30) := 'Process_Resale_Order';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     VARCHAR2(30);
l_msg_data          VARCHAR2(2000);
l_msg_count         NUMBER;

CURSOR header_id_csr IS
   SELECT DISTINCT a.resale_header_id --Bug# 8328719 fixed by ateotia
   ,      a.header_attribute_category
   ,      a.header_attribute1
   ,      a.header_attribute2
   ,      a.header_attribute3
   ,      a.header_attribute4
   ,      a.header_attribute5
   ,      a.header_attribute6
   ,      a.header_attribute7
   ,      a.header_attribute8
   ,      a.header_attribute9
   ,      a.header_attribute10
   ,      a.header_attribute11
   ,      a.header_attribute12
   ,      a.header_attribute13
   ,      a.header_attribute14
   ,      a.header_attribute15
   FROM ozf_resale_headers_all a
      , ozf_resale_lines_all b
      , ozf_resale_batch_line_maps_all c
   WHERE a.resale_header_id = b.resale_header_id
   AND b.resale_line_id = c.resale_line_id
   AND c.resale_batch_id = p_resale_batch_id;

TYPE header_id_tbl_type is TABLE OF header_id_csr%rowtype INDEX BY binary_integer;
l_header_id_tbl header_id_tbl_type;

CURSOR order_header_csr(p_header_id in NUMBER) IS
SELECT *
FROM ozf_resale_headers
WHERE resale_header_id = p_header_id;

l_header_rec order_header_csr%rowtype;

CURSOR order_set_csr(p_header_id in NUMBER) IS
SELECT *
FROM ozf_resale_lines
WHERE resale_header_id = p_header_id;

TYPE resale_lines_tbl_type is  TABLE OF order_set_csr%rowtype INDEX BY binary_integer;
l_order_set_tbl resale_lines_tbl_type;

l_control_rec  QP_PREQ_GRP.CONTROL_RECORD_TYPE;

l_line_tbl          OZF_ORDER_PRICE_PVT.LINE_REC_TBL_TYPE;
l_ldets_tbl         OZF_ORDER_PRICE_PVT.LDETS_TBL_TYPE;
l_related_lines_tbl OZF_ORDER_PRICE_PVT.RLTD_LINE_TBL_TYPE;

p NUMBER;
k NUMBER;

l_log_id NUMBER;

l_temp_count NUMBER;
l_temp_data VARCHAR2(2000);
l_price_flag VARCHAR2(1) := NULL;

--mkothari 13-dec-2006
l_list_price_override_flag VARCHAR2(1) := NULL;

l_accrual_on_selling      VARCHAR2(3);
l_default_price_list_id   NUMBER;
  -- bug 6317120
  l_org_id                NUMBER;
  -- end bug 6317120
BEGIN
   -- Standard BEGIN of API savepoint
   SAVEPOINT  Process_Resale_Order;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
        l_api_version,
        p_api_version,
        l_api_name,
        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Initialize message list if p_init_msg_list is TRUE.
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': Start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- We need to UPDATE the order FROM indirect customers so that they're not to be included in the
   -- pricing simulation;

   -- Get profile value for price list
   l_default_price_list_id := G_TP_DEFAULT_PRICE_LIST; --fnd_profile.value('OZF_TP_ACCRUAL_PRICE_LIST');

   -- Define control rec
   -- setup pricing_event based on purpose code and profile
   -- privcing_event is based on profile

   l_control_rec.pricing_event := fnd_profile.value('OZF_PRICING_SIMULATION_EVENT');
   IF l_control_rec.pricing_event is NULL THEN
       IF OZF_DEBUG_LOW_ON THEN
         ozf_utility_PVT.debug_message('pricing event default');
       END IF;
       l_control_rec.pricing_event := 'BATCH,BOOK,SHIP';
   ELSE
      IF l_control_rec.pricing_event = 'BATCH' THEN
         l_control_rec.pricing_event := 'BATCH';
      ELSIF l_control_rec.pricing_event = 'BOOK' THEN
         l_control_rec.pricing_event := 'BATCH,BOOK';
      ELSIF l_control_rec.pricing_event = 'SHIP' THEN
         l_control_rec.pricing_event := 'BATCH,BOOK,SHIP';
      END IF;
   END IF;

   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_PVT.debug_message('Event:' ||l_control_rec.pricing_event );
   END IF;

   l_control_rec.calculate_flag := 'Y';
   l_control_rec.simulation_flag := 'Y';
   l_control_rec.source_order_amount_flag := 'Y';
   l_control_rec.GSA_CHECK_FLAG := 'N';
   l_control_rec.GSA_DUP_CHECK_FLAG := 'N';
   l_control_rec.TEMP_TABLE_INSERT_FLAG := 'N';

   IF l_header_id_tbl.EXISTS(1) THEN
      l_header_id_tbl.DELETE;
   END IF;
   --p := 1;
   OPEN header_id_csr;
   FETCH header_id_csr BULK COLLECT INTO l_header_id_tbl;
   -- LOOP
   --   FETCH header_id_csr INTO l_header_id_tbl(p);
   --   EXIT when header_id_csr%notfound;
   --   p:= p+1;
   -- END LOOP;
   CLOSE header_id_csr;

   IF l_header_id_tbl.EXISTS(1) THEN
      -- setup price_flag based on profile
      l_accrual_on_selling := G_ACCRUAL_ON_SELLING; --fnd_profile.value('OZF_ACC_ON_SELLING_PRICE');

      -- If this profile is not set, we default the value to 'N'

      IF l_accrual_on_selling is NULL THEN
         l_accrual_on_selling := 'N';
      END IF;

      -- convert the value of the profile to proper price flag value
      IF l_accrual_on_selling = 'Y' THEN
         --l_price_flag := 'G'; -- 'G' is not implemented in QP -- mkothari

         --mkothari 13-dec-2006
         l_price_flag := 'Y';
         l_list_price_override_flag := 'Y';

      ELSE
         l_price_flag := 'Y';
      END IF;
      IF OZF_DEBUG_LOW_ON THEN
         ozf_utility_PVT.debug_message('Price flag:' ||l_price_flag );
         ozf_utility_PVT.debug_message('List Price Override Flag:' ||l_list_price_override_flag);
      END IF;

      For i in 1..l_header_id_tbl.LAST
      LOOP

         IF l_header_id_tbl(i).resale_header_id is not NULL THEN

            QP_Price_Request_Context.Set_Request_Id;

            IF OZF_DEBUG_LOW_ON THEN
               ozf_utility_PVT.debug_message('/*--- Processing order for order NUMBER:'||l_header_id_tbl(i).resale_header_id||'---*/');
            END IF;
            -- Before start process, clean up the data structures if necessary.
            IF l_order_set_tbl.EXISTS(1) THEN l_order_set_tbl.DELETE; END IF;
            IF l_line_tbl.EXISTS(1)      THEN l_line_tbl.DELETE; END IF;
            IF l_ldets_tbl.EXISTS(1)      THEN l_ldets_tbl.DELETE; END IF;
            IF l_related_lines_tbl.EXISTS(1) THEN l_related_lines_tbl.DELETE; END IF;
            IF OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL.EXISTS(1) THEN OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL.DELETE; END IF;
            IF OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL.EXISTS(1) THEN OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL.DELETE; END IF;

               -- get order_header_rec
            OPEN order_header_csr(l_header_id_tbl(i).resale_header_id);
            FETCH order_header_csr INTO l_header_rec;
            CLOSE order_header_csr;

            --k:=1;
            OPEN order_set_csr(l_header_id_tbl(i).resale_header_id);
            FETCH order_set_csr BULK COLLECT INTO l_order_set_tbl;
            --LOOP
            --   FETCH order_set_csr INTO l_order_set_tbl(k);
            --   EXIT when order_set_csr%notfound;
            --   k:=k+1;
            --END LOOP;
            CLOSE order_set_csr;

            IF OZF_DEBUG_LOW_ON THEN
               ozf_utility_PVT.debug_message('after order set'||l_order_set_tbl.LAST);
            END IF;
            IF l_order_set_tbl.exists(1) THEN
               For J in 1..l_order_set_tbl.LAST
               LOOP

                  -- ???????? Purge the any error message that might be there. Rethink this
                  -- OK for now
                  BEGIN
                     DELETE FROM ozf_resale_logs
                     WHERE resale_id = l_order_set_tbl(J).resale_line_id
                     AND   resale_id_type = OZF_RESALE_COMMON_PVT.G_ID_TYPE_LINE;
                  EXCEPTION
                     WHEN OTHERS THEN
                        ozf_utility_pvt.error_message('OZF_DEL_RESALE_LOG_WRG');
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END;

                  IF OZF_DEBUG_LOW_ON THEN
                     ozf_utility_PVT.debug_message(l_api_name||'>> building order line for resale line id: '||l_order_set_tbl(j).resale_line_id);
                  END IF;

                  -- INSERT INTO l_line_tbl
                  l_line_tbl(j).line_index               := j;
                  l_line_tbl(j).line_id                  := l_order_set_tbl(j).resale_line_id;
                  l_line_tbl(j).line_type_code           := OZF_ORDER_PRICE_PVT.G_ORDER_LINE_TYPE;
                  l_line_tbl(j).pricing_effective_date   := l_order_set_tbl(j).date_ordered;
                  l_line_tbl(j).active_date_first        := l_order_set_tbl(j).date_ordered;
                  l_line_tbl(j).active_date_first_type   := 'ORD';
                  l_line_tbl(j).active_date_second       := l_order_set_tbl(j).date_shipped;
                  l_line_tbl(j).active_date_second_type  := 'SHIP';
                  l_line_tbl(j).line_quantity            := ABS(l_order_set_tbl(j).quantity); -- BUG 4581928
                  l_line_tbl(j).line_uom_code            := l_order_set_tbl(j).uom_code;
                  l_line_tbl(j).request_type_code        := 'ONT';
                  -- Pricing might be able to default it

                  --mkothari 13-dec-2006
                  --IF l_price_flag ='G' THEN
                  IF l_list_price_override_flag = 'Y' THEN
                     l_line_tbl(j).priced_quantity       := ABS(l_order_set_tbl(j).quantity); -- BUG 4581928
                     l_line_tbl(j).priced_uom_code       := l_order_set_tbl(j).uom_code;
                     l_line_tbl(j).unit_price            := l_order_set_tbl(j).selling_price;
                  END IF;
                  l_line_tbl(j).currency_code            := l_order_set_tbl(j).currency_code;
                  IF l_header_rec.price_list_id IS NOT NULL THEN
                     l_line_tbl(j).price_list_id      := l_header_rec.price_list_id;
                  ELSE
                     l_line_tbl(j).price_list_id      := l_default_price_list_id;
                  END IF;
                  l_line_tbl(j).price_flag               := l_price_flag;
                  --mkothari 13-dec-2006
                  l_line_tbl(j).list_price_override_flag := l_list_price_override_flag;

                  l_line_tbl(j).pricing_status_code      := QP_PREQ_GRP.G_STATUS_UNCHANGED;
                  l_line_tbl(j).chargeback_int_id        := l_order_set_tbl(j).resale_line_id;
                  l_line_tbl(j).resale_table_type        := 'LINE'; -- bug 5360598
                  --        l_line_tbl(j).UNIT_PRICE              := NULL;
                  --        l_line_tbl(j).PERCENT_PRICE           := NULL;
                  --        l_line_tbl(j).UOM_QUANTITY            := NULL;
                  --        l_line_tbl(j).ADJUSTED_UNIT_PRICE     := NULL;
                  --        l_line_tbl(j).UPD_ADJUSTED_UNIT_PRICE   NUMBER:= FND_API.G_MISS_NUM,
                  --        l_line_tbl(j).PROCESSED_FLAG            VARCHAR2(1):= FND_API.G_MISS_CHAR,
                  --        l_line_tbl(j).PROCESSING_ORDER          := NULL;
                  --        l_line_tbl(j).PRICING_STATUS_TEXT       := NULL;
                  --        l_line_tbl(j).ROUNDING_FLAG             := NULL;
                  --        l_line_tbl(j).ROUNDING_FACTOR             := NULL;
                  --        l_line_tbl(j).QUALIFIERS_EXIST_FLAG     := NULL;
                  --        l_line_tbl(j).PRICING_ATTRS_EXIST_FLAG  := NULL;
                  --        l_line_tbl(j).PL_VALIDATED_FLAG         := NULL;
                  --        l_line_tbl(j).PRICE_REQUEST_CODE        := NULL;
                  --        l_line_tbl(j).USAGE_PRICING_TYPE        := NULL;
                  --        l_line_tbl(j).LINE_CATEGORY             := NULL;


                  -- populate the order_price global line arrary
                  -- Here I only populate the values of the qualifiers for ONT.
                  -- The real global structure will be populate in ozf_order_price_pvt.
                  -- And it's value can be change in OZF_CHARGEBACK_ATTRMAP_PUB

                  OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).header_id                := l_order_set_tbl.LAST + 1;
                  OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).line_id                  := l_order_set_tbl(j).resale_line_id;
                  OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).line_type_id             := l_header_rec.order_type_id;
                  OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).inventory_item_id        := l_order_set_tbl(j).inventory_item_id;
                  OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).ordered_quantity         := ABS(l_order_set_tbl(j).quantity);
                  OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).order_quantity_uom       := l_order_set_tbl(j).uom_code;
                  OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).invoice_to_org_id        := l_order_set_tbl(j).bill_to_site_use_id;
                  OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).ship_to_org_id           := l_order_set_tbl(j).ship_to_site_use_id;
                  OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).sold_to_org_id           := l_order_set_tbl(j).bill_to_cust_account_id;
                  --OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).sold_from_org_id       := l_order_set_tbl(j).sold_from_cust_account_id;
                  OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).invoice_to_party_id      := l_order_set_tbl(j).bill_to_party_id;
                  OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).invoice_to_party_site_id := l_order_set_tbl(j).bill_to_party_site_id;
                  OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).ship_to_party_id         := l_order_set_tbl(j).ship_to_party_id;
                  OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).ship_to_party_site_id    := l_order_set_tbl(j).ship_to_party_site_id;
                  OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).price_list_id            := l_line_tbl(j).price_list_id;
                  OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).request_date             := l_order_set_tbl(j).date_ordered;
                  OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).actual_shipment_date     := l_order_set_tbl(j).date_shipped;
                  OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).pricing_date             := l_order_set_tbl(j).date_ordered;

                  -- R12 Populate Global Resale Structure (+)
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).batch_type                     := 'TP_ACCRUAL';
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).qp_context_request_id          := QP_Price_Request_Context.Get_Request_Id;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_index                     := l_line_tbl(j).line_index;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).resale_table_type              := 'RESALE';
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_id                        := l_order_set_tbl(j).resale_line_id;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).resale_transfer_type           := l_order_set_tbl(j).resale_transfer_type;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).product_transfer_movement_type := l_order_set_tbl(j).product_transfer_movement_type;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).product_transfer_date          := l_order_set_tbl(j).product_transfer_date;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).tracing_flag                   := l_order_set_tbl(j).tracing_flag;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).sold_from_cust_account_id      := l_order_set_tbl(j).sold_from_cust_account_id;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).sold_from_site_id              := l_order_set_tbl(j).sold_from_site_id;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).sold_from_contact_party_id     := l_order_set_tbl(j).sold_from_contact_party_id;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).ship_from_cust_account_id      := l_order_set_tbl(j).ship_from_cust_account_id;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).ship_from_site_id              := l_order_set_tbl(j).ship_from_site_id;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).ship_from_contact_party_id     := l_order_set_tbl(j).ship_from_contact_party_id;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).bill_to_party_id               := l_order_set_tbl(j).bill_to_party_id;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).bill_to_party_site_id          := l_order_set_tbl(j).bill_to_party_site_id;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).bill_to_contact_party_id       := l_order_set_tbl(j).bill_to_contact_party_id;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).ship_to_party_id               := l_order_set_tbl(j).ship_to_party_id;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).ship_to_party_site_id          := l_order_set_tbl(j).ship_to_party_site_id;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).ship_to_contact_party_id       := l_order_set_tbl(j).ship_to_contact_party_id;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).end_cust_party_id              := l_order_set_tbl(j).end_cust_party_id;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).end_cust_site_use_id           := l_order_set_tbl(j).end_cust_site_use_id;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).end_cust_site_use_code         := l_order_set_tbl(j).end_cust_site_use_code;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).end_cust_party_site_id         := l_order_set_tbl(j).end_cust_party_site_id;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).end_cust_contact_party_id      := l_order_set_tbl(j).end_cust_contact_party_id;
                  --OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).data_source_code               := ??
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute_category      := l_header_id_tbl(i).header_attribute_category;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute1              := l_header_id_tbl(i).header_attribute1;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute2              := l_header_id_tbl(i).header_attribute2;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute3              := l_header_id_tbl(i).header_attribute3;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute4              := l_header_id_tbl(i).header_attribute4;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute5              := l_header_id_tbl(i).header_attribute5;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute6              := l_header_id_tbl(i).header_attribute6;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute7              := l_header_id_tbl(i).header_attribute7;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute8              := l_header_id_tbl(i).header_attribute8;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute9              := l_header_id_tbl(i).header_attribute9;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute10             := l_header_id_tbl(i).header_attribute10;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute11             := l_header_id_tbl(i).header_attribute11;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute12             := l_header_id_tbl(i).header_attribute12;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute13             := l_header_id_tbl(i).header_attribute13;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute14             := l_header_id_tbl(i).header_attribute14;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute15             := l_header_id_tbl(i).header_attribute15;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute_category        := l_order_set_tbl(j).line_attribute_category;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute1                := l_order_set_tbl(j).line_attribute1;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute2                := l_order_set_tbl(j).line_attribute2;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute3                := l_order_set_tbl(j).line_attribute3;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute4                := l_order_set_tbl(j).line_attribute4;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute5                := l_order_set_tbl(j).line_attribute5;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute6                := l_order_set_tbl(j).line_attribute6;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute7                := l_order_set_tbl(j).line_attribute7;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute8                := l_order_set_tbl(j).line_attribute8;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute9                := l_order_set_tbl(j).line_attribute9;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute10               := l_order_set_tbl(j).line_attribute10;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute11               := l_order_set_tbl(j).line_attribute11;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute12               := l_order_set_tbl(j).line_attribute12;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute13               := l_order_set_tbl(j).line_attribute13;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute14               := l_order_set_tbl(j).line_attribute14;
                  OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute15               := l_order_set_tbl(j).line_attribute15;
                  -- R12 Populate Global Resale Structure (-)



               END LOOP;

               IF OZF_DEBUG_LOW_ON THEN
                  ozf_utility_PVT.debug_message(l_api_name||'>> building order header');
               END IF;

               -- build summary line
               k := l_order_set_tbl.LAST + 1;
               l_line_tbl(k).line_index                := k;
               l_line_tbl(k).line_id                   := NULL;
               l_line_tbl(k).line_type_code            := OZF_ORDER_PRICE_PVT.G_ORDER_HEADER_TYPE;
               l_line_tbl(k).pricing_effective_date    := l_header_rec.date_ordered;
               l_line_tbl(k).active_date_first         := l_header_rec.date_ordered;
               l_line_tbl(k).active_date_first_type    := 'ORD'; -- Change because of ONT QP order 'NO TYPE';
               l_line_tbl(k).active_date_second        := l_header_rec.date_shipped;
               l_line_tbl(k).active_date_second_type   := 'SHIP'; -- change because of ONT QP order 'NO TYPE';
               l_line_tbl(k).request_type_code         := 'ONT';
               l_line_tbl(k).currency_code             := l_order_set_tbl(1).currency_code;
               l_line_tbl(k).price_list_id             := l_line_tbl(1).price_list_id;
               l_line_tbl(k).price_flag                := l_price_flag;

               --mkothari 13-dec-2006
               l_line_tbl(k).list_price_override_flag  := l_list_price_override_flag;
               l_line_tbl(k).pricing_status_code       := QP_PREQ_GRP.G_STATUS_UNCHANGED;
               l_line_tbl(k).chargeback_int_id         := l_order_set_tbl(1).resale_line_id;
               l_line_tbl(k).resale_table_type         := 'LINE'; -- bug 5360598


               -- populate the order_price global header structure
               -- Here I only populate the values of the qualifiers for ONT.
               -- The real global structure will be populate in ozf_order_price_pvt.
               -- And it's value can be change in OZF_CHARGEBACK_ATTRMAP_PUB

               -- Might be able to add more value here.
               OZF_ORDER_PRICE_PVT.G_HEADER_REC.header_id                := k;
               OZF_ORDER_PRICE_PVT.G_HEADER_REC.order_type_id            := l_header_rec.order_type_id;
               OZF_ORDER_PRICE_PVT.G_HEADER_REC.sold_to_org_id           := l_header_rec.bill_to_cust_account_id;
               OZF_ORDER_PRICE_PVT.G_HEADER_REC.invoice_to_org_id        := l_header_rec.bill_to_site_use_id;
               OZF_ORDER_PRICE_PVT.G_HEADER_REC.ship_to_org_id           := l_header_rec.ship_to_site_use_id;
               OZF_ORDER_PRICE_PVT.G_HEADER_REC.invoice_to_party_id      := l_header_rec.bill_to_party_id;
               OZF_ORDER_PRICE_PVT.G_HEADER_REC.invoice_to_party_site_id := l_header_rec.bill_to_party_site_id;
               OZF_ORDER_PRICE_PVT.G_HEADER_REC.ship_to_party_id         := l_header_rec.ship_to_party_id;
               OZF_ORDER_PRICE_PVT.G_HEADER_REC.ship_to_party_site_id    := l_header_rec.ship_to_party_site_id;
               OZF_ORDER_PRICE_PVT.G_HEADER_REC.price_list_id            := l_line_tbl(1).price_list_id;
               OZF_ORDER_PRICE_PVT.G_HEADER_REC.ordered_date             := l_header_rec.date_ordered;
               OZF_ORDER_PRICE_PVT.G_HEADER_REC.request_date             := l_header_rec.date_ordered;
               OZF_ORDER_PRICE_PVT.G_HEADER_REC.pricing_date             := l_header_rec.date_ordered;


               IF OZF_DEBUG_LOW_ON THEN
                  ozf_utility_PVT.debug_message(l_api_name||'>> Calling Get_Order_');
               END IF;

               OZF_ORDER_PRICE_PVT.Get_Order_Price (
                  p_api_version            => 1.0
                  ,p_init_msg_list          => FND_API.G_FALSE
                  ,p_commit                 => FND_API.G_FALSE
                  ,p_validation_level       => FND_API.G_VALID_LEVEL_FULL
                  ,x_return_status          => l_return_status
                  ,x_msg_data               => l_msg_data
                  ,x_msg_count              => l_msg_count
                  ,p_control_rec            => l_control_rec
                  ,xp_line_tbl              => l_line_tbl
                  ,x_ldets_tbl              => l_ldets_tbl
                  ,x_related_lines_tbl      => l_related_lines_tbl
               );
               IF l_return_status<> FND_API.G_RET_STS_SUCCESS THEN
                  ozf_utility_pvt.error_message('OZF_GET_ORDER_PRIC_ERR');

                  FOR p in 1..l_order_set_tbl.LAST
                  LOOP
                     BEGIN
                        OPEN OZF_RESALE_COMMON_PVT.g_log_id_csr;
                        FETCH OZF_RESALE_COMMON_PVT.g_log_id_csr INTO l_log_id;
                        CLOSE OZF_RESALE_COMMON_PVT.g_log_id_csr;

                        -- julou bug 6317120. get org_id from table
                        OPEN  OZF_RESALE_COMMON_PVT.gc_line_org_id(l_order_set_tbl(p).resale_line_id);
                        FETCH OZF_RESALE_COMMON_PVT.gc_line_org_id INTO l_org_id;
                        CLOSE OZF_RESALE_COMMON_PVT.gc_line_org_id;

                        OZF_RESALE_LOGS_PKG.Insert_Row(
                           px_resale_log_id           => l_log_id,
                           p_resale_id                => l_order_set_tbl(p).resale_line_id,
                           p_resale_id_type           => OZF_RESALE_COMMON_PVT.G_ID_TYPE_LINE,
                           p_error_code               => 'OZF_GET_ORDER_PRIC_ERR',
                           p_error_message            => fnd_message.get_string('OZF','OZF_GET_ORDER_PRIC_ERR'),
                           p_column_name              => NULL,
                           p_column_value             => NULL,
                           --px_org_id                  => OZF_RESALE_COMMON_PVT.g_org_id
                           px_org_id                  => l_org_id
                        );
                     EXCEPTION
                        WHEN OTHERS THEN
                           ozf_utility_pvt.error_message('OZF_INS_RESALE_LOG_WRG');
                           RAISE FND_API.g_exc_unexpected_error;
                     END;
                  END LOOP;
                  IF OZF_DEBUG_LOW_ON THEN
                     ozf_utility_PVT.debug_message('/*--- Get order price failed ---*/');
                  END IF;
                  GOTO END_LOOP;
               END IF;
               IF OZF_DEBUG_LOW_ON THEN
                  ozf_utility_PVT.debug_message('/*--- Get order price succeeded ---*/');
                  ozf_utility_PVT.debug_message('calling process price result');
                  ozf_utility_PVT.debug_message('/*--- Calling process_price_result: ---*/');
               END IF;

               -- Here, reasle_batch_id is passed for some process convenience, it's not necessary.

               process_pricing_result(
                  p_resale_batch_id => p_resale_batch_id,
                  p_line_tbl        => l_line_tbl,
                  p_caller_type     => G_RESALE_CALLER,
                  x_return_status   => l_return_status
               );
               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  FND_MSG_PUB.Count_And_Get (
                     p_encoded => FND_API.G_FALSE,
                     p_count => l_temp_count,
                     p_data  => l_temp_data
                  );

                  fnd_msg_pub.Get(
                      p_msg_index      => l_temp_count,
                      p_encoded        => FND_API.G_FALSE,
                      p_data           => l_temp_data,
                      p_msg_index_out  => l_temp_count
                  );
                  IF OZF_DEBUG_LOW_ON THEN
                     ozf_utility_PVT.debug_message('After process_price:'||l_temp_count||' ,'||l_temp_data);
                  END IF;
                  FOR i in 1..l_order_set_tbl.LAST
                  LOOP
                     BEGIN
                        OPEN OZF_RESALE_COMMON_PVT.g_log_id_csr;
                        FETCH OZF_RESALE_COMMON_PVT.g_log_id_csr INTO l_log_id;
                        CLOSE OZF_RESALE_COMMON_PVT.g_log_id_csr;

                        -- julou bug 6317120. get org_id from table
                        OPEN  OZF_RESALE_COMMON_PVT.gc_line_org_id(l_order_set_tbl(i).resale_line_id);
                        FETCH OZF_RESALE_COMMON_PVT.gc_line_org_id INTO l_org_id;
                        CLOSE OZF_RESALE_COMMON_PVT.gc_line_org_id;

                        OZF_RESALE_LOGS_PKG.Insert_Row(
                           px_resale_log_id           => l_log_id,
                           p_resale_id                => l_order_set_tbl(i).resale_line_id,
                           p_resale_id_type           => OZF_RESALE_COMMON_PVT.G_ID_TYPE_LINE,
                           p_error_code               => 'OZF_PROC_PRIC_RESLT_ERR',
                           p_error_message            => fnd_message.get_string('OZF','OZF_PROC_PRIC_RESLT_ERR'),
                           p_column_name              => NULL,
                           p_column_value             => NULL,
                           --px_org_id                  => OZF_RESALE_COMMON_PVT.g_org_id
                           px_org_id                  => l_org_id
                        );
                     EXCEPTION
                        WHEN OTHERS THEN
                          ozf_utility_pvt.error_message('OZF_INS_RESALE_LOG_WRG');
                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                     END;
                  END LOOP;
                  IF OZF_DEBUG_LOW_ON THEN
                     ozf_utility_PVT.debug_message('/*--- process_price_result Failed ---*/');
                  END IF;
                  goto END_LOOP;
               END IF;
            ELSE
               IF OZF_DEBUG_LOW_ON THEN
                  ozf_utility_PVT.debug_message('No order line to be processed');
               END IF;
            END IF;
         END IF; -- END if for order_NUMBER, bill_to cust not NULL
        << END_LOOP >>
        NULL;
      END LOOP;
   ELSE
      IF OZF_DEBUG_LOW_ON THEN
         ozf_utility_PVT.debug_message('/*--- No order to process ---*/');
      END IF;
   END IF;
   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': End'|| x_return_status);
   END IF;
   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Process_Resale_Order;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Process_Resale_Order;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Process_Resale_Order;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
END Process_Resale_Order;

---------------------------------------------------------------------
-- PROCEDURE
--    Process_Resale
--
-- PURPOSE
--    Process a batch FROM resale tables.
--
-- PARAMETERS
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE Process_Resale (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id             IN    NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)IS
l_api_name          CONSTANT VARCHAR2(30) := 'PROCESS_RESALE';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     VARCHAR2(30);
l_msg_data          VARCHAR2(2000);
l_msg_count         NUMBER;

BEGIN
   -- Standard BEGIN of API savepoint
   SAVEPOINT  PROCESS_TP_RESALE;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
      l_api_version,
      p_api_version,
      l_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Initialize message lISt if p_init_msg_list IS TRUE.
   IF FND_API.To_BOOLEAN (p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- validate batch for resale processing
   Validate_batch(
      p_api_version        => 1
      ,p_init_msg_list      => FND_API.G_FALSE
      ,p_commit             => FND_API.G_FALSE
      ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
      ,p_resale_batch_id    => p_resale_batch_id
      ,x_return_status      => l_return_status
      ,x_msg_data           => l_msg_data
      ,x_msg_count          => l_msg_count
      );

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- calling Third party accrual validation for this batch
   Validate_Order_Record(
      p_api_version        => 1
      ,p_init_msg_list      => FND_API.G_FALSE
      ,p_commit             => FND_API.G_FALSE
      ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
      ,p_resale_batch_id    => p_resale_batch_id
      ,p_caller_type        => G_RESALE_CALLER
      ,x_return_status      => l_return_status
      ,x_msg_data           => l_msg_data
      ,x_msg_count          => l_msg_count
   );

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   Process_Resale_Order (
      p_api_version     => 1.0
      ,p_init_msg_list   => FND_API.G_FALSE
      ,p_commit          => FND_API.G_FALSE
      ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
      ,p_resale_batch_id  => p_resale_batch_id
      ,x_return_status    => l_return_status
      ,x_msg_data         => l_msg_data
      ,x_msg_count        => l_msg_count
   );

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': End');
   END IF;
   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO PROCESS_TP_RESALE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO PROCESS_TP_RESALE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO PROCESS_TP_RESALE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
END Process_Resale;

---------------------------------------------------------------------
-- PROCEDURE
--    Move_Indirect_Customer_Order
--
-- PURPOSE
--
--   This procedure is to move indirect customer data to the resale tables. It
--   is called during the process of IFACE data
--
-- THIS IS TO BE USED IN MAKE PAYMENT
--    need to INSERT these transaction in inventory
--
-- PARAMETERS
--
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE  Move_Indirect_Customer_Order
(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id             IN    NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)IS
l_api_name          CONSTANT VARCHAR2(30) := 'Move_Indirect_Customer_Order';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     VARCHAR2(30);
l_msg_data          VARCHAR2(2000);
l_msg_count         NUMBER;

l_org_id NUMBER;
-- Start: bug # 5997978 fixed
/*CURSOR org_id_csr IS
SELECT (TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1, 10)))
FROM   dual; */
l_batch_org_id NUMBER;
CURSOR org_id_csr(cv_resale_batch_id IN NUMBER) IS
  SELECT org_id
  FROM ozf_resale_batches_all
  WHERE resale_batch_id = cv_resale_batch_id;
-- End: bug # 5997978 fixed

CURSOR order_num_csr is
SELECT distinct order_NUMBER,
                bill_to_cust_account_id,
                date_ordered
FROM ozf_resale_lines_int
WHERE status_code=OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_OPEN
AND direct_customer_flag = 'F'
AND resale_batch_id = p_resale_batch_id
ORDER BY date_ordered;

TYPE order_num_tbl_type is TABLE OF order_num_csr%rowtype INDEX BY binary_integer;
l_order_num_tbl order_num_tbl_type;

-- we only need one record
CURSOR interface_rec_csr(p_num in VARCHAR2,
                         p_name in VARCHAR2,
                         p_date in date) IS
SELECT *
FROM ozf_resale_lines_int
WHERE order_NUMBER = p_num
AND bill_to_cust_account_id = p_name
AND date_ordered = p_date
AND direct_customer_flag ='F'
AND status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_OPEN
AND resale_batch_id = p_resale_batch_id;

TYPE interface_tbl_type is TABLE OF OZF_RESALE_COMMON_PVT.g_interface_rec_csr%rowtype INDEX BY binary_integer;

l_resale_int_tbl interface_tbl_type;

l_header_id NUMBER;
l_line_id NUMBER;

j  NUMBER;
k  NUMBER;
BEGIN
   -- Standard BEGIN of API savepoint
   SAVEPOINT  TP_ACCRUAL_MV_IC;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
     l_api_version,
     p_api_version,
     l_api_name,
     G_PKG_NAME)
   THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Initialize message list if p_init_msg_list is TRUE.
   IF FND_API.To_Boolean (p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': Start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_PVT.debug_message('in mv id cust' );
   END IF;
   -- get org_id
   -- Start: bug # 5997978 fixed
   --OPEN org_id_csr;
   OPEN org_id_csr(p_resale_batch_id);
   -- End: bug # 5997978 fixed
   FETCH org_id_csr INTO l_batch_org_id;
   l_org_id := MO_GLOBAL.get_valid_org(l_batch_org_id);
   CLOSE org_id_csr;

   IF l_org_id is NULL THEN
      ozf_utility_pvt.error_message('OZF_CLAIM_ORG_ID_MISSING');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --j:=1;
   IF l_order_num_tbl.EXISTS(1) THEN
      l_order_num_tbl.DELETE;
   END IF;
   -- INSERT order headers and UPDATE lines.
   OPEN order_num_csr;
   FETCH order_num_csr BULK COLLECT INTO l_order_num_tbl;
   --LOOP
   --   EXIT WHEN order_num_csr%NOTFOUND;
   --   FETCH order_num_csr INTO l_order_num_tbl(j);
   --   j:=j+1;
   --END LOOP;
   CLOSE order_num_csr;

   IF l_order_num_tbl.EXISTS(1) THEN
      FOR i in 1..l_order_num_tbl.LAST
      LOOP
         IF OZF_DEBUG_LOW_ON THEN
            ozf_utility_PVT.debug_message('mv indirect customer with order NUMBER, cust name:' || l_order_num_tbl(i).order_NUMBER|| ','||l_order_num_tbl(i).bill_to_cust_account_id);
         END IF;

         j:=1;
         OPEN interface_rec_csr( l_order_num_tbl(i).order_NUMBER,
                                 l_order_num_tbl(i).bill_to_cust_account_id,
                                 l_order_num_tbl(i).date_ordered);
         LOOP
            EXIT when interface_rec_csr%NOTFOUND;
            FETCH interface_rec_csr INTO l_resale_int_tbl(j);
            j:=j+1;
         END LOOP;
         CLOSE interface_rec_csr;

         -- DELETE the error log before INSERT the orders
         DELETE FROM ozf_resale_logs_all a
         WHERE a.resale_id_type = 'IFACE'
         AND a.resale_id IN (
            SELECT resale_line_int_id
            FROM ozf_resale_lines_int_all b
            WHERE b.direct_customer_flag = 'F'
            AND b.status_code = 'OPEN'
            AND b.order_number = l_order_num_tbl(i).order_number
            AND b.bill_to_cust_account_id = l_order_num_tbl(i).bill_to_cust_account_id
            AND b.date_ordered = l_order_num_tbl(i).date_ordered
            AND b.resale_batch_id = p_resale_batch_id
         );

         -- ????  Consider recording order info in ozf_sales_transactions

         IF l_resale_int_tbl.EXISTS(1) THEN

            FOR k in 1..l_resale_int_tbl.LAST LOOP

               -- Create an order header for the order_NUMBER;
               IF k = 1 THEN
                  OZF_RESALE_COMMON_PVT.Insert_resale_header(
                     p_api_version       => 1
                     ,p_init_msg_list     => FND_API.G_FALSE
                     ,p_commit            => FND_API.G_FALSE
                     ,p_validation_level  => FND_API.G_VALID_LEVEL_FULL
                     ,p_line_int_rec      => l_resale_int_tbl(k)
                     ,x_header_id         => l_header_id
                     ,x_return_status     => l_return_status
                     ,x_msg_data          => l_msg_data
                     ,x_msg_count         => l_msg_count
                  );
                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               END IF;

               OZF_RESALE_COMMON_PVT.Insert_resale_line(
                  p_api_version       => 1
                 ,p_init_msg_list     => FND_API.G_FALSE
                 ,p_commit            => FND_API.G_FALSE
                 ,p_validation_level  => FND_API.G_VALID_LEVEL_FULL
                 ,p_line_int_rec      => l_resale_int_tbl(k)
                 ,p_header_id         => l_header_id
                 ,x_line_id           => l_line_id
                 ,x_return_status     => l_return_status
                 ,x_msg_data          => l_msg_data
                 ,x_msg_count         => l_msg_count
               );
               IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END LOOP;
         END IF;
      END LOOP;

      BEGIN
         UPDATE ozf_resale_lines_int
         SET status_code= OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_CLOSED
         WHERE direct_customer_flag ='F'
         AND status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_OPEN
         AND resale_batch_id = p_resale_batch_id;
      EXCEPTION
         WHEN OTHERS THEN
            ozf_utility_pvt.error_message('OZF_UPD_RESALE_INT_WRG');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;
   END IF;
   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': End');
   END IF;

   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO TP_ACCRUAL_MV_IC;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
        );
END Move_Indirect_Customer_Order;

---------------------------------------------------------------------
-- PROCEDURE
--    Process_Order
--
-- PURPOSE
--    Process order information. Only direct customer order will be simulated.
--    It is called by UI or concurrent program.
--
-- PARAMETERS
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE Process_Order(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id             IN    NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)IS
l_api_name          CONSTANT VARCHAR2(30) := 'Process_Order';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status              VARCHAR2(30);
l_msg_data                   VARCHAR2(2000);
l_msg_count                  NUMBER;

CURSOR order_num_csr IS
   SELECT DISTINCT order_NUMBER,
                   bill_to_cust_account_id,
                   date_ordered
   FROM ozf_resale_lines_int_all
   WHERE status_code IN ('OPEN', 'DUPLICATED')
   AND duplicated_adjustment_id IS NULL
   AND resale_batch_id = p_resale_batch_id
   ORDER BY date_ordered;

TYPE order_num_tbl_type IS TABLE OF order_num_csr%rowtype
INDEX BY binary_integer;

l_order_num_tbl              order_num_tbl_type;

CURSOR order_set_csr( p_order_number IN VARCHAR2,
                      p_id           IN NUMBER,
                      p_date         IN DATE
                    ) IS
SELECT *
FROM ozf_resale_lines_int_all
WHERE order_number = p_order_number
AND bill_to_cust_account_id= p_id
AND date_ordered = p_date
AND status_code IN ('OPEN', 'DUPLICATED')
AND duplicated_adjustment_id is NULL
AND resale_batch_id = p_resale_batch_id
AND tracing_flag = 'F';

TYPE resale_lines_tbl_type IS TABLE OF order_set_csr%rowtype
INDEX BY binary_integer;

l_order_set_tbl              resale_lines_tbl_type;

l_control_rec                QP_PREQ_GRP.CONTROL_RECORD_TYPE;

l_line_tbl                   OZF_ORDER_PRICE_PVT.LINE_REC_TBL_TYPE;
l_ldets_tbl                  OZF_ORDER_PRICE_PVT.LDETS_TBL_TYPE;
l_related_lines_tbl          OZF_ORDER_PRICE_PVT.RLTD_LINE_TBL_TYPE;

p                            NUMBER;
k                            NUMBER;

l_log_id                     NUMBER;

l_temp_count                 NUMBER;
l_temp_data                  VARCHAR2(2000);
l_price_flag                 VARCHAR2(1) := NULL;

--mkothari 13-dec-2006
l_list_price_override_flag   VARCHAR2(1) := NULL;

CURSOR dup_adjustments_csr( p_order_number IN VARCHAR2,
                            p_id           IN NUMBER,
                            p_date         IN DATE
                          ) IS
SELECT *
FROM ozf_resale_lines_int_all
WHERE order_number = p_order_number
AND bill_to_cust_account_id = p_id
AND date_ordered = p_date
AND status_code = 'DUPLICATED'
AND duplicated_adjustment_id IS NOT NULL
AND resale_batch_id = p_resale_batch_id
AND tracing_flag = 'F';

CURSOR tracing_data_csr( p_order_number IN VARCHAR2,
                         p_id           IN NUMBER,
                         p_date         IN DATE
                       ) IS
SELECT *
FROM ozf_resale_lines_int_all
WHERE order_number = p_order_number -- ?? need this
AND bill_to_cust_account_id = p_id -- ?? need this
AND date_ordered = p_date
AND status_code IN ('OPEN', 'DUPLICATED')
AND resale_batch_id = p_resale_batch_id
AND tracing_flag = 'T';

-- [BEGIN OF BUG 4233341 FIXING]
CURSOR csr_valid_line_count(cv_batch_id IN NUMBER) IS
  SELECT COUNT(1)
  FROM ozf_resale_lines_int_all
  WHERE status_code IN ('PROCESSED', 'CLOSED', 'DUPLICATED')
  AND resale_batch_id = cv_batch_id;

CURSOR csr_get_batch_number(cv_batch_id IN NUMBER) IS
  SELECT batch_number
  FROM ozf_resale_batches_all
  WHERE resale_batch_id = cv_batch_id;

l_valid_line_count           NUMBER;
l_batch_number               VARCHAR2(30);

CURSOR csr_out_dispute_pre_proc(cv_batch_id IN NUMBER) IS
   SELECT i.resale_line_int_id id
   ,      lk.meaning dispute_code
   ,      lg.error_message
   ,      lg.column_name
   ,      lg.column_value
   FROM ozf_resale_lines_int_all i
   , ozf_resale_logs_all lg
   , ozf_lookups lk
   WHERE i.dispute_code = lk.lookup_code(+)
   AND lk.lookup_type(+) = 'OZF_RESALE_DISPUTE_CODE'
   AND i.status_code = 'DISPUTED'
   AND i.resale_batch_id = cv_batch_id
   AND i.resale_line_int_id = lg.resale_id (+)
   ORDER BY i.resale_line_int_id;

TYPE output_dispute_line_tbl IS TABLE OF csr_out_dispute_pre_proc%ROWTYPE
INDEX BY BINARY_INTEGER;

l_output_dispute_line_tbl    output_dispute_line_tbl;
i_output_idx                 NUMBER;

/*
TYPE output_dispute_line_id_tbl IS
TABLE OF ozf_resale_lines_int_all.resale_line_int_id%TYPE
INDEX BY BINARY_INTEGER;

TYPE output_dispute_code_tbl IS
TABLE OF ozf_lookups.meaning%TYPE
INDEX BY BINARY_INTEGER;

TYPE output_dispute_bill_to_tbl IS
TABLE OF ozf_resale_lines_int_all.bill_to_party_name%TYPE
INDEX BY BINARY_INTEGER;

TYPE output_dispute_order_tbl IS
TABLE OF ozf_resale_lines_int_all.order_number%ROWTYPE
INDEX BY BINARY_INTEGER;

TYPE output_dispute_order_date_tbl IS
TABLE OF ozf_resale_lines_int_all.date_ordered%ROWTYPE
INDEX BY BINARY_INTEGER;

TYPE output_dispute_item_tbl IS
TABLE OF ozf_resale_lines_int_all.item_number%ROWTYPE
INDEX BY BINARY_INTEGER;

l_output_dispute_code_tbl       output_dispute_code_tbl;
l_output_dispute_bill_to_tbl    output_dispute_bill_to_tbl;
l_output_dispute_order_tbl      output_dispute_order_tbl;
l_output_dispute_order_date_tbl output_dispute_order_date_tbl;
l_output_dispute_item_tbl       output_dispute_item_tbl;
*/
-- [END OF BUG 4233341 FIXING]

l_lines_disputed             NUMBER;
l_calculated_amount          NUMBER;
l_total_accepted_amount      NUMBER;
l_total_allowed_amount       NUMBER;
l_total_disputed_amount      NUMBER;
l_total_claimed_amount       NUMBER;
l_status_code                VARCHAR2(30);

l_lines_invalid              NUMBER;
l_accrual_on_selling         VARCHAR2(3);
l_new_batch_status           VARCHAR2(30);
l_default_price_list_id      NUMBER;
  -- bug 6317120
  l_org_id                   NUMBER;
  -- end bug 6317120
BEGIN
   -- Standard BEGIN of API savepoint
   SAVEPOINT  Process_Order;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
      l_api_version,
      p_api_version,
      l_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Initialize message list if p_init_msg_list is TRUE.
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Call preprocess here.
   OZF_PRE_PROCESS_PVT.Resale_Pre_Process(
       p_api_version_number    => 1
      ,p_init_msg_list         => FND_API.G_FALSE
      ,p_commit                => FND_API.G_FALSE
      ,p_validation_level      => FND_API.G_VALID_LEVEL_FULL
      ,p_batch_id              => p_resale_batch_id
      ,x_batch_status          => l_new_batch_status
      ,x_return_status         => l_return_status
      ,x_msg_data              => l_msg_data
      ,x_msg_count             => l_msg_count
   );
   IF l_return_status <> FND_API.g_ret_sts_SUCCESS THEN
      ozf_utility_pvt.error_message('OZF_PRE_PROCESS_ERR');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- [BUG 4233341 FIXING]: add output file
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Disputed Interface Lines After Pre-Processing:');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Interface');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Line Id   Dispute Code                     Error                             Column Name          Column Value');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    --------- -------------------------------- --------------------------------  -------------------- ------------');

   --i_output_idx := 1;
   IF l_output_dispute_line_tbl.EXISTS(1) THEN
      l_output_dispute_line_tbl.DELETE;
   END IF;
   OPEN csr_out_dispute_pre_proc(p_resale_batch_id);
   FETCH csr_out_dispute_pre_proc BULK COLLECT INTO l_output_dispute_line_tbl;
   --LOOP
   --   FETCH csr_out_dispute_pre_proc INTO l_output_dispute_line_tbl(i_output_idx);
   --   EXIT WHEN csr_out_dispute_pre_proc%NOTFOUND;
   --   i_output_idx := i_output_idx + 1;
   --END LOOP;
   /*
   FETCH csr_out_dispute_pre_proc BULK COLLECT INTO l_output_dispute_code_tbl
                                                  , l_output_dispute_bill_to_tbl
                                                  , l_output_dispute_order_tbl
                                                  , l_output_dispute_order_date_tbl
                                                  , l_output_dispute_item_tbl;
   */
   CLOSE csr_out_dispute_pre_proc;

   FOR i_output_idx IN 1..l_output_dispute_line_tbl.COUNT LOOP
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    '
                       ||RPAD(l_output_dispute_line_tbl(i_output_idx).id, 10, ' ')
                       ||RPAD(l_output_dispute_line_tbl(i_output_idx).dispute_code, 33, ' ')
                       ||RPAD(l_output_dispute_line_tbl(i_output_idx).error_message, 34, ' ')
                       ||RPAD(l_output_dispute_line_tbl(i_output_idx).column_name, 21, ' ')
                       ||RPAD(l_output_dispute_line_tbl(i_output_idx).column_value, 15, ' ')
                       );
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    ');
   END LOOP;
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');

   -- remove all the disputed lines
   UPDATE ozf_resale_lines_int
   SET resale_batch_id = null
   ,   request_id = null -- [BUG 4233341 FIXING]
   Where resale_batch_id = p_resale_batch_id
   and status_code = 'DISPUTED';

   --  OK to do it here
   Move_Indirect_Customer_Order (
       p_api_version        => 1
      ,p_init_msg_list      => FND_API.G_FALSE
      ,p_commit             => FND_API.G_FALSE
      ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
      ,p_resale_batch_id    => p_resale_batch_id
      ,x_return_status      => l_return_status
      ,x_msg_data           => l_msg_data
      ,x_msg_count          => l_msg_count
   );
   IF l_return_status <> FND_API.g_ret_sts_SUCCESS THEN
      ozf_utility_pvt.error_message('OZF_MV_ID_CUST_ORDER_ERR');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Get profile value for price list
   l_default_price_list_id := G_TP_DEFAULT_PRICE_LIST; --fnd_profile.value('OZF_TP_ACCRUAL_PRICE_LIST');

   -- Define control rec
   -- setup pricing_event based on purpose code and profile
   -- privcing_event is based on profile

   -- We need to UPDATE the order FROM indirect customers so that they're not to be included in the
   -- pricing simulation;
   l_control_rec.pricing_event := G_PRICING_SIM_EVENT; --fnd_profile.value('OZF_PRICING_SIMULATION_EVENT');
   IF l_control_rec.pricing_event is NULL THEN
      l_control_rec.pricing_event := 'BATCH,BOOK,SHIP';
   ELSE
      IF l_control_rec.pricing_event = 'BATCH' THEN
         l_control_rec.pricing_event := 'BATCH';
      ELSIF l_control_rec.pricing_event = 'BOOK' THEN
         l_control_rec.pricing_event := 'BATCH,BOOK';
      ELSIF l_control_rec.pricing_event = 'SHIP' THEN
         l_control_rec.pricing_event := 'BATCH,BOOK,SHIP';
      END IF;
   END IF;

   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_PVT.debug_message('Event:' ||l_control_rec.pricing_event );
   END IF;

   l_control_rec.calculate_flag           := 'Y';
   l_control_rec.simulation_flag          := 'Y';
   l_control_rec.source_order_amount_flag := 'Y';
   l_control_rec.gsa_check_flag           := 'N';
   l_control_rec.gsa_dup_check_flag       := 'N';
   l_control_rec.temp_table_insert_flag   := 'N';

   --p := 1;
   IF l_order_num_tbl.EXISTS(1) THEN
      l_order_num_tbl.DELETE;
   END IF;
   OPEN order_num_csr;
   FETCH order_num_csr BULK COLLECT INTO l_order_num_tbl;
   --LOOP
   --   FETCH order_num_csr INTO l_order_num_tbl(p);
   --   EXIT when order_num_csr%notfound;
   --   p:= p+1;
   --END LOOP;
   CLOSE order_num_csr;

   IF l_order_num_tbl.EXISTS(1) THEN

      l_accrual_on_selling := fnd_profile.value('OZF_ACC_ON_SELLING_PRICE');

      -- If this profile is not set, we default the value to 'N'

      IF l_accrual_on_selling IS NULL THEN
         l_accrual_on_selling := 'N';
      END IF;

      -- convert the value of the profile to proper price flag value
      IF l_accrual_on_selling = 'Y' THEN
         --l_price_flag := 'G'; -- 'G' is not implemented in QP -- mkothari

         --mkothari 13-dec-2006
         l_price_flag := 'Y';
         l_list_price_override_flag := 'Y';

      ELSE
         l_price_flag := 'Y';
      END IF;

      IF OZF_DEBUG_LOW_ON THEN
         ozf_utility_PVT.debug_message('Price flag:' ||l_price_flag );
         ozf_utility_PVT.debug_message('List Price Override Flag:' ||l_list_price_override_flag);
      END IF;

      FOR i IN 1..l_order_num_tbl.LAST LOOP
         IF l_order_num_tbl(i).order_number IS NOT NULL AND
            l_order_num_tbl(i).bill_to_cust_account_id IS NOT NULL AND
            l_order_num_tbl(i).date_ordered IS NOT NULL THEN

            -- UPDATE tracing order lines to processed for this order to be processed
            UPDATE ozf_resale_lines_int_all
            SET status_code= 'PROCESSED'
            WHERE status_code = 'OPEN'
            AND order_number = l_order_num_tbl(i).order_number
            AND bill_to_cust_account_id = l_order_num_tbl(i).bill_to_cust_account_id
            AND date_ordered = l_order_num_tbl(i).date_ordered
            AND tracing_flag = 'T'
            AND resale_batch_id = p_resale_batch_id; -- bug 5222273

            QP_Price_Request_Context.Set_Request_Id;

            IF OZF_DEBUG_LOW_ON THEN
               ozf_utility_PVT.debug_message(l_api_name||'>> order_number = '||l_order_num_tbl(i).order_number||' (+)');
               ozf_utility_PVT.debug_message(l_api_name||'>> bill_to_cust_account_id = '||l_order_num_tbl(i).bill_to_cust_account_id);
            END IF;

            --k:=1;
            OPEN order_set_csr( l_order_num_tbl(i).order_number
                              , l_order_num_tbl(i).bill_to_cust_account_id
                              , l_order_num_tbl(i).date_ordered
                              );

            LOOP

              -- Before start process, clean up the data structures if necessary.
              IF l_order_set_tbl.EXISTS(1)     THEN l_order_set_tbl.DELETE; END IF;
              IF l_line_tbl.EXISTS(1)          THEN l_line_tbl.DELETE; END IF;
              IF l_ldets_tbl.EXISTS(1)         THEN l_ldets_tbl.DELETE; END IF;
              IF l_related_lines_tbl.EXISTS(1) THEN l_related_lines_tbl.DELETE; END IF;
              IF OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL.EXISTS(1) THEN OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL.DELETE; END IF;
              IF OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL.EXISTS(1) THEN OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL.DELETE; END IF;

              FETCH order_set_csr BULK COLLECT INTO l_order_set_tbl LIMIT G_BULK_LIMIT;
              IF l_order_set_tbl.FIRST IS NULL THEN
                 EXIT;
              END IF;
              --CLOSE order_set_csr;
/*
            FETCH order_set_csr BULK COLLECT INTO l_order_set_tbl;
            --LOOP
            --   FETCH order_set_csr INTO l_order_set_tbl(k);
            --   EXIT when order_set_csr%notfound;
            --   k := k+1;
            --END LOOP;
            CLOSE order_set_csr;
*/

              IF OZF_DEBUG_LOW_ON THEN
                 ozf_utility_PVT.debug_message(l_api_name||'>> order count = '||l_order_set_tbl.COUNT);
              END IF;

              FOR j IN l_order_set_tbl.FIRST .. l_order_set_tbl.LAST
              LOOP
                 --  Purge the any error message that might be there.
                 BEGIN
                    DELETE FROM ozf_resale_logs
                    WHERE resale_id = l_order_set_tbl(j).resale_line_int_id
                    AND   resale_id_type = 'IFACE';
                 EXCEPTION
                    WHEN OTHERS THEN
                       ozf_utility_pvt.error_message('OZF_DEL_RESALE_LOG_WRG');
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END;

                 IF OZF_DEBUG_LOW_ON THEN
                    ozf_utility_PVT.debug_message(l_api_name||'>> building order line for inteface id: '||l_order_set_tbl(j).resale_line_int_id);
                 END IF;

                 -- INSERT INTO l_line_tbl
                 l_line_tbl(j).line_index               := j;
                 l_line_tbl(j).line_id                  := l_order_set_tbl(j).resale_line_int_id;
                 l_line_tbl(j).line_type_code           := OZF_ORDER_PRICE_PVT.G_ORDER_LINE_TYPE;
                 l_line_tbl(j).pricing_effective_date   := l_order_set_tbl(j).date_ordered;
                 l_line_tbl(j).active_date_first        := l_order_set_tbl(j).date_ordered;
                 l_line_tbl(j).active_date_first_type   := 'ORD';
                 l_line_tbl(j).active_date_second       := l_order_set_tbl(j).date_shipped;
                 l_line_tbl(j).active_date_second_type  := 'SHIP';
                 l_line_tbl(j).line_quantity            := ABS(l_order_set_tbl(j).quantity); -- BUG 4581928
                 l_line_tbl(j).line_uom_code            := l_order_set_tbl(j).uom_code;
                 l_line_tbl(j).request_type_code        := 'ONT';
                 -- Pricing might be able to default it
                 --mkothari 13-dec-2006
                 --IF l_price_flag ='G' THEN
                 IF l_list_price_override_flag = 'Y' THEN
                    l_line_tbl(j).priced_quantity       := ABS(l_order_set_tbl(j).quantity); -- BUG 4581928
                    l_line_tbl(j).priced_uom_code       := l_order_set_tbl(j).uom_code;
                    l_line_tbl(j).unit_price            := l_order_set_tbl(j).selling_price;
                 END IF;
                 l_line_tbl(j).currency_code            := l_order_set_tbl(j).currency_code;
                 IF l_order_set_tbl(j).price_list_id IS NULL THEN
                    l_line_tbl(j).price_list_id         := l_default_price_list_id;
                 ELSE
                    l_line_tbl(j).price_list_id         := l_order_set_tbl(j).price_list_id;
                 END IF;
                 l_line_tbl(j).price_flag               := l_price_flag;
                 --mkothari 13-dec-2006
                 l_line_tbl(j).list_price_override_flag := l_list_price_override_flag;
                 l_line_tbl(j).pricing_status_code      := QP_PREQ_GRP.G_STATUS_UNCHANGED;
                 l_line_tbl(j).chargeback_int_id        := l_order_set_tbl(j).resale_line_int_id;
                 l_line_tbl(j).resale_table_type        := 'IFACE'; -- bug 5360598
                 --        l_line_tbl(j).UNIT_PRICE              := NULL;
                 --        l_line_tbl(j).PERCENT_PRICE           := NULL;
                 --        l_line_tbl(j).UOM_QUANTITY            := NULL;
                 --        l_line_tbl(j).ADJUSTED_UNIT_PRICE     := NULL;
                 --        l_line_tbl(j).UPD_ADJUSTED_UNIT_PRICE   NUMBER:= FND_API.G_MISS_NUM,
                 --        l_line_tbl(j).PROCESSED_FLAG            VARCHAR2(1):= FND_API.G_MISS_CHAR,
                 --        l_line_tbl(j).PROCESSING_ORDER          := NULL;
                 --        l_line_tbl(j).PRICING_STATUS_TEXT       := NULL;
                 --        l_line_tbl(j).ROUNDING_FLAG             := NULL;
                 --        l_line_tbl(j).ROUNDING_FACTOR             := NULL;
                 --        l_line_tbl(j).QUALIFIERS_EXIST_FLAG     := NULL;
                 --        l_line_tbl(j).PRICING_ATTRS_EXIST_FLAG  := NULL;
                 --        l_line_tbl(j).PL_VALIDATED_FLAG         := NULL;
                 --        l_line_tbl(j).PRICE_REQUEST_CODE        := NULL;
                 --        l_line_tbl(j).USAGE_PRICING_TYPE        := NULL;
                 --        l_line_tbl(j).LINE_CATEGORY             := NULL;

                 -- populate the order_price global line arrary
                 -- Here I only populate the values of the qualifiers for ONT.
                 -- The real global structure will be populate in ozf_order_price_pvt.
                 -- And it's value can be change in OZF_CHARGEBACK_ATTRMAP_PUB

                 OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).header_id                := l_order_set_tbl.LAST + 1;
                 OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).line_id                  := l_order_set_tbl(j).resale_line_int_id;
                 OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).line_type_id             := l_order_set_tbl(j).order_type_id;
                 OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).inventory_item_id        := l_order_set_tbl(j).inventory_item_id;
                 OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).ordered_quantity         := ABS(l_order_set_tbl(j).quantity); -- BUG 4581928
                 OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).order_quantity_uom       := l_order_set_tbl(j).uom_code;
                 OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).invoice_to_org_id        := l_order_set_tbl(j).bill_to_site_use_id;
                 OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).ship_to_org_id           := l_order_set_tbl(j).ship_to_site_use_id;
                 OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).sold_to_org_id           := l_order_set_tbl(j).bill_to_cust_account_id;
                 --OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).sold_from_org_id       := l_order_set_tbl(j).sold_from_cust_account_id;
                 OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).invoice_to_party_id      := l_order_set_tbl(j).bill_to_party_id;
                 OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).invoice_to_party_site_id := l_order_set_tbl(j).bill_to_party_site_id;
                 OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).ship_to_party_id         := l_order_set_tbl(j).ship_to_party_id;
                 OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).ship_to_party_site_id    := l_order_set_tbl(j).ship_to_party_site_id;
                 OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).price_list_id            := l_line_tbl(j).price_list_id;
                 OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).request_date             := l_order_set_tbl(j).date_ordered;
                 OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).actual_shipment_date     := l_order_set_tbl(j).date_shipped;
                 OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(j).pricing_date             := l_order_set_tbl(j).date_ordered;

                 -- R12 Populate Global Resale Structure (+)
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).batch_type                     := 'TP_ACCRUAL';
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).qp_context_request_id          := QP_Price_Request_Context.Get_Request_Id;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_index                     := l_line_tbl(j).line_index;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).resale_table_type              := 'IFACE';
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_id                        := l_order_set_tbl(j).resale_line_int_id;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).resale_transfer_type           := l_order_set_tbl(j).resale_transfer_type;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).product_transfer_movement_type := l_order_set_tbl(j).product_transfer_movement_type;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).product_transfer_date          := l_order_set_tbl(j).product_transfer_date;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).tracing_flag                   := l_order_set_tbl(j).tracing_flag;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).sold_from_cust_account_id      := l_order_set_tbl(j).sold_from_cust_account_id;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).sold_from_site_id              := l_order_set_tbl(j).sold_from_site_id;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).sold_from_contact_party_id     := l_order_set_tbl(j).sold_from_contact_party_id;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).ship_from_cust_account_id      := l_order_set_tbl(j).ship_from_cust_account_id;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).ship_from_site_id              := l_order_set_tbl(j).ship_from_site_id;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).ship_from_contact_party_id     := l_order_set_tbl(j).ship_from_contact_party_id;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).bill_to_party_id               := l_order_set_tbl(j).bill_to_party_id;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).bill_to_party_site_id          := l_order_set_tbl(j).bill_to_party_site_id;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).bill_to_contact_party_id       := l_order_set_tbl(j).bill_to_contact_party_id;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).ship_to_party_id               := l_order_set_tbl(j).ship_to_party_id;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).ship_to_party_site_id          := l_order_set_tbl(j).ship_to_party_site_id;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).ship_to_contact_party_id       := l_order_set_tbl(j).ship_to_contact_party_id;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).end_cust_party_id              := l_order_set_tbl(j).end_cust_party_id;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).end_cust_site_use_id           := l_order_set_tbl(j).end_cust_site_use_id;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).end_cust_site_use_code         := l_order_set_tbl(j).end_cust_site_use_code;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).end_cust_party_site_id         := l_order_set_tbl(j).end_cust_party_site_id;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).end_cust_contact_party_id      := l_order_set_tbl(j).end_cust_contact_party_id;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).data_source_code               := l_order_set_tbl(j).data_source_code;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute_category      := l_order_set_tbl(j).header_attribute_category;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute1              := l_order_set_tbl(j).header_attribute1;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute2              := l_order_set_tbl(j).header_attribute2;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute3              := l_order_set_tbl(j).header_attribute3;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute4              := l_order_set_tbl(j).header_attribute4;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute5              := l_order_set_tbl(j).header_attribute5;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute6              := l_order_set_tbl(j).header_attribute6;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute7              := l_order_set_tbl(j).header_attribute7;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute8              := l_order_set_tbl(j).header_attribute8;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute9              := l_order_set_tbl(j).header_attribute9;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute10             := l_order_set_tbl(j).header_attribute10;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute11             := l_order_set_tbl(j).header_attribute11;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute12             := l_order_set_tbl(j).header_attribute12;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute13             := l_order_set_tbl(j).header_attribute13;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute14             := l_order_set_tbl(j).header_attribute14;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).header_attribute15             := l_order_set_tbl(j).header_attribute15;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute_category        := l_order_set_tbl(j).line_attribute_category;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute1                := l_order_set_tbl(j).line_attribute1;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute2                := l_order_set_tbl(j).line_attribute2;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute3                := l_order_set_tbl(j).line_attribute3;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute4                := l_order_set_tbl(j).line_attribute4;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute5                := l_order_set_tbl(j).line_attribute5;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute6                := l_order_set_tbl(j).line_attribute6;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute7                := l_order_set_tbl(j).line_attribute7;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute8                := l_order_set_tbl(j).line_attribute8;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute9                := l_order_set_tbl(j).line_attribute9;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute10               := l_order_set_tbl(j).line_attribute10;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute11               := l_order_set_tbl(j).line_attribute11;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute12               := l_order_set_tbl(j).line_attribute12;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute13               := l_order_set_tbl(j).line_attribute13;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute14               := l_order_set_tbl(j).line_attribute14;
                 OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(j).line_attribute15               := l_order_set_tbl(j).line_attribute15;
                 -- R12 Populate Global Resale Structure (-)

              END LOOP; ---FOR i IN l_order_set_tbl.FIRST .. l_order_set_tbl.LAST


              IF OZF_DEBUG_LOW_ON THEN
                 ozf_utility_PVT.debug_message(l_api_name||'>> building order header');
              END IF;

              -- build summary line
              k := l_order_set_tbl.LAST + 1;
              l_line_tbl(k).line_index                := k;
              l_line_tbl(k).line_id                   := NULL;
              l_line_tbl(k).line_type_code            := OZF_ORDER_PRICE_PVT.G_ORDER_HEADER_TYPE;
              l_line_tbl(k).pricing_effective_date    := l_order_set_tbl(1).date_ordered;
              l_line_tbl(k).active_date_first         := l_order_set_tbl(1).date_ordered;
              l_line_tbl(k).active_date_first_type    := 'ORD'; -- Change because of ONT QP order 'NO TYPE';
              l_line_tbl(k).active_date_second        := l_order_set_tbl(1).date_shipped;
              l_line_tbl(k).active_date_second_type   := 'SHIP'; -- change because of ONT QP order 'NO TYPE';
              l_line_tbl(k).request_type_code         := 'ONT';
              l_line_tbl(k).currency_code             := l_order_set_tbl(1).currency_code;
              l_line_tbl(k).price_list_id             := l_line_tbl(1).price_list_id;
              l_line_tbl(k).price_flag                := l_price_flag;

              --mkothari 13-dec-2006
              l_line_tbl(k).list_price_override_flag  := l_list_price_override_flag;
              l_line_tbl(k).pricing_status_code       := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              l_line_tbl(k).chargeback_int_id         := l_order_set_tbl(1).resale_line_int_id;
              l_line_tbl(k).resale_table_type         := 'IFACE'; -- bug 5360598

              --      l_line_tbl(k).LINE_QUANTITY       := NULL;
              --      l_line_tbl(k).LINE_UOM_CODE       := NULL;
              --      l_line_tbl(k).PRICED_QUANTITY        := NULL;
              --      l_line_tbl(k).PRICED_UOM_CODE        := NULL;
              --      l_line_tbl(j).UNIT_PRICE              := l_order_set_tbl(j).
              --      l_line_tbl(j).PERCENT_PRICE           := l_order_set_tbl(j).
              --      l_line_tbl(j).UOM_QUANTITY            := l_order_set_tbl(j).
              --      l_line_tbl(j).ADJUSTED_UNIT_PRICE     := l_order_set_tbl(j).
              --      l_line_tbl(j).UPD_ADJUSTED_UNIT_PRICE   NUMBER:= FND_API.G_MISS_NUM,
              --      l_line_tbl(j).PROCESSED_FLAG            VARCHAR2(1):= FND_API.G_MISS_CHAR,
              --      l_line_tbl(j).PROCESSING_ORDER          := NULL;
              --      l_line_tbl(j).PRICING_STATUS_TEXT       := NULL;
              --      l_line_tbl(j).ROUNDING_FLAG             := NULL;
              --      l_line_tbl(j).ROUNDING_FACTOR            := NULL;
              --      l_line_tbl(j).QUALIFIERS_EXIST_FLAG     := NULL;
              --      l_line_tbl(j).PRICING_ATTRS_EXIST_FLAG  := NULL;
              --      l_line_tbl(j).PL_VALIDATED_FLAG         := NULL;
              --      l_line_tbl(j).PRICE_REQUEST_CODE        := NULL;
              --      l_line_tbl(j).USAGE_PRICING_TYPE        := NULL;
              --      l_line_tbl(j).LINE_CATEGORY             := NULL;

              -- populate the order_price global header structure
              -- Here I only populate the values of the qualifiers for ONT.
              -- The real global structure will be populate in ozf_order_price_pvt.
              -- And it's value can be change in OZF_CHARGEBACK_ATTRMAP_PUB

              -- Might be able to add more value here.
              OZF_ORDER_PRICE_PVT.G_HEADER_REC.header_id                := k;
              OZF_ORDER_PRICE_PVT.G_HEADER_REC.order_type_id            := l_order_set_tbl(1).order_type_id;
              OZF_ORDER_PRICE_PVT.G_HEADER_REC.sold_to_org_id           := l_order_set_tbl(1).bill_to_cust_account_id;
              OZF_ORDER_PRICE_PVT.G_HEADER_REC.invoice_to_org_id        := l_order_set_tbl(1).bill_to_site_use_id;
              OZF_ORDER_PRICE_PVT.G_HEADER_REC.ship_to_org_id           := l_order_set_tbl(1).ship_to_site_use_id;
              OZF_ORDER_PRICE_PVT.G_HEADER_REC.invoice_to_party_id      := l_order_set_tbl(1).bill_to_party_id;
              OZF_ORDER_PRICE_PVT.G_HEADER_REC.invoice_to_party_site_id := l_order_set_tbl(1).bill_to_party_site_id;
              OZF_ORDER_PRICE_PVT.G_HEADER_REC.ship_to_party_id         := l_order_set_tbl(1).ship_to_party_id;
              OZF_ORDER_PRICE_PVT.G_HEADER_REC.ship_to_party_site_id    := l_order_set_tbl(1).ship_to_party_site_id;
              OZF_ORDER_PRICE_PVT.G_HEADER_REC.price_list_id            := l_line_tbl(1).price_list_id;
              OZF_ORDER_PRICE_PVT.G_HEADER_REC.ordered_date             := l_order_set_tbl(1).date_ordered;
              OZF_ORDER_PRICE_PVT.G_HEADER_REC.request_date             := l_order_set_tbl(1).date_ordered;
              OZF_ORDER_PRICE_PVT.G_HEADER_REC.pricing_date             := l_order_set_tbl(1).date_ordered;

              IF OZF_DEBUG_LOW_ON THEN
                 ozf_utility_PVT.debug_message(l_api_name||'>> Calling Get_Order_');
              END IF;

              OZF_ORDER_PRICE_PVT.Get_Order_Price (
                 p_api_version             => 1.0
                 ,p_init_msg_list          => FND_API.G_FALSE
                 ,p_commit                 => FND_API.G_FALSE
                 ,p_validation_level       => FND_API.G_VALID_LEVEL_FULL
                 ,x_return_status          => l_return_status
                 ,x_msg_data               => l_msg_data
                 ,x_msg_count              => l_msg_count
                 ,p_control_rec            => l_control_rec
                 ,xp_line_tbl              => l_line_tbl
                 ,x_ldets_tbl              => l_ldets_tbl
                 ,x_related_lines_tbl      => l_related_lines_tbl
              );
              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 ozf_utility_pvt.error_message('OZF_GET_ORDER_PRIC_ERR');

                 BEGIN
                    UPDATE ozf_resale_lines_int
                    SET status_code = 'DISPUTED'
                    WHERE status_code = 'OPEN'
                    AND order_number = l_order_num_tbl(i).order_number
                    AND bill_to_cust_account_id = l_order_num_tbl(i).bill_to_cust_account_id
                    AND date_ordered = l_order_num_tbl(i).date_ordered
                    AND resale_batch_id = p_resale_batch_id;
                 EXCEPTION
                    WHEN OTHERS THEN
                       ozf_utility_pvt.error_message('OZF_UPD_RESALE_INT_WRG');
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END;

                 FOR p in 1..l_order_set_tbl.LAST
                 LOOP
                    BEGIN
                       OPEN OZF_RESALE_COMMON_PVT.g_log_id_csr;
                       FETCH OZF_RESALE_COMMON_PVT.g_log_id_csr INTO l_log_id;
                       CLOSE OZF_RESALE_COMMON_PVT.g_log_id_csr;

                       -- julou bug 6317120. get org_id from table
                       OPEN  OZF_RESALE_COMMON_PVT.gc_iface_org_id(l_order_set_tbl(p).resale_line_int_id);
                       FETCH OZF_RESALE_COMMON_PVT.gc_iface_org_id INTO l_org_id;
                       CLOSE OZF_RESALE_COMMON_PVT.gc_iface_org_id;

                       OZF_RESALE_LOGS_PKG.Insert_Row(
                            px_resale_log_id       => l_log_id,
                            p_resale_id            => l_order_set_tbl(p).resale_line_int_id,
                            p_resale_id_type       => 'IFACE',
                            p_error_code           => 'OZF_GET_ORDER_PRIC_ERR',
                            p_error_message        => FND_MESSAGE.get_string('OZF','OZF_GET_ORDER_PRIC_ERR'),
                            p_column_name          => NULL,
                            p_column_value         => NULL,
                            --px_org_id              => OZF_RESALE_COMMON_PVT.g_org_id
                            px_org_id              => l_org_id
                       );
                    EXCEPTION
                       WHEN OTHERS THEN
                          ozf_utility_pvt.error_message('OZF_INS_RESALE_LOG_WRG');
                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END;
                 END LOOP;

                 IF OZF_DEBUG_LOW_ON THEN
                    ozf_utility_PVT.debug_message(l_api_name||'>> Get_Order_Price Failed!');
                 END IF;

                 GOTO END_LOOP;
              END IF;

              Process_Pricing_Result(
                 p_resale_batch_id => p_resale_batch_id,
                 p_line_tbl        => l_line_tbl,
                 p_caller_type     => 'IFACE',
                 x_return_status   => l_return_status
              );
              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 FND_MSG_PUB.Count_And_Get (
                     p_encoded => FND_API.G_FALSE,
                     p_count => l_temp_count,
                     p_data  => l_temp_data
                 );

                 FND_MSG_PUB.Get(
                     p_msg_index      => l_temp_count,
                     p_encoded        => FND_API.G_FALSE,
                     p_data           => l_temp_data,
                     p_msg_index_out  => l_temp_count
                 );

                 FOR p in 1..l_order_set_tbl.LAST LOOP
                    BEGIN
                       OPEN OZF_RESALE_COMMON_PVT.g_log_id_csr;
                       FETCH OZF_RESALE_COMMON_PVT.g_log_id_csr INTO l_log_id;
                       CLOSE OZF_RESALE_COMMON_PVT.g_log_id_csr;

                       -- julou bug 6317120. get org_id from table
                       OPEN  OZF_RESALE_COMMON_PVT.gc_iface_org_id(l_order_set_tbl(p).resale_line_int_id);
                       FETCH OZF_RESALE_COMMON_PVT.gc_iface_org_id INTO l_org_id;
                       CLOSE OZF_RESALE_COMMON_PVT.gc_iface_org_id;

                       OZF_RESALE_LOGS_PKG.Insert_Row(
                         px_resale_log_id           => l_log_id,
                         p_resale_id                => l_order_set_tbl(p).resale_line_int_id,
                         p_resale_id_type           => 'IFACE',
                         p_error_code               => 'OZF_PRIC_RESULT_ERR',
                         p_error_message            => FND_MESSAGE.get_string('OZF','OZF_PRIC_RESULT_ERR'),
                         p_column_name              => NULL,
                         p_column_value             => NULL,
                         --px_org_id                  => OZF_RESALE_COMMON_PVT.g_org_id
                         px_org_id                  => l_org_id
                       );
                    EXCEPTION
                      WHEN OTHERS THEN
                         ozf_utility_pvt.error_message('OZF_INS_RESALE_LOG_WRG');
                    END;
                 END LOOP;

                 BEGIN
                    UPDATE ozf_resale_lines_int_all
                    SET status_code = 'DISPUTED'
                    WHERE status_code = 'OPEN'
                    AND order_number = l_order_num_tbl(i).order_number
                    AND bill_to_cust_account_id = l_order_num_tbl(i).bill_to_cust_account_id
                    AND date_ordered = l_order_num_tbl(i).date_ordered
                    AND resale_batch_id = p_resale_batch_id;
                 EXCEPTION
                    WHEN OTHERS THEN
                    ozf_utility_pvt.error_message('OZF_UPD_RESALE_INT_WRG');
                 END;

                 GOTO END_LOOP;
              END IF;
  /*  ????????????
             -- non tracing data and non dup data process successful
             IF l_header_id is NULL THEN
                -- create a header_id for duplicated adjs and tracing_data
             END IF;

             OPEN dup adjustment

        create link between batch_id and duplicated_line_id

        OPEN tracing
        If status_code = duplicated then
           create a link between batch_id and duplicated_line_id
        else
           create a line and a link.
        END

  */



                  IF OZF_DEBUG_LOW_ON THEN
                     ozf_utility_PVT.debug_message(l_api_name||'>>- Success and Committed: Processing order for order number:'||l_order_num_tbl(i).order_number||'(-)');
                     ozf_utility_PVT.debug_message(l_api_name||'>>- and customer:'||l_order_num_tbl(i).bill_to_cust_account_id||'(-)');
                  END IF;

                  -- commit the data created by processing these G_BULK_LIMIT (default 500) lines
                  IF G_ALLOW_INTER_COMMIT = 'Y' THEN
                     COMMIT;
                  END IF;

                  << END_LOOP >>
                  null;

           EXIT WHEN order_set_csr%NOTFOUND;
         END LOOP; -- OPEN order_set_csr
         CLOSE order_set_csr;
         END IF; -- END if for order_NUMBER, bill_to cust not NULL
      END LOOP; -- END LOOP FOR l_order_num_tbl

   ELSE --    IF l_order_num_tbl.EXISTS(1) THEN

      IF OZF_DEBUG_LOW_ON THEN
         ozf_utility_PVT.debug_message(l_api_name||'>> No Order to process <<');
      END IF;
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    There is no valid order to process.');

   END IF; --   IF l_order_num_tbl.EXISTS(1) THEN


   -- [BUG 4233341 FIXING]: add output file
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Disputed Lines After Processing Order:');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Interface');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Line Id   Dispute Code                     Error                             Column Name          Column Value');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    --------- -------------------------------- --------------------------------  -------------------- ------------');

   --i_output_idx := 1;
   IF l_output_dispute_line_tbl.EXISTS(1) THEN
      l_output_dispute_line_tbl.DELETE;
   END IF;
   OPEN csr_out_dispute_pre_proc(p_resale_batch_id);
   FETCH csr_out_dispute_pre_proc BULK COLLECT INTO l_output_dispute_line_tbl;
   --LOOP
   --   FETCH csr_out_dispute_pre_proc INTO l_output_dispute_line_tbl(i_output_idx);
   --   EXIT WHEN csr_out_dispute_pre_proc%NOTFOUND;
   --   i_output_idx := i_output_idx + 1;
   --END LOOP;
   /*
   FETCH csr_out_dispute_pre_proc BULK COLLECT INTO l_output_dispute_code_tbl
                                                  , l_output_dispute_bill_to_tbl
                                                  , l_output_dispute_order_tbl
                                                  , l_output_dispute_order_date_tbl
                                                  , l_output_dispute_item_tbl;
   */
   CLOSE csr_out_dispute_pre_proc;

   FOR i_output_idx IN 1..l_output_dispute_line_tbl.COUNT LOOP
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    '
                       ||RPAD(l_output_dispute_line_tbl(i_output_idx).id, 10, ' ')
                       ||RPAD(l_output_dispute_line_tbl(i_output_idx).dispute_code, 33, ' ')
                       ||RPAD(l_output_dispute_line_tbl(i_output_idx).error_message, 34, ' ')
                       ||RPAD(l_output_dispute_line_tbl(i_output_idx).column_name, 21, ' ')
                       ||RPAD(l_output_dispute_line_tbl(i_output_idx).column_value, 15, ' ')
                       );
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    ');
   END LOOP;
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');

   -- [BEGIN OF BUG 4233341 FIXING]
   -- delink all the new/processed/disputed lines
   UPDATE ozf_resale_lines_int_all
   SET resale_batch_id = null
   ,   request_id = null
   WHERE resale_batch_id = p_resale_batch_id
   AND status_code IN ('NEW', 'OPEN', 'DISPUTED'); -- 'PROCESSED'

   OPEN csr_valid_line_count(p_resale_batch_id);
   FETCH csr_valid_line_count INTO l_valid_line_count;
   CLOSE csr_valid_line_count;

   IF l_valid_line_count > 0 THEN
      -- close this batch
      UPDATE ozf_resale_batches_all
      SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_CLOSED
      ,   batch_count = l_valid_line_count
      WHERE resale_batch_id = p_resale_batch_id;

      OPEN csr_get_batch_number(p_resale_batch_id);
      FETCH csr_get_batch_number INTO l_batch_number;
      CLOSE csr_get_batch_number;

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Batch Successfully Created and Closed:');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '               Batch Number: '||l_batch_number);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '     Successfully Processed: '||l_valid_line_count);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');

   ELSE
      DELETE FROM ozf_resale_batches_all
      WHERE resale_batch_id = p_resale_batch_id;
   END IF;
   -- [END OF BUG 4233341 FIXING]


   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': end');
   END IF;
   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Process_Order;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Process_Order;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
END Process_Order;


---------------------------------------------------------------------
-- PROCEDURE
--    Process_TP_ACCRUAL
--
-- PURPOSE
--    This function is for backword compatable. It is called by the concurrent program.
--
--
-- PARAMETERS
--
--
-- NOTES
--
-- HISTORY
-- SEP-02-2008   ateotia    bug # 7375849 fixed. FP:11510-R12 7369835
--                          THIRD PARTY ACCRUAL FROM INTERFACE TABLE FINSIHES WITH ERROR
---------------------------------------------------------------------
PROCEDURE Process_TP_ACCRUAL (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_data_source_code       IN  VARCHAR2 := NULL
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Process_TP_ACCRUAL';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     VARCHAR2(30);
l_msg_data          VARCHAR2(2000);
l_msg_count         NUMBER;

/*
CURSOR batch_set_csr(p_data_source_code in VARCHAR2,
                     p_start_date in date,
                     p_END_date in date) IS
SELECT resale_batch_id
FROM ozf_resale_batches
WHERE data_source_code = p_data_source_code;
*/

TYPE batch_set_tbl_type is TABLE OF NUMBER INDEX BY binary_integer;
l_batch_tbl batch_set_tbl_type;

i NUMBER:=1;

CURSOR account_id_csr (p_id NUMBER)IS
SELECT distinct sold_from_cust_account_id, org_id, currency_code
FROM ozf_resale_lines_int
WHERE resale_batch_id IS NULL
AND request_id = p_id;

l_sold_from_cust_id_tbl OZF_RESALE_COMMON_PVT.number_tbl_type;

-- bug # 7375849 fixed by ateotia (+)
--l_sold_from_cust_name_tbl OZF_RESALE_COMMON_PVT.varchar_tbl_type;
TYPE varchar_tbl_type IS TABLE OF VARCHAR2(360) INDEX BY BINARY_INTEGER;
l_sold_from_cust_name_tbl varchar_tbl_type;
-- bug # 7375849 fixed by ateotia (-)

l_org_id_tbl   OZF_RESALE_COMMON_PVT.number_tbl_type;
l_currency_code_tbl OZF_RESALE_COMMON_PVT.varchar_tbl_type;

CURSOR party_id_csr(p_id number)IS
SELECT hca.party_id
-- bug # 7375849 fixed by ateotia (+)
--, substr(hp.party_name, 1,30)
, hp.party_name
-- bug # 7375849 fixed by ateotia (-)
FROM hz_cust_accounts hca
, hz_parties hp
WHERE hca.cust_account_id = p_id
AND hca.party_id = hp.party_id;

l_party_id  number;
l_party_name  varchar2(360);

l_obj_number NUMBER := 1.0;

CURSOR resale_batch_id_csr IS
SELECT ozf_resale_batches_all_s.nextval
  FROM dual;
l_resale_batch_id NUMBER;

CURSOR resale_batch_number_csr IS
SELECT to_char(ozf_resale_batch_number_s.nextval)
  FROM dual;
l_resale_batch_number VARCHAR2(30);

CURSOR line_info_csr(p_id NUMBER,
                     p_org_id NUMBER,
                     p_currency_code VARCHAR2) IS
SELECT orli.created_from
     , orli.data_source_code
     , orli.sold_from_cust_account_id
     , orli.sold_from_site_id
     , orli.sold_from_contact_party_id
     , orli.sold_from_contact_name
     , orli.sold_from_email
     , orli.sold_from_phone
     , orli.sold_from_fax
     ,orli.currency_code
FROM  ozf_resale_lines_int orli
WHERE orli.resale_batch_id IS NULL
AND orli.sold_from_cust_account_id = p_id
AND orli.request_id = G_CONC_REQUEST_ID
AND orli.org_id = p_org_id
AND orli.currency_code = p_currency_code
AND rownum = 1;

l_created_from                   VARCHAR2(30);
l_data_source_code               VARCHAR2(30);
l_sold_from_cust_account_id      NUMBER;
l_sold_from_site_id              NUMBER;
l_sold_from_contact_party_id     NUMBER;
l_sold_from_contact_name         VARCHAR2(240);
l_sold_from_email                VARCHAR2(240);
l_sold_from_phone                VARCHAR2(240);
l_sold_from_fax                  VARCHAR2(240);
l_currency_code                  VARCHAR2(30);

CURSOR start_end_date_csr(  p_account_id NUMBER,
                        p_org_id NUMBER,
                        p_currency_code VARCHAR2) IS
SELECT MIN(date_ordered), MAX(date_ordered)
FROM ozf_resale_lines_int_all
WHERE sold_from_cust_account_id = p_account_id
AND   request_id = FND_GLOBAL.CONC_REQUEST_ID
AND   org_id = p_org_id
AND   currency_code = p_currency_code;

l_start_date date;
l_end_date date;

BEGIN
   -- Standard BEGIN of API savepoint
   SAVEPOINT  Process_TP_ACCRUAL;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
      l_api_version,
      p_api_version,
      l_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Initialize message list if p_init_msg_list is TRUE.
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': Start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

/*
   IF p_data_source_code is NULL THEN
      ozf_utility_pvt.error_message('OZF_RESALE_TP_SOURCE_NULL');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
*/

   -- Mark all the records that will be processed.
   IF p_data_source_code is null OR
      p_data_source_code = 'ALL' THEN

      IF p_data_source_code is null THEN
         IF OZF_DEBUG_LOW_ON THEN
            ozf_utility_PVT.debug_message('source code is null, id:' || FND_GLOBAL.CONC_REQUEST_ID );
         END IF;
      ELSE
         IF OZF_DEBUG_LOW_ON THEN
            ozf_utility_PVT.debug_message('source code is '|| p_data_source_code||', id:' || FND_GLOBAL.CONC_REQUEST_ID  );
         END IF;
      END IF;
      UPDATE ozf_resale_lines_int_all
      SET   request_id = G_CONC_REQUEST_ID
      ,     dispute_code = null
      ,     program_application_id = FND_GLOBAL.PROG_APPL_ID
      ,     program_update_date = SYSDATE
      ,     program_id = FND_GLOBAL.CONC_PROGRAM_ID
      WHERE resale_batch_id IS NULL
      AND request_id IS NULL
      AND org_id = MO_GLOBAL.get_current_org_id();

   ELSE
      IF OZF_DEBUG_LOW_ON THEN
         ozf_utility_PVT.debug_message('source code is '|| p_data_source_code||', id:' || FND_GLOBAL.CONC_REQUEST_ID  );
      END IF;
      UPDATE ozf_resale_lines_int_all
      SET   request_id = G_CONC_REQUEST_ID
      ,     dispute_code = null
      ,     program_application_id = FND_GLOBAL.PROG_APPL_ID
      ,     program_update_date = SYSDATE
      ,     program_id = FND_GLOBAL.CONC_PROGRAM_ID
      WHERE resale_batch_id IS NULL
      AND data_source_code = p_data_source_code
      AND request_id IS NULL
      AND org_id = MO_GLOBAL.get_current_org_id();
   END IF;

   DELETE FROM ozf_resale_logs_all
   WHERE resale_id IN (SELECT resale_line_int_id
                       FROM ozf_resale_lines_int
                       WHERE request_id = G_CONC_REQUEST_ID)
   AND resale_id_type = 'IFACE';

   -- [BUG 4233341 FIXING: Add program output file]
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Request Id                 : '||G_CONC_REQUEST_ID);
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Data Source Code           : '||p_data_source_code);
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*------------------------------------------------------------------------------------------------------*');

   -- list of partner_party_id based on the sold_from_cust_account_id
   --Add org_id, currency_code
   OPEN account_id_csr(G_CONC_REQUEST_ID);
   FETCH account_id_csr BULK COLLECT INTO l_sold_from_cust_id_tbl, l_org_id_tbl, l_currency_code_tbl;
   CLOSE account_id_csr;

   IF l_sold_from_cust_id_tbl.exists(1) THEN
      FOR j in 1..l_sold_from_cust_id_tbl.LAST LOOP

         l_party_id := NULL;
         l_party_name := NULL;

         OPEN party_id_csr (l_sold_from_cust_id_tbl(j));
         FETCH party_id_csr into l_party_id, l_party_name;
         CLOSE party_id_csr;

         --create a batch header with resale_batch_id
         OPEN resale_batch_id_csr;
         FETCH resale_batch_id_csr into l_resale_batch_id;
         CLOSE resale_batch_id_csr;

         OPEN resale_batch_number_csr;
         FETCH resale_batch_number_csr into l_resale_batch_number;
         CLOSE resale_batch_number_csr;

         -- get one line
         OPEN line_info_csr(l_sold_from_cust_id_tbl(j),
                            l_org_id_tbl(j),
                            l_currency_code_tbl(j));
         FETCH line_info_csr INTO   l_created_from,
                                    l_data_source_code,
                                    l_sold_from_cust_account_id,
                                    l_sold_from_site_id,
                                    l_sold_from_contact_party_id,
                                    l_sold_from_contact_name,
                                    l_sold_from_email,
                                    l_sold_from_phone,
                                    l_sold_from_fax,
                                    l_currency_code;
         CLOSE line_info_csr;

         OPEN start_end_date_csr(l_sold_from_cust_id_tbl(j),
                            l_org_id_tbl(j),
                            l_currency_code_tbl(j));
         FETCH start_end_date_csr into l_start_date, l_end_date;
         CLOSE start_end_date_csr;

         OZF_RESALE_BATCHES_PKG.Insert_Row(
            px_resale_batch_id         => l_resale_batch_id,
            px_object_version_number   => l_obj_number,
            p_last_update_date         => SYSdate,
            p_last_updated_by          => NVL(FND_GLOBAL.user_id,-1),
            p_creation_date            => SYSdate,
            p_request_id               => G_CONC_REQUEST_ID,
            p_created_by               => NVL(FND_GLOBAL.user_id,-1),
            p_last_update_login        => NVL(FND_GLOBAL.conc_login_id,-1),
            p_program_application_id   => FND_GLOBAL.PROG_APPL_ID,
            p_program_update_date      => SYSdate,
            p_program_id               => FND_GLOBAL.CONC_PROGRAM_ID,
            p_created_from             => l_created_from,
            p_batch_number             => l_resale_batch_number,
            p_batch_type               => OZF_RESALE_COMMON_PVT.G_TP_ACCRUAL,
            p_batch_count              => NULL,
            p_year                     => NULL,
            p_month                    => NULL,
            p_report_date              => trunc(sysdate),
            p_report_start_date        => trunc(l_start_date),
            p_report_end_date          => trunc(l_end_date),
            p_status_code              => OZF_RESALE_COMMON_PVT.G_BATCH_NEW,
            p_data_source_code         => l_data_source_code,
            p_reference_type           => NULL,
            p_reference_number         => NULL,
            p_comments                 => NULL,
            p_partner_claim_number     => NULL,
            p_transaction_purpose_code => NULL,
            p_transaction_type_code    => NULL,
            p_partner_type             => NULL,
            p_partner_id               => NULL,
            p_partner_party_id         => l_party_id,
            p_partner_cust_account_id  => l_sold_from_cust_id_tbl(j) ,
            p_partner_site_id          => l_sold_from_site_id,
            p_partner_contact_party_id => l_sold_from_contact_party_id ,
            p_partner_contact_name     => l_sold_from_contact_name,
            p_partner_email            => l_sold_from_email,
            p_partner_phone            => l_sold_from_phone,
            p_partner_fax              => l_sold_from_fax,
            p_header_tolerance_operand    => NULL,
            p_header_tolerance_calc_code  => NULL,
            p_line_tolerance_operand      => NULL,
            p_line_tolerance_calc_code    => NULL,
            p_currency_code               => l_currency_code_tbl(j),
            p_claimed_amount      => NULL,
            p_allowed_amount      => NULL,
            p_paid_amount         => NULL,
            p_disputed_amount     => NULL,
            p_accepted_amount     => NULL,
            p_lines_invalid       => NULL,
            p_lines_w_tolerance   => NULL,
            p_lines_disputed      => NULL,
            p_batch_set_id_code   => NULL,
            p_credit_code         => NULL,
            p_credit_advice_date  => NULL,
            p_purge_flag          => NULL,
            p_attribute_category  => NULL,
            p_attribute1     => NULL,
            p_attribute2     => NULL,
            p_attribute3     => NULL,
            p_attribute4     => NULL,
            p_attribute5     => NULL,
            p_attribute6     => NULL,
            p_attribute7     => NULL,
            p_attribute8     => NULL,
            p_attribute9     => NULL,
            p_attribute10    => NULL,
            p_attribute11    => NULL,
            p_attribute12    => NULL,
            p_attribute13    => NULL,
            p_attribute14    => NULL,
            p_attribute15    => NULL,
            px_org_id        => l_org_id_tbl(j));

         l_batch_tbl(i) := l_resale_batch_id;
         l_sold_from_cust_name_tbl(i) := l_party_name;
         i := i +1;

         UPDATE ozf_resale_lines_int_all orli
         SET  resale_batch_id = l_resale_batch_id
         WHERE orli.sold_from_cust_account_id = l_sold_from_cust_id_tbl(j)
         AND   orli.org_id = l_org_id_tbl(j)
         AND   orli.currency_code = l_currency_code_tbl(j)
         AND   orli.request_id = G_CONC_REQUEST_ID;
      END LOOP;
   END IF;

   IF l_batch_tbl.EXISTS(1) THEN
      FOR i in 1..l_batch_tbl.LAST LOOP
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '* Sold From Customer: '||l_sold_from_cust_name_tbl(i));
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '* Currency Code: '||l_currency_code_tbl(i));
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');

         Process_order(
             p_api_version     => 1
            ,p_init_msg_list   => FND_API.G_FALSE
            ,p_commit          => FND_API.G_FALSE
            ,p_validation_level=> FND_API.G_VALID_LEVEL_FULL
            ,p_resale_batch_id => l_batch_tbl(i)
            ,x_return_status   => l_return_status
            ,x_msg_data        => l_msg_data
            ,x_msg_count       => l_msg_count
          );
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END LOOP;
   END IF; -- END if l_batch_tbl.EXISTS

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': End');
   END IF;
   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
     p_encoded => FND_API.G_FALSE,
     p_count => x_msg_count,
     p_data  => x_msg_data
   );
   x_return_status := l_return_status;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Process_TP_ACCRUAL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
END Process_TP_ACCRUAL;

---------------------------------------------------------------------
-- PROCEDURE
--    Start_TP_ACCRUAL
--
-- PURPOSE
--    This procedure to initiate concurrent program to process third party accrual.
--    It is to for backword compatibility issue on 11.5.9
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Start_TP_ACCRUAL (
    ERRBUF                   OUT NOCOPY VARCHAR2,
    RETCODE                  OUT NOCOPY NUMBER,
    p_data_source_code       IN  VARCHAR2 :=NULL
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Start_TP_ACCRUAL';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     VARCHAR2(30);
l_msg_data          VARCHAR2(2000);
l_msg_count         NUMBER;
BEGIN

   SAVEPOINT START_TP_ACCRUAL;
   RETCODE := 0;

   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*======================================================================================================*');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Starts On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*------------------------------------------------------------------------------------------------------*');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'MO_GLOBAL.GET_CURRENT_ORG_ID: ' || MO_GLOBAL.GET_CURRENT_ORG_ID());
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*------------------------------------------------------------------------------------------------------*');


   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': Start');
   END IF;

   Process_TP_ACCRUAL (
       p_api_version      => 1.0
      ,p_init_msg_list    => FND_API.G_FALSE
      ,p_commit           => FND_API.G_FALSE
      ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
      ,p_data_source_code => p_data_source_code
      ,x_return_status    => l_return_status
      ,x_msg_data         => l_msg_data
      ,x_msg_count        => l_msg_count
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      ozf_utility_pvt.error_message('OZF_PROC_RESALE_ERR');
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      ozf_utility_pvt.error_message('OZF_PROC_RESALE_ERR');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': End');
   END IF;

   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*------------------------------------------------------------------------------------------------------*');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Ends On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*======================================================================================================*');

   -- Write all messages to a log
   OZF_UTILITY_PVT.Write_Conc_Log;
EXCEPTION
   WHEN FND_API.g_exc_error THEN
      OZF_UTILITY_PVT.Write_Conc_Log;
      ERRBUF  := l_msg_data;

   WHEN FND_API.g_exc_unexpected_error THEN
      OZF_UTILITY_PVT.Write_Conc_Log;
      ERRBUF  := l_msg_data;
      RETCODE := 2;

   WHEN OTHERS THEN
      ROLLBACK TO START_TP_ACCRUAL;
      OZF_UTILITY_PVT.Write_Conc_Log;
      ERRBUF  := l_msg_data;
      RETCODE := 2;
END Start_TP_ACCRUAL;

END OZF_TP_ACCRUAL_PVT;

/
