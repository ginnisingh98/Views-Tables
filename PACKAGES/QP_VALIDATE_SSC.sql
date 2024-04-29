--------------------------------------------------------
--  DDL for Package QP_VALIDATE_SSC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_VALIDATE_SSC" AUTHID CURRENT_USER AS
/* $Header: QPXLSSCS.pls 120.1 2005/06/08 21:44:19 appldev  $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_SSC_rec                       IN  QP_Attr_Map_PUB.Ssc_Rec_Type
,   p_old_SSC_rec                   IN  QP_Attr_Map_PUB.Ssc_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SSC_REC
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_SSC_rec                       IN  QP_Attr_Map_PUB.Ssc_Rec_Type
,   p_old_SSC_rec                   IN  QP_Attr_Map_PUB.Ssc_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SSC_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_SSC_rec                       IN  QP_Attr_Map_PUB.Ssc_Rec_Type
);

END QP_Validate_Ssc;

 

/
