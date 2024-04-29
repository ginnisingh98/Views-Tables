--------------------------------------------------------
--  DDL for Package QP_DEFAULT_PTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_DEFAULT_PTE" AUTHID CURRENT_USER AS
/* $Header: QPXDPTES.pls 120.1 2005/06/10 06:08:48 appldev  $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PTE_REC
,   p_iteration                     IN  NUMBER := 1
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Pte_Rec_Type
);

END QP_Default_Pte;

 

/
