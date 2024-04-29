--------------------------------------------------------
--  DDL for Package QP_VALIDATE_PSG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_VALIDATE_PSG" AUTHID CURRENT_USER AS
/* $Header: QPXLPSGS.pls 120.1 2005/06/08 23:58:44 appldev  $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PSG_rec                       IN  QP_Attr_Map_PUB.Psg_Rec_Type
,   p_old_PSG_rec                   IN  QP_Attr_Map_PUB.Psg_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PSG_REC
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PSG_rec                       IN  QP_Attr_Map_PUB.Psg_Rec_Type
,   p_old_PSG_rec                   IN  QP_Attr_Map_PUB.Psg_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PSG_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PSG_rec                       IN  QP_Attr_Map_PUB.Psg_Rec_Type
);

END QP_Validate_Psg;

 

/
