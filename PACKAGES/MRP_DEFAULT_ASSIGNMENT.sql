--------------------------------------------------------
--  DDL for Package MRP_DEFAULT_ASSIGNMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_DEFAULT_ASSIGNMENT" AUTHID CURRENT_USER AS
/* $Header: MRPDASNS.pls 120.1 2005/06/16 07:50:58 ichoudhu noship $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_Assignment_rec                IN  MRP_Src_Assignment_PUB.Assignment_Rec_Type :=
                                        MRP_Src_Assignment_PUB.G_MISS_ASSIGNMENT_REC
,   p_iteration                     IN  NUMBER := 1
,   x_Assignment_rec                OUT NOCOPY MRP_Src_Assignment_PUB.Assignment_Rec_Type --NOCOPY CHANGES
);

END MRP_Default_Assignment;

 

/
