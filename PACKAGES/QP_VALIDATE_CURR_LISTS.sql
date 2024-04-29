--------------------------------------------------------
--  DDL for Package QP_VALIDATE_CURR_LISTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_VALIDATE_CURR_LISTS" AUTHID CURRENT_USER AS
/* $Header: QPXLCURS.pls 120.1 2005/06/08 22:08:33 appldev  $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CURR_LISTS_rec                IN  QP_Currency_PUB.Curr_Lists_Rec_Type
,   p_old_CURR_LISTS_rec            IN  QP_Currency_PUB.Curr_Lists_Rec_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_LISTS_REC
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CURR_LISTS_rec                IN  QP_Currency_PUB.Curr_Lists_Rec_Type
,   p_old_CURR_LISTS_rec            IN  QP_Currency_PUB.Curr_Lists_Rec_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_LISTS_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CURR_LISTS_rec                IN  QP_Currency_PUB.Curr_Lists_Rec_Type
);

END QP_Validate_Curr_Lists;

 

/
