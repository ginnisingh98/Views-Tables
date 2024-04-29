--------------------------------------------------------
--  DDL for Package ASO_VALIDATE_CFG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_VALIDATE_CFG_PVT" AUTHID CURRENT_USER as
/* $Header: asovcfgs.pls 120.0.12010000.1 2010/04/14 05:01:30 rassharm noship $ */

PROCEDURE Validate_Configuration
    (P_Api_Version_Number              IN             NUMBER,
     P_Init_Msg_List                   IN             VARCHAR2  := FND_API.G_FALSE,
     P_Commit                          IN             VARCHAR2  := FND_API.G_FALSE,
     p_control_rec                     IN             aso_quote_pub.control_rec_type
                                                      := aso_quote_pub.G_MISS_control_rec,
     P_model_line_id                   IN             NUMBER,
     P_Qte_Line_Tbl                    IN             ASO_QUOTE_PUB.Qte_Line_Tbl_Type
    					                             := ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL,
     P_Qte_Line_Dtl_Tbl	              IN             ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type
    					                             := ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL,
    P_UPDATE_QUOTE                   IN   VARCHAR2     := FND_API.G_FALSE,
    P_EFFECTIVE_DATE		     IN   Date  := FND_API.G_MISS_DATE,
    P_model_lookup_DATE   IN   Date  := FND_API.G_MISS_DATE,
     X_config_header_id               OUT NOCOPY /* file.sql.39 change */       NUMBER,
     X_config_revision_num            OUT NOCOPY /* file.sql.39 change */       NUMBER,
     X_valid_configuration_flag       OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
     X_complete_configuration_flag    OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
     X_config_changed                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
     X_return_status                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
     X_msg_count                      OUT NOCOPY /* file.sql.39 change */       NUMBER,
     X_msg_data                       OUT NOCOPY /* file.sql.39 change */       VARCHAR2
     );

PROCEDURE Create_header_xml
( p_model_line_id       IN       NUMBER,
 P_EFFECTIVE_DATE		     IN   Date  := FND_API.G_MISS_DATE,
 P_model_lookup_DATE   IN   Date  := FND_API.G_MISS_DATE,
  x_xml_hdr             OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
  x_return_status       OUT NOCOPY /* file.sql.39 change */      VARCHAR2 );

    End ASO_VALIDATE_CFG_PVT;




/
