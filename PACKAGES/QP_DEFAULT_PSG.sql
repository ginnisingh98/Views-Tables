--------------------------------------------------------
--  DDL for Package QP_DEFAULT_PSG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_DEFAULT_PSG" AUTHID CURRENT_USER AS
/* $Header: QPXDPSGS.pls 120.1 2005/06/10 06:05:39 appldev  $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_PSG_rec                       IN  QP_Attr_Map_PUB.Psg_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PSG_REC
,   p_iteration                     IN  NUMBER := 1
,   x_PSG_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Psg_Rec_Type
);

END QP_Default_Psg;

 

/
