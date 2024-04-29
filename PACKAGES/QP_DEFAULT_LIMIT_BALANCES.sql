--------------------------------------------------------
--  DDL for Package QP_DEFAULT_LIMIT_BALANCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_DEFAULT_LIMIT_BALANCES" AUTHID CURRENT_USER AS
/* $Header: QPXDLMBS.pls 120.1 2005/06/09 23:57:45 appldev  $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_LIMIT_BALANCES_rec            IN  QP_Limits_PUB.Limit_Balances_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_BALANCES_REC
,   p_iteration                     IN  NUMBER := 1
,   x_LIMIT_BALANCES_rec            OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Balances_Rec_Type
);

END QP_Default_Limit_Balances;

 

/
