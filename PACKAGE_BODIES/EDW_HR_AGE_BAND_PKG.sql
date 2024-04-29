--------------------------------------------------------
--  DDL for Package Body EDW_HR_AGE_BAND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_HR_AGE_BAND_PKG" AS
/* $Header: hriekagb.pkb 120.0 2005/05/29 07:11:18 appldev noship $ */

FUNCTION age_band_fk( p_age IN NUMBER)
               RETURN VARCHAR2 IS

  l_age_band_pk VARCHAR2(400);

  cursor age_band_cur is
  select age_band_pk
  from edw_hr_age_band_fkv
  where age_min <= p_age
  and p_age < nvl(age_max,p_age+1);

BEGIN

  OPEN age_band_cur;
  FETCH age_band_cur INTO l_age_band_pk;
  CLOSE age_band_cur;

  RETURN NVL(l_age_band_pk, 'NA_EDW');

EXCEPTION when others then

  if age_band_cur%ISOPEN then
    CLOSE age_band_cur;
  end if;

  RETURN NVL(l_age_band_pk, 'NA_EDW');

END age_band_fk;

END edw_hr_age_band_pkg;

/
