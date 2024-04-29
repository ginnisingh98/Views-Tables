--------------------------------------------------------
--  DDL for Package QP_VALIDATE_MODIFIER_LIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_VALIDATE_MODIFIER_LIST" AUTHID CURRENT_USER AS
/* $Header: QPXLMLHS.pls 120.1 2005/06/15 03:23:22 appldev  $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
,   p_old_MODIFIER_LIST_rec         IN  QP_Modifiers_PUB.Modifier_List_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIER_LIST_REC
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
,   p_old_MODIFIER_LIST_rec         IN  QP_Modifiers_PUB.Modifier_List_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIER_LIST_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
);

END QP_Validate_Modifier_List;

 

/
