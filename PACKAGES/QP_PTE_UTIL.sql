--------------------------------------------------------
--  DDL for Package QP_PTE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_PTE_UTIL" AUTHID CURRENT_USER AS
/* $Header: QPXUPTES.pls 120.1 2005/06/12 23:47:41 appldev  $ */

--  Attributes global constants

G_DESCRIPTION                 CONSTANT NUMBER := 1;
G_ENABLED                     CONSTANT NUMBER := 2;
G_END_DATE_ACTIVE             CONSTANT NUMBER := 3;
G_LOOKUP                      CONSTANT NUMBER := 4;
G_LOOKUP_TYPE                 CONSTANT NUMBER := 5;
G_MEANING                     CONSTANT NUMBER := 6;
G_START_DATE_ACTIVE           CONSTANT NUMBER := 7;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 8;

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type
,   p_old_PTE_rec                   IN  QP_Attr_Map_PUB.Pte_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PTE_REC
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Pte_Rec_Type
);

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type
,   p_old_PTE_rec                   IN  QP_Attr_Map_PUB.Pte_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PTE_REC
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Pte_Rec_Type
);

--  Function Complete_Record

FUNCTION Complete_Record
(   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type
,   p_old_PTE_rec                   IN  QP_Attr_Map_PUB.Pte_Rec_Type
) RETURN QP_Attr_Map_PUB.Pte_Rec_Type;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type
) RETURN QP_Attr_Map_PUB.Pte_Rec_Type;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_lookup_code                   IN  VARCHAR2
);

--  Function Query_Row

FUNCTION Query_Row
(   p_lookup_code                   IN  VARCHAR2
) RETURN QP_Attr_Map_PUB.Pte_Rec_Type;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Pte_Rec_Type
);

--  Function Get_Values

FUNCTION Get_Values
(   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type
,   p_old_PTE_rec                   IN  QP_Attr_Map_PUB.Pte_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PTE_REC
) RETURN QP_Attr_Map_PUB.Pte_Val_Rec_Type;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type
,   p_PTE_val_rec                   IN  QP_Attr_Map_PUB.Pte_Val_Rec_Type
) RETURN QP_Attr_Map_PUB.Pte_Rec_Type;

END QP_Pte_Util;

 

/
