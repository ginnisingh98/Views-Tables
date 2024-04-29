--------------------------------------------------------
--  DDL for Package PAY_ES_CALC_SS_EARNINGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ES_CALC_SS_EARNINGS" AUTHID CURRENT_USER AS
/* $Header: pyesssec.pkh 120.4 2005/08/05 02:44:07 viviswan noship $ */
--
FUNCTION get_defined_bal_id(p_bal_name         IN  VARCHAR2
                           ,p_db_item_suffix   IN  VARCHAR2) RETURN NUMBER ;
--
FUNCTION Get_Absence_Details(p_absence_attendance_id IN NUMBER
                            ,p_sickness_reason       OUT NOCOPY VARCHAR2
                            ,p_sickness_category     OUT NOCOPY VARCHAR2
                            ,p_temp_dis_start_date   OUT NOCOPY DATE
                            ,p_sickness_end          OUT NOCOPY DATE
                            ,p_info_1                OUT NOCOPY VARCHAR2
                            ,p_info_2                OUT NOCOPY VARCHAR2
                            ,p_info_3                OUT NOCOPY VARCHAR2
                            ,p_info_4                OUT NOCOPY VARCHAR2
                            ,p_info_5                OUT NOCOPY VARCHAR2
                            ,p_info_6                OUT NOCOPY VARCHAR2
                            ,p_info_7                OUT NOCOPY VARCHAR2
                            ,p_info_8                OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

--
FUNCTION Get_Contribution_Days(p_date_earned       IN DATE
                              ,p_no_of_months      IN NUMBER) RETURN NUMBER ;
--
FUNCTION get_person_gender(p_assignment_id   IN NUMBER
                          ,p_date_earned     IN DATE) RETURN VARCHAR2 ;
--
FUNCTION get_days_prev_year(p_date_earned     IN DATE) RETURN NUMBER ;
--
FUNCTION get_ss_contribution_days(p_assignment_id          IN NUMBER
                                 ,p_balance_name           IN VARCHAR2
                                 ,p_database_item_suffix   IN VARCHAR2
                                 ,p_virtal_date            IN DATE
                                 ,p_span_years             IN NUMBER)RETURN NUMBER ;
--
FUNCTION get_linked_absence_details(p_absence_attendance_id       IN NUMBER
                                   ,p_disability_start_date       IN DATE) RETURN NUMBER;
--
FUNCTION get_no_children(passignment_id                   IN NUMBER
                        ,pbusiness_gr_id                  IN NUMBER
                        ,peffective_date                  IN DATE)RETURN NUMBER;
--
FUNCTION get_benefit_slabs(p_assignment_id          IN  NUMBER
                          ,p_business_group_id      IN  NUMBER
                          ,p_absence_attendance_id  IN  NUMBER
                          ,p_disability_start_date  IN  DATE
                          ,p_Start_Date             IN  DATE
                          ,p_End_Date               IN  DATE
                          ,p_Work_Pattern           IN  VARCHAR2
                          ,p_Slab_1_high            IN  NUMBER
                          ,p_Slab_2_high            IN  NUMBER
                          ,p_Slab_SSA_high          IN  NUMBER
                          ,p_Days_Passed_By         IN  NUMBER
                          ,p_Disability_in_current  IN  VARCHAR2
                          ,p_Link_Days              OUT NOCOPY NUMBER
                          ,p_Withheld_Days          OUT NOCOPY NUMBER
                          ,p_Lower_Days             OUT NOCOPY NUMBER
                          ,p_Higher_Days            OUT NOCOPY NUMBER
                          ,p_Lower_BR_Days          OUT NOCOPY NUMBER
                          ,p_Higher_BR_Days         OUT NOCOPY NUMBER) RETURN NUMBER ;
--
FUNCTION get_contract_working_hours(p_assignment_id       IN  NUMBER
                                   ,p_business_group_id   IN  NUMBER
                                   ,p_Start_Date          IN  DATE) RETURN NUMBER;
--
FUNCTION Maternity_Validations(p_absence_attendance_id IN  NUMBER
                              ,p_benefit_days          OUT NOCOPY NUMBER) RETURN VARCHAR2;
--
FUNCTION get_wc_nd_sd_pu_info(p_work_center      IN  NUMBER
                             ,p_date_between     IN  DATE
                             ,p_PU               IN  VARCHAR2
                             ,p_end_date         OUT NOCOPY DATE
                             ,p_part_unemp_perc  OUT NOCOPY NUMBER
                             ,p_start_date       OUT NOCOPY DATE
                             ,p_Cal_method       OUT NOCOPY VARCHAR2
                             ,p_Rate_formula     OUT NOCOPY VARCHAR2
                             ,p_Duration_Formula OUT NOCOPY VARCHAR2) RETURN VARCHAR2;
--
FUNCTION get_wc_pu_info(p_work_center         IN  NUMBER
                       ,p_period_start_date   IN  DATE
                       ,p_period_end_date     IN  DATE
                       ,p_end_date            OUT NOCOPY DATE
                       ,p_part_unemp_perc     OUT NOCOPY NUMBER
                       ,p_start_date          OUT NOCOPY DATE
                       ,p_Cal_method          OUT NOCOPY VARCHAR2
                       ,p_Rate_formula        OUT NOCOPY VARCHAR2
                       ,p_Duration_Formula    OUT NOCOPY VARCHAR2) RETURN VARCHAR2;
--
FUNCTION get_bu_info(p_assignment_id           IN  NUMBER
                       ,p_business_gr_id       IN  NUMBER
                       ,p_date_earned          IN  DATE
                       ,p_abs_cat              IN  VARCHAR2
                       ,p_Total_Days           IN  NUMBER
                       ,p_bu_calc_method_e     IN  VARCHAR2
                       ,p_bu_daily_rate_e      IN  VARCHAR2
                       ,p_bu_duration_e        IN  VARCHAR2
                       ,p_start_date           IN  DATE
                       ,p_end_date             IN  DATE
                       ,p_Daily_Value_Base     IN  NUMBER
                       ,p_Link_Duration_Days   IN  NUMBER
                       ,p_Days_Passed_By       OUT  NOCOPY NUMBER
                       ,p_Benefit_Uplift       OUT  NOCOPY NUMBER
                       ,p_Gross_Pay_Per_Days   OUT  NOCOPY NUMBER
                       ,p_rate1                OUT  NOCOPY NUMBER
                       ,p_value1               OUT  NOCOPY NUMBER
                       ,p_rate2                OUT  NOCOPY NUMBER
                       ,p_value2               OUT  NOCOPY NUMBER
                       ,p_rate3                OUT  NOCOPY NUMBER
                       ,p_value3               OUT  NOCOPY NUMBER
                       ,p_rate4                OUT  NOCOPY NUMBER
                       ,p_value4               OUT  NOCOPY NUMBER
                       ,p_rate5                OUT  NOCOPY NUMBER
                       ,p_value5               OUT  NOCOPY NUMBER
                       ,p_rate6                OUT  NOCOPY NUMBER
                       ,p_value6               OUT  NOCOPY NUMBER
                       ,p_rate7                OUT  NOCOPY NUMBER
                       ,p_value7               OUT  NOCOPY NUMBER
                       ,p_rate8                OUT  NOCOPY NUMBER
                       ,p_value8               OUT  NOCOPY NUMBER
                       ,p_rate9                OUT  NOCOPY NUMBER
                       ,p_value9               OUT  NOCOPY NUMBER
                       ,p_rate10               OUT  NOCOPY NUMBER
                       ,p_value10              OUT  NOCOPY NUMBER
                       ,p_work_center          IN   NUMBER
                       ,p_pattern              IN   VARCHAR2
                       ,p_percentage           IN   NUMBER) RETURN VARCHAR2;
--
FUNCTION get_pu_contribution_value(p_assignment_id          IN NUMBER
                                  ,p_assignment_action_id   IN NUMBER
                                  ,p_balance_SS             IN VARCHAR2
                                  ,p_database_item_SS       IN VARCHAR2
                                  ,p_balance_PU             IN VARCHAR2
                                  ,p_database_item_PU       IN VARCHAR2
                                  ,p_PU_start_date          IN DATE
                                  ,p_span_days              IN NUMBER
                                  ,p_ss_days                OUT NOCOPY NUMBER)RETURN NUMBER;
--
--
END pay_es_calc_ss_earnings;

 

/
