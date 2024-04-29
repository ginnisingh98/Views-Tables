--------------------------------------------------------
--  DDL for Package IBC_UTILITIES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_UTILITIES_GRP" AUTHID CURRENT_USER as
/* $Header: ibcgutls.pls 115.1 2003/08/04 20:57:49 enunez noship $ */


-- --------------------------------------------------------------
-- Get_Rendition_File_Id
--
-- Valid content item id or citem version id must be given.  If
-- version id is given, the rendition returned will be for that
-- particular version.  If version id is not given and valid
-- content item id is given, the rendition returned will be for
-- the live version.
--
-- --------------------------------------------------------------
PROCEDURE Get_Rendition_File_Id (
 	p_api_version			  IN NUMBER    DEFAULT 1.0,
  p_init_msg_list	  IN VARCHAR2  DEFAULT FND_API.g_false,
  p_content_item_id IN NUMBER    DEFAULT NULL,
 	p_citem_ver_id		  IN	NUMBER    DEFAULT NULL,
  p_language        IN VARCHAR2  DEFAULT NULL,
  p_mime_type       IN VARCHAR2,
 	x_file_id      			OUT	NOCOPY NUMBER,
 	x_return_status			OUT NOCOPY VARCHAR2,
  x_msg_count			    OUT NOCOPY NUMBER,
  x_msg_data			     OUT NOCOPY VARCHAR2
);

-- --------------------------------------------------------------
-- Get_accessible_content_items
--
-- --------------------------------------------------------------
PROCEDURE Get_Accessible_Content_Items (
 	p_api_version			    IN NUMBER   DEFAULT 1.0,
  p_init_msg_list	    IN VARCHAR2 DEFAULT FND_API.g_false,
  p_user_id           IN NUMBER   DEFAULT NULL,
  p_language          IN VARCHAR2 DEFAULT NULL,
  p_permission_code   IN VARCHAR2,
  p_directory_node_id IN NUMBER   DEFAULT NULL,
  p_path_pattern      IN VARCHAR2 DEFAULT NULL,
  p_include_subdirs   IN VARCHAR2 DEFAULT FND_API.g_false,
  x_citem_ids         OUT NOCOPY JTF_NUMBER_TABLE,
  x_citem_names       OUT NOCOPY JTF_VARCHAR2_TABLE_100,
 	x_return_status			  OUT NOCOPY VARCHAR2,
  x_msg_count			      OUT NOCOPY NUMBER,
  x_msg_data			       OUT NOCOPY VARCHAR2
);

-- --------------------------------------------------------------
-- Get_citem_stylesheets
--
-- --------------------------------------------------------------
PROCEDURE Get_citem_Stylesheets (
 	p_api_version			  IN NUMBER    DEFAULT 1.0,
  p_init_msg_list	  IN VARCHAR2  DEFAULT FND_API.g_false,
  p_content_item_id IN NUMBER,
  p_language        IN VARCHAR2  DEFAULT NULL,
  x_citem_ids       OUT NOCOPY JTF_NUMBER_TABLE,
  x_citem_names     OUT NOCOPY JTF_VARCHAR2_TABLE_100,
 	x_return_status			OUT NOCOPY VARCHAR2,
  x_msg_count			    OUT NOCOPY NUMBER,
  x_msg_data			     OUT NOCOPY VARCHAR2
);



END IBC_UTILITIES_GRP;

 

/
