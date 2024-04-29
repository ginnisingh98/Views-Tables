--------------------------------------------------------
--  DDL for Package QP_DEFAULT_SSC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_DEFAULT_SSC" AUTHID CURRENT_USER AS
/* $Header: QPXDSSCS.pls 120.1 2005/06/12 23:45:49 appldev  $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_SSC_rec                       IN  QP_Attr_Map_PUB.Ssc_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SSC_REC
,   p_iteration                     IN  NUMBER := 1
,   x_SSC_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Ssc_Rec_Type
);

END QP_Default_Ssc;

 

/
