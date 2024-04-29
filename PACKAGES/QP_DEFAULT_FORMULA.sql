--------------------------------------------------------
--  DDL for Package QP_DEFAULT_FORMULA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_DEFAULT_FORMULA" AUTHID CURRENT_USER AS
/* $Header: QPXDPRFS.pls 120.1 2005/06/10 06:03:01 appldev  $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_FORMULA_rec                   IN  QP_Price_Formula_PUB.Formula_Rec_Type :=
                                        QP_Price_Formula_PUB.G_MISS_FORMULA_REC
,   p_iteration                     IN  NUMBER := 1
,   x_FORMULA_rec                   OUT NOCOPY /* file.sql.39 change */ QP_Price_Formula_PUB.Formula_Rec_Type
);

END QP_Default_Formula;

 

/
