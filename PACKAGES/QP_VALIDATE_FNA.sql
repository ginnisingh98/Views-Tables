--------------------------------------------------------
--  DDL for Package QP_VALIDATE_FNA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_VALIDATE_FNA" AUTHID CURRENT_USER AS
/* $Header: QPXLFNAS.pls 120.1 2005/07/20 11:41:55 sfiresto noship $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_FNA_rec                       IN  QP_Attr_Map_PUB.Fna_Rec_Type
,   p_old_FNA_rec                   IN  QP_Attr_Map_PUB.Fna_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_FNA_REC
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_FNA_rec                       IN  QP_Attr_Map_PUB.Fna_Rec_Type
,   p_old_FNA_rec                   IN  QP_Attr_Map_PUB.Fna_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_FNA_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_FNA_rec                       IN  QP_Attr_Map_PUB.Fna_Rec_Type
);

END QP_Validate_Fna;

 

/
