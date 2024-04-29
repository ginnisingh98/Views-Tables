--------------------------------------------------------
--  DDL for Package Body AMS_COLLAB_ASSOC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_COLLAB_ASSOC_PVT" as
/* $Header: amsvcolb.pls 120.0.12000000.2 2007/08/03 12:52:36 amlal ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Collab_assoc_PVT
-- Purpose
--
-- History

-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Collab_assoc_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvconb.pls';
G_module_name constant varchar2(100):='oracle.apps.ams.plsql.'||G_PKG_NAME;

-- Hint: Primary key needs to be returned.
AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);


AMS_LOG_PROCEDURE constant number := FND_LOG.LEVEL_PROCEDURE;
AMS_LOG_EXCEPTION constant Number := FND_LOG.LEVEL_EXCEPTION;
AMS_LOG_STATEMENT constant Number := FND_LOG.LEVEL_STATEMENT;

AMS_LOG_PROCEDURE_ON boolean := AMS_UTILITY_PVT.logging_enabled(AMS_LOG_PROCEDURE);
AMS_LOG_EXCEPTION_ON boolean := AMS_UTILITY_PVT.logging_enabled(AMS_LOG_EXCEPTION);
AMS_LOG_STATEMENT_ON boolean := AMS_UTILITY_PVT.logging_enabled(AMS_LOG_STATEMENT);



PROCEDURE Create_collab_Assoc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_collab_assoc_rec_type               IN   collab_assoc_rec_type,
    x_collab_item_id                   OUT NOCOPY  NUMBER
     )

 IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_collab_Assoc';
   l_full_name		       Constant varchar2(60) := g_pkg_name||'.'||l_api_name;
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_CONTACT_POINT_ID                  NUMBER;
   l_dummy       NUMBER;

   l_cnt_point_rec_type AMS_Cnt_Point_PVT.cnt_point_rec_type ;

   CURSOR c_script_name(p_script_id IN NUMBER)
   IS
   select dscript_name
   from ies_deployed_scripts
   where dscript_id = p_script_id;


   CURSOR c_template_name(p_template_id IN NUMBER)
   IS
   select template_name
   from PRP_templates_vl
   where template_id = p_template_id;

   l_collab_value_name   varchar2(256);

   CURSOR C_assoc_id
   IS
   SELECT association_id
   from ibc_associations
   where association_type_code = 'AMS_COLB'
   and associated_object_val1 =to_char(p_collab_assoc_rec_type.obj_id)
   and associated_object_val2 = p_collab_assoc_rec_type.obj_type;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Create_collab_Assoc_PVT;
   IF (AMS_LOG_PROCEDURE_ON) THEN
      AMS_UTILITY_PVT.debug_message(AMS_LOG_PROCEDURE,G_module_name,l_full_name||':Start');
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('Save point : Create_collab_Assoc_PVT created');
   END IF;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( L_API_VERSION_NUMBER,
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
   IF (AMS_LOG_STATEMENT_ON) THEN
    AMS_UTILITY_PVT.debug_message( AMS_LOG_STATEMENT
				,G_module_name,
    'p_collab_assoc_rec_type.Collab_type'||p_collab_assoc_rec_type.Collab_type);
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_collab_assoc_rec_type.Collab_type is NOT null
   THEN
      IF  p_collab_assoc_rec_type.Collab_type = 'AMS_CONTENT'
      THEN

        IBC_ASSOCIATIONS_GRP.Create_Association (
           p_api_version         => 1.0,
           p_commit              => FND_API.G_FALSE,
           p_assoc_type_code     => 'AMS_COLB',
           p_assoc_object1       => p_collab_assoc_rec_type.obj_id,
           p_assoc_object2       => p_collab_assoc_rec_type.obj_type, -- bug:4384746 created for midtab
           p_content_item_id     => p_collab_assoc_rec_type.collab_assoc_id,
           x_return_status       => x_return_status,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data
           );
      ELSIF ( p_collab_assoc_rec_type.Collab_type = 'INBOUND_SCRIPT'
        OR p_collab_assoc_rec_type.Collab_type = 'AMS_PROPOSAL_TEMPLATE')
      THEN

      l_cnt_point_rec_type.arc_contact_used_by := p_collab_assoc_rec_type.obj_type;
      l_cnt_point_rec_type.act_contact_used_by_id := p_collab_assoc_rec_type.obj_id;
      l_cnt_point_rec_type.contact_point_type := p_collab_assoc_rec_type.Collab_type;
      l_cnt_point_rec_type.contact_point_value := p_collab_assoc_rec_type.collab_assoc_value;
      l_cnt_point_rec_type.contact_point_value_id := p_collab_assoc_rec_type.collab_assoc_id;

      IF (p_collab_assoc_rec_type.collab_assoc_value IS NULL
      OR p_collab_assoc_rec_type.collab_assoc_value = FND_API.g_miss_char)
      THEN

         IF p_collab_assoc_rec_type.Collab_type = 'INBOUND_SCRIPT'
         THEN
            OPEN c_script_name(p_collab_assoc_rec_type.collab_assoc_id);
            FETCH c_script_name INTO l_collab_value_name;
            CLOSE c_script_name;
         ELSIF p_collab_assoc_rec_type.Collab_type = 'AMS_PROPOSAL_TEMPLATE'
         THEN
            OPEN c_template_name(p_collab_assoc_rec_type.collab_assoc_id);
            FETCH c_template_name INTO l_collab_value_name;
            CLOSE c_template_name;
         END IF;
         l_cnt_point_rec_type.contact_point_value := l_collab_value_name;
      END IF;

      AMS_Cnt_Point_PVT.Create_Cnt_Point(
        p_api_version_number     => 1.0,
        p_init_msg_list          => FND_API.G_FALSE,
        p_commit                 => FND_API.G_FALSE,
        p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data,
        p_cnt_point_rec          => l_cnt_point_rec_type,
        x_contact_point_id       =>x_collab_item_id
     );
     END IF;

     IF x_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
     ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
     END IF;

     IF p_collab_assoc_rec_type.Collab_type = 'AMS_CONTENT'
     THEN
       OPEN C_assoc_id;
       FETCH C_assoc_id into x_collab_item_id;
       CLOSE C_assoc_id;
     END IF;

   END IF; -- collab_type
--
-- End of API body
--
      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
   IF (AMS_LOG_PROCEDURE_ON) THEN
      AMS_UTILITY_PVT.debug_message(AMS_LOG_PROCEDURE,G_module_name,l_full_name||':end');
   END IF;

EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Create_collab_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_collab_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Create_collab_Assoc_PVT;
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
End Create_collab_Assoc;

END AMS_Collab_assoc_PVT;

/
