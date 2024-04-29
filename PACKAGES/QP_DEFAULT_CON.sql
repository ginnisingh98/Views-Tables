--------------------------------------------------------
--  DDL for Package QP_DEFAULT_CON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_DEFAULT_CON" AUTHID CURRENT_USER AS
/* $Header: QPXDCONS.pls 120.1 2005/06/09 23:42:34 appldev  $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_CON_rec                       IN  QP_Attributes_PUB.Con_Rec_Type :=
                                        QP_Attributes_PUB.G_MISS_CON_REC
,   p_iteration                     IN  NUMBER := 1
,   x_CON_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Con_Rec_Type
);

END QP_Default_Con;

 

/
