--------------------------------------------------------
--  DDL for Package MRP_ASSIGNMENT_SET_HANDLERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_ASSIGNMENT_SET_HANDLERS" AUTHID CURRENT_USER AS
/* $Header: MRPHASTS.pls 115.2 99/07/16 12:22:21 porting ship $ */

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_Assignment_Set_rec            IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_Assignment_Set_rec            IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_Assignment_Set_Id             IN  NUMBER
);

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT VARCHAR2
,   p_Assignment_Set_rec            IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
,   x_Assignment_Set_rec            OUT MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
);

--  Function Query_Row

FUNCTION Query_Row
(   p_Assignment_Set_Id             IN  NUMBER
) RETURN MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type;

--  Procedure Query_Entity

PROCEDURE Query_Entity
(   p_Assignment_Set_Id             IN  NUMBER
,   x_Assignment_Set_rec            OUT MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
,   x_Assignment_Set_val_rec        OUT MRP_Src_Assignment_PUB.Assignment_Set_Val_Rec_Type
);

END MRP_Assignment_Set_Handlers;

 

/
