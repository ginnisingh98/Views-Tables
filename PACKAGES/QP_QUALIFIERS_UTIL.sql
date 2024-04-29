--------------------------------------------------------
--  DDL for Package QP_QUALIFIERS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_QUALIFIERS_UTIL" AUTHID CURRENT_USER AS
/* $Header: QPXUQPQS.pls 120.2.12010000.2 2008/09/05 06:07:36 jputta ship $ */

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
G_CREATED_FROM_RULE           CONSTANT NUMBER := 19;
G_CREATION_DATE               CONSTANT NUMBER := 20;
G_END_DATE_ACTIVE             CONSTANT NUMBER := 21;
G_EXCLUDER                    CONSTANT NUMBER := 22;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 23;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 24;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 25;
G_LIST_HEADER                 CONSTANT NUMBER := 26;
G_LIST_LINE                   CONSTANT NUMBER := 27;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 28;
G_PROGRAM                     CONSTANT NUMBER := 29;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 30;
G_QUALIFIER_ATTRIBUTE         CONSTANT NUMBER := 31;
G_QUALIFIER_ATTR_VALUE        CONSTANT NUMBER := 32;
G_QUALIFIER_ATTR_VALUE_TO     CONSTANT NUMBER := 33;
G_QUALIFIER_CONTEXT           CONSTANT NUMBER := 34;
G_QUALIFIER_DATATYPE          CONSTANT NUMBER := 35;
--G_QUALIFIER_DATE_FORMAT       CONSTANT NUMBER := 36;
G_QUALIFIER_GROUPING_NO       CONSTANT NUMBER := 36;
G_QUALIFIER                   CONSTANT NUMBER := 37;
--G_QUALIFIER_NUMBER_FORMAT     CONSTANT NUMBER := 38;
G_QUALIFIER_PRECEDENCE        CONSTANT NUMBER := 38;
G_QUALIFIER_RULE              CONSTANT NUMBER := 39;
G_REQUEST                     CONSTANT NUMBER := 40;
G_START_DATE_ACTIVE           CONSTANT NUMBER := 41;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 42;
G_QUALIFY_HIER_DESCENDENT_FLAG CONSTANT NUMBER := 43;  -- Added for TCA

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
,   p_old_QUALIFIERS_rec            IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_REC
,   x_QUALIFIERS_rec                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
);

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
,   p_old_QUALIFIERS_rec            IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_REC
,   x_QUALIFIERS_rec                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
);

--  Function Complete_Record

FUNCTION Complete_Record
(   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
,   p_old_QUALIFIERS_rec            IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
) RETURN QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
) RETURN QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
);

--  Procedure Update_coupon_Row Added for bug 7315016

PROCEDURE Update_coupon_Row
(   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
);


--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
);

--This procedure will be used by HTML Qualifier UI
--to insert qualifiers into dummy table for updates
PROCEDURE Insert_Row(p_qual_grp_no IN NUMBER,
                     p_list_header_id IN NUMBER,
                     p_list_line_id IN NUMBER,
                     p_transaction_id IN NUMBER);

--This procedure will be used by HTML Qualifier UI
--to delete rows from dummy table
Procedure Delete_Dummy_Rows(p_transaction_id IN NUMBER);

--This procedure will mark given qualifier as DELETED
Procedure Mark_Delete_Dummy_Qual(p_qual_id IN NUMBER
                                ,p_mode IN VARCHAR2
                                ,p_transaction_id IN NUMBER);

--This procedure will mark given qualifiergroup as DELETED
Procedure Mark_Delete_Dummy_Qual(p_qual_grp_no IN NUMBER,
                         p_list_header_id IN NUMBER,
                         p_list_line_id IN NUMBER,
                         p_transaction_id IN NUMBER);

--This procedure will delete the dummy qualifiers inserted for updates
Procedure Remove_Dummy_Quals(p_action_type IN VARCHAR2,
                         p_list_header_id IN NUMBER,
                         p_list_line_id IN NUMBER,
                         p_transaction_id IN NUMBER);

--  Procedure Delete_Row

-- added qualifier_rule-id parameter for cascade delete

PROCEDURE Delete_Row
(   p_qualifier_id                  IN  NUMBER := FND_API.G_MISS_NUM,
    p_qualifier_rule_id             IN  NUMBER := FND_API.G_MISS_NUM
);

PROCEDURE Delete_Row(p_qual_grp_no IN NUMBER,
                     p_list_header_id IN NUMBER,
                     p_list_line_id IN NUMBER,
                     p_transaction_id IN NUMBER);

--  Function Query_Row

FUNCTION Query_Row
(   p_qualifier_id                  IN  NUMBER
) RETURN QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_qualifier_id                  IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_qualifier_rule_id             IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
,   x_QUALIFIERS_rec                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
);

--  Function Get_Values

FUNCTION Get_Values
(   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
,   p_old_QUALIFIERS_rec            IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_REC
) RETURN QP_Qualifier_Rules_PUB.Qualifiers_Val_Rec_Type;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
,   p_QUALIFIERS_val_rec            IN  QP_Qualifier_Rules_PUB.Qualifiers_Val_Rec_Type
) RETURN QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;

Procedure Pre_Write_Process
(   p_QUALIFIERS_rec                      IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
,   p_old_QUALIFIERS_rec                  IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type :=
						QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_REC
,   x_QUALIFIERS_rec                      OUT NOCOPY /* file.sql.39 change */  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
);

END QP_Qualifiers_Util;

/
