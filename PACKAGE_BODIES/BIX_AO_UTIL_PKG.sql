--------------------------------------------------------
--  DDL for Package Body BIX_AO_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_AO_UTIL_PKG" AS
/*$Header: bixxaoub.plb 115.9 2002/11/27 00:27:04 djambula noship $*/


FUNCTION BIX_DM_GET_AO_footer(p_context IN VARCHAR2 ) RETURN VARCHAR2 IS
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
  FROM   bix_dm_advanced_outbound_sum;

  RETURN FND_MESSAGE.GET_STRING('BIX','BIX_DM_REFRESH_MSG') || ' '|| l_max_date;

EXCEPTION
   WHEN OTHERS THEN
    RETURN NULL;
END BIX_DM_GET_AO_FOOTER;




FUNCTION BIX_DM_GET_AO_refresh_date(p_context IN VARCHAR2 ) RETURN VARCHAR2 IS
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
  FROM   bix_dm_advanced_outbound_sum;

  RETURN l_max_date;

EXCEPTION
   WHEN OTHERS THEN
    RETURN NULL;
END BIX_DM_GET_AO_refresh_date;


FUNCTION BIX_GET_AO_a_otcm_footer(p_context IN VARCHAR2 ) RETURN VARCHAR2 IS
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
  FROM   bix_dm_agent_outcome_sum;

  RETURN FND_MESSAGE.GET_STRING('BIX','BIX_DM_REFRESH_MSG') || ' '|| l_max_date;

EXCEPTION
   WHEN OTHERS THEN
    RETURN NULL;
END BIX_GET_AO_A_OTCM_FOOTER;


FUNCTION BIX_GET_AO_a_otcm_refresh_date(p_context IN VARCHAR2 ) RETURN VARCHAR2 IS
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
  FROM   bix_dm_agent_outcome_sum;

  RETURN l_max_date;

EXCEPTION
   WHEN OTHERS THEN
    RETURN NULL;
END BIX_GET_AO_A_OTCM_REFRESH_DATE;

END BIX_AO_UTIL_PKG;

/
