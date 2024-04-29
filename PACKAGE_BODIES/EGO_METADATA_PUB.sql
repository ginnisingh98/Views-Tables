--------------------------------------------------------
--  DDL for Package Body EGO_METADATA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_METADATA_PUB" AS
/* $Header: EGOPMDPB.pls 120.0.12010000.1 2010/04/15 12:29:06 kjonnala noship $ */


  /* Currently, we are NOT supporting Public bulkload APIs for Metadata.
     Hence commenting the below procedures.
     For single record public APIs for metadata, please refer to EGO_EXT_FWK_PUB and EGO_ITEM_CATALOG_PUB packages.
  */
/*Public Procedures
  --Main procedure for API processing. Takes care of AGs and its associated DL Called by Public API.
  PROCEDURE process_attribute_group(
    p_ag_tbl        IN OUT NOCOPY ego_attr_groups_tbl,
    p_agdl_tbl      IN OUT NOCOPY ego_attr_groups_dl_tbl,
    p_commit        IN BOOLEAN DEFAULT false,
    x_return_status OUT VARCHAR2,
    x_return_msg    OUT VARCHAR2)
    IS
    BEGIN
    	ego_process_ag_pvt.process_attribute_group(p_ag_tbl, p_agdl_tbl, p_commit, x_return_status,x_return_msg);
    EXCEPTION
    	WHEN  OTHERS THEN
    		x_return_status := g_ret_sts_unexp_error;
    		ego_metadata_bulkload_pvt.Write_debug('import_agdl - Exception When Others');
    END;
  --Main procedure for Attributes processing through API
  PROCEDURE process_attribute(
    p_attr_tbl      IN OUT NOCOPY ego_attr_group_cols_tbl,
    p_commit        IN BOOLEAN DEFAULT false,
    x_return_status OUT VARCHAR2,
    x_return_msg    OUT VARCHAR2)
    IS
    BEGIN
    	ego_process_ag_pvt.process_attribute(p_attr_tbl, p_commit, x_return_status,x_return_msg);
    EXCEPTION
    	WHEN  OTHERS THEN
    		x_return_status := g_ret_sts_unexp_error;
    		ego_metadata_bulkload_pvt.Write_debug('import_attribute - Exception When Others');
    END;

  --Main procedure for API processing. Takes care of Pages and is called by Public API.
  PROCEDURE process_pages(
    p_pg_tbl        IN OUT NOCOPY ego_pg_tbl,
    p_commit        IN BOOLEAN DEFAULT false,
    x_return_status OUT VARCHAR2,
    x_return_msg    OUT VARCHAR2)
    IS
    BEGIN
    	ego_process_pg_pvt.process_pages(p_pg_tbl, p_commit, x_return_status,x_return_msg);
    EXCEPTION
    	WHEN  OTHERS THEN
    		x_return_status := g_ret_sts_unexp_error;
    		ego_metadata_bulkload_pvt.Write_debug('import_pg - Exception When Others');
    END;

  --Main procedure for Page Entries processing through API
  PROCEDURE process_pg_entries(
    p_ent_tbl       IN OUT NOCOPY ego_ent_tbl,
    p_commit        IN BOOLEAN DEFAULT false,
    x_return_status OUT VARCHAR2,
    x_return_msg    OUT VARCHAR2)
    IS
    BEGIN
    	ego_process_pg_pvt.process_pg_entries(p_ent_tbl, p_commit, x_return_status,x_return_msg);
    EXCEPTION
    	WHEN  OTHERS THEN
    		x_return_status := g_ret_sts_unexp_error;
    		ego_metadata_bulkload_pvt.Write_debug('import_ent - Exception When Others');
    END;
 */
  /*-- Public API to create Value Set (No Child Value Set)
  PROCEDURE Process_Value_Set (
           p_api_version      IN            NUMBER,
           p_value_set_tbl    IN OUT NOCOPY Value_Set_Tbl,
           p_set_process_id   IN            NUMBER,
           x_return_status    OUT NOCOPY    VARCHAR2,
           x_msg_count        OUT NOCOPY    NUMBER,
           x_msg_data         OUT NOCOPY    VARCHAR2)
  IS

  BEGIN
   	Ego_Value_Set_Pvt.Process_Value_Set(p_api_version,p_value_set_tbl, p_set_process_id,x_return_status,x_msg_count,x_msg_data);
  EXCEPTION
   	WHEN  OTHERS THEN
    		x_return_status := g_ret_sts_unexp_error;
    		ego_metadata_bulkload_pvt.Write_debug(' Public API Process_Value_Set failed. ');
  END;


  -- Public API to create Value
  PROCEDURE Process_Value_Set_Value (
           p_api_version            IN         NUMBER,
           p_value_set_val_tbl      IN         Value_Set_Value_Tbl,
           p_value_set_val_tl_tbl   IN         Value_Set_Value_Tl_Tbl,
           p_set_process_id         IN         NUMBER,
           x_return_status          OUT NOCOPY VARCHAR2,
           x_msg_count              OUT NOCOPY NUMBER,
           x_msg_data               OUT NOCOPY VARCHAR2)
  IS

  BEGIN
   	Ego_Value_Set_Pvt.Process_Value_Set_Value(p_api_version,p_value_set_val_tbl,p_value_set_val_tl_tbl,p_set_process_id,x_return_status,x_msg_count,x_msg_data);
  EXCEPTION
   	WHEN  OTHERS THEN
    		x_return_status := g_ret_sts_unexp_error;
    		ego_metadata_bulkload_pvt.Write_debug(' Public API Process_Value_Set_Value failed. ');
  END;



  -- Public API to create Child Value Set and corresponding values
  PROCEDURE Process_Child_Value_Set (
           p_api_version      IN         NUMBER,
           p_value_set_tbl    IN         Value_Set_Tbl,
           p_valueset_val_tab IN         Value_Set_Value_Tbl,
           p_set_process_id   IN         NUMBER,
           x_return_status    OUT NOCOPY VARCHAR2,
           x_msg_count        OUT NOCOPY NUMBER,
           x_msg_data         OUT NOCOPY VARCHAR2)

  IS

  BEGIN
   	Ego_Value_Set_Pvt.Process_Child_Value_Set(p_api_version,p_value_set_tbl,p_valueset_val_tab, p_set_process_id,x_return_status,x_msg_count,x_msg_data);
  EXCEPTION
   	WHEN  OTHERS THEN
    		x_return_status := g_ret_sts_unexp_error;
    		ego_metadata_bulkload_pvt.Write_debug(' Public API Process_Child_Value_Set failed. ');
  END;
  */


END EGO_METADATA_PUB;

/
