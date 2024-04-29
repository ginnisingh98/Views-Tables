--------------------------------------------------------
--  DDL for Package ASO_SPLIT_LINE_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_SPLIT_LINE_INT" AUTHID CURRENT_USER as
/* $Header: asoispls.pls 120.1 2005/06/29 12:35:59 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_SPLIT_LINE_INT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

type search_tbl_type is table of number index by binary_integer;


PROCEDURE Split_quote_line(
       P_Api_Version_Number         IN            NUMBER,
       P_Init_Msg_List              IN            VARCHAR2     := FND_API.G_FALSE,
       P_Commit                     IN            VARCHAR2     := FND_API.G_FALSE,
       p_qte_line_id                IN            NUMBER,
       P_Qte_Line_Tbl               IN            ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
       P_ln_Shipment_Tbl            IN            ASO_QUOTE_PUB.Shipment_Tbl_Type
					                         := ASO_QUOTE_PUB.G_MISS_SHIPMENT_TBL,
       X_Qte_Line_Tbl               OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
       X_Return_Status              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
       X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */     NUMBER,
       X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */     VARCHAR2
 );

--Overloaded one

PROCEDURE split_quote_line(
       p_api_version_number         IN            number,
       p_init_msg_list              IN            varchar2     := fnd_api.g_false,
       p_commit                     IN            varchar2     := fnd_api.g_false,
       p_control_rec                IN            aso_quote_pub.control_rec_type
                                                  := aso_quote_pub.g_miss_control_rec,
       p_qte_header_rec             IN            aso_quote_pub.qte_header_rec_type
                                                  := aso_quote_pub.g_miss_qte_header_rec,
       p_original_qte_line_rec      IN            aso_quote_pub.qte_line_rec_type,
       p_qte_line_tbl               IN            aso_quote_pub.qte_line_tbl_type,
       p_ln_shipment_tbl            IN            aso_quote_pub.shipment_tbl_type
                                                  := aso_quote_pub.g_miss_shipment_tbl,
       x_qte_line_tbl               OUT NOCOPY /* file.sql.39 change */           aso_quote_pub.qte_line_tbl_type,
       x_return_status              OUT NOCOPY /* file.sql.39 change */           varchar2,
       x_msg_count                  OUT NOCOPY /* file.sql.39 change */           number,
       x_msg_data                   OUT NOCOPY /* file.sql.39 change */           varchar2
 );


PROCEDURE Do_Split_line (
    p_qte_header_rec           IN            ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    p_control_rec              IN            aso_quote_pub.control_rec_type,
    p_original_qte_line_rec    IN            ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    p_serviceable_item         IN            VARCHAR2  :=  FND_API.G_FALSE,
    P_Qte_Line_Tbl             IN            ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
    P_ln_Shipment_Tbl          IN            ASO_QUOTE_PUB.Shipment_Tbl_Type,
    p_commit                   IN            VARCHAR2,
    X_Qte_Line_Tbl             OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
    X_Return_Status            OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    X_Msg_Count                OUT NOCOPY /* file.sql.39 change */     NUMBER,
    X_Msg_Data                 OUT NOCOPY /* file.sql.39 change */     VARCHAR2
    );

End ASO_SPLIT_LINE_INT;

 

/
