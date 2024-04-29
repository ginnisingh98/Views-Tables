--------------------------------------------------------
--  DDL for Package FEM_DATAX_LOADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_DATAX_LOADER_PKG" AUTHID CURRENT_USER AS
-- $Header: fem_data_loader.pls 120.0 2005/06/06 19:43:44 appldev noship $

PROCEDURE Master (
   errbuf          OUT NOCOPY VARCHAR2,
   retcode         OUT NOCOPY VARCHAR2,
   p_exec_mode     IN         VARCHAR2,
   p_obj_def_id    IN         NUMBER,
   p_ledger_id     IN         NUMBER,
   p_dataset_cd    IN         NUMBER,
   p_source_cd     IN         NUMBER,
   p_cal_per_id    IN         NUMBER
);

PROCEDURE Validation;

PROCEDURE Registration;

PROCEDURE Pre_Process;

PROCEDURE Process_Rows (
   p_eng_sql         IN         VARCHAR2,
   p_slc_pred        IN         VARCHAR2,
   p_proc_num        IN         NUMBER,
   p_part_code       IN         NUMBER,
   p_fetch_limit     IN         NUMBER,
   p_data_table      IN         VARCHAR2,
   p_object_id       IN         NUMBER,
   p_ledger_id       IN         NUMBER,
   p_dataset_cd      IN         NUMBER,
   p_cal_per_id      IN         NUMBER,
   p_source_cd       IN         NUMBER,
   p_exec_mode       IN         VARCHAR2,
   p_req_id          IN         NUMBER,
   p_cctr_org_sql    IN         VARCHAR2,
   p_fin_elem_sql    IN         VARCHAR2,
   p_product_sql     IN         VARCHAR2,
   p_nat_acct_sql    IN         VARCHAR2,
   p_channel_sql     IN         VARCHAR2,
   p_line_item_sql   IN         VARCHAR2,
   p_project_sql     IN         VARCHAR2,
   p_customer_sql    IN         VARCHAR2,
   p_entity_sql      IN         VARCHAR2,
   p_geography_sql   IN         VARCHAR2,
   p_task_sql        IN         VARCHAR2,
   p_interco_sql     IN         VARCHAR2,
   p_user_dim1_sql   IN         VARCHAR2,
   p_user_dim2_sql   IN         VARCHAR2,
   p_user_dim3_sql   IN         VARCHAR2,
   p_user_dim4_sql   IN         VARCHAR2,
   p_user_dim5_sql   IN         VARCHAR2,
   p_user_dim6_sql   IN         VARCHAR2,
   p_user_dim7_sql   IN         VARCHAR2,
   p_user_dim8_sql   IN         VARCHAR2,
   p_user_dim9_sql   IN         VARCHAR2,
   p_user_dim10_sql  IN         VARCHAR2
);

PROCEDURE Post_Process;

PROCEDURE Get_Put_Messages (
   p_msg_count       IN   NUMBER,
   p_msg_data        IN   VARCHAR2
);

END Fem_DataX_Loader_Pkg;

 

/
