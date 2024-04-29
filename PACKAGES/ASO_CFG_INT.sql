--------------------------------------------------------
--  DDL for Package ASO_CFG_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_CFG_INT" AUTHID CURRENT_USER as
/* $Header: asoicfgs.pls 120.1.12010000.4 2016/04/01 06:50:06 akushwah ship $ */
-- Start of Comments
-- Package name     : aso_cfg_int
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;


 TYPE rtln_rec_type IS RECORD(
   operation_code               VARCHAR2(30)      := FND_API.G_MISS_CHAR ,
   quote_line_id                NUMBER            := FND_API.G_MISS_NUM ,
   quote_line_detail_id         NUMBER            := FND_API.G_MISS_NUM ,
   parent_config_item_id        NUMBER            := FND_API.G_MISS_NUM ,
   config_item_id               NUMBER            := FND_API.G_MISS_NUM ,
   inventory_item_id            NUMBER            := FND_API.G_MISS_NUM ,
   organization_id              NUMBER            := FND_API.G_MISS_NUM ,
   component_code               VARCHAR2(1200)    := FND_API.G_MISS_CHAR ,
   quantity                     NUMBER            := FND_API.G_MISS_NUM ,
   uom_code                     VARCHAR2(3)       := FND_API.G_MISS_CHAR ,
   included_flag                VARCHAR2(1)       := 'N' ,
   created_flag                 VARCHAR2(1)       := 'N' ,
   complete_configuration_flag  VARCHAR2(1)       := FND_API.G_MISS_CHAR ,
   valid_configuration_flag     VARCHAR2(1)       := FND_API.G_MISS_CHAR ) ;

 TYPE rtln_tbl_type  IS TABLE OF rtln_rec_type
                        INDEX BY BINARY_INTEGER ;

 G_rtln_tbl  rtln_tbl_type ;
 G_MISS_rtln_tbl rtln_tbl_type ;

/* commented for Bug 23024914
 --p1 bug 22676353
 TYPE  rtln_tbl_type1      IS TABLE OF rtln_rec_type  INDEX BY VARCHAR2(32767);
 G_rtln_tbl1  rtln_tbl_type1 ;
 G_MISS_rtln_tbl1 rtln_tbl_type1 ;
*/

--   API Name:  Get_configuration_lines
--   Type    :  Public
--   Pre-Req :

TYPE Control_Rec_Type IS RECORD
(new_config_flag      VARCHAR2(1) DEFAULT FND_API.G_TRUE ,
 handle_deleted_flag  VARCHAR2(1) DEFAULT NULL,
 new_name             VARCHAR2(240) DEFAULT NULL );

G_MISS_Control_Rec	Control_Rec_Type;

PROCEDURE Get_configuration_lines(
    P_Api_Version_Number      IN            NUMBER       := FND_API.G_MISS_NUM,
    P_Init_Msg_List           IN            VARCHAR2     := FND_API.G_FALSE,
    p_top_model_line_id       IN            NUMBER       := FND_API.G_MISS_NUM,
    x_qte_line_tbl            OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.qte_line_tbl_type,
    x_qte_line_dtl_tbl        OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.qte_line_dtl_tbl_type,
    x_shipment_tbl            OUT NOCOPY /* file.sql.39 change */     ASO_QUOTE_PUB.shipment_tbl_type ,
    x_return_status           OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    x_msg_count               OUT NOCOPY /* file.sql.39 change */     NUMBER,
    x_msg_data                OUT NOCOPY /* file.sql.39 change */     VARCHAR2 ) ;

PROCEDURE Delete_configuration(
	P_Api_version_NUmber	IN	     NUMBER,
	P_Init_msg_List		IN	     VARCHAR2 := FND_API.G_FALSE,
	P_config_hdr_id          IN        NUMBER,
	p_config_rev_nbr         IN        NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */    	VARCHAR2,
	x_msg_count		     OUT NOCOPY /* file.sql.39 change */    	NUMBER,
	x_msg_data		     OUT NOCOPY /* file.sql.39 change */    	VARCHAR2);


PROCEDURE Delete_configuration_auto(
	P_Api_version_NUmber	IN	     NUMBER,
	P_Init_msg_List		IN	     VARCHAR2 := FND_API.G_FALSE,
	P_config_hdr_id          IN        NUMBER,
	p_config_rev_nbr         IN        NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */    	VARCHAR2,
	x_msg_count		     OUT NOCOPY /* file.sql.39 change */    	NUMBER,
	x_msg_data		     OUT NOCOPY /* file.sql.39 change */    	VARCHAR2);


Procedure Copy_Configuration( p_api_version_number   IN           NUMBER,
                              p_init_msg_list        IN           VARCHAR2  :=  FND_API.G_FALSE,
                              p_commit               IN           VARCHAR2  :=  FND_API.G_FALSE,
                              p_config_header_id     IN           NUMBER,
                              p_config_revision_num  IN           NUMBER,
                              p_copy_mode            IN           VARCHAR2,
                              p_handle_deleted_flag  IN           VARCHAR2  :=  NULL,

                              p_new_name             IN           VARCHAR2  :=  NULL,
                              p_autonomous_flag      IN           VARCHAR2  :=  FND_API.G_FALSE,
                              x_config_header_id     OUT NOCOPY /* file.sql.39 change */    NUMBER,
                              x_config_revision_num  OUT NOCOPY /* file.sql.39 change */    NUMBER,
                              x_orig_item_id_tbl     OUT NOCOPY   CZ_API_PUB.number_tbl_type,
                              x_new_item_id_tbl      OUT NOCOPY   CZ_API_PUB.number_tbl_type,
                              x_return_status        OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
                              x_msg_count            OUT NOCOPY /* file.sql.39 change */    NUMBER,
                              x_msg_data             OUT NOCOPY /* file.sql.39 change */    VARCHAR2
                            );


PROCEDURE get_config_details(
    p_api_version_number    IN            NUMBER,
    p_init_msg_list         IN            VARCHAR2                       := FND_API.G_FALSE,
    p_commit                IN            VARCHAR2                       := FND_API.G_FALSE,
    p_control_rec           IN            aso_quote_pub.control_rec_type
								  := aso_quote_pub.G_MISS_control_rec,
    p_qte_header_rec        IN            aso_quote_pub.qte_header_rec_type,
    p_model_line_rec        IN            aso_quote_pub.qte_line_rec_type,
    p_config_rec            IN            aso_quote_pub.qte_line_dtl_rec_type,
    p_config_hdr_id         IN            NUMBER ,
    p_config_rev_nbr        IN            NUMBER,
    x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
    x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2
       );


PROCEDURE  Pricing_Callback(    p_config_session_key    IN            VARCHAR2,
                                p_price_type            IN            VARCHAR2,
                                x_total_price           OUT NOCOPY /* file.sql.39 change */     NUMBER );

FUNCTION Query_Qte_Line_Rows (
    P_Qte_Header_Id		IN  NUMBER ,
    P_Qte_Line_Id		IN  NUMBER
    ) RETURN ASO_QUOTE_PUB.Qte_Line_Tbl_Type;


PROCEDURE Create_hdr_xml
( p_model_line_id       IN            NUMBER,
  x_xml_hdr             OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_return_status       OUT NOCOPY /* file.sql.39 change */     VARCHAR2);


PROCEDURE Send_input_xml
            ( P_Qte_Line_Tbl        IN            ASO_QUOTE_PUB.Qte_Line_Tbl_Type
					                         := ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL,
              P_Qte_Line_Dtl_Tbl	 IN            ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type
					                         := ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL,
              P_xml_hdr             IN            VARCHAR2,
	      X_out_xml_msg         OUT NOCOPY /* file.sql.39 change */     LONG ,
              X_config_changed    OUT NOCOPY /* file.sql.39 change */     VARCHAR2,  -- CZ ER
              X_return_status       OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
	      X_msg_count           OUT NOCOPY /* file.sql.39 change */     NUMBER,
              X_msg_data            OUT NOCOPY /* file.sql.39 change */     VARCHAR2
            );


PROCEDURE  Parse_output_xml
               (  p_xml_msg                       IN            LONG,
                  x_valid_configuration_flag      OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
                  x_complete_configuration_flag   OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
                  x_config_header_id              OUT NOCOPY /* file.sql.39 change */     NUMBER,
                  x_config_revision_num           OUT NOCOPY /* file.sql.39 change */     NUMBER,
                  x_return_status                 OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
                  x_msg_count                     OUT NOCOPY /* file.sql.39 change */     NUMBER,
                  x_msg_data                      OUT NOCOPY /* file.sql.39 change */     VARCHAR2
                );


PROCEDURE Validate_Configuration
    (P_Api_Version_Number             IN              NUMBER    := FND_API.G_MISS_NUM,
     P_Init_Msg_List                  IN              VARCHAR2  := FND_API.G_FALSE,
     P_Commit                         IN              VARCHAR2  := FND_API.G_FALSE,
     p_control_rec                    IN              aso_quote_pub.control_rec_type
                                                      := aso_quote_pub.G_MISS_control_rec,
     P_model_line_id                  IN              NUMBER,
     P_Qte_Line_Tbl                   IN              ASO_QUOTE_PUB.Qte_Line_Tbl_Type
    					                             := ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL,
     P_Qte_Line_Dtl_Tbl	             IN              ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type
    					                             := ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL,
	X_config_header_id               OUT NOCOPY /* file.sql.39 change */       NUMBER,
	X_config_revision_num            OUT NOCOPY /* file.sql.39 change */       NUMBER,
     X_valid_configuration_flag       OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
     X_complete_configuration_flag    OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
     X_return_status                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
     X_msg_count                      OUT NOCOPY /* file.sql.39 change */       NUMBER,
     X_msg_data                       OUT NOCOPY /* file.sql.39 change */       VARCHAR2
     );



End aso_cfg_int;

/
