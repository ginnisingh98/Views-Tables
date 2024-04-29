--------------------------------------------------------
--  DDL for Package ASO_COPY_TMPL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_COPY_TMPL_PUB" AUTHID CURRENT_USER as
/* $Header: asoptcps.pls 120.0.12010000.1 2010/02/18 09:25:45 rassharm noship $ */
-- Start of Comments
-- Package name     : ASO_COPY_TMPL_PUB
-- Purpose          :
--   This package contains procedure for creating template from quote
--   Public  API of Order Capture.
--
--   Procedures:
--   Copy_Quote_To_Tmpl
--
-- History          :
-- NOTE             :
--
-- End of Comments

PROCEDURE Copy_Quote_To_Tmpl (
       P_Api_Version_Number IN NUMBER
    , P_Init_Msg_List IN VARCHAR2 := FND_API.G_FALSE
    , P_Commit IN VARCHAR2 := FND_API.G_FALSE
    , P_old_quote_header_Id IN NUMBER
    , X_Qte_Header_Id OUT NOCOPY /* file.sql.39 change */   NUMBER
    , X_Qte_Number OUT NOCOPY /* file.sql.39 change */   NUMBER
    , X_Return_Status OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    , X_Msg_Count OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    , X_Msg_Data OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );

 PROCEDURE Copy_Tmpl_Header(
       P_Api_Version_Number IN NUMBER
    , P_Init_Msg_List IN VARCHAR2 := FND_API.G_FALSE
    , P_Commit IN VARCHAR2 := FND_API.G_FALSE
    , P_Qte_Header_Rec IN ASO_QUOTE_PUB.qte_header_rec_Type
    , X_Qte_Header_Id OUT NOCOPY /* file.sql.39 change */   NUMBER
    , X_Return_Status OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    , X_Msg_Count OUT NOCOPY /* file.sql.39 change */   NUMBER
    , X_Msg_Data OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    );

PROCEDURE Copy_Tmpl_Lines(
     P_Api_Version_Number          IN   NUMBER,
     P_Init_Msg_List               IN   VARCHAR2     := FND_API.G_FALSE,
     P_Commit                      IN   VARCHAR2     := FND_API.G_FALSE,
     P_Qte_Header_Id          IN   NUMBER,
     P_New_Qte_Header_Id      IN   NUMBER,
     --P_Qte_Line_Id            IN   NUMBER   := FND_API.G_MISS_NUM,
     --P_Qte_Header_Rec         IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
     P_Control_Rec            IN   ASO_QUOTE_PUB.Control_Rec_Type,
     --X_Qte_Line_Id            OUT NOCOPY /* file.sql.39 change */     NUMBER,
     X_Return_Status          OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
     X_Msg_Count              OUT NOCOPY /* file.sql.39 change */     NUMBER,
     X_Msg_Data               OUT NOCOPY /* file.sql.39 change */     VARCHAR2 );


     PROCEDURE Copy_Tmpl_Service (
       p_qte_line_id IN NUMBER
    , p_new_qte_header_id IN NUMBER
    , p_qte_header_id IN NUMBER
    , lx_line_index_link_tbl IN OUT NOCOPY  ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type
    , X_Return_Status OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    , X_Msg_Count OUT NOCOPY /* file.sql.39 change */   NUMBER
    , X_Msg_Data OUT NOCOPY /* file.sql.39 change */   VARCHAR2
   ) ;

    PROCEDURE Config_Copy_Tmpl (
       p_old_config_header_id IN NUMBER
    , p_old_config_revision_num IN NUMBER
    , p_config_header_id IN NUMBER
    , p_config_revision_num IN NUMBER
    , p_new_qte_header_id IN NUMBER
    , p_qte_header_id IN NUMBER
    , lx_line_index_link_tbl IN OUT NOCOPY ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type
    , X_Return_Status OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    , X_Msg_Count OUT NOCOPY /* file.sql.39 change */   NUMBER
    , X_Msg_Data OUT NOCOPY /* file.sql.39 change */   VARCHAR2
);

    End ASO_COPY_TMPL_PUB;

/
