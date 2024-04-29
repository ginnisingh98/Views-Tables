--------------------------------------------------------
--  DDL for Package Body OZF_SALES_TRANSACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_SALES_TRANSACTIONS_PVT" AS
/* $Header: ozfvstnb.pls 120.13.12010000.4 2008/12/01 10:55:28 nirprasa ship $ */

-- Package name     : OZF_SALES_TRANSACTIONS_PVT
-- Purpose          :
-- History          :
-- 24/NOV/2008 - nirprasa Fixed bug 7030415
-- 01/DEC/2008 - nirprasa Fixed bug 6808124
-- NOTE             :
-- End of Comments

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'OZF_SALES_TRANSACTIONS_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(30) := 'ozfvstnb.pls';

OZF_DEBUG_HIGH_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);

G_COMMON_UOM_CODE            VARCHAR2(30) := FND_PROFILE.value('OZF_TP_COMMON_UOM');
G_COMMON_CURRENCY_CODE       VARCHAR2(15) := FND_PROFILE.value('OZF_TP_COMMON_CURRENCY');
---------------------------------------------------------------------
-- PROCEDURE
--    Validate_transaction
--
-- PURPOSE
--    Validate a transaction record.
--
-- PARAMETERS
--    p_transaction : the transaction code record to be validated
--
-- NOTES
--
----------------------------------------------------------------------
PROCEDURE  Validate_Transaction (
    p_api_version            IN   NUMBER
   ,p_init_msg_list          IN   VARCHAR2
   ,p_validation_level       IN   NUMBER
   ,x_return_status          OUT NOCOPY  VARCHAR2
   ,x_msg_count              OUT NOCOPY  NUMBER
   ,x_msg_data               OUT NOCOPY  VARCHAR2
   ,p_transaction            IN  SALES_TRANSACTION_REC_TYPE
   )
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Validate_transaction';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     VARCHAR2(30);
l_msg_data          VARCHAR2(2000);
l_msg_count         number;

BEGIN
   -- Standard begin of API savepoint
   SAVEPOINT  Validate_trans_PVT;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
      l_api_version,
      p_api_version,
      l_api_name,
      G_PKG_NAME)
   THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
     OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   If p_transaction.source_code = 'OM' THEN
      IF OZF_DEBUG_LOW_ON THEN
         ozf_utility_PVT.debug_message('IN OM:'  );
         ozf_utility_PVT.debug_message('sold_to_cust_account_id: '||p_transaction.sold_to_cust_account_id);
         ozf_utility_PVT.debug_message('sold_to_party_id: '||p_transaction.sold_to_party_id);
         ozf_utility_PVT.debug_message('bill_to_site_use_id: '||p_transaction.bill_to_site_use_id);
         ozf_utility_PVT.debug_message('ship_to_site_use_id: '||p_transaction.ship_to_site_use_id);
         ozf_utility_PVT.debug_message('header_id: '||p_transaction.header_id);
         ozf_utility_PVT.debug_message('line_id: '||p_transaction.line_id);
      END IF;

      IF p_transaction.sold_to_cust_account_id is NULL OR
         p_transaction.sold_to_party_id is NULL OR
         p_transaction.bill_to_site_use_id is NULL OR
         p_transaction.ship_to_site_use_id is NULL THEN

         ozf_utility_PVT.error_message('OZF_TRANS_BILLTO_NULL');
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      IF p_transaction.header_id is NULL OR
         p_transaction.line_id is NULL THEN

         ozf_utility_PVT.error_message('OZF_TRANS_ORDER_REF_NULL');
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

   ELSIF p_transaction.source_code = 'IS' THEN
      IF OZF_DEBUG_LOW_ON THEN
         ozf_utility_PVT.debug_message('IN IS:'  );
         ozf_utility_PVT.debug_message('sold_from_party_id: '||p_transaction.sold_from_party_id);
         ozf_utility_PVT.debug_message('header_id: '||p_transaction.header_id);
         ozf_utility_PVT.debug_message('line_id: '||p_transaction.line_id);
      END IF;

      IF p_transaction.sold_from_party_id is null THEN

         ozf_utility_PVT.error_message('OZF_TRANS_SOLDFROM_NULL');
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      IF p_transaction.header_id is NULL OR
         p_transaction.line_id is NULL THEN

         ozf_utility_PVT.error_message('OZF_TRANS_ORDER_REF_NULL');
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

   ELSIF p_transaction.source_code = 'MA' THEN
      IF OZF_DEBUG_LOW_ON THEN
         ozf_utility_PVT.debug_message('IN MA:'  );
         ozf_utility_PVT.debug_message('sold_to_party_id: '||p_transaction.sold_to_party_id);
      END IF;

      IF p_transaction.sold_to_party_id is null THEN
         OZF_UTILITY_PVT.error_message('OZF_TRANS_SOLD_TO_PTY_NULL');
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   ELSE
      OZF_UTILITY_PVT.error_message('OZF_TRANS_SOURCE_CD_WRG');
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
     OZF_UTILITY_PVT.debug_message(l_full_name||': End');
   END IF;
   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Validate_trans_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO  Validate_trans_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO  Validate_trans_PVT;
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
END Validate_Transaction;

---------------------------------------------------------------------
-- PROCEDURE
--    create_transaction
--
-- PURPOSE
--    This procedure creates an transaction
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Create_Transaction (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2
   ,p_commit                 IN  VARCHAR2
   ,p_validation_level       IN  NUMBER
   ,p_transaction_rec        IN  SALES_TRANSACTION_REC_TYPE
   ,x_sales_transaction_id   OUT NOCOPY   NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'create_transaction';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     VARCHAR2(30);
l_msg_data          VARCHAR2(2000);
l_msg_count         number;

l_transaction_rec  SALES_TRANSACTION_REC_TYPE := p_transaction_rec;
CURSOR primay_uom_code_csr(p_id in number) is
select primary_uom_code
from mtl_system_items
where inventory_item_id = p_id;

l_primary_uom_code VARCHAR2(30);

l_common_uom_code VARCHAR2(30);
l_common_currency_code VARCHAR2(30);

CURSOR transaction_id_csr is
select ozf_Sales_Transactions_all_s.nextval
from dual;
l_sales_transaction_id number;

CURSOR sales_transation_csr(p_line_id NUMBER,p_source_code VARCHAR2) IS
   SELECT 1 FROM DUAL WHERE EXISTS
    ( SELECT 1
      FROM ozf_sales_transactions_all trx
      WHERE trx.line_id = p_line_id
      AND source_code = nvl(p_source_code,'OM')); --fix for bug 6808124
--Added for bug 7030415
CURSOR c_get_conversion_type( p_org_id IN NUMBER) IS
SELECT exchange_rate_type
FROM   ozf_sys_parameters_all
WHERE  org_id = p_org_id;

l_exchange_rate_type      VARCHAR2(30) := FND_API.G_MISS_CHAR;
l_rate                    NUMBER;
l_vol_offr_apply_discount NUMBER;
l_sales_trans             NUMBER;
BEGIN
   -- Standard begin of API savepoint
   SAVEPOINT  CREATE_TRANSACTION;
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
   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message('inventory_item_id:' ||l_transaction_rec.inventory_item_id);
      OZF_UTILITY_PVT.debug_message('transaction_date:' ||l_transaction_rec.transaction_date);
      OZF_UTILITY_PVT.debug_message('quantity:' ||l_transaction_rec.quantity);
      OZF_UTILITY_PVT.debug_message('uom_code:' ||l_transaction_rec.uom_code );
   END IF;

   IF l_transaction_rec.inventory_item_id is null OR
       l_transaction_rec.transaction_date is null OR
       l_transaction_rec.quantity is null OR
       l_transaction_rec.uom_code is null THEN

       OZF_UTILITY_PVT.error_message('OZF_SALES_TRANS_MISS');
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Validate the record
   Validate_Transaction (
       p_api_version      => 1.0
      ,p_init_msg_list    => FND_API.G_FALSE
      ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
      ,x_return_status    => l_return_status
      ,x_msg_count        => l_msg_count
      ,x_msg_data         => l_msg_data
      ,p_transaction      => l_transaction_rec
   );
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

    -- Default transfer_type if necessary
    IF l_transaction_rec.transfer_type IS NULL THEN
       IF l_transaction_rec.quantity > 0 THEN
          l_transaction_rec.transfer_type := 'IN';
       ELSE
          l_transaction_rec.transfer_type := 'OUT';
          l_transaction_rec.quantity := abs( l_transaction_rec.quantity );
       END IF;
    ELSE
       l_transaction_rec.quantity := abs( l_transaction_rec.quantity );
    END IF;

    IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_PVT.debug_message('start conversion');
    END IF;

    l_transaction_rec.error_flag := 'N';
    -- uom_code conversion

    --  check whether the primanay uom_code = uom_code
    -- If not convert quantity
    IF l_transaction_rec.primary_uom_code is null or l_transaction_rec.primary_quantity is null THEN
       OPEN primay_uom_code_csr(l_transaction_rec.inventory_item_id);
       FETCH primay_uom_code_csr into l_primary_uom_code;
       CLOSE primay_uom_code_csr;

       IF l_primary_uom_code = l_transaction_rec.uom_code THEN

           l_transaction_rec.primary_uom_code := l_transaction_rec.uom_code;
           l_transaction_rec.primary_quantity := l_transaction_rec.quantity;
       ELSE

            l_transaction_rec.primary_quantity := inv_convert.inv_um_convert(
                                                   l_transaction_rec.inventory_item_id,
                                                   null,
                                                   l_transaction_rec.quantity,
                                                   l_transaction_rec.uom_code,
                                                   l_primary_uom_code,
                                                   null, null);
            IF l_transaction_rec.primary_quantity = -99999 THEN
               l_transaction_rec.primary_quantity := null;
               l_transaction_rec.primary_uom_code := null;
               l_transaction_rec.error_flag := 'Y';
            ELSE
               l_transaction_rec.primary_uom_code := l_primary_uom_code;
            END IF;
       END IF;
    END IF;
    IF OZF_DEBUG_LOW_ON THEN
       ozf_utility_PVT.debug_message('primary_uom_code: '||l_transaction_rec.primary_uom_code);
       ozf_utility_PVT.debug_message('primary_quantity: '||l_transaction_rec.primary_quantity);
       ozf_utility_PVT.debug_message('error_flag: '||l_transaction_rec.error_flag);
     END IF;
    -- Second check whether uom_code = common uom_code
    -- If not convert quantity
    IF l_transaction_rec.common_uom_code is null or l_transaction_rec.common_quantity is null THEN
       l_common_uom_code := G_COMMON_UOM_CODE; --fnd_profile.value('OZF_TP_COMMON_UOM');
       IF l_common_uom_code = l_transaction_rec.uom_code THEN

           l_transaction_rec.common_uom_code := l_transaction_rec.uom_code;
           l_transaction_rec.common_quantity := l_transaction_rec.quantity;
       ELSE

            l_transaction_rec.common_uom_code := l_common_uom_code;
            l_transaction_rec.common_quantity := inv_convert.inv_um_convert(
                                                l_transaction_rec.inventory_item_id,
                                                null,
                                                l_transaction_rec.quantity,
                                                l_transaction_rec.uom_code,
                                                l_common_uom_code,
                                                null, null);
            IF l_transaction_rec.common_quantity = -99999 THEN
               l_transaction_rec.common_quantity := null;
               l_transaction_rec.common_uom_code := null;
               l_transaction_rec.error_flag := 'Y';
            ELSE
               l_transaction_rec.common_uom_code := l_common_uom_code;
            END IF;
       END IF;
    END IF;
    IF OZF_DEBUG_LOW_ON THEN
       ozf_utility_PVT.debug_message('common_code: '||l_transaction_rec.common_uom_code);
       ozf_utility_PVT.debug_message('common_quantity: '||l_transaction_rec.common_quantity);
      ozf_utility_PVT.debug_message('error_flag: '||l_transaction_rec.error_flag);
    END IF;

    -- Third check whether common currency_code =
    -- If not convert currency code
    IF l_transaction_rec.currency_code is not null AND
       l_transaction_rec.amount is not null THEN
       IF l_transaction_rec.common_CURRENCY_CODE is null or
          l_transaction_rec.common_amount is null THEN
          l_common_currency_code := G_COMMON_CURRENCY_CODE; --fnd_profile.value('OZF_TP_COMMON_CURRENCY');
          IF l_common_currency_code = l_transaction_rec.currency_code THEN

               l_transaction_rec.common_currency_code := l_transaction_rec.currency_code;
               l_transaction_rec.common_amount := l_transaction_rec.amount;
          ELSE
             --Added for bug 7030415
             OPEN c_get_conversion_type(l_transaction_rec.org_id);
             FETCH c_get_conversion_type INTO l_exchange_rate_type;
             CLOSE c_get_conversion_type;
             l_transaction_rec.common_currency_code := l_common_currency_code;
             ozf_utility_pvt.Convert_Currency (
               x_return_status     => l_return_status,
               p_from_currency     => l_transaction_rec.currency_code,
               p_to_currency       => l_common_currency_code,
               p_conv_type         => l_exchange_rate_type,
               p_conv_date         => l_transaction_rec.transaction_date,
               p_from_amount       => l_transaction_rec.amount,
               x_to_amount         => l_transaction_rec.common_amount,
               x_rate              => l_rate
             );
          END IF;
       END IF;
   END IF;

   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_PVT.debug_message('common_currency_code: '||l_transaction_rec.common_currency_code);
      ozf_utility_PVT.debug_message('common_amount: '||l_transaction_rec.common_amount);
      ozf_utility_PVT.debug_message('error_flag: '||l_transaction_rec.error_flag);
   END IF;

     --fix for bug 6808124
   OPEN sales_transation_csr(l_transaction_rec.LINE_ID,l_transaction_rec.source_code);
   FETCH  sales_transation_csr INTO l_sales_trans;
   CLOSE sales_transation_csr;

   --22-FEB-2007 bug 5610124 - create sales transaction record if it doesn't exist
   IF NVL(l_sales_trans,0) <> 1 THEN

      OPEN transaction_id_csr;
      FETCH transaction_id_csr INTO l_sales_transaction_id;
      CLOSE transaction_id_csr;

      insert into ozf_sales_transactions_all(
         Sales_Transaction_id,
         OBJECT_VERSION_NUMBER,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         REQUEST_ID,
         CREATED_BY,
         CREATED_FROM,
         LAST_UPDATE_LOGIN,
         PROGRAM_APPLICATION_ID,
         PROGRAM_UPDATE_DATE,
         PROGRAM_ID,
         SOLD_FROM_CUST_ACCOUNT_ID,
         SOLD_FROM_PARTY_ID,
         SOLD_FROM_PARTY_SITE_ID,
         SOLD_TO_CUST_ACCOUNT_ID,
         SOLD_TO_PARTY_ID,
         SOLD_TO_PARTY_SITE_ID,
         BILL_TO_SITE_USE_ID,
         SHIP_TO_SITE_USE_ID,
         TRANSACTION_DATE,
         TRANSFER_TYPE,
         QUANTITY,
         uom_code,
         AMOUNT,
         CURRENCY_CODE,
         INVENTORY_ITEM_ID,
         PRIMARY_QUANTITY,
         PRIMARY_uom_code,
         AVAILABLE_PRIMARY_QUANTITY,
         COMMON_QUANTITY,
         COMMON_uom_code,
         COMMON_CURRENCY_CODE,
         COMMON_AMOUNT,
         HEADER_ID,
         LINE_ID,
         REASON_CODE,
         SOURCE_CODE,
         ERROR_FLAG,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4 ,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14 ,
         ATTRIBUTE15,
         org_id
      ) values (
         l_sales_transaction_id,
         1.0,
         sysdate,
         NVL(FND_GLOBAL.user_id,-1),
         sysdate,
         FND_GLOBAL.CONC_REQUEST_ID,
         NVL(FND_GLOBAL.user_id,-1),
         NULL,
         NVL(FND_GLOBAL.conc_login_id,-1),
         FND_GLOBAL.PROG_APPL_ID,
         sysdate,
         FND_GLOBAL.CONC_PROGRAM_ID,
         l_transaction_rec.SOLD_FROM_CUST_ACCOUNT_ID,
         l_transaction_rec.SOLD_FROM_PARTY_ID,
         l_transaction_rec.SOLD_FROM_PARTY_SITE_ID,
         l_transaction_rec.SOLD_TO_CUST_ACCOUNT_ID,
         l_transaction_rec.SOLD_TO_PARTY_ID,
         l_transaction_rec.SOLD_TO_PARTY_SITE_ID,
         l_transaction_rec.BILL_TO_SITE_USE_ID,
         l_transaction_rec.SHIP_TO_SITE_USE_ID,
         TRUNC(l_transaction_rec.TRANSACTION_DATE),
         l_transaction_rec.TRANSFER_TYPE,
         l_transaction_rec.QUANTITY,
         l_transaction_rec.uom_code,
         l_transaction_rec.AMOUNT,
         l_transaction_rec.CURRENCY_CODE,
         l_transaction_rec.INVENTORY_ITEM_ID,
         l_transaction_rec.PRIMARY_QUANTITY,
         l_transaction_rec.PRIMARY_uom_code,
         l_transaction_rec.PRIMARY_QUANTITY,
         l_transaction_rec.COMMON_QUANTITY,
         l_transaction_rec.COMMON_uom_code,
         l_transaction_rec.COMMON_CURRENCY_CODE,
         l_transaction_rec.COMMON_AMOUNT,
         l_transaction_rec.HEADER_ID,
         l_transaction_rec.LINE_ID,
         l_transaction_rec.REASON_CODE,
         l_transaction_rec.SOURCE_CODE,
         l_transaction_rec.ERROR_FLAG,
         l_transaction_rec.ATTRIBUTE_CATEGORY,
         l_transaction_rec.ATTRIBUTE1,
         l_transaction_rec.ATTRIBUTE2,
         l_transaction_rec.ATTRIBUTE3,
         l_transaction_rec.ATTRIBUTE4 ,
         l_transaction_rec.ATTRIBUTE5,
         l_transaction_rec.ATTRIBUTE6,
         l_transaction_rec.ATTRIBUTE7,
         l_transaction_rec.ATTRIBUTE8,
         l_transaction_rec.ATTRIBUTE9,
         l_transaction_rec.ATTRIBUTE10,
         l_transaction_rec.ATTRIBUTE11,
         l_transaction_rec.ATTRIBUTE12,
         l_transaction_rec.ATTRIBUTE13,
         l_transaction_rec.ATTRIBUTE14 ,
         l_transaction_rec.ATTRIBUTE15,
         l_transaction_rec.org_id
      );

      x_sales_transaction_id := l_sales_transaction_id;
      IF OZF_DEBUG_LOW_ON THEN
         ozf_utility_PVT.debug_message('insert done' || l_sales_transaction_id);
      END IF;

   END IF; --IF NVL(l_sales_trans,0) <> 1 THEN


   IF l_transaction_rec.SOURCE_CODE = 'OM' THEN
      OZF_VOLUME_CALCULATION_PUB.Create_Volume(
         p_init_msg_list     => FND_API.g_false
        ,p_api_version       => 1.0
        ,p_commit            => FND_API.g_false
        ,x_return_status     => l_return_status
        ,x_msg_count         => l_msg_count
        ,x_msg_data          => l_msg_data
        ,p_volume_detail_rec => l_transaction_rec
        ,p_qp_list_header_id => l_transaction_rec.qp_list_header_id
        ,x_apply_discount    => l_vol_offr_apply_discount
      );
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;


    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
       OZF_UTILITY_PVT.debug_message(l_full_name||': End');
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
        ROLLBACK TO CREATE_TRANSACTION;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CREATE_TRANSACTION;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO CREATE_TRANSACTION;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
END create_transaction;


---------------------------------------------------------------------
-- PROCEDURE
--    Initiate_Inventory_Tmp
--
-- PURPOSE
--    Populate the inventory temporary table
--
-- PARAMETERS
--    p_resale_batch_id: Resale_Batch_Id
--    p_start_date : The start date when we want to take a snapshot of inventory
--    p_end_date : The end date when we want to take a snapshot of inventory
--
-- NOTES
--
----------------------------------------------------------------------
PROCEDURE  Initiate_Inventory_Tmp (
    p_api_version            IN   NUMBER
   ,p_init_msg_list          IN   VARCHAR2
   ,p_validation_level       IN   NUMBER
   ,p_resale_batch_id        IN   NUMBER
   ,p_start_date             IN   DATE
   ,p_end_date               IN   DATE
   ,x_return_status          OUT NOCOPY  VARCHAR2
   ,x_msg_count              OUT NOCOPY  NUMBER
   ,x_msg_data               OUT NOCOPY  VARCHAR2
)IS
l_api_name          CONSTANT VARCHAR2(30) := 'Initiate_Inventory_Tmp';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     VARCHAR2(30);
l_msg_data          VARCHAR2(2000);
l_msg_count         number;
-- 6511302 start
CURSOR c_inventory_detl IS
SELECT *
FROM   ozf_inventory_tmp_t;
l_total_primary_quantity     NUMBER;
-- 6511302 end
BEGIN
   -- Standard begin of API savepoint
    SAVEPOINT  INIT_INVEN_TMP;
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
    IF OZF_DEBUG_LOW_ON THEN
       OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
    END IF;

    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;



   -- Force refresh snapshot before the query
   -- Need to think whether it's necessary
   -- Remove refresh
   -- DBMS_MVIEW.REFRESH(
   --   list => 'OZF_INVENTORY_SUMMARY_MV' ,
   --   method => '?'
   -- );

   INSERT INTO ozf_inventory_tmp_t(
      creation_date,
      created_by ,
      last_update_date,
      last_updated_by ,
      last_update_login,
      party_id,
      cust_account_id,
      inventory_item_id,
      transaction_date,
      primary_quantity,
      primary_uom_code,
      source_code,
      transfer_type
   )
   SELECT
      sysdate,
      1,
      sysdate,
      -1,
      -1,
      stn.sold_to_party_id, --NULL,
      NULL, --stn.sold_to_cust_account_id,
      stn.inventory_item_id,
      p_start_date,
      SUM(DECODE(stn.transfer_type, 'IN', 1
                                  , 'OUT', -1
                                  , 0
         ) * NVL(stn.primary_quantity,0)),
      stn.primary_uom_code,
      NULL,
      NULL
   FROM ozf_sales_transactions_all stn
   WHERE stn.transaction_date <= p_start_date
   AND stn.source_code IN ('OM', 'MA')
   AND stn.inventory_item_id IN ( SELECT rli.inventory_item_id
                                  FROM ozf_resale_lines_int_all rli
                                  , hz_cust_accounts hca
                                  WHERE rli.resale_batch_id = p_resale_batch_id
                                  --AND rli.sold_from_cust_account_id = stn.sold_to_cust_account_id
                                  AND rli.sold_from_cust_account_id = hca.cust_account_id
                                  AND hca.party_id = stn.sold_to_party_id
                                )
   GROUP BY stn.sold_to_party_id --stn.sold_to_cust_account_id
          , stn.inventory_item_id
          , stn.primary_uom_code
   UNION ALL
   SELECT
      sysdate,
      1,
      sysdate,
      -1,
      -1,
      stn.sold_from_party_id, --NULL,
      NULL, --stn.sold_from_cust_account_id,
      stn.inventory_item_id,
      p_start_date,
      SUM(DECODE(stn.transfer_type, 'IN', 1
                                  , 'OUT', -1
                                  , 0
         ) * NVL(stn.primary_quantity,0)),
      stn.primary_uom_code,
      NULL,
      NULL
   FROM ozf_sales_transactions_all stn
   WHERE stn.transaction_date <= p_start_date
   AND stn.source_code = 'IS'
   AND stn.inventory_item_id IN ( SELECT rli.inventory_item_id
                                  FROM ozf_resale_lines_int_all rli
                                  , hz_cust_accounts hca
                                  WHERE rli.resale_batch_id = p_resale_batch_id
                                  --AND rli.sold_from_cust_account_id = stn.sold_from_cust_account_id
                                  --AND rli.sold_from_cust_account_id = stn.sold_to_cust_account_id
                                  AND rli.sold_from_cust_account_id = hca.cust_account_id
                                  AND hca.party_id = stn.sold_from_party_id
                                )
   GROUP BY stn.sold_from_party_id --stn.sold_from_cust_account_id
          , stn.inventory_item_id
          , stn.primary_uom_code;


   INSERT INTO ozf_inventory_tmp_t(
      creation_date,
      created_by ,
      last_update_date,
      last_updated_by ,
      last_update_login,
      party_id,
      cust_account_id,
      inventory_item_id,
      transaction_date,
      primary_quantity,
      primary_uom_code,
      source_code,
      transfer_type
   )
   SELECT
      sysdate,
      1,
      sysdate,
      -1,
      -1,
      stn.sold_to_party_id, --NULL,
      NULL, --stn.sold_to_cust_account_id,
      stn.inventory_item_id,
      stn.transaction_date,
      DECODE(stn.transfer_type, 'IN', 1
                              , 'OUT', -1
                              , 0
      ) * NVL(stn.primary_quantity,0),
      stn.primary_uom_code,
      NULL,
      NULL
   FROM ozf_sales_transactions_all stn
   WHERE stn.transaction_date > p_start_date
   AND stn.transaction_date <= p_end_date
   AND stn.source_code IN ('OM', 'MA')
   AND stn.inventory_item_id IN ( SELECT rli.inventory_item_id
                                  FROM ozf_resale_lines_int_all rli
                                  , hz_cust_accounts hca
                                  WHERE rli.resale_batch_id = p_resale_batch_id
                                  --AND rli.sold_from_cust_account_id = stn.sold_to_cust_account_id
                                  AND rli.sold_from_cust_account_id = hca.cust_account_id
                                  AND hca.party_id = stn.sold_to_party_id
                                )
   UNION ALL
   SELECT
      sysdate,
      1,
      sysdate,
      -1,
      -1,
      stn.sold_from_party_id, --NULL,
      NULL, --stn.sold_from_cust_account_id,
      stn.inventory_item_id,
      stn.transaction_date,
      DECODE(stn.transfer_type, 'IN', 1
                                  , 'OUT', -1
                                  , 0
         ) * NVL(stn.primary_quantity,0),
      stn.primary_uom_code,
      NULL,
      NULL
   FROM ozf_sales_transactions_all stn
   WHERE stn.transaction_date > p_start_date
   AND stn.transaction_date <= p_end_date
   AND source_code = 'IS'
   AND stn.inventory_item_id IN ( SELECT rli.inventory_item_id
                                  FROM ozf_resale_lines_int_all rli
                                  , hz_cust_accounts hca
                                  WHERE rli.resale_batch_id = p_resale_batch_id
                                  --AND rli.sold_from_cust_account_id = stn.sold_from_cust_account_id
                                  AND rli.sold_from_cust_account_id = hca.cust_account_id
                                  AND hca.party_id = stn.sold_to_party_id
                                );

/*
   insert into ozf_inventory_tmp_t(
       CREATION_DATE,
       CREATED_BY ,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY ,
       LAST_UPDATE_LOGIN,
       party_id ,
       inventory_item_id,
       primary_uom_code ,
       primary_quantity)
   select sysdate,
      1,
      p_start_date,
      -1,
      -1,
      a.party_id,
      a.inventory_item_id,
      a.primary_uom,
      sum(a.primary_quantity)
      from ozf_inventory_summary_mv a, (SELECT time_id
             FROM OZF_TIME_RPT_STRUCT
             WHERE report_date= trunc(p_start_date)
             AND BITAND(record_type_id,1143)=record_type_id
             ) b
      where a.time_id = b.time_id
      and a.party_id = p_party_id
      group by sysdate,
               1,
               p_start_date,
               -1,
               -1,
               a.party_id,
               a.inventory_item_id,
               a.primary_uom;
*/
-- 6511302 (+)
IF OZF_DEBUG_LOW_ON THEN
  SELECT SUM(primary_quantity)
  INTO l_total_primary_quantity
  FROM ozf_inventory_tmp_t;
  OZF_UTILITY_PVT.debug_message(l_full_name||' : total_primary_quantity = '||l_total_primary_quantity);

  OZF_UTILITY_PVT.debug_message('----------Inventory Detail----------');
  FOR l_inventory_detl IN c_inventory_detl LOOP
    OZF_UTILITY_PVT.debug_message('party_id = ' || l_inventory_detl.party_id);
    OZF_UTILITY_PVT.debug_message('inventory_item_id = ' || l_inventory_detl.inventory_item_id);
    OZF_UTILITY_PVT.debug_message('primary_uom_code = ' || l_inventory_detl.primary_uom_code);
    OZF_UTILITY_PVT.debug_message('primary_quantity = ' || l_inventory_detl.primary_quantity);
    OZF_UTILITY_PVT.debug_message('cust_account_id = ' || l_inventory_detl.cust_account_id);
    OZF_UTILITY_PVT.debug_message('transfer_type = ' || l_inventory_detl.transfer_type);
    OZF_UTILITY_PVT.debug_message('- - - - - - - - - -');
  END LOOP;
  OZF_UTILITY_PVT.debug_message('------------------------------');
END IF;
-- 6511302 (-)

    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
       OZF_UTILITY_PVT.debug_message(l_full_name||': End');
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
        ROLLBACK TO INIT_INVEN_TMP;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO INIT_INVEN_TMP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO INIT_INVEN_TMP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
END Initiate_Inventory_Tmp;

---------------------------------------------------------------------
-- PROCEDURE
--    update_Inventory_tmp
--
-- PURPOSE
--    update the inventory temporary table
--
-- PARAMETERS
--    p_sales_transaction_id: the id of the salse_transaction record to update
--
-- NOTES
--
----------------------------------------------------------------------
PROCEDURE  update_Inventory_tmp (
    p_api_version            IN   NUMBER
   ,p_init_msg_list          IN   VARCHAR2
   ,p_validation_level       IN   NUMBER
   ,p_sales_transaction_id   IN   NUMBER
   ,x_return_status          OUT NOCOPY  VARCHAR2
   ,x_msg_count              OUT NOCOPY  NUMBER
   ,x_msg_data               OUT NOCOPY  VARCHAR2
)IS
l_api_name          CONSTANT VARCHAR2(30) := 'update_inventory_tmp';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     VARCHAR2(30);
l_msg_data          VARCHAR2(2000);
l_msg_count         number;

CURSOR transaction_info_csr (p_id number) is
select primary_quantity, inventory_item_id, sold_from_party_id
from OZF_SALES_TRANSACTIONS_ALL
where Sales_Transaction_id = p_id;
l_primary_quantity  number;
l_inventory_item_id number;
l_party_id          number;

BEGIN
   -- Standard begin of API savepoint
    SAVEPOINT  UPD_INVEN_TMP;
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
    IF OZF_DEBUG_LOW_ON THEN
       OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
    END IF;

    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN transaction_info_csr (p_sales_transaction_id);
    FETCH transaction_info_csr into l_primary_quantity, l_inventory_item_id, l_party_id;
    CLOSE transaction_info_csr;

    IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_PVT.debug_message('primary_quantity:' || l_primary_quantity);
      ozf_utility_PVT.debug_message('inventory_item_id:' || l_inventory_item_id);
      ozf_utility_PVT.debug_message('party_id:' || l_party_id);
    END IF;

    update ozf_inventory_tmp_t
    set primary_quantity = primary_quantity - l_primary_quantity
    where party_id = l_party_id
    and inventory_item_id = l_inventory_item_id;

    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
       OZF_UTILITY_PVT.debug_message(l_full_name||': End');
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
        ROLLBACK TO UPD_INVEN_TMP;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UPD_INVEN_TMP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO UPD_INVEN_TMP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
END update_inventory_tmp;

---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Inventory_Level
--
-- PURPOSE
--    Validate a line against the inventory levle.
--
-- PARAMETERS
--    p_line_int_rec: interface rece.
--
-- NOTES
--
----------------------------------------------------------------------
PROCEDURE  Validate_Inventory_Level (
    p_api_version            IN   NUMBER
   ,p_init_msg_list          IN   VARCHAR2
   ,p_validation_level       IN   NUMBER
   ,p_line_int_rec           IN   OZF_RESALE_COMMON_PVT.g_interface_rec_csr%rowtype
   ,x_valid                  OUT NOCOPY  BOOLEAN
   ,x_return_status          OUT NOCOPY  VARCHAR2
   ,x_msg_count              OUT NOCOPY  NUMBER
   ,x_msg_data               OUT NOCOPY  VARCHAR2
)IS
l_api_name          CONSTANT VARCHAR2(30) := 'Validate_Inventory_Level';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status              VARCHAR2(30);
l_msg_data                   VARCHAR2(2000);
l_msg_count                  NUMBER;

-- Bug 4380203 (+)
CURSOR csr_inventory_level( cv_party_id IN NUMBER --cv_cust_account_id   IN NUMBER
                          , cv_inventory_item_id IN NUMBER
                          , cv_transaction_date  IN DATE
                          ) IS
   SELECT SUM(primary_quantity)
   ,      primary_uom_code
   FROM ozf_inventory_tmp_t
   --WHERE cust_account_id = cv_cust_account_id
   WHERE party_id = cv_party_id
   AND inventory_item_id = cv_inventory_item_id
   AND transaction_date <= cv_transaction_date
   GROUP BY primary_uom_code;
   -- primary_uom_code is unique per product
/*
CURSOR product_level_csr (p_inventory_item_id IN NUMBER) IS
   SELECT primary_uom_code, primary_quantity
   FROM ozf_inventory_tmp_t
   WHERE inventory_item_id = p_inventory_item_id;
*/

CURSOR csr_primary_uom( cv_party_id IN NUMBER --cv_cust_account_id IN NUMBER
                      , cv_inventory_item_id IN NUMBER
                      ) IS
   SELECT primary_uom_code
   FROM ozf_inventory_tmp_t
   --WHERE cust_account_id = cv_cust_account_id
   WHERE party_id = cv_party_id
   AND inventory_item_id = cv_inventory_item_id
   AND rownum = 1;

CURSOR csr_sold_from_party_id (cv_cust_account_id IN NUMBER) IS
   SELECT party_id
   FROM hz_cust_accounts
   WHERE cust_account_id = cv_cust_account_id;

l_sold_from_party_id         NUMBER;
-- Bug 4380203 (-)

l_primary_uom_code           VARCHAR2(30);
l_primary_quantity           NUMBER;
l_converted_quantity         NUMBER;
l_transfer_type              VARCHAR2(10) := 'OUT';

-- 6511302 start
CURSOR c_inventory_detl IS
SELECT *
FROM   ozf_inventory_tmp_t;
l_total_primary_quantity     NUMBER;
-- 6511302 end
BEGIN
   -- Standard begin of API savepoint
   SAVEPOINT  VALID_INV_LVL;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
        l_api_version,
        p_api_version,
        l_api_name,
        G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Initialize message list if p_init_msg_list is TRUE.
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   x_valid := false;

   -- Bug 4380203 (+)
   IF p_line_int_rec.product_transfer_movement_type IN ('TI', 'CD') THEN
      l_transfer_type := 'IN';
   ELSIF p_line_int_rec.product_transfer_movement_type IN ('TO', 'DC') THEN
      l_transfer_type := 'OUT';
   END IF;

   OPEN csr_sold_from_party_id(p_line_int_rec.sold_from_cust_account_id);
   FETCH csr_sold_from_party_id INTO l_sold_from_party_id;
   CLOSE csr_sold_from_party_id;

   -- No need to do inventory level validation when transfering in product
   IF l_transfer_type = 'OUT' THEN
      OPEN csr_inventory_level( l_sold_from_party_id --p_line_int_rec.sold_from_cust_account_id
                              , p_line_int_rec.inventory_item_id
                              , p_line_int_rec.date_ordered
                              );
      FETCH csr_inventory_level INTO l_primary_quantity
                                   , l_primary_uom_code;
      CLOSE csr_inventory_level;

      /*
      -- check with tmp table whether there is enough inventory on stock.
      OPEN product_level_csr (p_line_int_rec.inventory_item_id);
      FETCH product_level_csr into l_primary_uom_code, l_primary_quantity;
      CLOSE product_level_csr;
      */

      IF l_primary_uom_code IS NOT NULL THEN
         IF p_line_int_rec.uom_code = l_primary_uom_code THEN
            x_valid := p_line_int_rec.quantity <= l_primary_quantity;
            l_converted_quantity := p_line_int_rec.quantity;
         ELSE
            -- get qauntity based on primayr_uom_code
            l_converted_quantity := INV_CONVERT.inv_um_convert(
                                        p_line_int_rec.inventory_item_id
                                       ,null
                                       ,p_line_int_rec.quantity
                                       ,p_line_int_rec.uom_code
                                       ,l_primary_uom_code
                                       ,null
                                       ,null
                                    );
            x_valid := l_converted_quantity <= l_primary_quantity;
         END IF;
      END IF;
      l_converted_quantity := l_converted_quantity * -1;
   ELSIF l_transfer_type = 'IN' THEN
      OPEN csr_primary_uom( l_sold_from_party_id --p_line_int_rec.sold_from_cust_account_id
                          , p_line_int_rec.inventory_item_id
                          );
      FETCH csr_primary_uom INTO l_primary_uom_code;
      CLOSE csr_primary_uom;

      IF p_line_int_rec.uom_code = l_primary_uom_code THEN
         l_converted_quantity := p_line_int_rec.quantity;
      ELSE
         l_converted_quantity := INV_CONVERT.inv_um_convert(
                                     p_line_int_rec.inventory_item_id
                                    ,null
                                    ,p_line_int_rec.quantity
                                    ,p_line_int_rec.uom_code
                                    ,l_primary_uom_code
                                    ,null
                                    ,null
                                 );
      END IF;
      x_valid := true;
   END IF;

-- 6511302 (+)
  IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name || ':order number = '||p_line_int_rec.order_number);
      OZF_UTILITY_PVT.debug_message(l_full_name || ':transfer type = '||l_transfer_type);
      OZF_UTILITY_PVT.debug_message(l_full_name || ':l_primary_quantity   = '||l_primary_quantity);
      OZF_UTILITY_PVT.debug_message(l_full_name || ':line quantity = '||ABS(l_converted_quantity));
      OZF_UTILITY_PVT.debug_message(l_full_name || ':item id = ' || p_line_int_rec.inventory_item_id);
      OZF_UTILITY_PVT.debug_message(l_full_name || ':sold_from_party_id = ' || l_sold_from_party_id);
  END IF;
-- 6511302 (-)

   INSERT INTO ozf_inventory_tmp_t(
      creation_date,
      created_by ,
      last_update_date,
      last_updated_by ,
      last_update_login,
      party_id,
      cust_account_id,
      inventory_item_id,
      transaction_date,
      primary_quantity,
      primary_uom_code,
      source_code,
      transfer_type
   ) VALUES (
      sysdate,
      p_line_int_rec.created_by ,
      sysdate,
      p_line_int_rec.last_updated_by ,
      p_line_int_rec.last_update_login,
      l_sold_from_party_id,
      NULL, --p_line_int_rec.sold_from_cust_account_id,
      p_line_int_rec.inventory_item_id,
      p_line_int_rec.date_ordered,
      l_converted_quantity,
      l_primary_uom_code,
      'IS',
      l_transfer_type
   );
   -- Bug 4380203 (-)

-- 6511302 (+)
IF OZF_DEBUG_LOW_ON THEN
  OZF_UTILITY_PVT.debug_message('----------Inventory Detail----------');
  FOR l_inventory_detl IN c_inventory_detl LOOP
    OZF_UTILITY_PVT.debug_message('party_id = ' || l_inventory_detl.party_id);
    OZF_UTILITY_PVT.debug_message('inventory_item_id = ' || l_inventory_detl.inventory_item_id);
    OZF_UTILITY_PVT.debug_message('primary_uom_code = ' || l_inventory_detl.primary_uom_code);
    OZF_UTILITY_PVT.debug_message('primary_quantity = ' || l_inventory_detl.primary_quantity);
    OZF_UTILITY_PVT.debug_message('cust_account_id = ' || l_inventory_detl.cust_account_id);
    OZF_UTILITY_PVT.debug_message('transfer_type = ' || l_inventory_detl.transfer_type);
    OZF_UTILITY_PVT.debug_message('- - - - - - - - - -');
  END LOOP;
  OZF_UTILITY_PVT.debug_message('------------------------------');
END IF;
-- 6511302 (-)

   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': End');
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
        ROLLBACK TO VALID_INV_LVL;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO VALID_INV_LVL;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO VALID_INV_LVL;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
END Validate_Inventory_Level;


---------------------------------------------------------------------
-- PROCEDURE
--    Get_Purchase_Price
--
-- PURPOSE
--    Calculate the purchase price of a line based on the order management data.
--
-- PARAMETERS
--    p_line_int_rec: interface rece.
--    x_purchase_price: NUMBER
--
-- NOTES
--
----------------------------------------------------------------------
PROCEDURE  Get_Purchase_Price (
    p_api_version            IN   NUMBER
   ,p_init_msg_list          IN   VARCHAR2
   ,p_validation_level       IN   NUMBER
   ,p_order_date             IN   DATE
   ,p_sold_from_cust_account_id  IN   NUMBER
   ,p_sold_from_site_id      IN   NUMBER
   ,p_inventory_item_id      IN   NUMBER
   ,p_uom_code               IN   VARCHAR2
   ,p_quantity               IN   NUMBER
   ,p_currency_code          IN   VARCHAR2
   ,p_x_purchase_uom_code    IN OUT NOCOPY VARCHAR2
   ,x_purchase_price         OUT NOCOPY  NUMBER
   ,x_return_status          OUT NOCOPY  VARCHAR2
   ,x_msg_count              OUT NOCOPY  NUMBER
   ,x_msg_data               OUT NOCOPY  VARCHAR2
   )
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Get_Purchase_Price';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     VARCHAR2(30);
l_msg_data          VARCHAR2(2000);
l_msg_count         NUMBER;

l_transaction_id_tbl   OZF_RESALE_COMMON_PVT.number_tbl_type;
l_transaction_date_tbl OZF_RESALE_COMMON_PVT.date_tbl_type;
l_unit_price_tbl       OZF_RESALE_COMMON_PVT.number_tbl_type;
l_currency_code_tbl    OZF_RESALE_COMMON_PVT.varchar_tbl_type;
l_available_quan_tbl   OZF_RESALE_COMMON_PVT.number_tbl_type;
l_primary_uom_tbl      OZF_RESALE_COMMON_PVT.varchar_tbl_type;

l_asking_quantity  NUMBER;

l_trans_id_tbl   OZF_RESALE_COMMON_PVT.number_tbl_type;
l_used_quantity_tbl   OZF_RESALE_COMMON_PVT.number_tbl_type;
l_used_unit_price_tbl   OZF_RESALE_COMMON_PVT.number_tbl_type;
l_rate       NUMBER;
l_default_exchange_type VARCHAR2(30);

l_numerator        NUMBER := 0; -- [BUG 4212965 Fixing]
l_denominator      NUMBER := 0; -- [BUG 4212965 Fixing]
l_uom_ratio        NUMBER;
--
CURSOR Sales_Order_info_csr(p_order_date DATE,
                            p_inventory_item_id NUMBER,
                            p_sold_from_cust_account_id NUMBER) IS
SELECT a.sales_transaction_id,
       a.amount / a.primary_quantity,
       a.currency_code,
       a.transaction_date,
       decode(a.transfer_type, 'IN', a.available_primary_quantity, 'OUT', -1 * a.available_primary_quantity),
       a.primary_uom_code
FROM  ozf_sales_transactions a
WHERE a.available_primary_quantity > 0
AND a.inventory_item_id = p_inventory_item_id
AND a.sold_to_cust_account_id = p_sold_from_cust_account_id
-- AND sold_to_party_site_id = p_sold_from_site_id
AND a.source_code = 'OM'
AND a.transaction_date< p_order_date
ORDER BY a.transaction_date DESC;

BEGIN
   -- Standard begin of API savepoint
   SAVEPOINT  GET_WAC;
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
   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN Sales_Order_info_csr(p_order_date,
                            p_inventory_item_id,
                            p_sold_from_cust_account_id);
   FETCH sales_order_info_csr BULK COLLECT INTO l_transaction_id_tbl,
                                                l_unit_price_tbl,
                                                l_currency_code_tbl,
                                                l_transaction_date_tbl,
                                                l_available_quan_tbl,
                                                l_primary_uom_tbl;
   CLOSE sales_order_info_csr;

   IF l_transaction_id_tbl.exists(1) THEN
      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('Number of OM lines: ' || l_transaction_id_tbl.LAST);
      END IF;

      -- First check whether p_uom_code is the same as the primary_uom_code.
      -- If not, conver the quentity
      -- use this quantity to do the calculation.
      IF p_uom_code = l_primary_uom_tbl(1) THEN
         l_asking_quantity := p_quantity;
      ELSE
         l_asking_quantity :=inv_convert.inv_um_convert(
                                 p_inventory_item_id,
                                 null,
                                 p_quantity,
                                 p_uom_code,
                                 l_primary_uom_tbl(1),
                                 null, null);
      END IF;

      -- Get default exchange type
      OPEN OZF_RESALE_COMMON_PVT.g_exchange_rate_type_csr;
      FETCH OZF_RESALE_COMMON_PVT.g_exchange_rate_type_csr INTO l_default_exchange_type;
      CLOSE OZF_RESALE_COMMON_PVT.g_exchange_rate_type_csr;

      FOR i in 1..l_transaction_id_tbl.LAST
      LOOP
         IF l_asking_quantity = 0 THEN
            EXIT;
         ELSE
            l_trans_id_tbl(i) := l_transaction_id_tbl(i);
            IF l_asking_quantity > l_available_quan_tbl(i) THEN
               l_used_quantity_tbl(i) := l_available_quan_tbl(i);
               l_asking_quantity := l_asking_quantity - l_available_quan_tbl(i);
            ELSE
               l_used_quantity_tbl(i) := l_asking_quantity;
               l_asking_quantity := 0;
            END IF;
            IF p_currency_code = l_currency_code_tbl(i) THEN
               l_used_unit_price_tbl(i) := l_unit_price_tbl(i);
            ELSE
               -- ?? What exchange type to use ?
               -- We will convert it to the asking currency code at the date of transfer.
               OZF_UTILITY_PVT.Convert_Currency(
                   p_from_currency   => l_currency_code_tbl(i)
                  ,p_to_currency     => p_currency_code
                  ,p_conv_type       => l_default_exchange_type
                  ,p_conv_rate       => l_rate
                  ,p_conv_date       => l_transaction_date_tbl(i)
                  ,p_from_amount     => l_unit_price_tbl(i)
                  ,x_return_status   => l_return_status
                  ,x_to_amount       => l_used_unit_price_tbl(i)
                  ,x_rate            => l_rate);
               IF l_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               END IF;
            END IF;
         END IF;
      END LOOP;
      IF l_trans_id_tbl.exists(1) THEN
         FOR i IN 1..l_trans_id_tbl.LAST
         LOOP
            l_numerator := l_numerator + l_used_quantity_tbl(i) * l_used_unit_price_tbl(i);
            l_denominator := l_denominator + l_used_quantity_tbl(i);
         END LOOP;
         x_purchase_price := l_numerator / l_denominator;

         FORALL i IN 1..l_trans_id_tbl.LAST
            UPDATE ozf_sales_transactions_all
            SET    available_primary_quantity = available_primary_quantity - l_used_quantity_tbl(i)
            WHERE  sales_transaction_id = l_trans_id_tbl(i);

         IF p_x_purchase_uom_code IS NULL THEN
            p_x_purchase_uom_code := l_primary_uom_tbl(1);
         ELSE
            l_uom_ratio := INV_CONVERT.inv_um_convert(
                                p_inventory_item_id,
                                null,
                                1,
                                l_primary_uom_tbl(1),
                                p_x_purchase_uom_code,
                                null,
                                null
                           );
            x_purchase_price := OZF_UTILITY_PVT.CurrRound(
                                      (x_purchase_price * l_uom_ratio)
                                    , p_currency_code
                                );
         END IF;
      ELSE
         -- Since we can not find any suitable order lines, we will return purchase price as null
         x_purchase_price := NULL;
      END IF;
   ELSE
      -- Since we can not find any suitable order lines, we will return purchase price as null
      x_purchase_price := NULL;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': End');
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
        ROLLBACK TO GET_WAC;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO GET_WAC;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO GET_WAC;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
END Get_Purchase_Price;

END OZF_SALES_TRANSACTIONS_PVT;

/
