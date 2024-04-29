--------------------------------------------------------
--  DDL for Package ASO_SALES_CREDIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_SALES_CREDIT_PVT" AUTHID CURRENT_USER AS
/* $Header: asovscas.pls 120.1 2005/06/29 12:45:02 appldev ship $ */
-- Package name     : ASO_SALES_CREDIT_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


PROCEDURE Allocate_Sales_Credits
(
    P_Api_Version_Number  IN   NUMBER,
    P_Init_Msg_List       IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit              IN   VARCHAR2     := FND_API.G_FALSE,
    p_control_rec         IN   ASO_QUOTE_PUB.SALES_ALLOC_CONTROL_REC_TYPE
                                            :=  ASO_QUOTE_PUB.G_MISS_SALES_ALLOC_CONTROL_REC,
    P_Qte_Header_Rec      IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Qte_Header_Rec      OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Return_Status       OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count           OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data            OUT NOCOPY /* file.sql.39 change */  VARCHAR2
);


PROCEDURE Get_Credits
(
    P_Api_Version_Number  IN   NUMBER       := 1.0,
    P_Init_Msg_List       IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Header_Rec      IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Return_Status       OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count           OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data            OUT NOCOPY /* file.sql.39 change */  VARCHAR2
);


END ASO_SALES_CREDIT_PVT;

 

/
