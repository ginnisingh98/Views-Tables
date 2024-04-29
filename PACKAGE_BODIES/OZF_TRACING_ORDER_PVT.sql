--------------------------------------------------------
--  DDL for Package Body OZF_TRACING_ORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_TRACING_ORDER_PVT" AS
/* $Header: ozfvotrb.pls 120.7.12010000.3 2009/05/06 10:39:52 ateotia ship $ */
-------------------------------------------------------------------------------
-- PACKAGE:
-- OZF_TRACING_ORDER_PVT
--
-- PURPOSE:
-- Private API for Tracing batch.
--
-- HISTORY:
-- 15-Apr-2009  ateotia   Bug# 8414563 fixed.
-- 06-May-2009  ateotia   Bug# 8489216 fixed.
--                        Moved the logic of End Customer/Bill_To/Ship_To
--                        Party creation to Common Resale API.
-------------------------------------------------------------------------------

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'OZF_TRACING_ORDER_PVT';
G_FILE_NAME CONSTANT VARCHAR2(30) := 'ozfvoctrb.pls';

OZF_DEBUG_HIGH_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON BOOLEAN  := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);

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

CURSOR batch_info_csr (p_id in NUMBER) IS
SELECT status_code,
       batch_type,
       partner_cust_account_id,
       partner_party_id,
       report_start_date,
       report_end_date,
       batch_number,
       last_updated_by
  FROM ozf_resale_batches
 WHERE resale_batch_id = p_id;
l_batch_status VARCHAR2(30);
l_batch_type   VARCHAR2(30);
l_partner_cust_account_id NUMBER;
l_partner_party_id NUMBER;
l_report_start_date date;
l_report_end_date date;
l_batch_NUMBER VARCHAR2(240);
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
                         p_date in DATE)
IS
SELECT resale_line_int_id
  FROM ozf_resale_lines_int
 WHERE resale_batch_id = p_id
   AND order_number = p_order_number
   AND sold_from_cust_account_id = p_cust_id
   AND date_ordered = p_date
   AND status_code = 'PROCESSED';
   --AND status_code in (OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DUPLICATED, OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED);
   --AND duplicated_adjustment_id <> -1;


l_valid_line_id_tbl id_tbl_type;

i NUMBER;

l_create_order_header boolean := false;

CURSOR dup_header_id_csr( p_id IN NUMBER
                        , p_order_number IN VARCHAR2
                        , p_cust_id IN NUMBER
                        , p_date IN DATE
                        ) IS
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

l_header_id NUMBER;
l_line_id   NUMBER;

CURSOR batch_order_num_csr(p_id in NUMBER)is
SELECT DISTINCT order_number,
       sold_from_cust_account_id,
       date_ordered
FROM ozf_resale_lines_int
WHERE resale_batch_id = p_id
AND status_code in(OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DUPLICATED, OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED)
--AND duplicated_adjustment_id <> -1
ORDER BY date_ordered;

TYPE order_num_tbl_type is TABLE OF batch_order_num_csr%rowtype INDEX BY binary_integer;
l_order_num_tbl order_num_tbl_type;

l_inventory_tracking VARCHAR2(1);

l_sales_transaction_rec OZF_SALES_TRANSACTIONS_PVT.SALES_TRANSACTION_REC_TYPE;

l_inventory_level_valid boolean;
l_sales_transaction_id NUMBER;

CURSOR end_cust_relation_flag_csr IS
  SELECT end_cust_relation_flag
  -- BUG 4992408 (+)
  -- FROM ozf_sys_parameters_all;
  FROM ozf_sys_parameters;
  -- BUG 4992408 (-)

l_end_cust_relation_flag varchar2(30);

--Bug# 8489216 fixed by ateotia(+)
/*
l_new_party_rec   OZF_RESALE_COMMON_PVT.party_rec_type;

CURSOR csr_orig_billto_cust(cv_resale_batch_id IN NUMBER) IS
   SELECT DISTINCT bill_to_party_name
        , bill_to_address
        , bill_to_city
        , bill_to_state
        , bill_to_postal_code
        , bill_to_country
   FROM ozf_resale_lines_int_all
   WHERE resale_batch_id = cv_resale_batch_id
   AND status_code = 'PROCESSED'
   AND ( duplicated_line_id IS NULL
      OR ( duplicated_line_id IS NOT NULL AND duplicated_adjustment_id = -1))
   AND bill_to_party_id IS NULL
   AND bill_to_cust_account_id IS NULL
   AND bill_to_party_name IS NOT NULL;

TYPE orig_billto_cust_tbl_type IS TABLE of csr_orig_billto_cust%ROWTYPE
INDEX BY BINARY_INTEGER;
l_orig_billto_cust_tbl       orig_billto_cust_tbl_type;

CURSOR csr_orig_end_cust(cv_resale_batch_id IN NUMBER) IS
   SELECT DISTINCT end_cust_party_name
        , end_cust_address
        , end_cust_city
        , end_cust_state
        , end_cust_postal_code
        , end_cust_country
        , end_cust_site_use_code
   FROM ozf_resale_lines_int_all
   WHERE resale_batch_id = cv_resale_batch_id
   AND status_code = 'PROCESSED'
   AND ( duplicated_line_id IS NULL
      OR ( duplicated_line_id IS NOT NULL AND duplicated_adjustment_id = -1))
   AND end_cust_party_id IS NULL
   AND end_cust_party_name IS NOT NULL;

TYPE orig_end_cust_tbl_type IS TABLE of csr_orig_end_cust%ROWTYPE
INDEX BY BINARY_INTEGER;
l_orig_end_cust_tbl       orig_end_cust_tbl_type;
*/
--Bug# 8489216 fixed by ateotia(-)

BEGIN
   -- Standard begin of API savepoint
   SAVEPOINT TRAC_INITIATE_PAYMENT;
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
                           l_partner_party_id,
                           l_report_start_date,
                           l_report_end_date,
                           l_batch_NUMBER,
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
         END IF;

         OPEN end_cust_relation_flag_csr;
         FETCH end_cust_relation_flag_csr INTO l_end_cust_relation_flag;
         CLOSE end_cust_relation_flag_csr;

         IF l_end_cust_relation_flag = 'T' THEN
            --Bug# 8489216 fixed by ateotia(+)
            --Moved the logic of End Customer/Bill_To/Ship_To Party creation to Common Resale API.
            OZF_RESALE_COMMON_PVT.Derive_Orig_Parties
            (  p_api_version      => 1.0
              ,p_init_msg_list    => FND_API.G_FALSE
              ,p_commit           => FND_API.G_FALSE
              ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
              ,p_resale_batch_id  => p_resale_batch_id
              ,p_partner_party_id => l_partner_party_id
              ,x_return_status    => l_return_status
              ,x_msg_data         => l_msg_data
              ,x_msg_count        => l_msg_count
            );
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            /*
            -- check bill_to customer
            OPEN csr_orig_billto_cust(p_resale_batch_id);
            FETCH csr_orig_billto_cust BULK COLLECT INTO l_orig_billto_cust_tbl;
            CLOSE csr_orig_billto_cust;

            IF l_orig_billto_cust_tbl.COUNT > 0 THEN
               FOR i IN 1..l_orig_billto_cust_tbl.COUNT LOOP
                  l_new_party_rec := NULL;
                  -- Bug 4737415 (+)
                  l_new_party_rec.partner_party_id := l_partner_party_id;
                  -- Bug 4737415 (-)
                  l_new_party_rec.name    := l_orig_billto_cust_tbl(i).bill_to_party_name;
                  l_new_party_rec.address := l_orig_billto_cust_tbl(i).bill_to_address;
                  l_new_party_rec.city    := l_orig_billto_cust_tbl(i).bill_to_city;
                  l_new_party_rec.state   := l_orig_billto_cust_tbl(i).bill_to_state;
                  l_new_party_rec.postal_Code := l_orig_billto_cust_tbl(i).bill_to_postal_code;
                  l_new_party_rec.country     := l_orig_billto_cust_tbl(i).bill_to_country;
                  l_new_party_rec.site_Use_Code := 'BILL_TO';

                  OZF_RESALE_COMMON_PVT.Create_Party(
                     p_api_version     => 1.0
                    ,p_init_msg_list   => FND_API.G_FALSE
                    ,p_commit          => FND_API.G_FALSE
                    ,p_validation_level=> FND_API.G_VALID_LEVEL_FULL
                    ,px_party_rec      => l_new_party_rec
                    ,x_return_status   => l_return_status
                    ,x_msg_data        => l_msg_data
                    ,x_msg_count       => l_msg_count
                  );
                  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                     RAISE FND_API.G_EXC_ERROR;
                  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;

                  UPDATE ozf_resale_lines_int_all
                  SET bill_to_party_id = l_new_party_rec.party_id
                    , bill_to_party_site_id = l_new_party_rec.party_site_id
                  WHERE resale_batch_id = p_resale_batch_id
                  AND bill_to_party_id IS NULL
                  AND bill_to_cust_account_id IS NULL
                  AND bill_to_party_name = l_orig_billto_cust_tbl(i).bill_to_party_name
                  AND bill_to_address = l_orig_billto_cust_tbl(i).bill_to_address
                  AND bill_to_city = l_orig_billto_cust_tbl(i).bill_to_city
                  AND bill_to_state = l_orig_billto_cust_tbl(i).bill_to_state
                  AND bill_to_postal_code = l_orig_billto_cust_tbl(i).bill_to_postal_code
                  AND bill_to_country = l_orig_billto_cust_tbl(i).bill_to_country;

               END LOOP;
            END IF;

            -- check end_customer
            OPEN csr_orig_end_cust(p_resale_batch_id);
            FETCH csr_orig_end_cust BULK COLLECT INTO l_orig_end_cust_tbl;
            CLOSE csr_orig_end_cust;

            IF l_orig_end_cust_tbl.COUNT > 0 THEN
               FOR i IN 1..l_orig_end_cust_tbl.COUNT LOOP
                  l_new_party_rec := NULL;
                  -- Bug 4737415 (+)
                  l_new_party_rec.partner_party_id := l_partner_party_id;
                  -- Bug 4737415 (-)
                  -- reset values:
                  l_new_party_rec.party_id      := NULL;
                  l_new_party_rec.party_site_id := NULL;
                  l_new_party_rec.party_site_use_id := NULL;
                  l_new_party_rec.name    := l_orig_end_cust_tbl(i).end_cust_party_name;
                  l_new_party_rec.address := l_orig_end_cust_tbl(i).end_cust_address;
                  l_new_party_rec.city    := l_orig_end_cust_tbl(i).end_cust_city;
                  l_new_party_rec.state   := l_orig_end_cust_tbl(i).end_cust_state;
                  l_new_party_rec.postal_code   := l_orig_end_cust_tbl(i).end_cust_postal_code;
                  l_new_party_rec.country       := l_orig_end_cust_tbl(i).end_cust_country;
                  l_new_party_rec.site_use_code := l_orig_end_cust_tbl(i).end_cust_site_use_code;

                  OZF_RESALE_COMMON_PVT.Create_Party
                  (  p_api_version     => 1.0
                    ,p_init_msg_list   => FND_API.G_FALSE
                    ,p_commit          => FND_API.G_FALSE
                    ,p_validation_level=> FND_API.G_VALID_LEVEL_FULL
                    ,px_party_rec      => l_new_party_rec
                    ,x_return_status   => l_return_status
                    ,x_msg_data        => l_msg_data
                    ,x_msg_count       => l_msg_count
                  );
                  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                     RAISE FND_API.G_EXC_ERROR;
                  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;

                  UPDATE ozf_resale_lines_int_all
                  SET end_cust_party_id = l_new_party_rec.party_id
                    , end_cust_party_site_id = l_new_party_rec.party_site_id
                  WHERE resale_batch_id = p_resale_batch_id
                  AND end_cust_party_id IS NULL
                  AND end_cust_party_name = l_orig_end_cust_tbl(i).end_cust_party_name
                  AND end_cust_address = l_orig_end_cust_tbl(i).end_cust_address
                  AND end_cust_city = l_orig_end_cust_tbl(i).end_cust_city
                  AND end_cust_state = l_orig_end_cust_tbl(i).end_cust_state
                  AND end_cust_postal_code = l_orig_end_cust_tbl(i).end_cust_postal_code
                  AND end_cust_country = l_orig_end_cust_tbl(i).end_cust_country
                  AND end_cust_site_use_code = l_orig_end_cust_tbl(i).end_cust_site_use_code;
               END LOOP;
            END IF;
            */
            --Bug# 8489216 fixed by ateotia(-)
         END IF;

         --i:=1;
         IF l_order_num_tbl.EXISTS(1) THEN
            l_order_num_tbl.DELETE;
         END IF;
         OPEN batch_order_num_csr(p_resale_batch_id);
         FETCH batch_order_num_csr BULK COLLECT INTO l_order_num_tbl;
         --LOOP
         --   EXIT WHEN batch_order_num_csr%NOTFOUND;
         --   FETCH batch_order_num_csr INTO l_order_num_tbl(i);
         --   i:= i+1;
         --END LOOP;
         CLOSE batch_order_num_csr;

         IF l_order_num_tbl.EXISTS(1) THEN -- IF B
            FOR k in 1..l_order_num_tbl.LAST LOOP -- FOR C

               IF OZF_DEBUG_LOW_ON THEN
                  ozf_utility_PVT.debug_message('PROCESS ORDER: ');
                  ozf_utility_PVT.debug_message('ORDER NUMBER: '||l_order_num_tbl(k).order_number);
                  ozf_utility_PVT.debug_message('SOLD_FROM_ACCT: '||l_order_num_tbl(k).sold_from_cust_account_id);
                  ozf_utility_PVT.debug_message('DATE ORDERED: '||l_order_num_tbl(k).date_ordered);
               END IF;

               -- beginjxwu header_fix
               -- Here, I assume if a line is the duplicate of another line, then they share
               -- the same order header. Hence all order with this duplicated line share the
               -- the same order with the oringinal lines.
               IF l_dup_header_id_tbl.EXISTS(1) THEN
                  l_dup_header_id_tbl.DELETE;
               END IF;
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
                     --AND   duplicated_adjustment_id <> -1;


                     GOTO END_ORDER_HEADER;
                  ELSE
                     l_create_order_header := false;
                     l_header_id := l_dup_header_id_tbl(1);
                  END IF;
               ELSE
                  l_create_order_header := true;
               END IF;

               --End jxuw header_fix


               -- Here only duplicated and processed lines are considered. DISPUTED lines will not
               -- be moved to resale order table.
               --i:=1;
               IF l_valid_line_id_tbl.EXISTS(1) THEN
                  l_valid_line_id_tbl.DELETE;
               END IF;
               OPEN valid_line_id_csr(p_resale_batch_id,
                                      l_order_num_tbl(k).order_number,
                                      l_order_num_tbl(k).sold_from_cust_account_id,
                                      l_order_num_tbl(k).date_ordered);
               FETCH valid_line_id_csr BULK COLLECT INTO l_valid_line_id_tbl;
               --LOOP
               --   EXIT WHEN valid_line_id_csr%NOTFOUND;
               --   FETCH valid_line_id_csr INTO l_valid_line_id_tbl(i);
               --   i := i+1;
               --END LOOP;
               CLOSE valid_line_id_csr;

               -- Again, we need to check whether if any line IS a duplicate or NOT.
               IF l_valid_line_id_tbl.EXISTS(1) THEN -- IF D
                  -- I then try to create resale data.
                  FOR j in 1..l_valid_line_id_tbl.last  -- FOR E
                  LOOP
                     IF OZF_DEBUG_LOW_ON THEN
                        OZF_UTILITY_PVT.debug_message('Current line_int_id:' || l_valid_line_id_tbl(j).id);
                     END IF;
                     OPEN OZF_RESALE_COMMON_PVT.g_interface_rec_csr(l_valid_line_id_tbl(j).id);
                     FETCH OZF_RESALE_COMMON_PVT.g_interface_rec_csr INTO l_line_int_rec;
                     CLOSE OZF_RESALE_COMMON_PVT.g_interface_rec_csr;

                     -- Need to check against inventory
                     IF l_line_int_rec.status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED AND
                        l_inventory_tracking = 'T'
                     THEN
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
                        IF NOT l_inventory_level_valid THEN
                           IF OZF_DEBUG_LOW_ON THEN
                              OZF_UTILITY_PVT.debug_message('Did NOT pass inventory checking');
                           END IF;
                           -- Here turn thIS line to DISPUTED AND create a dISput code FOR it.
                           UPDATE ozf_resale_lines_int
                              SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED,
                                  dispute_code = 'OZF_LT_INVT',
                                  followup_action_code = 'C',
                                  response_type = 'CA',
                                  response_code = 'N'
                            WHERE resale_line_int_id = l_line_int_rec.resale_line_int_id;

                           -- SET Batch as DISPUTED
                           UPDATE ozf_resale_batches
                              SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_DISPUTED
                            WHERE resale_batch_id = l_line_int_rec.resale_batch_id;

                           GOTO END_ORDER_LINE;
                        END IF;
                        -- Check WAC
                     END IF;

                     -- First, check whether there is need to create a header for this order
                     -- SLKRISHN Add logic to derive or insert header
                     -- see jxwu header_fix.
                     IF j = 1 THEN
                        -- Determin header id
                        IF l_create_order_header THEN
                           OZF_RESALE_COMMON_PVT.Insert_Resale_Header(
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
                           --
                        ELSE
                           NULL;
                           -- We should have the l_header_id FROM at the order level
                        END IF;
                     END IF;

                     IF OZF_DEBUG_LOW_ON THEN
                        OZF_UTILITY_PVT.debug_message('header_id is '|| l_header_id);
                     END IF;

                     IF l_line_int_rec.status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED THEN
                        IF l_line_int_rec.duplicated_line_id IS NULL THEN

                                                      -- We need to create party id for bill_to and end customer if
                           -- users wants us to do it.

                           -- No problem so far. Insert INTO batch_lines TABLE
                           OZF_RESALE_COMMON_PVT.Insert_Resale_Line(
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
                           --

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
                           --

                           IF l_inventory_tracking = 'T' THEN
                              OZF_SALES_TRANSACTIONS_PVT.Update_Inventory_Tmp (
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
                              --
                           END IF;
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
                        l_line_int_rec.status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DUPLICATED
                     THEN
                        -- only create mapping FOR the lines that are processed or
                        -- duplicated, yet the adjustment IS new then
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
                     END IF;

                     << END_ORDER_LINE >>
                     NULL;
                  END LOOP; -- END LOOP FOR this order -- FOR E
               END IF; -- if valid line id EXISTS -- IF D
               << END_ORDER_HEADER>>
               NULL;
            END LOOP; -- END LOOP FOR the batch FOR C
         END IF;  -- END order_num EXISTS  IF B


--          END IF; -- END if not rejected
       END IF; -- END l_count = 0


       -- UPDATE batch line status to CLOSEd for each OPEN and duplicated lines.

        BEGIN
            UPDATE ozf_resale_lines_int_all
            SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_CLOSED
            WHERE resale_batch_id = p_resale_batch_id
            --Bug# 8414563 fixed by ateotia(+)
            --AND status_code in(OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DUPLICATED, OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED);
            AND status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED;
            --Bug# 8414563 fixed by ateotia(-)
            --AND duplicated_adjustment_id <> -1;

            -- UPDATE batch status to CLOSEd -- might change later.
            UPDATE ozf_resale_batches_all
            SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_CLOSED
            WHERE resale_batch_id = p_resale_batch_id;
        EXCEPTION
            WHEN OTHERS THEN
               ozf_utility_pvt.error_message('OZF_UPD_RESALE_WRG','TEXT',l_full_name||': END');
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

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
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO TRAC_INITIATE_PAYMENT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO TRAC_INITIATE_PAYMENT;
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
l_return_status     VARCHAR2(30);
l_msg_data          VARCHAR2(2000);
l_msg_count         NUMBER;

CURSOR non_tracing_count_csr(p_id IN NUMBER) IS
  SELECT COUNT(1)
  FROM ozf_resale_lines_int
  WHERE resale_batch_id = p_id
  AND tracing_flag = 'F';

l_non_tracing_count NUMBER;

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

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': Start');
   END IF;

   --Initialize message list if p_init_msg_list is TRUE.
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN non_tracing_count_csr (p_resale_batch_id);
   FETCH non_tracing_count_csr INTO l_non_tracing_count;
   CLOSE non_tracing_count_csr;

   IF l_non_tracing_count > 0 THEN
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
            'OZF_RESALE_NON_TRC',
            FND_MESSAGE.get_string('OZF','OZF_RESALE_NON_TRC'),
            'TRACING_FLAG',
            tracing_flag,
            org_id
         FROM ozf_resale_lines_int_all b
         WHERE b.status_code = 'OPEN'
         AND b.tracing_flag = 'F'
         AND b.resale_batch_id = p_resale_batch_id
         AND NOT EXISTS(SELECT 1
            FROM ozf_resale_logs_all a
            WHERE a.resale_id = b.resale_line_int_id
            AND a.RESALE_ID_TYPE = 'IFACE'
            AND a.error_code ='OZF_RESALE_NON_TRC'
         );
      EXCEPTION
         WHEN OTHERS THEN
            OZF_UTILITY_PVT.error_message(
               p_message_name => 'OZF_INS_RESALE_LOG_WRG',
               p_token_name   => 'TEXT',
               p_token_value  => l_full_name||': END');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;

      UPDATE ozf_resale_lines_int_all
      SET status_code = 'DISPUTED',
          dispute_code = 'OZF_RESALE_NON_TRC',
          followup_action_code = 'C',
          response_type = 'CA',
          response_code = 'N'
      WHERE resale_batch_id = p_resale_batch_id
      AND tracing_flag = 'F';
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
--    Process_Order
--
-- PURPOSE
--    Process order information for tracing data. No simulation is needed.
--
-- PARAMETERS
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE Process_Order
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
l_api_name          CONSTANT VARCHAR2(30) := 'Process_Order';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     VARCHAR2(30);
l_msg_data          VARCHAR2(2000);
l_msg_count         NUMBER;

CURSOR order_num_csr IS
SELECT DISTINCT order_number,
       sold_from_cust_account_id,
       date_ordered
  FROM ozf_resale_lines_int
 WHERE status_code = 'OPEN'
       -- status_code in(OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_OPEN, OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DUPLICATED)
   AND duplicated_adjustment_id IS NULL
   AND resale_batch_id = p_resale_batch_id
ORDER BY date_ordered;

l_cust_account_id_tbl   OZF_RESALE_COMMON_PVT.number_tbl_type;
l_order_num_tbl         OZF_RESALE_COMMON_PVT.varchar_tbl_type;
l_order_date_tbl        OZF_RESALE_COMMON_PVT.date_tbl_type;

CURSOR order_set_csr(p_order_NUMBER in VARCHAR2,
                     p_cust_account_id in NUMBER,
                     p_date in date) IS
SELECT *
FROM ozf_resale_lines_int
WHERE order_NUMBER = p_order_NUMBER
AND date_ordered = p_date
AND sold_from_cust_account_id = p_cust_account_id
AND status_code = 'OPEN'
--AND status_code in(OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_OPEN, OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DUPLICATED)
AND duplicated_adjustment_id is NULL
AND resale_batch_id = p_resale_batch_id;

TYPE resale_lines_tbl_type IS  TABLE OF order_set_csr%rowtype INDEX BY binary_integer;
l_order_set_tbl resale_lines_tbl_type;

CURSOR invalid_line_count_csr (p_id NUMBER) IS
SELECT COUNT(1)
FROM ozf_resale_lines_int
WHERE status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED
AND dispute_code = OZF_RESALE_COMMON_PVT.G_INVALD_DISPUTE_CODE
AND resale_batch_id = p_id;

CURSOR Batch_info_csr (p_id in NUMBER) IS
SELECT partner_party_id,
       report_start_date,
       report_end_date
FROM ozf_resale_batches
WHERE resale_batch_id = p_id;

l_status_code           VARCHAR2(30);
l_inventory_level_valid boolean;
l_inventory_tracking    VARCHAR2(3);
l_partner_party_id      NUMBER;
l_report_start_date     DATE;
l_report_end_date       DATE;
l_lines_disputed        NUMBER;
l_lines_invalid         NUMBER;
l_lines_duplicated      NUMBER; --Bug# 8414563 fixed by ateotia

BEGIN
   -- Standard begin of API savepoint
   SAVEPOINT  PROCESS_TRAC_ORDER;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
     l_api_version,
     p_api_version,
     l_api_name,
     G_PKG_NAME)
   THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': Start');
   END IF;

   --Initialize message list if p_init_msg_list is TRUE.
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   /*
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
   */

   -- fetch all orders into a cursor.
   IF l_order_num_tbl.EXISTS(1) THEN
      l_order_num_tbl.DELETE;
      l_cust_account_id_tbl.DELETE;
      l_order_date_tbl.DELETE;
   END IF;
   OPEN order_num_csr;
   FETCH order_num_csr BULK COLLECT INTO l_order_num_tbl,l_cust_account_id_tbl,  l_order_date_tbl;
   CLOSE order_num_csr;

   IF l_order_num_tbl.EXISTS(1) THEN

      OPEN OZF_RESALE_COMMON_PVT.g_inventory_tracking_csr;
      FETCH OZF_RESALE_COMMON_PVT.g_inventory_tracking_csr INTO l_inventory_tracking;
      CLOSE OZF_RESALE_COMMON_PVT.g_inventory_tracking_csr;

      IF l_inventory_tracking = 'T' THEN
         OPEN Batch_info_csr(p_resale_batch_id);
         FETCH batch_info_csr INTO l_partner_party_id,
                                   l_report_start_date,
                                   l_report_end_date;
         CLOSE batch_info_csr;
         -- Bug 4380203 Fixing (+)
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
         */
         -- Bug 4380203 Fixing (-)
      END IF;

       For i in 1..l_order_num_tbl.LAST
       LOOP

         IF l_order_num_tbl(i) is not NULL AND
            l_cust_account_id_tbl(i) is not NULL AND
            l_order_date_tbl(i) is not NULL THEN

            IF OZF_DEBUG_LOW_ON THEN
               ozf_utility_PVT.debug_message('/*--- Processing order for order NUMBER:'||l_order_num_tbl(i)||'---*/');
            END IF;
            -- Before start process, clean up the data structures if necessary.

            --k:=1;
            IF l_order_set_tbl.EXISTS(1) THEN
               l_order_set_tbl.DELETE;
            END IF;
            OPEN order_set_csr(l_order_num_tbl(i),
                               l_cust_account_id_tbl(i),
                               l_order_date_tbl(i));
            FETCH order_set_csr BULK COLLECT INTO l_order_set_tbl;
            --LOOP
            --   FETCH order_set_csr INTO l_order_set_tbl(k);
            --   EXIT WHEN order_set_csr%notfound;
            --   k:=k+1;
            --END LOOP;
            CLOSE order_set_csr;

            IF OZF_DEBUG_LOW_ON THEN
               ozf_utility_PVT.debug_message('after order set'||l_order_set_tbl.LAST);
            END IF;

            For J in 1..l_order_set_tbl.LAST LOOP
               --  Purge the any error message that might be there.
               BEGIN
                  DELETE FROM ozf_resale_logs
                  WHERE resale_id = l_order_set_tbl(J).resale_line_int_id
                  AND resale_id_type = OZF_RESALE_COMMON_PVT.G_ID_TYPE_IFACE;
               EXCEPTION
                  WHEN OTHERS THEN
                     ozf_utility_pvt.error_message('OZF_DEL_RESALE_LOG_WRG');
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END;

               IF l_inventory_tracking = 'T'  THEN

                  -- Only need to Check inventory level
                  OZF_SALES_TRANSACTIONS_PVT.Validate_Inventory_level (
                              p_api_version      => 1.0
                             ,p_init_msg_list    => FND_API.G_FALSE
                             ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
                             ,p_line_int_rec     => l_order_set_tbl(J)
                             ,x_valid            => l_inventory_level_valid
                             ,x_return_status    => l_return_status
                             ,x_msg_count        => l_msg_count
                             ,x_msg_data         => l_msg_data
                  );

                  IF NOT l_inventory_level_valid THEN

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
                     WHERE resale_line_int_id = l_order_set_tbl(J).resale_line_int_id;

                     -- SET Batch as DISPUTED
                     UPDATE ozf_resale_batches
                     SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_DISPUTED
                     WHERE resale_batch_id = p_resale_batch_id;

                     GOTO END_ORDER_LINE;
                  ELSE
                     -- This is a valid tracing line
                     UPDATE ozf_resale_lines_int
                     SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED
                     WHERE resale_line_int_id = l_order_set_tbl(J).resale_line_int_id;
                  END IF;
               ELSE
                  -- Set line status to Processed if not tracking inventory
                  UPDATE ozf_resale_lines_int
                  SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED
                  WHERE resale_line_int_Id = l_order_set_tbl(j).resale_line_int_id;
               END IF;
               << END_ORDER_LINE >>
               NULL;
            END LOOP; -- END LOOP for l_order_set_tbl
            IF OZF_DEBUG_LOW_ON THEN
               ozf_utility_PVT.debug_message('/*--- Success: Processing order for order NUMBER:'||l_order_num_tbl(i)||'---*/');
            END IF;
         END IF; -- END if for order_NUMBER, date_ordered not NULL
         << END_LOOP >>
         NULL;
       END LOOP; -- END LOOP for l_order_num_tbl
    ELSE
      IF OZF_DEBUG_LOW_ON THEN
         ozf_utility_PVT.debug_message('/*--- No order to process ---*/');
      END IF;
    END IF;

    -- get data regard this process
    OPEN  OZF_RESALE_COMMON_PVT.g_disputed_line_count_csr (p_resale_batch_id);
    FETCH OZF_RESALE_COMMON_PVT.g_disputed_line_count_csr INTO l_lines_disputed;
    CLOSE OZF_RESALE_COMMON_PVT.g_disputed_line_count_csr;

    OPEN invalid_line_count_csr(p_resale_batch_id);
    FETCH invalid_line_count_csr INTO l_lines_invalid;
    CLOSE invalid_line_count_csr;

    --Bug# 8414563 fixed by ateotia(+)
    OPEN  OZF_RESALE_COMMON_PVT.g_duplicated_line_count_csr (p_resale_batch_id);
    FETCH OZF_RESALE_COMMON_PVT.g_duplicated_line_count_csr INTO l_lines_duplicated;
    CLOSE OZF_RESALE_COMMON_PVT.g_duplicated_line_count_csr;

    --IF l_lines_disputed = 0 THEN
    IF (l_lines_disputed = 0 AND l_lines_duplicated = 0) THEN
    --Bug# 8414563 fixed by ateotia(-)
       l_status_code := OZF_RESALE_COMMON_PVT.G_BATCH_PROCESSED;
    ELSE
       -- batch is in dispute
       l_status_code := OZF_RESALE_COMMON_PVT.G_BATCH_DISPUTED;
    END IF;

    -- Lastly, I will UPDATE the batch
    BEGIN
       UPDATE ozf_resale_batches_all
       SET status_code = l_status_code,
          --Bug# 8414563 fixed by ateotia(+)
          --lines_disputed = l_lines_disputed,
          lines_disputed = l_lines_disputed + l_lines_duplicated,
          --Bug# 8414563 fixed by ateotia(-)
          lines_invalid = l_lines_invalid
       WHERE resale_batch_id = p_resale_batch_id;
    EXCEPTION
       WHEN OTHERS THEN
          ozf_utility_pvt.error_message('OZF_UPD_RESALE_BATCH_WRG');
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
        ROLLBACK TO PROCESS_TRAC_ORDER;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO PROCESS_TRAC_ORDER;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO PROCESS_TRAC_ORDER;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
END Process_Order;

END OZF_TRACING_ORDER_PVT;

/
