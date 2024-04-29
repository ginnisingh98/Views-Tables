--------------------------------------------------------
--  DDL for Package MRP_VALIDATE_ASSIGNMENT_SET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_VALIDATE_ASSIGNMENT_SET" AUTHID CURRENT_USER AS
/* $Header: MRPLASTS.pls 120.1 2005/06/16 09:51:00 ichoudhu noship $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_Assignment_Set_rec            IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
,   p_old_Assignment_Set_rec        IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type :=
                                        MRP_Src_Assignment_PUB.G_MISS_ASSIGNMENT_SET_REC
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_Assignment_Set_rec            IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
,   p_old_Assignment_Set_rec        IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type :=
                                        MRP_Src_Assignment_PUB.G_MISS_ASSIGNMENT_SET_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_Assignment_Set_rec            IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
);

--  Entity attribute validation functions.


--  Function Val_Assignment_Set_Name

FUNCTION Val_Assignment_Set_Name
(   p_Assignment_Set_Name           IN  VARCHAR2
)   RETURN BOOLEAN;

--  Function Val_Attribute1

FUNCTION Val_Attribute1
(   p_Attribute1                    IN  VARCHAR2
)   RETURN BOOLEAN;

--  Function Val_Attribute10

FUNCTION Val_Attribute10
(   p_Attribute10                   IN  VARCHAR2
)   RETURN BOOLEAN;

--  Function Val_Attribute11

FUNCTION Val_Attribute11
(   p_Attribute11                   IN  VARCHAR2
)   RETURN BOOLEAN;

--  Function Val_Attribute12

FUNCTION Val_Attribute12
(   p_Attribute12                   IN  VARCHAR2
)   RETURN BOOLEAN;

--  Function Val_Attribute13

FUNCTION Val_Attribute13
(   p_Attribute13                   IN  VARCHAR2
)   RETURN BOOLEAN;

--  Function Val_Attribute14

FUNCTION Val_Attribute14
(   p_Attribute14                   IN  VARCHAR2
)   RETURN BOOLEAN;

--  Function Val_Attribute15

FUNCTION Val_Attribute15
(   p_Attribute15                   IN  VARCHAR2
)   RETURN BOOLEAN;

--  Function Val_Attribute2

FUNCTION Val_Attribute2
(   p_Attribute2                    IN  VARCHAR2
)   RETURN BOOLEAN;

--  Function Val_Attribute3

FUNCTION Val_Attribute3
(   p_Attribute3                    IN  VARCHAR2
)   RETURN BOOLEAN;

--  Function Val_Attribute4

FUNCTION Val_Attribute4
(   p_Attribute4                    IN  VARCHAR2
)   RETURN BOOLEAN;

--  Function Val_Attribute5

FUNCTION Val_Attribute5
(   p_Attribute5                    IN  VARCHAR2
)   RETURN BOOLEAN;

--  Function Val_Attribute6

FUNCTION Val_Attribute6
(   p_Attribute6                    IN  VARCHAR2
)   RETURN BOOLEAN;

--  Function Val_Attribute7

FUNCTION Val_Attribute7
(   p_Attribute7                    IN  VARCHAR2
)   RETURN BOOLEAN;

--  Function Val_Attribute8

FUNCTION Val_Attribute8
(   p_Attribute8                    IN  VARCHAR2
)   RETURN BOOLEAN;

--  Function Val_Attribute9

FUNCTION Val_Attribute9
(   p_Attribute9                    IN  VARCHAR2
)   RETURN BOOLEAN;

--  Function Val_Attribute_Category

FUNCTION Val_Attribute_Category
(   p_Attribute_Category            IN  VARCHAR2
)   RETURN BOOLEAN;

--  Function Val_Created_By

FUNCTION Val_Created_By
(   p_Created_By                    IN  NUMBER
)   RETURN BOOLEAN;

--  Function Val_Creation_Date

FUNCTION Val_Creation_Date
(   p_Creation_Date                 IN  DATE
)   RETURN BOOLEAN;

--  Function Val_Description

FUNCTION Val_Description
(   p_Description                   IN  VARCHAR2
)   RETURN BOOLEAN;

--  Function Val_Last_Updated_By

FUNCTION Val_Last_Updated_By
(   p_Last_Updated_By               IN  NUMBER
)   RETURN BOOLEAN;

--  Function Val_Last_Update_Date

FUNCTION Val_Last_Update_Date
(   p_Last_Update_Date              IN  DATE
)   RETURN BOOLEAN;

--  Function Val_Last_Update_Login

FUNCTION Val_Last_Update_Login
(   p_Last_Update_Login             IN  NUMBER
)   RETURN BOOLEAN;

--  Function Val_Program_Application_Id

FUNCTION Val_Program_Application_Id
(   p_Program_Application_Id        IN  NUMBER
)   RETURN BOOLEAN;

--  Function Val_Program_Id

FUNCTION Val_Program_Id
(   p_Program_Id                    IN  NUMBER
)   RETURN BOOLEAN;

--  Function Val_Program_Update_Date

FUNCTION Val_Program_Update_Date
(   p_Program_Update_Date           IN  DATE
)   RETURN BOOLEAN;

--  Function Val_Request_Id

FUNCTION Val_Request_Id
(   p_Request_Id                    IN  NUMBER
)   RETURN BOOLEAN;

END MRP_Validate_Assignment_Set;

 

/
