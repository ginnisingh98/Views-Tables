--------------------------------------------------------
--  DDL for Package Body OZF_CLAIMS_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CLAIMS_INT_PVT" as
/* $Header: ozfvcinb.pls 120.4.12010000.2 2008/07/31 11:26:58 kpatro ship $ */

G_DEDUCTION_CLASS      CONSTANT  VARCHAR2(20) := 'DEDUCTION';
G_CLAIM_CLASS          CONSTANT  VARCHAR2(20) := 'CLAIM';
G_OVERPAYMENT_CLASS    CONSTANT  VARCHAR2(20) := 'OVERPAYMENT';
G_CHARGE_CLASS          CONSTANT  VARCHAR2(20) := 'CHARGE';
G_DEDUC_OBJ_TYPE       CONSTANT  VARCHAR2(6)  := 'DEDU';
G_CLAIM_OBJECT_TYPE    CONSTANT  VARCHAR2(30) := 'CLAM';
G_CLAIM_STATUS  CONSTANT VARCHAR2(30) := 'OZF_CLAIM_STATUS';
G_OPEN_STATUS   CONSTANT VARCHAR2(30) := 'OPEN';


-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Claims_Int_PVT
-- Purpose
--
-- History
-- 02-Sep-2005  SSHIVALI   R12: Multi-Org Changes
-- 07-Oct-05    SSHIVALI   Bug#4648903: Added OU Info to Log and Output files
-- 20-Mar-06    Kishore    Bug#5104517 CLAIM IMPORT OZF_CLAIM_LINES_INT_PVT NOT IMPORTING ITEM_TYPE
-- NOTE
--
-- 29-Jul-2008  KPATRO   Fix for bug 7290916
-- End of Comments
-- ===============================================================

G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Claims_Int_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvcinb.pls';

OZF_DEBUG_HIGH_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);

PROCEDURE Create_Claims_Int(
    p_api_version_number   IN   NUMBER,
    p_init_msg_list        IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit               IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level     IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status        OUT NOCOPY  VARCHAR2,
    x_msg_count            OUT NOCOPY  NUMBER,
    x_msg_data             OUT NOCOPY  VARCHAR2,

    p_claims_int_rec       IN   claims_int_rec_type  := g_miss_claims_int_rec,
    x_interface_claim_id   OUT NOCOPY  NUMBER
)
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Claims_Int';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_return_status_full        VARCHAR2(1);
l_object_version_number     NUMBER := 1;
l_org_id                    NUMBER := FND_API.G_MISS_NUM;
l_INTERFACE_CLAIM_ID                  NUMBER;
l_dummy       NUMBER;

--Added for 7290916
l_claim_int_rec     claims_int_rec_type := p_claims_int_rec;

CURSOR c_id IS
   SELECT OZF_CLAIMS_INT_ALL_s.NEXTVAL
   FROM dual;

CURSOR c_id_exists (l_id IN NUMBER) IS
   SELECT 1 FROM dual
   WHERE EXISTS (SELECT 1 FROM OZF_CLAIMS_INT_ALL
              WHERE INTERFACE_CLAIM_ID = l_id);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT CREATE_Claims_Int_PVT;

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
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization
   IF p_claims_int_rec.INTERFACE_CLAIM_ID IS NULL OR
      p_claims_int_rec.INTERFACE_CLAIM_ID = FND_API.g_miss_num
   THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
            FETCH c_id INTO l_INTERFACE_CLAIM_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_INTERFACE_CLAIM_ID);
            FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
      --Added for 7290916
      l_claim_int_rec.INTERFACE_CLAIM_ID := l_INTERFACE_CLAIM_ID;
   END IF;

    -- Added for 7290916
      l_INTERFACE_CLAIM_ID := l_claim_int_rec.INTERFACE_CLAIM_ID;

      OZF_UTILITY_PVT.debug_message('l_INTERFACE_CLAIM_ID :' || l_INTERFACE_CLAIM_ID);

   -- =========================================================================
   -- Validate Environment
   -- =========================================================================
   IF FND_GLOBAL.User_Id IS NULL
   THEN
       OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_USER_PROFILE_MISSING');
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
   THEN
       -- Debug message
       IF OZF_DEBUG_HIGH_ON THEN
          OZF_UTILITY_PVT.debug_message('Private API: Validate_Claims_Int');
       END IF;

       --Added for 7290916
       -- Invoke validation procedures
       Validate_claims_int(
         p_api_version_number     => 1.0,
         p_init_msg_list    => FND_API.G_FALSE,
         p_validation_level => p_validation_level,
         p_claims_int_rec  =>  l_claim_int_rec,
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data);
   END IF;

   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
   END IF;

   -- Invoke table handler(OZF_CLAIMS_INT_PKG.Insert_Row)
   OZF_CLAIMS_INT_PKG.Insert_Row(
       px_interface_claim_id  => l_interface_claim_id,
       px_object_version_number  => l_object_version_number,
       p_last_update_date  => SYSDATE,
       p_last_updated_by  => FND_GLOBAL.USER_ID,
       p_creation_date  => SYSDATE,
       p_created_by  => FND_GLOBAL.USER_ID,
       p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
       p_request_id  => p_claims_int_rec.request_id,
       p_program_application_id  => p_claims_int_rec.program_application_id,
       p_program_update_date  => p_claims_int_rec.program_update_date,
       p_program_id  => p_claims_int_rec.program_id,
       p_created_from  => p_claims_int_rec.created_from,
       p_batch_id  => p_claims_int_rec.batch_id,
       p_claim_id  => p_claims_int_rec.claim_id,
       p_claim_number  => p_claims_int_rec.claim_number,
       p_claim_type_id  => p_claims_int_rec.claim_type_id,
       p_claim_class  => p_claims_int_rec.claim_class,
       p_claim_date  => p_claims_int_rec.claim_date,
       p_due_date  => p_claims_int_rec.due_date,
       p_owner_id  => p_claims_int_rec.owner_id,
       p_history_event  => p_claims_int_rec.history_event,
       p_history_event_date  => p_claims_int_rec.history_event_date,
       p_history_event_description  => p_claims_int_rec.history_event_description,
       p_split_from_claim_id  => p_claims_int_rec.split_from_claim_id,
       p_duplicate_claim_id  => p_claims_int_rec.duplicate_claim_id,
       p_split_date  => p_claims_int_rec.split_date,
       p_root_claim_id  => p_claims_int_rec.root_claim_id,
       p_amount  => p_claims_int_rec.amount,
       p_amount_adjusted  => p_claims_int_rec.amount_adjusted,
       p_amount_remaining  => p_claims_int_rec.amount_remaining,
       p_amount_settled  => p_claims_int_rec.amount_settled,
       p_acctd_amount  => p_claims_int_rec.acctd_amount,
       p_acctd_amount_remaining  => p_claims_int_rec.acctd_amount_remaining,
       p_tax_amount  => p_claims_int_rec.tax_amount,
       p_tax_code  => p_claims_int_rec.tax_code,
       p_tax_calculation_flag  => p_claims_int_rec.tax_calculation_flag,
       p_currency_code  => p_claims_int_rec.currency_code,
       p_exchange_rate_type  => p_claims_int_rec.exchange_rate_type,
       p_exchange_rate_date  => p_claims_int_rec.exchange_rate_date,
       p_exchange_rate  => p_claims_int_rec.exchange_rate,
       p_set_of_books_id  => p_claims_int_rec.set_of_books_id,
       p_original_claim_date  => p_claims_int_rec.original_claim_date,
       p_source_object_id  => p_claims_int_rec.source_object_id,
       p_source_object_class  => p_claims_int_rec.source_object_class,
       p_source_object_type_id  => p_claims_int_rec.source_object_type_id,
       p_source_object_number  => p_claims_int_rec.source_object_number,
       p_cust_account_id  => p_claims_int_rec.cust_account_id,
       p_cust_billto_acct_site_id  => p_claims_int_rec.cust_billto_acct_site_id,
       p_cust_shipto_acct_site_id  => p_claims_int_rec.cust_shipto_acct_site_id,
       p_location_id  => p_claims_int_rec.location_id,
       p_pay_related_account_flag  => p_claims_int_rec.pay_related_account_flag,
       p_related_cust_account_id  => p_claims_int_rec.related_cust_account_id,
       p_related_site_use_id  => p_claims_int_rec.related_site_use_id,
       p_relationship_type  => p_claims_int_rec.relationship_type,
       p_vendor_id  => p_claims_int_rec.vendor_id,
       p_vendor_site_id  => p_claims_int_rec.vendor_site_id,
       p_reason_type  => p_claims_int_rec.reason_type,
       p_reason_code_id  => p_claims_int_rec.reason_code_id,
       p_task_template_group_id  => p_claims_int_rec.task_template_group_id,
       p_status_code  => p_claims_int_rec.status_code,
       p_user_status_id  => p_claims_int_rec.user_status_id,
       p_sales_rep_id  => p_claims_int_rec.sales_rep_id,
       p_collector_id  => p_claims_int_rec.collector_id,
       p_contact_id  => p_claims_int_rec.contact_id,
       p_broker_id  => p_claims_int_rec.broker_id,
       p_territory_id  => p_claims_int_rec.territory_id,
       p_customer_ref_date  => p_claims_int_rec.customer_ref_date,
       p_customer_ref_number  => p_claims_int_rec.customer_ref_number,
       p_assigned_to  => p_claims_int_rec.assigned_to,
       p_receipt_id  => p_claims_int_rec.receipt_id,
       p_receipt_number  => p_claims_int_rec.receipt_number,
       p_doc_sequence_id  => p_claims_int_rec.doc_sequence_id,
       p_doc_sequence_value  => p_claims_int_rec.doc_sequence_value,
       p_gl_date  => p_claims_int_rec.gl_date,
       p_payment_method  => p_claims_int_rec.payment_method,
       p_voucher_id  => p_claims_int_rec.voucher_id,
       p_voucher_number  => p_claims_int_rec.voucher_number,
       p_payment_reference_id  => p_claims_int_rec.payment_reference_id,
       p_payment_reference_number  => p_claims_int_rec.payment_reference_number,
       p_payment_reference_date  => p_claims_int_rec.payment_reference_date,
       p_payment_status  => p_claims_int_rec.payment_status,
       p_approved_flag  => p_claims_int_rec.approved_flag,
       p_approved_date  => p_claims_int_rec.approved_date,
       p_approved_by  => p_claims_int_rec.approved_by,
       p_settled_date  => p_claims_int_rec.settled_date,
       p_settled_by  => p_claims_int_rec.settled_by,
       p_effective_date  => p_claims_int_rec.effective_date,
       p_custom_setup_id  => p_claims_int_rec.custom_setup_id,
       p_task_id  => p_claims_int_rec.task_id,
       p_country_id  => p_claims_int_rec.country_id,
       p_order_type_id  => p_claims_int_rec.order_type_id,
       p_comments  => p_claims_int_rec.comments,
       p_attribute_category  => p_claims_int_rec.attribute_category,
       p_attribute1  => p_claims_int_rec.attribute1,
       p_attribute2  => p_claims_int_rec.attribute2,
       p_attribute3  => p_claims_int_rec.attribute3,
       p_attribute4  => p_claims_int_rec.attribute4,
       p_attribute5  => p_claims_int_rec.attribute5,
       p_attribute6  => p_claims_int_rec.attribute6,
       p_attribute7  => p_claims_int_rec.attribute7,
       p_attribute8  => p_claims_int_rec.attribute8,
       p_attribute9  => p_claims_int_rec.attribute9,
       p_attribute10  => p_claims_int_rec.attribute10,
       p_attribute11  => p_claims_int_rec.attribute11,
       p_attribute12  => p_claims_int_rec.attribute12,
       p_attribute13  => p_claims_int_rec.attribute13,
       p_attribute14  => p_claims_int_rec.attribute14,
       p_attribute15  => p_claims_int_rec.attribute15,
       p_deduction_attribute_category  => p_claims_int_rec.deduction_attribute_category,
       p_deduction_attribute1  => p_claims_int_rec.deduction_attribute1,
       p_deduction_attribute2  => p_claims_int_rec.deduction_attribute2,
       p_deduction_attribute3  => p_claims_int_rec.deduction_attribute3,
       p_deduction_attribute4  => p_claims_int_rec.deduction_attribute4,
       p_deduction_attribute5  => p_claims_int_rec.deduction_attribute5,
       p_deduction_attribute6  => p_claims_int_rec.deduction_attribute6,
       p_deduction_attribute7  => p_claims_int_rec.deduction_attribute7,
       p_deduction_attribute8  => p_claims_int_rec.deduction_attribute8,
       p_deduction_attribute9  => p_claims_int_rec.deduction_attribute9,
       p_deduction_attribute10  => p_claims_int_rec.deduction_attribute10,
       p_deduction_attribute11  => p_claims_int_rec.deduction_attribute11,
       p_deduction_attribute12  => p_claims_int_rec.deduction_attribute12,
       p_deduction_attribute13  => p_claims_int_rec.deduction_attribute13,
       p_deduction_attribute14  => p_claims_int_rec.deduction_attribute14,
       p_deduction_attribute15  => p_claims_int_rec.deduction_attribute15,
       px_org_id  => l_org_id,
       p_customer_reason  => p_claims_int_rec.customer_reason,
       p_ship_to_cust_account_id  => p_claims_int_rec.ship_to_cust_account_id
       );
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
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
EXCEPTION
   WHEN OZF_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
      OZF_Utility_PVT.Error_Message(p_message_name =>'OZF_API_RESOURCE_LOCKED');
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_Claims_Int_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_Claims_Int_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO CREATE_Claims_Int_PVT;
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
End Create_Claims_Int;

PROCEDURE Update_Claims_Int(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status          OUT NOCOPY  VARCHAR2,
    x_msg_count              OUT NOCOPY  NUMBER,
    x_msg_data               OUT NOCOPY  VARCHAR2,

    p_claims_int_rec         IN   claims_int_rec_type,
    x_object_version_number  OUT NOCOPY  NUMBER
)
IS

CURSOR c_get_claims_int(p_interface_claim_id NUMBER) IS
    SELECT *
    FROM   OZF_CLAIMS_INT_ALL
    WHERE  interface_claim_id = p_interface_claim_id;

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Claims_Int';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;

-- Local Variables
l_object_version_number     NUMBER;
l_INTERFACE_CLAIM_ID    NUMBER;
l_ref_claims_int_rec  c_get_Claims_Int%ROWTYPE ;
l_tar_claims_int_rec  OZF_Claims_Int_PVT.claims_int_rec_type := P_claims_int_rec;
l_rowid  ROWID;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT UPDATE_Claims_Int_PVT;

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
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');
   END IF;

   /*
   OPEN c_get_Claims_Int( l_tar_claims_int_rec.interface_claim_id);

   FETCH c_get_Claims_Int INTO l_ref_claims_int_rec  ;

   If ( c_get_Claims_Int%NOTFOUND) THEN
        OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RECORD_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
   END IF;
   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('Private API: - Close Cursor');
   END IF;
   CLOSE     c_get_Claims_Int;
   */

   IF (l_tar_claims_int_rec.object_version_number IS NULL OR
       l_tar_claims_int_rec.object_version_number = FND_API.G_MISS_NUM )
   THEN
       OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_NO_OBJ_VER_NUM');
       raise FND_API.G_EXC_ERROR;
   END IF;

   -- Check Whether record has been changed by someone else
   IF (l_tar_claims_int_rec.object_version_number <> l_ref_claims_int_rec.object_version_number)
   THEN
       OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');
       raise FND_API.G_EXC_ERROR;
   END IF;

   IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
   THEN
       -- Debug message
       IF OZF_DEBUG_HIGH_ON THEN
          OZF_UTILITY_PVT.debug_message('Private API: Validate_Claims_Int');
       END IF;
       -- Invoke validation procedures
       Validate_claims_int(
         p_api_version_number  => 1.0,
         p_init_msg_list       => FND_API.G_FALSE,
         p_validation_level    => p_validation_level,
         p_claims_int_rec      =>  p_claims_int_rec,
         x_return_status       => x_return_status,
         x_msg_count           => x_msg_count,
         x_msg_data            => x_msg_data);
   END IF;

   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'Private API: Calling update table handler');
   END IF;

   -- Invoke table handler(OZF_CLAIMS_INT_PKG.Update_Row)
   OZF_CLAIMS_INT_PKG.Update_Row(
       p_interface_claim_id  => p_claims_int_rec.interface_claim_id,
       p_object_version_number  => p_claims_int_rec.object_version_number,
       p_last_update_date  => SYSDATE,
       p_last_updated_by  => FND_GLOBAL.USER_ID,
       p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
       p_request_id  => p_claims_int_rec.request_id,
       p_program_application_id  => p_claims_int_rec.program_application_id,
       p_program_update_date  => p_claims_int_rec.program_update_date,
       p_program_id  => p_claims_int_rec.program_id,
       p_created_from  => p_claims_int_rec.created_from,
       p_batch_id  => p_claims_int_rec.batch_id,
       p_claim_id  => p_claims_int_rec.claim_id,
       p_claim_number  => p_claims_int_rec.claim_number,
       p_claim_type_id  => p_claims_int_rec.claim_type_id,
       p_claim_class  => p_claims_int_rec.claim_class,
       p_claim_date  => p_claims_int_rec.claim_date,
       p_due_date  => p_claims_int_rec.due_date,
       p_owner_id  => p_claims_int_rec.owner_id,
       p_history_event  => p_claims_int_rec.history_event,
       p_history_event_date  => p_claims_int_rec.history_event_date,
       p_history_event_description  => p_claims_int_rec.history_event_description,
       p_split_from_claim_id  => p_claims_int_rec.split_from_claim_id,
       p_duplicate_claim_id  => p_claims_int_rec.duplicate_claim_id,
       p_split_date  => p_claims_int_rec.split_date,
       p_root_claim_id  => p_claims_int_rec.root_claim_id,
       p_amount  => p_claims_int_rec.amount,
       p_amount_adjusted  => p_claims_int_rec.amount_adjusted,
       p_amount_remaining  => p_claims_int_rec.amount_remaining,
       p_amount_settled  => p_claims_int_rec.amount_settled,
       p_acctd_amount  => p_claims_int_rec.acctd_amount,
       p_acctd_amount_remaining  => p_claims_int_rec.acctd_amount_remaining,
       p_tax_amount  => p_claims_int_rec.tax_amount,
       p_tax_code  => p_claims_int_rec.tax_code,
       p_tax_calculation_flag  => p_claims_int_rec.tax_calculation_flag,
       p_currency_code  => p_claims_int_rec.currency_code,
       p_exchange_rate_type  => p_claims_int_rec.exchange_rate_type,
       p_exchange_rate_date  => p_claims_int_rec.exchange_rate_date,
       p_exchange_rate  => p_claims_int_rec.exchange_rate,
       p_set_of_books_id  => p_claims_int_rec.set_of_books_id,
       p_original_claim_date  => p_claims_int_rec.original_claim_date,
       p_source_object_id  => p_claims_int_rec.source_object_id,
       p_source_object_class  => p_claims_int_rec.source_object_class,
       p_source_object_type_id  => p_claims_int_rec.source_object_type_id,
       p_source_object_number  => p_claims_int_rec.source_object_number,
       p_cust_account_id  => p_claims_int_rec.cust_account_id,
       p_cust_billto_acct_site_id  => p_claims_int_rec.cust_billto_acct_site_id,
       p_cust_shipto_acct_site_id  => p_claims_int_rec.cust_shipto_acct_site_id,
       p_location_id  => p_claims_int_rec.location_id,
       p_pay_related_account_flag  => p_claims_int_rec.pay_related_account_flag,
       p_related_cust_account_id  => p_claims_int_rec.related_cust_account_id,
       p_related_site_use_id  => p_claims_int_rec.related_site_use_id,
       p_relationship_type  => p_claims_int_rec.relationship_type,
       p_vendor_id  => p_claims_int_rec.vendor_id,
       p_vendor_site_id  => p_claims_int_rec.vendor_site_id,
       p_reason_type  => p_claims_int_rec.reason_type,
       p_reason_code_id  => p_claims_int_rec.reason_code_id,
       p_task_template_group_id  => p_claims_int_rec.task_template_group_id,
       p_status_code  => p_claims_int_rec.status_code,
       p_user_status_id  => p_claims_int_rec.user_status_id,
       p_sales_rep_id  => p_claims_int_rec.sales_rep_id,
       p_collector_id  => p_claims_int_rec.collector_id,
       p_contact_id  => p_claims_int_rec.contact_id,
       p_broker_id  => p_claims_int_rec.broker_id,
       p_territory_id  => p_claims_int_rec.territory_id,
       p_customer_ref_date  => p_claims_int_rec.customer_ref_date,
       p_customer_ref_number  => p_claims_int_rec.customer_ref_number,
       p_assigned_to  => p_claims_int_rec.assigned_to,
       p_receipt_id  => p_claims_int_rec.receipt_id,
       p_receipt_number  => p_claims_int_rec.receipt_number,
       p_doc_sequence_id  => p_claims_int_rec.doc_sequence_id,
       p_doc_sequence_value  => p_claims_int_rec.doc_sequence_value,
       p_gl_date  => p_claims_int_rec.gl_date,
       p_payment_method  => p_claims_int_rec.payment_method,
       p_voucher_id  => p_claims_int_rec.voucher_id,
       p_voucher_number  => p_claims_int_rec.voucher_number,
       p_payment_reference_id  => p_claims_int_rec.payment_reference_id,
       p_payment_reference_number  => p_claims_int_rec.payment_reference_number,
       p_payment_reference_date  => p_claims_int_rec.payment_reference_date,
       p_payment_status  => p_claims_int_rec.payment_status,
       p_approved_flag  => p_claims_int_rec.approved_flag,
       p_approved_date  => p_claims_int_rec.approved_date,
       p_approved_by  => p_claims_int_rec.approved_by,
       p_settled_date  => p_claims_int_rec.settled_date,
       p_settled_by  => p_claims_int_rec.settled_by,
       p_effective_date  => p_claims_int_rec.effective_date,
       p_custom_setup_id  => p_claims_int_rec.custom_setup_id,
       p_task_id  => p_claims_int_rec.task_id,
       p_country_id  => p_claims_int_rec.country_id,
       p_order_type_id  => p_claims_int_rec.order_type_id,
       p_comments  => p_claims_int_rec.comments,
       p_attribute_category  => p_claims_int_rec.attribute_category,
       p_attribute1  => p_claims_int_rec.attribute1,
       p_attribute2  => p_claims_int_rec.attribute2,
       p_attribute3  => p_claims_int_rec.attribute3,
       p_attribute4  => p_claims_int_rec.attribute4,
       p_attribute5  => p_claims_int_rec.attribute5,
       p_attribute6  => p_claims_int_rec.attribute6,
       p_attribute7  => p_claims_int_rec.attribute7,
       p_attribute8  => p_claims_int_rec.attribute8,
       p_attribute9  => p_claims_int_rec.attribute9,
       p_attribute10  => p_claims_int_rec.attribute10,
       p_attribute11  => p_claims_int_rec.attribute11,
       p_attribute12  => p_claims_int_rec.attribute12,
       p_attribute13  => p_claims_int_rec.attribute13,
       p_attribute14  => p_claims_int_rec.attribute14,
       p_attribute15  => p_claims_int_rec.attribute15,
       p_deduction_attribute_category  => p_claims_int_rec.deduction_attribute_category,
       p_deduction_attribute1  => p_claims_int_rec.deduction_attribute1,
       p_deduction_attribute2  => p_claims_int_rec.deduction_attribute2,
       p_deduction_attribute3  => p_claims_int_rec.deduction_attribute3,
       p_deduction_attribute4  => p_claims_int_rec.deduction_attribute4,
       p_deduction_attribute5  => p_claims_int_rec.deduction_attribute5,
       p_deduction_attribute6  => p_claims_int_rec.deduction_attribute6,
       p_deduction_attribute7  => p_claims_int_rec.deduction_attribute7,
       p_deduction_attribute8  => p_claims_int_rec.deduction_attribute8,
       p_deduction_attribute9  => p_claims_int_rec.deduction_attribute9,
       p_deduction_attribute10  => p_claims_int_rec.deduction_attribute10,
       p_deduction_attribute11  => p_claims_int_rec.deduction_attribute11,
       p_deduction_attribute12  => p_claims_int_rec.deduction_attribute12,
       p_deduction_attribute13  => p_claims_int_rec.deduction_attribute13,
       p_deduction_attribute14  => p_claims_int_rec.deduction_attribute14,
       p_deduction_attribute15  => p_claims_int_rec.deduction_attribute15,
       p_org_id  => p_claims_int_rec.org_id,
       p_customer_reason  => p_claims_int_rec.customer_reason,
       p_ship_to_cust_account_id  => p_claims_int_rec.ship_to_cust_account_id
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
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
EXCEPTION
   WHEN OZF_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
      OZF_Utility_PVT.Error_Message(p_message_name =>'OZF_API_RESOURCE_LOCKED');
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_Claims_Int_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_Claims_Int_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO UPDATE_Claims_Int_PVT;
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
End Update_Claims_Int;

PROCEDURE Delete_Claims_Int(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_interface_claim_id         IN   NUMBER,
    p_object_version_number      IN   NUMBER
)
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Claims_Int';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT DELETE_Claims_Int_PVT;

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
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Api body
   --
   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
   END IF;

   -- Invoke table handler(OZF_CLAIMS_INT_PKG.Delete_Row)
   OZF_CLAIMS_INT_PKG.Delete_Row(
       p_INTERFACE_CLAIM_ID  => p_INTERFACE_CLAIM_ID);
   --
   -- End of API body
   --

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
EXCEPTION
   WHEN OZF_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
      OZF_Utility_PVT.Error_Message(p_message_name =>'OZF_API_RESOURCE_LOCKED');
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO DELETE_Claims_Int_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO DELETE_Claims_Int_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO DELETE_Claims_Int_PVT;
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
End Delete_Claims_Int;

PROCEDURE Lock_Claims_Int(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_interface_claim_id         IN  NUMBER,
    p_object_version             IN  NUMBER
)
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Claims_Int';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_INTERFACE_CLAIM_ID                  NUMBER;

CURSOR c_Claims_Int IS
   SELECT INTERFACE_CLAIM_ID
   FROM OZF_CLAIMS_INT_ALL
   WHERE INTERFACE_CLAIM_ID = p_INTERFACE_CLAIM_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;
BEGIN
   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;

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
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;
   OPEN c_Claims_Int;
      FETCH c_Claims_Int INTO l_INTERFACE_CLAIM_ID;
      IF (c_Claims_Int%NOTFOUND) THEN
         CLOSE c_Claims_Int;

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      END IF;
   CLOSE c_Claims_Int;
   -------------------- finish --------------------------

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data);
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

EXCEPTION
   WHEN OZF_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
      OZF_Utility_PVT.Error_Message(p_message_name =>'OZF_API_RESOURCE_LOCKED');
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO LOCK_Claims_Int_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO LOCK_Claims_Int_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO LOCK_Claims_Int_PVT;
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
End Lock_Claims_Int;

PROCEDURE check_claims_int_uk_items(
    p_claims_int_rec               IN   claims_int_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      l_valid_flag := OZF_Utility_PVT.check_uniqueness(
      'OZF_CLAIMS_INT_ALL',
      'INTERFACE_CLAIM_ID = ''' || p_claims_int_rec.INTERFACE_CLAIM_ID ||''''
      );
   ELSE
      l_valid_flag := OZF_Utility_PVT.check_uniqueness(
      'OZF_CLAIMS_INT_ALL',
      'INTERFACE_CLAIM_ID = ''' || p_claims_int_rec.INTERFACE_CLAIM_ID ||
      ''' AND INTERFACE_CLAIM_ID <> ' || p_claims_int_rec.INTERFACE_CLAIM_ID
      );
   END IF;

   IF l_valid_flag = FND_API.g_false THEN
      OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_INTERFACE_CLAIM_ID_DUP');
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
END check_claims_int_uk_items;

PROCEDURE check_claims_int_req_items(
    p_claims_int_rec               IN  claims_int_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      IF p_claims_int_rec.interface_claim_id = FND_API.g_miss_num OR
         p_claims_int_rec.interface_claim_id IS NULL
      THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'INTERFACE_CLAIM_ID' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_claims_int_rec.object_version_number = FND_API.g_miss_num OR
         p_claims_int_rec.object_version_number IS NULL
      THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_VERSION_NUMBER' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_claims_int_rec.last_update_date = FND_API.g_miss_date OR
         p_claims_int_rec.last_update_date IS NULL
      THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'LAST_UPDATE_DATE' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_claims_int_rec.last_updated_by = FND_API.g_miss_num OR
         p_claims_int_rec.last_updated_by IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'LAST_UPDATED_BY' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_claims_int_rec.creation_date = FND_API.g_miss_date OR
         p_claims_int_rec.creation_date IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'CREATION_DATE' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_claims_int_rec.created_by = FND_API.g_miss_num OR
         p_claims_int_rec.created_by IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'CREATED_BY' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_claims_int_rec.claim_type_id = FND_API.g_miss_num OR
         p_claims_int_rec.claim_type_id IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'CLAIM_TYPE_ID' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_claims_int_rec.claim_date = FND_API.g_miss_date OR
         p_claims_int_rec.claim_date IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'CLAIM_DATE' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_claims_int_rec.cust_account_id = FND_API.g_miss_num OR
         p_claims_int_rec.cust_account_id IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'CUST_ACCOUNT_ID' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE
      IF p_claims_int_rec.interface_claim_id IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'INTERFACE_CLAIM_ID' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_claims_int_rec.object_version_number IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_VERSION_NUMBER' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_claims_int_rec.last_update_date IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'LAST_UPDATE_DATE' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_claims_int_rec.last_updated_by IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'LAST_UPDATED_BY' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_claims_int_rec.creation_date IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'CREATION_DATE' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_claims_int_rec.created_by IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'CREATED_BY' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_claims_int_rec.claim_type_id IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'CLAIM_TYPE_ID' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_claims_int_rec.claim_date IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'CLAIM_DATE' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_claims_int_rec.cust_account_id IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'CUST_ACCOUNT_ID' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_claims_int_req_items;

PROCEDURE check_claims_int_FK_items(
    p_claims_int_rec IN claims_int_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_claims_int_FK_items;

PROCEDURE check_claims_int_Lk_items(
    p_claims_int_rec IN claims_int_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_claims_int_Lk_items;

PROCEDURE Check_claims_int_Items (
    P_claims_int_rec     IN    claims_int_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls
   check_claims_int_uk_items(
      p_claims_int_rec => p_claims_int_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls
   check_claims_int_req_items(
      p_claims_int_rec => p_claims_int_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Foreign Keys API calls
   check_claims_int_FK_items(
      p_claims_int_rec => p_claims_int_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Lookups
   check_claims_int_Lk_items(
      p_claims_int_rec => p_claims_int_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_claims_int_Items;

PROCEDURE Complete_claims_int_Rec (
   p_claims_int_rec IN claims_int_rec_type,
   x_complete_rec OUT NOCOPY claims_int_rec_type)
IS
l_return_status  VARCHAR2(1);

CURSOR c_complete IS
  SELECT *
  FROM ozf_claims_int_all
  WHERE interface_claim_id = p_claims_int_rec.interface_claim_id;

l_claims_int_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_claims_int_rec;

   OPEN c_complete;
   FETCH c_complete INTO l_claims_int_rec;
   CLOSE c_complete;

   -- interface_claim_id
   IF p_claims_int_rec.interface_claim_id = FND_API.g_miss_num THEN
      x_complete_rec.interface_claim_id := NULL;
   END IF;
   IF p_claims_int_rec.interface_claim_id IS NULL THEN
      x_complete_rec.interface_claim_id := l_claims_int_rec.interface_claim_id;
   END IF;

   -- object_version_number
   IF p_claims_int_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := NULL;
   END IF;
   IF p_claims_int_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_claims_int_rec.object_version_number;
   END IF;

   -- last_update_date
   IF p_claims_int_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := NULL;
   END IF;
   IF p_claims_int_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_claims_int_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_claims_int_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := NULL;
   END IF;
   IF p_claims_int_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_claims_int_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_claims_int_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := NULL;
   END IF;
   IF p_claims_int_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_claims_int_rec.creation_date;
   END IF;

   -- created_by
   IF p_claims_int_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := NULL;
   END IF;
   IF p_claims_int_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_claims_int_rec.created_by;
   END IF;

   -- last_update_login
   IF p_claims_int_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := NULL;
   END IF;
   IF p_claims_int_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_claims_int_rec.last_update_login;
   END IF;

   -- request_id
   IF p_claims_int_rec.request_id = FND_API.g_miss_num THEN
      x_complete_rec.request_id := NULL;
   END IF;
   IF p_claims_int_rec.request_id IS NULL THEN
      x_complete_rec.request_id := l_claims_int_rec.request_id;
   END IF;

   -- program_application_id
   IF p_claims_int_rec.program_application_id = FND_API.g_miss_num THEN
      x_complete_rec.program_application_id := NULL;
   END IF;
   IF p_claims_int_rec.program_application_id IS NULL THEN
      x_complete_rec.program_application_id := l_claims_int_rec.program_application_id;
   END IF;

   -- program_update_date
   IF p_claims_int_rec.program_update_date = FND_API.g_miss_date THEN
      x_complete_rec.program_update_date := NULL;
   END IF;
   IF p_claims_int_rec.program_update_date IS NULL THEN
      x_complete_rec.program_update_date := l_claims_int_rec.program_update_date;
   END IF;

   -- program_id
   IF p_claims_int_rec.program_id = FND_API.g_miss_num THEN
      x_complete_rec.program_id := NULL;
   END IF;
   IF p_claims_int_rec.program_id IS NULL THEN
      x_complete_rec.program_id := l_claims_int_rec.program_id;
   END IF;

   -- created_from
   IF p_claims_int_rec.created_from = FND_API.g_miss_char THEN
      x_complete_rec.created_from := NULL;
   END IF;
   IF p_claims_int_rec.created_from IS NULL THEN
      x_complete_rec.created_from := l_claims_int_rec.created_from;
   END IF;

   -- batch_id
   IF p_claims_int_rec.batch_id = FND_API.g_miss_num THEN
      x_complete_rec.batch_id := NULL;
   END IF;
   IF p_claims_int_rec.batch_id IS NULL THEN
      x_complete_rec.batch_id := l_claims_int_rec.batch_id;
   END IF;

   -- claim_id
   IF p_claims_int_rec.claim_id = FND_API.g_miss_num THEN
      x_complete_rec.claim_id := NULL;
   END IF;
   IF p_claims_int_rec.claim_id IS NULL THEN
      x_complete_rec.claim_id := l_claims_int_rec.claim_id;
   END IF;

   -- claim_number
   IF p_claims_int_rec.claim_number = FND_API.g_miss_char THEN
      x_complete_rec.claim_number := NULL;
   END IF;
   IF p_claims_int_rec.claim_number IS NULL THEN
      x_complete_rec.claim_number := l_claims_int_rec.claim_number;
   END IF;

   -- claim_type_id
   IF p_claims_int_rec.claim_type_id = FND_API.g_miss_num THEN
      x_complete_rec.claim_type_id := NULL;
   END IF;
   IF p_claims_int_rec.claim_type_id IS NULL THEN
      x_complete_rec.claim_type_id := l_claims_int_rec.claim_type_id;
   END IF;

   -- claim_class
   IF p_claims_int_rec.claim_class = FND_API.g_miss_char THEN
      x_complete_rec.claim_class := NULL;
   END IF;
   IF p_claims_int_rec.claim_class IS NULL THEN
      x_complete_rec.claim_class := l_claims_int_rec.claim_class;
   END IF;

   -- claim_date
   IF p_claims_int_rec.claim_date = FND_API.g_miss_date THEN
      x_complete_rec.claim_date := NULL;
   END IF;
   IF p_claims_int_rec.claim_date IS NULL THEN
      x_complete_rec.claim_date := l_claims_int_rec.claim_date;
   END IF;

   -- due_date
   IF p_claims_int_rec.due_date = FND_API.g_miss_date THEN
      x_complete_rec.due_date := NULL;
   END IF;
   IF p_claims_int_rec.due_date IS NULL THEN
      x_complete_rec.due_date := l_claims_int_rec.due_date;
   END IF;

   -- owner_id
   IF p_claims_int_rec.owner_id = FND_API.g_miss_num THEN
      x_complete_rec.owner_id := NULL;
   END IF;
   IF p_claims_int_rec.owner_id IS NULL THEN
      x_complete_rec.owner_id := l_claims_int_rec.owner_id;
   END IF;

   -- history_event
   IF p_claims_int_rec.history_event = FND_API.g_miss_char THEN
      x_complete_rec.history_event := NULL;
   END IF;
   IF p_claims_int_rec.history_event IS NULL THEN
      x_complete_rec.history_event := l_claims_int_rec.history_event;
   END IF;

   -- history_event_date
   IF p_claims_int_rec.history_event_date = FND_API.g_miss_date THEN
      x_complete_rec.history_event_date := NULL;
   END IF;
   IF p_claims_int_rec.history_event_date IS NULL THEN
      x_complete_rec.history_event_date := l_claims_int_rec.history_event_date;
   END IF;

   -- history_event_description
   IF p_claims_int_rec.history_event_description = FND_API.g_miss_char THEN
      x_complete_rec.history_event_description := NULL;
   END IF;
   IF p_claims_int_rec.history_event_description IS NULL THEN
      x_complete_rec.history_event_description := l_claims_int_rec.history_event_description;
   END IF;

   -- split_from_claim_id
   IF p_claims_int_rec.split_from_claim_id = FND_API.g_miss_num THEN
      x_complete_rec.split_from_claim_id := NULL;
   END IF;
   IF p_claims_int_rec.split_from_claim_id IS NULL THEN
      x_complete_rec.split_from_claim_id := l_claims_int_rec.split_from_claim_id;
   END IF;

   -- duplicate_claim_id
   IF p_claims_int_rec.duplicate_claim_id = FND_API.g_miss_num THEN
      x_complete_rec.duplicate_claim_id := NULL;
   END IF;
   IF p_claims_int_rec.duplicate_claim_id IS NULL THEN
      x_complete_rec.duplicate_claim_id := l_claims_int_rec.duplicate_claim_id;
   END IF;

   -- split_date
   IF p_claims_int_rec.split_date = FND_API.g_miss_date THEN
      x_complete_rec.split_date := NULL;
   END IF;
   IF p_claims_int_rec.split_date IS NULL THEN
      x_complete_rec.split_date := l_claims_int_rec.split_date;
   END IF;

   -- root_claim_id
   IF p_claims_int_rec.root_claim_id = FND_API.g_miss_num THEN
      x_complete_rec.root_claim_id := NULL;
   END IF;
   IF p_claims_int_rec.root_claim_id IS NULL THEN
      x_complete_rec.root_claim_id := l_claims_int_rec.root_claim_id;
   END IF;

   -- amount
   IF p_claims_int_rec.amount = FND_API.g_miss_num THEN
      x_complete_rec.amount := NULL;
   END IF;
   IF p_claims_int_rec.amount IS NULL THEN
      x_complete_rec.amount := l_claims_int_rec.amount;
   END IF;

   -- amount_adjusted
   IF p_claims_int_rec.amount_adjusted = FND_API.g_miss_num THEN
      x_complete_rec.amount_adjusted := NULL;
   END IF;
   IF p_claims_int_rec.amount_adjusted IS NULL THEN
      x_complete_rec.amount_adjusted := l_claims_int_rec.amount_adjusted;
   END IF;

   -- amount_remaining
   IF p_claims_int_rec.amount_remaining = FND_API.g_miss_num THEN
      x_complete_rec.amount_remaining := NULL;
   END IF;
   IF p_claims_int_rec.amount_remaining IS NULL THEN
      x_complete_rec.amount_remaining := l_claims_int_rec.amount_remaining;
   END IF;

   -- amount_settled
   IF p_claims_int_rec.amount_settled = FND_API.g_miss_num THEN
      x_complete_rec.amount_settled := NULL;
   END IF;
   IF p_claims_int_rec.amount_settled IS NULL THEN
      x_complete_rec.amount_settled := l_claims_int_rec.amount_settled;
   END IF;

   -- acctd_amount
   IF p_claims_int_rec.acctd_amount = FND_API.g_miss_num THEN
      x_complete_rec.acctd_amount := NULL;
   END IF;
   IF p_claims_int_rec.acctd_amount IS NULL THEN
      x_complete_rec.acctd_amount := l_claims_int_rec.acctd_amount;
   END IF;

   -- acctd_amount_remaining
   IF p_claims_int_rec.acctd_amount_remaining = FND_API.g_miss_num THEN
      x_complete_rec.acctd_amount_remaining := NULL;
   END IF;
   IF p_claims_int_rec.acctd_amount_remaining IS NULL THEN
      x_complete_rec.acctd_amount_remaining := l_claims_int_rec.acctd_amount_remaining;
   END IF;

   -- tax_amount
   IF p_claims_int_rec.tax_amount = FND_API.g_miss_num THEN
      x_complete_rec.tax_amount := NULL;
   END IF;
   IF p_claims_int_rec.tax_amount IS NULL THEN
      x_complete_rec.tax_amount := l_claims_int_rec.tax_amount;
   END IF;

   -- tax_code
   IF p_claims_int_rec.tax_code = FND_API.g_miss_char THEN
      x_complete_rec.tax_code := NULL;
   END IF;
   IF p_claims_int_rec.tax_code IS NULL THEN
      x_complete_rec.tax_code := l_claims_int_rec.tax_code;
   END IF;

   -- tax_calculation_flag
   IF p_claims_int_rec.tax_calculation_flag = FND_API.g_miss_char THEN
      x_complete_rec.tax_calculation_flag := NULL;
   END IF;
   IF p_claims_int_rec.tax_calculation_flag IS NULL THEN
      x_complete_rec.tax_calculation_flag := l_claims_int_rec.tax_calculation_flag;
   END IF;

   -- currency_code
   IF p_claims_int_rec.currency_code = FND_API.g_miss_char THEN
      x_complete_rec.currency_code := NULL;
   END IF;
   IF p_claims_int_rec.currency_code IS NULL THEN
      x_complete_rec.currency_code := l_claims_int_rec.currency_code;
   END IF;

   -- exchange_rate_type
   IF p_claims_int_rec.exchange_rate_type = FND_API.g_miss_char THEN
      x_complete_rec.exchange_rate_type := NULL;
   END IF;
   IF p_claims_int_rec.exchange_rate_type IS NULL THEN
      x_complete_rec.exchange_rate_type := l_claims_int_rec.exchange_rate_type;
   END IF;

   -- exchange_rate_date
   IF p_claims_int_rec.exchange_rate_date = FND_API.g_miss_date THEN
      x_complete_rec.exchange_rate_date := NULL;
   END IF;
   IF p_claims_int_rec.exchange_rate_date IS NULL THEN
      x_complete_rec.exchange_rate_date := l_claims_int_rec.exchange_rate_date;
   END IF;

   -- exchange_rate
   IF p_claims_int_rec.exchange_rate = FND_API.g_miss_num THEN
      x_complete_rec.exchange_rate := NULL;
   END IF;
   IF p_claims_int_rec.exchange_rate IS NULL THEN
      x_complete_rec.exchange_rate := l_claims_int_rec.exchange_rate;
   END IF;

   -- set_of_books_id
   IF p_claims_int_rec.set_of_books_id = FND_API.g_miss_num THEN
      x_complete_rec.set_of_books_id := NULL;
   END IF;
   IF p_claims_int_rec.set_of_books_id IS NULL THEN
      x_complete_rec.set_of_books_id := l_claims_int_rec.set_of_books_id;
   END IF;

   -- original_claim_date
   IF p_claims_int_rec.original_claim_date = FND_API.g_miss_date THEN
      x_complete_rec.original_claim_date := NULL;
   END IF;
   IF p_claims_int_rec.original_claim_date IS NULL THEN
      x_complete_rec.original_claim_date := l_claims_int_rec.original_claim_date;
   END IF;

   -- source_object_id
   IF p_claims_int_rec.source_object_id = FND_API.g_miss_num THEN
      x_complete_rec.source_object_id := NULL;
   END IF;
   IF p_claims_int_rec.source_object_id IS NULL THEN
      x_complete_rec.source_object_id := l_claims_int_rec.source_object_id;
   END IF;

   -- source_object_class
   IF p_claims_int_rec.source_object_class = FND_API.g_miss_char THEN
      x_complete_rec.source_object_class := NULL;
   END IF;
   IF p_claims_int_rec.source_object_class IS NULL THEN
      x_complete_rec.source_object_class := l_claims_int_rec.source_object_class;
   END IF;

   -- source_object_type_id
   IF p_claims_int_rec.source_object_type_id = FND_API.g_miss_num THEN
      x_complete_rec.source_object_type_id := NULL;
   END IF;
   IF p_claims_int_rec.source_object_type_id IS NULL THEN
      x_complete_rec.source_object_type_id := l_claims_int_rec.source_object_type_id;
   END IF;

   -- source_object_number
   IF p_claims_int_rec.source_object_number = FND_API.g_miss_char THEN
      x_complete_rec.source_object_number := NULL;
   END IF;
   IF p_claims_int_rec.source_object_number IS NULL THEN
      x_complete_rec.source_object_number := l_claims_int_rec.source_object_number;
   END IF;

   -- cust_account_id
   IF p_claims_int_rec.cust_account_id = FND_API.g_miss_num THEN
      x_complete_rec.cust_account_id := NULL;
   END IF;
   IF p_claims_int_rec.cust_account_id IS NULL THEN
      x_complete_rec.cust_account_id := l_claims_int_rec.cust_account_id;
   END IF;

   -- cust_billto_acct_site_id
   IF p_claims_int_rec.cust_billto_acct_site_id = FND_API.g_miss_num THEN
      x_complete_rec.cust_billto_acct_site_id := NULL;
   END IF;
   IF p_claims_int_rec.cust_billto_acct_site_id IS NULL THEN
      x_complete_rec.cust_billto_acct_site_id := l_claims_int_rec.cust_billto_acct_site_id;
   END IF;

   -- cust_shipto_acct_site_id
   IF p_claims_int_rec.cust_shipto_acct_site_id = FND_API.g_miss_num THEN
      x_complete_rec.cust_shipto_acct_site_id := NULL;
   END IF;
   IF p_claims_int_rec.cust_shipto_acct_site_id IS NULL THEN
      x_complete_rec.cust_shipto_acct_site_id := l_claims_int_rec.cust_shipto_acct_site_id;
   END IF;

   -- location_id
   IF p_claims_int_rec.location_id = FND_API.g_miss_num THEN
      x_complete_rec.location_id := NULL;
   END IF;
   IF p_claims_int_rec.location_id IS NULL THEN
      x_complete_rec.location_id := l_claims_int_rec.location_id;
   END IF;

   -- pay_related_account_flag
   IF p_claims_int_rec.pay_related_account_flag = FND_API.g_miss_char THEN
      x_complete_rec.pay_related_account_flag := NULL;
   END IF;
   IF p_claims_int_rec.pay_related_account_flag IS NULL THEN
      x_complete_rec.pay_related_account_flag := l_claims_int_rec.pay_related_account_flag;
   END IF;

   -- related_cust_account_id
   IF p_claims_int_rec.related_cust_account_id = FND_API.g_miss_num THEN
      x_complete_rec.related_cust_account_id := NULL;
   END IF;
   IF p_claims_int_rec.related_cust_account_id IS NULL THEN
      x_complete_rec.related_cust_account_id := l_claims_int_rec.related_cust_account_id;
   END IF;

   -- related_site_use_id
   IF p_claims_int_rec.related_site_use_id = FND_API.g_miss_num THEN
      x_complete_rec.related_site_use_id := NULL;
   END IF;
   IF p_claims_int_rec.related_site_use_id IS NULL THEN
      x_complete_rec.related_site_use_id := l_claims_int_rec.related_site_use_id;
   END IF;

   -- relationship_type
   IF p_claims_int_rec.relationship_type = FND_API.g_miss_char THEN
      x_complete_rec.relationship_type := NULL;
   END IF;
   IF p_claims_int_rec.relationship_type IS NULL THEN
      x_complete_rec.relationship_type := l_claims_int_rec.relationship_type;
   END IF;

   -- vendor_id
   IF p_claims_int_rec.vendor_id = FND_API.g_miss_num THEN
      x_complete_rec.vendor_id := NULL;
   END IF;
   IF p_claims_int_rec.vendor_id IS NULL THEN
      x_complete_rec.vendor_id := l_claims_int_rec.vendor_id;
   END IF;

   -- vendor_site_id
   IF p_claims_int_rec.vendor_site_id = FND_API.g_miss_num THEN
      x_complete_rec.vendor_site_id := NULL;
   END IF;
   IF p_claims_int_rec.vendor_site_id IS NULL THEN
      x_complete_rec.vendor_site_id := l_claims_int_rec.vendor_site_id;
   END IF;

   -- reason_type
   IF p_claims_int_rec.reason_type = FND_API.g_miss_char THEN
      x_complete_rec.reason_type := NULL;
   END IF;
   IF p_claims_int_rec.reason_type IS NULL THEN
      x_complete_rec.reason_type := l_claims_int_rec.reason_type;
   END IF;

   -- reason_code_id
   IF p_claims_int_rec.reason_code_id = FND_API.g_miss_num THEN
      x_complete_rec.reason_code_id := NULL;
   END IF;
   IF p_claims_int_rec.reason_code_id IS NULL THEN
      x_complete_rec.reason_code_id := l_claims_int_rec.reason_code_id;
   END IF;

   -- task_template_group_id
   IF p_claims_int_rec.task_template_group_id = FND_API.g_miss_num THEN
      x_complete_rec.task_template_group_id := NULL;
   END IF;
   IF p_claims_int_rec.task_template_group_id IS NULL THEN
      x_complete_rec.task_template_group_id := l_claims_int_rec.task_template_group_id;
   END IF;

   -- status_code
   IF p_claims_int_rec.status_code = FND_API.g_miss_char THEN
      x_complete_rec.status_code := NULL;
   END IF;
   IF p_claims_int_rec.status_code IS NULL THEN
      x_complete_rec.status_code := l_claims_int_rec.status_code;
   END IF;

   -- user_status_id
   IF p_claims_int_rec.user_status_id = FND_API.g_miss_num THEN
      x_complete_rec.user_status_id := NULL;
   END IF;
   IF p_claims_int_rec.user_status_id IS NULL THEN
      x_complete_rec.user_status_id := l_claims_int_rec.user_status_id;
   END IF;

   -- sales_rep_id
   IF p_claims_int_rec.sales_rep_id = FND_API.g_miss_num THEN
      x_complete_rec.sales_rep_id := NULL;
   END IF;
   IF p_claims_int_rec.sales_rep_id IS NULL THEN
      x_complete_rec.sales_rep_id := l_claims_int_rec.sales_rep_id;
   END IF;

   -- collector_id
   IF p_claims_int_rec.collector_id = FND_API.g_miss_num THEN
      x_complete_rec.collector_id := NULL;
   END IF;
   IF p_claims_int_rec.collector_id IS NULL THEN
      x_complete_rec.collector_id := l_claims_int_rec.collector_id;
   END IF;

   -- contact_id
   IF p_claims_int_rec.contact_id = FND_API.g_miss_num THEN
      x_complete_rec.contact_id := NULL;
   END IF;
   IF p_claims_int_rec.contact_id IS NULL THEN
      x_complete_rec.contact_id := l_claims_int_rec.contact_id;
   END IF;

   -- broker_id
   IF p_claims_int_rec.broker_id = FND_API.g_miss_num THEN
      x_complete_rec.broker_id := NULL;
   END IF;
   IF p_claims_int_rec.broker_id IS NULL THEN
      x_complete_rec.broker_id := l_claims_int_rec.broker_id;
   END IF;

   -- territory_id
   IF p_claims_int_rec.territory_id = FND_API.g_miss_num THEN
      x_complete_rec.territory_id := NULL;
   END IF;
   IF p_claims_int_rec.territory_id IS NULL THEN
      x_complete_rec.territory_id := l_claims_int_rec.territory_id;
   END IF;

   -- customer_ref_date
   IF p_claims_int_rec.customer_ref_date = FND_API.g_miss_date THEN
      x_complete_rec.customer_ref_date := NULL;
   END IF;
   IF p_claims_int_rec.customer_ref_date IS NULL THEN
      x_complete_rec.customer_ref_date := l_claims_int_rec.customer_ref_date;
   END IF;

   -- customer_ref_number
   IF p_claims_int_rec.customer_ref_number = FND_API.g_miss_char THEN
      x_complete_rec.customer_ref_number := NULL;
   END IF;
   IF p_claims_int_rec.customer_ref_number IS NULL THEN
      x_complete_rec.customer_ref_number := l_claims_int_rec.customer_ref_number;
   END IF;

   -- assigned_to
   IF p_claims_int_rec.assigned_to = FND_API.g_miss_num THEN
      x_complete_rec.assigned_to := NULL;
   END IF;
   IF p_claims_int_rec.assigned_to IS NULL THEN
      x_complete_rec.assigned_to := l_claims_int_rec.assigned_to;
   END IF;

   -- receipt_id
   IF p_claims_int_rec.receipt_id = FND_API.g_miss_num THEN
      x_complete_rec.receipt_id := NULL;
   END IF;
   IF p_claims_int_rec.receipt_id IS NULL THEN
      x_complete_rec.receipt_id := l_claims_int_rec.receipt_id;
   END IF;

   -- receipt_number
   IF p_claims_int_rec.receipt_number = FND_API.g_miss_char THEN
      x_complete_rec.receipt_number := NULL;
   END IF;
   IF p_claims_int_rec.receipt_number IS NULL THEN
      x_complete_rec.receipt_number := l_claims_int_rec.receipt_number;
   END IF;

   -- doc_sequence_id
   IF p_claims_int_rec.doc_sequence_id = FND_API.g_miss_num THEN
      x_complete_rec.doc_sequence_id := NULL;
   END IF;
   IF p_claims_int_rec.doc_sequence_id IS NULL THEN
      x_complete_rec.doc_sequence_id := l_claims_int_rec.doc_sequence_id;
   END IF;

   -- doc_sequence_value
   IF p_claims_int_rec.doc_sequence_value = FND_API.g_miss_num THEN
      x_complete_rec.doc_sequence_value := NULL;
   END IF;
   IF p_claims_int_rec.doc_sequence_value IS NULL THEN
      x_complete_rec.doc_sequence_value := l_claims_int_rec.doc_sequence_value;
   END IF;

   -- gl_date
   IF p_claims_int_rec.gl_date = FND_API.g_miss_date THEN
      x_complete_rec.gl_date := NULL;
   END IF;
   IF p_claims_int_rec.gl_date IS NULL THEN
      x_complete_rec.gl_date := l_claims_int_rec.gl_date;
   END IF;

   -- payment_method
   IF p_claims_int_rec.payment_method = FND_API.g_miss_char THEN
      x_complete_rec.payment_method := NULL;
   END IF;
   IF p_claims_int_rec.payment_method IS NULL THEN
      x_complete_rec.payment_method := l_claims_int_rec.payment_method;
   END IF;

   -- voucher_id
   IF p_claims_int_rec.voucher_id = FND_API.g_miss_num THEN
      x_complete_rec.voucher_id := NULL;
   END IF;
   IF p_claims_int_rec.voucher_id IS NULL THEN
      x_complete_rec.voucher_id := l_claims_int_rec.voucher_id;
   END IF;

   -- voucher_number
   IF p_claims_int_rec.voucher_number = FND_API.g_miss_char THEN
      x_complete_rec.voucher_number := NULL;
   END IF;
   IF p_claims_int_rec.voucher_number IS NULL THEN
      x_complete_rec.voucher_number := l_claims_int_rec.voucher_number;
   END IF;

   -- payment_reference_id
   IF p_claims_int_rec.payment_reference_id = FND_API.g_miss_num THEN
      x_complete_rec.payment_reference_id := NULL;
   END IF;
   IF p_claims_int_rec.payment_reference_id IS NULL THEN
      x_complete_rec.payment_reference_id := l_claims_int_rec.payment_reference_id;
   END IF;

   -- payment_reference_number
   IF p_claims_int_rec.payment_reference_number = FND_API.g_miss_char THEN
      x_complete_rec.payment_reference_number := NULL;
   END IF;
   IF p_claims_int_rec.payment_reference_number IS NULL THEN
      x_complete_rec.payment_reference_number := l_claims_int_rec.payment_reference_number;
   END IF;

   -- payment_reference_date
   IF p_claims_int_rec.payment_reference_date = FND_API.g_miss_date THEN
      x_complete_rec.payment_reference_date := NULL;
   END IF;
   IF p_claims_int_rec.payment_reference_date IS NULL THEN
      x_complete_rec.payment_reference_date := l_claims_int_rec.payment_reference_date;
   END IF;

   -- payment_status
   IF p_claims_int_rec.payment_status = FND_API.g_miss_char THEN
      x_complete_rec.payment_status := NULL;
   END IF;
   IF p_claims_int_rec.payment_status IS NULL THEN
      x_complete_rec.payment_status := l_claims_int_rec.payment_status;
   END IF;

   -- approved_flag
   IF p_claims_int_rec.approved_flag = FND_API.g_miss_char THEN
      x_complete_rec.approved_flag := NULL;
   END IF;
   IF p_claims_int_rec.approved_flag IS NULL THEN
      x_complete_rec.approved_flag := l_claims_int_rec.approved_flag;
   END IF;

   -- approved_date
   IF p_claims_int_rec.approved_date = FND_API.g_miss_date THEN
      x_complete_rec.approved_date := NULL;
   END IF;
   IF p_claims_int_rec.approved_date IS NULL THEN
      x_complete_rec.approved_date := l_claims_int_rec.approved_date;
   END IF;

   -- approved_by
   IF p_claims_int_rec.approved_by = FND_API.g_miss_num THEN
      x_complete_rec.approved_by := NULL;
   END IF;
   IF p_claims_int_rec.approved_by IS NULL THEN
      x_complete_rec.approved_by := l_claims_int_rec.approved_by;
   END IF;

   -- settled_date
   IF p_claims_int_rec.settled_date = FND_API.g_miss_date THEN
      x_complete_rec.settled_date := NULL;
   END IF;
   IF p_claims_int_rec.settled_date IS NULL THEN
      x_complete_rec.settled_date := l_claims_int_rec.settled_date;
   END IF;

   -- settled_by
   IF p_claims_int_rec.settled_by = FND_API.g_miss_num THEN
      x_complete_rec.settled_by := NULL;
   END IF;
   IF p_claims_int_rec.settled_by IS NULL THEN
      x_complete_rec.settled_by := l_claims_int_rec.settled_by;
   END IF;

   -- effective_date
   IF p_claims_int_rec.effective_date = FND_API.g_miss_date THEN
      x_complete_rec.effective_date := NULL;
   END IF;
   IF p_claims_int_rec.effective_date IS NULL THEN
      x_complete_rec.effective_date := l_claims_int_rec.effective_date;
   END IF;

   -- custom_setup_id
   IF p_claims_int_rec.custom_setup_id = FND_API.g_miss_num THEN
      x_complete_rec.custom_setup_id := NULL;
   END IF;
   IF p_claims_int_rec.custom_setup_id IS NULL THEN
      x_complete_rec.custom_setup_id := l_claims_int_rec.custom_setup_id;
   END IF;

   -- task_id
   IF p_claims_int_rec.task_id = FND_API.g_miss_num THEN
      x_complete_rec.task_id := NULL;
   END IF;
   IF p_claims_int_rec.task_id IS NULL THEN
      x_complete_rec.task_id := l_claims_int_rec.task_id;
   END IF;

   -- country_id
   IF p_claims_int_rec.country_id = FND_API.g_miss_num THEN
      x_complete_rec.country_id := NULL;
   END IF;
   IF p_claims_int_rec.country_id IS NULL THEN
      x_complete_rec.country_id := l_claims_int_rec.country_id;
   END IF;

   -- order_type_id
   IF p_claims_int_rec.order_type_id = FND_API.g_miss_num THEN
      x_complete_rec.order_type_id := NULL;
   END IF;
   IF p_claims_int_rec.order_type_id IS NULL THEN
      x_complete_rec.order_type_id := l_claims_int_rec.order_type_id;
   END IF;

   -- comments
   IF p_claims_int_rec.comments = FND_API.g_miss_char THEN
      x_complete_rec.comments := NULL;
   END IF;
   IF p_claims_int_rec.comments IS NULL THEN
      x_complete_rec.comments := l_claims_int_rec.comments;
   END IF;

   -- attribute_category
   IF p_claims_int_rec.attribute_category = FND_API.g_miss_char THEN
      x_complete_rec.attribute_category := NULL;
   END IF;
   IF p_claims_int_rec.attribute_category IS NULL THEN
      x_complete_rec.attribute_category := l_claims_int_rec.attribute_category;
   END IF;

   -- attribute1
   IF p_claims_int_rec.attribute1 = FND_API.g_miss_char THEN
      x_complete_rec.attribute1 := NULL;
   END IF;
   IF p_claims_int_rec.attribute1 IS NULL THEN
      x_complete_rec.attribute1 := l_claims_int_rec.attribute1;
   END IF;

   -- attribute2
   IF p_claims_int_rec.attribute2 = FND_API.g_miss_char THEN
      x_complete_rec.attribute2 := NULL;
   END IF;
   IF p_claims_int_rec.attribute2 IS NULL THEN
      x_complete_rec.attribute2 := l_claims_int_rec.attribute2;
   END IF;

   -- attribute3
   IF p_claims_int_rec.attribute3 = FND_API.g_miss_char THEN
      x_complete_rec.attribute3 := NULL;
   END IF;
   IF p_claims_int_rec.attribute3 IS NULL THEN
      x_complete_rec.attribute3 := l_claims_int_rec.attribute3;
   END IF;

   -- attribute4
   IF p_claims_int_rec.attribute4 = FND_API.g_miss_char THEN
      x_complete_rec.attribute4 := NULL;
   END IF;
   IF p_claims_int_rec.attribute4 IS NULL THEN
      x_complete_rec.attribute4 := l_claims_int_rec.attribute4;
   END IF;

   -- attribute5
   IF p_claims_int_rec.attribute5 = FND_API.g_miss_char THEN
      x_complete_rec.attribute5 := NULL;
   END IF;
   IF p_claims_int_rec.attribute5 IS NULL THEN
      x_complete_rec.attribute5 := l_claims_int_rec.attribute5;
   END IF;

   -- attribute6
   IF p_claims_int_rec.attribute6 = FND_API.g_miss_char THEN
      x_complete_rec.attribute6 := NULL;
   END IF;
   IF p_claims_int_rec.attribute6 IS NULL THEN
      x_complete_rec.attribute6 := l_claims_int_rec.attribute6;
   END IF;

   -- attribute7
   IF p_claims_int_rec.attribute7 = FND_API.g_miss_char THEN
      x_complete_rec.attribute7 := NULL;
   END IF;
   IF p_claims_int_rec.attribute7 IS NULL THEN
      x_complete_rec.attribute7 := l_claims_int_rec.attribute7;
   END IF;

   -- attribute8
   IF p_claims_int_rec.attribute8 = FND_API.g_miss_char THEN
      x_complete_rec.attribute8 := NULL;
   END IF;
   IF p_claims_int_rec.attribute8 IS NULL THEN
      x_complete_rec.attribute8 := l_claims_int_rec.attribute8;
   END IF;

   -- attribute9
   IF p_claims_int_rec.attribute9 = FND_API.g_miss_char THEN
      x_complete_rec.attribute9 := NULL;
   END IF;
   IF p_claims_int_rec.attribute9 IS NULL THEN
      x_complete_rec.attribute9 := l_claims_int_rec.attribute9;
   END IF;

   -- attribute10
   IF p_claims_int_rec.attribute10 = FND_API.g_miss_char THEN
      x_complete_rec.attribute10 := NULL;
   END IF;
   IF p_claims_int_rec.attribute10 IS NULL THEN
      x_complete_rec.attribute10 := l_claims_int_rec.attribute10;
   END IF;

   -- attribute11
   IF p_claims_int_rec.attribute11 = FND_API.g_miss_char THEN
      x_complete_rec.attribute11 := NULL;
   END IF;
   IF p_claims_int_rec.attribute11 IS NULL THEN
      x_complete_rec.attribute11 := l_claims_int_rec.attribute11;
   END IF;

   -- attribute12
   IF p_claims_int_rec.attribute12 = FND_API.g_miss_char THEN
      x_complete_rec.attribute12 := NULL;
   END IF;
   IF p_claims_int_rec.attribute12 IS NULL THEN
      x_complete_rec.attribute12 := l_claims_int_rec.attribute12;
   END IF;

   -- attribute13
   IF p_claims_int_rec.attribute13 = FND_API.g_miss_char THEN
      x_complete_rec.attribute13 := NULL;
   END IF;
   IF p_claims_int_rec.attribute13 IS NULL THEN
      x_complete_rec.attribute13 := l_claims_int_rec.attribute13;
   END IF;

   -- attribute14
   IF p_claims_int_rec.attribute14 = FND_API.g_miss_char THEN
      x_complete_rec.attribute14 := NULL;
   END IF;
   IF p_claims_int_rec.attribute14 IS NULL THEN
      x_complete_rec.attribute14 := l_claims_int_rec.attribute14;
   END IF;

   -- attribute15
   IF p_claims_int_rec.attribute15 = FND_API.g_miss_char THEN
      x_complete_rec.attribute15 := NULL;
   END IF;
   IF p_claims_int_rec.attribute15 IS NULL THEN
      x_complete_rec.attribute15 := l_claims_int_rec.attribute15;
   END IF;

   -- deduction_attribute_category
   IF p_claims_int_rec.deduction_attribute_category = FND_API.g_miss_char THEN
      x_complete_rec.deduction_attribute_category := NULL;
   END IF;
   IF p_claims_int_rec.deduction_attribute_category IS NULL THEN
      x_complete_rec.deduction_attribute_category := l_claims_int_rec.deduction_attribute_category;
   END IF;

   -- deduction_attribute1
   IF p_claims_int_rec.deduction_attribute1 = FND_API.g_miss_char THEN
      x_complete_rec.deduction_attribute1 := NULL;
   END IF;
   IF p_claims_int_rec.deduction_attribute1 IS NULL THEN
      x_complete_rec.deduction_attribute1 := l_claims_int_rec.deduction_attribute1;
   END IF;

   -- deduction_attribute2
   IF p_claims_int_rec.deduction_attribute2 = FND_API.g_miss_char THEN
      x_complete_rec.deduction_attribute2 := NULL;
   END IF;
   IF p_claims_int_rec.deduction_attribute2 IS NULL THEN
      x_complete_rec.deduction_attribute2 := l_claims_int_rec.deduction_attribute2;
   END IF;

   -- deduction_attribute3
   IF p_claims_int_rec.deduction_attribute3 = FND_API.g_miss_char THEN
      x_complete_rec.deduction_attribute3 := NULL;
   END IF;
   IF p_claims_int_rec.deduction_attribute3 IS NULL THEN
      x_complete_rec.deduction_attribute3 := l_claims_int_rec.deduction_attribute3;
   END IF;

   -- deduction_attribute4
   IF p_claims_int_rec.deduction_attribute4 = FND_API.g_miss_char THEN
      x_complete_rec.deduction_attribute4 := NULL;
   END IF;
   IF p_claims_int_rec.deduction_attribute4 IS NULL THEN
      x_complete_rec.deduction_attribute4 := l_claims_int_rec.deduction_attribute4;
   END IF;

   -- deduction_attribute5
   IF p_claims_int_rec.deduction_attribute5 = FND_API.g_miss_char THEN
      x_complete_rec.deduction_attribute5 := NULL;
   END IF;
   IF p_claims_int_rec.deduction_attribute5 IS NULL THEN
      x_complete_rec.deduction_attribute5 := l_claims_int_rec.deduction_attribute5;
   END IF;

   -- deduction_attribute6
   IF p_claims_int_rec.deduction_attribute6 = FND_API.g_miss_char THEN
      x_complete_rec.deduction_attribute6 := NULL;
   END IF;
   IF p_claims_int_rec.deduction_attribute6 IS NULL THEN
      x_complete_rec.deduction_attribute6 := l_claims_int_rec.deduction_attribute6;
   END IF;

   -- deduction_attribute7
   IF p_claims_int_rec.deduction_attribute7 = FND_API.g_miss_char THEN
      x_complete_rec.deduction_attribute7 := NULL;
   END IF;
   IF p_claims_int_rec.deduction_attribute7 IS NULL THEN
      x_complete_rec.deduction_attribute7 := l_claims_int_rec.deduction_attribute7;
   END IF;

   -- deduction_attribute8
   IF p_claims_int_rec.deduction_attribute8 = FND_API.g_miss_char THEN
      x_complete_rec.deduction_attribute8 := NULL;
   END IF;
   IF p_claims_int_rec.deduction_attribute8 IS NULL THEN
      x_complete_rec.deduction_attribute8 := l_claims_int_rec.deduction_attribute8;
   END IF;

   -- deduction_attribute9
   IF p_claims_int_rec.deduction_attribute9 = FND_API.g_miss_char THEN
      x_complete_rec.deduction_attribute9 := NULL;
   END IF;
   IF p_claims_int_rec.deduction_attribute9 IS NULL THEN
      x_complete_rec.deduction_attribute9 := l_claims_int_rec.deduction_attribute9;
   END IF;

   -- deduction_attribute10
   IF p_claims_int_rec.deduction_attribute10 = FND_API.g_miss_char THEN
      x_complete_rec.deduction_attribute10 := NULL;
   END IF;
   IF p_claims_int_rec.deduction_attribute10 IS NULL THEN
      x_complete_rec.deduction_attribute10 := l_claims_int_rec.deduction_attribute10;
   END IF;

   -- deduction_attribute11
   IF p_claims_int_rec.deduction_attribute11 = FND_API.g_miss_char THEN
      x_complete_rec.deduction_attribute11 := NULL;
   END IF;
   IF p_claims_int_rec.deduction_attribute11 IS NULL THEN
      x_complete_rec.deduction_attribute11 := l_claims_int_rec.deduction_attribute11;
   END IF;

   -- deduction_attribute12
   IF p_claims_int_rec.deduction_attribute12 = FND_API.g_miss_char THEN
      x_complete_rec.deduction_attribute12 := NULL;
   END IF;
   IF p_claims_int_rec.deduction_attribute12 IS NULL THEN
      x_complete_rec.deduction_attribute12 := l_claims_int_rec.deduction_attribute12;
   END IF;

   -- deduction_attribute13
   IF p_claims_int_rec.deduction_attribute13 = FND_API.g_miss_char THEN
      x_complete_rec.deduction_attribute13 := NULL;
   END IF;
   IF p_claims_int_rec.deduction_attribute13 IS NULL THEN
      x_complete_rec.deduction_attribute13 := l_claims_int_rec.deduction_attribute13;
   END IF;

   -- deduction_attribute14
   IF p_claims_int_rec.deduction_attribute14 = FND_API.g_miss_char THEN
      x_complete_rec.deduction_attribute14 := NULL;
   END IF;
   IF p_claims_int_rec.deduction_attribute14 IS NULL THEN
      x_complete_rec.deduction_attribute14 := l_claims_int_rec.deduction_attribute14;
   END IF;

   -- deduction_attribute15
   IF p_claims_int_rec.deduction_attribute15 = FND_API.g_miss_char THEN
      x_complete_rec.deduction_attribute15 := NULL;
   END IF;
   IF p_claims_int_rec.deduction_attribute15 IS NULL THEN
      x_complete_rec.deduction_attribute15 := l_claims_int_rec.deduction_attribute15;
   END IF;

   -- org_id
   IF p_claims_int_rec.org_id = FND_API.g_miss_num THEN
      x_complete_rec.org_id := NULL;
   END IF;
   IF p_claims_int_rec.org_id IS NULL THEN
      x_complete_rec.org_id := l_claims_int_rec.org_id;
   END IF;

   IF p_claims_int_rec.customer_reason = FND_API.g_miss_char THEN
      x_complete_rec.customer_reason := NULL;
   END IF;
   IF p_claims_int_rec.customer_reason IS NULL THEN
      x_complete_rec.customer_reason := l_claims_int_rec.customer_reason;
   END IF;

   IF p_claims_int_rec.ship_to_cust_account_id = FND_API.g_miss_num THEN
      x_complete_rec.ship_to_cust_account_id := NULL;
   END IF;
   IF p_claims_int_rec.ship_to_cust_account_id IS NULL THEN
      x_complete_rec.ship_to_cust_account_id := l_claims_int_rec.ship_to_cust_account_id;
   END IF;


END Complete_claims_int_Rec;

PROCEDURE Validate_claims_int(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_claims_int_rec               IN   claims_int_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Claims_Int';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_claims_int_rec  OZF_Claims_Int_PVT.claims_int_rec_type;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT VALIDATE_Claims_Int_;

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
           Check_claims_int_Items(
              p_claims_int_rec        => p_claims_int_rec,
              p_validation_mode   => JTF_PLSQL_API.g_update,
              x_return_status     => x_return_status
           );

           IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
           ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
   END IF;

   Complete_claims_int_Rec(
      p_claims_int_rec        => p_claims_int_rec,
      x_complete_rec        => l_claims_int_rec
   );

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Validate_claims_int_Rec(
        p_api_version_number     => 1.0,
        p_init_msg_list          => FND_API.G_FALSE,
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data,
        p_claims_int_rec           =>    l_claims_int_rec);

           IF x_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
           ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
EXCEPTION
   WHEN OZF_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
      OZF_Utility_PVT.Error_Message(p_message_name =>'OZF_API_RESOURCE_LOCKED');
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO VALIDATE_Claims_Int_;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO VALIDATE_Claims_Int_;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO VALIDATE_Claims_Int_;
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
End Validate_Claims_Int;

PROCEDURE Validate_claims_int_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_claims_int_rec               IN    claims_int_rec_type
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
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('Private API: Validate_claims_int_rec');
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
END Validate_claims_int_Rec;

---------------------------------------------------------------------
--   PROCEDURE:  cleanup_claims
--
--   PURPOSE:
--   This procedure purges records from ozf_claims_all and ozf_claim_lines_all tables
--   for a given claim_id.
--
--   PARAMETERS:
--   IN:
--       p_claim_id number
--   OUT:
--       x_return_status VARCHAR2
--   NOTES:
--
---------------------------------------------------------------------

PROCEDURE cleanup_claims (
    p_claim_id   in number,
    x_return_status OUT NOCOPY varchar2
)
IS
BEGIN
   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('Private API: Clean up Claims');
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   delete from ozf_claims_all where claim_id = p_claim_id;
   delete from ozf_claim_lines_all where claim_id = p_claim_id;

EXCEPTION
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_DELETE_ERR');
        FND_MSG_PUB.add;
     END IF;
END cleanup_claims;

---------------------------------------------------------------------
--   PROCEDURE:  Start_Replicate
--
--   PURPOSE:
--   This procedure reads information from ozf_claims_int_all table
--   and inserts claims to ozf_claims_all table.
--
--   PARAMETERS:
--
--   OUT:
--       ERRBUT VARCHAR2
--       RETCODE NUMBER
--   NOTES:
--
---------------------------------------------------------------------
PROCEDURE Start_Replicate (
    ERRBUF    OUT NOCOPY VARCHAR2,
    RETCODE   OUT NOCOPY NUMBER,
    p_org_id  IN  		 NUMBER DEFAULT NULL
)
IS
l_claim_rec     OZF_CLAIM_PVT.claim_rec_type;
l_x_claim_rec   OZF_CLAIM_PVT.claim_rec_type;
l_line_rec      OZF_Claim_Line_PVT.claim_line_rec_type;
l_claim_id      NUMBER;
l_line_id       NUMBER;

l_return_status     VARCHAR2(1);
l_msg_data          VARCHAR2(200);
l_msg_count         NUMBER;
l_full_name varchar2(30) := 'Import API: Start Replicate';
CURSOR c_claim_int IS
SELECT *
FROM ozf_claims_int_all
WHERE claim_id is null;
l_claim_int_rec c_claim_int%ROWTYPE;

CURSOR c_claim_line_int(cv_claim_id IN NUMBER) IS
SELECT *
FROM ozf_claim_lines_int_all
WHERE interface_claim_id = cv_claim_id;
l_line_int_rec  c_claim_line_int%ROWTYPE;

l_api_name          CONSTANT VARCHAR2(30) := 'Import_Claim';

CURSOR object_class_csr(p_id in number) IS
SELECT type
FROM ra_cust_trx_types_all
WHERE cust_trx_type_id = p_id;

CURSOR claim_number_csr(p_id in number) IS
SELECT claim_number
FROM ozf_claims_all
WHERE claim_id = p_id;
l_claim_number   VARCHAR2(30);

--Multiorg Changes
CURSOR operating_unit_csr IS
    SELECT ou.organization_id   org_id
    FROM hr_operating_units ou
    WHERE mo_global.check_access(ou.organization_id) = 'Y';

m NUMBER := 0;
l_org_id     OZF_UTILITY_PVT.operating_units_tbl;

BEGIN
   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
      FND_MSG_PUB.Add;
   END IF;
   SAVEPOINT  Start_Replicate_IMP;

   ERRBUF  := null;
   RETCODE := 0;


--Multiorg Changes
MO_GLOBAL.init('OZF');

IF p_org_id IS NULL THEN
	MO_GLOBAL.set_policy_context('M',null);
    OPEN operating_unit_csr;
    LOOP
       FETCH operating_unit_csr into l_org_id(m);
       m := m + 1;
       EXIT WHEN operating_unit_csr%NOTFOUND;
    END LOOP;
    CLOSE operating_unit_csr;
ELSE
    l_org_id(m) := p_org_id;
END IF;

--Multiorg Changes
IF (l_org_id.COUNT > 0) THEN
    FOR m IN l_org_id.FIRST..l_org_id.LAST LOOP
       MO_GLOBAL.set_policy_context('S',l_org_id(m));
	   -- Write OU info to OUT file
	   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  'Operating Unit: ' || MO_GLOBAL.get_ou_name(l_org_id(m)));
	   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '-----------------------------------------------------');
	   -- Write OU info to LOG file
	   FND_FILE.PUT_LINE(FND_FILE.LOG,  'Operating Unit: ' || MO_GLOBAL.get_ou_name(l_org_id(m)));
	   FND_FILE.PUT_LINE(FND_FILE.LOG,  '-----------------------------------------------------');

	   OPEN c_claim_int;
	   LOOP
		  <<next_claim>>
		  FETCH c_claim_int INTO l_claim_int_rec;
		  EXIT WHEN c_claim_int%NOTFOUND;

		  -- Default values for interface table
		  --Get claim class
		  IF l_claim_int_rec.claim_class IS NULL
		  THEN
			  if l_claim_int_rec.amount >0 then
				 l_claim_int_rec.claim_class := G_CLAIM_CLASS;
			  else
				 l_claim_int_rec.claim_class := G_CHARGE_CLASS;
			  end if;
		  ELSE
			 IF l_claim_int_rec.claim_class <> G_CLAIM_CLASS AND
			  l_claim_int_rec.claim_class <> G_CHARGE_CLASS AND
			  l_claim_int_rec.claim_class <> G_DEDUCTION_CLASS AND
			  l_claim_int_rec.claim_class <> G_OVERPAYMENT_CLASS THEN
			-- write a message 'Wrong claim class'
				IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
				   FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_CLAIM_CLASS_WRG');
					FND_MSG_PUB.Add;
				   FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_IMPORT_ERR');
				   FND_MESSAGE.Set_Token('ID', l_claim_int_rec.interface_claim_id);
				   FND_MSG_PUB.Add;
				  END IF;
				 GOTO next_claim;
		   END IF;
		  END IF; --end if for line 2402

		  -- Check deduction items if it's a deduction.
		  IF (l_claim_int_rec.claim_class = G_DEDUCTION_CLASS AND
			  ((l_claim_int_rec.cust_account_id is NULL OR
		   l_claim_int_rec.cust_account_id = FND_API.G_MISS_NUM) OR
			  (l_claim_int_rec.receipt_id is NULL OR
		   l_claim_int_rec.receipt_id = FND_API.G_MISS_NUM) OR
			  (l_claim_int_rec.receipt_number is NULL OR
		   l_claim_int_rec.receipt_number = FND_API.G_MISS_CHAR) OR
			  (l_claim_int_rec.currency_code is NULL OR
		   l_claim_int_rec.currency_code = FND_API.G_MISS_CHAR) OR
			  (l_claim_int_rec.amount is NULL OR
		   l_claim_int_rec.amount = FND_API.G_MISS_NUM)))  THEN

			  IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
				 FND_MESSAGE.Set_Name('OZF','OZF_REQUIRED_FIELDS_MISSING');
				 FND_MSG_PUB.Add;
				 FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_IMPORT_ERR');
				 FND_MESSAGE.Set_Token('ID', l_claim_int_rec.interface_claim_id);
				 FND_MSG_PUB.Add;
			  END IF;
			  GOTO next_claim;
		  END IF;  --end if for line 2427

		  -- Verify claim_class based on input
		  IF l_claim_int_rec.claim_class <> G_CLAIM_CLASS
		  AND l_claim_int_rec.claim_class <> G_CHARGE_CLASS
		  THEN
			 IF (l_claim_int_rec.SOURCE_OBJECT_ID <> FND_API.G_MISS_NUM OR
				 l_claim_int_rec.SOURCE_OBJECT_ID is not NULL ) THEN

				 IF (l_claim_int_rec.source_object_type_id is null) THEN
					 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
						FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_SRC_INFO_MISSING');
						FND_MSG_PUB.add;
						 FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_IMPORT_ERR');
						FND_MESSAGE.Set_Token('ID', l_claim_int_rec.interface_claim_id);
						FND_MSG_PUB.Add;
					 END IF;
					 GOTO next_claim;
				 ELSE
					IF (l_claim_int_rec.amount < 0) THEN
						IF l_claim_int_rec.claim_class <> G_OVERPAYMENT_CLASS THEN
							 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
							  FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_AMT_NEG');
							  FND_MSG_PUB.add;
								 FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_IMPORT_ERR');
							  FND_MESSAGE.Set_Token('ID', l_claim_int_rec.interface_claim_id);
							  FND_MSG_PUB.Add;
						   END IF;
						   GOTO next_claim;
					   END IF;
					ELSE
					   IF l_claim_int_rec.claim_class <> G_DEDUCTION_CLASS THEN
						   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
							  FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_AMT_POS_OPM');
							  FND_MSG_PUB.add;
							  FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_IMPORT_ERR');
							  FND_MESSAGE.Set_Token('ID', l_claim_int_rec.interface_claim_id);
							  FND_MSG_PUB.Add;
						   END IF;
						   GOTO next_claim;
					   END IF;
				   END IF; --end if for line 2466

					OPEN object_class_csr(l_claim_int_rec.source_object_type_id);
					FETCH object_class_csr INTO l_claim_int_rec.SOURCE_OBJECT_CLASS;
					CLOSE object_class_csr;

					IF l_claim_int_rec.SOURCE_OBJECT_CLASS = 'INV' THEN
					   l_claim_int_rec.SOURCE_OBJECT_CLASS := 'INVOICE';
					END IF;
				 END IF; --end if for line 2456
			 ELSE --else for if in line 2453
			   IF (l_claim_int_rec.amount < 0) THEN
				  l_claim_int_rec.amount := l_claim_int_rec.amount * -1;
				  IF l_claim_int_rec.claim_class <> G_DEDUCTION_CLASS THEN
						IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
						FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_NEG_AMT_WOR_DEDU');
						FND_MSG_PUB.add;
						 FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_IMPORT_ERR');
						FND_MESSAGE.Set_Token('ID', l_claim_int_rec.interface_claim_id);
						FND_MSG_PUB.Add;
					 END IF;
					 GOTO next_claim;
				  END IF;
			   ELSE
				  l_claim_int_rec.amount := l_claim_int_rec.amount * -1;
				   IF l_claim_int_rec.claim_class <> G_OVERPAYMENT_CLASS THEN
					 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
						FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_POS_AMT_WOR_OPM');
						FND_MSG_PUB.add;
						 FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_IMPORT_ERR');
						FND_MESSAGE.Set_Token('ID', l_claim_int_rec.interface_claim_id);
						FND_MSG_PUB.Add;
					 END IF;
					 GOTO next_claim;
			   END IF;
			   END IF; --end if for line 2499
			 END IF; --end if for line 2453
		  END IF; --end if for line 2451


		  -- Set user_status_id as 'OPEN'
		  l_claim_int_rec.user_status_id := to_number( ozf_utility_pvt.GET_DEFAULT_USER_STATUS(
											  P_STATUS_TYPE=> G_CLAIM_STATUS,
											  P_STATUS_CODE=> G_OPEN_STATUS
										 )
						);
		  l_claim_int_rec.status_code       := 'OPEN';
		  l_claim_rec.request_id           := FND_GLOBAL.conc_request_id;
		  l_claim_rec.program_application_id := FND_GLOBAL.resp_appl_id;
		  l_claim_rec.program_update_date   := sysdate;
		  l_claim_rec.program_id            := FND_GLOBAL.conc_program_id;
		  l_claim_rec.created_from          := l_api_name;
		  l_claim_rec.batch_id              := l_claim_int_rec.batch_id;
		  l_claim_rec.claim_number          := l_claim_int_rec.claim_number;
		  l_claim_rec.claim_type_id         := l_claim_int_rec.claim_type_id;
		  l_claim_rec.claim_class           := l_claim_int_rec.claim_class;
		  l_claim_rec.claim_date            := l_claim_int_rec.claim_date;
		  l_claim_rec.due_date              := l_claim_int_rec.due_date;
		  l_claim_rec.amount                := l_claim_int_rec.amount;
		  l_claim_rec.currency_code         := l_claim_int_rec.currency_code;
		  l_claim_rec.exchange_rate_type    := l_claim_int_rec.exchange_rate_type;
		  l_claim_rec.exchange_rate_date    := l_claim_int_rec.exchange_rate_date;
		  l_claim_rec.exchange_rate         := l_claim_int_rec.exchange_rate;
		  l_claim_rec.set_of_books_id       := l_claim_int_rec.set_of_books_id;
		  l_claim_rec.source_object_id      := l_claim_int_rec.source_object_id;
		  l_claim_rec.source_object_class   := l_claim_int_rec.source_object_class;
		  l_claim_rec.source_object_type_id := l_claim_int_rec.source_object_type_id;
		  l_claim_rec.source_object_number  := l_claim_int_rec.source_object_number;
		  l_claim_rec.cust_account_id       := l_claim_int_rec.cust_account_id;
		  l_claim_rec.cust_billto_acct_site_id := l_claim_int_rec.cust_billto_acct_site_id;
		  l_claim_rec.cust_shipto_acct_site_id := l_claim_int_rec.cust_shipto_acct_site_id;
		  l_claim_rec.pay_related_account_flag := l_claim_int_rec.pay_related_account_flag;
		  l_claim_rec.related_cust_account_id  := l_claim_int_rec.related_cust_account_id;
		  l_claim_rec.related_site_use_id   := l_claim_int_rec.related_site_use_id;
		  l_claim_rec.relationship_type     := l_claim_int_rec.relationship_type;
		  l_claim_rec.vendor_id             := l_claim_int_rec.vendor_id;
		  l_claim_rec.vendor_site_id        := l_claim_int_rec.vendor_site_id;
		  l_claim_rec.reason_code_id        := l_claim_int_rec.reason_code_id;
		  l_claim_rec.task_template_group_id:= l_claim_int_rec.task_template_group_id;
		  l_claim_rec.status_code           := l_claim_int_rec.status_code;
		  l_claim_rec.user_status_id        := l_claim_int_rec.user_status_id;
		  l_claim_rec.sales_rep_id          := l_claim_int_rec.sales_rep_id;
		  l_claim_rec.contact_id            := l_claim_int_rec.contact_id;
		  l_claim_rec.broker_id             := l_claim_int_rec.broker_id;
		  l_claim_rec.customer_ref_date     := l_claim_int_rec.customer_ref_date;
		  l_claim_rec.customer_ref_number   := l_claim_int_rec.customer_ref_number;
		  l_claim_rec.receipt_id            := l_claim_int_rec.receipt_id;
		  l_claim_rec.receipt_number        := l_claim_int_rec.receipt_number;
		  l_claim_rec.gl_date               := l_claim_int_rec.gl_date;
		  l_claim_rec.payment_method        := l_claim_int_rec.payment_method;
		  l_claim_rec.effective_date        := l_claim_int_rec.effective_date;
		  l_claim_rec.order_type_id         := l_claim_int_rec.order_type_id;
		  l_claim_rec.comments              := l_claim_int_rec.comments;
		  l_claim_rec.attribute_category    := l_claim_int_rec.attribute_category;
		  l_claim_rec.attribute1            := l_claim_int_rec.attribute1;
		  l_claim_rec.attribute2            := l_claim_int_rec.attribute2;
		  l_claim_rec.attribute3            := l_claim_int_rec.attribute3;
		  l_claim_rec.attribute4            := l_claim_int_rec.attribute4;
		  l_claim_rec.attribute5            := l_claim_int_rec.attribute5;
		  l_claim_rec.attribute6            := l_claim_int_rec.attribute6;
		  l_claim_rec.attribute7            := l_claim_int_rec.attribute7;
		  l_claim_rec.attribute8            := l_claim_int_rec.attribute8;
		  l_claim_rec.attribute9            := l_claim_int_rec.attribute9;
		  l_claim_rec.attribute10           := l_claim_int_rec.attribute10;
		  l_claim_rec.attribute11           := l_claim_int_rec.attribute11;
		  l_claim_rec.attribute12           := l_claim_int_rec.attribute12;
		  l_claim_rec.attribute13           := l_claim_int_rec.attribute13;
		  l_claim_rec.attribute14           := l_claim_int_rec.attribute14;
		  l_claim_rec.attribute15           := l_claim_int_rec.attribute15;
		  l_claim_rec.deduction_attribute_category    := l_claim_int_rec.deduction_attribute_category;
		  l_claim_rec.deduction_attribute1            := l_claim_int_rec.deduction_attribute1;
		  l_claim_rec.deduction_attribute2            := l_claim_int_rec.deduction_attribute2;
		  l_claim_rec.deduction_attribute3            := l_claim_int_rec.deduction_attribute3;
		  l_claim_rec.deduction_attribute4            := l_claim_int_rec.deduction_attribute4;
		  l_claim_rec.deduction_attribute5            := l_claim_int_rec.deduction_attribute5;
		  l_claim_rec.deduction_attribute6            := l_claim_int_rec.deduction_attribute6;
		  l_claim_rec.deduction_attribute7            := l_claim_int_rec.deduction_attribute7;
		  l_claim_rec.deduction_attribute8            := l_claim_int_rec.deduction_attribute8;
		  l_claim_rec.deduction_attribute9            := l_claim_int_rec.deduction_attribute9;
		  l_claim_rec.deduction_attribute10           := l_claim_int_rec.deduction_attribute10;
		  l_claim_rec.deduction_attribute11           := l_claim_int_rec.deduction_attribute11;
		  l_claim_rec.deduction_attribute12           := l_claim_int_rec.deduction_attribute12;
		  l_claim_rec.deduction_attribute13           := l_claim_int_rec.deduction_attribute13;
		  l_claim_rec.deduction_attribute14           := l_claim_int_rec.deduction_attribute14;
		  l_claim_rec.deduction_attribute15           := l_claim_int_rec.deduction_attribute15;
		  l_claim_rec.org_id                          := l_claim_int_rec.org_id;
		  l_claim_rec.customer_reason                 := l_claim_int_rec.customer_reason;
		  l_claim_rec.ship_to_cust_account_id         := l_claim_int_rec.ship_to_cust_account_id;




		  -- Debug Message
		  IF OZF_DEBUG_HIGH_ON THEN
			 OZF_UTILITY_PVT.debug_message('Call check_claim_common_element');
		  END IF;

		  OZF_claim_PVT.Check_Claim_Common_Element (
		   p_api_version      => 1.0,
		   p_init_msg_list    => FND_API.G_FALSE,
		   p_validation_level => FND_API.G_VALID_LEVEL_FULL,
		   x_Return_Status      => l_return_status,
		   x_Msg_Count          => l_msg_count,
		   x_Msg_Data           => l_msg_data,
		   p_claim              => l_claim_rec,
		   x_claim              => l_x_claim_rec
		  );
		  -- Check return status from the above procedure call
		  IF l_return_status = FND_API.G_RET_STS_ERROR OR
			 l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		 IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
				FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_IMPORT_ERR');
				FND_MESSAGE.Set_Token('ID', l_claim_int_rec.interface_claim_id);
				FND_MSG_PUB.Add;
		 END IF;
		 GOTO next_claim;
		  END IF;
		  l_claim_rec := l_x_claim_rec;

		  -- Debug Message
		  IF OZF_DEBUG_HIGH_ON THEN
			 OZF_UTILITY_PVT.debug_message('Call create_claim');
		  END IF;

		  --------------------
		  --  Create Claim  --
		  --------------------
		  OZF_CLAIM_PVT.Create_Claim (
				p_api_version            => 1.0
			   ,x_return_status          => l_return_status
			   ,x_msg_data               => l_msg_data
			   ,x_msg_count              => l_msg_count
			   ,p_claim          	     => l_claim_rec
			   ,x_claim_id         	     => l_claim_id
		  );

		  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
			 -- Debug Message
			 IF OZF_DEBUG_HIGH_ON THEN
				OZF_UTILITY_PVT.debug_message('Create Claims for '|| l_claim_int_rec.interface_claim_id ||' failed');
			 END IF;

		 IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
				FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_IMPORT_ERR');
				FND_MESSAGE.Set_Token('ID', l_claim_int_rec.interface_claim_id);
				FND_MSG_PUB.Add;
		 END IF;
		 GOTO next_claim;
		  END IF;

		  IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
			 -----------------------------------------------
			 -- Update claim_id in Claim Interface Table  --
			 -----------------------------------------------

			 OPEN c_claim_line_int(l_claim_int_rec.interface_claim_id);
			 LOOP
				FETCH c_claim_line_int INTO l_line_int_rec;
				EXIT WHEN c_claim_line_int%NOTFOUND;

			-- check line amount
			IF (l_line_int_rec.claim_currency_amount is null OR
				l_line_int_rec.claim_currency_amount = 0) THEN

			   IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
					  FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_LINE_AMT_ERR');
					  FND_MSG_PUB.Add;
			   END IF;
			   IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
					  FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_LINE_IMPORT_ERR');
					  FND_MESSAGE.Set_Token('ID', l_line_int_rec.interface_claim_id);
			  FND_MESSAGE.Set_Token('LINEID', l_line_int_rec.interface_claim_line_id);
					  FND_MSG_PUB.Add;
			   END IF;
			   cleanup_claims (p_claim_id => l_claim_id,
								   x_return_status => l_return_status);
				   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			   END IF;
			   GOTO next_claim;
			END IF;

			-- Assign value to the local line record.

				l_line_rec.request_id          := FND_GLOBAL.conc_request_id;
				l_line_rec.program_application_id
										:= FND_GLOBAL.resp_appl_id;
				l_line_rec.program_update_date
										:= sysdate;
				l_line_rec.program_id          := FND_GLOBAL.conc_program_id;
				l_line_rec.created_from        := l_api_name;
				l_line_rec.claim_id            := l_claim_id;
				l_line_rec.amount              := l_line_int_rec.amount;
				l_line_rec.claim_currency_amount:= l_line_int_rec.claim_currency_amount;
				l_line_rec.set_of_books_id     := l_line_int_rec.set_of_books_id;
				l_line_rec.valid_flag          := l_line_int_rec.valid_flag;
				l_line_rec.source_object_id    := l_line_int_rec.source_object_id;
				l_line_rec.source_object_class:= l_line_int_rec.source_object_class;
				l_line_rec.source_object_type_id
									  := l_line_int_rec.source_object_type_id;
			l_line_rec.source_object_line_id
									  := l_line_int_rec.source_object_line_id;
				l_line_rec.payment_status      := l_line_int_rec.payment_status;
				l_line_rec.approved_flag       := l_line_int_rec.approved_flag;
				l_line_rec.approved_date       := l_line_int_rec.approved_date;
				l_line_rec.approved_by         := l_line_int_rec.approved_by;
				l_line_rec.settled_date        := l_line_int_rec.settled_date;
				l_line_rec.settled_by          := l_line_int_rec.settled_by;
				l_line_rec.performance_complete_flag
									  := l_line_int_rec.performance_complete_flag;
				l_line_rec.performance_attached_flag
									  := l_line_int_rec.performance_attached_flag;
				l_line_rec.select_cust_children_flag
									  := l_line_int_rec.select_cust_children_flag;
				l_line_rec.item_id             := l_line_int_rec.item_id;
				l_line_rec.item_description    := l_line_int_rec.item_description;
                l_line_rec.item_type           := l_line_int_rec.item_type;
				l_line_rec.quantity            := l_line_int_rec.quantity;
				l_line_rec.quantity_uom        := l_line_int_rec.quantity_uom;
				l_line_rec.rate                := l_line_int_rec.rate;
				l_line_rec.activity_type       := l_line_int_rec.activity_type;
				l_line_rec.activity_id         := l_line_int_rec.activity_id;
				l_line_rec.related_cust_account_id:= l_line_int_rec.related_cust_account_id;
				l_line_rec.relationship_type   := l_line_int_rec.relationship_type;
				--l_line_rec.earnings_associated_flag
				--                      := l_line_int_rec.earnings_associated_flag;
				l_line_rec.comments            := l_line_int_rec.comments;
				l_line_rec.tax_code            := l_line_int_rec.tax_code;
				l_line_rec.credit_to           := l_line_int_rec.credit_to;
				l_line_rec.attribute_category  := l_line_int_rec.attribute_category;
				l_line_rec.attribute1          := l_line_int_rec.attribute1;
				l_line_rec.attribute2          := l_line_int_rec.attribute2;
				l_line_rec.attribute3          := l_line_int_rec.attribute3;
				l_line_rec.attribute4          := l_line_int_rec.attribute4;
				l_line_rec.attribute5          := l_line_int_rec.attribute5;
				l_line_rec.attribute6          := l_line_int_rec.attribute6;
				l_line_rec.attribute7          := l_line_int_rec.attribute7;
				l_line_rec.attribute8          := l_line_int_rec.attribute8;
				l_line_rec.attribute9          := l_line_int_rec.attribute9;
				l_line_rec.attribute10         := l_line_int_rec.attribute10;
				l_line_rec.attribute11         := l_line_int_rec.attribute11;
				l_line_rec.attribute12         := l_line_int_rec.attribute12;
				l_line_rec.attribute13         := l_line_int_rec.attribute13;
				l_line_rec.attribute14         := l_line_int_rec.attribute14;
				l_line_rec.attribute15         := l_line_int_rec.attribute15;
				l_line_rec.org_id              := l_line_int_rec.org_id;
				l_line_rec.exchange_rate_type  := l_line_int_rec.exchange_rate_type;
				l_line_rec.exchange_rate_date  := l_line_int_rec.exchange_rate_date;
				l_line_rec.exchange_rate       := l_line_int_rec.exchange_rate;
				l_line_rec.currency_code       := l_line_int_rec.currency_code;

			-------------------------
				--  Create Claim_Line  --
				-------------------------
				OZF_Claim_Line_PVT.Create_Claim_Line(
				   P_Api_Version        => 1.0,
				   P_Init_Msg_List      => FND_API.G_FALSE,
				   P_Commit             => FND_API.G_FALSE,
				   P_Validation_Level   => FND_API.G_VALID_LEVEL_FULL,
				   X_Return_Status      => l_return_status,
				   X_Msg_Count          => l_msg_count,
				   X_Msg_Data           => l_msg_data,
				   p_claim_line_rec     => l_line_rec,
				   x_claim_line_id      => l_line_id
				);

				IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
				   IF OZF_DEBUG_HIGH_ON THEN
					  OZF_UTILITY_PVT.debug_message('Claim line creation failed. ');
				   END IF;

			   IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
					  FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_LINE_IMPORT_ERR');
					  FND_MESSAGE.Set_Token('ID', l_line_int_rec.interface_claim_id);
			  FND_MESSAGE.Set_Token('LINEID', l_line_int_rec.interface_claim_line_id);
					  FND_MSG_PUB.Add;
			   END IF;
			   cleanup_claims (p_claim_id => l_claim_id,
								   x_return_status => l_return_status);
				   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			   END IF;
			   GOTO next_claim;
			END IF;

			 END LOOP; -- for claim lines
			 CLOSE c_claim_line_int;

		 -- Now, I have created every lines for this claim without problem.
		 -- I will update the claim interface table with the new claim id.
		 IF OZF_DEBUG_HIGH_ON THEN
			OZF_UTILITY_PVT.debug_message('Create Claims for '|| l_claim_int_rec.interface_claim_id ||' succeed');

				OZF_UTILITY_PVT.debug_message('claim_id: ' || l_claim_id);
			 END IF;

		 UPDATE OZF_CLAIMS_INT_ALL
			 SET CLAIM_ID = l_claim_id
			 WHERE INTERFACE_CLAIM_ID = l_claim_int_rec.interface_claim_id;

		  OPEN claim_number_csr(l_claim_id);
		  FETCH claim_number_csr INTO l_claim_number;
		  CLOSE claim_number_csr;

		  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Claim ' || l_claim_number || ' created successfully');

		  END IF; -- for claim lines condition

	   END LOOP;
	   CLOSE c_claim_int;

		-- Debug Message
		IF OZF_DEBUG_LOW_ON THEN
		   FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
		   FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
		   FND_MSG_PUB.Add;
		END IF;

	   -- Write all messages to a log
	   OZF_UTILITY_PVT.Write_Conc_Log;

   END LOOP;
END IF;

EXCEPTION
  WHEN FND_API.g_exc_error THEN
    ROLLBACK TO Start_Replicate_IMP;
    FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false
        ,p_count   => l_msg_count
        ,p_data    => l_msg_data
    );
    ERRBUF  := fnd_msg_pub.get(p_msg_index => 1, p_encoded => 'F');
    RETCODE := 2;
    -- Write all errors messages to a log
    OZF_UTILITY_PVT.Write_Conc_Log;

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Start_Replicate_IMP;
    FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false
        ,p_count   => l_msg_count
        ,p_data    => l_msg_data
    );
    ERRBUF  := fnd_msg_pub.get(p_msg_index => 1, p_encoded => 'F');
    RETCODE := 2;
    -- Write all errors messages to a log
    OZF_UTILITY_PVT.Write_Conc_Log;
  WHEN OTHERS THEN
    ROLLBACK TO Start_Replicate_IMP;
    FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false
        ,p_count   => l_msg_count
        ,p_data    => l_msg_data
    );
    ERRBUF  := fnd_msg_pub.get(p_msg_index => 1, p_encoded => 'F');
    RETCODE := 2;
    -- Write all errors messages to a log
   OZF_UTILITY_PVT.Write_Conc_Log;

END Start_Replicate;

---------------------------------------------------------------------
--   PROCEDURE:  Purge_Claim
--
--   PURPOSE:
--   This procedure deletes processed records from ozf_claims_int_all, ozf_claim_lines_all table.
--
--   PARAMETERS:
--
--   OUT:
--       ERRBUT VARCHAR2
--       RETCODE NUMBER
--   NOTES:
--
---------------------------------------------------------------------
PROCEDURE Purge_Claims (
    ERRBUF    OUT NOCOPY VARCHAR2,
    RETCODE   OUT NOCOPY NUMBER,
    p_org_id  IN  		 NUMBER DEFAULT NULL
)
IS
l_full_name varchar2(30) := 'Import API: Purge Claims';
l_return_status     VARCHAR2(1);
l_msg_data          VARCHAR2(200);
l_msg_count         NUMBER;

BEGIN

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('Private API: Purge Claims');
   END IF;
   IF OZF_DEBUG_LOW_ON THEN
      FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
      FND_MSG_PUB.Add;
   END IF;
   SAVEPOINT  PURGE_CLAIM_IMP;
   ERRBUF  := null;
   RETCODE := 0;

   -- Multiorg Changes
   MO_GLOBAL.init('OZF');
   IF(p_org_id is null) THEN
      MO_GLOBAL.set_policy_context('M',null);
   ELSE
      MO_GLOBAL.set_policy_context('S',p_org_id);
   END IF;

   -- Clean up lines table.
   delete FROM ozf_claim_lines_int_all a
   where exists
   (select 1 from ozf_claims_int_all b
    where b.claim_id is not null
    and b.interface_claim_id = a.interface_claim_id);

   delete from ozf_claims_int_all
   where claim_id is not null;

    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
       FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;

   -- Write all messages to a log
   OZF_UTILITY_PVT.Write_Conc_Log;
EXCEPTION
  WHEN FND_API.g_exc_error THEN
    ROLLBACK TO PURGE_CLAIM_IMP;
    FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false
        ,p_count   => l_msg_count
        ,p_data    => l_msg_data
    );
    ERRBUF  := fnd_msg_pub.get(p_msg_index => 1, p_encoded => 'F');
    RETCODE := 2;
    -- Write all errors messages to a log
    OZF_UTILITY_PVT.Write_Conc_Log;

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO PURGE_CLAIM_IMP;
    FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false
        ,p_count   => l_msg_count
        ,p_data    => l_msg_data
    );
    ERRBUF  := fnd_msg_pub.get(p_msg_index => 1, p_encoded => 'F');
    RETCODE := 2;
    -- Write all errors messages to a log
    OZF_UTILITY_PVT.Write_Conc_Log;
  WHEN OTHERS THEN
    ROLLBACK TO PURGE_CLAIM_IMP;
    FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false
        ,p_count   => l_msg_count
        ,p_data    => l_msg_data
    );
    ERRBUF  := fnd_msg_pub.get(p_msg_index => 1, p_encoded => 'F');
    RETCODE := 2;
    -- Write all errors messages to a log
   OZF_UTILITY_PVT.Write_Conc_Log;
END Purge_Claims;

END OZF_Claims_Int_PVT;

/
