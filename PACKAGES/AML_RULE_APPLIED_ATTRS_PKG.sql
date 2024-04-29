--------------------------------------------------------
--  DDL for Package AML_RULE_APPLIED_ATTRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AML_RULE_APPLIED_ATTRS_PKG" AUTHID CURRENT_USER as
/* $Header: amltrlgs.pls 115.1 2003/08/29 00:39:45 ckapoor noship $ */
-- Start of Comments
-- Package name     : AML_RULE_APPLIED_ATTRS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_RULE_APPLIED_ATTR_ID   IN OUT NOCOPY  NUMBER
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
         ,p_ENTITY_RULE_APPLIED_ID    NUMBER
         ,p_ATTRIBUTE_ID    NUMBER
         ,p_OPERATOR    VARCHAR2
         ,p_ATTRIBUTE_VALUE    VARCHAR2
         ,p_ATTRIBUTE_TO_VALUE    VARCHAR2
         ,p_LEAD_VALUE    VARCHAR2
);
PROCEDURE Update_Row(
          p_RULE_APPLIED_ATTR_ID    NUMBER
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
         ,p_ENTITY_RULE_APPLIED_ID    NUMBER
         ,p_ATTRIBUTE_ID    NUMBER
         ,p_OPERATOR    VARCHAR2
         ,p_ATTRIBUTE_VALUE    VARCHAR2
         ,p_ATTRIBUTE_TO_VALUE    VARCHAR2
         ,p_LEAD_VALUE    VARCHAR2
);
PROCEDURE Lock_Row(
          p_RULE_APPLIED_ATTR_ID    NUMBER
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
         ,p_ENTITY_RULE_APPLIED_ID    NUMBER
         ,p_ATTRIBUTE_ID    NUMBER
         ,p_OPERATOR    VARCHAR2
         ,p_ATTRIBUTE_VALUE    VARCHAR2
         ,p_ATTRIBUTE_TO_VALUE    VARCHAR2
         ,p_LEAD_VALUE    VARCHAR2
);
PROCEDURE Delete_Row(
    p_RULE_APPLIED_ATTR_ID  NUMBER);
End AML_RULE_APPLIED_ATTRS_PKG;

 

/
