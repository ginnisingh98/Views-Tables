--------------------------------------------------------
--  DDL for Package OE_ITORD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ITORD_PUB" AUTHID CURRENT_USER AS
/* $Header: OEXPITOS.pls 120.1 2008/01/24 08:36:55 smanian noship $ */

TYPE Item_Orderability_Import_Rec IS RECORD
(
    ORG_ID               number
 ,  INVENTORY_ITEM_ID    number
 ,  ITEM_CATEGORY_ID     number
 ,  ITEM_LEVEL           varchar2(1)
 ,  GENERALLY_AVAILABLE  varchar2(1)
 ,  RULE_LEVEL              VARCHAR2(30)
 ,  CUSTOMER_ID             NUMBER
 ,  CUSTOMER_CLASS_ID       NUMBER
 ,  CUSTOMER_CATEGORY_CODE  VARCHAR2(30)
 ,  REGION_ID               NUMBER
 ,  ORDER_TYPE_ID           NUMBER
 ,  SHIP_TO_LOCATION_ID     NUMBER
 ,  SALES_CHANNEL_CODE      VARCHAR2(30)
 ,  SALES_PERSON_ID         NUMBER
 ,  END_CUSTOMER_ID         NUMBER
 ,  BILL_TO_LOCATION_ID     NUMBER
 ,  DELIVER_TO_LOCATION_ID  NUMBER
 ,  ENABLE_FLAG             VARCHAR2(1)
 ,  CREATED_BY           NUMBER
 ,  CREATION_DATE        DATE
 ,  LAST_UPDATED_BY      NUMBER
 ,  LAST_UPDATE_DATE     DATE
 , CONTEXT                 VARCHAR2(250)
 ,  ATTRIBUTE1              VARCHAR2(250)
 , ATTRIBUTE2              VARCHAR2(250)
 , ATTRIBUTE3              VARCHAR2(250)
 , ATTRIBUTE4              VARCHAR2(250)
 , ATTRIBUTE5              VARCHAR2(250)
 , ATTRIBUTE6              VARCHAR2(250)
 , ATTRIBUTE7              VARCHAR2(250)
 , ATTRIBUTE8              VARCHAR2(250)
 , ATTRIBUTE9              VARCHAR2(250)
 , ATTRIBUTE10             VARCHAR2(250)
 , ATTRIBUTE11             VARCHAR2(250)
 , ATTRIBUTE12             VARCHAR2(250)
 , ATTRIBUTE13             VARCHAR2(250)
 , ATTRIBUTE14             VARCHAR2(250)
 , ATTRIBUTE15             VARCHAR2(250)
 , ATTRIBUTE16             VARCHAR2(250)
 , ATTRIBUTE17             VARCHAR2(250)
 , ATTRIBUTE18             VARCHAR2(250)
 , ATTRIBUTE19             VARCHAR2(250)
 , ATTRIBUTE20             VARCHAR2(250)
 , status		   VARCHAR2(1)
 , msg_count              number
 , msg_data               VARCHAR2(5000)
);

TYPE Item_Orderability_Import_Tbl  IS TABLE OF Item_Orderability_Import_Rec
INDEX BY BINARY_INTEGER;


Procedure Import_Item_orderability_rules (  p_Item_Orderability_Import_Tbl IN OUT NOCOPY OE_ITORD_PUB.Item_Orderability_Import_Tbl
                                           ,p_commit_flag IN Varchar2 DEFAULT 'N' );


Procedure  Check_required_fields ( p_Item_Orderability_Import_Rec IN OUT NOCOPY OE_ITORD_PUB.Item_Orderability_Import_Rec );


Procedure  Validate_required_fields ( p_Item_Orderability_Import_Rec IN OUT NOCOPY OE_ITORD_PUB.Item_Orderability_Import_Rec );


Procedure Validate_conditional_fields ( p_Item_Orderability_Import_Rec IN OUT NOCOPY OE_ITORD_PUB.Item_Orderability_Import_Rec );


Procedure Check_duplicate_rules ( p_Item_Orderability_Import_Rec IN OUT NOCOPY  OE_ITORD_PUB.Item_Orderability_Import_Rec );


Procedure get_rule_coulumn_details( p_Item_Orderability_Import_Rec IN OE_ITORD_PUB.Item_Orderability_Import_Rec ,
				    x_rule_level_column  OUT NOCOPY VARCHAR2,
				    x_rule_level_value   OUT NOCOPY VARCHAR2,
				    x_data_type          OUT NOCOPY VARCHAR2
   			           );


Procedure Validate_rules_DFF (p_Item_Orderability_Import_Rec IN OUT NOCOPY OE_ITORD_PUB.Item_Orderability_Import_Rec );

Procedure insert_rules( p_Item_Orderability_Import_Rec IN OUT NOCOPY OE_ITORD_PUB.Item_Orderability_Import_Rec );

END OE_ITORD_PUB;

/
