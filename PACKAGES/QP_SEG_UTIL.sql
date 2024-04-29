--------------------------------------------------------
--  DDL for Package QP_SEG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_SEG_UTIL" AUTHID CURRENT_USER AS
/* $Header: QPXUSEGS.pls 120.2 2005/08/03 07:37:27 srashmi noship $ */

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
G_AVAILABILITY_IN_BASIC       CONSTANT NUMBER := 16;
G_CONTEXT                     CONSTANT NUMBER := 17;
G_CREATED_BY                  CONSTANT NUMBER := 18;
G_CREATION_DATE               CONSTANT NUMBER := 19;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 20;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 21;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 22;
G_PRC_CONTEXT                 CONSTANT NUMBER := 23;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 24;
G_PROGRAM                     CONSTANT NUMBER := 25;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 26;
G_SEEDED                      CONSTANT NUMBER := 27;
G_SEEDED_FORMAT_TYPE          CONSTANT NUMBER := 28;
G_SEEDED_PRECEDENCE           CONSTANT NUMBER := 29;
G_SEEDED_SEGMENT_NAME         CONSTANT NUMBER := 30;
G_SEEDED_VALUESET             CONSTANT NUMBER := 31;
G_SEGMENT_code             CONSTANT NUMBER := 32;
G_SEGMENT                     CONSTANT NUMBER := 33;
G_SEGMENT_MAPPING_COLUMN      CONSTANT NUMBER := 34;
G_USER_FORMAT_TYPE            CONSTANT NUMBER := 35;
G_USER_PRECEDENCE             CONSTANT NUMBER := 36;
G_USER_SEGMENT_NAME           CONSTANT NUMBER := 37;
G_USER_VALUESET               CONSTANT NUMBER := 38;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 39;
G_APPLICATION_ID              CONSTANT NUMBER := 40;
G_USER_DESCRIPTION            CONSTANT NUMBER := 41;
G_REQUIRED_FLAG	 	      CONSTANT NUMBER := 42;
G_SEEDED_DESCRIPTION 	      CONSTANT NUMBER := 43;
-- Added for TCA
G_PARTY_HIERARCHY_ENABLED_FLAG     CONSTANT NUMBER := 44;

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_SEG_rec                       IN  QP_Attributes_PUB.Seg_Rec_Type
,   p_old_SEG_rec                   IN  QP_Attributes_PUB.Seg_Rec_Type :=
                                        QP_Attributes_PUB.G_MISS_SEG_REC
,   x_SEG_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Seg_Rec_Type
);

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_SEG_rec                       IN  QP_Attributes_PUB.Seg_Rec_Type
,   p_old_SEG_rec                   IN  QP_Attributes_PUB.Seg_Rec_Type :=
                                        QP_Attributes_PUB.G_MISS_SEG_REC
,   x_SEG_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Seg_Rec_Type
);

--  Function Complete_Record

FUNCTION Complete_Record
(   p_SEG_rec                       IN  QP_Attributes_PUB.Seg_Rec_Type
,   p_old_SEG_rec                   IN  QP_Attributes_PUB.Seg_Rec_Type
) RETURN QP_Attributes_PUB.Seg_Rec_Type;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_SEG_rec                       IN  QP_Attributes_PUB.Seg_Rec_Type
) RETURN QP_Attributes_PUB.Seg_Rec_Type;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_SEG_rec                       IN  QP_Attributes_PUB.Seg_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_SEG_rec                       IN  QP_Attributes_PUB.Seg_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_segment_id                    IN  NUMBER
);

--  Function Query_Row

FUNCTION Query_Row
(   p_segment_id                    IN  NUMBER
) RETURN QP_Attributes_PUB.Seg_Rec_Type;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_segment_id                    IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_prc_context_id                IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN QP_Attributes_PUB.Seg_Tbl_Type;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_SEG_rec                       IN  QP_Attributes_PUB.Seg_Rec_Type
,   x_SEG_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Seg_Rec_Type
);

--  Function Get_Values

FUNCTION Get_Values
(   p_SEG_rec                       IN  QP_Attributes_PUB.Seg_Rec_Type
,   p_old_SEG_rec                   IN  QP_Attributes_PUB.Seg_Rec_Type :=
                                        QP_Attributes_PUB.G_MISS_SEG_REC
) RETURN QP_Attributes_PUB.Seg_Val_Rec_Type;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_SEG_rec                       IN  QP_Attributes_PUB.Seg_Rec_Type
,   p_SEG_val_rec                   IN  QP_Attributes_PUB.Seg_Val_Rec_Type
) RETURN QP_Attributes_PUB.Seg_Rec_Type;

END QP_Seg_Util;

 

/
