--------------------------------------------------------
--  DDL for Package Body CN_PROCESS_AUDITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PROCESS_AUDITS_PKG" AS
-- $Header: cnrepab.pls 120.0 2005/10/10 07:17:33 apink noship $


  --
  -- Public Procedures
  --

  --
  -- Procedure Name
  --   insert_row
  -- History
  --   1/11/94           Devesh Khatu		Created
  --
  PROCEDURE insert_row (
	X_rowid		IN OUT	NOCOPY ROWID,
	X_process_audit_id	IN OUT NOCOPY	cn_process_audits.process_audit_id%TYPE,
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
    x_org_id cn_process_audits.org_id%TYPE) IS

  BEGIN

    IF (X_process_audit_id IS NULL) THEN
      SELECT cn_process_audits_s.NEXTVAL
        INTO X_process_audit_id
        FROM dual;
    END IF;

    INSERT INTO cn_process_audits (
	process_audit_id,
	parent_process_audit_id,
	process_type,
	description,
	statement_text,
	execution_code,
	error_message,
	module_id,
	object_id,
	timestamp_start,
	timestamp_end,
    org_id)
      VALUES (
	X_process_audit_id,
	X_parent_process_audit_id,
	X_process_type,
	X_description,
	X_statement_text,
	X_execution_code,
	X_error_message,
	X_module_id,
	X_object_id,
	X_timestamp_start,
	X_timestamp_end,
    x_org_id);

    SELECT ROWID
      INTO X_rowid
      FROM cn_process_audits
     WHERE process_audit_id = X_process_audit_id;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END insert_row;


  --
  -- Procedure Name
  --   select_row
  -- History
  --   1/11/94           Devesh Khatu		Created
  --
  PROCEDURE select_row (
	recinfo IN OUT NOCOPY cn_process_audits%ROWTYPE) IS
  BEGIN
    -- select row based on process_id (primary key)
    IF (recinfo.process_audit_id IS NOT NULL) THEN

      SELECT * INTO recinfo
        FROM cn_process_audits cpa
       WHERE cpa.process_audit_id = recinfo.process_audit_id;

    END IF;
  END select_row;



  --
  -- Procedure Name
  --   update_row
  -- History
  --   1/11/94           Devesh Khatu		Created
  --
  PROCEDURE update_row (
	X_process_audit_id		cn_process_audits.process_audit_id%TYPE,
	X_module_id		cn_process_audits.module_id%TYPE,
	X_timestamp_end		cn_process_audits.timestamp_end%TYPE,
	X_execution_code	cn_process_audits.execution_code%TYPE,
	X_error_message		cn_process_audits.error_message%TYPE) IS

  BEGIN

    UPDATE cn_process_audits
       SET module_id	    = X_module_id,
           timestamp_end    = X_timestamp_end,
	   execution_code   = X_execution_code,
           error_message    = X_error_message
     WHERE process_audit_id = X_process_audit_id;

    IF (SQL%NOTFOUND) then
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


END cn_process_audits_pkg;

/
