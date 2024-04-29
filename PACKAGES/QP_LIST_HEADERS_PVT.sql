--------------------------------------------------------
--  DDL for Package QP_LIST_HEADERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_LIST_HEADERS_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXVPRLS.pls 120.1 2005/06/15 03:51:33 appldev  $ */

--  Start of Comments
--  API name    Process_Price_List
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

-- Define Global Variables
G_MULTI_CURRENCY_INSTALLED VARCHAR2(5) := NVL(UPPER(fnd_profile.value('QP_MULTI_CURRENCY_INSTALLED')), 'N');

PROCEDURE Process_Price_List
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type :=
                                        QP_GLOBALS.G_MISS_CONTROL_REC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_rec                IN  QP_Price_List_PUB.Price_List_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_REC
,   p_old_PRICE_LIST_rec            IN  QP_Price_List_PUB.Price_List_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_REC
,   p_PRICE_LIST_LINE_tbl           IN  QP_Price_List_PUB.Price_List_Line_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_TBL
,   p_old_PRICE_LIST_LINE_tbl       IN  QP_Price_List_PUB.Price_List_Line_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_TBL
,   p_QUALIFIERS_tbl                IN  Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_QUALIFIERS_TBL
,   p_old_QUALIFIERS_tbl            IN  Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_QUALIFIERS_TBL
,   p_PRICING_ATTR_tbl              IN  QP_Price_List_PUB.Pricing_Attr_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICING_ATTR_TBL
,   p_old_PRICING_ATTR_tbl          IN  QP_Price_List_PUB.Pricing_Attr_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICING_ATTR_TBL
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Tbl_Type
);

--  Start of Comments
--  API name    Lock_Price_List
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

PROCEDURE Lock_Price_List
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_rec                IN  QP_Price_List_PUB.Price_List_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_REC
,   p_PRICE_LIST_LINE_tbl           IN  QP_Price_List_PUB.Price_List_Line_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_TBL
,   p_QUALIFIERS_tbl                IN  Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_QUALIFIERS_TBL
,   p_PRICING_ATTR_tbl              IN  QP_Price_List_PUB.Pricing_Attr_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICING_ATTR_TBL
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Tbl_Type
);

--  Start of Comments
--  API name    Get_Price_List
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

PROCEDURE Get_Price_List
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_list_header_id                IN  NUMBER
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Tbl_Type
);

END QP_LIST_HEADERS_PVT;

 

/
