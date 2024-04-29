--------------------------------------------------------
--  DDL for Package Body QP_SEG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_SEG_UTIL" AS
/* $Header: QPXUSEGB.pls 120.2 2005/08/03 07:36:58 srashmi noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Seg_Util';

--  Procedure Clear_Dependent_Attr

PROCEDURE p_compile_flexfields(p_segment_mapping_column in varchar2)
-- Addded by Abhijit , based on new APIs provided by AOL.(08/07/2002)
-- Private procedure to set session,freeze,enable and compile flexfields.
is
  req_id    number;
  request_id    number;
begin
     fnd_flex_dsc_api.set_session_mode('customer_data');
     --
     -- Enabling column.
     fnd_flex_dsc_api.enable_columns(APPL_SHORT_NAME =>'QP',
                                     FLEXFIELD_NAME =>'QP_ATTR_DEFNS_PRICING',
                                     PATTERN => p_segment_mapping_column);
     -- Freezing the flexfield.
     fnd_flex_dsc_api.freeze(APPL_SHORT_NAME =>'QP',
                             FLEXFIELD_NAME =>'QP_ATTR_DEFNS_PRICING');
     --
     -- Compiling the Flexfield.
     commit;
     req_id := fnd_request.submit_request
           (application => 'FND',
            program    => 'FDFCMPD',
            description => ('fdfcmp(D,' ||
                            'QP' || ',' ||
                            'QP_ATTR_DEFNS_PRICING' || ')'),
            start_time  => NULL,
            sub_request => FALSE,
            argument1  => 'D',
            argument2  => 'QP',
            argument3  => 'QP_ATTR_DEFNS_PRICING');

     req_id := fnd_request.submit_request
           (application => 'FND',
            program    => 'FDFVGN',
            description => ('fdfvgn(3,' ||
                            '661' || ',' ||
                            'QP_ATTR_DEFNS_PRICING' || ')'),
            start_time  => NULL,
            sub_request => FALSE,
            argument1  => '3',
            argument2  => '661',
            argument3  => 'QP_ATTR_DEFNS_PRICING');
    /*request_id := submit_cp_request(p_application_short_name  => 'FND',
                                               p_concurrent_program_name => 'FDFVGN',
                                               px_description            => l_description,
                                               p_argument1               => '3',
                                               p_argument2               => 661
                                               p_argument3               => 'QP_ATTR_DEFNS_V'
					)*/
end;
--
PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_SEG_rec                       IN  QP_Attributes_PUB.Seg_Rec_Type
,   p_old_SEG_rec                   IN  QP_Attributes_PUB.Seg_Rec_Type :=
                                        QP_Attributes_PUB.G_MISS_SEG_REC
,   x_SEG_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Seg_Rec_Type
)
IS
l_index                       NUMBER := 0;
l_src_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
BEGIN

    --  Load out record

    x_SEG_rec := p_SEG_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute1,p_old_SEG_rec.attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute10,p_old_SEG_rec.attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute11,p_old_SEG_rec.attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute12,p_old_SEG_rec.attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute13,p_old_SEG_rec.attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute14,p_old_SEG_rec.attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute15,p_old_SEG_rec.attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute2,p_old_SEG_rec.attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute3,p_old_SEG_rec.attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute4,p_old_SEG_rec.attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute5,p_old_SEG_rec.attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute6,p_old_SEG_rec.attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute7,p_old_SEG_rec.attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute8,p_old_SEG_rec.attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute9,p_old_SEG_rec.attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.availability_in_basic,p_old_SEG_rec.availability_in_basic)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_AVAILABILITY_IN_BASIC;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.context,p_old_SEG_rec.context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.created_by,p_old_SEG_rec.created_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_CREATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.creation_date,p_old_SEG_rec.creation_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.last_updated_by,p_old_SEG_rec.last_updated_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.last_update_date,p_old_SEG_rec.last_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.last_update_login,p_old_SEG_rec.last_update_login)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.prc_context_id,p_old_SEG_rec.prc_context_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_PRC_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.program_application_id,p_old_SEG_rec.program_application_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_PROGRAM_APPLICATION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.program_id,p_old_SEG_rec.program_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_PROGRAM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.program_update_date,p_old_SEG_rec.program_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_PROGRAM_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.seeded_flag,p_old_SEG_rec.seeded_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_SEEDED;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.seeded_format_type,p_old_SEG_rec.seeded_format_type)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_SEEDED_FORMAT_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.seeded_precedence,p_old_SEG_rec.seeded_precedence)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_SEEDED_PRECEDENCE;
        END IF;


	IF NOT QP_GLOBALS.Equal( p_SEG_rec.seeded_description,p_old_SEG_rec.seeded_description)
	 THEN
             l_index := l_index + 1;
             l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_SEEDED_DESCRIPTION;
	END IF;

	IF NOT QP_GLOBALS.Equal( p_SEG_rec.user_description,p_old_SEG_rec.user_description)
	THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_USER_DESCRIPTION;
	END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.seeded_segment_name,p_old_SEG_rec.seeded_segment_name)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_SEEDED_SEGMENT_NAME;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.seeded_valueset_id,p_old_SEG_rec.seeded_valueset_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_SEEDED_VALUESET;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.segment_code,p_old_SEG_rec.segment_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_SEGMENT_code;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.segment_id,p_old_SEG_rec.segment_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_SEGMENT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.application_id,p_old_SEG_rec.application_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_APPLICATION_ID;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.segment_mapping_column,p_old_SEG_rec.segment_mapping_column)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_SEGMENT_MAPPING_COLUMN;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.user_format_type,p_old_SEG_rec.user_format_type)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_USER_FORMAT_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.user_precedence,p_old_SEG_rec.user_precedence)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_USER_PRECEDENCE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.user_segment_name,p_old_SEG_rec.user_segment_name)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_USER_SEGMENT_NAME;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.user_valueset_id,p_old_SEG_rec.user_valueset_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_USER_VALUESET;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SEG_rec.required_flag,p_old_SEG_rec.required_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_REQUIRED_FLAG;
        END IF;
      -- Added for TCA
        IF NOT QP_GLOBALS.Equal(p_SEG_rec.party_hierarchy_enabled_flag,p_old_SEG_rec.party_hierarchy_enabled_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_PARTY_HIERARCHY_ENABLED_FLAG;
        END IF;

    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_AVAILABILITY_IN_BASIC THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_AVAILABILITY_IN_BASIC;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_CONTEXT;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_CREATION_DATE;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_PRC_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_PRC_CONTEXT;
    ELSIF p_attr_id = G_PROGRAM_APPLICATION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_PROGRAM_APPLICATION;
    ELSIF p_attr_id = G_PROGRAM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_PROGRAM;
    ELSIF p_attr_id = G_PROGRAM_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_PROGRAM_UPDATE_DATE;
    ELSIF p_attr_id = G_SEEDED THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_SEEDED;
    ELSIF p_attr_id = G_SEEDED_FORMAT_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_SEEDED_FORMAT_TYPE;
    ELSIF p_attr_id = G_SEEDED_PRECEDENCE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_SEEDED_PRECEDENCE;
    ELSIF p_attr_id = G_SEEDED_SEGMENT_NAME THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_SEEDED_SEGMENT_NAME;
    ELSIF p_attr_id = G_SEEDED_VALUESET THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_SEEDED_VALUESET;
    ELSIF p_attr_id = G_SEGMENT_code THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_SEGMENT_code;
    ELSIF p_attr_id = G_SEGMENT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_SEGMENT;
    ELSIF p_attr_id = G_APPLICATION_ID THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_APPLICATION_ID;
    ELSIF p_attr_id = G_SEGMENT_MAPPING_COLUMN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_SEGMENT_MAPPING_COLUMN;
    ELSIF p_attr_id = G_USER_FORMAT_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_USER_FORMAT_TYPE;
    ELSIF p_attr_id = G_USER_PRECEDENCE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_USER_PRECEDENCE;
    ELSIF p_attr_id = G_USER_SEGMENT_NAME THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_USER_SEGMENT_NAME;
    ELSIF p_attr_id = G_USER_VALUESET THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_USER_VALUESET;
    ELSIF p_attr_id = G_SEEDED_DESCRIPTION THEN
	 l_index := l_index + 1;
         l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_SEEDED_DESCRIPTION;
    ELSIF p_attr_id = G_USER_DESCRIPTION THEN
	 l_index := l_index + 1;
         l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_USER_DESCRIPTION;
    ELSIF p_attr_id = G_REQUIRED_FLAG THEN
	 l_index := l_index + 1;
         l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_REQUIRED_FLAG;
  -- Added for TCA
    ELSIF p_attr_id = G_PARTY_HIERARCHY_ENABLED_FLAG THEN
	 l_index := l_index + 1;
         l_src_attr_tbl(l_index) := QP_SEG_UTIL.G_PARTY_HIERARCHY_ENABLED_FLAG;
    END IF;

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_SEG_rec                       IN  QP_Attributes_PUB.Seg_Rec_Type
,   p_old_SEG_rec                   IN  QP_Attributes_PUB.Seg_Rec_Type :=
                                        QP_Attributes_PUB.G_MISS_SEG_REC
,   x_SEG_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Seg_Rec_Type
)
IS
BEGIN

    --  Load out record

    x_SEG_rec := p_SEG_rec;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute1,p_old_SEG_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute10,p_old_SEG_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute11,p_old_SEG_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute12,p_old_SEG_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute13,p_old_SEG_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute14,p_old_SEG_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute15,p_old_SEG_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute2,p_old_SEG_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute3,p_old_SEG_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute4,p_old_SEG_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute5,p_old_SEG_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute6,p_old_SEG_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute7,p_old_SEG_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute8,p_old_SEG_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.attribute9,p_old_SEG_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.availability_in_basic,p_old_SEG_rec.availability_in_basic)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.context,p_old_SEG_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.created_by,p_old_SEG_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.creation_date,p_old_SEG_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.last_updated_by,p_old_SEG_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.last_update_date,p_old_SEG_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.last_update_login,p_old_SEG_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.prc_context_id,p_old_SEG_rec.prc_context_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.program_application_id,p_old_SEG_rec.program_application_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.program_id,p_old_SEG_rec.program_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.program_update_date,p_old_SEG_rec.program_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.seeded_flag,p_old_SEG_rec.seeded_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.seeded_format_type,p_old_SEG_rec.seeded_format_type)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.seeded_precedence,p_old_SEG_rec.seeded_precedence)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.seeded_segment_name,p_old_SEG_rec.seeded_segment_name)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal( p_SEG_rec.seeded_description,p_old_SEG_rec.seeded_description)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal( p_SEG_rec.user_description,p_old_SEG_rec.user_description)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.seeded_valueset_id,p_old_SEG_rec.seeded_valueset_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.segment_code,p_old_SEG_rec.segment_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.segment_id,p_old_SEG_rec.segment_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.application_id,p_old_SEG_rec.application_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.segment_mapping_column,p_old_SEG_rec.segment_mapping_column)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.user_format_type,p_old_SEG_rec.user_format_type)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.user_precedence,p_old_SEG_rec.user_precedence)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.user_segment_name,p_old_SEG_rec.user_segment_name)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.user_valueset_id,p_old_SEG_rec.user_valueset_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SEG_rec.required_flag,p_old_SEG_rec.required_flag)
    THEN
        NULL;
    END IF;
--Added for TCA
    IF NOT QP_GLOBALS.Equal(p_SEG_rec.party_hierarchy_enabled_flag,p_old_SEG_rec.party_hierarchy_enabled_flag)
    THEN
        NULL;
    END IF;
END Apply_Attribute_Changes;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_SEG_rec                       IN  QP_Attributes_PUB.Seg_Rec_Type
,   p_old_SEG_rec                   IN  QP_Attributes_PUB.Seg_Rec_Type
) RETURN QP_Attributes_PUB.Seg_Rec_Type
IS
l_SEG_rec                     QP_Attributes_PUB.Seg_Rec_Type := p_SEG_rec;
BEGIN

    IF l_SEG_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute1 := p_old_SEG_rec.attribute1;
    END IF;

    IF l_SEG_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute10 := p_old_SEG_rec.attribute10;
    END IF;

    IF l_SEG_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute11 := p_old_SEG_rec.attribute11;
    END IF;

    IF l_SEG_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute12 := p_old_SEG_rec.attribute12;
    END IF;

    IF l_SEG_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute13 := p_old_SEG_rec.attribute13;
    END IF;

    IF l_SEG_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute14 := p_old_SEG_rec.attribute14;
    END IF;

    IF l_SEG_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute15 := p_old_SEG_rec.attribute15;
    END IF;

    IF l_SEG_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute2 := p_old_SEG_rec.attribute2;
    END IF;

    IF l_SEG_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute3 := p_old_SEG_rec.attribute3;
    END IF;

    IF l_SEG_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute4 := p_old_SEG_rec.attribute4;
    END IF;

    IF l_SEG_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute5 := p_old_SEG_rec.attribute5;
    END IF;

    IF l_SEG_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute6 := p_old_SEG_rec.attribute6;
    END IF;

    IF l_SEG_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute7 := p_old_SEG_rec.attribute7;
    END IF;

    IF l_SEG_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute8 := p_old_SEG_rec.attribute8;
    END IF;

    IF l_SEG_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute9 := p_old_SEG_rec.attribute9;
    END IF;

    IF l_SEG_rec.availability_in_basic = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.availability_in_basic := p_old_SEG_rec.availability_in_basic;
    END IF;

    IF l_SEG_rec.context = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.context := p_old_SEG_rec.context;
    END IF;

    IF l_SEG_rec.created_by = FND_API.G_MISS_NUM THEN
        l_SEG_rec.created_by := p_old_SEG_rec.created_by;
    END IF;

    IF l_SEG_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_SEG_rec.creation_date := p_old_SEG_rec.creation_date;
    END IF;

    IF l_SEG_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_SEG_rec.last_updated_by := p_old_SEG_rec.last_updated_by;
    END IF;

    IF l_SEG_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_SEG_rec.last_update_date := p_old_SEG_rec.last_update_date;
    END IF;

    IF l_SEG_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_SEG_rec.last_update_login := p_old_SEG_rec.last_update_login;
    END IF;

    IF l_SEG_rec.prc_context_id = FND_API.G_MISS_NUM THEN
        l_SEG_rec.prc_context_id := p_old_SEG_rec.prc_context_id;
    END IF;

    IF l_SEG_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_SEG_rec.program_application_id := p_old_SEG_rec.program_application_id;
    END IF;

    IF l_SEG_rec.program_id = FND_API.G_MISS_NUM THEN
        l_SEG_rec.program_id := p_old_SEG_rec.program_id;
    END IF;

    IF l_SEG_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_SEG_rec.program_update_date := p_old_SEG_rec.program_update_date;
    END IF;

    IF l_SEG_rec.seeded_flag = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.seeded_flag := p_old_SEG_rec.seeded_flag;
    END IF;

    IF l_SEG_rec.seeded_format_type = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.seeded_format_type := p_old_SEG_rec.seeded_format_type;
    END IF;

    IF l_SEG_rec.seeded_precedence = FND_API.G_MISS_NUM THEN
        l_SEG_rec.seeded_precedence := p_old_SEG_rec.seeded_precedence;
    END IF;

    IF l_SEG_rec.seeded_segment_name = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.seeded_segment_name := p_old_SEG_rec.seeded_segment_name;
    END IF;

    IF l_SEG_rec.seeded_description = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.seeded_description := p_old_SEG_rec.seeded_description;
    END IF;

    IF l_SEG_rec.user_description = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.user_description := p_old_SEG_rec.user_description;
    END IF;

    IF l_SEG_rec.seeded_valueset_id = FND_API.G_MISS_NUM THEN
        l_SEG_rec.seeded_valueset_id := p_old_SEG_rec.seeded_valueset_id;
    END IF;

    IF l_SEG_rec.segment_code = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.segment_code := p_old_SEG_rec.segment_code;
    END IF;

    IF l_SEG_rec.segment_id = FND_API.G_MISS_NUM THEN
        l_SEG_rec.segment_id := p_old_SEG_rec.segment_id;
    END IF;

    IF l_SEG_rec.application_id = FND_API.G_MISS_NUM THEN
        l_SEG_rec.application_id := p_old_SEG_rec.application_id;
    END IF;

    IF l_SEG_rec.segment_mapping_column = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.segment_mapping_column := p_old_SEG_rec.segment_mapping_column;
    END IF;

    IF l_SEG_rec.user_format_type = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.user_format_type := p_old_SEG_rec.user_format_type;
    END IF;

    IF l_SEG_rec.user_precedence = FND_API.G_MISS_NUM THEN
        l_SEG_rec.user_precedence := p_old_SEG_rec.user_precedence;
    END IF;

    IF l_SEG_rec.user_segment_name = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.user_segment_name := p_old_SEG_rec.user_segment_name;
    END IF;

    IF l_SEG_rec.user_valueset_id = FND_API.G_MISS_NUM THEN
        l_SEG_rec.user_valueset_id := p_old_SEG_rec.user_valueset_id;
    END IF;

    IF l_SEG_rec.required_flag = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.required_flag := p_old_SEG_rec.required_flag;
    END IF;
-- Added for TCA
    IF l_SEG_rec.party_hierarchy_enabled_flag = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.party_hierarchy_enabled_flag := p_old_SEG_rec.party_hierarchy_enabled_flag;
    END IF;
    RETURN l_SEG_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_SEG_rec                       IN  QP_Attributes_PUB.Seg_Rec_Type
) RETURN QP_Attributes_PUB.Seg_Rec_Type
IS
l_SEG_rec                     QP_Attributes_PUB.Seg_Rec_Type := p_SEG_rec;
BEGIN

    IF l_SEG_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute1 := NULL;
    END IF;

    IF l_SEG_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute10 := NULL;
    END IF;

    IF l_SEG_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute11 := NULL;
    END IF;

    IF l_SEG_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute12 := NULL;
    END IF;

    IF l_SEG_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute13 := NULL;
    END IF;

    IF l_SEG_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute14 := NULL;
    END IF;

    IF l_SEG_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute15 := NULL;
    END IF;

    IF l_SEG_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute2 := NULL;
    END IF;

    IF l_SEG_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute3 := NULL;
    END IF;

    IF l_SEG_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute4 := NULL;
    END IF;

    IF l_SEG_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute5 := NULL;
    END IF;

    IF l_SEG_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute6 := NULL;
    END IF;

    IF l_SEG_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute7 := NULL;
    END IF;

    IF l_SEG_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute8 := NULL;
    END IF;

    IF l_SEG_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.attribute9 := NULL;
    END IF;

    IF l_SEG_rec.availability_in_basic = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.availability_in_basic := NULL;
    END IF;

    IF l_SEG_rec.context = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.context := NULL;
    END IF;

    IF l_SEG_rec.created_by = FND_API.G_MISS_NUM THEN
        l_SEG_rec.created_by := NULL;
    END IF;

    IF l_SEG_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_SEG_rec.creation_date := NULL;
    END IF;

    IF l_SEG_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_SEG_rec.last_updated_by := NULL;
    END IF;

    IF l_SEG_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_SEG_rec.last_update_date := NULL;
    END IF;

    IF l_SEG_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_SEG_rec.last_update_login := NULL;
    END IF;

    IF l_SEG_rec.prc_context_id = FND_API.G_MISS_NUM THEN
        l_SEG_rec.prc_context_id := NULL;
    END IF;

    IF l_SEG_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_SEG_rec.program_application_id := NULL;
    END IF;

    IF l_SEG_rec.program_id = FND_API.G_MISS_NUM THEN
        l_SEG_rec.program_id := NULL;
    END IF;

    IF l_SEG_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_SEG_rec.program_update_date := NULL;
    END IF;

    IF l_SEG_rec.seeded_flag = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.seeded_flag := NULL;
    END IF;

    IF l_SEG_rec.seeded_format_type = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.seeded_format_type := NULL;
    END IF;

    IF l_SEG_rec.seeded_precedence = FND_API.G_MISS_NUM THEN
        l_SEG_rec.seeded_precedence := NULL;
    END IF;

    IF l_SEG_rec.seeded_segment_name = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.seeded_segment_name := NULL;
    END IF;

    IF l_SEG_rec.seeded_description = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.seeded_description := NULL;
    END IF;

    IF l_SEG_rec.user_description = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.user_description := NULL;
    END IF;

    IF l_SEG_rec.seeded_valueset_id = FND_API.G_MISS_NUM THEN
        l_SEG_rec.seeded_valueset_id := NULL;
    END IF;

    IF l_SEG_rec.segment_code = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.segment_code := NULL;
    END IF;

    IF l_SEG_rec.segment_id = FND_API.G_MISS_NUM THEN
        l_SEG_rec.segment_id := NULL;
    END IF;

    IF l_SEG_rec.application_id = FND_API.G_MISS_NUM THEN
        l_SEG_rec.application_id := NULL;
    END IF;

    IF l_SEG_rec.segment_mapping_column = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.segment_mapping_column := NULL;
    END IF;

    IF l_SEG_rec.user_format_type = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.user_format_type := NULL;
    END IF;

    IF l_SEG_rec.user_precedence = FND_API.G_MISS_NUM THEN
        l_SEG_rec.user_precedence := NULL;
    END IF;

    IF l_SEG_rec.user_segment_name = FND_API.G_MISS_CHAR THEN
        l_SEG_rec.user_segment_name := NULL;
    END IF;

    IF l_SEG_rec.user_valueset_id = FND_API.G_MISS_NUM THEN
        l_SEG_rec.user_valueset_id := NULL;
    END IF;

    IF l_SEG_rec.required_flag = FND_API.G_MISS_CHAR THEN
	l_SEG_rec.required_flag := NULL;
    END IF;
-- Added for TCA
    IF l_SEG_rec.party_hierarchy_enabled_flag = FND_API.G_MISS_CHAR THEN
	l_SEG_rec.party_hierarchy_enabled_flag:= NULL;
    END IF;

    RETURN l_SEG_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_SEG_rec                       IN  QP_Attributes_PUB.Seg_Rec_Type
)
IS
  l_prc_context_code     varchar2(30);
  l_prc_context_type     varchar2(30);
  l_seg_flex_row         fnd_descr_flex_column_usages%rowtype;
BEGIN

    UPDATE  QP_SEGMENTS_b
    SET     ATTRIBUTE1                     = p_SEG_rec.attribute1
    ,       ATTRIBUTE10                    = p_SEG_rec.attribute10
    ,       ATTRIBUTE11                    = p_SEG_rec.attribute11
    ,       ATTRIBUTE12                    = p_SEG_rec.attribute12
    ,       ATTRIBUTE13                    = p_SEG_rec.attribute13
    ,       ATTRIBUTE14                    = p_SEG_rec.attribute14
    ,       ATTRIBUTE15                    = p_SEG_rec.attribute15
    ,       ATTRIBUTE2                     = p_SEG_rec.attribute2
    ,       ATTRIBUTE3                     = p_SEG_rec.attribute3
    ,       ATTRIBUTE4                     = p_SEG_rec.attribute4
    ,       ATTRIBUTE5                     = p_SEG_rec.attribute5
    ,       ATTRIBUTE6                     = p_SEG_rec.attribute6
    ,       ATTRIBUTE7                     = p_SEG_rec.attribute7
    ,       ATTRIBUTE8                     = p_SEG_rec.attribute8
    ,       ATTRIBUTE9                     = p_SEG_rec.attribute9
    ,       AVAILABILITY_IN_BASIC          = p_SEG_rec.availability_in_basic
    ,       CONTEXT                        = p_SEG_rec.context
    ,       CREATED_BY                     = p_SEG_rec.created_by
    ,       CREATION_DATE                  = p_SEG_rec.creation_date
    ,       LAST_UPDATED_BY                = p_SEG_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_SEG_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_SEG_rec.last_update_login
    ,       PRC_CONTEXT_ID                 = p_SEG_rec.prc_context_id
    ,       PROGRAM_APPLICATION_ID         = p_SEG_rec.program_application_id
    ,       PROGRAM_ID                     = p_SEG_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_SEG_rec.program_update_date
    ,       SEEDED_FLAG                    = p_SEG_rec.seeded_flag
    ,       SEEDED_FORMAT_TYPE             = p_SEG_rec.seeded_format_type
    ,       SEEDED_PRECEDENCE              = p_SEG_rec.seeded_precedence
    ,       SEEDED_VALUESET_ID             = p_SEG_rec.seeded_valueset_id
    ,       SEGMENT_code                   = p_SEG_rec.segment_code
    ,       SEGMENT_ID                     = p_SEG_rec.segment_id
    ,       APPLICATION_ID                 = p_SEG_rec.application_id
    ,       SEGMENT_MAPPING_COLUMN         = p_SEG_rec.segment_mapping_column
    ,       USER_FORMAT_TYPE               = p_SEG_rec.user_format_type
    ,       USER_PRECEDENCE                = p_SEG_rec.user_precedence
    ,       USER_VALUESET_ID               = p_SEG_rec.user_valueset_id
    ,       REQUIRED_FLAG  	           = p_SEG_rec.required_flag
    ,       PARTY_HIERARCHY_ENABLED_FLAG        = p_SEG_rec.party_hierarchy_enabled_flag -- Added for TCA
    WHERE   SEGMENT_ID = p_SEG_rec.segment_id ;

    UPDATE  qp_segments_tl
    SET     CREATED_BY                     = p_SEG_rec.created_by
    ,       CREATION_DATE                  = p_SEG_rec.creation_date
    ,       LAST_UPDATED_BY                = p_SEG_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_SEG_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_SEG_rec.last_update_login
    ,       seeded_segment_name            = p_SEG_rec.seeded_segment_name
    ,       user_segment_name              = p_SEG_rec.user_segment_name
    ,       seeded_description              = p_SEG_rec.seeded_description
    ,       user_description              = p_SEG_rec.user_description
    ,       SOURCE_LANG                    = userenv('LANG')
    WHERE   segment_id = p_SEG_rec.segment_id and
            userenv('LANG') in (LANGUAGE, SOURCE_LANG);
    ---
    select prc_context_type,
           prc_context_code
    into l_prc_context_type,
         l_prc_context_code
    from qp_prc_contexts_b
    where prc_context_id = p_SEG_rec.prc_context_id;
    --
    if l_prc_context_type = 'PRICING_ATTRIBUTE' then
      select *
      into l_seg_flex_row
      from fnd_descr_flex_column_usages
      where application_id = 661 and
            descriptive_flexfield_name = 'QP_ATTR_DEFNS_PRICING' and
            descriptive_flex_context_code = l_prc_context_code and
            application_column_name = p_SEG_rec.segment_mapping_column and
            rownum = 1;
      --
      FND_DESCR_FLEX_COL_USAGE_PKG.UPDATE_ROW(
        X_APPLICATION_ID => 661,
        X_DESCRIPTIVE_FLEXFIELD_NAME => 'QP_ATTR_DEFNS_PRICING',
        X_DESCRIPTIVE_FLEX_CONTEXT_COD => l_prc_context_code,
        X_APPLICATION_COLUMN_NAME => p_SEG_rec.segment_mapping_column,
        X_END_USER_COLUMN_NAME => p_SEG_rec.segment_code,
        X_COLUMN_SEQ_NUM => p_SEG_rec.user_precedence,
        X_ENABLED_FLAG => l_seg_flex_row.enabled_flag,
        X_REQUIRED_FLAG => NVL(p_SEG_rec.required_flag, 'N'),
        X_SECURITY_ENABLED_FLAG => l_seg_flex_row.security_enabled_flag,
        X_DISPLAY_FLAG => l_seg_flex_row.display_flag,
        X_DISPLAY_SIZE => l_seg_flex_row.display_size,
        X_MAXIMUM_DESCRIPTION_LEN => l_seg_flex_row.maximum_description_len,
        X_CONCATENATION_DESCRIPTION_LE => l_seg_flex_row.concatenation_description_len,
        X_FLEX_VALUE_SET_ID => p_SEG_rec.user_valueset_id,
        X_RANGE_CODE => l_seg_flex_row.range_code,
        X_DEFAULT_TYPE => l_seg_flex_row.default_type,
        X_DEFAULT_VALUE => l_seg_flex_row.default_value,
        X_RUNTIME_PROPERTY_FUNCTION => l_seg_flex_row.runtime_property_function,
        X_SRW_PARAM => l_seg_flex_row.srw_param,
        X_FORM_LEFT_PROMPT => p_SEG_rec.user_segment_name,
        X_FORM_ABOVE_PROMPT => p_SEG_rec.user_segment_name,
        X_DESCRIPTION => p_SEG_rec.user_segment_name,
        X_LAST_UPDATE_DATE => p_SEG_rec.LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY => p_SEG_rec.LAST_UPDATED_BY,
        X_LAST_UPDATE_LOGIN => p_SEG_rec.LAST_UPDATE_LOGIN);

      -- Freezing and Compiling the Flexfield.
      p_compile_flexfields(p_SEG_rec.segment_mapping_column);
      --
    end if;

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
(   p_SEG_rec                       IN  QP_Attributes_PUB.Seg_Rec_Type
)
IS
  l_row_id             varchar2(25);
  l_prc_context_type   varchar2(30);
  l_prc_context_code   varchar2(30);
  req_id               number;
  attr_in_ff_exists    varchar2(1);
  --l_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN
    select prc_context_type,
           prc_context_code
    into l_prc_context_type,
         l_prc_context_code
    from qp_prc_contexts_b
    where prc_context_id = p_SEG_rec.prc_context_id;
    --
    if l_prc_context_type = 'PRICING_ATTRIBUTE' then
      begin
         select 's'
         into attr_in_ff_exists
         from fnd_descr_flex_column_usages
         where application_id = 661 and
               descriptive_flexfield_name = 'QP_ATTR_DEFNS_PRICING' and
               descriptive_flex_context_code = l_prc_context_code and
               end_user_column_name =  p_SEG_rec.segment_code and
               rownum = 1;

          --l_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('QP','QP_ATTR_EXISTS_IN_FF');
          --FND_MESSAGE.SET_TOKEN('PTE_CODE', l_pte_code);
          OE_MSG_PUB.Add;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      exception
         when no_data_found then
              null;
      end;
    end if;
    ----
    INSERT  INTO QP_SEGMENTS_b
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
    ,       AVAILABILITY_IN_BASIC
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       PRC_CONTEXT_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       SEEDED_FLAG
    ,       SEEDED_FORMAT_TYPE
    ,       SEEDED_PRECEDENCE
    ,       SEEDED_VALUESET_ID
    ,       SEGMENT_code
    ,       SEGMENT_ID
    ,       APPLICATION_ID
    ,       SEGMENT_MAPPING_COLUMN
    ,       USER_FORMAT_TYPE
    ,       USER_PRECEDENCE
    ,       USER_VALUESET_ID
    ,	    REQUIRED_FLAG
    ,       PARTY_HIERARCHY_ENABLED_FLAG -- Added for TCA
    )
    VALUES
    (       p_SEG_rec.attribute1
    ,       p_SEG_rec.attribute10
    ,       p_SEG_rec.attribute11
    ,       p_SEG_rec.attribute12
    ,       p_SEG_rec.attribute13
    ,       p_SEG_rec.attribute14
    ,       p_SEG_rec.attribute15
    ,       p_SEG_rec.attribute2
    ,       p_SEG_rec.attribute3
    ,       p_SEG_rec.attribute4
    ,       p_SEG_rec.attribute5
    ,       p_SEG_rec.attribute6
    ,       p_SEG_rec.attribute7
    ,       p_SEG_rec.attribute8
    ,       p_SEG_rec.attribute9
    ,       p_SEG_rec.availability_in_basic
    ,       p_SEG_rec.context
    ,       p_SEG_rec.created_by
    ,       p_SEG_rec.creation_date
    ,       p_SEG_rec.last_updated_by
    ,       p_SEG_rec.last_update_date
    ,       p_SEG_rec.last_update_login
    ,       p_SEG_rec.prc_context_id
    ,       p_SEG_rec.program_application_id
    ,       p_SEG_rec.program_id
    ,       p_SEG_rec.program_update_date
    ,       p_SEG_rec.seeded_flag
    ,       p_SEG_rec.seeded_format_type
    ,       p_SEG_rec.seeded_precedence
    ,       p_SEG_rec.seeded_valueset_id
    ,       p_SEG_rec.segment_code
    ,       p_SEG_rec.segment_id
    ,       p_SEG_rec.application_id
    ,       p_SEG_rec.segment_mapping_column
    ,       p_SEG_rec.user_format_type
    ,       p_SEG_rec.user_precedence
    ,       p_SEG_rec.user_valueset_id
    ,       p_SEG_rec.required_flag
    ,       p_SEG_rec.party_hierarchy_enabled_flag   --Added for TCA
    );

    INSERT  INTO QP_segments_tl
    (       CREATED_BY
    ,       CREATION_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       segment_id
    ,       seeded_segment_name
    ,       user_segment_name
    ,       seeded_description
    ,       user_description
    ,       language
    ,       source_lang
    )
    SELECT  p_SEG_rec.created_by
    ,       p_SEG_rec.creation_date
    ,       p_SEG_rec.last_updated_by
    ,       p_SEG_rec.last_update_date
    ,       p_SEG_rec.last_update_login
    ,       p_SEG_rec.segment_id
    ,       p_SEG_rec.seeded_segment_name
    ,       p_SEG_rec.user_segment_name
    ,       p_SEG_rec.seeded_description
    ,       p_SEG_rec.user_description
    ,       L.language_code
    ,       userenv('LANG')
    from  FND_LANGUAGES  L
    where  L.INSTALLED_FLAG in ('I', 'B')
    and    not exists
           ( select NULL
             from  qp_segments_tl T
             where  T.segment_id = p_SEG_rec.segment_id
             and  T.LANGUAGE = L.LANGUAGE_CODE );
    ---
    /*
    select prc_context_type,
           prc_context_code
    into l_prc_context_type,
         l_prc_context_code
    from qp_prc_contexts_b
    where prc_context_id = p_SEG_rec.prc_context_id;
    */
    --
    if l_prc_context_type = 'PRICING_ATTRIBUTE' then
      FND_DESCR_FLEX_COL_USAGE_PKG.INSERT_ROW(
        X_ROWID => l_row_id,
        X_APPLICATION_ID => 661,
        X_DESCRIPTIVE_FLEXFIELD_NAME => 'QP_ATTR_DEFNS_PRICING',
        X_DESCRIPTIVE_FLEX_CONTEXT_COD => l_prc_context_code,
        X_APPLICATION_COLUMN_NAME => p_SEG_rec.segment_mapping_column,
        X_END_USER_COLUMN_NAME => p_SEG_rec.segment_code,
        X_COLUMN_SEQ_NUM => p_SEG_rec.user_precedence,
        X_ENABLED_FLAG => 'Y',
        X_REQUIRED_FLAG => NVL(p_SEG_rec.required_flag, 'N'),
        X_SECURITY_ENABLED_FLAG => 'N',
        X_DISPLAY_FLAG => 'Y',
        X_DISPLAY_SIZE => 35,
        X_MAXIMUM_DESCRIPTION_LEN => 50,
        X_CONCATENATION_DESCRIPTION_LE => 25,
        X_FLEX_VALUE_SET_ID => p_SEG_rec.user_valueset_id,
        X_RANGE_CODE => null,
        X_DEFAULT_TYPE => null,
        X_DEFAULT_VALUE => null,
        X_RUNTIME_PROPERTY_FUNCTION => null,
        X_SRW_PARAM => null,
        X_FORM_LEFT_PROMPT => p_SEG_rec.user_segment_name,
        X_FORM_ABOVE_PROMPT => p_SEG_rec.user_segment_name,
        X_DESCRIPTION => p_SEG_rec.user_segment_name,
        X_CREATION_DATE => p_SEG_rec.CREATION_DATE,
        X_CREATED_BY => p_SEG_rec.CREATED_BY,
        X_LAST_UPDATE_DATE => p_SEG_rec.LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY => p_SEG_rec.LAST_UPDATED_BY,
        X_LAST_UPDATE_LOGIN => p_SEG_rec.LAST_UPDATE_LOGIN);

      -- Freezing and Compiling the Flexfield.
      p_compile_flexfields(p_SEG_rec.segment_mapping_column);
      --
    end if;
    --
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
(   p_segment_id                    IN  NUMBER
)
IS
  l_prc_context_type          varchar2(30);
  l_prc_context_code          varchar2(30);
  l_segment_code              varchar2(30);
  l_seeded_flag               varchar2(1);
BEGIN

    select a.prc_context_type,
           a.prc_context_code,
           b.segment_code,
           b.seeded_flag
    into l_prc_context_type,
         l_prc_context_code,
         l_segment_code,
         l_seeded_flag
    from qp_prc_contexts_b a,
         qp_segments_b b
    where a.prc_context_id = b.prc_context_id and
          b.segment_id = p_segment_id;
    --
    DELETE  FROM QP_SEGMENTS_b
    WHERE   SEGMENT_ID = p_segment_id ;
    DELETE  FROM QP_SEGMENTS_tl
    WHERE   SEGMENT_ID = p_segment_id ;
    ---
    ---
    if l_prc_context_type = 'PRICING_ATTRIBUTE' and l_seeded_flag = 'N' then
       begin
       fnd_flex_dsc_api.delete_segment(
           APPL_SHORT_NAME => 'QP',
           FLEXFIELD_NAME => 'QP_ATTR_DEFNS_PRICING',
           CONTEXT => l_prc_context_code,
           SEGMENT => l_segment_code);
       exception
         when no_data_found then
            null;
       end;
       --
    end if;

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
(   p_segment_id                    IN  NUMBER
) RETURN QP_Attributes_PUB.Seg_Rec_Type
IS
BEGIN

    RETURN Query_Rows
        (   p_segment_id                  => p_segment_id
        )(1);

END Query_Row;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_segment_id                    IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_prc_context_id                IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN QP_Attributes_PUB.Seg_Tbl_Type
IS
l_SEG_rec                     QP_Attributes_PUB.Seg_Rec_Type;
l_SEG_tbl                     QP_Attributes_PUB.Seg_Tbl_Type;

CURSOR l_SEG_csr IS
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
    ,       AVAILABILITY_IN_BASIC
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       PRC_CONTEXT_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       SEEDED_FLAG
    ,       SEEDED_FORMAT_TYPE
    ,       SEEDED_PRECEDENCE
    ,       SEEDED_SEGMENT_NAME
    , 	    SEEDED_DESCRIPTION
    ,       SEEDED_VALUESET_ID
    ,       SEGMENT_code
    ,       SEGMENT_ID
    ,       APPLICATION_ID
    ,       SEGMENT_MAPPING_COLUMN
    ,       USER_FORMAT_TYPE
    ,       USER_PRECEDENCE
    ,       USER_SEGMENT_NAME
    ,       USER_DESCRIPTION
    ,       USER_VALUESET_ID
    ,	    REQUIRED_FLAG
    ,       PARTY_HIERARCHY_ENABLED_FLAG   -- Added for TCA
    FROM    QP_SEGMENTS_V
    WHERE ( SEGMENT_ID = p_segment_id
    )
    OR (    PRC_CONTEXT_ID = p_prc_context_id
    );

BEGIN

    IF
    (p_segment_id IS NOT NULL
     AND
     p_segment_id <> FND_API.G_MISS_NUM)
    AND
    (p_prc_context_id IS NOT NULL
     AND
     p_prc_context_id <> FND_API.G_MISS_NUM)
    THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: segment_id = '|| p_segment_id || ', prc_context_id = '|| p_prc_context_id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    --  Loop over fetched records

    FOR l_implicit_rec IN l_SEG_csr LOOP

        l_SEG_rec.attribute1           := l_implicit_rec.ATTRIBUTE1;
        l_SEG_rec.attribute10          := l_implicit_rec.ATTRIBUTE10;
        l_SEG_rec.attribute11          := l_implicit_rec.ATTRIBUTE11;
        l_SEG_rec.attribute12          := l_implicit_rec.ATTRIBUTE12;
        l_SEG_rec.attribute13          := l_implicit_rec.ATTRIBUTE13;
        l_SEG_rec.attribute14          := l_implicit_rec.ATTRIBUTE14;
        l_SEG_rec.attribute15          := l_implicit_rec.ATTRIBUTE15;
        l_SEG_rec.attribute2           := l_implicit_rec.ATTRIBUTE2;
        l_SEG_rec.attribute3           := l_implicit_rec.ATTRIBUTE3;
        l_SEG_rec.attribute4           := l_implicit_rec.ATTRIBUTE4;
        l_SEG_rec.attribute5           := l_implicit_rec.ATTRIBUTE5;
        l_SEG_rec.attribute6           := l_implicit_rec.ATTRIBUTE6;
        l_SEG_rec.attribute7           := l_implicit_rec.ATTRIBUTE7;
        l_SEG_rec.attribute8           := l_implicit_rec.ATTRIBUTE8;
        l_SEG_rec.attribute9           := l_implicit_rec.ATTRIBUTE9;
        l_SEG_rec.availability_in_basic := l_implicit_rec.AVAILABILITY_IN_BASIC;
        l_SEG_rec.context              := l_implicit_rec.CONTEXT;
        l_SEG_rec.created_by           := l_implicit_rec.CREATED_BY;
        l_SEG_rec.creation_date        := l_implicit_rec.CREATION_DATE;
        l_SEG_rec.last_updated_by      := l_implicit_rec.LAST_UPDATED_BY;
        l_SEG_rec.last_update_date     := l_implicit_rec.LAST_UPDATE_DATE;
        l_SEG_rec.last_update_login    := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_SEG_rec.prc_context_id       := l_implicit_rec.PRC_CONTEXT_ID;
        l_SEG_rec.program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_SEG_rec.program_id           := l_implicit_rec.PROGRAM_ID;
        l_SEG_rec.program_update_date  := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_SEG_rec.seeded_flag          := l_implicit_rec.SEEDED_FLAG;
        l_SEG_rec.seeded_format_type   := l_implicit_rec.SEEDED_FORMAT_TYPE;
        l_SEG_rec.seeded_precedence    := l_implicit_rec.SEEDED_PRECEDENCE;
        l_SEG_rec.seeded_segment_name  := l_implicit_rec.SEEDED_SEGMENT_NAME;
        l_SEG_rec.seeded_description   := l_implicit_rec.seeded_description;
        l_SEG_rec.user_description        := l_implicit_rec.user_description;
        l_SEG_rec.seeded_valueset_id   := l_implicit_rec.SEEDED_VALUESET_ID;
        l_SEG_rec.segment_code      := l_implicit_rec.SEGMENT_code;
        l_SEG_rec.segment_id           := l_implicit_rec.SEGMENT_ID;
        l_SEG_rec.application_id       := l_implicit_rec.APPLICATION_ID;
        l_SEG_rec.segment_mapping_column := l_implicit_rec.SEGMENT_MAPPING_COLUMN;
        l_SEG_rec.user_format_type     := l_implicit_rec.USER_FORMAT_TYPE;
        l_SEG_rec.user_precedence      := l_implicit_rec.USER_PRECEDENCE;
        l_SEG_rec.user_segment_name    := l_implicit_rec.USER_SEGMENT_NAME;
        l_SEG_rec.user_valueset_id     := l_implicit_rec.USER_VALUESET_ID;
        l_SEG_rec.required_flag	       := l_implicit_rec.REQUIRED_FLAG;
        l_SEG_rec.party_hierarchy_enabled_flag := l_implicit_rec.PARTY_HIERARCHY_ENABLED_FLAG;  -- Added for TCA

        l_SEG_tbl(l_SEG_tbl.COUNT + 1) := l_SEG_rec;

    END LOOP;


    --  PK sent and no rows found

    IF
    (p_segment_id IS NOT NULL
     AND
     p_segment_id <> FND_API.G_MISS_NUM)
    AND
    (l_SEG_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table

    RETURN l_SEG_tbl;

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
,   p_SEG_rec                       IN  QP_Attributes_PUB.Seg_Rec_Type
,   x_SEG_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Seg_Rec_Type
)
IS
l_SEG_rec                     QP_Attributes_PUB.Seg_Rec_Type;
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
    ,       AVAILABILITY_IN_BASIC
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       PRC_CONTEXT_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       SEEDED_FLAG
    ,       SEEDED_FORMAT_TYPE
    ,       SEEDED_PRECEDENCE
    ,       SEEDED_SEGMENT_NAME
    ,       SEEDED_DESCRIPTION
    ,       SEEDED_VALUESET_ID
    ,       SEGMENT_code
    ,       SEGMENT_ID
    ,       APPLICATION_ID
    ,       SEGMENT_MAPPING_COLUMN
    ,       USER_FORMAT_TYPE
    ,       USER_PRECEDENCE
    ,       USER_SEGMENT_NAME
    ,       USER_DESCRIPTION
    ,       USER_VALUESET_ID
    ,       REQUIRED_FLAG
    ,       PARTY_HIERARCHY_ENABLED_FLAG   --Added for TCA
    INTO    l_SEG_rec.attribute1
    ,       l_SEG_rec.attribute10
    ,       l_SEG_rec.attribute11
    ,       l_SEG_rec.attribute12
    ,       l_SEG_rec.attribute13
    ,       l_SEG_rec.attribute14
    ,       l_SEG_rec.attribute15
    ,       l_SEG_rec.attribute2
    ,       l_SEG_rec.attribute3
    ,       l_SEG_rec.attribute4
    ,       l_SEG_rec.attribute5
    ,       l_SEG_rec.attribute6
    ,       l_SEG_rec.attribute7
    ,       l_SEG_rec.attribute8
    ,       l_SEG_rec.attribute9
    ,       l_SEG_rec.availability_in_basic
    ,       l_SEG_rec.context
    ,       l_SEG_rec.created_by
    ,       l_SEG_rec.creation_date
    ,       l_SEG_rec.last_updated_by
    ,       l_SEG_rec.last_update_date
    ,       l_SEG_rec.last_update_login
    ,       l_SEG_rec.prc_context_id
    ,       l_SEG_rec.program_application_id
    ,       l_SEG_rec.program_id
    ,       l_SEG_rec.program_update_date
    ,       l_SEG_rec.seeded_flag
    ,       l_SEG_rec.seeded_format_type
    ,       l_SEG_rec.seeded_precedence
    ,       l_SEG_rec.seeded_segment_name
    ,       l_SEG_rec.seeded_description
    ,       l_SEG_rec.seeded_valueset_id
    ,       l_SEG_rec.segment_code
    ,       l_SEG_rec.segment_id
    ,       l_SEG_rec.application_id
    ,       l_SEG_rec.segment_mapping_column
    ,       l_SEG_rec.user_format_type
    ,       l_SEG_rec.user_precedence
    ,       l_SEG_rec.user_segment_name
    ,       l_SEG_rec.user_description
    ,       l_SEG_rec.user_valueset_id
    ,	    l_SEG_rec.required_flag
    ,       l_SEG_rec.party_hierarchy_enabled_flag   -- Added for TCA
    FROM    QP_SEGMENTS_V
    WHERE   SEGMENT_ID = p_SEG_rec.segment_id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  QP_GLOBALS.Equal(p_SEG_rec.attribute1,
                         l_SEG_rec.attribute1)
    AND QP_GLOBALS.Equal(p_SEG_rec.attribute10,
                         l_SEG_rec.attribute10)
    AND QP_GLOBALS.Equal(p_SEG_rec.attribute11,
                         l_SEG_rec.attribute11)
    AND QP_GLOBALS.Equal(p_SEG_rec.attribute12,
                         l_SEG_rec.attribute12)
    AND QP_GLOBALS.Equal(p_SEG_rec.attribute13,
                         l_SEG_rec.attribute13)
    AND QP_GLOBALS.Equal(p_SEG_rec.attribute14,
                         l_SEG_rec.attribute14)
    AND QP_GLOBALS.Equal(p_SEG_rec.attribute15,
                         l_SEG_rec.attribute15)
    AND QP_GLOBALS.Equal(p_SEG_rec.attribute2,
                         l_SEG_rec.attribute2)
    AND QP_GLOBALS.Equal(p_SEG_rec.attribute3,
                         l_SEG_rec.attribute3)
    AND QP_GLOBALS.Equal(p_SEG_rec.attribute4,
                         l_SEG_rec.attribute4)
    AND QP_GLOBALS.Equal(p_SEG_rec.attribute5,
                         l_SEG_rec.attribute5)
    AND QP_GLOBALS.Equal(p_SEG_rec.attribute6,
                         l_SEG_rec.attribute6)
    AND QP_GLOBALS.Equal(p_SEG_rec.attribute7,
                         l_SEG_rec.attribute7)
    AND QP_GLOBALS.Equal(p_SEG_rec.attribute8,
                         l_SEG_rec.attribute8)
    AND QP_GLOBALS.Equal(p_SEG_rec.attribute9,
                         l_SEG_rec.attribute9)
    AND QP_GLOBALS.Equal(p_SEG_rec.availability_in_basic,
                         l_SEG_rec.availability_in_basic)
    AND QP_GLOBALS.Equal(p_SEG_rec.context,
                         l_SEG_rec.context)
    AND QP_GLOBALS.Equal(p_SEG_rec.created_by,
                         l_SEG_rec.created_by)
    AND QP_GLOBALS.Equal(p_SEG_rec.creation_date,
                         l_SEG_rec.creation_date)
    AND QP_GLOBALS.Equal(p_SEG_rec.last_updated_by,
                         l_SEG_rec.last_updated_by)
    AND QP_GLOBALS.Equal(p_SEG_rec.last_update_date,
                         l_SEG_rec.last_update_date)
    AND QP_GLOBALS.Equal(p_SEG_rec.last_update_login,
                         l_SEG_rec.last_update_login)
    AND QP_GLOBALS.Equal(p_SEG_rec.prc_context_id,
                         l_SEG_rec.prc_context_id)
    AND QP_GLOBALS.Equal(p_SEG_rec.program_application_id,
                         l_SEG_rec.program_application_id)
    AND QP_GLOBALS.Equal(p_SEG_rec.program_id,
                         l_SEG_rec.program_id)
    AND QP_GLOBALS.Equal(p_SEG_rec.program_update_date,
                         l_SEG_rec.program_update_date)
    AND QP_GLOBALS.Equal(p_SEG_rec.seeded_flag,
                         l_SEG_rec.seeded_flag)
    AND QP_GLOBALS.Equal(p_SEG_rec.seeded_format_type,
                         l_SEG_rec.seeded_format_type)
    AND QP_GLOBALS.Equal(p_SEG_rec.seeded_precedence,
                         l_SEG_rec.seeded_precedence)
    AND QP_GLOBALS.Equal(p_SEG_rec.seeded_segment_name,
                         l_SEG_rec.seeded_segment_name)
    AND QP_GLOBALS.Equal(p_SEG_rec.seeded_valueset_id,
                         l_SEG_rec.seeded_valueset_id)
    AND QP_GLOBALS.Equal(p_SEG_rec.segment_code,
                         l_SEG_rec.segment_code)
    AND QP_GLOBALS.Equal(p_SEG_rec.segment_id,
                         l_SEG_rec.segment_id)
    AND QP_GLOBALS.Equal(p_SEG_rec.application_id,
                         l_SEG_rec.application_id)
    AND QP_GLOBALS.Equal(p_SEG_rec.segment_mapping_column,
                         l_SEG_rec.segment_mapping_column)
    AND QP_GLOBALS.Equal(p_SEG_rec.user_format_type,
                         l_SEG_rec.user_format_type)
    AND QP_GLOBALS.Equal(p_SEG_rec.user_precedence,
                         l_SEG_rec.user_precedence)
    AND QP_GLOBALS.Equal(p_SEG_rec.user_segment_name,
                         l_SEG_rec.user_segment_name)
    AND QP_GLOBALS.Equal( p_SEG_rec.seeded_description,
			  l_SEG_rec.seeded_description)
    AND QP_GLOBALS.Equal( p_SEG_rec.user_description,
                          l_SEG_rec.user_description)
    AND QP_GLOBALS.Equal(p_SEG_rec.user_valueset_id,
                         l_SEG_rec.user_valueset_id)
    AND QP_GLOBALS.Equal(p_SEG_rec.required_flag,
                         l_SEG_rec.required_flag)
   -- Added for TCA
    AND QP_GLOBALS.Equal(p_SEG_rec.party_hierarchy_enabled_flag,
                         l_SEG_rec.party_hierarchy_enabled_flag)

    THEN
        --  Row has not changed. Set out parameter.

        x_SEG_rec                      := l_SEG_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_SEG_rec.return_status        := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_SEG_rec.return_status        := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_CHANGED_abhi6');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_SEG_rec.return_status        := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_DELETED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_SEG_rec.return_status        := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_SEG_rec.return_status        := FND_API.G_RET_STS_UNEXP_ERROR;

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
(   p_SEG_rec                       IN  QP_Attributes_PUB.Seg_Rec_Type
,   p_old_SEG_rec                   IN  QP_Attributes_PUB.Seg_Rec_Type :=
                                        QP_Attributes_PUB.G_MISS_SEG_REC
) RETURN QP_Attributes_PUB.Seg_Val_Rec_Type
IS
l_SEG_val_rec                 QP_Attributes_PUB.Seg_Val_Rec_Type;
BEGIN

    IF p_SEG_rec.prc_context_id IS NOT NULL AND
        p_SEG_rec.prc_context_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_SEG_rec.prc_context_id,
        p_old_SEG_rec.prc_context_id)
    THEN
        l_SEG_val_rec.prc_context := QP_Id_To_Value.Prc_Context
        (   p_prc_context_id              => p_SEG_rec.prc_context_id
        );
    END IF;

    IF p_SEG_rec.seeded_flag IS NOT NULL AND
        p_SEG_rec.seeded_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_SEG_rec.seeded_flag,
        p_old_SEG_rec.seeded_flag)
    THEN
        l_SEG_val_rec.seeded := QP_Id_To_Value.Seeded
        (   p_seeded_flag                 => p_SEG_rec.seeded_flag
        );
    END IF;

    IF p_SEG_rec.seeded_valueset_id IS NOT NULL AND
        p_SEG_rec.seeded_valueset_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_SEG_rec.seeded_valueset_id,
        p_old_SEG_rec.seeded_valueset_id)
    THEN
        l_SEG_val_rec.seeded_valueset := QP_Id_To_Value.Seeded_Valueset
        (   p_seeded_valueset_id          => p_SEG_rec.seeded_valueset_id
        );
    END IF;

    IF p_SEG_rec.segment_id IS NOT NULL AND
        p_SEG_rec.segment_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_SEG_rec.segment_id,
        p_old_SEG_rec.segment_id)
    THEN
        l_SEG_val_rec.segment := QP_Id_To_Value.Segment
        (   p_segment_id                  => p_SEG_rec.segment_id
        );
    END IF;

    IF p_SEG_rec.user_valueset_id IS NOT NULL AND
        p_SEG_rec.user_valueset_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_SEG_rec.user_valueset_id,
        p_old_SEG_rec.user_valueset_id)
    THEN
        l_SEG_val_rec.user_valueset := QP_Id_To_Value.User_Valueset
        (   p_user_valueset_id            => p_SEG_rec.user_valueset_id
        );
    END IF;

    RETURN l_SEG_val_rec;

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_SEG_rec                       IN  QP_Attributes_PUB.Seg_Rec_Type
,   p_SEG_val_rec                   IN  QP_Attributes_PUB.Seg_Val_Rec_Type
) RETURN QP_Attributes_PUB.Seg_Rec_Type
IS
l_SEG_rec                     QP_Attributes_PUB.Seg_Rec_Type;
BEGIN

    --  initialize  return_status.

    l_SEG_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_SEG_rec.

    l_SEG_rec := p_SEG_rec;

    IF  p_SEG_val_rec.prc_context <> FND_API.G_MISS_CHAR
    THEN

        IF p_SEG_rec.prc_context_id <> FND_API.G_MISS_NUM THEN

            l_SEG_rec.prc_context_id := p_SEG_rec.prc_context_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','prc_context');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_SEG_rec.prc_context_id := QP_Value_To_Id.prc_context
            (   p_prc_context                 => p_SEG_val_rec.prc_context
            );

            IF l_SEG_rec.prc_context_id = FND_API.G_MISS_NUM THEN
                l_SEG_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_SEG_val_rec.seeded <> FND_API.G_MISS_CHAR
    THEN

        IF p_SEG_rec.seeded_flag <> FND_API.G_MISS_CHAR THEN

            l_SEG_rec.seeded_flag := p_SEG_rec.seeded_flag;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','seeded');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_SEG_rec.seeded_flag := QP_Value_To_Id.seeded
            (   p_seeded                      => p_SEG_val_rec.seeded
            );

            IF l_SEG_rec.seeded_flag = FND_API.G_MISS_CHAR THEN
                l_SEG_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_SEG_val_rec.seeded_valueset <> FND_API.G_MISS_CHAR
    THEN

        IF p_SEG_rec.seeded_valueset_id <> FND_API.G_MISS_NUM THEN

            l_SEG_rec.seeded_valueset_id := p_SEG_rec.seeded_valueset_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','seeded_valueset');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_SEG_rec.seeded_valueset_id := QP_Value_To_Id.seeded_valueset
            (   p_seeded_valueset             => p_SEG_val_rec.seeded_valueset
            );

            IF l_SEG_rec.seeded_valueset_id = FND_API.G_MISS_NUM THEN
                l_SEG_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_SEG_val_rec.segment <> FND_API.G_MISS_CHAR
    THEN

        IF p_SEG_rec.segment_id <> FND_API.G_MISS_NUM THEN

            l_SEG_rec.segment_id := p_SEG_rec.segment_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','segment');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_SEG_rec.segment_id := QP_Value_To_Id.segment
            (   p_segment                     => p_SEG_val_rec.segment
            );

            IF l_SEG_rec.segment_id = FND_API.G_MISS_NUM THEN
                l_SEG_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_SEG_val_rec.user_valueset <> FND_API.G_MISS_CHAR
    THEN

        IF p_SEG_rec.user_valueset_id <> FND_API.G_MISS_NUM THEN

            l_SEG_rec.user_valueset_id := p_SEG_rec.user_valueset_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','user_valueset');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_SEG_rec.user_valueset_id := QP_Value_To_Id.user_valueset
            (   p_user_valueset               => p_SEG_val_rec.user_valueset
            );

            IF l_SEG_rec.user_valueset_id = FND_API.G_MISS_NUM THEN
                l_SEG_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    RETURN l_SEG_rec;

END Get_Ids;

END QP_Seg_Util;

/
