--------------------------------------------------------
--  DDL for Package QP_DEFAULT_LIMITS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_DEFAULT_LIMITS" AUTHID CURRENT_USER AS
/* $Header: QPXDLMTS.pls 120.1 2005/06/10 02:46:55 appldev  $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMITS_REC
,   p_iteration                     IN  NUMBER := 1
,   x_LIMITS_rec                    OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limits_Rec_Type
);

END QP_Default_Limits;

 

/
