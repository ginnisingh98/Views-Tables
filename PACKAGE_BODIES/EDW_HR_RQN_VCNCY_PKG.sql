--------------------------------------------------------
--  DDL for Package Body EDW_HR_RQN_VCNCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_HR_RQN_VCNCY_PKG" AS
/* $Header: hriekvac.pkb 120.0 2005/05/29 07:12:43 appldev noship $ */

FUNCTION vacancy_fk( p_vacancy_id IN NUMBER)
			     RETURN VARCHAR2 IS

  l_vacancy_pk VARCHAR2(400);

  cursor vacancy_cur is
  select vacancy_pk
  from edw_hr_rqn_vcncy_fkv
  where p_vacancy_id = vacancy_id;

BEGIN

  OPEN vacancy_cur;
  FETCH vacancy_cur INTO l_vacancy_pk;
  CLOSE vacancy_cur;

  RETURN NVL(l_vacancy_pk, 'NA_EDW');

EXCEPTION when others then

  if vacancy_cur%ISOPEN then
    CLOSE vacancy_cur;
  end if;

  RETURN NVL(l_vacancy_pk, 'NA_EDW');

END vacancy_fk;

END edw_hr_rqn_vcncy_pkg;

/
