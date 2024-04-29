--------------------------------------------------------
--  DDL for Package QP_DEFAULT_PRICE_LIST_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_DEFAULT_PRICE_LIST_LINE" AUTHID CURRENT_USER AS
/* $Header: QPXDPLLS.pls 120.1 2005/06/10 03:29:21 appldev  $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_PRICE_LIST_LINE_rec           IN  QP_Price_List_PUB.Price_List_Line_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_REC
,   p_iteration                     IN  NUMBER := 1
,   x_PRICE_LIST_LINE_rec           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Rec_Type
);

END QP_Default_Price_List_Line;

 

/
