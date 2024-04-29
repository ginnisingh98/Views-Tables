--------------------------------------------------------
--  DDL for Package MRP_ASSIGNMENT_HANDLERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_ASSIGNMENT_HANDLERS" AUTHID CURRENT_USER AS
/* $Header: MRPHASNS.pls 115.2 99/07/16 12:21:58 porting ship $ */

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_Assignment_rec                IN  MRP_Src_Assignment_PUB.Assignment_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_Assignment_rec                IN  MRP_Src_Assignment_PUB.Assignment_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_Assignment_Id                 IN  NUMBER
);

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT VARCHAR2
,   p_Assignment_rec                IN  MRP_Src_Assignment_PUB.Assignment_Rec_Type
,   x_Assignment_rec                OUT MRP_Src_Assignment_PUB.Assignment_Rec_Type
);

--  Function Query_Row

FUNCTION Query_Row
(   p_Assignment_Id                 IN  NUMBER
) RETURN MRP_Src_Assignment_PUB.Assignment_Rec_Type;

--  Procedure Query_Entity

PROCEDURE Query_Entity
(   p_Assignment_Id                 IN  NUMBER
,   x_Assignment_rec                OUT MRP_Src_Assignment_PUB.Assignment_Rec_Type
,   x_Assignment_val_rec            OUT MRP_Src_Assignment_PUB.Assignment_Val_Rec_Type
);

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_Assignment_Id                 IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_Assignment_Set_Id             IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN MRP_Src_Assignment_PUB.Assignment_Tbl_Type;

--  Procedure Query_Entities

--

PROCEDURE Query_Entities
(   p_Assignment_Id                 IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_Assignment_Set_Id             IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   x_Assignment_tbl                OUT MRP_Src_Assignment_PUB.Assignment_Tbl_Type
,   x_Assignment_val_tbl            OUT MRP_Src_Assignment_PUB.Assignment_Val_Tbl_Type
);

END MRP_Assignment_Handlers;

 

/
