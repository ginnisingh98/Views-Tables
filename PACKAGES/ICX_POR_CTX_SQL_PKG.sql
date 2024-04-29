--------------------------------------------------------
--  DDL for Package ICX_POR_CTX_SQL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_POR_CTX_SQL_PKG" AUTHID CURRENT_USER AS
/* $Header: ICXCTXS.pls 115.1 2004/03/31 21:56:19 vkartik ship $*/

-- OEX_IP_PORTING
TYPE DescriptorInfo IS RECORD (
  descriptor_id NUMBER,
  descriptor_key ICX_CAT_DESCRIPTORS_TL.key%TYPE,
  descriptor_index NUMBER,
  descriptor_type NUMBER,
  descriptor_length NUMBER,
  section_tag NUMBER,
  stored_in_column ICX_CAT_DESCRIPTORS_TL.stored_in_column%TYPE,
  stored_in_table ICX_CAT_DESCRIPTORS_TL.stored_in_table%TYPE
);

TYPE DescriptorInfoTab IS TABLE OF DescriptorInfo INDEX BY
  BINARY_INTEGER;

TYPE SQLTab IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;

-- Use this where clause for rowid based operations
ROWID_WHERE_CLAUSE CONSTANT VARCHAR2(40) := ' AND tl.rowid = :p_rowid';
-- Use this where clause for itemid based operations
ITEMID_WHERE_CLAUSE CONSTANT VARCHAR2(40) := ' AND tl.rt_item_id = :p_item_id';
ITEMS_B_PREFIX CONSTANT VARCHAR2(40) := 'i';
ITEMS_TLP_PREFIX CONSTANT VARCHAR2(40) := 'tl';

-- Default max length for each row in icx_por_ctx_tl, set to 3600, leaving
-- 400 bytes for category name, section tags etc
DEFAULT_MAX_LENGTH CONSTANT NUMBER := 3600;

/* Constructs the sql required to populate icx_por_ctx_tl
 - pCategoryId - Category Id, pass in 0 if constructing for the root attributes
 - pDescriptors - Table containing info about searchable descriptors
 - pWhereClause - Where clause to be appended to the end of the sql statements
 - pLanguage - Language to use
 - pMaxLength - The max length each ctx row should hold.  This is used in
                cases when we know each attribute is much shorter than it's
                max length and we want to pack more attributes into each row
 - pInsertSQL - Table containing SQL for processing new items for the loader
 - pUpdateSQL - Table containing SQL for processing existing items
   (Existing means it exists in icx_por_items_tl)
*/
PROCEDURE build_ctx_sql(pCategoryId IN NUMBER,
                        pDescriptors IN DescriptorInfoTab,
                        pWhereClause IN VARCHAR2,
                        pLanguage IN VARCHAR2,
                        pMaxLength IN NUMBER,
                        pInsertSQL OUT NOCOPY SQLTab,
                        pUpdateSQL OUT NOCOPY SQLTab);

/* Constructs the sql required to populate icx_por_ctx_tl
 - This will load the descriptor info for pCategoryId and then call the
   version of build_ctx_sql that takes in a DescriptorInfoTab
 - pCategoryId - Category Id, pass in 0 if constructing for the root attributes
 - pWhereClause - Where clause to be appended to the end of the sql statements
 - pLanguage - Language to use
 - pMaxLength - The max length each ctx row should hold.  This is used in
                cases when we know each attribute is much shorter than it's
                max length and we want to pack more attributes into each row
 - pInsertSQL - Table containing SQL for processing new items for the loader
 - pUpdateSQL - Table containing SQL for processing existing items
   (Existing means it exists in icx_por_items_tl)
*/
PROCEDURE build_ctx_sql(pCategoryId IN NUMBER,
                        pWhereClause IN VARCHAR2,
                        pLanguage IN VARCHAR2,
                        pMaxLength IN NUMBER,
                        pInsertSQL OUT NOCOPY SQLTab,
                        pUpdateSQL OUT NOCOPY SQLTab);


/* Constructs the sql required to populate icx_por_ctx_tl
 - pCategoryId - Category Id, pass in 0 if constructing for the root attributes
 - pWhereClause - Where clause to be appended to the end of the sql statements
 - pLanguage - Language to use
 - pInsertSQL - Table containing SQL for processing new items for the loader
 - pUpdateSQL - Table containing SQL for processing existing items
   (Existing means it exists in icx_por_items_tl)
*/
PROCEDURE build_ctx_sql(pCategoryId IN NUMBER,
                        pWhereClause IN VARCHAR2,
                        pLanguage IN VARCHAR2,
                        pInsertSQL OUT NOCOPY SQLTab,
                        pUpdateSQL OUT NOCOPY SQLTab);

/* Constructs the sql required to populate icx_por_ctx_tl. Use this if you
   don't want the sql to include a filter on the language
 - pCategoryId - Category Id, pass in 0 if constructing for the root attributes
 - pWhereClause - Where clause to be appended to the end of the sql statements
 - pInsertSQL - Table containing SQL for processing new items for the loader
 - pUpdateSQL - Table containing SQL for processing existing items
   (Existing means it exists in icx_por_items_tl)
*/
PROCEDURE build_ctx_sql(pCategoryId IN NUMBER,
                        pWhereClause IN VARCHAR2,
                        pInsertSQL OUT NOCOPY SQLTab,
                        pUpdateSQL OUT NOCOPY SQLTab);


END ICX_POR_CTX_SQL_PKG;

 

/
