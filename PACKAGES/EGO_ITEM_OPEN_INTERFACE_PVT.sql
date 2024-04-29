--------------------------------------------------------
--  DDL for Package EGO_ITEM_OPEN_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_ITEM_OPEN_INTERFACE_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOPOPIS.pls 120.8.12010000.2 2011/07/14 11:53:20 nendrapu ship $ */

   PROCEDURE item_open_interface_process(
      ERRBUF            OUT     NOCOPY VARCHAR2
     ,RETCODE           OUT     NOCOPY VARCHAR2
     ,p_org_id          IN             NUMBER
     ,p_all_org         IN             NUMBER   := 1
     ,p_val_item_flag   IN             NUMBER   := 1
     ,p_pro_item_flag   IN             NUMBER   := 1
     ,p_del_rec_flag    IN             NUMBER   := 1
     ,p_xset_id         IN             NUMBER   := -999
     ,p_run_mode        IN             NUMBER   := 1
     ,p_prog_appid      IN             NUMBER   := -1
     ,p_prog_id         IN             NUMBER   := -1
     ,p_request_id      IN             NUMBER   := -1
     ,p_user_id         IN             NUMBER   := -1
     ,p_login_id        IN             NUMBER   := -1
     ,p_commit_flag     IN             NUMBER   := 1
     ,p_default_flag    IN             NUMBER   DEFAULT 1 );

   --4717744 : All item entities in a new prg
   PROCEDURE process_item_entities(
      ERRBUF            OUT     NOCOPY VARCHAR2
     ,RETCODE           OUT     NOCOPY VARCHAR2
     ,p_del_rec_flag    IN             NUMBER   := 1
     ,p_xset_id         IN             NUMBER   := -999
     ,p_request_id      IN             NUMBER   := -1
     ,p_call_uda_process IN            BOOLEAN  DEFAULT TRUE   -- Bug 12635842

     );


   -------------------------------------------------------------------
   -- In this method we call methods for copying
   --       1. Item People
   --       2. Item LC Project
   --       3. Item Attachments
   -------------------------------------------------------------------
   PROCEDURE Post_Import_Defaulting(ERRBUF            OUT     NOCOPY VARCHAR2,
                                    RETCODE           OUT     NOCOPY VARCHAR2,
                                    p_batch_id        IN             NUMBER,
                                    p_del_rec_flag    IN             NUMBER   := 1);

   --------------------------------------------------------------------
   -- EGO Concurrent Wrapper API for INV Concurrent API for processing
   -- Item Category Assignments (from MTL_ITEM_CATEGORIES_INTERFACE)
   --
   -- Fix for Bug# 3616946 (PPEDDAMA)
   -- Removed the parameters: Upload Processed Records and Delete
   -- Processed Records from UI. So, defaulting the values in this API:
   -- Upload Processed Records = 1 (Yes)
   -- Delete Processed Records = 0 (No)
   --------------------------------------------------------------------

   PROCEDURE process_Item_Category_records(
     ERRBUF              OUT  NOCOPY VARCHAR2
    ,RETCODE             OUT  NOCOPY VARCHAR2
    ,p_rec_set_id        IN   NUMBER
    ,p_upload_rec_flag   IN   NUMBER    :=  1
    ,p_delete_rec_flag   IN   NUMBER    :=  0
    ,p_commit_flag       IN   NUMBER    :=  1
    ,p_prog_appid        IN   NUMBER    :=  NULL
    ,p_prog_id           IN   NUMBER    :=  NULL
    ,p_request_id        IN   NUMBER    :=  NULL
    ,p_user_id           IN   NUMBER    :=  NULL
    ,p_login_id          IN   NUMBER    :=  NULL);


------------------------------------------------------------------------------------
/*
   Procedure for Displaying Error in the Concurrent Log.
   In case the Error Page is not working, helps in Debugging.
   Fix for Bug#4540712 (RSOUNDAR)

   param p_entity_name:Entity for which the Error is reported.
   param p_table_name :Table from which the Error is generated.
   param p_selectQuery:Query for getting ITEM_NUMBER,ORGANIZATION_CODE,ERROR_MESSAGE
                       from the respective interface tables calling this API.
   param p_request_id :Request ID of the transaction.
   param x_return_status:Returns the unexpected error encountered during processing.
   param x_msg_count: Indicates how many messages exist on ERROR_HANDLER
                      message stack upon completion of processing.
   param x_msg_data:Contains message in ERROR_HANDLER message stack
                    upon completion of processing.
 */
--------------------------------------------------------------------------------------
    PROCEDURE Write_Error_into_ConcurrentLog(
      p_entity_name      IN         VARCHAR2
     ,p_table_name       IN         VARCHAR2
	  ,p_selectQuery      IN         VARCHAR2
	  ,p_request_id       IN         NUMBER
	  ,x_return_status    OUT NOCOPY VARCHAR2
	  ,x_msg_count        OUT NOCOPY NUMBER
     ,x_msg_data         OUT NOCOPY VARCHAR2);

------------------------------------------------------------------------------------
/*
   Procedure for Applying the specfied template to the specified interface row.
*/
--------------------------------------------------------------------------------------

     FUNCTION APPLY_MULTIPLE_TEMPLATE( p_template_id IN NUMBER
                                      ,p_org_id      IN NUMBER
                                      ,p_all_org     IN NUMBER  := 2
                                      ,p_prog_appid  IN NUMBER  := -1
                                      ,p_prog_id     IN NUMBER  := -1
                                      ,p_request_id  IN NUMBER  := -1
                                      ,p_user_id     IN NUMBER  := -1
                                      ,p_login_id    IN NUMBER  := -1
                                      ,p_xset_id     IN NUMBER  := -999
                                      ,x_err_text    IN OUT NOCOPY VARCHAR2)
     RETURN INTEGER;

END EGO_ITEM_OPEN_INTERFACE_PVT;

/
