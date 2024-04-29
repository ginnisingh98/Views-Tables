--------------------------------------------------------
--  DDL for Package MRP_DEFAULT_ASSIGNMENT_SET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_DEFAULT_ASSIGNMENT_SET" AUTHID CURRENT_USER AS
/* $Header: MRPDASTS.pls 115.2 99/07/16 12:18:52 porting ship $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_Assignment_Set_rec            IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type :=
                                        MRP_Src_Assignment_PUB.G_MISS_ASSIGNMENT_SET_REC
,   p_iteration                     IN  NUMBER := 1
,   x_Assignment_Set_rec            OUT MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
);

END MRP_Default_Assignment_Set;

 

/
