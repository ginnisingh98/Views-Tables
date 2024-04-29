--------------------------------------------------------
--  DDL for Package QP_DEFAULT_FORMULA_LINES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_DEFAULT_FORMULA_LINES" AUTHID CURRENT_USER AS
/* $Header: QPXDPFLS.pls 120.1 2005/06/10 03:21:58 appldev  $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_FORMULA_LINES_rec             IN  QP_Price_Formula_PUB.Formula_Lines_Rec_Type :=
                                        QP_Price_Formula_PUB.G_MISS_FORMULA_LINES_REC
,   p_iteration                     IN  NUMBER := 1
,   x_FORMULA_LINES_rec             OUT NOCOPY /* file.sql.39 change */ QP_Price_Formula_PUB.Formula_Lines_Rec_Type
);

END QP_Default_Formula_Lines;

 

/
