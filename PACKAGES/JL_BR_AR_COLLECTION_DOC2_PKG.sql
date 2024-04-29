--------------------------------------------------------
--  DDL for Package JL_BR_AR_COLLECTION_DOC2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_BR_AR_COLLECTION_DOC2_PKG" AUTHID CURRENT_USER as
/* $Header: jlbrrc2s.pls 120.2 2003/09/15 21:52:09 vsidhart ship $ */

  PROCEDURE Lock_Row(    X_Rowid                                    VARCHAR2,

			 X_DOCUMENT_ID                              NUMBER,
			 X_BORDERO_ID                               NUMBER,
			 X_PAYMENT_SCHEDULE_ID                      NUMBER,
			 X_DOCUMENT_STATUS                          VARCHAR2,
			 X_ORIGIN_TYPE                              VARCHAR2,
			 X_DUE_DATE                                 DATE,
			 X_SELECTION_DATE                           DATE,
			 X_PORTFOLIO_CODE                           NUMBER,
			 X_BATCH_SOURCE_ID                          NUMBER,
			 X_RECEIPT_METHOD_ID                        NUMBER,
			 X_CUSTOMER_TRX_ID                          NUMBER,
			 X_TERMS_SEQUENCE_NUMBER                    NUMBER,
			 X_DOCUMENT_TYPE                            VARCHAR2,
			 X_BANK_ACCT_USE_ID                         NUMBER DEFAULT NULL,
			 X_PREVIOUS_DOC_STATUS                      VARCHAR2 DEFAULT NULL,
			 X_OUR_NUMBER                               VARCHAR2 DEFAULT NULL,
			 X_BANK_USE                                 VARCHAR2 DEFAULT NULL,
			 X_COLLECTOR_BANK_PARTY_ID                  NUMBER DEFAULT NULL,
			 X_COLLECTOR_BRANCH_PARTY_ID                NUMBER DEFAULT NULL,
			 X_FACTORING_RATE                           NUMBER DEFAULT NULL,
			 X_FACTORING_RATE_PERIOD                    NUMBER DEFAULT NULL,
			 X_FACTORING_AMOUNT                         NUMBER DEFAULT NULL,
			 X_FACTORING_DATE                           DATE DEFAULT NULL,
			 X_CANCELLATION_DATE                        DATE DEFAULT NULL,
			 X_BANK_INSTRUCTION_CODE1                   NUMBER DEFAULT NULL,
			 X_BANK_INSTRUCTION_CODE2                   NUMBER DEFAULT NULL,
			 X_NUM_DAYS_INSTRUCTION                     NUMBER DEFAULT NULL,
			 X_BANK_CHARGE_AMOUNT                       NUMBER DEFAULT NULL,
			 X_CASH_CCID                                NUMBER DEFAULT NULL,
			 X_BANK_CHARGES_CCID                        NUMBER DEFAULT NULL,
			 X_COLL_ENDORSEMENTS_CCID                   NUMBER DEFAULT NULL,
			 X_BILLS_COLLECTION_CCID                    NUMBER DEFAULT NULL,
			 X_CALCULATED_INTEREST_CCID                 NUMBER DEFAULT NULL,
			 X_INTEREST_WRITEOFF_CCID                   NUMBER DEFAULT NULL,
			 X_ABATEMENT_WRITEOFF_CCID                  NUMBER DEFAULT NULL,
			 X_ABATEMENT_REVENUE_CCID                   NUMBER DEFAULT NULL,
			 X_INTEREST_REVENUE_CCID                    NUMBER DEFAULT NULL,
			 X_CALCULATED_INT_RECTRX_ID                 NUMBER DEFAULT NULL,
			 X_INTEREST_WRITEOFF_RECTRX_ID              NUMBER DEFAULT NULL,
			 X_INTEREST_REVENUE_RECTRX_ID               NUMBER DEFAULT NULL,
			 X_ABATEMENT_WRITEOFF_RECTRX_ID             NUMBER DEFAULT NULL,
			 X_ABATE_REVENUE_RECTRX_ID                  NUMBER DEFAULT NULL,
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

END JL_BR_AR_COLLECTION_DOC2_PKG;

 

/
