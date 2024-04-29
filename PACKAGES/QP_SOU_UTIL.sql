--------------------------------------------------------
--  DDL for Package QP_SOU_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_SOU_UTIL" AUTHID CURRENT_USER AS
/* $Header: QPXUSOUS.pls 120.1 2005/06/13 23:27:31 appldev  $ */

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
G_ATTRIBUTE_SOURCING          CONSTANT NUMBER := 16;
G_ATTRIBUTE_SOURCING_LEVEL    CONSTANT NUMBER := 17;
G_APPLICATION_ID              CONSTANT NUMBER := 36;
G_CONTEXT                     CONSTANT NUMBER := 18;
G_CREATED_BY                  CONSTANT NUMBER := 19;
G_CREATION_DATE               CONSTANT NUMBER := 20;
G_ENABLED                     CONSTANT NUMBER := 21;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 22;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 23;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 24;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 25;
G_PROGRAM                     CONSTANT NUMBER := 26;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 27;
G_REQUEST_TYPE                CONSTANT NUMBER := 28;
G_SEEDED                      CONSTANT NUMBER := 29;
G_SEEDED_SOURCING_TYPE        CONSTANT NUMBER := 30;
G_SEEDED_VALUE_STRING         CONSTANT NUMBER := 31;
G_SEGMENT                     CONSTANT NUMBER := 32;
G_USER_SOURCING_TYPE          CONSTANT NUMBER := 33;
G_USER_VALUE_STRING           CONSTANT NUMBER := 34;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 35;

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_SOU_rec                       IN  QP_Attr_Map_PUB.Sou_Rec_Type
,   p_old_SOU_rec                   IN  QP_Attr_Map_PUB.Sou_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SOU_REC
,   x_SOU_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Sou_Rec_Type
);

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_SOU_rec                       IN  QP_Attr_Map_PUB.Sou_Rec_Type
,   p_old_SOU_rec                   IN  QP_Attr_Map_PUB.Sou_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SOU_REC
,   x_SOU_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Sou_Rec_Type
);

--  Function Complete_Record

FUNCTION Complete_Record
(   p_SOU_rec                       IN  QP_Attr_Map_PUB.Sou_Rec_Type
,   p_old_SOU_rec                   IN  QP_Attr_Map_PUB.Sou_Rec_Type
) RETURN QP_Attr_Map_PUB.Sou_Rec_Type;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_SOU_rec                       IN  QP_Attr_Map_PUB.Sou_Rec_Type
) RETURN QP_Attr_Map_PUB.Sou_Rec_Type;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_SOU_rec                       IN  QP_Attr_Map_PUB.Sou_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_SOU_rec                       IN  QP_Attr_Map_PUB.Sou_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_attribute_sourcing_id         IN  NUMBER
);

--  Function Query_Row

FUNCTION Query_Row
(   p_attribute_sourcing_id         IN  NUMBER
) RETURN QP_Attr_Map_PUB.Sou_Rec_Type;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_attribute_sourcing_id         IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_segment_pte_id                IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN QP_Attr_Map_PUB.Sou_Tbl_Type;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_SOU_rec                       IN  QP_Attr_Map_PUB.Sou_Rec_Type
,   x_SOU_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Sou_Rec_Type
);

--  Function Get_Values

FUNCTION Get_Values
(   p_SOU_rec                       IN  QP_Attr_Map_PUB.Sou_Rec_Type
,   p_old_SOU_rec                   IN  QP_Attr_Map_PUB.Sou_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SOU_REC
) RETURN QP_Attr_Map_PUB.Sou_Val_Rec_Type;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_SOU_rec                       IN  QP_Attr_Map_PUB.Sou_Rec_Type
,   p_SOU_val_rec                   IN  QP_Attr_Map_PUB.Sou_Val_Rec_Type
) RETURN QP_Attr_Map_PUB.Sou_Rec_Type;

END QP_Sou_Util;

 

/
