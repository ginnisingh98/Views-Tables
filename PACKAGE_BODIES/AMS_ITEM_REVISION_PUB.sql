--------------------------------------------------------
--  DDL for Package Body AMS_ITEM_REVISION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ITEM_REVISION_PUB" AS
/* $Header: amsprevb.pls 115.5 2002/11/11 22:04:50 abhola ship $ */



PROCEDURE Create_Item_Revision
(
   p_api_version             IN   NUMBER
,  p_init_msg_list           IN   VARCHAR2   :=  FND_API.G_FALSE
,  p_commit                  IN   VARCHAR2   :=  FND_API.G_FALSE
,  p_validation_level        IN   NUMBER     :=  FND_API.G_VALID_LEVEL_FULL
,  x_return_status           OUT NOCOPY  VARCHAR2
,  x_msg_count               OUT NOCOPY  NUMBER
,  x_msg_data                OUT NOCOPY  VARCHAR2
,  p_Item_Revision_rec       IN   Item_Revision_rec_type
)
IS

l_Item_Revision_rec    INV_ITEM_REVISION_PUB.Item_Revision_rec_type;
l_api_version                NUMBER ;
l_init_msg_list             VARCHAR2(2000)  ;
l_commit                     VARCHAR2(1)   ;
l_validation_level           NUMBER    ;
l_return_status             VARCHAR2(1)  ;
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(2000);

BEGIN



l_api_version               :=  p_api_version;
l_init_msg_list             :=  p_init_msg_list ;
l_commit                     :=  p_commit  ;
l_validation_level           :=   p_validation_level  ;


   l_Item_Revision_rec.inventory_item_id         :=  p_Item_Revision_rec.inventory_item_id      ;
   l_Item_Revision_rec.organization_id   :=  p_Item_Revision_rec.organization_id      ;
   l_Item_Revision_rec.revision           :=  p_Item_Revision_rec.revision     ;
   l_Item_Revision_rec.description      :=  p_Item_Revision_rec.description     ;
   l_Item_Revision_rec.effectivity_date :=  p_Item_Revision_rec.effectivity_date     ;

   IF  to_char(l_Item_Revision_rec.effectivity_date,'DD-MON-YY') = to_char(sysdate,'DD-MON-YY')
   THEN
     l_Item_Revision_rec.effectivity_date  :=  sysdate+.00001; --which increase one second from a sysdate
   END IF;

   INV_ITEM_REVISION_PUB.Create_Item_Revision
   (
     p_api_version             =>  l_api_version
    ,p_init_msg_list           =>  l_init_msg_list
    ,p_commit                  =>  l_commit
    ,p_validation_level        =>  l_validation_level
    ,x_return_status           =>  x_return_status
    ,x_msg_count               =>  x_msg_count
    ,x_msg_data                =>  x_msg_data
    ,p_Item_Revision_rec       =>  l_Item_Revision_rec
    ) ;

   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
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

END;




PROCEDURE Update_Item_Revision
(
   p_api_version             IN   NUMBER
,  p_init_msg_list           IN   VARCHAR2   :=  FND_API.g_FALSE
,  p_commit                  IN   VARCHAR2   :=  FND_API.g_FALSE
,  p_validation_level        IN   NUMBER     :=  FND_API.g_VALID_LEVEL_FULL
,  x_return_status           OUT NOCOPY  VARCHAR2
,  x_msg_count               OUT NOCOPY  NUMBER
,  x_msg_data                OUT NOCOPY  VARCHAR2
,  p_Item_Revision_rec       IN   Item_Revision_rec_type
)
IS

l_Item_Revision_rec  INV_ITEM_REVISION_PUB.Item_Revision_rec_type;

l_api_version                NUMBER ;
l_init_msg_list             VARCHAR2(2000)  ;
l_commit                     VARCHAR2(1)   ;
l_validation_level           NUMBER    ;
l_return_status             VARCHAR2(1)  ;
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(2000);

BEGIN

l_api_version               :=  p_api_version;
l_init_msg_list             :=  p_init_msg_list ;
l_commit                     :=  p_commit  ;
l_validation_level           :=   p_validation_level  ;


  l_Item_Revision_rec.inventory_item_id  :=  p_Item_Revision_rec.inventory_item_id      ;
  l_Item_Revision_rec.organization_id    :=  p_Item_Revision_rec.organization_id      ;
  l_Item_Revision_rec.revision           :=  p_Item_Revision_rec.revision     ;
  l_Item_Revision_rec.description       :=  p_Item_Revision_rec.description     ;
  l_Item_Revision_rec.effectivity_date  :=  p_Item_Revision_rec.effectivity_date     ;
  l_Item_Revision_rec.object_version_number      :=  p_Item_Revision_rec.object_version_number      ;

 INV_ITEM_REVISION_PUB.update_Item_Revision
(
   p_api_version             =>  l_api_version
,  p_init_msg_list           =>  l_init_msg_list
,  p_commit                  =>  l_commit
,  p_validation_level        =>  l_validation_level
,  x_return_status           =>  x_return_status
,  x_msg_count               =>  x_msg_count
,  x_msg_data                =>  x_msg_data
,  p_Item_Revision_rec       =>  l_Item_Revision_rec
) ;

   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
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

END;



PROCEDURE Delete_Item_Revision
(
   p_api_version             IN   NUMBER
,  p_init_msg_list           IN   VARCHAR2   :=  FND_API.g_FALSE
,  p_commit                  IN   VARCHAR2   :=  FND_API.g_FALSE
,  p_validation_level        IN   NUMBER     :=  FND_API.g_VALID_LEVEL_FULL
,  x_return_status           OUT NOCOPY  VARCHAR2
,  x_msg_count               OUT NOCOPY  NUMBER
,  x_msg_data                OUT NOCOPY  VARCHAR2
,  p_inventory_item_id       IN   NUMBER
,  p_organization_id         IN   NUMBER
,  p_revision                IN   VARCHAR2
,  p_object_version_number   IN   NUMBER
)
IS


l_api_version                NUMBER ;
l_init_msg_list             VARCHAR2(2000)  ;
l_commit                     VARCHAR2(1)   ;
l_validation_level           NUMBER    ;
l_return_status             VARCHAR2(1)  ;
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(2000);


 l_inventory_item_id     NUMBER     ;
  l_organization_id      NUMBER     ;
  l_revision           VARCHAR2(3)     ;
  l_object_version_number        NUMBER     ;

BEGIN

  l_api_version               :=  p_api_version;
  l_init_msg_list             :=  p_init_msg_list ;
  l_commit                     :=  p_commit  ;
  l_validation_level           :=   p_validation_level  ;

  l_inventory_item_id    :=  p_inventory_item_id      ;
  l_organization_id      :=  p_organization_id      ;
  l_revision           :=  p_revision     ;
  l_object_version_number        :=  p_object_version_number      ;

 INV_ITEM_REVISION_PUB.delete_Item_Revision
(
   p_api_version             =>  l_api_version
,  p_init_msg_list           =>  l_init_msg_list
,  p_commit                  =>  l_commit
,  p_validation_level        =>  l_validation_level
,  x_return_status           =>  x_return_status
,  x_msg_count               =>  x_msg_count
,  x_msg_data                =>  x_msg_data
,  p_inventory_item_id       =>  l_inventory_item_id
,  p_organization_id         =>  l_organization_id
,  p_revision                =>  l_revision
,  p_object_version_number   =>  l_object_version_number
) ;

   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
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


END;


END AMS_ITEM_REVISION_PUB;

/
