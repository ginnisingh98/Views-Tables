--------------------------------------------------------
--  DDL for Package AP_WEB_FND_LOOKUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_FND_LOOKUPS_PKG" AUTHID CURRENT_USER AS
/* $Header: apwlupss.pls 115.1 2002/12/26 10:13:27 srinvenk noship $ */


SUBTYPE lookups_meaning	IS FND_LOOKUPS.MEANING%TYPE;
SUBTYPE lookups_code    IS FND_LOOKUPS.LOOKUP_CODE%TYPE;

-- Global variables
g_langCode 	VARCHAR2(100):= null;
g_yesMeaning	lookups_meaning;
g_noMeaning	lookups_meaning;


FUNCTION getYesNoMeaning(p_lookup_code  IN lookups_code) RETURN lookups_meaning;


END AP_WEB_FND_LOOKUPS_PKG;

 

/
