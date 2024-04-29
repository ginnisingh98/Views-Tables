--------------------------------------------------------
--  DDL for Package MRP_SOURCING_RULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_SOURCING_RULE_PUB" AUTHID CURRENT_USER AS
/* $Header: MRPPSRLS.pls 120.1 2005/06/16 11:49:27 ichoudhu noship $ */

--  Sourcing_Rule record type

TYPE Sourcing_Rule_Rec_Type IS RECORD
(   Sourcing_Rule_Id              NUMBER         := FND_API.G_MISS_NUM
,   Attribute1                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute10                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute11                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute12                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute13                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute14                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute15                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute2                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute3                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute4                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute5                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute6                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute7                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute8                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute9                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute_Category            VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   Created_By                    NUMBER         := FND_API.G_MISS_NUM
,   Creation_Date                 DATE           := FND_API.G_MISS_DATE
,   Description                   VARCHAR2(80)   := FND_API.G_MISS_CHAR
,   Last_Updated_By               NUMBER         := FND_API.G_MISS_NUM
,   Last_Update_Date              DATE           := FND_API.G_MISS_DATE
,   Last_Update_Login             NUMBER         := FND_API.G_MISS_NUM
,   Organization_Id               NUMBER         := FND_API.G_MISS_NUM
,   Planning_Active               NUMBER         := FND_API.G_MISS_NUM
,   Program_Application_Id        NUMBER         := FND_API.G_MISS_NUM
,   Program_Id                    NUMBER         := FND_API.G_MISS_NUM
,   Program_Update_Date           DATE           := FND_API.G_MISS_DATE
,   Request_Id                    NUMBER         := FND_API.G_MISS_NUM
,   Sourcing_Rule_Name            VARCHAR2(50)   := FND_API.G_MISS_CHAR
,   Sourcing_Rule_Type            NUMBER         := FND_API.G_MISS_NUM
,   Status                        NUMBER         := FND_API.G_MISS_NUM
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
);

TYPE Sourcing_Rule_Tbl_Type IS TABLE OF Sourcing_Rule_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Sourcing_Rule value record type

TYPE Sourcing_Rule_Val_Rec_Type IS RECORD
(   null_element NUMBER := NULL
);

TYPE Sourcing_Rule_Val_Tbl_Type IS TABLE OF Sourcing_Rule_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Receiving_Org record type

TYPE Receiving_Org_Rec_Type IS RECORD
(   Sr_Receipt_Id                 NUMBER         := FND_API.G_MISS_NUM
,   Attribute1                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute10                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute11                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute12                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute13                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute14                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute15                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute2                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute3                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute4                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute5                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute6                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute7                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute8                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute9                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute_Category            VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   Created_By                    NUMBER         := FND_API.G_MISS_NUM
,   Creation_Date                 DATE           := FND_API.G_MISS_DATE
,   Disable_Date                  DATE           := FND_API.G_MISS_DATE
,   Effective_Date                DATE           := FND_API.G_MISS_DATE
,   Last_Updated_By               NUMBER         := FND_API.G_MISS_NUM
,   Last_Update_Date              DATE           := FND_API.G_MISS_DATE
,   Last_Update_Login             NUMBER         := FND_API.G_MISS_NUM
,   Program_Application_Id        NUMBER         := FND_API.G_MISS_NUM
,   Program_Id                    NUMBER         := FND_API.G_MISS_NUM
,   Program_Update_Date           DATE           := FND_API.G_MISS_DATE
,   Receipt_Organization_Id       NUMBER         := FND_API.G_MISS_NUM
,   Request_Id                    NUMBER         := FND_API.G_MISS_NUM
,   Sourcing_Rule_Id              NUMBER         := FND_API.G_MISS_NUM
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
);

TYPE Receiving_Org_Tbl_Type IS TABLE OF Receiving_Org_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Receiving_Org value record type

TYPE Receiving_Org_Val_Rec_Type IS RECORD
(   null_element NUMBER := NULL
);

TYPE Receiving_Org_Val_Tbl_Type IS TABLE OF Receiving_Org_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Shipping_Org record type

TYPE Shipping_Org_Rec_Type IS RECORD
(   Sr_Source_Id                  NUMBER         := FND_API.G_MISS_NUM
,   Allocation_Percent            NUMBER         := FND_API.G_MISS_NUM
,   Attribute1                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute10                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute11                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute12                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute13                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute14                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute15                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute2                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute3                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute4                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute5                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute6                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute7                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute8                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute9                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   Attribute_Category            VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   Created_By                    NUMBER         := FND_API.G_MISS_NUM
,   Creation_Date                 DATE           := FND_API.G_MISS_DATE
,   Last_Updated_By               NUMBER         := FND_API.G_MISS_NUM
,   Last_Update_Date              DATE           := FND_API.G_MISS_DATE
,   Last_Update_Login             NUMBER         := FND_API.G_MISS_NUM
,   Program_Application_Id        NUMBER         := FND_API.G_MISS_NUM
,   Program_Id                    NUMBER         := FND_API.G_MISS_NUM
,   Program_Update_Date           DATE           := FND_API.G_MISS_DATE
,   Rank                          NUMBER         := FND_API.G_MISS_NUM
,   Request_Id                    NUMBER         := FND_API.G_MISS_NUM
,   Secondary_Inventory           VARCHAR2(10)   := FND_API.G_MISS_CHAR
,   Ship_Method                   VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   Source_Organization_Id        NUMBER         := FND_API.G_MISS_NUM
,   Source_Type                   NUMBER         := FND_API.G_MISS_NUM
,   Sr_Receipt_Id                 NUMBER         := FND_API.G_MISS_NUM
,   Vendor_Id                     NUMBER         := FND_API.G_MISS_NUM
,   Vendor_Site_Id                NUMBER         := FND_API.G_MISS_NUM
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   Receiving_Org_index           NUMBER         := FND_API.G_MISS_NUM
);

TYPE Shipping_Org_Tbl_Type IS TABLE OF Shipping_Org_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Shipping_Org value record type

TYPE Shipping_Org_Val_Rec_Type IS RECORD
(   null_element NUMBER := NULL
);

TYPE Shipping_Org_Val_Tbl_Type IS TABLE OF Shipping_Org_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Variables representing missing records and tables

G_MISS_SOURCING_RULE_REC      Sourcing_Rule_Rec_Type;
G_MISS_SOURCING_RULE_VAL_REC  Sourcing_Rule_Val_Rec_Type;
G_MISS_SOURCING_RULE_TBL      Sourcing_Rule_Tbl_Type;
G_MISS_SOURCING_RULE_VAL_TBL  Sourcing_Rule_Val_Tbl_Type;
G_MISS_RECEIVING_ORG_REC      Receiving_Org_Rec_Type;
G_MISS_RECEIVING_ORG_VAL_REC  Receiving_Org_Val_Rec_Type;
G_MISS_RECEIVING_ORG_TBL      Receiving_Org_Tbl_Type;
G_MISS_RECEIVING_ORG_VAL_TBL  Receiving_Org_Val_Tbl_Type;
G_MISS_SHIPPING_ORG_REC       Shipping_Org_Rec_Type;
G_MISS_SHIPPING_ORG_VAL_REC   Shipping_Org_Val_Rec_Type;
G_MISS_SHIPPING_ORG_TBL       Shipping_Org_Tbl_Type;
G_MISS_SHIPPING_ORG_VAL_TBL   Shipping_Org_Val_Tbl_Type;

--  Start of Comments
--  API name    Process_Sourcing_Rule
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Process_Sourcing_Rule
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_Sourcing_Rule_rec             IN  Sourcing_Rule_Rec_Type :=
                                        G_MISS_SOURCING_RULE_REC
,   p_Sourcing_Rule_val_rec         IN  Sourcing_Rule_Val_Rec_Type :=
                                        G_MISS_SOURCING_RULE_VAL_REC
,   p_Receiving_Org_tbl             IN  Receiving_Org_Tbl_Type :=
                                        G_MISS_RECEIVING_ORG_TBL
,   p_Receiving_Org_val_tbl         IN  Receiving_Org_Val_Tbl_Type :=
                                        G_MISS_RECEIVING_ORG_VAL_TBL
,   p_Shipping_Org_tbl              IN  Shipping_Org_Tbl_Type :=
                                        G_MISS_SHIPPING_ORG_TBL
,   p_Shipping_Org_val_tbl          IN  Shipping_Org_Val_Tbl_Type :=
                                        G_MISS_SHIPPING_ORG_VAL_TBL
,   x_Sourcing_Rule_rec             OUT NOCOPY Sourcing_Rule_Rec_Type
,   x_Sourcing_Rule_val_rec         OUT NOCOPY Sourcing_Rule_Val_Rec_Type
,   x_Receiving_Org_tbl             OUT NOCOPY Receiving_Org_Tbl_Type
,   x_Receiving_Org_val_tbl         OUT NOCOPY Receiving_Org_Val_Tbl_Type
,   x_Shipping_Org_tbl              OUT NOCOPY Shipping_Org_Tbl_Type
,   x_Shipping_Org_val_tbl          OUT NOCOPY Shipping_Org_Val_Tbl_Type
);

--  Start of Comments
--  API name    Lock_Sourcing_Rule
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Lock_Sourcing_Rule
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_Sourcing_Rule_rec             IN  Sourcing_Rule_Rec_Type :=
                                        G_MISS_SOURCING_RULE_REC
,   p_Sourcing_Rule_val_rec         IN  Sourcing_Rule_Val_Rec_Type :=
                                        G_MISS_SOURCING_RULE_VAL_REC
,   p_Receiving_Org_tbl             IN  Receiving_Org_Tbl_Type :=
                                        G_MISS_RECEIVING_ORG_TBL
,   p_Receiving_Org_val_tbl         IN  Receiving_Org_Val_Tbl_Type :=
                                        G_MISS_RECEIVING_ORG_VAL_TBL
,   p_Shipping_Org_tbl              IN  Shipping_Org_Tbl_Type :=
                                        G_MISS_SHIPPING_ORG_TBL
,   p_Shipping_Org_val_tbl          IN  Shipping_Org_Val_Tbl_Type :=
                                        G_MISS_SHIPPING_ORG_VAL_TBL
,   x_Sourcing_Rule_rec             OUT NOCOPY Sourcing_Rule_Rec_Type
,   x_Sourcing_Rule_val_rec         OUT NOCOPY Sourcing_Rule_Val_Rec_Type
,   x_Receiving_Org_tbl             OUT NOCOPY Receiving_Org_Tbl_Type
,   x_Receiving_Org_val_tbl         OUT NOCOPY Receiving_Org_Val_Tbl_Type
,   x_Shipping_Org_tbl              OUT NOCOPY Shipping_Org_Tbl_Type
,   x_Shipping_Org_val_tbl          OUT NOCOPY Shipping_Org_Val_Tbl_Type
);

--  Start of Comments
--  API name    Get_Sourcing_Rule
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Get_Sourcing_Rule
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_Sourcing_Rule_Id              IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   x_Sourcing_Rule_rec             OUT NOCOPY Sourcing_Rule_Rec_Type
,   x_Sourcing_Rule_val_rec         OUT NOCOPY Sourcing_Rule_Val_Rec_Type
,   x_Receiving_Org_tbl             OUT NOCOPY Receiving_Org_Tbl_Type
,   x_Receiving_Org_val_tbl         OUT NOCOPY Receiving_Org_Val_Tbl_Type
,   x_Shipping_Org_tbl              OUT NOCOPY Shipping_Org_Tbl_Type
,   x_Shipping_Org_val_tbl          OUT NOCOPY Shipping_Org_Val_Tbl_Type
);

END MRP_Sourcing_Rule_PUB;

 

/
