--------------------------------------------------------
--  DDL for Package QP_LIMIT_ATTRS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_LIMIT_ATTRS_UTIL" AUTHID CURRENT_USER AS
/* $Header: QPXULATS.pls 120.1 2005/06/10 00:12:21 appldev  $ */

--  Attributes global constants

G_ATTRIBUTE1                  CONSTANT NUMBER := 1;
G_ATTRIBUTE10                 CONSTANT NUMBER := 2;
G_ATTRIBUTE11                 CONSTANT NUMBER := 3;
G_ATTRIBUTE12                 CONSTANT NUMBER := 4;
G_ATTRIBUTE13                 CONSTANT NUMBER := 5;
G_ATTRIBUTE14                 CONSTANT NUMBER := 6;
G_ATTRIBUTE15                 CONSTANT NUMBER := 7;
G_ATTRIBUTE2                  CONSTANT NUMBER := 8;
G_ATTRIBUTE3                  CONSTANT NUMBER := 9;
G_ATTRIBUTE4                  CONSTANT NUMBER := 10;
G_ATTRIBUTE5                  CONSTANT NUMBER := 11;
G_ATTRIBUTE6                  CONSTANT NUMBER := 12;
G_ATTRIBUTE7                  CONSTANT NUMBER := 13;
G_ATTRIBUTE8                  CONSTANT NUMBER := 14;
G_ATTRIBUTE9                  CONSTANT NUMBER := 15;
G_COMPARISON_OPERATOR         CONSTANT NUMBER := 16;
G_CONTEXT                     CONSTANT NUMBER := 17;
G_CREATED_BY                  CONSTANT NUMBER := 18;
G_CREATION_DATE               CONSTANT NUMBER := 19;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 20;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 21;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 22;
--G_LIMIT_ATTRIBUTE             CONSTANT NUMBER := 23;
G_LIMIT_ATTRIBUTE_CONTEXT     CONSTANT NUMBER := 24;
G_LIMIT_ATTRIBUTE             CONSTANT NUMBER := 25;
G_LIMIT_ATTRIBUTE_TYPE        CONSTANT NUMBER := 26;
G_LIMIT_ATTR_DATATYPE         CONSTANT NUMBER := 27;
G_LIMIT_ATTR_VALUE            CONSTANT NUMBER := 28;
G_LIMIT                       CONSTANT NUMBER := 29;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 30;
G_PROGRAM                     CONSTANT NUMBER := 31;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 32;
G_REQUEST                     CONSTANT NUMBER := 33;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 34;

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_LIMIT_ATTRS_rec               IN  QP_Limits_PUB.Limit_Attrs_Rec_Type
,   p_old_LIMIT_ATTRS_rec           IN  QP_Limits_PUB.Limit_Attrs_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_ATTRS_REC
,   x_LIMIT_ATTRS_rec               OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Attrs_Rec_Type
);

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_LIMIT_ATTRS_rec               IN  QP_Limits_PUB.Limit_Attrs_Rec_Type
,   p_old_LIMIT_ATTRS_rec           IN  QP_Limits_PUB.Limit_Attrs_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_ATTRS_REC
,   x_LIMIT_ATTRS_rec               OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Attrs_Rec_Type
);

--  Function Complete_Record

FUNCTION Complete_Record
(   p_LIMIT_ATTRS_rec               IN  QP_Limits_PUB.Limit_Attrs_Rec_Type
,   p_old_LIMIT_ATTRS_rec           IN  QP_Limits_PUB.Limit_Attrs_Rec_Type
) RETURN QP_Limits_PUB.Limit_Attrs_Rec_Type;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_LIMIT_ATTRS_rec               IN  QP_Limits_PUB.Limit_Attrs_Rec_Type
) RETURN QP_Limits_PUB.Limit_Attrs_Rec_Type;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_LIMIT_ATTRS_rec               IN  QP_Limits_PUB.Limit_Attrs_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_LIMIT_ATTRS_rec               IN  QP_Limits_PUB.Limit_Attrs_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_limit_attribute_id            IN  NUMBER
);

--  Function Query_Row

FUNCTION Query_Row
(   p_limit_attribute_id            IN  NUMBER
) RETURN QP_Limits_PUB.Limit_Attrs_Rec_Type;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_limit_attribute_id            IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_limit_id                      IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN QP_Limits_PUB.Limit_Attrs_Tbl_Type;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMIT_ATTRS_rec               IN  QP_Limits_PUB.Limit_Attrs_Rec_Type
,   x_LIMIT_ATTRS_rec               OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Attrs_Rec_Type
);

--  Function Get_Values

FUNCTION Get_Values
(   p_LIMIT_ATTRS_rec               IN  QP_Limits_PUB.Limit_Attrs_Rec_Type
,   p_old_LIMIT_ATTRS_rec           IN  QP_Limits_PUB.Limit_Attrs_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_ATTRS_REC
) RETURN QP_Limits_PUB.Limit_Attrs_Val_Rec_Type;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_LIMIT_ATTRS_rec               IN  QP_Limits_PUB.Limit_Attrs_Rec_Type
,   p_LIMIT_ATTRS_val_rec           IN  QP_Limits_PUB.Limit_Attrs_Val_Rec_Type
) RETURN QP_Limits_PUB.Limit_Attrs_Rec_Type;

Procedure Pre_Write_Process
(   p_LIMIT_ATTRS_rec                      IN  QP_Limits_PUB.Limit_Attrs_Rec_Type
,   p_old_LIMIT_ATTRS_rec                  IN  QP_Limits_PUB.Limit_Attrs_Rec_Type :=
                                                QP_Limits_PUB.G_MISS_LIMIT_ATTRS_REC
,   x_LIMIT_ATTRS_rec                      OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Attrs_Rec_Type
);

END QP_Limit_Attrs_Util;

 

/
