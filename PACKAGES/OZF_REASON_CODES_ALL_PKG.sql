--------------------------------------------------------
--  DDL for Package OZF_REASON_CODES_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_REASON_CODES_ALL_PKG" AUTHID CURRENT_USER as
/* $Header: ozftreas.pls 120.1 2005/06/30 23:32:45 appldev ship $ */
-- Start of Comments
-- Package name     : OZF_REASON_CODES_ALL_PKG
-- Purpose          :
-- History          : 30-AUG-2001  mchang   add P_REASON_TYPE as passing in parameter.
-- History          : 28-SEP-2003  ANUJGUPT  Add one more column: PARTNER_ACCESS_FLAG  VARCHAR2(1)
-- History          : 22-Jun-2005  KDHULIPA  Add one more column: INVOICING_REASON_CODE  VARCHAR2(30)
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_REASON_CODE_ID   IN OUT NOCOPY NUMBER,
          px_OBJECT_VERSION_NUMBER   IN OUT NOCOPY NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REASON_CODE    VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          p_END_DATE_ACTIVE    DATE,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
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
          p_NAME           VARCHAR2,
          p_DESCRIPTION    VARCHAR2,
          px_ORG_ID   IN OUT NOCOPY NUMBER,
          P_REASON_TYPE    VARCHAR2,
          p_ADJUSTMENT_REASON_CODE    VARCHAR2,
	  p_INVOICING_REASON_CODE  VARCHAR2,
          px_ORDER_TYPE_ID    NUMBER,
	  p_PARTNER_ACCESS_FLAG  VARCHAR2);

PROCEDURE Update_Row(
          p_REASON_CODE_ID    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
--          p_CREATION_DATE    DATE,
--          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REASON_CODE    VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          p_END_DATE_ACTIVE    DATE,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
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
          p_NAME           VARCHAR2,
          p_DESCRIPTION    VARCHAR2,
          p_ORG_ID    NUMBER,
          P_REASON_TYPE    VARCHAR2,
          p_ADJUSTMENT_REASON_CODE    VARCHAR2,
	  p_INVOICING_REASON_CODE VARCHAR2,
          p_ORDER_TYPE_ID   NUMBER,
	  p_PARTNER_ACCESS_FLAG  VARCHAR2);

PROCEDURE Lock_Row(
          p_REASON_CODE_ID    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REASON_CODE    VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          p_END_DATE_ACTIVE    DATE,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
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
          p_NAME           VARCHAR2,
          p_DESCRIPTION    VARCHAR2,
          p_ORG_ID    NUMBER,
          P_REASON_TYPE    VARCHAR2,
          p_ADJUSTMENT_REASON_CODE    VARCHAR2,
	  p_INVOICING_REASON_CODE VARCHAR2,
          p_ORDER_TYPE_ID   NUMBER,
	  p_PARTNER_ACCESS_FLAG  VARCHAR2);

PROCEDURE Delete_Row(
    p_REASON_CODE_ID  NUMBER);
procedure ADD_LANGUAGE;
procedure TRANSLATE_ROW(
          X_REASON_CODE_ID      in NUMBER,
          X_NAME                in VARCHAR2,
          X_DESCRIPTION         in VARCHAR2,
          X_OWNER               in VARCHAR2
 ) ;
End OZF_REASON_CODES_ALL_PKG;

 

/
