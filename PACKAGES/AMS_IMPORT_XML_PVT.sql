--------------------------------------------------------
--  DDL for Package AMS_IMPORT_XML_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_IMPORT_XML_PVT" AUTHID CURRENT_USER AS
/*$Header: amsvmixs.pls 120.1 2005/08/12 18:39:18 appldev noship $*/

--
-- Start of comments.
--
-- NAME
--   AMS_Import_XML_PVT
--
-- PURPOSE
--   The package provides APIs for importing and manipulating xml data.
--
--   Procedures:
--   Is_Leaf_Node
--   Get_File_Type
--   Get_Root_Node
--   Get_First_Child_Node
--   Get_Next_Sibling_Node
--   Get_Parent_Node
--   Get_Children_Nodes
--   Filter_XML
--   Store_XML
--
-- NOTES
--
--
-- HISTORY
-- 04/02/2002   huili        Created
-- 08/09/2002   huili        Added overloaded "Get_Children_Nodes" which returns
--                           table of all children records.
--
-- End of comments.
--
--
-- Start type definition
--
-- Type def for the xml element key
TYPE xml_element_key_set_type IS
  TABLE OF NUMBER INDEX BY BINARY_INTEGER;

--Type def for the source mapping fields
TYPE xml_source_column_set_type IS
  TABLE OF AMS_LIST_SRC_FIELDS.SOURCE_COLUMN_NAME%TYPE INDEX BY BINARY_INTEGER;

--Type def for the target mapping fields
TYPE xml_target_column_set_type IS
  TABLE OF AMS_LIST_SRC_FIELDS.FIELD_COLUMN_NAME%TYPE INDEX BY BINARY_INTEGER;

TYPE xml_element_set_type IS
  TABLE OF AMS_IMP_XML_ELEMENTS%ROWTYPE INDEX BY BINARY_INTEGER;

TYPE rc_type IS REF CURSOR RETURN AMS_IMP_XML_ELEMENTS%ROWTYPE;

-- Start of comments
-- API Name       Store_XML_Util
-- Type           Public
-- Pre-reqs       None.
-- Function       Takes the list import header id, filter and populate xml into the xml element
--                xml attribute tables.
-- Parameters
--    IN
--                p_import_list_header_id               IN              NUMBER,
--                p_ownerId                  IN    NUMBER,
--                p_generateList_flag        IN    VARCHAR2,
--                p_list_name                IN    VARCHAR2,
--                p_import_flag              IN    VARCHAR2,
--                p_status_code              IN    VARCHAR2
--    OUT         Retcode                                                       VARCHAR2
--                Errbuf                                                        VARCHAR2
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
);

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
   x_return_status            OUT NOCOPY   VARCHAR2,
   x_msg_data                 OUT NOCOPY   VARCHAR2
) RETURN BOOLEAN;


-- Start of comments
-- API Name       Get_File_Type
-- Type           Public
-- Pre-reqs       None.
-- Function       Retrieve the file type information (either CSV or XML), given the
--                "import_list_header_id".
-- Parameters
--    IN
--                p_import_list_header_id  NUMBER                       Required
--    OUT         x_file_type              AMS_IMP_DOCUMENTS.FILE_TYPE%TYPE
--                x_return_status          VARCHAR2
--                x_msg_data               VARCHAR2
--
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
PROCEDURE Get_File_Type (
	p_import_list_header_id    IN    NUMBER,
	x_file_type                OUT NOCOPY  AMS_IMP_DOCUMENTS.FILE_TYPE%TYPE,
	x_return_status            OUT NOCOPY   VARCHAR2,
	x_msg_data                 OUT NOCOPY   VARCHAR2
);

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
--                x_msg_data               VARCHAR2
--
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
PROCEDURE Get_Root_Node (
        p_import_list_header_id    IN  NUMBER,
        x_node_rec                 OUT NOCOPY   AMS_IMP_XML_ELEMENTS%ROWTYPE,
        x_return_status            OUT NOCOPY   VARCHAR2,
        x_msg_data                 OUT NOCOPY   VARCHAR2
);

-- Start of comments
-- API Name       Get_Parent_Node
-- Type           Public
-- Pre-reqs       None.
-- Function       Retrieve the information for the parent node in the
--                "AMS_IMP_XML_ELEMENTS" table, given the node id
-- Parameters
--    IN
--                p_imp_xml_element_id     NUMBER Required
--    OUT         x_node_rec               AMS_IMP_XML_ELEMENTS%ROWTYPE
--                x_return_status          VARCHAR2
--                x_msg_data               VARCHAR2
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
);

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
--                x_msg_data               VARCHAR2
--
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
PROCEDURE Get_First_Child_Node (
        p_imp_xml_element_id  IN           NUMBER,
        x_node_rec            OUT NOCOPY   AMS_IMP_XML_ELEMENTS%ROWTYPE,
   x_return_status            OUT NOCOPY   VARCHAR2,
        x_msg_data            OUT NOCOPY   VARCHAR2
);

-- Start of comments
-- API Name       Get_Next_Sibling_Node
-- Type           Public
-- Pre-reqs       None.
-- Function       Retrieve the information for the next sibling node in the
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
        p_imp_xml_element_id               IN           NUMBER,
        x_node_rec                 OUT NOCOPY   AMS_IMP_XML_ELEMENTS%ROWTYPE,
	x_return_status            OUT NOCOPY   VARCHAR2,
        x_msg_data                 OUT NOCOPY   VARCHAR2
);

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
);

-- Start of comments
-- API Name       Get_Children_Nodes
-- Type           Public
-- Pre-reqs       None.
-- Function       Retrieve the information for all child nodes in the
--                "AMS_IMP_XML_ELEMENTS" table, given the node id
-- Parameters
--    IN
--                p_imp_xml_element_id     NUMBER                       Required
--    OUT         x_child_ids              xml_element_key_set_type
--                x_return_status          VARCHAR2
--                x_msg_data               VARCHAR2
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
);

-- Start of comments
-- API Name       Get_Children_Nodes
-- Type           Public
-- Pre-reqs       None.
-- Function       Retrieve the information for all child nodes in the
--                "AMS_IMP_XML_ELEMENTS" table, given the node id
-- Parameters
--    IN
--                p_imp_xml_element_id     NUMBER                       Required
--    OUT         x_child_set              xml_element_key_set_type
--                x_return_status          VARCHAR2
--                x_msg_data               VARCHAR2
--
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
PROCEDURE Get_Children_Nodes (
	p_imp_xml_element_id  IN    NUMBER,
	x_child_set           OUT NOCOPY   xml_element_set_type,
	x_return_status       OUT NOCOPY   VARCHAR2,
   x_msg_data            OUT NOCOPY   VARCHAR2
);

-- Start of comments
-- API Name       Get_Children_Nodes
-- Type           Public
-- Pre-reqs       None.
-- Function       Retrieve the information for all child nodes in the
--                "AMS_IMP_XML_ELEMENTS" table, given the node id
-- Parameters
--    IN
--                p_imp_xml_element_id     NUMBER                       Required
--    OUT         x_rc_child_set              rc_type
--                x_return_status          VARCHAR2
--                x_msg_data               VARCHAR2
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
);

-- Start of comments
-- API Name       Filter_XML
-- Type           Public
-- Pre-reqs       None.
-- Function       Filter out the leaf nodes of an xml doc if they are not in mapping
-- Parameters
--    IN
--                p_import_list_header_id     NUMBER                       Required
--    OUT         x_return_status          VARCHAR2
--                x_msg_data               VARCHAR2
--
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
PROCEDURE Filter_XML (
        p_import_list_header_id    IN              NUMBER,
        x_return_status            OUT NOCOPY      VARCHAR2,
        x_msg_data                 OUT NOCOPY      VARCHAR2,
        x_result_xml               IN OUT NOCOPY   CLOB,
        x_doc_id                   OUT NOCOPY      NUMBER
);

-- Start of comments
-- API Name       Store_XML
-- Type           Public
-- Pre-reqs       None.
-- Function       Takes the list import header id, filter and populate xml into the xml element
--                xml attribute tables.
-- Parameters
--    IN
--                p_import_list_header_id               IN                      NUMBER,
--                     p_commit                   IN       VARCHAR2 := FND_API.G_TRUE,
--                     p_ownerId                  IN       NUMBER,
--                p_generateList_flag        IN       VARCHAR2,
--                     p_list_name                IN       VARCHAR2,
--                p_import_flag              IN                 VARCHAR2,
--                p_status_code              IN                 VARCHAR2
--    OUT         x_return_status         VARCHAR2
--                x_msg_data              VARCHAR2
--
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
PROCEDURE Store_XML (
        p_import_list_header_id    IN   NUMBER,
        p_commit                   IN   VARCHAR2 := FND_API.G_FALSE,
        p_ownerId                  IN   NUMBER,
        p_generateList_flag        IN   VARCHAR2,
        p_list_name                IN   VARCHAR2,
        p_import_flag              IN   VARCHAR2,
        p_status_code              IN   VARCHAR2,
        x_return_status            OUT NOCOPY    VARCHAR2,
        x_msg_data                 OUT NOCOPY    VARCHAR2
);

END AMS_Import_XML_PVT;

 

/
