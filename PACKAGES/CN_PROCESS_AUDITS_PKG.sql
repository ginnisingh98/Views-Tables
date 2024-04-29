--------------------------------------------------------
--  DDL for Package CN_PROCESS_AUDITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PROCESS_AUDITS_PKG" AUTHID CURRENT_USER AS
-- $Header: cnrepas.pls 120.0 2005/10/10 07:17:09 apink noship $


  --
  -- Procedure Name
  --   insert_row
  -- Purpose
  --   Insert a new record in the cn_process_audits table.
  -- History
  --   1/11/94		Devesh Khatu		Created
  --
  PROCEDURE insert_row (
	X_rowid		IN OUT	NOCOPY ROWID,
	X_process_audit_id	IN OUT	NOCOPY cn_process_audits.process_audit_id%TYPE,
	X_parent_process_audit_id	cn_process_audits.parent_process_audit_id%TYPE,
	X_process_type		cn_process_audits.process_type%TYPE,
	X_description		cn_process_audits.description%TYPE,
	X_statement_text	cn_process_audits.statement_text%TYPE,
	X_execution_code	cn_process_audits.execution_code%TYPE,
	X_error_message		cn_process_audits.error_message%TYPE,
	X_module_id		cn_process_audits.module_id%TYPE,
	X_object_id		cn_process_audits.object_id%TYPE,
	X_timestamp_start	cn_process_audits.timestamp_start%TYPE,
	X_timestamp_end		cn_process_audits.timestamp_end%TYPE,
    x_org_id cn_process_audits.org_id%TYPE);

  --
  -- Procedure Name
  --   select_row
  -- Purpose
  --   Select a row from the table, given the primary key
  -- History
  --   1/11/94		Devesh Khatu		Created
  --
  PROCEDURE select_row (
	recinfo IN OUT NOCOPY cn_process_audits%ROWTYPE);


  --
  -- Procedure Name
  --   update_row
  -- Purpose
  --   Update execution code for cn_process_audits
  -- History
  --   1/11/94		Devesh Khatu		Created
  --
  PROCEDURE update_row (
	X_process_audit_id	cn_process_audits.process_audit_id%TYPE,
	X_module_id		cn_process_audits.module_id%TYPE,
	X_timestamp_end		cn_process_audits.timestamp_end%TYPE,
	X_execution_code	cn_process_audits.execution_code%TYPE,
	X_error_message		cn_process_audits.error_message%TYPE);


END cn_process_audits_pkg;
 

/
