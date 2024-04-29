--------------------------------------------------------
--  DDL for Package Body PSP_EXTERNAL_EFFORT_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_EXTERNAL_EFFORT_LINES_PKG" AS
--$Header: PSPHREFB.pls 120.0 2006/02/02 14:27:50 sramacha noship $

FUNCTION get_external_effort_line_id
( p_ext_effort_line_user_key IN VARCHAR2)
    RETURN NUMBER IS

l_external_effort_line_id NUMBER;

CURSOR ext_eff_cur IS
SELECT unique_key_id
  FROM hr_pump_batch_line_user_keys
 WHERE user_key_value = p_ext_effort_line_user_key;
BEGIN
    OPEN  ext_eff_cur;
       FETCH ext_eff_cur INTO l_external_effort_line_id;
    CLOSE ext_eff_cur;

 RETURN(l_external_effort_line_id);

EXCEPTION
WHEN OTHERS THEN
    hr_data_pump.fail('get_external_effort_line_id '  ,
                      SQLERRM                 ,
                      p_ext_effort_line_user_key);
   RAISE;
END get_external_effort_line_id;


FUNCTION get_external_effort_ovn
( p_ext_effort_line_user_key IN VARCHAR2)
    RETURN NUMBER IS

l_ovn NUMBER;
CURSOR ovn_cur(p_user_key_value IN VARCHAR2) IS
SELECT object_version_number
  FROM psp_external_effort_lines  peel,
       hr_pump_batch_line_user_keys key
 WHERE key.user_key_value     = p_user_key_value
   AND peel.external_effort_line_id = key.unique_key_id ;
BEGIN
    OPEN  ovn_cur(p_ext_effort_line_user_key);
       FETCH ovn_cur INTO l_ovn;
    CLOSE ovn_cur;
    RETURN l_ovn;
EXCEPTION
WHEN OTHERS THEN
    hr_data_pump.fail('get_external_ovn' ,
                      SQLERRM                 ,
                      p_ext_effort_line_user_key);
    RAISE;
END get_external_effort_ovn;

END psp_external_effort_lines_PKG;

/
