--------------------------------------------------------
--  DDL for Package JTF_DSPMGRVALIDATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_DSPMGRVALIDATION_GRP" AUTHID CURRENT_USER AS
/* $Header: JTFGDVDS.pls 115.7 2004/07/09 18:49:51 applrt ship $ */


g_api_version CONSTANT NUMBER       := 1.0;
g_pkg_name   CONSTANT VARCHAR2(30):='JTF_DSPMGRVALIDATION_GRP';

context_accname_req_exception EXCEPTION;
context_req_exception	      EXCEPTION;
category_req_exception	      EXCEPTION;
template_req_exception	      EXCEPTION;
lglctnt_id_req_exception      EXCEPTION;
msite_req_exception			EXCEPTION;
physmap_not_exists_exception	EXCEPTION;

-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  the deliverable  id  exists
--    2. If object version number is passed, then the deliverable id
--	   with object version number is checked for existence
--    3. If deliverable id  in both cases if not found
--       message JTF_DSP_DLV_NOT_EXISTS is pushed on the stack
---------------------------------------------------------------------
FUNCTION check_deliverable_exists(
	p_deliverable_id IN NUMBER,
	p_object_version_number IN NUMBER := FND_API.G_MISS_NUM)
RETURN boolean;

-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  the deliverable with type matches
--       valid types are TEMPLATE/MEDIA
---   2. applicable to ,is used if passed
--    3. If not found ,returns false and message JTF_DSP_DLV_TYPE_NOT_EXISTS
--       is pushed onto the stack
---------------------------------------------------------------------
FUNCTION check_deliverable_type_exists(
	p_deliverable_id IN NUMBER,
	p_item_type IN VARCHAR2,
	p_applicable_to IN VARCHAR2 := FND_API.g_miss_char)
RETURN boolean;

-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  the object id with the right type does exist
---------------------------------------------------------------------
FUNCTION check_lgl_object_exists(
	p_object_type IN VARCHAR2,
	p_object_id IN NUMBER )
RETURN boolean;

-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  the logical content  id  exists
--    2. If object version number is passed, then the logical content id
--	   with object version number is checked for existence
--    3. If logical content id in both cases is not found
--       message JTF_DSP_LGL_CTNT_ID_NOT_EXISTS is pushed on the stack
---------------------------------------------------------------------
FUNCTION check_lgl_ctnt_id_exists(
	p_lgl_ctnt_id IN NUMBER,
	p_object_version_number IN NUMBER := FND_API.G_MISS_NUM )
RETURN boolean;

-----------------------------------------------------------------
-- NOTES
--    1. Returns false if there is no association for a
--       deliverable id/ category id in JTF_DSP_TPL_CTG
--    2. No message is pushed on the stack
---------------------------------------------------------------------
FUNCTION check_ctg_tpl_relation_exists(
	p_category_id IN NUMBER,
	p_template_id IN NUMBER)
RETURN boolean;

-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  the category id does exist
--    2. Return false, if the category id does not exist,
--       JTF_DSP_CATEGORY_NOT_EXISTS is pushed on the stack
---------------------------------------------------------------------
FUNCTION check_category_exists(p_category_id IN NUMBER)
RETURN boolean;

-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  the item id does exist
--    2. Return false, if the item id does not exist,
--       JTF_DSP_ITEM_NOT_EXISTS is pushed on the stack
---------------------------------------------------------------------
FUNCTION check_item_exists(p_item_id IN NUMBER)
RETURN boolean;

-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  the section id does exist
--    2. Return false, if the section id does not exist,
--       JTF_DSP_SECTION_NOT_EXISTS is pushed on the stack
---------------------------------------------------------------------
FUNCTION check_section_exists(p_section_id IN NUMBER)
RETURN boolean;

-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  the section id does exist
--    2. Return false, if the section id does not exist,
--       JTF_MSITE_RSECID_INVLD is pushed on the stack
---------------------------------------------------------------------
FUNCTION check_root_section_exists(p_root_section_id IN NUMBER)
RETURN boolean;

-----------------------------------------------------------------
-- NOTES
--    1. Returns true if the context id with the context type exists
--    2. Object version number is used if it is not FND_API.G_MISS_NUM
--    3. If the context_id is passed does not exist, an exception is
--       raised , and JTF_DSP_CONTEXT_NOT_EXISTS is pushed on the
--       message stack
---------------------------------------------------------------------
FUNCTION check_context_exists(
	p_context_id IN NUMBER,
	p_context_type IN VARCHAR2,
	p_object_version_number IN NUMBER := FND_API.G_MISS_NUM)
RETURN boolean;

-----------------------------------------------------------------
-- NOTES
--    1. Returns false if the context accessname is not being used
--    2. If the context_id is passed, then the access name being
--       used is checked against access names other than the context
--       id passed
--    3. If the context access name is being used, then it returns true
--       and JTF_DSP_CONTEXT_ACCNAME_EXISTS  is pushed on the
--       message stack
---------------------------------------------------------------------
FUNCTION check_context_accessname(
	p_context_accessname IN VARCHAR2,
	p_context_type       IN VARCHAR2,
      p_context_id 	   IN NUMBER := FND_API.G_MISS_NUM)
RETURN boolean;

-----------------------------------------------------------------
-- NOTES
--    1. Returns true if the context type is valid (TEMPLATE/MEDIA)
--    2. FND_LOOKUP used for context type is JTF_AMV_DELV_TYPE_CODE
--    3. If the context type passed is not valid, an exception is
--       raised , and JTF_DSP_CONTEXT_TYPE_INVALID is pushed on the
--       message stack
---------------------------------------------------------------------
FUNCTION check_valid_context_type(p_context_type IN VARCHAR2)
RETURN boolean;

-----------------------------------------------------------------
-- NOTES
--    1. Returns the context type code for a given context id
--    2. If the context_id is passed does not exist, null is returned
--       , and JTF_DSP_CONTEXT_NOT_EXISTS is pushed on the
--       message stack
---------------------------------------------------------------------
FUNCTION check_context_type_code(p_context_id IN NUMBER)
RETURN VARCHAR2;

-----------------------------------------------------------------
-- NOTES
--    1. Returns true if the object type is valid (S/I/C)
--    2. FND_LOOKUP used for object type is
--    3. If the object type passed is not valid, an exception is
--       raised , and JTF_DSP_OBJECT_TYPE_INVALID is pushed on the
--       message stack
---------------------------------------------------------------------
FUNCTION check_valid_object_type(p_object_type_code in VARCHAR2)
RETURN boolean;


FUNCTION check_item_deliverable(p_item_id IN NUMBER,
					  p_deliverable_id IN NUMBER)
RETURN boolean;

FUNCTION check_category_deliverable(p_category_id IN NUMBER,
						p_deliverable_id IN NUMBER)
RETURN Boolean;

FUNCTION check_master_msite_exists
RETURN NUMBER;

-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  the attachment id exists
--    2. Object version number is used if it is not FND_API.G_MISS_NUM
--    3. Return false, if the attachment id  does not exist,
--       JTF_DSP_ATH_NOT_EXISTS is pushed on the stack
---------------------------------------------------------------------
FUNCTION check_attachment_exists(
	p_attachment_id IN NUMBER,
	p_object_version_number IN NUMBER := FND_API.G_MISS_NUM)
RETURN boolean;

-----------------------------------------------------------------
-- NOTES
--    1. Return attachment_id if the attachment with the same file name exists
--    2. Otherwise return null
---------------------------------------------------------------------
FUNCTION check_attachment_exists(
	p_file_name IN VARCHAR2)
RETURN NUMBER;

-----------------------------------------------------------------
-- NOTES
--    1. Return attachment_id if the attachment with the same file name
--       and file id exists and belongs to the deliverable
--    2. Otherwise return null
-- Added by G. Zhang 05/23/01 10:57AM
---------------------------------------------------------------------
FUNCTION check_attachment_exists(
	p_deliverable_id IN NUMBER,
	p_file_id IN NUMBER,
	p_file_name IN VARCHAR2)
RETURN NUMBER;

-----------------------------------------------------------------
-- NOTES
--    1. Returns deliverable id for a attachment
--    2. If deliverable id or attachment id not exists , return null
--    3. Message JTF_DSP_ATH_NOT_EXISTS is pushed on the stack
---------------------------------------------------------------------
FUNCTION check_attachment_deliverable(p_attachment_id IN NUMBER)
RETURN NUMBER;

-----------------------------------------------------------------
-- NOTES
--    1. Return true if the attachment belongs to the deliverable
--    2. Otherwise, return false; Message JTG_DSP_DLV_ATH_INVLD is
--	 pushed on the stack
---------------------------------------------------------------------
FUNCTION check_attachment_deliverable(
	p_attachment_id IN NUMBER,
	p_deliverable_id IN NUMBER)
RETURN BOOLEAN;

-----------------------------------------------------------------
-- NOTES
--    1. Return true if the attachment has all-site and all-language mapping
--    2. Return false otherwise
---------------------------------------------------------------------
FUNCTION check_default_attachment(
        p_attachment_id IN NUMBER)
RETURN BOOLEAN;

-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  the filename associated with the attachment
--	   is not null and unique
--    2. If file name is null or missing message JTF_DSP_ATH_FILENAME_REQ
--        is pushed on the stack
--	3. If file name already exists , message JTF_DSP_ATH_FILENAME_EXISTS
--       is pushed on the stack
---------------------------------------------------------------------
FUNCTION check_attachment_filename(p_attachment_id IN NUMBER,
	p_file_name IN varchar2)
RETURN boolean;

-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  the minisite exists
--    2. If not, message JTF_MSITE_NOT_EXISTS is pushed on the stack
---------------------------------------------------------------------
FUNCTION check_msite_exists(
	p_msite_id IN NUMBER,
	p_object_version_number IN NUMBER := FND_API.G_MISS_NUM)
RETURN boolean;

-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  the language is supported by the minisite
--    2. If not,  message JTF_MSITE_LANG_NOT_SUPPORTED
--        is pushed on the stack
---------------------------------------------------------------------
FUNCTION check_language_supported(
	p_msite_id IN NUMBER,
	p_language_code in varchar2 )
RETURN boolean;

-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  lgl_phys_map_id (JTF_DSP_LGL_PHYS_MAP) exists
--    2. If not , message JTF_DSP_PHYSMAP_NOT_EXISTS is pushed on the stack
---------------------------------------------------------------------
FUNCTION check_physicalmap_exists( p_lgl_phys_map_id IN NUMBER )
RETURN boolean;

-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  the deliverable with accessname exists and
--	   is not null and unique
--    2. If access name is null, message JTF_DSP_DLV_ACCNAME_REQ
--        is pushed on the stack
--	3. If access name already exists , message JTF_DSP_DLV_ACCNAME_EXISTS
--       is pushed on the stack
---------------------------------------------------------------------
FUNCTION check_deliverable_accessname(
	p_deliverable_id IN NUMBER,
	p_access_name IN varchar2)
RETURN boolean;

---------------------------------------------------------------------
-- NOTES
-- 1. Returns TRUE if the access_name for a mini site is Unique.
-- 2. If Access Name already exists, message JTF_MSITE_DUP_ACCNAME is pushed on stack.
---------------------------------------------------------------------
FUNCTION Check_Msite_Accessname(p_access_name IN VARCHAR2)
RETURN BOOLEAN ;

END JTF_DSPMGRVALIDATION_GRP;

 

/
