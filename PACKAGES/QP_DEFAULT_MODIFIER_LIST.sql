--------------------------------------------------------
--  DDL for Package QP_DEFAULT_MODIFIER_LIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_DEFAULT_MODIFIER_LIST" AUTHID CURRENT_USER AS
/* $Header: QPXDMLHS.pls 120.1 2005/06/10 02:49:57 appldev  $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIER_LIST_REC
,   p_iteration                     IN  NUMBER := 1
,   x_MODIFIER_LIST_rec             OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Modifier_List_Rec_Type
);

END QP_Default_Modifier_List;

 

/
