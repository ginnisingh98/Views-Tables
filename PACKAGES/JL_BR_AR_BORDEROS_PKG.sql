--------------------------------------------------------
--  DDL for Package JL_BR_AR_BORDEROS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_BR_AR_BORDEROS_PKG" AUTHID CURRENT_USER as
/* $Header: jlbrrbds.pls 120.5 2003/09/18 20:24:36 vsidhart ship $ */

  PROCEDURE Insert_Row(  X_Rowid                             IN OUT NOCOPY VARCHAR2,

			 X_BORDERO_ID                               NUMBER,
			 X_SELECTION_CONTROL_ID                     NUMBER,
			 X_BANK_ACCT_USE_ID                         NUMBER,
			 X_BORDERO_STATUS                           VARCHAR2,
			 X_SEQUENTIAL_NUMBER_GENERATION             NUMBER DEFAULT NULL,
			 X_BORDERO_TYPE                             VARCHAR2 DEFAULT NULL,
			 X_TOTAL_COUNT                              NUMBER DEFAULT NULL,
			 X_TOTAL_AMOUNT                             NUMBER DEFAULT NULL,
			 X_SELECTION_DATE                           DATE DEFAULT NULL,
			 X_REMITTANCE_DATE                          DATE DEFAULT NULL,
			 X_REFUSED_DATE                             DATE DEFAULT NULL,
			 X_CANCELLATION_DATE                        DATE DEFAULT NULL,
			 X_COLLECTION_DATE                          DATE DEFAULT NULL,
			 X_WRITE_OFF_DATE                           DATE DEFAULT NULL,
			 X_DATE_IN_RECEIPT                          DATE DEFAULT NULL,
			 X_RECEIVED_DATE                            DATE DEFAULT NULL,
			 X_OUTPUT_PROGRAM_ID                        NUMBER DEFAULT NULL,
			 X_SELECT_ACCOUNT_ID                        NUMBER DEFAULT NULL,
			 X_OUTPUT_FORMAT                            VARCHAR2 DEFAULT NULL,
			 X_LAST_UPDATE_DATE                         DATE,
			 X_LAST_UPDATED_BY                          NUMBER,
			 X_CREATION_DATE                            DATE,
			 X_CREATED_BY                               NUMBER,
			 X_LAST_UPDATE_LOGIN                        NUMBER,

			 X_calling_sequence		            VARCHAR2,
			 X_ORG_ID      		                    NUMBER
                      );

  PROCEDURE Lock_Row(    X_Rowid                                    VARCHAR2,

			 X_BORDERO_ID                               NUMBER,
			 X_SELECTION_CONTROL_ID                     NUMBER,
			 X_BANK_ACCT_USE_ID                         NUMBER,
			 X_BORDERO_STATUS                           VARCHAR2,
			 X_SEQUENTIAL_NUMBER_GENERATION             NUMBER DEFAULT NULL,
			 X_BORDERO_TYPE                             VARCHAR2 DEFAULT NULL,
			 X_TOTAL_COUNT                              NUMBER DEFAULT NULL,
			 X_TOTAL_AMOUNT                             NUMBER DEFAULT NULL,
			 X_SELECTION_DATE                           DATE DEFAULT NULL,
			 X_REMITTANCE_DATE                          DATE DEFAULT NULL,
			 X_REFUSED_DATE                             DATE DEFAULT NULL,
			 X_CANCELLATION_DATE                        DATE DEFAULT NULL,
			 X_COLLECTION_DATE                          DATE DEFAULT NULL,
			 X_WRITE_OFF_DATE                           DATE DEFAULT NULL,
			 X_DATE_IN_RECEIPT                          DATE DEFAULT NULL,
			 X_RECEIVED_DATE                            DATE DEFAULT NULL,
			 X_OUTPUT_PROGRAM_ID                        NUMBER DEFAULT NULL,
			 X_SELECT_ACCOUNT_ID                        NUMBER DEFAULT NULL,
			 X_OUTPUT_FORMAT                            VARCHAR2 DEFAULT NULL,
			 X_LAST_UPDATE_DATE                         DATE,
			 X_LAST_UPDATED_BY                          NUMBER,
			 X_CREATION_DATE                            DATE,
			 X_CREATED_BY                               NUMBER,
			 X_LAST_UPDATE_LOGIN                        NUMBER,

                         X_calling_sequence		            VARCHAR2
                    );


  PROCEDURE Update_Row(  X_Rowid                                    VARCHAR2,

			 X_BORDERO_ID                               NUMBER,
			 X_SELECTION_CONTROL_ID                     NUMBER,
			 X_BANK_ACCT_USE_ID                         NUMBER,
			 X_BORDERO_STATUS                           VARCHAR2,
			 X_SEQUENTIAL_NUMBER_GENERATION             NUMBER DEFAULT NULL,
			 X_BORDERO_TYPE                             VARCHAR2 DEFAULT NULL,
			 X_TOTAL_COUNT                              NUMBER DEFAULT NULL,
			 X_TOTAL_AMOUNT                             NUMBER DEFAULT NULL,
			 X_SELECTION_DATE                           DATE DEFAULT NULL,
			 X_REMITTANCE_DATE                          DATE DEFAULT NULL,
			 X_REFUSED_DATE                             DATE DEFAULT NULL,
			 X_CANCELLATION_DATE                        DATE DEFAULT NULL,
			 X_COLLECTION_DATE                          DATE DEFAULT NULL,
			 X_WRITE_OFF_DATE                           DATE DEFAULT NULL,
			 X_DATE_IN_RECEIPT                          DATE DEFAULT NULL,
			 X_RECEIVED_DATE                            DATE DEFAULT NULL,
			 X_OUTPUT_PROGRAM_ID                        NUMBER DEFAULT NULL,
			 X_SELECT_ACCOUNT_ID                        NUMBER DEFAULT NULL,
			 X_OUTPUT_FORMAT                            VARCHAR2 DEFAULT NULL,
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

END JL_BR_AR_BORDEROS_PKG;

 

/
