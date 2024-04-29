--------------------------------------------------------
--  DDL for Package IBE_PROD_RELATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_PROD_RELATION_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVCRLS.pls 120.0.12010000.1 2008/07/28 11:37:56 appldev ship $ */

G_PKG_NAME            CONSTANT VARCHAR2(30) := 'IBE_Prod_Relation_PVT';
L_VIEW_APPLICATION_ID CONSTANT NUMBER       := 0;
L_ORGANIZATION_ID     CONSTANT NUMBER       := FND_PROFILE.Value_Specific('IBE_ITEM_VALIDATION_ORGANIZATION', NULL, NULL, 671);

PROCEDURE Insert_Relationship(
   p_api_version       IN  NUMBER                     ,
   p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status     OUT NOCOPY VARCHAR2                   ,
   x_msg_count         OUT NOCOPY NUMBER                     ,
   x_msg_data          OUT NOCOPY VARCHAR2                   ,
   p_rel_type_code     IN  VARCHAR2                   ,
   p_description       IN  VARCHAR2 := NULL           ,
   p_start_date_active IN  DATE     := NULL           ,
   p_end_date_active   IN  DATE     := NULL
);


PROCEDURE Update_Relationship(
   p_api_version   IN  NUMBER                     ,
   p_init_msg_list IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit        IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status OUT NOCOPY VARCHAR2                   ,
   x_msg_count     OUT NOCOPY NUMBER                     ,
   x_msg_data      OUT NOCOPY VARCHAR2                   ,
   p_rel_type_code IN  VARCHAR2                   ,
   p_description   IN  VARCHAR2                   ,
   p_start_date    IN  DATE                       ,
   p_end_date      IN  DATE
);

PROCEDURE Update_Relationship_Detail(
   p_api_version   IN  NUMBER                     ,
   p_init_msg_list IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit        IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status OUT NOCOPY VARCHAR2                   ,
   x_msg_count     OUT NOCOPY NUMBER                     ,
   x_msg_data      OUT NOCOPY VARCHAR2                   ,
   p_rel_type_code IN  VARCHAR2                   ,
   p_meaning       IN  VARCHAR2                   ,
   p_description   IN  VARCHAR2                   ,
   p_start_date    IN  DATE                       ,
   p_end_date      IN  DATE
);

PROCEDURE Delete_Relationships(
   p_api_version       IN  NUMBER                     ,
   p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status     OUT NOCOPY VARCHAR2                   ,
   x_msg_count         OUT NOCOPY NUMBER                     ,
   x_msg_data          OUT NOCOPY VARCHAR2                   ,
   p_rel_type_code_tbl IN  JTF_Varchar2_Table_100
);


PROCEDURE Exclude_Related_Items(
   p_api_version           IN  NUMBER                     ,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status         OUT NOCOPY VARCHAR2                   ,
   x_msg_count             OUT NOCOPY NUMBER                     ,
   x_msg_data              OUT NOCOPY VARCHAR2                   ,
   p_rel_type_code         IN  VARCHAR2                   ,
   p_inventory_item_id_tbl IN  JTF_Number_Table           ,
   p_related_item_id_tbl   IN  JTF_Number_Table
);


PROCEDURE Include_Related_Items(
   p_api_version            IN  NUMBER                     ,
   p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status          OUT NOCOPY VARCHAR2                   ,
   x_msg_count              OUT NOCOPY NUMBER                     ,
   x_msg_data               OUT NOCOPY VARCHAR2                   ,
   p_rel_type_code          IN  VARCHAR2                   ,
   p_inventory_item_id_tbl  IN  JTF_Number_Table           ,
   p_related_item_id_tbl    IN  JTF_Number_Table
);


PROCEDURE Insert_Related_Items_Rows(
   p_rel_type_code      IN VARCHAR2,
   p_rel_rule_id        IN NUMBER  ,
   p_origin_object_type IN VARCHAR2,
   p_dest_object_type   IN VARCHAR2,
   p_origin_object_id   IN NUMBER  ,
   p_dest_object_id     IN NUMBER
);

--Bug 2922902
PROCEDURE Insert_Related_Items_Rows(
   p_rel_type_code      IN VARCHAR2,
   p_rel_rule_id        IN NUMBER  ,
   p_origin_object_type IN VARCHAR2,
   p_dest_object_type   IN VARCHAR2,
   p_origin_object_id   IN NUMBER  ,
   p_dest_object_id     IN NUMBER  ,
   p_organization_id    IN NUMBER
);

PROCEDURE Item_Category_Inserted(
   p_category_id       IN NUMBER,
   p_inventory_item_id IN NUMBER,
   p_organization_id   IN NUMBER DEFAULT NULL --Bug 2922902, 3001591
);


PROCEDURE Item_Section_Inserted(
   p_section_id        IN NUMBER,
   p_inventory_item_id IN NUMBER,
   p_organization_id   IN NUMBER DEFAULT NULL --Bug 2922902, 3001591
);


PROCEDURE Item_Category_Deleted(
   p_category_id       IN NUMBER,
   p_inventory_item_id IN NUMBER,
   p_organization_id   IN NUMBER DEFAULT NULL --Bug 2922902, 3001591
);


PROCEDURE Item_Section_Deleted(
   p_section_id        IN NUMBER,
   p_inventory_item_id IN NUMBER,
   p_organization_id   IN NUMBER DEFAULT NULL --Bug 2922902, 3001591
);


PROCEDURE Category_Deleted(
   p_category_id IN NUMBER
);


PROCEDURE Section_Deleted(
   p_section_id IN NUMBER
);


PROCEDURE Item_Deleted(
   p_organization_id   IN NUMBER,
   p_inventory_item_id IN NUMBER
);


PROCEDURE Remove_Invalid_Exclusions;

END IBE_Prod_Relation_PVT;

/
