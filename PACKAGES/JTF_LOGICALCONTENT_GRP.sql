--------------------------------------------------------
--  DDL for Package JTF_LOGICALCONTENT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_LOGICALCONTENT_GRP" AUTHID CURRENT_USER AS
/* $Header: JTFGLCTS.pls 115.9 2004/07/09 18:49:58 applrt ship $ */


g_api_version CONSTANT NUMBER       := 1.0;
g_pkg_name   CONSTANT VARCHAR2(30):='JTF_LogicalContent_GRP';

TYPE obj_lgl_ctnt_rec_type  IS RECORD (
        obj_lgl_ctnt_delete	  VARCHAR2(1),
	OBJ_lgl_ctnt_id		  NUMBER,
        Object_Version_Number   NUMBER,
	Object_id			  NUMBER,
        Context_id              NUMBER,
        deliverable_id 		  NUMBER
);

TYPE obj_lgl_ctnt_tbl_type  IS TABLE OF
        obj_lgl_ctnt_rec_type INDEX BY BINARY_INTEGER;


PROCEDURE save_delete_lgl_ctnt(
   p_api_version         IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
   p_commit              IN  VARCHAR2 := FND_API.g_false,
   x_return_status       OUT VARCHAR2,
   x_msg_count           OUT  NUMBER,
   x_msg_data            OUT  VARCHAR2,
   p_object_type_code    IN   VARCHAR2,
  p_lgl_ctnt_tbl	      IN  OBJ_LGL_CTNT_TBL_TYPE
 );


-----------------------------------------------------------------------
-- NOTES
--    1. Deletes all the references to display context in
--       JTF_DSP_OBJ_LGL_CTNT table
--  Note : This method should not be called from the application
---------------------------------------------------------------------
PROCEDURE delete_context(
   p_context_id		 IN   NUMBER
 );

-----------------------------------------------------------------------
-- NOTES
--    1. Deletes all references to category and deliverable in
--       JTF_DSP_OBJ_LGL_CTNT table
--  Note : This method should not be called from the application
---------------------------------------------------------------------
PROCEDURE delete_category_dlv(
   p_category_id		IN NUMBER,
   p_deliverable_id		IN    NUMBER
 );

-----------------------------------------------------------------------
-- NOTES
--    1. Deletes all references to section in JTF_DSP_OBJ_LGL_CTNT table
--  Note : This method should not be called from the application
---------------------------------------------------------------------
PROCEDURE delete_section(
   p_section_id		 IN   NUMBER
 );

-----------------------------------------------------------------------
-- NOTES
--    1. Deletes all the refrences to category in JTF_DSP_OBJ_LGL_CTNT table
--  Note : This method should not be called from the application
---------------------------------------------------------------------
PROCEDURE delete_category(
   p_category_id		 IN   NUMBER
);

-----------------------------------------------------------------------
-- NOTES
--    1. Deletes all the refrences to item in JTF_DSP_OBJ_LGL_CTNT table
--  Note : This method should not be called from the application
---------------------------------------------------------------------
PROCEDURE delete_item(
   p_item_id		 IN   NUMBER
);

-----------------------------------------------------------------------
-- NOTES
--    1. Update all references to deliverable to null in JTF_DSP_OBJ_LGL_CTNT table
--  Note : This method should not be called from the application
---------------------------------------------------------------------
PROCEDURE delete_deliverable(
   p_deliverable_id	 IN   NUMBER
 );

END JTF_LogicalContent_GRP;


 

/
