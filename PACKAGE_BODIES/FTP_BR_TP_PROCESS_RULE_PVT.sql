--------------------------------------------------------
--  DDL for Package Body FTP_BR_TP_PROCESS_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTP_BR_TP_PROCESS_RULE_PVT" AS
/* $Header: ftpbtprb.pls 120.0 2005/06/06 19:21:13 appldev noship $ */

--------------------------------------------------------------------------------
-- PRIVATE CONSTANTS
--------------------------------------------------------------------------------
G_PKG_NAME constant varchar2(30) := 'FTP_BR_TP_PROCESS_RULE_PVT';
--------------------------------------------------------------------------------
-- PRIVATE SPECIFICATIONS
--------------------------------------------------------------------------------
PROCEDURE DeleteTpProcessRuleRec(
  p_obj_def_id          in          number
);
PROCEDURE DeleteTpStochAssumpRecs(
  p_obj_def_id          in          number
);
PROCEDURE DeleteMigrationColumnRecs(
  p_obj_def_id          in          number
);
PROCEDURE DeleteProcessTableRecs(
  p_obj_def_id          in          number
);
PROCEDURE CopyTpProcessRuleRec(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);
PROCEDURE CopyTpStochAssumpRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);
PROCEDURE CopyMigrationColumnRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);
PROCEDURE CopyProcessTableRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);
--------------------------------------------------------------------------------
-- PUBLIC BODIES
--------------------------------------------------------------------------------
--
-- PROCEDURE
--	 DeleteObjectDefinition
--
-- DESCRIPTION
--   Deletes all the details records of a TP Process Rule Definition.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteObjectDefinition(
  p_obj_def_id          in          number
)
--------------------------------------------------------------------------------
IS
  g_api_name    constant varchar2(30)   := 'DeleteObjectDefinition';
BEGIN
  DeleteProcessTableRecs(
    p_obj_def_id     => p_obj_def_id
  );
  DeleteMigrationColumnRecs(
    p_obj_def_id     => p_obj_def_id
  );
  DeleteTpStochAssumpRecs(
    p_obj_def_id     => p_obj_def_id
  );
  DeleteTpProcessRuleRec(
    p_obj_def_id     => p_obj_def_id
  );
EXCEPTION
  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, g_api_name);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
END DeleteObjectDefinition;
--
-- PROCEDURE
--	 CopyObjectDefinition
--
-- DESCRIPTION
--   Creates all the detail records of a new TP Process Rule Definition (target)
--   by copying the detail records of another TP Process Rule Definition (source).
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyObjectDefinition(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS
  g_api_name    constant varchar2(30)   := 'CopyObjectDefinition';
BEGIN
  CopyTpProcessRuleRec(
    p_source_obj_def_id   => p_source_obj_def_id
    ,p_target_obj_def_id  => p_target_obj_def_id
    ,p_created_by         => p_created_by
    ,p_creation_date      => p_creation_date
  );
  CopyTpStochAssumpRecs(
    p_source_obj_def_id   => p_source_obj_def_id
    ,p_target_obj_def_id  => p_target_obj_def_id
    ,p_created_by         => p_created_by
    ,p_creation_date      => p_creation_date
  );
  CopyMigrationColumnRecs(
    p_source_obj_def_id   => p_source_obj_def_id
    ,p_target_obj_def_id  => p_target_obj_def_id
    ,p_created_by         => p_created_by
    ,p_creation_date      => p_creation_date
  );
  CopyProcessTableRecs(
    p_source_obj_def_id   => p_source_obj_def_id
    ,p_target_obj_def_id  => p_target_obj_def_id
    ,p_created_by         => p_created_by
    ,p_creation_date      => p_creation_date
  );
EXCEPTION
  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, g_api_name);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
END CopyObjectDefinition;
--------------------------------------------------------------------------------
-- PRIVATE BODIES
--------------------------------------------------------------------------------
--
-- PROCEDURE
--	 DeleteTpProcessRuleRec
--
-- DESCRIPTION
--   Deletes a TP Process Rule Definition by performing deletes on records
--   in the FTP_TP_PROCESS_RULE table.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteTpProcessRuleRec(
  p_obj_def_id in number
)
--------------------------------------------------------------------------------
IS
BEGIN
  delete from ftp_tp_process_rule
  where object_definition_id = p_obj_def_id;
END DeleteTpProcessRuleRec;
--
-- PROCEDURE
--	 DeleteTpStochAssumpRecs
--
-- DESCRIPTION
--   Deletes Tp Process Rule by performing deletes on records
--   in the FTP_TP_STOCH_ASSUMP table.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteTpStochAssumpRecs(
  p_obj_def_id in number
)
--------------------------------------------------------------------------------
IS
BEGIN
  delete from ftp_tp_stoch_assump
  where object_definition_id = p_obj_def_id;
END DeleteTpStochAssumpRecs;
--
-- PROCEDURE
--	 DeleteMigrationColumnRecs
--
-- DESCRIPTION
--   Delete TP Process Rule Definition Migration Columns by performing deletes on records
--   in the FTP_TP_SELCTD_COLUMNS table.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteMigrationColumnRecs(
  p_obj_def_id in number
)
--------------------------------------------------------------------------------
IS
BEGIN
  delete from ftp_tp_selctd_columns
  where object_definition_id = p_obj_def_id;
END DeleteMigrationColumnRecs;
--
-- PROCEDURE
--	 DeleteProcessTableRecs
--
-- DESCRIPTION
--   Delete TP Process Rule Definition Process Tables by performing deletes on records
--   in the FTP_TP_PROCESS_TABLES table.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteProcessTableRecs(
  p_obj_def_id in number
)
--------------------------------------------------------------------------------
IS
BEGIN
  delete from ftp_tp_process_tables
  where object_definition_id = p_obj_def_id;
END DeleteProcessTableRecs;
--
-- PROCEDURE
--	 CopyTpProcessRuleRec
--
-- DESCRIPTION
--   Creates a new TP Process Rule Definition by copying records in the
--   FTP_TP_PROCESS_RULE table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyTpProcessRuleRec(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS
BEGIN
  insert into ftp_tp_process_rule (
        object_definition_id
        ,calc_mode_code
        ,transfer_price_object_id
        ,prepay_object_id
        ,filter_object_id
        ,dtl_cashflow_flg
        ,skip_nonzero_trans_rate_flg
        ,skip_nonzero_opt_cost_flg
        ,trans_rate_propagate_flg
        ,trans_rate_calc_flg
        ,trans_rate_migrate_flg
        ,option_cost_propagate_flg
        ,option_cost_calc_flg
        ,option_cost_migrate_flg
        ,write_forward_rate_flg
        ,accrual_code
        ,currency_flg
        ,creation_date
        ,created_by
        ,last_updated_by
        ,last_update_date
        ,last_update_login
        ,object_version_number
  ) select
         p_target_obj_def_id
        ,calc_mode_code
        ,transfer_price_object_id
        ,prepay_object_id
        ,filter_object_id
        ,dtl_cashflow_flg
        ,skip_nonzero_trans_rate_flg
        ,skip_nonzero_opt_cost_flg
        ,trans_rate_propagate_flg
        ,trans_rate_calc_flg
        ,trans_rate_migrate_flg
        ,option_cost_propagate_flg
        ,option_cost_calc_flg
        ,option_cost_migrate_flg
        ,write_forward_rate_flg
        ,accrual_code
        ,currency_flg
        ,nvl(p_creation_date,creation_date)
        ,nvl(p_created_by,created_by)
        ,FND_GLOBAL.user_id
        ,sysdate
        ,FND_GLOBAL.login_id
        ,object_version_number
  from ftp_tp_process_rule
  where object_definition_id = p_source_obj_def_id;
END CopyTpProcessRuleRec;
--
-- PROCEDURE
--	 CopyTpStochAssumpRecs
--
-- DESCRIPTION
--   Creates a new TP Process Rule Definition Tp Stochiastic Assumptions by copying records in the
--   FTP_TP_STOCH_ASSUMP table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyTpStochAssumpRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS
BEGIN
  insert into ftp_tp_stoch_assump (
        object_definition_id
        ,rate_index_object_id
        ,num_of_rate_path
        ,rand_seq_type_code
        ,ts_model_code
        ,smoothing_method_code
        ,write_1mn_rate_flg
        ,creation_date
        ,created_by
        ,last_updated_by
        ,last_update_date
        ,last_update_login
        ,object_version_number
        ,valuation_curve_code
  ) select
        p_target_obj_def_id
        ,rate_index_object_id
        ,num_of_rate_path
        ,rand_seq_type_code
        ,ts_model_code
        ,smoothing_method_code
        ,write_1mn_rate_flg
        ,nvl(p_creation_date,creation_date)
        ,nvl(p_created_by,created_by)
        ,FND_GLOBAL.user_id
        ,sysdate
        ,FND_GLOBAL.login_id
        ,object_version_number
        ,valuation_curve_code
  from ftp_tp_stoch_assump
  where object_definition_id = p_source_obj_def_id;
END CopyTpStochAssumpRecs;
--
-- PROCEDURE
--	 CopyMigrationColumnRecs
--
-- DESCRIPTION
--   Creates new TP Process Rule Definition Migration Columns by copying records in the
--   FTP_TP_SELCTD_COLUMNS table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyMigrationColumnRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS
BEGIN
  insert into ftp_tp_selctd_columns(
        object_definition_id
        ,column_id
        ,creation_date
        ,created_by
        ,last_updated_by
        ,last_update_date
        ,last_update_login
        ,object_version_number
  ) select
        p_target_obj_def_id
        ,column_id
        ,nvl(p_creation_date,creation_date)
        ,nvl(p_created_by,created_by)
        ,FND_GLOBAL.user_id
        ,sysdate
        ,FND_GLOBAL.login_id
        ,object_version_number
  from ftp_tp_selctd_columns
  where object_definition_id = p_source_obj_def_id;
END CopyMigrationColumnRecs;
--
-- PROCEDURE
--	 CopyProcessTableRecs
--
-- DESCRIPTION
--   Creates new TP Process Rule Definition Process Tables by copying records in the
--   FTP_TP_PROCESS_TABLES table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyProcessTableRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS
BEGIN
  insert into ftp_tp_process_tables(
        object_definition_id
        ,table_name
        ,creation_date
        ,created_by
        ,last_updated_by
        ,last_update_date
        ,last_update_login
        ,object_version_number
  ) select
         p_target_obj_def_id
        ,table_name
        ,nvl(p_creation_date,creation_date)
        ,nvl(p_created_by,created_by)
        ,FND_GLOBAL.user_id
        ,sysdate
        ,FND_GLOBAL.login_id
        ,object_version_number
  from ftp_tp_process_tables
  where object_definition_id = p_source_obj_def_id;
END CopyProcessTableRecs;
END FTP_BR_TP_PROCESS_RULE_PVT;

/
