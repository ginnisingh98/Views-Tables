--------------------------------------------------------
--  DDL for Package MRP_SRC_ASSIGNMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_SRC_ASSIGNMENT_PUB" AUTHID CURRENT_USER AS
/* $Header: MRPPASNS.pls 115.2 99/07/16 12:31:38 porting ship $ */

--  Assignment_Set record type

TYPE Assignment_Set_Rec_Type IS RECORD
(   Assignment_Set_Id             NUMBER         := FND_API.G_MISS_NUM
,   Assignment_Set_Name           VARCHAR2(30)   := FND_API.G_MISS_CHAR
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
,   Program_Application_Id        NUMBER         := FND_API.G_MISS_NUM
,   Program_Id                    NUMBER         := FND_API.G_MISS_NUM
,   Program_Update_Date           DATE           := FND_API.G_MISS_DATE
,   Request_Id                    NUMBER         := FND_API.G_MISS_NUM
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
);

TYPE Assignment_Set_Tbl_Type IS TABLE OF Assignment_Set_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Assignment_Set value record type

TYPE Assignment_Set_Val_Rec_Type IS RECORD
(   null_element NUMBER := NULL
);

TYPE Assignment_Set_Val_Tbl_Type IS TABLE OF Assignment_Set_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Assignment record type

TYPE Assignment_Rec_Type IS RECORD
(   Assignment_Id                 NUMBER         := FND_API.G_MISS_NUM
,   Assignment_Set_Id             NUMBER         := FND_API.G_MISS_NUM
,   Assignment_Type               NUMBER         := FND_API.G_MISS_NUM
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
,   Category_Id                   NUMBER         := FND_API.G_MISS_NUM
,   Category_Set_Id               NUMBER         := FND_API.G_MISS_NUM
,   Created_By                    NUMBER         := FND_API.G_MISS_NUM
,   Creation_Date                 DATE           := FND_API.G_MISS_DATE
,   Customer_Id                   NUMBER         := FND_API.G_MISS_NUM
,   Inventory_Item_Id             NUMBER         := FND_API.G_MISS_NUM
,   Last_Updated_By               NUMBER         := FND_API.G_MISS_NUM
,   Last_Update_Date              DATE           := FND_API.G_MISS_DATE
,   Last_Update_Login             NUMBER         := FND_API.G_MISS_NUM
,   Organization_Id               NUMBER         := FND_API.G_MISS_NUM
,   Program_Application_Id        NUMBER         := FND_API.G_MISS_NUM
,   Program_Id                    NUMBER         := FND_API.G_MISS_NUM
,   Program_Update_Date           DATE           := FND_API.G_MISS_DATE
,   Request_Id                    NUMBER         := FND_API.G_MISS_NUM
,   Secondary_Inventory           VARCHAR2(10)   := FND_API.G_MISS_CHAR
,   Ship_To_Site_Id               NUMBER         := FND_API.G_MISS_NUM
,   Sourcing_Rule_Id              NUMBER         := FND_API.G_MISS_NUM
,   Sourcing_Rule_Type            NUMBER         := FND_API.G_MISS_NUM
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
);

TYPE Assignment_Tbl_Type IS TABLE OF Assignment_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Assignment value record type

TYPE Assignment_Val_Rec_Type IS RECORD
(   null_element NUMBER := NULL
);

TYPE Assignment_Val_Tbl_Type IS TABLE OF Assignment_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Variables representing missing records and tables

G_MISS_ASSIGNMENT_SET_REC     Assignment_Set_Rec_Type;
G_MISS_ASSIGNMENT_SET_VAL_REC Assignment_Set_Val_Rec_Type;
G_MISS_ASSIGNMENT_SET_TBL     Assignment_Set_Tbl_Type;
G_MISS_ASSIGNMENT_SET_VAL_TBL Assignment_Set_Val_Tbl_Type;
G_MISS_ASSIGNMENT_REC         Assignment_Rec_Type;
G_MISS_ASSIGNMENT_VAL_REC     Assignment_Val_Rec_Type;
G_MISS_ASSIGNMENT_TBL         Assignment_Tbl_Type;
G_MISS_ASSIGNMENT_VAL_TBL     Assignment_Val_Tbl_Type;

--  Start of Comments
--  API name    Process_Assignment
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

PROCEDURE Process_Assignment
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
,   p_Assignment_Set_rec            IN  Assignment_Set_Rec_Type :=
                                        G_MISS_ASSIGNMENT_SET_REC
,   p_Assignment_Set_val_rec        IN  Assignment_Set_Val_Rec_Type :=
                                        G_MISS_ASSIGNMENT_SET_VAL_REC
,   p_Assignment_tbl                IN  Assignment_Tbl_Type :=
                                        G_MISS_ASSIGNMENT_TBL
,   p_Assignment_val_tbl            IN  Assignment_Val_Tbl_Type :=
                                        G_MISS_ASSIGNMENT_VAL_TBL
,   x_Assignment_Set_rec            OUT Assignment_Set_Rec_Type
,   x_Assignment_Set_val_rec        OUT Assignment_Set_Val_Rec_Type
,   x_Assignment_tbl                OUT Assignment_Tbl_Type
,   x_Assignment_val_tbl            OUT Assignment_Val_Tbl_Type
);

--  Start of Comments
--  API name    Lock_Assignment
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

PROCEDURE Lock_Assignment
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
,   p_Assignment_Set_rec            IN  Assignment_Set_Rec_Type :=
                                        G_MISS_ASSIGNMENT_SET_REC
,   p_Assignment_Set_val_rec        IN  Assignment_Set_Val_Rec_Type :=
                                        G_MISS_ASSIGNMENT_SET_VAL_REC
,   p_Assignment_tbl                IN  Assignment_Tbl_Type :=
                                        G_MISS_ASSIGNMENT_TBL
,   p_Assignment_val_tbl            IN  Assignment_Val_Tbl_Type :=
                                        G_MISS_ASSIGNMENT_VAL_TBL
,   x_Assignment_Set_rec            OUT Assignment_Set_Rec_Type
,   x_Assignment_Set_val_rec        OUT Assignment_Set_Val_Rec_Type
,   x_Assignment_tbl                OUT Assignment_Tbl_Type
,   x_Assignment_val_tbl            OUT Assignment_Val_Tbl_Type
);

--  Start of Comments
--  API name    Get_Assignment
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

PROCEDURE Get_Assignment
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
,   p_Assignment_Set_Id             IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   x_Assignment_Set_rec            OUT Assignment_Set_Rec_Type
,   x_Assignment_Set_val_rec        OUT Assignment_Set_Val_Rec_Type
,   x_Assignment_tbl                OUT Assignment_Tbl_Type
,   x_Assignment_val_tbl            OUT Assignment_Val_Tbl_Type
);

END MRP_Src_Assignment_PUB;

 

/
