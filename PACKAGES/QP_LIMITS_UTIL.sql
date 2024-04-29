--------------------------------------------------------
--  DDL for Package QP_LIMITS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_LIMITS_UTIL" AUTHID CURRENT_USER AS
/* $Header: QPXULMTS.pls 120.1.12000000.1 2007/01/17 22:31:17 appldev ship $ */

--  Attributes global constants

G_AMOUNT                      CONSTANT NUMBER := 1;
G_ATTRIBUTE1                  CONSTANT NUMBER := 2;
G_ATTRIBUTE10                 CONSTANT NUMBER := 3;
G_ATTRIBUTE11                 CONSTANT NUMBER := 4;
G_ATTRIBUTE12                 CONSTANT NUMBER := 5;
G_ATTRIBUTE13                 CONSTANT NUMBER := 6;
G_ATTRIBUTE14                 CONSTANT NUMBER := 7;
G_ATTRIBUTE15                 CONSTANT NUMBER := 8;
G_ATTRIBUTE2                  CONSTANT NUMBER := 9;
G_ATTRIBUTE3                  CONSTANT NUMBER := 10;
G_ATTRIBUTE4                  CONSTANT NUMBER := 11;
G_ATTRIBUTE5                  CONSTANT NUMBER := 12;
G_ATTRIBUTE6                  CONSTANT NUMBER := 13;
G_ATTRIBUTE7                  CONSTANT NUMBER := 14;
G_ATTRIBUTE8                  CONSTANT NUMBER := 15;
G_ATTRIBUTE9                  CONSTANT NUMBER := 16;
G_BASIS                       CONSTANT NUMBER := 17;
G_CONTEXT                     CONSTANT NUMBER := 18;
G_CREATED_BY                  CONSTANT NUMBER := 19;
G_CREATION_DATE               CONSTANT NUMBER := 20;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 21;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 22;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 23;
G_LIMIT_EXCEED_ACTION         CONSTANT NUMBER := 24;
G_LIMIT                       CONSTANT NUMBER := 25;
G_LIMIT_LEVEL                 CONSTANT NUMBER := 26;
G_LIMIT_NUMBER                CONSTANT NUMBER := 27;
G_LIST_HEADER                 CONSTANT NUMBER := 28;
G_LIST_LINE                   CONSTANT NUMBER := 29;
G_ORGANIZATION                CONSTANT NUMBER := 30;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 31;
G_PROGRAM                     CONSTANT NUMBER := 32;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 33;
G_REQUEST                     CONSTANT NUMBER := 34;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 35;
G_LIMIT_HOLD                  CONSTANT NUMBER := 36;
G_MULTIVAL_ATTR1_TYPE         CONSTANT NUMBER := 37;
G_MULTIVAL_ATTR1_CONTEXT      CONSTANT NUMBER := 38;
G_MULTIVAL_ATTRIBUTE1         CONSTANT NUMBER := 39;
G_MULTIVAL_ATTR1_DATATYPE     CONSTANT NUMBER := 40;
G_MULTIVAL_ATTR2_TYPE         CONSTANT NUMBER := 41;
G_MULTIVAL_ATTR2_CONTEXT      CONSTANT NUMBER := 42;
G_MULTIVAL_ATTRIBUTE2         CONSTANT NUMBER := 43;
G_MULTIVAL_ATTR2_DATATYPE     CONSTANT NUMBER := 44;

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
,   p_old_LIMITS_rec                IN  QP_Limits_PUB.Limits_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMITS_REC
,   x_LIMITS_rec                    OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limits_Rec_Type
);

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
,   p_old_LIMITS_rec                IN  QP_Limits_PUB.Limits_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMITS_REC
,   x_LIMITS_rec                    OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limits_Rec_Type
);

--  Function Complete_Record

FUNCTION Complete_Record
(   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
,   p_old_LIMITS_rec                IN  QP_Limits_PUB.Limits_Rec_Type
) RETURN QP_Limits_PUB.Limits_Rec_Type;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
) RETURN QP_Limits_PUB.Limits_Rec_Type;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_limit_id                      IN  NUMBER
);

--  Function Query_Row

FUNCTION Query_Row
(   p_limit_id                      IN  NUMBER
) RETURN QP_Limits_PUB.Limits_Rec_Type;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
,   x_LIMITS_rec                    OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limits_Rec_Type
);

--  Function Get_Values

FUNCTION Get_Values
(   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
,   p_old_LIMITS_rec                IN  QP_Limits_PUB.Limits_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMITS_REC
) RETURN QP_Limits_PUB.Limits_Val_Rec_Type;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
,   p_LIMITS_val_rec                IN  QP_Limits_PUB.Limits_Val_Rec_Type
) RETURN QP_Limits_PUB.Limits_Rec_Type;

Procedure Pre_Write_Process
(   p_LIMITS_rec                      IN  QP_Limits_PUB.Limits_Rec_Type
,   p_old_LIMITS_rec                  IN  QP_Limits_PUB.Limits_Rec_Type :=
                                                QP_Limits_PUB.G_MISS_LIMITS_REC
,   x_LIMITS_rec                      OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limits_Rec_Type
);


END QP_Limits_Util;

 

/
