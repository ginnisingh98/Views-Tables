--------------------------------------------------------
--  DDL for Package QP_DEFAULT_RQT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_DEFAULT_RQT" AUTHID CURRENT_USER AS
/* $Header: QPXDRQTS.pls 120.1 2005/06/12 23:37:18 appldev  $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_RQT_rec                       IN  QP_Attr_Map_PUB.Rqt_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_RQT_REC
,   p_iteration                     IN  NUMBER := 1
,   x_RQT_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Rqt_Rec_Type
);

END QP_Default_Rqt;

 

/
