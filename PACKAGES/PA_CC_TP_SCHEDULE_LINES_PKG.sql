--------------------------------------------------------
--  DDL for Package PA_CC_TP_SCHEDULE_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CC_TP_SCHEDULE_LINES_PKG" AUTHID CURRENT_USER AS
 /* $Header: PAXTPSLS.pls 120.1 2005/08/05 02:17:12 rgandhi noship $ */
procedure INSERT_ROW (
 X_ROWID                        in out NOCOPY varchar2, /*File.sql.39*/
 X_SCHEDULE_LINE_ID             in  NUMBER,
 X_TP_SCHEDULE_ID               in  NUMBER,
 X_PRVDR_ORGANIZATION_ID        in   NUMBER,
 X_START_DATE_ACTIVE            in   DATE,
 X_DEFAULT_FLAG                 in   VARCHAR2,
 X_TP_AMT_TYPE_CODE		in   VARCHAR2,
 X_LAST_UPDATE_DATE             in   DATE,
 X_LAST_UPDATED_BY              in   NUMBER,
 X_CREATION_DATE                in   DATE,
 X_CREATED_BY                   in   NUMBER,
 X_LAST_UPDATE_LOGIN            in   NUMBER,
 X_SORT_ORDER                   in   NUMBER,
 X_LABOR_TP_RULE_ID             in   NUMBER,
 X_LABOR_PERCENTAGE_APPLIED     in   NUMBER,
 X_NL_TP_RULE_ID                in   NUMBER,
 X_NL_PERCENTAGE_APPLIED        in   NUMBER,
 X_RECVR_ORGANIZATION_ID        in   NUMBER,
 X_END_DATE_ACTIVE              in   DATE,
 X_ATTRIBUTE_CATEGORY          in            VARCHAR2,
 X_ATTRIBUTE1                  in             VARCHAR2,
 X_ATTRIBUTE2                  in             VARCHAR2,
 X_ATTRIBUTE3                  in             VARCHAR2,
 X_ATTRIBUTE4                  in             VARCHAR2,
 X_ATTRIBUTE5                  in             VARCHAR2,
 X_ATTRIBUTE6                  in             VARCHAR2,
 X_ATTRIBUTE7                  in             VARCHAR2,
 X_ATTRIBUTE8                  in             VARCHAR2,
 X_ATTRIBUTE9                  in             VARCHAR2,
 X_ATTRIBUTE10                 in             VARCHAR2,
 X_ATTRIBUTE11                 in             VARCHAR2,
 X_ATTRIBUTE12                 in             VARCHAR2,
 X_ATTRIBUTE13                 in             VARCHAR2,
 X_ATTRIBUTE14                 in             VARCHAR2,
 X_ATTRIBUTE15                 in             VARCHAR2
);
procedure LOCK_ROW (
 X_SCHEDULE_LINE_ID             in  NUMBER,
 X_TP_SCHEDULE_ID               in  NUMBER,
 X_PRVDR_ORGANIZATION_ID        in   NUMBER,
 X_START_DATE_ACTIVE            in   DATE,
 X_DEFAULT_FLAG                 in   VARCHAR2,
 X_TP_AMT_TYPE_CODE		in   VARCHAR2,
 X_LAST_UPDATE_DATE             in   DATE,
 X_LAST_UPDATED_BY              in   NUMBER,
 X_CREATION_DATE                in   DATE,
 X_CREATED_BY                   in   NUMBER,
 X_LAST_UPDATE_LOGIN            in   NUMBER,
 X_SORT_ORDER                   in   NUMBER,
 X_LABOR_TP_RULE_ID             in   NUMBER,
 X_LABOR_PERCENTAGE_APPLIED     in   NUMBER,
 X_NL_TP_RULE_ID                in   NUMBER,
 X_NL_PERCENTAGE_APPLIED        in   NUMBER,
 X_RECVR_ORGANIZATION_ID        in   NUMBER,
 X_END_DATE_ACTIVE              in   DATE,
 X_ATTRIBUTE_CATEGORY          in            VARCHAR2,
 X_ATTRIBUTE1                  in             VARCHAR2,
 X_ATTRIBUTE2                  in             VARCHAR2,
 X_ATTRIBUTE3                  in             VARCHAR2,
 X_ATTRIBUTE4                  in             VARCHAR2,
 X_ATTRIBUTE5                  in             VARCHAR2,
 X_ATTRIBUTE6                  in             VARCHAR2,
 X_ATTRIBUTE7                  in             VARCHAR2,
 X_ATTRIBUTE8                  in             VARCHAR2,
 X_ATTRIBUTE9                  in             VARCHAR2,
 X_ATTRIBUTE10                 in             VARCHAR2,
 X_ATTRIBUTE11                 in             VARCHAR2,
 X_ATTRIBUTE12                 in             VARCHAR2,
 X_ATTRIBUTE13                 in             VARCHAR2,
 X_ATTRIBUTE14                 in             VARCHAR2,
 X_ATTRIBUTE15                 in             VARCHAR2
);
procedure UPDATE_ROW (
 X_ROWID                        in varchar2,
 X_SCHEDULE_LINE_ID             in  NUMBER,
 X_TP_SCHEDULE_ID               in  NUMBER,
 X_PRVDR_ORGANIZATION_ID        in   NUMBER,
 X_START_DATE_ACTIVE            in   DATE,
 X_DEFAULT_FLAG                 in   VARCHAR2,
 X_TP_AMT_TYPE_CODE		in   VARCHAR2,
 X_LAST_UPDATE_DATE             in DATE,
 X_LAST_UPDATED_BY              in NUMBER,
 X_LAST_UPDATE_LOGIN            in NUMBER,
 X_SORT_ORDER                   in   NUMBER,
 X_LABOR_TP_RULE_ID             in   NUMBER,
 X_LABOR_PERCENTAGE_APPLIED     in   NUMBER,
 X_NL_TP_RULE_ID                in   NUMBER,
 X_NL_PERCENTAGE_APPLIED        in   NUMBER,
 X_RECVR_ORGANIZATION_ID        in   NUMBER,
 X_END_DATE_ACTIVE              in   DATE,
 X_ATTRIBUTE_CATEGORY          in            VARCHAR2,
 X_ATTRIBUTE1                  in             VARCHAR2,
 X_ATTRIBUTE2                  in             VARCHAR2,
 X_ATTRIBUTE3                  in             VARCHAR2,
 X_ATTRIBUTE4                  in             VARCHAR2,
 X_ATTRIBUTE5                  in             VARCHAR2,
 X_ATTRIBUTE6                  in             VARCHAR2,
 X_ATTRIBUTE7                  in             VARCHAR2,
 X_ATTRIBUTE8                  in             VARCHAR2,
 X_ATTRIBUTE9                  in             VARCHAR2,
 X_ATTRIBUTE10                 in             VARCHAR2,
 X_ATTRIBUTE11                 in             VARCHAR2,
 X_ATTRIBUTE12                 in             VARCHAR2,
 X_ATTRIBUTE13                 in             VARCHAR2,
 X_ATTRIBUTE14                 in             VARCHAR2,
 X_ATTRIBUTE15                 in             VARCHAR2
);

procedure DELETE_ROW (
X_ROWID in varchar2
);
end PA_CC_TP_SCHEDULE_LINES_PKG;

 

/
