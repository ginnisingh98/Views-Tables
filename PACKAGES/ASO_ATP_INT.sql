--------------------------------------------------------
--  DDL for Package ASO_ATP_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_ATP_INT" AUTHID CURRENT_USER as
/* $Header: asoiatps.pls 120.2 2005/06/30 15:59:19 appldev ship $ */
-- Start of Comments
-- Package name     : aso_atp_int
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

--Action Code
ATPQUERY 		CONSTANT INTEGER := 100;

--Record Structure for getting ATP results

TYPE ATP_Rec_Typ is RECORD (
Inventory_Item_Id               NUMBER,
Inventory_Item_Name		       VARCHAR2(240),
Inventory_Item_Description      VARCHAR2(240),
Padded_Concatenated_Segments    VARCHAR2(90),
Source_Organization_Id          NUMBER,
Source_Organization_Code	       VARCHAR2(7),
Source_Organization_Name        VARCHAR2(240),
Identifier                      NUMBER,
Customer_Id                  	  NUMBER,
Customer_Site_Id                NUMBER,
Quantity_Ordered                NUMBER,
Quantity_UOM                    VARCHAR2(3),
UOM_Meaning                     VARCHAR2(25),
Requested_Ship_Date             DATE,
Ship_Date                       DATE,
Available_Quantity              NUMBER,
Request_Date_Quantity           NUMBER,
Error_Code			       NUMBER,
error_description               varchar2(80),
Message                         VARCHAR2(2000),
request_date_type               VARCHAR2(30),
request_date_type_meaning       VARCHAR2(240),
demand_class_code               VARCHAR2(30),
demand_class_meaning            VARCHAR2(80),
ship_set_name                   VARCHAR2(30),
arrival_set_name                VARCHAR2(30),
line_number                     varchar2(80),
group_ship_date                 Date,
requested_arrival_date          Date,
ship_method_code                varchar2(30),
ship_method_meaning             varchar2(80),
quantity_on_hand                Number,
shipment_id                     Number,
quote_header_id                 Number,
calling_module                  Number,
quote_number                    Number,
ato_line_id                     Number,
ref_line_id                     Number,
top_model_line_id               Number,
action                          Number,
arrival_date                    DATE,
organization_id                 Number,
component_code                  varchar2(1200),
component_sequence_id           Number,
included_item_flag              Number,
cascade_model_info_to_comp      Number,
ship_to_party_site_id           Number,
country                         varchar2(60),
state                           varchar2(60),
city                            varchar2(60),
postal_code                     varchar2(60),
match_item_id                   number
);

TYPE ATP_Tbl_Typ IS TABLE OF ATP_Rec_Typ
INDEX BY BINARY_INTEGER;

--   API Name:  Check_ATP
--   Type    :  Public
--   Pre-Req :

PROCEDURE Check_ATP(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    p_qte_line_tbl		 IN   ASO_QUOTE_PUB.qte_line_tbl_type,
    p_shipment_tbl		 IN   ASO_QUOTE_PUB.shipment_tbl_type,
    x_return_status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_msg_count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    x_msg_data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_atp_tbl                    OUT NOCOPY /* file.sql.39 change */   aso_atp_int.atp_tbl_typ
       );

PROCEDURE Check_ATP(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    p_qte_header_rec             IN   ASO_QUOTE_PUB.QTE_HEADER_REC_TYPE,
    p_qte_line_tbl		        IN   ASO_QUOTE_PUB.qte_line_tbl_type := ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL,
    p_shipment_tbl		        IN   ASO_QUOTE_PUB.shipment_tbl_type := ASO_QUOTE_PUB.G_MISS_SHIPMENT_TBL,
    p_entire_quote_flag          IN   VARCHAR2 :='N',
    x_return_status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    x_msg_count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_msg_data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_atp_tbl                    OUT NOCOPY /* file.sql.39 change */  aso_atp_int.atp_tbl_typ
       );

PROCEDURE update_configuration(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_qte_header_rec             IN   ASO_QUOTE_PUB.QTE_HEADER_REC_TYPE,
    p_qte_line_dtl_tbl		   IN   ASO_QUOTE_PUB.qte_line_dtl_tbl_type := ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL,
    x_return_status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    x_msg_count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_msg_data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );

End aso_atp_int;

 

/
