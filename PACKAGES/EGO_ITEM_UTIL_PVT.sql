--------------------------------------------------------
--  DDL for Package EGO_ITEM_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_ITEM_UTIL_PVT" AUTHID DEFINER AS
/* $Header: EGOIUTPS.pls 120.0 2006/03/15 04:36:37 dsakalle noship $ */

  /*
   * This function returns the lookup meaning for given lookup_code and Type
   */
  FUNCTION GET_LOOKUP_MEANING(p_lookup_type IN VARCHAR2, p_lookup_code IN VARCHAR2) RETURN VARCHAR2;

  /*
   * This function returns the user name for given user_id
   */
  FUNCTION GET_USER_NAME(p_user_id IN NUMBER) RETURN VARCHAR2;

END EGO_ITEM_UTIL_PVT;

 

/
