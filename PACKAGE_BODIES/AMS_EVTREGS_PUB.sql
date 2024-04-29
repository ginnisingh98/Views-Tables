--------------------------------------------------------
--  DDL for Package Body AMS_EVTREGS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_EVTREGS_PUB" as
/*$Header: amspregb.pls 115.19 2003/01/28 00:45:57 dbiswas ship $*/
-- Start of Comments
-- Package name     : AMS_EvtRegs_PUB
-- Purpose          :
-- History          :
--    12-MAR-2002    dcastlem    Added support for general Public API
--                               (AMS_Registrants_PUB)
--    22-Dec-2002    ptendulk    Modified for Debug Messages
--    27-Jan-2003    dbiswas     Modified p_block_fulfillment = 'F' bug 2769257
-- NOTE             :
-- End of Comments

g_pkg_name  CONSTANT VARCHAR2(30):='AMS_EvtRegs_PUB';
AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Register(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_evt_regs_Rec				 IN   AMS_EvtRegs_PVT.evt_regs_Rec_Type,
    p_block_fulfillment          IN   VARCHAR2     := 'F',
    x_event_registration_id      OUT NOCOPY  NUMBER,
    x_confirmation_code			 OUT NOCOPY  VARCHAR2,
    x_system_status_code         OUT NOCOPY  VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Register';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_evt_regs_Rec		AMS_EvtRegs_PVT.evt_regs_Rec_Type := P_evt_regs_Rec;
l_return_status                VARCHAR2(1); -- Return value from procedures.
l_cancellation_code  VARCHAR2(30);

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Register_pub;

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

   -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'PRE', 'C')
   THEN
      AMS_EvtRegs_CUHK.register_pre(  x_evt_regs_Rec => l_evt_regs_Rec
                                    , x_return_status => l_return_status
                                   );

      IF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'PRE', 'V')
   THEN
      AMS_EvtRegs_VUHK.register_pre(  x_evt_regs_Rec => l_evt_regs_Rec
                                    , x_return_status => l_return_status
                                   );

      IF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- API body
   -- Calling Private package: Create_EvtRegs

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message('Calling create registration');
   END IF ;
   AMS_evtregs_PVT.Create_evtregs(
       P_Api_Version_Number         => 1.0,
       P_Init_Msg_List              => FND_API.G_FALSE,
       P_Commit                     => p_commit,
       P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
       P_evt_regs_Rec			   =>  l_evt_regs_Rec ,
       p_block_fulfillment          => p_block_fulfillment,
       x_event_registration_id      => x_event_registration_id,
     x_confirmation_code		   => x_confirmation_code,
     x_system_status_code		   => x_system_status_code,
       x_return_status              => x_return_status,
       x_msg_count                  => x_msg_count,
       x_msg_data                   => x_msg_data);

   -- Check return status from the above procedure call
       IF x_return_status = FND_API.G_RET_STS_ERROR then
        raise FND_API.G_EXC_ERROR;
       elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

   -- vertical industry post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'POST', 'V')
   THEN
      AMS_EvtRegs_VUHK.register_post(  p_evt_regs_Rec => l_evt_regs_Rec
                                     , x_return_status => l_return_status
                                    );

      IF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- customer post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'POST', 'C')
   THEN
      AMS_EvtRegs_CUHK.register_post(  p_evt_regs_Rec => l_evt_regs_Rec
                                     , x_return_status => l_return_status
                                    );

      IF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

      -- End of API body.

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

   x_return_status := FND_API.g_ret_sts_success;
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Register_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Register_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO Register_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
          THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

End Register;

---------------------------------------------------------------------
-- PROCEDURE
--    init_reg_rec
--
-- HISTORY
--    06/29/2000  sugupta  Create.
---------------------------------------------------------------------
PROCEDURE init_reg_rec(
   x_evt_regs_rec  OUT NOCOPY  AMS_EvtRegs_PVT.evt_regs_Rec_Type
)
IS

BEGIN
	AMS_evtregs_PVT.init_evtregs_rec(x_evt_regs_rec);
END init_reg_rec;

/* add procedure update_regisrration info...make a rec with
updated column values...and then call update_registration..
*/

PROCEDURE Update_registration(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_evt_regs_Rec               IN   AMS_EvtRegs_PVT.evt_regs_Rec_Type,
    p_block_fulfillment          IN   VARCHAR2     := 'F',
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_registration';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_evt_regs_rec  AMS_EvtRegs_PVT.evt_regs_Rec_Type := P_evt_regs_Rec;
l_return_status                VARCHAR2(1); -- Return value from procedures.
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Registration_PUB;

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


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'PRE', 'C')
   THEN
      AMS_EvtRegs_CUHK.Update_registration_pre(  x_evt_regs_Rec => l_evt_regs_Rec
                                               , x_return_status => l_return_status
                                              );

      IF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'PRE', 'V')
   THEN
      AMS_EvtRegs_VUHK.Update_registration_pre(  x_evt_regs_Rec => l_evt_regs_Rec
                                               , x_return_status => l_return_status
                                              );

      IF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

      --
      -- API body
      --


    AMS_evtregs_PVT.Update_evtregs(
    P_Api_Version_Number         => 1.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
    P_evt_regs_Rec               => l_evt_regs_Rec,
    p_block_fulfillment          => p_block_fulfillment,
    X_Return_Status              => x_return_status,
    X_Msg_Count                  => x_msg_count,
    X_Msg_Data                   => x_msg_data);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body
      --

   -- vertical industry post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'POST', 'V')
   THEN
      AMS_EvtRegs_VUHK.Update_registration_post(  p_evt_regs_Rec => l_evt_regs_Rec
                                                , x_return_status => l_return_status
                                               );

      IF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- customer post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'POST', 'C')
   THEN
      AMS_EvtRegs_CUHK.Update_registration_post(  p_evt_regs_Rec => l_evt_regs_Rec
                                                , x_return_status => l_return_status
                                               );

      IF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

   x_return_status := FND_API.g_ret_sts_success;
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO update_registration_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_registration_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO update_registration_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
          THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

End Update_registration;

--   modified sugupta 06/21/2000 x_cancellation_code shud be varchar2

PROCEDURE Cancel_Registration(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_object_version		   IN   NUMBER,
    p_event_offer_id		   IN   NUMBER,
    p_registrant_party_id        IN   NUMBER,
    p_confirmation_code          IN   VARCHAR2,
    p_registration_group_id      IN   NUMBER,
    p_cancellation_reason_code   IN   VARCHAR2,
    p_block_fulfillment          IN   VARCHAR2     := 'F',
    x_cancellation_code          OUT NOCOPY  VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Cancel_Registration';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_pvt_evt_regs_rec  AMS_EvtRegs_PVT.evt_regs_Rec_Type;
l_object_version 		 NUMBER := p_object_version;
l_return_status 	VARCHAR2(1);
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Cancel_Registration_PUB;

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


   -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'PRE', 'C')
   THEN
      AMS_EvtRegs_CUHK.Cancel_Registration_pre(  p_object_version => l_object_version
                                               , p_event_offer_id => p_event_offer_id
                                               , p_registrant_party_id => p_registrant_party_id
                                               , p_confirmation_code => p_confirmation_code
                                               , p_registration_group_id => p_registration_group_id
                                               , p_cancellation_reason_code => p_cancellation_reason_code
                                               , x_cancellation_code => x_cancellation_code
                                               , X_Return_Status => l_Return_Status
                                              );

      IF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'PRE', 'V')
   THEN
      AMS_EvtRegs_VUHK.Cancel_Registration_pre(  p_object_version => l_object_version
                                               , p_event_offer_id => p_event_offer_id
                                               , p_registrant_party_id => p_registrant_party_id
                                               , p_confirmation_code => p_confirmation_code
                                               , p_registration_group_id => p_registration_group_id
                                               , p_cancellation_reason_code => p_cancellation_reason_code
                                               , x_cancellation_code => x_cancellation_code
                                               , X_Return_Status => l_Return_Status
                                              );

      IF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

      -- API body

    AMS_evtregs_PVT.Cancel_evtregs(
    P_Api_Version_Number         => l_api_version_number,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,

    p_object_version             => l_object_version,
    p_event_offer_id		     => p_event_offer_id,
    p_registrant_party_id        => p_registrant_party_id,
    p_confirmation_code          => p_confirmation_code,
    p_registration_group_id      => p_registration_group_id,
    p_cancellation_reason_code   => p_cancellation_reason_code,
    p_block_fulfillment          => p_block_fulfillment,
    x_cancellation_code          => x_cancellation_code,
    X_Return_Status              => l_return_status,
    X_Msg_Count                  => x_msg_count,
    X_Msg_Data                   => x_msg_data);

      -- Check return status from the above procedure call
      IF l_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   -- vertical industry post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'POST', 'V')
   THEN
      AMS_EvtRegs_VUHK.Cancel_Registration_post(  p_object_version => l_object_version
                                                , p_event_offer_id => p_event_offer_id
                                                , p_registrant_party_id => p_registrant_party_id
                                                , p_confirmation_code => p_confirmation_code
                                                , p_registration_group_id => p_registration_group_id
                                                , p_cancellation_reason_code => p_cancellation_reason_code
                                                , x_cancellation_code => x_cancellation_code
                                                , X_Return_Status => l_Return_Status
                                               );

      IF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- customer post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'POST', 'C')
   THEN
      AMS_EvtRegs_CUHK.Cancel_Registration_post(  p_object_version => l_object_version
                                                , p_event_offer_id => p_event_offer_id
                                                , p_registrant_party_id => p_registrant_party_id
                                                , p_confirmation_code => p_confirmation_code
                                                , p_registration_group_id => p_registration_group_id
                                                , p_cancellation_reason_code => p_cancellation_reason_code
                                                , x_cancellation_code => x_cancellation_code
                                                , X_Return_Status => l_Return_Status
                                               );

      IF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

  x_return_status := FND_API.g_ret_sts_success;

  -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Cancel_Registration_PUB;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Cancel_Registration_PUB;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO Cancel_Registration_PUB;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
          THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

End Cancel_Registration;

PROCEDURE delete_Registration(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_object_version		   IN   NUMBER,
    p_event_registration_id	   IN   NUMBER,

    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
) IS
l_api_name                CONSTANT VARCHAR2(30) := 'delete_Registration';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_event_registration_id 	 NUMBER	:= p_event_registration_id;
l_object_version 		 NUMBER := p_object_version;
l_return_status                VARCHAR2(1); -- Return value from procedures.

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_Registration_PUB;

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

       -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'PRE', 'C')
   THEN
      AMS_EvtRegs_CUHK.delete_Registration_pre(  x_object_version => l_object_version
                                               , x_event_registration_id =>l_event_registration_id
                                               , X_Return_Status => l_Return_Status
                                              );

      IF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'PRE', 'V')
   THEN
      AMS_EvtRegs_VUHK.delete_Registration_pre(  x_object_version => l_object_version
                                               , x_event_registration_id =>l_event_registration_id
                                               , X_Return_Status => l_Return_Status
                                              );

      IF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

	  -- API body

    AMS_evtregs_PVT.delete_evtregs(
				p_api_version_number         => l_api_version_number,
				p_init_msg_list              => FND_API.G_FALSE,
				p_commit                     => p_commit,
				p_object_version             => l_object_version,
				p_event_registration_id		 => l_event_registration_id,

				X_Return_Status              => x_return_status,
				X_Msg_Count                  => x_msg_count,
				X_Msg_Data                   => x_msg_data);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'POST', 'V')
   THEN
      AMS_EvtRegs_VUHK.delete_Registration_post(  p_object_version => l_object_version
                                                , p_event_registration_id =>l_event_registration_id
                                                , X_Return_Status => l_Return_Status
                                              );

      IF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'POST', 'C')
   THEN
      AMS_EvtRegs_CUHK.delete_Registration_post(  p_object_version => l_object_version
                                                , p_event_registration_id =>l_event_registration_id
                                                , X_Return_Status => l_Return_Status
                                               );

      IF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;



    -- End of API body

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

    -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO delete_Registration_PUB;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_Registration_PUB;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO delete_Registration_PUB;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
          THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

End delete_Registration;

-------------------------------------------------------
-- Start of Comments
--
-- PROCEDURE
--  prioritize_reg_wailist
--
-- HISTORY
--    11/29/99  sugupta  Added.
-- PURPOSE
--  Registrations for an event can have a wailist. This api call will look to see if it can
-- upgrade a reg status from wailtlisted to registered, if any cancellations or event
-- details have been changed.
-- note that cancelling a registration automatically calls this API internally to
-- upgrade the reg statuses in real time.
-------------------------------------------------------------

PROCEDURE prioritize_reg_wailist(
   p_api_version_number         IN   NUMBER,
   p_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
   P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
   p_event_offer_id     		IN   NUMBER,

   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2
) IS

l_api_name                CONSTANT VARCHAR2(30) := 'prioritize_reg_wailist';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status           VARCHAR2(1); -- Return value from procedures.
l_event_offer_id          NUMBER := p_event_offer_id;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT prioritize_reg_wailist_pub;

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

       -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'PRE', 'C')
   THEN
      AMS_EvtRegs_CUHK.prioritize_reg_wailist_pre(  x_event_offer_id => l_event_offer_id
                                                  , X_Return_Status => l_Return_Status
                                                 );

      IF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'PRE', 'V')
   THEN
      AMS_EvtRegs_VUHK.prioritize_reg_wailist_pre(  x_event_offer_id => l_event_offer_id
                                                  , X_Return_Status => l_Return_Status
                                                 );

      IF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

      --
      -- API body
      --
	  AMS_EVTREGS_PVT.prioritize_waitlist(
			   p_api_version_number => p_api_version_number,
			   p_Init_Msg_List => p_Init_Msg_List,
			   P_Commit => P_Commit,
			   p_event_offer_id => l_event_offer_id,

			   x_return_status => x_return_status,
			   x_msg_count => x_msg_count,
			   x_msg_data => x_msg_data
	  );

	  -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'POST', 'V')
   THEN
      AMS_EvtRegs_VUHK.prioritize_reg_wailist_post(  p_event_offer_id => l_event_offer_id
                                                   , X_Return_Status => l_Return_Status
                                                  );

      IF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'POST', 'C')
   THEN
      AMS_EvtRegs_CUHK.prioritize_reg_wailist_post(  p_event_offer_id => l_event_offer_id
                                                   , X_Return_Status => l_Return_Status
                                                  );

      IF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

    -- End of API body

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

    -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO prioritize_reg_wailist_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO prioritize_reg_wailist_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO prioritize_reg_wailist_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
          THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

End prioritize_reg_wailist;

-------------------------------------------------------
-- Start of Comments
--
-- PROCEDURE
--  substitute_enrollee
--
-- HISTORY
--    11/16/99  sugupta  Added.
-- PURPOSE
--  Substitute an enrollee(attendant) for an existing event registration..
-- Who can substitute is NOT verified in this API call...
-- If registrant information is also provided, then the existing
-- 'registrant information' is replaced...
-- 'Attendant information' is mandatory, but for account information...
-- if registrant info is changed, reg_contact id is stored in original_reg_contact_id column..
-------------------------------------------------------------

PROCEDURE substitute_enrollee(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    p_confirmation_code	         IN   VARCHAR2,	--required
    p_attendant_party_id		 IN   NUMBER,	--required
    p_attendant_contact_id	     IN   NUMBER,	--required
    p_attendant_account_id       IN   NUMBER,
    p_registrant_party_id	     IN   NUMBER,
    p_registrant_contact_id	     IN   NUMBER,	--required
    p_registrant_account_id	     IN   NUMBER,

    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'substitute_enrollee';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_confirmation_code 	  VARCHAR2(30) := p_confirmation_code;
l_return_status           VARCHAR2(1); -- Return value from procedures.

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT substitute_enrollee_pub;

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

       -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'PRE', 'C')
   THEN
      AMS_EvtRegs_CUHK.substitute_enrollee_pre(  p_confirmation_code => l_confirmation_code
                                               , p_attendant_party_id => p_attendant_party_id
                                               , p_attendant_contact_id => p_attendant_contact_id
                                               , p_attendant_account_id => p_attendant_account_id
                                               , p_registrant_party_id => p_registrant_party_id
                                               , p_registrant_contact_id => p_registrant_contact_id
                                               , p_registrant_account_id => p_registrant_account_id
                                               , X_Return_Status => l_Return_Status
                                              );


      IF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'PRE', 'V')
   THEN
      AMS_EvtRegs_VUHK.substitute_enrollee_pre(  p_confirmation_code => l_confirmation_code
                                               , p_attendant_party_id => p_attendant_party_id
                                               , p_attendant_contact_id => p_attendant_contact_id
                                               , p_attendant_account_id => p_attendant_account_id
                                               , p_registrant_party_id => p_registrant_party_id
                                               , p_registrant_contact_id => p_registrant_contact_id
                                               , p_registrant_account_id => p_registrant_account_id
                                               , X_Return_Status => l_Return_Status
                                              );


      IF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

      -- API body

	AMS_EVTREGS_PVT.substitute_and_validate(
				P_Api_Version_Number         => l_Api_Version_Number,
				P_Init_Msg_List              => P_Init_Msg_List ,
				P_Commit                     => P_Commit ,

				p_confirmation_code	         => l_confirmation_code,
				p_attendant_party_id		 => p_attendant_party_id,
				p_attendant_contact_id		 => p_attendant_contact_id,
				p_attendant_account_id       => p_attendant_account_id,
				p_registrant_party_id		 => p_registrant_party_id,
				p_registrant_contact_id		 => p_registrant_contact_id,
				p_registrant_account_id		 => p_registrant_account_id,

				X_Return_Status              =>  x_return_status,
				X_Msg_Count                  =>  x_msg_count,
				X_Msg_Data                   =>  x_msg_data
    );
      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    -- End of API body
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'POST', 'V')
   THEN
      AMS_EvtRegs_VUHK.substitute_enrollee_post(  p_confirmation_code => l_confirmation_code
                                                , p_attendant_party_id => p_attendant_party_id
                                                , p_attendant_contact_id => p_attendant_contact_id
                                                , p_attendant_account_id => p_attendant_account_id
                                                , p_registrant_party_id => p_registrant_party_id
                                                , p_registrant_contact_id => p_registrant_contact_id
                                                , p_registrant_account_id => p_registrant_account_id
                                                , X_Return_Status => l_Return_Status
                                               );

      IF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'POST', 'C')
   THEN
      AMS_EvtRegs_CUHK.substitute_enrollee_post(  p_confirmation_code => l_confirmation_code
                                                , p_attendant_party_id => p_attendant_party_id
                                                , p_attendant_contact_id => p_attendant_contact_id
                                                , p_attendant_account_id => p_attendant_account_id
                                                , p_registrant_party_id => p_registrant_party_id
                                                , p_registrant_contact_id => p_registrant_contact_id
                                                , p_registrant_account_id => p_registrant_account_id
                                                , X_Return_Status => l_Return_Status
                                               );

      IF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

    -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO substitute_enrollee_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO substitute_enrollee_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO substitute_enrollee_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
          THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

End substitute_enrollee;

-------------------------------------------------------
-- Start of Comments
--
-- PROCEDURE
--  transfer_enrollee
--
-- HISTORY
--    11/16/99  sugupta  Added.
-- PURPOSE
--  Transfer an enrollee(attendant) for an existing event registration
--  from one event offering to another offer id...
-- Who can transfer is NOT validated in this API call...
-- Waitlist flag input is mandatory which means if the other offering is full and
-- the attendant is willing to get waitlisted....
-- if the offering is full, and waitlisting is not wanted or even wailist is full, then
-- the transfer will fail...
-- PAYMENT details are not taken care of in this API call....
-------------------------------------------------------------

PROCEDURE transfer_enrollee(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_object_version	 		 IN   NUMBER,
    p_old_confirmation_code		 IN   VARCHAR2,	--required
    p_old_offer_id				 IN   NUMBER,	--required
    p_new_offer_id				 IN   NUMBER,	--required
    p_waitlist_flag				 IN   VARCHAR2,	--required
    p_registrant_account_id		 IN   NUMBER,  -- can be null
    p_registrant_party_id		 IN	  NUMBER,  -- can be null
    p_registrant_contact_id		 IN	  NUMBER,  -- can be null
    p_attendant_party_id         IN   NUMBER,-- can be null
    p_attendant_contact_id       IN   NUMBER,-- can be null
    x_new_confirmation_code		 OUT NOCOPY  VARCHAR2,
    x_old_cancellation_code		 OUT NOCOPY  VARCHAR2,
    x_new_registration_id        OUT NOCOPY  NUMBER,
    x_old_system_status_code	 OUT NOCOPY  VARCHAR2,
    x_new_system_status_code     OUT NOCOPY  VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
) IS

l_api_name                CONSTANT VARCHAR2(30) := 'transfer_enrollee';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status           VARCHAR2(1); -- Return value from procedures.

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT substitute_enrollee_PUB;

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

       -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'PRE', 'C')
   THEN
      AMS_EvtRegs_CUHK.transfer_enrollee_pre(  p_object_version => p_object_version
                                             , p_old_confirmation_code => p_old_confirmation_code
                                             , p_old_offer_id => p_old_offer_id
                                             , p_new_offer_id => p_new_offer_id
                                             , p_waitlist_flag => p_waitlist_flag
                                             , p_registrant_account_id => p_registrant_account_id
                                             , p_registrant_party_id => p_registrant_party_id
                                             , p_registrant_contact_id => p_registrant_contact_id
                                             , p_attendant_party_id => p_attendant_party_id
                                             , p_attendant_contact_id => p_attendant_contact_id
                                             , X_Return_Status => l_Return_Status
                                            );

      IF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'PRE', 'V')
   THEN
      AMS_EvtRegs_VUHK.transfer_enrollee_pre(  p_object_version => p_object_version
                                             , p_old_confirmation_code => p_old_confirmation_code
                                             , p_old_offer_id => p_old_offer_id
                                             , p_new_offer_id => p_new_offer_id
                                             , p_waitlist_flag => p_waitlist_flag
                                             , p_registrant_account_id => p_registrant_account_id
                                             , p_registrant_party_id => p_registrant_party_id
                                             , p_registrant_contact_id => p_registrant_contact_id
                                             , p_attendant_party_id => p_attendant_party_id
                                             , p_attendant_contact_id => p_attendant_contact_id
                                             , X_Return_Status => l_Return_Status
                                            );

      IF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

      --
      -- API body
      --
	AMS_EVTREGS_PVT.transfer_and_validate(
								P_Api_Version_Number,
								P_Init_Msg_List,
								P_Commit,
								p_object_version,
								p_old_confirmation_code,	--required
								p_old_offer_id,	--required
								p_new_offer_id,	--required
								p_waitlist_flag,	--required
								p_registrant_account_id,  -- can be null
								p_registrant_party_id,  -- can be null
								p_registrant_contact_id,  -- can be null
								p_attendant_party_id,-- can be null
								p_attendant_contact_id,-- can be null
								x_new_confirmation_code,
								x_old_cancellation_code,
								x_new_registration_id,
								x_old_system_status_code,
								x_new_system_status_code,
								X_Return_Status,
								X_Msg_Count,
								X_Msg_Data
	);

     -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'POST', 'V')
   THEN
      AMS_EvtRegs_VUHK.transfer_enrollee_post(  p_object_version => p_object_version
                                              , p_old_confirmation_code => p_old_confirmation_code
                                              , p_old_offer_id => p_old_offer_id
                                              , p_new_offer_id => p_new_offer_id
                                              , p_waitlist_flag => p_waitlist_flag
                                              , p_registrant_account_id => p_registrant_account_id
                                              , p_registrant_party_id => p_registrant_party_id
                                              , p_registrant_contact_id => p_registrant_contact_id
                                              , p_attendant_party_id => p_attendant_party_id
                                              , p_attendant_contact_id => p_attendant_contact_id
                                              , X_Return_Status => l_Return_Status
                                             );

      IF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'POST', 'C')
   THEN
      AMS_EvtRegs_CUHK.transfer_enrollee_post(  p_object_version => p_object_version
                                              , p_old_confirmation_code => p_old_confirmation_code
                                              , p_old_offer_id => p_old_offer_id
                                              , p_new_offer_id => p_new_offer_id
                                              , p_waitlist_flag => p_waitlist_flag
                                              , p_registrant_account_id => p_registrant_account_id
                                              , p_registrant_party_id => p_registrant_party_id
                                              , p_registrant_contact_id => p_registrant_contact_id
                                              , p_attendant_party_id => p_attendant_party_id
                                              , p_attendant_contact_id => p_attendant_contact_id
                                              , X_Return_Status => l_Return_Status
                                             );

      IF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;


    -- End of API body

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

    -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO transfer_enrollee;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO transfer_enrollee;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO transfer_enrollee;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
          THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

End transfer_enrollee;

FUNCTION  Get_Reg_Rec RETURN  AMS_EvtRegs_PVT.evt_regs_Rec_Type
IS
  TMP_REC  AMS_EvtRegs_PVT.evt_regs_Rec_Type;
 BEGIN
     RETURN   TMP_REC;
 END Get_Reg_Rec;

End AMS_EvtRegs_PUB;

/
