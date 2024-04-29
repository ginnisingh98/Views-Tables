--------------------------------------------------------
--  DDL for Package Body OZF_CLAIMS_INT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CLAIMS_INT_PUB" as
/* $Header: ozfpcinb.pls 120.0.12010000.2 2008/07/31 11:26:14 kpatro ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Claims_Int_PUB
-- Purpose
--
-- History
--
-- NOTE
--
-- 29-Jul-2008  KPATRO   Fix for bug 7290916
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Claims_Int_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfpcinb.pls';

G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);

PROCEDURE Create_Claims_Int(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_claims_int_rec               IN   claims_int_rec_type  := g_miss_claims_int_rec,
    x_interface_claim_id                   OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Claims_Int';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_pvt_claims_int_rec    OZF_Claims_Int_PVT.claims_int_rec_type;

--Added for 7290916
l_claims_int_rec claims_int_rec_type:= p_claims_int_rec;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Claims_Int_PUB;

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
      IF g_debug THEN
         OZF_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

	--Added For 7290916
	l_pvt_claims_int_rec.interface_claim_id := l_claims_int_rec.interface_claim_id;
	l_pvt_claims_int_rec.object_version_number := l_claims_int_rec.object_version_number;
	l_pvt_claims_int_rec.last_update_date := l_claims_int_rec.last_update_date;
	l_pvt_claims_int_rec.last_updated_by := l_claims_int_rec.last_updated_by;
	l_pvt_claims_int_rec.creation_date := l_claims_int_rec.creation_date;
	l_pvt_claims_int_rec.created_by := l_claims_int_rec.created_by;
	l_pvt_claims_int_rec.last_update_login := l_claims_int_rec.last_update_login;
	l_pvt_claims_int_rec.request_id := l_claims_int_rec.request_id;
	l_pvt_claims_int_rec.program_application_id := l_claims_int_rec.program_application_id;
	l_pvt_claims_int_rec.program_update_date := l_claims_int_rec.program_update_date;
	l_pvt_claims_int_rec.program_id := l_claims_int_rec.program_id;
	l_pvt_claims_int_rec.created_from := l_claims_int_rec.created_from;
	l_pvt_claims_int_rec.batch_id := l_claims_int_rec.batch_id;
	l_pvt_claims_int_rec.claim_id := l_claims_int_rec.claim_id;
	l_pvt_claims_int_rec.claim_number := l_claims_int_rec.claim_number;
	l_pvt_claims_int_rec.claim_type_id := l_claims_int_rec.claim_type_id;
	l_pvt_claims_int_rec.claim_class := l_claims_int_rec.claim_class;
	l_pvt_claims_int_rec.claim_date := l_claims_int_rec.claim_date;
	l_pvt_claims_int_rec.due_date := l_claims_int_rec.due_date;
	l_pvt_claims_int_rec.owner_id := l_claims_int_rec.owner_id;
	l_pvt_claims_int_rec.history_event := l_claims_int_rec.history_event;
	l_pvt_claims_int_rec.history_event_date := l_claims_int_rec.history_event_date;
	l_pvt_claims_int_rec.history_event_description := l_claims_int_rec.history_event_description;
	l_pvt_claims_int_rec.split_from_claim_id := l_claims_int_rec.split_from_claim_id;
	l_pvt_claims_int_rec.duplicate_claim_id := l_claims_int_rec.duplicate_claim_id;
	l_pvt_claims_int_rec.split_date := l_claims_int_rec.split_date;
	l_pvt_claims_int_rec.root_claim_id := l_claims_int_rec.root_claim_id;
	l_pvt_claims_int_rec.amount := l_claims_int_rec.amount;
	l_pvt_claims_int_rec.amount_adjusted := l_claims_int_rec.amount_adjusted;
	l_pvt_claims_int_rec.amount_remaining := l_claims_int_rec.amount_remaining;
	l_pvt_claims_int_rec.amount_settled := l_claims_int_rec.amount_settled;
	l_pvt_claims_int_rec.acctd_amount := l_claims_int_rec.acctd_amount;
	l_pvt_claims_int_rec.acctd_amount_remaining := l_claims_int_rec.acctd_amount_remaining;
	l_pvt_claims_int_rec.tax_amount := l_claims_int_rec.tax_amount;
	l_pvt_claims_int_rec.tax_code := l_claims_int_rec.tax_code;
	l_pvt_claims_int_rec.tax_calculation_flag := l_claims_int_rec.tax_calculation_flag;
	l_pvt_claims_int_rec.currency_code := l_claims_int_rec.currency_code;
	l_pvt_claims_int_rec.exchange_rate_type := l_claims_int_rec.exchange_rate_type;
	l_pvt_claims_int_rec.exchange_rate_date := l_claims_int_rec.exchange_rate_date;
	l_pvt_claims_int_rec.exchange_rate := l_claims_int_rec.exchange_rate;
	l_pvt_claims_int_rec.set_of_books_id := l_claims_int_rec.set_of_books_id;
	l_pvt_claims_int_rec.original_claim_date := l_claims_int_rec.original_claim_date;
	l_pvt_claims_int_rec.source_object_id := l_claims_int_rec.source_object_id;
	l_pvt_claims_int_rec.source_object_class := l_claims_int_rec.source_object_class;
	l_pvt_claims_int_rec.source_object_type_id := l_claims_int_rec.source_object_type_id;
	l_pvt_claims_int_rec.source_object_number := l_claims_int_rec.source_object_number;
	l_pvt_claims_int_rec.cust_account_id := l_claims_int_rec.cust_account_id;
	l_pvt_claims_int_rec.cust_billto_acct_site_id := l_claims_int_rec.cust_billto_acct_site_id;
	l_pvt_claims_int_rec.cust_shipto_acct_site_id := l_claims_int_rec.cust_shipto_acct_site_id;
	l_pvt_claims_int_rec.location_id := l_claims_int_rec.location_id;
	l_pvt_claims_int_rec.pay_related_account_flag := l_claims_int_rec.pay_related_account_flag;
	l_pvt_claims_int_rec.related_cust_account_id := l_claims_int_rec.related_cust_account_id;
	l_pvt_claims_int_rec.related_site_use_id := l_claims_int_rec.related_site_use_id;
	l_pvt_claims_int_rec.relationship_type := l_claims_int_rec.relationship_type;
	l_pvt_claims_int_rec.vendor_id := l_claims_int_rec.vendor_id;
	l_pvt_claims_int_rec.vendor_site_id := l_claims_int_rec.vendor_site_id;
	l_pvt_claims_int_rec.reason_type := l_claims_int_rec.reason_type;
	l_pvt_claims_int_rec.reason_code_id := l_claims_int_rec.reason_code_id;
	l_pvt_claims_int_rec.task_template_group_id := l_claims_int_rec.task_template_group_id;
	l_pvt_claims_int_rec.status_code := l_claims_int_rec.status_code;
	l_pvt_claims_int_rec.user_status_id := l_claims_int_rec.user_status_id;
	l_pvt_claims_int_rec.sales_rep_id := l_claims_int_rec.sales_rep_id;
	l_pvt_claims_int_rec.collector_id := l_claims_int_rec.collector_id;
	l_pvt_claims_int_rec.contact_id := l_claims_int_rec.contact_id;
	l_pvt_claims_int_rec.broker_id := l_claims_int_rec.broker_id;
	l_pvt_claims_int_rec.territory_id := l_claims_int_rec.territory_id;
	l_pvt_claims_int_rec.customer_ref_date := l_claims_int_rec.customer_ref_date;
	l_pvt_claims_int_rec.customer_ref_number := l_claims_int_rec.customer_ref_number;
	l_pvt_claims_int_rec.assigned_to := l_claims_int_rec.assigned_to;
	l_pvt_claims_int_rec.receipt_id := l_claims_int_rec.receipt_id;
	l_pvt_claims_int_rec.receipt_number := l_claims_int_rec.receipt_number;
	l_pvt_claims_int_rec.doc_sequence_id := l_claims_int_rec.doc_sequence_id;
	l_pvt_claims_int_rec.doc_sequence_value := l_claims_int_rec.doc_sequence_value;
	l_pvt_claims_int_rec.gl_date := l_claims_int_rec.gl_date;
	l_pvt_claims_int_rec.payment_method := l_claims_int_rec.payment_method;
	l_pvt_claims_int_rec.voucher_id := l_claims_int_rec.voucher_id;
	l_pvt_claims_int_rec.voucher_number := l_claims_int_rec.voucher_number;
	l_pvt_claims_int_rec.payment_reference_id := l_claims_int_rec.payment_reference_id;
	l_pvt_claims_int_rec.payment_reference_number := l_claims_int_rec.payment_reference_number;
	l_pvt_claims_int_rec.payment_reference_date := l_claims_int_rec.payment_reference_date;
	l_pvt_claims_int_rec.payment_status := l_claims_int_rec.payment_status;
	l_pvt_claims_int_rec.approved_flag := l_claims_int_rec.approved_flag;
	l_pvt_claims_int_rec.approved_date := l_claims_int_rec.approved_date;
	l_pvt_claims_int_rec.approved_by := l_claims_int_rec.approved_by;
	l_pvt_claims_int_rec.settled_date := l_claims_int_rec.settled_date;
	l_pvt_claims_int_rec.settled_by := l_claims_int_rec.settled_by;
	l_pvt_claims_int_rec.effective_date := l_claims_int_rec.effective_date;
	l_pvt_claims_int_rec.custom_setup_id := l_claims_int_rec.custom_setup_id;
	l_pvt_claims_int_rec.task_id := l_claims_int_rec.task_id;
	l_pvt_claims_int_rec.country_id := l_claims_int_rec.country_id;
	l_pvt_claims_int_rec.comments := l_claims_int_rec.comments;
	l_pvt_claims_int_rec.attribute_category := l_claims_int_rec.attribute_category;
	l_pvt_claims_int_rec.attribute1 := l_claims_int_rec.attribute1;
	l_pvt_claims_int_rec.attribute2 := l_claims_int_rec.attribute2;
	l_pvt_claims_int_rec.attribute3 := l_claims_int_rec.attribute3;
	l_pvt_claims_int_rec.attribute4 := l_claims_int_rec.attribute4;
	l_pvt_claims_int_rec.attribute5 := l_claims_int_rec.attribute5;
	l_pvt_claims_int_rec.attribute6 := l_claims_int_rec.attribute6;
	l_pvt_claims_int_rec.attribute7 := l_claims_int_rec.attribute7;
	l_pvt_claims_int_rec.attribute8 := l_claims_int_rec.attribute8;
	l_pvt_claims_int_rec.attribute9 := l_claims_int_rec.attribute9;
	l_pvt_claims_int_rec.attribute10 := l_claims_int_rec.attribute10;
	l_pvt_claims_int_rec.attribute11 := l_claims_int_rec.attribute11;
	l_pvt_claims_int_rec.attribute12 := l_claims_int_rec.attribute12;
	l_pvt_claims_int_rec.attribute13 := l_claims_int_rec.attribute13;
	l_pvt_claims_int_rec.attribute14 := l_claims_int_rec.attribute14;
	l_pvt_claims_int_rec.attribute15 := l_claims_int_rec.attribute15;
	l_pvt_claims_int_rec.deduction_attribute_category := l_claims_int_rec.deduction_attribute_category;
	l_pvt_claims_int_rec.deduction_attribute1 := l_claims_int_rec.deduction_attribute1;
	l_pvt_claims_int_rec.deduction_attribute2 := l_claims_int_rec.deduction_attribute2;
	l_pvt_claims_int_rec.deduction_attribute3 := l_claims_int_rec.deduction_attribute3;
	l_pvt_claims_int_rec.deduction_attribute4 := l_claims_int_rec.deduction_attribute4;
	l_pvt_claims_int_rec.deduction_attribute5 := l_claims_int_rec.deduction_attribute5;
	l_pvt_claims_int_rec.deduction_attribute6 := l_claims_int_rec.deduction_attribute6;
	l_pvt_claims_int_rec.deduction_attribute7 := l_claims_int_rec.deduction_attribute7;
	l_pvt_claims_int_rec.deduction_attribute8 := l_claims_int_rec.deduction_attribute8;
	l_pvt_claims_int_rec.deduction_attribute9 := l_claims_int_rec.deduction_attribute9;
	l_pvt_claims_int_rec.deduction_attribute10 := l_claims_int_rec.deduction_attribute10;
	l_pvt_claims_int_rec.deduction_attribute11 := l_claims_int_rec.deduction_attribute11;
	l_pvt_claims_int_rec.deduction_attribute12 := l_claims_int_rec.deduction_attribute12;
	l_pvt_claims_int_rec.deduction_attribute13 := l_claims_int_rec.deduction_attribute13;
	l_pvt_claims_int_rec.deduction_attribute14 := l_claims_int_rec.deduction_attribute14;
	l_pvt_claims_int_rec.deduction_attribute15 := l_claims_int_rec.deduction_attribute15;
	l_pvt_claims_int_rec.org_id := l_claims_int_rec.org_id;
      --
      -- API body
      --
    -- Calling Private package: Create_Claims_Int
    -- Hint: Primary key needs to be returned
     OZF_Claims_Int_PVT.Create_Claims_Int(
     p_api_version_number         => 1.0,
     p_init_msg_list              => FND_API.G_FALSE,
     p_commit                     => FND_API.G_FALSE,
     p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
     x_return_status              => x_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data,
     p_claims_int_rec  => l_pvt_claims_int_rec,
     x_interface_claim_id     => x_interface_claim_id);


      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          RAISE FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF g_debug THEN
         OZF_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');
      END IF;

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
     ROLLBACK TO CREATE_Claims_Int_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Claims_Int_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Claims_Int_PUB;
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
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_claims_int_rec               IN    claims_int_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Claims_Int';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number  NUMBER;
l_pvt_claims_int_rec  OZF_Claims_Int_PVT.claims_int_rec_type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Claims_Int_PUB;

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
      IF g_debug THEN
         OZF_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
    OZF_Claims_Int_PVT.Update_Claims_Int(
    p_api_version_number         => 1.0,
    p_init_msg_list              => FND_API.G_FALSE,
    p_commit                     => p_commit,
    p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
    x_return_status              => x_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data,
    p_claims_int_rec  =>  l_pvt_claims_int_rec,
    x_object_version_number      => l_object_version_number );


      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          RAISE FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
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
      IF g_debug THEN
         OZF_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');
      END IF;

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
     ROLLBACK TO UPDATE_Claims_Int_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Claims_Int_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Claims_Int_PUB;
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
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_interface_claim_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Claims_Int';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_INTERFACE_CLAIM_ID  NUMBER := p_INTERFACE_CLAIM_ID;
l_object_version_number  NUMBER := p_object_version_number;
l_pvt_claims_int_rec  OZF_Claims_Int_PVT.claims_int_rec_type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Claims_Int_PUB;

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
      IF g_debug THEN
         OZF_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
    OZF_Claims_Int_PVT.Delete_Claims_Int(
    p_api_version_number         => 1.0,
    p_init_msg_list              => FND_API.G_FALSE,
    p_commit                     => p_commit,
    p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
    x_return_status              => x_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data,
    p_interface_claim_id     => l_interface_claim_id,
    p_object_version_number      => l_object_version_number );


      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          RAISE FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
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
      IF g_debug THEN
         OZF_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');
      END IF;

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
     ROLLBACK TO DELETE_Claims_Int_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Claims_Int_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Claims_Int_PUB;
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

    p_interface_claim_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Claims_Int';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_pvt_claims_int_rec    OZF_Claims_Int_PVT.claims_int_rec_type;
 BEGIN

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
      IF g_debug THEN
         OZF_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
    -- Calling Private package: Create_Claims_Int
    -- Hint: Primary key needs to be returned
     OZF_Claims_Int_PVT.Lock_Claims_Int(
     p_api_version_number         => 1.0,
     p_init_msg_list              => FND_API.G_FALSE,
     x_return_status              => x_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data,
     p_interface_claim_id     => p_interface_claim_id,
     p_object_version             => p_object_version);


      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          RAISE FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      --
      -- End of API body.
      --

      -- Debug Message
      IF g_debug THEN
         OZF_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');
      END IF;

EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Claims_Int_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Claims_Int_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Claims_Int_PUB;
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


END OZF_Claims_Int_PUB;

/
