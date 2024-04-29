--------------------------------------------------------
--  DDL for Package PA_PROJECT_STATUSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_STATUSES_PKG" AUTHID CURRENT_USER as
/* $Header: PASTAPTS.pls 120.0 2005/05/29 18:08:41 appldev noship $ */
-- Start of Comments
-- Package name     : PA_PROJECT_STATUSES_PKG
-- Purpose          : Table handler for PA_PROJECT_STATUSES
-- History          : 07-JUL-2000 Mohnish       Created
-- NOTE             :  The procedure in these packages need to be
--                  :  called through the PA_PROJECT_STATUSES_PVT
--                  :  procedures only
-- End of Comments

PROCEDURE Insert_Row(
          p_PROJECT_STATUS_CODE           VARCHAR2,
          p_PROJECT_STATUS_NAME           VARCHAR2,
          p_PROJECT_SYSTEM_STATUS_CODE    VARCHAR2,
          p_DESCRIPTION                   VARCHAR2,
          p_START_DATE_ACTIVE             DATE,
          p_END_DATE_ACTIVE               DATE,
          p_PREDEFINED_FLAG               VARCHAR2,
          p_STARTING_STATUS_FLAG          VARCHAR2,
          p_ENABLE_WF_FLAG                VARCHAR2,
          p_WORKFLOW_ITEM_TYPE            VARCHAR2,
          p_WORKFLOW_PROCESS              VARCHAR2,
          p_WF_SUCCESS_STATUS_CODE        VARCHAR2,
          p_WF_FAILURE_STATUS_CODE        VARCHAR2,
          p_LAST_UPDATE_DATE              DATE,
          p_LAST_UPDATED_BY               NUMBER,
          p_CREATION_DATE                 DATE,
          p_CREATED_BY                    NUMBER,
          p_LAST_UPDATE_LOGIN             NUMBER,
          p_ATTRIBUTE_CATEGORY            VARCHAR2,
          p_ATTRIBUTE1                    VARCHAR2,
          p_ATTRIBUTE2                    VARCHAR2,
          p_ATTRIBUTE3                    VARCHAR2,
          p_ATTRIBUTE4                    VARCHAR2,
          p_ATTRIBUTE5                    VARCHAR2,
          p_ATTRIBUTE6                    VARCHAR2,
          p_ATTRIBUTE7                    VARCHAR2,
          p_ATTRIBUTE8                    VARCHAR2,
          p_ATTRIBUTE9                    VARCHAR2,
          p_ATTRIBUTE10                   VARCHAR2,
          p_ATTRIBUTE11                   VARCHAR2,
          p_ATTRIBUTE12                   VARCHAR2,
          p_ATTRIBUTE13                   VARCHAR2,
          p_ATTRIBUTE14                   VARCHAR2,
          p_ATTRIBUTE15                   VARCHAR2,
          p_STATUS_TYPE                   VARCHAR2,
          p_NEXT_ALLOWABLE_STATUS_FLAG    VARCHAR2);

PROCEDURE Update_Row(
          p_PROJECT_STATUS_CODE           VARCHAR2,
          p_PROJECT_STATUS_NAME           VARCHAR2,
          p_PROJECT_SYSTEM_STATUS_CODE    VARCHAR2,
          p_DESCRIPTION                   VARCHAR2,
          p_START_DATE_ACTIVE             DATE,
          p_END_DATE_ACTIVE               DATE,
          p_PREDEFINED_FLAG               VARCHAR2,
          p_STARTING_STATUS_FLAG          VARCHAR2,
          p_ENABLE_WF_FLAG                VARCHAR2,
          p_WORKFLOW_ITEM_TYPE            VARCHAR2,
          p_WORKFLOW_PROCESS              VARCHAR2,
          p_WF_SUCCESS_STATUS_CODE        VARCHAR2,
          p_WF_FAILURE_STATUS_CODE        VARCHAR2,
          p_LAST_UPDATE_DATE              DATE,
          p_LAST_UPDATED_BY               NUMBER,
          p_CREATION_DATE                 DATE,
          p_CREATED_BY                    NUMBER,
          p_LAST_UPDATE_LOGIN             NUMBER,
          p_ATTRIBUTE_CATEGORY            VARCHAR2,
          p_ATTRIBUTE1                    VARCHAR2,
          p_ATTRIBUTE2                    VARCHAR2,
          p_ATTRIBUTE3                    VARCHAR2,
          p_ATTRIBUTE4                    VARCHAR2,
          p_ATTRIBUTE5                    VARCHAR2,
          p_ATTRIBUTE6                    VARCHAR2,
          p_ATTRIBUTE7                    VARCHAR2,
          p_ATTRIBUTE8                    VARCHAR2,
          p_ATTRIBUTE9                    VARCHAR2,
          p_ATTRIBUTE10                   VARCHAR2,
          p_ATTRIBUTE11                   VARCHAR2,
          p_ATTRIBUTE12                   VARCHAR2,
          p_ATTRIBUTE13                   VARCHAR2,
          p_ATTRIBUTE14                   VARCHAR2,
          p_ATTRIBUTE15                   VARCHAR2,
          p_STATUS_TYPE                   VARCHAR2,
          p_NEXT_ALLOWABLE_STATUS_FLAG    VARCHAR2);

PROCEDURE Lock_Row(
          p_PROJECT_STATUS_CODE           VARCHAR2,
          p_PROJECT_STATUS_NAME           VARCHAR2,
          p_PROJECT_SYSTEM_STATUS_CODE    VARCHAR2,
          p_DESCRIPTION                   VARCHAR2,
          p_START_DATE_ACTIVE             DATE,
          p_END_DATE_ACTIVE               DATE,
          p_PREDEFINED_FLAG               VARCHAR2,
          p_STARTING_STATUS_FLAG          VARCHAR2,
          p_ENABLE_WF_FLAG                VARCHAR2,
          p_WORKFLOW_ITEM_TYPE            VARCHAR2,
          p_WORKFLOW_PROCESS              VARCHAR2,
          p_WF_SUCCESS_STATUS_CODE        VARCHAR2,
          p_WF_FAILURE_STATUS_CODE        VARCHAR2,
          p_LAST_UPDATE_DATE              DATE,
          p_LAST_UPDATED_BY               NUMBER,
          p_CREATION_DATE                 DATE,
          p_CREATED_BY                    NUMBER,
          p_LAST_UPDATE_LOGIN             NUMBER,
          p_ATTRIBUTE_CATEGORY            VARCHAR2,
          p_ATTRIBUTE1                    VARCHAR2,
          p_ATTRIBUTE2                    VARCHAR2,
          p_ATTRIBUTE3                    VARCHAR2,
          p_ATTRIBUTE4                    VARCHAR2,
          p_ATTRIBUTE5                    VARCHAR2,
          p_ATTRIBUTE6                    VARCHAR2,
          p_ATTRIBUTE7                    VARCHAR2,
          p_ATTRIBUTE8                    VARCHAR2,
          p_ATTRIBUTE9                    VARCHAR2,
          p_ATTRIBUTE10                   VARCHAR2,
          p_ATTRIBUTE11                   VARCHAR2,
          p_ATTRIBUTE12                   VARCHAR2,
          p_ATTRIBUTE13                   VARCHAR2,
          p_ATTRIBUTE14                   VARCHAR2,
          p_ATTRIBUTE15                   VARCHAR2,
          p_STATUS_TYPE                   VARCHAR2,
          p_NEXT_ALLOWABLE_STATUS_FLAG    VARCHAR2);

PROCEDURE Delete_Row(
    p_PROJECT_STATUS_CODE  VARCHAR2);


End PA_PROJECT_STATUSES_PKG;

 

/
