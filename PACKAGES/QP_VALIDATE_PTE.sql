--------------------------------------------------------
--  DDL for Package QP_VALIDATE_PTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_VALIDATE_PTE" AUTHID CURRENT_USER AS
/* $Header: QPXLPTES.pls 120.1 2005/06/09 00:02:02 appldev  $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type
,   p_old_PTE_rec                   IN  QP_Attr_Map_PUB.Pte_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PTE_REC
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type
,   p_old_PTE_rec                   IN  QP_Attr_Map_PUB.Pte_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PTE_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type
);

END QP_Validate_Pte;

 

/
