--------------------------------------------------------
--  DDL for Package Body OZF_CLAIM_LINES_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CLAIM_LINES_INT_PVT" as
/* $Header: ozfvclib.pls 115.2 2004/07/13 10:35:02 upoluri ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Claim_Lines_Int_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Claim_Lines_Int_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvclib.pls';

G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);

-- Hint: Primary key needs to be returned.
PROCEDURE Create_Claim_Lines_Int(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_claim_lines_int_rec               IN   claim_lines_int_rec_type  := g_miss_claim_lines_int_rec,
    x_interface_claim_line_id                   OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Claim_Lines_Int';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_INTERFACE_CLAIM_LINE_ID                  NUMBER;
   l_dummy       NUMBER;

   CURSOR c_id IS
      SELECT OZF_CLAIM_LINES_INT_ALL_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1 FROM dual
      WHERE EXISTS (SELECT 1 FROM OZF_CLAIM_LINES_INT_ALL
                    WHERE INTERFACE_CLAIM_LINE_ID = l_id);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Claim_Lines_Int_PVT;

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
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

   IF p_claim_lines_int_rec.INTERFACE_CLAIM_LINE_ID IS NULL OR p_claim_lines_int_rec.INTERFACE_CLAIM_LINE_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_INTERFACE_CLAIM_LINE_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_INTERFACE_CLAIM_LINE_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   END IF;

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
          IF g_debug THEN
             OZF_UTILITY_PVT.debug_message('Private API: Validate_Claim_Lines_Int');
          END IF;

          -- Invoke validation procedures
          Validate_claim_lines_int(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_claim_lines_int_rec  =>  p_claim_lines_int_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF g_debug THEN
         OZF_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

      -- Invoke table handler(OZF_CLAIM_LINES_INT_PKG.Insert_Row)
      OZF_CLAIM_LINES_INT_PKG.Insert_Row(
          px_interface_claim_line_id  => l_interface_claim_line_id,
          px_object_version_number  => l_object_version_number,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          p_request_id  => p_claim_lines_int_rec.request_id,
          p_program_application_id  => p_claim_lines_int_rec.program_application_id,
          p_program_update_date  => p_claim_lines_int_rec.program_update_date,
          p_program_id  => p_claim_lines_int_rec.program_id,
          p_created_from  => p_claim_lines_int_rec.created_from,
          p_interface_claim_id  => p_claim_lines_int_rec.interface_claim_id,
          p_line_number  => p_claim_lines_int_rec.line_number,
          p_split_from_claim_line_id  => p_claim_lines_int_rec.split_from_claim_line_id,
          p_amount  => p_claim_lines_int_rec.amount,
          p_claim_currency_amount  => p_claim_lines_int_rec.claim_currency_amount,
          p_acctd_amount  => p_claim_lines_int_rec.acctd_amount,
          p_currency_code  => p_claim_lines_int_rec.currency_code,
          p_exchange_rate_type  => p_claim_lines_int_rec.exchange_rate_type,
          p_exchange_rate_date  => p_claim_lines_int_rec.exchange_rate_date,
          p_exchange_rate  => p_claim_lines_int_rec.exchange_rate,
          p_set_of_books_id  => p_claim_lines_int_rec.set_of_books_id,
          p_valid_flag  => p_claim_lines_int_rec.valid_flag,
          p_source_object_id  => p_claim_lines_int_rec.source_object_id,
          p_source_object_class  => p_claim_lines_int_rec.source_object_class,
          p_source_object_type_id  => p_claim_lines_int_rec.source_object_type_id,
	  p_source_object_line_id  => p_claim_lines_int_rec.source_object_line_id,
          p_plan_id  => p_claim_lines_int_rec.plan_id,
          p_offer_id  => p_claim_lines_int_rec.offer_id,
          p_utilization_id  => p_claim_lines_int_rec.utilization_id,
          p_payment_method  => p_claim_lines_int_rec.payment_method,
          p_payment_reference_id  => p_claim_lines_int_rec.payment_reference_id,
          p_payment_reference_number  => p_claim_lines_int_rec.payment_reference_number,
          p_payment_reference_date  => p_claim_lines_int_rec.payment_reference_date,
          p_voucher_id  => p_claim_lines_int_rec.voucher_id,
          p_voucher_number  => p_claim_lines_int_rec.voucher_number,
          p_payment_status  => p_claim_lines_int_rec.payment_status,
          p_approved_flag  => p_claim_lines_int_rec.approved_flag,
          p_approved_date  => p_claim_lines_int_rec.approved_date,
          p_approved_by  => p_claim_lines_int_rec.approved_by,
          p_settled_date  => p_claim_lines_int_rec.settled_date,
          p_settled_by  => p_claim_lines_int_rec.settled_by,
          p_performance_complete_flag  => p_claim_lines_int_rec.performance_complete_flag,
          p_performance_attached_flag  => p_claim_lines_int_rec.performance_attached_flag,
          p_attribute_category  => p_claim_lines_int_rec.attribute_category,
          p_attribute1  => p_claim_lines_int_rec.attribute1,
          p_attribute2  => p_claim_lines_int_rec.attribute2,
          p_attribute3  => p_claim_lines_int_rec.attribute3,
          p_attribute4  => p_claim_lines_int_rec.attribute4,
          p_attribute5  => p_claim_lines_int_rec.attribute5,
          p_attribute6  => p_claim_lines_int_rec.attribute6,
          p_attribute7  => p_claim_lines_int_rec.attribute7,
          p_attribute8  => p_claim_lines_int_rec.attribute8,
          p_attribute9  => p_claim_lines_int_rec.attribute9,
          p_attribute10  => p_claim_lines_int_rec.attribute10,
          p_attribute11  => p_claim_lines_int_rec.attribute11,
          p_attribute12  => p_claim_lines_int_rec.attribute12,
          p_attribute13  => p_claim_lines_int_rec.attribute13,
          p_attribute14  => p_claim_lines_int_rec.attribute14,
          p_attribute15  => p_claim_lines_int_rec.attribute15,
          px_org_id  => l_org_id);
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
      IF g_debug THEN
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
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Claim_Lines_Int_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Claim_Lines_Int_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Claim_Lines_Int_PVT;
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
End Create_Claim_Lines_Int;


PROCEDURE Update_Claim_Lines_Int(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_claim_lines_int_rec               IN    claim_lines_int_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS

CURSOR c_get_claim_lines_int(p_interface_claim_line_id NUMBER) IS
    SELECT *
    FROM  OZF_CLAIM_LINES_INT_ALL
    WHERE interface_claim_line_id = p_interface_claim_line_id;

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Claim_Lines_Int';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_INTERFACE_CLAIM_LINE_ID    NUMBER;
l_ref_claim_lines_int_rec  c_get_Claim_Lines_Int%ROWTYPE ;
l_tar_claim_lines_int_rec  OZF_Claim_Lines_Int_PVT.claim_lines_int_rec_type := P_claim_lines_int_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Claim_Lines_Int_PVT;

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
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF g_debug THEN
         OZF_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');
      END IF;

/*
      OPEN c_get_Claim_Lines_Int( l_tar_claim_lines_int_rec.interface_claim_line_id);

      FETCH c_get_Claim_Lines_Int INTO l_ref_claim_lines_int_rec  ;

       If ( c_get_Claim_Lines_Int%NOTFOUND) THEN
           OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RECORD_NOT_FOUND',
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF g_debug THEN
          OZF_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_Claim_Lines_Int;
*/


      If (l_tar_claim_lines_int_rec.object_version_number is NULL or
          l_tar_claim_lines_int_rec.object_version_number = FND_API.G_MISS_NUM ) Then
          OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_NO_OBJ_VER_NUM');
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_claim_lines_int_rec.object_version_number <> l_ref_claim_lines_int_rec.object_version_number) Then
          OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF g_debug THEN
             OZF_UTILITY_PVT.debug_message('Private API: Validate_Claim_Lines_Int');
          END IF;

          -- Invoke validation procedures
          Validate_claim_lines_int(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_claim_lines_int_rec  =>  p_claim_lines_int_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF g_debug THEN
         OZF_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');
      END IF;

      -- Invoke table handler(OZF_CLAIM_LINES_INT_PKG.Update_Row)
      OZF_CLAIM_LINES_INT_PKG.Update_Row(
          p_interface_claim_line_id  => p_claim_lines_int_rec.interface_claim_line_id,
          p_object_version_number  => p_claim_lines_int_rec.object_version_number,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          p_request_id  => p_claim_lines_int_rec.request_id,
          p_program_application_id  => p_claim_lines_int_rec.program_application_id,
          p_program_update_date  => p_claim_lines_int_rec.program_update_date,
          p_program_id  => p_claim_lines_int_rec.program_id,
          p_created_from  => p_claim_lines_int_rec.created_from,
          p_interface_claim_id  => p_claim_lines_int_rec.interface_claim_id,
          p_line_number  => p_claim_lines_int_rec.line_number,
          p_split_from_claim_line_id  => p_claim_lines_int_rec.split_from_claim_line_id,
          p_amount  => p_claim_lines_int_rec.amount,
          p_claim_currency_amount  => p_claim_lines_int_rec.claim_currency_amount,
          p_acctd_amount  => p_claim_lines_int_rec.acctd_amount,
          p_currency_code  => p_claim_lines_int_rec.currency_code,
          p_exchange_rate_type  => p_claim_lines_int_rec.exchange_rate_type,
          p_exchange_rate_date  => p_claim_lines_int_rec.exchange_rate_date,
          p_exchange_rate  => p_claim_lines_int_rec.exchange_rate,
          p_set_of_books_id  => p_claim_lines_int_rec.set_of_books_id,
          p_valid_flag  => p_claim_lines_int_rec.valid_flag,
          p_source_object_id  => p_claim_lines_int_rec.source_object_id,
          p_source_object_class  => p_claim_lines_int_rec.source_object_class,
          p_source_object_type_id  => p_claim_lines_int_rec.source_object_type_id,
	  p_source_object_line_id  => p_claim_lines_int_rec.source_object_line_id,
          p_plan_id  => p_claim_lines_int_rec.plan_id,
          p_offer_id  => p_claim_lines_int_rec.offer_id,
          p_utilization_id  => p_claim_lines_int_rec.utilization_id,
          p_payment_method  => p_claim_lines_int_rec.payment_method,
          p_payment_reference_id  => p_claim_lines_int_rec.payment_reference_id,
          p_payment_reference_number  => p_claim_lines_int_rec.payment_reference_number,
          p_payment_reference_date  => p_claim_lines_int_rec.payment_reference_date,
          p_voucher_id  => p_claim_lines_int_rec.voucher_id,
          p_voucher_number  => p_claim_lines_int_rec.voucher_number,
          p_payment_status  => p_claim_lines_int_rec.payment_status,
          p_approved_flag  => p_claim_lines_int_rec.approved_flag,
          p_approved_date  => p_claim_lines_int_rec.approved_date,
          p_approved_by  => p_claim_lines_int_rec.approved_by,
          p_settled_date  => p_claim_lines_int_rec.settled_date,
          p_settled_by  => p_claim_lines_int_rec.settled_by,
          p_performance_complete_flag  => p_claim_lines_int_rec.performance_complete_flag,
          p_performance_attached_flag  => p_claim_lines_int_rec.performance_attached_flag,
          p_attribute_category  => p_claim_lines_int_rec.attribute_category,
          p_attribute1  => p_claim_lines_int_rec.attribute1,
          p_attribute2  => p_claim_lines_int_rec.attribute2,
          p_attribute3  => p_claim_lines_int_rec.attribute3,
          p_attribute4  => p_claim_lines_int_rec.attribute4,
          p_attribute5  => p_claim_lines_int_rec.attribute5,
          p_attribute6  => p_claim_lines_int_rec.attribute6,
          p_attribute7  => p_claim_lines_int_rec.attribute7,
          p_attribute8  => p_claim_lines_int_rec.attribute8,
          p_attribute9  => p_claim_lines_int_rec.attribute9,
          p_attribute10  => p_claim_lines_int_rec.attribute10,
          p_attribute11  => p_claim_lines_int_rec.attribute11,
          p_attribute12  => p_claim_lines_int_rec.attribute12,
          p_attribute13  => p_claim_lines_int_rec.attribute13,
          p_attribute14  => p_claim_lines_int_rec.attribute14,
          p_attribute15  => p_claim_lines_int_rec.attribute15,
          p_org_id  => p_claim_lines_int_rec.org_id);
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
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Claim_Lines_Int_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Claim_Lines_Int_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Claim_Lines_Int_PVT;
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
End Update_Claim_Lines_Int;


PROCEDURE Delete_Claim_Lines_Int(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_interface_claim_line_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Claim_Lines_Int';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Claim_Lines_Int_PVT;

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
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      IF g_debug THEN
         OZF_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
      END IF;

      -- Invoke table handler(OZF_CLAIM_LINES_INT_PKG.Delete_Row)
      OZF_CLAIM_LINES_INT_PKG.Delete_Row(
          p_INTERFACE_CLAIM_LINE_ID  => p_INTERFACE_CLAIM_LINE_ID);
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
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Claim_Lines_Int_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Claim_Lines_Int_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Claim_Lines_Int_PVT;
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
End Delete_Claim_Lines_Int;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Claim_Lines_Int(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_interface_claim_line_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Claim_Lines_Int';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_INTERFACE_CLAIM_LINE_ID                  NUMBER;

CURSOR c_Claim_Lines_Int IS
   SELECT INTERFACE_CLAIM_LINE_ID
   FROM OZF_CLAIM_LINES_INT_ALL
   WHERE INTERFACE_CLAIM_LINE_ID = p_INTERFACE_CLAIM_LINE_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN

      -- Debug Message
      IF g_debug THEN
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

  IF g_debug THEN
     OZF_Utility_PVT.debug_message(l_full_name||': start');
  END IF;
  OPEN c_Claim_Lines_Int;

  FETCH c_Claim_Lines_Int INTO l_INTERFACE_CLAIM_LINE_ID;

  IF (c_Claim_Lines_Int%NOTFOUND) THEN
    CLOSE c_Claim_Lines_Int;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Claim_Lines_Int;

 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  IF g_debug THEN
     OZF_Utility_PVT.debug_message(l_full_name ||': end');
  END IF;
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Claim_Lines_Int_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Claim_Lines_Int_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Claim_Lines_Int_PVT;
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
End Lock_Claim_Lines_Int;


PROCEDURE check_cl_int_uk_items(
    p_claim_lines_int_rec               IN   claim_lines_int_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := OZF_Utility_PVT.check_uniqueness(
         'OZF_CLAIM_LINES_INT_ALL',
         'INTERFACE_CLAIM_LINE_ID = ''' || p_claim_lines_int_rec.INTERFACE_CLAIM_LINE_ID ||''''
         );
      ELSE
         l_valid_flag := OZF_Utility_PVT.check_uniqueness(
         'OZF_CLAIM_LINES_INT_ALL',
         'INTERFACE_CLAIM_LINE_ID = ''' || p_claim_lines_int_rec.INTERFACE_CLAIM_LINE_ID ||
         ''' AND INTERFACE_CLAIM_LINE_ID <> ' || p_claim_lines_int_rec.INTERFACE_CLAIM_LINE_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_INTER_CLAIM_LINE_ID_DUP');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END check_cl_int_uk_items;

PROCEDURE check_cl_int_req_items(
    p_claim_lines_int_rec               IN  claim_lines_int_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_claim_lines_int_rec.interface_claim_line_id = FND_API.g_miss_num OR p_claim_lines_int_rec.interface_claim_line_id IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'INTERFACE_CLAIM_LINE_ID' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_claim_lines_int_rec.object_version_number = FND_API.g_miss_num OR p_claim_lines_int_rec.object_version_number IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_VERSION_NUMBER' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_claim_lines_int_rec.last_update_date = FND_API.g_miss_date OR p_claim_lines_int_rec.last_update_date IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'LAST_UPDATE_DATE' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_claim_lines_int_rec.last_updated_by = FND_API.g_miss_num OR p_claim_lines_int_rec.last_updated_by IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'LAST_UPDATED_BY' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_claim_lines_int_rec.creation_date = FND_API.g_miss_date OR p_claim_lines_int_rec.creation_date IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'CREATION_DATE' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_claim_lines_int_rec.created_by = FND_API.g_miss_num OR p_claim_lines_int_rec.created_by IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'CREATED_BY' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_claim_lines_int_rec.interface_claim_id = FND_API.g_miss_num OR p_claim_lines_int_rec.interface_claim_id IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'INTERFACE_CLAIM_ID' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_claim_lines_int_rec.line_number = FND_API.g_miss_num OR p_claim_lines_int_rec.line_number IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'LINE_NUMBER' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_claim_lines_int_rec.set_of_books_id = FND_API.g_miss_num OR p_claim_lines_int_rec.set_of_books_id IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'SET_OF_BOOKS_ID' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_claim_lines_int_rec.valid_flag = FND_API.g_miss_char OR p_claim_lines_int_rec.valid_flag IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'VALID_FLAG' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE


      IF p_claim_lines_int_rec.interface_claim_line_id IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'INTERFACE_CLAIM_LINE_ID' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_claim_lines_int_rec.object_version_number IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_VERSION_NUMBER' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_claim_lines_int_rec.last_update_date IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'LAST_UPDATE_DATE' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_claim_lines_int_rec.last_updated_by IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'LAST_UPDATED_BY' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_claim_lines_int_rec.creation_date IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'CREATION_DATE' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_claim_lines_int_rec.created_by IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'CREATED_BY' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_claim_lines_int_rec.interface_claim_id IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'INTERFACE_CLAIM_ID' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_claim_lines_int_rec.line_number IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'LINE_NUMBER' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_claim_lines_int_rec.set_of_books_id IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'SET_OF_BOOKS_ID' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_claim_lines_int_rec.valid_flag IS NULL THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'VALID_FLAG' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_cl_int_req_items;

PROCEDURE check_cl_int_FK_items(
    p_claim_lines_int_rec IN claim_lines_int_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_cl_int_FK_items;

PROCEDURE check_cl_int_Lk_items(
    p_claim_lines_int_rec IN claim_lines_int_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_cl_int_Lk_items;

PROCEDURE Check_claim_lines_int_Items (
    P_claim_lines_int_rec     IN    claim_lines_int_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_cl_int_uk_items(
      p_claim_lines_int_rec => p_claim_lines_int_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_cl_int_req_items(
      p_claim_lines_int_rec => p_claim_lines_int_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_cl_int_FK_items(
      p_claim_lines_int_rec => p_claim_lines_int_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_cl_int_Lk_items(
      p_claim_lines_int_rec => p_claim_lines_int_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_claim_lines_int_Items;

PROCEDURE Complete_claim_lines_int_Rec (
   p_claim_lines_int_rec IN claim_lines_int_rec_type,
   x_complete_rec OUT NOCOPY claim_lines_int_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ozf_claim_lines_int_all
      WHERE interface_claim_line_id = p_claim_lines_int_rec.interface_claim_line_id;
   l_claim_lines_int_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_claim_lines_int_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_claim_lines_int_rec;
   CLOSE c_complete;

   -- interface_claim_line_id
   IF p_claim_lines_int_rec.interface_claim_line_id = FND_API.g_miss_num THEN
      x_complete_rec.interface_claim_line_id := NULL;
   END IF;
   IF p_claim_lines_int_rec.interface_claim_line_id IS NULL THEN
      x_complete_rec.interface_claim_line_id := l_claim_lines_int_rec.interface_claim_line_id;
   END IF;

   -- object_version_number
   IF p_claim_lines_int_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := NULL;
   END IF;
   IF p_claim_lines_int_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_claim_lines_int_rec.object_version_number;
   END IF;

   -- last_update_date
   IF p_claim_lines_int_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := NULL;
   END IF;
   IF p_claim_lines_int_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_claim_lines_int_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_claim_lines_int_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := NULL;
   END IF;
   IF p_claim_lines_int_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_claim_lines_int_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_claim_lines_int_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := NULL;
   END IF;
   IF p_claim_lines_int_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_claim_lines_int_rec.creation_date;
   END IF;

   -- created_by
   IF p_claim_lines_int_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := NULL;
   END IF;
   IF p_claim_lines_int_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_claim_lines_int_rec.created_by;
   END IF;

   -- last_update_login
   IF p_claim_lines_int_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := NULL;
   END IF;
   IF p_claim_lines_int_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_claim_lines_int_rec.last_update_login;
   END IF;

   -- request_id
   IF p_claim_lines_int_rec.request_id = FND_API.g_miss_num THEN
      x_complete_rec.request_id := NULL;
   END IF;
   IF p_claim_lines_int_rec.request_id IS NULL THEN
      x_complete_rec.request_id := l_claim_lines_int_rec.request_id;
   END IF;

   -- program_application_id
   IF p_claim_lines_int_rec.program_application_id = FND_API.g_miss_num THEN
      x_complete_rec.program_application_id := NULL;
   END IF;
   IF p_claim_lines_int_rec.program_application_id IS NULL THEN
      x_complete_rec.program_application_id := l_claim_lines_int_rec.program_application_id;
   END IF;

   -- program_update_date
   IF p_claim_lines_int_rec.program_update_date = FND_API.g_miss_date THEN
      x_complete_rec.program_update_date := NULL;
   END IF;
   IF p_claim_lines_int_rec.program_update_date IS NULL THEN
      x_complete_rec.program_update_date := l_claim_lines_int_rec.program_update_date;
   END IF;

   -- program_id
   IF p_claim_lines_int_rec.program_id = FND_API.g_miss_num THEN
      x_complete_rec.program_id := NULL;
   END IF;
   IF p_claim_lines_int_rec.program_id IS NULL THEN
      x_complete_rec.program_id := l_claim_lines_int_rec.program_id;
   END IF;

   -- created_from
   IF p_claim_lines_int_rec.created_from = FND_API.g_miss_char THEN
      x_complete_rec.created_from := NULL;
   END IF;
   IF p_claim_lines_int_rec.created_from IS NULL THEN
      x_complete_rec.created_from := l_claim_lines_int_rec.created_from;
   END IF;

   -- interface_claim_id
   IF p_claim_lines_int_rec.interface_claim_id = FND_API.g_miss_num THEN
      x_complete_rec.interface_claim_id := NULL;
   END IF;
   IF p_claim_lines_int_rec.interface_claim_id IS NULL THEN
      x_complete_rec.interface_claim_id := l_claim_lines_int_rec.interface_claim_id;
   END IF;

   -- line_number
   IF p_claim_lines_int_rec.line_number = FND_API.g_miss_num THEN
      x_complete_rec.line_number := NULL;
   END IF;
   IF p_claim_lines_int_rec.line_number IS NULL THEN
      x_complete_rec.line_number := l_claim_lines_int_rec.line_number;
   END IF;

   -- split_from_claim_line_id
   IF p_claim_lines_int_rec.split_from_claim_line_id = FND_API.g_miss_num THEN
      x_complete_rec.split_from_claim_line_id := NULL;
   END IF;
   IF p_claim_lines_int_rec.split_from_claim_line_id IS NULL THEN
      x_complete_rec.split_from_claim_line_id := l_claim_lines_int_rec.split_from_claim_line_id;
   END IF;

   -- amount
   IF p_claim_lines_int_rec.amount = FND_API.g_miss_num THEN
      x_complete_rec.amount := NULL;
   END IF;
   IF p_claim_lines_int_rec.amount IS NULL THEN
      x_complete_rec.amount := l_claim_lines_int_rec.amount;
   END IF;

   -- claim_currency_amount
   IF p_claim_lines_int_rec.claim_currency_amount = FND_API.g_miss_num THEN
      x_complete_rec.claim_currency_amount := NULL;
   END IF;
   IF p_claim_lines_int_rec.claim_currency_amount IS NULL THEN
      x_complete_rec.claim_currency_amount := l_claim_lines_int_rec.claim_currency_amount;
   END IF;

   -- acctd_amount
   IF p_claim_lines_int_rec.acctd_amount = FND_API.g_miss_num THEN
      x_complete_rec.acctd_amount := NULL;
   END IF;
   IF p_claim_lines_int_rec.acctd_amount IS NULL THEN
      x_complete_rec.acctd_amount := l_claim_lines_int_rec.acctd_amount;
   END IF;

   -- currency_code
   IF p_claim_lines_int_rec.currency_code = FND_API.g_miss_char THEN
      x_complete_rec.currency_code := NULL;
   END IF;
   IF p_claim_lines_int_rec.currency_code IS NULL THEN
      x_complete_rec.currency_code := l_claim_lines_int_rec.currency_code;
   END IF;

   -- exchange_rate_type
   IF p_claim_lines_int_rec.exchange_rate_type = FND_API.g_miss_char THEN
      x_complete_rec.exchange_rate_type := NULL;
   END IF;
   IF p_claim_lines_int_rec.exchange_rate_type IS NULL THEN
      x_complete_rec.exchange_rate_type := l_claim_lines_int_rec.exchange_rate_type;
   END IF;

   -- exchange_rate_date
   IF p_claim_lines_int_rec.exchange_rate_date = FND_API.g_miss_date THEN
      x_complete_rec.exchange_rate_date := NULL;
   END IF;
   IF p_claim_lines_int_rec.exchange_rate_date IS NULL THEN
      x_complete_rec.exchange_rate_date := l_claim_lines_int_rec.exchange_rate_date;
   END IF;

   -- exchange_rate
   IF p_claim_lines_int_rec.exchange_rate = FND_API.g_miss_num THEN
      x_complete_rec.exchange_rate := NULL;
   END IF;
   IF p_claim_lines_int_rec.exchange_rate IS NULL THEN
      x_complete_rec.exchange_rate := l_claim_lines_int_rec.exchange_rate;
   END IF;

   -- set_of_books_id
   IF p_claim_lines_int_rec.set_of_books_id = FND_API.g_miss_num THEN
      x_complete_rec.set_of_books_id := NULL;
   END IF;
   IF p_claim_lines_int_rec.set_of_books_id IS NULL THEN
      x_complete_rec.set_of_books_id := l_claim_lines_int_rec.set_of_books_id;
   END IF;

   -- valid_flag
   IF p_claim_lines_int_rec.valid_flag = FND_API.g_miss_char THEN
      x_complete_rec.valid_flag := NULL;
   END IF;
   IF p_claim_lines_int_rec.valid_flag IS NULL THEN
      x_complete_rec.valid_flag := l_claim_lines_int_rec.valid_flag;
   END IF;

   -- source_object_id
   IF p_claim_lines_int_rec.source_object_id = FND_API.g_miss_num THEN
      x_complete_rec.source_object_id := NULL;
   END IF;
   IF p_claim_lines_int_rec.source_object_id IS NULL THEN
      x_complete_rec.source_object_id := l_claim_lines_int_rec.source_object_id;
   END IF;

   -- source_object_class
   IF p_claim_lines_int_rec.source_object_class = FND_API.g_miss_char THEN
      x_complete_rec.source_object_class := NULL;
   END IF;
   IF p_claim_lines_int_rec.source_object_class IS NULL THEN
      x_complete_rec.source_object_class := l_claim_lines_int_rec.source_object_class;
   END IF;

   -- source_object_type_id
   IF p_claim_lines_int_rec.source_object_type_id = FND_API.g_miss_num THEN
      x_complete_rec.source_object_type_id := NULL;
   END IF;
   IF p_claim_lines_int_rec.source_object_type_id IS NULL THEN
      x_complete_rec.source_object_type_id := l_claim_lines_int_rec.source_object_type_id;
   END IF;

   -- source_object_line_id
   IF p_claim_lines_int_rec.source_object_line_id = FND_API.g_miss_num THEN
      x_complete_rec.source_object_line_id := NULL;
   END IF;
   IF p_claim_lines_int_rec.source_object_line_id IS NULL THEN
      x_complete_rec.source_object_line_id := l_claim_lines_int_rec.source_object_line_id;
   END IF;

   -- plan_id
   IF p_claim_lines_int_rec.plan_id = FND_API.g_miss_num THEN
      x_complete_rec.plan_id := NULL;
   END IF;
   IF p_claim_lines_int_rec.plan_id IS NULL THEN
      x_complete_rec.plan_id := l_claim_lines_int_rec.plan_id;
   END IF;

   -- offer_id
   IF p_claim_lines_int_rec.offer_id = FND_API.g_miss_num THEN
      x_complete_rec.offer_id := NULL;
   END IF;
   IF p_claim_lines_int_rec.offer_id IS NULL THEN
      x_complete_rec.offer_id := l_claim_lines_int_rec.offer_id;
   END IF;

   -- utilization_id
   IF p_claim_lines_int_rec.utilization_id = FND_API.g_miss_num THEN
      x_complete_rec.utilization_id := NULL;
   END IF;
   IF p_claim_lines_int_rec.utilization_id IS NULL THEN
      x_complete_rec.utilization_id := l_claim_lines_int_rec.utilization_id;
   END IF;

   -- payment_method
   IF p_claim_lines_int_rec.payment_method = FND_API.g_miss_char THEN
      x_complete_rec.payment_method := NULL;
   END IF;
   IF p_claim_lines_int_rec.payment_method IS NULL THEN
      x_complete_rec.payment_method := l_claim_lines_int_rec.payment_method;
   END IF;

   -- payment_reference_id
   IF p_claim_lines_int_rec.payment_reference_id = FND_API.g_miss_num THEN
      x_complete_rec.payment_reference_id := NULL;
   END IF;
   IF p_claim_lines_int_rec.payment_reference_id IS NULL THEN
      x_complete_rec.payment_reference_id := l_claim_lines_int_rec.payment_reference_id;
   END IF;

   -- payment_reference_number
   IF p_claim_lines_int_rec.payment_reference_number = FND_API.g_miss_char THEN
      x_complete_rec.payment_reference_number := NULL;
   END IF;
   IF p_claim_lines_int_rec.payment_reference_number IS NULL THEN
      x_complete_rec.payment_reference_number := l_claim_lines_int_rec.payment_reference_number;
   END IF;

   -- payment_reference_date
   IF p_claim_lines_int_rec.payment_reference_date = FND_API.g_miss_date THEN
      x_complete_rec.payment_reference_date := NULL;
   END IF;
   IF p_claim_lines_int_rec.payment_reference_date IS NULL THEN
      x_complete_rec.payment_reference_date := l_claim_lines_int_rec.payment_reference_date;
   END IF;

   -- voucher_id
   IF p_claim_lines_int_rec.voucher_id = FND_API.g_miss_num THEN
      x_complete_rec.voucher_id := NULL;
   END IF;
   IF p_claim_lines_int_rec.voucher_id IS NULL THEN
      x_complete_rec.voucher_id := l_claim_lines_int_rec.voucher_id;
   END IF;

   -- voucher_number
   IF p_claim_lines_int_rec.voucher_number = FND_API.g_miss_char THEN
      x_complete_rec.voucher_number := NULL;
   END IF;
   IF p_claim_lines_int_rec.voucher_number IS NULL THEN
      x_complete_rec.voucher_number := l_claim_lines_int_rec.voucher_number;
   END IF;

   -- payment_status
   IF p_claim_lines_int_rec.payment_status = FND_API.g_miss_char THEN
      x_complete_rec.payment_status := NULL;
   END IF;
   IF p_claim_lines_int_rec.payment_status IS NULL THEN
      x_complete_rec.payment_status := l_claim_lines_int_rec.payment_status;
   END IF;

   -- approved_flag
   IF p_claim_lines_int_rec.approved_flag = FND_API.g_miss_char THEN
      x_complete_rec.approved_flag := NULL;
   END IF;
   IF p_claim_lines_int_rec.approved_flag IS NULL THEN
      x_complete_rec.approved_flag := l_claim_lines_int_rec.approved_flag;
   END IF;

   -- approved_date
   IF p_claim_lines_int_rec.approved_date = FND_API.g_miss_date THEN
      x_complete_rec.approved_date := NULL;
   END IF;
   IF p_claim_lines_int_rec.approved_date IS NULL THEN
      x_complete_rec.approved_date := l_claim_lines_int_rec.approved_date;
   END IF;

   -- approved_by
   IF p_claim_lines_int_rec.approved_by = FND_API.g_miss_num THEN
      x_complete_rec.approved_by := NULL;
   END IF;
   IF p_claim_lines_int_rec.approved_by IS NULL THEN
      x_complete_rec.approved_by := l_claim_lines_int_rec.approved_by;
   END IF;

   -- settled_date
   IF p_claim_lines_int_rec.settled_date = FND_API.g_miss_date THEN
      x_complete_rec.settled_date := NULL;
   END IF;
   IF p_claim_lines_int_rec.settled_date IS NULL THEN
      x_complete_rec.settled_date := l_claim_lines_int_rec.settled_date;
   END IF;

   -- settled_by
   IF p_claim_lines_int_rec.settled_by = FND_API.g_miss_num THEN
      x_complete_rec.settled_by := NULL;
   END IF;
   IF p_claim_lines_int_rec.settled_by IS NULL THEN
      x_complete_rec.settled_by := l_claim_lines_int_rec.settled_by;
   END IF;

   -- performance_complete_flag
   IF p_claim_lines_int_rec.performance_complete_flag = FND_API.g_miss_char THEN
      x_complete_rec.performance_complete_flag := NULL;
   END IF;
   IF p_claim_lines_int_rec.performance_complete_flag IS NULL THEN
      x_complete_rec.performance_complete_flag := l_claim_lines_int_rec.performance_complete_flag;
   END IF;

   -- performance_attached_flag
   IF p_claim_lines_int_rec.performance_attached_flag = FND_API.g_miss_char THEN
      x_complete_rec.performance_attached_flag := NULL;
   END IF;
   IF p_claim_lines_int_rec.performance_attached_flag IS NULL THEN
      x_complete_rec.performance_attached_flag := l_claim_lines_int_rec.performance_attached_flag;
   END IF;

   -- attribute_category
   IF p_claim_lines_int_rec.attribute_category = FND_API.g_miss_char THEN
      x_complete_rec.attribute_category := NULL;
   END IF;
   IF p_claim_lines_int_rec.attribute_category IS NULL THEN
      x_complete_rec.attribute_category := l_claim_lines_int_rec.attribute_category;
   END IF;

   -- attribute1
   IF p_claim_lines_int_rec.attribute1 = FND_API.g_miss_char THEN
      x_complete_rec.attribute1 := NULL;
   END IF;
   IF p_claim_lines_int_rec.attribute1 IS NULL THEN
      x_complete_rec.attribute1 := l_claim_lines_int_rec.attribute1;
   END IF;

   -- attribute2
   IF p_claim_lines_int_rec.attribute2 = FND_API.g_miss_char THEN
      x_complete_rec.attribute2 := NULL;
   END IF;
   IF p_claim_lines_int_rec.attribute2 IS NULL THEN
      x_complete_rec.attribute2 := l_claim_lines_int_rec.attribute2;
   END IF;

   -- attribute3
   IF p_claim_lines_int_rec.attribute3 = FND_API.g_miss_char THEN
      x_complete_rec.attribute3 := NULL;
   END IF;
   IF p_claim_lines_int_rec.attribute3 IS NULL THEN
      x_complete_rec.attribute3 := l_claim_lines_int_rec.attribute3;
   END IF;

   -- attribute4
   IF p_claim_lines_int_rec.attribute4 = FND_API.g_miss_char THEN
      x_complete_rec.attribute4 := NULL;
   END IF;
   IF p_claim_lines_int_rec.attribute4 IS NULL THEN
      x_complete_rec.attribute4 := l_claim_lines_int_rec.attribute4;
   END IF;

   -- attribute5
   IF p_claim_lines_int_rec.attribute5 = FND_API.g_miss_char THEN
      x_complete_rec.attribute5 := NULL;
   END IF;
   IF p_claim_lines_int_rec.attribute5 IS NULL THEN
      x_complete_rec.attribute5 := l_claim_lines_int_rec.attribute5;
   END IF;

   -- attribute6
   IF p_claim_lines_int_rec.attribute6 = FND_API.g_miss_char THEN
      x_complete_rec.attribute6 := NULL;
   END IF;
   IF p_claim_lines_int_rec.attribute6 IS NULL THEN
      x_complete_rec.attribute6 := l_claim_lines_int_rec.attribute6;
   END IF;

   -- attribute7
   IF p_claim_lines_int_rec.attribute7 = FND_API.g_miss_char THEN
      x_complete_rec.attribute7 := NULL;
   END IF;
   IF p_claim_lines_int_rec.attribute7 IS NULL THEN
      x_complete_rec.attribute7 := l_claim_lines_int_rec.attribute7;
   END IF;

   -- attribute8
   IF p_claim_lines_int_rec.attribute8 = FND_API.g_miss_char THEN
      x_complete_rec.attribute8 := NULL;
   END IF;
   IF p_claim_lines_int_rec.attribute8 IS NULL THEN
      x_complete_rec.attribute8 := l_claim_lines_int_rec.attribute8;
   END IF;

   -- attribute9
   IF p_claim_lines_int_rec.attribute9 = FND_API.g_miss_char THEN
      x_complete_rec.attribute9 := NULL;
   END IF;
   IF p_claim_lines_int_rec.attribute9 IS NULL THEN
      x_complete_rec.attribute9 := l_claim_lines_int_rec.attribute9;
   END IF;

   -- attribute10
   IF p_claim_lines_int_rec.attribute10 = FND_API.g_miss_char THEN
      x_complete_rec.attribute10 := NULL;
   END IF;
   IF p_claim_lines_int_rec.attribute10 IS NULL THEN
      x_complete_rec.attribute10 := l_claim_lines_int_rec.attribute10;
   END IF;

   -- attribute11
   IF p_claim_lines_int_rec.attribute11 = FND_API.g_miss_char THEN
      x_complete_rec.attribute11 := NULL;
   END IF;
   IF p_claim_lines_int_rec.attribute11 IS NULL THEN
      x_complete_rec.attribute11 := l_claim_lines_int_rec.attribute11;
   END IF;

   -- attribute12
   IF p_claim_lines_int_rec.attribute12 = FND_API.g_miss_char THEN
      x_complete_rec.attribute12 := NULL;
   END IF;
   IF p_claim_lines_int_rec.attribute12 IS NULL THEN
      x_complete_rec.attribute12 := l_claim_lines_int_rec.attribute12;
   END IF;

   -- attribute13
   IF p_claim_lines_int_rec.attribute13 = FND_API.g_miss_char THEN
      x_complete_rec.attribute13 := NULL;
   END IF;
   IF p_claim_lines_int_rec.attribute13 IS NULL THEN
      x_complete_rec.attribute13 := l_claim_lines_int_rec.attribute13;
   END IF;

   -- attribute14
   IF p_claim_lines_int_rec.attribute14 = FND_API.g_miss_char THEN
      x_complete_rec.attribute14 := NULL;
   END IF;
   IF p_claim_lines_int_rec.attribute14 IS NULL THEN
      x_complete_rec.attribute14 := l_claim_lines_int_rec.attribute14;
   END IF;

   -- attribute15
   IF p_claim_lines_int_rec.attribute15 = FND_API.g_miss_char THEN
      x_complete_rec.attribute15 := NULL;
   END IF;
   IF p_claim_lines_int_rec.attribute15 IS NULL THEN
      x_complete_rec.attribute15 := l_claim_lines_int_rec.attribute15;
   END IF;

   -- org_id
   IF p_claim_lines_int_rec.org_id = FND_API.g_miss_num THEN
      x_complete_rec.org_id := NULL;
   END IF;
   IF p_claim_lines_int_rec.org_id IS NULL THEN
      x_complete_rec.org_id := l_claim_lines_int_rec.org_id;
   END IF;

   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_claim_lines_int_Rec;
PROCEDURE Validate_claim_lines_int(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_claim_lines_int_rec               IN   claim_lines_int_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Claim_Lines_Int';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_claim_lines_int_rec  OZF_Claim_Lines_Int_PVT.claim_lines_int_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Claim_Lines_Int_;

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
              Check_claim_lines_int_Items(
                 p_claim_lines_int_rec        => p_claim_lines_int_rec,
                 p_validation_mode   => JTF_PLSQL_API.g_update,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_claim_lines_int_Rec(
         p_claim_lines_int_rec        => p_claim_lines_int_rec,
         x_complete_rec        => l_claim_lines_int_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_claim_lines_int_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_claim_lines_int_rec           =>    l_claim_lines_int_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      IF g_debug THEN
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      IF g_debug THEN
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
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Claim_Lines_Int_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Claim_Lines_Int_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Claim_Lines_Int_;
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
End Validate_Claim_Lines_Int;


PROCEDURE Validate_claim_lines_int_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_claim_lines_int_rec               IN    claim_lines_int_rec_type
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
      IF g_debug THEN
         OZF_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_claim_lines_int_Rec;

END OZF_Claim_Lines_Int_PVT;

/
