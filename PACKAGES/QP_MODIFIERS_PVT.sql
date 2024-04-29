--------------------------------------------------------
--  DDL for Package QP_MODIFIERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_MODIFIERS_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXVMLSS.pls 120.1 2005/06/15 00:27:08 appldev  $ */

--  Start of Comments
--  API name    Process_Modifiers
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Process_Modifiers
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type :=
                                        QP_GLOBALS.G_MISS_CONTROL_REC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIER_LIST_REC
,   p_old_MODIFIER_LIST_rec         IN  QP_Modifiers_PUB.Modifier_List_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIER_LIST_REC
,   p_MODIFIERS_tbl                 IN  QP_Modifiers_PUB.Modifiers_Tbl_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIERS_TBL
,   p_old_MODIFIERS_tbl             IN  QP_Modifiers_PUB.Modifiers_Tbl_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIERS_TBL
,   p_QUALIFIERS_tbl                IN  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_TBL
,   p_old_QUALIFIERS_tbl            IN  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_TBL
,   p_PRICING_ATTR_tbl              IN  QP_Modifiers_PUB.Pricing_Attr_Tbl_Type :=
                                        QP_Modifiers_PUB.G_MISS_PRICING_ATTR_TBL
,   p_old_PRICING_ATTR_tbl          IN  QP_Modifiers_PUB.Pricing_Attr_Tbl_Type :=
                                        QP_Modifiers_PUB.G_MISS_PRICING_ATTR_TBL
,   x_MODIFIER_LIST_rec             OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Modifier_List_Rec_Type
,   x_MODIFIERS_tbl                 OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Modifiers_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Pricing_Attr_Tbl_Type
);

--  Start of Comments
--  API name    Lock_Modifiers
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Lock_Modifiers
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIER_LIST_REC
,   p_MODIFIERS_tbl                 IN  QP_Modifiers_PUB.Modifiers_Tbl_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIERS_TBL
,   p_QUALIFIERS_tbl                IN  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_TBL
,   p_PRICING_ATTR_tbl              IN  QP_Modifiers_PUB.Pricing_Attr_Tbl_Type :=
                                        QP_Modifiers_PUB.G_MISS_PRICING_ATTR_TBL
,   x_MODIFIER_LIST_rec             OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Modifier_List_Rec_Type
,   x_MODIFIERS_tbl                 OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Modifiers_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Pricing_Attr_Tbl_Type
);

--  Start of Comments
--  API name    Get_Modifiers
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Get_Modifiers
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_list_header_id                IN  NUMBER
,   x_MODIFIER_LIST_rec             OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Modifier_List_Rec_Type
,   x_MODIFIERS_tbl                 OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Modifiers_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Pricing_Attr_Tbl_Type
);

END QP_Modifiers_PVT;

 

/
