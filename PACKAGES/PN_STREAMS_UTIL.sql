--------------------------------------------------------
--  DDL for Package PN_STREAMS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_STREAMS_UTIL" 
-- $Header: PNSTRMUTLS.pls 120.0.12010000.17 2019/05/17 04:52:00 rabhoopa noship $
 AUTHID CURRENT_USER AS

  G_PROP      CONSTANT VARCHAR2(10) := 'PROPERTY';
  G_EQUIP     CONSTANT VARCHAR2(10) := 'EQUIPMENT';
  --ER#28885404 - COMPOUND INTEREST REQUEST Starts
  G_pr_rule_360_days_yr NUMBER :=360 ; --ER Compounded Daily calculations
  G_pr_rule_365_days_yr NUMBER :=365 ; --ER Compounded Daily calculations

  G_SIMPLE_INTEREST   VARCHAR2(1) := 'S';
  G_COMPOUND_INTEREST VARCHAR2(1) := 'C';

  g_intrst_method_linear PN_SYSTEM_SETUP_OPTIONS.INTEREST_METHOD%TYPE := 'LINEAR'; -- COMPOUND USING INTEREST RATE.
  g_intrst_method_daily_compound PN_SYSTEM_SETUP_OPTIONS.INTEREST_METHOD%TYPE := 'DAILY' ; -- COMPOUND USING DAILY  INTEREST RATE.
  g_intrst_method_simple PN_SYSTEM_SETUP_OPTIONS.INTEREST_METHOD%TYPE := 'SIMPLE'; --SIMPLE INTEREST

  g_period_calc        VARCHAR2(10) := 'PERIODICAL';
  g_daily_calc         VARCHAR2(10) := 'DAILY';

--ER#28885404 - COMPOUND INTEREST REQUEST ends
  FUNCTION get_functional_currency(p_org_id NUMBER,
                          p_mode IN VARCHAR2 DEFAULT PN_STREAMS_UTIL.G_PROP) RETURN VARCHAR2;

  FUNCTION first_day(p_date DATE) RETURN DATE;

  FUNCTION first_day_period(p_date   DATE,
                            p_org_id NUMBER) RETURN DATE;
  FUNCTION last_day_period(p_date   DATE,
                            p_org_id NUMBER) RETURN DATE;

  FUNCTION get_days(p_days_convention NUMBER,
                    p_date1           DATE,
                    p_date2           DATE) RETURN NUMBER;

  FUNCTION get_interest_rate(p_index_id NUMBER,
                             p_date     DATE) RETURN NUMBER;

  FUNCTION calculate_pv(p_actual_amount  NUMBER,
                        p_interest_rate  NUMBER,
                        p_proration_rule NUMBER,
                        p_days           NUMBER,
						p_intrst_method VARCHAR2 DEFAULT g_intrst_method_linear) RETURN NUMBER;  --ER#28885404

  FUNCTION get_rate(p_from_currency   VARCHAR2,
                    p_to_currency     VARCHAR2,
                    p_due_date        DATE,
                    p_conversion_type VARCHAR2,
                    p_user_rate       NUMBER) RETURN NUMBER;

  PROCEDURE put_log(p_string    IN VARCHAR2,
                    p_log_level IN NUMBER DEFAULT fnd_log.level_statement);

  FUNCTION get_frozen_flag(p_org_id NUMBER) RETURN VARCHAR2;

  FUNCTION get_daily_flag(p_org_id IN NUMBER,
                          p_mode IN VARCHAR2 DEFAULT PN_STREAMS_UTIL.G_PROP) RETURN VARCHAR2;
  FUNCTION get_eqp_value RETURN VARCHAR2;

  FUNCTION get_days_360rule( p1 DATE,p2 DATE ) RETURN NUMBER;

  FUNCTION get_calc_pmt_start_date (
    p_change_commencement_date   DATE,
    p_lease_commencement_date    DATE,
    p_term_start_date            DATE,
    p_due_date                   DATE,
	p_period_first_date 		 DATE
    ) RETURN DATE;


  PROCEDURE get_cur_period_pmt_details(p_payment_Term_id 	IN NUMBER,
									 p_option_id 		IN NUMBER,
									 p_period_start_dt 	IN DATE,
									 p_period_end_dt   	IN DATE,
									 p_termination_date  	IN DATE,
									 p_out_no_of_pmts_left 	 OUT NOCOPY NUMBER ,
									 p_out_pmt_date_in_cur_period  OUT NOCOPY DATE ,
									 p_out_pmt_amt_in_cur_period   OUT NOCOPY NUMBER );

  PROCEDURE	get_intr_rate_cur_period(p_payment_Term_id 	IN NUMBER,
									 p_option_id 		IN NUMBER,
									 p_pmt_date         IN DATE,
									 p_out_intr_rate    OUT NOCOPY NUMBER);


    PROCEDURE get_stream_balance_by_date (
                                    p_exclude_lease_change_id    NUMBER,
                                    p_stream_type_code           VARCHAR2,
                                    p_regime_code                VARCHAR2,
                                    p_payment_term_id            NUMBER,
                                    p_option_id                  NUMBER,
			            p_daily_flag				 VARCHAR2, --periodic_change
                                    p_stream_period_start_date   DATE,
			            p_find_period_start_Date_flag VARCHAR2 DEFAULT 'Y' , -- 29718919
                                    p_out_beginning_bal          OUT NOCOPY NUMBER,
                                    p_out_ending_bal             OUT NOCOPY NUMBER
   									 );

   --ER#28885404 COMPOUND INTEREST Changes start
  FUNCTION calc_daily_intrst_rate(p_annual_intrst_rate  NUMBER,
				  p_pr_rule 	        NUMBER)
  RETURN NUMBER;

  FUNCTION calc_intrst_amt(p_actual_amount  		NUMBER,
			  p_annual_intrst_rate   	NUMBER,
			  p_pr_rule 	  		NUMBER,
			  p_days_in_mth		  	NUMBER DEFAULT NULL,
			  p_intrst_durtn_in_days 	NUMBER,
			--p_intrst_type           VARCHAR2 --Simple / compound interest - S/C
			  p_calc_freq             VARCHAR2,
			  p_intrst_method      VARCHAR2 DEFAULT g_intrst_method_linear
			) RETURN NUMBER	;

  FUNCTION calc_daily_compound_rate(p_annual_intrst_rate   	NUMBER,
				    p_pr_rule 		  		NUMBER
				   ) RETURN NUMBER DETERMINISTIC;
  FUNCTION get_intrst_method_flag(p_org_id IN NUMBER,
				  p_mode IN VARCHAR2 DEFAULT PN_STREAMS_UTIL.G_PROP)
				RETURN VARCHAR2 DETERMINISTIC;

  FUNCTION get_calc_freq_flag(p_org_id IN NUMBER,
			      p_mode IN VARCHAR2 DEFAULT PN_STREAMS_UTIL.G_PROP)
				RETURN VARCHAR2 DETERMINISTIC;

  --ER#28885404 COMPOUND INTEREST Changes end

-- 29124813 - VALIDATION ON AMENDMENT COMMENCEMENT DATE start
 FUNCTION is_lease_acd_current_period(p_acd_date DATE,
                       p_source VARCHAR2,
                       p_org_id NUMBER) RETURN VARCHAR2;

 FUNCTION is_compliance_lease(p_lease_id NUMBER) RETURN VARCHAR2;

 PROCEDURE validate_acd_date(p_acd_date DATE
 	,p_lease_id NUMBER
    ,x_Msg_Count             OUT NOCOPY NUMBER
    ,x_Msg_Data              OUT NOCOPY VARCHAR2
    ,x_Return_Status         OUT NOCOPY VARCHAR2);

 PROCEDURE validate_payment_term_date(p_term_id NUMBER
    ,p_lease_context  VARCHAR2
    ,p_term_new_start_date DATE
    ,p_term_new_end_date  DATE
    ,p_lease_commencement_date DATE
    ,p_lease_termindation_Date DATE
    ,x_Msg_Count             OUT NOCOPY NUMBER
    ,x_Msg_Data              OUT NOCOPY VARCHAR2
    ,x_Return_Status         OUT NOCOPY VARCHAR2);

-- 29124813 - VALIDATION ON AMENDMENT COMMENCEMENT DATE end

   FUNCTION get_schedule_date(p_date date,p_sch_day number) return date DETERMINISTIC;

   PROCEDURE get_rou_lia_adjustments(p_lease_id NUMBER
    ,p_payment_Term_id              NUMBER
    ,p_As_of_date                   DATE
    ,p_out_rou_adj_ifrs             OUT NOCOPY NUMBER
    ,p_out_lia_adj_ifrs             OUT NOCOPY NUMBER
    ,p_out_gain_loss_ifrs           OUT NOCOPY NUMBER
    ,p_out_rou_adj_gaap             OUT NOCOPY NUMBER
    ,p_out_lia_adj_gaap             OUT NOCOPY NUMBER
    ,p_out_gain_loss_gaap           OUT NOCOPY NUMBER);

    FUNCTION GET_SOURCE_PAYMENT_TERM_FLAG(p_payment_term_id NUMBER) RETURN VARCHAR2;

    -- 29718919
    PROCEDURE get_term_option_dates( p_lease_id NUMBER,
			             p_payment_term_id  NUMBER,
			             p_option_id  NUMBER,
			             p_out_start_Date OUT NOCOPY DATE,
                                     p_out_end_date OUT NOCOPY DATE);

--------------------------------------
-- End of Package Spec --
--------------------------------------

END pn_streams_util;

/
