--------------------------------------------------------
--  DDL for Package Body QP_LIMITS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_LIMITS_UTIL" AS
/* $Header: QPXULMTB.pls 120.2.12010000.2 2009/02/04 13:41:05 jputta ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Limits_Util';

PROCEDURE Update_List_Header_And_Line
(p_LIMITS_rec          IN  QP_Limits_PUB.Limits_Rec_Type)
IS

l_dummy NUMBER := 0;
l_dummy1 NUMBER := 0;
l_updated NUMBER := 0;  --pattern
l_return_status       		varchar2(30);

BEGIN

   IF (p_LIMITS_rec.operation = QP_GLOBALS.g_opr_create) THEN

      IF p_LIMITS_rec.list_header_id IS NOT NULL THEN
         UPDATE QP_LIST_HEADERS_B
         SET LIMIT_EXISTS_FLAG = 'Y'
         WHERE list_header_id = p_LIMITS_rec.list_header_id
         and nvl(LIMIT_EXISTS_FLAG,'N')  <> 'Y' ; --Bug no 6193752
	 l_updated := 1;  --pattern
      END IF;

      IF p_LIMITS_rec.list_line_id IS NOT NULL THEN
         UPDATE QP_LIST_LINES
         SET LIMIT_EXISTS_FLAG = 'Y'
         WHERE list_line_id = p_LIMITS_rec.list_line_id
         and nvl(LIMIT_EXISTS_FLAG,'N')  <> 'Y' ; --Bug no 6193752
	 l_updated := 2;  --pattern
      END IF;

   ELSIF (p_LIMITS_rec.operation = QP_GLOBALS.g_opr_delete) OR (p_LIMITS_rec.operation = QP_GLOBALS.g_opr_update) THEN

      IF p_LIMITS_rec.list_header_id IS NOT NULL THEN

         l_dummy := 0;
         SELECT COUNT(*) INTO   l_dummy
         FROM QP_LIST_HEADERS_B WHERE list_header_id = p_LIMITS_rec.list_header_id;

         IF l_dummy > 0 THEN     -- LIST HEADER EXISTS THEN

            l_dummy1 := 0;
            SELECT COUNT(*) INTO   l_dummy1
            FROM QP_LIMITS WHERE list_header_id = p_LIMITS_rec.list_header_id;

            IF l_dummy1 = 0 THEN
               UPDATE QP_LIST_HEADERS_B SET LIMIT_EXISTS_FLAG = 'N'
               WHERE list_header_id = p_LIMITS_rec.list_header_id
               and nvl(LIMIT_EXISTS_FLAG,'Y')  <> 'N' ; --Bug no 6193752
	       l_updated := 1;  --pattern
            ELSIF l_dummy1 > 0 THEN
               UPDATE QP_LIST_HEADERS_B SET LIMIT_EXISTS_FLAG = 'Y'
               WHERE list_header_id = p_LIMITS_rec.list_header_id
               and nvl(LIMIT_EXISTS_FLAG,'N')  <> 'Y' ; --Bug no 6193752
	       l_updated := 1;  --pattern
            END IF;

         END IF;

      END IF;

      IF p_LIMITS_rec.list_line_id IS NOT NULL THEN

         l_dummy := 0;
         SELECT COUNT(*) INTO   l_dummy
         FROM QP_LIST_LINES WHERE list_line_id = p_LIMITS_rec.list_line_id;

         IF l_dummy > 0 THEN    -- LIST LINE EXISTS THEN

            l_dummy1 := 0;
            SELECT COUNT(*) INTO   l_dummy1
            FROM QP_LIMITS WHERE list_line_id = p_LIMITS_rec.list_line_id;

            IF l_dummy1 = 0 THEN
               UPDATE QP_LIST_LINES SET LIMIT_EXISTS_FLAG = 'N'
               WHERE list_line_id = p_LIMITS_rec.list_line_id
               and nvl(LIMIT_EXISTS_FLAG,'Y')  <> 'N' ; --Bug no 6193752
	       l_updated := 2;  --pattern
            ELSIF l_dummy1 > 0 THEN
               UPDATE QP_LIST_LINES SET LIMIT_EXISTS_FLAG = 'Y'
               WHERE list_line_id = p_LIMITS_rec.list_line_id
               and nvl(LIMIT_EXISTS_FLAG,'N')  <> 'Y' ; --Bug no 6193752
	       l_updated := 2;  --pattern
            END IF;

         END IF;

      END IF;

   END IF;
-- pattern
   IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'Y' THEN
    IF (p_LIMITS_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
     IF l_updated = 1 then
	qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_LIMITS_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_LIMITS_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => l_return_status);
      END IF;
      IF l_updated = 2 then
	qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_LIMITS_rec.list_header_id,
		p_request_unique_key1 => p_LIMITS_rec.list_line_id,
		p_request_unique_key2 => NULL,
		p_request_unique_key3 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_LIMITS_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_LINE_PATTERN,
		x_return_status => l_return_status);
      END IF;
    END IF;
   END IF;
-- jagan's PL/SQL pattern
  IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
   IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'M' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' THEN
    IF (p_LIMITS_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
     IF l_updated = 1 then
	qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_LIMITS_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_LIMITS_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => l_return_status);
      END IF;
      IF l_updated = 2 then
	qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_LIMITS_rec.list_header_id,
		p_request_unique_key1 => p_LIMITS_rec.list_line_id,
		p_request_unique_key2 => NULL,
		p_request_unique_key3 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_LIMITS_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_LINE_PATTERN,
		x_return_status => l_return_status);
      END IF;
    END IF;
   END IF;
  END IF;
-- jagan's PL/SQL pattern
END Update_List_Header_And_Line;

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
,   p_old_LIMITS_rec                IN  QP_Limits_PUB.Limits_Rec_Type := QP_Limits_PUB.G_MISS_LIMITS_REC
,   x_LIMITS_rec                    OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limits_Rec_Type
)
IS
l_index                       NUMBER := 0;
l_src_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
BEGIN

    --  Load out record

    x_LIMITS_rec := p_LIMITS_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.amount, p_old_LIMITS_rec.amount)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_AMOUNT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute1, p_old_LIMITS_rec.attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute10, p_old_LIMITS_rec.attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute11, p_old_LIMITS_rec.attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute12, p_old_LIMITS_rec.attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute13, p_old_LIMITS_rec.attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute14, p_old_LIMITS_rec.attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute15, p_old_LIMITS_rec.attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute2, p_old_LIMITS_rec.attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute3, p_old_LIMITS_rec.attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute4, p_old_LIMITS_rec.attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute5, p_old_LIMITS_rec.attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute6, p_old_LIMITS_rec.attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute7, p_old_LIMITS_rec.attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute8, p_old_LIMITS_rec.attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute9, p_old_LIMITS_rec.attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.basis, p_old_LIMITS_rec.basis)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_BASIS;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.context, p_old_LIMITS_rec.context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.created_by, p_old_LIMITS_rec.created_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_CREATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.creation_date, p_old_LIMITS_rec.creation_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.last_updated_by, p_old_LIMITS_rec.last_updated_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.last_update_date, p_old_LIMITS_rec.last_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.last_update_login, p_old_LIMITS_rec.last_update_login)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.limit_exceed_action_code, p_old_LIMITS_rec.limit_exceed_action_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_LIMIT_EXCEED_ACTION;
        END IF;


        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.limit_id, p_old_LIMITS_rec.limit_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_LIMIT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.limit_level_code, p_old_LIMITS_rec.limit_level_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_LIMIT_LEVEL;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.limit_number, p_old_LIMITS_rec.limit_number)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_LIMIT_NUMBER;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.list_header_id, p_old_LIMITS_rec.list_header_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_LIST_HEADER;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.list_line_id, p_old_LIMITS_rec.list_line_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_LIST_LINE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.organization_flag, p_old_LIMITS_rec.organization_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ORGANIZATION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.program_application_id, p_old_LIMITS_rec.program_application_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_PROGRAM_APPLICATION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.program_id, p_old_LIMITS_rec.program_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_PROGRAM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.program_update_date, p_old_LIMITS_rec.program_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_PROGRAM_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.request_id, p_old_LIMITS_rec.request_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_REQUEST;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.limit_hold_flag, p_old_LIMITS_rec.limit_hold_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_LIMIT_HOLD;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.multival_attr1_type, p_old_LIMITS_rec.multival_attr1_type)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_MULTIVAL_ATTR1_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.multival_attr1_context, p_old_LIMITS_rec.multival_attr1_context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_MULTIVAL_ATTR1_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.multival_attribute1, p_old_LIMITS_rec.multival_attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_MULTIVAL_ATTRIBUTE1;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.multival_attr1_datatype, p_old_LIMITS_rec.multival_attr1_datatype)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_MULTIVAL_ATTR1_DATATYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.multival_attr2_type, p_old_LIMITS_rec.multival_attr2_type)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_MULTIVAL_ATTR2_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.multival_attr2_context, p_old_LIMITS_rec.multival_attr2_context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_MULTIVAL_ATTR2_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.multival_attribute2, p_old_LIMITS_rec.multival_attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_MULTIVAL_ATTRIBUTE2;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.multival_attr2_datatype, p_old_LIMITS_rec.multival_attr2_datatype)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_MULTIVAL_ATTR2_DATATYPE;
        END IF;

    ELSIF p_attr_id = G_AMOUNT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_AMOUNT;
    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_BASIS THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_BASIS;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_CONTEXT;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_CREATION_DATE;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_LIMIT_EXCEED_ACTION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_LIMIT_EXCEED_ACTION;
    ELSIF p_attr_id = G_LIMIT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_LIMIT;
    ELSIF p_attr_id = G_LIMIT_LEVEL THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_LIMIT_LEVEL;
    ELSIF p_attr_id = G_LIMIT_NUMBER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_LIMIT_NUMBER;
    ELSIF p_attr_id = G_LIST_HEADER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_LIST_HEADER;
    ELSIF p_attr_id = G_LIST_LINE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_LIST_LINE;
    ELSIF p_attr_id = G_ORGANIZATION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_ORGANIZATION;
    ELSIF p_attr_id = G_PROGRAM_APPLICATION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_PROGRAM_APPLICATION;
    ELSIF p_attr_id = G_PROGRAM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_PROGRAM;
    ELSIF p_attr_id = G_PROGRAM_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_PROGRAM_UPDATE_DATE;
    ELSIF p_attr_id = G_REQUEST THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_REQUEST;
    ELSIF p_attr_id = G_LIMIT_HOLD THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_LIMIT_HOLD;
    ELSIF p_attr_id = G_MULTIVAL_ATTR1_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_MULTIVAL_ATTR1_TYPE;
    ELSIF p_attr_id = G_MULTIVAL_ATTR1_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_MULTIVAL_ATTR1_CONTEXT;
    ELSIF p_attr_id = G_MULTIVAL_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_MULTIVAL_ATTRIBUTE1;
    ELSIF p_attr_id = G_MULTIVAL_ATTR1_DATATYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_MULTIVAL_ATTR1_DATATYPE;
    ELSIF p_attr_id = G_MULTIVAL_ATTR2_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_MULTIVAL_ATTR2_TYPE;
    ELSIF p_attr_id = G_MULTIVAL_ATTR2_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_MULTIVAL_ATTR2_CONTEXT;
    ELSIF p_attr_id = G_MULTIVAL_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_MULTIVAL_ATTRIBUTE2;
    ELSIF p_attr_id = G_MULTIVAL_ATTR2_DATATYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMITS_UTIL.G_MULTIVAL_ATTR2_DATATYPE;
    END IF;

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
,   p_old_LIMITS_rec                IN  QP_Limits_PUB.Limits_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMITS_REC
,   x_LIMITS_rec                    OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limits_Rec_Type
)
IS
BEGIN

    --  Load out record

    x_LIMITS_rec := p_LIMITS_rec;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.amount, p_old_LIMITS_rec.amount)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute1, p_old_LIMITS_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute10, p_old_LIMITS_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute11, p_old_LIMITS_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute12, p_old_LIMITS_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute13, p_old_LIMITS_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute14, p_old_LIMITS_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute15, p_old_LIMITS_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute2, p_old_LIMITS_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute3, p_old_LIMITS_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute4, p_old_LIMITS_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute5, p_old_LIMITS_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute6, p_old_LIMITS_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute7, p_old_LIMITS_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute8, p_old_LIMITS_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.attribute9, p_old_LIMITS_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.basis, p_old_LIMITS_rec.basis)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.context, p_old_LIMITS_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.created_by, p_old_LIMITS_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.creation_date, p_old_LIMITS_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.last_updated_by, p_old_LIMITS_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.last_update_date, p_old_LIMITS_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.last_update_login, p_old_LIMITS_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.limit_exceed_action_code, p_old_LIMITS_rec.limit_exceed_action_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.limit_id, p_old_LIMITS_rec.limit_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.limit_level_code, p_old_LIMITS_rec.limit_level_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.limit_number, p_old_LIMITS_rec.limit_number)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.list_header_id, p_old_LIMITS_rec.list_header_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.list_line_id, p_old_LIMITS_rec.list_line_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.organization_flag, p_old_LIMITS_rec.organization_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.program_application_id, p_old_LIMITS_rec.program_application_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.program_id, p_old_LIMITS_rec.program_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.program_update_date, p_old_LIMITS_rec.program_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.request_id, p_old_LIMITS_rec.request_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.limit_hold_flag, p_old_LIMITS_rec.limit_hold_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.multival_attr1_type, p_old_LIMITS_rec.multival_attr1_type)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.multival_attr1_context, p_old_LIMITS_rec.multival_attr1_context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.multival_attribute1, p_old_LIMITS_rec.multival_attribute1)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.multival_attr1_datatype, p_old_LIMITS_rec.multival_attr1_datatype)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.multival_attr2_type, p_old_LIMITS_rec.multival_attr2_type)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.multival_attr2_context, p_old_LIMITS_rec.multival_attr2_context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.multival_attribute2, p_old_LIMITS_rec.multival_attribute2)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.multival_attr2_datatype, p_old_LIMITS_rec.multival_attr2_datatype)
    THEN
        NULL;
    END IF;

END Apply_Attribute_Changes;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
,   p_old_LIMITS_rec                IN  QP_Limits_PUB.Limits_Rec_Type
) RETURN QP_Limits_PUB.Limits_Rec_Type
IS
l_LIMITS_rec                  QP_Limits_PUB.Limits_Rec_Type := p_LIMITS_rec;
BEGIN

    IF l_LIMITS_rec.amount = FND_API.G_MISS_NUM THEN
        l_LIMITS_rec.amount := p_old_LIMITS_rec.amount;
    END IF;

    IF l_LIMITS_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute1 := p_old_LIMITS_rec.attribute1;
    END IF;

    IF l_LIMITS_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute10 := p_old_LIMITS_rec.attribute10;
    END IF;

    IF l_LIMITS_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute11 := p_old_LIMITS_rec.attribute11;
    END IF;

    IF l_LIMITS_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute12 := p_old_LIMITS_rec.attribute12;
    END IF;

    IF l_LIMITS_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute13 := p_old_LIMITS_rec.attribute13;
    END IF;

    IF l_LIMITS_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute14 := p_old_LIMITS_rec.attribute14;
    END IF;

    IF l_LIMITS_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute15 := p_old_LIMITS_rec.attribute15;
    END IF;

    IF l_LIMITS_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute2 := p_old_LIMITS_rec.attribute2;
    END IF;

    IF l_LIMITS_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute3 := p_old_LIMITS_rec.attribute3;
    END IF;

    IF l_LIMITS_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute4 := p_old_LIMITS_rec.attribute4;
    END IF;

    IF l_LIMITS_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute5 := p_old_LIMITS_rec.attribute5;
    END IF;

    IF l_LIMITS_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute6 := p_old_LIMITS_rec.attribute6;
    END IF;

    IF l_LIMITS_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute7 := p_old_LIMITS_rec.attribute7;
    END IF;

    IF l_LIMITS_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute8 := p_old_LIMITS_rec.attribute8;
    END IF;

    IF l_LIMITS_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute9 := p_old_LIMITS_rec.attribute9;
    END IF;

    IF l_LIMITS_rec.basis = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.basis := p_old_LIMITS_rec.basis;
    END IF;

    IF l_LIMITS_rec.context = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.context := p_old_LIMITS_rec.context;
    END IF;

    IF l_LIMITS_rec.created_by = FND_API.G_MISS_NUM THEN
        l_LIMITS_rec.created_by := p_old_LIMITS_rec.created_by;
    END IF;

    IF l_LIMITS_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_LIMITS_rec.creation_date := p_old_LIMITS_rec.creation_date;
    END IF;

    IF l_LIMITS_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_LIMITS_rec.last_updated_by := p_old_LIMITS_rec.last_updated_by;
    END IF;

    IF l_LIMITS_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_LIMITS_rec.last_update_date := p_old_LIMITS_rec.last_update_date;
    END IF;

    IF l_LIMITS_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_LIMITS_rec.last_update_login := p_old_LIMITS_rec.last_update_login;
    END IF;

    IF l_LIMITS_rec.limit_exceed_action_code = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.limit_exceed_action_code := p_old_LIMITS_rec.limit_exceed_action_code;
    END IF;

    IF l_LIMITS_rec.limit_id = FND_API.G_MISS_NUM THEN
        l_LIMITS_rec.limit_id := p_old_LIMITS_rec.limit_id;
    END IF;

    IF l_LIMITS_rec.limit_level_code = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.limit_level_code := p_old_LIMITS_rec.limit_level_code;
    END IF;

    IF l_LIMITS_rec.limit_number = FND_API.G_MISS_NUM THEN
        l_LIMITS_rec.limit_number := p_old_LIMITS_rec.limit_number;
    END IF;

    IF l_LIMITS_rec.list_header_id = FND_API.G_MISS_NUM THEN
        l_LIMITS_rec.list_header_id := p_old_LIMITS_rec.list_header_id;
    END IF;

    IF l_LIMITS_rec.list_line_id = FND_API.G_MISS_NUM THEN
        l_LIMITS_rec.list_line_id := p_old_LIMITS_rec.list_line_id;
    END IF;

    IF l_LIMITS_rec.organization_flag = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.organization_flag := p_old_LIMITS_rec.organization_flag;
    END IF;

    IF l_LIMITS_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_LIMITS_rec.program_application_id := p_old_LIMITS_rec.program_application_id;
    END IF;

    IF l_LIMITS_rec.program_id = FND_API.G_MISS_NUM THEN
        l_LIMITS_rec.program_id := p_old_LIMITS_rec.program_id;
    END IF;

    IF l_LIMITS_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_LIMITS_rec.program_update_date := p_old_LIMITS_rec.program_update_date;
    END IF;

    IF l_LIMITS_rec.request_id = FND_API.G_MISS_NUM THEN
        l_LIMITS_rec.request_id := p_old_LIMITS_rec.request_id;
    END IF;

    IF l_LIMITS_rec.limit_hold_flag = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.limit_hold_flag := p_old_LIMITS_rec.limit_hold_flag;
    END IF;

    IF l_LIMITS_rec.multival_attr1_type = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.multival_attr1_type := p_old_LIMITS_rec.multival_attr1_type;
    END IF;

    IF l_LIMITS_rec.multival_attr1_context = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.multival_attr1_context := p_old_LIMITS_rec.multival_attr1_context;
    END IF;

    IF l_LIMITS_rec.multival_attribute1 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.multival_attribute1 := p_old_LIMITS_rec.multival_attribute1;
    END IF;

    IF l_LIMITS_rec.multival_attr1_datatype = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.multival_attr1_datatype := p_old_LIMITS_rec.multival_attr1_datatype;
    END IF;

    IF l_LIMITS_rec.multival_attr2_type = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.multival_attr2_type := p_old_LIMITS_rec.multival_attr2_type;
    END IF;

    IF l_LIMITS_rec.multival_attr2_context = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.multival_attr2_context := p_old_LIMITS_rec.multival_attr2_context;
    END IF;

    IF l_LIMITS_rec.multival_attribute2 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.multival_attribute2 := p_old_LIMITS_rec.multival_attribute2;
    END IF;

    IF l_LIMITS_rec.multival_attr2_datatype = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.multival_attr2_datatype := p_old_LIMITS_rec.multival_attr2_datatype;
    END IF;

    RETURN l_LIMITS_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
) RETURN QP_Limits_PUB.Limits_Rec_Type
IS
l_LIMITS_rec                  QP_Limits_PUB.Limits_Rec_Type := p_LIMITS_rec;
BEGIN

    IF l_LIMITS_rec.amount = FND_API.G_MISS_NUM THEN
        l_LIMITS_rec.amount := NULL;
    END IF;

    IF l_LIMITS_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute1 := NULL;
    END IF;

    IF l_LIMITS_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute10 := NULL;
    END IF;

    IF l_LIMITS_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute11 := NULL;
    END IF;

    IF l_LIMITS_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute12 := NULL;
    END IF;

    IF l_LIMITS_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute13 := NULL;
    END IF;

    IF l_LIMITS_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute14 := NULL;
    END IF;

    IF l_LIMITS_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute15 := NULL;
    END IF;

    IF l_LIMITS_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute2 := NULL;
    END IF;

    IF l_LIMITS_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute3 := NULL;
    END IF;

    IF l_LIMITS_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute4 := NULL;
    END IF;

    IF l_LIMITS_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute5 := NULL;
    END IF;

    IF l_LIMITS_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute6 := NULL;
    END IF;

    IF l_LIMITS_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute7 := NULL;
    END IF;

    IF l_LIMITS_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute8 := NULL;
    END IF;

    IF l_LIMITS_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.attribute9 := NULL;
    END IF;

    IF l_LIMITS_rec.basis = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.basis := NULL;
    END IF;

    IF l_LIMITS_rec.context = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.context := NULL;
    END IF;

    IF l_LIMITS_rec.created_by = FND_API.G_MISS_NUM THEN
        l_LIMITS_rec.created_by := NULL;
    END IF;

    IF l_LIMITS_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_LIMITS_rec.creation_date := NULL;
    END IF;

    IF l_LIMITS_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_LIMITS_rec.last_updated_by := NULL;
    END IF;

    IF l_LIMITS_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_LIMITS_rec.last_update_date := NULL;
    END IF;

    IF l_LIMITS_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_LIMITS_rec.last_update_login := NULL;
    END IF;

    IF l_LIMITS_rec.limit_exceed_action_code = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.limit_exceed_action_code := NULL;
    END IF;

    IF l_LIMITS_rec.limit_id = FND_API.G_MISS_NUM THEN
        l_LIMITS_rec.limit_id := NULL;
    END IF;

    IF l_LIMITS_rec.limit_level_code = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.limit_level_code := NULL;
    END IF;

    IF l_LIMITS_rec.limit_number = FND_API.G_MISS_NUM THEN
        l_LIMITS_rec.limit_number := NULL;
    END IF;

    IF l_LIMITS_rec.list_header_id = FND_API.G_MISS_NUM THEN
        l_LIMITS_rec.list_header_id := NULL;
    END IF;

    IF l_LIMITS_rec.list_line_id = FND_API.G_MISS_NUM THEN
        l_LIMITS_rec.list_line_id := NULL;
    END IF;

    IF l_LIMITS_rec.organization_flag = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.organization_flag := NULL;
    END IF;

    IF l_LIMITS_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_LIMITS_rec.program_application_id := NULL;
    END IF;

    IF l_LIMITS_rec.program_id = FND_API.G_MISS_NUM THEN
        l_LIMITS_rec.program_id := NULL;
    END IF;

    IF l_LIMITS_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_LIMITS_rec.program_update_date := NULL;
    END IF;

    IF l_LIMITS_rec.request_id = FND_API.G_MISS_NUM THEN
        l_LIMITS_rec.request_id := NULL;
    END IF;

    IF l_LIMITS_rec.limit_hold_flag = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.limit_hold_flag := NULL;
    END IF;

    IF l_LIMITS_rec.multival_attr1_type = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.multival_attr1_type := NULL;
    END IF;

    IF l_LIMITS_rec.multival_attr1_context = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.multival_attr1_context := NULL;
    END IF;

    IF l_LIMITS_rec.multival_attribute1 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.multival_attribute1 := NULL;
    END IF;

    IF l_LIMITS_rec.multival_attr1_datatype = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.multival_attr1_datatype := NULL;
    END IF;

    IF l_LIMITS_rec.multival_attr2_type = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.multival_attr2_type := NULL;
    END IF;

    IF l_LIMITS_rec.multival_attr2_context = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.multival_attr2_context := NULL;
    END IF;

    IF l_LIMITS_rec.multival_attribute2 = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.multival_attribute2 := NULL;
    END IF;

    IF l_LIMITS_rec.multival_attr2_datatype = FND_API.G_MISS_CHAR THEN
        l_LIMITS_rec.multival_attr2_datatype := NULL;
    END IF;

    RETURN l_LIMITS_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
)

IS
l_check_active_flag VARCHAR2(1);
l_active_flag VARCHAR2(1);
l_LIMITS_rec1              QP_Limits_PUB.Limits_Rec_Type;
l_LIMITS_rec               QP_Limits_PUB.Limits_Rec_Type;
x_retcode                  NUMBER;
x_errbuf                   VARCHAR2(250);
BEGIN

    l_LIMITS_rec := p_LIMITS_rec;
    l_LIMITS_rec1 := Query_Row(p_LIMITS_rec.limit_id);

    SELECT active_flag
       INTO   l_active_flag
       FROM   QP_LIST_HEADERS_B
       WHERE  list_header_id=p_LIMITS_rec.list_header_id;

    UPDATE  QP_LIMITS
    SET     AMOUNT                         = p_LIMITS_rec.amount
    ,       ATTRIBUTE1                     = p_LIMITS_rec.attribute1
    ,       ATTRIBUTE10                    = p_LIMITS_rec.attribute10
    ,       ATTRIBUTE11                    = p_LIMITS_rec.attribute11
    ,       ATTRIBUTE12                    = p_LIMITS_rec.attribute12
    ,       ATTRIBUTE13                    = p_LIMITS_rec.attribute13
    ,       ATTRIBUTE14                    = p_LIMITS_rec.attribute14
    ,       ATTRIBUTE15                    = p_LIMITS_rec.attribute15
    ,       ATTRIBUTE2                     = p_LIMITS_rec.attribute2
    ,       ATTRIBUTE3                     = p_LIMITS_rec.attribute3
    ,       ATTRIBUTE4                     = p_LIMITS_rec.attribute4
    ,       ATTRIBUTE5                     = p_LIMITS_rec.attribute5
    ,       ATTRIBUTE6                     = p_LIMITS_rec.attribute6
    ,       ATTRIBUTE7                     = p_LIMITS_rec.attribute7
    ,       ATTRIBUTE8                     = p_LIMITS_rec.attribute8
    ,       ATTRIBUTE9                     = p_LIMITS_rec.attribute9
    ,       BASIS                          = p_LIMITS_rec.basis
    ,       CONTEXT                        = p_LIMITS_rec.context
    ,       CREATED_BY                     = p_LIMITS_rec.created_by
    ,       CREATION_DATE                  = p_LIMITS_rec.creation_date
    ,       LAST_UPDATED_BY                = p_LIMITS_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_LIMITS_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_LIMITS_rec.last_update_login
    ,       LIMIT_EXCEED_ACTION_CODE       = p_LIMITS_rec.limit_exceed_action_code
    ,       LIMIT_HOLD_FLAG                = p_LIMITS_rec.limit_hold_flag
    ,       LIMIT_ID                       = p_LIMITS_rec.limit_id
    ,       LIMIT_LEVEL_CODE               = p_LIMITS_rec.limit_level_code
    ,       LIMIT_NUMBER                   = p_LIMITS_rec.limit_number
    ,       LIST_HEADER_ID                 = p_LIMITS_rec.list_header_id
    ,       LIST_LINE_ID                   = p_LIMITS_rec.list_line_id
    ,       MULTIVAL_ATTR1_TYPE            = p_LIMITS_rec.multival_attr1_type
    ,       MULTIVAL_ATTR1_CONTEXT         = p_LIMITS_rec.multival_attr1_context
    ,       MULTIVAL_ATTRIBUTE1            = p_LIMITS_rec.multival_attribute1
    ,       MULTIVAL_ATTR1_DATATYPE        = p_LIMITS_rec.multival_attr1_datatype
    ,       MULTIVAL_ATTR2_TYPE            = p_LIMITS_rec.multival_attr2_type
    ,       MULTIVAL_ATTR2_CONTEXT         = p_LIMITS_rec.multival_attr2_context
    ,       MULTIVAL_ATTRIBUTE2            = p_LIMITS_rec.multival_attribute2
    ,       MULTIVAL_ATTR2_DATATYPE        = p_LIMITS_rec.multival_attr2_datatype
    ,       ORGANIZATION_FLAG              = p_LIMITS_rec.organization_flag
    ,       PROGRAM_APPLICATION_ID         = p_LIMITS_rec.program_application_id
    ,       PROGRAM_ID                     = p_LIMITS_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_LIMITS_rec.program_update_date
    ,       REQUEST_ID                     = p_LIMITS_rec.request_id
    WHERE   LIMIT_ID = p_LIMITS_rec.limit_id
    ;
    l_LIMITS_rec.operation := QP_GLOBALS.g_opr_update;

l_check_active_flag:=nvl(fnd_profile.value('QP_BUILD_ATTRIBUTES_MAPPING_OPTIONS'),'N');
IF (l_check_active_flag='N') OR (l_check_active_flag='Y' AND l_active_flag='Y') THEN

  IF(p_LIMITS_rec.multival_attr1_context IS NOT NULL) AND
    (p_LIMITS_rec.multival_attribute1 IS NOT NULL) THEN
         UPDATE qp_pte_segments SET used_in_setup='Y'
         WHERE nvl(used_in_setup,'N')='N'
         AND segment_id IN
        (SELECT a.segment_id
         FROM   qp_segments_b a,qp_prc_contexts_b b
         WHERE  a.segment_mapping_column=p_LIMITS_rec.multival_attribute1
         AND    a.prc_context_id=b.prc_context_id
         AND b.prc_context_type = p_LIMITS_rec.multival_attr1_type
         AND    b.prc_context_code=p_LIMITS_rec.multival_attr1_context);
  END IF;

    IF(p_LIMITS_rec.multival_attr2_context IS NOT NULL) AND
      (p_LIMITS_rec.multival_attribute2 IS NOT NULL) THEN
      UPDATE qp_pte_segments SET used_in_setup='Y'
      WHERE nvl(used_in_setup,'N')='N'
      AND segment_id IN
      (SELECT a.segment_id
      FROM   qp_segments_b a,qp_prc_contexts_b b
      WHERE  a.segment_mapping_column=p_LIMITS_rec.multival_attribute2
      AND    a.prc_context_id=b.prc_context_id
      AND b.prc_context_type = p_LIMITS_rec.multival_attr2_type
      AND    b.prc_context_code=p_LIMITS_rec.multival_attr2_context);
   END IF;
END IF;

    Update_List_Header_And_Line(l_LIMITS_rec);


    IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.amount
                           ,l_limits_rec1.amount)
    THEN
       QP_LIMIT_CONC_REQ.UPDATE_BALANCES(x_retcode
                                        ,x_errbuf
                                        ,null
                                        ,null
                                        ,p_LIMITS_rec.limit_id
                                        ,null);
       IF x_retcode = 2 THEN
          OE_MSG_PUB.Add_Exc_Msg
          (   G_PKG_NAME
          ,   'UPDATE_BALANCES'
          );
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
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
(   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
)

IS
l_check_active_flag VARCHAR2(1);
l_active_flag VARCHAR2(1);
l_LIMITS_rec        QP_Limits_PUB.Limits_Rec_Type;

    --dbms_output.put_line('Begin Insert Row');
BEGIN
    l_LIMITS_rec := p_LIMITS_rec;
SELECT active_flag
       INTO   l_active_flag
       FROM   QP_LIST_HEADERS_B
       WHERE  list_header_id=p_LIMITS_rec.list_header_id;

    INSERT  INTO QP_LIMITS
    (       AMOUNT
    ,       ATTRIBUTE1
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
    ,       BASIS
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIMIT_EXCEED_ACTION_CODE
    ,       LIMIT_HOLD_FLAG
    ,       LIMIT_ID
    ,       LIMIT_LEVEL_CODE
    ,       LIMIT_NUMBER
    ,       LIST_HEADER_ID
    ,       LIST_LINE_ID
    ,       MULTIVAL_ATTR1_TYPE
    ,       MULTIVAL_ATTR1_CONTEXT
    ,       MULTIVAL_ATTRIBUTE1
    ,       MULTIVAL_ATTR1_DATATYPE
    ,       MULTIVAL_ATTR2_TYPE
    ,       MULTIVAL_ATTR2_CONTEXT
    ,       MULTIVAL_ATTRIBUTE2
    ,       MULTIVAL_ATTR2_DATATYPE
    ,       ORGANIZATION_FLAG
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    )
    VALUES
    (       p_LIMITS_rec.amount
    ,       p_LIMITS_rec.attribute1
    ,       p_LIMITS_rec.attribute10
    ,       p_LIMITS_rec.attribute11
    ,       p_LIMITS_rec.attribute12
    ,       p_LIMITS_rec.attribute13
    ,       p_LIMITS_rec.attribute14
    ,       p_LIMITS_rec.attribute15
    ,       p_LIMITS_rec.attribute2
    ,       p_LIMITS_rec.attribute3
    ,       p_LIMITS_rec.attribute4
    ,       p_LIMITS_rec.attribute5
    ,       p_LIMITS_rec.attribute6
    ,       p_LIMITS_rec.attribute7
    ,       p_LIMITS_rec.attribute8
    ,       p_LIMITS_rec.attribute9
    ,       p_LIMITS_rec.basis
    ,       p_LIMITS_rec.context
    ,       p_LIMITS_rec.created_by
    ,       p_LIMITS_rec.creation_date
    ,       p_LIMITS_rec.last_updated_by
    ,       p_LIMITS_rec.last_update_date
    ,       p_LIMITS_rec.last_update_login
    ,       p_LIMITS_rec.limit_exceed_action_code
    ,       p_LIMITS_rec.limit_hold_flag
    ,       p_LIMITS_rec.limit_id
    ,       p_LIMITS_rec.limit_level_code
    ,       p_LIMITS_rec.limit_number
    ,       p_LIMITS_rec.list_header_id
    ,       p_LIMITS_rec.list_line_id
    ,       p_LIMITS_rec.multival_attr1_type
    ,       p_LIMITS_rec.multival_attr1_context
    ,       p_LIMITS_rec.multival_attribute1
    ,       p_LIMITS_rec.multival_attr1_datatype
    ,       p_LIMITS_rec.multival_attr2_type
    ,       p_LIMITS_rec.multival_attr2_context
    ,       p_LIMITS_rec.multival_attribute2
    ,       p_LIMITS_rec.multival_attr2_datatype
    ,       p_LIMITS_rec.organization_flag
    ,       p_LIMITS_rec.program_application_id
    ,       p_LIMITS_rec.program_id
    ,       p_LIMITS_rec.program_update_date
    ,       p_LIMITS_rec.request_id
    );
    l_LIMITS_rec.operation := QP_GLOBALS.g_opr_create;
    Update_List_Header_And_Line(l_LIMITS_rec);
    --dbms_output.put_line('End Insert Row');
l_check_active_flag:=nvl(fnd_profile.value('QP_BUILD_ATTRIBUTES_MAPPING_OPTIONS'),'N');
IF (l_check_active_flag='N') OR (l_check_active_flag='Y' AND l_active_flag='Y') THEN
IF(p_LIMITS_rec.multival_attr1_context IS NOT NULL) AND
  (p_LIMITS_rec.multival_attribute1 IS NOT NULL) THEN
UPDATE qp_pte_segments SET used_in_setup='Y'
WHERE nvl(used_in_setup,'N')='N'
AND segment_id IN
(SELECT a.segment_id
 FROM   qp_segments_b a,qp_prc_contexts_b b
 WHERE  a.segment_mapping_column=p_LIMITS_rec.multival_attribute1
 AND    a.prc_context_id=b.prc_context_id
 AND b.prc_context_type = p_LIMITS_rec.multival_attr1_type
 AND    b.prc_context_code=p_LIMITS_rec.multival_attr1_context);
END IF;

IF(p_LIMITS_rec.multival_attr2_context IS NOT NULL) AND
  (p_LIMITS_rec.multival_attribute2 IS NOT NULL) THEN
UPDATE qp_pte_segments SET used_in_setup='Y'
WHERE nvl(used_in_setup,'N')='N'
AND segment_id IN
(SELECT a.segment_id
 FROM   qp_segments_b a,qp_prc_contexts_b b
 WHERE  a.segment_mapping_column=p_LIMITS_rec.multival_attribute2
 AND    a.prc_context_id=b.prc_context_id
 AND b.prc_context_type = p_LIMITS_rec.multival_attr2_type
 AND    b.prc_context_code=p_LIMITS_rec.multival_attr2_context);
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
(   p_limit_id                      IN  NUMBER
)

IS
l_limits_rec     QP_Limits_PUB.Limits_Rec_Type;
BEGIN

    l_limits_rec :=  Query_Row(p_limit_id);

     l_limits_rec.operation := QP_GLOBALS.g_opr_delete;
    --dbms_output.put_line('In Delete_Row ..' || 'Header ' || l_limits_rec.list_header_id || ' line ' || l_limits_rec.list_line_id);

    DELETE  FROM QP_LIMITS
    WHERE   LIMIT_ID = p_limit_id;

    Update_List_Header_And_Line(l_limits_rec);



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
(   p_limit_id                      IN  NUMBER
) RETURN QP_Limits_PUB.Limits_Rec_Type
IS
l_LIMITS_rec                  QP_Limits_PUB.Limits_Rec_Type;
BEGIN

    SELECT  AMOUNT
    ,       ATTRIBUTE1
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
    ,       BASIS
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIMIT_EXCEED_ACTION_CODE
    ,       LIMIT_HOLD_FLAG
    ,       LIMIT_ID
    ,       LIMIT_LEVEL_CODE
    ,       LIMIT_NUMBER
    ,       LIST_HEADER_ID
    ,       LIST_LINE_ID
    ,       MULTIVAL_ATTR1_TYPE
    ,       MULTIVAL_ATTR1_CONTEXT
    ,       MULTIVAL_ATTRIBUTE1
    ,       MULTIVAL_ATTR1_DATATYPE
    ,       MULTIVAL_ATTR2_TYPE
    ,       MULTIVAL_ATTR2_CONTEXT
    ,       MULTIVAL_ATTRIBUTE2
    ,       MULTIVAL_ATTR2_DATATYPE
    ,       ORGANIZATION_FLAG
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    INTO    l_LIMITS_rec.amount
    ,       l_LIMITS_rec.attribute1
    ,       l_LIMITS_rec.attribute10
    ,       l_LIMITS_rec.attribute11
    ,       l_LIMITS_rec.attribute12
    ,       l_LIMITS_rec.attribute13
    ,       l_LIMITS_rec.attribute14
    ,       l_LIMITS_rec.attribute15
    ,       l_LIMITS_rec.attribute2
    ,       l_LIMITS_rec.attribute3
    ,       l_LIMITS_rec.attribute4
    ,       l_LIMITS_rec.attribute5
    ,       l_LIMITS_rec.attribute6
    ,       l_LIMITS_rec.attribute7
    ,       l_LIMITS_rec.attribute8
    ,       l_LIMITS_rec.attribute9
    ,       l_LIMITS_rec.basis
    ,       l_LIMITS_rec.context
    ,       l_LIMITS_rec.created_by
    ,       l_LIMITS_rec.creation_date
    ,       l_LIMITS_rec.last_updated_by
    ,       l_LIMITS_rec.last_update_date
    ,       l_LIMITS_rec.last_update_login
    ,       l_LIMITS_rec.limit_exceed_action_code
    ,       l_LIMITS_rec.limit_hold_flag
    ,       l_LIMITS_rec.limit_id
    ,       l_LIMITS_rec.limit_level_code
    ,       l_LIMITS_rec.limit_number
    ,       l_LIMITS_rec.list_header_id
    ,       l_LIMITS_rec.list_line_id
    ,       l_LIMITS_rec.multival_attr1_type
    ,       l_LIMITS_rec.multival_attr1_context
    ,       l_LIMITS_rec.multival_attribute1
    ,       l_LIMITS_rec.multival_attr1_datatype
    ,       l_LIMITS_rec.multival_attr2_type
    ,       l_LIMITS_rec.multival_attr2_context
    ,       l_LIMITS_rec.multival_attribute2
    ,       l_LIMITS_rec.multival_attr2_datatype
    ,       l_LIMITS_rec.organization_flag
    ,       l_LIMITS_rec.program_application_id
    ,       l_LIMITS_rec.program_id
    ,       l_LIMITS_rec.program_update_date
    ,       l_LIMITS_rec.request_id
    FROM    QP_LIMITS
    WHERE   LIMIT_ID = p_limit_id
    ;

    RETURN l_LIMITS_rec;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
    RETURN l_LIMITS_rec;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Row;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
,   x_LIMITS_rec                    OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limits_Rec_Type
)
IS
l_LIMITS_rec                  QP_Limits_PUB.Limits_Rec_Type;
BEGIN

    SELECT  AMOUNT
    ,       ATTRIBUTE1
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
    ,       BASIS
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIMIT_EXCEED_ACTION_CODE
    ,       LIMIT_HOLD_FLAG
    ,       LIMIT_ID
    ,       LIMIT_LEVEL_CODE
    ,       LIMIT_NUMBER
    ,       LIST_HEADER_ID
    ,       LIST_LINE_ID
    ,       MULTIVAL_ATTR1_TYPE
    ,       MULTIVAL_ATTR1_CONTEXT
    ,       MULTIVAL_ATTRIBUTE1
    ,       MULTIVAL_ATTR1_DATATYPE
    ,       MULTIVAL_ATTR2_TYPE
    ,       MULTIVAL_ATTR2_CONTEXT
    ,       MULTIVAL_ATTRIBUTE2
    ,       MULTIVAL_ATTR2_DATATYPE
    ,       ORGANIZATION_FLAG
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    INTO    l_LIMITS_rec.amount
    ,       l_LIMITS_rec.attribute1
    ,       l_LIMITS_rec.attribute10
    ,       l_LIMITS_rec.attribute11
    ,       l_LIMITS_rec.attribute12
    ,       l_LIMITS_rec.attribute13
    ,       l_LIMITS_rec.attribute14
    ,       l_LIMITS_rec.attribute15
    ,       l_LIMITS_rec.attribute2
    ,       l_LIMITS_rec.attribute3
    ,       l_LIMITS_rec.attribute4
    ,       l_LIMITS_rec.attribute5
    ,       l_LIMITS_rec.attribute6
    ,       l_LIMITS_rec.attribute7
    ,       l_LIMITS_rec.attribute8
    ,       l_LIMITS_rec.attribute9
    ,       l_LIMITS_rec.basis
    ,       l_LIMITS_rec.context
    ,       l_LIMITS_rec.created_by
    ,       l_LIMITS_rec.creation_date
    ,       l_LIMITS_rec.last_updated_by
    ,       l_LIMITS_rec.last_update_date
    ,       l_LIMITS_rec.last_update_login
    ,       l_LIMITS_rec.limit_exceed_action_code
    ,       l_LIMITS_rec.limit_hold_flag
    ,       l_LIMITS_rec.limit_id
    ,       l_LIMITS_rec.limit_level_code
    ,       l_LIMITS_rec.limit_number
    ,       l_LIMITS_rec.list_header_id
    ,       l_LIMITS_rec.list_line_id
    ,       l_LIMITS_rec.multival_attr1_type
    ,       l_LIMITS_rec.multival_attr1_context
    ,       l_LIMITS_rec.multival_attribute1
    ,       l_LIMITS_rec.multival_attr1_datatype
    ,       l_LIMITS_rec.multival_attr2_type
    ,       l_LIMITS_rec.multival_attr2_context
    ,       l_LIMITS_rec.multival_attribute2
    ,       l_LIMITS_rec.multival_attr2_datatype
    ,       l_LIMITS_rec.organization_flag
    ,       l_LIMITS_rec.program_application_id
    ,       l_LIMITS_rec.program_id
    ,       l_LIMITS_rec.program_update_date
    ,       l_LIMITS_rec.request_id
    FROM    QP_LIMITS
    WHERE   LIMIT_ID = p_LIMITS_rec.limit_id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  QP_GLOBALS.Equal(p_LIMITS_rec.amount,
                         l_LIMITS_rec.amount)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.attribute1,
                         l_LIMITS_rec.attribute1)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.attribute10,
                         l_LIMITS_rec.attribute10)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.attribute11,
                         l_LIMITS_rec.attribute11)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.attribute12,
                         l_LIMITS_rec.attribute12)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.attribute13,
                         l_LIMITS_rec.attribute13)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.attribute14,
                         l_LIMITS_rec.attribute14)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.attribute15,
                         l_LIMITS_rec.attribute15)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.attribute2,
                         l_LIMITS_rec.attribute2)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.attribute3,
                         l_LIMITS_rec.attribute3)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.attribute4,
                         l_LIMITS_rec.attribute4)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.attribute5,
                         l_LIMITS_rec.attribute5)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.attribute6,
                         l_LIMITS_rec.attribute6)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.attribute7,
                         l_LIMITS_rec.attribute7)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.attribute8,
                         l_LIMITS_rec.attribute8)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.attribute9,
                         l_LIMITS_rec.attribute9)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.basis,
                         l_LIMITS_rec.basis)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.context,
                         l_LIMITS_rec.context)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.created_by,
                         l_LIMITS_rec.created_by)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.creation_date,
                         l_LIMITS_rec.creation_date)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.last_updated_by,
                         l_LIMITS_rec.last_updated_by)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.last_update_date,
                         l_LIMITS_rec.last_update_date)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.last_update_login,
                         l_LIMITS_rec.last_update_login)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.limit_exceed_action_code,
                         l_LIMITS_rec.limit_exceed_action_code)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.limit_hold_flag,
                         l_LIMITS_rec.limit_hold_flag)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.limit_id,
                         l_LIMITS_rec.limit_id)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.limit_level_code,
                         l_LIMITS_rec.limit_level_code)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.limit_number,
                         l_LIMITS_rec.limit_number)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.list_header_id,
                         l_LIMITS_rec.list_header_id)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.list_line_id,
                         l_LIMITS_rec.list_line_id)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.multival_attr1_type,
                         l_LIMITS_rec.multival_attr1_type)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.multival_attr1_context,
                         l_LIMITS_rec.multival_attr1_context)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.multival_attribute1,
                         l_LIMITS_rec.multival_attribute1)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.multival_attr1_datatype,
                         l_LIMITS_rec.multival_attr1_datatype)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.multival_attr2_type,
                         l_LIMITS_rec.multival_attr2_type)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.multival_attr2_context,
                         l_LIMITS_rec.multival_attr2_context)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.multival_attribute2,
                         l_LIMITS_rec.multival_attribute2)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.multival_attr2_datatype,
                         l_LIMITS_rec.multival_attr2_datatype)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.organization_flag,
                         l_LIMITS_rec.organization_flag)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.program_application_id,
                         l_LIMITS_rec.program_application_id)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.program_id,
                         l_LIMITS_rec.program_id)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.program_update_date,
                         l_LIMITS_rec.program_update_date)
    AND QP_GLOBALS.Equal(p_LIMITS_rec.request_id,
                         l_LIMITS_rec.request_id)
    THEN

        --  Row has not changed. Set out parameter.

        x_LIMITS_rec                   := l_LIMITS_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_LIMITS_rec.return_status     := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_LIMITS_rec.return_status     := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_CHANGED');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_LIMITS_rec.return_status     := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_DELETED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_LIMITS_rec.return_status     := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_LIMITS_rec.return_status     := FND_API.G_RET_STS_UNEXP_ERROR;

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
(   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
,   p_old_LIMITS_rec                IN  QP_Limits_PUB.Limits_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMITS_REC
) RETURN QP_Limits_PUB.Limits_Val_Rec_Type
IS
l_LIMITS_val_rec              QP_Limits_PUB.Limits_Val_Rec_Type;
BEGIN

    IF p_LIMITS_rec.limit_exceed_action_code IS NOT NULL AND
        p_LIMITS_rec.limit_exceed_action_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_LIMITS_rec.limit_exceed_action_code,
        p_old_LIMITS_rec.limit_exceed_action_code)
    THEN
        l_LIMITS_val_rec.limit_exceed_action := QP_Id_To_Value.Limit_Exceed_Action
        (   p_limit_exceed_action_code    => p_LIMITS_rec.limit_exceed_action_code
        );
    END IF;

    IF p_LIMITS_rec.limit_id IS NOT NULL AND
        p_LIMITS_rec.limit_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_LIMITS_rec.limit_id,
        p_old_LIMITS_rec.limit_id)
    THEN
        l_LIMITS_val_rec.limit := QP_Id_To_Value.Limit
        (   p_limit_id                    => p_LIMITS_rec.limit_id
        );
    END IF;

    IF p_LIMITS_rec.limit_level_code IS NOT NULL AND
        p_LIMITS_rec.limit_level_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_LIMITS_rec.limit_level_code,
        p_old_LIMITS_rec.limit_level_code)
    THEN
        l_LIMITS_val_rec.limit_level := QP_Id_To_Value.Limit_Level
        (   p_limit_level_code            => p_LIMITS_rec.limit_level_code
        );
    END IF;

    IF p_LIMITS_rec.list_header_id IS NOT NULL AND
        p_LIMITS_rec.list_header_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_LIMITS_rec.list_header_id,
        p_old_LIMITS_rec.list_header_id)
    THEN
        l_LIMITS_val_rec.list_header := QP_Id_To_Value.List_Header
        (   p_list_header_id              => p_LIMITS_rec.list_header_id
        );
    END IF;

    IF p_LIMITS_rec.list_line_id IS NOT NULL AND
        p_LIMITS_rec.list_line_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_LIMITS_rec.list_line_id,
        p_old_LIMITS_rec.list_line_id)
    THEN
        l_LIMITS_val_rec.list_line := QP_Id_To_Value.List_Line
        (   p_list_line_id                => p_LIMITS_rec.list_line_id
        );
    END IF;

    IF p_LIMITS_rec.organization_flag IS NOT NULL AND
        p_LIMITS_rec.organization_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_LIMITS_rec.organization_flag,
        p_old_LIMITS_rec.organization_flag)
    THEN
        l_LIMITS_val_rec.organization := QP_Id_To_Value.Organization
        (   p_organization_flag           => p_LIMITS_rec.organization_flag
        );
    END IF;

    -- Commented out this code to eliminate the compilation error.....

    RETURN l_LIMITS_val_rec;

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
,   p_LIMITS_val_rec                IN  QP_Limits_PUB.Limits_Val_Rec_Type
) RETURN QP_Limits_PUB.Limits_Rec_Type
IS
l_LIMITS_rec                  QP_Limits_PUB.Limits_Rec_Type;
BEGIN

    --  initialize  return_status.

    l_LIMITS_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_LIMITS_rec.

    l_LIMITS_rec := p_LIMITS_rec;

    IF  p_LIMITS_val_rec.limit_exceed_action <> FND_API.G_MISS_CHAR
    THEN

        IF p_LIMITS_rec.limit_exceed_action_code <> FND_API.G_MISS_CHAR THEN

            l_LIMITS_rec.limit_exceed_action_code := p_LIMITS_rec.limit_exceed_action_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit_exceed_action');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_LIMITS_rec.limit_exceed_action_code := QP_Value_To_Id.limit_exceed_action
            (   p_limit_exceed_action         => p_LIMITS_val_rec.limit_exceed_action
            );

            IF l_LIMITS_rec.limit_exceed_action_code = FND_API.G_MISS_CHAR THEN
                l_LIMITS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_LIMITS_val_rec.limit <> FND_API.G_MISS_CHAR
    THEN

        IF p_LIMITS_rec.limit_id <> FND_API.G_MISS_NUM THEN

            l_LIMITS_rec.limit_id := p_LIMITS_rec.limit_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_LIMITS_rec.limit_id := QP_Value_To_Id.limit
            (   p_limit                       => p_LIMITS_val_rec.limit
            );

            IF l_LIMITS_rec.limit_id = FND_API.G_MISS_NUM THEN
                l_LIMITS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_LIMITS_val_rec.limit_level <> FND_API.G_MISS_CHAR
    THEN

        IF p_LIMITS_rec.limit_level_code <> FND_API.G_MISS_CHAR THEN

            l_LIMITS_rec.limit_level_code := p_LIMITS_rec.limit_level_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit_level');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_LIMITS_rec.limit_level_code := QP_Value_To_Id.limit_level
            (   p_limit_level                 => p_LIMITS_val_rec.limit_level
            );

            IF l_LIMITS_rec.limit_level_code = FND_API.G_MISS_CHAR THEN
                l_LIMITS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_LIMITS_val_rec.list_header <> FND_API.G_MISS_CHAR
    THEN

        IF p_LIMITS_rec.list_header_id <> FND_API.G_MISS_NUM THEN

            l_LIMITS_rec.list_header_id := p_LIMITS_rec.list_header_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_header');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_LIMITS_rec.list_header_id := QP_Value_To_Id.list_header
            (   p_list_header                 => p_LIMITS_val_rec.list_header
            );

            IF l_LIMITS_rec.list_header_id = FND_API.G_MISS_NUM THEN
                l_LIMITS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_LIMITS_val_rec.list_line <> FND_API.G_MISS_CHAR
    THEN

        IF p_LIMITS_rec.list_line_id <> FND_API.G_MISS_NUM THEN

            l_LIMITS_rec.list_line_id := p_LIMITS_rec.list_line_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_line');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_LIMITS_rec.list_line_id := QP_Value_To_Id.list_line
            (   p_list_line                   => p_LIMITS_val_rec.list_line
            );

            IF l_LIMITS_rec.list_line_id = FND_API.G_MISS_NUM THEN
                l_LIMITS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_LIMITS_val_rec.organization <> FND_API.G_MISS_CHAR
    THEN

        IF p_LIMITS_rec.organization_flag <> FND_API.G_MISS_CHAR THEN

            l_LIMITS_rec.organization_flag := p_LIMITS_rec.organization_flag;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','organization');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_LIMITS_rec.organization_flag := QP_Value_To_Id.organization
            (   p_organization                => p_LIMITS_val_rec.organization
            );

            IF l_LIMITS_rec.organization_flag = FND_API.G_MISS_CHAR THEN
                l_LIMITS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    RETURN l_LIMITS_rec;

END Get_Ids;

Procedure Pre_Write_Process
(   p_LIMITS_rec                      IN  QP_Limits_PUB.Limits_Rec_Type
,   p_old_LIMITS_rec                  IN  QP_Limits_PUB.Limits_Rec_Type :=
                                                QP_Limits_PUB.G_MISS_LIMITS_REC
,   x_LIMITS_rec                      OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limits_Rec_Type
) IS

l_LIMITS_rec              	QP_Limits_PUB.Limits_Rec_Type := p_LIMITS_rec;
l_return_status       		varchar2(30);

BEGIN


    qp_delayed_requests_PVT.log_request
        (
        p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
        p_entity_id  => p_LIMITS_rec.limit_id,
        p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_ALL,
        p_requesting_entity_id => p_LIMITS_rec.limit_id,
        p_request_type => QP_GLOBALS.G_UPDATE_LIMITS_COLUMNS,
        x_return_status => l_return_status
        );

null;
x_LIMITS_rec := l_LIMITS_rec;

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


END QP_Limits_Util;

/
