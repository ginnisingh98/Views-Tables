--------------------------------------------------------
--  DDL for Package JL_BR_AR_SELECT_ACCOUNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_BR_AR_SELECT_ACCOUNTS_PKG" AUTHID CURRENT_USER as
/* $Header: jlbrrsas.pls 120.5 2003/09/18 21:03:25 vsidhart ship $ */

  PROCEDURE Insert_Row(  X_Rowid                             IN OUT NOCOPY VARCHAR2,

			 X_SELECT_ACCOUNT_ID                        NUMBER,
			 X_SELECTION_CONTROL_ID                     NUMBER,
			 X_BANK_ACCT_USE_ID                         NUMBER,
			 X_GL_DATE                                  DATE DEFAULT NULL,
			 X_SELECTION_DATE                           DATE DEFAULT NULL,
			 X_CANCELLATION_DATE                        DATE DEFAULT NULL,
			 X_FORMAT_DATE                              DATE DEFAULT NULL,
			 X_REMITTANCE_DATE                          DATE DEFAULT NULL,
			 X_PORTFOLIO_CODE                           NUMBER DEFAULT NULL,
			 X_MIN_DOCUMENT_AMOUNT                      NUMBER DEFAULT NULL,
			 X_MAX_DOCUMENT_AMOUNT                      NUMBER DEFAULT NULL,
			 X_MIN_REMITTANCE_AMOUNT                    NUMBER DEFAULT NULL,
			 X_MAX_REMITTANCE_AMOUNT                    NUMBER DEFAULT NULL,
			 X_BANK_INSTRUCTION_CODE1                   NUMBER DEFAULT NULL,
			 X_BANK_INSTRUCTION_CODE2                   NUMBER DEFAULT NULL,
			 X_BANK_CHARGE_AMOUNT                       NUMBER DEFAULT NULL,
			 X_BATCH_SOURCE_ID                          NUMBER DEFAULT NULL,
			 X_PERCENTAGE_DISTRIBUTION                  NUMBER DEFAULT NULL,
			 X_ATTRIBUTE_CATEGORY                       VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE1                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE2                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE3                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE4                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE5                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE6                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE7                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE8                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE9                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE10                              VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE11                              VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE12                              VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE13                              VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE14                              VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE15                              VARCHAR2 DEFAULT NULL,
			 X_LAST_UPDATE_DATE                         DATE,
			 X_LAST_UPDATED_BY                          NUMBER,
			 X_CREATION_DATE                            DATE,
			 X_CREATED_BY                               NUMBER,
			 X_LAST_UPDATE_LOGIN                        NUMBER,

			 X_calling_sequence		            VARCHAR2,
                         X_ORG_ID                                   NUMBER
                      );

  PROCEDURE Lock_Row(    X_Rowid                                    VARCHAR2,

			 X_SELECT_ACCOUNT_ID                        NUMBER,
			 X_SELECTION_CONTROL_ID                     NUMBER,
			 X_BANK_ACCT_USE_ID                         NUMBER,
			 X_GL_DATE                                  DATE DEFAULT NULL,
			 X_SELECTION_DATE                           DATE DEFAULT NULL,
			 X_CANCELLATION_DATE                        DATE DEFAULT NULL,
			 X_FORMAT_DATE                              DATE DEFAULT NULL,
			 X_REMITTANCE_DATE                          DATE DEFAULT NULL,
			 X_PORTFOLIO_CODE                           NUMBER DEFAULT NULL,
			 X_MIN_DOCUMENT_AMOUNT                      NUMBER DEFAULT NULL,
			 X_MAX_DOCUMENT_AMOUNT                      NUMBER DEFAULT NULL,
			 X_MIN_REMITTANCE_AMOUNT                    NUMBER DEFAULT NULL,
			 X_MAX_REMITTANCE_AMOUNT                    NUMBER DEFAULT NULL,
			 X_BANK_INSTRUCTION_CODE1                   NUMBER DEFAULT NULL,
			 X_BANK_INSTRUCTION_CODE2                   NUMBER DEFAULT NULL,
			 X_BANK_CHARGE_AMOUNT                       NUMBER DEFAULT NULL,
			 X_BATCH_SOURCE_ID                          NUMBER DEFAULT NULL,
			 X_PERCENTAGE_DISTRIBUTION                  NUMBER DEFAULT NULL,
			 X_ATTRIBUTE_CATEGORY                       VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE1                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE2                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE3                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE4                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE5                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE6                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE7                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE8                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE9                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE10                              VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE11                              VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE12                              VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE13                              VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE14                              VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE15                              VARCHAR2 DEFAULT NULL,
			 X_LAST_UPDATE_DATE                         DATE,
			 X_LAST_UPDATED_BY                          NUMBER,
			 X_CREATION_DATE                            DATE,
			 X_CREATED_BY                               NUMBER,
			 X_LAST_UPDATE_LOGIN                        NUMBER,

                         X_calling_sequence		            VARCHAR2
                    );


  PROCEDURE Update_Row(  X_Rowid                                    VARCHAR2,

			 X_SELECT_ACCOUNT_ID                        NUMBER,
			 X_SELECTION_CONTROL_ID                     NUMBER,
			 X_BANK_ACCT_USE_ID                         NUMBER,
			 X_GL_DATE                                  DATE DEFAULT NULL,
			 X_SELECTION_DATE                           DATE DEFAULT NULL,
			 X_CANCELLATION_DATE                        DATE DEFAULT NULL,
			 X_FORMAT_DATE                              DATE DEFAULT NULL,
			 X_REMITTANCE_DATE                          DATE DEFAULT NULL,
			 X_PORTFOLIO_CODE                           NUMBER DEFAULT NULL,
			 X_MIN_DOCUMENT_AMOUNT                      NUMBER DEFAULT NULL,
			 X_MAX_DOCUMENT_AMOUNT                      NUMBER DEFAULT NULL,
			 X_MIN_REMITTANCE_AMOUNT                    NUMBER DEFAULT NULL,
			 X_MAX_REMITTANCE_AMOUNT                    NUMBER DEFAULT NULL,
			 X_BANK_INSTRUCTION_CODE1                   NUMBER DEFAULT NULL,
			 X_BANK_INSTRUCTION_CODE2                   NUMBER DEFAULT NULL,
			 X_BANK_CHARGE_AMOUNT                       NUMBER DEFAULT NULL,
			 X_BATCH_SOURCE_ID                          NUMBER DEFAULT NULL,
			 X_PERCENTAGE_DISTRIBUTION                  NUMBER DEFAULT NULL,
			 X_ATTRIBUTE_CATEGORY                       VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE1                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE2                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE3                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE4                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE5                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE6                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE7                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE8                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE9                               VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE10                              VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE11                              VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE12                              VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE13                              VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE14                              VARCHAR2 DEFAULT NULL,
			 X_ATTRIBUTE15                              VARCHAR2 DEFAULT NULL,
			 X_LAST_UPDATE_DATE                         DATE,
			 X_LAST_UPDATED_BY                          NUMBER,
			 X_CREATION_DATE                            DATE,
			 X_CREATED_BY                               NUMBER,
			 X_LAST_UPDATE_LOGIN                        NUMBER,

                         X_calling_sequence		            VARCHAR2
                      );


  PROCEDURE Delete_Row(  X_Rowid				    VARCHAR2,
		         X_calling_sequence		            VARCHAR2
		      );

END JL_BR_AR_SELECT_ACCOUNTS_PKG;

 

/
