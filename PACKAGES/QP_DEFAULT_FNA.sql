--------------------------------------------------------
--  DDL for Package QP_DEFAULT_FNA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_DEFAULT_FNA" AUTHID CURRENT_USER AS
/* $Header: QPXDFNAS.pls 120.2 2005/07/20 11:37 sfiresto noship $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_FNA_rec                       IN  QP_Attr_Map_PUB.Fna_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_FNA_REC
,   p_iteration                     IN  NUMBER := 1
,   x_FNA_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Fna_Rec_Type
);

END QP_Default_Fna;

 

/
