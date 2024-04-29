--------------------------------------------------------
--  DDL for Package Body IGR_PER_INFO_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_PER_INFO_001" AS
/* $Header: IGSRTP1B.pls 120.0 2005/06/02 03:31:06 appldev noship $ */
/******************************************************************
Created By: Benjamin Gu
Date Created By: 19-Feb-2002
Purpose: Some pl/sql functions used in person summary pages
Known limitations,enhancements,remarks:
Change History
Who        When          What
jchin      14-Feb-05     Modified package for IGR pseudo product
******************************************************************/

FUNCTION GET_APPL_PROG_UNIT_SETS(x_person_id IN NUMBER,
				 x_adm_appl_number IN NUMBER,
				 x_course_cd IN VARCHAR2,
                                 x_seq_number IN NUMBER
                                 ) RETURN VARCHAR2 IS
  CURSOR cur_unit_sets IS
  SELECT eus.TITLE
    FROM IGS_AD_UNIT_SETS aus,
         IGS_EN_UNIT_SET eus
   WHERE aus.UNIT_SET_CD = eus.UNIT_SET_CD
     AND aus.VERSION_NUMBER = eus.VERSION_NUMBER
     AND aus.PERSON_ID = x_person_id
     AND aus.ADMISSION_APPL_NUMBER = x_adm_appl_number
     AND aus.NOMINATED_COURSE_CD = x_course_cd
     AND aus.SEQUENCE_NUMBER = x_seq_number;

  l_title varchar2(100);
  l_unit_sets varchar2(10000) :='';
  l_num number :=0;

BEGIN
  OPEN cur_unit_sets;
  LOOP
    FETCH cur_unit_sets INTO l_title;
    EXIT WHEN cur_unit_sets%NOTFOUND;

    if l_num = 0 then
      l_unit_sets := l_title;
    else
      l_unit_sets := l_unit_sets||' , '||l_title;
    end if;

    l_num := l_num + 1;
  END LOOP;
  return l_unit_sets;

END GET_APPL_PROG_UNIT_SETS;


FUNCTION GET_INQ_PROG_UNIT_SETS(x_prog_pref_id IN NUMBER) RETURN VARCHAR2 IS
  CURSOR cur_unit_sets IS
SELECT CODE.DESCRIPTION
  FROM IGS_AD_I_PRG_PRF_UST PREF,
       IGS_AD_I_PRG_U_SET USET,
       IGS_AD_INQ_UNIT_SETS CODE
 WHERE PREF.INQ_PROG_UNIT_SET_ID = USET.INQ_PROG_UNIT_SET_ID
   AND USET.INQ_UNIT_SET_CODE_ID = CODE.INQ_UNIT_SET_CODE_ID
   AND PREF.INQ_PROG_PREF_ID =x_prog_pref_id;

  l_title varchar2(100);
  l_unit_sets varchar2(10000) :='';
  l_num number :=0;

BEGIN
  OPEN cur_unit_sets;
  LOOP
    FETCH cur_unit_sets INTO l_title;
    EXIT WHEN cur_unit_sets%NOTFOUND;

    if l_num = 0 then
      l_unit_sets := l_title;
    else
      l_unit_sets := l_unit_sets||' <BR> '||l_title;
    end if;

    l_num := l_num + 1;
  END LOOP;
  return l_unit_sets;
END GET_INQ_PROG_UNIT_SETS;


FUNCTION GET_TEST_SCORES(x_test_result_id IN NUMBER) RETURN VARCHAR2 IS
  CURSOR cur_recs IS
  select SCORES.TEST_SEGMENT||' : '||SCORES.SEGMENT_SCORE SCORE
    from IGS_AD_TEST_SCORES_V SCORES
   where SCORES.TEST_RESULTS_ID = x_test_result_id;

  l_title varchar2(100);
  l_ret_val varchar2(10000) :='';
  l_num number :=0;

BEGIN
  OPEN cur_recs;
  LOOP
    FETCH cur_recs INTO l_title;
    EXIT WHEN cur_recs%NOTFOUND;

    if l_num = 0 then
      l_ret_val := l_title;
    else
      l_ret_val := l_ret_val||' <BR> '||l_title;
    end if;

    l_num := l_num + 1;
  END LOOP;
  return l_ret_val;

END GET_TEST_SCORES;


END IGR_PER_INFO_001;

/
