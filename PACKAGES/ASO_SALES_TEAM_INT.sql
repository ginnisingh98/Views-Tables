--------------------------------------------------------
--  DDL for Package ASO_SALES_TEAM_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_SALES_TEAM_INT" AUTHID CURRENT_USER as
/* $Header: asoistms.pls 120.1 2005/06/30 14:39:17 appldev ship $ */
-- Package name     : ASO_SALES_TEAM_INT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


PROCEDURE Assign_Sales_Team(
    P_Init_Msg_List              IN    VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN    VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Header_Rec             IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Qte_Header_Rec             OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );


END ASO_SALES_TEAM_INT;

 

/
