--------------------------------------------------------
--  DDL for Package QP_VALIDATE_SEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_VALIDATE_SEG" AUTHID CURRENT_USER AS
/* $Header: QPXLSEGS.pls 120.1 2005/06/09 00:28:05 appldev  $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_SEG_rec                       IN  QP_Attributes_PUB.Seg_Rec_Type
,   p_old_SEG_rec                   IN  QP_Attributes_PUB.Seg_Rec_Type :=
                                        QP_Attributes_PUB.G_MISS_SEG_REC
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_SEG_rec                       IN  QP_Attributes_PUB.Seg_Rec_Type
,   p_old_SEG_rec                   IN  QP_Attributes_PUB.Seg_Rec_Type :=
                                        QP_Attributes_PUB.G_MISS_SEG_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_SEG_rec                       IN  QP_Attributes_PUB.Seg_Rec_Type
);

END QP_Validate_Seg;

 

/
