--------------------------------------------------------
--  DDL for Package QP_VALIDATE_LIMIT_ATTRS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_VALIDATE_LIMIT_ATTRS" AUTHID CURRENT_USER AS
/* $Header: QPXLLATS.pls 120.1 2005/06/08 04:35:29 appldev  $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMIT_ATTRS_rec               IN  QP_Limits_PUB.Limit_Attrs_Rec_Type
,   p_old_LIMIT_ATTRS_rec           IN  QP_Limits_PUB.Limit_Attrs_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_ATTRS_REC
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMIT_ATTRS_rec               IN  QP_Limits_PUB.Limit_Attrs_Rec_Type
,   p_old_LIMIT_ATTRS_rec           IN  QP_Limits_PUB.Limit_Attrs_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_ATTRS_REC
);

--  Procedure Entity_Insert

PROCEDURE Entity_Insert
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMIT_ATTRS_rec               IN  QP_Limits_PUB.Limit_Attrs_Rec_Type
);

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMIT_ATTRS_rec               IN  QP_Limits_PUB.Limit_Attrs_Rec_Type
);

--  Procedure Entity_Update

PROCEDURE Entity_Update
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMIT_ATTRS_rec               IN  QP_Limits_PUB.Limit_Attrs_Rec_Type
);


END QP_Validate_Limit_Attrs;

 

/
