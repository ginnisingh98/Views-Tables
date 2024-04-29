--------------------------------------------------------
--  DDL for Package Body QP_QUALIFIERS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_QUALIFIERS_UTIL" AS
/* $Header: QPXUQPQB.pls 120.9.12010000.7 2009/08/19 07:33:31 smbalara ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Qualifiers_Util';

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
,   p_old_QUALIFIERS_rec            IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_REC
,   x_QUALIFIERS_rec                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
)
IS
l_index                       NUMBER := 0;
l_src_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
BEGIN

    --  Load out record

    x_QUALIFIERS_rec := p_QUALIFIERS_rec;

   -- Following if statement is added by svdeshmu
   -- If operator is updated from 'between' to '=' then qualifier_attr_value_to_code(ui field)
   -- gets set to null.However qualifier_attr_value_to (database field) remains unclear.
   --Hence if you query the record after this change, even though the operator is '='
   -- 'value to 'is shown on the UI.(which is incorrect)
   --Hence following statement is added to clear the qualifier_attr_value_to (database field)
   --whenever operator is other than 'between'.

    if p_old_QUALIFIERS_rec.comparison_operator_code = 'BETWEEN' AND
     p_QUALIFIERS_rec.comparison_operator_code <> 'BETWEEN' then

	  x_QUALIFIERS_rec.qualifier_attr_value_to := null;
     end if;



    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.


    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute1,p_old_QUALIFIERS_rec.attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute10,p_old_QUALIFIERS_rec.attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute11,p_old_QUALIFIERS_rec.attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute12,p_old_QUALIFIERS_rec.attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute13,p_old_QUALIFIERS_rec.attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute14,p_old_QUALIFIERS_rec.attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute15,p_old_QUALIFIERS_rec.attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute2,p_old_QUALIFIERS_rec.attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute3,p_old_QUALIFIERS_rec.attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute4,p_old_QUALIFIERS_rec.attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute5,p_old_QUALIFIERS_rec.attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute6,p_old_QUALIFIERS_rec.attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute7,p_old_QUALIFIERS_rec.attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute8,p_old_QUALIFIERS_rec.attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute9,p_old_QUALIFIERS_rec.attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.comparison_operator_code,p_old_QUALIFIERS_rec.comparison_operator_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_COMPARISON_OPERATOR;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.context,p_old_QUALIFIERS_rec.context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.created_by,p_old_QUALIFIERS_rec.created_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_CREATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.created_from_rule_id,p_old_QUALIFIERS_rec.created_from_rule_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_CREATED_FROM_RULE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.creation_date,p_old_QUALIFIERS_rec.creation_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.end_date_active,p_old_QUALIFIERS_rec.end_date_active)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_END_DATE_ACTIVE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.excluder_flag,p_old_QUALIFIERS_rec.excluder_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_EXCLUDER;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.last_updated_by,p_old_QUALIFIERS_rec.last_updated_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.last_update_date,p_old_QUALIFIERS_rec.last_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.last_update_login,p_old_QUALIFIERS_rec.last_update_login)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.list_header_id,p_old_QUALIFIERS_rec.list_header_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_LIST_HEADER;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.list_line_id,p_old_QUALIFIERS_rec.list_line_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_LIST_LINE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.program_application_id,p_old_QUALIFIERS_rec.program_application_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_PROGRAM_APPLICATION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.program_id,p_old_QUALIFIERS_rec.program_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_PROGRAM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.program_update_date,p_old_QUALIFIERS_rec.program_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_PROGRAM_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_attribute,p_old_QUALIFIERS_rec.qualifier_attribute)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_ATTRIBUTE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_attr_value,p_old_QUALIFIERS_rec.qualifier_attr_value)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_ATTR_VALUE;
        END IF;


        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_attr_value_to,p_old_QUALIFIERS_rec.qualifier_attr_value_to)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_ATTR_VALUE_TO;
        END IF;





        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_context,p_old_QUALIFIERS_rec.qualifier_context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_datatype,p_old_QUALIFIERS_rec.qualifier_datatype)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_DATATYPE;
        END IF;

    /*    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_date_format,p_old_QUALIFIERS_rec.qualifier_date_format)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_DATE_FORMAT;
        END IF;*/

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_grouping_no,p_old_QUALIFIERS_rec.qualifier_grouping_no)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_GROUPING_NO;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_id,p_old_QUALIFIERS_rec.qualifier_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER;
        END IF;

       /* IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_number_format,p_old_QUALIFIERS_rec.qualifier_number_format)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_NUMBER_FORMAT;
        END IF;*/

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_precedence,p_old_QUALIFIERS_rec.qualifier_precedence)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_PRECEDENCE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_rule_id,p_old_QUALIFIERS_rec.qualifier_rule_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_RULE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.request_id,p_old_QUALIFIERS_rec.request_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_REQUEST;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.start_date_active,p_old_QUALIFIERS_rec.start_date_active)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_START_DATE_ACTIVE;
        END IF;
-- Added for TCA
        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualify_hier_descendent_flag,p_old_QUALIFIERS_rec.qualify_hier_descendent_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFY_HIER_DESCENDENT_FLAG;
        END IF;

    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_COMPARISON_OPERATOR THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_COMPARISON_OPERATOR;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_CONTEXT;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATED_FROM_RULE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_CREATED_FROM_RULE;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_CREATION_DATE;
    ELSIF p_attr_id = G_END_DATE_ACTIVE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_END_DATE_ACTIVE;
    ELSIF p_attr_id = G_EXCLUDER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_EXCLUDER;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_LIST_HEADER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_LIST_HEADER;
    ELSIF p_attr_id = G_LIST_LINE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_LIST_LINE;
    ELSIF p_attr_id = G_PROGRAM_APPLICATION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_PROGRAM_APPLICATION;
    ELSIF p_attr_id = G_PROGRAM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_PROGRAM;
    ELSIF p_attr_id = G_PROGRAM_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_PROGRAM_UPDATE_DATE;
    ELSIF p_attr_id = G_QUALIFIER_ATTRIBUTE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_ATTRIBUTE;
    ELSIF p_attr_id = G_QUALIFIER_ATTR_VALUE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_ATTR_VALUE;
    ELSIF p_attr_id = G_QUALIFIER_ATTR_VALUE_TO THEN
        l_index := l_index + 1;
       l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_ATTR_VALUE_TO;
    ELSIF p_attr_id = G_QUALIFIER_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_CONTEXT;
    ELSIF p_attr_id = G_QUALIFIER_DATATYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_DATATYPE;
    --ELSIF p_attr_id = G_QUALIFIER_DATE_FORMAT THEN
     --   l_index := l_index + 1;
     --   l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_DATE_FORMAT;
    ELSIF p_attr_id = G_QUALIFIER_GROUPING_NO THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_GROUPING_NO;
    ELSIF p_attr_id = G_QUALIFIER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER;
    --ELSIF p_attr_id = G_QUALIFIER_NUMBER_FORMAT THEN
    --    l_index := l_index + 1;
    --    l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_NUMBER_FORMAT;
    ELSIF p_attr_id = G_QUALIFIER_PRECEDENCE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_PRECEDENCE;
    ELSIF p_attr_id = G_QUALIFIER_RULE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_RULE;
    ELSIF p_attr_id = G_REQUEST THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_REQUEST;
    ELSIF p_attr_id = G_START_DATE_ACTIVE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_START_DATE_ACTIVE;
-- Added for TCA
    ELSIF p_attr_id = G_QUALIFY_HIER_DESCENDENT_FLAG THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFY_HIER_DESCENDENT_FLAG;
    END IF;

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
,   p_old_QUALIFIERS_rec            IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_REC
,   x_QUALIFIERS_rec                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
)
IS
l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN


      oe_debug_pub.add('in apply attribute changes');


    --  Load out record

    x_QUALIFIERS_rec := p_QUALIFIERS_rec;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute1,p_old_QUALIFIERS_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute10,p_old_QUALIFIERS_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute11,p_old_QUALIFIERS_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute12,p_old_QUALIFIERS_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute13,p_old_QUALIFIERS_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute14,p_old_QUALIFIERS_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute15,p_old_QUALIFIERS_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute2,p_old_QUALIFIERS_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute3,p_old_QUALIFIERS_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute4,p_old_QUALIFIERS_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute5,p_old_QUALIFIERS_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute6,p_old_QUALIFIERS_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute7,p_old_QUALIFIERS_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute8,p_old_QUALIFIERS_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute9,p_old_QUALIFIERS_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.comparison_operator_code,p_old_QUALIFIERS_rec.comparison_operator_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.context,p_old_QUALIFIERS_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.created_by,p_old_QUALIFIERS_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.created_from_rule_id,p_old_QUALIFIERS_rec.created_from_rule_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.creation_date,p_old_QUALIFIERS_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.end_date_active,p_old_QUALIFIERS_rec.end_date_active)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.excluder_flag,p_old_QUALIFIERS_rec.excluder_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.last_updated_by,p_old_QUALIFIERS_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.last_update_date,p_old_QUALIFIERS_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.last_update_login,p_old_QUALIFIERS_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.list_header_id,p_old_QUALIFIERS_rec.list_header_id)
    THEN
	   NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.list_line_id,p_old_QUALIFIERS_rec.list_line_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.program_application_id,p_old_QUALIFIERS_rec.program_application_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.program_id,p_old_QUALIFIERS_rec.program_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.program_update_date,p_old_QUALIFIERS_rec.program_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_attribute,p_old_QUALIFIERS_rec.qualifier_attribute)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_attr_value,p_old_QUALIFIERS_rec.qualifier_attr_value)
    THEN
        NULL;
    END IF;
    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_attr_value_to,p_old_QUALIFIERS_rec.qualifier_attr_value_to)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_context,p_old_QUALIFIERS_rec.qualifier_context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_datatype,p_old_QUALIFIERS_rec.qualifier_datatype)
    THEN
        NULL;
    END IF;

    /*IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_date_format,p_old_QUALIFIERS_rec.qualifier_date_format)
    THEN
        NULL;
    END IF;*/

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_grouping_no,p_old_QUALIFIERS_rec.qualifier_grouping_no)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_id,p_old_QUALIFIERS_rec.qualifier_id)
    THEN
        NULL;
    END IF;

   /* IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_number_format,p_old_QUALIFIERS_rec.qualifier_number_format)
    THEN
        NULL;
    END IF;*/

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_precedence,p_old_QUALIFIERS_rec.qualifier_precedence)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_rule_id,p_old_QUALIFIERS_rec.qualifier_rule_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.request_id,p_old_QUALIFIERS_rec.request_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.start_date_active,p_old_QUALIFIERS_rec.start_date_active)
    THEN
        NULL;
    END IF;
-- Added for TCA
    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualify_hier_descendent_flag,p_old_QUALIFIERS_rec.qualify_hier_descendent_flag)
    THEN
        NULL;
    END IF;
      oe_debug_pub.add(' leaving  apply attribute changes');

END Apply_Attribute_Changes;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
,   p_old_QUALIFIERS_rec            IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
) RETURN QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
IS
l_QUALIFIERS_rec              QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type := p_QUALIFIERS_rec;
BEGIN

    IF l_QUALIFIERS_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute1 := p_old_QUALIFIERS_rec.attribute1;
    END IF;

    IF l_QUALIFIERS_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute10 := p_old_QUALIFIERS_rec.attribute10;
    END IF;

    IF l_QUALIFIERS_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute11 := p_old_QUALIFIERS_rec.attribute11;
    END IF;

    IF l_QUALIFIERS_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute12 := p_old_QUALIFIERS_rec.attribute12;
    END IF;

    IF l_QUALIFIERS_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute13 := p_old_QUALIFIERS_rec.attribute13;
    END IF;

    IF l_QUALIFIERS_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute14 := p_old_QUALIFIERS_rec.attribute14;
    END IF;

    IF l_QUALIFIERS_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute15 := p_old_QUALIFIERS_rec.attribute15;
    END IF;

    IF l_QUALIFIERS_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute2 := p_old_QUALIFIERS_rec.attribute2;
    END IF;

    IF l_QUALIFIERS_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute3 := p_old_QUALIFIERS_rec.attribute3;
    END IF;

    IF l_QUALIFIERS_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute4 := p_old_QUALIFIERS_rec.attribute4;
    END IF;

    IF l_QUALIFIERS_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute5 := p_old_QUALIFIERS_rec.attribute5;
    END IF;

    IF l_QUALIFIERS_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute6 := p_old_QUALIFIERS_rec.attribute6;
    END IF;

    IF l_QUALIFIERS_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute7 := p_old_QUALIFIERS_rec.attribute7;
    END IF;

    IF l_QUALIFIERS_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute8 := p_old_QUALIFIERS_rec.attribute8;
    END IF;

    IF l_QUALIFIERS_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute9 := p_old_QUALIFIERS_rec.attribute9;
    END IF;

    IF l_QUALIFIERS_rec.comparison_operator_code = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.comparison_operator_code := p_old_QUALIFIERS_rec.comparison_operator_code;
    END IF;

    IF l_QUALIFIERS_rec.context = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.context := p_old_QUALIFIERS_rec.context;
    END IF;

    IF l_QUALIFIERS_rec.created_by = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.created_by := p_old_QUALIFIERS_rec.created_by;
    END IF;

    IF l_QUALIFIERS_rec.created_from_rule_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.created_from_rule_id := p_old_QUALIFIERS_rec.created_from_rule_id;
    END IF;

    IF l_QUALIFIERS_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_QUALIFIERS_rec.creation_date := p_old_QUALIFIERS_rec.creation_date;
    END IF;

    IF l_QUALIFIERS_rec.end_date_active = FND_API.G_MISS_DATE THEN
        l_QUALIFIERS_rec.end_date_active := p_old_QUALIFIERS_rec.end_date_active;
    END IF;

    IF l_QUALIFIERS_rec.excluder_flag = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.excluder_flag := p_old_QUALIFIERS_rec.excluder_flag;
    END IF;

    IF l_QUALIFIERS_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.last_updated_by := p_old_QUALIFIERS_rec.last_updated_by;
    END IF;

    IF l_QUALIFIERS_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_QUALIFIERS_rec.last_update_date := p_old_QUALIFIERS_rec.last_update_date;
    END IF;

    IF l_QUALIFIERS_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.last_update_login := p_old_QUALIFIERS_rec.last_update_login;
    END IF;

    IF l_QUALIFIERS_rec.list_header_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.list_header_id := p_old_QUALIFIERS_rec.list_header_id;
    END IF;

    IF l_QUALIFIERS_rec.list_line_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.list_line_id := p_old_QUALIFIERS_rec.list_line_id;
    END IF;

    IF l_QUALIFIERS_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.program_application_id := p_old_QUALIFIERS_rec.program_application_id;
    END IF;

    IF l_QUALIFIERS_rec.program_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.program_id := p_old_QUALIFIERS_rec.program_id;
    END IF;

    IF l_QUALIFIERS_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_QUALIFIERS_rec.program_update_date := p_old_QUALIFIERS_rec.program_update_date;
    END IF;

    IF l_QUALIFIERS_rec.qualifier_attribute = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.qualifier_attribute := p_old_QUALIFIERS_rec.qualifier_attribute;
    END IF;

    IF l_QUALIFIERS_rec.qualifier_attr_value = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.qualifier_attr_value := p_old_QUALIFIERS_rec.qualifier_attr_value;
    END IF;
   IF l_QUALIFIERS_rec.qualifier_attr_value_to = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.qualifier_attr_value_to := p_old_QUALIFIERS_rec.qualifier_attr_value_to;
    END IF;

    IF l_QUALIFIERS_rec.qualifier_context = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.qualifier_context := p_old_QUALIFIERS_rec.qualifier_context;
    END IF;

    IF l_QUALIFIERS_rec.qualifier_datatype = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.qualifier_datatype := p_old_QUALIFIERS_rec.qualifier_datatype;
    END IF;

    /*IF l_QUALIFIERS_rec.qualifier_date_format = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.qualifier_date_format := p_old_QUALIFIERS_rec.qualifier_date_format;
    END IF;*/

    IF l_QUALIFIERS_rec.qualifier_grouping_no = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.qualifier_grouping_no := p_old_QUALIFIERS_rec.qualifier_grouping_no;
    END IF;

    IF l_QUALIFIERS_rec.qualifier_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.qualifier_id := p_old_QUALIFIERS_rec.qualifier_id;
    END IF;

    /*IF l_QUALIFIERS_rec.qualifier_number_format = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.qualifier_number_format := p_old_QUALIFIERS_rec.qualifier_number_format;
    END IF;*/

    IF l_QUALIFIERS_rec.qualifier_precedence = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.qualifier_precedence := p_old_QUALIFIERS_rec.qualifier_precedence;
    END IF;

    IF l_QUALIFIERS_rec.qualifier_rule_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.qualifier_rule_id := p_old_QUALIFIERS_rec.qualifier_rule_id;
    END IF;

    IF l_QUALIFIERS_rec.request_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.request_id := p_old_QUALIFIERS_rec.request_id;
    END IF;

    IF l_QUALIFIERS_rec.start_date_active = FND_API.G_MISS_DATE THEN
        l_QUALIFIERS_rec.start_date_active := p_old_QUALIFIERS_rec.start_date_active;
    END IF;
-- Added for TCA
    IF l_QUALIFIERS_rec.qualify_hier_descendent_flag = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.qualify_hier_descendent_flag := p_old_QUALIFIERS_rec.qualify_hier_descendent_flag;
    END IF;

    RETURN l_QUALIFIERS_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
) RETURN QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
IS
l_QUALIFIERS_rec              QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type := p_QUALIFIERS_rec;
BEGIN

    IF l_QUALIFIERS_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute1 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute10 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute11 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute12 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute13 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute14 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute15 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute2 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute3 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute4 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute5 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute6 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute7 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute8 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute9 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.comparison_operator_code = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.comparison_operator_code := NULL;
    END IF;

    IF l_QUALIFIERS_rec.context = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.context := NULL;
    END IF;

    IF l_QUALIFIERS_rec.created_by = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.created_by := NULL;
    END IF;

    IF l_QUALIFIERS_rec.created_from_rule_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.created_from_rule_id := NULL;
    END IF;

    IF l_QUALIFIERS_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_QUALIFIERS_rec.creation_date := NULL;
    END IF;

    IF l_QUALIFIERS_rec.end_date_active = FND_API.G_MISS_DATE THEN
        l_QUALIFIERS_rec.end_date_active := NULL;
    END IF;

    IF l_QUALIFIERS_rec.excluder_flag = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.excluder_flag := NULL;
    END IF;

    IF l_QUALIFIERS_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.last_updated_by := NULL;
    END IF;

    IF l_QUALIFIERS_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_QUALIFIERS_rec.last_update_date := NULL;
    END IF;

    IF l_QUALIFIERS_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.last_update_login := NULL;
    END IF;

    IF l_QUALIFIERS_rec.list_header_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.list_header_id := NULL;
    END IF;

    IF l_QUALIFIERS_rec.list_line_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.list_line_id := NULL;
    END IF;

    IF l_QUALIFIERS_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.program_application_id := NULL;
    END IF;

    IF l_QUALIFIERS_rec.program_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.program_id := NULL;
    END IF;

    IF l_QUALIFIERS_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_QUALIFIERS_rec.program_update_date := NULL;
    END IF;

    IF l_QUALIFIERS_rec.qualifier_attribute = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.qualifier_attribute := NULL;
    END IF;

    IF l_QUALIFIERS_rec.qualifier_attr_value = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.qualifier_attr_value := NULL;
    END IF;

    IF l_QUALIFIERS_rec.qualifier_attr_value_to = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.qualifier_attr_value_to := NULL;
    END IF;

    IF l_QUALIFIERS_rec.qualifier_context = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.qualifier_context := NULL;
    END IF;

    IF l_QUALIFIERS_rec.qualifier_datatype = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.qualifier_datatype := NULL;
    END IF;

    /*IF l_QUALIFIERS_rec.qualifier_date_format = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.qualifier_date_format := NULL;
    END IF;*/

    IF l_QUALIFIERS_rec.qualifier_grouping_no = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.qualifier_grouping_no := NULL;
    END IF;

    IF l_QUALIFIERS_rec.qualifier_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.qualifier_id := NULL;
    END IF;

    /*IF l_QUALIFIERS_rec.qualifier_number_format = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.qualifier_number_format := NULL;
    END IF;*/

    IF l_QUALIFIERS_rec.qualifier_precedence = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.qualifier_precedence := NULL;
    END IF;

    IF l_QUALIFIERS_rec.qualifier_rule_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.qualifier_rule_id := NULL;
    END IF;

    IF l_QUALIFIERS_rec.request_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.request_id := NULL;
    END IF;

    IF l_QUALIFIERS_rec.start_date_active = FND_API.G_MISS_DATE THEN
        l_QUALIFIERS_rec.start_date_active := NULL;
    END IF;
-- Added for TCA
    IF l_QUALIFIERS_rec.qualify_hier_descendent_flag = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.qualify_hier_descendent_flag := NULL;
    END IF;

    RETURN l_QUALIFIERS_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
)
IS
l_check_active_flag VARCHAR2(1);
l_qual_attr_value_from_number NUMBER := NULL;
l_qual_attr_value_to_number NUMBER := NULL;
l_qual_attr_value_from VARCHAR2(240);
--l_status VARCHAR2(1);
--l_qualifiers_rec   QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
BEGIN

   -- l_qualifiers_rec:=Query_Row(p_QUALIFIERS_rec.qualifier_id);

   BEGIN
    IF p_QUALIFIERS_rec.qualifier_datatype = 'N'
    then
            l_qual_attr_value_from_number :=
            qp_number.canonical_to_number(p_QUALIFIERS_rec.qualifier_attr_value);

            l_qual_attr_value_to_number :=
            qp_number.canonical_to_number(p_QUALIFIERS_rec.qualifier_attr_value_to);

            l_qual_attr_value_from :=
            qp_number.number_to_canonical(l_qual_attr_value_from_number);   --4418053
    ELSE

            l_qual_attr_value_from := p_QUALIFIERS_rec.qualifier_attr_value;  --4418053

    end if;

     EXCEPTION
            WHEN VALUE_ERROR THEN
                  NULL;
            WHEN OTHERS THEN
                  NULL;
     END;

    UPDATE  QP_QUALIFIERS
    SET     ATTRIBUTE1                     = p_QUALIFIERS_rec.attribute1
    ,       ATTRIBUTE10                    = p_QUALIFIERS_rec.attribute10
    ,       ATTRIBUTE11                    = p_QUALIFIERS_rec.attribute11
    ,       ATTRIBUTE12                    = p_QUALIFIERS_rec.attribute12
    ,       ATTRIBUTE13                    = p_QUALIFIERS_rec.attribute13
    ,       ATTRIBUTE14                    = p_QUALIFIERS_rec.attribute14
    ,       ATTRIBUTE15                    = p_QUALIFIERS_rec.attribute15
    ,       ATTRIBUTE2                     = p_QUALIFIERS_rec.attribute2
    ,       ATTRIBUTE3                     = p_QUALIFIERS_rec.attribute3
    ,       ATTRIBUTE4                     = p_QUALIFIERS_rec.attribute4
    ,       ATTRIBUTE5                     = p_QUALIFIERS_rec.attribute5
    ,       ATTRIBUTE6                     = p_QUALIFIERS_rec.attribute6
    ,       ATTRIBUTE7                     = p_QUALIFIERS_rec.attribute7
    ,       ATTRIBUTE8                     = p_QUALIFIERS_rec.attribute8
    ,       ATTRIBUTE9                     = p_QUALIFIERS_rec.attribute9
    ,       COMPARISON_OPERATOR_CODE       = p_QUALIFIERS_rec.comparison_operator_code
    ,       CONTEXT                        = p_QUALIFIERS_rec.context
    ,       CREATED_BY                     = p_QUALIFIERS_rec.created_by
    ,       CREATED_FROM_RULE_ID           = p_QUALIFIERS_rec.created_from_rule_id
    ,       CREATION_DATE                  = p_QUALIFIERS_rec.creation_date
    ,       END_DATE_ACTIVE                = p_QUALIFIERS_rec.end_date_active
    ,       EXCLUDER_FLAG                  = p_QUALIFIERS_rec.excluder_flag
    ,       LAST_UPDATED_BY                = p_QUALIFIERS_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_QUALIFIERS_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_QUALIFIERS_rec.last_update_login
    ,       LIST_HEADER_ID                 = p_QUALIFIERS_rec.list_header_id
    ,       LIST_LINE_ID                   = p_QUALIFIERS_rec.list_line_id
    ,       PROGRAM_APPLICATION_ID         = p_QUALIFIERS_rec.program_application_id
    ,       PROGRAM_ID                     = p_QUALIFIERS_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_QUALIFIERS_rec.program_update_date
    ,       QUALIFIER_ATTRIBUTE            = p_QUALIFIERS_rec.qualifier_attribute
    ,       QUALIFIER_ATTR_VALUE           = l_qual_attr_value_from
    ,       QUALIFIER_ATTR_VALUE_TO        = p_QUALIFIERS_rec.qualifier_attr_value_to
    ,       QUALIFIER_CONTEXT              = p_QUALIFIERS_rec.qualifier_context
    ,       QUALIFIER_DATATYPE             = p_QUALIFIERS_rec.qualifier_datatype
   -- ,       QUALIFIER_DATE_FORMAT          = p_QUALIFIERS_rec.qualifier_date_format
    ,       QUALIFIER_GROUPING_NO          = p_QUALIFIERS_rec.qualifier_grouping_no
    ,       QUALIFIER_ID                   = p_QUALIFIERS_rec.qualifier_id
    --,       QUALIFIER_NUMBER_FORMAT        = p_QUALIFIERS_rec.qualifier_number_format
    ,       QUALIFIER_PRECEDENCE           = p_QUALIFIERS_rec.qualifier_precedence
    ,       QUALIFIER_RULE_ID              = p_QUALIFIERS_rec.qualifier_rule_id
    ,       REQUEST_ID                     = p_QUALIFIERS_rec.request_id
    ,       START_DATE_ACTIVE              = p_QUALIFIERS_rec.start_date_active
    ,       QUAL_ATTR_VALUE_FROM_NUMBER    = l_qual_attr_value_from_number
    ,       QUAL_ATTR_VALUE_TO_NUMBER      = l_qual_attr_value_to_number
    ,       QUALIFY_HIER_DESCENDENTS_FLAG  = p_QUALIFIERS_rec.qualify_hier_descendent_flag -- Added for TCA
    WHERE   QUALIFIER_ID = p_QUALIFIERS_rec.qualifier_id
    ;



l_check_active_flag:=nvl(fnd_profile.value('QP_BUILD_ATTRIBUTES_MAPPING_OPTIONS'),'N');

IF (l_check_active_flag='N') OR (l_check_active_flag='Y' AND p_QUALIFIERS_rec.active_flag='Y') THEN

 IF(p_QUALIFIERS_rec.qualifier_context IS NOT NULL) AND
  (p_QUALIFIERS_rec.qualifier_attribute IS NOT NULL) THEN

  UPDATE qp_pte_segments SET used_in_setup='Y'
  WHERE  nvl(used_in_setup,'N')='N'
  AND segment_id IN
  (SELECT a.segment_id
   FROM   qp_segments_b a,qp_prc_contexts_b b
   WHERE a.segment_mapping_column=p_QUALIFIERS_rec.qualifier_attribute
   AND   a.prc_context_id=b.prc_context_id
   AND   b.prc_context_type='QUALIFIER'
   AND   b.prc_context_code=p_QUALIFIERS_rec.qualifier_context);
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
--  Procedure Update_coupon_Row Added for bug 7316016

PROCEDURE Update_coupon_Row
(   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
)
IS
BEGIN
UPDATE QP_COUPONS
    SET expiration_date=p_QUALIFIERS_rec.end_date_active
	,start_date=p_QUALIFIERS_rec.start_date_active
	,LAST_UPDATED_BY=p_QUALIFIERS_rec.LAST_UPDATED_BY
        ,LAST_UPDATE_DATE=p_QUALIFIERS_rec.LAST_UPDATE_DATE
        ,LAST_UPDATE_LOGIN=p_QUALIFIERS_rec.LAST_UPDATE_LOGIN
    WHERE coupon_id = p_QUALIFIERS_rec.qualifier_attr_value;
EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Coupon_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Update_Coupon_Row;

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
)
IS
l_list_type_code VARCHAR2(30) := '';
l_active_flag VARCHAR2(1) := '';
l_qualifier_grouping_no NUMBER;
l_qual_attr_value_from_number NUMBER := NULL;
l_qual_attr_value_to_number NUMBER := NULL;
l_check_active_flag VARCHAR2(1);
l_qual_attr_value_from VARCHAR2(240);



cursor update_pte_cur(l_qual_context varchar2,l_qual_attribute varchar2) is
   SELECT a.segment_id
   FROM   qp_segments_b a,qp_prc_contexts_b b
   WHERE a.segment_mapping_column=l_qual_attribute
   AND   a.prc_context_id=b.prc_context_id
   AND   b.prc_context_type='QUALIFIER'
   AND   b.prc_context_code=l_qual_context;


BEGIN

    l_qualifier_grouping_no := p_QUALIFIERS_rec.qualifier_grouping_no;

    IF p_QUALIFIERS_rec.qualifier_context = 'MODLIST' AND
	  p_QUALIFIERS_rec.qualifier_attribute = 'QUALIFIER_ATTRIBUTE4' AND
	  p_QUALIFIERS_rec.qualifier_grouping_no <> -1
    THEN
	  BEGIN
          SELECT list_type_code
	     INTO   l_list_type_code
	     FROM   qp_list_headers_vl
	     WHERE  list_header_id = p_QUALIFIERS_rec.list_header_id;
	  EXCEPTION
	    WHEN OTHERS THEN
		  NULL;
	  END;

	  IF l_list_type_code IN ('PRL', 'AGR') THEN
          l_qualifier_grouping_no := -1;
	  END IF;
    END IF;

    BEGIN

	 SELECT ACTIVE_FLAG, LIST_TYPE_CODE
	 INTO   l_active_flag, l_list_type_code
	 FROM   QP_LIST_HEADERS_B
	 WHERE  LIST_HEADER_ID = p_QUALIFIERS_rec.list_header_id;

     EXCEPTION
	    WHEN OTHERS THEN
		  NULL;
     END;


    BEGIN

    IF p_QUALIFIERS_rec.qualifier_datatype = 'N'
    then
            l_qual_attr_value_from_number :=
            qp_number.canonical_to_number(p_QUALIFIERS_rec.qualifier_attr_value);

            l_qual_attr_value_to_number :=
            qp_number.canonical_to_number(p_QUALIFIERS_rec.qualifier_attr_value_to);

            l_qual_attr_value_from :=
            qp_number.number_to_canonical(l_qual_attr_value_from_number);   --4418053
    ELSE

            l_qual_attr_value_from := p_QUALIFIERS_rec.qualifier_attr_value;  --4418053

    end if;

     EXCEPTION
            WHEN VALUE_ERROR THEN
                  NULL;
            WHEN OTHERS THEN
                  NULL;

    END;

    INSERT  INTO QP_QUALIFIERS
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
    ,       COMPARISON_OPERATOR_CODE
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATED_FROM_RULE_ID
    ,       CREATION_DATE
    ,       END_DATE_ACTIVE
    ,       EXCLUDER_FLAG
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIST_HEADER_ID
    ,       LIST_LINE_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       QUALIFIER_ATTRIBUTE
    ,       QUALIFIER_ATTR_VALUE
    ,       QUALIFIER_ATTR_VALUE_TO
    ,       QUALIFIER_CONTEXT
    ,       QUALIFIER_DATATYPE
    --,       QUALIFIER_DATE_FORMAT
    ,       QUALIFIER_GROUPING_NO
    ,       QUALIFIER_ID
    --,       QUALIFIER_NUMBER_FORMAT
    ,       QUALIFIER_PRECEDENCE
    ,       QUALIFIER_RULE_ID
    ,       REQUEST_ID
    ,       START_DATE_ACTIVE
    ,       ACTIVE_FLAG
    ,       LIST_TYPE_CODE
    ,       QUAL_ATTR_VALUE_FROM_NUMBER
    ,       QUAL_ATTR_VALUE_TO_NUMBER
    ,	  SEARCH_IND
    ,	  QUALIFIER_GROUP_CNT
    ,	  HEADER_QUALS_EXIST_FLAG
    ,	  DISTINCT_ROW_COUNT
    ,     QUALIFY_HIER_DESCENDENTS_FLAG   -- Added for TCA
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,ORIG_SYS_QUALIFIER_REF
     ,ORIG_SYS_LINE_REF
     ,ORIG_SYS_HEADER_REF
    )
    VALUES
    (       p_QUALIFIERS_rec.attribute1
    ,       p_QUALIFIERS_rec.attribute10
    ,       p_QUALIFIERS_rec.attribute11
    ,       p_QUALIFIERS_rec.attribute12
    ,       p_QUALIFIERS_rec.attribute13
    ,       p_QUALIFIERS_rec.attribute14
    ,       p_QUALIFIERS_rec.attribute15
    ,       p_QUALIFIERS_rec.attribute2
    ,       p_QUALIFIERS_rec.attribute3
    ,       p_QUALIFIERS_rec.attribute4
    ,       p_QUALIFIERS_rec.attribute5
    ,       p_QUALIFIERS_rec.attribute6
    ,       p_QUALIFIERS_rec.attribute7
    ,       p_QUALIFIERS_rec.attribute8
    ,       p_QUALIFIERS_rec.attribute9
    ,       p_QUALIFIERS_rec.comparison_operator_code
    ,       p_QUALIFIERS_rec.context
    ,       p_QUALIFIERS_rec.created_by
    ,       p_QUALIFIERS_rec.created_from_rule_id
    ,       p_QUALIFIERS_rec.creation_date
    ,       p_QUALIFIERS_rec.end_date_active
    ,       p_QUALIFIERS_rec.excluder_flag
    ,       p_QUALIFIERS_rec.last_updated_by
    ,       p_QUALIFIERS_rec.last_update_date
    ,       p_QUALIFIERS_rec.last_update_login
    ,       p_QUALIFIERS_rec.list_header_id
    ,       p_QUALIFIERS_rec.list_line_id
    ,       p_QUALIFIERS_rec.program_application_id
    ,       p_QUALIFIERS_rec.program_id
    ,       p_QUALIFIERS_rec.program_update_date
    ,       p_QUALIFIERS_rec.qualifier_attribute
    ,       l_qual_attr_value_from
    ,       p_QUALIFIERS_rec.qualifier_attr_value_to
    ,       p_QUALIFIERS_rec.qualifier_context
    ,       p_QUALIFIERS_rec.qualifier_datatype
    --,       p_QUALIFIERS_rec.qualifier_date_format
    ,       l_qualifier_grouping_no
    ,       p_QUALIFIERS_rec.qualifier_id
    --,       p_QUALIFIERS_rec.qualifier_number_format
    ,       p_QUALIFIERS_rec.qualifier_precedence
    ,       p_QUALIFIERS_rec.qualifier_rule_id
    ,       p_QUALIFIERS_rec.request_id
    ,       p_QUALIFIERS_rec.start_date_active
    ,       l_active_flag
    ,       l_list_type_code
    ,       l_qual_attr_value_from_number
    ,       l_qual_attr_value_to_number
    ,	  p_QUALIFIERS_rec.search_ind
    ,	  p_QUALIFIERS_rec.qualifier_group_cnt
    ,	  p_QUALIFIERS_rec.header_quals_exist_flag
    ,	  p_QUALIFIERS_rec.distinct_row_count
    ,     p_QUALIFIERS_rec.qualify_hier_descendent_flag  -- Added for TCA
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,to_char(p_QUALIFIERS_rec.qualifier_id)
     ,(select l.ORIG_SYS_LINE_REF from qp_list_lines l where l.list_line_id=p_QUALIFIERS_rec.list_line_id)
     ,(select h.ORIG_SYSTEM_HEADER_REF from qp_list_headers_b h where h.list_header_id=p_QUALIFIERS_rec.list_header_id)
    );

l_check_active_flag:=nvl(fnd_profile.value('QP_BUILD_ATTRIBUTES_MAPPING_OPTIONS'),'N');
IF (l_check_active_flag='N') OR (l_check_active_flag='Y' AND l_active_flag='Y') THEN
 IF(p_QUALIFIERS_rec.qualifier_context IS NOT NULL) AND
  (p_QUALIFIERS_rec.qualifier_attribute IS NOT NULL) THEN
	/* USed the cursor update_pte_cur instead of a nested subquery for the update statement
	 * for the bug 3544961*/


	for i in  update_pte_cur(p_QUALIFIERS_rec.qualifier_context, p_QUALIFIERS_rec.qualifier_attribute) loop

	update qp_pte_segments set used_in_setup='Y'
	where nvl(used_in_Setup,'N')='N'
	  and segment_id = i.segment_id;


	end loop;

 END IF;
END IF;
/*l_check_active_flag:=nvl(fnd_profile.value('QP_BUILD_ATTRIBUTES_MAPPING_OPTIONS'),'N');
IF (l_check_active_flag='N') OR (l_check_active_flag='Y' AND l_active_flag='Y') THEN
 IF(p_QUALIFIERS_rec.qualifier_context IS NOT NULL) AND
  (p_QUALIFIERS_rec.qualifier_attribute IS NOT NULL) THEN

  UPDATE qp_pte_segments SET used_in_setup='Y'
  WHERE  nvl(used_in_setup,'N')='N'
  AND segment_id IN
  (SELECT a.segment_id
   FROM   qp_segments_b a,qp_prc_contexts_b b
   WHERE a.segment_mapping_column=p_QUALIFIERS_rec.qualifier_attribute
   AND   a.prc_context_id=b.prc_context_id AND   b.prc_context_type='QUALIFIER'
   AND   b.prc_context_code=p_QUALIFIERS_rec.qualifier_context);
 END IF;
END IF;
*/
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

--This procedure will be used by HTML Qualifier UI
--to insert qualifiers into dummy table for updates
PROCEDURE Insert_Row(p_qual_grp_no IN NUMBER,
                     p_list_header_id IN NUMBER,
                     p_list_line_id IN NUMBER,
		     p_transaction_id IN NUMBER) IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

insert into qp_qualifiers_fwk_dummy
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
    ,       COMPARISON_OPERATOR_CODE
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATED_FROM_RULE_ID
    ,       CREATION_DATE
    ,       END_DATE_ACTIVE
    ,       EXCLUDER_FLAG
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIST_HEADER_ID
    ,       LIST_LINE_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       QUALIFIER_ATTRIBUTE
    ,       QUALIFIER_ATTR_VALUE
    ,       QUALIFIER_ATTR_VALUE_TO
    ,       QUALIFIER_CONTEXT
    ,       QUALIFIER_DATATYPE
    --,       QUALIFIER_DATE_FORMAT
    ,       QUALIFIER_GROUPING_NO
    ,       QUALIFIER_ID
    --,       QUALIFIER_NUMBER_FORMAT
    ,       QUALIFIER_PRECEDENCE
    ,       QUALIFIER_RULE_ID
    ,       REQUEST_ID
    ,       START_DATE_ACTIVE
    ,       ACTIVE_FLAG
    ,       LIST_TYPE_CODE
    ,       QUAL_ATTR_VALUE_FROM_NUMBER
    ,       QUAL_ATTR_VALUE_TO_NUMBER
    ,	  SEARCH_IND
    ,	  QUALIFIER_GROUP_CNT
    ,	  HEADER_QUALS_EXIST_FLAG
    ,	  DISTINCT_ROW_COUNT
    ,     TRANSACTION_ID
    ,     QUALIFY_HIER_DESCENDENTS_FLAG    -- Added for TCA
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,ORIG_SYS_QUALIFIER_REF
     ,ORIG_SYS_LINE_REF
     ,ORIG_SYS_HEADER_REF
    )
     select
           ATTRIBUTE1
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
    ,       COMPARISON_OPERATOR_CODE
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATED_FROM_RULE_ID
    ,       CREATION_DATE
    ,       END_DATE_ACTIVE
    ,       EXCLUDER_FLAG
    ,       LAST_UPDATED_BY
    ,       sysdate
    ,       LAST_UPDATE_LOGIN
    ,       LIST_HEADER_ID
    ,       LIST_LINE_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       QUALIFIER_ATTRIBUTE
    ,       QUALIFIER_ATTR_VALUE
    ,       QUALIFIER_ATTR_VALUE_TO
    ,       QUALIFIER_CONTEXT
    ,       QUALIFIER_DATATYPE
    --,       QUALIFIER_DATE_FORMAT
    ,       QUALIFIER_GROUPING_NO
    ,       QUALIFIER_ID
    --,       QUALIFIER_NUMBER_FORMAT
    ,       QUALIFIER_PRECEDENCE
    ,       QUALIFIER_RULE_ID
    ,       REQUEST_ID
    ,       START_DATE_ACTIVE
    ,       ACTIVE_FLAG
    ,       LIST_TYPE_CODE
    ,       QUAL_ATTR_VALUE_FROM_NUMBER
    ,       QUAL_ATTR_VALUE_TO_NUMBER
    ,	  SEARCH_IND
    ,	  QUALIFIER_GROUP_CNT
    ,	  'Q'
    ,	  DISTINCT_ROW_COUNT
    ,     p_transaction_id
    ,     QUALIFY_HIER_DESCENDENTS_FLAG     -- Added for TCA
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,to_char(qualifier_id)
     ,nvl(ORIG_SYS_LINE_REF,(select l.ORIG_SYS_LINE_REF from qp_list_lines l where l.list_line_id=p_list_line_id))
     ,nvl(ORIG_SYS_HEADER_REF,(select h.ORIG_SYSTEM_HEADER_REF from qp_list_headers_b h where h.list_header_id=p_list_header_id))
from qp_qualifiers qual
where list_header_id = p_list_header_id
and list_line_id = p_list_line_id
and ((p_qual_grp_no = -1
and qualifier_grouping_no = p_qual_grp_no)
or (p_qual_grp_no <> -1
and (qualifier_grouping_no = -1
or qualifier_grouping_no = p_qual_grp_no)))
and ((qual.list_type_code = 'PRL'
and not (qual.qualifier_context = 'MODLIST' and qual.qualifier_attribute = 'QUALIFIER_ATTRIBUTE4'))
or (qual.list_type_code <> 'PRL'))
and not exists (select 'Y' from qp_qualifiers_fwk_dummy dummy
  where dummy.qualifier_id = qual.qualifier_id
  and dummy.transaction_id = p_transaction_id);

  --AUTONOMOUS commit
  commit;
EXCEPTION
When OTHERS Then
null;
END Insert_Row;

--This procedure will be used by HTML Qualifier UI
--to delete rows from dummy table
Procedure Delete_Dummy_Rows(p_transaction_id IN NUMBER) IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  delete from qp_qualifiers_fwk_dummy where transaction_id = p_transaction_id
  or last_update_date < sysdate-5;
--  where list_header_id = p_list_header_id
--  and list_line_id = p_list_line_id;

  --AUTONOMOUS commit
  commit;
EXCEPTION
When OTHERS Then
  null;
END Delete_Dummy_Rows;

--This procedure will mark given qualifier as DELETED
Procedure Mark_Delete_Dummy_Qual(p_qual_id IN NUMBER
                                ,p_mode IN VARCHAR2
                                ,p_transaction_id IN NUMBER) IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
update qp_qualifiers_fwk_dummy set header_quals_exist_flag = decode(p_mode, 'HGRID', 'X', 'D'),
                                   last_update_date = sysdate
where qualifier_id = p_qual_id
and transaction_id = p_transaction_id;

IF SQL%ROWCOUNT < 1 THEN
  insert into qp_qualifiers_fwk_dummy
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
    ,       COMPARISON_OPERATOR_CODE
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATED_FROM_RULE_ID
    ,       CREATION_DATE
    ,       END_DATE_ACTIVE
    ,       EXCLUDER_FLAG
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIST_HEADER_ID
    ,       LIST_LINE_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       QUALIFIER_ATTRIBUTE
    ,       QUALIFIER_ATTR_VALUE
    ,       QUALIFIER_ATTR_VALUE_TO
    ,       QUALIFIER_CONTEXT
    ,       QUALIFIER_DATATYPE
    --,       QUALIFIER_DATE_FORMAT
    ,       QUALIFIER_GROUPING_NO
    ,       QUALIFIER_ID
    --,       QUALIFIER_NUMBER_FORMAT
    ,       QUALIFIER_PRECEDENCE
    ,       QUALIFIER_RULE_ID
    ,       REQUEST_ID
    ,       START_DATE_ACTIVE
    ,       ACTIVE_FLAG
    ,       LIST_TYPE_CODE
    ,       QUAL_ATTR_VALUE_FROM_NUMBER
    ,       QUAL_ATTR_VALUE_TO_NUMBER
    ,	  SEARCH_IND
    ,	  QUALIFIER_GROUP_CNT
    ,	  HEADER_QUALS_EXIST_FLAG
    ,	  DISTINCT_ROW_COUNT
    ,     TRANSACTION_ID
    ,     QUALIFY_HIER_DESCENDENTS_FLAG    -- Added for TCA
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,ORIG_SYS_QUALIFIER_REF
     ,ORIG_SYS_LINE_REF
     ,ORIG_SYS_HEADER_REF
    )
     select
           ATTRIBUTE1
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
    ,       COMPARISON_OPERATOR_CODE
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATED_FROM_RULE_ID
    ,       CREATION_DATE
    ,       END_DATE_ACTIVE
    ,       EXCLUDER_FLAG
    ,       LAST_UPDATED_BY
    ,       sysdate
    ,       LAST_UPDATE_LOGIN
    ,       LIST_HEADER_ID
    ,       LIST_LINE_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       QUALIFIER_ATTRIBUTE
    ,       QUALIFIER_ATTR_VALUE
    ,       QUALIFIER_ATTR_VALUE_TO
    ,       QUALIFIER_CONTEXT
    ,       QUALIFIER_DATATYPE
    --,       QUALIFIER_DATE_FORMAT
    ,       QUALIFIER_GROUPING_NO
    ,       QUALIFIER_ID
    --,       QUALIFIER_NUMBER_FORMAT
    ,       QUALIFIER_PRECEDENCE
    ,       QUALIFIER_RULE_ID
    ,       REQUEST_ID
    ,       START_DATE_ACTIVE
    ,       ACTIVE_FLAG
    ,       LIST_TYPE_CODE
    ,       QUAL_ATTR_VALUE_FROM_NUMBER
    ,       QUAL_ATTR_VALUE_TO_NUMBER
    ,	  SEARCH_IND
    ,	  QUALIFIER_GROUP_CNT
    ,	  decode(p_mode, 'HGRID', 'X', 'D')
    ,	  DISTINCT_ROW_COUNT
    ,     p_transaction_id
    ,     QUALIFY_HIER_DESCENDENTS_FLAG    -- Added for TCA
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,to_char(qual.qualifier_id)
     ,nvl(qual.ORIG_SYS_LINE_REF,(select l.ORIG_SYS_LINE_REF from qp_list_lines l where l.list_line_id=qual.list_line_id))
     ,nvl(qual.ORIG_SYS_HEADER_REF,(select h.ORIG_SYSTEM_HEADER_REF from qp_list_headers_b h where h.list_header_id=qual.list_header_id))
  from qp_qualifiers qual
  where qualifier_id = p_qual_id;
END IF;--SQL%ROWCOUNT
  --AUTONOMOUS commit
  commit;
EXCEPTION
WHEN OTHERS THEN
  null;
END Mark_Delete_Dummy_Qual;

--This procedure will mark given qualifiergroup as DELETED
Procedure Mark_Delete_Dummy_Qual(p_qual_grp_no IN NUMBER,
                         p_list_header_id IN NUMBER,
                         p_list_line_id IN NUMBER,
                         p_transaction_id IN NUMBER) IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
update qp_qualifiers_fwk_dummy set header_quals_exist_flag = 'X'
                                  ,last_update_date = sysdate
where qualifier_grouping_no = p_qual_grp_no
and list_header_id = p_list_header_id
and list_line_id = p_list_line_id
and ((list_type_code = 'PRL'
and not (qualifier_context = 'MODLIST' and qualifier_attribute = 'QUALIFIER_ATTRIBUTE4'))
or (list_type_code <> 'PRL'))
and transaction_id = p_transaction_id;

IF SQL%ROWCOUNT < 1 THEN
  insert into qp_qualifiers_fwk_dummy
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
    ,       COMPARISON_OPERATOR_CODE
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATED_FROM_RULE_ID
    ,       CREATION_DATE
    ,       END_DATE_ACTIVE
    ,       EXCLUDER_FLAG
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIST_HEADER_ID
    ,       LIST_LINE_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       QUALIFIER_ATTRIBUTE
    ,       QUALIFIER_ATTR_VALUE
    ,       QUALIFIER_ATTR_VALUE_TO
    ,       QUALIFIER_CONTEXT
    ,       QUALIFIER_DATATYPE
    --,       QUALIFIER_DATE_FORMAT
    ,       QUALIFIER_GROUPING_NO
    ,       QUALIFIER_ID
    --,       QUALIFIER_NUMBER_FORMAT
    ,       QUALIFIER_PRECEDENCE
    ,       QUALIFIER_RULE_ID
    ,       REQUEST_ID
    ,       START_DATE_ACTIVE
    ,       ACTIVE_FLAG
    ,       LIST_TYPE_CODE
    ,       QUAL_ATTR_VALUE_FROM_NUMBER
    ,       QUAL_ATTR_VALUE_TO_NUMBER
    ,	  SEARCH_IND
    ,	  QUALIFIER_GROUP_CNT
    ,	  HEADER_QUALS_EXIST_FLAG
    ,	  DISTINCT_ROW_COUNT
    ,     TRANSACTION_ID
    ,     QUALIFY_HIER_DESCENDENTS_FLAG   -- Added for TCA
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,ORIG_SYS_QUALIFIER_REF
     ,ORIG_SYS_LINE_REF
     ,ORIG_SYS_HEADER_REF
    )
     select
           ATTRIBUTE1
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
    ,       COMPARISON_OPERATOR_CODE
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATED_FROM_RULE_ID
    ,       CREATION_DATE
    ,       END_DATE_ACTIVE
    ,       EXCLUDER_FLAG
    ,       LAST_UPDATED_BY
    ,       sysdate
    ,       LAST_UPDATE_LOGIN
    ,       LIST_HEADER_ID
    ,       LIST_LINE_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       QUALIFIER_ATTRIBUTE
    ,       QUALIFIER_ATTR_VALUE
    ,       QUALIFIER_ATTR_VALUE_TO
    ,       QUALIFIER_CONTEXT
    ,       QUALIFIER_DATATYPE
    --,       QUALIFIER_DATE_FORMAT
    ,       QUALIFIER_GROUPING_NO
    ,       QUALIFIER_ID
    --,       QUALIFIER_NUMBER_FORMAT
    ,       QUALIFIER_PRECEDENCE
    ,       QUALIFIER_RULE_ID
    ,       REQUEST_ID
    ,       START_DATE_ACTIVE
    ,       ACTIVE_FLAG
    ,       LIST_TYPE_CODE
    ,       QUAL_ATTR_VALUE_FROM_NUMBER
    ,       QUAL_ATTR_VALUE_TO_NUMBER
    ,	  SEARCH_IND
    ,	  QUALIFIER_GROUP_CNT
    ,	  'X'
    ,	  DISTINCT_ROW_COUNT
    ,     p_transaction_id
    ,     QUALIFY_HIER_DESCENDENTS_FLAG    -- Added for TCA
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,to_char(qualifier_id)
     ,nvl(ORIG_SYS_LINE_REF,(select l.ORIG_SYS_LINE_REF from qp_list_lines l where l.list_line_id=p_list_line_id))
     ,nvl(ORIG_SYS_HEADER_REF,(select h.ORIG_SYSTEM_HEADER_REF from qp_list_headers_b h where h.list_header_id=p_list_header_id))
  from qp_qualifiers qual
  where list_header_id = p_list_header_id
  and list_line_id = p_list_line_id
  and qualifier_grouping_no = p_qual_grp_no
and ((qual.list_type_code = 'PRL'
and not (qual.qualifier_context = 'MODLIST' and qual.qualifier_attribute = 'QUALIFIER_ATTRIBUTE4'))
or (qual.list_type_code <> 'PRL'));
END IF;--SQL%ROWCOUNT
  --AUTONOMOUS commit
  commit;
EXCEPTION
WHEN OTHERS THEN
  null;
END Mark_Delete_Dummy_Qual;

--This procedure will delete the dummy qualifiers inserted for updates
Procedure Remove_Dummy_Quals(p_action_type IN VARCHAR2,
                         p_list_header_id IN NUMBER,
                         p_list_line_id IN NUMBER,
                         p_transaction_id IN NUMBER) IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
IF p_action_type = 'CANCEL' THEN
  delete from qp_qualifiers_fwk_dummy
  where list_header_id = p_list_header_id
  and list_line_id = p_list_line_id
  and transaction_id = p_transaction_id
  and nvl(header_quals_exist_flag, 'N') in ('Q');--, 'D', 'U', 'N');
ELSIF p_action_type = 'APPLY' THEN
  delete from qp_qualifiers_fwk_dummy
  where list_header_id = p_list_header_id
  and list_line_id = p_list_line_id
  and transaction_id = p_transaction_id
  and nvl(header_quals_exist_flag, 'N') = 'Q';
END IF;--p_action_type
  --AUTONOMOUS commit
  commit;
EXCEPTION
WHEN OTHERS THEN
  null;
END Remove_Dummy_Quals;

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_qualifier_id                  IN  NUMBER := FND_API.G_MISS_NUM,
    p_qualifier_rule_id             IN  NUMBER := FND_API.G_MISS_NUM
)
IS
--l_check_active_flag VARCHAR2(1);
--l_status VARCHAR2(1);
--l_qualifiers_rec   QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
BEGIN
  -- l_qualifiers_rec:=Query_Row(p_qualifier_id);
   IF p_qualifier_rule_id <> FND_API.G_MISS_NUM
   THEN

       DELETE  FROM QP_QUALIFIERS
       WHERE   QUALIFIER_RULE_ID = p_qualifier_rule_id ;
   ELSE

    DELETE  FROM QP_QUALIFIERS
    WHERE   QUALIFIER_ID = p_qualifier_id ;

   END IF;

/*
l_check_active_flag:=nvl(fnd_profile.value('QP_BUILD_ATTRIBUTES_MAPPING_OPTIONS'),'N');
IF (l_check_active_flag='N') OR (l_check_active_flag='Y' AND l_qualifiers_rec.active_flag='Y') THEN
 IF(l_qualifiers_rec.qualifier_context IS NOT NULL) AND
  (l_qualifiers_rec.qualifier_attribute IS NOT NULL) THEN
  l_status:=QP_UTIL.Is_Used('QUALIFIER',
                            l_qualifiers_rec.qualifier_context,
                            l_qualifiers_rec.qualifier_attribute);
  IF l_status='N' THEN
  UPDATE qp_pte_segments SET used_in_setup='N'
  WHERE
   segment_id IN
  (SELECT a.segment_id
   FROM   qp_segments_b a,qp_prc_contexts_b b
   WHERE a.segment_mapping_column=l_qualifiers_rec.qualifier_attribute
   AND   a.prc_context_id=b.prc_context_id
   AND   b.prc_context_type='QUALIFIER'
   AND   b.prc_context_code=l_qualifiers_rec.qualifier_context);
  END IF;
 END IF;
END IF;
*/

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

PROCEDURE Delete_Row(p_qual_grp_no IN NUMBER,
                     p_list_header_id IN NUMBER,
                     p_list_line_id IN NUMBER,
                     p_transaction_id IN NUMBER)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  delete from qp_qualifiers_fwk_dummy
  where transaction_id = p_transaction_id
  or last_update_date < sysdate - 5;
  --where qualifier_grouping_no = p_qual_grp_no
  --and list_header_id = p_list_header_id
  --and list_line_id = p_list_line_id;

  COMMIT;

EXCEPTION
    WHEN OTHERS THEN
    null;
End Delete_Row;

--  Function Query_Row

FUNCTION Query_Row
(   p_qualifier_id                  IN  NUMBER
) RETURN QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
IS
BEGIN

    RETURN Query_Rows
        (   p_qualifier_id                => p_qualifier_id
        )(1);

END Query_Row;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_qualifier_id                  IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_qualifier_rule_id             IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
IS
l_QUALIFIERS_rec              QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_QUALIFIERS_tbl              QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;

CURSOR l_QUALIFIERS_csr IS
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
    ,       COMPARISON_OPERATOR_CODE
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATED_FROM_RULE_ID
    ,       CREATION_DATE
    ,       END_DATE_ACTIVE
    ,       EXCLUDER_FLAG
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIST_HEADER_ID
    ,       LIST_LINE_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       QUALIFIER_ATTRIBUTE
    ,       QUALIFIER_ATTR_VALUE
    ,       QUALIFIER_ATTR_VALUE_TO
    ,       QUALIFIER_CONTEXT
    ,       QUALIFIER_DATATYPE
   -- ,       QUALIFIER_DATE_FORMAT
    ,       QUALIFIER_GROUPING_NO
    ,       QUALIFIER_ID
   -- ,       QUALIFIER_NUMBER_FORMAT
    ,       QUALIFIER_PRECEDENCE
    ,       QUALIFIER_RULE_ID
    ,       REQUEST_ID
    ,       START_DATE_ACTIVE
    ,       LIST_TYPE_CODE
    ,       QUAL_ATTR_VALUE_FROM_NUMBER
    ,       QUAL_ATTR_VALUE_TO_NUMBER
    ,       ACTIVE_FLAG
    ,	  SEARCH_IND
    ,	  QUALIFIER_GROUP_CNT
    ,	  HEADER_QUALS_EXIST_FLAG
    ,	  DISTINCT_ROW_COUNT
    ,     QUALIFY_HIER_DESCENDENTS_FLAG    -- Added for TCA
    FROM    QP_QUALIFIERS
    WHERE ( QUALIFIER_ID = p_qualifier_id
    )
    OR (    QUALIFIER_RULE_ID = p_qualifier_rule_id
    );

BEGIN

    IF
    (p_qualifier_id IS NOT NULL
     AND
     p_qualifier_id <> FND_API.G_MISS_NUM)
    AND
    (p_qualifier_rule_id IS NOT NULL
     AND
     p_qualifier_rule_id <> FND_API.G_MISS_NUM)
    THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: qualifier_id = '|| p_qualifier_id || ', qualifier_rule_id = '|| p_qualifier_rule_id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    --  Loop over fetched records

    FOR l_implicit_rec IN l_QUALIFIERS_csr LOOP

        l_QUALIFIERS_rec.attribute1    := l_implicit_rec.ATTRIBUTE1;
        l_QUALIFIERS_rec.attribute10   := l_implicit_rec.ATTRIBUTE10;
        l_QUALIFIERS_rec.attribute11   := l_implicit_rec.ATTRIBUTE11;
        l_QUALIFIERS_rec.attribute12   := l_implicit_rec.ATTRIBUTE12;
        l_QUALIFIERS_rec.attribute13   := l_implicit_rec.ATTRIBUTE13;
        l_QUALIFIERS_rec.attribute14   := l_implicit_rec.ATTRIBUTE14;
        l_QUALIFIERS_rec.attribute15   := l_implicit_rec.ATTRIBUTE15;
        l_QUALIFIERS_rec.attribute2    := l_implicit_rec.ATTRIBUTE2;
        l_QUALIFIERS_rec.attribute3    := l_implicit_rec.ATTRIBUTE3;
        l_QUALIFIERS_rec.attribute4    := l_implicit_rec.ATTRIBUTE4;
        l_QUALIFIERS_rec.attribute5    := l_implicit_rec.ATTRIBUTE5;
        l_QUALIFIERS_rec.attribute6    := l_implicit_rec.ATTRIBUTE6;
        l_QUALIFIERS_rec.attribute7    := l_implicit_rec.ATTRIBUTE7;
        l_QUALIFIERS_rec.attribute8    := l_implicit_rec.ATTRIBUTE8;
        l_QUALIFIERS_rec.attribute9    := l_implicit_rec.ATTRIBUTE9;
        l_QUALIFIERS_rec.comparison_operator_code := l_implicit_rec.COMPARISON_OPERATOR_CODE;
        l_QUALIFIERS_rec.context       := l_implicit_rec.CONTEXT;
        l_QUALIFIERS_rec.created_by    := l_implicit_rec.CREATED_BY;
        l_QUALIFIERS_rec.created_from_rule_id := l_implicit_rec.CREATED_FROM_RULE_ID;
        l_QUALIFIERS_rec.creation_date := l_implicit_rec.CREATION_DATE;
        l_QUALIFIERS_rec.end_date_active := l_implicit_rec.END_DATE_ACTIVE;
        l_QUALIFIERS_rec.excluder_flag := l_implicit_rec.EXCLUDER_FLAG;
        l_QUALIFIERS_rec.last_updated_by := l_implicit_rec.LAST_UPDATED_BY;
        l_QUALIFIERS_rec.last_update_date := l_implicit_rec.LAST_UPDATE_DATE;
        l_QUALIFIERS_rec.last_update_login := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_QUALIFIERS_rec.list_header_id := l_implicit_rec.LIST_HEADER_ID;
        l_QUALIFIERS_rec.list_line_id  := l_implicit_rec.LIST_LINE_ID;
        l_QUALIFIERS_rec.program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_QUALIFIERS_rec.program_id    := l_implicit_rec.PROGRAM_ID;
        l_QUALIFIERS_rec.program_update_date := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_QUALIFIERS_rec.qualifier_attribute := l_implicit_rec.QUALIFIER_ATTRIBUTE;
        l_QUALIFIERS_rec.qualifier_attr_value := l_implicit_rec.QUALIFIER_ATTR_VALUE;
        l_QUALIFIERS_rec.qualifier_attr_value_to := l_implicit_rec.QUALIFIER_ATTR_VALUE_TO;
        l_QUALIFIERS_rec.qualifier_context := l_implicit_rec.QUALIFIER_CONTEXT;
        l_QUALIFIERS_rec.qualifier_datatype := l_implicit_rec.QUALIFIER_DATATYPE;
       -- l_QUALIFIERS_rec.qualifier_date_format := l_implicit_rec.QUALIFIER_DATE_FORMAT;
        l_QUALIFIERS_rec.qualifier_grouping_no := l_implicit_rec.QUALIFIER_GROUPING_NO;
        l_QUALIFIERS_rec.qualifier_id  := l_implicit_rec.QUALIFIER_ID;
        --l_QUALIFIERS_rec.qualifier_number_format := l_implicit_rec.QUALIFIER_NUMBER_FORMAT;
        l_QUALIFIERS_rec.qualifier_precedence := l_implicit_rec.QUALIFIER_PRECEDENCE;
        l_QUALIFIERS_rec.qualifier_rule_id := l_implicit_rec.QUALIFIER_RULE_ID;
        l_QUALIFIERS_rec.request_id    := l_implicit_rec.REQUEST_ID;
        l_QUALIFIERS_rec.start_date_active := l_implicit_rec.START_DATE_ACTIVE;
        l_QUALIFIERS_rec.list_type_code := l_implicit_rec.LIST_TYPE_CODE;
        l_QUALIFIERS_rec.qual_attr_value_from_number := l_implicit_rec.QUAL_ATTR_VALUE_FROM_NUMBER;
        l_QUALIFIERS_rec.qual_attr_value_to_number := l_implicit_rec.QUAL_ATTR_VALUE_TO_NUMBER;
	   l_QUALIFIERS_rec.active_flag := l_implicit_rec.ACTIVE_FLAG;
	   l_QUALIFIERS_rec.search_ind := l_implicit_rec.SEARCH_IND;
	   l_QUALIFIERS_rec.qualifier_group_cnt := l_implicit_rec.QUALIFIER_GROUP_CNT;
	   l_QUALIFIERS_rec.header_quals_exist_flag := l_implicit_rec.HEADER_QUALS_EXIST_FLAG;
	   l_QUALIFIERS_rec.distinct_row_count := l_implicit_rec.DISTINCT_ROW_COUNT;
           l_QUALIFIERS_rec.qualify_hier_descendent_flag := l_implicit_rec.QUALIFY_HIER_DESCENDENTS_FLAG ; -- Added for TCA

        l_QUALIFIERS_tbl(l_QUALIFIERS_tbl.COUNT + 1) := l_QUALIFIERS_rec;

    END LOOP;


    --  PK sent and no rows found

    IF
    (p_qualifier_id IS NOT NULL
     AND
     p_qualifier_id <> FND_API.G_MISS_NUM)
    AND
    (l_QUALIFIERS_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table

    RETURN l_QUALIFIERS_tbl;

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
,   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
,   x_QUALIFIERS_rec                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
)
IS
l_QUALIFIERS_rec              QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
BEGIN

   oe_debug_pub.add('in QPXUQPQB.pls lock row');




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
    ,       COMPARISON_OPERATOR_CODE
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATED_FROM_RULE_ID
    ,       CREATION_DATE
    ,       END_DATE_ACTIVE
    ,       EXCLUDER_FLAG
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIST_HEADER_ID
    ,       LIST_LINE_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       QUALIFIER_ATTRIBUTE
    ,       QUALIFIER_ATTR_VALUE
    ,       QUALIFIER_ATTR_VALUE_TO
    ,       QUALIFIER_CONTEXT
    ,       QUALIFIER_DATATYPE
    --,       QUALIFIER_DATE_FORMAT
    ,       QUALIFIER_GROUPING_NO
    ,       QUALIFIER_ID
    --,       QUALIFIER_NUMBER_FORMAT
    ,       QUALIFIER_PRECEDENCE
    ,       QUALIFIER_RULE_ID
    ,       REQUEST_ID
    ,       START_DATE_ACTIVE
    ,       QUALIFY_HIER_DESCENDENTS_FLAG    -- Added for TCA
    INTO    l_QUALIFIERS_rec.attribute1
    ,       l_QUALIFIERS_rec.attribute10
    ,       l_QUALIFIERS_rec.attribute11
    ,       l_QUALIFIERS_rec.attribute12
    ,       l_QUALIFIERS_rec.attribute13
    ,       l_QUALIFIERS_rec.attribute14
    ,       l_QUALIFIERS_rec.attribute15
    ,       l_QUALIFIERS_rec.attribute2
    ,       l_QUALIFIERS_rec.attribute3
    ,       l_QUALIFIERS_rec.attribute4
    ,       l_QUALIFIERS_rec.attribute5
    ,       l_QUALIFIERS_rec.attribute6
    ,       l_QUALIFIERS_rec.attribute7
    ,       l_QUALIFIERS_rec.attribute8
    ,       l_QUALIFIERS_rec.attribute9
    ,       l_QUALIFIERS_rec.comparison_operator_code
    ,       l_QUALIFIERS_rec.context
    ,       l_QUALIFIERS_rec.created_by
    ,       l_QUALIFIERS_rec.created_from_rule_id
    ,       l_QUALIFIERS_rec.creation_date
    ,       l_QUALIFIERS_rec.end_date_active
    ,       l_QUALIFIERS_rec.excluder_flag
    ,       l_QUALIFIERS_rec.last_updated_by
    ,       l_QUALIFIERS_rec.last_update_date
    ,       l_QUALIFIERS_rec.last_update_login
    ,       l_QUALIFIERS_rec.list_header_id
    ,       l_QUALIFIERS_rec.list_line_id
    ,       l_QUALIFIERS_rec.program_application_id
    ,       l_QUALIFIERS_rec.program_id
    ,       l_QUALIFIERS_rec.program_update_date
    ,       l_QUALIFIERS_rec.qualifier_attribute
    ,       l_QUALIFIERS_rec.qualifier_attr_value
    ,       l_QUALIFIERS_rec.qualifier_attr_value_to
    ,       l_QUALIFIERS_rec.qualifier_context
    ,       l_QUALIFIERS_rec.qualifier_datatype
    --,       l_QUALIFIERS_rec.qualifier_date_format
    ,       l_QUALIFIERS_rec.qualifier_grouping_no
    ,       l_QUALIFIERS_rec.qualifier_id
    --,       l_QUALIFIERS_rec.qualifier_number_format
    ,       l_QUALIFIERS_rec.qualifier_precedence
    ,       l_QUALIFIERS_rec.qualifier_rule_id
    ,       l_QUALIFIERS_rec.request_id
    ,       l_QUALIFIERS_rec.start_date_active
    ,       l_QUALIFIERS_rec.qualify_hier_descendent_flag   -- Added for TCA
    FROM    QP_QUALIFIERS
    WHERE   QUALIFIER_ID = p_QUALIFIERS_rec.qualifier_id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.


    /*IF  QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute1,
                         l_QUALIFIERS_rec.attribute1)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute10,
                         l_QUALIFIERS_rec.attribute10)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute11,
                         l_QUALIFIERS_rec.attribute11)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute12,
                         l_QUALIFIERS_rec.attribute12)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute13,
                         l_QUALIFIERS_rec.attribute13)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute14,
                         l_QUALIFIERS_rec.attribute14)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute15,
                         l_QUALIFIERS_rec.attribute15)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute2,
                         l_QUALIFIERS_rec.attribute2)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute3,
                         l_QUALIFIERS_rec.attribute3)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute4,
                         l_QUALIFIERS_rec.attribute4)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute5,
                         l_QUALIFIERS_rec.attribute5)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute6,
                         l_QUALIFIERS_rec.attribute6)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute7,
                         l_QUALIFIERS_rec.attribute7)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute8,
                         l_QUALIFIERS_rec.attribute8)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute9,
                         l_QUALIFIERS_rec.attribute9)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.comparison_operator_code,
                         l_QUALIFIERS_rec.comparison_operator_code)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.context,
                         l_QUALIFIERS_rec.context)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.created_by,
                        l_QUALIFIERS_rec.created_by)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.created_from_rule_id,
                         l_QUALIFIERS_rec.created_from_rule_id)
    --AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.creation_date,
    --                     l_QUALIFIERS_rec.creation_date)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.end_date_active,
                         l_QUALIFIERS_rec.end_date_active)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.excluder_flag,
                         l_QUALIFIERS_rec.excluder_flag)
    --AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.last_updated_by,
    --                     l_QUALIFIERS_rec.last_updated_by)
    --AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.last_update_date,
    --                     l_QUALIFIERS_rec.last_update_date)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.last_update_login,
                         l_QUALIFIERS_rec.last_update_login)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.list_header_id,
                         l_QUALIFIERS_rec.list_header_id)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.list_line_id,
                         l_QUALIFIERS_rec.list_line_id)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.program_application_id,
                         l_QUALIFIERS_rec.program_application_id)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.program_id,
                         l_QUALIFIERS_rec.program_id)
    --AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.program_update_date,
    --                     l_QUALIFIERS_rec.program_update_date)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_attribute,
                         l_QUALIFIERS_rec.qualifier_attribute)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_attr_value,
                         l_QUALIFIERS_rec.qualifier_attr_value)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_attr_value_to,
                         l_QUALIFIERS_rec.qualifier_attr_value_to)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_context,
                         l_QUALIFIERS_rec.qualifier_context)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_datatype,
                         l_QUALIFIERS_rec.qualifier_datatype)
    --AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_date_format,
    --                     l_QUALIFIERS_rec.qualifier_date_format)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_grouping_no,
                         l_QUALIFIERS_rec.qualifier_grouping_no)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_id,
                         l_QUALIFIERS_rec.qualifier_id)
    --AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_number_format,
    --                     l_QUALIFIERS_rec.qualifier_number_format)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_precedence,
                         l_QUALIFIERS_rec.qualifier_precedence)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_rule_id,
                         l_QUALIFIERS_rec.qualifier_rule_id)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.request_id,
                         l_QUALIFIERS_rec.request_id)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.start_date_active,
                         l_QUALIFIERS_rec.start_date_active)*/


    IF  QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute1,
                         l_QUALIFIERS_rec.attribute1)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute10,
                         l_QUALIFIERS_rec.attribute10)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute11,
                         l_QUALIFIERS_rec.attribute11)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute12,
                         l_QUALIFIERS_rec.attribute12)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute13,
                         l_QUALIFIERS_rec.attribute13)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute14,
                         l_QUALIFIERS_rec.attribute14)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute15,
                         l_QUALIFIERS_rec.attribute15)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute2,
                         l_QUALIFIERS_rec.attribute2)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute3,
                         l_QUALIFIERS_rec.attribute3)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute4,
                         l_QUALIFIERS_rec.attribute4)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute5,
                         l_QUALIFIERS_rec.attribute5)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute6,
                         l_QUALIFIERS_rec.attribute6)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute7,
                         l_QUALIFIERS_rec.attribute7)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute8,
                         l_QUALIFIERS_rec.attribute8)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute9,
                         l_QUALIFIERS_rec.attribute9)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.comparison_operator_code,
                         l_QUALIFIERS_rec.comparison_operator_code)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.context,
                         l_QUALIFIERS_rec.context)
    --AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.created_by,
    --                     l_QUALIFIERS_rec.created_by)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.created_from_rule_id,
                         l_QUALIFIERS_rec.created_from_rule_id)
    --AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.creation_date,
    --                     l_QUALIFIERS_rec.creation_date)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.end_date_active,
                         l_QUALIFIERS_rec.end_date_active)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.excluder_flag,
                         l_QUALIFIERS_rec.excluder_flag)
    --AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.last_updated_by,
    --                     l_QUALIFIERS_rec.last_updated_by)
    --AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.last_update_date,
    --                     l_QUALIFIERS_rec.last_update_date)
    --AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.last_update_login,
    --                     l_QUALIFIERS_rec.last_update_login)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.list_header_id,
                         l_QUALIFIERS_rec.list_header_id)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.list_line_id,
                         l_QUALIFIERS_rec.list_line_id)
    --AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.program_application_id,
    --                     l_QUALIFIERS_rec.program_application_id)
    --AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.program_id,
    --                     l_QUALIFIERS_rec.program_id)
    --AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.program_update_date,
    --                     l_QUALIFIERS_rec.program_update_date)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_attribute,
                         l_QUALIFIERS_rec.qualifier_attribute)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_attr_value,
                         l_QUALIFIERS_rec.qualifier_attr_value)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_attr_value_to,
                         l_QUALIFIERS_rec.qualifier_attr_value_to)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_context,
                         l_QUALIFIERS_rec.qualifier_context)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_datatype,
                         l_QUALIFIERS_rec.qualifier_datatype)
    --AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_date_format,
    --                     l_QUALIFIERS_rec.qualifier_date_format)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_grouping_no,
                         l_QUALIFIERS_rec.qualifier_grouping_no)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_id,
                         l_QUALIFIERS_rec.qualifier_id)
    --AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_number_format,
    --                     l_QUALIFIERS_rec.qualifier_number_format)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_precedence,
                         l_QUALIFIERS_rec.qualifier_precedence)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_rule_id,
                         l_QUALIFIERS_rec.qualifier_rule_id)
    --AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.request_id,
    --                     l_QUALIFIERS_rec.request_id)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.start_date_active,
                         l_QUALIFIERS_rec.start_date_active)
-- Added for TCA
    AND (QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualify_hier_descendent_flag,
                         l_QUALIFIERS_rec.qualify_hier_descendent_flag)
		OR (p_QUALIFIERS_rec.qualify_hier_descendent_flag = FND_API.G_MISS_CHAR
			and l_QUALIFIERS_rec.qualify_hier_descendent_flag is null))
    THEN

        --  Row has not changed. Set out parameter.

        oe_debug_pub.add('row not changed');
        x_QUALIFIERS_rec               := l_QUALIFIERS_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE
	--8594682 - Add debug messages for OE_LOCK error
	oe_debug_pub.ADD('-------------------Data compare in Price list line Qualifier(database vs record)------------------');
	oe_debug_pub.ADD('qualifier_id		:'||l_QUALIFIERS_rec.qualifier_id||':'||p_QUALIFIERS_rec.qualifier_id||':');
	oe_debug_pub.ADD('attribute1		:'||l_QUALIFIERS_rec.attribute1||':'||p_QUALIFIERS_rec.attribute1||':');
	oe_debug_pub.ADD('attribute10		:'||l_QUALIFIERS_rec.attribute10||':'||p_QUALIFIERS_rec.attribute10||':');
	oe_debug_pub.ADD('attribute11		:'||l_QUALIFIERS_rec.attribute11||':'||p_QUALIFIERS_rec.attribute11||':');
	oe_debug_pub.ADD('attribute12		:'||l_QUALIFIERS_rec.attribute12||':'||p_QUALIFIERS_rec.attribute12||':');
	oe_debug_pub.ADD('attribute13		:'||l_QUALIFIERS_rec.attribute13||':'||p_QUALIFIERS_rec.attribute13||':');
	oe_debug_pub.ADD('attribute14		:'||l_QUALIFIERS_rec.attribute14||':'||p_QUALIFIERS_rec.attribute14||':');
	oe_debug_pub.ADD('attribute15		:'||l_QUALIFIERS_rec.attribute15||':'||p_QUALIFIERS_rec.attribute15||':');
	oe_debug_pub.ADD('attribute2		:'||l_QUALIFIERS_rec.attribute2||':'||p_QUALIFIERS_rec.attribute2||':');
	oe_debug_pub.ADD('attribute3		:'||l_QUALIFIERS_rec.attribute3||':'||p_QUALIFIERS_rec.attribute3||':');
	oe_debug_pub.ADD('attribute4		:'||l_QUALIFIERS_rec.attribute4||':'||p_QUALIFIERS_rec.attribute4||':');
	oe_debug_pub.ADD('attribute5		:'||l_QUALIFIERS_rec.attribute5||':'||p_QUALIFIERS_rec.attribute5||':');
	oe_debug_pub.ADD('attribute6		:'||l_QUALIFIERS_rec.attribute6||':'||p_QUALIFIERS_rec.attribute6||':');
	oe_debug_pub.ADD('attribute7		:'||l_QUALIFIERS_rec.attribute7||':'||p_QUALIFIERS_rec.attribute7||':');
	oe_debug_pub.ADD('attribute8		:'||l_QUALIFIERS_rec.attribute8||':'||p_QUALIFIERS_rec.attribute8||':');
	oe_debug_pub.ADD('attribute9		:'||l_QUALIFIERS_rec.attribute9||':'||p_QUALIFIERS_rec.attribute9||':');
	oe_debug_pub.ADD('comparison_operator_code:'||l_QUALIFIERS_rec.comparison_operator_code||':'||p_QUALIFIERS_rec.comparison_operator_code||':');
	oe_debug_pub.ADD('context		:'||l_QUALIFIERS_rec.context||':'||p_QUALIFIERS_rec.context||':');
	oe_debug_pub.ADD('created_by		:'||l_QUALIFIERS_rec.created_by||':'||p_QUALIFIERS_rec.created_by||':');
	oe_debug_pub.ADD('created_from_rule_id	:'||l_QUALIFIERS_rec.created_from_rule_id||':'||p_QUALIFIERS_rec.created_from_rule_id||':');
	oe_debug_pub.ADD('creation_date		:'||l_QUALIFIERS_rec.creation_date||':'||p_QUALIFIERS_rec.creation_date||':');
	oe_debug_pub.ADD('end_date_active	:'||l_QUALIFIERS_rec.end_date_active||':'||p_QUALIFIERS_rec.end_date_active||':');
	oe_debug_pub.ADD('excluder_flag		:'||l_QUALIFIERS_rec.excluder_flag||':'||p_QUALIFIERS_rec.excluder_flag||':');
	oe_debug_pub.ADD('last_updated_by	:'||l_QUALIFIERS_rec.last_updated_by||':'||p_QUALIFIERS_rec.last_updated_by||':');
	oe_debug_pub.ADD('last_update_date	:'||l_QUALIFIERS_rec.last_update_date||':'||p_QUALIFIERS_rec.last_update_date||':');
	oe_debug_pub.ADD('last_update_login	:'||l_QUALIFIERS_rec.last_update_login||':'||p_QUALIFIERS_rec.last_update_login||':');
	oe_debug_pub.ADD('list_header_id	:'||l_QUALIFIERS_rec.list_header_id||':'||p_QUALIFIERS_rec.list_header_id||':');
	oe_debug_pub.ADD('list_line_id		:'||l_QUALIFIERS_rec.list_line_id||':'||p_QUALIFIERS_rec.list_line_id||':');
	oe_debug_pub.ADD('program_application_id:'||l_QUALIFIERS_rec.program_application_id||':'||p_QUALIFIERS_rec.program_application_id||':');
	oe_debug_pub.ADD('program_id		:'||l_QUALIFIERS_rec.program_id||':'||p_QUALIFIERS_rec.program_id||':');
	oe_debug_pub.ADD('program_update_date	:'||l_QUALIFIERS_rec.program_update_date||':'||p_QUALIFIERS_rec.program_update_date||':');
	oe_debug_pub.ADD('qualifier_attribute	:'||l_QUALIFIERS_rec.qualifier_attribute||':'||p_QUALIFIERS_rec.qualifier_attribute||':');
	oe_debug_pub.ADD('qualifier_attr_value	:'||l_QUALIFIERS_rec.qualifier_attr_value||':'||p_QUALIFIERS_rec.qualifier_attr_value||':');
	oe_debug_pub.ADD('qualifier_attr_value_to:'||l_QUALIFIERS_rec.qualifier_attr_value_to||':'||p_QUALIFIERS_rec.qualifier_attr_value_to||':');
	oe_debug_pub.ADD('qualifier_context	:'||l_QUALIFIERS_rec.qualifier_context||':'||p_QUALIFIERS_rec.qualifier_context||':');
	oe_debug_pub.ADD('qualifier_datatype	:'||l_QUALIFIERS_rec.qualifier_datatype||':'||p_QUALIFIERS_rec.qualifier_datatype||':');
	oe_debug_pub.ADD('qualifier_grouping_no	:'||l_QUALIFIERS_rec.qualifier_grouping_no||':'||p_QUALIFIERS_rec.qualifier_grouping_no||':');
	oe_debug_pub.ADD('qualifier_id		:'||l_QUALIFIERS_rec.qualifier_id||':'||p_QUALIFIERS_rec.qualifier_id||':');
	oe_debug_pub.ADD('qualifier_precedence	:'||l_QUALIFIERS_rec.qualifier_precedence||':'||p_QUALIFIERS_rec.qualifier_precedence||':');
	oe_debug_pub.ADD('qualifier_rule_id	:'||l_QUALIFIERS_rec.qualifier_rule_id||':'||p_QUALIFIERS_rec.qualifier_rule_id||':');
	oe_debug_pub.ADD('request_id		:'||l_QUALIFIERS_rec.request_id||':'||p_QUALIFIERS_rec.request_id||':');
	oe_debug_pub.ADD('start_date_active	:'||l_QUALIFIERS_rec.start_date_active||':'||p_QUALIFIERS_rec.start_date_active||':');
	oe_debug_pub.ADD('-------------------Data compare in price list line qualifier end------------------');
	--  Row has changed by another user.
	--End 8594682 - Add debug messages for OE_LOCK error

        --  Row has changed by another user.
        oe_debug_pub.add('row changed');

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_LOCK_ROW_CHANGED');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            oe_debug_pub.add('row deleted');
            FND_MESSAGE.SET_NAME('QP','QP_LOCK_ROW_DELETED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

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
(   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
,   p_old_QUALIFIERS_rec            IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_REC
) RETURN QP_Qualifier_Rules_PUB.Qualifiers_Val_Rec_Type
IS
l_QUALIFIERS_val_rec          QP_Qualifier_Rules_PUB.Qualifiers_Val_Rec_Type;
BEGIN

    /*IF p_QUALIFIERS_rec.comparison_operator_code IS NOT NULL AND
        p_QUALIFIERS_rec.comparison_operator_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.comparison_operator_code,
        p_old_QUALIFIERS_rec.comparison_operator_code)
    THEN
        l_QUALIFIERS_val_rec.comparison_operator := QP_Id_To_Value.Comparison_Operator
        (   p_comparison_operator_code    => p_QUALIFIERS_rec.comparison_operator_code
        );
    END IF;*/

    IF p_QUALIFIERS_rec.created_from_rule_id IS NOT NULL AND
        p_QUALIFIERS_rec.created_from_rule_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.created_from_rule_id,
        p_old_QUALIFIERS_rec.created_from_rule_id)
    THEN
        l_QUALIFIERS_val_rec.created_from_rule := QP_Id_To_Value.Created_From_Rule
        (   p_created_from_rule_id        => p_QUALIFIERS_rec.created_from_rule_id
        );
    END IF;

   /* IF p_QUALIFIERS_rec.excluder_flag IS NOT NULL AND
        p_QUALIFIERS_rec.excluder_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.excluder_flag,
        p_old_QUALIFIERS_rec.excluder_flag)
    THEN
        l_QUALIFIERS_val_rec.excluder := QP_Id_To_Value.Excluder
        (   p_excluder_flag               => p_QUALIFIERS_rec.excluder_flag
        );
    END IF;*/

    IF p_QUALIFIERS_rec.list_header_id IS NOT NULL AND
        p_QUALIFIERS_rec.list_header_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.list_header_id,
        p_old_QUALIFIERS_rec.list_header_id)
    THEN
        l_QUALIFIERS_val_rec.list_header := QP_Id_To_Value.List_Header
        (   p_list_header_id              => p_QUALIFIERS_rec.list_header_id
        );
    END IF;

    IF p_QUALIFIERS_rec.list_line_id IS NOT NULL AND
        p_QUALIFIERS_rec.list_line_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.list_line_id,
        p_old_QUALIFIERS_rec.list_line_id)
    THEN
        l_QUALIFIERS_val_rec.list_line := QP_Id_To_Value.List_Line
        (   p_list_line_id                => p_QUALIFIERS_rec.list_line_id
        );
    END IF;

    /*IF p_QUALIFIERS_rec.qualifier_id IS NOT NULL AND
        p_QUALIFIERS_rec.qualifier_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_id,
        p_old_QUALIFIERS_rec.qualifier_id)
    THEN
        l_QUALIFIERS_val_rec.qualifier := QP_Id_To_Value.Qualifier
        (   p_qualifier_id                => p_QUALIFIERS_rec.qualifier_id
        );
    END IF;*/

    IF p_QUALIFIERS_rec.qualifier_rule_id IS NOT NULL AND
        p_QUALIFIERS_rec.qualifier_rule_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_rule_id,
        p_old_QUALIFIERS_rec.qualifier_rule_id)
    THEN
        l_QUALIFIERS_val_rec.qualifier_rule := QP_Id_To_Value.Qualifier_Rule
        (   p_qualifier_rule_id           => p_QUALIFIERS_rec.qualifier_rule_id
        );
    END IF;

    RETURN l_QUALIFIERS_val_rec;

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
,   p_QUALIFIERS_val_rec            IN  QP_Qualifier_Rules_PUB.Qualifiers_Val_Rec_Type
) RETURN QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
IS
l_QUALIFIERS_rec              QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
BEGIN

    --  initialize  return_status.

    l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_QUALIFIERS_rec.

    l_QUALIFIERS_rec := p_QUALIFIERS_rec;

/*    IF  p_QUALIFIERS_val_rec.comparison_operator <> FND_API.G_MISS_CHAR
    THEN

        IF p_QUALIFIERS_rec.comparison_operator_code <> FND_API.G_MISS_CHAR THEN

            l_QUALIFIERS_rec.comparison_operator_code := p_QUALIFIERS_rec.comparison_operator_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','comparison_operator');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_QUALIFIERS_rec.comparison_operator_code := QP_Value_To_Id.comparison_operator
            (   p_comparison_operator         => p_QUALIFIERS_val_rec.comparison_operator
            );

            IF l_QUALIFIERS_rec.comparison_operator_code = FND_API.G_MISS_CHAR THEN
                l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;*/

    IF  p_QUALIFIERS_val_rec.created_from_rule <> FND_API.G_MISS_CHAR
    THEN

        IF p_QUALIFIERS_rec.created_from_rule_id <> FND_API.G_MISS_NUM THEN

            l_QUALIFIERS_rec.created_from_rule_id := p_QUALIFIERS_rec.created_from_rule_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','created_from_rule');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_QUALIFIERS_rec.created_from_rule_id := QP_Value_To_Id.created_from_rule
            (   p_created_from_rule           => p_QUALIFIERS_val_rec.created_from_rule
            );

            IF l_QUALIFIERS_rec.created_from_rule_id = FND_API.G_MISS_NUM THEN
                l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

 /*   IF  p_QUALIFIERS_val_rec.excluder <> FND_API.G_MISS_CHAR
    THEN

        IF p_QUALIFIERS_rec.excluder_flag <> FND_API.G_MISS_CHAR THEN

            l_QUALIFIERS_rec.excluder_flag := p_QUALIFIERS_rec.excluder_flag;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','excluder');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_QUALIFIERS_rec.excluder_flag := QP_Value_To_Id.excluder
            (   p_excluder                    => p_QUALIFIERS_val_rec.excluder
            );

            IF l_QUALIFIERS_rec.excluder_flag = FND_API.G_MISS_CHAR THEN
                l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;*/

    IF  p_QUALIFIERS_val_rec.list_header <> FND_API.G_MISS_CHAR
    THEN

        IF p_QUALIFIERS_rec.list_header_id <> FND_API.G_MISS_NUM THEN

            l_QUALIFIERS_rec.list_header_id := p_QUALIFIERS_rec.list_header_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_header');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_QUALIFIERS_rec.list_header_id := QP_Value_To_Id.list_header
            (   p_list_header                 => p_QUALIFIERS_val_rec.list_header
            );

            IF l_QUALIFIERS_rec.list_header_id = FND_API.G_MISS_NUM THEN
                l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_QUALIFIERS_val_rec.list_line <> FND_API.G_MISS_CHAR
    THEN

        IF p_QUALIFIERS_rec.list_line_id <> FND_API.G_MISS_NUM THEN

            l_QUALIFIERS_rec.list_line_id := p_QUALIFIERS_rec.list_line_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_line');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_QUALIFIERS_rec.list_line_id := QP_Value_To_Id.list_line
            (   p_list_line                   => p_QUALIFIERS_val_rec.list_line
            );

            IF l_QUALIFIERS_rec.list_line_id = FND_API.G_MISS_NUM THEN
                l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

  /*  IF  p_QUALIFIERS_val_rec.qualifier <> FND_API.G_MISS_CHAR
    THEN

        IF p_QUALIFIERS_rec.qualifier_id <> FND_API.G_MISS_NUM THEN

            l_QUALIFIERS_rec.qualifier_id := p_QUALIFIERS_rec.qualifier_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_QUALIFIERS_rec.qualifier_id := QP_Value_To_Id.qualifier
            (   p_qualifier                   => p_QUALIFIERS_val_rec.qualifier
            );

            IF l_QUALIFIERS_rec.qualifier_id = FND_API.G_MISS_NUM THEN
                l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;*/

    IF  p_QUALIFIERS_val_rec.qualifier_rule <> FND_API.G_MISS_CHAR
    THEN

        IF p_QUALIFIERS_rec.qualifier_rule_id <> FND_API.G_MISS_NUM THEN

            l_QUALIFIERS_rec.qualifier_rule_id := p_QUALIFIERS_rec.qualifier_rule_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_rule');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_QUALIFIERS_rec.qualifier_rule_id := QP_Value_To_Id.qualifier_rule
            (   p_qualifier_rule              => p_QUALIFIERS_val_rec.qualifier_rule
            );

            IF l_QUALIFIERS_rec.qualifier_rule_id = FND_API.G_MISS_NUM THEN
                l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

/**************************************************************************
Added code for value_to_id conversion for qualifier_attribute,
qualifier_attr_value and qualifier_attr_value_to
***************************************************************************/

    IF  p_QUALIFIERS_val_rec.qualifier_attribute_desc <> FND_API.G_MISS_CHAR
    THEN

        IF p_QUALIFIERS_rec.qualifier_attribute <> FND_API.G_MISS_CHAR THEN

            l_QUALIFIERS_rec.qualifier_attribute := p_QUALIFIERS_rec.qualifier_attribute;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_attribute');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_QUALIFIERS_rec.qualifier_attribute := QP_Value_To_Id.qualifier_attribute
            (   p_qualifier_attribute_desc              => p_QUALIFIERS_val_rec.qualifier_attribute_desc,
			 p_context => l_QUALIFIERS_rec.qualifier_context
            );

            IF l_QUALIFIERS_rec.qualifier_attribute = FND_API.G_MISS_CHAR THEN
                l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_QUALIFIERS_val_rec.qualifier_attr_value_desc <> FND_API.G_MISS_CHAR
    THEN

        IF p_QUALIFIERS_rec.qualifier_attr_value <> FND_API.G_MISS_CHAR THEN

            l_QUALIFIERS_rec.qualifier_attr_value := p_QUALIFIERS_rec.qualifier_attr_value;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_attr_value');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_QUALIFIERS_rec.qualifier_attr_value := QP_Value_To_Id.qualifier_attr_value
            ( p_qualifier_attr_value_desc  => p_QUALIFIERS_val_rec.qualifier_attr_value_desc,
		    p_context => l_QUALIFIERS_rec.qualifier_context,
		    p_attribute => l_QUALIFIERS_rec.qualifier_attribute
            );

            IF l_QUALIFIERS_rec.qualifier_attr_value = FND_API.G_MISS_CHAR THEN
                l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_QUALIFIERS_val_rec.qualifier_attr_value_to_desc <> FND_API.G_MISS_CHAR
    THEN

        IF p_QUALIFIERS_rec.qualifier_attr_value_to <> FND_API.G_MISS_CHAR THEN

            l_QUALIFIERS_rec.qualifier_attr_value_to := p_QUALIFIERS_rec.qualifier_attr_value_to;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_attr_value_to');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_QUALIFIERS_rec.qualifier_attr_value_to := QP_Value_To_Id.qualifier_attr_value_to
            (   p_qualifier_attr_value_to_desc  => p_QUALIFIERS_val_rec.qualifier_attr_value_to_desc,
		    p_context => l_QUALIFIERS_rec.qualifier_context,
		    p_attribute => l_QUALIFIERS_rec.qualifier_attribute
            );

            IF l_QUALIFIERS_rec.qualifier_attr_value_to = FND_API.G_MISS_CHAR THEN
                l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    RETURN l_QUALIFIERS_rec;

END Get_Ids;

Procedure Pre_Write_Process
(   p_QUALIFIERS_rec                      IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
,   p_old_QUALIFIERS_rec                  IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type :=
						QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_REC
,   x_QUALIFIERS_rec                      OUT NOCOPY /* file.sql.39 change */  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
) IS
l_QUALIFIERS_rec              QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type := p_QUALIFIERS_rec;
l_return_status       varchar2(30);
l_hlq_count           NUMBER := 0;
		   --Header Level Qualifier Count
l_llq_count           NUMBER := 0;
		   --Line Level Qualifier Count
l_list_type_code      VARCHAR2(30);
l_denormalize_qual  varchar2(1) := nvl(fnd_profile.value('QP_DENORMALIZE_QUALIFIERS'),'Y');
                       --7120399

BEGIN

  oe_debug_pub.Add('Entering OE_QUALIFIERS_Util.pre_write_process');
  oe_debug_pub.Add('mkarya - p_QUALIFIERS_rec.operation = ' ||p_QUALIFIERS_rec.operation);


  x_QUALIFIERS_rec := l_QUALIFIERS_rec;

  IF   ( p_QUALIFIERS_rec.operation IN (QP_GLOBALS.G_OPR_CREATE,
								QP_GLOBALS.G_OPR_DELETE) ) THEN
    -- Get the List Type Code
    BEGIN
      SELECT list_type_code
      INTO   l_list_type_code
      FROM   qp_list_headers_vl
      WHERE  list_header_id = p_QUALIFIERS_rec.list_header_id;
    EXCEPTION
	 WHEN OTHERS THEN
	   NULL;
    END;

    -- Get the List Header Level Qualifier count
    IF l_list_type_code IN ('PRL', 'AGR') THEN
    BEGIN
	 /*SELECT 1
	 INTO   l_hlq_count
         FROM DUAL
         WHERE EXISTS (SELECT 'X'
	               FROM   qp_qualifiers
	               WHERE  list_header_id = p_QUALIFIERS_rec.list_header_id
	               AND    list_line_id = -1
	               AND    NOT (qualifier_context = 'MODLIST' AND
			   qualifier_attribute = 'QUALIFIER_ATTRIBUTE4'));*/

	/* changed the sql query from where exists to 'and rownum=1'*/

         SELECT 1 into l_hlq_count
	               FROM   qp_qualifiers
	               WHERE  list_header_id = p_QUALIFIERS_rec.list_header_id
	               AND    list_line_id = -1
	               AND    NOT (qualifier_context = 'MODLIST' AND qualifier_attribute = 'QUALIFIER_ATTRIBUTE4')
			       and rownum=1;
            --Do not consider qualifiers corresponding to Primary PL as
		  --qualifier for Secondary PL
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
        l_hlq_count := 0;
    END;

    ELSE -- All other list type codes
    BEGIN
      /*SELECT 1
      INTO   l_hlq_count
      FROM DUAL
      WHERE EXISTS (SELECT 'X'
                    FROM   qp_qualifiers
                    WHERE  list_header_id = p_QUALIFIERS_rec.list_header_id
                    AND    list_line_id = -1);  */

	/* changed the sql query from where exists to 'and rownum=1'*/
      SELECT 1 into l_hlq_count
                    FROM   qp_qualifiers
                    WHERE  list_header_id = p_QUALIFIERS_rec.list_header_id
                    AND    list_line_id = -1
					and rownum = 1;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
        l_hlq_count := 0;
    END;

    END IF; -- list type code is PRL or AGR


    -- Get the List Line Level Qualifier count
    BEGIN
/*    SELECT 1 INTO l_llq_count
    FROM DUAL
    WHERE EXISTS ( SELECT 'X'
                   FROM   qp_qualifiers
                   WHERE  list_line_id = p_QUALIFIERS_rec.list_line_id);*/

	/* changed the sql query from where exists to 'and rownum=1'*/
    SELECT 1 into l_llq_count
                   FROM   qp_qualifiers
                   WHERE  list_line_id = p_QUALIFIERS_rec.list_line_id
				   and rownum=1;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
        l_llq_count := 0;
    END;

    --Submit a Header Level Delayed Request to update qualification_ind
    --while creating the first or deleting the last header level qualifier.
    IF  (p_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_CREATE  AND
	    p_QUALIFIERS_rec.list_line_id = -1                    AND
         l_hlq_count = 0)  OR
	   (p_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_DELETE  AND
	    p_QUALIFIERS_rec.list_line_id = -1                    AND
         l_hlq_count = 1)
    THEN

       /* Bug 4191955 No need to log delayed request to update header qualification indicator
          for secondary price list */

       		IF NOT (l_list_type_code = 'PRL' and p_QUALIFIERS_rec.qualifier_context='MODLIST'
                          and p_QUALIFIERS_rec.qualifier_attribute='QUALIFIER_ATTRIBUTE4') THEN

        		qp_delayed_requests_PVT.log_request(
                 	p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
   	            	p_entity_id  => p_QUALIFIERS_rec.list_header_id,
                 	p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_ALL,
                 	p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
                 	p_request_type =>QP_GLOBALS.G_UPDATE_LIST_QUAL_IND,
                 	x_return_status => l_return_status);
                 END IF;

            IF l_list_type_code NOT IN ('PRL', 'AGR') THEN

      oe_debug_pub.add('log delayed request------------');

               qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
                 p_param1 => p_QUALIFIERS_rec.list_header_id,
   	            p_entity_id  => p_QUALIFIERS_rec.qualifier_id,
                 p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_ALL,
                 p_requesting_entity_id => p_QUALIFIERS_rec.qualifier_id,
                 p_request_type =>QP_GLOBALS.G_MAINTAIN_LIST_HEADER_PHASES,
                 x_return_status => l_return_status);

             END IF;

    --Submit a Line Level Delayed Request to update qualification_ind
    --while creating the first or deleting the last line level qualifier.
    ELSIF (p_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_CREATE  AND
	      p_QUALIFIERS_rec.list_line_id <> -1                   AND
           l_llq_count = 0) OR
		(p_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_DELETE  AND
	      p_QUALIFIERS_rec.list_line_id <> -1                   AND
           l_llq_count = 1)
    THEN
         qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
   	            p_entity_id  => p_QUALIFIERS_rec.list_line_id,
                 p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_ALL,
                 p_requesting_entity_id => p_QUALIFIERS_rec.list_line_id,
                 p_request_type =>QP_GLOBALS.G_UPDATE_LINE_QUAL_IND,
                 x_return_status => l_return_status);

         -- mkarya for bug1769955 - log the MAINTAIN_LIST_HEADER_PHASES request for line qualifier
         IF l_list_type_code NOT IN ('PRL', 'AGR') THEN
            qp_delayed_requests_PVT.log_request(
              p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
              p_param1 => p_QUALIFIERS_rec.list_header_id,
   	      p_entity_id  => p_QUALIFIERS_rec.qualifier_id,
              p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_ALL,
              p_requesting_entity_id => p_QUALIFIERS_rec.qualifier_id,
              p_request_type =>QP_GLOBALS.G_MAINTAIN_LIST_HEADER_PHASES,
              x_return_status => l_return_status);
         END IF;

    END IF;

  END IF; -- If operation is create or delete.

/*  Added for 7120399 */
if p_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_UPDATE then

    BEGIN
      SELECT list_type_code
      INTO   l_list_type_code
      FROM   qp_list_headers_vl
      WHERE  list_header_id = p_QUALIFIERS_rec.list_header_id;
    EXCEPTION
	 WHEN OTHERS THEN
	   NULL;
    END;
end if;

  IF p_QUALIFIERS_rec.operation IN (QP_GLOBALS.G_OPR_CREATE,
				    QP_GLOBALS.G_OPR_UPDATE,
				    QP_GLOBALS.G_OPR_DELETE) THEN
IF (l_list_type_code in ('PRL','AGR')) OR ((l_list_type_code NOT IN ('PRL','AGR')) AND (l_denormalize_qual= 'Y')) then   --7120399

         qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
   	         p_entity_id  => p_QUALIFIERS_rec.list_header_id,
                 p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_ALL,
                 p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
                 p_request_type => QP_GLOBALS.G_MAINTAIN_QUALIFIER_DEN_COLS,
                 x_return_status => l_return_status);
END IF;
         --Added following delayed request for Attributes Manager
         qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
   	         p_entity_id  => p_QUALIFIERS_rec.qualifier_id,
                 p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_ALL,
                 p_requesting_entity_id => p_QUALIFIERS_rec.qualifier_id,
                 p_request_type => QP_GLOBALS.G_MIXED_QUAL_SEG_LEVELS,
                 p_param1 => p_QUALIFIERS_rec.qualifier_rule_id,
                 x_return_status => l_return_status);

  END IF;

/*
    IF (p_QUALIFIERS_rec.operation IN
			(QP_GLOBALS.G_OPR_CREATE, QP_GLOBALS.G_OPR_UPDATE)) THEN

      oe_debug_pub.add('log delayed request--------warn_same_qual_grp');

             qp_delayed_requests_PVT.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id  => p_QUALIFIERS_rec.list_header_id,
			p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type =>QP_GLOBALS.G_WARN_SAME_QUALIFIER_GROUP,
			p_param1             => p_QUALIFIERS_rec.list_line_id,
			p_param2             => p_QUALIFIERS_rec.qualifier_grouping_no,
			p_param3             => p_QUALIFIERS_rec.qualifier_context,
			p_param4             => p_QUALIFIERS_rec.qualifier_attribute,
			x_return_status => l_return_status);

    END IF;
    */

    -- Attribute Manager Change BEGIN - required for modifiers
    -- Logging the request here instead of apply_attribute_changes because list_line_id is -1 even
    -- if qualifier is LINE level in apply_attribute_changes
    --IF ( p_QUALIFIERS_rec.operation IN (QP_GLOBALS.G_OPR_CREATE,
--								QP_GLOBALS.G_OPR_UPDATE) ) THEN
      IF qp_util.attrmgr_installed = 'Y' THEN
        IF (NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_attribute,
                                p_old_QUALIFIERS_rec.qualifier_attribute))
           OR
           (NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_grouping_no,
                            p_old_QUALIFIERS_rec.qualifier_grouping_no))
           OR (p_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_DELETE) THEN
          -- Get the List Type Code
          BEGIN
            SELECT list_type_code
              INTO   l_list_type_code
              FROM   qp_list_headers_vl
             WHERE  list_header_id = p_QUALIFIERS_rec.list_header_id;
          EXCEPTION
	       WHEN OTHERS THEN
	         NULL;
          END;
          IF l_list_type_code NOT IN ('PRL', 'AGR') THEN
            oe_debug_pub.add('list_header_id = ' || p_qualifiers_rec.list_header_id);
            oe_debug_pub.add('list_line_id = ' || p_qualifiers_rec.list_line_id);
            oe_debug_pub.add('qualifier_grouping_no = ' || p_qualifiers_rec.qualifier_grouping_no);
            qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_QUALIFIERS,
                 p_request_unique_key1 => p_qualifiers_rec.list_header_id,
                 p_request_unique_key2 => p_qualifiers_rec.qualifier_grouping_no,
                 p_entity_id  => p_qualifiers_rec.list_line_id,
                 p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_QUALIFIERS,
                 p_requesting_entity_id => p_qualifiers_rec.list_line_id,
                 p_request_type =>QP_GLOBALS.G_CHECK_SEGMENT_LEVEL_IN_GROUP,
                 x_return_status => l_return_status);

            -- mkarya for attribute manager
            -- Log a delayed request to validate that if header level qualifier exist then at least
            -- one qualifier should exist for any existence of modifier line of modifier level
            -- 'LINE' or 'ORDER'
            if p_qualifiers_rec.list_line_id = -1 then
              qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
   	         p_entity_id  => l_qualifiers_rec.list_header_id,
                 p_request_unique_key1 => -1,
                 p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_ALL,
                 p_requesting_entity_id => l_qualifiers_rec.list_header_id,
                 p_request_type =>QP_GLOBALS.G_CHECK_LINE_FOR_HEADER_QUAL,
                 x_return_status => l_return_status);
            end if;

            -- if qualifier_grouping_no is updated to -1 then log the request for all other
            -- qualifier_grouping_no for the given list_header_id and list_line_id
            if p_qualifiers_rec.qualifier_grouping_no = -1
              and p_qualifiers_rec.operation = QP_GLOBALS.G_OPR_UPDATE then
              declare
                  cursor c_qual_grp is
                 select distinct qualifier_grouping_no qualifier_grouping_no
                   from qp_qualifiers
                  where list_header_id =  p_qualifiers_rec.list_header_id
                    and list_line_id =  p_qualifiers_rec.list_line_id
                    and qualifier_grouping_no <> -1;
              begin

               for l_rec in c_qual_grp
               LOOP
                  oe_debug_pub.add('In LOOP - update of qualifier grp to -1');
                  oe_debug_pub.add('list_header_id = ' || p_qualifiers_rec.list_header_id);
                  oe_debug_pub.add('list_line_id = ' || p_qualifiers_rec.list_line_id);
                  oe_debug_pub.add('qualifier_grouping_no = ' || l_rec.qualifier_grouping_no);
                  qp_delayed_requests_PVT.log_request(
                           p_entity_code => QP_GLOBALS.G_ENTITY_QUALIFIERS,
                           p_request_unique_key1 => p_qualifiers_rec.list_header_id,
                           p_request_unique_key2 => l_rec.qualifier_grouping_no,
                           p_entity_id  => p_qualifiers_rec.list_line_id,
                           p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_QUALIFIERS,
                           p_requesting_entity_id => p_qualifiers_rec.list_line_id,
                           p_request_type =>QP_GLOBALS.G_CHECK_SEGMENT_LEVEL_IN_GROUP,
                           x_return_status => l_return_status);

               END LOOP;

              end;
            end if; -- grp_no is -1 and operation is update
           end if; -- list_type_code is for modifiers
         END IF; -- Change in either qualifier_grouping_no or qualifier_attribute
       END IF; -- Attribute Manager Installed
     --END IF; -- operation is insert or update
     -- Attribute Manager change end

--pattern

    IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'Y' THEN

      IF p_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_CREATE AND
         p_QUALIFIERS_rec.list_line_id = -1 			THEN
       -- header qualifier is added to price list/modifier
        IF p_QUALIFIERS_rec.qualifier_grouping_no = -1 THEN
	    qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_QUALIFIERS_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'I',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => l_return_status);
	ELSE
	    qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_QUALIFIERS_rec.list_header_id,
		p_request_unique_key1 => p_QUALIFIERS_rec.qualifier_grouping_no,
		p_request_unique_key2 => 'I',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => l_return_status);
	END IF;
      END IF;

      IF p_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_UPDATE AND
         p_QUALIFIERS_rec.list_line_id = -1 			THEN
       -- header qualifier is modified
           IF QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_grouping_no,
                            p_old_QUALIFIERS_rec.qualifier_grouping_no) THEN
		-- updated other than qualifier grouping number
		IF p_QUALIFIERS_rec.qualifier_grouping_no = -1 THEN
		    qp_delayed_requests_pvt.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_unique_key1 => NULL,
			p_request_unique_key2 => 'U',
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
			x_return_status => l_return_status);
		ELSE
		    qp_delayed_requests_pvt.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_unique_key1 => p_QUALIFIERS_rec.qualifier_grouping_no,
			p_request_unique_key2 => 'U',
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
			x_return_status => l_return_status);
		END IF;

	   ELSE
		-- qualifier grouping number is modified
                IF (p_QUALIFIERS_rec.qualifier_grouping_no = -1 or
                    p_old_QUALIFIERS_rec.qualifier_grouping_no = -1) THEN
		    qp_delayed_requests_pvt.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_unique_key1 => NULL,
			p_request_unique_key2 => 'U',
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
			x_return_status => l_return_status);
		ELSE
		    qp_delayed_requests_pvt.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_unique_key1 => p_old_QUALIFIERS_rec.qualifier_grouping_no,
			p_request_unique_key2 => 'U',
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
			x_return_status => l_return_status);
		    qp_delayed_requests_pvt.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_unique_key1 => p_QUALIFIERS_rec.qualifier_grouping_no,
			p_request_unique_key2 => 'U',
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
			x_return_status => l_return_status);
		END IF;
	   END IF;

      END IF;

      IF p_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_DELETE AND
         p_QUALIFIERS_rec.list_line_id = -1 			THEN
		IF p_QUALIFIERS_rec.qualifier_grouping_no = -1 then
		    qp_delayed_requests_pvt.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_unique_key1 => NULL,
			p_request_unique_key2 => 'D',
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
			x_return_status => l_return_status);
		ELSE
		    qp_delayed_requests_pvt.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_unique_key1 => p_QUALIFIERS_rec.qualifier_grouping_no,
			p_request_unique_key2 => 'D',
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
			x_return_status => l_return_status);
		END IF;

      END IF;
-- line pattern
      IF p_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_CREATE AND
         p_QUALIFIERS_rec.list_line_id <> -1 			THEN
         IF p_QUALIFIERS_rec.qualifier_grouping_no = -1 THEN
	    qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_QUALIFIERS_rec.list_header_id,
		p_request_unique_key1 => p_QUALIFIERS_rec.list_line_id,
		p_request_unique_key2 => NULL,
		p_request_unique_key3 => 'I',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_LINE_PATTERN,
		x_return_status => l_return_status);
	 ELSE
	    qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_QUALIFIERS_rec.list_header_id,
		p_request_unique_key1 => p_QUALIFIERS_rec.list_line_id,
		p_request_unique_key2 => p_QUALIFIERS_rec.qualifier_grouping_no,
		p_request_unique_key3 => 'I',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_LINE_PATTERN,
		x_return_status => l_return_status);
	 END IF;
      END IF;

      IF p_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_UPDATE AND
         p_QUALIFIERS_rec.list_line_id <> -1 			THEN
           IF QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_grouping_no,
                            p_old_QUALIFIERS_rec.qualifier_grouping_no) THEN
		IF p_QUALIFIERS_rec.qualifier_grouping_no = -1 THEN
		    qp_delayed_requests_pvt.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_unique_key1 => p_QUALIFIERS_rec.list_line_id,
			p_request_unique_key2 => NULL,
			p_request_unique_key3 => 'U',
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type => QP_GLOBALS.G_MAINTAIN_LINE_PATTERN,
			x_return_status => l_return_status);
		ELSE
		    qp_delayed_requests_pvt.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_unique_key1 => p_QUALIFIERS_rec.list_line_id,
			p_request_unique_key2 => p_QUALIFIERS_rec.qualifier_grouping_no,
			p_request_unique_key3 => 'U',
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type => QP_GLOBALS.G_MAINTAIN_LINE_PATTERN,
			x_return_status => l_return_status);
		END IF;

	   ELSE
                IF (p_QUALIFIERS_rec.qualifier_grouping_no = -1 or
                    p_old_QUALIFIERS_rec.qualifier_grouping_no = -1) THEN
		    qp_delayed_requests_pvt.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_unique_key1 => p_QUALIFIERS_rec.list_line_id,
			p_request_unique_key2 => NULL,
			p_request_unique_key3 => 'U',
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type => QP_GLOBALS.G_MAINTAIN_LINE_PATTERN,
			x_return_status => l_return_status);
		ELSE
		    qp_delayed_requests_pvt.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_unique_key1 => p_QUALIFIERS_rec.list_line_id,
			p_request_unique_key2 => p_old_QUALIFIERS_rec.qualifier_grouping_no,
			p_request_unique_key3 => 'U',
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type => QP_GLOBALS.G_MAINTAIN_LINE_PATTERN,
			x_return_status => l_return_status);
		    qp_delayed_requests_pvt.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_unique_key1 => p_QUALIFIERS_rec.list_line_id,
			p_request_unique_key2 => p_QUALIFIERS_rec.qualifier_grouping_no,
			p_request_unique_key3 => 'U',
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type => QP_GLOBALS.G_MAINTAIN_LINE_PATTERN,
			x_return_status => l_return_status);
		END IF;
	   END IF;

      END IF;

      IF p_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_DELETE AND
         p_QUALIFIERS_rec.list_line_id <> -1 			THEN
		IF p_QUALIFIERS_rec.qualifier_grouping_no = -1 THEN
		    qp_delayed_requests_pvt.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_unique_key1 => p_QUALIFIERS_rec.list_line_id,
			p_request_unique_key2 => NULL,
			p_request_unique_key3 => 'D',
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type => QP_GLOBALS.G_MAINTAIN_LINE_PATTERN,
			x_return_status => l_return_status);
		ELSE
		    qp_delayed_requests_pvt.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_unique_key1 => p_QUALIFIERS_rec.list_line_id,
			p_request_unique_key2 => p_QUALIFIERS_rec.qualifier_grouping_no,
			p_request_unique_key3 => 'D',
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type => QP_GLOBALS.G_MAINTAIN_LINE_PATTERN,
			x_return_status => l_return_status);
		END IF;

      END IF;

    END IF; --Java Engine Installed
--pattern
-- jagan's PL/SQL pattern
 IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
   IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'M' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'P' THEN

      IF p_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_CREATE AND
         p_QUALIFIERS_rec.list_line_id = -1 			THEN
       -- header qualifier is added to price list/modifier
        IF p_QUALIFIERS_rec.qualifier_grouping_no = -1 THEN
	    qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_QUALIFIERS_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'I',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => l_return_status);
	ELSE
	    qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_QUALIFIERS_rec.list_header_id,
		p_request_unique_key1 => p_QUALIFIERS_rec.qualifier_grouping_no,
		p_request_unique_key2 => 'I',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => l_return_status);
	END IF;
      END IF;
      IF p_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_UPDATE AND
         p_QUALIFIERS_rec.list_line_id = -1 			THEN
       -- header qualifier is modified
           IF QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_grouping_no,
                            p_old_QUALIFIERS_rec.qualifier_grouping_no) THEN
		-- updated other than qualifier grouping number
		IF p_QUALIFIERS_rec.qualifier_grouping_no = -1 THEN
		    qp_delayed_requests_pvt.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_unique_key1 => NULL,
			p_request_unique_key2 => 'U',
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
			x_return_status => l_return_status);
		ELSE
		    qp_delayed_requests_pvt.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_unique_key1 => p_QUALIFIERS_rec.qualifier_grouping_no,
			p_request_unique_key2 => 'U',
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
			x_return_status => l_return_status);
		END IF;
	   ELSE
		-- qualifier grouping number is modified
                IF (p_QUALIFIERS_rec.qualifier_grouping_no = -1 or
                    p_old_QUALIFIERS_rec.qualifier_grouping_no = -1) THEN
		    qp_delayed_requests_pvt.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_unique_key1 => NULL,
			p_request_unique_key2 => 'U',
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
			x_return_status => l_return_status);
		ELSE
		    qp_delayed_requests_pvt.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_unique_key1 => p_old_QUALIFIERS_rec.qualifier_grouping_no,
			p_request_unique_key2 => 'U',
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
			x_return_status => l_return_status);
		    qp_delayed_requests_pvt.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_unique_key1 => p_QUALIFIERS_rec.qualifier_grouping_no,
			p_request_unique_key2 => 'U',
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
			x_return_status => l_return_status);
		END IF;
	   END IF;

      END IF;
      IF p_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_DELETE AND
         p_QUALIFIERS_rec.list_line_id = -1 			THEN
		IF p_QUALIFIERS_rec.qualifier_grouping_no = -1 then
		    qp_delayed_requests_pvt.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_unique_key1 => NULL,
			p_request_unique_key2 => 'D',
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
			x_return_status => l_return_status);
		ELSE
		    qp_delayed_requests_pvt.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_unique_key1 => p_QUALIFIERS_rec.qualifier_grouping_no,
			p_request_unique_key2 => 'D',
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
			x_return_status => l_return_status);
		END IF;
      END IF;
-- line pattern
      IF p_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_CREATE AND
         p_QUALIFIERS_rec.list_line_id <> -1 			THEN
         IF p_QUALIFIERS_rec.qualifier_grouping_no = -1 THEN
	    qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_QUALIFIERS_rec.list_header_id,
		p_request_unique_key1 => p_QUALIFIERS_rec.list_line_id,
		p_request_unique_key2 => NULL,
		p_request_unique_key3 => 'I',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_LINE_PATTERN,
		x_return_status => l_return_status);
	 ELSE
	    qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_QUALIFIERS_rec.list_header_id,
		p_request_unique_key1 => p_QUALIFIERS_rec.list_line_id,
		p_request_unique_key2 => p_QUALIFIERS_rec.qualifier_grouping_no,
		p_request_unique_key3 => 'I',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_LINE_PATTERN,
		x_return_status => l_return_status);
	 END IF;
      END IF;
      IF p_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_UPDATE AND
         p_QUALIFIERS_rec.list_line_id <> -1 			THEN
           IF QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_grouping_no,
                            p_old_QUALIFIERS_rec.qualifier_grouping_no) THEN
		IF p_QUALIFIERS_rec.qualifier_grouping_no = -1 THEN
		    qp_delayed_requests_pvt.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_unique_key1 => p_QUALIFIERS_rec.list_line_id,
			p_request_unique_key2 => NULL,
			p_request_unique_key3 => 'U',
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type => QP_GLOBALS.G_MAINTAIN_LINE_PATTERN,
			x_return_status => l_return_status);
		ELSE
		    qp_delayed_requests_pvt.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_unique_key1 => p_QUALIFIERS_rec.list_line_id,
			p_request_unique_key2 => p_QUALIFIERS_rec.qualifier_grouping_no,
			p_request_unique_key3 => 'U',
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type => QP_GLOBALS.G_MAINTAIN_LINE_PATTERN,
			x_return_status => l_return_status);
		END IF;
	   ELSE
                IF (p_QUALIFIERS_rec.qualifier_grouping_no = -1 or
                    p_old_QUALIFIERS_rec.qualifier_grouping_no = -1) THEN
		    qp_delayed_requests_pvt.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_unique_key1 => p_QUALIFIERS_rec.list_line_id,
			p_request_unique_key2 => NULL,
			p_request_unique_key3 => 'U',
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type => QP_GLOBALS.G_MAINTAIN_LINE_PATTERN,
			x_return_status => l_return_status);
		ELSE
		    qp_delayed_requests_pvt.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_unique_key1 => p_QUALIFIERS_rec.list_line_id,
			p_request_unique_key2 => p_old_QUALIFIERS_rec.qualifier_grouping_no,
			p_request_unique_key3 => 'U',
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type => QP_GLOBALS.G_MAINTAIN_LINE_PATTERN,
			x_return_status => l_return_status);
		    qp_delayed_requests_pvt.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_unique_key1 => p_QUALIFIERS_rec.list_line_id,
			p_request_unique_key2 => p_QUALIFIERS_rec.qualifier_grouping_no,
			p_request_unique_key3 => 'U',
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type => QP_GLOBALS.G_MAINTAIN_LINE_PATTERN,
			x_return_status => l_return_status);
		END IF;
	   END IF;

      END IF;
      IF p_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_DELETE AND
         p_QUALIFIERS_rec.list_line_id <> -1 			THEN
		IF p_QUALIFIERS_rec.qualifier_grouping_no = -1 THEN
		    qp_delayed_requests_pvt.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_unique_key1 => p_QUALIFIERS_rec.list_line_id,
			p_request_unique_key2 => NULL,
			p_request_unique_key3 => 'D',
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type => QP_GLOBALS.G_MAINTAIN_LINE_PATTERN,
			x_return_status => l_return_status);
		ELSE
		    qp_delayed_requests_pvt.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_unique_key1 => p_QUALIFIERS_rec.list_line_id,
			p_request_unique_key2 => p_QUALIFIERS_rec.qualifier_grouping_no,
			p_request_unique_key3 => 'D',
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id => p_QUALIFIERS_rec.list_header_id,
			p_request_type => QP_GLOBALS.G_MAINTAIN_LINE_PATTERN,
			x_return_status => l_return_status);
		END IF;

      END IF;

    END IF; --Java Engine Installed
   END IF;  -- PL/SQL pattern search enabled

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        RAISE;
    WHEN OTHERS THEN
        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pre_Write_Process'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Pre_Write_Process;

END QP_Qualifiers_Util;

/
