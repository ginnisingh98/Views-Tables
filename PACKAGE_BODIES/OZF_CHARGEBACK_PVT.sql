--------------------------------------------------------
--  DDL for Package Body OZF_CHARGEBACK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CHARGEBACK_PVT" AS
/* $Header: ozfvcbkb.pls 120.23.12010000.4 2010/05/18 05:37:48 nepanda ship $ */
-------------------------------------------------------------------------------
-- PACKAGE:
-- OZF_CHARGEBACK_PVT
--
-- PURPOSE:
-- Private API for Chargeback batch.
--
-- HISTORY:
-- 02-Oct-2003  Jim Wu    Created
-- 28-Feb-2004  Sarvanan  Error Handling, Formating, Changes to error logging,
--                        Changes for Workflow and Change call to common
--                        Duplicate check api at batch level
-- 25-Feb-2005  Michelle  BUG 4186465 Fixing: Populate the following order
--                        attribute when calling pricing api
--                        - invoice_to_party_id
--                        - invoice_to_party_site_id
--                        - ship_to_party_site_id
--                        - ship_to_party_site_id
-- 28-May-2007  ateotia   Bug# 5997978 fixed.
-- 15-Feb-2008  ateotia   Bug# 6821886 fixed.
--                        Inventory Validation should happen for Tracing lines.
-- 06-May-2009  ateotia   Bug# 8489216 fixed.
--                        Moved the logic of End Customer/Bill_To/Ship_To
--                        Party creation to Common Resale API.
-- 25-JAN-2010  muthsubr  Bug# 8632964 fixed.
--                        If 'Create Accruals On Chargeback Claims' flag is not
--                        checked in system parameter page, we should use the
--                        existing accruals of chargeback budget.
-- 5/18/2010    nepanda   Fix for Bug 9662148 - claim association wrong while uploading a chargeback batch
------------------------------------------------------------------------------------------------------------

G_PKG_NAME        CONSTANT VARCHAR2(30) := 'OZF_CHARGEBACK_PVT';
G_FILE_NAME       CONSTANT VARCHAR2(30) := 'ozfvcbkb.pls';
G_PRICING_EVENT   CONSTANT VARCHAR2(30) := 'PRICE';
G_TP_ACCRUAL      CONSTANT VARCHAR2(30) := 'TP_ACCRUAL';
G_CHBK_UTIL_TYPE  CONSTANT VARCHAR2(30) := 'CHARGEBACK';

OZF_DEBUG_HIGH_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON  BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);
OZF_UNEXP_ERROR   BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.g_msg_lvl_unexp_error);

---------------------------------------------------------------------
-- PROCEDURE
--    Initiate_Payment
--
-- PURPOSE
--    Initiate payment FOR a batch.
--
-- PARAMETERS
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE Initiate_Payment (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN  NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Initiate_Payment';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status                  VARCHAR2(30);
l_msg_data                       VARCHAR2(2000);
l_msg_count                      NUMBER;
--
l_batch_status                   VARCHAR2(30);
l_batch_type                     VARCHAR2(30);
l_partner_cust_account_id        NUMBER;
l_partner_party_id               NUMBER;
l_report_start_date              DATE;
l_report_end_date                DATE;
l_batch_number                   VARCHAR2(30);
l_last_updated_by                NUMBER(15);
--
l_count                          NUMBER;
TYPE id_type IS RECORD (id NUMBER);
TYPE id_tbl_type IS TABLE OF id_type INDEX BY BINARY_INTEGER;

l_line_int_rec                   OZF_RESALE_COMMON_PVT.g_interface_rec_csr%ROWTYPE;
l_valid_line_id_tbl              id_tbl_type;
i                                NUMBER;
l_chargeback_fund_id             NUMBER;
l_header_id                      NUMBER;
l_line_id                        NUMBER;
l_create_order_header            BOOLEAN := false;
--
l_inventory_tracking             VARCHAR2(1);

--
l_auto_tp_accrual                VARCHAR2(1);
l_claim_rec                      OZF_CLAIM_PVT.claim_rec_type;
l_funds_util_flt                 OZF_CLAIM_ACCRUAL_PVT.funds_util_flt_type;
l_claim_id                       NUMBER;
l_amount_claimed                 NUMBER;
l_reprocessing                   BOOLEAN;
l_inventory_level_valid          BOOLEAN;
l_sales_transaction_id           NUMBER;
l_currency_code                  VARCHAR2(15);

l_dup_header_id_tbl              OZF_RESALE_COMMON_PVT.number_tbl_type;
--
CURSOR batch_info_csr (p_id IN NUMBER) IS
   SELECT status_code,
          batch_type,
          partner_cust_account_id,
          partner_party_id,
          report_start_date,
          report_end_date,
          batch_number,
          last_updated_by,
          currency_code,
          partner_claim_number
    FROM ozf_resale_batches
    WHERE resale_batch_id = p_id;

CURSOR open_line_count_csr (p_id IN NUMBER) IS
   SELECT count(1)
   FROM ozf_resale_lines_int
   WHERE resale_batch_id = p_id
   AND status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_OPEN;

CURSOR valid_line_id_csr(p_id           IN NUMBER,
                         p_order_number IN VARCHAR2,
                         p_cust_id      IN NUMBER,
                         p_date         IN DATE) IS
   SELECT resale_line_int_id
   FROM ozf_resale_lines_int
   WHERE resale_batch_id = p_id
   AND order_number = p_order_number
   AND sold_from_cust_account_id = p_cust_id
   AND date_ordered = p_date
   AND status_code = 'PROCESSED';
   -- AND status_code in (OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DUPLICATED, OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED);
   --   AND duplicated_adjustment_id <> -1;

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
   AND b.status_code = 'PROCESSED'
   -- AND b.status_code IN ('DUPLICATED', 'PROCESSED')
   AND b.duplicated_line_id = c.resale_line_id
   AND c.resale_header_id = a.resale_header_id;


CURSOR batch_order_num_csr(p_id IN NUMBER) IS
   SELECT DISTINCT order_number,
          sold_from_cust_account_id,
          date_ordered
   FROM ozf_resale_lines_int
   WHERE resale_batch_id = p_id
   AND status_code = 'PROCESSED'
   -- AND status_code in(OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DUPLICATED, OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED)
   --   AND duplicated_adjustment_id <> -1
   ORDER BY date_ordered;

TYPE order_num_tbl_type IS TABLE of batch_order_num_csr%ROWTYPE
INDEX BY BINARY_INTEGER;
l_order_num_tbl                  order_num_tbl_type;

CURSOR auto_tp_accrual_csr IS
   SELECT auto_tp_accrual_flag
   FROM ozf_sys_parameters;

CURSOR claimed_amount_csr(p_claim_id IN NUMBER) IS
   SELECT amount
   FROM ozf_claims
   WHERE claim_id = p_claim_id;

CURSOR end_cust_relation_flag_csr IS
   SELECT end_cust_relation_flag
   -- BUG 4992408 (+)
   -- FROM ozf_sys_parameters_all;
   FROM ozf_sys_parameters;
   -- BUG 4992408 (-)

l_end_cust_relation_flag         VARCHAR2(30);
l_partner_claim_num              VARCHAR2(30);
error_no_rollback                EXCEPTION;

--Bug# 8489216 fixed by ateotia(+)
/*
l_new_party_rec                  OZF_RESALE_COMMON_PVT.party_rec_type;

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

--Bug# 8632964 fixed by anuj and muthu (+)
CURSOR sysparam_accrual_flag_csr (p_resale_batch_id IN NUMBER)
IS
SELECT NVL(ospa.ship_debit_accrual_flag, 'F')
FROM ozf_sys_parameters_all ospa,
     ozf_resale_batches_all orba
WHERE ospa.org_id = orba.org_id
AND orba.resale_batch_id = p_resale_batch_id;

l_accrual_flag VARCHAR2(1);
--Bug# 8632964 fixed by anuj and muthu (-)

BEGIN
   -- Standard begin of API savepoint
   SAVEPOINT Initiate_Payment;
   -- Standard call to check FOR call compatibility.
   IF NOT FND_API.Compatible_API_Call (
        l_api_version,
        p_api_version,
        l_api_name,
        G_PKG_NAME)
   THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   --Initialize message if p_init_msg_list IS TRUE.
   IF FND_API.To_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN batch_info_csr(p_resale_batch_id);
   FETCH batch_info_csr INTO l_batch_status,
                             l_batch_type,
                             l_partner_cust_account_id,
                             l_partner_party_id,
                             l_report_start_date,
                             l_report_end_date,
                             l_batch_number,
                             l_last_updated_by,
                             l_currency_code,
                             l_partner_claim_num;
   CLOSE batch_info_csr;

   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message('status ' ||l_batch_status);
      OZF_UTILITY_PVT.debug_message('compare to ' ||OZF_RESALE_COMMON_PVT.G_BATCH_PENDING_PAYMENT);
      OZF_UTILITY_PVT.debug_message('Batch Type '	||l_batch_type);
   END IF;

   -- --------------------------------------------------
   -- Stop Initiate_Payment if
   --      1. Batch Status is not in Pending Payment
   --      2. There are open line(s) exists in the batch
   -- --------------------------------------------------

   IF l_batch_status <> OZF_RESALE_COMMON_PVT.G_BATCH_PENDING_PAYMENT  THEN
      -- Only DISPUTED AND PROCESSED batch can be paid.
      OZF_UTILITY_PVT.error_message('OZF_RESALE_WRONG_STAUS_TO_PAY');
      RAISE FND_API.g_exc_error;
   END IF;

   OPEN open_line_count_csr(p_resale_batch_id);
   FETCH open_line_count_csr INTO l_count;
   CLOSE open_line_count_csr;

   IF l_count IS NOT NULL AND l_count <> 0 THEN
      --Can not pay if there is an OPEN line
      OZF_UTILITY_PVT.error_message('OZF_RESALE_OPEN_LINE_EXIST');
      RAISE FND_API.g_exc_error;
   END IF;


   IF l_batch_status = OZF_RESALE_COMMON_PVT.G_BATCH_PENDING_PAYMENT  THEN
      -- Get the budget where accruals are posted
      l_chargeback_fund_id := FND_PROFILE.value('OZF_CHARGEBACK_BUDGET');
      --
      IF l_chargeback_fund_id IS NULL THEN
         --OZF_UTILITY_PVT.error_message('OZF_CHBK_BUDGET_NULL');

         OZF_RESALE_COMMON_PVT.Insert_Resale_Log (
             p_id_value      => p_resale_batch_id
            ,p_id_type       => OZF_RESALE_COMMON_PVT.G_ID_TYPE_BATCH
            ,p_error_code    => 'OZF_CHBK_BUDGET_NULL'
            ,p_column_name   => NULL
            ,p_column_value  => NULL
            ,x_return_status => l_return_status
         );
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         UPDATE ozf_resale_batches_all
         SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_DISPUTED
         WHERE resale_batch_id = p_resale_batch_id;

         RAISE error_no_rollback;
         --RAISE FND_API.g_exc_error;
      END IF;
      --
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_UTILITY_PVT.debug_message('Chargeback Budget: ' || l_chargeback_fund_id);
      END IF;

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

      --Bug# 8632964 fixed by anuj and muthu (+)
      OPEN sysparam_accrual_flag_csr (p_resale_batch_id);
      FETCH sysparam_accrual_flag_csr INTO l_accrual_flag;
      CLOSE sysparam_accrual_flag_csr;

      IF OZF_DEBUG_HIGH_ON THEN
         OZF_UTILITY_PVT.debug_message('Create Accruals On Chargeback Claims: '|| l_accrual_flag);
      END IF;
      --Bug# 8632964 fixed by anuj and muthu (-)

      --i:=1;
      IF l_order_num_tbl.EXISTS(1) THEN
         l_order_num_tbl.DELETE;
      END IF;
      OPEN batch_order_num_csr(p_resale_batch_id);
      FETCH batch_order_num_csr BULK COLLECT INTO l_order_num_tbl;
      --LOOP
      --   FETCH batch_order_num_csr INTO l_order_num_tbl(i);
      --   EXIT WHEN batch_order_num_csr%NOTFOUND;
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

            -- [begin jxwu header_fix]:
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
               -- BUG 4670154 (+)
               -- Cursor dup_header_id_csr will return multiple rows if same
               -- order numbers exists in the same batch.
               /*
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
               */
                  l_create_order_header := false;
                  l_header_id := l_dup_header_id_tbl(1);
               --END IF;
               -- BUG 4670154 (-)
            ELSE
               l_create_order_header := true;
            END IF;
            -- [End jxuw header_fix]

            -- Here only DUPLICATED and PROCESSED lines are considered.
            -- DISPUTED lines will not be moved to resale order table.
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
                  -- Only need to check inventory for non-duplicate resale lines
                  IF l_line_int_rec.status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED AND
                     (   l_line_int_rec.duplicated_adjustment_id IS NULL
                      OR l_line_int_rec.duplicated_adjustment_id = -1 ) AND
                     l_inventory_tracking = 'T' THEN
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
                     ELSE
                        NULL;
                        -- We should have the l_header_id FROM at the order level
                     END IF;
                  END IF;

                  IF OZF_DEBUG_LOW_ON THEN
                     OZF_UTILITY_PVT.debug_message('header_id is '|| l_header_id);
                  END IF;

                  IF l_line_int_rec.status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED THEN
                     IF (l_line_int_rec.duplicated_line_id IS NULL)  OR
                        (l_line_int_rec.duplicated_line_id IS NOT NULL AND
                         l_line_int_rec.duplicated_adjustment_id = -1) THEN
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

                        -- FOR processed order line, I need to create a transaction FOR it.
                        OZF_RESALE_COMMON_PVT.Create_Sales_Transaction (
                            p_api_version          => 1.0
                           ,p_init_msg_list        => FND_API.G_FALSE
                           ,p_commit               => FND_API.G_FALSE
                           ,p_validation_level     => FND_API.G_VALID_LEVEL_FULL
                           ,p_line_int_rec         => l_line_int_rec
                           ,p_header_id            => l_header_id
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
                        --

                        -- Bug 4380203 Fixing (+)
                        -- Bug 4380203 Fixing: Inventory Temp table is already updated in Validate_Inventory_Level
                        /*
                        IF l_inventory_tracking = 'T' THEN
                           OZF_SALES_TRANSACTIONS_PVT.Update_Inventory_Tmp(
                              p_api_version          => 1.0
                             ,p_init_msg_list        => FND_API.G_FALSE
                             ,p_validation_level     => FND_API.G_VALID_LEVEL_FULL
                             ,p_sales_transaction_id => l_sales_transaction_id
                             ,x_return_status        => l_return_status
                             ,x_msg_data             => l_msg_data
                             ,x_msg_count            => l_msg_count
                           );
                           IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                              RAISE FND_API.G_EXC_ERROR;
                           ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                           END IF;
                           --
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

                  IF l_line_int_rec.status_code = 'PROCESSED' THEN
                     -- Create Resale Line Mappings only for Processed Lines
                     -- l_line_int_rec.status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DUPLICATED THEN
                     -- -- only create mapping FOR the lines that are processed or
                     -- -- duplicated, yet the adjustment IS new then
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

                  IF l_line_int_rec.status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED AND
                     l_line_int_rec.tracing_flag = 'F' AND
                     --Bug# 8632964 fixed by anuj and muthu (+)
                     l_accrual_flag = 'T' THEN
                     --Bug# 8632964 fixed by anuj and muthu (-)
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
                  END IF; -- If this line is a processed one
                  --
                  << END_ORDER_LINE >>
                  NULL;
               END LOOP; -- END LOOP FOR this order -- FOR E
            END IF; -- if valid line id EXISTS -- IF D
            << END_ORDER_HEADER>>
            NULL;
         END LOOP; -- END LOOP FOR the batch FOR C
      END IF;  -- END order_num EXISTS  IF B

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

      -- After all the processes are done, call claim autopay
      l_claim_rec.cust_account_id      := l_partner_cust_account_id;
      l_claim_rec.source_object_class  := OZF_RESALE_COMMON_PVT.G_BATCH_OBJECT_CLASS;
      l_claim_rec.source_object_id     := p_resale_batch_id;
      l_claim_rec.source_object_number := l_batch_number;
      l_claim_rec.batch_id             := p_resale_batch_id;
      l_claim_rec.batch_type           := OZF_RESALE_COMMON_PVT.G_BATCH_REF_TYPE;
      l_claim_rec.customer_ref_number  := l_partner_claim_num;
      l_claim_rec.currency_code        := l_currency_code;
      l_funds_util_flt.cust_account_id := l_partner_cust_account_id;
      l_funds_util_flt.utiz_currency_code := l_currency_code ; --Fix for 9662148
      --Bug# 8632964 fixed by anuj and muthu (+)
      IF l_accrual_flag = 'T' THEN
      l_funds_util_flt.reference_type  := OZF_RESALE_COMMON_PVT.G_BATCH_REF_TYPE;
      l_funds_util_flt.reference_id    := p_resale_batch_id;
      l_funds_util_flt.utilization_type:= G_CHBK_UTIL_TYPE;
         IF OZF_DEBUG_HIGH_ON THEN
            OZF_UTILITY_PVT.debug_message('Accruals created for this batch should be used.');
         END IF;
      ELSE
         l_funds_util_flt.fund_id            := l_chargeback_fund_id;
         l_funds_util_flt.product_level_type := 'PRODUCT';
         IF OZF_DEBUG_HIGH_ON THEN
            OZF_UTILITY_PVT.debug_message('Existing accruals of chargeback budget should be used.');
         END IF;
      END IF;
      --Bug# 8632964 fixed by anuj and muthu (-)
      OZF_Claim_Accrual_PVT.Pay_Claim_for_Accruals(
          p_api_version       => 1.0
         ,p_init_msg_list     => FND_API.g_false
         ,p_commit            => FND_API.g_false
         ,p_validation_level  => FND_API.g_valid_level_full
	 ,p_accrual_flag      => l_accrual_flag
         ,x_return_status     => l_return_status
         ,x_msg_count         => l_msg_count
         ,x_msg_data          => l_msg_data
         ,p_claim_rec         => l_claim_rec
         ,p_funds_util_flt    => l_funds_util_flt
         ,x_claim_id          => l_claim_id
      );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;


      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('new claim_id:' || l_claim_id);
      END IF;

      -- Claim is created successfully.
      IF l_claim_id IS NOT NULL THEN
         -- get claimed amount
         OPEN claimed_amount_csr(l_claim_id);
         FETCH claimed_amount_csr INTO l_amount_claimed;
         CLOSE claimed_amount_csr;

         BEGIN
            -- BUG 4395931 (+)
            UPDATE ozf_resale_lines_int
            SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_CLOSED
            WHERE resale_batch_id = p_resale_batch_id
            AND status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED;

            /*
            -- SLKRISHN change to common procedure
            UPDATE ozf_resale_lines_int
               SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_CLOSED
             WHERE resale_batch_id = p_resale_batch_id
               AND status_code in(OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DUPLICATED, OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED);
               --AND duplicated_adjustment_id <> -1;
            */
            -- BUG 4395931 (-)

            -- UPDATE batch status to closed -- might change later.
            UPDATE ozf_resale_batches
            SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_CLOSED,
            paid_amount = l_amount_claimed
            WHERE resale_batch_id = p_resale_batch_id;

         EXCEPTION
            WHEN OTHERS THEN
               OZF_UTILITY_PVT.error_message('OZF_UPD_RESALE_WRG','TEXT',l_full_name||': End');
               RAISE FND_API.g_exc_unexpected_error;
         END;

         -- mchang: Run Third Party Accrual After Chargeback Calculation was
         --         done in workflow already. No need to check here.
         /*
         --  ??????? Need to think whether there IS a better way ---
         -- Once the autopay was successful, check options whether to start chargeback
         OPEN auto_tp_accrual_csr;
         FETCH auto_tp_accrual_csr INTO l_auto_tp_accrual;
         CLOSE auto_tp_accrual_csr;
         */
      END IF;
      --         END IF; -- END if not rejected
   END IF; -- END IF batch processed or disputed

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': End');
   END IF;

   --Standard call to get message count AND if count=1, get the message
   FND_MSG_PUB.Count_and_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
   );

EXCEPTION
   WHEN error_no_rollback THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Initiate_Payment;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Initiate_Payment;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Initiate_Payment;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
END Initiate_Payment;

---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Order_Record
--
-- PURPOSE
--    ThIS procedure validates the order information
--    These are validation specific to chargeback process
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Validate_Order_Record(
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN  NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)IS
l_api_name          CONSTANT VARCHAR2(30) := 'Validate_Order_Record';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_id_tbl  OZF_RESALE_COMMON_PVT.number_tbl_type;
l_err_tbl OZF_RESALE_COMMON_PVT.varchar_tbl_type;
l_col_tbl OZF_RESALE_COMMON_PVT.varchar_tbl_type;
l_val_tbl OZF_RESALE_COMMON_PVT.long_varchar_tbl_type;
l_return_status     VARCHAR2(1);
--
   CURSOR null_columns_csr (p_batch_id in number) IS
   SELECT resale_line_int_id,
          'OZF_RESALE_PUR_PRICE_MISSING',
          'PURCHASE_PRICE',
          NULL
     FROM ozf_resale_lines_int_all
    WHERE resale_batch_id = p_batch_id
      AND status_code IN (OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_OPEN, OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED)
      AND tracing_flag = 'F'
      AND purchase_price IS NULL;

--
BEGIN
   -- Standard call to check FOR call compatibility.
   IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
   THEN
       RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;

   --Initialize message lISt if p_init_msg_list IS TRUE.
   IF FND_API.To_BOOLEAN (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- bulk select all lines with missing order numbers
   IF l_id_tbl.EXISTS(1) THEN
      l_id_tbl.DELETE;
   END IF;
   IF l_err_tbl.EXISTS(1) THEN
      l_err_tbl.DELETE;
   END IF;
   IF l_col_tbl.EXISTS(1) THEN
      l_col_tbl.DELETE;
   END IF;
   IF l_val_tbl.EXISTS(1) THEN
      l_val_tbl.DELETE;
   END IF;
   OPEN null_columns_csr (p_resale_batch_id);
   FETCH null_columns_csr BULK COLLECT INTO l_id_tbl, l_err_tbl, l_col_tbl, l_val_tbl;
   CLOSE null_columns_csr;
   --

   -- log disputed lines
   OZF_RESALE_COMMON_PVT.Bulk_Insert_Resale_Log (
      p_id_value      => l_id_tbl,
      p_id_type       => OZF_RESALE_COMMON_PVT.G_ID_TYPE_IFACE,
      p_error_code    => l_err_tbl,
      p_column_name   => l_col_tbl,
      p_column_value  => l_val_tbl,
      p_batch_id      => p_resale_batch_id, --bug # 5997978 fixed
      x_return_status => l_return_status
   );

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
   --

   OZF_RESALE_COMMON_PVT.Bulk_Dispute_Line (
      p_batch_id      => p_resale_batch_id,
      p_line_status   => OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_OPEN,
      x_return_status => l_return_status
   );
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
   --

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': End');
   END IF;

   --Standard call to get message count AND if count=1, get the message
   FND_MSG_PUB.Count_and_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data
   );
--
EXCEPTION
   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count AND if count=1, get the message
      FND_MSG_PUB.Count_and_Get (
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count AND if count=1, get the message
      FND_MSG_PUB.Count_and_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count AND if count=1, get the message
      FND_MSG_PUB.Count_and_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
END Validate_Order_Record;

---------------------------------------------------------------------
-- PROCEDURE
--    Process_Pricing_Result
--
-- PURPOSE
--    ThIS procedure process the pricing call result. It creates accruals based
--    on the dIScount information.
--
-- PARAMETERS
--   p_resale_batch_id   IN NUMBER,
--   p_line_tbl          IN OZF_ORDER_PRICE_PVT.line_rec_tbl_type,
--   p_inventory_tracking IN VARCHAR2,
--   x_return_status  out VARCHAR2
--
-- NOTES
--   1. Non-monetray accruals have NOT been considered. Should look INTO ldets.benefit_qty
--      AND ldets.benefit_uom FOR calculation.
--
---------------------------------------------------------------------
PROCEDURE Process_Pricing_Result (
   p_resale_batch_id   IN NUMBER,
   p_line_tbl          IN OZF_ORDER_PRICE_PVT.line_rec_tbl_type,
   p_inventory_tracking IN VARCHAR2,
   x_return_status     OUT NOCOPY VARCHAR2
)
IS
--
l_api_name          CONSTANT VARCHAR2(30) := 'Process_Pricing_Result';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER;
l_return_status VARCHAR2(30);
--
l_order_number  VARCHAR2(30);
l_cust_account_id  NUMBER;
l_date_ordered DATE;
l_has_error BOOLEAN:=false;
l_log_id NUMBER;
l_resale_int_rec OZF_RESALE_COMMON_PVT.g_interface_rec_csr%ROWTYPE;
l_header_id NUMBER;
l_line_id   NUMBER;
l_object_version_number NUMBER :=1;

l_default_exchange_type VARCHAR2(30);
l_exchange_type VARCHAR2(30);
l_exchange_date DATE;
l_acctd_adj_unit_price NUMBER;
l_acctd_selling_price NUMBER;
l_rate NUMBER;
l_func_currency_code VARCHAR2(15);
l_IS_error BOOLEAN:=FALSE;
l_inventory_level_valid BOOLEAN;
l_allowed_amount NUMBER;

l_id_tbl OZF_RESALE_COMMON_PVT.number_tbl_type;
l_err_tbl OZF_RESALE_COMMON_PVT.varchar_tbl_type;
l_col_tbl OZF_RESALE_COMMON_PVT.varchar_tbl_type;
l_val_tbl OZF_RESALE_COMMON_PVT.long_varchar_tbl_type;
--
CURSOR order_identifiers_csr (p_id IN NUMBER) IS
SELECT order_number
     , sold_from_cust_account_id
     , date_ordered
  FROM ozf_resale_lines_int
 WHERE resale_line_int_id = p_id;

CURSOR func_currency_cd_csr IS
  SELECT gs.currency_code
  FROM gl_sets_of_books gs,
       ozf_sys_parameters osp
  WHERE gs.set_of_books_id = osp.set_of_books_id
  AND osp.org_id = MO_GLOBAL.get_current_org_id();

CURSOR open_lines_csr(p_order_number VARCHAR2,
                      p_date_ordered DATE,
                      p_cust_account_id NUMBER )IS
SELECT resale_line_int_id, 'OZF_RESALE_PRICE_ERROR', NULL, NULL
  FROM ozf_resale_lines_int
WHERE status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_OPEN
AND order_number = l_order_number
AND date_ordered = l_date_ordered
AND sold_from_cust_account_id =l_cust_account_id
AND dispute_code is null
AND resale_batch_id = p_resale_batch_id;

l_unit_purchase_price number;
l_uom_ratio number;
BEGIN
   SAVEPOINT  Process_Pricing_Result;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;

   -- First check whether the order result collection EXISTS or NOT
   IF p_line_tbl.EXISTS(1) THEN

      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('There is one line');
      END IF;

      OPEN order_identifiers_csr(p_line_tbl(1).chargeback_int_id);
      FETCH order_identifiers_csr INTO l_order_number, l_cust_account_id, l_date_ordered;
      CLOSE order_identifiers_csr;

      -- LOOP through the result to find if there is an error in the result.
      FOR i in 1..p_line_tbl.LAST
      LOOP
         l_is_error := p_line_tbl(i).pricing_status_code <> QP_PREQ_PUB.G_STATUS_NEW AND
                       p_line_tbl(i).pricing_status_code <> QP_PREQ_PUB.G_STATUS_UNCHANGED AND
                       p_line_tbl(i).pricing_status_code <> QP_PREQ_PUB.G_STATUS_UPDATED;
         IF OZF_DEBUG_LOW_ON THEN
            OZF_UTILITY_PVT.debug_message('pricing status code ' || p_line_tbl(i).pricing_status_code);
         END IF;

         IF l_is_error then
            IF OZF_DEBUG_LOW_ON THEN
               OZF_UTILITY_PVT.debug_message('line '||p_line_tbl(i).chargeback_int_id || ' has pricing error' );
            END IF;
            BEGIN
               update ozf_resale_lines_int
               set status_code =OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED,
                   dispute_code = 'OZF_RESALE_PRICE_ERROR',
                   followup_action_code = 'C',
                   response_type = 'CA',
                   response_code = 'N'
               where resale_line_int_id = p_line_tbl(i).chargeback_int_id;
            EXCEPTION
               WHEN OTHERS THEN
                  ozf_utility_pvt.error_message('OZF_UPD_RESALE_INT_WRG');
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END;

            OZF_RESALE_COMMON_PVT.Insert_Resale_Log (
               p_id_value      => p_line_tbl(i).chargeback_int_id,
               p_id_type       => OZF_RESALE_COMMON_PVT.G_ID_TYPE_IFACE,
               p_error_code    => p_line_tbl(i).pricing_status_code,
               p_error_message => p_line_tbl(i).pricing_status_text,
               p_column_name   => NULL,
               p_column_value  => NULL,
               x_return_status => l_return_status);
            --
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

            OZF_RESALE_COMMON_PVT.Insert_Resale_Log (
               p_id_value      => p_line_tbl(i).chargeback_int_id,
               p_id_type       => OZF_RESALE_COMMON_PVT.G_ID_TYPE_IFACE,
               p_error_code    => 'OZF_RESALE_PRICE_ERROR',
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
         END IF;

         -- If there IS an error, remember it
         l_has_error := l_has_error OR l_is_error;
      END LOOP;

      IF l_has_error THEN
         IF l_id_tbl.EXISTS(1) THEN
            l_id_tbl.DELETE;
         END IF;
         IF l_err_tbl.EXISTS(1) THEN
            l_err_tbl.DELETE;
         END IF;
         IF l_col_tbl.EXISTS(1) THEN
            l_col_tbl.DELETE;
         END IF;
         IF l_val_tbl.EXISTS(1) THEN
            l_val_tbl.DELETE;
         END IF;
         OPEN open_lines_csr (l_order_number, l_date_ordered, l_cust_account_id);
         FETCH open_lines_csr BULK COLLECT INTO l_id_tbl, l_err_tbl, l_col_tbl, l_val_tbl;
         CLOSE open_lines_csr;

         -- log disputed lines
         OZF_RESALE_COMMON_PVT.Bulk_Insert_Resale_Log (
            p_id_value      => l_id_tbl,
            p_id_type       => OZF_RESALE_COMMON_PVT.G_ID_TYPE_IFACE,
            p_error_code    => l_err_tbl,
            p_column_name   => l_col_tbl,
            p_column_value  => l_val_tbl,
            p_batch_id      => p_resale_batch_id, --bug # 5997978 fixed
            x_return_status => l_return_status
         );
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         BEGIN
            UPDATE ozf_resale_lines_int_all
            SET status_code =OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED,
                dispute_code = 'OZF_RESALE_PRICE_ERROR',
                followup_action_code = 'C',
                response_type = 'CA',
                response_code = 'N'
            WHERE status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_OPEN
            AND order_number = l_order_number
            AND date_ordered = l_date_ordered
            AND sold_from_cust_account_id =l_cust_account_id
            AND dispute_code is null
            AND resale_batch_id = p_resale_batch_id;
         EXCEPTION
            WHEN OTHERS THEN
              ozf_utility_pvt.error_message( 'OZF_UPD_RESALE_INT_WRG');
              RAISE FND_API.g_exc_unexpected_error;
         END;

      ELSE
         -- There is no error in the result. We need to process the result one by one.
         IF OZF_DEBUG_LOW_ON THEN
            OZF_UTILITY_PVT.debug_message('No Error in the result' );
         END IF;

         -- get functional currency code AND convertion type
         OPEN func_currency_cd_csr;
         FETCH func_currency_cd_csr INTO l_func_currency_code;
         CLOSE func_currency_cd_csr;

         OPEN OZF_RESALE_COMMON_PVT.g_exchange_rate_type_csr;
         FETCH OZF_RESALE_COMMON_PVT.g_exchange_rate_type_csr INTO l_default_exchange_type;
         CLOSE OZF_RESALE_COMMON_PVT.g_exchange_rate_type_csr;

         -- FOR each chargeback of the line, we will UPDATE the line
         FOR i in 1..p_line_tbl.LAST LOOP
            IF p_line_tbl(i).line_type_code = 'LINE' THEN
               OPEN OZF_RESALE_COMMON_PVT.g_interface_rec_csr(p_line_tbl(i).chargeback_int_id);
               FETCH OZF_RESALE_COMMON_PVT.g_interface_rec_csr INTO l_resale_int_rec;
               CLOSE OZF_RESALE_COMMON_PVT.g_interface_rec_csr;

               -- Check inventory level FOR thIS order.
               -- If inventory level IS lower than the asked, then there IS no need to
               -- continue processing
               IF p_inventory_tracking = 'T' AND
                  l_resale_int_rec.duplicated_line_id IS NULL AND
                  (   l_resale_int_rec.duplicated_adjustment_id IS NULL
                   OR l_resale_int_rec.duplicated_adjustment_id = -1 ) THEN
                  IF OZF_DEBUG_LOW_ON THEN
                     OZF_UTILITY_PVT.debug_message('Need inventory tracking' );
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
                        OZF_UTILITY_PVT.debug_message('Did not pass inventory checking');
                     END IF;
                     --
                     OZF_RESALE_COMMON_PVT.Insert_Resale_Log (
                        p_id_value      => p_line_tbl(i).chargeback_int_id,
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
                     UPDATE ozf_resale_lines_int
                        SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED,
                            dispute_code = 'OZF_LT_INVT',
                            followup_action_code = 'C',
                            response_type = 'CA',
                            response_code = 'N'
                      WHERE resale_line_int_id = l_resale_int_rec.resale_line_int_id;

                     UPDATE ozf_resale_batches
                        SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_DISPUTED
                      WHERE resale_batch_id = l_resale_int_rec.resale_batch_id;
                     --
                     GOTO END_LOOP3;
                  ELSE
                     IF OZF_DEBUG_LOW_ON THEN
                        OZF_UTILITY_PVT.debug_message('Pass inventory test' );
                     END IF;
                  END IF;
                  --
               END IF;

               -- Check WAC
               --END IF;

               -- Convert the adjusted amount to functional currency code.
               l_exchange_type := l_resale_int_rec.exchange_rate_type;
               l_exchange_date := l_resale_int_rec.exchange_rate_date;
               l_rate          := l_resale_int_rec.exchange_rate;
               IF l_func_currency_code <> l_resale_int_rec.CURRENCY_CODE THEN
                  IF l_rate IS NULL THEN
                     IF l_exchange_type IS NULL THEN
                        l_exchange_type := l_default_exchange_type;
                     END IF;

                     IF l_exchange_type IS NULL THEN
                        OZF_UTILITY_PVT.error_message('OZF_CLAIM_CONTYPE_MISSING');
                        RAISE FND_API.g_exc_unexpected_error;
                     END IF;

                     IF l_exchange_date IS NULL THEN
                        l_exchange_date := sysdate;
                     END IF;
                     IF OZF_DEBUG_LOW_ON THEN
                        OZF_UTILITY_PVT.debug_message('FROM currency:' || l_resale_int_rec.currency_code);
                        OZF_UTILITY_PVT.debug_message('to currency:' || l_func_currency_code);
                        OZF_UTILITY_PVT.debug_message('rate:' || l_rate);
                        OZF_UTILITY_PVT.debug_message('exchange DATE:' || l_exchange_date);
                        OZF_UTILITY_PVT.debug_message('exchange type:' || l_exchange_type);
                     END IF;

                     -- convert unit price
                     OZF_UTILITY_PVT.Convert_Currency(
                         p_from_currency   => l_resale_int_rec.CURRENCY_CODE
                        ,p_to_currency     => l_func_currency_code
                        ,p_conv_type       => l_exchange_type
                        ,p_conv_rate       => l_rate
                        ,p_conv_date       => l_exchange_date
                        ,p_from_amount     => p_line_tbl(i).unit_price
                        ,x_return_status   => l_return_status
                        ,x_to_amount       => l_acctd_adj_unit_price
                        ,x_rate            => l_rate);
                     IF l_return_status = FND_API.g_ret_sts_error THEN
                        RAISE FND_API.g_exc_error;
                     ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                        RAISE FND_API.g_exc_unexpected_error;
                     END IF;

                     -- convert adjusted selling price
                     OZF_UTILITY_PVT.Convert_Currency(
                         p_from_currency   => l_resale_int_rec.CURRENCY_CODE
                        ,p_to_currency     => l_func_currency_code
                        ,p_conv_type       => l_exchange_type
                        ,p_conv_rate       => l_rate
                        ,p_conv_date       => l_exchange_date
                        ,p_from_amount     => l_resale_int_rec.selling_price
                        ,x_return_status   => l_return_status
                        ,x_to_amount       => l_acctd_selling_price
                        ,x_rate            => l_rate);
                     IF l_return_status = FND_API.g_ret_sts_error THEN
                        RAISE FND_API.g_exc_error;
                     ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                        RAISE FND_API.g_exc_unexpected_error;
                     END IF;
                  ELSE
                     l_acctd_adj_unit_price := OZF_UTILITY_PVT.CurrRound(p_line_tbl(i).unit_price*l_rate, l_func_currency_code);
                     l_acctd_selling_price := OZF_UTILITY_PVT.CurrRound(l_resale_int_rec.selling_price*l_rate, l_func_currency_code);
                  END IF;
               ELSE
                  l_rate := 1;
                  l_acctd_adj_unit_price := p_line_tbl(i).unit_price;
                  l_acctd_selling_price := l_resale_int_rec.selling_price;
               END IF;

               -- In case of chargeback, we will not create resale lines and adjustments right away.
               l_line_id := l_resale_int_rec.resale_line_int_id;
               l_resale_int_rec.exchange_rate := l_rate;
               l_resale_int_rec.exchange_rate_date := l_exchange_date;
               l_resale_int_rec.exchange_rate_type := l_exchange_type;
               l_resale_int_rec.acctd_calculated_price := l_acctd_adj_unit_price;
               l_resale_int_rec.acctd_selling_price := l_acctd_selling_price;

               -- First check the difference between purchase uom and uom
               IF l_resale_int_rec.purchase_uom_code = l_resale_int_rec.uom_code THEN
                  l_unit_purchase_price := l_resale_int_rec.purchase_price;
               ELSE
                  l_uom_ratio := inv_convert.inv_um_convert(
                           l_resale_int_rec.inventory_item_id,
                           null,
                           1,
                           l_resale_int_rec.purchase_uom_code,
                           l_resale_int_rec.uom_code,
                           null, null);
                  l_unit_purchase_price := OZF_UTILITY_PVT.CurrRound(l_resale_int_rec.purchase_price/l_uom_ratio
                                 , l_resale_int_rec.currency_code);
               END IF;

               IF OZF_DEBUG_LOW_ON THEN
                  OZF_UTILITY_PVT.debug_message('Unit Purchase Price:' || l_unit_purchase_price);
               END IF;
               -- Get allowed amount
               IF p_line_tbl(i).unit_price < l_unit_purchase_price THEN
                  IF SIGN(p_line_tbl(i).line_quantity) = -1 THEN
                     l_allowed_amount := (l_unit_purchase_price - p_line_tbl(i).unit_price) * -1;
                  ELSE
                     l_allowed_amount := l_unit_purchase_price - p_line_tbl(i).unit_price;
                  END IF;

               ELSE
                  l_allowed_amount := 0;
               END IF;

               IF OZF_DEBUG_LOW_ON THEN
                  OZF_UTILITY_PVT.debug_message('Allowed amount:' || l_allowed_amount);
               END IF;

               -- Update the results of Chargeback Calculation
               OZF_RESALE_COMMON_PVT.Update_Line_Calculations(
                  p_resale_line_int_rec => l_resale_int_rec,
                  p_unit_price          => p_line_tbl(i).unit_price,
                  p_line_quantity       => p_line_tbl(i).line_quantity,
                  p_allowed_amount      => l_allowed_amount,
                  x_return_status       => l_return_status);
               --
               IF l_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               END IF;
               --
            END IF; -- END if current record IS a line
            << END_LOOP3>>
            NULL;
         END LOOP; -- END LOOP through lines

         -- Dispute all the lines from this order
         OZF_RESALE_COMMON_PVT.Bulk_Dispute_Line (
            p_batch_id      => p_resale_batch_id,
            p_line_status   => OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_OPEN,
            x_return_status => l_return_status
         );
         --
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
         --
      END IF; -- END of l_has_error
   ELSE
      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('There is no line to be processed');
      END IF;
   END IF; -- END of EXISTS

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': End');
   END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Process_Pricing_Result;
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Process_Pricing_Result;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      ROLLBACK TO Process_Pricing_Result;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
END Process_Pricing_Result;

---------------------------------------------------------------------
-- PROCEDURE
--    Get_Order_Price
--
-- PURPOSE
--    Process order information to get agreemenet price
--
-- PARAMETERS
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE Get_Order_Price (
   p_resale_batch_id        IN  NUMBER,
   p_order_number           IN  VARCHAR2,
   p_sold_from_cust_acct_id IN  NUMBER,
   p_date_ordered           IN  DATE,
   x_line_tbl               OUT NOCOPY OZF_ORDER_PRICE_PVT.line_rec_tbl_type,
   x_ldets_tbl              OUT NOCOPY OZF_ORDER_PRICE_PVT.LDETS_TBL_TYPE,
   x_related_lines_tbl      OUT NOCOPY OZF_ORDER_PRICE_PVT.RLTD_LINE_TBL_TYPE,
   x_return_status          OUT NOCOPY VARCHAR2
)
IS
--
l_api_name          CONSTANT VARCHAR2(30) := 'Get_Order_Price';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER;
l_return_status VARCHAR2(30);
--
l_line_tbl          OZF_ORDER_PRICE_PVT.LINE_REC_TBL_TYPE;
l_ldets_tbl         OZF_ORDER_PRICE_PVT.LDETS_TBL_TYPE;
l_related_lines_tbl OZF_ORDER_PRICE_PVT.RLTD_LINE_TBL_TYPE;
l_control_rec       QP_PREQ_GRP.CONTROL_RECORD_TYPE;
--
l_line_count        NUMBER;
J  NUMBER;
K  NUMBER;
l_price_flag VARCHAR2(1) := NULL;
--
CURSOR order_set_csr(p_order_number IN VARCHAR2,
                     p_id           IN NUMBER,
                     p_date         IN DATE,
                     p_batch_id     IN NUMBER ) IS
SELECT *
  FROM ozf_resale_lines_int
 WHERE order_number = p_order_number
   AND sold_from_cust_account_id= p_id
   AND date_ordered = p_date
   AND status_code = 'OPEN'
--   AND status_code in(OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_OPEN, OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DUPLICATED)
--   AND duplicated_adjustment_id IS NULL
-- bug # 6821886 fixed by ateotia (+)
   AND resale_batch_id = p_batch_id;
   --AND tracing_flag = 'F';
-- bug # 6821886 fixed by ateotia (-)

TYPE order_set_tbl IS TABLE OF order_set_csr%ROWTYPE INDEX BY BINARY_INTEGER;

l_order_set_tbl order_set_tbl;

-- bug 6511302 (+) need to validate inventory for tracing lines
CURSOR c_order_set_trc(p_order_number IN VARCHAR2,
                     p_id           IN NUMBER,
                     p_date         IN DATE,
                     p_batch_id     IN NUMBER ) IS
SELECT *
FROM   ozf_resale_lines_int
WHERE  order_number = p_order_number
AND    sold_from_cust_account_id= p_id
AND    date_ordered = p_date
AND    status_code = 'OPEN'
AND    resale_batch_id = p_batch_id
AND    tracing_flag = 'T';

TYPE order_set_trc_tbl IS TABLE OF c_order_set_trc%ROWTYPE INDEX BY BINARY_INTEGER;

l_order_set_trc_tbl     order_set_trc_tbl;
l_inventory_tracking    VARCHAR2(2);
l_inventory_level_valid BOOLEAN;
l_resale_int_rec        OZF_RESALE_COMMON_PVT.g_interface_rec_csr%ROWTYPE;
-- 6511302 (-)

--
BEGIN
   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;

   SAVEPOINT Get_Order_Price;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- bug 6511302 (+) validate inventory for tracing lines
  OPEN OZF_RESALE_COMMON_PVT.g_inventory_tracking_csr;
  FETCH OZF_RESALE_COMMON_PVT.g_inventory_tracking_csr INTO l_inventory_tracking;
  CLOSE OZF_RESALE_COMMON_PVT.g_inventory_tracking_csr;

  IF l_inventory_tracking = 'T' THEN -- validate inventory for tracing lines. order lines will be validated during pricing phase
    OPEN c_order_set_trc(p_order_number,
                         p_sold_from_cust_acct_id,
                         p_date_ordered,
                         p_resale_batch_id);
    FETCH c_order_set_trc BULK COLLECT INTO l_order_set_trc_tbl;
    CLOSE c_order_set_trc;

    IF  l_order_set_trc_tbl.COUNT > 0 THEN
      FOR i IN 1..l_order_set_trc_tbl.COUNT LOOP
        OZF_UTILITY_PVT.debug_message(l_full_name || ' Validating tracing line ' || l_order_set_trc_tbl(i).resale_line_int_id);
        OPEN  OZF_RESALE_COMMON_PVT.g_interface_rec_csr(l_order_set_trc_tbl(i).resale_line_int_id);
        FETCH OZF_RESALE_COMMON_PVT.g_interface_rec_csr INTO l_resale_int_rec;
        CLOSE OZF_RESALE_COMMON_PVT.g_interface_rec_csr;

        IF l_resale_int_rec.duplicated_adjustment_id IS NULL OR l_resale_int_rec.duplicated_adjustment_id = -1 THEN
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
              OZF_UTILITY_PVT.debug_message('Did NOT pass inventory checking');
            END IF;

            -- log
            OZF_RESALE_COMMON_PVT.Insert_Resale_Log (
                        p_id_value      => l_order_set_trc_tbl(i).resale_line_int_id,
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

            -- Set line to DISPUTED
            UPDATE ozf_resale_lines_int
            SET    status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED,
                   dispute_code = 'OZF_LT_INVT',
                   followup_action_code = 'C',
                   response_type = 'CA',
                   response_code = 'N'
            WHERE  resale_line_int_id = l_resale_int_rec.resale_line_int_id;

            -- SET Batch as DISPUTED
            UPDATE ozf_resale_batches
            SET    status_code = OZF_RESALE_COMMON_PVT.G_BATCH_DISPUTED
            WHERE  resale_batch_id = l_resale_int_rec.resale_batch_id;
          END IF;
        END IF;
      END LOOP;
    END IF;
  END IF;
  -- bug 6511302 (-)

   -- Define control rec
   -- setup pricing_event based on purpose code AND profile
   -- privcing_event = 'PRICE' FOR chargeback
   l_control_rec.pricing_event := G_PRICING_EVENT;
   --l_control_rec.pricing_event := 'BATCH';
   l_control_rec.calculate_flag := 'Y';
   l_control_rec.simulation_flag := 'Y';
   l_control_rec.source_order_amount_flag := 'Y';
   l_control_rec.gsa_check_flag := 'N';
   l_control_rec.gsa_dup_check_flag := 'N';
   l_control_rec.temp_table_insert_flag := 'N';

   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message('Event:' ||l_control_rec.pricing_event );
   END IF;

   -- Price flag has to be Y to get the price.
   l_price_flag := 'Y';

   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message('Price flag:' ||l_price_flag );
   END IF;

   QP_Price_Request_Context.Set_Request_Id;

   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message('/*--- Processing order for order number:'||p_order_number||'---*/');
      OZF_UTILITY_PVT.debug_message('/*--- and cusomter:'||p_sold_from_cust_acct_id||'---*/');
   END IF;

   -- Before start process, clean up the data structures if necessary.
   IF l_order_set_tbl.EXISTS(1) THEN l_order_set_tbl.DELETE; END IF;
   IF l_line_tbl.EXISTS(1)      THEN l_line_tbl.DELETE; END IF;
   IF l_ldets_tbl.EXISTS(1)      THEN l_ldets_tbl.DELETE; END IF;
   IF l_related_lines_tbl.EXISTS(1) THEN l_related_lines_tbl.DELETE; END IF;
   IF OZF_ORDER_PRICE_PVT.g_line_rec_tbl.EXISTS(1) THEN OZF_ORDER_PRICE_PVT.g_line_rec_tbl.DELETE; END IF;

   -- Get all lines in an order
   --l_line_count := 1;
   OPEN order_set_csr(p_order_number,
                      p_sold_from_cust_acct_id,
                      p_date_ordered,
                      p_resale_batch_id);
   FETCH order_set_csr BULK COLLECT INTO l_order_set_tbl;
   --LOOP
   --   FETCH order_set_csr INTO l_order_set_tbl(l_line_count);
   --   EXIT WHEN order_set_csr%NOTFOUND;
   --   l_line_count := l_line_count + 1;
   --END LOOP;
   CLOSE order_set_csr;

   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message('after order set'||l_order_set_tbl.count);
   END IF;

   IF l_order_set_tbl.EXISTS(1) THEN
      FOR J in 1..l_order_set_tbl.LAST
      LOOP
         --  Purge the any error message that might be there.
         BEGIN
            -- SLKRISHN move to a common procedure
            DELETE FROM ozf_resale_logs
             WHERE resale_id = l_order_set_tbl(J).resale_line_int_id
               AND resale_id_type = OZF_RESALE_COMMON_PVT.G_ID_TYPE_IFACE;
         EXCEPTION
            WHEN OTHERS THEN
               IF OZF_UNEXP_ERROR THEN
                  FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
               END IF;
               RAISE FND_API.g_exc_unexpected_error;
         END;
         IF OZF_DEBUG_LOW_ON THEN
            OZF_UTILITY_PVT.debug_message('/*--- Buidling order line info for inteface id:  '||l_order_set_tbl(J).resale_line_int_id ||'---*/');
         END IF;

         -- insert INTO l_line_tbl
         l_line_tbl(J).line_index               := J;
         l_line_tbl(J).line_id                  := NULL;
         l_line_tbl(J).line_type_code           := OZF_ORDER_PRICE_PVT.G_ORDER_LINE_TYPE;
         l_line_tbl(J).pricing_effective_date   := l_order_set_tbl(J).date_ordered;
         l_line_tbl(J).active_date_first        := l_order_set_tbl(J).date_ordered;
         l_line_tbl(J).active_date_first_type   := 'ORD';
         l_line_tbl(J).active_date_second       := l_order_set_tbl(J).date_shipped;
         l_line_tbl(J).active_date_second_type  := 'SHIP';
         l_line_tbl(J).line_quantity            := l_order_set_tbl(J).Quantity;
         l_line_tbl(J).line_uom_code            := l_order_set_tbl(J).uom_code;
         l_line_tbl(J).request_type_code        := 'ONT';
         l_line_tbl(J).priced_quantity          := NULL;
         l_line_tbl(J).priced_uom_code          := NULL;
         l_line_tbl(J).unit_price               := NULL;
         l_line_tbl(J).currency_code            := l_order_set_tbl(J).currency_code;
         --l_line_tbl(J).unit_price              := NULL;
         --l_line_tbl(J).percent_price           := NULL;
         --l_line_tbl(J).uom_quantity            := NULL;
         --l_line_tbl(J).adjusted_unit_price     := NULL;
         --l_line_tbl(J).upd_adjusted_unit_price := FND_API.G_MISS_NUM,
         --l_line_tbl(J).processed_flag          := FND_API.G_MISS_CHAR,
         l_line_tbl(J).price_flag               := l_price_flag;
         --l_line_tbl(J).processing_order        := NULL;
         l_line_tbl(J).pricing_status_code      := QP_PREQ_GRP.G_STATUS_UNCHANGED;
         --l_line_tbl(J).pricing_status_text       := NULL;
         --l_line_tbl(J).rounding_flag             := NULL;
         --l_line_tbl(J).rounding_factor           := NULL;
         --l_line_tbl(J).qualifiers_EXIST_flag     := NULL;
         --l_line_tbl(J).pricing_attrs_EXIST_flag  := NULL;
         IF l_order_set_tbl(J).corrected_agreement_id IS NOT NULL THEN
            l_line_tbl(J).price_list_id            := l_order_set_tbl(J).corrected_agreement_id;
         ELSE
            l_line_tbl(J).price_list_id            := l_order_set_tbl(J).agreement_id;
         END IF;
         --l_line_tbl(J).pl_VALIDATED_flag         := NULL;
         --l_line_tbl(J).price_request_code        := NULL;
         --l_line_tbl(J).usage_pricing_type        := NULL;
         --l_line_tbl(J).line_category             := NULL;
         l_line_tbl(J).chargeback_int_id        := l_order_set_tbl(J).resale_line_int_id;
         l_line_tbl(J).resale_table_type        := 'IFACE'; -- bug 5360598

         -- populate the order_price global line arrary
         -- Here I only populate the values of the qualifiers FOR ONT.
         -- The real global structure will be populate in ozf_order_price_pvt.
         -- AND it's value can be change in OZF_CHARGEBACK_ATTRMAP_PUB

         OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(J).header_id         := l_order_set_tbl.LAST +1;
         OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(J).inventory_item_id := l_order_set_tbl(J).inventory_item_id;
         OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(J).line_id           := NULL;
         OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(J).ordered_quantity  := l_order_set_tbl(J).quantity;
         OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(J).order_quantity_uom := l_order_set_tbl(J).uom_code;

         IF l_order_set_tbl(J).corrected_agreement_id IS NOT NULL THEN
            OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(J).price_list_id := l_order_set_tbl(J).corrected_agreement_id;
         ELSE
            OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(J).price_list_id := l_order_set_tbl(J).agreement_id;
         END IF;

         OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(J).request_date      := l_order_set_tbl(J).date_ordered;
         OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(J).invoice_to_org_id := l_order_set_tbl(J).bill_to_site_use_id;
         OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(J).ship_to_org_id    := l_order_set_tbl(J).ship_to_site_use_id;
         OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(J).sold_to_org_id    := l_order_set_tbl(J).bill_to_cust_account_id;
         -- [BEGIN OF BUG 4186465 FIXING]
         OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(J).invoice_to_party_id      := l_order_set_tbl(J).bill_to_party_id;
         OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(J).invoice_to_party_site_id := l_order_set_tbl(J).bill_to_party_site_id;
         OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(J).ship_to_party_id         := l_order_set_tbl(J).ship_to_party_id;
         OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(J).ship_to_party_site_id    := l_order_set_tbl(J).ship_to_party_site_id;
         -- [END OF BUG 4186465 FIXING]
         -- OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(J).sold_from_org_id  := l_order_set_tbl(J).sold_from_cust_account_id;
         OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(J).actual_shipment_date  := l_order_set_tbl(J).date_shipped;
         OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(J).pricing_date := l_order_set_tbl(J).date_ordered;
         OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(J).line_type_id := l_order_set_tbl(J).order_type_id;


         -- R12 Populate Global Resale Structure (+)
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).batch_type                     := 'CHARGEBACK';
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).qp_context_request_id          := QP_Price_Request_Context.Get_Request_Id;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).line_index                     := l_line_tbl(J).line_index;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).resale_table_type              := 'IFACE';
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).line_id                        := l_order_set_tbl(J).resale_line_int_id;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).resale_transfer_type           := l_order_set_tbl(J).resale_transfer_type;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).product_transfer_movement_type := l_order_set_tbl(J).product_transfer_movement_type;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).product_transfer_date          := l_order_set_tbl(J).product_transfer_date;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).tracing_flag                   := l_order_set_tbl(J).tracing_flag;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).sold_from_cust_account_id      := l_order_set_tbl(J).sold_from_cust_account_id;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).sold_from_site_id              := l_order_set_tbl(J).sold_from_site_id;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).sold_from_contact_party_id     := l_order_set_tbl(J).sold_from_contact_party_id;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).ship_from_cust_account_id      := l_order_set_tbl(J).ship_from_cust_account_id;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).ship_from_site_id              := l_order_set_tbl(J).ship_from_site_id;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).ship_from_contact_party_id     := l_order_set_tbl(J).ship_from_contact_party_id;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).bill_to_party_id               := l_order_set_tbl(J).bill_to_party_id;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).bill_to_party_site_id          := l_order_set_tbl(J).bill_to_party_site_id;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).bill_to_contact_party_id       := l_order_set_tbl(J).bill_to_contact_party_id;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).ship_to_party_id               := l_order_set_tbl(J).ship_to_party_id;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).ship_to_party_site_id          := l_order_set_tbl(J).ship_to_party_site_id;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).ship_to_contact_party_id       := l_order_set_tbl(J).ship_to_contact_party_id;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).end_cust_party_id              := l_order_set_tbl(J).end_cust_party_id;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).end_cust_site_use_id           := l_order_set_tbl(J).end_cust_site_use_id;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).end_cust_site_use_code         := l_order_set_tbl(J).end_cust_site_use_code;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).end_cust_party_site_id         := l_order_set_tbl(J).end_cust_party_site_id;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).end_cust_contact_party_id      := l_order_set_tbl(J).end_cust_contact_party_id;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).data_source_code               := l_order_set_tbl(J).data_source_code;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).header_attribute_category      := l_order_set_tbl(J).header_attribute_category;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).header_attribute1              := l_order_set_tbl(J).header_attribute1;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).header_attribute2              := l_order_set_tbl(J).header_attribute2;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).header_attribute3              := l_order_set_tbl(J).header_attribute3;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).header_attribute4              := l_order_set_tbl(J).header_attribute4;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).header_attribute5              := l_order_set_tbl(J).header_attribute5;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).header_attribute6              := l_order_set_tbl(J).header_attribute6;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).header_attribute7              := l_order_set_tbl(J).header_attribute7;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).header_attribute8              := l_order_set_tbl(J).header_attribute8;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).header_attribute9              := l_order_set_tbl(J).header_attribute9;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).header_attribute10             := l_order_set_tbl(J).header_attribute10;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).header_attribute11             := l_order_set_tbl(J).header_attribute11;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).header_attribute12             := l_order_set_tbl(J).header_attribute12;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).header_attribute13             := l_order_set_tbl(J).header_attribute13;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).header_attribute14             := l_order_set_tbl(J).header_attribute14;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).header_attribute15             := l_order_set_tbl(J).header_attribute15;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).line_attribute_category        := l_order_set_tbl(J).line_attribute_category;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).line_attribute1                := l_order_set_tbl(J).line_attribute1;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).line_attribute2                := l_order_set_tbl(J).line_attribute2;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).line_attribute3                := l_order_set_tbl(J).line_attribute3;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).line_attribute4                := l_order_set_tbl(J).line_attribute4;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).line_attribute5                := l_order_set_tbl(J).line_attribute5;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).line_attribute6                := l_order_set_tbl(J).line_attribute6;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).line_attribute7                := l_order_set_tbl(J).line_attribute7;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).line_attribute8                := l_order_set_tbl(J).line_attribute8;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).line_attribute9                := l_order_set_tbl(J).line_attribute9;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).line_attribute10               := l_order_set_tbl(J).line_attribute10;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).line_attribute11               := l_order_set_tbl(J).line_attribute11;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).line_attribute12               := l_order_set_tbl(J).line_attribute12;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).line_attribute13               := l_order_set_tbl(J).line_attribute13;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).line_attribute14               := l_order_set_tbl(J).line_attribute14;
         OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL(J).line_attribute15               := l_order_set_tbl(J).line_attribute15;
         -- R12 Populate Global Resale Structure (-)


         IF OZF_DEBUG_LOW_ON THEN
            OZF_UTILITY_PVT.debug_message('/*---END Buidling order line FOR inteface id:  '||l_order_set_tbl(J).resale_line_int_id ||'---*/');
         END IF;
      END LOOP;
      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('/*--- Buidling order header FOR order ---*/');
      END IF;

      -- build summary line
      k := l_order_set_tbl.LAST +1;
      l_line_tbl(k).LINE_INDEX               := k;
      l_line_tbl(k).LINE_ID                  := NULL;
      l_line_tbl(k).LINE_TYPE_CODE           := OZF_ORDER_PRICE_PVT.G_ORDER_HEADER_TYPE;
      l_line_tbl(k).PRICING_EFFECTIVE_DATE   := l_line_tbl(1).PRICING_EFFECTIVE_DATE;
      l_line_tbl(k).ACTIVE_DATE_FIRST        := l_line_tbl(1).ACTIVE_DATE_FIRST;
      l_line_tbl(k).ACTIVE_DATE_FIRST_TYPE   := 'ORD'; -- Change because of ONT QP order 'NO TYPE';
      l_line_tbl(k).ACTIVE_DATE_SECOND       := l_line_tbl(1).ACTIVE_DATE_SECOND;
      l_line_tbl(k).ACTIVE_DATE_SECOND_TYPE  := 'SHIP'; -- change because of ONT QP order 'NO TYPE';
      --l_line_tbl(k).LINE_QUANTITY            := NULL;
      --l_line_tbl(k).LINE_UOM_CODE            := NULL;
      l_line_tbl(k).REQUEST_TYPE_CODE        := 'ONT';
      --l_line_tbl(k).PRICED_QUANTITY          := NULL;
      --l_line_tbl(k).PRICED_UOM_CODE          := NULL;
      l_line_tbl(k).CURRENCY_CODE              := l_line_tbl(1).currency_code;
      --l_line_tbl(J).UNIT_PRICE               := l_order_set_tbl(J).
      --l_line_tbl(J).PERCENT_PRICE            := l_order_set_tbl(J).
      --l_line_tbl(J).UOM_QUANTITY             := l_order_set_tbl(J).
      --l_line_tbl(J).ADJUSTED_UNIT_PRICE      := l_order_set_tbl(J).
      --l_line_tbl(J).UPD_ADJUSTED_UNIT_PRICE  := FND_API.G_MISS_NUM,
      --l_line_tbl(J).PROCESSED_FLAG           := FND_API.G_MISS_CHAR,
      l_line_tbl(k).PRICE_FLAG               := l_price_flag;
      --l_line_tbl(J).PROCESSING_ORDER         := NULL;
      l_line_tbl(k).PRICING_STATUS_CODE      := QP_PREQ_GRP.G_STATUS_UNCHANGED;
      --l_line_tbl(J).PRICING_STATUS_TEXT      := NULL;
      --l_line_tbl(J).ROUNDING_FLAG            := NULL;
      --l_line_tbl(J).ROUNDING_FACTOR          := NULL;
      --l_line_tbl(J).QUALIFIERS_EXIST_FLAG    := NULL;
      --l_line_tbl(J).PRICING_ATTRS_EXIST_FLAG := NULL;
      l_line_tbl(k).price_list_id             := l_line_tbl(1).price_list_id;
      --l_line_tbl(J).PL_VALIDATED_FLAG        := NULL;
      --l_line_tbl(J).PRICE_REQUEST_CODE       := NULL;
      --l_line_tbl(J).USAGE_PRICING_TYPE       := NULL;
      --l_line_tbl(J).LINE_CATEGORY            := NULL;
      l_line_tbl(k).chargeback_int_id         := l_order_set_tbl(1).resale_line_int_id; -- SLKRISHN correct?
                                                                                        -- JXWU varified.
      l_line_tbl(k).resale_table_type         := 'IFACE'; -- bug 5360598

      -- populate the order_price global header structure
      -- Here I only populate the values of the qualifiers FOR ONT.
      -- The real global structure will be populate in ozf_order_price_pvt.
      -- AND it's value can be change in OZF_CHARGEBACK_ATTRMAP_PUB
      -- Might be able to add more value here.
      OZF_ORDER_PRICE_PVT.G_HEADER_REC.header_id         := k;
      OZF_ORDER_PRICE_PVT.G_HEADER_REC.sold_to_org_id    := OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(1).sold_to_org_id;
      OZF_ORDER_PRICE_PVT.G_HEADER_REC.order_type_id     := l_order_set_tbl(1).order_type_id;
      OZF_ORDER_PRICE_PVT.G_HEADER_REC.invoice_to_org_id := OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(1).invoice_to_org_id;
      OZF_ORDER_PRICE_PVT.G_HEADER_REC.ship_to_org_id    := OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(1).ship_to_org_id;
      -- [BEGIN OF BUG 4186465 FIXING]
      OZF_ORDER_PRICE_PVT.G_HEADER_REC.invoice_to_party_id      := OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(1).invoice_to_party_id;
      OZF_ORDER_PRICE_PVT.G_HEADER_REC.invoice_to_party_site_id := OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(1).invoice_to_party_site_id;
      OZF_ORDER_PRICE_PVT.G_HEADER_REC.ship_to_party_id         := OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(1).ship_to_party_id;
      OZF_ORDER_PRICE_PVT.G_HEADER_REC.ship_to_party_site_id    := OZF_ORDER_PRICE_PVT.G_LINE_REC_TBL(1).ship_to_party_site_id;
      -- [END OF BUG 4186465 FIXING]
      OZF_ORDER_PRICE_PVT.G_HEADER_REC.ordered_date := l_order_set_tbl(1).date_ordered;
      OZF_ORDER_PRICE_PVT.G_HEADER_REC.price_list_id := l_line_tbl(1).price_list_id;
      OZF_ORDER_PRICE_PVT.G_HEADER_REC.request_date := l_order_set_tbl(1).date_ordered;
      OZF_ORDER_PRICE_PVT.G_HEADER_REC.pricing_date := l_order_set_tbl(1).date_ordered;
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_UTILITY_PVT.debug_message('/*---END Buidling order header FOR order ---*/');
         OZF_UTILITY_PVT.debug_message('/*--- Calling get order price ---*/');
      END IF;

      -- Get the agreement price for order lines
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
         ,x_ldets_tbl              => x_ldets_tbl
         ,x_related_lines_tbl      => x_related_lines_tbl
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      x_line_tbl := l_line_tbl;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': End');
   END IF;
EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Get_Order_Price;
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Get_Order_Price;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      ROLLBACK TO Get_Order_Price;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
END Get_Order_Price;

---------------------------------------------------------------------
-- PROCEDURE
--    Process_Order
--
-- PURPOSE
--    Process order information. Only direct customer order will be simulated.
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
   ,p_resale_batch_id        IN    NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)IS
l_api_name          CONSTANT VARCHAR2(30) := 'Process_Order';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     VARCHAR2(1);
l_msg_data          VARCHAR2(2000);
l_msg_count         NUMBER;
--
k NUMBER;
--
l_log_id NUMBER;
l_temp_count NUMBER;
l_temp_data VARCHAR2(2000);
--
CURSOR order_num_csr IS
SELECT DISTINCT order_number,
       sold_from_cust_account_id,
       date_ordered
  FROM ozf_resale_lines_int
 WHERE status_code = 'OPEN' --(OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_OPEN, OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DUPLICATED)
   AND resale_batch_id = p_resale_batch_id
   --AND (duplicated_adjustment_id IS NULL OR
   --     duplicated_adjustment_id = -1 )
ORDER BY date_ordered;

l_cust_account_id_tbl   OZF_RESALE_COMMON_PVT.number_tbl_type;
l_order_num_tbl         OZF_RESALE_COMMON_PVT.varchar_tbl_type;
l_order_date_tbl        OZF_RESALE_COMMON_PVT.date_tbl_type;

l_line_tbl          OZF_ORDER_PRICE_PVT.LINE_REC_TBL_TYPE;
l_ldets_tbl         OZF_ORDER_PRICE_PVT.LDETS_TBL_TYPE;
l_related_lines_tbl OZF_ORDER_PRICE_PVT.RLTD_LINE_TBL_TYPE;

CURSOR batch_info_csr (p_id IN NUMBER) IS
SELECT partner_party_id, report_start_date, report_end_date
  FROM ozf_resale_batches
 WHERE resale_batch_id = p_id;

l_partner_party_id NUMBER;
l_report_start_date DATE;
l_report_end_date DATE;
l_inventory_tracking VARCHAR2(2);

--
BEGIN
   -- Standard begin of API savepoint
   SAVEPOINT  Process_Order;

   -- Standard call to check FOR call compatibility.
   IF NOT FND_API.Compatible_API_Call (
      l_api_version,
      p_api_version,
      l_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   --Initialize message lISt if p_init_msg_list IS TRUE.
   IF FND_API.To_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': Start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Move Delete logs to resale_pre_process
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

   -- Check whether there IS a need to do inventory_verification
   OPEN OZF_RESALE_COMMON_PVT.g_inventory_tracking_csr;
   FETCH OZF_RESALE_COMMON_PVT.g_inventory_tracking_csr INTO l_inventory_tracking;
   CLOSE OZF_RESALE_COMMON_PVT.g_inventory_tracking_csr;
OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': inventory flag = ' || l_inventory_tracking);
   -- populates the temp tables
   IF l_inventory_tracking = 'T' THEN
      OPEN batch_info_csr(p_resale_batch_id);
      FETCH batch_info_csr INTO l_partner_party_id
                              , l_report_start_date
                              , l_report_end_date;
      CLOSE batch_info_csr;

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


   -- fetch all orders into a cursor.
   IF l_order_num_tbl.EXISTS(1) THEN
      l_order_num_tbl.DELETE;
   END IF;
   IF l_cust_account_id_tbl.EXISTS(1) THEN
      l_cust_account_id_tbl.DELETE;
   END IF;
   IF l_order_date_tbl.EXISTS(1) THEN
      l_order_date_tbl.DELETE;
   END IF;
   OPEN order_num_csr;
   FETCH order_num_csr BULK COLLECT INTO l_order_num_tbl,l_cust_account_id_tbl,  l_order_date_tbl;
   CLOSE order_num_csr;
OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||' order count = ' || l_order_num_tbl.count);
   --
   -- Get agreement price for all lines order by order
   IF l_order_num_tbl.EXISTS(1) THEN
      -- Loop through each order record
      FOR i in 1..l_order_num_tbl.LAST
      LOOP
         IF l_cust_account_id_tbl(i) IS NOT NULL AND
            l_order_num_tbl(i) IS NOT NULL AND
            l_order_date_tbl(i) IS NOT NULL
         THEN
            --
            Get_Order_Price (
               p_resale_batch_id       => p_resale_batch_id,
               p_order_number          => l_order_num_tbl(i),
               p_sold_from_cust_acct_id  => l_cust_account_id_tbl(i),
               p_date_ordered          => l_order_date_tbl(i),
               x_line_tbl              => l_line_tbl,
               x_ldets_tbl             => l_ldets_tbl,
               x_related_lines_tbl     => l_related_lines_tbl,
               x_return_status         => l_return_status
            );
            --
            -- log errors and dispute line if there are any error in processing the order
            -- Continue to next order in case of errors
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               IF l_line_tbl.EXISTS(1) THEN
                  FOR j in 1..l_line_tbl.LAST
                  LOOP

                     IF OZF_DEBUG_LOW_ON THEN
                        OZF_UTILITY_PVT.debug_message('/*--- before get_order_price Insert resale log done ---*/');
                        OZF_UTILITY_PVT.debug_message('/*--- chargeback int id:' || l_line_tbl(j).chargeback_int_id);
                        OZF_UTILITY_PVT.debug_message('/*--- Message type: '||OZF_RESALE_COMMON_PVT.G_ID_TYPE_IFACE);
                     END IF;

                     OZF_RESALE_COMMON_PVT.Insert_Resale_Log (
                        p_id_value      => l_line_tbl(j).chargeback_int_id,
                        p_id_type       => OZF_RESALE_COMMON_PVT.G_ID_TYPE_IFACE,
                        p_error_code    => 'OZF_GET_ORDER_PRIC_ERR',
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
                  END LOOP;
                  IF OZF_DEBUG_LOW_ON THEN
                     OZF_UTILITY_PVT.debug_message('/*--- After get_order_price Insert resale log done ---*/');
                  END IF;

                  -- Dispute all the lines from this order
                  OZF_RESALE_COMMON_PVT.Bulk_Dispute_Line (
                     p_batch_id      => p_resale_batch_id,
                     p_line_status   => OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_OPEN,
                     x_return_status => l_return_status
                  );
                  --
                  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;
                  IF OZF_DEBUG_LOW_ON THEN
                     OZF_UTILITY_PVT.debug_message('/*--- Get order price failed ---*/');
                  END IF;
                  GOTO END_LOOP;
               ELSE
                  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;
               END IF;
            END IF; -- not success status

            IF OZF_DEBUG_LOW_ON THEN
               OZF_UTILITY_PVT.debug_message('/*--- Get order price succeeded ---*/');
               OZF_UTILITY_PVT.debug_message('/*--- Calling process_price_result: ---*/');
            END IF;

            -- Process pricing result
            Process_Pricing_Result(
               p_resale_batch_id => p_resale_batch_id,
               p_line_tbl  => l_line_tbl,
               p_inventory_tracking => l_inventory_tracking,
               x_return_status => l_return_status
            );

            -- insert error messages into error stack
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               FOR j in 1..l_line_tbl.LAST
               LOOP
                  OZF_RESALE_COMMON_PVT.Insert_Resale_Log (
                     p_id_value      => l_line_tbl(j).chargeback_int_id,
                     p_id_type       => OZF_RESALE_COMMON_PVT.G_ID_TYPE_IFACE,
                     p_error_code    => 'OZF_PROC_PRIC_RESLT_ERR',
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
               END LOOP;

               IF OZF_DEBUG_LOW_ON THEN
                  OZF_UTILITY_PVT.debug_message('/*--- After process_pricing_result Insert resale log done ---*/');
               END IF;

               BEGIN
                  UPDATE ozf_resale_lines_int
                  SET status_code =OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED,
                      dispute_code = 'OZF_PROC_PRIC_RESLT_ERR',
                      followup_action_code = 'C',
                      response_type = 'CA',
                      response_code = 'N'
                  WHERE status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_OPEN
                  AND order_number = l_order_num_tbl(i)
                  AND date_ordered = l_order_date_tbl(i)
                  AND sold_from_cust_account_id =l_cust_account_id_tbl(i)
                  AND dispute_code is null
                  AND resale_batch_id = p_resale_batch_id;
               EXCEPTION
                  WHEN OTHERS THEN
                    ozf_utility_pvt.error_message( 'OZF_UPD_RESALE_INT_WRG');
                    RAISE FND_API.g_exc_unexpected_error;
               END;
               --
               IF OZF_DEBUG_LOW_ON THEN
                  OZF_UTILITY_PVT.debug_message('/*--- Process Pricing Result Failed ---*/');
               END IF;
               GOTO END_LOOP;
            END IF;

            -- Bug 4387465 (+)
            UPDATE ozf_resale_lines_int_all
            SET status_code= 'PROCESSED'
            WHERE status_code = 'OPEN'
            AND order_number = l_order_num_tbl(i)
            AND sold_from_cust_account_id = l_cust_account_id_tbl(i)
            AND date_ordered = l_order_date_tbl(i)
            AND tracing_flag = 'T'
            AND resale_batch_id = p_resale_batch_id; -- bug 5222273
            -- Bug 4387465 (-)

            IF OZF_DEBUG_LOW_ON THEN
               OZF_UTILITY_PVT.debug_message('/*--- Success: Processing order for order number:'||l_order_num_tbl(i)||'---*/');
               OZF_UTILITY_PVT.debug_message('/*--- and cusomter:'||l_cust_account_id_tbl(i)||'---*/');
            END IF;
         END IF; -- END if FOR order_number, sold_from cust, date_ordered NOT NULL
         << END_LOOP >>
         NULL;
      END LOOP; -- END LOOP FOR l_order_num_tbl
   ELSE
      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('/*--- No order to process ---*/');
      END IF;
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
   --Standard call to get message count AND if count=1, get the message
   FND_MSG_PUB.Count_and_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data
   );
EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Process_Order;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_and_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Process_Order;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_and_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Process_Order;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_and_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
      );
END Process_Order;

END OZF_CHARGEBACK_PVT;

/
