--------------------------------------------------------
--  DDL for Package Body HXT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_UTIL" AS
/* $Header: hxtutl.pkb 120.8.12010000.3 2009/06/13 12:58:11 asrajago ship $ */

g_debug boolean := hr_utility.debug_enabled;
--BEGIN HXT11i1
FUNCTION GetPersonID(p_TIM_ID NUMBER) RETURN NUMBER;  -- ER230
FUNCTION GetPayrollID(p_PTP_ID NUMBER) RETURN NUMBER; -- ER230
--END HXT11i1

--BEGIN HXT115
Procedure DEBUG(p_string IN VARCHAR2) IS
BEGIN
     g_debug :=hr_utility.debug_enabled;
  -- Uncomment line below to turn-on OTM package debug messages.
     if g_debug then
     	   hr_utility.trace(p_string);
     end if;
  -- NULL;
END DEBUG;
--END HXT115

/*----------------------Procedure GEN_ERROR NEWEST--------------------------*/
Procedure GEN_ERROR (p_PPB_ID IN NUMBER
                   ,p_TIM_ID IN NUMBER
                   , p_HRW_ID IN NUMBER
                   , p_PTP_ID IN NUMBER
                   , p_ERROR_MSG IN VARCHAR2
                   , p_LOCATION IN VARCHAR2
                   , p_ORA_MSG IN VARCHAR2
                   , p_EFFECTIVE_START_DATE IN DATE      --ORA135
                   , p_EFFECTIVE_END_DATE IN DATE        --ORA135
                   , p_TYPE IN VARCHAR2) IS              --HXT11i1
  --  Procedure GEN_ERROR
  --
  --  Purpose
  --    Insert record in HXT_ERRORS table when an error is found regarding a
  --    Timecard, summary or detailed Hours Worked or Pay Period record.
  --
  --  Returns
  --    0 - No errors occurred
  --    1 - Warnings occurred
  --    2 - Errors occurred
  --
  --  Arguments
  --    p_TIM_ID  - The source of the error is the BATCH record
  --    p_TIM_ID  - The source of the error is the TIMECARD record
  --    p_HRW_ID  - The source of the error is the Hours Worked record
  --    p_PTP_ID  - The source of the error is the TIME PERIOD RECORD.
  --***  p_TYPE    -  will = 'NEW' until p_type is deleted from the HXT_ERRORS table  *********
  --    p_ERROR_MSG    - the error message to show the user
  --    p_LOCATION     - the Procedure or Source
  --    p_ORA_MSG      - the ORACLE error number and message if any
  --
  --  Local Variables
        l_CREATION_DATE DATE;       --- the date time of the error
        l_CREATED_BY    NUMBER;     --- the user logged in when the error occurred
        l_EXCEP_seqno NUMBER;       --- the next sequence number for new error record
        l_ERROR_MSG    VARCHAR2(240);
        l_error VARCHAR2(240);
        l_person_id NUMBER;
        l_payroll_id NUMBER;

  --
  --
BEGIN
  --
   SELECT hxt_seqno.nextval
   INTO l_EXCEP_seqno
   FROM dual;
   l_CREATED_BY := FND_GLOBAL.user_id;

   l_person_id := GetPersonID(p_TIM_ID);
   l_payroll_id := GetPayrollID(p_PTP_ID);

   BEGIN

     IF p_ERROR_MSG IS NULL THEN
        l_ERROR_MSG := FND_MESSAGE.GET;
        FND_MESSAGE.CLEAR;
     ELSE
        l_ERROR_MSG := p_ERROR_MSG;
     END IF;

     insert into hxt_errors_f(id, error_msg, creation_date, location,--ORA135
                           created_by, err_type, PPB_ID, TIM_ID, HRW_ID, PTP_ID, ora_message
                           ,EFFECTIVE_START_DATE
                           ,EFFECTIVE_END_DATE
                           ,PERSON_ID
                           ,PAYROLL_ID
						   )
values(l_EXCEP_seqno,
 substr(nvl(l_ERROR_MSG,'NOTPROVIDED'),1,239),
 sysdate,
 substr(nvl(p_LOCATION,'NOTPROVIDED'),1,119),
 nvl(l_CREATED_BY,-1),
 p_TYPE, p_PPB_id, p_TIM_id, p_HRW_ID, p_PTP_ID,
 substr(p_ORA_MSG,1,119)
 ,nvl(p_EFFECTIVE_START_DATE,sysdate)
 ,nvl(p_EFFECTIVE_END_DATE,hr_general.end_of_time)
 ,l_Person_ID
 ,l_Payroll_ID
);  --FORMS60


    EXCEPTION
      WHEN others THEN
         FND_MESSAGE.SET_NAME('HXT','HXT_39469_ERR_INS_HXT_ERR');
         l_error := SQLERRM;
         insert into hxt_errors_f(id, error_msg, creation_date, location,
                   created_by, err_type, PPB_ID, TIM_ID, HRW_ID, PTP_ID, ora_message
                  ,EFFECTIVE_START_DATE
                  ,EFFECTIVE_END_DATE)
                  values(l_EXCEP_seqno,
                  FND_MESSAGE.GET||' '||nls_initcap(substr(p_error_msg,1,100)),
                          sysdate, 'ERROR', 999, 'NEW', 999, 999, 999, 999,
                          l_error
                          ,nvl(p_EFFECTIVE_START_DATE,sysdate)
                          ,nvl(p_EFFECTIVE_END_DATE,hr_general.end_of_time));  --FORMS60
                  FND_MESSAGE.CLEAR;
          END;
END gen_error;
--
/*-------------------------Procedure GEN_ERROR---------------------------------*/
Procedure GEN_ERROR (p_TIM_ID IN NUMBER
                   , p_HRW_ID IN NUMBER
                   , p_PTP_ID IN NUMBER
                   , p_ERROR_MSG IN VARCHAR2
                   , p_LOCATION IN VARCHAR2
                   , p_ORA_MSG IN VARCHAR2
                   , p_EFFECTIVE_START_DATE IN DATE
                   , p_EFFECTIVE_END_DATE IN DATE
                   , p_TYPE IN VARCHAR2) IS
  --  Procedure GEN_ERROR
  --
  --  Purpose
  --    Insert record in HXT_ERRORS table when an error is found regarding a
  --    Timecard, summary or detailed Hours Worked or Pay Period record.
  --
  --  Returns
  --    0 - No errors occurred
  --    1 - Warnings occurred
  --    2 - Errors occurred
  --
  --  Arguments
  --    p_TIM_ID  - The source of the error is the TIMECARD record
  --    p_HRW_ID  - The source of the error is the Hours Worked record
  --    p_PTP_ID  - The source of the error is the TIME PERIOD RECORD.
  --    p_ERROR_MSG    - the error message to show the user
  --    p_LOCATION     - the Procedure or Source
  --    p_ORA_MSG      - the ORACLE error number and message if any
  --
  --  Local Variables
        l_CREATION_DATE DATE;       --- the date time of the error
        l_CREATED_BY    NUMBER;     --- the user logged in when the error occurred
        l_EXCEP_seqno NUMBER;       --- the next sequence number for new error record
        l_error VARCHAR2(240);
        l_ERROR_MSG    VARCHAR2(240);
        l_person_id NUMBER;
        l_payroll_id NUMBER;
  --
  --
BEGIN
  --
  --
   SELECT hxt_seqno.nextval
   INTO l_EXCEP_seqno
   FROM dual;
   l_CREATED_BY := FND_GLOBAL.user_id;

   l_person_id := GetPersonID(p_TIM_ID);
   l_payroll_id := GetPayrollID(p_PTP_ID);

   IF p_ERROR_MSG IS NULL THEN
      l_ERROR_MSG := FND_MESSAGE.GET;
      FND_MESSAGE.CLEAR;
   ELSE
      l_ERROR_MSG := p_ERROR_MSG;
   END IF;
   BEGIN
         insert into hxt_errors_f(id, error_msg, creation_date, location,--ORA135
                                  created_by, err_type, TIM_ID, HRW_ID, PTP_ID, ora_message
                                 ,EFFECTIVE_START_DATE
                                 ,EFFECTIVE_END_DATE
                                 ,PERSON_ID  --ER230
                                 ,PAYROLL_ID  --ER230
				 )
                          values(l_EXCEP_seqno,
                                 substr(nvl(l_ERROR_MSG,'NOTPROVIDED'),1,239),
                                 sysdate,
                                 substr(nvl(p_LOCATION,'NOTPROVIDED'),1,119),
                                 nvl(l_CREATED_BY,-1),
                                 p_TYPE, p_TIM_id, p_HRW_ID, p_PTP_ID,
                                 substr(p_ORA_MSG,1,119)
                                 ,nvl(p_EFFECTIVE_START_DATE,sysdate)
                                 ,nvl(p_EFFECTIVE_END_DATE,hr_general.end_of_time)
                                 ,l_Person_ID
                                 ,l_Payroll_ID
                               );
    EXCEPTION
      WHEN others THEN
        FND_MESSAGE.SET_NAME('HXT','HXT_39469_ERR_INS_HXT_ERR');
        l_error := SQLERRM;
         insert into hxt_errors_f(id, error_msg, creation_date, location,
                                created_by, err_type, TIM_ID, HRW_ID, PTP_ID, ora_message
                               ,EFFECTIVE_START_DATE
                               ,EFFECTIVE_END_DATE)
                         values(l_EXCEP_seqno,
                                FND_MESSAGE.GET||' '||nls_initcap(substr(p_error_msg,1,100)),
                                sysdate, 'ERROR', 999, 'NEW', 999, 999, 999,
                                l_error
                                ,nvl(p_EFFECTIVE_START_DATE,sysdate)
                                ,nvl(p_EFFECTIVE_END_DATE,hr_general.end_of_time));
         FND_MESSAGE.CLEAR;
    END;
END gen_error;
--
-------------------------------------Procedure autogen_error-------------------------------------
--ORA136  removed.
------------------------------------old --PROCEDURE GEN_ERROR-------------------------------------
--ORA136  removed.
------------------------------------------PROCEDURE chk_absence------------------------------------
PROCEDURE chk_absence(P_assignment_id  IN NUMBER,
                      P_period_id IN NUMBER,
                      P_calculation_date IN DATE,
                      P_element_type_id IN NUMBER,
                      P_hours IN NUMBER,
                      P_net_amt OUT NOCOPY NUMBER,
                      P_period_amt OUT NOCOPY NUMBER,
                      P_available_amt OUT NOCOPY NUMBER,
                      P_abs_status OUT NOCOPY NUMBER) IS
--
-- Procedure chk_absence
--
-- Purpose
--   Check the net accrual for a specific Absenece Element for sufficient hours
--   in order to allow person to take hours requested.  If enough, then return
--   P_abs_status = 0; if not, then return P_abs_status = 1; if NO PTO Accrual Plan,
--   then return P_abs_status = 2.
--
-- Arguments
p_PLAN_ID NUMBER;
p_PLAN_NAME VARCHAR2(80);
p_PLAN_ELEMENT_TYPE_ID NUMBER;
p_PLAN_CATEGORY VARCHAR2(30);
p_PLAN_CATEGORY_NAME VARCHAR2(80);
p_PTO_ELEMENT_TYPE_ID NUMBER;
p_PTO_ELEMENT_NAME VARCHAR2(80);
p_PTO_INPUT_VALUE_ID NUMBER;
p_PTO_INPUT_VALUE_NAME VARCHAR2(30);
--
-- Local Variables
l_amount NUMBER;
l_total_period_hrs NUMBER;
--
--  Get PTO ACCRUAL PLAN for Absence Element
--
CURSOR pto_plan(p_element_type_id NUMBER) IS
select
 ACCRUAL_PLAN_ID,
 ACCRUAL_PLAN_NAME,
 ACCRUAL_PLAN_ELEMENT_TYPE_ID,
 ACCRUAL_CATEGORY,
 ACCRUAL_CATEGORY_NAME,
 PTO_ELEMENT_TYPE_ID,
 PTO_ELEMENT_NAME,
 PTO_INPUT_VALUE_ID,

 PTO_INPUT_VALUE_NAME
FROM PAY_ACCRUAL_PLANS_V
WHERE PTO_ELEMENT_TYPE_ID = p_element_type_id;
--
--  Total all hours for Absence Element for current pay period
--
CURSOR hr_amt(p_period_id NUMBER,p_assignement_id NUMBER,p_element_type_id NUMBER) IS
select sum(hours)
from hxt_timecards tim, hxt_sum_hours_worked hrw
where hrw.tim_id = tim.id
and tim.time_period_id = p_period_id
and hrw.assignment_id = p_assignement_id
and hrw.element_type_id = p_element_type_id;
BEGIN
  --
  --  Initialize OUT variables;
  P_net_amt := NULL;
  P_period_amt := NULL;
  P_abs_status := NULL;
  P_available_amt := NULL;
  --
  --   Get PTO plan for element type passed
  --
  open pto_plan(p_element_type_id);
  --
    fetch pto_plan into p_PLAN_ID,
                        p_PLAN_NAME,
                        p_PLAN_ELEMENT_TYPE_ID,
                        p_PLAN_CATEGORY,
                        p_PLAN_CATEGORY_NAME,
                        p_PTO_ELEMENT_TYPE_ID,
                        p_PTO_ELEMENT_NAME,
                        p_PTO_INPUT_VALUE_ID,
                        p_PTO_INPUT_VALUE_NAME;
  --
  close pto_plan;
  --
  IF p_PLAN_ID IS NULL THEN
     P_abs_status := 2;             --- Element does not belong to an Accrual Plan
  ELSE
    --
    --   Get net Accrual plan amount
    --
    l_amount := pay_us_pto_accrual.get_net_accrual( P_assignment_id ,
                                                    P_calculation_date,
                                                    P_plan_id ,
                                                    P_plan_category);
    P_net_amt := l_amount;
    --
    --   Get total Absence Element hours for current pay period
    --
    open hr_amt(p_period_id,p_assignment_id,p_element_type_id);
    --
       fetch hr_amt into l_total_period_hrs;
    --
    close hr_amt;
    --
    --   Total Absence Element hours for current pay period
    --
    P_period_amt := l_total_period_hrs;
    --
    IF l_total_period_hrs IS NULL THEN
      l_total_period_hrs := 0;
    END IF;
    l_total_period_hrs := l_total_period_hrs + p_hours;
    --
    --  Calculate net Accrual available if all Absence Elements are taken
    P_available_amt := l_amount - l_total_period_hrs;
    --
    --   Check that Hours to be charge to this Accrual plan are available to take
    --
    IF l_total_period_hrs <= l_amount THEN
      P_abs_status := 0;
    ELSE
      P_abs_status := 1;
    END IF;
  END IF;
  --
  EXCEPTION
      WHEN others THEN
        P_abs_status := 3;
END;
--
--------------------------Submit Req --------------------------
FUNCTION submit_req (p_program varchar2,
		     p_desc varchar2,
		     p_msg varchar2,
		     p_loc varchar2,
		     p_1 varchar2,p_2 varchar2,p_3 varchar2,p_4 varchar2,
		     p_5 varchar2,p_6 varchar2,p_7 varchar2,p_8 varchar2,
		     p_9 varchar2,p_10 varchar2,p_11 varchar2,p_12 varchar2,
                     p_13 varchar2,p_14 varchar2,p_15 varchar2,p_16 varchar2,
		     p_17 varchar2,p_18 varchar2,p_19 varchar2,p_20 varchar2,
                     p_21 varchar2,p_22 varchar2,p_23 varchar2,p_24 varchar2,
                     p_25 varchar2,p_26 varchar2,p_27 varchar2,p_28 varchar2,
		     p_29 varchar2,p_30 varchar2,p_31 varchar2,p_32 varchar2,
		     p_33 varchar2,p_34 varchar2,p_35 varchar2,p_36 varchar2,
                     p_37 varchar2,p_38 varchar2,p_39 varchar2,p_40 varchar2,
		     p_41 varchar2,p_42 varchar2,p_43 varchar2,p_44 varchar2,
                     p_45 varchar2,p_46 varchar2,p_47 varchar2,p_48 varchar2,
                     p_49 varchar2,p_50 varchar2,p_51 varchar2,p_52 varchar2,
		     p_53 varchar2,p_54 varchar2,p_55 varchar2,p_56 varchar2,
                     p_57 varchar2,p_58 varchar2,p_59 varchar2,p_60 varchar2,
                     p_61 varchar2,p_62 varchar2,p_63 varchar2,p_64 varchar2,
		     p_65 varchar2,p_66 varchar2,p_67 varchar2,p_68 varchar2,
                     p_69 varchar2,p_70 varchar2,p_71 varchar2,p_72 varchar2,
                     p_73 varchar2,p_74 varchar2,p_75 varchar2,p_76 varchar2,
		     p_77 varchar2,p_78 varchar2,p_79 varchar2,p_80 varchar2,
                     p_81 varchar2,p_82 varchar2,p_83 varchar2,p_84 varchar2,
                     p_85 varchar2,p_86 varchar2,p_87 varchar2,p_88 varchar2,
		     p_89 varchar2,p_90 varchar2,p_91 varchar2,p_92 varchar2,
                     p_93 varchar2,p_94 varchar2,p_95 varchar2,p_96 varchar2,
                     p_97 varchar2,p_98 varchar2,p_99 varchar2,p_100 varchar2
		     )	RETURN number IS
l_req_id number;
v_flag   number := 0;
BEGIN
RETURN (v_flag);
END submit_req;
--
--------------------------Check For Holiday --------------------------
PROCEDURE check_for_holiday (p_date in DATE
                            ,p_hol_id in NUMBER
                            ,p_day_id OUT NOCOPY  NUMBER
                            ,p_hours OUT NOCOPY NUMBER
                            ,p_retcode OUT NOCOPY NUMBER) IS
--
-- Procedure
--    Check_For_Holiday
-- Purpose
--    Check to see if a date is a holiday or the day before or after a holiday.
--
-- Arguments
--    p_date      The date being checked.
--    p_hol_id    The Holiday Calendar to be checked.
--
-- Returns:
--	p_day_id - holiday calendar day ID
--	p_hours  - paid hours for holiday
--	p_retcode:
--	   0 - regular day
--	   1 - holiday
--	   2 - day before or after a holiday
--
  -- Define cursor to return any holiday that falls between
  -- the day before and the day after the date passed
  CURSOR holiday_cur IS
    select hdy.id, hdy.hours, hdy.holiday_date
    from   hxt_holiday_days hdy
	  ,hxt_holiday_calendars hcl
    where  hdy.holiday_date between p_date - 1 and p_date + 1
    and    hdy.hcl_id = hcl.id
    and    p_date between hcl.effective_start_date
		      and hcl.effective_end_date
    and    hcl.id = p_hol_id;
BEGIN
   -- Initialize return code
   p_retcode := 0;
   -- Step through all holidays in three day range
   FOR data in holiday_cur
   LOOP
      -- Check if date passed is holiday
      IF p_date = data.holiday_date THEN
	 p_retcode := 1;
         p_day_id := data.id;
         p_hours := data.hours;
         EXIT ; -- TA35 Loop must end when holiday is found. PWM 07/02/96            --ORA137
      -- Otherwise, date passed is before or after holiday
      ELSE
	 p_retcode := 2;
	 p_day_id := null;
	 p_hours := null;
      END IF;
   END LOOP;
END;
--
--------------------------Fnd Username --------------------------
FUNCTION Fnd_Username( a_user_id NUMBER ) RETURN VARCHAR2 IS
  -- Get FND user name
  CURSOR cur_user is
    SELECT user_name
    FROM fnd_user
    WHERE user_id = a_user_id;
  l_user_name		fnd_user.user_name%TYPE;
BEGIN
  OPEN cur_user;
  FETCH cur_user INTO l_user_name;
  CLOSE cur_user;
  return (l_user_name);
END fnd_username;
--
--------------------------Element Cat --------------------------
-- BEGIN ORACLE bug #712501
FUNCTION element_cat(p_element_type_id IN NUMBER,
                     p_date_worked IN DATE) RETURN varchar2 IS

--  Returns earning category of the given element type
  l_earning_cat   VARCHAR2(30);
BEGIN
 BEGIN
  SELECT eltv.hxt_earning_category
    INTO l_earning_cat
    FROM hxt_pay_element_types_f_ddf_v eltv
   WHERE eltv.element_type_id = p_element_type_id
     AND p_date_worked BETWEEN eltv.effective_start_date
                           AND eltv.effective_end_date;
  EXCEPTION
     WHEN no_data_found THEN
       l_earning_cat := NULL;
     WHEN OTHERS THEN
       l_earning_cat := 'ERR';  --  this done to flag error in calling routine
   --
 END;
 return(l_earning_cat);
END;
--
--------------------------Check Policy Use --------------------------
FUNCTION check_policy_use (
   p_policy_id         IN   NUMBER,
   p_policy_name       IN   VARCHAR2,
   p_policy_end_date   IN   DATE
)
   RETURN BOOLEAN
IS

-- Function
--    check_policy_use
-- Purpose
--    Ensure ID values for ROTATION_PLAN, WORK_PLAN,
--    SHIFT_DIFFERENTIAL_POLICY, OVERTIME_POLICY or
--    HOUR_DEDUCT_POLICY have not been linked to the
--    ASSIGNMENT table if an attempt is made to delete them
--    or determine if a policy is currently assigned before
--    it is closed.
--
-- Arguments
--    p_policy_id        the object Policy id.
--    p_policy_name      the object Policy name.
--    p_policy_end_date  the object Policy Date to (null if assignment check)
--
   CURSOR assign_dfv (p_policy_id NUMBER)
   IS
      SELECT 1
        FROM hxt_per_aei_ddf_v aeiv
       WHERE (   aeiv.hxt_rotation_plan = p_policy_id
              OR aeiv.hxt_earning_policy = p_policy_id
              OR aeiv.hxt_hour_deduction_policy = p_policy_id
              OR aeiv.hxt_shift_differential_policy = p_policy_id
             )
         AND (     p_policy_end_date
                 + 1 BETWEEN aeiv.effective_start_date
                         AND aeiv.effective_end_date
              OR p_policy_end_date IS NULL
             );

   v_id     NUMBER (15);
   v_flag   BOOLEAN;
--   v_date date;
--   v_session_date date;
BEGIN
   v_id := NULL;
   OPEN assign_dfv (p_policy_id);
   FETCH assign_dfv INTO v_id;

   IF assign_dfv%FOUND
   THEN
      v_flag := (TRUE);
   ELSE
      v_flag := (FALSE);
   END IF;

   CLOSE assign_dfv;
   RETURN (v_flag);
END check_policy_use;
--
--------------------------Get Policies --------------------------
PROCEDURE get_policies(p_earn_pol_id IN NUMBER
                      ,p_assignment_id IN NUMBER
		      ,p_date	IN DATE
		      ,p_work_plan OUT NOCOPY NUMBER
		      ,p_rotation_plan OUT NOCOPY NUMBER
		      ,p_ep_id OUT NOCOPY NUMBER
		      ,p_hdp_id OUT NOCOPY NUMBER
		      ,p_sdp_id OUT NOCOPY NUMBER
		      ,p_ep_type OUT NOCOPY VARCHAR2
		      ,p_egt_id OUT NOCOPY NUMBER
		      ,p_pep_id OUT NOCOPY NUMBER
		      ,p_pip_id OUT NOCOPY NUMBER
		      ,p_hcl_id OUT NOCOPY NUMBER
		      ,p_min_tcard_intvl OUT NOCOPY NUMBER
		      ,p_round_up OUT NOCOPY NUMBER
		      ,p_hcl_element_type_id OUT NOCOPY NUMBER
		      ,p_error OUT NOCOPY NUMBER) IS
  --
  --
  --  Procedure GET_POLICIES
  --  Purpose:  Gets policies assigned to an input person on an input date.
  --		Shift premiums returned by procedure Get_Shift_Info.
  --
  --  Returns p_error:
  --	0     - No errors occured
  --	Other - Oracle error number
  --
  --
  --
  -- Modification Log:
  -- 12/14/95   PJA   Added Min_Tcard_Intvl and Round_Up.
  -- 01/03/96   PJA   Handle date effectivity and return error code.
  --
  --
CURSOR policies_cur(c_earn_pol_id NUMBER, c_assignment_id NUMBER, c_date DATE) IS
SELECT aeiv.hxt_rotation_plan
       , egp.id
       , aeiv.hxt_hour_deduction_policy
       , aeiv.hxt_shift_differential_policy
       , egp.fcl_earn_type
       , egp.egt_id
       , egp.pep_id
       , egp.pip_id
       , egp.hcl_id
       , egp.min_tcard_intvl
       , egp.round_up
       , hcl.element_type_id
  FROM
        hxt_earning_policies egp
       , hxt_holiday_calendars hcl
       , hxt_per_aei_ddf_v aeiv
       , per_all_assignments_f asm
  WHERE  asm.assignment_id = p_assignment_id
    AND  asm.assignment_id = aeiv.assignment_id
    AND  c_date between aeiv.effective_start_date
                    and aeiv.effective_end_date
    AND  c_date between asm.effective_start_date
                    and asm.effective_end_date
    AND  c_date between hcl.effective_start_date
                    and hcl.effective_end_date
    AND  egp.hcl_id = hcl.id
    AND  c_date between egp.effective_start_date
                    and egp.effective_end_date
    AND egp.id = DECODE(c_earn_pol_id, NULL, aeiv.hxt_earning_policy, c_earn_pol_id);


BEGIN
   OPEN policies_cur(p_earn_pol_id, p_assignment_id, p_date);
  FETCH policies_cur
   INTO p_rotation_plan
        ,p_ep_id
        ,p_hdp_id
        ,p_sdp_id
        ,p_ep_type
        ,p_egt_id
	,p_pep_id
        ,p_pip_id
        ,p_hcl_id
        ,p_min_tcard_intvl
        ,p_round_up
        ,p_hcl_element_type_id;
  CLOSE policies_cur;

  --
  -- Set error code to no error
  p_error := 0;
 -- line C243 by BC
  p_work_plan := null;
--
EXCEPTION
  -- Return Oracle error number
  WHEN others THEN
    p_error := SQLCODE;
END;
--
--------------------------Get Shift Info --------------------------
PROCEDURE get_shift_info( p_date IN DATE
			, p_work_id IN OUT NOCOPY NUMBER
			, p_rotation_id IN NUMBER
			, p_osp_id OUT NOCOPY NUMBER
			, p_sdf_id OUT NOCOPY NUMBER
			, p_standard_start OUT NOCOPY NUMBER
			, p_standard_stop OUT NOCOPY NUMBER
			, p_early_start OUT NOCOPY NUMBER
			, p_late_stop OUT NOCOPY NUMBER
			, p_hours OUT NOCOPY NUMBER                  --SIR212
			, p_error OUT NOCOPY NUMBER) IS
  --
  --  Procedure GET_SHIFT_INFO
  --  Purpose:  Gets shift diff and off-shift premium for the person's
  --		assigned shift on an input date
  --
  --  Returns p_error:
  --	0     - No errors occured
  --	Other - Oracle error number
  --
  --
  --
  -- Modification Log:
  -- 01/05/96   PJA   Handle date effectivity and eturn error code.
  -- 01/22/96   PJA   Return shift start and stop times.  Return weekly work
  --			schedule ID if person assigned rotation schedule.
  --
  --
  l_date DATE;
BEGIN
  p_osp_id := NULL;
  p_sdf_id := NULL;
  p_early_start := NULL;
  p_late_stop := NULL;
  -- If rotation plan, get applicable work schedule id
    -- Find rotation containing work date
    SELECT rts.tws_id
    INTO   p_work_id
    FROM   hxt_rotation_schedules rts
    WHERE  rts.rtp_id = p_rotation_id
      AND  rts.start_date = (SELECT MAX(start_date)
			     FROM   hxt_rotation_schedules
			     WHERE  rtp_id = p_rotation_id
			       AND  start_date <= p_date
			     );
--ORACLE  END IF;
  -- Get shift diff and off-shift premiums
  SELECT wsh.off_shift_prem_id,
         wsh.shift_diff_ovrrd_id,
	 sht.standard_start,
	 sht.standard_stop,
	 sht.early_start,
	 sht.late_stop,
	 sht.hours
  INTO   p_osp_id,
	 p_sdf_id,
	 p_standard_start,
	 p_standard_stop,
	 p_early_start,
	 p_late_stop,
	 p_hours
  FROM   hxt_shifts sht,
	 hxt_weekly_work_schedules wws,
	 hxt_work_shifts wsh
  WHERE  wsh.week_day = hxt_util.get_week_day(p_date)
    AND  wws.id = wsh.tws_id
    AND  p_date between wws.date_from
	   and nvl(wws.date_to, p_date)
    AND  wws.id = p_work_id
    AND  sht.id = wsh.sht_id;
  --
  -- Set error code to no error
  p_error := 0;
--
EXCEPTION
  -- Return Oracle error number
  WHEN others THEN
    p_error := SQLCODE;
END;
--
-------------------------- Get Period End Date --------------------------
--
FUNCTION get_period_end_date(p_batch_id IN NUMBER) return VARCHAR2 IS
--
cursor csr_period_end IS
   select ptp.end_date
     from per_time_periods ptp,
          hxt_timecards_f htf
    where htf.batch_id = p_batch_id
      and htf.time_period_id = ptp.time_period_id;
--
cursor csr_retro_end IS
   select ptp.end_date
     from per_time_periods ptp,
          hxt_det_hours_worked_f hdh,
          hxt_timecards_f htf
    where hdh.retro_batch_id = p_batch_id
      and hdh.tim_id = htf.id
      and htf.time_period_id = ptp.time_period_id;
--
l_period_end_date DATE;
--
BEGIN
--
OPEN csr_period_end;
FETCH csr_period_end into l_period_end_date;
--
IF csr_period_end%NOTFOUND THEN
   --
   OPEN csr_retro_end;
   FETCH csr_retro_end into l_period_end_date;
   CLOSE csr_retro_end;
   --
END IF;
--
CLOSE csr_period_end;
--
RETURN fnd_date.date_to_displaydate(l_period_end_date);
--
END;
--
--------------------------Round Time --------------------------
FUNCTION round_time (p_time  DATE
                   , p_interval  NUMBER
                   , p_round_up  NUMBER) RETURN DATE IS
  l_min	   NUMBER;
  l_mod	   NUMBER;
BEGIN
  -- Get number of minutes past midnite
  l_min := ( p_time - Trunc( p_time,'DD') ) * (24*60);
  --
  -- Get number of minutes past interval
  l_mod := Mod( l_min, p_interval);
  --
  -- Apply interval rules to number of minutes (if remainder is less than round value,
  -- deduct the remainder - otherwise, deduct the remainder then add the interval)
  IF ( l_mod < p_round_up ) THEN
    l_min := l_min - l_mod;
  ELSE
    l_min := l_min - l_mod + p_interval;
  END IF;
  --
  -- Return new time (add minutes (converted to date) to date at midnite).
  -- Round to prevent truncation
  RETURN  Round( ( Trunc( p_time,'DD') + (l_min/60/24) ), 'MI' );
  --
END;
--
--------------------------Time to Hours --------------------------
FUNCTION time_to_hours(
  P_TIME IN NUMBER ) RETURN NUMBER
IS
BEGIN
  BEGIN
     RETURN(FLOOR((p_time / 100)) +(MOD(p_time, 100) / 60));
  END;
END time_to_hours;
--------------------------Get Next Seqno --------------------------
FUNCTION Get_Next_Seqno(a_timecard_id IN NUMBER, a_date_worked IN DATE) RETURN
NUMBER IS
--  Returns the max sequence + 10 of summary records of a given day on a given timecard
   returned_seqno      NUMBER;
BEGIN
   SELECT NVL(MAX(seqno),0) INTO returned_seqno FROM hxt_sum_hours_worked thw --C421
   WHERE thw.tim_id = a_timecard_id
   AND       thw.date_worked = a_date_worked;
   RETURN returned_seqno + 10;
END;
--BEGIN SPR C166 BY BC
--
--------------------------Get Period Start --------------------------
FUNCTION Get_Period_Start(a_period_id IN NUMBER) RETURN DATE IS
--  Returns the end date of pay period a_period_id
   returned_date DATE DEFAULT NULL; --SPR C166 BY BC
BEGIN
   SELECT start_date INTO returned_date
   FROM per_time_periods
   WHERE TIME_PERIOD_ID = a_period_id;
   RETURN returned_date;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN returned_date; --SPR C166 BY BC
END;
--
--------------------------Get Period End --------------------------
FUNCTION Get_Period_End(a_period_id IN NUMBER) RETURN DATE IS
--  Returns the end date of pay period a_period_id
   returned_date DATE DEFAULT NULL; --SPR C166 BY BC
BEGIN
   SELECT end_date INTO returned_date
   FROM per_time_periods
   WHERE TIME_PERIOD_ID = a_period_id;
   RETURN returned_date;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN returned_date; --SPR C166 BY BC
END;
--
--------------------------Set Tim Status --------------------------
--ORAXXX removed
--
--------------------------Date Range --------------------------
FUNCTION date_range (start_date_in IN DATE,
                     end_date_in IN DATE,
                     check_time_in IN VARCHAR2 := 'NOTIME') RETURN VARCHAR2
/*
|| date_range returns a string containing a date range
|| in the format 'BETWEEN x AND y'
||
|| Parameters:
||		start_date_in - The start date of the range. If NULL
||			then use the min_start_date. If that is NULL, range
||			has form '<= end_date'.
||

||		end_date_in - The end date of the range. If NULL
||			then use the max_end_date. If that is NULL, range has
||			form '>= start_date'.
||
||		check_time_in - If 'TIME' then use the time component
||			of the dates as part of the comparison.
||			If 'NOTIME' then strip off the time.
*/

IS
	/* String versions of parameters to place in return value */
	start_date_int VARCHAR2(30);
	end_date_int VARCHAR2(30);
	/* Date mask for date<->character conversions. */
	mask_int VARCHAR2(15) := 'MMDDYYYY';
	/* Version of date mask which fits right into date range string */
	mask_string VARCHAR2(30) := NULL;
	/* The return value for the function. */
   return_value VARCHAR2(1000) := NULL;
BEGIN
	/*
	|| Finalize the date mask. If user wants to use time, add that to
	|| the mask. Then set the string version by embedding the mask
	|| in single quotes and with a trailing paranthesis.
	*/
	IF UPPER (check_time_in) = 'TIME'
	THEN
		mask_int := mask_int || ' HHMISS';
	END IF;
	/*
	|| Convert mask. Example:
	|| 		If mask is:				MMDDYYYY HHMISS
	|| 		then mask string is: ', 'MMDDYYYY HHMISS')
	*/
	mask_string := ''', ''' || mask_int || ''')';
	/* Now convert the dates to character strings using format mask */
   start_date_int := TO_CHAR (start_date_in, mask_int);
	end_date_int := TO_CHAR (end_date_in, mask_int);
	/* If both start and end are NULL, then return NULL. */
	IF start_date_int IS NULL AND end_date_int IS NULL
	THEN
		return_value := NULL;
	/* If no start point then return "<=" format. */
	ELSIF start_date_int IS NULL
	THEN
		return_value := '<= TO_DATE (''' || end_date_int || mask_string;
	/* If no end point then return ">=" format. */
	ELSIF end_date_int IS NULL
	THEN
		return_value := '>= TO_DATE (''' || start_date_int || mask_string;
	/* Have start and end. A true range, so just put it together. */
	ELSE
		return_value :=
		  'BETWEEN TO_DATE (''' || start_date_int || mask_string ||
		     ' AND TO_DATE (''' || end_date_int || mask_string;
	END IF;
	RETURN return_value;
END;
--
--------------------------Get Retro Batch id --------------------------
FUNCTION Get_Retro_Batch_Id(p_tim_id IN NUMBER,
			    p_batch_name IN VARCHAR2 DEFAULT NULL,
			    p_batch_ref IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
   l_retro_id  NUMBER(15) := 0;
   l_retcode  NUMBER(15) := 0;
   l_assignment_id  NUMBER(15) := 0;

/*
   cursor existing_batch is
   select retro_batch_id, assignment_id
   from   hxt_det_hours_worked det,
          hxt_batch_states tbs
   where  det.tim_id = p_tim_id
   and    tbs.batch_id=det.retro_batch_id
   and    tbs.status in ('H','VE')
   and    pay_status = 'R';
*/

   cursor existing_batch is
   select retro_batch_id, assignment_id, pbh.batch_reference
   from   hxt_det_hours_worked det,
          hxt_batch_states tbs,
          pay_batch_headers pbh
   where  det.tim_id = p_tim_id
   and    tbs.batch_id = det.retro_batch_id
   and    tbs.status in ('H','VE')
   and    pay_status = 'R'
   and    pbh.batch_id = tbs.batch_id;

   cursor batch_param is
   select payroll_id, time_period_id, for_person_id
   from   hxt_timecards
   where  id = p_tim_id;

   bp     batch_param%ROWTYPE;
   l_batch_ref                     VARCHAR2(30);

BEGIN
   open existing_batch;
   fetch existing_batch into l_retro_id,l_assignment_id, l_batch_ref;
   if existing_batch%NOTFOUND then
     open batch_param;
     fetch batch_param into bp;
     if batch_param%FOUND then
        l_retcode := HXT_UTIL.create_batch('R',	--source is retro-pay
					p_batch_name,
					p_batch_ref,
				 	bp.payroll_id,
					bp.time_period_id,
					l_assignment_id,
					bp.for_person_id,
					l_retro_id);
        if l_retcode <> 0 then
           l_retro_id := 0;
        end if;
     else
        l_retro_id := 0;
     end if;
     close batch_param;
   else
      IF p_batch_ref IS NOT NULL THEN
         IF l_batch_ref NOT like p_batch_ref THEN
            l_retcode := HXT_UTIL.create_batch('R',
                                        p_batch_name,
                                        p_batch_ref,
                                        bp.payroll_id,
                                        bp.time_period_id,
                                        l_assignment_id,
                                        bp.for_person_id,
                                        l_retro_id);
            if l_retcode <> 0 then
               l_retro_id := 0;
            end if;
         END IF;
      END IF;
   end if;
   close existing_batch;
   return (l_retro_id);

END;
--
--------------------------Create Batch --------------------------
FUNCTION create_batch(	i_source IN VARCHAR2,
			p_batch_name IN VARCHAR2 DEFAULT NULL,
			p_batch_ref IN VARCHAR2 DEFAULT NULL,
		 	i_payroll_id IN NUMBER,
			i_time_period_id IN NUMBER,
			i_assignment_id IN NUMBER,
			i_person_id IN NUMBER,
			o_batch_id OUT NOCOPY NUMBER) RETURN NUMBER IS

  l_batch_id	        pay_batch_headers.batch_id%TYPE 	 DEFAULT NULL;
  l_reference_num       pay_batch_headers.batch_reference%TYPE   DEFAULT NULL;
  l_batch_name          pay_batch_headers.batch_name%TYPE        DEFAULT NULL;
  l_error_text          VARCHAR2(128)                            DEFAULT NULL;
  l_batch_id_error      EXCEPTION;
  l_reference_num_error EXCEPTION;
  l_retcode             NUMBER					 DEFAULT 0;
  l_user_id	        fnd_user.user_id%TYPE := FND_GLOBAL.User_Id;
  l_user_name		fnd_user.user_name%TYPE := 'OTM';
  l_sysdate		DATE := trunc(SYSDATE);
  l_bus_group_id	hr_organization_units.business_group_id%TYPE :=
				FND_PROFILE.Value( 'PER_BUSINESS_GROUP_ID' );

  l_object_version_number pay_batch_headers.object_version_number%TYPE;
   cursor assign_param(c_person_id NUMBER) IS
   select asm.business_group_id
     from per_assignment_status_types ast,
          per_assignments_f asm
    where asm.person_id = c_person_id
      and ast.assignment_status_type_id = asm.assignment_status_type_id
      and ast.pay_system_status = 'P';	-- Check payroll status

BEGIN
     IF p_batch_ref IS NULL THEN
     hxt_user_exits.Define_Reference_Number(i_payroll_id,
					i_time_period_id,
					i_assignment_id,
					i_person_id,
					l_user_name,
					i_source,
					l_reference_num,
					l_error_text);
     ELSE
        l_reference_num := p_batch_ref || ' R';
     END IF;

     IF l_error_text <> NULL THEN
       RETURN 1;
     END IF;

-- Get business_group_id from PER_ASSIGNMENTS_F table
     open assign_param(i_person_id);
     fetch assign_param into l_bus_group_id;
     if assign_param%NOTFOUND then
        close assign_param;
        RETURN 2;
     end if;
     close assign_param;

    /* Get next batch number */
      -- create a batch first
      pay_batch_element_entry_api.create_batch_header (
         p_session_date=> l_sysdate,
          p_batch_name=> to_char(sysdate, 'DD-MM-RRRR HH24:MI:SS'),
         p_batch_status=> 'U',
         p_business_group_id=> l_bus_group_id,
         p_action_if_exists=> 'I',
         p_batch_reference=> l_reference_num,
         p_batch_source=> 'OTM',
         p_purge_after_transfer=> 'N',
         p_reject_if_future_changes=> 'N',
         p_batch_id=> l_batch_id,
         p_object_version_number=> l_object_version_number
      );

   -- from the batch id, get the batch name
   IF p_batch_name IS NULL
   THEN
      hxt_user_exits.define_batch_name (
         l_batch_id,
         l_batch_name,
         l_error_text
      );

  /*  l_batch_id := hxt_time_gen.Get_Next_Batch_Id;
    IF l_batch_id = NULL THEN
       RETURN 2;
    END IF;
--
    IF p_batch_name IS NULL THEN
       hxt_user_exits.Define_Batch_Name(l_batch_id, l_batch_name, l_error_text);*/
    ELSE
       l_batch_name := p_batch_name || 'R' || to_char(l_batch_id);
    END IF;

    IF l_error_text <> NULL THEN
      RETURN 1;
    END IF;

   /* INSERT INTO pay_batch_headers
     (batch_id,
      business_group_id,
      batch_name,
      batch_status,
      action_if_exists,
      batch_reference,
      batch_source,
      purge_after_transfer,
      reject_if_future_changes,
      created_by,
      creation_date)
    VALUES
     (l_batch_id,
      l_bus_group_id,
      l_batch_name,
      'U',
      'I',
      l_reference_num,
      'OTM',
      'N',
      'N',
      l_user_id,
      l_sysdate);*/
      --update the batch name
      pay_batch_element_entry_api.update_batch_header (
         p_session_date => l_sysdate,
         p_batch_id=> l_batch_id,
         p_object_version_number=> l_object_version_number,
         p_batch_name=> l_batch_name
      );

  --COMMIT;
  o_batch_id := l_batch_id;
  return 0;
END create_batch;
--------------------------Gen Exception --------------------------
PROCEDURE GEN_EXCEPTION
      (p_LOCATION            IN   VARCHAR2
       ,p_HXT_ERROR_MSG      IN   VARCHAR2
       ,p_ORACLE_ERROR_MSG    IN   VARCHAR2
       ,p_RESOLUTION          IN   VARCHAR2) IS
l_EXCEP_seqno NUMBER;       --- the next sequence number for new error record
BEGIN

DEBUG(p_LOCATION || ' - ' || p_HXT_ERROR_MSG || ' : ' || p_ORACLE_ERROR_MSG ||
       ' => ' || p_RESOLUTION); --HXT115
null;
EXCEPTION WHEN OTHERS THEN
      null;
END gen_exception;
--
--------------------------Build Cost Alloc Flex Entry --------------------------
/******************************************************************
  build_cost_alloc_flex_entry()
  Select vital information from the fnd_id_flex_structures and
  fnd_id_flex_segments tables to build concatenated segments
  string using the segment values passed into this function.
  Then create a new entry to the pay_cost_allocation_keyflex table
  for the Cost Allocation Flexfield or retrieve the id of an existing
  one by calling the hr function hr_entry.maintain_cost_keyflex.
******************************************************************/
FUNCTION build_cost_alloc_flex_entry(i_segment1 IN VARCHAR2,
				     i_segment2 IN VARCHAR2,
				     i_segment3 IN VARCHAR2,
				     i_segment4 IN VARCHAR2,
				     i_segment5 IN VARCHAR2,
				     i_segment6 IN VARCHAR2,
				     i_segment7 IN VARCHAR2,
				     i_segment8 IN VARCHAR2,
				     i_segment9 IN VARCHAR2,
				     i_segment10 IN VARCHAR2,
				     i_segment11 IN VARCHAR2,
				     i_segment12 IN VARCHAR2,
				     i_segment13 IN VARCHAR2,
				     i_segment14 IN VARCHAR2,
				     i_segment15 IN VARCHAR2,
				     i_segment16 IN VARCHAR2,
				     i_segment17 IN VARCHAR2,
				     i_segment18 IN VARCHAR2,
				     i_segment19 IN VARCHAR2,
				     i_segment20 IN VARCHAR2,
				     i_segment21 IN VARCHAR2,
				     i_segment22 IN VARCHAR2,
				     i_segment23 IN VARCHAR2,
				     i_segment24 IN VARCHAR2,
				     i_segment25 IN VARCHAR2,
				     i_segment26 IN VARCHAR2,
				     i_segment27 IN VARCHAR2,
				     i_segment28 IN VARCHAR2,
				     i_segment29 IN VARCHAR2,
				     i_segment30 IN VARCHAR2,
				     i_business_group_id IN NUMBER,
				     io_keyflex_id IN OUT NOCOPY NUMBER,
				     o_error_msg OUT NOCOPY VARCHAR2)
--     p_mode IN VARCHAR2 default 'INSERT')
RETURN NUMBER IS

/* This cursor selects Cost Allocation Flexfield info needed */
/* to build an entry to pay_cost_allocation_keyflex          */

CURSOR cost_cur IS
  SELECT fifs.concatenated_segment_delimiter,
	 fifs.dynamic_inserts_allowed_flag,
	 fifs.enabled_flag,
	 fifs.freeze_flex_definition_flag
    FROM fnd_id_flex_structures fifs,
         per_business_groups_perf pbg
   WHERE fifs.id_flex_code = 'COST'
     AND fifs.application_id = 801
    AND pbg.business_group_id = i_business_group_id
    AND pbg.cost_allocation_structure = fifs.id_flex_num;

cost_rec cost_cur%ROWTYPE;

/* This cursor selects Cost Allocation Flexfield segments */
/* that have been defined and are enabled and have been   */
/* qualified for element entry 				  */

--CURSOR seg_cur IS
--CURSOR seg_cur(c_id_flex_num NUMBER) IS
--  SELECT seg.application_column_name,
--         seg.display_size,
--	 seg.segment_num
--    FROM fnd_id_flex_segments seg
--   WHERE seg.id_flex_code = 'COST'
--     AND seg.application_id = 801
--     AND seg.id_flex_num = c_id_flex_num
--     AND seg.application_column_name IN
--		('SEGMENT1','SEGMENT2','SEGMENT3','SEGMENT4','SEGMENT5',
--                 'SEGMENT6','SEGMENT7','SEGMENT8','SEGMENT9','SEGMENT10',
--                 'SEGMENT11','SEGMENT12','SEGMENT13','SEGMENT14','SEGMENT15',
--                 'SEGMENT16','SEGMENT17','SEGMENT18','SEGMENT19','SEGMENT20',
--                 'SEGMENT21','SEGMENT22','SEGMENT23','SEGMENT24','SEGMENT25',
--                 'SEGMENT26','SEGMENT27','SEGMENT28','SEGMENT29','SEGMENT30')
--     AND seg.enabled_flag = 'Y'
--     AND EXISTS (SELECT 'X'
--                   FROM fnd_segment_attribute_values fsav
--                  WHERE fsav.id_flex_code = 'COST'
--                    AND fsav.application_id = 801
--                    AND fsav.id_flex_num = seg.id_flex_num
--                    AND fsav.application_column_name = seg.application_column_name
--     	 	    AND fsav.attribute_value = 'Y')
--  ORDER BY seg.segment_num;

/* This cursor checks to see if this particular segment combination already exists */

--CURSOR exist_flex_cur(c_concatenated_segments pay_cost_allocation_keyflex.concatenated_segments%TYPE)IS
--  SELECT pcak.cost_allocation_keyflex_id
--    FROM pay_cost_allocation_keyflex pcak
--   WHERE pcak.concatenated_segments = c_concatenated_segments;

/* Cursor to generate a new Cost Allocation Keyflex Id */

--CURSOR flex_id_cur IS
--  SELECT pay_cost_allocation_keyflex_s.nextval
--    FROM sys.dual;

l_return_code		NUMBER;

--l_concatenated_segments pay_cost_allocation_keyflex.concatenated_segments%TYPE DEFAULT NULL;

l_id_flex_num fnd_id_flex_structures.id_flex_num%TYPE;
l_delimiter   fnd_id_flex_structures.concatenated_segment_delimiter%TYPE;
l_allowed     fnd_id_flex_structures.dynamic_inserts_allowed_flag%TYPE;
l_enabled     fnd_id_flex_structures.enabled_flag%TYPE;
l_frozen      fnd_id_flex_structures.freeze_flex_definition_flag%TYPE;

--l_key_num VARCHAR2(32);

flex_not_found 		EXCEPTION;
cost_flex_not_enabled 	EXCEPTION;
cost_flex_not_frozen 	EXCEPTION;
no_structure_found      EXCEPTION;

BEGIN

  pay_paywsqee_pkg.populate_context_items(i_business_group_id, l_id_flex_num);

  IF l_id_flex_num IS NULL THEN
    RAISE no_structure_found;
  END IF;
  OPEN cost_cur;
  FETCH cost_cur
    INTO l_delimiter,
	 l_allowed,
	 l_enabled,
	 l_frozen;
  IF cost_cur%NOTFOUND THEN
    RAISE flex_not_found;
    CLOSE cost_cur;
  END IF;
  CLOSE cost_cur;

  IF l_enabled = 'N' THEN
    RAISE cost_flex_not_enabled;
  END IF;

  IF l_frozen = 'N' THEN
    RAISE cost_flex_not_frozen;
  END IF;

--used  new procedure hr_entry.maintain_cost_keyflex  --2711607

  io_keyflex_id:=
	    hr_entry.maintain_cost_keyflex(
                  p_cost_keyflex_structure     => l_id_flex_num,
                  p_cost_allocation_keyflex_id => -1,
                  p_concatenated_segments      => NULL,
                  p_summary_flag               => 'N',
                  p_start_date_active          => NULL,
                  p_end_date_active            => NULL,
                  p_segment1                   => i_segment1,
                  p_segment2                   => i_segment2,
                  p_segment3                   => i_segment3,
                  p_segment4                   => i_segment4,
                  p_segment5                   => i_segment5,
                  p_segment6                   => i_segment6,
                  p_segment7                   => i_segment7,
                  p_segment8                   => i_segment8,
                  p_segment9                   => i_segment9,
                  p_segment10                  => i_segment10,
                  p_segment11                  => i_segment11,
                  p_segment12                  => i_segment12,
                  p_segment13                  => i_segment13,
                  p_segment14                  => i_segment14,
                  p_segment15                  => i_segment15,
                  p_segment16                  => i_segment16,
                  p_segment17                  => i_segment17,
                  p_segment18                  => i_segment18,
                  p_segment19                  => i_segment19,
                  p_segment20                  => i_segment20,
                  p_segment21                  => i_segment21,
                  p_segment22                  => i_segment22,
                  p_segment23                  => i_segment23,
                  p_segment24                  => i_segment24,
                  p_segment25                  => i_segment25,
                  p_segment26                  => i_segment26,
                  p_segment27                  => i_segment27,
                  p_segment28                  => i_segment28,
                  p_segment29                  => i_segment29,
                  p_segment30                  => i_segment30);

  RETURN 0;
-------------------------------------------
--commented as part of 2711607
--  FOR seg_rec IN seg_cur(l_id_flex_num) LOOP
--    IF seg_rec.application_column_name = 'SEGMENT1' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment1 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT2' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment2 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT3' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment3 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT4' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment4 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT5' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment5 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT6' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment6 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT7' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment7 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT8' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment8 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT9' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment9 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT10' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment10 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT11' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment11 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT12' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment12 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT13' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment13 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT14' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment14 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT15' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment15 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT16' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment16 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT17' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment17 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT18' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment18 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT19' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment19 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT20' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment20 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT21' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment21 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT22' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment22 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT23' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment23 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT24' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment24 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT25' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment25 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT26' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment26 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT27' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment27 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT28' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment28 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT29' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment29 || l_delimiter;
--    ELSIF seg_rec.application_column_name = 'SEGMENT30' THEN
--      l_concatenated_segments := l_concatenated_segments || i_segment30 || l_delimiter;
--    END IF;
--  END LOOP;

  /* Strip off a trailing delimiter if one exists */
--  IF SUBSTR(l_concatenated_segments,-1) = l_delimiter THEN
--    l_concatenated_segments := SUBSTR(l_concatenated_segments,0,LENGTH(l_concatenated_segments)-1);
--  END IF;

  /* Return NULL when no values exist */
--  IF LTRIM(l_concatenated_segments, l_delimiter) IS NULL THEN
--    io_keyflex_id := NULL;
--    RETURN 0;
--  END IF;

--  DEBUG('Concatenated Segments : ' || l_concatenated_segments);

     /* Attempt to find a matching keyflex entry  */
--     OPEN exist_flex_cur(l_concatenated_segments);
--     FETCH exist_flex_cur INTO io_keyflex_id;

     /*When no match exists,create a new entry in pay_cost_allocation_keyflex */
 --    IF exist_flex_cur%NOTFOUND THEN
--       CLOSE exist_flex_cur;

--       OPEN flex_id_cur;
--       FETCH flex_id_cur INTO io_keyflex_id;
--       CLOSE flex_id_cur;

--       INSERT INTO pay_cost_allocation_keyflex
--           (cost_allocation_keyflex_id
--           ,concatenated_segments
--           ,id_flex_num
--           ,last_update_date
--           ,last_updated_by
--           ,summary_flag
--           ,enabled_flag
--           ,start_date_active
--           ,end_date_active
--           ,segment1
--           ,segment2
--           ,segment3
--           ,segment4
--           ,segment5
--           ,segment6
--           ,segment7
--           ,segment8
--           ,segment9
--           ,segment10
--           ,segment11
--           ,segment12
--           ,segment13
--           ,segment14
--           ,segment15
--           ,segment16
--           ,segment17
--           ,segment18
--           ,segment19
--           ,segment20
--           ,segment21
--           ,segment22
--           ,segment23
--           ,segment24
--           ,segment25
--           ,segment26
--           ,segment27
--           ,segment28
--           ,segment29
--           ,segment30)
--        VALUES
--           (io_keyflex_id
--           ,l_concatenated_segments
--           ,l_id_flex_num
--           ,SYSDATE
--           ,NULL
--           ,'N'
--           ,'Y'
--           ,to_date('01-01-1900', 'DD-MM-YYYY') --fnd_date.chardate_to_date('1900/01/01')
--           ,NULL
--           ,i_segment1
--           ,i_segment2
--           ,i_segment3
--           ,i_segment4
--           ,i_segment5
--           ,i_segment6
--           ,i_segment7
--           ,i_segment8
--           ,i_segment9
--           ,i_segment10
--           ,i_segment11
--           ,i_segment12
--           ,i_segment13
--           ,i_segment14
--           ,i_segment15
--           ,i_segment16
--           ,i_segment17
--           ,i_segment18
--           ,i_segment19
--           ,i_segment20
--           ,i_segment21
--           ,i_segment22
--           ,i_segment23
--           ,i_segment24
--           ,i_segment25
--           ,i_segment26
--           ,i_segment27
--           ,i_segment28
--           ,i_segment29
--           ,i_segment30);
--     ELSE
--       CLOSE exist_flex_cur;
--     END IF;

--  RETURN 0;

EXCEPTION
   WHEN no_structure_found THEN
      FND_MESSAGE.SET_NAME('HXT','HXT_39470_CA_NOT_LOC_4_BUS_GRP');
      o_error_msg := FND_MESSAGE.GET;
      FND_MESSAGE.CLEAR;
      DEBUG('Cost Allocation Structure not located for this Business Group');
      RETURN 1;
   WHEN flex_not_found THEN
      FND_MESSAGE.SET_NAME('HXT','HXT_39471_CA_NOT_LOC_4_APP');
      o_error_msg := FND_MESSAGE.GET;
      FND_MESSAGE.CLEAR;
      DEBUG('Cost Allocation Flexfield not located for application 801');
      RETURN 1;
   WHEN cost_flex_not_enabled THEN
      FND_MESSAGE.SET_NAME('HXT','HXT_39472_CA_NOT_ENABLED');
      o_error_msg := FND_MESSAGE.GET;
      FND_MESSAGE.CLEAR;
      DEBUG('Cost Allocation Flexfield is not enabled');
      RETURN 1;
   WHEN cost_flex_not_frozen THEN
      FND_MESSAGE.SET_NAME('HXT','HXT_39473_CA_NOT_COMPILED');
      o_error_msg := FND_MESSAGE.GET;
      FND_MESSAGE.CLEAR;
      DEBUG('Cost Allocation Flexfield needs to be frozen and compiled');
      RETURN 1;
   WHEN OTHERS THEN
      o_error_msg := SQLERRM;
      DEBUG(SQLERRM); --HXT115
      RETURN 2;

END build_cost_alloc_flex_entry;
--End COSTING
--------------------------------------------PROCEDURE check_absence------------------------------------
--                 added 07/31/97   RDB
PROCEDURE check_absence(
		      P_assignment_id  IN NUMBER,
                      P_period_id IN NUMBER,
                      P_tim_id IN NUMBER,
                      P_calculation_date IN DATE,
                      P_element_type_id IN NUMBER,
                      P_hours IN NUMBER,
                      P_net_amt OUT NOCOPY NUMBER,
                      P_period_amt OUT NOCOPY NUMBER,
                      P_available_amt OUT NOCOPY NUMBER,
                      P_abs_status OUT NOCOPY NUMBER) IS
--
--   Updated 07-23-97   by RDB ... added EXTRA DATES AND CHANGED CALL FROM
--                                 PAY_US_PTO_ACCRUAL.GET_NET_ACCRUAL TO
--	                           TA_UTIL.TA_GET_NEXT_ACCRUAL.
-- Procedure check_absence
--
-- Purpose
--   Check the net accrual for a specific Absenece Element for sufficient hours
--   in order to allow person to take hours requested.  If enough, then return
--   P_abs_status = 0; if not, then return P_abs_status = 1; if NO PTO Accrual Plan,
--   then return P_abs_status = 2.
--
-- Arguments
p_plan_id  nuMBER;
p_PLAN_NAME VARCHAR2(80);
p_PLAN_ELEMENT_TYPE_ID NUMBER;
p_PLAN_CATEGORY VARCHAR2(30);
p_PLAN_CATEGORY_NAME VARCHAR2(80);
p_PTO_ELEMENT_TYPE_ID NUMBER;
p_PTO_ELEMENT_NAME VARCHAR2(80);
p_PTO_INPUT_VALUE_ID NUMBER;
p_PTO_INPUT_VALUE_NAME VARCHAR2(30);
--
-- Local Variables
l_amount NUMBER;
l_total_period_hrs NUMBER;
--
--  Get PTO ACCRUAL PLAN for Absence Element
--
     CURSOR pto_plan (p_assignment_id NUMBER,
	              p_calculation_date DATE) IS
      SELECT
	PAP.ACCRUAL_PLAN_ID,
	PAP.ACCRUAL_CATEGORY
      FROM
	PAY_ELEMENT_TYPES_F PETF,
	PAY_ELEMENT_CLASSIFICATIONS PEC,
	PAY_ELEMENT_ENTRIES_F PEEF,
	PAY_ELEMENT_LINKS_F PELF,
	PAY_ACCRUAL_PLANS PAP
      WHERE
	    PEEF.ASSIGNMENT_ID=P_assignment_id
        AND PETF.CLASSIFICATION_ID=PEC.CLASSIFICATION_ID
        AND UPPER(PEC.CLASSIFICATION_NAME) LIKE UPPER('PTO Accrual%')
 	AND PETF.ELEMENT_TYPE_ID=PELF.ELEMENT_TYPE_ID
 	AND PEEF.ELEMENT_LINK_ID=PELF.ELEMENT_LINK_ID
	AND p_calculation_date BETWEEN PETF.EFFECTIVE_START_DATE
	    AND PETF.EFFECTIVE_END_DATE
	AND PETF.ELEMENT_TYPE_ID = PAP.ACCRUAL_PLAN_ELEMENT_TYPE_ID;

--
--  Total all hours for Absence Element for current pay period
--
   CURSOR hr_amt(p_tim_id NUMBER,
                 p_assignment_id NUMBER,
	         p_element_type_id NUMBER) IS
   select sum(hrw.hours)
   from
	hxt_sum_hours_worked_x hrw
   where
        hrw.tim_id              = p_tim_id
        and hrw.assignment_id   = p_assignment_id
        and hrw.element_type_id = p_element_type_id;

--
BEGIN
  --
  --  Initialize OUT variables;
  P_net_amt := NULL;
  P_period_amt := NULL;
  P_abs_status := NULL;
  P_available_amt := NULL;
  --
  --   Get PTO plan for element type passed
  --
  open pto_plan(p_assignment_id,
	        p_calculation_date);
  --
  --
  fetch pto_plan into P_PLAN_ID,
                      p_PLAN_CATEGORY;
  --
  close pto_plan;
  --
  IF p_PLAN_ID IS NULL THEN
     P_abs_status := 2;             --- Element does not belong to an Accrual Plan
  ELSE
    --
    --   Get net Accrual plan amount
    --
      l_amount := PAY_US_PTO_ACCRUAL.GET_NET_ACCRUAL( P_assignment_id,
                                                      P_calculation_date,
                                                      P_plan_id,
                                                      P_plan_category);

    --
    P_net_amt := l_amount;
    --
    --   Get total Absence Element hours for current pay period
    --
    open hr_amt(p_tim_id,p_assignment_id,p_element_type_id);
    --
       fetch hr_amt into l_total_period_hrs;


    --
    close hr_amt;
    --
    --   Total Absence Element hours for current pay period
    --

    IF l_total_period_hrs IS NULL THEN
      l_total_period_hrs := 0;
    END IF;

    P_period_amt := l_total_period_hrs;


    l_total_period_hrs := l_total_period_hrs + p_hours;
    --
    --  Calculate net Accrual available if all Absence Elements are taken
    P_available_amt := l_amount - l_total_period_hrs;
    --
    --   Check that Hours to be charge to this Accrual plan are available to take
    --
      IF l_total_period_hrs <= l_amount THEN
      P_abs_status := 0;
    ELSE
--      P_abs_status := 1;
      P_abs_status := 0;
    END IF;
  END IF;
  --
  EXCEPTION
      WHEN others THEN
        P_abs_status := 3;
--
END CHECK_ABSENCE;
FUNCTION accrual_exceeded( p_tim_id  IN NUMBER,
                      P_calculation_date IN DATE,
                      P_accrual_plan_name OUT NOCOPY VARCHAR2,
                      P_accrued_hrs OUT NOCOPY NUMBER,
                      P_charged_hrs OUT NOCOPY NUMBER) return BOOLEAN IS

-- get all accrual plans for all assignments on this timecard
CURSOR plan_cur (p_assignment_id NUMBER) is
SELECT vap.assignment_id, vap.accrual_plan_id, vap.accrual_plan_name,
       vap.accrual_category, vap.business_group_id
  FROM pay_view_accrual_plans_v vap
 WHERE  vap.assignment_id = p_assignment_id
   AND p_calculation_date BETWEEN vap.asg_effective_start_date
                              AND vap.asg_effective_end_date
   AND p_calculation_date BETWEEN vap.iv_effective_start_date
                              AND vap.iv_effective_end_date
   AND p_calculation_date BETWEEN vap.e_entry_effective_start_date
                              AND vap.e_entry_effective_end_date
   AND p_calculation_date BETWEEN vap.e_type_effective_start_date
                              AND vap.e_type_effective_end_date
   AND p_calculation_date BETWEEN vap.e_link_effective_start_date
                              AND vap.e_link_effective_end_date;

CURSOR get_asg_id ( p_tim_id NUMBER,  p_calculation_date DATE ) IS
SELECT DISTINCT (assignment_id)
FROM hxt_sum_hours_worked_f
WHERE tim_id = p_tim_id
AND DATE_WORKED=p_calculation_date
AND SYSDATE BETWEEN effective_start_date AND effective_end_date;


-- get total on this timecard for all elements in the
-- net calculation rules for this accrual plan
CURSOR tc_tot_by_net_calc(p_tim_id NUMBER,
                          p_assignment_id NUMBER,
                          p_accrual_plan_id NUMBER,
                          p_bus_group_id NUMBER) IS
-- Bug 6785744
-- Changed the query to look at the base tables instead of the
-- view.  The view was over multiple TL tables and was adding
-- to the perf issues here.
-- We may make the same changes to the below cursor for retro total too.

/*
SELECT sum(hrw.hours*(-1)*(ncr.add_or_subtract))
  FROM hxt_sum_hours_worked_f hrw,
       pay_net_calculation_rules_v ncr
 WHERE hrw.tim_id = p_tim_id
   and SYSDATE between hrw.effective_start_date
                   and hrw.effective_end_date
   AND hrw.assignment_id = p_assignment_id
   AND ncr.business_group_id +0 = p_bus_group_id
   AND ncr.accrual_plan_id = p_accrual_plan_id
   AND ncr.element_type_id = hrw.element_type_id;
*/

  SELECT /*+ ORDERED */
         SUM(hrw.hours*(-1)*(ncr.add_or_subtract))
    FROM hxt_sum_hours_worked_f hrw,
	 pay_element_types_f pef,
	 pay_input_values_f piv,
	 pay_net_calculation_rules ncr
   WHERE hrw.tim_id = p_tim_id
     AND SYSDATE BETWEEN hrw.effective_start_date
 	             AND hrw.effective_end_date
     AND hrw.assignment_id        = p_assignment_id
     AND pef.element_type_id      = hrw.element_type_id
     AND SYSDATE BETWEEN pef.effective_start_date
                     AND pef.effective_end_date
     AND piv.element_type_id      = pef.element_type_id
     AND SYSDATE BETWEEN piv.effective_start_date
                     AND piv.effective_end_date
     AND piv.input_value_id       = ncr.input_value_id
     AND ncr.business_group_id +0 = p_bus_group_id
     AND ncr.accrual_plan_id      = p_accrual_plan_id ;


cursor get_max_retro_batch is
  select max(batch_id) from pay_batch_headers pbh
  where pbh.batch_status='T'
  and pbh.batch_id in (select distinct retro_batch_id from hxt_det_hours_worked_f
  where tim_id=p_tim_id);


cursor chk_retro_batch_status is
  select batch_id from pay_batch_headers pbh
  where pbh.batch_status='T'
  and pbh.batch_id in (select distinct retro_batch_id from hxt_det_hours_worked_f
  where tim_id=p_tim_id);


cursor chk_original_batch_status is
  select null from pay_batch_headers pbh
  where pbh.batch_status='T'
  and pbh.batch_id in (select distinct batch_id from hxt_timecards_f
  where id=p_tim_id);

cursor get_retro_total(   p_tim_id NUMBER,
                          p_assignment_id NUMBER,
                          p_accrual_plan_id NUMBER,
                          p_bus_group_id NUMBER,
                          p_batch_id number) is
SELECT nvl(sum(det.hours*(-1)*(ncr.add_or_subtract)),0)
    FROM hxt_det_hours_worked_f det,
         pay_net_calculation_rules_v ncr
   WHERE det.tim_id = p_tim_id
     AND det.assignment_id = p_assignment_id
     AND ncr.business_group_id = p_bus_group_id
     AND ncr.accrual_plan_id = p_accrual_plan_id
     AND ncr.element_type_id = det.element_type_id
     AND det.retro_batch_id=p_batch_id;

cursor get_org_total(     p_tim_id NUMBER,
                          p_assignment_id NUMBER,
                          p_accrual_plan_id NUMBER,
                          p_bus_group_id NUMBER) is
SELECT nvl(sum(det.hours*(-1)*(ncr.add_or_subtract)),0)
    FROM hxt_det_hours_worked_f det,
         pay_net_calculation_rules_v ncr
   WHERE det.tim_id = p_tim_id
     AND det.assignment_id = p_assignment_id
     AND ncr.business_group_id  = p_bus_group_id
     AND ncr.accrual_plan_id = p_accrual_plan_id
     AND ncr.element_type_id = det.element_type_id
     AND det.retro_batch_id is null;




l_charged_hrs 		NUMBER(7,3);
l_accrued_hrs 		NUMBER(7,3);
l_batch_id              NUMBER;
l_old_total             NUMBER;

l_asg_id per_all_assignments_f.assignment_id%TYPE;


BEGIN

OPEN  get_asg_id ( p_tim_id, p_calculation_date);
FETCH get_asg_id INTO l_asg_id;
CLOSE get_asg_id;

  FOR rec_plan IN plan_cur(l_asg_id) LOOP
    --   Get net Accrual plan amount
    --
    OPEN tc_tot_by_net_calc(p_tim_id,
                          rec_plan.assignment_id,
                          rec_plan.accrual_plan_id,
                          rec_plan.business_group_id);
    FETCH tc_tot_by_net_calc into l_charged_hrs;
    CLOSE tc_tot_by_net_calc;

    l_batch_id:=0;
    l_old_total:=0;

    	--check if timecard has been retro edited and is transferred to payroll

         open chk_retro_batch_status ;
         fetch chk_retro_batch_status  into l_batch_id;

            if chk_retro_batch_status %notfound then

                -- if timecard has been retro edited but not transferred to payroll
                -- or it is new timecard

            l_batch_id :=0;
      	    open chk_original_batch_status  ;
      	    fetch chk_original_batch_status   into l_batch_id;
      	       if chk_original_batch_status  %notfound then
        	 --it is new timecard
        	 l_batch_id :=0;
      	       end if;
         	    close chk_original_batch_status  ;
            else

                 -- since the retro batch exists get the last batch_id

           open get_max_retro_batch  ;
    	   fetch get_max_retro_batch into l_batch_id;
           close get_max_retro_batch  ;
           end if;
           close chk_retro_batch_status ;



          if(l_batch_id is not null )  then

             -- get the hours corresponding to retro batch

          open get_retro_total(p_tim_id,
                          rec_plan.assignment_id,
                          rec_plan.accrual_plan_id,
                          rec_plan.business_group_id,
                          l_batch_id);
          fetch get_retro_total into l_old_total;

            if(get_retro_total%notfound) then
             l_old_total:=0;
            end if;
          close get_retro_total;

    	else
          -- get the hours corresponding to non retro timecard

          open get_org_total(p_tim_id,
                          rec_plan.assignment_id,
                          rec_plan.accrual_plan_id,
                          rec_plan.business_group_id);
             fetch get_org_total into l_old_total;
                if(get_org_total%notfound) then
                 l_old_total:=0;
          	end if;
          close get_org_total;
      end if;

    if l_charged_hrs <> 0 then
      l_accrued_hrs :=
                 pay_us_pto_accrual.get_net_accrual( rec_plan.assignment_id,
                                                     p_calculation_date,
                                                     rec_plan.accrual_plan_id ,
--                                                     rec_plan.accrual_category);
                                                     NULL);
         if nvl((l_charged_hrs-l_old_total),0) > l_accrued_hrs then
         p_accrual_plan_name := rec_plan.accrual_plan_name;
         p_charged_hrs := l_charged_hrs;
         p_accrued_hrs := l_accrued_hrs;
         return TRUE;
      end if;
    end if;
  END LOOP;

    RETURN FALSE;
END;

--BEGIN SIR450
FUNCTION get_costable_type(p_element_type_id IN NUMBER,
                           p_date_worked IN DATE,
                           p_assignment_id IN NUMBER) return VARCHAR2 IS

CURSOR cur_costable_type IS
SELECT pel.costable_type
  FROM pay_element_links_f pel,
       per_assignments_f asm
 WHERE asm.assignment_id = p_assignment_id
   AND p_date_worked BETWEEN asm.effective_start_date
                         AND asm.effective_end_date
   AND nvl(pel.organization_id,nvl(asm.organization_id,-1)) = nvl(asm.organization_id,-1)
   AND (pel.people_group_id IS NULL
        OR exists (SELECT 'X'
                     FROM pay_assignment_link_usages_f usage
                    WHERE usage.assignment_id = asm.assignment_id
                      AND usage.element_link_id = pel.element_link_id
                      AND p_date_worked BETWEEN usage.effective_start_date
                                            AND usage.effective_end_date))
   AND nvl(pel.job_id, nvl(asm.job_id,-1)) = nvl(asm.job_id,-1)
   AND nvl(pel.position_id, nvl(asm.position_id,-1)) = nvl(asm.position_id,-1)
   AND nvl(pel.grade_id,nvl(asm.grade_id,-1)) = nvl(asm.grade_id,-1)
   AND nvl(pel.location_id,nvl(asm.location_id,-1)) = nvl(asm.location_id,-1)
   AND nvl(pel.payroll_id,nvl(asm.payroll_id,-1)) = nvl(asm.payroll_id,-1)
   AND nvl(pel.employment_category,nvl(asm.employment_category,-1)) = nvl(asm.employment_category,-1)
   AND nvl(pel.pay_basis_id,nvl(asm.pay_basis_id,-1)) = nvl(asm.pay_basis_id,-1)
   AND nvl(pel.business_group_id,nvl(asm.business_group_id,-1)) = nvl(asm.business_group_id,-1)
   AND p_date_worked BETWEEN pel.effective_start_date
                         AND pel.effective_end_date
   AND pel.element_type_id = p_element_type_id;

l_costable_type VARCHAR2(30);

BEGIN
  OPEN cur_costable_type;
  FETCH cur_costable_type into l_costable_type;
  RETURN(l_costable_type);
EXCEPTION
  WHEN others THEN
    RETURN('?');
END get_costable_type;

/********************************************************************
*  PROCEDURE SET_TIMECARD_ERROR          -- ER178  SDM 09-03-98     *
*                                                                   *
*  Purpose                                                          *
*    Retrieve Error Type From QUICK CODES then value is used to     *
*    inserting record in HXT_ERRORS table when an error is found    *
*    regarding Timecard, summary,  detailed Hours Worked orPay      *
*    Period record.of hxt_errors.                                   *
*                                                                   *
*  Arguments                                                        *
*    p_PBD_ID  - The source of the error is the BATCH record        *
*    p_TIM_ID  - The source of the error is the TIMECARD record     *
*    p_HRW_ID  - The source of the error is the Hours Worked record *
*    p_PTP_ID  - The source of the error is the TIME PERIOD RECORD. *
*    p_ERROR_MSG    - the error message to show the user            *
*    p_LOCATION     - the Procedure or Source                       *
*    p_ORA_MSG      - the ORACLE error number and message if any    *
*                                                                   *
********************************************************************/
Procedure SET_TIMECARD_ERROR (p_PPB_ID               IN NUMBER,
                              p_TIM_ID               IN NUMBER,
                              p_HRW_ID               IN NUMBER,
                              p_PTP_ID               IN NUMBER,
                              p_ERROR_MSG            IN OUT NOCOPY VARCHAR2,
                              p_LOCATION             IN VARCHAR2,
                              p_ORA_MSG              IN VARCHAR2,
                              p_LOOKUP_CODE          IN VARCHAR2,
                              p_valid                OUT NOCOPY VARCHAR,
                              p_msg_level            OUT NOCOPY VARCHAR2) IS

 CURSOR  tim_dates is
 SELECT  effective_start_date,
         effective_end_date
 FROM    HXT_TIMECARDS_X
 WHERE   id = p_tim_id;


   --  Local Variables
        l_CREATION_DATE DATE;          --- the date time of the error
        l_CREATED_BY    NUMBER;        --- the user logged in when the error occurred
        l_EXCEP_seqno   NUMBER;        --- the next sequence number for new error record
        l_error_msg     VARCHAR2(240);
        l_error         VARCHAR2(240);
        l_meaning       VARCHAR2(80);
        l_type          VARCHAR2(80);   --- Error type either 'ERR', 'WRN' or 'SKIP'
        l_eff_start  DATE;
        l_eff_end  DATE;
        l_person_id NUMBER;  -- ER230
        l_payroll_id NUMBER;  -- ER230
  --
  --
BEGIN

   OPEN tim_dates;
   FETCH tim_dates into l_eff_start, l_eff_end;

   -- Bug 8584436
   -- Modified the code slightly so that the global variable with messages with embedded
   -- token values is checked first before the error is inserted.

   if tim_dates%FOUND
   then

     IF hxt_batch_val.g_errtab.EXISTS(p_LOOKUP_CODE)
     THEN
        p_error_msg := hxt_batch_val.g_errtab(p_lookup_code).errmsg;
        l_type := hxt_batch_val.g_errtab(p_lookup_code).errtype;
     ELSE


        get_quick_codes(p_lookup_code,
     	                'HXT_TIMECARD_VALIDATION',
     	                808,
     	                l_meaning,
     	                l_type);


     	IF ( l_meaning = 'XXX' )
     	THEN

	-- the USER has modified the lookup_code

     	    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
     	    fnd_message.set_token('PROCEDURE', 'HXTUTL');
     	    fnd_message.set_token('STEP','Invalid HXT_TIMECARD_VALIDATION-'||p_lookup_code);
     	    fnd_message.raise_error;
     	END IF;

     	FND_MESSAGE.SET_NAME('HXT',l_meaning);
     	p_error_msg := FND_MESSAGE.GET;
     END IF;

     IF l_type = 'SKIP' THEN
       p_msg_level := ' ';
       p_valid := ' ';
       RETURN;
     ELSIF l_type = 'ERR' THEN
       FND_MESSAGE.SET_NAME('HXT','HXT_39503_QUICK_CODE_STOP');
       l_error_msg := FND_MESSAGE.GET || p_error_msg;
       p_msg_level := 'E';
     ELSIF l_type = 'WRN' THEN
       FND_MESSAGE.SET_NAME('HXT','HXT_39504_QUICK_CODE_WARN');
       l_error_msg := FND_MESSAGE.GET || p_error_msg;
       p_msg_level := 'W';
     ELSE
       FND_MESSAGE.SET_NAME('HXT','HXT_39505_INVALID_QUICK_CODE');
       l_error_msg := FND_MESSAGE.GET;
       l_type := 'ERR';
       p_msg_level := 'E';
     END IF;

     p_valid := 'N';

     SELECT hxt_seqno.nextval
     INTO l_EXCEP_seqno
     FROM dual;
     l_CREATED_BY := FND_GLOBAL.user_id;
     l_person_id := GetPersonID(p_TIM_ID);  -- ER230
     l_payroll_id := GetPayrollID(p_PTP_ID); -- ER230


     insert into hxt_errors_f(
            id,
            error_msg,
            creation_date,
            location,
            created_by,
            err_type,
            PPB_ID,
            TIM_ID,
            HRW_ID,
            PTP_ID,
            ora_message,
            EFFECTIVE_START_DATE,
            EFFECTIVE_END_DATE
           ,PERSON_ID  --ER230
           ,PAYROLL_ID  --ER230
           )
      values(l_EXCEP_seqno,
            substr(nvl(l_ERROR_MSG,'NOTPROVIDED'),1,239),
            sysdate,
            substr(nvl(p_LOCATION,'NOTPROVIDED'),1,119),
            nvl(l_CREATED_BY,-1),
            l_TYPE,
            p_PPB_id,
            p_TIM_id,
            p_HRW_ID,
            p_PTP_ID,
           substr(p_ORA_MSG,1,119),
           nvl(l_eff_start,sysdate),
           nvl(l_eff_end,hr_general.end_of_time)
          ,l_Person_ID   /* ER230 */
          ,l_Payroll_ID  /* ER230 */
         );

  CLOSE tim_dates;

END IF; -- l_meaning = 'XXX'

EXCEPTION
  WHEN others THEN
   l_error := SQLERRM;

   FND_MESSAGE.SET_NAME('HXT','HXT_39469_ERR_INS_HXT_ERR');
   insert into hxt_errors_f(
          id,
          error_msg,
          creation_date,
          location,
          created_by,
          err_type,
          PPB_ID,
          TIM_ID,
          HRW_ID,
          PTP_ID,
          ora_message,
          EFFECTIVE_START_DATE,
          EFFECTIVE_END_DATE)
    values(l_EXCEP_seqno,
          FND_MESSAGE.GET
          ||nls_initcap(substr(p_error_msg,1,100)),
          sysdate,
          'SET_TIMECARD_ERROR',
          -1,
          'NEW',
          NULL,
          NULL,
          NULL,
          NULL,
          l_error,
          nvl(l_eff_start,sysdate),
          nvl(l_eff_end,hr_general.end_of_time)
         );

END SET_TIMECARD_ERROR;

/********************************************************************
*  PROCEDURE GET_QUICK_CODES             -- ER178  SDM 09-03-98     *
*                                                                   *
*  Purpose                                                          *
*    Retrieve Values from QUICK CODES and retrun values             *
*                                                                   *
*  Arguments                                                        *
*   Inputs                                                          *
*    p_lookup_code                                                  *
*    p_lookup_type                                                  *
*    p_application_id                                               *
*   Outputs:                                                        *
*    p_lookup_meaning                                               *
*    p_TAG                                                          *
*                                                                   *
********************************************************************/

Procedure GET_QUICK_CODES(p_lookup_code          IN  VARCHAR2,
                          p_lookup_type          IN  VARCHAR2,
                          p_application_id       IN  NUMBER,
                          p_lookup_meaning       OUT NOCOPY VARCHAR2,
                          p_lookup_description   OUT NOCOPY VARCHAR2) is

CURSOR quick_codes IS
select
 meaning,
 UPPER(TAG)
FROM fnd_lookup_values
WHERE lookup_code = p_lookup_code
  AND SYSDATE BETWEEN NVL(start_date_active, SYSDATE)
  AND NVL(end_date_active, SYSDATE)
  AND LANGUAGE = userenv('LANG')
  AND VIEW_APPLICATION_ID = 3
  AND SECURITY_GROUP_ID = fnd_global.lookup_security_group(LOOKUP_TYPE,VIEW_APPLICATION_ID)
  AND enabled_flag = 'Y'
  AND lookup_type = p_lookup_type;

BEGIN
  OPEN  quick_codes;
  FETCH quick_codes into p_lookup_meaning, p_lookup_description;
  IF quick_codes%notfound then
    p_lookup_meaning := 'XXX';
    p_lookup_description := 'XXX';
  END IF;
  CLOSE quick_codes;

END get_quick_codes;

FUNCTION GetPersonID(p_TIM_ID NUMBER) RETURN NUMBER IS
cursor person_cur(c_tim_id NUMBER) is
select tim.for_person_id
  from hxt_timecards_x tim
 where tim.id = c_tim_id;

l_person_id  NUMBER := NULL;

BEGIN
   if p_tim_id is null then
      return null;
   end if;
   open person_cur(p_tim_id);
   fetch person_cur into l_person_id;
   close person_cur;
   return l_person_id;
END GetPersonID;


FUNCTION GetPayrollID(p_PTP_ID NUMBER) RETURN NUMBER IS

cursor payroll_cur(c_ptp_id NUMBER) is
select ptp.payroll_id
  from per_time_periods ptp
 where ptp.time_period_id = c_ptp_id;

l_payroll_id NUMBER := NULL;

BEGIN
   if p_ptp_id is null then
      return null;
   end if;
   open payroll_cur(p_ptp_id);
   fetch payroll_cur into l_payroll_id;
   close payroll_cur;
   return l_payroll_id;
END GetPayrollID;

PROCEDURE check_batch_states(P_BATCH_ID IN NUMBER) --3739107
IS
   CURSOR c_chk_tc_exists
   IS
   SELECT 'Y'
  FROM pay_batch_headers pbh
 WHERE pbh.batch_status <> 'T'
   AND pbh.batch_id = p_batch_id
   AND EXISTS ((SELECT HTF.batch_id
                  FROM hxt_timecards_f HTF
                 WHERE HTF.batch_id = pbh.batch_id)
               UNION
               (SELECT hdhw.retro_batch_id
                  FROM hxt_det_hours_worked_f hdhw
                 WHERE hdhw.retro_batch_id = pbh.batch_id));
   l_dummy   VARCHAR2 (1);
BEGIN
   g_debug :=hr_utility.debug_enabled;
 --hr_utility.trace_on(null,'Y');
   if g_debug then
   	hr_utility.trace('inside def');
   end if;
   OPEN c_chk_tc_exists;
   FETCH c_chk_tc_exists INTO l_dummy;

   IF (c_chk_tc_exists%FOUND)
   THEN
        if g_debug then
        	hr_utility.trace('inside def1');
        end if;
     HR_UTILITY.SET_MESSAGE(808, 'HXT_39144_CANT_DELETE_BATCH'); --This message is
     --not the actuall message, it is just meant for testing purpose
    CLOSE c_chk_tc_exists;
     hr_utility.raise_error;

   END IF;
  CLOSE c_chk_tc_exists;
END check_batch_states;



FUNCTION get_week_day(p_date in Date ) RETURN varchar2 IS

cursor weekday_cur(c_date Date) is
select DECODE (MOD (trunc(p_date)-trunc(hr_general.START_OF_TIME),7),
0,'SAT',
1,'SUN',
2,'MON',
3,'TUE',
4,'WED',
5,'THU',
6,'FRI'
)
from dual;



l_week_day varchar2(80) := NULL;
BEGIN
if p_date is null then
      return null;
   end if;
open weekday_cur(p_date);
   fetch weekday_cur into l_week_day;
   close weekday_cur;
   return l_week_day;

END get_week_day;

FUNCTION is_valid_time_entry (
p_raw_time_in IN hxt_det_hours_worked_f.time_in%TYPE,
p_rounded_time_in IN hxt_det_hours_worked_f.time_in%TYPE,
p_raw_time_out IN hxt_det_hours_worked_f.time_in%TYPE,
p_rounded_time_out IN hxt_det_hours_worked_f.time_in%TYPE
)
RETURN BOOLEAN AS

l_proc VARCHAR2 (30) ;
l_valid_entry BOOLEAN := TRUE;
c_hours_format CONSTANT VARCHAR2 (6) := 'HH24MI';

BEGIN

g_debug :=hr_utility.debug_enabled;
if g_debug then
	l_proc := 'is_valid_time_entry';

	hr_utility.set_location ( 'Entering: ' || l_proc, 10);
end if;

IF ( ( (TO_CHAR (p_raw_time_in, c_hours_format) <
TO_CHAR (p_raw_time_out, c_hours_format)
)
AND (TO_CHAR (p_rounded_time_in, c_hours_format) >
TO_CHAR (p_rounded_time_out, c_hours_format)
)
)
OR ( (TO_CHAR (p_raw_time_in, c_hours_format) >
TO_CHAR (p_raw_time_out, c_hours_format)
)
AND (TO_CHAR (p_rounded_time_in, c_hours_format) <
TO_CHAR (p_rounded_time_out, c_hours_format)
) ) ) THEN
     if g_debug then
     	     hr_utility.set_location ( 'Invalid entry: ' || l_proc, 20);
     end if;
     l_valid_entry := FALSE;
ELSE
     if g_debug then
     	    hr_utility.set_location ( 'Valid entry: ' || l_proc, 30);
     end if;
     l_valid_entry := TRUE;
END IF;

if g_debug then
	hr_utility.set_location ( 'Leaving: ' || l_proc, 100);
end if;

RETURN l_valid_entry;

END is_valid_time_entry;


PROCEDURE check_timecard_exists (p_person_id IN NUMBER)
IS
   CURSOR csr_chk_tc_exists_hxt
   IS
      SELECT 'Y'
        FROM hxt_timecards_f
       WHERE for_person_id = p_person_id;


   CURSOR csr_chk_tc_exists_ss
    IS
       SELECT 'Y'
         FROM hxc_time_building_blocks
        WHERE resource_id = p_person_id
        AND date_to=hr_general.end_of_time
        AND ROWNUM<2;

   l_dummy   VARCHAR2 (1);
BEGIN
   OPEN csr_chk_tc_exists_hxt;
   FETCH csr_chk_tc_exists_hxt INTO l_dummy;

   IF (csr_chk_tc_exists_hxt%FOUND)
   THEN
      CLOSE csr_chk_tc_exists_hxt;
      hr_utility.set_message (808, 'HXT_CANT_DEL_PERSON');
      hr_utility.raise_error;
   ElSE

CLOSE csr_chk_tc_exists_hxt;

   OPEN csr_chk_tc_exists_ss;
   FETCH csr_chk_tc_exists_ss INTO l_dummy;

   IF (csr_chk_tc_exists_ss%FOUND)
   THEN
      CLOSE csr_chk_tc_exists_ss;
      hr_utility.set_message (808, 'HXT_CANT_DEL_PERSON');
      hr_utility.raise_error;
   END IF;

   CLOSE csr_chk_tc_exists_ss;

END IF;
END check_timecard_exists;


--end ER230
--END HXT11i1

END hxt_util;

/
