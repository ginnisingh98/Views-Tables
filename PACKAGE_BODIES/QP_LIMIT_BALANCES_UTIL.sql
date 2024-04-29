--------------------------------------------------------
--  DDL for Package Body QP_LIMIT_BALANCES_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_LIMIT_BALANCES_UTIL" AS
/* $Header: QPXULMBB.pls 120.1 2005/06/10 02:17:54 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Limit_Balances_Util';

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_LIMIT_BALANCES_rec            IN  QP_Limits_PUB.Limit_Balances_Rec_Type
,   p_old_LIMIT_BALANCES_rec        IN  QP_Limits_PUB.Limit_Balances_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_BALANCES_REC
,   x_LIMIT_BALANCES_rec            OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Balances_Rec_Type
)
IS
l_index                       NUMBER := 0;
l_src_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
BEGIN

    --  Load out record

    x_LIMIT_BALANCES_rec := p_LIMIT_BALANCES_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute1,p_old_LIMIT_BALANCES_rec.attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute10,p_old_LIMIT_BALANCES_rec.attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute11,p_old_LIMIT_BALANCES_rec.attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute12,p_old_LIMIT_BALANCES_rec.attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute13,p_old_LIMIT_BALANCES_rec.attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute14,p_old_LIMIT_BALANCES_rec.attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute15,p_old_LIMIT_BALANCES_rec.attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute2,p_old_LIMIT_BALANCES_rec.attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute3,p_old_LIMIT_BALANCES_rec.attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute4,p_old_LIMIT_BALANCES_rec.attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute5,p_old_LIMIT_BALANCES_rec.attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute6,p_old_LIMIT_BALANCES_rec.attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute7,p_old_LIMIT_BALANCES_rec.attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute8,p_old_LIMIT_BALANCES_rec.attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute9,p_old_LIMIT_BALANCES_rec.attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.available_amount,p_old_LIMIT_BALANCES_rec.available_amount)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_AVAILABLE_AMOUNT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.consumed_amount,p_old_LIMIT_BALANCES_rec.consumed_amount)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_CONSUMED_AMOUNT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.context,p_old_LIMIT_BALANCES_rec.context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.created_by,p_old_LIMIT_BALANCES_rec.created_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_CREATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.creation_date,p_old_LIMIT_BALANCES_rec.creation_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.last_updated_by,p_old_LIMIT_BALANCES_rec.last_updated_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.last_update_date,p_old_LIMIT_BALANCES_rec.last_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.last_update_login,p_old_LIMIT_BALANCES_rec.last_update_login)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.limit_balance_id,p_old_LIMIT_BALANCES_rec.limit_balance_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_LIMIT_BALANCE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.limit_id,p_old_LIMIT_BALANCES_rec.limit_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_LIMIT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.program_application_id,p_old_LIMIT_BALANCES_rec.program_application_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_PROGRAM_APPLICATION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.program_id,p_old_LIMIT_BALANCES_rec.program_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_PROGRAM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.program_update_date,p_old_LIMIT_BALANCES_rec.program_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_PROGRAM_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.request_id,p_old_LIMIT_BALANCES_rec.request_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_REQUEST;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.reserved_amount,p_old_LIMIT_BALANCES_rec.reserved_amount)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_RESERVED_AMOUNT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attr1_type,p_old_LIMIT_BALANCES_rec.multival_attr1_type)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_MULTIVAL_ATTR1_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attr1_context,p_old_LIMIT_BALANCES_rec.multival_attr1_context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_MULTIVAL_ATTR1_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attribute1,p_old_LIMIT_BALANCES_rec.multival_attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_MULTIVAL_ATTRIBUTE1;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attr1_value,p_old_LIMIT_BALANCES_rec.multival_attr1_value)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_MULTIVAL_ATTR1_VALUE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attr1_datatype,p_old_LIMIT_BALANCES_rec.multival_attr1_datatype)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_MULTIVAL_ATTR1_DATATYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attr2_type,p_old_LIMIT_BALANCES_rec.multival_attr2_type)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_MULTIVAL_ATTR2_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attr2_context,p_old_LIMIT_BALANCES_rec.multival_attr2_context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_MULTIVAL_ATTR2_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attribute2,p_old_LIMIT_BALANCES_rec.multival_attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_MULTIVAL_ATTRIBUTE2;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attr2_value,p_old_LIMIT_BALANCES_rec.multival_attr2_value)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_MULTIVAL_ATTR2_VALUE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attr2_datatype,p_old_LIMIT_BALANCES_rec.multival_attr2_datatype)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_MULTIVAL_ATTR2_DATATYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.organization_attr_context,p_old_LIMIT_BALANCES_rec.organization_attr_context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ORGANIZATION_ATTR_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.organization_attribute,p_old_LIMIT_BALANCES_rec.organization_attribute)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ORGANIZATION_ATTRIBUTE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.organization_attr_value,p_old_LIMIT_BALANCES_rec.organization_attr_value)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ORGANIZATION_ATTR_VALUE;
        END IF;

    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_AVAILABLE_AMOUNT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_AVAILABLE_AMOUNT;
    ELSIF p_attr_id = G_CONSUMED_AMOUNT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_CONSUMED_AMOUNT;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_CONTEXT;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_CREATION_DATE;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_LIMIT_BALANCE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_LIMIT_BALANCE;
    ELSIF p_attr_id = G_LIMIT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_LIMIT;
    ELSIF p_attr_id = G_PROGRAM_APPLICATION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_PROGRAM_APPLICATION;
    ELSIF p_attr_id = G_PROGRAM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_PROGRAM;
    ELSIF p_attr_id = G_PROGRAM_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_PROGRAM_UPDATE_DATE;
    ELSIF p_attr_id = G_REQUEST THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_REQUEST;
    ELSIF p_attr_id = G_RESERVED_AMOUNT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_RESERVED_AMOUNT;
    ELSIF p_attr_id = G_MULTIVAL_ATTR1_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_MULTIVAL_ATTR1_TYPE;
    ELSIF p_attr_id = G_MULTIVAL_ATTR1_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_MULTIVAL_ATTR1_CONTEXT;
    ELSIF p_attr_id = G_MULTIVAL_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_MULTIVAL_ATTRIBUTE1;
    ELSIF p_attr_id = G_MULTIVAL_ATTR1_VALUE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_MULTIVAL_ATTR1_VALUE;
    ELSIF p_attr_id = G_MULTIVAL_ATTR1_DATATYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_MULTIVAL_ATTR1_DATATYPE;
    ELSIF p_attr_id = G_MULTIVAL_ATTR2_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_MULTIVAL_ATTR2_TYPE;
    ELSIF p_attr_id = G_MULTIVAL_ATTR2_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_MULTIVAL_ATTR2_CONTEXT;
    ELSIF p_attr_id = G_MULTIVAL_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_MULTIVAL_ATTRIBUTE2;
    ELSIF p_attr_id = G_MULTIVAL_ATTR2_VALUE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_MULTIVAL_ATTR2_VALUE;
    ELSIF p_attr_id = G_MULTIVAL_ATTR2_DATATYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_MULTIVAL_ATTR2_DATATYPE;
    ELSIF p_attr_id = G_ORGANIZATION_ATTR_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ORGANIZATION_ATTR_CONTEXT;
    ELSIF p_attr_id = G_ORGANIZATION_ATTRIBUTE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ORGANIZATION_ATTRIBUTE;
    ELSIF p_attr_id = G_ORGANIZATION_ATTR_VALUE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_BALANCES_UTIL.G_ORGANIZATION_ATTR_VALUE;
    END IF;

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_LIMIT_BALANCES_rec            IN  QP_Limits_PUB.Limit_Balances_Rec_Type
,   p_old_LIMIT_BALANCES_rec        IN  QP_Limits_PUB.Limit_Balances_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_BALANCES_REC
,   x_LIMIT_BALANCES_rec            OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Balances_Rec_Type
)
IS
BEGIN

    --  Load out record

    x_LIMIT_BALANCES_rec := p_LIMIT_BALANCES_rec;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute1,p_old_LIMIT_BALANCES_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute10,p_old_LIMIT_BALANCES_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute11,p_old_LIMIT_BALANCES_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute12,p_old_LIMIT_BALANCES_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute13,p_old_LIMIT_BALANCES_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute14,p_old_LIMIT_BALANCES_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute15,p_old_LIMIT_BALANCES_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute2,p_old_LIMIT_BALANCES_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute3,p_old_LIMIT_BALANCES_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute4,p_old_LIMIT_BALANCES_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute5,p_old_LIMIT_BALANCES_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute6,p_old_LIMIT_BALANCES_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute7,p_old_LIMIT_BALANCES_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute8,p_old_LIMIT_BALANCES_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute9,p_old_LIMIT_BALANCES_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.available_amount,p_old_LIMIT_BALANCES_rec.available_amount)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.consumed_amount,p_old_LIMIT_BALANCES_rec.consumed_amount)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.context,p_old_LIMIT_BALANCES_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.created_by,p_old_LIMIT_BALANCES_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.creation_date,p_old_LIMIT_BALANCES_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.last_updated_by,p_old_LIMIT_BALANCES_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.last_update_date,p_old_LIMIT_BALANCES_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.last_update_login,p_old_LIMIT_BALANCES_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.limit_balance_id,p_old_LIMIT_BALANCES_rec.limit_balance_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.limit_id,p_old_LIMIT_BALANCES_rec.limit_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.program_application_id,p_old_LIMIT_BALANCES_rec.program_application_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.program_id,p_old_LIMIT_BALANCES_rec.program_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.program_update_date,p_old_LIMIT_BALANCES_rec.program_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.request_id,p_old_LIMIT_BALANCES_rec.request_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.reserved_amount,p_old_LIMIT_BALANCES_rec.reserved_amount)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attr1_type,p_old_LIMIT_BALANCES_rec.multival_attr1_type)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attr1_context,p_old_LIMIT_BALANCES_rec.multival_attr1_context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attribute1,p_old_LIMIT_BALANCES_rec.multival_attribute1)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attr1_value,p_old_LIMIT_BALANCES_rec.multival_attr1_value)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attr1_datatype,p_old_LIMIT_BALANCES_rec.multival_attr1_datatype)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attr2_type,p_old_LIMIT_BALANCES_rec.multival_attr2_type)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attr2_context,p_old_LIMIT_BALANCES_rec.multival_attr2_context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attribute2,p_old_LIMIT_BALANCES_rec.multival_attribute2)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attr2_value,p_old_LIMIT_BALANCES_rec.multival_attr2_value)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attr2_datatype,p_old_LIMIT_BALANCES_rec.multival_attr2_datatype)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.organization_attr_context,p_old_LIMIT_BALANCES_rec.organization_attr_context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.organization_attribute,p_old_LIMIT_BALANCES_rec.organization_attribute)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.organization_attr_value,p_old_LIMIT_BALANCES_rec.organization_attr_value)
    THEN
        NULL;
    END IF;


END Apply_Attribute_Changes;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_LIMIT_BALANCES_rec            IN  QP_Limits_PUB.Limit_Balances_Rec_Type
,   p_old_LIMIT_BALANCES_rec        IN  QP_Limits_PUB.Limit_Balances_Rec_Type
) RETURN QP_Limits_PUB.Limit_Balances_Rec_Type
IS
l_LIMIT_BALANCES_rec          QP_Limits_PUB.Limit_Balances_Rec_Type := p_LIMIT_BALANCES_rec;
BEGIN

    IF l_LIMIT_BALANCES_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute1 := p_old_LIMIT_BALANCES_rec.attribute1;
    END IF;

    IF l_LIMIT_BALANCES_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute10 := p_old_LIMIT_BALANCES_rec.attribute10;
    END IF;

    IF l_LIMIT_BALANCES_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute11 := p_old_LIMIT_BALANCES_rec.attribute11;
    END IF;

    IF l_LIMIT_BALANCES_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute12 := p_old_LIMIT_BALANCES_rec.attribute12;
    END IF;

    IF l_LIMIT_BALANCES_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute13 := p_old_LIMIT_BALANCES_rec.attribute13;
    END IF;

    IF l_LIMIT_BALANCES_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute14 := p_old_LIMIT_BALANCES_rec.attribute14;
    END IF;

    IF l_LIMIT_BALANCES_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute15 := p_old_LIMIT_BALANCES_rec.attribute15;
    END IF;

    IF l_LIMIT_BALANCES_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute2 := p_old_LIMIT_BALANCES_rec.attribute2;
    END IF;

    IF l_LIMIT_BALANCES_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute3 := p_old_LIMIT_BALANCES_rec.attribute3;
    END IF;

    IF l_LIMIT_BALANCES_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute4 := p_old_LIMIT_BALANCES_rec.attribute4;
    END IF;

    IF l_LIMIT_BALANCES_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute5 := p_old_LIMIT_BALANCES_rec.attribute5;
    END IF;

    IF l_LIMIT_BALANCES_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute6 := p_old_LIMIT_BALANCES_rec.attribute6;
    END IF;

    IF l_LIMIT_BALANCES_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute7 := p_old_LIMIT_BALANCES_rec.attribute7;
    END IF;

    IF l_LIMIT_BALANCES_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute8 := p_old_LIMIT_BALANCES_rec.attribute8;
    END IF;

    IF l_LIMIT_BALANCES_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute9 := p_old_LIMIT_BALANCES_rec.attribute9;
    END IF;

    IF l_LIMIT_BALANCES_rec.available_amount = FND_API.G_MISS_NUM THEN
        l_LIMIT_BALANCES_rec.available_amount := p_old_LIMIT_BALANCES_rec.available_amount;
    END IF;

    IF l_LIMIT_BALANCES_rec.consumed_amount = FND_API.G_MISS_NUM THEN
        l_LIMIT_BALANCES_rec.consumed_amount := p_old_LIMIT_BALANCES_rec.consumed_amount;
    END IF;

    IF l_LIMIT_BALANCES_rec.context = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.context := p_old_LIMIT_BALANCES_rec.context;
    END IF;

    IF l_LIMIT_BALANCES_rec.created_by = FND_API.G_MISS_NUM THEN
        l_LIMIT_BALANCES_rec.created_by := p_old_LIMIT_BALANCES_rec.created_by;
    END IF;

    IF l_LIMIT_BALANCES_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_LIMIT_BALANCES_rec.creation_date := p_old_LIMIT_BALANCES_rec.creation_date;
    END IF;

    IF l_LIMIT_BALANCES_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_LIMIT_BALANCES_rec.last_updated_by := p_old_LIMIT_BALANCES_rec.last_updated_by;
    END IF;

    IF l_LIMIT_BALANCES_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_LIMIT_BALANCES_rec.last_update_date := p_old_LIMIT_BALANCES_rec.last_update_date;
    END IF;

    IF l_LIMIT_BALANCES_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_LIMIT_BALANCES_rec.last_update_login := p_old_LIMIT_BALANCES_rec.last_update_login;
    END IF;

    IF l_LIMIT_BALANCES_rec.limit_balance_id = FND_API.G_MISS_NUM THEN
        l_LIMIT_BALANCES_rec.limit_balance_id := p_old_LIMIT_BALANCES_rec.limit_balance_id;
    END IF;

    IF l_LIMIT_BALANCES_rec.limit_id = FND_API.G_MISS_NUM THEN
        l_LIMIT_BALANCES_rec.limit_id := p_old_LIMIT_BALANCES_rec.limit_id;
    END IF;

    IF l_LIMIT_BALANCES_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_LIMIT_BALANCES_rec.program_application_id := p_old_LIMIT_BALANCES_rec.program_application_id;
    END IF;

    IF l_LIMIT_BALANCES_rec.program_id = FND_API.G_MISS_NUM THEN
        l_LIMIT_BALANCES_rec.program_id := p_old_LIMIT_BALANCES_rec.program_id;
    END IF;

    IF l_LIMIT_BALANCES_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_LIMIT_BALANCES_rec.program_update_date := p_old_LIMIT_BALANCES_rec.program_update_date;
    END IF;

    IF l_LIMIT_BALANCES_rec.request_id = FND_API.G_MISS_NUM THEN
        l_LIMIT_BALANCES_rec.request_id := p_old_LIMIT_BALANCES_rec.request_id;
    END IF;

    IF l_LIMIT_BALANCES_rec.reserved_amount = FND_API.G_MISS_NUM THEN
        l_LIMIT_BALANCES_rec.reserved_amount := p_old_LIMIT_BALANCES_rec.reserved_amount;
    END IF;

    IF l_LIMIT_BALANCES_rec.multival_attr1_type = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.multival_attr1_type := p_old_LIMIT_BALANCES_rec.multival_attr1_type;
    END IF;

    IF l_LIMIT_BALANCES_rec.multival_attr1_context = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.multival_attr1_context := p_old_LIMIT_BALANCES_rec.multival_attr1_context;
    END IF;

    IF l_LIMIT_BALANCES_rec.multival_attribute1 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.multival_attribute1 := p_old_LIMIT_BALANCES_rec.multival_attribute1;
    END IF;

    IF l_LIMIT_BALANCES_rec.multival_attr1_value = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.multival_attr1_value := p_old_LIMIT_BALANCES_rec.multival_attr1_value;
    END IF;

    IF l_LIMIT_BALANCES_rec.multival_attr1_datatype = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.multival_attr1_datatype := p_old_LIMIT_BALANCES_rec.multival_attr1_datatype;
    END IF;

    IF l_LIMIT_BALANCES_rec.multival_attr2_type = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.multival_attr2_type := p_old_LIMIT_BALANCES_rec.multival_attr2_type;
    END IF;

    IF l_LIMIT_BALANCES_rec.multival_attr2_context = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.multival_attr2_context := p_old_LIMIT_BALANCES_rec.multival_attr2_context;
    END IF;

    IF l_LIMIT_BALANCES_rec.multival_attribute2 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.multival_attribute2 := p_old_LIMIT_BALANCES_rec.multival_attribute2;
    END IF;

    IF l_LIMIT_BALANCES_rec.multival_attr2_value = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.multival_attr2_value := p_old_LIMIT_BALANCES_rec.multival_attr2_value;
    END IF;

    IF l_LIMIT_BALANCES_rec.multival_attr2_datatype = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.multival_attr2_datatype := p_old_LIMIT_BALANCES_rec.multival_attr2_datatype;
    END IF;

    IF l_LIMIT_BALANCES_rec.organization_attr_context = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.organization_attr_context := p_old_LIMIT_BALANCES_rec.organization_attr_context;
    END IF;

    IF l_LIMIT_BALANCES_rec.organization_attribute = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.organization_attribute := p_old_LIMIT_BALANCES_rec.organization_attribute;
    END IF;

    IF l_LIMIT_BALANCES_rec.organization_attr_value = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.organization_attr_value := p_old_LIMIT_BALANCES_rec.organization_attr_value;
    END IF;

    RETURN l_LIMIT_BALANCES_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_LIMIT_BALANCES_rec            IN  QP_Limits_PUB.Limit_Balances_Rec_Type
) RETURN QP_Limits_PUB.Limit_Balances_Rec_Type
IS
l_LIMIT_BALANCES_rec          QP_Limits_PUB.Limit_Balances_Rec_Type := p_LIMIT_BALANCES_rec;
BEGIN

    IF l_LIMIT_BALANCES_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute1 := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute10 := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute11 := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute12 := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute13 := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute14 := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute15 := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute2 := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute3 := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute4 := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute5 := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute6 := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute7 := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute8 := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.attribute9 := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.available_amount = FND_API.G_MISS_NUM THEN
        l_LIMIT_BALANCES_rec.available_amount := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.consumed_amount = FND_API.G_MISS_NUM THEN
        l_LIMIT_BALANCES_rec.consumed_amount := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.context = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.context := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.created_by = FND_API.G_MISS_NUM THEN
        l_LIMIT_BALANCES_rec.created_by := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_LIMIT_BALANCES_rec.creation_date := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_LIMIT_BALANCES_rec.last_updated_by := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_LIMIT_BALANCES_rec.last_update_date := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_LIMIT_BALANCES_rec.last_update_login := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.limit_balance_id = FND_API.G_MISS_NUM THEN
        l_LIMIT_BALANCES_rec.limit_balance_id := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.limit_id = FND_API.G_MISS_NUM THEN
        l_LIMIT_BALANCES_rec.limit_id := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_LIMIT_BALANCES_rec.program_application_id := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.program_id = FND_API.G_MISS_NUM THEN
        l_LIMIT_BALANCES_rec.program_id := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_LIMIT_BALANCES_rec.program_update_date := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.request_id = FND_API.G_MISS_NUM THEN
        l_LIMIT_BALANCES_rec.request_id := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.reserved_amount = FND_API.G_MISS_NUM THEN
        l_LIMIT_BALANCES_rec.reserved_amount := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.multival_attr1_type = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.multival_attr1_type := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.multival_attr1_context = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.multival_attr1_context := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.multival_attribute1 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.multival_attribute1 := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.multival_attr1_value = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.multival_attr1_value := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.multival_attr1_datatype = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.multival_attr1_datatype := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.multival_attr2_type = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.multival_attr2_type := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.multival_attr2_context = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.multival_attr2_context := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.multival_attribute2 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.multival_attribute2 := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.multival_attr2_value = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.multival_attr2_value := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.multival_attr2_datatype = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.multival_attr2_datatype := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.organization_attr_context = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.organization_attr_context := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.organization_attribute = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.organization_attribute := NULL;
    END IF;

    IF l_LIMIT_BALANCES_rec.organization_attr_value = FND_API.G_MISS_CHAR THEN
        l_LIMIT_BALANCES_rec.organization_attr_value := NULL;
    END IF;

    RETURN l_LIMIT_BALANCES_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_LIMIT_BALANCES_rec            IN  QP_Limits_PUB.Limit_Balances_Rec_Type
)
IS
l_check_active_flag VARCHAR2(1);
l_active_flag VARCHAR2(1);
BEGIN
  SELECT active_flag
       INTO l_active_flag
       FROM QP_LIMITS a,QP_LIST_HEADERS_B b
       WHERE a.limit_id=p_LIMIT_BALANCES_rec.limit_id
       AND   b.list_header_id=a.list_header_id;


    UPDATE  QP_LIMIT_BALANCES
    SET     ATTRIBUTE1                     = p_LIMIT_BALANCES_rec.attribute1
    ,       ATTRIBUTE10                    = p_LIMIT_BALANCES_rec.attribute10
    ,       ATTRIBUTE11                    = p_LIMIT_BALANCES_rec.attribute11
    ,       ATTRIBUTE12                    = p_LIMIT_BALANCES_rec.attribute12
    ,       ATTRIBUTE13                    = p_LIMIT_BALANCES_rec.attribute13
    ,       ATTRIBUTE14                    = p_LIMIT_BALANCES_rec.attribute14
    ,       ATTRIBUTE15                    = p_LIMIT_BALANCES_rec.attribute15
    ,       ATTRIBUTE2                     = p_LIMIT_BALANCES_rec.attribute2
    ,       ATTRIBUTE3                     = p_LIMIT_BALANCES_rec.attribute3
    ,       ATTRIBUTE4                     = p_LIMIT_BALANCES_rec.attribute4
    ,       ATTRIBUTE5                     = p_LIMIT_BALANCES_rec.attribute5
    ,       ATTRIBUTE6                     = p_LIMIT_BALANCES_rec.attribute6
    ,       ATTRIBUTE7                     = p_LIMIT_BALANCES_rec.attribute7
    ,       ATTRIBUTE8                     = p_LIMIT_BALANCES_rec.attribute8
    ,       ATTRIBUTE9                     = p_LIMIT_BALANCES_rec.attribute9
    ,       AVAILABLE_AMOUNT               = p_LIMIT_BALANCES_rec.available_amount
    ,       CONSUMED_AMOUNT                = p_LIMIT_BALANCES_rec.consumed_amount
    ,       CONTEXT                        = p_LIMIT_BALANCES_rec.context
    ,       CREATED_BY                     = p_LIMIT_BALANCES_rec.created_by
    ,       CREATION_DATE                  = p_LIMIT_BALANCES_rec.creation_date
    ,       LAST_UPDATED_BY                = p_LIMIT_BALANCES_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_LIMIT_BALANCES_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_LIMIT_BALANCES_rec.last_update_login
    ,       LIMIT_BALANCE_ID               = p_LIMIT_BALANCES_rec.limit_balance_id
    ,       LIMIT_ID                       = p_LIMIT_BALANCES_rec.limit_id
    ,       PROGRAM_APPLICATION_ID         = p_LIMIT_BALANCES_rec.program_application_id
    ,       PROGRAM_ID                     = p_LIMIT_BALANCES_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_LIMIT_BALANCES_rec.program_update_date
    ,       REQUEST_ID                     = p_LIMIT_BALANCES_rec.request_id
    ,       RESERVED_AMOUNT                = p_LIMIT_BALANCES_rec.reserved_amount
    ,       MULTIVAL_ATTR1_TYPE            = p_LIMIT_BALANCES_rec.multival_attr1_type
    ,       MULTIVAL_ATTR1_CONTEXT         = p_LIMIT_BALANCES_rec.multival_attr1_context
    ,       MULTIVAL_ATTRIBUTE1            = p_LIMIT_BALANCES_rec.multival_attribute1
    ,       MULTIVAL_ATTR1_VALUE           = p_LIMIT_BALANCES_rec.multival_attr1_value
    ,       MULTIVAL_ATTR1_DATATYPE        = p_LIMIT_BALANCES_rec.multival_attr1_datatype
    ,       MULTIVAL_ATTR2_TYPE            = p_LIMIT_BALANCES_rec.multival_attr2_type
    ,       MULTIVAL_ATTR2_CONTEXT         = p_LIMIT_BALANCES_rec.multival_attr2_context
    ,       MULTIVAL_ATTRIBUTE2            = p_LIMIT_BALANCES_rec.multival_attribute2
    ,       MULTIVAL_ATTR2_VALUE           = p_LIMIT_BALANCES_rec.multival_attr2_value
    ,       MULTIVAL_ATTR2_DATATYPE        = p_LIMIT_BALANCES_rec.multival_attr2_datatype
    ,       ORGANIZATION_ATTR_CONTEXT      = p_LIMIT_BALANCES_rec.organization_attr_context
    ,       ORGANIZATION_ATTRIBUTE         = p_LIMIT_BALANCES_rec.organization_attribute
    ,       ORGANIZATION_ATTR_VALUE        = p_LIMIT_BALANCES_rec.organization_attr_value
    WHERE   LIMIT_BALANCE_ID = p_LIMIT_BALANCES_rec.limit_balance_id
    ;


l_check_active_flag:=nvl(fnd_profile.value('QP_BUILD_ATTRIBUTES_MAPPING_OPTIONS'),'N');
IF (l_check_active_flag='N') OR (l_check_active_flag='Y' AND l_active_flag='Y') THEN

IF(p_LIMIT_BALANCES_rec.multival_attr1_context IS NOT NULL)
AND  (p_LIMIT_BALANCES_rec.multival_attribute1 IS NOT NULL) THEN
UPDATE qp_pte_segments SET used_in_setup='Y'
WHERE nvl(used_in_setup,'N')='N'
AND segment_id IN
(SELECT a.segment_id
 FROM   qp_segments_b a,qp_prc_contexts_b b
 WHERE  a.segment_mapping_column=p_LIMIT_BALANCES_rec.multival_attribute1
 AND    a.prc_context_id=b.prc_context_id
 AND b.prc_context_type = p_LIMIT_BALANCES_rec.multival_attr1_type
 AND    b.prc_context_code=p_LIMIT_BALANCES_rec.multival_attr1_context);
END IF;

IF(p_LIMIT_BALANCES_rec.multival_attr2_context IS NOT NULL) AND
  (p_LIMIT_BALANCES_rec.multival_attribute2 IS NOT NULL) THEN
UPDATE qp_pte_segments SET used_in_setup='Y'
WHERE nvl(used_in_setup,'N')='N'
AND segment_id IN
(SELECT a.segment_id
 FROM   qp_segments_b a,qp_prc_contexts_b b
 WHERE  a.segment_mapping_column=p_LIMIT_BALANCES_rec.multival_attribute2
 AND    a.prc_context_id=b.prc_context_id
 AND b.prc_context_type = p_LIMIT_BALANCES_rec.multival_attr2_type
 AND    b.prc_context_code=p_LIMIT_BALANCES_rec.multival_attr2_context);
END IF;
END IF;


EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Row;

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_LIMIT_BALANCES_rec            IN  QP_Limits_PUB.Limit_Balances_Rec_Type
)
IS
l_check_active_flag VARCHAR2(1);
l_active_flag VARCHAR2(1);
BEGIN
SELECT active_flag
       INTO l_active_flag
       FROM QP_LIMITS a,QP_LIST_HEADERS_B b
       WHERE a.limit_id=p_LIMIT_BALANCES_rec.limit_id
       AND   b.list_header_id=a.list_header_id;

    INSERT  INTO QP_LIMIT_BALANCES
    (       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       AVAILABLE_AMOUNT
    ,       CONSUMED_AMOUNT
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIMIT_BALANCE_ID
    ,       LIMIT_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       RESERVED_AMOUNT
    ,       MULTIVAL_ATTR1_TYPE
    ,       MULTIVAL_ATTR1_CONTEXT
    ,       MULTIVAL_ATTRIBUTE1
    ,       MULTIVAL_ATTR1_VALUE
    ,       MULTIVAL_ATTR1_DATATYPE
    ,       MULTIVAL_ATTR2_TYPE
    ,       MULTIVAL_ATTR2_CONTEXT
    ,       MULTIVAL_ATTRIBUTE2
    ,       MULTIVAL_ATTR2_VALUE
    ,       MULTIVAL_ATTR2_DATATYPE
    ,       ORGANIZATION_ATTR_CONTEXT
    ,       ORGANIZATION_ATTRIBUTE
    ,       ORGANIZATION_ATTR_VALUE
    )
    VALUES
    (       p_LIMIT_BALANCES_rec.attribute1
    ,       p_LIMIT_BALANCES_rec.attribute10
    ,       p_LIMIT_BALANCES_rec.attribute11
    ,       p_LIMIT_BALANCES_rec.attribute12
    ,       p_LIMIT_BALANCES_rec.attribute13
    ,       p_LIMIT_BALANCES_rec.attribute14
    ,       p_LIMIT_BALANCES_rec.attribute15
    ,       p_LIMIT_BALANCES_rec.attribute2
    ,       p_LIMIT_BALANCES_rec.attribute3
    ,       p_LIMIT_BALANCES_rec.attribute4
    ,       p_LIMIT_BALANCES_rec.attribute5
    ,       p_LIMIT_BALANCES_rec.attribute6
    ,       p_LIMIT_BALANCES_rec.attribute7
    ,       p_LIMIT_BALANCES_rec.attribute8
    ,       p_LIMIT_BALANCES_rec.attribute9
    ,       p_LIMIT_BALANCES_rec.available_amount
    ,       p_LIMIT_BALANCES_rec.consumed_amount
    ,       p_LIMIT_BALANCES_rec.context
    ,       p_LIMIT_BALANCES_rec.created_by
    ,       p_LIMIT_BALANCES_rec.creation_date
    ,       p_LIMIT_BALANCES_rec.last_updated_by
    ,       p_LIMIT_BALANCES_rec.last_update_date
    ,       p_LIMIT_BALANCES_rec.last_update_login
    ,       p_LIMIT_BALANCES_rec.limit_balance_id
    ,       p_LIMIT_BALANCES_rec.limit_id
    ,       p_LIMIT_BALANCES_rec.program_application_id
    ,       p_LIMIT_BALANCES_rec.program_id
    ,       p_LIMIT_BALANCES_rec.program_update_date
    ,       p_LIMIT_BALANCES_rec.request_id
    ,       p_LIMIT_BALANCES_rec.reserved_amount
    ,       p_LIMIT_BALANCES_rec.multival_attr1_type
    ,       p_LIMIT_BALANCES_rec.multival_attr1_context
    ,       p_LIMIT_BALANCES_rec.multival_attribute1
    ,       p_LIMIT_BALANCES_rec.multival_attr1_value
    ,       p_LIMIT_BALANCES_rec.multival_attr1_datatype
    ,       p_LIMIT_BALANCES_rec.multival_attr2_type
    ,       p_LIMIT_BALANCES_rec.multival_attr2_context
    ,       p_LIMIT_BALANCES_rec.multival_attribute2
    ,       p_LIMIT_BALANCES_rec.multival_attr2_value
    ,       p_LIMIT_BALANCES_rec.multival_attr2_datatype
    ,       p_LIMIT_BALANCES_rec.organization_attr_context
    ,       p_LIMIT_BALANCES_rec.organization_attribute
    ,       p_LIMIT_BALANCES_rec.organization_attr_value
    );

l_check_active_flag:=nvl(fnd_profile.value('QP_BUILD_ATTRIBUTES_MAPPING_OPTIONS'),'N');
IF (l_check_active_flag='N') OR (l_check_active_flag='Y' AND l_active_flag='Y') THEN
IF(p_LIMIT_BALANCES_rec.multival_attr1_context IS NOT NULL)
AND (p_LIMIT_BALANCES_rec.multival_attribute1 IS NOT NULL) THEN
UPDATE qp_pte_segments SET used_in_setup='Y'
WHERE nvl(used_in_setup,'N')='N'
AND segment_id IN
(SELECT a.segment_id
 FROM   qp_segments_b a,qp_prc_contexts_b b
 WHERE  a.segment_mapping_column=p_LIMIT_BALANCES_rec.multival_attribute1
 AND    a.prc_context_id=b.prc_context_id
 AND b.prc_context_type = p_LIMIT_BALANCES_rec.multival_attr1_type
 AND    b.prc_context_code=p_LIMIT_BALANCES_rec.multival_attr1_context);
END IF;

IF(p_LIMIT_BALANCES_rec.multival_attr2_context IS NOT NULL) AND
  (p_LIMIT_BALANCES_rec.multival_attribute2 IS NOT NULL) THEN
UPDATE qp_pte_segments SET used_in_setup='Y'
WHERE nvl(used_in_setup,'N')='N'
AND segment_id IN
(SELECT a.segment_id
 FROM   qp_segments_b a,qp_prc_contexts_b b
 WHERE  a.segment_mapping_column=p_LIMIT_BALANCES_rec.multival_attribute2
 AND    a.prc_context_id=b.prc_context_id
 AND b.prc_context_type = p_LIMIT_BALANCES_rec.multival_attr2_type
 AND    b.prc_context_code=p_LIMIT_BALANCES_rec.multival_attr2_context);
END IF;
END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_limit_balance_id              IN  NUMBER
)
IS
BEGIN

    DELETE  FROM QP_LIMIT_BALANCES
    WHERE   LIMIT_BALANCE_ID = p_limit_balance_id
    ;



EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Row;

--  Function Query_Row

FUNCTION Query_Row
(   p_limit_balance_id              IN  NUMBER
) RETURN QP_Limits_PUB.Limit_Balances_Rec_Type
IS
BEGIN

    RETURN Query_Rows
        (   p_limit_balance_id            => p_limit_balance_id
        )(1);

END Query_Row;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_limit_balance_id              IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_limit_id                      IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN QP_Limits_PUB.Limit_Balances_Tbl_Type
IS
l_LIMIT_BALANCES_rec          QP_Limits_PUB.Limit_Balances_Rec_Type;
l_LIMIT_BALANCES_tbl          QP_Limits_PUB.Limit_Balances_Tbl_Type;

CURSOR l_LIMIT_BALANCES_csr IS
    SELECT  ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       AVAILABLE_AMOUNT
    ,       CONSUMED_AMOUNT
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIMIT_BALANCE_ID
    ,       LIMIT_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       RESERVED_AMOUNT
    ,       MULTIVAL_ATTR1_TYPE
    ,       MULTIVAL_ATTR1_CONTEXT
    ,       MULTIVAL_ATTRIBUTE1
    ,       MULTIVAL_ATTR1_VALUE
    ,       MULTIVAL_ATTR1_DATATYPE
    ,       MULTIVAL_ATTR2_TYPE
    ,       MULTIVAL_ATTR2_CONTEXT
    ,       MULTIVAL_ATTRIBUTE2
    ,       MULTIVAL_ATTR2_VALUE
    ,       MULTIVAL_ATTR2_DATATYPE
    ,       ORGANIZATION_ATTR_CONTEXT
    ,       ORGANIZATION_ATTRIBUTE
    ,       ORGANIZATION_ATTR_VALUE
    FROM    QP_LIMIT_BALANCES
    WHERE ( LIMIT_BALANCE_ID = p_limit_balance_id
    )
    OR (    LIMIT_ID = p_limit_id
    );

BEGIN

    IF
    (p_limit_balance_id IS NOT NULL
     AND
     p_limit_balance_id <> FND_API.G_MISS_NUM)
    AND
    (p_limit_id IS NOT NULL
     AND
     p_limit_id <> FND_API.G_MISS_NUM)
    THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: limit_balance_id = '|| p_limit_balance_id || ', limit_id = '|| p_limit_id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    --  Loop over fetched records

    FOR l_implicit_rec IN l_LIMIT_BALANCES_csr LOOP

        l_LIMIT_BALANCES_rec.attribute1 := l_implicit_rec.ATTRIBUTE1;
        l_LIMIT_BALANCES_rec.attribute10 := l_implicit_rec.ATTRIBUTE10;
        l_LIMIT_BALANCES_rec.attribute11 := l_implicit_rec.ATTRIBUTE11;
        l_LIMIT_BALANCES_rec.attribute12 := l_implicit_rec.ATTRIBUTE12;
        l_LIMIT_BALANCES_rec.attribute13 := l_implicit_rec.ATTRIBUTE13;
        l_LIMIT_BALANCES_rec.attribute14 := l_implicit_rec.ATTRIBUTE14;
        l_LIMIT_BALANCES_rec.attribute15 := l_implicit_rec.ATTRIBUTE15;
        l_LIMIT_BALANCES_rec.attribute2 := l_implicit_rec.ATTRIBUTE2;
        l_LIMIT_BALANCES_rec.attribute3 := l_implicit_rec.ATTRIBUTE3;
        l_LIMIT_BALANCES_rec.attribute4 := l_implicit_rec.ATTRIBUTE4;
        l_LIMIT_BALANCES_rec.attribute5 := l_implicit_rec.ATTRIBUTE5;
        l_LIMIT_BALANCES_rec.attribute6 := l_implicit_rec.ATTRIBUTE6;
        l_LIMIT_BALANCES_rec.attribute7 := l_implicit_rec.ATTRIBUTE7;
        l_LIMIT_BALANCES_rec.attribute8 := l_implicit_rec.ATTRIBUTE8;
        l_LIMIT_BALANCES_rec.attribute9 := l_implicit_rec.ATTRIBUTE9;
        l_LIMIT_BALANCES_rec.available_amount := l_implicit_rec.AVAILABLE_AMOUNT;
        l_LIMIT_BALANCES_rec.consumed_amount := l_implicit_rec.CONSUMED_AMOUNT;
        l_LIMIT_BALANCES_rec.context   := l_implicit_rec.CONTEXT;
        l_LIMIT_BALANCES_rec.created_by := l_implicit_rec.CREATED_BY;
        l_LIMIT_BALANCES_rec.creation_date := l_implicit_rec.CREATION_DATE;
        l_LIMIT_BALANCES_rec.last_updated_by := l_implicit_rec.LAST_UPDATED_BY;
        l_LIMIT_BALANCES_rec.last_update_date := l_implicit_rec.LAST_UPDATE_DATE;
        l_LIMIT_BALANCES_rec.last_update_login := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_LIMIT_BALANCES_rec.limit_balance_id := l_implicit_rec.LIMIT_BALANCE_ID;
        l_LIMIT_BALANCES_rec.limit_id  := l_implicit_rec.LIMIT_ID;
        l_LIMIT_BALANCES_rec.program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_LIMIT_BALANCES_rec.program_id := l_implicit_rec.PROGRAM_ID;
        l_LIMIT_BALANCES_rec.program_update_date := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_LIMIT_BALANCES_rec.request_id := l_implicit_rec.REQUEST_ID;
        l_LIMIT_BALANCES_rec.reserved_amount := l_implicit_rec.RESERVED_AMOUNT;
        l_LIMIT_BALANCES_rec.multival_attr1_type := l_implicit_rec.MULTIVAL_ATTR1_TYPE;
        l_LIMIT_BALANCES_rec.multival_attr1_context := l_implicit_rec.MULTIVAL_ATTR1_CONTEXT;
        l_LIMIT_BALANCES_rec.multival_attribute1 := l_implicit_rec.MULTIVAL_ATTRIBUTE1;
        l_LIMIT_BALANCES_rec.multival_attr1_value := l_implicit_rec.MULTIVAL_ATTR1_VALUE;
        l_LIMIT_BALANCES_rec.multival_attr1_datatype := l_implicit_rec.MULTIVAL_ATTR1_DATATYPE;
        l_LIMIT_BALANCES_rec.multival_attr2_type := l_implicit_rec.MULTIVAL_ATTR2_TYPE;
        l_LIMIT_BALANCES_rec.multival_attr2_context := l_implicit_rec.MULTIVAL_ATTR2_CONTEXT;
        l_LIMIT_BALANCES_rec.multival_attribute2 := l_implicit_rec.MULTIVAL_ATTRIBUTE2;
        l_LIMIT_BALANCES_rec.multival_attr2_value := l_implicit_rec.MULTIVAL_ATTR2_VALUE;
        l_LIMIT_BALANCES_rec.multival_attr2_datatype := l_implicit_rec.MULTIVAL_ATTR2_DATATYPE;
        l_LIMIT_BALANCES_rec.organization_attr_context := l_implicit_rec.ORGANIZATION_ATTR_CONTEXT;
        l_LIMIT_BALANCES_rec.organization_attribute := l_implicit_rec.ORGANIZATION_ATTRIBUTE;
        l_LIMIT_BALANCES_rec.organization_attr_value := l_implicit_rec.ORGANIZATION_ATTR_VALUE;

        l_LIMIT_BALANCES_tbl(l_LIMIT_BALANCES_tbl.COUNT + 1) := l_LIMIT_BALANCES_rec;

    END LOOP;


    --  PK sent and no rows found

    IF
    (p_limit_balance_id IS NOT NULL
     AND
     p_limit_balance_id <> FND_API.G_MISS_NUM)
    AND
    (l_LIMIT_BALANCES_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table

    RETURN l_LIMIT_BALANCES_tbl;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Rows'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Rows;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMIT_BALANCES_rec            IN  QP_Limits_PUB.Limit_Balances_Rec_Type
,   x_LIMIT_BALANCES_rec            OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Balances_Rec_Type
)
IS
l_LIMIT_BALANCES_rec          QP_Limits_PUB.Limit_Balances_Rec_Type;
BEGIN

    SELECT  ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       AVAILABLE_AMOUNT
    ,       CONSUMED_AMOUNT
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIMIT_BALANCE_ID
    ,       LIMIT_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       RESERVED_AMOUNT
    ,       MULTIVAL_ATTR1_TYPE
    ,       MULTIVAL_ATTR1_CONTEXT
    ,       MULTIVAL_ATTRIBUTE1
    ,       MULTIVAL_ATTR1_VALUE
    ,       MULTIVAL_ATTR1_DATATYPE
    ,       MULTIVAL_ATTR2_TYPE
    ,       MULTIVAL_ATTR2_CONTEXT
    ,       MULTIVAL_ATTRIBUTE2
    ,       MULTIVAL_ATTR2_VALUE
    ,       MULTIVAL_ATTR2_DATATYPE
    ,       ORGANIZATION_ATTR_CONTEXT
    ,       ORGANIZATION_ATTRIBUTE
    ,       ORGANIZATION_ATTR_VALUE
    INTO    l_LIMIT_BALANCES_rec.attribute1
    ,       l_LIMIT_BALANCES_rec.attribute10
    ,       l_LIMIT_BALANCES_rec.attribute11
    ,       l_LIMIT_BALANCES_rec.attribute12
    ,       l_LIMIT_BALANCES_rec.attribute13
    ,       l_LIMIT_BALANCES_rec.attribute14
    ,       l_LIMIT_BALANCES_rec.attribute15
    ,       l_LIMIT_BALANCES_rec.attribute2
    ,       l_LIMIT_BALANCES_rec.attribute3
    ,       l_LIMIT_BALANCES_rec.attribute4
    ,       l_LIMIT_BALANCES_rec.attribute5
    ,       l_LIMIT_BALANCES_rec.attribute6
    ,       l_LIMIT_BALANCES_rec.attribute7
    ,       l_LIMIT_BALANCES_rec.attribute8
    ,       l_LIMIT_BALANCES_rec.attribute9
    ,       l_LIMIT_BALANCES_rec.available_amount
    ,       l_LIMIT_BALANCES_rec.consumed_amount
    ,       l_LIMIT_BALANCES_rec.context
    ,       l_LIMIT_BALANCES_rec.created_by
    ,       l_LIMIT_BALANCES_rec.creation_date
    ,       l_LIMIT_BALANCES_rec.last_updated_by
    ,       l_LIMIT_BALANCES_rec.last_update_date
    ,       l_LIMIT_BALANCES_rec.last_update_login
    ,       l_LIMIT_BALANCES_rec.limit_balance_id
    ,       l_LIMIT_BALANCES_rec.limit_id
    ,       l_LIMIT_BALANCES_rec.program_application_id
    ,       l_LIMIT_BALANCES_rec.program_id
    ,       l_LIMIT_BALANCES_rec.program_update_date
    ,       l_LIMIT_BALANCES_rec.request_id
    ,       l_LIMIT_BALANCES_rec.reserved_amount
    ,       l_LIMIT_BALANCES_rec.multival_attr1_type
    ,       l_LIMIT_BALANCES_rec.multival_attr1_context
    ,       l_LIMIT_BALANCES_rec.multival_attribute1
    ,       l_LIMIT_BALANCES_rec.multival_attr1_value
    ,       l_LIMIT_BALANCES_rec.multival_attr1_datatype
    ,       l_LIMIT_BALANCES_rec.multival_attr2_type
    ,       l_LIMIT_BALANCES_rec.multival_attr2_context
    ,       l_LIMIT_BALANCES_rec.multival_attribute2
    ,       l_LIMIT_BALANCES_rec.multival_attr2_value
    ,       l_LIMIT_BALANCES_rec.multival_attr2_datatype
    ,       l_LIMIT_BALANCES_rec.organization_attr_context
    ,       l_LIMIT_BALANCES_rec.organization_attribute
    ,       l_LIMIT_BALANCES_rec.organization_attr_value
    FROM    QP_LIMIT_BALANCES
    WHERE   LIMIT_BALANCE_ID = p_LIMIT_BALANCES_rec.limit_balance_id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute1,
                         l_LIMIT_BALANCES_rec.attribute1)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute10,
                         l_LIMIT_BALANCES_rec.attribute10)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute11,
                         l_LIMIT_BALANCES_rec.attribute11)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute12,
                         l_LIMIT_BALANCES_rec.attribute12)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute13,
                         l_LIMIT_BALANCES_rec.attribute13)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute14,
                         l_LIMIT_BALANCES_rec.attribute14)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute15,
                         l_LIMIT_BALANCES_rec.attribute15)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute2,
                         l_LIMIT_BALANCES_rec.attribute2)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute3,
                         l_LIMIT_BALANCES_rec.attribute3)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute4,
                         l_LIMIT_BALANCES_rec.attribute4)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute5,
                         l_LIMIT_BALANCES_rec.attribute5)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute6,
                         l_LIMIT_BALANCES_rec.attribute6)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute7,
                         l_LIMIT_BALANCES_rec.attribute7)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute8,
                         l_LIMIT_BALANCES_rec.attribute8)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.attribute9,
                         l_LIMIT_BALANCES_rec.attribute9)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.available_amount,
                         l_LIMIT_BALANCES_rec.available_amount)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.consumed_amount,
                         l_LIMIT_BALANCES_rec.consumed_amount)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.context,
                         l_LIMIT_BALANCES_rec.context)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.created_by,
                         l_LIMIT_BALANCES_rec.created_by)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.creation_date,
                         l_LIMIT_BALANCES_rec.creation_date)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.last_updated_by,
                         l_LIMIT_BALANCES_rec.last_updated_by)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.last_update_date,
                         l_LIMIT_BALANCES_rec.last_update_date)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.last_update_login,
                         l_LIMIT_BALANCES_rec.last_update_login)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.limit_balance_id,
                         l_LIMIT_BALANCES_rec.limit_balance_id)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.limit_id,
                         l_LIMIT_BALANCES_rec.limit_id)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.program_application_id,
                         l_LIMIT_BALANCES_rec.program_application_id)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.program_id,
                         l_LIMIT_BALANCES_rec.program_id)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.program_update_date,
                         l_LIMIT_BALANCES_rec.program_update_date)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.request_id,
                         l_LIMIT_BALANCES_rec.request_id)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.reserved_amount,
                         l_LIMIT_BALANCES_rec.reserved_amount)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attr1_type,
                         l_LIMIT_BALANCES_rec.multival_attr1_type)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attr1_context,
                         l_LIMIT_BALANCES_rec.multival_attr1_context)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attribute1,
                         l_LIMIT_BALANCES_rec.multival_attribute1)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attr1_value,
                         l_LIMIT_BALANCES_rec.multival_attr1_value)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attr1_datatype,
                         l_LIMIT_BALANCES_rec.multival_attr1_datatype)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attr2_type,
                         l_LIMIT_BALANCES_rec.multival_attr2_type)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attr2_context,
                         l_LIMIT_BALANCES_rec.multival_attr2_context)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attribute2,
                         l_LIMIT_BALANCES_rec.multival_attribute2)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attr2_value,
                         l_LIMIT_BALANCES_rec.multival_attr2_value)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.multival_attr2_datatype,
                         l_LIMIT_BALANCES_rec.multival_attr2_datatype)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.organization_attr_context,
                         l_LIMIT_BALANCES_rec.organization_attr_context)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.organization_attribute,
                         l_LIMIT_BALANCES_rec.organization_attribute)
    AND QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.organization_attr_value,
                         l_LIMIT_BALANCES_rec.organization_attr_value)
    THEN

        --  Row has not changed. Set out parameter.

        x_LIMIT_BALANCES_rec           := l_LIMIT_BALANCES_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_LIMIT_BALANCES_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_LIMIT_BALANCES_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_CHANGED');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_LIMIT_BALANCES_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_DELETED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_LIMIT_BALANCES_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_LIMIT_BALANCES_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

END Lock_Row;

--  Function Get_Values

FUNCTION Get_Values
(   p_LIMIT_BALANCES_rec            IN  QP_Limits_PUB.Limit_Balances_Rec_Type
,   p_old_LIMIT_BALANCES_rec        IN  QP_Limits_PUB.Limit_Balances_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_BALANCES_REC
) RETURN QP_Limits_PUB.Limit_Balances_Val_Rec_Type
IS
l_LIMIT_BALANCES_val_rec      QP_Limits_PUB.Limit_Balances_Val_Rec_Type;
BEGIN

    IF p_LIMIT_BALANCES_rec.limit_balance_id IS NOT NULL AND
        p_LIMIT_BALANCES_rec.limit_balance_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.limit_balance_id,
        p_old_LIMIT_BALANCES_rec.limit_balance_id)
    THEN
        l_LIMIT_BALANCES_val_rec.limit_balance := QP_Id_To_Value.Limit_Balance
        (   p_limit_balance_id            => p_LIMIT_BALANCES_rec.limit_balance_id
        );
    END IF;

    IF p_LIMIT_BALANCES_rec.limit_id IS NOT NULL AND
        p_LIMIT_BALANCES_rec.limit_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_LIMIT_BALANCES_rec.limit_id,
        p_old_LIMIT_BALANCES_rec.limit_id)
    THEN
        l_LIMIT_BALANCES_val_rec.limit := QP_Id_To_Value.Limit
        (   p_limit_id                    => p_LIMIT_BALANCES_rec.limit_id
        );
    END IF;

    RETURN l_LIMIT_BALANCES_val_rec;

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_LIMIT_BALANCES_rec            IN  QP_Limits_PUB.Limit_Balances_Rec_Type
,   p_LIMIT_BALANCES_val_rec        IN  QP_Limits_PUB.Limit_Balances_Val_Rec_Type
) RETURN QP_Limits_PUB.Limit_Balances_Rec_Type
IS
l_LIMIT_BALANCES_rec          QP_Limits_PUB.Limit_Balances_Rec_Type;
BEGIN

    --  initialize  return_status.

    l_LIMIT_BALANCES_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_LIMIT_BALANCES_rec.

    l_LIMIT_BALANCES_rec := p_LIMIT_BALANCES_rec;

    IF  p_LIMIT_BALANCES_val_rec.limit_balance <> FND_API.G_MISS_CHAR
    THEN

        IF p_LIMIT_BALANCES_rec.limit_balance_id <> FND_API.G_MISS_NUM THEN

            l_LIMIT_BALANCES_rec.limit_balance_id := p_LIMIT_BALANCES_rec.limit_balance_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit_balance');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_LIMIT_BALANCES_rec.limit_balance_id := QP_Value_To_Id.limit_balance
            (   p_limit_balance               => p_LIMIT_BALANCES_val_rec.limit_balance
            );

            IF l_LIMIT_BALANCES_rec.limit_balance_id = FND_API.G_MISS_NUM THEN
                l_LIMIT_BALANCES_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_LIMIT_BALANCES_val_rec.limit <> FND_API.G_MISS_CHAR
    THEN

        IF p_LIMIT_BALANCES_rec.limit_id <> FND_API.G_MISS_NUM THEN

            l_LIMIT_BALANCES_rec.limit_id := p_LIMIT_BALANCES_rec.limit_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_LIMIT_BALANCES_rec.limit_id := QP_Value_To_Id.limit
            (   p_limit                       => p_LIMIT_BALANCES_val_rec.limit
            );

            IF l_LIMIT_BALANCES_rec.limit_id = FND_API.G_MISS_NUM THEN
                l_LIMIT_BALANCES_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    RETURN l_LIMIT_BALANCES_rec;

END Get_Ids;

END QP_Limit_Balances_Util;

/
