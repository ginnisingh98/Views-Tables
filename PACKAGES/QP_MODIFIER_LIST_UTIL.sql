--------------------------------------------------------
--  DDL for Package QP_MODIFIER_LIST_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_MODIFIER_LIST_UTIL" AUTHID CURRENT_USER AS
/* $Header: QPXUMLHS.pls 120.2 2005/06/20 23:06:40 appldev ship $ */

--  Attributes global constants
/*
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
G_AUTOMATIC                   CONSTANT NUMBER := 16;
G_COMMENTS                    CONSTANT NUMBER := 17;
G_CONTEXT                     CONSTANT NUMBER := 18;
G_CREATED_BY                  CONSTANT NUMBER := 19;
G_CREATION_DATE               CONSTANT NUMBER := 20;
G_CURRENCY                    CONSTANT NUMBER := 21;
G_DISCOUNT_LINES              CONSTANT NUMBER := 22;
G_END_DATE_ACTIVE             CONSTANT NUMBER := 23;
G_FREIGHT_TERMS               CONSTANT NUMBER := 24;
G_GSA_INDICATOR               CONSTANT NUMBER := 25;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 26;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 27;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 28;
G_LIST_HEADER                 CONSTANT NUMBER := 29;
G_LIST_TYPE                   CONSTANT NUMBER := 30;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 31;
G_PROGRAM                     CONSTANT NUMBER := 32;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 33;
G_PRORATE                     CONSTANT NUMBER := 34;
G_REQUEST                     CONSTANT NUMBER := 35;
G_ROUNDING_FACTOR             CONSTANT NUMBER := 36;
G_SHIP_METHOD                 CONSTANT NUMBER := 37;
G_START_DATE_ACTIVE           CONSTANT NUMBER := 38;
G_TERMS                       CONSTANT NUMBER := 39;
G_VERSION_NO                  CONSTANT NUMBER := 40;
G_SOURCE_SYSTEM_CODE          CONSTANT NUMBER := 44;
G_ACTIVE_FLAG                 CONSTANT NUMBER := 45;
G_PARENT_LIST_HEADER_ID       CONSTANT NUMBER := 46;
G_START_DATE_ACTIVE_FIRST     CONSTANT NUMBER := 47;
G_END_DATE_ACTIVE_FIRST       CONSTANT NUMBER := 48;
G_ACTIVE_DATE_FIRST_TYPE      CONSTANT NUMBER := 49;
G_NAME     				CONSTANT NUMBER := 50;
G_DESCRIPTION     			CONSTANT NUMBER := 51;
G_START_DATE_ACTIVE_SECOND    CONSTANT NUMBER := 52;
G_END_DATE_ACTIVE_SECOND      CONSTANT NUMBER := 53;
G_ACTIVE_DATE_SECOND_TYPE     CONSTANT NUMBER := 54;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 55;
*/



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
G_AUTOMATIC                   CONSTANT NUMBER := 16;
G_COMMENTS                    CONSTANT NUMBER := 17;
G_CONTEXT                     CONSTANT NUMBER := 18;
G_CREATED_BY                  CONSTANT NUMBER := 19;
G_CREATION_DATE               CONSTANT NUMBER := 20;
G_CURRENCY                    CONSTANT NUMBER := 21;
G_DISCOUNT_LINES              CONSTANT NUMBER := 22;
G_END_DATE_ACTIVE             CONSTANT NUMBER := 23;
G_FREIGHT_TERMS               CONSTANT NUMBER := 24;
G_GSA_INDICATOR               CONSTANT NUMBER := 25;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 26;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 27;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 28;
G_LIST_HEADER                 CONSTANT NUMBER := 29;
G_LIST_TYPE                   CONSTANT NUMBER := 30;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 31;
G_PROGRAM                     CONSTANT NUMBER := 32;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 33;
G_PRORATE                     CONSTANT NUMBER := 34;
G_REQUEST                     CONSTANT NUMBER := 35;
G_ROUNDING_FACTOR             CONSTANT NUMBER := 36;
G_SHIP_METHOD                 CONSTANT NUMBER := 37;
G_START_DATE_ACTIVE           CONSTANT NUMBER := 38;
G_TERMS                       CONSTANT NUMBER := 39;
G_VERSION_NO                 CONSTANT NUMBER := 40;
G_PARENT_LIST_HEADER_ID		CONSTANT NUMBER := 41;
G_ACTIVE_DATE_FIRST_TYPE           CONSTANT NUMBER := 42;
G_START_DATE_ACTIVE_FIRST     CONSTANT NUMBER := 43;
G_END_DATE_ACTIVE_FIRST       CONSTANT NUMBER := 44;
G_ACTIVE_DATE_SECOND_TYPE          CONSTANT NUMBER := 45;
G_START_DATE_ACTIVE_SECOND    CONSTANT NUMBER := 46;
G_GLOBAL_FLAG                 CONSTANT NUMBER := 47;
G_END_DATE_ACTIVE_SECOND      CONSTANT NUMBER := 48;
G_ACTIVE_FLAG      				CONSTANT NUMBER := 49;
G_ASK_FOR      			CONSTANT NUMBER := 50;
G_NAME	      			CONSTANT NUMBER := 51;
G_DESCRIPTION      			CONSTANT NUMBER := 52;
G_SOURCE_SYSTEM_CODE          CONSTANT NUMBER := 53;
G_MAX_ATTR_ID      			CONSTANT NUMBER := 54;
G_PTE_CODE                    CONSTANT NUMBER := 55;
-- Blanket pricing
G_LIST_SOURCE_CODE            CONSTANT NUMBER := 56;
G_ORIG_SYSTEM_HEADER_REF      CONSTANT NUMBER := 57;
G_SHAREABLE_FLAG              CONSTANT NUMBER := 58;
--added for MOAC
G_ORG_ID                      CONSTANT NUMBER := 59;





--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
,   p_old_MODIFIER_LIST_rec         IN  QP_Modifiers_PUB.Modifier_List_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIER_LIST_REC
,   x_MODIFIER_LIST_rec             OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Modifier_List_Rec_Type
);

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
,   p_old_MODIFIER_LIST_rec         IN  QP_Modifiers_PUB.Modifier_List_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIER_LIST_REC
,   x_MODIFIER_LIST_rec             OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Modifier_List_Rec_Type
);

--  Function Complete_Record

FUNCTION Complete_Record
(   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
,   p_old_MODIFIER_LIST_rec         IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
) RETURN QP_Modifiers_PUB.Modifier_List_Rec_Type;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
) RETURN QP_Modifiers_PUB.Modifier_List_Rec_Type;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_list_header_id                IN  NUMBER
);

--  Function Query_Row

FUNCTION Query_Row
(   p_list_header_id                IN  NUMBER
) RETURN QP_Modifiers_PUB.Modifier_List_Rec_Type;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
,   x_MODIFIER_LIST_rec             OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Modifier_List_Rec_Type
);

--  Function Get_Values

FUNCTION Get_Values
(   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
,   p_old_MODIFIER_LIST_rec         IN  QP_Modifiers_PUB.Modifier_List_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIER_LIST_REC
) RETURN QP_Modifiers_PUB.Modifier_List_Val_Rec_Type;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
,   p_MODIFIER_LIST_val_rec         IN  QP_Modifiers_PUB.Modifier_List_Val_Rec_Type
) RETURN QP_Modifiers_PUB.Modifier_List_Rec_Type;

FUNCTION Get_Segment_Level_for_Group
  (p_list_header_id IN NUMBER
   ,p_list_line_id IN NUMBER
   ,p_qualifier_grouping_no IN NUMBER
  ) RETURN VARCHAR2;

END QP_Modifier_List_Util;

 

/
