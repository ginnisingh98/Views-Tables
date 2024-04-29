--------------------------------------------------------
--  DDL for Package IBE_LOGICALCONTENT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_LOGICALCONTENT_GRP" AUTHID CURRENT_USER AS
  /* $Header: IBEGLCTS.pls 115.1 2002/12/14 07:50:34 schak ship $ */


g_api_version CONSTANT NUMBER      := 1.0;
g_pkg_name    CONSTANT VARCHAR2(30):='IBE_LogicalContent_GRP';

TYPE obj_lgl_ctnt_rec_type  IS RECORD (
  obj_lgl_ctnt_delete	  VARCHAR2(1),
  OBJ_lgl_ctnt_id	  NUMBER,
  Object_Version_Number   NUMBER,
  Object_id		  NUMBER,
  Context_id              NUMBER,
  deliverable_id 	  NUMBER );

TYPE obj_lgl_ctnt_tbl_type  IS TABLE OF
  obj_lgl_ctnt_rec_type INDEX BY BINARY_INTEGER;

PROCEDURE save_delete_lgl_ctnt(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
  p_commit              IN  VARCHAR2 := FND_API.g_false,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  p_object_type_code    IN  VARCHAR2,
  p_lgl_ctnt_tbl        IN  OBJ_LGL_CTNT_TBL_TYPE );

-----------------------------------------------------------------------+
-- NOTES
--    1. Deletes all the references to display context in
--       IBE_DSP_OBJ_LGL_CTNT table
--  Note : This method should not be called from the application
---------------------------------------------------------------------+
PROCEDURE delete_context(p_context_id	 IN   NUMBER );

-----------------------------------------------------------------------+
-- NOTES
--    1. Deletes all references to category and deliverable in
--       IBE_DSP_OBJ_LGL_CTNT table
--  Note : This method should not be called from the application
---------------------------------------------------------------------+
PROCEDURE delete_category_dlv(
                              p_category_id		IN    NUMBER,
                              p_deliverable_id		IN    NUMBER );

-----------------------------------------------------------------------+
-- NOTES
--    1. Deletes all references to section in IBE_DSP_OBJ_LGL_CTNT table
--  Note : This method should not be called from the application
---------------------------------------------------------------------+
PROCEDURE delete_section(p_section_id	 IN   NUMBER );

-----------------------------------------------------------------------+
-- NOTES
--  1. Deletes all the refrences to category in IBE_DSP_OBJ_LGL_CTNT table
--  Note : This method should not be called from the application
---------------------------------------------------------------------+
PROCEDURE delete_category(p_category_id	 IN   NUMBER );

-----------------------------------------------------------------------+
-- NOTES
--  1. Deletes all the refrences to item in IBE_DSP_OBJ_LGL_CTNT table
--  Note : This method should not be called from the application
---------------------------------------------------------------------+
PROCEDURE delete_item(p_item_id	 IN   NUMBER );

-----------------------------------------------------------------------+
-- NOTES
--  1. Update all references to deliverable to null in
--     IBE_DSP_OBJ_LGL_CTNT table
--  Note : This method should not be called from the application
---------------------------------------------------------------------
PROCEDURE delete_deliverable(p_deliverable_id IN   NUMBER );

END IBE_LogicalContent_GRP;

 

/
