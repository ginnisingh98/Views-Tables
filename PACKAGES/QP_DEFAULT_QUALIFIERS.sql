--------------------------------------------------------
--  DDL for Package QP_DEFAULT_QUALIFIERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_DEFAULT_QUALIFIERS" AUTHID CURRENT_USER AS
/* $Header: QPXDQPQS.pls 120.1 2005/06/27 05:13:43 appldev ship $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_REC
,   p_iteration                     IN  NUMBER := 1
,   x_QUALIFIERS_rec                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
);

END QP_Default_Qualifiers;

 

/
