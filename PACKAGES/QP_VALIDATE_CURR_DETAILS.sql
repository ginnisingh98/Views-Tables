--------------------------------------------------------
--  DDL for Package QP_VALIDATE_CURR_DETAILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_VALIDATE_CURR_DETAILS" AUTHID CURRENT_USER AS
/* $Header: QPXLCDTS.pls 120.1 2005/06/08 21:56:20 appldev  $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CURR_DETAILS_rec              IN  QP_Currency_PUB.Curr_Details_Rec_Type
,   p_old_CURR_DETAILS_rec          IN  QP_Currency_PUB.Curr_Details_Rec_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_DETAILS_REC
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CURR_DETAILS_rec              IN  QP_Currency_PUB.Curr_Details_Rec_Type
,   p_old_CURR_DETAILS_rec          IN  QP_Currency_PUB.Curr_Details_Rec_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_DETAILS_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CURR_DETAILS_rec              IN  QP_Currency_PUB.Curr_Details_Rec_Type
);

END QP_Validate_Curr_Details;

 

/
