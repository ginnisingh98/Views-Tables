--------------------------------------------------------
--  DDL for Package ICX_POR_SCHEMA_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_POR_SCHEMA_UPLOAD" AUTHID CURRENT_USER AS
/* $Header: ICXSULDS.pls 115.11 2003/09/08 10:58:34 pcreddy ship $*/

-- Number of seeded descriptors
NUM_SEEDED_DESCRIPTORS CONSTANT Number := 300;

-- Category type
GENUS_TYPE		CONSTANT Number := 2;
NAVIGATION_TYPE		CONSTANT Number := 1;

-- Schema Attribute Ids
ROOT_ATTRIB_ID		CONSTANT Number := 0;
LOCAL_ATTRIB_ID		CONSTANT Number := 1;

-- Descriptor type
TEXT_TYPE		CONSTANT VARCHAR2(30) := '0';
NUMERIC_TYPE      CONSTANT VARCHAR2(30) := '1';
TRANSLATABLE_TEXT_TYPE	CONSTANT VARCHAR2(30) := '2';
DATE_TYPE          CONSTANT VARCHAR2(30) := '3';
URL_TYPE           CONSTANT VARCHAR2(30) := '4';
INTEGER_TYPE      CONSTANT VARCHAR2(30) := '5';

-- YES and NO
YES CONSTANT VARCHAR2(1) := '1';
NO  CONSTANT VARCHAR2(1) := '0';



-------------------------------------------------------------------------
--                             ADD ACTION                              --
-------------------------------------------------------------------------
/**
 ** Proc : add_child_category
 ** Desc : Add a category as a child of another category.
 **        If this child category is already a child of other
 **        category, this relationship will be remained.
 **        Also this parent category should be navigation type.
 **/
/* Changes for userId, loginId Added two parameters p_user_id, p_login_id */
PROCEDURE add_child_category (p_parent_id	IN NUMBER,
                              p_child_id	IN NUMBER,
                              p_user_id         IN NUMBER,
                              p_login_id        IN NUMBER);

/**
 ** Proc : create_category
 ** Desc : Create a new category with the specified name + key.
 **        If parent is specified, a new link will be created.
 **        This method assumes all parameters are validated, and
 **        it only creates one row for specified language, won't
 **        create rows for each installed language.
 **/
/* Changes for userId, loginId Added two parameters p_user_id, p_login_id */
PROCEDURE create_category (p_category_id	OUT NOCOPY NUMBER,
                           p_key		IN VARCHAR2,
                           p_name		IN VARCHAR2,
                           p_description	IN VARCHAR2,
                           p_type		IN NUMBER,
                           p_language		IN VARCHAR2,
                           p_parent_id		IN NUMBER DEFAULT -1,
                           p_request_id		IN NUMBER DEFAULT -1,
                           p_user_id            IN NUMBER,
                           p_login_id           IN NUMBER);

/**
 ** Proc : create_category_table
 ** Desc : Create dynamic table and view for genus category.
PROCEDURE create_category_table (p_category_id IN NUMBER);
 **/

/**
 ** Proc : create_descriptor
 ** Desc : Create a new local descriptor within a category.
 **        A dynamic category table will be created if it doesn't
 **        exist, and a new column is added to this table.
 **        This method assumes everything is validated before
 **        calling. And it only creates one row for specified
 **        language, won't create rows for each installed language.
 **/
/* Changes for userId, loginId Added two parameters p_user_id, p_login_id */
PROCEDURE create_descriptor (p_descriptor_id		OUT NOCOPY NUMBER,
                             p_key			      IN VARCHAR2,
                             p_name 			IN VARCHAR2 DEFAULT NULL,
                             p_description		IN VARCHAR2 DEFAULT NULL,
                             p_type			      IN VARCHAR2 DEFAULT
                                                         TEXT_TYPE,
                             p_sequence			IN NUMBER,
                             p_search_results_visible	IN VARCHAR2 DEFAULT NO,
                             p_item_detail_visible	IN VARCHAR2 DEFAULT NO,
                             p_searchable		      IN VARCHAR2 DEFAULT NO,
                             p_required			IN VARCHAR2 DEFAULT NO,
                             p_refinable		      IN VARCHAR2 DEFAULT NO,
                             p_multivalue             IN VARCHAR2 DEFAULT NO,
                             p_default_value		IN VARCHAR2 DEFAULT NULL,
                             p_language			IN VARCHAR2,
                             p_category_id 		IN NUMBER,
                             p_request_id		      IN NUMBER DEFAULT -1,
                             p_section_tag		      OUT NOCOPY NUMBER,
                             p_stored_in_table			OUT NOCOPY VARCHAR2,
                             p_stored_in_column			OUT NOCOPY VARCHAR2,
                             p_user_id                  IN NUMBER,
                             p_login_id                 IN NUMBER);


/**
 ** Proc : create_descriptor_metadata
 ** Desc : Insert a new local descriptor into ICX_POR_DESCRIPTORS_TL.
 **        This method simply pulls out the metadata section of a descriptor
 **        that gets inserted into ICX_DESCRIPTORS_TL. This is done to
 **        separate the insertion of data, from the creation of a dynamic
 **        table. And is called directly in online category creation.
 **        This method assumes everything is validated before
 **        calling. And it will create rows for each installed language.
 **/
/* Changes for userId, loginId Added two parameters p_user_id, p_login_id */
PROCEDURE create_descriptor_metadata (p_descriptor_id   IN NUMBER,
                             p_key				IN VARCHAR2,
                             p_name 			IN VARCHAR2,
                             p_description		IN VARCHAR2,
                             p_type				IN VARCHAR2,
                             p_sequence			IN NUMBER,
                             p_search_results_visible	IN VARCHAR2,
                             p_item_detail_visible	IN VARCHAR2,
                             p_searchable			IN VARCHAR2,
                             p_required			IN VARCHAR2,
                             p_refinable			IN VARCHAR2,
                             p_multivalue       	IN VARCHAR2,
                             p_default_value		IN VARCHAR2,
                             p_language			IN VARCHAR2,
                             p_category_id 		IN NUMBER,
			     	     p_request_id			IN NUMBER DEFAULT -1,
			           p_rebuild_flag           IN VARCHAR2,
			           p_descriptor_id_out	OUT NOCOPY NUMBER,
                             p_user_id                  IN NUMBER,
                             p_login_id                 IN NUMBER);


-------------------------------------------------------------------------
--                            UPDATE ACTION                            --
-------------------------------------------------------------------------
/**
 ** Proc : update_category
 ** Desc : Update an existing category for a sepcified language.
 **        If parent is specified, a new link will be created.
 **/
/* Changes for userId, loginId Added two parameters p_user_id, p_login_id */
PROCEDURE update_category (p_category_id	IN NUMBER,
                           p_language	IN VARCHAR2,
                           p_name		IN VARCHAR2 DEFAULT NULL,
                           p_description	IN VARCHAR2 DEFAULT NULL,
                           p_type		IN NUMBER   DEFAULT -1,
                           p_parent_id	IN NUMBER   DEFAULT -1,
                           p_request_id	IN NUMBER   DEFAULT -1,
                           p_user_id            IN NUMBER,
                           p_login_id           IN NUMBER);

/**
 ** Proc : update_descriptor
 ** Desc : Update a existing local descriptor for a specified language
 **        within a category.
 **/
/* Changes for userId, loginId Added two parameters p_user_id, p_login_id */
PROCEDURE update_descriptor (p_descriptor_id		IN NUMBER,
                             p_language			IN VARCHAR2,
                             p_name 			IN VARCHAR2 DEFAULT NULL,
                             p_description		IN VARCHAR2 DEFAULT NULL,
                             p_default_value		IN VARCHAR2 DEFAULT NULL,
                             p_sequence			IN VARCHAR2 DEFAULT NULL,
                             p_search_results_visible	IN VARCHAR2 DEFAULT NULL,
                             p_item_detail_visible	IN VARCHAR2 DEFAULT NULL,
                             p_searchable			IN VARCHAR2 DEFAULT NULL,
                             p_required			IN VARCHAR2 DEFAULT NULL,
                             p_refinable			IN VARCHAR2 DEFAULT NULL,
                             p_multivalue             IN VARCHAR2 DEFAULT NULL,
                             p_request_id			IN NUMBER   DEFAULT -1,
                             p_section_tag		      OUT NOCOPY NUMBER,
                             p_stored_in_table			OUT NOCOPY VARCHAR2,
                             p_stored_in_column			OUT NOCOPY VARCHAR2,
                             p_user_id                  IN NUMBER,
                             p_login_id                 IN NUMBER);


-------------------------------------------------------------------------
--                            DELETE ACTION                            --
-------------------------------------------------------------------------
/**
 ** Proc : delete_child_category
 ** Desc : Delete a category as a child of another category.
 **        Also this parent category should be navigation type.
 **/

PROCEDURE delete_child_category (p_parent_id	IN NUMBER,
                                 p_child_id	IN NUMBER);

/**
 ** Proc : delete_category_tree
 ** Desc : Navigate the subtree, delete the whole subtree and items
 **        associated.
 **/
PROCEDURE delete_category_tree (p_category_id IN NUMBER);
PROCEDURE delete_category (p_category_id IN NUMBER);

/**
 ** Proc : delete_descriptor
 ** Desc : Delete the local descriptor within a category.
 **        If no local descriptors for this category, the
 **        dynamic table and view will be dropped.
 **/
 --Bug#3027134 Added who columns in icx_cat_deleted_attributes
 --as part of ECM OA Rewrite
 --So add two parameters for user_id and login_id to delete_descriptors
 --to populate the who columns in icx_cat_deleted_attributes.
PROCEDURE delete_descriptor (p_descriptor_id IN NUMBER,
                             p_request_id IN NUMBER   DEFAULT -1,
                             p_user_id                  IN NUMBER,
                             p_login_id                 IN NUMBER);

-------------------------------------------------------------------------
--                           Rebuild Index                             --
-------------------------------------------------------------------------
/*
** Procedure : populate_ctx_desc_indexes
** Synopsis  : Update the ctx_<lang> columns for items belong to
**             those categories which own rebuild_flags or their
**             local descriptors' rebuild_flags are set to 'Y.'
**
** Parameter:  p_request_id - number of the job to rebuild
*/

PROCEDURE populate_ctx_desc_indexes(p_request_id IN INTEGER := -1);

/*
** Procedure : populate_ctx_desc_indexes
** Synopsis  : Overloaded version. Contains 2 extra out parameters
**             which are used by Concurrent program.
**             No other functional change
**             Update the ctx_<lang> columns for items belong to
**             those categories which own rebuild_flags or their
**             local descriptors' rebuild_flags are set to 'Y.'
**
** Parameter:  p_request_id - number of the job to rebuild
*/

PROCEDURE populate_ctx_desc_indexes(errbuf       OUT NOCOPY VARCHAR2,
                                    retcode      OUT NOCOPY VARCHAR2,
                                    p_request_id IN  INTEGER := -1);


-------------------------------------------------------------------------
--                             Validation                              --
-------------------------------------------------------------------------
/**
 ** Proc : validate_descriptor
 ** Desc : validate whether the loaded parameters are valid
 **/

PROCEDURE validate_descriptor(p_request_id IN OUT NOCOPY NUMBER,
                             p_line_number IN NUMBER,
                             p_user_action IN VARCHAR2,
                             p_system_action OUT NOCOPY VARCHAR2,
                             p_language IN VARCHAR2,
                             p_descriptor_id OUT NOCOPY NUMBER,
                             p_key IN VARCHAR2,
                             p_name IN VARCHAR2,
                             p_type IN VARCHAR2,
                             p_description IN VARCHAR2,
                             p_required IN VARCHAR2,
                             p_sequence IN VARCHAR2,
                             p_searchable IN VARCHAR2,
                             p_multivalue IN VARCHAR2,
                             p_itemdetailvisible IN VARCHAR2,
                             p_searchResultsVisible IN VARCHAR2,
                             p_owner_key IN VARCHAR2,
                             p_owner_name IN VARCHAR2,
                             p_owner_id OUT NOCOPY NUMBER,
                             p_is_valid OUT NOCOPY VARCHAR2);

/* validate descriptor updated online
PROCEDURE validate_update_desc_online(p_request_id IN OUT NOCOPY NUMBER,
                             p_line_number IN NUMBER,
                             p_session_key IN VARCHAR2,
                             p_owner_id IN NUMBER,
                             p_language IN VARCHAR2,
                             p_key IN VARCHAR2,
                             p_name IN VARCHAR2,
                             p_type IN VARCHAR2,
                             p_description IN VARCHAR2,
                             p_required IN VARCHAR2,
                             p_sequence IN VARCHAR2,
                             p_searchable IN VARCHAR2,
                             p_multivalue IN VARCHAR2,
                             p_itemdetailvisible IN VARCHAR2,
                             p_searchResultsVisible IN VARCHAR2,
                             p_descriptor_id IN NUMBER,
                             p_is_valid OUT NOCOPY VARCHAR2);

/* validate descriptor created online
PROCEDURE validate_add_desc_online(p_request_id IN OUT NOCOPY NUMBER,
                             p_line_number IN NUMBER,
                             p_session_key IN VARCHAR2,
                             p_owner_id IN NUMBER,
                             p_language IN VARCHAR2,
                             p_key IN VARCHAR2,
                             p_name IN VARCHAR2,
                             p_type IN VARCHAR2,
                             p_description IN VARCHAR2,
                             p_required IN VARCHAR2,
                             p_sequence IN VARCHAR2,
                             p_searchable IN VARCHAR2,
                             p_multivalue IN VARCHAR2,
                             p_itemdetailvisible IN VARCHAR2,
                             p_searchResultsVisible IN VARCHAR2,
                             p_is_valid OUT NOCOPY VARCHAR2);
*/

/**
 ** Proc : validate_category
 ** Desc : check whether the passin parameters violate the rules
 **/

PROCEDURE validate_category(p_request_id IN OUT NOCOPY NUMBER,
                           p_line_number IN NUMBER,
                           p_user_action IN VARCHAR2,
                           p_system_action OUT NOCOPY VARCHAR2,
                           p_language IN VARCHAR2,
                           p_category_id OUT NOCOPY NUMBER,
                           p_key IN VARCHAR2,
                           p_name IN VARCHAR2,
                           p_type IN VARCHAR2,
                           p_type_value OUT NOCOPY VARCHAR2,
                           p_owner_key IN VARCHAR2,
                           p_owner_name IN VARCHAR2,
                           p_owner_id OUT NOCOPY NUMBER,
                           p_is_valid OUT NOCOPY VARCHAR2);

/**
 ** Proc : validate_hier_relationship
 ** Desc : check the hierarchical relationship between categories
 **/
PROCEDURE validate_hier_relationship(p_request_id IN OUT NOCOPY NUMBER,
                             p_line_number IN NUMBER,
                             p_user_action IN VARCHAR2,
                             p_system_action OUT NOCOPY VARCHAR2,
                             p_language IN VARCHAR2,
                             p_parent_key IN VARCHAR2,
                             p_parent_name IN VARCHAR2,
                             p_parent_id OUT NOCOPY NUMBER,
                             p_child_key IN VARCHAR2,
                             p_child_name IN VARCHAR2,
                             p_child_id OUT NOCOPY NUMBER,
                             p_is_valid OUT NOCOPY VARCHAR2);

PROCEDURE save_failed_category(p_request_id IN NUMBER,
                           p_line_number IN NUMBER,
                           p_action IN VARCHAR2,
                           p_key IN VARCHAR2,
                           p_name IN VARCHAR2,
                           p_type IN VARCHAR2,
                           p_description IN VARCHAR2,
                           p_owner_key IN VARCHAR2,
                           p_owner_name IN VARCHAR2);

PROCEDURE save_failed_descriptor(p_request_id IN NUMBER,
                           p_line_number IN NUMBER,
                           p_action IN VARCHAR2,
                           p_key IN VARCHAR2,
                           p_name IN VARCHAR2,
                           p_type IN VARCHAR2,
                           p_description IN VARCHAR2,
                           p_owner_key IN VARCHAR2,
                           p_owner_name IN VARCHAR2,
                           p_sequence IN VARCHAR2,
                           p_default_value IN VARCHAR2,
                           p_searchable IN VARCHAR2,
                           p_itemdetailvisible IN VARCHAR2,
                           p_searchresultsvisible IN VARCHAR2,
                           p_required IN VARCHAR2,
                           p_multivalue IN VARCHAR2,
                           p_errortype IN VARCHAR2);

PROCEDURE save_failed_hier_relationship(p_request_id IN NUMBER,
                           p_line_number IN NUMBER,
                           p_action IN VARCHAR2,
                           p_parent_key IN VARCHAR2,
                           p_parent_name IN VARCHAR2,
                           p_child_key IN VARCHAR2,
                           p_child_name IN VARCHAR2);


/**
 ** Proc : InsertError
 ** Desc : insert errors inti failed_line_messages table
 **/

PROCEDURE InsertError(p_request_id in out NOCOPY number,
                      p_descriptor_key in varchar2,
                      p_message_name in varchar2,
                      p_line_number in number);

-------------------------------------------------------------------------
--                        Manage Section Tags                          --
-------------------------------------------------------------------------
/**
 ** Proc : release_section_tag
 ** Desc : Called when a descriptor is to be deleted or made not searchable
 **        SHOULD BE CALLED BEFORE THE DESCRIPTOR IS ACTUALLY DELETED
 **        Before calling this the rows in icx_por_categories_tl with the
 **        given rt_category_id should be locked thru a SELECT...FOR UPDATE
 **        to avoid concurrent access to the SECTION_MAP column.  The calling
 **        code is responsible for committing the changes.
 ** Parameters:
 ** p_category_id - category to be modified
 ** p_descriptor_id - descriptor to be modified
 **/
PROCEDURE release_section_tag(p_category_id IN NUMBER,
                              p_descriptor_id IN NUMBER);

/**
 ** Proc : assign_section_tag
 ** Desc : Assigns a section tag to a given searchable descriptor. If the
 **        descriptor is already assigned a tag then the assigned tag will
 **        be returned.
 **        Before calling this the rows in icx_por_categories_tl with the
 **        given rt_category_id should be locked thru a SELECT...FOR UPDATE
 **        to avoid concurrent access to the SECTION_MAP column.  The calling
 **        code is responsible for committing the changes.
 ** Parameters:
 ** p_category_id IN NUMBER - category to be modified
 ** p_descriptor_id IN NUMBER - descriptor to be modified
 ** p_section_tag OUT NUMBER - section tag assigned
 **/
PROCEDURE assign_section_tag(p_category_id IN NUMBER,
                             p_descriptor_id IN NUMBER,
                             p_section_tag OUT NOCOPY NUMBER,
                             p_stored_in_table			OUT NOCOPY VARCHAR2,
                             p_stored_in_column			OUT NOCOPY VARCHAR2,
                             p_type IN VARCHAR2);

/**
 ** Proc : assign_all_section_tags
 ** Desc : Assigns section tags to all searchable descriptors of a given
 **        category.  This is intended to be called during the upgrade to 6.2
 **        or when batch update of a category is needed
 **        Before calling this the rows in icx_por_categories_tl with the
 **        given rt_category_id should be locked thru a SELECT...FOR UPDATE
 **        to avoid concurrent access to the SECTION_MAP column.  The calling
 **        code is responsible for committing the changes.
 ** Parameters:
 ** p_category_id - category to be modified
 **/
PROCEDURE assign_all_section_tags(p_category_id IN NUMBER);

/* this is added for bug 2108372
   the procedure itself will do nothing.
   it will be called when starting a shema bulk load job.
*/
PROCEDURE prepare_job;

PROCEDURE inc_schema_change_version(p_category_id IN NUMBER);

PROCEDURE fail_root_descriptor_section(p_request_id IN OUT NOCOPY NUMBER,
                                       p_action IN VARCHAR2,
                                       p_line_number IN NUMBER);

PROCEDURE sync_deleted_descriptors;

/**
 ** Proc : get_stored_in_values
 ** Desc : Formulates the stored_in_table, stored_in_column
 ** Parameters:
 ** p_descriptor_id - rt_descriptor_id
 ** p_category_id   - rt_category_id
 ** type            - type
 ** p_section_tag   - section_tag
 **/
PROCEDURE get_stored_in_values(p_descriptor_id IN NUMBER,
                               p_category_id IN NUMBER,
                               p_type IN VARCHAR2,
                               p_section_tag IN NUMBER,
                               p_stored_in_table OUT NOCOPY VARCHAR2,
                               p_stored_in_column OUT NOCOPY VARCHAR2);

/**
 ** Proc : update_items_for_category
 ** Desc : Update primary_category_name in items_tlp with the category name for
a sepcified language.
 **/
PROCEDURE update_items_for_category (
                           errbuf         OUT NOCOPY VARCHAR2,
                           retcode        OUT NOCOPY VARCHAR2,
                           p_category_name      IN VARCHAR2,
                           p_category_id        IN NUMBER,
                           p_language           IN VARCHAR2,
                           p_request_id         IN NUMBER   DEFAULT -1);

/**
 ** Proc : update_items_for_category
 ** Desc : Update primary_category_name in items_tlp with the category name for a sepcified language.
 **/
PROCEDURE update_items_for_category (p_category_name      IN VARCHAR2,
                           p_category_id        IN NUMBER,
                           p_language           IN VARCHAR2,
                           p_request_id         IN NUMBER   DEFAULT -1);
/**
 ** Proc : handle_delete_descriptors
 ** Desc : Handles the plsql call required when a descritpor is deleted from ecmanager
 **/
PROCEDURE handle_delete_descriptors (p_searchable      IN NUMBER,
                           p_rename_category_done      IN VARCHAR2,
                           p_category_name             IN VARCHAR2,
                           p_rt_category_id            IN NUMBER,
                           p_language                  IN VARCHAR2,
                           p_request_id                IN NUMBER   DEFAULT -1);

/**
 ** Proc : handle_delete_descriptors
 ** Desc : Overloaded version. No functional change except the 2 OUT parameters
 **        Handles the plsql call required when a descritpor is deleted
 **        from ecmanager
 **/
PROCEDURE handle_delete_descriptors (
                           errbuf                     OUT NOCOPY VARCHAR2,
                           retcode                    OUT NOCOPY VARCHAR2,
                           p_searchable                IN NUMBER,
                           p_rename_category_done      IN VARCHAR2,
                           p_category_name             IN VARCHAR2,
                           p_rt_category_id            IN NUMBER,
                           p_language                  IN VARCHAR2,
                           p_request_id                IN NUMBER   DEFAULT -1);

END ICX_POR_SCHEMA_UPLOAD;

 

/
