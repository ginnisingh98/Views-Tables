--------------------------------------------------------
--  DDL for Package Body HXT_TIME_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_TIME_SUMMARY" AS
/* $Header: hxttsum.pkb 120.5.12010000.3 2009/08/22 12:11:21 asrajago ship $ */

--Global variables for package
--Used for parameters received that are not changed
  g_debug boolean := hr_utility.debug_enabled;
  g_ep_id                 NUMBER;
  g_ep_type               HXT_EARNING_POLICIES.FCL_EARN_TYPE%TYPE;
  g_egt_id                NUMBER;
  g_sdp_id                NUMBER;
  g_hdp_id                NUMBER;
  g_hol_id                NUMBER;
  g_pep_id                NUMBER;
  g_pip_id                NUMBER;
  g_sdovr_id              NUMBER;
  g_osp_id                NUMBER;
  g_hol_yn                VARCHAR2(1);
  g_person_id             NUMBER;
  g_ID                    NUMBER;
  g_EFFECTIVE_START_DATE  DATE;
  g_EFFECTIVE_END_DATE    DATE;
  g_ROWID                 ROWID;
  g_PARENT_ID             NUMBER;
  g_TIM_ID                NUMBER;
  g_DATE_WORKED           DATE;
  g_ASSIGNMENT_ID         NUMBER;
  g_HOURS                 NUMBER;
  g_TIME_IN               DATE;
  g_TIME_OUT              DATE;
  g_ELEMENT_TYPE_ID       NUMBER;
  g_FCL_EARN_REASON_CODE  HXT_SUM_HOURS_WORKED.FCL_EARN_REASON_CODE%TYPE;--C421
  g_FFV_COST_CENTER_ID    NUMBER;
  g_FFV_LABOR_ACCOUNT_ID  NUMBER;
  g_TAS_ID                NUMBER;
  g_LOCATION_ID           NUMBER;
  g_SHT_ID                NUMBER;
  g_HRW_COMMENT           HXT_SUM_HOURS_WORKED.HRW_COMMENT%TYPE;--C421
  g_FFV_RATE_CODE_ID      NUMBER;
  g_RATE_MULTIPLE         NUMBER;
  g_HOURLY_RATE           NUMBER;
  g_AMOUNT                NUMBER;
  g_FCL_TAX_RULE_CODE     HXT_SUM_HOURS_WORKED.FCL_TAX_RULE_CODE%TYPE;--C421
  g_SEPARATE_CHECK_FLAG   HXT_SUM_HOURS_WORKED.SEPARATE_CHECK_FLAG%TYPE;--C421
  g_SEQNO                 NUMBER;
  g_CREATED_BY            NUMBER;
  g_CREATION_DATE         DATE;
  g_LAST_UPDATED_BY       NUMBER;
  g_LAST_UPDATE_DATE      DATE;
  g_LAST_UPDATE_LOGIN     NUMBER;
  g_EARLY_START           NUMBER;
  g_LATE_STOP             NUMBER;
  g_STANDARD_START        NUMBER;
  g_STANDARD_STOP         NUMBER;
  g_PROJECT_ID            NUMBER;
  g_JOB_ID                hxt_SUM_HOURS_WORKED.JOB_ID%TYPE;
  g_PAY_STATUS            CHAR(1);
  g_PA_STATUS             CHAR(1);
  g_PERIOD_START_DATE     DATE;
  g_RETRO_BATCH_ID        NUMBER;
  g_DT_UPDATE_MODE        VARCHAR2(30);
--g_GROUP_ID              NUMBER;
  g_include_yn            VARCHAR2(1);
  g_start_day_of_week     VARCHAR2(30);

  g_CALL_ADJUST_ABS       VARCHAR2(1);



  -- Bug 8600894
  -- Added the following variables for calculation
  -- of Holiday hours as per holiday rule.
  g_hol_ep_id                 NUMBER;
  g_hol_ep_type               HXT_EARNING_POLICIES.FCL_EARN_TYPE%TYPE;
  g_hol_egt_id                NUMBER;
  g_hol_sdp_id                NUMBER;
  g_hol_hdp_id                NUMBER;
  g_hol_hol_id                NUMBER;
  g_hol_pep_id                NUMBER;
  g_hol_pip_id                NUMBER;
  g_hol_sdovr_id              NUMBER;
  g_hol_osp_id                NUMBER;
  g_hol_hol_yn                VARCHAR2(1);
  g_hol_person_id             NUMBER;
  g_hol_pk_ID                    NUMBER;
  g_hol_EFFECTIVE_START_DATE  DATE;
  g_hol_EFFECTIVE_END_DATE    DATE;
  g_hol_ROWID                 ROWID;
  g_hol_PARENT_ID             NUMBER;
  g_hol_TIM_ID                NUMBER;
  g_hol_DATE_WORKED           DATE;
  g_hol_ASSIGNMENT_ID         NUMBER;
  g_hol_HOURS                 NUMBER;
  g_hol_TIME_IN               DATE;
  g_hol_TIME_OUT              DATE;
  g_hol_ELEMENT_TYPE_ID       NUMBER;
  g_hol_FCL_EARN_REASON_CODE  HXT_SUM_HOURS_WORKED.FCL_EARN_REASON_CODE%TYPE;--C421
  g_hol_FFV_COST_CENTER_ID    NUMBER;
  g_hol_FFV_LABOR_ACCOUNT_ID  NUMBER;
  g_hol_TAS_ID                NUMBER;
  g_hol_LOCATION_ID           NUMBER;
  g_hol_SHT_ID                NUMBER;
  g_hol_HRW_COMMENT           HXT_SUM_HOURS_WORKED.HRW_COMMENT%TYPE;--C421
  g_hol_FFV_RATE_CODE_ID      NUMBER;
  g_hol_RATE_MULTIPLE         NUMBER;
  g_hol_HOURLY_RATE           NUMBER;
  g_hol_AMOUNT                NUMBER;
  g_hol_FCL_TAX_RULE_CODE     HXT_SUM_HOURS_WORKED.FCL_TAX_RULE_CODE%TYPE;--C421
  g_hol_SEPARATE_CHECK_FLAG   HXT_SUM_HOURS_WORKED.SEPARATE_CHECK_FLAG%TYPE;--C421
  g_hol_SEQNO                 NUMBER;
  g_hol_CREATED_BY            NUMBER;
  g_hol_CREATION_DATE         DATE;
  g_hol_LAST_UPDATED_BY       NUMBER;
  g_hol_LAST_UPDATE_DATE      DATE;
  g_hol_LAST_UPDATE_LOGIN     NUMBER;
  g_hol_EARLY_START           NUMBER;
  g_hol_LATE_STOP             NUMBER;
  g_hol_STANDARD_START        NUMBER;
  g_hol_STANDARD_STOP         NUMBER;
  g_hol_PROJECT_ID            NUMBER;
  g_hol_JOB_ID                hxt_SUM_HOURS_WORKED.JOB_ID%TYPE;
  g_hol_PAY_STATUS            CHAR(1);
  g_hol_PA_STATUS             CHAR(1);
  g_hol_PERIOD_START_DATE     DATE;
  g_hol_RETRO_BATCH_ID        NUMBER;
  g_hol_DT_UPDATE_MODE        VARCHAR2(30);
  g_hol_include_yn            VARCHAR2(1);
  g_hol_start_day_of_week     VARCHAR2(30);
  g_hol_STATE_NAME            hxt_sum_hours_worked_f.state_name%type;
  g_hol_COUNTY_NAME           hxt_sum_hours_worked_f.county_name%type;
  g_hol_CITY_NAME             hxt_sum_hours_worked_f.city_name%type;
  g_hol_ZIP_CODE              hxt_sum_hours_worked_f.zip_code%type;

  g_hol_location VARCHAR2(500);



--
--Flags for checking which shift diff premium gets paid for a segment chunk
--
  g_sdf_rule_completed    VARCHAR2(1);
  g_sdf_carryover         DATE;
  g_STATE_NAME            hxt_sum_hours_worked_f.state_name%type;
  g_COUNTY_NAME           hxt_sum_hours_worked_f.county_name%type;
  g_CITY_NAME             hxt_sum_hours_worked_f.city_name%type;
  g_ZIP_CODE              hxt_sum_hours_worked_f.zip_code%type;


--Function and Procedure declarations

FUNCTION valid_data(p_location IN VARCHAR2) RETURN NUMBER;

FUNCTION gen_details(p_location                IN VARCHAR2
                    ,p_shift_adjusted_time_in  IN DATE
                    ,p_shift_adjusted_time_out IN DATE )
                     RETURN NUMBER;

PROCEDURE Delete_Details(p_location   IN     VARCHAR2
                        ,p_error_code IN OUT NOCOPY NUMBER);

PROCEDURE  shift_adjust_times(p_shift_adjusted_time_in  OUT NOCOPY DATE
                             ,p_shift_adjusted_time_out OUT NOCOPY DATE);

PROCEDURE Rebuild_Details(p_location   IN     VARCHAR2
                         ,p_error_code IN OUT NOCOPY NUMBER);

FUNCTION call_gen_error
              (p_location          IN varchar2
              ,p_error_text        IN VARCHAR2
              ,p_oracle_error_text IN VARCHAR2 default NULL) RETURN NUMBER;

FUNCTION call_hxthxc_gen_error
         ( p_app_short_name    IN VARCHAR2
          ,p_msg_name	       IN VARCHAR2
	  ,p_msg_token	       IN VARCHAR2
	  ,p_location          IN varchar2
          ,p_error_text        IN VARCHAR2
          ,p_oracle_error_text IN VARCHAR2 default NULL) RETURN NUMBER ;


FUNCTION Get_Include(p_location        IN VARCHAR2
                    ,p_egt_id          IN NUMBER
                    ,p_element_type_id IN NUMBER
                    ,p_date            IN DATE) RETURN VARCHAR2;

FUNCTION GEN_SPECIAL (p_location               IN VARCHAR2
                     ,p_time_in                IN DATE
                     ,p_time_out               IN DATE
                     ,p_hours_worked           IN NUMBER
                     ,p_shift_diff_earning_id  IN NUMBER
                     ,p_sdovr_earning_id       IN NUMBER) RETURN NUMBER;


PROCEDURE store_globals;

PROCEDURE clear_globals;

PROCEDURE check_holiday_rule_behavior;

FUNCTION adjust_holiday_rule
RETURN NUMBER;


-- Bug 8600894
-- Store the global variables for later Holiday adjustment.
PROCEDURE store_globals
IS

BEGIN

     g_hol_ep_id                 := g_ep_id;
     g_hol_ep_type               := g_ep_type;
     g_hol_egt_id                := g_egt_id;
     g_hol_sdp_id                := g_sdp_id;
     g_hol_hdp_id                := g_hdp_id;
     g_hol_hol_id                := g_hol_id;
     g_hol_pep_id                := g_pep_id;
     g_hol_pip_id                := g_pip_id;
     g_hol_sdovr_id              := g_sdovr_id;
     g_hol_osp_id                := g_osp_id;
     g_hol_standard_start        := g_standard_start;
     g_hol_standard_stop         := g_standard_stop;
     g_hol_early_start           := g_early_start;
     g_hol_late_stop             := g_late_stop;
     g_hol_hol_yn                := g_hol_yn;
     g_hol_person_id             := g_person_id;
     g_hol_pk_ID                    := g_ID;
     g_hol_ROWID                 := CHARTOROWID(g_ROWID);
     g_hol_EFFECTIVE_START_DATE  := g_EFFECTIVE_START_DATE;
     g_hol_EFFECTIVE_END_DATE    := g_EFFECTIVE_END_DATE;
     g_hol_TIM_ID                := g_TIM_ID;
     g_hol_DATE_WORKED           := g_DATE_WORKED;
     g_hol_ASSIGNMENT_ID         := g_ASSIGNMENT_ID;
     g_hol_HOURS                 := g_HOURS;
     g_hol_TIME_IN               := g_TIME_IN;
     g_hol_TIME_OUT              := g_TIME_OUT;
     g_hol_ELEMENT_TYPE_ID       := g_ELEMENT_TYPE_ID;
     g_hol_FCL_EARN_REASON_CODE  := g_FCL_EARN_REASON_CODE;
     g_hol_FFV_COST_CENTER_ID    := g_FFV_COST_CENTER_ID;
     g_hol_FFV_LABOR_ACCOUNT_ID  := g_FFV_LABOR_ACCOUNT_ID;
     g_hol_TAS_ID                := g_TAS_ID;
     g_hol_LOCATION_ID           := g_LOCATION_ID;
     g_hol_SHT_ID                := g_SHT_ID;
     g_hol_HRW_COMMENT           := g_HRW_COMMENT;
     g_hol_FFV_RATE_CODE_ID      := g_FFV_RATE_CODE_ID;
     g_hol_RATE_MULTIPLE         := g_RATE_MULTIPLE;
     g_hol_HOURLY_RATE           := g_HOURLY_RATE;
     g_hol_AMOUNT                := g_AMOUNT;
     g_hol_FCL_TAX_RULE_CODE     := g_FCL_TAX_RULE_CODE;
     g_hol_SEPARATE_CHECK_FLAG   := g_SEPARATE_CHECK_FLAG;
     g_hol_SEQNO                 := g_SEQNO;
     g_hol_CREATED_BY            := g_CREATED_BY;
     g_hol_CREATION_DATE         := g_CREATION_DATE;
     g_hol_LAST_UPDATED_BY       := g_LAST_UPDATED_BY;
     g_hol_LAST_UPDATE_DATE      := g_LAST_UPDATE_DATE;
     g_hol_LAST_UPDATE_LOGIN     := g_LAST_UPDATE_LOGIN;
     g_hol_PROJECT_ID            := g_PROJECT_ID;
     g_hol_JOB_ID                := g_JOB_ID;
     g_hol_PAY_STATUS            := g_PAY_STATUS;
     g_hol_PA_STATUS             := g_PA_STATUS;
     g_hol_RETRO_BATCH_ID        := g_RETRO_BATCH_ID;
     g_hol_DT_UPDATE_MODE        := g_DT_UPDATE_MODE;
     g_hol_PERIOD_START_DATE     := g_PERIOD_START_DATE;
     g_hol_STATE_NAME            := g_STATE_NAME;
     g_hol_COUNTY_NAME           := g_COUNTY_NAME;
     g_hol_CITY_NAME             := g_CITY_NAME;
     g_hol_ZIP_CODE              := g_ZIP_CODE;
  -- g_hol_GROUP_ID              := g_GROUP_ID;


END store_globals;


-- Bug 8600894
-- Clears the holiday variables for the next detail.
PROCEDURE clear_globals
IS

BEGIN

     g_hol_ep_id                 := NULL;
     g_hol_ep_type               := NULL;
     g_hol_egt_id                := NULL;
     g_hol_sdp_id                := NULL;
     g_hol_hdp_id                := NULL;
     g_hol_hol_id                := NULL;
     g_hol_pep_id                := NULL;
     g_hol_pip_id                := NULL;
     g_hol_sdovr_id              := NULL;
     g_hol_osp_id                := NULL;
     g_hol_standard_start        := NULL;
     g_hol_standard_stop         := NULL;
     g_hol_early_start           := NULL;
     g_hol_late_stop             := NULL;
     g_hol_hol_yn                := NULL;
     g_hol_person_id             := NULL;
     g_hol_pk_ID                    := NULL;
     g_hol_ROWID                 := NULL;
     g_hol_EFFECTIVE_START_DATE  := NULL;
     g_hol_EFFECTIVE_END_DATE    := NULL;
     g_hol_TIM_ID                := NULL;
     g_hol_DATE_WORKED           := NULL;
     g_hol_ASSIGNMENT_ID         := NULL;
     g_hol_HOURS                 := NULL;
     g_hol_TIME_IN               := NULL;
     g_hol_TIME_OUT              := NULL;
     g_hol_ELEMENT_TYPE_ID       := NULL;
     g_hol_FCL_EARN_REASON_CODE  := NULL;
     g_hol_FFV_COST_CENTER_ID    := NULL;
     g_hol_FFV_LABOR_ACCOUNT_ID  := NULL;
     g_hol_TAS_ID                := NULL;
     g_hol_LOCATION_ID           := NULL;
     g_hol_SHT_ID                := NULL;
     g_hol_HRW_COMMENT           := NULL;
     g_hol_FFV_RATE_CODE_ID      := NULL;
     g_hol_RATE_MULTIPLE         := NULL;
     g_hol_HOURLY_RATE           := NULL;
     g_hol_AMOUNT                := NULL;
     g_hol_FCL_TAX_RULE_CODE     := NULL;
     g_hol_SEPARATE_CHECK_FLAG   := NULL;
     g_hol_SEQNO                 := NULL;
     g_hol_CREATED_BY            := NULL;
     g_hol_CREATION_DATE         := NULL;
     g_hol_LAST_UPDATED_BY       := NULL;
     g_hol_LAST_UPDATE_DATE      := NULL;
     g_hol_LAST_UPDATE_LOGIN     := NULL;
     g_hol_PROJECT_ID            := NULL;
     g_hol_JOB_ID                := NULL;
     g_hol_PAY_STATUS            := NULL;
     g_hol_PA_STATUS             := NULL;
     g_hol_RETRO_BATCH_ID        := NULL;
     g_hol_DT_UPDATE_MODE        := NULL;
     g_hol_PERIOD_START_DATE     := NULL;
     g_hol_STATE_NAME            := NULL;
     g_hol_COUNTY_NAME           := NULL;
     g_hol_CITY_NAME             := NULL;
     g_hol_ZIP_CODE              := NULL;
  -- g_hol_GROUP_ID              := NULL;


END clear_globals;



-- Check if this is a holiday day
PROCEDURE check_holiday_rule_behavior
IS

l_hdy_id   NUMBER;
l_hours    NUMBER;
l_retcode  NUMBER:= 0;

BEGIN


  HXT_UTIL.Check_For_Holiday(g_date_worked
                            ,g_hol_id
                            ,l_hdy_id
                            ,l_hours
                            ,l_retcode);

    IF    NVL(FND_PROFILE.VALUE('HXT_HOLIDAY_EXPLOSION'),'EX') <> 'EX'
      AND l_retcode = 1
    THEN
       store_globals;
    END IF;

END check_holiday_rule_behavior;


FUNCTION adjust_holiday_rule
RETURN NUMBER
IS

     CURSOR get_holiday_values(p_ep_id   IN NUMBER)
     IS SELECT hours,
               hours- NVL(LAG(hours) OVER (ORDER BY hours) ,0) cap,
	       element_type_id
          FROM hxt_earning_policies ep,
     	       hxt_earning_rules er
     	 WHERE ep.id = p_ep_id
     	   AND er.egp_id = ep.id
     	   AND g_sum_session_date BETWEEN er.effective_start_date
     	                              AND er.effective_end_date
     	   AND er.egr_type = 'HOL'
     	 ORDER BY hours;

     CURSOR get_reg_elements(p_ep_id   IN NUMBER,
                             p_date    IN DATE)
         IS SELECT DISTINCT
                   er.element_type_id
              FROM hxt_earning_rules er,
                   hxt_pay_element_types_f_ddf_v elem
             WHERE er.egp_id = p_ep_id
               AND p_date BETWEEN er.effective_start_date
                              AND er.effective_end_date
               AND g_sum_session_date BETWEEN er.effective_start_date
                                          AND er.effective_end_date
               AND elem.element_type_id = er.element_type_id
               AND elem.hxt_earning_category = 'REG';


    CURSOR get_other_summary(p_seq_no   IN NUMBER,
                             p_date     IN DATE)
        IS SELECT 1
             FROM hxt_sum_hours_worked_f sum
            WHERE seqno > p_seq_no
              AND tim_id = g_hol_tim_id
              AND g_sum_session_date BETWEEN sum.effective_start_date
                              AND sum.effective_end_date
              AND date_worked = p_date
              AND element_type_id IS NULL
              AND ROWNUM < 2;

    CURSOR get_next_summary(p_time_in   IN DATE,
                             p_date     IN DATE)
        IS SELECT 1
             FROM hxt_sum_hours_worked_f sum
            WHERE time_in > p_time_in
             AND g_sum_session_date BETWEEN sum.effective_start_date
                                        AND sum.effective_end_date
              AND tim_id = g_hol_tim_id
              AND date_worked = p_date
              AND element_type_id IS NULL
              AND ROWNUM < 2;


    CURSOR get_holiday_overtime
    IS
    SELECT NVL(SUM(det.hours),0)
      FROM hxt_det_hours_worked_f det,
           hxt_sum_hours_worked_f sum,
     	    hxt_earning_rules     er,
           hxt_pay_element_types_f_ddf_v elem
     WHERE det.tim_id =   g_hol_tim_id
       AND sum.id = det.parent_id
       AND g_sum_session_date BETWEEN sum.effective_start_date
                                  AND sum.effective_end_date
       AND g_sum_session_date BETWEEN det.effective_start_date
                                  AND det.effective_end_date
       AND g_sum_session_date BETWEEN elem.effective_start_date
                                  AND elem.effective_end_date
       AND g_sum_session_date BETWEEN er.effective_start_date
                                  AND er.effective_end_date
       AND sum.date_worked = g_hol_date_worked
       AND sum.element_type_id IS NULL
       AND er.egp_id = g_hol_ep_id
       AND er.egr_type NOT IN ('HOL')
       AND er.element_type_id = det.element_type_id
       AND elem.element_type_id = det.element_type_id
       AND elem.hxt_earning_category = 'OVT' ;



    TYPE HOLIDAY_TAB IS TABLE OF get_holiday_values%ROWTYPE INDEX BY BINARY_INTEGER;
    l_holidays  HOLIDAY_TAB;
    l_ind       BINARY_INTEGER;

    TYPE HOLIDAY_REC IS RECORD
    ( hours   NUMBER,
      time_in DATE,
      time_out DATE,
      element_type_id NUMBER);

    TYPE HOL_TAB IS TABLE OF HOLIDAY_REC INDEX BY BINARY_INTEGER;
    l_hol_tab HOL_TAB;
    e_ind  BINARY_INTEGER;


    TYPE ROWIDTAB IS TABLE OF VARCHAR2(30) ;
    l_det_row ROWIDTAB;

    l_element_string   VARCHAR2(200);

    l_sql   VARCHAR2(32000) :=
    'SELECT NVL(sum(sum.hours),0)
      FROM hxt_sum_hours_worked_f SUM,
           hxt_det_hours_worked_f DET
     WHERE sum.tim_id      = :tim_id
       AND sum.id          = det.parent_id
       AND sum.element_type_id IS NULL
       AND sum.date_worked =      FND_date.CANONICAL_TO_DATE(:date_worked)
       AND det.element_type_id IN ELEMENT_LIST
       AND FND_DATE.CANONICAL_TO_DATE(:session_date1) BETWEEN sum.effective_start_date
                                                          AND sum.effective_end_date
       AND FND_DATE.CANONICAL_TO_DATE(:session_date2) BETWEEN det.effective_start_date
                                                          AND det.effective_end_date' ;



    l_refcursor        SYS_REFCURSOR;
    l_paid_hours  	   NUMBER;
    l_hours       	   NUMBER;
    l_adjusted_hours   NUMBER;
    l_adjusted_element NUMBER;

    l_rebuild_code   NUMBER;
    l_time_in        DATE;
    l_time_out       DATE;
    l_reg            NUMBER;
    l_other_summary  NUMBER;

    l_hol_true       NUMBER;


BEGIN

     -- ADJUST_HOLIDAY_RULE
     -- Basic functionality here is to explode the time as per Holiday rule defined in the
     -- earning policy.  The whole thing would be done based on the value of HXT_HOLIDAY_EXPLOSION
     -- profile option.
     --      EX -- The existing and archaic behavior -- No rule except holiday rule.
     --      NE -- Normal explosion and Holiday rule together.  This means that
     --            explosion according to Daily/Weekly/Special rules happen as if there is
     --            No holiday rule.  And Holiday explosion would happen as per rules.
     --      NO -- Normal explosion happens along with Holiday rule, but only Overtime elements are
     --         -- paid.
     --      OO -- Normal explosion happens and only Overtime elements are paid.  Holiday rule is applicable
     --            Only for regular hours -- ie. whatever falls outside Overtime.


     --  The algorigthm followed is simple.


     SELECT 1
       INTO l_hol_true
       FROM hxt_holiday_days
      WHERE hcl_id = g_hol_hol_id
        AND holiday_date = g_hol_date_worked;

     IF l_hol_true IS NULL
     THEN
        IF g_debug
        THEN
           hr_utility.trace('Not a holiday '||g_hol_date_worked);
        END IF;
        clear_globals;
        RETURN 0;
     END IF;


     -- Find out if there is a holiday rule.
     -- If there is none, there is no need to proceed further.
     -- Do nothing, return.
     OPEN get_holiday_values(g_hol_ep_id);
     FETCH get_holiday_values BULK
                           COLLECT
                              INTO l_holidays;
     IF l_holidays.COUNT = 0
     THEN
         clear_globals;
         CLOSE get_holiday_values;
         IF g_debug
         THEN
             hr_utility.trace('No HOLIDAY RULE, NO ADJUSTMENT');
         END IF;
         RETURN 0;
     END IF;

     CLOSE get_holiday_values;

    -- If No Regular hours on holiday is the rule, delete
    -- all that is paid as WEEKLY/DAILY regular.

    IF fnd_profile.value('HXT_HOLIDAY_EXPLOSION') IN ('NO','OO')
    THEN

       IF g_hol_time_in IS NULL
       THEN
        OPEN get_other_summary(g_hol_seqno,g_hol_date_worked);
        FETCH get_other_summary INTO l_other_summary;
        CLOSE get_other_summary;
       ELSE
         OPEN get_next_summary(g_hol_time_in,g_hol_date_worked);
         FETCH get_next_summary INTO l_other_summary;
         CLOSE get_next_summary;
       END IF;

        IF g_debug
        THEN
            hr_utility.trace('Ash Hol G_hol_time_in '||to_char(g_hol_time_in,'dd-mon-yyyy hh24:mi'));
            hr_utility.trace('Ash Hol G_hol_time_out '||to_char(g_hol_time_out,'dd-mon-yyyy hh24:mi'));
        END IF;

        -- We should not delete the reg hours if there is another detail waiting to come up.
        -- If we do that OT calculation for the Day would topple up.
        IF l_other_summary IS NULL
        THEN

           OPEN get_reg_elements(g_hol_ep_id,g_date_worked);
      	   LOOP
    	       FETCH get_reg_elements INTO l_reg;

    	       EXIT WHEN get_reg_elements%NOTFOUND;

    	       SELECT rowidtochar(det.rowid)
    	         BULK COLLECT INTO l_det_row
    	        FROM hxt_sum_hours_worked_f sum,
    	             hxt_det_hours_worked_f det
    	       WHERE sum.element_type_id IS NULL
    	         AND sum.id = det.parent_id
    	         AND SYSDATE BETWEEN sum.effective_start_date
    	                         AND sum.effective_end_date
    	         AND SYSDATE BETWEEN det.effective_start_date
    	                         AND det.effective_end_Date
    	         AND det.tim_id = g_hol_tim_id
    	         AND det.element_type_id = l_reg
    	         AND sum.date_worked = g_hol_date_worked;

    	       IF l_det_row.COUNT > 0
    	       THEN
    	           FORALL i IN l_det_row.FIRST..l_det_row.LAST
    	            DELETE FROM hxt_det_hours_worked_f
    	                  WHERE ROWID = CHARTOROWID(l_det_row(i));
    	       END IF;



 	   END LOOP;
        END IF;
     END IF;


     -- Pick up all the holiday hours paid for this day.
     -- This is required so that we pay for only what is remaining in the
     -- Holiday rule.
     l_element_string := '( ';

     l_ind := l_holidays.FIRST;
     LOOP
         l_element_string := l_element_string||l_holidays(l_ind).element_type_id||',';
         l_ind := l_holidays.NEXT(l_ind);
         EXIT WHEN NOT  l_holidays.EXISTS(l_ind);
     END LOOP;
     l_element_string := rtrim(l_element_string,',')||')';

     -- l_element_string is a string of element_type_id s. Eg. (1234,2345)

     l_sql := REPLACE(l_sql,'ELEMENT_LIST',l_element_string);


     IF g_debug
     THEN
         hr_utility.trace('l_sql is '||l_sql);
     END IF;

     OPEN l_refcursor FOR l_sql USING g_hol_tim_id,
                                      FND_DATE.DATE_TO_CANONICAL(g_hol_date_worked),
                                      FND_DATE.DATE_TO_CANONICAL(g_sum_session_date),
                                      FND_DATE.DATE_TO_CANONICAL(g_sum_session_date);

     FETCH l_refcursor INTO l_paid_hours;

     CLOSE l_refcursor;

     l_hours := l_paid_hours;

     IF l_hours > 0
     THEN
        l_ind := l_holidays.FIRST;
        LOOP
           EXIT WHEN NOT l_holidays.EXISTS(l_ind);
           -- Paid hours is greater than this slab.
           -- Delete this slab.
           IF l_hours >= l_holidays(l_ind).hours
           THEN
               l_holidays.DELETE(l_ind);
           -- Paid hour is not greater, but the cap needs to be adjusted.
           ELSE
               l_holidays(l_ind).cap :=  l_holidays(l_ind).hours - l_hours ;
               l_holidays(l_ind).hours :=  l_holidays(l_ind).hours - l_hours ;
               EXIT;
           END IF;
           l_ind := l_holidays.NEXT(l_ind);
        END LOOP;
     END IF;

     -- If holiday explosion should occur only for what had to be paid for Regular,
     -- we need to subtract the total overtime paid from the total number of hours.

     IF FND_PROFILE.VALUE('HXT_HOLIDAY_EXPLOSION') = 'OO'
     THEN
        IF g_debug
        THEN
           hr_utility.trace('Holiday profile set to apply only on Reg elements ');
        END IF;
        OPEN get_holiday_overtime;

        FETCH get_holiday_overtime INTO l_hours;

        CLOSE get_holiday_overtime;
        IF g_debug
        THEN
           hr_utility.trace('Overtime already paid = '||l_hours);
           hr_utility.trace('Holiday hours now = '||g_hol_hours);
           hr_utility.trace('Holiday time_in now = '||TO_CHAR(g_hol_time_in,'HH24:MI'));
           hr_utility.trace('Holiday time_out now = '||TO_CHAR(g_hol_time_out,'HH24:MI'));
        END IF;

        IF l_hours >= g_hol_hours
        THEN
           RETURN 0;
        END IF;

        g_hol_hours := g_hol_hours - l_hours;
        g_hol_time_out := g_hol_time_out - (l_hours/24);

        IF g_debug
        THEN
           hr_utility.trace('After adjustment of Overtime ='||l_hours);
           hr_utility.trace('Holiday hours  = '||g_hol_hours);
           hr_utility.trace('Holiday time_in  = '||TO_CHAR(g_hol_time_in,'HH24:MI'));
           hr_utility.trace('Holiday time_out = '||TO_CHAR(g_hol_time_out,'HH24:MI'));
        END IF;
     END IF;

     -- Adjust the Hours and Time IN/OUT values.
     e_ind := 0;
     IF g_time_in IS NULL
     THEN
           l_hours := g_hol_hours;
     ELSE
         l_hours := (g_hol_time_out - g_hol_time_in)*24;
         l_time_in := g_hol_time_in;
         l_time_out := g_hol_time_out;
     END IF;


     l_ind := l_holidays.FIRST;
     LOOP
        EXIT WHEN NOT l_holidays.EXISTS(l_ind);
        IF l_holidays(l_ind).hours >= l_hours
        THEN
            -- If the number of hours to be paid falls above the cap,
            -- adjusted hours should be the Cap, and the element should be
            -- the current element.
            l_adjusted_hours := LEAST(l_hours,l_holidays(l_ind).cap);
            l_adjusted_element := l_holidays(l_ind).element_type_id;
            e_ind := e_ind +1;
            -- If its only hours
            IF g_time_in IS NULL
            THEN
               l_hol_tab(e_ind).element_type_id := l_adjusted_element;
               l_hol_tab(e_ind).hours := l_adjusted_hours;
            -- If its time_in/Time_out
            ELSE
               l_hol_tab(e_ind).element_type_id := l_adjusted_element;
               l_hol_tab(e_ind).time_in := l_time_in;
               l_hol_tab(e_ind).time_out := l_time_in + (l_adjusted_hours/24);
               l_time_in := l_hol_tab(e_ind).time_out;
               l_hol_tab(e_ind).hours := l_adjusted_hours;
            END IF;
            EXIT;
        ELSE
            l_adjusted_hours := l_holidays(l_ind).cap;
            l_adjusted_element := l_holidays(l_ind).element_type_id;
            l_hours := l_hours - l_holidays(l_ind).cap;
            e_ind := e_ind +1;
            l_hol_tab(e_ind).element_type_id := l_adjusted_element;
            IF g_time_in IS NULL
            THEN
               l_hol_tab(e_ind).hours := l_adjusted_hours;
            ELSE
               l_hol_tab(e_ind).time_in := l_time_in;
               l_hol_tab(e_ind).time_out := l_time_in + (l_adjusted_hours/24);
               l_time_in := l_hol_tab(e_ind).time_out;
               l_hol_tab(e_ind).hours := l_adjusted_hours;
            END IF;
        END IF;
        l_ind := l_holidays.NEXT(l_ind);
    END LOOP;


    e_ind := l_hol_tab.FIRST;
    LOOP
       EXIT WHEN NOT l_hol_tab.EXISTS(e_ind);
         g_ep_id                 := g_hol_ep_id;
         g_ep_type               := g_hol_ep_type;
         g_egt_id                := g_hol_egt_id;
         g_sdp_id                := g_hol_sdp_id;
         g_hdp_id                := g_hol_hdp_id;
         g_hol_id                := g_hol_hol_id;
         g_pep_id                := g_hol_pep_id;
         g_pip_id                := g_hol_pip_id;
         g_sdovr_id              := g_hol_sdovr_id;
         g_osp_id                := g_hol_osp_id;
         g_standard_start        := g_hol_standard_start;
         g_standard_stop         := g_hol_standard_stop;
         g_early_start           := g_hol_early_start;
         g_late_stop             := g_hol_late_stop;
         g_hol_yn                := g_hol_hol_yn;
         g_person_id             := g_hol_person_id;
         g_ID                    := g_hol_pk_ID;
         g_ROWID                 := CHARTOROWID(g_hol_ROWID);
         g_EFFECTIVE_START_DATE  := g_hol_EFFECTIVE_START_DATE;
         g_EFFECTIVE_END_DATE    := g_hol_EFFECTIVE_END_DATE;
         g_TIM_ID                := g_hol_TIM_ID;
         g_DATE_WORKED           := g_hol_DATE_WORKED;
         g_ASSIGNMENT_ID         := g_hol_ASSIGNMENT_ID;
         g_HOURS                 := l_hol_tab(e_ind).hours;
         g_TIME_IN               := l_hol_tab(e_ind).time_in;
         g_TIME_OUT              := l_hol_tab(e_ind).time_out;
         g_ELEMENT_TYPE_ID       := l_hol_tab(e_ind).element_type_id;
         g_FCL_EARN_REASON_CODE  := g_hol_FCL_EARN_REASON_CODE;
         g_FFV_COST_CENTER_ID    := g_hol_FFV_COST_CENTER_ID;
         g_FFV_LABOR_ACCOUNT_ID  := g_hol_FFV_LABOR_ACCOUNT_ID;
         g_TAS_ID                := g_hol_TAS_ID;
         g_LOCATION_ID           := g_hol_LOCATION_ID;
         g_SHT_ID                := g_hol_SHT_ID;
         g_HRW_COMMENT           := g_hol_HRW_COMMENT;
         g_FFV_RATE_CODE_ID      := g_hol_FFV_RATE_CODE_ID;
         g_RATE_MULTIPLE         := g_hol_RATE_MULTIPLE;
         g_HOURLY_RATE           := g_hol_HOURLY_RATE;
         g_AMOUNT                := g_hol_AMOUNT;
         g_FCL_TAX_RULE_CODE     := g_hol_FCL_TAX_RULE_CODE;
         g_SEPARATE_CHECK_FLAG   := g_hol_SEPARATE_CHECK_FLAG;
         g_SEQNO                 := g_hol_SEQNO;
         g_CREATED_BY            := g_hol_CREATED_BY;
         g_CREATION_DATE         := g_hol_CREATION_DATE;
         g_LAST_UPDATED_BY       := g_hol_LAST_UPDATED_BY;
         g_LAST_UPDATE_DATE      := g_hol_LAST_UPDATE_DATE;
         g_LAST_UPDATE_LOGIN     := g_hol_LAST_UPDATE_LOGIN;
         g_PROJECT_ID            := g_hol_PROJECT_ID;
         g_JOB_ID                := g_hol_JOB_ID;
         g_PAY_STATUS            := g_hol_PAY_STATUS;
         g_PA_STATUS             := g_hol_PA_STATUS;
         g_RETRO_BATCH_ID        := g_hol_RETRO_BATCH_ID;
         g_DT_UPDATE_MODE        := g_hol_DT_UPDATE_MODE;
         g_PERIOD_START_DATE     := g_hol_PERIOD_START_DATE;
         g_STATE_NAME            := g_hol_STATE_NAME;
         g_COUNTY_NAME           := g_hol_COUNTY_NAME;
         g_CITY_NAME             := g_hol_CITY_NAME;
         g_ZIP_CODE              := g_hol_ZIP_CODE;
      -- g_GROUP_ID              := g_hol_GROUP_ID;

         rebuild_details(g_hol_location,l_rebuild_code);
         IF l_rebuild_code <> 0
         THEN
             hr_utility.trace('There is a problem while readjusting holiday ');
             RETURN l_rebuild_code;
         END IF;

    e_ind := l_hol_tab.NEXT(e_ind);
    END LOOP;

    clear_globals;
    RETURN 0;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
           RETURN 0;


END adjust_holiday_rule;



------------generate details,loads globals and calls gen_details---------------
---------------return 0 for normal,1 for warning,2 for error-------------------

FUNCTION generate_details
  ( p_ep_id                      IN NUMBER
   ,p_ep_type                    IN VARCHAR2
   ,p_egt_id                     IN NUMBER
   ,p_sdp_id                     IN NUMBER
   ,p_hdp_id                     IN NUMBER
   ,p_hol_id                     IN NUMBER
   ,p_pep_id                     IN NUMBER
   ,p_pip_id                     IN NUMBER
   ,p_sdovr_id                   IN NUMBER
   ,p_osp_id                     IN NUMBER
   ,p_standard_start             IN NUMBER
   ,p_standard_stop              IN NUMBER
   ,p_early_start                IN NUMBER
   ,p_late_stop                  IN NUMBER
   ,p_hol_yn                     IN VARCHAR2
   ,p_person_id                  IN NUMBER
   ,p_location                   IN VARCHAR2
   ,p_ID                         IN NUMBER
   ,p_TIM_ID                     IN NUMBER
   ,p_DATE_WORKED                IN DATE
   ,p_ASSIGNMENT_ID              IN NUMBER
   ,p_HOURS                      IN NUMBER
   ,p_TIME_IN                    IN DATE
   ,p_TIME_OUT                   IN DATE
   ,p_ELEMENT_TYPE_ID            IN NUMBER
   ,p_FCL_EARN_REASON_CODE       IN VARCHAR2
   ,p_FFV_COST_CENTER_ID         IN NUMBER
   ,p_FFV_LABOR_ACCOUNT_ID       IN NUMBER
   ,p_TAS_ID                     IN NUMBER
   ,p_LOCATION_ID                IN NUMBER
   ,p_SHT_ID                     IN NUMBER
   ,p_HRW_COMMENT                IN VARCHAR2
   ,p_FFV_RATE_CODE_ID           IN NUMBER
   ,p_RATE_MULTIPLE              IN NUMBER
   ,p_HOURLY_RATE                IN NUMBER
   ,p_AMOUNT                     IN NUMBER
   ,p_FCL_TAX_RULE_CODE          IN VARCHAR2
   ,p_SEPARATE_CHECK_FLAG        IN VARCHAR2
   ,p_SEQNO                      IN NUMBER
   ,p_CREATED_BY                 IN NUMBER
   ,p_CREATION_DATE              IN DATE
   ,p_LAST_UPDATED_BY            IN NUMBER
   ,p_LAST_UPDATE_DATE           IN DATE
   ,p_LAST_UPDATE_LOGIN          IN NUMBER
   ,p_PERIOD_START_DATE          IN DATE     --SPR C389
   ,p_ROWIDIN                    IN VARCHAR2 --SIR012
   ,p_EFFECTIVE_START_DATE       IN DATE     --SIR012
   ,p_EFFECTIVE_END_DATE         IN DATE     --SIR012
   ,p_PROJECT_ID                 IN NUMBER   --SIR022
   ,p_JOB_ID                     IN NUMBER   --SIR015
   ,p_PAY_STATUS                 IN VARCHAR2 --SIR020
   ,p_PA_STATUS                  IN VARCHAR2 --SIR022
   ,p_RETRO_BATCH_ID             IN NUMBER   --SIR020
   ,p_DT_UPDATE_MODE             IN VARCHAR2 --SIR020
   ,p_CALL_ADJUST_ABS            IN VARCHAR2 DEFAULT 'Y'
   ,p_STATE_NAME                 IN VARCHAR2 DEFAULT NULL
   ,p_COUNTY_NAME                IN VARCHAR2 DEFAULT NULL
   ,p_CITY_NAME                  IN VARCHAR2 DEFAULT NULL
   ,p_ZIP_CODE                   IN VARCHAR2 DEFAULT NULL
 --,p_GROUP_ID                   IN NUMBER   -- HXT11i1
  ) RETURN NUMBER IS

    l_location                   VARCHAR2(120);
    l_error_code                 NUMBER := 0;
    l_rebuild_code               NUMBER := 0;
    shift_adjusted_time_in       DATE;
    shift_adjusted_time_out      DATE;

    otl_recurring_period         VARCHAR2(120);
    l_period_start_date          hxc_recurring_periods.start_date%TYPE;
    l_period_start               DATE;
    l_period_end                 DATE;
    l_period_type                hxc_recurring_periods.period_type%TYPE;


    -- Bug 7359347
    -- Return code for valid_data function, to avoid multiple
    -- calls.
    l_vd_retcode                 NUMBER;

   /*  Bug: 4489952 changes starts here */

    -- procedure to insert the non-explosion timecard entries directly
    -- into table 'hxt_det_hours_worked_f' without calling the explosion code.
    PROCEDURE insert_non_explodable_hrs
    IS
       l_object_version_number      HXT_DET_HOURS_WORKED_F.OBJECT_VERSION_NUMBER%TYPE;
       l_rowid                      ROWID;
       l_id                         NUMBER;
       l_pay_status                 VARCHAR2(1);
       l_pa_status                  VARCHAR2(1);
       l_retro_batch_id             NUMBER(15);
       l_error_status               NUMBER(15);
       l_sqlerrm                    VARCHAR2(200);
       l_rate_multiple              HXT_PAY_ELEMENT_TYPES_F_DDF_V.HXT_PREMIUM_AMOUNT%TYPE;
       l_hourly_rate                HXT_PAY_ELEMENT_TYPES_F_DDF_V.HXT_PREMIUM_AMOUNT%TYPE;
       l_amount                     HXT_PAY_ELEMENT_TYPES_F_DDF_V.HXT_PREMIUM_AMOUNT%TYPE;
       l_hours                      HXT_DET_HOURS_WORKED_F.HOURS%TYPE; -- SIR092
       l_costable_type              PAY_ELEMENT_LINKS_F.COSTABLE_TYPE%TYPE;
       l_ffv_cost_center_id         HXT_DET_HOURS_WORKED_F.FFV_COST_CENTER_ID%TYPE;
       l_premium_type               HXT_PAY_ELEMENT_TYPES_F_DDF_V.HXT_PREMIUM_TYPE%TYPE;
       l_premium_amount             HXT_PAY_ELEMENT_TYPES_F_DDF_V.HXT_PREMIUM_AMOUNT%TYPE;
       l_processing_order           HXT_PAY_ELEMENT_TYPES_F_DDF_V.HXT_PROCESSING_ORDER%TYPE;

       CURSOR next_id_cur IS
       SELECT hxt_seqno.nextval next_id
       FROM   dual;

       CURSOR get_ovt_rates_cur IS
       SELECT eltv.hxt_premium_type,
              eltv.hxt_premium_amount,
              eltv.hxt_processing_order
       FROM   hxt_pay_element_types_f_ddf_v eltv
       WHERE  eltv.hxt_earning_category NOT IN ('REG', 'ABS')
       AND    g_DATE_WORKED between eltv.effective_start_date
                                and eltv.effective_end_date
       AND    eltv.element_type_id = g_element_type_id
       ORDER by eltv.hxt_processing_order;

    BEGIN

       IF g_debug THEN
          hr_utility.set_location('hxt_time_summary.insert_non_explodable_hrs',10);
       END IF;

       l_hours := p_hours ; -- SIR092

       OPEN next_id_cur;
       FETCH next_id_cur INTO l_id;

       IF g_debug THEN
          hr_utility.trace('l_id :'||l_id);
       END IF;

       CLOSE next_id_cur;

       OPEN get_ovt_rates_cur;
       FETCH get_ovt_rates_cur
       INTO  l_premium_type, l_premium_amount, l_processing_order;

       IF g_debug THEN
          hr_utility.trace('premium_type     :'||l_premium_type);
          hr_utility.trace('premium_amount   :'||l_premium_amount);
          hr_utility.trace('processing_order :'||l_processing_order);
       END IF;

       CLOSE get_ovt_rates_cur;

       IF l_premium_type     = 'FACTOR' THEN
          l_rate_multiple := l_premium_amount;
       ELSIF l_premium_type  = 'RATE' THEN
          l_hourly_rate   := l_premium_amount;
       ELSIF l_premium_type  = 'FIXED' THEN
          l_amount        := l_premium_amount;
          l_hours         := 0 ; -- SIR092 Hours have no meaning with
                                 -- flat amount premiums
       END IF;

       -- Any values passed in from globals will override retrieved values.

       IF g_rate_multiple IS NOT NULL THEN
          l_rate_multiple := g_rate_multiple ;
       END IF ;
       IF g_hourly_rate IS NOT NULL THEN
          l_hourly_rate := g_hourly_rate ;
       END IF  ;
       IF g_amount IS NOT NULL THEN
          l_amount := g_amount ;
       END IF ;

       l_costable_type := HXT_UTIL.get_costable_type(g_element_type_id,
                                                     g_date_worked,
                                                     g_assignment_id);
       IF g_debug THEN
          hr_utility.trace('l_costable_type :'||l_costable_type);
       END IF;

       IF l_costable_type in ('C','F') THEN
          l_ffv_cost_center_id := g_ffv_cost_center_id;
       ELSE
          l_ffv_cost_center_id := NULL;
       END IF;

       hxt_time_pay.get_retro_fields( g_tim_id
                                     ,HXT_TIME_COLLECTION.g_batch_name
                                     ,HXT_TIME_COLLECTION.g_batch_ref
                                     ,l_pay_status
                                     ,l_pa_status
                                     ,l_retro_batch_id
                                     ,l_error_status
                                     ,l_sqlerrm);

       IF l_error_status = 0 THEN
          IF g_debug then
             hr_utility.set_location('hxt_time_summary.insert_non_explodable_hrs',20);
          END IF;

          HXT_DML.INSERT_HXT_DET_HOURS_WORKED (
              p_rowid        		=> l_rowid,
  	      p_id                     	=> l_id,
	      p_parent_id              	=> g_id,
	      p_tim_id                 	=> g_tim_id,
	      p_date_worked           	=> g_date_worked,
	      p_assignment_id         	=> g_assignment_id,
	      p_hours                 	=> l_hours,
	      p_time_in               	=> g_time_in,
	      p_time_out              	=> g_time_out,
	      p_element_type_id       	=> g_element_type_id,
	      p_fcl_earn_reason_code 	=> g_fcl_earn_reason_code,
	      p_ffv_cost_center_id   	=> l_ffv_cost_center_id,
	      p_ffv_labor_account_id	=> NULL,
	      p_tas_id             	=> g_TAS_ID,
	      p_location_id       	=> g_location_id,
	      p_sht_id           	=> g_sht_id,
	      p_hrw_comment     	=> g_hrw_comment,
	      p_ffv_rate_code_id      	=> g_ffv_rate_code_id,
	      p_rate_multiple        	=> l_rate_multiple,
	      p_hourly_rate         	=> l_hourly_rate,
	      p_amount             	=> l_amount,
	      p_fcl_tax_rule_code 	=> g_fcl_tax_rule_code,
	      p_separate_check_flag  	=> g_separate_check_flag,
	      p_seqno               	=> g_seqno,
	      p_created_by         	=> g_created_by,
	      p_creation_date  		=> g_creation_date,
	      p_last_updated_by		=> g_last_updated_by,
	      p_last_update_date      	=> g_last_update_date,
	      p_last_update_login    	=> g_last_update_login,
	      p_actual_time_in     	=> NULL,
	      p_actual_time_out		=> NULL,
	      p_effective_start_date 	=> g_effective_start_date,
	      p_effective_end_date  	=> g_effective_end_date,
	      p_project_id         	=> g_project_id,
	      p_job_id         		=> NULL,
	      p_earn_pol_id    		=> NULL,
	      p_retro_batch_id 		=> l_retro_batch_id,
	      p_pa_status     		=> l_pa_status,
	      p_pay_status   		=> l_pay_status,
	      --p_group_id		=> g_group_id,
	      p_object_version_number 	=> l_object_version_number,
              p_STATE_NAME              => g_STATE_NAME,
	      p_COUNTY_NAME             => g_COUNTY_NAME,
	      p_CITY_NAME               => g_CITY_NAME,
	      p_ZIP_CODE                => g_ZIP_CODE);

       ELSE  /* l_error_status <> 0 */
          IF g_debug then
             hr_utility.set_location('hxt_time_summary.insert_non_explodable_hrs', 30);
          END IF;
          -- Insert record in error table.
          FND_MESSAGE.SET_NAME('HXT','HXT_39421_GET_RETRO_ERR');
       END IF;

    EXCEPTION
       WHEN OTHERS THEN
          IF g_debug THEN
            hr_utility.set_location('hxt_time_summary.insert_non_explodable_hrs', 40);
          END IF;
          -- Insert record in error table.
         FND_MESSAGE.SET_NAME('HXT','HXT_39313_OR_ERR_INS_REC');

    END insert_non_explodable_hrs;

    Function check_non_explosion_entry (p_element_type_id IN NUMBER, p_date_worked DATE)
    RETURN BOOLEAN IS
      l_non_explosion_flag  VARCHAR2(1);

       CURSOR check_non_explosion_entry IS
       SELECT 'Y'
       FROM   hxt_add_elem_info_f
       WHERE  element_type_id = p_element_type_id
       AND    p_date_worked BETWEEN effective_start_date
                                AND effective_end_date
       AND    NVL(exclude_from_explosion, 'N') = 'Y';

    BEGIN

       FOR i in check_non_explosion_entry
       LOOP
          l_non_explosion_flag := 'Y';
       END LOOP;

       IF l_non_explosion_flag = 'Y' THEN
          Return TRUE;
       ELSE
          Return FALSE;
       END IF;
    END check_non_explosion_entry;

   /* Bug: 4489952 changes ends here */

BEGIN
   g_debug :=hr_utility.debug_enabled;
   if g_debug then
   	   hr_utility.set_location('hxt_time_summary.generate_details',10);
   end if;

-- Set the flags for checking which shift diff premium gets paid for a
-- segment chunk.
   g_sdf_rule_completed    := 'Y';
   g_sdf_carryover         := null;

-- Set global variables for package with parameter values
   g_ep_id                 := p_ep_id;
   g_ep_type               := p_ep_type;
   g_egt_id                := p_egt_id;
   g_sdp_id                := p_sdp_id;
   g_hdp_id                := p_hdp_id;
   g_hol_id                := p_hol_id;
   g_pep_id                := p_pep_id;
   g_pip_id                := p_pip_id;
   g_sdovr_id              := p_sdovr_id;
   g_osp_id                := p_osp_id;
   g_standard_start        := p_standard_start;
   g_standard_stop         := p_standard_stop;
   g_early_start           := p_early_start;
   g_late_stop             := p_late_stop;
   g_hol_yn                := p_hol_yn;
   g_person_id             := p_person_id;
   g_ID                    := p_ID;
   g_ROWID                 := CHARTOROWID(p_ROWIDIN);
   g_EFFECTIVE_START_DATE  := p_EFFECTIVE_START_DATE;
   g_EFFECTIVE_END_DATE    := p_EFFECTIVE_END_DATE;
   g_TIM_ID                := p_TIM_ID;
   g_DATE_WORKED           := p_DATE_WORKED;
   g_ASSIGNMENT_ID         := p_ASSIGNMENT_ID;
   g_HOURS                 := p_HOURS;
   g_TIME_IN               := p_TIME_IN;
   g_TIME_OUT              := p_TIME_OUT;
   g_ELEMENT_TYPE_ID       := p_ELEMENT_TYPE_ID;
   g_FCL_EARN_REASON_CODE  := p_FCL_EARN_REASON_CODE;
   g_FFV_COST_CENTER_ID    := p_FFV_COST_CENTER_ID;
   g_FFV_LABOR_ACCOUNT_ID  := p_FFV_LABOR_ACCOUNT_ID;
   g_TAS_ID                := p_TAS_ID;
   g_LOCATION_ID           := p_LOCATION_ID;
   g_SHT_ID                := p_SHT_ID;
   g_HRW_COMMENT           := p_HRW_COMMENT;
   g_FFV_RATE_CODE_ID      := p_FFV_RATE_CODE_ID;
   g_RATE_MULTIPLE         := p_RATE_MULTIPLE;
   g_HOURLY_RATE           := p_HOURLY_RATE;
   g_AMOUNT                := p_AMOUNT;
   g_FCL_TAX_RULE_CODE     := p_FCL_TAX_RULE_CODE;
   g_SEPARATE_CHECK_FLAG   := p_SEPARATE_CHECK_FLAG;
   g_SEQNO                 := p_SEQNO;
   g_CREATED_BY            := p_CREATED_BY;
   g_CREATION_DATE         := p_CREATION_DATE;
   g_LAST_UPDATED_BY       := p_LAST_UPDATED_BY;
   g_LAST_UPDATE_DATE      := p_LAST_UPDATE_DATE;
   g_LAST_UPDATE_LOGIN     := p_LAST_UPDATE_LOGIN;
   g_PROJECT_ID            := p_PROJECT_ID;
   g_JOB_ID                := p_JOB_ID;
   g_PAY_STATUS            := p_PAY_STATUS;
   g_PA_STATUS             := p_PA_STATUS;
   g_RETRO_BATCH_ID        := p_RETRO_BATCH_ID;
   g_DT_UPDATE_MODE        := p_DT_UPDATE_MODE;
   g_PERIOD_START_DATE     := p_PERIOD_START_DATE;
   g_CALL_ADJUST_ABS       := p_CALL_ADJUST_ABS;
   g_STATE_NAME            :=p_STATE_NAME;
   g_COUNTY_NAME           :=p_COUNTY_NAME;
   g_CITY_NAME             :=p_CITY_NAME;
   g_ZIP_CODE              :=p_ZIP_CODE;
-- g_GROUP_ID              := p_GROUP_ID;




   -- Bug 7359347
   -- Setting session date to the global variable
   IF hxt_tim_col_util.g_session_date.EXISTS(USERENV('SESSIONID'))
   THEN
      g_sum_session_date := hxt_tim_col_util.g_session_date(USERENV('SESSIONID'));
   ELSE
      l_error_code := hxt_tim_col_util.get_session_date(g_sum_session_date);
   END IF;

   l_error_code := 0 ;




-- generate_details returns 0 if no errors encountered,-1 to signal the
-- Timecard that a summary status was changed from E,2 for errors that stopped
-- processing on current record,3 for errors that stopped processing on related
-- summaries and -2 for warning that changed records prevented complete rebuild

-- g_start_day_of_week := 'MON';
-- hard coded for now  must match hxt_time_details start day

--
-- Get the Recurring Period assigned to the person. The recurring period is
-- setup as a Preference - Self-Service -> Otl Rules Evaluation -> Overtime
-- Recurring Period.
-- Context of the Preference is TC_W_RULES_EVALUATION
-- Segment is attribute 3   OT_RECURRING_PERIOD
--
   if g_debug then
   	   hr_utility.set_location('hxt_time_summary.generate_details',20);
   end if;
   otl_recurring_period := hxc_preference_evaluation.resource_preferences
                          (g_person_id
                          ,'TC_W_RULES_EVALUATION'
                          ,3
                          ,p_date_worked);
   if g_debug then
	   hr_utility.set_location('hxt_time_summary.generate_details',30);
	   hr_utility.trace('otl_recurring_period :'||otl_recurring_period);
   end if;
--
-- Now calculate the start day as per the otl recurring period
--
   if g_debug then
   	   hr_utility.set_location('hxt_time_summary.generate_details',40);
   end if;
   IF otl_recurring_period is NOT NULL THEN
   --
   -- Get the period start_date, period_type for the recurring_period
   --
      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.generate_details',50);
      end if;
      SELECT start_date,period_type
      INTO   l_period_start_date,l_period_type
      FROM   hxc_recurring_periods
      WHERE  recurring_period_id = otl_recurring_period;

      if g_debug then
	      hr_utility.trace('l_period_start_date :'
			      || to_char(l_period_start_date,'DD-MON-YYYY HH24:MI:SS'));
	      hr_utility.trace('l_period_type :'|| l_period_type);
	      hr_utility.trace('g_date_worked :'
			      || to_char(g_date_worked,'DD-MON-YYYY HH24:MI:SS'));
              hr_utility.set_location('hxt_time_summary.generate_details',60);
      end if;
      hxc_period_evaluation.period_start_stop
         (g_date_worked
         ,l_period_start_date
         ,l_period_start
         ,l_period_end
         ,l_period_type);

      if g_debug then
	      hr_utility.set_location('hxt_time_summary.generate_details',70);
	      hr_utility.trace('l_period_start :'
			      || to_char(l_period_start,'DD-MON-YYYY HH24:MI:SS'));
	      hr_utility.trace('l_period_end :'
			      || to_char(l_period_end,'DD-MON-YYYY HH24:MI:SS'));
      end if;
      g_start_day_of_week := TO_CHAR(l_period_start,'DAY');
      if g_debug then
	      hr_utility.trace('g_start_day_of_week :'|| g_start_day_of_week);
	      hr_utility.set_location('hxt_time_summary.generate_details',80);
      end if;
   ELSE
      if g_debug then
	      hr_utility.set_location('hxt_time_summary.generate_details',90);
	      hr_utility.trace('p_PERIOD_START_DATE :'
			      || to_char(p_PERIOD_START_DATE,'DD-MON-YYYY HH24:MI:SS'));
      end if;
      g_start_day_of_week := TO_CHAR(p_PERIOD_START_DATE,'DAY');
      if g_debug then
      	      hr_utility.trace('g_start_day_of_week :'|| g_start_day_of_week);
      end if;
      l_location := p_location||':GD';
      g_hol_location := l_location;

   END IF;

   if g_debug then
   	   hr_utility.set_location('hxt_time_summary.generate_details',100);
   end if;

   -- Bug 7359347
   -- Execute valid data and capture that.
   l_vd_retcode := valid_data(l_location);

   IF l_vd_retcode NOT IN (0,1) THEN
   -- check for time in/out and hour values
      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.generate_details',110);
      end if;
      RETURN(2);
   ELSIF l_vd_retcode = 1 THEN
      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.generate_details',120);
      end if;
      RETURN(11);
   END IF;

   IF g_element_type_id is not null THEN
      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.generate_details',130);
      end if;
   -- Determine if earning is in assigned INCLUDE earning group
      g_include_yn := Get_Include(l_location
                                 ,g_egt_id
                                 ,g_element_type_id
                                 ,g_date_worked);

       IF g_include_yn = 'E' THEN
          if g_debug then
          	  hr_utility.set_location('hxt_time_summary.generate_details',140);
          end if;
          RETURN 2;

       END IF;
    ELSIF NVL(FND_PROFILE.VALUE('HXT_HOLIDAY_EXPLOSION'),'EX') <> 'EX'
    THEN
       NULL;
      check_holiday_rule_behavior;
       -- Do caching the values for holiday.
       -- Set flag

   END IF; --element_type_id is not null

   IF l_error_code < 2 THEN
      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.generate_details',150);
      end if;

     /* Bug: 4489952 changes starts here */

      IF check_non_explosion_entry (g_element_type_id, g_date_worked) THEN
         IF g_debug then
            hr_utility.set_location('hxt_time_summary.generate_details',151);
         END IF;

	 insert_non_explodable_hrs;

      ELSE /* check_non_explosion_entry = FALSE */

        IF g_debug then
           hr_utility.set_location('hxt_time_summary.generate_details',155);
        END IF;

        rebuild_details( l_location, l_rebuild_code);
      END IF;

      /* Bug: 4489952 changes ends here */

   END IF;

   IF l_rebuild_code <> 0 THEN
      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.generate_details',160);
      end if;
      RETURN l_rebuild_code;
   ELSE
      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.generate_details',170);
      end if;
      -- Bug 8600894
      IF NVL(FND_PROFILE.VALUE('HXT_HOLIDAY_EXPLOSION'),'EX') <> 'EX'
      THEN
          l_error_code := adjust_holiday_rule;
      END IF;
      RETURN l_error_code;
   END IF;

EXCEPTION

   WHEN OTHERS THEN
      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.generate_details',180);
      end if;
      FND_MESSAGE.SET_NAME('HXT','HXT_39269_ORACLE_ERROR');
      RETURN call_hxthxc_gen_error('HXT','HXT_39269_ORACLE_ERROR',NULL,l_location, '', sqlerrm);
      --2278400 RETURN call_gen_error(l_location, '', sqlerrm);
END; -- generate_details

PROCEDURE time_in_dates(ln_start      in      number
                       ,ln_stop       in      number
                       ,ln_carryover  in      number
                       ,time_in           out nocopy date
                       ,time_out          out nocopy date
                       ,carryover_time    out nocopy date
                       ,l_date_worked in      date)
 IS

BEGIN
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
	  hr_utility.set_location('hxt_time_summary.time_in_dates',10);
	  hr_utility.trace('ln_start      :'||ln_start);
	  hr_utility.trace('ln_stop       :'||ln_stop);
	  hr_utility.trace('ln_carryover  :'||ln_carryover);
  end if;
  time_in := to_date((to_char(l_date_worked,'DDMMYYYY')
                        ||lpad(to_char(ln_start),4,'0')),'DDMMYYYYHH24MI');
  if g_debug then
	  hr_utility.trace('time_in :'
				|| to_char(time_in,'DD-MON-YYYY HH24:MI:SS'));
  end if;
  IF ln_start < ln_stop  OR
    (ln_start = 0  AND
     ln_stop  = 0) THEN
     if g_debug then
     	     hr_utility.set_location('hxt_time_summary.time_in_dates',20);
     end if;
     time_out := to_date((to_char(l_date_worked,'DDMMYYYY')
                        ||lpad(to_char(ln_stop),4,'0')),'DDMMYYYYHH24MI');
     if g_debug then
	     hr_utility.trace('time_out :'
				|| to_char(time_out,'DD-MON-YYYY HH24:MI:SS'));
     end if;
  ELSE --IF ln_start >= ln_stop
     if g_debug then
     	     hr_utility.set_location('hxt_time_summary.time_in_dates',30);
     end if;
     time_out := to_date((to_char(l_date_worked + 1,'DDMMYYYY')
                        ||lpad(to_char(ln_stop),4,'0')),'DDMMYYYYHH24MI');
     if g_debug then
	     hr_utility.trace('time_out :'
				|| to_char(time_out,'DD-MON-YYYY HH24:MI:SS'));
     end if;
  END IF;

  IF ln_carryover is NOT NULL THEN
     if g_debug then
     	     hr_utility.set_location('hxt_time_summary.time_in_dates',35);
     end if;
     IF ln_start < ln_carryover THEN
        if g_debug then
        	hr_utility.set_location('hxt_time_summary.time_in_dates',40);
        end if;
        carryover_time := to_date((to_char(l_date_worked,'DDMMYYYY')
                        ||lpad(to_char(ln_carryover),4,'0')),'DDMMYYYYHH24MI');

        if g_debug then
		hr_utility.trace('carryover_time :'
				|| to_char(carryover_time,'DD-MON-YYYY HH24:MI:SS'));
        end if;
     ELSE --IF ln_start >= ln_carryover
        if g_debug then
        	hr_utility.set_location('hxt_time_summary.time_in_dates',50);
        end if;
        carryover_time := to_date((to_char(l_date_worked + 1,'DDMMYYYY')
                        ||lpad(to_char(ln_carryover),4,'0')),'DDMMYYYYHH24MI');

        if g_debug then
		hr_utility.trace('carryover_time :'
				|| to_char(carryover_time,'DD-MON-YYYY HH24:MI:SS'));
	end if;
     END IF;

  END IF;

END;

FUNCTION call_gen_error
          (p_location          IN varchar2
          ,p_error_text        IN VARCHAR2
          ,p_oracle_error_text IN VARCHAR2 default NULL) RETURN NUMBER IS

   dummy NUMBER;

-- calls error processing procedure

BEGIN

  if g_debug then
  	  hr_utility.set_location('hxt_time_summary.call_gen_error',10);
  end if;
--Checking of the hours worked table for the current id is done so that
--validation is not done on a record being deleted.

   hxt_util.gen_error(g_tim_id
                     ,g_id
                     ,NULL
                     ,p_error_text
                     ,p_location
                     ,p_oracle_error_text
                     ,g_EFFECTIVE_START_DATE
                     ,g_EFFECTIVE_END_DATE
                     ,'ERR');

   if g_debug then
   	   hr_utility.set_location('hxt_time_summary.call_gen_error',20);
   end if;
   RETURN 2;

EXCEPTION

   WHEN NO_DATA_FOUND THEN
      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.call_gen_error',30);
      end if;
      RETURN 0;

   WHEN OTHERS THEN
      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.call_gen_error',40);
      end if;
      hxt_util.gen_error(g_tim_id
                        ,g_id
                        ,NULL
                        ,p_error_text
                        ,p_location
                        ,p_oracle_error_text
                        ,g_EFFECTIVE_START_DATE
                        ,g_EFFECTIVE_END_DATE
                        ,'ERR');
      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.call_gen_error',50);
      end if;
      RETURN 2;
END;

FUNCTION call_hxthxc_gen_error
         ( p_app_short_name    IN VARCHAR2
          ,p_msg_name	       IN VARCHAR2
	  ,p_msg_token	       IN VARCHAR2
	  ,p_location          IN varchar2
          ,p_error_text        IN VARCHAR2
          ,p_oracle_error_text IN VARCHAR2 default NULL) RETURN NUMBER IS

   dummy NUMBER;

-- calls error processing procedure

BEGIN

  if g_debug then
  	  hr_utility.set_location('hxt_time_summary.call_gen_error',10);
  end if;
--Checking of the hours worked table for the current id is done so that
--validation is not done on a record being deleted.

   hxt_util.gen_error(g_tim_id
                     ,g_id
                     ,NULL
                     ,p_error_text
                     ,p_location
                     ,p_oracle_error_text
                     ,g_EFFECTIVE_START_DATE
                     ,g_EFFECTIVE_END_DATE
                     ,'ERR');

   hxc_time_entry_rules_utils_pkg.add_error_to_table (
                     p_message_table=> hxt_hxc_retrieval_process.g_otm_messages,
                     p_message_name=> p_msg_name,
                     p_message_token=> NULL ,
                     p_message_level=> 'ERROR',
                     p_message_field=> NULL,
                     p_application_short_name=> p_app_short_name,
                     p_timecard_bb_id=> null,
                     p_time_attribute_id=> NULL,
                     p_timecard_bb_ovn=> NULL,
                     p_time_attribute_ovn=> NULL
                  );
   if g_debug then
   	   hr_utility.trace('Adding to g_otm_messages'||p_msg_name);
   	   hr_utility.set_location('hxt_time_summary.call_gen_error',20);
   end if;
   RETURN 2;

EXCEPTION

   WHEN NO_DATA_FOUND THEN
      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.call_gen_error',30);
      end if;
      RETURN 0;

   WHEN OTHERS THEN
      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.call_gen_error',40);
      end if;
      hxt_util.gen_error(g_tim_id
                        ,g_id
                        ,NULL
                        ,p_error_text
                        ,p_location
                        ,p_oracle_error_text
                        ,g_EFFECTIVE_START_DATE
                        ,g_EFFECTIVE_END_DATE
                        ,'ERR');

   hxc_time_entry_rules_utils_pkg.add_error_to_table (
                     p_message_table=> hxt_hxc_retrieval_process.g_otm_messages,
                     p_message_name=> p_msg_name,
                     p_message_token=> substr(p_msg_token,1,240),
                     p_message_level=> 'ERROR',
                     p_message_field=> NULL,
                     p_application_short_name=> p_app_short_name,
                     p_timecard_bb_id=> null,
                     p_time_attribute_id=> NULL,
                     p_timecard_bb_ovn=> NULL,
                     p_time_attribute_ovn=> NULL
                  );

      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.call_gen_error',50);
      end if;
      RETURN 2;
END;

FUNCTION valid_data(p_location IN VARCHAR2) RETURN NUMBER IS

--  Checks in and out times to ensure that if one is present both are
--  If no times are there hours must be there

   l_cat         VARCHAR2(10);
   error_code    NUMBER        := 0;
   location      VARCHAR2(120) := p_location||':VD';
   l_non_exp_elem_count   NUMBER; /* Bug: 4489952 */

BEGIN



   -- Bug 7359347
   -- set session date.
   IF g_sum_session_date IS NULL
   THEN
      error_code := hxt_tim_col_util.get_session_date(g_sum_session_date);
   END IF;

   if g_debug then
     	   hr_utility.set_location('hxt_time_summary.valid_data',10);
   end if;
   IF g_time_in IS NULL AND g_time_out IS NOT NULL THEN

       if g_debug then
       	       hr_utility.set_location('hxt_time_summary.valid_data',20);
       end if;
       FND_MESSAGE.SET_NAME('HXT','HXT_39327_TIME_IN_OT_REQ');
       RETURN call_hxthxc_gen_error('HXT','HXT_39327_TIME_IN_OT_REQ',NULL,location, '');

   END IF;

   IF g_time_out IS NULL AND g_time_in IS NOT NULL THEN

       if g_debug then
       	       hr_utility.set_location('hxt_time_summary.valid_data',30);
       end if;
       FND_MESSAGE.SET_NAME('HXT','HXT_39327_TIME_IN_OT_REQ');
       RETURN call_hxthxc_gen_error('HXT','HXT_39327_TIME_IN_OT_REQ',NULL,location, '');

   END IF;

   IF g_time_in IS NULL AND g_hours IS NULL THEN

       if g_debug then
       	       hr_utility.set_location('hxt_time_summary.valid_data',40);
       end if;
       FND_MESSAGE.SET_NAME('HXT','HXT_39328_TIME_OR_TOT_HRS_REQ');
       RETURN call_hxthxc_gen_error('HXT','HXT_39328_TIME_OR_TOT_HRS_REQ',NULL,location, '');

   END IF;

   IF g_element_type_id IS NOT NULL THEN

       if g_debug then
       	       hr_utility.set_location('hxt_time_summary.valid_data',50);
       end if;
       l_cat := hxt_util.element_cat(g_element_type_id
                                    ,g_date_worked);

   END IF;

-- Hours or times must be consistent across all summary records in a day

   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.valid_data',60);
      end if;

      /* Bug: 4489952 changes starts here */

      SELECT  count(1)
      INTO    l_non_exp_elem_count
      FROM    hxt_add_elem_info_f hei
      WHERE   hei.element_type_id = g_element_type_id
      AND     g_date_worked BETWEEN hei.effective_start_date
                                AND hei.effective_end_date
      AND     NVL(hei.exclude_from_explosion, 'N') = 'Y';

      IF (g_hours<>0) and l_non_exp_elem_count = 0 THEN
        IF g_TIME_IN IS NULL THEN
          SELECT '1'
          INTO   error_code
          FROM   SYS.DUAL
          WHERE  EXISTS (SELECT hrw.id
                         FROM   hxt_sum_hours_worked hrw, hxt_add_elem_info_f hei
                         WHERE  hrw.tim_id = g_TIM_ID
                         AND    hrw.date_worked = g_DATE_WORKED
                         AND    hrw.time_in IS NOT NULL
                         AND    hrw.element_type_id = hei.element_type_id
                         AND    hrw.element_type_id is not null
			 AND    g_date_worked BETWEEN hei.effective_start_date
                                                  AND hei.effective_end_date
                         AND    NVL(hei.exclude_from_explosion, 'N') <> 'Y'
                         UNION
                         SELECT hrw.id
                         FROM   hxt_sum_hours_worked hrw
                         WHERE  hrw.tim_id = g_TIM_ID
                         AND    hrw.date_worked = g_DATE_WORKED
                         AND    hrw.time_in IS NOT NULL
                         AND    hrw.element_type_id is null
                        );
        ELSE  -- g_TIME_IN IS NOT NULL
          SELECT '1'
          INTO   error_code
          FROM   SYS.DUAL
          WHERE  EXISTS (SELECT hrw.id
                         FROM   hxt_sum_hours_worked hrw, hxt_add_elem_info_f hei
                         WHERE  hrw.tim_id = g_TIM_ID
                         AND    hrw.date_worked = g_DATE_WORKED
                         AND    hrw.time_in IS NULL
                         AND    hrw.hours<>0
                         AND    hrw.element_type_id = hei.element_type_id
                         AND    hrw.element_type_id is not null
			 AND    g_date_worked BETWEEN hei.effective_start_date
                                                  AND hei.effective_end_date
                         AND    NVL(hei.exclude_from_explosion, 'N') <> 'Y'
                         UNION
                         SELECT hrw.id
                         FROM   hxt_sum_hours_worked hrw
                         WHERE  hrw.tim_id = g_TIM_ID
                         AND    hrw.date_worked = g_DATE_WORKED
                         AND    hrw.time_in IS NULL
                         AND    hrw.hours<>0
                         AND    hrw.element_type_id is null
                        );
        END IF;
      END IF;

      /* Bug: 4489952 changes ends here */

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         if g_debug then
         	 hr_utility.set_location('hxt_time_summary.valid_data',90);
         end if;
         NULL;
   END;

   IF error_code = 1 THEN
      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.valid_data',100);
      end if;
      FND_MESSAGE.SET_NAME('HXT','HXT_39329_INC_TIM_HR_ENTRIES');

   END IF;

   RETURN error_code;

EXCEPTION

  WHEN OTHERS THEN
      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.valid_data',110);
      end if;
      FND_MESSAGE.SET_NAME('HXT','HXT_39269_ORACLE_ERROR');
      RETURN  call_hxthxc_gen_error('HXT','HXT_39269_ORACLE_ERROR',NULL,location, '', sqlerrm);

END;  -- valid_data
-------------------------------------------------------------------------------
PROCEDURE Delete_Details(p_location   IN     VARCHAR2
                        ,p_error_code IN OUT NOCOPY NUMBER) IS
--Begins by deleting details for current summary record
  CURSOR completed_time_card IS
     SELECT 'Y'
     FROM hxt_det_hours_worked_f
     WHERE  tim_id=g_tim_id
       AND  pay_status = 'C';

  l_completed_time_card   VARCHAR2(1) := 'N';
  l_location              hxt_errors.location%TYPE;

BEGIN

  if g_debug then
  	  hr_utility.set_location('hxt_time_summary.Delete_Details',10);
  end if;
  p_error_code := 0;

--Add local code to location variable
  l_location := p_location||':DD';

  IF nvl(g_DT_UPDATE_MODE, 'CORRECTION') = 'CORRECTION' THEN
       if g_debug then
       	       hr_utility.set_location('hxt_time_summary.Delete_Details',20);
       end if;
       DELETE from hxt_det_hours_worked_f
       WHERE  parent_id = g_id;

       DELETE from hxt_errors_f where --SPR C153
       hrw_id = g_id; --SPR C153
  ELSE
       if g_debug then
       	       hr_utility.set_location('hxt_time_summary.Delete_Details',30);
       end if;
    -- Delete details for this entry and all others that follow
    -- on this day for this person that are non-absence or are in
    -- the person's include group


       -- Bug 7359347
       -- Changed the reference to hxt_det_hours_worked to hxt_det_hours_worked_f
       /*
       UPDATE hxt_det_hours_worked_f
       SET    effective_end_date = g_effective_start_date - 1
       WHERE  rowid in (
              SELECT rowid
              FROM   hxt_det_hours_worked
              WHERE  parent_id = g_id);
       */

       UPDATE hxt_det_hours_worked_f
       SET    effective_end_date = g_effective_start_date - 1
       WHERE  parent_id = g_id
         AND  g_sum_session_date BETWEEN effective_start_date
                                     AND effective_end_date ;


       UPDATE hxt_errors_f
       SET    effective_end_date = g_effective_start_date - 1
       WHERE  rowid in (
              SELECT rowid
              FROM   hxt_errors
              WHERE  hrw_id = g_id);

  END IF;--absence and not in include group or not

EXCEPTION

  WHEN OTHERS THEN
    if g_debug then
    	    hr_utility.set_location('hxt_time_summary.Delete_Details',40);
    end if;
 -- Write to error table - do not generate details
    FND_MESSAGE.SET_NAME('HXT','HXT_39269_ORACLE_ERROR');             -- HXT11
    p_error_code := call_hxthxc_gen_error('HXT','HXT_39269_ORACLE_ERROR',NULL,l_location, '', sqlerrm);          -- HXT11
    --p_error_code := call_gen_error(l_location, '', sqlerrm);          -- HXT11
END; -- delete details

-------------------------------------------------------------------------------
PROCEDURE shift_adjust_times(p_shift_adjusted_time_in  OUT NOCOPY DATE
                            ,p_shift_adjusted_time_out OUT NOCOPY DATE) IS

BEGIN

   if g_debug then
   	   hr_utility.set_location('hxt_time_summary.shift_adjust_times',10);
   end if;
   p_shift_adjusted_time_in := g_TIME_IN;
   p_shift_adjusted_time_out := g_TIME_OUT;

   IF (g_EARLY_START IS NOT NULL AND g_STANDARD_START IS NOT NULL) THEN
      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.shift_adjust_times',20);
      end if;
      IF g_EARLY_START > g_STANDARD_START  THEN  --  spans midnight
         if g_debug then
         	 hr_utility.set_location('hxt_time_summary.shift_adjust_times',30);
         end if;
         IF to_number(to_char(g_TIME_IN, 'HH24MI')) < g_STANDARD_START THEN
            if g_debug then
            	    hr_utility.set_location('hxt_time_summary.shift_adjust_times',40);
            end if;
            p_shift_adjusted_time_in := g_TIME_IN + ((hxt_util.time_to_hours(g_STANDARD_START)
                    - hxt_util.time_to_hours(to_number(to_char(g_TIME_IN, 'HH24MI')))) / 24);
         ELSIF to_number(to_char(g_TIME_IN, 'HH24MI')) > g_EARLY_START THEN
            if g_debug then
            	    hr_utility.set_location('hxt_time_summary.shift_adjust_times',50);
            end if;
            p_shift_adjusted_time_in := g_TIME_IN + ((hxt_util.time_to_hours(g_STANDARD_START)
                    + (hxt_util.time_to_hours(2400) -
		hxt_util.time_to_hours(to_number(to_char(g_TIME_IN, 'HH24MI'))))) / 24);
         END IF;
      ELSE  --  no midnight span
         if g_debug then
         	 hr_utility.set_location('hxt_time_summary.shift_adjust_times',60);
         end if;
         IF to_number(to_char(g_TIME_IN, 'HH24MI')) BETWEEN g_EARLY_START
                   AND g_STANDARD_START THEN
            if g_debug then
            	    hr_utility.set_location('hxt_time_summary.shift_adjust_times',70);
            end if;
            p_shift_adjusted_time_in := g_TIME_IN + ((hxt_util.time_to_hours(g_STANDARD_START)
                    - hxt_util.time_to_hours(to_number(to_char(g_TIME_IN, 'HH24MI')))) / 24);
         END IF;
      END IF;
   END IF;

   IF (g_LATE_STOP IS NOT NULL AND g_STANDARD_STOP IS NOT NULL) THEN
      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.shift_adjust_times',80);
      end if;
      IF g_LATE_STOP < g_STANDARD_STOP  THEN  --  spans midnight
         if g_debug then
         	 hr_utility.set_location('hxt_time_summary.shift_adjust_times',90);
         end if;
         IF to_number(to_char(g_TIME_OUT, 'HH24MI')) > g_STANDARD_STOP THEN
            if g_debug then
            	    hr_utility.set_location('hxt_time_summary.shift_adjust_times',100);
            end if;
            p_shift_adjusted_time_out := g_TIME_OUT -
		(( hxt_util.time_to_hours(to_number(to_char(g_TIME_OUT, 'HH24MI')))
                    - (hxt_util.time_to_hours(g_STANDARD_STOP))) / 24);
         ELSIF to_number(to_char(g_TIME_OUT, 'HH24MI')) < g_LATE_STOP THEN
            if g_debug then
            	    hr_utility.set_location('hxt_time_summary.shift_adjust_times',110);
            end if;
            p_shift_adjusted_time_out := g_TIME_OUT -
		(( hxt_util.time_to_hours(to_number(to_char(g_TIME_OUT, 'HH24MI')))
                + (hxt_util.time_to_hours(2400) - (hxt_util.time_to_hours(g_STANDARD_STOP)))) / 24);
         END IF;
      ELSE  --  no midnight span
         if g_debug then
         	 hr_utility.set_location('hxt_time_summary.shift_adjust_times',120);
         end if;
         IF to_number(to_char(g_TIME_OUT, 'HH24MI')) BETWEEN g_STANDARD_STOP
               AND g_LATE_STOP THEN
            if g_debug then
            	    hr_utility.set_location('hxt_time_summary.shift_adjust_times',130);
            end if;
            p_shift_adjusted_time_out := g_TIME_OUT -
		(( hxt_util.time_to_hours(to_number(to_char(g_TIME_OUT, 'HH24MI')))
                    - (hxt_util.time_to_hours(g_STANDARD_STOP))) / 24);
         END IF;
      END IF;
   END IF;

END;  --  shift adjust times
-------------------------------------------------------------------------------
PROCEDURE Rebuild_Details(p_location   IN     VARCHAR2
                         ,p_error_code IN OUT NOCOPY NUMBER) IS

--Rebuilds details for a person for this summary record.

--Define local variables
  l_error_code                  NUMBER  :=  0;
  l_location                    hxt_errors.location%TYPE;
  l_shift_adjusted_time_in      DATE;
  l_shift_adjusted_time_out     DATE;
  original_record_id            NUMBER  := g_ID;
  change_warning_flag           NUMBER  := 0;
  l_retcode                     NUMBER;  -- BUG688072
  l_hdy_id                      NUMBER;  -- BUG688072
  l_hours                       NUMBER;  -- BUG688072

BEGIN

  if g_debug then
  	  hr_utility.set_location('hxt_time_summary.Rebuild_Details',10);
  end if;
--Add local code to location variable
  l_location := p_location||':RB';

--Currently, earning type is null in the summary record unless it is of type
--'ABSENCE'.

--Check if absence and not in include group
  HXT_UTIL.Check_For_Holiday(g_date_worked
                            ,g_hol_id
                            ,l_hdy_id
                            ,l_hours
                            ,l_retcode);
  if g_debug then
  	  hr_utility.set_location('hxt_time_summary.Rebuild_Details',20);
  end if;
  IF l_retcode = 1 THEN
     if g_debug then
     	     hr_utility.set_location('hxt_time_summary.Rebuild_Details',30);
     end if;
     g_hol_yn := 'Y';
  ELSE
     if g_debug then
     	     hr_utility.set_location('hxt_time_summary.Rebuild_Details',40);
     end if;
     g_hol_yn := 'N';
  END IF;

     l_error_code := Gen_Details(l_location, g_time_in, g_time_out);

  IF l_error_code <> 0 THEN
     if g_debug then
     	     hr_utility.set_location('hxt_time_summary.Rebuild_Details',50);
     end if;
     p_error_code := l_error_code;
  ELSE
     if g_debug then
     	     hr_utility.set_location('hxt_time_summary.Rebuild_Details',60);
     end if;
     p_error_code := change_warning_flag;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    if g_debug then
    	    hr_utility.set_location('hxt_time_summary.Rebuild_Details',70);
    end if;
    FND_MESSAGE.SET_NAME('HXT','HXT_39269_ORACLE_ERROR');             -- HXT11
    p_error_code := call_hxthxc_gen_error('HXT','HXT_39269_ORACLE_ERROR',NULL,l_location, '', sqlerrm);          -- HXT11
    --2278400 p_error_code := call_gen_error(l_location, '', sqlerrm);          -- HXT11
END;  -- rebuild details
-------------------------------------------------------------------------------
FUNCTION gen_details
        (p_location                IN VARCHAR2
        ,p_shift_adjusted_time_in  IN DATE
        ,p_shift_adjusted_time_out IN DATE)
         RETURN NUMBER IS

-- g_variables are global variables set when package is entered and should not
-- be changed
-- p_variables are parameters
-- all other variables are locals

   location            VARCHAR2(120) := p_location||':GDD';
   segment_start_time  DATE;    --  start time of segment  - includes date
   segment_stop_time   DATE;    --  stop time of segment   - includes date
   hours_worked        NUMBER;  --  # of hours in segment
   return_code         NUMBER := 0;
   sd_rule_earning     NUMBER;  --  element type of sd rule found
   sd_rule_carryover   NUMBER;  --  carryover time of sd rule found
   sd_rule_start       NUMBER;  --  start of sd rule found
   loop_count          NUMBER := 0;--count loop passes to break if necessary

/*CURSOR Get_shift_stop_time (p_assignment_id  NUMBER
                           ,p_date_worked    DATE  ) IS
      SELECT  hs.standard_stop
      FROM    hxt_shifts hs
             ,hxt_work_shifts hws
             ,hxt_per_aei_ddf_v aeiv
             ,hxt_rotation_schedules rts
      WHERE   aeiv.assignment_id = p_ASSIGNMENT_ID
      AND     p_DATE_WORKED between aeiv.effective_start_date
                                and aeiv.effective_end_date
      AND     rts.rtp_id = aeiv.hxt_rotation_plan
      AND     rts.start_date = (SELECT MAX(start_date)
                                FROM   hxt_rotation_schedules
                                WHERE  rtp_id = rts.rtp_id
                                AND    start_date <= p_DATE_WORKED
                                )
      AND     hws.tws_id     = rts.tws_id
      AND     hws.week_day   = to_char(p_DATE_WORKED,'DY')
      AND     hws.sht_id     = hs.id;
*/
      ln_standard_start  hxt_shifts.standard_start%TYPE;
      ln_standard_stop   hxt_shifts.standard_stop%TYPE;
      wp_start_time      DATE;
      wp_stop_time       DATE;
      ld_carryover2      DATE;

CURSOR Get_Work_plan IS
      SELECT  hs.standard_start , hs.standard_stop
      FROM  hxt_per_aei_ddf_v aeiv
           ,hxt_rotation_schedules rts
           ,hxt_work_shifts hws
	       ,hxt_shifts hs
      WHERE   aeiv.assignment_id = g_ASSIGNMENT_ID
      AND     g_DATE_WORKED between aeiv.effective_start_date
                                and aeiv.effective_end_date
      AND     rts.rtp_id = aeiv.hxt_rotation_plan
      AND     rts.start_date = (SELECT MAX(start_date)
                                FROM   hxt_rotation_schedules
                                WHERE  rtp_id = rts.rtp_id
                                AND    start_date <= g_DATE_WORKED
                                )
      AND     hws.tws_id     = rts.tws_id
      AND     hws.week_day   = hxt_util.get_week_day(g_DATE_WORKED)
      AND     hws.sht_id     = hs.id;

   CURSOR Get_sd_rules IS
    SELECT sdr.start_time
          ,sdr.stop_time
       -- ,sdr.element_type_id
          ,sdr.carryover_time
    FROM  hxt_shift_diff_rules sdr
    WHERE sdr.sdp_id = g_sdp_id
    AND   g_DATE_WORKED BETWEEN
          sdr.effective_start_date AND sdr.effective_end_date;

   ln_sd_start          hxt_shift_diff_rules.start_time%TYPE;
   ln_sd_stop           hxt_shift_diff_rules.stop_time%TYPE;
   ln_sd_carryover      hxt_shift_diff_rules.carryover_time%TYPE;
   sd_start_time        DATE;
   sd_stop_time         DATE;
   sd_carryover_time    DATE;
   sd_date_worked       DATE;

   wplan_date_worked    DATE;

   segment_start        number;
   segment_stop         number;
   chunk_start          date;
   chunk_stop           date;
   chunk_start_date     date;
   chunk_stop_date      date;
   p_sdp_earning_type   number;
   p_sdovr_earning_type number;

   l_next_index         BINARY_INTEGER := 0;
   chunk_count          NUMBER := 1;

-----------------Gen Details local functions and procedures---------------------

----------------- Populate PL/SQL Table ---------------------------------------
PROCEDURE populate_plsql_table (p_value in date)
IS
 lv_insert_flag VARCHAR2(1) := 'Y';
 ln_next_index  NUMBER;

BEGIN
    if segment_chunks.count > 0 then
       for i in segment_chunks.first .. segment_chunks.last loop
           if p_value = segment_chunks(i) then
              lv_insert_flag := 'N';
              exit;
           end if;
       end loop;
    end if;

    if lv_insert_flag = 'Y' then
       ln_next_index := segment_chunks.count + 1;
       segment_chunks(ln_next_index) := p_value;
    end if;

END populate_plsql_table;

/*
PROCEDURE time_in_dates(ln_start      in      number
                       ,ln_stop       in      number
                       ,ln_carryover  in      number
                       ,time_in           out nocopy date
                       ,time_out          out nocopy date
                       ,carryover_time    out nocopy date
                       ,l_date_worked in      date)
 IS

BEGIN
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
	  hr_utility.set_location('hxt_time_summary.time_in_dates',10);
	  hr_utility.trace('ln_start      :'||ln_start);
	  hr_utility.trace('ln_stop       :'||ln_stop);
	  hr_utility.trace('ln_carryover  :'||ln_carryover);
  end if;
  time_in := to_date((to_char(l_date_worked,'DDMMYYYY')
                        ||lpad(to_char(ln_start),4,'0')),'DDMMYYYYHH24MI');
  if g_debug then
	  hr_utility.trace('time_in :'
				|| to_char(time_in,'DD-MON-YYYY HH24:MI:SS'));
  end if;
  IF ln_start < ln_stop  OR
    (ln_start = 0  AND
     ln_stop  = 0) THEN
     if g_debug then
     	     hr_utility.set_location('hxt_time_summary.time_in_dates',20);
     end if;
     time_out := to_date((to_char(l_date_worked,'DDMMYYYY')
                        ||lpad(to_char(ln_stop),4,'0')),'DDMMYYYYHH24MI');
     if g_debug then
	     hr_utility.trace('time_out :'
				|| to_char(time_out,'DD-MON-YYYY HH24:MI:SS'));
     end if;
  ELSE --IF ln_start >= ln_stop
     if g_debug then
     	     hr_utility.set_location('hxt_time_summary.time_in_dates',30);
     end if;
     time_out := to_date((to_char(l_date_worked + 1,'DDMMYYYY')
                        ||lpad(to_char(ln_stop),4,'0')),'DDMMYYYYHH24MI');
     if g_debug then
	     hr_utility.trace('time_out :'
				|| to_char(time_out,'DD-MON-YYYY HH24:MI:SS'));
     end if;
  END IF;

  IF ln_carryover is NOT NULL THEN
     if g_debug then
     	     hr_utility.set_location('hxt_time_summary.time_in_dates',35);
     end if;
     IF ln_start < ln_carryover THEN
        if g_debug then
        	hr_utility.set_location('hxt_time_summary.time_in_dates',40);
        end if;
        carryover_time := to_date((to_char(l_date_worked,'DDMMYYYY')
                        ||lpad(to_char(ln_carryover),4,'0')),'DDMMYYYYHH24MI');

	if g_debug then
 		hr_utility.trace('carryover_time :'
				|| to_char(carryover_time,'DD-MON-YYYY HH24:MI:SS'));
	end if;
     ELSE --IF ln_start >= ln_carryover
        if g_debug then
        	hr_utility.set_location('hxt_time_summary.time_in_dates',50);
	end if;
        carryover_time := to_date((to_char(l_date_worked + 1,'DDMMYYYY')
                        ||lpad(to_char(ln_carryover),4,'0')),'DDMMYYYYHH24MI');

 	if g_debug then
		hr_utility.trace('carryover_time :'
				|| to_char(carryover_time,'DD-MON-YYYY HH24:MI:SS'));
	end if;
     END IF;

  END IF;

END;
*/

FUNCTION sort (segment_chunks in t_date, p_order in Varchar2)
RETURN t_date IS

sorted_chunks T_DATE;
v_temp date;

BEGIN

  if g_debug then
  	  hr_utility.set_location('hxt_time_summary.sort',10);
  end if;
  if segment_chunks.count > 0 then
     For i in segment_chunks.first .. segment_chunks.LAST
     Loop
      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.sort',20);
      end if;
      sorted_chunks(i):= segment_chunks(i);
     End loop;
  end if;

  if g_debug then
  	  hr_utility.trace('FYI');
  end if;
  if sorted_chunks.count <> 0 then
     if g_debug then
     	     hr_utility.set_location('hxt_time_summary.sort',30);
     end if;
     for l_cnt in sorted_chunks.first .. sorted_chunks.last loop
         if g_debug then
         	 hr_utility.trace('sorted_chunks is:'||to_char(sorted_chunks(l_cnt),'DD-MON-YYYY HH24:MI:SS'));
         end if;
     end loop;
  end if;
  if g_debug then
  	  hr_utility.trace('END FYI');
  end if;
  For i in sorted_chunks.First+1 .. sorted_chunks.LAST
   Loop
     if g_debug then
     	     hr_utility.set_location('hxt_time_summary.sort',40);
     end if;
     v_temp:= sorted_chunks(i);
     if g_debug then
     	     hr_utility.trace('v_temp :'||to_char(v_temp,'DD-MON-YYYY HH24:MI:SS'));
     end if;
     <<inner_loop>>
       if g_debug then
       	       hr_utility.set_location('hxt_time_summary.sort',50);
       end if;
       For j in REVERSE sorted_chunks.First .. (i-1)
          Loop
              if g_debug then
		      hr_utility.set_location('hxt_time_summary.sort',60);
		      hr_utility.trace('sorted_chunks(j) :'||to_char(sorted_chunks(j),'DD-MON-YYYY HH24:MI:SS'));
              end if;
              If sorted_chunks(j)   >= v_temp  then
                 if g_debug then
                 	 hr_utility.set_location('hxt_time_summary.sort',70);
                 end if;
                 sorted_chunks(j+1) := sorted_chunks(j);
                 sorted_chunks(j)   := v_temp;
              end if;
              if g_debug then
              	      hr_utility.set_location('hxt_time_summary.sort',80);
              end if;
           end loop inner_loop;
           if g_debug then
           	   hr_utility.set_location('hxt_time_summary.sort',90);
           end if;
   end loop;
  IF p_order ='ASC' then
     if g_debug then
     	     hr_utility.set_location('hxt_time_summary.sort',100);
     end if;
     RETURN sorted_chunks;
  END IF;
  if g_debug then
  	  hr_utility.set_location('hxt_time_summary.sort',110);
  end if;
END;

FUNCTION segment_earning  (segment_start      in      date
                          ,segment_stop       in      date
                          ,sdp_earning_type       out nocopy number
                          ,sdovr_earning_type     out nocopy number
                           )
 RETURN BOOLEAN IS

 Cursor sd_earning is
  select sdr.start_time
        ,sdr.stop_time
        ,sdr.carryover_time
        ,sdr.element_type_id
  from   hxt_shift_diff_rules sdr
  where  sdr.sdp_id = g_sdp_id
  and    g_date_worked between sdr.effective_start_date
                           and sdr.effective_end_date;

 sdp_start          hxt_shift_diff_rules.start_time%TYPE;
 sdp_stop           hxt_shift_diff_rules.stop_time%TYPE;
 sdp_carryover      hxt_shift_diff_rules.carryover_time%TYPE;
 sdp_earning        hxt_shift_diff_rules.element_type_id%TYPE;
 sdp_start_time     DATE;
 sdp_stop_time      DATE;
 sdp_carryover_time DATE;

 worked_time_in     DATE := p_shift_adjusted_time_in;
 worked_time_out    DATE := p_shift_adjusted_time_out;

 wp_start           NUMBER;
 wp_stop            NUMBER;
 ld_wp_start        DATE;
 ld_wp_stop         DATE;
 ld_carryover1      DATE;

 lv_date_worked     DATE;
 wp_date_worked     DATE;

 sdp_earning_found  VARCHAR2(1) := 'N';
 elig_for_sdovr     VARCHAR2(1) := 'N';
 elig_for_sdovr1    VARCHAR2(1) := 'N';
 elig_for_sdovr2    VARCHAR2(1) := 'N';
 elig_for_sdovr3    VARCHAR2(1) := 'N';

 l_proc             VARCHAR2(50) ;

---------------------------segment_earning local functions---------------------
FUNCTION check_eligibility(lv_time_in       in date
                          ,lv_time_out      in date
                          ,lv_segment_start in date
                          ,lv_segment_stop  in date)
RETURN BOOLEAN is

--This function is used to check whether employee actually worked for
--this chunk or not ,i.e., whether this chunk is between the time_in and
--time_out.
--The | in the comments shows where midnight falls.
--This function is also used to check whether this chunk falls outside the
--regular shift. If yes then pay override earning for this chunk.

BEGIN


 if g_debug then

 	 hr_utility.set_location('hxt_time_summary.check_eligibility',10);
 end if;

 IF (
    (lv_time_in <= lv_segment_start
     AND lv_segment_start <= lv_time_out
     AND lv_time_in <= lv_segment_stop
     AND lv_segment_stop <= lv_time_out)
  -- lv_time_in lv_segment_start lv_segment_stop lv_time_out |
 OR  (lv_segment_start < lv_time_in
     AND lv_segment_start < lv_time_out
     AND lv_segment_stop < lv_time_in
     AND lv_segment_stop < lv_time_out
     AND lv_time_in > lv_time_out)
  -- lv_time_in | lv_segment_start lv_segment_stop lv_time_out
 OR  (lv_time_in <= lv_segment_start
     AND lv_time_in < lv_segment_stop
     AND lv_time_in > lv_time_out )
  -- lv_time_in lv_segment_start lv_segment_stop |  lv_time_out
 OR (lv_time_in <= lv_segment_start
     AND lv_segment_stop <= lv_time_out
     AND lv_segment_start > lv_segment_stop
     AND lv_time_in > lv_segment_stop
     AND lv_time_in > lv_time_out)
  -- lv_time_in lv_segment_start | lv_segment_stop lv_time_out
    )
  THEN
    if g_debug then
    	    hr_utility.set_location('hxt_time_summary.check_eligibility',20);
    end if;
    RETURN TRUE;
  ELSE
    if g_debug then
    	    hr_utility.set_location('hxt_time_summary.check_eligibility',30);
    end if;
    RETURN FALSE;
  END IF;
  if g_debug then
  	  hr_utility.set_location('hxt_time_summary.check_eligibility',40);
  end if;
END;

----------------------------segment_earning main module-------------------------

BEGIN

 if g_debug then
	 l_proc := 'hxt_time_summary.segment_earning';
	 hr_utility.set_location(l_proc,10);

	-- hr_utility.trace('worked_time_in  :'||worked_time_in);
	-- hr_utility.trace('worked_time_out :'||worked_time_out);
	-- hr_utility.trace('segment_start   :'||segment_start);
	-- hr_utility.trace('segment_stop    :'||segment_stop);

	 hr_utility.trace('worked_time_in  :'
			  ||to_char(worked_time_in,'DD-MON-YYYY HH24:MI:SS'));
	 hr_utility.trace('worked_time_out :'
			  ||to_char(worked_time_out,'DD-MON-YYYY HH24:MI:SS'));
	 hr_utility.trace('segment_start   :'
			  ||to_char(segment_start,'DD-MON-YYYY HH24:MI:SS'));
	 hr_utility.trace('segment_stop    :'
			  ||to_char(segment_stop,'DD-MON-YYYY HH24:MI:SS'));
 end if;
--First check whether employee worked for this chunk or not ,i.e., whether
--this chunk is between the worked_time_in and worked_time_out.
--The | in the comments shows where midnight falls.

 IF check_eligibility(worked_time_in
                     ,worked_time_out
                     ,segment_start
                     ,segment_stop) THEN

    if g_debug then
    	    hr_utility.set_location(l_proc,20);
    end if;
 -- Check whether eligible for shift override
    if g_debug then
    	    hr_utility.set_location(l_proc,30);
    end if;
    open get_work_plan;
    fetch get_work_plan into wp_start,wp_stop;
    if g_debug then
	    hr_utility.trace('wp_start :'||wp_start);
	    hr_utility.trace('wp_stop  :'||wp_stop);
    end if;
    close get_work_plan;

    wp_date_worked := TRUNC(p_shift_adjusted_time_in - 1, 'DD');

    FOR i in 1 .. 3 LOOP

      if g_debug then
	      hr_utility.set_location(l_proc,40);
	      hr_utility.trace('wp_date_worked :'
				|| to_char(wp_date_worked,'DD-MON-YYYY HH24:MI:SS'));
      end if;
      time_in_dates(wp_start
                   ,wp_stop
                   ,null
                   ,ld_wp_start
                   ,ld_wp_stop
                   ,ld_carryover1
                   ,wp_date_worked);

      if g_debug then
	      hr_utility.set_location(l_proc,50);
	      hr_utility.trace('ld_wp_start :'
				|| to_char(ld_wp_start,'DD-MON-YYYY HH24:MI:SS'));
	      hr_utility.trace('ld_wp_stop  :'
				|| to_char(ld_wp_stop,'DD-MON-YYYY HH24:MI:SS'));
	      hr_utility.trace('ld_carryover1:'
				|| to_char(ld_carryover1,'DD-MON-YYYY HH24:MI:SS'));
      end if;
      IF g_sdovr_id is NOT NULL THEN

         if g_debug then
		 hr_utility.set_location(l_proc,60);

		 hr_utility.trace('segment_start :'
				||to_char(segment_start,'DD-MON-YYYY HH24:MI:SS'));
		 hr_utility.trace('segment_stop  :'
				||to_char(segment_stop,'DD-MON-YYYY HH24:MI:SS'));
         end if;
         IF check_eligibility(ld_wp_start
                             ,ld_wp_stop
                             ,segment_start
                             ,segment_stop) THEN
            if g_debug then
            	    hr_utility.set_location(l_proc,70);
            end if;
         -- the chunk falls within the regular shift.
         -- So , not eligible for shift override.
         -- sdovr_earning_type := null;
            elig_for_sdovr := 'N';
            if g_debug then
            	    hr_utility.trace('sdovr_earning_type :'||sdovr_earning_type);
            end if;
         ELSE
            if g_debug then
            	    hr_utility.set_location(l_proc,80);
            end if;
         -- sdovr_earning_type := g_sdovr_id;
            --if g_debug then
         	-- hr_utility.trace('sdovr_earning_type :'||sdovr_earning_type);
            --end if;
            elig_for_sdovr := 'Y';
         END IF;

         if g_debug then
         	 hr_utility.set_location(l_proc,90);
         end if;

         -- Check if eligible before midnight
         IF i = 1 THEN
            if g_debug then
            	    hr_utility.set_location(l_proc,100);
            end if;
            IF elig_for_sdovr = 'Y' THEN
               if g_debug then
               	       hr_utility.set_location(l_proc,110);
               end if;
               elig_for_sdovr1 := 'Y';
            END IF;
            if g_debug then
            	    hr_utility.set_location(l_proc,120);
            end if;
         END IF;

         -- Now Check if eligible on current day
         IF i = 2 THEN
            if g_debug then
            	    hr_utility.set_location(l_proc,130);
            end if;
            IF elig_for_sdovr = 'Y' THEN
               if g_debug then
               	       hr_utility.set_location(l_proc,140);
               end if;
               elig_for_sdovr2 := 'Y';
            END IF;
            if g_debug then
            	    hr_utility.set_location(l_proc,145);
            end if;
         END IF;

         -- Now Check if eligible after midnight
         IF i = 3 THEN
            if g_debug then
            	    hr_utility.set_location(l_proc,150);
            end if;
            IF elig_for_sdovr = 'Y' THEN
               if g_debug then
               	       hr_utility.set_location(l_proc,160);
               end if;
               elig_for_sdovr3 := 'Y';
            END IF;
            if g_debug then
            	    hr_utility.set_location(l_proc,170);
            end if;
         END IF;

         -- If eligible for both before,current day and after the midnight then
         -- pay the shift diff override
         IF elig_for_sdovr1= 'Y' and elig_for_sdovr2 = 'Y' and
            elig_for_sdovr3 = 'Y' THEN
            if g_debug then
            	    hr_utility.set_location(l_proc,180);
            end if;
            sdovr_earning_type := g_sdovr_id;
         ELSE
            if g_debug then
            	    hr_utility.set_location(l_proc,190);
            end if;
            sdovr_earning_type := null;
         END IF;

         if g_debug then
         	 hr_utility.set_location(l_proc,200);
         end if;
         wp_date_worked := TRUNC(wp_date_worked + 1, 'DD');

      END IF;

      if g_debug then
      	      hr_utility.trace('sdovr_earning_type :'|| sdovr_earning_type);
              hr_utility.set_location(l_proc,210);
      end if;
    END LOOP;

    if g_debug then
	    hr_utility.set_location(l_proc,215);
	    hr_utility.trace('sdovr_earning_type :'|| sdovr_earning_type);
	    hr_utility.trace('sdp_earning_type   :'|| sdp_earning_type);
    end if;
 -- BUG 2721493
 -- Now before proceeding to calculate the shift diff premium
 -- check that the employee is not eligible for any shift diff override.
 -- If eligible for a shift diff override then no need to evaluate the shift
 -- diff premiums since the shift diff Override overrides all the other
 -- premiums for this chunk.

    IF sdovr_earning_type IS NULL THEN

       if g_debug then
       	       hr_utility.set_location(l_proc,230);
       end if;
    -- Check whether eligible for shift diff premium
       open sd_earning;

       LOOP
         if g_debug then
         	 hr_utility.set_location(l_proc,240);
         end if;
         fetch sd_earning into sdp_start,sdp_stop,sdp_carryover,sdp_earning;

         Exit when sd_earning%NOTFOUND;

         if g_debug then
		 hr_utility.trace('sdp_start       :'||sdp_start);
		 hr_utility.trace('sdp_stop        :'||sdp_stop);
		 hr_utility.trace('sdp_carryover   :'||sdp_carryover);
		 hr_utility.trace('sdp_earning_type:'||sdp_earning_type);

		 hr_utility.trace('p_shift_adjusted_time_in :'
			 ||to_char(p_shift_adjusted_time_in,'DD-MON-YYYY HH24:MI:SS'));
		 hr_utility.trace('p_shift_adjusted_time_out:'
			 ||to_char(p_shift_adjusted_time_out,'DD-MON-YYYY HH24:MI:SS'));
         end if;
         lv_date_worked := TRUNC(p_shift_adjusted_time_in - 1, 'DD');

      -- Loop through for the day before, the current day and the day after
         FOR i in 1 .. 3 LOOP
             if g_debug then
		     hr_utility.set_location(l_proc,250);
		     hr_utility.trace('lv_date_worked :'
			     ||to_char(lv_date_worked,'DD-MON-YYYY HH24:MI:SS'));
             end if;
             time_in_dates(sdp_start
                          ,sdp_stop
                          ,sdp_carryover
                          ,sdp_start_time
                          ,sdp_stop_time
                          ,sdp_carryover_time
                          ,lv_date_worked
                          );

             if g_debug then
		     hr_utility.trace('sdp_start_time :'
			     || to_char(sdp_start_time,'DD-MON-YYYY HH24:MI:SS'));
		     hr_utility.trace('sdp_stop_time :'
			     || to_char(sdp_stop_time,'DD-MON-YYYY HH24:MI:SS'));
		     hr_utility.trace('sdp_carryover_time :'
			     || to_char(sdp_carryover_time,'DD-MON-YYYY HH24:MI:SS'));
		     hr_utility.set_location(l_proc,260);

		     hr_utility.trace('g_sdf_rule_completed :'
				    || g_sdf_rule_completed);
		     hr_utility.trace('g_sdf_carryover :'
			     || to_char(g_sdf_carryover,'DD-MON-YYYY HH24:MI:SS'));
             end if;
             IF g_sdf_rule_completed = 'Y' THEN
                if g_debug then
                	hr_utility.set_location(l_proc,270);
 		end if;
                if segment_start >= sdp_start_time and
                   segment_start <  sdp_stop_time then
                   if g_debug then
                   	   hr_utility.set_location(l_proc,280);
 		   end if;
                   sdp_earning_type     := sdp_earning;
                   sdp_earning_found    := 'Y';

                   if segment_stop = sdp_carryover_time then
                      if g_debug then
                      	      hr_utility.set_location(l_proc,290);
                      end if;
                      g_sdf_rule_completed := 'Y';
                      g_sdf_carryover := null;
                      if g_debug then
                      	      hr_utility.trace('g_sdf_carryover :'||g_sdf_carryover);
                      end if;
                   else
                      if g_debug then
                      	      hr_utility.set_location(l_proc,300);
                      end if;
                      g_sdf_rule_completed := 'N';
                      g_sdf_carryover := sdp_carryover_time;
                      if g_debug then
                      	      hr_utility.trace('g_sdf_carryover :'||g_sdf_carryover);
                              hr_utility.set_location(l_proc,310);
                      end if;
                   end if;

                if g_debug then
                	hr_utility.set_location(l_proc,320);
                end if;
                exit;
                else
                   if g_debug then
                   	   hr_utility.set_location(l_proc,330);
                   end if;
                   sdp_earning_type   := null;
                end if;

                if g_debug then
                	hr_utility.set_location(l_proc,340);
                end if;
             ELSIF g_sdf_rule_completed = 'N' THEN

                if g_debug then
                	hr_utility.set_location(l_proc,350);
		end if;
                if g_sdf_carryover = sdp_carryover_time then

                   if g_debug then
                   	   hr_utility.set_location(l_proc,360);
		   end if;
                   sdp_earning_type     := sdp_earning;
                   sdp_earning_found    := 'Y';

                      if segment_stop = sdp_carryover_time then
                         if g_debug then
                         	 hr_utility.set_location(l_proc,370);
                         end if;
                         g_sdf_rule_completed := 'Y';
                         g_sdf_carryover := null;
                         if g_debug then
                         	 hr_utility.trace('g_sdf_carryover :'||g_sdf_carryover);
                         end if;
                      else
                         if g_debug then
                         	 hr_utility.set_location(l_proc,380);
                         end if;
                         g_sdf_rule_completed := 'N';
                         if g_debug then
                         	 hr_utility.trace('g_sdf_carryover :'||g_sdf_carryover);
                         end if;
                      end if;

                if g_debug then
                	hr_utility.set_location(l_proc,390);
                end if;
                exit;
                else
                  if g_debug then
                  	  hr_utility.set_location(l_proc,400);
                  end if;
                  sdp_earning_type   := null;
                end if;

             if g_debug then
             	     hr_utility.set_location(l_proc,410);
             end if;
             END IF;

             lv_date_worked := TRUNC(lv_date_worked + 1, 'DD');

             if g_debug then
             	     hr_utility.set_location(l_proc,420);
             end if;
         END LOOP;

         if g_debug then
         	 hr_utility.set_location(l_proc,430);
         end if;
         IF sdp_earning_found = 'Y' THEN
            if g_debug then
            	    hr_utility.set_location(l_proc,440);
            end if;
            EXIT;
         END IF;
         if g_debug then
         	 hr_utility.set_location(l_proc,450);
         end if;
       END LOOP;

       if g_debug then
       	       hr_utility.set_location(l_proc,460);
       end if;
       close sd_earning;

    ELSE

       if g_debug then
       	       hr_utility.set_location(l_proc,465);
       end if;
       sdp_earning_type   := null;

    END IF;

    if g_debug then
    	    hr_utility.set_location(l_proc,470);
    end if;
    RETURN TRUE;

 ELSE
    if g_debug then
    	    hr_utility.set_location(l_proc,480);
    end if;
    RETURN FALSE;
 END IF; -- check_eligibility

 if g_debug then

 	 hr_utility.set_location(l_proc,490);
 end if;
END; -- segment_earning

FUNCTION segment_start_in_rule
        (p_rule_earning_type OUT NOCOPY NUMBER
        ,p_carryover         OUT NOCOPY NUMBER)
         RETURN BOOLEAN IS

-- Checks to see if the segment start time falls within a shift diff rule.
-- If so, returns the earning type of the rule and the carryover time for
-- calculating the end of the segment.Returns true if the start is within a
-- rule, false if it is not.The | in the comments shows where midnight falls.
-- The segment start and stop are both dates while sdr.start and stop are
-- numbers.

   CURSOR sd_rules IS
    SELECT sdr.element_type_id
          ,sdr.carryover_time
    FROM hxt_shift_diff_rules sdr
    WHERE sdr.sdp_id = g_sdp_id
    AND g_DATE_WORKED BETWEEN
        sdr.effective_start_date AND sdr.effective_end_date
    AND ( (sdr.start_time <= to_number(to_char(segment_start_time, 'HH24MI'))
           AND to_number(to_char(segment_start_time, 'HH24MI')) < sdr.stop_time)
             --  sdr.start  segment.start  sdr.stop  |
       OR ((to_number(to_char(segment_start_time, 'HH24MI')) <= sdr.start_time)
          AND to_number(to_char(segment_start_time, 'HH24MI')) < sdr.stop_time
          AND sdr.start_time > sdr.stop_time)
          --  sdr.start  |  segment.start   sdr.stop
       OR (sdr.start_time <= to_number(to_char(segment_start_time, 'HH24MI'))
          AND sdr.start_time > sdr.stop_time)  );
          --  sdr.start  segment.start  |  sdr.stop

BEGIN

   if g_debug then
   	   hr_utility.set_location('hxt_time_summary.segment_start_in_rule',10);
   end if;
   OPEN sd_rules;
   FETCH sd_rules INTO p_rule_earning_type, p_carryover;
   if g_debug then
   	   hr_utility.trace('p_rule_earning_type :'||p_rule_earning_type);
   	   hr_utility.trace('p_carryover         :'||p_carryover);
   end if;
   IF sd_rules%NOTFOUND THEN
      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.segment_start_in_rule',20);
      end if;
      CLOSE sd_rules;
      RETURN FALSE;
   END IF;
   if g_debug then
   	   hr_utility.set_location('hxt_time_summary.segment_start_in_rule',30);
   end if;
   CLOSE sd_rules;
   RETURN TRUE;

END;

FUNCTION rule_start_in_segment( p_rule_start OUT NOCOPY NUMBER) RETURN BOOLEAN IS

-- Checks to see if a shift diff rule starts within the time segment being
-- generated.This is only called if it is already determined that the start of
-- the segment does not fall within any rule.

   CURSOR sd_rules IS
      SELECT   sdr.start_time
      FROM hxt_shift_diff_rules sdr
      WHERE sdr.sdp_id = g_sdp_id
      AND g_DATE_WORKED BETWEEN
           sdr.effective_start_date AND sdr.effective_end_date
      AND ( ( to_number(to_char(segment_start_time, 'HH24MI')) < sdr.start_time
             AND sdr.start_time < to_number(to_char(p_shift_adjusted_time_out, 'HH24MI'))  )
             --    segment.start  sdr.start   segment.stop  |
         OR (to_number(to_char(segment_start_time, 'HH24MI')) > sdr.start_time
            AND   sdr.start_time < to_number(to_char(p_shift_adjusted_time_out, 'HH24MI'))
            AND to_number(to_char(segment_start_time, 'HH24MI')) >
			to_number(to_char(p_shift_adjusted_time_out, 'HH24MI')) )
            --  segment.start  |  sdr.start   segment.stop
         OR (  to_number(to_char(segment_start_time, 'HH24MI')) < sdr.start_time
            AND to_number(to_char(segment_start_time, 'HH24MI')) >
		to_number(to_char(p_shift_adjusted_time_out, 'HH24MI')) ));
            --  segment.start    sdr.start |  segment.stop

BEGIN

   if g_debug then
   	   hr_utility.set_location('hxt_time_summary.rule_start_in_segment',10);
   end if;
   OPEN sd_rules;
   FETCH sd_rules INTO p_rule_start;
   if g_debug then
   	   hr_utility.trace('p_rule_start :'||p_rule_start);
   end if;
   IF sd_rules%NOTFOUND THEN
      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.rule_start_in_segment',20);
      end if;
      CLOSE sd_rules;
      RETURN FALSE;
   END IF;
   CLOSE sd_rules;
   RETURN TRUE;

END;

FUNCTION set_stop_and_hours
        (p_segment_stop_time IN OUT NOCOPY DATE
        ,p_hours_worked      IN OUT NOCOPY NUMBER) RETURN NUMBER IS

-- Sets the stop time and hours worked of a segment if the start of the segment
-- is within a shift diff rule.The stop time is the earliest of the input time
-- out or the carryover time of the applicable rule.Segment start and stop
-- times are dates which include the day.Carryover and rule start stop times
-- are numbers.Diagrams showing relative times to midnight are S segment start,
-- ST time out of input record, C carryover time,| midnight.

   time_in_hours    NUMBER  := to_number(to_char(segment_start_time, 'HH24MI'));
   time_out_hours   NUMBER  := to_number(to_char(g_time_out, 'HH24MI'));

BEGIN

   if g_debug then
   	   hr_utility.set_location('hxt_time_summary.set_stop_and_hours',10);
   end if;
   p_segment_stop_time := NULL;
   if g_debug then
	   hr_utility.trace('sd_rule_carryover :'||sd_rule_carryover);
	   hr_utility.trace('time_out_hours    :'||time_out_hours);
	   hr_utility.trace('time_in_hours     :'||time_in_hours);
	   hr_utility.trace('p_shift_adjusted_time_out :'||p_shift_adjusted_time_out);
	   hr_utility.trace('segment_start_time :'||segment_start_time);
   end if;
   IF sd_rule_carryover >= time_out_hours THEN
      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.set_stop_and_hours',20);
      end if;
      IF ((time_out_hours > time_in_hours) OR (time_in_hours > sd_rule_carryover)) THEN
         if g_debug then
         	 hr_utility.set_location('hxt_time_summary.set_stop_and_hours',30);
         end if;
         --  | S  ST  C                         S  |  ST  C
         p_segment_stop_time := p_shift_adjusted_time_out;
         if g_debug then
         	 hr_utility.trace('p_segment_stop_time :'||p_segment_stop_time);
         end if;
      ELSIF time_in_hours >= time_out_hours THEN
         if g_debug then
         	 hr_utility.set_location('hxt_time_summary.set_stop_and_hours',40);
         end if;
           --   S  C | ST
         p_segment_stop_time := segment_start_time +
		((hxt_util.time_to_hours(sd_rule_carryover) -
			hxt_util.time_to_hours(time_in_hours)) / 24);
         if g_debug then
         	 hr_utility.trace('p_segment_stop_time :'||p_segment_stop_time);
         end if;
      END IF;
   ELSE   --  carryover < time_out_hours
      IF time_in_hours < sd_rule_carryover THEN
         if g_debug then
         	 hr_utility.set_location('hxt_time_summary.set_stop_and_hours',50);
         end if;
           --  S  C  ST  |
         p_segment_stop_time := segment_start_time +
		((hxt_util.time_to_hours(sd_rule_carryover) -
			hxt_util.time_to_hours(time_in_hours)) / 24);
         if g_debug then
         	 hr_utility.trace('p_segment_stop_time :'||p_segment_stop_time);
         end if;

      ELSIF ((time_in_hours > sd_rule_carryover) AND (time_in_hours > time_out_hours)) THEN
         if g_debug then
         	 hr_utility.set_location('hxt_time_summary.set_stop_and_hours',60);
         end if;
             --  S  |  C  ST
         p_segment_stop_time := segment_start_time +
		((hxt_util.time_to_hours(sd_rule_carryover) +
                (hxt_util.time_to_hours(2400) - hxt_util.time_to_hours(time_in_hours))) / 24);
         if g_debug then
         	 hr_utility.trace('p_segment_stop_time :'||p_segment_stop_time);
         end if;
      ELSIF ((time_in_hours > sd_rule_carryover) AND (time_in_hours < time_out_hours)) THEN
         if g_debug then
         	 hr_utility.set_location('hxt_time_summary.set_stop_and_hours',70);
         end if;
            --  S  ST  |  C
         p_segment_stop_time := p_shift_adjusted_time_out;
         if g_debug then
         	 hr_utility.trace('p_segment_stop_time :'||p_segment_stop_time);
         end if;
      ELSIF ((time_in_hours > sd_rule_carryover)
		AND (time_in_hours = time_out_hours)) THEN --SIR523
            --  S  ST  |  C
         if g_debug then
         	 hr_utility.set_location('hxt_time_summary.set_stop_and_hours',80);
         end if;
         p_segment_stop_time := p_shift_adjusted_time_out;
         if g_debug then
         	 hr_utility.trace('p_segment_stop_time :'||p_segment_stop_time);
         end if;
      ELSIF time_in_hours = sd_rule_carryover THEN
         if g_debug then
         	 hr_utility.set_location('hxt_time_summary.set_stop_and_hours',90);
         end if;
         p_segment_stop_time := p_shift_adjusted_time_out;
         if g_debug then
         	 hr_utility.trace('p_segment_stop_time :'||p_segment_stop_time);
         end if;
      END IF;
   END IF;

   p_hours_worked := ((p_segment_stop_time - segment_start_time) * 24);
   if g_debug then
   	   hr_utility.trace('p_hours_worked :'||p_hours_worked);
   end if;

   IF p_segment_stop_time IS NULL THEN
      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.set_stop_and_hours',100);
      end if;
      FND_MESSAGE.SET_NAME('HXT','HXT_39314_SEG_STOP_TIME_NF');        -- HXT11
      RETURN call_hxthxc_gen_error('HXT','HXT_39314_SEG_STOP_TIME_NF',NULL,location, '');                             -- HXT11
      --2278400 RETURN call_gen_error(location, '');                             -- HXT11
   END IF;

   RETURN 0;

END;

FUNCTION set_stop_at_rule(p_segment_stop_time OUT NOCOPY DATE
         		 ,p_hours_worked      OUT NOCOPY NUMBER) RETURN NUMBER IS
--  Sets the segment stop time and hours worked when a segment starts with no
--  shift diff rule but a rule starts before the segment would end.The stop
--  time is the rule start time.

   time_in_hours    NUMBER  := to_number(to_char(segment_start_time, 'HH24MI'));
   time_out_hours   NUMBER  := to_number(to_char(g_time_out, 'HH24MI'));
   l_stop_time      DATE;  --  local to use to set p_segment_stop_time

BEGIN

   if g_debug then
   	   hr_utility.set_location('hxt_time_summary.set_stop_at_rule',10);
   end if;
   l_stop_time := NULL;

   if g_debug then
	   hr_utility.trace('sd_rule_start :'||sd_rule_start);
	   hr_utility.trace('time_in_hours :'||to_char(segment_stop_time,'DD-MON-YYYY HH24:MI:SS'));
   end if;
   IF sd_rule_start > time_in_hours THEN
      if g_debug then
	      hr_utility.set_location('hxt_time_summary.set_stop_at_rule',20);
	      hr_utility.trace('segment_start_time:'||to_char(segment_start_time,'DD-MON-YYYY HH24:MI:SS'));
      end if;
      l_stop_time := segment_start_time + ((hxt_util.time_to_hours(sd_rule_start)
			 - hxt_util.time_to_hours(time_in_hours)) / 24);
   --  | Segment.start   Rule.start  or  Segment.start  Rule.start |
      if g_debug then
      	      hr_utility.trace('l_stop_time :'||to_char(l_stop_time,'DD-MON-YYYY HH24:MI:SS'));
      end if;
   ELSE
      if g_debug then
	      hr_utility.set_location('hxt_time_summary.set_stop_at_rule',30);
	      hr_utility.trace('segment_start_time:'||to_char(segment_start_time,'DD-MON-YYYY HH24:MI:SS'));
      end if;
      l_stop_time := segment_start_time + ((hxt_util.time_to_hours(sd_rule_start) +
                     (hxt_util.time_to_hours(2400) - hxt_util.time_to_hours(time_in_hours))) / 24);
   --  Segment.start  |  Rule.start
      if g_debug then
      	      hr_utility.trace('l_stop_time :'||to_char(l_stop_time,'DD-MON-YYYY HH24:MI:SS'));
      end if;
   END IF;

   if g_debug then
	   hr_utility.trace('l_stop_time       :'||to_char(l_stop_time,'DD-MON-YYYY HH24:MI:SS'));
	   hr_utility.trace('segment_start_time:'||to_char(segment_start_time,'DD-MON-YYYY HH24:MI:SS'));
   end if;
   p_hours_worked := ((l_stop_time - segment_start_time) * 24);
   p_segment_stop_time := l_stop_time;
   if g_debug then
	   hr_utility.trace('p_hours_worked :'||to_char(p_hours_worked,'DD-MON-YYYY HH24:MI:SS'));
	   hr_utility.trace('p_segment_stop_time :'||to_char(p_segment_stop_time,'DD-MON-YYYY HH24:MI:SS'));
   end if;
   IF l_stop_time IS NULL THEN
      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.set_stop_at_rule',40);
      end if;
      FND_MESSAGE.SET_NAME('HXT','HXT_39314_SEG_STOP_TIME_NF');        -- HXT11
      RETURN call_hxthxc_gen_error('HXT','HXT_39314_SEG_STOP_TIME_NF',NULL,location, '');                             -- HXT11
      --2278400 RETURN call_gen_error(location, '');                             -- HXT11
   END IF;

   RETURN 0;

END;
----------------------------GEN DETAILS MAIN MODULE----------------------------
BEGIN
   g_debug :=hr_utility.debug_enabled;
   if g_debug then
   	   hr_utility.set_location('hxt_time_summary.gen_details',10);
   end if;
   IF segment_chunks.count > 0 THEN
     if g_debug then
     	     hr_utility.set_location('hxt_time_summary.gen_details',11);
     end if;
     FOR l in segment_chunks.first .. segment_chunks.last LOOP
        if g_debug then
        	hr_utility.set_location('hxt_time_summary.gen_details',12);
        end if;
        segment_chunks(l) := null;
     END LOOP;
     segment_chunks.delete;
     if g_debug then
     	     hr_utility.set_location('hxt_time_summary.gen_details',13);
     end if;
   END IF;

   IF sorted_chunks.count > 0 THEN
     if g_debug then
     	     hr_utility.set_location('hxt_time_summary.gen_details',14);
     end if;
     FOR l in sorted_chunks.first .. sorted_chunks.last LOOP
        if g_debug then
        	hr_utility.set_location('hxt_time_summary.gen_details',15);
        end if;
        sorted_chunks(l) := null;
     END LOOP;
     sorted_chunks.delete;
     if g_debug then
     	     hr_utility.set_location('hxt_time_summary.gen_details',16);
     end if;
   END IF;

-- Takes the incoming time in and out from the summary record and splits into
-- segments corresponding to the rules of the applicable shift diff policy.
-- Sends the segments to Gen Special for generating.The segment start and stop
-- are dates which include the day for processing times that span midnight.
-- Returns 0 for normal,2 for error.

-- IF g_sdp_id IS NULL OR g_TIME_IN IS NULL THEN
-- If there is no shift diff policy or only hours entered

   if g_debug then
   	   hr_utility.trace('g_sdp_id          :'||g_sdp_id);
	   hr_utility.trace('g_TIME_IN         :'
			     ||to_char(g_time_in,'DD-MON-YYYY HH24:MI:SS'));
	   hr_utility.trace('g_element_type_id :'||g_element_type_id);
   end if;
   IF g_sdp_id IS NULL OR g_TIME_IN IS NULL
       OR (g_element_type_id IS NOT NULL AND g_CALL_ADJUST_ABS = 'Y') THEN
      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.gen_details',20);
      end if;
-- If there is no shift diff policy or only hours entered or override hours
-- type entered
      segment_start_time := p_shift_adjusted_time_in;
      segment_stop_time  := p_shift_adjusted_time_out;
      hours_worked       := g_hours;
      return_code        := gen_special(location
                                       ,segment_start_time
                                       ,segment_stop_time
                                       ,hours_worked
                                       ,NULL
                                       ,NULL);
   ELSE

      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.gen_details',21);
      end if;

      segment_start_time := p_shift_adjusted_time_in;
      segment_stop_time  := p_shift_adjusted_time_out;

  --  segment_start := to_number(to_char(p_shift_adjusted_time_in,'HH24MI'));
  --  segment_stop  := to_number(to_char(p_shift_adjusted_time_out,'HH24MI'));

      if g_debug then
	      hr_utility.trace('p_shift_adjusted_time_in :'
		      ||to_char(p_shift_adjusted_time_in,'DD-MON-YYYY HH24:MI:SS'));
	      hr_utility.trace('p_shift_adjusted_time_out:'
		      ||to_char(p_shift_adjusted_time_out,'DD-MON-YYYY HH24:MI:SS'));

	      hr_utility.trace('segment_start_time :'
		      ||to_char(segment_start_time,'DD-MON-YYYY HH24:MI:SS'));
	      hr_utility.trace('segment_stop_time  :'
		      ||to_char(segment_stop_time,'DD-MON-YYYY HH24:MI:SS'));

	      hr_utility.set_location('hxt_time_summary.gen_details',22);
      end if;
   -- Insert these rows for hours worked start stop into the
   -- pl sql table segment_chunks.
   -- These start and stop times are entered into a single column
   -- and then sorted by the function sort.

        populate_plsql_table(segment_start_time);
        populate_plsql_table(segment_stop_time);

   -- Now insert the rows for work plan start stop
   -- into the pl sql table segment_chunks for day before , day worked and day
   -- after.
      open  get_work_plan;
      fetch get_work_plan into ln_standard_start ,ln_standard_stop;
      if g_debug then
	      hr_utility.trace('ln_standard_start :'|| ln_standard_start);
	      hr_utility.trace('ln_standard_stop  :'|| ln_standard_stop);
      end if;
      close get_work_plan;

      wplan_date_worked := TRUNC(p_shift_adjusted_time_in - 1, 'DD');
      FOR i in 1 .. 3 LOOP
          if g_debug then
		  hr_utility.trace('wplan_date_worked :'
 			     || to_char(wplan_date_worked,'DD-MON-YYYY HH24:MI:SS'));
          end if;
          time_in_dates(ln_standard_start
                       ,ln_standard_stop
                       ,null
                       ,wp_start_time
                       ,wp_stop_time
                       ,ld_carryover2
                       ,wplan_date_worked);

          if g_debug then
		  hr_utility.trace('wp_start_time :'
			     || to_char(wp_start_time,'DD-MON-YYYY HH24:MI:SS'));
		  hr_utility.trace('wp_stop_time :'
			     || to_char(wp_stop_time,'DD-MON-YYYY HH24:MI:SS'));
		  hr_utility.trace('ld_carryover2 :'
			      || to_char(ld_carryover2,'DD-MON-YYYY HH24:MI:SS'));
	  end if;
          populate_plsql_table(wp_start_time);
          populate_plsql_table(wp_stop_time);

          if g_debug then
          	  hr_utility.set_location('hxt_time_summary.gen_details',23);
	  end if;
          wplan_date_worked := TRUNC(wplan_date_worked + 1, 'DD');
      END LOOP;

      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.gen_details',23.4);
      end if;
      open get_sd_rules;
      LOOP
      -- fetch get_sd_rules into lv_sd_start,lv_sd_stop;
         fetch get_sd_rules into ln_sd_start,ln_sd_stop,ln_sd_carryover;
         Exit when get_sd_rules%NOTFOUND;

	 if g_debug then
		 hr_utility.trace('ln_sd_start      :'||ln_sd_start);
		 hr_utility.trace('ln_sd_stop       :'||ln_sd_stop);
		 hr_utility.trace('ln_sd_carryover  :'||ln_sd_carryover);
	 end if;
      -- Populate the plsql table with the shift policy chunks appended
      -- with the dates for day before , current day and day after
         sd_date_worked := TRUNC(p_shift_adjusted_time_in - 1, 'DD');

         FOR i in 1 .. 3 LOOP
	 if g_debug then
		   hr_utility.set_location('hxt_time_summary.gen_details',23.5);
		   hr_utility.trace('sd_date_worked :'
			      || to_char(sd_date_worked,'DD-MON-YYYY HH24:MI:SS'));
	 end if;
           time_in_dates(ln_sd_start
                        ,ln_sd_stop
                        ,ln_sd_carryover
                        ,sd_start_time
                        ,sd_stop_time
                        ,sd_carryover_time
                        ,sd_date_worked);

  	   if g_debug then
		   hr_utility.trace('sd_start_time :'
			      || to_char(sd_start_time,'DD-MON-YYYY HH24:MI:SS'));
		   hr_utility.trace('sd_carryover_time :'
			      || to_char(sd_carryover_time,'DD-MON-YYYY HH24:MI:SS'));
	   end if;
           populate_plsql_table(sd_start_time);
           populate_plsql_table(sd_carryover_time);

           if g_debug then
           	   hr_utility.set_location('hxt_time_summary.gen_details',23.6);
           end if;
           sd_date_worked := TRUNC(sd_date_worked + 1, 'DD');

         END LOOP;

         if g_debug then
         	 hr_utility.set_location('hxt_time_summary.gen_details',23.8);
         end if;
      END LOOP;
      close get_sd_rules;

      if g_debug then
	      hr_utility.set_location('hxt_time_summary.gen_details',24);

	      hr_utility.trace('FYI');
      end if;
      if segment_chunks.count <> 0 then
         if g_debug then
          	 hr_utility.set_location('hxt_time_summary.gen_details',26);
         end if;
         for l_cnt in segment_chunks.first .. segment_chunks.last loop
             if g_debug then
		     hr_utility.trace('segment_chunks is:'
			  ||to_char(segment_chunks(l_cnt),'DD-MON-YYYY HH24:MI:SS'));
	     end if;
         end loop;
      end if;
      if g_debug then
	      hr_utility.trace('END FYI');
	      hr_utility.set_location('hxt_time_summary.gen_details',27);
      end if;
   -- Get the sorted pl sql table
      sorted_chunks := sort( segment_chunks , 'ASC');

      if g_debug then
      	      hr_utility.trace('FYI');
      end if;
      if sorted_chunks.count <> 0 then
         if g_debug then
         	 hr_utility.set_location('hxt_time_summary.gen_details',28);
         end if;
         for l_cnt in sorted_chunks.first .. sorted_chunks.last loop
             if g_debug then
		     hr_utility.trace('sorted_chunks is:'
			  ||to_char(sorted_chunks(l_cnt),'DD-MON-YYYY HH24:MI:SS'));
             end if;
         end loop;
         if g_debug then
         	 hr_utility.set_location('hxt_time_summary.gen_details',29);
         end if;
      end if;
      if g_debug then
      	      hr_utility.trace('END FYI');
      end if;


      if sorted_chunks.count > 0 then
         if g_debug then
         	 hr_utility.set_location('hxt_time_summary.gen_details',30);
         end if;
         for i in sorted_chunks.first .. sorted_chunks.last-1 loop
             if g_debug then
             	     hr_utility.set_location('hxt_time_summary.gen_details',31);
	     end if;
             chunk_start := sorted_chunks(i);

             if g_debug then
		     hr_utility.trace('chunk_start:'
				 ||to_char(chunk_start,'DD-MON-YYYY HH24:MI:SS'));
             end if;
         /*  if i = sorted_chunks.last then
                chunk_stop := sorted_chunks(sorted_chunks.first);
                if g_debug then
			hr_utility.trace('chunk_stop :'
				 ||to_char(chunk_stop,'DD-MON-YYYY HH24:MI:SS'));
                end if;
             else
         */
                chunk_stop := sorted_chunks(i+1);
 		if g_debug then
			hr_utility.trace('chunk_stop :'
				 ||to_char(chunk_stop,'DD-MON-YYYY HH24:MI:SS'));
		end if;
        --   end if;
             if g_debug then
             	     hr_utility.set_location('hxt_time_summary.gen_details',32);
	     end if;
             IF segment_earning(chunk_start
                               ,chunk_stop
                               ,p_sdp_earning_type
                               ,p_sdovr_earning_type
                                ) THEN
                if g_debug then
                	hr_utility.set_location('hxt_time_summary.gen_details',33);
		end if;
             -- hours_worked:= ((chunk_stop - chunk_start) * 24);
                hours_worked:= ROUND((chunk_stop - chunk_start) * 24,3);

		if g_debug then
			hr_utility.trace('hours_worked     :'|| hours_worked);
			hr_utility.set_location('hxt_time_summary.gen_details',34);
		end if;
                return_code := gen_special(location
                                          ,chunk_start
                                          ,chunk_stop
                                          ,hours_worked
                                          ,p_sdp_earning_type
                                          ,p_sdovr_earning_type);
                if g_debug then
                	hr_utility.set_location('hxt_time_summary.gen_details',35);
                end if;
             END IF; -- segment_earning

         end loop;

         if g_debug then
         	 hr_utility.set_location('hxt_time_summary.gen_details',36);
         end if;

      end if;



/*

      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.gen_details',30);
      end if;
      segment_stop_time  := p_shift_adjusted_time_in;
      if g_debug then
	      hr_utility.trace('p_shift_adjusted_time_in :'
		       ||to_char(p_shift_adjusted_time_in,'DD-MON-YYYY HH24:MI:SS'));
	      hr_utility.trace('p_shift_adjusted_time_out:'
		       ||to_char(p_shift_adjusted_time_out,'DD-MON-YYYY HH24:MI:SS'));
	      hr_utility.trace('return_code       :'
		       ||return_code);
	      hr_utility.trace('segment_stop_time :'
		       ||to_char(segment_stop_time,'DD-MON-YYYY HH24:MI:SS'));
      end if;
      WHILE (segment_stop_time < p_shift_adjusted_time_out) AND return_code = 0
       LOOP
         if g_debug then
         	 hr_utility.set_location('hxt_time_summary.gen_details',40);
         end if;
       --while the end of the last segment is not end of time
         segment_start_time := segment_stop_time; -- start each segment with
                                                  -- stop time of last
 	 if g_debug then
		 hr_utility.trace('segment_start_time :'
		       ||to_char(segment_start_time,'DD-MON-YYYY HH24:MI:SS'));
	 end if;
         IF segment_start_in_rule(sd_rule_earning,sd_rule_carryover) THEN
            if g_debug then
            	    hr_utility.set_location('hxt_time_summary.gen_details',50);
	    end if;
	 -- if the start is in a rule
	    if g_debug then
		    hr_utility.trace('segment_stop_time :'
		       ||to_char(segment_stop_time,'DD-MON-YYYY HH24:MI:SS'));
		    hr_utility.trace('hours_worked :'||hours_worked);
	    end if;
            return_code := set_stop_and_hours(segment_stop_time,hours_worked);
 	    if g_debug then
		    hr_utility.trace('segment_stop_time :'
		       ||to_char(segment_stop_time,'DD-MON-YYYY HH24:MI:SS'));
		    hr_utility.trace('hours_worked :'||hours_worked);
		    hr_utility.trace('return_code  :'||return_code);
	    end if;
         ELSIF rule_start_in_segment(sd_rule_start) THEN
            if g_debug then
            	    hr_utility.set_location('hxt_time_summary.gen_details',60);
            end if;
         -- if a rule starts in the segment
            return_code := set_stop_at_rule(segment_stop_time,hours_worked);
            if g_debug then
		    hr_utility.trace('segment_stop_time :'
		       ||to_char(segment_stop_time,'DD-MON-YYYY HH24:MI:SS'));
		    hr_utility.trace('hours_worked      :'||hours_worked);
		    hr_utility.trace('return_code       :'||return_code);
	    end if;
            sd_rule_earning := NULL;


      -- CHECK IF THERE IS A SHIFT DIFFERENTIAL OVERRIDE APPLICABLE TO THIS DAY
         ELSIF g_sdovr_id is NOT NULL THEN

               open  Get_Shift_stop_time( g_ASSIGNMENT_ID,g_DATE_WORKED );
               fetch Get_Shift_stop_time into lv_standard_stop;
               if g_debug then
               	       hr_utility.trace('lv_standard_stop :'||lv_standard_stop);
               end if;
               close Get_Shift_stop_time;

            -- IF working from 0800 to 2300 then pay only regular hours
            -- from 1200 to 1700 (shift diff defined from 0800 to 1200) and
            -- shift diff Override from 1700 to 2300
               IF to_number(to_char(segment_stop_time,'HH24MI')) < lv_standard_stop THEN
                  if g_debug then
                  	  hr_utility.set_location('hxt_time_summary.gen_details',75);
		  end if;
               -- segment_stop_time := lv_standard_stop;
                  segment_stop_time := to_date((to_char(g_date_worked, 'DDMMYYYY')||lv_standard_stop), 'DDMMYYYYHH24MI');
		  if g_debug then
			  hr_utility.trace('segment_stop_time  :'
			     ||to_char(segment_stop_time,'DD-MON-YYYY HH24:MI:SS'));
			  hr_utility.trace('segment_start_time :'
			     ||to_char(segment_start_time,'DD-MON-YYYY HH24:MI:SS'));
		  end if;
                  hours_worked:=((segment_stop_time - segment_start_time) * 24);
                  if g_debug then
                  	  hr_utility.trace('hours_worked      :'||hours_worked);
                  end if;
                  sd_rule_earning   := NULL;
               ELSE -- segment_stop_time >= lv_standard_stop
                  if g_debug then
                  	  hr_utility.set_location('hxt_time_summary.gen_details',76);
                  end if;
                  segment_stop_time := p_shift_adjusted_time_out;
		  if g_debug then
			  hr_utility.trace('segment_stop_time  :'
			     ||to_char(segment_stop_time,'DD-MON-YYYY HH24:MI:SS'));
			  hr_utility.trace('segment_start_time :'
			     ||to_char(segment_start_time,'DD-MON-YYYY HH24:MI:SS'));
		  end if;
                  hours_worked:=((segment_stop_time - segment_start_time) * 24);
                  if g_debug then
                  	  hr_utility.trace('hours_worked      :'||hours_worked);
 		  end if;
         -- IF the shift differential override is applicable to the time_in and
         -- time_outs ,then set p_sdf_id to g_sdovr_id so that the cursor
         -- cur_elig_prem in hxt_time_pay.gen_premiums returns a row and the
         -- logic gets called to insert the data into hxt_det_hours_worked
                  sd_rule_earning   := g_sdovr_id;
                END IF;
                if g_debug then
                	hr_utility.set_location('hxt_time_summary.gen_details',77);
                end if;
      -- END g_sdovr_id is NOT NULL

         ELSE
         -- NO SHIFT DIFF RULES APPLY
            if g_debug then
		    hr_utility.trace('segment_start_time :'
			||to_char(segment_start_time,'DD-MON-YYYY HH24:MI:SS'));
		    hr_utility.trace('segment_stop_time  :'
			||to_char(segment_stop_time,'DD-MON-YYYY HH24:MI:SS'));
		    hr_utility.trace('p_shift_adjusted_time_out :'
			||to_char(p_shift_adjusted_time_out,'DD-MON-YYYY HH24:MI:SS'));
		    hr_utility.set_location('hxt_time_summary.gen_details',78);
	    end if;
            segment_stop_time := p_shift_adjusted_time_out;
            if g_debug then
		    hr_utility.trace('segment_stop_time  :'
			     ||to_char(segment_stop_time,'DD-MON-YYYY HH24:MI:SS'));
            end if;
            hours_worked      :=((segment_stop_time - segment_start_time) * 24);
            if g_debug then
		    hr_utility.trace('segment_stop_time :'
			     ||to_char(segment_stop_time,'DD-MON-YYYY HH24:MI:SS'));
		    hr_utility.trace('hours_worked      :'||hours_worked);
            end if;
            sd_rule_earning   := NULL;

         END IF;

         if g_debug then
		 hr_utility.trace('location           :'||location);
		 hr_utility.trace('segment_start_time :'
		       ||to_char(segment_start_time,'DD-MON-YYYY HH24:MI:SS'));
		 hr_utility.trace('segment_stop_time  :'
		       ||to_char(segment_stop_time,'DD-MON-YYYY HH24:MI:SS'));
		 hr_utility.trace('sd_rule_earning    :'||sd_rule_earning);
		 hr_utility.trace('return_code        :'||return_code);
         end if;
         IF return_code = 0 THEN
            if g_debug then
            	    hr_utility.set_location('hxt_time_summary.gen_details',80);
            end if;
            loop_count  := loop_count + 1;
            if g_debug then
            	    hr_utility.trace('loop_count :'||loop_count);
            end if;
            return_code := gen_special(location
                                      ,segment_start_time
                                      ,segment_stop_time
                                      ,hours_worked
                                      ,sd_rule_earning);
         END IF;
         IF loop_count > 50 THEN
            if g_debug then
            	    hr_utility.set_location('hxt_time_summary.gen_details',90);
            end if;
            FND_MESSAGE.SET_NAME('HXT','HXT_39300_GEN_DTAIL_EXC_LOOP'); -- HXT11
            return_code := call_gen_error(location, '');                -- HXT11
         END IF;
         IF return_code > 0 THEN
            if g_debug then
            	    hr_utility.set_location('hxt_time_summary.gen_details',100);
            end if;
            EXIT;
         END IF;
      END LOOP;
*/


   if g_debug then
   	   hr_utility.set_location('hxt_time_summary.gen_details',40);
   end if;
   END IF;  --  there is a shift diff policy

   if g_debug then
   	   hr_utility.set_location('hxt_time_summary.gen_details',45);
   end if;
   RETURN return_code;

EXCEPTION

  WHEN OTHERS THEN
    if g_debug then
    	    hr_utility.set_location('hxt_time_summary.gen_details',110);
    end if;
    FND_MESSAGE.SET_NAME('HXT','HXT_39269_ORACLE_ERROR');               -- HXT11
    RETURN call_hxthxc_gen_error('HXT','HXT_39269_ORACLE_ERROR',NULL,location, '', sqlerrm);                       -- HXT11
    --2278400 RETURN call_gen_error(location, '', sqlerrm);                       -- HXT11

END;

FUNCTION Get_Include(p_location        IN VARCHAR2
                    ,p_egt_id          IN NUMBER
                    ,p_element_type_id IN NUMBER
                    ,p_date            IN DATE)
RETURN VARCHAR2 IS

-- Returns 1 if element_type passed found in earning group passed,
--         0 if not in earning group,
--   SQLCODE if Oracle error occurred.

-- Modification Log:
-- 01/19/96   PJA   Created.
-- 02/01/96   AVS  Modified cursor and error handling.

   l_retcode    VARCHAR2(1)  DEFAULT  'N';
   l_error_code NUMBER;
   l_location   VARCHAR2(120) := p_location||':GI';

BEGIN

   if g_debug then
   	   hr_utility.set_location('hxt_time_summary.Get_Include',10);
   end if;
-- Check if no earn group passed
   IF p_egt_id is null THEN
      if g_debug then
      	      hr_utility.set_location('hxt_time_summary.Get_Include',20);
      end if;
      RETURN l_retcode;
   ELSE
      BEGIN
         if g_debug then
         	 hr_utility.set_location('hxt_time_summary.Get_Include',30);
         end if;
      -- Check if element_type exists in earning group
         SELECT 'Y'
         INTO   l_retcode
         FROM   hxt_earn_group_types egt
         WHERE  egt.FCL_EG_TYPE = 'INCLUDE'
         AND    p_date between egt.effective_start_date
                           and egt.effective_end_date
         AND    egt.id = p_egt_id
         AND    exists (SELECT 'x'
                        FROM   hxt_earn_groups egr
                        WHERE  egr.egt_id = p_egt_id    -- SPR C150
                          AND  egr.element_type_id = p_element_type_id
                       );
         RETURN l_retcode;

      EXCEPTION
         WHEN no_data_found THEN
            if g_debug then
            	    hr_utility.set_location('hxt_time_summary.Get_Include',40);
            end if;
            RETURN l_retcode;
      END;
   END IF;

EXCEPTION
  -- Return Oracle error number
     WHEN others THEN
         if g_debug then
         	 hr_utility.set_location('hxt_time_summary.Get_Include',50);
         end if;
         FND_MESSAGE.SET_NAME('HXT','HXT_39270_OR_ERR_G_GROUP');       -- HXT11
	 l_error_code := call_hxthxc_gen_error('HXT','HXT_39270_OR_ERR_G_GROUP',l_location,'', sqlerrm);       -- HXT11
         --2278400 l_error_code := call_gen_error(l_location,'', sqlerrm);       -- HXT11
         RETURN 'E';

END;  -- get include
-------------------------------------------------------------------------------
FUNCTION GEN_SPECIAL (p_location               IN VARCHAR2
                     ,p_time_in                IN DATE
                     ,p_time_out               IN DATE
                     ,p_hours_worked           IN NUMBER
                     ,p_shift_diff_earning_id  IN NUMBER
                     ,p_sdovr_earning_id       IN NUMBER)
             RETURN NUMBER IS

BEGIN

   if g_debug then
	   hr_utility.set_location('hxt_time_summary.GEN_SPECIAL',10);
	   hr_utility.trace('p_time_in               :'||to_char(p_time_in,'DD-MON-YYYY HH24:MI:SS'));
	   hr_utility.trace('p_time_out              :'||to_char(p_time_out,'DD-MON-YYYY HH24:MI:SS'));
	   hr_utility.trace('p_hours_worked          :'||p_hours_worked);
	   hr_utility.trace('p_shift_diff_earning_id :'||p_shift_diff_earning_id);
	   hr_utility.trace('p_sdovr_earning_id      :'||p_sdovr_earning_id);
   end if;
   RETURN hxt_time_detail.generate_special
            ( g_ep_id
             ,g_ep_type
             ,g_egt_id
             ,p_shift_diff_earning_id
             ,g_hdp_id
             ,g_hol_id
             ,g_sdp_id  -- ORACLE bug #715964
             ,g_pep_id
             ,g_pip_id
             ,p_sdovr_earning_id
             ,g_osp_id
             ,g_hol_yn
             ,g_person_id
             ,p_location
             ,g_ID
             ,g_TIM_ID
             ,g_DATE_WORKED
             ,g_ASSIGNMENT_ID
             ,p_hours_worked
             ,p_time_in
             ,p_time_out
             ,g_ELEMENT_TYPE_ID
             ,g_FCL_EARN_REASON_CODE
             ,g_FFV_COST_CENTER_ID
             ,g_FFV_LABOR_ACCOUNT_ID
             ,g_TAS_ID
             ,g_LOCATION_ID
             ,g_SHT_ID
             ,g_HRW_COMMENT
             ,g_FFV_RATE_CODE_ID
             ,g_RATE_MULTIPLE
             ,g_HOURLY_RATE
             ,g_AMOUNT
             ,g_FCL_TAX_RULE_CODE
             ,g_SEPARATE_CHECK_FLAG
             ,g_SEQNO
             ,g_CREATED_BY
             ,g_CREATION_DATE
             ,g_LAST_UPDATED_BY
             ,g_LAST_UPDATE_DATE
             ,g_LAST_UPDATE_LOGIN
             ,g_start_day_of_week
             ,g_EFFECTIVE_START_DATE
             ,g_EFFECTIVE_END_DATE
             ,g_PROJECT_ID
             ,g_JOB_ID
             ,g_PAY_STATUS
             ,g_PA_STATUS
             ,g_RETRO_BATCH_ID
             ,g_PERIOD_START_DATE
             ,g_CALL_ADJUST_ABS
             ,g_STATE_NAME
             ,g_COUNTY_NAME
             ,g_CITY_NAME
             ,g_ZIP_CODE
           --,g_GROUP_ID
            );

   if g_debug then
   	   hr_utility.set_location('hxt_time_summary.GEN_SPECIAL',20);
   end if;
END;  -- gen special

-- begin


END;  -- package

/
