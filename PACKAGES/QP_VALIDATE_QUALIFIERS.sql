--------------------------------------------------------
--  DDL for Package QP_VALIDATE_QUALIFIERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_VALIDATE_QUALIFIERS" AUTHID CURRENT_USER AS
/* $Header: QPXLQPQS.pls 120.1 2005/06/27 04:45:45 appldev ship $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
,   p_old_QUALIFIERS_rec            IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_REC
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
,   p_old_QUALIFIERS_rec            IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
);

END QP_Validate_Qualifiers;

 

/
