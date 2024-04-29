--------------------------------------------------------
--  DDL for Package Body AMS_ITEM_SECTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ITEM_SECTION_PVT" as
/* $Header: amsvpseb.pls 115.4 2002/05/29 04:15:23 pkm ship      $ */
-- Start of Comments
-- Package name     : AMS_item_section_PVT
-- Purpose          :

-- History          :
-- 01/22/2001     musman   created.
-- 17-MAY-2002    abhola   removed references to G_USER_ID
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_item_section_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvmulb.pls';


PROCEDURE create_item_sec_assoc
(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
  p_commit              IN  VARCHAR2 := FND_API.g_false,
  p_validation_level    IN  NUMBER   := FND_API.g_valid_level_full,

  x_return_status       OUT VARCHAR2,
  x_msg_count           OUT NUMBER,
  x_msg_data            OUT VARCHAR2,

  p_section_rec         IN  section_rec_type

  )

 IS


 l_api_name                CONSTANT VARCHAR2(50) := 'create_item_sec_assoc';


 l_section_id_tbl      JTF_NUMBER_TABLE ;
 l_start_date_tbl      JTF_DATE_TABLE;
 l_end_date_tbl        JTF_DATE_TABLE;

 l_sort_order_tbl                 JTF_NUMBER_TABLE :=JTF_NUMBER_TABLE() ;
 l_association_reason_code_tbl    JTF_VARCHAR2_TABLE_300 := JTF_VARCHAR2_TABLE_300() ;
 x_section_id_tbl                 JTF_NUMBER_TABLE :=  JTF_NUMBER_TABLE();



 l_api_version           NUMBER   := p_api_version;
 l_init_msg_list         VARCHAR2(1) := p_init_msg_list;
 l_commit                VARCHAR2(1) := p_commit;
 l_validation_level      NUMBER   := p_validation_level;

 l_dup_return_status     VARCHAR2(1);


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Create_Item_Sec_Assoc;

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
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


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


       l_section_id_tbl := JTF_NUMBER_TABLE(1);
       l_section_id_tbl(1)  := p_section_rec.section_id;

       AMS_UTILITY_PVT.debug_message(l_api_name || ' the l_section_id_tbl(1):' ||l_section_id_tbl(1));
       l_start_date_tbl  :=  JTF_DATE_TABLE();
       l_start_date_tbl.extend();
       l_start_date_tbl(1)  := sysdate; --p_section_rec.start_date

       l_end_date_tbl    :=  JTF_DATE_TABLE();
       l_end_date_tbl.extend();
       l_end_date_tbl(1)    := p_section_rec.end_date;

       l_association_reason_code_tbl.extend();
       x_section_id_tbl.extend();
       l_sort_order_tbl.extend();

      -- Call to IBE Procedure
      ------------------------
      Ibe_dsp_hierarchy_setup_pvt.Associate_Sections_To_Item
      (  p_api_version                  =>   l_api_version
      ,  p_init_msg_list                =>   l_init_msg_list
      ,  p_commit                       =>   l_commit
      ,  p_validation_level             =>   l_validation_level
      ,  p_inventory_item_id            =>   p_section_rec.inventory_item_id
      ,  p_organization_id              =>   p_section_rec.organization_id
      ,  p_section_ids                  =>   l_section_id_tbl
      ,  p_start_date_actives           =>   l_start_date_tbl
      ,  p_end_date_actives             =>   l_end_date_tbl
      ,  p_sort_orders                  =>   l_sort_order_tbl
      ,  p_association_reason_codes     =>   l_association_reason_code_tbl
      ,  x_section_item_ids             =>   x_section_id_tbl
      ,  x_duplicate_association_status =>   l_dup_return_status
      ,  x_return_status                =>   x_return_status
      ,  x_msg_count                    =>   x_msg_count
      ,  x_msg_data                     =>   x_msg_data
      );

      IF x_return_status  =FND_API.G_RET_STS_UNEXP_ERROR
      THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      ELSIF x_return_status  =FND_API.G_RET_STS_ERROR
      OR l_dup_return_status  =FND_API.G_RET_STS_ERROR
      THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
       AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Create_Item_Sec_Assoc;
     x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Item_Sec_Assoc;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Item_Sec_Assoc;
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
 END create_item_sec_assoc;

 ---------------------------------------------------------------------
-- PROCEDURE
--    delete_item_sec_assoc
--
---------------------------------------------------------------------

PROCEDURE Delete_item_sec_assoc
(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
  p_commit              IN  VARCHAR2 := FND_API.g_false,
  p_validation_level    IN  NUMBER   := FND_API.g_valid_level_full,

  x_return_status       OUT VARCHAR2,
  x_msg_count           OUT NUMBER,
  x_msg_data            OUT VARCHAR2,

  p_section_rec         IN  section_rec_type

  )

  IS
    l_api_name                CONSTANT VARCHAR2(50) := 'Delete_item_sec_assoc';

    l_inv_id_tbl          JTF_NUMBER_TABLE :=JTF_NUMBER_TABLE(1);
    l_org_id_tbl          JTF_NUMBER_TABLE :=JTF_NUMBER_TABLE(1);
    l_section_id_tbl      JTF_NUMBER_TABLE :=JTF_NUMBER_TABLE(1);

    l_api_version           NUMBER   := p_api_version;
    l_init_msg_list         VARCHAR2(1) := p_init_msg_list;
    l_commit                VARCHAR2(1) := p_commit;
    l_validation_level      NUMBER   := p_validation_level;



BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Delete_item_sec_assoc;

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

       l_section_id_tbl(1)  := p_section_rec.section_id;
       l_inv_id_tbl(1)      := p_section_rec.inventory_item_id;
       l_org_id_tbl(1)      := p_section_rec.organization_id;

      -- Call to IBE Procedure
      ------------------------
      Ibe_dsp_hierarchy_setup_pvt.Disassociate_Scts_To_Itms
      (
         p_api_version             =>   l_api_version
      ,  p_init_msg_list           =>   l_init_msg_list
      ,  p_commit                  =>   l_commit
      ,  p_validation_level        =>   l_validation_level
      ,  p_section_ids             =>   l_section_id_tbl
      ,  p_inventory_item_ids      =>   l_inv_id_tbl
      ,  p_organization_ids        =>   l_org_id_tbl
      ,  x_return_status           =>   x_return_status
      ,  x_msg_count               =>   x_msg_count
      ,  x_msg_data                =>   x_msg_data
      );


      IF x_return_status  =FND_API.G_RET_STS_UNEXP_ERROR
      THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF x_return_status  =FND_API.G_RET_STS_ERROR
      THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


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
     ROLLBACK TO Delete_item_sec_assoc;
     x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_item_sec_assoc;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_item_sec_assoc;
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
 END Delete_item_sec_assoc;




End AMS_item_section_PVT;

/
