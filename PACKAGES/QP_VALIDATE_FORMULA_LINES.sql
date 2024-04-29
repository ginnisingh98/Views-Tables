--------------------------------------------------------
--  DDL for Package QP_VALIDATE_FORMULA_LINES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_VALIDATE_FORMULA_LINES" AUTHID CURRENT_USER AS
/* $Header: QPXLPFLS.pls 120.1 2005/06/08 23:45:45 appldev  $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_FORMULA_LINES_rec             IN  QP_Price_Formula_PUB.Formula_Lines_Rec_Type
,   p_old_FORMULA_LINES_rec         IN  QP_Price_Formula_PUB.Formula_Lines_Rec_Type :=
                                        QP_Price_Formula_PUB.G_MISS_FORMULA_LINES_REC
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_FORMULA_LINES_rec             IN  QP_Price_Formula_PUB.Formula_Lines_Rec_Type
,   p_old_FORMULA_LINES_rec         IN  QP_Price_Formula_PUB.Formula_Lines_Rec_Type :=
                                        QP_Price_Formula_PUB.G_MISS_FORMULA_LINES_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_FORMULA_LINES_rec             IN  QP_Price_Formula_PUB.Formula_Lines_Rec_Type
);

END QP_Validate_Formula_Lines;

 

/
