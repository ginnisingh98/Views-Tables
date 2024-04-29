--------------------------------------------------------
--  DDL for Package Body GHR_VALIDATE_PERWSEPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_VALIDATE_PERWSEPI" AS
/* $Header: ghrwsepi.pkb 120.0.12010000.2 2009/05/26 10:50:29 vmididho noship $ */

   -- Created g_new_line to use instead of CHR(10)
   g_new_line      varchar2(1)    := substr('
',1,1);

--------------------------------------------------------------------------------------------------------
---------------------------------- get_person_type  ----------------------------------------------------
--------------------------------------------------------------------------------------------------------
Function get_person_type (p_business_group_id IN NUMBER,p_person_id IN number,p_effective_date IN DATE)
 RETURN VARCHAR2 IS

-- This cursor gets the Person Type ID for Employee
 CURSOR cur_chk_pst(p_business_group_id IN NUMBER,p_person_id IN NUMBER, p_effective_date IN DATE) IS
    SELECT ppf.person_id
    FROM per_people_f ppf, per_person_types pty
    WHERE  ppf.person_id = p_person_id
    AND    p_effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
    AND    ppf.person_type_id = pty.person_type_id
    AND    pty.system_person_type = 'EMP'
    AND    pty.business_group_id = p_business_group_id
    AND    pty.active_flag = 'Y';

BEGIN
  FOR cur_chk_pst_rec in cur_chk_pst(p_business_group_id,p_person_id,p_effective_date) LOOP
    RETURN('TRUE');
  END LOOP;

  RETURN('FALSE');

END get_person_type;

-- This function checks if there are any future PA Request actions for a given person between 2 dates
-- that have been completed.
FUNCTION check_pend_future_pars (p_person_id  IN NUMBER
                                ,p_from_date  IN DATE
                                ,p_to_date    IN DATE)
RETURN VARCHAR2 IS

l_pend_future_list VARCHAR2(2000) := NULL;
--
CURSOR c_par IS
  SELECT 'Request Number:'||par.request_number||
        ', 1st NOA Code:'||par.first_noa_code||
        DECODE(par.second_noa_code,NULL,NULL, ', 2nd NOA Code:'||par.second_noa_code)||
        ', Effective Date:'||par.effective_date||
        ', Updater:'||prh.user_name     list_info
  FROM   ghr_pa_routing_history prh
        ,ghr_pa_requests        par
  WHERE  par.person_id = p_person_id
  AND    par.effective_date BETWEEN NVL(p_from_date,par.effective_date) AND NVL(p_to_date,par.effective_date)
  AND    prh.pa_request_id  = par.pa_request_id
  AND    prh.pa_routing_history_id = (SELECT MAX(prh2.pa_routing_history_id)
                                      FROM   ghr_pa_routing_history prh2
                                      WHERE  prh2.pa_request_id = par.pa_request_id)
  AND    prh.action_taken IN ('FUTURE_ACTION')
  ORDER BY par.effective_date, par.pa_request_id;


BEGIN
  -- loop around them all to build up a list
  FOR c_par_rec IN c_par LOOP
    l_pend_future_list := SUBSTR(l_pend_future_list||g_new_line||g_new_line||c_par%ROWCOUNT||'.'||c_par_rec.list_info,1,2000);
  END LOOP;

  RETURN(l_pend_future_list);

END check_pend_future_pars ;

END ghr_validate_perwsepi;

/
