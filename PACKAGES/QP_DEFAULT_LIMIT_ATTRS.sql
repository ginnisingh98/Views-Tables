--------------------------------------------------------
--  DDL for Package QP_DEFAULT_LIMIT_ATTRS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_DEFAULT_LIMIT_ATTRS" AUTHID CURRENT_USER AS
/* $Header: QPXDLATS.pls 120.1 2005/06/09 23:50:58 appldev  $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_LIMIT_ATTRS_rec               IN  QP_Limits_PUB.Limit_Attrs_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_ATTRS_REC
,   p_iteration                     IN  NUMBER := 1
,   x_LIMIT_ATTRS_rec               OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Attrs_Rec_Type
);

END QP_Default_Limit_Attrs;

 

/
