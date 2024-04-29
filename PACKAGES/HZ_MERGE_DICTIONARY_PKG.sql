--------------------------------------------------------
--  DDL for Package HZ_MERGE_DICTIONARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MERGE_DICTIONARY_PKG" AUTHID CURRENT_USER as
/* $Header: ARHMDTBS.pls 120.5 2006/04/26 09:36:20 vsegu noship $ */
-- Start of Comments
-- Package name     : HZ_MERGE_DICTIONARY_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Validate_Parent_Entity(
          p_parent_entity  VARCHAR2,
          p_owner IN VARCHAR2,
          p_error_text OUT NOCOPY VARCHAR2,
          p_return_status OUT NOCOPY VARCHAR2);
PROCEDURE Validate_Primary_Key(
          p_primary_key VARCHAR2,
          p_owner IN VARCHAR2,
          p_entity_name VARCHAR2,
          p_error_message OUT NOCOPY VARCHAR2,
          p_return_status OUT NOCOPY VARCHAR2);
PROCEDURE Validate_Foreign_Key(
          p_foreign_key IN VARCHAR2,
          p_owner IN VARCHAR2,
          p_entity_name IN VARCHAR2,
          p_error_message OUT NOCOPY VARCHAR2,
          p_return_status OUT NOCOPY VARCHAR2);
PROCEDURE Validate_Entity(
  p_entity_name IN VARCHAR2,
  p_owner IN VARCHAR2,
  p_error_message OUT NOCOPY VARCHAR2,
  p_return_status OUT NOCOPY VARCHAR2);


PROCEDURE Insert_Row(
          px_MERGE_DICT_ID   IN OUT NOCOPY NUMBER,
          p_RULE_SET_NAME    VARCHAR2,
          p_ENTITY_NAME    VARCHAR2,
          p_PARENT_ENTITY_NAME    VARCHAR2,
          p_PK_COLUMN_NAME    VARCHAR2,
          p_FK_COLUMN_NAME    VARCHAR2,
          p_DESC_COLUMN_NAME    VARCHAR2,
          p_PROCEDURE_TYPE    VARCHAR2,
          p_PROCEDURE_NAME    VARCHAR2,
          p_JOIN_CLAUSE    VARCHAR2,
          p_DICT_APPLICATION_ID    NUMBER,
          p_DESCRIPTION    VARCHAR2,
          px_SEQUENCE_NO    IN OUT NOCOPY NUMBER,
          p_BULK_FLAG    VARCHAR2,
	  p_BATCH_MERGE_FLAG VARCHAR2, --4634891
	  p_VALIDATE_PURGE_FLAG VARCHAR2, --5125968
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER);

PROCEDURE Update_Row(
          p_MERGE_DICT_ID    NUMBER,
          p_RULE_SET_NAME    VARCHAR2,
          p_ENTITY_NAME    VARCHAR2,
          p_PARENT_ENTITY_NAME    VARCHAR2,
          p_PK_COLUMN_NAME    VARCHAR2,
          p_FK_COLUMN_NAME    VARCHAR2,
          p_DESC_COLUMN_NAME    VARCHAR2,
          p_PROCEDURE_TYPE    VARCHAR2,
          p_PROCEDURE_NAME    VARCHAR2,
          p_JOIN_CLAUSE    VARCHAR2,
          p_DICT_APPLICATION_ID    NUMBER,
          p_DESCRIPTION    VARCHAR2,
          px_SEQUENCE_NO    IN OUT NOCOPY NUMBER,
          p_BULK_FLAG    VARCHAR2,
	  p_BATCH_MERGE_FLAG VARCHAR2, --4634891
	  p_VALIDATE_PURGE_FLAG VARCHAR2, --5125968
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER);

PROCEDURE Lock_Row(
          p_MERGE_DICT_ID    NUMBER,
          p_RULE_SET_NAME    VARCHAR2,
          p_ENTITY_NAME    VARCHAR2,
          p_PARENT_ENTITY_NAME    VARCHAR2,
          p_PK_COLUMN_NAME    VARCHAR2,
          p_FK_COLUMN_NAME    VARCHAR2,
          p_DESC_COLUMN_NAME    VARCHAR2,
          p_PROCEDURE_TYPE    VARCHAR2,
          p_PROCEDURE_NAME    VARCHAR2,
          p_JOIN_CLAUSE    VARCHAR2,
          p_DICT_APPLICATION_ID    NUMBER,
          p_DESCRIPTION    VARCHAR2,
          p_SEQUENCE_NO    NUMBER,
          p_BULK_FLAG    VARCHAR2,
	  p_BATCH_MERGE_FLAG VARCHAR2, --4634891
	  p_VALIDATE_PURGE_FLAG VARCHAR2, --5125968
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER);

PROCEDURE Delete_Row(
    p_MERGE_DICT_ID  NUMBER);
End HZ_MERGE_DICTIONARY_PKG;

 

/
