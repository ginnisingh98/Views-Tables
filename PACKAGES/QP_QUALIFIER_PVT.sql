--------------------------------------------------------
--  DDL for Package QP_QUALIFIER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_QUALIFIER_PVT" AUTHID CURRENT_USER as
/* $Header: QPXVQFRS.pls 115.0 99/10/14 18:54:50 porting ship   $ */

PROCEDURE Insert_Row(
  X_QUALIFIER_ID            IN OUT NUMBER
, X_CREATION_DATE                  DATE
, X_CREATED_BY                     NUMBER
, X_LAST_UPDATE_DATE               DATE
, X_LAST_UPDATED_BY                NUMBER
, X_LAST_UPDATE_LOGIN              NUMBER
, X_PROGRAM_APPLICATION_ID         NUMBER
, X_PROGRAM_ID                     NUMBER
, X_PROGRAM_UPDATE_DATE            DATE
, X_REQUEST_ID                     NUMBER
, X_EXCLUDER_FLAG                  VARCHAR2
, X_COMPARISON_OPERATOR_CODE       VARCHAR2
, X_QUALIFIER_CONTEXT              VARCHAR2
, X_QUALIFIER_ATTRIBUTE            VARCHAR2
, X_QUALIFIER_RULE_ID              NUMBER
, X_QUALIFIER_GROUPING_NO          NUMBER
, X_QUALIFIER_ATTR_VALUE           VARCHAR2
, X_LIST_HEADER_ID                 NUMBER
, X_LIST_LINE_ID                   NUMBER
, X_CREATED_FROM_RULE_ID           NUMBER
, X_START_DATE_ACTIVE              DATE
, X_END_DATE_ACTIVE                DATE
, X_CONTEXT                        VARCHAR2
, X_ATTRIBUTE1                     VARCHAR2
, X_ATTRIBUTE2                     VARCHAR2
, X_ATTRIBUTE3                     VARCHAR2
, X_ATTRIBUTE4                     VARCHAR2
, X_ATTRIBUTE5                     VARCHAR2
, X_ATTRIBUTE6                     VARCHAR2
, X_ATTRIBUTE7                     VARCHAR2
, X_ATTRIBUTE8                     VARCHAR2
, X_ATTRIBUTE9                     VARCHAR2
, X_ATTRIBUTE10                    VARCHAR2
, X_ATTRIBUTE11                    VARCHAR2
, X_ATTRIBUTE12                    VARCHAR2
, X_ATTRIBUTE13                    VARCHAR2
, X_ATTRIBUTE14                    VARCHAR2
, X_ATTRIBUTE15                    VARCHAR2
);


PROCEDURE Lock_Row(
  X_QUALIFIER_ID            IN OUT NUMBER
, X_CREATION_DATE                  DATE
, X_CREATED_BY                     NUMBER
, X_LAST_UPDATE_DATE               DATE
, X_LAST_UPDATED_BY                NUMBER
, X_LAST_UPDATE_LOGIN              NUMBER
, X_PROGRAM_APPLICATION_ID         NUMBER
, X_PROGRAM_ID                     NUMBER
, X_PROGRAM_UPDATE_DATE            DATE
, X_REQUEST_ID                     NUMBER
, X_EXCLUDER_FLAG                  VARCHAR2
, X_COMPARISON_OPERATOR_CODE       VARCHAR2
, X_QUALIFIER_CONTEXT              VARCHAR2
, X_QUALIFIER_ATTRIBUTE            VARCHAR2
, X_QUALIFIER_RULE_ID              NUMBER
, X_QUALIFIER_GROUPING_NO          NUMBER
, X_QUALIFIER_ATTR_VALUE           VARCHAR2
, X_LIST_HEADER_ID                 NUMBER
, X_LIST_LINE_ID                   NUMBER
, X_CREATED_FROM_RULE_ID           NUMBER
, X_START_DATE_ACTIVE              DATE
, X_END_DATE_ACTIVE                DATE
, X_CONTEXT                        VARCHAR2
, X_ATTRIBUTE1                     VARCHAR2
, X_ATTRIBUTE2                     VARCHAR2
, X_ATTRIBUTE3                     VARCHAR2
, X_ATTRIBUTE4                     VARCHAR2
, X_ATTRIBUTE5                     VARCHAR2
, X_ATTRIBUTE6                     VARCHAR2
, X_ATTRIBUTE7                     VARCHAR2
, X_ATTRIBUTE8                     VARCHAR2
, X_ATTRIBUTE9                     VARCHAR2
, X_ATTRIBUTE10                    VARCHAR2
, X_ATTRIBUTE11                    VARCHAR2
, X_ATTRIBUTE12                    VARCHAR2
, X_ATTRIBUTE13                    VARCHAR2
, X_ATTRIBUTE14                    VARCHAR2
, X_ATTRIBUTE15                    VARCHAR2
);


PROCEDURE Update_Row(
  X_QUALIFIER_ID            IN OUT NUMBER
, X_CREATION_DATE                  DATE
, X_CREATED_BY                     NUMBER
, X_LAST_UPDATE_DATE               DATE
, X_LAST_UPDATED_BY                NUMBER
, X_LAST_UPDATE_LOGIN              NUMBER
, X_PROGRAM_APPLICATION_ID         NUMBER
, X_PROGRAM_ID                     NUMBER
, X_PROGRAM_UPDATE_DATE            DATE
, X_REQUEST_ID                     NUMBER
, X_EXCLUDER_FLAG                  VARCHAR2
, X_COMPARISON_OPERATOR_CODE       VARCHAR2
, X_QUALIFIER_CONTEXT              VARCHAR2
, X_QUALIFIER_ATTRIBUTE            VARCHAR2
, X_QUALIFIER_RULE_ID              NUMBER
, X_QUALIFIER_GROUPING_NO          NUMBER
, X_QUALIFIER_ATTR_VALUE           VARCHAR2
, X_LIST_HEADER_ID                 NUMBER
, X_LIST_LINE_ID                   NUMBER
, X_CREATED_FROM_RULE_ID           NUMBER
, X_START_DATE_ACTIVE              DATE
, X_END_DATE_ACTIVE                DATE
, X_CONTEXT                        VARCHAR2
, X_ATTRIBUTE1                     VARCHAR2
, X_ATTRIBUTE2                     VARCHAR2
, X_ATTRIBUTE3                     VARCHAR2
, X_ATTRIBUTE4                     VARCHAR2
, X_ATTRIBUTE5                     VARCHAR2
, X_ATTRIBUTE6                     VARCHAR2
, X_ATTRIBUTE7                     VARCHAR2
, X_ATTRIBUTE8                     VARCHAR2
, X_ATTRIBUTE9                     VARCHAR2
, X_ATTRIBUTE10                    VARCHAR2
, X_ATTRIBUTE11                    VARCHAR2
, X_ATTRIBUTE12                    VARCHAR2
, X_ATTRIBUTE13                    VARCHAR2
, X_ATTRIBUTE14                    VARCHAR2
, X_ATTRIBUTE15                    VARCHAR2
);

PROCEDURE Delete_Row(
X_ID		NUMBER
,X_HEADER_LINE_FLAG	VARCHAR2
);


END QP_QUALIFIER_PVT;

 

/
