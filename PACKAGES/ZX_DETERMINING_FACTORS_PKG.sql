--------------------------------------------------------
--  DDL for Package ZX_DETERMINING_FACTORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_DETERMINING_FACTORS_PKG" AUTHID CURRENT_USER AS
/* $Header: zxritrldetfacts.pls 120.8 2005/04/27 11:11:41 mparihar ship $ */

PROCEDURE INSERT_ROW
     (X_ROWID                    IN OUT NOCOPY VARCHAR2,
      X_DETERMINING_FACTOR_ID                  NUMBER,
      X_DETERMINING_FACTOR_CODE                VARCHAR2,
      X_DETERMINING_FACTOR_CLASS_COD           VARCHAR2,
      X_VALUE_SET                              VARCHAR2,
      X_TAX_PARAMETER_CODE                     VARCHAR2,
      X_DATA_TYPE_CODE                         VARCHAR2,
      X_TAX_FUNCTION_CODE                      VARCHAR2,
      X_RECORD_TYPE_CODE                       VARCHAR2,
      X_TAX_REGIME_DET_FLAG                    VARCHAR2,
      X_TAX_SUMMARIZATION_FLAG                 VARCHAR2,
      X_TAX_RULES_FLAG                         VARCHAR2,
      X_TAXABLE_BASIS_FLAG                     VARCHAR2,
      X_TAX_CALCULATION_FLAG                   VARCHAR2,
      X_INTERNAL_FLAG                          VARCHAR2,
      X_RECORD_ONLY_FLAG                       VARCHAR2,
      X_REQUEST_ID                             NUMBER,
      X_DETERMINING_FACTOR_NAME                VARCHAR2,
      X_DETERMINING_FACTOR_DESC                VARCHAR2,
      X_CREATION_DATE                          DATE,
      X_CREATED_BY                             NUMBER,
      X_LAST_UPDATE_DATE                       DATE,
      X_LAST_UPDATED_BY                        NUMBER,
      X_LAST_UPDATE_LOGIN                      NUMBER,
      X_OBJECT_VERSION_NUMBER                  NUMBER);

PROCEDURE LOCK_ROW
     (X_DETERMINING_FACTOR_ID                  NUMBER,
      X_DETERMINING_FACTOR_CODE                VARCHAR2,
      X_DETERMINING_FACTOR_CLASS_COD           VARCHAR2,
      X_VALUE_SET                              VARCHAR2,
      X_TAX_PARAMETER_CODE                     VARCHAR2,
      X_DATA_TYPE_CODE                         VARCHAR2,
      X_TAX_FUNCTION_CODE                      VARCHAR2,
      X_RECORD_TYPE_CODE                       VARCHAR2,
      X_TAX_REGIME_DET_FLAG                    VARCHAR2,
      X_TAX_SUMMARIZATION_FLAG                 VARCHAR2,
      X_TAX_RULES_FLAG                         VARCHAR2,
      X_TAXABLE_BASIS_FLAG                     VARCHAR2,
      X_TAX_CALCULATION_FLAG                   VARCHAR2,
      X_INTERNAL_FLAG                          VARCHAR2,
      X_RECORD_ONLY_FLAG                       VARCHAR2,
      X_REQUEST_ID                             NUMBER,
      X_DETERMINING_FACTOR_NAME                VARCHAR2,
      X_DETERMINING_FACTOR_DESC                VARCHAR2,
      X_OBJECT_VERSION_NUMBER                  NUMBER);

PROCEDURE UPDATE_ROW
     (X_DETERMINING_FACTOR_ID                  NUMBER,
      X_DETERMINING_FACTOR_CODE                VARCHAR2,
      X_DETERMINING_FACTOR_CLASS_COD           VARCHAR2,
      X_VALUE_SET                              VARCHAR2,
      X_TAX_PARAMETER_CODE                     VARCHAR2,
      X_DATA_TYPE_CODE                         VARCHAR2,
      X_TAX_FUNCTION_CODE                      VARCHAR2,
      X_RECORD_TYPE_CODE                       VARCHAR2,
      X_TAX_REGIME_DET_FLAG                    VARCHAR2,
      X_TAX_SUMMARIZATION_FLAG                 VARCHAR2,
      X_TAX_RULES_FLAG                         VARCHAR2,
      X_TAXABLE_BASIS_FLAG                     VARCHAR2,
      X_TAX_CALCULATION_FLAG                   VARCHAR2,
      X_INTERNAL_FLAG                          VARCHAR2,
      X_RECORD_ONLY_FLAG                       VARCHAR2,
      X_REQUEST_ID                             NUMBER,
      X_DETERMINING_FACTOR_NAME                VARCHAR2,
      X_DETERMINING_FACTOR_DESC                VARCHAR2,
      X_LAST_UPDATE_DATE                       DATE,
      X_LAST_UPDATED_BY                        NUMBER,
      X_LAST_UPDATE_LOGIN                      NUMBER,
      X_OBJECT_VERSION_NUMBER                  NUMBER);

PROCEDURE DELETE_ROW
     (X_DETERMINING_FACTOR_ID                  NUMBER);

PROCEDURE ADD_LANGUAGE;

PROCEDURE INSERT_GEOGRAPHY_ROW
     (X_DETERMINING_FACTOR_CLASS_COD           VARCHAR2,
      X_DETERMINING_FACTOR_CODE                VARCHAR2,
      X_RECORD_TYPE_CODE                       VARCHAR2);

END ZX_DETERMINING_FACTORS_PKG;

 

/
