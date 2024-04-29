--------------------------------------------------------
--  DDL for Package Body OZF_CLAIM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CLAIM_PUB" as
/* $Header: ozfpclab.pls 120.3.12010000.6 2009/05/08 10:56:34 kpatro ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Claim_PUB
-- Purpose
--
-- History
--
-- NOTE
--
-- MODIFICATION HISTORY
--    KPATRO     26-Dec-2007      12.1 Enhancement: Price Protection
--                                Added a new column dpp_cust_account_id
--    KPATRO     17-Jan-2008      Added the PPVENDOR check for update claim
--    KPATRO     16-Apr-2008      Fix for bug 6965694
--    KPATRO     30-sep-2008      Fix for Bug 7443072
--    KPATRO     04-Apr-2009      Fix for Bug 8402328
--    KPATRO     17-Apr-2009	  Fix for Bug 8438651
--    KPATRO     08-May-2009      Fix for Bug 8501176
-- End of Comments
-- ===============================================================
G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Claim_PUB';
G_FILE_NAME CONSTANT VARCHAR2(14) := 'ozfpclab.pls';

G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);

---------------------------------------------------------------------
-- PROCEDURE
--    create_claim
--
-- PURPOSE
--    This procedure creates claim and claim line with unique ID's
--
-- PARAMETERS
--    p_claim_line_tbl
--    p_claim_rec
--    x_claim_id
--    x_return_status
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Create_Claim(
   p_api_version_number IN   NUMBER,
   p_init_msg_list      IN   VARCHAR2     := FND_API.G_FALSE,
   p_commit             IN   VARCHAR2     := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.g_valid_level_full,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count          OUT NOCOPY  NUMBER,
   x_msg_data           OUT NOCOPY  VARCHAR2,
   p_claim_rec          IN   claim_rec_type,
   p_claim_line_tbl     IN   claim_line_tbl_type,
   x_claim_id           OUT NOCOPY  NUMBER
)
IS
   L_API_NAME               CONSTANT VARCHAR2(30) := 'Create_Claim';
   L_API_VERSION_NUMBER     CONSTANT NUMBER   := 1.0;
   l_pvt_claim_rec          OZF_ClAIM_PVT.claim_rec_type;
   l_x_pvt_claim_rec        OZF_ClAIM_PVT.claim_rec_type;
   l_claim_rec              OZF_Claim_PUB.claim_rec_type  := p_claim_rec;
   l_claim_line_tbl         claim_line_tbl_type := p_claim_line_tbl;
   l_claim_line_rec         claim_line_rec_type ;
   l_pvt_line_rec           OZF_CLAIM_LINE_PVT.claim_line_rec_type;
   x_claim_LINE_id          NUMBER;
   l_error_index            NUMBER;
BEGIN
-- Standard Start of API savepoint
SAVEPOINT CREATE_Claim_PUB;
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
   OZF_UTILITY_PVT.debug_message('Public API: ' || l_api_name || ' pub start');
END IF;
-- Initialize API return status to SUCCESS
x_return_status := FND_API.G_RET_STS_SUCCESS;
--
-- API body
--
-- Construct the claim rec to pass to private api
--
   l_pvt_claim_rec.claim_id:=l_claim_rec.claim_id;
   l_pvt_claim_rec.object_version_number:=l_claim_rec.object_version_number;
   l_pvt_claim_rec.last_update_date:=l_claim_rec.last_update_date;
   l_pvt_claim_rec.last_updated_by:=l_claim_rec.last_updated_by;
   l_pvt_claim_rec.creation_date:=l_claim_rec.creation_date;
   l_pvt_claim_rec.created_by:=l_claim_rec.created_by;
   l_pvt_claim_rec.last_update_login:=l_claim_rec.last_update_login;
   l_pvt_claim_rec.request_id:=l_claim_rec.request_id;
   l_pvt_claim_rec.program_application_id:=l_claim_rec.program_application_id;
   l_pvt_claim_rec.program_update_date:=l_claim_rec.program_update_date;
   l_pvt_claim_rec.program_id:=l_claim_rec.program_id;
   l_pvt_claim_rec.created_from:=l_claim_rec.created_from;
   l_pvt_claim_rec.batch_id:=l_claim_rec.batch_id;
   l_pvt_claim_rec.claim_number:=l_claim_rec.claim_number;
   l_pvt_claim_rec.claim_type_id:=l_claim_rec.claim_type_id;
   l_pvt_claim_rec.claim_class:=l_claim_rec.claim_class;
   l_pvt_claim_rec.claim_date:=l_claim_rec.claim_date;
   l_pvt_claim_rec.due_date:=l_claim_rec.due_date;
   l_pvt_claim_rec.owner_id:=l_claim_rec.owner_id;
   l_pvt_claim_rec.history_event:=l_claim_rec.history_event;
   l_pvt_claim_rec.history_event_date:=l_claim_rec.history_event_date;
   l_pvt_claim_rec.history_event_description:=l_claim_rec.history_event_description;
   l_pvt_claim_rec.split_from_claim_id:=l_claim_rec.split_from_claim_id;
   l_pvt_claim_rec.duplicate_claim_id:=l_claim_rec.duplicate_claim_id;
   l_pvt_claim_rec.split_date:=l_claim_rec.split_date;
   l_pvt_claim_rec.root_claim_id:=l_claim_rec.root_claim_id;
   l_pvt_claim_rec.amount:=l_claim_rec.amount;
   l_pvt_claim_rec.amount_adjusted:=l_claim_rec.amount_adjusted;
   l_pvt_claim_rec.amount_remaining:=l_claim_rec.amount_remaining;
   l_pvt_claim_rec.amount_settled:=l_claim_rec.amount_settled;
   l_pvt_claim_rec.acctd_amount:=l_claim_rec.acctd_amount;
   l_pvt_claim_rec.acctd_amount_remaining:=l_claim_rec.acctd_amount_remaining;
   l_pvt_claim_rec.tax_amount:=l_claim_rec.tax_amount;
   l_pvt_claim_rec.tax_code:=l_claim_rec.tax_code;
   l_pvt_claim_rec.tax_calculation_flag:=l_claim_rec.tax_calculation_flag;
   l_pvt_claim_rec.currency_code:=l_claim_rec.currency_code;
   l_pvt_claim_rec.exchange_rate_type:=l_claim_rec.exchange_rate_type;
   l_pvt_claim_rec.exchange_rate_date:=l_claim_rec.exchange_rate_date;
   l_pvt_claim_rec.exchange_rate:=l_claim_rec.exchange_rate;
   l_pvt_claim_rec.set_of_books_id:=l_claim_rec.set_of_books_id;
   l_pvt_claim_rec.original_claim_date:=l_claim_rec.original_claim_date;
   l_pvt_claim_rec.source_object_id:=l_claim_rec.source_object_id;
   l_pvt_claim_rec.source_object_class:=l_claim_rec.source_object_class;
   l_pvt_claim_rec.source_object_type_id:=l_claim_rec.source_object_type_id;
   l_pvt_claim_rec.source_object_number:=l_claim_rec.source_object_number;
   l_pvt_claim_rec.cust_account_id:=l_claim_rec.cust_account_id;
   l_pvt_claim_rec.cust_billto_acct_site_id:=l_claim_rec.cust_billto_acct_site_id;
   l_pvt_claim_rec.cust_shipto_acct_site_id:=l_claim_rec.cust_shipto_acct_site_id;
   l_pvt_claim_rec.location_id:=l_claim_rec.location_id;
   l_pvt_claim_rec.pay_related_account_flag:=l_claim_rec.pay_related_account_flag;
   l_pvt_claim_rec.related_cust_account_id:=l_claim_rec.related_cust_account_id;
   l_pvt_claim_rec.related_site_use_id:=l_claim_rec.related_site_use_id;
   l_pvt_claim_rec.relationship_type:=l_claim_rec.relationship_type;
   l_pvt_claim_rec.vendor_id:=l_claim_rec.vendor_id;
   l_pvt_claim_rec.vendor_site_id:=l_claim_rec.vendor_site_id;
   l_pvt_claim_rec.reason_type:=l_claim_rec.reason_type;
   l_pvt_claim_rec.reason_code_id:=l_claim_rec.reason_code_id;
   l_pvt_claim_rec.task_template_group_id:=l_claim_rec.task_template_group_id;
   l_pvt_claim_rec.status_code:=l_claim_rec.status_code;
   l_pvt_claim_rec.user_status_id:=l_claim_rec.user_status_id;
   l_pvt_claim_rec.sales_rep_id:=l_claim_rec.sales_rep_id;
   l_pvt_claim_rec.collector_id:=l_claim_rec.collector_id;
   l_pvt_claim_rec.contact_id:=l_claim_rec.contact_id;
   l_pvt_claim_rec.broker_id:=l_claim_rec.broker_id;
   l_pvt_claim_rec.territory_id:=l_claim_rec.territory_id;
   l_pvt_claim_rec.customer_ref_date:=l_claim_rec.customer_ref_date;
   l_pvt_claim_rec.customer_ref_number:=l_claim_rec.customer_ref_number;
   l_pvt_claim_rec.assigned_to:=l_claim_rec.assigned_to;
   l_pvt_claim_rec.receipt_id:=l_claim_rec.receipt_id;
   l_pvt_claim_rec.receipt_number:=l_claim_rec.receipt_number;
   l_pvt_claim_rec.doc_sequence_id:=l_claim_rec.doc_sequence_id;
   l_pvt_claim_rec.doc_sequence_value:=l_claim_rec.doc_sequence_value;
   l_pvt_claim_rec.gl_date:=l_claim_rec.gl_date;
   l_pvt_claim_rec.payment_method:=l_claim_rec.payment_method;
   l_pvt_claim_rec.voucher_id:=l_claim_rec.voucher_id;
   l_pvt_claim_rec.voucher_number:=l_claim_rec.voucher_number;
   l_pvt_claim_rec.payment_reference_id:=l_claim_rec.payment_reference_id;
   l_pvt_claim_rec.payment_reference_number:=l_claim_rec.payment_reference_number;
   l_pvt_claim_rec.payment_reference_date:=l_claim_rec.payment_reference_date;
   l_pvt_claim_rec.payment_status:=l_claim_rec.payment_status;
   l_pvt_claim_rec.approved_flag:=l_claim_rec.approved_flag;
   l_pvt_claim_rec.approved_date:=l_claim_rec.approved_date;
   l_pvt_claim_rec.approved_by:=l_claim_rec.approved_by;
   l_pvt_claim_rec.settled_date:=l_claim_rec.settled_date;
   l_pvt_claim_rec.settled_by:=l_claim_rec.settled_by;
   l_pvt_claim_rec.effective_date:=l_claim_rec.effective_date;
   l_pvt_claim_rec.custom_setup_id:=l_claim_rec.custom_setup_id;
   l_pvt_claim_rec.task_id:=l_claim_rec.task_id;
   l_pvt_claim_rec.country_id:=l_claim_rec.country_id;
   l_pvt_claim_rec.order_type_id:=l_claim_rec.order_type_id;
   l_pvt_claim_rec.comments:=l_claim_rec.comments;
   l_pvt_claim_rec.attribute_category:=l_claim_rec.attribute_category;
   l_pvt_claim_rec.attribute1:=l_claim_rec.attribute1;
   l_pvt_claim_rec.attribute2:=l_claim_rec.attribute2;
   l_pvt_claim_rec.attribute3:=l_claim_rec.attribute3;
   l_pvt_claim_rec.attribute4:=l_claim_rec.attribute4;
   l_pvt_claim_rec.attribute5:=l_claim_rec.attribute5;
   l_pvt_claim_rec.attribute6:=l_claim_rec.attribute6;
   l_pvt_claim_rec.attribute7:=l_claim_rec.attribute7;
   l_pvt_claim_rec.attribute8:=l_claim_rec.attribute8;
   l_pvt_claim_rec.attribute9:=l_claim_rec.attribute9;
   l_pvt_claim_rec.attribute10:=l_claim_rec.attribute10;
   l_pvt_claim_rec.attribute11:=l_claim_rec.attribute11;
   l_pvt_claim_rec.attribute12:=l_claim_rec.attribute12;
   l_pvt_claim_rec.attribute13:=l_claim_rec.attribute13;
   l_pvt_claim_rec.attribute14:=l_claim_rec.attribute14;
   l_pvt_claim_rec.attribute15:=l_claim_rec.attribute15;
   l_pvt_claim_rec.deduction_attribute_category:=l_claim_rec.deduction_attribute_category;
   l_pvt_claim_rec.deduction_attribute1:=l_claim_rec.deduction_attribute1;
   l_pvt_claim_rec.deduction_attribute2:=l_claim_rec.deduction_attribute2;
   l_pvt_claim_rec.deduction_attribute3:=l_claim_rec.deduction_attribute3;
   l_pvt_claim_rec.deduction_attribute4:=l_claim_rec.deduction_attribute4;
   l_pvt_claim_rec.deduction_attribute5:=l_claim_rec.deduction_attribute5;
   l_pvt_claim_rec.deduction_attribute6:=l_claim_rec.deduction_attribute6;
   l_pvt_claim_rec.deduction_attribute7:=l_claim_rec.deduction_attribute7;
   l_pvt_claim_rec.deduction_attribute8:=l_claim_rec.deduction_attribute8;
   l_pvt_claim_rec.deduction_attribute9:=l_claim_rec.deduction_attribute9;
   l_pvt_claim_rec.deduction_attribute10:=l_claim_rec.deduction_attribute10;
   l_pvt_claim_rec.deduction_attribute11:=l_claim_rec.deduction_attribute11;
   l_pvt_claim_rec.deduction_attribute12:=l_claim_rec.deduction_attribute12;
   l_pvt_claim_rec.deduction_attribute13:=l_claim_rec.deduction_attribute13;
   l_pvt_claim_rec.deduction_attribute14:=l_claim_rec.deduction_attribute14;
   l_pvt_claim_rec.deduction_attribute15:=l_claim_rec.deduction_attribute15;
   l_pvt_claim_rec.org_id:=l_claim_rec.org_id;

   l_pvt_claim_rec.write_off_flag                  	:=l_claim_rec.write_off_flag;
   l_pvt_claim_rec.write_off_threshold_amount      	:=l_claim_rec.write_off_threshold_amount;
   l_pvt_claim_rec.under_write_off_threshold       	:=l_claim_rec.under_write_off_threshold;
   l_pvt_claim_rec.customer_reason                 	:=l_claim_rec.customer_reason;
   l_pvt_claim_rec.ship_to_cust_account_id         	:=l_claim_rec.ship_to_cust_account_id;
   l_pvt_claim_rec.amount_applied                  	:=l_claim_rec.amount_applied;
   l_pvt_claim_rec.applied_receipt_id              	:=l_claim_rec.applied_receipt_id;
   l_pvt_claim_rec.applied_receipt_number          	:=l_claim_rec.applied_receipt_number;
   l_pvt_claim_rec.wo_rec_trx_id                   	:=l_claim_rec.wo_rec_trx_id;
   l_pvt_claim_rec.group_claim_id                     :=l_claim_rec.group_claim_id;
   l_pvt_claim_rec.appr_wf_item_key                	:=l_claim_rec.appr_wf_item_key;
   l_pvt_claim_rec.cstl_wf_item_key                	:=l_claim_rec.cstl_wf_item_key;
   l_pvt_claim_rec.batch_type                      	:=l_claim_rec.batch_type;

--
-- Calling Private package: Create_Claim
-- Hint: Primary key needs to be returned
-- Check for default values befor creating claim.

   OZF_claim_PVT.Check_Claim_Common_Element (
      p_api_version      => p_api_version_number,
      p_init_msg_list    => p_init_msg_list,
      p_validation_level => p_validation_level,
      x_Return_Status      => x_return_status,
      x_Msg_Count          => x_msg_count,
      x_Msg_Data           => x_msg_data,
      p_claim              => l_pvt_claim_rec,
      x_claim              => l_x_pvt_claim_rec
   );
-- Check return status from the above procedure call
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   l_pvt_claim_rec := l_x_pvt_claim_rec;

-- OZF_UTILITY_PVT.debug_message('Call  Private APICreate Claim Procdure 1');
   OZF_claim_PVT.Create_Claim(
      p_api_version      => p_api_version_number,
      p_init_msg_list    => FND_API.G_FALSE,
      p_commit           => FND_API.G_FALSE,
      P_Validation_Level   => p_Validation_Level,
      X_Return_Status      => x_return_status,
      X_Msg_Count          => x_msg_count,
      X_Msg_Data           => x_msg_data,
      P_claim              => l_pvt_claim_rec,
      X_CLAIM_ID           => x_claim_id
   );
-- Check return status from the above procedure call
   IF x_return_status = FND_API.G_RET_STS_ERROR then
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF p_claim_line_tbl.count > 0 THEN
     l_claim_line_tbl := p_claim_line_tbl;
     FOR i IN p_claim_line_tbl.FIRST..p_claim_line_tbl.LAST LOOP
       l_claim_line_tbl(i).claim_id := x_claim_id;
     END LOOP;
   END IF;
-- Call create claim line procedure
   Create_Claim_Line_Tbl(
   p_api_version       => p_api_version_number
   ,p_init_msg_list    => FND_API.G_FALSE
   ,P_commit           => FND_API.G_FALSE
   ,p_validation_level => p_validation_level
   ,x_return_status          =>   x_return_status
   ,x_msg_data               =>   x_msg_data
   ,x_msg_count              =>   x_msg_count
   ,p_claim_line_tbl         =>   l_claim_line_tbl
   ,x_error_index            =>   l_error_index);
IF g_debug THEN
   ozf_utility_pvt.debug_message('return status for create_claim_line_tbl =>'||x_return_status);
END IF;
   IF x_return_status = FND_API.G_RET_STS_ERROR then
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
-- Debug Message
IF g_debug THEN
   OZF_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');
END IF;
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;
--OZF_UTILITY_PVT.DEBUG_MESSAGE('CLAIM_ID=>'||l_claim_line_rec.claim_id);
-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count          =>   x_msg_count,
   p_data           =>   x_msg_data
   );
EXCEPTION
WHEN OZF_Utility_PVT.resource_locked THEN
   ROLLBACK TO CREATE_Claim_PUB;
   x_return_status := FND_API.G_RET_STS_ERROR;
   OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO CREATE_Claim_PUB;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO CREATE_Claim_PUB;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
WHEN OTHERS THEN
   ROLLBACK TO CREATE_Claim_PUB;
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
End Create_Claim;
--Begin of create claim line
---------------------------------------------------------------------
-- PROCEDURE
--    create_claim_line_Tbl
--
-- PURPOSE
--    This procedure  claim line with unique ID's
--
-- PARAMETERS
--
--    p_claim_rec
--    x_claim_line_id
--    x_return_status
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Create_Claim_Line_Tbl(
   p_api_version             IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.g_false
   ,p_commit                 IN  VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN  NUMBER   := FND_API.g_valid_level_full
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_claim_line_tbl         IN  claim_line_tbl_type
   ,x_error_index            OUT NOCOPY   NUMBER
)
IS
   L_API_NAME               CONSTANT VARCHAR2(30) := 'Create_Claim_Line';
   L_API_VERSION_NUMBER     CONSTANT NUMBER   := 1.0;
   l_pvt_claim_line_rec     OZF_CLAIM_LINE_PVT.claim_line_rec_type;
   l_claim_LINE_id          NUMBER;
   l_claim_line_rec         claim_line_rec_type;
   l_error_index            NUMBER;
   l_pvt_claim_line_tbl     OZF_CLAIM_LINE_PVT.claim_line_tbl_type ;
   l_claim_line_tbl         OZF_CLAIM_PUB.claim_line_tbl_type := p_claim_line_tbl;
BEGIN
   SAVEPOINT Create_Claim_Line_Tbl;
-- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
      p_api_version,
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
      OZF_UTILITY_PVT.debug_message('Public API: ' || l_api_name || ' pub start');
   END IF;
-- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_claim_line_tbl.count > 0 THEN
   --
       l_claim_line_tbl := p_claim_line_tbl;
   FOR i IN p_claim_line_tbl.FIRST..p_claim_line_tbl.LAST LOOP
   --
     l_pvt_claim_line_tbl(i).claim_line_id               := l_claim_line_tbl(i).claim_line_id  ;
     l_pvt_claim_line_tbl(i).object_version_number       := l_claim_line_tbl(i).object_version_number;
     l_pvt_claim_line_tbl(i).last_update_date            := l_claim_line_tbl(i).last_update_date;
     l_pvt_claim_line_tbl(i).last_updated_by             := l_claim_line_tbl(i).last_updated_by ;
     l_pvt_claim_line_tbl(i).creation_date               := l_claim_line_tbl(i).creation_date ;
     l_pvt_claim_line_tbl(i).created_by                  := l_claim_line_tbl(i).created_by ;
     l_pvt_claim_line_tbl(i).last_update_login           := l_claim_line_tbl(i).last_update_login;
     l_pvt_claim_line_tbl(i).request_id                  := l_claim_line_tbl(i).request_id;
     l_pvt_claim_line_tbl(i).program_application_id      := l_claim_line_tbl(i).program_application_id;
     l_pvt_claim_line_tbl(i).program_update_date         := l_claim_line_tbl(i).program_update_date ;
     l_pvt_claim_line_tbl(i).program_id                  := l_claim_line_tbl(i).program_id;
     l_pvt_claim_line_tbl(i).created_from                := l_claim_line_tbl(i).created_from;
     l_pvt_claim_line_tbl(i).claim_id                    := l_claim_line_tbl(i).claim_id;
     l_pvt_claim_line_tbl(i).line_number                 := l_claim_line_tbl(i).line_number;
     l_pvt_claim_line_tbl(i).split_from_claim_line_id    := l_claim_line_tbl(i).split_from_claim_line_id;
     l_pvt_claim_line_tbl(i).amount                      := l_claim_line_tbl(i).amount;
     l_pvt_claim_line_tbl(i).claim_currency_amount       := l_claim_line_tbl(i).claim_currency_amount;
     l_pvt_claim_line_tbl(i).acctd_amount                := l_claim_line_tbl(i).acctd_amount;
     l_pvt_claim_line_tbl(i).currency_code               := l_claim_line_tbl(i).currency_code ;
     l_pvt_claim_line_tbl(i).exchange_rate_type          := l_claim_line_tbl(i).exchange_rate_type ;
     l_pvt_claim_line_tbl(i).exchange_rate_date          := l_claim_line_tbl(i).exchange_rate_date;
     l_pvt_claim_line_tbl(i).exchange_rate               := l_claim_line_tbl(i).exchange_rate;
     l_pvt_claim_line_tbl(i).set_of_books_id             := l_claim_line_tbl(i).set_of_books_id;
     l_pvt_claim_line_tbl(i).valid_flag                  := l_claim_line_tbl(i).valid_flag;
     l_pvt_claim_line_tbl(i).source_object_id            := l_claim_line_tbl(i).source_object_id;
     l_pvt_claim_line_tbl(i).source_object_class         := l_claim_line_tbl(i).source_object_class;
     l_pvt_claim_line_tbl(i).source_object_type_id       := l_claim_line_tbl(i).source_object_type_id;
     l_pvt_claim_line_tbl(i).source_object_line_id       := l_claim_line_tbl(i).source_object_line_id;
     l_pvt_claim_line_tbl(i).plan_id                     := l_claim_line_tbl(i).plan_id;
     l_pvt_claim_line_tbl(i).offer_id                    := l_claim_line_tbl(i).offer_id;
     l_pvt_claim_line_tbl(i).utilization_id              := l_claim_line_tbl(i).utilization_id;
     l_pvt_claim_line_tbl(i).payment_method              := l_claim_line_tbl(i).payment_method;
     l_pvt_claim_line_tbl(i).payment_reference_id        := l_claim_line_tbl(i).payment_reference_id;
     l_pvt_claim_line_tbl(i).payment_reference_number    := l_claim_line_tbl(i).payment_reference_number;
     l_pvt_claim_line_tbl(i).payment_reference_date      := l_claim_line_tbl(i).payment_reference_date;
     l_pvt_claim_line_tbl(i).voucher_id                  := l_claim_line_tbl(i).voucher_id;
     l_pvt_claim_line_tbl(i).voucher_number              := l_claim_line_tbl(i).voucher_number;
     l_pvt_claim_line_tbl(i).payment_status              := l_claim_line_tbl(i).payment_status;
     l_pvt_claim_line_tbl(i).approved_flag               := l_claim_line_tbl(i).approved_flag ;
     l_pvt_claim_line_tbl(i).approved_date               := l_claim_line_tbl(i).approved_date;
     l_pvt_claim_line_tbl(i).approved_by                 := l_claim_line_tbl(i).approved_by  ;
     l_pvt_claim_line_tbl(i).settled_date                := l_claim_line_tbl(i).settled_date;
     l_pvt_claim_line_tbl(i).settled_by                  := l_claim_line_tbl(i).settled_by;
     l_pvt_claim_line_tbl(i).performance_complete_flag   := l_claim_line_tbl(i).performance_complete_flag;
     l_pvt_claim_line_tbl(i).performance_attached_flag   := l_claim_line_tbl(i).performance_attached_flag;
     l_pvt_claim_line_tbl(i).item_id                     := l_claim_line_tbl(i).item_id;
     l_pvt_claim_line_tbl(i).item_description            := l_claim_line_tbl(i).item_description ;
     l_pvt_claim_line_tbl(i).quantity                    := l_claim_line_tbl(i).quantity;
     l_pvt_claim_line_tbl(i).quantity_uom                := l_claim_line_tbl(i).quantity_uom;
     l_pvt_claim_line_tbl(i).rate                        := l_claim_line_tbl(i).rate;
     l_pvt_claim_line_tbl(i).activity_type               := l_claim_line_tbl(i).activity_type;
     l_pvt_claim_line_tbl(i).activity_id                 := l_claim_line_tbl(i).activity_id;
     l_pvt_claim_line_tbl(i).related_cust_account_id     := l_claim_line_tbl(i).related_cust_account_id;
     l_pvt_claim_line_tbl(i).relationship_type           := l_claim_line_tbl(i).relationship_type;
     l_pvt_claim_line_tbl(i).earnings_associated_flag    := l_claim_line_tbl(i).earnings_associated_flag;
     l_pvt_claim_line_tbl(i).comments                    := l_claim_line_tbl(i).comments;
     l_pvt_claim_line_tbl(i).tax_code                    := l_claim_line_tbl(i).tax_code;
     l_pvt_claim_line_tbl(i).attribute_category          := l_claim_line_tbl(i).attribute_category;
     l_pvt_claim_line_tbl(i).attribute1                  := l_claim_line_tbl(i).attribute1;
     l_pvt_claim_line_tbl(i).attribute2                  := l_claim_line_tbl(i).attribute2;
     l_pvt_claim_line_tbl(i).attribute3                  := l_claim_line_tbl(i).attribute3;
     l_pvt_claim_line_tbl(i).attribute4                  := l_claim_line_tbl(i).attribute4;
     l_pvt_claim_line_tbl(i).attribute5                  := l_claim_line_tbl(i).attribute5;
     l_pvt_claim_line_tbl(i).attribute6                  := l_claim_line_tbl(i).attribute6;
     l_pvt_claim_line_tbl(i).attribute7                  := l_claim_line_tbl(i).attribute7;
     l_pvt_claim_line_tbl(i).attribute8                  := l_claim_line_tbl(i).attribute8;
     l_pvt_claim_line_tbl(i).attribute9                  := l_claim_line_tbl(i).attribute9;
     l_pvt_claim_line_tbl(i).attribute10                 := l_claim_line_tbl(i).attribute10;
     l_pvt_claim_line_tbl(i).attribute11                 := l_claim_line_tbl(i).attribute11;
     l_pvt_claim_line_tbl(i).attribute12                 := l_claim_line_tbl(i).attribute12;
     l_pvt_claim_line_tbl(i).attribute13                 := l_claim_line_tbl(i).attribute13;
     l_pvt_claim_line_tbl(i).attribute14                 := l_claim_line_tbl(i).attribute14;
     l_pvt_claim_line_tbl(i).attribute15                 := l_claim_line_tbl(i).attribute15;
     l_pvt_claim_line_tbl(i).org_id                      := l_claim_line_tbl(i).org_id ;
     l_pvt_claim_line_tbl(i).update_from_tbl_flag        := l_claim_line_tbl(i).update_from_tbl_flag;
     l_pvt_claim_line_tbl(i).tax_action	               := l_claim_line_tbl(i).tax_action;
     l_pvt_claim_line_tbl(i).sale_date	                  := l_claim_line_tbl(i).sale_date;
     l_pvt_claim_line_tbl(i).item_type	                  := l_claim_line_tbl(i).item_type;
     l_pvt_claim_line_tbl(i).tax_amount	               := l_claim_line_tbl(i).tax_amount;
     l_pvt_claim_line_tbl(i).claim_curr_tax_amount	      := l_claim_line_tbl(i).claim_curr_tax_amount;
     l_pvt_claim_line_tbl(i).activity_line_id	         := l_claim_line_tbl(i).activity_line_id;
     l_pvt_claim_line_tbl(i).offer_type	               := l_claim_line_tbl(i).offer_type;
     l_pvt_claim_line_tbl(i).prorate_earnings_flag	      := l_claim_line_tbl(i).prorate_earnings_flag;
     l_pvt_claim_line_tbl(i).earnings_end_date	         := l_claim_line_tbl(i).earnings_end_date;
     --12.1 Enhancement : Price Protection
     l_pvt_claim_line_tbl(i).dpp_cust_account_id	     := l_claim_line_tbl(i).dpp_cust_account_id;

    END LOOP;
   END IF;

-- call to create_claim_line_tbl
   Ozf_Claim_Line_Pvt.Create_Claim_Line_Tbl(
    p_api_version      => p_api_version
   ,p_init_msg_list    => FND_API.G_FALSE
   ,P_commit           => FND_API.G_FALSE
   ,p_validation_level => p_validation_level
   ,x_return_status          =>   x_return_status
   ,x_msg_data               =>   x_msg_data
   ,x_msg_count              =>   x_msg_count
   ,p_claim_line_tbl         =>   l_pvt_claim_line_tbl
   ,x_error_index            =>   l_error_index);
   IF g_debug THEN
      ozf_utility_pvt.debug_message('return status for create_claim_line_tbl =>'||x_return_status);
   END IF;
   IF x_return_status = FND_API.G_RET_STS_ERROR then
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
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
   ROLLBACK TO Create_Claim_Line_Tbl;
   x_return_status := FND_API.G_RET_STS_ERROR;
   OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Create_Claim_Line_Tbl;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Create_Claim_Line_Tbl;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
WHEN OTHERS THEN
   ROLLBACK TO Create_Claim_Line_Tbl;
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
End Create_Claim_Line_Tbl;

--BEGIN OF UPDATE CLAIM
---------------------------------------------------------------------
-- PROCEDURE
--   update_claim
--
-- PURPOSE
--    This procedure updates claim record by incrementing object version number
--
-- PARAMETERS
--
--    p_claim_line_tbl
--    x_object_version_number
--    x_return_status
--    p_claim_rec
-- NOTES
---------------------------------------------------------------------
PROCEDURE Update_Claim(
   p_api_version_number         IN    NUMBER,
   p_init_msg_list              IN    VARCHAR2     := FND_API.G_FALSE,
   p_commit                     IN    VARCHAR2     := FND_API.G_FALSE,
   p_validation_level           IN    NUMBER   := FND_API.g_valid_level_full,
   x_return_status              OUT NOCOPY   VARCHAR2,
   x_msg_count                  OUT NOCOPY   NUMBER,
   x_msg_data                   OUT NOCOPY   VARCHAR2,
   p_claim_rec                  IN    claim_rec_type,
   p_claim_line_tbl             IN    claim_line_tbl_type,
   x_object_version_number      OUT NOCOPY   NUMBER
)
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Claim';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_pvt_claim_rec             OZF_Claim_PVT.claim_rec_type;
   l_claim_rec                 OZF_CLAIM_PUB.claim_rec_type := p_claim_rec;
   l_claim_line_tbl            claim_line_tbl_type:=p_claim_line_tbl ;
   l_claim_line_rec            claim_line_rec_type;
   l_object_version_number     NUMBER;
   --l_pvt_claim_line_rec        OZF_CLAIM_LINE_PVT.claim_line_rec_type;
   --l_pvt_claim_line_tbl        OZF_CLAIM_LINE_PVT.claim_line_tbl_type ;
   x_object_version            NUMBER ;
   x_error_index               NUMBER;
-- Added for Bug 6727136
CURSOR Claim_Source_csr(p_claim_id in number) IS
SELECT source_object_class
FROM ozf_claims_all
WHERE claim_id = p_claim_id;

l_source_object_class VARCHAR2(30);

BEGIN
-- Standard Start of API savepoint
   SAVEPOINT SAVE_UPDATE_CLAIM_PUB;
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
--  Pass Public API values to Private API
   l_pvt_claim_rec.claim_id:=l_claim_rec.claim_id;
   l_pvt_claim_rec.object_version_number :=l_claim_rec.object_version_number;
   l_pvt_claim_rec.last_update_date:=l_claim_rec.last_update_date;
   l_pvt_claim_rec.last_updated_by:=l_claim_rec.last_updated_by;
   l_pvt_claim_rec.creation_date:=l_claim_rec.creation_date;
   l_pvt_claim_rec.created_by:=l_claim_rec.created_by;
   l_pvt_claim_rec.last_update_login:=l_claim_rec.last_update_login;
   l_pvt_claim_rec.request_id:=l_claim_rec.request_id;
   l_pvt_claim_rec.program_application_id:=l_claim_rec.program_application_id;
   l_pvt_claim_rec.program_update_date:=l_claim_rec.program_update_date;
   l_pvt_claim_rec.program_id:=l_claim_rec.program_id;
   l_pvt_claim_rec.created_from:=l_claim_rec.created_from;
   l_pvt_claim_rec.batch_id:=l_claim_rec.batch_id;
   l_pvt_claim_rec.claim_number:=l_claim_rec.claim_number;
   l_pvt_claim_rec.claim_type_id:=l_claim_rec.claim_type_id;
   l_pvt_claim_rec.claim_class:=l_claim_rec.claim_class;
   l_pvt_claim_rec.claim_date:=l_claim_rec.claim_date;
   l_pvt_claim_rec.due_date:=l_claim_rec.due_date;
   l_pvt_claim_rec.owner_id:=l_claim_rec.owner_id;
   l_pvt_claim_rec.history_event:=l_claim_rec.history_event;
   l_pvt_claim_rec.history_event_date:=l_claim_rec.history_event_date;
   l_pvt_claim_rec.history_event_description:=l_claim_rec.history_event_description;
   l_pvt_claim_rec.split_from_claim_id:=l_claim_rec.split_from_claim_id;
   l_pvt_claim_rec.duplicate_claim_id:=l_claim_rec.duplicate_claim_id;
   l_pvt_claim_rec.split_date:=l_claim_rec.split_date;
   l_pvt_claim_rec.root_claim_id:=l_claim_rec.root_claim_id;
   l_pvt_claim_rec.amount:=l_claim_rec.amount;
   l_pvt_claim_rec.amount_adjusted:=l_claim_rec.amount_adjusted;
   l_pvt_claim_rec.amount_remaining:=l_claim_rec.amount_remaining;
   l_pvt_claim_rec.amount_settled:=l_claim_rec.amount_settled;
   l_pvt_claim_rec.acctd_amount:=l_claim_rec.acctd_amount;
   l_pvt_claim_rec.acctd_amount_remaining:=l_claim_rec.acctd_amount_remaining;
   l_pvt_claim_rec.tax_amount:=l_claim_rec.tax_amount;
   l_pvt_claim_rec.tax_code:=l_claim_rec.tax_code;
   l_pvt_claim_rec.tax_calculation_flag:=l_claim_rec.tax_calculation_flag;
   l_pvt_claim_rec.currency_code:=l_claim_rec.currency_code;
   l_pvt_claim_rec.exchange_rate_type:=l_claim_rec.exchange_rate_type;
   l_pvt_claim_rec.exchange_rate_date:=l_claim_rec.exchange_rate_date;
   l_pvt_claim_rec.exchange_rate:=l_claim_rec.exchange_rate;
   l_pvt_claim_rec.set_of_books_id:=l_claim_rec.set_of_books_id;
   l_pvt_claim_rec.original_claim_date:=l_claim_rec.original_claim_date;
   l_pvt_claim_rec.source_object_id:=l_claim_rec.source_object_id;
   l_pvt_claim_rec.source_object_class:=l_claim_rec.source_object_class;
   l_pvt_claim_rec.source_object_type_id:=l_claim_rec.source_object_type_id;
   l_pvt_claim_rec.source_object_number:=l_claim_rec.source_object_number;
   l_pvt_claim_rec.cust_account_id:=l_claim_rec.cust_account_id;
   l_pvt_claim_rec.cust_billto_acct_site_id:=l_claim_rec.cust_billto_acct_site_id;
   l_pvt_claim_rec.cust_shipto_acct_site_id:=l_claim_rec.cust_shipto_acct_site_id;
   l_pvt_claim_rec.location_id:=l_claim_rec.location_id;
   l_pvt_claim_rec.pay_related_account_flag:=l_claim_rec.pay_related_account_flag;
   l_pvt_claim_rec.related_cust_account_id:=l_claim_rec.related_cust_account_id;
   l_pvt_claim_rec.related_site_use_id:=l_claim_rec.related_site_use_id;
   l_pvt_claim_rec.relationship_type:=l_claim_rec.relationship_type;
   l_pvt_claim_rec.vendor_id:=l_claim_rec.vendor_id;
   l_pvt_claim_rec.vendor_site_id:=l_claim_rec.vendor_site_id;
   l_pvt_claim_rec.reason_type:=l_claim_rec.reason_type;
   l_pvt_claim_rec.reason_code_id:=l_claim_rec.reason_code_id;
   l_pvt_claim_rec.task_template_group_id:=l_claim_rec.task_template_group_id;
   l_pvt_claim_rec.status_code:=l_claim_rec.status_code;
   l_pvt_claim_rec.user_status_id:=l_claim_rec.user_status_id;
   l_pvt_claim_rec.sales_rep_id:=l_claim_rec.sales_rep_id;
   l_pvt_claim_rec.collector_id:=l_claim_rec.collector_id;
   l_pvt_claim_rec.contact_id:=l_claim_rec.contact_id;
   l_pvt_claim_rec.broker_id:=l_claim_rec.broker_id;
   l_pvt_claim_rec.territory_id:=l_claim_rec.territory_id;
   l_pvt_claim_rec.customer_ref_date:=l_claim_rec.customer_ref_date;
   l_pvt_claim_rec.customer_ref_number:=l_claim_rec.customer_ref_number;
   l_pvt_claim_rec.assigned_to:=l_claim_rec.assigned_to;
   l_pvt_claim_rec.receipt_id:=l_claim_rec.receipt_id;
   l_pvt_claim_rec.receipt_number:=l_claim_rec.receipt_number;
   l_pvt_claim_rec.doc_sequence_id:=l_claim_rec.doc_sequence_id;
   l_pvt_claim_rec.doc_sequence_value:=l_claim_rec.doc_sequence_value;
   l_pvt_claim_rec.gl_date:=l_claim_rec.gl_date;
   l_pvt_claim_rec.payment_method:=l_claim_rec.payment_method;
   l_pvt_claim_rec.voucher_id:=l_claim_rec.voucher_id;
   l_pvt_claim_rec.voucher_number:=l_claim_rec.voucher_number;
   l_pvt_claim_rec.payment_reference_id:=l_claim_rec.payment_reference_id;
   l_pvt_claim_rec.payment_reference_number:=l_claim_rec.payment_reference_number;
   l_pvt_claim_rec.payment_reference_date:=l_claim_rec.payment_reference_date;
   l_pvt_claim_rec.payment_status:=l_claim_rec.payment_status;
   l_pvt_claim_rec.approved_flag:=l_claim_rec.approved_flag;
   l_pvt_claim_rec.approved_date:=l_claim_rec.approved_date;
   l_pvt_claim_rec.approved_by:=l_claim_rec.approved_by;
   l_pvt_claim_rec.settled_date:=l_claim_rec.settled_date;
   l_pvt_claim_rec.settled_by:=l_claim_rec.settled_by;
   l_pvt_claim_rec.effective_date:=l_claim_rec.effective_date;
   l_pvt_claim_rec.custom_setup_id:=l_claim_rec.custom_setup_id;
   l_pvt_claim_rec.task_id:=l_claim_rec.task_id;
   l_pvt_claim_rec.country_id:=l_claim_rec.country_id;
   l_pvt_claim_rec.order_type_id:=l_claim_rec.order_type_id;
   l_pvt_claim_rec.comments:=l_claim_rec.comments;
   l_pvt_claim_rec.attribute_category:=l_claim_rec.attribute_category;
   l_pvt_claim_rec.attribute1:=l_claim_rec.attribute1;
   l_pvt_claim_rec.attribute2:=l_claim_rec.attribute2;
   l_pvt_claim_rec.attribute3:=l_claim_rec.attribute3;
   l_pvt_claim_rec.attribute4:=l_claim_rec.attribute4;
   l_pvt_claim_rec.attribute5:=l_claim_rec.attribute5;
   l_pvt_claim_rec.attribute6:=l_claim_rec.attribute6;
   l_pvt_claim_rec.attribute7:=l_claim_rec.attribute7;
   l_pvt_claim_rec.attribute8:=l_claim_rec.attribute8;
   l_pvt_claim_rec.attribute9:=l_claim_rec.attribute9;
   l_pvt_claim_rec.attribute10:=l_claim_rec.attribute10;
   l_pvt_claim_rec.attribute11:=l_claim_rec.attribute11;
   l_pvt_claim_rec.attribute12:=l_claim_rec.attribute12;
   l_pvt_claim_rec.attribute13:=l_claim_rec.attribute13;
   l_pvt_claim_rec.attribute14:=l_claim_rec.attribute14;
   l_pvt_claim_rec.attribute15:=l_claim_rec.attribute15;
   l_pvt_claim_rec.deduction_attribute_category:=l_claim_rec.deduction_attribute_category;
   l_pvt_claim_rec.deduction_attribute1:=l_claim_rec.deduction_attribute1;
   l_pvt_claim_rec.deduction_attribute2:=l_claim_rec.deduction_attribute2;
   l_pvt_claim_rec.deduction_attribute3:=l_claim_rec.deduction_attribute3;
   l_pvt_claim_rec.deduction_attribute4:=l_claim_rec.deduction_attribute4;
   l_pvt_claim_rec.deduction_attribute5:=l_claim_rec.deduction_attribute5;
   l_pvt_claim_rec.deduction_attribute6:=l_claim_rec.deduction_attribute6;
   l_pvt_claim_rec.deduction_attribute7:=l_claim_rec.deduction_attribute7;
   l_pvt_claim_rec.deduction_attribute8:=l_claim_rec.deduction_attribute8;
   l_pvt_claim_rec.deduction_attribute9:=l_claim_rec.deduction_attribute9;
   l_pvt_claim_rec.deduction_attribute10:=l_claim_rec.deduction_attribute10;
   l_pvt_claim_rec.deduction_attribute11:=l_claim_rec.deduction_attribute11;
   l_pvt_claim_rec.deduction_attribute12:=l_claim_rec.deduction_attribute12;
   l_pvt_claim_rec.deduction_attribute13:=l_claim_rec.deduction_attribute13;
   l_pvt_claim_rec.deduction_attribute14:=l_claim_rec.deduction_attribute14;
   l_pvt_claim_rec.deduction_attribute15:=l_claim_rec.deduction_attribute15;
   l_pvt_claim_rec.org_id:=l_claim_rec.org_id;
   l_pvt_claim_rec.write_off_flag			      :=  l_claim_rec.write_off_flag;
   l_pvt_claim_rec.write_off_threshold_amount	:=  l_claim_rec.write_off_threshold_amount;
   l_pvt_claim_rec.under_write_off_threshold	   :=  l_claim_rec.under_write_off_threshold;
   l_pvt_claim_rec.customer_reason			      :=  l_claim_rec.customer_reason;
   l_pvt_claim_rec.ship_to_cust_account_id		:=  l_claim_rec.ship_to_cust_account_id;
   l_pvt_claim_rec.amount_applied			      :=  l_claim_rec.amount_applied;
   l_pvt_claim_rec.applied_receipt_id		      :=  l_claim_rec.applied_receipt_id;
   l_pvt_claim_rec.applied_receipt_number		   :=  l_claim_rec.applied_receipt_number;
   l_pvt_claim_rec.wo_rec_trx_id			         :=  l_claim_rec.wo_rec_trx_id;
   l_pvt_claim_rec.group_claim_id			      :=  l_claim_rec.group_claim_id;
   l_pvt_claim_rec.appr_wf_item_key		         :=  l_claim_rec.appr_wf_item_key;
   l_pvt_claim_rec.cstl_wf_item_key		         :=  l_claim_rec.cstl_wf_item_key;
   l_pvt_claim_rec.batch_type			            :=  l_claim_rec.batch_type;

--
   --l_pvt_claim_line_rec.update_from_tbl_flag:= l_claim_line_rec.update_from_tbl_flag;
   OZF_Claim_PVT.Update_Claim(
   p_api_version      => p_api_version_number,
   p_init_msg_list    => FND_API.G_FALSE,
   p_commit           => FND_API.G_FALSE,
   P_Validation_Level   => p_Validation_Level,
   x_return_status              => x_return_status,
   x_msg_count                  => x_msg_count,
   x_msg_data                   => x_msg_data,
   p_claim                      => l_pvt_claim_rec,
   p_event                      => 'UPDATE',
   p_mode                       => OZF_claim_Utility_pvt.G_AUTO_MODE,
   x_object_version_number      => x_object_version_number );
   IF g_debug THEN
      OZF_UTILITY_PVT.DEBUG_MESSAGE('OBJ VERSION NUMBER =>'||NVL(x_object_version_number,-99));
      OZF_UTILITY_PVT.DEBUG_MESSAGE('RETURN STATUS FOR UPDATE CLAIM =>'||X_RETURN_STATUS);
   END IF;
   -- Check return status from the above procedure call
   IF x_return_status = FND_API.G_RET_STS_ERROR then
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
--
--
-- In case claim id is not popluated.
   IF l_claim_line_tbl.count > 0 THEN
      FOR i IN l_claim_line_tbl.FIRST..l_claim_line_tbl.LAST LOOP
          l_claim_line_tbl(i).claim_id := l_claim_rec.claim_id;
      END LOOP;
   END IF;


     OPEN Claim_Source_csr(l_claim_rec.claim_id);
     FETCH Claim_Source_csr INTO l_source_object_class;
     ClOSE Claim_Source_csr;

   IF g_debug THEN
           OZF_UTILITY_PVT.DEBUG_MESSAGE('In Public API l_source_object_class =>'||l_source_object_class);
           OZF_UTILITY_PVT.DEBUG_MESSAGE('In Public API l_claim_rec.claim_id =>'||l_claim_rec.claim_id);
	   OZF_UTILITY_PVT.DEBUG_MESSAGE('In Public API l_claim_line_tbl.count =>'||l_claim_line_tbl.count);
    END IF;
   --Added for bug 6965694
   -- Added for bug 7443072

   IF (l_source_object_class NOT IN ('PPVENDOR','PPINCVENDOR')
       OR ( l_source_object_class IN ('PPVENDOR','PPINCVENDOR') AND l_claim_line_tbl.count >1))
   THEN
	   Update_Claim_Line_Tbl(
	    p_api_version      => p_api_version_number
	   ,p_init_msg_list    => FND_API.G_FALSE
	   ,p_commit           => FND_API.G_FALSE
	   ,P_Validation_Level   => p_Validation_Level
	   ,x_return_status          => x_return_status
	   ,x_msg_data               => x_msg_data
	   ,x_msg_count              => x_msg_count
	   ,p_claim_line_tbl         => l_claim_line_tbl
	   ,p_change_object_version  => FND_API.g_false -- Added For Fix
	   ,x_error_index            => x_error_index);
   END IF;
   --OZF_UTILITY_PVT.DEBUG_MESSAGE('OBJ VERSION  =>'||NVL(x_object_version,-99));
   IF g_debug THEN
      OZF_UTILITY_PVT.DEBUG_MESSAGE('Return Status for Update claim line =>'||x_return_status);
   END IF;
   IF x_return_status = FND_API.G_RET_STS_ERROR then
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

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
   ROLLBACK TO SAVE_UPDATE_CLAIM_PUB;
   x_return_status := FND_API.g_ret_sts_error;
   OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO SAVE_UPDATE_CLAIM_PUB;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO SAVE_UPDATE_CLAIM_PUB;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
WHEN OTHERS THEN
   ROLLBACK TO SAVE_UPDATE_CLAIM_PUB;
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
End Update_Claim;

---------------------------------------------------------------------
-- PROCEDURE
--    Update_Claim_Line_Tbl
--
-- PURPOSE
--    This procedure updates claim lines
--
-- PARAMETERS
--    p_claim_line_tbl
--    p_change_object_version  IN    VARCHAR2 := FND_API.g_false
--    x_error_index
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Update_Claim_Line_Tbl(
   p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_claim_line_tbl         IN    claim_line_tbl_type
   ,p_change_object_version  IN    VARCHAR2 := FND_API.g_false
   ,x_error_index            OUT NOCOPY   NUMBER
)
IS
   L_API_NAME               CONSTANT VARCHAR2(30) := 'Update_Claim_Line';
   L_API_VERSION_NUMBER     CONSTANT NUMBER   := 1.0;
   l_pvt_claim_line_rec     OZF_CLAIM_LINE_PVT.claim_line_rec_type;
   l_claim_line_tbl         OZF_CLAIM_PUB.claim_line_tbl_type:=p_claim_line_tbl;
   l_pvt_claim_line_tbl     OZF_CLAIM_LINE_PVT.claim_line_tbl_type ;
   l_error_index            NUMBER;
   l_temp_line_rec          OZF_CLAIM_LINE_PVT.claim_line_rec_type;
BEGIN
   SAVEPOINT Update_Claim_Line_Tbl;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
      p_api_version,
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
   l_claim_line_tbl := p_claim_line_tbl;

   IF p_claim_line_tbl.COUNT > 0 THEN
   FOR i IN p_claim_line_tbl.FIRST..p_claim_line_tbl.LAST LOOP
   --
     l_pvt_claim_line_tbl(i).claim_line_id               := l_claim_line_tbl(i).claim_line_id  ;

     IF l_claim_line_tbl(i).object_version_number is null then
        l_pvt_claim_line_tbl(i).object_version_number    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).object_version_number    :=l_claim_line_tbl(i).object_version_number;
     END IF;

     IF l_claim_line_tbl(i).last_update_date is null then
        l_pvt_claim_line_tbl(i).last_update_date    := FND_API.G_MISS_DATE;
     ELSE
        l_pvt_claim_line_tbl(i).last_update_date    :=l_claim_line_tbl(i).last_update_date;
     END IF;

     IF l_claim_line_tbl(i).last_updated_by is null then
        l_pvt_claim_line_tbl(i).last_updated_by    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).last_updated_by    :=l_claim_line_tbl(i).last_updated_by;
     END IF;

     IF l_claim_line_tbl(i).creation_date is null then
        l_pvt_claim_line_tbl(i).creation_date    := FND_API.G_MISS_DATE;
     ELSE
        l_pvt_claim_line_tbl(i).creation_date    :=l_claim_line_tbl(i).creation_date;
     END IF;

     IF l_claim_line_tbl(i).created_by is null then
        l_pvt_claim_line_tbl(i).created_by    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).created_by    :=l_claim_line_tbl(i).created_by;
     END IF;

     IF l_claim_line_tbl(i).last_update_login is null then
        l_pvt_claim_line_tbl(i).last_update_login    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).last_update_login    :=l_claim_line_tbl(i).last_update_login;
     END IF;

     IF l_claim_line_tbl(i).request_id is null then
        l_pvt_claim_line_tbl(i).request_id    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).request_id    :=l_claim_line_tbl(i).request_id;
     END IF;

     IF l_claim_line_tbl(i).program_application_id is null then
        l_pvt_claim_line_tbl(i).program_application_id    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).program_application_id    :=l_claim_line_tbl(i).program_application_id;
     END IF;

     IF l_claim_line_tbl(i).program_update_date is null then
        l_pvt_claim_line_tbl(i).program_update_date    := FND_API.G_MISS_DATE;
     ELSE
        l_pvt_claim_line_tbl(i).program_update_date    :=l_claim_line_tbl(i).program_update_date;
     END IF;

     IF l_claim_line_tbl(i).program_id is null then
        l_pvt_claim_line_tbl(i).program_id    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).program_id    :=l_claim_line_tbl(i).program_id;
     END IF;

     IF l_claim_line_tbl(i).created_from is null then
        l_pvt_claim_line_tbl(i).created_from    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).created_from    :=l_claim_line_tbl(i).created_from;
     END IF;

     IF l_claim_line_tbl(i).claim_id is null then
        l_pvt_claim_line_tbl(i).claim_id    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).claim_id    :=l_claim_line_tbl(i).claim_id;
     END IF;

     IF l_claim_line_tbl(i).line_number is null then
        l_pvt_claim_line_tbl(i).line_number              := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).line_number              :=l_claim_line_tbl(i).line_number;
     END IF;

     IF l_claim_line_tbl(i).split_from_claim_line_id is null then
        l_pvt_claim_line_tbl(i).split_from_claim_line_id    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).split_from_claim_line_id    :=l_claim_line_tbl(i).split_from_claim_line_id;
     END IF;

     IF l_claim_line_tbl(i).amount is null then
        l_pvt_claim_line_tbl(i).amount    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).amount    :=l_claim_line_tbl(i).amount;
     END IF;

     IF l_claim_line_tbl(i).claim_currency_amount is null then
        l_pvt_claim_line_tbl(i).claim_currency_amount    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).claim_currency_amount    :=l_claim_line_tbl(i).claim_currency_amount;
     END IF;

     IF l_claim_line_tbl(i).acctd_amount is null then
        l_pvt_claim_line_tbl(i).acctd_amount    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).acctd_amount   :=l_claim_line_tbl(i).acctd_amount;
     END IF;

     IF l_claim_line_tbl(i).currency_code is null then
        l_pvt_claim_line_tbl(i).currency_code    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).currency_code    :=l_claim_line_tbl(i).currency_code;
     END IF;

     IF l_claim_line_tbl(i).exchange_rate_type is null then
        l_pvt_claim_line_tbl(i).exchange_rate_type    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).exchange_rate_type    :=l_claim_line_tbl(i).exchange_rate_type;
     END IF;

     IF l_claim_line_tbl(i).exchange_rate_date is null then
        l_pvt_claim_line_tbl(i).exchange_rate_date    := FND_API.G_MISS_DATE;
     ELSE
        l_pvt_claim_line_tbl(i).exchange_rate_date    :=l_claim_line_tbl(i).exchange_rate_date;
     END IF;

     IF l_claim_line_tbl(i).exchange_rate is null then
        l_pvt_claim_line_tbl(i).exchange_rate    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).exchange_rate    :=l_claim_line_tbl(i).exchange_rate;
     END IF;

     IF l_claim_line_tbl(i).set_of_books_id is null then
        l_pvt_claim_line_tbl(i).set_of_books_id    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).set_of_books_id    :=l_claim_line_tbl(i).set_of_books_id;
     END IF;

     IF l_claim_line_tbl(i).valid_flag is null then
        l_pvt_claim_line_tbl(i).valid_flag    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).valid_flag    :=l_claim_line_tbl(i).valid_flag;
     END IF;

     IF l_claim_line_tbl(i).source_object_id is null then
        l_pvt_claim_line_tbl(i).source_object_id    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).source_object_id    :=l_claim_line_tbl(i).source_object_id;
     END IF;

     IF l_claim_line_tbl(i).source_object_class is null then
        l_pvt_claim_line_tbl(i).source_object_class    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).source_object_class    :=l_claim_line_tbl(i).source_object_class;
     END IF;

     IF l_claim_line_tbl(i).source_object_type_id  is null then
        l_pvt_claim_line_tbl(i).source_object_type_id     := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).source_object_type_id     :=l_claim_line_tbl(i).source_object_type_id ;
     END IF;

     IF l_claim_line_tbl(i).source_object_line_id is null then
        l_pvt_claim_line_tbl(i).source_object_line_id    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).source_object_line_id    :=l_claim_line_tbl(i).source_object_line_id;
     END IF;

     IF l_claim_line_tbl(i).plan_id is null then
        l_pvt_claim_line_tbl(i).plan_id    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).plan_id    :=l_claim_line_tbl(i).plan_id;
     END IF;

     IF l_claim_line_tbl(i).offer_id is null then
        l_pvt_claim_line_tbl(i).offer_id    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).offer_id    :=l_claim_line_tbl(i).offer_id;
     END IF;

     IF l_claim_line_tbl(i).utilization_id is null then
        l_pvt_claim_line_tbl(i).utilization_id    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).utilization_id   :=l_claim_line_tbl(i).utilization_id;
     END IF;

     IF l_claim_line_tbl(i).payment_method is null then
        l_pvt_claim_line_tbl(i).payment_method    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).payment_method    :=l_claim_line_tbl(i).payment_method;
     END IF;

     IF l_claim_line_tbl(i).payment_reference_id is null then
        l_pvt_claim_line_tbl(i).payment_reference_id    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).payment_reference_id    :=l_claim_line_tbl(i).payment_reference_id;
     END IF;

     IF l_claim_line_tbl(i).payment_reference_number is null then
        l_pvt_claim_line_tbl(i).payment_reference_number    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).payment_reference_number    :=l_claim_line_tbl(i).payment_reference_number;
     END IF;

     IF l_claim_line_tbl(i).payment_reference_date is null then
        l_pvt_claim_line_tbl(i).payment_reference_date    := FND_API.G_MISS_DATE;
     ELSE
        l_pvt_claim_line_tbl(i).payment_reference_date    :=l_claim_line_tbl(i).payment_reference_date;
     END IF;

     IF l_claim_line_tbl(i).voucher_id is null then
        l_pvt_claim_line_tbl(i).voucher_id    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).voucher_id   :=l_claim_line_tbl(i).voucher_id;
     END IF;

     IF l_claim_line_tbl(i).voucher_number is null then
        l_pvt_claim_line_tbl(i).voucher_number    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).voucher_number    :=l_claim_line_tbl(i).voucher_number;
     END IF;

     IF l_claim_line_tbl(i).payment_status is null then
        l_pvt_claim_line_tbl(i).payment_status    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).payment_status    :=l_claim_line_tbl(i).payment_status;
     END IF;

     IF l_claim_line_tbl(i).approved_flag is null then
        l_pvt_claim_line_tbl(i).approved_flag    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).approved_flag    :=l_claim_line_tbl(i).approved_flag;
     END IF;

     IF l_claim_line_tbl(i).approved_date is null then
        l_pvt_claim_line_tbl(i).approved_date    := FND_API.G_MISS_DATE;
     ELSE
        l_pvt_claim_line_tbl(i).approved_date    :=l_claim_line_tbl(i).approved_date;
     END IF;

     IF l_claim_line_tbl(i).approved_by is null then
        l_pvt_claim_line_tbl(i).approved_by    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).approved_by    :=l_claim_line_tbl(i).approved_by;
     END IF;

     IF l_claim_line_tbl(i).settled_date is null then
        l_pvt_claim_line_tbl(i).settled_date    := FND_API.G_MISS_DATE;
     ELSE
        l_pvt_claim_line_tbl(i).settled_date   :=l_claim_line_tbl(i).settled_date;
     END IF;

     IF l_claim_line_tbl(i).settled_by  is null then
        l_pvt_claim_line_tbl(i).settled_by    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).settled_by     :=l_claim_line_tbl(i).settled_by ;
     END IF;

     IF l_claim_line_tbl(i).performance_complete_flag is null then
        l_pvt_claim_line_tbl(i).performance_complete_flag    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).performance_complete_flag    :=l_claim_line_tbl(i).performance_complete_flag;
     END IF;

     IF l_claim_line_tbl(i).performance_attached_flag is null then
        l_pvt_claim_line_tbl(i).performance_attached_flag    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).performance_attached_flag    :=l_claim_line_tbl(i).performance_attached_flag;
     END IF;

     IF l_claim_line_tbl(i).item_id is null then
        l_pvt_claim_line_tbl(i).item_id    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).item_id    :=l_claim_line_tbl(i).item_id;
     END IF;

     IF l_claim_line_tbl(i).item_description is null then
        l_pvt_claim_line_tbl(i).item_description    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).item_description    :=l_claim_line_tbl(i).item_description;
     END IF;

     IF l_claim_line_tbl(i).quantity is null then
        l_pvt_claim_line_tbl(i).quantity    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).quantity   :=l_claim_line_tbl(i).quantity;
     END IF;

     IF l_claim_line_tbl(i).quantity_uom is null then
        l_pvt_claim_line_tbl(i).quantity_uom    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).quantity_uom   :=l_claim_line_tbl(i).quantity_uom;
     END IF;

     IF l_claim_line_tbl(i).rate is null then
        l_pvt_claim_line_tbl(i).rate    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).rate    :=l_claim_line_tbl(i).rate;
     END IF;

     IF l_claim_line_tbl(i).activity_type is null then
        l_pvt_claim_line_tbl(i).activity_type    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).activity_type    :=l_claim_line_tbl(i).activity_type;
     END IF;

     IF l_claim_line_tbl(i).activity_id is null then
        l_pvt_claim_line_tbl(i).activity_id    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).activity_id    :=l_claim_line_tbl(i).activity_id;
     END IF;

     IF l_claim_line_tbl(i).related_cust_account_id is null then
        l_pvt_claim_line_tbl(i).related_cust_account_id    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).related_cust_account_id   :=l_claim_line_tbl(i).related_cust_account_id;
     END IF;

     IF l_claim_line_tbl(i).relationship_type is null then
        l_pvt_claim_line_tbl(i).relationship_type    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).relationship_type    :=l_claim_line_tbl(i).relationship_type;
     END IF;

     IF l_claim_line_tbl(i).earnings_associated_flag is null then
        l_pvt_claim_line_tbl(i).earnings_associated_flag    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).earnings_associated_flag    :=l_claim_line_tbl(i).earnings_associated_flag;
     END IF;

     IF l_claim_line_tbl(i).comments is null then
        l_pvt_claim_line_tbl(i).comments    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).comments    :=l_claim_line_tbl(i).comments;
     END IF;

     IF l_claim_line_tbl(i).tax_code is null then
        l_pvt_claim_line_tbl(i).tax_code    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).tax_code    :=l_claim_line_tbl(i).tax_code;
     END IF;

     IF l_claim_line_tbl(i).attribute_category is null then
        l_pvt_claim_line_tbl(i).attribute_category    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).attribute_category    :=l_claim_line_tbl(i).attribute_category;
     END IF;

     IF l_claim_line_tbl(i).attribute1 is null then
        l_pvt_claim_line_tbl(i).attribute1    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).attribute1    :=l_claim_line_tbl(i).attribute1;
     END IF;

     IF l_claim_line_tbl(i).attribute2 is null then
        l_pvt_claim_line_tbl(i).attribute2    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).attribute2    :=l_claim_line_tbl(i).attribute2;
     END IF;

     IF l_claim_line_tbl(i).attribute3 is null then
        l_pvt_claim_line_tbl(i).attribute3   := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).attribute3   :=l_claim_line_tbl(i).attribute3;
     END IF;

     IF l_claim_line_tbl(i).attribute4 is null then
        l_pvt_claim_line_tbl(i).attribute4    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).attribute4   :=l_claim_line_tbl(i).attribute4;
     END IF;

     IF l_claim_line_tbl(i).attribute5 is null then
        l_pvt_claim_line_tbl(i).attribute5    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).attribute5    :=l_claim_line_tbl(i).attribute5;
     END IF;

     IF l_claim_line_tbl(i).attribute6 is null then
        l_pvt_claim_line_tbl(i).attribute6    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).attribute6   :=l_claim_line_tbl(i).attribute6;
     END IF;

     IF l_claim_line_tbl(i).attribute7 is null then
        l_pvt_claim_line_tbl(i).attribute7    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).attribute7   :=l_claim_line_tbl(i).attribute7;
     END IF;

     IF l_claim_line_tbl(i).attribute8 is null then
        l_pvt_claim_line_tbl(i).attribute8    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).attribute8    :=l_claim_line_tbl(i).attribute8;
     END IF;

     IF l_claim_line_tbl(i).attribute9 is null then
        l_pvt_claim_line_tbl(i).attribute9    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).attribute9    :=l_claim_line_tbl(i).attribute9;
     END IF;

     IF l_claim_line_tbl(i).attribute10 is null then
        l_pvt_claim_line_tbl(i).attribute10    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).attribute10    :=l_claim_line_tbl(i).attribute10;
     END IF;

     IF l_claim_line_tbl(i).attribute11 is null then
        l_pvt_claim_line_tbl(i).attribute11    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).attribute11    :=l_claim_line_tbl(i).attribute11;
     END IF;

     IF l_claim_line_tbl(i).attribute12 is null then
        l_pvt_claim_line_tbl(i).attribute12    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).attribute12   :=l_claim_line_tbl(i).attribute12;
     END IF;

     IF l_claim_line_tbl(i).attribute13 is null then
        l_pvt_claim_line_tbl(i).attribute13    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).attribute13  :=l_claim_line_tbl(i).attribute13;
     END IF;

     IF l_claim_line_tbl(i).attribute14 is null then
        l_pvt_claim_line_tbl(i).attribute14    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).attribute14    :=l_claim_line_tbl(i).attribute14;
     END IF;

     IF l_claim_line_tbl(i).attribute15 is null then
        l_pvt_claim_line_tbl(i).attribute15    := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).attribute15    :=l_claim_line_tbl(i).attribute15;
     END IF;

     IF l_claim_line_tbl(i).org_id is null then
        l_pvt_claim_line_tbl(i).org_id    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).org_id    :=l_claim_line_tbl(i).org_id;
     END IF;

     IF l_claim_line_tbl(i).update_from_tbl_flag is null then
        l_pvt_claim_line_tbl(i).update_from_tbl_flag   := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).update_from_tbl_flag   :=l_claim_line_tbl(i).update_from_tbl_flag;
     END IF;

     IF l_claim_line_tbl(i).tax_action is null then
        l_pvt_claim_line_tbl(i).tax_action   := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).tax_action   :=l_claim_line_tbl(i).tax_action;
     END IF;

     IF l_claim_line_tbl(i).sale_date is null then
        l_pvt_claim_line_tbl(i).sale_date    := FND_API.G_MISS_DATE;
     ELSE
        l_pvt_claim_line_tbl(i).sale_date   :=l_claim_line_tbl(i).sale_date;
     END IF;

     IF l_claim_line_tbl(i).item_type is null then
        l_pvt_claim_line_tbl(i).item_type   := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).item_type   :=l_claim_line_tbl(i).item_type;
     END IF;

     IF l_claim_line_tbl(i).tax_amount is null then
        l_pvt_claim_line_tbl(i).tax_amount    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).tax_amount    :=l_claim_line_tbl(i).tax_amount;
     END IF;

     IF l_claim_line_tbl(i).claim_curr_tax_amount is null then
        l_pvt_claim_line_tbl(i).claim_curr_tax_amount    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).claim_curr_tax_amount    :=l_claim_line_tbl(i).claim_curr_tax_amount;
     END IF;

     IF l_claim_line_tbl(i).activity_line_id is null then
        l_pvt_claim_line_tbl(i).activity_line_id    := FND_API.G_MISS_NUM;
     ELSE
        l_pvt_claim_line_tbl(i).activity_line_id    :=l_claim_line_tbl(i).activity_line_id;
     END IF;

     IF l_claim_line_tbl(i).offer_type is null then
        l_pvt_claim_line_tbl(i).offer_type   := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).offer_type   :=l_claim_line_tbl(i).offer_type;
     END IF;

     IF l_claim_line_tbl(i).prorate_earnings_flag is null then
        l_pvt_claim_line_tbl(i).prorate_earnings_flag   := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).prorate_earnings_flag   :=l_claim_line_tbl(i).prorate_earnings_flag;
     END IF;

     IF l_claim_line_tbl(i).earnings_end_date is null then
        l_pvt_claim_line_tbl(i).earnings_end_date    := FND_API.G_MISS_DATE;
     ELSE
        l_pvt_claim_line_tbl(i).earnings_end_date   :=l_claim_line_tbl(i).earnings_end_date;
     END IF;
     --12.1 Enhancement : Price Protection
     IF l_claim_line_tbl(i).dpp_cust_account_id is null then
        l_pvt_claim_line_tbl(i).dpp_cust_account_id   := FND_API.G_MISS_CHAR;
     ELSE
        l_pvt_claim_line_tbl(i).dpp_cust_account_id   :=l_claim_line_tbl(i).dpp_cust_account_id;
     END IF;
    END LOOP;
   END IF;

-- Call to Update claim line tbl.
   Ozf_Claim_Line_Pvt.Update_Claim_line_Tbl(
    p_api_version        => p_api_version
   ,p_init_msg_list      => FND_API.G_FALSE
   ,p_commit             => FND_API.G_FALSE
   ,P_Validation_Level   => p_Validation_Level
   ,x_return_status          =>   x_return_status
   ,x_msg_data               =>   x_msg_data
   ,x_msg_count              =>   x_msg_count
   ,p_claim_line_tbl         =>   l_pvt_claim_line_tbl
   ,p_change_object_version  =>   FND_API.g_false
   ,x_error_index            =>   l_error_index );
   IF g_debug THEN
      OZF_UTILITY_PVT.DEBUG_MESSAGE('sTATUS FOR Update claim line =>'||x_return_status);
   END IF;
   IF x_return_status = FND_API.G_RET_STS_ERROR then
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
--Standard check for p_commit
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
   ROLLBACK TO Update_Claim_Line_Tbl;
   x_return_status := FND_API.g_ret_sts_error;
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Update_Claim_Line_Tbl;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Update_Claim_Line_Tbl;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
WHEN OTHERS THEN
   ROLLBACK TO Update_Claim_Line_Tbl;
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
End Update_Claim_Line_tbl;
/*End of Update Claim Line*/
---------------------------------------------------------------------
-- PROCEDURE
--   delete_claim
--
-- PURPOSE
--    This procedure deletes claim record when Claim_Id and Object Version Number are provided.
--
-- PARAMETERS
--
--    x_msg_count
--    x_object_version_number
--    x_return_status
--    p_claim_id
--    p_object_version_number
-- NOTES
---------------------------------------------------------------------
PROCEDURE Delete_Claim(
   p_api_version_number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
   p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
   p_validation_level           IN    NUMBER   := FND_API.g_valid_level_full,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2,
   p_claim_id                   IN  NUMBER,
   p_object_version_number      IN   NUMBER
)
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Claim';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_object_version_NUMBER     NUMBER:=p_object_version_number;
   l_claim_id                  NUMBER:=p_claim_id;
BEGIN
-- Standard Start of API savepoint
   SAVEPOINT DELETE_Claim_PUB;
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
-- Calling private API
--
   OZF_Claim_PVT.Delete_Claim(
    p_api_version_number     => p_api_version_number,
    p_init_msg_list          => FND_API.G_FALSE,
    p_commit                 => FND_API.G_FALSE,
    p_object_id              => l_claim_id,
    p_object_version_number  => l_object_version_number,
    x_return_status          => x_return_status,
    x_msg_count              => x_msg_count,
    x_msg_data               => x_msg_data
    );
--
   IF g_debug THEN
      OZF_UTILITY_PVT.DEBUG_MESSAGE('RETURN STATUS FOR DELETE_CLAIM =>'||X_RETURN_STATUS);
   END IF;
-- Check return status from the above procedure call
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
   ROLLBACK TO DELETE_Claim_PUB;
   x_return_status := FND_API.g_ret_sts_error;
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO DELETE_Claim_PUB;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO DELETE_Claim_PUB;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
WHEN OTHERS THEN
   ROLLBACK TO DELETE_Claim_PUB;
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
   End Delete_Claim;
---------------------------------------------------------------------
-- PROCEDURE
--   Delete_Claim_Line_Tbl
--
-- PURPOSE
--    This procedure deletes claim line records
--
-- PARAMETERS
--
--    x_msg_count
--    x_object_version_number
--    x_return_status
--    p_claim_line_tbl
--    p_object_version_number
--    x_error_index
-- NOTES
---------------------------------------------------------------------
PROCEDURE Delete_Claim_Line_Tbl(
   p_api_version             IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_claim_line_tbl         IN    claim_line_tbl_type
   ,p_change_object_version  IN    VARCHAR2 := FND_API.g_false
   ,x_error_index            OUT NOCOPY   NUMBER)
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Claim_Line';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_pvt_claim_line_tbl        OZF_CLAIM_LINE_PVT.claim_line_Tbl_type;
   l_claim_line_tbl            OZF_CLAIM_PUB.claim_line_tbl_type:=p_claim_line_tbl;
   l_error_index               NUMBER;
BEGIN
-- Standard Start of API savepoint
   SAVEPOINT DELETE_Claim_Line_PUB;
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
   p_api_version,
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
     l_claim_line_tbl := p_claim_line_tbl;
       IF p_claim_line_tbl.COUNT > 0 THEN
   FOR i IN p_claim_line_tbl.FIRST..p_claim_line_tbl.LAST LOOP
   --
     l_pvt_claim_line_tbl(i). claim_line_id              := l_claim_line_tbl(i). claim_line_id  ;
     l_pvt_claim_line_tbl(i).object_version_number       := l_claim_line_tbl(i).object_version_number;
     l_pvt_claim_line_tbl(i).claim_id                    := l_claim_line_tbl(i).claim_id;
END LOOP;
 END IF;
   OZF_Claim_Line_PVT.Delete_Claim_Line_Tbl(
    p_api_version        => p_api_version
   ,p_init_msg_list      => FND_API.G_FALSE
   ,p_commit             => FND_API.G_FALSE
   ,P_Validation_Level   => p_Validation_Level
   ,x_return_status         =>    x_return_status
   ,x_msg_data              =>    x_msg_data
   ,x_msg_count             =>    x_msg_count
   ,p_claim_line_tbl        =>    l_pvt_claim_line_tbl
   ,p_change_object_version =>    FND_API.g_false
   ,x_error_index           =>    l_error_index);
   IF g_debug THEN
      OZF_UTILITY_PVT.DEBUG_MESSAGE('RETURN STATUS FOR DELETE_CLAIM_Line_Tbl =>'||X_RETURN_STATUS);
   END IF;
   -- Check return status from the above procedure call
   IF x_return_status = FND_API.G_RET_STS_ERROR then
       RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
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
   ROLLBACK TO DELETE_Claim_Line_PUB;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');
   WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO DELETE_Claim_Line_PUB;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO DELETE_Claim_Line_PUB;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
WHEN OTHERS THEN
   ROLLBACK TO DELETE_Claim_PUB;
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
End Delete_Claim_Line_Tbl;
/* End of Delete claim line*/

---------------------------------------------------------------------
-- PROCEDURE
--   asso_accruals_to_claim
--
-- PURPOSE
--    This procedure associates accruals based on the given fund
--    utilization criteria.
--
-- PARAMETERS
--    p_api_version
--    p_init_msg_list
--    p_commit
--    p_validation_level
--    p_claim_id
--    p_funds_util_flt
--    x_return_status
--    x_msg_count
--    x_msg_data
-- NOTES
---------------------------------------------------------------------
PROCEDURE Asso_Accruals_To_Claim(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_claim_id               IN    NUMBER
   ,p_funds_util_flt         IN    funds_util_flt_type
)
IS
l_api_version                CONSTANT NUMBER       := 1.0;
l_api_name                   CONSTANT VARCHAR2(30) := 'Asso_Accruals_To_Claim';
l_full_name                  CONSTANT VARCHAR2(60) := G_PKG_NAME||'.'||l_api_name;
l_return_status                       VARCHAR2(1);

l_funds_util_flt                      OZF_Claim_Accrual_PVT.funds_util_flt_type;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Asso_Accruals_To_Claim;

   IF G_DEBUG THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ------------------------------------------
   -- 1. Default and derive column valude  --
   ------------------------------------------
   l_funds_util_flt.fund_id                     := p_funds_util_flt.fund_id;
   l_funds_util_flt.activity_type               := p_funds_util_flt.activity_type;
   l_funds_util_flt.activity_id                 := p_funds_util_flt.activity_id;
   l_funds_util_flt.activity_product_id         := p_funds_util_flt.activity_product_id;
   l_funds_util_flt.offer_type                  := p_funds_util_flt.offer_type;
   l_funds_util_flt.document_class              := p_funds_util_flt.document_class;
   l_funds_util_flt.document_id                 := p_funds_util_flt.document_id;
   l_funds_util_flt.product_level_type          := p_funds_util_flt.product_level_type;
   l_funds_util_flt.product_id                  := p_funds_util_flt.product_id;
   l_funds_util_flt.reference_type              := p_funds_util_flt.reference_type;
   l_funds_util_flt.reference_id                := p_funds_util_flt.reference_id;
   l_funds_util_flt.utilization_type            := p_funds_util_flt.utilization_type;
   l_funds_util_flt.cust_account_id             := p_funds_util_flt.cust_account_id;
   l_funds_util_flt.relationship_type           := p_funds_util_flt.relationship_type;
   l_funds_util_flt.related_cust_account_id     := p_funds_util_flt.related_cust_account_id;
   l_funds_util_flt.buy_group_cust_account_id   := p_funds_util_flt.buy_group_cust_account_id;
   l_funds_util_flt.select_cust_children_flag   := p_funds_util_flt.select_cust_children_flag;
   l_funds_util_flt.pay_to_customer             := p_funds_util_flt.pay_to_customer;
   l_funds_util_flt.prorate_earnings_flag       := p_funds_util_flt.prorate_earnings_flag;
   l_funds_util_flt.end_date                    := p_funds_util_flt.end_date;
   l_funds_util_flt.total_amount                := p_funds_util_flt.total_amount;
   l_funds_util_flt.total_units                 := p_funds_util_flt.total_units;
   l_funds_util_flt.quantity                    := p_funds_util_flt.quantity;
   l_funds_util_flt.uom_code                    := p_funds_util_flt.uom_code;
   -- Added For Bug 8402328
   l_funds_util_flt.utilization_id              := p_funds_util_flt.utilization_id;

   ------------------------------------------
   -- 2. Call OZF_CLAIM_ACCRUAL_PVT
   ------------------------------------------
   OZF_Claim_Accrual_PVT.Asso_Accruals_To_Claim(
     p_api_version         => l_api_version
    ,p_init_msg_list       => FND_API.g_false
    ,p_commit              => FND_API.g_false
    ,p_validation_level    => FND_API.g_valid_level_full

    ,x_return_status       => l_return_status
    ,x_msg_count           => x_msg_count
    ,x_msg_data            => x_msg_data

    ,p_claim_id            => p_claim_id
    ,p_funds_util_flt      => l_funds_util_flt
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Standard check for p_commit
   IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   IF G_DEBUG THEN
      OZF_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(
         p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Asso_Accruals_To_Claim;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Asso_Accruals_To_Claim;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CRE_DEDU_ERR');
         FND_MSG_PUB.add;
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Asso_Accruals_To_Claim;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CRE_DEDU_ERR');
         FND_MSG_PUB.add;
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );
END Asso_Accruals_To_Claim;

---------------------------------------------------------------------
-- PROCEDURE
--   asso_accruals_to_claim_line
--
-- PURPOSE
--    This procedure associates accruals to a claim line.
--
-- PARAMETERS
--    p_api_version
--    p_init_msg_list
--    p_commit
--    p_validation_level
--    p_claim_line_id
--    x_return_status
--    x_msg_count
--    x_msg_data
-- NOTES
---------------------------------------------------------------------
PROCEDURE Asso_Accruals_To_Claim_Line(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_claim_line_id          IN    NUMBER
)
IS
l_api_version                CONSTANT NUMBER       := 1.0;
l_api_name                   CONSTANT VARCHAR2(30) := 'Asso_Accruals_To_Claim_Line';
l_full_name                  CONSTANT VARCHAR2(60) := G_PKG_NAME||'.'||l_api_name;
l_return_status                       VARCHAR2(1);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Asso_Accruals_To_Claim_Line;

   IF G_DEBUG THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ------------------------------------------
   -- 1. Call OZF_CLAIM_ACCRUAL_PVT
   ------------------------------------------
   OZF_Claim_Accrual_PVT.Asso_Accruals_To_Claim_Line(
     p_api_version         => l_api_version
    ,p_init_msg_list       => FND_API.g_false
    ,p_commit              => FND_API.g_false
    ,p_validation_level    => FND_API.g_valid_level_full

    ,x_return_status       => l_return_status
    ,x_msg_count           => x_msg_count
    ,x_msg_data            => x_msg_data

    ,p_claim_line_id       => p_claim_line_id
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Standard check for p_commit
   IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   IF G_DEBUG THEN
      OZF_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(
         p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Asso_Accruals_To_Claim_Line;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Asso_Accruals_To_Claim_Line;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CRE_DEDU_ERR');
         FND_MSG_PUB.add;
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Asso_Accruals_To_Claim_Line;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CRE_DEDU_ERR');
         FND_MSG_PUB.add;
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );
END Asso_Accruals_To_Claim_Line;

---------------------------------------------------------------------
-- PROCEDURE
--   create_claim_for_accruals
--
-- PURPOSE
--    This procedure creates a claim for accruals that meet the fund
--    utilization search criteria.
--
-- PARAMETERS
--    p_api_version
--    p_init_msg_list
--    p_commit
--    p_validation_level
--    p_claim_rec
--    p_funds_util_flt
--    x_return_status
--    x_msg_count
--    x_msg_data
-- NOTES
---------------------------------------------------------------------
PROCEDURE Create_Claim_For_Accruals(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_claim_rec              IN    claim_rec_type
   ,p_funds_util_flt         IN    funds_util_flt_type
   ,x_claim_id               OUT NOCOPY   NUMBER
)
IS
l_api_version                CONSTANT NUMBER       := 1.0;
l_api_name                   CONSTANT VARCHAR2(30) := 'Create_Claim_For_Accruals';
l_full_name                  CONSTANT VARCHAR2(60) := G_PKG_NAME||'.'||l_api_name;
l_return_status                       VARCHAR2(1);

l_claim_rec                           OZF_Claim_PVT.claim_rec_type;
l_funds_util_flt                      OZF_Claim_Accrual_PVT.funds_util_flt_type;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Create_Claim_For_Accruals;

   IF G_DEBUG THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ------------------------------------------
   -- 1. Default and derive column valude  --
   ------------------------------------------
   l_claim_rec.claim_type_id                := p_claim_rec.claim_type_id;
   l_claim_rec.claim_date                   := p_claim_rec.claim_date;
   l_claim_rec.due_date                     := p_claim_rec.due_date;
   l_claim_rec.gl_date                      := p_claim_rec.gl_date;
   l_claim_rec.owner_id                     := p_claim_rec.owner_id;
   l_claim_rec.amount                       := p_claim_rec.amount;
   l_claim_rec.currency_code                := p_claim_rec.currency_code;
   l_claim_rec.exchange_rate_type           := p_claim_rec.exchange_rate_type;
   l_claim_rec.exchange_rate_date           := p_claim_rec.exchange_rate_date;
   l_claim_rec.exchange_rate                := p_claim_rec.exchange_rate;
   l_claim_rec.set_of_books_id              := p_claim_rec.set_of_books_id;
   l_claim_rec.source_object_id             := p_claim_rec.source_object_id;
   l_claim_rec.source_object_class          := p_claim_rec.source_object_class;
   l_claim_rec.source_object_type_id        := p_claim_rec.source_object_type_id;
   l_claim_rec.source_object_number         := p_claim_rec.source_object_number;
   l_claim_rec.cust_account_id              := p_claim_rec.cust_account_id;
   l_claim_rec.cust_billto_acct_site_id     := p_claim_rec.cust_billto_acct_site_id;
   l_claim_rec.cust_shipto_acct_site_id     := p_claim_rec.cust_shipto_acct_site_id;
   l_claim_rec.related_cust_account_id      := p_claim_rec.related_cust_account_id;
   l_claim_rec.reason_code_id               := p_claim_rec.reason_code_id;
   l_claim_rec.reason_type                  := p_claim_rec.reason_type;
   l_claim_rec.status_code                  := p_claim_rec.status_code;
   l_claim_rec.user_status_id               := p_claim_rec.user_status_id;
   l_claim_rec.sales_rep_id                 := p_claim_rec.sales_rep_id;
   l_claim_rec.collector_id                 := p_claim_rec.collector_id;
   l_claim_rec.contact_id                   := p_claim_rec.contact_id;
   l_claim_rec.broker_id                    := p_claim_rec.broker_id;
   l_claim_rec.customer_ref_date            := p_claim_rec.customer_ref_date;
   l_claim_rec.customer_ref_number          := p_claim_rec.customer_ref_number;
   l_claim_rec.comments                     := p_claim_rec.comments;
   l_claim_rec.attribute_category           := p_claim_rec.attribute_category;
   l_claim_rec.attribute1                   := p_claim_rec.attribute1;
   l_claim_rec.attribute2                   := p_claim_rec.attribute2;
   l_claim_rec.attribute3                   := p_claim_rec.attribute3;
   l_claim_rec.attribute4                   := p_claim_rec.attribute4;
   l_claim_rec.attribute5                   := p_claim_rec.attribute5;
   l_claim_rec.attribute6                   := p_claim_rec.attribute6;
   l_claim_rec.attribute7                   := p_claim_rec.attribute7;
   l_claim_rec.attribute8                   := p_claim_rec.attribute8;
   l_claim_rec.attribute9                   := p_claim_rec.attribute9;
   l_claim_rec.attribute10                  := p_claim_rec.attribute10;
   l_claim_rec.attribute11                  := p_claim_rec.attribute11;
   l_claim_rec.attribute12                  := p_claim_rec.attribute12;
   l_claim_rec.attribute13                  := p_claim_rec.attribute13;
   l_claim_rec.attribute14                  := p_claim_rec.attribute14;
   l_claim_rec.attribute15                  := p_claim_rec.attribute15;
   l_claim_rec.org_id                       := p_claim_rec.org_id;
   l_claim_rec.write_off_flag		    := p_claim_rec.write_off_flag;
   l_claim_rec.write_off_threshold_amount   := p_claim_rec.write_off_threshold_amount;
   l_claim_rec.under_write_off_threshold    := p_claim_rec.under_write_off_threshold;
   l_claim_rec.customer_reason		    := p_claim_rec.customer_reason;
   l_claim_rec.ship_to_cust_account_id	    := p_claim_rec.ship_to_cust_account_id;
   l_claim_rec.amount_applied		    := p_claim_rec.amount_applied;
   l_claim_rec.applied_receipt_id	    := p_claim_rec.applied_receipt_id;
   l_claim_rec.applied_receipt_number	    := p_claim_rec.applied_receipt_number;
   l_claim_rec.wo_rec_trx_id		    := p_claim_rec.wo_rec_trx_id;
   l_claim_rec.group_claim_id		    := p_claim_rec.group_claim_id;
   l_claim_rec.appr_wf_item_key		    := p_claim_rec.appr_wf_item_key;
   l_claim_rec.cstl_wf_item_key		    := p_claim_rec.cstl_wf_item_key;
   l_claim_rec.batch_type		    := p_claim_rec.batch_type;
   -- Fix for Bug 8501176
   l_claim_rec.claim_number		    := p_claim_rec.claim_number;


   l_funds_util_flt.fund_id                     := p_funds_util_flt.fund_id;
   l_funds_util_flt.activity_type               := p_funds_util_flt.activity_type;
   l_funds_util_flt.activity_id                 := p_funds_util_flt.activity_id;
   l_funds_util_flt.activity_product_id         := p_funds_util_flt.activity_product_id;
   l_funds_util_flt.offer_type                  := p_funds_util_flt.offer_type;
   l_funds_util_flt.document_class              := p_funds_util_flt.document_class;
   l_funds_util_flt.document_id                 := p_funds_util_flt.document_id;
   l_funds_util_flt.product_level_type          := p_funds_util_flt.product_level_type;
   l_funds_util_flt.product_id                  := p_funds_util_flt.product_id;
   l_funds_util_flt.reference_type              := p_funds_util_flt.reference_type;
   l_funds_util_flt.reference_id                := p_funds_util_flt.reference_id;
   l_funds_util_flt.utilization_type            := p_funds_util_flt.utilization_type;
   l_funds_util_flt.cust_account_id             := p_funds_util_flt.cust_account_id;
   l_funds_util_flt.relationship_type           := p_funds_util_flt.relationship_type;
   l_funds_util_flt.related_cust_account_id     := p_funds_util_flt.related_cust_account_id;
   l_funds_util_flt.buy_group_cust_account_id   := p_funds_util_flt.buy_group_cust_account_id;
   l_funds_util_flt.select_cust_children_flag   := p_funds_util_flt.select_cust_children_flag;
   l_funds_util_flt.pay_to_customer             := p_funds_util_flt.pay_to_customer;
   l_funds_util_flt.prorate_earnings_flag       := p_funds_util_flt.prorate_earnings_flag;
   l_funds_util_flt.end_date                    := p_funds_util_flt.end_date;
   l_funds_util_flt.total_amount                := p_funds_util_flt.total_amount;
   l_funds_util_flt.total_units                 := p_funds_util_flt.total_units;
   l_funds_util_flt.quantity                    := p_funds_util_flt.quantity;
   l_funds_util_flt.uom_code                    := p_funds_util_flt.uom_code;
    -- Added For Bug 8402328
   l_funds_util_flt.utilization_id              := p_funds_util_flt.utilization_id;

   ------------------------------------------
   -- 2. Call OZF_CLAIM_ACCRUAL_PVT
   ------------------------------------------
   IF G_DEBUG THEN
      OZF_Utility_PVT.debug_message(l_claim_rec.claim_number||': In Public l_claim_rec.claim_number');
   END IF;

   OZF_Claim_Accrual_PVT.Create_Claim_For_Accruals(
     p_api_version         => l_api_version
    ,p_init_msg_list       => FND_API.g_false
    ,p_commit              => FND_API.g_false
    ,p_validation_level    => FND_API.g_valid_level_full

    ,x_return_status       => l_return_status
    ,x_msg_count           => x_msg_count
    ,x_msg_data            => x_msg_data

    ,p_claim_rec           => l_claim_rec
    ,p_funds_util_flt      => l_funds_util_flt

    ,x_claim_id            => x_claim_id
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Standard check for p_commit
   IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   IF G_DEBUG THEN
      OZF_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(
         p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Claim_For_Accruals;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Claim_For_Accruals;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CRE_DEDU_ERR');
         FND_MSG_PUB.add;
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Create_Claim_For_Accruals;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CRE_DEDU_ERR');
         FND_MSG_PUB.add;
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );
END Create_Claim_For_Accruals;

---------------------------------------------------------------------
-- PROCEDURE
--   pay_claim_for_accruals
--
-- PURPOSE
--    This procedure creates a claim for accruals that meet the fund
--    utilization search criteria and initiates settlement of the claim.
--
-- PARAMETERS
--    p_api_version
--    p_init_msg_list
--    p_commit
--    p_validation_level
--    p_claim_rec
--    p_funds_util_flt
--    x_return_status
--    x_msg_count
--    x_msg_data
-- NOTES
---------------------------------------------------------------------
PROCEDURE Pay_Claim_For_Accruals(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_claim_rec              IN    claim_rec_type
   ,p_funds_util_flt         IN    funds_util_flt_type
   ,x_claim_id               OUT NOCOPY   NUMBER
)
IS
l_api_version                CONSTANT NUMBER       := 1.0;
l_api_name                   CONSTANT VARCHAR2(30) := 'Pay_Claim_For_Accruals';
l_full_name                  CONSTANT VARCHAR2(60) := G_PKG_NAME||'.'||l_api_name;
l_return_status                       VARCHAR2(1);

l_claim_rec                           OZF_Claim_PVT.claim_rec_type;
l_funds_util_flt                      OZF_Claim_Accrual_PVT.funds_util_flt_type;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Pay_Claim_For_Accruals;

   IF G_DEBUG THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ------------------------------------------
   -- 1. Default and derive column valude  --
   ------------------------------------------
   l_claim_rec.claim_type_id                := p_claim_rec.claim_type_id;
   l_claim_rec.claim_date                   := p_claim_rec.claim_date;
   l_claim_rec.due_date                     := p_claim_rec.due_date;
   l_claim_rec.gl_date                      := p_claim_rec.gl_date;
   l_claim_rec.owner_id                     := p_claim_rec.owner_id;
   l_claim_rec.amount                       := p_claim_rec.amount;
   l_claim_rec.currency_code                := p_claim_rec.currency_code;
   l_claim_rec.exchange_rate_type           := p_claim_rec.exchange_rate_type;
   l_claim_rec.exchange_rate_date           := p_claim_rec.exchange_rate_date;
   l_claim_rec.exchange_rate                := p_claim_rec.exchange_rate;
   l_claim_rec.set_of_books_id              := p_claim_rec.set_of_books_id;
   l_claim_rec.source_object_id             := p_claim_rec.source_object_id;
   l_claim_rec.source_object_class          := p_claim_rec.source_object_class;
   l_claim_rec.source_object_type_id        := p_claim_rec.source_object_type_id;
   l_claim_rec.source_object_number         := p_claim_rec.source_object_number;
   l_claim_rec.cust_account_id              := p_claim_rec.cust_account_id;
   l_claim_rec.cust_billto_acct_site_id     := p_claim_rec.cust_billto_acct_site_id;
   l_claim_rec.cust_shipto_acct_site_id     := p_claim_rec.cust_shipto_acct_site_id;
   l_claim_rec.related_cust_account_id      := p_claim_rec.related_cust_account_id;
   l_claim_rec.reason_code_id               := p_claim_rec.reason_code_id;
   l_claim_rec.reason_type                  := p_claim_rec.reason_type;
   l_claim_rec.status_code                  := p_claim_rec.status_code;
   l_claim_rec.user_status_id               := p_claim_rec.user_status_id;
   l_claim_rec.sales_rep_id                 := p_claim_rec.sales_rep_id;
   l_claim_rec.collector_id                 := p_claim_rec.collector_id;
   l_claim_rec.contact_id                   := p_claim_rec.contact_id;
   l_claim_rec.broker_id                    := p_claim_rec.broker_id;
   l_claim_rec.customer_ref_date            := p_claim_rec.customer_ref_date;
   l_claim_rec.customer_ref_number          := p_claim_rec.customer_ref_number;
   l_claim_rec.comments                     := p_claim_rec.comments;
   l_claim_rec.attribute_category           := p_claim_rec.attribute_category;
   l_claim_rec.attribute1                   := p_claim_rec.attribute1;
   l_claim_rec.attribute2                   := p_claim_rec.attribute2;
   l_claim_rec.attribute3                   := p_claim_rec.attribute3;
   l_claim_rec.attribute4                   := p_claim_rec.attribute4;
   l_claim_rec.attribute5                   := p_claim_rec.attribute5;
   l_claim_rec.attribute6                   := p_claim_rec.attribute6;
   l_claim_rec.attribute7                   := p_claim_rec.attribute7;
   l_claim_rec.attribute8                   := p_claim_rec.attribute8;
   l_claim_rec.attribute9                   := p_claim_rec.attribute9;
   l_claim_rec.attribute10                  := p_claim_rec.attribute10;
   l_claim_rec.attribute11                  := p_claim_rec.attribute11;
   l_claim_rec.attribute12                  := p_claim_rec.attribute12;
   l_claim_rec.attribute13                  := p_claim_rec.attribute13;
   l_claim_rec.attribute14                  := p_claim_rec.attribute14;
   l_claim_rec.attribute15                  := p_claim_rec.attribute15;
   l_claim_rec.org_id                       := p_claim_rec.org_id;
   l_claim_rec.write_off_flag		    := p_claim_rec.write_off_flag;
   l_claim_rec.write_off_threshold_amount   := p_claim_rec.write_off_threshold_amount;
   l_claim_rec.under_write_off_threshold    := p_claim_rec.under_write_off_threshold;
   l_claim_rec.customer_reason		    := p_claim_rec.customer_reason;
   l_claim_rec.ship_to_cust_account_id	    := p_claim_rec.ship_to_cust_account_id;
   l_claim_rec.amount_applied		    := p_claim_rec.amount_applied;
   l_claim_rec.applied_receipt_id	    := p_claim_rec.applied_receipt_id;
   l_claim_rec.applied_receipt_number	    := p_claim_rec.applied_receipt_number;
   l_claim_rec.wo_rec_trx_id		    := p_claim_rec.wo_rec_trx_id;
   l_claim_rec.group_claim_id		    := p_claim_rec.group_claim_id;
   l_claim_rec.appr_wf_item_key		    := p_claim_rec.appr_wf_item_key;
   l_claim_rec.cstl_wf_item_key		    := p_claim_rec.cstl_wf_item_key;
   l_claim_rec.batch_type		    := p_claim_rec.batch_type;
   -- Fix for Bug 8501176
   l_claim_rec.claim_number		    := p_claim_rec.claim_number;


   l_funds_util_flt.fund_id                     := p_funds_util_flt.fund_id;
   l_funds_util_flt.activity_type               := p_funds_util_flt.activity_type;
   l_funds_util_flt.activity_id                 := p_funds_util_flt.activity_id;
   l_funds_util_flt.activity_product_id         := p_funds_util_flt.activity_product_id;
   l_funds_util_flt.offer_type                  := p_funds_util_flt.offer_type;
   l_funds_util_flt.document_class              := p_funds_util_flt.document_class;
   l_funds_util_flt.document_id                 := p_funds_util_flt.document_id;
   l_funds_util_flt.product_level_type          := p_funds_util_flt.product_level_type;
   l_funds_util_flt.product_id                  := p_funds_util_flt.product_id;
   l_funds_util_flt.reference_type              := p_funds_util_flt.reference_type;
   l_funds_util_flt.reference_id                := p_funds_util_flt.reference_id;
   l_funds_util_flt.utilization_type            := p_funds_util_flt.utilization_type;
   l_funds_util_flt.cust_account_id             := p_funds_util_flt.cust_account_id;
   l_funds_util_flt.relationship_type           := p_funds_util_flt.relationship_type;
   l_funds_util_flt.related_cust_account_id     := p_funds_util_flt.related_cust_account_id;
   l_funds_util_flt.buy_group_cust_account_id   := p_funds_util_flt.buy_group_cust_account_id;
   l_funds_util_flt.select_cust_children_flag   := p_funds_util_flt.select_cust_children_flag;
   l_funds_util_flt.pay_to_customer             := p_funds_util_flt.pay_to_customer;
   l_funds_util_flt.prorate_earnings_flag       := p_funds_util_flt.prorate_earnings_flag;
   l_funds_util_flt.end_date                    := p_funds_util_flt.end_date;
   l_funds_util_flt.total_amount                := p_funds_util_flt.total_amount;
   l_funds_util_flt.total_units                 := p_funds_util_flt.total_units;
   l_funds_util_flt.quantity                    := p_funds_util_flt.quantity;
   l_funds_util_flt.uom_code                    := p_funds_util_flt.uom_code;
    -- Added For Bug 8402328
   l_funds_util_flt.utilization_id              := p_funds_util_flt.utilization_id;

   ------------------------------------------
   -- 2. Call OZF_CLAIM_ACCRUAL_PVT
   ------------------------------------------
   OZF_Claim_Accrual_PVT.Pay_Claim_For_Accruals(
     p_api_version         => l_api_version
    ,p_init_msg_list       => FND_API.g_false
    ,p_commit              => FND_API.g_false
    ,p_validation_level    => FND_API.g_valid_level_full

    ,x_return_status       => l_return_status
    ,x_msg_count           => x_msg_count
    ,x_msg_data            => x_msg_data

    ,p_claim_rec           => l_claim_rec
    ,p_funds_util_flt      => l_funds_util_flt

    ,x_claim_id            => x_claim_id
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Standard check for p_commit
   IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   IF G_DEBUG THEN
      OZF_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(
         p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Pay_Claim_For_Accruals;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Pay_Claim_For_Accruals;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CRE_DEDU_ERR');
         FND_MSG_PUB.add;
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Pay_Claim_For_Accruals;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CRE_DEDU_ERR');
         FND_MSG_PUB.add;
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );
END Pay_Claim_For_Accruals;

END OZF_Claim_PUB;

/
