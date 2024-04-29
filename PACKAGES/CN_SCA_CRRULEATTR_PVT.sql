--------------------------------------------------------
--  DDL for Package CN_SCA_CRRULEATTR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SCA_CRRULEATTR_PVT" AUTHID CURRENT_USER as
-- $Header: cnvscrrs.pls 120.1 2005/08/07 21:32:22 vensrini noship $ --+
TYPE credit_rule_attr_rec is RECORD (
   Sca_Rule_Attribute_Id        cn_sca_rule_attributes.sca_rule_attribute_id%TYPE,
   Transaction_source   	cn_sca_rule_attributes.transaction_source%TYPE,
   Destination_column 		cn_sca_rule_attributes.src_column_name%TYPE,
   User_Name 			cn_sca_rule_attributes.user_column_name%TYPE,
   Value_Set_Id 	        fnd_flex_value_sets.flex_value_set_id%TYPE,
   Data_Type 			cn_sca_rule_attributes.datatype%TYPE,
   Source_Column 		cn_sca_rule_attributes.trx_src_column_name%TYPE    ,
   Enable_Flag 		        cn_sca_rule_attributes.enabled_flag%TYPE  ,
   Attribute_Category 		cn_sca_rule_attributes.attribute_category%TYPE 	:= NULL,
   Attribute1                   cn_sca_rule_attributes.attribute1%TYPE		:= NULL,
   Attribute2                   cn_sca_rule_attributes.attribute2%TYPE		:= NULL,
   Attribute3                   cn_sca_rule_attributes.attribute3%TYPE		:= NULL,
   Attribute4                   cn_sca_rule_attributes.attribute4%TYPE		:= NULL,
   Attribute5                   cn_sca_rule_attributes.attribute5%TYPE		:= NULL,
   Attribute6                   cn_sca_rule_attributes.attribute6%TYPE		:= NULL,
   Attribute7                   cn_sca_rule_attributes.attribute7%TYPE		:= NULL,
   Attribute8                   cn_sca_rule_attributes.attribute8%TYPE		:= NULL,
   Attribute9                   cn_sca_rule_attributes.attribute9%TYPE		:= NULL,
   Attribute10                  cn_sca_rule_attributes.attribute10%TYPE		:= NULL,
   Attribute11                  cn_sca_rule_attributes.attribute11%TYPE		:= NULL,
   Attribute12                  cn_sca_rule_attributes.attribute12%TYPE		:= NULL,
   Attribute13                  cn_sca_rule_attributes.attribute13%TYPE		:= NULL,
   Attribute14                  cn_sca_rule_attributes.attribute14%TYPE		:= NULL,
   Attribute15                  cn_sca_rule_attributes.attribute15%TYPE		:= NULL,
   Object_Version_Number cn_sca_rule_attributes.object_version_number%TYPE
);

TYPE credit_rule_attr_tbl_type IS
   TABLE OF credit_rule_attr_rec INDEX BY BINARY_INTEGER ;

G_MISS_SCACRRR_REC  credit_rule_attr_rec;
G_MISS_SCACRRR_REC_TB  credit_rule_attr_tbl_type;

PROCEDURE Create_Credit_RuleAttr
  (     p_api_version                 IN NUMBER,
        p_init_msg_list               IN VARCHAR2 := FND_API.G_FALSE,
       	p_commit                      IN VARCHAR2 := FND_API.G_FALSE,
    	p_valdiation_level            IN VARCHAR2 := FND_API.G_FALSE,
        p_org_id                      IN  cn_sca_rule_attributes.org_id%TYPE, -- MOAC Change
     	p_credit_rule_attr_rec         IN  credit_rule_attr_rec,
     	x_return_status               OUT NOCOPY VARCHAR2,
     	x_msg_count                   OUT NOCOPY NUMBER,
     	x_msg_data                    OUT NOCOPY VARCHAR2
     );


PROCEDURE Update_Credit_RuleAttr
     (
     p_api_version                 IN NUMBER,
     p_init_msg_list               IN VARCHAR2 := FND_API.G_FALSE,
     p_commit                      IN VARCHAR2,
     p_valdiation_level            IN VARCHAR2,
     p_org_id                      IN  cn_sca_rule_attributes.org_id%TYPE, -- MOAC Change
     p_credit_rule_attr_rec        IN  credit_rule_attr_rec,
--     p_old_credit_rule_attr_rec    IN  credit_rule_attr_rec,
     x_return_status               OUT NOCOPY VARCHAR2,
     x_msg_count                   OUT NOCOPY NUMBER,
     x_msg_data                    OUT NOCOPY VARCHAR2
     );



/*PROCEDURE Get_Credit_Rule_Attr
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
   p_start_record                IN      NUMBER := -1,
   p_fetch_size                  IN      NUMBER := -1,
   p_search_uname                IN      cn_sca_rule_attributes.user_column_name%TYPE := '%' ,
   p_search_trx_source           IN      cn_sca_rule_attributes.transaction_source%TYPE,
   x_credit_rule_attr            OUT NOCOPY     credit_rule_attr_tbl_type,
   x_total_record                OUT NOCOPY     NUMBER,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2
 );*/

 PROCEDURE Generate_Package
      ( p_api_version       IN NUMBER,
 	p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
 	p_commit            IN VARCHAR2 := FND_API.G_FALSE,
 	p_validation_level  IN  NUMBER  := FND_API.G_VALID_LEVEL_FULL,
        p_org_id            IN NUMBER, -- MOAC Change
 	x_return_status     OUT NOCOPY VARCHAR2,
 	x_msg_count         OUT NOCOPY NUMBER,
 	x_msg_data          OUT NOCOPY VARCHAR2
 	);



END CN_SCA_CRRULEATTR_PVT;

 

/
