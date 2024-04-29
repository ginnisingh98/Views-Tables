--------------------------------------------------------
--  DDL for Package IBE_TPLCATEGORY_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_TPLCATEGORY_GRP" AUTHID CURRENT_USER AS
  /* $Header: IBEGTCGS.pls 115.1 2002/12/14 07:51:09 schak ship $ */


  -- HISTORY
  --   12/12/02           SCHAK         Modified for NOCOPY (Bug # 2691704) Changes.
  -- *********************************************************************************

g_pkg_name   CONSTANT  VARCHAR2(30)  :='IBE_TplCategory_GRP';
g_api_version CONSTANT NUMBER       := 1.0;

TYPE category_id_tbl_type IS TABLE OF NUMBER(15)
  INDEX BY BINARY_INTEGER;

TYPE template_id_tbl_type IS TABLE  OF NUMBER(15)
  INDEX BY BINARY_INTEGER;

TYPE tpl_ctg_id_tbl_type IS TABLE OF NUMBER(15)
  INDEX BY BINARY_INTEGER;

-----------------------------------------------------------------------+
-- NOTES
--    1. Raises an exception if the api_version is not valid
--    2. Raises an exception if the template_id is missing or invalid
--       The template_id should have DELIVERABLE_TYPE_CODE = TEMPLATE
--	    and APPLICABLE_TO_CODE = CATEGORY (JTF_AMV_ITEMS_B)
--	 3. Raises an exception if any invalid category is passed in
--	    p_category_id_tbl
--
---------------------------------------------------------------------+
PROCEDURE add_tpl_ctg(
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.g_false,
  p_commit                IN  VARCHAR2  := FND_API.g_false,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_template_id           IN  NUMBER,
  p_category_id_tbl       IN  category_id_tbl_type );

-----------------------------------------------------------------------+
-- NOTES
--    1. Raise exception if the p_api_version doesn't match.
--    2. Deletes the association of the template to the category
--	 3. Deletes the category to template association in IBE_OBJ_LGL_CTNT
--       for all display contexts
--------------------------------------------------------------------+
PROCEDURE delete_tpl_ctg_relation(
  p_api_version       IN  NUMBER,
  p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
  p_commit            IN  VARCHAR2 := FND_API.g_false,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2,
  p_tpl_ctg_id_tbl    IN  tpl_ctg_id_tbl_type );

-----------------------------------------------------------------------+
-- NOTES
--    1. Raises an exception if the api_version is not valid
--    2. Raises an exception if the category_id is missing or invalid
--	3. Raises an exception if any invalid template_id is passed in
--	    p_template_id_tbl
--    4. Creates a category to templates relationship (IBE_DSP_TPL_CTG)
---------------------------------------------------------------------+
PROCEDURE add_ctg_tpl(
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN VARCHAR2 := FND_API.g_false,
  p_commit                IN  VARCHAR2  := FND_API.g_false,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY  NUMBER,
  x_msg_data              OUT NOCOPY  VARCHAR2,
  p_category_id           IN NUMBER,
  p_template_id_tbl       IN  template_id_tbl_type );

-----------------------------------------------------------------------+
-- NOTES
--    1. Deletes all the category-template_id association for the
--	   template id passed
--  Note : This method should not be called from the application
---------------------------------------------------------------------+
PROCEDURE delete_deliverable(p_template_id IN  NUMBER );

-----------------------------------------------------------------------+
-- NOTES
--    1. Deletes all the category-template_id association for the
--	   category id passed
--  Note : This method should not be called from the application
---------------------------------------------------------------------+
PROCEDURE delete_category (p_category_id  IN NUMBER );

END IBE_TplCategory_GRP;

 

/
