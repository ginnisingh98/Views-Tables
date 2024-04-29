--------------------------------------------------------
--  DDL for Package Body JTF_CHANGED_TERR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_CHANGED_TERR_PKG" AS
/* $Header: jtfvctrb.pls 115.7 2000/06/05 17:00:38 pkm ship   $ */

PROCEDURE Insert_Row(
          px_TERR_ID   IN OUT NUMBER,
          P_TERR_VALUE_ID IN NUMBER,
          p_TRIGGER_MODE    VARCHAR2,
          p_ACTION    VARCHAR2,
          p_PARENT_TERRITORY_ID    NUMBER,
          p_O_START_DATE_ACTIVE    DATE,
          p_O_END_DATE_ACTIVE    DATE,
          p_O_RANK    NUMBER,
          p_O_UPDATE_FLAG    VARCHAR2,
          p_N_START_DATE_ACTIVE    DATE,
          p_N_END_DATE_ACTIVE    DATE,
          p_N_RANK    NUMBER,
          p_N_UPDATE_FLAG    VARCHAR2,
          p_O_LAST_UPDATED_BY    NUMBER,
          p_O_LAST_UPDATE_DATE    DATE,
          p_O_CREATED_BY    NUMBER,
          p_O_CREATION_DATE    DATE,
          p_O_LAST_UPDATE_LOGIN    NUMBER,
          p_O_TERR_QUAL_ID    NUMBER,
          p_O_INCLUDE_FLAG    VARCHAR2,
          p_O_COMPARISON_OPERATOR    VARCHAR2,
          p_O_ID_USED_FLAG    VARCHAR2,
          p_O_LOW_VALUE_CHAR_ID    NUMBER,
          p_O_LOW_VALUE_CHAR    VARCHAR2,
          p_O_HIGH_VALUE_CHAR    VARCHAR2,
          p_O_LOW_VALUE_NUMBER    NUMBER,
          p_O_HIGH_VALUE_NUMBER    NUMBER,
          p_O_VALUE_SET    NUMBER,
          p_O_INTEREST_TYPE_ID    NUMBER,
          p_O_PRI_INTEREST_CODE_ID    NUMBER,
          p_O_SEC_INTEREST_CODE_ID    NUMBER,
          p_O_CURRENCY_CODE    VARCHAR2,
          p_N_LAST_UPDATED_BY    NUMBER,
          p_N_LAST_UPDATE_DATE    DATE,
          p_N_CREATED_BY    NUMBER,
          p_N_CREATION_DATE    DATE,
          p_N_LAST_UPDATE_LOGIN    NUMBER,
          p_N_TERR_QUAL_ID    NUMBER,
          p_N_INCLUDE_FLAG    VARCHAR2,
          p_N_COMPARISON_OPERATOR    VARCHAR2,
          p_N_ID_USED_FLAG    VARCHAR2,
          p_N_LOW_VALUE_CHAR_ID    NUMBER,
          p_N_LOW_VALUE_CHAR    VARCHAR2,
          p_N_HIGH_VALUE_CHAR    VARCHAR2,
          p_N_LOW_VALUE_NUMBER    NUMBER,
          p_N_HIGH_VALUE_NUMBER    NUMBER,
          p_N_VALUE_SET    NUMBER,
          p_N_INTEREST_TYPE_ID    NUMBER,
          p_N_PRI_INTEREST_CODE_ID    NUMBER,
          p_N_SEC_INTEREST_CODE_ID    NUMBER,
          p_N_CURRENCY_CODE    VARCHAR2,
          p_O_RESOURCE_ID    NUMBER,
          p_O_RESOURCE_TYPE    VARCHAR2,
          p_O_ROLE    VARCHAR2,
          p_O_PRI_CONTACT_FLAG    VARCHAR2,
          p_O_FULL_ACCESS_FLAG    VARCHAR2,
          p_N_RESOURCE_ID    NUMBER,
          p_N_RESOURCE_TYPE    VARCHAR2,
          p_N_ROLE    VARCHAR2,
          p_N_PRI_CONTACT_FLAG    VARCHAR2,
          p_N_FULL_ACCESS_FLAG    VARCHAR2,
          p_TRANSFER_ONLY_FLAG    VARCHAR2,
          p_REQUEST_ID    NUMBER,
          p_TERR_RSC_ID    NUMBER,
          p_ORG_ID         NUMBER)

IS
BEGIN
   INSERT INTO JTF_CHANGED_TERR_ALL(
           TERR_ID,
           TERR_VALUE_ID,
           TRIGGER_MODE,
           ACTION,
           PARENT_TERRITORY_ID,
           OLD_START_DATE_ACTIVE,
           OLD_END_DATE_ACTIVE,
           OLD_RANK,
           OLD_UPDATE_FLAG,
           NEW_START_DATE_ACTIVE,
           NEW_END_DATE_ACTIVE,
           NEW_RANK,
           NEW_UPDATE_FLAG,
           OLD_LAST_UPDATED_BY,
           OLD_LAST_UPDATE_DATE,
           OLD_CREATED_BY,
           OLD_CREATION_DATE,
           OLD_LAST_UPDATE_LOGIN,
           OLD_TERR_QUAL_ID,
           OLD_INCLUDE_FLAG,
           OLD_COMPARISON_OPERATOR,
           OLD_ID_USED_FLAG,
           OLD_LOW_VALUE_CHAR_ID,
           OLD_LOW_VALUE_CHAR,
           OLD_HIGH_VALUE_CHAR,
           OLD_LOW_VALUE_NUMBER,
           OLD_HIGH_VALUE_NUMBER,
           OLD_VALUE_SET,
           OLD_INTEREST_TYPE_ID,
           OLD_PRIMARY_INTEREST_CODE_ID,
           OLD_SECONDARY_INTEREST_CODE_ID,
           OLD_CURRENCY_CODE,
           NEW_LAST_UPDATED_BY,
           NEW_LAST_UPDATE_DATE,
           NEW_CREATED_BY,
           NEW_CREATION_DATE,
           NEW_LAST_UPDATE_LOGIN,
           NEW_TERR_QUAL_ID,
           NEW_INCLUDE_FLAG,
           NEW_COMPARISON_OPERATOR,
           NEW_ID_USED_FLAG,
           NEW_LOW_VALUE_CHAR_ID,
           NEW_LOW_VALUE_CHAR,
           NEW_HIGH_VALUE_CHAR,
           NEW_LOW_VALUE_NUMBER,
           NEW_HIGH_VALUE_NUMBER,
           NEW_VALUE_SET,
           NEW_INTEREST_TYPE_ID,
           NEW_PRIMARY_INTEREST_CODE_ID,
           NEW_SECONDARY_INTEREST_CODE_ID,
           NEW_CURRENCY_CODE,
           OLD_RESOURCE_ID,
           OLD_RESOURCE_TYPE,
           OLD_ROLE,
           OLD_PRIMARY_CONTACT_FLAG,
           OLD_FULL_ACCESS_FLAG,
           NEW_RESOURCE_ID,
           NEW_RESOURCE_TYPE,
           NEW_ROLE,
           NEW_PRIMARY_CONTACT_FLAG,
           NEW_FULL_ACCESS_FLAG,
           TRANSFER_ONLY_FLAG,
           REQUEST_ID,
           TERR_RSC_ID,
           ORG_ID
          ) VALUES (
           px_TERR_ID,
           decode( p_TERR_VALUE_ID, FND_API.G_MISS_NUM, NULL, p_TERR_VALUE_ID),
           decode( p_TRIGGER_MODE, FND_API.G_MISS_CHAR, NULL, p_TRIGGER_MODE),
           decode( p_ACTION, FND_API.G_MISS_CHAR, NULL, p_ACTION),
           decode( p_PARENT_TERRITORY_ID, FND_API.G_MISS_NUM, NULL, p_PARENT_TERRITORY_ID),
           decode( p_O_START_DATE_ACTIVE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_O_START_DATE_ACTIVE),
           decode( p_O_END_DATE_ACTIVE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_O_END_DATE_ACTIVE),
           decode( p_O_RANK, FND_API.G_MISS_NUM, NULL, p_O_RANK),
           decode( p_O_UPDATE_FLAG, FND_API.G_MISS_CHAR, NULL, p_O_UPDATE_FLAG),
           decode( p_N_START_DATE_ACTIVE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_N_START_DATE_ACTIVE),
           decode( p_N_END_DATE_ACTIVE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_N_END_DATE_ACTIVE),
           decode( p_N_RANK, FND_API.G_MISS_NUM, NULL, p_N_RANK),
           decode( p_N_UPDATE_FLAG, FND_API.G_MISS_CHAR, NULL, p_N_UPDATE_FLAG),
           decode( p_O_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_O_LAST_UPDATED_BY),
           decode( p_O_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_O_LAST_UPDATE_DATE),
           decode( p_O_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_O_CREATED_BY),
           decode( p_O_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_O_CREATION_DATE),
           decode( p_O_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_O_LAST_UPDATE_LOGIN),
           decode( p_O_TERR_QUAL_ID, FND_API.G_MISS_NUM, NULL, p_O_TERR_QUAL_ID),
           decode( p_O_INCLUDE_FLAG, FND_API.G_MISS_CHAR, NULL, p_O_INCLUDE_FLAG),
           decode( p_O_COMPARISON_OPERATOR, FND_API.G_MISS_CHAR, NULL, p_O_COMPARISON_OPERATOR),
           decode( p_O_ID_USED_FLAG, FND_API.G_MISS_CHAR, NULL, p_O_ID_USED_FLAG),
           decode( p_O_LOW_VALUE_CHAR_ID, FND_API.G_MISS_NUM, NULL, p_O_LOW_VALUE_CHAR_ID),
           decode( p_O_LOW_VALUE_CHAR, FND_API.G_MISS_CHAR, NULL, p_O_LOW_VALUE_CHAR),
           decode( p_O_HIGH_VALUE_CHAR, FND_API.G_MISS_CHAR, NULL, p_O_HIGH_VALUE_CHAR),
           decode( p_O_LOW_VALUE_NUMBER, FND_API.G_MISS_NUM, NULL, p_O_LOW_VALUE_NUMBER),
           decode( p_O_HIGH_VALUE_NUMBER, FND_API.G_MISS_NUM, NULL, p_O_HIGH_VALUE_NUMBER),
           decode( p_O_VALUE_SET, FND_API.G_MISS_NUM, NULL, p_O_VALUE_SET),
           decode( p_O_INTEREST_TYPE_ID, FND_API.G_MISS_NUM, NULL, p_O_INTEREST_TYPE_ID),
           decode( p_O_PRI_INTEREST_CODE_ID, FND_API.G_MISS_NUM, NULL, p_O_PRI_INTEREST_CODE_ID),
           decode( p_O_SEC_INTEREST_CODE_ID, FND_API.G_MISS_NUM, NULL, p_O_SEC_INTEREST_CODE_ID),
           decode( p_O_CURRENCY_CODE, FND_API.G_MISS_CHAR, NULL, p_O_CURRENCY_CODE),
           decode( p_N_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_N_LAST_UPDATED_BY),
           decode( p_N_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_N_LAST_UPDATE_DATE),
           decode( p_N_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_N_CREATED_BY),
           decode( p_N_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_N_CREATION_DATE),
           decode( p_N_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_N_LAST_UPDATE_LOGIN),
           decode( p_N_TERR_QUAL_ID, FND_API.G_MISS_NUM, NULL, p_N_TERR_QUAL_ID),
           decode( p_N_INCLUDE_FLAG, FND_API.G_MISS_CHAR, NULL, p_N_INCLUDE_FLAG),
           decode( p_N_COMPARISON_OPERATOR, FND_API.G_MISS_CHAR, NULL, p_N_COMPARISON_OPERATOR),
           decode( p_N_ID_USED_FLAG, FND_API.G_MISS_CHAR, NULL, p_N_ID_USED_FLAG),
           decode( p_N_LOW_VALUE_CHAR_ID, FND_API.G_MISS_NUM, NULL, p_N_LOW_VALUE_CHAR_ID),
           decode( p_N_LOW_VALUE_CHAR, FND_API.G_MISS_CHAR, NULL, p_N_LOW_VALUE_CHAR),
           decode( p_N_HIGH_VALUE_CHAR, FND_API.G_MISS_CHAR, NULL, p_N_HIGH_VALUE_CHAR),
           decode( p_N_LOW_VALUE_NUMBER, FND_API.G_MISS_NUM, NULL, p_N_LOW_VALUE_NUMBER),
           decode( p_N_HIGH_VALUE_NUMBER, FND_API.G_MISS_NUM, NULL, p_N_HIGH_VALUE_NUMBER),
           decode( p_N_VALUE_SET, FND_API.G_MISS_NUM, NULL, p_N_VALUE_SET),
           decode( p_N_INTEREST_TYPE_ID, FND_API.G_MISS_NUM, NULL, p_N_INTEREST_TYPE_ID),
           decode( p_N_PRI_INTEREST_CODE_ID, FND_API.G_MISS_NUM, NULL, p_N_PRI_INTEREST_CODE_ID),
           decode( p_N_SEC_INTEREST_CODE_ID, FND_API.G_MISS_NUM, NULL, p_N_SEC_INTEREST_CODE_ID),
           decode( p_N_CURRENCY_CODE, FND_API.G_MISS_CHAR, NULL, p_N_CURRENCY_CODE),
           decode( p_O_RESOURCE_ID, FND_API.G_MISS_NUM, NULL, p_O_RESOURCE_ID),
           decode( p_O_RESOURCE_TYPE, FND_API.G_MISS_CHAR, NULL, p_O_RESOURCE_TYPE),
           decode( p_O_ROLE, FND_API.G_MISS_CHAR, NULL, p_O_ROLE),
           decode( p_O_PRI_CONTACT_FLAG, FND_API.G_MISS_CHAR, NULL, p_O_PRI_CONTACT_FLAG),
           decode( p_O_FULL_ACCESS_FLAG, FND_API.G_MISS_CHAR, NULL, p_O_FULL_ACCESS_FLAG),
           decode( p_N_RESOURCE_ID, FND_API.G_MISS_NUM, NULL, p_N_RESOURCE_ID),
           decode( p_N_RESOURCE_TYPE, FND_API.G_MISS_CHAR, NULL, p_N_RESOURCE_TYPE),
           decode( p_N_ROLE, FND_API.G_MISS_CHAR, NULL, p_N_ROLE),
           decode( p_N_PRI_CONTACT_FLAG, FND_API.G_MISS_CHAR, NULL, p_N_PRI_CONTACT_FLAG),
           decode( p_N_FULL_ACCESS_FLAG, FND_API.G_MISS_CHAR, NULL, p_N_FULL_ACCESS_FLAG),
           decode( p_TRANSFER_ONLY_FLAG, FND_API.G_MISS_CHAR, NULL, p_TRANSFER_ONLY_FLAG),
           decode( p_REQUEST_ID, FND_API.G_MISS_NUM, NULL, p_REQUEST_ID),
           decode( p_TERR_RSC_ID, FND_API.G_MISS_NUM, NULL, p_TERR_RSC_ID),
           decode( p_ORG_ID, FND_API.G_MISS_NUM, NULL, p_ORG_ID));
End Insert_Row;

PROCEDURE Update_Row(
          p_TERR_ID    NUMBER,
          p_TERR_VALUE_ID NUMBER,
          p_TRIGGER_MODE    VARCHAR2,
          p_ACTION    VARCHAR2,
          p_PARENT_TERRITORY_ID    NUMBER,
          p_O_START_DATE_ACTIVE    DATE,
          p_O_END_DATE_ACTIVE    DATE,
          p_O_RANK    NUMBER,
          p_O_UPDATE_FLAG    VARCHAR2,
          p_N_START_DATE_ACTIVE    DATE,
          p_N_END_DATE_ACTIVE    DATE,
          p_N_RANK    NUMBER,
          p_N_UPDATE_FLAG    VARCHAR2,
          p_O_LAST_UPDATED_BY    NUMBER,
          p_O_LAST_UPDATE_DATE    DATE,
          p_O_CREATED_BY    NUMBER,
          p_O_CREATION_DATE    DATE,
          p_O_LAST_UPDATE_LOGIN    NUMBER,
          p_O_TERR_QUAL_ID    NUMBER,
          p_O_INCLUDE_FLAG    VARCHAR2,
          p_O_COMPARISON_OPERATOR    VARCHAR2,
          p_O_ID_USED_FLAG    VARCHAR2,
          p_O_LOW_VALUE_CHAR_ID    NUMBER,
          p_O_LOW_VALUE_CHAR    VARCHAR2,
          p_O_HIGH_VALUE_CHAR    VARCHAR2,
          p_O_LOW_VALUE_NUMBER    NUMBER,
          p_O_HIGH_VALUE_NUMBER    NUMBER,
          p_O_VALUE_SET    NUMBER,
          p_O_INTEREST_TYPE_ID    NUMBER,
          p_O_PRI_INTEREST_CODE_ID    NUMBER,
          p_O_SEC_INTEREST_CODE_ID    NUMBER,
          p_O_CURRENCY_CODE    VARCHAR2,
          p_N_LAST_UPDATED_BY    NUMBER,
          p_N_LAST_UPDATE_DATE    DATE,
          p_N_CREATED_BY    NUMBER,
          p_N_CREATION_DATE    DATE,
          p_N_LAST_UPDATE_LOGIN    NUMBER,
          p_N_TERR_QUAL_ID    NUMBER,
          p_N_INCLUDE_FLAG    VARCHAR2,
          p_N_COMPARISON_OPERATOR    VARCHAR2,
          p_N_ID_USED_FLAG    VARCHAR2,
          p_N_LOW_VALUE_CHAR_ID    NUMBER,
          p_N_LOW_VALUE_CHAR    VARCHAR2,
          p_N_HIGH_VALUE_CHAR    VARCHAR2,
          p_N_LOW_VALUE_NUMBER    NUMBER,
          p_N_HIGH_VALUE_NUMBER    NUMBER,
          p_N_VALUE_SET    NUMBER,
          p_N_INTEREST_TYPE_ID    NUMBER,
          p_N_PRI_INTEREST_CODE_ID    NUMBER,
          p_N_SEC_INTEREST_CODE_ID    NUMBER,
          p_N_CURRENCY_CODE    VARCHAR2,
          p_O_RESOURCE_ID    NUMBER,
          p_O_RESOURCE_TYPE    VARCHAR2,
          p_O_ROLE    VARCHAR2,
          p_O_PRI_CONTACT_FLAG    VARCHAR2,
          p_O_FULL_ACCESS_FLAG    VARCHAR2,
          p_N_RESOURCE_ID    NUMBER,
          p_N_RESOURCE_TYPE    VARCHAR2,
          p_N_ROLE    VARCHAR2,
          p_N_PRI_CONTACT_FLAG    VARCHAR2,
          p_N_FULL_ACCESS_FLAG    VARCHAR2,
          p_TRANSFER_ONLY_FLAG    VARCHAR2,
          p_REQUEST_ID    NUMBER,
          p_TERR_RSC_ID    NUMBER,
          P_ORG_ID         NUMBER)

 IS
 BEGIN
    Update JTF_CHANGED_TERR_ALL
    SET
              TERR_VALUE_ID = decode( p_TERR_VALUE_ID, FND_API.G_MISS_NUM, TERR_VALUE_ID, p_TERR_VALUE_ID),
              TRIGGER_MODE = decode( p_TRIGGER_MODE, FND_API.G_MISS_CHAR, TRIGGER_MODE, p_TRIGGER_MODE),
              ACTION = decode( p_ACTION, FND_API.G_MISS_CHAR, ACTION, p_ACTION),
              PARENT_TERRITORY_ID = decode( p_PARENT_TERRITORY_ID, FND_API.G_MISS_NUM, PARENT_TERRITORY_ID, p_PARENT_TERRITORY_ID),
              OLD_START_DATE_ACTIVE = decode( p_O_START_DATE_ACTIVE, FND_API.G_MISS_DATE, OLD_START_DATE_ACTIVE, p_O_START_DATE_ACTIVE),
              OLD_END_DATE_ACTIVE = decode( p_O_END_DATE_ACTIVE, FND_API.G_MISS_DATE, OLD_END_DATE_ACTIVE, p_O_END_DATE_ACTIVE),
              OLD_RANK = decode( p_O_RANK, FND_API.G_MISS_NUM, OLD_RANK, p_O_RANK),
              OLD_UPDATE_FLAG = decode( p_O_UPDATE_FLAG, FND_API.G_MISS_CHAR, OLD_UPDATE_FLAG, p_O_UPDATE_FLAG),
              NEW_START_DATE_ACTIVE = decode( p_N_START_DATE_ACTIVE, FND_API.G_MISS_DATE, NEW_START_DATE_ACTIVE, p_N_START_DATE_ACTIVE),
              NEW_END_DATE_ACTIVE = decode( p_N_END_DATE_ACTIVE, FND_API.G_MISS_DATE, NEW_END_DATE_ACTIVE, p_N_END_DATE_ACTIVE),
              NEW_RANK = decode( p_N_RANK, FND_API.G_MISS_NUM, NEW_RANK, p_N_RANK),
              NEW_UPDATE_FLAG = decode( p_N_UPDATE_FLAG, FND_API.G_MISS_CHAR, NEW_UPDATE_FLAG, p_N_UPDATE_FLAG),
              OLD_LAST_UPDATED_BY = decode( p_O_LAST_UPDATED_BY, FND_API.G_MISS_NUM, OLD_LAST_UPDATED_BY, p_O_LAST_UPDATED_BY),
              OLD_LAST_UPDATE_DATE = decode( p_O_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, OLD_LAST_UPDATE_DATE, p_O_LAST_UPDATE_DATE),
              OLD_CREATED_BY = decode( p_O_CREATED_BY, FND_API.G_MISS_NUM, OLD_CREATED_BY, p_O_CREATED_BY),
              OLD_CREATION_DATE = decode( p_O_CREATION_DATE, FND_API.G_MISS_DATE, OLD_CREATION_DATE, p_O_CREATION_DATE),
              OLD_LAST_UPDATE_LOGIN = decode( p_O_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, OLD_LAST_UPDATE_LOGIN, p_O_LAST_UPDATE_LOGIN),
              OLD_TERR_QUAL_ID = decode( p_O_TERR_QUAL_ID, FND_API.G_MISS_NUM, OLD_TERR_QUAL_ID, p_O_TERR_QUAL_ID),
              OLD_INCLUDE_FLAG = decode( p_O_INCLUDE_FLAG, FND_API.G_MISS_CHAR, OLD_INCLUDE_FLAG, p_O_INCLUDE_FLAG),
              OLD_COMPARISON_OPERATOR = decode( p_O_COMPARISON_OPERATOR, FND_API.G_MISS_CHAR, OLD_COMPARISON_OPERATOR, p_O_COMPARISON_OPERATOR),
              OLD_ID_USED_FLAG = decode( p_O_ID_USED_FLAG, FND_API.G_MISS_CHAR, OLD_ID_USED_FLAG, p_O_ID_USED_FLAG),
              OLD_LOW_VALUE_CHAR_ID = decode( p_O_LOW_VALUE_CHAR_ID, FND_API.G_MISS_NUM, OLD_LOW_VALUE_CHAR_ID, p_O_LOW_VALUE_CHAR_ID),
              OLD_LOW_VALUE_CHAR = decode( p_O_LOW_VALUE_CHAR, FND_API.G_MISS_CHAR, OLD_LOW_VALUE_CHAR, p_O_LOW_VALUE_CHAR),
              OLD_HIGH_VALUE_CHAR = decode( p_O_HIGH_VALUE_CHAR, FND_API.G_MISS_CHAR, OLD_HIGH_VALUE_CHAR, p_O_HIGH_VALUE_CHAR),
              OLD_LOW_VALUE_NUMBER = decode( p_O_LOW_VALUE_NUMBER, FND_API.G_MISS_NUM, OLD_LOW_VALUE_NUMBER, p_O_LOW_VALUE_NUMBER),
              OLD_HIGH_VALUE_NUMBER = decode( p_O_HIGH_VALUE_NUMBER, FND_API.G_MISS_NUM, OLD_HIGH_VALUE_NUMBER, p_O_HIGH_VALUE_NUMBER),
              OLD_VALUE_SET = decode( p_O_VALUE_SET, FND_API.G_MISS_NUM, OLD_VALUE_SET, p_O_VALUE_SET),
              OLD_INTEREST_TYPE_ID = decode( p_O_INTEREST_TYPE_ID, FND_API.G_MISS_NUM, OLD_INTEREST_TYPE_ID, p_O_INTEREST_TYPE_ID),
              OLD_PRIMARY_INTEREST_CODE_ID = decode( p_O_PRI_INTEREST_CODE_ID, FND_API.G_MISS_NUM, OLD_PRIMARY_INTEREST_CODE_ID, p_O_PRI_INTEREST_CODE_ID),
              OLD_SECONDARY_INTEREST_CODE_ID = decode( p_O_SEC_INTEREST_CODE_ID, FND_API.G_MISS_NUM, OLD_SECONDARY_INTEREST_CODE_ID, p_O_SEC_INTEREST_CODE_ID),
              OLD_CURRENCY_CODE = decode( p_O_CURRENCY_CODE, FND_API.G_MISS_CHAR, OLD_CURRENCY_CODE, p_O_CURRENCY_CODE),
              NEW_LAST_UPDATED_BY = decode( p_N_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NEW_LAST_UPDATED_BY, p_N_LAST_UPDATED_BY),
              NEW_LAST_UPDATE_DATE = decode( p_N_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NEW_LAST_UPDATE_DATE, p_N_LAST_UPDATE_DATE),
              NEW_CREATED_BY = decode( p_N_CREATED_BY, FND_API.G_MISS_NUM, NEW_CREATED_BY, p_N_CREATED_BY),
              NEW_CREATION_DATE = decode( p_N_CREATION_DATE, FND_API.G_MISS_DATE, NEW_CREATION_DATE, p_N_CREATION_DATE),
              NEW_LAST_UPDATE_LOGIN = decode( p_N_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NEW_LAST_UPDATE_LOGIN, p_N_LAST_UPDATE_LOGIN),
              NEW_TERR_QUAL_ID = decode( p_N_TERR_QUAL_ID, FND_API.G_MISS_NUM, NEW_TERR_QUAL_ID, p_N_TERR_QUAL_ID),
              NEW_INCLUDE_FLAG = decode( p_N_INCLUDE_FLAG, FND_API.G_MISS_CHAR, NEW_INCLUDE_FLAG, p_N_INCLUDE_FLAG),
              NEW_COMPARISON_OPERATOR = decode( p_N_COMPARISON_OPERATOR, FND_API.G_MISS_CHAR, NEW_COMPARISON_OPERATOR, p_N_COMPARISON_OPERATOR),
              NEW_ID_USED_FLAG = decode( p_N_ID_USED_FLAG, FND_API.G_MISS_CHAR, NEW_ID_USED_FLAG, p_N_ID_USED_FLAG),
              NEW_LOW_VALUE_CHAR_ID = decode( p_N_LOW_VALUE_CHAR_ID, FND_API.G_MISS_NUM, NEW_LOW_VALUE_CHAR_ID, p_N_LOW_VALUE_CHAR_ID),
              NEW_LOW_VALUE_CHAR = decode( p_N_LOW_VALUE_CHAR, FND_API.G_MISS_CHAR, NEW_LOW_VALUE_CHAR, p_N_LOW_VALUE_CHAR),
              NEW_HIGH_VALUE_CHAR = decode( p_N_HIGH_VALUE_CHAR, FND_API.G_MISS_CHAR, NEW_HIGH_VALUE_CHAR, p_N_HIGH_VALUE_CHAR),
              NEW_LOW_VALUE_NUMBER = decode( p_N_LOW_VALUE_NUMBER, FND_API.G_MISS_NUM, NEW_LOW_VALUE_NUMBER, p_N_LOW_VALUE_NUMBER),
              NEW_HIGH_VALUE_NUMBER = decode( p_N_HIGH_VALUE_NUMBER, FND_API.G_MISS_NUM, NEW_HIGH_VALUE_NUMBER, p_N_HIGH_VALUE_NUMBER),
              NEW_VALUE_SET = decode( p_N_VALUE_SET, FND_API.G_MISS_NUM, NEW_VALUE_SET, p_N_VALUE_SET),
              NEW_INTEREST_TYPE_ID = decode( p_N_INTEREST_TYPE_ID, FND_API.G_MISS_NUM, NEW_INTEREST_TYPE_ID, p_N_INTEREST_TYPE_ID),
              NEW_PRIMARY_INTEREST_CODE_ID = decode( p_N_PRI_INTEREST_CODE_ID, FND_API.G_MISS_NUM, NEW_PRIMARY_INTEREST_CODE_ID, p_N_PRI_INTEREST_CODE_ID),
              NEW_SECONDARY_INTEREST_CODE_ID = decode( p_N_SEC_INTEREST_CODE_ID, FND_API.G_MISS_NUM, NEW_SECONDARY_INTEREST_CODE_ID, p_N_SEC_INTEREST_CODE_ID),
              NEW_CURRENCY_CODE = decode( p_N_CURRENCY_CODE, FND_API.G_MISS_CHAR, NEW_CURRENCY_CODE, p_N_CURRENCY_CODE),
              OLD_RESOURCE_ID = decode( p_O_RESOURCE_ID, FND_API.G_MISS_NUM, OLD_RESOURCE_ID, p_O_RESOURCE_ID),
              OLD_RESOURCE_TYPE = decode( p_O_RESOURCE_TYPE, FND_API.G_MISS_CHAR, OLD_RESOURCE_TYPE, p_O_RESOURCE_TYPE),
              OLD_ROLE = decode( p_O_ROLE, FND_API.G_MISS_CHAR, OLD_ROLE, p_O_ROLE),
              OLD_PRIMARY_CONTACT_FLAG = decode( p_O_PRI_CONTACT_FLAG, FND_API.G_MISS_CHAR, OLD_PRIMARY_CONTACT_FLAG, p_O_PRI_CONTACT_FLAG),
              OLD_FULL_ACCESS_FLAG = decode( p_O_FULL_ACCESS_FLAG, FND_API.G_MISS_CHAR, OLD_FULL_ACCESS_FLAG, p_O_FULL_ACCESS_FLAG),
              NEW_RESOURCE_ID = decode( p_N_RESOURCE_ID, FND_API.G_MISS_NUM, NEW_RESOURCE_ID, p_N_RESOURCE_ID),
              NEW_RESOURCE_TYPE = decode( p_N_RESOURCE_TYPE, FND_API.G_MISS_CHAR, NEW_RESOURCE_TYPE, p_N_RESOURCE_TYPE),
              NEW_ROLE = decode( p_N_ROLE, FND_API.G_MISS_CHAR, NEW_ROLE, p_N_ROLE),
              NEW_PRIMARY_CONTACT_FLAG = decode( p_N_PRI_CONTACT_FLAG, FND_API.G_MISS_CHAR, NEW_PRIMARY_CONTACT_FLAG, p_N_PRI_CONTACT_FLAG),
              NEW_FULL_ACCESS_FLAG = decode( p_N_FULL_ACCESS_FLAG, FND_API.G_MISS_CHAR, NEW_FULL_ACCESS_FLAG, p_N_FULL_ACCESS_FLAG),
              TRANSFER_ONLY_FLAG = decode( p_TRANSFER_ONLY_FLAG, FND_API.G_MISS_CHAR, TRANSFER_ONLY_FLAG, p_TRANSFER_ONLY_FLAG),
              REQUEST_ID = decode( p_REQUEST_ID, FND_API.G_MISS_NUM, REQUEST_ID, p_REQUEST_ID),
              TERR_RSC_ID = decode( p_TERR_RSC_ID, FND_API.G_MISS_NUM, TERR_RSC_ID, p_TERR_RSC_ID),
              ORG_ID = decode( p_ORG_ID, FND_API.G_MISS_NUM, ORG_ID, p_ORG_ID)
    where TERR_ID = p_TERR_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_TERR_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM JTF_CHANGED_TERR_ALL
    WHERE TERR_ID = p_TERR_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_TERR_ID    NUMBER,
          p_TERR_VALUE_ID NUMBER,
          p_TRIGGER_MODE    VARCHAR2,
          p_ACTION    VARCHAR2,
          p_PARENT_TERRITORY_ID    NUMBER,
          p_O_START_DATE_ACTIVE    DATE,
          p_O_END_DATE_ACTIVE    DATE,
          p_O_RANK    NUMBER,
          p_O_UPDATE_FLAG    VARCHAR2,
          p_N_START_DATE_ACTIVE    DATE,
          p_N_END_DATE_ACTIVE    DATE,
          p_N_RANK    NUMBER,
          p_N_UPDATE_FLAG    VARCHAR2,
          p_O_LAST_UPDATED_BY    NUMBER,
          p_O_LAST_UPDATE_DATE    DATE,
          p_O_CREATED_BY    NUMBER,
          p_O_CREATION_DATE    DATE,
          p_O_LAST_UPDATE_LOGIN    NUMBER,
          p_O_TERR_QUAL_ID    NUMBER,
          p_O_INCLUDE_FLAG    VARCHAR2,
          p_O_COMPARISON_OPERATOR    VARCHAR2,
          p_O_ID_USED_FLAG    VARCHAR2,
          p_O_LOW_VALUE_CHAR_ID    NUMBER,
          p_O_LOW_VALUE_CHAR    VARCHAR2,
          p_O_HIGH_VALUE_CHAR    VARCHAR2,
          p_O_LOW_VALUE_NUMBER    NUMBER,
          p_O_HIGH_VALUE_NUMBER    NUMBER,
          p_O_VALUE_SET    NUMBER,
          p_O_INTEREST_TYPE_ID    NUMBER,
          p_O_PRI_INTEREST_CODE_ID    NUMBER,
          p_O_SEC_INTEREST_CODE_ID    NUMBER,
          p_O_CURRENCY_CODE    VARCHAR2,
          p_N_LAST_UPDATED_BY    NUMBER,
          p_N_LAST_UPDATE_DATE    DATE,
          p_N_CREATED_BY    NUMBER,
          p_N_CREATION_DATE    DATE,
          p_N_LAST_UPDATE_LOGIN    NUMBER,
          p_N_TERR_QUAL_ID    NUMBER,
          p_N_INCLUDE_FLAG    VARCHAR2,
          p_N_COMPARISON_OPERATOR    VARCHAR2,
          p_N_ID_USED_FLAG    VARCHAR2,
          p_N_LOW_VALUE_CHAR_ID    NUMBER,
          p_N_LOW_VALUE_CHAR    VARCHAR2,
          p_N_HIGH_VALUE_CHAR    VARCHAR2,
          p_N_LOW_VALUE_NUMBER    NUMBER,
          p_N_HIGH_VALUE_NUMBER    NUMBER,
          p_N_VALUE_SET    NUMBER,
          p_N_INTEREST_TYPE_ID    NUMBER,
          p_N_PRI_INTEREST_CODE_ID    NUMBER,
          p_N_SEC_INTEREST_CODE_ID    NUMBER,
          p_N_CURRENCY_CODE    VARCHAR2,
          p_O_RESOURCE_ID    NUMBER,
          p_O_RESOURCE_TYPE    VARCHAR2,
          p_O_ROLE    VARCHAR2,
          p_O_PRI_CONTACT_FLAG    VARCHAR2,
          p_O_FULL_ACCESS_FLAG    VARCHAR2,
          p_N_RESOURCE_ID    NUMBER,
          p_N_RESOURCE_TYPE    VARCHAR2,
          p_N_ROLE    VARCHAR2,
          p_N_PRI_CONTACT_FLAG    VARCHAR2,
          p_N_FULL_ACCESS_FLAG    VARCHAR2,
          p_TRANSFER_ONLY_FLAG    VARCHAR2,
          p_REQUEST_ID    NUMBER,
          p_TERR_RSC_ID    NUMBER,
          p_ORG_ID        NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM JTF_CHANGED_TERR
        WHERE TERR_ID =  p_TERR_ID
        FOR UPDATE of TERR_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    If (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
    CLOSE C;
    if (
           (      Recinfo.TERR_ID = p_TERR_ID)
       AND (    ( Recinfo.TERR_VALUE_ID = p_TERR_VALUE_ID)
            OR (    ( Recinfo.TERR_VALUE_ID IS NULL )
                AND (  p_TERR_VALUE_ID IS NULL )))
       AND (    ( Recinfo.TRIGGER_MODE = p_TRIGGER_MODE)
            OR (    ( Recinfo.TRIGGER_MODE IS NULL )
                AND (  p_TRIGGER_MODE IS NULL )))
       AND (    ( Recinfo.ACTION = p_ACTION)
            OR (    ( Recinfo.ACTION IS NULL )
                AND (  p_ACTION IS NULL )))
       AND (    ( Recinfo.PARENT_TERRITORY_ID = p_PARENT_TERRITORY_ID)
            OR (    ( Recinfo.PARENT_TERRITORY_ID IS NULL )
                AND (  p_PARENT_TERRITORY_ID IS NULL )))
       AND (    ( Recinfo.OLD_START_DATE_ACTIVE = p_O_START_DATE_ACTIVE)
            OR (    ( Recinfo.OLD_START_DATE_ACTIVE IS NULL )
                AND (  p_O_START_DATE_ACTIVE IS NULL )))
       AND (    ( Recinfo.OLD_END_DATE_ACTIVE = p_O_END_DATE_ACTIVE)
            OR (    ( Recinfo.OLD_END_DATE_ACTIVE IS NULL )
                AND (  p_O_END_DATE_ACTIVE IS NULL )))
       AND (    ( Recinfo.OLD_RANK = p_O_RANK)
            OR (    ( Recinfo.OLD_RANK IS NULL )
                AND (  p_O_RANK IS NULL )))
       AND (    ( Recinfo.OLD_UPDATE_FLAG = p_O_UPDATE_FLAG)
            OR (    ( Recinfo.OLD_UPDATE_FLAG IS NULL )
                AND (  p_O_UPDATE_FLAG IS NULL )))
       AND (    ( Recinfo.NEW_START_DATE_ACTIVE = p_N_START_DATE_ACTIVE)
            OR (    ( Recinfo.NEW_START_DATE_ACTIVE IS NULL )
                AND (  p_N_START_DATE_ACTIVE IS NULL )))
       AND (    ( Recinfo.NEW_END_DATE_ACTIVE = p_N_END_DATE_ACTIVE)
            OR (    ( Recinfo.NEW_END_DATE_ACTIVE IS NULL )
                AND (  p_N_END_DATE_ACTIVE IS NULL )))
       AND (    ( Recinfo.NEW_RANK = p_N_RANK)
            OR (    ( Recinfo.NEW_RANK IS NULL )
                AND (  p_N_RANK IS NULL )))
       AND (    ( Recinfo.NEW_UPDATE_FLAG = p_N_UPDATE_FLAG)
            OR (    ( Recinfo.NEW_UPDATE_FLAG IS NULL )
                AND (  p_N_UPDATE_FLAG IS NULL )))
       AND (    ( Recinfo.OLD_LAST_UPDATED_BY = p_O_LAST_UPDATED_BY)
            OR (    ( Recinfo.OLD_LAST_UPDATED_BY IS NULL )
                AND (  p_O_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.OLD_LAST_UPDATE_DATE = p_O_LAST_UPDATE_DATE)
            OR (    ( Recinfo.OLD_LAST_UPDATE_DATE IS NULL )
                AND (  p_O_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.OLD_CREATED_BY = p_O_CREATED_BY)
            OR (    ( Recinfo.OLD_CREATED_BY IS NULL )
                AND (  p_O_CREATED_BY IS NULL )))
       AND (    ( Recinfo.OLD_CREATION_DATE = p_O_CREATION_DATE)
            OR (    ( Recinfo.OLD_CREATION_DATE IS NULL )
                AND (  p_O_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.OLD_LAST_UPDATE_LOGIN = p_O_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.OLD_LAST_UPDATE_LOGIN IS NULL )
                AND (  p_O_LAST_UPDATE_LOGIN IS NULL )))
       AND (    ( Recinfo.OLD_TERR_QUAL_ID = p_O_TERR_QUAL_ID)
            OR (    ( Recinfo.OLD_TERR_QUAL_ID IS NULL )
                AND (  p_O_TERR_QUAL_ID IS NULL )))
       AND (    ( Recinfo.OLD_INCLUDE_FLAG = p_O_INCLUDE_FLAG)
            OR (    ( Recinfo.OLD_INCLUDE_FLAG IS NULL )
                AND (  p_O_INCLUDE_FLAG IS NULL )))
       AND (    ( Recinfo.OLD_COMPARISON_OPERATOR = p_O_COMPARISON_OPERATOR)
            OR (    ( Recinfo.OLD_COMPARISON_OPERATOR IS NULL )
                AND (  p_O_COMPARISON_OPERATOR IS NULL )))
       AND (    ( Recinfo.OLD_ID_USED_FLAG = p_O_ID_USED_FLAG)
            OR (    ( Recinfo.OLD_ID_USED_FLAG IS NULL )
                AND (  p_O_ID_USED_FLAG IS NULL )))
       AND (    ( Recinfo.OLD_LOW_VALUE_CHAR_ID = p_O_LOW_VALUE_CHAR_ID)
            OR (    ( Recinfo.OLD_LOW_VALUE_CHAR_ID IS NULL )
                AND (  p_O_LOW_VALUE_CHAR_ID IS NULL )))
       AND (    ( Recinfo.OLD_LOW_VALUE_CHAR = p_O_LOW_VALUE_CHAR)
            OR (    ( Recinfo.OLD_LOW_VALUE_CHAR IS NULL )
                AND (  p_O_LOW_VALUE_CHAR IS NULL )))
       AND (    ( Recinfo.OLD_HIGH_VALUE_CHAR = p_O_HIGH_VALUE_CHAR)
            OR (    ( Recinfo.OLD_HIGH_VALUE_CHAR IS NULL )
                AND (  p_O_HIGH_VALUE_CHAR IS NULL )))
       AND (    ( Recinfo.OLD_LOW_VALUE_NUMBER = p_O_LOW_VALUE_NUMBER)
            OR (    ( Recinfo.OLD_LOW_VALUE_NUMBER IS NULL )
                AND (  p_O_LOW_VALUE_NUMBER IS NULL )))
       AND (    ( Recinfo.OLD_HIGH_VALUE_NUMBER = p_O_HIGH_VALUE_NUMBER)
            OR (    ( Recinfo.OLD_HIGH_VALUE_NUMBER IS NULL )
                AND (  p_O_HIGH_VALUE_NUMBER IS NULL )))
       AND (    ( Recinfo.OLD_VALUE_SET = p_O_VALUE_SET)
            OR (    ( Recinfo.OLD_VALUE_SET IS NULL )
                AND (  p_O_VALUE_SET IS NULL )))
       AND (    ( Recinfo.OLD_INTEREST_TYPE_ID = p_O_INTEREST_TYPE_ID)
            OR (    ( Recinfo.OLD_INTEREST_TYPE_ID IS NULL )
                AND (  p_O_INTEREST_TYPE_ID IS NULL )))
       AND (    ( Recinfo.OLD_PRIMARY_INTEREST_CODE_ID = p_O_PRI_INTEREST_CODE_ID)
            OR (    ( Recinfo.OLD_PRIMARY_INTEREST_CODE_ID IS NULL )
                AND (  p_O_PRI_INTEREST_CODE_ID IS NULL )))
       AND (    ( Recinfo.OLD_SECONDARY_INTEREST_CODE_ID = p_O_SEC_INTEREST_CODE_ID)
            OR (    ( Recinfo.OLD_SECONDARY_INTEREST_CODE_ID IS NULL )
                AND (  p_O_SEC_INTEREST_CODE_ID IS NULL )))
       AND (    ( Recinfo.OLD_CURRENCY_CODE = p_O_CURRENCY_CODE)
            OR (    ( Recinfo.OLD_CURRENCY_CODE IS NULL )
                AND (  p_O_CURRENCY_CODE IS NULL )))
       AND (    ( Recinfo.NEW_LAST_UPDATED_BY = p_N_LAST_UPDATED_BY)
            OR (    ( Recinfo.NEW_LAST_UPDATED_BY IS NULL )
                AND (  p_N_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.NEW_LAST_UPDATE_DATE = p_N_LAST_UPDATE_DATE)
            OR (    ( Recinfo.NEW_LAST_UPDATE_DATE IS NULL )
                AND (  p_N_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.NEW_CREATED_BY = p_N_CREATED_BY)
            OR (    ( Recinfo.NEW_CREATED_BY IS NULL )
                AND (  p_N_CREATED_BY IS NULL )))
       AND (    ( Recinfo.NEW_CREATION_DATE = p_N_CREATION_DATE)
            OR (    ( Recinfo.NEW_CREATION_DATE IS NULL )
                AND (  p_N_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.NEW_LAST_UPDATE_LOGIN = p_N_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.NEW_LAST_UPDATE_LOGIN IS NULL )
                AND (  p_N_LAST_UPDATE_LOGIN IS NULL )))
       AND (    ( Recinfo.NEW_TERR_QUAL_ID = p_N_TERR_QUAL_ID)
            OR (    ( Recinfo.NEW_TERR_QUAL_ID IS NULL )
                AND (  p_N_TERR_QUAL_ID IS NULL )))
       AND (    ( Recinfo.NEW_INCLUDE_FLAG = p_N_INCLUDE_FLAG)
            OR (    ( Recinfo.NEW_INCLUDE_FLAG IS NULL )
                AND (  p_N_INCLUDE_FLAG IS NULL )))
       AND (    ( Recinfo.NEW_COMPARISON_OPERATOR = p_N_COMPARISON_OPERATOR)
            OR (    ( Recinfo.NEW_COMPARISON_OPERATOR IS NULL )
                AND (  p_N_COMPARISON_OPERATOR IS NULL )))
       AND (    ( Recinfo.NEW_ID_USED_FLAG = p_N_ID_USED_FLAG)
            OR (    ( Recinfo.NEW_ID_USED_FLAG IS NULL )
                AND (  p_N_ID_USED_FLAG IS NULL )))
       AND (    ( Recinfo.NEW_LOW_VALUE_CHAR_ID = p_N_LOW_VALUE_CHAR_ID)
            OR (    ( Recinfo.NEW_LOW_VALUE_CHAR_ID IS NULL )
                AND (  p_N_LOW_VALUE_CHAR_ID IS NULL )))
       AND (    ( Recinfo.NEW_LOW_VALUE_CHAR = p_N_LOW_VALUE_CHAR)
            OR (    ( Recinfo.NEW_LOW_VALUE_CHAR IS NULL )
                AND (  p_N_LOW_VALUE_CHAR IS NULL )))
       AND (    ( Recinfo.NEW_HIGH_VALUE_CHAR = p_N_HIGH_VALUE_CHAR)
            OR (    ( Recinfo.NEW_HIGH_VALUE_CHAR IS NULL )
                AND (  p_N_HIGH_VALUE_CHAR IS NULL )))
       AND (    ( Recinfo.NEW_LOW_VALUE_NUMBER = p_N_LOW_VALUE_NUMBER)
            OR (    ( Recinfo.NEW_LOW_VALUE_NUMBER IS NULL )
                AND (  p_N_LOW_VALUE_NUMBER IS NULL )))
       AND (    ( Recinfo.NEW_HIGH_VALUE_NUMBER = p_N_HIGH_VALUE_NUMBER)
            OR (    ( Recinfo.NEW_HIGH_VALUE_NUMBER IS NULL )
                AND (  p_N_HIGH_VALUE_NUMBER IS NULL )))
       AND (    ( Recinfo.NEW_VALUE_SET = p_N_VALUE_SET)
            OR (    ( Recinfo.NEW_VALUE_SET IS NULL )
                AND (  p_N_VALUE_SET IS NULL )))
       AND (    ( Recinfo.NEW_INTEREST_TYPE_ID = p_N_INTEREST_TYPE_ID)
            OR (    ( Recinfo.NEW_INTEREST_TYPE_ID IS NULL )
                AND (  p_N_INTEREST_TYPE_ID IS NULL )))
       AND (    ( Recinfo.NEW_PRIMARY_INTEREST_CODE_ID = p_N_PRI_INTEREST_CODE_ID)
            OR (    ( Recinfo.NEW_PRIMARY_INTEREST_CODE_ID IS NULL )
                AND (  p_N_PRI_INTEREST_CODE_ID IS NULL )))
       AND (    ( Recinfo.NEW_SECONDARY_INTEREST_CODE_ID = p_N_SEC_INTEREST_CODE_ID)
            OR (    ( Recinfo.NEW_SECONDARY_INTEREST_CODE_ID IS NULL )
                AND (  p_N_SEC_INTEREST_CODE_ID IS NULL )))
       AND (    ( Recinfo.NEW_CURRENCY_CODE = p_N_CURRENCY_CODE)
            OR (    ( Recinfo.NEW_CURRENCY_CODE IS NULL )
                AND (  p_N_CURRENCY_CODE IS NULL )))
       AND (    ( Recinfo.OLD_RESOURCE_ID = p_O_RESOURCE_ID)
            OR (    ( Recinfo.OLD_RESOURCE_ID IS NULL )
                AND (  p_O_RESOURCE_ID IS NULL )))
       AND (    ( Recinfo.OLD_RESOURCE_TYPE = p_O_RESOURCE_TYPE)
            OR (    ( Recinfo.OLD_RESOURCE_TYPE IS NULL )
                AND (  p_O_RESOURCE_TYPE IS NULL )))
       AND (    ( Recinfo.OLD_ROLE = p_O_ROLE)
            OR (    ( Recinfo.OLD_ROLE IS NULL )
                AND (  p_O_ROLE IS NULL )))
       AND (    ( Recinfo.OLD_PRIMARY_CONTACT_FLAG = p_O_PRI_CONTACT_FLAG)
            OR (    ( Recinfo.OLD_PRIMARY_CONTACT_FLAG IS NULL )
                AND (  p_O_PRI_CONTACT_FLAG IS NULL )))
       AND (    ( Recinfo.OLD_FULL_ACCESS_FLAG = p_O_FULL_ACCESS_FLAG)
            OR (    ( Recinfo.OLD_FULL_ACCESS_FLAG IS NULL )
                AND (  p_O_FULL_ACCESS_FLAG IS NULL )))
       AND (    ( Recinfo.NEW_RESOURCE_ID = p_N_RESOURCE_ID)
            OR (    ( Recinfo.NEW_RESOURCE_ID IS NULL )
                AND (  p_N_RESOURCE_ID IS NULL )))
       AND (    ( Recinfo.NEW_RESOURCE_TYPE = p_N_RESOURCE_TYPE)
            OR (    ( Recinfo.NEW_RESOURCE_TYPE IS NULL )
                AND (  p_N_RESOURCE_TYPE IS NULL )))
       AND (    ( Recinfo.NEW_ROLE = p_N_ROLE)
            OR (    ( Recinfo.NEW_ROLE IS NULL )
                AND (  p_N_ROLE IS NULL )))
       AND (    ( Recinfo.NEW_PRIMARY_CONTACT_FLAG = p_N_PRI_CONTACT_FLAG)
            OR (    ( Recinfo.NEW_PRIMARY_CONTACT_FLAG IS NULL )
                AND (  p_N_PRI_CONTACT_FLAG IS NULL )))
       AND (    ( Recinfo.NEW_FULL_ACCESS_FLAG = p_N_FULL_ACCESS_FLAG)
            OR (    ( Recinfo.NEW_FULL_ACCESS_FLAG IS NULL )
                AND (  p_N_FULL_ACCESS_FLAG IS NULL )))
       AND (    ( Recinfo.TRANSFER_ONLY_FLAG = p_TRANSFER_ONLY_FLAG)
            OR (    ( Recinfo.TRANSFER_ONLY_FLAG IS NULL )
                AND (  p_TRANSFER_ONLY_FLAG IS NULL )))
       AND (    ( Recinfo.REQUEST_ID = p_REQUEST_ID)
            OR (    ( Recinfo.REQUEST_ID IS NULL )
                AND (  p_REQUEST_ID IS NULL )))
       AND (    ( Recinfo.TERR_RSC_ID = p_TERR_RSC_ID)
            OR (    ( Recinfo.TERR_RSC_ID IS NULL )
                AND (  p_TERR_RSC_ID IS NULL )))
       AND (    ( Recinfo.ORG_ID = p_ORG_ID)
            OR (    ( Recinfo.ORG_ID IS NULL )
                AND (  p_ORG_ID IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

End JTF_CHANGED_TERR_PKG;

/
