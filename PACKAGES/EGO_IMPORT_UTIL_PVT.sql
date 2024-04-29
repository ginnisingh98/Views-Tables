--------------------------------------------------------
--  DDL for Package EGO_IMPORT_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_IMPORT_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOVIMUS.pls 120.7.12010000.9 2011/07/14 11:48:01 nendrapu ship $ */

  PROCEDURE Propagate_Item_Num_To_Child (
                                           p_batch_id                  NUMBER
                                         , p_ss_id                     NUMBER
                                         , p_ss_ref                    VARCHAR2
                                         , p_old_item_number           VARCHAR2
                                         , p_item_number               VARCHAR2
                                        );

  /* Function to do the preprocessing of Import
   * This method is called from Concurrent Program
   * and then, this method internally calls the
   * various defaulting/copy APIs that are needed
   * for preprocessing
   */
  PROCEDURE Preprocess_Import(retcode               OUT NOCOPY VARCHAR2,
                              errbuf                OUT NOCOPY VARCHAR2,
                              p_batch_id                       NUMBER);

  /*
   * This API does the defaulting of Org Assignments
   * from Style to SKU and from SKU to Style
   */
  PROCEDURE Default_Org_Assignments( retcode       OUT NOCOPY VARCHAR2,
                                     errbuf        OUT NOCOPY VARCHAR2,
                                     p_batch_id    NUMBER
                                   );

  /*
   * This method does the defaulting of Item people
   */
  PROCEDURE Default_Item_People( retcode               OUT NOCOPY VARCHAR2,
                                 errbuf                OUT NOCOPY VARCHAR2,
                                 p_batch_id                       NUMBER
                               );

  /*
   * This method copies Item people from style to SKU (that are newly added to style) directly into the Procudution table
   */
  PROCEDURE Copy_Item_People_From_Style( retcode               OUT NOCOPY VARCHAR2,
                                         errbuf                OUT NOCOPY VARCHAR2,
                                         p_batch_id                       NUMBER
                                       );

  /*
   * This API Marks all the records to process_flag 10 in all interface tables
   * to disable SKUs for processing, and marks process_flag to 1
   * to enable SKUs for processing
   */
  PROCEDURE Enable_Disable_SKU_Processing( retcode                  OUT NOCOPY VARCHAR2,
                                           errbuf                   OUT NOCOPY VARCHAR2,
                                           p_batch_id               NUMBER,
                                           p_enable_sku_processing  VARCHAR2, /* T - TRUE / F - FALSE */
                                           x_skus_to_process        OUT NOCOPY VARCHAR2   -- Bug 9678667
                                         );

  /*
   * This method copies the LC Project
   */
  PROCEDURE Copy_LC_Projects( retcode               OUT NOCOPY VARCHAR2,
                              errbuf                OUT NOCOPY VARCHAR2,
                              p_batch_id                       NUMBER
                            );

  PROCEDURE Process_Import_Copy_Options
      (   p_api_version           IN          NUMBER
      ,   p_commit                IN          VARCHAR2 DEFAULT FND_API.G_TRUE
      ,   p_batch_id              IN          NUMBER
      ,   p_copy_option           IN          VARCHAR2
      ,   p_template_name         IN          VARCHAR2
      ,   p_template_sequence     IN          NUMBER
      ,   p_selection_flag        IN          VARCHAR2
      ,   x_return_status         OUT NOCOPY  VARCHAR2
      ,   x_msg_count             OUT NOCOPY  NUMBER
      ,   x_msg_data              OUT NOCOPY  VARCHAR2
      );

  PROCEDURE Process_Variant_Attrs
                                       (   p_api_version           IN          NUMBER
                                       ,   p_commit                IN          VARCHAR2 DEFAULT FND_API.G_TRUE
                                       ,   p_batch_id              IN          NUMBER
                                       ,   p_item_number           IN          VARCHAR2
                                       ,   p_organization_id       IN          NUMBER
                                       ,   p_attr_group_type       IN          VARCHAR2
                                       ,   p_attr_group_name       IN          VARCHAR2
                                       ,   p_attr_name             IN          VARCHAR2
                                       ,   p_data_level_name       IN          VARCHAR2
                                       ,   p_attr_value_num        IN          NUMBER
                                       ,   p_attr_value_str        IN          VARCHAR2
                                       ,   p_attr_value_date       IN          DATE
                                       ,   x_return_status         OUT NOCOPY  VARCHAR2
                                       ,   x_msg_count             OUT NOCOPY  NUMBER
                                       ,   x_msg_data              OUT NOCOPY  VARCHAR2
                                       );

  PROCEDURE Get_Interface_Errors(
                                  p_batch_id       IN NUMBER,
                                  x_item_err_table OUT NOCOPY EGO_VARCHAR_TBL_TYPE,
                                  x_rev_err_table  OUT NOCOPY EGO_VARCHAR_TBL_TYPE,
                                  x_uda_err_table  OUT NOCOPY EGO_VARCHAR_TBL_TYPE
                                );

  /*
   * This method will stale out all the rows in batch
   * that are not latest for enabled_for_data_pool batches
   */
  PROCEDURE Validate_Timestamp_In_Batch(retcode     OUT NOCOPY VARCHAR2,
                                        errbuf      OUT NOCOPY VARCHAR2,
                                        p_batch_id  IN NUMBER);

  PROCEDURE Update_Timestamp_In_Prod(retcode     OUT NOCOPY VARCHAR2,
                                     errbuf      OUT NOCOPY VARCHAR2,
                                     p_batch_id  IN NUMBER);

  PROCEDURE Copy_Attachments ( retcode      OUT NOCOPY VARCHAR2,
                               errbuf       OUT NOCOPY VARCHAR2,
                               p_batch_id   IN NUMBER  );

  /*
   * This method is called at the end of import processing.
   * If any SKUs are created in EGO_SKU_VARIANT_ATTR_USAGES table
   * but corresponding variant attributes are not present in
   * production table, then delete that entry.
   */
  PROCEDURE Clean_Dirty_SKUs( retcode    OUT NOCOPY VARCHAR2,
                              errbuf     OUT NOCOPY VARCHAR2,
                              p_batch_id IN NUMBER );

  PROCEDURE check_for_duplicates(p_batch_id IN NUMBER,p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE);

  /* Fix for bug#9336604 Change: */
  PROCEDURE INSERT_FUN_GEN_SETUP_UDAS( p_batch_id IN NUMBER);
  /* Fix for bug#9336604 Change: */

  -- Bug 8442016 set procedure Call_UDA_Apply_Template as public for reusing it in other API package
  PROCEDURE Call_UDA_Apply_Template
                        ( p_batch_id         IN NUMBER,
                          p_entity_sql       IN VARCHAR2,
                          p_gdsn_entity_sql  IN VARCHAR2,
                          p_user_id          IN NUMBER,
                          p_login_id         IN NUMBER,
                          p_prog_appid       IN NUMBER,
                          p_prog_id          IN NUMBER,
                          p_request_id       IN NUMBER,
                          x_return_status    OUT NOCOPY VARCHAR2,
                          x_err_msg          OUT NOCOPY VARCHAR2
                        );

  -- Bug 9959169 : Making this procedure public and added a new parameter
  PROCEDURE Do_AGLevel_UDA_Defaulting( p_batch_id       NUMBER,
                                      x_return_status   OUT NOCOPY VARCHAR2,
                                      x_err_msg         OUT NOCOPY VARCHAR2,
                                      p_msii_miri_process_flag  IN NUMBER DEFAULT 1
                                     );

 -- Bug 10263673 : Added the below procedure spec to make it public.
 PROCEDURE Process_Copy_Options_For_UDAs( retcode               OUT NOCOPY VARCHAR2,
                                          errbuf                OUT NOCOPY VARCHAR2,
                                          p_batch_id                       NUMBER,
                                          p_copy_options_exist             VARCHAR2
                                        );

  -- Bug 12635842 : Making the below procedure as public for reusing it in other APIs.
  PROCEDURE Default_Child_Entities( retcode        OUT NOCOPY  VARCHAR2
                                  ,errbuf          OUT NOCOPY  VARCHAR2
                                  ,p_batch_id                  NUMBER
                                  ,p_msii_miri_process_flag IN NUMBER DEFAULT 1
                                );

END EGO_IMPORT_UTIL_PVT;

/
