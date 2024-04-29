--------------------------------------------------------
--  DDL for Package Body OZF_ASSIGNMENT_QUALIFIER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_ASSIGNMENT_QUALIFIER_PUB" as
/* $Header: ozfpasqb.pls 115.0 2003/06/26 05:05:53 mchang noship $ */
-- Start of Comments
-- Package name     : OZF_ASSIGNMENT_QUALIFIER_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME             CONSTANT  VARCHAR2(30) := 'OZF_ASSIGNMENT_QUALIFIER_PUB';
G_FILE_NAME            CONSTANT VARCHAR2(15) := 'ozfpasqb.pls';

OZF_DEBUG_LOW_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);

---------------------------------------------------------------------
-- PROCEDURE
--    get_claim_type
--
-- PURPOSE
--    This procedure gets the claim type id
--
-- PARAMETERS
--    p_rec   IN DEDUCTION_REC_TYPE,
--    x_claim_type_id  OUT number
--    x_return_status  OUT VARCHAR2
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE get_claim_type(p_rec            IN DEDUCTION_REC_TYPE,
                         x_claim_type_id  OUT NOCOPY number,
			 x_return_status  OUT NOCOPY VARCHAR2)
IS
BEGIN

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   x_claim_type_id := p_rec.claim_type_id;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END get_claim_type;

---------------------------------------------------------------------
-- PROCEDURE
--    get_reason
--
-- PURPOSE
--    This procedure gets the reason
--
-- PARAMETERS
--    p_rec   IN DEDUCTION_REC_TYPE,
--    x_reason_code_id  OUT number
--    x_return_status  OUT VARCHAR2
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE get_reason(p_rec            IN DEDUCTION_REC_TYPE,
                     x_reason_code_id OUT NOCOPY number,
		     x_return_status  OUT NOCOPY VARCHAR2)
IS
BEGIN

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   x_reason_code_id := p_rec.reason_code_id;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END get_reason;


---------------------------------------------------------------------
-- PROCEDURE
--    get_cust_ref_number
--
-- PURPOSE
--    This procedure gets the customer_ref_number
--
-- PARAMETERS
--    p_rec                  IN DEDUCTION_REC_TYPE,
--    x_cust_ref_number      OUT VARCHAR2
--    x_return_status        OUT VARCHAR2
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE get_cust_ref_number(p_rec             IN DEDUCTION_REC_TYPE,
                              x_cust_ref_number OUT NOCOPY VARCHAR2,
		              x_return_status   OUT NOCOPY VARCHAR2)
IS
BEGIN

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   x_cust_ref_number := p_rec.customer_ref_number;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END get_cust_ref_number;

---------------------------------------------------------------------
-- PROCEDURE
--    get_cust_ref_date
--
-- PURPOSE
--    This procedure gets the customer_ref_date
--
-- PARAMETERS
--    p_rec                  IN  DEDUCTION_REC_TYPE,
--    x_cust_ref_date        OUT DATE
--    x_return_status        OUT VARCHAR2
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE get_cust_ref_date(p_rec             IN DEDUCTION_REC_TYPE,
                            x_cust_ref_date   OUT NOCOPY DATE,
		            x_return_status   OUT NOCOPY VARCHAR2)
IS
BEGIN

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   x_cust_ref_date := p_rec.customer_ref_date;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END get_cust_ref_date;

---------------------------------------------------------------------
--   PROCEDURE:  Get_Deduction_Value
--
--   PURPOSE:
--   This procedure modifies the values of a deduction record.
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
--       X_qualifier              OUT  DEDUCTION_REC_TYPE
--   NOTES:
--
---------------------------------------------------------------------
PROCEDURE Get_Deduction_Value(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,

    P_deduction                  IN   DEDUCTION_REC_TYPE,
    X_qualifier                  OUT NOCOPY  Qualifier_Rec_Type
    )
IS
l_api_name                CONSTANT VARCHAR2(30) := 'Get_Deduction_Value';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_full_name               CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status varchar2(30);
l_qualifier     OZF_ASSIGNMENT_QUALIFIER_PUB.Qualifier_Rec_Type;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT GET_DED_VAL_PUB;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
      FND_MSG_PUB.Add;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  get_claim_type(p_rec           => p_deduction,
                 x_claim_type_id => l_qualifier.claim_type_id,
	         x_return_status => l_return_status);
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  get_reason(p_rec           => p_deduction,
             x_reason_code_id=> l_qualifier.reason_code_id,
	     x_return_status => l_return_status);
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  get_cust_ref_number(p_rec             => p_deduction,
                      x_cust_ref_number => l_qualifier.customer_ref_number,
	              x_return_status   => l_return_status);
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  get_cust_ref_date(p_rec           => p_deduction,
                    x_cust_ref_date => l_qualifier.customer_ref_date,
	            x_return_status => l_return_status);
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- assign the rest of the values

  l_qualifier.CLAIM_DATE := p_deduction.CLAIM_DATE;
  l_qualifier.DUE_DATE   := p_deduction.DUE_DATE;
  l_qualifier.OWNER_ID   := p_deduction.OWNER_ID;
  l_qualifier.CUST_BILLTO_ACCT_SITE_ID := p_deduction.CUST_BILLTO_ACCT_SITE_ID;
  l_qualifier.CUST_SHIPTO_ACCT_SITE_ID:= p_deduction.CUST_SHIPTO_ACCT_SITE_ID;
  l_qualifier.SALES_REP_ID:= p_deduction.SALES_REP_ID;
  l_qualifier.CONTACT_ID := p_deduction.CONTACT_ID;
  l_qualifier.BROKER_ID  := p_deduction.BROKER_ID;
  l_qualifier.GL_DATE    := p_deduction.GL_DATE;
  l_qualifier.COMMENTS   := p_deduction.COMMENTS;

  x_qualifier := l_qualifier;

  -- Standard check for p_commit
  IF FND_API.to_Boolean( p_commit )
  THEN
     COMMIT WORK;
  END IF;

  -- Debug Message
  IF OZF_DEBUG_LOW_ON THEN
     FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
     FND_MSG_PUB.Add;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
     p_count          =>   x_msg_count,
     p_data           =>   x_msg_data
  );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO GET_DED_VAL_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO GET_DED_VAL_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO GET_DED_VAL_PUBP;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_ASS_QUA_ERR');
         FND_MSG_PUB.add;
      END IF;

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
End get_deduction_value;

End OZF_ASSIGNMENT_QUALIFIER_PUB;

/
