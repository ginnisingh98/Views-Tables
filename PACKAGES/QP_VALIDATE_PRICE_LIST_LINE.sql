--------------------------------------------------------
--  DDL for Package QP_VALIDATE_PRICE_LIST_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_VALIDATE_PRICE_LIST_LINE" AUTHID CURRENT_USER AS
/* $Header: QPXLPLLS.pls 120.1.12010000.1 2008/07/28 11:54:15 appldev ship $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_LINE_rec           IN  QP_Price_List_PUB.Price_List_Line_Rec_Type
,   p_old_PRICE_LIST_LINE_rec       IN  QP_Price_List_PUB.Price_List_Line_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_REC
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_LINE_rec           IN  QP_Price_List_PUB.Price_List_Line_Rec_Type
,   p_old_PRICE_LIST_LINE_rec       IN  QP_Price_List_PUB.Price_List_Line_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_LINE_rec           IN  QP_Price_List_PUB.Price_List_Line_Rec_Type
);

END QP_Validate_Price_List_Line;

/
