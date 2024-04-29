--------------------------------------------------------
--  DDL for Package QP_MODIFIER_LIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_MODIFIER_LIST_PVT" AUTHID CURRENT_USER as
/* $Header: QPXVMLHS.pls 115.0 99/10/14 18:54:06 porting ship   $ */

PROCEDURE Insert_Row(
  X_LIST_HEADER_ID       IN OUT     NUMBER
, X_CREATION_DATE                   DATE
, X_CREATED_BY                      NUMBER
, X_LAST_UPDATE_DATE                DATE
, X_LAST_UPDATED_BY                 NUMBER
, X_LAST_UPDATE_LOGIN               NUMBER
, X_PROGRAM_APPLICATION_ID          NUMBER
, X_PROGRAM_ID                      NUMBER
, X_PROGRAM_UPDATE_DATE             DATE
, X_REQUEST_ID                      NUMBER
, X_LIST_TYPE_CODE                  VARCHAR2
, X_START_DATE_ACTIVE            	 DATE
, X_END_DATE_ACTIVE              	 DATE
, X_AUTOMATIC_FLAG                  VARCHAR2
, X_CURRENCY_CODE                   VARCHAR2
, X_ROUNDING_FACTOR                 NUMBER
, X_SHIP_METHOD_CODE                VARCHAR2
, X_FREIGHT_TERMS_CODE              VARCHAR2
, X_TERMS_ID                        NUMBER
, X_COMMENTS                        VARCHAR2
, X_DISCOUNT_LINES_FLAG             VARCHAR2
, X_GSA_INDICATOR                   VARCHAR2
, X_PRORATE_FLAG                    VARCHAR2
, X_CONTEXT                         VARCHAR2
, X_ATTRIBUTE1                      VARCHAR2
, X_ATTRIBUTE2                      VARCHAR2
, X_ATTRIBUTE3                      VARCHAR2
, X_ATTRIBUTE4                      VARCHAR2
, X_ATTRIBUTE5                      VARCHAR2
, X_ATTRIBUTE6                      VARCHAR2
, X_ATTRIBUTE7                      VARCHAR2
, X_ATTRIBUTE8                      VARCHAR2
, X_ATTRIBUTE9                      VARCHAR2
, X_ATTRIBUTE10                     VARCHAR2
, X_ATTRIBUTE11                     VARCHAR2
, X_ATTRIBUTE12                     VARCHAR2
, X_ATTRIBUTE13                     VARCHAR2
, X_ATTRIBUTE14                     VARCHAR2
, X_ATTRIBUTE15                     VARCHAR2
, X_NAME					      VARCHAR2
, X_DESCRIPTION			    	 VARCHAR2
);




PROCEDURE Lock_Row(
  X_LIST_HEADER_ID       IN OUT     NUMBER
, X_CREATION_DATE                   DATE
, X_CREATED_BY                      NUMBER
, X_LAST_UPDATE_DATE                DATE
, X_LAST_UPDATED_BY                 NUMBER
, X_LAST_UPDATE_LOGIN               NUMBER
, X_PROGRAM_APPLICATION_ID          NUMBER
, X_PROGRAM_ID                      NUMBER
, X_PROGRAM_UPDATE_DATE             DATE
, X_REQUEST_ID                      NUMBER
, X_LIST_TYPE_CODE                  VARCHAR2
, X_START_DATE_ACTIVE            	 DATE
, X_END_DATE_ACTIVE              	 DATE
, X_AUTOMATIC_FLAG                  VARCHAR2
, X_CURRENCY_CODE                   VARCHAR2
, X_ROUNDING_FACTOR                 NUMBER
, X_SHIP_METHOD_CODE                VARCHAR2
, X_FREIGHT_TERMS_CODE              VARCHAR2
, X_TERMS_ID                        NUMBER
, X_COMMENTS                        VARCHAR2
, X_DISCOUNT_LINES_FLAG             VARCHAR2
, X_GSA_INDICATOR                   VARCHAR2
, X_PRORATE_FLAG                    VARCHAR2
, X_CONTEXT                         VARCHAR2
, X_ATTRIBUTE1                      VARCHAR2
, X_ATTRIBUTE2                      VARCHAR2
, X_ATTRIBUTE3                      VARCHAR2
, X_ATTRIBUTE4                      VARCHAR2
, X_ATTRIBUTE5                      VARCHAR2
, X_ATTRIBUTE6                      VARCHAR2
, X_ATTRIBUTE7                      VARCHAR2
, X_ATTRIBUTE8                      VARCHAR2
, X_ATTRIBUTE9                      VARCHAR2
, X_ATTRIBUTE10                     VARCHAR2
, X_ATTRIBUTE11                     VARCHAR2
, X_ATTRIBUTE12                     VARCHAR2
, X_ATTRIBUTE13                     VARCHAR2
, X_ATTRIBUTE14                     VARCHAR2
, X_ATTRIBUTE15                     VARCHAR2
, X_NAME					      VARCHAR2
, X_DESCRIPTION			    	 VARCHAR2
);



PROCEDURE Update_Row(
  X_LIST_HEADER_ID       IN OUT     NUMBER
, X_CREATION_DATE                   DATE
, X_CREATED_BY                      NUMBER
, X_LAST_UPDATE_DATE                DATE
, X_LAST_UPDATED_BY                 NUMBER
, X_LAST_UPDATE_LOGIN               NUMBER
, X_PROGRAM_APPLICATION_ID          NUMBER
, X_PROGRAM_ID                      NUMBER
, X_PROGRAM_UPDATE_DATE             DATE
, X_REQUEST_ID                      NUMBER
, X_LIST_TYPE_CODE                  VARCHAR2
, X_START_DATE_ACTIVE            	 DATE
, X_END_DATE_ACTIVE              	 DATE
, X_AUTOMATIC_FLAG                  VARCHAR2
, X_CURRENCY_CODE                   VARCHAR2
, X_ROUNDING_FACTOR                 NUMBER
, X_SHIP_METHOD_CODE                VARCHAR2
, X_FREIGHT_TERMS_CODE              VARCHAR2
, X_TERMS_ID                        NUMBER
, X_COMMENTS                        VARCHAR2
, X_DISCOUNT_LINES_FLAG             VARCHAR2
, X_GSA_INDICATOR                   VARCHAR2
, X_PRORATE_FLAG                    VARCHAR2
, X_CONTEXT                         VARCHAR2
, X_ATTRIBUTE1                      VARCHAR2
, X_ATTRIBUTE2                      VARCHAR2
, X_ATTRIBUTE3                      VARCHAR2
, X_ATTRIBUTE4                      VARCHAR2
, X_ATTRIBUTE5                      VARCHAR2
, X_ATTRIBUTE6                      VARCHAR2
, X_ATTRIBUTE7                      VARCHAR2
, X_ATTRIBUTE8                      VARCHAR2
, X_ATTRIBUTE9                      VARCHAR2
, X_ATTRIBUTE10                     VARCHAR2
, X_ATTRIBUTE11                     VARCHAR2
, X_ATTRIBUTE12                     VARCHAR2
, X_ATTRIBUTE13                     VARCHAR2
, X_ATTRIBUTE14                     VARCHAR2
, X_ATTRIBUTE15                     VARCHAR2
, X_NAME					      VARCHAR2
, X_DESCRIPTION			    	 VARCHAR2
);


PROCEDURE Delete_Row(
X_LIST_HEADER_ID	NUMBER
);

Procedure Add_Language;



END QP_MODIFIER_LIST_PVT;

 

/
