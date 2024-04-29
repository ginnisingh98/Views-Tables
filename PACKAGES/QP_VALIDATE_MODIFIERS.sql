--------------------------------------------------------
--  DDL for Package QP_VALIDATE_MODIFIERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_VALIDATE_MODIFIERS" AUTHID CURRENT_USER AS
/* $Header: QPXLMLLS.pls 120.1.12000000.1 2007/01/17 22:26:43 appldev ship $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_MODIFIERS_rec                 IN  QP_Modifiers_PUB.Modifiers_Rec_Type
,   p_old_MODIFIERS_rec             IN  QP_Modifiers_PUB.Modifiers_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIERS_REC
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_MODIFIERS_rec                 IN  QP_Modifiers_PUB.Modifiers_Rec_Type
,   p_old_MODIFIERS_rec             IN  QP_Modifiers_PUB.Modifiers_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIERS_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_MODIFIERS_rec                 IN  QP_Modifiers_PUB.Modifiers_Rec_Type
);

END QP_Validate_Modifiers;

 

/
