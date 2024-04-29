--------------------------------------------------------
--  DDL for Package ICX_CAT_SCHEMA_UPLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_SCHEMA_UPLOAD_PVT" AUTHID CURRENT_USER AS
/* $Header: ICXVSULS.pls 120.9.12010000.2 2014/08/20 10:43:19 rkandima ship $*/

-- Number of seeded descriptors
-- xxx why?
g_NUM_SEEDED_DESCRIPTORS CONSTANT NUMBER := 300;

-- Category type
g_ITEM_CATEGORY CONSTANT NUMBER := 2;
g_BROWSING_CATEORY CONSTANT NUMBER := 1;

-- Schema Attribute Ids
g_ROOT_ATTRIB_ID CONSTANT NUMBER := 0;
g_LOCAL_ATTRIB_ID CONSTANT NUMBER := 1;

-- Descriptor type
g_TEXT_TYPE CONSTANT VARCHAR2(1) := '0';
g_NUMERIC_TYPE CONSTANT VARCHAR2(1) := '1';
g_TRANSLATABLE_TEXT_TYPE CONSTANT VARCHAR2(1) := '2';

-- YES and NO
g_YES CONSTANT VARCHAR2(1) := '1';
g_NO  CONSTANT VARCHAR2(1) := '0';

-----------------------sudsubra----------


-- Procedure the get the nullify values for the different datatypes
-- this returns the values for varchar, number and date
PROCEDURE get_nullify_values
(
  x_nullify_char OUT NOCOPY VARCHAR2,
  x_nullify_num OUT NOCOPY NUMBER,
  x_nullify_date OUT NOCOPY DATE
);

-- Procedure to validate the descriptor before it gets created
-- this method is only called from item load
PROCEDURE validate_descriptor_for_create
(
  p_key IN VARCHAR2,
  p_name IN VARCHAR2,
  p_type IN VARCHAR2,
  p_cat_id IN NUMBER,
  p_language IN VARCHAR2,
  x_is_valid OUT NOCOPY VARCHAR2,
  x_error OUT NOCOPY VARCHAR2
);

-- procedure to save the failed category into the failed lines table
PROCEDURE save_failed_category
(
  p_request_id IN NUMBER,
  p_line_number IN NUMBER,
  p_action IN VARCHAR2,
  p_key IN VARCHAR2,
  p_name IN VARCHAR2,
  p_type IN VARCHAR2,
  p_description IN VARCHAR2
);

-- procedure to save the failed descriptor into the failed lines table
PROCEDURE save_failed_descriptor
(
  p_request_id IN NUMBER,
  p_line_number IN NUMBER,
  p_action IN VARCHAR2,
  p_key IN VARCHAR2,
  p_name IN VARCHAR2,
  p_type IN VARCHAR2,
  p_description IN VARCHAR2,
  p_owner_key IN VARCHAR2,
  p_owner_name IN VARCHAR2,
  p_sequence IN VARCHAR2,
  p_searchable IN VARCHAR2,
  p_item_detail_visible IN VARCHAR2,
  p_search_results_visible IN VARCHAR2,
  p_restrict_access IN VARCHAR2
);

-- procedure to save the failed relationships into the failed lines table
PROCEDURE save_failed_relationship
(
  p_request_id IN NUMBER,
  p_line_number IN NUMBER,
  p_action IN VARCHAR2,
  p_parent_key IN VARCHAR2,
  p_parent_name IN VARCHAR2,
  p_child_key IN VARCHAR2,
  p_child_name IN VARCHAR2
);

-- inserts a row into the failed lines table
PROCEDURE insert_failed_line
(
  p_request_id IN NUMBER,
  p_line_number IN NUMBER,
  p_action IN VARCHAR2,
  p_row_type IN VARCHAR2,
  p_descriptor_key IN VARCHAR2,
  p_descriptor_value IN VARCHAR2
);

-- inserts a row into the failed messages table
PROCEDURE insert_failed_message
(
  p_request_id IN NUMBER,
  p_descriptor_key IN VARCHAR2,
  p_message_name IN VARCHAR2,
  p_line_number IN NUMBER
);

-- procedure to create a category
-- assumes that the parameters are valid
-- called from schema load
PROCEDURE create_category
(
  x_category_id OUT NOCOPY NUMBER,
  p_key IN VARCHAR2,
  p_name IN VARCHAR2,
  p_description IN VARCHAR2,
  p_type IN NUMBER,
  p_language IN VARCHAR2,
  p_request_id IN NUMBER,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER
);

-- procedure to update a category
-- assumes that the parameters are valid
-- called from schema load
PROCEDURE update_category
(
  p_category_id IN NUMBER,
  p_language IN VARCHAR2,
  p_name IN VARCHAR2,
  p_description IN VARCHAR2,
  p_type IN NUMBER,
  p_request_id IN NUMBER,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER
);

-- procedure to delete a category
-- assumes that the parameters are valid
-- called from schema load
PROCEDURE delete_category
(
  p_category_id IN NUMBER,
  p_language IN VARCHAR2,
  p_request_id IN NUMBER,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER
);

-- procedure to validate a category
PROCEDURE validate_category
(
  p_key IN VARCHAR2,
  p_name IN VARCHAR2,
  p_type IN VARCHAR2,
  p_language IN VARCHAR2,
  p_request_id IN NUMBER,
  p_line_number IN NUMBER,
  p_user_action IN VARCHAR2,
  x_is_valid OUT NOCOPY VARCHAR2,
  x_system_action OUT NOCOPY VARCHAR2,
  x_category_id OUT NOCOPY NUMBER,
  x_converted_type OUT NOCOPY VARCHAR2
);


-- function to check if category can be deleted
-- a category can be deleted if it is not referenced on any documents and master items
FUNCTION can_category_be_deleted
(
  p_ip_category_id IN NUMBER
)
RETURN NUMBER;

-- procedure to add a relationship
-- assumes that the categories to be related are valid
PROCEDURE add_relationship
(
  p_parent_id IN NUMBER,
  p_child_id IN NUMBER,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER,
  p_request_id IN NUMBER,
  p_line_number IN NUMBER,
  p_action IN VARCHAR2
);

-- procedure to delete a relationship
-- assumes that the categories to be related are valid
PROCEDURE delete_relationship
(
  p_parent_id IN NUMBER,
  p_child_id IN NUMBER,
  p_request_id IN NUMBER,
  p_line_number IN NUMBER,
  p_action IN VARCHAR2
);

-- procedure to delete a relationship
-- assumes that the categories to be related are valid
PROCEDURE validate_relationship
(
  p_parent_key IN VARCHAR2,
  p_parent_name IN VARCHAR2,
  p_child_key IN VARCHAR2,
  p_child_name IN VARCHAR2,
  p_language IN VARCHAR2,
  p_request_id IN NUMBER,
  p_line_number IN NUMBER,
  p_user_action IN VARCHAR2,
  x_is_valid OUT NOCOPY VARCHAR2,
  x_system_action OUT NOCOPY VARCHAR2,
  x_parent_id OUT NOCOPY NUMBER,
  x_child_id OUT NOCOPY NUMBER
);


-- procedure to create a descriptr
-- this assumes that everything has been validated
PROCEDURE create_descriptor
(
  p_key IN VARCHAR2,
  p_name IN VARCHAR2,
  p_description IN VARCHAR2,
  p_type IN VARCHAR2,
  p_sequence IN NUMBER,
  p_search_results_visible IN VARCHAR2,
  p_item_detail_visible IN VARCHAR2,
  p_searchable IN VARCHAR2,
  p_language IN VARCHAR2,
  p_category_id IN NUMBER,
  p_request_id IN NUMBER,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER,
  x_descriptor_id OUT NOCOPY NUMBER,
  x_stored_in_table OUT NOCOPY VARCHAR2,
  x_stored_in_column OUT NOCOPY VARCHAR2,
  x_section_tag OUT NOCOPY NUMBER,
  p_restrict_access IN VARCHAR2
);

-- procedure to increment the schema version
PROCEDURE inc_schema_change_version
(
  p_category_id IN NUMBER,
  p_request_id IN NUMBER,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER
);

-- Procedure to assign the section tag to a given descriptor
-- If the descriptor is already assigned a section tag it will be returne
PROCEDURE assign_section_tag
(
  p_category_id IN NUMBER,
  p_descriptor_id IN NUMBER,
  p_type IN VARCHAR2,
  p_section_tag OUT NOCOPY NUMBER,
  p_stored_in_table OUT NOCOPY VARCHAR2,
  p_stored_in_column OUT NOCOPY VARCHAR2,
  p_request_id IN NUMBER
);

-- Procedure to release the section tag to a given descriptor
-- should be called before the descriptor is actually deleted
PROCEDURE release_section_tag
(
  p_category_id IN NUMBER,
  p_descriptor_id IN NUMBER,
  p_request_id IN NUMBER
);

-- procedure to update a descriptr
-- this assumes that everything has been validated
PROCEDURE update_descriptor
(
  p_descriptor_id IN NUMBER,
  p_name IN VARCHAR2,
  p_description IN VARCHAR2,
  p_category_id IN VARCHAR2,
  p_sequence IN NUMBER,
  p_search_results_visible IN VARCHAR2,
  p_item_detail_visible IN VARCHAR2,
  p_searchable IN VARCHAR2,
  p_language IN VARCHAR2,
  p_request_id IN NUMBER,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER,
  p_restrict_access IN VARCHAR2
);


-- procedure to delete a descriptr
-- this assumes that everything has been validated
PROCEDURE delete_descriptor
(
  p_descriptor_id IN NUMBER,
  p_request_id IN NUMBER,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER
);

-- function to check if descriptor can be deleted
-- a descriptor can be deleted if it has no values for any documents
FUNCTION can_descriptor_be_deleted
(
  p_descriptor_id IN NUMBER
)
RETURN NUMBER;

-- procedure to validate a descriptor
PROCEDURE validate_descriptor
(
  p_key IN VARCHAR2,
  p_name IN VARCHAR2,
  p_description IN VARCHAR2,
  p_type IN VARCHAR2,
  p_owner_key IN VARCHAR2,
  p_owner_name IN VARCHAR2,
  p_language IN VARCHAR2,
  p_sequence IN VARCHAR2,
  p_searchable IN VARCHAR2,
  p_search_results_visible IN VARCHAR2,
  p_item_detail_visible IN VARCHAR2,
  p_request_id IN NUMBER,
  p_line_number IN NUMBER,
  p_user_action IN VARCHAR2,
  x_is_valid OUT NOCOPY VARCHAR2,
  x_system_action OUT NOCOPY VARCHAR2,
  x_descriptor_id OUT NOCOPY NUMBER,
  x_owner_id OUT NOCOPY NUMBER
);

-- procedure to delete old jobs from the tables
-- (icx_por_batch_jobs, icx_cat_batch_jobs, icx_por_failed_line_messages,
--  icx_por_failed_lines, icx_por_contract_references, icx_cat_parse_errors)
PROCEDURE purge_loader_tables;

-- procedure to populate the ctx desc for schema load
-- this will handle the following cases
-- 1. category name change
-- 2. Change of descriptor searchability
-- 3. Deletion of a descriptor
PROCEDURE populate_ctx_desc
(
  p_request_id IN NUMBER
);

-- methods for online schema
-- submitted through concurrent programs

-- method to populate the ctx desc for category rename
PROCEDURE populate_for_cat_rename
(
  x_errbuf OUT NOCOPY VARCHAR2,
  x_retcode OUT NOCOPY NUMBER,
  p_category_id IN NUMBER,
  p_category_name IN VARCHAR2,
  p_language IN VARCHAR2
);

-- method to populate the ctx_desc for a searchability change
PROCEDURE populate_for_searchable_change
(
  x_errbuf OUT NOCOPY VARCHAR2,
  x_retcode OUT NOCOPY NUMBER,
  p_attribute_id IN NUMBER,
  p_attribute_key IN VARCHAR2,
  p_category_id IN NUMBER,
  p_searchable IN NUMBER
);

-- method to update the status of a job
PROCEDURE update_job_status
(
  p_job_number IN NUMBER,
  p_job_status IN VARCHAR2
);

END ICX_CAT_SCHEMA_UPLOAD_PVT;

/
