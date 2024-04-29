--------------------------------------------------------
--  DDL for Package HXT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_UTIL" AUTHID CURRENT_USER AS
/* $Header: hxtutl.pkh 120.2.12010000.1 2008/07/25 09:51:39 appldev ship $ */

Procedure DEBUG(p_string IN VARCHAR2);

    PROCEDURE GEN_ERROR (p_PPB_ID IN NUMBER
                      ,p_TIM_ID IN NUMBER
                      , p_HRW_ID IN NUMBER
                      , p_PTP_ID IN NUMBER
                      , p_ERROR_MSG IN VARCHAR2
                      , p_LOCATION IN VARCHAR2
                      , p_ORA_MSG IN VARCHAR2
                      , p_EFFECTIVE_START_DATE IN DATE
                      , p_EFFECTIVE_END_DATE IN DATE
                      , p_TYPE IN VARCHAR2);

--------------------------------Procedure GEN ERRORS-----------------------------
  PROCEDURE GEN_ERROR (p_TIM_ID IN NUMBER
                      , p_HRW_ID IN NUMBER
                      , p_PTP_ID IN NUMBER
                      , p_ERROR_MSG IN VARCHAR2
                      , p_LOCATION IN VARCHAR2
                      , p_ORA_MSG IN VARCHAR2
                      , p_EFFECTIVE_START_DATE IN DATE
                      , p_EFFECTIVE_END_DATE IN DATE
                      , p_TYPE IN VARCHAR2);


  PROCEDURE chk_absence(P_assignment_id  IN NUMBER,
                        P_period_id IN NUMBER,
                        P_calculation_date IN DATE,
                        P_element_type_id IN NUMBER,
                        P_hours IN NUMBER,
                        P_net_amt OUT NOCOPY NUMBER,
                        P_period_amt OUT NOCOPY NUMBER,
                        P_available_amt OUT NOCOPY NUMBER,
                        P_abs_status OUT NOCOPY NUMBER);
----------------------------Function Submit Req ---------------------
FUNCTION submit_req
(p_program varchar2,
 p_desc varchar2,
 p_msg varchar2,
 p_loc varchar2,
 p_1 varchar2,p_2 varchar2,p_3 varchar2,p_4 varchar2,
 p_5 varchar2,p_6 varchar2,p_7 varchar2,p_8 varchar2,p_9 varchar2,p_10 varchar2,
 p_11 varchar2,p_12 varchar2,p_13 varchar2,p_14 varchar2,p_15 varchar2,p_16 varchar2,
 p_17 varchar2,p_18 varchar2,p_19 varchar2,p_20 varchar2,p_21 varchar2,p_22 varchar2,
 p_23 varchar2,p_24 varchar2,p_25 varchar2,p_26 varchar2,p_27 varchar2,p_28 varchar2,
 p_29 varchar2,p_30 varchar2,p_31 varchar2,p_32 varchar2,p_33 varchar2,p_34 varchar2,
 p_35 varchar2,p_36 varchar2,p_37 varchar2,p_38 varchar2,p_39 varchar2,p_40 varchar2,
 p_41 varchar2,p_42 varchar2,p_43 varchar2,p_44 varchar2,p_45 varchar2,p_46 varchar2,
 p_47 varchar2,p_48 varchar2,p_49 varchar2,p_50 varchar2,p_51 varchar2,p_52 varchar2,
 p_53 varchar2,p_54 varchar2,p_55 varchar2,p_56 varchar2,p_57 varchar2,p_58 varchar2,
 p_59 varchar2,p_60 varchar2,p_61 varchar2,p_62 varchar2,p_63 varchar2,p_64 varchar2,
 p_65 varchar2,p_66 varchar2,p_67 varchar2,p_68 varchar2,p_69 varchar2,p_70 varchar2,
 p_71 varchar2,p_72 varchar2,p_73 varchar2,p_74 varchar2,p_75 varchar2,p_76 varchar2,
 p_77 varchar2,p_78 varchar2,p_79 varchar2,p_80 varchar2,p_81 varchar2,p_82 varchar2,
 p_83 varchar2,p_84 varchar2,p_85 varchar2,p_86 varchar2,p_87 varchar2,p_88 varchar2,
 p_89 varchar2,p_90 varchar2,p_91 varchar2,p_92 varchar2,p_93 varchar2,p_94 varchar2,
 p_95 varchar2,p_96 varchar2,p_97 varchar2,p_98 varchar2,p_99 varchar2,p_100 varchar2
 ) RETURN number;

--
PROCEDURE check_for_holiday (p_date in DATE
                            ,p_hol_id in NUMBER
                            ,p_day_id OUT NOCOPY  NUMBER
                            ,p_hours OUT NOCOPY NUMBER
                            ,p_retcode OUT NOCOPY NUMBER);

FUNCTION Fnd_Username( a_user_id NUMBER ) RETURN VARCHAR2;
--

FUNCTION element_cat(p_element_type_id IN NUMBER,
                     p_date_worked IN DATE) RETURN varchar2;

FUNCTION    CHECK_POLICY_USE   (p_policy_id in number,
                              p_policy_name in varchar2,
                              p_policy_end_date in date) RETURN BOOLEAN;
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
		      ,p_error OUT NOCOPY NUMBER);


PROCEDURE get_shift_info( p_date IN DATE
			, p_work_id IN OUT NOCOPY NUMBER
			, p_rotation_id IN NUMBER
			, p_osp_id OUT NOCOPY NUMBER
			, p_sdf_id OUT NOCOPY NUMBER
			, p_standard_start OUT NOCOPY NUMBER
			, p_standard_stop OUT NOCOPY NUMBER
			, p_early_start OUT NOCOPY NUMBER
			, p_late_stop OUT NOCOPY NUMBER
			, p_hours OUT NOCOPY NUMBER
			, p_error OUT NOCOPY NUMBER) ;

FUNCTION round_time (p_time  DATE
                   , p_interval  NUMBER
                   , p_round_up  NUMBER) RETURN DATE;

FUNCTION time_to_hours(
  P_TIME IN NUMBER ) RETURN NUMBER;


FUNCTION Get_Next_Seqno(a_timecard_id IN NUMBER, a_date_worked IN DATE) RETURN NUMBER;

FUNCTION Get_Period_End(a_period_id IN NUMBER) RETURN DATE;

FUNCTION Get_Period_Start(a_period_id IN NUMBER) RETURN DATE;

--
FUNCTION date_range
	(start_date_in IN DATE,
	 end_date_in IN DATE,
	 check_time_in IN VARCHAR2 := 'NOTIME')RETURN VARCHAR2;

FUNCTION Get_Retro_Batch_Id(p_tim_id IN NUMBER
                           ,p_batch_name IN VARCHAR2 DEFAULT NULL
                           ,p_batch_ref IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

FUNCTION create_batch(  i_source IN VARCHAR2,
                        p_batch_name IN VARCHAR2 DEFAULT NULL,
                        p_batch_ref IN VARCHAR2 DEFAULT NULL,
                        i_payroll_id IN NUMBER,
                        i_time_period_id IN NUMBER,
                        i_assignment_id IN NUMBER,
                        i_person_id IN NUMBER,
                        o_batch_id OUT NOCOPY NUMBER) RETURN NUMBER;

PROCEDURE GEN_EXCEPTION
      (p_LOCATION            IN   VARCHAR2
       ,p_HXT_ERROR_MSG       IN   VARCHAR2
       ,p_ORACLE_ERROR_MSG    IN   VARCHAR2
       ,p_RESOLUTION          IN   VARCHAR2);


--Begin COSTIN
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
				     o_error_msg OUT NOCOPY VARCHAR2) RETURN NUMBER;
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
                      P_abs_status OUT NOCOPY NUMBER);
FUNCTION accrual_exceeded( p_tim_id  IN NUMBER,
                      P_calculation_date IN DATE,
                      P_accrual_plan_name OUT NOCOPY VARCHAR2,
                      P_accrued_hrs OUT NOCOPY NUMBER,
                      P_charged_hrs OUT NOCOPY NUMBER) return BOOLEAN;

FUNCTION get_costable_type(p_element_type_id IN NUMBER,
                           p_date_worked IN DATE,
                           p_assignment_id IN NUMBER) return VARCHAR2;

FUNCTION get_period_end_date(p_batch_id IN NUMBER) return VARCHAR2;
FUNCTION get_week_day(p_date IN DATE) return VARCHAR2;
Procedure SET_TIMECARD_ERROR (p_PPB_ID               IN NUMBER,
                              p_TIM_ID               IN NUMBER,
                              p_HRW_ID               IN NUMBER,
                              p_PTP_ID               IN NUMBER,
                              p_ERROR_MSG            IN OUT NOCOPY VARCHAR2,
                              p_LOCATION             IN VARCHAR2,
                              p_ORA_MSG              IN VARCHAR2,
                              p_LOOKUP_CODE          IN VARCHAR2,
                              p_valid                OUT NOCOPY VARCHAR,
                              p_msg_level            OUT NOCOPY VARCHAR2);

Procedure GET_QUICK_CODES(p_lookup_code          IN  VARCHAR2,
                          p_lookup_type          IN  VARCHAR2,
                          p_application_id       IN  NUMBER,
                          p_lookup_meaning       OUT NOCOPY VARCHAR2,
                          p_lookup_description   OUT NOCOPY VARCHAR2);
PROCEDURE check_batch_states(P_BATCH_ID IN NUMBER); --3739107

FUNCTION is_valid_time_entry (
p_raw_time_in IN hxt_det_hours_worked_f.time_in%TYPE,
p_rounded_time_in IN hxt_det_hours_worked_f.time_in%TYPE,
p_raw_time_out IN hxt_det_hours_worked_f.time_in%TYPE,
p_rounded_time_out IN hxt_det_hours_worked_f.time_in%TYPE
)
RETURN BOOLEAN ;

PROCEDURE check_timecard_exists (p_person_id IN NUMBER);

--END HXT11i1
END hxt_util;

/
