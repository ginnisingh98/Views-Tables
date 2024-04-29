--------------------------------------------------------
--  DDL for Package AMS_LISTDEDUPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LISTDEDUPE_PVT" AUTHID CURRENT_USER as
/* $Header: amsvldds.pls 115.11 2002/11/12 23:39:04 jieli ship $ */

-- Start of Comments
--
-- NAME
--   AMS_ListDedupe_PVT
--
-- PURPOSE
--   This package is a Private API for managing List Deduplication information in
--   AMS.  It contains specification for pl/sql records and tables
--
--   Functions:
--	Filte_Word (see below for specification)
--	Dedupe_List (see below for specification)
--
-- NOTES
--
-- HISTORY
--
--	06/29/1999	khung		created
--	07/22/1999	khung		Changed package name and file name
--	09/30/1999	KHUNG		Add support of deduplication from AMS_IMP_SOURCE_LINE
--					as list entry table
-- 11/11/1999  choang   Moved Generate_Key from AMS_PartyImport_PVT.
--
-- End of Comments

-- global constants

/*****************************************************************************************/
-- Start of Comments
--
--    NAME
--	Filter_Word

--    PURPOSE
--	Replaces all noise words for the relevant fields in AMS_LIST_ENTRIES
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN		:
--		p_word		VARCHAR2
--		p_substr_len	AMS_LIST_RULE_ENTRIES.SUBSTRING_LEN%TYPE
--		p_table_name	AMS_LIST_RULE_FIELDS.TABLE_NAME%TYPE
--		p_column_name	AMS_LIST_RULE_FIELDS.COLUMN_NAME%TYPE
--
--    NOTES
--
--
--    HISTORY
--      06/29/1999	khung		created

-- End Of Comments


FUNCTION Filter_Word
 (p_word		VARCHAR2
 ,p_substr_len		AMS_LIST_RULE_FIELDS.SUBSTRING_LENGTH%TYPE
 ,p_field_table_name	AMS_LIST_RULE_FIELDS.FIELD_TABLE_NAME%TYPE
 ,p_field_column_name	AMS_LIST_RULE_FIELDS.FIELD_COLUMN_NAME%TYPE
 )
 RETURN VARCHAR2;

/*****************************************************************************************/
-- Start of Comments
--
--    NAME
--	Dedupe_List

--    PURPOSE
--	This function is for deduplication
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN	  :
--		p_list_header_id		AMS_LIST_HEADERS_ALL.LIST_HEADER_ID%TYPE
--		p_enable_word_replacement_flag	AMS_LIST_HEADERS_ALL.ENABLE_WORD_REPLACEMENT_FLAG%TYPE
--		p_send_to_log			VARCHAR2 := 'N'
--
--    NOTES
--
--
--    HISTORY
--      06/29/1999	khung		created

-- End Of Comments


FUNCTION Dedupe_List
 (p_list_header_id			AMS_LIST_HEADERS_ALL.LIST_HEADER_ID%TYPE
 ,p_enable_word_replacement_flag	AMS_LIST_HEADERS_ALL.ENABLE_WORD_REPLACEMENT_FLAG%TYPE
 ,p_send_to_log				VARCHAR2 := 'N'
 --	add by khung@us 09/30/1999	deduping for entries from AMS_IMP_SOURCE_LINE table
 ,p_object_name				VARCHAR2 := 'AMS_LIST_ENTRIES'
 )
 RETURN NUMBER;


--------------------------------------------------------------------
-- PROCEDURE
--    Generate_Key
-- PURPOSE
--    Return a DEDUPE_KEY given the rules to use
--    for generating the key.
-- PARAMETERS
--    p_list_rule_id: the rule to use for generating the key.
--    p_sys_object_id: the ID of the record
--    p_sys_object_id_field: the ID field to use in the WHERE
--       clause of the dynamic SQL statement.
--    p_word_replacement_flag: indicate whether to perform
--       word replacement against the data.
--    x_dedupe_key: the out value containing the generated key.
--------------------------------------------------------------------
PROCEDURE Generate_Key (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2  := FND_API.g_false,
   p_validation_level   IN    NUMBER    := FND_API.g_valid_level_full,

   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count          OUT NOCOPY   NUMBER,
   x_msg_data           OUT NOCOPY   VARCHAR2,

   p_list_rule_id       IN    NUMBER,
   p_sys_object_id      IN    NUMBER,
   p_sys_object_id_field   IN    VARCHAR2,
   p_word_replacement_flag IN    VARCHAR2,
   x_dedupe_key         OUT NOCOPY   VARCHAR2
);


 FUNCTION Replace_Word(p_word              VARCHAR2,
                        p_replacement_type  VARCHAR2)
  RETURN VARCHAR2;

END AMS_ListDedupe_PVT;


 

/
