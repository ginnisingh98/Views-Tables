--------------------------------------------------------
--  DDL for Package FTP_TP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTP_TP_PKG" AUTHID CURRENT_USER as
/* $Header: FTPEFTPS.pls 120.5 2006/12/05 05:36:34 rknanda noship $ */
  -- create or validate map of tp and pp assumptions to appropriate
  -- nodes in the hierarchies used.
  procedure VALIDATE_NODE_MAP(
    OBJ_ID in number,
    REQ_ID in number,
    EFFECTIVE_DATE in date,
    NODE_MAP_ID out nocopy number,
    DIM_COL_NAME out nocopy varchar2
  );

  -- return the appropirate instrument table columns
  -- to update given the tp process id (to allow for
  -- future expansion to support multiple transfer rate
  -- columns.
  procedure GET_TP_OUT_COLS(
    obj_id in number,
    data_set_id in number,
    jobid  in number,
    effective_date in date,
    TRATE_COL out nocopy varchar2,
    MSPREAD_COL out nocopy varchar2,
    OAS_COL out nocopy varchar2,
    SS_COL out nocopy varchar2,
    LAST_OBJID_COL out nocopy varchar2,
    LAST_REQID_COL out nocopy varchar2
  );

  procedure REGISTER_TP_PROCESS(
    OBJ_ID in number,
    LEDGER_ID In number,
    EFFECTIVE_DATE in date,
    PROCESS_PARAM_ID out NOCOPY number
  );

  -- return information for joining ftp_pp_node_map to
  -- attribute table to get account type.
  -- aliases needed to properly generate where clause.
  procedure ACCT_TYPE_JOIN_INFO(
    TBL_ALIAS in varchar2, -- alias of main table
    TBL_JOIN_ALIAS in varchar2, -- alias of attribute table
    JOIN_TBL_NAME out NOCOPY varchar2, -- table to join to
    ATTR_COL_NAME out NOCOPY varchar2, -- attribute column to select
    IS_ASSET_DECODE out NOCOPY varchar2, -- decode to determine if asset/liab
    WHERE_CLAUSE out NOCOPY varchar2   -- where clause for join
  );

  -- return information for joining ftp_pp_node_map to
  -- attribute table to get account type.
  -- aliases needed to properly generate where clause.
  procedure CHG_CRDT_ACC_BASIS_JOIN(
    TBL_ALIAS in varchar2, -- alias of main table
    TBL_JOIN_ALIAS in varchar2, -- alias of attribute table
    JOIN_TBL_NAME out NOCOPY varchar2, -- table to join to
    ATTR_COL_NAME out NOCOPY varchar2, -- attribute column to select
    ACCR_DECODE out NOCOPY varchar2, -- decode to determine if asset/liab
    WHERE_CLAUSE out NOCOPY varchar2   -- where clause for join
  );

  PROCEDURE GET_VALUESETS_INFO(
     OBJ_ID in number,
     EFFECTIVE_DATE in date,
     LN_ITEM_VAL_SET out NOCOPY number,
     ORG_VAL_SET     out NOCOPY number,
     SOURCE_SYS_CD   out NOCOPY number
  );

  PROCEDURE START_PROCESS_LOCKS(
   p_request_id      IN    NUMBER,
   p_object_id       IN    NUMBER,
   p_cal_period_id   IN    NUMBER,
   p_ledger_id       IN    NUMBER,
   p_dataset_def_id  IN    NUMBER,
   p_job_id          IN    NUMBER,
   p_condition_id    IN    NUMBER,
   p_effective_date  IN    DATE,
   p_user_id         IN    NUMBER,
   p_last_update_login      IN  NUMBER,
   p_program_id             IN  NUMBER,
   p_program_login_id       IN  NUMBER,
   p_program_application_id IN  NUMBER,
   x_exec_lock_exists   OUT NOCOPY  VARCHAR2,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2
  );

  PROCEDURE STOP_PROCESS_LOCKS(
   p_request_id      IN    NUMBER,
   p_object_id       IN    NUMBER,
   p_cal_period_id   IN    NUMBER,
   p_ledger_id       IN    NUMBER,
   p_dataset_def_id  IN    NUMBER,
   p_exec_status_code IN   VARCHAR2,
   p_job_id          IN    NUMBER,
   p_condition_id    IN    NUMBER,
   p_effective_date  IN    DATE,
   p_user_id         IN    NUMBER,
   p_last_update_login        IN    NUMBER,
   x_return_status   OUT NOCOPY  VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2
  );

  PROCEDURE LEDGER_PROCESSING(
   p_request_id      IN    NUMBER,
   p_object_id       IN    NUMBER,
   p_cal_period_id   IN    NUMBER,
   p_ledger_id       IN    NUMBER,
   p_dataset_def_id  IN    NUMBER,
   p_job_id          IN    NUMBER,
   p_condition_id    IN    NUMBER,
   p_effective_date  IN    DATE,
   p_user_id         IN    NUMBER,
   p_last_update_login        IN    NUMBER,
   x_exec_lock_exists   OUT NOCOPY  VARCHAR2,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2
  );

  PROCEDURE CHAINING_EXISTS(
   p_request_id      IN    NUMBER,
   p_object_id       IN    NUMBER,
   p_cal_period_id   IN    NUMBER,
   p_ledger_id       IN    NUMBER,
   p_dataset_def_id  IN    NUMBER,
   p_condition_str   IN    VARCHAR2,
   p_effective_date  IN    DATE,
   p_table_name      IN    VARCHAR2,
   x_exec_lock_exists   OUT NOCOPY  VARCHAR2
  );

  procedure GET_VALID_TABLE_LIST(
    obj_id in number,
    jobid  in number,
    effective_date in date,
    new_valid_table_list out nocopy varchar2,
    LAST_OBJID_COL out nocopy varchar2,
    LAST_REQID_COL out nocopy varchar2,
    x_return_status   OUT NOCOPY  VARCHAR2,
    x_msg_count       OUT NOCOPY NUMBER,
    x_msg_data        OUT NOCOPY VARCHAR2
  );

  PROCEDURE VERIFY_VALID_COLUMN(
    rate_output_rule_obj_id IN NUMBER,
    p_col_name IN   VARCHAR2,
    p_col_value IN   VARCHAR2,
    p_table_name  IN    VARCHAR2,
    valid_flg IN OUT NOCOPY BOOLEAN
);
end FTP_TP_PKG;


/
