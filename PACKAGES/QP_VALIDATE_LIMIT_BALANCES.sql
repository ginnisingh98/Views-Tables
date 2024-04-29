--------------------------------------------------------
--  DDL for Package QP_VALIDATE_LIMIT_BALANCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_VALIDATE_LIMIT_BALANCES" AUTHID CURRENT_USER AS
/* $Header: QPXLLMBS.pls 120.1 2005/06/08 04:11:54 appldev  $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMIT_BALANCES_rec            IN  QP_Limits_PUB.Limit_Balances_Rec_Type
,   p_old_LIMIT_BALANCES_rec        IN  QP_Limits_PUB.Limit_Balances_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_BALANCES_REC
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMIT_BALANCES_rec            IN  QP_Limits_PUB.Limit_Balances_Rec_Type
,   p_old_LIMIT_BALANCES_rec        IN  QP_Limits_PUB.Limit_Balances_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_BALANCES_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMIT_BALANCES_rec            IN  QP_Limits_PUB.Limit_Balances_Rec_Type
);

END QP_Validate_Limit_Balances;

 

/
