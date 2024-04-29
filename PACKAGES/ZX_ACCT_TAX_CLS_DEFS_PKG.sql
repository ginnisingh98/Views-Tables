--------------------------------------------------------
--  DDL for Package ZX_ACCT_TAX_CLS_DEFS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_ACCT_TAX_CLS_DEFS_PKG" AUTHID CURRENT_USER AS
/* $Header: zxgltcds.pls 120.1 2005/07/06 12:03:27 mparihar noship $ */
--
-- Package
--   zx_account_tax_rates_pkg
-- Purpose
--   To implement various data checking needed for the
--   gl_tax_options table
-- History
--   24-NOV-04	Tai-Hyun Won		Created
--

  --
  -- Procedure
  --   select_columns
  -- Purpose
  --   Gets the values of some columns from zx_acct_tx_cls_defs_all associated
  --   with the given ledger and organization.
  -- History
  --
  -- Arguments
  --   x_ledger_id			ID of the current ledger
  --   x_org_id				ID of the current organization

  PROCEDURE select_columns(
	      x_ledger_id			NUMBER,
	      x_org_id				NUMBER,
	      x_tax_class			IN OUT NOCOPY	VARCHAR2,
	      x_tax_classification_code		IN OUT NOCOPY 	VARCHAR2);


  --
  -- Procedure
  --   duplicate_tax_class_code
  --
  -- Purpose
  --   Check if another record for the same ledger id and org id exists
  --
  -- History
  --
  --
  -- Arguments
  --   x_ledger_id			ID of the current ledger
  --   x_org_id				ID of the current organization
  --   x_rowid				Row ID
  --
  PROCEDURE duplicate_tax_class_code(
	      x_ledger_id               NUMBER,
	      x_org_id                  NUMBER,
	      x_rowid                   VARCHAR2);


  --
  -- Procedure
  --   org_name
  --
  -- Purpose
  --   Gets the name of the current organization
  --
  -- History
  --
  --
  -- Arguments
  --   x_org_id 			ID of the current organization
  --   x_org_name		        Name of the current organization
  --
  PROCEDURE org_name(
	      x_org_id			   	NUMBER,
	      x_org_name			IN OUT NOCOPY  VARCHAR2);


  --
  -- Procedure
  --   insert_row
  -- Purpose
  --
  -- History
  --   24-Nov-04  Tai-Hyun Won       Created
  --
  PROCEDURE insert_row(
                X_LEDGER_ID                       NUMBER,
                X_ORG_ID                          NUMBER,
                X_ACCOUNT_SEGMENT_VALUE           VARCHAR2,
                X_TAX_CLASS                       VARCHAR2,
                X_TAX_CLASSIFICATION_CODE         VARCHAR2,
                X_ALLOW_TAX_CODE_OVERRIDE_FLAG    VARCHAR2,
                X_RECORD_TYPE_CODE                VARCHAR2,
                X_CREATION_DATE                   DATE,
                X_CREATED_BY                      NUMBER,
                X_LAST_UPDATED_BY                 NUMBER,
                X_LAST_UPDATE_DATE                DATE,
                X_LAST_UPDATE_LOGIN               NUMBER,
                X_ATTRIBUTE_CATEGORY              VARCHAR2,
                X_ATTRIBUTE1                      VARCHAR2,
                X_ATTRIBUTE2                      VARCHAR2,
                X_ATTRIBUTE3                      VARCHAR2,
                X_ATTRIBUTE4                      VARCHAR2,
                X_ATTRIBUTE5                      VARCHAR2,
                X_ATTRIBUTE6                      VARCHAR2,
                X_ATTRIBUTE7                      VARCHAR2,
                X_ATTRIBUTE8                      VARCHAR2,
                X_ATTRIBUTE9                      VARCHAR2,
                X_ATTRIBUTE10                     VARCHAR2,
                X_ATTRIBUTE11                     VARCHAR2,
                X_ATTRIBUTE12                     VARCHAR2,
                X_ATTRIBUTE13                     VARCHAR2,
                X_ATTRIBUTE14                     VARCHAR2,
                X_ATTRIBUTE15                     VARCHAR2);

  --
  -- Procedure
  --   update_row
  -- Purpose
  --
  -- History
  --   24-Nov-04  Tai-Hyun Won       Created
  --
  PROCEDURE update_row(
                X_LEDGER_ID                       NUMBER,
                X_ORG_ID                          NUMBER,
                X_ACCOUNT_SEGMENT_VALUE           VARCHAR2,
                X_TAX_CLASS                       VARCHAR2,
                X_TAX_CLASSIFICATION_CODE         VARCHAR2,
                X_ALLOW_TAX_CODE_OVERRIDE_FLAG    VARCHAR2,
                X_RECORD_TYPE_CODE                VARCHAR2,
                X_CREATION_DATE                   DATE,
                X_CREATED_BY                      NUMBER,
                X_LAST_UPDATED_BY                 NUMBER,
                X_LAST_UPDATE_DATE                DATE,
                X_LAST_UPDATE_LOGIN               NUMBER,
                X_ATTRIBUTE_CATEGORY              VARCHAR2,
                X_ATTRIBUTE1                      VARCHAR2,
                X_ATTRIBUTE2                      VARCHAR2,
                X_ATTRIBUTE3                      VARCHAR2,
                X_ATTRIBUTE4                      VARCHAR2,
                X_ATTRIBUTE5                      VARCHAR2,
                X_ATTRIBUTE6                      VARCHAR2,
                X_ATTRIBUTE7                      VARCHAR2,
                X_ATTRIBUTE8                      VARCHAR2,
                X_ATTRIBUTE9                      VARCHAR2,
                X_ATTRIBUTE10                     VARCHAR2,
                X_ATTRIBUTE11                     VARCHAR2,
                X_ATTRIBUTE12                     VARCHAR2,
                X_ATTRIBUTE13                     VARCHAR2,
                X_ATTRIBUTE14                     VARCHAR2,
                X_ATTRIBUTE15                     VARCHAR2,
                X_ACCOUNT_SEGMENT_VALUE_ORIG      VARCHAR2,
                X_TAX_CLASS_ORIG		  VARCHAR2);

  --
  -- Procedure
  --   lock_row
  -- Purpose
  --
  -- History
  --   24-Nov-04  Tai-Hyun Won       Created
  --
  PROCEDURE lock_row(
                X_LEDGER_ID                       NUMBER,
                X_ORG_ID                          NUMBER,
                X_ACCOUNT_SEGMENT_VALUE           VARCHAR2,
                X_TAX_CLASS                       VARCHAR2,
                X_TAX_CLASSIFICATION_CODE         VARCHAR2,
                X_ALLOW_TAX_CODE_OVERRIDE_FLAG    VARCHAR2,
                X_RECORD_TYPE_CODE                VARCHAR2,
                X_CREATION_DATE                   DATE,
                X_CREATED_BY                      NUMBER,
                X_LAST_UPDATED_BY                 NUMBER,
                X_LAST_UPDATE_DATE                DATE,
                X_LAST_UPDATE_LOGIN               NUMBER,
                X_ATTRIBUTE_CATEGORY              VARCHAR2,
                X_ATTRIBUTE1                      VARCHAR2,
                X_ATTRIBUTE2                      VARCHAR2,
                X_ATTRIBUTE3                      VARCHAR2,
                X_ATTRIBUTE4                      VARCHAR2,
                X_ATTRIBUTE5                      VARCHAR2,
                X_ATTRIBUTE6                      VARCHAR2,
                X_ATTRIBUTE7                      VARCHAR2,
                X_ATTRIBUTE8                      VARCHAR2,
                X_ATTRIBUTE9                      VARCHAR2,
                X_ATTRIBUTE10                     VARCHAR2,
                X_ATTRIBUTE11                     VARCHAR2,
                X_ATTRIBUTE12                     VARCHAR2,
                X_ATTRIBUTE13                     VARCHAR2,
                X_ATTRIBUTE14                     VARCHAR2,
                X_ATTRIBUTE15                     VARCHAR2);

END zx_acct_tax_cls_defs_pkg;

 

/
