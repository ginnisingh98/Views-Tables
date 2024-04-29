--------------------------------------------------------
--  DDL for Package Body EGO_ITEM_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_ITEM_UTIL_PVT" AS
/* $Header: EGOIUTPB.pls 120.0 2006/03/15 04:37:04 dsakalle noship $ */

  /*
   * This function returns the lookup meaning for given lookup_code and Type
   */
  FUNCTION GET_LOOKUP_MEANING(p_lookup_type IN VARCHAR2, p_lookup_code IN VARCHAR2) RETURN VARCHAR2 AS
    l_meaning FND_LOOKUPS.MEANING%TYPE;
  BEGIN
    SELECT MEANING INTO l_meaning
    FROM FND_LOOKUP_VALUES
    WHERE LOOKUP_TYPE = p_lookup_type
      AND LOOKUP_CODE = p_lookup_code
      AND LANGUAGE = USERENV('LANG')
      AND VIEW_APPLICATION_ID = 0
      AND SECURITY_GROUP_ID = FND_GLOBAL.LOOKUP_SECURITY_GROUP(p_lookup_type, 0);

    RETURN l_meaning;
  EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
  END GET_LOOKUP_MEANING;

  /*
   * This function returns the user name for given user_id
   */
  FUNCTION GET_USER_NAME(p_user_id IN NUMBER) RETURN VARCHAR2 AS
    l_user_name EGO_USER_V.PARTY_NAME%TYPE;
  BEGIN
    SELECT PARTY_NAME INTO l_user_name
    FROM EGO_USER_V
    WHERE USER_ID = p_user_id;

    RETURN l_user_name;
  EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
  END GET_USER_NAME;

END EGO_ITEM_UTIL_PVT;

/
