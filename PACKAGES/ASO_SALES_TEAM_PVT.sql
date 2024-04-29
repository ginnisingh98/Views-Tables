--------------------------------------------------------
--  DDL for Package ASO_SALES_TEAM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_SALES_TEAM_PVT" AUTHID CURRENT_USER as
/* $Header: asovasts.pls 120.2.12010000.3 2011/05/11 09:41:02 vidsrini ship $ */
-- Start of Comments
-- Package name     : ASO_SALES_TEAM_PVT
-- Purpose          :
--
-- History          :
-- NOTE             :
--
-- End of Comments
--

PROCEDURE Assign_Sales_Team(
    P_Init_Msg_List              IN    VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN    VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Header_Rec             IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    P_Qte_Line_Tbl               IN    ASO_QUOTE_PUB.Qte_Line_Tbl_Type
                                                := ASO_QUOTE_PUB.G_MISS_qte_line_TBL,
    P_Operation                  IN    VARCHAR2     := FND_API.G_MISS_CHAR,
    X_Qte_Header_Rec             OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );


PROCEDURE Get_Sales_Team(
    P_Init_Msg_List              IN    VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Header_Rec             IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    P_Qte_Line_Tbl               IN    ASO_QUOTE_PUB.Qte_Line_Tbl_Type
                                       := ASO_QUOTE_PUB.G_MISS_qte_line_TBL,
    --X_Winners_Rec                OUT NOCOPY /* file.sql.39 change */   JTF_TERR_ASSIGN_PUB.bulk_winners_rec_type,
    X_Winners_Rec                OUT NOCOPY /* file.sql.39 change */   JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );


PROCEDURE Update_Primary_SalesInfo(
    P_Init_Msg_List              IN    VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Header_Rec             IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    P_Primary_SalesAgent         IN    NUMBER,
    P_Primary_SalesGrp           IN    NUMBER,
    P_Reassign_Flag              IN    VARCHAR2,
    X_Qte_Header_Rec             OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
   );


PROCEDURE Opp_Quote_Primary_SalesRep(
    P_Init_Msg_List              IN    VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Header_Rec             IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Qte_Header_Rec             OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
   );

PROCEDURE EXPLODE_GROUPS_ACCOUNTS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY  JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2
    );

 PROCEDURE EXPLODE_TEAMS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2
    );

 PROCEDURE INSERT_ACCESSES_ACCOUNTS(
				x_errbuf        OUT NOCOPY VARCHAR2,
				x_retcode        OUT NOCOPY VARCHAR2,
                                P_Qte_Header_Rec   IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type ,
				p_WinningTerrMember_tbl  IN OUT NOCOPY JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
				x_return_status     OUT NOCOPY VARCHAR2
  );

End ASO_SALES_TEAM_PVT;

/
