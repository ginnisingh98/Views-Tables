--------------------------------------------------------
--  DDL for Package QP_PRICE_LIST_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_PRICE_LIST_GRP" AUTHID CURRENT_USER AS
/* $Header: QPXGPRLS.pls 120.1 2005/06/10 01:45:24 appldev  $ */

--  Start of Comments
--  API name    Process_Price_List
--  Type        Group
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

PROCEDURE Process_Price_List
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_rec                IN  QP_Price_List_PUB.Price_List_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_REC
,   p_PRICE_LIST_val_rec            IN  QP_Price_List_PUB.Price_List_Val_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_VAL_REC
,   p_PRICE_LIST_LINE_tbl           IN  QP_Price_List_PUB.Price_List_Line_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_TBL
,   p_PRICE_LIST_LINE_val_tbl       IN  QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_VAL_TBL
,   p_QUALIFIERS_tbl                IN  Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_QUALIFIERS_TBL
,   p_QUALIFIERS_val_tbl            IN  Qp_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_QUALIFIERS_VAL_TBL
,   p_PRICING_ATTR_tbl              IN  QP_Price_List_PUB.Pricing_Attr_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICING_ATTR_TBL
,   p_PRICING_ATTR_val_tbl          IN  QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICING_ATTR_VAL_TBL
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type
,   x_PRICE_LIST_val_rec            OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Val_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_PRICE_LIST_LINE_val_tbl       OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type
,   x_QUALIFIERS_val_tbl            OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Tbl_Type
,   x_PRICING_ATTR_val_tbl          OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type
);

--  Start of Comments
--  API name    Lock_Price_List
--  Type        Public
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
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_rec                IN  QP_Price_List_PUB.Price_List_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_REC
,   p_PRICE_LIST_val_rec            IN  QP_Price_List_PUB.Price_List_Val_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_VAL_REC
,   p_PRICE_LIST_LINE_tbl           IN  QP_Price_List_PUB.Price_List_Line_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_TBL
,   p_PRICE_LIST_LINE_val_tbl       IN  QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_VAL_TBL
,   p_QUALIFIERS_tbl                IN  Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_QUALIFIERS_TBL
,   p_QUALIFIERS_val_tbl            IN  Qp_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_QUALIFIERS_VAL_TBL
,   p_PRICING_ATTR_tbl              IN  QP_Price_List_PUB.Pricing_Attr_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICING_ATTR_TBL
,   p_PRICING_ATTR_val_tbl          IN  QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICING_ATTR_VAL_TBL
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type
,   x_PRICE_LIST_val_rec            OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Val_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_PRICE_LIST_LINE_val_tbl       OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type
,   x_QUALIFIERS_val_tbl            OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Tbl_Type
,   x_PRICING_ATTR_val_tbl          OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type
);

--  Start of Comments
--  API name    Get_Price_List
--  Type        Public
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
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_list_header_id                IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_list_header                   IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type
,   x_PRICE_LIST_val_rec            OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Val_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_PRICE_LIST_LINE_val_tbl       OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type
,   x_QUALIFIERS_val_tbl            OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Tbl_Type
,   x_PRICING_ATTR_val_tbl          OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type
);

END QP_Price_List_GRP;

 

/
