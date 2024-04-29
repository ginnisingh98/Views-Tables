--------------------------------------------------------
--  DDL for Package CSP_EXCESS_RULES_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_EXCESS_RULES_B_PKG" AUTHID CURRENT_USER as
/* $Header: csptexrs.pls 115.5 2002/11/26 07:22:26 hhaugeru noship $ */
-- Start of Comments
-- Package name     : CSP_EXCESS_RULES_B_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_FILE_NAME CONSTANT VARCHAR2(12) := 'csptexrs.pls';
PROCEDURE Insert_Row(
          px_EXCESS_RULE_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_EXCESS_RULE_NAME    VARCHAR2,
          p_TOTAL_MAX_EXCESS    NUMBER,
          p_LINE_MAX_EXCESS    NUMBER,
          p_DAYS_SINCE_RECEIPT    NUMBER,
          p_TOTAL_EXCESS_VALUE    NUMBER,
          p_TOP_EXCESS_LINES    NUMBER,
          p_CATEGORY_SET_ID    NUMBER,
          p_CATEGORY_ID    NUMBER,
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
          p_DESCRIPTION       VARCHAR2);

PROCEDURE Update_Row(
          p_EXCESS_RULE_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_EXCESS_RULE_NAME    VARCHAR2,
          p_TOTAL_MAX_EXCESS    NUMBER,
          p_LINE_MAX_EXCESS    NUMBER,
          p_DAYS_SINCE_RECEIPT    NUMBER,
          p_TOTAL_EXCESS_VALUE    NUMBER,
          p_TOP_EXCESS_LINES    NUMBER,
          p_CATEGORY_SET_ID    NUMBER,
          p_CATEGORY_ID    NUMBER,
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
          p_DESCRIPTION       VARCHAR2);

PROCEDURE Lock_Row(
          p_EXCESS_RULE_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_EXCESS_RULE_NAME    VARCHAR2,
          p_TOTAL_MAX_EXCESS    NUMBER,
          p_LINE_MAX_EXCESS    NUMBER,
          p_DAYS_SINCE_RECEIPT    NUMBER,
          p_TOTAL_EXCESS_VALUE    NUMBER,
          p_TOP_EXCESS_LINES    NUMBER,
          p_CATEGORY_SET_ID    NUMBER,
          p_CATEGORY_ID    NUMBER,
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
          p_DESCRIPTION       VARCHAR2);

PROCEDURE Delete_Row(
    p_EXCESS_RULE_ID  NUMBER);
PROCEDURE Load_Row
( p_excess_rule_id    IN  NUMBER
, p_description         IN  VARCHAR2
, p_owner               IN VARCHAR2
);
PROCEDURE Translate_Row
( p_excess_rule_id     IN  NUMBER
, p_description          IN  VARCHAR2
, p_owner                IN  VARCHAR2
);
procedure ADD_LANGUAGE;
End CSP_EXCESS_RULES_B_PKG;

 

/
