--------------------------------------------------------
--  DDL for Package Body OZF_OFFER_BACKDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFER_BACKDATE_PVT" as
/* $Header: ozfvobdb.pls 120.9 2006/07/20 12:15:00 mgudivak ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Offer_Backdate_PVT
-- Purpose
--
-- History
--   05-DEC-2002 julou 1. sql performance fix
--   11-DEC-2002 julou change ams_offer_adjustments to ozf_offer_adjustments_b
--   Tue Dec 02 2003:7/44 PM RSSHARMA Fixed process_new_adjustments removed reference to all ams tables
--  Wed Nov 24 2004:4/15 PM RSSHARMA Fixed bug # 4027062(11.5.9),4085552 (11.5.10). Introduced new procedure update_volume_offer_discounts
--  to update the disocunts and tiers for Volume Offer.
-- Mon Aug 01 2005:2/12 AM rssharma Fixed bug # 4522172. Send arithmetic operator while activating new adjustment lines
-- else the discount type is converted to amount
-- Wed Sep 21 2005:5/16 PM RSSHARMA. Fixed bug #4626103. Changes approach for adjusting tiers. RIght now we
-- are just updating the tiers in QP and expecting the Accrual engine to call the update_offer_discounts api
-- to update discounts after the adjustment is effective
-- NOTE
--
-- End of Comments
--  Thu Aug 19 1999:6/43 AM RSSHARMA Added procedure process_vo_adjustments for processing volume offer adjustments
-- Tue Sep 27 2005:6/50 PM RSSHARMA Added logic to end date adjustments
-- Mon Oct 03 2005:6/39 PM RSSHARMA Added start date and end dates to new products
-- Mon Oct 03 2005:8/57 PM RSSHARMA Fixed issue with adjustment did not go active if volumeType on the tier was quantity
-- with error message Benefit Quantity/Benefit UOM are required. The issue was that arithmetic_operator was not passed
-- in hence some if conditions failed which populated values into benefit_qty and benefit_uom which should not have.
-- Pass arithmetic_operator to fix the issue
-- Wed Mar 29 2006:5/46 PM  RSSHARMA Added new procedures to close adjustments and changed update_offer_discounts for new adjustments functionality
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Offer_Backdate_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvobdb.pls';


-- Hint: Primary key needs to be returned.
PROCEDURE Create_Offer_Backdate(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offer_backdate_rec               IN   offer_backdate_rec_type  := g_miss_offer_backdate_rec,
    x_offer_adjustment_id                   OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Offer_Backdate';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_OFFER_ADJUSTMENT_ID                  NUMBER;
   l_dummy       NUMBER;

   CURSOR c_id IS
      SELECT ozf_OFFER_ADJUSTMENTS_B_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM ozf_OFFER_ADJUSTMENTS_B
      WHERE OFFER_ADJUSTMENT_ID = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Offer_Backdate_PVT;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

   IF p_offer_backdate_rec.OFFER_ADJUSTMENT_ID IS NULL OR p_offer_backdate_rec.OFFER_ADJUSTMENT_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_OFFER_ADJUSTMENT_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_OFFER_ADJUSTMENT_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
	  END LOOP;
   --ELSE
         --p_offer_backdate_rec.offer_adjustment_id := l_offer_adjustment_id;
    END IF;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.User_Id IS NULL
      THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          OZF_UTILITY_PVT.debug_message('Private API: Validate_Offer_Backdate');

          -- Invoke validation procedures
          Validate_offer_backdate(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            p_offer_backdate_rec  =>  p_offer_backdate_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');

      -- Invoke table handler(ozf_OFFER_ADJUSTMENTS_PKG.Insert_Row)
      ozf_OFFER_ADJUSTMENTS_PKG.Insert_Row(
          px_offer_adjustment_id  => l_offer_adjustment_id,
          p_effective_date  => p_offer_backdate_rec.effective_date,
          p_approved_date  => p_offer_backdate_rec.approved_date,
          p_settlement_code  => p_offer_backdate_rec.settlement_code,
          p_status_code  => p_offer_backdate_rec.status_code,
          p_list_header_id  => p_offer_backdate_rec.list_header_id,
          p_version  => p_offer_backdate_rec.version,
          p_budget_adjusted_flag  => p_offer_backdate_rec.budget_adjusted_flag,
          p_comments  => p_offer_backdate_rec.comments,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          px_object_version_number  => l_object_version_number,
          p_security_group_id  => p_offer_backdate_rec.security_group_id);

          x_offer_adjustment_id := l_offer_adjustment_id;
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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

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
     ROLLBACK TO CREATE_Offer_Backdate_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Offer_Backdate_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Offer_Backdate_PVT;
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
End Create_Offer_Backdate;


PROCEDURE Update_Offer_Backdate(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offer_backdate_rec               IN    offer_backdate_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS

CURSOR c_get_Offer_Backdate(p_offer_adjustment_id NUMBER) IS
    SELECT *
    FROM  ozf_offer_adjustments_B
    WHERE  offer_adjustment_id = p_offer_adjustment_id ;

CURSOR c_get_offer_status(p_offer_adjustment_id NUMBER) IS
    SELECT status_code
    FROM  ozf_offer_adjustments_B
    WHERE  offer_adjustment_id = p_offer_adjustment_id ;

l_current_status_code VARCHAR2(30);
l_new_status_code     VARCHAR2(30);

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Offer_Backdate';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_OFFER_ADJUSTMENT_ID    NUMBER;
l_ref_offer_backdate_rec  c_get_Offer_Backdate%ROWTYPE ;
l_tar_offer_backdate_rec  OZF_Offer_Backdate_PVT.offer_backdate_rec_type := P_offer_backdate_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Offer_Backdate_PVT;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');

/*
      OPEN c_get_Offer_Backdate( l_tar_offer_backdate_rec.offer_adjustment_id);

      FETCH c_get_Offer_Backdate INTO l_ref_offer_backdate_rec  ;

       If ( c_get_Offer_Backdate%NOTFOUND) THEN
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Offer_Backdate') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       OZF_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       CLOSE     c_get_Offer_Backdate;
*/


      If (l_tar_offer_backdate_rec.object_version_number is NULL or
          l_tar_offer_backdate_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_offer_backdate_rec.object_version_number <> l_ref_offer_backdate_rec.object_version_number) Then
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Offer_Backdate') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          OZF_UTILITY_PVT.debug_message('Private API: Validate_Offer_Backdate');

          -- Invoke validation procedures
          Validate_offer_backdate(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_offer_backdate_rec  =>  p_offer_backdate_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

     OPEN c_get_offer_status(p_offer_backdate_rec.offer_adjustment_id);
     FETCH c_get_offer_status INTO l_current_status_code;
     CLOSE c_get_offer_status;

     l_new_status_code := p_offer_backdate_rec.status_code;

     IF    ( l_current_status_code <> l_new_status_code )
     THEN

           IF ( l_new_status_code = 'ACTIVE' )
           THEN
               -- Call Approval Work Flow



                AMS_GEN_APPROVAL_PVT.StartProcess
                 (p_activity_type  => 'OFFR'
                  ,p_activity_id    => p_offer_backdate_rec.offer_adjustment_id
                  ,p_approval_type  => 'BUDGET'
                  ,p_object_version_number  =>p_offer_backdate_rec.object_version_number
                  ,p_orig_stat_id           => 0
                  ,p_new_stat_id            => 0
                  ,p_reject_stat_id         => 0
                  ,p_requester_userid       => OZF_Utility_PVT.get_resource_id(NVL(FND_GLOBAL.user_id,-1))
                  ,p_notes_from_requester   => p_offer_backdate_rec.comments
                  ,p_workflowprocess        => 'OZFGAPP'
                  ,p_item_type              => 'OZFGAPP');


               l_new_status_code := 'PENDING';

           END IF;
     END IF;



      -- Debug Message
     -- OZF_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');

      -- Invoke table handler(ozf_OFFER_ADJUSTMENTS_PKG.Update_Row)
      ozf_OFFER_ADJUSTMENTS_PKG.Update_Row(
          p_offer_adjustment_id  => p_offer_backdate_rec.offer_adjustment_id,
          p_effective_date  => p_offer_backdate_rec.effective_date,
          p_approved_date  => p_offer_backdate_rec.approved_date,
          p_settlement_code  => p_offer_backdate_rec.settlement_code,
          p_status_code  => l_new_status_code,          -- p_offer_backdate_rec.status_code,
          p_list_header_id  => p_offer_backdate_rec.list_header_id,
          p_version  => p_offer_backdate_rec.version,
          p_budget_adjusted_flag  => p_offer_backdate_rec.budget_adjusted_flag,
          p_comments  => p_offer_backdate_rec.comments,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          p_object_version_number  => p_offer_backdate_rec.object_version_number,
          p_security_group_id  => p_offer_backdate_rec.security_group_id);

          x_object_version_number := p_offer_backdate_rec.object_version_number + 1;

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

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
     ROLLBACK TO UPDATE_Offer_Backdate_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Offer_Backdate_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Offer_Backdate_PVT;
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
End Update_Offer_Backdate;


PROCEDURE Delete_Offer_Backdate(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_offer_adjustment_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Offer_Backdate';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Offer_Backdate_PVT;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      OZF_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');

      -- Invoke table handler(ozf_OFFER_ADJUSTMENTS_PKG.Delete_Row)
      ozf_OFFER_ADJUSTMENTS_PKG.Delete_Row(
          p_OFFER_ADJUSTMENT_ID  => p_OFFER_ADJUSTMENT_ID);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

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
     ROLLBACK TO DELETE_Offer_Backdate_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Offer_Backdate_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Offer_Backdate_PVT;
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
End Delete_Offer_Backdate;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Offer_Backdate(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offer_adjustment_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Offer_Backdate';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_OFFER_ADJUSTMENT_ID                  NUMBER;

CURSOR c_Offer_Backdate IS
   SELECT OFFER_ADJUSTMENT_ID
   FROM ozf_OFFER_ADJUSTMENTS_B
   WHERE OFFER_ADJUSTMENT_ID = p_OFFER_ADJUSTMENT_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN

      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

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

  OZF_Utility_PVT.debug_message(l_full_name||': start');
  OPEN c_Offer_Backdate;

  FETCH c_Offer_Backdate INTO l_OFFER_ADJUSTMENT_ID;

  IF (c_Offer_Backdate%NOTFOUND) THEN
    CLOSE c_Offer_Backdate;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Offer_Backdate;

 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  OZF_Utility_PVT.debug_message(l_full_name ||': end');
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Offer_Backdate_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Offer_Backdate_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Offer_Backdate_PVT;
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
End Lock_Offer_Backdate;


PROCEDURE check_offer_backdate_uk_items(
    p_offer_backdate_rec               IN   offer_backdate_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := OZF_Utility_PVT.check_uniqueness(
         'OZF_OFFER_ADJUSTMENTS_B',
         'OFFER_ADJUSTMENT_ID = ''' || p_offer_backdate_rec.OFFER_ADJUSTMENT_ID ||''''
         );
      ELSE
         l_valid_flag := OZF_Utility_PVT.check_uniqueness(
         'OZF_OFFER_ADJUSTMENTS_B',
         'OFFER_ADJUSTMENT_ID = ''' || p_offer_backdate_rec.OFFER_ADJUSTMENT_ID ||
         ''' AND OFFER_ADJUSTMENT_ID <> ' || p_offer_backdate_rec.OFFER_ADJUSTMENT_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFER_ADJ_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END check_offer_backdate_uk_items;

PROCEDURE check_offer_backdate_req_items(
    p_offer_backdate_rec               IN  offer_backdate_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   --IF p_validation_mode = JTF_PLSQL_API.g_create THEN
   --ELSE
   --END IF;

END check_offer_backdate_req_items;

PROCEDURE check_offer_backdate_FK_items(
    p_offer_backdate_rec IN offer_backdate_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_offer_backdate_FK_items;

/*PROCEDURE check_offer_backdate_Lookup_items(
    p_offer_backdate_rec IN offer_backdate_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_offer_backdate_Lookup_items;*/

PROCEDURE Check_offer_backdate_Items (
    P_offer_backdate_rec     IN    offer_backdate_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_offer_backdate_uk_items(
      p_offer_backdate_rec => p_offer_backdate_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_offer_backdate_req_items(
      p_offer_backdate_rec => p_offer_backdate_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_offer_backdate_FK_items(
      p_offer_backdate_rec => p_offer_backdate_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

  /* check_offer_backdate_Lookup_items(
      p_offer_backdate_rec => p_offer_backdate_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF; */

END Check_offer_backdate_Items;



PROCEDURE Complete_offer_backdate_Rec (
   p_offer_backdate_rec IN offer_backdate_rec_type,
   x_complete_rec OUT NOCOPY offer_backdate_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ozf_offer_adjustments_b
      WHERE offer_adjustment_id = p_offer_backdate_rec.offer_adjustment_id;
   l_offer_backdate_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_offer_backdate_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_offer_backdate_rec;
   CLOSE c_complete;

   -- offer_adjustment_id
   IF p_offer_backdate_rec.offer_adjustment_id = FND_API.g_miss_num THEN
      x_complete_rec.offer_adjustment_id := NULL;
   END IF;
   IF p_offer_backdate_rec.offer_adjustment_id IS NULL THEN
      x_complete_rec.offer_adjustment_id := l_offer_backdate_rec.offer_adjustment_id;
   END IF;

   -- effective_date
   IF p_offer_backdate_rec.effective_date = FND_API.g_miss_date THEN
      x_complete_rec.effective_date := NULL;
   END IF;
   IF p_offer_backdate_rec.effective_date IS NULL THEN
      x_complete_rec.effective_date := l_offer_backdate_rec.effective_date;
   END IF;

   -- approved_date
   IF p_offer_backdate_rec.approved_date = FND_API.g_miss_date THEN
      x_complete_rec.approved_date := NULL;
   END IF;
   IF p_offer_backdate_rec.approved_date IS NULL THEN
      x_complete_rec.approved_date := l_offer_backdate_rec.approved_date;
   END IF;

   -- settlement_code
   IF p_offer_backdate_rec.settlement_code = FND_API.g_miss_char THEN
      x_complete_rec.settlement_code := NULL;
   END IF;
   IF p_offer_backdate_rec.settlement_code IS NULL THEN
      x_complete_rec.settlement_code := l_offer_backdate_rec.settlement_code;
   END IF;

   -- status_code
   IF p_offer_backdate_rec.status_code = FND_API.g_miss_char THEN
      x_complete_rec.status_code := NULL;
   END IF;
   IF p_offer_backdate_rec.status_code IS NULL THEN
      x_complete_rec.status_code := l_offer_backdate_rec.status_code;
   END IF;

   -- list_header_id
   IF p_offer_backdate_rec.list_header_id = FND_API.g_miss_num THEN
      x_complete_rec.list_header_id := NULL;
   END IF;
   IF p_offer_backdate_rec.list_header_id IS NULL THEN
      x_complete_rec.list_header_id := l_offer_backdate_rec.list_header_id;
   END IF;

   -- version
   IF p_offer_backdate_rec.version = FND_API.g_miss_num THEN
      x_complete_rec.version := NULL;
   END IF;
   IF p_offer_backdate_rec.version IS NULL THEN
      x_complete_rec.version := l_offer_backdate_rec.version;
   END IF;

   -- budget_adjusted_flag
   IF p_offer_backdate_rec.budget_adjusted_flag = FND_API.g_miss_char THEN
      x_complete_rec.budget_adjusted_flag := NULL;
   END IF;
   IF p_offer_backdate_rec.budget_adjusted_flag IS NULL THEN
      x_complete_rec.budget_adjusted_flag := l_offer_backdate_rec.budget_adjusted_flag;
   END IF;

   -- comments
   IF p_offer_backdate_rec.comments = FND_API.g_miss_char THEN
      x_complete_rec.comments := NULL;
   END IF;
   IF p_offer_backdate_rec.comments IS NULL THEN
      x_complete_rec.comments := l_offer_backdate_rec.comments;
   END IF;

   -- last_update_date
   IF p_offer_backdate_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := NULL;
   END IF;
   IF p_offer_backdate_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_offer_backdate_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_offer_backdate_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := NULL;
   END IF;
   IF p_offer_backdate_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_offer_backdate_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_offer_backdate_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := NULL;
   END IF;
   IF p_offer_backdate_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_offer_backdate_rec.creation_date;
   END IF;

   -- created_by
   IF p_offer_backdate_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := NULL;
   END IF;
   IF p_offer_backdate_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_offer_backdate_rec.created_by;
   END IF;

   -- last_update_login
   IF p_offer_backdate_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := NULL;
   END IF;
   IF p_offer_backdate_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_offer_backdate_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_offer_backdate_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := NULL;
   END IF;
   IF p_offer_backdate_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_offer_backdate_rec.object_version_number;
   END IF;

   -- security_group_id
   IF p_offer_backdate_rec.security_group_id = FND_API.g_miss_num THEN
      x_complete_rec.security_group_id := NULL;
   END IF;
   IF p_offer_backdate_rec.security_group_id IS NULL THEN
      x_complete_rec.security_group_id := l_offer_backdate_rec.security_group_id;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_offer_backdate_Rec;
PROCEDURE Validate_offer_backdate(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_offer_backdate_rec               IN   offer_backdate_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Offer_Backdate';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_offer_backdate_rec  OZF_Offer_Backdate_PVT.offer_backdate_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Offer_Backdate_;

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
              Check_offer_backdate_Items(
                 p_offer_backdate_rec        => p_offer_backdate_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_offer_backdate_Rec(
         p_offer_backdate_rec        => p_offer_backdate_rec,
         x_complete_rec        => l_offer_backdate_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_offer_backdate_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_offer_backdate_rec           =>    l_offer_backdate_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

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
     ROLLBACK TO VALIDATE_Offer_Backdate_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Offer_Backdate_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Offer_Backdate_;
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
End Validate_Offer_Backdate;


PROCEDURE Validate_offer_backdate_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_offer_backdate_rec               IN    offer_backdate_rec_type
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
      OZF_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_offer_backdate_Rec;

PROCEDURE Create_Initial_Adj(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
    p_commit           IN  VARCHAR2  := FND_API.g_false,
    p_obj_id           IN   NUMBER,
    p_obj_type         IN   VARCHAR2 ,
    x_return_status    OUT NOCOPY  VARCHAR2,
    x_msg_count        OUT NOCOPY  NUMBER,
    x_msg_data         OUT NOCOPY  VARCHAR2
     )
IS

l_OFFER_ADJUSTMENT_ID                  NUMBER;
l_OFFER_ADJUSTMENT_LINE_ID             NUMBER;
l_dummy       NUMBER;
l_pricing_attribute_id  NUMBER;
l_list_line_id          NUMBER;
l_arithmetic_operator   VARCHAR2(30);
l_arithmetic_name       VARCHAR2(30);
l_operand               NUMBER;
L_API_NAME              CONSTANT VARCHAR2(30) := 'CREATE_INITIAL_ADJ';
l_count                 NUMBER := 0;
CURSOR c_id IS
      SELECT ozf_OFFER_ADJUSTMENTS_B_s.NEXTVAL
      FROM dual;

CURSOR c_line_id IS
      SELECT ozf_OFFER_ADJUSTMENT_LINES_s.NEXTVAL
      FROM dual;

CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM ozf_OFFER_ADJUSTMENTS_B
      WHERE OFFER_ADJUSTMENT_ID = l_id;

CURSOR c_offer_data (l_id IN NUMBER) IS
      select qp.pricing_attribute_id,
             ql.list_line_id,
             ql.arithmetic_operator,
             ql.operand
     from qp_pricing_attributes qp,
          qp_list_lines ql
     where ql.list_header_id = l_id
     and   qp.list_header_id = l_id -- julou added for sql performance xxfix
     and  ql.list_line_id = qp.list_line_id
     and qp.excluder_flag = 'N';


BEGIN

  LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_OFFER_ADJUSTMENT_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_OFFER_ADJUSTMENT_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
  END LOOP;

INSERT INTO ozf_OFFER_ADJUSTMENTS_B(
           offer_adjustment_id,
	   list_header_id,
           status_code,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
	   object_version_number
       ) VALUES (
           l_OFFER_ADJUSTMENT_ID,
	   p_obj_id,
           'DRAFT',
           SYSDATE,
           FND_GLOBAL.USER_ID,
           SYSDATE,
           FND_GLOBAL.USER_ID,
           FND_GLOBAL.CONC_LOGIN_ID,
	   1
                );

OPEN c_offer_data(p_obj_id);
   LOOP
     FETCH c_offer_data INTO l_pricing_attribute_id,l_list_line_id,l_arithmetic_operator,l_operand;
     LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_OFFER_ADJUSTMENT_LINE_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_OFFER_ADJUSTMENT_LINE_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
     END LOOP;
          EXIT WHEN c_offer_data%NOTFOUND;

         INSERT INTO ozf_OFFER_ADJUSTMENT_LINES(
           offer_adjustment_line_id,
	   offer_adjustment_id,
	   list_line_id,
	   arithmetic_operator,
	   original_discount,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
	   object_version_number
          ) VALUES (
           l_OFFER_ADJUSTMENT_LINE_ID,
	   l_OFFER_ADJUSTMENT_ID,
	   l_list_line_id,
	   l_arithmetic_operator,
	   l_operand,
           SYSDATE,
           FND_GLOBAL.USER_ID,
           SYSDATE,
           FND_GLOBAL.USER_ID,
           FND_GLOBAL.CONC_LOGIN_ID,
	   1
                );

     -- process data record
   END LOOP;
CLOSE c_offer_data;

EXCEPTION

    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;

      FND_MESSAGE.set_name('OZF', 'OZF_CREATE_OFFR_ADJ_FAILED');
      FND_MESSAGE.set_token('ERR_MSG',SQLERRM);
      FND_MSG_PUB.add;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(p_encoded => FND_API.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END Create_Initial_Adj;

-------------------------------------------------------
-- Start of Comments
--
-- NAME
--   process_new_adjustments
--
-- PURPOSE
--   This Procedure Activates the Discount Lines added to an Offer thru. Offer Adjustment.
-- this is supposed to be called internally by update_offer_discounts
--
-- IN
--   p_init_msg_list         IN   VARCHAR2,
--   p_api_version           IN   NUMBER,
--   p_commit                IN   VARCHAR2,
--   p_offer_adjustment_id   IN   NUMBER
--
-- OUT
--   x_return_status         OUT  VARCHAR2,
--   x_msg_count             OUT  NUMBER,
--   x_msg_data              OUT  VARCHAR2,
--
-- NOTES
--
-- HISTORY
--    Mon Dec 01 2003:7/26 PM rssharma    created
-- End of Comments
---------------------------------------------------------
procedure process_new_adjustments(
   p_init_msg_list         IN   VARCHAR2 := FND_API.g_false
  ,p_api_version           IN   NUMBER
  ,p_commit                IN   VARCHAR2 := FND_API.g_false
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offer_adjustment_id   IN   NUMBER
)
IS
   l_api_name VARCHAR2(30) := 'process_new_adjustments';
   l_qp_list_header_id NUMBER;
   l_error_location    NUMBER;
   l_modifier_list_rec ozf_offer_pvt.modifier_list_rec_type;
   l_modifier_line_tbl ozf_offer_pvt.modifier_line_tbl_type ;

   l_line_ctr          NUMBER := 1;
   l_offer_type VARCHAR2(30);

   CURSOR get_offer_type IS
   SELECT o.offer_type
   FROM   ozf_offers o,
          ozf_offer_adjustments_vl a
   WHERE  a.offer_adjustment_id = p_offer_adjustment_id
   and    a.list_header_id = o.qp_list_header_id ;

  -- julou backdated offer for Promotional Goods, Trade Deal, Tiered Discount
  CURSOR c_qp_line_detail(l_list_line_id NUMBER) IS
  SELECT *
    FROM qp_list_lines
   WHERE list_line_id = l_list_line_id;
  l_qp_line_detail c_qp_line_detail%ROWTYPE;
  l_qp_rltd_line_detail c_qp_line_detail%ROWTYPE;

  CURSOR c_effectiveDate(cp_offerAdjustmentId NUMBER) IS
  SELECT effective_date
    FROM ozf_offer_adjustments_b
   WHERE offer_adjustment_id = cp_offerAdjustmentId;
  l_effectiveDate    DATE;


  CURSOR c_adj_lines IS
  SELECT list_line_id
	,list_line_id_td
	,list_header_id
    , arithmetic_operator
    , discount_end_date
    FROM ozf_offer_adjustment_lines
   WHERE offer_adjustment_id = p_offer_adjustment_id
   AND created_from_adjustments = 'Y';

  CURSOR c_rltd_line(p_list_header_id NUMBER, p_list_line_id NUMBER) IS
  SELECT related_deal_lines_id
        ,modifier_id
        ,related_modifier_id
        ,object_version_number
    FROM ozf_related_deal_lines
   WHERE qp_list_header_id = p_list_header_id
     AND modifier_id = p_list_line_id;
  l_rltd_line c_rltd_line%ROWTYPE;

  l_index    NUMBER := 0;
  l_dummy    NUMBER;
  -- julou end
BEGIN

ozf_utility_pvt.debug_message('inside process new adjustments');
   IF   Fnd_Api.to_boolean(p_init_msg_list)
   THEN

        Fnd_Msg_Pub.initialize;


   END IF;

    IF   NOT Fnd_Api.compatible_api_call (  p_api_version,
                                            p_api_version,
                                            l_api_name,
                                            g_pkg_name
                                           )
    THEN

         RAISE Fnd_Api.g_exc_unexpected_error;

   END IF;

  x_return_status := Fnd_Api.g_ret_sts_success;

  -- julou backdated offer for Promotional Goods, Trade Deal, Tiered Discount
  -- set operation to NULL should prevent operation on list header and offer tables
  l_modifier_list_rec.offer_operation := NULL;
  l_modifier_list_rec.modifier_operation := NULL;

  OPEN get_offer_type;
  FETCH get_offer_type INTO l_offer_type;
  CLOSE get_offer_type;

  OPEN c_effectiveDate(p_offer_adjustment_id);
  FETCH c_effectiveDate INTO l_effectiveDate;
  CLOSE c_effectiveDate;
ozf_utility_pvt.debug_message('offer_type is '||l_offer_type);
  IF l_offer_type IN ('OID', 'ACCRUAL', 'OFF_INVOICE', 'ORDER', 'DEAL','VOLUME_OFFER') THEN
    FOR l_adj_line IN c_adj_lines LOOP
      -- initialize
      l_qp_line_detail := NULL;
      l_qp_rltd_line_detail := NULL;
      l_rltd_line := NULL;

      l_index := l_index + 1;

      l_modifier_line_tbl(l_index).operation := 'UPDATE';
      l_modifier_line_tbl(l_index).list_header_id := l_adj_line.list_header_id;--l_qp_line_detail.list_header_id;
      l_modifier_line_tbl(l_index).inactive_flag := 'Y';
      l_modifier_line_tbl(l_index).end_date_active := l_adj_line.discount_end_date;
      l_modifier_line_tbl(l_index).start_date_active := l_effectiveDate;
      l_modifier_line_tbl(l_index).arithmetic_operator := l_adj_line.arithmetic_operator;
      IF l_offer_type IN ('OID', 'ACCRUAL', 'OFF_INVOICE', 'ORDER','VOLUME_OFFER') THEN
        l_modifier_line_tbl(l_index).list_line_id := l_adj_line.list_line_id;
      ELSIF l_offer_type = 'DEAL' THEN
        OPEN c_rltd_line(l_adj_line.list_header_id,l_adj_line.list_line_id);
        FETCH c_rltd_line INTO l_rltd_line;
        CLOSE c_rltd_line;
        l_modifier_line_tbl(l_index).qd_related_deal_lines_id := l_rltd_line.related_deal_lines_id;
        l_modifier_line_tbl(l_index).list_line_id := l_adj_line.list_line_id;
        l_modifier_line_tbl(l_index).qd_object_version_number := l_rltd_line.object_version_number;
        l_modifier_line_tbl(l_index).qd_list_line_id := l_adj_line.list_line_id_td;
      END IF;
    END LOOP;
     ozf_offer_pvt.process_modifiers ( p_init_msg_list
                                      ,p_api_version
                                      ,p_commit
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data
                                      ,l_offer_type
                                      ,l_modifier_list_rec
                                      ,l_modifier_line_tbl
                                      ,l_qp_list_header_id
                                      ,l_error_location
                                    );
  END IF; -- end l_offer_type
END process_new_adjustments;


-------------------------------------------------------------------------------------------
-- Procedure :
--  Name : update_volume_offer_discounts
--  Updates the tiers and Discounts for Volume Offer tiers
-------------------------------------------------------------------------------------------
PROCEDURE update_volume_offer_discounts
(
  p_init_msg_list         IN   VARCHAR2 := FND_API.g_false
  ,p_api_version           IN   NUMBER
  ,p_commit                IN   VARCHAR2 := FND_API.g_false
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offer_adjustment_id   IN   NUMBER
)
IS
   l_qp_list_header_id NUMBER;
   l_error_location    NUMBER;
   l_modifier_list_rec ozf_offer_pvt.modifier_list_rec_type;
   l_modifier_line_tbl ozf_offer_pvt.modifier_line_tbl_type ;

   l_offer_type VARCHAR2(30);

  CURSOR c_qp_line_detail(p_list_header_id NUMBER) IS
  SELECT *
    FROM qp_list_lines
   WHERE list_header_id = p_list_header_id;
  l_qp_line_detail c_qp_line_detail%ROWTYPE;



  CURSOR c_adj_lines IS
  SELECT  modified_discount , qp_list_header_id
  FROM OZF_OFFER_ADJUSTMENT_TIERS
  WHERE
    offer_adjustment_id = p_offer_adjustment_id
  AND original_discount =
  (SELECT operand FROM qp_list_lines WHERE list_header_id
  = (select qp_list_header_id FROM ozf_offer_adjustment_tiers WHERE offer_adjustment_id = p_offer_adjustment_id and rownum < 2)
  and rownum < 2)
;


  CURSOR c_pricing_attr(l_list_header_id NUMBER, l_list_line_id NUMBER) IS
  SELECT pricing_attribute_id
        ,product_attribute_context
        ,product_attribute
        ,product_attr_value
        ,product_uom_code
        ,pricing_attribute_context
        ,pricing_attribute
        ,pricing_attr_value_from
        ,pricing_attr_value_to
        ,excluder_flag
    FROM qp_pricing_attributes
   WHERE list_header_id = l_list_header_id
     AND list_line_id = l_list_line_id;

  CURSOR c_qualifier(l_list_header_id NUMBER, l_list_line_id NUMBER) IS
  SELECT qualifier_id
        ,qualifier_attr_value
        ,qualifier_attr_value_to
    FROM qp_qualifiers
   WHERE list_header_id = l_list_header_id
     AND list_line_id = l_list_line_id;

  CURSOR c_adj_tiers IS
  SELECT volume_offer_tiers_id
        ,modified_discount
    FROM ozf_offer_adjustment_tiers
   WHERE offer_adjustment_id = p_offer_adjustment_id;

  CURSOR c_tier_detail(l_tier_id NUMBER) IS
  SELECT *
    FROM ozf_volume_offer_tiers
   WHERE volume_offer_tiers_id = l_tier_id;
  l_tier_detail c_tier_detail%ROWTYPE;

  l_vol_offr_tier_rec ozf_vol_offr_pvt.vol_offr_tier_rec_type;
  l_index    NUMBER := 0;
  l_dummy    NUMBER;
  l_adj_lines c_adj_lines%rowtype;

BEGIN
      x_return_status := Fnd_Api.g_ret_sts_success;
---------Update Volume Offer tiers ----------------------------
      FOR l_adj_tier IN c_adj_tiers LOOP
      OPEN c_tier_detail(l_adj_tier.volume_offer_tiers_id);
          FETCH c_tier_detail INTO l_tier_detail;
      CLOSE c_tier_detail;

      l_vol_offr_tier_rec.volume_offer_tiers_id := l_tier_detail.volume_offer_tiers_id;
      l_vol_offr_tier_rec.qp_list_header_id := l_tier_detail.qp_list_header_id;
      l_vol_offr_tier_rec.discount_type_code := l_tier_detail.discount_type_code;
      l_vol_offr_tier_rec.break_type_code := l_tier_detail.break_type_code;
      l_vol_offr_tier_rec.tier_value_from := l_tier_detail.tier_value_from;
      l_vol_offr_tier_rec.tier_value_to := l_tier_detail.tier_value_to;
      l_vol_offr_tier_rec.volume_type := l_tier_detail.volume_type;
      l_vol_offr_tier_rec.active := l_tier_detail.active;
      l_vol_offr_tier_rec.uom_code := l_tier_detail.uom_code;
      l_vol_offr_tier_rec.object_version_number := l_tier_detail.object_version_number;
      l_vol_offr_tier_rec.discount := l_adj_tier.modified_discount;

      OZF_Vol_Offr_PVT.Update_Vol_Offr(p_api_version
                                      ,p_init_msg_list
                                      ,p_commit
                                      ,FND_API.G_VALID_LEVEL_FULL -- validation level
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data
                                      ,l_vol_offr_tier_rec
                                      ,l_dummy);
    END LOOP;
-------Done updating Volume Offer Tiers-----------------
    open c_adj_lines;
    fetch c_adj_lines into l_adj_lines;
    close c_adj_lines;

    l_modifier_list_rec.qp_list_header_id := l_adj_lines.qp_list_header_id;
    l_offer_type := 'VOLUME_OFFER';
      -- initialize
      l_qp_line_detail := NULL;
      FOR l_qp_line_detail in c_qp_line_detail(l_adj_lines.qp_list_header_id) LOOP
      l_index := l_index + 1;
      l_modifier_line_tbl(l_index).operation := 'UPDATE';
      l_modifier_line_tbl(l_index).list_line_id := l_qp_line_detail.list_line_id;
      l_modifier_line_tbl(l_index).list_header_id := l_qp_line_detail.list_header_id;
      l_modifier_line_tbl(l_index).list_line_type_code :=  l_qp_line_detail.list_line_type_code;
      l_modifier_line_tbl(l_index).start_date_active := l_qp_line_detail.start_date_active;
      l_modifier_line_tbl(l_index).end_date_active := l_qp_line_detail.end_date_active;
      IF l_qp_line_detail.end_date_active <> FND_API.G_MISS_DATE
      AND l_qp_line_detail.end_date_active IS NOT NULL
      THEN
        l_modifier_line_tbl(l_index).inactive_flag := 'N';
      ELSE
        l_modifier_line_tbl(l_index).inactive_flag := 'Y';
      END IF;
      -- end benefit quantity

      -- get pricing attribute from qp_pricing_attributes
      OPEN c_pricing_attr(l_qp_line_detail.list_header_id, l_qp_line_detail.list_line_id);
      FETCH c_pricing_attr INTO l_modifier_line_tbl(l_index).pricing_attribute_id
                               ,l_modifier_line_tbl(l_index).product_attribute_context
                               ,l_modifier_line_tbl(l_index).product_attr
                               ,l_modifier_line_tbl(l_index).product_attr_val
                               ,l_modifier_line_tbl(l_index).product_uom_code
                               ,l_modifier_line_tbl(l_index).pricing_attribute_context
                               ,l_modifier_line_tbl(l_index).pricing_attr
                               ,l_modifier_line_tbl(l_index).pricing_attr_value_from
                               ,l_modifier_line_tbl(l_index).pricing_attr_value_to
                               ,l_modifier_line_tbl(l_index).excluder_flag;
      CLOSE c_pricing_attr;

      OPEN c_qualifier(l_qp_line_detail.list_header_id, l_qp_line_detail.list_line_id);
      FETCH c_qualifier INTO l_modifier_line_tbl(l_index).qualifier_id
                            ,l_modifier_line_tbl(l_index).order_value_from
                            ,l_modifier_line_tbl(l_index).order_value_to;
      CLOSE c_qualifier;

      l_modifier_line_tbl(l_index).operand := l_adj_lines.modified_discount;
      l_modifier_line_tbl(l_index).arithmetic_operator := l_qp_line_detail.arithmetic_operator;

      END LOOP;
    -- calling offer API to update lines
     ozf_offer_pvt.process_modifiers ( p_init_msg_list
                                      ,p_api_version
                                      ,p_commit
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data
                                      ,l_offer_type
                                      ,l_modifier_list_rec
                                      ,l_modifier_line_tbl
                                      ,l_qp_list_header_id
                                      ,l_error_location
                                    );
----------------------------------------------------------------------------------------------
END update_volume_offer_discounts;


/*
Done with normal cases without exclusions and apply discounts = n
currently only inserts without checking for duplicates, so depends on judicious calling of the api
*/
PROCEDURE process_vo_adj_products
(
   p_init_msg_list         IN   VARCHAR2 := FND_API.g_false
  , p_api_version           IN   NUMBER
  , p_commit                IN   VARCHAR2 := FND_API.g_false
  , x_return_status         OUT NOCOPY  VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
  , p_offer_adjustment_id   IN   NUMBER
)
IS


l_vo_prod_rec OZF_Volume_Offer_disc_PVT.vo_prod_rec_type;

l_off_discount_product_id NUMBER;
l_api_name CONSTANT VARCHAR2(30) := 'process_vo_adj_products';
l_api_version_number CONSTANT NUMBER := 1.0;


l_reln_rec OZF_OFFER_PVT.ozf_qp_reln_rec_type ;

BEGIN
-- initialize
SAVEPOINT process_vo_adj_products;
IF NOT FND_API.COMPATIBLE_API_CALL
(
p_api_version
, l_api_version_number
, l_api_name
, g_pkg_name
)
THEN
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
x_return_status := FND_API.G_RET_STS_SUCCESS;

ozf_utility_pvt.debug_message('Private API:'|| l_api_name || ' Start');
-- create new discont products
DECLARE
CURSOR C_ADJ_PROD(p_adjustment_id NUMBER) IS
SELECT decode(apply_discount_flag,'N',decode(include_volume_flag,'N','Y','N'),'N') excluder_flag
, offer_discount_line_id
, offer_id
, product_context
, product_attribute
, product_attr_value
, apply_discount_flag
, include_volume_flag
FROM ozf_offer_adjustment_products a , ozf_offer_adjustments_b b, ozf_offers c
WHERE a.offer_adjustment_id = b.offer_adjustment_id
AND b.list_header_id = c.qp_list_header_id
AND a.offer_adjustment_id = p_adjustment_id;

BEGIN
FOR l_adj_prod in c_adj_prod(p_offer_adjustment_id) LOOP
l_vo_prod_rec.excluder_flag := l_adj_prod.excluder_flag ;
l_vo_prod_rec.offer_discount_line_id := l_adj_prod.offer_discount_line_id;
l_vo_prod_rec.offer_id := l_adj_prod.offer_id;
l_vo_prod_rec.product_context := l_adj_prod.product_context;
l_vo_prod_rec.product_attribute := l_adj_prod.product_attribute;
l_vo_prod_rec.product_attr_value := l_adj_prod.product_attr_value;
l_vo_prod_rec.apply_discount_flag := l_adj_prod.apply_discount_flag;
l_vo_prod_rec.include_volume_flag := l_adj_prod.include_volume_flag;
ozf_utility_pvt.debug_message('Excluder Flag :'||l_vo_prod_rec.excluder_flag);
ozf_utility_pvt.debug_message('Offer Discount Line Id :'||l_vo_prod_rec.offer_discount_line_id);
ozf_utility_pvt.debug_message('Offer Id :'||l_vo_prod_rec.offer_id);
ozf_utility_pvt.debug_message('Product Context :'||l_vo_prod_rec.product_context);
ozf_utility_pvt.debug_message('product_attribute :'||l_vo_prod_rec.product_attribute);
ozf_utility_pvt.debug_message('Product Attr val :'||l_vo_prod_rec.product_attr_value);
ozf_utility_pvt.debug_message('Apply discount Flag :'||l_vo_prod_rec.apply_discount_flag);
ozf_utility_pvt.debug_message('Include Volume :'||l_vo_prod_rec.include_volume_flag);
OZF_Volume_Offer_disc_PVT.Create_vo_product(
    p_api_version_number            => 1.0
    , p_init_msg_list               => FND_API.G_FALSE
    , p_commit                      => FND_API.G_FALSE
    , p_validation_level            => FND_API.G_VALID_LEVEL_FULL

    , x_return_status               => x_return_status
    , x_msg_count                   => x_msg_count
    , x_msg_data                    => x_msg_data

    , p_vo_prod_rec                 => l_vo_prod_rec
    , x_off_discount_product_id     => l_off_discount_product_id
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

END LOOP;
END;

IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

ozf_utility_pvt.debug_message('Return status 1 is '||x_return_status);
-- loop thru new products and create new list lines and pricing attributes
declare
CURSOR c_adj_prod_disc(p_adjustment_id NUMBER)
IS
SELECT a.product_context
, a.product_attribute
, a.product_attr_value
, c.uom_code
, c.volume_type
, d.qp_list_header_id list_header_id
, d.volume_offer_type
, d.modifier_level_code
, b.offer_discount_line_id
, c.discount_type
, e.effective_date
, a.apply_discount_flag
, a.include_volume_flag
FROM ozf_offer_adjustment_products a, ozf_offer_discount_products b , ozf_offer_discount_lines c , ozf_offers d , ozf_offer_adjustments_b e
WHERE a.offer_discount_line_id = c.offer_discount_line_id
AND b.offer_discount_line_id = c.offer_discount_line_id
AND a.product_context = b.product_context
AND a.product_attribute = b.product_attribute
AND a.product_attr_value = b.product_attr_value
AND c.offer_id = d.offer_id
AND e.offer_adjustment_id = a.offer_adjustment_id
--AND b.offer_discount_line_id = p_offer_discount_line_id
AND a.offer_adjustment_id = p_offer_adjustment_id;

CURSOR c_adj_prod_dis(p_offer_discount_line_id number) IS
SELECT volume_from, volume_to, discount_type, discount
FROM ozf_offer_discount_lines where parent_discount_line_id = p_offer_discount_line_id;

i NUMBER:= 0;
k NUMBER := 0;
 l_modifiers_tbl          Qp_Modifiers_Pub.modifiers_tbl_type;
 l_pricing_attr_tbl       Qp_Modifiers_Pub.pricing_attr_tbl_type;
 v_modifier_list_rec      qp_modifiers_pub.modifier_list_rec_type;
 v_modifier_list_val_rec  qp_modifiers_pub.modifier_list_val_rec_type;
 v_modifiers_tbl          qp_modifiers_pub.modifiers_tbl_type;
 v_modifiers_val_tbl      qp_modifiers_pub.modifiers_val_tbl_type;
 v_qualifiers_tbl         qp_qualifier_rules_pub.qualifiers_tbl_type;
 v_qualifiers_val_tbl     qp_qualifier_rules_pub.qualifiers_val_tbl_type;
 v_pricing_attr_tbl       qp_modifiers_pub.pricing_attr_tbl_type;
 v_pricing_attr_val_tbl   qp_modifiers_pub.pricing_attr_val_tbl_type;
 l_control_rec            qp_globals.control_rec_type;

BEGIN
for l_adj_prod_disc IN c_adj_prod_disc(p_offer_adjustment_id) LOOP
i := k;
i := i + 1;
ozf_utility_pvt.debug_message('i:'||i);
        l_pricing_attr_tbl(i).product_attribute_context := l_adj_prod_disc.product_context;
        l_pricing_attr_tbl(i).product_attribute         := l_adj_prod_disc.product_attribute;
        l_pricing_attr_tbl(i).product_attr_value        := l_adj_prod_disc.product_attr_value;
        l_pricing_attr_tbl(i).product_uom_code          := l_adj_prod_disc.uom_code;

        l_pricing_attr_tbl(i).pricing_attribute_context := 'VOLUME';
        l_pricing_attr_tbl(i).pricing_attribute         := l_adj_prod_disc.volume_type;
        l_pricing_attr_tbl(i).comparison_operator_code   := 'BETWEEN';

        l_pricing_attr_tbl(i).modifiers_index            := i;
        l_pricing_attr_tbl(i).operation                  := 'CREATE';

    l_modifiers_tbl(i).operation := 'CREATE';
    l_modifiers_tbl(i).list_header_id := l_adj_prod_disc.list_header_id;

    IF l_adj_prod_disc.volume_offer_type = 'ACCRUAL' THEN
        l_modifiers_tbl(i).accrual_flag := 'Y';
    ELSE
        l_modifiers_tbl(i).accrual_flag := 'N';
    END IF;

    l_modifiers_tbl(i).proration_type_code      := 'N';
    l_modifiers_tbl(i).product_precedence       := 10;

    IF l_adj_prod_disc.modifier_level_code <> 'ORDER' THEN
        l_modifiers_tbl(i).pricing_group_sequence   := 1;
        IF l_adj_prod_disc.modifier_level_code = 'LINEGROUP' THEN
              l_modifiers_tbl(i).pricing_phase_id := 3;
        ELSIF l_adj_prod_disc.modifier_level_code = 'LINE' THEN
              l_modifiers_tbl(i).pricing_phase_id := 2;
        ELSE
              l_modifiers_tbl(i).pricing_phase_id := 3;
        END IF;
    ELSE
              l_modifiers_tbl(i).pricing_phase_id := 4;
    END IF;

    l_modifiers_tbl(i).print_on_invoice_flag    := 'Y';
    l_modifiers_tbl(i).modifier_level_code      := l_adj_prod_disc.modifier_level_code;
    l_modifiers_tbl(i).automatic_flag := 'Y';
    l_modifiers_tbl(i).price_break_type_code := 'RANGE';--l_products.volume_break_type;
    l_modifiers_tbl(i).start_date_active := l_adj_prod_disc.effective_date;

    IF l_adj_prod_disc.apply_discount_flag = 'N' AND l_adj_prod_disc.include_volume_flag = 'Y' THEN
    ozf_utility_pvt.debug_message('Apply discount = n3-range');
        l_pricing_attr_tbl(i).pricing_attr_value_from   :=  1;
        l_pricing_attr_tbl(i).pricing_attr_value_to   :=  999999999;
        l_modifiers_tbl(i).list_line_type_code := 'DIS';
        l_modifiers_tbl(i).price_break_type_code := 'POINT'; -- RANGE GIVES ERROR
        l_modifiers_tbl(i).arithmetic_operator := 'AMT';
        l_modifiers_tbl(i).operand             := 0;
        k := k+1;
    ELSE
    l_modifiers_tbl(i).list_line_type_code := 'PBH';

--    l_modifiers_tbl(i).start_date_active := l_adj_prod_disc.effective_date;
ozf_utility_pvt.debug_message('l_adj_prod_disc.offer_discount_line_id:'||l_adj_prod_disc.offer_discount_line_id);
k := i;
    FOR l_adj_prod_dis IN c_adj_prod_dis(l_adj_prod_disc.offer_discount_line_id) LOOP
    k := k + 1;
    ozf_utility_pvt.debug_message('k:'||k);
        l_modifiers_tbl(k).operation := 'CREATE';
        l_modifiers_tbl(k).list_header_id := l_adj_prod_disc.list_header_id;
        IF l_adj_prod_disc.volume_offer_type = 'ACCRUAL' THEN
            l_modifiers_tbl(k).accrual_flag := 'Y';
        END IF;
        l_modifiers_tbl(k).list_line_type_code := 'DIS';
        l_modifiers_tbl(k).proration_type_code      := 'N';
        l_modifiers_tbl(k).product_precedence       := 10;
        IF l_adj_prod_disc.modifier_level_code <> 'ORDER' THEN
            l_modifiers_tbl(k).pricing_group_sequence   := 1;
        END IF;
        l_modifiers_tbl(k).print_on_invoice_flag    := 'Y';
    IF l_adj_prod_disc.modifier_level_code <> 'ORDER' THEN
        l_modifiers_tbl(k).pricing_group_sequence   := 1;
        IF l_adj_prod_disc.modifier_level_code = 'LINEGROUP' THEN
              l_modifiers_tbl(k).pricing_phase_id := 3;
        ELSIF l_adj_prod_disc.modifier_level_code = 'LINE' THEN
              l_modifiers_tbl(k).pricing_phase_id := 2;
        ELSE
              l_modifiers_tbl(k).pricing_phase_id := 3;
        END IF;
    ELSE
              l_modifiers_tbl(k).pricing_phase_id := 4;
    END IF;


        l_modifiers_tbl(k).modifier_level_code      := l_adj_prod_disc.modifier_level_code;
        l_modifiers_tbl(k).automatic_flag := 'Y';
        l_modifiers_tbl(k).price_break_type_code := 'POINT';
        ozf_utility_pvt.debug_message('l_adj_prod_dis.discount_type:'||l_adj_prod_disc.discount_type);
        l_modifiers_tbl(k).arithmetic_operator := l_adj_prod_disc.discount_type;
        l_modifiers_tbl(k).operand             := l_adj_prod_dis.discount;
--        l_modifiers_tbl(k).generate_using_formula_id := l_disc_struct_dis.formula_id;
--        l_modifiers_tbl(k).modifiers_index               := k;
        l_modifiers_tbl(k).rltd_modifier_grp_type        := 'PRICE BREAK';
        l_modifiers_tbl(k).rltd_modifier_grp_no          := 1;
        l_modifiers_tbl(k).modifier_parent_index         := i;
        ozf_utility_pvt.debug_message('Parent index is :'|| i || ' for : '||k);

    -- process products for discounts
        l_pricing_attr_tbl(k) := l_pricing_attr_tbl(i);
        l_pricing_attr_tbl(k).pricing_attr_value_from   :=  l_adj_prod_dis.volume_from;
        l_pricing_attr_tbl(k).pricing_attr_value_to   :=  l_adj_prod_dis.volume_to;
        l_pricing_attr_tbl(k).modifiers_index            := k;
END LOOP;
END IF;
END LOOP;

ozf_utility_pvt.debug_message('l_pricing_attr_tbl'||l_pricing_attr_tbl.COUNT);
   QP_Modifiers_PUB.process_modifiers(
      p_api_version_number     => 1.0,
      p_init_msg_list          => FND_API.G_FALSE,
      p_return_values          => FND_API.G_FALSE,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data,
      p_modifiers_tbl          => l_modifiers_tbl,
      p_pricing_attr_tbl       => l_pricing_attr_tbl,
      x_modifier_list_rec      => v_modifier_list_rec,
      x_modifier_list_val_rec  => v_modifier_list_val_rec,
      x_modifiers_tbl          => v_modifiers_tbl,
      x_modifiers_val_tbl      => v_modifiers_val_tbl,
      x_qualifiers_tbl         => v_qualifiers_tbl,
      x_qualifiers_val_tbl     => v_qualifiers_val_tbl,
      x_pricing_attr_tbl       => v_pricing_attr_tbl,
      x_pricing_attr_val_tbl   => v_pricing_attr_val_tbl
     );
ozf_utility_pvt.debug_message('Return status 2 is '||x_return_status);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
ozf_utility_pvt.debug_message('Return status 3 is '||x_return_status);
END;

-- loop thru new products and create new discount and product relations

DECLARE
/*CURSOR c_disc_reln(p_offer_adjustment_id NUMBER) IS
SELECT distinct b.off_discount_product_id , d.pricing_attribute_id
FROM ozf_offer_adjustment_products a, ozf_offer_discount_products b , ozf_offer_adjustments_b c, qp_pricing_attributes d
WHERE a.offer_discount_line_id = b.offer_discount_line_id
AND a.product_attribute = b.product_attribute
AND a.product_attr_value = b.product_attr_value
AND a.excluder_flag = b.excluder_flag
AND a.offer_adjustment_id = c.offer_adjustment_id
AND c.list_header_id = d.list_header_id
AND a.product_attribute = d.product_attribute
AND a.product_attr_value = d.product_attr_value
AND a.offer_adjustment_id = p_offer_adjustment_id;
CURSOR c_prod_reln(p_offer_adjustment_id NUMBER) IS
SELECT b.offer_discount_line_id , d.list_line_id
FROM ozf_offer_adjustment_products a, ozf_offer_discount_lines b, ozf_offer_adjustments_b c, qp_list_lines d
WHERE a.offer_discount_line_id = DECODE(b.tier_type,'PBH',offer_discount_line_id,parent_discount_line_id)
AND b.offer_adjustment_id = a.offer_adjustment_id
AND a.offer_adjustment_id = p_offer_adjustment_id
AND c.list_header_id = d.list_header_id
AND b.tier_type = d.list_line_type_code
AND nvl(b.discount,-1) = nvl(d.operand,-1);
--AND nvl(b.discount_type,'-1') = nvl(d.arithmetic_operator)
*/
CURSOR c_create_reln(p_offer_adjustment_id NUMBER) IS
SELECT c.offer_discount_line_id, b.off_discount_product_id , d.list_line_id , d.pricing_attribute_id
FROM ozf_offer_adjustment_products a, ozf_offer_discount_products b,  ozf_offer_discount_lines c  , ozf_offer_adjustments_b e ,qp_pricing_attributes d
WHERE a.offer_discount_line_id = b.offer_discount_line_id
AND a.product_attr_value = b.product_attr_value
AND a.offer_adjustment_id = p_offer_adjustment_id
AND b.offer_discount_line_id = decode(c.tier_type , 'DIS',c.parent_discount_line_id, c.offer_discount_line_id)
AND e.offer_adjustment_id = a.offer_adjustment_id
AND d.list_header_id = e.list_header_id
AND d.product_attr_value = a.product_attr_value
AND to_number(nvl(d.pricing_attr_value_from,0)) = nvl(c.volume_from,0)
AND to_number(nvl(d.pricing_attr_value_to,0)) = nvl(c.volume_to,0)
AND a.apply_discount_flag = 'Y';

BEGIN
ozf_utility_pvt.debug_message('apply Discounts = Y');
FOR l_create_reln IN c_create_reln(p_offer_adjustment_id ) LOOP
l_reln_rec.pricing_attribute_id := l_create_reln.pricing_attribute_id;
l_reln_rec.qp_list_line_id      := l_create_reln.list_line_id;
l_reln_rec.offer_discount_line_id := l_create_reln.offer_discount_line_id;
l_reln_rec.off_discount_product_id := l_create_reln.off_discount_product_id;
ozf_utility_pvt.debug_message('Prc attr : '||l_reln_rec.pricing_attribute_id);
ozf_utility_pvt.debug_message('ListLIneId :'||l_reln_rec.qp_list_line_id);
ozf_utility_pvt.debug_message('Discount line id :'||l_reln_rec.offer_discount_line_id);
ozf_utility_pvt.debug_message('Prod id :'||l_reln_rec.off_discount_product_id);
-- mgudivak Bug 5400931
-- Commenting the call since the following procedure has been
-- obsoleted in ozfvofrs.pls 120.12
/*
OZF_OFFER_PVT.relate_qp_ozf_lines
(
    p_api_version_number         => p_api_version,
    p_init_msg_list              => p_init_msg_list,
    p_commit                     => p_commit,
    p_validation_level           => FND_API.G_VALID_LEVEL_FULL,

    x_return_status              => x_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data,
    p_ozf_qp_reln_rec            => l_reln_rec
);
*/
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

END LOOP;

END;

DECLARE
CURSOR c_dis_products(p_offer_adjustment_id NUMBER) IS
SELECT c.off_discount_product_id , d.pricing_attribute_id
FROM
ozf_offer_adjustment_products a, ozf_offer_adjustments_b b , ozf_offer_discount_products c, qp_pricing_attributes d
WHERE a.offer_adjustment_id = b.offer_adjustment_id
AND a.offer_adjustment_id = p_offer_adjustment_id
AND a.offer_discount_line_id = c.offer_discount_line_id
AND a.product_attribute = c.product_attribute
AND a.product_attr_value = c.product_attr_value
AND b.list_header_id = d.list_header_id
AND c.product_attribute = d.product_attribute
AND c.product_attr_value = d.product_attr_value
AND a.apply_discount_flag = 'N';

l_prod_rec OZF_QP_PRODUCTS_PVT.qp_product_rec_type;

BEGIN
ozf_utility_pvt.debug_message('apply Discounts = n');
FOR l_dis_products in c_dis_products(p_offer_adjustment_id) LOOP
l_reln_rec := null;
l_reln_rec.pricing_attribute_id := l_dis_products.pricing_attribute_id;
l_reln_rec.off_discount_product_id := l_dis_products.off_discount_product_id;
ozf_utility_pvt.debug_message('Prc attr : '||l_reln_rec.pricing_attribute_id);
ozf_utility_pvt.debug_message('ListLIneId :'||l_reln_rec.qp_list_line_id);
ozf_utility_pvt.debug_message('Discount line id :'||l_reln_rec.offer_discount_line_id);
ozf_utility_pvt.debug_message('Prod id :'||l_reln_rec.off_discount_product_id);
-- mgudivak - Bug 5400931
-- Commenting the call since the following procedure has been
-- obsoleted in ozfvofrs.pls 120.12
/*
OZF_OFFER_PVT.relate_qp_ozf_lines
(
    p_api_version_number         => p_api_version,
    p_init_msg_list              => p_init_msg_list,
    p_commit                     => p_commit,
    p_validation_level           => FND_API.G_VALID_LEVEL_FULL,

    x_return_status              => x_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data,
    p_ozf_qp_reln_rec            => l_reln_rec
);
*/
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
END LOOP;
end;

--exception
null;
ozf_utility_pvt.debug_message('Private API:'|| l_api_name || ' Start');

EXCEPTION
WHEN  FND_API.G_EXC_ERROR THEN
rollback to process_vo_adj_products;
x_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
WHEN  FND_API.G_EXC_UNEXPECTED_ERROR THEN
ROLLBACK TO process_vo_adj_products;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
WHEN OTHERS THEN
ROLLBACK TO process_vo_adj_products;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
END process_vo_adj_products;


/**
THis procedure has been trimmed down in its approach due to the following issues.
Ideally the best way to adjust tiers would be to end date qp_list_lines with the effective date of the offer adjustment
and create new qp_list_lines with new discounts and effective date for new tiers.
Since qp overlapping logic does not account for the end_Date of a list line, this approach does not work.
Second approach is to end date the whole pbh qp_list_line and recreate new pbh qp_list_line.
But this is a lot of work and at this stage this will be hard to pull up since it is a sensitive code and mistake here will
mess up the whole volume offer.
The approach taken here is just update the existing lines.

*/
PROCEDURE process_vo_adj_tiers
(
   p_init_msg_list         IN   VARCHAR2 := FND_API.g_false
  ,p_api_version           IN   NUMBER
  ,p_commit                IN   VARCHAR2 := FND_API.g_false
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offer_adjustment_id   IN   NUMBER

)
IS
i NUMBER  := 1;
j NUMBER;
l_qp_list_header_id NUMBER;
l_error_location NUMBER;
l_modifier_line_tbl OZF_OFFER_PVT.MODIFIER_LINE_TBL_TYPE;
l_modifier_line_create_tbl OZF_OFFER_PVT.MODIFIER_LINE_TBL_TYPE;
l_modifier_list_rec OZF_OFFER_PVT.MODIFIER_LIST_REC_TYPE;
l_offer_type VARCHAR2(30) := 'VOLUME_OFFER';


l_modifiers_tbl         qp_modifiers_pub.modifiers_tbl_type;
l_pricing_attr_tbl       qp_modifiers_pub.pricing_attr_tbl_type;


L_API_VERSION_NUMBER CONSTANT NUMBER := 1.0;
L_API_NAME CONSTANT VARCHAR2(30) := 'process_vo_adj_tiers';

BEGIN
SAVEPOINT process_vo_adj_tiers;
/*
IF NOT FND_API.COMPATIBLE_API_CALL(
                                    l_api_version_number
                                    ,p_api_version
                                    ,l_api_name
                                    ,G_PKG_NAME
                                )
 THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

IF FND_API.TO_BOOLEAN(p_init_msg_list) THEN
FND_MSG_PUB.INITIALIZE;
END IF;*/
x_return_status := FND_API.G_RET_STS_SUCCESS;
ozf_utility_pvt.debug_message('Private API:'|| l_api_name || ' Start');
-- inactivate existing qp_list_lines
DECLARE
CURSOR c_qp_list_lines(p_adjustment_id NUMBER)
IS
SELECT  c.list_line_id , c.list_header_id , d.effective_date , a.modified_discount, c.arithmetic_operator
FROM ozf_offer_adjustment_tiers a, ozf_qp_discounts b ,   qp_list_Lines c, ozf_offer_adjustments_b d
WHERE a.offer_discount_line_id = b.offer_discount_line_id
AND b.list_line_id = c.list_line_id
AND a.offer_adjustment_id = d.offer_adjustment_id
AND a.offer_adjustment_id = p_adjustment_id;

BEGIN
for l_qp_list_lines in c_qp_list_lines(p_offer_adjustment_id) LOOP
i := i+1;
l_modifier_list_rec.offer_type := 'VOLUME_OFFER';
l_modifier_list_rec.qp_list_header_id := l_qp_list_lines.list_header_id;

l_modifier_line_tbl(i).list_line_id     := l_qp_list_lines.list_line_id;
l_modifier_line_tbl(i).list_header_id   :=  l_qp_list_lines.list_header_id;
--l_modifier_line_tbl(i).end_date_active  := l_qp_list_lines.effective_date;
l_modifier_line_tbl(i).operand          := l_qp_list_lines.modified_discount;
l_modifier_line_tbl(i).arithmetic_operator := l_qp_list_lines.arithmetic_operator;

l_modifier_line_tbl(i).operation        := 'UPDATE';
ozf_utility_pvt.debug_message('List Line Id is :'||l_qp_list_lines.list_line_id || ' : '||l_qp_list_lines.list_header_id || ' : '||l_qp_list_lines.modified_discount);
ozf_utility_pvt.debug_message('List Line Id is1 :'||l_modifier_line_tbl(i).list_line_id || ' : '||l_modifier_line_tbl(i).list_header_id || ' : '||l_modifier_line_tbl(i).operand);

END LOOP;
OZF_OFFER_PVT.process_modifiers
(
   p_init_msg_list         => FND_API.G_FALSE
  , p_api_version           => 1.0
  , p_commit                => FND_API.G_FALSE
  , x_return_status         => x_return_status
  , x_msg_count             => x_msg_count
  , x_msg_data              => x_msg_data
  , p_offer_type            => l_offer_type
  , p_modifier_list_rec     => l_modifier_list_rec
  , p_modifier_line_tbl     => l_modifier_line_tbl
  , x_qp_list_header_id     => l_qp_list_header_id
  , x_error_location        => l_error_location
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
END;
-- update existing tiers
DECLARE
CURSOR c_discounts(p_offer_adjustment_id NUMBER) IS
SELECT
a.modified_discount, a.offer_discount_line_id , b.object_version_number , b.offer_id
FROM ozf_offer_adjustment_tiers a, ozf_offer_discount_lines b
WHERE a.offer_adjustment_id = p_offer_adjustment_id
AND a.offer_discount_line_id = b.offer_discount_line_id;
l_vo_disc_rec OZF_Volume_Offer_disc_PVT.vo_disc_rec_type;
BEGIN
FOR l_discounts in c_discounts(p_offer_adjustment_id) LOOP
l_vo_disc_rec.offer_discount_line_id := l_discounts.offer_discount_line_id;
l_vo_disc_rec.discount := l_discounts.modified_discount;
l_vo_disc_rec.object_version_number := l_discounts.object_version_number;
l_vo_disc_rec.offer_id := l_discounts.offer_id;
OZF_Volume_Offer_disc_PVT.Update_vo_discount(
    p_api_version_number         => 1.0
    ,p_init_msg_list              => FND_API.G_FALSE
    ,p_commit                     => FND_API.G_FALSE
    ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL

    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data

    , p_vo_disc_rec                => l_vo_disc_rec
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
END LOOP;
END;
/*
-- create new discount tiers
DECLARE
CURSOR c_create_qp_list_lines(p_offer_adjustment_id NUMBER)
IS
SELECT  d.from_rltd_modifier_id list_line_id
, c.list_header_id list_header_id
, f.price_break_type_code price_break_type_code
, c.pricing_attr_value_from pricing_attr_value_from
, c.pricing_attr_value_to pricing_attr_value_to
, a.modified_discount operand
, f.arithmetic_operator arithmetic_operator
, c.pricing_attribute pricing_attribute
, e.effective_date start_date_active
FROM ozf_offer_adjustment_tiers a, ozf_qp_discounts b, qp_pricing_attributes c, qp_rltd_modifiers d
, ozf_offer_adjustments_b e, qp_list_lines f
WHERE a.offer_discount_line_id = b.offer_discount_line_id
AND b.list_line_id = c.list_line_id
AND c.list_line_id = d.to_rltd_modifier_id
AND a.offer_adjustment_id = e.offer_adjustment_id
AND b.list_line_id        = f.list_line_id
AND a.offer_adjustment_id = p_offer_adjustment_id;
BEGIN
i := 1;
FOR l_create_qp_list_lines IN c_create_qp_list_lines(p_offer_adjustment_id) LOOP
    l_modifier_line_create_tbl(i).list_header_id                    := l_create_qp_list_lines.list_header_id;
    l_modifier_line_create_tbl(i).list_line_id                      := l_create_qp_list_lines.list_line_id;
    l_modifier_line_create_tbl(i).price_break_type_code             := l_create_qp_list_lines.price_break_type_code;
    l_modifier_line_create_tbl(i).pricing_attr_value_from           := l_create_qp_list_lines.pricing_attr_value_from;
    l_modifier_line_create_tbl(i).pricing_attr_value_to             := l_create_qp_list_lines.pricing_attr_value_to;
    l_modifier_line_create_tbl(i).operand                           := l_create_qp_list_lines.operand;
    l_modifier_line_create_tbl(i).arithmetic_operator               := l_create_qp_list_lines.arithmetic_operator;
    l_modifier_line_create_tbl(i).pricing_attribute_id              := FND_API.G_MISS_NUM;
    l_modifier_line_create_tbl(i).pricing_attr                      := l_create_qp_list_lines.pricing_attribute;
    l_modifier_line_create_tbl(i).start_date_active                 := l_create_qp_list_lines.start_date_active;
    l_modifier_line_create_tbl(i).operation                         := 'CREATE';
i := i + 1;
END LOOP;
dbms_output.put_line('Size is '||l_modifier_line_create_tbl.count);
OZF_OFFER_PVT.create_offer_tiers
(
   p_init_msg_list         => p_init_msg_list
  ,p_api_version           => p_api_version
  ,p_commit                => p_commit
  ,x_return_status         => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_modifier_line_tbl     => l_modifier_line_create_tbl
  ,x_error_location        => l_error_location
  ,x_modifiers_tbl         => l_modifiers_tbl
  ,x_pricing_attr_tbl      => l_pricing_attr_tbl
);
 IF x_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
 ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;
 END;
 */
 /*
-- create new relationships
DECLARE
CURSOR c_create_reln(p_offer_adjustment_id NUMBER)
IS
SELECT a.offer_discount_line_id , f.off_discount_product_id , e.pricing_attribute_id , d.list_line_id
FROM ozf_offer_adjustment_tiers a, ozf_offer_adjustments_b b , ozf_offer_discount_lines c , qp_list_lines d , qp_pricing_attributes e , ozf_offer_discount_products f
WHERE a.offer_adjustment_id = b.offer_adjustment_id
AND c.offer_discount_line_id = a.offer_discount_line_id
AND b.list_header_id = d.list_header_id
AND d.list_line_id = e.list_line_id
AND to_number(e.pricing_attr_value_from) = c.volume_from -- takes care of no apply discount products
AND to_number(e.pricing_attr_value_to) = c.volume_to
AND d.operand = a.modified_discount --c.discount
AND f.offer_discount_line_id = c.parent_discount_line_id
AND f.product_attribute = e.product_attribute
and f.product_attr_value = e.product_attr_value
AND d.start_date_active >= b.effective_date
AND a.offer_adjustment_id = p_offer_adjustment_id;
l_reln_rec OZF_OFFER_PVT.ozf_qp_reln_rec_type;
BEGIN
FOR l_create_reln in c_create_reln(p_offer_adjustment_id ) LOOP
l_reln_rec.pricing_attribute_id := l_create_reln.pricing_attribute_id;
l_reln_rec.qp_list_line_id      := l_create_reln.list_line_id;
l_reln_rec.offer_discount_line_id := l_create_reln.offer_discount_line_id;
l_reln_rec.off_discount_product_id := l_create_reln.off_discount_product_id;
dbms_output.put_line('Prc attr : '||l_reln_rec.pricing_attribute_id);
dbms_output.put_line('ListLIneId :'||l_reln_rec.qp_list_line_id);
dbms_output.put_line('Discount line id :'||l_reln_rec.offer_discount_line_id);
dbms_output.put_line('Prod id :'||l_reln_rec.off_discount_product_id);
OZF_OFFER_PVT.relate_qp_ozf_lines
(
    p_api_version_number         => p_api_version,
    p_init_msg_list              => p_init_msg_list,
    p_commit                     => p_commit,
    p_validation_level           => FND_API.G_VALID_LEVEL_FULL,

    x_return_status              => x_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data,
    p_ozf_qp_reln_rec            => l_reln_rec
);
END LOOP;
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
end;
*/
ozf_utility_pvt.debug_message('Private API:'|| l_api_name || ' End');

IF FND_API.to_boolean(p_commit) THEN
    COMMIT WORK;
END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
ROLLBACK TO process_vo_adj_tiers;
x_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
ROLLBACK TO process_vo_adj_tiers;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
WHEN OTHERS THEN
rollback to process_vo_adj_tiers;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
END process_vo_adj_tiers;



PROCEDURE process_vo_adjustments
(
   p_init_msg_list         IN   VARCHAR2 := FND_API.g_false
  ,p_api_version           IN   NUMBER
  ,p_commit                IN   VARCHAR2 := FND_API.g_false
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offer_adjustment_id   IN   NUMBER

)
IS

L_API_VERSION_NUMBER CONSTANT NUMBER := 1.0;
L_API_NAME CONSTANT VARCHAR2(30) := 'process_vo_adjustments';

BEGIN
SAVEPOINT process_vo_adjustments;

IF NOT FND_API.COMPATIBLE_API_CALL(
                                    l_api_version_number
                                    ,p_api_version
                                    ,l_api_name
                                    ,G_PKG_NAME
                                )
 THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

IF FND_API.TO_BOOLEAN(p_init_msg_list) THEN
FND_MSG_PUB.INITIALIZE;
END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;
ozf_utility_pvt.debug_message('Private API:'|| l_api_name || ' Start');
process_vo_adj_tiers
(
   p_init_msg_list         => FND_API.g_false
  ,p_api_version           => 1.0
  ,p_commit                => FND_API.g_false
  ,x_return_status         => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_offer_adjustment_id   => p_offer_adjustment_id
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
process_vo_adj_products
(
   p_init_msg_list         => FND_API.g_false
  ,p_api_version           => 1.0
  ,p_commit                => FND_API.g_false
  ,x_return_status         => x_return_status
  ,x_msg_count             => x_msg_count
  ,x_msg_data              => x_msg_data
  ,p_offer_adjustment_id   => p_offer_adjustment_id
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

ozf_utility_pvt.debug_message('Private API:'|| l_api_name || ' End');
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
ROLLBACK TO process_vo_adjustments;
x_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
ROLLBACK TO process_vo_adjustments;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );
WHEN OTHERS THEN
ROLLBACK TO process_vo_adjustments;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
THEN
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
END IF;
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false
    , p_count => x_msg_count
    , p_data  => x_msg_data
    );

END process_vo_adjustments;


PROCEDURE getCloseAdjustmentParams
(
  p_offer_adjustment_id   IN   NUMBER
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,x_newStatus             OUT NOCOPY VARCHAR2
  ,x_budgetAdjFlag         OUT NOCOPY VARCHAR2
)
IS

l_newStatus OZF_OFFER_ADJUSTMENTS_B.STATUS_CODE%TYPE;
CURSOR c_closeAdjustment(cp_offerAdjustmentId NUMBER) IS
SELECT decode(greatest(a.effective_date,sysdate) , a.effective_date, 'Y','N') close_adjustment
FROM ozf_offer_adjustments_b a
WHERE offer_adjustment_id = cp_offerAdjustmentId;
l_closeAdjustment VARCHAR2(1);
l_budgetAdjFlag VARCHAR2(1);

BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
l_closeAdjustment := 'N';
OPEN c_closeAdjustment(p_offer_adjustment_id);
    FETCH c_closeAdjustment INTO l_closeAdjustment;
    IF c_closeAdjustment%NOTFOUND THEN
        l_closeAdjustment := 'N';
    END IF;
CLOSE c_closeAdjustment;

IF l_closeAdjustment = 'Y' THEN
    x_newStatus := 'CLOSED';
    x_budgetAdjFlag := 'Y';
ELSE
    x_newStatus := 'ACTIVE';
    x_budgetAdjFlag := null;
END IF;
END getCloseAdjustmentParams;

/**
*   Closes a Future dated adjustment and activates a back dated adjustment.
*   This procedure calls update statement directly since, this procedure may be called from update_offer_adjustments procedure
*   and calling this procedure again to update will lead to an recursive call without exit condition
*   p_offer_adjustment_id Primary key of the adjustment to be closed/activated
*/
PROCEDURE close_adjustment
(
  p_offer_adjustment_id   IN   NUMBER
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
)
IS
l_newStatus OZF_OFFER_ADJUSTMENTS_B.STATUS_CODE%TYPE;

CURSOR c_closeAdjustment(cp_offerAdjustmentId NUMBER) IS
SELECT decode(greatest(a.effective_date,sysdate) , a.effective_date, 'Y','N') close_adjustment,
       list_header_id offer_id
  FROM ozf_offer_adjustments_b a
 WHERE offer_adjustment_id = cp_offerAdjustmentId;

l_closeAdjustment VARCHAR2(1);
l_budgetAdjFlag   VARCHAR2(1);
l_list_header_id  NUMBER;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
l_closeAdjustment := 'N';
OPEN c_closeAdjustment(p_offer_adjustment_id);
    FETCH c_closeAdjustment INTO l_closeAdjustment,l_list_header_id;
    IF c_closeAdjustment%NOTFOUND THEN
        l_closeAdjustment := 'N';
    END IF;
CLOSE c_closeAdjustment;

IF l_closeAdjustment = 'Y' THEN
    l_newStatus := 'CLOSED';
    l_budgetAdjFlag := 'Y';
ELSE
    l_newStatus := 'ACTIVE';
    l_budgetAdjFlag := null;
END IF;

UPDATE ozf_offer_adjustments_b
             SET budget_adjusted_flag = l_budgetAdjFlag,
                 object_version_number = object_version_number + 1,
                 approved_date  = sysdate,
                 status_code = l_newStatus
                 WHERE offer_adjustment_id = p_offer_adjustment_id;


EXCEPTION
WHEN OTHERS THEN
x_return_status := FND_API.G_RET_STS_ERROR;
     Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END CLOSE_ADJUSTMENT;


PROCEDURE Update_Offer_Discounts
(
   p_init_msg_list         IN   VARCHAR2 := FND_API.g_false
  ,p_api_version           IN   NUMBER
  ,p_commit                IN   VARCHAR2 := FND_API.g_false
  ,x_return_status         OUT NOCOPY  VARCHAR2
  ,x_msg_count             OUT NOCOPY  NUMBER
  ,x_msg_data              OUT NOCOPY  VARCHAR2
  ,p_offer_adjustment_id   IN   NUMBER

)
IS
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'update_offer_discounts';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_list_header_id NUMBER;
BEGIN
-- initialize
-- push data to qp
-- close/activate the adjustment
   SAVEPOINT update_offer_discounts ;

   IF   Fnd_Api.to_boolean(p_init_msg_list)
   THEN
        Fnd_Msg_Pub.initialize;
   END IF;
    IF   NOT Fnd_Api.compatible_api_call (  l_api_version,
                                            p_api_version,
                                            l_api_name,
                                            g_pkg_name
                                           )
    THEN
         RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;
  x_return_status := Fnd_Api.g_ret_sts_success;
  -- julou backdated offer for Promotional Goods, Trade Deal, Tiered Discount
  -- populate l_modifier_list_rec
  -- set operation to NULL should prevent operation on list header and offer tables
OZF_OFFER_ADJ_PVT.process_adjustment
(
  p_init_msg_list           => FND_API.g_false
  ,p_api_version            => 1.0
  ,p_commit                 => FND_API.g_false
  ,x_return_status          => x_return_status
  ,x_msg_count              => x_msg_count
  ,x_msg_data               => x_msg_data
  ,p_offerAdjustmentId      => p_offer_adjustment_id
);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

SELECT list_header_id into l_list_header_id
  FROM ozf_offer_adjustments_b a
 WHERE offer_adjustment_id = p_offer_adjustment_id;

--insert into ozf_events values('After process_adjustment'||p_offer_adjustment_id,sysdate);
OZF_OFFER_PVT.raise_offer_event(l_list_header_id, p_offer_adjustment_id);

IF   p_commit = Fnd_Api.g_true
   THEN
        COMMIT WORK;
END IF;

EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.g_ret_sts_error ;
      ROLLBACK TO update_offer_discounts;
      Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
     ROLLBACK TO update_offer_discounts;
     Fnd_Msg_Pub.Count_AND_Get
         ( p_count      =>      x_msg_count,
           p_data       =>      x_msg_data,
           p_encoded    =>      Fnd_Api.G_FALSE
          );
 WHEN OTHERS THEN
     x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
     ROLLBACK TO update_offer_discounts ;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     Fnd_Msg_Pub.Count_AND_Get
       ( p_count      =>      x_msg_count,
         p_data       =>      x_msg_data,
         p_encoded    =>      Fnd_Api.G_FALSE
        );
END Update_Offer_Discounts ;



END OZF_Offer_Backdate_PVT;

/
