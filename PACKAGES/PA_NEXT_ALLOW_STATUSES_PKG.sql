--------------------------------------------------------
--  DDL for Package PA_NEXT_ALLOW_STATUSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_NEXT_ALLOW_STATUSES_PKG" AUTHID CURRENT_USER as
/* $Header: PASTANTS.pls 120.0 2005/05/30 08:10:35 appldev noship $ */
-- Start of Comments
-- Package name     : PA_NEXT_ALLOW_STATUSES_PKG
-- Purpose          : Table handler for PA_NEXT_ALLOW_STATUSES
-- History          : 07-JUL-2000 Mohnish       Created
-- NOTE             :  The procedure in these packages need to be
--                  :  called through the PA_NEXT_ALLOW_STATUSES_PVT
--                  :  procedures only
-- End of Comments

PROCEDURE Insert_Row(
          p_STATUS_CODE                   VARCHAR2,
          p_NEXT_ALLOWABLE_STATUS_CODE    VARCHAR2,
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
          p_ATTRIBUTE15                   VARCHAR2);

PROCEDURE Update_Row(
          p_STATUS_CODE                   VARCHAR2,
          p_NEXT_ALLOWABLE_STATUS_CODE    VARCHAR2,
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
          p_ATTRIBUTE15                   VARCHAR2);

PROCEDURE Lock_Row(
          p_STATUS_CODE                   VARCHAR2,
          p_NEXT_ALLOWABLE_STATUS_CODE    VARCHAR2,
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
          p_ATTRIBUTE15                   VARCHAR2);

PROCEDURE Delete_Row(
    p_STATUS_CODE  VARCHAR2);
End PA_NEXT_ALLOW_STATUSES_PKG;

 

/
