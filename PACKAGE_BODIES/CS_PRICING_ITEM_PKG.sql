--------------------------------------------------------
--  DDL for Package Body CS_PRICING_ITEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_PRICING_ITEM_PKG" as
/* $Header: csxcpicb.pls 120.4.12010000.2 2008/08/06 13:08:22 vpremach ship $ */

/*********** Global  Variables  ********************************/
G_PKG_NAME     CONSTANT  VARCHAR2(30)  := 'cs_pricing_item_pkg' ;

PROCEDURE Call_Pricing_Item(
                 P_Api_Version              IN NUMBER default null,
                 P_Init_Msg_List            IN VARCHAR2 := FND_API.G_FALSE,
                 P_Commit                   IN VARCHAR2 := FND_API.G_FALSE,
                 P_Validation_Level         IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                 P_Inventory_Item_Id        IN NUMBER,
                 P_Price_List_Id            IN NUMBER,
                 P_UOM_Code                 IN VARCHAR2,
                 P_Currency_Code            IN VARCHAR2,
                 P_Quantity                 IN NUMBER,
                 P_Org_id                   IN NUMBER,
 		 P_Incident_date	    IN DATE default Null,   -- Bug 6393403
                 P_Pricing_Context          IN VARCHAR2,
                 P_Pricing_Attribute1       IN VARCHAR2,
                 P_Pricing_Attribute2       IN VARCHAR2,
                 P_Pricing_Attribute3       IN VARCHAR2,
                 P_Pricing_Attribute4       IN VARCHAR2,
                 P_Pricing_Attribute5       IN VARCHAR2,
                 P_Pricing_Attribute6       IN VARCHAR2,
                 P_Pricing_Attribute7       IN VARCHAR2,
                 P_Pricing_Attribute8       IN VARCHAR2,
                 P_Pricing_Attribute9       IN VARCHAR2,
                 P_Pricing_Attribute10      IN VARCHAR2,
                 P_Pricing_Attribute11      IN VARCHAR2,
                 P_Pricing_Attribute12      IN VARCHAR2,
                 P_Pricing_Attribute13      IN VARCHAR2,
                 P_Pricing_Attribute14      IN VARCHAR2,
                 P_Pricing_Attribute15      IN VARCHAR2,
                 P_Pricing_Attribute16      IN VARCHAR2,
                 P_Pricing_Attribute17      IN VARCHAR2,
                 P_Pricing_Attribute18      IN VARCHAR2,
                 P_Pricing_Attribute19      IN VARCHAR2,
                 P_Pricing_Attribute20      IN VARCHAR2,
                 P_Pricing_Attribute21      IN VARCHAR2,
                 P_Pricing_Attribute22      IN VARCHAR2,
                 P_Pricing_Attribute23      IN VARCHAR2,
                 P_Pricing_Attribute24      IN VARCHAR2,
                 P_Pricing_Attribute25      IN VARCHAR2,
                 P_Pricing_Attribute26      IN VARCHAR2,
                 P_Pricing_Attribute27      IN VARCHAR2,
                 P_Pricing_Attribute28      IN VARCHAR2,
                 P_Pricing_Attribute29      IN VARCHAR2,
                 P_Pricing_Attribute30      IN VARCHAR2,
                 P_Pricing_Attribute31      IN VARCHAR2,
                 P_Pricing_Attribute32      IN VARCHAR2,
                 P_Pricing_Attribute33      IN VARCHAR2,
                 P_Pricing_Attribute34      IN VARCHAR2,
                 P_Pricing_Attribute35      IN VARCHAR2,
                 P_Pricing_Attribute36      IN VARCHAR2,
                 P_Pricing_Attribute37      IN VARCHAR2,
                 P_Pricing_Attribute38      IN VARCHAR2,
                 P_Pricing_Attribute39      IN VARCHAR2,
                 P_Pricing_Attribute40      IN VARCHAR2,
                 P_Pricing_Attribute41      IN VARCHAR2,
                 P_Pricing_Attribute42      IN VARCHAR2,
                 P_Pricing_Attribute43      IN VARCHAR2,
                 P_Pricing_Attribute44      IN VARCHAR2,
                 P_Pricing_Attribute45      IN VARCHAR2,
                 P_Pricing_Attribute46      IN VARCHAR2,
                 P_Pricing_Attribute47      IN VARCHAR2,
                 P_Pricing_Attribute48      IN VARCHAR2,
                 P_Pricing_Attribute49      IN VARCHAR2,
                 P_Pricing_Attribute50      IN VARCHAR2,
                 P_Pricing_Attribute51      IN VARCHAR2,
                 P_Pricing_Attribute52      IN VARCHAR2,
                 P_Pricing_Attribute53      IN VARCHAR2,
                 P_Pricing_Attribute54      IN VARCHAR2,
                 P_Pricing_Attribute55      IN VARCHAR2,
                 P_Pricing_Attribute56      IN VARCHAR2,
                 P_Pricing_Attribute57      IN VARCHAR2,
                 P_Pricing_Attribute58      IN VARCHAR2,
                 P_Pricing_Attribute59      IN VARCHAR2,
                 P_Pricing_Attribute60      IN VARCHAR2,
                 P_Pricing_Attribute61      IN VARCHAR2,
                 P_Pricing_Attribute62      IN VARCHAR2,
                 P_Pricing_Attribute63      IN VARCHAR2,
                 P_Pricing_Attribute64      IN VARCHAR2,
                 P_Pricing_Attribute65      IN VARCHAR2,
                 P_Pricing_Attribute66      IN VARCHAR2,
                 P_Pricing_Attribute67      IN VARCHAR2,
                 P_Pricing_Attribute68      IN VARCHAR2,
                 P_Pricing_Attribute69      IN VARCHAR2,
                 P_Pricing_Attribute70      IN VARCHAR2,
                 P_Pricing_Attribute71      IN VARCHAR2,
                 P_Pricing_Attribute72      IN VARCHAR2,
                 P_Pricing_Attribute73      IN VARCHAR2,
                 P_Pricing_Attribute74      IN VARCHAR2,
                 P_Pricing_Attribute75      IN VARCHAR2,
                 P_Pricing_Attribute76      IN VARCHAR2,
                 P_Pricing_Attribute77      IN VARCHAR2,
                 P_Pricing_Attribute78      IN VARCHAR2,
                 P_Pricing_Attribute79      IN VARCHAR2,
                 P_Pricing_Attribute80      IN VARCHAR2,
                 P_Pricing_Attribute81      IN VARCHAR2,
                 P_Pricing_Attribute82      IN VARCHAR2,
                 P_Pricing_Attribute83      IN VARCHAR2,
                 P_Pricing_Attribute84      IN VARCHAR2,
                 P_Pricing_Attribute85      IN VARCHAR2,
                 P_Pricing_Attribute86      IN VARCHAR2,
                 P_Pricing_Attribute87      IN VARCHAR2,
                 P_Pricing_Attribute88      IN VARCHAR2,
                 P_Pricing_Attribute89      IN VARCHAR2,
                 P_Pricing_Attribute90      IN VARCHAR2,
                 P_Pricing_Attribute91      IN VARCHAR2,
                 P_Pricing_Attribute92      IN VARCHAR2,
                 P_Pricing_Attribute93      IN VARCHAR2,
                 P_Pricing_Attribute94      IN VARCHAR2,
                 P_Pricing_Attribute95      IN VARCHAR2,
                 P_Pricing_Attribute96      IN VARCHAR2,
                 P_Pricing_Attribute97      IN VARCHAR2,
                 P_Pricing_Attribute98      IN VARCHAR2,
                 P_Pricing_Attribute99      IN VARCHAR2,
                 P_Pricing_Attribute100     IN VARCHAR2,
                 x_list_price               OUT NOCOPY NUMBER,
                 x_return_status            OUT NOCOPY VARCHAR2,
                 x_msg_count                OUT NOCOPY NUMBER,
                 x_msg_data                 OUT NOCOPY VARCHAR2) IS

-- The input to the Pricing_Item is stored in this structure
l_control_rec		ASO_PRICING_INT.Pricing_Control_rec_Type;
l_hd_price_attr_tbl ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
l_qte_header_rec	ASO_QUOTE_PUB.Qte_Header_Rec_Type;
l_qte_line_rec     	ASO_QUOTE_PUB.Qte_Line_Rec_Type;
l_qte_line_dtl_rec  ASO_QUOTE_PUB.Qte_Line_dtl_Rec_Type;
l_hd_shipment_rec   ASO_QUOTE_PUB.Shipment_Rec_Type;
l_ln_shipment_rec   ASO_QUOTE_PUB.Shipment_Rec_Type;
l_Price_attr_tbl  	ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;

-- The output from the Pricing_Item is stored in this structure
lx_qte_out_line_tbl		ASO_QUOTE_PUB.Qte_Line_Tbl_Type ;
lx_qte_line_dtl_tbl  	ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
lx_price_adj_tbl          ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
lx_price_adj_attr_tbl     ASO_QUOTE_PUB.Price_Adj_attr_Tbl_Type;
lx_price_adj_rltship_tbl  ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;

lx_return_status  VARCHAR2(1);
lx_msg_count      NUMBER;
lx_msg_data       VARCHAR2(2000);

l_api_name       CONSTANT  VARCHAR2(30) := 'Call_Pricing_Item' ;
l_api_name_full  CONSTANT  VARCHAR2(61) := G_PKG_NAME || '.' || l_api_name ;
l_log_module     CONSTANT VARCHAR2(255) := 'cs.plsql.' || l_api_name_full || '.';

e_pricing_warning EXCEPTION;

BEGIN

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Api_Version              	:' || P_Api_Version
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Init_Msg_List            	:' || P_Init_Msg_List
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Commit  			:' || P_Commit
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Validation_Level         	:' || P_Validation_Level
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Inventory_Item_Id        	:' || P_Inventory_Item_Id
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Price_List_Id            	:' || P_Price_List_Id
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_UOM_Code			:' || P_UOM_Code
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Currency_Code            	:' || P_Currency_Code
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Quantity			:' || P_Quantity
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Org_Id                        :' || P_Org_Id

    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Context          	:' || P_Pricing_Context
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute1       	:' || P_Pricing_Attribute1
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute2       	:' || P_Pricing_Attribute2
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute3       	:' || P_Pricing_Attribute3
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute4       	:' || P_Pricing_Attribute4
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute5       	:' || P_Pricing_Attribute5
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute6       	:' || P_Pricing_Attribute6
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute7       	:' || P_Pricing_Attribute7
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute8       	:' || P_Pricing_Attribute8
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute9       	:' || P_Pricing_Attribute9
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute10      	:' || P_Pricing_Attribute10
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute11      	:' || P_Pricing_Attribute11
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute12      	:' || P_Pricing_Attribute12
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute13      	:' || P_Pricing_Attribute13
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute14      	:' || P_Pricing_Attribute14
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute15      	:' || P_Pricing_Attribute15
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute16      	:' || P_Pricing_Attribute16
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute17      	:' || P_Pricing_Attribute17
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute18      	:' || P_Pricing_Attribute18
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute19      	:' || P_Pricing_Attribute19
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute20      	:' || P_Pricing_Attribute20
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute21      	:' || P_Pricing_Attribute21
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute22      	:' || P_Pricing_Attribute22
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute23      	:' || P_Pricing_Attribute23
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute24      	:' || P_Pricing_Attribute24
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute25      	:' || P_Pricing_Attribute25
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute26      	:' || P_Pricing_Attribute26
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute27      	:' || P_Pricing_Attribute27
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute28      	:' || P_Pricing_Attribute28
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute29      	:' || P_Pricing_Attribute29
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute30      	:' || P_Pricing_Attribute30
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute31      	:' || P_Pricing_Attribute31
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute32      	:' || P_Pricing_Attribute32
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute33      	:' || P_Pricing_Attribute33
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute34      	:' || P_Pricing_Attribute34
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute35      	:' || P_Pricing_Attribute35
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute36      	:' || P_Pricing_Attribute36
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute37      	:' || P_Pricing_Attribute37
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute38      	:' || P_Pricing_Attribute38
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute39      	:' || P_Pricing_Attribute39
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute40      	:' || P_Pricing_Attribute40
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute41      	:' || P_Pricing_Attribute41
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute42      	:' || P_Pricing_Attribute42
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute43      	:' || P_Pricing_Attribute43
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute44      	:' || P_Pricing_Attribute44
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute45      	:' || P_Pricing_Attribute45
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute46      	:' || P_Pricing_Attribute46
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute47      	:' || P_Pricing_Attribute47
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute48      	:' || P_Pricing_Attribute48
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute49      	:' || P_Pricing_Attribute49
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute50      	:' || P_Pricing_Attribute50
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute51      	:' || P_Pricing_Attribute51
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute52      	:' || P_Pricing_Attribute52
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute53      	:' || P_Pricing_Attribute53
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute54      	:' || P_Pricing_Attribute54
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute55      	:' || P_Pricing_Attribute55
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute56      	:' || P_Pricing_Attribute56
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute57      	:' || P_Pricing_Attribute57
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute58      	:' || P_Pricing_Attribute58
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute59      	:' || P_Pricing_Attribute59
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute60      	:' || P_Pricing_Attribute60
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute61      	:' || P_Pricing_Attribute61
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute62      	:' || P_Pricing_Attribute62
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute63      	:' || P_Pricing_Attribute63
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute64      	:' || P_Pricing_Attribute64
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute65      	:' || P_Pricing_Attribute65
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute66      	:' || P_Pricing_Attribute66
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute67      	:' || P_Pricing_Attribute67
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute68      	:' || P_Pricing_Attribute68
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute69      	:' || P_Pricing_Attribute69
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute70      	:' || P_Pricing_Attribute70
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute71      	:' || P_Pricing_Attribute71
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute72      	:' || P_Pricing_Attribute72
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute73      	:' || P_Pricing_Attribute73
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute74      	:' || P_Pricing_Attribute74
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute75      	:' || P_Pricing_Attribute75
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute76      	:' || P_Pricing_Attribute76
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute77      	:' || P_Pricing_Attribute77
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute78      	:' || P_Pricing_Attribute78
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute79      	:' || P_Pricing_Attribute79
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute80      	:' || P_Pricing_Attribute80
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute81      	:' || P_Pricing_Attribute81
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute82      	:' || P_Pricing_Attribute82
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute83      	:' || P_Pricing_Attribute83
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute84      	:' || P_Pricing_Attribute84
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute85      	:' || P_Pricing_Attribute85
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute86      	:' || P_Pricing_Attribute86
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute87      	:' || P_Pricing_Attribute87
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute88      	:' || P_Pricing_Attribute88
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute89      	:' || P_Pricing_Attribute89
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute90      	:' || P_Pricing_Attribute90
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute91      	:' || P_Pricing_Attribute91
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute92      	:' || P_Pricing_Attribute92
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute93      	:' || P_Pricing_Attribute93
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute94      	:' || P_Pricing_Attribute94
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute95      	:' || P_Pricing_Attribute95
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute96      	:' || P_Pricing_Attribute96
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute97      	:' || P_Pricing_Attribute97
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute98      	:' || P_Pricing_Attribute98
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute99      	:' || P_Pricing_Attribute99
    );
     FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    ,'P_Pricing_Attribute100     	:' || P_Pricing_Attribute100
    );
  END IF;

   l_qte_header_rec.price_frozen_date := P_Incident_Date;   -- bug 6393403
   -- dbms_output.put_line('Beginning of the test');
   -- Initialize the values of the Pricing Line Rec Type
   l_qte_line_rec.INVENTORY_ITEM_ID := p_inventory_item_id;
   l_qte_line_rec.PRICE_LIST_ID := p_price_list_id;
   l_qte_line_rec.CURRENCY_CODE	:= p_currency_code;
   l_qte_line_rec.QUANTITY := p_Quantity;
   l_qte_line_rec.UOM_CODE := p_Uom_Code;

   l_qte_header_rec.ORG_ID := p_Org_Id; --r12

   -- Request_type is required to identify which product has setup the price list
   -- and pricing_event is required to identify the event which returns the item price
   l_control_rec.request_type := 'ASO';
   l_control_rec.pricing_event := 'LINE';

   -- Initialize the values of the Pricing line table. Since we are passing
   -- one line at a time from the form we hard the line_index to 1
   l_price_attr_tbl(1).flex_title               :=     'QP_ATTR_DEFNS_PRICING';
   l_Price_Attr_tbl(1).pricing_context	        :=	p_pricing_context;
   l_Price_Attr_tbl(1).pricing_attribute1	:=	p_pricing_attribute1;
   l_Price_Attr_tbl(1).pricing_attribute2	:=	p_pricing_attribute2;
   l_Price_Attr_tbl(1).pricing_attribute3	:=	p_pricing_attribute3;
   l_Price_Attr_tbl(1).pricing_attribute4	:=	p_pricing_attribute4;
   l_Price_Attr_tbl(1).pricing_attribute5	:=	p_pricing_attribute5;
   l_Price_Attr_tbl(1).pricing_attribute6	:=	p_pricing_attribute6;
   l_Price_Attr_tbl(1).pricing_attribute7	:=	p_pricing_attribute7;
   l_Price_Attr_tbl(1).pricing_attribute8	:=	p_pricing_attribute8;
   l_Price_Attr_tbl(1).pricing_attribute9	:=	p_pricing_attribute9;
   l_Price_Attr_tbl(1).pricing_attribute10	:=	p_pricing_attribute10;
   l_Price_Attr_tbl(1).pricing_attribute11	:=	p_pricing_attribute11;
   l_Price_Attr_tbl(1).pricing_attribute12	:=	p_pricing_attribute12;
   l_Price_Attr_tbl(1).pricing_attribute13	:=	p_pricing_attribute13;
   l_Price_Attr_tbl(1).pricing_attribute14	:=	p_pricing_attribute14;
   l_Price_Attr_tbl(1).pricing_attribute15	:=	p_pricing_attribute15;
   l_Price_Attr_tbl(1).pricing_attribute16	:=	p_pricing_attribute16;
   l_Price_Attr_tbl(1).pricing_attribute17 :=	p_pricing_attribute17;
   l_Price_Attr_tbl(1).pricing_attribute18	:=	p_pricing_attribute18;
   l_Price_Attr_tbl(1).pricing_attribute19	:=	p_pricing_attribute19;
   l_Price_Attr_tbl(1).pricing_attribute20	:=	p_pricing_attribute20;
   l_Price_Attr_tbl(1).pricing_attribute21	:=	p_pricing_attribute21;
   l_Price_Attr_tbl(1).pricing_attribute22	:=	p_pricing_attribute22;
   l_Price_Attr_tbl(1).pricing_attribute23	:=	p_pricing_attribute23;
   l_Price_Attr_tbl(1).pricing_attribute24	:=	p_pricing_attribute24;
   l_Price_Attr_tbl(1).pricing_attribute25	:=	p_pricing_attribute25;
   l_Price_Attr_tbl(1).pricing_attribute26	:=	p_pricing_attribute26;
   l_Price_Attr_tbl(1).pricing_attribute27	:=	p_pricing_attribute27;
   l_Price_Attr_tbl(1).pricing_attribute28	:=	p_pricing_attribute28;
   l_Price_Attr_tbl(1).pricing_attribute29	:=	p_pricing_attribute29;
   l_Price_Attr_tbl(1).pricing_attribute30	:=	p_pricing_attribute30;
   l_Price_Attr_tbl(1).pricing_attribute31	:=	p_pricing_attribute31;
   l_Price_Attr_tbl(1).pricing_attribute32	:=	p_pricing_attribute32;
   l_Price_Attr_tbl(1).pricing_attribute33	:=	p_pricing_attribute33;
   l_Price_Attr_tbl(1).pricing_attribute34	:=	p_pricing_attribute34;
   l_Price_Attr_tbl(1).pricing_attribute35 :=	p_pricing_attribute35;
   l_Price_Attr_tbl(1).pricing_attribute36	:=	p_pricing_attribute36;
   l_Price_Attr_tbl(1).pricing_attribute37	:=	p_pricing_attribute37;
   l_Price_Attr_tbl(1).pricing_attribute38	:=	p_pricing_attribute38;
   l_Price_Attr_tbl(1).pricing_attribute39	:=	p_pricing_attribute39;
   l_Price_Attr_tbl(1).pricing_attribute40	:=	p_pricing_attribute40;
   l_Price_Attr_tbl(1).pricing_attribute41	:=	p_pricing_attribute41;
   l_Price_Attr_tbl(1).pricing_attribute42	:=	p_pricing_attribute42;
   l_Price_Attr_tbl(1).pricing_attribute43	:=	p_pricing_attribute43;
   l_Price_Attr_tbl(1).pricing_attribute44	:=	p_pricing_attribute44;
   l_Price_Attr_tbl(1).pricing_attribute45	:=	p_pricing_attribute45;
   l_Price_Attr_tbl(1).pricing_attribute46	:=	p_pricing_attribute46;
   l_Price_Attr_tbl(1).pricing_attribute47	:=	p_pricing_attribute47;
   l_Price_Attr_tbl(1).pricing_attribute48	:=	p_pricing_attribute48;
   l_Price_Attr_tbl(1).pricing_attribute49	:=	p_pricing_attribute49;
   l_Price_Attr_tbl(1).pricing_attribute50	:=	p_pricing_attribute50;
   l_Price_Attr_tbl(1).pricing_attribute51	:=	p_pricing_attribute51;
   l_Price_Attr_tbl(1).pricing_attribute52	:=	p_pricing_attribute52;
   l_Price_Attr_tbl(1).pricing_attribute53 :=	p_pricing_attribute53;
   l_Price_Attr_tbl(1).pricing_attribute54	:=	p_pricing_attribute54;
   l_Price_Attr_tbl(1).pricing_attribute55	:=	p_pricing_attribute55;
   l_Price_Attr_tbl(1).pricing_attribute56	:=	p_pricing_attribute56;
   l_Price_Attr_tbl(1).pricing_attribute57	:=	p_pricing_attribute57;
   l_Price_Attr_tbl(1).pricing_attribute58	:=	p_pricing_attribute58;
   l_Price_Attr_tbl(1).pricing_attribute59	:=	p_pricing_attribute59;
   l_Price_Attr_tbl(1).pricing_attribute60	:=	p_pricing_attribute60;
   l_Price_Attr_tbl(1).pricing_attribute61	:=	p_pricing_attribute61;
   l_Price_Attr_tbl(1).pricing_attribute62	:=	p_pricing_attribute62;
   l_Price_Attr_tbl(1).pricing_attribute63	:=	p_pricing_attribute63;
   l_Price_Attr_tbl(1).pricing_attribute64	:=	p_pricing_attribute64;
   l_Price_Attr_tbl(1).pricing_attribute65	:=	p_pricing_attribute65;
   l_Price_Attr_tbl(1).pricing_attribute66	:=	p_pricing_attribute66;
   l_Price_Attr_tbl(1).pricing_attribute67	:=	p_pricing_attribute67;
   l_Price_Attr_tbl(1).pricing_attribute68	:=	p_pricing_attribute68;
   l_Price_Attr_tbl(1).pricing_attribute69	:=	p_pricing_attribute69;
   l_Price_Attr_tbl(1).pricing_attribute70	:=	p_pricing_attribute70;
   l_Price_Attr_tbl(1).pricing_attribute71 :=	p_pricing_attribute71;
   l_Price_Attr_tbl(1).pricing_attribute72	:=	p_pricing_attribute72;
   l_Price_Attr_tbl(1).pricing_attribute73	:=	p_pricing_attribute73;
   l_Price_Attr_tbl(1).pricing_attribute74	:=	p_pricing_attribute74;
   l_Price_Attr_tbl(1).pricing_attribute75	:=	p_pricing_attribute75;
   l_Price_Attr_tbl(1).pricing_attribute76	:=	p_pricing_attribute76;
   l_Price_Attr_tbl(1).pricing_attribute77	:=	p_pricing_attribute77;
   l_Price_Attr_tbl(1).pricing_attribute78	:=	p_pricing_attribute78;
   l_Price_Attr_tbl(1).pricing_attribute79	:=	p_pricing_attribute79;
   l_Price_Attr_tbl(1).pricing_attribute80	:=	p_pricing_attribute80;
   l_Price_Attr_tbl(1).pricing_attribute81	:=	p_pricing_attribute81;
   l_Price_Attr_tbl(1).pricing_attribute82	:=	p_pricing_attribute82;
   l_Price_Attr_tbl(1).pricing_attribute83	:=	p_pricing_attribute83;
   l_Price_Attr_tbl(1).pricing_attribute84 :=	p_pricing_attribute84;
   l_Price_Attr_tbl(1).pricing_attribute85	:=	p_pricing_attribute85;
   l_Price_Attr_tbl(1).pricing_attribute86	:=	p_pricing_attribute86;
   l_Price_Attr_tbl(1).pricing_attribute87	:=	p_pricing_attribute87;
   l_Price_Attr_tbl(1).pricing_attribute88	:=	p_pricing_attribute88;
   l_Price_Attr_tbl(1).pricing_attribute89	:=	p_pricing_attribute89;
   l_Price_Attr_tbl(1).pricing_attribute90	:=	p_pricing_attribute90;
   l_Price_Attr_tbl(1).pricing_attribute91	:=	p_pricing_attribute91;
   l_Price_Attr_tbl(1).pricing_attribute92	:=	p_pricing_attribute92;
   l_Price_Attr_tbl(1).pricing_attribute93	:=	p_pricing_attribute93;
   l_Price_Attr_tbl(1).pricing_attribute94	:=	p_pricing_attribute94;
   l_Price_Attr_tbl(1).pricing_attribute95	:=	p_pricing_attribute95;
   l_Price_Attr_tbl(1).pricing_attribute96	:=	p_pricing_attribute96;
   l_Price_Attr_tbl(1).pricing_attribute97	:=	p_pricing_attribute97;
   l_Price_Attr_tbl(1).pricing_attribute98	:=	p_pricing_attribute98;
   l_Price_Attr_tbl(1).pricing_attribute99	:=	p_pricing_attribute99;
   l_Price_Attr_tbl(1).pricing_attribute100:=	p_pricing_attribute100;

/* Begin Bug7219268 */
IF jtf_usr_hks.Ok_To_Execute('CS_CHARGE_DETAILS_PVT',
                                      'Call_Pricing_Item',
                                      'B', 'C')  THEN
    CS_CHARGE_DETAILS_CUHK.Call_Pricing_Item_Pre ( p_inventory_item_id => p_inventory_item_id,
                                                   p_price_list_id     => p_price_list_id,
                                                   p_uom_code	       => p_uom_code,
                                                   p_currency_code     => p_currency_code,
                                                   p_quantity	       => p_quantity,
                                                   p_org_id            => p_org_id,
                                                   x_list_price	       => x_list_price,
                                                   p_in_price_attr_tbl => l_Price_Attr_tbl,
                                                   x_return_status     => lx_return_status,
                                                   x_msg_count	       => lx_msg_count,
                                                   x_msg_data	       => lx_msg_data );
    x_return_status := lx_return_status;
    x_msg_data := lx_msg_data;
    x_msg_count := lx_msg_count;

    IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('CS', 'CS_API_CHG_ERR_PRE_CUST_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
  /* End Bug7219268 */

   --DBMS_Output.Put_Line('Calling Pricing API.  Price List='|| to_char(p_price_list_id));
  IF x_list_price is NULL THEN
   -- Call the pricing API.
    ASO_PRICING_INT.Pricing_Item(
		    p_api_version_number => 1.0,
		    p_init_msg_list	=> P_Init_Msg_List,
		    p_commit		=> P_Commit,
		    p_control_rec       => l_control_rec,
		    p_qte_header_rec  => l_qte_header_rec,
		    p_hd_shipment_rec => l_hd_shipment_rec,
		    p_hd_price_attr_tbl     => l_hd_price_attr_tbl,
		    p_qte_line_rec => l_qte_line_rec,
		    p_qte_line_dtl_rec  => l_qte_line_dtl_rec,
		    p_ln_shipment_rec   => l_ln_shipment_rec,
                    p_ln_price_attr_tbl     => l_price_attr_tbl,
		    x_qte_line_tbl => lx_qte_out_line_tbl,
		    x_qte_line_dtl_tbl   => lx_qte_line_dtl_tbl,
		    x_price_adj_tbl      => lx_price_adj_tbl,
		    x_price_adj_attr_tbl => lx_price_adj_attr_tbl,
		    x_price_adj_rltship_tbl => lx_price_adj_rltship_tbl,
		    x_return_status => lx_return_status,
		    x_msg_data     => lx_msg_data,
		    x_msg_count     => lx_msg_count);

    x_return_status := lx_return_status;
    x_msg_data := lx_msg_data;
    x_msg_count := lx_msg_count;

  -- Check Return Status - Refer ASOIPRCB.pls for details
     IF lx_return_status = FND_API.G_RET_STS_SUCCESS THEN

         FOR i IN 1..lx_qte_out_line_tbl.count LOOP

		 -- IF lx_qte_out_line_tbl(i).Inventory_Item_id = p_inventory_item_id then
		 x_list_price := lx_qte_out_line_tbl(i).Line_List_Price;

         --dbms_output.put_line('item_id => '|| to_char(lx_qte_out_line_tbl(i).inventory_item_id));
	     -- dbms_output.put_line('list_price => '|| to_char(lx_qte_out_line_tbl(i).line_list_price));

          END LOOP;

      ELSE
      --FND_MESSAGE.Set_Name('CS', 'CS_CHG_API_ASO_PRICING_ERROR');
      --FND_MESSAGE.SET_TOKEN('TEXT', x_msg_data);
      --FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
  END IF;
   EXCEPTION

      WHEN e_pricing_warning THEN
		 FND_MESSAGE.Set_Encoded(x_msg_data);
		 app_exception.raise_exception;

      WHEN OTHERS THEN
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data  => x_msg_data);
         x_return_status := FND_API.G_RET_STS_ERROR;

END Call_Pricing_Item;

END Cs_pricing_item_pkg;

/
