--------------------------------------------------------
--  DDL for Package JL_BR_AR_SELECT_CONTROLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_BR_AR_SELECT_CONTROLS_PKG" AUTHID CURRENT_USER as
/* $Header: jlbrrscs.pls 120.4 2003/07/11 18:58:29 appradha ship $ */

  PROCEDURE Insert_Row(  X_Rowid                             IN OUT NOCOPY VARCHAR2,

			 X_SELECTION_CONTROL_ID                     NUMBER,
			 X_SELECTION_STATUS                         VARCHAR2,
			 X_SELECTION_TYPE                           VARCHAR2,
			 X_NAME                                     VARCHAR2 DEFAULT NULL,
			 X_BORDERO_TYPE                             VARCHAR2 DEFAULT NULL,
			 X_SELECTION_DATE                           DATE DEFAULT NULL,
			 X_CANCELLATION_DATE                        DATE DEFAULT NULL,
			 X_GENERATION_DATE                          DATE DEFAULT NULL,
			 X_REMITTANCE_DATE                          DATE DEFAULT NULL,
			 X_DUE_DATE_BREAK_FLAG                      VARCHAR2 DEFAULT NULL,
			 X_INITIAL_DUE_DATE                         DATE DEFAULT NULL,
			 X_FINAL_DUE_DATE                           DATE DEFAULT NULL,
			 X_INITIAL_TRX_DATE                         DATE DEFAULT NULL,
			 X_FINAL_TRX_DATE                           DATE DEFAULT NULL,
			 X_CUST_TRX_TYPE_ID                         NUMBER DEFAULT NULL,
			 X_INITIAL_TRX_NUMBER                       VARCHAR2 DEFAULT NULL,
			 X_FINAL_TRX_NUMBER                         VARCHAR2 DEFAULT NULL,
			 X_INITIAL_CUSTOMER_NUMBER                  VARCHAR2 DEFAULT NULL,
			 X_FINAL_CUSTOMER_NUMBER                    VARCHAR2 DEFAULT NULL,
			 X_REQUEST_ID                               NUMBER DEFAULT NULL,
			 X_RECEIPT_METHOD_ID                        NUMBER DEFAULT NULL,
			 X_INITIAL_TRX_AMOUNT                       NUMBER DEFAULT NULL,
			 X_FINAL_TRX_AMOUNT                         NUMBER DEFAULT NULL,
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

			 X_SELECTION_CONTROL_ID                     NUMBER,
			 X_SELECTION_STATUS                         VARCHAR2,
			 X_SELECTION_TYPE                           VARCHAR2,
			 X_NAME                                     VARCHAR2 DEFAULT NULL,
			 X_BORDERO_TYPE                             VARCHAR2 DEFAULT NULL,
			 X_SELECTION_DATE                           DATE DEFAULT NULL,
			 X_CANCELLATION_DATE                        DATE DEFAULT NULL,
			 X_GENERATION_DATE                          DATE DEFAULT NULL,
			 X_REMITTANCE_DATE                          DATE DEFAULT NULL,
			 X_DUE_DATE_BREAK_FLAG                      VARCHAR2 DEFAULT NULL,
			 X_INITIAL_DUE_DATE                         DATE DEFAULT NULL,
			 X_FINAL_DUE_DATE                           DATE DEFAULT NULL,
			 X_INITIAL_TRX_DATE                         DATE DEFAULT NULL,
			 X_FINAL_TRX_DATE                           DATE DEFAULT NULL,
			 X_CUST_TRX_TYPE_ID                         NUMBER DEFAULT NULL,
			 X_INITIAL_TRX_NUMBER                       VARCHAR2 DEFAULT NULL,
			 X_FINAL_TRX_NUMBER                         VARCHAR2 DEFAULT NULL,
			 X_INITIAL_CUSTOMER_NUMBER                  VARCHAR2 DEFAULT NULL,
			 X_FINAL_CUSTOMER_NUMBER                    VARCHAR2 DEFAULT NULL,
			 X_REQUEST_ID                               NUMBER DEFAULT NULL,
			 X_RECEIPT_METHOD_ID                        NUMBER DEFAULT NULL,
			 X_INITIAL_TRX_AMOUNT                       NUMBER DEFAULT NULL,
			 X_FINAL_TRX_AMOUNT                         NUMBER DEFAULT NULL,
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

			 X_SELECTION_CONTROL_ID                     NUMBER,
			 X_SELECTION_STATUS                         VARCHAR2,
			 X_SELECTION_TYPE                           VARCHAR2,
			 X_NAME                                     VARCHAR2 DEFAULT NULL,
			 X_BORDERO_TYPE                             VARCHAR2 DEFAULT NULL,
			 X_SELECTION_DATE                           DATE DEFAULT NULL,
			 X_CANCELLATION_DATE                        DATE DEFAULT NULL,
			 X_GENERATION_DATE                          DATE DEFAULT NULL,
			 X_REMITTANCE_DATE                          DATE DEFAULT NULL,
			 X_DUE_DATE_BREAK_FLAG                      VARCHAR2 DEFAULT NULL,
			 X_INITIAL_DUE_DATE                         DATE DEFAULT NULL,
			 X_FINAL_DUE_DATE                           DATE DEFAULT NULL,
			 X_INITIAL_TRX_DATE                         DATE DEFAULT NULL,
			 X_FINAL_TRX_DATE                           DATE DEFAULT NULL,
			 X_CUST_TRX_TYPE_ID                         NUMBER DEFAULT NULL,
			 X_INITIAL_TRX_NUMBER                       VARCHAR2 DEFAULT NULL,
			 X_FINAL_TRX_NUMBER                         VARCHAR2 DEFAULT NULL,
			 X_INITIAL_CUSTOMER_NUMBER                  VARCHAR2 DEFAULT NULL,
			 X_FINAL_CUSTOMER_NUMBER                    VARCHAR2 DEFAULT NULL,
			 X_REQUEST_ID                               NUMBER DEFAULT NULL,
			 X_RECEIPT_METHOD_ID                        NUMBER DEFAULT NULL,
			 X_INITIAL_TRX_AMOUNT                       NUMBER DEFAULT NULL,
			 X_FINAL_TRX_AMOUNT                         NUMBER DEFAULT NULL,
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

END JL_BR_AR_SELECT_CONTROLS_PKG;

 

/
