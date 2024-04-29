--------------------------------------------------------
--  DDL for Package QP_DEFAULT_SEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_DEFAULT_SEG" AUTHID CURRENT_USER AS
/* $Header: QPXDSEGS.pls 120.1 2005/06/12 23:40:14 appldev  $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_SEG_rec                       IN  QP_Attributes_PUB.Seg_Rec_Type :=
                                        QP_Attributes_PUB.G_MISS_SEG_REC
,   p_iteration                     IN  NUMBER := 1
,   x_SEG_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Seg_Rec_Type
);

END QP_Default_Seg;

 

/
