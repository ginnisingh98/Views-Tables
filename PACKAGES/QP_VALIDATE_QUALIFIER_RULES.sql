--------------------------------------------------------
--  DDL for Package QP_VALIDATE_QUALIFIER_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_VALIDATE_QUALIFIER_RULES" AUTHID CURRENT_USER AS
/* $Header: QPXLQPRS.pls 120.1 2005/06/09 00:21:03 appldev  $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
,   p_old_QUALIFIER_RULES_rec       IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIER_RULES_REC
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
,   p_old_QUALIFIER_RULES_rec       IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIER_RULES_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
);

END QP_Validate_Qualifier_Rules;

 

/
