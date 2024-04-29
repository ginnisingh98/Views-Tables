--------------------------------------------------------
--  DDL for Package QP_VALIDATE_SOU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_VALIDATE_SOU" AUTHID CURRENT_USER AS
/* $Header: QPXLSOUS.pls 120.1 2005/06/08 21:26:09 appldev  $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_SOU_rec                       IN  QP_Attr_Map_PUB.Sou_Rec_Type
,   p_old_SOU_rec                   IN  QP_Attr_Map_PUB.Sou_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SOU_REC
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_SOU_rec                       IN  QP_Attr_Map_PUB.Sou_Rec_Type
,   p_old_SOU_rec                   IN  QP_Attr_Map_PUB.Sou_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SOU_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_SOU_rec                       IN  QP_Attr_Map_PUB.Sou_Rec_Type
);

END QP_Validate_Sou;

 

/
