--------------------------------------------------------
--  DDL for Package JL_CO_GL_NIT_ACCTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_CO_GL_NIT_ACCTS_PKG" AUTHID CURRENT_USER as
/* $Header: jlcoglas.pls 115.1 2002/04/05 10:06:01 pkm ship      $ */

  PROCEDURE Lock_Row(
                      X_rowid                   VARCHAR2,
                      X_chart_of_accounts_id    NUMBER,
                      X_flex_value_id           NUMBER,
                      X_account_code            VARCHAR2,
                      X_nit_required            VARCHAR2,
                      X_last_updated_by         NUMBER,
                      X_last_update_date        DATE,
                      X_last_update_login       NUMBER,
                      X_creation_date           DATE,
                      X_created_by              NUMBER,
                      X_attribute_category      VARCHAR2,
                      X_attribute1              VARCHAR2,
                      X_attribute2              VARCHAR2,
                      X_attribute3              VARCHAR2,
                      X_attribute4              VARCHAR2,
                      X_attribute5              VARCHAR2,
                      X_attribute6              VARCHAR2,
                      X_attribute7              VARCHAR2,
                      X_attribute8              VARCHAR2,
                      X_attribute9              VARCHAR2,
                      X_attribute10             VARCHAR2,
                      X_attribute11             VARCHAR2,
                      X_attribute12             VARCHAR2,
                      X_attribute13             VARCHAR2,
                      X_attribute14             VARCHAR2,
                      X_attribute15             VARCHAR2
  );


  PROCEDURE Update_Row(
		      X_rowid                   VARCHAR2,
		      X_chart_of_accounts_id    NUMBER,
                      X_flex_value_id           NUMBER,
		      X_account_code            VARCHAR2,
                      X_nit_required            VARCHAR2,
		      X_last_updated_by         NUMBER,
		      X_last_update_date        DATE,
		      X_last_update_login       NUMBER,
		      X_creation_date           DATE,
		      X_created_by              NUMBER,
		      X_attribute_category      VARCHAR2,
                      X_attribute1              VARCHAR2,
                      X_attribute2              VARCHAR2,
                      X_attribute3              VARCHAR2,
                      X_attribute4              VARCHAR2,
                      X_attribute5              VARCHAR2,
                      X_attribute6              VARCHAR2,
                      X_attribute7              VARCHAR2,
                      X_attribute8              VARCHAR2,
                      X_attribute9              VARCHAR2,
                      X_attribute10             VARCHAR2,
                      X_attribute11             VARCHAR2,
                      X_attribute12             VARCHAR2,
                      X_attribute13             VARCHAR2,
                      X_attribute14             VARCHAR2,
                      X_attribute15             VARCHAR2
  );

  PROCEDURE Delete_Row(
			  X_rowid                   VARCHAR2
  );

END JL_CO_GL_NIT_ACCTS_PKG;

 

/
