--------------------------------------------------------
--  DDL for Package IBE_SHOP_LIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_SHOP_LIST_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVQSLS.pls 120.1 2005/06/10 00:16:43 appldev  $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBE_Shop_List_PVT';

/*
 * Types declaration for Shopping List Header
 */
TYPE SL_Header_Rec_Type IS RECORD(
   shp_list_id            NUMBER        := FND_API.G_MISS_NUM ,
   request_id             NUMBER        := FND_API.G_MISS_NUM ,
   program_application_id NUMBER        := FND_API.G_MISS_NUM ,
   program_id             NUMBER        := FND_API.G_MISS_NUM ,
   program_update_date    DATE          := FND_API.G_MISS_DATE,
   object_version_number  NUMBER        := FND_API.G_MISS_NUM ,
   created_by             NUMBER        := FND_API.G_MISS_NUM ,
   creation_date          DATE          := FND_API.G_MISS_DATE,
   last_updated_by        NUMBER        := FND_API.G_MISS_NUM ,
   last_update_date       DATE          := FND_API.G_MISS_DATE,
   last_update_login      NUMBER        := FND_API.G_MISS_NUM ,
   party_id               NUMBER        := FND_API.G_MISS_NUM ,
   cust_account_id        NUMBER        := FND_API.G_MISS_NUM ,
   shopping_list_name     VARCHAR2(120) := FND_API.G_MISS_CHAR,
   description            VARCHAR2(240) := FND_API.G_MISS_CHAR,
   attribute_category     VARCHAR2(30)  := FND_API.G_MISS_CHAR,
   attribute1             VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute2             VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute3             VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute4             VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute5             VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute6             VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute7             VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute8             VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute9             VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute10            VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute11            VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute12            VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute13            VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute14            VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute15            VARCHAR2(150) := FND_API.G_MISS_CHAR,
   org_id                 NUMBER        := FND_API.G_MISS_NUM
);

G_MISS_SL_HEADER_REC    SL_Header_Rec_Type;

TYPE SL_Header_Tbl_Type IS TABLE OF SL_Header_Rec_Type
                           INDEX BY BINARY_INTEGER;

G_MISS_SL_HEADER_TBL    SL_Header_Tbl_Type;

/*
 * Types declaration for Shopping List Line
 */
TYPE SL_Line_Rec_Type IS RECORD(
   operation_code              VARCHAR2(30)  := FND_API.G_MISS_CHAR,
   shp_list_item_id            NUMBER        := FND_API.G_MISS_NUM ,
   object_version_number       NUMBER        := FND_API.G_MISS_NUM ,
   creation_date               DATE          := FND_API.G_MISS_DATE,
   created_by                  NUMBER        := FND_API.G_MISS_NUM ,
   last_updated_by             NUMBER        := FND_API.G_MISS_NUM ,
   last_update_date            DATE          := FND_API.G_MISS_DATE,
   last_update_login           NUMBER        := FND_API.G_MISS_NUM ,
   request_id                  NUMBER        := FND_API.G_MISS_NUM ,
   program_id                  NUMBER        := FND_API.G_MISS_NUM ,
   program_application_id      NUMBER        := FND_API.G_MISS_NUM ,
   program_update_date         DATE          := FND_API.G_MISS_DATE,
   shp_list_id                 NUMBER        := FND_API.G_MISS_NUM ,
   inventory_item_id           NUMBER        := FND_API.G_MISS_NUM ,
   organization_id             NUMBER        := FND_API.G_MISS_NUM ,
   uom_code                    VARCHAR2(30)  := FND_API.G_MISS_CHAR,
   quantity                    NUMBER        := FND_API.G_MISS_NUM ,
   config_header_id            NUMBER        := FND_API.G_MISS_NUM ,
   config_revision_num         NUMBER        := FND_API.G_MISS_NUM ,
   complete_configuration_flag VARCHAR2(3)   := FND_API.G_MISS_CHAR,
   valid_configuration_flag    VARCHAR2(3)   := FND_API.G_MISS_CHAR,
   item_type_code              VARCHAR2(30)  := FND_API.G_MISS_CHAR,
   attribute_category          VARCHAR2(30)  := FND_API.G_MISS_CHAR,
   attribute1                  VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute2                  VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute3                  VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute4                  VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute5                  VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute6                  VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute7                  VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute8                  VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute9                  VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute10                 VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute11                 VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute12                 VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute13                 VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute14                 VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute15                 VARCHAR2(150) := FND_API.G_MISS_CHAR,
   org_id                      NUMBER        := FND_API.G_MISS_NUM
);

G_MISS_SL_LINE_REC    SL_Line_Rec_Type;

TYPE SL_Line_Tbl_Type IS TABLE OF SL_Line_Rec_Type
                         INDEX BY BINARY_INTEGER;

G_MISS_SL_LINE_TBL    SL_Line_Tbl_Type;


/*
 * Types declaration for Shopping List Line Relationship
 */
TYPE SL_Line_Rel_Rec_Type IS RECORD(
   operation_code           VARCHAR2(30) := FND_API.G_MISS_CHAR,
   shlitem_rel_id           NUMBER       := FND_API.G_MISS_NUM ,
   request_id               NUMBER       := FND_API.G_MISS_NUM ,
   program_application_id   NUMBER       := FND_API.G_MISS_NUM ,
   program_id               NUMBER       := FND_API.G_MISS_NUM ,
   program_update_date      DATE         := FND_API.G_MISS_DATE,
   object_version_number    NUMBER       := FND_API.G_MISS_NUM ,
   created_by               NUMBER       := FND_API.G_MISS_NUM ,
   creation_date            DATE         := FND_API.G_MISS_DATE,
   last_updated_by          NUMBER       := FND_API.G_MISS_NUM ,
   last_update_date         DATE         := FND_API.G_MISS_DATE,
   last_update_login        NUMBER       := FND_API.G_MISS_NUM ,
   shp_list_item_id         NUMBER       := FND_API.G_MISS_NUM ,
   line_index               NUMBER       := FND_API.G_MISS_NUM ,
   related_shp_list_item_id NUMBER       := FND_API.G_MISS_NUM ,
   related_line_index       NUMBER       := FND_API.G_MISS_NUM ,
   relationship_type_code   VARCHAR2(30) := FND_API.G_MISS_CHAR
);

G_MISS_SL_LINE_REL_REC    SL_Line_Rel_Rec_Type;

TYPE SL_Line_Rel_Tbl_Type IS TABLE OF SL_Line_Rel_Rec_Type
                             INDEX BY BINARY_INTEGER;

G_MISS_SL_LINE_REL_TBL    SL_Line_Rel_Tbl_Type;


PROCEDURE Delete(
   p_api_version     IN  NUMBER   := 1              ,
   p_init_msg_list   IN  VARCHAR2 := FND_API.G_TRUE ,
   p_commit          IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status   OUT NOCOPY VARCHAR2                   ,
   x_msg_count       OUT NOCOPY NUMBER                     ,
   x_msg_data        OUT NOCOPY VARCHAR2                   ,
   p_shop_list_ids   IN  jtf_number_table           ,
   p_obj_ver_numbers IN  jtf_number_table
);


PROCEDURE Delete_All_Lines(
   p_api_version     IN  NUMBER   := 1              ,
   p_init_msg_list   IN  VARCHAR2 := FND_API.G_TRUE ,
   p_commit          IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status   OUT NOCOPY VARCHAR2                   ,
   x_msg_count       OUT NOCOPY NUMBER                     ,
   x_msg_data        OUT NOCOPY VARCHAR2                   ,
   p_shop_list_ids   IN  jtf_number_table           ,
   p_obj_ver_numbers IN  jtf_number_table
);


PROCEDURE Delete_Lines(
   p_api_version         IN  NUMBER   := 1              ,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_TRUE ,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status       OUT NOCOPY VARCHAR2                   ,
   x_msg_count           OUT NOCOPY NUMBER                     ,
   x_msg_data            OUT NOCOPY VARCHAR2                   ,
   p_shop_list_line_ids  IN  jtf_number_table           ,
   p_obj_ver_numbers     IN  jtf_number_table
);


PROCEDURE Save(
   p_api_version       IN  NUMBER   := 1                                 ,
   p_init_msg_list     IN  VARCHAR2 := FND_API.G_TRUE                    ,
   p_commit            IN  VARCHAR2 := FND_API.G_FALSE                   ,
   x_return_status     OUT NOCOPY VARCHAR2                                      ,
   x_msg_count         OUT NOCOPY NUMBER                                        ,
   x_msg_data          OUT NOCOPY VARCHAR2                                      ,
   p_combine_same_item IN  VARCHAR2 := FND_API.G_MISS_CHAR               ,
   p_sl_header_rec     IN  SL_Header_Rec_Type                            ,
   p_sl_line_tbl       IN  SL_Line_Tbl_Type     := G_MISS_SL_LINE_TBL    ,
   p_sl_line_rel_tbl   IN  SL_Line_Rel_Tbl_Type := G_MISS_SL_LINE_REL_TBL,
   x_sl_header_id      OUT NOCOPY NUMBER
);


PROCEDURE Save_List_From_Items(
   p_api_version       IN  NUMBER   := 1                  ,
   p_init_msg_list     IN  VARCHAR2 := FND_API.G_TRUE     ,
   p_commit            IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status     OUT NOCOPY VARCHAR2                       ,
   x_msg_count         OUT NOCOPY NUMBER                         ,
   x_msg_data          OUT NOCOPY VARCHAR2                       ,
   p_sl_line_ids       IN  jtf_number_table               ,
   p_sl_line_ovns      IN  jtf_number_table := NULL       ,
   p_mode              IN  VARCHAR2 := 'MERGE'            ,
   p_combine_same_item IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_sl_header_rec     IN  SL_Header_Rec_Type             ,
   x_sl_header_id      OUT NOCOPY NUMBER
);

PROCEDURE Save_List_From_Quote(
   p_api_version              IN  NUMBER   := 1                  ,
   p_init_msg_list            IN  VARCHAR2 := FND_API.G_TRUE     ,
   p_commit                   IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status            OUT NOCOPY VARCHAR2                       ,
   x_msg_count                OUT NOCOPY NUMBER                         ,
   x_msg_data                 OUT NOCOPY VARCHAR2                       ,
   p_quote_header_id          IN  NUMBER                         ,
   p_quote_retrieval_number   IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_minisite_id              IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_last_update_date         IN  DATE     := FND_API.G_MISS_DATE,
   p_mode                     IN  VARCHAR2 := 'MERGE'            ,
   p_combine_same_item        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_sl_header_rec            IN  SL_Header_Rec_Type             ,
   x_sl_header_id             OUT NOCOPY NUMBER
);


PROCEDURE Save_Quote_From_List_Items(
   p_api_version               IN  NUMBER   := 1                    ,
   p_init_msg_list             IN  VARCHAR2 := FND_API.G_TRUE       ,
   p_commit                    IN  VARCHAR2 := FND_API.G_FALSE      ,
   x_return_status             OUT NOCOPY VARCHAR2                         ,
   x_msg_count                 OUT NOCOPY NUMBER                           ,
   x_msg_data                  OUT NOCOPY VARCHAR2                         ,
   p_sl_line_ids               IN  jtf_number_table                 ,
   p_sl_line_ovns              IN  jtf_number_table := NULL         ,
   p_quote_retrieval_number    IN  NUMBER   := FND_API.G_MISS_NUM   ,
   p_recipient_party_id        IN  NUMBER   := FND_API.G_MISS_NUM   ,
   p_recipient_cust_account_id IN  NUMBER   := FND_API.G_MISS_NUM   ,
   p_minisite_id               IN  NUMBER   := FND_API.G_MISS_NUM   ,
   p_mode                      IN  VARCHAR2 := 'MERGE'              ,
   p_combine_same_item         IN  VARCHAR2 := FND_API.G_MISS_CHAR  ,
   p_control_rec               IN  ASO_Quote_Pub.control_rec_type   ,
   p_q_header_rec              IN  ASO_Quote_Pub.qte_header_rec_type,
   p_password                  IN  VARCHAR2 := FND_API.G_MISS_CHAR  ,
   p_email_address             IN  jtf_varchar2_table_2000 := NULL  ,
   p_privilege_type            IN  jtf_varchar2_table_100  := NULL  ,
   p_url                       IN  VARCHAR2                         ,
   p_comments                  IN  VARCHAR2                         ,
   p_promocode                 IN  VARCHAR2 := FND_API.G_MISS_CHAR  ,
   x_q_header_id               OUT NOCOPY NUMBER
);

END IBE_Shop_List_PVT;


 

/
