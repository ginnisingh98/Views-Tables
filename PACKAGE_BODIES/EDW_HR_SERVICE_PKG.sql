--------------------------------------------------------
--  DDL for Package Body EDW_HR_SERVICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_HR_SERVICE_PKG" AS
/* $Header: hrieklwb.pkb 120.0 2005/05/29 07:11:31 appldev noship $ */

FUNCTION service_band_fk( p_service_days  IN NUMBER)
               RETURN VARCHAR2 IS

  l_days_to_month   NUMBER;
  l_service_band_pk VARCHAR2(400);

  CURSOR ratio_cur IS
  SELECT days_to_month
  FROM hri_service_bands
  WHERE days_to_month IS NOT NULL;

  CURSOR service_band_cur
  (v_days_to_month  NUMBER) IS
  SELECT service_band_pk
  FROM edw_hr_service_fkv
  WHERE (((service_length_min_year * 12) + service_length_min_month) * v_days_to_month)
        + ((service_length_min_week * 7)  + service_length_min_day)
                             <= p_service_days
  AND ((service_length_max_year  IS NULL AND
        service_length_max_month IS NULL AND
        service_length_max_week  IS NULL AND
        service_length_max_day   IS NULL)
    OR ((((service_length_max_year * 12) + service_length_max_month) * v_days_to_month)
       + ((service_length_max_week * 7)  + service_length_max_day)
                             > p_service_days));

BEGIN

  OPEN ratio_cur;
  FETCH ratio_cur INTO l_days_to_month;
  CLOSE ratio_cur;

  OPEN service_band_cur(l_days_to_month);
  FETCH service_band_cur INTO l_service_band_pk;
  CLOSE service_band_cur;

  RETURN NVL(l_service_band_pk, 'NA_EDW');

EXCEPTION when others then

  if service_band_cur%ISOPEN then
    CLOSE service_band_cur;
  end if;

  RETURN NVL(l_service_band_pk, 'NA_EDW');

END service_band_fk;

END edw_hr_service_pkg;

/
