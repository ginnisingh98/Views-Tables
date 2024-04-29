--------------------------------------------------------
--  DDL for Package FEM_MULTI_PROC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_MULTI_PROC_PKG" AUTHID CURRENT_USER AS
-- $Header: fem_mp_utl.pls 120.1 2006/02/24 13:45:31 ghall noship $

PROCEDURE Master
  (x_prg_stat        OUT    NOCOPY VARCHAR2,
   x_exception_code  OUT    NOCOPY VARCHAR2,
   p_rule_id         IN     NUMBER,
   p_eng_step        IN     VARCHAR2,
   p_data_table      IN     VARCHAR2,
   p_source_db_link  IN     VARCHAR2 DEFAULT NULL,
   p_eng_sql         IN     VARCHAR2 DEFAULT NULL,
   p_table_alias     IN     VARCHAR2 DEFAULT NULL,
   p_run_name        IN     VARCHAR2 DEFAULT NULL,
   p_eng_prg         IN     VARCHAR2 DEFAULT NULL,
   p_condition       IN     VARCHAR2 DEFAULT NULL,
   p_failed_req_id   IN     NUMBER   DEFAULT NULL,
   p_reuse_slices    IN     VARCHAR2 DEFAULT 'N',
   p_arg1            IN     VARCHAR2 DEFAULT NULL,
   p_arg2            IN     VARCHAR2 DEFAULT NULL,
   p_arg3            IN     VARCHAR2 DEFAULT NULL,
   p_arg4            IN     VARCHAR2 DEFAULT NULL,
   p_arg5            IN     VARCHAR2 DEFAULT NULL,
   p_arg6            IN     VARCHAR2 DEFAULT NULL,
   p_arg7            IN     VARCHAR2 DEFAULT NULL,
   p_arg8            IN     VARCHAR2 DEFAULT NULL,
   p_arg9            IN     VARCHAR2 DEFAULT NULL,
   p_arg10           IN     VARCHAR2 DEFAULT NULL,
   p_arg11           IN     VARCHAR2 DEFAULT NULL,
   p_arg12           IN     VARCHAR2 DEFAULT NULL,
   p_arg13           IN     VARCHAR2 DEFAULT NULL,
   p_arg14           IN     VARCHAR2 DEFAULT NULL,
   p_arg15           IN     VARCHAR2 DEFAULT NULL,
   p_arg16           IN     VARCHAR2 DEFAULT NULL,
   p_arg17           IN     VARCHAR2 DEFAULT NULL,
   p_arg18           IN     VARCHAR2 DEFAULT NULL,
   p_arg19           IN     VARCHAR2 DEFAULT NULL,
   p_arg20           IN     VARCHAR2 DEFAULT NULL,
   p_arg21           IN     VARCHAR2 DEFAULT NULL,
   p_arg22           IN     VARCHAR2 DEFAULT NULL,
   p_arg23           IN     VARCHAR2 DEFAULT NULL,
   p_arg24           IN     VARCHAR2 DEFAULT NULL,
   p_arg25           IN     VARCHAR2 DEFAULT NULL,
   p_arg26           IN     VARCHAR2 DEFAULT NULL,
   p_arg27           IN     VARCHAR2 DEFAULT NULL,
   p_arg28           IN     VARCHAR2 DEFAULT NULL,
   p_arg29           IN     VARCHAR2 DEFAULT NULL,
   p_arg30           IN     VARCHAR2 DEFAULT NULL,
   p_arg31           IN     VARCHAR2 DEFAULT NULL,
   p_arg32           IN     VARCHAR2 DEFAULT NULL,
   p_arg33           IN     VARCHAR2 DEFAULT NULL,
   p_arg34           IN     VARCHAR2 DEFAULT NULL,
   p_arg35           IN     VARCHAR2 DEFAULT NULL,
   p_arg36           IN     VARCHAR2 DEFAULT NULL,
   p_arg37           IN     VARCHAR2 DEFAULT NULL,
   p_arg38           IN     VARCHAR2 DEFAULT NULL,
   p_arg39           IN     VARCHAR2 DEFAULT NULL,
   p_arg40           IN     VARCHAR2 DEFAULT NULL);

PROCEDURE Sub_Request
  (errbuf           OUT     NOCOPY VARCHAR2,
   retcode          OUT     NOCOPY VARCHAR2,
   p_req_id         IN      NUMBER,
   p_mp_method      IN      NUMBER,
   p_slc_type       IN      NUMBER,
   p_proc_num       IN      NUMBER,
   p_part_code      IN      NUMBER,
   p_fetch_limit    IN      NUMBER);

PROCEDURE Get_Data_Slice
  (x_slc_id       OUT     NOCOPY NUMBER,
   x_slc_val1     OUT     NOCOPY VARCHAR2,
   x_slc_val2     OUT     NOCOPY VARCHAR2,
   x_slc_val3     OUT     NOCOPY VARCHAR2,
   x_slc_val4     OUT     NOCOPY VARCHAR2,
   x_num_vals     OUT     NOCOPY NUMBER,
   x_part_name    OUT     NOCOPY VARCHAR2,
   p_req_id       IN      NUMBER,
   p_proc_num     IN      NUMBER);

PROCEDURE Post_Data_Slice
  (p_req_id       IN      NUMBER,
   p_slc_id       IN      NUMBER,
   p_status       IN      NUMBER,
   p_message      IN      VARCHAR2 DEFAULT NULL,
   p_rows_processed IN    NUMBER DEFAULT 0,
   p_rows_loaded    IN    NUMBER DEFAULT 0,
   p_rows_rejected  IN    NUMBER DEFAULT 0);

PROCEDURE Post_Subreq_Messages
  (p_req_id        IN       NUMBER);

PROCEDURE Delete_Data_Slices
  (p_req_id        IN       NUMBER);

END FEM_Multi_Proc_Pkg;

 

/
