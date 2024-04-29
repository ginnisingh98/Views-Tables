--------------------------------------------------------
--  DDL for Package Body EDW_HR_REC_ACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_HR_REC_ACT_PKG" AS
/* $Header: hriekrec.pkb 120.0 2005/05/29 07:12:30 appldev noship $ */

FUNCTION recruitment_activity_fk( p_recruitment_activity_id IN NUMBER)
			     RETURN VARCHAR2 IS

  l_recruitment_activity_pk VARCHAR2(400);

  cursor recruitment_activity_cur is
  select recruitment_activity_pk
  from edw_hr_rec_act_fkv
  where p_recruitment_activity_id = recruitment_activity_id;

BEGIN

  OPEN recruitment_activity_cur;
  FETCH recruitment_activity_cur INTO l_recruitment_activity_pk;
  CLOSE recruitment_activity_cur;

  RETURN NVL(l_recruitment_activity_pk, 'NA_EDW');

EXCEPTION when others then

  if recruitment_activity_cur%ISOPEN then
    CLOSE recruitment_activity_cur;
  end if;

  RETURN NVL(l_recruitment_activity_pk, 'NA_EDW');

END recruitment_activity_fk;

END edw_hr_rec_act_pkg;

/
