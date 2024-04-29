--------------------------------------------------------
--  DDL for Package Body OZF_RESALE_COMMON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_RESALE_COMMON_PVT" AS
/* $Header: ozfvrscb.pls 120.20.12010000.8 2010/02/17 08:52:16 nepanda ship $ */
-------------------------------------------------------------------------------
-- PACKAGE:
-- OZF_RESALE_COMMON_PVT
--
-- PURPOSE:
-- Private API for common resale functionality across all IDSM batches.
--
-- HISTORY:
-- 02-Oct-2003  Jim Wu    Created
-- 28-Feb-2004  Sarvanan  Error Handling, Formating, Changes to error logging
--                        and Changes for Workflow.
-- 28-May-2007  ateotia   Bug# 5997978 fixed.
-- 22-Jun-2007  ateotia   Bug# 6134121 fixed.
-- 19-Feb-2009  nirprasa  Bug# 6790803 fixed.
-- 15-Apr-2009  ateotia   Bug# 8414563 fixed.
-- 06-May-2009  ateotia   Bug# 8489216 fixed.
--                        Added the logic for End Customer/Bill_To/Ship_To
--                        Party creation.
-- 2/17/2010    nepanda   Bug 9131648 : multi currency changes
-------------------------------------------------------------------------------

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'OZF_RESALE_COMMON_PVT';
G_FILE_NAME CONSTANT VARCHAR2(30) := 'ozfvscb.pls';

OZF_DEBUG_HIGH_ON CONSTANT BOOLEAN := FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON  CONSTANT BOOLEAN := FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.g_msg_lvl_debug_low);
OZF_UNEXP_ERROR   CONSTANT BOOLEAN := FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.g_msg_lvl_unexp_error);
OZF_ERROR         CONSTANT BOOLEAN := FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.g_msg_lvl_error);

G_CHBK_UTIL_TYPE       CONSTANT VARCHAR2(30) := 'CHARGEBACK';
G_SPP_UTIL_TYPE        CONSTANT VARCHAR2(30) :='UTILIZED';
G_TP_ACCRUAL_UTIL_TYPE CONSTANT VARCHAR2(30) :='ADJUSTMENT';
G_CHBK_ADJ_TYPE_ID     CONSTANT NUMBER := -10;
G_ACCEPT_ALLOWED       CONSTANT VARCHAR2(30) := 'ACCEPT_ALLOWED';
G_ACCEPT_CLAIMED       CONSTANT VARCHAR2(30) := 'ACCEPT_CLAIMED';
G_ITEM_ORG_ID          NUMBER := FND_PROFILE.value('AMS_ITEM_ORGANIZATION_ID');

-------------------------------------------------------------------------------

---------------------------------------------------------------------
-- PROCEDURE
--    Insert_Resale_Log
--
-- PURPOSE
-- This procedure inserts a record in ozf_resale_logs_all table
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Insert_Resale_Log (
  p_id_value      IN VARCHAR2,
  p_id_type       IN VARCHAR2,
  p_error_code    IN VARCHAR2,
  p_error_message IN VARCHAR2 := NULL,
  p_column_name   IN VARCHAR2,
  p_column_value  IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2 )
IS
  l_api_name                  CONSTANT VARCHAR2(30) := 'Insert_Resale_Log';
  l_api_version_number        CONSTANT NUMBER   := 1.0;
  l_log_id                    NUMBER;
  l_org_id                    NUMBER;
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_api_name||': Start');
   END IF;
   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message('id_value:'||p_id_value );
      OZF_UTILITY_PVT.debug_message('id_type:'||p_id_type );
      OZF_UTILITY_PVT.debug_message('error_code:'||p_error_code);
      IF p_error_message is NOT NULL THEN
         OZF_UTILITY_PVT.debug_message('error_message:'||p_error_message);
      ELSE
         OZF_UTILITY_PVT.debug_message('error_message:'||fnd_message.get_string('OZF',p_error_code));
      END IF;
      OZF_UTILITY_PVT.debug_message('column_name'||p_column_name);
      OZF_UTILITY_PVT.debug_message('column_value:'||p_column_value);
   END IF;
   --

   IF p_error_code IS NOT NULL THEN
      OPEN g_log_id_csr;
      FETCH g_log_id_csr into l_log_id;
      CLOSE g_log_id_csr;

      -- julou bug 6317120. get org_id from table
      IF p_id_type = 'BATCH' THEN
        OPEN  OZF_RESALE_COMMON_PVT.gc_batch_org_id(p_id_value);
        FETCH OZF_RESALE_COMMON_PVT.gc_batch_org_id INTO l_org_id;
        CLOSE OZF_RESALE_COMMON_PVT.gc_batch_org_id;
      ELSIF p_id_type = 'LINE' THEN
        OPEN  OZF_RESALE_COMMON_PVT.gc_line_org_id(p_id_value);
        FETCH OZF_RESALE_COMMON_PVT.gc_line_org_id INTO l_org_id;
        CLOSE OZF_RESALE_COMMON_PVT.gc_line_org_id;
      ELSIF p_id_type = 'IFACE' THEN
        OPEN  OZF_RESALE_COMMON_PVT.gc_iface_org_id(p_id_value);
        FETCH OZF_RESALE_COMMON_PVT.gc_iface_org_id INTO l_org_id;
        CLOSE OZF_RESALE_COMMON_PVT.gc_iface_org_id;
      END IF;

      BEGIN
      OZF_RESALE_LOGS_PKG.Insert_Row(
         px_resale_log_id           => l_log_id,
         p_resale_id                => p_id_value,
         p_resale_id_type           => p_id_type,
         p_error_code               => p_error_code,
         p_error_message            => nvl(p_error_message, fnd_message.get_string('OZF',p_error_code)),
         p_column_name              => p_column_name,
         p_column_value             => p_column_value,
         --px_org_id                  => OZF_RESALE_COMMON_PVT.g_org_id
         px_org_id                  => l_org_id
      );
      EXCEPTION
         WHEN OTHERS THEN
            OZF_UTILITY_PVT.error_message('OZF_INS_RESALE_LOG_WRG');
            RAISE FND_API.g_exc_unexpected_error;
      END;
   END IF;
   --
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_api_name||': End');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Insert_Resale_Log;

---------------------------------------------------------------------
-- PROCEDURE
--    Bulk_Insert_Resale_Log
--
-- PURPOSE
-- This procedure inserts a lot of records in ozf_resale_logs_all table
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Bulk_Insert_Resale_Log (
  p_id_value      IN number_tbl_type,
  p_id_type       IN VARCHAR2,
  p_error_code    IN varchar_tbl_type,
  p_column_name   IN varchar_tbl_type,
  p_column_value  IN long_varchar_tbl_type,
  p_batch_id      IN NUMBER, -- bug # 5997978 fixed
  x_return_status OUT NOCOPY VARCHAR2
)
IS
l_api_name varchar2(30) := 'Bulk_Insert_Resale_Log';
-- Start: bug # 5997978 fixed
l_batch_org_id NUMBER;
l_org_id NUMBER;
-- End: bug # 5997978 fixed
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_api_name||': Start');
   END IF;
   -- Start: bug # 5997978 fixed
   OPEN g_resale_batch_org_id_csr(p_batch_id);
   FETCH g_resale_batch_org_id_csr INTO l_batch_org_id;
   CLOSE g_resale_batch_org_id_csr;
   l_org_id := MO_GLOBAL.get_valid_org(l_batch_org_id);
   IF (l_batch_org_id IS NULL OR l_org_id IS NULL) THEN
         OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_ORG_ID_NOTFOUND');
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- End: bug # 5997978 fixed

   -- bulk insert into resale logs table for above id's
   FORALL i in 1..p_id_value.count
      INSERT INTO ozf_resale_logs_all (
         RESALE_LOG_ID,
         RESALE_ID,
         RESALE_ID_TYPE,
         ERROR_CODE,
         ERROR_MESSAGE,
         COLUMN_NAME,
         COLUMN_VALUE,
         ORG_ID
      ) VALUES (
         ozf_resale_logs_all_s.nextval,
         p_id_value(i),
         p_id_type,
         p_error_code(i),
         FND_MESSAGE.get_string('OZF',p_error_code(i)),
         p_column_name(i),
         p_column_value(i),
         -- Start: bug # 5997978 fixed
         -- NVL(SUBSTRB(USERENV('CLIENT_INFO'),1,10),-99)
         l_org_id
         -- End: bug # 5997978 fixed
      );

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_api_name||': End');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Bulk_Insert_Resale_Log;

---------------------------------------------------------------------
-- PROCEDURE
--    Log_Null_Values
--
-- PURPOSE
-- This procedure checks null values from ozf_resale_lines_int_all table
--
-- PARAMETERS
--
--
-- NOTES
-- JXWU this proceducre should be moved to preprocess
--
---------------------------------------------------------------------
PROCEDURE Log_Null_Values (
   p_batch_id      IN  VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2
)
IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'Log_Null_Values';
   l_id_tbl number_tbl_type;
   l_err_tbl varchar_tbl_type;
   l_col_tbl varchar_tbl_type;
   l_val_tbl long_varchar_tbl_type;
   l_return_status varchar2(1);
   --
   l_report_start_date date;
   l_report_end_date   date;

CURSOR batch_info_csr (p_id IN NUMBER) IS
 SELECT report_start_date, report_end_date
   FROM ozf_resale_batches
  WHERE resale_batch_id = p_id;
-- bugfix
CURSOR null_columns_csr (p_start_date IN DATE, p_end_date IN DATE) IS
   SELECT resale_line_int_id, 'OZF_RESALE_ORD_NUM_MISS', 'ORDER_NUMBER', NULL
     FROM ozf_resale_lines_int_all
    WHERE resale_batch_id = p_batch_id
      AND status_code IN (G_BATCH_ADJ_OPEN, G_BATCH_ADJ_DISPUTED)
      AND order_number IS NULL
    UNION ALL
   SELECT resale_line_int_id, 'OZF_RESALE_ORD_DATE_MISS', 'DATE_ORDERED', NULL
     FROM ozf_resale_lines_int_all
    WHERE resale_batch_id = p_batch_id
      AND status_code IN (G_BATCH_ADJ_OPEN, G_BATCH_ADJ_DISPUTED)
      AND date_ordered IS NULL
    UNION ALL
   SELECT resale_line_int_id, 'OZF_ORD_DATE_LT_START', 'DATE_ORDERED', TO_CHAR(date_ordered)
     FROM ozf_resale_lines_int_all
    WHERE resale_batch_id = p_batch_id
      AND status_code IN (G_BATCH_ADJ_OPEN, G_BATCH_ADJ_DISPUTED)
      AND date_ordered IS NOT NULL
      AND date_ordered < p_start_date
    UNION ALL
   SELECT resale_line_int_id, 'OZF_ORD_DATE_GT_END', 'DATE_ORDERED', TO_CHAR(date_ordered)
     FROM ozf_resale_lines_int_all
    WHERE resale_batch_id = p_batch_id
      AND status_code IN (G_BATCH_ADJ_OPEN, G_BATCH_ADJ_DISPUTED)
      AND date_ordered IS NOT NULL
      AND date_ordered > p_end_date
    UNION ALL
   SELECT resale_line_int_id, 'OZF_RESALE_PRODUCT_ID_MISS', 'INVENTORY_ITEM_ID', NULL
     FROM ozf_resale_lines_int_all
    WHERE resale_batch_id = p_batch_id
      AND status_code IN (G_BATCH_ADJ_OPEN, G_BATCH_ADJ_DISPUTED)
      AND inventory_item_id IS NULL
    UNION ALL
   SELECT resale_line_int_id, 'OZF_RESALE_UOM_MISS', 'UOM_CODE', NULL
     FROM ozf_resale_lines_int_all
    WHERE resale_batch_id = p_batch_id
      AND status_code IN (G_BATCH_ADJ_OPEN, G_BATCH_ADJ_DISPUTED)
      AND uom_code IS NULL
    UNION ALL
   SELECT resale_line_int_id, 'OZF_RESALE_SOLD_FROM_MISS', 'SOLD_FROM_CUST_ACCOUNT_ID', NULL
     FROM ozf_resale_lines_int_all
    WHERE resale_batch_id = p_batch_id
      AND status_code IN (G_BATCH_ADJ_OPEN, G_BATCH_ADJ_DISPUTED)
      AND sold_from_cust_account_id IS NULL
    UNION ALL
   SELECT resale_line_int_id, 'OZF_RESALE_SHIP_FROM_MISS', 'SHIP_FROM_CUST_ACCOUNT_ID', NULL
     FROM ozf_resale_lines_int_all
    WHERE resale_batch_id = p_batch_id
      AND status_code IN (G_BATCH_ADJ_OPEN, G_BATCH_ADJ_DISPUTED)
      AND ship_from_cust_account_id IS NULL
    UNION ALL
   SELECT resale_line_int_id, 'OZF_RESALE_PRICE_LIST_NULL', 'AGREEMENT_ID', NULL
     FROM ozf_resale_lines_int_all
    WHERE resale_batch_id = p_batch_id
      AND status_code IN (G_BATCH_ADJ_OPEN, G_BATCH_ADJ_DISPUTED)
      AND agreement_type = 'PL'
      AND agreement_id IS NULL
    UNION ALL
   SELECT resale_line_int_id, 'OZF_RESALE_AGREE_NUM_NULL', 'AGREEMENT_ID', NULL
     FROM ozf_resale_lines_int_all
    WHERE resale_batch_id = p_batch_id
      AND status_code IN (G_BATCH_ADJ_OPEN, G_BATCH_ADJ_DISPUTED)
      AND agreement_type = 'SPO'
      AND agreement_id IS NULL;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_api_name||': Start');
   END IF;

   -- get batch start and end date
   OPEN batch_info_csr (p_batch_id);
   FETCH batch_info_csr INTO l_report_start_date, l_report_end_date;
   CLOSE batch_info_csr;

   -- bulk select all lines with missing order numbers
   OPEN null_columns_csr (l_report_start_date, l_report_end_date);
   FETCH null_columns_csr BULK COLLECT INTO l_id_tbl, l_err_tbl, l_col_tbl, l_val_tbl;
   CLOSE null_columns_csr;
   --

   IF l_id_tbl.exists(1) THEN
      -- log disputed lines
      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('Number of errors: ' || l_id_tbl.LAST);
      END IF;
      Bulk_Insert_Resale_Log (
         p_id_value      => l_id_tbl,
         p_id_type       => G_ID_TYPE_IFACE,
         p_error_code    => l_err_tbl,
         p_column_name   => l_col_tbl,
         p_column_value  => l_val_tbl,
         p_batch_id      => p_batch_id, --bug # 5997978 fixed
         x_return_status => l_return_status
      );
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;
   --
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_api_name||': End');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
END Log_Null_Values;

---------------------------------------------------------------------
-- PROCEDURE
--    Log_Invalid_Values
--
-- PURPOSE
-- This procedure checks invalid values from ozf_resale_lines_int_all table
--
-- PARAMETERS
--
-- NOTES:
-- JXWU this proceducre should be moved to preprocess
--
---------------------------------------------------------------------
PROCEDURE Log_Invalid_Values (
   p_batch_id      IN  VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2
)
IS
   l_api_name CONSTANT VARCHAR2(30) := 'Log_Invalid_Values';
   l_id_tbl number_tbl_type;
   l_err_tbl varchar_tbl_type;
   l_col_tbl varchar_tbl_type;
   l_val_tbl long_varchar_tbl_type;
   l_return_status varchar2(1);
-- bugfix 4901702 SQL Repository - sangara
CURSOR invalid_columns_csr (p_resale_batch_id IN NUMBER) IS
SELECT orsl.resale_line_int_id
     , 'OZF_CLAIM_CUST_NOT_IN_DB'
     , 'SOLD_FROM_CUST_ACCOUNT_ID'
     , to_char(orsl.sold_from_cust_account_id)
  FROM ozf_resale_lines_int_all orsl
 WHERE orsl.status_code = 'OPEN'
   AND orsl.direct_customer_flag = 'T'
   AND orsl.resale_batch_id = p_resale_batch_id
   AND orsl.sold_from_cust_account_id IS NOT NULL
   AND NOT EXISTS ( SELECT 1
                      FROM hz_cust_accounts hca
                     WHERE hca.cust_account_id = orsl.sold_from_cust_account_id)
UNION ALL
SELECT orsl.resale_line_int_id
     , 'OZF_CLAIM_CUST_NOT_IN_DB'
     , 'SHIP_FROM_CUST_ACCOUNT_ID'
     , to_char(orsl.ship_from_cust_account_id)
  FROM ozf_resale_lines_int_all orsl
 WHERE orsl.status_code = 'OPEN'
   AND orsl.direct_customer_flag = 'T'
   AND orsl.resale_batch_id = p_resale_batch_id
   AND orsl.ship_from_cust_account_id IS NOT NULL
   AND NOT EXISTS ( SELECT 1
                      FROM hz_cust_accounts hca
                     WHERE hca.cust_account_id = orsl.ship_from_cust_account_id)
UNION ALL
SELECT orsl.resale_line_int_id
     , 'OZF_RESALE_UOM_NOT_IN_DB'
     , 'UOM_CODE'
     , orsl.uom_code
  FROM ozf_resale_lines_int_all orsl
 WHERE orsl.direct_customer_flag ='T'
   AND orsl.status_code = 'OPEN'
   AND orsl.resale_batch_id = p_resale_batch_id
   AND orsl.uom_code IS NOT NULL
   AND NOT EXISTS ( SELECT 1
                      FROM mtl_units_of_measure mum
                     WHERE mum.uom_code = orsl.uom_code )
UNION ALL
SELECT orsl.resale_line_int_id
     , 'OZF_RESALE_ORDTYPE_NOT_IN_DB'
     , 'ORDER_TYPE_ID'
     , to_char(orsl.order_type_id)
  FROM ozf_resale_lines_int_all orsl
 WHERE orsl.status_code = 'OPEN'
   AND orsl.direct_customer_flag = 'T'
   AND orsl.order_type_id IS NOT NULL
   AND orsl.resale_batch_id = p_resale_batch_id
   AND NOT EXISTS ( SELECT 1
                      FROM oe_transaction_types_all ottv
                     WHERE ottv.transaction_type_id = orsl.order_type_id)
UNION ALL
/*
SELECT orsl.resale_line_int_id
     , 'OZF_RESALE_PRICE_NOT_IN_DB'
     , 'AGREEMENT_ID'
     , to_char(orsl.agreement_id)
  FROM ozf_resale_lines_int_all orsl
 WHERE orsl.status_code = 'OPEN'
   AND orsl.direct_customer_flag = 'T'
   AND orsl.resale_batch_id = p_resale_batch_id
   AND orsl.agreement_id IS NOT NULL
   AND NOT EXISTS ( SELECT 1
                      FROM qp_list_headers_b qlhv
                     WHERE qlhv.list_header_id = orsl.agreement_id
                       AND qlhv.list_type_code = 'PRL')
UNION ALL
*/
SELECT orsl.resale_line_int_id
     , 'OZF_RESALE_PRODUCT_NOT_IN_DB'
     , 'INVENTORY_ITEM_ID'
     , to_char(orsl.inventory_item_id)
  FROM ozf_resale_lines_int_all orsl
 WHERE orsl.status_code = 'OPEN'
   AND orsl.direct_customer_flag = 'T'
   AND orsl.resale_batch_id = p_resale_batch_id
   AND orsl.inventory_item_id IS NOT NULL
   AND NOT EXISTS ( SELECT 1
                    FROM mtl_system_items_b msi
                    WHERE msi.inventory_item_id = orsl.inventory_item_id
                    AND msi.organization_id = G_ITEM_ORG_ID);

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_api_name||': Start');
   END IF;
   -- bulk select all lines with missing order numbers
   OPEN invalid_columns_csr (p_batch_id);
   FETCH invalid_columns_csr BULK COLLECT INTO l_id_tbl, l_err_tbl, l_col_tbl, l_val_tbl;
   CLOSE invalid_columns_csr;
   --

   IF l_id_tbl.exists(1) THEN
      -- log disputed lines
      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('Number of errors: ' || l_id_tbl.LAST);
      END IF;
      -- log disputed lines
      Bulk_Insert_Resale_Log (
         p_id_value      => l_id_tbl,
         p_id_type       => G_ID_TYPE_IFACE,
         p_error_code    => l_err_tbl,
         p_column_name   => l_col_tbl,
         p_column_value  => l_val_tbl,
         p_batch_id      => p_batch_id, --bug # 5997978 fixed
         x_return_status => l_return_status
      );
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      --
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_api_name||': End');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
END Log_Invalid_Values;

---------------------------------------------------------------------
-- PROCEDURE
--    Bulk_Dispute_Line
--
-- PURPOSE
-- This procedure update disputed lines
--
-- PARAMETERS
--
-- NOTES:
-- JXWU this proceducre should be moved to preprocess
--
---------------------------------------------------------------------
PROCEDURE Bulk_Dispute_Line (
   p_batch_id      IN NUMBER,
   p_line_status   IN VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2
)
IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'Bulk_Dispute_Line';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   --
--
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_api_name||': Start');
   END IF;
   --
   BEGIN
      UPDATE ozf_resale_lines_int_all orli
         SET orli.dispute_code = (SELECT orl.error_code
                                    FROM ozf_resale_logs_all orl
                                   WHERE orl.resale_id = orli.resale_line_int_id
                                     AND resale_id_type = 'IFACE'
                                     AND rownum = 1)
           , orli.status_code = G_BATCH_ADJ_DISPUTED
           , followup_action_code = 'C'
           , response_type = 'CA'
           , response_code = 'N'
       WHERE orli.resale_batch_id = p_batch_id
         AND orli.status_code = p_line_status
         AND EXISTS( SELECT 1
                     FROM ozf_resale_logs_all c
                     WHERE c.resale_id = orli.resale_line_int_id
                      AND c.resale_id_type = 'IFACE');
   EXCEPTION
      WHEN OTHERS THEN
         IF OZF_UNEXP_ERROR THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   END;
   --
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_api_name||': End');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Bulk_Dispute_Line;

---------------------------------------------------------------------
-- PROCEDURE
--    Update_Batch_Calculations
--
-- PURPOSE
-- ThIS procedure updates batch column based on data processing
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Update_Batch_Calculations (
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
l_api_name          CONSTANT VARCHAR2(30) := 'Update_Batch_Calculations';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status              VARCHAR2(1);

l_lines_disputed             NUMBER;
l_lines_w_tolerance          NUMBER;
l_lines_invalid              NUMBER;
l_lines_duplicated           NUMBER;
--
l_tolerance                  NUMBER;
l_header_tolerance_calc_cd   VARCHAR2(30);
l_header_tolerance_operand   NUMBER;
--
l_calculated_amount          NUMBER;
l_total_accepted_amount      NUMBER;
l_total_allowed_amount       NUMBER;
l_total_disputed_amount      NUMBER;
l_total_claimed_amount       NUMBER;
l_total_duplicated_amount    NUMBER;
l_status_code                VARCHAR2(30);
l_need_tolerance             BOOLEAN;
--
CURSOR tolerance_line_count_csr (p_id NUMBER)IS
SELECT count(1)
  FROM ozf_resale_lines_int
 WHERE status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED
   AND tolerance_flag = 'T'
   AND resale_batch_id = p_id;

CURSOR invalid_line_count_csr (p_id NUMBER)IS
SELECT count(1)
  FROM ozf_resale_lines_int
 WHERE status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED
   AND dispute_code = OZF_RESALE_COMMON_PVT.G_INVALD_DISPUTE_CODE
   AND resale_batch_id = p_id;

CURSOR header_tolerance_csr(p_id in NUMBER) IS
SELECT header_tolerance_operand, header_tolerance_calc_code
  FROM ozf_resale_batches
 WHERE resale_batch_id = p_id;

CURSOR csr_duplicated_dispute_amount(p_resale_batch_id IN NUMBER) IS
  SELECT NVL(COUNT(resale_line_int_id), 0)
       , NVL(SUM(total_claimed_amount), 0)
  FROM ozf_resale_lines_int_all
  WHERE resale_batch_id = p_resale_batch_id
  AND status_code = 'DUPLICATED';

BEGIN
   -- Standard begin of API savepoint
   SAVEPOINT  Update_Batch_Calculations;

   -- Standard call to check FOR call compatibility.
   IF NOT FND_API.Compatible_API_Call (
      l_api_version,
      p_api_version,
      l_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Initialize message if p_init_msg_list IS TRUE.
   IF FND_API.To_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': Start');
   END IF;
   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- get data regard thIS process
   OPEN  OZF_RESALE_COMMON_PVT.g_disputed_line_count_csr (p_resale_batch_id);
   FETCH OZF_RESALE_COMMON_PVT.g_disputed_line_count_csr INTO l_lines_disputed;
   CLOSE OZF_RESALE_COMMON_PVT.g_disputed_line_count_csr;

   OPEN  tolerance_line_count_csr (p_resale_batch_id);
   FETCH tolerance_line_count_csr INTO l_lines_w_tolerance;
   CLOSE tolerance_line_count_csr;

   -- get header level tolerance
   OPEN header_tolerance_csr(p_resale_batch_id);
   FETCH header_tolerance_csr INTO l_header_tolerance_operand,l_header_tolerance_calc_cd;
   CLOSE header_tolerance_csr;

   OPEN invalid_line_count_csr(p_resale_batch_id);
   FETCH invalid_line_count_csr INTO l_lines_invalid;
   CLOSE invalid_line_count_csr;

   OPEN  OZF_RESALE_COMMON_PVT.g_total_amount_csr (p_resale_batch_id);
   FETCH OZF_RESALE_COMMON_PVT.g_total_amount_csr INTO l_calculated_amount,
                                                       l_total_claimed_amount,
                                                       l_total_accepted_amount,
                                                       l_total_allowed_amount,
                                                       l_total_disputed_amount;
   CLOSE OZF_RESALE_COMMON_PVT.g_total_amount_csr;

   --bug # 6134121 fixed by ateotia(+)
   OPEN csr_duplicated_dispute_amount(p_resale_batch_id);
   FETCH csr_duplicated_dispute_amount INTO l_lines_duplicated
                                          , l_total_duplicated_amount;
   CLOSE csr_duplicated_dispute_amount;
   --bug # 6134121 fixed by ateotia(-)

   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message('diputed line:' || l_lines_disputed || ' tolerance line' || l_lines_w_tolerance);
   END IF;
   --bug # 6134121 fixed by ateotia(+)
   --IF l_lines_disputed = 0 THEN
   IF (l_lines_disputed = 0 AND l_lines_duplicated = 0)THEN
   --bug # 6134121 fixed by ateotia(-)
      -- Need to check header tolerance
      IF l_header_tolerance_operand IS NULL or
         l_header_tolerance_calc_cd IS NULL
      THEN
         -- No need for tolerance
         l_need_tolerance := false;
      ELSE
         l_need_tolerance := true;
         -- Check tolerance level
         -- % will be based on the transaction value of thIS batch
         IF l_header_tolerance_calc_cd = '%' THEN
            --Bug# 8418811 fixed by muthsubr(+)
            --l_tolerance := l_total_allowed_amount * (l_header_tolerance_operand /100);
            l_tolerance := ABS(l_total_allowed_amount) * (l_header_tolerance_operand /100);
            --Bug# 8418811 fixed by muthsubr(-)
         ELSE
            l_tolerance := l_header_tolerance_operand;
         END IF;
      END IF;

      IF l_need_tolerance THEN
         --Bug# 8418811 fixed by muthsubr(+)
         /*
         -- BUG 4879544 (+)
         -- IF l_total_accepted_amount <= l_total_claimed_amount + l_tolerance AND
         --   l_total_accepted_amount >= l_total_claimed_amount - l_tolerance THEN
         IF l_total_allowed_amount - l_tolerance <= l_total_accepted_amount  AND
            l_total_allowed_amount + l_tolerance >= l_total_accepted_amount  THEN
         -- BUG 4879544 (-)
         */
         IF ABS(l_total_allowed_amount) - l_tolerance <= ABS(l_total_accepted_amount) AND
            ABS(l_total_allowed_amount) + l_tolerance >= ABS(l_total_accepted_amount) THEN
         --Bug# 8418811 fixed by muthsubr(-)
            l_status_code := 'PROCESSED';
         ELSE
            l_status_code := 'DISPUTED';
            -- BUG 4879544 (+)
            Insert_Resale_Log (
               p_id_value      => p_resale_batch_id,
               p_id_type       => 'BATCH',
               p_error_code    => 'OZF_BATCH_AMT_OUT_TOLERANCE',
               p_column_name   => 'ALLOWED_AMOUNT',
               p_column_value  => l_total_allowed_amount,
               x_return_status => l_return_status
            );
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            -- BUG 4879544 (-)
         END IF;
      ELSE
         -- No need to check tolerance
         l_status_code := 'PROCESSED';
      END IF;
   ELSE
      -- batch IS in dispute
      l_status_code := 'DISPUTED';
   END IF;

   -- invalid lines are the lines with status 'DISPUTED' AND dISpute code as 'INVLD'
   -- lines_invalid = l_lines_invalid,
   -- Lastly, I will UPDATE the batch

   --bug # 6134121 fixed by ateotia(+)
   /*OPEN csr_duplicated_dispute_amount(p_resale_batch_id);
   FETCH csr_duplicated_dispute_amount INTO l_lines_duplicated
                                          , l_total_duplicated_amount;
   CLOSE csr_duplicated_dispute_amount;*/
   --bug # 6134121 fixed by ateotia(-)

   BEGIN
      UPDATE ozf_resale_batches_all
      SET status_code = l_status_code,
          allowed_amount =l_total_allowed_amount,
          accepted_amount = l_total_accepted_amount,
          disputed_amount = ABS(l_total_disputed_amount) + ABS(l_total_duplicated_amount),
          lines_w_tolerance = l_lines_w_tolerance,
          lines_disputed = l_lines_disputed + l_lines_duplicated,
          lines_invalid = l_lines_invalid
      WHERE resale_batch_id = p_resale_batch_id;
   EXCEPTION
      WHEN OTHERS THEN
         OZF_UTILITY_PVT.error_message('OZF_UPD_RESALE_BATCH_WRG');
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

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
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Batch_Calculations;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_and_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Batch_Calculations;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_and_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Batch_Calculations;
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
END Update_Batch_Calculations;

---------------------------------------------------------------------
-- PROCEDURE
--    Update_Line_Calculations
--
-- PURPOSE
--    This procedure update ozf_lines_int_all table based on the data processing
-- PARAMETERS
--    x_return_status  out VARCHAR2
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE Update_Line_Calculations(
    p_resale_line_int_rec IN OZF_RESALE_COMMON_PVT.g_interface_rec_csr%ROWTYPE,
    p_unit_price          IN NUMBER,
    p_line_quantity       IN NUMBER,
    p_allowed_amount      IN NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2
)
IS
l_api_name       CONSTANT VARCHAR2(30) := 'Update_Line_Calculations';
l_api_version    CONSTANT NUMBER       := 1.0;
l_full_name      CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
l_return_status           VARCHAR2(1);
l_allowed_or_claimed      VARCHAR2(30);
l_accepted_amount         NUMBER;
l_tolerance               NUMBER;
l_status_code             VARCHAR2(30);
l_tolerance_flag          VARCHAR2(1);
l_line_tolerance_amount   NUMBER;
l_line_tolerance_calc_cd  VARCHAR2(30);
l_line_tolerance_operand  NUMBER;
l_followup_action_code    VARCHAR2(30) := NULL;
l_response_type           VARCHAR2(30) := NULL;
l_dispute_code            VARCHAR2(30) := NULL;
l_net_adjusted_amount     NUMBER;
l_total_accepted_amount   NUMBER;
l_total_allowed_amount    NUMBER;

CURSOR line_tolerance_csr(p_id in NUMBER) IS
SELECT line_tolerance_operand,  line_tolerance_calc_code
  FROM ozf_resale_batches
 WHERE resale_batch_id = p_id;

CURSOR allowed_or_claimed_csr IS
SELECT ship_debit_calc_type
from ozf_sys_parameters;
--Bug# 8418811 fixed by muthsubr(+)
/*
-- bug 5969118 Ship and Debit return order generates positive claim amount
CURSOR c_batch_type(p_batch_id NUMBER) IS
SELECT batch_type
FROM   ozf_resale_batches_all
WHERE  resale_batch_id = p_batch_id;
l_batch_type VARCHAR2(30);
-- bug 5969118 end
*/
--Bug# 8418811 fixed by muthsubr(-)

BEGIN
   -- Standard begin of API savepoint
   SAVEPOINT Update_Line_Calculations;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;
   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message('unit_price:'||p_unit_price);
      OZF_UTILITY_PVT.debug_message('line_quantity:'||p_line_quantity);
      OZF_UTILITY_PVT.debug_message('Allowed_amount:'|| p_allowed_amount);
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_resale_line_int_rec.claimed_amount IS NOT NULL THEN
      --bug 6790803 for negative quantity
      --IF p_allowed_amount = p_resale_line_int_rec.claimed_amount THEN
      --Bug# 8418811 fixed by muthsubr(+)
      --IF abs(p_allowed_amount) = p_resale_line_int_rec.claimed_amount THEN
      IF ABS(p_allowed_amount) = ABS(p_resale_line_int_rec.claimed_amount) THEN
      --Bug# 8418811 fixed by muthsubr(-)
         -- No dispute in line as allowed and claimed are same
         l_status_code := OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED;
         l_line_tolerance_amount := 0;
         l_tolerance_flag := 'F';
         l_accepted_amount := p_allowed_amount;
      ELSE
         -- Check tolerance level
         OPEN line_tolerance_csr (p_resale_line_int_rec.resale_batch_id);
         FETCH line_tolerance_csr INTO l_line_tolerance_operand,l_line_tolerance_calc_cd;
         CLOSE line_tolerance_csr;

         -- tolerance % will be based on unit_price, or the total of the transaction
         IF l_line_tolerance_calc_cd IS NULL THEN
            l_tolerance := 0;
         ELSE
            IF l_line_tolerance_calc_cd = '%' THEN
               l_tolerance := p_unit_price * l_line_tolerance_operand / 100;
            ELSE
               l_tolerance := l_line_tolerance_operand;
            END IF;
         END IF;

         -- Set lines that do not fall INTO tolerence as DISPUTED
         --Bug# 8418811 fixed by muthsubr(+)
         /*IF p_allowed_amount - l_tolerance <= p_resale_line_int_rec.claimed_amount AND
            p_allowed_amount + l_tolerance >= p_resale_line_int_rec.claimed_amount THEN*/
         IF ABS(p_allowed_amount) - l_tolerance <= ABS(p_resale_line_int_rec.claimed_amount) AND
            ABS(p_allowed_amount) + l_tolerance >= ABS(p_resale_line_int_rec.claimed_amount) THEN
         --Bug# 8418811 fixed by muthsubr(-)
            l_status_code := OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED;
            l_line_tolerance_amount := l_tolerance;
            l_tolerance_flag := 'T';

            -- use system parameter flag to determine with amount assign to accepted amount
            OPEN allowed_or_claimed_csr;
            FETCH allowed_or_claimed_csr into l_allowed_or_claimed;
            CLOSE allowed_or_claimed_csr;

            -- default to allowed
            IF l_allowed_or_claimed IS NULL THEN
               l_allowed_or_claimed := G_ACCEPT_ALLOWED;
            END IF;

            IF l_allowed_or_claimed = G_ACCEPT_ALLOWED THEN
               l_accepted_amount := p_allowed_amount;
            ELSE
               l_accepted_amount := p_resale_line_int_rec.claimed_amount;
            END IF;
         ELSE
            l_status_code := OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED;
            l_line_tolerance_amount := l_tolerance;
            l_tolerance_flag := 'F';
            l_dispute_code := 'OZF_AMT_NOT_MATCH';
            l_followup_action_code := 'C';
            l_response_type := 'CA';

            -- BUG 4879544 (+)
            Insert_Resale_Log (
               p_id_value      => p_resale_line_int_rec.resale_line_int_id,
               p_id_type       => 'IFACE',
               p_error_code    => 'OZF_IFACE_AMT_OUT_TOLERANCE',
               p_column_name   => 'LINE_TOLERANCE_AMOUNT',
               p_column_value  => l_line_tolerance_amount,
               x_return_status => l_return_status
            );
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            -- BUG 4879544 (-)
         END if;
      END IF;
      --Bug# 8418811 fixed by muthsubr(+)
      --l_net_adjusted_amount := p_resale_line_int_rec.claimed_amount - l_accepted_amount;
      l_net_adjusted_amount := ABS(p_resale_line_int_rec.claimed_amount) - ABS(l_accepted_amount);
      --Bug# 8418811 fixed by muthsubr(-)
   ELSE
      --Here user did not specific the claimed amount, I will calculate it based on the request
      l_status_code := OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED;
      l_accepted_amount := p_allowed_amount;
      l_line_tolerance_amount := null;
      l_tolerance_flag := 'F';
      l_net_adjusted_amount := NULL;
   END IF;

   -- Update Line
   BEGIN
      --Bug# 8418811 fixed by muthsubr(+)
      /*
      -- bug 5969118 Ship and Debit return order generates positive claim amount
      OPEN  c_batch_type(p_resale_line_int_rec.resale_batch_id);
      FETCH c_batch_type INTO l_batch_type;
      CLOSE c_batch_type;

      IF l_batch_type = 'SHIP_DEBIT' AND p_resale_line_int_rec.resale_transfer_type = 'BN' THEN
      */
      IF p_resale_line_int_rec.resale_transfer_type = 'BN' THEN
      --Bug# 8418811 fixed by muthsubr(-)
        l_total_accepted_amount := ABS(l_accepted_amount * p_line_quantity) * -1;
        l_total_allowed_amount := ABS(p_allowed_amount * p_line_quantity) * -1;
      ELSE
        l_total_accepted_amount := l_accepted_amount * ABS(p_line_quantity);
        l_total_allowed_amount := p_allowed_amount * ABS(p_line_quantity);
      END IF;
      -- bug 5969118 end

      UPDATE ozf_resale_lines_int_all
      SET accepted_amount = l_accepted_amount,
--         total_accepted_amount = l_accepted_amount * ABS(p_line_quantity),
         -- bug 5969118 Ship and Debit return order generates positive claim amount
         total_accepted_amount = l_total_accepted_amount,
         -- bug 5969118 end
         allowed_amount = p_allowed_amount,
--         total_allowed_amount = p_allowed_amount * ABS(p_line_quantity),
         -- bug 5969118 Ship and Debit return order generates positive claim amount
         total_allowed_amount = l_total_allowed_amount,
         -- bug 5969118 end
         net_adjusted_amount = l_net_adjusted_amount,
         calculated_price  = p_unit_price,
         acctd_calculated_price = p_resale_line_int_rec.acctd_calculated_price,
         calculated_amount  = p_unit_price *  p_line_quantity,
         acctd_selling_price = p_resale_line_int_rec.acctd_selling_price,
         exchange_rate = p_resale_line_int_rec.exchange_rate,
         exchange_rate_date = p_resale_line_int_rec.exchange_rate_date,
         exchange_rate_type = p_resale_line_int_rec.exchange_rate_type,
         status_code = l_status_code,
         dispute_code = l_dispute_code,
         line_tolerance_amount = l_line_tolerance_amount,
         tolerance_flag = l_tolerance_flag,
         followup_action_code = l_followup_action_code,
         response_type = l_response_type,
         response_code = decode(l_status_code, OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED, 'N',
                                               OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED, 'Y')
      WHERE resale_line_int_id = p_resale_line_int_rec.resale_line_int_id;
   EXCEPTION
      WHEN OTHERS THEN
         IF OZF_UNEXP_ERROR THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': End');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Line_Calculations;
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Line_Calculations;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      ROLLBACK TO Update_Line_Calculations;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
END Update_Line_Calculations;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Duplicate_Line
--
-- PURPOSE
--    This procedure tries to see whether the current line AND adjustments have been sent before.
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Check_Duplicate_Line(
    p_api_version_number         IN  NUMBER
   ,p_init_msg_LIST              IN  VARCHAR2   := FND_API.G_FALSE
   ,p_commit                     IN  VARCHAR2   := FND_API.G_FALSE
   ,p_validation_level           IN  NUMBER     := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_line_int_id         IN  NUMBER
   ,p_direct_customer_flag       IN  VARCHAR2
   ,p_claimed_amount             IN  NUMBER
   ,p_batch_type                 IN  VARCHAR2
   ,x_dup_line_id                OUT NOCOPY     NUMBER
   ,x_dup_adjustment_id          OUT NOCOPY     NUMBER
   ,x_reprocessing               OUT NOCOPY     BOOLEAN
   ,x_return_status              OUT NOCOPY     VARCHAR2
   ,x_msg_count                  OUT NOCOPY     NUMBER
   ,x_msg_data                   OUT NOCOPY     VARCHAR2
)IS
l_api_name          CONSTANT VARCHAR2(30) := 'Check_Duplicate_Line';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_adjustment_id  NUMBER;
l_claimed_amount NUMBER;
l_line_id        NUMBER := NULL;
l_tracing_flag   VARCHAR2(1); --Bug# 8414563 fixed by ateotia

CURSOR dup_line_direct_resale_csr ( p_resale_line_int_id IN NUMBER )
IS
SELECT orl.resale_line_id
  -- Bug 4670154 (+)
  FROM ozf_resale_lines_all orl,
       ozf_resale_lines_int_all orli
  /*
  FROM ozf_resale_lines orl,
       ozf_resale_lines_int orli
  */
  -- Bug 4670154 (-)
 WHERE orl.order_number = orli.order_number
   AND orl.date_ordered =  orli.date_ordered
   -- 6704619 (+)
   AND (orl.date_shipped = orli.date_shipped
       OR (orl.date_shipped IS NULL AND orli.date_shipped IS NULL))
   -- 6704619 (-)
   --AND orl.invoice_number = orli.invoice_number
   --AND orl.date_invoiced = orli.date_invoiced
   AND orl.inventory_item_id = orli.inventory_item_id
   AND orl.quantity = orli.quantity
   AND orl.uom_code = orli.uom_code
   AND orl.sold_from_cust_account_id = orli.sold_from_cust_account_id
   --AND orl.ship_from_cust_account_id = orli.sold_from_cust_account_id
   AND orl.ship_from_cust_account_id = orli.ship_from_cust_account_id
   AND orl.direct_customer_flag = 'T'
   AND orl.bill_to_cust_account_id = orli.bill_to_cust_account_id
   AND orli.resale_line_int_id = p_resale_line_int_id
   AND rownum = 1;

CURSOR dup_line_indirect_resale_csr ( p_resale_line_int_id IN NUMBER )
IS
SELECT orl.resale_line_id
  -- Bug 4670154 (+)
  FROM ozf_resale_lines_all orl,
       ozf_resale_lines_int_all orli
  /*
  FROM ozf_resale_lines orl,
       ozf_resale_lines_int orli
  */
  -- Bug 4670154 (-)
 WHERE orl.order_number = orli.order_number
   AND orl.date_ordered =  orli.date_ordered
   -- 6704619 (+)
   AND (orl.date_shipped = orli.date_shipped
       OR (orl.date_shipped IS NULL AND orli.date_shipped IS NULL))
   -- 6704619 (-)
   --AND orl.invoice_number = orli.invoice_number
   --AND orl.date_invoiced = orli.date_invoiced
   AND orl.inventory_item_id = orli.inventory_item_id
   AND orl.quantity = orli.quantity
   AND orl.uom_code = orli.uom_code
   AND orl.sold_from_cust_account_id = orli.sold_from_cust_account_id
   --AND orl.ship_from_cust_account_id = orli.sold_from_cust_account_id
   AND orl.ship_from_cust_account_id = orli.ship_from_cust_account_id
   AND orl.direct_customer_flag = 'F'
   AND orl.bill_to_party_name = orli.bill_to_party_name
   AND orli.resale_line_int_id = p_resale_line_int_id
   AND rownum = 1;

CURSOR dup_adj_csr(
         p_line_id IN NUMBER,
         p_batch_type IN VARCHAR2)
IS
SELECT orsa.resale_adjustment_id
     , orsa.claimed_amount
  -- Bug 4670154 (+)
  FROM ozf_resale_adjustments_all orsa
     , ozf_resale_batches_all orsb
  /*
  FROM ozf_resale_adjustments orsa
     , ozf_resale_batches orsb
  */
  -- Bug 4670154 (-)
 WHERE orsa.resale_line_id = p_line_id
   AND orsa.resale_batch_id = orsb.resale_batch_id
   AND orsb.batch_type = p_batch_type
  -- Bug 4670154 (+)
   AND orsa.list_header_id IS NULL
   AND orsa.list_line_id IS NULL;
  -- Bug 4670154 (-)

CURSOR dup_line_direct_iface_csr ( p_resale_line_int_id IN NUMBER )
IS
SELECT orlo.resale_line_int_id
  -- Bug 4670154 (+)
  FROM ozf_resale_lines_int_all orlo,
       ozf_resale_lines_int_all orli
  /*
  FROM ozf_resale_lines_int orlo,
       ozf_resale_lines_int orli
  */
  -- Bug 4670154 (-)
 WHERE orlo.order_number = orli.order_number
   AND orlo.date_ordered =  orli.date_ordered
   -- 6704619 (+)
   AND (orlo.date_shipped = orli.date_shipped
       OR (orlo.date_shipped IS NULL AND orli.date_shipped IS NULL))
   -- 6704619 (-)
   AND orlo.inventory_item_id = orli.inventory_item_id
   AND orlo.quantity = orli.quantity
   AND orlo.uom_code = orli.uom_code
   AND orlo.sold_from_cust_account_id = orli.sold_from_cust_account_id
   --AND orlo.ship_from_cust_account_id = orli.sold_from_cust_account_id
   AND orlo.ship_from_cust_account_id = orli.ship_from_cust_account_id
   AND orlo.claimed_amount = orli.claimed_amount
   AND orlo.bill_to_cust_account_id = orli.bill_to_cust_account_id
   AND orlo.status_code in (OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_OPEN, OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED)
   AND orlo.resale_line_int_id <> p_resale_line_int_id
   AND orlo.resale_batch_id <> orli.resale_batch_id
   AND orli.resale_line_int_id = p_resale_line_int_id
   AND orlo.duplicated_line_id IS NULL
   AND orlo.duplicated_adjustment_id IS NULL
   AND orlo.direct_customer_flag = 'T'
   AND orlo.creation_date <= orli.creation_date
   AND rownum = 1;

CURSOR dup_line_indirect_iface_csr ( p_resale_line_int_id IN NUMBER )
IS
SELECT orlo.resale_line_int_id
  -- Bug 4670154 (+)
  FROM ozf_resale_lines_int_all orlo,
       ozf_resale_lines_int_all orli
  /*
  FROM ozf_resale_lines_int orlo,
       ozf_resale_lines_int orli
  */
  -- Bug 4670154 (-)
 WHERE orlo.order_number = orli.order_number
   AND orlo.date_ordered =  orli.date_ordered
   -- 6704619 (+)
   AND (orlo.date_shipped = orli.date_shipped
       OR (orlo.date_shipped IS NULL AND orli.date_shipped IS NULL))
   -- 6704619 (-)
   --AND orl.invoice_number = orli.invoice_number
   --AND orl.date_invoiced = orli.date_invoiced
   AND orlo.inventory_item_id = orli.inventory_item_id
   AND orlo.quantity = orli.quantity
   AND orlo.uom_code = orli.uom_code
   AND orlo.sold_from_cust_account_id = orli.sold_from_cust_account_id
   --AND orlo.ship_from_cust_account_id = orli.sold_from_cust_account_id
   AND orlo.ship_from_cust_account_id = orli.ship_from_cust_account_id
   AND orlo.claimed_amount = orli.claimed_amount
   AND orlo.bill_to_party_name = orli.bill_to_party_name
   AND orlo.status_code in (OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_OPEN, OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED)
   AND orlo.resale_line_int_id <> p_resale_line_int_id
   AND orlo.resale_batch_id <> orli.resale_batch_id
   AND orli.resale_line_int_id = p_resale_line_int_id
   AND orlo.duplicated_line_id IS NULL
   AND orlo.duplicated_adjustment_id IS NULL
   AND orlo.direct_customer_flag = 'F'
   AND orlo.creation_date <= orli.creation_date
   AND rownum = 1;

CURSOR dup_line_nondirect_resale_csr ( p_resale_line_int_id IN NUMBER )
IS
SELECT orl.resale_line_id
  FROM ozf_resale_lines_all orl,
       ozf_resale_lines_int_all orli
  -- Bug 4670154 (+)
  /*
  FROM ozf_resale_lines orl,
       ozf_resale_lines_int orli
  */
  -- Bug 4670154 (-)
 WHERE orl.order_number = orli.order_number
   AND orl.date_ordered =  orli.date_ordered
   -- 6704619 (+)
   AND (orl.date_shipped = orli.date_shipped
       OR (orl.date_shipped IS NULL AND orli.date_shipped IS NULL))
   -- 6704619 (-)
   --AND orl.invoice_number = orli.invoice_number
   --AND orl.date_invoiced = orli.date_invoiced
   AND orl.inventory_item_id = orli.inventory_item_id
   AND orl.quantity = orli.quantity
   AND orl.uom_code = orli.uom_code
   AND orl.sold_from_cust_account_id = orli.sold_from_cust_account_id
   --AND orl.ship_from_cust_account_id = orli.sold_from_cust_account_id
   AND orl.ship_from_cust_account_id = orli.ship_from_cust_account_id
   AND orl.bill_to_cust_account_id is null
   AND orl.bill_to_party_name is null
   AND orl.direct_customer_flag is null
   AND orli.resale_line_int_id = p_resale_line_int_id
   AND rownum = 1;

CURSOR dup_line_nondirect_iface_csr ( p_resale_line_int_id IN NUMBER )
IS
SELECT orlo.resale_line_int_id
  -- Bug 4670154 (+)
  FROM ozf_resale_lines_int_all orlo,
       ozf_resale_lines_int_all orli
  /*
  FROM ozf_resale_lines_int orlo,
       ozf_resale_lines_int orli
  */
  -- Bug 4670154 (-)
 WHERE orlo.order_number = orli.order_number
   AND orlo.date_ordered =  orli.date_ordered
   -- 6704619 (+)
   AND (orlo.date_shipped = orli.date_shipped
       OR (orlo.date_shipped IS NULL AND orli.date_shipped IS NULL))
   -- 6704619 (-)
   AND orlo.inventory_item_id = orli.inventory_item_id
   AND orlo.quantity = orli.quantity
   AND orlo.uom_code = orli.uom_code
   AND orlo.sold_from_cust_account_id = orli.sold_from_cust_account_id
   --AND orlo.ship_from_cust_account_id = orli.sold_from_cust_account_id
   AND orlo.ship_from_cust_account_id = orli.ship_from_cust_account_id
   AND orlo.claimed_amount = orli.claimed_amount
   AND orlo.bill_to_cust_account_id is null
   AND orlo.bill_to_party_name is null
   AND orlo.direct_customer_flag is null
   AND orlo.status_code in (OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_OPEN, OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED)
   AND orlo.resale_line_int_id <> p_resale_line_int_id
   AND orlo.resale_batch_id <> orli.resale_batch_id
   AND orli.resale_line_int_id = p_resale_line_int_id
   AND orlo.duplicated_line_id IS NULL
   AND orlo.duplicated_adjustment_id IS NULL
   AND orlo.creation_date <= orli.creation_date
   AND rownum = 1;
---

CURSOR dup_line_dir_iface_self_csr ( p_resale_line_int_id IN NUMBER )
IS
SELECT orlo.resale_line_int_id
  FROM ozf_resale_lines_int_all orlo,
       ozf_resale_lines_int_all orli
 WHERE orlo.order_number = orli.order_number
   AND orlo.date_ordered =  orli.date_ordered
   -- 6704619 (+)
   AND (orlo.date_shipped = orli.date_shipped
       OR (orlo.date_shipped IS NULL AND orli.date_shipped IS NULL))
   -- 6704619 (-)
   AND orlo.inventory_item_id = orli.inventory_item_id
   AND orlo.quantity = orli.quantity
   AND orlo.uom_code = orli.uom_code
   AND orlo.sold_from_cust_account_id = orli.sold_from_cust_account_id
   AND orlo.ship_from_cust_account_id = orli.ship_from_cust_account_id
   --AND orlo.claimed_amount = orli.claimed_amount
   AND orlo.bill_to_cust_account_id = orli.bill_to_cust_account_id
   AND orlo.status_code IN ('OPEN', 'PROCESSED')
   AND orlo.resale_line_int_id <> p_resale_line_int_id
   AND orlo.resale_batch_id = orli.resale_batch_id
   AND orli.resale_line_int_id = p_resale_line_int_id
   AND orlo.duplicated_line_id IS NULL
   AND orlo.duplicated_adjustment_id IS NULL
   AND orlo.direct_customer_flag = 'T'
   AND orlo.creation_date <= orli.creation_date
   AND rownum = 1;

CURSOR dup_line_indir_iface_self_csr ( p_resale_line_int_id IN NUMBER )
IS
SELECT orlo.resale_line_int_id
  FROM ozf_resale_lines_int_all orlo,
       ozf_resale_lines_int_all orli
 WHERE orlo.order_number = orli.order_number
   AND orlo.date_ordered =  orli.date_ordered
   -- 6704619 (+)
   AND (orlo.date_shipped = orli.date_shipped
       OR (orlo.date_shipped IS NULL AND orli.date_shipped IS NULL))
   -- 6704619 (-)
   AND orlo.inventory_item_id = orli.inventory_item_id
   AND orlo.quantity = orli.quantity
   AND orlo.uom_code = orli.uom_code
   AND orlo.sold_from_cust_account_id = orli.sold_from_cust_account_id
   AND orlo.ship_from_cust_account_id = orli.ship_from_cust_account_id
   --AND orlo.claimed_amount = orli.claimed_amount
   AND orlo.bill_to_party_name = orli.bill_to_party_name

   AND orlo.status_code IN ('OPEN', 'PROCESSED')
   AND orlo.resale_line_int_id <> p_resale_line_int_id
   AND orlo.resale_batch_id = orli.resale_batch_id
   AND orli.resale_line_int_id = p_resale_line_int_id
   AND orlo.duplicated_line_id IS NULL
   AND orlo.duplicated_adjustment_id IS NULL
   AND orlo.direct_customer_flag = 'F'
   AND orlo.creation_date <= orli.creation_date
   AND rownum = 1;

CURSOR dup_line_nondir_iface_self_csr ( p_resale_line_int_id IN NUMBER )
IS
SELECT orlo.resale_line_int_id
  FROM ozf_resale_lines_int_all orlo,
       ozf_resale_lines_int_all orli
 WHERE orlo.order_number = orli.order_number
   AND orlo.date_ordered =  orli.date_ordered
   -- 6704619 (+)
   AND (orlo.date_shipped = orli.date_shipped
       OR (orlo.date_shipped IS NULL AND orli.date_shipped IS NULL))
   -- 6704619 (-)
   AND orlo.inventory_item_id = orli.inventory_item_id
   AND orlo.quantity = orli.quantity
   AND orlo.uom_code = orli.uom_code
   AND orlo.sold_from_cust_account_id = orli.sold_from_cust_account_id
   AND orlo.ship_from_cust_account_id = orli.ship_from_cust_account_id
   --AND orlo.claimed_amount = orli.claimed_amount
   AND orlo.bill_to_cust_account_id is null
   AND orlo.bill_to_party_name is null
   AND orlo.direct_customer_flag is null
   AND orlo.status_code IN ('OPEN', 'PROCESSED')
   AND orlo.resale_line_int_id <> p_resale_line_int_id
   AND orlo.resale_batch_id = orli.resale_batch_id
   AND orli.resale_line_int_id = p_resale_line_int_id
   AND orlo.duplicated_line_id IS NULL
   AND orlo.duplicated_adjustment_id IS NULL
   AND orlo.creation_date <= orli.creation_date
   AND rownum = 1;

BEGIN

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
      l_api_version,
      p_api_version_number,
      l_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Initialize message LIST IF p_init_msg_LIST IS TRUE.
   IF FND_API.To_Boolean (p_init_msg_LIST) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message('resale_line_int_id'||p_resale_line_int_id);
      OZF_UTILITY_PVT.debug_message('direct_customer_flag'||p_direct_customer_flag);
      OZF_UTILITY_PVT.debug_message('claimed_amount'||p_claimed_amount);
   END IF;

   -- Check with resale data first
   IF p_direct_customer_flag IS NULL THEN
      OPEN dup_line_nondirect_resale_csr(p_resale_line_int_id);
      FETCH dup_line_nondirect_resale_csr INTO l_line_id;
      CLOSE dup_line_nondirect_resale_csr;
   ELSE
      IF p_direct_customer_flag = 'T' THEN
         OPEN dup_line_direct_resale_csr(p_resale_line_int_id);
         FETCH dup_line_direct_resale_csr INTO l_line_id;
         CLOSE dup_line_direct_resale_csr;
      ELSE
         OPEN dup_line_indirect_resale_csr(p_resale_line_int_id);
         FETCH dup_line_indirect_resale_csr INTO l_line_id;
         CLOSE dup_line_indirect_resale_csr;
      END IF;
   END IF;

   x_reprocessing := false;
   IF l_line_id IS NOT NULL THEN
      --Bug# 8414563 fixed by ateotia(+)
      IF (p_batch_type = G_TRACING) THEN
         x_reprocessing := true;
         -- -2 to indicate that it's a tracing batch and current line is duplicate of a resale line
         l_adjustment_id := -2;
      ELSE
         --Check for tracing line
         OPEN g_tracing_flag_csr (p_resale_line_int_id);
         FETCH g_tracing_flag_csr INTO l_tracing_flag;
         CLOSE g_tracing_flag_csr;
         IF (NVL(l_tracing_flag, 'F') = 'T') THEN
            x_reprocessing := true;
            -- -3 to indicate that current line is a tracing line and is duplicate of a resale line
            l_adjustment_id := -3;
         END IF;
      END IF;
      IF (NOT x_reprocessing) THEN
         OPEN dup_adj_csr(l_line_id, p_batch_type);
         FETCH dup_adj_csr INTO l_adjustment_id, l_claimed_amount;
         CLOSE dup_adj_csr;

         x_dup_adjustment_id := l_adjustment_id;
         x_reprocessing := l_adjustment_id IS NOT NULL AND
                           p_claimed_amount = l_claimed_amount;
      END IF;
      --Bug# 8414563 fixed by ateotia(-)
      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('l_adjustment_id = '||l_adjustment_id);
         OZF_UTILITY_PVT.debug_message('x_dup_adjustment_id = '||x_dup_adjustment_id);
         IF x_reprocessing THEN
            OZF_UTILITY_PVT.debug_message('x_reprocessing >> Yes');
         ELSE
            OZF_UTILITY_PVT.debug_message('x_reprocessing >> No');
         END IF;
      END IF;

   ELSE
      -- check to see whether it can be a duplicate of an interface line.
      -- In this case, reprocess is always false.
      IF p_direct_customer_flag IS NULL THEN
         OPEN dup_line_nondirect_iface_csr(p_resale_line_int_id);
         FETCH dup_line_nondirect_iface_csr INTO l_line_id;
         CLOSE dup_line_nondirect_iface_csr;
      ELSE
         IF p_direct_customer_flag = 'T' THEN
            OPEN dup_line_direct_iface_csr(p_resale_line_int_id);
            FETCH dup_line_direct_iface_csr INTO l_line_id;
            CLOSE dup_line_direct_iface_csr;
         ELSE
            OPEN dup_line_indirect_iface_csr(p_resale_line_int_id);
            FETCH dup_line_indirect_iface_csr INTO l_line_id;
            CLOSE dup_line_indirect_iface_csr;
         END IF;
      END IF;
      -- -1 to indicate it's a duplication to an interface line.
      IF l_line_id is NOT NULL THEN
         l_adjustment_id := -1;
         --x_reprocessing := true;
         x_reprocessing := false;
      END IF;
   END IF;

   IF l_line_id IS NULL THEN
      IF p_direct_customer_flag IS NULL THEN
         OPEN dup_line_nondir_iface_self_csr(p_resale_line_int_id);
         FETCH dup_line_nondir_iface_self_csr INTO l_line_id;
         CLOSE dup_line_nondir_iface_self_csr;
      ELSE
         IF p_direct_customer_flag = 'T' THEN
            OPEN dup_line_dir_iface_self_csr(p_resale_line_int_id);
            FETCH dup_line_dir_iface_self_csr INTO l_line_id;
            CLOSE dup_line_dir_iface_self_csr;
         ELSE
            OPEN dup_line_indir_iface_self_csr(p_resale_line_int_id);
            FETCH dup_line_indir_iface_self_csr INTO l_line_id;
            CLOSE dup_line_indir_iface_self_csr;
         END IF;
      END IF;
      -- -1 to indicate it's a duplication to an interface line within the same batch
      IF l_line_id IS NOT NULL THEN
         l_adjustment_id := -1;
         x_reprocessing := true;
      END IF;
   END IF;


   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message('dup adj id' || l_adjustment_id);
      OZF_UTILITY_PVT.debug_message('dup line id' || l_line_id);
   END IF;

   x_dup_adjustment_id := l_adjustment_id;
   x_dup_line_id := l_line_id;


   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': End');
   END IF;

   --Standard call to get message count AND IF count=1, get the message
   FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN
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
END Check_Duplicate_Line;

---------------------------------------------------------------------
-- PROCEDURE
--    Update_Duplicates
--
-- PURPOSE
--    This procedure updates the duplicates
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Update_Duplicates (
    p_api_version            IN  NUMBER
   ,p_init_msg_LIST          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN  NUMBER
   ,p_resale_batch_type      IN  VARCHAR2
   ,p_batch_status           IN  VARCHAR2
   ,x_batch_status           OUT NOCOPY   VARCHAR2
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Update_Duplicates';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     VARCHAR2(30);
l_msg_data          VARCHAR2(2000);
l_msg_count         NUMBER;

i                   NUMBER;

l_dup_line_id       NUMBER;
l_dup_adjustment_id NUMBER;
l_reprocessing      BOOLEAN;
l_duplicate_count   NUMBER  := 0;
l_batch_count       NUMBER  := 0;
--
l_open_lines_tbl        number_tbl_type;
l_direct_customer_tbl   varchar_tbl_type;
l_claimed_amount_tbl    number_tbl_type;
--
CURSOR open_lines_csr(p_id IN NUMBER) IS
SELECT resale_line_int_id, direct_customer_flag, claimed_amount
  FROM ozf_resale_lines_int
-- WHERE status_code =OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_OPEN
 WHERE resale_batch_id = p_id;

CURSOR batch_count_csr(pc_batch_id NUMBER) IS
SELECT NVL(batch_count,0)
  FROM ozf_resale_batches
 WHERE resale_batch_id = pc_batch_id;

CURSOR duplicate_count_csr(p_id NUMBER) IS
SELECT count(1)
  FROM ozf_resale_lines_int
 WHERE status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DUPLICATED
   AND resale_batch_id = p_id;

BEGIN
   SAVEPOINT  Update_Duplicates;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
      l_api_version,
      p_api_version,
      l_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Initialize message LIST IF p_init_msg_LIST IS TRUE.
   IF FND_API.To_Boolean (p_init_msg_LIST) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN open_lines_csr(p_resale_batch_id);
   FETCH open_lines_csr BULK COLLECT INTO l_open_lines_tbl, l_direct_customer_tbl, l_claimed_amount_tbl;
   CLOSE open_lines_csr;

   IF l_open_lines_tbl.EXISTS(1) THEN
      FOR i IN 1..l_open_lines_tbl.LAST
      LOOP
         -- BUG 4670154 (+)
         UPDATE ozf_resale_lines_int_all
            SET duplicated_line_id = NULL
            ,   duplicated_adjustment_id = NULL
         WHERE resale_line_int_id = l_open_lines_tbl(i);
         -- BUG 4670154 (-)

         OZF_RESALE_COMMON_PVT.Check_Duplicate_Line (
             p_api_version_number => 1.0
            ,p_init_msg_LIST      => FND_API.G_FALSE
            ,p_commit             => FND_API.G_FALSE
            ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
            ,x_return_status      => l_return_status
            ,x_msg_count          => l_msg_count
            ,x_msg_data           => l_msg_data
            ,p_resale_line_int_id => l_open_lines_tbl(i)
            ,p_direct_customer_flag => l_direct_customer_tbl(i)
            ,p_claimed_amount     => l_claimed_amount_tbl(i)
            ,p_batch_type         => p_resale_batch_type
            ,x_dup_line_id        => l_dup_line_id
            ,x_dup_adjustment_id  => l_dup_adjustment_id
            ,x_reprocessing       => l_reprocessing
         );

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            OZF_UTILITY_PVT.error_message('OZF_RESALE_CHK_DUP_ERR');
         ELSE
            IF l_dup_adjustment_id IS NOT NULL AND l_reprocessing THEN
               -- Set the line and adjustment as duplicates
               UPDATE ozf_resale_lines_int
                  SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DUPLICATED
                  ,   duplicated_line_id = l_dup_line_id
                  ,   duplicated_adjustment_id = l_dup_adjustment_id
                  ,   dispute_code = 'OZF_RESALE_DUP'
               WHERE resale_line_int_id = l_open_lines_tbl(i);

               Insert_Resale_Log (
                  p_id_value    => l_open_lines_tbl(i),
                  p_id_type     => 'IFACE',
                  p_error_code  => 'OZF_RESALE_DUP',
                  p_column_name => 'DUPLICATED_ADJUSTMENT_ID',
                  p_column_value => l_dup_adjustment_id,
                  x_return_status => l_return_status );
               IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
               ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            ELSE
               -- record dup line if necessary
               UPDATE ozf_resale_lines_int
                  SET duplicated_line_id = l_dup_line_id
                    , duplicated_adjustment_id = l_dup_adjustment_id
                WHERE resale_line_int_id = l_open_lines_tbl(i);
            END IF;
         END IF;
      END LOOP;
   END IF;

   OPEN duplicate_count_csr (p_resale_batch_id);
   FETCH duplicate_count_csr INTO l_duplicate_count;
   CLOSE duplicate_count_csr;

   OPEN batch_count_csr(p_resale_batch_id);
   FETCH batch_count_csr INTO l_batch_count;
   CLOSE batch_count_csr;

   IF l_duplicate_count = l_batch_count THEN
      -- Reject batch if all lines are duplicates
      x_batch_status := OZF_RESALE_COMMON_PVT.G_BATCH_REJECTED ;
      --
      UPDATE ozf_resale_batches_all
         SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_REJECTED
       WHERE resale_batch_id = p_resale_batch_id;
      --
   --bug # 6134121 fixed by ateotia(+)
   ELSIF (l_duplicate_count >=1) THEN
      --dispute the batch if lines are duplicated within in the same batch
      x_batch_status := OZF_RESALE_COMMON_PVT.G_BATCH_DISPUTED ;
      UPDATE ozf_resale_batches_all
         SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_DISPUTED
         WHERE resale_batch_id = p_resale_batch_id;
   --bug # 6134121 fixed by ateotia(-)
   ELSE
      -- JXWU In this case we just keep the current status
      x_batch_status := p_batch_status;
/*
      -- Open batch IS there are some Open lines to process
      x_batch_status := 'OPEN';
      --
      BEGIN
         -- set DISPUTED_code to NULL for the lines to be processed.
         UPDATE ozf_resale_lines_int
            SET dispute_code = NULL
          WHERE resale_batch_id = p_resale_batch_id
            AND status_code= OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_OPEN;

         -- UPDATE tracing order lines to processed for this order to be processed
         UPDATE ozf_resale_lines_int
            SET status_code= OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED
          WHERE resale_batch_id = p_resale_batch_id
            AND status_code= OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_OPEN
            AND tracing_flag = 'T';
         --
      EXCEPTION
         WHEN OTHERS THEN
            IF OZF_UNEXP_ERROR THEN
               FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;
*/
      --
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': End');
   END IF;

   --Standard call to get message count AND IF count=1, get the message
   FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Duplicates;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Duplicates;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Duplicates;
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
END Update_Duplicates;

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
    p_api_version            IN  NUMBER
   ,p_init_msg_LIST          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN  NUMBER
   ,x_batch_status           OUT NOCOPY VARCHAR2
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)IS
l_api_name          CONSTANT VARCHAR2(30) := 'Validate_Batch';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     VARCHAR2(30);
l_batch_count NUMBER;
l_status_code VARCHAR2(30);
l_report_date date;
l_report_start_date date;
l_report_end_date date;
l_partner_cust_account_id NUMBER;
--
l_int_line_count NUMBER;
l_line_count NUMBER;
l_total_line_count NUMBER := NULL;
l_partner_id_count NUMBER;

CURSOR batch_info_csr IS
SELECT batch_count
     , status_code
     , report_date
     , report_start_date
     , report_end_date
     , partner_cust_account_id
  FROM ozf_resale_batches
 WHERE resale_batch_id = p_resale_batch_id;

CURSOR int_line_count_csr IS
SELECT count(1)
  FROM ozf_resale_lines_int
 WHERE resale_batch_id = p_resale_batch_id;

CURSOR line_count_csr IS
SELECT count(1)
  FROM ozf_resale_batch_line_maps
 WHERE resale_batch_id = p_resale_batch_id;

CURSOR count_cust_acctid_csr(p_id NUMBER) IS
SELECT 1
  FROM dual
 WHERE EXISTS (SELECT hca.cust_account_id
                 FROM hz_cust_accounts hca
                WHERE hca.cust_account_id = p_id);
--
BEGIN

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
     l_api_version,
     p_api_version,
     l_api_name,
     G_PKG_NAME)
   THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Initialize message LIST IF p_init_msg_LIST IS TRUE.
   IF FND_API.To_Boolean (p_init_msg_LIST) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- First, do some basic check
   OPEN batch_info_csr;
   FETCH batch_info_csr INTO l_batch_count,
                             l_status_code,
                             l_report_date,
                             l_report_start_date,
                             l_report_end_date,
                             l_partner_cust_account_id;
   CLOSE batch_info_csr;

   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message('Report date:' || l_report_date);
      OZF_UTILITY_PVT.debug_message('Report Start date:' || l_report_start_date);
      OZF_UTILITY_PVT.debug_message('Report End date:' || l_report_end_date);
   END IF;

   -- Check status
   IF l_status_code <> G_BATCH_PROCESSING THEN
      --
      x_return_status := FND_API.G_RET_STS_ERROR;
      --
      Insert_Resale_Log (
         p_id_value      => p_resale_batch_id,
         p_id_type       => G_ID_TYPE_BATCH,
         p_error_code    => 'OZF_BATCH_STATUS_WNG',
         p_column_name   => 'STATUS_CODE',
         p_column_value  => l_status_code,
         x_return_status => l_return_status );
      --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      --
   END IF;

   -- Check report_date
   IF l_report_date IS NULL THEN
      --
      x_return_status := FND_API.G_RET_STS_ERROR;
      --
      Insert_Resale_Log (
         p_id_value      => p_resale_batch_id,
         p_id_type       => G_ID_TYPE_BATCH,
         p_error_code    => 'OZF_BATCH_REPORT_DATE_NULL',
         p_column_name   => 'REPORT_date',
         p_column_value  => NULL,
         x_return_status => l_return_status );
      --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      --
   END IF;

   -- Check report_start_date
   IF l_report_start_date IS NULL THEN
      --
      x_return_status := FND_API.G_RET_STS_ERROR;
      --
      Insert_Resale_Log (
         p_id_value      => p_resale_batch_id,
         p_id_type       => G_ID_TYPE_BATCH,
         p_error_code    => 'OZF_BATCH_REPORT_ST_DATE_NULL',
         p_column_name   => 'REPORT_START_date',
         p_column_value  => NULL,
         x_return_status => l_return_status );
      --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      --
   END IF;

   -- Check report_end_date
   IF l_report_end_date IS NULL THEN
      --
      x_return_status := FND_API.G_RET_STS_ERROR;
      --
      Insert_Resale_Log (
         p_id_value      => p_resale_batch_id,
         p_id_type       => G_ID_TYPE_BATCH,
         p_error_code    => 'OZF_BATCH_REPORT_END_DATE_NULL',
         p_column_name   => 'REPORT_END_date',
         p_column_value  => NULL,
         x_return_status => l_return_status );
      --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      --
   END IF;

   --
   IF l_report_date IS NOT NULL        AND
      l_report_start_date IS NOT NULL  AND
      l_report_end_date IS NOT NULL
   THEN
      IF l_report_start_date > l_report_end_date THEN

         x_return_status := FND_API.G_RET_STS_ERROR;
         --
         Insert_Resale_Log (
            p_id_value      => p_resale_batch_id,
            p_id_type       => G_ID_TYPE_BATCH,
            p_error_code    => 'OZF_RESALE_WNG_DATE_RANGE',
            p_column_name   => 'REPORT_START_DATE',
            p_column_value  => NULL,
            x_return_status => l_return_status );
         --
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
         --
      END IF;
      --
   END IF;

   -- Check partner_cust_account_id
   IF l_partner_cust_account_id IS NULL THEN
      --
      x_return_status := FND_API.G_RET_STS_ERROR;
      --
      Insert_Resale_Log (
         p_id_value      => p_resale_batch_id,
         p_id_type       => G_ID_TYPE_BATCH,
         p_error_code    => 'OZF_BATCH_PARTNER_NULL',
         p_column_name   => 'PARTNER_CUST_ACCOUNT_ID',
         p_column_value  => NULL,
         x_return_status => l_return_status );
      --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      --
   ELSE
      -- make sure partner cust_account_id IS valid
      OPEN count_cust_acctid_csr(l_partner_cust_account_id);
      FETCH count_cust_acctid_csr INTO l_partner_id_count;
      CLOSE count_cust_acctid_csr;
      --
      IF l_partner_id_count IS NULL THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         --
         Insert_Resale_Log (
            p_id_value      => p_resale_batch_id,
            p_id_type       => G_ID_TYPE_BATCH,
            p_error_code    => 'OZF_BATCH_PARTNER_ERR',
            p_column_name   => 'PARTNER_CUST_ACCOUNT_ID',
            p_column_value  => l_partner_cust_account_id,
            x_return_status => l_return_status );
         --
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
         --
      END IF;
   END IF;

   -- check batch count. why IS this required ??
   IF l_batch_count IS NULL OR
      l_batch_count = 0
   THEN
      --
      x_return_status := FND_API.G_RET_STS_ERROR;
      --
      Insert_Resale_Log (
         p_id_value      => p_resale_batch_id,
         p_id_type       => G_ID_TYPE_BATCH,
         p_error_code    => 'OZF_BATCH_COUNT_NULL',
         p_column_name   => 'BATCH_COUNT',
         p_column_value  => NULL,
         x_return_status => l_return_status );
      --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      --
   END IF;

   -- THEN I will check whether the batch_count = line belongs to that batch
   OPEN int_line_count_csr;
   FETCH int_line_count_csr INTO l_int_line_count;
   CLOSE int_line_count_csr;

   OPEN line_count_csr;
   FETCH line_count_csr INTO l_line_count;
   CLOSE line_count_csr;

   IF l_int_line_count IS NOT NULL THEN
      -- records the total number of lines in interface table for the batch
      l_total_line_count := l_int_line_count;
      IF l_line_count IS NOT NULL THEN
         -- records the total number of lines in int table and map table for the batch
         l_total_line_count := l_total_line_count + l_line_count;
      END IF;
   ELSE
      IF l_line_count IS NOT NULL THEN
         -- records the total number of lines in map table for the batch
         l_total_line_count := l_line_count;
      END IF;
   END IF;

   -- batch without any lines cannot be processed
   IF l_total_line_count IS NULL THEN
      --
      x_return_status := FND_API.G_RET_STS_ERROR;
      --
      Insert_Resale_Log (
         p_id_value      => p_resale_batch_id,
         p_id_type       => G_ID_TYPE_BATCH,
         p_error_code    => 'OZF_BATCH_LINE_COUNT_ERR',
         p_column_name   => NULL,
         p_column_value  => NULL,
         x_return_status => l_return_status );
      --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      --
   ELSE
      -- checks if the batch count and actual number of lines in batch are same
      IF l_batch_count IS NOT NULL AND
         l_batch_count <> l_total_line_count
      THEN
         --
         x_return_status := FND_API.G_RET_STS_ERROR;
         --
         Insert_Resale_Log (
            p_id_value      => p_resale_batch_id,
            p_id_type       => G_ID_TYPE_BATCH,
            p_error_code    => 'OZF_BATCH_COUNT_ERR',
            p_column_name   => 'BATCH_COUNT',
            p_column_value  => l_batch_count,
            x_return_status => l_return_status );
         --
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
         --
      END IF;
   END IF;

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      -- SLKRISHN common update
      BEGIN
         UPDATE ozf_resale_batches
         SET    status_code= G_BATCH_DISPUTED
         WHERE  resale_batch_id = p_resale_batch_id;
      EXCEPTION
         WHEN OTHERS THEN
            IF OZF_UNEXP_ERROR THEN
               FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': END');
   END IF;

   --Standard call to get message count AND IF count=1, get the message
   FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data
   );
--
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN
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
END Validate_Batch;

---------------------------------------------------------------------
-- PROCEDURE
--   Validate_Order_Record
--
-- PURPOSE
--    This procedure validates the order information
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Validate_Order_Record(
    p_api_version            IN  NUMBER
   ,p_init_msg_LIST          IN  VARCHAR2 := FND_API.G_FALSE
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
l_return_status varchar2(1);
BEGIN

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Initialize message LIST IF p_init_msg_LIST IS TRUE.
   IF FND_API.To_Boolean (p_init_msg_LIST) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Log lines with null values when required
   Log_Null_Values (
      p_batch_id       =>p_resale_batch_id,
      x_return_status  => l_return_status);
   --
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --

   -- Log lines with invalid values
   Log_Invalid_Values (
      p_batch_id       =>p_resale_batch_id,
      x_return_status  => l_return_status);
   --
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --

   Bulk_Dispute_Line (
      p_batch_id      => p_resale_batch_id,
      p_line_status   => G_BATCH_ADJ_OPEN,
      x_return_status => l_return_status
   );
   --
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': End');
   END IF;

   --Standard call to get message count AND IF count=1, get the message
   FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
      );
   WHEN OTHERS THEN
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
END Validate_Order_Record;

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Utilization_record
--
-- PURPOSE
--    ThIS procedure prepare the record FOR utilization
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Create_Utilization_record(
   p_line_int_rec        IN  g_interface_rec_csr%ROWTYPE
  ,p_batch_type          IN  VARCHAR2
  ,p_fund_id             IN  NUMBER
  ,p_line_id             IN  NUMBER
  ,p_cust_account_id     IN  NUMBER
  ,p_approver_id         IN  NUMBER
  ,p_line_agreement_flag IN  VARCHAR2
  ,p_utilization_type    IN  VARCHAR2
  ,p_adjustment_type_id     IN  NUMBER
  ,p_budget_source_type  IN  VARCHAR2
  ,p_budget_source_id    IN  NUMBER
  ,p_justification       IN  VARCHAR2
  ,p_to_create_utilization  IN BOOLEAN
  ,x_return_status       OUT NOCOPY VARCHAR2
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Create_Utilization_Rec';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     VARCHAR2(30);
l_msg_data          VARCHAR2(2000);
l_msg_count         NUMBER;

l_pric_act_budgets_rec ozf_actbudgets_pvt.act_budgets_rec_type;
l_pric_act_util_rec    ozf_actbudgets_pvt.act_util_rec_type;
l_pric_price_adj_rec   ozf_resale_adjustments_all%ROWTYPE;

l_adjustment_id NUMBER;
l_rate NUMBER;
l_exchange_type VARCHAR2(30);
BEGIN
   -- Standard begin of API savepoint
   SAVEPOINT IDSM_Create_Utiz_Rec;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;

   -- Create act Utilization Record.
   l_pric_act_util_rec.object_type        := 'TP_ORDER';
   l_pric_act_util_rec.object_id          :=  p_line_id;
   l_pric_act_util_rec.product_level_type := 'PRODUCT';
   l_pric_act_util_rec.product_id         :=  p_line_int_rec.inventory_item_Id;

   -- Pass partner account id for this
   l_pric_act_util_rec.billto_cust_account_id    := p_cust_account_id;
   l_pric_act_util_rec.utilization_type   := p_utilization_type;
   l_pric_act_util_rec.adjustment_type_id := p_adjustment_type_id;

   -- Reference for batch
   l_pric_act_util_rec.reference_type     := OZF_RESALE_COMMON_PVT.G_BATCH_REF_TYPE;
   l_pric_act_util_rec.reference_id       := p_line_int_rec.resale_batch_id;

   -- Add gl_date
   l_pric_act_util_rec.gl_date            := p_line_int_rec.date_shipped;

   -- Add org_id
   l_pric_act_util_rec.org_id             := p_line_int_rec.org_id;

   --nirprasa,12.2 ER 8399134
   l_pric_act_util_rec.plan_currency_code           := p_line_int_rec.currency_code;
   l_pric_act_util_rec.fund_request_currency_code   := p_line_int_rec.currency_code;
   --nirprasa,12.2
   -- Create Budget Record.
   l_pric_act_budgets_rec.parent_source_id  := p_fund_id;
   l_pric_act_budgets_rec.arc_act_budget_used_by := p_budget_source_type;
   l_pric_act_budgets_rec.act_budget_used_by_id  := p_budget_source_id;
   l_pric_act_budgets_rec.budget_source_type     := p_budget_source_type;
   l_pric_act_budgets_rec.budget_source_id       := p_budget_source_id;
   l_pric_act_budgets_rec.status_code            := 'APPROVED';--l_utilization_rec.status_code;

   -- get request amount in budget currency
   l_pric_act_budgets_rec.request_currency       := p_line_int_rec.currency_code;
   l_pric_act_budgets_rec.request_amount         := p_line_int_rec.total_accepted_amount;

   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message('request currency'|| l_pric_act_budgets_rec.request_currency);
      OZF_UTILITY_PVT.debug_message('request amount: '||l_pric_act_budgets_rec.request_amount);
   END IF;

   IF p_batch_type <> G_SPECIAL_PRICING THEN
      l_pric_act_budgets_rec.parent_src_curr :=
            OZF_ACTBUDGETS_PVT.Get_Object_Currency (
               'FUND'
               ,l_pric_act_budgets_rec.parent_source_id
               ,l_return_status
            );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      l_pric_act_budgets_rec.parent_src_apprvd_amt := p_line_int_rec.total_accepted_amount;

      IF p_line_int_rec.currency_code <> l_pric_act_budgets_rec.parent_src_curr THEN
         IF OZF_DEBUG_LOW_ON THEN
            OZF_UTILITY_PVT.debug_message('in exchange');
         END IF;
         -- get convertion type
         OPEN OZF_RESALE_COMMON_PVT.g_exchange_rate_type_csr;
         FETCH OZF_RESALE_COMMON_PVT.g_exchange_rate_type_csr INTO l_exchange_type;
         CLOSE OZF_RESALE_COMMON_PVT.g_exchange_rate_type_csr;

         OZF_UTILITY_PVT.Convert_Currency (
             p_from_currency   => p_line_int_rec.currency_code
            ,p_to_currency     => l_pric_act_budgets_rec.parent_src_curr
            ,p_conv_type       => l_exchange_type
            ,p_conv_rate       => FND_API.G_MISS_NUM
            ,p_conv_date       => sysdate
            ,p_from_amount     => p_line_int_rec.total_accepted_amount
            ,x_return_status   => l_return_status
            ,x_to_amount       => l_pric_act_budgets_rec.parent_src_apprvd_amt
            ,x_rate            => l_rate);

         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
         --
      END IF;

   END IF;

   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message('act currency: '||p_line_int_rec.currency_code);
      OZF_UTILITY_PVT.debug_message('par src: '||l_pric_act_budgets_rec.parent_src_curr);
      OZF_UTILITY_PVT.debug_message('approve amount: '||l_pric_act_budgets_rec.parent_src_apprvd_amt);
   END IF;

   l_pric_act_budgets_rec.transfer_type := 'UTILIZED';
   l_pric_act_budgets_rec.justification := p_justification;

   -- Add approver_id AND requester_id
   l_pric_act_budgets_rec.approver_id := OZF_UTILITY_PVT.get_resource_id (p_approver_id);
   l_pric_act_budgets_rec.requester_id := OZF_UTILITY_PVT.get_resource_id (p_approver_id);

   -- Insert INTO ozf_adjustment TABLE.
   OPEN OZF_RESALE_COMMON_PVT.g_adjustment_id_csr;
   FETCH OZF_RESALE_COMMON_PVT.g_adjustment_id_csr INTO l_adjustment_id;
   CLOSE OZF_RESALE_COMMON_PVT.g_adjustment_id_csr;

   l_pric_price_adj_rec.resale_adjustment_id := l_adjustment_id;
   l_pric_price_adj_rec.resale_batch_id := p_line_int_rec.resale_batch_id;
   l_pric_price_adj_rec.resale_line_id := p_line_id;
   l_pric_price_adj_rec.status_code := OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_CLOSED;
   l_pric_price_adj_rec.orig_system_agreement_uom      := p_line_int_rec.orig_system_agreement_uom;
   l_pric_price_adj_rec.orig_system_agreement_name     := p_line_int_rec.orig_system_agreement_name;
   l_pric_price_adj_rec.orig_system_agreement_type     := p_line_int_rec.orig_system_agreement_type;
   l_pric_price_adj_rec.orig_system_agreement_status   := p_line_int_rec.orig_system_agreement_status;
   l_pric_price_adj_rec.orig_system_agreement_curr     := p_line_int_rec.orig_system_agreement_curr;
   l_pric_price_adj_rec.orig_system_agreement_price    := p_line_int_rec.orig_system_agreement_price;
   l_pric_price_adj_rec.orig_system_agreement_quantity := p_line_int_rec.orig_system_agreement_quantity;
   l_pric_price_adj_rec.agreement_id                   := p_line_int_rec.agreement_id;
   l_pric_price_adj_rec.agreement_type                 := p_line_int_rec.agreement_type;
   l_pric_price_adj_rec.agreement_name                 := p_line_int_rec.agreement_name;
   l_pric_price_adj_rec.agreement_price                := p_line_int_rec.agreement_price;
   l_pric_price_adj_rec.agreement_uom_code             := p_line_int_rec.agreement_uom_code;
   l_pric_price_adj_rec.corrected_agreement_id         := p_line_int_rec.corrected_agreement_id;
   l_pric_price_adj_rec.corrected_agreement_name       := p_line_int_rec.corrected_agreement_name;
   l_pric_price_adj_rec.credit_code                    := p_line_int_rec.credit_code;
   l_pric_price_adj_rec.credit_advice_date             := p_line_int_rec.credit_advice_date;
   l_pric_price_adj_rec.claimed_amount                 := p_line_int_rec.claimed_amount;
   l_pric_price_adj_rec.total_claimed_amount           := p_line_int_rec.total_claimed_amount;
   l_pric_price_adj_rec.allowed_amount                 := p_line_int_rec.allowed_amount;
   l_pric_price_adj_rec.total_allowed_amount           := p_line_int_rec.total_allowed_amount;
   l_pric_price_adj_rec.accepted_amount                := p_line_int_rec.accepted_amount;
   l_pric_price_adj_rec.total_accepted_amount          := p_line_int_rec.total_accepted_amount;
   l_pric_price_adj_rec.calculated_price               := p_line_int_rec.calculated_price;
   l_pric_price_adj_rec.acctd_calculated_price         := p_line_int_rec.acctd_calculated_price;
   l_pric_price_adj_rec.calculated_amount              := p_line_int_rec.calculated_amount;
   l_pric_price_adj_rec.line_agreement_flag            := p_line_agreement_flag;
   l_pric_price_adj_rec.tolerance_flag                 := p_line_int_rec.tolerance_flag;
   l_pric_price_adj_rec.line_tolerance_amount          := p_line_int_rec.line_tolerance_amount;
   l_pric_price_adj_rec.operand                        := NULL;
   l_pric_price_adj_rec.operand_calculation_code       := NULL;
   l_pric_price_adj_rec.priced_quantity                := p_line_int_rec.quantity;
   l_pric_price_adj_rec.priced_uom_code                := p_line_int_rec.uom_code;
   l_pric_price_adj_rec.priced_unit_price              := p_line_int_rec.calculated_price;
   l_pric_price_adj_rec.liSt_header_id                 := NULL;
   l_pric_price_adj_rec.liSt_line_id                   := NULL;

   OZF_RESALE_COMMON_PVT.Create_Adj_And_Utilization(
       p_api_version     => 1
      ,p_init_msg_list   => FND_API.G_FALSE
      ,p_commit          => FND_API.G_FALSE
      ,p_validation_level=> FND_API.G_VALID_LEVEL_FULL
      ,p_price_adj_rec   => l_pric_price_adj_rec
      ,p_act_budgets_rec => l_pric_act_budgets_rec
      ,p_act_util_rec    => l_pric_act_util_rec
      ,p_to_create_utilization  => p_to_create_utilization
      ,x_return_status   => l_return_status
      ,x_msg_data        => l_msg_data
      ,x_msg_count       => l_msg_count
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- update the interface duplicated line
   UPDATE ozf_resale_lines_int_all
   SET duplicated_line_id = p_line_id
     , duplicated_adjustment_id =l_adjustment_id
   WHERE duplicated_line_id = p_line_int_rec.resale_line_int_id
   AND duplicated_adjustment_id = -1;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': End');
   END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO IDSM_Create_Utiz_Rec;
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO IDSM_Create_Utiz_Rec;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      ROLLBACK TO IDSM_Create_Utiz_Rec;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
END Create_Utilization_record;

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Adj_And_Utilization
--
-- PURPOSE
--    This function receives the price adjustment rec AND utilization record
--    It them inserts the price adjustmetns AND utilization
--
-- PARAMETERS
--
-- p_adj_rec IN ozf_chargeback_price_adj_all%rowtype
-- p_act_budgets_rec ozf_actbudgets_pvt.act_budgets_rec_type
-- p_act_util_rec    ozf_actbudgets_pvt.act_util_rec_type;
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Create_Adj_And_Utilization(
    p_api_version            IN    NUMBER
   ,p_init_msg_LIST          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_price_adj_rec          IN    ozf_resale_adjustments_all%rowtype
   ,p_act_budgets_rec        IN    ozf_actbudgets_pvt.act_budgets_rec_type
   ,p_act_util_rec           IN    ozf_actbudgets_pvt.act_util_rec_type
   ,p_to_create_utilization  IN BOOLEAN
   ,x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)IS
l_api_name          CONSTANT VARCHAR2(30) := 'Create_Adj_and_Utilization';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_act_budget_id NUMBER;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER;
l_return_status VARCHAR2(30);

l_adjustment_id  NUMBER:= p_price_adj_rec.resale_adjustment_id;

l_obj_ver_num NUMBER := 1;
l_org_id NUMBER;

l_utilized_amount NUMBER;
BEGIN
   -- Standard BEGIN of API savepoint
   SAVEPOINT  Create_Adj_And_Utilization;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
      l_api_version,
      p_api_version,
      l_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Initialize message LIST IF p_init_msg_LIST IS TRUE.
   IF FND_API.To_Boolean (p_init_msg_LIST) THEN
     FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message('adj_id:' || p_price_adj_rec.resale_adjustment_id ||'line_id:' || p_price_adj_rec.resale_line_id);
      IF p_to_create_utilization THEN
         OZF_UTILITY_PVT.debug_message('create utilization:T');
      ELSE
         OZF_UTILITY_PVT.debug_message('create utilization:F');
      END IF;
   END IF;

   -- get price_adj_id
   IF l_adjustment_id IS NULL THEN
      OPEN g_adjustment_id_csr;
      FETCH g_adjustment_id_csr INTO l_adjustment_id;
      CLOSE g_adjustment_id_csr;
   END IF;

   IF p_price_adj_rec.org_id IS NOT NULL THEN
      l_org_id := p_price_adj_rec.org_id;
   ELSE
      l_org_id := MO_GLOBAL.get_current_org_id();
   END IF;

   -- We only need to record for every price adjustment information
   BEGIN
      OZF_RESALE_ADJUSTMENTS_PKG.Insert_Row(
         px_resale_adjustment_id       => l_adjustment_id,
         px_object_version_number      => l_obj_ver_num,
         p_last_update_date            => sysdate,
         p_last_updated_by             => NVL(FND_GLOBAL.user_id,-1),
         p_creation_date               => sysdate,
         p_request_id                  => FND_GLOBAL.CONC_REQUEST_ID,
         p_created_by                  => NVL(FND_GLOBAL.user_id,-1),
         p_created_from                => p_price_adj_rec.created_from,
         p_last_update_login           => NVL(FND_GLOBAL.conc_login_id,-1),
         p_program_application_id      => FND_GLOBAL.PROG_APPL_ID,
         p_program_update_date         => sysdate,
         p_program_id                  => FND_GLOBAL.CONC_PROGRAM_ID,
         p_resale_line_id              => p_price_adj_rec.resale_line_id,
         p_resale_batch_id             => p_price_adj_rec.resale_batch_id,
         p_orig_system_agreement_uom   => p_price_adj_rec.orig_system_agreement_uom,
         p_orig_system_agreement_name  => p_price_adj_rec.orig_system_agreement_name,
         p_orig_system_agreement_type  => p_price_adj_rec.orig_system_agreement_type,
         p_orig_system_agreement_status=> p_price_adj_rec.orig_system_agreement_status,
         p_orig_system_agreement_curr  => p_price_adj_rec.orig_system_agreement_curr,
         p_orig_system_agreement_price => p_price_adj_rec.orig_system_agreement_price,
         p_orig_system_agreement_quant => p_price_adj_rec.orig_system_agreement_quantity,
         p_agreement_id                => p_price_adj_rec.agreement_id  ,
         p_agreement_type              => p_price_adj_rec.agreement_type ,
         p_agreement_name              => p_price_adj_rec.agreement_name ,
         p_agreement_price             => p_price_adj_rec.agreement_price ,
         p_agreement_uom_code          => p_price_adj_rec.agreement_uom_code,
         p_corrected_agreement_id      => p_price_adj_rec.corrected_agreement_id ,
         p_corrected_agreement_name    => p_price_adj_rec.corrected_agreement_name ,
         p_credit_code                 => p_price_adj_rec.credit_code,
         p_credit_advice_date          => p_price_adj_rec.credit_advice_date,
         p_total_allowed_amount        => p_price_adj_rec.total_allowed_amount,
         p_allowed_amount              => p_price_adj_rec.allowed_amount,
         p_total_accepted_amount       => p_price_adj_rec.total_accepted_amount,
         p_accepted_amount             => p_price_adj_rec.accepted_amount,
         p_total_claimed_amount        => p_price_adj_rec.total_claimed_amount,
         p_claimed_amount              => p_price_adj_rec.claimed_amount,
         p_calculated_price            => p_price_adj_rec.calculated_price,
         p_acctd_calculated_price      => p_price_adj_rec.acctd_calculated_price,
         p_calculated_amount           => p_price_adj_rec.calculated_amount,
         p_line_agreement_flag         => p_price_adj_rec.line_agreement_flag,
         p_tolerance_flag              => p_price_adj_rec.tolerance_flag,
         p_line_tolerance_amount       => p_price_adj_rec.line_tolerance_amount,
         p_operand                     => p_price_adj_rec.operand,
         p_operand_calculation_code    => p_price_adj_rec.operand_calculation_code,
         p_priced_quantity             => p_price_adj_rec.priced_quantity,
         p_priced_uom_code             => p_price_adj_rec.priced_uom_code,
         p_priced_unit_price           => p_price_adj_rec.priced_unit_price,
         p_list_header_id              => p_price_adj_rec.list_header_id,
         p_list_line_id                => p_price_adj_rec.list_line_id,
         p_status_code                 => 'CLOSED',
         px_org_id                     => l_org_id
      );
         --
   EXCEPTION
      WHEN OTHERS THEN
         IF OZF_UNEXP_ERROR THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   -- Create accrual only when its required
   IF p_to_create_utilization THEN
      IF OZF_DEBUG_LOW_ON THEN
         ozf_utility_pvt.debug_message('p_act_util_rec.object_type              = '|| p_act_util_rec.object_type);
         ozf_utility_pvt.debug_message('p_act_util_rec.object_id                = '|| p_act_util_rec.object_id);
         ozf_utility_pvt.debug_message('p_act_util_rec.product_level_type       = '|| p_act_util_rec.product_level_type);
         ozf_utility_pvt.debug_message('p_act_util_rec.product_id               = '|| p_act_util_rec.product_id);
         ozf_utility_pvt.debug_message('p_act_util_rec.billto_cust_account_id   = '|| p_act_util_rec.billto_cust_account_id);
         ozf_utility_pvt.debug_message('p_act_util_rec.gl_date                  = '|| p_act_util_rec.gl_date);
         ozf_utility_pvt.debug_message('p_act_util_rec.reference_type           = '|| p_act_util_rec.reference_type);
         ozf_utility_pvt.debug_message('p_act_util_rec.reference_id             = '|| p_act_util_rec.reference_id);
         ozf_utility_pvt.debug_message('p_act_util_rec.price_adjustment_id      = '|| p_act_util_rec.price_adjustment_id);
         ozf_utility_pvt.debug_message('p_act_util_rec.utilization_type         = '|| p_act_util_rec.utilization_type);
         ozf_utility_pvt.debug_message('p_act_util_rec.adjustment_type_id       = '|| p_act_util_rec.adjustment_type_id);
         ozf_utility_pvt.debug_message('p_act_util_rec.org_id                   = '|| p_act_util_rec.org_id);

         ozf_utility_pvt.debug_message('p_act_budgets_rec.act_budget_used_by_id = '|| p_act_budgets_rec.act_budget_used_by_id);
         ozf_utility_pvt.debug_message('p_act_budgets_rec.budget_source_id      = '|| p_act_budgets_rec.budget_source_id);
         ozf_utility_pvt.debug_message('p_act_budgets_rec.status_code           = '|| p_act_budgets_rec.status_code);
         ozf_utility_pvt.debug_message('p_act_budgets_rec.transfer_type         = '|| p_act_budgets_rec.transfer_type);
         ozf_utility_pvt.debug_message('p_act_budgets_rec.arc_act_budget_used_by= '|| p_act_budgets_rec.arc_act_budget_used_by);
         ozf_utility_pvt.debug_message('p_act_budgets_rec.budget_source_type    = '|| p_act_budgets_rec.budget_source_type);
         ozf_utility_pvt.debug_message('p_act_budgets_rec.approver_id           = '|| p_act_budgets_rec.approver_id);
         ozf_utility_pvt.debug_message('p_act_budgets_rec.requester_id          = '|| p_act_budgets_rec.requester_id);
         ozf_utility_pvt.debug_message('p_act_budgets_rec.request_currency      = '|| p_act_budgets_rec.request_currency);
         ozf_utility_pvt.debug_message('p_act_budgets_rec.parent_source_id      = '|| p_act_budgets_rec.parent_source_id);
         ozf_utility_pvt.debug_message('p_act_budgets_rec.parent_src_curr       = '|| p_act_budgets_rec.parent_src_curr);
         ozf_utility_pvt.debug_message('p_act_budgets_rec.justification         = '|| p_act_budgets_rec.justification);
         ozf_utility_pvt.debug_message('p_act_budgets_rec.arc_act_budget_used_by= '|| p_act_budgets_rec.arc_act_budget_used_by);
         ozf_utility_pvt.debug_message('p_act_budgets_rec.budget_source_type    = '|| p_act_budgets_rec.budget_source_type);
         ozf_utility_pvt.debug_message('p_act_budgets_rec.request_currency      = '|| p_act_budgets_rec.request_currency);
         ozf_utility_pvt.debug_message('p_act_budgets_rec.request_amount        = '|| p_act_budgets_rec.request_amount);
         ozf_utility_pvt.debug_message('p_act_budgets_rec.parent_src_apprvd_amt = '|| p_act_budgets_rec.parent_src_apprvd_amt);
      END IF;

      BEGIN
         --
         OZF_FUND_ADJUSTMENT_PVT.Process_Act_Budgets (
            x_return_status   => l_return_status,
            x_msg_count       => l_msg_count,
            x_msg_data        => l_msg_data,
            p_act_budgets_rec => p_act_budgets_rec,
            p_act_util_rec    => p_act_util_rec,
            x_act_budget_id   => l_act_budget_id,
            x_utilized_amount => l_utilized_amount
         );
         IF OZF_DEBUG_LOW_ON THEN
            OZF_UTILITY_PVT.debug_message('OZF_FUND_ADJUSTMENT_PVT.Process_Act_Budgets return result: '||l_return_status);
            OZF_UTILITY_PVT.debug_message('post to budget: budget_source_id:' || p_act_budgets_rec.budget_source_id);
            OZF_UTILITY_PVT.debug_message('post to budget: amount:' || p_act_budgets_rec.request_amount);
            OZF_UTILITY_PVT.debug_message('x_utilized_amount: '||l_utilized_amount);
         END IF;

         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
         -- bug 5391758,5216124
         IF l_utilized_amount = 0 AND p_act_budgets_rec.request_amount <> 0 THEN
            ozf_utility_pvt.error_message ( 'OZF_COMMAMT_LESS_REQAMT');
            RAISE fnd_api.g_exc_error;
         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            IF OZF_UNEXP_ERROR THEN
               FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': End');
   END IF;

   --Standard call to get message count AND IF count=1, get the message
   FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Adj_And_Utilization;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Adj_And_Utilization;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Adj_And_Utilization;
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
END Create_Adj_And_Utilization;

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Utilization
--
-- PURPOSE
--    This procedure creates utilization
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Create_Utilization(
    p_api_version         IN    NUMBER
   ,p_init_msg_LIST       IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_line_int_rec        IN  g_interface_rec_csr%ROWTYPE
   ,p_fund_id             IN  NUMBER
   ,p_line_id             IN  NUMBER
   ,p_cust_account_id     IN  NUMBER
   ,p_approver_id         IN  NUMBER
   ,x_return_status       OUT NOCOPY VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Create_Utilization';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     VARCHAR2(30);
l_msg_data          VARCHAR2(2000);
l_msg_count         NUMBER;
--
l_dup_adjustment_id NUMBER;
l_dup_total_accepted_amount NUMBER;
l_line_int_rec OZF_RESALE_COMMON_PVT.g_interface_rec_csr%ROWTYPE := p_line_int_rec;

CURSOR dup_adj_csr(p_line_id in NUMBER, p_batch_type in VARCHAR2) IS
SELECT a.resale_adjustment_id,
       a.total_accepted_amount
  FROM ozf_resale_adjustments a,
       ozf_resale_batches b,
       ozf_resale_lines c
 WHERE a.resale_line_id = p_line_id
   AND a.resale_batch_id = b.resale_batch_id
   AND b.batch_type = p_batch_type
   AND b.status_code = OZF_RESALE_COMMON_PVT.G_BATCH_CLOSED
   AND c.resale_line_id = a.resale_line_id
   AND c.status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED
   -- BUG 4670154 (+)
   AND a.list_header_id IS NULL
   AND a.list_line_id IS NULL;
   -- BUG 4670154 (-)

CURSOR dup_adj_rec_csr(p_adj_id NUMBER) IS
SELECT *
  FROM ozf_resale_adjustments
 WHERE resale_adjustment_id = p_adj_id;

l_dup_adj_rec dup_adj_rec_csr%ROWTYPE;

l_batch_type  VARCHAR2(30);
l_utilization_type VARCHAR2(30);
l_adjustment_type_id  NUMBER := NULL;
l_budget_source_type  VARCHAR2(30);
l_justification       VARCHAR2(250);
l_to_create_utilization  BOOLEAN;
l_budget_source_id  NUMBER;
-- POS Batch Processing by profiles by ateotia (+)
   l_spr_ship_from_stock_flag      VARCHAR2(1);
   l_spr_offer_type                VARCHAR2(30);
   l_spr_offer_id                  NUMBER;
   CURSOR request_header_info_csr(p_agreement_num VARCHAR2,
                                  p_resale_batch_id NUMBER) IS
   SELECT
     orha.ship_from_stock_flag,
     orha.offer_type,
     qlha.list_header_id
   FROM
     ozf_request_headers_all_vl orha,
     ozf_resale_batches_all orba,
     qp_list_headers_all qlha
   WHERE
     orha.agreement_number = p_agreement_num
     AND orha.status_code = 'APPROVED'
     AND orha.request_class = 'SPECIAL_PRICE'
     AND orha.partner_id = orba.partner_id
     AND orba.resale_batch_id = p_resale_batch_id
     AND orha.authorization_code = qlha.name;
   -- POS Batch Processing by profiles by ateotia (-)

--
BEGIN
   -- Standard BEGIN of API savepoint
   SAVEPOINT  IDSM_Create_Utilization;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
      l_api_version,
      p_api_version,
      l_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Initialize message LIST IF p_init_msg_LIST IS TRUE.
   IF FND_API.To_Boolean (p_init_msg_LIST) THEN
     FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message('IN create_utilization');
   END IF;

   OPEN g_batch_type_csr(l_line_int_rec.resale_batch_id);
   FETCH g_batch_type_csr into l_batch_type;
   CLOSE g_batch_type_csr;

   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message('batch type' ||l_batch_type);
   END IF;

   IF l_batch_type = G_CHARGEBACK THEN
      l_utilization_type:= G_CHBK_UTIL_TYPE;
      l_adjustment_type_id := G_CHBK_ADJ_TYPE_id;
      l_budget_source_type := 'PRIC';
      l_justification      := 'CHARGEBACK';
      l_to_create_utilization := true;
      IF l_line_int_rec.corrected_agreement_id IS NOT NULL THEN
         l_budget_source_id := l_line_int_rec.corrected_agreement_id;
      ELSE
         l_budget_source_id := l_line_int_rec.agreement_id;
      END IF;

   ELSIF l_batch_type = G_SPECIAL_PRICING THEN
      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('In batch type as spp.');
      END IF;
        --POS Batch Processing by profiles by ateotia (+)
         OPEN request_header_info_csr(l_line_int_rec.agreement_name, l_line_int_rec.resale_batch_id);
         FETCH request_header_info_csr INTO l_spr_ship_from_stock_flag,
                                            l_spr_offer_type,
                                            l_spr_offer_id;
         CLOSE request_header_info_csr;
         IF (l_spr_ship_from_stock_flag = 'Y' AND l_spr_offer_type = 'ACCRUAL') THEN
                    l_to_create_utilization  := true;
                    l_budget_source_id       := l_spr_offer_id;
                    l_budget_source_type     := 'OFFR';
                    l_utilization_type       := 'ACCRUAL';
                    -- l_justification for populating ozf_funds_utilized_all_tl.adjustment_desc
                    l_justification          := ' Special Pricing Ship From Stock Accrual';
         ELSE

              l_utilization_type:= G_SPP_UTIL_TYPE;
              l_budget_source_type := 'OFFR';
              l_justification      := 'SPECIAL PRICE';
              l_to_create_utilization  := false;  --???
              IF l_line_int_rec.corrected_agreement_id IS NOT NULL THEN
                 l_budget_source_id := l_line_int_rec.corrected_agreement_id;
              ELSE
                 l_budget_source_id := l_line_int_rec.agreement_id;
       END IF;
      END IF;
          --POS Batch Processing by profiles by ateotia (+)

/*
   ELSIF l_batch_type = G_TP_ACCRUAL THEN
      -- Third party acrrual run from inter face.
      l_utilization_type:= G_TP_ACCRUAL_UTIL_TYPE;
      l_budget_source_id := l_line_int_rec.price_list_id;
      l_adjustment_type_id := G_CHBK_ADJ_TYPE_id;
      l_justification      := 'THIRD PARTY PRICE DIFF';
*/
   END IF;

   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message('dup line id' ||l_line_int_rec.duplicated_line_id);
      OZF_UTILITY_PVT.debug_message('dup_accepted_amount:'||l_dup_total_accepted_amount);
      OZF_UTILITY_PVT.debug_message('total_accepted_amount:'||l_line_int_rec.total_accepted_amount);
   END IF;

   IF l_line_int_rec.duplicated_line_id IS NOT NULL THEN
      IF l_line_int_rec.duplicated_adjustment_id = -1 THEN
         -- Create utilization using int rec
         Create_Utilization_record(
             p_line_int_rec  => l_line_int_rec
            ,p_batch_type    => l_batch_type
            ,p_fund_id       => p_fund_id
            ,p_line_id       => p_line_id
            ,p_cust_account_id => p_cust_account_id
            ,p_approver_id   => p_approver_id
            ,p_line_agreement_flag => 'T'
            ,p_utilization_type => l_utilization_type
            ,p_adjustment_type_id   => l_adjustment_type_id
            ,p_budget_source_type  => l_budget_source_type
            ,p_budget_source_id     => l_budget_source_id
            ,p_justification       => l_justification
            ,p_to_create_utilization =>l_to_create_utilization
            ,x_return_status   => l_return_status
         );
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      ELSE
         -- Go check whether there IS a need to create a reverse utilization
         OPEN dup_adj_csr (l_line_int_rec.duplicated_line_id, l_batch_type);
         FETCH dup_adj_csr INTO l_dup_adjustment_id, l_dup_total_accepted_amount;
         CLOSE dup_adj_csr;
         -- Here the claimed_amount should NOT equal to the current claimed amount
         IF l_dup_total_accepted_amount IS NULL OR -- bug 5222273
            l_dup_total_accepted_amount <> l_line_int_rec.total_accepted_amount THEN
            -- AND the create one FOR the current int rec.
            -- creat utilization using int rec
            Create_Utilization_record(
                p_line_int_rec  => l_line_int_rec
               ,p_batch_type    => l_batch_type
               ,p_fund_id       => p_fund_id
               ,p_line_id       => p_line_id
               ,p_cust_account_id => p_cust_account_id
               ,p_approver_id         => p_approver_id
               ,p_line_agreement_flag => 'T'
               ,p_utilization_type    => l_utilization_type
               ,p_adjustment_type_id  => l_adjustment_type_id
               ,p_budget_source_type  => l_budget_source_type
               ,p_budget_source_id     => l_budget_source_id
               ,p_justification       => l_justification
               ,p_to_create_utilization =>l_to_create_utilization
               ,x_return_status   => l_return_status
            );
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            -- We need to reverse the old utilization
            -- Here I need to repopulate the adj related columns.
            OPEN dup_adj_rec_csr(l_dup_adjustment_id);
            FETCH dup_adj_rec_csr INTO l_dup_adj_rec;
            CLOSE dup_adj_rec_csr;
            l_line_int_rec.orig_system_agreement_uom     := l_dup_adj_rec.orig_system_agreement_uom;
            l_line_int_rec.orig_system_agreement_name    := l_dup_adj_rec.orig_system_agreement_name;
            l_line_int_rec.orig_system_agreement_type    := l_dup_adj_rec.orig_system_agreement_type;
            l_line_int_rec.orig_system_agreement_status  := l_dup_adj_rec.orig_system_agreement_status;
            l_line_int_rec.orig_system_agreement_curr    := l_dup_adj_rec.orig_system_agreement_curr;
            l_line_int_rec.orig_system_agreement_price   := l_dup_adj_rec.orig_system_agreement_price;
            l_line_int_rec.orig_system_agreement_quantity:= l_dup_adj_rec.orig_system_agreement_quantity;
            l_line_int_rec.agreement_id                  := l_dup_adj_rec.agreement_id;
            l_line_int_rec.agreement_type                := l_dup_adj_rec.agreement_type;
            l_line_int_rec.agreement_name                := l_dup_adj_rec.agreement_name;
            l_line_int_rec.agreement_price               := l_dup_adj_rec.agreement_price;
            l_line_int_rec.agreement_uom_code            := l_dup_adj_rec.agreement_uom_code;
            l_line_int_rec.corrected_agreement_id        := l_dup_adj_rec.corrected_agreement_id;
            l_line_int_rec.corrected_agreement_name      := l_dup_adj_rec.corrected_agreement_name;
            l_line_int_rec.credit_code                   := l_dup_adj_rec.credit_code;
            l_line_int_rec.credit_advice_date            := l_dup_adj_rec.credit_advice_date;
            l_line_int_rec.claimed_amount                := l_dup_adj_rec.claimed_amount;
            l_line_int_rec.total_claimed_amount          := l_dup_adj_rec.total_claimed_amount;
            l_line_int_rec.allowed_amount                := l_dup_adj_rec.allowed_amount;
            l_line_int_rec.total_allowed_amount          := l_dup_adj_rec.total_allowed_amount;
            l_line_int_rec.accepted_amount               := -1 * l_dup_adj_rec.accepted_amount;
            l_line_int_rec.total_accepted_amount         := -1 * l_dup_adj_rec.total_accepted_amount;
            l_line_int_rec.calculated_price              := l_dup_adj_rec.calculated_price;
            l_line_int_rec.acctd_calculated_price        := l_dup_adj_rec.acctd_calculated_price;
            l_line_int_rec.calculated_amount             := l_line_int_rec.calculated_amount;
            l_line_int_rec.tolerance_flag                := l_dup_adj_rec.tolerance_flag;
            l_line_int_rec.line_tolerance_amount         := l_dup_adj_rec.line_tolerance_amount;
            l_line_int_rec.quantity                      := l_dup_adj_rec.priced_quantity;
            l_line_int_rec.uom_code                      := l_dup_adj_rec.priced_uom_code;
            l_line_int_rec.calculated_price              := l_dup_adj_rec.priced_unit_price;

            Create_Utilization_record(
                p_line_int_rec         => l_line_int_rec
               ,p_batch_type    => l_batch_type
               ,p_fund_id              => p_fund_id
               ,p_line_id              => p_line_id
               ,p_cust_account_id      => p_cust_account_id
               ,p_approver_id          => p_approver_id
               ,p_line_agreement_flag  => 'F'
               ,p_utilization_type     => l_utilization_type
               ,p_adjustment_type_id     => l_adjustment_type_id
               ,p_budget_source_type   => l_budget_source_type
               ,p_budget_source_id     => l_budget_source_id
               ,p_justification        => l_justification
               ,p_to_create_utilization =>l_to_create_utilization
               ,x_return_status        => l_return_status
            );
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         ELSE
            -- This IS a duplicate. No need to create utilization
            -- SLKRISHN move update to resale common pvt
            UPDATE ozf_resale_lines_int_all
               SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DUPLICATED,
                   duplicated_line_id = p_line_id,
                   duplicated_adjustment_id = l_dup_adjustment_id
             WHERE resale_line_int_id = l_line_int_rec.resale_line_int_id;
         END IF;
      END IF;
   ELSE
      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('In creat utilization with nothing');
      END IF;
      -- Create utilization using int rec
      Create_Utilization_record(
          p_line_int_rec  => l_line_int_rec
         ,p_batch_type    => l_batch_type
         ,p_fund_id       => p_fund_id
         ,p_line_id       => p_line_id
         ,p_cust_account_id => p_cust_account_id
         ,p_approver_id   => p_approver_id
         ,p_line_agreement_flag => 'T'
         ,p_utilization_type => l_utilization_type
         ,p_adjustment_type_id   => l_adjustment_type_id
         ,p_budget_source_type  => l_budget_source_type
         ,p_budget_source_id     => l_budget_source_id
         ,p_justification       => l_justification
         ,p_to_create_utilization =>l_to_create_utilization
         ,x_return_status   => l_return_status
      );
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': End');
   END IF;

   --Standard call to get message count AND IF count=1, get the message
   FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO IDSM_Create_Utilization;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO IDSM_Create_Utilization;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO IDSM_Create_Utilization;
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
END Create_Utilization;

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Sales_Transaction
--
-- PURPOSE
--    This procedure inserts a record in ozf sales transaction table
--
-- PARAMETERS
--    p_line_int_rec  IN g_interface_rec_csr%rowtype,
--    x_headerid       out NUMBER
--    x_return_status  out VARCHAR2
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE Create_Sales_Transaction(
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_line_int_rec           IN  g_interface_rec_csr%rowtype
   ,p_header_id              IN  NUMBER
   ,p_line_id                IN  NUMBER
   ,x_sales_transaction_id   OUT NOCOPY   NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Create_Sales_Transaction';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     VARCHAR2(30);
l_msg_data          VARCHAR2(2000);
l_msg_count         NUMBER;

l_sales_transaction_id NUMBER;
l_object_version_number NUMBER := 1;
l_org_id    NUMBER;

l_sales_transaction_rec OZF_SALES_TRANSACTIONS_PVT.SALES_TRANSACTION_REC_TYPE;

CURSOR party_id_csr(p_cust_account_id NUMBER) IS
SELECT party_id
  FROM hz_cust_accounts
 WHERE cust_account_id = p_cust_account_id;

CURSOR party_site_id_csr(p_account_site_id NUMBER) IS
SELECT party_site_id
  FROM hz_cust_acct_sites
 WHERE cust_acct_site_id = p_account_site_id;

BEGIN
   -- Standard BEGIN of API savepoint
   SAVEPOINT  Create_Sales_Transaction;
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
      OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;

   --Initialize message LIST IF p_init_msg_LIST IS TRUE.
   IF FND_API.To_Boolean (p_init_msg_LIST) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_sales_transaction_rec.sold_from_cust_account_id :=p_line_int_rec.sold_from_cust_account_id;
   OPEN party_id_csr(l_sales_transaction_rec.sold_from_cust_account_id);
   FETCH party_id_csr INTO l_sales_transaction_rec.sold_from_party_id;
   CLOSE party_id_csr;

   OPEN party_site_id_csr(p_line_int_rec.sold_from_site_id);
   FETCH party_site_id_csr INTO l_sales_transaction_rec.sold_from_party_site_id;
   CLOSE party_site_id_csr;

   l_sales_transaction_rec.sold_to_cust_account_id := p_line_int_rec.bill_to_cust_account_id;
   l_sales_transaction_rec.sold_to_party_id        := p_line_int_rec.bill_to_party_id;
   l_sales_transaction_rec.sold_to_party_site_id   := p_line_int_rec.bill_to_party_site_id;
   l_sales_transaction_rec.bill_to_site_use_id  := p_line_int_rec.bill_to_site_use_id;
   l_sales_transaction_rec.ship_to_site_use_id  := p_line_int_rec.ship_to_site_use_id;
   l_sales_transaction_rec.transaction_date := p_line_int_rec.date_ordered;
   IF p_line_int_rec.product_transfer_movement_type = 'TI' THEN
      l_sales_transaction_rec.transfer_type    := 'IN';
   ELSIF p_line_int_rec.product_transfer_movement_type = 'TO' THEN
      l_sales_transaction_rec.transfer_type    := 'OUT';
   ELSIF p_line_int_rec.product_transfer_movement_type = 'DC' THEN
      l_sales_transaction_rec.transfer_type    := 'OUT';
   ELSIF p_line_int_rec.product_transfer_movement_type = 'CD' THEN
      l_sales_transaction_rec.transfer_type    := 'IN';
   END IF;
   l_sales_transaction_rec.quantity     := p_line_int_rec.quantity;
   l_sales_transaction_rec.uom_code             := p_line_int_rec.uom_code;
   l_sales_transaction_rec.amount          := p_line_int_rec.selling_price * p_line_int_rec.quantity;
   l_sales_transaction_rec.currency_code   := p_line_int_rec.currency_code;
   l_sales_transaction_rec.inventory_item_id := p_line_int_rec.inventory_item_id;
   l_sales_transaction_rec.header_id    := p_header_id;
   l_sales_transaction_rec.line_id      := p_line_id;
   l_sales_transaction_rec.reason_code  := NULL;
   l_sales_transaction_rec.source_code  := 'IS';
   l_sales_transaction_rec.error_flag  := NULL;

   -- We need to create sales transactions based on these lines.
   OZF_SALES_TRANSACTIONS_PVT.Create_Transaction (
       p_api_version      => 1.0
      ,p_init_msg_list    => FND_API.G_FALSE
      ,p_commit           => FND_API.G_FALSE
      ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
      ,p_transaction_rec  => l_sales_transaction_rec
      ,x_sales_transaction_id => l_sales_transaction_id
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

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': End');
   END IF;

   --Standard call to get message count AND IF count=1, get the message
   FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Sales_Transaction;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Sales_Transaction;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Sales_Transaction;
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
END Create_Sales_Transaction;

---------------------------------------------------------------------
-- PROCEDURE
--    Insert_Resale_Header
--
-- PURPOSE
--    This procedure inserts a record in to resale header table
--
-- PARAMETERS
--    p_line_int_rec  IN g_interface_rec_csr%rowtype,
--    x_headerid       OUT NUMBER
--    x_return_status  OUT VARCHAR2
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE Insert_Resale_Header(
    p_api_version            IN  NUMBER
   ,p_init_msg_LIST          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_line_int_rec           IN g_interface_rec_csr%rowtype
   ,x_header_id              OUT NOCOPY NUMBER
   ,x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Insert_resale_header';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     VARCHAR2(30);
l_msg_data          VARCHAR2(2000);
l_msg_count         NUMBER;

l_header_id NUMBER;
l_object_version_number NUMBER := 1;
l_org_id    NUMBER;
BEGIN
   -- Standard BEGIN of API savepoint
   SAVEPOINT  Insert_Resale_Header;
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
      OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;

   --Initialize message LIST IF p_init_msg_LIST IS TRUE.
   IF FND_API.To_Boolean (p_init_msg_LIST) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- INSERT the order information to ozf_resale_headers_all
   OPEN g_header_id_csr;
   FETCH g_header_id_csr INTO l_header_id;
   CLOSE g_header_id_csr;

   x_header_id := l_header_id;
   l_org_id := p_line_int_rec.org_id; -- bug # 5997978 fixed
   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message('before INSERT: header_id' || l_header_id);
   END IF;

   OZF_RESALE_HEADERS_PKG.Insert_Row(
      px_resale_header_id        => l_header_id,
      px_object_version_number   => l_object_version_number,
      p_last_update_date         => SYSdate,
      p_last_updated_by          => NVL(FND_GLOBAL.user_id,-1),
      p_creation_date            => SYSdate,
      p_request_id               => FND_GLOBAL.CONC_REQUEST_ID,
      p_created_by               => NVL(FND_GLOBAL.user_id,-1),
      p_last_update_login        => NVL(FND_GLOBAL.conc_login_id,-1),
      p_program_application_id   => FND_GLOBAL.PROG_APPL_ID,
      p_program_update_date      => SYSdate,
      p_program_id               => FND_GLOBAL.CONC_PROGRAM_ID,
      p_created_from             => p_line_int_rec.created_from,
      p_date_shipped             => p_line_int_rec.date_shipped,
      p_date_ordered             => p_line_int_rec.date_ordered,
      p_order_type_id            => p_line_int_rec.order_type_id,
      p_order_type               => p_line_int_rec.order_type,
      p_order_category           => p_line_int_rec.order_category,
      p_status_code              => G_BATCH_PROCESSED,
      p_direct_customer_flag     => p_line_int_rec.direct_customer_flag,
      p_order_number             => p_line_int_rec.order_number,
      p_price_LIST_id            => p_line_int_rec.price_LIST_id,
      p_bill_to_cust_account_id  => p_line_int_rec.bill_to_cust_account_id,
      p_bill_to_site_use_id      => p_line_int_rec.bill_to_site_use_id,
      p_bill_to_party_name       => p_line_int_rec.bill_to_party_name,
      p_bill_to_party_id         =>p_line_int_rec.bill_to_party_id ,
      p_bill_to_party_site_id    =>p_line_int_rec.bill_to_party_site_id ,
      p_bill_to_location         => p_line_int_rec.bill_to_location ,
      p_bill_to_duns_number      => p_line_int_rec.bill_to_duns_number,
      p_bill_to_address          => p_line_int_rec.bill_to_address,
      p_bill_to_city             => p_line_int_rec.bill_to_city ,
      p_bill_to_state            => p_line_int_rec.bill_to_state,
      p_bill_to_postal_code      => p_line_int_rec.bill_to_postal_code,
      p_bill_to_country          => p_line_int_rec.bill_to_country,
      p_bill_to_contact_party_id => p_line_int_rec.bill_to_contact_party_id,
      p_bill_to_contact_name     => p_line_int_rec.bill_to_contact_name,
      p_bill_to_email            => p_line_int_rec.bill_to_email,
      p_bill_to_phone            => p_line_int_rec.bill_to_phone,
      p_bill_to_fax              => p_line_int_rec.bill_to_fax,
      p_ship_to_cust_account_id  => p_line_int_rec.ship_to_cust_account_id,
      p_ship_to_site_use_id      => p_line_int_rec.ship_to_site_use_id,
      p_ship_to_party_name       => p_line_int_rec.ship_to_party_name,
      p_ship_to_party_id         =>p_line_int_rec.ship_to_party_id ,
      p_ship_to_party_site_id    =>p_line_int_rec.ship_to_party_site_id ,
      p_ship_to_location         => p_line_int_rec.ship_to_location,
      p_ship_to_duns_number      => p_line_int_rec.ship_to_duns_number,
      p_ship_to_address          => p_line_int_rec.ship_to_address,
      p_ship_to_city             => p_line_int_rec.ship_to_city,
      p_ship_to_state            => p_line_int_rec.ship_to_state,
      p_ship_to_postal_code      => p_line_int_rec.ship_to_postal_code,
      p_ship_to_country          => p_line_int_rec.ship_to_country,
      p_ship_to_contact_party_id => p_line_int_rec.ship_to_contact_party_id,
      p_ship_to_contact_name     => p_line_int_rec.ship_to_contact_name,
      p_ship_to_email            => p_line_int_rec.ship_to_email,
      p_ship_to_phone            => p_line_int_rec.ship_to_phone,
      p_ship_to_fax              => p_line_int_rec.ship_to_fax,
      p_sold_from_cust_account_id=> p_line_int_rec.sold_from_cust_account_id,
      p_ship_from_cust_account_id=> p_line_int_rec.ship_from_cust_account_id,
      p_header_attribute_category=> p_line_int_rec.header_attribute_category,
      p_header_attribute1        => p_line_int_rec.header_attribute1,
      p_header_attribute2        => p_line_int_rec.header_attribute2,
      p_header_attribute3        => p_line_int_rec.header_attribute3,
      p_header_attribute4        => p_line_int_rec.header_attribute4,
      p_header_attribute5        => p_line_int_rec.header_attribute5,
      p_header_attribute6        => p_line_int_rec.header_attribute6,
      p_header_attribute7        => p_line_int_rec.header_attribute7,
      p_header_attribute8        => p_line_int_rec.header_attribute8,
      p_header_attribute9        => p_line_int_rec.header_attribute9,
      p_header_attribute10       => p_line_int_rec.header_attribute10,
      p_header_attribute11       => p_line_int_rec.header_attribute11,
      p_header_attribute12       => p_line_int_rec.header_attribute12,
      p_header_attribute13       => p_line_int_rec.header_attribute13,
      p_header_attribute14       => p_line_int_rec.header_attribute14,
      p_header_attribute15       => p_line_int_rec.header_attribute15,
      p_attribute_category       => NULL,
      p_attribute1               => NULL,
      p_attribute2               => NULL,
      p_attribute3               => NULL,
      p_attribute4               => NULL,
      p_attribute5               => NULL,
      p_attribute6               => NULL,
      p_attribute7               => NULL,
      p_attribute8               => NULL,
      p_attribute9               => NULL,
      p_attribute10              => NULL,
      p_attribute11              => NULL,
      p_attribute12              => NULL,
      p_attribute13              => NULL,
      p_attribute14              => NULL,
      p_attribute15              => NULL,
      px_org_id                  => l_org_id);

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': End');
   END IF;

   --Standard call to get message count AND IF count=1, get the message
   FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Insert_Resale_Header;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Insert_Resale_Header;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Insert_Resale_Header;
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
END Insert_Resale_Header;

---------------------------------------------------------------------
-- PROCEDURE
--    Insert_Resale_Line
--
-- PURPOSE
--    This procedure inserts a record IN resale line table
--
-- PARAMETERS
--    p_line_int_rec  IN g_interface_rec_csr%rowtype,
--    x_return_status  OUT VARCHAR2
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE Insert_Resale_Line(
    p_api_version            IN  NUMBER
   ,p_init_msg_LIST          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_line_int_rec           IN g_interface_rec_csr%rowtype
   ,p_header_id              IN NUMBER
   ,x_line_id                OUT NOCOPY NUMBER
   ,x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)

IS
l_api_name          CONSTANT VARCHAR2(30) := 'Insert_resale_line';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     VARCHAR2(30);
l_msg_data          VARCHAR2(2000);
l_msg_count         NUMBER;

l_line_id NUMBER;
l_obj_ver_num NUMBER := 1;
l_org_id NUMBER;
l_map_id NUMBER;
BEGIN
   -- Standard BEGIN of API savepoint
   SAVEPOINT  Insert_Resale_Line;
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
      OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;

   --Initialize message LIST IF p_init_msg_LIST IS TRUE.
   IF FND_API.To_Boolean (p_init_msg_LIST) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN g_line_id_csr;
   FETCH g_line_id_csr INTO l_line_id;
   CLOSE g_line_id_csr;
   x_line_id := l_line_id;
   l_org_id := p_line_int_rec.org_id; -- bug # 5997978 fixed
   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message('before line INSERT: header id' || p_header_id);
      OZF_UTILITY_PVT.debug_message('before line INSERT:' || l_line_id);
   END IF;

   OZF_RESALE_LINES_PKG.Insert_Row(
      p_resale_line_id              => l_line_id ,
      p_resale_header_id            => p_header_id ,
      p_resale_transfer_type        => p_line_int_rec.resale_transfer_type ,
      px_object_version_number      => l_obj_ver_num,
      p_last_update_date            => SYSdate,
      p_last_updated_by             => NVL(FND_GLOBAL.user_id,-1),
      p_creation_date               => SYSdate,
      p_request_id                  => FND_GLOBAL.CONC_REQUEST_ID,
      p_created_by                  => NVL(FND_GLOBAL.user_id,-1),
      p_last_update_login           => NVL(FND_GLOBAL.conc_login_id,-1),
      p_program_application_id      => FND_GLOBAL.PROG_APPL_ID,
      p_program_update_date         => SYSdate,
      p_program_id                  => FND_GLOBAL.CONC_PROGRAM_ID,
      p_created_from                => p_line_int_rec.created_from,
      p_status_code                 => G_BATCH_ADJ_PROCESSED ,
      p_product_trans_movement_type => p_line_int_rec.product_transfer_movement_type ,
      p_product_transfer_date       => p_line_int_rec.product_transfer_date,
      p_end_cust_party_id           => p_line_int_rec.end_cust_party_id,
      p_end_cust_site_use_id        => p_line_int_rec.end_cust_site_use_id,
      p_end_cust_site_use_code      => p_line_int_rec.end_cust_site_use_code,
      p_end_cust_party_site_id      => p_line_int_rec.end_cust_party_site_id ,
      p_end_cust_party_name         => p_line_int_rec.end_cust_party_name ,
      p_end_cust_location           => p_line_int_rec.end_cust_location ,
      p_end_cust_address            => p_line_int_rec.end_cust_address ,
      p_end_cust_city               => p_line_int_rec.end_cust_city ,
      p_end_cust_state              => p_line_int_rec.end_cust_state ,
      p_end_cust_postal_code        => p_line_int_rec.end_cust_postal_code ,
      p_end_cust_country            => p_line_int_rec.end_cust_country ,
      p_end_cust_contact_party_id   => p_line_int_rec.end_cust_contact_party_id ,
      p_end_cust_contact_name       => p_line_int_rec.end_cust_contact_name ,
      p_end_cust_email              => p_line_int_rec.end_cust_email ,
      p_end_cust_phone              => p_line_int_rec.end_cust_phone ,
      p_end_cust_fax                => p_line_int_rec.end_cust_fax ,
      p_bill_to_cust_account_id     => p_line_int_rec.bill_to_cust_account_id,
      p_bill_to_site_use_id         => p_line_int_rec.bill_to_site_use_id  ,
      p_bill_to_party_name          => p_line_int_rec.bill_to_party_name ,
      p_bill_to_party_id            => p_line_int_rec.bill_to_party_id ,
      p_bill_to_party_site_id       => p_line_int_rec.bill_to_party_site_id ,
      p_bill_to_duns_number         => p_line_int_rec.bill_to_duns_number ,
      p_bill_to_location            => p_line_int_rec.bill_to_location ,
      p_bill_to_address             => p_line_int_rec.bill_to_address ,
      p_bill_to_city                => p_line_int_rec.bill_to_city ,
      p_bill_to_state               => p_line_int_rec.bill_to_state ,
      p_bill_to_postal_code         => p_line_int_rec.bill_to_postal_code  ,
      p_bill_to_country             => p_line_int_rec.bill_to_country ,
      p_bill_to_contact_party_id    => p_line_int_rec.bill_to_contact_party_id ,
      p_bill_to_contact_name        => p_line_int_rec.bill_to_contact_name ,
      p_bill_to_email               => p_line_int_rec.bill_to_email ,
      p_bill_to_phone               => p_line_int_rec.bill_to_phone ,
      p_bill_to_fax                 => p_line_int_rec.bill_to_fax ,
      p_ship_to_cust_account_id     => p_line_int_rec.ship_to_cust_account_id  ,
      p_ship_to_site_use_id         => p_line_int_rec.ship_to_site_use_id ,
      p_ship_to_party_name          => p_line_int_rec.ship_to_party_name ,
      p_ship_to_party_id            => p_line_int_rec.ship_to_party_id ,
      p_ship_to_party_site_id       => p_line_int_rec.ship_to_party_site_id ,
      p_ship_to_duns_number         => p_line_int_rec.ship_to_duns_number ,
      p_ship_to_location            => p_line_int_rec.ship_to_location ,
      p_ship_to_address             => p_line_int_rec.ship_to_address,
      p_ship_to_city                => p_line_int_rec.ship_to_city ,
      p_ship_to_state               => p_line_int_rec.ship_to_state ,
      p_ship_to_postal_code         => p_line_int_rec.ship_to_postal_code ,
      p_ship_to_country             => p_line_int_rec.ship_to_country ,
      p_ship_to_contact_party_id    => p_line_int_rec.ship_to_contact_party_id ,
      p_ship_to_contact_name        => p_line_int_rec.ship_to_contact_name ,
      p_ship_to_email               => p_line_int_rec.ship_to_email ,
      p_ship_to_phone               => p_line_int_rec.ship_to_phone ,
      p_ship_to_fax                 => p_line_int_rec.ship_to_fax ,
      p_ship_from_cust_account_id   => p_line_int_rec.ship_from_cust_account_id  ,
      p_ship_from_site_id           => p_line_int_rec.ship_from_site_id,
      p_ship_from_party_name        => p_line_int_rec.ship_from_party_name,
      p_ship_from_location          => p_line_int_rec.ship_from_location ,
      p_ship_from_address           => p_line_int_rec.ship_from_address ,
      p_ship_from_city              => p_line_int_rec.ship_from_city ,
      p_ship_from_state             => p_line_int_rec.ship_from_state ,
      p_ship_from_postal_code       => p_line_int_rec.ship_from_postal_code ,
      p_ship_from_country           => p_line_int_rec.ship_from_country,
      p_ship_from_contact_party_id  => p_line_int_rec.ship_from_contact_party_id ,
      p_ship_from_contact_name      => p_line_int_rec.ship_from_contact_name ,
      p_ship_from_email             => p_line_int_rec.ship_from_email ,
      p_ship_from_fax               => p_line_int_rec.ship_from_fax ,
      p_ship_from_phone             => p_line_int_rec.ship_from_phone ,
      p_sold_from_cust_account_id   => p_line_int_rec.sold_from_cust_account_id ,
      p_sold_from_site_id           => p_line_int_rec.sold_from_site_id ,
      p_sold_from_party_name        => p_line_int_rec.sold_from_party_name,
      p_sold_from_location          => p_line_int_rec.sold_from_location ,
      p_sold_from_address           => p_line_int_rec.sold_from_address ,
      p_sold_from_city              => p_line_int_rec.sold_from_city ,
      p_sold_from_state             => p_line_int_rec.sold_from_state ,
      p_sold_from_postal_code       => p_line_int_rec.sold_from_postal_code ,
      p_sold_from_country           => p_line_int_rec.sold_from_country,
      p_sold_from_contact_party_id  => p_line_int_rec.sold_from_contact_party_id ,
      p_sold_from_contact_name      => p_line_int_rec.sold_from_contact_name ,
      p_sold_from_email             => p_line_int_rec.sold_from_email,
      p_sold_from_phone             => p_line_int_rec.sold_from_phone,
      p_sold_from_fax               => p_line_int_rec.sold_from_fax,
      p_price_LIST_id               => p_line_int_rec.price_LIST_id ,
      p_price_LIST_name             => p_line_int_rec.price_LIST_name ,
      p_invoice_number              => p_line_int_rec.invoice_number ,
      p_date_invoiced               => p_line_int_rec.date_invoiced,
      p_po_number                   => p_line_int_rec.po_number ,
      p_po_release_number           => p_line_int_rec.po_release_number ,
      p_po_type                     => p_line_int_rec.po_type ,
      p_order_number                => p_line_int_rec.order_number ,
      p_date_ordered                => p_line_int_rec.date_ordered,
      p_date_shipped                => p_line_int_rec.date_shipped,
      p_purchase_uom_code           => p_line_int_rec.purchase_uom_code ,
      p_quantity                    => p_line_int_rec.quantity ,
      p_uom_code                    => p_line_int_rec.uom_code ,
      p_currency_code               => p_line_int_rec.currency_code ,
      p_exchange_rate               => p_line_int_rec.exchange_rate ,
      p_exchange_rate_type          => p_line_int_rec.exchange_rate_type,
      p_exchange_rate_date          => p_line_int_rec.exchange_rate_date,
      p_selling_price               => p_line_int_rec.selling_price ,
      p_acctd_selling_price         => p_line_int_rec.acctd_selling_price ,
      p_purchase_price              => p_line_int_rec.purchase_price ,
      p_acctd_purchase_price        => p_line_int_rec.acctd_purchase_price ,
      p_tracing_flag                => p_line_int_rec.tracing_flag ,
      p_orig_system_quantity        => p_line_int_rec. orig_system_quantity,
      p_orig_system_uom             => p_line_int_rec.orig_system_uom ,
      p_orig_system_currency_code   => p_line_int_rec.orig_system_currency_code,
      p_orig_system_selling_price   => p_line_int_rec.orig_system_selling_price ,
      p_orig_system_line_reference  => p_line_int_rec.orig_system_line_reference ,
      p_orig_system_reference       => p_line_int_rec.orig_system_reference ,
      p_orig_system_purchase_uom    => p_line_int_rec.orig_system_purchase_uom,
      p_orig_system_purchase_curr   => p_line_int_rec.orig_system_purchase_curr,
      p_orig_system_purchase_price  => p_line_int_rec.orig_system_purchase_price,
      p_orig_system_purchase_quant  => p_line_int_rec.orig_system_purchase_quantity,
      p_orig_system_item_number     => p_line_int_rec.orig_system_item_number,
      p_product_category_id         => p_line_int_rec.product_category_id ,
      p_category_name               => p_line_int_rec.category_name  ,
      p_inventory_item_segment1     => p_line_int_rec.inventory_item_segment1 ,
      p_inventory_item_segment2     => p_line_int_rec.inventory_item_segment2 ,
      p_inventory_item_segment3     => p_line_int_rec.inventory_item_segment3 ,
      p_inventory_item_segment4     => p_line_int_rec.inventory_item_segment4 ,
      p_inventory_item_segment5     => p_line_int_rec.inventory_item_segment5 ,
      p_inventory_item_segment6     => p_line_int_rec.inventory_item_segment6 ,
      p_inventory_item_segment7     => p_line_int_rec.inventory_item_segment7 ,
      p_inventory_item_segment8     => p_line_int_rec.inventory_item_segment8 ,
      p_inventory_item_segment9     => p_line_int_rec.inventory_item_segment9,
      p_inventory_item_segment10    => p_line_int_rec.inventory_item_segment10,
      p_inventory_item_segment11    => p_line_int_rec.inventory_item_segment11,
      p_inventory_item_segment12    => p_line_int_rec.inventory_item_segment12,
      p_inventory_item_segment13    => p_line_int_rec.inventory_item_segment13,
      p_inventory_item_segment14    => p_line_int_rec.inventory_item_segment14,
      p_inventory_item_segment15    => p_line_int_rec.inventory_item_segment15,
      p_inventory_item_segment16    => p_line_int_rec.inventory_item_segment16,
      p_inventory_item_segment17    => p_line_int_rec.inventory_item_segment17,
      p_inventory_item_segment18    => p_line_int_rec.inventory_item_segment18,
      p_inventory_item_segment19    => p_line_int_rec.inventory_item_segment19,
      p_inventory_item_segment20    => p_line_int_rec.inventory_item_segment20 ,
      p_inventory_item_id           => p_line_int_rec.inventory_item_id ,
      p_item_description            => p_line_int_rec.item_description ,
      p_upc_code                    => p_line_int_rec.upc_code ,
      p_item_number                 => p_line_int_rec.item_number ,
      p_direct_customer_flag        => p_line_int_rec.direct_customer_flag ,
      p_attribute_category          => NULL,
      p_attribute1                  => NULL,
      p_attribute2                  => NULL,
      p_attribute3                  => NULL,
      p_attribute4                  => NULL,
      p_attribute5                  => NULL,
      p_attribute6                  => NULL,
      p_attribute7                  => NULL,
      p_attribute8                  => NULL,
      p_attribute9                  => NULL,
      p_attribute10                 => NULL,
      p_attribute11                 => NULL,
      p_attribute12                 => NULL,
      p_attribute13                 => NULL,
      p_attribute14                 => NULL,
      p_attribute15                 => NULL,
      p_line_attribute_category     => p_line_int_rec.line_attribute_category,
      p_line_attribute1             => p_line_int_rec.line_attribute1 ,
      p_line_attribute2             => p_line_int_rec.line_attribute2 ,
      p_line_attribute3             => p_line_int_rec.line_attribute3,
      p_line_attribute4             => p_line_int_rec.line_attribute4 ,
      p_line_attribute5             => p_line_int_rec.line_attribute5 ,
      p_line_attribute6             => p_line_int_rec.line_attribute6 ,
      p_line_attribute7             => p_line_int_rec.line_attribute7,
      p_line_attribute8             => p_line_int_rec.line_attribute8,
      p_line_attribute9             => p_line_int_rec.line_attribute9,
      p_line_attribute10            => p_line_int_rec.line_attribute10,
      p_line_attribute11            => p_line_int_rec.line_attribute11,
      p_line_attribute12            => p_line_int_rec.line_attribute12,
      p_line_attribute13            => p_line_int_rec.line_attribute13,
      p_line_attribute14            => p_line_int_rec.line_attribute14,
      p_line_attribute15            => p_line_int_rec.line_attribute15 ,
      px_org_id                     => l_org_id );


   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('line INSERT successful id:' || l_line_id);
      OZF_UTILITY_PVT.debug_message(l_full_name||': End');
   END IF;

   --Standard call to get message count AND IF count=1, get the message
   FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data
   );
   x_return_status := l_return_status;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Insert_Resale_Line;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Insert_Resale_Line;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Insert_Resale_Line;
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
END Insert_Resale_Line;

---------------------------------------------------------------------
-- PROCEDURE
--    Insert_Resale_Line_Mapping
--
-- PURPOSE
--    This procedure inserts a record IN resale_batch_line_mapping  table
--
-- PARAMETERS
--    p_line_int_rec  IN g_interface_rec_csr%rowtype,
--    x_return_status  OUT VARCHAR2
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE Insert_Resale_Line_Mapping(
    p_api_version            IN  NUMBER
   ,p_init_msg_LIST          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN  NUMBER
   ,p_line_id                IN  NUMBER
   ,x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_data               OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Insert_Resale_Line_Mapping';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     VARCHAR2(30);
l_msg_data          VARCHAR2(2000);
l_msg_count         NUMBER;

l_obj_ver_num NUMBER := 1;
l_org_id NUMBER;
l_batch_org_id NUMBER; -- bug # 5997978 fixed
l_map_id NUMBER;
BEGIN
   -- Standard BEGIN of API savepoint
   SAVEPOINT  Insert_Resale_Line_Mapping;
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
      OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;

   --Initialize message LIST IF p_init_msg_LIST IS TRUE.
   IF FND_API.To_Boolean (p_init_msg_LIST) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   OPEN g_map_id_csr;
   FETCH g_map_id_csr INTO l_map_id;
   CLOSE g_map_id_csr;

   -- Start: bug # 5997978 fixed
   OPEN g_resale_batch_org_id_csr(p_resale_batch_id);
   FETCH g_resale_batch_org_id_csr INTO l_batch_org_id;
   CLOSE g_resale_batch_org_id_csr;
   l_org_id := MO_GLOBAL.get_valid_org(l_batch_org_id);
   IF (l_batch_org_id IS NULL OR l_org_id IS NULL) THEN
         OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_ORG_ID_NOTFOUND');
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- End: bug # 5997978 fixed

   -- INSERT INTO mapping table
   OZF_RESALE_BATCH_LINE_MAPS_PKG.Insert_Row(
      px_resale_batch_line_map_id   => l_map_id,
      p_resale_batch_id             => p_resale_batch_id,
      p_resale_line_id              => p_line_id,
      px_object_version_number      => l_obj_ver_num,
      p_last_update_date            => SYSdate,
      p_last_updated_by             => NVL(FND_GLOBAL.user_id,-1),
      p_creation_date               => SYSdate,
      p_request_id                  => FND_GLOBAL.CONC_REQUEST_ID,
      p_created_by                  => NVL(FND_GLOBAL.user_id,-1),
      p_last_update_login           => NVL(FND_GLOBAL.conc_login_id,-1),
      p_program_application_id      => FND_GLOBAL.PROG_APPL_ID,
      p_program_update_date         => SYSdate,
      p_program_id                  => FND_GLOBAL.CONC_PROGRAM_ID,
      p_created_from                => NULL,
      p_attribute_category          => NULL,
      p_attribute1                  => NULL,
      p_attribute2                  => NULL,
      p_attribute3                  => NULL,
      p_attribute4                  => NULL,
      p_attribute5                  => NULL,
      p_attribute6                  => NULL,
      p_attribute7                  => NULL,
      p_attribute8                  => NULL,
      p_attribute9                  => NULL,
      p_attribute10                 => NULL,
      p_attribute11                 => NULL,
      p_attribute12                 => NULL,
      p_attribute13                 => NULL,
      p_attribute14                 => NULL,
      p_attribute15                 => NULL,
      px_org_id                     => l_org_id);

    -- Debug Message
    IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': End');
    END IF;

    --Standard call to get message count AND IF count=1, get the message
    FND_MSG_PUB.Count_And_Get (
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data
    );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Insert_Resale_Line_Mapping;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Insert_Resale_Line_Mapping;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Insert_Resale_Line_Mapping;
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
END Insert_Resale_Line_Mapping;

---------------------------------------------------------------------
-- PROCEDURE
--    Delete_Log
--
-- PURPOSE
--    This procedure delets the log for all open lines of batch
--
-- PARAMETERS
--    p_resale_batch_id  IN number
--    x_return_status  out VARCHAR2
--
-- NOTES
-----------------------------------------------------------------------
PROCEDURE Delete_Log(
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN  NUMBER
   ,x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_data               OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Delete_Log';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     VARCHAR2(30);
l_msg_data          VARCHAR2(2000);
l_msg_count         NUMBER;

BEGIN
   -- Standard BEGIN of API savepoint
   SAVEPOINT  Delete_Log;
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
      OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;

   --Initialize message LIST IF p_init_msg_LIST IS TRUE.
   IF FND_API.To_Boolean (p_init_msg_LIST) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- delete batch logs
   DELETE FROM OZF_RESALE_LOGS
   WHERE resale_id = p_resale_batch_id
   AND   resale_id_type = G_ID_TYPE_BATCH;

   -- delete interface logs
   DELETE FROM OZF_RESALE_LOGS a
   WHERE exists (
      SELECT 1
      FROM OZF_RESALE_LINES_INT b
      WHERE b.resale_batch_id = p_resale_batch_id
      AND   a.resale_id = b.resale_line_int_id
      AND   a.resale_id_type = G_ID_TYPE_IFACE
      );

    -- Debug Message
    IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': End');
    END IF;

    --Standard call to get message count AND IF count=1, get the message
    FND_MSG_PUB.Count_And_Get (
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data
    );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO  Delete_Log;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO  Delete_Log;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count AND IF count=1, get the message
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO  Delete_Log;
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
END  Delete_Log;


---------------------------------------------------------------------
-- PROCEDURE
--    Create_Party
--
-- PURPOSE
--    This procedure creates party, party site, party site use and relationship
--
-- PARAMETERS
--    px_party_rec  IN OUT party_rec_type
--    x_return_status  out VARCHAR2
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE Create_Party
(  p_api_version            IN  NUMBER
  ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
  ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
  ,px_party_rec             IN OUT NOCOPY party_rec_type
  ,x_return_status          OUT NOCOPY VARCHAR2
  ,x_msg_count              OUT NOCOPY NUMBER
  ,x_msg_data               OUT NOCOPY VARCHAR2
)
IS

l_api_name              CONSTANT VARCHAR2(30) := 'Create_Party';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

l_organization_rec      HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;
l_location_rec          HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
l_party_site_rec        HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
l_party_site_use_rec    HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE;
l_relationship_rec      HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;

l_party_id              NUMBER;
l_party_number          VARCHAR2(2000);
l_party_no              VARCHAR2(2000);
l_profile_id            NUMBER;
l_location_id           NUMBER;
l_party_site_id         NUMBER;
l_party_site_number     VARCHAR2(2000);
l_party_site_use_id     NUMBER;
l_relationship_id       NUMBER;

BEGIN
   -- Standard BEGIN of API savepoint
   SAVEPOINT  Party_Create;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
        l_api_version,
        p_api_version,
        l_api_name,
        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Initialize message LIST IF p_init_msg_LIST IS TRUE.
   IF FND_API.To_Boolean (p_init_msg_LIST) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   --  Create  Organization
   IF  px_party_rec.name IS NOT NULL THEN
       IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('NAME '|| px_party_rec.name);
       END IF;
      l_organization_rec.organization_name     := px_party_rec.name;
      -- Bug 4630628 (+)
      --l_organization_rec.created_by_module     := 'TCA_V2_API';
      l_organization_rec.created_by_module     := 'OZF_RESALE';
      -- Bug 4630628 (-)
      l_organization_rec.party_rec.status      := 'A';
      l_organization_rec.application_id        :=  682;

      HZ_PARTY_V2PUB.create_organization(
         p_init_msg_list     => FND_API.G_FALSE,
         p_organization_rec  => l_organization_rec,
         x_return_status     => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data          => x_msg_data,
         x_party_id          => px_party_rec.party_id,
         x_party_number      => l_party_number,
         x_profile_id        => l_profile_id);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('Party Id '||px_party_rec.party_id);
      END IF;
   END IF;

   --  Create Location
   IF px_party_rec.address IS NOT NULL THEN

      l_location_rec.country               := px_party_rec.country;
      l_location_rec.address1              := px_party_rec.address;
      l_location_rec.city                  := px_party_rec.city;
      l_location_rec.postal_code           := px_party_rec.postal_code;
      l_location_rec.state                 := px_party_rec.state;
      -- Bug 4630628 (+)
      --l_location_rec.created_by_module     := 'TCA_V2_API';
      l_location_rec.created_by_module     := 'OZF_RESALE';
      -- Bug 4630628 (-)

      HZ_LOCATION_V2PUB.create_location(
         p_init_msg_list    => FND_API.G_FALSE,
         p_location_rec     => l_location_rec,
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data,
         x_location_id      => l_location_id);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('Location ID '|| l_location_id);
      END IF;
   END IF;

   --  Create Party Site
   IF  px_party_rec.party_id IS NOT NULL AND
       l_location_id IS NOT NULL THEN

      l_party_site_rec.party_id                 := px_party_rec.party_id;
      l_party_site_rec.location_id              := l_location_id;
      l_party_site_rec.identifying_address_flag := 'Y';
      l_party_site_rec.status                   := 'A';
      -- Bug 4630628 (+)
      --l_party_site_rec.created_by_module        := 'TCA_V2_API';
      l_party_site_rec.created_by_module        := 'OZF_RESALE';
      -- Bug 4630628 (-)

      HZ_PARTY_SITE_V2PUB.create_party_site (
         p_init_msg_list    => FND_API.G_FALSE,
         p_party_site_rec   => l_party_site_rec,
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data,
         x_party_site_id    => px_party_rec.party_site_id,
         x_party_site_number=> l_party_site_number);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('Party Site ID '|| px_party_rec.party_site_id);
      END IF;
   END IF;

   --  Create Party Site Use
   IF px_party_rec.party_site_id IS NOT NULL THEN

      l_party_site_use_rec.party_site_id           := px_party_rec.party_site_id;
      -- Bug 4630628 (+)
      --l_party_site_use_rec.created_by_module       := 'TCA_V2_API';
      l_party_site_use_rec.created_by_module       := 'OZF_RESALE';
      -- Bug 4630628 (-)
      l_party_site_use_rec.application_id          := 682;


      IF (px_party_rec.site_use_code is null OR px_party_rec.site_use_code = FND_API.G_MISS_CHAR) THEN
         l_party_site_use_rec.site_use_type := 'BILL_TO';
      ELSE
         l_party_site_use_rec.site_use_type := px_party_rec.site_use_code;  -- 'BILL_TO';
      END IF;

      HZ_PARTY_SITE_V2PUB.create_party_site_use(
         p_init_msg_list      => FND_API.G_FALSE,
         p_party_site_use_rec => l_party_site_use_rec,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data,
         x_party_site_use_id  => px_party_rec.party_site_use_id
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('Party Site Use ID '|| px_party_rec.party_site_use_id);
      END IF;
   END IF;

   -- Create Relationship
   IF px_party_rec.party_id IS NOT NULL AND
      px_party_rec.partner_party_id IS NOT NULL THEN

      l_relationship_rec.subject_id                :=  px_party_rec.party_id;
      l_relationship_rec.subject_type              := 'ORGANIZATION';
      l_relationship_rec.subject_table_name        := 'HZ_PARTIES';
      l_relationship_rec.object_id                 :=  px_party_rec.partner_party_id;
      l_relationship_rec.object_type               := 'ORGANIZATION';
      l_relationship_rec.object_table_name         := 'HZ_PARTIES';
      l_relationship_rec.relationship_type         := 'CUSTOMER/SELLER';
      l_relationship_rec.start_date                := sysdate;
      l_relationship_rec.relationship_code         := 'CUSTOMER_OF';
      -- Bug 4630628 (+)
      --l_relationship_rec.created_by_module         := 'TCA_V2_API';
      l_relationship_rec.created_by_module         := 'OZF_RESALE';
      -- Bug 4630628 (-)
      l_relationship_rec.application_id            := 682;
      l_relationship_rec.status                    := 'A';


      HZ_RELATIONSHIP_V2PUB.create_relationship(
         p_init_msg_list              => FND_API.G_FALSE,
         p_relationship_rec           => l_relationship_rec,
         x_relationship_id            => l_relationship_id,
         x_party_id                   => l_party_id,
         x_party_number               => l_party_no,
         x_return_status              => x_return_status,
         x_msg_count                  => x_msg_count,
         x_msg_data                   => x_msg_data,
         p_create_org_contact         => 'Y'
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('Relationship ID '|| l_relationship_id);
      END IF;
   END IF;



   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': End');
   END IF;
   --Standard call to get message count AND IF count=1, get the message
   FND_MSG_PUB.Count_And_Get (
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      OZF_UTILITY_PVT.debug_message('SQLERRM '|| sqlerrm);

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END  Create_Party;


---------------------------------------------------------------------
-- PROCEDURE
--    Build_Global_Resale_Rec
--
-- PURPOSE
--    Build Global Resale Record for Pricing Simulation
--
-- PARAMETERS
--    p_caller_type          IN VARCHAR2
--    p_resale_line_int_rec  IN OZF_RESALE_COMMON_PVT.g_interface_rec_csr%ROWTYPE
--    p_resale_line_rec      IN OZF_RESALE_LINES%ROWTYPE
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE Build_Global_Resale_Rec
(  p_api_version         IN  NUMBER
  ,p_init_msg_list       IN  VARCHAR2
  ,p_commit              IN  VARCHAR2
  ,p_validation_level    IN  NUMBER
  ,p_caller_type         IN  VARCHAR2
  ,p_line_index          IN  NUMBER
  ,p_resale_line_int_rec IN  OZF_RESALE_COMMON_PVT.g_interface_rec_csr%ROWTYPE
  ,p_resale_header_rec   IN  OZF_RESALE_HEADERS%ROWTYPE
  ,p_resale_line_rec     IN  OZF_RESALE_LINES%ROWTYPE
  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Build_Global_Resale_Rec';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_qp_context_request_id      NUMBER;

BEGIN
   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message(l_full_name||': start');
   END IF;

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

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_caller_type = 'IFACE' AND
      p_resale_line_int_rec.resale_line_int_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_RESALE_INT_RECD_NULL');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF p_caller_type = 'RESALE' AND
      p_resale_line_rec.resale_line_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_RESALE_RECD_NULL');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   l_qp_context_request_id := QP_Price_Request_Context.Get_Request_Id;

   IF p_caller_type = 'IFACE' THEN
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.qp_context_request_id          := l_qp_context_request_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_index                     := p_line_index;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.resale_table_type              := 'IFACE';
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_id                        := p_resale_line_int_rec.resale_line_int_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.resale_transfer_type           := p_resale_line_int_rec.resale_transfer_type;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.product_transfer_movement_type := p_resale_line_int_rec.product_transfer_movement_type;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.product_transfer_date          := p_resale_line_int_rec.product_transfer_date;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.tracing_flag                   := p_resale_line_int_rec.tracing_flag;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.sold_from_cust_account_id      := p_resale_line_int_rec.sold_from_cust_account_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.sold_from_site_id              := p_resale_line_int_rec.sold_from_site_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.sold_from_contact_party_id     := p_resale_line_int_rec.sold_from_contact_party_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.ship_from_cust_account_id      := p_resale_line_int_rec.ship_from_cust_account_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.ship_from_site_id              := p_resale_line_int_rec.ship_from_site_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.ship_from_contact_party_id     := p_resale_line_int_rec.ship_from_contact_party_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.bill_to_party_id               := p_resale_line_int_rec.bill_to_party_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.bill_to_party_site_id          := p_resale_line_int_rec.bill_to_party_site_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.bill_to_contact_party_id       := p_resale_line_int_rec.bill_to_contact_party_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.ship_to_party_id               := p_resale_line_int_rec.ship_to_party_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.ship_to_party_site_id          := p_resale_line_int_rec.ship_to_party_site_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.ship_to_contact_party_id       := p_resale_line_int_rec.ship_to_contact_party_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.end_cust_party_id              := p_resale_line_int_rec.end_cust_party_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.end_cust_site_use_id           := p_resale_line_int_rec.end_cust_site_use_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.end_cust_site_use_code         := p_resale_line_int_rec.end_cust_site_use_code;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.end_cust_party_site_id         := p_resale_line_int_rec.end_cust_party_site_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.end_cust_contact_party_id      := p_resale_line_int_rec.end_cust_contact_party_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.data_source_code               := p_resale_line_int_rec.data_source_code;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute_category      := p_resale_line_int_rec.header_attribute_category;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute1              := p_resale_line_int_rec.header_attribute1;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute2              := p_resale_line_int_rec.header_attribute2;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute3              := p_resale_line_int_rec.header_attribute3;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute4              := p_resale_line_int_rec.header_attribute4;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute5              := p_resale_line_int_rec.header_attribute5;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute6              := p_resale_line_int_rec.header_attribute6;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute7              := p_resale_line_int_rec.header_attribute7;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute8              := p_resale_line_int_rec.header_attribute8;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute9              := p_resale_line_int_rec.header_attribute9;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute10             := p_resale_line_int_rec.header_attribute10;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute11             := p_resale_line_int_rec.header_attribute11;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute12             := p_resale_line_int_rec.header_attribute12;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute13             := p_resale_line_int_rec.header_attribute13;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute14             := p_resale_line_int_rec.header_attribute14;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute15             := p_resale_line_int_rec.header_attribute15;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute_category        := p_resale_line_int_rec.line_attribute_category;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute1                := p_resale_line_int_rec.line_attribute1;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute2                := p_resale_line_int_rec.line_attribute2;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute3                := p_resale_line_int_rec.line_attribute3;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute4                := p_resale_line_int_rec.line_attribute4;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute5                := p_resale_line_int_rec.line_attribute5;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute6                := p_resale_line_int_rec.line_attribute6;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute7                := p_resale_line_int_rec.line_attribute7;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute8                := p_resale_line_int_rec.line_attribute8;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute9                := p_resale_line_int_rec.line_attribute9;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute10               := p_resale_line_int_rec.line_attribute10;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute11               := p_resale_line_int_rec.line_attribute11;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute12               := p_resale_line_int_rec.line_attribute12;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute13               := p_resale_line_int_rec.line_attribute13;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute14               := p_resale_line_int_rec.line_attribute14;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute15               := p_resale_line_int_rec.line_attribute15;

   ELSIF p_caller_type = 'RESALE' THEN
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.qp_context_request_id          := l_qp_context_request_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_index                     := p_line_index;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.resale_table_type              := 'RESALE';
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_id                        := p_resale_line_rec.resale_line_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.resale_transfer_type           := p_resale_line_rec.resale_transfer_type;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.product_transfer_movement_type := p_resale_line_rec.product_transfer_movement_type;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.product_transfer_date          := p_resale_line_rec.product_transfer_date;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.tracing_flag                   := p_resale_line_rec.tracing_flag;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.sold_from_cust_account_id      := p_resale_line_rec.sold_from_cust_account_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.sold_from_site_id              := p_resale_line_rec.sold_from_site_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.sold_from_contact_party_id     := p_resale_line_rec.sold_from_contact_party_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.ship_from_cust_account_id      := p_resale_line_rec.ship_from_cust_account_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.ship_from_site_id              := p_resale_line_rec.ship_from_site_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.ship_from_contact_party_id     := p_resale_line_rec.ship_from_contact_party_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.bill_to_party_id               := p_resale_line_rec.bill_to_party_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.bill_to_party_site_id          := p_resale_line_rec.bill_to_party_site_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.bill_to_contact_party_id       := p_resale_line_rec.bill_to_contact_party_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.ship_to_party_id               := p_resale_line_rec.ship_to_party_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.ship_to_party_site_id          := p_resale_line_rec.ship_to_party_site_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.ship_to_contact_party_id       := p_resale_line_rec.ship_to_contact_party_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.end_cust_party_id              := p_resale_line_rec.end_cust_party_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.end_cust_site_use_id           := p_resale_line_rec.end_cust_site_use_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.end_cust_site_use_code         := p_resale_line_rec.end_cust_site_use_code;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.end_cust_party_site_id         := p_resale_line_rec.end_cust_party_site_id;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.end_cust_contact_party_id      := p_resale_line_rec.end_cust_contact_party_id;
      --OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.data_source_code               := ?
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute_category      := p_resale_header_rec.header_attribute_category;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute1              := p_resale_header_rec.header_attribute1;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute2              := p_resale_header_rec.header_attribute2;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute3              := p_resale_header_rec.header_attribute3;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute4              := p_resale_header_rec.header_attribute4;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute5              := p_resale_header_rec.header_attribute5;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute6              := p_resale_header_rec.header_attribute6;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute7              := p_resale_header_rec.header_attribute7;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute8              := p_resale_header_rec.header_attribute8;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute9              := p_resale_header_rec.header_attribute9;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute10             := p_resale_header_rec.header_attribute10;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute11             := p_resale_header_rec.header_attribute11;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute12             := p_resale_header_rec.header_attribute12;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute13             := p_resale_header_rec.header_attribute13;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute14             := p_resale_header_rec.header_attribute14;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.header_attribute15             := p_resale_header_rec.header_attribute15;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute_category        := p_resale_line_rec.line_attribute_category;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute1                := p_resale_line_rec.line_attribute1;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute2                := p_resale_line_rec.line_attribute2;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute3                := p_resale_line_rec.line_attribute3;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute4                := p_resale_line_rec.line_attribute4;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute5                := p_resale_line_rec.line_attribute5;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute6                := p_resale_line_rec.line_attribute6;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute7                := p_resale_line_rec.line_attribute7;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute8                := p_resale_line_rec.line_attribute8;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute9                := p_resale_line_rec.line_attribute9;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute10               := p_resale_line_rec.line_attribute10;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute11               := p_resale_line_rec.line_attribute11;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute12               := p_resale_line_rec.line_attribute12;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute13               := p_resale_line_rec.line_attribute13;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute14               := p_resale_line_rec.line_attribute14;
      OZF_ORDER_PRICE_PVT.G_RESALE_LINE_REC.line_attribute15               := p_resale_line_rec.line_attribute15;
   END IF;


   FND_MSG_PUB.Count_And_Get (
     p_encoded => FND_API.G_FALSE,
     p_count   => x_msg_count,
     p_data    => x_msg_data
   );

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message(l_full_name||': end');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );
END Build_Global_Resale_Rec;

-------------------------------------------------------------------------------
-- PROCEDURE
--    Derive_Orig_Parties
--
-- PURPOSE
--    This procedure derives Bill_To, Ship_To and End_Cust Party information.
--
-- PARAMETERS
--    p_resale_batch_id IN NUMBER
--    p_partner_party_id IN NUMBER
--    x_return_status OUT NOCOPY VARCHAR2
--
-- NOTES
--
-- HISTORY
--    06-May-2009  ateotia   Created.
--                           Bug# 8489216 fixed.
-------------------------------------------------------------------------------
PROCEDURE Derive_Orig_Parties (
    p_api_version       IN   NUMBER
   ,p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE
   ,p_commit            IN   VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id   IN   NUMBER
   ,p_partner_party_id  IN   NUMBER
   ,x_return_status     OUT  NOCOPY   VARCHAR2
   ,x_msg_data          OUT  NOCOPY   VARCHAR2
   ,x_msg_count         OUT  NOCOPY   NUMBER
)
IS
l_api_name      CONSTANT VARCHAR2(30) := 'Derive_Orig_Parties';
l_api_version   CONSTANT NUMBER       := 1.0;
l_full_name     CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
l_return_status VARCHAR2(30);
l_msg_data      VARCHAR2(2000);
l_msg_count     NUMBER;

BEGIN
   -- Standard BEGIN of API savepoint
   SAVEPOINT  Derive_Orig_Parties;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
        l_api_version,
        p_api_version,
        l_api_name,
        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Initialize message LIST IF p_init_msg_LIST IS TRUE.
   IF FND_API.To_Boolean (p_init_msg_LIST) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   OZF_RESALE_COMMON_PVT.Derive_Bill_To_Party
   (  p_api_version      => 1.0
     ,p_init_msg_list    => FND_API.G_FALSE
     ,p_commit           => FND_API.G_FALSE
     ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
     ,p_resale_batch_id  => p_resale_batch_id
     ,p_partner_party_id => p_partner_party_id
     ,x_return_status    => l_return_status
     ,x_msg_data         => l_msg_data
     ,x_msg_count        => l_msg_count
   );
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   OZF_RESALE_COMMON_PVT.Derive_Ship_To_Party
   (  p_api_version      => 1.0
     ,p_init_msg_list    => FND_API.G_FALSE
     ,p_commit           => FND_API.G_FALSE
     ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
     ,p_resale_batch_id  => p_resale_batch_id
     ,p_partner_party_id => p_partner_party_id
     ,x_return_status    => l_return_status
     ,x_msg_data         => l_msg_data
     ,x_msg_count        => l_msg_count
   );
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   OZF_RESALE_COMMON_PVT.Derive_End_Cust_Party
   (  p_api_version      => 1.0
     ,p_init_msg_list    => FND_API.G_FALSE
     ,p_commit           => FND_API.G_FALSE
     ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
     ,p_resale_batch_id  => p_resale_batch_id
     ,p_partner_party_id => p_partner_party_id
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
      OZF_UTILITY_PVT.debug_message(l_full_name||': End');
   END IF;

   --Standard call to get message count AND IF count=1, get the message
   FND_MSG_PUB.Count_And_Get (
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Derive_Orig_Parties;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Derive_Orig_Parties;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Derive_Orig_Parties;
      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('SQLERRM '|| sqlerrm);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Derive_Orig_Parties;

-------------------------------------------------------------------------------
-- PROCEDURE
--    Derive_Bill_To_Party
--
-- PURPOSE
--    This procedure derives Bill_To Party, Party_Site, Party_Site_Use and
--    Relationship.
--
-- PARAMETERS
--    p_resale_batch_id IN NUMBER
--    p_partner_party_id IN NUMBER
--    x_return_status OUT NOCOPY VARCHAR2
--
-- NOTES
--
--
-- HISTORY
--    06-May-2009  ateotia   Created.
--                           Bug# 8489216 fixed.
-------------------------------------------------------------------------------
PROCEDURE Derive_Bill_To_Party (
    p_api_version       IN   NUMBER
   ,p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE
   ,p_commit            IN   VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id   IN   NUMBER
   ,p_partner_party_id  IN   NUMBER
   ,x_return_status     OUT  NOCOPY   VARCHAR2
   ,x_msg_data          OUT  NOCOPY   VARCHAR2
   ,x_msg_count         OUT  NOCOPY   NUMBER
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Derive_Bill_To_Party';
l_api_version           CONSTANT NUMBER       := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
l_return_status         VARCHAR2(30);
l_msg_data              VARCHAR2(2000);
l_msg_count             NUMBER;
l_new_party_rec         OZF_RESALE_COMMON_PVT.party_rec_type;
l_orig_billto_count     NUMBER;
l_exist_billto_party_id NUMBER;

CURSOR csr_orig_billto_count (cv_resale_batch_id IN NUMBER) IS
   SELECT COUNT(DISTINCT bill_to_party_name)
   FROM ozf_resale_lines_int_all
   WHERE resale_batch_id = cv_resale_batch_id
   AND status_code = 'PROCESSED'
   AND ( duplicated_line_id IS NULL
         OR ( duplicated_line_id IS NOT NULL AND duplicated_adjustment_id = -1)
       )
   AND bill_to_party_id IS NULL
   AND bill_to_cust_account_id IS NULL
   AND bill_to_party_name IS NOT NULL;

CURSOR csr_exist_billto_party_id (cv_resale_batch_id IN NUMBER, cv_billto_party_name IN VARCHAR2) IS
   SELECT bill_to_party_id
   FROM ozf_resale_lines_int_all
   WHERE resale_batch_id = cv_resale_batch_id
   AND bill_to_party_name = cv_billto_party_name
   AND status_code = 'PROCESSED'
   AND ( duplicated_line_id IS NULL
         OR ( duplicated_line_id IS NOT NULL AND duplicated_adjustment_id = -1)
       )
   AND bill_to_party_id IS NOT NULL
   GROUP BY bill_to_party_id
   ORDER BY bill_to_party_id;

CURSOR csr_orig_billto_cust (cv_resale_batch_id IN NUMBER) IS
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
         OR ( duplicated_line_id IS NOT NULL AND duplicated_adjustment_id = -1)
       )
   AND bill_to_party_id IS NULL
   AND bill_to_cust_account_id IS NULL
   AND bill_to_party_name IS NOT NULL;

TYPE orig_billto_cust_tbl_type IS TABLE OF csr_orig_billto_cust%ROWTYPE INDEX BY BINARY_INTEGER;
l_orig_billto_cust_tbl orig_billto_cust_tbl_type;

BEGIN
   -- Standard BEGIN of API savepoint
   SAVEPOINT  Derive_Bill_To_Party;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
        l_api_version,
        p_api_version,
        l_api_name,
        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Initialize message LIST IF p_init_msg_LIST IS TRUE.
   IF FND_API.To_Boolean (p_init_msg_LIST) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   OPEN  csr_orig_billto_count (p_resale_batch_id);
   FETCH csr_orig_billto_count INTO l_orig_billto_count;
   CLOSE csr_orig_billto_count;

   OPEN  csr_orig_billto_cust(p_resale_batch_id);
   FETCH csr_orig_billto_cust BULK COLLECT INTO l_orig_billto_cust_tbl;
   CLOSE csr_orig_billto_cust;

   IF l_orig_billto_cust_tbl.COUNT > 0 THEN
      FOR i IN 1..l_orig_billto_cust_tbl.COUNT
      LOOP
         l_new_party_rec                  := NULL;
         l_exist_billto_party_id          := NULL;
         l_new_party_rec.partner_party_id := p_partner_party_id;
         l_new_party_rec.name             := l_orig_billto_cust_tbl(i).bill_to_party_name;
         l_new_party_rec.address          := l_orig_billto_cust_tbl(i).bill_to_address;
         l_new_party_rec.city             := l_orig_billto_cust_tbl(i).bill_to_city;
         l_new_party_rec.state            := l_orig_billto_cust_tbl(i).bill_to_state;
         l_new_party_rec.postal_Code      := l_orig_billto_cust_tbl(i).bill_to_postal_code;
         l_new_party_rec.country          := l_orig_billto_cust_tbl(i).bill_to_country;
         l_new_party_rec.site_Use_Code    := 'BILL_TO';

         IF (l_orig_billto_count <> l_orig_billto_cust_tbl.COUNT) THEN
            --Check whether a party with this name has already been already created.
            OPEN  csr_exist_billto_party_id (p_resale_batch_id, l_orig_billto_cust_tbl(i).bill_to_party_name);
            FETCH csr_exist_billto_party_id INTO l_exist_billto_party_id;
            CLOSE csr_exist_billto_party_id;
            IF (l_exist_billto_party_id IS NOT NULL) THEN
               --New Party and Relationship should not be created.
               --Derive the party_id from existing party.
               l_new_party_rec.party_id         := l_exist_billto_party_id;
               l_new_party_rec.name             := NULL;
               l_new_party_rec.partner_party_id := NULL;
            END IF;
         END IF;

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

         --Update bill_to_party_id, bill_to_party_site_id and bill_to_site_use_id
         UPDATE ozf_resale_lines_int_all
         SET bill_to_party_id      = l_new_party_rec.party_id,
             bill_to_party_site_id = l_new_party_rec.party_site_id,
             bill_to_site_use_id   = l_new_party_rec.party_site_use_id
         WHERE bill_to_party_id IS NULL
         AND bill_to_cust_account_id IS NULL
         AND resale_batch_id            = p_resale_batch_id
         AND bill_to_party_name         = l_orig_billto_cust_tbl(i).bill_to_party_name
         AND NVL(bill_to_address,1)     = NVL(l_orig_billto_cust_tbl(i).bill_to_address,1)
         AND NVL(bill_to_city,1)        = NVL(l_orig_billto_cust_tbl(i).bill_to_city,1)
         AND NVL(bill_to_state,1)       = NVL(l_orig_billto_cust_tbl(i).bill_to_state,1)
         AND NVL(bill_to_postal_code,1) = NVL(l_orig_billto_cust_tbl(i).bill_to_postal_code,1)
         AND NVL(bill_to_country,1)     = NVL(l_orig_billto_cust_tbl(i).bill_to_country,1);

      END LOOP;
   END IF;

 -- Debug Message
 IF OZF_DEBUG_HIGH_ON THEN
    OZF_UTILITY_PVT.debug_message(l_full_name||': End');
 END IF;

 --Standard call to get message count AND IF count=1, get the message
 FND_MSG_PUB.Count_And_Get (
    p_encoded => FND_API.G_FALSE,
    p_count => x_msg_count,
    p_data  => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Derive_Bill_To_Party;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Derive_Bill_To_Party;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Derive_Bill_To_Party;
      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('SQLERRM '|| sqlerrm);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Derive_Bill_To_Party;

-------------------------------------------------------------------------------
-- PROCEDURE
--    Derive_Ship_To_Party
--
-- PURPOSE
--    This procedure derives Ship_To Party, Party_Site, Party_Site_Use and
--    Relationship.
--
-- PARAMETERS
--    p_resale_batch_id IN NUMBER
--    p_partner_party_id IN NUMBER
--    x_return_status OUT NOCOPY VARCHAR2
--
-- NOTES
--
--
-- HISTORY
--    06-May-2009  ateotia   Created.
--                           Bug# 8489216 fixed.
-------------------------------------------------------------------------------
PROCEDURE Derive_Ship_To_Party (
    p_api_version       IN   NUMBER
   ,p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE
   ,p_commit            IN   VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id   IN   NUMBER
   ,p_partner_party_id  IN   NUMBER
   ,x_return_status     OUT  NOCOPY   VARCHAR2
   ,x_msg_data          OUT  NOCOPY   VARCHAR2
   ,x_msg_count         OUT  NOCOPY   NUMBER
)
IS
l_api_name                   CONSTANT VARCHAR2(30) := 'Derive_Ship_To_Party';
l_api_version                CONSTANT NUMBER       := 1.0;
l_full_name                  CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
l_return_status              VARCHAR2(30);
l_msg_data                   VARCHAR2(2000);
l_msg_count                  NUMBER;
l_new_party_rec              OZF_RESALE_COMMON_PVT.party_rec_type;
l_orig_shipto_count          NUMBER;
l_exist_shipto_party_id      NUMBER;
l_exist_billto_party_id      NUMBER;
l_exist_billto_party_site_id NUMBER;

CURSOR csr_orig_shipto_count (cv_resale_batch_id IN NUMBER) IS
   SELECT COUNT(DISTINCT ship_to_party_name)
   FROM ozf_resale_lines_int_all
   WHERE resale_batch_id = cv_resale_batch_id
   AND status_code = 'PROCESSED'
   AND ( duplicated_line_id IS NULL
         OR ( duplicated_line_id IS NOT NULL AND duplicated_adjustment_id = -1)
       )
   AND ship_to_party_id IS NULL
   AND ship_to_cust_account_id IS NULL
   AND ship_to_party_name IS NOT NULL;

CURSOR csr_exist_shipto_party_id (cv_resale_batch_id IN NUMBER, cv_shipto_party_name IN VARCHAR2) IS
   SELECT ship_to_party_id
   FROM ozf_resale_lines_int_all
   WHERE resale_batch_id = cv_resale_batch_id
   AND ship_to_party_name = cv_shipto_party_name
   AND status_code = 'PROCESSED'
   AND ( duplicated_line_id IS NULL
         OR ( duplicated_line_id IS NOT NULL AND duplicated_adjustment_id = -1)
       )
   AND ship_to_party_id IS NOT NULL
   GROUP BY ship_to_party_id
   ORDER BY ship_to_party_id;

CURSOR csr_exist_billto_party_id (cv_resale_batch_id IN NUMBER, cv_billto_party_name IN VARCHAR2) IS
   SELECT bill_to_party_id
   FROM ozf_resale_lines_int_all
   WHERE resale_batch_id = cv_resale_batch_id
   AND bill_to_party_name = cv_billto_party_name
   AND status_code = 'PROCESSED'
   AND ( duplicated_line_id IS NULL
         OR ( duplicated_line_id IS NOT NULL AND duplicated_adjustment_id = -1)
       )
   AND bill_to_party_id IS NOT NULL
   GROUP BY bill_to_party_id
   ORDER BY bill_to_party_id;

CURSOR csr_exist_billto_party_site_id
(
   cv_resale_batch_id IN NUMBER,
   cv_billto_party_name IN VARCHAR2,
   cv_bill_to_address IN VARCHAR2,
   cv_bill_to_city IN VARCHAR2,
   cv_bill_to_state IN VARCHAR2,
   cv_bill_to_postal_code IN VARCHAR2,
   cv_bill_to_country IN VARCHAR2
)  IS
   SELECT bill_to_party_site_id
   FROM ozf_resale_lines_int_all
   WHERE resale_batch_id = cv_resale_batch_id
   AND status_code = 'PROCESSED'
   AND ( duplicated_line_id IS NULL
         OR ( duplicated_line_id IS NOT NULL AND duplicated_adjustment_id = -1)
       )
   AND bill_to_party_id IS NOT NULL
   AND bill_to_party_site_id IS NOT NULL
   AND bill_to_party_name          = cv_billto_party_name
   AND NVL(bill_to_address,1)     = NVL(cv_bill_to_address,1)
   AND NVL(bill_to_city,1)        = NVL(cv_bill_to_city,1)
   AND NVL(bill_to_state,1)       = NVL(cv_bill_to_state,1)
   AND NVL(bill_to_postal_code,1) = NVL(cv_bill_to_postal_code,1)
   AND NVL(bill_to_country,1)     = NVL(cv_bill_to_country,1)
   GROUP BY bill_to_party_site_id
   ORDER BY bill_to_party_site_id;

CURSOR csr_orig_shipto_cust (cv_resale_batch_id IN NUMBER) IS
   SELECT DISTINCT ship_to_party_name
        , ship_to_address
        , ship_to_city
        , ship_to_state
        , ship_to_postal_code
        , ship_to_country
   FROM ozf_resale_lines_int_all
   WHERE resale_batch_id = cv_resale_batch_id
   AND status_code = 'PROCESSED'
   AND ( duplicated_line_id IS NULL
         OR ( duplicated_line_id IS NOT NULL AND duplicated_adjustment_id = -1)
       )
   AND ship_to_party_id IS NULL
   AND ship_to_cust_account_id IS NULL
   AND ship_to_party_name IS NOT NULL;

TYPE orig_shipto_cust_tbl_type IS TABLE OF csr_orig_shipto_cust%ROWTYPE INDEX BY BINARY_INTEGER;
l_orig_shipto_cust_tbl orig_shipto_cust_tbl_type;

BEGIN
   -- Standard BEGIN of API savepoint
   SAVEPOINT  Derive_ship_To_Party;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
        l_api_version,
        p_api_version,
        l_api_name,
        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Initialize message LIST IF p_init_msg_LIST IS TRUE.
   IF FND_API.To_Boolean (p_init_msg_LIST) THEN
      FND_MSG_PUB.initialize;

   END IF;
   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   OPEN  csr_orig_shipto_count (p_resale_batch_id);
   FETCH csr_orig_shipto_count INTO l_orig_shipto_count;
   CLOSE csr_orig_shipto_count;

   OPEN  csr_orig_shipto_cust(p_resale_batch_id);
   FETCH csr_orig_shipto_cust BULK COLLECT INTO l_orig_shipto_cust_tbl;
   CLOSE csr_orig_shipto_cust;

   IF l_orig_shipto_cust_tbl.COUNT > 0 THEN
      FOR i IN 1..l_orig_shipto_cust_tbl.COUNT
      LOOP
         l_new_party_rec              := NULL;
         l_exist_shipto_party_id      := NULL;
         l_exist_billto_party_id      := NULL;
         l_exist_billto_party_site_id := NULL;

         --Derive ship_to_party_id from bill_to_party_id
         OPEN  csr_exist_billto_party_id (p_resale_batch_id, l_orig_shipto_cust_tbl(i).ship_to_party_name);
         FETCH csr_exist_billto_party_id INTO l_exist_billto_party_id;
         CLOSE csr_exist_billto_party_id;
         IF (l_exist_billto_party_id IS NOT NULL) THEN
            --New Party and Relationship should not be created.
            l_new_party_rec.party_id := l_exist_billto_party_id;
            l_new_party_rec.name := NULL;
            l_new_party_rec.partner_party_id := NULL;
            --Derive ship_to_party_site_id from bill_party_to_site_id
            OPEN  csr_exist_billto_party_site_id (
               p_resale_batch_id,
               l_orig_shipto_cust_tbl(i).ship_to_party_name,
               l_orig_shipto_cust_tbl(i).ship_to_address,
               l_orig_shipto_cust_tbl(i).ship_to_city,
               l_orig_shipto_cust_tbl(i).ship_to_state,
               l_orig_shipto_cust_tbl(i).ship_to_postal_code,
               l_orig_shipto_cust_tbl(i).ship_to_country
            );
            FETCH csr_exist_billto_party_site_id INTO l_exist_billto_party_site_id;
            CLOSE csr_exist_billto_party_site_id;
            IF (l_exist_billto_party_site_id IS NOT NULL) THEN
               --New Location and Party Site should not be created.
               l_new_party_rec.party_site_id := l_exist_billto_party_site_id;
               l_new_party_rec.address := NULL;
            ELSE
               --Create New Party Site
               l_new_party_rec.address := l_orig_shipto_cust_tbl(i).ship_to_address;
            END IF;
         ELSE
            --Create New Ship To Party
            l_new_party_rec.name := l_orig_shipto_cust_tbl(i).ship_to_party_name;
            l_new_party_rec.partner_party_id := p_partner_party_id;
            l_new_party_rec.address := l_orig_shipto_cust_tbl(i).ship_to_address;
         END IF;

         IF (l_exist_billto_party_id IS NULL
         AND l_orig_shipto_count <> l_orig_shipto_cust_tbl.COUNT) THEN
            --Check whether a party with this name has already been already created.
            OPEN  csr_exist_shipto_party_id (p_resale_batch_id, l_orig_shipto_cust_tbl(i).ship_to_party_name);
            FETCH csr_exist_shipto_party_id INTO l_exist_shipto_party_id;
            CLOSE csr_exist_shipto_party_id;
            IF (l_exist_shipto_party_id IS NOT NULL) THEN
               --New Party and Relationship should not be created.
               --Derive the party_id from existing party.
               l_new_party_rec.party_id         := l_exist_shipto_party_id;
               l_new_party_rec.name             := NULL;
               l_new_party_rec.partner_party_id := NULL;
            END IF;
         END IF;

         --Pass the following information anyway to create ship_to_site_use_id
         l_new_party_rec.city             := l_orig_shipto_cust_tbl(i).ship_to_city;
         l_new_party_rec.state            := l_orig_shipto_cust_tbl(i).ship_to_state;
         l_new_party_rec.postal_Code      := l_orig_shipto_cust_tbl(i).ship_to_postal_code;
         l_new_party_rec.country          := l_orig_shipto_cust_tbl(i).ship_to_country;
         l_new_party_rec.site_Use_Code    := 'SHIP_TO';

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

         --Update ship_to_party_id, ship_to_party_site_id and ship_to_site_use_id
         UPDATE ozf_resale_lines_int_all
         SET ship_to_party_id      = l_new_party_rec.party_id,
             ship_to_party_site_id = l_new_party_rec.party_site_id,
             ship_to_site_use_id   = l_new_party_rec.party_site_use_id
         WHERE ship_to_party_id IS NULL
         AND ship_to_cust_account_id IS NULL
         AND resale_batch_id            = p_resale_batch_id
         AND ship_to_party_name         = l_orig_shipto_cust_tbl(i).ship_to_party_name
         AND NVL(ship_to_address,1)     = NVL(l_orig_shipto_cust_tbl(i).ship_to_address,1)
         AND NVL(ship_to_city,1)        = NVL(l_orig_shipto_cust_tbl(i).ship_to_city,1)
         AND NVL(ship_to_state,1)       = NVL(l_orig_shipto_cust_tbl(i).ship_to_state,1)
         AND NVL(ship_to_postal_code,1) = NVL(l_orig_shipto_cust_tbl(i).ship_to_postal_code,1)
         AND NVL(ship_to_country,1)     = NVL(l_orig_shipto_cust_tbl(i).ship_to_country,1);

      END LOOP;
   END IF;

 -- Debug Message
 IF OZF_DEBUG_HIGH_ON THEN
    OZF_UTILITY_PVT.debug_message(l_full_name||': End');
 END IF;

 --Standard call to get message count AND IF count=1, get the message
 FND_MSG_PUB.Count_And_Get (
    p_encoded => FND_API.G_FALSE,
    p_count => x_msg_count,
    p_data  => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Derive_Ship_To_Party;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Derive_Ship_To_Party;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Derive_Ship_To_Party;
      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('SQLERRM '|| sqlerrm);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Derive_Ship_To_Party;

-------------------------------------------------------------------------------
-- PROCEDURE
--    Derive_End_Cust_Party
--
-- PURPOSE
--    This procedure derives End Customer Party, Party_Site, Party_Site_Use and
--    Relationship.
--
-- PARAMETERS
--    p_resale_batch_id IN NUMBER
--    p_partner_party_id IN NUMBER
--    x_return_status OUT NOCOPY VARCHAR2
--
-- NOTES
--
--
-- HISTORY
--    06-May-2009  ateotia   Created.
--                           Bug# 8489216 fixed.
-------------------------------------------------------------------------------
PROCEDURE Derive_End_Cust_Party (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN  NUMBER
   ,p_partner_party_id       IN  NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
l_api_name                CONSTANT VARCHAR2(30) := 'Derive_End_Cust_Party';
l_api_version             CONSTANT NUMBER       := 1.0;
l_full_name               CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
l_return_status           VARCHAR2(30);
l_msg_data                VARCHAR2(2000);
l_msg_count               NUMBER;
l_new_party_rec           OZF_RESALE_COMMON_PVT.party_rec_type;
l_orig_end_cust_count     NUMBER;
l_exist_end_cust_party_id NUMBER;

CURSOR csr_orig_end_cust_count (cv_resale_batch_id IN NUMBER) IS
   SELECT COUNT(DISTINCT end_cust_party_name)
   FROM ozf_resale_lines_int_all
   WHERE resale_batch_id = cv_resale_batch_id
   AND status_code = 'PROCESSED'
   AND ( duplicated_line_id IS NULL
         OR ( duplicated_line_id IS NOT NULL AND duplicated_adjustment_id = -1)
       )
   AND end_cust_party_id IS NULL
   AND end_cust_party_name IS NOT NULL;

CURSOR csr_exist_end_cust_party_id (cv_resale_batch_id IN NUMBER, cv_end_cust_party_name IN VARCHAR2) IS
   SELECT end_cust_party_id
   FROM ozf_resale_lines_int_all
   WHERE resale_batch_id = cv_resale_batch_id
   AND end_cust_party_name = cv_end_cust_party_name
   AND status_code = 'PROCESSED'
   AND ( duplicated_line_id IS NULL
         OR ( duplicated_line_id IS NOT NULL AND duplicated_adjustment_id = -1)
       )
   AND end_cust_party_id IS NOT NULL
   GROUP BY end_cust_party_id
   ORDER BY end_cust_party_id;

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
         OR ( duplicated_line_id IS NOT NULL AND duplicated_adjustment_id = -1)
       )
   AND end_cust_party_id IS NULL
   AND end_cust_party_name IS NOT NULL;

TYPE orig_end_cust_tbl_type IS TABLE of csr_orig_end_cust%ROWTYPE INDEX BY BINARY_INTEGER;
l_orig_end_cust_tbl orig_end_cust_tbl_type;

BEGIN
   -- Standard BEGIN of API savepoint
   SAVEPOINT  Derive_Bill_To_Party;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
        l_api_version,
        p_api_version,
        l_api_name,
        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Initialize message LIST IF p_init_msg_LIST IS TRUE.
   IF FND_API.To_Boolean (p_init_msg_LIST) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   OPEN csr_orig_end_cust_count (p_resale_batch_id);
   FETCH csr_orig_end_cust_count INTO l_orig_end_cust_count;
   CLOSE csr_orig_end_cust_count;

   OPEN csr_orig_end_cust(p_resale_batch_id);
   FETCH csr_orig_end_cust BULK COLLECT INTO l_orig_end_cust_tbl;
   CLOSE csr_orig_end_cust;

   IF l_orig_end_cust_tbl.COUNT > 0 THEN
      FOR i IN 1..l_orig_end_cust_tbl.COUNT
      LOOP
         l_new_party_rec                  := NULL;
         l_exist_end_cust_party_id        := NULL;
         l_new_party_rec.partner_party_id := p_partner_party_id;
         l_new_party_rec.name             := l_orig_end_cust_tbl(i).end_cust_party_name;
         l_new_party_rec.address          := l_orig_end_cust_tbl(i).end_cust_address;
         l_new_party_rec.city             := l_orig_end_cust_tbl(i).end_cust_city;
         l_new_party_rec.state            := l_orig_end_cust_tbl(i).end_cust_state;
         l_new_party_rec.postal_code      := l_orig_end_cust_tbl(i).end_cust_postal_code;
         l_new_party_rec.country          := l_orig_end_cust_tbl(i).end_cust_country;
         l_new_party_rec.site_use_code    := l_orig_end_cust_tbl(i).end_cust_site_use_code;

         IF (l_orig_end_cust_count <> l_orig_end_cust_tbl.COUNT) THEN
            --Check whether a party with this name has already been already created.
            OPEN csr_exist_end_cust_party_id (p_resale_batch_id, l_orig_end_cust_tbl(i).end_cust_party_name);
            FETCH csr_exist_end_cust_party_id INTO l_exist_end_cust_party_id;
            CLOSE csr_exist_end_cust_party_id;
            IF(l_exist_end_cust_party_id IS NOT NULL) THEN
               --New Party and Party Relationship should not be created.
               --Derive the party_id from existing party.
               l_new_party_rec.party_id         := l_exist_end_cust_party_id;
               l_new_party_rec.name             := NULL;
               l_new_party_rec.partner_party_id := NULL;
            END IF;
         END IF;

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

         --Update end_cust_party_id, end_cust_party_site_id and end_cust_site_use_id
         UPDATE ozf_resale_lines_int_all
         SET end_cust_party_id      = l_new_party_rec.party_id,
             end_cust_party_site_id = l_new_party_rec.party_site_id,
             end_cust_site_use_id   = l_new_party_rec.party_site_use_id
         WHERE end_cust_party_id IS NULL
         AND resale_batch_id               = p_resale_batch_id
         AND end_cust_party_name           = l_orig_end_cust_tbl(i).end_cust_party_name
         AND NVL(end_cust_address,1)       = NVL(l_orig_end_cust_tbl(i).end_cust_address,1)
         AND NVL(end_cust_city,1)          = NVL(l_orig_end_cust_tbl(i).end_cust_city,1)
         AND NVL(end_cust_state,1)         = NVL(l_orig_end_cust_tbl(i).end_cust_state,1)
         AND NVL(end_cust_postal_code,1)   = NVL(l_orig_end_cust_tbl(i).end_cust_postal_code,1)
         AND NVL(end_cust_country,1)       = NVL(l_orig_end_cust_tbl(i).end_cust_country,1)
         AND NVL(end_cust_site_use_code,1) = NVL(l_orig_end_cust_tbl(i).end_cust_site_use_code,1);

      END LOOP;
   END IF;

 -- Debug Message
 IF OZF_DEBUG_HIGH_ON THEN
    OZF_UTILITY_PVT.debug_message(l_full_name||': End');
 END IF;

 --Standard call to get message count AND IF count=1, get the message
 FND_MSG_PUB.Count_And_Get (
    p_encoded => FND_API.G_FALSE,
    p_count => x_msg_count,
    p_data  => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Derive_End_Cust_Party;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Derive_End_Cust_Party;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Derive_End_Cust_Party;
      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('SQLERRM '|| sqlerrm);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Derive_End_Cust_Party;

END OZF_RESALE_COMMON_PVT;

/
