--------------------------------------------------------
--  DDL for Package JL_BR_AR_BANK_RETURNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_BR_AR_BANK_RETURNS_PKG" AUTHID CURRENT_USER as
/* $Header: jlbrrems.pls 120.5 2003/09/15 21:51:46 vsidhart ship $ */

  PROCEDURE Insert_Row(
			              X_rowid                   IN OUT NOCOPY VARCHAR2,
                          X_RETURN_ID                                NUMBER,
                          X_BANK_OCCURRENCE_CODE                     NUMBER,
                          X_OCCURRENCE_DATE                          DATE,
                          X_FILE_CONTROL                             VARCHAR2,
                          X_ENTRY_SEQUENTIAL_NUMBER                  NUMBER,
                          X_GENERATION_DATE                          DATE,
                          X_PROCESSING_DATE                          DATE,
                          X_DOCUMENT_ID                              NUMBER,
                          --X_BANK_NUMBER                            VARCHAR2,
                          X_BANK_PARTY_ID                            NUMBER,
                          X_BATCH_SOURCE_ID                          NUMBER,
                          X_OUR_NUMBER                               VARCHAR2,
                          X_TRADE_NOTE_NUMBER                        VARCHAR2,
                          X_DUE_DATE                                 DATE,
                          X_TRADE_NOTE_AMOUNT                        NUMBER,
                          X_COLLECTOR_BANK_PARTY_ID                  NUMBER,
                          X_COLLECTOR_BRANCH_PARTY_ID                NUMBER,
                          X_BANK_CHARGE_AMOUNT                       NUMBER,
                          X_ABATEMENT_AMOUNT                         NUMBER,
                          X_DISCOUNT_AMOUNT                          NUMBER,
                          X_CREDIT_AMOUNT                            NUMBER,
                          X_INTEREST_AMOUNT_RECEIVED                 NUMBER,
                          X_CUSTOMER_ID                              NUMBER,
                          X_RETURN_INFO                              VARCHAR2,
                          X_BANK_USE                                 VARCHAR2,
                          X_COMPANY_USE                              NUMBER,
                          X_LAST_UPDATE_DATE                         DATE,
                          X_LAST_UPDATED_BY                          NUMBER,
                          X_CREATION_DATE                            DATE,
                          X_CREATED_BY                               NUMBER,
                          X_LAST_UPDATE_LOGIN                        NUMBER,
                          X_calling_sequence                     IN  VARCHAR2,
                          X_ORG_ID                                   NUMBER
  );

  PROCEDURE Lock_Row(
			              X_rowid                                    VARCHAR2,
                          X_RETURN_ID                                NUMBER,
                          X_BANK_OCCURRENCE_CODE                     NUMBER,
                          X_OCCURRENCE_DATE                          DATE,
                          X_FILE_CONTROL                             VARCHAR2,
                          X_ENTRY_SEQUENTIAL_NUMBER                  NUMBER,
                          X_GENERATION_DATE                          DATE,
                          X_PROCESSING_DATE                          DATE,
                          X_DOCUMENT_ID                              NUMBER,
                          --X_BANK_NUMBER                            VARCHAR2,
                          X_BANK_PARTY_ID                            NUMBER,
                          X_BATCH_SOURCE_ID                          NUMBER,
                          X_OUR_NUMBER                               VARCHAR2,
                          X_TRADE_NOTE_NUMBER                        VARCHAR2,
                          X_DUE_DATE                                 DATE,
                          X_TRADE_NOTE_AMOUNT                        NUMBER,
                          X_COLLECTOR_BANK_PARTY_ID                  NUMBER,
                          X_COLLECTOR_BRANCH_PARTY_ID                NUMBER,
                          X_BANK_CHARGE_AMOUNT                       NUMBER,
                          X_ABATEMENT_AMOUNT                         NUMBER,
                          X_DISCOUNT_AMOUNT                          NUMBER,
                          X_CREDIT_AMOUNT                            NUMBER,
                          X_INTEREST_AMOUNT_RECEIVED                 NUMBER,
                          X_CUSTOMER_ID                              NUMBER,
                          X_RETURN_INFO                              VARCHAR2,
                          X_BANK_USE                                 VARCHAR2,
                          X_COMPANY_USE                              NUMBER,
                          X_LAST_UPDATE_DATE                         DATE,
                          X_LAST_UPDATED_BY                          NUMBER,
                          X_CREATION_DATE                            DATE,
                          X_CREATED_BY                               NUMBER,
                          X_LAST_UPDATE_LOGIN                        NUMBER,
                          X_calling_sequence                   IN    VARCHAR2
  );

  PROCEDURE Update_Row(
			              X_rowid                                    VARCHAR2,
                          X_RETURN_ID                                NUMBER,
                          X_BANK_OCCURRENCE_CODE                     NUMBER,
                          X_OCCURRENCE_DATE                          DATE,
                          X_FILE_CONTROL                             VARCHAR2,
                          X_ENTRY_SEQUENTIAL_NUMBER                  NUMBER,
                          X_GENERATION_DATE                          DATE,
                          X_PROCESSING_DATE                          DATE,
                          X_DOCUMENT_ID                              NUMBER,
                          --X_BANK_NUMBER                            VARCHAR2,
                          X_BANK_PARTY_ID                            NUMBER,
                          X_BATCH_SOURCE_ID                          NUMBER,
                          X_OUR_NUMBER                               VARCHAR2,
                          X_TRADE_NOTE_NUMBER                        VARCHAR2,
                          X_DUE_DATE                                 DATE,
                          X_TRADE_NOTE_AMOUNT                        NUMBER,
                          X_COLLECTOR_BANK_PARTY_ID                  NUMBER,
                          X_COLLECTOR_BRANCH_PARTY_ID                NUMBER,
                          X_BANK_CHARGE_AMOUNT                       NUMBER,
                          X_ABATEMENT_AMOUNT                         NUMBER,
                          X_DISCOUNT_AMOUNT                          NUMBER,
                          X_CREDIT_AMOUNT                            NUMBER,
                          X_INTEREST_AMOUNT_RECEIVED                 NUMBER,
                          X_CUSTOMER_ID                              NUMBER,
                          X_RETURN_INFO                              VARCHAR2,
                          X_BANK_USE                                 VARCHAR2,
                          X_COMPANY_USE                              NUMBER,
                          X_LAST_UPDATE_DATE                         DATE,
                          X_LAST_UPDATED_BY                          NUMBER,
                          X_CREATION_DATE                            DATE,
                          X_CREATED_BY                               NUMBER,
                          X_LAST_UPDATE_LOGIN                        NUMBER,
                          X_calling_sequence                   IN    VARCHAR2
  );

  PROCEDURE Delete_Row(
			  X_rowid                   VARCHAR2
  );
END JL_BR_AR_BANK_RETURNS_PKG;

 

/
