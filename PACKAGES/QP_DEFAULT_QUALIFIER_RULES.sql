--------------------------------------------------------
--  DDL for Package QP_DEFAULT_QUALIFIER_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_DEFAULT_QUALIFIER_RULES" AUTHID CURRENT_USER AS
/* $Header: QPXDQPRS.pls 120.1 2005/06/12 23:34:17 appldev  $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIER_RULES_REC
,   p_iteration                     IN  NUMBER := 1
,   x_QUALIFIER_RULES_rec           OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
);

END QP_Default_Qualifier_Rules;

 

/
