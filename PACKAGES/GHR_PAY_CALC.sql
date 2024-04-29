--------------------------------------------------------
--  DDL for Package GHR_PAY_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PAY_CALC" AUTHID CURRENT_USER AS
/* $Header: ghpaycal.pkh 120.13.12010000.1 2008/07/28 10:35:57 appldev ship $ */


  --GMIT Pay calcultions.
 g_gm_unadjd_basic_pay   NUMBER;
 gm_unadjusted_pay_flg   VARCHAR2(1);
 -- FWFA Changes Bug#4444609
 g_pay_table_upd_flag BOOLEAN;
 -- GL Change Flag
 g_gl_upd_flag        BOOLEAN;
 -- Bug#4680403
 g_fwfa_pay_calc_flag BOOLEAN;
 g_fw_equiv_pay_plan BOOLEAN;  -- Will be TRUE for FW equivalent employees with PRD 6, E or F
 g_out_to_pay_plan   ghr_pay_plans.pay_plan%TYPE;
 l_spl491_table_name CONSTANT varchar2(80) := '0491 Oracle Federal Special Rate Pay Table (GS) No. 0491';
 -- FWFA Changes

  -- Global constants: (NB: Probably should have begun with  with g - too late now as I assume people have used it!!1)
  l_standard_table_name CONSTANT varchar2(80) := '0000 Oracle Federal Standard Pay Table (AL, ES, EX, GS, GG) No. 0000';

  --
  -- This exception is used to indicate that we do not know how to calculate pay given the set of parameters
  -- NOTE: It is not used if we should be able to calculate but just we had an error
  unable_to_calculate EXCEPTION;
  pay_calc_message    EXCEPTION;
  open_pay_range_mesg EXCEPTION;

  --
  -- want to see if this will work!
  --
  form_item_name    VARCHAR2(61); -- This will be the block_name.item_name
  --
  FUNCTION get_form_item_name
    RETURN VARCHAR2;
  --
  PROCEDURE set_form_item_name(p_value IN VARCHAR2);
  --
  -- This record structure will keep all the in parameters that were passed to the main pay calc process
  TYPE pay_calc_in_rec_type IS RECORD
	                  (person_id                    per_people_f.person_id%TYPE
                        ,position_id                    hr_all_positions_f.position_id%TYPE
                        ,noa_family_code                ghr_families.noa_family_code%TYPE
                        ,noa_code                       ghr_nature_of_actions.code%TYPE
                        ,second_noa_code                ghr_nature_of_actions.code%TYPE
                        --GPPA Update46
                        ,first_action_la_code1          ghr_pa_requests.first_action_la_code1%TYPE
                        ,effective_date                 DATE
                        ,pay_rate_determinant           VARCHAR2(30)
                        ,pay_plan                       VARCHAR2(30)
                        ,grade_or_level                 VARCHAR2(60)
                        ,step_or_rate                   VARCHAR2(30)
                        ,pay_basis                      VARCHAR2(30)
                        ,user_table_id                  NUMBER
                        ,duty_station_id                NUMBER
                        ,auo_premium_pay_indicator      VARCHAR2(30)
                        ,ap_premium_pay_indicator       VARCHAR2(30)
                        ,retention_allowance            NUMBER
                        ,to_ret_allow_percentage        NUMBER(15,2)
                        ,supervisory_differential       NUMBER
                        ,staffing_differential          NUMBER
                        ,current_basic_pay              NUMBER
                        ,current_adj_basic_pay          NUMBER
                        ,current_step_or_rate           VARCHAR2(30)
                        ,pa_request_id                  NUMBER
                        ,open_range_out_basic_pay       NUMBER
			            -- Bug#5482191 Added personnel_system_ind.
		                ,personnel_system_indicator     VARCHAR2(30)
                        --Bug #5132113 added Locality adjustment
                        ,open_out_locality_adj          NUMBER
                         );
  -- FWFA Changes. Added new columns to the OUT record type
  TYPE pay_calc_out_rec_type IS RECORD
	                  (basic_pay                    NUMBER
                        ,locality_adj                 NUMBER
                        ,adj_basic_pay                NUMBER
                        ,total_salary                 NUMBER
                        ,other_pay_amount             NUMBER
                        ,retention_allowance          NUMBER
                        ,ret_allow_perc_out           NUMBER
                        ,au_overtime                  NUMBER
                        ,availability_pay             NUMBER
                        ,out_step_or_rate             VARCHAR2(30)
                        ,out_pay_rate_determinant     VARCHAR2(30)
                        ,PT_eff_start_date            DATE
                        ,open_basicpay_field          BOOLEAN
                        ,open_pay_fields              BOOLEAN
			-- FWFA Changes
			--Bug#5132113
			,open_localityadj_field       BOOLEAN
			,calculation_pay_table_id     NUMBER
			,pay_table_id	              NUMBER
                        ,out_to_grade_id                  NUMBER
                        ,out_to_pay_plan                  VARCHAR2(2)
                        ,out_to_grade_or_level            VARCHAR2(30)
			);
 --
 TYPE retained_grade_rec_type IS RECORD
	                    (person_extra_info_id   NUMBER(15)
                         -- Bug#4423679 Added date_from,date_to columns in the record.
                        ,date_from              DATE
                        ,date_to                DATE
                        ,pay_plan               VARCHAR2(30)
                        ,grade_or_level         VARCHAR2(60)
                        ,step_or_rate           VARCHAR2(30)
                        ,pay_basis              VARCHAR2(30)
                        ,user_table_id          NUMBER
                        ,locality_percent       NUMBER
                        ,temp_step              VARCHAR2(30)
                        );
  --
  FUNCTION get_default_prd (p_position_id    IN NUMBER
                           ,p_effective_date IN DATE)
    RETURN VARCHAR2;
  --
  -- This function returns TRUE if Pay Calc is going to set the step so the form knows to
  -- grey it out, this is especially hard to work out after it has been routed!!
  FUNCTION pay_calc_sets_step(p_first_noa_code  IN VARCHAR2
                             ,p_second_noa_code IN VARCHAR2
                             ,p_pay_plan        IN VARCHAR2
                             ,p_prd             IN VARCHAR2
                             ,p_pa_request_id   IN NUMBER)
    RETURN BOOLEAN;
  --
  FUNCTION convert_amount (p_amount        IN NUMBER
                          ,p_in_pay_basis  IN VARCHAR2
                          ,p_out_pay_basis IN VARCHAR2)
    RETURN NUMBER;
  --
  FUNCTION get_lpa_percentage (p_duty_station_id  ghr_duty_stations_f.duty_station_id%TYPE
                              ,p_effective_date   DATE)
    RETURN NUMBER;
  pragma restrict_references (get_lpa_percentage, WNDS, WNPS);
  --
  -- Bug#5482191
  FUNCTION get_leo_lpa_percentage (p_duty_station_id  ghr_duty_stations_f.duty_station_id%TYPE
                                  ,p_effective_date   DATE)
  RETURN NUMBER;
  --
  --

  FUNCTION get_user_table_name (p_user_table_id IN NUMBER)
    RETURN VARCHAR2;
  --
  FUNCTION get_user_table_id (p_position_id    IN hr_all_positions_f.position_id%TYPE
                           ,p_effective_date IN date)
  RETURN NUMBER;
  --
  FUNCTION get_open_pay_range (p_position_id    IN hr_all_positions_f.position_id%TYPE
                              ,p_person_id      IN per_all_people_f.person_id%type
                              ,p_prd            IN ghr_pa_requests.pay_rate_determinant%type
                              ,p_pa_request_id  IN ghr_pa_requests.pa_request_id%type
                              ,p_effective_date IN date)

  RETURN BOOLEAN;
  --
  PROCEDURE get_pay_table_value (p_user_table_id    IN  NUMBER
                               ,p_pay_plan          IN  VARCHAR2
                               ,p_grade_or_level    IN  VARCHAR2
                               ,p_step_or_rate      IN  VARCHAR2
                               ,p_effective_date    IN  DATE
                               ,p_PT_value          OUT NOCOPY NUMBER
                               ,p_PT_eff_start_date OUT NOCOPY DATE
                               ,p_PT_eff_end_date   OUT NOCOPY DATE);
  --
  --
  FUNCTION get_standard_pay_table_value (p_pay_plan       IN VARCHAR2
                                  ,p_grade_or_level IN VARCHAR2
                                  ,p_step_or_rate   IN VARCHAR2
                                  ,p_effective_date IN DATE)
    RETURN NUMBER;

  -- Bug 3021003
  -- This procedure determines whether any intervening Retained grade exists or not.
  PROCEDURE is_retained_ia(
				p_person_id             IN NUMBER,
				p_effective_date        IN DATE,
				p_retained_pay_plan     IN OUT NOCOPY VARCHAR2,
				p_retained_grade        IN OUT NOCOPY VARCHAR2,
			        p_retained_step_or_rate IN OUT NOCOPY VARCHAR2,
				p_temp_step             IN OUT NOCOPY VARCHAR2,
				p_return_flag OUT NOCOPY BOOLEAN);
  --
  --
  -- This function is used to determine if the given position is a 'LEO'
  -- The definition of a LEO is the 'LEO Position Indicator' on information type 'GHR_US_POS_GRP2'
  -- is 1 or 2
  -- Returns TRUE if it is a LEO Position
  FUNCTION LEO_position (p_prd                    IN VARCHAR2
                        ,p_position_id            IN NUMBER
                        ,p_retained_user_table_id IN NUMBER
                        ,p_duty_station_id        IN ghr_duty_stations_f.duty_station_id%TYPE
                        ,p_effective_date         IN DATE)
    RETURN BOOLEAN;
  --
  FUNCTION get_ppi_amount (p_ppi_code       IN     VARCHAR2
                          ,p_amount         IN     NUMBER
                          ,p_pay_basis      IN     VARCHAR2)
    RETURN NUMBER;
  --

  --Bug# 5132113 added new parameters p_open_out_locality_adj,p_open_localityadj_field
PROCEDURE main_pay_calc (p_person_id                 IN     per_people_f.person_id%TYPE
                        ,p_position_id               IN     hr_all_positions_f.position_id%TYPE
                        ,p_noa_family_code           IN     ghr_families.noa_family_code%TYPE
                        ,p_noa_code                  IN     ghr_nature_of_actions.code%TYPE
                        ,p_second_noa_code           IN     ghr_nature_of_actions.code%TYPE
                        ,p_first_action_la_code1     IN     ghr_pa_requests.first_action_la_code1%TYPE
                        ,p_effective_date            IN     DATE
                        ,p_pay_rate_determinant      IN     VARCHAR2
                        ,p_pay_plan                  IN     VARCHAR2
                        ,p_grade_or_level            IN     VARCHAR2
                        ,p_step_or_rate              IN     VARCHAR2
                        ,p_pay_basis                 IN     VARCHAR2
                        ,p_user_table_id             IN     NUMBER
                        ,p_duty_station_id           IN     NUMBER
                        ,p_auo_premium_pay_indicator IN     VARCHAR2
                        ,p_ap_premium_pay_indicator  IN     VARCHAR2
                        ,p_retention_allowance       IN     NUMBER
                        ,p_to_ret_allow_percentage   IN     NUMBER
                        ,p_supervisory_differential  IN     NUMBER
                        ,p_staffing_differential     IN     NUMBER
                        ,p_current_basic_pay         IN     NUMBER
                        ,p_current_adj_basic_pay     IN     NUMBER
                        ,p_current_step_or_rate      IN     VARCHAR2
                        ,p_pa_request_id             IN     NUMBER
                        ,p_open_range_out_basic_pay  IN     NUMBER DEFAULT NULL
			,p_open_out_locality_adj     IN     NUMBER DEFAULT NULL
                        ,p_basic_pay                    OUT NOCOPY NUMBER
                        ,p_locality_adj                 OUT NOCOPY NUMBER
                        ,p_adj_basic_pay                OUT NOCOPY NUMBER
                        ,p_total_salary                 OUT NOCOPY NUMBER
                        ,p_other_pay_amount             OUT NOCOPY NUMBER
                        ,p_to_retention_allowance       OUT NOCOPY NUMBER
                        ,p_ret_allow_perc_out           OUT NOCOPY NUMBER
                        ,p_au_overtime                  OUT NOCOPY NUMBER
                        ,p_availability_pay             OUT NOCOPY NUMBER
                        -- FWFA Changes
                        ,p_calc_pay_table_id		OUT NOCOPY NUMBER
                        ,p_pay_table_id			OUT NOCOPY NUMBER
                        -- FWFA Changes
                        ,p_out_step_or_rate             OUT NOCOPY VARCHAR2
                        ,p_out_pay_rate_determinant     OUT NOCOPY VARCHAR2
                        ,p_out_to_grade_id              OUT NOCOPY NUMBER
                        ,p_out_to_pay_plan              OUT NOCOPY VARCHAR2
                        ,p_out_to_grade_or_level        OUT NOCOPY VARCHAR2
                        ,p_PT_eff_start_date            OUT NOCOPY DATE
                        ,p_open_basicpay_field          OUT NOCOPY BOOLEAN
                        ,p_open_pay_fields              OUT NOCOPY BOOLEAN
                        ,p_message_set                  OUT NOCOPY BOOLEAN
                        ,p_calculated                   OUT NOCOPY BOOLEAN
			,p_open_localityadj_field       OUT NOCOPY BOOLEAN
                        );
  --
PROCEDURE sql_main_pay_calc (p_pay_calc_data      IN  ghr_pay_calc.pay_calc_in_rec_type
                            ,p_pay_calc_out_data  OUT NOCOPY ghr_pay_calc.pay_calc_out_rec_type
                            ,p_message_set        OUT NOCOPY BOOLEAN
                            ,p_calculated         OUT NOCOPY BOOLEAN
                            );
                                                                                       --AVR
PROCEDURE get_locality_adj_894_PRDM_GS
             (p_user_table_id     IN  NUMBER
             ,p_pay_plan          IN  VARCHAR2
             ,p_grade_or_level    IN  VARCHAR2
             ,p_step_or_rate      IN  VARCHAR2
             ,p_effective_date    IN  DATE
             ,p_cur_adj_basic_pay IN  NUMBER
             ,p_new_basic_pay     IN  NUMBER
             ,p_new_adj_basic_pay OUT NOCOPY NUMBER
             ,p_new_locality_adj  OUT NOCOPY NUMBER);

PROCEDURE get_locality_adj_894_PRDM_GM
             (p_pay_calc_data     IN  ghr_pay_calc.pay_calc_in_rec_type
             ,p_retained_grade    IN  ghr_pay_calc.retained_grade_rec_type
             ,p_new_std_relative_rate OUT NOCOPY NUMBER
             ,p_new_adj_basic_pay OUT NOCOPY NUMBER
             ,p_new_locality_adj  OUT NOCOPY NUMBER);
                                                                                       --AVR
PROCEDURE get_open_pay_table_values (p_user_table_id     IN  NUMBER
                             ,p_pay_plan          IN  VARCHAR2
                             ,p_grade_or_level    IN  VARCHAR2
                             ,p_effective_date    IN  DATE
                             ,p_row_high          OUT NOCOPY NUMBER
                             ,p_row_low           OUT NOCOPY NUMBER);

FUNCTION get_pos_pay_basis (p_position_id    IN per_positions.position_id%TYPE
                           ,p_effective_date IN date)
RETURN VARCHAR2;

FUNCTION get_pay_basis(
				p_effective_date IN ghr_pa_requests.effective_date%type,
				p_pa_request_id IN ghr_pa_requests.pa_request_id%type,
				p_person_id	IN ghr_pa_requests.person_id%type
				) RETURN ghr_pa_requests.from_pay_basis%type;

PROCEDURE get_locality_894_itpay
             (p_pay_calc_data      IN  ghr_pay_calc.pay_calc_in_rec_type
             ,p_retained_grade     IN  ghr_pay_calc.retained_grade_rec_type
             ,p_new_basic_pay      IN  NUMBER
             ,p_GM_unadjusted_rate OUT NOCOPY NUMBER
             ,p_new_adj_basic_pay  OUT NOCOPY NUMBER
             ,p_new_locality_adj   OUT NOCOPY NUMBER);

PROCEDURE get_locality_892_itpay
             (p_pay_calc_data     IN  ghr_pay_calc.pay_calc_in_rec_type
             ,p_retained_grade    IN  ghr_pay_calc.retained_grade_rec_type
             ,p_new_basic_pay     IN  NUMBER
             ,p_new_adj_basic_pay OUT NOCOPY NUMBER
             ,p_new_locality_adj  OUT NOCOPY NUMBER);

-- FWFA Changes. Created procedures get_special_pay_table_value, special_rate_pay_calc
FUNCTION fwfa_pay_calc(p_pay_calc_data     IN  ghr_pay_calc.pay_calc_in_rec_type
                      ,p_retained_grade    IN  ghr_pay_calc.retained_grade_rec_type)
RETURN BOOLEAN;

PROCEDURE get_special_pay_table_value (p_pay_plan          IN VARCHAR2
                                         ,p_grade_or_level     IN VARCHAR2
                                         ,p_step_or_rate       IN VARCHAR2
                                         ,p_user_table_id      IN NUMBER
                                         ,p_effective_date     IN DATE
                                         ,p_pt_value          OUT NOCOPY NUMBER
                                         ,p_PT_eff_start_date OUT NOCOPY DATE
                                         ,p_PT_eff_end_date   OUT NOCOPY DATE
                                         ,p_pp_grd_exists       OUT NOCOPY BOOLEAN);

PROCEDURE special_rate_pay_calc(p_pay_calc_data     IN     ghr_pay_calc.pay_calc_in_rec_type
                               ,p_pay_calc_out_data OUT NOCOPY ghr_pay_calc.pay_calc_out_rec_type
                               ,p_retained_grade    IN OUT NOCOPY ghr_pay_calc.retained_grade_rec_type);
-- Bug# 4748927 Begin
PROCEDURE award_amount_calc (
                         p_position_id              IN NUMBER
                        ,p_pay_plan					IN VARCHAR2
						,p_award_percentage			IN NUMBER
                        ,p_user_table_id			IN NUMBER
						,p_grade_or_level			IN  VARCHAR2
						,p_effective_date			IN  DATE
						,p_basic_pay				IN NUMBER
						,p_adj_basic_pay			IN NUMBER
						,p_duty_station_id			IN ghr_duty_stations_f.duty_station_id%TYPE
						,p_prd						IN ghr_pa_requests.pay_rate_determinant%type
						,p_pay_basis                IN VARCHAR2
						,p_person_id                IN per_people_f.person_id%TYPE
						,p_award_amount				OUT NOCOPY NUMBER
						,p_award_salary				OUT NOCOPY NUMBER
                        );
-- Bug# 4748927 end
END ghr_pay_calc;


/
