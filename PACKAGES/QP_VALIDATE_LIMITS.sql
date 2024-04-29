--------------------------------------------------------
--  DDL for Package QP_VALIDATE_LIMITS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_VALIDATE_LIMITS" AUTHID CURRENT_USER AS
/* $Header: QPXLLMTS.pls 120.1 2005/06/08 04:27:30 appldev  $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
,   p_old_LIMITS_rec                IN  QP_Limits_PUB.Limits_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMITS_REC
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
,   p_old_LIMITS_rec                IN  QP_Limits_PUB.Limits_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMITS_REC
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
);

PROCEDURE Entity_Update
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
);

END QP_Validate_Limits;

 

/
