--------------------------------------------------------
--  DDL for Package Body AMS_IMPORT_XML_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IMPORT_XML_PVT" AS
/* $Header: amsvmixb.pls 120.1 2006/01/18 03:14:10 rmbhanda noship $ */
--------------------------------------------------------------------------------
--
-- NAME
--    AMS_Import_XML_PVT
--
-- HISTORY
-- 02-Apr-2002    huili           Created
-- 01-May-2002    huili           Added profile checking and possible concurrent program.
-- 18-May-2002    huili           Removed the "Filter_XML" call inside the "Store_XML_Util".
-- 03-June-2002   huili           Added code to deal with unmapped columns.
-- 04-June-2002   huili           Tuned APIs.
-- 09-Aug-2002    huili           Added overloaded "Get_Children_Nodes" which returns
--                                table of all children records.
------------------------------------------------------------------------------
--
-- Global variables and constants.
G_PKG_NAME        CONSTANT VARCHAR2(30) := 'AMS_Import_XML_PVT'; -- Name of the current package.
G_ORDER_INITIAL_START_NUMBER   CONSTANT NUMBER := 1;
G_COUNT NUMBER := 1;
G_ARC_IMPORT_HEADER  CONSTANT VARCHAR2(30) := 'IMPH';
G_DATA_TYPE_DATA CONSTANT VARCHAR2(1) := 'D';
G_DATA_TYPE_TAG CONSTANT VARCHAR2(1) := 'T';

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

FUNCTION Get_Children_Cursor (
   p_imp_doc_id    IN NUMBER,

	p_order_initial IN NUMBER) RETURN rc_type
IS
   l_children rc_type;
BEGIN
   OPEN l_children FOR
      SELECT e3.*
      FROM ams_imp_xml_elements e3
      START WITH e3.imp_xml_document_id = p_imp_doc_id
      AND e3.order_initial = p_order_initial + 1
      CONNECT BY e3.imp_xml_document_id = p_imp_doc_id
      AND PRIOR order_final + 1 = order_initial;
   RETURN l_children;
END Get_Children_Cursor;

PROCEDURE Get_Element_Info (
   p_element_id   IN NUMBER,
	x_element_info OUT NOCOPY AMS_IMP_XML_ELEMENTS%ROWTYPE
)
IS
	CURSOR c_get_element (p_imp_xml_element_id NUMBER) IS
	SELECT *
	FROM ams_imp_xml_elements
	WHERE IMP_XML_ELEMENT_ID = p_imp_xml_element_id;
BEGIN
	OPEN c_get_element (p_element_id);
	FETCH c_get_element INTO x_element_info;
	CLOSE c_get_element;
END Get_Element_Info;

PROCEDURE write_debug (
	p_msg VARCHAR2
)
IS
BEGIN
	--insert into ams_xml_test1 values (G_COUNT || p_msg);
	--G_COUNT := G_COUNT + 1;
	--commit;
	NULL;
END write_debug;

PROCEDURE Filter_XML_Helper (
	p_node            IN OUT NOCOPY  xmldom.DOMNode,
	p_mapping         IN      xml_source_column_set_type,
	p_source_col_name IN      VARCHAR2
);

FUNCTION Is_In_Mapping (
	p_item          IN VARCHAR2,
	p_mapping       IN xml_source_column_set_type
) RETURN BOOLEAN;

PROCEDURE Store_XML_Elements (
	p_xml_doc_id               IN           NUMBER,
	p_imp_list_header_id       IN           NUMBER,
	p_xml_content              IN           CLOB,
	p_commit                   IN           VARCHAR2 := FND_API.G_FALSE,
	x_return_status            OUT NOCOPY          VARCHAR2,
	x_msg_data                 OUT NOCOPY          VARCHAR2
);

--PROCEDURE Store_XML_Elements_Helper (
--	p_node          IN xmldom.DOMNode,
--	p_source_fields IN xml_source_column_set_type,
--	p_target_fields IN xml_target_column_set_type,
--	p_col_name      IN VARCHAR2,
--	p_xml_doc_id    IN NUMBER,
--	p_commit        IN VARCHAR2 := FND_API.G_TRUE,
--	x_order_num     IN OUT NUMBER
--);

PROCEDURE Store_XML_Elements_Helper (
	p_node          IN xmldom.DOMNode,
	p_source_fields IN xml_source_column_set_type,
	p_target_fields IN xml_target_column_set_type,
	p_col_name      IN VARCHAR2,
	p_xml_doc_id    IN NUMBER,
	p_commit        IN VARCHAR2 := FND_API.G_FALSE,
	x_order_num     IN OUT NOCOPY NUMBER,
	p_result_node   IN OUT NOCOPY xmldom.DOMNode,
	p_column_name   IN OUT NOCOPY VARCHAR2,
	p_value         IN OUT NOCOPY VARCHAR2,
	p_result_doc    IN OUT NOCOPY xmldom.DOMDocument
);

FUNCTION Store_XML_Attributes (
	p_node            IN xmldom.DOMNode,
	p_order_init      IN NUMBER,
	p_xml_doc_id      IN NUMBER,
	p_commit          IN VARCHAR2 := FND_API.G_FALSE
) RETURN NUMBER;

FUNCTION Get_Col_name (
	p_source_fields IN xml_source_column_set_type,
	p_target_fields IN xml_target_column_set_type,
	p_col_name      IN VARCHAR2
) RETURN VARCHAR2;
--- End forward modules


-- Start of comments
-- API Name       Is_Leaf_Node
-- Type           Public
-- Pre-reqs       None.
-- Function       Determine whether the given element is leaf or not
-- Parameters
--    IN
--                p_imp_xml_element_id  NUMBER                       Required
--    OUT
--                x_return_status          VARCHAR2
--                x_msg_data               VARCHAR2
--
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
FUNCTION Is_Leaf_Node (
   p_imp_xml_element_id    IN    NUMBER,
   x_return_status         OUT NOCOPY   VARCHAR2,
   x_msg_data              OUT NOCOPY   VARCHAR2
) RETURN BOOLEAN

IS
	L_API_NAME	CONSTANT VARCHAR2(30) := 'Is_Leaf_Node';
	L_FULL_NAME CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;

	CURSOR c_element_info (p_xml_element_id NUMBER)
	IS SELECT ORDER_INITIAL, ORDER_FINAL
	FROM AMS_IMP_XML_ELEMENTS
	WHERE IMP_XML_ELEMENT_ID = p_xml_element_id;

	l_element_info c_element_info%ROWTYPE;
BEGIN

	--
	-- Initialize API return status to success.
	--
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF p_imp_xml_element_id IS NULL THEN
		x_msg_data := 'Expected error in ' || L_FULL_NAME
			|| ' list import header is null';
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	OPEN c_element_info (p_imp_xml_element_id);
	FETCH c_element_info INTO l_element_info;
	CLOSE c_element_info;

	IF l_element_info.ORDER_INITIAL IS NOT NULL AND l_element_info.ORDER_FINAL IS NOT NULL
		AND l_element_info.ORDER_FINAL = l_element_info.ORDER_INITIAL + 1 THEN
		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END IF;

	EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
		WHEN OTHERS THEN
			x_msg_data := 'Unexpected error in '
								|| L_FULL_NAME || ': '|| SQLERRM;
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Is_Leaf_Node;


-- Start of comments
-- API Name       Get_File_Type
-- Type           Public
-- Pre-reqs       None.
-- Function       Retrieve the information for the root node in the
--                "AMS_IMP_XML_ELEMENTS" table, given the
--                "import_list_header_id".
-- Parameters
--    IN
--                p_import_list_header_id  NUMBER     Required
--    OUT         x_node_rec               AMS_IMP_XML_ELEMENTS%ROWTYPE
--                x_return_status          VARCHAR2
--
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
PROCEDURE Get_File_Type (
	p_import_list_header_id    IN    NUMBER,
	x_file_type                OUT NOCOPY   AMS_IMP_DOCUMENTS.FILE_TYPE%TYPE,
	x_return_status            OUT NOCOPY   VARCHAR2,
	x_msg_data                 OUT NOCOPY   VARCHAR2
)
IS
	L_API_NAME         CONSTANT VARCHAR2(30) := 'Get_File_Type';
	L_FULL_NAME        CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;

	CURSOR c_file_type (p_import_list_header_id NUMBER) IS
	SELECT FILE_TYPE
	FROM AMS_IMP_DOCUMENTS
	WHERE IMPORT_LIST_HEADER_ID = p_import_list_header_id;
BEGIN

	--
	-- Initialize API return status to success.
	--
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF p_import_list_header_id IS NULL THEN
		x_msg_data := 'Expected error in ' || L_FULL_NAME
							|| ' list import header is null';
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	OPEN c_file_type (p_import_list_header_id);
	FETCH c_file_type INTO x_file_type;
	CLOSE c_file_type;

	EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
		WHEN OTHERS THEN
			x_msg_data := 'Unexpected error in '
							  || L_FULL_NAME || ': '|| SQLERRM;
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Get_File_Type;


-- Start of comments
-- API Name       Get_Root_Node
-- Type           Public
-- Pre-reqs       None.
-- Function       Retrieve the information for the root node in the
--                "AMS_IMP_XML_ELEMENTS" table, given the
--                "import_list_header_id".
-- Parameters
--    IN
--                p_import_list_header_id  NUMBER                       Required
--    OUT         x_node_rec               AMS_IMP_XML_ELEMENTS%ROWTYPE
--                x_return_status          VARCHAR2
--
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
PROCEDURE Get_Root_Node (
	p_import_list_header_id    IN    NUMBER,
	x_node_rec                 OUT NOCOPY   AMS_IMP_XML_ELEMENTS%ROWTYPE,
	x_return_status            OUT NOCOPY   VARCHAR2,
	x_msg_data                 OUT NOCOPY   VARCHAR2
)
IS
	L_API_NAME     CONSTANT VARCHAR2(30) := 'Get_Root_Node';
	L_FULL_NAME    CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;

	CURSOR c_root_node_rec (p_import_list_header_id NUMBER) IS
		SELECT *
		FROM AMS_IMP_XML_ELEMENTS
		WHERE ORDER_INITIAL = G_ORDER_INITIAL_START_NUMBER
		AND EXISTS (SELECT 1
		FROM AMS_IMP_DOCUMENTS
		WHERE AMS_IMP_DOCUMENTS.IMPORT_LIST_HEADER_ID = p_import_list_header_id
		AND AMS_IMP_DOCUMENTS.IMP_DOCUMENT_ID = AMS_IMP_XML_ELEMENTS.IMP_XML_DOCUMENT_ID);
BEGIN

	--
	-- Initialize API return status to success.
	--
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF p_import_list_header_id IS NULL THEN
		x_msg_data := 'Expected error in ' || L_FULL_NAME
							|| ' list import header is null';
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	OPEN c_root_node_rec (p_import_list_header_id);
	FETCH c_root_node_rec INTO x_node_rec;
	CLOSE c_root_node_rec;

	EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
		WHEN OTHERS THEN
			x_msg_data := 'Unexpected error in '
							  || L_FULL_NAME || ': '|| SQLERRM;
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Get_Root_Node;

-- Start of comments
-- API Name       Get_First_Child_Node
-- Type           Public
-- Pre-reqs       None.
-- Function       Retrieve the information for the first child node in the
--                "AMS_IMP_XML_ELEMENTS" table, given the node id
-- Parameters
--    IN
--                p_imp_xml_element_id     NUMBER                       Required
--    OUT         x_node_rec               AMS_IMP_XML_ELEMENTS%ROWTYPE
--                x_return_status          VARCHAR2
--
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
PROCEDURE Get_First_Child_Node (
	p_imp_xml_element_id       IN    NUMBER,
	x_node_rec                 OUT NOCOPY   AMS_IMP_XML_ELEMENTS%ROWTYPE,
	x_return_status            OUT NOCOPY   VARCHAR2,
	x_msg_data                 OUT NOCOPY   VARCHAR2
)
IS
	L_API_NAME                 CONSTANT VARCHAR2(30) := 'Get_First_Child_Node';
	L_FULL_NAME                CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;

	CURSOR c_xml_element (p_xml_element_id NUMBER) IS
		SELECT IMP_XML_ELEMENT_ID,
		IMP_XML_DOCUMENT_ID,
		ORDER_INITIAL
		FROM AMS_IMP_XML_ELEMENTS
		WHERE IMP_XML_ELEMENT_ID = p_xml_element_id;

	CURSOR c_xml_first_child_element (p_xml_doc_id NUMBER, p_order_initial NUMBER) IS
		SELECT *
		FROM AMS_IMP_XML_ELEMENTS
		WHERE IMP_XML_DOCUMENT_ID = p_xml_doc_id
		AND ORDER_INITIAL = p_order_initial + 1;

	l_xml_element_rec c_xml_element%ROWTYPE;
BEGIN
	--
	-- Initialize API return status to success.
	--
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF p_imp_xml_element_id IS NULL THEN
		x_msg_data := 'Expected error in ' || L_FULL_NAME
		|| ' xml element id is null';
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	OPEN c_xml_element (p_imp_xml_element_id);
	FETCH c_xml_element INTO l_xml_element_rec;


	IF c_xml_element%FOUND THEN
		OPEN c_xml_first_child_element (l_xml_element_rec.IMP_XML_DOCUMENT_ID,
		l_xml_element_rec.ORDER_INITIAL);
		FETCH c_xml_first_child_element INTO x_node_rec;
		CLOSE c_xml_first_child_element;
	END IF;
	CLOSE c_xml_element;

	EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
		WHEN OTHERS THEN
			x_msg_data := 'Unexpected error in '
			|| L_FULL_NAME || ': '|| SQLERRM;
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Get_First_Child_Node;

-- Start of comments
-- API Name       Get_Next_Sibling_Node
-- Type           Public
-- Pre-reqs       None.
-- Function       Retrieve the information for the first child node in the
--                "AMS_IMP_XML_ELEMENTS" table, given the node id
-- Parameters
--    IN
--                p_imp_xml_element_id     NUMBER                       Required
--    OUT         x_node_rec               AMS_IMP_XML_ELEMENTS%ROWTYPE
--                x_return_status          VARCHAR2
--
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
PROCEDURE Get_Next_Sibling_Node (
	p_imp_xml_element_id       IN    NUMBER,
	x_node_rec                 OUT NOCOPY   AMS_IMP_XML_ELEMENTS%ROWTYPE,
	x_return_status            OUT NOCOPY   VARCHAR2,
	x_msg_data                 OUT NOCOPY   VARCHAR2
)
IS
	L_API_NAME                 CONSTANT VARCHAR2(30) := 'Get_Next_Sibling_Node';
	L_FULL_NAME                CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;

	CURSOR c_xml_element (p_xml_element_id NUMBER) IS
		SELECT IMP_XML_ELEMENT_ID,
		IMP_XML_DOCUMENT_ID,
		ORDER_FINAL
		FROM AMS_IMP_XML_ELEMENTS
		WHERE IMP_XML_ELEMENT_ID = p_xml_element_id;

	CURSOR c_xml_next_sibling_element (p_xml_doc_id NUMBER,
	p_order_final NUMBER) IS
		SELECT *
		FROM AMS_IMP_XML_ELEMENTS
		WHERE IMP_XML_DOCUMENT_ID = p_xml_doc_id
		AND ORDER_INITIAL = p_order_final + 1;

	l_xml_element_rec c_xml_element%ROWTYPE;
BEGIN
	--
	-- Initialize API return status to success.
	--
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF p_imp_xml_element_id IS NULL THEN
		x_msg_data := 'Expected error in ' || L_FULL_NAME
		|| ' xml element id is null';
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	OPEN c_xml_element (p_imp_xml_element_id);
	FETCH c_xml_element INTO l_xml_element_rec;

	IF c_xml_element%FOUND THEN
		OPEN c_xml_next_sibling_element (l_xml_element_rec.IMP_XML_DOCUMENT_ID,
		l_xml_element_rec.ORDER_FINAL);
		FETCH c_xml_next_sibling_element INTO x_node_rec;
		CLOSE c_xml_next_sibling_element;
	END IF;
	CLOSE c_xml_element;

	EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
	WHEN OTHERS THEN
		x_msg_data := 'Unexpected error in '
		|| L_FULL_NAME || ': '|| SQLERRM;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Get_Next_Sibling_Node;

-- Start of comments
-- API Name       Get_Parent_Node
-- Type           Public
-- Pre-reqs       None.
-- Function       Retrieve the information for the parent node in the
--                "AMS_IMP_XML_ELEMENTS" table, given the node id
-- Parameters
--    IN
--                p_imp_xml_element_id     NUMBER                       Required
--    OUT         x_node_rec               AMS_IMP_XML_ELEMENTS%ROWTYPE
--                x_return_status          VARCHAR2
--
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
PROCEDURE Get_Parent_Node (
	p_imp_xml_element_id       IN    NUMBER,
	x_node_rec                 OUT NOCOPY   AMS_IMP_XML_ELEMENTS%ROWTYPE,
	x_return_status            OUT NOCOPY   VARCHAR2,
	x_msg_data                 OUT NOCOPY   VARCHAR2
)
IS
	L_API_NAME                 CONSTANT VARCHAR2(30) := 'Get_Parent_Node';
	L_FULL_NAME                CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;

	CURSOR c_xml_element (p_xml_element_id NUMBER) IS
		SELECT IMP_XML_ELEMENT_ID,
		IMP_XML_DOCUMENT_ID,
		ORDER_INITIAL,
		ORDER_FINAL
		FROM AMS_IMP_XML_ELEMENTS
		WHERE IMP_XML_ELEMENT_ID = p_xml_element_id;

	CURSOR c_xml_parent_element (p_xml_doc_id NUMBER,
					p_order_initial NUMBER,
					p_order_final NUMBER) IS
		SELECT *
		FROM AMS_IMP_XML_ELEMENTS
		WHERE IMP_XML_DOCUMENT_ID = p_xml_doc_id
		--AND ORDER_INITIAL < p_order_initial
		--AND ORDER_FINAL > p_order_final
		AND ORDER_INITIAL =
			(SELECT MAX(ORDER_INITIAL)
			 FROM AMS_IMP_XML_ELEMENTS e2
			 WHERE e2.IMP_XML_DOCUMENT_ID = p_xml_doc_id
			 AND e2.ORDER_INITIAL < p_order_initial
			 AND e2.ORDER_FINAL > p_order_final);
	l_xml_element_rec c_xml_element%ROWTYPE;

BEGIN
	--
	-- Initialize API return status to success.
	--
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF p_imp_xml_element_id IS NULL THEN
		x_msg_data := 'Expected error in ' || L_FULL_NAME
		|| ' xml element id is null';
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	OPEN c_xml_element (p_imp_xml_element_id);
	FETCH c_xml_element INTO l_xml_element_rec;

	IF c_xml_element%FOUND THEN
		OPEN c_xml_parent_element (l_xml_element_rec.IMP_XML_DOCUMENT_ID,
			l_xml_element_rec.ORDER_INITIAL,
			l_xml_element_rec.ORDER_FINAL);
		FETCH c_xml_parent_element INTO x_node_rec;
		CLOSE c_xml_parent_element;
	ELSE
		x_node_rec.IMP_XML_ELEMENT_ID := NULL;
	END IF;
	CLOSE c_xml_element;

	EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
		WHEN OTHERS THEN
			x_msg_data := 'Unexpected error in '
			|| L_FULL_NAME || ': '|| SQLERRM;
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Get_Parent_Node;

-- Start of comments
-- API Name       Get_Error_Info
-- Type           Public
-- Pre-reqs       None.
-- Function       Retrieve the tag name and text data for an error node.
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
PROCEDURE Get_Error_Info (
	p_imp_xml_element_id       IN    NUMBER,
	x_column_name              OUT NOCOPY   VARCHAR2,
	x_column_value             OUT NOCOPY   VARCHAR2,
	x_return_status            OUT NOCOPY   VARCHAR2,
	x_msg_data                 OUT NOCOPY   VARCHAR2
)
IS
	L_API_NAME                 CONSTANT VARCHAR2(30) := 'Get_Error_Info';
	L_FULL_NAME                CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;
	l_parent_node_rec          AMS_IMP_XML_ELEMENTS%ROWTYPE;

	CURSOR c_error_xml_element (p_xml_element_id NUMBER) IS
		SELECT IMP_XML_ELEMENT_ID,
		COLUMN_NAME,
		DATA
		FROM AMS_IMP_XML_ELEMENTS
		WHERE IMP_XML_ELEMENT_ID = p_xml_element_id;
	l_error_info c_error_xml_element%ROWTYPE;
	l_column_name AMS_IMP_XML_ELEMENTS.COLUMN_NAME%TYPE;
	l_data   AMS_IMP_XML_ELEMENTS.DATA%TYPE;
	l_element_id NUMBER;
BEGIN
	--
	-- Initialize API return status to success.
	--
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF p_imp_xml_element_id IS NULL THEN
		x_msg_data := 'Expected error in ' || L_FULL_NAME
		|| ' xml element id is null';
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	OPEN c_error_xml_element (p_imp_xml_element_id);
	FETCH c_error_xml_element INTO l_error_info;

	IF c_error_xml_element%FOUND THEN
		l_element_id := l_error_info.IMP_XML_ELEMENT_ID;
		l_column_name := '(' || l_error_info.COLUMN_NAME || ')';
		l_data := l_error_info.DATA;
		WHILE l_element_id IS NOT NULL
		LOOP
			l_parent_node_rec.IMP_XML_ELEMENT_ID := NULL;
			Get_Parent_Node (
			p_imp_xml_element_id               => l_element_id,
			x_node_rec                 => l_parent_node_rec,
			x_return_status            => x_return_status,
			x_msg_data                 => x_msg_data
			);

			IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				CLOSE c_error_xml_element;
				RAISE FND_API.G_EXC_ERROR;
			END IF;

			l_element_id := l_parent_node_rec.IMP_XML_ELEMENT_ID;
			IF l_element_id IS NOT NULL THEN
				l_column_name :=   '(' || l_parent_node_rec.COLUMN_NAME || ').'
										  || l_column_name;
			END IF;
		END LOOP;
	END IF;
	CLOSE c_error_xml_element;

	x_column_name   := l_column_name;
	x_column_value := l_data;

	EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
		WHEN OTHERS THEN
			x_msg_data := 'Unexpected error in '
								|| L_FULL_NAME || ': '|| SQLERRM;
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Get_Error_Info;

-- Start of comments
-- API Name       Get_Children_Nodes
-- Type           Public
-- Pre-reqs       None.
-- Function       Retrieve the information for all child nodes in the
--                "AMS_IMP_XML_ELEMENTS" table, given the node id
-- Parameters
--    IN
--                p_imp_xml_element_id     NUMBER    Required
--    OUT         x_node_rec               AMS_IMP_XML_ELEMENTS%ROWTYPE
--                x_return_status          VARCHAR2
--
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
PROCEDURE Get_Children_Nodes (
	p_imp_xml_element_id       IN    NUMBER,
	x_child_ids                OUT NOCOPY   xml_element_key_set_type,
	x_return_status            OUT NOCOPY   VARCHAR2,
	x_msg_data                 OUT NOCOPY   VARCHAR2
)
IS
	L_API_NAME                 CONSTANT VARCHAR2(30) := 'Get_Children_Nodes';
	L_FULL_NAME                CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;

	--l_child_node_rec AMS_IMP_XML_ELEMENTS%ROWTYPE;

	l_return_status VARCHAR2(1);
	l_msg_data      VARCHAR2(4000);
	l_child_count  NUMBER := 1;
	l_element_rec AMS_IMP_XML_ELEMENTS%ROWTYPE;

	rc_child_set rc_type;
	l_child rc_child_set%ROWTYPE;
BEGIN

	--
	-- Initialize API return status to success.
	--
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_return_status := FND_API.G_RET_STS_SUCCESS;

	IF p_imp_xml_element_id IS NULL THEN
	   x_msg_data := 'Expected error in ' || L_FULL_NAME
	   || ' xml element id is null';
	   RAISE FND_API.G_EXC_ERROR;
	END IF;

	Get_Element_Info (
		p_element_id   => p_imp_xml_element_id,
		x_element_info => l_element_rec);

	IF l_element_rec.imp_xml_document_id IS NULL
	   OR l_element_rec.order_initial IS NULL THEN
	   RAISE FND_API.G_EXC_ERROR;
	END IF;

	rc_child_set := Get_Children_Cursor (
	   p_imp_doc_id => l_element_rec.imp_xml_document_id,
	   p_order_initial => l_element_rec.order_initial);
	LOOP
	   FETCH rc_child_set INTO l_child;
	   EXIT WHEN rc_child_set%NOTFOUND;
	   x_child_ids(l_child_count) := l_child.IMP_XML_ELEMENT_ID;
	   l_child_count := l_child_count + 1;
	END LOOP;
	CLOSE rc_child_set;

	EXCEPTION
	   WHEN FND_API.G_EXC_ERROR THEN
	      x_return_status := FND_API.G_RET_STS_ERROR;
	   WHEN OTHERS THEN
	      x_msg_data := 'Unexpected error in ' || L_FULL_NAME || ': '|| SQLERRM;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Get_Children_Nodes;


-- Start of comments
-- API Name       Get_Children_Nodes
-- Type           Public
-- Pre-reqs       None.
-- Function       Retrieve the information for all child nodes in the
--                "AMS_IMP_XML_ELEMENTS" table, given the node id
-- Parameters
--    IN
--                p_imp_xml_element_id     NUMBER    Required
--    OUT         x_child_set               xml_element_set_type
--                x_return_status          VARCHAR2
--
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
PROCEDURE Get_Children_Nodes (
	p_imp_xml_element_id       IN    NUMBER,
	x_child_set                OUT NOCOPY   xml_element_set_type,
	x_return_status            OUT NOCOPY   VARCHAR2,
	x_msg_data                 OUT NOCOPY   VARCHAR2
)
IS
	L_API_NAME                 CONSTANT VARCHAR2(30) := 'Get_Children_Nodes';
	L_FULL_NAME                CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;

	l_return_status VARCHAR2(1);
	l_msg_data      VARCHAR2(4000);
	l_child_count  NUMBER := 1;
	l_element_rec AMS_IMP_XML_ELEMENTS%ROWTYPE;
	rc_child_set rc_type;
	l_child rc_child_set%ROWTYPE;
BEGIN

	--
	-- Initialize API return status to success.
	--
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_return_status := FND_API.G_RET_STS_SUCCESS;

	IF p_imp_xml_element_id IS NULL THEN
	   x_msg_data := 'Expected error in ' || L_FULL_NAME
		|| ' xml element id is null';
	   RAISE FND_API.G_EXC_ERROR;
	END IF;

	Get_Element_Info (
		p_element_id   => p_imp_xml_element_id,
		x_element_info => l_element_rec);

	IF l_element_rec.imp_xml_document_id IS NULL
	   OR l_element_rec.order_initial IS NULL THEN
	   RAISE FND_API.G_EXC_ERROR;
	END IF;

	rc_child_set := Get_Children_Cursor (
	   p_imp_doc_id => l_element_rec.imp_xml_document_id,
	   p_order_initial => l_element_rec.order_initial);
	LOOP
	   FETCH rc_child_set INTO l_child;
	   EXIT WHEN rc_child_set%NOTFOUND;
		x_child_set(l_child_count) := l_child;
		l_child_count := l_child_count + 1;
	END LOOP;
	CLOSE rc_child_set;

	EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
		WHEN OTHERS THEN
			x_msg_data := 'Unexpected error in '
							  || L_FULL_NAME || ': '|| SQLERRM;
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Get_Children_Nodes;

-- Start of comments
-- API Name       Get_Children_Nodes
-- Type           Public
-- Pre-reqs       None.
-- Function       Retrieve the information for all child nodes in the
--                "AMS_IMP_XML_ELEMENTS" table, given the node id
-- Parameters
--    IN
--                p_imp_xml_element_id     NUMBER    Required
--    OUT         x_child_set               xml_element_set_type
--                x_return_status          VARCHAR2
--
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
PROCEDURE Get_Children_Nodes (
	p_imp_xml_element_id       IN    NUMBER,
	x_rc_child_set             OUT NOCOPY   rc_type,
	x_return_status            OUT NOCOPY   VARCHAR2,
	x_msg_data                 OUT NOCOPY   VARCHAR2
)
IS
	L_API_NAME                 CONSTANT VARCHAR2(30) := 'Get_Children_Nodes';
	L_FULL_NAME                CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;

	l_return_status VARCHAR2(1);
	l_msg_data      VARCHAR2(4000);
	l_child_count  NUMBER := 1;
	l_element_rec AMS_IMP_XML_ELEMENTS%ROWTYPE;

BEGIN

	--
	-- Initialize API return status to success.
	--
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_return_status := FND_API.G_RET_STS_SUCCESS;

	IF p_imp_xml_element_id IS NULL THEN
	   x_msg_data := 'Expected error in ' || L_FULL_NAME
		|| ' xml element id is null';
	   RAISE FND_API.G_EXC_ERROR;
	END IF;

	Get_Element_Info (
		p_element_id   => p_imp_xml_element_id,
		x_element_info => l_element_rec);

	IF l_element_rec.imp_xml_document_id IS NULL
	   OR l_element_rec.order_initial IS NULL THEN
	   RAISE FND_API.G_EXC_ERROR;
	END IF;

	x_rc_child_set := Get_Children_Cursor (
	   p_imp_doc_id => l_element_rec.imp_xml_document_id,
	   p_order_initial => l_element_rec.order_initial);

	EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
		WHEN OTHERS THEN
			x_msg_data := 'Unexpected error in '
							  || L_FULL_NAME || ': '|| SQLERRM;
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Get_Children_Nodes;

-- Start of comments
-- API Name       Filter_XML
-- Type           Public
-- Pre-reqs       None.
-- Function       Filter out the leaf nodes of an xml doc if they are not in mapping
-- Parameters
--    IN
--                p_import_list_header_id  NUMBER    Required
--    OUT         x_return_status          VARCHAR2
--                x_msg_data               VARCHAR2
--
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
PROCEDURE Filter_XML (
	p_import_list_header_id    IN     NUMBER,
	x_return_status            OUT NOCOPY    VARCHAR2,
	x_msg_data                 OUT NOCOPY    VARCHAR2,
	x_result_xml               IN OUT NOCOPY CLOB,
	x_doc_id                   OUT NOCOPY    NUMBER
)
IS
	L_API_NAME     CONSTANT VARCHAR2(30) := 'Filter_XML';
	L_FULL_NAME    CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;

	l_return_status VARCHAR2(1);
	l_msg_data      VARCHAR2(4000);
	l_mapping_source_fields xml_source_column_set_type;
	l_xml_doc_clob CLOB;
	l_xml_doc_result_clob CLOB;

	l_parser xmlparser.Parser;
	l_xml_doc xmldom.DOMDocument;
	l_dom_root xmldom.DOMNode;
	l_dom_actual_root xmldom.DOMNode;

	CURSOR c_import_source_fields (p_import_list_header_id NUMBER) IS
		SELECT A.SOURCE_COLUMN_NAME
		FROM ams_list_src_fields A, ams_imp_list_headers_all b
		WHERE b.IMPORT_LIST_HEADER_ID = p_import_list_header_id
		AND b.LIST_SOURCE_TYPE_ID = A.LIST_SOURCE_TYPE_ID
		ORDER BY LIST_SOURCE_FIELD_ID;

	CURSOR c_xml_doc_content (p_import_list_header_id NUMBER) IS
		SELECT CONTENT_TEXT, IMP_DOCUMENT_ID
		FROM AMS_IMP_DOCUMENTS
		WHERE IMPORT_LIST_HEADER_ID = p_import_list_header_id;

	XMLParseError EXCEPTION;
	PRAGMA EXCEPTION_INIT (XMLParseError, -20100);
	p_buffer VARCHAR2(4000);
	l_result_xml_content CLOB;
	l_actual_root_name VARCHAR2 (2000);

BEGIN

	--
	-- Initialize API return status to success.
	--
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_return_status := FND_API.G_RET_STS_SUCCESS;

	IF p_import_list_header_id IS NULL THEN
		x_msg_data := 'Expected error in ' || L_FULL_NAME
								 || ' list header id is null';
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	OPEN c_import_source_fields (p_import_list_header_id);
	FETCH c_import_source_fields BULK COLLECT INTO
	l_mapping_source_fields;
	CLOSE c_import_source_fields;

	--l_mapping_source_fields(1) := '(PRODUCT).(PRICING).(PRICE).(PRICE_LIST_NAME)';
	--l_mapping_source_fields(2) := '(PRODUCT).(PRICING).(PRICE).(CURRENCY)';
	--l_mapping_source_fields(3) := '(PRODUCT).(PRICING).(PRICE).(AMOUNT)';
	--l_mapping_source_fields(4) := '(PRODUCT).(CATEGORY).(CAT).(CATEGORY_SET)';
	--l_mapping_source_fields(5) := '(PRODUCT).(CATEGORY).(CAT).(CATEGORY_CODE)';

	/*********************** END ************************************/
	IF l_mapping_source_fields.COUNT > 1 THEN
		OPEN c_xml_doc_content (p_import_list_header_id);
		FETCH c_xml_doc_content INTO l_xml_doc_clob, x_doc_id;
		IF c_xml_doc_content%FOUND THEN
			l_parser := xmlparser.newParser;
			xmlparser.parseClob (l_parser, l_xml_doc_clob);
			l_xml_doc := xmlparser.getDocument(l_parser);

			-- virtual root
			l_dom_root := xmldom.makeNode(l_xml_doc);

			--actual root
			l_dom_actual_root := xmldom.item (xmldom.getChildNodes(l_dom_root), 1);

			l_actual_root_name := xmldom.getNodeName(l_dom_actual_root);

			Filter_XML_Helper (
				p_node => l_dom_actual_root,
				p_mapping => l_mapping_source_fields,
				p_source_col_name => '(' || l_actual_root_name || ')'
			);

			SELECT FILTER_CONTENT_TEXT INTO l_result_xml_content
			FROM AMS_IMP_DOCUMENTS
			WHERE IMPORT_LIST_HEADER_ID = p_import_list_header_id
			FOR UPDATE;

			xmldom.writeToClob(l_dom_actual_root, l_result_xml_content);
			--commit;
			xmlparser.freeParser (l_parser);
		END IF;
		CLOSE c_xml_doc_content;
	END IF;

	EXCEPTION
		WHEN XMLParseError THEN
			xmlparser.freeParser (l_parser);
			x_return_status := FND_API.G_RET_STS_ERROR;
			x_msg_data := x_msg_data || 'XML parse error in ' || L_FULL_NAME || ': '|| SQLERRM;
		WHEN FND_API.G_EXC_ERROR THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
		WHEN OTHERS THEN
			x_msg_data := x_msg_data || 'Unexpected error in '
						  || L_FULL_NAME || ': '|| SQLERRM;
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Filter_XML;

PROCEDURE Filter_XML_Helper (
	p_node            IN OUT NOCOPY xmldom.DOMNode,
	p_mapping         IN     xml_source_column_set_type,
	p_source_col_name IN     VARCHAR2
)
IS
	l_child_list      xmldom.DOMNodeList;
	l_num_children    NUMBER;
	l_child_node      xmldom.DOMNode;
	l_grand_child_node xmldom.DOMNode;
	l_cur_source_col_name VARCHAR2(2000);
	l_num_child_offset    NUMBER;

	l_temp VARCHAR2(4000);
	l_temp1 VARCHAR2(4000);
BEGIN
	l_child_list := xmldom.getChildNodes(p_node);
	l_num_children := xmldom.getLength (l_child_list);

	FOR i IN 0 .. l_num_children -1
	LOOP

		l_child_node := xmldom.item(l_child_list, i);

		IF p_source_col_name IS NULL THEN
			l_cur_source_col_name := '(' || xmldom.getNodeName(l_child_node) || ')';
		ELSE
			l_cur_source_col_name := p_source_col_name || '.(' || xmldom.getNodeName(l_child_node) || ')';
		END IF;

		l_grand_child_node := xmldom.getFirstChild(l_child_node);
		IF xmldom.hasChildNodes(l_child_node)
			AND ( xmldom.getLength (xmldom.getChildNodes(l_child_node)) <> 1
			OR UPPER(RTRIM(LTRIM(xmldom.getNodeName (l_grand_child_node)))) <> '#TEXT')
		THEN

			Filter_XML_Helper (
				p_node                          => l_child_node,
				p_mapping                       => p_mapping,
				p_source_col_name => l_cur_source_col_name
			);
		ELSE
			-- one grand child
			IF xmldom.getLength (xmldom.getChildNodes(l_child_node)) = 1
			-- grand child is leaf
				AND UPPER(RTRIM(LTRIM(xmldom.getNodeName (l_grand_child_node)))) = '#TEXT'
				AND NOT Is_In_Mapping ( --leaf not in mapping
				p_item          => l_cur_source_col_name,
				p_mapping       => p_mapping
				) THEN
				p_node := xmldom.removeChild(l_child_node, l_grand_child_node);
			END IF;
		END IF;

	END LOOP;

	EXCEPTION
		WHEN OTHERS THEN
			l_temp1 := 'Unexpected error in '
						  || ': '|| SQLERRM;
END Filter_XML_Helper;

FUNCTION Is_In_Mapping (
	p_item          IN VARCHAR2,
	p_mapping       IN xml_source_column_set_type
) RETURN BOOLEAN
IS
BEGIN
	FOR i IN p_mapping.FIRST .. p_mapping.LAST
	LOOP
		IF p_mapping (i) = p_item THEN
			RETURN TRUE;
		END IF;
	END LOOP;
	RETURN FALSE;
END Is_In_Mapping;

-- Start of comments
-- API Name       Store_XML_Elements
-- Type           Private
-- Pre-reqs       None.
-- Function       Takes an XML as a CLOB, parses and stores it into the "AMS_IMP_XML_ELEMENTS" table
--                and "AMS_IMP_XML_ATTRIBUTES" table.
-- Parameters
--    IN
--                p_xml_content           CLOB                       Required
--    OUT         x_return_status         VARCHAR2
--                x_msg_data              VARCHAR2
--
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
PROCEDURE Store_XML_Elements (
	p_xml_doc_id             IN   NUMBER,
	p_imp_list_header_id     IN   NUMBER,
	p_xml_content				 IN   CLOB,
	p_commit                 IN   VARCHAR2 := FND_API.G_FALSE,
	x_return_status          OUT NOCOPY  VARCHAR2,
	x_msg_data               OUT NOCOPY  VARCHAR2
)
IS
	L_API_NAME        CONSTANT VARCHAR2(30) := 'Store_XML_Elements';
	L_FULL_NAME       CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;

	l_return_status VARCHAR2(1);
	l_msg_data      VARCHAR2(4000);
	l_order_num     NUMBER;
	l_mapping_source_fields xml_source_column_set_type;
	l_mapping_target_fields xml_target_column_set_type;

	l_parser xmlparser.Parser;
	l_xml_doc xmldom.DOMDocument;
	l_dom_root xmldom.DOMNode;
	l_dom_actual_root xmldom.DOMNode;

	CURSOR c_import_mapping_fields (p_import_list_header_id NUMBER) IS
		SELECT A.SOURCE_COLUMN_NAME, A.FIELD_COLUMN_NAME
		FROM ams_list_src_fields A, ams_imp_list_headers_all b
		WHERE b.IMPORT_LIST_HEADER_ID = p_import_list_header_id
		AND b.LIST_SOURCE_TYPE_ID = A.LIST_SOURCE_TYPE_ID
		ORDER BY LIST_SOURCE_FIELD_ID;

	CURSOR c_xml_content (p_import_list_header_id NUMBER) IS
		SELECT CONTENT_TEXT
		FROM AMS_IMP_DOCUMENTS
		WHERE IMPORT_LIST_HEADER_ID = p_import_list_header_id;

	XMLParseError EXCEPTION;
	PRAGMA EXCEPTION_INIT (XMLParseError, -20100);
	p_buffer VARCHAR2(4000);
	l_xml_content CLOB;
	l_temp VARCHAR2(4000);

	l_result_xml_content CLOB;
	l_result_xml_node xmldom.DOMNode;
	l_col VARCHAR2(2000);
	l_value VARCHAR2(2000);

	--l_clone_node xmldom.DOMNode;
	l_temp_doc xmldom.DOMDocument;
	l_temp_element xmldom.DOMElement;

	l_actual_root_name VARCHAR2(2000);

BEGIN

	--
	-- Initialize API return status to success.
	--
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_return_status := FND_API.G_RET_STS_SUCCESS;

	OPEN c_xml_content (p_imp_list_header_id);
	FETCH c_xml_content INTO l_xml_content;
	CLOSE c_xml_content;

	IF l_xml_content IS NOT NULL THEN

		OPEN c_import_mapping_fields (p_imp_list_header_id);
		FETCH c_import_mapping_fields BULK COLLECT INTO
		l_mapping_source_fields, l_mapping_target_fields;
		CLOSE c_import_mapping_fields;
		l_parser := xmlparser.newParser;

		xmlparser.parseClob (l_parser, l_xml_content);

		l_xml_doc := xmlparser.getDocument(l_parser);

		-- virtual root
		l_dom_root := xmldom.makeNode(l_xml_doc);

		--l_temp := ' Store_XML_Elements 05-01:' || xmldom.getNodeName (l_dom_root);

		--actual root
		IF xmldom.getLength (xmldom.getChildNodes(l_dom_root)) = 1 THEN
			l_dom_actual_root := xmldom.item (xmldom.getChildNodes(l_dom_root), 0);
		ELSE
			l_dom_actual_root := xmldom.item (xmldom.getChildNodes(l_dom_root), 1);
		END IF;

		--l_temp := ' Store_XML_Elements 06:' || xmldom.getNodeName (l_dom_actual_root);
		l_order_num := G_ORDER_INITIAL_START_NUMBER;

		l_temp_doc := xmldom.newDOMDocument;

		l_actual_root_name := xmldom.getNodeName (l_dom_actual_root);
		l_temp_element := xmldom.createElement(l_temp_doc, l_actual_root_name);
		l_result_xml_node := xmldom.makeNode(l_temp_element);

		Store_XML_Elements_Helper (
			p_node          => l_dom_actual_root,
			p_source_fields => l_mapping_source_fields,
			p_target_fields => l_mapping_target_fields,
			p_col_name      => NULL,
			p_xml_doc_id    => p_xml_doc_id,
			p_commit        => p_commit,
			x_order_num     => l_order_num,
			p_result_node   => l_result_xml_node,
			p_column_name   => l_col,
			p_value         => l_value,
			p_result_doc    => l_temp_doc
		);

		SELECT FILTER_CONTENT_TEXT INTO l_result_xml_content
		FROM AMS_IMP_DOCUMENTS
		WHERE IMPORT_LIST_HEADER_ID = p_imp_list_header_id
		FOR UPDATE;

		xmldom.writeToClob (l_result_xml_node, l_result_xml_content);
		--commit;
		IF FND_API.to_boolean(p_commit) THEN
			COMMIT;
		END IF;
		xmldom.freeDocument(l_temp_doc);
	ELSE
		x_return_status := FND_API.G_RET_STS_ERROR;
		x_msg_data := 'No XML data found';
		RAISE FND_API.G_EXC_ERROR;
	END IF;

EXCEPTION
	WHEN XMLParseError THEN
		xmlparser.freeParser (l_parser);
		x_return_status := FND_API.G_RET_STS_ERROR;
		x_msg_data := x_msg_data || 'XML parse error in ' || L_FULL_NAME || ': '|| SQLERRM;

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
	WHEN OTHERS THEN
		x_msg_data := x_msg_data || 'Unexpected error in '
						  || L_FULL_NAME || ': '|| SQLERRM;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Store_XML_Elements;

PROCEDURE Store_XML_Elements_Helper (
	p_node          IN xmldom.DOMNode,
	p_source_fields IN xml_source_column_set_type,
	p_target_fields IN xml_target_column_set_type,
	p_col_name      IN VARCHAR2,
	p_xml_doc_id    IN NUMBER,
	p_commit        IN VARCHAR2 := FND_API.G_FALSE,
	x_order_num     IN OUT NOCOPY NUMBER,
	p_result_node   IN OUT NOCOPY xmldom.DOMNode,
	p_column_name   IN OUT NOCOPY VARCHAR2,
	p_value         IN OUT NOCOPY VARCHAR2,
	p_result_doc    IN OUT NOCOPY xmldom.DOMDocument
)
IS
	l_xml_element_rec AMS_IMP_XML_ELEMENTS%ROWTYPE;
	l_col_name        VARCHAR2(2000);
	l_cur_col_name    VARCHAR2(2000);
	l_child_list      xmldom.DOMNodeList;
	l_num_children    NUMBER;
	l_child_node      xmldom.DOMNode;
	l_now             DATE := SYSDATE;
	l_in_mapping_flag BOOLEAN := FALSE;
	l_curr_element    xmldom.DOMElement;
	l_col VARCHAR2(2000);
	l_value VARCHAR2(2000);
	l_child_element xmldom.DOMElement;
	l_child_dom_node xmldom.DOMNode;
	--l_dom_doc xmldom.DOMDocument := xmldom.makeDocument (p_node); --commented for bug4961953

	l_dummy_node xmldom.DOMNode;

	l_msg VARCHAR2(2000);
	l_temp VARCHAR2(2000);
	l_temp1 VARCHAR2(2000);
	--l_clone_node xmldom.DOMNode;
	l_child_doc xmldom.DOMDocument;

	l_text_data xmldom.DOMText;
	--createTextNode(doc DOMDocument, data IN VARCHAR2) RETURN DOMText
BEGIN

	--l_temp := ' TEST01::';
	l_xml_element_rec.DATA_TYPE := G_DATA_TYPE_TAG;
	l_xml_element_rec.IMP_XML_DOCUMENT_ID := p_xml_doc_id;
	l_xml_element_rec.ORDER_INITIAL := x_order_num;
	IF p_col_name IS NULL THEN
		l_cur_col_name := '(' || xmldom.getNodeName (p_node) || ')';
	ELSE
		l_cur_col_name := p_col_name || '.(' || xmldom.getNodeName (p_node) || ')';
	END IF;

	--l_temp := l_temp || ' TEST02::';
	l_col_name := Get_Col_name (
		p_source_fields => p_source_fields,
		p_target_fields => p_target_fields,
		p_col_name      => l_cur_col_name
		);
	--l_temp := l_temp || ' l_col_name::' || l_col_name;
	IF l_col_name IS NULL THEN --not in mapping
		l_xml_element_rec.COLUMN_NAME := xmldom.getNodeName (p_node);
	ELSE -- in mapping
		l_in_mapping_flag := TRUE;
		l_xml_element_rec.COLUMN_NAME := l_col_name;
	END IF;

	--l_temp := l_temp || ' l_xml_element_rec.COLUMN_NAME::'
	--	|| l_xml_element_rec.COLUMN_NAME;

	l_child_list := xmldom.getChildNodes(p_node);
	l_num_children := xmldom.getLength (l_child_list);

	IF l_num_children <> 1
	OR UPPER(RTRIM(LTRIM(xmldom.getNodeName (xmldom.item(l_child_list, 0))))) <> '#TEXT' THEN
		FOR i IN 0 .. l_num_children -1
		LOOP
			l_child_node := xmldom.item(l_child_list, i);
			x_order_num := x_order_num + 1;

			l_col := l_cur_col_name || '.(' || xmldom.getNodeName (l_child_node) || ')';

			l_col := Get_Col_name (
				p_source_fields => p_source_fields,
				p_target_fields => p_target_fields,
				p_col_name      => l_col
				);
			IF l_col IS NULL THEN
				l_col := xmldom.getNodeName (l_child_node);
			END IF;

	      --l_clone_node := xmldom.cloneNode (l_child_node, FALSE);
			--l_child_doc := xmldom.newDOMDocument;
			l_child_element := xmldom.createElement(p_result_doc, l_col);

			--l_temp := xmldom.getTagName (l_child_element);

			l_child_dom_node := xmldom.makeNode(l_child_element);

			--l_temp := xmldom.getNodeName(l_child_dom_node);
			--l_temp := 'hui 30::::name::' || l_temp;


			Store_XML_Elements_Helper (
				p_node          => l_child_node,
				p_source_fields => p_source_fields,
				p_target_fields => p_target_fields,
				p_col_name      => l_cur_col_name,
				p_xml_doc_id    => p_xml_doc_id,
				x_order_num     => x_order_num,
				p_result_node   => l_child_dom_node,
				p_column_name   => l_col,
				p_value         => l_value,
				p_result_doc    => p_result_doc
			);

			IF l_value IS NOT NULL THEN
				l_text_data := xmldom.createTextNode(p_result_doc, l_value);
				l_dummy_node := xmldom.appendChild (l_child_dom_node, xmldom.makeNode(l_text_data));
			END IF;

			--l_dummy_node := xmldom.appendChild (l_child_dom_node, xmldom.makeNode(l_text_data));


			l_dummy_node := xmldom.appendChild (p_result_node, l_child_dom_node);

			--xmldom.freeDocument (l_child_doc);

		END LOOP;
	END IF;
	x_order_num := x_order_num + 1;
	l_xml_element_rec.ORDER_FINAL := x_order_num;

	IF l_num_children = 1
	AND UPPER(RTRIM(LTRIM(xmldom.getNodeName (xmldom.item(l_child_list, 0))))) = '#TEXT' THEN
		l_xml_element_rec.DATA_TYPE := G_DATA_TYPE_DATA;
		IF l_in_mapping_flag THEN
			l_xml_element_rec.DATA := RTRIM(LTRIM(xmldom.getNodeValue(xmldom.item(l_child_list, 0))));
		ELSE
			l_xml_element_rec.DATA := '';
		END IF;
	ELSIF l_num_children = 0 THEN
		l_xml_element_rec.DATA_TYPE := G_DATA_TYPE_DATA;
	ELSE
		l_xml_element_rec.DATA_TYPE := G_DATA_TYPE_TAG;
	END IF;

	/****
	IF xmldom.getNodeType (p_node) = xmldom.TEXT_NODE THEN
		l_xml_element_rec.DATA_TYPE := G_DATA_TYPE_DATA;
	ELSE
		l_xml_element_rec.DATA_TYPE := G_DATA_TYPE_TAG;
	END IF;
	****/

	l_xml_element_rec.NUM_ATTR := Store_XML_Attributes (
		p_node            => p_node,
		p_order_init      => l_xml_element_rec.ORDER_INITIAL,
		p_xml_doc_id      => l_xml_element_rec.IMP_XML_DOCUMENT_ID,
		p_commit          => p_commit);

	INSERT INTO AMS_IMP_XML_ELEMENTS (
		IMP_XML_ELEMENT_ID,
		LAST_UPDATED_BY,
		OBJECT_VERSION_NUMBER,
		CREATED_BY,
		LAST_UPDATE_LOGIN,
		LAST_UPDATE_DATE,
		CREATION_DATE,
		IMP_XML_DOCUMENT_ID,
		ORDER_INITIAL,
		ORDER_FINAL,
		COLUMN_NAME,
		DATA,
		NUM_ATTR,
		LOAD_STATUS,
		DATA_TYPE)
	VALUES (
		AMS_IMP_XML_ELEMENTS_S.NEXTVAL,
		FND_GLOBAL.User_ID,
		1.0,
		FND_GLOBAL.User_ID,
		FND_GLOBAL.Conc_Login_ID,
		l_now,
		l_now,
		l_xml_element_rec.IMP_XML_DOCUMENT_ID,
		l_xml_element_rec.ORDER_INITIAL,
		l_xml_element_rec.ORDER_FINAL,
		l_xml_element_rec.COLUMN_NAME,
		l_xml_element_rec.DATA,
		l_xml_element_rec.NUM_ATTR,
		'ACTIVE',
		l_xml_element_rec.DATA_TYPE);

	p_column_name := l_xml_element_rec.COLUMN_NAME;
	p_value := l_xml_element_rec.DATA;

	--COMMIT WORK;
	--
	-- Standard check for commit request.
	--
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;
EXCEPTION

	WHEN OTHERS THEN
		RAISE;
END Store_XML_Elements_Helper;

FUNCTION Store_XML_Attributes (
	p_node            IN xmldom.DOMNode,
	p_order_init      IN NUMBER,
	p_xml_doc_id      IN NUMBER,
	p_commit          IN VARCHAR2 := FND_API.G_FALSE
) RETURN NUMBER
IS
	l_xml_attribute_rec AMS_IMP_XML_ATTRIBUTES%ROWTYPE;
	l_num_attr     NUMBER := 0;
	l_att_seq      NUMBER := 1;
	--l_element    xmldom.DOMElement;
	l_attr_map     xmldom.DOMNamedNodeMap;
	l_node         xmldom.DOMNode;
	l_now          DATE := SYSDATE;

BEGIN
	l_attr_map := xmldom.getAttributes (p_node);
	IF NOT xmldom.isNull(l_attr_map) THEN
		l_num_attr := xmldom.getLength(l_attr_map);
		FOR i IN 0 .. l_num_attr - 1
		LOOP
			l_node := xmldom.item (l_attr_map, i);
			l_xml_attribute_rec.ATT_NAME := xmldom.getNodeName (l_node);
			l_xml_attribute_rec.ATT_VALUE := xmldom.getNodeValue (l_node);
			l_xml_attribute_rec.ATT_SEQ := i + 1;

			INSERT INTO AMS_IMP_XML_ATTRIBUTES (
			IMP_XML_ATTRIBUTE_ID,
			LAST_UPDATED_BY,
			OBJECT_VERSION_NUMBER,
			CREATED_BY,
			LAST_UPDATE_LOGIN,
			LAST_UPDATE_DATE,
			CREATION_DATE,
			--IMP_DOCUMENT_ID,
			IMP_XML_DOCUMENT_ID,
			ORDER_INITIAL,
			ATT_SEQ,
			ATT_NAME,
			ATT_VALUE)
			VALUES (
			AMS_IMP_XML_ATTRIBUTES_S.NEXTVAL,
			FND_GLOBAL.User_ID,
			1.0,
			FND_GLOBAL.User_ID,
			FND_GLOBAL.Conc_Login_ID,
			l_now,
			l_now,
			p_xml_doc_id,
			p_order_init,
			l_xml_attribute_rec.ATT_SEQ,
			l_xml_attribute_rec.ATT_NAME,
			l_xml_attribute_rec.ATT_VALUE);
		END LOOP;
	END IF;

	--
	-- Standard check for commit request.
	--
	IF FND_API.To_Boolean (p_commit) THEN
		COMMIT WORK;
	END IF;
	RETURN l_num_attr;
END Store_XML_Attributes;

FUNCTION Get_Col_name (
	p_source_fields IN xml_source_column_set_type,
	p_target_fields IN xml_target_column_set_type,
	p_col_name      IN VARCHAR2
) RETURN VARCHAR2
IS
	l_seq_num NUMBER := 1;
BEGIN
	FOR i IN p_source_fields.FIRST .. p_source_fields.LAST
	LOOP
		IF p_source_fields(i) = p_col_name THEN
			IF INSTR (UPPER(LTRIM(p_target_fields(i))), 'AMS_COL') = 1 THEN
				RETURN NULL;
			ELSE
				RETURN p_target_fields(i);
			END IF;
		END IF;
	END LOOP;
	RETURN NULL;
END Get_Col_name;

-- Start of comments
-- API Name       Store_XML_Util
-- Type           Public
-- Pre-reqs       None.
-- Function       Takes the list import header id, filter and populate xml into the xml element
--                xml attribute tables.
-- Parameters
--    IN
--                p_import_list_header_id    IN    NUMBER,
--                p_ownerId                  IN    NUMBER,
--                p_generateList_flag        IN    VARCHAR2,
--                p_list_name                IN    VARCHAR2,
--                p_import_flag              IN    VARCHAR2,
--                p_status_code              IN    VARCHAR2
--    OUT         Retcode		           VARCHAR2
--                Errbuf			   VARCHAR2
--
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
PROCEDURE Store_XML_Util (
	Errbuf                     OUT NOCOPY   VARCHAR2,
	Retcode                    OUT NOCOPY   VARCHAR2,
	p_import_list_header_id    IN    NUMBER,
	p_ownerId                  IN    NUMBER,
	p_generateList_flag        IN    VARCHAR2,
	p_list_name                IN    VARCHAR2,
	p_import_flag              IN    VARCHAR2,
	p_status_code              IN    VARCHAR2
)
IS
	L_API_NAME           CONSTANT VARCHAR2(30) := 'Store_XML_Util';
	L_FULL_NAME          CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;
	l_xml_doc_content    CLOB;
	l_doc_id             NUMBER;

	CURSOR c_doc_id (p_import_list_header_id NUMBER) IS
	SELECT IMP_DOCUMENT_ID
	FROM AMS_IMP_DOCUMENTS
	WHERE IMPORT_LIST_HEADER_ID = p_import_list_header_id;

	CURSOR c_status_id
	IS SELECT user_status_id
	FROM ams_user_statuses_vl
	WHERE system_status_type = 'AMS_IMPORT_STATUS'
	AND system_status_code = 'STAGED'
	AND default_flag = 'Y';

	l_user_status_id NUMBER;
BEGIN
	Retcode := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT Store_XML_Util;

	IF UPPER(p_status_code) = 'NEW' THEN
		--Filter_XML (
		--	p_import_list_header_id    => p_import_list_header_id,
		--	x_return_status            => Retcode,
		--x_msg_data                 => Errbuf,
		--	x_result_xml               => l_xml_doc_content,
		--	x_doc_id                   => l_doc_id
		--);

		--IF Retcode <> FND_API.G_RET_STS_SUCCESS THEN
		--	RAISE FND_API.G_EXC_ERROR;
		--END IF;

		OPEN c_doc_id (p_import_list_header_id);
		FETCH c_doc_id INTO l_doc_id;
		CLOSE c_doc_id;

		IF l_doc_id IS NULL THEN
			Errbuf := 'Can not find document id:';
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		Store_XML_Elements (
			p_xml_doc_id               => l_doc_id,
			p_imp_list_header_id       => p_import_list_header_id,
			p_xml_content              => l_xml_doc_content,
			p_commit                   => FND_API.G_TRUE,
			x_return_status            => Retcode,
			x_msg_data                 => Errbuf
		);

		IF Retcode <> FND_API.G_RET_STS_SUCCESS THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		OPEN c_status_id;
		FETCH c_status_id  INTO l_user_status_id;
		CLOSE c_status_id;

		UPDATE AMS_IMP_LIST_HEADERS_ALL
		SET STATUS_CODE = 'STAGED', USER_STATUS_ID = l_user_status_id
		WHERE IMPORT_LIST_HEADER_ID = p_import_list_header_id;
	END IF;

   IF UPPER (p_import_flag) = 'Y' THEN

		AMS_ListImport_PVT.client_load(
			p_import_list_header_id  => p_import_list_header_id,
			p_owner_user_id          => p_ownerId,
			p_generate_list          => p_generateList_flag,
			p_list_name              => p_list_name
			);

    END IF;

	--DBMS_LOB.FREETEMPORARY (l_xml_doc_content);
	COMMIT WORK;

	EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
			--DBMS_LOB.FREETEMPORARY (l_xml_doc_content);
			ROLLBACK TO Store_XML_Util;
			Retcode := FND_API.G_RET_STS_ERROR;
		WHEN OTHERS THEN
			--DBMS_LOB.FREETEMPORARY (l_xml_doc_content);
			ROLLBACK TO Store_XML_Util;
			Errbuf := 'Unexpected error in '
						|| L_FULL_NAME || ': '|| SQLERRM;
			Retcode := FND_API.G_RET_STS_UNEXP_ERROR;
END Store_XML_Util;

-- Start of comments
-- API Name       Store_XML
-- Type           Public
-- Pre-reqs       None.
-- Function       Takes the list import header id, filter and populate xml into the xml element
--                xml attribute tables.
-- Parameters
--    IN
--                p_import_list_header_id    IN       NUMBER,
--                     p_commit              IN       VARCHAR2 := FND_API.G_TRUE,
--                     p_ownerId             IN       NUMBER,
--                p_generateList_flag        IN       VARCHAR2,
--                     p_list_name           IN       VARCHAR2,
--                p_import_flag              IN       VARCHAR2,
--                p_status_code              IN       VARCHAR2
--    OUT         x_return_status         VARCHAR2
--                x_msg_data              VARCHAR2
--
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
PROCEDURE Store_XML (
	p_import_list_header_id    IN       NUMBER,
	p_commit                   IN       VARCHAR2 := FND_API.G_FALSE,
	p_ownerId                  IN       NUMBER,
	p_generateList_flag        IN       VARCHAR2,
	p_list_name                IN       VARCHAR2,
	p_import_flag              IN       VARCHAR2,
	p_status_code              IN       VARCHAR2,
	x_return_status            OUT NOCOPY      VARCHAR2,
	x_msg_data                 OUT NOCOPY      VARCHAR2
)
IS
	CURSOR c_xml_doc (p_import_list_header_id NUMBER)
	IS SELECT CONTENT_TEXT
	FROM AMS_IMP_DOCUMENTS
	WHERE IMPORT_LIST_HEADER_ID = p_import_list_header_id;

	l_xml_clob c_xml_doc%ROWTYPE;
	l_doc_length NUMBER;
	l_profile_length NUMBER := 0;
	l_request_id NUMBER;
	l_ret_status VARCHAR2(1);
	l_client_file_size VARCHAR2 (20);
	l_msg_count NUMBER;
BEGIN

	SAVEPOINT Store_XML;
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	--l_request_id := FND_REQUEST.SUBMIT_REQUEST (
	--		application   => 'AMS',
	--		program       => 'AMS_IMP_REP_TEST',
	--		argument1     => '14123');

	l_client_file_size := fnd_profile.value('AMS_IMP_CLIENT_FILE_SIZE');
	l_profile_length := TO_NUMBER (l_client_file_size);
	OPEN c_xml_doc (p_import_list_header_id);
	FETCH c_xml_doc INTO l_xml_clob;
	IF c_xml_doc%FOUND THEN
		l_doc_length := DBMS_LOB.GETLENGTH (l_xml_clob.CONTENT_TEXT);
		IF l_doc_length >= l_profile_length THEN
			l_request_id := FND_REQUEST.SUBMIT_REQUEST (
			application   => 'AMS',
			program       => 'AMSILXOM',
			argument1     => p_import_list_header_id,
			argument2     => p_ownerId,
			argument3     => p_generateList_flag,
			argument4     => p_list_name,
			argument5     => p_import_flag,
			argument6     => p_status_code);
			IF l_request_id = 0 THEN
				AMS_Utility_PVT.Create_Log (
				x_return_status   => l_ret_status,
				p_arc_log_used_by => G_ARC_IMPORT_HEADER,
				p_log_used_by_id  => p_import_list_header_id,
				p_msg_data        => 'Can  not start the list import XML Load Concurrent Program.',
				p_msg_type        => 'DEBUG'
				);
				x_msg_data := 'Can  not start the list import XML Load Concurrent Program.';

				RAISE FND_API.G_EXC_ERROR;
			END IF;

			AMS_Utility_PVT.Create_Log (
			x_return_status   => l_ret_status,
			p_arc_log_used_by => G_ARC_IMPORT_HEADER,
			p_log_used_by_id  => p_import_list_header_id,
			p_msg_data        => 'List Import XML Load Concurrent Program AMSILXOM Started.',
			p_msg_type        => 'DEBUG'
			);

		ELSE
			Store_XML_Util (
				Errbuf                     => x_msg_data,
				Retcode                    => x_return_status,
				p_import_list_header_id         => p_import_list_header_id,
				p_ownerId                  => p_ownerId,
				p_generateList_flag        => p_generateList_flag,
				p_list_name                => p_list_name,
				p_import_flag              => p_import_flag,
				p_status_code              => p_status_code
			);
			IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				RAISE FND_API.G_EXC_ERROR;
			END IF;
		END IF;
	END IF;
	CLOSE c_xml_doc;

	EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Store_XML;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.count_and_get(
			p_encoded => FND_API.g_false,
			p_count   => l_msg_count,
			p_data    => x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO Store_XML;
		x_return_status := FND_API.g_ret_sts_unexp_error ;

		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
			FND_MSG_PUB.add_exc_msg(g_pkg_name, 'error_capture');
		END IF;

		FND_MSG_PUB.count_and_get(
		    p_encoded => FND_API.g_false,
		    p_count   => l_msg_count,
		    p_data    => x_msg_data
		);

END Store_XML;

END AMS_Import_XML_PVT;

/
