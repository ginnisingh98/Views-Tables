--------------------------------------------------------
--  DDL for Package AS_LEAD_DECISION_FACTORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_LEAD_DECISION_FACTORS_PKG" AUTHID CURRENT_USER as
/* $Header: asxtdfcs.pls 115.5 2002/12/13 12:25:35 nkamble ship $ */
-- Start of Comments
-- Package name     : AS_LEAD_DECISION_FACTORS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          p_ATTRIBUTE15    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_DECISION_RANK    NUMBER,
          p_DECISION_PRIORITY_CODE    VARCHAR2,
          p_DECISION_FACTOR_CODE    VARCHAR2,
          px_LEAD_DECISION_FACTOR_ID   IN OUT NOCOPY NUMBER,
          p_LEAD_LINE_ID    NUMBER,
          p_CREATE_BY    NUMBER,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_CREATION_DATE    DATE);

PROCEDURE Update_Row(
          p_ATTRIBUTE15    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_DECISION_RANK    NUMBER,
          p_DECISION_PRIORITY_CODE    VARCHAR2,
          p_DECISION_FACTOR_CODE    VARCHAR2,
          p_LEAD_DECISION_FACTOR_ID    NUMBER,
          p_LEAD_LINE_ID    NUMBER,
          p_CREATE_BY    NUMBER,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_CREATION_DATE    DATE);

PROCEDURE Lock_Row(
          p_ATTRIBUTE15    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_DECISION_RANK    NUMBER,
          p_DECISION_PRIORITY_CODE    VARCHAR2,
          p_DECISION_FACTOR_CODE    VARCHAR2,
          p_LEAD_DECISION_FACTOR_ID    NUMBER,
          p_LEAD_LINE_ID    NUMBER,
          p_CREATE_BY    NUMBER,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_CREATION_DATE    DATE);

PROCEDURE Delete_Row(
    p_LEAD_DECISION_FACTOR_ID  NUMBER);
End AS_LEAD_DECISION_FACTORS_PKG;

 

/
