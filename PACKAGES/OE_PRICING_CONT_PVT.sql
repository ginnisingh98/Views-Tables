--------------------------------------------------------
--  DDL for Package OE_PRICING_CONT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PRICING_CONT_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVPRCS.pls 120.1 2005/06/09 04:45:29 appldev  $ */

--  Start of Comments
--  API name    Process_Pricing_Cont
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

PROCEDURE Process_Pricing_Cont
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type :=
                                        OE_GLOBALS.G_MISS_CONTROL_REC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_CONTRACT_REC
,   p_old_Contract_rec              IN  OE_Pricing_Cont_PUB.Contract_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_CONTRACT_REC
,   p_Agreement_rec                 IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_AGREEMENT_REC
,   p_old_Agreement_rec             IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_AGREEMENT_REC
,   p_Price_LHeader_rec             IN  OE_Price_List_PUB.Price_List_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_List_REC
,   p_old_Price_LHeader_rec         IN  OE_Price_List_PUB.Price_List_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_List_REC
,   p_Discount_Header_rec           IN  OE_Pricing_Cont_PUB.Discount_Header_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_DISCOUNT_HEADER_REC
,   p_old_Discount_Header_rec       IN  OE_Pricing_Cont_PUB.Discount_Header_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_DISCOUNT_HEADER_REC
,   p_Price_LLine_tbl               IN  OE_Price_List_PUB.Price_List_Line_Tbl_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_List_Line_TBL
,   p_old_Price_LLine_tbl           IN  OE_Price_List_PUB.Price_List_Line_Tbl_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_List_Line_TBL
,   p_Discount_Cust_tbl             IN  OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_DISCOUNT_CUST_TBL
,   p_old_Discount_Cust_tbl         IN  OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_DISCOUNT_CUST_TBL
,   p_Discount_Line_tbl             IN  OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_DISCOUNT_LINE_TBL
,   p_old_Discount_Line_tbl         IN  OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_DISCOUNT_LINE_TBL
,   p_Price_Break_tbl               IN  OE_Pricing_Cont_PUB.Price_Break_Tbl_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_PRICE_BREAK_TBL
,   p_old_Price_Break_tbl           IN  OE_Pricing_Cont_PUB.Price_Break_Tbl_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_PRICE_BREAK_TBL
,   x_Contract_rec                  OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Contract_Rec_Type
,   x_Agreement_rec                 OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Agreement_Rec_Type
,   x_Price_LHeader_rec             OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Rec_Type
,   x_Discount_Header_rec           OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Discount_Header_Rec_Type
,   x_Price_LLine_tbl               OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_Discount_Cust_tbl             OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type
,   x_Discount_Line_tbl             OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type
,   x_Price_Break_tbl               OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Price_Break_Tbl_Type
);

--  Start of Comments
--  API name    Lock_Pricing_Cont
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

PROCEDURE Lock_Pricing_Cont
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_CONTRACT_REC
,   p_Agreement_rec                 IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_AGREEMENT_REC
,   p_Price_LHeader_rec             IN  OE_Price_List_PUB.Price_List_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_List_REC
,   p_Discount_Header_rec           IN  OE_Pricing_Cont_PUB.Discount_Header_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_DISCOUNT_HEADER_REC
,   p_Price_LLine_tbl               IN  OE_Price_List_PUB.Price_List_Line_Tbl_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_List_Line_TBL
,   p_Discount_Cust_tbl             IN  OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_DISCOUNT_CUST_TBL
,   p_Discount_Line_tbl             IN  OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_DISCOUNT_LINE_TBL
,   p_Price_Break_tbl               IN  OE_Pricing_Cont_PUB.Price_Break_Tbl_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_PRICE_BREAK_TBL
,   x_Contract_rec                  OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Contract_Rec_Type
,   x_Agreement_rec                 OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Agreement_Rec_Type
,   x_Price_LHeader_rec             OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Rec_Type
,   x_Discount_Header_rec           OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Discount_Header_Rec_Type
,   x_Price_LLine_tbl               OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_Discount_Cust_tbl             OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type
,   x_Discount_Line_tbl             OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type
,   x_Price_Break_tbl               OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Price_Break_Tbl_Type
);

--  Start of Comments
--  API name    Get_Pricing_Cont
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

PROCEDURE Get_Pricing_Cont
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_pricing_contract_id           IN  NUMBER
,   p_name		            IN  VARCHAR2
,   x_Contract_rec                  OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Contract_Rec_Type
,   x_Agreement_rec                 OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Agreement_Rec_Type
,   x_Price_LHeader_rec             OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Rec_Type
,   x_Discount_Header_rec           OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Discount_Header_Rec_Type
,   x_Price_LLine_tbl               OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_Discount_Cust_tbl             OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type
,   x_Discount_Line_tbl             OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type
,   x_Price_Break_tbl               OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Price_Break_Tbl_Type
);


/*Included this procedure in public to be used by vgulati for his upgrade script to upgrade agreements -- spgopal*/

PROCEDURE Create_Agreement_Qualifier
			(p_list_header_id IN NUMBER,
			 p_old_list_header_id IN NUMBER,
			 p_Agreement_id IN NUMBER,
			 p_operation IN VARCHAR2,
			 x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

END OE_Pricing_Cont_PVT;

 

/
