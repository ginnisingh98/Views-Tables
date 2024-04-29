--------------------------------------------------------
--  DDL for Package CE_STATEMENT_RECONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_STATEMENT_RECONS_PKG" AUTHID CURRENT_USER AS
/* $Header: cestmres.pls 120.2 2004/09/02 22:55:52 lkwan ship $ */
--
-- Package
--   ce_statement_recons_pkg
-- Purpose
--   To contain routines for ce_statement_recons
-- History
--   04-08-95   Kai Pigg        Created
  G_spec_revision 	VARCHAR2(1000) := '$Revision: 120.2 $';

  FUNCTION spec_revision RETURN VARCHAR2;

  FUNCTION body_revision RETURN VARCHAR2;

  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Checks to make sure that the reconciliation inserted
  --   is unique.
  -- History
  --   04-08-95  Kai Pigg    Created
  -- Arguments
  --   X_statement_line_id 	NUMBER
  --   X_reference_type    	VARCHAR2
  --   X_reference_id      	NUMBER
  --   X_currenct_record_flag 	VARCHAR2
  --   X_row_id            	VARCHAR2
  --
  -- Example
  --   ce_statement_recons_pkg.check_unique(...);
  -- Notes
  --
  PROCEDURE check_unique(X_statement_line_id 	NUMBER,
                         X_reference_type    	VARCHAR2,
                         X_reference_id 	VARCHAR2,
                         X_current_record_flag 	VARCHAR2,
                         X_row_id 		VARCHAR2);
  --
  -- Procedure
  --  Insert_Row
  -- Purpose
  --   Inserts a row into ce_statement_reconciliations
  -- History
  --   04-08-95  Kai Pigg       Created
  -- Arguments
  -- all the columns of the table CE_STATEMENT_RECONCILIATIONS
  -- Example
  --   ce_statement_recons_pkg.Insert_Row(....;
  -- Notes
  --
  PROCEDURE Insert_Row( X_Row_id                         IN OUT NOCOPY VARCHAR2,
			X_statement_line_id		NUMBER,
              		X_reference_type		VARCHAR2,
              		X_reference_id			NUMBER,
			X_org_id			NUMBER,
			X_legal_entity_id		NUMBER,
			X_reference_status		VARCHAR2,
			X_amount			NUMBER	DEFAULT NULL,
              		X_status_flag			VARCHAR2,
			X_action_flag			VARCHAR2,
              		X_current_record_flag		VARCHAR2,
              		X_auto_reconciled_flag		VARCHAR2,
			X_created_by			NUMBER,
			X_creation_date			DATE,
			X_last_updated_by		NUMBER,
			X_last_update_date		DATE,
			X_request_id			NUMBER 	DEFAULT NULL,
			X_program_application_id	NUMBER 	DEFAULT NULL,
			X_program_id			NUMBER 	DEFAULT NULL,
			X_program_update_date		DATE 	DEFAULT NULL);

  PROCEDURE Insert_Row( X_Row_id                         IN OUT NOCOPY VARCHAR2,
			X_statement_line_id		NUMBER,
              		X_reference_type		VARCHAR2,
              		X_reference_id			NUMBER,
			X_je_header_id			NUMBER,
			X_org_id			NUMBER,
			X_legal_entity_id		NUMBER,
			X_reference_status		VARCHAR2,
			X_amount                        NUMBER  DEFAULT NULL,
              		X_status_flag			VARCHAR2,
			X_action_flag			VARCHAR2,
              		X_current_record_flag		VARCHAR2,
              		X_auto_reconciled_flag		VARCHAR2,
			X_created_by			NUMBER,
			X_creation_date			DATE,
			X_last_updated_by		NUMBER,
			X_last_update_date		DATE,
			X_request_id			NUMBER 	DEFAULT NULL,
			X_program_application_id	NUMBER 	DEFAULT NULL,
			X_program_id			NUMBER 	DEFAULT NULL,
			X_program_update_date		DATE 	DEFAULT NULL);
  --
  -- Procedure
  --  Update_Row
  -- Purpose
  --   Updates a row into ce_statement_reconciliations
  -- History
  --   04-08-95  Kai Pigg       Created
  -- Arguments
  -- all the columns of the table CE_STATEMENT_RECONCILIATIONS
  -- Example
  --   ce_statement_recons_pkg.Update_Row(....;
  -- Notes
  --
  PROCEDURE Update_Row( X_Row_id                         IN OUT NOCOPY VARCHAR2,
			X_statement_line_id		NUMBER,
              		X_reference_type		VARCHAR2,
              		X_reference_id			NUMBER,
              		X_status			VARCHAR2,
              		X_cleared_when_matched		VARCHAR2,
              		X_current_record_flag		VARCHAR2,
              		X_auto_reconciled_flag		VARCHAR2,
              		X_created_by			NUMBER,
              		X_creation_date			DATE,
              		X_last_updated_by		NUMBER,
              		X_last_update_date		DATE);


  --
  -- Procedure
  --  Lock_Row
  -- Purpose
  --   Locks a row into ce_statement_reconciliations
  -- History
  --   04-08-95  Kai Pigg       Created
  -- Arguments
  -- all the columns of the table CE_STATEMENT_RECONCILIATIONS
  -- Example
  --   ce_statement_recons_pkg.Lock_Row(....;
  -- Notes
  --
  PROCEDURE Lock_Row  ( X_Row_id                         IN OUT NOCOPY VARCHAR2,
			X_statement_line_id		NUMBER,
              		X_reference_type		VARCHAR2,
              		X_reference_id			NUMBER,
              		X_status			VARCHAR2,
              		X_cleared_when_matched		VARCHAR2,
              		X_current_record_flag		VARCHAR2,
              		X_auto_reconciled_flag		VARCHAR2);

  --
  -- Procedure
  --  Delete_Row
  -- Purpose
  --   Deletes a row from ce_statement_reconciliations
  -- History
  --   04-08-95  Kai Pigg       Created
  -- Arguments
  --    X_row_id         Rowid of a row
  -- Example
  --   ce_statement_recons_pkg.delete_row('ajfdshj');
  -- Notes
  --
  PROCEDURE Delete_Row(X_Row_id VARCHAR2);

END ce_statement_recons_pkg;

 

/
