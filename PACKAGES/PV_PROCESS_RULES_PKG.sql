--------------------------------------------------------
--  DDL for Package PV_PROCESS_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PROCESS_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: pvrtprus.pls 120.1 2006/05/31 18:42:12 solin noship $ */
-- Start of Comments
-- Package name     : PV_PROCESS_RULES_PKG
-- Purpose          :
-- History          :
--      01/08/2002  SOLIN    Created.
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_PROCESS_RULE_ID   IN OUT NOCOPY NUMBER
         ,p_PARENT_RULE_ID   IN NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_CREATED_BY    NUMBER
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_REQUEST_ID    NUMBER
         ,p_PROGRAM_APPLICATION_ID    NUMBER
         ,p_PROGRAM_ID    NUMBER
         ,p_PROGRAM_UPDATE_DATE    DATE
         ,p_PROCESS_TYPE    VARCHAR2
         ,p_RANK    NUMBER
         ,p_STATUS_CODE    VARCHAR2
         ,p_START_DATE    DATE
         ,p_END_DATE    DATE
         ,p_ACTION    VARCHAR2
         ,p_ACTION_VALUE    VARCHAR2
         ,p_OWNER_RESOURCE_ID    NUMBER
         ,p_CURRENCY_CODE    VARCHAR2
         ,p_PROCESS_RULE_NAME    VARCHAR2
         ,p_DESCRIPTION    VARCHAR2
         ,p_ATTRIBUTE_CATEGORY    VARCHAR2
         ,p_ATTRIBUTE1    VARCHAR2
         ,p_ATTRIBUTE2    VARCHAR2
         ,p_ATTRIBUTE3    VARCHAR2
         ,p_ATTRIBUTE4    VARCHAR2
         ,p_ATTRIBUTE5    VARCHAR2
         ,p_ATTRIBUTE6    VARCHAR2
         ,p_ATTRIBUTE7    VARCHAR2
         ,p_ATTRIBUTE8    VARCHAR2
         ,p_ATTRIBUTE9    VARCHAR2
         ,p_ATTRIBUTE10    VARCHAR2
         ,p_ATTRIBUTE11    VARCHAR2
         ,p_ATTRIBUTE12    VARCHAR2
         ,p_ATTRIBUTE13    VARCHAR2
         ,p_ATTRIBUTE14    VARCHAR2
         ,p_ATTRIBUTE15    VARCHAR2
);
PROCEDURE Update_Row(
          p_PROCESS_RULE_ID    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_CREATED_BY    NUMBER
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_REQUEST_ID    NUMBER
         ,p_PROGRAM_APPLICATION_ID    NUMBER
         ,p_PROGRAM_ID    NUMBER
         ,p_PROGRAM_UPDATE_DATE    DATE
         ,p_PROCESS_TYPE    VARCHAR2
         ,p_RANK    NUMBER
         ,p_STATUS_CODE    VARCHAR2
         ,p_START_DATE    DATE
         ,p_END_DATE    DATE
         ,p_ACTION    VARCHAR2
         ,p_ACTION_VALUE    VARCHAR2
         ,p_OWNER_RESOURCE_ID    NUMBER
         ,p_CURRENCY_CODE    VARCHAR2
         ,p_PROCESS_RULE_NAME    VARCHAR2
         ,p_DESCRIPTION    VARCHAR2
         ,p_ATTRIBUTE_CATEGORY    VARCHAR2
         ,p_ATTRIBUTE1    VARCHAR2
         ,p_ATTRIBUTE2    VARCHAR2
         ,p_ATTRIBUTE3    VARCHAR2
         ,p_ATTRIBUTE4    VARCHAR2
         ,p_ATTRIBUTE5    VARCHAR2
         ,p_ATTRIBUTE6    VARCHAR2
         ,p_ATTRIBUTE7    VARCHAR2
         ,p_ATTRIBUTE8    VARCHAR2
         ,p_ATTRIBUTE9    VARCHAR2
         ,p_ATTRIBUTE10    VARCHAR2
         ,p_ATTRIBUTE11    VARCHAR2
         ,p_ATTRIBUTE12    VARCHAR2
         ,p_ATTRIBUTE13    VARCHAR2
         ,p_ATTRIBUTE14    VARCHAR2
         ,p_ATTRIBUTE15    VARCHAR2
);
PROCEDURE Lock_Row(
          p_PROCESS_RULE_ID    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_CREATED_BY    NUMBER
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_REQUEST_ID    NUMBER
         ,p_PROGRAM_APPLICATION_ID    NUMBER
         ,p_PROGRAM_ID    NUMBER
         ,p_PROGRAM_UPDATE_DATE    DATE
         ,p_PROCESS_TYPE    VARCHAR2
         ,p_RANK    NUMBER
         ,p_STATUS_CODE    VARCHAR2
         ,p_START_DATE    DATE
         ,p_END_DATE    DATE
         ,p_ACTION    VARCHAR2
         ,p_ACTION_VALUE    VARCHAR2
         ,p_OWNER_RESOURCE_ID    NUMBER
         ,p_CURRENCY_CODE    VARCHAR2
         ,p_PROCESS_RULE_NAME    VARCHAR2
         ,p_DESCRIPTION    VARCHAR2
         ,p_ATTRIBUTE_CATEGORY    VARCHAR2
         ,p_ATTRIBUTE1    VARCHAR2
         ,p_ATTRIBUTE2    VARCHAR2
         ,p_ATTRIBUTE3    VARCHAR2
         ,p_ATTRIBUTE4    VARCHAR2
         ,p_ATTRIBUTE5    VARCHAR2
         ,p_ATTRIBUTE6    VARCHAR2
         ,p_ATTRIBUTE7    VARCHAR2
         ,p_ATTRIBUTE8    VARCHAR2
         ,p_ATTRIBUTE9    VARCHAR2
         ,p_ATTRIBUTE10    VARCHAR2
         ,p_ATTRIBUTE11    VARCHAR2
         ,p_ATTRIBUTE12    VARCHAR2
         ,p_ATTRIBUTE13    VARCHAR2
         ,p_ATTRIBUTE14    VARCHAR2
         ,p_ATTRIBUTE15    VARCHAR2
);

PROCEDURE Delete_Row(
    p_PROCESS_RULE_ID  NUMBER);

PROCEDURE Add_Language;

PROCEDURE Load_Row (
  px_PROCESS_RULE_ID        IN OUT NOCOPY NUMBER,
  p_PARENT_RULE_ID          IN NUMBER,
  p_PROCESS_TYPE            IN VARCHAR2,
  p_RANK                    IN NUMBER,
  p_STATUS_CODE             IN VARCHAR2,
  p_START_DATE              IN DATE,
  p_END_DATE                IN DATE,
  p_ACTION                  IN VARCHAR2,
  p_ACTION_VALUE            IN VARCHAR2,
  p_OWNER_RESOURCE_ID       IN NUMBER,
  p_CURRENCY_CODE           IN VARCHAR2,
  p_PROCESS_RULE_NAME       IN VARCHAR2,
  p_DESCRIPTION             IN VARCHAR2,
  p_OWNER                   IN VARCHAR2
);

PROCEDURE Translate_Row(
           px_PROCESS_RULE_ID		    IN  NUMBER
          ,p_PROCESS_RULE_NAME              IN  VARCHAR2
          ,p_DESCRIPTION	            IN  VARCHAR2
	  ,p_OWNER_RESOURCE_ID		    IN  VARCHAR2
          );

End PV_PROCESS_RULES_PKG;

 

/
