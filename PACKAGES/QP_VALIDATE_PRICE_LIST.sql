--------------------------------------------------------
--  DDL for Package QP_VALIDATE_PRICE_LIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_VALIDATE_PRICE_LIST" AUTHID CURRENT_USER AS
/* $Header: QPXLPLHS.pls 120.1 2005/06/15 03:21:47 appldev  $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_rec                IN  QP_Price_List_PUB.Price_List_Rec_Type
,   p_old_PRICE_LIST_rec            IN  QP_Price_List_PUB.Price_List_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_REC
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_rec                IN  QP_Price_List_PUB.Price_List_Rec_Type
,   p_old_PRICE_LIST_rec            IN  QP_Price_List_PUB.Price_List_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_rec                IN  QP_Price_List_PUB.Price_List_Rec_Type
);

END QP_Validate_Price_List;

 

/
