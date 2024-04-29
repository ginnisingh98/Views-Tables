--------------------------------------------------------
--  DDL for Package Body BIX_EMAIL_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_EMAIL_UTIL_PKG" AS
/*$Header: bixxeutb.plb 115.7 2002/11/27 00:27:00 djambula noship $*/

FUNCTION get_email_table_footer(p_context IN VARCHAR2 )
         RETURN VARCHAR2 IS
l_max_date VARCHAR2(20);
l_date_format VARCHAR2(50);
BEGIN
  l_date_format := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');
  IF(l_date_format IS NULL) THEN
  l_date_format := 'MM/DD/YYYY';
  END IF;
  l_date_format := l_date_format||' HH24:MI:SS';
  SELECT to_char(MAX(period_start_date_time),l_date_format)
  INTO   l_max_date
  FROM   bix_dm_email_sum;
  RETURN FND_MESSAGE.GET_STRING('BIX','BIX_DM_REFRESH_MSG') || ' '|| l_max_date;
EXCEPTION
   WHEN OTHERS THEN
    RETURN NULL;
END get_email_table_footer;

FUNCTION get_max_date_of_email_table(p_context IN VARCHAR2 )
         RETURN VARCHAR2 IS
l_max_date VARCHAR2(20);
l_date_format VARCHAR2(50);
BEGIN
  l_date_format := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');
  IF(l_date_format IS NULL) THEN
  l_date_format := 'MM/DD/YYYY';
  END IF;
  l_date_format := l_date_format||' HH24:MI:SS';
  SELECT to_char(MAX(period_start_date_time),l_date_format)
  INTO   l_max_date
  FROM   bix_dm_email_sum;
  RETURN l_max_date;
EXCEPTION
   WHEN OTHERS THEN
    RETURN NULL;
END get_max_date_of_email_table;

FUNCTION get_agent_table_footer(p_context IN VARCHAR2 )
         RETURN VARCHAR2 IS
l_max_date VARCHAR2(20);
l_date_format VARCHAR2(50);
BEGIN
  l_date_format := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');
  IF(l_date_format IS NULL) THEN
  l_date_format := 'MM/DD/YYYY';
  END IF;
  l_date_format := l_date_format||' HH24:MI:SS';
  SELECT to_char(MAX(period_start_date_time),l_date_format)
  INTO   l_max_date
  FROM   bix_dm_email_agent_sum;
  RETURN FND_MESSAGE.GET_STRING('BIX','BIX_DM_REFRESH_MSG') || ' '|| l_max_date;
EXCEPTION
   WHEN OTHERS THEN
    RETURN NULL;
END get_agent_table_footer;

FUNCTION get_max_date_of_agent_table(p_context IN VARCHAR2 )
         RETURN VARCHAR2 IS
l_max_date VARCHAR2(20);
l_date_format VARCHAR2(50);
BEGIN
  l_date_format := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');
  IF(l_date_format IS NULL) THEN
  l_date_format := 'MM/DD/YYYY';
  END IF;
  l_date_format := l_date_format||' HH24:MI:SS';
  SELECT to_char(MAX(period_start_date_time),l_date_format)
  INTO   l_max_date
  FROM   bix_dm_email_agent_sum;
  RETURN  l_max_date;
EXCEPTION
   WHEN OTHERS THEN
    RETURN NULL;
END get_max_date_of_agent_table;

END BIX_EMAIL_UTIL_PKG;

/
