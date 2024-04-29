--------------------------------------------------------
--  DDL for Package Body AMS_ITEM_CATEGORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ITEM_CATEGORY_PVT" AS
/* $Header: amsvicab.pls 115.8 2002/11/14 00:55:42 abhola ship $ */

--------------------------------------------------------------
-- PROCEDURE
--    Create_Category_Assignment
--
--------------------------------------------------------------

 AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_Category_Assignment
  (
    p_api_version       IN   NUMBER,
    p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_errorcode         OUT NOCOPY  NUMBER,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_category_id       IN   NUMBER,
    p_category_set_id   IN   NUMBER,
    p_inventory_item_id IN   NUMBER,
    p_organization_id   IN   NUMBER
   )
   IS

    l_api_version            CONSTANT NUMBER       := 1.0;
    l_category_id            NUMBER           := p_category_id ;
    l_category_set_id        NUMBER           := p_category_set_id ;
    l_inventory_item_id      NUMBER           := p_inventory_item_id ;
    l_organization_id        NUMBER           := p_organization_id ;


Cursor Get_owner_id IS
    SELECT item_owner_id
           FROM ams_item_attributes
    WHERE inventory_item_id = p_inventory_item_id
         AND organization_id = p_organization_id;

l_return_status_cue      VARCHAR2(1);
l_owner_id                NUMBER;


 BEGIN

        IF fnd_api.to_boolean (p_init_msg_list) THEN
            fnd_msg_pub.initialize;
        END IF;

        INV_ITEM_CATEGORY_PUB.Create_Category_Assignment
           (p_api_version       =>   l_api_version,
            p_init_msg_list     =>   p_init_msg_list,
            p_commit            =>   p_commit,
            x_return_status     =>   x_return_status,
            x_errorcode         =>   x_errorcode ,
            x_msg_count         =>   x_msg_count,
            x_msg_data          =>   x_msg_data,
            p_category_id       =>   l_category_id,
            p_category_set_id   =>   l_category_set_id,
            p_inventory_item_id =>   l_inventory_item_id,
            p_organization_id   =>   l_organization_id
        );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                         RAISE FND_API.G_EXC_ERROR;

         /***** commented by ABHOLA
          ELSE
            OPEN get_owner_id;
            FETCH get_owner_id INTO l_owner_id;
            CLOSE get_owner_id;

           AMS_ObjectAttribute_PVT.modify_object_attribute(
                 p_api_version        => l_api_version,
                 p_init_msg_list      => FND_API.g_false,
                 p_commit             => FND_API.g_false,
           p_validation_level   => FND_API.g_valid_level_full,
           x_return_status      => l_return_status_cue,
                 x_msg_count          => x_msg_count,
                 x_msg_data           => x_msg_data,
         p_object_type        => 'PROD',
            p_object_id          => l_owner_id ,
            p_attr               => 'PCAT',
            p_attr_defined_flag  => 'Y'
                        );
           ***********************************************/
         END IF;

        IF FND_API.to_boolean(p_commit) THEN
           COMMIT;
        END IF;

    FND_MSG_PUB.Count_AND_Get
    ( p_count           =>      x_msg_count,
      p_data            =>      x_msg_data,
      p_encoded         =>      FND_API.G_FALSE
    );

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_And_Get
       ( p_count => x_msg_count,
         p_data => x_msg_data,
         p_encoded => FND_API.G_FALSE
	);
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_And_Get
       ( p_count => x_msg_count,
         p_data => x_msg_data,
	 p_encoded =>  FND_API.G_FALSE
       );

 END Create_Category_Assignment;


 PROCEDURE Delete_Category_Assignment
  (
    p_api_version       IN   NUMBER,
    p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_errorcode         OUT NOCOPY  NUMBER,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_category_id       IN   NUMBER,
    p_category_set_id   IN   NUMBER,
    p_inventory_item_id IN   NUMBER,
    p_organization_id   IN   NUMBER
   )
   IS

    l_api_version            CONSTANT NUMBER  := 1.0;
    l_category_id            NUMBER           := p_category_id ;
    l_category_set_id        NUMBER           := p_category_set_id ;
    l_inventory_item_id      NUMBER           := p_inventory_item_id ;
    l_organization_id        NUMBER           := p_organization_id ;

Cursor check_item is
   SELECT 1
   FROM mtl_item_categories
   WHERE organization_id = p_organization_id
   AND inventory_item_id = p_inventory_item_id;

Cursor Get_owner_id IS
    SELECT item_owner_id
    FROM ams_item_attributes
    WHERE inventory_item_id = p_inventory_item_id
    AND organization_id = p_organization_id;

l_return_status_cue      VARCHAR2(1);
l_owner_id                NUMBER;
l_dummy number :=0;
l_return_status VARCHAR2(1) ;
l_item_owner_id NUMBER;


  BEGIN

        IF fnd_api.to_boolean (p_init_msg_list) THEN
            fnd_msg_pub.initialize;
        END IF;

        INV_ITEM_CATEGORY_PUB.Delete_Category_Assignment
           (p_api_version       =>   l_api_version,
            p_init_msg_list     =>   p_init_msg_list,
            p_commit            =>   p_commit,
            x_return_status     =>   x_return_status,
            x_errorcode         =>   x_errorcode ,
            x_msg_count         =>   x_msg_count,
            x_msg_data          =>   x_msg_data,
            p_category_id       =>   l_category_id,
            p_category_set_id   =>   l_category_set_id,
            p_inventory_item_id =>   l_inventory_item_id,
            p_organization_id   =>   l_organization_id
        );

        -- ************************************************************
      --    Call for cue card
      -- ************************************************************

      /*************************
      --
      --   commented call to object attr
      --
      OPEN check_item;
        FETCH check_item INTO l_dummy;
      CLOSE check_item;

      OPEN get_owner_id;
       FETCH get_owner_id INTO l_item_owner_id;
      CLOSE get_owner_id;

      IF l_dummy =1 THEN

         AMS_ObjectAttribute_PVT.modify_object_attribute(
              p_api_version        => l_api_version,
              p_init_msg_list      => FND_API.g_false,
              p_commit             => FND_API.g_false,
              p_validation_level   => FND_API.g_valid_level_full,

              x_return_status      => l_return_status,
              x_msg_count          => x_msg_count,
              x_msg_data           => x_msg_data,

              p_object_type        => 'PROD',
              p_object_id          => l_item_owner_id ,
              p_attr               => 'PCAT',
              p_attr_defined_flag  => 'Y'
           );
        ELSE

         AMS_ObjectAttribute_PVT.modify_object_attribute(
              p_api_version        => l_api_version,
              p_init_msg_list      => FND_API.g_false,
              p_commit             => FND_API.g_false,
              p_validation_level   => FND_API.g_valid_level_full,

              x_return_status      => l_return_status,
              x_msg_count          => x_msg_count,
              x_msg_data           => x_msg_data,

              p_object_type        => 'PROD',
              p_object_id          => l_item_owner_id ,
              p_attr               => 'PCAT',
              p_attr_defined_flag  => 'N'
           );

       END IF;
       *********************************************/

        IF FND_API.to_boolean(p_commit) THEN
           COMMIT;
        END IF;

        FND_MSG_PUB.count_And_Get
       ( p_count => x_msg_count,
         p_data => x_msg_data,
	 p_encoded => FND_API.G_FALSE);


  EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_And_Get
       ( p_count => x_msg_count,
         p_data => x_msg_data,
	 p_encoded =>  FND_API.G_FALSE );
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_And_Get
       ( p_count => x_msg_count,
         p_data => x_msg_data,
	 p_encoded => FND_API.G_FALSE);
  END Delete_Category_Assignment;

END;

/
