--------------------------------------------------------
--  DDL for Package HXT_TIME_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_TIME_SUMMARY" AUTHID CURRENT_USER AS
/* $Header: hxttsum.pkh 120.2.12010000.2 2009/06/08 17:47:02 asrajago ship $ */


--TYPE t_char IS TABLE of varchar2(8000) INDEX BY BINARY_INTEGER;
  TYPE t_date  IS TABLE of DATE INDEX BY BINARY_INTEGER;

  SEGMENT_CHUNKS t_date;
  SORTED_CHUNKS  t_date;

--FUNCTION sort (V_char in t_num, p_order in Varchar2:= 'ASC') RETURN t_char;
--FUNCTION sort (segment_chunks in t_num, p_order in Varchar2) RETURN t_num;



  -- Bug 7359347
  -- New global variable for session date.
  g_sum_session_date      DATE;



  FUNCTION generate_details(
  p_ep_id                 IN NUMBER,
  p_ep_type               IN VARCHAR2,
  p_egt_id                IN NUMBER,
  p_sdp_id                IN NUMBER,
  p_hdp_id                IN NUMBER,
  p_hol_id                IN NUMBER,
  p_pep_id                IN NUMBER,
  p_pip_id                IN NUMBER,
  p_sdovr_id              IN NUMBER,
  p_osp_id                IN NUMBER,
  p_standard_start        IN NUMBER,
  p_standard_stop         IN NUMBER,
  p_early_start           IN NUMBER,
  p_late_stop             IN NUMBER,
  p_hol_yn                IN VARCHAR2,
  p_person_id             IN NUMBER,
  p_location              IN VARCHAR2,
  p_ID                    IN NUMBER,
  p_TIM_ID                IN NUMBER,
  p_DATE_WORKED           IN DATE,
  p_ASSIGNMENT_ID         IN NUMBER,
  p_HOURS                 IN NUMBER,
  p_TIME_IN               IN DATE,
  p_TIME_OUT              IN DATE,
  p_ELEMENT_TYPE_ID       IN NUMBER,
  p_FCL_EARN_REASON_CODE  IN VARCHAR2,
  p_FFV_COST_CENTER_ID    IN NUMBER,
  p_FFV_LABOR_ACCOUNT_ID  IN NUMBER,
  p_TAS_ID                IN NUMBER,
  p_LOCATION_ID           IN NUMBER,
  p_SHT_ID                IN NUMBER,
  p_HRW_COMMENT           IN VARCHAR2,
  p_FFV_RATE_CODE_ID      IN NUMBER,
  p_RATE_MULTIPLE         IN NUMBER,
  p_HOURLY_RATE           IN NUMBER,
  p_AMOUNT                IN NUMBER,
  p_FCL_TAX_RULE_CODE     IN VARCHAR2,
  p_SEPARATE_CHECK_FLAG   IN VARCHAR2,
  p_SEQNO                 IN NUMBER,
  p_CREATED_BY            IN NUMBER,
  p_CREATION_DATE         IN DATE,
  p_LAST_UPDATED_BY       IN NUMBER,
  p_LAST_UPDATE_DATE      IN DATE,
  p_LAST_UPDATE_LOGIN     IN NUMBER,
  p_PERIOD_START_DATE     IN DATE,
  p_ROWIDIN               IN VARCHAR2,
  p_EFFECTIVE_START_DATE  IN DATE,
  p_EFFECTIVE_END_DATE    IN DATE,
  p_PROJECT_ID            IN NUMBER,
  p_JOB_ID                IN NUMBER,
  p_PAY_STATUS            IN VARCHAR2,
  p_PA_STATUS             IN VARCHAR2,
  p_RETRO_BATCH_ID        IN NUMBER,
  p_DT_UPDATE_MODE        IN VARCHAR2,
  p_CALL_ADJUST_ABS       IN VARCHAR2 DEFAULT 'Y',
  p_STATE_NAME            IN VARCHAR2 DEFAULT NULL,
  p_COUNTY_NAME           IN VARCHAR2 DEFAULT NULL,
  p_CITY_NAME             IN VARCHAR2 DEFAULT NULL,
  p_ZIP_CODE              IN VARCHAR2 DEFAULT NULL
  -- p_GROUP_ID              IN NUMBER
)
  RETURN NUMBER;

PROCEDURE time_in_dates(ln_start      in      number
                       ,ln_stop       in      number
                       ,ln_carryover  in      number
                       ,time_in           out nocopy date
                       ,time_out          out nocopy date
                       ,carryover_time    out nocopy date
                       ,l_date_worked in      date);

END;

/
