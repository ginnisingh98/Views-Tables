--------------------------------------------------------
--  DDL for Package INV_DEFAULT_TROHDR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_DEFAULT_TROHDR" AUTHID CURRENT_USER AS
/* $Header: INVDTRHS.pls 120.1 2005/06/17 04:21:02 appldev  $ */

--  Cache Call

FUNCTION Load_Request_Header
(p_header_id       IN NUMBER )
RETURN INV_Move_Order_PUB.Trohdr_Rec_Type;

--  Procedure Attributes

PROCEDURE Attributes
(   p_trohdr_rec                    IN  INV_Move_Order_PUB.Trohdr_Rec_Type :=
                                        INV_Move_Order_PUB.G_MISS_TROHDR_REC
,   p_iteration                     IN  NUMBER := 1
,   x_trohdr_rec                    OUT NOCOPY /* file.sql.39 change */ INV_Move_Order_PUB.Trohdr_Rec_Type
);

END INV_Default_Trohdr;

 

/
