--------------------------------------------------------
--  DDL for Package ASO_QUOTE_TMPL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_QUOTE_TMPL_PVT" AUTHID CURRENT_USER AS
/* $Header: asovqtms.pls 120.1.12010000.2 2010/03/03 07:07:21 rassharm ship $ */

-- Start of Comments
-- Package name     : ASO_QUOTE_TMPL_PVT
-- Purpose          :
-- End of Comments
PROCEDURE Add_Template_To_Quote(
    P_API_VERSION_NUMBER    IN   NUMBER,
    P_INIT_MSG_LIST         IN   VARCHAR2                                 := FND_API.G_FALSE,
    P_COMMIT                IN   VARCHAR2                                 := FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN   NUMBER                                   := FND_API.G_VALID_LEVEL_FULL,
    P_UPDATE_FLAG           IN   VARCHAR2                                 := 'Y',
    P_TEMPLATE_ID_TBL       IN   ASO_QUOTE_TMPL_INT.LIST_TEMPLATE_TBL_TYPE,
    P_QTE_HEADER_REC        IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    P_CONTROL_REC           IN   ASO_QUOTE_PUB.CONTROL_REC_TYPE           := ASO_QUOTE_PUB.G_MISS_control_REC,
    x_Qte_Line_Tbl         OUT NOCOPY /* file.sql.39 change */       ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
    x_Qte_Line_Dtl_Tbl     OUT NOCOPY /* file.sql.39 change */       ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
    X_RETURN_STATUS         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY /* file.sql.39 change */     NUMBER,
    X_MSG_DATA              OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);


-- ER 9433340
FUNCTION Validate_Item(
    p_qte_header_rec    IN       ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    p_quote_line_id        IN      NUMBER,
    p_inventory_item_id IN       NUMBER,
    p_quantity          IN       NUMBER,
    p_uom_code          IN       VARCHAR2
) RETURN BOOLEAN;

END;


/
