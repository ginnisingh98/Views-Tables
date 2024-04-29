--------------------------------------------------------
--  DDL for Package QP_DEFAULT_SOU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_DEFAULT_SOU" AUTHID CURRENT_USER AS
/* $Header: QPXDSOUS.pls 120.1 2005/06/12 23:42:34 appldev  $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_SOU_rec                       IN  QP_Attr_Map_PUB.Sou_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SOU_REC
,   p_iteration                     IN  NUMBER := 1
,   x_SOU_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Sou_Rec_Type
);

END QP_Default_Sou;

 

/
