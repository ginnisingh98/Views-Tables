--------------------------------------------------------
--  DDL for Package QP_DEFAULT_MODIFIERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_DEFAULT_MODIFIERS" AUTHID CURRENT_USER AS
/* $Header: QPXDMLLS.pls 120.1 2005/06/10 02:51:26 appldev  $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_MODIFIERS_rec                 IN  QP_Modifiers_PUB.Modifiers_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIERS_REC
,   p_iteration                     IN  NUMBER := 1
,   x_MODIFIERS_rec                 OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Modifiers_Rec_Type
);

END QP_Default_Modifiers;

 

/
