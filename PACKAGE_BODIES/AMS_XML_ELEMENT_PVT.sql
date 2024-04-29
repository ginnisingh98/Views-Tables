--------------------------------------------------------
--  DDL for Package Body AMS_XML_ELEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_XML_ELEMENT_PVT" as
/* $Header: amsvxelb.pls 115.10 2003/03/06 17:25:38 huili noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Xml_Element_PVT
-- Purpose
--   Manage XML Elements.
--
-- History
--   05/13/2002 DMVINCEN  Created.
--   05/21/2002 DMVINCEN BUG 2380113: Removed G_USER_ID and G_LOGIN_ID.
--   05/21/2002 DMVINCEN Removed created_by and creation_date from update.
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Xml_Element_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvxelb.pls';
G_B2B_VIEW_NAME CONSTANT VARCHAR2(100) := 'AMS_HZ_B2B_MAPPING_V';
G_B2C_VIEW_NAME CONSTANT VARCHAR2(100) := 'AMS_HZ_B2C_MAPPING_V';

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE write_msg(p_message IN VARCHAR2)
IS
BEGIN
     --insert into imp_xml_test values (TO_CHAR(DBMS_UTILITY.get_time)
	  --		||'::::' || p_message);
	  --commit;
	  null;
END;


PROCEDURE Update_Xml_Source_Lines_Util (
	p_view_name						IN		VARCHAR2,
	p_commit							IN		VARCHAR2,
	p_column_name					IN		VARCHAR2,
	p_prim_key						IN		NUMBER,
	p_xml_elements_data			IN		varchar2_2000_set_type,
	p_xml_elements_col_name		IN		varchar2_2000_set_type,
	x_return_status            OUT NOCOPY   VARCHAR2,
	x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2
)
IS

	l_update_statement VARCHAR2(2000) := ' UPDATE ' || p_view_name
		|| ' SET LOAD_STATUS = ''RELOAD'' ';
	l_status integer;
	g_cursor INT DEFAULT dbms_sql.open_cursor;

   l_error VARCHAR2(2000);
BEGIN
	FOR i IN p_xml_elements_col_name.FIRST .. p_xml_elements_col_name.LAST
	LOOP
		l_update_statement := l_update_statement || ',' || p_xml_elements_col_name(i)
			|| '=:v' || i;
	END LOOP;

	l_update_statement := l_update_statement || ' WHERE '
		|| p_column_name || '=:p1';

	write_msg(' l_update_statement::' || l_update_statement);

	BEGIN
		write_msg(' test1::');

		dbms_sql.parse (g_cursor, l_update_statement, dbms_sql.native);

		write_msg(' test2::');
		FOR j IN p_xml_elements_data.FIRST .. p_xml_elements_data.LAST
		LOOP
			write_msg(' test3::');
			dbms_sql.bind_variable (g_cursor, ':v' || j, p_xml_elements_data(j));
		END LOOP;

		write_msg(' test4::');
		dbms_sql.bind_variable (g_cursor, ':p1', p_prim_key);

		l_status := dbms_sql.EXECUTE(g_cursor);
		dbms_sql.close_cursor (g_cursor);

		EXCEPTION
			WHEN OTHERS THEN
				dbms_sql.close_cursor (g_cursor);
				--IF (AMS_DEBUG_HIGH_ON) THENAMS_UTILITY_PVT.debug_message('Error Update_Xml_Source_Lines_Util in cursor execution');END IF;
				l_error := SQLERRM;
				IF (AMS_DEBUG_HIGH_ON) THEN

				AMS_UTILITY_PVT.debug_message(l_error);
				END IF;
				--write_msg(' test5::' || l_error);
				RAISE FND_API.G_EXC_ERROR;
	END;

	-- Standard check for p_commit
	IF FND_API.to_Boolean( p_commit) THEN
		COMMIT WORK;
	END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     --IF (AMS_DEBUG_HIGH_ON) THENAMS_UTILITY_PVT.debug_message('Private API: Update_Xml_Source_Lines_Util expected');END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --IF (AMS_DEBUG_HIGH_ON) THENAMS_UTILITY_PVT.debug_message('Private API: Update_Xml_Source_Lines_Util unexpected');END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --IF (AMS_DEBUG_HIGH_ON) THENAMS_UTILITY_PVT.debug_message('Private API: Update_Xml_Source_Lines_Util OTHERS');END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END Update_Xml_Source_Lines_Util;

PROCEDURE Update_B2C_Xml_Source_lines (
	 x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_xml_element_rec            IN   AMS_IMP_XML_ELEMENTS%ROWTYPE,
	 p_xml_element_ids            IN   num_data_set_type_w,
	 p_xml_elements_data          IN   varchar2_2000_set_type,
	 p_xml_elements_col_name      IN   varchar2_2000_set_type,
	 p_commit							IN		VARCHAR2
)
IS
	l_column_name AMS_IMP_XML_ELEMENTS.COLUMN_NAME%TYPE;
	l_source_system_column_name VARCHAR2(2000);
	l_update_element_id NUMBER;
	l_element_rec AMS_IMP_XML_ELEMENTS%ROWTYPE;

BEGIN
	l_column_name := UPPER (p_xml_element_rec.COLUMN_NAME);
	write_msg(' l_column_name::'||l_column_name );
	IF l_column_name IS NOT NULL AND l_column_name = 'PERSON' THEN -- PERSON
	--('PERSON', 'PERSON_FIRST_NAME', 'PERSON_MIDDLE_NAME',
	--	'PERSON_LAST_NAME', 'PERSON_NAME_SUFFIX', 'PERSON_TITLE', 'SALUTATION', 'PARTY_ID') THEN --PERSON
		l_source_system_column_name := 'PER_IMP_XML_ELEMENT_ID';
	ELSIF l_column_name IS NOT NULL AND l_column_name = 'ADDRESS' THEN -- ADDRESS
	--	('ADDRESS', 'ADDRESS1', 'ADDRESS2', 'ADDRESS3', 'ADDRESS4',
	--	 'CITY', 'COUNTY', 'PROVINCE', 'STATE', 'POSTAL_CODE',
	--	 'COUNTRY', 'ADDRESS_LINES_PHONETIC', 'PO_BOX_NUMBER',
	--	 'HOUSE_NUMBER', 'STREET_SUFFIX', 'STREET', 'STREET_NUMBER',
	--	 'FLOOR', 'SUITE', 'POSTAL_PLUS4_CODE', 'IDENTIFYING_ADDRESS_FLAG') 	THEN
		l_source_system_column_name := 'ADD_IMP_XML_ELEMENT_ID';
	ELSIF l_column_name IS NOT NULL AND l_column_name = 'PHONE_INFO' THEN --PHONE_INFO
	-- ('PHONE_INFO', 'PHONE_COUNTRY_CODE', 'PHONE_AREA_CODE', 'PHONE_NUMBER', 'PHONE_EXTENSION')	THEN
		l_source_system_column_name := 'CP_IMP_XML_ELEMENT_ID';
	ELSIF l_column_name IS NOT NULL AND l_column_name = 'EMAIL_INFO' THEN --EMAIL_INFO
		l_source_system_column_name := 'EM_IMP_XML_ELEMENT_ID';
	END IF;

	Update_Xml_Source_Lines_Util (
		p_view_name						=> G_B2C_VIEW_NAME,
		p_commit							=> p_commit,
		p_column_name					=> l_source_system_column_name,
		p_prim_key						=> p_xml_element_rec.IMP_XML_ELEMENT_ID,
		p_xml_elements_data			=> p_xml_elements_data,
		p_xml_elements_col_name		=> p_xml_elements_col_name,
		x_return_status            => x_return_status,
		x_msg_count                => x_msg_count,
		x_msg_data                 => x_msg_data
	);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     --IF (AMS_DEBUG_HIGH_ON) THENAMS_UTILITY_PVT.debug_message('Private API: Update_B2B_Xml_Source_lines expected');END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --IF (AMS_DEBUG_HIGH_ON) THENAMS_UTILITY_PVT.debug_message('Private API: Update_B2B_Xml_Source_lines unexpected');END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --IF (AMS_DEBUG_HIGH_ON) THENAMS_UTILITY_PVT.debug_message('Private API: Update_B2B_Xml_Source_lines OTHERS');END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END;

PROCEDURE Update_B2B_Xml_Source_lines (
	 x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_xml_element_rec            IN   AMS_IMP_XML_ELEMENTS%ROWTYPE,
	 p_xml_element_ids            IN   num_data_set_type_w,
	 p_xml_elements_data          IN   varchar2_2000_set_type,
	 p_xml_elements_col_name      IN   varchar2_2000_set_type,
	 p_commit                     IN   VARCHAR2
)
IS
	l_column_name AMS_IMP_XML_ELEMENTS.COLUMN_NAME%TYPE;
	l_source_system_column_name VARCHAR2(2000);
	l_update_element_id NUMBER;
	l_element_rec AMS_IMP_XML_ELEMENTS%ROWTYPE;

	l_update_statement VARCHAR2(2000) := ' UPDATE ' || G_B2B_VIEW_NAME
		|| ' SET LOAD_STATUS = ''RELOAD'', ';

BEGIN
	l_column_name := UPPER (p_xml_element_rec.COLUMN_NAME);
	IF l_column_name IS NOT NULL AND l_column_name = 'ORGANIZATION' THEN --ORGANIZATION
	--('PARTY_NAME', 'FISCAL_YEAREND_MONTH',
	--	'DUNS_NUMBER', 'EMPLOYEES_TOTAL', 'LINE_OF_BUSINESS', 'YEAR_ESTABLISHED',
	--	'TAX_REFERENCE', 'CEO_NAME', 'SIC_CODE', 'SIC_CODE_TYPE', 'ANALYSIS_FY',
	--	'CURR_FY_POTENTIAL_REVENUE', 'NEXT_FY_POTENTIAL_REVENUE', 'GSA_INDICATOR_FLAG',
	--	'MISSION_STATEMENT', 'ORGANIZATION_NAME_PHONETIC', 'CATEGORY_CODE',
	--	'JGZZ_FISCAL_CODE', 'PARTY_ID') THEN --organization
		l_source_system_column_name := 'ORG_IMP_XML_ELEMENT_ID';
	ELSIF l_column_name IS NOT NULL AND l_column_name = 'ADDRESS' THEN --ADDRESS
	--	('ADDRESS1', 'ADDRESS2', 'ADDRESS3', 'ADDRESS4',
	--	'CITY', 'COUNTY', 'PROVINCE', 'STATE', 'POSTAL_CODE',
	--	'COUNTRY', 'ADDRESS_LINES_PHONETIC', 'PO_BOX_NUMBER',
	--	'HOUSE_NUMBER', 'STREET_SUFFIX', 'STREET', 'STREET_NUMBER',
	--	'FLOOR', 'SUITE', 'POSTAL_PLUS4_CODE','IDENTIFYING_ADDRESS_FLAG')	THEN
		l_source_system_column_name := 'ADD_IMP_XML_ELEMENT_ID';
	ELSIF l_column_name IS NOT NULL AND l_column_name = 'CONTACT' THEN
	--	('PERSON_FIRST_NAME', 'PERSON_MIDDLE_NAME', 'PERSON_NAME_SUFFIX',
	--	 'PERSON_TITLE', 'PERSON_LAST_NAME', 'DEPARTMENT',
	--	'JOB_TITLE', 'DECISION_MAKER_FLAG')	THEN
		l_source_system_column_name := 'OCONT_IMP_XML_ELEMENT_ID';
	ELSIF l_column_name IS NOT NULL AND l_column_name = 'PHONE_INFO' THEN -- PHONE_INFO
	--	('PHONE_COUNTRY_CODE', 'PHONE_AREA_CODE',
	--	'PHONE_NUMBER', 'PHONE_EXTENSION')	THEN
		l_source_system_column_name := 'CP_IMP_XML_ELEMENT_ID';
	ELSIF l_column_name IS NOT NULL AND l_column_name = 'EMAIL_INFO' THEN --EMAIL_INFO
		l_source_system_column_name := 'EM_IMP_XML_ELEMENT_ID';
	END IF;

	Update_Xml_Source_Lines_Util (
		p_view_name						=> G_B2B_VIEW_NAME,
		p_commit							=> p_commit,
		p_column_name					=> l_source_system_column_name,
		p_prim_key						=> p_xml_element_rec.IMP_XML_ELEMENT_ID,
		p_xml_elements_data			=> p_xml_elements_data,
		p_xml_elements_col_name		=> p_xml_elements_col_name,
		x_return_status            => x_return_status,
		x_msg_count                => x_msg_count,
		x_msg_data                 => x_msg_data
	);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	/****
	AMS_Import_XML_PVT.Get_Parent_Node (
			p_imp_xml_element_id       => p_xml_element_rec.IMP_XML_ELEMENT_ID,
			x_node_rec                 => l_element_rec,
			x_return_status            => x_return_status,
			x_msg_data                 => x_msg_data);
	l_update_element_id := l_element_rec.imp_xml_element_id;
	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	l_update_statement := l_update_statement || l_column_name
		|| ' = :v1 WHERE ' || l_source_system_column_name || ' = :p1';

	EXECUTE IMMEDIATE
		l_update_statement USING p_xml_element_rec.data, l_update_element_id;
	****/

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     --IF (AMS_DEBUG_HIGH_ON) THENAMS_UTILITY_PVT.debug_message('Private API: Update_B2B_Xml_Source_lines expected');END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --IF (AMS_DEBUG_HIGH_ON) THENAMS_UTILITY_PVT.debug_message('Private API: Update_B2B_Xml_Source_lines unexpected');END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --IF (AMS_DEBUG_HIGH_ON) THENAMS_UTILITY_PVT.debug_message('Private API: Update_B2B_Xml_Source_lines OTHERS');END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END;

-- Set the load_status for the current element as "RELOAD", update all the child elements
-- with new values and update source lines correspondingly
PROCEDURE Update_Error_Xml_Element (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_xml_element_rec            IN   xml_element_rec_type,
	 p_xml_element_ids            IN   num_data_set_type_w,
	 p_xml_elements_data          IN   varchar2_2000_set_type,
	 p_xml_elements_col_name      IN   varchar2_2000_set_type,
	 x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    x_object_version_number      OUT NOCOPY  NUMBER
    )
IS

CURSOR c_get_xml_element(l_imp_xml_element_id NUMBER) IS
    SELECT *
    FROM  AMS_IMP_XML_ELEMENTS
    WHERE imp_xml_element_id = l_imp_xml_element_id;
    -- Hint: Developer need to provide Where clause

CURSOR c_get_import_type (p_header_id NUMBER) IS
	SELECT IMPORT_TYPE
	FROM AMS_IMP_LIST_HEADERS_ALL
	WHERE IMPORT_LIST_HEADER_ID = p_header_id;

CURSOR c_get_header_id (p_imp_xml_doc_id NUMBER ) IS
	SELECT IMPORT_LIST_HEADER_ID
	FROM AMS_IMP_DOCUMENTS
	WHERE imp_document_id = p_imp_xml_doc_id;

	l_header_id c_get_header_id%ROWTYPE;

	l_import_type c_get_import_type%rowtype;

	L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Error_Xml_Element';
	L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;

	-- Local Variables
	l_object_version_number     NUMBER;
	l_IMP_XML_ELEMENT_ID    NUMBER;
	--l_ref_xml_element_rec  c_get_Xml_Element%ROWTYPE ;
	--l_tar_xml_element_rec  AMS_Xml_Element_PVT.xml_element_rec_type := P_xml_element_rec;

	l_return_status	VARCHAR2(1);
	l_msg_count			NUMBER;
	l_msg_data        VARCHAR2 (2000);

	l_element_rec AMS_IMP_XML_ELEMENTS%ROWTYPE;

BEGIN

	-- Standard Start of API savepoint
   SAVEPOINT Update_Error_Xml_Element;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Debug Message
	IF (AMS_DEBUG_HIGH_ON) THEN

	AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
	END IF;

	-- Initialize API return status to SUCCESS
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Debug Message
	IF (AMS_DEBUG_HIGH_ON) THEN

	AMS_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');
	END IF;

	/****
   If (l_tar_xml_element_rec.object_version_number is NULL or
       l_tar_xml_element_rec.object_version_number = FND_API.G_MISS_NUM ) Then
		AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
												p_token_name   => 'COLUMN',
												p_token_value  => 'Last_Update_Date') ;
      raise FND_API.G_EXC_ERROR;
   End if;

	IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
		-- Debug message
		IF (AMS_DEBUG_HIGH_ON) THEN

		AMS_UTILITY_PVT.debug_message('Private API: Validate_Xml_Element');
		END IF;

		-- Invoke validation procedures
		Validate_xml_element(
		p_api_version_number => 1.0,
		p_init_msg_list    => FND_API.G_FALSE,
		p_validation_level => p_validation_level,
		p_validation_mode => JTF_PLSQL_API.g_update,
		p_xml_element_rec  =>  p_xml_element_rec,
		x_return_status    => x_return_status,
		x_msg_count        => x_msg_count,
		x_msg_data         => x_msg_data);
   END IF;

	IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- Debug Message
	IF (AMS_DEBUG_HIGH_ON) THEN

	AMS_UTILITY_PVT.debug_message('Private API: Calling update table handler');
	END IF;

	-- Invoke table handler(AMS_IMP_XML_ELEMENTS_PKG.Update_Row)
	AMS_IMP_XML_ELEMENTS_PKG.Update_Row (
		 p_imp_xml_element_id  => p_xml_element_rec.imp_xml_element_id,
		 p_last_updated_by  => FND_GLOBAL.user_id,
		 p_object_version_number  => p_xml_element_rec.object_version_number,
		 -- p_created_by  => p_xml_element_rec.created_by,
		 p_last_update_login  => FND_GLOBAL.conc_login_id,
		 p_last_update_date  => SYSDATE,
		 -- p_creation_date  => p_xml_element_rec.creation_date,
		 p_imp_xml_document_id  => p_xml_element_rec.imp_xml_document_id,
		 p_order_initial  => p_xml_element_rec.order_initial,
		 p_order_final  => p_xml_element_rec.order_final,
		 p_column_name  => p_xml_element_rec.column_name,
		 p_data  => p_xml_element_rec.data,
		 p_num_attr  => p_xml_element_rec.num_attr,
		 p_data_type  => p_xml_element_rec.data_type,
		 p_load_status  => 'RELOAD', --p_xml_element_rec.load_status,
		 p_error_text  => NULL); --p_xml_element_rec.error_text);

	IF (AMS_DEBUG_HIGH_ON) THEN



	AMS_UTILITY_PVT.debug_message('Private API: Returned update table handler');

	END IF;
	****/

	AMS_Import_XML_PVT.Get_Parent_Node (
			p_imp_xml_element_id       => p_xml_element_ids(1),
			x_node_rec                 => l_element_rec,
			x_return_status            => x_return_status,
			x_msg_data                 => x_msg_data);

   --x_object_version_number := p_xml_element_rec.object_version_number + 1;

	--IF l_ref_xml_element_rec.data IS NULL THEN
	--	l_ref_xml_element_rec.data := FND_API.g_miss_char;
	--END IF;

	UPDATE ams_imp_xml_elements
	SET LOAD_STATUS = 'RELOAD'
	WHERE IMP_XML_ELEMENT_ID = l_element_rec.imp_xml_element_id;

	OPEN c_get_header_id (l_element_rec.IMP_XML_DOCUMENT_ID);
	FETCH c_get_header_id INTO l_header_id;
	CLOSE c_get_header_id;

	write_msg(' a test 01::l_element_rec.imp_xml_element_id' || l_element_rec.imp_xml_element_id
		|| ' and the l_header_id.IMPORT_LIST_HEADER_ID::'
		|| l_header_id.IMPORT_LIST_HEADER_ID );
	IF l_header_id.IMPORT_LIST_HEADER_ID IS NOT NULL THEN
		UPDATE ams_imp_list_headers_all
		SET execute_mode = 'R'
		WHERE import_list_header_id = l_header_id.IMPORT_LIST_HEADER_ID;

		UPDATE ams_imp_source_lines
		SET LOAD_STATUS = 'RELOAD'
		WHERE IMPORT_LIST_HEADER_ID = l_header_id.IMPORT_LIST_HEADER_ID;
	END IF;

	write_msg(' a test 02::' );
	FORALL l_count IN p_xml_element_ids.FIRST .. p_xml_element_ids.LAST
		UPDATE ams_imp_xml_elements
		SET DATA = p_xml_elements_data (l_count)
		WHERE IMP_XML_ELEMENT_ID = p_xml_element_ids (l_count);

	OPEN c_get_import_type (l_header_id.IMPORT_LIST_HEADER_ID);
	FETCH c_get_import_type INTO l_import_type;
	CLOSE c_get_import_type;

	write_msg(' a test 03:: l_import_type.IMPORT_TYPE::' ||  l_import_type.IMPORT_TYPE);
	IF l_import_type.IMPORT_TYPE IS NOT NULL AND UPPER (l_import_type.IMPORT_TYPE) = 'B2B' THEN
		Update_B2B_Xml_Source_lines (
			x_return_status              => l_return_status,
			x_msg_count                  => l_msg_count,
			x_msg_data                   => l_msg_data,
			p_xml_element_rec            => l_element_rec,
			p_xml_element_ids            => p_xml_element_ids,
			p_xml_elements_data          => p_xml_elements_data,
			p_xml_elements_col_name      => p_xml_elements_col_name,
			p_commit                     => FND_API.G_FALSE);
		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	ELSIF l_import_type.IMPORT_TYPE IS NOT NULL AND UPPER (l_import_type.IMPORT_TYPE) = 'B2C' THEN
		Update_B2C_Xml_Source_lines (
			x_return_status              => l_return_status,
			x_msg_count                  => l_msg_count,
			x_msg_data                   => l_msg_data,
			p_xml_element_rec            => l_element_rec,
			p_xml_element_ids            => p_xml_element_ids,
			p_xml_elements_data          => p_xml_elements_data ,
			p_xml_elements_col_name      => p_xml_elements_col_name,
			p_commit                     => FND_API.G_FALSE);
		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;
	--END IF; --IF l_ref_xml_element_rec.imp_xml_element_id IS NOT NULL

	-- Standard check for p_commit
	IF FND_API.to_Boolean( p_commit) THEN
		COMMIT WORK;
	END IF;

	-- Debug Message
	IF (AMS_DEBUG_HIGH_ON) THEN

	AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
	END IF;

	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get (	p_count          =>   x_msg_count,
											p_data           =>   x_msg_data);

EXCEPTION
   WHEN AMS_Utility_PVT.resource_locked THEN
		x_return_status := FND_API.g_ret_sts_error;
		AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Update_Error_Xml_Element;
		x_return_status := FND_API.G_RET_STS_ERROR;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: Exception G_EXC_ERROR');
      END IF;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data );

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Update_Error_Xml_Element;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: Exception G_EXC_UNEXPECTED_ERROR');
      END IF;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
		);

	WHEN OTHERS THEN
		ROLLBACK TO Update_Error_Xml_Element;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: Exception OTHERS');
      END IF;
		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
		END IF;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data);
END Update_Error_Xml_Element;

-- Hint: Primary key needs to be returned.
PROCEDURE Create_Xml_Element(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_xml_element_rec            IN   xml_element_rec_type  := g_miss_xml_element_rec,
    x_imp_xml_element_id         OUT NOCOPY  NUMBER
  )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Xml_Element';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_IMP_XML_ELEMENT_ID                  NUMBER;
   l_dummy       NUMBER;

   CURSOR c_id IS
      SELECT AMS_IMP_XML_ELEMENTS_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_IMP_XML_ELEMENTS
      WHERE IMP_XML_ELEMENT_ID = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Xml_Element_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

   IF p_xml_element_rec.IMP_XML_ELEMENT_ID IS NULL OR
      p_xml_element_rec.IMP_XML_ELEMENT_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_IMP_XML_ELEMENT_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_IMP_XML_ELEMENT_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
      l_imp_xml_element_id := p_xml_element_rec.imp_xml_element_id;
   END IF;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.User_Id IS NULL
      THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Xml_Element');
          END IF;

          -- Invoke validation procedures
          Validate_xml_element(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            p_xml_element_rec  =>  p_xml_element_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

      -- Invoke table handler(AMS_IMP_XML_ELEMENTS_PKG.Insert_Row)
      AMS_IMP_XML_ELEMENTS_PKG.Insert_Row(
          px_imp_xml_element_id  => l_imp_xml_element_id,
          p_last_updated_by  => FND_GLOBAL.user_id,
          px_object_version_number  => l_object_version_number,
          p_created_by  => FND_GLOBAL.user_id,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_last_update_date  => SYSDATE,
          p_creation_date  => SYSDATE,
          p_imp_xml_document_id  => p_xml_element_rec.imp_xml_document_id,
          p_order_initial  => p_xml_element_rec.order_initial,
          p_order_final  => p_xml_element_rec.order_final,
          p_column_name  => p_xml_element_rec.column_name,
          p_data  => p_xml_element_rec.data,
          p_num_attr  => p_xml_element_rec.num_attr,
          p_data_type  => p_xml_element_rec.data_type,
          p_load_status  => p_xml_element_rec.load_status,
          p_error_text  => p_xml_element_rec.error_text);

          x_imp_xml_element_id := l_imp_xml_element_id;
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
--
-- End of API body
--

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Xml_Element_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Xml_Element_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Xml_Element_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Create_Xml_Element;


PROCEDURE Update_Xml_Element(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_xml_element_rec               IN    xml_element_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS

CURSOR c_get_xml_element(l_imp_xml_element_id NUMBER) IS
    SELECT *
    FROM  AMS_IMP_XML_ELEMENTS
    WHERE imp_xml_element_id = l_imp_xml_element_id;
    -- Hint: Developer need to provide Where clause

CURSOR c_get_import_type (p_header_id NUMBER) IS
	SELECT IMPORT_TYPE
	FROM AMS_IMP_LIST_HEADERS_ALL
	WHERE IMPORT_LIST_HEADER_ID = p_header_id;

CURSOR c_get_header_id (p_imp_xml_doc_id NUMBER ) IS
	SELECT IMPORT_LIST_HEADER_ID
 FROM AMS_IMP_DOCUMENTS
 WHERE imp_document_id = p_imp_xml_doc_id;

 l_header_id c_get_header_id%ROWTYPE;

l_import_type c_get_import_type%rowtype;


L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Xml_Element';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_IMP_XML_ELEMENT_ID    NUMBER;
l_ref_xml_element_rec  c_get_Xml_Element%ROWTYPE ;
l_tar_xml_element_rec  AMS_Xml_Element_PVT.xml_element_rec_type := P_xml_element_rec;

l_return_status	VARCHAR2(1);
l_msg_count			NUMBER;
l_msg_data        VARCHAR2 (2000);

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Xml_Element_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');
      END IF;

/*
      OPEN c_get_Xml_Element( l_tar_xml_element_rec.imp_xml_element_id);

      FETCH c_get_Xml_Element INTO l_ref_xml_element_rec  ;

       If ( c_get_Xml_Element%NOTFOUND) THEN
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Xml_Element') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_Xml_Element;
*/


      If (l_tar_xml_element_rec.object_version_number is NULL or
          l_tar_xml_element_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_xml_element_rec.object_version_number <> l_ref_xml_element_rec.object_version_number) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Xml_Element') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Xml_Element');
          END IF;

          -- Invoke validation procedures
          Validate_xml_element(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_xml_element_rec  =>  p_xml_element_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: Calling update table handler');
      END IF;

      -- Invoke table handler(AMS_IMP_XML_ELEMENTS_PKG.Update_Row)
      AMS_IMP_XML_ELEMENTS_PKG.Update_Row (
          p_imp_xml_element_id  => p_xml_element_rec.imp_xml_element_id,
          p_last_updated_by  => FND_GLOBAL.user_id,
          p_object_version_number  => p_xml_element_rec.object_version_number,
          -- p_created_by  => p_xml_element_rec.created_by,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_last_update_date  => SYSDATE,
          -- p_creation_date  => p_xml_element_rec.creation_date,
          p_imp_xml_document_id  => p_xml_element_rec.imp_xml_document_id,
          p_order_initial  => p_xml_element_rec.order_initial,
          p_order_final  => p_xml_element_rec.order_final,
          p_column_name  => p_xml_element_rec.column_name,
          p_data  => p_xml_element_rec.data,
          p_num_attr  => p_xml_element_rec.num_attr,
          p_data_type  => p_xml_element_rec.data_type,
          p_load_status  => 'RELOAD', --p_xml_element_rec.load_status,
          p_error_text  => NULL); --p_xml_element_rec.error_text);

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('Private API: Returned update table handler');

      END IF;

      x_object_version_number := p_xml_element_rec.object_version_number + 1;

		OPEN c_get_Xml_Element(p_xml_element_rec.imp_xml_element_id);
      FETCH c_get_Xml_Element INTO l_ref_xml_element_rec;
      CLOSE c_get_Xml_Element;

		IF l_ref_xml_element_rec.data IS NULL THEN
			l_ref_xml_element_rec.data := FND_API.g_miss_char;
		END IF;

		--write_msg ('test1::id::' || l_ref_xml_element_rec.imp_xml_element_id
		--	|| ' p data::' || p_xml_element_rec.data || ' ref data::' || l_ref_xml_element_rec.data);
		OPEN c_get_header_id (l_ref_xml_element_rec.imp_xml_document_id);
		FETCH c_get_header_id INTO l_header_id;
		CLOSE c_get_header_id;

		IF l_header_id.IMPORT_LIST_HEADER_ID IS NOT NULL THEN
			UPDATE ams_imp_list_headers_all
			SET execute_mode = 'R'
			WHERE import_list_header_id = l_header_id.IMPORT_LIST_HEADER_ID;
		END IF;

		IF l_ref_xml_element_rec.imp_xml_element_id IS NOT NULL AND
			p_xml_element_rec.data IS NOT NULL THEN
			--l_ref_xml_element_rec.data <> p_xml_element_rec.data THEN
			--write_msg ('test2');
			OPEN c_get_import_type (l_header_id.IMPORT_LIST_HEADER_ID);
			FETCH c_get_import_type INTO l_import_type;
			CLOSE c_get_import_type;
			--write_msg ('test3::' || l_import_type.IMPORT_TYPE);
			IF l_import_type.IMPORT_TYPE IS NOT NULL AND
				UPPER (l_import_type.IMPORT_TYPE) = 'B2B' THEN
				--Update_B2B_Xml_Source_lines (
				--	x_return_status              => l_return_status,
				--	x_msg_count                  => l_msg_count,
				--	x_msg_data                   => l_msg_data,
				--	p_xml_element_rec            => l_ref_xml_element_rec);
				IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
					RAISE FND_API.G_EXC_ERROR;
				END IF;
			ELSIF l_import_type.IMPORT_TYPE IS NOT NULL AND
				UPPER (l_import_type.IMPORT_TYPE) = 'B2C' THEN
				--Update_B2C_Xml_Source_lines (
				--	x_return_status              => l_return_status,
				--	x_msg_count                  => l_msg_count,
				--	x_msg_data                   => l_msg_data,
				--	p_xml_element_rec            => l_ref_xml_element_rec);
				IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
					RAISE FND_API.G_EXC_ERROR;
				END IF;
			END IF;
		END IF;

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Xml_Element_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: Exception G_EXC_ERROR');
      END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Xml_Element_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: Exception G_EXC_UNEXPECTED_ERROR');
      END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Xml_Element_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: Exception OTHERS');
       END IF;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Update_Xml_Element;


PROCEDURE Delete_Xml_Element(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_imp_xml_element_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Xml_Element';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Xml_Element_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
      END IF;

      -- Invoke table handler(AMS_IMP_XML_ELEMENTS_PKG.Delete_Row)
      AMS_IMP_XML_ELEMENTS_PKG.Delete_Row(
          p_IMP_XML_ELEMENT_ID  => p_IMP_XML_ELEMENT_ID);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Xml_Element_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Xml_Element_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Xml_Element_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Delete_Xml_Element;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Xml_Element(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_imp_xml_element_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Xml_Element';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_IMP_XML_ELEMENT_ID                  NUMBER;

CURSOR c_Xml_Element IS
   SELECT IMP_XML_ELEMENT_ID
   FROM AMS_IMP_XML_ELEMENTS
   WHERE IMP_XML_ELEMENT_ID = p_IMP_XML_ELEMENT_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


------------------------ lock -------------------------

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_Utility_PVT.debug_message(l_full_name||': start');

  END IF;
  OPEN c_Xml_Element;

  FETCH c_Xml_Element INTO l_IMP_XML_ELEMENT_ID;

  IF (c_Xml_Element%NOTFOUND) THEN
    CLOSE c_Xml_Element;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Xml_Element;

 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name ||': end');
  END IF;
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Xml_Element_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Xml_Element_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Xml_Element_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Lock_Xml_Element;


PROCEDURE check_xml_element_uk_items(
    p_xml_element_rec               IN   xml_element_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1) := FND_API.g_true;

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_IMP_XML_ELEMENTS',
         'IMP_XML_ELEMENT_ID = ''' || p_xml_element_rec.IMP_XML_ELEMENT_ID ||''''
         );
--      ELSE
--         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
--         'AMS_IMP_XML_ELEMENTS',
--         'IMP_XML_ELEMENT_ID = ''' || p_xml_element_rec.IMP_XML_ELEMENT_ID ||
--         ''' AND IMP_XML_ELEMENT_ID <> ' || p_xml_element_rec.IMP_XML_ELEMENT_ID
--         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_IMP_XML_ELEMENT_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END check_xml_element_uk_items;

PROCEDURE check_xml_element_req_items(
    p_xml_element_rec               IN  xml_element_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status           OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_xml_element_rec.imp_xml_element_id = FND_API.g_miss_num OR p_xml_element_rec.imp_xml_element_id IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','IMP_XML_ELEMENT_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_xml_element_rec.last_updated_by = FND_API.g_miss_num OR p_xml_element_rec.last_updated_by IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','LAST_UPDATED_BY');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_xml_element_rec.created_by = FND_API.g_miss_num OR p_xml_element_rec.created_by IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','CREATED_BY');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_xml_element_rec.last_update_login = FND_API.g_miss_num OR p_xml_element_rec.last_update_login IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','LAST_UPDATE_LOGIN');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_xml_element_rec.last_update_date = FND_API.g_miss_date OR p_xml_element_rec.last_update_date IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','LAST_UPDATE_DATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_xml_element_rec.creation_date = FND_API.g_miss_date OR p_xml_element_rec.creation_date IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','CREATION_DATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_xml_element_rec.imp_xml_document_id = FND_API.g_miss_num OR p_xml_element_rec.imp_xml_document_id IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','IMP_XML_DOCUMENT_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE


      IF p_xml_element_rec.imp_xml_element_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_xml_element_NO_imp_xml_element_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_xml_element_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_xml_element_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_xml_element_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_xml_element_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_xml_element_rec.last_update_login IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_xml_element_NO_last_update_login');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_xml_element_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_xml_element_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_xml_element_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_xml_element_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_xml_element_rec.imp_xml_document_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_xml_element_NO_imp_xml_document_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_xml_element_req_items;

PROCEDURE check_xml_element_FK_items(
    p_xml_element_rec IN xml_element_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_xml_element_FK_items;

PROCEDURE check_xml_element_Lookup_items(
    p_xml_element_rec IN xml_element_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_xml_element_Lookup_items;

PROCEDURE Check_xml_element_Items (
    P_xml_element_rec     IN    xml_element_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_xml_element_uk_items(
      p_xml_element_rec => p_xml_element_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_xml_element_req_items(
      p_xml_element_rec => p_xml_element_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_xml_element_FK_items(
      p_xml_element_rec => p_xml_element_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_xml_element_Lookup_items(
      p_xml_element_rec => p_xml_element_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_xml_element_Items;



PROCEDURE Complete_xml_element_Rec (
   p_xml_element_rec IN xml_element_rec_type,
   x_complete_rec OUT NOCOPY xml_element_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_imp_xml_elements
      WHERE imp_xml_element_id = p_xml_element_rec.imp_xml_element_id;
   l_xml_element_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_xml_element_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_xml_element_rec;
   CLOSE c_complete;

   -- imp_xml_element_id
   IF p_xml_element_rec.imp_xml_element_id = FND_API.g_miss_num THEN
      x_complete_rec.imp_xml_element_id := l_xml_element_rec.imp_xml_element_id;
   END IF;

   -- last_updated_by
   IF p_xml_element_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_xml_element_rec.last_updated_by;
   END IF;

   -- object_version_number
   IF p_xml_element_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_xml_element_rec.object_version_number;
   END IF;

   -- created_by
   IF p_xml_element_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_xml_element_rec.created_by;
   END IF;

   -- last_update_login
   IF p_xml_element_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_xml_element_rec.last_update_login;
   END IF;

   -- last_update_date
   IF p_xml_element_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_xml_element_rec.last_update_date;
   END IF;

   -- creation_date
   IF p_xml_element_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_xml_element_rec.creation_date;
   END IF;

   -- imp_xml_document_id
   IF p_xml_element_rec.imp_xml_document_id = FND_API.g_miss_num THEN
      x_complete_rec.imp_xml_document_id := l_xml_element_rec.imp_xml_document_id;
   END IF;

   -- order_initial
   IF p_xml_element_rec.order_initial = FND_API.g_miss_num THEN
      x_complete_rec.order_initial := l_xml_element_rec.order_initial;
   END IF;

   -- order_final
   IF p_xml_element_rec.order_final = FND_API.g_miss_num THEN
      x_complete_rec.order_final := l_xml_element_rec.order_final;
   END IF;

   -- column_name
   IF p_xml_element_rec.column_name = FND_API.g_miss_char THEN
      x_complete_rec.column_name := l_xml_element_rec.column_name;
   END IF;

   -- data
   IF p_xml_element_rec.data = FND_API.g_miss_char THEN
      x_complete_rec.data := l_xml_element_rec.data;
   END IF;

   -- num_attr
   IF p_xml_element_rec.num_attr = FND_API.g_miss_num THEN
      x_complete_rec.num_attr := l_xml_element_rec.num_attr;
   END IF;

   -- data_type
   IF p_xml_element_rec.data_type = FND_API.g_miss_char THEN
      x_complete_rec.data_type := l_xml_element_rec.data_type;
   END IF;

   -- load_status
   IF p_xml_element_rec.load_status = FND_API.g_miss_char THEN
      x_complete_rec.load_status := l_xml_element_rec.load_status;
   END IF;

   -- error_text
   IF p_xml_element_rec.error_text = FND_API.g_miss_char THEN
      x_complete_rec.error_text := l_xml_element_rec.error_text;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_xml_element_Rec;

PROCEDURE Validate_xml_element(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_xml_element_rec               IN   xml_element_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Xml_Element';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_xml_element_rec  AMS_Xml_Element_PVT.xml_element_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Xml_Element_;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;
      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              Check_xml_element_Items(
                 p_xml_element_rec        => p_xml_element_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_xml_element_Rec(
         p_xml_element_rec        => p_xml_element_rec,
         x_complete_rec        => l_xml_element_rec
      );

		/****
		IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_xml_element_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_xml_element_rec           =>    l_xml_element_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;
		****/

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Xml_Element_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Xml_Element_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Xml_Element_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Validate_Xml_Element;


PROCEDURE Validate_xml_element_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_xml_element_rec               IN    xml_element_rec_type
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Hint: Validate data
      -- If data not valid
      -- THEN
      -- x_return_status := FND_API.G_RET_STS_ERROR;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_xml_element_Rec;

END AMS_Xml_Element_PVT;

/
