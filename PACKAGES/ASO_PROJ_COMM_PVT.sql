--------------------------------------------------------
--  DDL for Package ASO_PROJ_COMM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_PROJ_COMM_PVT" AUTHID CURRENT_USER AS
/* $Header: asovpqcs.pls 120.1 2005/06/29 12:43:29 appldev ship $ */
-- Package name     : ASO_PROJ_COMM_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


PROCEDURE Calculate_Proj_Commission(
    P_Init_Msg_List              IN    VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN    VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Header_Rec             IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    P_Resource_Id                IN    NUMBER       := FND_API.G_MISS_NUM,
    X_Last_Update_Date           OUT NOCOPY /* file.sql.39 change */   DATE,
    X_Object_Version_Number      OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );


END ASO_PROJ_COMM_PVT;

 

/
