--------------------------------------------------------
--  DDL for Package Body JE_AT_VAT_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JE_AT_VAT_UTIL_PKG" AS
/* $Header: jeatutilb.pls 120.0 2006/06/01 17:19:13 panaraya noship $ */
 FUNCTION G_APFilter(source_name varchar2) return boolean is
 BEGIN
 --Oracle Payables
  IF (source_name='I') THEN
    RETURN TRUE;
  ELSE
   RETURN FALSE;
  end if;
end G_APFilter;
FUNCTION G_ARFilter(source_name varchar2) return boolean is
 BEGIN
 --Oracle Receivables
   IF (source_name='O') THEN
    RETURN TRUE;
  ELSE
   RETURN FALSE;
  end if;
end G_ARFilter;
end JE_AT_VAT_UTIL_PKG;

/
