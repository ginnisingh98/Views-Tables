--------------------------------------------------------
--  DDL for Package ASO_RLTSHIP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_RLTSHIP_PUB" AUTHID CURRENT_USER as
/* $Header: asoprlts.pls 120.1 2005/06/29 12:37:49 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_RLTSHIP_PUB
-- Purpose          :
--   This package contains specification for pl/sql records and tables and the
--   Public API of Order Capture.
--



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Line_Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_Line_Rltship_Tbl IN   Line_Rltship_Tbl_Type

--   End of Comments
--
PROCEDURE Create_Line_Relationship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Line_Rltship_Rec      IN   ASO_QUOTE_PUB.Line_Rltship_Rec_Type := ASO_QUOTE_PUB.G_MISS_line_rltship_REC,
    X_line_relationship_id       OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Line_Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional Default = NULL
--       P_Line_Rltship_Rec IN   Line_Rltship_Rec_Type

--   End of Comments
--
PROCEDURE Update_Line_Relationship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
 P_Line_Rltship_Rec      IN   ASO_QUOTE_PUB.Line_Rltship_Rec_Type := ASO_QUOTE_PUB.G_MISS_line_rltship_REC,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_Line_Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional Default = NULL
--       P_Line_Rltship_Rec IN   Line_Rltship_Rec_Type

--
PROCEDURE Delete_Line_Relationship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
     p_control_rec                IN  ASO_QUOTE_PUB.control_rec_type 	:= ASO_QUOTE_PUB.G_MISS_Control_Rec,
    P_Line_Rltship_Rec      IN   ASO_QUOTE_PUB.Line_Rltship_Rec_Type := ASO_QUOTE_PUB.G_MISS_line_rltship_rec,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Header_Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_Header_Relationship_Rec IN   Header_Relationship_Rec_Type

--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Create_Header_Relationship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Header_Rltship_Rec         IN   ASO_QUOTE_PUB.Header_Rltship_Rec_Type := ASO_QUOTE_PUB.G_MISS_header_rltship_REC,
    X_Header_rltship_id          OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Header_Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional Default = NULL
--       P_Header_Relationship_Rec IN   Header_Relationship_Rec_Type

--
--   End of Comments
--
PROCEDURE Update_Header_Relationship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Header_Rltship_Rec      IN   ASO_QUOTE_PUB.Header_Rltship_Rec_Type := ASO_QUOTE_PUB.G_MISS_header_rltship_REC,
    X_header_relationship_id       OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Return_Status                OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                    OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                     OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_Header_Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional Default = NULL
--       P_Header_Relationship_Rec IN   Header_Relationship_Rec_Type
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT  parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Delete_Header_Relationship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Header_Rltship_Rec      IN   ASO_QUOTE_PUB.Header_Rltship_Rec_Type := ASO_QUOTE_PUB.G_MISS_header_rltship_REC,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Party_Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_Party_Relationship_Rec IN   Party_Relationship_Rec_Type
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */   NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT  parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Create_Party_Relationship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Party_Rltship_Rec      IN   ASO_QUOTE_PUB.Party_Rltship_Rec_Type := ASO_QUOTE_PUB.G_MISS_party_rltship_REC,
    X_party_relationship_id      OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Party_Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional Default = NULL
--       P_Party_Relationship_Rec IN   Party_Relationship_Rec_Type
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT  parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Update_Party_Relationship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Party_Rltship_Rec      IN   ASO_QUOTE_PUB.Party_Rltship_Rec_Type := ASO_QUOTE_PUB.G_MISS_party_rltship_REC,
    X_party_relationship_id       OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    );




--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_Party_Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional Default = NULL
--       P_Party_Relationship_Rec IN   Party_Relationship_Rec_Type
--
--   End of Comments
--
PROCEDURE Delete_Party_Relationship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Party_Rltship_Rec      IN   ASO_QUOTE_PUB.Party_Rltship_Rec_Type := ASO_QUOTE_PUB.G_MISS_party_rltship_REC,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Object_Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_Object_Relationship_Rec IN   RELATED_OBJ_Rec_Type
--
--   End of Comments
--
PROCEDURE Create_Object_Relationship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_RELATED_OBJ_Rec     IN    ASO_quote_PUB.RELATED_OBJ_Rec_Type  := ASO_quote_PUB.G_MISS_RELATED_OBJ_REC,
    X_related_object_id          OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Object_Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional Default = NULL
--       P_Object_Relationship_Rec IN   RELATED_OBJ_Rec_Type

--
--   End of Comments
--
PROCEDURE Update_Object_Relationship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_RELATED_OBJ_Rec     IN    ASO_QUOTE_PUB.RELATED_OBJ_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );




--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_Object_Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional Default = NULL
--       P_Object_Relationship_Rec IN   Object_Relationship_Rec_Type
--
--   End of Comments
--
PROCEDURE Delete_Object_Relationship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_RELATED_OBJ_Rec     IN ASO_QUOTE_PUB.RELATED_OBJ_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Price_Adj_Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_Price_Adj_Rltship_Rec   IN   Price_Adj_Rltship_Rec_Type
--   Note: This automatic generated procedure definition, it includes standard IN/OUT  parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Create_Price_Adj_Rltship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Price_Adj_Rltship_Rec      IN   ASO_QUOTE_PUB.Price_Adj_Rltship_Rec_Type := ASO_QUOTE_PUB.G_MISS_Price_Adj_Rltship_REC,
    X_adj_relationship_id       OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    );



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Price_Adj_Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional Default = NULL
--       P_Price_Adj_Rltship_Rec   IN   Price_Adj_Rltship_Rec_Type
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT  parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Update_Price_Adj_Rltship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Price_Adj_Rltship_Rec      IN   ASO_QUOTE_PUB.Price_Adj_Rltship_Rec_Type := ASO_QUOTE_PUB.G_MISS_Price_Adj_Rltship_REC,
    X_adj_relationship_id        OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_Price_Adj__Relationship
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional Default = NUL
--       P_Price_Adj_Rltship_Rec   IN   Price_Adj_Rltship_Rec_Type
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT  parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Delete_Price_Adj_Rltship(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Price_Adj_Rltship_Rec      IN   ASO_QUOTE_PUB.Price_Adj_Rltship_Rec_Type := ASO_QUOTE_PUB.G_MISS_Price_Adj_Rltship_REC,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );


END ASO_RLTSHIP_PUB;

 

/
