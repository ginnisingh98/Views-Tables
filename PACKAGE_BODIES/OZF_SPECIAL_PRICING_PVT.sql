--------------------------------------------------------
--  DDL for Package Body OZF_SPECIAL_PRICING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_SPECIAL_PRICING_PVT" AS
/* $Header: ozfvsppb.pls 120.16.12010000.5 2009/07/29 14:26:58 rsatyava ship $ */

-- Package name     : OZF_SPECIAL_PRICING_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- END of Comments

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'OZF_SPECIAL_PRICING_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(30) := 'ozfvsppb.pls';

G_SPECIAL_PRICE_CLASS  CONSTANT VARCHAR2(30) := 'SPECIAL_PRICE';
G_MEET_REQ      CONSTANT VARCHAR2(30) := 'MEET_COMPETITOR';
G_BID_REQ       CONSTANT VARCHAR2(30) := 'BID_REQUEST';
G_BLANKET_REQ   CONSTANT VARCHAR2(30) := 'BLANKET_REQUEST';
G_SPECIAL_PRICING_OBJ CONSTANT VARCHAR2(30) :='SPECIAL_PRICE';

G_SPP_UTIL_TYPE CONSTANT VARCHAR2(30) :='UTILIZED';

OZF_DEBUG_HIGH_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);
OZF_UNEXP_ERROR   CONSTANT BOOLEAN := FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.g_msg_lvl_unexp_error);
OZF_ERROR         CONSTANT BOOLEAN := FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.g_msg_lvl_error);

G_OFF_INVOICE_OFFER CONSTANT VARCHAR2(30) :='OFF_INVOICE';

g_inventory_tracking         VARCHAR2(1);

---------------------------------------------------------------------
-- PROCEDURE
--    Initiate_payment
--
-- PURPOSE
--    Initiate payment for a batch.
--
-- PARAMETERS
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE Initiate_payment (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN    NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Initiate_payment';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     VARCHAR2(30);
l_msg_data          VARCHAR2(2000);
l_msg_count         NUMBER;

CURSOR Batch_info_csr (p_id in NUMBER) IS
SELECT status_code,
       batch_type,
       partner_cust_account_id,
       partner_id,
       partner_party_id,
       report_start_date,
       report_end_date,
       batch_number,
       last_updated_by
FROM ozf_resale_batches
WHERE resale_batch_id = p_id;
l_batch_status VARCHAR2(30);
l_batch_type VARCHAR2(30);
l_partner_cust_account_id NUMBER;
l_partner_id NUMBER;
l_partner_party_id NUMBER;
l_report_start_date date;
l_report_end_date date;
l_batch_number VARCHAR2(240);
l_last_updated_by NUMBER(15);

CURSOR OPEN_line_count_csr (p_id in NUMBER) IS
SELECT count(1)
From ozf_resale_lines_int
WHERE resale_batch_id = p_id
AND status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_OPEN;
l_count NUMBER;

TYPE id_type IS RECORD (
id NUMBER
);

TYPE id_tbl_type is TABLE OF id_type INDEX BY binary_integer;

l_line_int_rec OZF_RESALE_COMMON_PVT.g_interface_rec_csr%rowtype;

CURSOR valid_line_id_csr(p_id in NUMBER,
                         p_order_number in VARCHAR2,
                         p_cust_id in NUMBER,
                         p_date in date) IS
SELECT resale_line_int_id
FROM ozf_resale_lines_int
WHERE resale_batch_id = p_id
AND order_number = p_order_number
AND sold_from_cust_account_id = p_cust_id
AND date_ordered = p_date
AND status_code = 'PROCESSED';
--AND status_code in(OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DUPLICATED, OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED) ;

l_valid_line_id_tbl id_tbl_type;

i NUMBER;

l_create_order_header boolean := false;

l_chargeback_fund_id NUMBER;

l_header_id NUMBER;
l_line_id   NUMBER;

CURSOR batch_order_num_csr(p_id in NUMBER) IS
SELECT distinct order_number,
       sold_from_cust_account_id,
       date_ordered
FROM ozf_resale_lines_int
WHERE resale_batch_id = p_id
AND status_code = 'PROCESSED'
--AND status_code in(OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DUPLICATED, OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED)
ORDER BY date_ordered;

TYPE order_num_tbl_type IS TABLE OF batch_order_num_csr%rowtype INDEX BY binary_integer;
l_order_num_tbl order_num_tbl_type;

l_inventory_tracking VARCHAR2(1);

l_sales_transaction_rec OZF_SALES_TRANSACTIONS_PVT.SALES_TRANSACTION_REC_TYPE;

l_dup_line_id NUMBER;

l_claim_rec        ozf_claim_pvt.claim_rec_type;
l_funds_util_flt   ozf_claim_accrual_pvt.funds_util_flt_type;
l_claim_id NUMBER;

CURSOR claimed_amount_csr(p_resale_batch_id in NUMBER) IS
-- Bug 4496370 (+)
--SELECT NVL(amount, 0)
SELECT NVL(SUM(amount), 0)
-- Bug 4496370 (-)
FROM ozf_claims
WHERE batch_id = p_resale_batch_id
AND   batch_type = 'BATCH';
l_amount_claimed NUMBER;


l_inventory_level_valid boolean;
l_sales_transaction_id NUMBER;

CURSOR agreement_list_csr(p_resale_batch_id NUMBER) IS
SELECT distinct substr(agreement_name, 1, 30)
FROM  ozf_resale_lines_int
where resale_batch_id = p_resale_batch_id;

TYPE agreement_name_type IS RECORD (
agreement_name VARCHAR2(30)
);

TYPE agreement_tbl_type IS TABLE OF agreement_name_type INDEX BY binary_integer;

l_agreement_tbl agreement_tbl_type;

CURSOR request_header_id_csr (p_agreement_number VARCHAR2,
                              p_partner_id NUMBER) IS
SELECT a.request_header_id,
       a.request_number
FROM ozf_request_headers_all_vl a
WHERE a.agreement_number = p_agreement_number
AND   a.status_code = 'APPROVED'
AND   a.partner_id = p_partner_id
AND   a.request_class = G_SPECIAL_PRICE_CLASS;

l_request_header_id NUMBER;
l_request_number VARCHAR2(30);
l_batch_disputed BOOLEAN := false;

CURSOR dup_header_id_csr( p_id           IN NUMBER
                        , p_order_number IN VARCHAR2
                        , p_cust_id      IN NUMBER
                        , p_date         IN DATE ) IS
   SELECT a.resale_header_id
   FROM ozf_resale_headers a
      , ozf_resale_lines_int b
      , ozf_resale_lines c
   WHERE b.resale_batch_id = p_id
   AND b.order_number = p_order_number
   AND b.sold_from_cust_account_id = p_cust_id
   AND b.date_ordered = p_date
   AND b.status_code IN ('DUPLICATED', 'PROCESSED')
   AND b.duplicated_line_id = c.resale_line_id
   AND c.resale_header_id = a.resale_header_id;

l_dup_header_id_tbl OZF_RESALE_COMMON_PVT.number_tbl_type;

--Start POS Batch Processing Changes
CURSOR csr_batch_request(cv_batch_id IN NUMBER, cv_partner_id IN NUMBER) IS
  SELECT count(1)

  FROM   ozf_resale_lines_int s
       , ozf_request_headers_all_b r
  WHERE  s.resale_batch_id = cv_batch_id
  AND    s.agreement_name = r.agreement_number
  AND    r.partner_id = cv_partner_id
  AND    r.status_code = 'APPROVED'
  AND    r.request_class = 'SPECIAL_PRICE'
  AND    r.offer_type='SCAN_DATA'
  GROUP BY r.request_header_id
         , r.request_number;

l_scan_data_cnt  NUMBER(30);

l_auto_claim_profile varchar2(10):= FND_PROFILE.value('OZF_AUTO_CLAIM_POS');


--End POS Batch Processing Changes


BEGIN
   -- Standard begin of API savepoint
   SAVEPOINT INIT_PAYMENT_SPP;
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

   OPEN Batch_info_csr(p_resale_batch_id);
   FETCH batch_info_csr INTO l_batch_status,
                           l_batch_type,
                           l_partner_cust_account_id,
                           l_partner_id,
                           l_partner_party_id,
                           l_report_start_date,
                           l_report_end_date,
                           l_batch_number,
                           l_last_updated_by;
   CLOSE batch_info_csr;

   IF l_batch_status = OZF_RESALE_COMMON_PVT.G_BATCH_PENDING_PAYMENT THEN

       OPEN OPEN_line_count_csr(p_resale_batch_id);
       FETCH OPEN_line_count_csr INTO l_count;
       CLOSE OPEN_line_count_csr;

       IF l_count <> 0 THEN
          --Can not pay if there is an OPEN line
          ozf_utility_pvt.error_message('OZF_RESALE_OPEN_LINE_EXIST');
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSE
         -- There is no need to find a fund id for the SPECIAL PRICING REQUEST
         l_chargeback_fund_id := NULL;

         -- Check whether there is a need to do inventory_verification
         OPEN OZF_RESALE_COMMON_PVT.g_inventory_tracking_csr;
         FETCH OZF_RESALE_COMMON_PVT.g_inventory_tracking_csr INTO l_inventory_tracking;
         CLOSE OZF_RESALE_COMMON_PVT.g_inventory_tracking_csr;

         IF l_inventory_tracking = 'T' THEN
            -- Bug 4380203 (+)
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
            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
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
            -- Bug 4380203 (-)
         END IF;
/*
         -- SLKRISHN change to use Update_Duplicates
         -- Check for Duplicates
         OZF_RESALE_COMMON_PVT.Update_Duplicates (
            p_api_version        => 1.0,
            p_init_msg_list      => FND_API.G_FALSE,
            p_commit             => FND_API.G_FALSE,
            p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
            p_resale_batch_id    => p_resale_batch_id,
            p_resale_batch_type  => l_batch_type,
            p_batch_status       => l_batch_status,
            x_batch_status       => l_batch_status,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data);
         --
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         IF l_batch_status = OZF_RESALE_COMMON_PVT.G_BATCH_REJECTED THEN
            IF OZF_DEBUG_LOW_ON THEN
               OZF_UTILITY_PVT.debug_message('OZF_RESALE_REJECTED');
            END IF;
         ELSE
*/
            --i:=1;
            IF l_order_num_tbl.EXISTS(1) THEN
               l_order_num_tbl.DELETE;
            END IF;
            OPEN batch_order_num_csr(p_resale_batch_id);
            FETCH batch_order_num_csr BULK COLLECT INTO l_order_num_tbl;
            --LOOP
            --  FETCH batch_order_num_csr INTO l_order_num_tbl(i);
            --  EXIT WHEN batch_order_num_csr%NOTFOUND;
            --  i:= i+1;
            --END LOOP;
            CLOSE batch_order_num_csr;

            IF l_order_num_tbl.EXISTS(1) THEN
               FOR k in 1..l_order_num_tbl.LAST LOOP
                  IF OZF_DEBUG_LOW_ON THEN
                     ozf_utility_PVT.debug_message('PROCESS ORDER: ');
                     ozf_utility_PVT.debug_message('ORDER NUMBER: '||l_order_num_tbl(k).order_number);
                     ozf_utility_PVT.debug_message('sold_from_ACCT: '||l_order_num_tbl(k).sold_from_cust_account_id);
                     ozf_utility_PVT.debug_message('DATE ORDERED: '||l_order_num_tbl(k).date_ordered);
                  END IF;

                   -- beginjxwu header_fix
                  -- Here, I assume if a line is the duplicate of another line, then they share
                  -- the same order header. Hence all order with this duplicated line share the
                  -- the same order with the oringinal lines.
                  OPEN dup_header_id_csr(p_resale_batch_id,
                                     l_order_num_tbl(k).order_number,
                                     l_order_num_tbl(k).sold_from_cust_account_id,
                                     l_order_num_tbl(k).date_ordered
                                     );
                  FETCH dup_header_id_csr BULK COLLECT INTO l_dup_header_id_tbl;
                  CLOSE dup_header_id_csr;

                  IF l_dup_header_id_tbl.EXISTS(1) THEN
                     IF l_dup_header_id_tbl.EXISTS(2) THEN

                        -- There is something wrong with this order. dispute all the orders
                        -- and move to the next one.
                        -- JXWU move update to common pvt
                        UPDATE ozf_resale_lines_int_all
                        SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED,
                            dispute_code = 'OZF_RESALE_MULTI_HEADER',
                            followup_action_code = 'C',
                            response_type = 'CA',
                            response_code = 'N'
                        WHERE resale_batch_id = p_resale_batch_id
                        AND   order_number = l_order_num_tbl(k).order_number
                        AND   sold_from_cust_account_id = l_order_num_tbl(k).sold_from_cust_account_id
                        AND   date_ordered = l_order_num_tbl(k).date_ordered
                        AND   status_code in (OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DUPLICATED, OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED);

                        GOTO END_ORDER_HEADER;
                     ELSE
                        l_create_order_header := false;
                        l_header_id := l_dup_header_id_tbl(1);
                     END IF;
                  ELSE
                     l_create_order_header := true;
                  END IF;

                  --End jxuw header_fix

                   --i:=1;
                   -- Here only duplicated and processed lines are considered. Disputed lines will not
                   -- be moved to resale order table.
                   IF l_valid_line_id_tbl.EXISTS(1) THEN
                      l_valid_line_id_tbl.DELETE;
                   END IF;
                   OPEN valid_line_id_csr(p_resale_batch_id,
                                          l_order_num_tbl(k).order_number,
                                          l_order_num_tbl(k).sold_from_cust_account_id,
                                          l_order_num_tbl(k).date_ordered);
                   FETCH valid_line_id_csr BULK COLLECT INTO l_valid_line_id_tbl;
                   --LOOP
                   --   FETCH valid_line_id_csr INTO l_valid_line_id_tbl(i);
                   --   EXIT WHEN valid_line_id_csr%NOTFOUND;
                   --   i := i+1;
                   --END LOOP;
                   CLOSE valid_line_id_csr;

                   -- Again, we need to check whether if any line is a duplicate or not.
                   IF l_valid_line_id_tbl.EXISTS(1) THEN

                      -- I then try to create resale data.
                      For j in 1..l_valid_line_id_tbl.last
                      LOOP
                        IF OZF_DEBUG_LOW_ON THEN
                           ozf_utility_PVT.debug_message('Current line_int_id:' || l_valid_line_id_tbl(j).id);
                        END IF;

                        OPEN OZF_RESALE_COMMON_PVT.g_interface_rec_csr(l_valid_line_id_tbl(j).id);
                        FETCH OZF_RESALE_COMMON_PVT.g_interface_rec_csr INTO l_line_int_rec;
                        CLOSE OZF_RESALE_COMMON_PVT.g_interface_rec_csr;

                        -- Need to check against inventory
                        IF l_line_int_rec.status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED AND
                           l_inventory_tracking = 'T'  THEN

                           -- Check inventory level first
                           OZF_SALES_TRANSACTIONS_PVT.Validate_Inventory_level (
                                 p_api_version      => 1.0
                                ,p_init_msg_list    => FND_API.G_FALSE
                                ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
                                ,p_line_int_rec     => l_line_int_rec
                                ,x_valid            => l_inventory_level_valid
                                ,x_return_status    => l_return_status
                                ,x_msg_count        => l_msg_count
                                ,x_msg_data         => l_msg_data
                           );

                           IF not l_inventory_level_valid THEN
                              IF OZF_DEBUG_LOW_ON THEN
                                 ozf_utility_PVT.debug_message('Did not pass inventory checking');
                              END IF;

                              -- Here turn this line to disputed and create a disput code for it.
                              UPDATE ozf_resale_lines_int
                              SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED,
                                  dispute_code = 'OZF_LT_INVT',
                                  followup_action_code = 'C',
                                  response_type = 'CA',
                                  response_code = 'N'
                              WHERE resale_line_int_id = l_line_int_rec.resale_line_int_id;

                              -- SET Batch as disputed
                              UPDATE ozf_resale_batches
                              SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_DISPUTED
                              WHERE resale_batch_id = l_line_int_rec.resale_batch_id;

                              goto END_LOOP2;
                           END IF;

                           -- Check WAC

                        END IF;

                        -- First, check whether there is need to create a header for this order
                        IF j = 1 THEN
                           -- Determin header id
                           IF l_create_order_header THEN
                              OZF_RESALE_COMMON_PVT.Insert_resale_header(
                                 p_api_version       => 1
                                ,p_init_msg_list     => FND_API.G_FALSE
                                ,p_commit            => FND_API.G_FALSE
                                ,p_validation_level  => FND_API.G_VALID_LEVEL_FULL
                                ,p_line_int_rec      => l_line_int_rec
                                ,x_header_id         => l_header_id
                                ,x_return_status     => l_return_status
                                ,x_msg_data          => l_msg_data
                                ,x_msg_count         => l_msg_count
                              );
                              IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                                 RAISE FND_API.G_EXC_ERROR;
                              ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                              END IF;
                           ELSE
                              NULL;
                              -- We should have the l_header_id FROM the order level
                           END IF;
                        END IF;

                        IF l_line_int_rec.status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED THEN
                           IF l_line_int_rec.duplicated_line_id is NULL THEN

                              -- No problem so far. Insert INTO batch_lines table
                              OZF_RESALE_COMMON_PVT.Insert_resale_line(
                                 p_api_version       => 1
                                 ,p_init_msg_list     => FND_API.G_FALSE
                                 ,p_commit            => FND_API.G_FALSE
                                 ,p_validation_level  => FND_API.G_VALID_LEVEL_FULL
                                 ,p_line_int_rec      => l_line_int_rec
                                 ,p_header_id         => l_header_id
                                 ,x_line_id           => l_line_id
                                 ,x_return_status     => l_return_status
                                 ,x_msg_data          => l_msg_data
                                 ,x_msg_count         => l_msg_count
                              );
                              IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                                 RAISE FND_API.G_EXC_ERROR;
                              ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                              END IF;

                              -- FOR processed order line, I need to create a transaction FOR it.
                              OZF_RESALE_COMMON_PVT.Create_Sales_Transaction (
                                  p_api_version       => 1.0
                                 ,p_init_msg_list     => FND_API.G_FALSE
                                 ,p_commit            => FND_API.G_FALSE
                                 ,p_validation_level  => FND_API.G_VALID_LEVEL_FULL
                                 ,p_line_int_rec      => l_line_int_rec
                                 ,p_header_id         => l_header_id
                                 ,p_line_id           => l_line_id
                                 ,x_sales_transaction_id => l_sales_transaction_id
                                 ,x_return_status     => l_return_status
                                 ,x_msg_data          => l_msg_data
                                 ,x_msg_count         => l_msg_count
                              );
                              IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                                 RAISE FND_API.G_EXC_ERROR;
                              ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                              END IF;
                              -- Bug 4380203 Fixing (+)
                              -- Bug 4380203 Fixing: Inventory Temp table is already updated in Validate_Inventory_Level
                              /*
                              IF l_inventory_tracking = 'T' THEN
                                 OZF_SALES_TRANSACTIONS_PVT.UPDATE_inventory_tmp (
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
                              -- Bug 4380203 Fixing (-)
                           ELSE
                              l_line_id := l_line_int_rec.duplicated_line_id;
                           END IF;
                        ELSIF l_line_int_rec.status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DUPLICATED THEN
                           l_line_id := l_line_int_rec.duplicated_line_id;
                        END IF;
                        IF OZF_DEBUG_LOW_ON THEN
                           OZF_UTILITY_PVT.debug_message('line_id is '|| l_line_id);
                        END IF;

                        IF l_line_int_rec.status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED OR
                           l_line_int_rec.status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DUPLICATED THEN

                           -- only create mapping for the lines that are processed or
                           -- duplicated, yet the adjustment is new then
                           OZF_RESALE_COMMON_PVT.Insert_resale_line_mapping(
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
                        END IF;

                        IF l_line_int_rec.status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED AND
                           l_line_int_rec.tracing_flag = 'F' THEN
                           OZF_RESALE_COMMON_PVT.Create_Utilization(
                               p_api_version     => 1.0
                              ,p_init_msg_LIST   => FND_API.G_FALSE
                              ,p_commit          => FND_API.G_FALSE
                              ,p_validation_level=> FND_API.G_VALID_LEVEL_FULL
                              ,p_line_int_rec    => l_line_int_rec
                              ,p_fund_id         => l_chargeback_fund_id
                              ,p_line_id         => l_line_id
                              ,p_cust_account_id => l_partner_cust_account_id
                              ,p_approver_id     => l_last_updated_by
                              ,x_return_status   => l_return_status
                              ,x_msg_data        => l_msg_data
                              ,x_msg_count       => l_msg_count
                           );
                           IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                              RAISE FND_API.G_EXC_ERROR;
                           ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                           END IF;

                        END IF; -- if this line is a processed one
                        << END_LOOP2 >>
                        NULL;
                      END LOOP; -- END LOOP for this order
                   END IF; -- if valid line id EXISTS
               << END_ORDER_HEADER>>
               NULL;
               END LOOP; -- END LOOP for the batch
            END IF;  -- END order_num EXISTS
--         END IF;  -- if not rejected
      END IF; -- END l_count = 0

--Added code to call the claim creation process conditionally based on the profile option 'OZF: Auto Claim creation for POS' for Ship from stock accrual offers of SPR.
OPEN csr_batch_request(p_resale_batch_id, l_partner_id);
   FETCH csr_batch_request INTO l_scan_data_cnt    ;
   IF (csr_batch_request%NOTFOUND) THEN
         l_scan_data_cnt := 0;
        END IF;
   CLOSE csr_batch_request;

IF (l_auto_claim_profile = 'Y' ) OR (l_scan_data_cnt <> 0)  THEN
      OZF_Claim_Accrual_PVT.Initiate_Batch_Payment(
         p_api_version      => 1.0
        ,p_init_msg_list    => FND_API.g_false
        ,p_commit           => FND_API.g_false
        ,p_validation_level => FND_API.g_valid_level_full
        ,x_return_status    => l_return_status
        ,x_msg_count        => l_msg_count
        ,x_msg_data         => l_msg_data
        ,p_resale_batch_id  => p_resale_batch_id
      );

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      OPEN claimed_amount_csr(p_resale_batch_id);
      FETCH claimed_amount_csr INTO l_amount_claimed;
      CLOSE claimed_amount_csr;

      IF l_amount_claimed <> 0 THEN

          -- IF anything is paid, UPDATE batch line status to CLOSEd for each OPEN and duplicated lines.
         BEGIN
            UPDATE ozf_resale_lines_int
            SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_CLOSED
            WHERE resale_batch_id = p_resale_batch_id
            AND status_code in(OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DUPLICATED, OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED) ;

            -- UPDATE batch status to CLOSEd -- might change later.
            UPDATE ozf_resale_batches
            SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_CLOSED,
                paid_amount = l_amount_claimed
            WHERE resale_batch_id = p_resale_batch_id;
         EXCEPTION
            WHEN OTHERS THEN
               ozf_utility_pvt.error_message('OZF_UPD_RESALE_WRG','TEXT',l_full_name||': END');
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END;
      END IF;
ELSE
	BEGIN
            -- UPDATE batch line status to CLOSED   for duplicated and processed lines

            UPDATE ozf_resale_lines_int
            SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_CLOSED
            WHERE resale_batch_id = p_resale_batch_id
            AND status_code in(OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DUPLICATED, OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED) ;


            -- UPDATE batch status to CLOSED
            UPDATE ozf_resale_batches
            SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_CLOSED
            WHERE resale_batch_id = p_resale_batch_id;
            EXCEPTION
            WHEN OTHERS THEN
               ozf_utility_pvt.error_message('OZF_UPD_RESALE_WRG','TEXT',l_full_name||': END');
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END;


END IF;
   ELSE
       -- Only disputed and processed batch can be paid.
       ozf_utility_pvt.error_message('OZF_RESALE_WRONG_STAUS_TO_PAY');
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
   x_return_status := l_return_status;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO INIT_PAYMENT_SPP;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
     );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO INIT_PAYMENT_SPP;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
        );
   WHEN OTHERS THEN
      ROLLBACK TO INIT_PAYMENT_SPP;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
END Initiate_payment;

---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Order_Record
--
-- PURPOSE
--    This procedure validates the order information
--    These are validation specific to chargeback process
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
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)IS
l_api_name          CONSTANT VARCHAR2(30) := 'Validate_Order_Record';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--

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

   -- agreement_type should be 'SPO'
   BEGIN
      INSERT INTO ozf_resale_logs_all(
         RESALE_LOG_ID,
         RESALE_ID,
         RESALE_ID_TYPE,
         ERROR_CODE,
         ERROR_MESSAGE,
         COLUMN_NAME,
         COLUMN_VALUE,
         ORG_ID
      ) SELECT
         ozf_resale_logs_all_s.nextval,
         resale_line_int_id,
         'IFACE',
         'OZF_RESALE_AGRM_TYPE_WNG',
         FND_MESSAGE.get_string('OZF','OZF_RESALE_AGR_TYPE_WNG'),
         'AGREEMENT_TYPE',
         NULL,
         org_id
      FROM ozf_resale_lines_int_all b
      WHERE b.status_code = 'OPEN'
      AND b.tracing_flag = 'F'
      AND b.agreement_type <>'SPO'
      AND b.resale_batch_id = p_resale_batch_id
      AND NOT EXISTS(SELECT 1
         FROM ozf_resale_logs_all a
         WHERE a.resale_id = b.resale_line_int_id
         AND a.RESALE_ID_TYPE = 'IFACE'
         AND a.error_code ='OZF_RESALE_AGRM_TYPE_WNG'
      );
   EXCEPTION
      WHEN OTHERS THEN
         OZF_UTILITY_PVT.error_message(
            p_message_name => 'OZF_INS_RESALE_LOG_WRG',
            p_token_name   => 'TEXT',
            p_token_value  => l_full_name||': END');
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   BEGIN
      UPDATE ozf_resale_lines_int_all
      SET status_code = 'DISPUTED',
          dispute_code = 'OZF_RESALE_AGRM_TYPE_WNG',
          followup_action_code = 'C',
          response_type = 'CA',
          response_code = 'N'
      WHERE status_code = 'OPEN'
      AND tracing_flag = 'F'
      AND agreement_type <>'SPO'
      AND resale_batch_id = p_resale_batch_id;
   EXCEPTION
     WHEN OTHERS THEN
          OZF_UTILITY_PVT.error_message(
            p_message_name => 'OZF_UPD_RESALE_INT_WRG',
            p_token_name   => 'TEXT',
            p_token_value  => l_full_name||': END');
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

   -- purchase price not be NULL
   BEGIN
      INSERT INTO ozf_resale_logs_all(
         RESALE_LOG_ID,
         RESALE_ID,
         RESALE_ID_TYPE,
         ERROR_CODE,
         ERROR_MESSAGE,
         COLUMN_NAME,
         COLUMN_VALUE,
         ORG_ID
      ) SELECT
         ozf_resale_logs_all_s.nextval,
         resale_line_int_id,
         OZF_RESALE_COMMON_PVT.G_ID_TYPE_IFACE,
         'OZF_RESALE_PUR_PRICE_MISSING',
         fnd_message.get_string('OZF','OZF_RESALE_PUR_PRICE_MISSING'),
         'PURCHASE_PRICE',
         NULL,
         org_id
      FROM ozf_resale_lines_int_all b
      WHERE b.status_code = 'OPEN'
      AND b.tracing_flag = 'F'
      AND b.purchase_price IS NULL
      AND b.resale_batch_id = p_resale_batch_id
      AND NOT EXISTS(SELECT 1
         FROM ozf_resale_logs_all a
         WHERE a.resale_id = b.resale_line_int_id
         AND a.RESALE_ID_TYPE = 'IFACE'
         AND a.error_code ='OZF_RESALE_PUR_PRICE_MISSING'
      );
   EXCEPTION
      WHEN OTHERS THEN
         OZF_UTILITY_PVT.error_message(
            p_message_name => 'OZF_INS_RESALE_LOG_WRG',
            p_token_name   => 'TEXT',
            p_token_value  => l_full_name||': END');
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   BEGIN
      UPDATE ozf_resale_lines_int_all
      SET status_code = 'DISPUTED',
          dispute_code = 'OZF_RESALE_PUR_PRICE_MISSING',
          followup_action_code = 'C',
          response_type = 'CA',
          response_code = 'N'
      WHERE status_code = 'OPEN'
      AND tracing_flag = 'F'
      AND purchase_price IS NULL
      AND resale_batch_id = p_resale_batch_id;
   EXCEPTION
       WHEN OTHERS THEN
         OZF_UTILITY_PVT.error_message(
            p_message_name => 'OZF_UPD_RESALE_INT_WRG',
            p_token_name   => 'TEXT',
            p_token_value  => l_full_name||': END');
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

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
--    Process_One_Order
--
-- PURPOSE
--    Process information of a single order
--
-- PARAMETERS
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE Process_One_Order(
    p_order_number            IN VARCHAR2
   ,p_sold_from_cust_account_id IN NUMBER
   ,p_date_ordered            IN DATE
   ,p_resale_batch_id         IN NUMBER
   ,p_partner_id              IN NUMBER
   ,x_return_status           OUT NOCOPY   VARCHAR2
)IS
l_api_name          CONSTANT VARCHAR2(30) := 'Process_One_Order';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

l_return_status     VARCHAR2(30):=FND_API.G_RET_STS_SUCCESS;
l_msg_count         NUMBER;
l_msg_data          VARCHAR2(2000);


CURSOR order_set_csr(p_order_number VARCHAR2,
                     p_id NUMBER, p_date date,
                     p_resale_id NUMBER) IS
SELECT *
FROM ozf_resale_lines_int
WHERE order_number = p_order_number
AND sold_from_cust_account_id= p_id
AND date_ordered = p_date
AND status_code = 'OPEN'
--AND status_code in(OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_OPEN, OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DUPLICATED)
AND duplicated_adjustment_id is NULL
AND resale_batch_id = p_resale_id
AND tracing_flag = 'F';

TYPE resale_lines_tbl_type is  TABLE OF order_set_csr%rowtype INDEX BY binary_integer;
l_order_set_tbl resale_lines_tbl_type;

-- bug # 6821886 fixed by ateotia (+)
CURSOR all_order_set_csr(p_order_number VARCHAR2,
                     p_id NUMBER, p_date date,
                     p_resale_id NUMBER) IS
SELECT *
FROM ozf_resale_lines_int
WHERE order_number = p_order_number
AND sold_from_cust_account_id= p_id
AND date_ordered = p_date
AND status_code = 'OPEN'
AND duplicated_adjustment_id is NULL
AND resale_batch_id = p_resale_id;

TYPE all_resale_lines_tbl_type is  TABLE OF order_set_csr%rowtype INDEX BY binary_integer;
l_all_order_set_tbl all_resale_lines_tbl_type;
-- bug # 6821886 fixed by ateotia (-)

k NUMBER;

CURSOR request_header_info_csr(p_agreement_num VARCHAR2,
                               p_partner_id NUMBER) IS
SELECT a.request_header_id,
       -- BUG 4627231 (+)
       -- a.start_date,
       -- a.end_date,
       TRUNC(a.start_date) start_date,
       TRUNC(a.end_date) end_date,
       -- BUG 4627231 (-)
       a.currency_code,
       a.request_type_code,
       a.end_cust_party_id,
       a.reseller_party_id,
       a.offer_id,
       a.offer_type,
       a.ship_from_stock_flag --POS Batch Processing by profiles by ateotia
FROM ozf_request_headers_all_vl a
WHERE a.agreement_number = p_agreement_num
AND a.status_code = 'APPROVED'
AND a.partner_id = p_partner_id
AND a.request_class = G_SPECIAL_PRICE_CLASS;

l_ship_from_stock_flag VARCHAR2(1); --POS Batch Processing by profiles by ateotia

--POS Batch Processing by profiles by ateotia (+)
CURSOR accrued_quantity_csr(p_request_header_id NUMBER,
                             p_inventory_item_id NUMBER) IS
SELECT sum(orl.quantity) used_quantity,
       orl.uom_code
FROM   ozf_resale_lines_all orl,
       ozf_resale_adjustments_all ora
WHERE  orl.inventory_item_id = p_inventory_item_id
AND    NVL(ora.corrected_agreement_id, ora.agreement_id) = p_request_header_id
AND    orl.resale_line_id = ora.resale_line_id
AND    ora.agreement_type = 'SPO'
AND    ora.status_code = 'CLOSED'
GROUP BY orl.uom_code;
--POS Batch Processing by profiles by ateotia (-)


l_request_header_id NUMBER;
l_header_start_date date;
l_header_END_date   date;
l_request_type_code VARCHAR2(30);
l_header_currency_code VARCHAR2(30);
l_header_end_cust_party_id NUMBER;
l_header_reseller_party_id NUMBER;
l_offer_id NUMBER;
l_offer_type  VARCHAR2(30);

CURSOR request_line_info_csr(p_inventory_id NUMBER,
                             p_agreement_num VARCHAR2,
                             p_partner_id NUMBER) IS
SELECT a.request_line_id,
       a.uom,
       a.quantity,
       a.item_price,
       a.approved_type,
       a.approved_amount,
       a.approved_max_qty,
       a.approved_min_qty
FROM ozf_request_lines_all a,
     ozf_request_headers_all_vl b
WHERE a.item_type = 'PRODUCT'
AND a.item_id = p_inventory_id
AND a.request_header_id = b.request_header_id
AND b.agreement_number = p_agreement_num
AND b.status_code = 'APPROVED'
AND b.request_class = G_SPECIAL_PRICE_CLASS
AND b.partner_id = p_partner_id;

l_request_line_id          NUMBER;
l_request_line_uom         VARCHAR2(30);
l_reqeust_line_quantity    NUMBER;
l_reqeust_line_item_price  NUMBER;
l_request_line_apprv_type  VARCHAR2(30);
l_request_line_apprv_amt   NUMBER;
l_request_line_apprv_max_qty NUMBER;
l_request_line_apprv_min_qty NUMBER;

CURSOR used_quantity_csr(p_offer_id NUMBER,
                         p_product_id NUMBER) IS
SELECT sum(l.scan_unit) * a.quantity quantity_remaining,
       a.uom_code
FROM   ozf_funds_utilized_all_b u,
       ozf_claim_lines_util_all l,
       ams_act_products a
WHERE  u.utilization_id = l.utilization_id
AND    u.activity_product_id = a.activity_product_id
AND    u.plan_type = 'OFFR'
AND    u.plan_id = p_offer_id
AND    u.product_level_type = 'PRODUCT'
AND    u.product_id = p_product_id
group by a.quantity, a.uom_code;

l_used_quantity NUMBER;
l_used_uom_code VARCHAR2(20);

l_current_quantity NUMBER;

CURSOR remaining_amount_csr( p_request_header_id NUMBER) is
SELECT r.request_header_id,
       sum(fu.acctd_amount_remaining) amount_remaining
FROM ozf_funds_utilized_all_b fu,
     ozf_request_headers_all_b r
WHERE r.offer_id = fu.plan_id
AND request_header_id = p_request_header_id
GROUP BY r.request_header_id;

l_remaining_amount   NUMBER;
l_accepted_amount    NUMBER;
l_allowed_amount     NUMBER;
l_line_tolerance_amount NUMBER;
l_tolerance_flag     VARCHAR2(1);

l_line_tolerance_calc_cd varchar2(30);
l_line_tolerance_operand number;

CURSOR line_tolerance_csr(p_id in number) is
select LINE_TOLERANCE_OPERAND,  LINE_TOLERANCE_CALC_CODE
from ozf_resale_batches
where resale_batch_id = p_id;

l_need_tolerance boolean;
l_allowed_or_claimed varchar2(30);
l_dispute_code varchar2(30) := null;
l_status_code varchar2(30);
l_tolerance NUMBER;

l_resale_int_rec             OZF_RESALE_COMMON_PVT.g_interface_rec_csr%ROWTYPE;
l_inventory_level_valid      BOOLEAN;


BEGIN
   -- Standard begin of API savepoint
   SAVEPOINT  Process_SPP_ONE_Order;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': Start');
   END IF;

   -- bug # 6821886 fixed by ateotia (+)
   -- Before start process, clean up the data structures if necessary.
   IF l_all_order_set_tbl.EXISTS(1) THEN
      l_all_order_set_tbl.DELETE;
   END IF;

   OPEN all_order_set_csr(p_order_number,
          p_sold_from_cust_account_id,
          p_date_ordered,
          p_resale_batch_id);
   FETCH all_order_set_csr BULK COLLECT INTO l_all_order_set_tbl;
   CLOSE all_order_set_csr;

   IF l_all_order_set_tbl.exists(1) THEN
      For i in 1..l_all_order_set_tbl.LAST LOOP

         OPEN OZF_RESALE_COMMON_PVT.g_interface_rec_csr(l_all_order_set_tbl(i).resale_line_int_id);
         FETCH OZF_RESALE_COMMON_PVT.g_interface_rec_csr INTO l_resale_int_rec;
         CLOSE OZF_RESALE_COMMON_PVT.g_interface_rec_csr;

         IF OZF_DEBUG_LOW_ON THEN
            ozf_utility_PVT.debug_message(l_full_name || ' checking int line ' || l_all_order_set_tbl(i).resale_line_int_id);
            ozf_utility_PVT.debug_message(l_full_name || ' inventory tracking ' || g_inventory_tracking);
         END IF;

         IF g_inventory_tracking = 'T'  THEN
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
                  ozf_utility_PVT.debug_message(l_full_name || ' inventory checking not passed!!!');
               END IF;

               OZF_RESALE_COMMON_PVT.Insert_Resale_Log (
                  p_id_value      => l_all_order_set_tbl(i).resale_line_int_id,
                  p_id_type       => OZF_RESALE_COMMON_PVT.G_ID_TYPE_IFACE,
                  p_error_code    => 'OZF_RESALE_INV_LEVEL_ERROR',
                  p_column_name   => NULL,
                  p_column_value  => NULL,
                  x_return_status => l_return_status);

               IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.g_exc_error;
               ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.g_exc_unexpected_error;
               END IF;

               -- SET Batch as DISPUTED
               -- SLKRISHN change to common procedure
               UPDATE ozf_resale_lines_int_all
               SET status_code = 'DISPUTED',
               dispute_code = 'OZF_LT_INVT',
               followup_action_code = 'C',
               response_type = 'CA',
               response_code = 'N'
               WHERE resale_line_int_id = l_resale_int_rec.resale_line_int_id;
            ELSE
               UPDATE ozf_resale_lines_int_all
               SET status_code= 'PROCESSED'
               WHERE resale_line_int_id = l_resale_int_rec.resale_line_int_id
               AND tracing_flag = 'T';
            END IF;
         ELSE
	    -- 7570302 update stock sale line to PROCESSED if inventory validation disabled
            UPDATE ozf_resale_lines_int_all
            SET status_code= 'PROCESSED'
            WHERE resale_line_int_id = l_resale_int_rec.resale_line_int_id
            AND tracing_flag = 'T';
         END IF;
      END LOOP;
   END IF;
   -- the following piece of code has been commented in order to validate the tracing lines.
   --  ????  UPDATE tracing order lines to processed for this order to be processed
   /* UPDATE ozf_resale_lines_int_all
   SET status_code = 'PROCESSED'
   WHERE status_code = 'OPEN'
   AND order_number = p_order_number
   AND sold_from_cust_account_id = p_sold_from_cust_account_id
   AND date_ordered = p_date_ordered
   AND tracing_flag = 'T'
   AND resale_batch_id = p_resale_batch_id; -- bug 5222273 */
   -- bug # 6821886 fixed by ateotia (-)

   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message('partner_id:' || p_partner_id);
      ozf_utility_PVT.debug_message('/*--- Processing order for order NUMBER:'||p_order_number||'---*/');
      ozf_utility_PVT.debug_message('/*--- And cusomter:'||p_sold_from_cust_account_id||'---*/');
      ozf_utility_PVT.debug_message('/*--- And date ordered:'||p_date_ordered||'---*/');
   END IF;

   -- Before start process, clean up the data structures if necessary.
   IF l_order_set_tbl.EXISTS(1) THEN
      l_order_set_tbl.DELETE;
   END IF;
   --k:=1;
   OPEN order_set_csr(p_order_number,
          p_sold_from_cust_account_id,
          p_date_ordered,
          p_resale_batch_id);
   FETCH order_set_csr BULK COLLECT INTO l_order_set_tbl;
   --LOOP
      -- BUG 4491985 (+)
      --EXIT when order_set_csr%notfound;
      --FETCH order_set_csr INTO l_order_set_tbl(k);
   --   FETCH order_set_csr INTO l_order_set_tbl(k);
   --   EXIT when order_set_csr%notfound;
      -- BUG 4491985 (-)
   --   k:=k+1;
   --END LOOP;
   CLOSE order_set_csr;

   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_PVT.debug_message('after order set:'||l_order_set_tbl.LAST);
   END IF;

   IF l_order_set_tbl.exists(1) THEN
      For J in 1..l_order_set_tbl.LAST LOOP

         -- bug # 6821886 fixed by ateotia (+)
               /*-- Bug 4616588 (+)
               OPEN OZF_RESALE_COMMON_PVT.g_interface_rec_csr(l_order_set_tbl(J).resale_line_int_id);
               FETCH OZF_RESALE_COMMON_PVT.g_interface_rec_csr INTO l_resale_int_rec;
               CLOSE OZF_RESALE_COMMON_PVT.g_interface_rec_csr;

               IF g_inventory_tracking = 'T'  THEN
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
                     OZF_RESALE_COMMON_PVT.Insert_Resale_Log (
                        p_id_value      => l_order_set_tbl(J).resale_line_int_id,
                        p_id_type       => OZF_RESALE_COMMON_PVT.G_ID_TYPE_IFACE,
                        p_error_code    => 'OZF_RESALE_INV_LEVEL_ERROR',
                        p_column_name   => NULL,
                        p_column_value  => NULL,
                        x_return_status => l_return_status);
                     --
                     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                        RAISE FND_API.g_exc_error;
                     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE FND_API.g_exc_unexpected_error;
                     END IF;
                     --
                     -- SET Batch as DISPUTED
                     -- SLKRISHN change to common procedure
                     UPDATE ozf_resale_lines_int_all
                        SET status_code = 'DISPUTED',
                            dispute_code = 'OZF_LT_INVT',
                            followup_action_code = 'C',
                            response_type = 'CA',
                            response_code = 'N'
                      WHERE resale_line_int_id = l_resale_int_rec.resale_line_int_id;
                     --
                     GOTO END_LOOP;
                  END IF;
               END IF;
               -- Bug 4616588 (-)*/
         -- bug # 6821886 fixed by ateotia (-)

          -- request header level validation
         OPEN request_header_info_csr(l_order_set_tbl(J).agreement_name,
                                    p_partner_id);
         FETCH request_header_info_csr INTO l_request_header_id,
                                          l_header_start_date,
                                          l_header_end_date,
                                          l_header_currency_code,
                                          l_request_type_code,
                                          l_header_end_cust_party_id,
                                          l_header_reseller_party_id,
                                          l_offer_id,
                                          l_offer_type,
					  l_ship_from_stock_flag; --POS Batch Processing by profiles by ateotia
         CLOSE request_header_info_csr;

         IF OZF_DEBUG_LOW_ON THEN
            OZF_UTILITY_PVT.debug_message(p_message_text => 'start_date' || l_header_start_date);
            OZF_UTILITY_PVT.debug_message(p_message_text => 'end_date' || l_header_end_date);
            OZF_UTILITY_PVT.debug_message(p_message_text => 'request_type ' || l_request_type_code);
            OZF_UTILITY_PVT.debug_message(p_message_text => 'currency_code' || l_header_currency_code);
         END IF;
         IF l_header_start_date IS NULL OR
            l_request_type_code IS NULL OR
            l_header_currency_code is NULL THEN
            OZF_RESALE_COMMON_PVT.Insert_Resale_Log (
                p_id_value      => l_order_set_tbl(J).resale_line_int_id,
                p_id_type       => OZF_RESALE_COMMON_PVT.G_ID_TYPE_IFACE,
                p_error_code    => 'OZF_RESALE_AGRM_WNG',
                p_column_name   => NULL,
                p_column_value  => NULL,
                x_return_status => l_return_status
            );
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

            BEGIN
               UPDATE ozf_resale_lines_int
               SET status_code=OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED,
                   dispute_code = 'OZF_RESALE_AGRM_WNG',
                   followup_action_code = 'C',
                   response_type = 'CA',
                   response_code = 'N'
               WHERE resale_line_int_id = l_order_set_tbl(J).resale_line_int_id
               AND resale_batch_id = p_resale_batch_id;
            EXCEPTION
               WHEN OTHERS THEN
                  OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_UPD_RESALE_INT_WRG');
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END;
             goto END_LOOP;
         END IF;

         IF OZF_DEBUG_LOW_ON THEN
            OZF_UTILITY_PVT.debug_message(p_message_text => 'date_ordered' || l_order_set_tbl(J).date_ordered);
         END IF;


         IF l_order_set_tbl(J).date_ordered < l_header_start_date OR
            (l_header_end_date is not null AND
             l_order_set_tbl(J).date_ordered > l_header_end_date) THEN
            OZF_RESALE_COMMON_PVT.Insert_Resale_Log (
                p_id_value      => l_order_set_tbl(J).resale_line_int_id,
                p_id_type       => OZF_RESALE_COMMON_PVT.G_ID_TYPE_IFACE,
                p_error_code    => 'OZF_RESALE_AGRM_RANG_WNG',
                p_column_name   => NULL,
                p_column_value  => NULL,
                x_return_status => l_return_status
            );
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

            BEGIN
               UPDATE ozf_resale_lines_int
               SET status_code=OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED,
                   dispute_code = 'OZF_RESALE_AGRM_RANG_WNG',
                   followup_action_code = 'C',
                   response_type = 'CA',
                   response_code = 'N'
               WHERE resale_line_int_id = l_order_set_tbl(J).resale_line_int_id
               AND resale_batch_id = p_resale_batch_id;
            EXCEPTION
               WHEN OTHERS THEN
                  OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_UPD_RESALE_INT_WRG');
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END;
            GOTO END_LOOP;
         END IF;

         IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            OZF_UTILITY_PVT.debug_message('line currency '||l_order_set_tbl(J).currency_code  );
         END IF;
          IF l_order_set_tbl(J).currency_code <> l_header_currency_code THEN
            BEGIN
               UPDATE ozf_resale_lines_int
               SET status_code=OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED,
                   dispute_code = 'OZF_RESALE_AGRM_CURRENCY_WNG',
                   followup_action_code = 'C',
                   response_type = 'CA',
                   response_code = 'N'
               WHERE resale_line_int_id = l_order_set_tbl(J).resale_line_int_id
               AND resale_batch_id = p_resale_batch_id;
            EXCEPTION
               WHEN OTHERS THEN
                  OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_UPD_RESALE_INT_WRG');
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END;
            GOTO END_LOOP;
          END IF;

          -- check customer information based on request_type_code
          IF l_request_type_code = G_BLANKET_REQ THEN
             -- no need to do check;
             NULL;
          ELSIF l_request_type_code = G_BID_REQ THEN
            -- When the request is bid request, end customer info is required. Reseller info is not required.
            -- Validation on resale data is passed, only when bill_to/ ship_to is not null and equal to the
            -- end customer.

             IF OZF_DEBUG_LOW_ON THEN
               OZF_UTILITY_PVT.debug_message('In Bid request'  );
             END IF;
             IF l_header_end_cust_party_id IS NOT NULL THEN
                -- One of the following should match
                IF (l_order_set_tbl(J).bill_to_party_id is not null AND
                    l_order_set_tbl(J).bill_to_party_id = l_header_end_cust_party_id) OR
                   (l_order_set_tbl(J).ship_to_party_id is not null AND
                    l_order_set_tbl(J).ship_to_party_id = l_header_end_cust_party_id) THEN

                    -- Do nothing
                    NULL;
                ELSE
                  BEGIN
                     UPDATE ozf_resale_lines_int
                     SET status_code=OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED,
                         dispute_code = 'OZF_RESALE_AGRM_END_CUST_WNG',
                         followup_action_code = 'C',
                         response_type = 'CA',
                         response_code = 'N'
                     WHERE resale_line_int_id = l_order_set_tbl(J).resale_line_int_id
                     AND resale_batch_id = p_resale_batch_id;
                  EXCEPTION
                     WHEN OTHERS THEN
                     OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_UPD_RESALE_INT_WRG');
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END;
                  GOTO END_LOOP;
                END IF;
             END IF;
          ELSIF l_request_type_code = G_MEET_REQ THEN

            -- When the request is meet competitor, neither end customer info nor reseller info is required.
            -- Validation on resale data is passed, only as follows:
            --   IF reseller is not null then
            --       bill_to/ ship_to is not null and equal to the reseller,
            --       If end customer is not null then
            --          end customer is not null and equal to the end cusomter or
            --          end customer is null
            --       end if;
            --    ELSE
            --       If end customer is not null THEN
            --          bill_to/ ship_to is not null and equal to the end customer
            --       end if;
            --    end if;
             IF OZF_DEBUG_LOW_ON THEN
               OZF_UTILITY_PVT.debug_message('In Meet'  );
             END IF;
            -- One of the following should match
            IF l_header_reseller_party_id IS NOT NULL THEN
               IF (l_order_set_tbl(J).bill_to_party_id is NOT NULL AND
                   l_order_set_tbl(J).bill_to_party_id = l_header_reseller_party_id) OR
                  (l_order_set_tbl(J).ship_to_party_id is NOT NULL AND
                   l_order_set_tbl(J).ship_to_party_id = l_header_reseller_party_id) THEN

                   IF l_header_end_cust_party_id IS NOT NULL THEN
                      IF (l_order_set_tbl(J).END_cust_party_id is not NULL AND
                          l_order_set_tbl(J).END_cust_party_id = l_header_end_cust_party_id) OR
                         (l_order_set_tbl(J).END_cust_party_id is NULL) THEN
                          NULL;
                      ELSE
                          BEGIN
                              UPDATE ozf_resale_lines_int
                              SET status_code=OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED,
                                  dispute_code = 'OZF_RESALE_AGRM_RESELL_WNG',
                                  followup_action_code = 'C',
                                  response_type = 'CA',
                                  response_code = 'N'
                              WHERE resale_line_int_id = l_order_set_tbl(J).resale_line_int_id
                              AND resale_batch_id = p_resale_batch_id;
                           EXCEPTION
                              WHEN OTHERS THEN
                                 OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_UPD_RESALE_INT_WRG');
                                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                           END;
                           GOTO END_LOOP;
                      END IF;
                   END IF;
               ELSE
                    BEGIN
                        UPDATE ozf_resale_lines_int
                        SET status_code=OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED,
                            dispute_code = 'OZF_RESALE_AGRM_RESELL_WNG',
                            followup_action_code = 'C',
                            response_type = 'CA',
                            response_code = 'N'
                        WHERE resale_line_int_id = l_order_set_tbl(J).resale_line_int_id
                        AND resale_batch_id = p_resale_batch_id;
                     EXCEPTION
                        WHEN OTHERS THEN
                           OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_UPD_RESALE_INT_WRG');
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                     END;
                     GOTO END_LOOP;
               END IF;
            ELSE
                IF l_header_end_cust_party_id IS NOT NULL THEN
                   IF (l_order_set_tbl(J).bill_to_party_id is not NULL AND
                       l_order_set_tbl(J).bill_to_party_id = l_header_end_cust_party_id) OR
                      (l_order_set_tbl(J).ship_to_party_id is not NULL AND
                       l_order_set_tbl(J).ship_to_party_id = l_header_end_cust_party_id) THEN

                       NULL;
                   ELSE
                       BEGIN
                           UPDATE ozf_resale_lines_int
                           SET status_code=OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED,
                               dispute_code = 'OZF_RESALE_AGRM_RESELL_WNG',
                               followup_action_code = 'C',
                               response_type = 'CA',
                               response_code = 'N'
                           WHERE resale_line_int_id = l_order_set_tbl(J).resale_line_int_id
                           AND resale_batch_id = p_resale_batch_id;
                        EXCEPTION
                           WHEN OTHERS THEN
                              OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_UPD_RESALE_INT_WRG');
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END;
                        GOTO END_LOOP;
                   END IF;
                END IF;
            END IF;
          END IF;

          IF l_offer_id IS NULL THEN

            IF OZF_DEBUG_LOW_ON THEN
               OZF_UTILITY_PVT.debug_message('In Offer id null'  );
            END IF;
            BEGIN
               UPDATE ozf_resale_lines_int
               SET status_code=OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED,
                   dispute_code = 'OZF_RESALE_AGRM_OFF_NULL',
                   followup_action_code = 'C',
                   response_type = 'CA',
                   response_code = 'N'
               WHERE resale_line_int_id = l_order_set_tbl(J).resale_line_int_id
               AND resale_batch_id = p_resale_batch_id;
            EXCEPTION
               WHEN OTHERS THEN
                  OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_UPD_RESALE_INT_WRG');
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END;
            GOTO END_LOOP;
         ELSE
            IF l_offer_type = G_OFF_INVOICE_OFFER THEN
               IF OZF_DEBUG_LOW_ON THEN
                  OZF_UTILITY_PVT.debug_message('In Off invoice offer'  );
               END IF;
               BEGIN
                  UPDATE ozf_resale_lines_int
                  SET status_code=OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED,
                      dispute_code = 'OZF_RESALE_AGRM_OFF_OFF_INV',
                      followup_action_code = 'C',
                      response_type = 'CA',
                      response_code = 'N'
                  WHERE resale_line_int_id = l_order_set_tbl(J).resale_line_int_id
                  AND resale_batch_id = p_resale_batch_id;
               EXCEPTION
                  WHEN OTHERS THEN
                     OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_UPD_RESALE_INT_WRG');
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END;
               GOTO END_LOOP;
            END IF;
         END IF;

          -- request line level validation
          OPEN request_line_info_csr(l_order_set_tbl(J).inventory_item_id,
                                     l_order_set_tbl(J).agreement_name,
                                     p_partner_id);
          --EXIT when request_line_info_csr%NOTFOUND;
          FETCH request_line_info_csr INTO l_request_line_id,
                                           l_request_line_uom,
                                           l_reqeust_line_quantity,
                                           l_reqeust_line_item_price,
                                           l_request_line_apprv_type,
                                           l_request_line_apprv_amt,
                                           l_request_line_apprv_max_qty,
                                           l_request_line_apprv_min_qty;
          CLOSE request_line_info_csr;

          IF OZF_DEBUG_LOW_ON THEN
               OZF_UTILITY_PVT.debug_message('request line_id:' || l_request_line_id  );
               OZF_UTILITY_PVT.debug_message('request line uom:' || l_request_line_uom  );
               OZF_UTILITY_PVT.debug_message('request line approved max:' || l_request_line_apprv_max_qty  );
               OZF_UTILITY_PVT.debug_message('request line approved min' || l_request_line_apprv_min_qty  );
          END IF;
          IF l_request_line_id is NULL THEN
            OZF_RESALE_COMMON_PVT.Insert_Resale_Log (
                p_id_value      => l_order_set_tbl(J).resale_line_int_id,
                p_id_type       => OZF_RESALE_COMMON_PVT.G_ID_TYPE_IFACE,
                p_error_code    => 'OZF_RESALE_AGRM_PROD_WNG',
                p_column_name   => 'ITEM_NUMBER',
                p_column_value  => l_order_set_tbl(J).item_number,
                x_return_status => l_return_status
            );
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

            BEGIN
               UPDATE ozf_resale_lines_int
               SET status_code=OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED,
                   dispute_code = 'OZF_RESALE_AGRM_LINE_WNG',
                   followup_action_code = 'C',
                   response_type = 'CA',
                   response_code = 'N'
               WHERE resale_line_int_id = l_order_set_tbl(J).resale_line_int_id
               AND resale_batch_id = p_resale_batch_id;
            EXCEPTION
               WHEN OTHERS THEN
                  OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_UPD_RESALE_INT_WRG');
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END;
            goto END_LOOP;
          END IF;


   /*
          -- get current quantity and amount FROM tmp table
          OZF_RESALE_COMMON_PVT.get_available_quantity(
               p_api_version_number => 1.0,
               p_init_msg_list      => FND_API.G_FALSE,
               p_commit             => FND_API.G_FALSE,
               p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
               p_line_id           => l_request_line_id,
               p_primary_uom_code  => l_primary_uom_code,
               x_available_quantity=> l_available_quan,
               x_available_amount  => l_available_amt,
               x_return_status     => l_return_status,
               x_msg_count         => l_msg_count,
               x_msg_data          => l_msg_data
          );

   */

          l_current_quantity := l_order_set_tbl(J).quantity;
          IF OZF_DEBUG_LOW_ON THEN
            OZF_UTILITY_PVT.debug_message('init current quantity:' || l_current_quantity );
          END IF;

          IF l_request_line_apprv_max_qty is not NULL OR
             l_request_line_apprv_min_qty is not NULL THEN

             -- only to checking quantity if necessary
	     --POS Batch Processing by profiles by ateotia (+)
             l_used_quantity := NULL;
             l_used_uom_code := NULL;
             IF (l_ship_from_stock_flag = 'Y' AND l_offer_type = 'ACCRUAL') THEN
                OPEN accrued_quantity_csr(l_request_header_id, l_order_set_tbl(J).inventory_item_id);
                FETCH accrued_quantity_csr INTO l_used_quantity, l_used_uom_code;
                CLOSE accrued_quantity_csr;
             ELSE
                OPEN used_quantity_csr(l_offer_id, l_order_set_tbl(J).inventory_item_id);
                FETCH used_quantity_csr INTO l_used_quantity, l_used_uom_code;
                CLOSE used_quantity_csr;
             END IF;
	     /*
             OPEN used_quantity_csr(l_offer_id, l_order_set_tbl(J).inventory_item_id);
             FETCH used_quantity_csr INTO l_used_quantity,
                                          l_used_uom_code;
             CLOSE used_quantity_csr;*/

          --POS Batch Processing by profiles by ateotia (-)

             IF l_used_quantity IS NULL THEN
                l_used_quantity := 0;
             END IF;

             IF l_used_uom_code IS NULL THEN
                l_used_uom_code := l_request_line_uom;
             END IF;

             IF l_request_line_uom <> l_used_uom_code THEN
                -- conver the requeste line quantity
                IF l_request_line_apprv_max_qty is not NULL THEN
                     l_request_line_apprv_max_qty := inv_convert.inv_um_convert(
                         l_order_set_tbl(J).inventory_item_id,
                         NULL,
                         l_request_line_apprv_max_qty ,
                         l_request_line_uom,
                         l_used_uom_code,
                         NULL, NULL);
                     IF l_request_line_apprv_max_qty = -99999 THEN
                        BEGIN
                           UPDATE ozf_resale_lines_int
                           SET status_code=OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED,
                               dispute_code = 'OZF_SPP_NO_UOM_CONV_MAX',
                               followup_action_code = 'C',
                               response_type = 'CA',
                               response_code = 'N'
                           WHERE resale_line_int_id = l_order_set_tbl(J).resale_line_int_id
                           AND resale_batch_id = p_resale_batch_id;
                        EXCEPTION
                           WHEN OTHERS THEN
                              OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_UPD_RESALE_INT_WRG');
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END;
                        goto END_LOOP;
                     END IF;
                END IF;

                IF l_request_line_apprv_min_qty is not NULL THEN
                     l_request_line_apprv_min_qty := inv_convert.inv_um_convert(
                         l_order_set_tbl(J).inventory_item_id,
                         NULL,
                         l_request_line_apprv_min_qty ,
                         l_request_line_uom,
                         l_used_uom_code,
                         NULL, NULL);
                     IF l_request_line_apprv_min_qty = -99999 THEN
                        BEGIN
                           UPDATE ozf_resale_lines_int
                           SET status_code=OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED,
                               dispute_code = 'OZF_SPP_NO_UOM_CONV_MIN',
                               followup_action_code = 'C',
                               response_type = 'CA',
                               response_code = 'N'
                           WHERE resale_line_int_id = l_order_set_tbl(J).resale_line_int_id
                           AND resale_batch_id = p_resale_batch_id;
                        EXCEPTION
                           WHEN OTHERS THEN
                              OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_UPD_RESALE_INT_WRG');
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END;
                        goto END_LOOP;
                     END IF;
                END IF;
             END IF;

             IF l_order_set_tbl(J).uom_code <> l_used_uom_code THEN
                -- conver the quantity for the current order
                IF l_current_quantity is not NULL THEN
                     l_current_quantity := inv_convert.inv_um_convert(
                         l_order_set_tbl(J).inventory_item_id,
                         NULL,
                         l_current_quantity,
                         l_order_set_tbl(J).uom_code,
                         l_used_uom_code,
                         NULL, NULL);
                     IF l_current_quantity = -99999 THEN
                        BEGIN
                           UPDATE ozf_resale_lines_int
                           SET status_code=OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED,
                               dispute_code = 'OZF_SPP_NO_UOM_CONV_CURR',
                               followup_action_code = 'C',
                               response_type = 'CA',
                               response_code = 'N'
                           WHERE resale_line_int_id = l_order_set_tbl(J).resale_line_int_id
                           AND resale_batch_id = p_resale_batch_id;
                        EXCEPTION
                           WHEN OTHERS THEN
                              OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_UPD_RESALE_INT_WRG');
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END;
                        goto END_LOOP;
                     END IF;
                END IF;
             END IF;
             IF OZF_DEBUG_LOW_ON THEN
               OZF_UTILITY_PVT.debug_message('2 current quantity:' || l_current_quantity );
             END IF;

             IF l_request_line_apprv_max_qty is not NULL AND
                l_current_quantity + l_used_quantity > l_request_line_apprv_max_qty THEN
                  BEGIN
                     UPDATE ozf_resale_lines_int
                     SET status_code=OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED,
                         dispute_code = 'OZF_RESALE_AGRM_QUN_GT_MAX',
                         followup_action_code = 'C',
                         response_type = 'CA',
                         response_code = 'N'
                     WHERE resale_line_int_id = l_order_set_tbl(J).resale_line_int_id
                     AND resale_batch_id = p_resale_batch_id;
                  EXCEPTION
                     WHEN OTHERS THEN
                        OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_UPD_RESALE_INT_WRG');
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END;
                  goto END_LOOP;
             END IF;

             IF l_request_line_apprv_min_qty is not NULL AND
                l_current_quantity + l_used_quantity < l_request_line_apprv_min_qty THEN
                  BEGIN
                     UPDATE ozf_resale_lines_int
                     SET status_code=OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED,
                         dispute_code = 'OZF_RESALE_AGRM_QUN_LT_MIN',
                         followup_action_code = 'C',
                         response_type = 'CA',
                         response_code = 'N'
                     WHERE resale_line_int_id = l_order_set_tbl(J).resale_line_int_id
                     AND resale_batch_id = p_resale_batch_id;
                  EXCEPTION
                     WHEN OTHERS THEN
                        OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_UPD_RESALE_INT_WRG');
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END;
                  goto END_LOOP;
             END IF;

             -- UPDATE line and temp table with information FROM this line.
             l_used_quantity := l_used_quantity + l_current_quantity;

             -- Need to continue here.

          END IF;

          --2. get claimed amount, claimed_amount + claiming_amount < total_amount  ???
          OPEN remaining_amount_csr(l_request_header_id);
          FETCH remaining_amount_csr into l_request_header_id,
                                          l_remaining_amount;
          CLOSE remaining_amount_csr;

          IF OZF_DEBUG_LOW_ON THEN
               OZF_UTILITY_PVT.debug_message('remaining amount:' || l_remaining_amount  );
          END IF;


          -- allowed amount should be based on the request.
          -- Update the results of Special Pricing Calculation
          OZF_RESALE_COMMON_PVT.Update_Line_Calculations(
            p_resale_line_int_rec => l_order_set_tbl(J),
            p_unit_price          => l_reqeust_line_item_price,
            p_line_quantity       => l_current_quantity,
            p_allowed_amount      => l_request_line_apprv_amt,
            x_return_status       => l_return_status);
         --
         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
         <<END_LOOP>>
         NULL;
      END LOOP;
   END IF;
   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_PVT.debug_message('/*--- Success: Processing order for order NUMBER:'||p_order_number||'---*/');
      ozf_utility_PVT.debug_message('/*--- AND cusomter:'||p_sold_from_cust_account_id||'---*/');
      ozf_utility_PVT.debug_message('/*--- And date ordered:'||p_date_ordered||'---*/');
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': End');
   END IF;

   x_return_status := l_return_status;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Process_SPP_ONE_Order;
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Process_SPP_ONE_Order;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      ROLLBACK TO Process_SPP_ONE_Order;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Process_One_Order;

---------------------------------------------------------------------
-- PROCEDURE
--    Process_Order
--
-- PURPOSE
--
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
l_return_status     VARCHAR2(30);
l_msg_data          VARCHAR2(2000);
l_msg_count         NUMBER;

CURSOR partner_id_csr (p_resale_batch_id NUMBER)IS
SELECT partner_id
     , report_start_date
     , report_end_date
FROM ozf_resale_batches
where resale_batch_id = p_resale_batch_id;
l_partner_id NUMBER;

CURSOR order_num_csr IS
SELECT DISTINCT order_number,
       sold_from_cust_account_id,
       date_ordered
  FROM ozf_resale_lines_int
 WHERE status_code = 'OPEN'
       --status_code in(OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_OPEN, OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DUPLICATED)
   AND duplicated_adjustment_id IS NULL
   AND resale_batch_id = p_resale_batch_id
ORDER BY date_ordered;

l_cust_account_id_tbl   OZF_RESALE_COMMON_PVT.number_tbl_type;
l_order_num_tbl         OZF_RESALE_COMMON_PVT.varchar_tbl_type;
l_order_date_tbl        OZF_RESALE_COMMON_PVT.date_tbl_type;

l_report_start_date     DATE;
l_report_end_date       DATE;

BEGIN
   -- Standard begin of API savepoint
   SAVEPOINT  Process_SPP_Order;
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

      -- Delete the logs for the current batch
   OZF_RESALE_COMMON_PVT.Delete_Log(
       p_api_version      => 1.0
      ,p_init_msg_list    => FND_API.G_FALSE
      ,p_commit           => FND_API.G_FALSE
      ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
      ,p_resale_batch_id  => p_resale_batch_id
      ,x_return_status          => l_return_status
      ,x_msg_count              => l_msg_count
      ,x_msg_data               => l_msg_data
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;


   OPEN partner_id_csr(p_resale_batch_id);
   FETCH partner_id_csr INTO l_partner_id
                           , l_report_start_date
                           , l_report_end_date;
   CLOSE partner_id_csr;


   -- Bug 4616588 (+)
   -- Check whether there is a need to do inventory_verification
   OPEN OZF_RESALE_COMMON_PVT.g_inventory_tracking_csr;
   FETCH OZF_RESALE_COMMON_PVT.g_inventory_tracking_csr INTO g_inventory_tracking;
   CLOSE OZF_RESALE_COMMON_PVT.g_inventory_tracking_csr;

   -- populates the temp tables
   IF g_inventory_tracking = 'T' THEN
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
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;
   -- Bug 4616588 (-)


   -- fetch all orders into a cursor.
   OPEN order_num_csr;
   FETCH order_num_csr BULK COLLECT INTO l_order_num_tbl,l_cust_account_id_tbl,  l_order_date_tbl;
   CLOSE order_num_csr;


   IF l_order_num_tbl.EXISTS(1) THEN

      For i in 1..l_order_num_tbl.LAST
      LOOP
         IF l_order_num_tbl(i) is not NULL AND
            l_cust_account_id_tbl(i) is not NULL AND
            l_order_date_tbl(i) is not NULL THEN

            process_one_order(p_order_number => l_order_num_tbl(i),
                              p_sold_from_cust_account_id => l_cust_account_id_tbl(i),
                              p_date_ordered => l_order_date_tbl(i),
                              p_resale_batch_id => p_resale_batch_id,
                              p_partner_id => l_partner_id,
                              x_return_status => l_return_status);

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               BEGIN
                  update ozf_resale_lines_int
                  set status_code =OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED,
                      dispute_code = 'OZF_PROC_PRIC_RESLT_ERR',
                      followup_action_code = 'C',
                      response_type = 'CA',
                      response_code = 'N'
                  where status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_OPEN
                  and order_number = l_order_num_tbl(i)
                  and sold_from_cust_account_id =l_cust_account_id_tbl(i)
                  and date_ordered = l_order_date_tbl(i)
                  and resale_batch_id = p_resale_batch_id;
               EXCEPTION
                  WHEN OTHERS THEN
                    ozf_utility_pvt.error_message( 'OZF_UPD_RESALE_INT_WRG');
                    RAISE FND_API.g_exc_unexpected_error;
               END;
               IF OZF_DEBUG_LOW_ON THEN
                  ozf_utility_PVT.debug_message('/*--- process_one_order Failed ---*/');
               END IF;
            END IF;
         END IF; -- END if for order_number, sold_from cust, date_ordered not NULL
      END LOOP; -- END LOOP for l_order_num_tbl
   END IF;

   -- Update Chargeback header with processing detail
   OZF_RESALE_COMMON_PVT.Update_Batch_Calculations (
       p_api_version            => 1.0
      ,p_init_msg_list          => FND_API.G_FALSE
      ,p_commit                 => FND_API.G_FALSE
      ,p_validation_level       => FND_API.G_VALID_LEVEL_FULL
      ,p_resale_batch_id        => p_resale_batch_id
      ,x_return_status          => l_return_status
      ,x_msg_data               => l_msg_data
      ,x_msg_count              => l_msg_count
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
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
   x_return_status := l_return_status;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Process_SPP_Order;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Process_SPP_Order;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Process_SPP_Order;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
END Process_Order;

END OZF_SPECIAL_PRICING_PVT;

/
