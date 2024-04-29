--------------------------------------------------------
--  DDL for Package Body AMS_DELIVERABLE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DELIVERABLE_PUB" as
/* $Header: amspdelb.pls 120.0 2005/05/31 17:03:06 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--         AMS_Deliverable_PUB
-- Purpose
--
-- History
--  27-sep-2002  ABHOLA Created
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Deliverable_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amspdelb.pls';

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Convert_PubRec_To_PvtRec(
   p_deliv_rec_pub      IN   deliv_rec_type,
   x_deliv_rec_pvt      OUT NOCOPY  AMS_Deliverable_PVT.deliv_rec_type

)

IS
   l_deliv_rec_pub      deliv_rec_type := p_deliv_rec_pub;

BEGIN

       x_deliv_rec_pvt.deliverable_id                 :=  l_deliv_rec_pub.deliverable_id ;
       x_deliv_rec_pvt.last_update_date               :=  l_deliv_rec_pub.last_update_date;
       x_deliv_rec_pvt.last_updated_by                :=  l_deliv_rec_pub.last_updated_by ;
       x_deliv_rec_pvt.creation_date                  :=  l_deliv_rec_pub.creation_date;
       x_deliv_rec_pvt.created_by                     :=  l_deliv_rec_pub.created_by;
       x_deliv_rec_pvt.last_update_login              :=  l_deliv_rec_pub.last_update_login;
       x_deliv_rec_pvt.object_version_number          :=  l_deliv_rec_pub.object_version_number;
       x_deliv_rec_pvt.user_status_id                 :=  l_deliv_rec_pub.user_status_id;
       x_deliv_rec_pvt.status_code                    :=  l_deliv_rec_pub.status_code;
       x_deliv_rec_pvt.status_date                    :=  l_deliv_rec_pub.status_date;
x_deliv_rec_pvt.deliverable_id                       :=  l_deliv_rec_pub.deliverable_id;
x_deliv_rec_pvt.last_update_date                     :=  l_deliv_rec_pub.last_update_date;
x_deliv_rec_pvt.last_updated_by                      :=  l_deliv_rec_pub.last_updated_by;
x_deliv_rec_pvt.creation_date                        :=  l_deliv_rec_pub.creation_date;
x_deliv_rec_pvt.created_by                           :=  l_deliv_rec_pub.created_by;
x_deliv_rec_pvt.last_update_login                    :=  l_deliv_rec_pub.last_update_login;
x_deliv_rec_pvt.object_version_number                :=  l_deliv_rec_pub.object_version_number;
x_deliv_rec_pvt.language_code                        :=  l_deliv_rec_pub.language_code;
x_deliv_rec_pvt.version                              :=  l_deliv_rec_pub.version ;
x_deliv_rec_pvt.application_id                       :=  l_deliv_rec_pub.application_id;
x_deliv_rec_pvt.user_status_id                       :=  l_deliv_rec_pub.user_status_id ;
x_deliv_rec_pvt.status_code                          :=  l_deliv_rec_pub.status_code  ;
x_deliv_rec_pvt.status_date                          :=  l_deliv_rec_pub.status_date  ;
x_deliv_rec_pvt.active_flag                          :=  l_deliv_rec_pub.active_flag   ;
x_deliv_rec_pvt.private_flag                         :=  l_deliv_rec_pub.private_flag   ;
x_deliv_rec_pvt.owner_user_id                        :=  l_deliv_rec_pub.owner_user_id   ;
x_deliv_rec_pvt.fund_source_id                       :=  l_deliv_rec_pub.fund_source_id   ;
x_deliv_rec_pvt.fund_source_type                     :=  l_deliv_rec_pub.fund_source_type  ;
x_deliv_rec_pvt.category_type_id                     :=  l_deliv_rec_pub.category_type_id   ;
x_deliv_rec_pvt.category_sub_type_id                 :=  l_deliv_rec_pub.category_sub_type_id ;
x_deliv_rec_pvt.kit_flag                             :=  l_deliv_rec_pub.kit_flag      ;
x_deliv_rec_pvt.inventory_flag                       :=  l_deliv_rec_pub.inventory_flag  ;
x_deliv_rec_pvt.inventory_item_id                    :=  l_deliv_rec_pub.inventory_item_id ;
x_deliv_rec_pvt.inventory_item_org_id                :=  l_deliv_rec_pub.inventory_item_org_id ;
x_deliv_rec_pvt.pricelist_header_id                  :=  l_deliv_rec_pub.pricelist_header_id  ;
x_deliv_rec_pvt.pricelist_line_id                    :=  l_deliv_rec_pub.pricelist_line_id     ;
x_deliv_rec_pvt.actual_avail_from_date               :=  l_deliv_rec_pub.actual_avail_from_date ;
x_deliv_rec_pvt.actual_avail_to_date                 :=  l_deliv_rec_pub.actual_avail_to_date  ;
x_deliv_rec_pvt.forecasted_complete_date             :=  l_deliv_rec_pub.forecasted_complete_date ;
x_deliv_rec_pvt.actual_complete_date                 :=  l_deliv_rec_pub.actual_complete_date      ;
x_deliv_rec_pvt.transaction_currency_code            :=  l_deliv_rec_pub.transaction_currency_code  ;
x_deliv_rec_pvt.functional_currency_code             :=  l_deliv_rec_pub.functional_currency_code    ;
x_deliv_rec_pvt.budget_amount_tc                     :=  l_deliv_rec_pub.budget_amount_tc    ;
x_deliv_rec_pvt.budget_amount_fc                     :=  l_deliv_rec_pub.budget_amount_fc    ;
x_deliv_rec_pvt.replaced_by_deliverable_id           :=  l_deliv_rec_pub.replaced_by_deliverable_id  ;
x_deliv_rec_pvt.can_fulfill_electronic_flag          :=  l_deliv_rec_pub.can_fulfill_electronic_flag ;
x_deliv_rec_pvt.can_fulfill_physical_flag            :=  l_deliv_rec_pub.can_fulfill_physical_flag   ;
x_deliv_rec_pvt.jtf_amv_item_id                      :=  l_deliv_rec_pub.jtf_amv_item_id   ;
x_deliv_rec_pvt.non_inv_ctrl_code                    :=  l_deliv_rec_pub.non_inv_ctrl_code  ;
x_deliv_rec_pvt.non_inv_quantity_on_hand             :=  l_deliv_rec_pub.non_inv_quantity_on_hand    ;
x_deliv_rec_pvt.non_inv_quantity_on_order            :=  l_deliv_rec_pub.non_inv_quantity_on_order   ;
x_deliv_rec_pvt.non_inv_quantity_on_reserve          :=  l_deliv_rec_pub.non_inv_quantity_on_reserve ;
x_deliv_rec_pvt.chargeback_amount                    :=  l_deliv_rec_pub.chargeback_amount           ;
x_deliv_rec_pvt.chargeback_uom                       :=  l_deliv_rec_pub.chargeback_uom              ;
x_deliv_rec_pvt.chargeback_amount_curr_code          :=  l_deliv_rec_pub.chargeback_amount_curr_code ;
x_deliv_rec_pvt.deliverable_code                     :=  l_deliv_rec_pub.deliverable_code            ;
x_deliv_rec_pvt.deliverable_pick_flag                :=  l_deliv_rec_pub.deliverable_pick_flag       ;
x_deliv_rec_pvt.currency_code                        :=  l_deliv_rec_pub.currency_code               ;
x_deliv_rec_pvt.forecasted_cost                      :=  l_deliv_rec_pub.forecasted_cost             ;
x_deliv_rec_pvt.actual_cost                          :=  l_deliv_rec_pub.actual_cost                 ;
x_deliv_rec_pvt.forecasted_responses                 :=  l_deliv_rec_pub.forecasted_responses        ;
x_deliv_rec_pvt.actual_responses                     :=  l_deliv_rec_pub.actual_responses            ;
x_deliv_rec_pvt.country                              :=  l_deliv_rec_pub.country                     ;
x_deliv_rec_pvt.default_approver_id                  :=  l_deliv_rec_pub.default_approver_id         ;
x_deliv_rec_pvt.attribute_category                   :=  l_deliv_rec_pub.attribute_category          ;
x_deliv_rec_pvt.attribute1                           :=  l_deliv_rec_pub.attribute1                  ;
x_deliv_rec_pvt.attribute2                           :=  l_deliv_rec_pub.attribute2                  ;
x_deliv_rec_pvt.attribute3                           :=  l_deliv_rec_pub.attribute3                  ;
x_deliv_rec_pvt.attribute4                           :=  l_deliv_rec_pub.attribute4                  ;
x_deliv_rec_pvt.attribute5                           :=  l_deliv_rec_pub.attribute5                  ;
x_deliv_rec_pvt.attribute6                           :=  l_deliv_rec_pub.attribute6                  ;
x_deliv_rec_pvt.attribute7                           :=  l_deliv_rec_pub.attribute7                  ;
x_deliv_rec_pvt.attribute8                           :=  l_deliv_rec_pub.attribute8                  ;
x_deliv_rec_pvt.attribute9                           :=  l_deliv_rec_pub.attribute9                  ;
x_deliv_rec_pvt.attribute10                          :=  l_deliv_rec_pub.attribute10                 ;
x_deliv_rec_pvt.attribute11                          :=  l_deliv_rec_pub.attribute11                 ;
x_deliv_rec_pvt.attribute12                          :=  l_deliv_rec_pub.attribute12                 ;
x_deliv_rec_pvt.attribute13                          :=  l_deliv_rec_pub.attribute13                 ;
x_deliv_rec_pvt.attribute14                          :=  l_deliv_rec_pub.attribute14                 ;
x_deliv_rec_pvt.attribute15                          :=  l_deliv_rec_pub.attribute15                 ;
x_deliv_rec_pvt.deliverable_name                     :=  l_deliv_rec_pub.deliverable_name            ;
x_deliv_rec_pvt.description                          :=  l_deliv_rec_pub.description                 ;
x_deliv_rec_pvt.start_period_name                    :=  l_deliv_rec_pub.start_period_name           ;
x_deliv_rec_pvt.end_period_name                      :=  l_deliv_rec_pub.end_period_name             ;
x_deliv_rec_pvt.deliverable_calendar                 :=  l_deliv_rec_pub.deliverable_calendar        ;
x_deliv_rec_pvt.country_id                           :=  l_deliv_rec_pub.country_id                  ;
x_deliv_rec_pvt.setup_id                             :=  l_deliv_rec_pub.setup_id                    ;
x_deliv_rec_pvt.item_Number                          :=  l_deliv_rec_pub.item_Number       ;
x_deliv_rec_pvt.associate_flag                       :=  l_deliv_rec_pub.associate_flag    ;
x_deliv_rec_pvt.master_object_id                     :=  l_deliv_rec_pub.master_object_id  ;
x_deliv_rec_pvt.master_object_type                   :=  l_deliv_rec_pub.master_object_type;
x_deliv_rec_pvt.email_content_type                   :=  l_deliv_rec_pub.email_content_type ;

END;


PROCEDURE create_Deliverable(
   p_api_version_number       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_deliv_rec          IN  deliv_rec_type,
   x_deliv_id           OUT NOCOPY NUMBER
)
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'create_Deliverable';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_return_status  VARCHAR2(1);
l_pvt_deliv_rec    AMS_deliverable_PVT.deliv_rec_type ;
l_pub_deliv_rec    deliv_rec_type := p_deliv_rec;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_deliv_PUB;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- convert public parameter to private-type
      Convert_PubRec_To_PvtRec(l_pub_deliv_rec,l_pvt_deliv_rec);

      Create_Deliverable(
         p_api_version_number     => p_api_version_number,
         p_init_msg_list          => p_init_msg_list,
         p_commit                 => p_commit,
         p_validation_level       => p_validation_level,
         x_return_status          => x_return_status,
         x_msg_count              => x_msg_count,
         x_msg_data               => x_msg_data,
         p_deliv_rec              => l_pvt_deliv_rec,
         x_deliv_id               => x_deliv_id  );

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
       IF (AMS_DEBUG_HIGH_ON) THEN
        AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');
       END IF;

       -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
         (p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
       );

EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_deliv_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_deliv_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_deliv_PUB;
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
End Create_Deliverable;




PROCEDURE Create_Deliverable(

   p_api_version_number      IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_deliv_rec          IN  AMS_Deliverable_PVT.deliv_rec_type,
   x_deliv_id           OUT NOCOPY NUMBER

     )


 IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'create_Deliverable';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_return_status  VARCHAR2(1);
l_pvt_deliv_rec    AMS_Deliverable_PVT.deliv_rec_type := p_deliv_rec;

BEGIN

      SAVEPOINT CREATE_Deliverable_PUB;

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
       IF (AMS_DEBUG_HIGH_ON) THEN
        AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');
       END IF;

       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       --
       -- API body
       --
     -- Calling Private package: Create_Deliverable
     -- Hint: Primary key needs to be returned

  -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_Deliverable_CUHK.create_deliverable_pre(
         l_pvt_Deliv_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'V')
   THEN
      AMS_Deliverable_VUHK.create_deliverable_pre(
         l_pvt_Deliv_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;
   -------------------------------------------------------
       AMS_Deliverable_PVT.Create_Deliverable(
              p_api_version                => 1.0,
              p_init_msg_list              => FND_API.G_FALSE,
              p_commit                     => FND_API.G_FALSE,
              p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
              x_return_status              => x_return_status,
              x_msg_count                  => x_msg_count,
              x_msg_data                   => x_msg_data,
              p_Deliv_rec                  => l_pvt_Deliv_rec,
              x_Deliv_id                   => x_Deliv_id);


       -- Check return status from the above procedure call
       IF x_return_status = FND_API.G_RET_STS_ERROR then
           RAISE FND_API.G_EXC_ERROR;
       elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- End of API body.
       --

           -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'C')
   THEN
      AMS_Deliverable_CUHK.create_deliverable_post(
         l_pvt_Deliv_rec,
         x_Deliv_id,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;



   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'V')
   THEN
      AMS_Deliverable_VUHK.create_deliverable_post(
         l_pvt_Deliv_rec,
         x_Deliv_id,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;
   ------------------------------------------

       -- Standard check for p_commit
       IF FND_API.to_Boolean( p_commit )
       THEN
          COMMIT WORK;
       END IF;


       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN
       AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');
       END IF;

       -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
         (p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
       );

EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Deliverable_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Deliverable_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Deliverable_PUB;
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
End Create_Deliverable;

PROCEDURE Update_Deliverable(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER    := FND_API.g_valid_level_full,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_deliv_rec                  IN  deliv_rec_type
    )

 IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'update_Deliverable';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number  NUMBER;
l_return_status  VARCHAR2(1);
l_pvt_deliv_rec    AMS_deliverable_PVT.deliv_rec_type ;
l_pub_deliv_rec    deliv_rec_type := p_deliv_rec;

BEGIN

       -- Standard Start of API savepoint
       SAVEPOINT UPDATE_Deliv_PUB;

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
      IF (AMS_DEBUG_HIGH_ON) THEN
       AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');
      END IF;


       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- convert public parameter to private-type
      Convert_PubRec_To_PvtRec(l_pub_deliv_rec,l_pvt_deliv_rec);

      update_Deliverable(
         p_api_version_number     => p_api_version_number,
         p_init_msg_list          => p_init_msg_list,
         p_commit                 => p_commit,
         p_validation_level       => p_validation_level,
         x_return_status          => x_return_status,
         x_msg_count              => x_msg_count,
         x_msg_data               => x_msg_data,
         p_deliv_rec              => l_pvt_deliv_rec );

       -- Check return status from the above procedure call
       IF x_return_status = FND_API.G_RET_STS_ERROR then
           RAISE FND_API.G_EXC_ERROR;
       elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- End of API body.
       --

   -------------------------------------------------------
       -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN
       AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');
       END IF;

       -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
         (p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
       );
 EXCEPTION

    WHEN AMS_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
  AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_Deliv_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_Deliv_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO UPDATE_Deliv_PUB;
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

End Update_Deliverable;


PROCEDURE Update_Deliverable(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER    := FND_API.g_valid_level_full,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_deliv_rec                  IN  AMS_Deliverable_PVT.deliv_rec_type
    )

 IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'update_Deliverable';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number  NUMBER;
l_return_status  VARCHAR2(1);
l_pvt_deliv_rec  AMS_Deliverable_PVT.deliv_rec_type := p_deliv_rec;

BEGIN

       -- Standard Start of API savepoint
       SAVEPOINT UPDATE_Deliverable_PUB;

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
       IF (AMS_DEBUG_HIGH_ON) THEN
       AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');
       END IF;

       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_Deliverable_CUHK.update_deliverable_pre(
         l_pvt_deliv_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'V')
   THEN
      AMS_Deliverable_VUHK.update_deliverable_pre(
         l_pvt_deliv_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;
   -------------------------------------------------------
       --
       -- API body
       --
   AMS_Deliverable_PVT.Update_Deliverable(
     p_api_version         => 1.0,
     p_init_msg_list              => FND_API.G_FALSE,
     p_commit                     => p_commit,
     p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
     x_return_status              => x_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data,
     p_deliv_rec                  =>  l_pvt_deliv_rec);


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

   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'C')
   THEN
      AMS_Deliverable_CUHK.update_deliverable_post(
         l_pvt_deliv_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'V')
   THEN
      AMS_Deliverable_VUHK.update_deliverable_post(
         l_pvt_deliv_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;
   -------------------------------------------------------
       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN
       AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');
       END IF;

       -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
         (p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
       );
 EXCEPTION

    WHEN AMS_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
  AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_Deliverable_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_Deliverable_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO UPDATE_Deliverable_PUB;
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

End Update_Deliverable;


PROCEDURE Delete_Deliverable(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
        p_validation_level           IN  NUMBER    := FND_API.g_valid_level_full,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_deliv_id                   IN   NUMBER,
    p_object_version_number      IN   NUMBER
    )



 IS

 L_API_NAME                  CONSTANT VARCHAR2(30) := 'delete_Deliverable';
 L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
 l_deliv_ID  NUMBER := p_deliv_ID;
 l_object_version_number  NUMBER := p_object_version_number;
 l_return_status          VARCHAR2(1);


  BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT DELETE_Deliverable_PUB;

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
       IF (AMS_DEBUG_HIGH_ON) THEN
       AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');
       END IF;


       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_Deliverable_CUHK.delete_Deliverable_pre(
         l_deliv_ID,
                 l_object_version_number,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'V')
   THEN
      AMS_Deliverable_VUHK.delete_Deliverable_pre(
         l_deliv_ID,
                 l_object_version_number,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;
   -------------------------------------------------------

       --
       -- API body
       --
     AMS_Deliverable_PVT.Delete_Deliverable(
     p_api_version                => 1.0,
     p_init_msg_list              => FND_API.G_FALSE,
     p_commit                     => p_commit,
     x_return_status              => x_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data,
     p_deliv_id                   => l_deliv_id,
     p_object_version             => l_object_version_number );


       -- Check return status from the above procedure call
       IF x_return_status = FND_API.G_RET_STS_ERROR then
           RAISE FND_API.G_EXC_ERROR;
       elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- End of API body
       --

   -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'C')
   THEN
      AMS_Deliverable_CUHK.delete_Deliverable_post(
         l_deliv_ID,
                 l_object_version_number,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'V')
   THEN
      AMS_Deliverable_VUHK.delete_Deliverable_post(
         l_deliv_ID,
         l_object_version_number,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;
   -------------------------------------------------------


       -- Standard check for p_commit
       IF FND_API.to_Boolean( p_commit )
       THEN
          COMMIT WORK;
       END IF;


       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN
       AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');
       END IF;

       -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
         (p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
       );
 EXCEPTION

    WHEN AMS_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO DELETE_Deliverable_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO DELETE_Deliverable_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO DELETE_Deliverable_PUB;
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
 End Delete_Deliverable;

PROCEDURE Validate_Deliverable(
   p_api_version_number       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   p_validation_mode   IN  VARCHAR2  := JTF_PLSQL_API.g_create,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_deliv_rec         IN  AMS_Deliverable_PVT.deliv_rec_type
)


IS

   l_api_name       CONSTANT VARCHAR2(30) := 'validate_Deliverable';
   l_return_status  VARCHAR2(1);
   l_pvt_deliv_rec  AMS_Deliverable_PVT.deliv_rec_type := p_deliv_rec;


BEGIN

   SAVEPOINT validate_Deliverable_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;


     -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_Deliverable_CUHK.validate_deliverable_pre(
         l_pvt_deliv_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'V')
   THEN
      AMS_Deliverable_VUHK.validate_deliverable_pre(
         l_pvt_deliv_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- call business API

   AMS_Deliverable_PVT.Validate_Deliverable(
      p_api_version    => p_api_version_number,
      p_init_msg_list         => p_init_msg_list, --has done before
      p_validation_level      => p_validation_level,
      p_validation_mode       => p_validation_mode,
      p_deliv_rec             => l_pvt_deliv_rec,
      x_return_status         => l_return_status,
      x_msg_count             => x_msg_count,
      x_msg_data              => x_msg_data
        );


   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;





   -- vertical industry post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'V')
   THEN
      AMS_Deliverable_VUHK.validate_deliverable_post(
         l_pvt_deliv_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- customer post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'C')
   THEN
      AMS_Deliverable_CUHK.validate_deliverable_post(
         l_pvt_deliv_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO validate_Deliverable_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO validate_Deliverable_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO validate_Deliverable_pub;
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

END Validate_Deliverable;


PROCEDURE Lock_Deliverable(
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
         p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2,

     p_deliv_id                   IN  NUMBER,
     p_object_version_number             IN  NUMBER
     )

  IS

 L_API_NAME                  CONSTANT VARCHAR2(30) := 'lock_Deliverable';
 L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;

 l_deliv_id      NUMBER := p_deliv_id ;
 l_object_version_number          NUMBER := p_object_version_number;
 l_return_status    VARCHAR2(1);

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
       AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');


       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
   -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_Deliverable_CUHK.lock_deliverable_pre(
         l_deliv_ID,
                 l_object_version_number,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'V')
   THEN
      AMS_Deliverable_VUHK.lock_Deliverable_pre(
         l_deliv_ID,
                 l_object_version_number,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;
       --
       -- API body
       --
     -- Calling Private package: Create_Deliverable
     -- Hint: Primary key needs to be returned

      AMS_Deliverable_PVT.Lock_Deliverable(
      p_api_version        => 1.0,
      p_init_msg_list              => FND_API.G_FALSE,
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data,
      p_deliv_id     => l_deliv_id,
      p_object_version             => l_object_version_number);


       -- Check return status from the above procedure call
       IF x_return_status = FND_API.G_RET_STS_ERROR then
           RAISE FND_API.G_EXC_ERROR;
       elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- End of API body.
       --
            -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'C')
   THEN
      AMS_Deliverable_CUHK.lock_Deliverable_post(
         l_deliv_ID,
                 l_object_version_number,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'V')
   THEN
      AMS_Deliverable_VUHK.lock_Deliverable_post(
         l_deliv_ID,
                 l_object_version_number,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;
       --

       -- Debug Message
       AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');

 EXCEPTION

    WHEN AMS_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
  AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO LOCK_Deliverable_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO LOCK_Deliverable_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO LOCK_Deliverable_PUB;
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
 End Lock_Deliverable;


END AMS_Deliverable_PUB;

/
