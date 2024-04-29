--------------------------------------------------------
--  DDL for Package IBC_CITEM_ADMIN_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_CITEM_ADMIN_GRP" AUTHID CURRENT_USER AS
/* $Header: ibcgcias.pls 115.35 2003/10/17 23:55:11 svatsa ship $ */

/*******************************************************************/
/**************************** VARIABLES ****************************/
/*******************************************************************/
G_PKG_NAME                CONSTANT VARCHAR2(30) := 'IBC_CITEM_ADMIN_GRP';

-- shared default value
G_OBJ_VERSION_DEFAULT    CONSTANT NUMBER := 1.0;
-- shared default value
G_API_VERSION_DEFAULT    CONSTANT NUMBER := 1.0;













/*******************************************************************/
/**************************** FUNCTIONS ****************************/
/*******************************************************************/
-- --------------------------------------------------------------
-- GET OBJECT VERSION NUMBER
-- (from content item id)
--
-- --------------------------------------------------------------
FUNCTION getObjVerNum(
    f_citem_id   IN  NUMBER
)
RETURN NUMBER;




















/*******************************************************************/
/**************************** PROCEDURES ***************************/
/*******************************************************************/
-- --------------------------------------------------------------
-- APPROVE CONTENT ITEM VERSION (BASE)
--
-- --------------------------------------------------------------
PROCEDURE approve_item(
    p_citem_ver_id              IN NUMBER
    ,p_commit                   IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version_number       IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.g_false
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
);














-- --------------------------------------------------------------
-- ARCHIVE ITEM
--
-- --------------------------------------------------------------
PROCEDURE archive_item(
    p_content_item_id           IN NUMBER
    ,p_cascaded_flag            IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_commit                   IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version_number       IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.g_false
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
);











-- --------------------------------------------------------------
-- CHANGE STATUS
--
-- --------------------------------------------------------------
PROCEDURE change_status(
    p_citem_ver_id              IN NUMBER
    ,p_new_status               IN VARCHAR2
    ,p_language                 IN VARCHAR2 DEFAULT USERENV('LANG')
    ,p_commit                   IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version_number       IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.g_false
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
);





-- --------------------------------------------------------------
-- COPY ITEM
--
-- --------------------------------------------------------------
-- 11.5.10 Requirement Content Item Name must be unique with in a Folder
-- While Copying a Content Item accept the Name of the New Content Item as a
-- parameter.

PROCEDURE copy_item(
    p_item_reference_code       IN VARCHAR2 DEFAULT NULL
    ,p_new_citem_name		IN VARCHAR2
    ,p_directory_node_id        IN NUMBER
    ,p_language                 IN VARCHAR2 DEFAULT USERENV('LANG')
    ,p_commit                   IN VARCHAR2 DEFAULT Fnd_Api.g_false
    ,p_api_version_number       IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,p_init_msg_list            IN VARCHAR2 DEFAULT Fnd_Api.g_false
    ,px_content_item_id         IN OUT NOCOPY NUMBER
    ,px_citem_ver_id            IN OUT NOCOPY NUMBER
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
);

PROCEDURE copy_item(
    p_item_reference_code       IN VARCHAR2 DEFAULT NULL
    ,p_language                 IN VARCHAR2 DEFAULT USERENV('LANG')
    ,p_commit                   IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version_number       IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.g_false
    ,px_content_item_id         IN OUT NOCOPY NUMBER
    ,px_citem_ver_id            IN OUT NOCOPY NUMBER
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
);



-- --------------------------------------------------------------
-- COPY ITEM
--
-- --------------------------------------------------------------
PROCEDURE copy_item(
    p_item_reference_code       IN VARCHAR2 DEFAULT NULL
    ,p_directory_node_id        IN NUMBER
    ,p_language                 IN VARCHAR2 DEFAULT USERENV('LANG')
    ,p_commit                   IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version_number       IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.g_false
    ,px_content_item_id         IN OUT NOCOPY NUMBER
    ,px_citem_ver_id            IN OUT NOCOPY NUMBER
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
);




-- --------------------------------------------------------------
-- COPY VERSION
--
-- --------------------------------------------------------------
PROCEDURE copy_version(
    p_language                  IN VARCHAR2 DEFAULT USERENV('LANG')
    ,p_commit                   IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version_number       IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.g_false
    ,px_content_item_id         IN OUT NOCOPY NUMBER
    ,px_citem_ver_id            IN OUT NOCOPY NUMBER
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
);





-- --------------------------------------------------------------
-- DELETE COMPONENT ITEM
--
-- --------------------------------------------------------------
PROCEDURE delete_component(
    p_attribute_type_code       IN VARCHAR2
    ,p_citem_ver_id             IN NUMBER
    ,p_content_item_id          IN NUMBER
    ,p_commit                   IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version_number       IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.g_false
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
);













-- --------------------------------------------------------------
-- DELETE CONTENT ITEM ASSOCIATION
--
-- --------------------------------------------------------------
PROCEDURE delete_association(
    p_content_item_id           IN NUMBER
    ,p_association_type_code    IN VARCHAR2
    ,p_associated_object_val1   IN VARCHAR2
    ,p_associated_object_val2   IN VARCHAR2 DEFAULT NULL
    ,p_associated_object_val3   IN VARCHAR2 DEFAULT NULL
    ,p_associated_object_val4   IN VARCHAR2 DEFAULT NULL
    ,p_associated_object_val5   IN VARCHAR2 DEFAULT NULL
    ,p_commit                   IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version_number       IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.g_false
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
);













-- --------------------------------------------------------------
-- GET ATTRIBUTE BUNDLE
--
-- --------------------------------------------------------------
PROCEDURE get_attribute_bundle(
    p_citem_ver_id           IN NUMBER
    ,p_init_msg_list         IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version_number    IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,x_attribute_type_codes  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes            OUT NOCOPY JTF_VARCHAR2_TABLE_32767
    ,x_object_version_number OUT NOCOPY NUMBER
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
);

-- Overloaded for 4K limit support on attr values
PROCEDURE get_attribute_bundle(
    p_citem_ver_id           IN NUMBER
    ,p_init_msg_list         IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version_number    IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,x_attribute_type_codes  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes            OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    ,x_object_version_number OUT NOCOPY NUMBER
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
);



-- --------------------------------------------------------------
-- GET CONTENT ITEM (FOR UPDATE)
--
-- --------------------------------------------------------------
PROCEDURE get_item(
    p_citem_ver_id            IN NUMBER
    ,p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version_number     IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,x_content_item_id        OUT NOCOPY NUMBER
    ,x_citem_name             OUT NOCOPY VARCHAR2
    ,x_citem_version          OUT NOCOPY NUMBER
    ,x_dir_node_id            OUT NOCOPY NUMBER
    ,x_dir_node_name          OUT NOCOPY VARCHAR2
    ,x_dir_node_code          OUT NOCOPY VARCHAR2
    ,x_item_status            OUT NOCOPY VARCHAR2
    ,x_version_status         OUT NOCOPY VARCHAR2
    ,x_citem_description      OUT NOCOPY VARCHAR2
    ,x_ctype_code             OUT NOCOPY VARCHAR2
    ,x_ctype_name             OUT NOCOPY VARCHAR2
    ,x_start_date             OUT NOCOPY DATE
    ,x_end_date               OUT NOCOPY DATE
    ,x_owner_resource_id      OUT NOCOPY NUMBER
    ,x_owner_resource_type    OUT NOCOPY VARCHAR2
    ,x_reference_code         OUT NOCOPY VARCHAR2
    ,x_trans_required         OUT NOCOPY VARCHAR2
    ,x_parent_item_id         OUT NOCOPY NUMBER
    ,x_locked_by              OUT NOCOPY NUMBER
    ,x_wd_restricted          OUT NOCOPY VARCHAR2
    ,x_attach_file_ids        OUT NOCOPY JTF_NUMBER_TABLE
    ,x_attach_file_names      OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attach_mime_types      OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attach_mime_names      OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_default_rendition      OUT NOCOPY NUMBER
    ,x_object_version_number  OUT NOCOPY NUMBER
    ,x_created_by             OUT NOCOPY NUMBER
    ,x_creation_date          OUT NOCOPY DATE
    ,x_last_updated_by        OUT NOCOPY NUMBER
    ,x_last_update_date       OUT NOCOPY DATE
    ,x_attribute_type_codes   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes             OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    ,x_component_citems       OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_attrib_types OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_citem_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_component_owner_ids    OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_owner_types  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_sort_orders  OUT NOCOPY JTF_NUMBER_TABLE
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
);



-- --------------------------------------------------------------
-- GET CONTENT ITEM (FOR UPDATE)
--
-- --------------------------------------------------------------
PROCEDURE get_item(
    p_citem_ver_id            IN NUMBER
    ,p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version_number     IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,x_content_item_id        OUT NOCOPY NUMBER
    ,x_citem_name             OUT NOCOPY VARCHAR2
    ,x_citem_version          OUT NOCOPY NUMBER
    ,x_dir_node_id            OUT NOCOPY NUMBER
    ,x_dir_node_name          OUT NOCOPY VARCHAR2
    ,x_dir_node_code          OUT NOCOPY VARCHAR2
    ,x_item_status            OUT NOCOPY VARCHAR2
    ,x_version_status         OUT NOCOPY VARCHAR2
    ,x_citem_description      OUT NOCOPY VARCHAR2
    ,x_ctype_code             OUT NOCOPY VARCHAR2
    ,x_ctype_name             OUT NOCOPY VARCHAR2
    ,x_start_date             OUT NOCOPY DATE
    ,x_end_date               OUT NOCOPY DATE
    ,x_owner_resource_id      OUT NOCOPY NUMBER
    ,x_owner_resource_type    OUT NOCOPY VARCHAR2
    ,x_reference_code         OUT NOCOPY VARCHAR2
    ,x_trans_required         OUT NOCOPY VARCHAR2
    ,x_parent_item_id         OUT NOCOPY NUMBER
    ,x_locked_by              OUT NOCOPY NUMBER
    ,x_wd_restricted          OUT NOCOPY VARCHAR2
    ,x_attach_file_id         OUT NOCOPY NUMBER
    ,x_attach_file_name       OUT NOCOPY VARCHAR2
    ,x_object_version_number  OUT NOCOPY NUMBER
    ,x_created_by             OUT NOCOPY NUMBER
    ,x_creation_date          OUT NOCOPY DATE
    ,x_last_updated_by        OUT NOCOPY NUMBER
    ,x_last_update_date       OUT NOCOPY DATE
    ,x_attribute_type_codes   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes             OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    ,x_component_citems       OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_attrib_types OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_citem_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_component_owner_ids    OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_owner_types  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_sort_orders  OUT NOCOPY JTF_NUMBER_TABLE
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
);

--
--- get_item: Overloaded to include component item version id
PROCEDURE get_item(
    p_citem_ver_id            IN NUMBER
    ,p_init_msg_list          IN VARCHAR2
    ,p_api_version_number     IN NUMBER
    ,x_content_item_id        OUT NOCOPY NUMBER
    ,x_citem_name             OUT NOCOPY VARCHAR2
    ,x_citem_version          OUT NOCOPY NUMBER
    ,x_dir_node_id            OUT NOCOPY NUMBER
    ,x_dir_node_name          OUT NOCOPY VARCHAR2
    ,x_dir_node_code          OUT NOCOPY VARCHAR2
    ,x_item_status            OUT NOCOPY VARCHAR2
    ,x_version_status         OUT NOCOPY VARCHAR2
    ,x_citem_description      OUT NOCOPY VARCHAR2
    ,x_ctype_code             OUT NOCOPY VARCHAR2
    ,x_ctype_name             OUT NOCOPY VARCHAR2
    ,x_start_date             OUT NOCOPY DATE
    ,x_end_date               OUT NOCOPY DATE
    ,x_owner_resource_id      OUT NOCOPY NUMBER
    ,x_owner_resource_type    OUT NOCOPY VARCHAR2
    ,x_reference_code         OUT NOCOPY VARCHAR2
    ,x_trans_required         OUT NOCOPY VARCHAR2
    ,x_parent_item_id         OUT NOCOPY NUMBER
    ,x_locked_by              OUT NOCOPY NUMBER
    ,x_wd_restricted          OUT NOCOPY VARCHAR2
    ,x_attach_file_ids        OUT NOCOPY JTF_NUMBER_TABLE
    ,x_attach_file_names      OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attach_mime_types      OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attach_mime_names      OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_default_rendition      OUT NOCOPY NUMBER
    ,x_object_version_number  OUT NOCOPY NUMBER
    ,x_created_by             OUT NOCOPY NUMBER
    ,x_creation_date          OUT NOCOPY DATE
    ,x_last_updated_by        OUT NOCOPY NUMBER
    ,x_last_update_date       OUT NOCOPY DATE
    ,x_attribute_type_codes   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes             OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    ,x_component_citems       OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_citem_ver_ids OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_attrib_types OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_citem_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_component_owner_ids    OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_owner_types  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_sort_orders  OUT NOCOPY JTF_NUMBER_TABLE
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
);


--
--- get_item: Overloaded to include keywords
PROCEDURE get_item(
    p_citem_ver_id            IN NUMBER
    ,p_init_msg_list          IN VARCHAR2
    ,p_api_version_number     IN NUMBER
    ,x_content_item_id        OUT NOCOPY NUMBER
    ,x_citem_name             OUT NOCOPY VARCHAR2
    ,x_citem_version          OUT NOCOPY NUMBER
    ,x_dir_node_id            OUT NOCOPY NUMBER
    ,x_dir_node_name          OUT NOCOPY VARCHAR2
    ,x_dir_node_code          OUT NOCOPY VARCHAR2
    ,x_item_status            OUT NOCOPY VARCHAR2
    ,x_version_status         OUT NOCOPY VARCHAR2
    ,x_citem_description      OUT NOCOPY VARCHAR2
    ,x_ctype_code             OUT NOCOPY VARCHAR2
    ,x_ctype_name             OUT NOCOPY VARCHAR2
    ,x_start_date             OUT NOCOPY DATE
    ,x_end_date               OUT NOCOPY DATE
    ,x_owner_resource_id      OUT NOCOPY NUMBER
    ,x_owner_resource_type    OUT NOCOPY VARCHAR2
    ,x_reference_code         OUT NOCOPY VARCHAR2
    ,x_trans_required         OUT NOCOPY VARCHAR2
    ,x_parent_item_id         OUT NOCOPY NUMBER
    ,x_locked_by              OUT NOCOPY NUMBER
    ,x_wd_restricted          OUT NOCOPY VARCHAR2
    ,x_attach_file_ids        OUT NOCOPY JTF_NUMBER_TABLE
    ,x_attach_file_names      OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attach_mime_types      OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attach_mime_names      OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_default_rendition      OUT NOCOPY NUMBER
    ,x_object_version_number  OUT NOCOPY NUMBER
    ,x_created_by             OUT NOCOPY NUMBER
    ,x_creation_date          OUT NOCOPY DATE
    ,x_last_updated_by        OUT NOCOPY NUMBER
    ,x_last_update_date       OUT NOCOPY DATE
    ,x_attribute_type_codes   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes             OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    ,x_component_citems       OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_citem_ver_ids OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_attrib_types OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_citem_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_component_owner_ids    OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_owner_types  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_sort_orders  OUT NOCOPY JTF_NUMBER_TABLE
    ,x_keywords               OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
);


--
--- get_item: Overloaded for new renditions usage
PROCEDURE get_item(
    p_citem_ver_id            IN NUMBER
    ,p_init_msg_list          IN VARCHAR2
    ,p_api_version_number     IN NUMBER
    ,x_content_item_id        OUT NOCOPY NUMBER
    ,x_citem_name             OUT NOCOPY VARCHAR2
    ,x_citem_version          OUT NOCOPY NUMBER
    ,x_dir_node_id            OUT NOCOPY NUMBER
    ,x_dir_node_name          OUT NOCOPY VARCHAR2
    ,x_dir_node_code          OUT NOCOPY VARCHAR2
    ,x_item_status            OUT NOCOPY VARCHAR2
    ,x_version_status         OUT NOCOPY VARCHAR2
    ,x_citem_description      OUT NOCOPY VARCHAR2
    ,x_ctype_code             OUT NOCOPY VARCHAR2
    ,x_ctype_name             OUT NOCOPY VARCHAR2
    ,x_start_date             OUT NOCOPY DATE
    ,x_end_date               OUT NOCOPY DATE
    ,x_owner_resource_id      OUT NOCOPY NUMBER
    ,x_owner_resource_type    OUT NOCOPY VARCHAR2
    ,x_reference_code         OUT NOCOPY VARCHAR2
    ,x_trans_required         OUT NOCOPY VARCHAR2
    ,x_parent_item_id         OUT NOCOPY NUMBER
    ,x_locked_by              OUT NOCOPY NUMBER
    ,x_wd_restricted          OUT NOCOPY VARCHAR2
    ,x_attach_file_id         OUT NOCOPY NUMBER
    ,x_attach_file_name       OUT NOCOPY VARCHAR2
    ,x_attach_mime_type       OUT NOCOPY VARCHAR2
    ,x_attach_mime_name       OUT NOCOPY VARCHAR2
    ,x_rendition_file_ids     OUT NOCOPY JTF_NUMBER_TABLE
    ,x_rendition_file_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_rendition_mime_types   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_rendition_mime_names   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_default_rendition      OUT NOCOPY NUMBER
    ,x_object_version_number  OUT NOCOPY NUMBER
    ,x_created_by             OUT NOCOPY NUMBER
    ,x_creation_date          OUT NOCOPY DATE
    ,x_last_updated_by        OUT NOCOPY NUMBER
    ,x_last_update_date       OUT NOCOPY DATE
    ,x_attribute_type_codes   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes             OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    ,x_component_citems       OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_citem_ver_ids OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_attrib_types OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_citem_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_component_owner_ids    OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_owner_types  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_sort_orders  OUT NOCOPY JTF_NUMBER_TABLE
    ,x_keywords               OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
);

-- Overloaded to add support for 32K attr values

PROCEDURE get_item(
    p_citem_ver_id            IN NUMBER
    ,p_init_msg_list          IN VARCHAR2
    ,p_api_version_number     IN NUMBER
    ,x_content_item_id        OUT NOCOPY NUMBER
    ,x_citem_name             OUT NOCOPY VARCHAR2
    ,x_citem_version          OUT NOCOPY NUMBER
    ,x_dir_node_id            OUT NOCOPY NUMBER
    ,x_dir_node_name          OUT NOCOPY VARCHAR2
    ,x_dir_node_code          OUT NOCOPY VARCHAR2
    ,x_item_status            OUT NOCOPY VARCHAR2
    ,x_version_status         OUT NOCOPY VARCHAR2
    ,x_citem_description      OUT NOCOPY VARCHAR2
    ,x_ctype_code             OUT NOCOPY VARCHAR2
    ,x_ctype_name             OUT NOCOPY VARCHAR2
    ,x_start_date             OUT NOCOPY DATE
    ,x_end_date               OUT NOCOPY DATE
    ,x_owner_resource_id      OUT NOCOPY NUMBER
    ,x_owner_resource_type    OUT NOCOPY VARCHAR2
    ,x_reference_code         OUT NOCOPY VARCHAR2
    ,x_trans_required         OUT NOCOPY VARCHAR2
    ,x_parent_item_id         OUT NOCOPY NUMBER
    ,x_locked_by              OUT NOCOPY NUMBER
    ,x_wd_restricted          OUT NOCOPY VARCHAR2
    ,x_attach_file_id         OUT NOCOPY NUMBER
    ,x_attach_file_name       OUT NOCOPY VARCHAR2
    ,x_attach_mime_type       OUT NOCOPY VARCHAR2
    ,x_attach_mime_name       OUT NOCOPY VARCHAR2
    ,x_rendition_file_ids     OUT NOCOPY JTF_NUMBER_TABLE
    ,x_rendition_file_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_rendition_mime_types   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_rendition_mime_names   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_default_rendition      OUT NOCOPY NUMBER
    ,x_object_version_number  OUT NOCOPY NUMBER
    ,x_created_by             OUT NOCOPY NUMBER
    ,x_creation_date          OUT NOCOPY DATE
    ,x_last_updated_by        OUT NOCOPY NUMBER
    ,x_last_update_date       OUT NOCOPY DATE
    ,x_attribute_type_codes   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes             OUT NOCOPY JTF_VARCHAR2_TABLE_32767
    ,x_component_citems       OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_citem_ver_ids OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_attrib_types OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_citem_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_component_owner_ids    OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_owner_types  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_sort_orders  OUT NOCOPY JTF_NUMBER_TABLE
    ,x_keywords               OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
);


-- --------------------------------------------------------------
-- GET TRANSLATED CONTENT ITEM (FOR UPDATE)
--
-- --------------------------------------------------------------
PROCEDURE get_trans_item(
    p_citem_ver_id            IN NUMBER
    ,p_language               IN VARCHAR2
    ,p_skip_security          IN VARCHAR2
    ,p_init_msg_list          IN VARCHAR2
    ,p_api_version_number     IN NUMBER
    ,x_content_item_id        OUT NOCOPY NUMBER
    ,x_citem_name             OUT NOCOPY VARCHAR2
    ,x_citem_version          OUT NOCOPY NUMBER
    ,x_dir_node_id            OUT NOCOPY NUMBER
    ,x_dir_node_name          OUT NOCOPY VARCHAR2
    ,x_dir_node_code          OUT NOCOPY VARCHAR2
    ,x_item_status            OUT NOCOPY VARCHAR2
    ,x_version_status         OUT NOCOPY VARCHAR2
    ,x_citem_description      OUT NOCOPY VARCHAR2
    ,x_ctype_code             OUT NOCOPY VARCHAR2
    ,x_ctype_name             OUT NOCOPY VARCHAR2
    ,x_start_date             OUT NOCOPY DATE
    ,x_end_date               OUT NOCOPY DATE
    ,x_owner_resource_id      OUT NOCOPY NUMBER
    ,x_owner_resource_type    OUT NOCOPY VARCHAR2
    ,x_reference_code         OUT NOCOPY VARCHAR2
    ,x_trans_required         OUT NOCOPY VARCHAR2
    ,x_parent_item_id         OUT NOCOPY NUMBER
    ,x_locked_by              OUT NOCOPY NUMBER
    ,x_wd_restricted          OUT NOCOPY VARCHAR2
    ,x_attach_file_id         OUT NOCOPY NUMBER
    ,x_attach_file_name       OUT NOCOPY VARCHAR2
    ,x_attach_mime_type       OUT NOCOPY VARCHAR2
    ,x_attach_mime_name       OUT NOCOPY VARCHAR2
    ,x_rendition_file_ids     OUT NOCOPY JTF_NUMBER_TABLE
    ,x_rendition_file_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_rendition_mime_types   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_rendition_mime_names   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_default_rendition      OUT NOCOPY NUMBER
    ,x_object_version_number  OUT NOCOPY NUMBER
    ,x_created_by             OUT NOCOPY NUMBER
    ,x_creation_date          OUT NOCOPY DATE
    ,x_last_updated_by        OUT NOCOPY NUMBER
    ,x_last_update_date       OUT NOCOPY DATE
    ,x_attribute_type_codes   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes             OUT NOCOPY JTF_VARCHAR2_TABLE_32767
    ,x_component_citems       OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_citem_ver_ids OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_attrib_types OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_citem_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_component_owner_ids    OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_owner_types  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_sort_orders  OUT NOCOPY JTF_NUMBER_TABLE
    ,x_keywords               OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
);

-- --------------------------------------------------------------
-- GET TRANSLATED CONTENT ITEM (FOR UPDATE)
--
-- --------------------------------------------------------------
PROCEDURE get_trans_item(
    p_citem_ver_id            IN NUMBER
    ,p_language               IN VARCHAR2 DEFAULT USERENV('LANG')
    ,p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version_number     IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,x_content_item_id        OUT NOCOPY NUMBER
    ,x_citem_name             OUT NOCOPY VARCHAR2
    ,x_citem_version          OUT NOCOPY NUMBER
    ,x_dir_node_id            OUT NOCOPY NUMBER
    ,x_dir_node_name          OUT NOCOPY VARCHAR2
    ,x_dir_node_code          OUT NOCOPY VARCHAR2
    ,x_item_status            OUT NOCOPY VARCHAR2
    ,x_version_status         OUT NOCOPY VARCHAR2
    ,x_citem_description      OUT NOCOPY VARCHAR2
    ,x_ctype_code             OUT NOCOPY VARCHAR2
    ,x_ctype_name             OUT NOCOPY VARCHAR2
    ,x_start_date             OUT NOCOPY DATE
    ,x_end_date               OUT NOCOPY DATE
    ,x_owner_resource_id      OUT NOCOPY NUMBER
    ,x_owner_resource_type    OUT NOCOPY VARCHAR2
    ,x_reference_code         OUT NOCOPY VARCHAR2
    ,x_trans_required         OUT NOCOPY VARCHAR2
    ,x_parent_item_id         OUT NOCOPY NUMBER
    ,x_locked_by              OUT NOCOPY NUMBER
    ,x_wd_restricted          OUT NOCOPY VARCHAR2
    ,x_attach_file_id         OUT NOCOPY NUMBER
    ,x_attach_file_name       OUT NOCOPY VARCHAR2
    ,x_object_version_number  OUT NOCOPY NUMBER
    ,x_created_by             OUT NOCOPY NUMBER
    ,x_creation_date          OUT NOCOPY DATE
    ,x_last_updated_by        OUT NOCOPY NUMBER
    ,x_last_update_date       OUT NOCOPY DATE
    ,x_attribute_type_codes   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes             OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    ,x_component_citems       OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_attrib_types OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_citem_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_component_owner_ids    OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_owner_types  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_sort_orders  OUT NOCOPY JTF_NUMBER_TABLE
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
);

-- --------------------------------------------------------------
-- GET TRANSLATED CONTENT ITEM (FOR UPDATE)
--
-- Used to get info to display on update page
--
-- --------------------------------------------------------------
PROCEDURE get_trans_item(
    p_citem_ver_id            IN NUMBER
    ,p_language               IN VARCHAR2 DEFAULT USERENV('LANG')
    ,p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version_number     IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,x_content_item_id        OUT NOCOPY NUMBER
    ,x_citem_name             OUT NOCOPY VARCHAR2
    ,x_citem_version          OUT NOCOPY NUMBER
    ,x_dir_node_id            OUT NOCOPY NUMBER
    ,x_dir_node_name          OUT NOCOPY VARCHAR2
    ,x_dir_node_code          OUT NOCOPY VARCHAR2
    ,x_item_status            OUT NOCOPY VARCHAR2
    ,x_version_status         OUT NOCOPY VARCHAR2
    ,x_citem_description      OUT NOCOPY VARCHAR2
    ,x_ctype_code             OUT NOCOPY VARCHAR2
    ,x_ctype_name             OUT NOCOPY VARCHAR2
    ,x_start_date             OUT NOCOPY DATE
    ,x_end_date               OUT NOCOPY DATE
    ,x_owner_resource_id      OUT NOCOPY NUMBER
    ,x_owner_resource_type    OUT NOCOPY VARCHAR2
    ,x_reference_code         OUT NOCOPY VARCHAR2
    ,x_trans_required         OUT NOCOPY VARCHAR2
    ,x_parent_item_id         OUT NOCOPY NUMBER
    ,x_locked_by              OUT NOCOPY NUMBER
    ,x_wd_restricted          OUT NOCOPY VARCHAR2
    ,x_attach_file_ids        OUT NOCOPY JTF_NUMBER_TABLE
    ,x_attach_file_names      OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attach_mime_types      OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attach_mime_names      OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_default_rendition      OUT NOCOPY NUMBER
    ,x_object_version_number  OUT NOCOPY NUMBER
    ,x_created_by             OUT NOCOPY NUMBER
    ,x_creation_date          OUT NOCOPY DATE
    ,x_last_updated_by        OUT NOCOPY NUMBER
    ,x_last_update_date       OUT NOCOPY DATE
    ,x_attribute_type_codes   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes             OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    ,x_component_citems       OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_attrib_types OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_citem_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_component_owner_ids    OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_owner_types  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_sort_orders  OUT NOCOPY JTF_NUMBER_TABLE
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
);

-- --------------------------------------------------------------
-- GET TRANSLATED CONTENT ITEM (FOR UPDATE)
--
-- Used to get info to display on update page
-- Overloaded to include component item version ids
--
-- --------------------------------------------------------------
PROCEDURE get_trans_item(
    p_citem_ver_id            IN NUMBER
    ,p_language               IN VARCHAR2
    ,p_init_msg_list          IN VARCHAR2
    ,p_api_version_number     IN NUMBER
    ,x_content_item_id        OUT NOCOPY NUMBER
    ,x_citem_name             OUT NOCOPY VARCHAR2
    ,x_citem_version          OUT NOCOPY NUMBER
    ,x_dir_node_id            OUT NOCOPY NUMBER
    ,x_dir_node_name          OUT NOCOPY VARCHAR2
    ,x_dir_node_code          OUT NOCOPY VARCHAR2
    ,x_item_status            OUT NOCOPY VARCHAR2
    ,x_version_status         OUT NOCOPY VARCHAR2
    ,x_citem_description      OUT NOCOPY VARCHAR2
    ,x_ctype_code             OUT NOCOPY VARCHAR2
    ,x_ctype_name             OUT NOCOPY VARCHAR2
    ,x_start_date             OUT NOCOPY DATE
    ,x_end_date               OUT NOCOPY DATE
    ,x_owner_resource_id      OUT NOCOPY NUMBER
    ,x_owner_resource_type    OUT NOCOPY VARCHAR2
    ,x_reference_code         OUT NOCOPY VARCHAR2
    ,x_trans_required         OUT NOCOPY VARCHAR2
    ,x_parent_item_id         OUT NOCOPY NUMBER
    ,x_locked_by              OUT NOCOPY NUMBER
    ,x_wd_restricted          OUT NOCOPY VARCHAR2
    ,x_attach_file_ids        OUT NOCOPY JTF_NUMBER_TABLE
    ,x_attach_file_names      OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attach_mime_types      OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attach_mime_names      OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_default_rendition      OUT NOCOPY NUMBER
    ,x_object_version_number  OUT NOCOPY NUMBER
    ,x_created_by             OUT NOCOPY NUMBER
    ,x_creation_date          OUT NOCOPY DATE
    ,x_last_updated_by        OUT NOCOPY NUMBER
    ,x_last_update_date       OUT NOCOPY DATE
    ,x_attribute_type_codes   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes             OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    ,x_component_citems       OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_citem_ver_ids OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_attrib_types OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_citem_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_component_owner_ids    OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_owner_types  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_sort_orders  OUT NOCOPY JTF_NUMBER_TABLE
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
);

-- --------------------------------------------------------------
-- GET TRANSLATED CONTENT ITEM (FOR UPDATE)
--
-- Used to get info to display on update page
-- Overloaded to include component item version ids
--
-- --------------------------------------------------------------
PROCEDURE get_trans_item(
    p_citem_ver_id            IN NUMBER
    ,p_language               IN VARCHAR2
    ,p_init_msg_list          IN VARCHAR2
    ,p_api_version_number     IN NUMBER
    ,x_content_item_id        OUT NOCOPY NUMBER
    ,x_citem_name             OUT NOCOPY VARCHAR2
    ,x_citem_version          OUT NOCOPY NUMBER
    ,x_dir_node_id            OUT NOCOPY NUMBER
    ,x_dir_node_name          OUT NOCOPY VARCHAR2
    ,x_dir_node_code          OUT NOCOPY VARCHAR2
    ,x_item_status            OUT NOCOPY VARCHAR2
    ,x_version_status         OUT NOCOPY VARCHAR2
    ,x_citem_description      OUT NOCOPY VARCHAR2
    ,x_ctype_code             OUT NOCOPY VARCHAR2
    ,x_ctype_name             OUT NOCOPY VARCHAR2
    ,x_start_date             OUT NOCOPY DATE
    ,x_end_date               OUT NOCOPY DATE
    ,x_owner_resource_id      OUT NOCOPY NUMBER
    ,x_owner_resource_type    OUT NOCOPY VARCHAR2
    ,x_reference_code         OUT NOCOPY VARCHAR2
    ,x_trans_required         OUT NOCOPY VARCHAR2
    ,x_parent_item_id         OUT NOCOPY NUMBER
    ,x_locked_by              OUT NOCOPY NUMBER
    ,x_wd_restricted          OUT NOCOPY VARCHAR2
    ,x_attach_file_ids        OUT NOCOPY JTF_NUMBER_TABLE
    ,x_attach_file_names      OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attach_mime_types      OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attach_mime_names      OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_default_rendition      OUT NOCOPY NUMBER
    ,x_object_version_number  OUT NOCOPY NUMBER
    ,x_created_by             OUT NOCOPY NUMBER
    ,x_creation_date          OUT NOCOPY DATE
    ,x_last_updated_by        OUT NOCOPY NUMBER
    ,x_last_update_date       OUT NOCOPY DATE
    ,x_attribute_type_codes   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes             OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    ,x_component_citems       OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_citem_ver_ids OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_attrib_types OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_citem_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_component_owner_ids    OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_owner_types  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_sort_orders  OUT NOCOPY JTF_NUMBER_TABLE
    ,x_keywords               OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
);

-- --------------------------------------------------------------
-- GET TRANSLATED CONTENT ITEM (FOR UPDATE)
--
-- --------------------------------------------------------------
PROCEDURE get_trans_item(
    p_citem_ver_id            IN NUMBER
    ,p_language               IN VARCHAR2
    ,p_init_msg_list          IN VARCHAR2
    ,p_api_version_number     IN NUMBER
    ,x_content_item_id        OUT NOCOPY NUMBER
    ,x_citem_name             OUT NOCOPY VARCHAR2
    ,x_citem_version          OUT NOCOPY NUMBER
    ,x_dir_node_id            OUT NOCOPY NUMBER
    ,x_dir_node_name          OUT NOCOPY VARCHAR2
    ,x_dir_node_code          OUT NOCOPY VARCHAR2
    ,x_item_status            OUT NOCOPY VARCHAR2
    ,x_version_status         OUT NOCOPY VARCHAR2
    ,x_citem_description      OUT NOCOPY VARCHAR2
    ,x_ctype_code             OUT NOCOPY VARCHAR2
    ,x_ctype_name             OUT NOCOPY VARCHAR2
    ,x_start_date             OUT NOCOPY DATE
    ,x_end_date               OUT NOCOPY DATE
    ,x_owner_resource_id      OUT NOCOPY NUMBER
    ,x_owner_resource_type    OUT NOCOPY VARCHAR2
    ,x_reference_code         OUT NOCOPY VARCHAR2
    ,x_trans_required         OUT NOCOPY VARCHAR2
    ,x_parent_item_id         OUT NOCOPY NUMBER
    ,x_locked_by              OUT NOCOPY NUMBER
    ,x_wd_restricted          OUT NOCOPY VARCHAR2
    ,x_attach_file_id         OUT NOCOPY NUMBER
    ,x_attach_file_name       OUT NOCOPY VARCHAR2
    ,x_attach_mime_type       OUT NOCOPY VARCHAR2
    ,x_attach_mime_name       OUT NOCOPY VARCHAR2
    ,x_rendition_file_ids     OUT NOCOPY JTF_NUMBER_TABLE
    ,x_rendition_file_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_rendition_mime_types   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_rendition_mime_names   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_default_rendition      OUT NOCOPY NUMBER
    ,x_object_version_number  OUT NOCOPY NUMBER
    ,x_created_by             OUT NOCOPY NUMBER
    ,x_creation_date          OUT NOCOPY DATE
    ,x_last_updated_by        OUT NOCOPY NUMBER
    ,x_last_update_date       OUT NOCOPY DATE
    ,x_attribute_type_codes   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes             OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    ,x_component_citems       OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_citem_ver_ids OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_attrib_types OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_citem_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_component_owner_ids    OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_owner_types  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_sort_orders  OUT NOCOPY JTF_NUMBER_TABLE
    ,x_keywords               OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
);

-- --------------------------------------------------------------
-- GET TRANSLATED CONTENT ITEM (FOR UPDATE)
--  Added support for attr values with upto 32K
-- --------------------------------------------------------------
PROCEDURE get_trans_item(
    p_citem_ver_id            IN NUMBER
    ,p_language               IN VARCHAR2
    ,p_init_msg_list          IN VARCHAR2
    ,p_api_version_number     IN NUMBER
    ,x_content_item_id        OUT NOCOPY NUMBER
    ,x_citem_name             OUT NOCOPY VARCHAR2
    ,x_citem_version          OUT NOCOPY NUMBER
    ,x_dir_node_id            OUT NOCOPY NUMBER
    ,x_dir_node_name          OUT NOCOPY VARCHAR2
    ,x_dir_node_code          OUT NOCOPY VARCHAR2
    ,x_item_status            OUT NOCOPY VARCHAR2
    ,x_version_status         OUT NOCOPY VARCHAR2
    ,x_citem_description      OUT NOCOPY VARCHAR2
    ,x_ctype_code             OUT NOCOPY VARCHAR2
    ,x_ctype_name             OUT NOCOPY VARCHAR2
    ,x_start_date             OUT NOCOPY DATE
    ,x_end_date               OUT NOCOPY DATE
    ,x_owner_resource_id      OUT NOCOPY NUMBER
    ,x_owner_resource_type    OUT NOCOPY VARCHAR2
    ,x_reference_code         OUT NOCOPY VARCHAR2
    ,x_trans_required         OUT NOCOPY VARCHAR2
    ,x_parent_item_id         OUT NOCOPY NUMBER
    ,x_locked_by              OUT NOCOPY NUMBER
    ,x_wd_restricted          OUT NOCOPY VARCHAR2
    ,x_attach_file_id         OUT NOCOPY NUMBER
    ,x_attach_file_name       OUT NOCOPY VARCHAR2
    ,x_attach_mime_type       OUT NOCOPY VARCHAR2
    ,x_attach_mime_name       OUT NOCOPY VARCHAR2
    ,x_rendition_file_ids     OUT NOCOPY JTF_NUMBER_TABLE
    ,x_rendition_file_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_rendition_mime_types   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_rendition_mime_names   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_default_rendition      OUT NOCOPY NUMBER
    ,x_object_version_number  OUT NOCOPY NUMBER
    ,x_created_by             OUT NOCOPY NUMBER
    ,x_creation_date          OUT NOCOPY DATE
    ,x_last_updated_by        OUT NOCOPY NUMBER
    ,x_last_update_date       OUT NOCOPY DATE
    ,x_attribute_type_codes   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_attribute_type_names   OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_attributes             OUT NOCOPY JTF_VARCHAR2_TABLE_32767
    ,x_component_citems       OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_citem_ver_ids OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_attrib_types OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_citem_names  OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_component_owner_ids    OUT NOCOPY JTF_NUMBER_TABLE
    ,x_component_owner_types  OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_component_sort_orders  OUT NOCOPY JTF_NUMBER_TABLE
    ,x_keywords               OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
);

-- --------------------------------------------------------------
-- HARD DELETE ITEM VERSION
--
-- --------------------------------------------------------------
PROCEDURE hard_delete_item_versions(
	p_api_version           IN NUMBER,
   p_init_msg_list			IN VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit			         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_citem_version_ids		IN	JTF_NUMBER_TABLE,
	x_return_status		 OUT NOCOPY VARCHAR2,
   x_msg_count			      OUT NOCOPY NUMBER,
   x_msg_data			      OUT NOCOPY VARCHAR2
);










-- --------------------------------------------------------------
-- HARD DELETE ITEMS
--
-- --------------------------------------------------------------
PROCEDURE hard_delete_items (
	p_api_version        IN NUMBER,
   p_init_msg_list	   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit			      IN VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_content_item_ids	IN	JTF_NUMBER_TABLE,
	x_return_status	 OUT NOCOPY VARCHAR2,
   x_msg_count			   OUT NOCOPY NUMBER,
   x_msg_data			   OUT NOCOPY VARCHAR2
);









-- --------------------------------------------------------------
-- INSERT COMPONENT ITEMS
--
-- --------------------------------------------------------------
PROCEDURE insert_components(
    p_citem_ver_id              IN NUMBER
    ,p_content_item_ids         IN JTF_NUMBER_TABLE
    ,p_citem_ver_ids            IN JTF_NUMBER_TABLE
    ,p_attribute_type_codes     IN JTF_VARCHAR2_TABLE_100
    ,p_sort_order               IN JTF_NUMBER_TABLE DEFAULT NULL
    ,p_commit                   IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version_number       IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.g_false
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
);

-- --------------------------------------------------------------
-- INSERT COMPONENT ITEMS
-- Overloaded with no subitem ver_ids
-- --------------------------------------------------------------
PROCEDURE insert_components(
    p_citem_ver_id              IN NUMBER
    ,p_content_item_ids         IN JTF_NUMBER_TABLE
    ,p_attribute_type_codes     IN JTF_VARCHAR2_TABLE_100
    ,p_sort_order               IN JTF_NUMBER_TABLE DEFAULT NULL
    ,p_commit                   IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version_number       IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.g_false
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
);










-- --------------------------------------------------------------
-- INSERT CONTENT ITEM (ASSOCIATIONS)
--
-- --------------------------------------------------------------
PROCEDURE insert_associations(
    p_content_item_id           IN NUMBER
    ,p_assoc_type_codes         IN JTF_VARCHAR2_TABLE_100
    ,p_assoc_objects1           IN JTF_VARCHAR2_TABLE_300
    ,p_assoc_objects2           IN JTF_VARCHAR2_TABLE_300 DEFAULT NULL
    ,p_assoc_objects3           IN JTF_VARCHAR2_TABLE_300 DEFAULT NULL
    ,p_assoc_objects4           IN JTF_VARCHAR2_TABLE_300 DEFAULT NULL
    ,p_assoc_objects5           IN JTF_VARCHAR2_TABLE_300 DEFAULT NULL
    ,p_commit                   IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version_number       IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.g_false
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
);

PROCEDURE insert_associations(
    p_content_item_id           IN NUMBER
    ,p_citem_version_id         IN NUMBER
    ,p_assoc_type_codes         IN JTF_VARCHAR2_TABLE_100
    ,p_assoc_objects1           IN JTF_VARCHAR2_TABLE_300
    ,p_assoc_objects2           IN JTF_VARCHAR2_TABLE_300 DEFAULT NULL
    ,p_assoc_objects3           IN JTF_VARCHAR2_TABLE_300 DEFAULT NULL
    ,p_assoc_objects4           IN JTF_VARCHAR2_TABLE_300 DEFAULT NULL
    ,p_assoc_objects5           IN JTF_VARCHAR2_TABLE_300 DEFAULT NULL
    ,p_commit                   IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version_number       IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.g_false
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
);




-- --------------------------------------------------------------
-- INSERT CONTENT ITEM (MINIMUM)
--
-- --------------------------------------------------------------
PROCEDURE insert_minimum_item(
    p_ctype_code              IN VARCHAR2
    ,p_citem_name             IN VARCHAR2
    ,p_citem_description      IN VARCHAR2 DEFAULT NULL
    ,p_lock_flag              IN VARCHAR2 DEFAULT FND_API.g_true
    ,p_dir_node_id            IN NUMBER DEFAULT IBC_UTILITIES_PUB.G_COMMON_DIR_NODE
    ,p_commit                 IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version_number     IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.g_false
    ,px_content_item_id       IN OUT NOCOPY NUMBER
    ,px_object_version_number IN OUT NOCOPY NUMBER
    ,x_citem_ver_id           OUT NOCOPY NUMBER
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
);











-- --------------------------------------------------------------
-- LOCK CONTENT ITEM
--
-- --------------------------------------------------------------

PROCEDURE lock_item(
    p_content_item_id           IN NUMBER
    ,p_commit                   IN VARCHAR2 DEFAULT FND_API.g_true
    ,p_api_version_number       IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.g_false
    ,x_citem_version_id         OUT NOCOPY NUMBER
    ,x_object_version_number    OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
);







-- --------------------------------------------------------------
-- PRE VALIDATE ITEM
--
-- --------------------------------------------------------------
PROCEDURE pre_validate_item(
    p_citem_ver_id              IN NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
);





-- --------------------------------------------------------------
-- SET CONTENT ITEM (ATTRIBUTE BUNDLE)
--
-- --------------------------------------------------------------

PROCEDURE set_attribute_bundle(
    p_citem_ver_id              IN NUMBER
    ,p_attribute_type_codes     IN JTF_VARCHAR2_TABLE_100
    ,p_attributes               IN JTF_VARCHAR2_TABLE_4000
    ,p_remove_old               IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_commit                   IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version_number       IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.g_false
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
);

-- Overloaded: added support for 32K attr values
PROCEDURE set_attribute_bundle(
    p_citem_ver_id              IN NUMBER
    ,p_attribute_type_codes     IN JTF_VARCHAR2_TABLE_100
    ,p_attributes               IN JTF_VARCHAR2_TABLE_32767
    ,p_remove_old               IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_commit                   IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version_number       IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.g_false
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
);








-- --------------------------------------------------------------
-- SET CONTENT ITEM (ATTACHMENTS)
--
-- --------------------------------------------------------------

PROCEDURE set_attachment(
    p_citem_ver_id              IN NUMBER
    ,p_attach_file_id           IN NUMBER
    ,p_language                 IN VARCHAR2 DEFAULT USERENV('LANG')
    ,p_commit                   IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version_number       IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.g_false
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
);














-- --------------------------------------------------------------
-- SET CONTENT ITEM (META)
--
-- --------------------------------------------------------------
PROCEDURE set_citem_meta(
    p_content_item_id           IN NUMBER
    ,p_dir_node_id              IN NUMBER DEFAULT Ibc_Utilities_Pub.G_COMMON_DIR_NODE
    ,p_trans_required           IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_owner_resource_id        IN NUMBER DEFAULT NULL
    ,p_owner_resource_type      IN VARCHAR2 DEFAULT NULL
    ,p_parent_item_id           IN NUMBER DEFAULT NULL
    ,p_wd_restricted            IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_commit                   IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version_number       IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
);






-- --------------------------------------------------------------
-- SET LIVE VERSION
--
-- Set Live Version
--
-- --------------------------------------------------------------
PROCEDURE Set_Live_Version(
    p_content_item_id           IN NUMBER
    ,p_citem_ver_id             IN NUMBER
    ,p_commit                   IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version_number       IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.g_false
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
);





-- --------------------------------------------------------------
-- SET CONTENT ITEM VERSION(META)
--
-- --------------------------------------------------------------
PROCEDURE set_version_meta(
    p_citem_ver_id              IN NUMBER
    ,p_citem_name               IN VARCHAR2 DEFAULT NULL
    ,p_citem_description        IN VARCHAR2 DEFAULT NULL
    ,p_start_date               IN DATE DEFAULT NULL
    ,p_end_date                 IN DATE DEFAULT NULL
    ,p_commit                   IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version_number       IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
  );











-- --------------------------------------------------------------
-- UNARCHIVE ITEM
--
-- --------------------------------------------------------------
PROCEDURE unarchive_item(
    p_content_item_id           IN NUMBER
    ,p_commit                   IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version_number       IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.g_false
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
);











-- --------------------------------------------------------------
-- UNLOCK CONTENT ITEM
--
-- --------------------------------------------------------------

PROCEDURE unlock_item(
    p_content_item_id           IN NUMBER
    ,p_commit                   IN VARCHAR2 DEFAULT FND_API.g_true
    ,p_api_version_number       IN NUMBER DEFAULT G_API_VERSION_DEFAULT
    ,p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.g_false
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
);






-- --------------------------------------------------------------
-- UPSERT ITEM
-- no renditions
-- --------------------------------------------------------------
PROCEDURE upsert_item(
	    p_ctype_code                IN VARCHAR2
       ,p_citem_name                IN VARCHAR2
       ,p_citem_description         IN VARCHAR2
       ,p_dir_node_id               IN NUMBER DEFAULT IBC_UTILITIES_PUB.G_COMMON_DIR_NODE
       ,p_owner_resource_id         IN NUMBER DEFAULT NULL
       ,p_owner_resource_type       IN VARCHAR2 DEFAULT NULL
       ,p_reference_code            IN VARCHAR2 DEFAULT NULL
       ,p_trans_required            IN VARCHAR2 DEFAULT FND_API.g_false
       ,p_parent_item_id            IN NUMBER DEFAULT NULL
       ,p_lock_flag                 IN VARCHAR2 DEFAULT FND_API.g_true
       ,p_wd_restricted             IN VARCHAR2 DEFAULT FND_API.g_true
       ,p_start_date                IN DATE DEFAULT NULL
       ,p_end_date                  IN DATE DEFAULT NULL
       ,p_attribute_type_codes      IN JTF_VARCHAR2_TABLE_100 DEFAULT NULL
       ,p_attributes                IN JTF_VARCHAR2_TABLE_4000 DEFAULT NULL
       ,p_attach_file_id            IN NUMBER DEFAULT NULL
       ,p_component_citems          IN JTF_NUMBER_TABLE DEFAULT NULL
       ,p_component_atypes          IN JTF_VARCHAR2_TABLE_100 DEFAULT NULL
       ,p_sort_order                IN JTF_NUMBER_TABLE DEFAULT NULL
       ,p_status                    IN VARCHAR2 DEFAULT IBC_UTILITIES_PUB.G_STV_WORK_IN_PROGRESS
       ,p_log_action                IN VARCHAR2 DEFAULT FND_API.g_true
       ,p_language                  IN VARCHAR2 DEFAULT USERENV('LANG')
       ,p_commit                    IN VARCHAR2 DEFAULT FND_API.g_true
       ,p_api_version_number        IN NUMBER DEFAULT G_API_VERSION_DEFAULT
       ,p_init_msg_list             IN VARCHAR2 DEFAULT FND_API.g_false
       ,px_content_item_id          IN OUT NOCOPY NUMBER
       ,px_citem_ver_id             IN OUT NOCOPY NUMBER
       ,px_object_version_number    IN OUT NOCOPY NUMBER
       ,x_return_status             OUT NOCOPY VARCHAR2
       ,x_msg_count                 OUT NOCOPY NUMBER
       ,x_msg_data                  OUT NOCOPY VARCHAR2
);

-- --------------------------------------------------------------
-- UPSERT ITEM
--
-- --------------------------------------------------------------
PROCEDURE upsert_item(
	      p_ctype_code                 IN VARCHAR2
       ,p_citem_name                IN VARCHAR2
       ,p_citem_description         IN VARCHAR2
       ,p_dir_node_id               IN NUMBER DEFAULT Ibc_Utilities_Pub.G_COMMON_DIR_NODE
       ,p_owner_resource_id         IN NUMBER DEFAULT NULL
       ,p_owner_resource_type       IN VARCHAR2 DEFAULT NULL
       ,p_reference_code            IN VARCHAR2 DEFAULT NULL
       ,p_trans_required            IN VARCHAR2 DEFAULT FND_API.g_false
       ,p_parent_item_id            IN NUMBER DEFAULT NULL
       ,p_lock_flag                 IN VARCHAR2 DEFAULT FND_API.g_true
       ,p_wd_restricted             IN VARCHAR2 DEFAULT FND_API.g_true
       ,p_start_date                IN DATE DEFAULT NULL
       ,p_end_date                  IN DATE DEFAULT NULL
       ,p_attribute_type_codes      IN JTF_VARCHAR2_TABLE_100 DEFAULT NULL
       ,p_attributes                IN JTF_VARCHAR2_TABLE_4000 DEFAULT NULL
       ,p_attach_file_ids           IN JTF_NUMBER_TABLE
       ,p_default_rendition         IN NUMBER DEFAULT NULL
       ,p_component_citems          IN JTF_NUMBER_TABLE DEFAULT NULL
       ,p_component_atypes          IN JTF_VARCHAR2_TABLE_100 DEFAULT NULL
       ,p_sort_order                IN JTF_NUMBER_TABLE DEFAULT NULL
       ,p_status                    IN VARCHAR2 DEFAULT Ibc_Utilities_Pub.G_STV_WORK_IN_PROGRESS
       ,p_log_action                IN VARCHAR2 DEFAULT FND_API.g_true
       ,p_language                  IN VARCHAR2 DEFAULT USERENV('LANG')
       ,p_commit                    IN VARCHAR2 DEFAULT FND_API.g_true
       ,p_api_version_number        IN NUMBER DEFAULT G_API_VERSION_DEFAULT
       ,p_init_msg_list             IN VARCHAR2 DEFAULT FND_API.g_false
       ,px_content_item_id          IN OUT NOCOPY NUMBER
       ,px_citem_ver_id             IN OUT NOCOPY NUMBER
       ,px_object_version_number    IN OUT NOCOPY NUMBER
       ,x_return_status             OUT NOCOPY VARCHAR2
       ,x_msg_count                 OUT NOCOPY NUMBER
       ,x_msg_data                  OUT NOCOPY VARCHAR2
);

-- --------------------------------------------------------------
-- UPSERT ITEM FULL
--
--  Overloaded - Added support for 32K attr values
-- --------------------------------------------------------------
PROCEDURE upsert_item_full(
	    p_ctype_code                 IN VARCHAR2
       ,p_citem_name                IN VARCHAR2
       ,p_citem_description         IN VARCHAR2
       ,p_dir_node_id               IN NUMBER
       ,p_owner_resource_id         IN NUMBER
       ,p_owner_resource_type       IN VARCHAR2
       ,p_reference_code            IN VARCHAR2
       ,p_trans_required            IN VARCHAR2
       ,p_parent_item_id            IN NUMBER
       ,p_lock_flag                 IN VARCHAR2
       ,p_wd_restricted             IN VARCHAR2
       ,p_start_date                IN DATE
       ,p_end_date                  IN DATE
       ,p_attribute_type_codes      IN JTF_VARCHAR2_TABLE_100
       ,p_attributes                IN JTF_VARCHAR2_TABLE_32767
       ,p_attach_file_id            IN NUMBER
       ,p_item_renditions           IN JTF_NUMBER_TABLE
       ,p_default_rendition         IN NUMBER
       ,p_component_citems          IN JTF_NUMBER_TABLE
       ,p_component_citem_ver_ids   IN JTF_NUMBER_TABLE
       ,p_component_atypes          IN JTF_VARCHAR2_TABLE_100
       ,p_sort_order                IN JTF_NUMBER_TABLE
       ,p_keywords                  IN JTF_VARCHAR2_TABLE_100
       ,p_status                    IN VARCHAR2
       ,p_log_action                IN VARCHAR2
       ,p_language                  IN VARCHAR2
       ,p_update                    IN VARCHAR2
       ,p_commit                    IN VARCHAR2
       ,p_api_version_number        IN NUMBER
       ,p_init_msg_list             IN VARCHAR2
       ,px_content_item_id          IN OUT NOCOPY NUMBER
       ,px_citem_ver_id             IN OUT NOCOPY NUMBER
       ,px_object_version_number    IN OUT NOCOPY NUMBER
       ,x_return_status             OUT NOCOPY VARCHAR2
       ,x_msg_count                 OUT NOCOPY NUMBER
       ,x_msg_data                  OUT NOCOPY VARCHAR2
);

-- --------------------------------------------------------------
-- UPSERT ITEM FULL
--
--  Overloaded - For "old" attachment renditions
-- --------------------------------------------------------------
PROCEDURE upsert_item_full(
	    p_ctype_code                 IN VARCHAR2
       ,p_citem_name                IN VARCHAR2
       ,p_citem_description         IN VARCHAR2
       ,p_dir_node_id               IN NUMBER
       ,p_owner_resource_id         IN NUMBER
       ,p_owner_resource_type       IN VARCHAR2
       ,p_reference_code            IN VARCHAR2
       ,p_trans_required            IN VARCHAR2
       ,p_parent_item_id            IN NUMBER
       ,p_lock_flag                 IN VARCHAR2
       ,p_wd_restricted             IN VARCHAR2
       ,p_start_date                IN DATE
       ,p_end_date                  IN DATE
       ,p_attribute_type_codes      IN JTF_VARCHAR2_TABLE_100
       ,p_attributes                IN JTF_VARCHAR2_TABLE_4000
       ,p_attach_file_id            IN NUMBER
       ,p_item_renditions           IN JTF_NUMBER_TABLE
       ,p_default_rendition         IN NUMBER
       ,p_component_citems          IN JTF_NUMBER_TABLE
       ,p_component_citem_ver_ids   IN JTF_NUMBER_TABLE
       ,p_component_atypes          IN JTF_VARCHAR2_TABLE_100
       ,p_sort_order                IN JTF_NUMBER_TABLE
       ,p_keywords                  IN JTF_VARCHAR2_TABLE_100
       ,p_status                    IN VARCHAR2
       ,p_log_action                IN VARCHAR2
       ,p_language                  IN VARCHAR2
       ,p_update                    IN VARCHAR2
       ,p_commit                    IN VARCHAR2
       ,p_api_version_number        IN NUMBER
       ,p_init_msg_list             IN VARCHAR2
       ,px_content_item_id          IN OUT NOCOPY NUMBER
       ,px_citem_ver_id             IN OUT NOCOPY NUMBER
       ,px_object_version_number    IN OUT NOCOPY NUMBER
       ,x_return_status             OUT NOCOPY VARCHAR2
       ,x_msg_count                 OUT NOCOPY NUMBER
       ,x_msg_data                  OUT NOCOPY VARCHAR2
);

-- --------------------------------------------------------------
-- UPSERT ITEM FULL
--
--  Overloaded - For "old" attachment renditions
-- --------------------------------------------------------------
PROCEDURE upsert_item_full(
	    p_ctype_code                 IN VARCHAR2
       ,p_citem_name                IN VARCHAR2
       ,p_citem_description         IN VARCHAR2
       ,p_dir_node_id               IN NUMBER
       ,p_owner_resource_id         IN NUMBER
       ,p_owner_resource_type       IN VARCHAR2
       ,p_reference_code            IN VARCHAR2
       ,p_trans_required            IN VARCHAR2
       ,p_parent_item_id            IN NUMBER
       ,p_lock_flag                 IN VARCHAR2
       ,p_wd_restricted             IN VARCHAR2
       ,p_start_date                IN DATE
       ,p_end_date                  IN DATE
       ,p_attribute_type_codes      IN JTF_VARCHAR2_TABLE_100
       ,p_attributes                IN JTF_VARCHAR2_TABLE_4000
       ,p_attach_file_ids           IN JTF_NUMBER_TABLE
       ,p_default_rendition         IN NUMBER
       ,p_component_citems          IN JTF_NUMBER_TABLE
       ,p_component_citem_ver_ids   IN JTF_NUMBER_TABLE
       ,p_component_atypes          IN JTF_VARCHAR2_TABLE_100
       ,p_sort_order                IN JTF_NUMBER_TABLE
       ,p_keywords                  IN JTF_VARCHAR2_TABLE_100
       ,p_status                    IN VARCHAR2
       ,p_log_action                IN VARCHAR2
       ,p_language                  IN VARCHAR2
       ,p_update                    IN VARCHAR2
       ,p_commit                    IN VARCHAR2
       ,p_api_version_number        IN NUMBER
       ,p_init_msg_list             IN VARCHAR2
       ,px_content_item_id          IN OUT NOCOPY NUMBER
       ,px_citem_ver_id             IN OUT NOCOPY NUMBER
       ,px_object_version_number    IN OUT NOCOPY NUMBER
       ,x_return_status             OUT NOCOPY VARCHAR2
       ,x_msg_count                 OUT NOCOPY NUMBER
       ,x_msg_data                  OUT NOCOPY VARCHAR2
);

-- --------------------------------------------------------------
-- UPSERT ITEM FULL
-- Overloaded - No Keywords
--
-- --------------------------------------------------------------
PROCEDURE upsert_item_full(
	    p_ctype_code                 IN VARCHAR2
       ,p_citem_name                IN VARCHAR2
       ,p_citem_description         IN VARCHAR2
       ,p_dir_node_id               IN NUMBER
       ,p_owner_resource_id         IN NUMBER
       ,p_owner_resource_type       IN VARCHAR2
       ,p_reference_code            IN VARCHAR2
       ,p_trans_required            IN VARCHAR2
       ,p_parent_item_id            IN NUMBER
       ,p_lock_flag                 IN VARCHAR2
       ,p_wd_restricted             IN VARCHAR2
       ,p_start_date                IN DATE
       ,p_end_date                  IN DATE
       ,p_attribute_type_codes      IN JTF_VARCHAR2_TABLE_100
       ,p_attributes                IN JTF_VARCHAR2_TABLE_4000
       ,p_attach_file_ids           IN JTF_NUMBER_TABLE
       ,p_default_rendition         IN NUMBER
       ,p_component_citems          IN JTF_NUMBER_TABLE
       ,p_component_citem_ver_ids   IN JTF_NUMBER_TABLE
       ,p_component_atypes          IN JTF_VARCHAR2_TABLE_100
       ,p_sort_order                IN JTF_NUMBER_TABLE
       ,p_status                    IN VARCHAR2
       ,p_log_action                IN VARCHAR2
       ,p_language                  IN VARCHAR2
       ,p_update                    IN VARCHAR2
       ,p_commit                    IN VARCHAR2
       ,p_api_version_number        IN NUMBER
       ,p_init_msg_list             IN VARCHAR2
       ,px_content_item_id          IN OUT NOCOPY NUMBER
       ,px_citem_ver_id             IN OUT NOCOPY NUMBER
       ,px_object_version_number    IN OUT NOCOPY NUMBER
       ,x_return_status             OUT NOCOPY VARCHAR2
       ,x_msg_count                 OUT NOCOPY NUMBER
       ,x_msg_data                  OUT NOCOPY VARCHAR2
);


-- --------------------------------------------------------------
-- UPSERT ITEM FULL
--  Overloaded no access to sub component item version ids.
--
-- --------------------------------------------------------------
PROCEDURE upsert_item_full(
	    p_ctype_code                 IN VARCHAR2
       ,p_citem_name                IN VARCHAR2
       ,p_citem_description         IN VARCHAR2
       ,p_dir_node_id               IN NUMBER DEFAULT Ibc_Utilities_Pub.G_COMMON_DIR_NODE
       ,p_owner_resource_id         IN NUMBER DEFAULT NULL
       ,p_owner_resource_type       IN VARCHAR2 DEFAULT NULL
       ,p_reference_code            IN VARCHAR2 DEFAULT NULL
       ,p_trans_required            IN VARCHAR2 DEFAULT FND_API.g_false
       ,p_parent_item_id            IN NUMBER DEFAULT NULL
       ,p_lock_flag                 IN VARCHAR2 DEFAULT FND_API.g_true
       ,p_wd_restricted             IN VARCHAR2 DEFAULT FND_API.g_true
       ,p_start_date                IN DATE DEFAULT NULL
       ,p_end_date                  IN DATE DEFAULT NULL
       ,p_attribute_type_codes      IN JTF_VARCHAR2_TABLE_100 DEFAULT NULL
       ,p_attributes                IN JTF_VARCHAR2_TABLE_4000 DEFAULT NULL
       ,p_attach_file_ids           IN JTF_NUMBER_TABLE DEFAULT NULL
       ,p_default_rendition         IN NUMBER DEFAULT NULL
       ,p_component_citems          IN JTF_NUMBER_TABLE DEFAULT NULL
       ,p_component_atypes          IN JTF_VARCHAR2_TABLE_100 DEFAULT NULL
       ,p_sort_order                IN JTF_NUMBER_TABLE DEFAULT NULL
       ,p_status                    IN VARCHAR2 DEFAULT Ibc_Utilities_Pub.G_STV_WORK_IN_PROGRESS
       ,p_log_action                IN VARCHAR2 DEFAULT FND_API.g_true
       ,p_language                  IN VARCHAR2 DEFAULT USERENV('LANG')
       ,p_update                    IN VARCHAR2 DEFAULT FND_API.g_false
       ,p_commit                    IN VARCHAR2 DEFAULT FND_API.g_true
       ,p_api_version_number        IN NUMBER DEFAULT G_API_VERSION_DEFAULT
       ,p_init_msg_list             IN VARCHAR2 DEFAULT FND_API.g_false
       ,px_content_item_id          IN OUT NOCOPY NUMBER
       ,px_citem_ver_id             IN OUT NOCOPY NUMBER
       ,px_object_version_number    IN OUT NOCOPY NUMBER
       ,x_return_status             OUT NOCOPY VARCHAR2
       ,x_msg_count                 OUT NOCOPY NUMBER
       ,x_msg_data                  OUT NOCOPY VARCHAR2
);


-- --------------------------------------------------------------
-- UPSERT ITEM FULL
-- Wrapper - no renditions
-- --------------------------------------------------------------
PROCEDURE upsert_item_full(
	    p_ctype_code                 IN VARCHAR2
       ,p_citem_name                IN VARCHAR2
       ,p_citem_description         IN VARCHAR2
       ,p_dir_node_id               IN NUMBER DEFAULT Ibc_Utilities_Pub.G_COMMON_DIR_NODE
       ,p_owner_resource_id         IN NUMBER DEFAULT NULL
       ,p_owner_resource_type       IN VARCHAR2 DEFAULT NULL
       ,p_reference_code            IN VARCHAR2 DEFAULT NULL
       ,p_trans_required            IN VARCHAR2 DEFAULT FND_API.g_false
       ,p_parent_item_id            IN NUMBER DEFAULT NULL
       ,p_lock_flag                 IN VARCHAR2 DEFAULT FND_API.g_true
       ,p_wd_restricted             IN VARCHAR2 DEFAULT FND_API.g_true
       ,p_start_date                IN DATE DEFAULT NULL
       ,p_end_date                  IN DATE DEFAULT NULL
       ,p_attribute_type_codes      IN JTF_VARCHAR2_TABLE_100 DEFAULT NULL
       ,p_attributes                IN JTF_VARCHAR2_TABLE_4000 DEFAULT NULL
       ,p_attach_file_id            IN NUMBER DEFAULT NULL
       ,p_component_citems          IN JTF_NUMBER_TABLE DEFAULT NULL
       ,p_component_atypes          IN JTF_VARCHAR2_TABLE_100 DEFAULT NULL
       ,p_sort_order                IN JTF_NUMBER_TABLE DEFAULT NULL
       ,p_status                    IN VARCHAR2 DEFAULT Ibc_Utilities_Pub.G_STV_WORK_IN_PROGRESS
       ,p_log_action                IN VARCHAR2 DEFAULT FND_API.g_true
       ,p_language                  IN VARCHAR2 DEFAULT USERENV('LANG')
       ,p_update                    IN VARCHAR2 DEFAULT FND_API.g_false
       ,p_commit                    IN VARCHAR2 DEFAULT FND_API.g_true
       ,p_api_version_number        IN NUMBER DEFAULT G_API_VERSION_DEFAULT
       ,p_init_msg_list             IN VARCHAR2 DEFAULT FND_API.g_false
       ,px_content_item_id          IN OUT NOCOPY NUMBER
       ,px_citem_ver_id             IN OUT NOCOPY NUMBER
       ,px_object_version_number    IN OUT NOCOPY NUMBER
       ,x_return_status             OUT NOCOPY VARCHAR2
       ,x_msg_count                 OUT NOCOPY NUMBER
       ,x_msg_data                  OUT NOCOPY VARCHAR2
);


-- --------------------------------------------------------------
-- IBC_CITEM_ADMIN_GRP.CHANGE_TRANSLATION_STATUS
--  It changes status of a particular version. It will not allow
--  changes to approved versions.  NOTE: archiving of versions is
--  not currently supported even though status CODE exists.
-- --------------------------------------------------------------

PROCEDURE Change_Translation_Status(
     p_citem_ver_id             IN NUMBER
    ,p_new_status               IN VARCHAR2
    ,p_language                 IN VARCHAR2 DEFAULT USERENV('LANG')
    ,p_commit                   IN VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version_number       IN NUMBER   DEFAULT G_API_VERSION_DEFAULT
    ,p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.g_false
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
    );

-- --------------------------------------------------------------
-- isCitemVerInPassedStatus
--
-- Used to see if any item version exists for the passed
-- item version status
--
-- --------------------------------------------------------------
FUNCTION isCitemVerInPassedStatus(
                                  p_content_item_id      IN NUMBER
                                 ,p_citem_version_status IN VARCHAR2
                                 ) RETURN BOOLEAN;

-- --------------------------------------------------------------
-- isItemLockedByCurrentUser
--
-- Used to see if the item is locked by the current user
--
-- --------------------------------------------------------------
FUNCTION isItemLockedByCurrentUser(p_content_item_id IN NUMBER) RETURN BOOLEAN;

END;

 

/
