--------------------------------------------------------
--  DDL for Package FEM_XGL_POST_ENGINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_XGL_POST_ENGINE_PKG" AUTHID CURRENT_USER AS
/* $Header: fem_xgl_post_eng.pls 120.0.12010000.2 2009/06/27 00:33:29 ghall ship $ */

--
-- PUBLIC PROCEDURES
--

  --
  -- Procedure
  --     Main
  -- Purpose
  --     This is the main routine of the XGL Posting Engine program
  -- History
  --     10-23-03   S Kung        Created
  -- Arguments
  --    p_errbuf     : Output parameter required by
  --                   Concurrent Manager
  --    p_retcode    : Output parameter required by
  --                   Concurrent Manager
  --    p_ledger_id        : Ledger to load data for
  --    p_cal_period_id    : Period to load data for
  --    p_dataset_code     : Target dataset to load data into
  --    p_xgl_int_obj_def_id  : XGL/FEM integration rule object definition ID
  --    p_execution_mode   : Execution mode, S (Snapshot)/I (Incremental)
  --    p_qtd_ytd_code     : Specifies whether period-specific QTD and
  --                         YTD balances will be maintained
  --    p_budget_id        : Budget to be loaded
  --    p_enc_type_id      : Encumbrance type to be loaded
  --
  -- Example
  --    result := FEM_XGL_POST_ENGINE_PKG.Main( );
  -- Notes
  --
  PROCEDURE Main
             (x_errbuf              OUT NOCOPY VARCHAR2,
              x_retcode             OUT NOCOPY VARCHAR2,
              p_execution_mode      IN  VARCHAR2 DEFAULT NULL,
              p_ledger_id           IN  VARCHAR2 DEFAULT NULL,
              p_cal_period_id       IN  VARCHAR2 DEFAULT NULL,
              p_budget_id           IN  VARCHAR2 DEFAULT NULL,
              p_enc_type_id         IN  VARCHAR2 DEFAULT NULL,
              p_dataset_code        IN  VARCHAR2 DEFAULT NULL,
              p_xgl_int_obj_def_id  IN  VARCHAR2 DEFAULT NULL,
              p_qtd_ytd_code        IN  VARCHAR2 DEFAULT 'N',
              p_allow_dis_mbrs_flag IN  VARCHAR2 DEFAULT 'N');

   PROCEDURE Process_Data_Slice
              (x_slice_status_cd          OUT NOCOPY NUMBER,
               x_slice_msg                OUT NOCOPY VARCHAR2,
               x_slice_errors_reprocessed OUT NOCOPY NUMBER,
               x_slice_output_rows        OUT NOCOPY NUMBER,
               x_slice_errors_reported    OUT NOCOPY NUMBER,
               p_eng_sql                  IN  VARCHAR2,
               p_data_slice_predicate     IN  VARCHAR2,
               p_process_number           IN  NUMBER,
               p_slice_id                 IN  NUMBER,
               p_fetch_limit              IN  NUMBER,
               p_req_id                   IN  VARCHAR2,
               p_exec_mode                IN  VARCHAR2,
               p_rule_obj_id              IN  VARCHAR2,
               p_dataset_code             IN  VARCHAR2,
               p_cal_period_id            IN  VARCHAR2,
               p_ledger_id                IN  VARCHAR2,
               p_qtd_ytd_code             IN  VARCHAR2,
               p_entered_crncy_flag       IN  VARCHAR2,
               p_cal_per_dim_grp_dsp_cd   IN  VARCHAR2,
               p_cal_per_end_date         IN  VARCHAR2,
               p_gl_per_number            IN  VARCHAR2,
               p_ledger_dsp_cd            IN  VARCHAR2,
               p_budget_dsp_cd            IN  VARCHAR2,
               p_enc_type_dsp_cd          IN  VARCHAR2,
               p_ds_balance_type_cd       IN  VARCHAR2,
               p_schema_name              IN  VARCHAR2,
               p_allow_dis_mbrs_flag      IN  VARCHAR2);

END FEM_XGL_POST_ENGINE_PKG;

/
