--------------------------------------------------------
--  DDL for Package GHR_PC_BASIC_PAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PC_BASIC_PAY" AUTHID CURRENT_USER AS
/* $Header: ghbasicp.pkh 120.4.12010000.2 2008/08/05 15:01:39 ubhat ship $ */

--
g_noa_family_code      ghr_families.noa_family_code%type;

  FUNCTION get_retained_grade_details (p_person_id      IN NUMBER
                                      ,p_effective_date IN DATE
                                      ,p_pa_request_id  IN NUMBER DEFAULT NULL)
    RETURN ghr_pay_calc.retained_grade_rec_type;
  --
  -- Bug#4016384 Created the following function to get the RG record available
  --             before the MSL effective date.
  FUNCTION get_expired_rg_details (p_person_id      IN NUMBER
                              ,p_effective_date IN DATE
                              ,p_pa_request_id  IN NUMBER DEFAULT NULL)
    RETURN ghr_pay_calc.retained_grade_rec_type;
  --
  PROCEDURE get_min_pay_table_value (p_user_table_id  IN  NUMBER
                             ,p_pay_plan            IN  VARCHAR2
                             ,p_grade_or_level      IN  VARCHAR2
                             ,p_effective_date      IN  DATE
                             ,p_step_or_rate        OUT NOCOPY VARCHAR2
                             ,p_PT_value            OUT NOCOPY NUMBER
                             ,p_PT_eff_start_date   OUT NOCOPY DATE
                             ,p_PT_eff_end_date     OUT NOCOPY DATE);
  --
  PROCEDURE get_max_pay_table_value (p_user_table_id  IN  NUMBER
                             ,p_pay_plan            IN  VARCHAR2
                             ,p_grade_or_level      IN  VARCHAR2
                             ,p_effective_date      IN  DATE
                             ,p_step_or_rate        OUT NOCOPY VARCHAR2
                             ,p_PT_value            OUT NOCOPY NUMBER
                             ,p_PT_eff_start_date   OUT NOCOPY DATE
                             ,p_PT_eff_end_date     OUT NOCOPY DATE);
  --

  --6211029 Added p_in_step_or_rate
  PROCEDURE get_890_pay_table_value (p_user_table_id  IN  NUMBER
                             ,p_pay_plan            IN  VARCHAR2
                             ,p_grade_or_level      IN  VARCHAR2
                             ,p_effective_date      IN  DATE
                             ,p_current_val         IN  NUMBER
			     ,p_in_step_or_rate     IN  VARCHAR2
                             ,p_step_or_rate        OUT NOCOPY VARCHAR2
                             ,p_PT_value            OUT NOCOPY NUMBER
                             ,p_PT_eff_start_date   OUT NOCOPY DATE
                             ,p_PT_eff_end_date     OUT NOCOPY DATE);
  --
  PROCEDURE get_basic_pay_SAL894_6step(p_pay_calc_data     IN  ghr_pay_calc.pay_calc_in_rec_type
                                    ,p_retained_grade    IN  ghr_pay_calc.retained_grade_rec_type
                                    ,p_pay_table_data    IN  VARCHAR2
                                    ,p_basic_pay         OUT NOCOPY NUMBER
                                    ,p_PT_eff_start_date OUT NOCOPY DATE
                                    ,p_7dp               OUT NOCOPY NUMBER);

  PROCEDURE get_basic_pay_SAL894_PRDM (p_pay_calc_data     IN  ghr_pay_calc.pay_calc_in_rec_type
                                      ,p_retained_grade    IN  ghr_pay_calc.retained_grade_rec_type
                                      ,p_basic_pay         OUT NOCOPY NUMBER
                                      ,p_prd               OUT NOCOPY VARCHAR2
                                      ,p_PT_eff_start_date OUT NOCOPY DATE);
  --
  PROCEDURE get_basic_pay (p_pay_calc_data     IN     ghr_pay_calc.pay_calc_in_rec_type
                          ,p_pay_calc_out_data    OUT NOCOPY ghr_pay_calc.pay_calc_out_rec_type
                          ,p_retained_grade    IN OUT NOCOPY ghr_pay_calc.retained_grade_rec_type);
  --
  FUNCTION get_next_WGI_step (p_pay_plan      IN VARCHAR2
                           ,p_current_step  IN VARCHAR2)
 RETURN VARCHAR2;

-- Bug#5114467 Calling proc for Calculating basic pay, locality rate and
-- adjusted basic pay for employee in 'GM' pay plan and NOA 894 AC
PROCEDURE get_894_GM_sp_basic_pay(p_grade_or_level          IN  VARCHAR2
                                 ,p_effective_date          IN  DATE
                                 ,p_user_table_id           IN  pay_user_tables.user_table_id%TYPE
                                 ,p_default_table_id        IN  NUMBER
                                 ,p_curr_basic_pay          IN  NUMBER
                                 ,p_duty_station_id         IN  ghr_duty_stations_f.duty_station_id%TYPE
                                 ,p_new_basic_pay           OUT NOCOPY NUMBER
				                 ,p_new_adj_basic_pay       OUT NOCOPY NUMBER
                                 ,p_new_locality_adj        OUT NOCOPY NUMBER
                                 ,p_new_special_rate        OUT NOCOPY NUMBER
				                 );

-- Bug#5114467 Calling proc for Calculating basic pay, locality rate and
-- adjusted basic pay for WGI employee in 'GM' pay plan AC
PROCEDURE get_wgi_GM_sp_basic_pay(p_grade_or_level          IN  VARCHAR2
                                 ,p_effective_date          IN  DATE
                                 ,p_user_table_id           IN  pay_user_tables.user_table_id%TYPE
                                 ,p_default_table_id        IN  NUMBER
                                 ,p_curr_basic_pay          IN  NUMBER
                                 ,p_duty_station_id         IN  ghr_duty_stations_f.duty_station_id%TYPE
                                 ,p_new_basic_pay           OUT NOCOPY NUMBER
				                 ,p_new_adj_basic_pay       OUT NOCOPY NUMBER
				                 ,p_new_locality_adj        OUT NOCOPY NUMBER
				                 );
--5470182 new procedure added for calculation of 6 step process
PROCEDURE get_basic_pay_SAL890_6step(p_pay_calc_data     IN  ghr_pay_calc.pay_calc_in_rec_type
                                    ,p_retained_grade    IN  ghr_pay_calc.retained_grade_rec_type
                                    ,p_pay_table_data    IN  VARCHAR2
                                    ,p_basic_pay         OUT NOCOPY NUMBER
				    );

END ghr_pc_basic_pay;

/
