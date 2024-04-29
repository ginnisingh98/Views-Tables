--------------------------------------------------------
--  DDL for Package Body AMS_CLAIM_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CLAIM_GRP" as
/* $Header: amsgclab.pls 115.44 2004/04/06 19:33:41 julou ship $ */
-- Start of Comments
-- Package name     : AMS_claim_GRP
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME             CONSTANT  VARCHAR2(20) := 'AMS_CLAIM_GRP';
G_DEDUCTION_CLASS      CONSTANT  VARCHAR2(20) := 'DEDUCTION';
G_OVERPAYMENT_CLASS    CONSTANT  VARCHAR2(20) := 'OVERPAYMENT';
G_DEDUC_OBJ_TYPE       CONSTANT  VARCHAR2(6)  := 'DEDU';
G_CLAIM_OBJECT_TYPE    CONSTANT  VARCHAR2(30) := 'CLAM';
G_CLAIM_STATUS         CONSTANT  VARCHAR2(30) := 'AMS_CLAIM_STATUS';
G_FILE_NAME            CONSTANT VARCHAR2(12) := 'amsgclab.pls';
G_OPEN_STATUS          CONSTANT VARCHAR2(30) := 'OPEN';
G_UPDATE_EVENT         CONSTANT VARCHAR2(30) := 'UPDATE';
G_INVOICE              CONSTANT VARCHAR2(30) := 'INVOICE';

AMS_DEBUG_LOW_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);


PROCEDURE Complete_OZF_Claim_Grp_Rec(
      p_ams_claim_grp_rec   IN AMS_CLAIM_GRP.DEDUCTION_REC_TYPE
    , x_ozf_claim_grp_rec   OUT NOCOPY OZF_CLAIM_GRP.DEDUCTION_REC_TYPE
    , x_return_status       OUT NOCOPY VARCHAR2
)
IS
BEGIN
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_ams_claim_grp_rec.claim_id = FND_API.g_miss_num THEN
      x_ozf_claim_grp_rec.claim_id                      := NULL;
   ELSE
      x_ozf_claim_grp_rec.claim_id                      := p_ams_claim_grp_rec.claim_id;
   END IF;

   IF p_ams_claim_grp_rec.claim_number  = FND_API.g_miss_char THEN
      x_ozf_claim_grp_rec.claim_number                  := NULL;
   ELSE
      x_ozf_claim_grp_rec.claim_number                  := p_ams_claim_grp_rec.claim_number;
   END IF;

   IF p_ams_claim_grp_rec.claim_type_id = FND_API.g_miss_num THEN
      x_ozf_claim_grp_rec.claim_type_id                 := NULL;
   ELSE
      x_ozf_claim_grp_rec.claim_type_id                 := p_ams_claim_grp_rec.claim_type_id;
   END IF;

   IF p_ams_claim_grp_rec.claim_date = FND_API.g_miss_date THEN
      x_ozf_claim_grp_rec.claim_date                    := NULL;
   ELSE
      x_ozf_claim_grp_rec.claim_date                    := p_ams_claim_grp_rec.claim_date;
   END IF;

   IF p_ams_claim_grp_rec.due_date = FND_API.g_miss_date THEN
      x_ozf_claim_grp_rec.due_date                      := NULL;
   ELSE
      x_ozf_claim_grp_rec.due_date                      := p_ams_claim_grp_rec.due_date;
   END IF;

   IF p_ams_claim_grp_rec.owner_id = FND_API.g_miss_num THEN
      x_ozf_claim_grp_rec.owner_id                      := NULL;
   ELSE
      x_ozf_claim_grp_rec.owner_id                      := p_ams_claim_grp_rec.owner_id;
   END IF;

   IF p_ams_claim_grp_rec.amount = FND_API.g_miss_num THEN
      x_ozf_claim_grp_rec.amount                        := NULL;
   ELSE
      x_ozf_claim_grp_rec.amount                        := p_ams_claim_grp_rec.amount;
   END IF;

   IF p_ams_claim_grp_rec.currency_code = FND_API.g_miss_char THEN
      x_ozf_claim_grp_rec.currency_code                 := NULL;
   ELSE
      x_ozf_claim_grp_rec.currency_code                 := p_ams_claim_grp_rec.currency_code;
   END IF;

   IF p_ams_claim_grp_rec.exchange_rate_type = FND_API.g_miss_char THEN
      x_ozf_claim_grp_rec.exchange_rate_type            := NULL;
   ELSE
      x_ozf_claim_grp_rec.exchange_rate_type            := p_ams_claim_grp_rec.exchange_rate_type;
   END IF;

   IF p_ams_claim_grp_rec.exchange_rate_date = FND_API.g_miss_date THEN
      x_ozf_claim_grp_rec.exchange_rate_date            := NULL;
   ELSE
      x_ozf_claim_grp_rec.exchange_rate_date            := p_ams_claim_grp_rec.exchange_rate_date;
   END IF;

   IF p_ams_claim_grp_rec.exchange_rate = FND_API.g_miss_num THEN
      x_ozf_claim_grp_rec.exchange_rate                 := NULL;
   ELSE
      x_ozf_claim_grp_rec.exchange_rate                 := p_ams_claim_grp_rec.exchange_rate;
   END IF;

   IF p_ams_claim_grp_rec.set_of_books_id = FND_API.g_miss_num THEN
      x_ozf_claim_grp_rec.set_of_books_id               := NULL;
   ELSE
      x_ozf_claim_grp_rec.set_of_books_id               := p_ams_claim_grp_rec.set_of_books_id;
   END IF;

   IF p_ams_claim_grp_rec.source_object_id = FND_API.g_miss_num THEN
      x_ozf_claim_grp_rec.source_object_id              := NULL;
   ELSE
      x_ozf_claim_grp_rec.source_object_id              := p_ams_claim_grp_rec.source_object_id;
   END IF;

   IF p_ams_claim_grp_rec.source_object_class = FND_API.g_miss_char THEN
      x_ozf_claim_grp_rec.source_object_class           := NULL;
   ELSE
      x_ozf_claim_grp_rec.source_object_class           := p_ams_claim_grp_rec.source_object_class;
   END IF;

   IF p_ams_claim_grp_rec.source_object_type_id = FND_API.g_miss_num THEN
      x_ozf_claim_grp_rec.source_object_type_id         := NULL;
   ELSE
      x_ozf_claim_grp_rec.source_object_type_id         := p_ams_claim_grp_rec.source_object_type_id;
   END IF;

   IF p_ams_claim_grp_rec.source_object_number = FND_API.g_miss_char THEN
      x_ozf_claim_grp_rec.source_object_number          := NULL;
   ELSE
      x_ozf_claim_grp_rec.source_object_number          := p_ams_claim_grp_rec.source_object_number;
   END IF;

   IF p_ams_claim_grp_rec.cust_account_id = FND_API.g_miss_num THEN
      x_ozf_claim_grp_rec.cust_account_id               := NULL;
   ELSE
      x_ozf_claim_grp_rec.cust_account_id               := p_ams_claim_grp_rec.cust_account_id;
   END IF;

   IF p_ams_claim_grp_rec.cust_billto_acct_site_id = FND_API.g_miss_num THEN
      x_ozf_claim_grp_rec.cust_billto_acct_site_id      := NULL;
   ELSE
      x_ozf_claim_grp_rec.cust_billto_acct_site_id      := p_ams_claim_grp_rec.cust_billto_acct_site_id;
   END IF;

   IF p_ams_claim_grp_rec.cust_shipto_acct_site_id = FND_API.g_miss_num THEN
      x_ozf_claim_grp_rec.cust_shipto_acct_site_id      := NULL;
   ELSE
      x_ozf_claim_grp_rec.cust_shipto_acct_site_id      := p_ams_claim_grp_rec.cust_shipto_acct_site_id;
   END IF;

   IF p_ams_claim_grp_rec.location_id = FND_API.g_miss_num THEN
      x_ozf_claim_grp_rec.location_id                   := NULL;
   ELSE
      x_ozf_claim_grp_rec.location_id                   := p_ams_claim_grp_rec.location_id;
   END IF;

   IF p_ams_claim_grp_rec.reason_code_id = FND_API.g_miss_num THEN
      x_ozf_claim_grp_rec.reason_code_id                := NULL;
   ELSE
      x_ozf_claim_grp_rec.reason_code_id                := p_ams_claim_grp_rec.reason_code_id;
   END IF;

   IF p_ams_claim_grp_rec.status_code = FND_API.g_miss_char THEN
      x_ozf_claim_grp_rec.status_code                   := NULL;
   ELSE
      x_ozf_claim_grp_rec.status_code                   := p_ams_claim_grp_rec.status_code;
   END IF;

   IF p_ams_claim_grp_rec.user_status_id = FND_API.g_miss_num THEN
      x_ozf_claim_grp_rec.user_status_id                := NULL;
   ELSE
      x_ozf_claim_grp_rec.user_status_id                := p_ams_claim_grp_rec.user_status_id;
   END IF;

   IF p_ams_claim_grp_rec.sales_rep_id = FND_API.g_miss_num THEN
      x_ozf_claim_grp_rec.sales_rep_id                  := NULL;
   ELSE
      x_ozf_claim_grp_rec.sales_rep_id                  := p_ams_claim_grp_rec.sales_rep_id;
   END IF;

   IF p_ams_claim_grp_rec.collector_id = FND_API.g_miss_num THEN
      x_ozf_claim_grp_rec.collector_id                  := NULL;
   ELSE
      x_ozf_claim_grp_rec.collector_id                  := p_ams_claim_grp_rec.collector_id;
   END IF;

   IF p_ams_claim_grp_rec.contact_id = FND_API.g_miss_num THEN
      x_ozf_claim_grp_rec.contact_id                    := NULL;
   ELSE
      x_ozf_claim_grp_rec.contact_id                    := p_ams_claim_grp_rec.contact_id;
   END IF;

   IF p_ams_claim_grp_rec.broker_id = FND_API.g_miss_num THEN
      x_ozf_claim_grp_rec.broker_id                     := NULL;
   ELSE
      x_ozf_claim_grp_rec.broker_id                     := p_ams_claim_grp_rec.broker_id;
   END IF;

   IF p_ams_claim_grp_rec.customer_ref_date = FND_API.g_miss_date THEN
      x_ozf_claim_grp_rec.customer_ref_date             := NULL;
   ELSE
      x_ozf_claim_grp_rec.customer_ref_date             := p_ams_claim_grp_rec.customer_ref_date;
   END IF;


   IF p_ams_claim_grp_rec.customer_ref_number = FND_API.g_miss_char THEN
      x_ozf_claim_grp_rec.customer_ref_number           := NULL;
   ELSE
      x_ozf_claim_grp_rec.customer_ref_number           := p_ams_claim_grp_rec.customer_ref_number;
   END IF;

   IF p_ams_claim_grp_rec.receipt_id = FND_API.g_miss_num THEN
      x_ozf_claim_grp_rec.receipt_id                    := NULL;
   ELSE
      x_ozf_claim_grp_rec.receipt_id                    := p_ams_claim_grp_rec.receipt_id;
   END IF;

   IF p_ams_claim_grp_rec.receipt_number = FND_API.g_miss_char THEN
      x_ozf_claim_grp_rec.receipt_number                := NULL;
   ELSE
      x_ozf_claim_grp_rec.receipt_number                := p_ams_claim_grp_rec.receipt_number;
   END IF;

   IF p_ams_claim_grp_rec.gl_date = FND_API.g_miss_date THEN
      x_ozf_claim_grp_rec.gl_date                       := NULL;
   ELSE
      x_ozf_claim_grp_rec.gl_date                       := p_ams_claim_grp_rec.gl_date;
   END IF;

   IF p_ams_claim_grp_rec.comments = FND_API.g_miss_char THEN
      x_ozf_claim_grp_rec.comments                      := NULL;
   ELSE
      x_ozf_claim_grp_rec.comments                      := p_ams_claim_grp_rec.comments;
   END IF;

   IF p_ams_claim_grp_rec.deduction_attribute_category = FND_API.g_miss_char THEN
      x_ozf_claim_grp_rec.deduction_attribute_category  := NULL;
   ELSE
      x_ozf_claim_grp_rec.deduction_attribute_category  := p_ams_claim_grp_rec.deduction_attribute_category;
   END IF;

   IF p_ams_claim_grp_rec.deduction_attribute1 = FND_API.g_miss_char THEN
      x_ozf_claim_grp_rec.deduction_attribute1          := NULL;
   ELSE
      x_ozf_claim_grp_rec.deduction_attribute1          := p_ams_claim_grp_rec.deduction_attribute1;
   END IF;

   IF p_ams_claim_grp_rec.deduction_attribute2 = FND_API.g_miss_char THEN
      x_ozf_claim_grp_rec.deduction_attribute2          := NULL;
   ELSE
      x_ozf_claim_grp_rec.deduction_attribute2          := p_ams_claim_grp_rec.deduction_attribute2;
   END IF;

   IF p_ams_claim_grp_rec.deduction_attribute3 = FND_API.g_miss_char THEN
      x_ozf_claim_grp_rec.deduction_attribute3          := NULL;
   ELSE
      x_ozf_claim_grp_rec.deduction_attribute3          := p_ams_claim_grp_rec.deduction_attribute3;
   END IF;

   IF p_ams_claim_grp_rec.deduction_attribute4 = FND_API.g_miss_char THEN
      x_ozf_claim_grp_rec.deduction_attribute4          := NULL;
   ELSE
      x_ozf_claim_grp_rec.deduction_attribute4          := p_ams_claim_grp_rec.deduction_attribute4;
   END IF;

   IF p_ams_claim_grp_rec.deduction_attribute5 = FND_API.g_miss_char THEN
      x_ozf_claim_grp_rec.deduction_attribute5          := NULL;
   ELSE
      x_ozf_claim_grp_rec.deduction_attribute5          := p_ams_claim_grp_rec.deduction_attribute5;
   END IF;

   IF p_ams_claim_grp_rec.deduction_attribute6 = FND_API.g_miss_char THEN
      x_ozf_claim_grp_rec.deduction_attribute6          := NULL;
   ELSE
      x_ozf_claim_grp_rec.deduction_attribute6          := p_ams_claim_grp_rec.deduction_attribute6;
   END IF;

   IF p_ams_claim_grp_rec.deduction_attribute7 = FND_API.g_miss_char THEN
      x_ozf_claim_grp_rec.deduction_attribute7          := NULL;
   ELSE
      x_ozf_claim_grp_rec.deduction_attribute7          := p_ams_claim_grp_rec.deduction_attribute7;
   END IF;

   IF p_ams_claim_grp_rec.deduction_attribute8 = FND_API.g_miss_char THEN
      x_ozf_claim_grp_rec.deduction_attribute8          := NULL;
   ELSE
      x_ozf_claim_grp_rec.deduction_attribute8          := p_ams_claim_grp_rec.deduction_attribute8;
   END IF;

   IF p_ams_claim_grp_rec.deduction_attribute9 = FND_API.g_miss_char THEN
      x_ozf_claim_grp_rec.deduction_attribute9          := NULL;
   ELSE
      x_ozf_claim_grp_rec.deduction_attribute9          := p_ams_claim_grp_rec.deduction_attribute9;
   END IF;

   IF p_ams_claim_grp_rec.deduction_attribute10 = FND_API.g_miss_char THEN
      x_ozf_claim_grp_rec.deduction_attribute10         := NULL;
   ELSE
      x_ozf_claim_grp_rec.deduction_attribute10         := p_ams_claim_grp_rec.deduction_attribute10;
   END IF;

   IF p_ams_claim_grp_rec.deduction_attribute11 = FND_API.g_miss_char THEN
      x_ozf_claim_grp_rec.deduction_attribute11         := NULL;
   ELSE
      x_ozf_claim_grp_rec.deduction_attribute11         := p_ams_claim_grp_rec.deduction_attribute11;
   END IF;

   IF p_ams_claim_grp_rec.deduction_attribute12 = FND_API.g_miss_char THEN
      x_ozf_claim_grp_rec.deduction_attribute12         := NULL;
   ELSE
      x_ozf_claim_grp_rec.deduction_attribute12         := p_ams_claim_grp_rec.deduction_attribute12;
   END IF;

   IF p_ams_claim_grp_rec.deduction_attribute13 = FND_API.g_miss_char THEN
      x_ozf_claim_grp_rec.deduction_attribute13         := NULL;
   ELSE
      x_ozf_claim_grp_rec.deduction_attribute13         := p_ams_claim_grp_rec.deduction_attribute13;
   END IF;

   IF p_ams_claim_grp_rec.deduction_attribute14 = FND_API.g_miss_char THEN
      x_ozf_claim_grp_rec.deduction_attribute14         := NULL;
   ELSE
      x_ozf_claim_grp_rec.deduction_attribute14         := p_ams_claim_grp_rec.deduction_attribute14;
   END IF;

   IF p_ams_claim_grp_rec.deduction_attribute15 = FND_API.g_miss_char THEN
      x_ozf_claim_grp_rec.deduction_attribute15         := NULL;
   ELSE
      x_ozf_claim_grp_rec.deduction_attribute15         := p_ams_claim_grp_rec.deduction_attribute15;
   END IF;

   IF p_ams_claim_grp_rec.org_id = FND_API.g_miss_num THEN
      x_ozf_claim_grp_rec.org_id                        := NULL;
   ELSE
      x_ozf_claim_grp_rec.org_id                        := p_ams_claim_grp_rec.org_id;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CLAIM_COMP_GRP_REC_ERR');
         FND_MSG_PUB.add;
      END IF;

END Complete_OZF_Claim_Grp_Rec;

---------------------------------------------------------------------
--   PROCEDURE:  Create_Deduction
--
--   PURPOSE:
--   This procedure checks information passed from AR to Claim module and then
--   calls Creat_claim function in the private package to create a claim record.
--   It returns a claim_id and cliam_number as the result.

--   PARAMETERS:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_deduction_Rec           IN   DEDUCTION_REC_TYPE  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_claim_id                OUT  NUMBER,
--       x_claim_number            OUT  VARCHAR2
--   NOTES:
--
---------------------------------------------------------------------
PROCEDURE Create_Deduction(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,

    P_deduction                  IN   DEDUCTION_REC_TYPE,
    X_CLAIM_ID                   OUT NOCOPY  NUMBER,
    X_CLAIM_NUMBER               OUT NOCOPY  VARCHAR2
)
IS
l_ozf_claim_grp_rec    OZF_CLAIM_GRP.DEDUCTION_REC_TYPE;

BEGIN
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   Complete_OZF_Claim_Grp_Rec(
      p_ams_claim_grp_rec   => P_deduction
    , x_ozf_claim_grp_rec   => l_ozf_claim_grp_rec
    , x_return_status       => x_return_status

   );
   IF x_return_status = FND_API.G_RET_STS_ERROR then
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   OZF_CLAIM_GRP.Create_Deduction(
        P_Api_Version_Number     => P_Api_Version_Number,
        P_Init_Msg_List          => P_Init_Msg_List,
        p_validation_level       => p_validation_level,
        P_Commit                 => P_Commit,

        X_Return_Status          => X_Return_Status,
        X_Msg_Count              => X_Msg_Count,
        X_Msg_Data               => X_Msg_Data,

        P_deduction              => l_ozf_claim_grp_rec,
        X_CLAIM_ID               => X_CLAIM_ID,
        X_CLAIM_NUMBER           => X_CLAIM_NUMBER
   );
   IF x_return_status = FND_API.G_RET_STS_ERROR then
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CLAIM_CRE_DEDU_ERR');
         FND_MSG_PUB.add;
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
End Create_Deduction;


---------------------------------------------------------------------
--   PROCEDURE:  Update_Deduction
--
--   PURPOSE  :
--   This procedure update a Deduction. It calls the Update_claim function in the private
--   package.
--
--   PARAMETERS:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_deduction               IN   DEDUCTION_REC_TYPE  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_object_version_number   OUT  NUMBER
--
--   Note:
--
---------------------------------------------------------------------

PROCEDURE Update_Deduction(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,

    P_deduction                  IN   DEDUCTION_REC_TYPE,
    X_Object_Version_Number      OUT NOCOPY  NUMBER
)
IS
l_ozf_claim_grp_rec    OZF_CLAIM_GRP.DEDUCTION_REC_TYPE;
l_ozf_claim_pvt_rec    OZF_CLAIM_PVT.CLAIM_REC_TYPE;

TYPE NUMBER_TBL IS TABLE OF NUMBER
INDEX BY BINARY_INTEGER;
l_claim_id_tbl            NUMBER_TBL;
l_custom_setup_id_tbl     NUMBER_TBL;
l_claim_obj_ver_num_tbl   NUMBER_TBL;
idx                       NUMBER            := 1;


CURSOR split_claims_info_csr (p_id in number) IS
   SELECT claim_id, object_version_number, custom_setup_id
   FROM   ozf_claims_all
   WHERE  root_claim_id = p_id
   AND    status_code NOT IN ('CLOSED', 'CANCELLED', 'REJECTED');


BEGIN

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   Complete_OZF_Claim_Grp_Rec(
      p_ams_claim_grp_rec   => P_deduction
    , x_ozf_claim_grp_rec   => l_ozf_claim_grp_rec
    , x_return_status       => x_return_status
   );
   IF x_return_status = FND_API.G_RET_STS_ERROR then
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF p_deduction.status_code = 'CANCELLED' THEN
      IF ( NOT( check_cancell_deduction(p_deduction.claim_id))) THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_CLAIM_INVALID_STATUS_CODE');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      OPEN split_claims_info_csr(p_deduction.claim_id);
      LOOP
         FETCH split_claims_info_csr INTO l_claim_id_tbl(idx)
                                        , l_claim_obj_ver_num_tbl(idx)
                                        , l_custom_setup_id_tbl(idx);
         EXIT WHEN split_claims_info_csr%NOTFOUND OR split_claims_info_csr%NOTFOUND IS NULL;
         idx := idx + 1;
      END LOOP;
      CLOSE split_claims_info_csr;

      idx := l_claim_id_tbl.FIRST;
      IF idx IS NOT NULL THEN
         LOOP
            l_ozf_claim_pvt_rec.claim_id := l_claim_id_tbl(idx);
            l_ozf_claim_pvt_rec.object_version_number := l_claim_obj_ver_num_tbl(idx);
            l_ozf_claim_pvt_rec.custom_setup_id := l_custom_setup_id_tbl(idx);
            l_ozf_claim_pvt_rec.status_code := 'CANCELLED';

            OZF_CLAIM_PVT.Update_claim(
                 p_api_version                => 1.0,
                 p_init_msg_list              => fnd_api.g_false,
                 p_commit                     => fnd_api.g_false,
                 p_validation_level           => fnd_api.g_valid_level_full,
                 x_return_status              => x_return_status,
                 x_msg_count                  => x_msg_count,
                 x_msg_data                   => x_msg_data,
                 p_claim                      => l_ozf_claim_pvt_rec,
                 p_event                      => 'UPDATE',
                 p_mode                       => oZF_CLAIM_UTILITY_PVT.G_AUTO_MODE,
                 x_object_version_number      => l_claim_obj_ver_num_tbl(idx)
            );
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            EXIT WHEN idx = l_claim_id_tbl.LAST;
            idx := l_claim_id_tbl.NEXT(idx);
         END LOOP;
      END IF;
   ELSE
      OZF_CLAIM_GRP.Update_Deduction(
           P_Api_Version_Number     => P_Api_Version_Number,
           P_Init_Msg_List          => P_Init_Msg_List,
           p_validation_level       => p_validation_level,
           P_Commit                 => P_Commit,

           X_Return_Status          => X_Return_Status,
           X_Msg_Count              => X_Msg_Count,
           X_Msg_Data               => X_Msg_Data,

           P_deduction              => l_ozf_claim_grp_rec,
           X_Object_Version_Number  => X_Object_Version_Number
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR then
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;


EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CLAIM_UPD_DEDU_ERR');
         FND_MSG_PUB.add;
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );

End Update_Deduction;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Check_Cancell_Deduction
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       P_Claim_Id      IN   NUMBER     Required
--
--   OUT:
--       x_status                OUT  BOOLEAN
--   Version : Current version 1.0
--
--   Note: This function checks whether a claims can be cancelled or not.
--
--   End of Comments
--
FUNCTION Check_Cancell_Deduction(
    P_Claim_Id   IN               NUMBER
) RETURN BOOLEAN
IS

BEGIN

   RETURN OZF_CLAIM_GRP.Check_Cancell_Deduction(P_Claim_Id);

End Check_Cancell_Deduction ;

End AMS_claim_GRP;

/
