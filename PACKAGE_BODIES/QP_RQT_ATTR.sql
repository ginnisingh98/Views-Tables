--------------------------------------------------------
--  DDL for Package Body QP_RQT_ATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_RQT_ATTR" AS
/* $Header: QPXARQTB.pls 120.0 2005/06/02 00:41:23 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_RQT_ATTR';

--  Procedure : Get_Attr_Tbl

PROCEDURE Get_Attr_Tbl
IS
l_attr_rec                    OE_GENERATE.Attribute_Rec_Type;
I                             NUMBER := 0;
BEGIN

    OE_GENERATE.g_attr_tbl.DELETE;

    --  Load attributes

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'ATTRIBUTE1';
    l_attr_rec.type                := 'VARCHAR2';
    l_attr_rec.length              := 240;
    l_attr_rec.name                := 'attribute1';
    l_attr_rec.code                := 'attribute1';
    l_attr_rec.category            := OE_GENERATE.G_CAT_DESC_FLEX;
    l_attr_rec.text1               := 'RQT';
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'ATTRIBUTE10';
    l_attr_rec.type                := 'VARCHAR2';
    l_attr_rec.length              := 240;
    l_attr_rec.name                := 'attribute10';
    l_attr_rec.code                := 'attribute10';
    l_attr_rec.category            := OE_GENERATE.G_CAT_DESC_FLEX;
    l_attr_rec.text1               := 'RQT';
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'ATTRIBUTE11';
    l_attr_rec.type                := 'VARCHAR2';
    l_attr_rec.length              := 240;
    l_attr_rec.name                := 'attribute11';
    l_attr_rec.code                := 'attribute11';
    l_attr_rec.category            := OE_GENERATE.G_CAT_DESC_FLEX;
    l_attr_rec.text1               := 'RQT';
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'ATTRIBUTE12';
    l_attr_rec.type                := 'VARCHAR2';
    l_attr_rec.length              := 240;
    l_attr_rec.name                := 'attribute12';
    l_attr_rec.code                := 'attribute12';
    l_attr_rec.category            := OE_GENERATE.G_CAT_DESC_FLEX;
    l_attr_rec.text1               := 'RQT';
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'ATTRIBUTE13';
    l_attr_rec.type                := 'VARCHAR2';
    l_attr_rec.length              := 240;
    l_attr_rec.name                := 'attribute13';
    l_attr_rec.code                := 'attribute13';
    l_attr_rec.category            := OE_GENERATE.G_CAT_DESC_FLEX;
    l_attr_rec.text1               := 'RQT';
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'ATTRIBUTE14';
    l_attr_rec.type                := 'VARCHAR2';
    l_attr_rec.length              := 240;
    l_attr_rec.name                := 'attribute14';
    l_attr_rec.code                := 'attribute14';
    l_attr_rec.category            := OE_GENERATE.G_CAT_DESC_FLEX;
    l_attr_rec.text1               := 'RQT';
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'ATTRIBUTE15';
    l_attr_rec.type                := 'VARCHAR2';
    l_attr_rec.length              := 240;
    l_attr_rec.name                := 'attribute15';
    l_attr_rec.code                := 'attribute15';
    l_attr_rec.category            := OE_GENERATE.G_CAT_DESC_FLEX;
    l_attr_rec.text1               := 'RQT';
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'ATTRIBUTE2';
    l_attr_rec.type                := 'VARCHAR2';
    l_attr_rec.length              := 240;
    l_attr_rec.name                := 'attribute2';
    l_attr_rec.code                := 'attribute2';
    l_attr_rec.category            := OE_GENERATE.G_CAT_DESC_FLEX;
    l_attr_rec.text1               := 'RQT';
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'ATTRIBUTE3';
    l_attr_rec.type                := 'VARCHAR2';
    l_attr_rec.length              := 240;
    l_attr_rec.name                := 'attribute3';
    l_attr_rec.code                := 'attribute3';
    l_attr_rec.category            := OE_GENERATE.G_CAT_DESC_FLEX;
    l_attr_rec.text1               := 'RQT';
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'ATTRIBUTE4';
    l_attr_rec.type                := 'VARCHAR2';
    l_attr_rec.length              := 240;
    l_attr_rec.name                := 'attribute4';
    l_attr_rec.code                := 'attribute4';
    l_attr_rec.category            := OE_GENERATE.G_CAT_DESC_FLEX;
    l_attr_rec.text1               := 'RQT';
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'ATTRIBUTE5';
    l_attr_rec.type                := 'VARCHAR2';
    l_attr_rec.length              := 240;
    l_attr_rec.name                := 'attribute5';
    l_attr_rec.code                := 'attribute5';
    l_attr_rec.category            := OE_GENERATE.G_CAT_DESC_FLEX;
    l_attr_rec.text1               := 'RQT';
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'ATTRIBUTE6';
    l_attr_rec.type                := 'VARCHAR2';
    l_attr_rec.length              := 240;
    l_attr_rec.name                := 'attribute6';
    l_attr_rec.code                := 'attribute6';
    l_attr_rec.category            := OE_GENERATE.G_CAT_DESC_FLEX;
    l_attr_rec.text1               := 'RQT';
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'ATTRIBUTE7';
    l_attr_rec.type                := 'VARCHAR2';
    l_attr_rec.length              := 240;
    l_attr_rec.name                := 'attribute7';
    l_attr_rec.code                := 'attribute7';
    l_attr_rec.category            := OE_GENERATE.G_CAT_DESC_FLEX;
    l_attr_rec.text1               := 'RQT';
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'ATTRIBUTE8';
    l_attr_rec.type                := 'VARCHAR2';
    l_attr_rec.length              := 240;
    l_attr_rec.name                := 'attribute8';
    l_attr_rec.code                := 'attribute8';
    l_attr_rec.category            := OE_GENERATE.G_CAT_DESC_FLEX;
    l_attr_rec.text1               := 'RQT';
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'ATTRIBUTE9';
    l_attr_rec.type                := 'VARCHAR2';
    l_attr_rec.length              := 240;
    l_attr_rec.name                := 'attribute9';
    l_attr_rec.code                := 'attribute9';
    l_attr_rec.category            := OE_GENERATE.G_CAT_DESC_FLEX;
    l_attr_rec.text1               := 'RQT';
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'CONTEXT';
    l_attr_rec.type                := 'VARCHAR2';
    l_attr_rec.length              := 30;
    l_attr_rec.name                := 'context';
    l_attr_rec.code                := 'context';
    l_attr_rec.category            := OE_GENERATE.G_CAT_DESC_FLEX;
    l_attr_rec.text1               := 'RQT';
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'CREATED_BY';
    l_attr_rec.type                := 'NUMBER';
    l_attr_rec.name                := 'created_by';
    l_attr_rec.code                := 'created_by';
    l_attr_rec.category            := OE_GENERATE.G_CAT_WHO;
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'CREATION_DATE';
    l_attr_rec.type                := 'DATE';
    l_attr_rec.name                := 'creation_date';
    l_attr_rec.code                := 'creation_date';
    l_attr_rec.category            := OE_GENERATE.G_CAT_WHO;
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'ENABLED_FLAG';
    l_attr_rec.type                := 'VARCHAR2';
    l_attr_rec.length              := 1;
    l_attr_rec.name                := 'enabled';
    l_attr_rec.code                := 'enabled_flag';
    l_attr_rec.category            := OE_GENERATE.G_CAT_REGULAR;
    l_attr_rec.value               := TRUE;
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'LAST_UPDATED_BY';
    l_attr_rec.type                := 'NUMBER';
    l_attr_rec.name                := 'last_updated_by';
    l_attr_rec.code                := 'last_updated_by';
    l_attr_rec.category            := OE_GENERATE.G_CAT_WHO;
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'LAST_UPDATE_DATE';
    l_attr_rec.type                := 'DATE';
    l_attr_rec.name                := 'last_update_date';
    l_attr_rec.code                := 'last_update_date';
    l_attr_rec.category            := OE_GENERATE.G_CAT_WHO;
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'LAST_UPDATE_LOGIN';
    l_attr_rec.type                := 'NUMBER';
    l_attr_rec.name                := 'last_update_login';
    l_attr_rec.code                := 'last_update_login';
    l_attr_rec.category            := OE_GENERATE.G_CAT_WHO;
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'LINE_LEVEL_GLOBAL_STRUCT';
    l_attr_rec.type                := 'VARCHAR2';
    l_attr_rec.length              := 80;
    l_attr_rec.name                := 'line_level_global_struct';
    l_attr_rec.code                := 'line_level_global_struct';
    l_attr_rec.category            := OE_GENERATE.G_CAT_REGULAR;
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'LINE_LEVEL_VIEW_NAME';
    l_attr_rec.type                := 'VARCHAR2';
    l_attr_rec.length              := 80;
    l_attr_rec.name                := 'line_level_view_name';
    l_attr_rec.code                := 'line_level_view_name';
    l_attr_rec.category            := OE_GENERATE.G_CAT_REGULAR;
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'ORDER_LEVEL_GLOBAL_STRUCT';
    l_attr_rec.type                := 'VARCHAR2';
    l_attr_rec.length              := 80;
    l_attr_rec.name                := 'order_level_global_struct';
    l_attr_rec.code                := 'order_level_global_struct';
    l_attr_rec.category            := OE_GENERATE.G_CAT_REGULAR;
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'ORDER_LEVEL_VIEW_NAME';
    l_attr_rec.type                := 'VARCHAR2';
    l_attr_rec.length              := 80;
    l_attr_rec.name                := 'order_level_view_name';
    l_attr_rec.code                := 'order_level_view_name';
    l_attr_rec.category            := OE_GENERATE.G_CAT_REGULAR;
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'PROGRAM_APPLICATION_ID';
    l_attr_rec.type                := 'NUMBER';
    l_attr_rec.name                := 'program_application';
    l_attr_rec.code                := 'program_application_id';
    l_attr_rec.category            := OE_GENERATE.G_CAT_WHO;
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'PROGRAM_ID';
    l_attr_rec.type                := 'NUMBER';
    l_attr_rec.name                := 'program';
    l_attr_rec.code                := 'program_id';
    l_attr_rec.category            := OE_GENERATE.G_CAT_WHO;
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'PROGRAM_UPDATE_DATE';
    l_attr_rec.type                := 'DATE';
    l_attr_rec.name                := 'program_update_date';
    l_attr_rec.code                := 'program_update_date';
    l_attr_rec.category            := OE_GENERATE.G_CAT_WHO;
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'PTE_CODE';
    l_attr_rec.type                := 'VARCHAR2';
    l_attr_rec.length              := 30;
    l_attr_rec.name                := 'pte';
    l_attr_rec.code                := 'pte_code';
    l_attr_rec.category            := OE_GENERATE.G_CAT_REGULAR;
    l_attr_rec.value               := TRUE;
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'REQUEST_TYPE_CODE';
    l_attr_rec.type                := 'VARCHAR2';
    l_attr_rec.length              := 30;
    l_attr_rec.name                := 'request_type';
    l_attr_rec.code                := 'request_type_code';
    l_attr_rec.category            := OE_GENERATE.G_CAT_REGULAR;
    l_attr_rec.pk_flag             := TRUE;
    l_attr_rec.value               := TRUE;
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.column              := 'REQUEST_TYPE_DESC';
    l_attr_rec.type                := 'VARCHAR2';
    l_attr_rec.length              := 240;
    l_attr_rec.name                := 'request_type_desc';
    l_attr_rec.code                := 'request_type_desc';
    l_attr_rec.category            := OE_GENERATE.G_CAT_REGULAR;
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.type                := 'VARCHAR2';
    l_attr_rec.length              := 1;
    l_attr_rec.name                := 'return_status';
    l_attr_rec.code                := 'return_status';
    l_attr_rec.db_attr             := FALSE;
    l_attr_rec.category            := OE_GENERATE.G_CAT_TEMP;
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.type                := 'VARCHAR2';
    l_attr_rec.length              := 1;
    l_attr_rec.name                := 'db_flag';
    l_attr_rec.code                := 'db_flag';
    l_attr_rec.db_attr             := FALSE;
    l_attr_rec.category            := OE_GENERATE.G_CAT_TEMP;
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.type                := 'VARCHAR2';
    l_attr_rec.length              := 30;
    l_attr_rec.name                := 'operation';
    l_attr_rec.code                := 'operation';
    l_attr_rec.db_attr             := FALSE;
    l_attr_rec.category            := OE_GENERATE.G_CAT_TEMP;
    OE_GENERATE.g_attr_tbl(I)      := l_attr_rec;

END Get_Attr_Tbl;

--  Procedure : Get_Attr_Value_Tbl

PROCEDURE Get_Attr_Value_Tbl
IS
l_attr_rec                    OE_GENERATE.Attribute_Rec_Type;
I                             NUMBER := 0;
BEGIN

    OE_GENERATE.g_attr_value_tbl.DELETE;

    --  Load attribute values

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.name                := 'enabled';
    l_attr_rec.code                := 'enabled_flag';
    l_attr_rec.type                := OE_GENERATE.G_TYPE_CHAR;
    l_attr_rec.length              := 240;
    l_attr_rec.category            := OE_GENERATE.G_CAT_REGULAR;
    OE_GENERATE.g_attr_value_tbl(I) := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.name                := 'pte';
    l_attr_rec.code                := 'pte_code';
    l_attr_rec.type                := OE_GENERATE.G_TYPE_CHAR;
    l_attr_rec.length              := 240;
    l_attr_rec.category            := OE_GENERATE.G_CAT_REGULAR;
    OE_GENERATE.g_attr_value_tbl(I) := l_attr_rec;

    I                              := I + 1;
    l_attr_rec                     := OE_GENERATE.G_MISS_ATTR_REC;
    l_attr_rec.name                := 'request_type';
    l_attr_rec.code                := 'request_type_code';
    l_attr_rec.type                := OE_GENERATE.G_TYPE_CHAR;
    l_attr_rec.length              := 240;
    l_attr_rec.category            := OE_GENERATE.G_CAT_REGULAR;
    OE_GENERATE.g_attr_value_tbl(I) := l_attr_rec;

END Get_Attr_Value_Tbl;

END QP_RQT_ATTR;

/
