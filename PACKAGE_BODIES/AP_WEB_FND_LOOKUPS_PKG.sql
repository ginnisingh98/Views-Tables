--------------------------------------------------------
--  DDL for Package Body AP_WEB_FND_LOOKUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_FND_LOOKUPS_PKG" AS
/* $Header: apwlupsb.pls 115.1 2002/12/26 10:13:20 srinvenk noship $ */


/* --------------------------------------------------------
 *  Written by:
 *    David Tong
 *  Purpose:
 *    - Called by SQL script to get the Meaning from FND_LOOKUPS table
 *    - For performance purpose, we embeded the select statement in this
 *	function instead of calling a procedure
 *  Input:
 *    p_lookup_code - Lookup Code
 *  Output:
 *    Meaning for the Lookup Code
 *  Assumption:
 *    None
 -----------------------------------------------------------*/
FUNCTION getYesNoMeaning(p_lookup_code  IN lookups_code) RETURN lookups_meaning
IS
  l_langCode 			  VARCHAR2(100);

BEGIN
  l_langCode := userenv('LANG');

  -- need to check whether the session's language has been changed
  -- if it does, then we need to get the meanings from FND table again

  if (g_langCode is null OR g_langCode <> l_langCode) then
      g_langCode := l_langCode;

      SELECT MEANING
      INTO g_yesMeaning
      FROM FND_LOOKUPS
      WHERE LOOKUP_TYPE = 'YES_NO'
      AND LOOKUP_CODE = 'Y';

      SELECT MEANING
      INTO g_noMeaning
      FROM FND_LOOKUPS
      WHERE LOOKUP_TYPE = 'YES_NO'
      AND LOOKUP_CODE = 'N';
  end if;

    IF (p_lookup_code = 'Y') THEN
      return g_yesMeaning;
    ELSIF (p_lookup_code = 'N') THEN
      return g_noMeaning;
    ELSE
      return null;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    return null;
END getYesNoMeaning;


END AP_WEB_FND_LOOKUPS_PKG;

/
