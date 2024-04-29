--------------------------------------------------------
--  DDL for Package ZX_ACCOUNT_TAX_RATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_ACCOUNT_TAX_RATES_PKG" AUTHID CURRENT_USER AS
/* $Header: zxglatrs.pls 120.2 2005/09/30 17:29:46 mparihar noship $ */
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
  --   Gets the values of some columns from zx_account_rates associated
  --   with the given ledger and content owner.
  -- History
  --   24-NOV-04  Tai-Hyun Won     Created.
  -- Arguments
  --   x_ledger_id			ID of the current ledger
  --   x_content_owner_id		ID of the current Content Owner
  --   x_tax_precision			Tax precision
  --   x_tax_mau			Tax mau
  PROCEDURE select_columns(
	      x_ledger_id				NUMBER,
	      x_content_owner_id			NUMBER,
	      x_tax_precision			IN OUT NOCOPY	NUMBER,
	      x_tax_mau				IN OUT NOCOPY 	NUMBER);


  --
  -- Procedure
  --   duplicate_tax_options
  --
  -- Purpose
  --   Check if another record for the same ledger id and org id exists
  --
  -- History
  --
  --
  -- Arguments
  --   x_ledger_id			ID of the current Ledger
  --   x_content_owner_id		ID of the current Content Owner
  --   x_rowid				Row ID
  --
  PROCEDURE duplicate_tax_options(
	      x_ledger_id               NUMBER,
	      x_content_owner_id        NUMBER,
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
                X_CONTENT_OWNER_ID                NUMBER,
                X_ACCOUNT_SEGMENT_VALUE           VARCHAR2,
                X_TAX_PRECISION                   NUMBER,
                X_CALCULATION_LEVEL_CODE          VARCHAR2,
                X_ALLOW_RATE_OVERRIDE_FLAG        VARCHAR2,
                X_TAX_MAU                         NUMBER,
                X_TAX_CURRENCY_CODE               VARCHAR2,
                X_TAX_CLASS                       VARCHAR2,
                X_TAX_REGIME_CODE                 VARCHAR2,
                X_TAX                             VARCHAR2,
                X_TAX_STATUS_CODE                 VARCHAR2,
                X_TAX_RATE_CODE                   VARCHAR2,
                X_ROUNDING_RULE_CODE              VARCHAR2,
                X_AMT_INCL_TAX_FLAG               VARCHAR2,
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
                X_ALLOW_ROUNDING_OVERRIDE_FLAG	  VARCHAR2);

  --
  -- Procedure
  --   update_row
  -- Purpose
  --
  -- History
  --   24-Nov-04  Tai-Hyun Won       Created
  --
  PROCEDURE update_row(
                X_RECORD_LEVEL 			  VARCHAR2,
                X_LEDGER_ID                       NUMBER,
                X_CONTENT_OWNER_ID                NUMBER,
                X_ACCOUNT_SEGMENT_VALUE           VARCHAR2,
                X_TAX_PRECISION                   NUMBER,
                X_CALCULATION_LEVEL_CODE          VARCHAR2,
                X_ALLOW_RATE_OVERRIDE_FLAG        VARCHAR2,
                X_TAX_MAU                         NUMBER,
                X_TAX_CURRENCY_CODE               VARCHAR2,
                X_TAX_CLASS                       VARCHAR2,
                X_TAX_REGIME_CODE                 VARCHAR2,
                X_TAX                             VARCHAR2,
                X_TAX_STATUS_CODE                 VARCHAR2,
                X_TAX_RATE_CODE                   VARCHAR2,
                X_ROUNDING_RULE_CODE              VARCHAR2,
                X_AMT_INCL_TAX_FLAG               VARCHAR2,
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
                X_ALLOW_ROUNDING_OVERRIDE_FLAG	  VARCHAR2,
                X_CONTENT_OWNER_ID_ORIG           NUMBER,
                X_ACCOUNT_SEGMENT_VALUE_ORIG      VARCHAR2,
                X_TAX_CLASS_ORIG                  VARCHAR2);

  --
  -- Procedure
  --   lock_row
  -- Purpose
  --
  -- History
  --   24-Nov-04  Tai-Hyun Won       Created
  --
  PROCEDURE lock_row(
                X_RECORD_LEVEL 			  VARCHAR2,
                X_LEDGER_ID                       NUMBER,
                X_CONTENT_OWNER_ID                NUMBER,
                X_ACCOUNT_SEGMENT_VALUE           VARCHAR2,
                X_TAX_PRECISION                   NUMBER,
                X_CALCULATION_LEVEL_CODE          VARCHAR2,
                X_ALLOW_RATE_OVERRIDE_FLAG        VARCHAR2,
                X_TAX_MAU                         NUMBER,
                X_TAX_CURRENCY_CODE               VARCHAR2,
                X_TAX_CLASS                       VARCHAR2,
                X_TAX_REGIME_CODE                 VARCHAR2,
                X_TAX                             VARCHAR2,
                X_TAX_STATUS_CODE                 VARCHAR2,
                X_TAX_RATE_CODE                   VARCHAR2,
                X_ROUNDING_RULE_CODE              VARCHAR2,
                X_AMT_INCL_TAX_FLAG               VARCHAR2,
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
                X_ALLOW_ROUNDING_OVERRIDE_FLAG	  VARCHAR2);

END zx_account_tax_rates_pkg;

 

/
