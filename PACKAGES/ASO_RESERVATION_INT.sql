--------------------------------------------------------
--  DDL for Package ASO_RESERVATION_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_RESERVATION_INT" AUTHID CURRENT_USER as
/* $Header: asoprsvs.pls 120.1 2005/06/29 12:37:56 appldev ship $ */
-- Start of Comments
-- Package name     : aso_reservation_int
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_reservation
--   Type    :  Public
--   Pre-Req :
--   Parameters:
PROCEDURE Create_reservation(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_line_rec                   IN   aso_quote_pub.qte_line_rec_type,
    p_shipment_rec               IN   aso_quote_pub.shipment_rec_type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_quantity_reserved	         OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_reservation_id             OUT NOCOPY /* file.sql.39 change */   NUMBER
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_reservation
--   Type    :  Public
--   Pre-Req :
--   Parameters:

PROCEDURE Update_reservation(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_line_rec                   IN   aso_quote_pub.qte_line_rec_type,
    p_shipment_rec               IN   aso_quote_pub.shipment_rec_type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_reservation
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P__Rec     IN _Rec_Type  Required
--
--   OUT NOCOPY /* file.sql.39 change */ :
--       x_return_status           OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */   NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--   Version : Current version 2.0

PROCEDURE Delete_reservation(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_line_rec                   IN   aso_quote_pub.qte_line_rec_type,
    p_shipment_rec               IN   aso_quote_pub.shipment_rec_type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );

PROCEDURE Transfer_Reservation(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_msg_list              In   VARCHAR2  := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2  := FND_API.G_FALSE,
    P_Header_rec                 IN   ASO_QUOTE_PUB.qte_header_rec_type,
    P_Line_rec                   IN   ASO_QUOTE_PUB.qte_line_rec_type,
    P_shipment_rec               IN   ASO_QUOTE_PUB.shipment_rec_type,
    X_New_Reservation_id         OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );

End aso_reservation_int;

 

/
