--------------------------------------------------------
--  DDL for Package Body AMS_MULTIMEDIA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_MULTIMEDIA_PVT" as
/* $Header: amsvmulb.pls 115.3 2002/06/11 14:44:58 pkm ship      $ */
-- Start of Comments
-- Package name     : AMS_Multimedia_PVT
-- Purpose          :

-- History          :
-- 12/26/2000     abhola   created.
-- 12-MAY-2002    ABHOLA   removed references to G_USER_ID
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Multimedia_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvmulb.pls';



PROCEDURE Process_Multimedia(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
  p_commit              IN  VARCHAR2 := FND_API.g_false,
  p_validation_level    IN  NUMBER   := FND_API.g_valid_level_full,

  x_return_status       OUT VARCHAR2,
  x_msg_count           OUT NUMBER,
  x_msg_data            OUT VARCHAR2,

  p_multi_rec           IN  multimedia_rec_type )

 IS


 l_api_name                CONSTANT VARCHAR2(50) := 'Process_Multimedia';

 l_multimedia_tbl  IBE_LogicalContent_GRP.obj_lgl_ctnt_tbl_type;

 l_api_version           NUMBER   := p_api_version;
 l_init_msg_list         VARCHAR2(1) := p_init_msg_list;
 l_commit                VARCHAR2(1) := p_commit;
 l_validation_level      NUMBER   := p_validation_level;

 transaction_type VARCHAR2(1);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Process_Multimedia;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
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
     --  AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AMS', 'USER_PROFILE_MISSING');
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      --
      -- get the default image if default falg is 'Y'
      --

      transaction_type := p_multi_rec.create_delete_flag;

      if (p_multi_rec.default_flag = 'Y') then

         transaction_type := FND_API.g_true;

      end if;

      l_multimedia_tbl(1).obj_lgl_ctnt_delete  := transaction_type ;
      l_multimedia_tbl(1).OBJ_lgl_ctnt_id  :=   p_multi_rec.obj_lgl_ctnt_id;
      l_multimedia_tbl(1).Object_Version_Number  :=   p_multi_rec.object_version_number;
      l_multimedia_tbl(1).Object_id  := p_multi_rec.object_id ;
      l_multimedia_tbl(1).Context_id  :=   p_multi_rec.context_id;
      l_multimedia_tbl(1).deliverable_id  :=  p_multi_rec.image_id ;

      -- Call to IBE Procedure
      ------------------------
      IBE_LogicalContent_GRP.save_delete_lgl_ctnt(
		p_api_version         =>   l_api_version,
		p_init_msg_list       =>   l_init_msg_list,
		p_commit              =>   l_commit,
		x_return_status       => x_return_status,
		x_msg_count           => x_msg_count,
		x_msg_data            => x_msg_data,
		p_object_type_code    => p_multi_rec.obj_type_code,
		p_lgl_ctnt_tbl        => l_multimedia_tbl );


      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      -- AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN

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
 END;


End AMS_Multimedia_PVT;

/
