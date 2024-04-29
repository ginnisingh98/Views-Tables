--------------------------------------------------------
--  DDL for Package ASO_SALES_CREDITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_SALES_CREDITS_PKG" AUTHID CURRENT_USER as
/* $Header: asotqscs.pls 120.0 2005/05/31 12:31:57 appldev noship $ */
-- Start of Comments
-- Package name     : ASO_SALES_CREDITS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATED_BY    VARCHAR2,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          px_SALES_CREDIT_ID   IN OUT NOCOPY  NUMBER,
          p_QUOTE_HEADER_ID    NUMBER,
          p_QUOTE_LINE_ID    NUMBER,
          p_PERCENT    NUMBER,
          p_RESOURCE_ID    NUMBER,
          p_RESOURCE_GROUP_ID    NUMBER,
          p_EMPLOYEE_PERSON_ID    NUMBER,
          p_SALES_CREDIT_TYPE_ID    NUMBER,
--          p_SECURITY_GROUP_ID    NUMBER,
          p_ATTRIBUTE_CATEGORY_CODE    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_ATTRIBUTE16    VARCHAR2,
          p_ATTRIBUTE17    VARCHAR2,
          p_ATTRIBUTE18    VARCHAR2,
          p_ATTRIBUTE19    VARCHAR2,
          p_ATTRIBUTE20    VARCHAR2,
		p_SYSTEM_ASSIGNED_FLAG VARCHAR2,
		p_CREDIT_RULE_ID  NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER);

PROCEDURE Update_Row(
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATED_BY    VARCHAR2,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_SALES_CREDIT_ID    NUMBER,
          p_QUOTE_HEADER_ID    NUMBER,
          p_QUOTE_LINE_ID    NUMBER,
          p_PERCENT    NUMBER,
          p_RESOURCE_ID    NUMBER,
          p_RESOURCE_GROUP_ID    NUMBER,
          p_EMPLOYEE_PERSON_ID    NUMBER,
          p_SALES_CREDIT_TYPE_ID    NUMBER,
--          p_SECURITY_GROUP_ID    NUMBER,
          p_ATTRIBUTE_CATEGORY_CODE    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_ATTRIBUTE16    VARCHAR2,
          p_ATTRIBUTE17    VARCHAR2,
          p_ATTRIBUTE18    VARCHAR2,
          p_ATTRIBUTE19    VARCHAR2,
          p_ATTRIBUTE20    VARCHAR2,
	  p_SYSTEM_ASSIGNED_FLAG VARCHAR2,
	  p_CREDIT_RULE_ID  NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER);

PROCEDURE Lock_Row(
          --p_OBJECT_VERSION_NUMBER  NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATED_BY    VARCHAR2,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_SALES_CREDIT_ID    NUMBER,
          p_QUOTE_HEADER_ID    NUMBER,
          p_QUOTE_LINE_ID    NUMBER,
          p_PERCENT    NUMBER,
          p_RESOURCE_ID    NUMBER,
          p_RESOURCE_GROUP_ID    NUMBER,
          p_EMPLOYEE_PERSON_ID    NUMBER,
          p_SALES_CREDIT_TYPE_ID    NUMBER,
--          p_SECURITY_GROUP_ID    NUMBER,
          p_ATTRIBUTE_CATEGORY_CODE    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2);
--          p_OBJECT_VERSION_NUMBER    NUMBER);

PROCEDURE Delete_Row(
    p_SALES_CREDIT_ID  NUMBER);

PROCEDURE Delete_Row(
    p_QUOTE_LINE_ID  NUMBER);

PROCEDURE Delete_Row(
    p_QUOTE_HEADER_ID  NUMBER);

PROCEDURE Delete_Header_Row(
    p_QUOTE_HEADER_ID  NUMBER);


End ASO_SALES_CREDITS_PKG;

 

/
