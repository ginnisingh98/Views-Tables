--------------------------------------------------------
--  DDL for Package JL_AR_AR_DOC_LETTER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_AR_AR_DOC_LETTER_PKG" AUTHID CURRENT_USER as
/* $Header: jlarrdos.pls 120.4 2003/12/08 22:11:00 appradha ship $ */

  PROCEDURE Insert_Row(
			  X_rowid                   IN OUT NOCOPY VARCHAR2,
                          X_tax_category_id                 NUMBER,
                          X_org_tax_attribute_name          VARCHAR2,
                          X_org_tax_attribute_value         VARCHAR2,
                          X_con_tax_attribute_name          VARCHAR2,
                          X_con_tax_attribute_value         VARCHAR2,
                          X_document_letter                 VARCHAR2,
                          X_start_date_active               DATE,
                          X_end_date_active                 DATE,
                          X_LAST_UPDATE_DATE                DATE,
                          X_LAST_UPDATED_BY                 NUMBER,
                          X_CREATION_DATE                   DATE,
                          X_CREATED_BY                      NUMBER,
                          X_LAST_UPDATE_LOGIN               NUMBER,
                          X_ORG_ID                          NUMBER,
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
                          X_calling_sequence        IN  VARCHAR2
  );

  PROCEDURE Lock_Row(
			  X_rowid                   VARCHAR2,
                          X_tax_category_id                 NUMBER,
                          X_org_tax_attribute_name          VARCHAR2,
                          X_org_tax_attribute_value         VARCHAR2,
                          X_con_tax_attribute_name          VARCHAR2,
                          X_con_tax_attribute_value         VARCHAR2,
                          X_document_letter                 VARCHAR2,
                          X_start_date_active               DATE,
                          X_end_date_active                 DATE,
                          X_LAST_UPDATE_DATE                DATE,
                          X_LAST_UPDATED_BY                 NUMBER,
                          X_CREATION_DATE                   DATE,
                          X_CREATED_BY                      NUMBER,
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
                          X_calling_sequence        IN    VARCHAR2
  );

  PROCEDURE Update_Row(
			  X_rowid                           VARCHAR2,
                          X_tax_category_id                 NUMBER,
                          X_org_tax_attribute_name          VARCHAR2,
                          X_org_tax_attribute_value         VARCHAR2,
                          X_con_tax_attribute_name          VARCHAR2,
                          X_con_tax_attribute_value         VARCHAR2,
                          X_document_letter                 VARCHAR2,
                          X_start_date_active               DATE,
                          X_end_date_active                 DATE,
                          X_LAST_UPDATE_DATE                DATE,
                          X_LAST_UPDATED_BY                 NUMBER,
                          X_CREATION_DATE                   DATE,
                          X_CREATED_BY                      NUMBER,
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
                          X_calling_sequence        IN    VARCHAR2
  );

  PROCEDURE Delete_Row(
			  X_rowid                   VARCHAR2
  );

  PROCEDURE Check_Unique(
			  X_rowid                   VARCHAR2,
		      X_org_tax_attribute_name      VARCHAR2,
		      X_org_tax_attribute_value     VARCHAR2,
                      X_con_tax_attribute_name      VARCHAR2,
		      X_con_tax_attribute_value     VARCHAR2,
		      X_end_date_active         DATE,
              X_calling_sequence        IN    VARCHAR2
  );

  PROCEDURE Check_Overlapped_Dates(
			  X_rowid                   VARCHAR2,
		      X_org_tax_attribute_name      VARCHAR2,
		      X_org_tax_attribute_value     VARCHAR2,
                      X_con_tax_attribute_name      VARCHAR2,
		      X_con_tax_attribute_value     VARCHAR2,
		      X_end_date_active             DATE,
		      X_start_date_active           DATE,
              X_calling_sequence        IN    VARCHAR2
  );

  PROCEDURE Check_Gaps(
			  X_rowid                   VARCHAR2,
		      X_org_tax_attribute_name      VARCHAR2,
		      X_org_tax_attribute_value     VARCHAR2,
                      X_con_tax_attribute_name      VARCHAR2,
		      X_con_tax_attribute_value     VARCHAR2,
		      X_end_date_active             DATE,
		      X_start_date_active           DATE,
              X_calling_sequence        IN    VARCHAR2
  );

END JL_AR_AR_DOC_LETTER_PKG;

 

/
